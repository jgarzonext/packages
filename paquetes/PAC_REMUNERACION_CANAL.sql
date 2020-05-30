--------------------------------------------------------
--  DDL for Package PAC_REMUNERACION_CANAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_REMUNERACION_CANAL" AS
   /******************************************************************************
      NOMBRE:      PAC_REMUNERACION_CANAL
      PROPÓSITO:   Contiene las funciones de cierre de la remuneracion del canal

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        15/11/2011   DRA               1. 0019347: LCOL_C002 - Proceso de cierre de remuneración al canal
   ******************************************************************************/
   FUNCTION f_cierre_remun_pol(
      psproces IN NUMBER,
      psremcanal IN NUMBER,
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE)
      RETURN NUMBER;

   FUNCTION f_cierre_remun_rec(
      psproces IN NUMBER,
      psremcanal IN NUMBER,
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE)
      RETURN NUMBER;

   FUNCTION f_cierre_remun_sin(
      psproces IN NUMBER,
      psremcanal IN NUMBER,
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE)
      RETURN NUMBER;

   FUNCTION f_cierre_remun_canal(
      psproces IN NUMBER,
      psremcanal IN NUMBER,
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pfproces IN DATE)
      RETURN NUMBER;

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
END pac_remuneracion_canal;

/

  GRANT EXECUTE ON "AXIS"."PAC_REMUNERACION_CANAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REMUNERACION_CANAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REMUNERACION_CANAL" TO "PROGRAMADORESCSI";
