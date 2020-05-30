--------------------------------------------------------
--  DDL for Package PAC_IAX_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_COMMON" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_COMMON
   PROP¿SITO:  Funciones de uso general para el IAxis

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        02/08/2007   ACC                1. Creaci¿n del package.
   2.0        26/09/2007   ACC                2. Funciones recuperar partes objeto
   3.0        21/11/2007   ACC                3. Nuevas funcionalidades
   4.0        01/12/2009   AMC                4. bug 11308.Se a¿ade la funci¿n f_extrae_npoliza
   5.0        27/08/2010   FAL                5. 0015750: CRE998 - Modificacions m¿dul domiciliacions
******************************************************************************/

   /*************************************************************************
      Tipo registro con las claves de definici¿n de un producto
   *************************************************************************/
   TYPE prodidentifiedr IS RECORD(
      cramo          NUMBER,
      cmodali        NUMBER,
      ctipseg        NUMBER,
      ccolect        NUMBER
   );

   TYPE prodidentified IS TABLE OF prodidentifiedr
      INDEX BY BINARY_INTEGER;

   /*************************************************************************
      Establece una variable de contexto
      param in clave         : clave del contexto
      param in valor         : valor del contexto
      param in out mensajes  : colecci¿n de mensajes
   *************************************************************************/
   PROCEDURE p_set_contextparam(
      clave IN VARCHAR2,
      valor IN VARCHAR2,
      mensajes OUT t_iax_mensajes);

   /*************************************************************************
      Devuelve valor variable de contexto
      param in clave         : clave del contexto
      param in out mensajes  : colecci¿n de mensajes
      return                 : valor del contexto
   *************************************************************************/
   FUNCTION f_get_contextparam(clave IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
      Define el idioma como contexto
      param in valor         : valor del contexto
   *************************************************************************/
   PROCEDURE p_set_cxtidioma(valor IN NUMBER);

   /*************************************************************************
      Recupera el idioma como contexto
      return   : valor del contexto
   *************************************************************************/
   FUNCTION f_get_cxtidioma
      RETURN NUMBER;

   /*************************************************************************
      Define el usuario como contexto
      param in valor  : valor del contexto
   *************************************************************************/
   PROCEDURE p_set_cxtusuario(valor IN VARCHAR2);

   /*************************************************************************
      Recupera el usuario como contexto
      return   : valor del contexto
   *************************************************************************/
   FUNCTION f_get_cxtusuario
      RETURN VARCHAR2;

   /*************************************************************************
      Define el agente como contexto
      param in valor  : valor del contexto
   *************************************************************************/
   PROCEDURE p_set_cxtagente(valor IN NUMBER);

   /*************************************************************************
      Recupera el agente como contexto
      return   : valor del contexto
   *************************************************************************/
   FUNCTION f_get_cxtagente
      RETURN NUMBER;

   /*************************************************************************
      Define el agente para producci¿ncomo contexto
      param in valor  : valor del contexto
   *************************************************************************/
   PROCEDURE p_set_cxtagenteprod(valor IN NUMBER);

   /*************************************************************************
      Recupera el agente para producci¿n como contexto
      return   : valor del contexto
   *************************************************************************/
   FUNCTION f_get_cxtagenteprod
      RETURN NUMBER;

   /*************************************************************************
      Define la empresa como contexto
      param in valor  : valor del contexto
   *************************************************************************/
   PROCEDURE p_set_cxtempresa(valor IN NUMBER);

   /*************************************************************************
      Recupera la empresa como contexto
      return   : valor del contexto
   *************************************************************************/
   FUNCTION f_get_cxtempresa
      RETURN NUMBER;

   /************************************************************************
      Indica si el usuario actual puede hacer un cambio de agente en la
      emisi¿n de p¿liza
      return   :  1 puede cambiar el agente para emitir p¿liza
                  0 el agente es l'actual
   ************************************************************************/
   FUNCTION f_permitecagente
      RETURN NUMBER;

   /***********************************************************************
      Indica si el campo para identificar una persona en host puede
      ser visible
      return   : 1 indica que el campo se debe mostrar
                 0 el campo se debe ocultar
   ***********************************************************************/
   FUNCTION f_permitirsip
      RETURN NUMBER;

   /***********************************************************************
      Indica si desde la pantalla de busqueda de personas se puede dar
      de alta una nueva persona
      return   : 1 indica se puede dar de alta
                 0 no puede dar de alta
   ***********************************************************************/
   FUNCTION f_permitirnuevapersona
      RETURN NUMBER;

   /***********************************************************************
      Dado un n¿mero de p¿liza devuelve el c¿digo del ramo
      param in pnpoliza     : n¿mero p¿liza
      param in out mensajes : mensajes error
      return                : c¿digo ramo o nulo si se produce error
   ***********************************************************************/
   FUNCTION f_get_polramo(pnpoliza IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Dado un c¿digo de seguro
      param in psseguro     : c¿digo seguro
      param in pmode        : mode consulta EST POL
      param out onpoliza    : n¿mero p¿liza
      param out oncertif    : n¿mero certificado
      param in out mensajes : mensajes error
   ***********************************************************************/
   PROCEDURE f_get_npoliza(
      psseguro IN NUMBER,
      pmode IN VARCHAR2,
      onpoliza OUT NUMBER,
      oncertif OUT NUMBER,
      mensajes OUT t_iax_mensajes);

   /***********************************************************************
      Formatea la cuenta bancaria
      param in ctipban : tipo cuenta
      param in cbancar : cuenta bancaria
      return           : cuenta formateada si ha podido aplicar el formato
                         sino devuelve la cuenta
   ***********************************************************************/
   FUNCTION f_formatccc(ctipban IN NUMBER, cbancar IN VARCHAR2)
      RETURN VARCHAR2;

   /***********************************************************************
       Devuelve el entorno de trabajo: test, validaci¿n, producci¿n..
       param in out mensajes : mensajes error
       return                : varchar2
    ***********************************************************************/
   FUNCTION f_get_entorno(mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /***********************************************************************
      Devuelve el modo de trabajo: POL, EST
      param in out mensajes : mensajes error
      return                : varchar2
   ***********************************************************************/
   FUNCTION f_get_ptablas(pmodo IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

    -- BUG 8339
    /***************************************************************************
     Funci¿n que retornar¿ el c¿digo de proceso temporal para la gesti¿n del proceso de cartera.
     Par¿metros:
      Salida :
       Mensajes   OUT T_IAX_MENSAJES
     Retorna: el n¿mero de la secuencia
   *****************************************************************************/
   FUNCTION f_get_proceso(psproces OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- Bug 11308 - 01/12/2009 - AMC
   /*************************************************************************
      FUNCTION f_extrae_npoliza
        Extrae el n¿ de poliza del c¿digo de cuenta interno
        param in pncontinter   : C¿digo de cuenta interno
        return             : N¿ poliza
   *************************************************************************/
   FUNCTION f_extrae_npoliza(pncontinter IN VARCHAR2)
      RETURN NUMBER;

--Fi Bug 11308 - 01/12/2009 - AMC

--Ini CONF-219 AP
   /*************************************************************************
      FUNCTION f_extrae_npoliza
        Extrae el n¿ de poliza del n¿mero de contrato (pregunta 4097)
        param in pncontinter   : N¿mero de contrato
        return             : N¿ poliza
   *************************************************************************/

   FUNCTION F_EXTRAE_NPOLCONTRA(PNCONTRATO IN VARCHAR2)
     RETURN NUMBER;
--Fi CONF-219 AP

   -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliaci¿n
    /***************************************************************************
     Funci¿n que retornar¿ el c¿digo de proceso temporal para la gesti¿n del proceso de domiciliaci¿n.
     Par¿metros:
      Salida :
       Mensajes   OUT T_IAX_MENSAJES
     Retorna: el n¿mero de la secuencia
   *****************************************************************************/
   FUNCTION f_get_procesodom(psproces OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- FI Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliaci¿n

   /*************************************************************************
      FUNCTION f_obtener_formatos_moneda
       Obtiene la lista de patrones de monedas definidas en el sistema
       return                : sys_refcursor con el cmoneda, cmonint y el patron de una moneda
   *************************************************************************/
   FUNCTION f_obtener_formatos_moneda(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
   FUNCTION f_obtener_formatos_moneda
    Obtiene la lista de patrones de monedas definidas en el sistema
    param pmoneda IN monedas.cmoneda%TYPE: Codigo de la moneda en la tabla eco_codmonedas
    return                : el patron de una moneda
*************************************************************************/
   FUNCTION f_obtener_formatos_moneda1(
      pmoneda IN eco_codmonedas.cmoneda%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

/*************************************************************************
   FUNCTION f_obtener_formatos_moneda
    Obtiene la lista de patrones de monedas definidas en el sistema
    param pmoneda IN monedas.cmoneda%TYPE: Codigo de la moneda en la tabla monedas
    return                : el patron de una moneda
*************************************************************************/
   FUNCTION f_obtener_formatos_moneda2(
      pmoneda IN monedas.cmoneda%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;
END pac_iax_common;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMMON" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMMON" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMMON" TO "PROGRAMADORESCSI";
