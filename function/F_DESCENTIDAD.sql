--------------------------------------------------------
--  DDL for Function F_DESCENTIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESCENTIDAD" (pcenti NUMBER)
   RETURN VARCHAR2 IS
/******************************************************************************
   NAME:       F_DESCENTIDAD
   Función que retorna el nombre de la entidad, o en el caso que no exista
   retorna NULL
******************************************************************************/
   v_tbanco       VARCHAR2(36);
BEGIN
   BEGIN
      SELECT tbanco
        INTO v_tbanco
        FROM bancos
       WHERE cbanco = pcenti;
   EXCEPTION
      WHEN OTHERS THEN
         v_tbanco := NULL;
   END;

   RETURN REPLACE(v_tbanco, CHR(39), CHR(39) || CHR(39));
END f_descentidad;

/

  GRANT EXECUTE ON "AXIS"."F_DESCENTIDAD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESCENTIDAD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESCENTIDAD" TO "PROGRAMADORESCSI";
