--------------------------------------------------------
--  DDL for Package GETTIMER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."GETTIMER" 
IS
PROCEDURE reset_timer;
 FUNCTION get_elapsed_time RETURN NUMBER;
END gettimer;

 
 

/

  GRANT EXECUTE ON "AXIS"."GETTIMER" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."GETTIMER" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."GETTIMER" TO "PROGRAMADORESCSI";
