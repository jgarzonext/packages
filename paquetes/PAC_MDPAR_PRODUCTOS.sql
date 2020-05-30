--------------------------------------------------------
--  DDL for Package PAC_MDPAR_PRODUCTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MDPAR_PRODUCTOS" AS
   /******************************************************************************
      NOMBRE:       PAC_MDPAR_PRODUCTOS
      PROPOSITO: Recupera la parametrizacion del producto devolviendo los objetos

      REVISIONES:
      Ver        Fecha        Autor             Descripcion
      ---------  ----------  ---------  ------------------------------------
      1.0        29/01/2008   ACC       1. Creacion del package.
      2.0        16/02/2009   SBG       2. Creacio funcio f_get_pregtipgru i s'informa CTIPGRU
                                           de l'objecte OB_IAXPAR_PREGUNTAS (Bug 6296)
      3.0        03/04/2009   DRA       3. 0009217: IAX - Suplement de clausules
      4.0        15/04/2009   DRA       4. BUG0009661: APR - Tipo de revalorizacion a nivel de producto
      5.0        28/04/2009   DRA       5. 0009906: APR - Ampliar la parametritzacio de la revaloracio a nivell de garantia
      6.0        28/05/2009   ETM       6. BUG0009855:  CEM - Configuraciones varias de Escut Basic,Incluimos el parametro psimul a la funcion f_get_pregpoliza
      7.0        24/04/2009   FAL       7. Parametrizar causas de anulacion de poliza en funcion del tipo de baja. Bug 9686.
      8.0        18/12/2009   JMF       8. 0012227 AGA - Adaptar profesiones con empresa y producto
      9.0        15/01/2010   NMM       9. 12674: CRE087 - Producto ULK- Eliminar pantalla beneficiarios de wizard de contratacion
     10.0        03/02/2010   DRA       10. 0012760: CRE200 - Consulta de polizas: mostrar preguntas automaticas.
     11.0        22/11/2010   JBN       11. 0016410 -CRT003 - Clausulas con parametros
     12.0        03/01/2012   JMF       12. 0020671: LCOL_T001-LCOL - UAT - TEC: Contrataci?n
     13.0        09/01/2012   DRA       13. 0020498: LCOL_T001-LCOL - UAT - TEC - Beneficiaris de la p?lissa
     14.0        16/10/2012   DRA       14. 0022402: LCOL_C003: Adaptaci¿n del co-corretaje
     15.0        18/10/2012   DRA       15. 0023911: LCOL: A¿adir Retorno para los productos Colectivos
     16.0        09/12/2015   FAL       16. 0036730: I - Producto Subsidio Individual
   ******************************************************************************/

   /***********************************************************************
      Devuelve el parametro de producto especificado
      return   : valor del parametro
   ***********************************************************************/
   FUNCTION f_get_parproducto(clave IN VARCHAR2, psproduc IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Devuelve el codigo del subtipo de producto VF 37
      return   : codigo del subtipo de producto
   ***********************************************************************/
   FUNCTION f_get_subtipoprod(psproduc IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Recupera las formas de pago del producto
      param in psproduc  : codigo del producto
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_formapago(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Recupera las duraciones del producto
      param in psproduc  : codigo del producto
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_tipduracion(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Recupera las preguntas a nivel de poliza
      param in psproduc  : codigo del producto
      param out mensajes : mensajes de error
      return             : objeto preguntas
   ***********************************************************************/
   FUNCTION f_get_pregpoliza(
      psproduc IN NUMBER,
      psimul IN BOOLEAN,   --BUG0009855:ETM: 28/05/2009
      pissuplem IN BOOLEAN,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iaxpar_preguntas;

   /***********************************************************************
      Recupera los datos del riesgo (preguntas)
      param in psproduc  : codigo del producto
      param in pcactivi  : codigo de actividad
      param in psimul    : indicador de simulacion  --BUG9427-01042009-XVM
      param out mensajes : mensajes de error
      return             : objeto preguntas
   ***********************************************************************/
   FUNCTION f_get_datosriesgos(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      psimul IN BOOLEAN,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iaxpar_preguntas;

   /***********************************************************************
      Recupera las preguntas a nivel de garantia
      param in psproduc  : codigo del producto
      param in pcactivi  : codigo de actividad
      param in pcgarant  : codigo de garantia
      param out mensajes : mensajes de error
      return             : objeto preguntas
   ***********************************************************************/
   FUNCTION f_get_preggarant(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iaxpar_preguntas;

   /***********************************************************************
      Recupera el Tipo de pregunta (detvalores.cvalor = 78)
      param in  pcpregun : codigo de pregunta
      param out mensajes : mensajes de error
      return             : Tipo de pregunta (detvalores.cvalor = 78)
   ***********************************************************************/
   FUNCTION f_get_pregtippre(pcpregun IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera si la pregunta es automatica/manual (detvalores.cvalor = 787)
      param in  pcpregun : codigo de pregunta
      param in  psproduc : codigo del producto
      param in  tipo     : indica si son preguntas POL RIE GAR
      param in  pcactivi : codigo actividad
      param in  pcgarant : codigo garantia
      param out mensajes : mensajes de error
      return             : Tipo de pregunta (detvalores.cvalor = 787)
   ***********************************************************************/
   FUNCTION f_get_pregunautomatica(
      pcpregun IN NUMBER,
      psproduc IN NUMBER,
      tipo IN VARCHAR2,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera las clausulas del beneficiario
      param in psproduc  : codigo del producto
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_claubenefi(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Devuelve la descripcion de una clausula de beneficiarios
      param in psclaben  : codigo de la clausula
      param out mensajes : mensajes de error
      return             : descripcion garantia
   ***********************************************************************/
   FUNCTION f_get_descclausulaben(psclaben IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /***********************************************************************
      Devuelve la descripcion de una clausula
      param in psclagen  : codigo de la clausula
      param out mensajes : mensajes de error
      return             : descripcion garantia
   ***********************************************************************/
   FUNCTION f_get_descclausula(psclagen IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /***********************************************************************
      Devuelve las clausulas
      param in pcramo     : codigo ramo
      param in pcmodali   : codigo modalidad
      param in pctipseg   : codigo tipo de seguro
      param in pccolect   : codigo de colectividad
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_clausulas(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iaxpar_clausulas;

   /***********************************************************************
      Devuelve las clausulas multiples
      param in cramo     : codigo ramo
      param in cmodali   : codigo modalidad
      param in ctipseg   : codigo tipo de seguro
      param in ccolect   : codigo de colectividad
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_clausulasmult(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iaxpar_clausulas;

   /***********************************************************************
      Devuelve las garantias
      param in psproduc  : codigo del producto
      param in pcactivi  : codigo de actividad
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_garantias(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iaxpar_garantias;

   /***********************************************************************
      Devuelve la descripcion de una garantia
      param in  pcgarant  : codigo de la garantia
      param out mensajes : mensajes de error
      return             : descripcion garantia
   ***********************************************************************/
   FUNCTION f_get_descgarant(pcgarant IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /***********************************************************************
      Devuelve la respuesta de una pregunta
      param in  psproduc : codigo de producto
      param in  pcpregun : codigo de la pregunta
      param in  pcrespue : codigo de la respuesta
      param in  pcidioma : codigo de idioma
      param out mensajes : mensajes de error
      return             : descripcion pregunta
   ***********************************************************************/
   -- Bug 0012227 - 18/12/2009 - JMF: Afegir sproduc
   FUNCTION f_get_pregunrespue(
      psproduc IN NUMBER,
      pcpregun IN NUMBER,
      pcrespue IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /***********************************************************************
      Devuelve el tipo de garantia
      param in psproduc  : codigo de producto
      param in pcgarant  : codigo de la garantia
      param out mensajes : mensajes de error
      return             : descripcion garantia
   ***********************************************************************/
   FUNCTION f_get_tipgar(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Devuelve la lista de capitales por garantia
      param in psproduc  : codigo del producto
      param in pcactivi  : codigo de actividad
      param in pcramo    : codigo ramo
      param in pcmodali  : codigo modalidad
      param in pctipseg  : codigo tipo de seguro
      param in pccolect  : codigo de colectividad
      param in pcgarant  : codigo de garantia
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_garanprocap(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iaxpar_garanprocap;

   /***********************************************************************
      Devuelve las garantias incompatibles
      param in psproduc  : codigo del producto
      param in pcactivi  : codigo de actividad
      param in pcramo    : codigo ramo
      param in pcmodali  : codigo modalidad
      param in pctipseg  : codigo tipo de seguro
      param in pccolect  : codigo de colectividad
      param in pcgarant  : codigo de garantia
      param out mensajes : mensajes de error
      return             : objeto actividades
   ***********************************************************************/
   FUNCTION f_get_incompgaran(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iaxpar_incompgaran;

   /***********************************************************************
      Devuelve las actividades definidas en el producto
      param in psproduc  : codigo del producto
      param out mensajes : mensajes de error
      return             : objeto actividades
   ***********************************************************************/
   FUNCTION f_get_actividades(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iaxpar_actividades;

   /*************************************************************************
      Recupera las posibles causas de anulacion de polizas de un determinado producto
      param in psproduc  : codigo del producto
      return             : refcursor
   *************************************************************************/
   FUNCTION f_get_causaanulpol(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- FI BUG 9686 - 24/04/2009 ¿¿¿¿¿¿¿¿ FAL

   /*************************************************************************
      Recupera las posibles causas de siniestros de polizas de un determinado producto
      param in psproduc  : codigo del producto
      return             : refcursor
   *************************************************************************/
   FUNCTION f_get_causasini(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

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
      RETURN sys_refcursor;

   /*************************************************************************
      Comproba si el producto tiene asociado preguntas y de que nivel son
      param in psproduc  : codigo de producto
      param in pcactivi  : codigo de actividad (puede se nula)
      param in pcgarant  : codigo de la garantia (puede se nula)
      param in nivelPreg : P poliza - R riesgo - G garantia
      param out mensajes : mensajes de error
      return             : 0 no tiene preguntas del nivel
                           1 tiene preguntas del nivel
   *************************************************************************/
   FUNCTION f_get_prodtienepreg(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      nivelpreg IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Recupera los valores de revalorizacion a nivel de producto
      param int psproduc : codigo de producto
      param out pcrevali : codigo de revalorizacion
      param out pprevali : valor de la revalorizacion
      param out mensajes : mensajes de error
   *************************************************************************/
   PROCEDURE p_revalprod(
      psproduc IN NUMBER,
      pcrevali OUT NUMBER,
      pprevali OUT NUMBER,
      mensajes IN OUT t_iax_mensajes);

   /*************************************************************************
      Indica si el producto puede tener revalorizacion
      param in  psproduc : codigo de producto
      param out mensajes : mensajes de error
      return : 1 se permite
               0 no se permite
   *************************************************************************/
   FUNCTION f_permitirrevalprod(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Recupera los valores de revalorizacion a nivel de garantia
      param in psproduc  : codigo de producto
      param in pcactivi  : codigo de actividad
      param in pcgarant  : codigo de garantia
      param in pcrevalipol : codigo de revalorizacion de la poliza
      param in pprevalipol : porcetaje de la revalorizacion de la poliza
      param in pirevalipol : importe de la revalorizacion de la poliza
      param out pcrevali : codigo de revalorizacion
      param out pprevali : porcetaje de la revalorizacion
      param out pirevali : importe de la revalorizacion
      param out mensajes : mensajes de error
   *************************************************************************/
   PROCEDURE p_revalgar(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcrevalipol IN NUMBER,   -- BUG9906:DRA:29/04/2009
      pprevalipol IN NUMBER,   -- BUG9906:DRA:29/04/2009
      pirevalipol IN NUMBER,   -- BUG9906:DRA:29/04/2009
      pcrevali OUT NUMBER,
      pprevali OUT NUMBER,
      pirevali OUT NUMBER,   -- BUG9906:DRA:28/04/2009
      mensajes IN OUT t_iax_mensajes);

   /*************************************************************************
      Recupera la documentacion necesaria para poder realizar un determinado
      movimiento en una poliza de un determinado producto.
      param in  psproduc   : codigo del producto
      param in  pcmotmov   : codigo del motivo del movimiento.
      param in  pctipdoc   : Tipo de documentacion a recuperar (0->opcional, 1->obligatoria, NULL->toda)
      param in  pcidioma   : Codigo del idioma para la descripcion de la documentacion.
      param out mensajes   : mensajes de error
      return    refcuror   : informacion de la documentacion necesaria.
   *************************************************************************/
   FUNCTION f_get_documnecmov(
      psproduc IN NUMBER,
      pcmotmov IN NUMBER,
      pctipdoc IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_descpregun(
      pcpregun IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   --JRH 03/2008 A¿¿¿¿ado datos de producto financieros
    /*************************************************************************
         Recupera los periodos de revision por producto
         param in  psproduc   : codigo del producto
         param in  pcidioma   : Codigo del idioma para la descripcion de la documentacion.
         param out mensajes   : mensajes de error
         return    refcuror   : informacion de los periodos de revision posibles del producto (codigo - descripcion).
      *************************************************************************/
   FUNCTION f_get_perrevision(
      psproduc IN productos.sproduc%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   --JRH 03/2008 Obtener formas de pago de las rentas
   /*************************************************************************
        Recupera formas de pago de la renta del producto
        param in  psproduc   : codigo del producto
        param in  pcidioma   : Codigo del idioma para la descripcion de la documentacion.
        param out mensajes   : mensajes de error
        return    refcuror   : informacion de las formas de pago de renta del producto( codigo - descripcion).
     *************************************************************************/
   FUNCTION get_forpagren(
      psproduc IN productos.sproduc%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

    --JRH 03/2008 Obtener los a¿¿¿¿os posibles para las rentas irregulares
   /*************************************************************************
      Recupera los periodos de revision por producto
      param in  psproduc   : codigo del producto
      param in  pcidioma   : Codigo del idioma para la descripcion de la documentacion.
      param out mensajes   : mensajes de error
      return    refcuror   :  informacion de las formas de pago del producto (codigo - descripcion).
   *************************************************************************/
   FUNCTION get_anyosrentasirreg(
      psproduc IN productos.sproduc%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

    --JRH 03/2008
   /***********************************************************************
      Devuelve el parametro de garantia especificado
      param in clave: El nombre del parametro
      psproduc in clave: El producto
      pgarant in clave: La garantia
      return   : valor del parametro
   ***********************************************************************/
   FUNCTION f_get_pargarantia(
      clave IN VARCHAR2,
      psproduc IN productos.sproduc%TYPE,
      pgarant IN NUMBER,
      pcactivi IN NUMBER DEFAULT 0)   -- BUG 0036730 - FAL - 09/12/2015
      RETURN NUMBER;

   --JRB 04/2008
   /***********************************************************************
      Devuelve el objeto producto
      param in sproduc : Codigo producto
      return   : objeto productos
   ***********************************************************************/
   FUNCTION f_get_producto(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iaxpar_productos;

        --JRB 04/2008
   /***********************************************************************
      Devuelve la descripcion del producto
      param in sproduc : Codigo producto
      param in ptipdesc: Tipo descripcion
      return   : descripcion del producto
   ***********************************************************************/
   FUNCTION f_get_descproducto(
      psproduc IN productos.sproduc%TYPE,
      ptipdesc IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /***********************************************************************
      Devuelve las garantias de un determinado producto - actividad.
      Si se informa el parametro "pcgarant", se excluye la garantia pasada
      por parametro de la lista de garantias retornadas.
      param in psproduc  : codigo del producto
      param in pcactivi  : codigo de actividad
      param in pcgarant  : codigo de garantia
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_lstgarantias(
      psproduc IN productos.sproduc%TYPE,
      pcactivi IN activisegu.cactivi%TYPE,
      pcgarant IN garanpro.cgarant%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Devuelve el codigo de CDURMIN del producto
      param in sproduc : Codigo producto
      return           : cdurmin del producto
   ***********************************************************************/
   FUNCTION f_get_cdurmin(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera la agrupacion del producto buscandola por el SPRODUC (si el
      param. no es null), o bien por CRAMO, CMODALI, CTIPSEG y CCOLECT.
      param in psseguro  : codigo de seguro
      param out mensajes : mensajes de error
      return             : codigo de agrupacion
   ***********************************************************************/
   FUNCTION f_get_agrupacio(p_sseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve objeto registro con las pk de producto
      param in psproduc      : codigo de producto
      param in pcramo
      param in pcmodali
      param in pctipseg
      param in pccollect
      param in out mensajes  : coleccion de mensajes
      return                 : NUMBER
   *************************************************************************/
   FUNCTION f_get_identprod(
      psproduc NUMBER,
      pcramo OUT NUMBER,
      pcmodali OUT NUMBER,
      pctipseg OUT NUMBER,
      pccollect OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve el sproduc seg¿¿¿¿n parametros
      param in cramo         : codigo del ramo
      param in cmodali       : codigo de modalidad
      param in ctipseg       : codigo de tipo de seguro
      param in ccolect       : codigo de colectividad
      param in out mensajes  : coleccion de mensajes
   *************************************************************************/
   FUNCTION f_get_sproduc(
      cramo NUMBER,
      cmodali NUMBER,
      ctipseg NUMBER,
      ccolect NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- ini t.7817
   /***********************************************************************
      Recupera el valor del campo CTARPOL d'una pregunta asociada a un
      producto.
      param in  p_cramo   : Ramo
      param in  p_cmodali : Modalidad
      param in  p_ctipseg : Tipo de seguro
      param in  p_ccolect : Colectivo
      param in  p_cpregun : Pregunta
      param out p_ctarpol : indica si se debe tarifar o no con el cambio
                            de valor de esta pregunta.
      return              : devuelve 0 si todo bien, sino el codigo del error
   ***********************************************************************/
   FUNCTION f_pregneedtarif(
      p_cramo IN pregunpro.cramo%TYPE,
      p_cmodali IN pregunpro.cmodali%TYPE,
      p_ctipseg IN pregunpro.ctipseg%TYPE,
      p_ccolect IN pregunpro.ccolect%TYPE,
      p_cpregun IN pregunpro.cpregun%TYPE,
      p_ctarpol OUT pregunpro.ctarpol%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera si un producto tiene cuestionario de salud
      param in psproduc  : codigo de producto
      param out pccuesti : indica si tiene cuestionario de salud
      param in out mensajes  : coleccion de mensajes
      return             : devuelve 0 si todo bien, sino el codigo del error
   ***********************************************************************/
   FUNCTION f_get_ccuesti(
      psproduc IN NUMBER,
      pccuesti OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- BUG 6296 - 16/03/2009 - SBG - Creacio funcio f_get_pregtipgru
   /***********************************************************************
      Recupera el Tipo de grupo de pregunta (detvalores.cvalor = 309)
      param in  pcpregun : codigo de pregunta
      param out mensajes : mensajes de error
      return             : Tipo de grupo de pregunta (detvalores.cvalor = 309)
   ***********************************************************************/
   FUNCTION f_get_pregtipgru(pcpregun IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Nos indica si una determinada pregunta es o no semiautomatica
      param in  psproduc : codigo de producto
      param in  pcpregun : codigo de pregunta
      param in  pnivel   : codigo de accesi (poliza, riesgo o garantia)
      param out mensajes : mensajes de error
      param in  pcgarant : codigo de garantia para el acceso por garantia
      return             : Number [0/1]
   ***********************************************************************/
   -- Bug 9109 - 12/02/2009 - RSC - APR: Preguntas semiautomaticas
   FUNCTION f_es_semiautomatica(
      psproduc IN NUMBER,
      pcpregun IN NUMBER,
      pnivel IN VARCHAR2,
      mensajes OUT t_iax_mensajes,
      pcgarant IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /***********************************************************************
      Nos retornara el TPREFOR de una determinada pregunta ya sea a nivel de
      poliza, riesgo o garantia.

      param in  psproduc : codigo de producto
      param in  pcpregun : codigo de pregunta
      param in  pnivel   : codigo de accesi (poliza, riesgo o garantia)
      param out mensajes : mensajes de error
      param in  pcgarant : codigo de garantia para el acceso por garantia
      return             : Number [0/1]
   ***********************************************************************/
   -- Bug 9109 - 12/02/2009 - RSC - APR: Preguntas semiautomaticas
   FUNCTION f_get_tpreforsemi(
      psproduc IN NUMBER,
      pcpregun IN NUMBER,
      pnivel IN VARCHAR2,
      mensajes OUT t_iax_mensajes,
      pcgarant IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /*************************************************************************
      BUG9217 - 03/04/2009 - DRA
      Retorna por parametro si permite hacer el suplemento de un motivo determinado
      param in  p_cuser      : Codigo del usuario
      param in  p_cmotmov    : Codigo del motivo
      param in  p_sproduc    : id. producto
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

   -- BUG9661:DRA:15/04/2009: Inici
   /***********************************************************************
      Recuperar la lista de posibles valores de revalorizacion por producto
      param in  p_sproduc: codigo del producto
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_tipreval(p_sproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- BUG9661:DRA:15/04/2009: Fi
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
      RETURN NUMBER;

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
      RETURN NUMBER;

-- BUG12760:DRA:03/02/2010:Fi
/***********************************************************************
      Devuelve Si tiene detalle la garantia
      param in psproduc  : codigo de producto
      param in pcgarant  : codigo de la garantia
      param out mensajes : mensajes de error
      return             : descripcion garantia
   ***********************************************************************/
   FUNCTION f_get_detallegar(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera las formas de pago del producto
      param in psproduc  : codigo del producto
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_fprestaprod(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Devuelve una clausula del producto
      param in cramo     : codigo ramo
      param in cmodali   : codigo modalidad
      param in ctipseg   : codigo tipo de seguro
      param in ccolect   : codigo de colectividad
      param in sclagen   : codigo de la clausula
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_clausula(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psclagen IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iaxpar_clausulas;

   /***********************************************************************
      Devuelve una clausula del producto (multiple)
      param in cramo     : codigo ramo
      param in cmodali   : codigo modalidad
      param in ctipseg   : codigo tipo de seguro
      param in ccolect   : codigo de colectividad
      param in sclagen   : codigo de la clausula
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_clausulamult(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psclagen IN NUMBER,
      pnordcla IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iaxpar_clausulas;

     /***********************************************************************
      Devuelve los parametros de una clausulas inicializados
      param in psclagen     : codigo clausula
      param out pcparams   :  Numero de parametros de una clausula
      param out mensajes : mensajes de error
      return             : t_iax_clausupara
   ***********************************************************************/
   FUNCTION f_get_clausulas(
      psclagen IN NUMBER,
      pcparams OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_clausupara;

/***********************************************************************
      Devuelve la descripcion de una clausula con parametros
      param in  sclaben  : codigo de la clausula
      param in  sseguro  : sseguro de la poliza
      param out mensajes : mensajes de error
      return             : descripcion garantia
   ***********************************************************************/
   FUNCTION f_get_descclausulapar(
      psclaben IN NUMBER,
      psseguro IN NUMBER,
      mensajes OUT t_iax_mensajes,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

   /***********************************************************************
      Devuelve la descripcion de una clausula con parametros
      param in  sclaben  : codigo de la clausula
      param in  sseguro  : sseguro de la poliza
      param out mensajes : mensajes de error
      return             : descripcion garantia
   ***********************************************************************/
   FUNCTION f_get_descclausulaparmult(
      psclaben IN NUMBER,
      pnordcla IN NUMBER,
      psseguro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

    /***********************************************************************
      Devuelve el parametro de producto productos_ren.cmodextra
      return   : valor del parametro
   ***********************************************************************/
   FUNCTION f_get_cmodextra(
      psproduc IN NUMBER,
      pcmodextra OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- Bug 0019578 - FAL - 26/09/2011 - Recuperar si derechos de registro nivel garantia
   /*************************************************************************
      Recupera los valores de si aplica derechos de registro a nivel de garantia
      param in psproduc  : codigo de producto
      param in pcactivi  : codigo de actividad
      param in pcgarant  : codigo de garantia
      param out pcderreg : codigo de si aplica derechos de registro
      param out mensajes : mensajes de error
   *************************************************************************/
   PROCEDURE p_derreggar(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcderreg OUT NUMBER,
      mensajes OUT t_iax_mensajes);

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- BUG 0020671 - 03/01/2012 - JMF
   /***********************************************************************
      Recupera si la pregunta es visible o no
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
      RETURN NUMBER;

   -- BUG20498:DRA:09/01/2012:Inici
   /***********************************************************************
      Recupera las preguntas a nivel de clausulas
      param in psproduc  : codigo del producto
      param out mensajes : mensajes de error
      return             : objeto preguntas
   ***********************************************************************/
   FUNCTION f_get_pregclausulas(
      psproduc IN NUMBER,
      psimul IN BOOLEAN,   --BUG0009855:ETM: 28/05/2009
      pissuplem IN BOOLEAN,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iaxpar_preguntas;

-- BUG20498:DRA:09/01/2012:Fi
   FUNCTION f_get_cabecera_preguntab(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      ptipo IN VARCHAR2,
      pcpregun IN NUMBER,
      pcgarant IN NUMBER,
      psimul IN BOOLEAN,
      pissuplem IN BOOLEAN,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_preguntastab_columns;

   FUNCTION f_get_franquicias(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pnriesgo IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      pssegpol IN NUMBER,
      pcgrup IN NUMBER,
      pcsubgrup IN NUMBER,
      pcversion IN NUMBER,
      pcnivel IN NUMBER,
      pcvalor1 IN NUMBER,
      pimpvalor1 IN NUMBER,
      pcvalor2 IN NUMBER,
      pimpvalor2 IN NUMBER,
      pcimpmin IN NUMBER,
      pimpmin IN NUMBER,
      pcimpmax IN NUMBER,
      pimpmax IN NUMBER,
      psuplem IN BOOLEAN,
      psimul IN BOOLEAN,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_bf_proactgrup;

   FUNCTION f_get_bf_listalibre(pid_listlibre IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_bf_listlibre;

   /***********************************************************************
      Devuelve el co-corretaje
      param in sproduc   : c¿digo de producto
      param out mensajes : mensajes de error
      return             : t_iax_corretaje
   ***********************************************************************/
   FUNCTION f_get_corretaje(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_corretaje;

   /***********************************************************************
      Devuelve el retorno
      param in sproduc   : c¿digo de producto
      param out mensajes : mensajes de error
      return             : t_iax_corretaje
   ***********************************************************************/
   FUNCTION f_get_retorno(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_retorno;

   FUNCTION f_hay_franq_bonusmalus(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pfranquicias OUT NUMBER,
      pbonus OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Nos retornara el cpretip de una determinada pregunta ya sea a nivel de
      poliza, riesgo o garantia.

      param in  psproduc : codigo de producto
      param in  pcpregun : codigo de pregunta
      param in  pnivel   : codigo de accesi (poliza, riesgo o garantia)
      param out mensajes : mensajes de error
      param in  pcgarant : codigo de garantia para el acceso por garantia
      return             : Number [0/1]
   ***********************************************************************/
   FUNCTION f_get_cpretippreg(
      psproduc IN NUMBER,
      pcpregun IN NUMBER,
      pnivel IN VARCHAR2,
      mensajes OUT t_iax_mensajes,
      pcgarant IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /***********************************************************************
      Nos retornara el esccero de una determinada pregunta ya sea a nivel de
      poliza, riesgo o garantia.

      param in  psproduc : codigo de producto
      param in  pcpregun : codigo de pregunta
      param in  pnivel   : codigo de accesi (poliza, riesgo o garantia)
      param out mensajes : mensajes de error
      param in  pcgarant : codigo de garantia para el acceso por garantia
      return             : Number [0/1]
   ***********************************************************************/
   FUNCTION f_get_escceropreg(
      psproduc IN NUMBER,
      pcpregun IN NUMBER,
      pnivel IN VARCHAR2,
      mensajes OUT t_iax_mensajes,
      pcgarant IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

      /***********************************************************************
      Nos indica si una determinada pregunta es o no automatica que se calcula antes de tarifar al entrar en la pantalla de garant¿as.
      param in psproduc : codigo de producto
      param in pcpregun : codigo de pregunta
      param in pnivel : codigo de accesi (poliza, riesgo o garantia)
      param out mensajes : mensajes de error
      param in pcgarant : codigo de garantia para el acceso por garantia
      return : Number [0/1]
   ***********************************************************************/
   FUNCTION f_es_automatica_pre_tarif(
      psproduc IN NUMBER,
      pcpregun IN NUMBER,
      pnivel IN VARCHAR2,   -- Nivel 'P' (poliza) o 'R' (riesgo)
      mensajes OUT t_iax_mensajes,
      pcgarant IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
END pac_mdpar_productos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MDPAR_PRODUCTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MDPAR_PRODUCTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MDPAR_PRODUCTOS" TO "PROGRAMADORESCSI";
