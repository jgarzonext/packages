--------------------------------------------------------
--  DDL for Function F_REBNOIMPRIM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_REBNOIMPRIM" (
   pnrecibo IN NUMBER,
   pfmovini IN DATE,
   pcimprim OUT NUMBER,
   pcestaux IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
   xcimprim       NUMBER;
   xsmovagr       NUMBER := 0;
   xnliqmen       NUMBER;
   xnliqlin       NUMBER;
   xcdelega       NUMBER;
   xitotalr       NUMBER;
   xitotpri       NUMBER;
   error          NUMBER;
-- BUG 0040003 - FAL - 25/01/2016
   vctiprec       recibos.ctiprec%TYPE;
   v_estrec       movrecibo.cestrec%TYPE;
--
-- ALLIBADM. Si importe = 0, recibo no imprimible y cobrado.
--
-- Retorna (como parámetro) = pcimprim (0 - No imprimible, 1 - Imprimible)
--
BEGIN
   BEGIN
      SELECT itotalr, itotpri
        INTO xitotalr, xitotpri
        FROM vdetrecibos
       WHERE nrecibo = pnrecibo;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 103936;   -- Rebut no trobat a VDETRECIBOS
      WHEN OTHERS THEN
         RETURN 103920;   -- Error al llegir de VDETRECIBOS
   END;

   IF xitotpri = 0 THEN   -- Prima neta cero
      BEGIN
         UPDATE recibos
            SET cestimp = 0   -- No imprimible
          WHERE nrecibo = pnrecibo;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 102358;   -- Error al modificar RECIBOS
      END;

      IF xitotalr = 0
         AND NVL(pcestaux, 0) = 0 THEN   -- Si total recibo 0 lo cobramos
         BEGIN
            SELECT cdelega
              INTO xcdelega
              FROM recibos
             WHERE nrecibo = pnrecibo;
         EXCEPTION
            WHEN OTHERS THEN
               xcdelega := NULL;
         END;

         -- BUG 0040003 - FAL - 25/01/2016
         BEGIN
            SELECT ctiprec
              INTO vctiprec
              FROM recibos
             WHERE nrecibo = pnrecibo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 101902;   -- Rebut no trobat a la taula RECIBOS
            WHEN OTHERS THEN
               RETURN 102367;   -- Error al llegir dades de la taula RECIBOS
         END;

         v_estrec := NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                       'ESTREC_IMPORTE_CERO'),
                         1);

         IF vctiprec = 5   -- Comisiones s/intereses
            OR v_estrec = 1 THEN
            error := f_movrecibo(pnrecibo, 1, NULL, NULL, xsmovagr, xnliqmen, xnliqlin,
                                 pfmovini, NULL, xcdelega, NULL, NULL);
         ELSE
            error := f_movrecibo(pnrecibo, v_estrec, NULL, NULL, xsmovagr, xnliqmen, xnliqlin,
                                 pfmovini, NULL, xcdelega, NULL, NULL);
         END IF;

         IF error <> 0 THEN
            RETURN error;
         END IF;
      END IF;

      pcimprim := 0;   -- No imprimible
   ELSE
      pcimprim := 1;   -- Imprimible
   END IF;

   RETURN 0;
END;

/

  GRANT EXECUTE ON "AXIS"."F_REBNOIMPRIM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_REBNOIMPRIM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_REBNOIMPRIM" TO "PROGRAMADORESCSI";
