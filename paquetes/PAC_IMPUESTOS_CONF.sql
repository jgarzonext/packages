--------------------------------------------------------
--  DDL for Package PAC_IMPUESTOS_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IMPUESTOS_CONF" IS
   /******************************************************************************
   NOMBRE:     PAC_IMPUESTOS_CONF
   PROPÓSITO:  Package que contiene las funciones propias de calculo de impuestos para CONF
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/06/2012   JLB              22516: CONF898-Nuevas poblaciones con RETEICA
   2.0        22/06/2012    JLB                    22578: CONF_A003-IVA para la garantia de Gastos Medico por Enf. Graves - Producto Liberty Life
   ******************************************************************************/
   /*************************************************************************
   FUNCTION f_reteica_indicador:  Encontrar el valor reteica de indicadores
   param in pcagente : Codigo agente
   param out pvalor  : Porcentaje de ICA
   *************************************************************************/
   FUNCTION f_reteica_indicador(pcagente IN NUMBER) RETURN NUMBER;

   /*************************************************************************
   FUNCTION f_reteica_provin
   Encontrar el valor reteica
   param in pcagente    : codigo agente
   param out pvalor  : devuelve el valor de la provincia para aplicar el reteica
   *************************************************************************/
   FUNCTION f_reteica_provin(pcagente IN NUMBER) RETURN NUMBER;

   /*************************************************************************
   FUNCTION f_reteica_poblac
   Encontrar el valor reteica
   param in pcagente    : codigo agente
   param out pvalor  : devuelve el valor de la poblacion para aplicar el reteica
   *************************************************************************/
   FUNCTION f_reteica_poblac(pcagente IN NUMBER) RETURN NUMBER;

   --Ini Bug: 22443  MCA Unificar impuestos
   /*************************************************************************
   FUNCTION f_retefuente
   Encontrar el valor retefuente
   param in pcagente    : codigo agente
   param out pretefuente  : devuelve el valor del retefuente a buscar dentro de las vigencias
   *************************************************************************/
   FUNCTION f_retefuente(pcagente IN NUMBER) RETURN NUMBER;

   -- INI - JLB - BUG 22578
   /*************************************************************************
   FUNCTION f_iva_provinciariesgo
   Encontrar el valor de la provincia de localizaciÃ³n del riesgo para saber que tipo de iva se aplica
   param in ptabla      : tablas de origen
   param in psseguro    : seguro
   param out pvalor  : devuelve el valor de la provincia para aplicar el el iva
   *************************************************************************/
   FUNCTION f_iva_provinciariesgo(ptabla   IN VARCHAR2,
                                  psseguro IN NUMBER,
                                  pnriesgo IN NUMBER) RETURN NUMBER;

   /*************************************************************************
   FUNCTION f_iva_poblacionriesgo
   Encontrar el valor de la poblacion de localización del riesgo para saber que tipo de iva se aplica
   param in ptabla      : tablas de origen
   param in psseguro    : sseguro
   param out pvalor     :devuelve el valor de la poblacion para aplicar el reteica
   *************************************************************************/
   FUNCTION f_iva_poblacionriesgo(ptabla   IN VARCHAR2,
                                  psseguro IN NUMBER,
                                  pnriesgo IN NUMBER) RETURN NUMBER;

   -- INI - CONF-190 -- AP
   /*************************************************************************
   FUNCTION F_ENTIDAD_EXC_IVA
   Encontrar si el tomador es una persona (entidad) sin ánimo de lucro exenta de IVA
   param in ptabla      : tablas de origen
   param in psseguro    : seguro
   param out pvalor     : devuelve 1 si la entidad es sin ánimo de lucro exenta de iva y 0 si no
   *************************************************************************/
   FUNCTION f_entidad_exc_iva(ptabla   IN VARCHAR2,
                              psseguro IN NUMBER) RETURN NUMBER;
   -- FIN - CONF-190 -- AP

   /*************************************************************************
   FUNCTION f_gastos_expedicion
   Encontrar el valor los gastos de expedicion según producto y moneda
   param in ptabla      : tablas de origen
   param in psseguro    : sseguro
   param out pvalor     :devuelve el valor de los gastos en la moneda produto
   *************************************************************************/
   FUNCTION f_gastos_expedicion(porigen IN NUMBER,
                                psseguro IN NUMBER,
                                pnriesgo IN NUMBER) RETURN NUMBER;

   FUNCTION f_indicador_agente(pcagente IN NUMBER,
                               pcimpret IN NUMBER,
                               pfecha   IN DATE) RETURN VARCHAR2;
   /*************************************************************************
      FUNCTION f_busca_padre
      Retorna el agente padre con CTIPAGE  IN (2,3) del agente que se especifica (hijo)
      param in pcagente      : cagente
      param in pctipage      : ctipage
      param in pfbusca       : f_sysdate
   *************************************************************************/
   -- CONF 403 - JVG - 20/10/2017 - se crea la funcion
   FUNCTION f_busca_padre(
      pcagente IN NUMBER)
      RETURN NUMBER;
  /*************************************************************************
      FUNCTION f_indicador_primas_emitidas
      Retorna el indicador de los impuestos de la emisi?n de primas (iva solamente)
      param in psperson : sperson
      param in pfbusca       : f_sysdate
   *************************************************************************/
   -- CONF 403 - JVG - 23/10/2017 - se crea la funcion
      FUNCTION f_indicador_primas_emitidas(psperson IN NUMBER,
                                           pfecha   IN DATE) RETURN VARCHAR2;
 /*************************************************************************
      FUNCTION f_indicador_Coa_Rea
      Retorna el indicador de los impuestos de la compañia coaseguradora y reaseguradora
      param in pccompani  : ccompani
      param in pctipcoa   : ctipcoa
      param in pfbusca    : f_sysdate
      param out pvalor    : Indicador impuesto SAP
   *************************************************************************/
   -- CONF 403 - JVG - 27/10/2017 - se crea la funcion
   FUNCTION f_indicador_Coa_Rea(pccompani IN NUMBER ,pcimpret IN NUMBER, pctipcoa IN NUMBER,
                                         pfecha  IN DATE) RETURN VARCHAR2;

   /*************************************************************************
   FUNCTION f_reteica_indicador_coa:  Encontrar el valor reteica de indicadores
   param in pccompania : Codigo Compañía
   param out pvalor  : Porcentaje de ICA
   *************************************************************************/
   FUNCTION f_reteica_indicador_coa(pccompania IN NUMBER) RETURN NUMBER;

END pac_impuestos_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_IMPUESTOS_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IMPUESTOS_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IMPUESTOS_CONF" TO "PROGRAMADORESCSI";
