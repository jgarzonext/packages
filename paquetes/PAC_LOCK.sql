--------------------------------------------------------
--  DDL for Package PAC_LOCK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_LOCK" AS
/******************************************************************************
Package que tiene como utilidad la gestión y control de bloqueos
de objetos de la base de datos
******************************************************************************/
 FUNCTION f_lock (pidlock IN VARCHAR2)
     RETURN NUMBER;

 FUNCTION f_get_userlock(pidlock IN VARCHAR2)
     RETURN VARCHAR2;

 FUNCTION f_get_timelock(pidlock IN VARCHAR2)
     RETURN NUMBER;

 FUNCTION f_set_userlock(pidlock IN VARCHAR2 ,puser IN VARCHAR2)
     RETURN NUMBER;

 FUNCTION f_set_timelock(pidlock IN VARCHAR2 ,pdate IN DATE)
     RETURN NUMBER;

 PROCEDURE p_unlock(pidlock IN VARCHAR2);

  PROCEDURE p_unlock(pidlock IN VARCHAR2,pcuser IN VARCHAR2);

END pac_lock;

 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_LOCK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LOCK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LOCK" TO "PROGRAMADORESCSI";
