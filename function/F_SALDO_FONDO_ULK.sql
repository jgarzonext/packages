--------------------------------------------------------
--  DDL for Function F_SALDO_FONDO_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SALDO_FONDO_ULK" (
   psseguro NUMBER,
   pfondo NUMBER,
   pfvalor DATE,
   pfrescat DATE DEFAULT NULL)
   RETURN NUMBER AUTHID CURRENT_USER IS
   /***************************************************************************
       -- Bug 9031 - 31/03/2009 - RSC - Análisis adaptación productos indexados
       This function is deprecated.
   ****************************************************************************/
   xunidades      NUMBER;
   xfvaloracion   DATE;
   saldo          NUMBER;
   preciounidad   NUMBER;
   sumaunidad     NUMBER;
BEGIN
--gettimer.reset_timer;
   saldo := 0;

   BEGIN
      SELECT SUM(NVL(nunidad, 0))
        INTO sumaunidad
        FROM ctaseguro
       WHERE sseguro = psseguro
         AND fvalmov <= ultima_hora(pfvalor)
         AND cesta = pfondo;
   EXCEPTION
      WHEN OTHERS THEN
         sumaunidad := 0;
   END;

-- Bug 9031 - 31/03/2009 - RSC - Análisis adaptación productos indexados
-- Función deprecada. Comento este código por que la función no compila
-- al ya que se han eliminado campos de la tabla FONDOS (ccodhos)
/*
select max(fvalor)
into xfvaloracion
from tabvalces
where ccesta = (select ccodhos from fondos where ccodfon = pfondo)
and fvalor <= ultima_hora(nvl(pfrescat,pfvalor));
*/
   xfvaloracion := f_sysdate;

-- Fin Bug 9031
   BEGIN
      -- Bug 9031 - 31/03/2009 - RSC - Análisis adaptación productos indexados
      -- Bug 9031 - 31/03/2009 - RSC - Análisis adaptación productos indexados
      -- Función deprecada. Comento este código por que la función no compila
      -- al ya que se han eliminado campos de la tabla FONDOS (ccodhos)
      /*
      select iuniact
      into preciounidad
      from tabvalces
      where ccesta = (select ccodhos from fondos where ccodfon = pfondo)
      and fvalor BETWEEN primera_hora(xfvaloracion) AND ultima_hora(xfvaloracion);
      */
      preciounidad := 1;
   -- Fin Bug 9031
   EXCEPTION
      WHEN OTHERS THEN
         preciounidad := 0;
   END;

   saldo := sumaunidad * preciounidad;
--dbms_output.put_line('Seg='||to_char(psseguro)||', cesta='||to_char(pfondo)||' ('||to_char(gettimer.get_elapsed_time));
   RETURN saldo;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_SALDO_FONDO_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SALDO_FONDO_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SALDO_FONDO_ULK" TO "PROGRAMADORESCSI";
