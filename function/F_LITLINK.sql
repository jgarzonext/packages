--------------------------------------------------------
--  DDL for Function F_LITLINK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_LITLINK" (psseguro IN NUMBER, pidioma IN NUMBER, texto OUT VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
   t1             VARCHAR(400);
   t2             VARCHAR(400);
   t3             VARCHAR(400);
   nmixta         NUMBER;
   ncreix         NUMBER;
   cadena         VARCHAR(80);
   error          NUMBER;
BEGIN
   t1 := f_axis_literales(107643, pidioma);
   t2 := f_axis_literales(107644, pidioma);
   t3 := f_axis_literales(107645, pidioma);

   SELECT SUM(nunidad)
     INTO nmixta
     FROM ctaseguro
    WHERE cesta = 15
      AND sseguro = psseguro;

   SELECT SUM(nunidad)
     INTO ncreix
     FROM ctaseguro
    WHERE cesta = 17
      AND sseguro = psseguro;

   cadena := SUBSTR(t1 || ' ' || t2 || ' ' || ROUND(ncreix, 3) || ' ' || t3 || ' '
                    || ROUND(nmixta, 3),
                    1, 80);
   texto := cadena;
   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 104882;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_LITLINK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_LITLINK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_LITLINK" TO "PROGRAMADORESCSI";
