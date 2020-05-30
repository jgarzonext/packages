--------------------------------------------------------
--  DDL for Function F_CONTADOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CONTADOR" (tipo IN VARCHAR2, pcaux IN NUMBER)
   RETURN NUMBER IS
   /***********************************************************************
         F_CONTADOR: Nuevo valor del contador.
         Tipo  -> '01': siniestro
            -> '02': poliza
            -> '03': recibos
            -> '04': recibos pruebas
         Retornem el nº de rebut concatenat amb l'empresa (pcaux). Pcaux serà el
         codi d'empresa pels rebuts però el codi del ram per els altres
         Comptador '04' cíclic. Es bloqueja la taula CONTADORES.

         REVISIONS:

         Ver        Fecha        Autor   Descripción
         ---------  ----------  ------- ----------------------------------------
         1.0        ...         xxx
         2.0        02/10/2009  NMM     11323: APR - numero de polizas erróneos.
         3.0        16/12/2010  JMP     17008: JMP - Sustitución de F_CONTADOR por PAC_PR0PIO.F_CONTADOR2
         4.0        29/11/2016  OGQ     CONF : OGQ - Se adiciona condicion para crear consecutivos de productos.

         -- BUG 17008 - 16/12/2010 - JMP - Llamar a PAC_PROPIO.F_CONTADOR2 para la generación del nº de póliza
         La llamada a F_CONTADOR se debe ir sustituyendo progresivamente por PAC_PROPIO.F_CONTADOR2.
         De momento se sustituyen únicamente las llamadas de tipo '02' (póliza).
         Para las instalaciones que no tengan implementada la PAC_PROPIO_XXX.F_CONTADOR2, se seguirá llamando a
         F_CONTADOR.
   ***********************************************************************/
   w_contador     NUMBER;
   v_long         NUMBER;
   -- 11323: APR - numero de polizas erróneos.
   w_cagrupa      NUMBER;
   w_conta_apra   NUMBER;
   w_tipo         VARCHAR2(2) := tipo;

   CURSOR c_contador IS
      SELECT     DECODE(w_tipo,
                        '01', DECODE(v_long, 2,(pcaux * 1000000), 3,(pcaux * 100000),4,(pcaux * 10000),5,(pcaux * 10000)) + ncontad,--se adiciona la condicion 4
                        '02',(pcaux * 1000000) + ncontad,
                        '03',(pcaux * 10000000) + ncontad,
                        '04',(pcaux * 10000000) + ncontad,
                        ncontad),
                 cagrupa, ncontad
            FROM contadores
           WHERE ccontad = DECODE(w_tipo,
                                  '01', w_tipo || LPAD(TO_CHAR(pcaux), v_long, '0'),
                                  '02', w_tipo || LPAD(TO_CHAR(pcaux), v_long, '0'),
                                  '03', w_tipo || LPAD(TO_CHAR(pcaux), v_long, '0'),
                                  '04', w_tipo || LPAD(TO_CHAR(pcaux), v_long, '0'),
                                  w_tipo)
      FOR UPDATE;

   CURSOR c_contador2 IS
      SELECT     DECODE(v_long, 2,(pcaux * 1000000), 3,(pcaux * 100000)) + ncontad, cagrupa,
                 ncontad
            FROM contadores
           WHERE ccontad = DECODE(w_tipo,
                                  '05', w_tipo || LPAD(TO_CHAR(pcaux), v_long, '0'),
                                  '06', w_tipo || LPAD(TO_CHAR(pcaux), v_long, '0'),
                                  w_tipo)
      FOR UPDATE;
BEGIN
   v_long := LENGTH(pcaux);

   IF v_long <= 2 THEN
      v_long := 2;
   END IF;

   --26810:NSS:30/04/2013
   IF tipo IN('05', '06') THEN
      OPEN c_contador2;

      FETCH c_contador2
       INTO w_contador, w_cagrupa, w_conta_apra;

      IF w_contador IS NULL THEN
         w_tipo := '01';

         OPEN c_contador;

         FETCH c_contador
          INTO w_contador, w_cagrupa, w_conta_apra;
      END IF;
   ELSE
      OPEN c_contador;

      FETCH c_contador
       INTO w_contador, w_cagrupa, w_conta_apra;
   END IF;

------------------------------------------------------------
-- 11323.i.: APR - numero de polizas erróneos.
   IF w_cagrupa IS NULL THEN
      UPDATE contadores
         SET ncontad = ncontad + 1
       WHERE ccontad = DECODE(tipo,
                              '01', w_tipo || LPAD(TO_CHAR(pcaux), v_long, '0'),
                              '02', w_tipo || LPAD(TO_CHAR(pcaux), v_long, '0'),
                              '03', w_tipo || LPAD(TO_CHAR(pcaux), v_long, '0'),
                              '04', w_tipo || LPAD(TO_CHAR(pcaux), v_long, '0'),
                              '05', w_tipo || LPAD(TO_CHAR(pcaux), v_long, '0'),
                              '06', w_tipo || LPAD(TO_CHAR(pcaux), v_long, '0'),
                              tipo);
   ELSE
      UPDATE contadores
         SET ncontad = w_conta_apra + 1
       WHERE cagrupa = w_cagrupa;
   END IF;

-- 11323.f.: APR - numero de polizas erróneos.
------------------------------------------------------------
   IF c_contador2%ISOPEN THEN
      CLOSE c_contador2;
   END IF;

   IF c_contador%ISOPEN THEN
      CLOSE c_contador;
   END IF;

   RETURN(w_contador);
--
EXCEPTION
   WHEN OTHERS THEN
      -- BUG 21546_108724 - 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
      IF c_contador%ISOPEN THEN
         CLOSE c_contador;
      END IF;

      IF c_contador2%ISOPEN THEN
         CLOSE c_contador2;
      END IF;

      RETURN(0);
--
END f_contador;

/

  GRANT EXECUTE ON "AXIS"."F_CONTADOR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CONTADOR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CONTADOR" TO "PROGRAMADORESCSI";
