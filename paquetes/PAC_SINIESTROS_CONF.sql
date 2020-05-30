--------------------------------------------------------
--  DDL for Package PAC_SINIESTROS_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SINIESTROS_CONF" IS
   /******************************************************************************
   NOMBRE:     PAC_SINIESTROS_LCOL
   PROP¿SITO:  Cuerpo del paquete de las funciones para SINIESTROS LCOL

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        17/04/2012   JMF             0021897 LCOL_S001-SIN - Ajuste cambio moneda tras cierres (UAT 4208)
   ****************************************************************************/
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
   PROCEDURE p_cierre_mensual(
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

   PROCEDURE p_cierre_anual(
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
END pac_siniestros_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_SINIESTROS_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SINIESTROS_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SINIESTROS_CONF" TO "PROGRAMADORESCSI";
