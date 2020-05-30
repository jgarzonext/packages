--------------------------------------------------------
--  DDL for Package Body PAC_MD_MNTPROD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_MNTPROD" AS
/******************************************************************************
   NOMBRE:       PAC_MD_MNTPROD
   PROPÓSITO: Funciones para mantenimiento productos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        02/04/2008   ACC                1. Creación del package.
   2.0        07/01/2009   XCG                2. Modificació package. (8510) afegir i/o modificar funcions
   2.1        06/03/2009   FAL                3. 0005548: Recuperar el camp NORDEN als cursors de F_Get_PregunActi y F_Get_PregunPro
   3.0        27/04/2009   APD                4. Bug 9685 - primero se ha de buscar para la actividad en concreto
                                                 y si no se encuentra nada ir a buscar a GARANPRO, PARGARANPRO, PREGUNPROGARAN y
                                                 GARANFORMULA para la actividad cero
   4.0        29/06/2009   AMC                5. Se añaden nuevas funciones bug 10557
   5.0        05/05/2010   AMC                6. Bug 14284. Se añaden nuevas funciones.
   6.0        27/05/2010   AMC                6. Se añade la función f_del_garantia bug 14723
   7.0        04/06/2010   PFA                7. 14588: CRT001 - Añadir campo compañia productos
   8.0        04/06/2010   AMC                8. Se añaden nuevas funciones bug 14748
   9.0        16/06/2010   AMC                9. Se añaden nuevas funciones bug 15023
   10.0       21/06/2010   AMC                10. Se añaden nuevas funciones bug 15148
   11.0       29/06/2010   AMC                11. Se añaden nuevas funciones bug 15149
   12.0       23/07/2010   PFA                12. 15513: MDP - Alta de productos
   13.0       23/08/2010   ICV                13. 0015479: CRT - Muestra por defecto el primer titulo de producto recuperado, refrescar actividad
   14.0       16/07/2010   PFA                14. 15433: MDP003 - En el mant. productos añadir nueva columna en la sección de preguntas.
   15.0       28/10/2010   SRA                15. 16489: CRT101 - Preguntas a nivel de garantia
   16.0       15/12/2010   LCF                16. 16684: Anyadir ccompani para productos especiales
   17.0       25/02/2011   RSC                17. 008999: IAX014 - iAXIS - Mnt. Par?tros
   18.0       09/01/2012   DRA                18. 0020498: LCOL_T001-LCOL - UAT - TEC - Beneficiaris de la p?lissa
   19.0       17/05/2012   MDS                19. 0022253: LCOL - Duración del cobro como campo desplegable
   20.0       28/03/2013   MMS                20. 0026501: POSRA400-(POSRA400)-Vida Grupo (Voluntario)
   21.0       23/01/2014   AGG                15. 0027306: POSS518 (POSSF200)- Resolucion de Incidencias FASE 1-2: Tecnico - VI - Temporales anuales renovables
   22.0       18/02/2014   DEV                22. 0029920: POSFC100-Taller de Productos
   23.0       25/09/2014   JTT                23. 0032367: Añadimos el 'Codigo contable' en el bloque de Administracion
                                                  0032620: Añadimos el 'Tipo de provision' en el bloque Datos tecnicos

******************************************************************************/

   -- Bug 14588 - 07/06/2010 - PFA
   /**************************************************************************
     Inserta un nuevo registro en la tabla companipro. Si existe, lo actualiza
     param in psproduc     : Codigo del producto
     param in pccompani    : Codigo de la compania
     param in pcagencorr   : Codigo del agente en la compania/producto
     param in psproducesp  : Codigo del producto especifico
   **************************************************************************/
   FUNCTION f_insert_companipro(
      psproduc IN NUMBER,
      pccompani IN NUMBER,
      pcagencorr IN VARCHAR2,
      psproducesp IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - psproduc:' || psproduc || ' pccompani=' || pccompani
            || ' pcagencorr=' || pcagencorr || ' psproducesp=' || psproducesp;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.f_insert_companipro';
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF psproduc IS NULL
         OR pccompani IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_mntprod.f_insert_companipro(psproduc, pccompani, pcagencorr, psproducesp);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
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
   END f_insert_companipro;

   /**************************************************************************
     Borra un registro de la tabla companipro.
     param in psproduc     : Codigo del producto
     param in pccompani    : Codigo de la compania
   **************************************************************************/
   FUNCTION f_delete_companipro(
      psproduc IN NUMBER,
      pccompani IN NUMBER,
      psproducesp IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                        := 'parámetros - psproduc= ' || psproduc || ' pccompani=' || pccompani;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.f_delete_companipro';
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF psproduc IS NULL
         OR pccompani IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_mntprod.f_delete_companipro(psproduc, pccompani, psproducesp);

      IF v_result <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_result);
         RAISE e_object_error;
      END IF;

      RETURN v_result;
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
   END f_delete_companipro;

   --Fi Bug 14588 - 07/06/2010 - PFA
/*************************************************************************
      Recupera el objeto con la información del producto
      param in pcempresa   : código empresa
      param in pcramo      : código ramo
      param in pcagrpro    : código agrupación producto
      param in pcactivo    : activo
      param in ccompani    : codigo compañia
      param out mensajes   : mensajes de error
   *************************************************************************/
   FUNCTION f_get_consulta(
      pcempresa IN NUMBER,
      pcramo IN NUMBER,
      pcagrpro IN NUMBER,
      pcactivo IN NUMBER,
      pccompani IN NUMBER,
      --BUG 14588 - PFA -  CRT001 - Añadir campo compañia productos
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempresa=' || pcempresa || ' pcramo=' || pcramo || ' pcagrpro=' || pcagrpro
            || ' pcactivo=' || pcactivo || ' pccompani=' || pccompani;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Get_Consulta';
      squery         VARCHAR2(1000);
      vtwhere        VARCHAR2(500);
      vtfrom         VARCHAR2(50);
      --BUG 14588 - PFA -  CRT001 - Añadir campo compañia productos
      vtselect       VARCHAR2(50);
   BEGIN
      vtwhere := NULL;

      IF pcramo IS NOT NULL THEN
         vtwhere := vtwhere || ' AND P.CRAMO = ' || pcramo;
      END IF;

      IF pcagrpro IS NOT NULL THEN
         vtwhere := vtwhere || ' AND P.CAGRPRO = ' || pcagrpro;
      END IF;

      IF pcactivo IS NOT NULL THEN
         vtwhere := vtwhere || ' AND P.CACTIVO =' || pcactivo;
      END IF;

      IF pcempresa IS NOT NULL THEN
         vtwhere := vtwhere || ' AND C.CEMPRES =' || pcempresa;
      END IF;

      -- Bug 16684 - 25/01/2011 - AMC
      -- Bug 18134 - RSC - 01/04/2011 - CRT - Modificacion de productos genericos
      vtfrom := ', COMPANIAS T';
      --BUG 14588 - PFA -  CRT001 - Añadir campo compañia productos
      vtselect := ', T.CCOMPANI, T.TCOMPANI';

      -- Fin Bug 18134
      IF pccompani IS NOT NULL THEN
         vtwhere :=
            vtwhere
            || ' and p.ccompani = t.ccompani
                         AND P.CCOMPANI = ' || pccompani;
      -- Bug 18134 - RSC - 01/04/2011 - CRT - Modificacion de productos genericos
      ELSE
         vtwhere := vtwhere || ' and p.ccompani = t.ccompani (+)';
      END IF;

      -- Fin Bug 18134

      -- Fi Bug 16684 - 25/01/2011 - AMC
      squery :=
         'SELECT E.TEMPRES, P.SPRODUC, TP.CRAMO||''-''||TP.CMODALI||''-''||TP.CTIPSEG||''-''||TP.CCOLECT CODIPROD, TP.TTITULO, R.TRAMO, D.TATRIBU ACTIVO'
         || vtselect
         || '   FROM PRODUCTOS P, CODIRAM C, RAMOS R, EMPRESAS E, TITULOPRO TP, DETVALORES D'
         || vtfrom || '   WHERE P.CRAMO = C.CRAMO ' || '   AND C.CEMPRES = E.CEMPRES '
         || '   AND C.CRAMO = R.CRAMO ' || '   AND R.CIDIOMA = '
         || pac_md_common.f_get_cxtidioma || '   AND P.CRAMO = TP.CRAMO '
         || '   AND P.CMODALI = TP.CMODALI ' || '   AND P.CTIPSEG = TP.CTIPSEG '
         || '   AND P.CCOLECT = TP.CCOLECT ' || '   AND TP.CIDIOMA = '
         || pac_md_common.f_get_cxtidioma || '   AND D.CVALOR = 108 ' || '   AND D.CIDIOMA = '
         || pac_md_common.f_get_cxtidioma || '   AND D.CATRIBU = P.CACTIVO ' || vtwhere
         || ' ORDER BY CODIPROD ASC';
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
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
   END f_get_consulta;

   /*************************************************************************
      Recupera el objeto con la información del producto filtrado
      param in pcempresa   : código empresa
      param in pcramo      : código ramo
      param in pcagrpro    : código agrupación producto
      param in pcactivo    : activo
      param in ccompani    : codigo compañia
      param out mensajes   : mensajes de error
   *************************************************************************/
   FUNCTION f_get_consulta_filtrado(
      pcempresa IN NUMBER,
      pcramo IN NUMBER,
      pcagrpro IN NUMBER,
      pcactivo IN NUMBER,
      pccompani IN NUMBER,
      --BUG 14588 - PFA -  CRT001 - Añadir campo compañia productos
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempresa=' || pcempresa || ' pcramo=' || pcramo || ' pcagrpro=' || pcagrpro
            || ' pcactivo=' || pcactivo || ' pccompani=' || pccompani;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Get_Consulta';
      squery         VARCHAR2(1000);
      vtwhere        VARCHAR2(500);
      vtfrom         VARCHAR2(50);
      --BUG 14588 - PFA -  CRT001 - Añadir campo compañia productos
      vtselect       VARCHAR2(50);
   BEGIN
      vtwhere := NULL;

      IF pcramo IS NOT NULL THEN
         vtwhere := vtwhere || ' AND P.CRAMO = ' || pcramo;
      END IF;

      IF pcagrpro IS NOT NULL THEN
         vtwhere := vtwhere || ' AND P.CAGRPRO = ' || pcagrpro;
      END IF;

      IF pcactivo IS NOT NULL THEN
         vtwhere := vtwhere || ' AND P.CACTIVO =' || pcactivo;
      END IF;

      IF pcempresa IS NOT NULL THEN
         vtwhere := vtwhere || ' AND C.CEMPRES =' || pcempresa;
      END IF;

      -- Bug 16684 - 25/01/2011 - AMC
      -- Bug 18134 - RSC - 01/04/2011 - CRT - Modificacion de productos genericos
      vtfrom := ', COMPANIAS T';
      --BUG 14588 - PFA -  CRT001 - Añadir campo compañia productos
      vtselect := ', T.CCOMPANI, T.TCOMPANI';

      -- Fin Bug 18134
      IF pccompani IS NOT NULL THEN
         vtwhere :=
            vtwhere
            || ' and p.ccompani = t.ccompani
                         AND P.CCOMPANI = ' || pccompani;
      -- Bug 18134 - RSC - 01/04/2011 - CRT - Modificacion de productos genericos
      ELSE
         vtwhere := vtwhere || ' and p.ccompani = t.ccompani (+)';
      END IF;

      -- Fin Bug 18134

      -- Fi Bug 16684 - 25/01/2011 - AMC
      squery :=
         'SELECT E.TEMPRES, P.SPRODUC, TP.CRAMO||''-''||TP.CMODALI||''-''||TP.CTIPSEG||''-''||TP.CCOLECT CODIPROD, TP.TTITULO, R.TRAMO, D.TATRIBU ACTIVO'
         || vtselect
         || '   FROM PRODUCTOS P, CODIRAM C, RAMOS R, EMPRESAS E, TITULOPRO TP, DETVALORES D'
         || vtfrom || '   WHERE P.CRAMO = C.CRAMO ' || '   AND C.CEMPRES = E.CEMPRES '
         || '   AND C.CRAMO = R.CRAMO ' || '   AND R.CIDIOMA = '
         || pac_md_common.f_get_cxtidioma || '   AND P.CRAMO = TP.CRAMO '
         || '   AND P.CMODALI = TP.CMODALI ' || '   AND P.CTIPSEG = TP.CTIPSEG '
         || '   AND P.CCOLECT = TP.CCOLECT ' || '   AND TP.CIDIOMA = '
         || pac_md_common.f_get_cxtidioma || '   AND D.CVALOR = 108 ' || '   AND D.CIDIOMA = '
         || pac_md_common.f_get_cxtidioma
         || '   AND D.CATRIBU = P.CACTIVO   and
            (select count(*)  from pregunpro where cpregun=433 and sproduc=P.SPRODUC)>0   '
         || vtwhere || ' ORDER BY CODIPROD ASC';
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
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
   END f_get_consulta_filtrado;

   /*************************************************************************
      Duplica el productos especificado como "origen", en un nuevo producto
      identificado como "destino". La salida del duplicado (script o ejecución
      directa en base de datos se puede especificar mediante el parámetro de
      entrada "psalida".
      param in  pramorig    : Ramo origen
      param in  pmodaliorig : Modalidad origen
      param in  ptipsegorig : Tipo seguro origen
      param in  pcolectorig : Colectividad origen
      param in  pramdest    : Ramo destino
      param in  pmodalidest : Modalidad destino
      param in  ptipsegdest : Tipo seguro destino
      param in  pcolectdest : Colectividad destino
      param in  psalida     : Tipo de salida 1/0 ' Script / BD
      param out mensajes    : mensajes de error
      retorno: 0 -> Todo ha ido bien
               <>0 -> Error al duplicar producto.
   *************************************************************************/
   FUNCTION f_duplicarprod(
      pramorig IN NUMBER,
      pmodaliorig IN NUMBER,
      ptipsegorig IN NUMBER,
      pcolectorig IN NUMBER,
      pramdest IN NUMBER,
      pmodalidest IN NUMBER,
      ptipsegdest IN NUMBER,
      pcolectdest IN NUMBER,
      psalida IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(200)
         := 'parámetros - pramorig: ' || pramorig || 'pmodaliorig: ' || pmodaliorig
            || 'ptipsegorig: ' || ptipsegorig || 'pcolectorig: ' || pcolectorig
            || 'pramdest: ' || pramdest || 'pmodalidest: ' || pmodalidest || 'ptipsegdest: '
            || ptipsegdest || 'pcolectdest: ' || pcolectdest || 'psalida: ' || psalida;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_DuplicarProd';
      vtipotablas    NUMBER(8);
      vsproducdest   NUMBER(8);
      ptinfo         t_iax_info;
   BEGIN
      IF pramorig IS NULL
         OR pmodaliorig IS NULL
         OR ptipsegorig IS NULL
         OR pcolectorig IS NULL
         OR pramdest IS NULL
         OR pmodalidest IS NULL
         OR ptipsegdest IS NULL
         OR pcolectdest IS NULL
         OR psalida IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vtipotablas := NULL;   --Dupliquem totes les taules.

      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'PETICION_CODIGOS'),
             0) = 1 THEN
         ptinfo := t_iax_info();
         ptinfo.EXTEND;
         ptinfo(ptinfo.LAST) := ob_iax_info;
         ptinfo(ptinfo.LAST).nombre_columna := 'idRequest';
         ptinfo(ptinfo.LAST).valor_columna := 'SPRODUC';
         ptinfo.EXTEND;
         ptinfo(ptinfo.LAST) := ob_iax_info;
         ptinfo(ptinfo.LAST).nombre_columna := 'cempres';
         ptinfo(ptinfo.LAST).valor_columna := pac_md_common.f_get_cxtempresa;
         ptinfo.EXTEND;
         ptinfo(ptinfo.LAST) := ob_iax_info;
         ptinfo(ptinfo.LAST).nombre_columna := 'cramo';
         ptinfo(ptinfo.LAST).valor_columna := pramdest;
         ptinfo.EXTEND;
         ptinfo(ptinfo.LAST) := ob_iax_info;
         ptinfo(ptinfo.LAST).nombre_columna := 'cidioma';
         ptinfo(ptinfo.LAST).valor_columna := pac_md_common.f_get_cxtidioma;
         ptinfo.EXTEND;
         ptinfo(ptinfo.LAST) := ob_iax_info;
         ptinfo(ptinfo.LAST).nombre_columna := 'ccolect';
         ptinfo(ptinfo.LAST).valor_columna := pcolectdest;
         ptinfo.EXTEND;
         ptinfo(ptinfo.LAST) := ob_iax_info;
         ptinfo(ptinfo.LAST).nombre_columna := 'cmodali';
         ptinfo(ptinfo.LAST).valor_columna := pmodalidest;
         ptinfo.EXTEND;
         ptinfo(ptinfo.LAST) := ob_iax_info;
         ptinfo(ptinfo.LAST).nombre_columna := 'ctipseg';
         ptinfo(ptinfo.LAST).valor_columna := ptipsegdest;
         vnumerr := pac_md_codigos.f_get_codigos(ptinfo, vsproducdest, mensajes);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      ELSE
         vsproducdest := NULL;
--L'sproduc destí no el rebem per paràmetre, sinó que s'asignarà automàticament en el procés de duplicat a partir de la seqüència.
      END IF;

      vnumerr := pac_duplicar.f_dup_producto(pramorig, pmodaliorig, ptipsegorig, pcolectorig,
                                             pramdest, pmodalidest, ptipsegdest, pcolectdest,
                                             vtipotablas, psalida, vsproducdest);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      --Producte duplicat correctament.
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
   END f_duplicarprod;

   /************************************************************************
      Recupera información del producto -->>
   *************************************************************************/

   /*************************************************************************
      Recupera el objeto con la información del producto
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_producto(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_producto IS
      numerr         NUMBER(8) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Get_Producto';
      mntproducto    ob_iax_producto := ob_iax_producto();
   BEGIN
      mntproducto := pac_md_mntprod.f_get_datosgenerales(psproduc, mensajes);
      vpasexec := 2;
      mntproducto.titulo := pac_md_mntprod.f_get_prodtitulo(psproduc, mensajes);
      vpasexec := 3;
      mntproducto.gestion := pac_md_mntprod.f_get_gestion(psproduc, mensajes);
      vpasexec := 4;
      mntproducto.admprod := pac_md_mntprod.f_get_admprod(psproduc, mensajes);
      vpasexec := 5;
      mntproducto.forpago := pac_md_mntprod.f_get_forpago(psproduc, mensajes);
      vpasexec := 6;
      mntproducto.dattecn := pac_md_mntprod.f_get_dattecn(psproduc, mensajes);
      vpasexec := 8;
      mntproducto.activid := pac_md_mntprod.f_get_activid(psproduc, mensajes);
      vpasexec := 9;
      mntproducto.preguntas := pac_md_mntprod.f_get_pregunpro(psproduc, mensajes);
      --Preguntas - SHEILA
      vpasexec := 10;
      mntproducto.parametros := pac_md_mntprod.f_get_parampro(psproduc, mensajes);
      --Parámetros - JOSE MARIA
      vpasexec := 11;
      mntproducto.beneficiarios := pac_md_mntprod.f_get_benefpro(psproduc, mensajes);
      --Beneficiarios - ALBERT
      vpasexec := 12;
      mntproducto.companias := pac_md_mntprod.f_get_companipro(psproduc, mensajes);
      --BUG 14588 - PFA -  CRT001 - Añadir campo compañia productos
      vpasexec := 13;
      mntproducto.planpensiones := pac_md_mntprod.f_get_planpensiones(psproduc, mensajes);
      --BUG JBN 27281: ENSA998-Mantenimiento de fondos y planes de pensiones
      vpasexec := 14;
      mntproducto.interficies := pac_md_mntprod.f_get_interficies(psproduc, mensajes);
      vpasexec := 15;

      IF mntproducto.cagrpro = 21 THEN   --Producte UnitLink
         mntproducto.unitulk := pac_md_mntprod.f_get_unitulk(psproduc, mensajes);
      END IF;

      IF mntproducto.cagrpro = 10 THEN   --Producte Rendes
         mntproducto.datrent := pac_md_mntprod.f_get_datrent(psproduc, mensajes);
      END IF;

      RETURN mntproducto;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_producto;

   /*************************************************************************
      Recupera los datos de los planes de pensiones para ese producto
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_planpensiones(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_planpensiones IS
      planpensiones  t_iax_planpensiones := t_iax_planpensiones();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GET_PLANPENSIONES';
      nerror         NUMBER := 0;
      vccodpla       NUMBER(8);
      vnumerr        NUMBER;
   BEGIN
      BEGIN
         SELECT ccodpla
           INTO vccodpla
           FROM proplapen
          WHERE sproduc = psproduc;

         vnumerr := pac_md_pensiones.f_get_planpensiones(NULL, NULL, NULL, NULL, NULL,
                                                         vccodpla, planpensiones, mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- El producto no tiene asociado ningún plan
            RETURN NULL;
      END;

      RETURN planpensiones;
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
   END f_get_planpensiones;

   /*************************************************************************
      Recupera los datos de la tabla int_codigos_emp para ese producto
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_interficies(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_interficies IS
      t_interficies  t_iax_interficies := t_iax_interficies();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GET_INTERFICIES';

      CURSOR cur_interficies IS
         SELECT *
           FROM int_codigos_emp
          WHERE cvalaxis = TO_CHAR(psproduc)
            AND cempres = pac_md_common.f_get_cxtempresa;
   BEGIN
      FOR r_interficie IN cur_interficies LOOP
         t_interficies.EXTEND;
         t_interficies(t_interficies.LAST) := ob_iax_interficies();
         t_interficies(t_interficies.LAST).ccodigo := r_interficie.ccodigo;
         t_interficies(t_interficies.LAST).cempres := pac_md_common.f_get_cxtempresa;
         t_interficies(t_interficies.LAST).cvalaxis := r_interficie.cvalaxis;
         t_interficies(t_interficies.LAST).cvalemp := r_interficie.cvalemp;
         t_interficies(t_interficies.LAST).cvaldef := r_interficie.cvaldef;
         t_interficies(t_interficies.LAST).cvalaxisdef := r_interficie.cvalaxisdef;
      END LOOP;

      RETURN t_interficies;
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
   END f_get_interficies;

    -- Bug 14588 - 07/06/2010 - PFA
   /*************************************************************************
      Recupera los datos de las compañias para ese producto
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_companipro(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_companiprod IS
      mntcompanias   t_iax_companiprod := t_iax_companiprod();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GET_COMPANIPROD';
      nerror         NUMBER := 0;
      cramo          NUMBER(8);
      cmodali        NUMBER(2);
      ctipseg        NUMBER(2);
      ccolect        NUMBER(2);

      CURSOR cur_companipro IS
         SELECT co.ccompani, c.tcompani, co.cagencorr, co.sproducesp, p.cramo, p.cmodali,
                p.ctipseg, p.ccolect
           FROM companias c, companipro co, productos p, codiram cc
          WHERE co.sproduc = psproduc
            AND p.sproduc = co.sproduc
            AND p.cramo = cc.cramo
            AND cc.cempres = pac_md_common.f_get_cxtempresa
            AND c.ccompani = co.ccompani;
   BEGIN
      FOR companiprod IN cur_companipro LOOP
         mntcompanias.EXTEND;
         mntcompanias(mntcompanias.LAST) := ob_iax_companiprod();
         mntcompanias(mntcompanias.LAST).ccompani := companiprod.ccompani;
         mntcompanias(mntcompanias.LAST).tcompani := companiprod.tcompani;
         mntcompanias(mntcompanias.LAST).cagencorr := companiprod.cagencorr;
         mntcompanias(mntcompanias.LAST).sproducesp := companiprod.sproducesp;

         IF companiprod.sproducesp IS NOT NULL THEN
            SELECT p.cramo, p.cmodali, p.ctipseg, p.ccolect
              INTO cramo, cmodali, ctipseg, ccolect
              FROM productos p
             WHERE p.sproduc = companiprod.sproducesp;

            mntcompanias(mntcompanias.LAST).tproducesp :=
               f_desproducto_t(cramo, cmodali, ctipseg, ccolect, 1,
                               pac_md_common.f_get_cxtidioma());
         END IF;
      END LOOP;

      RETURN mntcompanias;
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
   END f_get_companipro;

   -- Fi Bug 14588 - 07/06/2010 - PFA

   /*************************************************************************
      Recupera el objeto con la información del producto
      recupera titulos del producto
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_prodtitulo(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodtitulo IS
      mntprodtitulo  t_iax_prodtitulo := t_iax_prodtitulo();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GET_PRODTITULO';
      nerror         NUMBER := 0;

      CURSOR cur_prodtit IS
         SELECT cidioma, trotulo, ttitulo
           FROM titulopro
          WHERE cramo || cmodali || ctipseg || ccolect IN(
                                                 SELECT cramo || cmodali || ctipseg || ccolect
                                                   FROM productos
                                                  WHERE sproduc = psproduc);
   BEGIN
      FOR prodtit IN cur_prodtit LOOP
         mntprodtitulo.EXTEND;
         mntprodtitulo(mntprodtitulo.LAST) := ob_iax_prodtitulo();
         mntprodtitulo(mntprodtitulo.LAST).cidioma := prodtit.cidioma;
         nerror := f_desidioma(prodtit.cidioma, mntprodtitulo(mntprodtitulo.LAST).tidioma);

         IF nerror <> 0 THEN
            mntprodtitulo(mntprodtitulo.LAST).tidioma := '';
         END IF;

         mntprodtitulo(mntprodtitulo.LAST).trotulo := prodtit.trotulo;
         mntprodtitulo(mntprodtitulo.LAST).ttitulo := prodtit.ttitulo;
      END LOOP;

      RETURN mntprodtitulo;
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
   END f_get_prodtitulo;

   /*************************************************************************
      Recupera los datos generales del producto
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_datosgenerales(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_producto IS
      mntproducto    ob_iax_producto := ob_iax_producto();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Get_DatosGenerales';
      numerr         NUMBER;

      CURSOR cur_prod IS
         SELECT p.cramo, p.cmodali, p.ctipseg, p.ccolect, p.sproduc, p.cactivo, p.ctermfin,
                p.ctiprie, p.cobjase, p.csubpro, p.nmaxrie,   --p.c2cabezas,
                                                           p.cagrpro, p.cprprod, p.cramdgs,
                p.cdivisa, p.pgaexex, p.pgaexin, p.pgasint, p.pgasext, p.pinttec, p.ccompani
           FROM productos p
          WHERE p.sproduc = psproduc;
   BEGIN
      FOR prod IN cur_prod LOOP
         mntproducto.cempres := pac_md_common.f_get_cxtempresa();
         mntproducto.cramo := prod.cramo;
         mntproducto.cmodali := prod.cmodali;
         mntproducto.ctipseg := prod.ctipseg;
         mntproducto.ccolect := prod.ccolect;
         mntproducto.sproduc := prod.sproduc;
         mntproducto.cactivo := prod.cactivo;
         mntproducto.tactivo := pac_iax_listvalores.f_getdescripvalores(36, prod.cactivo,
                                                                        mensajes);
         mntproducto.ctermfin := prod.ctermfin;
         mntproducto.ttermfin := pac_iax_listvalores.f_getdescripvalores(444, prod.ctermfin,
                                                                         mensajes);
         mntproducto.ctiprie := prod.ctiprie;
         mntproducto.ttiprie := pac_iax_listvalores.f_getdescripvalores(14, prod.ctiprie,
                                                                        mensajes);
         mntproducto.cobjase := prod.cobjase;
         mntproducto.tobjase := pac_iax_listvalores.f_getdescripvalores(65, prod.cobjase,
                                                                        mensajes);
         mntproducto.csubpro := prod.csubpro;
         mntproducto.tsubpro := pac_iax_listvalores.f_getdescripvalores(37, prod.csubpro,
                                                                        mensajes);
         mntproducto.nmaxrie := prod.nmaxrie;
         mntproducto.c2cabezas := NULL;   --prod.c2cabezas;
         --Temporalment recupero el paràmetre 2cabezas de un parproducto, però en realitat forma part de taula PRODUCTOS
         mntproducto.c2cabezas := NVL(f_parproductos_v(psproduc, '2_CABEZAS'), 0);
         mntproducto.cagrpro := prod.cagrpro;
         mntproducto.tagrpro := pac_iax_listvalores.f_getdescripvalores(283, prod.cagrpro,
                                                                        mensajes);
         mntproducto.cprprod := prod.cprprod;
         mntproducto.tprprod := pac_iax_listvalores.f_getdescripvalores(205, prod.cprprod,
                                                                        mensajes);
         mntproducto.cramdgs := prod.cramdgs;
         numerr := f_desramodgs(prod.cramdgs, pac_md_common.f_get_cxtidioma(),
                                mntproducto.tramdgs);

         IF numerr <> 0 THEN
            mntproducto.tramdgs := '';
         END IF;

         mntproducto.cdivisa := prod.cdivisa;

         IF prod.cdivisa IS NOT NULL THEN
            mntproducto.tdivisa :=
               pac_iax_listvalores.f_getdescripvalor
                                            ('select tdivisa from divisa where cdivisa = '
                                             || prod.cdivisa || ' and cidioma = '
                                             || pac_md_common.f_get_cxtidioma(),
                                             mensajes);
         END IF;

         mntproducto.pgaexex := prod.pgaexex;
         mntproducto.pgaexin := prod.pgaexin;
         mntproducto.pgasint := prod.pgasint;
         mntproducto.pgasext := prod.pgasext;
         --Bug.: 15479 - ICV - 23/07/2010
         mntproducto.ttitulo := f_desproducto_t(prod.cramo, prod.cmodali, prod.ctipseg,
                                                prod.ccolect, 1,
                                                pac_md_common.f_get_cxtidioma());
         mntproducto.ccompani := prod.ccompani;

         IF prod.ccompani IS NOT NULL THEN
            mntproducto.tcompani :=
               pac_iax_listvalores.f_getdescripvalor
                                       ('select tcompani from companias where ccompani = '
                                        || prod.ccompani,
                                        mensajes);
         END IF;
      --  mntproducto.pinttec := prod.pinttec;
      END LOOP;

      RETURN mntproducto;
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
   END f_get_datosgenerales;

   /*************************************************************************
      Recupera el objeto con la información del producto
      datos de gestión
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_gestion(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_prodgestion IS
      mntgestion     ob_iax_prodgestion := ob_iax_prodgestion();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Get_Gestion';

      CURSOR cur_ges IS
         SELECT p.*, (SELECT COUNT(1)
                        FROM prodcartera
                       WHERE sproduc = p.sproduc) cprodcar
           FROM productos p
          WHERE p.sproduc = psproduc;
   BEGIN
      FOR ges IN cur_ges LOOP
         mntgestion.cduraci := ges.cduraci;
         mntgestion.tduraci := pac_iax_listvalores.f_getdescripvalores(20, ges.cduraci,
                                                                       mensajes);
         mntgestion.ctempor := ges.ctempor;
         mntgestion.ttempor := pac_iax_listvalores.f_getdescripvalores(23, ges.ctempor,
                                                                       mensajes);
         mntgestion.ndurcob := ges.ndurcob;
         mntgestion.cdurmin := ges.cdurmin;
         mntgestion.tdurmin := pac_iax_listvalores.f_getdescripvalores(686, ges.cdurmin,
                                                                       mensajes);
         mntgestion.nvtomin := ges.nvtomin;
         mntgestion.cdurmax := ges.cdurmax;
         mntgestion.tdurmax := pac_iax_listvalores.f_getdescripvalores(209, ges.cdurmax,
                                                                       mensajes);
         mntgestion.nvtomax := ges.nvtomax;
         mntgestion.ctipefe := ges.ctipefe;
         mntgestion.ttipefe := pac_iax_listvalores.f_getdescripvalores(42, ges.ctipefe,
                                                                       mensajes);
         mntgestion.nrenova := ges.nrenova;
         mntgestion.cmodnre := ges.cmodnre;
         -- CPRODCAR falta definir que es
         mntgestion.crevali := ges.crevali;
         mntgestion.trevali := pac_iax_listvalores.f_getdescripvalores(62, ges.crevali,
                                                                       mensajes);
         mntgestion.prevali := ges.prevali;
         mntgestion.irevali := ges.irevali;
         mntgestion.ctarman := ges.ctarman;
         mntgestion.ttarman := pac_iax_listvalores.f_getdescripvalores(56, ges.ctarman,
                                                                       mensajes);
         mntgestion.creaseg := ges.creaseg;
         mntgestion.treaseg := pac_iax_listvalores.f_getdescripvalores(108, ges.creaseg,
                                                                       mensajes);
         mntgestion.creteni := ges.creteni;
         mntgestion.treteni := pac_iax_listvalores.f_getdescripvalores(66, ges.creteni,
                                                                       mensajes);
         mntgestion.cprorra := ges.cprorra;
         mntgestion.tprorra := pac_iax_listvalores.f_getdescripvalores(174, ges.cprorra,
                                                                       mensajes);
         mntgestion.cprimin := ges.cprimin;
         mntgestion.tprimin := pac_iax_listvalores.f_getdescripvalores(685, ges.cprimin,
                                                                       mensajes);
         mntgestion.iprimin := ges.iprimin;
         mntgestion.cclapri := ges.cclapri;

         IF ges.cclapri IS NOT NULL THEN
            mntgestion.tclapri :=
               pac_iax_listvalores.f_getdescripvalor
                                    ('select descripcion from sgt_formulas where cramo = '
                                     || ges.cramo || ' and clave = ' || ges.cclapri,
                                     mensajes);
         END IF;

         mntgestion.ipminfra := ges.ipminfra;
         mntgestion.nedamic := ges.nedamic;
         mntgestion.ciedmic := ges.ciedmic;
         mntgestion.nedamac := ges.nedamac;
         mntgestion.ciedmac := ges.ciedmac;
         mntgestion.nedamar := ges.nedamar;
         mntgestion.ciedmar := ges.ciedmar;
         mntgestion.nedmi2c := ges.nedmi2c;
         mntgestion.ciemi2c := ges.ciemi2c;
         mntgestion.nedma2c := ges.nedma2c;
         mntgestion.ciema2c := ges.ciema2c;
         mntgestion.nedma2r := ges.nedma2r;
         mntgestion.ciema2r := ges.ciema2r;
         mntgestion.nsedmac := ges.nsedmac;
         mntgestion.cisemac := ges.cisemac;
         mntgestion.cvinpol := ges.cvinpol;
         mntgestion.cvinpre := ges.cvinpre;
         mntgestion.ccuesti := ges.ccuesti;
         mntgestion.cctacor := ges.cctacor;
         mntgestion.cprodcar := ges.cprodcar;
         mntgestion.cpreaviso := ges.cpreaviso;
         mntgestion.durperiodoprod := pac_md_mntprod.f_get_durperiod(psproduc, mensajes);
      END LOOP;

      RETURN mntgestion;
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
   END f_get_gestion;

   /*************************************************************************
      Recupera el objeto con la información del producto
      datos gestión duraciones
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_durperiod(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_proddurperiodo IS
      mntdurperiod   t_iax_proddurperiodo := t_iax_proddurperiodo();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Get_Durperiod';

      CURSOR cur_proddur IS
         SELECT ndurper, finicio, ffin
           FROM durperiodoprod
          WHERE sproduc = psproduc;
   BEGIN
      FOR prodtit IN cur_proddur LOOP
         mntdurperiod.EXTEND;
         mntdurperiod(mntdurperiod.LAST) := ob_iax_proddurperiodo();
         mntdurperiod(mntdurperiod.LAST).ndurper := prodtit.ndurper;
         mntdurperiod(mntdurperiod.LAST).finicio := prodtit.finicio;
         mntdurperiod(mntdurperiod.LAST).ffin := prodtit.ffin;
      END LOOP;

      RETURN mntdurperiod;
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
   END f_get_durperiod;

   /*************************************************************************
      Recupera el objeto con la información del producto
      datos administración
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_admprod(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_prodadministracion IS
      mntadmprod     ob_iax_prodadministracion := ob_iax_prodadministracion();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Get_Admprod';
      nerror         NUMBER;

      -- Bug 32367 - 25/09/2014 - JTT: Recuperamos el 'Codigo contable del cliente' (cnvproductos_ext.cnv_spr)
      CURSOR cur_admprod IS
         SELECT p.*, UPPER(c.cnv_spr) cnv_spr
           FROM productos p, cnvproductos_ext c
          WHERE p.sproduc = psproduc
            AND c.sproduc(+) = p.sproduc;
   BEGIN
      FOR admprod IN cur_admprod LOOP
         mntadmprod.ctipges := admprod.ctipges;
         mntadmprod.ttipges := pac_iax_listvalores.f_getdescripvalores(43, admprod.ctipges,
                                                                       mensajes);
         mntadmprod.creccob := admprod.creccob;

         IF ff_es_correduria(pac_md_common.f_get_cxtempresa) = 1 THEN
            mntadmprod.treccob := pac_iax_listvalores.f_getdescripvalores(694,
                                                                          admprod.creccob,
                                                                          mensajes);
         END IF;

         mntadmprod.ctipreb := admprod.ctipreb;
         mntadmprod.ttipreb := pac_iax_listvalores.f_getdescripvalores(40, admprod.ctipreb,
                                                                       mensajes);
         mntadmprod.ccalcom := admprod.ccalcom;
         mntadmprod.tcalcom := pac_iax_listvalores.f_getdescripvalores(122, admprod.ccalcom,
                                                                       mensajes);
         mntadmprod.ctippag := admprod.ctippag;
         mntadmprod.ttippag := pac_iax_listvalores.f_getdescripvalores(39, admprod.ctippag,
                                                                       mensajes);
         mntadmprod.cmovdom := admprod.cmovdom;
         mntadmprod.cfeccob := admprod.cfeccob;
         mntadmprod.crecfra := admprod.crecfra;
         mntadmprod.iminext := admprod.iminext;
         mntadmprod.ndiaspro := admprod.ndiaspro;
         mntadmprod.scuecar := admprod.scuecar;

         IF admprod.scuecar IS NOT NULL THEN
            mntadmprod.tcuecar :=
               pac_iax_listvalores.f_getdescripvalor
                                    ('select tacuecar from codictacargos where cidioma = '
                                     || pac_md_common.f_get_cxtidioma() || ' and scuecar = '
                                     || admprod.scuecar,
                                     mensajes);
         END IF;

         mntadmprod.cnv_spr := admprod.cnv_spr;
--            mntadmprod.ccobban := F_Buscacobban (admprod.cramo,admprod.cmodali,admprod.ctipseg,admprod.ccolect,null,null,null,nerror);
--            if nerror = 0 then
--               nerror := F_Descuentacob(mntadmprod.ccobban,mntadmprod.tcobban);
--            end if;
--            if nerror <> 0 then
--               PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(mensajes,vobject,
--               nerror,vpasexec,vparam,psqcode=>sqlcode,psqerrm=>sqlerrm);
--            end if;
      END LOOP;

      RETURN mntadmprod;
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
   END f_get_admprod;

   /*************************************************************************
      Recupera el objeto con la información del producto
      formas de pago
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_forpago(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodformapago IS
      mntforpag      t_iax_prodformapago := t_iax_prodformapago();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GET_FORPAGO';
      vcforpag       NUMBER;

      CURSOR cur_detvalores IS
         SELECT   catribu, tatribu
             FROM detvalores
            WHERE cvalor = 17
              AND cidioma = pac_md_common.f_get_cxtidioma
         ORDER BY catribu;

      CURSOR cur_prodformapago IS
         SELECT f.*, p.cpagdef, p.crevfpg
           FROM forpagpro f, productos p
          WHERE f.cramo = p.cramo
            AND f.cmodali = p.cmodali
            AND f.ctipseg = p.ctipseg
            AND f.ccolect = p.ccolect
            AND p.sproduc = psproduc
            AND f.cforpag = vcforpag;
   BEGIN
      FOR detval IN cur_detvalores LOOP
         vcforpag := detval.catribu;
         mntforpag.EXTEND;
         mntforpag(mntforpag.LAST) := ob_iax_prodformapago();
         mntforpag(mntforpag.LAST).cforpag := detval.catribu;
         mntforpag(mntforpag.LAST).tforpag := detval.tatribu;
         --PAC_IAX_LISTVALORES.F_GetDescripValores(17, prodfor.cforpag, mensajes);
         mntforpag(mntforpag.LAST).cobliga := 0;
         mntforpag(mntforpag.LAST).cpagdef := 0;

         IF vcforpag = 0
            AND psproduc IS NOT NULL THEN
            -- si es forma de pago única inicializamos los siguientes campos...
            mntforpag(mntforpag.LAST).crevfpg :=
               pac_iax_listvalores.f_getdescripvalor
                                         ('select crevfpg from productos where sproduc = '
                                          || psproduc,
                                          mensajes);
         END IF;

         FOR prodfor IN cur_prodformapago LOOP
            mntforpag(mntforpag.LAST).cobliga := 1;

            IF detval.catribu = prodfor.cpagdef THEN
               mntforpag(mntforpag.LAST).cpagdef := 1;
            END IF;

            IF vcforpag IS NOT NULL THEN
               mntforpag(mntforpag.LAST).precarg :=
                  pac_iax_listvalores.f_getdescripvalor
                     ('select precarg from forpagrecprod f, productos p where p.sproduc = '
                      || psproduc
                      || ' and p.cramo = f.cramo and p.cmodali = f.cmodali and p.ctipseg = f.ctipseg and p.ccolect = f.ccolect and f.cforpag ='
                      || vcforpag,
                      mensajes);
            END IF;
         END LOOP;
      END LOOP;

      RETURN mntforpag;
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
   END f_get_forpago;

   /*************************************************************************
      Recupera el objeto con la información del producto
      datos tecnicos
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_dattecn(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_proddatostecnicos IS
      mntdattecn     ob_iax_proddatostecnicos := ob_iax_proddatostecnicos();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GET_DATTECN';
      vtablas        NUMBER;
      vcodint        NUMBER;
      v_numerr       NUMBER;

      CURSOR cur_dattecn IS
         SELECT p.nniigar, p.nniggar, p.cmodint, p.cintrev
           FROM productos p
          WHERE p.sproduc = psproduc;
   BEGIN
      FOR dattecn IN cur_dattecn LOOP
         mntdattecn.nniigar := dattecn.nniigar;
         mntdattecn.nniggar := dattecn.nniggar;
         mntdattecn.cmodint := dattecn.cmodint;
         mntdattecn.cintrev := dattecn.cintrev;
         v_numerr := pac_inttec.f_get_ncodintprod(psproduc, vcodint);
         mntdattecn.ncodint := vcodint;

         IF v_numerr = 0 THEN
            mntdattecn.tcodint :=
               pac_iax_listvalores.f_getdescripvalor
                  (' select ttexto
                                                                           from detintertec
                                                                           where ncodint = '
                   || vcodint || ' and CIDIOMA = ' || pac_md_common.f_get_cxtidioma,
                   mensajes);
         END IF;

         mntdattecn.interesprod := pac_md_mntprod.f_get_tipintprod(psproduc, mensajes);
         mntdattecn.tnniigar := pac_md_listvalores.f_getdescripvalores(287, dattecn.nniigar,
                                                                       mensajes);
         mntdattecn.tnniggar := pac_md_listvalores.f_getdescripvalores(287, dattecn.nniggar,
                                                                       mensajes);
         vtablas :=
            pac_iax_listvalores.f_getdescripvalor
                           ('select count(distinct(ctabla)) from garanpro where sproduc = '
                            || psproduc || ' and ctabla is not null',
                            mensajes);

         IF vtablas = 1 THEN
            mntdattecn.ctabla :=
               pac_iax_listvalores.f_getdescripvalor
                                           ('select ctabla from garanpro where sproduc = '
                                            || psproduc || ' and ctabla is not null',
                                            mensajes);

            IF mntdattecn.ctabla IS NOT NULL THEN
               mntdattecn.ttabla :=
                  pac_iax_listvalores.f_getdescripvalor
                     ('select ttabla from codmortalidad where fbaja is null and ctabla = '
                      || mntdattecn.ctabla,
                      mensajes);
            END IF;
         ELSE
            mntdattecn.ctabla := '';

            IF vtablas > 1 THEN
               mntdattecn.ttabla := f_axis_literales(1000015, pac_md_common.f_get_cxtidioma());
            ELSE
               mntdattecn.ttabla := '';
            END IF;
         END IF;
      --dattecn.ctabla; --DEFINIR     --buscar en todas las garantias del producto garanpro sino nulo
      --DEFINIR --codmortalidad... devuelve mas de 1. Poner ctabla a nulo y aqui poner que "ctabla está definido a nivel de garantia"
      END LOOP;

      RETURN mntdattecn;
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
   END f_get_dattecn;

   /*************************************************************************
      Recupera el objeto con la información del producto
      unit linked
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_unitulk(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_productosulk IS
      mntunitulk     ob_iax_productosulk := ob_iax_productosulk();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GET_UNITULK';

      CURSOR cur_prodsul IS
         SELECT p.*
           FROM productos_ulk p
          WHERE cramo || cmodali || ctipseg || ccolect IN(
                                                 SELECT cramo || cmodali || ctipseg || ccolect
                                                   FROM productos
                                                  WHERE sproduc = psproduc);
   BEGIN
      FOR prodsulk IN cur_prodsul LOOP
         mntunitulk.ndiaria := prodsulk.ndiaria;
         mntunitulk.cproval := prodsulk.cproval;
         mntunitulk.modelosinv := pac_md_mntprod.f_get_modelosinv(psproduc, mensajes);
      END LOOP;

      RETURN mntunitulk;
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
   END f_get_unitulk;

   /*************************************************************************
      Recupera el objeto con la información del producto
      datos rentas
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_datrent(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_productosren IS
      mntdatrent     ob_iax_productosren := ob_iax_productosren();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GET_DATRENT';
      vcmodextra     NUMBER;

      CURSOR cur_prodren IS
         SELECT p.ctipren, p.cclaren, p.nnumren, p.cpa1ren, p.npa1ren, p.cpctrev, p.npctrev,
                p.npctrevmin, p.npctrevmax, p.nrecren, p.cmunrec, p.cestmre, p.nmesextra,
                p.cmodextra
           FROM producto_ren p
          WHERE p.sproduc = psproduc;
   BEGIN
      FOR prodren IN cur_prodren LOOP
         mntdatrent.ctipren := prodren.ctipren;
         mntdatrent.ttipren := pac_md_listvalores.f_getdescripvalores(200, prodren.ctipren,
                                                                      mensajes);
         mntdatrent.cclaren := prodren.cclaren;
         mntdatrent.tclaren := pac_md_listvalores.f_getdescripvalores(201, prodren.cclaren,
                                                                      mensajes);
         mntdatrent.nnumren := prodren.nnumren;
         mntdatrent.cpa1ren := prodren.cpa1ren;
         mntdatrent.tpa1ren := pac_md_listvalores.f_getdescripvalores(210, prodren.cpa1ren,
                                                                      mensajes);
         mntdatrent.npa1ren := prodren.npa1ren;   --definir
         mntdatrent.cpctrev := prodren.cpctrev;
         mntdatrent.tpctrev := pac_md_listvalores.f_getdescripvalores(284, prodren.cpctrev,
                                                                      mensajes);
         mntdatrent.npctrev := prodren.npctrev;   --DEFINIR
         mntdatrent.npctrevmin := prodren.npctrevmin;
         mntdatrent.npctrevmax := prodren.npctrevmax;
         mntdatrent.nrecren := prodren.nrecren;
         mntdatrent.trecren := pac_md_listvalores.f_getdescripvalores(870, prodren.nrecren,
                                                                      mensajes);
         mntdatrent.cmunrec := prodren.cmunrec;
         mntdatrent.tmunrec := pac_md_listvalores.f_getdescripvalores(285, mntdatrent.cmunrec,
                                                                      mensajes);
         mntdatrent.cestmre := prodren.cestmre;
         mntdatrent.testmre := pac_md_listvalores.f_getdescripvalores(230, mntdatrent.cestmre,
                                                                      mensajes);
         mntdatrent.rentasformula := pac_md_mntprod.f_get_rentasformula(psproduc, mensajes);
         mntdatrent.forpagren := pac_md_mntprod.f_get_forpagren(psproduc, mensajes);
         mntdatrent.nmesextra := pac_md_obtenerdatos.f_leermesesextrapro(psproduc, vcmodextra,
                                                                         mensajes);
         mntdatrent.cmodextra := prodren.cmodextra;
         mntdatrent.tmodextra := pac_md_listvalores.f_getdescripvalores(828,
                                                                        mntdatrent.cmodextra,
                                                                        mensajes);
      END LOOP;

      RETURN mntdatrent;
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
   END f_get_datrent;

   /*************************************************************************
      Recupera las garantias del producto y actividad
      param in psproduc  : código del producto
      param in pcactivi  : código actividad
      param out mensajes : mensajes de error
      return             : objecto garantias
   *************************************************************************/
   FUNCTION f_get_garantias(psproduc IN NUMBER, pcactivi IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_prodgarantias IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc || ' pcactivi=' || pcactivi;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Get_Garantias';
      garan          t_iax_prodgarantias := t_iax_prodgarantias();

      CURSOR cgaran IS
         -- Bug 9685 - APD - 12/05/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
         SELECT   gp.*,
                  (SELECT tgarant
                     FROM garangen g
                    WHERE g.cgarant = gp.cgarant
                      AND g.cidioma = pac_md_common.f_get_cxtidioma) descripcion
             FROM garanpro gp
            WHERE gp.sproduc = psproduc
              AND gp.cactivi = pcactivi
         UNION
         SELECT   gp.*,
                  (SELECT tgarant
                     FROM garangen g
                    WHERE g.cgarant = gp.cgarant
                      AND g.cidioma = pac_md_common.f_get_cxtidioma) descripcion
             FROM garanpro gp
            WHERE gp.sproduc = psproduc
              AND gp.cactivi = 0
              AND NOT EXISTS(SELECT gp.*,
                                    (SELECT tgarant
                                       FROM garangen g
                                      WHERE g.cgarant = gp.cgarant
                                        AND g.cidioma = pac_md_common.f_get_cxtidioma)
                                                                                   descripcion
                               FROM garanpro gp
                              WHERE gp.sproduc = psproduc
                                AND gp.cactivi = pcactivi)
         ORDER BY 7;   --norden;
   -- Bug 9685 - APD - 12/05/2009 - fin
   BEGIN
      IF psproduc IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      FOR gar IN cgaran LOOP
         garan.EXTEND;
         garan(garan.LAST) := ob_iax_prodgarantias();
         garan(garan.LAST).cgarant := gar.cgarant;
         garan(garan.LAST).tgarant := gar.descripcion;
         garan(garan.LAST).norden := gar.norden;
         garan(garan.LAST).ctipgar := gar.ctipgar;
         garan(garan.LAST).ttipgar := pac_md_listvalores.f_getdescripvalores(33, gar.ctipgar,
                                                                             mensajes);
         garan(garan.LAST).ctipcap := gar.ctipcap;
         garan(garan.LAST).ttipcap := pac_md_listvalores.f_getdescripvalores(34, gar.ctipcap,
                                                                             mensajes);
         garan(garan.LAST).cgardep := gar.cgardep;

         IF gar.cgardep IS NOT NULL THEN
            garan(garan.LAST).tgardep :=
               pac_md_listvalores.f_getdescripvalor('select tgarant from garangen '
                                                    || 'where cgarant=' || gar.cgarant
                                                    || ' and cidioma='
                                                    || pac_md_common.f_get_cxtidioma,
                                                    mensajes);
         END IF;
      END LOOP;

      RETURN garan;
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
   END f_get_garantias;

   /*************************************************************************
      Recupera el objeto con la información del producto
      preguntas producto
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_pregunpro(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodpreguntas IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Get_PregunPro';
      mntpregunpro   t_iax_prodpreguntas := t_iax_prodpreguntas();
      nerror         NUMBER := 0;

      CURSOR cur_pregun IS
         SELECT   cpregun, cpretip, cpreobl, tprefor, tvalfor, cresdef, cofersn, npreimp,
                  npreord, cnivel, (SELECT ctippre
                                      FROM codipregun
                                     WHERE cpregun = p.cpregun) ctippre
             FROM pregunpro p
            WHERE sproduc = psproduc
         ORDER BY npreord;
-- Bug 18134 - RSC - 04/04/2011 - CRT - Modificacion de productos genericos (npreord)
   BEGIN
      --Comprovació dels paràmetres d'entrada
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      FOR pregun IN cur_pregun LOOP
         mntpregunpro.EXTEND;
         mntpregunpro(mntpregunpro.LAST) := ob_iax_prodpreguntas();
         mntpregunpro(mntpregunpro.LAST).cpregun := pregun.cpregun;
         nerror := f_despregunta(pregun.cpregun, pac_md_common.f_get_cxtidioma(),
                                 mntpregunpro(mntpregunpro.LAST).tpregun);

         IF nerror <> 0 THEN
            mntpregunpro(mntpregunpro.LAST).tpregun := '';
         END IF;

         mntpregunpro(mntpregunpro.LAST).cpretip := pregun.cpretip;
         mntpregunpro(mntpregunpro.LAST).tpretip :=
                         pac_iax_listvalores.f_getdescripvalores(787, pregun.cpretip, mensajes);
         mntpregunpro(mntpregunpro.LAST).cpreobl := pregun.cpreobl;
         mntpregunpro(mntpregunpro.LAST).tpreobl :=
                         pac_iax_listvalores.f_getdescripvalores(108, pregun.cpreobl, mensajes);
         mntpregunpro(mntpregunpro.LAST).tprefor := pregun.tprefor;
         mntpregunpro(mntpregunpro.LAST).tvalfor := pregun.tvalfor;
         mntpregunpro(mntpregunpro.LAST).cresdef := pregun.cresdef;

         IF pregun.cresdef IS NOT NULL
            AND pregun.ctippre IN(1, 2)   --BUG 25441-0138851 JLV 04/03/2013
            AND pregun.cpregun IS NOT NULL THEN
            mntpregunpro(mntpregunpro.LAST).tresdef :=
               pac_iax_listvalores.f_getdescripvalor
                                        ('select trespue from respuestas where crespue = '
                                         || pregun.cresdef || ' and cpregun = '
                                         || pregun.cpregun || ' and cidioma = '
                                         || pac_md_common.f_get_cxtidioma(),
                                         mensajes);
         END IF;

         mntpregunpro(mntpregunpro.LAST).cofersn := pregun.cofersn;
         mntpregunpro(mntpregunpro.LAST).npreimp := pregun.npreimp;
         mntpregunpro(mntpregunpro.LAST).npreord := pregun.npreord;

         -- FAL. BUG 5548: Asignar el camp NORDEN al objecte ob_iax_prodpreguntas

         -- Bug 15433 - 06/07/2010 - PFA - Anadir nuevo campo TNIVEL
         IF pregun.cnivel = 'R' THEN
            mntpregunpro(mntpregunpro.LAST).tnivel :=
                                    pac_iax_listvalores.f_getdescripvalores(1007, 2, mensajes);
         ELSIF pregun.cnivel = 'P' THEN
            mntpregunpro(mntpregunpro.LAST).tnivel :=
                                    pac_iax_listvalores.f_getdescripvalores(1007, 1, mensajes);
         -- BUG20498:DRA:09/01/2012:Inici
         ELSIF pregun.cnivel = 'C' THEN
            mntpregunpro(mntpregunpro.LAST).tnivel :=
                                    pac_iax_listvalores.f_getdescripvalores(1007, 4, mensajes);
         -- BUG20498:DRA:09/01/2012:Fi
         END IF;
      -- FI Bug 15433 - 06/07/2010 - PFA - Anadir nuevo campo TNIVEL
      END LOOP;

      RETURN mntpregunpro;
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
   END f_get_pregunpro;

   /*************************************************************************
      Recupera el objeto con los parametros del producto
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_parampro(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodparametros IS
      paramprod      t_iax_prodparametros := t_iax_prodparametros();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Get_ParamPro';

      CURSOR c IS
         SELECT pp.cparpro cparame, des.tparam tparame, cp.ctipo ctippar, pp.tvalpar tvalpar,
                pp.cvalpar nvalpar,
                DECODE(ctipo, 1, pp.tvalpar, 2, pp.cvalpar, 3, pp.fvalpar, NULL) dvalpar,

                -- Bug 8999 - RSC - 25/02/2011 - IAX014 - iAXIS - Mnt. Parametros
                pp.fvalpar fvalpar
           FROM parproductos pp, codparam cp, desparam des
          WHERE pp.sproduc = psproduc
            AND cp.cutili = 1
            AND pp.cparpro = cp.cparam
            AND pp.cparpro = des.cparam
            AND des.cidioma = pac_md_common.f_get_cxtidioma
            AND cp.ctipo < 4
            AND NVL(cp.cvisible, 1) = 1
         UNION
         SELECT pp.cparpro cparame, des.tparam tparame, cp.ctipo ctippar, pp.tvalpar tvalpar,
                pp.cvalpar nvalpar, det.tvalpar dvalpar, pp.fvalpar fvalpar
           FROM parproductos pp, codparam cp, desparam des, detparam det
          WHERE pp.sproduc = psproduc
            AND cp.cutili = 1
            AND pp.cparpro = cp.cparam
            AND pp.cparpro = des.cparam
            AND des.cidioma = pac_md_common.f_get_cxtidioma
            AND pp.cparpro = det.cparam
            AND det.cidioma = pac_md_common.f_get_cxtidioma
            AND det.cvalpar = pp.cvalpar
            AND cp.ctipo = 4
            AND NVL(cp.cvisible, 1) = 1;
   BEGIN
      --Comprovació dels paràmetres d'entrada
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      FOR r IN c LOOP
         paramprod.EXTEND;
         paramprod(paramprod.LAST) := ob_iax_prodparametros();
         paramprod(paramprod.LAST).cparame := r.cparame;
         paramprod(paramprod.LAST).tparame := r.tparame;
         paramprod(paramprod.LAST).ctippar := r.ctippar;
         paramprod(paramprod.LAST).tvalpar := r.tvalpar;
         paramprod(paramprod.LAST).nvalpar := r.nvalpar;
         paramprod(paramprod.LAST).dvalpar := r.dvalpar;
         paramprod(paramprod.LAST).fvalpar := r.fvalpar;
      END LOOP;

      RETURN paramprod;
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
   END f_get_parampro;

   /*************************************************************************
      Recupera el objeto con los beneficiarios del producto
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_benefpro(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodbeneficiarios IS
      mntbenefpro    t_iax_prodbeneficiarios := t_iax_prodbeneficiarios();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Get_BenefPro';

      CURSOR cben IS
         SELECT   bp.norden, bb.sclaben, bb.tclaben, 1 cobliga,
                  (SELECT COUNT(1)
                     FROM productos
                    WHERE sproduc = bp.sproduc
                      AND sclaben = bp.sclaben) cdefecto
             FROM claubenpro bp, clausuben bb
            WHERE bb.sclaben = bp.sclaben
              AND bp.sproduc = psproduc
              AND bb.cidioma = pac_md_common.f_get_cxtidioma
         ORDER BY bp.norden;
   BEGIN
      --Comprovació dels paràmetres d'entrada
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      FOR cb IN cben LOOP
         mntbenefpro.EXTEND;
         mntbenefpro(mntbenefpro.LAST) := ob_iax_prodbeneficiarios();
         mntbenefpro(mntbenefpro.LAST).norden := cb.norden;
         mntbenefpro(mntbenefpro.LAST).sclaben := cb.sclaben;
         mntbenefpro(mntbenefpro.LAST).tclaben := cb.tclaben;
         mntbenefpro(mntbenefpro.LAST).cobliga := cb.cobliga;
         mntbenefpro(mntbenefpro.LAST).cdefecto := cb.cdefecto;
      END LOOP;

      RETURN mntbenefpro;
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
   END f_get_benefpro;

   /*************************************************************************
      Recupera el objeto con la información del producto
      actividades
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_activid(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodactividades IS
      mntactivid     t_iax_prodactividades := t_iax_prodactividades();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GET_ACTIVID';

      CURSOR cur_actpr IS
         SELECT activisegu.tactivi, activisegu.cactivi
           FROM productos p, activiprod INNER JOIN activisegu
                ON activiprod.cactivi = activisegu.cactivi
              AND activiprod.cramo = activisegu.cramo
          WHERE activiprod.ccolect = p.ccolect
            AND activisegu.cidioma = pac_md_common.f_get_cxtidioma
            AND activiprod.cmodali = p.cmodali
            AND activiprod.cramo = p.cramo
            AND activiprod.ctipseg = p.ctipseg
            AND p.sproduc = psproduc;
   BEGIN
      FOR actpr IN cur_actpr LOOP
         mntactivid.EXTEND;
         mntactivid(mntactivid.LAST) := ob_iax_prodactividades();
         mntactivid(mntactivid.LAST).cactivi := actpr.cactivi;
         mntactivid(mntactivid.LAST).tactivi := actpr.tactivi;
         mntactivid(mntactivid.LAST).paractividad :=
                          pac_md_mntprod.f_get_paractividad(psproduc, actpr.cactivi, mensajes);
         mntactivid(mntactivid.LAST).pregunacti :=
                            pac_md_mntprod.f_get_pregunacti(psproduc, actpr.cactivi, mensajes);
         mntactivid(mntactivid.LAST).recfraccacti :=
                          pac_md_mntprod.f_get_recfraccacti(psproduc, actpr.cactivi, mensajes);
      END LOOP;

      RETURN mntactivid;
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
   END f_get_activid;

   /************************************************************************
      Recupera información del producto actividades -->>
   *************************************************************************/

   /*************************************************************************
      Recupera el objeto con la información del producto
      parámetros actividades
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_paractividad(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodparactividad IS
      mntparactividad t_iax_prodparactividad
                                     := NEW /*BUG8510-07/01/2008-XCG*/ t_iax_prodparactividad
                                                                                            ();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GET_PARACTIVIDAD';

      CURSOR cur_parac IS
         SELECT cparame, ctippar, tvalpar, nvalpar, fvalpar
           FROM paractividad
          WHERE sproduc = psproduc
            AND cactivi = pcactivi;
   BEGIN
      IF psproduc IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      FOR parac IN cur_parac LOOP
         mntparactividad.EXTEND;
         mntparactividad(mntparactividad.LAST) := ob_iax_prodparactividad();
         mntparactividad(mntparactividad.LAST).cparame := parac.cparame;

         --DEFINIR
         IF parac.cparame IS NOT NULL THEN
            mntparactividad(mntparactividad.LAST).tparame :=
               pac_iax_listvalores.f_getdescripvalor
                                   ('select tparame from desparactividad where cparame = '
                                    || parac.cparame || ' and cidioma = '
                                    || pac_md_common.f_get_cxtidioma(),
                                    mensajes);   --DEFINIR
         END IF;

         mntparactividad(mntparactividad.LAST).ctippar := parac.ctippar;
         mntparactividad(mntparactividad.LAST).tvalpar := parac.tvalpar;
         mntparactividad(mntparactividad.LAST).nvalpar := parac.nvalpar;
         mntparactividad(mntparactividad.LAST).fvalpar := parac.fvalpar;
      END LOOP;

      RETURN mntparactividad;
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
   END f_get_paractividad;

   /*************************************************************************
      Recupera el objeto con la información del producto
      preguntas actividades
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_pregunacti(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodpregunacti IS
      mntpregunacti  t_iax_prodpregunacti := t_iax_prodpregunacti();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GET_PREGUNACTI';
      nerror         NUMBER := 0;

      CURSOR cur_pregun IS
         SELECT cpregun, cpretip, cpreobl, tprefor, tvalfor, cresdef, cofersn, npreimp,
                npreord
           FROM pregunproactivi
          WHERE sproduc = psproduc
            AND cactivi = pcactivi;
   BEGIN
      IF psproduc IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      FOR pregun IN cur_pregun LOOP
         mntpregunacti.EXTEND;
         mntpregunacti(mntpregunacti.LAST) := ob_iax_prodpregunacti();
         mntpregunacti(mntpregunacti.LAST).cpregun := pregun.cpregun;
         nerror := f_despregunta(pregun.cpregun, pac_md_common.f_get_cxtidioma(),
                                 mntpregunacti(mntpregunacti.LAST).tpregun);

         IF nerror <> 0 THEN
            mntpregunacti(mntpregunacti.LAST).tpregun := '';
         END IF;

         mntpregunacti(mntpregunacti.LAST).cpretip := pregun.cpretip;
         mntpregunacti(mntpregunacti.LAST).tpretip :=
                         pac_iax_listvalores.f_getdescripvalores(787, pregun.cpretip, mensajes);
         mntpregunacti(mntpregunacti.LAST).cpreobl := pregun.cpreobl;
         mntpregunacti(mntpregunacti.LAST).tprefor := pregun.tprefor;
         mntpregunacti(mntpregunacti.LAST).tvalfor := pregun.tvalfor;
         mntpregunacti(mntpregunacti.LAST).cresdef := pregun.cresdef;

         IF pregun.cresdef IS NOT NULL
            AND pregun.cpregun IS NOT NULL THEN
            mntpregunacti(mntpregunacti.LAST).tresdef :=
               pac_iax_listvalores.f_getdescripvalor
                                        ('select trespue from respuestas where crespue = '
                                         || pregun.cresdef || ' and cpregun = '
                                         || pregun.cpregun || ' and cidioma = '
                                         || pac_md_common.f_get_cxtidioma(),
                                         mensajes);
         END IF;

         mntpregunacti(mntpregunacti.LAST).cofersn := pregun.cofersn;
         mntpregunacti(mntpregunacti.LAST).npreimp := pregun.npreimp;
         mntpregunacti(mntpregunacti.LAST).npreord := pregun.npreord;
      -- FAL. BUG 5548: Asignar el camp NORDEN al objecte ob_iax_prodpregunacti
      END LOOP;

      RETURN mntpregunacti;
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
   END f_get_pregunacti;

   /*************************************************************************
      Recupera el objeto con la información del producto
      recargo fraccionamiento actividades
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_recfraccacti(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodrecfraccacti IS
      mntrecfraccacti t_iax_prodrecfraccacti := t_iax_prodrecfraccacti();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GET_RECFRACCACTI';

      CURSOR cur_recfra IS
         SELECT *
           FROM forpagrecacti
          WHERE cactivi = pcactivi
            AND cramo || cmodali || ctipseg || ccolect IN(
                                                  SELECT cramo || cmodali || ctipseg || ccolect
                                                    FROM productos
                                                   WHERE sproduc = psproduc);
   BEGIN
      IF psproduc IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      FOR recfra IN cur_recfra LOOP
         mntrecfraccacti.EXTEND;
         mntrecfraccacti(mntrecfraccacti.LAST) := ob_iax_prodrecfraccacti();
         mntrecfraccacti(mntrecfraccacti.LAST).cforpag := recfra.cforpag;
         mntrecfraccacti(mntrecfraccacti.LAST).tforpag :=
                         pac_iax_listvalores.f_getdescripvalores(17, recfra.cforpag, mensajes);
         mntrecfraccacti(mntrecfraccacti.LAST).precarg := recfra.precarg;
      END LOOP;

      RETURN mntrecfraccacti;
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
   END f_get_recfraccacti;

   /************************************************************************
      <<-- Recupera información del producto actividades
   *************************************************************************/

   /************************************************************************
      Recupera información de la garantia  -->>
   *************************************************************************/

   /*************************************************************************
         Recupera el objeto con la información de la forma de pago de la garantia
         recargo fraccionamiento actividades
         param in psproduc  : código producto
         param in pcactivi  : código de la actividad
         param in pcgarant  : código de la garantia
         param out mensajes : mensajes de error
      *************************************************************************/
   FUNCTION f_get_prodforpagrecgaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodforpagrecgaran IS
      mntprodforpagrecgaran t_iax_prodforpagrecgaran := t_iax_prodforpagrecgaran();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GET_PRODFORPAGRECGARAN';

      CURSOR cur_forpagrecgaran IS
         SELECT *
           FROM forpagrecgaran
          WHERE cramo || cmodali || ctipseg || ccolect IN(
                                                 SELECT cramo || cmodali || ctipseg || ccolect
                                                   FROM productos
                                                  WHERE sproduc = psproduc)
            AND cgarant = pcgarant
            AND cactivi = pcactivi;
   BEGIN
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      FOR recgaran IN cur_forpagrecgaran LOOP
         mntprodforpagrecgaran.EXTEND;
         mntprodforpagrecgaran(mntprodforpagrecgaran.LAST) := ob_iax_prodforpagrecgaran();
         mntprodforpagrecgaran(mntprodforpagrecgaran.LAST).cforpag := recgaran.cforpag;
         mntprodforpagrecgaran(mntprodforpagrecgaran.LAST).tforpag :=
                       pac_iax_listvalores.f_getdescripvalores(17, recgaran.cforpag, mensajes);
         mntprodforpagrecgaran(mntprodforpagrecgaran.LAST).precarg := recgaran.precarg;
      END LOOP;

      RETURN mntprodforpagrecgaran;
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
   END f_get_prodforpagrecgaran;

   /*************************************************************************
      Recupera el cursor con la información de la tabla CAPITALMIN
      param in psproduc  : código producto
      param in pcactivi  : código actividad
      param in pcgarant  : código garantia
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_capitalmin(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_MNTPROD.F_Get_Capitalmin';
      vparam         VARCHAR2(500)
         := 'parámetros , sproduc :' || psproduc || ' , cactivi' || pcactivi
            || ' , pcgarant =' || pcgarant;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
   BEGIN
      -- Verificación de los parámetros
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      squery := 'select  cforpag,  icapmin from capitalmin where sproduc = ' || psproduc
                || ' and cactivi = ' || pcactivi || ' and cgarant =' || pcgarant;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_capitalmin;

   /*************************************************************************
      Recupera el cursor con la información de la tabla Garanprocap
      param in psproduc  : código producto
      param in pcactivi  : código actividad
      param in pcgarant  : código garantia
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_garanprocap(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_MNTPROD.F_Get_Garanprocap';
      vparam         VARCHAR2(500)
         := 'parámetros , sproduc :' || psproduc || ' , cactivi' || pcactivi || ' , cgarant ='
            || pcgarant;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcramo         productos.cramo%TYPE;
      vcmodali       productos.cmodali%TYPE;
      vctipseg       productos.ctipseg%TYPE;
      vccolect       productos.ccolect%TYPE;
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
      v_count        NUMBER;
   BEGIN
      -- Verificación de los parámetros
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      --Inicialitzacions
      SELECT cramo, cmodali, ctipseg, ccolect
        INTO vcramo, vcmodali, vctipseg, vccolect
        FROM productos
       WHERE sproduc = psproduc;

      vpasexec := 3;
      squery := 'SELECT norden, icapital, cdefecto FROM garanprocap WHERE cramo = ' || vcramo
                || ' AND cmodali = ' || vcmodali || ' AND ctipseg =' || vctipseg
                || ' AND ccolect =' || vccolect || ' AND cactivi =' || pcactivi
                || ' AND cgarant =' || pcgarant || ' UNION ALL '
                || 'SELECT norden, icapital, cdefecto FROM garanprocap WHERE cramo = '
                || vcramo || ' AND cmodali = ' || vcmodali || ' AND ctipseg =' || vctipseg
                || ' AND ccolect =' || vccolect || ' AND cactivi = 0' || ' AND cgarant ='
                || pcgarant || ' AND NOT EXISTS (SELECT 1 FROM garanprocap WHERE cramo = '
                || vcramo || ' AND cmodali = ' || vcmodali || ' AND ctipseg =' || vctipseg
                || ' AND ccolect =' || vccolect || ' AND cactivi =' || pcactivi
                || ' AND cgarant =' || pcgarant || ')';
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_garanprocap;

   /*************************************************************************
      Recupera la tabla de objeto OB_IAX_PRODGARANTIAS para un subproducto y actividad.
      param in psproduc  : código producto
      param in pcactivi  : código actividad
      param out mensajes : mensajes de error
      return Tabla de OB_IAX_PRODGARANTIAS
   *************************************************************************/
   FUNCTION f_get_datosgeneralesgaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_prodgarantias IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_MNTPROD.F_Get_DatosGeneralesGaran';
      vparam         VARCHAR2(500)
                           := 'parámetros , sproduc :' || psproduc || ' , cactivi' || pcactivi;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcidioma       NUMBER(1);
      vcramo         productos.cramo%TYPE;
      vcur_gar       sys_refcursor;
      vcur_cap       sys_refcursor;
      oprod          ob_iax_prodgarantias := ob_iax_prodgarantias();
   BEGIN
      -- Verificación de los parámetros
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      vcidioma := pac_md_common.f_get_cxtidioma;

      BEGIN
         SELECT cramo
           INTO vcramo
           FROM productos
          WHERE sproduc = psproduc;
      EXCEPTION
         WHEN OTHERS THEN
            RAISE e_param_error;
      END;

      -- Bug 9685 - APD - 12/05/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      BEGIN
         SELECT pcactivi, pcgarant, norden, ctarjet, ctipgar,
                cgardep, cpardep, cvalpar, cbasica, ctipcap,
                icapmax, ccapmax, cclacap, cformul, pcapdep,
                icapmin, icaprev, iprimax, iprimin, cclamin,
                ccapmin, cmoncap
           INTO oprod.cactivi, oprod.cgarant, oprod.norden, oprod.ctarjet, oprod.ctipgar,
                oprod.cgardep, oprod.cpardep, oprod.cvalpar, oprod.cbasica, oprod.ctipcap,
                oprod.icapmax, oprod.ccapmax, oprod.cclacap, oprod.cformul, oprod.pcapdep,
                oprod.icapmin, oprod.icaprev, oprod.iprimax, oprod.iprimin, oprod.cclamin,
                oprod.ccapmin, oprod.cmoncap
           FROM garanpro
          WHERE sproduc = psproduc
            AND cactivi = pcactivi
            AND cgarant = pcgarant;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT pcactivi, pcgarant, norden, ctarjet, ctipgar,
                   cgardep, cpardep, cvalpar, cbasica, ctipcap,
                   icapmax, ccapmax, cclacap, cformul, pcapdep,
                   icapmin, icaprev, iprimax, iprimin, cclamin,
                   ccapmin, cmoncap
              INTO oprod.cactivi, oprod.cgarant, oprod.norden, oprod.ctarjet, oprod.ctipgar,
                   oprod.cgardep, oprod.cpardep, oprod.cvalpar, oprod.cbasica, oprod.ctipcap,
                   oprod.icapmax, oprod.ccapmax, oprod.cclacap, oprod.cformul, oprod.pcapdep,
                   oprod.icapmin, oprod.icaprev, oprod.iprimax, oprod.iprimin, oprod.cclamin,
                   oprod.ccapmin, oprod.cmoncap
              FROM garanpro
             WHERE sproduc = psproduc
               AND cactivi = 0
               AND cgarant = pcgarant;
      END;

      -- Bug 9685 - APD - 12/05/2009 - fin
      oprod.ttipgar := pac_iax_listvalores.f_getdescripvalores(33, oprod.ctipgar, mensajes);
      oprod.ttipcap := pac_iax_listvalores.f_getdescripvalores(34, oprod.ctipcap, mensajes);

      IF oprod.ccapmax IS NOT NULL THEN
         oprod.tcapmax := pac_iax_listvalores.f_getdescripvalores(35, oprod.ccapmax, mensajes);
      ELSE
         oprod.tcapmax := NULL;
      END IF;

      IF oprod.ccapmin IS NOT NULL THEN
         oprod.tcapmin := pac_iax_listvalores.f_getdescripvalores(35, oprod.ccapmin, mensajes);
      -- Bug 26501 - MMS - 28/03/2013
      ELSE
         oprod.tcapmin := NULL;
      END IF;

      BEGIN
         SELECT tactivi
           INTO oprod.tactivi
           FROM activisegu
          WHERE cidioma = vcidioma
            AND cramo = vcramo
            AND cactivi = pcactivi;
      EXCEPTION
         WHEN OTHERS THEN
            oprod.tactivi := NULL;
      END;

      BEGIN
         SELECT tparam
           INTO oprod.tpardep
           FROM desparam
          WHERE cidioma = vcidioma
            AND cparam = oprod.cpardep;
      EXCEPTION
         WHEN OTHERS THEN
            oprod.tpardep := NULL;
      END;

      BEGIN
         SELECT tgarant
           INTO oprod.tgarant
           FROM garangen
          WHERE cidioma = vcidioma
            AND cgarant = oprod.cgarant;
      EXCEPTION
         WHEN OTHERS THEN
            oprod.tgarant := NULL;
      END;

      BEGIN
         SELECT tgarant
           INTO oprod.tgardep
           FROM garangen
          WHERE cidioma = vcidioma
            AND cgarant = oprod.cgardep;
      EXCEPTION
         WHEN OTHERS THEN
            oprod.tgardep := NULL;
      END;

      BEGIN
         SELECT descripcion
           INTO oprod.tclacap
           FROM sgt_formulas
          WHERE clave = oprod.cclacap;
      EXCEPTION
         WHEN OTHERS THEN
            oprod.tclacap := NULL;
      END;

      BEGIN
         SELECT descripcion
           INTO oprod.tformul
           FROM sgt_formulas
          WHERE clave = oprod.cformul;
      EXCEPTION
         WHEN OTHERS THEN
            oprod.tformul := NULL;
      END;

      vcur_gar := pac_md_mntprod.f_get_garanprocap(psproduc, pcactivi, pcgarant, mensajes);

      LOOP
         oprod.garanprocap := t_iax_prodgaranprocap();
         oprod.garanprocap.EXTEND;
         oprod.garanprocap(oprod.garanprocap.COUNT) := ob_iax_prodgaranprocap();

         FETCH vcur_gar
          INTO oprod.garanprocap(oprod.garanprocap.COUNT).norden,
               oprod.garanprocap(oprod.garanprocap.COUNT).icapital,
               oprod.garanprocap(oprod.garanprocap.COUNT).cdefecto;

         EXIT WHEN vcur_gar%NOTFOUND;
      END LOOP;

      vcur_cap := pac_md_mntprod.f_get_capitalmin(psproduc, pcactivi, pcgarant, mensajes);

      LOOP
         oprod.capitalmin := t_iax_prodcapitalmin();
         oprod.capitalmin.EXTEND;
         oprod.capitalmin(oprod.capitalmin.COUNT) := ob_iax_prodcapitalmin();

         FETCH vcur_cap
          INTO oprod.capitalmin(oprod.capitalmin.COUNT).cforpag,
               oprod.capitalmin(oprod.capitalmin.COUNT).icapmin;

         oprod.capitalmin(oprod.capitalmin.COUNT).tforpag :=
            pac_iax_listvalores.f_getdescripvalores
                                            (17,
                                             oprod.capitalmin(oprod.capitalmin.COUNT).cforpag,
                                             mensajes);
         EXIT WHEN vcur_cap%NOTFOUND;
      END LOOP;

      -- Bug 14284 - 18/05/2010 - AMC
      BEGIN
         SELECT tvalpar
           INTO oprod.tvalpar
           FROM detpargar
          WHERE cpargar = oprod.cpardep
            AND cidioma = vcidioma
            AND cvalpar = oprod.cvalpar;
      EXCEPTION
         WHEN OTHERS THEN
            oprod.tvalpar := NULL;
      END;

      -- Fi Bug 14284 - 18/05/2010 - AMC
      RETURN oprod;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_datosgeneralesgaran;

   /*************************************************************************
      Recupera el objeto con la información de la garantia
      datos de gestión
      param in psproduc  : código producto
      param in pcactivi  : código de la actividad
      param in pcgarant  : código de la garantia
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_gestiongaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_prodgardatgestion IS
      mntgestion     ob_iax_prodgardatgestion := ob_iax_prodgardatgestion();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Get_GestionGaran';

      CURSOR cur_ges IS
         -- Bug 9685 - APD - 12/05/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
         SELECT g.*
           FROM garanpro g
          WHERE g.sproduc = psproduc
            AND g.cgarant = pcgarant
            AND g.cactivi = pcactivi
         UNION
         SELECT g.*
           FROM garanpro g
          WHERE g.sproduc = psproduc
            AND g.cgarant = pcgarant
            AND g.cactivi = 0
            AND NOT EXISTS(SELECT g.*
                             FROM garanpro g
                            WHERE g.sproduc = psproduc
                              AND g.cgarant = pcgarant
                              AND g.cactivi = pcactivi);
   -- Bug 9685 - APD - 12/05/2009 - fin
   BEGIN
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      FOR ges IN cur_ges LOOP
         mntgestion.nedamic := ges.nedamic;
         mntgestion.ciedmic := NVL(ges.ciedmic, 0);
         mntgestion.nedamac := ges.nedamac;
         mntgestion.ciedmac := NVL(ges.ciedmac, 0);
         mntgestion.nedamar := ges.nedamar;
         mntgestion.ciedmar := NVL(ges.ciedmar, 0);
         mntgestion.nedmi2c := ges.nedmi2c;
         mntgestion.ciemi2c := NVL(ges.ciemi2c, 0);
         mntgestion.nedma2c := ges.nedma2c;
         mntgestion.ciema2c := NVL(ges.ciema2c, 0);
         mntgestion.nedma2r := ges.nedma2r;
         mntgestion.ciema2r := NVL(ges.ciema2r, 0);
         mntgestion.ctiptar := ges.ctiptar;
         mntgestion.ttiptar := pac_iax_listvalores.f_getdescripvalores(48, ges.ctiptar,
                                                                       mensajes);
         --mntgestion.ctarifa := ges.ctarifa;
         --mntgestion.ttarifa := ges.ttarifa;
         mntgestion.creaseg := ges.creaseg;
         mntgestion.treaseg := pac_iax_listvalores.f_getdescripvalores(134, ges.creaseg,
                                                                       mensajes);
         mntgestion.crevali := ges.crevali;
         mntgestion.trevali := pac_iax_listvalores.f_getdescripvalores(279, ges.crevali,
                                                                       mensajes);
         mntgestion.prevali := ges.prevali;
         mntgestion.irevali := ges.irevali;
         mntgestion.cmodrev := NVL(ges.cmodrev, 0);
         mntgestion.crecarg := NVL(ges.crecarg, 0);
         mntgestion.cdtocom := NVL(ges.cdtocom, 0);
         mntgestion.cextrap := NVL(ges.cextrap, 0);
         mntgestion.ctarman := ges.ctarman;
         mntgestion.ttarman := pac_iax_listvalores.f_getdescripvalores(56, ges.ctarman,
                                                                       mensajes);
         mntgestion.cderreg := NVL(ges.cderreg, 0);
         mntgestion.ctecnic := NVL(ges.ctecnic, 0);
         mntgestion.cofersn := NVL(ges.cofersn, 0);
         mntgestion.crecfra := NVL(ges.crecfra, 0);
         mntgestion.forpagrecgaran := f_get_prodforpagrecgaran(psproduc, pcactivi, pcgarant,
                                                               mensajes);
         --AGG se añade los campos de Edad Máxima de Revalorización
         mntgestion.nedamrv := ges.nedamrv;
         mntgestion.ciedmrv := NVL(ges.ciedmrv, 0);
      END LOOP;

      RETURN mntgestion;
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
   END f_get_gestiongaran;

   /*************************************************************************
       Recupera el objeto con la información de los impuestos de una garantia
       param in psproduc  : código producto
       param in pcactivi  : código actividad
       param in pgarant  : código garantía
       param out mensajes : mensajes de error
    *************************************************************************/
   FUNCTION f_get_impuestosgaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_prodgarimpuestos IS
      mntimpuestos   ob_iax_prodgarimpuestos := ob_iax_prodgarimpuestos();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Get_ImpuestosGaran';
      numerr         NUMBER;

      CURSOR cur_imp IS
         -- Bug 9685 - APD - 12/05/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
         SELECT p.cimpcon, p.cimpdgs, p.cimpips, p.cimparb, p.cimpfng
           FROM garanpro p
          WHERE p.sproduc = psproduc
            AND p.cactivi = pcactivi
            AND p.cgarant = pcgarant
         UNION
         SELECT p.cimpcon, p.cimpdgs, p.cimpips, p.cimparb, p.cimpfng
           FROM garanpro p
          WHERE p.sproduc = psproduc
            AND p.cactivi = 0
            AND p.cgarant = pcgarant
            AND NOT EXISTS(SELECT p.cimpcon, p.cimpdgs, p.cimpips, p.cimparb, p.cimpfng
                             FROM garanpro p
                            WHERE p.sproduc = psproduc
                              AND p.cactivi = pcactivi
                              AND p.cgarant = pcgarant);
   -- Bug 9685 - APD - 12/05/2009 - fin
   BEGIN
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      FOR reg IN cur_imp LOOP
         mntimpuestos.cimpcon := reg.cimpcon;
         mntimpuestos.cimpdgs := reg.cimpdgs;
         mntimpuestos.cimpips := reg.cimpips;
         mntimpuestos.cimparb := reg.cimparb;
         mntimpuestos.cimpfng := reg.cimpfng;
      END LOOP;

      RETURN mntimpuestos;
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
   END f_get_impuestosgaran;

   /*************************************************************************
      Recupera el objeto con la información de los DATOS TECNICOS de la garantia
      param in psproduc  : código producto
      param in pcactivi  : código actividad
      param in pcgarant  : código garantía
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_datostecngaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_prodgardattecnicos IS
      dattecgar      ob_iax_prodgardattecnicos := ob_iax_prodgardattecnicos();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
          := 'psproduc=' || psproduc || ', pcactivi=' || pcactivi || ', pcgarant=' || pcgarant;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Get_DatosTecnGaran';

      CURSOR c IS
         -- Bug 9685 - APD - 12/05/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
         -- Bug 32620 - 25/09/2014 - JTT: Recuperamos el tipo de provision (garanpro.cprovis)
         SELECT gp.cramdgs,
                (SELECT des.tramdgs
                   FROM desramodgs des
                  WHERE des.cramdgs = gp.cramdgs
                    AND des.cidioma = pac_md_common.f_get_cxtidioma) tramdgs,
                nparben, precseg, cd.ctabla, cd.ttabla, gp.cprovis,
                ff_desvalorfijo(1150, pac_md_common.f_get_cxtidioma, gp.cprovis)
           FROM garanpro gp, codmortalidad cd
          WHERE gp.sproduc = psproduc
            AND gp.cactivi = pcactivi
            AND gp.cgarant = pcgarant
            AND gp.ctabla = cd.ctabla(+)
         UNION
         SELECT gp.cramdgs,
                (SELECT des.tramdgs
                   FROM desramodgs des
                  WHERE des.cramdgs = gp.cramdgs
                    AND des.cidioma = pac_md_common.f_get_cxtidioma) tramdgs,
                nparben, precseg, cd.ctabla, cd.ttabla, gp.cprovis,
                ff_desvalorfijo(1150, pac_md_common.f_get_cxtidioma, gp.cprovis)
           FROM garanpro gp, codmortalidad cd
          WHERE gp.sproduc = psproduc
            AND gp.cactivi = 0
            AND gp.cgarant = pcgarant
            AND gp.ctabla = cd.ctabla(+)
            AND NOT EXISTS(SELECT gp.cramdgs,
                                  (SELECT des.tramdgs
                                     FROM desramodgs des
                                    WHERE des.cramdgs = gp.cramdgs
                                      AND des.cidioma = pac_md_common.f_get_cxtidioma) tramdgs,
                                  nparben, precseg, cd.ctabla, cd.ttabla
                             FROM garanpro gp, codmortalidad cd
                            WHERE gp.sproduc = psproduc
                              AND gp.cactivi = pcactivi
                              AND gp.cgarant = pcgarant
                              AND gp.ctabla = cd.ctabla(+));
   -- Bug 9685 - APD - 12/05/2009 - fin
   BEGIN
      --Comprovació dels paràmetres d'entrada
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      OPEN c;

      FETCH c
       INTO dattecgar.cramdgs, dattecgar.tramdgs, dattecgar.nparben, dattecgar.precseg,
            dattecgar.ctabla, dattecgar.ttabla, dattecgar.cprovis, dattecgar.tprovis;

      CLOSE c;

      RETURN dattecgar;
   EXCEPTION
      WHEN e_param_error THEN
         -- BUG -21546_108724- 04/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF c%ISOPEN THEN
            CLOSE c;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         -- BUG -21546_108724- 04/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF c%ISOPEN THEN
            CLOSE c;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         -- BUG -21546_108724- 04/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF c%ISOPEN THEN
            CLOSE c;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_datostecngaran;

   /*************************************************************************
       Recupera el objeto con la información de las incompatibilidades de una garantia
       param in psproduc  : código producto
       param in pcactivi  : código actividad
       param in pgarant  : código garantía
       param out mensajes : mensajes de error
    *************************************************************************/
   FUNCTION f_get_incompatigaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodincompgaran IS
      mntprodgarincomp t_iax_prodincompgaran := t_iax_prodincompgaran();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Get_IncompatiGaran';
      numerr         NUMBER;
      vcactivi       NUMBER;
      vcount         NUMBER;

      CURSOR cur_imp(ppcactivi IN NUMBER) IS
         SELECT i.cgarinc
           FROM incompgaran i, productos p
          WHERE p.cramo = i.cramo
            AND p.cmodali = i.cmodali
            AND p.ctipseg = i.ctipseg
            AND p.ccolect = i.ccolect
            AND i.cactivi = ppcactivi
            AND i.cgarant = pcgarant
            AND p.sproduc = psproduc;   -- Bug 15023 - 16/06/2010 - AMC
   BEGIN
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      --BUG9685 - 12/05/2009 - APD - IAX -ACTIVIDAD - Selects contra INCOMPAGARAN, tener en cuenta la actividad
      SELECT COUNT(1)
        INTO vcount
        FROM incompgaran i, productos p
       WHERE p.cramo = i.cramo
         AND p.cmodali = i.cmodali
         AND p.ctipseg = i.ctipseg
         AND p.ccolect = i.ccolect
         AND i.cactivi = pcactivi
         AND i.cgarant = pcgarant
         AND p.sproduc = psproduc;   -- Bug 15023 - 16/06/2010 - AMC

      IF vcount > 0 THEN
         vcactivi := pcactivi;
      ELSE
         vcactivi := 0;
      END IF;

      --BUG9685 - 12/05/2009 - APD - fin
      FOR reg IN cur_imp(vcactivi) LOOP
         mntprodgarincomp.EXTEND;
         mntprodgarincomp(mntprodgarincomp.LAST) := ob_iax_prodincompgaran();
         mntprodgarincomp(mntprodgarincomp.LAST).cgarinc := reg.cgarinc;

         IF reg.cgarinc IS NOT NULL THEN
            mntprodgarincomp(mntprodgarincomp.LAST).tgarinc :=
               pac_iax_listvalores.f_getdescripvalor
                                         (' select tgarant from garangen where cgarant = '
                                          || reg.cgarinc || ' and cidioma = '
                                          || pac_md_common.f_get_cxtidioma(),
                                          mensajes);
         END IF;
      END LOOP;

      RETURN mntprodgarincomp;
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
   END f_get_incompatigaran;

   /*************************************************************************
      Recupera los cumulos de la garantia del producto
      param in psproduc  : código del producto
      param in pcactivi  : código actividad
      param in pcgarant  : código garantia
      param out mensajes : mensajes de error
      return             : objecto beneficiarios
   *************************************************************************/
   FUNCTION f_get_cumulosgaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodcumgaran IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Get_CumulosGaran';
      cum            t_iax_prodcumgaran := t_iax_prodcumgaran();

      CURSOR curcum IS
         SELECT cgar.ccumulo, tcumulo, ffecini, ffecfin, ilimite, cformul, clave, cvalor
           FROM cum_cumgaran cgar, cum_codcumulo cdsc, cum_detcumulo cdet, productos p
          WHERE cgar.cactivi = pcactivi
            AND cgar.cgarant = pcgarant
            AND p.sproduc = psproduc
            AND cgar.ccolect = p.ccolect
            AND cgar.cmodali = p.cmodali
            AND cgar.cramo = p.cramo
            AND cgar.ctipseg = p.ctipseg
            AND cdet.ccumulo = cgar.ccumulo
            AND cdsc.cidioma = pac_md_common.f_get_cxtidioma;
   BEGIN
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      FOR ccum IN curcum LOOP
         cum.EXTEND;
         cum(cum.LAST) := ob_iax_prodcumgaran();
         cum(cum.LAST).ccumulo := ccum.ccumulo;
         cum(cum.LAST).tcumulo := ccum.tcumulo;
         cum(cum.LAST).ffecini := ccum.ffecini;
         cum(cum.LAST).fecfin := ccum.ffecfin;
         cum(cum.LAST).ilimite := ccum.ilimite;
         cum(cum.LAST).cformul := ccum.cformul;
         cum(cum.LAST).tformul :=
            pac_md_listvalores.f_getdescripvalor('SELECT DESCRIPCION FROM '
                                                 || ' SGT_FORMULAS WHERE CLAVE='
                                                 || ccum.cformul,
                                                 mensajes);
         cum(cum.LAST).clave := ccum.clave;
         cum(cum.LAST).tclave :=
            pac_md_listvalores.f_getdescripvalor('SELECT DESCRIPCION FROM '
                                                 || ' SGT_FORMULAS WHERE CLAVE=' || ccum.clave,
                                                 mensajes);
         cum(cum.LAST).cvalor := ccum.cvalor;
         cum(cum.LAST).tvalor :=
            pac_md_listvalores.f_getdescripvalor('SELECT TVALOR FROM '
                                                 || 'VALORES WHERE CVALOR=' || ccum.cvalor,
                                                 mensajes);
      END LOOP;

      RETURN cum;
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
   END f_get_cumulosgaran;

   /*************************************************************************
       Recupera el objeto con la información de las formulas de una garantia
       param in psproduc  : código producto
       param in pcactivi  : código actividad
       param in pgarant  : código garantía
       param out mensajes : mensajes de error
    *************************************************************************/
   FUNCTION f_get_formulasgaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodgarformulas IS
      mntgaranformula t_iax_prodgarformulas := t_iax_prodgarformulas();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(300)
              := 'psproduc=' || psproduc || 'pcactivi=' || pcactivi || 'pcgarant:' || pcgarant;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GET_PRODGARFORMULAS';

      CURSOR cur_formulas IS
         -- Bug 9685 - APD - 12/05/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
         SELECT g.cgarant, g.cactivi, g.ccampo, c.tcampo, c.cutili, g.clave, f.formula,
                f.descripcion
           FROM productos p, garanformula g, codcampo c, sgt_formulas f
          WHERE f.clave = g.clave
            AND c.cutili IN(0, 8)
            AND c.ccampo = g.ccampo
            AND g.cactivi = pcactivi
            AND g.cgarant = pcgarant
            AND p.cmodali = g.cmodali
            AND p.cramo = g.cramo
            AND p.ccolect = g.ccolect
            AND p.ctipseg = g.ctipseg
            AND p.sproduc = psproduc
         UNION
         SELECT g.cgarant, g.cactivi, g.ccampo, c.tcampo, c.cutili, g.clave, f.formula,
                f.descripcion
           FROM productos p, garanformula g, codcampo c, sgt_formulas f
          WHERE f.clave = g.clave
            AND c.cutili IN(0, 8)
            AND c.ccampo = g.ccampo
            AND g.cactivi = 0
            AND g.cgarant = pcgarant
            AND p.cmodali = g.cmodali
            AND p.cramo = g.cramo
            AND p.ccolect = g.ccolect
            AND p.ctipseg = g.ctipseg
            AND p.sproduc = psproduc
            AND NOT EXISTS(SELECT g.cgarant, g.cactivi, g.ccampo, c.tcampo, c.cutili, g.clave,
                                  f.formula, f.descripcion
                             FROM productos p, garanformula g, codcampo c, sgt_formulas f
                            WHERE f.clave = g.clave
                              AND c.cutili IN(0, 8)
                              AND c.ccampo = g.ccampo
                              AND g.cactivi = pcactivi
                              AND g.cgarant = pcgarant
                              AND p.cmodali = g.cmodali
                              AND p.cramo = g.cramo
                              AND p.ccolect = g.ccolect
                              AND p.ctipseg = g.ctipseg
                              AND p.sproduc = psproduc);
   -- Bug 9685 - APD - 12/05/2009 - fin
   BEGIN
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      FOR formul IN cur_formulas LOOP
         mntgaranformula.EXTEND;
         mntgaranformula(mntgaranformula.LAST) := ob_iax_prodgarformulas();
         mntgaranformula(mntgaranformula.LAST).ccampo := formul.ccampo;
         mntgaranformula(mntgaranformula.LAST).tcampo := formul.tcampo;
         mntgaranformula(mntgaranformula.LAST).clave := formul.clave;
         mntgaranformula(mntgaranformula.LAST).formula := formul.descripcion;
         mntgaranformula(mntgaranformula.LAST).cutili := formul.cutili;
      END LOOP;

      RETURN mntgaranformula;
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
   END f_get_formulasgaran;

   /*************************************************************************
      Recupera el cursor con la información de la tabla Garanprocap
      param in psproduc  : código producto
      param in pcactivi  : código actividad
      param in pcgarant  : código garantia
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_pregungaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodpregunprogaran IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_MNTPROD.F_Get_PregunGaran';
      vparam         VARCHAR2(500)
         := 'parámetros , sproduc :' || psproduc || ' , cactivi' || pcactivi
            || ' , pcgarant =' || pcgarant;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      num_err        NUMBER;
      tpppg          t_iax_prodpregunprogaran := t_iax_prodpregunprogaran();
      vctippre       NUMBER;
   BEGIN
      -- Verificación de los parámetros
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      -- Bug 9685 - APD - 12/05/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a PREGUNPROGARAN para la actividad cero
      FOR cur IN (SELECT   cpregun, npreord, cpretip, cpreobl, tprefor, cresdef, cofersn,
                           npreimp
                      FROM pregunprogaran
                     WHERE sproduc = psproduc
                       AND cactivi = pcactivi
                       -- Ini Bug 16489 - SRA - se ha de aplicar el filtrado por garantía
                       AND cgarant = pcgarant
                  -- Fin Bug 16489 - SRA
                  UNION
                  SELECT   cpregun, npreord, cpretip, cpreobl, tprefor, cresdef, cofersn,
                           npreimp
                      FROM pregunprogaran
                     WHERE sproduc = psproduc
                       AND cactivi = 0
                       -- Ini Bug 16489 - SRA - se ha de aplicar el filtrado por garantía
                       AND cgarant = pcgarant
                       -- Fin Bug 16489 - SRA
                       AND NOT EXISTS(SELECT cpregun, npreord, cpretip, cpreobl, tprefor,
                                             cresdef, cofersn, npreimp
                                        FROM pregunprogaran
                                       WHERE sproduc = psproduc
                                         AND cactivi = pcactivi
                                         -- Ini Bug 16489 - SRA - se ha de aplicar el filtrado por garantía
                                         AND cgarant = pcgarant
                                                               -- Fin Bug 16489 - SRA
                          )
                  -- Bug 9685 - APD - 12/05/2009 - fin
                  ORDER BY 2) LOOP
-- Bug 18134 - RSC - 04/04/2011 - CRT - Modificacion de productos genericos (npreord)
         vpasexec := 3;
         tpppg.EXTEND;
         tpppg(tpppg.COUNT) := ob_iax_prodpregunprogaran();
         tpppg(tpppg.COUNT).cpregun := cur.cpregun;
         tpppg(tpppg.COUNT).npreord := cur.npreord;
         tpppg(tpppg.COUNT).cpretip := cur.cpretip;
         tpppg(tpppg.COUNT).cpreobl := cur.cpreobl;
         tpppg(tpppg.COUNT).tprefor := cur.tprefor;
         tpppg(tpppg.COUNT).cresdef := cur.cresdef;
         tpppg(tpppg.COUNT).cofersn := cur.cofersn;
         tpppg(tpppg.COUNT).npreimp := cur.npreimp;
         num_err := f_despregunta(tpppg(tpppg.COUNT).cpregun, pac_md_common.f_get_cxtidioma(),
                                  tpppg(tpppg.COUNT).tpregun);
         vpasexec := 4;

         IF num_err <> 0 THEN
            tpppg(tpppg.COUNT).tpregun := NULL;
         END IF;

         vpasexec := 5;
         tpppg(tpppg.COUNT).tpretip :=
             pac_iax_listvalores.f_getdescripvalores(787, tpppg(tpppg.COUNT).cpretip, mensajes);
         vpasexec := 6;

         SELECT ctippre
           INTO vctippre
           FROM codipregun p
          WHERE p.cpregun = tpppg(tpppg.COUNT).cpregun;

         IF tpppg(tpppg.COUNT).cresdef IS NOT NULL
            AND vctippre IN(1, 2)
            AND tpppg(tpppg.COUNT).cpregun IS NOT NULL THEN
            vpasexec := 7;
            tpppg(tpppg.COUNT).tresdef :=
               pac_iax_listvalores.f_getdescripvalor
                                        ('select trespue from respuestas where crespue = '
                                         || tpppg(tpppg.COUNT).cresdef || ' and cpregun = '
                                         || tpppg(tpppg.COUNT).cpregun || ' and cidioma = '
                                         || pac_md_common.f_get_cxtidioma(),
                                         mensajes);
         ELSE
            tpppg(tpppg.COUNT).tresdef := tpppg(tpppg.COUNT).cresdef;
         END IF;
      END LOOP;

      vpasexec := 8;
      RETURN tpppg;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_pregungaran;

   /*************************************************************************
       Recupera el objeto con los parametros de la garantia
       Psproduc    NUMBER    IN        Código producto
       Pcactivi    NUMBER    IN        Código de actividad
       Pcgarant    NUMBER    IN        Código garantia
       param out mensajes : mensajes de error
    *************************************************************************/
   FUNCTION f_get_paramgaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodparagaranpro IS
      garparam       t_iax_prodparagaranpro := t_iax_prodparagaranpro();
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(100)
         := 'parámetros , sproduc :' || psproduc || ' , cactivi' || pcactivi || ' , cgarant ='
            || pcgarant;
      vobject        VARCHAR2(100) := 'PAC_MD_MNTPROD.F_Get_ParamGaran';

      CURSOR c(vcactivi IN NUMBER) IS
         SELECT pg.cpargar cparame, des.tparam tparame, cp.ctipo ctippar, pg.tvalpar tvalpar,
                pg.cvalpar nvalpar, NULL dvalpar, pg.fvalpar fvalpar
           FROM pargaranpro pg, codparam cp, desparam des
          WHERE pg.sproduc = psproduc
            AND pg.cactivi = vcactivi
            AND pg.cgarant = pcgarant
            AND cp.cutili = 3
            AND pg.cpargar = cp.cparam
            AND pg.cpargar = des.cparam
            AND des.cidioma = pac_md_common.f_get_cxtidioma
            AND cp.ctipo < 4
            AND NVL(cp.cvisible, 1) = 1
         UNION
         SELECT pg.cpargar cparame, des.tparam tparame, cp.ctipo ctippar, pg.tvalpar tvalpar,
                pg.cvalpar nvalpar, det.tvalpar dvalpar, pg.fvalpar fvalpar
           FROM pargaranpro pg, codparam cp, desparam des, detparam det
          WHERE pg.sproduc = psproduc
            AND pg.cactivi = vcactivi
            AND pg.cgarant = pcgarant
            AND cp.cutili = 3
            AND pg.cpargar = cp.cparam
            AND pg.cpargar = des.cparam
            AND des.cidioma = pac_md_common.f_get_cxtidioma
            AND pg.cpargar = det.cparam
            AND det.cidioma = pac_md_common.f_get_cxtidioma
            AND det.cvalpar = pg.cvalpar
            AND cp.ctipo = 4
            AND NVL(cp.cvisible, 1) = 1;
   BEGIN
      --Comprovació dels paràmetres d'entrada
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      FOR r IN c(pcactivi) LOOP
         garparam.EXTEND;
         garparam(garparam.LAST) := ob_iax_prodparagaranpro();
         garparam(garparam.LAST).cparame := r.cparame;
         garparam(garparam.LAST).tparame := r.tparame;
         garparam(garparam.LAST).ctippar := r.ctippar;
         garparam(garparam.LAST).tvalpar := r.tvalpar;
         garparam(garparam.LAST).nvalpar := r.nvalpar;
         garparam(garparam.LAST).dvalpar := r.dvalpar;
         garparam(garparam.LAST).fvalpar := r.fvalpar;

         --XVM-RSA-8-14/06/216
         IF r.ctippar=1 THEN
            garparam(garparam.LAST).vvalpar := r.tvalpar;
         ELSIF r.ctippar=2 THEN
            garparam(garparam.LAST).vvalpar := to_char(r.nvalpar);
         ELSIF r.ctippar=3 THEN
            garparam(garparam.LAST).vvalpar := to_char(r.fvalpar,'DD/MM/YYYY');
         ELSIF r.ctippar=4 THEN
            garparam(garparam.LAST).vvalpar := NVL(r.dvalpar,r.nvalpar);
         ELSIF r.ctippar=5 THEN
            garparam(garparam.LAST).vvalpar := to_char(r.nvalpar);
         END IF;
      END LOOP;

      -- Bug 9685 - APD - 12/05/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a PARGARANPRO para la actividad cero
      IF garparam IS NULL THEN
         FOR r IN c(0) LOOP
            garparam.EXTEND;
            garparam(garparam.LAST) := ob_iax_prodparagaranpro();
            garparam(garparam.LAST).cparame := r.cparame;
            garparam(garparam.LAST).tparame := r.tparame;
            garparam(garparam.LAST).ctippar := r.ctippar;
            garparam(garparam.LAST).tvalpar := r.tvalpar;
            garparam(garparam.LAST).nvalpar := r.nvalpar;
            garparam(garparam.LAST).dvalpar := r.dvalpar;
            garparam(garparam.LAST).fvalpar := r.fvalpar;

            --XVM-RSA-8-14/06/216
            IF r.ctippar=1 THEN
               garparam(garparam.LAST).vvalpar := r.tvalpar;
            ELSIF r.ctippar=2 THEN
               garparam(garparam.LAST).vvalpar := to_char(r.nvalpar);
            ELSIF r.ctippar=3 THEN
               garparam(garparam.LAST).vvalpar := to_char(r.fvalpar,'DD/MM/YYYY');
            ELSIF r.ctippar=4 THEN
               garparam(garparam.LAST).vvalpar := NVL(r.dvalpar,r.nvalpar);
            ELSIF r.ctippar=5 THEN
               garparam(garparam.LAST).vvalpar := to_char(r.nvalpar);
            END IF;
         END LOOP;
      END IF;

      -- Bug 9685 - APD - 12/05/2009 - fin
      RETURN garparam;
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
   END f_get_paramgaran;

   /************************************************************************
      <<-- Recupera información de la garantia
   *************************************************************************/

   /************************************************************************
      Recupera información del producto datos unit linked -->>
   *************************************************************************/

   /*************************************************************************
      Recupera el objeto con la información del producto
      datos unit linked modelos inversión
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_modelosinv(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_produlkmodelosinv IS
      mntmodelosinv  t_iax_produlkmodelosinv := t_iax_produlkmodelosinv();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GET_MODELOSINV';

      CURSOR cur_produlk IS
         SELECT cmodinv, tmodinv
           FROM codimodelosinversion
          WHERE cramo || cmodali || ctipseg || ccolect IN(
                        SELECT cramo || cmodali || ctipseg || ccolect
                          FROM productos
                         WHERE sproduc = psproduc
                           AND cidioma = pac_md_common.f_get_cxtidioma());
   BEGIN
      FOR produlk IN cur_produlk LOOP
         mntmodelosinv.EXTEND;
         mntmodelosinv(mntmodelosinv.LAST) := ob_iax_produlkmodelosinv();
         mntmodelosinv(mntmodelosinv.LAST).cmodinv := produlk.cmodinv;
         mntmodelosinv(mntmodelosinv.LAST).tmodinv := produlk.tmodinv;
         mntmodelosinv(mntmodelosinv.LAST).modinvfondo :=
                         pac_md_mntprod.f_get_modinvfondo(psproduc, produlk.cmodinv, mensajes);
      END LOOP;

      RETURN mntmodelosinv;
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
   END f_get_modelosinv;

   /*************************************************************************
      Recupera el objeto con la información del producto
      datos unit linked fondos inversión
      param in psproduc  : código producto
      param in pcmodinv  : código modelo inversión
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_modinvfondo(
      psproduc IN NUMBER,
      pcmodinv IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_produlkmodinvfondo IS
      mntmodinvfondo t_iax_produlkmodinvfondo := t_iax_produlkmodinvfondo();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GET_MODINVFONDO';

      CURSOR cur_modinv IS
         SELECT ccodfon, pinvers, pmaxcont
           FROM modinvfondo
          WHERE cramo || cmodali || ctipseg || ccolect IN(
                                                 SELECT cramo || cmodali || ctipseg || ccolect
                                                   FROM productos
                                                  WHERE sproduc = psproduc);
   BEGIN
      FOR modinv IN cur_modinv LOOP
         mntmodinvfondo.EXTEND;
         mntmodinvfondo(mntmodinvfondo.LAST) := ob_iax_produlkmodinvfondo();
         mntmodinvfondo(mntmodinvfondo.LAST).ccodfon := modinv.ccodfon;

         IF modinv.ccodfon IS NOT NULL THEN
            mntmodinvfondo(mntmodinvfondo.LAST).tcodfon :=
               pac_iax_listvalores.f_getdescripvalor
                              ('select tfonabv from fondos where ctipfon=3 and ccodfon = '
                               || modinv.ccodfon,
                               mensajes);
         END IF;

         mntmodinvfondo(mntmodinvfondo.LAST).pinvers := modinv.pinvers;
         mntmodinvfondo(mntmodinvfondo.LAST).pmaxcont := modinv.pmaxcont;
      END LOOP;

      RETURN mntmodinvfondo;
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
   END f_get_modinvfondo;

   /************************************************************************
      <<-- Recupera información del producto datos unit linked
   *************************************************************************/

   /************************************************************************
      Recupera información del producto datos rentas -->>
   *************************************************************************/

   /*************************************************************************
      Recupera el objeto con la información del producto
      datos rentas formulas
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_rentasformula(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodrentasformula IS
      mntrentasformula t_iax_prodrentasformula := t_iax_prodrentasformula();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GET_RENTASFORMULA';

      CURSOR cur_renta IS
         SELECT ccampo, clave
           FROM rentasformula
          WHERE sproduc = psproduc;
   BEGIN
      FOR renta IN cur_renta LOOP
         mntrentasformula.EXTEND;
         mntrentasformula(mntrentasformula.LAST) := ob_iax_prodrentasformula();
         mntrentasformula(mntrentasformula.LAST).ccampo := renta.ccampo;

         --DEFINIR
         IF renta.ccampo IS NOT NULL THEN
            --mntrentasformula(mntrentasformula.last).tcampo := PAC_IAX_LISTVALORES.F_GetDescripValor('select tcampo from codcampo where ccampo = ' ||  renta.ccampo,mensajes); --DEFINIR
            mntrentasformula(mntrentasformula.LAST).tcampo :=
               pac_iax_listvalores.f_getdescripvalor
                                            ('select tcampo from codcampo where ccampo = '
                                             || CHR(39) || renta.ccampo || CHR(39),
                                             mensajes);
         END IF;

         mntrentasformula(mntrentasformula.LAST).clave := renta.clave;

         --DEFINIR
         IF renta.clave IS NOT NULL THEN
            mntrentasformula(mntrentasformula.LAST).formula :=
               pac_iax_listvalores.f_getdescripvalor
                                        ('select formula from sgt_formulas where clave = '
                                         || renta.clave,
                                         mensajes);   --DEFINIR
         END IF;
      END LOOP;

      RETURN mntrentasformula;
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
   END f_get_rentasformula;

   /*************************************************************************
      Recupera el objeto con la información del producto
      datos rentas formas de pago
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_forpagren(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prodforpagren IS
      mntforpagren   t_iax_prodforpagren := t_iax_prodforpagren();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GET_FORPAGREN';
      vcforpag       NUMBER;

      CURSOR cur_detvalores IS
         SELECT   catribu, tatribu
             FROM detvalores
            WHERE cvalor = 17
              AND cidioma = pac_md_common.f_get_cxtidioma
         ORDER BY catribu;

      CURSOR cur_forpag IS
         SELECT cforpag
           FROM forpagren
          WHERE sproduc = psproduc
            AND cforpag = vcforpag;
   BEGIN
      FOR detval IN cur_detvalores LOOP
         vcforpag := detval.catribu;
         mntforpagren.EXTEND;
         mntforpagren(mntforpagren.LAST) := ob_iax_prodforpagren();
         mntforpagren(mntforpagren.LAST).cforpag := detval.catribu;
         mntforpagren(mntforpagren.LAST).tforpag := detval.tatribu;
         --PAC_IAX_LISTVALORES.F_GetDescripValores(17, forpag.cforpag, mensajes);
         mntforpagren(mntforpagren.LAST).cobliga := 0;

         FOR forpag IN cur_forpag LOOP
            mntforpagren(mntforpagren.LAST).cobliga := 1;
         END LOOP;
      END LOOP;

      RETURN mntforpagren;
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
   END f_get_forpagren;

   /************************************************************************
      <<-- Recupera información del producto datos rentas
   *************************************************************************/

   /************************************************************************
      <<-- Recupera información del producto
   *************************************************************************/

   /*************************************************************************
      Valida los datos generales
      param in psproduc    : código del producto
      param in pcramo      : código del ramo
      param in pcmodali    : código de la modalidad
      param in pctipseg    : código del tipo de seguro
      param in pccolect    : código de colectividad
      param in pcactivo    : indica si el producto está activo
      param in pctermfin   : contratable desde el terminal financiero, 0.-Si, 1.-No
      param in pctiprie    : tipo de riesgo
      param in pcobjase    : Tipo de objeto asegurado
      param in pcsubpro    : Código de subtipo de producto
      param in pnmaxrie    : maximo riesgo
      param in pc2cabezas  : c2cabezas
      param in pcagrpro    : Codigo agrupación de producto
      param in pcdivisa    : Clave de Divisa
      param in pTitulos    : Colección t_iax_prodtitulo
      param out mensajes   : mensajes de error
      return 0 bien numerror error
   *************************************************************************/
   FUNCTION f_validadatosgenerales(
      psproduc IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivo IN NUMBER,
      pctermfin IN NUMBER,
      pctiprie IN NUMBER,
      pcobjase IN NUMBER,
      pcsubpro IN NUMBER,
      pnmaxrie IN NUMBER,
      pc2cabezas IN NUMBER,
      pcagrpro IN NUMBER,
      pcdivisa IN NUMBER,
      pcompani IN NUMBER,
      ptitulos IN t_iax_prodtitulo,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      nerror         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'psproduc=' || psproduc || ' pcramo=' || pcramo || ' pcmodali=' || pcmodali
            || ' pctipseg=' || pctipseg || ' pccolect=' || pccolect;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_ValidaDatosGenerales';
   BEGIN
      nerror := pac_mntprod.f_validadatosgenerales(psproduc, pcramo, pcmodali, pctipseg,
                                                   pccolect, pcactivo, pctermfin, pctiprie,
                                                   pcobjase, pcsubpro, pnmaxrie, pc2cabezas,
                                                   pcagrpro, pcdivisa, pcompani);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, nerror, vpasexec, vparam);
         RETURN nerror;
      END IF;

      vpasexec := 5;

      FOR titu IN ptitulos.FIRST .. ptitulos.LAST LOOP
         IF ptitulos.EXISTS(titu) THEN
            IF ptitulos(titu).ttitulo IS NULL
               AND ptitulos(titu).ttitulo IS NULL THEN
               pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000031, vpasexec, vparam);
               nerror := 1000031;
            END IF;
         END IF;
      END LOOP;

      RETURN nerror;
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
   END f_validadatosgenerales;

   /*************************************************************************
      Realiza las inserciones, modificaciones y validaciones
      param in psproduc    : código del producto
      param in pcramo      : código del ramo
      param in pcmodali    : código de la modalidad
      param in pctipseg    : código del tipo de seguro
      param in pccolect    : código de colectividad
      param in pcactivo    : indica si el producto está activo
      param in pctermfin   : contratable desde el terminal financiero, 0.-Si, 1.-No
      param in pctiprie    : tipo de riesgo
      param in pcobjase    : Tipo de objeto asegurado
      param in pcsubpro    : Código de subtipo de producto
      param in pnmaxrie    : maximo riesgo
      param in pc2cabezas  : c2cabezas
      param in pcagrpro    : Codigo agrupación de producto
      param in pcdivisa    : Clave de Divisa
      param in pTitulos    : Colección t_iax_prodtitulo
      param in pcompani    : Código cia
      param out mensajes   : mensajes de error
      return number 0 bien 1 error
   *************************************************************************/
   FUNCTION f_set_datosgenerales(
      psproduc IN OUT NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivo IN NUMBER,
      pctermfin IN NUMBER,
      pctiprie IN NUMBER,
      pcobjase IN NUMBER,
      pcsubpro IN NUMBER,
      pnmaxrie IN NUMBER,
      pc2cabezas IN NUMBER,
      pcagrpro IN NUMBER,
      pcdivisa IN NUMBER,
      ptitulos IN t_iax_prodtitulo,
      pcprprod IN NUMBER,
      pcompani IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Set_DatosGenerales';
      nerror         NUMBER := 0;
   BEGIN
      nerror := f_validadatosgenerales(psproduc, pcramo, pcmodali, pctipseg, pccolect,
                                       pcactivo, pctermfin, pctiprie, pcobjase, pcsubpro,
                                       pnmaxrie, pc2cabezas, pcagrpro, pcdivisa, pcompani,
                                       ptitulos, mensajes);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, nerror, vpasexec, vparam);
         RETURN nerror;
      END IF;

      vpasexec := 15;
      nerror := pac_mntprod.f_set_datosgenerales(psproduc, pcramo, pcmodali, pctipseg,
                                                 pccolect, pcactivo, pctermfin, pctiprie,
                                                 pcobjase, pcsubpro, pnmaxrie, pc2cabezas,
                                                 pcagrpro, pcdivisa, pcprprod, pcompani);
      vpasexec := 16;

      IF nerror = 0 THEN
         vpasexec := 7;

         FOR titu IN ptitulos.FIRST .. ptitulos.LAST LOOP
            IF ptitulos.EXISTS(titu) THEN
               vpasexec := 9;
               nerror := pac_mntprod.f_set_prodtitulo(pcramo, pcmodali, pctipseg, pccolect,
                                                      ptitulos(titu).cidioma,
                                                      ptitulos(titu).trotulo,
                                                      ptitulos(titu).ttitulo);

               IF nerror <> 0 THEN
                  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, nerror, vpasexec,
                                                    vparam);
               END IF;
            END IF;
         END LOOP;
      ELSE
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, nerror, vpasexec, vparam);
      END IF;

      RETURN nerror;
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
   END f_set_datosgenerales;

   /*************************************************************************
      Valida los datos de gestión de un producto
      param in psproduc   : código del producto
      param in cduraci    : código de la duración
      param in ctempor    : Permite temporal
      param in ndurcob    : Duración pagos
      param in cdurmin    : Duración mínima
      param in nvtomin    : Tipo
      param in cdurmax    : duración máxima póliza
      param in nvtomax    : Número años máximo para el vto.
      param in ctipefe    : Tipo de efecto
      param in nrenova    : renovación
      param in cmodnre    : Fecha de renovación
      param in cprodcar   : Si ha pasado cartera
      param in crevali    : Código de revalorización
      param in prevali    : Porcentaje revalorización
      param in irevali    : Importe revalorización
      param in ctarman    : tarificación puede ser manual
      param in creaseg    : creaseg
      param in creteni    : Indicador de propuesta
      param in cprorra    : tipo prorrateo
      param in cprimin    : tipo de prima minima
      param in iprimin    : importe mínimo prima de recibo en emisión
      param in cclapri    : Fórmula prima mínima
      param in ipminfra   : Prima mínima fraccionada
      param in nedamic    : Edad mín ctr
      param in ciedmic    : Edad real
      param in nedamac    : Edad máx. ctr
      param in ciedmac    : Edad Real. Check por defecto = 0 ( sino es actuarial)
      param in nedamar    : Edad máx. ren
      param in ciedmar    : Edad Real
      param in nedmi2c    : Edad mín ctr 2º aseg.
      param in ciemi2c    : Edad real
      param in nedma2c    : Edad máx. ctr 2º aseg.
      param in ciema2c    : Edad Real
      param in nedma2r    : Edad máx. ren 2º aseg.
      param in ciema2r    : Real o Actuarial
      param in nsedmac    : Suma Máx. Edades
      param in cisemac    : Real
      param in cvinpol    : Póliza vinculada
      param in cvinpre    : Préstamo vinculado
      param in ccuesti    : Cuestionario Salud
      param in cctacor    : Libreta
      return              : 0 si ha ido bien
                           error si ha ido mal
   *************************************************************************/
   FUNCTION f_validagestion(
      psproduc IN NUMBER,
      pcduraci IN NUMBER,
      pctempor IN NUMBER,
      pndurcob IN NUMBER,
      pcdurmin IN NUMBER,
      pnvtomin IN NUMBER,
      pcdurmax IN NUMBER,
      pnvtomax IN NUMBER,
      pctipefe IN NUMBER,
      pnrenova IN NUMBER,
      pcmodnre IN NUMBER,
      pcprodcar IN NUMBER,
      pcrevali IN NUMBER,
      pprevali IN NUMBER,
      pirevali IN NUMBER,
      pctarman IN NUMBER,
      pcreaseg IN NUMBER,
      pcreteni IN NUMBER,
      pcprorra IN NUMBER,
      pcprimin IN NUMBER,
      piprimin IN NUMBER,
      pcclapri IN NUMBER,
      pipminfra IN NUMBER,
      pnedamic IN NUMBER,
      pciedmic IN NUMBER,
      pnedamac IN NUMBER,
      pciedmac IN NUMBER,
      pnedamar IN NUMBER,
      pciedmar IN NUMBER,
      pnedmi2c IN NUMBER,
      pciemi2c IN NUMBER,
      pnedma2c IN NUMBER,
      pciema2c IN NUMBER,
      pnedma2r IN NUMBER,
      pciema2r IN NUMBER,
      pnsedmac IN NUMBER,
      pcisemac IN NUMBER,
      pcvinpol IN NUMBER,
      pcvinpre IN NUMBER,
      pccuesti IN NUMBER,
      pcctacor IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      nerror         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_ValidaGestion';
   BEGIN
      nerror := pac_mntprod.f_validagestion(psproduc, pcduraci, pctempor, pndurcob, pcdurmin,
                                            pnvtomin, pcdurmax, pnvtomax, pctipefe, pnrenova,
                                            pcmodnre, pcprodcar, pcrevali, pprevali, pirevali,
                                            pctarman, pcreaseg, pcreteni, pcprorra, pcprimin,
                                            piprimin, pcclapri, pipminfra, pnedamic, pciedmic,
                                            pnedamac, pciedmac, pnedamar, pciedmar, pnedmi2c,
                                            pciemi2c, pnedma2c, pciema2c, pnedma2r, pciema2r,
                                            pnsedmac, pcisemac, pcvinpol, pcvinpre, pccuesti,
                                            pcctacor);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
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
   END f_validagestion;

   /*************************************************************************
      Valida los datos de gestión de un producto
      param in psproduc   : código del producto
      param in cduraci    : código de la duración
      param in ctempor    : Permite temporal
      param in ndurcob    : Duración pagos
      param in cdurmin    : Duración mínima
      param in nvtomin    : Tipo
      param in cdurmax    : duración máxima póliza
      param in nvtomax    : Número años máximo para el vto.
      param in ctipefe    : Tipo de efecto
      param in nrenova    : renovación
      param in cmodnre    : Fecha de renovación
      param in cprodcar   : Si ha pasado cartera
      param in crevali    : Código de revalorización
      param in prevali    : Porcentaje revalorización
      param in irevali    : Importe revalorización
      param in ctarman    : tarificación puede ser manual
      param in creaseg    : creaseg
      param in creteni    : Indicador de propuesta
      param in cprorra    : tipo prorrateo
      param in cprimin    : tipo de prima minima
      param in iprimin    : importe mínimo prima de recibo en emisión
      param in cclapri    : Fórmula prima mínima
      param in ipminfra   : Prima mínima fraccionada
      param in nedamic    : Edad mín ctr
      param in ciedmic    : Edad real
      param in nedamac    : Edad máx. ctr
      param in ciedmac    : Edad Real. Check por defecto = 0 ( sino es actuarial)
      param in nedamar    : Edad máx. ren
      param in ciedmar    : Edad Real
      param in nedmi2c    : Edad mín ctr 2º aseg.
      param in ciemi2c    : Edad real
      param in nedma2c    : Edad máx. ctr 2º aseg.
      param in ciema2c    : Edad Real
      param in nedma2r    : Edad máx. ren 2º aseg.
      param in ciema2r    : Real o Actuarial
      param in nsedmac    : Suma Máx. Edades
      param in cisemac    : Real
      param in cvinpol    : Póliza vinculada
      param in cvinpre    : Préstamo vinculado
      param in ccuesti    : Cuestionario Salud
      param in cctacor    : Libreta
      return              : 0 si ha ido bien
                           error si ha ido mal
   *************************************************************************/
   FUNCTION f_set_gestion(
      psproduc IN NUMBER,
      pcduraci IN NUMBER,
      pctempor IN NUMBER,
      pndurcob IN NUMBER,
      pcdurmin IN NUMBER,
      pnvtomin IN NUMBER,
      pcdurmax IN NUMBER,
      pnvtomax IN NUMBER,
      pctipefe IN NUMBER,
      pnrenova IN NUMBER,
      pcmodnre IN NUMBER,
      pcprodcar IN NUMBER,
      pcrevali IN NUMBER,
      pprevali IN NUMBER,
      pirevali IN NUMBER,
      pctarman IN NUMBER,
      pcreaseg IN NUMBER,
      pcreteni IN NUMBER,
      pcprorra IN NUMBER,
      pcprimin IN NUMBER,
      piprimin IN NUMBER,
      pcclapri IN NUMBER,
      pipminfra IN NUMBER,
      pnedamic IN NUMBER,
      pciedmic IN NUMBER,
      pnedamac IN NUMBER,
      pciedmac IN NUMBER,
      pnedamar IN NUMBER,
      pciedmar IN NUMBER,
      pnedmi2c IN NUMBER,
      pciemi2c IN NUMBER,
      pnedma2c IN NUMBER,
      pciema2c IN NUMBER,
      pnedma2r IN NUMBER,
      pciema2r IN NUMBER,
      pnsedmac IN NUMBER,
      pcisemac IN NUMBER,
      pcvinpol IN NUMBER,
      pcvinpre IN NUMBER,
      pccuesti IN NUMBER,
      pcctacor IN NUMBER,
      pcpreaviso IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Set_Gestion';
      nerror         NUMBER := 0;
   BEGIN
      nerror := pac_mntprod.f_set_gestion(psproduc, pcduraci, pctempor, pndurcob, pcdurmin,
                                          pnvtomin, pcdurmax, pnvtomax, pctipefe, pnrenova,
                                          pcmodnre, pcprodcar, pcrevali, pprevali, pirevali,
                                          pctarman, pcreaseg, pcreteni, pcprorra, pcprimin,
                                          piprimin, pcclapri, pipminfra, pnedamic, pciedmic,
                                          pnedamac, pciedmac, pnedamar, pciedmar, pnedmi2c,
                                          pciemi2c, pnedma2c, pciema2c, pnedma2r, pciema2r,
                                          pnsedmac, pcisemac, pcvinpol, pcvinpre, pccuesti,
                                          pcctacor, pcpreaviso);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
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
   END f_set_gestion;

   /*************************************************************************
       Modifica o inserta un periodo
       param in psproduc   : código del producto
       param in Pfinicio   : fecha inicio
       param in pndurper   : duracion
       param in PndurperOld: duracion anterior
       param out mensajes  : mensajes de error
       return              : 0 si ha ido bien
                             1 si ha ido mal
    *************************************************************************/
   FUNCTION f_set_durperiod(
      psproduc IN NUMBER,
      pfinicio IN DATE,
      pndurper IN NUMBER,
      pndurperold IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproduc=' || psproduc || ' pfinicio=' || pfinicio || ' pndurper=' || pndurper
            || ' pndurperOld=' || pndurperold;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Set_Durperiod';
      nerror         NUMBER := 0;
      finicio_max    DATE;
   BEGIN
      IF pfinicio IS NULL THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 700169, vpasexec, vparam);
         RETURN 1;
      ELSIF pndurper IS NULL THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 151288, vpasexec, vparam);
         RETURN 1;
      END IF;

      nerror := pac_durperiodoprod.f_fecha_inicio_periodo_vigente(psproduc, finicio_max);

      IF nerror = 0 THEN
         IF TO_DATE(pfinicio, 'dd/mm/yyyy') >= TO_DATE(finicio_max, 'dd/mm/yyyy')
            AND finicio_max IS NOT NULL THEN
            -- Nueva Duración para el periodo vigente o Modificar periodo existente
            IF TO_DATE(pfinicio, 'dd/mm/yyyy') = TO_DATE(finicio_max, 'dd/mm/yyyy') THEN   -- Misma Fecha
               IF pndurperold IS NULL THEN   -- Nueva Duración para el periodo vigente
                  IF pac_durperiodoprod.f_contar_registros(psproduc, pfinicio, pndurper) = 0 THEN
                     IF pac_durperiodoprod.f_insert_durperiodoprod(psproduc, pfinicio,
                                                                   pndurper) = 0 THEN
                        COMMIT;
                     ELSE
                        pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 152976, vpasexec,
                                                          vparam);
                        RETURN 1;
                     END IF;
                  ELSE
                     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 108959, vpasexec,
                                                       vparam);
                     RETURN 1;
                  END IF;
               ELSE   -- Modificar periodo existente
                  IF pac_durperiodoprod.f_contar_registros(psproduc, pfinicio, pndurper) = 0 THEN
                     IF pac_durperiodoprod.f_modificacio_durperiodoprod(psproduc, pfinicio,
                                                                        pndurper, pndurperold) =
                                                                                             0 THEN
                        COMMIT;
                     ELSE
                        pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 152977, vpasexec,
                                                          vparam);
                        RETURN 1;
                     END IF;
                  ELSE
                     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 108959, vpasexec,
                                                       vparam);
                     RETURN 1;
                  END IF;
               END IF;   -- FIN Modificar periodo existente
            ELSE
               -- Nuevo Periodo de Duraciones (se debe cerrar el periodo anterior)
               IF pac_durperiodoprod.f_actualiza_fecha_fin(psproduc, pfinicio) = 0 THEN
                  IF pac_durperiodoprod.f_insert_durperiodoprod(psproduc, pfinicio, pndurper) =
                                                                                             0 THEN
                     COMMIT;
                  ELSE
                     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 152976, vpasexec,
                                                       vparam);
                     RETURN 1;
                  END IF;
               ELSE
                  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 108959, vpasexec,
                                                    vparam);
                  RETURN 1;
               END IF;
            END IF;
         ELSE
            IF finicio_max IS NULL THEN
               -- Primer registro (se da de alta la primera duracion del primer periodo)
               IF pac_durperiodoprod.f_insert_durperiodoprod(psproduc, pfinicio, pndurper) = 0 THEN
                  COMMIT;
               ELSE
                  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 152976, vpasexec,
                                                    vparam);
                  RETURN 1;
               END IF;
            ELSE
               pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 153037, vpasexec, vparam);
               RETURN 1;
            END IF;
         END IF;   -- FIN Fecha inicio superior
      ELSE
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 140149, vpasexec, vparam);
         RETURN 1;
      END IF;   -- FIN Existe fecha maxima

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
   END f_set_durperiod;

   /*************************************************************************
       Borra las duraciones permitidas para un producto
       param in psproduc   : código del producto
       param in Pfinicio   : fecha inicio
       param in pndurper   : duracion
       param out mensajes  : mensajes de error
       return              : 0 si ha ido bien
                             1 si ha ido mal
   *************************************************************************/
   FUNCTION f_del_durperiod(
      psproduc IN NUMBER,
      pfinicio IN DATE,
      pndurper IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Del_Duperiod';
      nerror         NUMBER := 0;
   BEGIN
      IF pac_durperiodoprod.f_borrar_durperiodoprod(psproduc, pfinicio, pndurper) = 0 THEN
         IF pac_durperiodoprod.f_abrir_periodo_anterior(psproduc, pfinicio) <> 0 THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 152978, vpasexec, vparam);
            RETURN 1;
         END IF;
      ELSE
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 152978, vpasexec, vparam);
         RETURN 1;
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
   END f_del_durperiod;

   /*************************************************************************
      Realiza las  modificaciones y validaciones de los datos de admnistración del producto
      param in psproduc    : código del producto
      param in Pctipges    : Gestión del seguro.
      param in pcreccob    : 1er recibo
      param in pctipreb    : Recibo por.
      param in pccalcom    : Cálculo comisión
      param in pctippag    : Cobro
      param in pcmovdom    : Domiciliar el primer recibo
      param in pcfeccob    : Acepta fecha de cobro
      param in pcrecfra    : Recargo Fraccionamiento
      param in piminext    : Prima mínima extorno
      param in pndiaspro   : Días acumulables
      param in pcnv_spr    : Identificador del cliente para el producto en contabilidad
      param out mensajes   : mensajes de error
      retorna un cero si todo va bien  y un uno en caso contrario
   *************************************************************************/
   FUNCTION f_set_admprod(
      psproduc IN NUMBER,
      pctipges IN NUMBER,
      pcreccob IN NUMBER,
      pctipreb IN NUMBER,
      pccalcom IN NUMBER,
      pctippag IN NUMBER,
      pcmovdom IN NUMBER,
      pcfeccob IN NUMBER,
      pcrecfra IN NUMBER,
      piminext IN NUMBER,
      pndiaspro IN NUMBER,
      pcnv_spr IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := ' sproduc:' || psproduc || ' ,ctipges:' || pctipges || ' ,creccob:' || pcreccob
            || ' ,ctipreb:' || pctipreb || ' ,ccalcom:' || pccalcom || ' ,ctippag:'
            || pctippag || ' ,cmovdom:' || pcmovdom || ' ,cfeccob:' || pcfeccob
            || ' ,crecfra:' || pcrecfra || ' ,iminext:' || piminext || ' ,ndiaspro:'
            || pndiaspro || ' cnv_spr:' || pcnv_spr;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Set_AdmProd';
      nerror         NUMBER := 0;
   BEGIN
      --Comprovació de paràmetres
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerror := pac_mntprod.f_valida_admprod(pac_md_common.f_get_cxtempresa, psproduc,
                                             pctipges, pcreccob, pctipreb, pccalcom, pctippag,
                                             pcmovdom, pcfeccob, pcrecfra, piminext, pndiaspro,
                                             pcnv_spr);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      nerror := pac_mntprod.f_set_admprod(psproduc, pctipges, pcreccob, pctipreb, pccalcom,
                                          pctippag, pcmovdom, pcfeccob, pcrecfra, piminext,
                                          pndiaspro, pcnv_spr);

      IF nerror <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN nerror;
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
   END f_set_admprod;

   /*************************************************************************
      Realiza validaciones e inserta/modifica formas de pago del producto
      param in psproduc  : código producto
      param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_set_forpago(
      psproduc IN NUMBER,
      pcforpag IN NUMBER,
      ptforpag IN VARCHAR2,
      pcobliga IN NUMBER,
      pprecarg IN NUMBER,
      pcpagdef IN NUMBER,
      pcrevfpg IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Set_Forpago';
      v_index        NUMBER(2);
      v_cramo        NUMBER(8);
      v_cmodali      NUMBER(2);
      v_ctipseg      NUMBER(2);
      v_ccolect      NUMBER(2);
      nerror         NUMBER;
      vpagdef        NUMBER := 0;
      vobliga        NUMBER := 0;
   BEGIN
      --Comprovació de paràmetres
      IF psproduc IS NULL THEN
         --OR pforpago IS NULL THEN
         RAISE e_param_error;
      END IF;

      nerror := pac_mntprod.f_setforpago(psproduc, pcforpag, pcobliga, pprecarg, pcpagdef,
                                         pcrevfpg);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, nerror, vpasexec, vparam);   --Error al insertar
         RETURN nerror;
      END IF;

--      COMMIT;
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
   END f_set_forpago;

   /*************************************************************************
      Inserta o modifica los impuestos de una garantia
      param in psproduc    : código del producto
      param in pcactivi    : código de la actividad
      param in pcgarant    : código de la garantía
      param in pcimpcon    : aplica consorcio 0/1
      param in pcimpdgs    : aplica la DGS 0/1
      param in pcimpips    : aplica IPS 0/1
      param in pcimparb    : se calcula arbitrios 0/1
      param in pcimpfng    :
      param out mensajes   : mensajes de error
      return               : 0 si ha ido bien
                            numero error si ha ido mal
   *************************************************************************/
   FUNCTION f_set_impuestosgaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcimpcon IN NUMBER,
      pcimpdgs IN NUMBER,
      pcimpips IN NUMBER,
      pcimparb IN NUMBER,
      pcimpfng IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'psproduc=' || psproduc || ' pcactivi=' || pcactivi || ' pcgarant=' || pcgarant
            || ' pcimpcon=' || pcimpcon || ' pcimpdgs=' || pcimpdgs || ' pcimpips='
            || pcimpips || ' pcimparb=' || pcimparb || 'pcimpfng=' || pcimpfng;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Set_ImpuestosGaran';
      vpsproduc      NUMBER;
      nerror         NUMBER := 0;
   BEGIN
      --Comprovació de paràmetres
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL
         OR pcimpcon IS NULL
         OR pcimpdgs IS NULL
         OR pcimpips IS NULL
         OR pcimparb IS NULL
         OR pcimpfng IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerror := pac_mntprod.f_set_impuestosgaran(psproduc, pcactivi, pcgarant, pcimpcon,
                                                 pcimpdgs, pcimpips, pcimparb, pcimpfng);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RETURN nerror;
      END IF;

      RETURN nerror;
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
   END f_set_impuestosgaran;

   /*************************************************************************
      Inserta o modifica la formula de una garantia
      param in psproduc    : código del producto
      param in pcactivi    : código de la actividad
      param in pcgarant    : código de la garantía
      param in pccampo     : código del campo
      param in pclave      : clave fórmula
      param out mensajes   : mensajes de error
      return               : 0 si ha ido bien
                            numero error si ha ido mal
   *************************************************************************/
   FUNCTION f_set_prodgarformulas(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'Psproduc=' || psproduc || ' Pcactivi=' || pcactivi || ' Pcgarant=' || pcgarant
            || ' Pccampo=' || pccampo || ' Pclave=' || pclave;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Set_ProdGarFormulas';
      nerror         NUMBER := 0;
   BEGIN
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL
         OR pccampo IS NULL
         OR pclave IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerror := pac_mntprod.f_set_prodgarformulas(psproduc, pcactivi, pcgarant, pccampo,
                                                  pclave);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, nerror, vpasexec, vparam);
         RETURN nerror;
      END IF;

      RETURN nerror;
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
   END f_set_prodgarformulas;

   /*************************************************************************
       Devuelve la descripción de un cuadro de interés
       param in ncodint    : Código del cuadro
       param out mensajes  : mensajes de error
       return              : Descripción del cuadro de interes
   *************************************************************************/
   FUNCTION f_get_descripncodint(pncodint IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400) := 'pncodint=' || pncodint;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GET_DescripNcodint';
      nerror         NUMBER := 0;
      vtexto         VARCHAR2(100);
   BEGIN
      SELECT ttexto
        INTO vtexto
        FROM detintertec
       WHERE ncodint = pncodint
         AND cidioma = pac_md_common.f_get_cxtidioma();

      RETURN vtexto;
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
   END f_get_descripncodint;

   /*************************************************************************
       Devuelve los diferentes tipos de interés que tiene asignado el producto
       param in psproduc    : código del producto
       param out mensajes   : mensajes de error
       return               : Descripción del cuadro de interes
   *************************************************************************/
   FUNCTION f_get_tipintprod(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_intertecprod IS
      mntintertecprod t_iax_intertecprod := t_iax_intertecprod();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Get_TipIntProd';
      nerror         NUMBER := 0;
   BEGIN
      FOR cur IN (SELECT DISTINCT sproduc, p.ncodint, m.ctipo
                             FROM intertecprod p, intertecmov m
                            WHERE sproduc = psproduc
                              AND p.ncodint = m.ncodint) LOOP
         mntintertecprod.EXTEND;
         mntintertecprod(mntintertecprod.LAST) := ob_iax_intertecprod();
         mntintertecprod(mntintertecprod.LAST).ncodint := cur.ncodint;
         mntintertecprod(mntintertecprod.LAST).tcodint :=
            pac_iax_listvalores.f_getdescripvalor
               (' select ttexto
                                                                                                    from detintertec
                                                                                                    where ncodint = '
                || cur.ncodint || ' and cidioma = PAC_MD_COMMON.F_GET_CXTIDIOMA()',
                mensajes);
         mntintertecprod(mntintertecprod.LAST).ctipo := cur.ctipo;
         mntintertecprod(mntintertecprod.LAST).ttipo :=
                              pac_md_listvalores.f_getdescripvalores(848, cur.ctipo, mensajes);
      END LOOP;

      RETURN mntintertecprod;
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
   END f_get_tipintprod;

   /*************************************************************************
       Devuelve las vigencias para un cuadro en concreto y un tipo de interes
       param in ncodint     : Código del cuadro
       param in pctipo      : tipo de interes
       param out mensajes   : mensajes de error
       return               : Objeto con las viencias
   *************************************************************************/
   FUNCTION f_get_intertecmov(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_intertecprod IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400) := 'PNCODINT=' || pncodint || ' PCTIPO=' || pctipo;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Get_Intertecmov';
      nerror         NUMBER := 0;
      vfinicio       DATE;
      vffin          DATE;
      vctramtip      NUMBER;
      mntintertecprod t_iax_intertecprod := t_iax_intertecprod();
   BEGIN
      FOR cur IN (SELECT finicio, ffin, ctramtip
                    FROM intertecmov
                   WHERE ncodint = pncodint
                     AND ctipo = pctipo) LOOP
         mntintertecprod.EXTEND;
         mntintertecprod(mntintertecprod.LAST) := ob_iax_intertecprod();
         mntintertecprod(mntintertecprod.LAST).ncodint := pncodint;
         mntintertecprod(mntintertecprod.LAST).finicio := cur.finicio;
         mntintertecprod(mntintertecprod.LAST).ctipo := pctipo;
         mntintertecprod(mntintertecprod.LAST).ffin := cur.ffin;
         mntintertecprod(mntintertecprod.LAST).ctramotip := cur.ctramtip;
         mntintertecprod(mntintertecprod.LAST).ttramotip :=
                           pac_md_listvalores.f_getdescripvalores(288, cur.ctramtip, mensajes);
      END LOOP;

            /*  Select finicio, ffin, ctramtip
              into vfinicio,vffin,vctramtip
              From intertecmovdet
              Where ncodint = pncodint
              And ctipo = pctipo;

              mntintertecprod.extend;
              mntintertecprod(mntintertecprod.last) := ob_iax_intertecprod();
              mntintertecprod(mntintertecprod.last).ncodint := pncodint;
              mntintertecprod(mntintertecprod.last).finicio := vfinicio;
              mntintertecprod(mntintertecprod.last).ctipo := pctipo;
              mntintertecprod(mntintertecprod.last).ffin := vffin;
              mntintertecprod(mntintertecprod.last).ctramotip := vctramtip;
              mntintertecprod(mntintertecprod.last).ttramotip := pac_md_listvalores.F_GETDESCRIPVALORES(288,vctramtip,mensajes);


      */
      RETURN mntintertecprod;
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
   END f_get_intertecmov;

   /*************************************************************************
       Devuelve los tramos que tiene para un cuadro y un tipo de interés en concreto
       param in PNCODINT    : Código del cuadro
       param in PCTIPO      : Código del tipo de interés
       param in PFINICIO    : Fecha de la vigencia
       param out mensajes   : mensajes de error
       return               : Tramos que tiene para un cuadro y un tipo de interés en concreto
   *************************************************************************/
   FUNCTION f_get_intertecmovdet(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_intertecmovdetprod IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
                := 'PNCODINT=' || pncodint || ' PCTIPO=' || pctipo || ' PFINICIO=' || pfinicio;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GET_INTERTECMOVDET';
      nerror         NUMBER := 0;
      mntintertecmovdetprod t_iax_intertecmovdetprod := t_iax_intertecmovdetprod();
      vfinicio       DATE;
      vctipo         NUMBER;
      vndesde        NUMBER;
      vnhasta        NUMBER;
      vninttec       NUMBER;
   BEGIN
      FOR cur IN (SELECT finicio, ctipo, ndesde, nhasta, ninttec
                    FROM intertecmovdet
                   WHERE ncodint = pncodint
                     AND ctipo = pctipo
                     AND finicio = pfinicio) LOOP
         mntintertecmovdetprod.EXTEND;
         mntintertecmovdetprod(mntintertecmovdetprod.LAST) := ob_iax_intertecmovdetprod();
         mntintertecmovdetprod(mntintertecmovdetprod.LAST).ndesde := cur.ndesde;
         mntintertecmovdetprod(mntintertecmovdetprod.LAST).nhasta := cur.nhasta;
         mntintertecmovdetprod(mntintertecmovdetprod.LAST).ninttec := cur.ninttec;
      END LOOP;

      /*select finicio,ctipo,ndesde,nhasta,ninttec
      into vfinicio,vctipo,vndesde,vnhasta,vninttec
      from intertecmovdet
      where ncodint = pncodint
      and ctipo = pctipo
      and finicio = pfinicio;

      mntintertecmovdetprod.extend;
      mntintertecmovdetprod(mntintertecmovdetprod.last).ndesde := vndesde;
      mntintertecmovdetprod(mntintertecmovdetprod.last).nhasta := vnhasta;
      mntintertecmovdetprod(mntintertecmovdetprod.last).ninttec := vninttec;*/
      RETURN mntintertecmovdetprod;
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
   END f_get_intertecmovdet;

   /*************************************************************************
       Devuelve los diferentes códigos de interés que tiene un cuadro a una fecha
       param in PNCODINT    : Código del cuadro
       param out mensajes   : mensajes de error
       return               : Cursor con los diferentes códigos de interes que tiene un cuadro a una fecha
   *************************************************************************/
   FUNCTION f_get_cuadrointeresprod(pncodint IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_intertecprod IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400) := 'PNCODINT=' || pncodint;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Get_CuadroInteresProd';
      nerror         NUMBER := 0;
      squery         VARCHAR2(1000);
      mntintertecprod t_iax_intertecprod := t_iax_intertecprod();
   BEGIN
      FOR cur IN (SELECT DISTINCT m.ctipo
                             FROM intertecmov m
                            WHERE m.ncodint = pncodint
                         ORDER BY m.ctipo) LOOP
         mntintertecprod.EXTEND;
         mntintertecprod(mntintertecprod.LAST) := ob_iax_intertecprod();
         mntintertecprod(mntintertecprod.LAST).ncodint := pncodint;
         mntintertecprod(mntintertecprod.LAST).tcodint :=
            pac_iax_listvalores.f_getdescripvalor
               (' select ttexto
                                                                                                    from detintertec
                                                                                                    where ncodint = '
                || pncodint || ' and cidioma = PAC_MD_COMMON.F_GET_CXTIDIOMA()',
                mensajes);
         mntintertecprod(mntintertecprod.LAST).ctipo := cur.ctipo;
         mntintertecprod(mntintertecprod.LAST).ttipo :=
                              pac_md_listvalores.f_getdescripvalores(848, cur.ctipo, mensajes);
      END LOOP;

      RETURN mntintertecprod;
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
   END f_get_cuadrointeresprod;

   /*************************************************************************
       función que modificará los datos técnicos de un producto en concreto
       param in Psproduc  : Código del producto.
       PARAM IN pnniggar  : Indica si los gastos están a nivel de garantía Parámetro de entrada
       PARAM IN pnniigar  : Indicador de si el interés técnico está a nivel de garantía. Parámetro de entrada
       PARAM IN pcmodint  : Intereses tecnicos modificables en póliza.
       PARAM IN pcintrev  : Por defecto en renovación aplicar el interés del producto
       PARAM IN pncodint  : Código del cuadro de interés que se ha escogido para el producto
       param IN out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_set_dattecn(
      psproduc IN NUMBER,
      pnniggar IN NUMBER,
      pnniigar IN NUMBER,
      pcmodint IN NUMBER,
      pcintrev IN NUMBER,
      pncodint IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'PSPRODUC=' || psproduc || ' PNNIGGAR=' || pnniggar || ' PNNIIGAR=' || pnniigar
            || ' PCMODINT=' || pcmodint || ' PCINTREV=' || ' PNCODINT=' || pncodint;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Set_DatTecn';
      num_err        NUMBER;
   BEGIN
      num_err := pac_mntprod.f_validadattecn(psproduc, pnniggar, pnniigar, pcmodint, pcintrev,
                                             pncodint);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      num_err := pac_mntprod.f_set_dattecn(psproduc, pnniggar, pnniigar, pcmodint, pcintrev,
                                           pncodint);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_dattecn;

    /*************************************************************************
        función que recupera la descripción de un cuadro de interés
        PARAM IN PNCODINT  : Código del cuadro de interés que se ha escogido para el producto
        PARAM IN PCIDIOMA  : Código del Idioma
        PARAM IN TNCODINT  : Descripción del cuadro de interés
        param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_get_ncodint(
      pncodint IN NUMBER,
      pcidioma IN NUMBER,
      ptncodint IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400) := ' PCMODINT=' || pncodint;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GET_NCODINT';
      cur            sys_refcursor;
      squery         VARCHAR2(1000);
   BEGIN
      squery := 'select i.cidioma, i.tidioma, d.ncodint,  d.ttexto tncodint '
                || 'from detintertec d, idiomas i where d.cidioma=i.cidioma ';

      IF pncodint <> NULL THEN
         squery := squery || ' and d.ncodint = ' || pncodint;
      END IF;

      IF pcidioma <> NULL THEN
         squery := squery || ' and d.cidioma = ' || pcidioma;
      ELSE
         squery := squery || ' and d.cidioma =' || pac_md_common.f_get_cxtidioma();
      END IF;

      IF ptncodint <> NULL THEN
         squery := ' and ( upper( d.ttexto) like UPPER(''%' || ptncodint || '%'')';
      END IF;

      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_ncodint;

     /*************************************************************************
        función que se encargará de borrar un cuadro de interés técnico
        PARAM IN PNCODINT  : Código del cuadro de interés que se ha escogido para el producto
        param out mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_del_intertec(pncodint IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400) := ' PCMODINT=' || pncodint;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_DEL_INTERTEC';
      num_err        NUMBER;
   BEGIN
      num_err := pac_mntprod.f_del_intertec(pncodint);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_intertec;

    /*************************************************************************
    función que se encargará de borrar una vigencia de un cuadro de interés técnico
    PARAM IN PNCODINT   : Código del cuadro de interés que se ha escogido para el producto
    PARAM IN PCTIPO     : Código del tipo de interés.
    PARAM IN PFINICIO   : Fecha inicio vigencia del tramo.
   *************************************************************************/
   FUNCTION f_del_intertecmov(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
               := ' PCMODINT=' || pncodint || ' PCTIPO=' || pctipo || ' PFINICIO=' || pfinicio;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.f_del_intertecmov';
      num_err        NUMBER;
   BEGIN
      num_err := pac_mntprod.f_del_intertecmov(pncodint, pctipo, pfinicio);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_intertecmov;

    /*************************************************************************
        Función que se encargará de borrar una vigencia de un cuadro de interés técnico
        PARAM IN PNCODINT  : Código del cuadro de interés
        PARAM IN PCTIPO    : Código del tipo de interés.
        PARAM IN PFINICIO  : Fecha inicio vigencia del tramo.
        PARAM IN PNDESDE   : importe/edad desde
        PARAM OUT mensajes : mensajes de error
   *************************************************************************/
   FUNCTION f_del_intertecmovdet(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pndesde IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := ' PCMODINT=' || pncodint || ' PCTIPO=' || pctipo || ' PFINICIO=' || pfinicio
            || ' PNDESDE=' || pndesde;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.f_del_intertecmovdet';
      num_err        NUMBER;
   BEGIN
      num_err := pac_mntprod.f_del_intertecmovdet(pncodint, pctipo, pfinicio, pndesde);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_intertecmovdet;

    /*************************************************************************
    función que se encargará de recuperar la información de una vigencia en concreto para un cuadro de interés.
    PARAM IN PNCODINT   : Código del cuadro de interés que se ha escogido para el producto
    PARAM IN PCTIPO     : Código del tipo de interés.
    PARAM IN PFINICIO   : Fecha inicio vigencia del tramo.
    PARAM OUT PFFIN
    PARAM OUT PCTRAMTIP
    param out mensajes  : mensajes de error
   *************************************************************************/
   FUNCTION f_getreg_intertecmov(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pffin OUT DATE,
      pctramtip OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
               := ' PCMODINT=' || pncodint || ' PCTIPO=' || pctipo || ' PFINICIO=' || pfinicio;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_GETREG_INTERTECMOV';
      num_err        NUMBER;
   BEGIN
      SELECT ffin, ctramtip
        INTO pffin, pctramtip
        FROM intertecmov
       WHERE ncodint = pncodint
         AND ctipo = pctipo
         AND finicio = pfinicio;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_getreg_intertecmov;

    /*************************************************************************
    función que se encarga de validar y grabar una nueva vigencia para un cuadro de interés.
    PARAM IN PNCODINT   : Código del cuadro de interés que se ha escogido para el producto
    PARAM IN PCTIPO     : Código del tipo de interés.
    PARAM IN PFINICIO   : Fecha inicio vigencia del tramo.
    PARAM IN PFFIN      : Fecha fin
    PARAM IN PCTRAMTIP  : Código del concepto del tramo
    param out mensajes  : mensajes de error
   *************************************************************************/
   FUNCTION f_set_intertecmov(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pffin IN DATE,
      pctramtip IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := ' PCMODINT=' || pncodint || ' PCTIPO=' || pctipo || ' PFINICIO=' || pfinicio
            || ' PFFIN=' || pffin || ' PCTRAMTIP=' || pctramtip;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_Set_Intertecmov';
      num_err        NUMBER;
   BEGIN
      num_err := pac_mntprod.f_valida_intertecmov(pncodint, pctipo, pfinicio, pffin,
                                                  pctramtip);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      num_err := pac_mntprod.f_set_intertecmov(pncodint, pctipo, pfinicio, pffin, pctramtip);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_intertecmov;

   /*************************************************************************
   función que nos sirve para recuperar un registro de un tramo en concreto
   PARAM IN PNCODINT    : Código del cuadro de interés que se ha escogido para el producto
   PARAM IN PCTIPO      : Código del tipo de interés.
   PARAM IN PFINICIO    : Fecha inicio vigencia del tramo.
   PARAM IN NDESDE      : Inicio deL tramo
   PARAM OUT NHASTA     : Fin del tramo
   PARAM OUT PNINTTEC   : Porcentaje de interes
   PARAM OUT MENSAJES   : mensajes de error
   *************************************************************************/
   FUNCTION f_getreg_intertecmovdet(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pndesde IN NUMBER,
      pnhasta OUT NUMBER,
      pninttec OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := ' PCMODINT=' || pncodint || ' PCTIPO=' || pctipo || ' PFINICIO=' || pfinicio
            || ' PNDESDE=' || pndesde;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_getreg_intertecmovdet';
      num_err        NUMBER;
   BEGIN
      SELECT nhasta, ninttec
        INTO pnhasta, pninttec
        FROM intertecmovdet
       WHERE ncodint = pncodint
         AND ctipo = pctipo
         AND finicio = pfinicio
         AND ndesde = pndesde;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_getreg_intertecmovdet;

   /*************************************************************************
   función que modifica o da de alta un nuevo tramo
   PARAM IN PNCODINT    : Código del cuadro de interés que se ha escogido para el producto
   PARAM IN PCTIPO      : Código del tipo de interés.
   PARAM IN PFINICIO    : Fecha inicio vigencia del tramo.
   PARAM IN NDESDE      : Inicio deL tramo
   PARAM OUT NHASTA     : Fin del tramo
   PARAM OUT PNINTTEC   : Porcentaje de interes
   PARAM OUT MENSAJES   : mensajes de error
   *************************************************************************/
   FUNCTION f_set_intertecmovdet(
      pncodint IN NUMBER,
      pctipo IN NUMBER,
      pfinicio IN DATE,
      pndesde IN NUMBER,
      pnhasta IN NUMBER,
      pninttec IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := ' PCMODINT=' || pncodint || ' PCTIPO=' || pctipo || ' PFINICIO=' || pfinicio
            || ' PNDESDE=' || pndesde || ' PNHASTA=' || pnhasta || 'PNINTTEC=' || pninttec;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.F_set_intertecmovdet';
      num_err        NUMBER;
   BEGIN
      num_err := pac_mntprod.f_valida_intertecmovdet(pncodint, pctipo, pfinicio, pndesde,
                                                     pnhasta, pninttec);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      num_err := pac_mntprod.f_set_intertecmovdet(pncodint, pctipo, pfinicio, pndesde, pnhasta,
                                                  pninttec);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_intertecmovdet;

   /*******BUG8510-07/01/2008-XCG Afegir funcions************************/
   /*************************************************************************
        Función que INSERTA las actividades seleccionadas previamente.
        PARAM IN PCRAMO   : Código del Ramo del producto
        PARAM IN PCMODALI : Código de la Modalidad del producto
        PARAM IN PCTIPSEG : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT : Código del la Colectividad del producto
        PARAM IN PSPRODUC : Código del Identificador del producto
        PARAM IN PCACTIVI : Código de la Actividad
        PARAM IN OUT MENSAJES : mensajes de error
        RETURN NUMBER(0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_set_actividades(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_MNTROP.F_set_actividades';
      vparam         VARCHAR2(500)
         := 'parámetros - PCRAMO ' || pcramo || ' PCMODALI ' || pcmodali || ' PCTIPSEG '
            || pctipseg || ' PCCOLECT ' || pccolect || ' PSPRODUC ' || psproduc;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
   BEGIN
      --CONTROL DE PARAMETROS DE ENTRADA
      IF pcramo IS NULL THEN
         vparam := 'parametro - pcramo';
         RAISE e_param_error;
      END IF;

      IF pcmodali IS NULL THEN
         vparam := 'parametro - pcmodali';
         RAISE e_param_error;
      END IF;

      IF pctipseg IS NULL THEN
         vparam := 'parametro - pctipseg';
         RAISE e_param_error;
      END IF;

      IF pccolect IS NULL THEN
         vparam := 'parametro - pccolect';
         RAISE e_param_error;
      END IF;

      IF psproduc IS NULL THEN
         vparam := 'parametro - psproduc';
         RAISE e_param_error;
      END IF;

      IF pcactivi IS NULL THEN
         vparam := 'parametro - pcactivi';
         RAISE e_param_error;
      END IF;

      --LLAMADA A LA FUNCIÓN
      vnumerr := pac_mntprod.f_set_actividades(pcramo, pcmodali, pctipseg, pccolect, psproduc,
                                               pcactivi);

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
   END f_set_actividades;

/*************************************************************************
      Función que retorna un objeto con el recargo del fraccionamiento asignado a una actividad de producto.
      PARAM IN PCRAMO        : Código del Ramo del producto
      PARAM IN PCMODALI      : Código de la Modalidad del producto
      PARAM IN PCTIPSEG      : Código del tipo de Seguro del producto
      PARAM IN PCCOLECT      : Código del la Colectividad del producto
      PARAM IN PSPRODUC      : Código del Identificador del producto
      PARAM IN PCACTIVI      : Código de la Actividad
      PARAM IN OUT PREACTIVI : Tipo T_IAX_PRODRECFRACCACTI, recargo de fraccionamiento, según forma de pago,
                                 de una actividad
      PARAM IN OUT MENSAJES : TIPO T_IAX_MENSAJES mensajes de error
      RETURN NUMBER(0: operación correcta sino num error)
*************************************************************************/
   FUNCTION f_get_recactividad(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      preactivi IN OUT t_iax_prodrecfraccacti,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_MNTROP.F_get_reactividad';
      vparam         VARCHAR2(500)
         := 'parámetros - PCRAMO ' || pcramo || ' PCMODALI ' || pcmodali || ' PCTIPSEG '
            || pctipseg || ' PCCOLECT ' || pccolect || ' PSPRODUC ' || psproduc
            || ' PCACTIVI ' || pcactivi;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      vidioma        NUMBER := 1;
      vpreactivi     sys_refcursor;
   BEGIN
      --CONTROL DE PARAMETROS DE ENTRADA
      IF pcramo IS NULL THEN
         vparam := 'parametro - pcramo';
         RAISE e_param_error;
      END IF;

      IF pcmodali IS NULL THEN
         vparam := 'parametro - pcmodali';
         RAISE e_param_error;
      END IF;

      IF pctipseg IS NULL THEN
         vparam := 'parametro - pctipseg';
         RAISE e_param_error;
      END IF;

      IF pccolect IS NULL THEN
         vparam := 'parametro - pccolect';
         RAISE e_param_error;
      END IF;

      IF psproduc IS NULL THEN
         vparam := 'parametro - psproduc';
         RAISE e_param_error;
      END IF;

      IF pcactivi IS NULL THEN
         vparam := 'parametro - pcactivi';
         RAISE e_param_error;
      END IF;

      --LLAMADA A LA FUNCIÓN
      vidioma := pac_md_common.f_get_cxtidioma;

      IF vidioma IS NULL THEN
         vparam := 'parametro - vidioma';
         RAISE e_param_error;
      END IF;

      vnumerr := pac_mntprod.f_get_recactividad(pcramo, pcmodali, pctipseg, pccolect, psproduc,
                                                pcactivi, vidioma, vpreactivi);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      --ASSIGNACIÓ
      preactivi := NEW t_iax_prodrecfraccacti();

      LOOP
         preactivi.EXTEND;
         preactivi(preactivi.COUNT) := ob_iax_prodrecfraccacti();

         FETCH vpreactivi
          INTO preactivi(preactivi.COUNT).cforpag, preactivi(preactivi.COUNT).tforpag,
               preactivi(preactivi.COUNT).precarg;

         EXIT WHEN vpreactivi%NOTFOUND;
      END LOOP;

      preactivi.TRIM;
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
   END f_get_recactividad;

/*************************************************************************
        Función que retorna un objeto con las preguntas definidas a nivel de una actividad de producto.
        PARAM IN PCRAMO      : Código del Ramo del producto
        PARAM IN PCMODALI    : Código de la Modalidad del producto
        PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT    : Código del la Colectividad del producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM IN  PPREGACTIVI  : Tipo T_IAX_PRODPREGUNACTI, Preuntas definidas a nivel de actividad
        PARAM IN OUT MENSAJES : TIPO T_IAX_MENSAJES mensajes de error
        RETURN NUMBER(0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_get_pregactividad(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      ppregactivi IN OUT t_iax_prodpregunacti,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_MNTROP.F_get_pregactividad';
      vparam         VARCHAR2(500)
         := 'parámetros - PCRAMO ' || pcramo || ' PCMODALI ' || pcmodali || ' PCTIPSEG '
            || pctipseg || ' PCCOLECT ' || pccolect || ' PSPRODUC ' || psproduc
            || ' PCACTIVI ' || pcactivi;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      vidioma        NUMBER := 1;
      vppregactivi   sys_refcursor;
   BEGIN
      --CONTROL DE PARAMETROS DE ENTRADA
      IF pcramo IS NULL THEN
         vparam := 'parametro - pcramo';
         RAISE e_param_error;
      END IF;

      IF pcmodali IS NULL THEN
         vparam := 'parametro - pcmodali';
         RAISE e_param_error;
      END IF;

      IF pctipseg IS NULL THEN
         vparam := 'parametro - pctipseg';
         RAISE e_param_error;
      END IF;

      IF pccolect IS NULL THEN
         vparam := 'parametro - pccolect';
         RAISE e_param_error;
      END IF;

      IF psproduc IS NULL THEN
         vparam := 'parametro - psproduc';
         RAISE e_param_error;
      END IF;

      IF pcactivi IS NULL THEN
         vparam := 'parametro - pcactivi';
         RAISE e_param_error;
      END IF;

      --LLAMADA A LA FUNCIÓN
      vidioma := pac_md_common.f_get_cxtidioma;

      IF vidioma IS NULL THEN
         vparam := 'parametro - vidioma';
         RAISE e_param_error;
      END IF;

      vnumerr := pac_mntprod.f_get_pregactividad(pcramo, pcmodali, pctipseg, pccolect,
                                                 psproduc, pcactivi, vidioma, vppregactivi);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      --ASSIGNACIÓ
      ppregactivi := NEW t_iax_prodpregunacti();

      LOOP
         ppregactivi.EXTEND;
         ppregactivi(ppregactivi.COUNT) := ob_iax_prodpregunacti();

         FETCH vppregactivi
          INTO ppregactivi(ppregactivi.COUNT).cpregun, ppregactivi(ppregactivi.COUNT).tpregun,
               ppregactivi(ppregactivi.COUNT).cpretip, ppregactivi(ppregactivi.COUNT).tpretip,
               ppregactivi(ppregactivi.COUNT).cpreobl, ppregactivi(ppregactivi.COUNT).tprefor,
               ppregactivi(ppregactivi.COUNT).tvalfor, ppregactivi(ppregactivi.COUNT).cresdef,
               ppregactivi(ppregactivi.COUNT).tresdef, ppregactivi(ppregactivi.COUNT).cofersn,
               ppregactivi(ppregactivi.COUNT).npreimp;

         EXIT WHEN vppregactivi%NOTFOUND;
      END LOOP;

      ppregactivi.TRIM;
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
   END f_get_pregactividad;

/*************************************************************************
        Función que retorna un objeto con las actividades de un producto.
        PARAM IN PCRAMO      : Código del Ramo del producto
        PARAM IN PCMODALI    : Código de la Modalidad del producto
        PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT    : Código del la Colectividad del producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM IN PPRODACTIVI : Tipo T_IAX_PRODACTIVIDADES
        PARAM IN OUT MENSAJES : TIPO T_IAX_MENSAJES mensajes de error
        RETURN NUMBER(0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_get_actividades(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pprodactivi IN OUT t_iax_prodactividades,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_MNTROP.F_get_actividades';
      vparam         VARCHAR2(500)
         := 'parámetros - PCRAMO ' || pcramo || ' PCMODALI ' || pcmodali || ' PCTIPSEG '
            || pctipseg || ' PCCOLECT ' || pccolect || ' PSPRODUC ' || psproduc
            || ' PCACTIVI ' || pcactivi;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      vidioma        NUMBER := 1;
      vcactivi       NUMBER;
      vtactivi       VARCHAR2(100);
      vpretcursor    sys_refcursor;
      vpreactivi     t_iax_prodrecfraccacti;
      vppregactivi   t_iax_prodpregunacti;
      vparactivi     t_iax_prodparactividad;
   BEGIN
      --CONTROL DE PARAMETROS DE ENTRADA
      IF pcramo IS NULL THEN
         vparam := 'parametro - pcramo';
         RAISE e_param_error;
      END IF;

      IF pcmodali IS NULL THEN
         vparam := 'parametro - pcmodali';
         RAISE e_param_error;
      END IF;

      IF pctipseg IS NULL THEN
         vparam := 'parametro - pctipseg';
         RAISE e_param_error;
      END IF;

      IF pccolect IS NULL THEN
         vparam := 'parametro - pccolect';
         RAISE e_param_error;
      END IF;

      IF psproduc IS NULL THEN
         vparam := 'parametro - psproduc';
         RAISE e_param_error;
      END IF;

      /* DRA:27/05/2014:Inici: Para que no pete si entramos dando de alta un producto sin actividades *
      IF pcactivi IS NULL THEN
         vparam := 'parametro - pcactivi';
         RAISE e_param_error;
      END IF;
      */

      --LLAMADA A LA FUNCIÓN
      vidioma := pac_md_common.f_get_cxtidioma;

      IF vidioma IS NULL THEN
         vparam := 'parametro - vidioma';
         RAISE e_param_error;
      END IF;

      vnumerr := pac_mntprod.f_get_actividades(pcramo, pcmodali, pctipseg, pccolect, psproduc,
                                               pcactivi, vidioma, vpretcursor);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      --ASSIGNACIÓ
      pprodactivi := NEW t_iax_prodactividades();

      LOOP
         FETCH vpretcursor
          INTO vcactivi, vtactivi;

         EXIT WHEN vpretcursor%NOTFOUND;
         pprodactivi.EXTEND;
         pprodactivi(pprodactivi.COUNT) := ob_iax_prodactividades();
         pprodactivi(pprodactivi.COUNT).cactivi := vcactivi;
         pprodactivi(pprodactivi.COUNT).tactivi := vtactivi;
         pprodactivi(pprodactivi.COUNT).paractividad :=
                f_get_paractividad(psproduc, pprodactivi(pprodactivi.COUNT).cactivi, mensajes);

         IF mensajes.LAST > 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, vnumerr);
            RAISE e_object_error;
         END IF;

         vnumerr := f_get_pregactividad(pcramo, pcmodali, pctipseg, pccolect, psproduc,
                                        pprodactivi(pprodactivi.COUNT).cactivi,
                                        pprodactivi(pprodactivi.COUNT).pregunacti, mensajes);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 3, vnumerr);
            RAISE e_object_error;
         END IF;

         vnumerr := f_get_recactividad(pcramo, pcmodali, pctipseg, pccolect, psproduc,
                                       pprodactivi(pprodactivi.COUNT).cactivi,
                                       pprodactivi(pprodactivi.COUNT).recfraccacti, mensajes);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 4, vnumerr);
            RAISE e_object_error;
         END IF;
      END LOOP;

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
   END f_get_actividades;

/*************************************************************************
        Función que inserta datos de la forma de pago y recargo por actividad.
        PARAM IN PCRAMO      : Código del Ramo del producto
        PARAM IN PCMODALI    : Código de la Modalidad del producto
        PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT    : Código del la Colectividad del producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM IN PCFORPAG    : Código de la forma de pago
        PARAM IN PPRECARG    : Porcentage del recargo
        PARAM IN OUT MENSAJE : TIPO T_IAX_MENSAJES mensajes de error
        RETURN NUMBER(0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_set_recactividad(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcforpag IN NUMBER,
      pprecarg IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_MNTROD.F_set_reactividad';
      vidioma        NUMBER := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - PCRAMO ' || pcramo || ' PCMODALI ' || pcmodali || ' PCTIPSEG '
            || pctipseg || ' PCCOLECT ' || pccolect || ' PSPRODUC ' || psproduc
            || ' PCACTIVI ' || pcactivi || '  PCFORPAG  ' || pcforpag || ' PPRECARG '
            || pprecarg;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      vnerror        NUMBER := 0;
   BEGIN
      --CONTROL DE PARAMETROS DE ENTRADA
      IF pcramo IS NULL THEN
         vparam := 'parametro - pcramo';
         RAISE e_param_error;
      END IF;

      IF pcmodali IS NULL THEN
         vparam := 'parametro - pcmodali';
         RAISE e_param_error;
      END IF;

      IF pctipseg IS NULL THEN
         vparam := 'parametro - pctipseg';
         RAISE e_param_error;
      END IF;

      IF pccolect IS NULL THEN
         vparam := 'parametro - pccolect';
         RAISE e_param_error;
      END IF;

      IF psproduc IS NULL THEN
         vparam := 'parametro - psproduc';
         RAISE e_param_error;
      END IF;

      IF pcactivi IS NULL THEN
         vparam := 'parametro - pcactivi';
         RAISE e_param_error;
      END IF;

      IF pcforpag IS NULL THEN
         vparam := 'parametro - pcforpag';
         RAISE e_param_error;
      END IF;

      --LLAMADA A LA FUNCIÓN
      vidioma := pac_md_common.f_get_cxtidioma;

      IF vidioma IS NULL THEN
         vparam := 'parametro - vidioma';
         RAISE e_param_error;
      END IF;

      vnumerr := pac_mntprod.f_set_recactividad(pcramo, pcmodali, pctipseg, pccolect, psproduc,
                                                pcactivi, pcforpag, pprecarg, vnerror);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
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
   END f_set_recactividad;

/*************************************************************************
        Función que se utiliza para comprobar si existen pólizas de una actividad definida en un producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM OUT NERROR     : Código de error
        PARAM IN OUT MENSAJES : TIPO T_IAX_MENSAJES mensajes de error
        RETURN NUMBER(0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_exist_actpol(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_MNTROD.F_exist_actpol';
      vparam         VARCHAR2(800)
                           := 'parámetros - PSPRODUC ' || psproduc || ' PCACTIVI ' || pcactivi;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      vnerror        NUMBER := 0;
   BEGIN
      --CONTROL DE PARAMETROS DE ENTRADA
      IF psproduc IS NULL THEN
         vparam := 'parametro - psproduc';
         RAISE e_param_error;
      END IF;

      IF pcactivi IS NULL THEN
         vparam := 'parametro - pcactivi';
         RAISE e_param_error;
      END IF;

      --LLAMADA A LA FUNCIÓN
      vnumerr := pac_mntprod.f_exist_actpol(psproduc, pcactivi, vnerror);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_exist_actpol;

/*************************************************************************
        Función que inserta preguntas por producto y actividad.
        PARAM IN PCRAMO      : Código del Ramo del producto
        PARAM IN PCMODALI    : Código de la Modalidad del producto
        PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT    : Código del la Colectividad del producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM IN PCPREGUN    : Código de pregunta
        PARAM IN PCPRETIP    : Código tipo de respuesta (manual,automática) valor fijo: 787
        PARAM IN PNPREORD    : Número de orden en el que se pregunta
        PARAM IN PTPREFOR    : Fórmula para plantear la pregunta
        PARAM IN PCPREOBL    : Obligatorio (Sí-1,No-0)
        PARAM IN PNPREIMP    : Orden de impresión
        PARAM IN PCRESDEF    : Respuesta por defecto
        PARAM IN PCOFERSN    : Código: Aparece en ofertas? (Sí-1,No-0)
        PARAM IN PTVALOR     : Fórmula para validar la respuesta
        PARAM IN OUT MENSAJES : TIPO T_IAX_MENSAJES mensajes de error
        RETURN NUMBER(0: operación correcta sino num error)
 *************************************************************************/
   FUNCTION f_set_pregactividad(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcpregun IN NUMBER,
      pcpretip IN NUMBER,
      pnpreord IN NUMBER,
      ptprefor IN VARCHAR2,
      pcpreobl IN NUMBER,
      pnpreimp IN NUMBER,
      pcresdef IN NUMBER,
      pcofersn IN NUMBER,
      ptvalfor IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_MNTROP.F_set_pregactividad';
      vidioma        NUMBER := 1;
      vparam         VARCHAR2(800)
         := 'parámetros - PCRAMO ' || pcramo || ' PCMODALI ' || pcmodali || ' PCTIPSEG '
            || pctipseg || ' PCCOLECT ' || pccolect || ' PSPRODUC ' || psproduc
            || ' PCACTIVI ' || pcactivi || '  PCPREGUN  ' || pcpregun || ' PCPRETIP '
            || pcpretip || ' PNPREORD ' || pnpreord || ' PTPREFOR ' || ptprefor
            || '  PCPREOBL ' || pcpreobl || ' PNPREIMP ' || pnpreimp || ' PCRESDEF '
            || ' PCOFERSN ' || pcofersn || ' PTVALFOR ' || ptvalfor;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      vnerror        NUMBER := 0;
   BEGIN
      --CONTROL DE PARAMETROS DE ENTRADA
      IF pcramo IS NULL THEN
         vparam := 'parametro - pcramo';
         RAISE e_param_error;
      END IF;

      IF pcmodali IS NULL THEN
         vparam := 'parametro - pcmodali';
         RAISE e_param_error;
      END IF;

      IF pctipseg IS NULL THEN
         vparam := 'parametro - pctipseg';
         RAISE e_param_error;
      END IF;

      IF pccolect IS NULL THEN
         vparam := 'parametro - pccolect';
         RAISE e_param_error;
      END IF;

      IF psproduc IS NULL THEN
         vparam := 'parametro - psproduc';
         RAISE e_param_error;
      END IF;

      IF pcactivi IS NULL THEN
         vparam := 'parametro - pcactivi';
         RAISE e_param_error;
      END IF;

      IF pcpregun IS NULL THEN
         vparam := 'parametro - pcpregun';
         RAISE e_param_error;
      END IF;

      IF pcpretip IS NULL THEN
         vparam := 'parametro - pcpretip';
         RAISE e_param_error;
      END IF;

      IF pnpreord IS NULL THEN
         vparam := 'parametro - pnpreord';
         RAISE e_param_error;
      END IF;

      IF ptprefor IS NULL THEN
         vparam := 'parametro - ptprefor';
         RAISE e_param_error;
      END IF;

      IF pnpreimp IS NULL THEN
         vparam := 'parametro - pnpreimp';
         RAISE e_param_error;
      END IF;

      IF pcresdef IS NULL THEN
         vparam := 'parametro - pcresdef';
         RAISE e_param_error;
      END IF;

      IF pcpreobl IS NULL THEN
         vparam := 'parametro - pcpreobl';
         RAISE e_param_error;
      END IF;

      IF pcofersn IS NULL THEN
         vparam := 'parametro - pcofersn';
         RAISE e_param_error;
      END IF;

      IF ptvalfor IS NULL THEN
         vparam := 'parametro - ptvalfor';
         RAISE e_param_error;
      END IF;

      --LLAMADA A LA FUNCIÓN
      vnumerr := pac_mntprod.f_set_pregactividad(pcramo, pcmodali, pctipseg, pccolect,
                                                 psproduc, pcactivi, pcpregun, pcpretip,
                                                 pnpreord, ptprefor, pcpreobl, pnpreimp,
                                                 pcresdef, pcofersn, ptvalfor, vnerror);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
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
   END f_set_pregactividad;

/*************************************************************************
        Función que se utiliza para borrar la actividad definida en un producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM OUT NERROR     : Código de error
        PARAM IN OUT MENSAJES : TIPO T_IAX_MENSAJES mensajes de error
        RETURN NUMBER(0: operación correcta sino num error)
   *************************************************************************/
   FUNCTION f_borrar_actividades(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MD_MNTROP.F_borrar_actividades';
      vidioma        NUMBER := 1;
      vparam         VARCHAR2(50) := 'parámetros - PSPRODUC ' || psproduc;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      vnerror        NUMBER := 0;
   BEGIN
      --CONTROL DE PARAMETROS
      IF psproduc IS NULL THEN
         vparam := 'parametro - psproduc';
         RAISE e_param_error;
      END IF;

      --LLAMADA A LA FUNCIÓN
      vnumerr := pac_mntprod.f_borrar_actividades(psproduc, pcactivi, vnerror);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
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
   END f_borrar_actividades;

/*************************************************************************
        Función que duplica actividad.
        PARAM IN PCRAMO      : Código del Ramo del producto
        PARAM IN PCMODALI    : Código de la Modalidad del producto
        PARAM IN PCTIPSEG    : Código del tipo de Seguro del producto
        PARAM IN PCCOLECT    : Código del la Colectividad del producto
        PARAM IN PSPRODUC    : Código del Identificador del producto
        PARAM IN PCACTIVI    : Código de la Actividad
        PARAM IN PCACTIVIC   : Código de la Actividad destino
        PARAM IN OUT MENSAJES: TIPO T_IAX_MENSAJES mensajes de error
        RETURN NUMBER        : Código de error (0: operación correcta sino 1)
  **********************************************************************/
   FUNCTION f_duplicar_actividades(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcactivic IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MD_MNTROP.f_duplicar_actividades';
      vidioma        NUMBER := 1;
      vparam         VARCHAR2(50);
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
   BEGIN
      --CONTROL DE PARAMETROS DE ENTRADA
      IF pcramo IS NULL THEN
         vparam := 'parametro - pcramo';
         RAISE e_param_error;
      END IF;

      IF pcmodali IS NULL THEN
         vparam := 'parametro - pcmodali';
         RAISE e_param_error;
      END IF;

      IF pctipseg IS NULL THEN
         vparam := 'parametro - pctipseg';
         RAISE e_param_error;
      END IF;

      IF pccolect IS NULL THEN
         vparam := 'parametro - pccolect';
         RAISE e_param_error;
      END IF;

      IF psproduc IS NULL THEN
         vparam := 'parametro - psproduc';
         RAISE e_param_error;
      END IF;

      IF pcactivi IS NULL THEN
         vparam := 'parametro - pcactivi';
         RAISE e_param_error;
      END IF;

      IF pcactivi IS NOT NULL
         AND pcactivic IS NOT NULL
         AND pcactivi = pcactivic THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001461);
         RAISE e_param_error;
      END IF;

      --LLAMADA A LA FUNCIÓN
      vnumerr := pac_mntprod.f_duplicar_actividades(pcramo, pcmodali, pctipseg, pccolect,
                                                    psproduc, pcactivi, pcactivic);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      ELSIF vnumerr = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 111313);
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
   END f_duplicar_actividades;

/*******FI BUG8510************************/

   /*************************************************************************
         Función para asignar cláusulas de beneficiario al producto
         PARAM IN PSPRODUC    : Código del Identificador del producto
         PARAM IN PSCLABEN    : Código de la clausula
         PARAM OUT MENSAJES   : Mensajes de error
         RETURN NUMBER        : Código de error (0: operación correcta sino 1)

         Bug 10557   29/06/2009  AMC
   **********************************************************************/
   FUNCTION f_set_benefpro(psproduc IN NUMBER, psclaben IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTROP.f_set_benefpro';
      vparam         VARCHAR2(400) := ' psproduc:' || psproduc || ' psclaben:' || psclaben;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      vnorden        NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR psclaben IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_mntprod.f_set_benefpro(psproduc, psclaben);

      IF vnumerr <> 0 THEN
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
   END f_set_benefpro;

   /*************************************************************************
          Función para asignar una cláusula de beneficiario por defecto al producto
          PARAM IN PSPRODUC    : Código del Identificador del producto
          PARAM IN PSCLABEN    : Código de la clausula
          PARAM OUT MENSAJES   : Mensajes de error
          RETURN NUMBER        : Código de error (0: operación correcta sino 1)

          Bug 10557   29/06/2009  AMC
    **********************************************************************/
   FUNCTION f_set_benefdefecto(
      psproduc IN NUMBER,
      psclaben IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTROP.F_SET_BENEFDEFECTO';
      vparam         VARCHAR2(400) := ' psproduc:' || psproduc || ' psclaben:' || psclaben;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      vnorden        NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR psclaben IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_mntprod.f_set_benefdefecto(psproduc, psclaben);

      IF vnumerr <> 0 THEN
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
   END f_set_benefdefecto;

   /*************************************************************************
         Función que retorna las cláusulas de beneficirio no asignadas a un producto
         PARAM IN PSPRODUC    : Código del Identificador del producto
         PARAM OUT MENSAJES   : Mensajes de error
         RETURN NUMBER        : Código de error (0: operación correcta sino 1)

         Bug 10557   29/06/2009  AMC
   **********************************************************************/
   FUNCTION f_get_benef_noasig(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTROP.F_GET_BENEF_NOASIG';
      vparam         VARCHAR2(400) := ' psproduc:' || psproduc;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      cur            sys_refcursor;
      squery         VARCHAR2(400);
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_mntprod.f_get_benef_noasig(psproduc, pac_md_common.f_get_cxtidioma());
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_benef_noasig;

   /*************************************************************************
         Función que se utiliza para desasignar una cláusula del producto
         PARAM IN PSPRODUC    : Código del Identificador del producto
         PARAM IN PSCLABEN    : Código de la clausula
         PARAM OUT PNERROR    : Código del error
         PARAM OUT MENSAJES   : Mensajes de error
         RETURN NUMBER        : Código de error (0: operación correcta sino 1)

         Bug 10557   29/06/2009  AMC
   **********************************************************************/
   FUNCTION f_del_benefpro(
      psproduc IN NUMBER,
      psclaben IN NUMBER,
      pnerror OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTROP.F_DEL_BENEFPRO';
      vparam         VARCHAR2(400) := ' psproduc:' || psproduc || ' psclaben:' || psclaben;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR psclaben IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_mntprod.f_del_benefpro(psproduc, psclaben, pnerror);

      IF pnerror IS NOT NULL THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, pnerror, vpasexec, vparam);
         RETURN 1;
      END IF;

      IF vnumerr <> 0 THEN
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
   END f_del_benefpro;

   /*************************************************************************
         Función que asigna una garantia a un producto
         PARAM IN PSPRODUC    : Código del Identificador del producto
         PARAM IN PCGARANT    : Código de la garantia
         PARAM IN PCACTIVI    : Código de la actividad
         PARAM IN PNORDEN     : Numero de orden
         PARAM IN PCTIPGAR    : Código de tipo de garantia
         PARAM IN PCTIPCAR    : Código de tipo de capital
         PARAM IN OUT MENSAJES   : Mensajes de error
         RETURN NUMBER

         Bug 14284   26/04/2010  AMC
   **********************************************************************/
   FUNCTION f_set_garantiaprod(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pnorden IN NUMBER,
      pctipgar IN NUMBER,
      pctipcap IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTPROD.F_SET_GARANTIAPROD';
      vparam         VARCHAR2(400)
         := ' psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:' || pcactivi
            || ' pnorden:' || pnorden || ' pctipgar:' || pctipgar || ' pctipcar:' || pctipcap;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
   BEGIN
      IF psproduc IS NULL
         OR pcgarant IS NULL
         OR pcactivi IS NULL
         OR pnorden IS NULL
         OR pctipgar IS NULL
         OR pctipcap IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_mntprod.f_set_garantiaprod(psproduc, pcgarant, pcactivi, pnorden,
                                                pctipgar, pctipcap);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, vnumerr);
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
   END f_set_garantiaprod;

    /*************************************************************************
         Función que devuelve la lista de parametro por garantia
         PARAM IN PCIDIOMA    : Código de idioma
         PARAM IN OUT MENSAJES   : Mensajes de error
         RETURN sys_refcursor

         Bug 14284   29/04/2010  AMC
   **********************************************************************/
   FUNCTION f_get_pargarantia(pcidioma IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(100) := 'PAC_MD_MNTPROD.f_get_pargarantia';
      vparam         VARCHAR2(400) := ' pcidioma:' || pcidioma;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
      cur            sys_refcursor;
      squery         VARCHAR2(400);
   BEGIN
      cur := pac_mntprod.f_get_pargarantia(NVL(pcidioma, pac_md_common.f_get_cxtidioma()));
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_pargarantia;

   /*************************************************************************
         Función que retorna el tipo de respuesta y la lista de valores de un parametro
         PARAM IN PCPARGAR    : codigo del parametro
         PARAM IN PCIDIOMA    : Código del idioma
         PARAM OUT PCTIPO     : tipo de respuesta
         PARAM OUT PLISTRESP  : lista de posibles respuestas
         PARAM IN OUT MENSAJES   : Mensajes de error
         RETURN sys_refcursor

         Bug 14284   29/04/2010  AMC
   **********************************************************************/
   FUNCTION f_get_valpargarantia(
      pcpargar IN VARCHAR2,
      pcidioma IN NUMBER,
      pctipo OUT NUMBER,
      plistresp OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MD_MNTPROD.f_get_valpargarantia';
      vparam         VARCHAR2(400) := 'pcpargar:' || pcpargar || ' pcidioma:' || pcidioma;
      vpasexec       NUMBER := 1;
      vnumerr        NUMBER := 0;
   BEGIN
      pctipo := pac_mntprod.f_get_ctipoparam(pcpargar);

      IF pctipo IS NULL THEN
         RAISE e_object_error;
      END IF;

      IF pctipo = 2 THEN
         plistresp := pac_mntprod.f_get_valpargarantia(pcpargar,
                                                       NVL(pcidioma,
                                                           pac_md_common.f_get_cxtidioma()));
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
   END f_get_valpargarantia;

   /*************************************************************************
      Inicializa las listas de capitales de una garantia
      param in psproduc  : codigo del producto
      param in pcgarant  : codigo de la garantia
      param in pcactivi  : codigo de la actividad
      param out pcapitales :coleccion con los capitales
      param out mensajes : mensajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error

     Bug 14284 - 05/05/2010 - AMC
   *************************************************************************/
   FUNCTION f_inicializa_capital(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pcapitales OUT t_iax_prodgaranprocap,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_SINIESTROS.F_Inicializa_capital';
      vparam         VARCHAR2(500) := 'parámetros - NULL';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
      capitales      t_iax_prodgaranprocap;
      vnorden        NUMBER;
      vicapital      NUMBER;
      vcdefecto      NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR pcgarant IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_mntprod.f_get_listcapitales(psproduc, pcgarant, pcactivi);
      capitales := t_iax_prodgaranprocap();

      LOOP
         EXIT WHEN cur%NOTFOUND;

         FETCH cur
          INTO vnorden, vicapital, vcdefecto;

         IF vnorden IS NOT NULL THEN
            capitales.EXTEND;
            capitales(capitales.LAST) := ob_iax_prodgaranprocap();
            capitales(capitales.LAST).norden := vnorden;
            capitales(capitales.LAST).icapital := vicapital;
            capitales(capitales.LAST).cdefecto := vcdefecto;
            vnorden := NULL;
            vicapital := NULL;
            vcdefecto := NULL;
         END IF;
      END LOOP;

      CLOSE cur;

      pcapitales := capitales;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
   END f_inicializa_capital;

   /*************************************************************************
      Baja la lista de capitales a BB.DD
      param in psproduc  : codigo del producto
      param in pcgarant  : codigo de la garantia
      param in pcactivi  : codigo de la actividad
      param in pcapitales : lista de capitales a guardar
      param out          : mensajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error

     Bug 14284 - 05/05/2010 - AMC
   *************************************************************************/
   FUNCTION f_set_capitales(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pcapitales IN t_iax_prodgaranprocap,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_SINIESTROS.f_set_obj_capital';
      vparam         VARCHAR2(500)
         := 'parámetros - psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:'
            || pcactivi;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR pcgarant IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := f_def_producto(psproduc, vcramo, vcmodali, vctipseg, vccolect);
      vnumerr := pac_mntprod.f_del_capitales(vcramo, vcmodali, vctipseg, vccolect, pcgarant,
                                             pcactivi);

      IF pcapitales IS NOT NULL
         AND pcapitales.COUNT > 0 THEN
         FOR i IN pcapitales.FIRST .. pcapitales.LAST LOOP
            vnumerr := pac_mntprod.f_set_capital(vcramo, vcmodali, vctipseg, vccolect,
                                                 pcgarant, pcactivi, pcapitales(i).norden,
                                                 pcapitales(i).icapital,
                                                 pcapitales(i).cdefecto);

            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         END LOOP;
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
   END f_set_capitales;

   /*************************************************************************
         Función que actualiza los datos generales de la garantia
         param in psproduc  : codigo del producto
         param in pcgarant  : codigo de la garantia
         param in pcactivi  : codigo de la actividad
         param in pnorden   : numero de orden
         param in pctipgar  : codigo tipo de garantia
         param in pctipcap  : codigo tipo de capital
         param in pcgardep  : codigo garantia dependiente
         param in pcpardep  : codigo parametro dependiente
         param in pcvalpar  : valor parametro dependiente
         param in pctarjet
         param in pcbasica
         param in picapmax  : importe capital maximo
         param in pccapmax  : codigo capital maximo
         param in pcformul  : codigo de formula
         param in pcclacap  :
         param in picaprev  : capital de revision
         param in ppcapdep  :
         param in piprimin  : prima minima
         param in piprimax  : capital maximo
         param in picapmin  : capital minimo
         param in out mensajes : mensajes de error
         RETURN number

         Bug 14284   07/05/2010  AMC
   **********************************************************************/
   FUNCTION f_set_datosgen(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pnorden IN NUMBER,
      pctipgar IN NUMBER,
      pctipcap IN NUMBER,
      pcgardep IN NUMBER,
      pcpardep IN VARCHAR2,
      pcvalpar IN NUMBER,
      pctarjet IN NUMBER,
      pcbasica IN NUMBER,
      picapmax IN NUMBER,
      pccapmax IN NUMBER,
      pcformul IN NUMBER,
      pcclacap IN NUMBER,
      picaprev IN NUMBER,
      ppcapdep IN NUMBER,
      piprimin IN NUMBER,
      piprimax IN NUMBER,
      pccapmin IN NUMBER,
      picapmin IN NUMBER,
      pcclamin IN NUMBER,
      pcmoncap IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MD_MNTPROD.f_set_datosgen';
      vparam         VARCHAR2(1000)
         := 'psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:' || pcactivi
            || ' pnorden:' || pnorden || ' pctipgar:' || pctipgar || ' pctipcap:' || pctipcap
            || ' pcgardep:' || pcgardep || ' pcpardep:' || pcpardep || ' pcvalpar:'
            || pcvalpar || ' pctarjet:' || pctarjet || ' pcbasica:' || pcbasica
            || ' picapmax:' || picapmax || ' pccapmax:' || pccapmax || ' pcformul:'
            || pcformul || ' pcclacap:' || pcclacap || ' picaprev:' || picaprev
            || ' ppcapdep:' || ppcapdep || ' piprimin:' || piprimin || ' piprimax:'
            || piprimax || ' pccapmin:' || pccapmin || ' picapmin:' || picapmin || 'pcclamin'
            || pcclamin || 'pcmoncap' || pcmoncap;
      vpasexec       NUMBER := 1;
      verror         NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR pcgarant IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_mntprod.f_set_datosgen(psproduc, pcgarant, pcactivi, pnorden, pctipgar,
                                           pctipcap, pcgardep, pcpardep, pcvalpar, pctarjet,
                                           pcbasica, picapmax, pccapmax, pcformul, pcclacap,
                                           picaprev, ppcapdep, piprimin, piprimax, pccapmin,
                                           picapmin, pcclamin, pcmoncap);

      IF verror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, verror);
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
   END f_set_datosgen;

   /**********************************************************************
         Función que borrar una garantia asignada a un producto
         param in psproduc  : codigo del producto
         param in pcgarant  : codigo de la garantia
         param in pcactivi  : código de la actividad
         param in mensajes  : mensajes de error
         RETURN number

         Bug 14723 -  25/05/2010 - AMC
   **********************************************************************/
   FUNCTION f_del_garantia(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MD_MNTPROD.f_del_garantia';
      vparam         VARCHAR2(1000)
           := 'psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivii:' || pcactivi;
      vpasexec       NUMBER := 1;
      verror         NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR pcgarant IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_mntprod.f_del_garantia(psproduc, pcactivi, pcgarant);

      IF verror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, verror);
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
   END f_del_garantia;

   /*************************************************************************
         Función que actualiza los datos generales de la garantia
         param in psproduc  : codigo del producto
         param in pcgarant  : codigo de la garantia
         param in pcactivi  : codigo de la actividad
         param in pciedmic  : Ind. si se valida la 0-edad actuarial 1-edad real. Edad Min. Ctnr.
         param in pnedamic  : Edad mínima de contratación
         param in pciedmac  : Ind. si se valida la 0-edad actuarial 1-edad real. Edad Max. Ctnr.
         param in pnedamac, : Edad máxima de contratación
         param in pciedmar  : Ind. si se valida la 0-edad actuarial 1-edad real. Edad Max. Renov.
         param in pnedamar  : Edad máxima de renovación
         param in pciemi2c  : Ind. si se valida la 0-edad actuarial 1-edad real. Cuando se informa Edad Min. Ctnr. 2ºAsegurado
         param in pnedmi2c, : Edad Min. Ctnr. 2ºAsegurado
         param in pciema2c, : Ind. si se valida la 0-edad actuarial 1-edad real. Cuando se informa Edad Max. Ctnr. 2ºAsegurado
         param in pnedma2c  : Edad Max. Ctnr. 2ºAsegurado
         param in pciema2r  : Ind. si se valida la 0-edad actuarial 1-edad real. Cuando se informa Edad Max. Renov. 2ºAsegurado
         param in pnedma2r  : Edad Max. Renov. 2ºAsegurado
         param in pcreaseg
         param in pcrevali  : Tipo de revalorización
         param in pctiptar  : Tipo de tarifa (lista de valores)
         param in pcmodrev  : Se puede modificar la revalorización
         param in pcrecarg  : Se puede añadir un recargo
         param in pcdtocom  : Admite descuento comercial
         param in pctecnic
         param in pcofersn
         param in pcextrap  : Se puede modificar la extraprima
         param in pcderreg
         param in pprevali  : Porcentaje de revalorización
         param in pirevali  : Importe de revalorización
         param in pcrecfra
         param in pctarman
         param in pnedamrv : Edad máxima de revalorización
         param in pciedmrv : Ind. si se valida la 0-edad actuarial 1-edad real. Edad Max. Revalorización
         param out mensajes : mensajes de error
         RETURN number

         Bug 14748   04/06/2010  AMC
   **********************************************************************/
   FUNCTION f_set_datosges(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pciedmic IN NUMBER,
      pnedamic IN NUMBER,
      pciedmac IN NUMBER,
      pnedamac IN NUMBER,
      pciedmar IN NUMBER,
      pnedamar IN NUMBER,
      pciemi2c IN NUMBER,
      pnedmi2c IN NUMBER,
      pciema2c IN NUMBER,
      pnedma2c IN NUMBER,
      pciema2r IN NUMBER,
      pnedma2r IN NUMBER,
      pcreaseg IN NUMBER,
      pcrevali IN NUMBER,
      pctiptar IN NUMBER,
      pcmodrev IN NUMBER,
      pcrecarg IN NUMBER,
      pcdtocom IN NUMBER,
      pctecnic IN NUMBER,
      pcofersn IN NUMBER,
      pcextrap IN NUMBER,
      pcderreg IN NUMBER,
      pprevali IN NUMBER,
      pirevali IN NUMBER,
      pcrecfra IN NUMBER,
      pctarman IN NUMBER,
      pnedamrv IN NUMBER,
      pciedmrv IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MNTPROD.f_set_datosges';
      vparam         VARCHAR2(1000)
         := ' psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:' || pcactivi
            || ' ciedmic:' || pciedmic || ' nedamic:' || pnedamic || ' ciedmac:' || pciedmac
            || ' nedamac:' || pnedamac || ' ciedmar:' || pciedmar || ' nedamar:' || pnedamar
            || ' ciemi2c:' || pciemi2c || ' nedmi2c:' || pnedmi2c || ' ciema2c:' || pciema2c
            || ' nedma2c:' || pnedma2c || ' ciema2r:' || pciema2r || ' nedma2r:' || pnedma2r
            || ' creaseg:' || pcreaseg || ' crevali:' || pcrevali || ' ctiptar:' || pctiptar
            || ' cmodrev:' || pcmodrev || ' crecarg:' || pcrecarg || ' cdtocom:' || pcdtocom
            || ' ctecnic:' || pctecnic || ' cofersn:' || pcofersn || ' cextrap:' || pcextrap
            || ' cderreg:' || pcderreg || ' prevali:' || pprevali || ' irevali:' || pirevali
            || ' crecfra:' || pcrecfra || ' pctarman:' || pctarman || ' pnedamrv:' || pnedamrv
            || ' pciedmrv:' || pciedmrv;
      vpasexec       NUMBER := 1;
      verror         NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR pcgarant IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_mntprod.f_set_datosges(psproduc, pcgarant, pcactivi, pciedmic, pnedamic,
                                           pciedmac, pnedamac, pciedmar, pnedamar, pciemi2c,
                                           pnedmi2c, pciema2c, pnedma2c, pciema2r, pnedma2r,
                                           pcreaseg, pcrevali, pctiptar, pcmodrev, pcrecarg,
                                           pcdtocom, pctecnic, pcofersn, pcextrap, pcderreg,
                                           pprevali, pirevali, pcrecfra, pctarman, pnedamrv,
                                           pciedmrv);

      IF verror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, verror);
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
   END f_set_datosges;

   /*************************************************************************
      Recupera las garantias que peden ser incompatibles
      param in psproduc     : código del producto
      param in pcactivi     : código de la actividad
      param in pcgarant     : código de la garantia
      param in out mensajes   : mensajes de error
      RETURN sys_refcursor

      -- Bug 15023 - 16/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_lstgarincompatibles(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
            := 'psproduc=' || psproduc || ' pcactivi=' || pcactivi || ' pcgarant=' || pcgarant;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.f_get_lstgarincompatibles';
      squery         VARCHAR2(1000);
   BEGIN
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      squery := 'select g.cgarant, ga.tgarant' || ' from  garanpro g, garangen ga'
                || ' where g.cactivi = ' || pcactivi || ' and g.SPRODUC =' || psproduc
                || ' and g.cgarant not in (select cgarinc'
                || ' from incompgaran i, productos p' || ' WHERE p.cramo = i.cramo'
                || ' AND p.cmodali = i.cmodali' || ' AND p.ctipseg = i.ctipseg'
                || ' AND p.ccolect = i.ccolect' || ' AND i.cactivi =' || pcactivi
                || ' AND i.cgarant =' || pcgarant || ' AND p.sproduc =' || psproduc || ')'
                || ' and g.CGARANT <>' || pcgarant || ' and g.CGARANT = ga.CGARANT'
                || ' and ga.CIDIOMA =' || pac_md_common.f_get_cxtidioma;
      cur := pac_md_listvalores.f_opencursor(squery, mensajes);
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
   END f_get_lstgarincompatibles;

   /*************************************************************************
         Función que inserta en incompgaran
         PARAM IN PSPRODUC     : codigo del producto
         PARAM IN PCGARANT    : codigo de la garantia
         PARAM IN PCGARANT    : codigo de la garantia incompatible
         PARAM IN PCACTIVI    : codigo de la actividad
         PARAM IN OUT MENSAJES   : mensajes de error

         RETURN NUMBER

         Bug 15023   16/06/2010  AMC
   **********************************************************************/
   FUNCTION f_set_incompagar(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcgarinc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MD_MNTPROD.f_set_incompagar';
      vparam         VARCHAR2(400)
         := 'psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:' || pcactivi
            || ' pcgarinc:' || pcgarinc;
      vpasexec       NUMBER := 1;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      verror         NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR pcgarant IS NULL
         OR pcgarinc IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_mntprod.f_set_incompagar(psproduc, pcgarant, pcgarinc, pcactivi);

      IF verror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, verror);
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
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_incompagar;

   /*************************************************************************
         Función que borra de incompgaran
         PARAM IN PSPRODUC     : codigo del producto
         PARAM IN PCGARANT    : codigo de la garantia
         PARAM IN PCGARANT    : codigo de la garantia incompatible
         PARAM IN PCACTIVI    : codigo de la actividad
         PARAM IN OUT MENSAJES   : mensajes de error

         RETURN NUMBER

         Bug 15023   16/06/2010  AMC
   **********************************************************************/
   FUNCTION f_del_incompagar(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcgarinc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MD_MNTPROD.f_del_incompagar';
      vparam         VARCHAR2(400)
         := 'psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:' || pcactivi
            || ' pcgarinc:' || pcgarinc;
      vpasexec       NUMBER := 1;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      verror         NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR pcgarant IS NULL
         OR pcgarinc IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_mntprod.f_del_incompagar(psproduc, pcgarant, pcgarinc, pcactivi);

      IF verror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, verror);
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
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_incompagar;

   /*************************************************************************
         Función que actualiza los datos tecnicos de la garantia
         param in psproduc  : codigo del producto
         param in pcgarant  : codigo de la garantia
         param in pcactivi  : codigo de la actividad
         param in pcramdgs  : código del ramo de la dgs
         param in pctabla   : código de la tabla de mortalidad
         param in precseg   : % recargo de seguridad
         param in nparben   : participación en beneficios
         param in out mensajes   : mensajes de error

         RETURN number

         Bug 15148 - 21/06/2010 - AMC
   **********************************************************************/
   FUNCTION f_set_datostec(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pcramdgs IN NUMBER,
      pctabla IN NUMBER,
      pprecseg IN NUMBER,
      pnparben IN NUMBER,
      pcprovis IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MD_MNTPROD.f_set_datostec';
      vparam         VARCHAR2(1000)
         := ' psproduc:' || psproduc || ' pcgarant:' || pcgarant || ' pcactivi:' || pcactivi
            || ' cramdgs:' || pcramdgs || ' ctabla:' || pctabla || ' precseg:' || pprecseg
            || ' nparben:' || pnparben || ' cprovis:' || pcprovis;
      vpasexec       NUMBER := 1;
      verror         NUMBER;
   BEGIN
      IF psproduc IS NULL
         OR pcgarant IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_mntprod.f_set_datostec(psproduc, pcgarant, pcactivi, pcramdgs, pctabla,
                                           pprecseg, pnparben, pcprovis);

      IF verror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, verror);
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
   END f_set_datostec;

   /*************************************************************************
      Borra la formula de una garantia
      param in psproduc    : código del producto
      param in pcactivi    : código de la actividad
      param in pcgarant    : código de la garantía
      param in pccampo     : código del campo
      param in pclave      : clave fórmula
      param out mensajes   : mensajes de error
      return               : 0 si ha ido bien
                            numero error si ha ido mal

      Bug 15149 - 29/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_del_prodgarformulas(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'Psproduc=' || psproduc || ' Pcactivi=' || pcactivi || ' Pcgarant=' || pcgarant
            || ' Pccampo=' || pccampo || ' Pclave=' || pclave;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.f_del_prodgarformulas';
      nerror         NUMBER := 0;
   BEGIN
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pcgarant IS NULL
         OR pccampo IS NULL
         OR pclave IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerror := pac_mntprod.f_del_prodgarformulas(psproduc, pcactivi, pcgarant, pccampo,
                                                  pclave);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, nerror, vpasexec, vparam);
         RAISE e_object_error;
      END IF;

      RETURN nerror;
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
   END f_del_prodgarformulas;

      /*************************************************************************
         Inserta un nuevo producto en la tabla PRODUCTOS
         param in pcramo    : codigo del ramo
         param in pcmodali  : codigo de la modalidad
         param in pctipseg  : codigo del tipo de seguro
         param in pccolect  : codigo de colectividad
         param in pcagrpro  : codigo agrupacion de producto
         param in pttitulo  : titulo del producto
         param in ptrotulo  : abreviacion del titulo
         param in pcsubpro  : codigo de subtipo de producto
         param in pctipreb  : recibo por.
         param in pctipges  : gestion del seguro
         param in pctippag  : cobro
         param in pcduraci  : codigo de la duración
         param in pctarman  : tarificacion puede ser manual
         param in pctipefe  : tipo de efecto
         param out psproduct_out  : codigo del producto insertado
         param out mensajes  : mensajes de error

         Bug 15513 - 23/07/2010 - PFA
   *************************************************************************/
   FUNCTION f_alta_producto(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcagrpro IN NUMBER,
      pttitulo IN VARCHAR2,
      ptrotulo IN VARCHAR2,
      pcsubpro IN NUMBER,
      pctipreb IN NUMBER,
      pctipges IN NUMBER,
      pctippag IN NUMBER,
      pcduraci IN NUMBER,
      pctarman IN NUMBER,
      pctipefe IN NUMBER,
      psproduc_copy IN NUMBER,
      pparproductos IN NUMBER,
      psproduc_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_MD_MNTPROD.f_alta_producto';
      vparam         VARCHAR2(1000)
         := 'pcramo: ' || pcramo || ' pcmodali: ' || pcmodali || ' pctipseg: ' || pctipseg
            || ' pccolect: ' || pccolect || ' pcagrpro: ' || pcagrpro || ' pttitulo: '
            || pttitulo || ' ptrotulo: ' || ptrotulo || ' pcsubpro: ' || pcsubpro
            || ' pctipreb: ' || pctipreb || ' pctipges: ' || pctipges || ' pctippag: '
            || pctippag || ' pcduraci: ' || pcduraci || ' pctarman: ' || pctarman
            || ' pctipefe: ' || pctipefe;
      vpasexec       NUMBER := 1;
      verror         NUMBER;
      vcidioma       NUMBER;
      ptinfo         t_iax_info;
   BEGIN
      vcidioma := pac_md_common.f_get_cxtidioma;

      IF pcramo IS NULL
         OR pcmodali IS NULL
         OR pctipseg IS NULL
         OR pccolect IS NULL
         OR pcagrpro IS NULL
         OR pttitulo IS NULL
         OR ptrotulo IS NULL
         OR pcsubpro IS NULL
         OR pctipreb IS NULL
         OR pctipges IS NULL
         OR pctippag IS NULL
         OR pcduraci IS NULL
         OR pctarman IS NULL
         OR pctipefe IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'PETICION_CODIGOS'),
             0) = 1 THEN
         ptinfo := t_iax_info();
         ptinfo.EXTEND;
         ptinfo(ptinfo.LAST) := ob_iax_info;
         ptinfo(ptinfo.LAST).nombre_columna := 'idRequest';
         ptinfo(ptinfo.LAST).valor_columna := 'SPRODUC';
         ptinfo.EXTEND;
         ptinfo(ptinfo.LAST) := ob_iax_info;
         ptinfo(ptinfo.LAST).nombre_columna := 'cempres';
         ptinfo(ptinfo.LAST).valor_columna := pac_md_common.f_get_cxtempresa;
         ptinfo.EXTEND;
         ptinfo(ptinfo.LAST) := ob_iax_info;
         ptinfo(ptinfo.LAST).nombre_columna := 'cramo';
         ptinfo(ptinfo.LAST).valor_columna := pcramo;
         ptinfo.EXTEND;
         ptinfo(ptinfo.LAST) := ob_iax_info;
         ptinfo(ptinfo.LAST).nombre_columna := 'cidioma';
         ptinfo(ptinfo.LAST).valor_columna := pac_md_common.f_get_cxtidioma;
         ptinfo.EXTEND;
         ptinfo(ptinfo.LAST) := ob_iax_info;
         ptinfo(ptinfo.LAST).nombre_columna := 'ccolect';
         ptinfo(ptinfo.LAST).valor_columna := pccolect;
         ptinfo.EXTEND;
         ptinfo(ptinfo.LAST) := ob_iax_info;
         ptinfo(ptinfo.LAST).nombre_columna := 'cmodali';
         ptinfo(ptinfo.LAST).valor_columna := pcmodali;
         ptinfo.EXTEND;
         ptinfo(ptinfo.LAST) := ob_iax_info;
         ptinfo(ptinfo.LAST).nombre_columna := 'ctipseg';
         ptinfo(ptinfo.LAST).valor_columna := pctipseg;
         verror := pac_md_codigos.f_get_codigos(ptinfo, psproduc_out, mensajes);

         IF verror <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
            RAISE e_object_error;
         END IF;
      END IF;

      verror := pac_mntprod.f_alta_producto(pcramo, pcmodali, pctipseg, pccolect, pcagrpro,
                                            vcidioma, pttitulo, ptrotulo, pcsubpro, pctipreb,
                                            pctipges, pctippag, pcduraci, pctarman, pctipefe,
                                            psproduc_copy, pparproductos, psproduc_out);

      IF verror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
         RAISE e_object_error;
      END IF;

      RETURN verror;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_alta_producto;

    /*************************************************************************
         Función que retorna els documentos d'un producte
         param in psproduc  : codigo del producto

         RETURN sys_refcursor

         Bug 14284   29/04/2010  AMC
   **********************************************************************/
   FUNCTION f_get_documentos(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(100) := 'PAC_MD_MNTPROD.f_get_documentos';
      vparam         VARCHAR2(1000) := 'pcramo: ' || psproduc;
      vpasexec       NUMBER := 1;
      verror         NUMBER;
      vcidioma       NUMBER;
      cur            sys_refcursor;
   BEGIN
      vcidioma := pac_md_common.f_get_cxtidioma;

      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_mntprod.f_get_documentos(psproduc, vcidioma);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_documentos;

   /**************************************************************************
     Assigna un pla de pensió per un producte. Si existe, lo actualiza
     param in psproduc     : Codigo del producto
     param in pccodpla    : Codigo del plan de pensión
   **************************************************************************/
   FUNCTION f_set_planpension(
      psproduc IN NUMBER,
      pccodpla IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                           := 'parámetros - psproduc:' || psproduc || ' pccodpla=' || pccodpla;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.f_set_planpension';
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF psproduc IS NULL
         OR pccodpla IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_mntprod.f_set_planpension(psproduc, pccodpla);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
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
   END f_set_planpension;

   /*************************************************************************
            Función que retorna las duraciones de cobro de un producto
            param in psproduc  : codigo del producto

            RETURN t_iax_durcobroprod

            Bug 22253   17/05/2012   MDS
      **********************************************************************/
   FUNCTION f_get_durcobroprod(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_durcobroprod IS
      vobjectname    VARCHAR2(100) := 'PAC_MD_MNTPROD.f_get_durcobroprod';
      vparam         VARCHAR2(1000) := 'psproduc: ' || psproduc;
      vpasexec       NUMBER := 1;
      cur            sys_refcursor;
      tdurcobroprod  t_iax_durcobroprod;
      v_ndurcob      durcobroprod.ndurcob%TYPE;
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_mntprod.f_get_durcobroprod(psproduc);
      tdurcobroprod := t_iax_durcobroprod();

      LOOP
         EXIT WHEN cur%NOTFOUND;

         FETCH cur
          INTO v_ndurcob;

         IF v_ndurcob IS NOT NULL THEN
            tdurcobroprod.EXTEND;
            tdurcobroprod(tdurcobroprod.LAST) := ob_iax_durcobroprod();
            tdurcobroprod(tdurcobroprod.LAST).ndurcob := v_ndurcob;
            v_ndurcob := NULL;
         END IF;
      END LOOP;

      CLOSE cur;

      RETURN tdurcobroprod;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_durcobroprod;

   /*************************************************************************
         Función que mantiene la tabla int_codigos_emp
         PARAM IN CCODIGO     : codigo de la interfaz
         PARAM IN CVALAXIS    : valor del campo en axis
         PARAM IN CVALEMP    : valor del campo en la empresa
         PARAM OUT MENSAJES   : mensajes de error

         RETURN NUMBER

         Bug 15023   01/11/2013  LPP
   **********************************************************************/
   FUNCTION f_get_interficie(
      pccodigo IN VARCHAR2,
      pcvalaxis IN VARCHAR2,
      pcvalemp IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_interficies IS
      vnumerr        NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pccodigo:' || pccodigo || ' pcvalemp=' || pcvalemp || ' pcvalaxis='
            || pcvalaxis;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.f_get_interficie';
   BEGIN
      vpasexec := 1;
      RETURN pac_mntprod.f_get_interficie(pccodigo, pcvalaxis, pcvalemp, mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END f_get_interficie;

   /*************************************************************************
         Función que mantiene la tabla int_codigos_emp
         PARAM IN CCODIGO     : codigo de la interfaz
         PARAM IN CVALAXIS    : valor del campo en axis
         PARAM IN CVALEMP    : valor del campo en la empresa
         PARAM IN CVALDEF    : valor del campo en axis, por si cvalaxis tiene mas de un valor
         PARAM IN CVALAXISDEF : valor del campo en la empresa, por si cvalaxisdef tiene mas de un valor
         PARAM OUT MENSAJES   : mensajes de error

         RETURN NUMBER

         Bug 15023   01/11/2013  LPP
   **********************************************************************/
   FUNCTION f_set_interficie(
      pccodigo IN VARCHAR2,
      pcvalaxis IN VARCHAR2,
      pcvalemp IN VARCHAR2,
      pcvaldef IN VARCHAR2,
      pcvalaxisdef IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pccodigo:' || pccodigo || ' pcvalemp=' || pcvalemp || ' pcvalaxis='
            || pcvalaxis || ' pcvaldef=' || pcvaldef || ' pcvalaxisdef=' || pcvalaxisdef;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.f_set_interficie';
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pccodigo IS NULL
         OR pcvalaxis IS NULL
         OR pcvalemp IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_mntprod.f_set_interficie(pccodigo, pcvalaxis, pcvalemp, pcvaldef,
                                              pcvalaxisdef, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
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
   END f_set_interficie;

   /*************************************************************************
         Función que borra de la tabla int_codigos_emp
         PARAM IN CCODIGO     : codigo de la interfaz
         PARAM IN CVALAXIS    : valor del campo en axis
         PARAM OUT MENSAJES   : mensajes de error

         RETURN NUMBER

         Bug 15023   01/11/2013  LPP
   **********************************************************************/
   FUNCTION f_del_interficie(
      pccodigo IN VARCHAR2,
      pcvalaxis IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                         := 'parámetros - pccodigo:' || pccodigo || ' pcvalaxis=' || pcvalaxis;
      vobject        VARCHAR2(200) := 'PAC_MD_MNTPROD.f_del_interficie';
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pccodigo IS NULL
         OR pcvalaxis IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_mntprod.f_del_interficie(pccodigo, pcvalaxis, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
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
   END f_del_interficie;

   /**************************************************************************
    ffunción que recupera los fondos asociados al modelo que se ha recibido por parámetro.
    param in psproduc      :
    param in pcmodinv      :
    param in pmodelo      :
    param in mensajes      :
    **************************************************************************/
   FUNCTION f_get_modelinv(
      psproduc IN NUMBER,
      pcmodinv IN NUMBER,
      pmodelo IN t_iax_produlkmodelosinv,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vquery         VARCHAR2(1000);
   BEGIN
      vquery :=
         'SELECT minv.CRAMO,minv.CMODALI,minv.CTIPSEG,minv.CCOLECT,minv.CMODINV,minv.FINICIO,minv.FFIN FROM MODELOSINVERSION minv,PRODUCTOS prod
            WHERE minv.CRAMO = prod.CRAMO AND minv.CMODALI= prod.CMODALI AND minv.CTIPSEG= prod.CTIPSEG AND minv.CCOLECT = prod.CCOLECT AND SPRODUC ='
         || psproduc;

      OPEN cur FOR vquery;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;
   END f_get_modelinv;

   FUNCTION f_set_modelinv(
      psproduc IN NUMBER,
      pcmodinv IN NUMBER,
      pcidioma IN NUMBER,
      ptmodinv IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      verror         NUMBER := 1;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
   BEGIN
      SELECT cramo, cmodali, ctipseg, ccolect
        INTO vcramo, vcmodali, vctipseg, vccolect
        FROM productos
       WHERE sproduc = psproduc;

      verror := pac_mntprod.f_set_modelinv(vcramo, vcmodali, vccolect, vctipseg, pcmodinv,
                                           pcidioma, ptmodinv, mensajes);
      RETURN verror;
   END f_set_modelinv;

      /**************************************************************************
       función que recupera los fondos asociados a un modelo de inversión.
       param in psproduc      :
       param in pcmodinv     :
       param in mensajes     :
       **************************************************************************/
   /*  FUNCTION  f_get_modinvfondo(
       psproduc IN NUMBER,
      pcmodinv IN NUMBER,
       mensajes IN OUT T_IAX_MENSAJES
     )RETURN T_IAX_PRODULKMODINVFONDO IS
     vquery VARCHAR(1000);
     cur sys_refcursor;
     vlinea  ob_iax_produlkmodinvfondo := ob_iax_produlkmodinvfondo();
     vmodinvfondo t_iax_produlkmodinvfondo = t_iax_produlkmodinvfondo();
     BEGIN

              vquery:='SELECT mif.CCODFON,mif.PINVERS,mif.PMAXCONT
                          FROM MODELOSINVERSION minv,
                               PRODUCTOS prod,
                               MODINVFONDO mif
                          WHERE
                              minv.CRAMO = prod.CRAMO AND
                              minv.CRAMO = mif.CRAMO AND
                              minv.CMODALI= prod.CMODALI AND
                              minv.CMODALI = mif.CMODALI AND
                              minv.CTIPSEG= prod.CTIPSEG AND
                              minv.CTIPSEG = mif.CTIPSEG AND
                              minv.CCOLECT = prod.CCOLECT AND
                              minv.CCOLECT = mif.CCOLECT AND
                              minv.CMODINV = mif.CMODINV AND
                              prod.SPRODUC ='||psproduc ||'  AND'||
                              'mif.CMODINV ='||pcmodinv;
                  open cur for vquery;
           LOOP

              FETCH cur INTO vlinea.CCODFON,vlinea.PINVERS,vlinea.PMAXCONT,vlinea.TCODFON;



              EXIT WHEN cur%NOTFOUND;
              vmodinvfondo.EXTEND;
              vmodinvfondo(vmodinvfondo.LAST):=vlinea;
              vlinea:= ob_iax_produlkmodinvfondo();

           END LOOP;


           CLOSE cur;

           RETURN vmodinvfondo;
      EXCEPTION
          WHEN OTHERS THEN
               pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                             NULL, SQLCODE, SQLERRM);
                RETURN NULL;

     END   f_get_modinvfondo;*/
      /**************************************************************************
       función que recupera los fondos asociados y no asociados a un modelo de inversión.
       param in psproduc      :
       param in pcmodinv     :
       param in mensajes     :
       **************************************************************************/
   FUNCTION f_get_modinvfondos(
      psproduc IN NUMBER,
      pcmodinv IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_produlkmodinvfondo IS
      vquery         VARCHAR2(1500);
      cur            sys_refcursor;
      vlinea         ob_iax_produlkmodinvfondo := ob_iax_produlkmodinvfondo();
      vmodinvfondo   t_iax_produlkmodinvfondo := t_iax_produlkmodinvfondo();
      vcobliga       NUMBER;
      vasociado      NUMBER;
      vobject        VARCHAR2(50) := 'PAC_MD_MNTPROD.f_get_modinvfondos';
      vpasexec       NUMBER;
      vparam         VARCHAR2(100) := psproduc || '#' || pcmodinv;
   BEGIN
      vquery :=
         'SELECT ccodfon, pinvers, pmaxcont, TFONABV,tfoncmp ,cobliga from
                     (SELECT f.ccodfon, mif.pinvers,mif.pmaxcont,f.TFONABV,f.tfoncmp ,0 cobliga
                     FROM MODINVFONDO mif,
                          FONDOS f, productos p
                     WHERE f.cempres = '
         || f_empres || ' AND p.sproduc=' || psproduc
         || ' AND p.CCOLECT = mif.CCOLECT AND p.cramo = mif.cramo AND mif.CMODALI = p.cmodali AND mif.CTIPSEG = p.ctipseg
                                AND  mif.CCODFON = f.ccodfon AND mif.CMODINV ='
         || pcmodinv
         || ' AND mif.pinvers is null
                     UNION ALL
                      SELECT f.ccodfon, mif.pinvers,mif.pmaxcont,f.TFONABV,f.tfoncmp ,1 cobliga
                     FROM MODINVFONDO mif,
                          FONDOS f, productos p
                     WHERE
                             f.cempres = '
         || f_empres || ' AND p.sproduc=' || psproduc
         || ' AND p.CCOLECT = mif.CCOLECT AND p.cramo = mif.cramo AND mif.CMODALI = p.cmodali AND mif.CTIPSEG = p.ctipseg
                                AND  mif.CCODFON = f.ccodfon AND mif.CMODINV ='
         || pcmodinv
         || ' and mif.pinvers is not null )
                                 order by 6 desc ,4 asc, 5 asc';
      vpasexec := 1;

      OPEN cur FOR vquery;

      LOOP
         FETCH cur
          INTO vlinea.ccodfon, vlinea.pinvers, vlinea.pmaxcont, vlinea.tcodfon,
               vlinea.tcodfonl, vlinea.cobliga;

         vpasexec := 2;
         EXIT WHEN cur%NOTFOUND;
         vmodinvfondo.EXTEND;
         vmodinvfondo(vmodinvfondo.LAST) := vlinea;
         vlinea := ob_iax_produlkmodinvfondo();
      END LOOP;

      vpasexec := 2;

      CLOSE cur;

      RETURN vmodinvfondo;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_modinvfondos;

     /**************************************************************************
   función que recupera los fondos asociados y no asociados a un modelo de inversión.
   param in psproduc      :
   param in pcmodinv     :
   param in mensajes     :
   **************************************************************************/
   FUNCTION f_get_modinvfondos2(
      psproduc IN NUMBER,
      pcmodinv IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_produlkmodinvfondo IS
      vquery         VARCHAR2(1500);
      cur            sys_refcursor;
      vlinea         ob_iax_produlkmodinvfondo := ob_iax_produlkmodinvfondo();
      vmodinvfondo   t_iax_produlkmodinvfondo := t_iax_produlkmodinvfondo();
      vcobliga       NUMBER;
      vasociado      NUMBER;
      vobject        VARCHAR2(50) := 'PAC_MD_MNTPROD.f_get_modinvfondos2';
      vpasexec       NUMBER;
      vparam         VARCHAR2(100) := 'psproduc=' || psproduc || ' pcmodinv=' || pcmodinv;
   BEGIN
      vquery :=
         'SELECT ccodfon,pinvers,pmaxcont,tfonabv,tfoncmp,cobliga FROM ('
         || '  SELECT f.ccodfon, mif.pinvers,mif.pmaxcont,f.tfonabv,f.tfoncmp,0 as cobliga '
         || '      FROM modinvfondo mif, fondos f ' || '       WHERE f.cempres = ' || f_empres
         || ' AND mif.ccodfon(+) = f.ccodfon AND mif.cmodinv(+) =' || NVL(pcmodinv, -999)
         || ' AND mif.pinvers IS NULL ' || ' UNION ALL '
         || '   SELECT f.ccodfon, mif.pinvers,mif.pmaxcont,f.tfonabv,f.tfoncmp,1 as cobliga '
         || '     FROM modinvfondo mif, fondos f, productos p ' || '     WHERE f.cempres = '
         || f_empres || ' AND mif.ccodfon(+) = f.ccodfon AND mif.cmodinv(+) ='
         || NVL(pcmodinv, -999) || ' AND mif.pinvers IS NOT NULL ' || ' AND p.sproduc='
         || psproduc || ' AND p.ccolect = mif.ccolect AND p.cramo = mif.cramo '
         || ' AND mif.cmodali = p.cmodali AND mif.ctipseg = p.ctipseg '
         || ' ) ORDER BY 6 DESC ,4 ASC, 5 ASC';
      vpasexec := 1;

      OPEN cur FOR vquery;

      LOOP
         FETCH cur
          INTO vlinea.ccodfon, vlinea.pinvers, vlinea.pmaxcont, vlinea.tcodfon,
               vlinea.tcodfonl, vlinea.cobliga;

         EXIT WHEN cur%NOTFOUND;
         vmodinvfondo.EXTEND;
         vmodinvfondo(vmodinvfondo.LAST) := vlinea;
         vlinea := ob_iax_produlkmodinvfondo();
      END LOOP;

      vpasexec := 2;

      CLOSE cur;

      RETURN vmodinvfondo;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_modinvfondos2;

   /**************************************************************************
     función que modifica o inserta los fondos asociados y no asociados a un modelo de inversión.
     param in psproduc      :
     param in pcmodinv     :
     param in mensajes     :
     **************************************************************************/
   FUNCTION f_set_modinvfondos(
      psproduc IN NUMBER,
      pcmodinv IN NUMBER,
      pfondo IN t_iax_produlkmodinvfondo,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      pccodfon       NUMBER;
      v_error_nproceso EXCEPTION;
      v_error_porcent EXCEPTION;
      v_error_porcent_max EXCEPTION;
      vpinvers       NUMBER;
      vmaxcont       NUMBER;
      vpinverssum    NUMBER := 0;
      n_error        NUMBER := 0;
      vobject        VARCHAR2(50) := 'PAC_MD_MNTPROD.f_set_modinvfondos';
      vpasexec       NUMBER;
      vparam         VARCHAR(100) := psproduc || '#' || pcmodinv;
      modinvfondo_row ob_iax_produlkmodinvfondo := ob_iax_produlkmodinvfondo();
   BEGIN
      FOR x IN pfondo.FIRST .. pfondo.LAST LOOP
         n_error := pac_mntprod.f_set_modinvfondo(psproduc, pfondo(x).ccodfon,
                                                  pfondo(x).pinvers, pcmodinv,
                                                  pfondo(x).pmaxcont, mensajes);
      END LOOP;

      --        END IF;
      RETURN n_error;
   EXCEPTION
      WHEN v_error_porcent_max THEN
         RETURN 9902398;
      WHEN v_error_nproceso THEN
         RETURN 1000005;
      WHEN OTHERS THEN
         RETURN 1000005;
   END f_set_modinvfondos;

   /**************************************************************************
     función que borra el fondo correspondiente a  un modelo de inversión recibido por parámetro
     param in pccodfon    :
     param in pinvers    :
     param in out mensajes    :
     **************************************************************************/
   FUNCTION f_del_modinvfondos(
      pccodfon IN NUMBER,
      pcmodinv IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      verror         NUMBER;
   BEGIN
      verror := pac_mntprod.f_del_modinvfondos(pccodfon, pcmodinv, mensajes);
      RETURN verror;
   END f_del_modinvfondos;

   FUNCTION f_get_modinvfondosseg(pcmodinv IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_produlkmodinvfondo IS
      vquery         VARCHAR2(2500);
      cur            sys_refcursor;
      vlinea         ob_iax_produlkmodinvfondo := ob_iax_produlkmodinvfondo();
      vmodinvfondo   t_iax_produlkmodinvfondo := t_iax_produlkmodinvfondo();
      vsproduc       seguros.sproduc%TYPE;
      vsseguro       seguros.sseguro%TYPE;
      vuniact        NUMBER := 0;
      vicestas       NUMBER := 0;
      vprovshw       NUMBER := 0;
      vuniactshw     NUMBER := 0;
      vicestasshw    NUMBER := 0;
      vnumerr        NUMBER;
      vprovision     NUMBER := 0;
   BEGIN
      vquery :=
         '
                SELECT ccodfon, pinvers,tfonabv,tfoncmp,cmodabo,cobliga from (
                SELECT f.ccodfon, mif.pinvers,f.TFONABV, f.tfoncmp, NULL as cmodabo, 0 cobliga
                     FROM MODINVFONDO mif,
                          FONDOS f
                     WHERE
                          f.cempres = '
         || f_empres || ' AND mif.CCODFON(+) = f.ccodfon AND mif.CMODINV =' || pcmodinv
         || '
                          and not exists (select ccesta from estsegdisin2 where sseguro ='
         || NVL(pac_iax_produccion.vsolicit, 0)
         || ' and f.ccodfon = ccesta and nmovimi in (select max(nmovimi) from estsegdisin2 where sseguro ='
         || NVL(pac_iax_produccion.vsolicit, 0)
         || '))
                          and not exists (select ccesta from segdisin2 where sseguro = '
         || NVL(pac_iax_produccion.vsseguro, 0)
         || ' and f.ccodfon = ccesta  and nmovimi in (select max(nmovimi) from segdisin2 where sseguro = '
         || NVL(pac_iax_produccion.vsseguro, 0)
         || ') )
                 UNION
                    SELECT f.ccodfon, s.pdistrec as pinvers,f.TFONABV, f.tfoncmp, s.cmodabo , 1 cobliga
                             FROM MODINVFONDO mif,
                                  FONDOS f, estsegdisin2 s
                                   where f.cempres = '
         || f_empres || ' AND mif.CCODFON(+) = f.ccodfon AND mif.CMODINV =' || pcmodinv
         || '
                                            AND s.CCESTA = f.ccodfon AND s.SSEGURO ='
         || NVL(pac_iax_produccion.vsolicit, 0)
         || ' and nmovimi in (select max(nmovimi) from estsegdisin2 where sseguro ='
         || NVL(pac_iax_produccion.vsolicit, 0)
         || ')
                  UNION
                         SELECT f.ccodfon, s.pdistrec as pinvers,f.TFONABV, f.tfoncmp, s.cmodabo, 1 cobliga
                             FROM MODINVFONDO mif,
                                  FONDOS f, segdisin2 s where f.cempres = '
         || f_empres || '  AND mif.CCODFON(+) = f.ccodfon AND mif.CMODINV = ' || pcmodinv
         || '
                                           AND s.CCESTA = f.ccodfon AND s.SSEGURO = '
         || NVL(pac_iax_produccion.vsseguro, 0)
         || ' and nmovimi in (select max(nmovimi) from segdisin2 where sseguro = '
         || NVL(pac_iax_produccion.vsseguro, 0)
         || ')

                                           ) order by cobliga desc, tfonabv asc, tfoncmp asc';

      OPEN cur FOR vquery;

      LOOP
         FETCH cur
          INTO vlinea.ccodfon, vlinea.pinvers, vlinea.tcodfon, vlinea.tcodfonl,
               vlinea.cmodabo, vlinea.cobliga;

         EXIT WHEN cur%NOTFOUND;

         BEGIN
            SELECT sseguro, sproduc
              INTO vsseguro, vsproduc
              FROM estseguros
             WHERE sseguro = pac_iax_produccion.vsolicit;
         EXCEPTION
            WHEN OTHERS THEN
               BEGIN
                  SELECT sseguro, sproduc
                    INTO vsseguro, vsproduc
                    FROM seguros
                   WHERE sseguro = pac_iax_produccion.vsseguro;
               EXCEPTION
                  WHEN OTHERS THEN
                     vsseguro := NULL;
                     vsproduc := NULL;
               END;
         END;

         IF vsseguro IS NOT NULL THEN
            vnumerr := pac_operativa_finv.f_cta_saldo_fondos_cesta(vsseguro, TRUNC(f_sysdate),
                                                                   vlinea.ccodfon, vuniact,
                                                                   vicestas, vprovision);

            IF NVL(pac_ctaseguro.f_tiene_ctashadow(NULL, vsproduc), 0) = 1 THEN
               vnumerr := pac_operativa_finv.f_cta_saldo_fondos_cesta_shw(vsseguro,
                                                                          TRUNC(f_sysdate),
                                                                          vlinea.ccodfon,
                                                                          vuniactshw,
                                                                          vicestasshw,
                                                                          vprovshw);

               IF NVL(vuniactshw, vuniact) < vuniact THEN
                  vuniact := vuniactshw;
               END IF;

               IF NVL(vicestasshw, vicestas) < vicestas THEN
                  vicestas := vicestasshw;
               END IF;
            END IF;

            vlinea.nuniact := vuniact;
            vlinea.ivalact := vicestas;
         END IF;

         vmodinvfondo.EXTEND;
         vmodinvfondo(vmodinvfondo.LAST) := vlinea;
         vlinea := ob_iax_produlkmodinvfondo();
      END LOOP;

      CLOSE cur;

      RETURN vmodinvfondo;
   END f_get_modinvfondosseg;
END pac_md_mntprod;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTPROD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTPROD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MNTPROD" TO "PROGRAMADORESCSI";
