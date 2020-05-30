--------------------------------------------------------
--  DDL for Package PAC_IAX_DINCARTERA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_DINCARTERA" AS
/******************************************************************************
   NOMBRE:      PAC_IAX_DINCARTERA
   PROPÓSITO:

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        03/12/2008                 1. Creación del package.
   1.1        16/12/2008
   1.2        18/12/2008     xpl         2. Estandarització
   2.0        24/04/2009     RSC         2. Suplemento de cambio de forma de pago diferido
   3.0        08/11/2012     APD         3. 0023940: LCOL_T010-LCOL - Certificado 0 renovable - Renovaci?n colectivos
   4.0        04/07/2013     ECP         4. 0027539: LCOL_T010-LCOL - Revision incidencias qtracker (VII). Nota 148366
******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

   FUNCTION f_get_prodcartera(
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      psprocar IN NUMBER,
      --Ini Bug 27539 --ECP--04/07/2013
      pmodo IN VARCHAR,
      --Fin Bug 27539 --ECP--04/07/2013
      pcurprcar OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_prodcartera(
      pcempres IN NUMBER,
      psprocar IN NUMBER,
      psproduc IN NUMBER,
      pseleccio IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_mes_cartera(
      pnpoliza IN NUMBER,
      pcempres IN NUMBER,
      pcmodo IN VARCHAR2,
      pcurmescar OUT sys_refcursor,
      mensajes OUT t_iax_mensajes,
      psprocar IN NUMBER   -- Bug 29952/169064 - 11/03/2014 - AMC
                        )
      RETURN NUMBER;

   FUNCTION f_get_anyo_cartera(
      pcempres IN NUMBER,
      pnpoliza IN NUMBER,
      pnmes IN NUMBER,
      pnanyo OUT NUMBER,
      mensajes OUT t_iax_mensajes,
      psprocar IN NUMBER   -- Bug 29952/169064 - 11/03/2014 - AMC
                        )
      RETURN NUMBER;

   FUNCTION f_registra_proceso(
      pmodo IN VARCHAR2,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pcempres IN NUMBER,
      pfcartera IN DATE,
      pnproceso OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_proceso(psproces OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_lanza_previo(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      psprocar IN NUMBER,
      prenuevan IN NUMBER,
      pfcartera IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_lanza_cartera(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      psprocar IN NUMBER,
      pfcartera IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_listado_cartera(
      report IN VARCHAR2,
      pcempres IN NUMBER,
      pselprod IN VARCHAR2,
      psproces IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      psprocar IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*******************************************************************************
    FUNCION f_eval_genera_diferidos
    Nos indicará si debe o no generarse el MAP de información de pólizas que sufrirán
    un suplemento automático o un suplemento diferido en la cartera indicada por
    parámetro.

    Parámetros:
       pcempres NUMBER: Código de empresa seleccionada en pantalla de previo de cartera.
       psproces NUMBER: Identificador de proceso.
       pgeneramap NUMBER: 0 (no genera map) o 1 (si genera map)
     Salida :
       Mensajes   T_IAX_MENSAJES
    Retorna: NUMBER.
   ********************************************************************************/
   -- Bug 9905 - 21/05/2009 - RSC - Suplemento de cambio de forma de pago diferido
   FUNCTION f_eval_genera_diferidos(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pgeneramap OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- Fin Bug 9905

   -- Bug 23940 - APD - 08/11/2012 - se crea la funcion
   FUNCTION f_consulta_gestrenova(
      pramo IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncert IN NUMBER,
      pnnumide IN VARCHAR2,
      psnip IN VARCHAR2,
      pbuscar IN VARCHAR2,
      pnsolici IN NUMBER,
      ptipopersona IN NUMBER,
      pcagente IN NUMBER,
      pcmatric IN VARCHAR2,
      pcpostal IN VARCHAR2,
      ptdomici IN VARCHAR2,
      ptnatrie IN VARCHAR2,
      pcsituac IN NUMBER,
      p_filtroprod IN VARCHAR2,
      pcpolcia IN VARCHAR2,
      pccompani IN NUMBER,
      pcactivi IN NUMBER,
      pcestsupl IN NUMBER,
      pnpolini IN VARCHAR2,
      pfilage IN NUMBER,
      pfvencimini IN DATE,
      pfvencimfin IN DATE,
      psucurofi IN VARCHAR2,
      pmodo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- Bug 23940 - APD - 08/11/2012 - se crea la funcion
   FUNCTION f_act_cbloqueocol(
      psseguro IN NUMBER,
      pcbloqueocol IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 23940 - APD - 08/11/2012 - se crea la funcion
   FUNCTION f_suplemento_renovacion(
      psseguro IN NUMBER,
      otexto OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 23940 - APD - 08/11/2012 - se crea la funcion
   FUNCTION f_botones_gestrenova(
      psseguro IN NUMBER,
      opermiteemitir OUT NUMBER,
      opermitepropret OUT NUMBER,
      opermitesuplemento OUT NUMBER,
      opermiterenovar OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_carteradiaria_poliza(pnpoliza IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_carteraprog_poliza(pnpoliza IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_carteradiaria_producto(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_carteraprog_producto(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_programar_cartera(
      psproces IN NUMBER,
      pmodo IN VARCHAR2,
      pcempres IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pproductos IN VARCHAR2,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      psprocar IN NUMBER,
      pfejecucion IN DATE,
      pfcartera IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_lanza_cartera_cero(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      psproces OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_retroceder_cartera_cero(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*********************************************************************************************************
    Funcio que realitza les validacions per a la renovació de la cartera.


      psproces  NUMBER,
      pcempres  NUMBER,
      pmes      NUMBER,
      panyo     NUMBER,
      pnpoliza  NUMBER,
      pncertif  NUMBER,
      psprocar  NUMBER,
      pfcartera DATE,
      mensajes  t_iax_mensajes
*********************************************************************************************************/
   FUNCTION f_validacion_cartera(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      psprocar IN NUMBER,
      pfcartera IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_dincartera;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_DINCARTERA" TO "PROGRAMADORESCSI";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DINCARTERA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DINCARTERA" TO "CONF_DWH";
