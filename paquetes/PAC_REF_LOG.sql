--------------------------------------------------------
--  DDL for Package PAC_REF_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_REF_LOG" IS

  FUNCTION f_log_update (ptidentif in varchar2, pcpatch in varchar2,
      psentencia in varchar2) RETURN number;

END PAC_REF_LOG;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_LOG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_LOG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REF_LOG" TO "PROGRAMADORESCSI";
