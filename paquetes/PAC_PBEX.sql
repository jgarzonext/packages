--------------------------------------------------------
--  DDL for Package PAC_PBEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PBEX" AUTHID CURRENT_USER IS
/***************************************************************************
   PAC_LISTA: Package para calcular provisiones.
   ALLIBP01 - Package de procedimientos de B.D.
***************************************************************************/
   FUNCTION f_commit_pbex(
      cempres IN NUMBER,
      aux_factual IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER)
      RETURN NUMBER;

   /************************************************************************
      proceso_batch_cierre
         Proceso batch de inserción de la PB en CTASEGURO.

       Parámetros Entrada:

           psmodo : Modo (1-->Previo y '2 --> Real)
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
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_PBEX" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PBEX" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PBEX" TO "PROGRAMADORESCSI";
