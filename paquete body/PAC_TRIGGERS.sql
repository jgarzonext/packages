--------------------------------------------------------
--  DDL for Package Body PAC_TRIGGERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_TRIGGERS" AS
/******************************************************************************
   NAME:       PAC_TRIGGERS
   PURPOSE:    En el body no es necesario código alguno

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        23/03/2010   DRA             1. 0013679: CRE200 - Problemas con el alta de cuentas CCC en alta rápida de personas
******************************************************************************/
BEGIN
   NULL;
END pac_triggers;

/

  GRANT EXECUTE ON "AXIS"."PAC_TRIGGERS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_TRIGGERS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_TRIGGERS" TO "PROGRAMADORESCSI";
