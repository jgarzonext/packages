--------------------------------------------------------
--  DDL for Function F_REDIST_PERMITE_SPL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_REDIST_PERMITE_SPL" (psseguro IN NUMBER)
   RETURN NUMBER IS
   /******************************************************************************
      NOMBRE:       f_redist_permite_spl
      PROPÓSITO:    Proteger la ejecución de un suplemento de modificación de perfil
                          de inversión en caso de existir recibos en gestión de cobro o lineas
                          pendientes de asignar sus participaciones.
      REVISIONES:

      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
       1.0       10/01/2008  RSC              1. Creación de función
       2.0       27/04/2009  RSC              2. Suplemento de cambio de forma de pago diferido.
   ******************************************************************************/
   vconta         NUMBER;

   -- Bug 9905 - 27/04/2009 - RSC - Suplemento de cambio de forma de pago diferido
   -- Join con vdetrecibos
   CURSOR cur_recibos IS
      SELECT r.nrecibo
        FROM recibos r, vdetrecibos v
       WHERE sseguro = psseguro
         AND r.nrecibo = v.nrecibo
         AND v.itotalr <> 0;

   vcsituac       NUMBER;
BEGIN
   SELECT CASE
             WHEN contador > 0 THEN 180704   -- Existeixen lineas pendents d'assignar participacions. Redistribució no permessa.
             ELSE 0
          END conta
     INTO vconta
     FROM (SELECT COUNT(*) contador
             FROM ctaseguro
            WHERE sseguro = psseguro
              AND cesta IS NOT NULL
              AND nunidad IS NULL);

   IF vconta <> 0 THEN
      RETURN(vconta);
   ELSE
      FOR regs IN cur_recibos LOOP
         vcsituac := f_cestrec_mv(regs.nrecibo, 2);   -- Esto lo he cogido de tfcon006 (campo nrecibo.csituac)

         IF vcsituac = 3 THEN   -- Gestión de cobro
            RETURN 180705;
         END IF;
      END LOOP;
   END IF;

   RETURN 0;
END f_redist_permite_spl;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_REDIST_PERMITE_SPL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_REDIST_PERMITE_SPL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_REDIST_PERMITE_SPL" TO "PROGRAMADORESCSI";
