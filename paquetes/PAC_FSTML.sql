--------------------------------------------------------
--  DDL for Package PAC_FSTML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_FSTML" AUTHID CURRENT_USER
IS
   FUNCTION f_montar_fichero (pfichero NUMBER, pdatos VARCHAR2, psecuencia IN OUT NUMBER, plinea IN OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_escribir_fichero (pfichero NUMBER, psecuencia NUMBER, nomfich IN OUT VARCHAR2)
      RETURN NUMBER;
END pac_fstml;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_FSTML" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FSTML" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FSTML" TO "PROGRAMADORESCSI";
