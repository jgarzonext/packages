--------------------------------------------------------
--  DDL for Package PAC_PRODUCTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PRODUCTOS" AS
   /******************************************************************************
      NOMBRE:       PAC_PRODUCTOS
      PROPÓSITO: Recupera las consultas del producto

      REVISIONES:
      Ver        Fecha       Autor            Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0                                     1. Creación del package.
      2.0        01/04/2009   SBG             2. Creació funció f_get_filtroprod
      3.0        15/04/2009   DRA             3. BUG0009661: APR - Tipo de revalorización a nivel de producto
      4.0        28/04/2009   DRA             4. 0009906: APR - Ampliar la parametrització de la revaloració a nivell de garantia
      5.0        18/12/2009   JMF             5. 0012227 AGA - Adaptar profesiones con empresa y producto
      6.0        15/01/2010   NMM             6. 12674: CRE087 - Producto ULK- Eliminar pantalla beneficiarios de wizard de contratación
      7.0        20/01/2010   RSC             7. 7926: APR - Fecha de vencimiento a nivel de garantía
                                                 (movemos función PAC_PRODUCTOS.f_vto_garantia --> PAC_SEGUROS.f_vto_garantia)
      8.0        03/02/2010   DRA             8. 0012760: CRE200 - Consulta de pólizas: mostrar preguntas automáticas.
      9.0        11/08/2010   SMF             9. 0015711: AGA003 - standaritzación del pac_cass
     10.0        03/01/2012   JMF            10. 0020671: LCOL_T001-LCOL - UAT - TEC: Contrataci?n
     16.0        11/02/2013   NMM            16. 24735: (POSDE600)-Desarrollo-GAPS Tecnico-Id 33 - Mesadas Extras diferentes a la propia (preguntas)
     17.0        21/01/2014   JTT            17. 0026501: Añadir el parametro psseguro a pnpoliza a la funcin f_get_pregunrespue
     18.0        09/12/2015   FAL            18. 0036730: I - Producto Subsidio Individual
   ******************************************************************************/

   /***********************************************************************
      Recupera el código de subtipo de producto
      param in psproduc  : código del producto
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_subtipoprod(psproduc IN NUMBER, vcsubpro OUT NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Recupera las duraciones del producto
      param in psproduc  : código del producto
      param out vcduraci  : duración del producto
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_tipduracion(psproduc IN NUMBER, vcduraci OUT NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Recupera el Tipo de pregunta (detvalores.cvalor = 78)
      param in pcpregun  : código de pregunta
      param out pctippre  : tipo pregunta
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_pregtippre(pcpregun IN NUMBER, pctippre OUT NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Recupera el Tipo de pregunta Pol
      param in psproduc  : código de producto
      param in pcpregun  : código de pregunta
      param out pctippre  : tipo respuesta
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_pregunpol(psproduc IN NUMBER, pcpregun IN NUMBER, pcpretip OUT NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Recupera el Tipo de pregunta Rie
      param in psproduc  : código de producto
      param in pcpregun  : código de pregunta
      param in pcactivi  : código de actividad
      param out pctippre  : tipo respuesta
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_pregunrie(
      psproduc IN NUMBER,
      pcpregun IN NUMBER,
      pcactivi IN NUMBER,
      pcpretip OUT NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Recupera el Tipo de pregunta Gar
      param in psproduc  : código de producto
      param in pcpregun  : código de pregunta
      param in pcactivi  : código de actividad
      param in pcgarant  : código de garantia
      param out pctippre  : tipo respuesta
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_pregungar(
      psproduc IN NUMBER,
      pcpregun IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcpretip OUT NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Recupera el Tipo de pregunta Gar
      param in psclagen  : secuencia de clausula
      param in pcidioma  : código idioma
      param out ptclatit : titulo clausula
      param out ptclatex : texto clausula
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_clausugen(
      psclagen IN NUMBER,
      pcidioma IN NUMBER,
      ptclatit OUT VARCHAR2,
      ptclatex OUT VARCHAR2)
      RETURN NUMBER;

   /***********************************************************************
      Recupera el valor de la respuesta
      param in psproduc  : código producto
      param in pcpregun  : código pregunta
      param in pcrespue  : código respuesta
      param in pcidioma  : código idioma
      param out ptrespue : valor respuesta
      param in pnpoliza  : numero de poliza
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   -- Bug 0012227 - 18/12/2009 - JMF: Afegir sproduc
   -- BUG26501 - 21/01/2014 - JTT: Afegir pnpoliza
   FUNCTION f_get_pregunrespue(
      psproduc IN NUMBER,
      pcpregun IN NUMBER,
      pcrespue IN NUMBER,
      pcidioma IN NUMBER,
      ptrespue OUT VARCHAR2,
      pnpoliza IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /***********************************************************************
      Recupera el valor de la respuesta
      param in psproduc  : código de producto
      param in pcidioma  : código idioma
      param out ncount   : número registros
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_prodtienepregp(psproduc IN NUMBER, pcidioma IN NUMBER, ncount OUT NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Recupera el valor de la respuesta
      param in psproduc  : código de producto
      param in pcactivi  : código de actividad
      param in pcidioma  : código idioma
      param out ncount   : número registros
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_prodtienepregr(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcidioma IN NUMBER,
      ncount OUT NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Recupera el valor de la respuesta
      param in psproduc  : código de producto
      param in pcactivi  : código de actividad
      param in pcgarant  : código de garantia
      param in pcidioma  : código idioma
      param out ncount   : número registros
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_prodtienepregg(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcidioma IN NUMBER,
      ncount OUT NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Recupera el valor del producto
      param in psproduc  : código de producto
      param out pcrevali :
      param out pprevali :
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_revalprod(psproduc IN NUMBER, pcrevali OUT NUMBER, pprevali OUT NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Recupera el valor del producto
      param in psproduc  : código de producto
      param in pcactivi  : código actividad
      param in pcgarant  : código garantia
      param out pcrevali : codigo de revaloracion
      param out pprevali : porcentaje de revaloracion
      param out pirevali : importe de revaloracion
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_revalgaranpro(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcrevali OUT NUMBER,
      pprevali OUT NUMBER,
      pirevali OUT NUMBER)   -- BUG9906:DRA:28/04/2009
      RETURN NUMBER;

   /***********************************************************************
      Recupera la agrupación del producto buscándola por el SPRODUC (si el
      parám. no es null), o bien por CRAMO, CMODALI, CTIPSEG y CCOLECT.
      param in  p_sproduc : código de producto
      param in  p_cramo   : ramo
      param in  p_cmodali : modalidad
      param in  p_ctipseg : tipo
      param in  p_ccolect : colec.
      param out p_cagrpro : código de agrupación
      return              : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_agrupacio(
      p_sproduc IN NUMBER DEFAULT NULL,
      p_cramo IN NUMBER DEFAULT NULL,
      p_cmodali IN NUMBER DEFAULT NULL,
      p_ctipseg IN NUMBER DEFAULT NULL,
      p_ccolect IN NUMBER DEFAULT NULL,
      p_cagrpro OUT NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Recupera el código del producto a partir del código interno del seguro.
      param in  p_sseguro : código interno del seguro
      param out p_sproduc : código del producto asociado a la póliza
      return              : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_sproduc(p_sseguro IN NUMBER, p_sproduc OUT NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Recupera el código del producto a partir su ramo, modalidad, tipo de
      seguro y colectivo.
      param in  cramo      : código del ramo
                cmodali    : código de la modalidad
                ctipseg    : código del tipo de seguro
                ccolect    : código de la colectividad
      param out p_sproduc : código del producto asociado a la póliza
      return              : devuelve el sproduc si todo bien, sino null
   ***********************************************************************/
   FUNCTION f_get_sproduc(pcramo NUMBER, pcmodali NUMBER, pctipseg NUMBER, pccolect NUMBER)
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
      return              : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_ctarpol(
      p_cramo IN pregunpro.cramo%TYPE,
      p_cmodali IN pregunpro.cmodali%TYPE,
      p_ctipseg IN pregunpro.ctipseg%TYPE,
      p_ccolect IN pregunpro.ccolect%TYPE,
      p_cpregun IN pregunpro.cpregun%TYPE,
      p_ctarpol OUT pregunpro.ctarpol%TYPE)
      RETURN NUMBER;

   -- fin t.7817

   /**********************************************************************
     Devuelve 0 si no se tiene acceso a ese producto, y 1 si tiene acceso
    **********************************************************************/
   FUNCTION f_prodagente(
      psproduc IN productos.sproduc%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pctipo IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Recupera si un producto tiene cuestionario de salud
      param in psproduc  : código de producto
      param out pccuesti : indica si tiene cuestionario de salud
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_ccuesti(psproduc IN NUMBER, pccuesti OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_mesesextra(
      psproduc IN NUMBER,
      pmesesextra OUT VARCHAR2,
      pcmodextra OUT NUMBER)
      RETURN NUMBER;

   -- 24735.NMM.
   FUNCTION f_get_imesextra(
      psproduc IN NUMBER,
      pmesesextra OUT VARCHAR2,
      pcmodextra OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_get_pargarantia
      Retorna el valor de cpargar de una garantía
      param in psproduc  : código de producto
      param in pgarant   : código de la garantía
      param out pcvalpar : valor
      param in pcactivi  : codi activitat
      return             : devuelve 0 si todo bien, sino el código del error
   *************************************************************************/
   FUNCTION f_get_pargarantia(
      pclave IN VARCHAR2,
      psproduc IN NUMBER,
      pgarant IN NUMBER,
      pcvalpar OUT NUMBER,
      pcactivi IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_control_emision
      Retorna el valor de creteni
      param in psolicit   : número de solicitud
      param out pcreteni  : codi indicador proposta
      return              : devuelve 0 si todo bien, sino el código del error
   *************************************************************************/
   FUNCTION f_get_creteni(psolicit IN NUMBER, pcreteni OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_control_emision
      Retorna el valor de creteni
      param in psproduc   : código de producto
      param out pcdurmin  : duración mínima
      return              : devuelve 0 si todo bien, sino el código del error
   *************************************************************************/
   FUNCTION f_get_cdurmin(psproduc IN NUMBER, pcdurmin OUT NUMBER)
      RETURN NUMBER;

   -- BUG 9017 - 01/04/2009 - SBG - Creació funció f_get_filtroprod
   /***********************************************************************
      Retorna un filtre segons el paràmetre d'entrada
      param in p_tipo    : Tipo de productos requeridos:
                           'TF'         ---> Contratables des de Front-Office
                           'REEMB'      ---> Productos de salud
                           'APOR_EXTRA' ---> Con aportaciones extra
                           'SIMUL'      ---> Que puedan tener simulación
                           'RESCA'      ---> Que puedan tener rescates
                           'SINIS'      ---> Que puedan tener siniestros
                           null         ---> Todos los productos
      param out p_filtro : Sentencia de filtro
      return             : Devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_filtroprod(
      p_tipo IN VARCHAR2,
      p_filtro OUT VARCHAR2,
      p_cagente IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   -- FINAL BUG 9017 - 01/04/2009 - SBG

   -- BUG9661:DRA:15/04/2009: Inici
   /*************************************************************************
      Recuperar la lista de posibles valores de revalorización por producto
      param in p_sproduc : codigo del producto
      param in p_cidioma : codigo del idioma
      return             : VARCHAR2
   *************************************************************************/
   FUNCTION f_get_tipreval(p_sproduc IN NUMBER, p_cidioma IN NUMBER)
      RETURN VARCHAR2;

   -- BUG9661:DRA:15/04/2009: Fi

   -- BUG9906:DRA:28/04/2009: Inici
   /*************************************************************************
      Recuperar el tipo de revaloracion que aplica para la garantia
      param in p_sproduc    : codigo del producto
      param in p_cactivi    : codigo de la actividad
      param in p_cgarant    : codigo de la garantia
      param in p_crevalipol : codigo de revaloracion de la poliza
      param in p_prevalipol : porcentaje de revaloracion de la poliza
      param in p_irevalipol : importe de revaloracion de la poliza
      param out p_crevali   : codigo de revaloracion
      param out p_prevali   : porcentaje de revaloracion
      param out p_irevali   : importe de revaloracion
      return                : NUMBER
   *************************************************************************/
   FUNCTION f_get_revalgar(
      p_sproduc IN NUMBER,
      p_cactivi IN NUMBER,
      p_cgarant IN NUMBER,
      p_crevalipol IN NUMBER,
      p_prevalipol IN NUMBER,
      p_irevalipol IN NUMBER,
      p_crevali OUT NUMBER,
      p_prevali OUT NUMBER,
      p_irevali OUT NUMBER)
      RETURN NUMBER;

   -- BUG9906:DRA:28/04/2009: Fi

   /***********************************************************************
   Donat un producte retornem el codi de clàusula per defecte del producte.
   param in  p_sproduc: codi  producte
   return             : codi clàusula
   ***********************************************************************/
   -- BUG 12674.NMM.15/01/2010.i.
   FUNCTION f_get_claubenefi_def(
      p_sproduc IN productos.sproduc%TYPE,
      p_sclaben OUT productos.sclaben%TYPE)
      RETURN NUMBER;

-- BUG 12674.NMM.15/01/2010.f.

   -- BUG12760:DRA:03/02/2010:Inici
   /***********************************************************************
      Recupera si la pregunta es visible o no
      param in  p_sproduc  : código de productos
      param in  p_cpregun  : código de pregunta
      param out p_cvisible : 0-> No visible   1-> Visible
      return               : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_pregvisible(
      p_sproduc IN productos.sproduc%TYPE,
      p_cpregun IN pregunpro.cpregun%TYPE,
      p_cactivi IN pregunproactivi.cactivi%TYPE DEFAULT 0,   -- BUG 0036730 - FAL - 09/12/2015
      p_cvisible OUT NUMBER)
      RETURN NUMBER;

-- BUG12760:DRA:03/02/2010:Fi

   /***********************************************************************
      16.0        11/08/2010   SMF       16. 0015711: AGA003 - standaritzación del pac_cass
      Recupera si la póliza/ recibo pertenece a una poliza de un producto de salud (basada en F_esahorro
      param in  p_sseguro  : código de productos
      param in  p_nrecibo  : código de pregunta
      return               : devuelve 1 si es salud, en caso contrario 0
   ***********************************************************************/
   FUNCTION f_essalud(p_nrecibo IN recibos.nrecibo%TYPE, p_sseguro IN seguros.sseguro%TYPE)
      RETURN NUMBER;

--16.0        11/08/2010   SMF       16. 0015711: AGA003 - standaritzación del pac_cass

   -- Bug 0019578 - FAL - 26/09/2011 - Recuperar si derechos de registro nivel garantia
   /***********************************************************************
      Recupera el valor de garanpro
      param in psproduc  : código de producto
      param in pcactivi  : código actividad
      param in pcgarant  : código garantia
      param out pcderreg : código de si aplica derechos de registro
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_derreggaranpro(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcderreg OUT NUMBER)
      RETURN NUMBER;

-- Bug 0019578 - FAL - 26/09/2011 - Recuperar si derechos de registro nivel garantia

   -- BUG 0020671 - 03/01/2012 - JMF
   /***********************************************************************
      Recupera si la pregunta es visible o no
      param in  p_sproduc  : código de productos
      param in  p_cpregun  : código de pregunta
      param in  p_cactivi  : código de actividad
      param in  p_cgarant  : código de garantia
      param out p_cvisible : 0-> No visible   1-> Visible
      return               : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_pregunprogaranvisible(
      p_sproduc IN NUMBER,
      p_cpregun IN NUMBER,
      p_cactivi IN NUMBER,
      p_cgarant IN NUMBER,
      p_cvisible OUT NUMBER)
      RETURN NUMBER;

    -- BUG 0022839 - FAL - 24/07/2012
   /***********************************************************************
      Recupera si hereda agente, forpag, recfra, clausulas, garantias del certif 0
      param in p_sproduc  : código de producto
      param in p_tipo_heren: indica cuál herencia a recuperar (agente:1, forpag:2, recfra:3, clausulas:4, garantias:5)
      param out p_chereda : indica si hereda o no del certificado 0
      return             : devuelve 0 si todo bien, sino el código del error
   ***********************************************************************/
   FUNCTION f_get_herencia_col(
      p_sproduc IN NUMBER,
      p_tipo_heren IN NUMBER,
      p_chereda OUT NUMBER)
      RETURN NUMBER;

-- FI BUG 0022839

   -- BUG 0022839 - RSC - 13/08/2012
   FUNCTION f_get_frenova_col(pnpoliza IN NUMBER, pfrenova OUT DATE)
      RETURN NUMBER;
END pac_productos;

/

  GRANT EXECUTE ON "AXIS"."PAC_PRODUCTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PRODUCTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PRODUCTOS" TO "PROGRAMADORESCSI";
