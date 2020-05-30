--------------------------------------------------------
--  DDL for Package PAC_UTIL_JAVA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_UTIL_JAVA" IS
   PROCEDURE f_get_list_files(p_dir IN VARCHAR2, p_sproces IN VARCHAR2);

   FUNCTION get_path_oracle(dir IN VARCHAR2)
      RETURN VARCHAR2;
END pac_util_java;

/

  GRANT EXECUTE ON "AXIS"."PAC_UTIL_JAVA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_UTIL_JAVA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_UTIL_JAVA" TO "PROGRAMADORESCSI";
