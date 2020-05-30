--------------------------------------------------------
--  DDL for Package PAC_UTIL_FICHEROS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_UTIL_FICHEROS" IS
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
      RETURN NUMBER;

   -- Elimina un fichero. Retorna 0 si OK, sino 1
   FUNCTION borrar_fichero(ppath VARCHAR2, pfichero VARCHAR2)
      RETURN NUMBER;

   -- Mueve un fichero de un directorio a otro. Retorna 0 si OK, sino 1
   FUNCTION mover_fichero(ppath_orig VARCHAR2, ppath_dest VARCHAR2, pfichero VARCHAR2)
      RETURN NUMBER;
END pac_util_ficheros;

/

  GRANT EXECUTE ON "AXIS"."PAC_UTIL_FICHEROS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_UTIL_FICHEROS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_UTIL_FICHEROS" TO "PROGRAMADORESCSI";
