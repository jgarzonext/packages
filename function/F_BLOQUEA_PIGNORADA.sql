--------------------------------------------------------
--  DDL for Function F_BLOQUEA_PIGNORADA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_BLOQUEA_PIGNORADA" (psseguro IN NUMBER, pfvalmov IN DATE)
   RETURN NUMBER AUTHID CURRENT_USER IS
/******************************************************************************
Función que nos indica si una póliza está anulada, o pignorada a una fecha
 0 .- va a ser que no
 1 .- bloqueada (262)
 2 .- pignorada (261)
 Ver Fecha Autor Descripción
 --------- ---------- -------- ------------------------------------
 1.0 19/04/2010 AVT 1. 0014188: CEM800 - consulta pignoració/bloqueig
******************************************************************************/
   fecha_bloqueo  DATE;
   fecha_desbloqueo DATE;
   fecha_pigno    DATE;
   fecha_despigno DATE;
   valor          NUMBER;
   num_bloqueo    NUMBER;
   xcmotmov       NUMBER;
   mov_bloqueo    NUMBER;   -- 14188 AVT 19-04-2010
   mov_desbloqueo NUMBER;   -- 14188 AVT 19-04-2010
BEGIN
   fecha_bloqueo := NULL;
   fecha_desbloqueo := NULL;
   mov_bloqueo := 0;
   mov_desbloqueo := 0;

   --------Control que la póliza está bloqueada
   SELECT MAX(finicio), MAX(nmovimi)
     INTO fecha_bloqueo, mov_bloqueo
     FROM bloqueoseg
    WHERE bloqueoseg.sseguro = psseguro
      AND finicio <= pfvalmov
      AND ffinal IS NULL
      AND cmotmov IN(262, 261);

   --
   IF fecha_bloqueo IS NOT NULL THEN
      SELECT MAX(nbloqueo)
        INTO num_bloqueo
        FROM bloqueoseg
       WHERE bloqueoseg.sseguro = psseguro
         AND finicio = fecha_bloqueo
         AND ffinal IS NULL
         AND cmotmov IN(262, 261);

      SELECT b.cmotmov
        INTO xcmotmov
        FROM bloqueoseg b
       WHERE b.sseguro = psseguro
         AND nbloqueo = num_bloqueo
         AND ffinal IS NULL
         AND cmotmov IN(262, 261);

      IF xcmotmov = 262 THEN
         --{En caso de pinoracion ,miramos si esta despigno...}
         SELECT MAX(finicio), MAX(nmovimi)
           INTO fecha_desbloqueo, mov_desbloqueo
           FROM bloqueoseg
          WHERE bloqueoseg.sseguro = psseguro
            AND finicio <= pfvalmov
            --AND nbloqueo = num_bloqueo -- 14188 AVT 19-04-2010
            AND cmotmov = 264;
      ELSIF xcmotmov = 261 THEN
         --{En el caso de bloqueo, miramos si esta desbloqueada...}
         SELECT MAX(finicio), MAX(nmovimi)
           INTO fecha_desbloqueo, mov_desbloqueo
           FROM bloqueoseg
          WHERE bloqueoseg.sseguro = psseguro
            AND finicio <= pfvalmov
            AND ffinal IS NULL
            AND nbloqueo = num_bloqueo   -- 14188 AVT 19-04-2010
            AND cmotmov = 263;
      END IF;
   END IF;

   IF (fecha_bloqueo IS NOT NULL
       AND fecha_desbloqueo IS NULL)
      OR(fecha_bloqueo >= fecha_desbloqueo
         AND mov_bloqueo > mov_desbloqueo) THEN   -- 14188 AVT 19-04-2010
      IF xcmotmov = 262 THEN
         RETURN 1;   --{bloqueada}
      ELSE
         RETURN 2;   --{pignorada}
      END IF;
   END IF;

   RETURN 0;   --{va se que no}
END f_bloquea_pignorada;

/

  GRANT EXECUTE ON "AXIS"."F_BLOQUEA_PIGNORADA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_BLOQUEA_PIGNORADA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_BLOQUEA_PIGNORADA" TO "PROGRAMADORESCSI";
