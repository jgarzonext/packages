--------------------------------------------------------
--  DDL for Package PAC_MIGRA_10G
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MIGRA_10G" 
   AUTHID   current_user
IS
PROCEDURE
   p_migra_10g
   (ps_user IN VARCHAR2, ps_repserver IN VARCHAR2);
PROCEDURE
   p_deshaz_10g
   (ps_user IN VARCHAR2, ps_repserver IN VARCHAR2);
PROCEDURE
   p_show_users;
  -----------------------------------------------------------------------------
END pac_migra_10g;

 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MIGRA_10G" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MIGRA_10G" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MIGRA_10G" TO "PROGRAMADORESCSI";
