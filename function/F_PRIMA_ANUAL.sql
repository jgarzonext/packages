--------------------------------------------------------
--  DDL for Function F_PRIMA_ANUAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PRIMA_ANUAL" (
   psproces IN NUMBER,
   pcempresa IN NUMBER,
   psseguro IN NUMBER)
   RETURN NUMBER IS
   xitotalr       NUMBER;
   xsproces       NUMBER;
   dummy          NUMBER;
   xnmovimi       NUMBER;
   nerror         NUMBER;
   nerror1        NUMBER;
BEGIN
   nerror1 := f_buscanmovimi(psseguro, 1, 1, xnmovimi);

   IF nerror1 = 0 THEN
      nerror := f_prevrecibo(1, 1, psproces, psseguro, NULL, xnmovimi, dummy, dummy, dummy,
                             dummy, dummy, dummy, dummy, dummy, dummy, dummy, dummy, dummy,
                             dummy, dummy, dummy, dummy, dummy, dummy, dummy, xitotalr);

      IF nerror = 0 THEN
         DELETE      detreciboscar
               WHERE sproces = psproces;

         -- BUG 18423 -  30/11/2011 - JMP - LCOL000 - Multimoneda
         DELETE      vdetreciboscar_monpol
               WHERE sproces = psproces;

         -- FIN BUG 18423 -  30/11/2011 - JMP - LCOL000 - Multimoneda
         DELETE      vdetreciboscar
               WHERE sproces = psproces;

         DELETE      reciboscar
               WHERE sproces = psproces;

         COMMIT;
      END IF;
   END IF;

   RETURN(xitotalr);
END f_prima_anual;

/

  GRANT EXECUTE ON "AXIS"."F_PRIMA_ANUAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PRIMA_ANUAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PRIMA_ANUAL" TO "PROGRAMADORESCSI";
