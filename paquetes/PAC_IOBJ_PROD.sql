--------------------------------------------------------
--  DDL for Package PAC_IOBJ_PROD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IOBJ_PROD" AS
   /******************************************************************************
      NOMBRE:       PAC_IOBJ_PROD
      PROPÓSITO:  Funciones de tratamiento objetos produccion

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        25/01/2008   ACC                1. Creación del package.
      2.0        27/02/2009   RSC                2. Adaptación iAxis a productos colectivos con certificados
      3.0        11/03/2009   RSC                2. iAxis: Análisis adaptación productos indexados
      4.0        16/09/2009   AMC                4. 11165: Se sustituñe  T_iax_saldodeutorseg por t_iax_prestamoseg
      5.0        01/06/2011   APD                5. 0018362: LCOL003 - Parámetros en cláusulas y visualización cláusulas automáticas
      6.0        27/09/2011   DRA                6. 0019069: LCOL_C001 - Co-corretaje
      7.0        08/03/2012   JMF                0021592: MdP - TEC - Gestor de Cobro
      8.0        02/05/2011   MDS                8. 0021907: MDP - TEC - Descuentos y recargos (técnico y comercial) a nivel de póliza/riesgo/garantía
      9.0        04/06/2012   ETM                9. 0021657: MDP - TEC - Pantalla Inquilinos y Avalistas
     10.0        14/08/2012   DCG               10. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
     11.0        03/09/2012   JMF               0022701: LCOL: Implementación de Retorno
     12.0        27/07/2015   IGIL              0036596 MSV - get y set de type citas medicas
     13.0        21/01/2020   JLTS               13. IAXIS-10627. Se ajustó la función f_partpolcorretaje incluyendo el parámetro NMOVIMI
   ******************************************************************************/

   /*************************************************************************
   **
   ** Funciones para devolución de partes del objeto poliza
   **
   *************************************************************************/

   /*************************************************************************
      Recupera la poliza como objeto persistente
      param out mensajes : mensajes de error
      return             : objeto detalle póliza
   *************************************************************************/
   FUNCTION f_getpoliza(mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_detpoliza;

   /*************************************************************************
      Establece la poliza como objeto persistente
      param out mensajes : mensajes de error
   *************************************************************************/
   PROCEDURE p_set_poliza(detpoliza IN ob_iax_detpoliza);

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto tomadores
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto colección tomadores
   *************************************************************************/
   FUNCTION f_partpoltomadores(poliza   IN ob_iax_detpoliza,
                               mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_tomadores;

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto gestion
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto gestion
   *************************************************************************/
   FUNCTION f_partpoldatosgestion(poliza   IN ob_iax_detpoliza,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_gestion;

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto preguntas poliza
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto preguntas
   *************************************************************************/
   FUNCTION f_partpolpreguntas(poliza   IN ob_iax_detpoliza,
                               mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_preguntas;

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto riesgos
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto colección riesgos
   *************************************************************************/
   FUNCTION f_partpolriesgos(poliza   IN ob_iax_detpoliza,
                             mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_riesgos;

   -- JLTS
   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto agendas
      param in poliza       : objeto detalle pÃ³liza
      param in out mensajes : colecciÃ³n de mensajes
      return                : objeto colecciÃ³n agendas
   *************************************************************************/
   FUNCTION f_partpolagensegu(poliza   IN ob_iax_detpoliza,
                              mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_agensegu;
   -- JLTS

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto riesgo
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto riesgos
   *************************************************************************/
   FUNCTION f_partpolriesgo(poliza   IN ob_iax_detpoliza,
                            pnriesgo IN NUMBER,
                            mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_riesgos;

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto clausulas
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto colección clausulas
   *************************************************************************/
   FUNCTION f_partpolclausulas(poliza   IN ob_iax_detpoliza,
                               mensajes IN OUT t_iax_mensajes,
                               pmode    IN VARCHAR2 DEFAULT 'EST') -- Bug 18362 - APD - 01/06/2011
    RETURN t_iax_clausulas;

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto primas
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto colección primas
   *************************************************************************/
   FUNCTION f_partpolprimas(poliza   IN ob_iax_detpoliza,
                            mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_primas;

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto comisiones
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto colección de comisiones
   *************************************************************************/
   FUNCTION f_partpolcomisiones(poliza   IN ob_iax_detpoliza,
                                mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_gstcomision;

   /*************************************************************************
      Devuelve parte del objeto riesgo a un objeto riespersonal
      param in riesgo       : objeto riesgo
      param in out mensajes : colección de mensajes
      return                : objeto colección personas
   *************************************************************************/
   FUNCTION f_partriespersonal(riesgo   IN ob_iax_riesgos,
                               mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_personas;

   /*************************************************************************
      Devuelve parte del objeto riesgo a un objeto riesdirecciones
      param in riesgo       : objeto riesgo
      param in out mensajes : colección de mensajes
      return                : objeto colección de direcciones
   *************************************************************************/
   FUNCTION f_partriesdirecciones(riesgo   IN ob_iax_riesgos,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_sitriesgos;

   /*************************************************************************
      Devuelve parte del objeto riesgo a un objeto riesgoase
      param in riesgo       : objeto riesgo
      param in out mensajes : colección de mensajes
      return                : objeto colección asegurados
   *************************************************************************/
   FUNCTION f_partriesasegurado(riesgo   IN ob_iax_riesgos,
                                mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_asegurados;

   /*************************************************************************
      Devuelve parte del objeto riesgo a un objeto preguntas
      param in riesgo       : objeto riesgo
      param in out mensajes : colección de mensajes
      return                : objeto colección preguntas
   *************************************************************************/
   FUNCTION f_partriespreguntas(riesgo   IN ob_iax_riesgos,
                                mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_preguntas;

   /*************************************************************************
      Devuelve parte del objeto riesgo a un objeto garantias
      param in riesgo       : objeto riesgo
      param in out mensajes : colección de mensajes
      return                : objeto colección garantias
   *************************************************************************/
   FUNCTION f_partriesgarantias(riesgo   IN ob_iax_riesgos,
                                mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_garantias;

   /*************************************************************************
      Devuelve parte del objeto riesgo a un objeto garantia
      param in riesgo       : objeto riesgo
      param in cgarant      : código de garantia
      param in out mensajes : colección de mensajes
      return                : objeto garantia
   *************************************************************************/
   FUNCTION f_partriesgarantia(riesgo   IN ob_iax_riesgos,
                               cgarant  IN NUMBER,
                               mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_garantias;

   /*************************************************************************
      Devuelve parte del objeto riesgo a un objeto beneficiarios
      param in riesgo       : objeto riesgo
      param in out mensajes : colección de mensajes
      return                : objeto beneficiario
   *************************************************************************/
   FUNCTION f_partriesbeneficiarios(riesgo   IN ob_iax_riesgos,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_beneficiarios;

   /*************************************************************************
      Devuelve parte del objeto riesgo a un objeto beneficiarios nominales
      param in riesgo       : objeto riesgo
      param in out mensajes : colección de mensajes
      return                : objeto colección beneficiarios nominales
   *************************************************************************/
   FUNCTION f_partriesbenenominales(riesgo   IN ob_iax_riesgos,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_benenominales;

   /*************************************************************************
      Devuelve parte del objeto garantias a un objeto preguntas
      param in garantia       : objeto garantia
      param in out mensajes : colección de mensajes
      return                : objeto colección preguntas
   *************************************************************************/
   FUNCTION f_partgarpreguntas(garantia IN ob_iax_garantias,
                               mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_preguntas;

   /*************************************************************************
      Devuelve parte del objeto automovil a un objeto conductores
      param in autos       : objeto automovil
      param in out mensajes : colección de mensajes
      return                : objeto colección conductores
   *************************************************************************/
   FUNCTION f_partautconductores(autos    IN ob_iax_autriesgos,
                                 mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_autconductores;

   /*************************************************************************
      Devuelve parte del objeto automovil a un objeto accesorios
      param in autos       : objeto automovil
      param in out mensajes : colección de mensajes
      return                : objeto colección accesorios
   *************************************************************************/
   FUNCTION f_partautaccesorios(autos    IN ob_iax_autriesgos,
                                mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_autaccesorios;

   /***********************************************************************/

   --JRH 03/2008
   /*************************************************************************
      Devuelve parte del objeto aqsociado a rentas irregulares
      param in riesgo       : objeto riesgo
      param in out mensajes : colección de mensajes
      return                : objeto colección de rentas irregulares
   *************************************************************************/
   FUNCTION f_partrentirreg(riesgo   IN ob_iax_riesgos,
                            mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_rentairr;

   --JRH 03/2008
   /***********************************************************************/
   --JRH 03/2008
   /*************************************************************************
      Sustituye el objeto renta irregular del riesgo determinado
      param in poliza       : objeto riesgo
      param in nriesgo      : número de riesgo
      param in irreg         : objeto con rentas irregulares del riesgo
      param in out mensajes : colección de mensajes
      return                : objeto colección preguntas
   *************************************************************************/
   FUNCTION f_set_partriesrentirreg(poliza   IN OUT ob_iax_detpoliza,
                                    nriesgo  IN riesgos.nriesgo%TYPE,
                                    irreg    IN t_iax_rentairr,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   --JRH 03/2008
   /*************************************************************************
   **
   ** Funciones para incluir partes del objeto poliza
   **
   *************************************************************************/

   /*************************************************************************
      Sustituye el objeto tomadores
      param in poliza       : objeto poliza
      param in tom          : objeto tomadores
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_parttomadores(poliza   IN OUT ob_iax_detpoliza,
                                tom      IN t_iax_tomadores,
                                mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
      Sustituye el objeto gestor cobro
      param in poliza       : objeto poliza
      param in tom          : objeto gestor cobro
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   -- Bug 0021592 - 08/03/2012 - JMF
   FUNCTION f_set_partgestorcobro(poliza   IN OUT ob_iax_detpoliza,
                                  gesc     IN t_iax_gescobros,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Sustituye el objeto riesgos del riesgo determinado
      param in poliza       : objeto poliza
      param in nriesgo      : número de riesgo
      param in riesgo       : objeto riesgo
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_partriesgo(poliza   IN OUT ob_iax_detpoliza,
                             nriesgo  IN NUMBER,
                             riesgo   IN ob_iax_riesgos,
                             mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
      Sustituye el objeto beneficiario del riesgo determinado
      param in poliza       : objeto poliza
      param in nriesgo      : número de riesgo
      param in bene         : objeto beneficiario
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_partriesbeneficiarios(poliza   IN OUT ob_iax_detpoliza,
                                        nriesgo  IN NUMBER,
                                        bene     IN ob_iax_beneficiarios,
                                        mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Sustituye el objeto preguntas del riesgo determinado
      param in poliza       : objeto poliza
      param in nriesgo      : número de riesgo
      param in preg         : objeto preguntas
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_partriespreguntas(poliza   IN OUT ob_iax_detpoliza,
                                    nriesgo  IN NUMBER,
                                    preg     IN t_iax_preguntas,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Sustituye el objeto garantias del riesgo determinado
      param in poliza       : objeto poliza
      param in nriesgo      : número de riesgo
      param in gar          : objeto garantias
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_partriesgarantias(poliza   IN OUT ob_iax_detpoliza,
                                    nriesgo  IN NUMBER,
                                    gar      IN t_iax_garantias,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Sustituye el objeto garantia del riesgo determinado de la lista garantias
      param in poliza       : objeto poliza
      param in nriesgo      : número de riesgo
      param in gar          : objeto garantia
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_partriesgarantia(poliza   IN OUT ob_iax_detpoliza,
                                   nriesgo  IN NUMBER,
                                   gar      IN ob_iax_garantias,
                                   mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Sustituye del objeto garantias del riesgo las preguntas
      param in poliza       : objeto poliza
      param in nriesgo      : número de riesgo
      param in cgarant      : código de garantia
      param in gar          : objeto garantias
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_partgarpreguntas(poliza   IN OUT ob_iax_detpoliza,
                                   nriesgo  IN NUMBER,
                                   cgarant  IN NUMBER,
                                   pre      IN t_iax_preguntas,
                                   mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Sustituye del objeto gestion
      param in poliza       : objeto riesgo
      param in gest         : objeto gestión
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_partpoldatosgestion(poliza   IN OUT ob_iax_detpoliza,
                                      gest     IN ob_iax_gestion,
                                      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve la información del objeto tipo descripción
      param in riesgo        : objeto riesgo
      param in out mensajes  : colección de mensajes
      return                 : objeto descripcion
   *************************************************************************/
   FUNCTION f_partriesdescripcion(riesgo   IN ob_iax_riesgos,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_descripcion;

   /***********************************************************************/
   /***********************************************************************
      Función que asigna el número de póliza del tomador del colectivo, al certificado que se crea nuevo,
      modificando una de las variables del tipo persistente de la contratación.
      param in pnpoliza  : número de póliza
      param in/out poliza  : número de póliza
      param out mensajes : mensajes de error
      return             : number  0 -> Ok  1 --> Error
   ***********************************************************************/
   -- Bug 8745 - 27/02/2009 - RSC - Adaptación iAxis a productos colectivos con certificados
   FUNCTION f_set_npoliza(pnpoliza IN NUMBER,
                          poliza   IN OUT ob_iax_detpoliza,
                          mensajes OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto distribución poliza
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto distribución
   *************************************************************************/
   -- Bug 9031 - 11/03/2009 - RSC - iAxis: Análisis adaptación productos indexados
   FUNCTION f_partpolmodeloinv(poliza   IN ob_iax_detpoliza,
                               mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_produlkmodelosinv;

   FUNCTION f_partriesautomoviles(riesgo   IN ob_iax_riesgos,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_autriesgos;

   /*************************************************************************
   BUG 9247-24022009-XVM
   FUNCTION f_partriesautomovil
      Funció que retorna l'objecte OB_IAX_AUTRIESGOS amb tota la seva informació
      per a un risc en concret
       param in poliza       : objeto detalle póliza
       param in pnriesgo     : número risc
       param in out mensajes : missatges
       return                : objecte OB_IAX_AUTRIESGOS
   *************************************************************************/
   FUNCTION f_partriesautomovil(poliza   IN ob_iax_detpoliza,
                                pnriesgo IN NUMBER,
                                mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_autriesgos;

   /*************************************************************************
      Sustituye el objeto conductores del riesgo determinado
      param in poliza       : objeto poliza
      param in nriesgo      : número de riesgo
      param in cond         : objeto autconductores
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_partautconductores(poliza   IN OUT ob_iax_detpoliza,
                                     pnriesgo IN NUMBER,
                                     pnorden  IN NUMBER,
                                     cond     IN ob_iax_autconductores,
                                     mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   BUG 9247-11032009-APD
   FUNCTION f_set_partriesautomovil
       Sustituye el objeto autriesgos del riesgo determinado
       param in poliza       : objeto detalle póliza
       param in pnriesgo     : número risc
       param in autries     : lista de objetos autriesgos
       param in out mensajes : missatges
       return                : objecte OB_IAX_AUTRIESGOS
   *************************************************************************/
   FUNCTION f_set_partriesautomovil(poliza   IN OUT ob_iax_detpoliza,
                                    pnriesgo IN NUMBER,
                                    ries     IN ob_iax_riesgos,
                                    autries  IN ob_iax_autriesgos,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Sustituye el objeto accesorios del riesgo determinado
      param in poliza       : objeto poliza
      param in nriesgo      : número de riesgo
      param in acc         : objeto autaccesorios
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_partautaccesorios(poliza   IN OUT ob_iax_detpoliza,
                                    pnriesgo IN NUMBER,
                                    accc     IN t_iax_autaccesorios,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_partautdispositivos(poliza   IN OUT ob_iax_detpoliza,
                                      pnriesgo IN NUMBER,
                                      disp     IN t_iax_autdispositivos,
                                      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************/
   /*************************************************************************
      Sustituye un asegurado de la coleccion de asegurados de los riesgo
      param in poliza       : objeto riesgo
      param in aseg          : objeto asegurados
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_partriesasegurado(poliza   IN OUT ob_iax_detpoliza,
                                    nriesgo  IN NUMBER,
                                    aseg     IN ob_iax_asegurados,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve parte del objeto riesgo a un objeto saldo deutors
      param in riesgo       : objeto riesgo
      param in out mensajes : colección de mensajes
      return                : objeto colección saldos deutors
   *************************************************************************/
   FUNCTION f_partriessaldodeutor(riesgo   IN ob_iax_riesgos,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prestamoseg;

   -- Bug 10702 - XPL - 22/07/2009 -- Se crea la funcion f_set_partriessaldodeutor
   /*************************************************************************
      Graba en el objeto saldo deutors el objeto pasado por parametro
      param in poliza       : objeto poliza
      param in nriesgo       : num. riesgo
      param in selsaldo       : marcado o no
      param in saldo          : objeto saldo deutor
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   -- Bug 11165 - 16/09/2009 - AMC - Se sustituñe  ob_iax_saldodeutorseg por ob_iax_prestamoseg
   FUNCTION f_set_partriessaldodeutor(poliza   IN OUT ob_iax_detpoliza,
                                      nriesgo  IN NUMBER,
                                      selsaldo IN NUMBER,
                                      saldo    IN ob_iax_prestamoseg,
                                      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto reglasseg
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto gestion
   *************************************************************************/
   -- Bug 16106 - RSC - 23/09/2010 - APR - Ajustes e implementación para el alta de colectivos
   FUNCTION f_partpoldatosreglasseg(poliza   IN OUT ob_iax_detpoliza,
                                    pnriesgo IN NUMBER,
                                    pcgarant IN NUMBER,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_reglasseg;

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto t_iax_reglassegtramos
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto gestion
   *************************************************************************/
   FUNCTION f_partpoldatosreglassegtramos(poliza   IN OUT ob_iax_detpoliza,
                                          pnriesgo IN NUMBER,
                                          pcgarant IN NUMBER,
                                          mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_reglassegtramos;

   /*************************************************************************
      Graba parte del objeto poliza a un objeto reglasseg
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto gestion
   *************************************************************************/
   FUNCTION f_set_partpoldatosregla(poliza     IN OUT ob_iax_detpoliza,
                                    pnriesgo   IN NUMBER,
                                    pcgarant   IN NUMBER,
                                    pcapmaxemp IN NUMBER,
                                    pcapminemp IN NUMBER,
                                    pcapmaxtra IN NUMBER,
                                    pcapmintra IN NUMBER,
                                    mensajes   IN OUT t_iax_mensajes)
      RETURN ob_iax_reglasseg;

   /*************************************************************************
      Graba parte del objeto poliza a un objeto reglasseg
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto gestion
   *************************************************************************/
   FUNCTION f_set_partpoldatosreglatramos(poliza   IN OUT ob_iax_detpoliza,
                                          pnriesgo IN NUMBER,
                                          pcgarant IN NUMBER,
                                          pnumbloq IN NUMBER,
                                          pedadini IN NUMBER,
                                          pedadfin IN NUMBER,
                                          pt1emp   IN NUMBER,
                                          pt1trab  IN NUMBER,
                                          pt2emp   IN NUMBER,
                                          pt2trab  IN NUMBER,
                                          pt3emp   IN NUMBER,
                                          pt3trab  IN NUMBER,
                                          pt4emp   IN NUMBER,
                                          pt4trab  IN NUMBER,
                                          mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_reglassegtramos;

   /*************************************************************************
      Obté les regles del certificat 0
      param in psseguro     : id del seguro
      param in pnriesgo     : id del riesgo
      param in pcgarant     : id de la garantia
      param in out mensajes : colección de mensajes
      return                : objeto reglasseg
   *************************************************************************/
   FUNCTION f_getreglas_cert0(psseguro IN NUMBER,
                              pnriesgo IN NUMBER,
                              pcgarant IN NUMBER,
                              pnpoliza IN NUMBER,
                              mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_reglasseg;

   -- Fin Bug 16106

   -- ini 19276, jbn, reemplazos
   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto reemplazos
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto colección tomadores
   *************************************************************************/
   FUNCTION f_partpolreemplazos(poliza   IN ob_iax_detpoliza,
                                mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_reemplazos;

   --Bug.: 19152 - 21/10/2011 - ICV
   /*************************************************************************
      Devuelve parte del objeto riesgo a un objeto garantia
      param in riesgo       : objeto riesgo
      param in pnorden      : Posición del objeto
      param in out mensajes : colección de mensajes
      return                : objeto garantia
   *************************************************************************/
   FUNCTION f_partriesbeneident_r(riesgo   IN ob_iax_riesgos,
                                  psseguro IN NUMBER,
                                  pnorden  IN NUMBER,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_beneidentificados;

   /*************************************************************************
      Devuelve parte del objeto ob_iax_beneidentificados garantía
      param in riesgo       : objeto riesgo
      param in pnorden      : Posición del objeto
      param in out mensajes : colección de mensajes
      return                : objeto garantia
   *************************************************************************/
   FUNCTION f_partriesbeneident_g(riesgo   IN ob_iax_riesgos,
                                  pnorden  IN NUMBER,
                                  pcgarant IN NUMBER,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_beneidentificados;

   -- BUG19069:DRA:27/09/2011:Inici
   -- INI -IAXIS-10627 -21/01/2020
   FUNCTION f_partpolcorretaje(poliza   IN ob_iax_detpoliza,
		                           pnmovimi IN NUMBER DEFAULT NULL,
	 -- FIN -IAXIS-10627 -21/01/2020
                               mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_corretaje;

   FUNCTION f_set_partcorretaje(poliza   IN OUT ob_iax_detpoliza,
                                corret   IN t_iax_corretaje,
                                mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   -- BUG19069:DRA:27/09/2011:Fi

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto gestor cobros
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto colección gestor cobros
   *************************************************************************/
   -- Bug 0021592 - 08/03/2012 - JMF
   FUNCTION f_partpolgescobro(poliza   IN ob_iax_detpoliza,
                              mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_gescobros;

   --bfp bug 21947 ini
   FUNCTION f_partgaransegcom(riesgo   IN ob_iax_riesgos,
                              mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_garansegcom;

   FUNCTION f_set_partgaransegcom(poliza   IN OUT ob_iax_detpoliza,
                                  pnriesgo IN riesgos.nriesgo%TYPE,
                                  pgsc     IN t_iax_garansegcom,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   --bfp bug 21947 fi
   --  Ini Bug 21907 - MDS - 02/05/2012
   /*************************************************************************
      Sustituye el objeto primas de la prima determinada
      param in poliza       : objeto poliza
      param in prima        : objeto prima
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_partprima(poliza   IN OUT ob_iax_detpoliza,
                            prima    IN ob_iax_primas,
                            mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   --  Fin Bug 21907 - MDS - 02/05/2012

   -- BUG 21657 --ETM --04/06/2012
   FUNCTION f_set_partpolinquiaval(poliza    IN OUT ob_iax_detpoliza,
                                   pinquival IN t_iax_inquiaval,
                                   mensajes  IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_partpolinquiaval(poliza   IN ob_iax_detpoliza,
                               mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_inquiaval;

   -- fin BUG 21657 --ETM --04/06/2012

   -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto coacuadro
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto colección tomadores
   *************************************************************************/
   FUNCTION f_partcoacuadro(poliza   IN ob_iax_detpoliza,
                            mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_coacuadro;

   /*************************************************************************
      Sustituye el objeto coacuadro
      param in poliza       : objeto poliza
      param in coa          : objeto cuadro coaseguro
      param in out mensajes : colección de mensajes
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_setpartcoacuadro(poliza   IN OUT ob_iax_detpoliza,
                               coa      IN ob_iax_coacuadro,
                               mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   -- Fin Bug 0023183

   -- Bug 0022701 - 03/09/2012 - JMF
   FUNCTION f_partpolretorno(poliza   IN ob_iax_detpoliza,
                             mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_retorno;

   -- Bug 0022701 - 03/09/2012 - JMF
   FUNCTION f_set_partretorno(poliza   IN OUT ob_iax_detpoliza,
                              retrn    IN t_iax_retorno,
                              mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
      Devuelve parte del objeto riesgo a un objeto aseguradosmes
      param in poliza       : objeto riesgo
      param in out mensajes : colección de mensajes
      return                : objeto colección de direcciones
   *************************************************************************/
   FUNCTION f_partaseguradosmes(riesgo   IN ob_iax_riesgos,
                                mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_aseguradosmes;

   --JRH 03/2008
   /*************************************************************************
      Sustituye el objeto aseguradosmes del riesgo determinado
      param in poliza       : objeto riesgo
      param in nriesgo      : número de riesgo
      param in irreg         : objeto rentas irregulares
      param in out mensajes : colección de mensajes
      return                : objeto colección preguntas
   *************************************************************************/
   FUNCTION f_set_partaseguradosmes(poliza   IN OUT ob_iax_detpoliza,
                                    nriesgo  IN riesgos.nriesgo%TYPE,
                                    pasegmes IN ob_iax_aseguradosmes,
                                    mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve parte del objeto de versi??e una p??a
      param in poliza       : objeto p??a
      param in out mensajes : colección de mensajes
      return                : objeto colección de direcciones
   *************************************************************************/
   FUNCTION f_partconvempvers(poliza   IN ob_iax_detpoliza,
                              mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_convempvers;

   /*************************************************************************
      Asocia parte del objeto poliza a un objeto versi??e convenio
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto colección clausulas
   *************************************************************************/
   FUNCTION f_set_partconvempvers(poliza       IN OUT ob_iax_detpoliza,
                                  pconvempvers IN ob_iax_convempvers,
                                  mensajes     IN OUT t_iax_mensajes,
                                  pmode        IN VARCHAR2 DEFAULT 'EST') -- Bug 18362 - APD - 01/06/2011
    RETURN NUMBER;

   /*************************************************************************
      Devuelve parte del objeto poliza a un objeto citas medicas
      param in poliza       : objeto detalle póliza
      param in out mensajes : colección de mensajes
      return                : objeto colección citas
   *************************************************************************/
   FUNCTION f_partpolcitamed(poliza   IN ob_iax_detpoliza,
                             mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_citamedica;

   /*************************************************************************
      FUNCTION f_partpolcontgaran

      param in poliza    : ob_iax_detpoliza
      param in mensajes  : t_iax_mensajes
      return             : t_iax_contragaran
   *************************************************************************/
   FUNCTION f_partpolcontgaran(poliza   IN ob_iax_detpoliza,
                               mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_contragaran;

   FUNCTION f_set_partpolcitamed(poliza   IN OUT ob_iax_detpoliza,
                                 citas    IN t_iax_citamedica,
                                 mensajes IN OUT t_iax_mensajes) RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_set_partcontgaran

      param in poliza    : ob_iax_detpoliza
      contragaran        : t_iax_contragaran
      param in mensajes  : t_iax_mensajes
      return             : t_iax_contragaran
   *************************************************************************/
   FUNCTION f_set_partcontgaran(poliza    IN OUT ob_iax_detpoliza,
                                contgaran IN t_iax_contragaran,
                                mensajes  IN OUT t_iax_mensajes) RETURN NUMBER;
END pac_iobj_prod;
/
