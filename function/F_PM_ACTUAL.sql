--------------------------------------------------------
--  DDL for Function F_PM_ACTUAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PM_ACTUAL" (psseguro IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
--(sesion IN NUMBER, psseguro IN NUMBER,
--  f_ini IN DATE, f_final IN DATE, f_pm_anterior IN DATE, pfecha IN DATE, porigen IN NUMBER,
--  pcapini IN NUMBER )

   /**********************************************************************
    15/12/2008
    Función que extrae la suma de los moviminentos realizado durante un
    intervalo de tiempo en CTASEGUROS + El saldo de la provisión
    Todo a fecha de hoy
    para ser utilizado desde el GFI
   ***********************************************************************/
   w_sum          NUMBER := 0;
   aux_nnumlin    NUMBER;
   aux_fanterior  DATE;
   aux_sseguro    NUMBER := psseguro;
   aux_femisio    DATE;
   aux_fefecto    DATE;
   w_provmat      NUMBER;
   v_ret          NUMBER;   -- BUG24718:DRA:02/01/2013
BEGIN
   BEGIN
      SELECT femisio, fefecto
        INTO aux_femisio, aux_fefecto
        FROM seguros
       WHERE sseguro = psseguro;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'ff_sum_mov_ctaseguro', 3,
                     'OTHERS parametros =' || psseguro, SQLERRM);
         RETURN 0;
   END;

   IF aux_femisio IS NULL THEN   -- Es tracta d'una alta
      RETURN 0;   --pcapini;
   END IF;

   -- 4893 CPM 29/02/2008: Comprobamos que la fecha del saldo es diferente que la
   --  fecha efecto, para evitar problemas con la formulación para los últimos días
   --  del mes.
   -- 5095 CPM 01/04/08: Controlamos las inicializaciones de variables.
   SELECT NVL(MAX(nnumlin), 0)   --               ,imovimi   ####### En este mov está la PM ####
     INTO aux_nnumlin
     FROM ctaseguro
    WHERE sseguro = aux_sseguro
      --AND fvalmov = f_pm_anterior
      --AND fvalmov > nvl(aux_fefecto, f_pm_anterior-1)        --¿Siempre habrá fecha de emisión?
      AND fvalmov = (SELECT MAX(fvalmov)
                       FROM ctaseguro
                      WHERE sseguro = aux_sseguro
                        AND cmovimi = 0
                        AND fvalmov >= aux_fefecto)
      AND cmovimi = 0;   --Indica Provisión Matemática (PM)

   BEGIN
      SELECT NVL(imovimi, 0), ffecmov   --fvalmov
        INTO w_provmat, aux_fanterior
        FROM ctaseguro
       WHERE sseguro = aux_sseguro
         AND nnumlin = aux_nnumlin;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         w_provmat := 0;
   END;

   IF aux_nnumlin = 0 THEN
      --aux_fanterior := f_pm_anterior - 1;
      aux_fanterior := aux_fefecto - 1;   --Ponemos com fecha anterior una antes de la de efecto ya que no hay movimiento
   --ELSE
   --   aux_fanterior := f_pm_anterior;
   END IF;

   SELECT SUM(DECODE(cmovimi,   --1, 0,   --IMOVIMI,  -- No tenim en compte la Aport. Extr.
                     1, imovimi,
                     2, imovimi,
                     4, imovimi,
                     8, imovimi,
                     9, imovimi,
                     10, imovimi,
                     -imovimi))
     INTO w_sum
     FROM ctaseguro
    WHERE sseguro = aux_sseguro
      AND cmovimi IN(1, 2, 4,   --1,2,4 APORTACIONS
                             8,   -- Traspaso de entrada
                               9,   --Part. Benef.
                                 33, 34, 27, 51,   --Rescates
                                                47,   -- traspasos de salida
                                                   53,   -- pago prestación
                                                      10   -- anulacion prestacion
                                                        )
      --AND ((TRUNC(FFECMOV) BETWEEN GREATEST(F_INI, aux_fanterior) AND F_FINAL
      AND((TRUNC(ffecmov) BETWEEN aux_fanterior AND f_sysdate
           --AND TRUNC(FCONTAB) <= F_SYSDATE --GREATEST(F_FINAL, pfecha)
           AND ffecmov > aux_fanterior
           AND(TRUNC(fcontab) <> aux_fanterior
               OR cmovimi = 2)
                              --4208 jdomingo 14/1/2008 evitar conflicte si fecha ultim cierre=fecha llença cartera
                              -- 4613 CPM 06/02/08: si tenim una aportació periódica, només mirem l'interval de dades
          )
          --OR (TRUNC(FCONTAB) BETWEEN aux_fanterior +1  AND F_FINAL
          OR(TRUNC(fcontab) BETWEEN aux_fanterior + 1 AND f_sysdate
             AND ffecmov <= aux_fanterior
             AND TRUNC(fcontab) <> aux_fanterior)
          OR(TRUNC(fcontab) = aux_fanterior
             AND ffecmov <= aux_fanterior
             AND nnumlin > aux_nnumlin
             --(JAS)10.10.2007 - Afegim la condició "imovimi < 0" perquè es tinguin també en compte els rebuts de prima periòdica
             --anul·lats el mateix dia que l'últim càlcul d'apunt de llibreta.
             AND(cmovimi <> 2
                 OR imovimi < 0)));

   --RETURN nvl(w_Sum,0);
   --
   -- BUG24718:DRA:02/01/2013:Inici: Si el resultat és negatiu tornem un 0
   v_ret := w_provmat + NVL(w_sum, 0);

   IF v_ret < 0 THEN
      v_ret := 0;
   END IF;

   RETURN v_ret;
-- BUG24718:DRA:02/01/2013:FI
EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'ff_sum_mov_ctaseguro', 1,
                  'OTHERS parametros=' || psseguro, SQLERRM);
      RETURN 0;
END;

/

  GRANT EXECUTE ON "AXIS"."F_PM_ACTUAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PM_ACTUAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PM_ACTUAL" TO "PROGRAMADORESCSI";
