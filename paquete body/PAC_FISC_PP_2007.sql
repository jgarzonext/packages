--------------------------------------------------------
--  DDL for Package Body PAC_FISC_PP_2007
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_FISC_PP_2007" 
AS
   FUNCTION f_part_pres (
      psseguro       IN       NUMBER,
      pfcontig       IN       DATE,
      pnparant2007   OUT      NUMBER,
      pnparpos2006   OUT      NUMBER,
      pnparret       OUT      NUMBER,
      pcerror         OUT      NUMBER,
      plerror          OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      aux_ant2007   NUMBER;
      aux_pos2006   NUMBER;
      err_calc      EXCEPTION;
   BEGIN
      pnparant2007 := 0;
      pnparpos2006 := 0;
      pnparret := 0;

      FOR reg IN (SELECT c.cmovimi, c.fvalmov, nnumlin, ctipapor,
                         DECODE (GREATEST (c.cmovimi, 10),
                                 10, c.nparpla,
                                 -c.nparpla
                                ) "NPARPLA",
                         ( SELECT VDETRECIBOS.ITOTALR FROM VDETRECIBOS WHERE NRECIBO = C.NRECIBO ) IMPRECIBO
                    FROM ctaseguro c
                   WHERE c.sseguro = psseguro AND c.cmovimi NOT IN (0, 54))
      LOOP
         IF reg.fvalmov <= pfcontig
         THEN
            IF reg.fvalmov < fecha_ini_fisc OR reg.ctipapor='SP'
            THEN
               pnparant2007 := pnparant2007 + reg.nparpla;
            ELSIF reg.cmovimi IN (8, 47) AND reg.fvalmov >= fecha_ini_fisc
            THEN
               -- Traspasos
               -- ALBERT - Si hay error capturamos excepción y continuamos
               BEGIN
               SELECT t.nparant2007, t.nparpos2006
                 INTO aux_ant2007, aux_pos2006
                 FROM trasplainout t
                WHERE t.sseguro = psseguro
                  AND t.nnumlin = reg.nnumlin
                  AND t.cestado IN (3, 4);
               EXCEPTION
               WHEN OTHERS THEN
                   aux_ant2007 := 0;
                   aux_pos2006 := 0;
               END;


               -- ALBERT - En lugar de comparar con reg.nparpla, compare con el importe del recibo
               --IF (aux_ant2007 + aux_pos2006) != ABS (reg.nparpla)
               IF reg.cmovimi = 8 and (aux_ant2007 + aux_pos2006) != ABS (reg.imprecibo)
               THEN                 -- Comprovan que n. parti estigui correcta
                  RAISE err_calc;
               ELSE
                  IF reg.cmovimi = 8
                  THEN
                     -- Taspas d'entrada. Recogim les participacions corresponents.
                     pnparant2007 := pnparant2007 + aux_ant2007;
                     pnparpos2006 := pnparpos2006 + aux_pos2006;
                  ELSE
                     pnparant2007 := pnparant2007 - aux_ant2007;
                     pnparpos2006 := pnparpos2006 - aux_pos2006;
                  END IF;
               END IF;
            ELSIF reg.cmovimi = 53 AND reg.fvalmov >= fecha_ini_fisc
            THEN
               SELECT i.nparant2007, i.nparpos2006
                 INTO aux_ant2007, aux_pos2006
                FROM irpf_prestaciones i, ctaseguro c
               WHERE i.sidepag = c.sidepag
                 AND c.sseguro = psseguro
                 AND c.nnumlin = reg.nnumlin;
               IF aux_ant2007 IS NULL and aux_pos2006 IS NULL
               THEN
                 pnparant2007 := pnparant2007 + reg.nparpla;
               ELSE
                 pnparant2007 := pnparant2007 - aux_ant2007;
                 pnparpos2006 := pnparpos2006 - aux_pos2006;
               END IF;
            ELSE
               pnparpos2006 := pnparpos2006 + reg.nparpla;
            END IF;
         ELSE
            IF reg.ctipapor='SP' THEN
               pnparant2007 := pnparant2007 + reg.nparpla;
            ELSE
               pnparret := pnparret + reg.nparpla;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN err_calc
      THEN
         pnparpos2006 := NULL;
         pnparant2007 := NULL;
         pnparret := NULL;
         RETURN 500141;
      WHEN OTHERS
      THEN
         pnparpos2006 := NULL;
         pnparant2007 := NULL;
         pnparret := NULL;
         RETURN SQLCODE;
   END f_part_pres;

   FUNCTION f_part_tras (
      psseguro       IN       NUMBER,
      pnparant2007   OUT      NUMBER,
      pnparpos2006   OUT      NUMBER,
      pcerror         OUT      NUMBER,
      plerror         OUT       VARCHAR2
   )
      RETURN NUMBER
   IS
      aux_ant2007   NUMBER;
      aux_pos2006   NUMBER;
      aux_tippres    NUMBER;
      err_calc      EXCEPTION;
   BEGIN
      pnparant2007 := 0;
      pnparpos2006 := 0;

      FOR reg IN (SELECT c.cmovimi, c.fvalmov, nnumlin,ctipapor,
                         DECODE (GREATEST (c.cmovimi, 10),
                                 10, c.nparpla,
                                 -c.nparpla
                                ) "NPARPLA",
                         ( SELECT VDETRECIBOS.ITOTALR FROM VDETRECIBOS WHERE NRECIBO = C.NRECIBO ) IMPRECIBO
                    FROM ctaseguro c
                   WHERE c.sseguro = psseguro AND c.cmovimi NOT IN (0, 54))
      LOOP
         IF reg.fvalmov < fecha_ini_fisc OR reg.ctipapor='SP'
         THEN
            pnparant2007 := pnparant2007 + reg.nparpla;
         ELSIF reg.cmovimi IN (8, 47) AND reg.fvalmov >= fecha_ini_fisc
         THEN                                                     -- Traspasos
            -- ALBERT - Si hay error capturamos excepción y continuamos
            BEGIN
            SELECT t.nparant2007, t.nparpos2006
              INTO aux_ant2007, aux_pos2006
              FROM trasplainout t
             WHERE t.sseguro = psseguro
               AND t.nnumlin = reg.nnumlin
               AND t.cestado IN (3, 4);
            EXCEPTION
            WHEN OTHERS THEN
               aux_ant2007 := 0;
               aux_pos2006 := 0;
            END;


            -- ALBERT - En lugar de comparar con reg.nparpla, compare con el importe del recibo
            --IF (aux_ant2007 + aux_pos2006) != ABS (reg.nparpla)
            IF reg.cmovimi = 8 and (aux_ant2007 + aux_pos2006) != ABS (reg.imprecibo)
            THEN                    -- Comprovan que n. parti estigui correcta
               RAISE err_calc;
            ELSE
               IF reg.cmovimi = 8
               THEN
                  -- Taspas d'entrada. Recogim les participacions corresponents.
                  pnparant2007 := pnparant2007 + aux_ant2007;
                  pnparpos2006 := pnparpos2006 + aux_pos2006;
               ELSE
                  pnparant2007 := pnparant2007 - aux_ant2007;
                  pnparpos2006 := pnparpos2006 - aux_pos2006;
               END IF;
            END IF;
         ELSIF reg.cmovimi = 53 AND reg.fvalmov >= fecha_ini_fisc
         THEN
            SELECT i.nparant2007, i.nparpos2006, i.ctipcap
              INTO aux_ant2007, aux_pos2006, aux_tippres
              FROM irpf_prestaciones i, ctaseguro c
             WHERE i.sidepag = c.sidepag
               AND c.sseguro = psseguro
               AND c.nnumlin = reg.nnumlin;
            IF aux_tippres = 1  -- Capital
            THEN
               pnparant2007 := pnparant2007 - aux_ant2007;
               pnparpos2006 := pnparpos2006 - aux_pos2006;
            ELSE
                pnparpos2006 := pnparpos2006 + reg.nparpla;
            END IF;
         ELSE
            pnparpos2006 := pnparpos2006 + reg.nparpla;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN err_calc
      THEN
         pnparpos2006 := NULL;
         pnparant2007 := NULL;
         RETURN 500141;
      WHEN OTHERS
      THEN
         pnparpos2006 := NULL;
         pnparant2007 := NULL;
         RETURN SQLCODE;
   END f_part_tras;
END pac_fisc_pp_2007;

/

  GRANT EXECUTE ON "AXIS"."PAC_FISC_PP_2007" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FISC_PP_2007" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FISC_PP_2007" TO "PROGRAMADORESCSI";
