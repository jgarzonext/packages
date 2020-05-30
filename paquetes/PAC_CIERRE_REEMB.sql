--------------------------------------------------------
--  DDL for Package PAC_CIERRE_REEMB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CIERRE_REEMB" AS
/******************************************************************************
   NOMBRE:    PAC_CIERRE_REEMB

   REVISIONES:
   Ver        Fecha       Autor            Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        28/07/2009  ASN               creacion
   2.0        11/03/2010  ICV               2. 0010733: CRE - Listados de Reembolsos: Informe de siniestralidad

******************************************************************************/

   /***************************************************************************
         28/07/2009 ASN
         Cierre de reembolsos. Llena la tabla reemb_sinietralidad para estadisticas
   ***************************************************************************/
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

   FUNCTION f_reemb_siniestralidad(
      pcempres IN NUMBER,
      panyo IN NUMBER,
      psproces IN NUMBER,
      pcidioma IN NUMBER)
      RETURN NUMBER;
END pac_cierre_reemb;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_CIERRE_REEMB" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CIERRE_REEMB" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CIERRE_REEMB" TO "PROGRAMADORESCSI";
