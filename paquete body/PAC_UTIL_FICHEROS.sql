--------------------------------------------------------
--  DDL for Package Body PAC_UTIL_FICHEROS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_UTIL_FICHEROS" IS
    /******************************************************************************
      NOMBRE:       PAC_UTIL_FICHEROS
      PROPÓSITO:
      REVISIONES:

      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
       1.0       06/05/2014  MMS              1. Creación de package
   ******************************************************************************/

   -- Copia un fichero de un directorio a otro. Retorna 0 si OK, sino 1
   FUNCTION copiar_fichero(ppath_orig VARCHAR2, ppath_dest VARCHAR2, pfichero VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      UTL_FILE.fcopy(ppath_orig, pfichero, ppath_dest, pfichero);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'copiar_fichero', 1, SQLERRM, SQLERRM);
   END copiar_fichero;

   -- Elimina un fichero. Retorna 0 si OK, sino 1
   FUNCTION borrar_fichero(ppath VARCHAR2, pfichero VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      UTL_FILE.fremove(ppath, pfichero);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'borrar_fichero', 1, SQLERRM, SQLERRM);
   END borrar_fichero;

   -- Mueve un fichero de un directorio a otro. Retorna 0 si OK, sino 1
   FUNCTION mover_fichero(ppath_orig VARCHAR2, ppath_dest VARCHAR2, pfichero VARCHAR2)
      RETURN NUMBER IS
      verror         NUMBER;
      vdesc          VARCHAR2(100);
      error          EXCEPTION;
   BEGIN
      verror := copiar_fichero(ppath_orig, ppath_dest, pfichero);

      IF verror = 0 THEN
         verror := borrar_fichero(ppath_orig, pfichero);

         IF verror <> 0 THEN
            vdesc := 'no se copiado al directorio destino el fichero';
            RAISE error;
         END IF;
      ELSE
         vdesc := 'no se ha eliminado el fichero en el directorio origen';
         RAISE error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN error THEN
         p_tab_error(f_sysdate, f_user, 'mover_fichero', 1, vdesc, SQLERRM);
   END mover_fichero;
END pac_util_ficheros;

/

  GRANT EXECUTE ON "AXIS"."PAC_UTIL_FICHEROS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_UTIL_FICHEROS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_UTIL_FICHEROS" TO "PROGRAMADORESCSI";
