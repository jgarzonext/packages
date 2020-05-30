--------------------------------------------------------
--  DDL for Package Body PK_TRASPASOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_TRASPASOS" AS
/******************************************************************************
   NOM:       pk_traspasos

   REVISIONS:
   Ver        Fecha       Autor  Descripción
   ---------  ----------  -----  ------------------------------------
   1.0                           Creación del package.
   2.0        03/07/2009  DCT    0010612: CRE - Error en la generació de pagaments automàtics.
                                 Canviar vista personas por tablas personas y añadir filtro de visión de agente
   3.0        11/04/2011   APD   3. 0018225: AGM704 - Realizar la modificación de precisión el cagente
   4.0        15/12/2011  JMP    4. 0018423: LCOL705 - Multimoneda
   5.0        08/10/2013  DEV, HRE 5. 0028462: LCOL_T001-Cambio dimension NPOLIZA, NCERTIF
******************************************************************************/
   FUNCTION f_saldo_pp(psseguro IN NUMBER, pfvalmov IN DATE, ptipus IN NUMBER)
      RETURN NUMBER IS
      ---
      tdivisa        NUMBER(2);
      psaldo         NUMBER;   /* NUMBER(25, 6);        */
      pparti         NUMBER;   /* NUMBER(25, 9);        */
      parti_actual   NUMBER;   /* NUMBER(16, 6);         */
      imp_movimi     NUMBER;   /* NUMBER(25, 6);          */
      codi_movimi    NUMBER(2);
      valor_parti    NUMBER;   /* NUMBER(25, 9);        */
      xnnumlin       ctaseguro.nnumlin%TYPE;   --trasplainout.fvalmov%TYPE;   --       xnnumlin       NUMBER(8); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---

      ---
      CURSOR c_saldo(psseguro IN NUMBER, pfvalmov IN DATE) IS
         SELECT   cmovimi, imovimi, nparpla, nnumlin
             FROM ctaseguro
            WHERE sseguro = psseguro
              AND fvalmov <= pfvalmov
         ORDER BY fvalmov, nnumlin;
   BEGIN
      parti_actual := 0;

      OPEN c_saldo(psseguro, pfvalmov);

      LOOP
         FETCH c_saldo
          INTO codi_movimi, imp_movimi, valor_parti, xnnumlin;

         EXIT WHEN c_saldo%NOTFOUND;

         IF codi_movimi > 10 THEN
            valor_parti := -valor_parti;
         ELSIF codi_movimi = 0 THEN
            valor_parti := 0;
         END IF;

         parti_actual := parti_actual + valor_parti;
      END LOOP;

      CLOSE c_saldo;

      pparti := parti_actual;
      ---Calculem l'import del saldo
      valor_parti := f_valor_participlan(pfvalmov, psseguro, tdivisa);

      IF valor_parti = -1 THEN
         RETURN -1;
      END IF;

      psaldo := ROUND(pparti * valor_parti, 2);

      ---
      IF ptipus = 1 THEN
         RETURN psaldo;
      ELSIF ptipus = 2 THEN
         RETURN pparti;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 07/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF c_saldo%ISOPEN THEN
            CLOSE c_saldo;
         END IF;

         RETURN -SQLCODE;
   END f_saldo_pp;

---
---
   FUNCTION f_in_partic(
      pstras IN NUMBER,
      pctiptras IN NUMBER,
      psseguro IN NUMBER,
      pfvalmov IN OUT DATE,
      pfefecto IN OUT DATE,
      pimovimi IN OUT NUMBER,
      ppartras IN OUT NUMBER,
      pintern IN NUMBER,
      psseguro_or IN NUMBER,
      pautomatic IN NUMBER DEFAULT 1,
      pporcdcons IN NUMBER,
      pporcdecon IN NUMBER)
      RETURN NUMBER IS
      ---
      num_err        NUMBER(8);
      xfantigi       trasplainout.fantigi%TYPE;   --       xfantigi       DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xfefecte       seguros.fefecto%TYPE;   --       xfefecte       DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      ximpanu        NUMBER;   /* NUMBER(25, 10);  */
      xaportacions   trasplainout.iimpanu%TYPE;   --       xaportacions   NUMBER(25, 10); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xmesaporta     NUMBER;   /* NUMBER(25, 10);  */
      xestado        trasplainout.cestado%TYPE;   --       xestado        NUMBER(1); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xnnumlin       trasplainout.nnumlin%TYPE;   --       xnnumlin       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xfcontab       DATE;
      xnrecibo       NUMBER;
      pstrasin       NUMBER(8);
      ximovimi       trasplainout.iimptemp%TYPE;   --       ximovimi       NUMBER(15, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xparpla        NUMBER;   /* NUMBER(25, 10);  */
      xivalora       NUMBER;   /* NUMBER(25, 10);  */
      tdiv           NUMBER(3);
      partis_incorporadas trasplainout.nparpla%TYPE;   --       partis_incorporadas NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_porcant2007  trasplainout.porcant2007%TYPE;   --       v_porcant2007  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_porcpos2006  trasplainout.porcpos2006%TYPE;   --       v_porcpos2006  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_nparant2007  trasplainout.nparant2007%TYPE;   --       v_nparant2007  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_nparpos2006  trasplainout.nparpos2006%TYPE;   --       v_nparpos2006  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      ---
      errorte        EXCEPTION;
      errorts        EXCEPTION;
   ---
   BEGIN
      --DBMS_OUTPUT.put_line('f_in_partic: ' || TO_CHAR(f_SYSDATE, 'hh24:mi:ss'));

      ---Comprovació paràmetres
      IF pfvalmov IS NULL THEN
         pfvalmov := TRUNC(f_sysdate);
      END IF;

      IF pfefecto IS NULL THEN
         pfefecto := TRUNC(f_sysdate);
      END IF;

      IF pintern = 1
         AND psseguro_or IS NULL THEN
         num_err := 107839;
         RAISE errorte;
      END IF;

      IF pintern = 0
         AND(pimovimi = 0
             OR pimovimi IS NULL) THEN
         num_err := 107839;
         RAISE errorte;
      END IF;

      IF pintern = 1
         AND(pimovimi = 0
             OR pimovimi IS NULL)
         AND(ppartras = 0
             OR ppartras IS NULL) THEN
         num_err := 107839;
         RAISE errorte;
      END IF;

      IF pintern = 1
         AND pautomatic = 1 THEN
         ---*** Si el traspàs es d'entrada cap a un altre pla de l'empresa
         ---*** hem de fer primer un traspàs de sortida
         ---Calculem l'import del traspàs de sortida
         IF pimovimi IS NOT NULL
            AND pimovimi <> 0 THEN
            ximovimi := pimovimi;
            xparpla := NULL;
         ELSIF ppartras IS NOT NULL
               AND ppartras <> 0 THEN
            ximovimi := NULL;
            xivalora := f_valor_participlan(pfvalmov, psseguro, tdiv);
            ximovimi := f_round(xivalora * ppartras, tdiv);
            xparpla := NULL;
         END IF;

         ---
         num_err := f_traspaso_inverso(1, pstras, psseguro_or, psseguro, ximovimi, xparpla,
                                       pctiptras, 2, pstrasin);

         IF num_err <> 0 THEN
            RAISE errorts;
         END IF;

         ----
         num_err := f_out_partic(pstrasin, pctiptras, psseguro_or, pfvalmov, pfefecto,
                                 ximovimi, xparpla, pintern, psseguro, 0, pporcdcons,
                                 pporcdecon);

         IF num_err <> 0 THEN
            RAISE errorts;
         END IF;

         pimovimi := ximovimi;
      --DBMS_OUTPUT.put_line('RETORN F_OUT_PARTIC: ' || pimovimi);
      END IF;

      num_err := f_in(pstras, psseguro, pfvalmov, pfefecto, pimovimi, xnnumlin, xfcontab,
                      xnrecibo);

      IF num_err <> 0 THEN
         RAISE errorte;
      END IF;

--    calcular les participaciones
      xivalora := f_valor_participlan(pfvalmov, psseguro, tdiv);
      v_porcant2007 := 100 - NVL(pporcdcons, 0);
      v_porcpos2006 := NVL(pporcdcons, 0);

      IF NVL(xivalora, 0) > 0 THEN
         partis_incorporadas := ROUND(pimovimi / xivalora, 6);

         IF v_porcant2007 > 0 THEN
            v_nparant2007 := ROUND(partis_incorporadas * v_porcant2007 / 100, 6);
         ELSE
            v_nparant2007 := 0;
         END IF;

         IF v_porcpos2006 > 0 THEN
            v_nparpos2006 := ROUND(partis_incorporadas * v_porcpos2006 / 100, 6);
         ELSE
            v_nparpos2006 := 0;
         END IF;
      END IF;

      -- *** Actualitzem traspàs d'entrada (només per traspassos totals)
      IF pintern = 1
         AND pctiptras = 1 THEN
         --DBMS_OUTPUT.put_line('PINTERN ');
         SELECT SUM(NVL(imovimi, 0))
           INTO xaportacions
           FROM ctaseguro
          WHERE ctaseguro.sseguro = psseguro_or
            AND ctaseguro.cmovimi IN(1, 2)
            AND ctaseguro.cmovanu NOT IN(1)
            AND TO_CHAR(fvalmov, 'YYYY') = TO_CHAR(pfvalmov, 'YYYY');

         SELECT SUM(NVL(iimpanu, 0))
           INTO xmesaporta
           FROM trasplainout
          WHERE trasplainout.sseguro = psseguro_or
            AND trasplainout.cinout = 1
            AND cestado IN(3, 4);

         --DBMS_OUTPUT.put_line('PINTERN2');
         xaportacions := NVL(xaportacions, 0) + NVL(xmesaporta, 0);

         /***********
         IF pctiptras = 0 THEN
            xaportacions := 0;
         END IF;
         ***************/
         SELECT fefecto
           INTO xfefecte
           FROM seguros
          WHERE sseguro = psseguro_or;

         DECLARE
            xmintras       DATE;
         BEGIN
            SELECT MIN(fantigi)
              INTO xmintras
              FROM trasplainout
             WHERE sseguro = psseguro_or
               AND cinout = 1
               AND fantigi IS NOT NULL
               AND cestado = 4;

            IF xmintras IS NULL
               OR NVL(TO_CHAR(xfantigi, 'YYYYMMDD'), '0') >=
                                                        NVL(TO_CHAR(xfefecte, 'YYYYMMDD'), '0') THEN
               xfantigi := xfefecte;
            ELSE
               xfantigi := xmintras;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               xfantigi := xfefecte;
         END;

         IF xfantigi IS NULL
            OR xaportacions IS NULL THEN
            xestado := 3;
         ELSE
            xestado := 4;
         END IF;

         UPDATE trasplainout
            SET fantigi = xfantigi,
                iimpanu = xaportacions,
                cestado = xestado,
                iimporte = pimovimi,
                nnumlin = xnnumlin,
                nparpla = partis_incorporadas,
                porcant2007 = v_porcant2007,
                porcpos2006 = v_porcpos2006,
                nparant2007 = v_nparant2007,
                nparpos2006 = v_nparpos2006
          WHERE stras = pstras;
      --DBMS_OUTPUT.put_line('PINTERN4');
      ELSIF pintern = 1
            AND pctiptras = 2 THEN
         UPDATE trasplainout
            SET cestado = 4,
                iimporte = pimovimi,
                nnumlin = xnnumlin,
                nparpla = partis_incorporadas,
                porcant2007 = v_porcant2007,
                porcpos2006 = v_porcpos2006,
                nparant2007 = v_nparant2007,
                nparpos2006 = v_nparpos2006
          WHERE stras = pstras;
      ELSE
         UPDATE trasplainout
            SET cestado = DECODE(iimpanu, NULL, 3, DECODE(fantigi, NULL, 3, 4)),
                iimporte = pimovimi,
                nnumlin = xnnumlin,
                nparpla = partis_incorporadas,
                porcant2007 = v_porcant2007,
                porcpos2006 = v_porcpos2006,
                nparant2007 = v_nparant2007,
                nparpos2006 = v_nparpos2006
          WHERE stras = pstras;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN errorte THEN
         --DBMS_OUTPUT.put_line('te ' || num_err);
         ROLLBACK;

         IF num_err = 1 THEN
            RETURN 140978;
         ELSE
            RETURN num_err;
         END IF;
      WHEN errorts THEN
         ROLLBACK;
         RETURN 151255;
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line(SQLERRM);
         ROLLBACK;
         RETURN 140978;
   END f_in_partic;

---
---
   FUNCTION f_out_partic(
      pstras IN NUMBER,
      pctiptras IN NUMBER,
      psseguro IN NUMBER,
      pfvalmov IN OUT DATE,
      pfefecto IN OUT DATE,
      pimovimi IN OUT NUMBER,
      ppartras IN OUT NUMBER,
      pintern IN NUMBER,
      psseguro_ds IN NUMBER,
      pautomatic IN NUMBER DEFAULT 1,
      pporcdcons IN NUMBER,
      pporcdecon IN NUMBER)
      RETURN NUMBER IS
      ---
      num_err        NUMBER;
      xnsinies       prestaplan.nsinies%TYPE;   --       xnsinies       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xsidepag       NUMBER;
      xnnumlin       trasplainout.nnumlin%TYPE;   --       xnnumlin       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xfcontab       DATE;
      ximovimi       trasplainout.iimporte%TYPE;   --       ximovimi       NUMBER(15, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xsaldo         NUMBER;   /*  NUMBER(15, 2);  */
      xpartras       NUMBER;   /*  NUMBER(25, 6);   */
      pspersdest     per_personas.sperson%TYPE;   --       pspersdest     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pspertipdestinat NUMBER(2);
      pstrasin       NUMBER(8);
      xepagsin       NUMBER(1);
      xfantigi       trasplainout.fantigi%TYPE := NULL;   --       xfantigi       DATE := NULL; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      ximpanu        NUMBER := 0;   /*  NUMBER(25, 10) := 0;   */
      xaportacions   trasplainout.iimpanu%TYPE := 0;   --       xaportacions   NUMBER(25, 10) := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xmesaporta     NUMBER := 0;   /* NUMBER(25, 10);  */
      ---
      errorts        EXCEPTION;
      errorte        EXCEPTION;
      vcagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;
   BEGIN
      --DBMS_OUTPUT.put_line('f_out_partic: ' || TO_CHAR(F_SYSDATE, 'hh24:mi:ss'));

      ---Comprovació paràmetres
      IF pfvalmov IS NULL THEN
         pfvalmov := TRUNC(f_sysdate);
      END IF;

      IF pfefecto IS NULL THEN
         pfefecto := TRUNC(f_sysdate);
      END IF;

      ximovimi := pimovimi;

      IF pctiptras = 2
         AND(ximovimi = 0
             OR ximovimi IS NULL)
         AND(ppartras = 0
             OR ppartras IS NULL) THEN
         num_err := 107839;
         RAISE errorts;
      ELSIF pctiptras = 1 THEN
         ppartras := f_saldo_pp(psseguro, pfvalmov, 2);

         IF ppartras = -1 THEN
            num_err := 109524;
            RAISE errorts;
         ELSIF ppartras < 0
               OR ppartras IS NULL THEN
            num_err := 1;
            RAISE errorts;
         END IF;

         ximovimi := 0;
      ELSIF pctiptras = 2 THEN
         IF ximovimi IS NOT NULL
            AND ximovimi > 0 THEN
            xsaldo := f_saldo_pp(psseguro, pfvalmov, 1);

            IF xsaldo < ximovimi THEN
               num_err := 109285;
               RAISE errorts;
            END IF;
         END IF;
      END IF;

      --Bug10612 - 03/07/2009 - DCT (Canviar vista personas por tablas personas y añadir filtro de visión de agente)

      ----Busquem codi de persona del destinatari.
      BEGIN
         SELECT p.sperson
           INTO pspersdest
           FROM per_personas p, planpensiones, fonpensiones, trasplainout
          WHERE fonpensiones.ccodfon = planpensiones.ccodfon
            AND p.sperson = fonpensiones.sperson
            AND planpensiones.ccodfon = fonpensiones.ccodfon
            AND planpensiones.ccodpla = trasplainout.ccodpla
            AND trasplainout.stras = pstras;
      /*SELECT personas.sperson
        INTO pspersdest
        FROM personas, planpensiones, fonpensiones, trasplainout
       WHERE fonpensiones.ccodfon = planpensiones.ccodfon
         AND personas.sperson = fonpensiones.sperson
         AND planpensiones.ccodfon = fonpensiones.ccodfon
         AND planpensiones.ccodpla = trasplainout.ccodpla
         AND trasplainout.stras = pstras;*/
      EXCEPTION
         WHEN OTHERS THEN
            pspersdest := NULL;
      END;

      --FI Bug10612 - 03/07/2009 - DCT (Canviar vista personas por tablas personas y añadir filtro de visión de agente)
      pspertipdestinat := 5;

      IF pintern = 0 THEN
         xepagsin := 2;
      ELSIF pintern = 1 THEN
         xepagsin := 1;
      END IF;

      num_err := f_out(pstras, pctiptras, psseguro, pfvalmov, pfefecto, ximovimi, ppartras,
                       xnnumlin, xfcontab, pspersdest, xepagsin);

      IF num_err <> 0 THEN
         RAISE errorts;
      END IF;

      SELECT LEAST(NVL(MIN(fantigi), '31/12/2999'), MIN(s.fefecto))
        INTO xfantigi
        FROM seguros s, trasplainout t
       WHERE s.sseguro = t.sseguro(+)
         AND s.sseguro = psseguro
         AND t.cinout(+) = 1;

      BEGIN
         SELECT SUM(NVL(imovimi, 0))
           INTO xaportacions
           FROM ctaseguro
          WHERE ctaseguro.sseguro = psseguro
            AND ctaseguro.cmovimi IN(1, 2)
            AND ctaseguro.cmovanu NOT IN(1)
            AND TO_CHAR(fvalmov, 'YYYY') = TO_CHAR(pfvalmov, 'YYYY');

         SELECT SUM(NVL(iimpanu, 0))
           INTO xmesaporta
           FROM trasplainout
          WHERE trasplainout.sseguro = psseguro
            AND trasplainout.cinout = 1
            AND cestado IN(3, 4);

         xaportacions := NVL(xaportacions, 0) + NVL(xmesaporta, 0);
      END;

      IF pintern = 1
         AND psseguro_ds IS NOT NULL THEN
         IF pautomatic = 1 THEN
            ---*** Si el traspàs es de sortida cap a un altre pla de l'empresa
            ---*** hem de crear un traspàs d'entrada
            --DBMS_OUTPUT.put_line('traspas invers');
            xpartras := 0;
            num_err := f_traspaso_inverso(1, pstras, psseguro_ds, psseguro, ximovimi,
                                          xpartras, pctiptras, 1, pstrasin);

            IF num_err <> 0 THEN
               RAISE errorte;
            END IF;

            --DBMS_OUTPUT.put_line('traspas invers: ' || pstrasin);
            --DBMS_OUTPUT.put_line('traspas invers: ' || ximovimi);
            --DBMS_OUTPUT.put_line('traspas invers: ' || xpartras);
            ----
            num_err := f_in_partic(pstrasin, pctiptras, psseguro_ds, pfvalmov, pfefecto,
                                   ximovimi, xpartras, pintern, psseguro, 0, pporcdcons,
                                   pporcdecon);

            IF num_err <> 0 THEN
               RAISE errorte;
            END IF;
         END IF;
      END IF;

      ---*** Actualizamos el traspaso
      BEGIN
         pimovimi := ximovimi;

         UPDATE trasplainout
            SET fantigi = xfantigi,
                iimpanu = xaportacions,
                cestado = 4,
                iimporte = ximovimi,
                nnumlin = xnnumlin
          WHERE stras = pstras;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 151254;
      END;

      RETURN num_err;
   EXCEPTION
      WHEN errorts THEN
         ROLLBACK;

         IF num_err = 1 THEN
            RETURN 140977;
         ELSE
            RETURN num_err;
         END IF;
      WHEN errorte THEN
         ROLLBACK;
         RETURN 151255;
      WHEN OTHERS THEN
         ROLLBACK;
         RETURN 140977;
   END f_out_partic;

---
---
   FUNCTION f_in_benef(
      pstras IN NUMBER,
      pctiptras IN NUMBER,
      pspersonben IN NUMBER,
      psseguro IN NUMBER,
      pfvalmov IN DATE,
      pfefecto IN DATE,
      pimovimi IN OUT NUMBER,
      ppartras IN OUT NUMBER,
      pintern IN NUMBER,
      psseguro_or IN NUMBER,
      pautomatic IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      ---
      xfvalmov       DATE;
      ximovimi       trasplainout.iimptemp%TYPE;   --       ximovimi       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xnnumlin       trasplainout.nnumlin%TYPE;   --       xnnumlin       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xfcontab       DATE;
      xnrecibo       NUMBER;
      xsaldo         NUMBER;
      xtepresta      NUMBER;
      xsprestaplan   NUMBER;
      bdefinir       BOOLEAN;
      bconfirmar     BOOLEAN;
      xprorat        NUMBER;
      num_err        NUMBER;
      pstrasin       NUMBER(8);
      psprestaplan   prestaplan.sprestaplan%TYPE;   --       psprestaplan   NUMBER(8); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      ---
      errorteb       EXCEPTION;
      errortsb       EXCEPTION;
   BEGIN
      ----Decidim com haurà de quedar la prestació definida.
      SELECT COUNT(1)
        INTO xtepresta
        FROM prestaplan
       WHERE sseguro = psseguro
         AND cestado IN(1, 2);

      bdefinir := TRUE;

      IF xtepresta = 0 THEN
         xsaldo := f_saldo_pp(psseguro, pfvalmov, 1);

         IF xsaldo = -1 THEN
            num_err := 1;
            RAISE errorteb;
         END IF;

         IF xsaldo = 0 THEN
            bconfirmar := TRUE;
         ELSE
            bconfirmar := FALSE;
         END IF;
      ELSIF xtepresta <> 0 THEN
         bconfirmar := FALSE;
      /**************
      SELECT COUNT(1)
      INTO xtepresta
      FROM BENEFPRESTAPLAN
      WHERE sperson = pspersonben
      AND CTIPCAP IN (2,3)
      AND sprestaplan IN
             (SELECT sprestaplan
              FROM PRESTAPLAN
              WHERE sseguro = psseguro
              AND cestado IN (1, 2);
      **********/
      END IF;

      ---
      ---
      IF bdefinir = TRUE THEN
         xfvalmov := pfvalmov;

         IF pintern = 1
            AND pautomatic = 1 THEN   -- es intern i automatic
            num_err := f_traspaso_inverso(2, pstras, psseguro, psseguro_or, NULL, ppartras,
                                          pctiptras, 2, pstrasin);

            IF num_err <> 0 THEN
               RAISE errortsb;
            END IF;

            num_err := f_out_benef(pstrasin, pctiptras, psprestaplan, pspersonben, psseguro_or,
                                   xfvalmov, xfvalmov, pimovimi, ppartras, pintern, psseguro,
                                   0);

            IF num_err <> 0 THEN
               RAISE errortsb;
            END IF;
         END IF;

         num_err := f_in(pstras, psseguro, xfvalmov, xfvalmov, pimovimi, xnnumlin, xfcontab,
                         xnrecibo);

         IF num_err <> 0 THEN
            num_err := 1;
            RAISE errorteb;
         END IF;

         UPDATE trasplainout
            SET cestado = 3
          WHERE stras = pstras;

         num_err := f_crear_presta(pstras, psseguro, pspersonben, pfvalmov, pfefecto,
                                   bconfirmar, xsprestaplan, xprorat);

         IF num_err <> 0 THEN
            num_err := 1;
            RAISE errorteb;
         END IF;

         UPDATE trasplainout
            SET cestado = 4,
                nnumlin = xnnumlin
          WHERE stras = pstras;
      END IF;
   EXCEPTION
      WHEN errorteb THEN
         RETURN num_err;
      WHEN errortsb THEN
         RETURN num_err;
      WHEN OTHERS THEN
         RETURN 1;
   END f_in_benef;

---
---
   FUNCTION f_out_benef(
      pstras IN NUMBER,
      pctiptras IN NUMBER,
      psprestaplan IN NUMBER,
      pspersonben IN NUMBER,
      psseguro IN NUMBER,
      pfvalmov IN DATE,
      pfefecto IN DATE,
      pimovimi IN OUT NUMBER,
      ppartras IN OUT NUMBER,
      pintern IN NUMBER,
      psseguro_ds IN NUMBER,
      pautomatic IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      ---
      ximovimi       trasplainout.iimptemp%TYPE;   --       ximovimi       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xnpar_per_pagar benefprestaplan.nparpla%TYPE;   --       xnpar_per_pagar NUMBER(25, 6); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xfvalmov       DATE;
      xnnumlin       trasplainout.nnumlin%TYPE;   --       xnnumlin       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xfcontab       DATE;
      xstrasin       NUMBER;
      num_err        NUMBER := 0;
      pspersdest     per_personas.sperson%TYPE;   --       pspersdest     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xnsinies       prestaplan.nsinies%TYPE;   --       xnsinies       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xprorat        NUMBER;
      pstrasin       NUMBER(8);
      xepagsin       NUMBER(1);
      errortsb       EXCEPTION;
      vcagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;
   BEGIN
      --DBMS_OUTPUT.put_line('Entrem f_out_benef: ' || TO_CHAR(F_SYSDATE, 'hh24:mi:ss'));
      BEGIN
         SELECT nsinies
           INTO xnsinies
           FROM prestaplan
          WHERE sprestaplan = psprestaplan;
      EXCEPTION
         WHEN OTHERS THEN
            --DBMS_OUTPUT.put_line(SQLERRM);
            NULL;
      END;

      DECLARE
         pnparpla       NUMBER;
         tdiv           NUMBER;
         vnparpla       NUMBER;
      BEGIN
         SELECT nparpla
           INTO xnpar_per_pagar
           FROM benefprestaplan
          WHERE sprestaplan = psprestaplan
            AND sperson = pspersonben;

         pnparpla := f_valor_participlan(pfvalmov, psseguro, tdiv);
         ximovimi := f_round(pnparpla * xnpar_per_pagar, tdiv);

         IF pnparpla = -1 THEN
            -----Revisar
            ximovimi := 0;
         ELSE
            ximovimi := f_round(pnparpla * xnpar_per_pagar, tdiv);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            --DBMS_OUTPUT.put_line(SQLERRM);
            NULL;
      END;

      ----l'import a traspassar ha de ser una funció que depengui de:
      ---1.import sol·licitat.
      ---2.participacions que queden per pagar.
      IF pctiptras = 1
         OR pimovimi >= ximovimi THEN
         xprorat := 1;
         pimovimi := ximovimi;
      ELSE
         xprorat := ROUND(pimovimi / ximovimi, 3);
         ximovimi := pimovimi;
      END IF;

      xfvalmov := pfvalmov;

      --Bug10612 - 03/07/2009 - DCT (Canviar vista personas por tablas personas y añadir filtro de visión de agente)
      --Necesitem l´agent i l´empresa de la pòlissa.

      ----Busquem codi de persona del destinatari.
      BEGIN
         SELECT p.sperson
           INTO pspersdest
           FROM per_personas p, planpensiones, fonpensiones, trasplainout
          WHERE fonpensiones.ccodfon = planpensiones.ccodfon
            AND p.sperson = fonpensiones.sperson
            AND planpensiones.ccodfon = fonpensiones.ccodfon
            AND planpensiones.ccodpla = trasplainout.ccodpla
            AND trasplainout.stras = pstras;
      /*SELECT PERSONAS.SPERSON
        INTO PSPERSDEST
        FROM PERSONAS, PLANPENSIONES, FONPENSIONES, TRASPLAINOUT
       WHERE FONPENSIONES.CCODFON = PLANPENSIONES.CCODFON
         AND PERSONAS.SPERSON = FONPENSIONES.SPERSON
         AND PLANPENSIONES.CCODFON = FONPENSIONES.CCODFON
         AND PLANPENSIONES.CCODPLA = TRASPLAINOUT.CCODPLA
         AND TRASPLAINOUT.STRAS = PSTRAS;*/
      EXCEPTION
         WHEN OTHERS THEN
            pspersdest := NULL;
      END;

      --FI Bug10612 - 03/07/2009 - DCT (Canviar vista personas por tablas personas y añadir filtro de visión de agente)
      IF pctiptras = 1 THEN
         --DBMS_OUTPUT.put_line('tancar presta: ' || 0);
         num_err := f_tancar_presta(psprestaplan, pspersonben, psseguro, xnsinies);

         --DBMS_OUTPUT.put_line('tancar presta: ' || num_err);
         IF num_err <> 0 THEN
            RAISE errortsb;
         END IF;
      ELSE
         NULL;
      ------num_err := F_MODIFICAR_PRESTA (psprestaplan, pspersonben, psseguro, pnsinies);
      END IF;

      IF pintern = 0 THEN
         xepagsin := 2;
      ELSIF pintern = 1 THEN
         xepagsin := 1;
      END IF;

      num_err := f_out(pstras, pctiptras, psseguro, xfvalmov, xfvalmov, ximovimi, ppartras,
                       xnnumlin, xfcontab, pspersdest, xepagsin);

      --DBMS_OUTPUT.put_line('sortida particep: ' || num_err);
      IF num_err <> 0 THEN
         RAISE errortsb;
      END IF;

      IF pintern = 1
         AND pautomatic = 1 THEN
         num_err := f_traspaso_inverso(2, pstras, psseguro_ds, psseguro, NULL, ppartras,
                                       pctiptras, 1, xstrasin);

         IF num_err <> 0 THEN
            RAISE errortsb;
         END IF;

         num_err := f_in_benef(xstrasin, pctiptras, pspersonben, psseguro_ds, xfvalmov,
                               xfvalmov, ximovimi, ppartras, pintern, psseguro, 0);

         IF num_err <> 0 THEN
            RAISE errortsb;
         END IF;
      END IF;

      ---*** Actualizamos el traspaso
      BEGIN
         UPDATE trasplainout
            SET cestado = DECODE(iimpanu, NULL, 3, DECODE(fantigi, NULL, 3, 4)),
                iimporte = pimovimi,
                nnumlin = xnnumlin
          WHERE stras = pstras;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 107841;   ----canviar
      END;

      RETURN 0;
   EXCEPTION
      WHEN errortsb THEN
         RETURN num_err;
      WHEN OTHERS THEN
         RETURN 1;
   END f_out_benef;

---
---
   FUNCTION f_out(
      pstras IN NUMBER,
      pctiptras IN NUMBER,
      psseguro IN NUMBER,
      pfvalmov IN OUT DATE,
      pfefecto IN OUT DATE,
      pimovimi IN OUT NUMBER,
      ppartras IN OUT NUMBER,
      pnnumlin IN OUT NUMBER,
      pfcontab IN OUT DATE,
      pspersdest IN NUMBER,
      pepagsin IN NUMBER)
      RETURN NUMBER IS
      ---
      num_err        NUMBER;
      suplemento     seguros.nsuplem%TYPE;   --       suplemento     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      num_movimi     NUMBER;
      xnsinies       prestaplan.nsinies%TYPE;   --       xnsinies       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xsidepag       NUMBER;
      ximovimi       ctaseguro.imovimi%TYPE;
      ximovim2       ctaseguro.imovim2%TYPE;
      errorts        EXCEPTION;
      v_cempres      seguros.cempres%TYPE;

      ---
      FUNCTION f_anula_recibos(psseguro IN NUMBER)
         RETURN NUMBER IS
         reg            NUMBER;
         err            NUMBER;
         movagr         NUMBER;
         liqmen         NUMBER;
         liqlin         NUMBER;
         delegacion     NUMBER;
      BEGIN
         FOR reg IN (SELECT recibos.nrecibo
                       FROM recibos, movrecibo
                      WHERE sseguro = psseguro
                        AND movrecibo.nrecibo = recibos.nrecibo
                        AND movrecibo.cestrec = 0
                        AND movrecibo.fmovfin IS NULL) LOOP
            movagr := 0;
            err := f_movrecibo(reg.nrecibo, 2, f_sysdate, NULL, movagr, liqmen, liqlin,
                               f_sysdate, NULL, NULL, NULL, NULL);

            IF err <> 0 THEN
               RETURN 1;
            END IF;
         END LOOP;

         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 1;
      END f_anula_recibos;
   BEGIN
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      --Se genera un movimiento de seguro de suplemento
      SELECT (NVL(MAX(nsuplem), 0) + 1)
        INTO suplemento
        FROM movseguro
       WHERE sseguro = psseguro;

      num_err := f_movseguro(psseguro, NULL, 271, 1, pfefecto, NULL, suplemento, 0, NULL,
                             num_movimi);

      IF num_err <> 0 THEN
         num_err := 10;
         RAISE errorts;
      END IF;

      UPDATE movseguro
         SET femisio = pfefecto
       WHERE movseguro.sseguro = psseguro
         AND movseguro.nmovimi = num_movimi;

      DECLARE
         pnparpla       NUMBER;
         tdiv           NUMBER;
      BEGIN
         pnparpla := f_valor_participlan(pfvalmov, psseguro, tdiv);

         IF ppartras IS NOT NULL
            AND ppartras <> 0 THEN
            pimovimi := f_round(ppartras * pnparpla, 1);
         ELSIF pimovimi IS NOT NULL
               AND pimovimi <> 0 THEN
            ppartras := ROUND((pimovimi / pnparpla), 6);
         END IF;
      END;

      num_err := f_dupgaran(psseguro, pfefecto, num_movimi);

      IF num_err <> 0 THEN
         num_err := 11;
         RAISE errorts;
      END IF;

      --Cambiamos el numero de suplemento en SEGUROS
      BEGIN
         UPDATE seguros
            SET nsuplem = suplemento
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 12;
            RAISE errorts;
      END;

      num_err := pk_traspasos_sin.f_crea_siniestro(psseguro, pstras, pfvalmov, 5, pimovimi,
                                                   pspersdest, 1, xnsinies, xsidepag, pepagsin);

      IF num_err <> 0 THEN
         ------NUM_ERR := 13;
         RAISE errorts;
      END IF;

      IF num_err = 0 THEN
         SELECT MAX(nnumlin) + 1
           INTO pnnumlin
           FROM ctaseguro
          WHERE sseguro = psseguro;

         pfcontab := f_sysdate;

         ----cestado  ???
         INSERT INTO ctaseguro
                     (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi,
                      imovimi, ccalint, imovim2, nsinies, cmovanu, cestado, fasign, nparpla,
                      cestpar, sidepag)
              VALUES (psseguro, pfcontab, pnnumlin, TRUNC(pfefecto), TRUNC(pfvalmov), 47,
                      pimovimi, 0, 0, xnsinies, 0, NULL, f_sysdate, ppartras,
                      1, xsidepag);

         -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0) = 1 THEN
            num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro, pfcontab,
                                                                  pnnumlin, TRUNC(pfvalmov));

            IF num_err <> 0 THEN
               RAISE errorts;
            END IF;
         END IF;
      -- FIN BUG 18423 - 15/12/2011 - JMP - Multimoneda
      END IF;

      --- **** Si el traspaso era total, tenemos que anular la póliza
      IF pctiptras = 1 THEN
         num_err := f_anula_recibos(psseguro);

         IF num_err <> 0 THEN
            num_err := 14;
            RAISE errorts;
         END IF;

         num_err := f_anulaseg(psseguro, 0, pfefecto, 272, NULL, 2, num_movimi);

         IF num_err <> 0 THEN
            RAISE errorts;
         END IF;
      /**********UPDATE CTASEGURO
      SET NNUMLIN = NNUMLIN + 1
      WHERE CTASEGURO.SSEGURO = :SEGUROS.SSEGURO
      AND CMOVIMI = 54;***************/
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN errorts THEN
         RETURN num_err;
      WHEN OTHERS THEN
         RETURN 1;
   END f_out;

---
   FUNCTION f_in(
      pstras IN NUMBER,
      psseguro IN NUMBER,
      pfvalmov IN OUT DATE,
      pfefecto IN OUT DATE,
      pimovimi IN OUT NUMBER,
      pnnumlin IN OUT NUMBER,
      pfcontab IN OUT DATE,
      pnrecibo IN OUT NUMBER)
      RETURN NUMBER IS
      ---
      suplemento     NUMBER;   -- seguros.itarifa%TYPE;   --       suplemento     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      dummy          NUMBER;
      cdelega        NUMBER := 9000;
      agente         seguros.cagente%TYPE;   --       agente         NUMBER;   -- Bug 18225 - APD - 11/04/2011 - la precisión debe ser NUMBER --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      delegacion     NUMBER;
      psmovagr       NUMBER(8);
      importe        NUMBER;   /* NUMBER(25, 10);  */
      pccobban       seguros.ccobban%TYPE;   --       pccobban       NUMBER(3); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      empresa        seguros.cempres%TYPE;   --       empresa        NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      emision        seguros.femisio%TYPE;   --       emision        DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xnliqmen       NUMBER;
      smovrecibo     NUMBER;
      num_err        NUMBER;
      num_movimi     NUMBER;
      aux_conta      NUMBER;
      pnorden        garanpro.norden%TYPE;   --       pnorden        NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pctarifa       garanpro.ctarifa%TYPE;   --       pctarifa       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pcformul       garanpro.cformul%TYPE;   --       pcformul       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pfmovini       DATE;
      participacion  ctaseguro.nparpla%TYPE;   --       participacion  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_cempres      seguros.cempres%TYPE;
      ---
      errorte        EXCEPTION;
   BEGIN
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      --DBMS_OUTPUT.put_line('Entrem f_in: ' || TO_CHAR(F_SYSDATE, 'hh24:mi:ss'));

      --Es genera un moviment de traspàs d'entrada
      SELECT (NVL(MAX(nsuplem), 0) + 1)
        INTO suplemento
        FROM movseguro
       WHERE sseguro = psseguro;

      num_err := f_movseguro(psseguro, NULL, 270, 1, pfefecto, NULL, suplemento, 0, NULL,
                             num_movimi);

      IF num_err <> 0 THEN
         RAISE errorte;
      END IF;

      --DBMS_OUTPUT.put_line('Entrem f_in: 1');

      ---Posem la data d'emissió
      UPDATE movseguro
         SET femisio = pfefecto
       WHERE movseguro.sseguro = psseguro
         AND movseguro.nmovimi = num_movimi;

      ---Dupliquem la informació i insertem l'import del traspàs
      ---en la garantia 282
      num_err := f_dupgaran(psseguro, pfefecto, num_movimi);

      IF num_err <> 0 THEN
         RAISE errorte;
      END IF;

      --DBMS_OUTPUT.put_line('Entrem f_in: 2');
      BEGIN
         SELECT COUNT(*)
           INTO aux_conta
           FROM garanseg
          WHERE sseguro = psseguro
            AND nmovimi = num_movimi
            AND cgarant = 282;

         IF aux_conta = 0 THEN
            SELECT g.norden, g.ctarifa, g.cformul
              INTO pnorden, pctarifa, pcformul
              FROM garanpro g, seguros s
             WHERE g.cramo = s.cramo
               AND g.cmodali = s.cmodali
               AND g.ctipseg = s.ctipseg
               AND g.ccolect = s.ccolect
               AND s.sseguro = psseguro
               AND cgarant = 282;

            ---
            INSERT INTO garanseg
                        (cgarant, sseguro, nriesgo, finiefe, norden, crevali, ctarifa,
                         icapital, precarg, iprianu, iextrap, ffinefe, cformul, ctipfra,
                         ifranqu, irecarg, ipritar, pdtocom, idtocom, prevali, irevali,
                         itarifa, nmovimi, itarrea, ipritot, icaptot)
                 VALUES (282, psseguro, 1, pfefecto, pnorden, 4, pctarifa,
                         pimovimi, NULL, 0, NULL, NULL, pcformul, NULL,
                         NULL, 0, 0, NULL, 0, NULL, NULL,
                         NULL, num_movimi, NULL, 0, pimovimi);
         ELSE   --- Si ja existeix la garantia 282
            UPDATE garanseg
               SET icapital = pimovimi,
                   icaptot = pimovimi
             WHERE sseguro = psseguro
               AND nmovimi = num_movimi
               AND cgarant = 282;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 101959;
            RAISE errorte;
      END;

      --**** Creem el rebut
      SELECT ccobban, cempres, cagente, femisio
        INTO pccobban, empresa, agente, emision
        FROM seguros
       WHERE sseguro = psseguro;

      num_err := f_insrecibo(psseguro, agente, f_sysdate, pfvalmov, pfvalmov + 1, 10, NULL,
                             NULL, pccobban, 0, 1, pnrecibo, 'A', NULL, 51, num_movimi,
                             pfefecto);

      IF num_err <> 0 THEN
         RAISE errorte;
      END IF;

      --DBMS_OUTPUT.put_line('Entrem f_in: 3');
      num_err := f_detrecibo(NULL, psseguro, pnrecibo, NULL, 'A', 1, f_sysdate, pfvalmov, NULL,
                             NULL, pimovimi, NULL, num_movimi, NULL, importe);

      IF num_err <> 0 THEN
         RAISE errorte;
      END IF;

      --DBMS_OUTPUT.put_line('Entrem f_in: 4');
      ---Cobrem el rebut
      delegacion := f_delegacion(pnrecibo, empresa, agente, emision);
      psmovagr := 0;
      smovrecibo := 0;

      SELECT GREATEST(pfefecto, pfvalmov, f_sysdate)
        INTO pfmovini
        FROM DUAL;

      num_err := f_movrecibo(pnrecibo, 1, pfefecto, NULL, smovrecibo, xnliqmen, dummy,
                             pfmovini, pccobban, cdelega, NULL, NULL);

      IF num_err <> 0 THEN
         RAISE errorte;
      END IF;

      --DBMS_OUTPUT.put_line('Entrem f_in: 5');
      UPDATE recibos
         SET cestimp = 2,
             cbancar = NULL
       WHERE nrecibo = pnrecibo;

      ---**** Modifiquem tipus de moviment, assignem data valor
      ---**** i calculem el nombre de participacions
      DECLARE
         pnparpla       NUMBER;
         tdiv           NUMBER;
      BEGIN
         pnparpla := f_valor_participlan(pfvalmov, psseguro, tdiv);

         IF pnparpla <> -1 THEN
            participacion := ROUND((pimovimi / pnparpla), 6);
         ELSE
            participacion := NULL;
         END IF;
      END;

      SELECT nnumlin, fcontab
        INTO pnnumlin, pfcontab
        FROM ctaseguro
       WHERE nrecibo = pnrecibo
         AND sseguro = psseguro;

      UPDATE ctaseguro
         SET cmovimi = 8,
             fvalmov = pfvalmov,
             nparpla = participacion,
             cestpar = 1,
             fasign = f_sysdate
       WHERE sseguro = psseguro
         AND fcontab = pfcontab
         AND nnumlin = pnnumlin;

      -- BUG 18423 - 29/12/2011 - JMP - Multimoneda
      IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0) = 1 THEN
         num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro, pfcontab, pnnumlin,
                                                               pfvalmov);

         IF num_err <> 0 THEN
            RAISE errorte;
         END IF;
      END IF;

      -- FIN BUG 18423 - 29/12/2011 - JMP - Multimoneda

      --DBMS_OUTPUT.put_line('SORTIM F_IN');
      RETURN 0;
   EXCEPTION
      WHEN errorte THEN
         --DBMS_OUTPUT.put_line('Entrem f_in: 6');
         --DBMS_OUTPUT.put_line('Entrem f_in: 6');
         RETURN num_err;
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line('F_IN: ' || num_err);
         --DBMS_OUTPUT.put_line('F_IN: ' || SQLERRM);
         RETURN SQLCODE;
   END f_in;

---
---
   FUNCTION f_tancar_presta(
      psprestaplan IN NUMBER,
      pspersonben IN NUMBER,
      psseguro IN NUMBER,
      pnsinies IN NUMBER)
      RETURN NUMBER IS
      quants_oberts  NUMBER;
      num_err        NUMBER := 0;
   BEGIN
      --DBMS_OUTPUT.put_line(1);
      UPDATE planbenefpresta
         SET cestado = 3
       WHERE sprestaplan = psprestaplan
         AND sperson = pspersonben
         AND ctipcap IN(2, 3);   ----RENDA O MIXTA

      UPDATE benefprestaplan
         SET nparpla = 0
       WHERE sprestaplan = psprestaplan
         AND sperson = pspersonben;

      --DBMS_OUTPUT.put_line(2);
      UPDATE prestaplan
         SET cestado = 3
       WHERE sprestaplan = psprestaplan;

      ---Comprovem si totes les prestacions estan tancades
      ---de la mateixa pòlissa
      ---Si ho estan tanquem el sinistre
      --DBMS_OUTPUT.put_line(3);
      SELECT COUNT(*)
        INTO quants_oberts
        FROM prestaplan
       WHERE prestaplan.sseguro = psseguro
         AND prestaplan.cestado IN(1, 2);

      IF quants_oberts = 0 THEN
         -----num_err := PK_TRASPASOS_SIN.F_CIERRA_SINIESTRO(pnsinies);
         NULL;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line(SQLERRM);
         RETURN 1;
   END f_tancar_presta;

---
---
   FUNCTION f_crear_presta(
      pstras IN NUMBER,
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pfvalmov IN DATE,
      pfefecto IN DATE,
      bconfirmar IN BOOLEAN,
      psprestaplan OUT NUMBER,
      xprorat IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;
      num_movimi     NUMBER;
      suplemento     NUMBER;   -- seguros.itarifa%TYPE;   --       suplemento     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xiimpanu       NUMBER := NULL;
      xnnivel        prestaplan.nnivel%TYPE := NULL;   --       xnnivel        NUMBER := NULL; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xctipren       prestaplan.ctipren%TYPE := NULL;   --       xctipren       NUMBER(1) := NULL; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xctipjub       trasplainout.iimpanu%TYPE := NULL;   --       xctipjub       NUMBER := NULL; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xfaccion       prestaplan.faccion%TYPE := NULL;   --       xfaccion       DATE := NULL; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xcestado       NUMBER := NULL;
      xnsinies       prestaplan.nsinies%TYPE := NULL;   --       xnsinies       NUMBER := NULL; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xiparti        benefprestaplan.nparpla%TYPE := NULL;   --       xiparti        NUMBER := NULL; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xpartipos      trasplainout.nparret%TYPE := NULL;   --       xpartipos      NUMBER := NULL; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xpartrasret    NUMBER := NULL;
      xtipdestinat   NUMBER := 1;
      xsidepag       NUMBER;
      xctipcap       benefprestaplan.ctipcap%TYPE;   --       xctipcap       NUMBER(1); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      movagr         NUMBER;
      liqmen         NUMBER;
      liqlin         NUMBER;
      xiimporte      NUMBER;
      secuencia      NUMBER;
      xsperson       riesgos.sperson%TYPE;   --       xsperson       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      mensaje_error  EXCEPTION;
      xsprestaplan   NUMBER(8);
   BEGIN
      SELECT nparret,   --, CTIPJUB,
                     ----------, CTIPCAP, FPROPAG,
                            -------CPERIOD, CREVAL, CTIPREV, FPROREV, PREVALO, IREVALO,
                            -----NREVANU,
                     iimpanu, iimporte
        INTO xpartipos   --, xCTIPJUB,
                      ---------, xCTIPCAP, xFROPAG,
                         -------  xCPERIOD, XCREVAL, xctiprev, xfprorev, xprevalo, xirevalo,
                           -----xnrevanu,
      ,      xiimpanu, xiimporte
        FROM trasplainout
       WHERE stras = pstras;

      SELECT sprestaplan.NEXTVAL
        INTO psprestaplan
        FROM DUAL;

      DECLARE
         xesbenef       NUMBER(1);
      BEGIN
         SELECT 1
           INTO xesbenef
           FROM riesgos
          WHERE riesgos.sseguro = psseguro
            AND riesgos.sperson = psperson;

         IF xesbenef = 1 THEN
            SELECT NVL(MAX(NVL(nnivel, 0)), 0) + 1
              INTO xnnivel
              FROM prestaplan
             WHERE prestaplan.sseguro = psseguro
               AND prestaplan.sperson = psperson
               AND prestaplan.cestado = 2;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            xnnivel := 1;
      END;

      DECLARE
         pnparpla       NUMBER;
         tdiv           NUMBER;
      BEGIN
         pnparpla := f_valor_participlan(pfvalmov, psseguro, tdiv);

         IF pnparpla <> -1 THEN
            IF xctipcap = 1 THEN   ---capital
               xiparti := ROUND((xiimporte / pnparpla), 6);
            ELSIF xctipcap = 2 THEN   ----renda
               xiparti := ROUND((xiimpanu / pnparpla), 6);
            ELSIF xctipcap = 3 THEN   ----mixte
               xiparti := ROUND(((xiimpanu + xiimporte) / pnparpla), 6);
            END IF;
         END IF;
      END;

      INSERT INTO prestaplan
                  (sprestaplan, sseguro, sperson, ctipren, ctipjub, faccion, nnivel,
                   fcreacion, cestado, nsinies, nparti, nparret, npartrasret)
           VALUES (psprestaplan, psseguro, psperson, xctipren, xctipjub, xfaccion, xnnivel,
                   f_sysdate, 1, NULL, xiparti, xpartipos, NULL);

      INSERT INTO benefprestaplan
                  (sprestaplan, sperson, nparpla, ctipcap, nporcen, nparfin)
           VALUES (psprestaplan, psperson, xiparti, xctipcap, NULL, NULL);

   -----?????ERR := CALCULAR_RETENCION_IRPF( :PLANBENEFPRESTA.NRETENC )  ;
/*
   INSERT INTO PLANBENEFPRESTA
         (SPRESTAPLAN, SPERSON, CTIPCAP, CPERIOD, FINICIO, IMPORTE, NPARTOT,
         CESTADO, NRETENC, IREDUC, IREDUCSN, NRETENCSN, CIMPRES, CBANCAR,
         NREVANU, FPROREV, PREVALO, FMODIFI, CTIPREV, IREVALO)
   VALUES
         (
         pSPRESTAPLAN, pSPERSON, xCTIPCAP, xCPERIOD, ??xFINICIO, ??xIMPORTE, ??xNPARTOT,
         ??xCESTADO, ??XNRETENC, ??xIREDUC, ??xIREDUCSN, ??xNRETENCSN, 'S', ??xCBANCAR,
         xNREVANU, xFPROREV, xPREVALO, NULL, xCTIPREV, xIREVALO);
*/
      IF bconfirmar THEN
         -- Ahora suspendemos las aportaciones periódicas
         IF xnnivel = 1 THEN
            UPDATE seguros
               SET fcarpro = NULL,
                   fcaranu = NULL
             WHERE sseguro = psseguro;

            --**** Anulamos los recibos pendientes
            FOR reg IN (SELECT recibos.nrecibo
                          FROM recibos, movrecibo
                         WHERE sseguro = psseguro
                           AND movrecibo.nrecibo = recibos.nrecibo
                           AND movrecibo.cestrec = 0
                           AND movrecibo.fmovfin IS NULL) LOOP
               movagr := 0;
               num_err := f_movrecibo(reg.nrecibo, 2, f_sysdate, NULL, movagr, liqmen, liqlin,
                                      f_sysdate, NULL, NULL, NULL, NULL);

               IF num_err <> 0 THEN
                  RETURN 1;
               END IF;
            END LOOP;
         END IF;

         SELECT sperson
           INTO xsperson
           FROM riesgos
          WHERE sseguro = psseguro;

         IF psperson = xsperson THEN
            xtipdestinat := 1;
         ELSE
            xtipdestinat := 6;
         END IF;

         num_err := pk_traspasos_sin.f_crea_siniestro(psseguro, pstras, pfvalmov, xtipdestinat,
                                                      0, psperson, 2, xnsinies, xsidepag, 0);

         IF num_err <> 0 THEN
            RAISE mensaje_error;
         END IF;

         UPDATE prestaplan
            SET nsinies = xnsinies,
                cestado = 2
          WHERE sprestaplan = psprestaplan;

         IF xnnivel > 1 THEN
            --******** sI EL PARTE ES MAYOR QUE NIVEL 1, tenemos que cerrar el anterior
            -- pero antes ponemos las participaciones a repartir a cero del anterior parte
            -- y ponemos también a 0 el plan de pagos.
            SELECT prestaplan.sprestaplan
              INTO xsprestaplan
              FROM prestaplan, benefprestaplan
             WHERE prestaplan.sprestaplan = benefprestaplan.sprestaplan
               AND prestaplan.nnivel = xnnivel - 1
               AND benefprestaplan.sperson = psperson
               AND prestaplan.sseguro = psseguro
               AND prestaplan.cestado = 2;

            UPDATE benefprestaplan
               SET nparfin = nparpla,
                   nparpla = 0
             WHERE sprestaplan = xsprestaplan
               AND benefprestaplan.sperson = psperson;

            UPDATE planbenefpresta
               SET cestado = 2
             WHERE sprestaplan = xsprestaplan
               AND planbenefpresta.sperson = psperson;

            --***... y si todas las participacones de los beneficiarios estan a 0
            --***... también cerramos el parte.
            UPDATE prestaplan
               SET cestado = 3
             WHERE prestaplan.nnivel = xnnivel - 1
               AND prestaplan.sseguro = psseguro
               AND prestaplan.cestado = 2
               AND 0 = (SELECT SUM(nparpla)
                          FROM benefprestaplan
                         WHERE benefprestaplan.sprestaplan = prestaplan.sprestaplan);
         ELSIF xnnivel = 1 THEN
            -- *** Insertamos registros en la INTERFASE FSE0620 Y FSE070
            -- *** si el partícipe pasa a beneficiario
            INSERT INTO pila_ifases
                        (sseguro, fecha, ifase)
                 VALUES (psseguro, f_sysdate, 'FSE0620');

            INSERT INTO pila_pendientes
                        (sseguro, ffecmov, iimpmov, ccodmov)
                 VALUES (psseguro, f_sysdate, 0, 16);
         END IF;
      END IF;

      NULL;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_crear_presta;

---
   FUNCTION f_traspaso_inverso(
      pcparoben IN NUMBER,
      pstras IN NUMBER,
      psseguro_ds IN NUMBER,
      psseguro_or IN NUMBER,
      pimovimi IN NUMBER,
      ppartras IN NUMBER,
      pctiptras IN NUMBER,
      pcinout IN NUMBER,
      pstrasin IN OUT NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;
      id_traspaso    trasplainout.stras%TYPE;   /* NUMBER(8);     */
      PLAN           NUMBER(7);
      pcbancar       seguros.cbancar%TYPE;
      pnpoliza       NUMBER;   -- Bug 28462 - 07/10/2013 - HRE - Cambio de dimension SSEGURO
      pncertif       NUMBER;   -- Bug 28462 - 04/10/2013 - DEV - la precisión debe ser NUMBER
      xcoment        VARCHAR2(100);
   BEGIN
      SELECT proplapen.ccodpla, npoliza, ncertif
        INTO PLAN, pnpoliza, pncertif
        FROM proplapen, productos, seguros
       WHERE seguros.sseguro = psseguro_or
         AND seguros.cramo = productos.cramo
         AND seguros.cmodali = productos.cmodali
         AND seguros.ctipseg = productos.ctipseg
         AND seguros.ccolect = productos.ccolect
         AND productos.sproduc = proplapen.sproduc;

      xcoment := literal(111334);

      IF pcparoben = 1 THEN
         SELECT stras.NEXTVAL
           INTO id_traspaso
           FROM DUAL;

         -- Si el traspaso de salida no tiene cuenta cogemos la del fondo
         SELECT f.cbancar
           INTO pcbancar
           FROM planpensiones p, fonpensiones f
          WHERE f.ccodfon = p.ccodfon
            AND p.ccodpla = PLAN;

         INSERT INTO trasplainout
                     (stras, cinout, sseguro, fsolici, ccodpla, tpolext, ncertext,
                      cestado, ctiptras, iimptemp, fantigi, nporcen, nparpla, tmemo)
              VALUES (id_traspaso, pcinout, psseguro_ds, f_sysdate, PLAN, pnpoliza, pncertif,
                      2, pctiptras, pimovimi, NULL, 0, 0, xcoment);
      ELSIF pcparoben = 2 THEN
         SELECT stras.NEXTVAL
           INTO id_traspaso
           FROM DUAL;
/************
      INSERT INTO TRASPLAINOUT
            (STRAS, CINOUT, SSEGURO, FSOLICI, CCODPLA,
            TPOLEXT, CBANCAR, CESTADO, CTIPTRAS, TMEMO,
            IIMPORTE, IIMPTEMP, IIMPANU, FANTIGI, NNUMLIN,
            NCERTEXT, NPORCEN, NPARPLA,
            SPERSON, CPARBEN, NPARRET, SPRESTAPLAN, CTIPREN,
            CTIPJUB, CTIPCAP, FPROPAG, CPERIOD, CREVAL,
            CTIPREV, FPROREV, PREVALO, IREVALO, NREVANU)
      SELECT ID_TRASPASO, pcinout, psseguro_ds, F_SYSDATE, plan,
            pNPOLIZA, NULL, 2, CTIPTRAS, TMEMO,
            NULL, NULL, NULL, NULL, NULL,
            pncertif, NULL, NULL,
            SPERSON, CPARBEN, NPARRET, NULL, CTIPREN,
            CTIPJUB, CTIPCAP, FPROPAG, CPERIOD, CREVAL,
            CTIPREV, FPROREV, PREVALO, IREVALO, NREVANU
      FROM TRASPLAINOUT
      WHERE stras = pstras;
*****/
      END IF;

      pstrasin := id_traspaso;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_traspaso_inverso;
---
END pk_traspasos;

/

  GRANT EXECUTE ON "AXIS"."PK_TRASPASOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_TRASPASOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_TRASPASOS" TO "PROGRAMADORESCSI";
