--------------------------------------------------------
--  DDL for Package PAC_AUTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_AUTOS" AS
/******************************************************************************
   NOMBRE:       PAC_AUTOS
   PROPÓSITO:  Funciones para realizar una conexión
               a base de datos de la capa de negocio

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        02/03/2009   XVM               1. Creación del package.
   2.0        07/01/2013   MDS               2. 0025458: LCOL_T031-LCOL - AUT - (ID 279) Tipos de placa (matr?cula)
   3.0        31/01/2013   DCT               3. 0025628: LCOL_T031-LCOL - AUT - (ID 278 id 85) Control duplicidad matriculas
   4.0        15/03/2013   DCT               4. 0026435: LCOL - TEC - control de duplicidad
   5.0        26/03/2013   ECP               6. 0025202: LCOL_T031 - Adaptar pantalla riesgo - autos. Id 428
******************************************************************************/

   /*************************************************************************
      FUNCTION f_valida_version
         Funció que valida determinats conceptes de la versió
         param in pcmarca   : Codi de la marca
         param in pcmodelo  : Codi del modelo
         param in pctipveh  : Codi tipo vehícle
         param in pcclaveh  : Codi classe vehícle
         param in pcversion : Codi de la versió
         param in ptversion : Descripció versió
         param in ptvarian  : Complement a la versió (en 2ª categoria)
         param in pnpuerta  : Número de portes totals en turismes
         param in pnpuertl  : Número de portes laterals dels furgons
         param in pnpuertt  : Número de portes del darrera dels furgons
         param in pflanzam  : Data del llançament. Format mes/any (mm/aaaa)
         param in pntara    : Pes en buit
         param in pnpma     : Pes Màxim Admès
         param in pnvolcar  : Volum de carga en els furgons
         param in pnlongit  : Longitud del vehícle
         param in pnvia     : Via davantera
         param in pnneumat  : Amplada de pneumàtic davanter
         param in pcvehcha  : Descripció xassis
         param in pcvehlog  : Descripció longitud
         param in pcvehacr  : Descripció tacament
         param in pcvehcaj  : Descripció de caixa
         param in pcvehtec  : Descripció de sostre
         param in pcmotor   : Tipus de motor (Gasolina, Diesel,  Elèctric, etc)
         param in pncilind  : Cilindrada del motor
         param in pnpotecv  : Poténcia del vehícle
         param in pnpotekw  : Poténcia del vehícle
         param in pnplazas  : Número màxim de places
         param in pnace100  : Temps d'acceleració de 0 a 100 Km/h.
         param in pnace400  : Temps d'acceleració de 0 a 400 metres
         param in pnveloc   : Velocitat màxima
         param in pcvehb7   : Indica si ve de base set o no
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_valida_version(
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
      pcvehb7 IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_rieauto(
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
      pcmotor IN VARCHAR2,   -- Tipo combustible(Tipo de motor (Gasolina, Diesel,etc))
      pcgaraje IN NUMBER,   -- Utiliza garaje. Valor fijo = 296
      pcvehb7 IN NUMBER,   -- Indica si procede de base siete o no. Valor fijo = 108
      pcusorem IN NUMBER,   --Utiliza remolque . Valor fijo =108 ( si o no )
      pcremolque IN NUMBER,   -- Descripción del remolque. Valor fijo =297
      pccolor IN NUMBER,   --  Código color vehículo. Valor fijo = 440
      pcvehnue IN VARCHAR2,   -- Indica si el vehículo es nuevo o no.
      pnbastid IN VARCHAR2,
      pcchasis IN VARCHAR2,   -- Código de chasis
      pcodmotor IN VARCHAR2,   -- Código del motor
      psproduc IN NUMBER,   --Código del producto
      pfefecto IN DATE,   --Fecha de Efecto
      panyo IN NUMBER)   --Anyo del vehiculo
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_set_version
         Funció que inserta en AUT_VERSIONES
         param in pcmarca   : Codi de la marca
         param in pcmodelo  : Codi del modelo
         param in pctipveh  : Codi tipo vehícle
         param in pcclaveh  : Codi classe vehícle
         param in pcversion : Codi de la versió
         param in ptversion : Descripció versió
         param in ptvarian  : Complement a la versió (en 2ª categoria)
         param in pnpuerta  : Número de portes totals en turismes
         param in pnpuertl  : Número de portes laterals dels furgons
         param in pnpuertt  : Número de portes del darrera dels furgons
         param in pflanzam  : Data del llançament. Format mes/any (mm/aaaa)
         param in pntara    : Pes en buit
         param in pnpma     : Pes Màxim Admès
         param in pnvolcar  : Volum de carga en els furgons
         param in pnlongit  : Longitud del vehícle
         param in pnvia     : Via davantera
         param in pnneumat  : Amplada de pneumàtic davanter
         param in pcvehcha  : Descripció xassis
         param in pcvehlog  : Descripció longitud
         param in pcvehacr  : Descripció tacament
         param in pcvehcaj  : Descripció de caixa
         param in pcvehtec  : Descripció de sostre
         param in pcmotor   : Tipus de motor (Gasolina, Diesel,  Elèctric, etc)
         param in pncilind  : Cilindrada del motor
         param in pnpotecv  : Poténcia del vehícle
         param in pnpotekw  : Poténcia del vehícle
         param in pnplazas  : Número màxim de places
         param in pnace100  : Temps d'acceleració de 0 a 100 Km/h.
         param in pnace400  : Temps d'acceleració de 0 a 400 metres
         param in pnveloc   : Velocitat màxima
         param in pcvehb7   : Indica si ve de base set o no
         return             : 0 -> Tot correcte
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
      pcvehb7 IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_desversion
         Funcion que busca la descripcion de la version de un vehiculo
         param in pcversion : Codigo de la version
         return             : descripcion de la version
   *************************************************************************/
   FUNCTION f_desversion(pcversion IN VARCHAR2)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_desmodelo
         Funcion que busca la descripcion del modelo de un vehiculo
         param in pcmodelo : Codigo del modelo
         param in pcmarca : Codigo de la marca
         return            : descripcion del modelo
   *************************************************************************/
   FUNCTION f_desmodelo(pcmodelo IN VARCHAR2, pcmarca IN VARCHAR2)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_desmarca
         Funcion que busca la descripcion de la marca de un vehiculo
         param in pcmarca : Codigo de la marca
         return            : descripcion de la marca
   *************************************************************************/
   FUNCTION f_desmarca(pcmarca IN VARCHAR2)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_destipveh
         Funcion que busca la descripcion del tipo de un vehiculo
         param in pctipveh : Codigo del tipo de vehiculo
         param in pcidioma : Idioma de la descripcion
         return            : descripcion del tipo
   *************************************************************************/
   FUNCTION f_destipveh(pctipveh IN VARCHAR2, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_desclaveh
         Funcion que busca la descripcion de la clase de un vehiculo
         param in pcclaveh : Codigo de la clase de vehiculo
         param in pcidioma : Idioma de la descripcion
         return            : descripcion del tipo
   *************************************************************************/
   FUNCTION f_desclaveh(pcclaveh IN VARCHAR2, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_desuso
         Funcion que busca la descripcion del uso de un vehiculo
         param in pcuso : Codigo del uso de vehiculo
         param in pcidioma : Idioma de la descripcion
         return            : descripcion del uso
   *************************************************************************/
   FUNCTION f_desuso(pcuso IN VARCHAR2, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_dessubuso
         Funcion que busca la descripcion del subuso de un vehiculo
         param in pcuso : Codigo del subuso de vehiculo
         param in pcidioma : Idioma de la descripcion
         return            : descripcion del subuso
   *************************************************************************/
   FUNCTION f_dessubuso(pcsubuso IN VARCHAR2, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   -- BUG 0025412 - FAL - 11/01/2013
   FUNCTION f_get_digitverif_matric(pctipmat IN NUMBER, pcmatric IN VARCHAR2)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_controlduplicidad
         Funcion que valida si la matrícula y/o bastidor y/o código motor no esten duplicados
         param in psseguro  Secuencia de la póliza
         param in pcmatric: Codigo de la matrícula
         param in pnbastid : Codigo del bastidor
         param in pcodmotor: Codigo del motor
         param in psproduc:  Codigo del producto
         param in pfefecto:  Fecha efecto
         param in pcchasis:  Código del chasis
         return: 0(OK) x(error)
   *************************************************************************/
   FUNCTION f_controlduplicidad(
      psseguro IN NUMBER,
      pcmatric IN VARCHAR2,
      pnbastid IN VARCHAR2,
      pcodmotor IN VARCHAR2,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pcchasis IN VARCHAR2 DEFAULT NULL,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;

    -- BUG 0025202 -  ECP  - 15/02/2013
   /*************************************************************************
      FUNCTION f_despeso
         Funcion que busca la descripcion del peso de un vehiculo
         param in pcpeso : Codigo del peso
         return            : descripcion del peso
   *************************************************************************/
   FUNCTION f_despeso(psproduc IN NUMBER, pcpeso IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_get_valorauto
         Funcion que busca el valor de una version
         param in psseguro : Codigo del seguro
         param in pnriesgo : Numero de riesgo
         param in psproces : Codigo del proceso
         param in pcversion : Código de la versión
         param out pvalorcomercial : valor comercial
         param out pvalorcomercial_nuevo : nuevo valor comercial
         return  0 - Ok 1 Ko

         Bug 26638/160933 - 11/12/2013 - AMC
   *************************************************************************/
   FUNCTION f_get_valorauto(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psproces IN NUMBER,
      pcversion IN VARCHAR2,
      pdonde IN NUMBER,
      pvalorcomercial OUT NUMBER,
      pvalorcomercial_nuevo OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_ctipmat(
      pctipmat IN NUMBER,
      pcmatric IN VARCHAR2,
      pcversion IN VARCHAR2,
      pctipveh IN VARCHAR2)
      RETURN NUMBER;
END pac_autos;

/

  GRANT EXECUTE ON "AXIS"."PAC_AUTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_AUTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_AUTOS" TO "PROGRAMADORESCSI";
