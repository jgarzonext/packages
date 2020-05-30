--------------------------------------------------------
--  DDL for Package Body GETTIMER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."GETTIMER" IS
 start_time number;
 PROCEDURE reset_timer IS
 BEGIN
  start_time := dbms_utility.get_time;
 END reset_timer;
 FUNCTION get_elapsed_time RETURN NUMBER IS
 BEGIN
  RETURN ((dbms_utility.get_time - start_time)/100);
 END get_elapsed_time;
END gettimer;

/

  GRANT EXECUTE ON "AXIS"."GETTIMER" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."GETTIMER" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."GETTIMER" TO "PROGRAMADORESCSI";
