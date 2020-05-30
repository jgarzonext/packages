--------------------------------------------------------
--  DDL for Package Body PAC_UTIL_JAVA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_UTIL_JAVA" IS
   PROCEDURE f_get_list_files(p_dir IN VARCHAR2, p_sproces IN VARCHAR2) AS
      LANGUAGE JAVA
      NAME 'ListFicheros.getFileList(java.lang.String, java.lang.String)';

   FUNCTION get_path_oracle(dir IN VARCHAR2)
      RETURN VARCHAR2 IS
      o_path         all_directories.directory_path%TYPE;
   BEGIN
      SELECT directory_path
        INTO o_path
        FROM all_directories d
       WHERE d.directory_name = dir;

      RETURN o_path;
   END get_path_oracle;
END pac_util_java;

/

  GRANT EXECUTE ON "AXIS"."PAC_UTIL_JAVA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_UTIL_JAVA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_UTIL_JAVA" TO "PROGRAMADORESCSI";
