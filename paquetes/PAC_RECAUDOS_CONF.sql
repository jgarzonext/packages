--------------------------------------------------------
--  DDL for Package PAC_RECAUDOS_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_RECAUDOS_CONF" IS
/******************************************************************************
   NOMBRE:       pac_recaudos_conf
   PROP¿SITO:
   REVISIONES:

   Ver  Fecha       Autor  Descripci¿n

******************************************************************************/

PROCEDURE p_recibos_convenio(
      p_fecha IN DATE DEFAULT NULL,
      p_dev IN OUT NUMBER,
      p_pro IN OUT NUMBER,
      p_err IN OUT NUMBER);
END pac_recaudos_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_RECAUDOS_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_RECAUDOS_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_RECAUDOS_CONF" TO "PROGRAMADORESCSI";
