--------------------------------------------------------
--  DDL for Package PAC_MD_SIN_RESCATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_SIN_RESCATES" AS
/******************************************************************************
   NOMBRE:       PAC_MD_SIN_RESCATES
   PROPÓSITO:  Funciones de rescates para productos financieros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/03/2008   JRH                1. Creación del package.
   2.0        20/05/2010   RSC                2.0013829: APRB78 - Parametrizacion y adapatacion de rescastes
   3.0        01/07/2011   APD                3.0018913: CRE998 - Afegir motiu de Rescats
******************************************************************************/

   --JRH 03/2008
   /*************************************************************************
      Valida y realiza la simulación de un rescate
      param in psseguro  : póliza
      param in pnriesgo  : riesgo
      param in fecha     : fecha del rescate
      pimporte           : Importe del rescate (nulo si es total)
      pccausin           : 4 en rescate total , 5 en rescate parcial.
      simResc OUT OB_IAX_SIMRESCATE : El objeto simulación si todo hay ido bien
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_valor_simulacion(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      fecha IN DATE,
      pimporte IN NUMBER,
      pccausin IN NUMBER,
      pctipcal IN NUMBER,
      simresc IN OUT ob_iax_simrescate,
      mensajes IN OUT t_iax_mensajes,
      pimppenali IN NUMBER DEFAULT NULL,
      pimprcm IN NUMBER DEFAULT NULL,   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      ppctreten IN NUMBER DEFAULT NULL)   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      RETURN NUMBER;

    --JRH 03/2008
   /*************************************************************************
       Valida y realiza un rescate
       param in psseguro  : póliza
       param in pnriesgo  : riesgo
       param in fecha     : fecha del rescate
       pimporte           : Importe del rescate (nulo si es total)
       tipoOper           : 4 en rescate total , 5 en rescate parcial.
       param out mensajes : mensajes de error
       return             : 0 todo correcto
                            1 ha habido un error
    *************************************************************************/
   FUNCTION f_rescate_poliza(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      fecha IN DATE,
      pimporte IN NUMBER,
      pipenali IN sin_tramita_reserva.ipenali%TYPE,
      tipooper IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pimprcm IN NUMBER DEFAULT NULL,   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      ppctreten IN NUMBER DEFAULT NULL,   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      pcmotresc IN NUMBER DEFAULT NULL,
      pfondos IN t_iax_datos_fnd,
      pctipcal IN NUMBER DEFAULT NULL)   -- Bug 18913 - APD - 01/07/2011
      RETURN NUMBER;

      --JRH 03/2008
     /*************************************************************************
      Valida si se puede realizar el rescate
      param in psseguro  : póliza
      param in pnriesgo  : riesgo
      param in fecha     : fecha del rescate
      param in pccausin  : tipo oper ( 4 --> rescate total)
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_valida_permite_rescate(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      fecha IN DATE,
      pccausin IN NUMBER,
      pimporte IN NUMBER,
      pfondos IN t_iax_datos_fnd,
      pctipcal IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_sol_rescate_fnd(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pffecmov IN DATE,
      pcidioma IN NUMBER,
      pfondos IN t_iax_datos_fnd,
      pctipcal IN NUMBER,
      pimporte IN NUMBER,
      pimprcm IN NUMBER,
      ppctreten IN NUMBER,
      pipenali IN sin_tramita_reserva.ipenali%TYPE,
      pccausin IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_inserta_reserva_fondon(
      pfondos IN t_iax_datos_fnd,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pnriesgo IN NUMBER,
      pffecmov IN DATE,
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pctipcal IN NUMBER,
      pscactivi IN NUMBER,
      pcausin IN NUMBER,
      pcmotsin IN NUMBER,
      pretenc IN NUMBER DEFAULT NULL,
      pimporte IN NUMBER DEFAULT NULL,
      pipenal IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
END pac_md_sin_rescates;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_RESCATES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_RESCATES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_RESCATES" TO "PROGRAMADORESCSI";
