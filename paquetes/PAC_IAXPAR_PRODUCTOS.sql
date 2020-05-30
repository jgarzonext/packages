--------------------------------------------------------
--  DDL for Package PAC_IAXPAR_PRODUCTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAXPAR_PRODUCTOS" AS
   /******************************************************************************
    NOMBRE:       PAC_IAXPAR_PRODUCTOS
    PROPÃ“SITO: Recupera la parametrizaciÃ³n del producto devolviendo los objectos

    REVISIONES:
    Ver        Fecha        Autor             DescripciÃ³n
    ---------  ----------  ----------   -----------------------------------
    1.0        06/09/2007   ACC          1. CreaciÃ³n del package.
    2.0        21/11/2007   ACC          2. Nuevas funcionalidades
    3.0        16/02/2009   SBG          3. CreaciÃ³ funciÃ³ f_get_pregtipgru (Bug 6296)
    4.0        06/04/2009   DRA          4. 0009217: IAX - Suplement de clÃ usules
    5.0        15/04/2009   DRA          5. BUG0009661: APR - Tipo de revalorizaciÃ³n a nivel de producto
    6.0        28/04/2009   DRA          6. 0009906: APR - Ampliar la parametritzaciÃ³ de la revaloraciÃ³ a nivell de garantia
    7.0        24/04/2009   FAL          7. Parametrizar causas de anulaciÃ³n de poliza en funciÃ³n del tipo de baja. Bug 9686.
    8.0        18/12/2009   JMF          8. 0012227 AGA - Adaptar profesiones con empresa y producto
    9.0        15/01/2010   NMM          9. 12674: CRE087 - Producto ULK- Eliminar pantalla beneficiarios de wizard de contrataciÃ³n
   10.0        03/02/2010   DRA          10. 0012760: CRE200 - Consulta de pÃ³lizas: mostrar preguntas automÃ¡ticas.
   11.0        03/01/2012   JMF          11. 0020671: LCOL_T001-LCOL - UAT - TEC: Contrataci?n
   12.0        09/12/2015   FAL          12. 0036730: I - Producto Subsidio Individual
   ******************************************************************************/
   vproducto      NUMBER;   --CÃ³digo producto
   vcactivi       NUMBER := 0;   --CÃ³digo actividad por defecto 0
   vmodalidad     NUMBER;   --CÃ³digo modalidad
   vempresa       NUMBER;   --CÃ³digo empresa
   vidioma        NUMBER := pac_md_common.f_get_cxtidioma;   --CÃ³digo idioma
   vccolect       NUMBER;   --CÃ³digo de Colectividad del Producto
   vcramo         NUMBER;   --CÃ³digo de Ramo del Producto
   vctipseg       NUMBER;   --CÃ³digo de Tipo de Seguro del Producto

   /***********************************************************************
      Inicializa producto
      param in sproduc   : cÃ³digo de productos
      param in cmodali   : cÃ³digo modalidad
      param in cempres   : cÃ³digo empresa
      param in cidioma   : cÃ³digo idioma
      param in ccolect   : cÃ³digo de colectividad
      param in cramo     : cÃ³digo de ramo
      param in ctipseg   : cÃ³digo tipo de seguro
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
      RETURN NUMBER;

   /***********************************************************************
      Devuelve el parÃ¡metro de producto especificado
      return   : valor del parÃ¡metro
   ***********************************************************************/
   FUNCTION f_get_parproducto(clave IN VARCHAR2, psproduc IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Devuelve el cÃ³digo del subtipo de producto VF 37
      return   : cÃ³digo del subtipo de producto
   ***********************************************************************/
   FUNCTION f_get_subtipoprod(psproduc IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Indica si se permite tener multiples tomadores en la pÃ³liza
      return   : 1 indica que se permite
                 0 que no se permite
   ***********************************************************************/
   FUNCTION f_permitirmultitomador
      RETURN NUMBER;

   /***********************************************************************
      Indica si se permite tener multiples asegurados en la pÃ³liza
      return   : 1 indica que se permite
                 0 que no se permite
   ***********************************************************************/
   FUNCTION f_permitirmultiaseg
      RETURN NUMBER;

   /***********************************************************************
      Indica si se permite tener multiples riesgos en la pÃ³liza
      return   : 1 indica que se permite
                 0 que no se permite
   ***********************************************************************/
   FUNCTION f_permitirmultiriesgos
      RETURN NUMBER;

   /***********************************************************************
      Establece el cÃ³digo de actividad para el producto
   ***********************************************************************/
   PROCEDURE p_set_prodactiviti(pcactivi NUMBER);

   /***********************************************************************
      Recupera las formas de pago del producto
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_formapago(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Recupera las duraciones del producto
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_tipduracion(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Recupera las preguntas a nivel de pÃ³liza
      param out mensajes : mensajes de error
      return             : objeto preguntas
   ***********************************************************************/
   FUNCTION f_get_pregpoliza(mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_preguntas;

   /***********************************************************************
      Recupera los datos del riesgo (preguntas)
      param out mensajes : mensajes de error
      return             : objeto preguntas
   ***********************************************************************/
   FUNCTION f_get_datosriesgos(mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_preguntas;

   /***********************************************************************
      Recupera las preguntas a nivel de garantia
      param in  cgarant  : cÃ³digo de garantia
      param out mensajes : mensajes de error
      return             : objeto preguntas
   ***********************************************************************/
   FUNCTION f_get_preggarant(cgarant IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_preguntas;

   /***********************************************************************
      Recupera el Tipo de pregunta (detvalores.cvalor = 78)
      param in  pcpregun : cÃ³digo de pregunta
      param out mensajes : mensajes de error
      return             : Tipo de pregunta (detvalores.cvalor = 78)
   ***********************************************************************/
   FUNCTION f_get_pregtippre(pcpregun IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera si la pregunta es automatica/manual (detvalores.cvalor = 787)
      param in  pcpregun : cÃ³digo de pregunta
      param in  tipo     : indica si son preguntas POL RIE GAR
      param in  pcactivi : cÃ³digo actividad
      param in  pcgarant : cÃ³digo garantia
      param out mensajes : mensajes de error
      return             : Tipo de pregunta (detvalores.cvalor = 787)
   ***********************************************************************/
   FUNCTION f_get_pregunautomatica(
      pcpregun IN NUMBER,
      tipo IN VARCHAR2,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera las clausulas del beneficiario
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_claubenefi(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Devuelve la descripciÃ³n de una clausula de beneficiarios
      param in  sclaben  : cÃ³digo de la clausula
      param out mensajes : mensajes de error
      return             : descripciÃ³n garantia
   ***********************************************************************/
   FUNCTION f_get_descclausulaben(sclaben IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

-- BUG171999:JBN:19/01/2011: Inic
/***********************************************************************
      Devuelve la descripciÃ³n de una clausula con parametros
      param in  sclaben  : cÃ³digo de la clausula
      param in  sseguro  : sseguro de la pÃ²liza
      param out mensajes : mensajes de error
      return             : descripciÃ³n garantia
   ***********************************************************************/
   FUNCTION f_get_descclausulapar(
      psclaben IN NUMBER,
      sseguro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /***********************************************************************
      Devuelve la descripciÃ³n de una clausula con parametros
      param in  sclaben  : cÃ³digo de la clausula
      param in  sseguro  : sseguro de la pÃ²liza
      param out mensajes : mensajes de error
      return             : descripciÃ³n garantia
   ***********************************************************************/
   FUNCTION f_get_descclausulaparmult(
      psclaben IN NUMBER,
      pnordcla IN NUMBER,
      sseguro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

-- BUG171999:JBN:19/01/2011 fi

   -- BUG9661:DRA:15/04/2009: Inici
   /***********************************************************************
      Recupera los tipos de revalorizaciÃ³n
      param in  p_sproduc: codigo del producto
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_tipreval(p_sproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- BUG9661:DRA:15/04/2009: Fi

   /***********************************************************************
      Devuelve las clausulas
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_clausulas(mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_clausulas;

   /***********************************************************************
      Devuelve las clausulas multiples
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_clausulasmult(mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_clausulas;

   /***********************************************************************
      Devuelve la descripciÃ³n de una clausula
      param in  sclagen  : cÃ³digo de la clausula
      param out mensajes : mensajes de error
      return             : descripciÃ³n garantia
   ***********************************************************************/
   FUNCTION f_get_descclausula(sclagen IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /***********************************************************************
      Devuelve las garantias
      param out mensajes : mensajes de error
      return             : objeto garantias
   ***********************************************************************/
   FUNCTION f_get_garantias(pnriesgo NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_garantias;

   /***********************************************************************
      Devuelve las lista garantias
      param in psproduc  : cÃ³digo producto
      param in pcactivi  : cÃ³digo actividad
      param out mensajes : mensajes de error
      return             : objeto garantias
   ***********************************************************************/
   FUNCTION f_get_lstgarantias(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_garantias;

   /***********************************************************************
      Devuelve la descripciÃ³n de una garantia
      param in  cgarant  : cÃ³digo de la garantia
      param out mensajes : mensajes de error
      return             : descripciÃ³n garantia
   ***********************************************************************/
   FUNCTION f_get_descgarant(cgarant IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /***********************************************************************
      Devuelve la descripciÃ³n de una pregunta
      param in  cpregun  : cÃ³digo de la pregunta
      param out mensajes : mensajes de error
      return             : descripciÃ³n pregunta
   ***********************************************************************/
   FUNCTION f_get_descpregun(pcpregun IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /***********************************************************************
      Devuelve la respuesta de una pregunta
      param in  psproduc : cÃ³digo producto
      param in  pcpregun : cÃ³digo de la pregunta
      param in  pcrespue : cÃ³digo de la respuesta
      param out mensajes : mensajes de error
      return             : descripciÃ³n pregunta
   ***********************************************************************/
   -- Bug 0012227 - 18/12/2009 - JMF
   FUNCTION f_get_pregunrespue(
      psproduc IN NUMBER,
      pcpregun IN NUMBER,
      pcrespue IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /***********************************************************************
      Devuelve el tipo de garantia
      param in  cgarant  : cÃ³digo de la garantia
      param in psproduc  : cÃ³digo de producto (default null)
      param out mensajes : mensajes de error
      return             : descripciÃ³n garantia
   ***********************************************************************/
   FUNCTION f_get_tipgar(
      pcgarant IN NUMBER,
      psproduc IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Devuelve la lista de capitales por garantia
      param in pcgarant  : cÃ³digo de garantia
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_garanprocap(pcgarant IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_garanprocap;

   /***********************************************************************
      Devuelve las franquicias de la garantia
      param in pcgarant  : cÃ³digo de garantia
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_franquiciasgar(cgarant IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_franquicias;

   /***********************************************************************
      Devuelve las garantias incompatibles
      param in pcgarant  : cÃ³digo de la garantia
      param in pcgarant  : cÃ³digo de garantia
      param out mensajes : mensajes de error
      return             : objeto garantias incompatibles
   ***********************************************************************/
   FUNCTION f_get_incompgaran(pcgarant IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_incompgaran;

   /***********************************************************************
      Devuelve las actividades definidas en el producto
      param out mensajes : mensajes de error
      return             : objeto actividades
   ***********************************************************************/
   FUNCTION f_get_actividades(mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_actividades;

   /***********************************************************************
      Devuelve las actividades definidas en el producto
      param in  psproduc : cÃ³digo producto
      param out mensajes : mensajes de error
      return             : objeto actividades
   ***********************************************************************/
   FUNCTION f_get_lstactividades(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_actividades;

   /*************************************************************************
      Recupera las posibles causas de anulaciÃ³n de pÃ³lizas de un determinado producto
      param in psproduc  : cÃ³digo del producto
      return             : refcursor
   *************************************************************************/
   FUNCTION f_get_causaanulpol(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- BUG 9686 - 24/04/2009 - FAL - Parametrizar causas de anulaciÃ³n de poliza en funciÃ³n del tipo de baja
      /*************************************************************************
         Recupera las posibles causas de anulaciÃ³n de pÃ³lizas de un determinado producto
         param in psproduc  : cÃ³digo del producto
         param in pctipbaja : tipo de baja
         return             : refcursor
      *************************************************************************/
   FUNCTION f_get_causaanulpol(
      psproduc IN NUMBER,
      pctipbaja IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- FI BUG 9686 - 24/04/2009 â€“ FAL

   /*************************************************************************
      Recupera las posibles causas de siniestros de pÃ³lizas de un determinado producto
      param in psproduc  : cÃ³digo del producto
      return             : refcursor
   *************************************************************************/
   FUNCTION f_get_causasini(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera lista con los motivos de siniestros por producto
      param in psproduc  : cÃ³digo del producto
      param in pccausa   : cÃ³digo causa de siniestro
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_motivossini(
      psproduc IN NUMBER,
      pccausa IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Comproba si el producto tiene asociado preguntas y de que nivel son
      param in nivelPreg : P pÃ³liza - R riesgo - G garantia
      param out mensajes : mensajes de error
      param in pcgarant  : cÃ³digo de la garantia (puede ser nulo)
      return             : 0 no tiene preguntas del nivel
                           1 tiene preguntas del nivel
   *************************************************************************/
   FUNCTION f_get_prodtienepreg(
      nivelpreg IN VARCHAR2,
      mensajes OUT t_iax_mensajes,
      pcgarant IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
      Recupera los valores de revalorizaciÃ³n a nivel de producto
      param out crevali : cÃ³digo de revalorizaciÃ³n
      param out prevali : valor de la revalorizaciÃ³n
      param out mensajes : mensajes de error
   *************************************************************************/
   PROCEDURE p_revalprod(crevali OUT NUMBER, prevali OUT NUMBER, mensajes OUT t_iax_mensajes);

   /*************************************************************************
      Recupera los valores de revalorizaciÃ³n a nivel de garantia
      param in pcgarant  : cÃ³digo de garantia
      param in pcrevalipol : cÃ³digo de revalorizaciÃ³n de la poliza
      param in pprevalipol : porcentaje de la revalorizaciÃ³n de la poliza
      param in pirevalipol : import de la revalorizaciÃ³n de la poliza
      param out pcrevali : cÃ³digo de revalorizaciÃ³n
      param out pprevali : porcentaje de la revalorizaciÃ³n
      param out pirevali : import de la revalorizaciÃ³n
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
      mensajes OUT t_iax_mensajes);

   /*************************************************************************
      Indica si el producto puede tener revalorizaciÃ³n
      return : 1 se permite
               0 no se permite
   *************************************************************************/
   FUNCTION f_permitirrevalprod
      RETURN NUMBER;

   /*************************************************************************
      Indica si la garantia puede tener revalorizaciÃ³n
      param in pcgarant  : cÃ³digo de garantia
      param in pcrevalipol : cÃ³digo de revalorizaciÃ³n de la poliza
      param in pprevalipol : porcentaje de la revalorizaciÃ³n de la poliza
      param in pirevalipol : import de la revalorizaciÃ³n de la poliza
      return : 1 se permite
               0 no se permite
   *************************************************************************/
   FUNCTION f_permitirrevalgar(
      pcgarant IN NUMBER,
      pcrevalipol IN NUMBER,   -- BUG9906:DRA:29/04/2009
      pprevalipol IN NUMBER,   -- BUG9906:DRA:29/04/2009
      pirevalipol IN NUMBER   -- BUG9906:DRA:29/04/2009
                           )
      RETURN NUMBER;

   /***********************************************************************
      Devuelve el objeto producto con toda la definiciÃ³n del producto
      return   : objeto productos
   ***********************************************************************/
   FUNCTION f_get_defproducto(sproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iaxpar_productos;

   /***********************************************************************
      Devuelve el objeto producto
      return   : objeto productos
   ***********************************************************************/
   FUNCTION f_get_producto(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iaxpar_productos;

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
      RETURN NUMBER;

   --JRB 04/2008
   /***********************************************************************
      Devuelve la descripciÃ³n del producto
      param in sproduc : CÃ³digo producto
      return   : descripciÃ³n del producto
   ***********************************************************************/
   FUNCTION f_get_descproducto(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      Recupera la documentaciÃ³n necesaria para poder realizar la emisiÃ³n de una
      pÃ³liza de un determinado producto.
      param in  sproduc    : cÃ³digo del producto
      param out mensajes   : mensajes de error
      return    refcuror   : informaciÃ³n de la documentaciÃ³n necesaria.
   *************************************************************************/
   FUNCTION f_get_documnecalta(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   --JRH 03/2008 Obtener formas de pago de las rentas
     /*************************************************************************
          Recupera los periodos de revisiÃ³n por producto
          param in  psproduc   : cÃ³digo del producto
          param out mensajes   : mensajes de error
          return    refcuror   : informaciÃ³n de las formas de pago del producto.
       *************************************************************************/
   FUNCTION get_forpagren(psproduc IN productos.sproduc%TYPE, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   --JRH 03/2008 Obtener periodos de revisiÃ³n del producto pasado como parÃ¡metro
     /*************************************************************************
          Recupera los periodos de revisiÃ³n por producto
          param in  psproduc   : cÃ³digo del producto
          param out mensajes   : mensajes de error
          return    refcuror   : informaciÃ³n de los periodos de revisiÃ³n posibles del producto.
       *************************************************************************/
   FUNCTION f_get_perrevision(
      psproduc IN productos.sproduc%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   --JRH 03/2008 Obtener los aÃ±os posibles para las rentas irregulares
     /*************************************************************************
        Recupera los periodos de revisiÃ³n por producto
        param in  psproduc   : cÃ³digo del producto
        param out mensajes   : mensajes de error
        return    refcuror   :  informaciÃ³n de los aÃ±os (cÃ³digo / descripciÃ³n).
     *************************************************************************/
   FUNCTION get_anyosrentasirreg(
      psproduc IN productos.sproduc%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   --JRH 03/2008
    /***********************************************************************
       Devuelve el parÃ¡metro de garantÃ­a especificado
       param in clave: El nombre del parÃ¡metro
       psproduc in clave: El producto
       pgarant in clave: La garantÃ­a
       return   : valor del parÃ¡metro
    ***********************************************************************/
   FUNCTION f_get_pargarantia(
      clave IN VARCHAR2,
      psproduc IN productos.sproduc%TYPE,
      pgarant IN NUMBER,
      pcactivi IN NUMBER DEFAULT 0)   -- BUG 0036730 - FAL - 09/12/2015
      RETURN NUMBER;

   /***********************************************************************
      Devuelve las garantias. Si se informa el parÃ¡metro "pcgarant", se excluye
      la garantia pasada por parÃ¡metro de la lista de garantÃ­as retornadas.
      param in psproduc  : cÃ³digo del producto
      param in pcactivi  : cÃ³digo de actividad
      param in pcgarant  : cÃ³digo de garantia
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_lstgarantiasdep(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Devuelve si es visible o no el campo fvencim
      param in psproduc  : cÃ³digo del producto
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
      RETURN NUMBER;

   /***********************************************************************
      Devuelve si es visible o no el campo nduraci
      param in psproduc  : cÃ³digo del producto
      param in pcduraci  : estseguros.cduraci
      param in pmodo     : modo
      param out mensajes : mensajes de error
      return             : 0=oculto / 1=visible
   ***********************************************************************/
   FUNCTION f_visible_nduraci(pcduraci IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /***********************************************************************
      Recupera si un producto tiene cuestionario de salud
      param in psproduc  : cÃ³digo de producto
      param out pccuesti : indica si tiene cuestionario de salud
      param in out mensajes  : colecciÃ³n de mensajes
      return             : devuelve 0 si todo bien, sino el cÃ³digo del error
   ***********************************************************************/
   FUNCTION f_get_ccuesti(psproduc IN NUMBER, pccuesti OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- BUG 6296 - 16/03/2009 - SBG - CreaciÃ³ funciÃ³ f_get_pregtipgru
   /***********************************************************************
      Recupera el Tipo de grupo de pregunta (detvalores.cvalor = 309)
      param in  pcpregun : cÃ³digo de pregunta
      param out mensajes : mensajes de error
      return             : Tipo de grupo de pregunta (detvalores.cvalor = 309)
   ***********************************************************************/
   FUNCTION f_get_pregtipgru(pcpregun IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      BUG9217 - 06/04/2009 - DRA
      Retorna por parÃ¡metro si permite hacer el suplemento de un motivo determinado
      param in  pcuser      : CÃ³digo del usuario
      param in  pcmotmov    : CÃ³digo del motivo
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
      RETURN NUMBER;

      /***********************************************************************
      Donat un producte retornem el codi de clÃ usula per defecte del producte.
      param in  p_sproduc: codi producte
      param out mensajes : missatge error
      return             : ok/error
      ***********************************************************************/
   -- BUG 12674.NMM.15/01/2010.i.
   FUNCTION f_get_claubenefi_def(
      p_sproduc IN NUMBER,
      p_clau_benef_defecte OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- BUG 12674.NMM.15/01/2010.f.

   -- BUG12760:DRA:03/02/2010:Inici
   /***********************************************************************
      Recupera si la pregunta es visible o no
      param in  p_sproduc  : cÃ³digo de productos
      param in  p_cpregun  : cÃ³digo de pregunta
      param out p_cvisible : 0-> No visible   1-> Visible
      return               : devuelve 0 si todo bien, sino el cÃ³digo del error
   ***********************************************************************/
   FUNCTION f_get_pregvisible(
      p_sproduc IN NUMBER,
      p_cpregun IN NUMBER,
      p_cactivi IN NUMBER DEFAULT 0,   -- BUG 0036730 - FAL - 09/12/2015
      p_cvisible OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- BUG12760:DRA:03/02/2010:Fi

   /***********************************************************************
      Recupera las formas de pago del producto
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_fprestaprod(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Devuelve el parÃ¡metro de producto productos_ren.cmodextra
      return   : valor del parÃ¡metro
   ***********************************************************************/
   FUNCTION f_get_cmodextra(
      psproduc IN NUMBER,
      pcmodextra OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- Bug 0019578 - FAL - 26/09/2011 - Recuperar si derechos de registro nivel garantia
   /*************************************************************************
      Recupera los valores de si aplica derechos de registro a nivel de garantia
      param in pcgarant  : cÃ³digo de garantia
      param out pcderreg : cÃ³digo de si aplica derechos de registro
      param out mensajes : mensajes de error
   *************************************************************************/
   PROCEDURE p_derreggar(pcgarant IN NUMBER, pcderreg OUT NUMBER, mensajes OUT t_iax_mensajes);

-- Fi Bug 0019578 - FAL - 26/09/2011

   /***********************************************************************
      Devuelve la descripcin del producto y el cdigo cmoneda(monedas) y cmoneda(eco_codmonedas)
      return   : valor del parÃ¡metro
   ***********************************************************************/
   FUNCTION f_get_monedaproducto(
      psproduc IN NUMBER,
      pcmoneda OUT NUMBER,
      pcmonint OUT VARCHAR2,
      ptmoneda OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- BUG 0020671 - 03/01/2012 - JMF
   /***********************************************************************
      Recupera si la pregunta de garantia es visible o no
      param in  p_sproduc  : cÃ³digo de productos
      param in  p_cpregun  : cÃ³digo de pregunta
      param in  p_cactivi  : cÃ³digo de actividad
      param in  p_cgarant  : cÃ³digo de garantia
      param out p_cvisible : 0-> No visible   1-> Visible
      return               : devuelve 0 si todo bien, sino el cÃ³digo del error
   ***********************************************************************/
   FUNCTION f_get_pregunprogaranvisible(
      p_sproduc IN NUMBER,
      p_cpregun IN NUMBER,
      p_cactivi IN NUMBER,
      p_cgarant IN NUMBER,
      p_cvisible OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_cabecera_preguntab(
      ptipo IN VARCHAR2,
      pcpregun IN NUMBER,
      pcgarant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_preguntastab_columns;
END pac_iaxpar_productos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAXPAR_PRODUCTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAXPAR_PRODUCTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAXPAR_PRODUCTOS" TO "PROGRAMADORESCSI";
