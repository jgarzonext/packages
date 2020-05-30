--------------------------------------------------------
--  DDL for Package PAC_PERSISTENCIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PERSISTENCIA" IS
   kborradosesion NUMBER := 90;   -- minutos desde el ultimo acceso a la sesión para su borrado

   FUNCTION f_inicializar_contexto(pidsession VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_guardar_contexto(pidsession VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_limpiar_contexto(pidsession VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_limpiar_conexiones(pidsession VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_PERSISTENCIA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PERSISTENCIA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PERSISTENCIA" TO "PROGRAMADORESCSI";
