--------------------------------------------------------
--  DDL for Package Body PAC_IAXPAR_PRODUCTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAXPAR_PRODUCTOS" AS
   /******************************************************************************
      NOMBRE:       PAC_IAXPAR_PRODUCTOS
      PROPOSITO: Recupera la parametrizacion del producto devolviendo los objectos

      REVISIONES:
      Ver        Fecha        Autor             Descripcion
      ---------  ----------  ------------ ------------------------------------
      1.0        06/09/2007   ACC          1. Creacion del package.
      2.0        21/11/2007   ACC          2. Nuevas funcionalidades
      3.0        16/02/2009   SBG          3. Creacio funcio f_get_pregtipgru (Bug 6296)
      4.0        15/04/2009   DRA          4. BUG0009661: APR - Tipo de revalorizacion a nivel de producto
      5.0        28/04/2009   DRA          5. 0009906: APR - Ampliar la parametritzacio de la revaloracio a nivell de garantia
      6.0        28/05/2009   ETM          6. BUG0009855: CEM - Configuraciones varias de Escut Basic
      7.0        24/04/2009   FAL          7. Parametrizar causas de anulacion de poliza en funcion del tipo de baja. Bug 9686.
      8.0        18/12/2009   JMF          8. 0012227 AGA - Adaptar profesiones con empresa y producto
      9.0        15/01/2010   NMM          9. 12674: CRE087 - Producto ULK- Eliminar pantalla beneficiarios de wizard de contratacion
     10.0        03/02/2010   DRA          10. 0012760: CRE200 - Consulta de polizas: mostrar preguntas automaticas.
     11.0        03/01/2012   JMF          11. 0020671: LCOL_T001-LCOL - UAT - TEC: Contrataci?n
     12.0        27/01/2012   JMC          12. 0022011: AGM101 - Correcci�n de incidencias detectadas en AGM
     13.0        09/12/2015   FAL          13. 0036730: I - Producto Subsidio Individual
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   ------- Funcions metodos internos

   /***********************************************************************
      Define las claves de definicion del producto
      param out mensajes : mensajes de error
   ***********************************************************************/
   PROCEDURE pkproduct(sproduc IN NUMBER, mensajes IN OUT t_iax_mensajes) IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'sproduc=' || sproduc;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.PKPRODUCT';
      vramo          NUMBER(8);
      vmodali        NUMBER(2);
      vtipseg        NUMBER(2);
      vcolect        NUMBER(2);
      v_error        NUMBER;
   BEGIN
      v_error := pac_mdpar_productos.f_get_identprod(sproduc, vramo, vmodali, vtipseg,
                                                     vcolect, mensajes);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      END IF;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END pkproduct;

   -------

   /***********************************************************************
      Inicializa producto
      param in sproduc   : codigo de productos
      param in cmodali   : codigo modalidad
      param in cempres   : codigo empresa
      param in cidioma   : codigo idioma
      param in ccolect   : codigo de colectividad
      param in cramo     : codigo de ramo
      param in ctipseg   : codigo tipo de seguro
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   ***********************************************************************/
   FUNCTION f_inicializa(
      sproduc IN NUMBER,
      cmodali IN NUMBER,
      cempres IN NUMBER,
      cidioma IN NUMBER,
      ccolect IN NUMBER,
      cramo IN NUMBER,
      ctipseg IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'sproduc=' || sproduc || ' cmodali=' || cmodali || ' cempres=' || cempres
            || ' cidioma=' || cidioma || ' ccolect=' || ccolect || ' cramo=' || cramo
            || ' ctipseg=' || ctipseg;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Inicializa';
   BEGIN
      vproducto := sproduc;
      vmodalidad := cmodali;
      vempresa := cempres;
      vidioma := cidioma;
      vccolect := ccolect;
      vcramo := cramo;
      vctipseg := ctipseg;

      IF cmodali IS NULL
         OR ccolect IS NULL
         OR cramo IS NULL
         OR ctipseg IS NULL THEN
         pkproduct(sproduc, mensajes);
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
   END f_inicializa;

   /***********************************************************************
      Devuelve el parametro de producto especificado
      return   : valor del parametro
   ***********************************************************************/
   FUNCTION f_get_parproducto(clave IN VARCHAR2, psproduc IN NUMBER)
      RETURN NUMBER IS
      mensajes       t_iax_mensajes;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_ParProducto';
   BEGIN
      RETURN pac_mdpar_productos.f_get_parproducto(clave, psproduc);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 0;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 0;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 0;
   END f_get_parproducto;

    --JRH 03/2008
   /***********************************************************************
      Devuelve el parametro de garantÃ­a especificado
      param in clave: El nombre del parametro
      psproduc in clave: El producto
      pgarant in clave: La garantÃ­a
      return   : valor del parametro
   ***********************************************************************/
   FUNCTION f_get_pargarantia(
      clave IN VARCHAR2,
      psproduc IN productos.sproduc%TYPE,
      pgarant IN NUMBER,
      pcactivi IN NUMBER DEFAULT 0)   -- BUG 0036730 - FAL - 09/12/2015
      RETURN NUMBER IS
      mensajes       t_iax_mensajes;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_ParGarantia';
   BEGIN
      RETURN pac_mdpar_productos.f_get_pargarantia(clave, psproduc, pgarant, pcactivi);   -- BUG 0036730 - FAL - 09/12/2015
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 0;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 0;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 0;
   END f_get_pargarantia;

   /***********************************************************************
      Devuelve el codigo del subtipo de producto VF 37
      return   : codigo del subtipo de producto
   ***********************************************************************/
   FUNCTION f_get_subtipoprod(psproduc IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_SubtipoProd';
      vcsubpro       NUMBER;
      mensajes       t_iax_mensajes;
   BEGIN
      vcsubpro := pac_mdpar_productos.f_get_subtipoprod(psproduc);
      RETURN vcsubpro;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 0;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 0;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 0;
   END f_get_subtipoprod;

   -- BUG 0008695 - 28-01-09 - jmf - 0008695: IAX - Control del nÃºmero maximo de tomadores
   -- Esta funcion indica el nÃºmero de tomadores admitidos para el producto.
   -- Por defecto 99.
   FUNCTION f_permitirmultitomador
      RETURN NUMBER IS
      nretorno       NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_PermitirMultiTomador';
      mensajes       t_iax_mensajes;
   BEGIN
      nretorno := f_get_parproducto('NUM_TOMADORES', vproducto);

      IF nretorno = 0 THEN
         nretorno := 99;
      END IF;

      RETURN nretorno;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 0;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 0;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 0;
   END f_permitirmultitomador;

   /***********************************************************************
      Indica si se permite tener multiples asegurados en la poliza
      return   : 1 indica que se permite
                 0 que no se permite
   ***********************************************************************/
   FUNCTION f_permitirmultiaseg
      RETURN NUMBER IS
      vcsubpro       NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_PermitirMultiAseg';
      mensajes       t_iax_mensajes;
   BEGIN
      IF f_get_parproducto('2_CABEZAS', vproducto) = 1 THEN   -- 2 CABEZAS ACC040308
         RETURN 1;
      END IF;

      vcsubpro := f_get_subtipoprod(vproducto);

      IF vcsubpro = 1 THEN   -- Individual   ->   1 risc 1 asegurat
         RETURN 0;
      ELSIF vcsubpro = 2 THEN   --ColÂ·lectiu simple   ->   n risc n asegurats
         RETURN 1;
      ELSIF vcsubpro = 3 THEN   --ColÂ·lectiu individualitzat   ->   n Polisses 1 risc 1 asegurats
         RETURN 0;
      ELSIF vcsubpro = 5 THEN   --Individual 2 cabezas   ->   1 risc 2 asegurats
         RETURN 0;
      END IF;

      RETURN vcsubpro;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 0;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 0;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 0;
   END f_permitirmultiaseg;

   /***********************************************************************
      Indica si se permite tener multiples riesgos en la poliza
      return   : 1 indica que se permite
                 0 que no se permite
   ***********************************************************************/
   FUNCTION f_permitirmultiriesgos
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_PermitirMultiRiesgos';
      mensajes       t_iax_mensajes;
   BEGIN
      RETURN f_permitirmultiaseg;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 0;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 0;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 0;
   END f_permitirmultiriesgos;

   /***********************************************************************
      Establece el codigo de actividad para el producto
   ***********************************************************************/
   PROCEDURE p_set_prodactiviti(pcactivi IN NUMBER) IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'pcactivi=' || pcactivi;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.P_Set_ProdActiviti';
      mensajes       t_iax_mensajes;
   BEGIN
      vcactivi := pcactivi;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_set_prodactiviti;

   /***********************************************************************
      Recupera las formas de pago del producto
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_formapago(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_FormaPago';
   BEGIN
      cur := pac_mdpar_productos.f_get_formapago(vproducto, mensajes);
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
   END f_get_formapago;

   /***********************************************************************
      Recupera las duraciones del producto
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_tipduracion(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_GET_TipDuracion';
   BEGIN
      cur := pac_mdpar_productos.f_get_tipduracion(vproducto, mensajes);
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
   END f_get_tipduracion;

   /***********************************************************************
      Recupera las preguntas a nivel de poliza
      param out mensajes : mensajes de error
      return             : objeto preguntas
   ***********************************************************************/
   FUNCTION f_get_pregpoliza(mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_preguntas IS
      preg           t_iaxpar_preguntas;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_PregPoliza';
   BEGIN
      preg := pac_mdpar_productos.f_get_pregpoliza(vproducto, pac_iax_produccion.issimul,
                                                   pac_iax_produccion.issuplem, mensajes);   --etm BUG 9855 - 28/05/2009 - Se aÃ±ade pac_iax_produccion.issimul
      RETURN preg;
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
   END f_get_pregpoliza;

   /***********************************************************************
      Recupera los datos del riesgo (preguntas)
      param out mensajes : mensajes de error
      return             : objeto preguntas
   ***********************************************************************/
   FUNCTION f_get_datosriesgos(mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_preguntas IS
      preg           t_iaxpar_preguntas;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_DatosRiesgos';
   BEGIN
      preg := pac_mdpar_productos.f_get_datosriesgos(vproducto, vcactivi,
                                                     pac_iax_produccion.issimul, mensajes);   --BUG9427-30032009-XVM
      RETURN preg;
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
   END f_get_datosriesgos;

   /***********************************************************************
      Recupera las preguntas a nivel de garantia
      param in  cgarant  : codigo de garantia
      param out mensajes : mensajes de error
      return             : objeto preguntas
   ***********************************************************************/
   FUNCTION f_get_preggarant(cgarant IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_preguntas IS
      preg           t_iaxpar_preguntas;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_PregGarant';
   BEGIN
      preg := pac_mdpar_productos.f_get_preggarant(vproducto, vcactivi, cgarant, mensajes);
      RETURN preg;
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
   END f_get_preggarant;

   /***********************************************************************
      Recupera el Tipo de pregunta (detvalores.cvalor = 78)
      param in  pcpregun : codigo de pregunta
      param out mensajes : mensajes de error
      return             : Tipo de pregunta (detvalores.cvalor = 78)
   ***********************************************************************/
   FUNCTION f_get_pregtippre(pcpregun IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'cpregun= ' || pcpregun;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_PregTipPre';
   BEGIN
      RETURN pac_mdpar_productos.f_get_pregtippre(pcpregun, mensajes);
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
   END f_get_pregtippre;

   /***********************************************************************
      Recupera si la pregunta es automatica/manual (detvalores.cvalor = 787)
      param in  pcpregun : codigo de pregunta
      param in  tipo     : indica si son preguntas POL RIE GAR
      param in  pcactivi : codigo actividad
      param in  pcgarant : codigo garantia
      param out mensajes : mensajes de error
      return             : Tipo de pregunta (detvalores.cvalor = 787)
   ***********************************************************************/
   FUNCTION f_get_pregunautomatica(
      pcpregun IN NUMBER,
      tipo IN VARCHAR2,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1500)
         := 'cpregun= ' || pcpregun || ' tipo= ' || tipo || ' pcactivi= ' || pcactivi
            || ' pcgarant= ' || pcgarant;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_PregunAutomatica';
   BEGIN
      RETURN pac_mdpar_productos.f_get_pregunautomatica(pcpregun, vproducto, tipo, pcactivi,
                                                        pcgarant, mensajes);
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
   END f_get_pregunautomatica;

   /***********************************************************************
      Recupera las clausulas del beneficiario
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_claubenefi(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_ClauBenefi';
   BEGIN
      cur := pac_mdpar_productos.f_get_claubenefi(vproducto, mensajes);
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
   END f_get_claubenefi;

   /***********************************************************************
      Devuelve la descripcion de una clausula de beneficiarios
      param in  sclaben  : codigo de la clausula
      param out mensajes : mensajes de error
      return             : descripcion garantia
   ***********************************************************************/
   FUNCTION f_get_descclausulaben(sclaben IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      dclausu        VARCHAR2(600);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_DescClausulaBen';
   BEGIN
      dclausu := pac_mdpar_productos.f_get_descclausulaben(sclaben, mensajes);
      RETURN dclausu;
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
   END f_get_descclausulaben;

   -- BUG9661:DRA:15/04/2009: Inici
   /***********************************************************************
      Recupera los tipos de revalorizacion
      param in  p_sproduc: codigo del producto
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_tipreval(p_sproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'p_sproduc: ' || p_sproduc;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_TipReval';
   BEGIN
      cur := pac_mdpar_productos.f_get_tipreval(p_sproduc, mensajes);
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
   END f_get_tipreval;

   -- BUG9661:DRA:15/04/2009: Fi

   /***********************************************************************
      Devuelve las clausulas
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_clausulas(mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_clausulas IS
      clau           t_iaxpar_clausulas;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_Clausulas';
   BEGIN
      pkproduct(vproducto, mensajes);
      clau := pac_mdpar_productos.f_get_clausulas(vcramo, vmodalidad, vctipseg, vccolect,
                                                  mensajes);
      RETURN clau;
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
   END f_get_clausulas;

   /***********************************************************************
      Devuelve las clausulas multiples
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_clausulasmult(mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_clausulas IS
      clau           t_iaxpar_clausulas;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_Clausulasmult';
   BEGIN
      pkproduct(vproducto, mensajes);
      clau := pac_mdpar_productos.f_get_clausulasmult(vcramo, vmodalidad, vctipseg, vccolect,
                                                      mensajes);
      RETURN clau;
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
   END f_get_clausulasmult;

   /***********************************************************************
      Devuelve la descripcion de una clausula
      param in  sclagen  : codigo de la clausula
      param out mensajes : mensajes de error
      return             : descripcion garantia
   ***********************************************************************/
   FUNCTION f_get_descclausula(sclagen IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      dclausu        VARCHAR2(4000);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_DescClausula';
   BEGIN
      dclausu := pac_mdpar_productos.f_get_descclausula(sclagen, mensajes);
      RETURN dclausu;
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
   END f_get_descclausula;

   /***********************************************************************
      Devuelve las garantias
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_garantias(pnriesgo NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_garantias IS
      garan          t_iaxpar_garantias;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_Garantias';
   BEGIN
      vparam := ' pnriesgo: ' || pnriesgo;
      garan := pac_mdpar_productos.f_get_garantias(vproducto, vcactivi, pnriesgo, mensajes);
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

   /***********************************************************************
      Devuelve las lista garantias
      param in psproduc  : codigo producto
      param in pcactivi  : codigo actividad
      param out mensajes : mensajes de error
      return             : objeto garantias
   ***********************************************************************/
   FUNCTION f_get_lstgarantias(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_garantias IS
      garan          t_iaxpar_garantias := t_iaxpar_garantias();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psproduc=' || psproduc || ' pcactivi=' || pcactivi;
      vcursor        sys_refcursor;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_LstGarantias';
      v_cgarant      NUMBER;
      v_tgarant      VARCHAR2(500);
   BEGIN
      vcursor := pac_mdpar_productos.f_get_lstgarantias(psproduc, pcactivi, NULL, mensajes);

      LOOP
         FETCH vcursor
          INTO v_cgarant, v_tgarant;

         EXIT WHEN vcursor%NOTFOUND;
         garan.EXTEND;
         garan(garan.LAST) := ob_iaxpar_garantias();
         garan(garan.LAST).cgarant := v_cgarant;
         garan(garan.LAST).descripcion := v_tgarant;
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
   END f_get_lstgarantias;

   /***********************************************************************
      Devuelve la descripcion de una garantia
      param in  cgarant  : codigo de la garantia
      param out mensajes : mensajes de error
      return             : descripcion garantia
   ***********************************************************************/
   FUNCTION f_get_descgarant(cgarant IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      dgarant        VARCHAR2(120) := NULL;   --bug:22011 - JMC - 27/06/2012
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_DescGarant';
   BEGIN
      dgarant := pac_mdpar_productos.f_get_descgarant(cgarant, mensajes);
      RETURN dgarant;
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
   END f_get_descgarant;

   /***********************************************************************
      Devuelve la descripcion de una pregunta
      param in  cpregun  : codigo de la pregunta
      param out mensajes : mensajes de error
      return             : descripcion pregunta
   ***********************************************************************/
   FUNCTION f_get_descpregun(pcpregun IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vtpregun       VARCHAR2(300) := NULL;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_DescPregun';
   BEGIN
      vtpregun := pac_mdpar_productos.f_get_descpregun(pcpregun,
                                                       pac_md_common.f_get_cxtidioma,
                                                       mensajes);
      RETURN vtpregun;
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
   END f_get_descpregun;

   /***********************************************************************
      Devuelve la respuesta de una pregunta
      param in  psproduc : codigo producto
      param in  pcpregun : codigo de la pregunta
      param in  pcrespue : codigo de la respuesta
      param out mensajes : mensajes de error
      return             : descripcion pregunta
   ***********************************************************************/
   -- Bug 0012227 - 18/12/2009 - JMF: Afegir sproduc
   FUNCTION f_get_pregunrespue(
      psproduc IN NUMBER,
      pcpregun IN NUMBER,
      pcrespue IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
          := 'psproduc= ' || psproduc || ' pcpregun= ' || pcpregun || ' pcrespue=' || pcrespue;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_PregunRespue';
   BEGIN
      RETURN pac_mdpar_productos.f_get_pregunrespue(psproduc, pcpregun, pcrespue,
                                                    pac_md_common.f_get_cxtidioma, mensajes);
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
   END f_get_pregunrespue;

   /***********************************************************************
      Devuelve el tipo de garantia
      param in  cgarant  : codigo de la garantia
      param in psproduc  : codigo de producto (default null)
      param out mensajes : mensajes de error
      return             : descripcion garantia
   ***********************************************************************/
   FUNCTION f_get_tipgar(
      pcgarant IN NUMBER,
      psproduc IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      RESULT         NUMBER;
      vsproduc       NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_TipGar';
   BEGIN
      IF NVL(psproduc, -1) <> -1 THEN
         vsproduc := psproduc;
      ELSE
         vsproduc := vproducto;
      END IF;

      RESULT := pac_mdpar_productos.f_get_tipgar(vsproduc, pcgarant, mensajes);
      RETURN RESULT;
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
   END f_get_tipgar;

   /***********************************************************************
      Devuelve la lista de capitales por garantia
      param in pcgarant  : codigo de garantia
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_garanprocap(pcgarant IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_garanprocap IS
      gar            t_iaxpar_garanprocap;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_Garanprocap';
   BEGIN
      pkproduct(vproducto, mensajes);
      gar := pac_mdpar_productos.f_get_garanprocap(vproducto, vcactivi, vcramo, vmodalidad,
                                                   vctipseg, vccolect, pcgarant, mensajes);
      RETURN gar;
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
   END f_get_garanprocap;

   /***********************************************************************
      Devuelve las franquicias de la garantia
      param in pcgarant  : codigo de garantia
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_franquiciasgar(cgarant IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_franquicias IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_Franquiciasgar';
   BEGIN
      RETURN NULL;
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
   END f_get_franquiciasgar;

   /***********************************************************************
      Devuelve las garantias incompatibles
      param in pcgarant  : codigo de la garantia
      param out mensajes : mensajes de error
      return             : objeto actividades
   ***********************************************************************/
   FUNCTION f_get_incompgaran(pcgarant IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_incompgaran IS
      cincgar        t_iaxpar_incompgaran;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_Incompgaran';
   BEGIN
      pkproduct(vproducto, mensajes);
      cincgar := pac_mdpar_productos.f_get_incompgaran(vproducto, vcactivi, vcramo,
                                                       vmodalidad, vctipseg, vccolect,
                                                       pcgarant, mensajes);
      RETURN cincgar;
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
   END f_get_incompgaran;

   /***********************************************************************
      Devuelve las actividades definidas en el producto
      param out mensajes : mensajes de error
      return             : objeto actividades
   ***********************************************************************/
   FUNCTION f_get_actividades(mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_actividades IS
      activ          t_iaxpar_actividades;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_Actividades';
   BEGIN
      activ := pac_mdpar_productos.f_get_actividades(vproducto, mensajes);
      RETURN activ;
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
   END f_get_actividades;

   /***********************************************************************
      Devuelve las actividades definidas en el producto
      param in  psproduc : codigo producto
      param out mensajes : mensajes de error
      return             : objeto actividades
   ***********************************************************************/
   FUNCTION f_get_lstactividades(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_actividades IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'parametros - psproduc: ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_LstActividades';
      activ          t_iaxpar_actividades;
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      activ := pac_mdpar_productos.f_get_actividades(psproduc, mensajes);
      RETURN activ;
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
   END f_get_lstactividades;

   /*************************************************************************
      Recupera las posibles causas de anulacion de polizas de un determinado producto
      param in psproduc  : codigo del producto
      return             : refcursor
   *************************************************************************/
   FUNCTION f_get_causaanulpol(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - psproduc: ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_CausaAnulPol';
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      cur := pac_mdpar_productos.f_get_causaanulpol(psproduc, mensajes);
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
   END f_get_causaanulpol;

   -- BUG 9686 - 24/04/2009 - FAL - Parametrizar causas de anulacion de poliza en funcion del tipo de baja
      /*************************************************************************
         Recupera las posibles causas de anulacion de polizas de un determinado producto
         param in psproduc  : codigo del producto
         param in pctipbaja : tipo de baja
         return             : refcursor
      *************************************************************************/
   FUNCTION f_get_causaanulpol(
      psproduc IN NUMBER,
      pctipbaja IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                     := 'parametros - psproduc: ' || psproduc || ' - pctipbaja: ' || pctipbaja;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_CausaAnulPol';
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      cur := pac_mdpar_productos.f_get_causaanulpol(psproduc, pctipbaja, mensajes);
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
   END f_get_causaanulpol;

   -- FI BUG 9686 - 24/04/2009 â€“ FAL
      /*************************************************************************
         Recupera las posibles causas de siniestros de polizas de un determinado producto
         param in psproduc  : codigo del producto
         return             : refcursor
      *************************************************************************/
   FUNCTION f_get_causasini(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - psproduc: ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_CausaSini';
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      cur := pac_mdpar_productos.f_get_causasini(psproduc, mensajes);
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
   END f_get_causasini;

   /*************************************************************************
      Recupera lista con los motivos de siniestros por producto
      param in psproduc  : codigo del producto
      param in pccausa   : codigo causa de siniestro
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_motivossini(
      psproduc IN NUMBER,
      pccausa IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                            := 'parametros - psproduc:' || psproduc || ', pccausa:' || pccausa;
      vobject        VARCHAR2(50) := 'PAC_IAXPAR_PRODUCTOS.F_Get_MotivosSini';
      vcursor        sys_refcursor;
   BEGIN
      -- Comprovacio pas de parametres
      IF psproduc IS NULL
         OR pccausa IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vcursor := pac_mdpar_productos.f_get_motivossini(psproduc, pccausa, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_motivossini;

   /*************************************************************************
      Comproba si el producto tiene asociado preguntas y de que nivel son
      param in nivelPreg : P poliza - R riesgo - G garantia
      param out mensajes : mensajes de error
      param in pcgarant  : codigo de la garantia (puede ser nulo)
      return             : 0 no tiene preguntas del nivel
                           1 tiene preguntas del nivel
   *************************************************************************/
   FUNCTION f_get_prodtienepreg(
      nivelpreg IN VARCHAR2,
      mensajes OUT t_iax_mensajes,
      pcgarant IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := nivelpreg;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_ProdTienePreg';
      nerr           NUMBER;
   BEGIN
      nerr := pac_mdpar_productos.f_get_prodtienepreg(vproducto, vcactivi, pcgarant,
                                                      nivelpreg, mensajes);
      RETURN nerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 0;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 0;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 0;
   END f_get_prodtienepreg;

   /*************************************************************************
      Recupera los valores de revalorizacion a nivel de producto
      param out crevali : codigo de revalorizacion
      param out prevali : valor de la revalorizacion
      param out mensajes : mensajes de error
   *************************************************************************/
   PROCEDURE p_revalprod(crevali OUT NUMBER, prevali OUT NUMBER, mensajes OUT t_iax_mensajes) IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.P_RevalProd';
      nerr           NUMBER;
   BEGIN
      pac_mdpar_productos.p_revalprod(vproducto, crevali, prevali, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_revalprod;

   /*************************************************************************
      Recupera los valores de revalorizacion a nivel de garantia
      param in pcgarant  : codigo de garantia
      param in pcrevalipol : codigo de revalorizacion de la poliza
      param in pprevalipol : porcentaje de la revalorizacion de la poliza
      param in pirevalipol : import de la revalorizacion de la poliza
      param out pcrevali : codigo de revalorizacion
      param out pprevali : porcentaje de la revalorizacion
      param out pirevali : import de la revalorizacion
      param out mensajes : mensajes de error
   *************************************************************************/
   PROCEDURE p_revalgar(
      pcgarant IN NUMBER,
      pcrevalipol IN NUMBER,   -- BUG9906:DRA:29/04/2009
      pprevalipol IN NUMBER,   -- BUG9906:DRA:29/04/2009
      pirevalipol IN NUMBER,   -- BUG9906:DRA:29/04/2009
      pcrevali OUT NUMBER,
      pprevali OUT NUMBER,
      pirevali OUT NUMBER,   -- BUG9906:DRA:28/04/2009
      mensajes OUT t_iax_mensajes) IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'pcgarant=' || pcgarant || ', pcrevalipol=' || pcrevalipol || ', pprevalipol='
            || pprevalipol || ', pirevalipol=' || pirevalipol;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.P_RevalGar';
      nerr           NUMBER;
   BEGIN
      -- BUG9906:DRA:29/04/2009:Inici
      pac_mdpar_productos.p_revalgar(vproducto, vcactivi, pcgarant, pcrevalipol, pprevalipol,
                                     pirevalipol, pcrevali, pprevali, pirevali, mensajes);
   -- BUG9906:DRA:29/04/2009:Fi
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_revalgar;

   /*************************************************************************
      Indica si el producto puede tener revalorizacion
      return : 1 se permite
               0 no se permite
   *************************************************************************/
   FUNCTION f_permitirrevalprod
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_PermitirRevalProd';
      mensajes       t_iax_mensajes;
      vpermite       NUMBER(8);
   BEGIN
      vpermite := pac_mdpar_productos.f_permitirrevalprod(vproducto, mensajes);
      RETURN vpermite;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 0;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 0;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 0;
   END f_permitirrevalprod;

   /*************************************************************************
      Indica si la garantia puede tener revalorizacion
      param in pcgarant  : codigo de garantia
      param in pcrevalipol : codigo de revalorizacion de la poliza
      param in pprevalipol : porcentaje de la revalorizacion de la poliza
      param in pirevalipol : import de la revalorizacion de la poliza
      return : 1 se permite
               0 no se permite
   *************************************************************************/
   FUNCTION f_permitirrevalgar(
      pcgarant IN NUMBER,
      pcrevalipol IN NUMBER,   -- BUG9906:DRA:29/04/2009
      pprevalipol IN NUMBER,   -- BUG9906:DRA:29/04/2009
      pirevalipol IN NUMBER   -- BUG9906:DRA:29/04/2009
                           )
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'pcgarant=' || pcgarant || ', pcrevalipol=' || pcrevalipol || ', pprevalipol='
            || pprevalipol || ', pirevalipol=' || pirevalipol;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_PermitirRevalGar';
      mensajes       t_iax_mensajes;
      crevali        NUMBER;
      prevali        NUMBER;
      irevali        NUMBER;   -- BUG9906:DRA:28/04/2009
   BEGIN
      -- BUG9906:DRA:29/04/2009:Inici
      p_revalgar(pcgarant, pcrevalipol, pprevalipol, pirevalipol, crevali, prevali, irevali,
                 mensajes);

      -- BUG9906:DRA:29/04/2009:Fi
      IF (crevali > 0) THEN
         RETURN 1;   -- permet revaloritzar
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 0;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 0;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 0;
   END f_permitirrevalgar;

   --
   /***********************************************************************
      Devuelve el objeto producto con toda la definicion del producto
      return   : objeto productos
   ***********************************************************************/
   FUNCTION f_get_defproducto(sproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iaxpar_productos IS
      prod           ob_iaxpar_productos;
      garant         t_iaxpar_garantias;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_Defproducto';
   BEGIN
      pkproduct(sproduc, mensajes);

      -- Producto
      BEGIN
         prod := f_get_producto(sproduc, mensajes);
      EXCEPTION
         WHEN OTHERS THEN
            -- NO PUEDE RECUPERAR PRODUCTOS
            NULL;
      END;

      -- Actividades
      BEGIN
         prod.actividades := f_get_actividades(mensajes);
      EXCEPTION
         WHEN OTHERS THEN
            -- NO PUEDE RECUPERAR ACTIVIDADES
            NULL;
      END;   -- Actividades

      -- Garantias
      BEGIN
         IF prod.actividades IS NOT NULL THEN
            FOR i IN prod.actividades.FIRST .. prod.actividades.LAST LOOP
               prod.actividades(i).garantias := f_get_garantias(1, mensajes);

               -- Lista capitales garantias, garantias incompatibles
               -- preguntas, franquicias
               BEGIN
                  IF prod.actividades(i).garantias IS NOT NULL THEN
                     garant := prod.actividades(i).garantias;

                     FOR x IN garant.FIRST .. garant.LAST LOOP
                        -- Preguntas
                        garant(x).preguntas := f_get_preggarant(garant(x).cgarant, mensajes);
                        -- Lista capitales
                        garant(x).listacapitales :=
                                                f_get_garanprocap(garant(x).cgarant, mensajes);
                        -- Garantias incompatibles
                        garant(x).incompgaran :=
                                                f_get_incompgaran(garant(x).cgarant, mensajes);
                        -- Garantias incompatibles
                        garant(x).franquicias :=
                                             f_get_franquiciasgar(garant(x).cgarant, mensajes);
                     END LOOP;

                     prod.actividades(i).garantias := garant;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;
            END LOOP;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            -- NO PUEDE RECUPERAR GARANTIAS
            NULL;
      END;   -- Garantias

      -- Preguntas
      BEGIN
         prod.preguntas := f_get_pregpoliza(mensajes);
      EXCEPTION
         WHEN OTHERS THEN
            -- NO PUEDE RECUPERAR PREGUNTAS
            NULL;
      END;   -- Preguntas

      -- Clausulas
      BEGIN
         prod.clausulas := f_get_clausulas(mensajes);
      EXCEPTION
         WHEN OTHERS THEN
            -- NO PUEDE RECUPERAR CLAUSULAS
            NULL;
      END;   -- Clausulas

      RETURN prod;
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
   END;

   /***********************************************************************
      Devuelve el objeto producto
      return   : objeto productos
   ***********************************************************************/
   FUNCTION f_get_producto(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iaxpar_productos IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_Producto';
   BEGIN
      pkproduct(psproduc, mensajes);
      RETURN pac_mdpar_productos.f_get_producto(psproduc, mensajes);
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
   END;

   /***********************************************************************
      Devuelve la clave compuesta de un determinado producto
      param in:    psproduc
      param out:   pcramo
      param out:   pcmodali
      param out:   pctipseg
      param out:   pccolect
      param out:   mensajes
      return:      0 -> Todo ha ido bien
                   <> 0 -> Error
   ***********************************************************************/
   FUNCTION f_get_identprod(
      psproduc IN NUMBER,
      pcramo OUT NUMBER,
      pcmodali OUT NUMBER,
      pctipseg OUT NUMBER,
      pccolect OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'parametros - psproduc: ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_IdentProd';
      v_error        NUMBER;
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      v_error := pac_mdpar_productos.f_get_identprod(psproduc, pcramo, pcmodali, pctipseg,
                                                     pccolect, mensajes);

      IF v_error <> 0 THEN
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
   END;

   --JRB 04/2008
   /***********************************************************************
      Devuelve la descripcion del producto
      param in sproduc : Codigo producto
      return   : descripcion del producto
   ***********************************************************************/
   FUNCTION f_get_descproducto(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - psproduc: ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.Get_AnyosRentasIrreg';
   BEGIN
      --Comprovacio dels parametres d'entrada
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      RETURN pac_mdpar_productos.f_get_descproducto(psproduc, 1, mensajes);
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
   END f_get_descproducto;

   /*************************************************************************
      Recupera la documentacion necesaria para poder realizar la emision de una
      poliza de un determinado producto.
      param in  sproduc    : codigo del producto
      param out mensajes   : mensajes de error
      return    refcuror   : informacion de la documentacion necesaria.
   *************************************************************************/
   FUNCTION f_get_documnecalta(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_IAXPAR_PRODUCTOS.F_Get_DocumNecAlta';
      vparam         VARCHAR2(500) := 'parametros - psproduc: ' || psproduc;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcursor        sys_refcursor;
   BEGIN
      --Comprovacio dels parametres d'entrada
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Recuperacio de la documentacio necessaria pel moviment d'alta d'una pÃ²lissa
      vcursor := pac_mdpar_productos.f_get_documnecmov(psproduc, 100, NULL,
                                                       pac_md_common.f_get_cxtidioma, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_documnecalta;

   --JRH 03/2008 Obtener formas de pago de las rentas
     /*************************************************************************
          Recupera los periodos de revision por producto
          param in  psproduc   : codigo del producto
          param out mensajes   : mensajes de error
          return    refcuror   : informacion de las formas de pago de renta del producto.
       *************************************************************************/
   FUNCTION get_forpagren(psproduc IN productos.sproduc%TYPE, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - psproduc: ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.Get_ForPagRen';
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      cur := pac_mdpar_productos.get_forpagren(psproduc, pac_md_common.f_get_cxtidioma,
                                               mensajes);
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
   END get_forpagren;

   --JRH 03/2008

   --JRH 03/2008 Obtener periodos de revision del producto pasado como parametro
   /*************************************************************************
        Recupera los periodos de revision por producto
        param in  psproduc   : codigo del producto
        param out mensajes   : mensajes de error
        return    refcuror   : informacion de los periodos de revision posibles del producto.
     *************************************************************************/
   FUNCTION f_get_perrevision(psproduc IN productos.sproduc%TYPE, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - psproduc: ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_PerRevision';
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      cur := pac_mdpar_productos.f_get_perrevision(psproduc, pac_md_common.f_get_cxtidioma,
                                                   mensajes);
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
   END f_get_perrevision;

   --JRH 03/2008

   --JRH 03/2008 Obtener los aÃ±os posibles para las rentas irregulares
    /*************************************************************************
       Recupera los periodos de revision por producto
       param in  psproduc   : codigo del producto
       param out mensajes   : mensajes de error
       return    refcuror   :  informacion de los aÃ±os (codigo / descripcion).
    *************************************************************************/
   FUNCTION get_anyosrentasirreg(
      psproduc IN productos.sproduc%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parametros - psproduc: ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.Get_AnyosRentasIrreg';
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      cur := pac_mdpar_productos.get_anyosrentasirreg(psproduc, pac_md_common.f_get_cxtidioma,
                                                      mensajes);
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
   END get_anyosrentasirreg;

   --JRH 03/2008

   /***********************************************************************
      Devuelve las garantias. Si se informa el parametro "pcgarant", se excluye
      la garantia pasada por parametro de la lista de garantÃ­as retornadas.
      param in psproduc  : codigo del producto
      param in pcactivi  : codigo de actividad
      param in pcgarant  : codigo de garantia
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_lstgarantiasdep(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(200)
         := 'parametros - psproduc:' || psproduc || ' - pcactivi:' || pcactivi
            || ' - pcgarant:' || pcgarant;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_LstGarantiasDep';
      vcursor        sys_refcursor;
   BEGIN
      -- Comprovacio pas de parametres
      IF psproduc IS NULL
         OR pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vcursor := pac_mdpar_productos.f_get_lstgarantias(psproduc, pcactivi, pcgarant, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_lstgarantiasdep;

   /***********************************************************************
      Devuelve si es visible o no el campo fvencim
      param in psproduc  : codigo del producto
      param in pcduraci  : estseguros.cduraci
      param in pmodo     : modo
      param out mensajes : mensajes de error
      return             : 0=oculto / 1=visible
   ***********************************************************************/
   FUNCTION f_visible_fvencim(
      psproduc IN NUMBER,
      pcduraci IN NUMBER,
      pmodo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'parametros - psproduc:' || psproduc || ' - pcduraci:' || pcduraci || ' - pmodo:'
            || pmodo;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Visible_Fvencim';
   BEGIN
      IF pcduraci IN(1, 2, 5) THEN
         RETURN 1;
      ELSIF pcduraci = 3
            AND f_prod_vinc(psproduc) <> 1
            AND pmodo <> 'SUPLEMENTO' THEN
         RETURN 1;
      END IF;

      RETURN 0;
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
   END f_visible_fvencim;

   /***********************************************************************
      Devuelve si es visible o no el campo nduraci
      param in pcduraci  : estseguros.cduraci
      param out mensajes : mensajes de error
      return             : 0=oculto / 1=visible
   ***********************************************************************/
   FUNCTION f_visible_nduraci(pcduraci IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'parametros - pcduraci:' || pcduraci;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Visible_Nduraci';
   BEGIN
      IF pcduraci IN(1, 2, 3, 5) THEN
         RETURN 1;
      END IF;

      RETURN 0;
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
   END f_visible_nduraci;

   /***********************************************************************
      Recupera si un producto tiene cuestionario de salud
      param in psproduc  : codigo de producto
      param out pccuesti : indica si tiene cuestionario de salud
      param in out mensajes  : coleccion de mensajes
      return             : devuelve 0 si todo bien, sino el codigo del error
   ***********************************************************************/
   FUNCTION f_get_ccuesti(psproduc IN NUMBER, pccuesti OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.f_get_ccuesti';
      num_err        NUMBER;
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_mdpar_productos.f_get_ccuesti(psproduc, pccuesti, mensajes);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN num_err;
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
   END f_get_ccuesti;

   -- BUG 6296 - 16/03/2009 - SBG - Creacio funcio f_get_pregtipgru
   /***********************************************************************
      Recupera el Tipo de grupo de pregunta (detvalores.cvalor = 309)
      param in  pcpregun : codigo de pregunta
      param out mensajes : mensajes de error
      return             : Tipo de grupo de pregunta (detvalores.cvalor = 309)
   ***********************************************************************/
   FUNCTION f_get_pregtipgru(pcpregun IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'cpregun= ' || pcpregun;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_PregTipGru';
   BEGIN
      RETURN pac_mdpar_productos.f_get_pregtipgru(pcpregun, mensajes);
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
   END f_get_pregtipgru;

   /*************************************************************************
      BUG9217 - 06/04/2009 - DRA
      Retorna por parametro si permite hacer el suplemento de un motivo determinado
      param in  pcuser      : Codigo del usuario
      param in  pcmotmov    : Codigo del motivo
      param in  psproduc    : id. producto
      param out p_permite    : Indica si se permite realizar el suplemento o no
      param out mensajes     : mensajes de error
      return                 : 0.- OK    <> 0 --> ERROR
   *************************************************************************/
   FUNCTION f_permite_supl_prod(
      p_cuser IN VARCHAR2,
      p_cmotmov IN NUMBER,
      p_sproduc IN NUMBER,
      p_permite OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500)
         := 'p_cuser= ' || p_cuser || ' - p_cmotmov: ' || p_cmotmov || ' - p_sproduc: '
            || p_sproduc;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.f_permite_supl_prod';
      v_numerr       NUMBER;
   BEGIN
      v_numerr := pac_mdpar_productos.f_permite_supl_prod(p_cuser, p_cmotmov, p_sproduc,
                                                          p_permite, mensajes);

      IF v_numerr <> 0 THEN
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
   END f_permite_supl_prod;

   /***********************************************************************
   Donat un producte retornem el codi de clausula per defecte del producte.
   param in  p_sproduc: codi producte
   param out mensajes : missatge error
   return             : ok/error
   ***********************************************************************/
   -- BUG 12674.NMM.15/01/2010.i.
   FUNCTION f_get_claubenefi_def(
      p_sproduc IN NUMBER,
      p_clau_benef_defecte OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'p_sproduc= ' || p_sproduc;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.f_get_claubenefi_def';
      w_err          NUMBER;
   --
   BEGIN
      IF p_sproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      w_err := pac_mdpar_productos.f_get_claubenefi_def(p_sproduc, p_clau_benef_defecte,
                                                        mensajes);

      IF w_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN(0);
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN(1);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN(w_err);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN(1);
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
   FUNCTION f_get_pregvisible(
      p_sproduc IN NUMBER,
      p_cpregun IN NUMBER,
      p_cactivi IN NUMBER DEFAULT 0,   -- BUG 0036730 - FAL - 09/12/2015
      p_cvisible OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500)
                                 := 'p_sproduc= ' || p_sproduc || ', p_cpregun= ' || p_cpregun;
      vobject        VARCHAR2(200) := 'PAC_MDPAR_PRODUCTOS.f_get_pregvisible';
      w_err          NUMBER;
   BEGIN
      IF p_sproduc IS NULL
         OR p_cpregun IS NULL THEN
         RAISE e_param_error;
      END IF;

      w_err :=
         pac_mdpar_productos.f_get_pregvisible(p_sproduc, p_cpregun, p_cactivi, p_cvisible,   -- BUG 0036730 - FAL - 09/12/2015
                                               mensajes);

      IF w_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, w_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN(w_err);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN(w_err);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN(w_err);
   END f_get_pregvisible;

-- BUG12760:DRA:03/02/2010:Fi

   /***********************************************************************
      Recupera las formas de pago del producto
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_fprestaprod(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.f_get_fprestaprod';
   BEGIN
      cur := pac_mdpar_productos.f_get_fprestaprod(vproducto, mensajes);
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
   END f_get_fprestaprod;

   /***********************************************************************
      Devuelve la descripcion de una clausula con parametros
      param in  sclaben  : codigo de la clausula
      param in  sseguro  : sseguro de la pÃ²liza
      param out mensajes : mensajes de error
      return             : descripcion garantia
   ***********************************************************************/
   FUNCTION f_get_descclausulapar(
      psclaben IN NUMBER,
      sseguro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      dclausu        VARCHAR2(4000);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_DescClausula';
   BEGIN
      dclausu := pac_mdpar_productos.f_get_descclausulapar(psclaben, sseguro, mensajes);
      RETURN dclausu;
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
   END f_get_descclausulapar;

   /***********************************************************************
      Devuelve la descripcion de una clausula con parametros
      param in  sclaben  : codigo de la clausula
      param in  sseguro  : sseguro de la pÃ²liza
      param out mensajes : mensajes de error
      return             : descripcion garantia
   ***********************************************************************/
   FUNCTION f_get_descclausulaparmult(
      psclaben IN NUMBER,
      pnordcla IN NUMBER,
      sseguro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      dclausu        VARCHAR2(2000);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_DescClausulaMult';
   BEGIN
      dclausu := pac_mdpar_productos.f_get_descclausulaparmult(psclaben, pnordcla, sseguro,
                                                               mensajes);
      RETURN dclausu;
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
   END f_get_descclausulaparmult;

   /***********************************************************************
      Devuelve el parametro de producto productos_ren.cmodextra
      return   : valor del parametro
   ***********************************************************************/
   FUNCTION f_get_cmodextra(
      psproduc IN NUMBER,
      pcmodextra OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vcmodextra     NUMBER := 0;
      verr           NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_DescClausula';
   BEGIN
      verr := pac_mdpar_productos.f_get_cmodextra(psproduc, vcmodextra, mensajes);

      IF verr = 0 THEN
         pcmodextra := vcmodextra;
      END IF;

      RETURN verr;
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
   END f_get_cmodextra;

-- Bug 0019578 - FAL - 26/09/2011 - Recuperar si derechos de registro nivel garantia
   /*************************************************************************
      Recupera los valores de si aplica derechos de registro a nivel de garantia
      param in pcgarant  : codigo de garantia
      param out pcderreg : codigo de si aplica derechos de registro
      param out mensajes : mensajes de error
   *************************************************************************/
   PROCEDURE p_derreggar(pcgarant IN NUMBER, pcderreg OUT NUMBER, mensajes OUT t_iax_mensajes) IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'pcgarant=' || pcgarant;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.P_derreggar';
      nerr           NUMBER;
   BEGIN
      pac_mdpar_productos.p_derreggar(vproducto, vcactivi, pcgarant, pcderreg, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_derreggar;

-- Fi Bug 0019578 - FAL - 26/09/2011

   /***********************************************************************
      Devuelve la descripcin del producto y el cdigo cmoneda(monedas) y cmoneda(eco_codmonedas)
      return   : valor del parametro
   ***********************************************************************/
   FUNCTION f_get_monedaproducto(
      psproduc IN NUMBER,
      pcmoneda OUT NUMBER,
      pcmonint OUT VARCHAR2,
      ptmoneda OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vcmodextra     NUMBER := 0;
      verr           NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAXPAR_PRODUCTOS.F_Get_monedaproducto';
   BEGIN
      verr := pac_mdpar_productos.f_get_monedaproducto(psproduc, pcmoneda, pcmonint, ptmoneda,
                                                       mensajes);
      RETURN verr;
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
   END f_get_monedaproducto;

   -- BUG 0020671 - 03/01/2012 - JMF
   /***********************************************************************
      Recupera si la pregunta de garantia es visible o no
      param in  p_sproduc  : codigo de productos
      param in  p_cpregun  : codigo de pregunta
      param in  p_cactivi  : codigo de actividad
      param in  p_cgarant  : codigo de garantia
      param out p_cvisible : 0-> No visible   1-> Visible
      return               : devuelve 0 si todo bien, sino el codigo del error
   ***********************************************************************/
   FUNCTION f_get_pregunprogaranvisible(
      p_sproduc IN NUMBER,
      p_cpregun IN NUMBER,
      p_cactivi IN NUMBER,
      p_cgarant IN NUMBER,
      p_cvisible OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500)
         := 'pro=' || p_sproduc || ' pre=' || p_cpregun || ' act=' || p_cactivi || ' gar='
            || p_cgarant;
      vobject        VARCHAR2(200) := 'PAC_MDPAR_PRODUCTOS.f_get_pregunprogaranvisible';
      w_err          NUMBER;
   BEGIN
      IF p_sproduc IS NULL
         OR p_cpregun IS NULL THEN
         RAISE e_param_error;
      END IF;

      w_err := pac_mdpar_productos.f_get_pregunprogaranvisible(p_sproduc, p_cpregun, p_cactivi,
                                                               p_cgarant, p_cvisible, mensajes);

      IF w_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, w_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN(w_err);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN(w_err);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN(w_err);
   END f_get_pregunprogaranvisible;

   FUNCTION f_get_cabecera_preguntab(
      ptipo IN VARCHAR2,
      pcpregun IN NUMBER,
      pcgarant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_preguntastab_columns IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
            := 'pcpregun : ' || pcpregun || ',ptipo : ' || ptipo || ',pcgarant : ' || pcgarant;
      vobject        VARCHAR2(200) := 'PAC_MDPAR_PRODUCTOS.f_get_cabecera_preguntab';
      num_err        NUMBER := 0;
      cur            sys_refcursor;
      squery         VARCHAR2(200);
      tpreguntas     t_iax_preguntastab_columns;
   BEGIN
      tpreguntas := pac_mdpar_productos.f_get_cabecera_preguntab(vproducto, vcactivi, ptipo,
                                                                 pcpregun, pcgarant,
                                                                 pac_iax_produccion.issimul,
                                                                 pac_iax_produccion.issuplem,
                                                                 mensajes);
      RETURN tpreguntas;
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
   END f_get_cabecera_preguntab;
END pac_iaxpar_productos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAXPAR_PRODUCTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAXPAR_PRODUCTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAXPAR_PRODUCTOS" TO "PROGRAMADORESCSI";
