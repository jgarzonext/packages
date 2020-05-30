--------------------------------------------------------
--  DDL for Function F_ULTSUPL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ULTSUPL" (
   pnpoliza IN NUMBER,
   pncertif IN NUMBER,
   pnsuplem IN OUT NUMBER,
   pfefepol IN OUT DATE,
   pfefesupl IN OUT DATE)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************
   F_ULTSUPL: Retorna el número de suplemento y fecha de efecto
      del último suplemento.
   ALLIBCTR - Gestión de datos referentes a los seguros
   No tenemos en cuenta las regularizaciones
   No tendremos en cuenta los movimientos anulados
      (nuevo tipo -> cmovseg = 52)
***********************************************************************/
   CURSOR c_suplemento IS
      SELECT   s.nsuplem, s.fefecto, m.fefecto
          FROM movseguro m, seguros s
         WHERE      /*m.cmovseg = 1
                 AND*/
               m.cmovseg NOT IN(6, 52)
           AND m.sseguro = s.sseguro
           AND s.ncertif = pncertif
           AND s.npoliza = pnpoliza
      ORDER BY m.fefecto DESC;

   num_err        NUMBER;
BEGIN
   OPEN c_suplemento;

   FETCH c_suplemento
    INTO pnsuplem, pfefepol, pfefesupl;

   IF c_suplemento%FOUND THEN
      num_err := 0;
   ELSE
      num_err := 100525;   -- Suplement inexistent
   END IF;

   CLOSE c_suplemento;

   RETURN(num_err);
-- BUG 21546_108724 - 07/02/2012 - JLTS - Cierre de posibles cursores abiertos
EXCEPTION
   WHEN OTHERS THEN
      IF c_suplemento%ISOPEN THEN
         CLOSE c_suplemento;
      END IF;

      RETURN 140999;
END;

/

  GRANT EXECUTE ON "AXIS"."F_ULTSUPL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ULTSUPL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ULTSUPL" TO "PROGRAMADORESCSI";
