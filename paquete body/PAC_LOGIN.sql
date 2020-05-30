--------------------------------------------------------
--  DDL for Package Body PAC_LOGIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_LOGIN" AS
/******************************************************************************
   NOMBRE:       PAC_LOGIN
   PROPÓSITO:  Funciones para realizar una conexión
               a base de datos de la capa de negocio

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        4/12/2008   PCT               1. Creación del package.
******************************************************************************/

   /*************************************************************************
      Función que insertará en la tabla log_conexión.
   *************************************************************************/
   FUNCTION f_set_log_conexion(
      pcusuari IN usuarios.cusuari%TYPE,
      psession IN log_conexion.session_id%TYPE,
      remoteip IN VARCHAR2,
      pfconexion IN log_conexion.fconexion%TYPE,
      pcoficina IN log_conexion.coficina%TYPE,
      pmsg IN log_conexion.msg%TYPE,
      pvalpaswd IN NUMBER)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      IF pcusuari IS NULL THEN   -- NO HAGO NADA PCT
         RETURN 0;
      ELSE
         INSERT INTO log_conexion
                     (cusuari, session_id, nipusu, fconexion, coficina, msg, cestcon)
              VALUES (pcusuari, psession, remoteip, pfconexion, pcoficina, pmsg, pvalpaswd);

         COMMIT;
         RETURN 0;   ---Todo correcto
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, pcusuari, 'F_set_log_conexion', 1, 'error no controlat',
                     SQLERRM);
         RETURN 9000655;   ---Error en registrar la connexió
   END;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_LOGIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LOGIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LOGIN" TO "PROGRAMADORESCSI";
