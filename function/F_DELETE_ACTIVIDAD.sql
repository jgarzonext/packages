--------------------------------------------------------
--  DDL for Function F_DELETE_ACTIVIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DELETE_ACTIVIDAD" (pcramo IN NUMBER,
                                              pcmodali IN NUMBER,
					      pccolect IN NUMBER,
					      pctipseg IN NUMBER,
					      psproduc IN NUMBER,
					      pcactivi IN NUMBER) RETURN NUMBER authid current_user IS

/********************************************************************
 Borra una actividad de un producto
********************************************************************/

BEGIN
  DELETE
    FROM clausugar
   WHERE cmodali = pcmodali
     AND ccolect = pccolect
     AND ctipseg = pctipseg
     AND cactivi = pcactivi
     AND cramo = pcramo;

  DELETE
    FROM comisionacti
   WHERE cmodali = pcmodali
     AND ccolect = pccolect
     AND ctipseg = pctipseg
     AND cactivi = pcactivi
     AND cramo = pcramo;

  DELETE
    FROM comisiongar
   WHERE cmodali = pcmodali
     AND ccolect = pccolect
     AND ctipseg = pctipseg
     AND cactivi = pcactivi
     AND cramo = pcramo;

  DELETE
    FROM forpagrecacti
   WHERE cmodali = pcmodali
     AND ccolect = pccolect
     AND ctipseg = pctipseg
     AND cactivi = pcactivi
     AND cramo = pcramo;

  DELETE
    FROM garanformula
   WHERE cmodali = pcmodali
     AND ccolect = pccolect
     AND ctipseg = pctipseg
     AND cactivi = pcactivi
     AND cramo = pcramo;

  DELETE
    FROM paractividad
   WHERE cactivi = pcactivi
     AND sproduc = psproduc;

  DELETE
    FROM pargaranpro
   WHERE cmodali = pcmodali
     AND ccolect = pccolect
     AND ctipseg = pctipseg
     AND cactivi = pcactivi
     AND cramo = pcramo;

  DELETE
    FROM garanpro
   WHERE cmodali = pcmodali
     AND ccolect = pccolect
     AND ctipseg = pctipseg
     AND cactivi = pcactivi
     AND cramo = pcramo;

  DELETE
    FROM incompgaran
   WHERE cmodali = pcmodali
     AND ccolect = pccolect
     AND ctipseg = pctipseg
     AND cactivi = pcactivi
     AND cramo = pcramo;

  DELETE
    FROM codmorpar_garanpro
   WHERE cmodali = pcmodali
     AND ccolect = pccolect
     AND ctipseg = pctipseg
     AND cactivi = pcactivi
     AND cramo = pcramo;

  DELETE
    FROM forpagrecgaran
   WHERE cmodali = pcmodali
     AND ccolect = pccolect
     AND ctipseg = pctipseg
     AND cactivi = pcactivi
     AND cramo = pcramo;

  DELETE
    FROM garanprogas
   WHERE cmodali = pcmodali
     AND ccolect = pccolect
     AND ctipseg = pctipseg
     AND cactivi = pcactivi
     AND cramo = pcramo;

  DELETE
    FROM garanpro_sbpri
   WHERE cmodali = pcmodali
     AND ccolect = pccolect
     AND ctipseg = pctipseg
     AND cactivi = pcactivi
     AND cramo = pcramo;

  DELETE
    FROM garanpro_sbpri_depor
   WHERE cmodali = pcmodali
     AND ccolect = pccolect
     AND ctipseg = pctipseg
     AND cactivi = pcactivi
     AND cramo = pcramo;

  DELETE
    FROM garanpro_sbpri_prof
   WHERE cmodali = pcmodali
     AND ccolect = pccolect
     AND ctipseg = pctipseg
     AND cactivi = pcactivi
     AND cramo = pcramo;

  DELETE
    FROM garanprotramit
   WHERE cactivi = pcactivi
     AND sproduc = psproduc;

  DELETE
    FROM intcomprogar
   WHERE cmodali = pcmodali
     AND ccolect = pccolect
     AND ctipseg = pctipseg
     AND cactivi = pcactivi
     AND cramo = pcramo;

  DELETE
    FROM intprogar
   WHERE cmodali = pcmodali
     AND ccolect = pccolect
     AND ctipseg = pctipseg
     AND cactivi = pcactivi
     AND cramo = pcramo;

  DELETE
    FROM pregunprogaran
   WHERE cactivi = pcactivi
     AND sproduc = psproduc;

  DELETE
    FROM vinculaciones_prod
   WHERE cmodali = pcmodali
     AND ccolect = pccolect
     AND ctipseg = pctipseg
     AND cactivi = pcactivi
     AND cramo = pcramo;

  DELETE
    FROM detcampanya
   WHERE cactivi = pcactivi
     AND sproduc = psproduc;

  DELETE
    FROM detcarencias
   WHERE cmodali = pcmodali
     AND ccolect = pccolect
     AND ctipseg = pctipseg
     AND cactivi = pcactivi
     AND cramo = pcramo;

  commit;

  return 0;
EXCEPTION
  WHEN others THEN
    return -1;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_DELETE_ACTIVIDAD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DELETE_ACTIVIDAD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DELETE_ACTIVIDAD" TO "PROGRAMADORESCSI";
