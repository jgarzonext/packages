--------------------------------------------------------
--  DDL for Package PAC_GASTOS_FONDOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_GASTOS_FONDOS" AUTHID CURRENT_USER IS
/****************************************************************************
            NOMBRE:       PAC_GASTOS_FONDOS
            PROPÓSITO:  Funciones para cálculo de los Gastos sobre Fondos (Comisiones)

            REVISIONES:
    Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------  ----------------------------------
    1.0        14/02/2011    APD     1.- Bug 17243: ENSA101 - Rebuts de comissió  - Creación package.

****************************************************************************/
   /*************************************************************************
      f_generar_gastos_fondos
      Genera los gastos sobre fondos
      param in   psproces : Número de proceso
      param in   pfproces : Fecha del proceso
      param in   pcramo : Ramo
      param in   psproduc : Producto
      param in  psseguro : Sseguro
      Retorna diferente de 0 (un código de error) en caso de error
   *************************************************************************/
   FUNCTION f_generar_gastos_fondos(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfproces IN DATE,
      pcidioma IN NUMBER,
      pcagrup IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER;

   /************************************************************************
       f_proceso_cierre
          Proceso batch de inserción de la ALM en CTASEGURO

        Parámetros Entrada:

            psmodo : Modo (P-->Previo y R --> Real)
            pcempres: Empresa
            pmoneda: Divisa
            pcidioma: Idioma
            pfperini: Fecha Inicio
            pfperfin: Fecha Fin
            pfcierre: Fecha Cierre

        Parámetros Salida:

            pcerror : <>0 si ha habido algún error
            psproces : Proceso
            pfproces : Fecha en que se realiza el proceso

    *************************************************************************/
   PROCEDURE p_proceso_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcagrup IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE);

    /************************************************************************
      proceso_batch_cierre
         Proceso batch de inserción de la PB en CTASEGURO

       Parámetros Entrada:

           psmodo : Modo (P-->Previo y R --> Real)
           pcempres: Empresa
           pmoneda: Divisa
           pcidioma: Idioma
           pfperini: Fecha Inicio
           pfperfin: Fecha Fin
           pfcierre: Fecha Cierre

       Parámetros Salida:

           pcerror : <>0 si ha habido algún error
           psproces : Proceso
           pfproces : Fecha en que se realiza el proceso

   *************************************************************************/
   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE);
END pac_gastos_fondos;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_GASTOS_FONDOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_GASTOS_FONDOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_GASTOS_FONDOS" TO "PROGRAMADORESCSI";
