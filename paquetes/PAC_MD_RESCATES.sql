--------------------------------------------------------
--  DDL for Package PAC_MD_RESCATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_RESCATES" AS
/******************************************************************************
   NOMBRE:       PAC_MD_RESCATES
   PROPÓSITO:  Funciones de rescates para productos financieros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/03/2008   JRH                1. Creación del package.
   2.0        07/05/2008   JRH             2. 0009596: CRE - Rescates y promoción nómina en producto PPJ
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
      simresc IN OUT ob_iax_simrescate,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    --JRH 03/2008
   /*************************************************************************
       Valida y realiza un rescate
       param in psseguro  : póliza
       param in pnriesgo  : riesgo
       param in fecha     : fecha del rescate
       pimporte           : Importe del rescate (nulo si es total)
       pipenali           : Importe de penalización
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
      pipenali IN NUMBER,   -- BUG 9596 - 19/05/2009 - JRH - 0009596: CRE - Rescates y promoción nómina en producto PPJ  (pasar l apenalización por parámetro)
      tipooper IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_rescates;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_RESCATES" TO "PROGRAMADORESCSI";
  GRANT EXECUTE ON "AXIS"."PAC_MD_RESCATES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_RESCATES" TO "CONF_DWH";
