--------------------------------------------------------
--  DDL for Package PAC_MD_CFG_PRODUCCION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_CFG_PRODUCCION" AS
/******************************************************************************
   NOMBRE:      PAC_MD_CFG_PRODUCCION
   PROPÓSITO:   Funciones para la consfiguración de las pantallas de producción
                en segunda capa

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/01/2007   JAS               1. Creación del package.
   2.0        18/01/2010   DRA               2. 0011583: CRE - Incidencia en modificación de datos de Suplemento
   3.0        27/07/2010   JRH               3. 0015509: CEM - Modificaciones Rentas
   4.0        25/06/2012   DRA               4. 0021927: MDP - TEC - Parametrización producto de Hogar (MHG) - Nueva producción
   5.0        05/07/2012   DRA               5. 0022402: LCOL_C003: Adaptación del co-corretaje
   6.0        27/07/2012   FPG               6. 0023075: LCOL_T010-Figura del pagador
   7.0        03/09/2012   JMF               0022701: LCOL: Implementación de Retorno
   ******************************************************************************/

   /*************************************************************************
       Devuelve si se puede saltar la pantalla de asegurados del flujo de contratación
       param in pObjPol     : Objeto póliza con los datos a evaluar.
       return               : 1 -> Saltar pantalla
                            : 0 -> Mostrar pantalla
                            : Otros -> Error
    *************************************************************************/
   FUNCTION f_skip_asegurados(pobjpol IN OUT ob_iax_detpoliza)
      RETURN NUMBER;

    -- ini t.7817
   /*************************************************************************
      Devuelve si se puede saltar la pantalla de riesgos del flujo de suplementos
      de preguntas de póliza.
      param in pObjPol     : Objeto póliza con los datos a evaluar.
      return               : 1 -> Saltar pantalla
                           : 0 -> Mostrar pantalla
                           : Otros -> Error
   *************************************************************************/
   FUNCTION f_skip_tarificacion(pobjpol IN OUT ob_iax_detpoliza)
      RETURN NUMBER;

   -- fin t.7817

   -- BUG11583:DRA:18/01/2010:Inici
   /*************************************************************************
      Devuelve si se puede saltar la pantalla de seleccion de colectivo del
       flujo de propuestas pendientes de emitir
      param in pObjPol     : Objeto póliza con los datos a evaluar.
      return               : 1 -> Saltar pantalla
                           : 0 -> Mostrar pantalla
                           : Otros -> Error
   *************************************************************************/
   FUNCTION f_skip_certf0(pobjpol IN OUT ob_iax_detpoliza)
      RETURN NUMBER;

-- BUG11583:DRA:18/01/2010:Fi

   -- BUG 15509 - 27/07/2010 - JRH - 0015509: CEM - Modificaciones Rentas
   /***************************************************************** en el flujo de contratación********
        Devuelve si se puede saltar la pantalla de beneficiarios
        param in pObjPol     : Objeto póliza con los datos a evaluar.
        return               : 1 -> Saltar pantalla
                             : 0 -> Mostrar pantalla
                             : Otros -> Error
     *************************************************************************/
   FUNCTION f_skip_beneficiarios(pobjpol IN OUT ob_iax_detpoliza)
      RETURN NUMBER;

-- Fi BUG 15509 - 27/07/2010 - JRH
   /***************************************************************** en el flujo de contrataci?n********
        Devuelve si se puede saltar la pantalla de comisiones por garantia
        param in pObjPol     : Objeto p?liza con los datos a evaluar.
        return               : 1 -> Saltar pantalla
                             : 0 -> Mostrar pantalla
                             : Otros -> Error
     *************************************************************************/
   FUNCTION f_skip_comisiongar(pobjpol IN OUT ob_iax_detpoliza)
      RETURN NUMBER;

   /********************** en el flujo de contratacion *************************
         Devuelve si se puede saltar la pantalla de inquilinos/avalistas
         param in pObjPol     : Objeto poliza con los datos a evaluar.
         return               : 1 -> Saltar pantalla
                              : 0 -> Mostrar pantalla
                              : Otros -> Error
      *************************************************************************/
   FUNCTION f_skip_inquiaval(pobjpol IN OUT ob_iax_detpoliza)
      RETURN NUMBER;

   /********************** en el flujo de contratacion *************************
         Devuelve si se debe mostrar la pantalla del co-corretaje
         param in pObjPol     : Objeto poliza con los datos a evaluar.
         return               : 1 -> Saltar pantalla
                              : 0 -> Mostrar pantalla
                              : Otros -> Error
      *************************************************************************/
-- Bug 23075 - FPG - 30/07/2012 - LCOL_T010-Figura del pagador - inicio
   FUNCTION f_skip_corretaje(pobjpol IN OUT ob_iax_detpoliza)
      RETURN NUMBER;

   /********************** en el flujo de contratacion *************************
          Devuelve si se debe mostrar la pantalla del pagadores
          param in pObjPol     : Objeto poliza con los datos a evaluar.
          return               : 1 -> Saltar pantalla
                               : 0 -> Mostrar pantalla
                               : Otros -> Error
       *************************************************************************/
   FUNCTION f_skip_pagadores(pobjpol IN OUT ob_iax_detpoliza)
      RETURN NUMBER;

-- Bug 23075 - FPG - 30/07/2012 - LCOL_T010-Figura del pagador - final

   /********************** en el flujo de contratacion *************************
         Devuelve si se debe mostrar la pantalla del retorno
         param in pObjPol     : Objeto poliza con los datos a evaluar.
         return               : 1 -> Saltar pantalla
                              : 0 -> Mostrar pantalla
                              : Otros -> Error
      *************************************************************************/
   -- ini Bug 0022701 - 03/09/2012 - JMF
   FUNCTION f_skip_retorno(pobjpol IN OUT ob_iax_detpoliza)
      RETURN NUMBER;
END pac_md_cfg_produccion;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_CFG_PRODUCCION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CFG_PRODUCCION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CFG_PRODUCCION" TO "PROGRAMADORESCSI";
