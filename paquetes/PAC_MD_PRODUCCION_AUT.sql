--------------------------------------------------------
--  DDL for Package PAC_MD_PRODUCCION_AUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_PRODUCCION_AUT" IS
/******************************************************************************
   NOMBRE:       PAC_MD_PRODUCCION_AUT
   PROPÓSITO: Funcions per gestionar autos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        03/03/2009   XVM                1. Creación del package.
   2.0        04/10/2010   JTS                2. 16163: CRT - Modificar tabla descripcion riesgo (autriesgo)
   3.0        14/02/2013   JDS                3. 0025964: LCOL - AUT - Experiencia
******************************************************************************/

   /*************************************************************************
      FUNCTION f_get_caccesorio
         Funció que retorna un nou codi d'accesori
         param in  paccesorio  : col·lecció d'accesoris
         param out pcacc       : codi accesori
         param in out mensajes : col·lecció de missatges
         return                : 0 -> Tot correcte
                                 1 -> S'ha produit un error
   *************************************************************************/

   /*************************************************************************
   GLOBALS
*************************************************************************/
   poliza         ob_iax_poliza;   --Objecte pòlisa
   asegurado      ob_iax_asegurados;   --Objecte assegurat
   accesorios     ob_iax_autaccesorios;   --Objecte accesori
   taccesorios    t_iax_autaccesorios;   --Objecte col·lecció accesoris
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma();   --Código idioma

   FUNCTION f_get_caccesorio(
      paccesorio IN t_iax_autaccesorios,
      pcacc OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_set_version
         Funció que valida i inserta en AUT_VERSIONES
         param in pcmarca      : Codi de la marca
         param in pcmodelo     : Codi del modelo
         param in pctipveh     : Codi tipo vehícle
         param in pcclaveh     : Codi classe vehícle
         param in pcversion    : Codi de la versió
         param in ptversion    : Descripció versió
         param in ptvarian     : Complement a la versió (en 2ª categoria)
         param in pnpuerta     : Número de portes totals en turismes
         param in pnpuertl     : Número de portes laterals dels furgons
         param in pnpuertt     : Número de portes del darrera dels furgons
         param in pflanzam     : Data del llançament. Format mes/any (mm/aaaa)
         param in pntara       : Pes en buit
         param in pnpma        : Pes Màxim Admès
         param in pnvolcar     : Volum de carga en els furgons
         param in pnlongit     : Longitud del vehícle
         param in pnvia        : Via davantera
         param in pnneumat     : Amplada de pneumàtic davanter
         param in pcvehcha     : Descripció xassis
         param in pcvehlog     : Descripció longitud
         param in pcvehacr     : Descripció tacament
         param in pcvehcaj     : Descripció de caixa
         param in pcvehtec     : Descripció de sostre
         param in pcmotor      : Tipus de motor (Gasolina, Diesel,  Elèctric, etc)
         param in pncilind     : Cilindrada del motor
         param in pnpotecv     : Poténcia del vehícle
         param in pnpotekw     : Poténcia del vehícle
         param in pnplazas     : Número màxim de places
         param in pnace100     : Temps d'acceleració de 0 a 100 Km/h.
         param in pnace400     : Temps d'acceleració de 0 a 400 metres
         param in pnveloc      : Velocitat màxima
         param in pcvehb7      : Indica si ve de base set o no
         param in out mensajes : col·lecció de missatges
         return                : 0 -> Tot correcte
                                 1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_set_version(
      pcmarca IN VARCHAR2,
      pcmodelo IN VARCHAR2,
      pctipveh IN VARCHAR2,
      pcclaveh IN VARCHAR2,
      pcversion IN VARCHAR2,
      ptversion IN VARCHAR2,
      pnpuerta IN NUMBER,
      pflanzam IN DATE,
      pntara IN NUMBER,
      pnpma IN NUMBER,
      pcmotor IN VARCHAR2,
      pncilind IN NUMBER,
      pnpotecv IN NUMBER,
      pnpotekw IN NUMBER,
      pnplazas IN NUMBER,
      pcvehb7 IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 9247 - APD - 30/03/2009 -- Se crea la funcion f_set_riesauto
   /*************************************************************************
      FUNCTION f_set_riesauto
         Función que carga el objeto de memoria con los cambios que se realizan en pantalla para el objeto de tipo auto.
         param in  psseguro : Código identificativo del seguro
         param in  pnriesgo : Numero De Riesgo
         param in  pcversion : En Este Campo Tiene La Siguiente Estructura:
         param in  pcmodelo : Código Del Modelo Del Auto.( Se Corresponde Con El Campo Autmodelos.Smodelo)
         param in  pcmarca : Los Cinco Primeros Caracteres Del Campo Cversion.
         param in  pctipveh : Código Del Tipo De Vehículo
         param in  pcclaveh : Código De La Clase De Vehiculo.
         param in  pcmatric : Matricula Vehiculo. No Se Informa Si  Ctipmat = 2, Sin Matricula
         param in  pctipmat : Tipo De Matricula. Tipo De Patente
         param in  pcuso : Codigo Uso Del Vehiculo
         param in  pcsubuso : Codigo Subuso Del Vehiculo
         param in  pfmatric : Fecha de primera matriculación
         param in  pnkilometros : Número de kilómetros anuales. Valor fijo = 295
         param in  pivehicu : Importe Vehiculo
         param in  pnpma : Peso Máximo Autorizado
         param in  pntara : Tara
         param in  pnpuertas : Numero de puertas del vehiculo
         param in  pnplazas : Numero de plazas del vehiculo
         param in  pcmotor : Código del motor
         param in  pcgaraje : Utiliza garaje. Valor fijo = 296
         param in  pcvehb7 : Indica si procede de base siete o no. Valor fijo = 108
         param in  pcusorem : Utiliza remolque . Valor fijo =108 ( si o no )
         param in  pcremolque : Descripción del remolque. Valor fijo =297
         param in  pccolor : Código color vehículo. Valor fijo = 440
         param in  pcvehnue : Indica si el vehículo es nuevo o no.
         param in  pnbastid : Número de bastido( chasis)
         param in  pffinciant : Fecha de antigüedad en la compañía anterior
         param in  pciaant : Compañía de la cual procede
         param out  pnriesgo_out : Numero De Riesgo calculado
         param out mensajes : col·lecció de missatges
       param in  pcpeso : Peso del vehiculo
         param in  pctransmision : Transmision del vehiculo
         return             : 0 -> Si todo OK
                              1 -> Si ha habido un error
   *************************************************************************/
   FUNCTION f_set_riesauto(
      psseguro IN NUMBER,   -- Código identificativo del seguro
      pnriesgo IN NUMBER,   --  Numero De Riesgo
      pcversion IN VARCHAR2,   -- En Este Campo Tiene La Siguiente Estructura:
      -- 5 Primeras Posiciones = Marca Del Auto.
      -- Posición 6-7-8 = Modelo Del Auto.
      -- Posición 9-10-11 = Versión Del Auto.
      pcmodelo IN VARCHAR2,   -- Código Del Modelo Del Auto.( Se Corresponde Con El Campo Autmodelos.Smodelo)
      pcmarca IN VARCHAR2,   -- Los Cinco Primeros Caracteres Del Campo Cversion.
      pctipveh IN VARCHAR2,   -- Código Del Tipo De Vehículo
      pcclaveh IN VARCHAR2,   -- Código De La Clase De Vehiculo.
      pcmatric IN VARCHAR2,   -- Matricula Vehiculo. No Se Informa Si  Ctipmat = 2, Sin Matricula
      pctipmat IN NUMBER,   -- Tipo De Matricula. Tipo De Patente
      pcuso IN VARCHAR2,   -- Codigo Uso Del Vehiculo
      pcsubuso IN VARCHAR2,   -- Codigo Subuso Del Vehiculo
      pfmatric IN DATE,   -- Fecha de primera matriculación
      pnkilometros IN NUMBER,   -- Número de kilómetros anuales. Valor fijo = 295
      pivehicu IN NUMBER,   --  Importe Vehiculo
      pnpma IN NUMBER,   --  Peso Máximo Autorizado
      pntara IN NUMBER,   --  Tara
      pnpuertas IN NUMBER,   --  Numero de puertas del vehiculo
      pnplazas IN NUMBER,   --  Numero de plazas del vehiculo
      pcmotor IN NUMBER,   -- Código del motor
      pcgaraje IN NUMBER,   -- Utiliza garaje. Valor fijo = 296
      pcvehb7 IN NUMBER,   -- Indica si procede de base siete o no. Valor fijo = 108
      pcusorem IN NUMBER,   --Utiliza remolque . Valor fijo =108 ( si o no )
      pcremolque IN NUMBER,   -- Descripción del remolque. Valor fijo =297
      pccolor IN NUMBER,   --  Código color vehículo. Valor fijo = 440
      pcvehnue IN NUMBER,   -- Indica si el vehículo es nuevo o no.
      pnbastid IN VARCHAR2,   -- Número de bastido( chasis)
      ptriesgo IN VARCHAR2,
      pcpaisorigen IN NUMBER,
      pcodmotor IN VARCHAR2,
      pcchasis IN VARCHAR2,
      pivehinue IN NUMBER,
      pnkilometraje IN NUMBER,
      pccilindraje IN VARCHAR2,
      pcpintura IN NUMBER,
      pccaja IN NUMBER,
      pccampero IN NUMBER,
      pctipcarroceria IN NUMBER,
      pcservicio IN NUMBER,
      pcorigen IN NUMBER,
      pctransporte IN NUMBER,
      pivehicufasecolda IN NUMBER,
      pivehicufasecoldanue IN NUMBER,
      panyo IN NUMBER,
      pnriesgo_out IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pffinciant IN DATE DEFAULT NULL,
      pciaant IN NUMBER DEFAULT NULL,
      pcpeso IN NUMBER DEFAULT NULL,
      pctransmision IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   -- Bug 9247 - APD - 30/03/2009 - Fin Se crea la funcion f_set_riesauto

   -- Bug 9247 - APD - 09/03/2009 -- Se crea la funcion f_set_conductor
   /*************************************************************************
      FUNCTION f_set_conductor
         Función que carga el objeto de memoria con los cambios que se realizan en pantalla.
         param in  pnriesgo : número riesgo
         param in  pnorden : Numero orden de conductor. El número 1 se corresponde al conductor principal
         param in  psperson : Código de persona (conductor identificado, nominal)
         param in  pnedad : Edad conductor innominado
         param in  pnpuntos : Número de puntos en el permiso
         param in  pfcarnet : Fecha de expedición del permiso de conducción
         param in  pcsexo : Sexo conductor innominado
         param in  pexper_manual : Numero de años de experiencia del conductor.
         param in  pexper_cexper : Numero de años de experiencia que viene por interfaz.
         param out mensajes : col·lecció de missatges
         return             : 0 -> Si todo OK
                              1 -> Si ha habido un error

         -- Bug 25368/133447 - 08/01/2013 - AMC  Se añade el pcdomici
         -- Bug 25368/135191 - 15/01/2013 - AMC  Se añade el pcprincipal
   *************************************************************************/
   FUNCTION f_set_conductor(
      pnriesgo IN NUMBER,
      pnorden IN NUMBER,
      psperson IN NUMBER,
      pfnacimi IN DATE,
      pnpuntos IN NUMBER,
      pfcarnet IN DATE,
      pcsexo IN NUMBER,
      pcdomici IN NUMBER,
      pcprincipal IN NUMBER,
      pexper_manual IN NUMBER,
      pexper_cexper IN NUMBER,
      pexper_sinie IN NUMBER,
      pexper_sinie_manual IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- Bug 9247 - APD - 09/03/2009 -- Se crea la funcion f_set_conductor

   -- Bug 9247 - APD - 06/03/2009 -- Se crea la funcion f_set_AccesoriosNoSerie
   /*************************************************************************
      FUNCTION f_set_AccesoriosNoSerie
         Función que carga el objeto de memoria con los cambios que se realizan en pantalla.
         param in  pnriesgo : número riesgo
         param in  pcversion : número de version
         param in  pcaccesorio : número de accesorio
         param in  ptdescripcion : descripcion del accesorio
         param in  pivalacc : valor del accesorio
         param in  ptipacc : tipo de accesorio
         param out mensajes : col·lecció de missatges
         return             : 0 -> Si todo OK
                              1 -> Si ha habido un error
   *************************************************************************/
   FUNCTION f_set_accesoriosnoserie(
      pnriesgo IN NUMBER,
      pcversion IN VARCHAR2,   --Obligatiro
      pcaccesorio IN VARCHAR2,   -- No obligatorio
      ptdescripcion IN VARCHAR2,
      pivalacc IN NUMBER,
      pctipacc IN NUMBER,
      pcaccesorio_out IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- Bug 9247 - APD - 06/03/2009 -- Fin Se crea la funcion f_set_AccesoriosNoSerie

   -- Bug 9247 - APD - 06/03/2009 -- Se crea la funcion f_set_detautriesgos
   /*************************************************************************
      FUNCTION f_set_detautriesgos
         Función que insertará en objeto ob_iax_autaccesorios del objeto póliza
         param in pnriesgo: numero de riesgo
         param in pnmovimi: numero de movimiento
         param in pcversion: codigo de version
         param in pcaccesorio: codigo del accesorio
         param in pctipacc: codigo del tipo de accesorio
         param in pfini: fecha de inicio o alta
         param in pivalacc: valor del accesorio
         param in ptdesacc: descripcion del accesorio
         param out mensajes : col·lecció de missatges
         return             : 0 -> Si todo OK
                              1 -> Si ha habido un error
   *************************************************************************/
   FUNCTION f_set_detautriesgos(
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcversion IN VARCHAR2,
      pcaccesorio IN VARCHAR2,
      pctipacc IN VARCHAR2,
      pfini IN DATE,
      pivalacc IN NUMBER,
      ptdesacc IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- Bug 9247 - APD - 06/03/2009 -- Fin Se crea la funcion f_set_detautriesgos

   -- Bug 9247 - APD - 23/03/2009 -- Se crea la funcion f_set_garanmodalidad
   /*************************************************************************
    Recupera las garantías que contiene una modalidad.
    param in p_nriesgo: identificador del riesgo
    param in p_cmodalidad: codigo de la modalidad
    param in p_solicit: código de solicitut
    param in p_nmovimi: número de movimiento
    param in p_pmode: modo
    param out garantaias: coleccion de garantias
    param out mensajes: mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_set_garanmodalidad(
      p_nriesgo IN NUMBER,
      p_cmodalidad IN NUMBER,
      p_solicit IN NUMBER,
      p_nmovimi IN NUMBER,
      p_pmode IN VARCHAR2,
      garantias OUT t_iax_garantias,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- Bug 9247 - APD - 23/03/2009 -- Se crea la funcion f_set_garanmodalidad
   FUNCTION f_get_auto_matric(
      pctipmat IN NUMBER,
      pcmatric IN VARCHAR2,
      psproduc IN NUMBER,   -- Bug 26435/142193 - 03/05/2013 - AMC
      pcactivi IN NUMBER,   -- Bug 26435/142193 - 03/05/2013 - AMC
      pcmodo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_autriesgos;

   FUNCTION f_hay_homologacion(
      pcversion IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pvalorcomercial OUT NUMBER,
      pvalorcomercial_nuevo OUT NUMBER,
      phomologado OUT NUMBER,
      pmensajemostrar OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

      -- BUG: 0027953/0151258 - JSV 21/08/2013
/*************************************************************************
    Recupera las garantías que contiene una modalidad.
    param in p_nriesgo: identificador del riesgo
    param in p_cmodalidad: codigo de la modalidad
    param in p_solicit: código de solicitut
    param in p_nmovimi: número de movimiento
    param in p_pmode: modo
    param out garantaias: coleccion de garantias
    param out mensajes: mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_garanmodalidad(
      p_nriesgo IN NUMBER,
      p_cmodalidad IN NUMBER,
      p_solicit IN NUMBER,
      p_nmovimi IN NUMBER,
      p_pmode IN VARCHAR2,
      garantias OUT t_iax_garantias,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_produccion_aut;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PRODUCCION_AUT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PRODUCCION_AUT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PRODUCCION_AUT" TO "PROGRAMADORESCSI";
