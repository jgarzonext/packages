--------------------------------------------------------
--  DDL for Package PAC_MD_OBTENERDATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_OBTENERDATOS" IS
   /******************************************************************************
      NOMBRE:       PAC_MD_OBTENERDATOS
      PROP¿¿SITO: Recupera la informaci¿n de la poliza guardada en la base de datos

      REVISIONES:
      Ver        Fecha        Autor             Descripci¿¿n
      ---------  ----------  ---------------  ------------------------------------
      1.0        14/09/2007   ACC               1. Creaci¿¿n del package.
      2.0        16/09/2009   AMC               2. 11165: Se sustitu¿¿e  T_iax_saldodeutorseg por t_iax_prestamoseg
      3.0        16/12/2009   RSC               3. 0010690: APR - Provisiones en productos de cartera (PORTFOLIO)
      4.0        28/01/2010   RSC               4. 0011735: APR - suplemento de modificaci¿¿n de capital /prima
      5.0        23/06/2010   RSC               5. 0014598: CEM800 - Informaci¿¿n adicional en pantallas y documentos
      6.0        06/08/2010   PFA               6. 14598: CEM800 - Informaci¿¿n adicional en pantallas y documentos
      7.0        27/09/2011   DRA               7. 0019069: LCOL_C001 - Co-corretaje
      8.0        01/03/2012   APD               8. 0021121: MDP701 - TEC - DETALLE DE PRIMAS DE GARANTIAS
      9.0        08/03/2012   JMF               0021592: MdP - TEC - Gestor de Cobro
      10.0       04/06/2012   ETM               10. 0021657: MDP - TEC - Pantalla Inquilinos y Avalistas
      11.0       14/08/2012   DCG               11. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
      12.0       03/09/2012   JMF               0022701: LCOL: Implementaci¿¿n de Retorno
      13.0       01/11/2012   XVM               13. 0024058: LCOL_T010-LCOL - Parametrizaci?n de productos Vida Grupo
      14.0       06/11/2012   XVM               14. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
      15.0       11/05/2015   YDA               15. Se crea la funci¿n f_evoluprovmatseg_scen y se incluye el parametro pnscenario en f_leeevoluprovmatseg
      16.0       04/06/2015   YDA               16. Se crea la funci¿n f_evoluprovmatseg_minscen
      17.0       03/07/2015   YDA               17. 0036596: Se crea la funci¿n f_get_exclusiones
      18.0       27/07/2015   IGIL              18. 0036596: Se crea la funci¿n f_leecitamedica
      19.0       05/08/2015   YDA               19. 0036596: Se crea la funci¿n f_lee_enfermedades
      20.0       10/08/2015   YDA               20. 0036596: Se crea la funci¿n f_lee_preguntas
      21.0       12/08/2015   YDA               21. 0036596: Se crea la funci¿n f_lee_acciones
      22.0       07/03/2016   JAEG              22. 40927/228750: Desarrollo Dise¿o t¿cnico CONF_TEC-03_CONTRAGARANTIAS
      23.0       21/01/2020   JLTS              23. IAXIS-10627. Se ajustó la función f_leecorretaje incluyendo el parámetro NMOVIMI
   ******************************************************************************/

   /*************************************************************************
      Define con que tablas se trabajar¿¿
      param in pmode     : modo a trabajar
      param out mensajes : mesajes de error
   *************************************************************************/
   PROCEDURE define_mode(pmode    IN VARCHAR2,
                         mensajes IN OUT t_iax_mensajes);

   /*************************************************************************
      Devuelve la descripci¿¿n del riesgo
      param in pmode     : modo a trabajar
      param in psolicit  : n¿¿mero de seguro
      param in pnriesgo  : n¿¿mero de riesgo
      param out mensajes : mesajes de error
      return             : descripci¿¿n del riesgo
   *************************************************************************/
   FUNCTION f_desriesgos(pmode    IN VARCHAR2,
                         psolicit IN NUMBER,
                         pnriesgo IN NUMBER,
                         mensajes IN OUT t_iax_mensajes) RETURN VARCHAR2;

   /*************************************************************************
      Devuelve la descripci¿¿n del riesgo
      param in pmode     : modo a trabajar
      param in psseguro  : n¿¿mero de seguro
      param in pnriesgo  : n¿¿mero de riesgo
      return             : descripci¿¿n del riesgo
                           '***' si se ha produccido un error.
   *************************************************************************/
   FUNCTION f_desriesgos(pmode    IN VARCHAR2,
                         psseguro IN NUMBER,
                         pnriesgo IN NUMBER) RETURN VARCHAR2;

   /*************************************************************************
      Inicializa ejecuci¿¿n package
      param in pmode     : modo a trabajar
      param in pssolicit : c¿¿digo de seguro
      param in pnmovimi  : n¿¿mero de movimientos
      param out mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_inicializa(pmode     IN VARCHAR2,
                         pssolicit IN NUMBER,
                         pnmovimi  IN NUMBER DEFAULT 1,
                         mensajes  IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
      Devuelve el tipo de riesgo objeto asegurado
      param in psolicit  : n¿¿mero de seguro
      param in pmode     : modo a trabajar
      param out mensajes : mesajes de error
      return             : c¿¿digo objeto asegurado
   *************************************************************************/
   FUNCTION f_getobjase(psolicit IN NUMBER,
                        pmode    IN VARCHAR2,
                        mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
      Lee los datos de la p¿¿liza
      param out mensajes : mesajes de error
      return             : objeto detalle p¿¿liza
   *************************************************************************/
   FUNCTION f_leedatospoliza(mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_detpoliza;

   /*************************************************************************
      Lee los datos generales de la p¿¿liza
      param in polObj    : envia el objeto persistente para recuperar la
                           informaci¿¿n necesaria puede ser nulo en tal caso
                           se recupera de la db
      param out mensajes : mesajes de error
      return             : objeto datos generales p¿¿liza
   *************************************************************************/
   FUNCTION f_leedatosgenpoliza(polobj   IN ob_iax_detpoliza,
                                mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_genpoliza;

   /*************************************************************************
      Lee tomadores
      param out mensajes : mesajes de error
      return             : objeto tomadores
   *************************************************************************/
   FUNCTION f_leetomadores(mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_tomadores;

   /*************************************************************************
      Lee los datos de gesti¿¿n
      param out mensajes : mesajes de error
      return             : objeto gesti¿¿n
   *************************************************************************/
   FUNCTION f_leedatosgestion(mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_gestion;

   /*************************************************************************
      Lee riesgos
      param out mensajes             : mesajes de error
      param in pnriesgo default null : n¿¿mero de riesgo
      return                         : objeto riesgos
   *************************************************************************/
   FUNCTION f_leeriesgos(mensajes IN OUT t_iax_mensajes,
                         pnriesgo IN NUMBER DEFAULT NULL) RETURN t_iax_riesgos;

   /*************************************************************************
      Lee riesgo
      param in pnriesgo  : n¿¿mero de riesgo
      param out mensajes : mesajes de error
      return             : objeto riesgo
   *************************************************************************/
   FUNCTION f_leeriesgo(pnriesgo IN NUMBER,
                        mensajes IN OUT t_iax_mensajes) RETURN ob_iax_riesgos;

   /*************************************************************************
      Lee cl¿¿usulas
      param out mensajes : mesajes de error
      return             : objeto clausulas
   *************************************************************************/
   FUNCTION f_leeclausulas(mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_clausulas;

   /*************************************************************************
      Lee las primas de la p¿¿liza
      param in out detpoliza: objeto detalle poliza
      param out mensajes : mesajes de error
      return             : objeto detalle p¿¿liza
   *************************************************************************/
   FUNCTION f_leeprimas(detpoliza IN OUT ob_iax_detpoliza,
                        mensajes  IN OUT t_iax_mensajes) RETURN t_iax_primas;

   /*************************************************************************
      Lee las preguntas de la p¿¿liza
      param out mensajes : mesajes de error
      return             : objeto preguntas
   *************************************************************************/
   FUNCTION f_leepreguntaspoliza(mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_preguntas;

   /*************************************************************************
      Lee gesti¿¿n comisi¿¿n
      param out mensajes : mesajes de error
      return             : objeto gesti¿¿n comisi¿¿n
   *************************************************************************/
   FUNCTION f_leegstcomision(mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_gstcomision;

   /************************************************************************
      Recupera informaci¿¿n del riesgo -->>
   *************************************************************************/

   /*************************************************************************
      Lee las primas del riesgo
      param in riesgo    : objecte risc a omplir dades
      param out mensajes : mesajes de error
      return             : objeto detalle p¿¿liza
   *************************************************************************/
   FUNCTION f_leeriesgoprimas(riesgo   IN OUT ob_iax_riesgos,
                              mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_primas;

   /*************************************************************************
      Recuperar la informaci¿¿n del riesgo personal
      param in pnriesgo  : n¿¿mero de riesgo
      param out mensajes : mesajes de error
      return             : objeto detalle p¿¿liza
   *************************************************************************/
   FUNCTION f_leeriesgopersonal(pnriesgo IN NUMBER,
                                mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_personas;

   /*************************************************************************
      Recuperar la informaci¿¿n del riesgo direcciones
      param in pnriesgo  : n¿¿mero de riesgo
      param out mensajes : mesajes de error
      return             : objeto detalle p¿¿liza
   *************************************************************************/
   FUNCTION f_leeriesgodirecciones(pnriesgo IN NUMBER,
                                   mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_sitriesgos;

   /*************************************************************************
      Recuperar la informaci¿¿n de los asegurados
      param out mensajes : mesajes de error
      param in pnriesgo  : n¿¿mero de riesgo
      return             : objeto asegurados
   *************************************************************************/
   FUNCTION f_leeasegurados(pnriesgo IN NUMBER,
                            mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_asegurados;

   /*************************************************************************
      Recuperar la informaci¿¿n de las preguntas
      param in pnriesgo  : n¿¿mero de riesgo
      param out mensajes : mesajes de error
      return             : objeto preguntas
   *************************************************************************/
   FUNCTION f_leepreguntasriesgo(pnriesgo IN NUMBER,
                                 mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_preguntas;

   /*************************************************************************
      Recuperar la informaci¿¿n de las garantias
      param in pnriesgo  : n¿¿mero de riesgo
      param out mensajes : mesajes de error
      return             : objeto garantias
   *************************************************************************/
   FUNCTION f_leegarantias(pnriesgo IN NUMBER,
                           mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_garantias;

   /*************************************************************************
           Recuperar informaci¿¿n de las de garantias -->>
   *************************************************************************/

   /*************************************************************************
      Recuperar la informaic¿¿n de las preguntas de garantias
      param in pnriesgo  : n¿¿mero de riesgo
      param in pcgarant  : c¿¿digo de garantia
      param out mensajes : mesajes de error
      return             : objeto preguntas
   *************************************************************************/
   FUNCTION f_leepreguntasgarantia(pnriesgo IN NUMBER,
                                   pcgarant IN NUMBER,
                                   mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_preguntas;

   /*************************************************************************
      Lee las primas de la garantia
      param in pnriesgo  : n¿¿mero de riesgo
      param in pcgarant  : c¿¿digo de garantia
      param out mensajes : mesajes de error
      return             : objeto detalle p¿¿liza
   *************************************************************************/
   FUNCTION f_leeprimasgarantia(pnriesgo IN NUMBER,
                                pcgarant IN NUMBER,
                                mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_primas;

   /*************************************************************************
            <<-- Recuperar informaci¿¿n de las de garantias
   *************************************************************************/

   /*************************************************************************
      Recuperar la informaci¿¿n de beneficiarios
      param in pnriesgo  : n¿¿mero de riesgo
      param out mensajes : mesajes de error
      return             : objeto beneficiarios
   *************************************************************************/
   FUNCTION f_leebeneficiarios(pnriesgo IN NUMBER,
                               mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_beneficiarios;

   /*************************************************************************
      Recuperar la informaci¿¿n de los beneficiarios nominales
      param out mensajes : mesajes de error
      return             : objeto beneficiarios nominales
   *************************************************************************/
   FUNCTION f_leebenenominales(pnriesgo IN NUMBER,
                               mensajes OUT t_iax_mensajes)
      RETURN t_iax_benenominales;

   /*************************************************************************
      Recuperar la informaci¿¿n del detalle de automoviles
      parma in pnriesgo  : n¿¿mero de riesgo
      param out mensajes : mesajes de error
      return             : objeto riesgo automoviles
   *************************************************************************/
   FUNCTION f_leeriesgoauto(pnriesgo IN NUMBER,
                            mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_autriesgos;

   /* Recupera informaci¿¿n del detalle riesgo automovil -->> */

   /*************************************************************************
      Recuperar la informaci¿¿n de los conductores
      param in pnriesgo  : n¿¿mero de riesgo
      param out mensajes : mesajes de error
      return             : objeto conductores
   *************************************************************************/
   FUNCTION f_leeconductores(pnriesgo IN NUMBER,
                             mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_autconductores;

   /*************************************************************************
      Recuperar la informaci¿¿n de accesorios en el riesgo automoviles
      param in pnriesgo  : n¿¿mero de riesgo
      param out mensajes : mesajes de error
      return             : objeto detalle p¿¿liza
   *************************************************************************/
   FUNCTION f_leeaccesoriosauto(pnriesgo IN NUMBER,
                                mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_autaccesorios;

   /* <<-- Recupera informaci¿¿n del detalle riesgo automovil */

   /* <<-- Recupera informaci¿¿n del riesgo */

   /*************************************************************************
      Recuperar la informaci¿¿n de las rentas irregulares
      param in pnriesgo  : n¿¿mero de riesgo
      param out mensajes : mesajes de error
      return             : objeto garantias
   *************************************************************************/
   FUNCTION f_leerentasirreg(pnriesgo IN NUMBER,
                             mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_rentairr;

   /*************************************************************************
      Recuperar la informaci¿¿n del riesgo descripcion
      param in pnriesgo  : n¿¿mero de riesgo
      param out mensajes : mesajes de error
      return             : objeto detalle p¿¿liza
   *************************************************************************/
   FUNCTION f_leeriesgodescripcion(pnriesgo IN NUMBER,
                                   mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_descripcion;

   /*************************************************************************
      Recuperar la informaci¿¿n de los meses que tienen paga extra
      param in psseguro  : n¿¿mero de seguro
      param out mensajes : mesajes de error
      return             : objeto detalle meses paga extra
   *************************************************************************/
   FUNCTION f_leermesesextra(psseguro IN NUMBER,
                             mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_nmesextra;

   /*************************************************************************
      Nos devuelve si un producto permite modificar las pagas extras en la p¿¿liza
      param in psproduc  : n¿¿mero de producto
      param out mensajes : mesajes de error
      return             : el campo cmodextra
   *************************************************************************/
   FUNCTION f_leer_cmodextra(psproduc IN NUMBER,
                             mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
      Recuperar la informaci¿¿n de los meses que tienen paga extra de un producto
      param in psproduc  : n¿¿mero de producto
      param out mensajes : mesajes de error
      return             : objeto detalle meses paga extra
   *************************************************************************/
   FUNCTION f_leermesesextrapro(psproduc   IN NUMBER,
                                pcmodextra OUT NUMBER,
                                mensajes   IN OUT t_iax_mensajes)
      RETURN ob_iax_nmesextra;

   /*************************************************************************
      Lee distribucion
      param out mensajes : mesajes de error
      return             : objeto clausulas
   *************************************************************************/
   -- Bug 9031 - 17/03/2009 - RSC -  iAxis: An¿¿lisis adaptaci¿¿n productos indexados
   -- Bug 10385 - 14/07/2009 - AMC - Se a¿¿ade el parametro psseguro, si viene a null se coge el vsolicit
   FUNCTION f_leedistribucionfinv(mensajes IN OUT t_iax_mensajes,
                                  psseguro IN NUMBER DEFAULT NULL)
      RETURN ob_iax_produlkmodelosinv;

   FUNCTION f_leedatosgarantias(pnriesgo IN NUMBER,
                                pcgarant IN NUMBER,
                                pndetgar IN NUMBER,
                                mensajes IN OUT t_iax_mensajes,
                                psseguro IN NUMBER DEFAULT NULL)
      RETURN ob_iax_masdatosgar;

   /*************************************************************************
   Bug 13884: CEM - Escut Total - Conversi¿¿n a capital decreciente
      Lee los datos de los del cuadro de prestamos
      param out mensajes : mesajes de error
      return             : objeto t_iax_prestcuadroseg
   *************************************************************************/
   FUNCTION f_leeprestcuadroseg(psseguro IN NUMBER,
                                pnmovimi IN NUMBER,
                                pctapres IN VARCHAR2,
                                mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prestcuadroseg;

   /*************************************************************************
    Bug 10702 - Nueva pantalla para contrataci¿¿n y suplementos que
    permita seleccionar cuentas aseguradas. nova funci¿¿ XPL
      Lee los datos de los saldos deutores
      param out mensajes : mesajes de error
      return             : objeto detalle p¿¿liza
   *************************************************************************/
   -- Bug 11165 - 16/09/2009 - AMC - Se sustitu¿¿e  T_iax_saldodeutorseg por t_iax_prestamoseg
   FUNCTION f_leesaldodeutors(mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prestamoseg;

   /*************************************************************************
    Bug 10690 - Nueva seccion en la consulta de p¿¿liza. Provisiones por garant¿¿a.
      param IN sseguro : mesajes de error
      param out mensajes : mesajes de error
      return             : objeto detalle garant¿¿as
   *************************************************************************/
   -- Bug 10690 - 16/12/2009 - RSC - APR - Provisiones en productos de cartera (PORTFOLIO)
   FUNCTION f_leeprovisionesgar(psseguro IN NUMBER,
                                mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_garantias;

   /*************************************************************************
    Bug 10690 - Nueva seccion en la consulta de p¿¿liza. Provision por p¿¿liza.
      param IN sseguro : mesajes de error
      param out mensajes : mesajes de error
      return             : objeto detalle garant¿¿as
   *************************************************************************/
   -- Bug 10690 - 16/12/2009 - RSC - APR - Provisiones en productos de cartera (PORTFOLIO)
   FUNCTION f_leeprovisionpol(psseguro IN NUMBER,
                              mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_datoseconomicos;

   /*************************************************************************
      Recuperar la informaci¿¿n de las garantias (suplementos econ¿¿micos)
      param in pnriesgo  : n¿¿mero de riesgo
      param out mensajes : mesajes de error
      return             : objeto garantias
   *************************************************************************/
   -- Bug 11735 - RSC - 28/01/2010 - APR - suplemento de modificaci¿¿n de capital /prima
   FUNCTION f_leegarantias_supl(psseguro IN NUMBER,
                                pnriesgo IN NUMBER,
                                mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_garantias;

   /*************************************************************************
      Recuperar la informaci¿¿n de evoluprovmatseg
      param in sseguro   : n¿¿mero de seguro
      param in ptablas   : tablas a consultar
      param out mensajes : mesajes de error
      return             : objeto garantias
   *************************************************************************/
   -- Bug 14598 - RSC - 23/06/2010 - CEM800 - Informaci¿¿n adicional en pantallas y documentos
   -- Bug 14598 - PFA - 06/08/2010 - a¿¿adir parametro ptablas
   FUNCTION f_leeevoluprovmatseg(psseguro   IN NUMBER,
                                 ptablas    IN VARCHAR2,
                                 pnscenario IN NUMBER,
                                 mensajes   IN OUT t_iax_mensajes)
      RETURN t_iax_evoluprovmat;

   -- Fin Bug 14598
   /*************************************************************************
      Lee los datos del desglose de capitales de garantias
      param out mensajes : mesajes de error
      return             : objeto gesti¿¿n
   *************************************************************************/
   FUNCTION f_lee_desglosegarantias(psseguro IN NUMBER,
                                    pnriesgo IN NUMBER,
                                    pcgarant IN NUMBER,
                                    pnorden  IN NUMBER,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_desglose_gar;

   /*************************************************************************
      Lee reglas (APRA - GROUPLIFE)
      param out mensajes : mesajes de error
      return             : objeto clausulas
   *************************************************************************/
   -- Bug 16106 - RSC - 23/09/2010 - APR - Ajustes e implementaci¿¿n para el alta de colectivos
   FUNCTION f_leereglasseg(psseguro IN NUMBER,
                           pnriesgo IN NUMBER,
                           pcgarant IN NUMBER,
                           pnmovimi IN NUMBER,
                           mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_reglasseg;

   /*************************************************************************
      Lee reglas (APRA - GROUPLIFE)
      param out mensajes : mesajes de error
      return             : objeto clausulas
   *************************************************************************/
   FUNCTION f_leereglassegtramos(psseguro IN NUMBER,
                                 pnriesgo IN NUMBER,
                                 pcgarant IN NUMBER,
                                 pnmovimi IN NUMBER,
                                 mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_reglassegtramos;

   /*************************************************************************
      Devuelve el capital de una garantia
      param in psseguro   : numero de seguro
      param in pnriesgo   : numero de riesgo
      param in pcgarant   : codigo de la garantia
      param in ptablas    : tablas donde hay que ir a buscar la informaci¿¿n
      param out mensajes : mesajes de error
      return             : Impporte del capital

      Bug 18342 - 24/05/2011 - AMC
   *************************************************************************/
   FUNCTION f_leecapital(psseguro IN NUMBER,
                         pnriesgo IN NUMBER,
                         pcgarant IN NUMBER,
                         ptablas  IN VARCHAR2,
                         mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   -- BUG19069:DRA:27/09/2011:Inici
   -- INI -IAXIS-10627 -21/01/2020
   FUNCTION f_leecorretaje(pnmovimi IN NUMBER DEFAULT NULL,
		                       mensajes IN OUT t_iax_mensajes)
	 -- FIN -IAXIS-10627 -21/01/2020
      RETURN t_iax_corretaje;

   -- BUG19069:DRA:27/09/2011:Fi

   /*************************************************************************
      Lee los datos del detalle de primas de garantias
      param out mensajes : mesajes de error
      return             : objeto detprimas
   *************************************************************************/
   -- Bug 21121 - APD - 01/03/2012 - se crea la funcion
   FUNCTION f_lee_detprimas(psseguro IN NUMBER,
                            pnriesgo IN NUMBER,
                            pcgarant IN NUMBER,
                            pnmovimi IN NUMBER,
                            pfiniefe IN DATE,
                            mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_detprimas;

   /*************************************************************************
      Lee gestor cobro
      param out mensajes : mesajes de error
      return             : objeto gestor cobro
   *************************************************************************/
   -- BUG 0021592 - 08/03/2012 - JMF
   FUNCTION f_leegescobro(mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_gescobros;

   FUNCTION f_lee_riesgo(mensajes IN OUT t_iax_mensajes,
                         pnriesgo IN NUMBER DEFAULT NULL)
      RETURN ob_iax_riesgos;

   --bfp bug 21947 ini
   FUNCTION f_leergaransegcom(psseguro IN NUMBER,
                              pnriesgo IN NUMBER,
                              mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_garansegcom;

   --bbp bug 21947 fi
   --BUG 21657--ETM--04/06/2012
   FUNCTION f_leeinquiaval(mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_inquiaval;

   -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   --BUG 0023183: XVM :26/10/2012--A¿adir pmodo
   /*************************************************************************
      Lee cuadro de coaseguro
      param in psseguro         : N¿mero seguro
      param in out mensajes     : mesajes de error
      param in pmodo default 0  : Informa en que modo estamos:
                                  1.-Alta p¿liza
                                  otros. - No alta p¿liza.
      return                    : objeto cuadro coa.
   *************************************************************************/
   FUNCTION f_leercoacuadro(psseguro IN NUMBER,
                            mensajes IN OUT t_iax_mensajes,
                            pmodo    IN NUMBER DEFAULT 0)
      RETURN ob_iax_coacuadro;

   -- Bug 0022701 - 03/09/2012 - JMF
   FUNCTION f_leeretorno(mensajes IN OUT t_iax_mensajes) RETURN t_iax_retorno;

   FUNCTION f_leerfranquicias(psseguro IN NUMBER,
                              pnriesgo IN NUMBER,
                              mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_bonfranseg;

   /*************************************************************************
      Devuelve el caso bpm

      param out mensajes : mesajes de error
      return             : caso bpm

      Bug 28263/153355 - 01/10/2013 - AMC
   *************************************************************************/
   FUNCTION f_lee_caso_bpmseg(mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_bpm;

   /*************************************************************************
      Obtiene los asegurados mes del supemento de regularizaci¿n

      param out mensajes : mesajes de error
      return             : caso bpm

      Convenios
   *************************************************************************/
   FUNCTION f_leeraseguradosmes(pnriesgo IN NUMBER,
                                pnmovimi IN NUMBER DEFAULT NULL,
                                mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_aseguradosmes;

   /*************************************************************************
      Lee  laversi¿n de convenio
      param in psseguro         : Numero seguro
      param in out mensajes     : mesajes de error
      pa
      return                    : objeto version
   *************************************************************************/
   FUNCTION f_leer_convempvers(psseguro IN NUMBER,
                               mensajes IN OUT t_iax_mensajes,
                               pmodo    IN NUMBER DEFAULT 0)
      RETURN ob_iax_convempvers;

   -- JLTS
   /*    Recuperar la informacion de agensegu
   param in pnriesgo  : secuencia del seguro
   param out mensajes : mesajes de error
   return             : objeto detalle poliza
   *************************************************************************/
   FUNCTION f_leeragensegu(pmode    IN VARCHAR2,
                           psseguro IN NUMBER,
                           mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_agensegu;
   -- JLTS

   /*************************************************************************
     funcion que retorna los cuadros de amortizacion de un prestamo.
     param psseguro : codigo del seguro
     param mensajes : mensajes registrados en el proceso
     return : t_iax_prestcuadroseg tabla PL con objetos de cuadro de prestamo
     Bug 35712 mnustes
   *************************************************************************/
   FUNCTION f_lee_prestcuadroseg(psseguro IN seguros.sseguro%TYPE,
                                 mensajes OUT t_iax_mensajes)
      RETURN t_iax_prestcuadroseg;

   /*************************************************************************
      Recupera lista de escenarios de proyecciones de interes
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_evoluprovmatseg_scen(psseguro IN NUMBER,
                                   ptablas  IN VARCHAR2,
                                   mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

   /*************************************************************************
      Recupera m¿nimo escenario de proyecciones de interes
      param out mensajes : mesajes de error
      return             : number
   *************************************************************************/
   FUNCTION f_evoluprovmatseg_minscen(psseguro IN NUMBER,
                                      ptablas  IN VARCHAR2,
                                      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve las exclusiones de una p¿liza
      param in psseguro   : numero de seguro
      param in pnriesgo   : numero de riesgo
      param in ptablas    : tablas donde hay que ir a buscar la informaci¿n
      param out mensajes  : mesajes de error
      return              : Tabla de exclusiones

      Bug 36596/208854 - YDA
   *************************************************************************/
   FUNCTION f_get_exclusiones(psseguro IN NUMBER,
                              pnriesgo IN NUMBER,
                              ptablas  IN VARCHAR2,
                              mensajes OUT t_iax_mensajes)
      RETURN t_iax_exclusiones;

   /*************************************************************************
      Recuperar la informacion de los citamedica

   *************************************************************************/
   FUNCTION f_leecitamedica(psseguro IN NUMBER,
                            pssegpol IN NUMBER,
                            pmodo    IN VARCHAR2,
                            mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_citamedica;

   /*************************************************************************
      Recuperar la informacion de las enfermedades
   *************************************************************************/
   FUNCTION f_lee_enfermedades(psseguro IN NUMBER,
                               mensajes OUT t_iax_mensajes)
      RETURN t_iax_enfermedades_undw;

   /*************************************************************************
      Recupera la informacion de las preguntas base
   *************************************************************************/
   FUNCTION f_lee_preguntas(psseguro IN NUMBER,
                            mensajes OUT t_iax_mensajes)
      RETURN t_iax_basequestion_undw;

   /*************************************************************************
      Recupera la informacion de las acciones de los asegurados
   *************************************************************************/
   FUNCTION f_lee_acciones(psseguro IN NUMBER,
                           mensajes OUT t_iax_mensajes)
      RETURN t_iax_actions_undw;

   /*************************************************************************
      FUNCTION f_leecontgaran

      param in psseguro    : psseguro
      param in mensajes    : t_iax_mensajes
      return               : t_iax_contragaran
   *************************************************************************/
   FUNCTION f_leecontgaran(psseguro IN NUMBER,
                           mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_contragaran;
END pac_md_obtenerdatos;
/
