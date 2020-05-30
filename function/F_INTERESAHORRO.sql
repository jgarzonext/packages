--------------------------------------------------------
--  DDL for Function F_INTERESAHORRO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_INTERESAHORRO" (
   psseguro IN NUMBER,
   pfecha IN DATE,
   pmoneda IN NUMBER,
   intereses OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/****************************************************************************
   F_INTERESAHORRO : Calcula los intereses que corresponden a una cuenta de
            ahorro hasta una determinada fecha.
            Actualiza los registros de CTASEGURO con ccalint = 1.
   ALLIBCTR.

      Se graba un recibo con los intereses que se queda el agente
          como comisión

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/12/2011  JMP              1. 0018423: LCOL000 - Multimoneda
   2.0        20/12/2011  JMF              2. 0020480: LCOL_C001 Ajuste de la retención en la función de cálculo
*****************************************************************************/
   CURSOR c_regctaseg IS
      SELECT   sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi, imovim2,
               nrecibo, ccalint, cmovanu, nsinies
          FROM ctaseguro
         WHERE sseguro = psseguro
           AND ccalint = 0
           AND fvalmov <= pfecha
      ORDER BY fcontab;

   regcta         c_regctaseg%ROWTYPE;
   wcramo         NUMBER;
   wcmodali       NUMBER;
   wcdelega       NUMBER;
   wctipseg       NUMBER;
   wccolect       NUMBER;
   pint_total     NUMBER;
   pdifdata       NUMBER;
   pintere        NUMBER;
   num_err        NUMBER;
   texto          VARCHAR2(100);
   max_numlin     NUMBER;
   wfcaranu       DATE;
   wnmovimi       NUMBER;
   wnrecibo       NUMBER;
   interes_ini    NUMBER := 0;
   wliqmen        NUMBER;
   wliqlin        NUMBER;
   wsmovagr       NUMBER;
   xccomisi       NUMBER;
   xcretenc       NUMBER;
   v_cempres      seguros.cempres%TYPE;
BEGIN
   -----Buscamos todos los registros de CTASEGURO de
   -----esta póliza que no hayan calculado intereses
   BEGIN
      SELECT cramo, cmodali, ctipseg, ccolect, fcaranu, cempres
        INTO wcramo, wcmodali, wctipseg, wccolect, wfcaranu, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 100500;
   END;

   pint_total := 0;

   OPEN c_regctaseg;

   LOOP
      FETCH c_regctaseg
       INTO regcta;

      EXIT WHEN c_regctaseg%NOTFOUND;
      ---Cálculo de los intereses---------------------
      num_err := f_difdata(regcta.fvalmov, pfecha, 1, 3, pdifdata);
      ---Utilizamos la función de calcular intereses diarios---
      num_err := f_intdiari(wcramo, wcmodali, wctipseg, wccolect, pdifdata, regcta.imovimi,
                            pintere);

      IF num_err <> 0 THEN
         CLOSE c_regctaseg;

         RETURN num_err;
      ELSE
         ---Miramos si el interes calculado tiene que ser negativo o positivo,
         --dependiendo del tipo de movimiento que sea
         IF regcta.cmovimi > 10 THEN
            pintere := 0 - pintere;
         END IF;

         pint_total := pint_total + pintere;

         BEGIN
            UPDATE ctaseguro
               SET ccalint = 1
             WHERE sseguro = psseguro
               AND fcontab = regcta.fcontab
               AND nnumlin = regcta.nnumlin;
         EXCEPTION
            WHEN OTHERS THEN
               CLOSE c_regctaseg;

               RETURN 102537;
         END;
      END IF;
   END LOOP;

   CLOSE c_regctaseg;

   interes_ini := f_round(pint_total, pmoneda);

   IF interes_ini <> 0 THEN
      --Miramos si el agente tiene comision para grabar el recibo
      num_err := f_pcomisi(psseguro, 2,   --pfecha,
                           f_sysdate,   -- BUG 0020480 - 19/12/2011 - JMF
                           xccomisi, xcretenc);

      IF xccomisi <> 0 THEN
         -- Se graba el recibo
         num_err := f_buscanmovimi(psseguro, 1, 1, wnmovimi);
         num_err := f_insrecibo(psseguro, NULL, pfecha, pfecha, pfecha + 1, 5, NULL, NULL,
                                NULL, 0, NULL, wnrecibo, 'R', NULL, NULL, wnmovimi, f_sysdate);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         num_err := f_detrecibo(NULL, psseguro, wnrecibo, NULL, 'I', 2, f_sysdate, pfecha,
                                pfecha + 1, wfcaranu, interes_ini, NULL, wnmovimi, 1,
                                intereses);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         BEGIN
            SELECT cdelega
              INTO wcdelega
              FROM recibos
             WHERE nrecibo = wnrecibo;
         EXCEPTION
            WHEN OTHERS THEN
               wcdelega := NULL;
         END;

         wsmovagr := 0;
         num_err := f_movrecibo(wnrecibo, 1, NULL, NULL, wsmovagr, wliqmen, wliqlin, f_sysdate,
                                NULL, wcdelega, NULL, NULL);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      ELSE   -- de ccomisi <> 0
         intereses := interes_ini;
      END IF;
   ELSE   -- si interes_ini = 0
      intereses := interes_ini;
   END IF;

   -- Grabamos el registro de intereses
   BEGIN
      SELECT MAX(nnumlin)
        INTO max_numlin
        FROM ctaseguro
       WHERE sseguro = psseguro;

      INSERT INTO ctaseguro
                  (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi, imovim2,
                   nrecibo, ccalint, cmovanu, nsinies)
           VALUES (psseguro, pfecha, NVL(max_numlin + 1, 0), pfecha, pfecha, 3, intereses, 0,
                   0, 1, 0, 0);

      -- BUG 18423 - 14/12/2011 - JMP - Multimoneda
      IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0) = 1 THEN
         num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro, pfecha,
                                                               NVL(max_numlin + 1, 0), pfecha);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;
   -- FIN BUG 18423 - 14/12/2011 - JMP - Multimoneda
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG 21546_108724 - 09/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF c_regctaseg%ISOPEN THEN
            CLOSE c_regctaseg;
         END IF;

         RETURN 102555;
   END;

   RETURN 0;
END;

/

  GRANT EXECUTE ON "AXIS"."F_INTERESAHORRO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_INTERESAHORRO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_INTERESAHORRO" TO "PROGRAMADORESCSI";
