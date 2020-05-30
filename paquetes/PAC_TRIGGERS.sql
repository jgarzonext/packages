--------------------------------------------------------
--  DDL for Package PAC_TRIGGERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_TRIGGERS" AS
/******************************************************************************
   NAME:       PAC_TRIGGERS
   PURPOSE:    Servirá para declarar todas las variables necesarias en los triggers mutantes

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        23/03/2010   DRA             1. 0013679: CRE200 - Problemas con el alta de cuentas CCC en alta rápida de personas
******************************************************************************/

   -- Para el trigger SINIESTROS.HISTORIAL_SINIESTROS
   TYPE t_ccc IS TABLE OF per_ccc%ROWTYPE
      INDEX BY BINARY_INTEGER;

   vtccc_new      t_ccc;
   vtccc_old      t_ccc;
   vccc_comptador BINARY_INTEGER := 0;
   vccc_trigger   BINARY_INTEGER := 0;
END pac_triggers;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_TRIGGERS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_TRIGGERS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_TRIGGERS" TO "PROGRAMADORESCSI";
