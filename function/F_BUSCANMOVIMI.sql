--------------------------------------------------------
--  DDL for Function F_BUSCANMOVIMI
--------------------------------------------------------

  CREATE OR REPLACE  FUNCTION F_BUSCANMOVIMI (
   psseguro IN NUMBER,
   pmodo IN NUMBER,
   tipo IN NUMBER,
   pnmovimi OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/****************************************************************************
   F_BUSCANMOVIMI : Nos da el número de movimiento nmovimi que elegimos
            mediante el tipo.
            pmodo == 0 -> 'No se utiliza'.
                                              Sin tener en cuenta aportaciones extr.
                  == 1 -> teniendo en cuenta aportac. extraord.
            tipo  == 1 -> último movimiento en vigor(con cambio de
                   de garantías)
                  == 2 -> último movimiento de propuesta o suplem.
                  == 3 -> 'No se utiliza'.
                                              anterior movimiento al último en vigor
      Los movimientos de regularizacion no se tienen en cuenta, solo
      como propuesta
      Si no existe el movimiento que pedimos, pnmovimi := null
    Si el último movimiento es de anulación de póliza con
         extorno, éste será el vigente aunque no le cuelguen garantías.
       El modo 0 y el tipo 3 no se utilizan
       1.0    02/09/2013  ECP       1. 0012244: Poliza 9127 Poliza emitida con errores
       2.0    29/05/2019  ECP       2. IAXIS-3592. Prodceso de terminación por no pago   
****************************************************************************/
   propuesta      BOOLEAN;
   ult_movim      NUMBER;
   mov            NUMBER;
   movimiento     NUMBER;
   num_err        NUMBER;
   movimi         NUMBER;
   motivo         NUMBER;
   movimi_vigor   NUMBER;
   movi           NUMBER;

------------------------------------------------------------------------------
-- Definimos una funcion que nos calcula el movimiento anterior
-- (con garantias) a un movimiento determinado
------------------------------------------------------------------------------
   FUNCTION f_movimi(psseguro IN NUMBER, mov IN NUMBER, ultimo_mov OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT NVL(MAX(nmovimi), 0)
        INTO ultimo_mov
        FROM garanseg
       WHERE sseguro = psseguro
         AND nmovimi < mov;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 103500;
   END;

------------------------------------------------------------------------------
-- Definimos una funcion que nos dice si un movimiento es de regularizacion
------------------------------------------------------------------------------
   FUNCTION f_es_regularizacion(psseguro IN NUMBER, movimi IN NUMBER)
      RETURN BOOLEAN IS
      tipmov         NUMBER;
   BEGIN
      SELECT cmovseg
        INTO tipmov
        FROM movseguro
       WHERE sseguro = psseguro
         AND nmovimi = movimi;

      IF tipmov = 6 THEN   -- si es de regularizacion
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN FALSE;
   END;
------------------------------------------------------------------------------
--                ========= CUERPO DE LA FUNCION ====================
------------------------------------------------------------------------------
BEGIN
   IF pmodo = 1 THEN   -- teniendo en cuenta aport. extraord.
                       -- Miramos si tiene alguna propuesta
      BEGIN
         SELECT a.nmovimi
           INTO mov
           FROM movseguro a
          WHERE a.sseguro = psseguro
            AND a.femisio IS NULL
            -- Ini 12244 --ECP-- 21/04/2014
            AND a.fanulac IS NULL
                               -- Fin 12244 --ECP-- 21/04/2014
                               --Ini IAXIS-3592 -- ECP -- 29/05/2019
            AND a.nmovimi = (select max(b.nmovimi) from movseguro b where b.sseguro = a.sseguro)
         --Fin IAXIS-3592 -- ECP -- 29/05/2019
         ;

         propuesta := TRUE;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            propuesta := FALSE;
      END;

      IF propuesta = FALSE THEN   -- si el último mov. no es de propuesta
         BEGIN
            SELECT DISTINCT (nmovimi)
                       INTO ult_movim
                       FROM garanseg
                      WHERE sseguro = psseguro
                        AND ffinefe IS NULL;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104514;   --este seguro no tiene garantias con fecha final a null
         END;
      ELSE
         -- Buscamos el anterior al de la propuesta
         num_err := f_movimi(psseguro, mov, ult_movim);
      END IF;

      IF tipo = 1 THEN   --ult. movim. en vigor
         pnmovimi := NULL;
         movimi := ult_movim;

         WHILE pnmovimi IS NULL LOOP
            IF f_es_regularizacion(psseguro, movimi) = TRUE THEN
               num_err := f_movimi(psseguro, movimi, movimi);
               pnmovimi := NULL;
            ELSE
               pnmovimi := movimi;
            END IF;
         END LOOP;
      ELSIF tipo = 2 THEN   -- ult. movim. de propuesta
         pnmovimi := mov;
      ELSIF tipo = 3 THEN   -- anterior al último en vigor
-- Nadie llama a la función con este parámetro.
         RETURN 101901;
      END IF;
   ELSIF pmodo = 0 THEN   --sin tener en cuenta aport. extraordin.
                          --Miramos si tiene alguna propuesta
-- Nadie llama a la función con este parámetro.
      RETURN 101901;
   END IF;

   RETURN 0;
END;

/