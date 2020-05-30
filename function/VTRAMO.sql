--------------------------------------------------------
--  DDL for Function VTRAMO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."VTRAMO" (nsesion IN NUMBER, ntramo IN NUMBER, vbuscar IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
   valor          NUMBER;
   fecha          NUMBER;
   ftope          DATE;
BEGIN
   IF nsesion = -1 THEN
      ftope := f_sysdate;
   ELSE
      BEGIN
         -- I - JLB  - OPTIMIZACION
           -- SELECT valor
           --   INTO fecha
           --   FROM sgt_parms_transitorios
           --  WHERE sesion = nsesion
            --   AND parametro = 'FECEFE';
         fecha := pac_sgt.get(nsesion, 'FECEFE');
         -- F - JLB --
         ftope := TO_DATE(fecha, 'yyyymmdd');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            ftope := f_sysdate;
      END;
   END IF;

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

   RETURN 0;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN NULL;
   WHEN OTHERS THEN
      RETURN NULL;
END vtramo;

/

  GRANT EXECUTE ON "AXIS"."VTRAMO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."VTRAMO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."VTRAMO" TO "PROGRAMADORESCSI";
