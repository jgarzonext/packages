--------------------------------------------------------
--  DDL for Function F_GETTRAMO1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_GETTRAMO1" (fecha IN DATE, ntramo IN NUMBER, vbuscar IN NUMBER)
   RETURN NUMBER IS
/************************************************************
  F_GETTRAMO1: Captura el valor de un tramo en la fecha
              determinado.
*************************************************************/
   valor          NUMBER;
   ftope          DATE;
BEGIN
   -- Bug 9794 - YIL - 21/04/2009 - Daba error porque el parámetro fecha ya es DATE
   ftope := fecha;   --TO_DATE(fecha, 'yyyymmdd');
   -- Bug 9794 - YIL - 21/04/2009 - Fin
   valor := NULL;

   FOR r IN (SELECT   orden, desde, NVL(hasta, desde) hasta, valor
                 FROM sgt_det_tramos
                WHERE tramo = (SELECT detalle_tramo
                                 FROM sgt_vigencias_tramos
                                WHERE tramo = ntramo
                                  AND fecha_efecto =
                                               (SELECT MAX(fecha_efecto)
                                                  FROM sgt_vigencias_tramos
                                                 WHERE tramo = ntramo
                                                   AND fecha_efecto <= ftope))
             ORDER BY orden) LOOP
      IF vbuscar BETWEEN r.desde AND r.hasta THEN
         RETURN r.valor;
      END IF;
   END LOOP;

   RETURN NULL;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN NULL;
   WHEN OTHERS THEN
      RETURN NULL;
END f_gettramo1;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_GETTRAMO1" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_GETTRAMO1" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_GETTRAMO1" TO "PROGRAMADORESCSI";
