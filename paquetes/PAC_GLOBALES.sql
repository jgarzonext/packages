--------------------------------------------------------
--  DDL for Package PAC_GLOBALES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_GLOBALES" IS
   --
   PROCEDURE p_asigna_global(p_global VARCHAR2, p_valor VARCHAR2);

   --
   FUNCTION f_obtiene_global(p_global VARCHAR2)
      RETURN VARCHAR2;
END pac_globales;

/

  GRANT EXECUTE ON "AXIS"."PAC_GLOBALES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_GLOBALES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_GLOBALES" TO "PROGRAMADORESCSI";
