--------------------------------------------------------
--  DDL for Package PAC_AGENTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_AGENTES" AS
/****************************************************************************
   NOM:       PAC_AGENTES
   PROPÒSIT:  Funciones relacionades amb agents

   REVISIONS:
   Ver        Data         Autor             Descripció
   ---------  ----------  ---------------  ----------------------------------
   1.0        28/05/2009   MSR               1. Creació del package.
   1.1        15/06/2009   MSR               Límitació per empreses
   2.0        28/09/2011   JMC               2.Comisiones Indirectas (bug:19586)
   3.0        27/01/2012   APD               3.0020999: LCOL_C001: Comisiones Indirectas para ADN Bancaseguros
   4.0        21/05/2014   FAL               4.0031489: TRQ003-TRQ: Gap de comercial. Liquidación a nivel de Banco
****************************************************************************/

   -- Definicions de dades utilitzades per la funció F_AGENTS_VISIBLES
   TYPE rt_redcomercial IS RECORD(
      cempres        redcomercial.cempres%TYPE,
      cagente        redcomercial.cagente%TYPE
   );

   TYPE tt_redcomercial IS TABLE OF rt_redcomercial;

   /*************************************************************************
    FUNCTION f_agents_visibes
    Torna una taula amb l'empresa i els codis d'aqents de 'redcomercial'
    que l'agent loginat pot veure.

    return             : table

    La format d'utilitzar-la és TABLE(PAC_GENTES.F_AGENTS_VISIBLES).
    Per exemple, SELECT cempres,cagente FROM TABLE(PAC_AGENTES.F_AGENTS_VISIBLES)

    Notes:
       1.- En cas que algun agent estigui donat de baixa tornarà els agents fills
       però no el propi agent donat de baixa.
       2.- En cas que el contexte empresa estigui inicialitzat torna només aquella empresa
           Si el contexte és a NULL tornarà les dades per totes les empreses
   *************************************************************************/
--   FUNCTION f_agents_visibles
--      RETURN tt_redcomercial PIPELINED;

   /*************************************************************************
    FUNCTION f_get_agecomp
    Funcion que dado un agente y una compañia retorna un agente compañia
    return             : number
   *************************************************************************/
   FUNCTION f_get_agecomp(pcagente IN NUMBER, pccompani IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
    FUNCTION f_get_agente
    Funcion que dado un agente compañia y una compañia retorna un agente
    return             : number
   *************************************************************************/
   FUNCTION f_get_agente(pcagecomp IN VARCHAR2, pccompani IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    FUNCTION f_get_cageind
    Funcion que dado un agente y una fecha retorna el agente activo a la fecha
    que cobrara las comisiones indirectas.
    param in pcagente   : Código agente
    param in pfecha     : Fecha en activo
    return             : Código agente indirectas
   *************************************************************************/
   FUNCTION f_get_cageind(pcagente IN NUMBER, pfecha IN DATE)
      RETURN NUMBER;

   /*************************************************************************
    FUNCTION f_get_cageliq
    Funcion que dado un agente, una empresa y un tipo agente retorna el agente
    que este por encima del agente pasado por parametro, en el nivel especificado.
    Se utiliza para obtener el agente que cobra las comisiones en el caso de estar
    informado el parámetro por empresa LIQUIDA_CTIPAGE.
    param in pcagente   : Código agente
    param in pcempres     : Código de empresa
    param in pctipage  : Tipo de agente
    return             : Código agente liquidación
   *************************************************************************/
   FUNCTION f_get_cageliq(pcempres IN NUMBER, pctipage IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_get_tipiva
      Funcion que dado un agente y una fecha retorna el % tipo de iva a la fecha
      que cobrara las comisiones.
      param in pcagente   : Código agente
      param in pfecha     : Fecha en activo
      return             :  % Tipo de iva a aplicar
     *************************************************************************/
   FUNCTION f_get_tipiva(pcagente IN NUMBER, pfecha IN DATE)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_get_reteniva
      Funcion que dado un agente y una fecha retorna el la retencion a aplicar en la fecha
      que cobrara las comisiones.
      param in pcagente   : Código agente
      param in pfecha     : Fecha en activo
      return              :  % Tipo de retención a aplicar
     *************************************************************************/
   FUNCTION f_get_reteniva(pcagente IN NUMBER, pfecha IN DATE)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_es_descendiente
      Funcion que dado un agente 1 y un agente 2 determina
      si el agente 2 es descendiente del agente 1.
      param in pcagepadre   : Código agente padre
      param in pcagedesc    : Código agente descendiente
      return              :  0- NO es descendiente, 1-SI es descendiente
     *************************************************************************/
   FUNCTION f_es_descendiente(pcempres IN NUMBER, pcagepadre IN NUMBER, pcagedesc IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    FUNCTION f_get_ccomind
    Funcion que dado un agente y una fecha retorna el cuadro de comision indirecta
    de su agente padre y el agente padre
    param in pcempres   : Código de empresa
    param in pcagente   : Código agente
    param in pfecha     : Fecha en activo
    param out pccomind     : cuadro de comision indirecta del agente padre
    param out pcpadre     : agente padre
    return             : number
   *************************************************************************/
   FUNCTION f_get_ccomind(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pfecha IN DATE,
      pccomind OUT NUMBER,
      pcpadre OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
     FUNCTION f_set_age_contacto
     Funcion que guarda el contacto de un agente
     param in pcagente   : Código agente
     param in pctipo     : Código del tipo de contacto
     param in pnorden    : Nº orden
     param in pnombre    : Nombre del contacto
     param in pcargo     : Código del cargo
     param in piddomici  : Código del domicilio
     param in ptelefono  : Telefono
     param in ptelefono2 : Telefono 2
     param in pfax       : Fax
     param in pemail     : Email
     return             : 0 - ok - Codi error

     Bug 21450/108261 - 24/02/2012 - AMC
    *************************************************************************/
   FUNCTION f_set_age_contacto(
      pcagente IN NUMBER,
      pctipo IN NUMBER,
      pnorden IN NUMBER,
      pnombre IN VARCHAR2,
      pcargo IN VARCHAR2,
      piddomici IN NUMBER,
      ptelefono IN NUMBER,
      ptelefono2 IN NUMBER,
      pfax IN NUMBER,
      pweb IN VARCHAR2,
      pemail IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
    FUNCTION f_del_age_contacto
    Funcion que borra el contacto de un agente
    param in pcagente   : Código agente
    param in pnorden    : Nº orden
    return             : 0 - ok - Codi error

    Bug 21450/108261 - 27/02/2012 - AMC
   *************************************************************************/
   FUNCTION f_del_age_contacto(pcagente IN NUMBER, pnorden IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
     Función que inserta o actualiza los datos de un documento asociado a un agente
     param in pcagente   : Código agente
     param in pfcaduca   : Fecha de caducidad
     param in ptobserva  : Observaciones
     param in piddocgedox : Identificador del documento
     param in ptamano : Tamaño del documento

     Bug 21543/108711 - AMC - 02/03/2012
   *************************************************************************/
   FUNCTION f_set_docagente(
      pcagente IN NUMBER,
      pfcaduca IN DATE,
      ptobserva IN VARCHAR2,
      piddocgedox IN NUMBER,
      ptamano IN VARCHAR2)
      RETURN NUMBER;

-- BUG 31489 - FAL - 21/05/2014
   /*************************************************************************
     Función que recupera el agente al que debe liquidar
     param in pcempres   : Código empresa
     param in pcagente   : Código agente
   *************************************************************************/
   FUNCTION f_agente_liquida(pcempres IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER;
-- FI BUG 31489 - FAL - 21/05/2014
END pac_agentes;

/

  GRANT EXECUTE ON "AXIS"."PAC_AGENTES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_AGENTES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_AGENTES" TO "PROGRAMADORESCSI";
