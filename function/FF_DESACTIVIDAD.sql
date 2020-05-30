--------------------------------------------------------
--  DDL for Function FF_DESACTIVIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_DESACTIVIDAD" (
   p_cactivi IN NUMBER,
   p_cramo IN NUMBER,
   p_cidioma IN NUMBER,
   p_campo IN NUMBER DEFAULT 2)
   RETURN VARCHAR2 AUTHID CURRENT_USER IS
   /***********************************************************************
   FF_DESACTIVIDAD: Descripción de la actividad.
   ***********************************************************************/
   v_des          activisegu.tactivi%TYPE;
BEGIN
   SELECT DECODE(p_campo, 1, ttitulo, tactivi)
     INTO v_des
     FROM activisegu
    WHERE cactivi = p_cactivi
      AND cramo = p_cramo
      AND cidioma = p_cidioma;

   RETURN v_des;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_DESACTIVIDAD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_DESACTIVIDAD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_DESACTIVIDAD" TO "PROGRAMADORESCSI";
