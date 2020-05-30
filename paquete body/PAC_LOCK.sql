--------------------------------------------------------
--  DDL for Package Body PAC_LOCK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_LOCK" AS
/******************************************************************************
Package que tiene como utilidad la gestión y control de bloqueos
de objetos de la base de datos
******************************************************************************/
 FUNCTION f_lock (pidlock IN VARCHAR2)
     RETURN NUMBER IS
	 /*************************************************************************
	 función que bloquea un objeto, para esto inserta un registro en la tabla
	 temporal tmp_lock
	 **************************************************************************/
	BEGIN
	  BEGIN
	   INSERT INTO tmp_lock (id_lock, finilock, cuser)
	    VALUES (pidlock, f_sysdate,F_USER);
	  EXCEPTION
	    WHEN OTHERS THEN
		  RETURN 151585; --Objeto bloqueado por otro registro
	  END;
	 RETURN 0;
	END f_lock;

 FUNCTION f_get_userlock(pidlock IN VARCHAR2)
     RETURN VARCHAR2 IS
	  /**********************************************************************
	  función que nos indica que usuario tiene bloquado un determinado objeto
	  **********************************************************************/
	  c_cuser tmp_lock.cuser%type;
	 BEGIN
	   BEGIN
	    SELECT cuser
		 INTO c_cuser
		 FROM tmp_lock
		WHERE id_lock = pidlock;
	   EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		 c_cuser:=NULL;
	   END;
	  RETURN c_cuser;
	 END f_get_userlock;

 FUNCTION f_get_timelock(pidlock IN VARCHAR2)
     /**********************************************************************
	 función que nos indica el tiempo que hace que se reservo el objeto
	 **********************************************************************/
     RETURN NUMBER  IS
	BEGIN
	 RETURN 0;
	END f_get_timelock;

 FUNCTION f_set_userlock(pidlock IN VARCHAR2 ,puser IN VARCHAR2)
     /**********************************************************************
	 Modifica el usuario que bloquea un objeto
	 **********************************************************************/
     RETURN NUMBER IS
	BEGIN
	  BEGIN
	    UPDATE tmp_lock
	       SET cuser = puser
	     WHERE id_lock =pidlock;
	   IF sql%rowcount  = 0 THEN
	    RETURN 151586; -- objeto no reservado
	   END IF;
	  END;
	 RETURN 0;
	END f_set_userlock;

 FUNCTION f_set_timelock(pidlock IN VARCHAR2 ,pdate IN DATE)
     /**********************************************************************
	 Modifica el momento de la reserva y por tanto el tiempo que lleva reservado
	 **********************************************************************/
     RETURN NUMBER IS
   BEGIN
     BEGIN
	   UPDATE tmp_lock
	       SET finilock = pdate
	     WHERE id_lock =pidlock;
	   IF sql%rowcount  = 0 THEN
	    RETURN 151586; -- objeto no reservado
	   END IF;
	  END;
	RETURN 0;
   END  f_set_timelock;

 PROCEDURE p_unlock(pidlock IN VARCHAR2) IS
     /**********************************************************************
	  procedimiento que desbloquea un objeto borrando el registro de bloqueo
	  de la tabla tmp_lock
	 **********************************************************************/
  BEGIN
    DELETE tmp_lock
	 WHERE id_lock = pidlock;
  END p_unlock;

  PROCEDURE p_unlock(pidlock IN VARCHAR2,pcuser IN VARCHAR2) IS
     /**********************************************************************
	  Sobrecarga de p_unlock , solo borra en el caso en que coincida el usuario
	  si no coincide con el que se pasa por parametro salta una excepcion, forma
	  segura de borrar un bloqueo.
	 **********************************************************************/
  BEGIN
    DELETE tmp_lock
	 WHERE id_lock = pidlock
	   AND cuser = pcuser;
	IF sql%rowcount = 0 THEN
	 raise_application_error(151586,'object not found');
	END IF;
  END p_unlock;
END pac_lock;

/

  GRANT EXECUTE ON "AXIS"."PAC_LOCK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LOCK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LOCK" TO "PROGRAMADORESCSI";
