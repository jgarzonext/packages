--------------------------------------------------------
--  DDL for Function F_SALDO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SALDO" (psseguro IN NUMBER, pfecha IN DATE, psaldo IN OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***************************************************************************
   F_SALDO: Calcula el saldo de la cuenta seguro en una fecha
             determinada.
   ALLIBCTR.
   Modificació: Se cambia el cursor principal, porque han cambiado las
                fechas del movimiento de saldo.
****************************************************************************/
   saldo_ant      ctaseguro.imovimi%TYPE;   --    saldo_ant      NUMBER(14, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   saldo_actual   ctaseguro.imovimi%TYPE;   --NUMBER(14, 2);
   imp_movimi     ctaseguro.imovimi%TYPE;   ---NUMBER(13, 2);
   codi_movimi    ctaseguro.cmovimi%TYPE;   --NUMBER(2);
   num_lin        ctaseguro.nnumlin%TYPE;   --    num_lin        NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---

   CURSOR c_saldo IS
      SELECT cmovimi, imovimi
        FROM ctaseguro
       WHERE sseguro = psseguro
         AND fcontab > (SELECT NVL(MAX(fcontab), TO_DATE('1-1-1900', 'dd/mm/yyyy'))
                          FROM ctaseguro
                         WHERE sseguro = psseguro
                           AND cmovanu <> 1   -- 1 = Anulado
                           AND nnumlin = NVL(num_lin, 0))
         AND fcontab <= pfecha
         AND cmovanu <> 1;   -- 1 = Anulado
BEGIN
-------Calculamos el saldo actual----------------------------------------
   BEGIN
      SELECT imovimi, nnumlin
        INTO saldo_ant, num_lin
        FROM ctaseguro
       WHERE sseguro = psseguro
         AND(cmovimi = 0
             AND cmovanu <> 1   -- 1 = Anulado
             AND fcontab = (SELECT MAX(fcontab)
                              FROM ctaseguro
                             WHERE sseguro = psseguro
                               AND cmovimi = 0
                               AND cmovanu <> 1   -- 1 = Anulado
                               AND fcontab < pfecha));
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   saldo_actual := NVL(saldo_ant, 0);

   OPEN c_saldo;

   LOOP
      FETCH c_saldo
       INTO codi_movimi, imp_movimi;

      EXIT WHEN c_saldo%NOTFOUND;

      IF codi_movimi > 10 THEN
         imp_movimi := 0 - imp_movimi;
      ELSIF codi_movimi = 0 THEN
         imp_movimi := 0;
      END IF;

      saldo_actual := saldo_actual + imp_movimi;
   END LOOP;

   CLOSE c_saldo;

   psaldo := saldo_actual;
   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      -- BUG 21546_108724 - 04/02/2012 - JLTS - Cierre de los cursores abiertos
      IF c_saldo%ISOPEN THEN
         CLOSE c_saldo;
      END IF;

      RETURN 102556;
END "F_SALDO";

/

  GRANT EXECUTE ON "AXIS"."F_SALDO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SALDO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SALDO" TO "PROGRAMADORESCSI";
