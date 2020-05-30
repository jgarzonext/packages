--------------------------------------------------------
--  DDL for Function F_DESCENTIDADSIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESCENTIDADSIN" (pcenti NUMBER)
   RETURN VARCHAR2 IS
/******************************************************************************
   --Bug 26857-XVM-27/06/2013
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

   RETURN v_tbanco;
END f_descentidadsin;

/

  GRANT EXECUTE ON "AXIS"."F_DESCENTIDADSIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESCENTIDADSIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESCENTIDADSIN" TO "PROGRAMADORESCSI";
