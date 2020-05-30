--------------------------------------------------------
--  DDL for Function FF_DESAGENTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_DESAGENTE" (pcagente IN agentes.cagente%TYPE)
   RETURN VARCHAR2 AUTHID CURRENT_USER
IS
   vobjectname      VARCHAR2 (500) := 'FF_DESAGENTE';
   vparam           VARCHAR2 (500) := 'parámetros - pcagente:' || pcagente;
   vpasexec         NUMBER (5)     := 1;
   vdesagente       VARCHAR2 (500);
   vnum_err         NUMBER;
   e_object_error   EXCEPTION;
   e_param_error    EXCEPTION;
BEGIN
   --Comprovació de paràmetres d'entrada
   IF pcagente IS NULL
   THEN
      RAISE e_param_error;
   END IF;

   vnum_err := f_desagente (pcagente, vdesagente);

   IF vnum_err <> 0
   THEN
      RAISE e_object_error;
   END IF;

   RETURN vdesagente;
EXCEPTION
   WHEN e_param_error
   THEN
      p_tab_error (f_sysdate,
                   f_user,
                   vobjectname,
                   vpasexec,
                   vparam,
                   'Objeto invocado con parámetros erroneos'
                  );
      RETURN '**';
   WHEN e_object_error
   THEN
      p_tab_error (f_sysdate,
                   f_user,
                   vobjectname,
                   vpasexec,
                   vparam,
                   'Error F_DESAGENTE. Num_err:' || vnum_err
                  );
      RETURN '**';
   WHEN OTHERS
   THEN
      p_tab_error (f_sysdate,
                   f_user,
                   vobjectname,
                   vpasexec,
                   vparam,
                   'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                  );
      RETURN '**';
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_DESAGENTE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_DESAGENTE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_DESAGENTE" TO "PROGRAMADORESCSI";
