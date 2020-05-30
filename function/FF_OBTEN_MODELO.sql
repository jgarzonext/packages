--------------------------------------------------------
--  DDL for Function FF_OBTEN_MODELO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_OBTEN_MODELO" (pcmodelo IN NUMBER)
   RETURN VARCHAR2 IS
/***********************************************************************
 ff_obten_modelo: Obtener la descripción de modelos
***********************************************************************/
   v_tmodelo      VARCHAR2(500);
BEGIN
   SELECT tmodelo
     INTO v_tmodelo
     FROM modelos
    WHERE cmodelo = pcmodelo;

   RETURN v_tmodelo;
EXCEPTION
   WHEN OTHERS THEN
      v_tmodelo := NULL;
      RETURN v_tmodelo;
END ff_obten_modelo;
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_OBTEN_MODELO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_OBTEN_MODELO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_OBTEN_MODELO" TO "PROGRAMADORESCSI";
