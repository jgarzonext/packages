--------------------------------------------------------
--  DDL for Function F_PCOMISI_CIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PCOMISI_CIA" (
   pcramo IN NUMBER,
   pcmodali IN NUMBER,
   pctipseg IN NUMBER,
   pccolect IN NUMBER,
   pcactivi IN NUMBER,
   pcmodcom IN NUMBER,
   ppcomisi OUT NUMBER,
   pfecha IN DATE DEFAULT f_sysdate)
   RETURN NUMBER AUTHID CURRENT_USER IS
   /******************************************************************************
      NOMBRE:     F_PCOMISI_CIA
      PROPÓSITO:  Función que encuentra el porcentaje a aplicar sobre la prima
                  neta para generar los nuevos conceptos de detalle de recibo

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      2.0        11/02/2011  JMP              BUG 0015137: Tener en cuenta la fecha de vigencia
   ******************************************************************************/
   xccompani      NUMBER := 0;   -- Compañia del producto.
   xccomisi       NUMBER := 0;   -- Cuadro de comisiones de la compañia.
BEGIN
   -- Se obtiene la compañia del producto.
   BEGIN
      SELECT ccompani
        INTO xccompani
        FROM productos
       WHERE ctipseg = pctipseg
         AND ccolect = pccolect
         AND cramo = pcramo
         AND cmodali = pcmodali;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 100503;   --Producto inexistente.
   END;

   IF xccompani IS NOT NULL THEN
      -- Se obtiene el cuadro de comisiones de la compañia.
      BEGIN
         SELECT ccomisi
           INTO xccomisi
           FROM companias
          WHERE ccompani = xccompani;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 100508;   -- Compañia inexistente.
      END;

      -- Obtener los porcentajes del cuadro por producto/actividad.
      BEGIN
         SELECT pcomisi
           INTO ppcomisi
           FROM comisionacti
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect
            AND cactivi = pcactivi
            AND ccomisi = xccomisi
            AND cmodcom = pcmodcom
            -- BUG 15137 - 11/02/2011 - JMP - Tener en cuenta la fecha de vigencia
            AND finivig = (SELECT MAX(finivig)
                             FROM comisionacti
                            WHERE cramo = pcramo
                              AND cmodali = pcmodali
                              AND ctipseg = pctipseg
                              AND ccolect = pccolect
                              AND cactivi = pcactivi
                              AND ccomisi = xccomisi
                              AND cmodcom = pcmodcom
                              AND finivig <= pfecha);
      -- FIN BUG 15137 - 11/02/2011 - JMP
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT pcomisi
                 INTO ppcomisi
                 FROM comisionprod
                WHERE cramo = pcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect
                  AND ccomisi = xccomisi
                  AND cmodcom = pcmodcom
                  -- BUG 15137 - 11/02/2011 - JMP - Tener en cuenta la fecha de vigencia
                  AND finivig = (SELECT MAX(finivig)
                                   FROM comisionprod
                                  WHERE cramo = pcramo
                                    AND cmodali = pcmodali
                                    AND ctipseg = pctipseg
                                    AND ccolect = pccolect
                                    AND ccomisi = xccomisi
                                    AND cmodcom = pcmodcom
                                    AND finivig <= pfecha);
            -- FIN BUG 15137 - 11/02/2011 - JMP
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 100933;   -- Comissión inexistente
               WHEN OTHERS THEN
                  RETURN 103216;   --Error al leer de la tabla COMISIONPROD
            END;
         WHEN OTHERS THEN
            RETURN 103628;   -- Error al leer de la tabla COMISIONACTI
      END;
   END IF;

   RETURN(0);
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PCOMISI_CIA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PCOMISI_CIA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PCOMISI_CIA" TO "PROGRAMADORESCSI";
