--------------------------------------------------------
--  DDL for Function F_SALDO_PP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SALDO_PP" (
   psseguro IN NUMBER,
   fecha_hasta IN DATE,
   tipo IN NUMBER,
   paportante IN NUMBER DEFAULT NULL)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***************************************************************************
F_SALDO: Calcula el saldo de la cuenta seguro
      sI EL TIPO es 1 entonces devuelve el importe
      si es 0 devuelvo las participaciones
      pAPORTANTE : Nulo -- Total participaciones
              1 - Aportaciones del promotor
              2 - Aportaciones del partícipe y aportantes
              3 - Servicios pasados
              4 - Aportaciones del promotor SIN Servicios Pasados
              5 - Aportaciones OBLIGATORIAS del pariticipe.
              6 - Aportaciones VOLUNTARIAS del participe
****************************************************************************/
   divisa         NUMBER;
   fecha_saldo    DATE;
   saldo_ant      NUMBER(14, 2);
   una_parti      NUMBER(25, 9);
   psaldo         NUMBER(25, 6);
   pparti         NUMBER(25, 9);
   saldo_actual   NUMBER(25, 9);
   parti_ant      NUMBER(25, 6);
   parti_actual   NUMBER(16, 6);
   imp_movimi     ctaseguro.imovimi%TYPE;   --NUMBER(25, 6);
   codi_movimi    ctaseguro.cmovimi%TYPE;   --NUMBER(2);
   valor_parti    ctaseguro.nparpla%TYPE;   --NUMBER(25, 9);
   valor_parti_promo ctaseguro.nparpla%TYPE;   -- NUMBER(25, 9);
   valor_parti_partici ctaseguro.nparpla%TYPE;   -- NUMBER(25, 9);
   valor_parti_sp ctaseguro.nparpla%TYPE;   -- NUMBER(25, 9);
   pnnumlin       ctaseguro.nnumlin%TYPE;--NUMBER(8);
   permin         NUMBER;
   promotor       NUMBER;
   tipoapor       VARCHAR2(2);
   fcalculo       DATE;
-- INI - Toni
   valor_parti_promo_sin_sp NUMBER(25, 9);
   valor_parti_partici_obl NUMBER(25, 9);
   valor_parti_partici_vol NUMBER(25, 9);

-- FIN - Toni
   CURSOR c_saldo IS
      SELECT   cmovimi, imovimi, nparpla, nnumlin, spermin, ctipapor
          FROM ctaseguro
         WHERE sseguro = psseguro
           AND cmovimi NOT IN(0, 54)
-- MSR
           AND fvalmov < TRUNC(fecha_hasta) + 1   -- fvalmov inclou l'hora
      ORDER BY fvalmov, nnumlin;
BEGIN
-------Calculamos el saldo ----------------------------------------
   saldo_actual := 0;
   parti_actual := 0;

   --Bug10612 - 07/07/2009 - DCT (canviar vista personas)
   SELECT promotores.sperson
     INTO promotor
     FROM per_personas p, promotores, proplapen, seguros
    WHERE p.sperson = promotores.sperson
      AND promotores.ccodpla = proplapen.ccodpla
      AND seguros.sproduc = proplapen.sproduc
      AND seguros.sseguro = psseguro;

   /*SELECT PROMOTORES.SPERSON INTO promotor
   FROM PERSONAS, PROMOTORES, PROPLAPEN, SEGUROS
   WHERE PERSONAS.SPERSON = PROMOTORES.SPERSON
   AND PROMOTORES.CCODPLA = PROPLAPEN.CCODPLA
   AND SEGUROS.SPRODUC = PROPLAPEN.SPRODUC
   AND SEGUROS.SSEGURO = PSSEGURO;*/

   --FI Bug10612 - 07/07/2009 - DCT (canviar vista personas)
   OPEN c_saldo;

   LOOP
      FETCH c_saldo
       INTO codi_movimi, imp_movimi, valor_parti, pnnumlin, permin, tipoapor;

      EXIT WHEN c_saldo%NOTFOUND;

      --DBMS_OUTPUT.PUT_LINE ( 'ENTRAMOS' || VALOR_PARTI);
      IF codi_movimi > 10 THEN
         valor_parti := -valor_parti;

         IF permin = promotor THEN
-- MSR                 valor_parti_promo := NVL(valor_parti_promo,0) - NVL(valor_parti_promo,0);
            valor_parti_promo := 0;

            IF tipoapor != 'SP'
               OR tipoapor IS NULL THEN
               valor_parti_promo_sin_sp := NVL(valor_parti_promo_sin_sp, 0)
                                           + NVL(valor_parti, 0);
            END IF;
         ELSE
            valor_parti_partici := NVL(valor_parti_partici, 0) - NVL(valor_parti_partici, 0);

            IF tipoapor = 'O' THEN
               valor_parti_partici_obl := NVL(valor_parti_partici_obl, 0)
                                          + NVL(valor_parti, 0);
            ELSIF tipoapor IS NULL THEN
               valor_parti_partici_vol := NVL(valor_parti_partici_vol, 0)
                                          + NVL(valor_parti, 0);
            END IF;
         END IF;

         IF tipoapor = 'SP' THEN   --> Servicios pasados;
            valor_parti_sp := NVL(valor_parti_sp, 0) + NVL(valor_parti, 0);
         END IF;
      ELSIF codi_movimi <= 10 THEN
         IF permin = promotor THEN
            valor_parti_promo := NVL(valor_parti_promo, 0) + NVL(valor_parti, 0);

            IF tipoapor != 'SP'
               OR tipoapor IS NULL THEN
               valor_parti_promo_sin_sp := NVL(valor_parti_promo_sin_sp, 0)
                                           + NVL(valor_parti, 0);
            END IF;
         ELSE
            valor_parti_partici := NVL(valor_parti_partici, 0) + NVL(valor_parti, 0);

            IF tipoapor = 'O' THEN
               valor_parti_partici_obl := NVL(valor_parti_partici_obl, 0)
                                          + NVL(valor_parti, 0);
            END IF;

            IF NVL(tipoapor, 'X') != 'O' THEN
               valor_parti_partici_vol := NVL(valor_parti_partici_vol, 0)
                                          + NVL(valor_parti, 0);
            END IF;
         END IF;

         IF tipoapor = 'SP' THEN   --> Servicios pasados;
            valor_parti_sp := NVL(valor_parti_sp, 0) + NVL(valor_parti, 0);
         END IF;
      ELSIF codi_movimi = 0 THEN
         valor_parti := 0;
      END IF;

      parti_actual := parti_actual + valor_parti;
   END LOOP;

   CLOSE c_saldo;

   pparti := parti_actual;

   IF paportante = 1 THEN   -- > Aportaciones del promotor
      pparti := valor_parti_promo;
   ELSIF paportante = 2 THEN   --> Aportaciones del partícipe
      pparti := valor_parti_partici;
   ELSIF paportante = 3 THEN   --> Servicios pasados
      pparti := valor_parti_sp;
   ELSIF paportante = 4 THEN   -- > Aportaciones del promotor sin servicios pasados
      pparti := valor_parti_promo_sin_sp;
   ELSIF paportante = 5 THEN   -- > Aportaiones del participe obligatorias
      pparti := valor_parti_partici_obl;
   ELSIF paportante = 6 THEN   -- > Aportaciones del participe voluntarias
      pparti := valor_parti_partici_vol;
   END IF;

   IF tipo = 1 THEN
      --- *** Calculamos el importe del saldo
      -- MSR : Només calcular-ho si cal
      valor_parti := f_valor_participlan(fecha_hasta, psseguro, divisa);

      IF valor_parti = -1 THEN
         RETURN(-1);
      END IF;

      RETURN(ROUND(pparti * valor_parti, 2));
   ELSE
      RETURN(pparti);
   END IF;

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      -- BUG 21546_108724 - 04/02/2012 - JLTS - Cierre de posibles cursores abiertos
      IF c_saldo%ISOPEN THEN
         CLOSE c_saldo;
      END IF;

      --DBMS_OUTPUT.put_line('ERROR F_SALDO_PP: ' || SQLERRM);
      RETURN -1;
END;

/

  GRANT EXECUTE ON "AXIS"."F_SALDO_PP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SALDO_PP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SALDO_PP" TO "PROGRAMADORESCSI";
