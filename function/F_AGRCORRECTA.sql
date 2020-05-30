--------------------------------------------------------
--  DDL for Function F_AGRCORRECTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_AGRCORRECTA" (precibo IN NUMBER, pagrupacion IN NUMBER, pcorrecta OUT NUMBER)
RETURN NUMBER authid current_user IS
/* ********************************************************************
    F_AGRCORRECTA  Funcion que devuelve dado un recibo y una agrupacion
                 si el producto al que pertenece el seguro es de la agru-
                 pacion que entramos.
              Siendo los valores de la agrupacion
               1. No vida (Cualquier valor de cagrpro != 2)
               2. Vida (cagrpro = 2)
    ALIBADM.
*********************************************************************** */
  error NUMBER := 0;
  agrac NUMBER;
BEGIN
 BEGIN
   SELECT DECODE(p.cagrpro,2,2,1)
     INTO agrac
     FROM seguros s,recibos r,productos p
    WHERE r.nrecibo = precibo
      AND  r.sseguro = s.sseguro
      AND  p.cramo = s.cramo
      AND  p.cmodali = s.cmodali
      AND  p.ctipseg = s.ctipseg
      AND  p.ccolect = s.ccolect;
 EXCEPTION
    WHEN no_data_found THEN
      error := 104347;  -- Producto no encontrado
    WHEN others THEN
      error := 105743;   -- Error al leer en las tablas RECIBOS,SEGUROS,PRODUCTOS
 END;
 IF error != 0 THEN
   RETURN error;
 END IF;
 IF agrac = pagrupacion THEN
   pcorrecta := 1;  -- El producto es de la agrupacion deseada
 ELSE
   pcorrecta := 0;  -- El producto no es de la agrupacion deseada
 END IF;
 RETURN 0;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_AGRCORRECTA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_AGRCORRECTA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_AGRCORRECTA" TO "PROGRAMADORESCSI";
