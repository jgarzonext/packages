--------------------------------------------------------
--  DDL for Package Body PAC_VENTASCONTAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_VENTASCONTAB" IS
/************************************************************************************************
  Proceso batch diario que calcula las ventas desde el último mes cerrado
  proceso de cierre
************************************************************************************************/
   vg_nmesven     NUMBER;
   vg_nanyven     NUMBER;

/***********************************************************************************
 FUNCIONES QUE CALCULAN EL REPARTO DE VENTA ENTRE EL EJERCICIO ACTUAL Y EL ANTERIOR
************************************************************************************/
------------------------------------------------------------------------------------------------
   FUNCTION f_renovapost(w_sseguro IN NUMBER, w_excant IN NUMBER, w_frenova OUT DATE)
      RETURN NUMBER IS
/******************************************************************************************
Funcio f_renovapost : Obte la suposada data de renovació posterior a la de
                      l'exercici anterior
Paràmetres :
- w_sseguro : Sseguro del rebut
- w_excant  : Exercici anterior
- w_frenova : Data de renovació
******************************************************************************************/
      l_error        NUMBER;
      l_excact       VARCHAR2(4);
      l_fefecto      movseguro.fefecto%TYPE;   --       l_fefecto      DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      l_frenova      DATE;
      l_char         VARCHAR2(8);
      l_nrenova      seguros.nrenova%TYPE;   --       l_nrenova      NUMBER(4); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      l_nmovimi      movseguro.nmovimi%TYPE;
      l_fcanvi       DATE;
      l_fvencim      seguros.fvencim%TYPE;   --       l_fvencim      DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      l_fcaranu      seguros.fcaranu%TYPE;   --       l_fcaranu      DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      w_frenova := NULL;
      l_error := 0;
      l_excact := TO_CHAR(w_excant + 1);

      -- Busquem les dades de la pòlissa
      SELECT fvencim, fcaranu, nrenova
        INTO l_fvencim, l_fcaranu, l_nrenova
        FROM seguros
       WHERE sseguro = w_sseguro;

      BEGIN
         -- Busquem la data de la cartera de l'exercici anterior (o efecte de la pòlissa)
         SELECT MAX(fefecto)
           INTO l_fefecto
           FROM movseguro
          WHERE sseguro = w_sseguro
            AND cmovseg = 2
            AND nanyven = w_excant;

         IF l_fefecto IS NULL THEN
            -- Busquem la data de efecte de la pòlissa en l'exercici anterior
            BEGIN
               SELECT fefecto
                 INTO l_fefecto
                 FROM movseguro
                WHERE sseguro = w_sseguro
                  AND cmovseg = 0
                  AND nanyven = w_excant;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  l_fefecto := NULL;
            END;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            l_error := 104349;   -- Altres errors al llegir de movseguro
      END;

      IF l_fefecto IS NOT NULL THEN
         -- Buscar següent data de renovacio a la de l'exercici anterior
         BEGIN
            SELECT fefecto
              INTO w_frenova
              FROM movseguro
             WHERE sseguro = w_sseguro
               AND nmovimi = (SELECT MIN(nmovimi)
                                FROM movseguro
                               WHERE sseguro = w_sseguro
                                 AND cmovseg = 2
                                 AND fefecto > l_fefecto);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- No trobem cap moviment de renovació posterior a la de l'exercici anterior
               IF l_fcaranu IS NULL THEN   -- No és pòlissa renovable
                  w_frenova := l_fvencim;
               ELSE
                  -- Com que no hem trobat renovacio posterior, suposem que és la propera
                  w_frenova := l_fcaranu;
               END IF;
            WHEN OTHERS THEN
               l_error := 104349;   -- Altres errors al llegir de movseguro
         END;
      END IF;

      RETURN l_error;
   END f_renovapost;

-------------------------------------------------------------------------------------------------
   FUNCTION f_trasllat_prima(
      w_sseguro IN NUMBER,
      w_dataini IN DATE,
      w_datafi IN DATE,
      w_fgaran IN DATE,
      p_moneda IN NUMBER,
      w_import OUT NUMBER,
      w_diespnoe OUT NUMBER)
      RETURN NUMBER IS
/******************************************************************************************
 Funcio f_trasllat_prima
 Obté la prima de garanties en la situació que tenien en la data w_fgaran, prorratejada
 en el periode de w_dataini a w_datafi
******************************************************************************************/
      l_prima_anual  NUMBER;   /* NUMBER(15, 2);     */
      l_error        NUMBER;
      l_nasegur      NUMBER;
   BEGIN
      l_error := 0;

      -- Obtenir nº de assegurats ( si cobjase = 4)
      BEGIN
         SELECT NVL(nasegur, 1)
           INTO l_nasegur
           FROM seguros s, riesgos r
          WHERE s.sseguro = r.sseguro
            AND s.cobjase = 4
            AND s.sseguro = w_sseguro
            AND r.fefecto <= w_fgaran
            AND(r.fanulac > w_fgaran
                OR r.fanulac IS NULL);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_nasegur := 1;
         WHEN OTHERS THEN
            l_error := 103509;   -- Error al leer de la tabla RIESGOS
      END;

      -- Obtenir la prima en la data w_fgaran
      SELECT SUM(iprianu)
        INTO l_prima_anual
        FROM garanseg g, movseguro m
       WHERE g.sseguro = w_sseguro
         AND g.sseguro = m.sseguro
         AND g.nmovimi = m.nmovimi
         AND m.cmovseg <> 6
         AND finiefe <= w_fgaran
         AND(ffinefe > w_fgaran
             OR ffinefe IS NULL);

      l_prima_anual := l_prima_anual * l_nasegur;

      IF l_prima_anual IS NULL THEN
         l_prima_anual := 0;
      END IF;

      w_import := 0;
      l_error := f_difdata(w_dataini, w_datafi, 1, 3, w_diespnoe);

      IF l_error = 0 THEN
         w_import := f_round(l_prima_anual * w_diespnoe / 365, p_moneda);
      END IF;

      RETURN l_error;
   END f_trasllat_prima;

-------------------------------------------------------------------------------------------------
   FUNCTION f_trasllat_prima_gar(
      w_sseguro IN NUMBER,
      w_cgarant IN NUMBER,
      w_nriesgo IN NUMBER,
      w_dataini IN DATE,
      w_datafi IN DATE,
      w_fgaran IN DATE,
      p_moneda IN NUMBER,
      w_import OUT NUMBER,
      w_diespnoe OUT NUMBER)
      RETURN NUMBER IS
/*****************************************************************************************
 Funcio f_trasllat_prima_gar
 obté la prima de la garantia en la situació que tenia en la data w_fgaran, prorratejada
 en el periode de w_dataini a w_datafi
******************************************************************************************/
      l_prima_anual  NUMBER;   /* NUMBER(15, 2);   */
      l_error        NUMBER;
      l_dies         NUMBER(4);
      l_nasegur      NUMBER;
   BEGIN
      l_error := 0;

-- Obtenir nº de assegurats ( si cobjase = 4)
      BEGIN
         SELECT NVL(nasegur, 1)
           INTO l_nasegur
           FROM riesgos r
          WHERE r.sseguro = w_sseguro
            AND r.nriesgo = w_nriesgo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_nasegur := 1;
         WHEN OTHERS THEN
            l_error := 103509;   -- Error al leer de la tabla RIESGOS
      END;

      -- Obtenir la prima en la data w_fgaran para una garantia y riesgo
      SELECT SUM(iprianu)
        INTO l_prima_anual
        FROM garanseg g, movseguro m
       WHERE g.sseguro = w_sseguro
         AND g.sseguro = m.sseguro
         AND g.nmovimi = m.nmovimi
         AND g.cgarant = w_cgarant
         AND g.nriesgo = w_nriesgo
         AND m.cmovseg <> 6
         AND finiefe <= w_fgaran
         AND(ffinefe > w_fgaran
             OR ffinefe IS NULL);

      l_prima_anual := l_prima_anual * l_nasegur;

      IF l_prima_anual IS NULL THEN
         l_prima_anual := 0;
      END IF;

      w_import := 0;
      l_error := f_difdata(w_dataini, w_datafi, 1, 3, w_diespnoe);

      IF l_error = 0 THEN
         w_import := f_round(l_prima_anual * w_diespnoe / 365, p_moneda);
      END IF;

      RETURN l_error;
   END f_trasllat_prima_gar;

--------------------------------------------------------------------------------------------
   FUNCTION f_ppe_excant_anual(
      w_sseguro IN NUMBER,
      w_excact IN NUMBER,
      w_fcierre IN DATE,
      p_moneda IN NUMBER,
      w_pnoe OUT NUMBER,
      w_diasppe OUT NUMBER)
      RETURN NUMBER IS
/******************************************************************************************
 Funcio f_ppe_excant_anual
 Obt' la prima no emesa de la polissa corresponent a l'exercici anterior
 Par.metres :
 w_sseguro
 w_excact      : exercici a calcul.lar
 w_fcierre     : Data tancament de l'exercici
 p_moneda      : moneda
 w_pnoe        : prima no emesa de la polissa corresponent a l'exercici anterior
 w_diasppe     : dias hasta la renovación
******************************************************************************************/
      l_error        NUMBER;
      l_dataini      DATE;
      l_datafi       DATE;
      l_nrenova      seguros.nrenova%TYPE;   --       l_nrenova      NUMBER(4); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      l_excact       VARCHAR2(4);
   BEGIN
      l_error := 0;

-- Obtenir data de venciment del darrer rebut de l'exercici (No regularitzacio)
      SELECT MAX(fvencim)
        INTO l_dataini
        FROM movrecibo mr, movseguro m, recibos r
       WHERE r.sseguro = w_sseguro
         AND r.sseguro = m.sseguro
         AND r.nmovimi = m.nmovimi
         AND mr.nrecibo = r.nrecibo
         AND mr.fmovini <= w_fcierre
         AND(mr.fmovfin > w_fcierre
             OR mr.fmovfin IS NULL)
         AND mr.cestrec <> 2
         AND m.cmovseg <> 6
         AND r.ctiprec IN(3, 0)
         AND m.nanyven = w_excact
         AND TO_CHAR(r.fefecto, 'yyyy') = w_excact;

      IF l_dataini IS NOT NULL THEN
         -- Obtenir data de renovaci½
         l_error := pac_ventascontab.f_renovapost(w_sseguro, w_excact, l_datafi);

         IF l_error = 0 THEN
            IF l_datafi IS NULL
               OR   -- Si no hemos conseguido localizar una fecha o
                 l_datafi <= l_dataini THEN   -- la inicial es superior a la final
                                              -- pasaremos las fechas para que no prorratee
               l_datafi := l_dataini;
               w_pnoe := 0;
            ELSE
               l_error := pac_ventascontab.f_trasllat_prima(w_sseguro, l_dataini, l_datafi,
                                                            TO_DATE('3112' || w_excact,
                                                                    'ddmmyyyy'),
                                                            p_moneda, w_pnoe, w_diasppe);
            END IF;
         END IF;
      ELSE
         w_pnoe := 0;
      END IF;

      RETURN l_error;
   END f_ppe_excant_anual;

--------------------------------------------------------------------------------------
   FUNCTION f_ppeea(
      p_cempres IN NUMBER,
      p_excact IN NUMBER,
      p_moneda IN NUMBER,
      p_sproces IN NUMBER,
      text_error OUT VARCHAR2)
      RETURN NUMBER IS
/*************************************************************
 Càlcul de la prima pendent d'emetre de l'exercici anterior.
 Procés que s'executa a cada tancament anual per inicialitzar
 les primes pendents d'emetre anuals.
**************************************************************/
      num_err        NUMBER := 0;
      l_pnoe         ventascontab.itotcon%TYPE;   --       l_pnoe         NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      l_pnoe_ced     ventascontab.itotcon_coa%TYPE;   --       l_pnoe_ced     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      l_diasppe      NUMBER;
      v_fcierre      cierres.fcierre%TYPE;   --       v_fcierre      DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      l_ploccoa      coacuadro.ploccoa%TYPE := 0;   --       l_ploccoa      NUMBER := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---

      CURSOR c_seguros(c_cempres NUMBER, c_exer NUMBER) IS
         SELECT DISTINCT s.sseguro, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                         s.npoliza, s.ncertif, s.cagente, s.cagrpro, s.ctiprea, s.ctipcoa
                    FROM movseguro m, seguros s
                   WHERE m.sseguro = s.sseguro
                     AND s.cempres = c_cempres
                     AND s.cforpag NOT IN(0)
                     AND(s.csituac IN(0, 5)
                         OR   -- Vigente o prop. de suplem
                           (s.csituac IN(2, 3)
                            AND m.cmovseg = 3
                            AND fmovimi >= TO_DATE('0101' || c_exer, 'ddmmyyyy'))
                         OR   -- anulada o vencida despues del cierre
                           (fvencim >= TO_DATE('0101' || c_exer, 'ddmmyyyy')
                            AND fvencim IS NOT NULL)   -- vencida despues del cierre
                                                    );
   BEGIN
      BEGIN
         SELECT fcierre
           INTO v_fcierre
           FROM cierres
          WHERE cempres = p_cempres
            AND ctipo = 1
            AND fperfin = TO_DATE('3112' || p_excact, 'ddmmyyyy');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_fcierre := TO_DATE('3112' || p_excact, 'ddmmyyyy');
         WHEN OTHERS THEN
            text_error := 'empresa = ' || p_cempres || ' ' || SQLERRM || ' ' || SQLCODE;
            RETURN 105511;   -- Error de lectura en CIERRES
      END;

      FOR seg IN c_seguros(p_cempres, p_excact + 1) LOOP
         l_pnoe_ced := 0;
         l_pnoe := 0;
         l_diasppe := 0;
         num_err := f_ppe_excant_anual(seg.sseguro, p_excact, v_fcierre, p_moneda, l_pnoe,
                                       l_diasppe);

         IF num_err = 0 THEN
            IF seg.ctipcoa IN(1, 2) THEN
               BEGIN
                  SELECT ploccoa
                    INTO l_ploccoa
                    FROM coacuadro
                   WHERE sseguro = seg.sseguro
                     AND finicoa <= TO_DATE('3112' || p_excact, 'ddmmyyyy')
                     AND(ffincoa > TO_DATE('3112' || p_excact, 'ddmmyyyy')
                         OR ffincoa IS NULL);
               EXCEPTION
                  WHEN OTHERS THEN
                     l_ploccoa := 100;   -- si no lo encuentra lo consideraremos todo local
               END;

               l_pnoe_ced := f_round(l_pnoe *(100 - l_ploccoa) / l_ploccoa, p_moneda);
            END IF;

            IF l_pnoe <> 0
               OR l_pnoe_ced <> 0 THEN
               INSERT INTO ventascontab
                           (sseguro, ctipo, cexerci, nanyven, nmesven, sproces,
                            fcierre, fcalcul, cempres,
                            cramo, cmodali, ctipseg, ccolect, cactivi,
                            npoliza, ncertif, cagente, cagrpro, ctiprea,
                            ctipcoa, ipridev, iprinet, ipemiti, itotcon, iips, idgs, iarbitr,
                            ifng, irecfra, idtoom, iderreg, ipridev_coa, iprinet_coa,
                            ipemiti_coa, itotcon_coa, iips_coa, idgs_coa, iarbitr_coa,
                            ifng_coa, irecfra_coa, idtoom_coa, iderreg_coa, ndiasppe)
                    VALUES (seg.sseguro, 1, 0, p_excact + 1, 0, p_sproces,
                            TO_DATE('3112' || p_excact, 'ddmmyyyy'), f_sysdate, p_cempres,
                            seg.cramo, seg.cmodali, seg.ctipseg, seg.ccolect, seg.cactivi,
                            seg.npoliza, seg.ncertif, seg.cagente, seg.cagrpro, seg.ctiprea,
                            seg.ctipcoa, 0, 0, l_pnoe, 0, 0, 0, 0,
                            0, 0, 0, 0, 0, 0,
                            l_pnoe_ced, 0, 0, 0, 0,
                            0, 0, 0, 0, l_diasppe);
            END IF;
         ELSE
            RETURN num_err;
         END IF;
      END LOOP;

      RETURN 0;
   END f_ppeea;

-------------------------------------------------------------------------------------------------
   FUNCTION f_pnoe_excant(
      w_sseguro IN NUMBER,
      w_excant IN NUMBER,
      p_moneda IN NUMBER,
      w_pnoe OUT NUMBER)
      RETURN NUMBER IS
/******************************************************************************************
 Funcio f_pnoe_excant
 Obté la prima no emesa de la polissa corresponent a l'exercici anterior
 Paràmetres :
 w_sseguro
 w_excant     : exercici anterior
 p_moneda     : moneda
 w_pnoe       : prima no emesa de la polissa corresponent a l'exercici anterior
******************************************************************************************/
      l_error        NUMBER;
      l_ipemiti      ventascontab.ipemiti%TYPE;   --       l_ipemiti      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      l_ndiasppe     ventascontab.ndiasppe%TYPE;   --       l_ndiasppe     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      l_error := 0;

-- Obtenir la prima pendet d'emetre de l'any anterior i el n. de dies de prorrata
      BEGIN
         SELECT ipemiti, ndiasppe
           INTO l_ipemiti, l_ndiasppe
           FROM ventascontab
          WHERE nmesven = 0
            AND nanyven = w_excant + 1
            AND cexerci = 0
            AND sseguro = w_sseguro;

         w_pnoe := f_round(l_ipemiti / l_ndiasppe, p_moneda);   -- prima diaria
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            w_pnoe := 0;
         WHEN OTHERS THEN
            l_error := 108175;
      END;

      RETURN l_error;
   END f_pnoe_excant;

-------------------------------------------------------------------------------------------------
   FUNCTION f_pnoe_excant_gar(
      w_sseguro IN NUMBER,
      w_nriesgo IN NUMBER,
      w_cgarant IN NUMBER,
      w_excant IN NUMBER,
      w_fcierreefe IN DATE,
      w_fcierreproc IN DATE,
      p_moneda IN NUMBER,
      w_pnoe OUT NUMBER)
      RETURN NUMBER IS
/******************************************************************************************
 Funcio f_pnoe_excant_gar
 Obté la prima no emesa de la polissa corresponent a l'exercici anterior
 Paràmetres :
 w_sseguro
 w_nriesgo
 w_cgarant
 w_excant  : exercici anterior
 w_fcierreproc : Data tancament de l'exercici anterior
 w_fcierreefe: Darrer dia d'efecte de l'exercici anterior ('3112yyyy')
 p_moneda  : moneda
 w_pnoe    : prima no emesa de la polissa corresponent a l'exercici anterior
******************************************************************************************/
      l_error        NUMBER;
      l_dies         NUMBER;
      l_dataini      DATE;
      l_datafi       DATE;
      l_nrenova      seguros.nrenova%TYPE;   --       l_nrenova      NUMBER(4); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      l_excact       VARCHAR2(4);
   BEGIN
      l_error := 0;

      -- Obtenir data de venciment del darrer rebut de l'exercici anterior (No regularitzacio)
      SELECT MAX(fvencim)
        INTO l_dataini
        FROM movrecibo mr, movseguro m, recibos r
       WHERE r.sseguro = w_sseguro
         AND r.sseguro = m.sseguro
         AND r.nmovimi = m.nmovimi
         AND mr.nrecibo = r.nrecibo
         AND mr.fmovini <= w_fcierreproc
         AND(mr.fmovfin > w_fcierreproc
             OR mr.fmovfin IS NULL)
         AND mr.cestrec <> 2
         AND m.cmovseg <> 6
         AND r.ctiprec IN(3, 0)
         AND m.nanyven = w_excant
         AND TO_CHAR(r.fefecto, 'yyyy') = w_excant;

      IF l_dataini IS NOT NULL THEN
         -- Obtenir data de renovació
         l_error := f_renovapost(w_sseguro, w_excant, l_datafi);

         IF l_datafi IS NULL
            OR   -- Si no hemos conseguido localizar una fecha o
              l_datafi < l_dataini THEN   -- la inicial es superior a la final
                                          -- pasaremos las fechas para que no prorratee
            l_datafi := l_dataini;
         END IF;

         IF l_error = 0 THEN
            l_error := f_trasllat_prima_gar(w_sseguro, w_cgarant, w_nriesgo, l_dataini,
                                            l_datafi, w_fcierreefe, p_moneda, w_pnoe, l_dies);

            IF l_dies = 0 THEN
               w_pnoe := 0;
            ELSE
               w_pnoe := f_round(w_pnoe / l_dies, p_moneda);
            END IF;
         END IF;
      ELSE
         w_pnoe := 0;
      END IF;

      RETURN l_error;
   END f_pnoe_excant_gar;

-------------------------------------------------------------------------------------------------
   FUNCTION f_pe_excant(
      w_sseguro IN NUMBER,
      w_fefecto IN DATE,
      w_fvencim IN DATE,
      w_excant IN NUMBER,
      w_fcierreefe IN DATE,
      w_fcierreproc IN DATE,
      p_moneda IN NUMBER,
      w_pe_excant OUT NUMBER)
      RETURN NUMBER IS
/******************************************************************************************
 Funcio f_pe_excant
 Paràmetres :
 - w_sseguro : Sseguro del rebut
 - w_fefecto : Efecte del rebut
 - w_fvencim : Venciment del rebut
 - w_excant  : Exercici anterior
 - w_fcierreproc: Data tancament de l'exercici anterior
 - w_fcierreefe: Darrer dia d'efecte de l'exercici anterior ('3112yyyy')
 - p_moneda  : Moneda
 - w_pe_excant : Part de la prima emesa del rebut, que correspon a l'exercici anterior
******************************************************************************************/
      l_pnoe         ventascontab.itotcon%TYPE;   --       l_pnoe         NUMBER(15, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      l_error        NUMBER;
      l_dies         NUMBER(4);
   BEGIN
      w_pe_excant := 0;
      l_error := f_pnoe_excant(w_sseguro, w_excant, p_moneda, l_pnoe);

      IF l_error = 0 THEN
         l_error := f_difdata(w_fefecto, w_fvencim, 1, 3, l_dies);

         IF l_error = 0 THEN
            w_pe_excant := f_round(l_pnoe * l_dies, p_moneda);
         END IF;
      END IF;

      RETURN l_error;
   END f_pe_excant;

-------------------------------------------------------------------------------------------------
   FUNCTION f_pe_excant_gar(
      w_sseguro IN NUMBER,
      w_nriesgo IN NUMBER,
      w_cgarant IN NUMBER,
      w_fefecto IN DATE,
      w_fvencim IN DATE,
      w_excant IN NUMBER,
      w_fcierreefe IN DATE,
      w_fcierreproc IN DATE,
      p_moneda IN NUMBER,
      w_pe_excant_gar OUT NUMBER)
      RETURN NUMBER IS
/******************************************************************************************
 Funcio f_pe_excant_gar
 Paràmetres :
 - w_sseguro : Sseguro del rebut
 - w_nriesgo : Risc del rebut
 - w_cgarant : Garantia del rebut
 - w_fefecto : Efecte del rebut
 - w_fvencim : Venciment del rebut
 - w_excant  : Exercici anterior
 - w_fcierreproc: Data tancament de l'exercici anterior
 - w_fcierreefe: Darrer dia d'efecte de l'exercici anterior ('3112yyyy')
 - p_moneda  : Moneda
 - w_pe_excant_gar : Part de la prima emesa del rebut, que correspon a l'exercici anterior
 -                   per risc i garantia
******************************************************************************************/
      l_pnoe         ventascontab.itotcon%TYPE;   --       l_pnoe         NUMBER(15, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      l_error        NUMBER;
      l_dies         NUMBER(4);
   BEGIN
      w_pe_excant_gar := 0;
      l_error := f_pnoe_excant_gar(w_sseguro, w_nriesgo, w_cgarant, w_excant, w_fcierreefe,
                                   w_fcierreproc, p_moneda, l_pnoe);

      IF l_error = 0 THEN
         l_error := f_difdata(w_fefecto, w_fvencim, 1, 3, l_dies);

         IF l_error = 0 THEN
            w_pe_excant_gar := f_round(l_pnoe * l_dies, p_moneda);
         END IF;
      END IF;

      RETURN l_error;
   END f_pe_excant_gar;

-------------------------------------------------------------------------------------------------
   FUNCTION f_vanu_excant(
      w_sseguro IN NUMBER,
      w_excant IN NUMBER,
      w_fcierreefe IN DATE,
      w_fanulac IN DATE,
      p_moneda IN NUMBER,
      w_vanu_excant OUT NUMBER)
      RETURN NUMBER IS
/******************************************************************************************
 Funcio f_vanu_excant
 Paràmetres :
 - w_sseguro : Sseguro del rebut
 - w_excant  : Exercici anterior
 - w_fcierreproc : Data de tancament de l'exercici anterior
 - w_fanulac : Fecha de efecto de anulación de la póliza
 - p_moneda  : Moneda
 - w_vanu_excant : Part de la venda anulada, que correspon a l'exercici anterior
******************************************************************************************/
      l_pan_excant   NUMBER;   /* NUMBER(15, 2);     */
      l_error        NUMBER;
      l_dies         NUMBER(4);
      l_frenova      DATE;
      dummy1         NUMBER;
      l_ipemiti      ventascontab.ipemiti%TYPE := 0;   --       l_ipemiti      NUMBER := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      l_error := f_renovapost(w_sseguro, w_excant, l_frenova);

      IF l_frenova IS NULL THEN   -- Si no hemos conseguido localizar una fecha
                                  -- pasaremos las fechas para que no prorratee
         l_frenova := w_fanulac;
      END IF;

      IF l_error = 0 THEN
         IF l_frenova <= w_fanulac THEN
            w_vanu_excant := 0;
         ELSE
            l_error := f_trasllat_prima(w_sseguro, w_fanulac, l_frenova, w_fcierreefe,
                                        p_moneda, l_pan_excant, dummy1);

            BEGIN
               SELECT ipemiti
                 INTO l_ipemiti
                 FROM ventascontab
                WHERE nmesven = 0
                  AND nanyven = w_excant + 1
                  AND cexerci = 0
                  AND sseguro = w_sseguro;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  l_ipemiti := 0;
               WHEN OTHERS THEN
                  l_error := 108183;
            END;

-- Como máximo se puede anular lo que estaba pend. de emitir a 31/12
            IF l_pan_excant > l_ipemiti THEN
               w_vanu_excant := l_ipemiti;
            ELSE
               w_vanu_excant := l_pan_excant;
            END IF;
         END IF;
      END IF;

      RETURN l_error;
   END f_vanu_excant;

--------------------------------------------------------------------------------------------
   FUNCTION f_vanu_excant_gar(
      w_sseguro IN NUMBER,
      w_cgarant IN NUMBER,
      w_nriesgo IN NUMBER,
      w_excant IN NUMBER,
      w_fcierreefe IN DATE,
      w_fanulac IN DATE,
      p_moneda IN NUMBER,
      w_vanu_excant OUT NUMBER)
      RETURN NUMBER IS
/******************************************************************************************
 Funcio f_vanu_excant
 Paràmetres :
 - w_sseguro : Sseguro del rebut
 - w_cgarant : Garantia
 - w_excant  : Exercici anterior
 - w_fcierreproc : Data de tancament de l'exercici anterior
 - w_fanulac : Fecha de efecto de anulación de la póliza
 - p_moneda  : Moneda
 - w_vanu_excant : Part de la venda anulada de la garantia, que correspon a l'exercici anterior
******************************************************************************************/
      l_pan_excant   NUMBER;   /*  NUMBER(15, 2);              */
      l_error        NUMBER;
      l_dies         NUMBER(4);
      l_frenova      DATE;
      dummy1         NUMBER;
   BEGIN
      l_error := f_renovapost(w_sseguro, w_excant, l_frenova);

      IF l_frenova IS NULL THEN   -- Si no hemos conseguido localizar una fecha
                                  -- pasaremos las fechas para que no prorratee
         l_frenova := w_fanulac;
      END IF;

      IF l_error = 0 THEN
         IF l_frenova <= w_fanulac THEN
            w_vanu_excant := 0;
         ELSE
            l_error := f_trasllat_prima_gar(w_sseguro, w_cgarant, w_nriesgo, w_fanulac,
                                            l_frenova, w_fcierreefe, p_moneda, l_pan_excant,
                                            dummy1);
            w_vanu_excant := l_pan_excant;
         END IF;
      END IF;

      RETURN l_error;
   END f_vanu_excant_gar;

------------------------------------------------------------------------------------------------
/*********************************************
FUNCIONES DEL CALCULO DE VENTAS DE CONTABILIDAD
***********************************************/
------------------------------------------------------------------------------------------------
   FUNCTION emitida_ejeant(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pfcierre IN DATE,
      text_error OUT VARCHAR2)
      RETURN NUMBER IS
/**********************************************************
  Cálculo de la prima emitida de ventas de años anteriores
***********************************************************/
      num_err        NUMBER := 0;
      text_error1    VARCHAR2(150);
      v_excant       NUMBER;
      v_excact       NUMBER;
      v_pe_excant    ventascontab.iprinet%TYPE;   --       v_pe_excant    NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_peremi       NUMBER;
      v_anyemi       ventascontab.nanyven%TYPE;   --       v_anyemi       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_mesemi       ventascontab.nmesven%TYPE;   --       v_mesemi       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_pe_excant_coa ventascontab.iprinet_coa%TYPE;   --       v_pe_excant_coa NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_itotcon_ant  ventascontab.itotcon%TYPE;   --       v_itotcon_ant  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_itotcon_coa_ant ventascontab.itotcon_coa%TYPE;   --       v_itotcon_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iips_ant     ventascontab.iips%TYPE;   --       v_iips_ant     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iips_coa_ant ventascontab.iips_coa%TYPE;   --       v_iips_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idgs_ant     ventascontab.idgs%TYPE;   --       v_idgs_ant     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idgs_coa_ant ventascontab.idgs_coa%TYPE;   --       v_idgs_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iarbitr_ant  ventascontab.iarbitr%TYPE;   --       v_iarbitr_ant  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iarbitr_coa_ant ventascontab.iarbitr_coa%TYPE;   --       v_iarbitr_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ifng_ant     ventascontab.ifng%TYPE;   --       v_ifng_ant     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ifng_coa_ant ventascontab.ifng_coa%TYPE;   --       v_ifng_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_irecfra_ant  ventascontab.irecfra%TYPE;   --       v_irecfra_ant  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_irecfra_coa_ant ventascontab.irecfra_coa%TYPE;   --       v_irecfra_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idtoom_ant   ventascontab.idtoom%TYPE;   --       v_idtoom_ant   NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idtoom_coa_ant ventascontab.idtoom_coa%TYPE;   --       v_idtoom_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iderreg_ant  ventascontab.iderreg%TYPE;   --       v_iderreg_ant  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iderreg_coa_ant NUMBER;
-- Para poder ejecutar la instruccion 'TRUNCATE'
      v_cursor       INTEGER;
      v_truncatemovventascontab VARCHAR2(40);
      v_numrows      INTEGER;

      CURSOR c_recibos IS
         SELECT mv.sseguro, DECODE(ctiprec, 9, 2, 1) tipo, r.cempres, mv.cramo, mv.cmodali,
                mv.ctipseg, mv.ccolect, mv.cactivi, mv.npoliza, mv.ncertif, mv.cagente,
                mv.cagrpro, mv.ctiprea, mv.ctipcoa, vdet.ipridev, vdet.iprinet, vdet.it1con,
                vdet.idgs, vdet.iips, vdet.iarbitr, vdet.ifng, vdet.irecfra, vdet.iderreg,
                vdet.idtoom, vdet.icedpdv, vdet.icednet, vdet.it2con, vdet.iceddgs,
                vdet.icedips, vdet.icedarb, vdet.icedfng, vdet.icedrfr, vdet.icedreg,
                vdet.iceddom, r.ctiprec, r.fefecto, r.fvencim, r.nrecibo, r.femisio,
                r.nperven
           FROM vdetrecibos vdet, recibos r, movventascontab mv
          WHERE r.sseguro = mv.sseguro
            AND r.nmovimi = mv.nmovimi
            AND r.ctiprec IN(0, 1, 3, 4, 9)
            AND r.femisio >= TO_DATE('0101' || v_excact, 'ddmmyyyy')
            AND r.femisio < pfcierre + 1
            AND r.nrecibo = vdet.nrecibo
            AND mv.sproces = psproces
            AND mv.cempres = pcempres;
   BEGIN
      text_error1 := '- FUNC. EMI. EJER. ANT. CONTAB - ';
      -- Calculamos cual es el ejercicio anterior, el ejercicio actual y
      -- la fecha de cierre del ejercicio anterior
      v_excact := TO_CHAR(pfcierre, 'yyyy');
      v_excant := v_excact - 1;

      -- Con este insert conseguimos saber todos los movimientos de seguro que tienen venta en
      -- el ejercicio anterior y recibos emitidos en el actual
      BEGIN
         INSERT INTO movventascontab
                     (sseguro, pdtoord, nanyven, nmesven, nmovimi, sproces, cramo, cmodali,
                      ctipseg, ccolect, cactivi, npoliza, ncertif, cagente, cagrpro, ctiprea,
                      ctipcoa, cempres)
            (SELECT DISTINCT m.sseguro, NVL(s.pdtoord, 0), 0, 0, m.nmovimi, psproces, s.cramo,
                             s.cmodali, s.ctipseg, s.ccolect, s.cactivi, s.npoliza, s.ncertif,
                             s.cagente, s.cagrpro, s.ctiprea, s.ctipcoa, s.cempres
                        FROM movseguro m, recibos r, seguros s
                       WHERE m.sseguro = r.sseguro
                         AND m.nmovimi = r.nmovimi
                         AND m.sseguro = s.sseguro
                         AND m.nanyven = v_excant
                         AND r.fefecto >=
                               TO_DATE('0101' || v_excant, 'ddmmyyyy')   -- recollim rebuts des de l'any anterior
                         AND r.fefecto < pfcierre + 1
                         AND s.cempres = pcempres);
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 108012;   -- Error al insertar en la tabla MOVVENTAS
            text_error := text_error1 || SQLERRM || '  ' || SQLCODE;
      END;

      -- Para cada registro calculamos los importes
      -- La select la hacemos con recibos con primas emitidas hasta el último día del mes que se
      -- está cerrando.
      FOR reg IN c_recibos LOOP
         v_peremi := reg.nperven;
         v_anyemi := ROUND(v_peremi / 100);
         v_mesemi := v_peremi - ROUND(v_peremi / 100) * 100;

         IF v_anyemi = v_excact THEN
            v_pe_excant := reg.iprinet;
            v_itotcon_ant := reg.it1con;
            v_iips_ant := reg.iips;
            v_idgs_ant := reg.idgs;
            v_iarbitr_ant := reg.iarbitr;
            v_ifng_ant := reg.ifng;
            v_irecfra_ant := reg.irecfra;
            v_idtoom_ant := reg.idtoom;
            v_iderreg_ant := reg.iderreg;
            -- Importes de coaseguro
            v_pe_excant_coa := reg.icednet;
            v_itotcon_coa_ant := reg.it2con;
            v_iips_coa_ant := reg.icedips;
            v_idgs_coa_ant := reg.iceddgs;
            v_iarbitr_coa_ant := reg.icedarb;
            v_ifng_coa_ant := reg.icedfng;
            v_irecfra_coa_ant := reg.icedrfr;
            v_idtoom_coa_ant := reg.iceddom;
            v_iderreg_coa_ant := reg.icedreg;

            IF pmodo IN(1, 2) THEN   -- si no es simulación grabamos en VENTASCONTAB
               BEGIN
                  -- Sólo grabamos si hay algún importe distinto de 0
                  IF v_pe_excant <> 0
                     OR v_itotcon_ant <> 0
                     OR v_iips_ant <> 0
                     OR v_idgs_ant <> 0
                     OR v_iarbitr_ant <> 0
                     OR v_ifng_ant <> 0
                     OR v_irecfra_ant <> 0
                     OR v_idtoom_ant <> 0
                     OR v_iderreg_ant <> 0
                     OR v_pe_excant_coa <> 0
                     OR v_itotcon_coa_ant <> 0
                     OR v_iips_coa_ant <> 0
                     OR v_idgs_ant <> 0
                     OR v_iarbitr_ant <> 0
                     OR v_ifng_ant <> 0
                     OR v_irecfra_ant <> 0
                     OR v_idtoom_ant <> 0
                     OR v_iderreg_ant <> 0 THEN
                     INSERT INTO ventascontab
                                 (sseguro, ctipo, cexerci, nanyven, nmesven, sproces,
                                  fcierre, fcalcul, cempres, cramo, cmodali,
                                  ctipseg, ccolect, cactivi, npoliza,
                                  ncertif, cagente, cagrpro, ctiprea,
                                  ctipcoa, ipridev, iprinet, ipemiti, itotcon,
                                  iips, idgs, iarbitr, ifng,
                                  irecfra, idtoom, iderreg, ipridev_coa,
                                  iprinet_coa, ipemiti_coa, itotcon_coa,
                                  iips_coa, idgs_coa, iarbitr_coa,
                                  ifng_coa, irecfra_coa, idtoom_coa,
                                  iderreg_coa)
                          VALUES (reg.sseguro, reg.tipo, 0, v_anyemi, v_mesemi, psproces,
                                  pfcierre, f_sysdate, reg.cempres, reg.cramo, reg.cmodali,
                                  reg.ctipseg, reg.ccolect, reg.cactivi, reg.npoliza,
                                  reg.ncertif, reg.cagente, reg.cagrpro, reg.ctiprea,
                                  reg.ctipcoa, 0, v_pe_excant, v_pe_excant, v_itotcon_ant,
                                  v_iips_ant, v_idgs_ant, v_iarbitr_ant, v_ifng_ant,
                                  v_irecfra_ant, v_idtoom_ant, v_iderreg_ant, 0,
                                  v_pe_excant_coa, v_pe_excant_coa, v_itotcon_coa_ant,
                                  v_iips_coa_ant, v_idgs_coa_ant, v_iarbitr_coa_ant,
                                  v_ifng_coa_ant, v_irecfra_coa_ant, v_idtoom_coa_ant,
                                  v_iderreg_coa_ant);
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := 111112;   -- Error al insertar en la tabla VENTASCONTAB
                     text_error := text_error1 || 'recibo =' || reg.nrecibo || ' ' || SQLERRM
                                   || ' ' || SQLCODE;
               END;
            ELSIF pmodo = 3 THEN   -- simulación
               BEGIN
                  -- Sólo grabamos si hay algún importe distinto de 0
                  IF v_pe_excant <> 0
                     OR v_itotcon_ant <> 0
                     OR v_iips_ant <> 0
                     OR v_idgs_ant <> 0
                     OR v_iarbitr_ant <> 0
                     OR v_ifng_ant <> 0
                     OR v_irecfra_ant <> 0
                     OR v_idtoom_ant <> 0
                     OR v_iderreg_ant <> 0
                     OR v_pe_excant_coa <> 0
                     OR v_itotcon_coa_ant <> 0
                     OR v_iips_coa_ant <> 0
                     OR v_idgs_ant <> 0
                     OR v_iarbitr_ant <> 0
                     OR v_ifng_ant <> 0
                     OR v_irecfra_ant <> 0
                     OR v_idtoom_ant <> 0
                     OR v_iderreg_ant <> 0 THEN
                     INSERT INTO ventascontabaux
                                 (sseguro, ctipo, cexerci, nanyven, nmesven, sproces,
                                  fcierre, fcalcul, cempres, cramo, cmodali,
                                  ctipseg, ccolect, cactivi, npoliza,
                                  ncertif, cagente, cagrpro, ctiprea,
                                  ctipcoa, ipridev, iprinet, ipemiti, itotcon,
                                  iips, idgs, iarbitr, ifng,
                                  irecfra, idtoom, iderreg, ipridev_coa,
                                  iprinet_coa, ipemiti_coa, itotcon_coa,
                                  iips_coa, idgs_coa, iarbitr_coa,
                                  ifng_coa, irecfra_coa, idtoom_coa,
                                  iderreg_coa)
                          VALUES (reg.sseguro, reg.tipo, 0, v_anyemi, v_mesemi, psproces,
                                  pfcierre, f_sysdate, reg.cempres, reg.cramo, reg.cmodali,
                                  reg.ctipseg, reg.ccolect, reg.cactivi, reg.npoliza,
                                  reg.ncertif, reg.cagente, reg.cagrpro, reg.ctiprea,
                                  reg.ctipcoa, 0, v_pe_excant, v_pe_excant, v_itotcon_ant,
                                  v_iips_ant, v_idgs_ant, v_iarbitr_ant, v_ifng_ant,
                                  v_irecfra_ant, v_idtoom_ant, v_iderreg_ant, 0,
                                  v_pe_excant_coa, v_pe_excant_coa, v_itotcon_coa_ant,
                                  v_iips_coa_ant, v_idgs_coa_ant, v_iarbitr_coa_ant,
                                  v_ifng_coa_ant, v_irecfra_coa_ant, v_idtoom_coa_ant,
                                  v_iderreg_coa_ant);
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := 111113;   -- Error al insertar en la tabla VENTASCONTABAUX
                     text_error := text_error1 || 'recibo =' || reg.nrecibo || ' ' || SQLERRM
                                   || ' ' || SQLCODE;
               END;
            END IF;
         END IF;

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END LOOP;

      -- Borramos el contenido de la tabla MOVVENTASCONTAB
      BEGIN
         -- Para poder ejecutar la instruccion 'TRUNCATE'
         v_cursor := DBMS_SQL.open_cursor;
         v_truncatemovventascontab := 'TRUNCATE TABLE MOVVENTASCONTAB';
         DBMS_SQL.parse(v_cursor, v_truncatemovventascontab, DBMS_SQL.native);
         v_numrows := DBMS_SQL.EXECUTE(v_cursor);
         DBMS_SQL.close_cursor(v_cursor);
      EXCEPTION
         WHEN OTHERS THEN
            IF DBMS_SQL.is_open(v_cursor) THEN
               DBMS_SQL.close_cursor(v_cursor);
            END IF;

            RETURN 108017;   -- Error al borrar las tablas
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         num_err := 444444;
         text_error := text_error1 || SQLERRM;
         RETURN num_err;
   END emitida_ejeant;

-------------------------------------------------------------------------------------------------
   FUNCTION fecha_calculo(
      pcempres IN NUMBER,
      pmodo IN NUMBER,
      pfcierre OUT DATE,
      pnmesven OUT NUMBER,
      pnanyven OUT NUMBER)
      RETURN NUMBER IS
/***********************************************************************************************
   Devuelve el mes y año para el cual hay que calcular las ventas de cada empresa.
        pmodo = 1 ==> Proceso diario, por lo tanto, será el mes siguiente al último cierre
                      que tenemos en CIERRES
        pmodo = 2 ==> Cierre definitivo, por lo tanto, será el último cierre
                      que tenemos en CIERRES para el ctipo = 1(Cierres de Ventas),
                      pero no está cerrado
        pmodo = 3 ==> Simulación cierre, por lo tanto, será el mes siguiente al último cierre
                      que tenemos en CIERRES
************************************************************************************************/
      num_err        NUMBER := 0;
   BEGIN
      IF pmodo IN(1, 3) THEN
         SELECT ADD_MONTHS(MAX(fperfin), 1), TO_NUMBER(TO_CHAR(MAX(fperfin) + 1, 'mm')),
                TO_NUMBER(TO_CHAR(MAX(fperfin) + 1, 'yyyy'))
           INTO pfcierre, pnmesven,
                pnanyven
           FROM cierres
          WHERE cempres = pcempres
            AND ctipo = 1
            AND cestado = 1;
      ELSIF pmodo = 2 THEN
         SELECT MAX(fperfin), TO_NUMBER(TO_CHAR(MAX(fperfin), 'mm')),
                TO_NUMBER(TO_CHAR(MAX(fperfin), 'yyyy'))
           INTO pfcierre, pnmesven,
                pnanyven
           FROM cierres
          WHERE ctipo = 1
            AND cempres = pcempres;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         num_err := 105511;   -- Error de lectura en CIERRES
         RETURN num_err;
   END fecha_calculo;

-------------------------------------------------------------------------------------------------
   FUNCTION f_rec_en_exact(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pexcant IN NUMBER,
      todo_en_ejercicio_actual OUT BOOLEAN)
      RETURN NUMBER IS
/*********************************************************************************************
 Devuelve TRUE si el recibo pertenece todo al ejercio actual o debe repartirse su prima.
**********************************************************************************************/
      num_err        NUMBER := 0;
      l_nmovimi      NUMBER;
   BEGIN
      todo_en_ejercicio_actual := TRUE;

      SELECT MAX(nmovimi)
        INTO l_nmovimi
        FROM movseguro
       WHERE sseguro = psseguro
         AND nmovimi <= pnmovimi
         AND cmovseg = 2
         AND nanyven = pexcant + 1;

      IF l_nmovimi IS NULL THEN
         todo_en_ejercicio_actual := FALSE;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         num_err := 104349;   -- Error al leer de la tabla MOVSEGURO
         RETURN num_err;
   END f_rec_en_exact;

-------------------------------------------------------------------------------------------------
   FUNCTION venta_generada(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pnmesven IN NUMBER,
      pnanyven IN NUMBER,
      psproces IN NUMBER,
      pfcierre IN DATE,
      pfcalcul IN DATE,
      pmoneda IN NUMBER,
      text_error OUT VARCHAR2)
      RETURN NUMBER IS
/*********************************************************************************************
 En este proceso se calculan las ventas generadas Y PRIMAS EMITIDAS, sin anulaciones,
 es decir,ventas de nueva producción, suplementos(pueden ser extornos),
 cartera y aportaciones extraordinarias.
**********************************************************************************************/
      num_err        NUMBER := 0;
      text_error1    VARCHAR2(150);

      CURSOR c_recibos IS
         SELECT mv.sseguro, DECODE(ctiprec, 9, 2, 1) tipo, mv.nanyven, mv.nmesven, r.cempres,
                mv.cramo, mv.cmodali, mv.ctipseg, mv.ccolect, mv.cactivi, mv.npoliza,
                mv.ncertif, mv.cagente, mv.cagrpro, mv.ctiprea, mv.ctipcoa, vdet.ipridev,
                vdet.iprinet, vdet.it1con, vdet.idgs, vdet.iips, vdet.iarbitr, vdet.ifng,
                vdet.irecfra, vdet.iderreg, vdet.idtoom, vdet.icedpdv, vdet.icednet,
                vdet.it2con, vdet.iceddgs, vdet.icedips, vdet.icedarb, vdet.icedfng,
                vdet.icedrfr, vdet.icedreg, vdet.iceddom, r.ctiprec, r.fefecto, r.fvencim,
                r.nrecibo, r.nmovimi
           FROM vdetrecibos vdet, recibos r, movventascontab mv
          WHERE r.sseguro = mv.sseguro
            AND r.nmovimi = mv.nmovimi
            AND r.ctiprec IN(0, 1, 3, 4, 9)
            AND DECODE(r.ctiprec, 3, r.fefecto, TO_DATE('01011900', 'ddmmyyyy')) <= pfcierre
            AND r.nrecibo = vdet.nrecibo
            AND mv.sproces = psproces
            AND mv.cempres = pcempres;

      v_excant       NUMBER;
      v_excact       NUMBER;
      v_fcierre_excant_proc DATE;
      v_fcierre_excant_efe DATE;
      v_pe_excant    ventascontab.iprinet%TYPE;   --       v_pe_excant    NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_pe_excact    ventascontab.iprinet%TYPE;   --       v_pe_excact    NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      coefic         NUMBER;
      v_pe_excant_coa ventascontab.iprinet_coa%TYPE;   --       v_pe_excant_coa NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_pe_excact_coa ventascontab.iprinet_coa%TYPE;   --       v_pe_excact_coa NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_itotcon_ant  ventascontab.itotcon%TYPE;   --       v_itotcon_ant  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_itotcon_coa_ant ventascontab.itotcon_coa%TYPE;   --       v_itotcon_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iips_ant     ventascontab.iips%TYPE;   --       v_iips_ant     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iips_coa_ant ventascontab.iips_coa%TYPE;   --       v_iips_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idgs_ant     ventascontab.idgs%TYPE;   --       v_idgs_ant     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idgs_coa_ant ventascontab.idgs_coa%TYPE;   --       v_idgs_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iarbitr_ant  ventascontab.iarbitr%TYPE;   --       v_iarbitr_ant  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iarbitr_coa_ant ventascontab.iarbitr_coa%TYPE;   --       v_iarbitr_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ifng_ant     ventascontab.ifng%TYPE;   --       v_ifng_ant     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ifng_coa_ant ventascontab.ifng_coa%TYPE;   --       v_ifng_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_irecfra_ant  ventascontab.irecfra%TYPE;   --       v_irecfra_ant  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_irecfra_coa_ant ventascontab.irecfra_coa%TYPE;   --       v_irecfra_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idtoom_ant   ventascontab.idtoom%TYPE;   --       v_idtoom_ant   NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idtoom_coa_ant ventascontab.idtoom_coa%TYPE;   --       v_idtoom_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iderreg_ant  ventascontab.iderreg%TYPE;   --       v_iderreg_ant  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iderreg_coa_ant NUMBER;
      v_itotcon_act  ventascontab.itotcon%TYPE;   --       v_itotcon_act  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_itotcon_coa_act ventascontab.itotcon_coa%TYPE;   --       v_itotcon_coa_act NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iips_act     ventascontab.iips%TYPE;   --       v_iips_act     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iips_coa_act ventascontab.iips_coa%TYPE;   --       v_iips_coa_act NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idgs_act     ventascontab.idgs%TYPE;   --       v_idgs_act     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idgs_coa_act ventascontab.idgs_coa%TYPE;   --       v_idgs_coa_act NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iarbitr_act  ventascontab.iarbitr%TYPE;   --       v_iarbitr_act  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iarbitr_coa_act ventascontab.iarbitr_coa%TYPE;   --       v_iarbitr_coa_act NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ifng_act     ventascontab.ifng%TYPE;   --       v_ifng_act     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ifng_coa_act ventascontab.ifng_coa%TYPE;   --       v_ifng_coa_act NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_irecfra_act  ventascontab.irecfra%TYPE;   --       v_irecfra_act  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_irecfra_coa_act ventascontab.irecfra_coa%TYPE;   --       v_irecfra_coa_act NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idtoom_act   ventascontab.idtoom%TYPE;   --       v_idtoom_act   NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idtoom_coa_act ventascontab.idtoom_coa%TYPE;   --       v_idtoom_coa_act NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iderreg_act  ventascontab.iderreg%TYPE;   --       v_iderreg_act  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iderreg_coa_act NUMBER;
      todo_en_ejercicio_actual BOOLEAN;
   BEGIN
      text_error1 := '- FUNC. VENTAS GENER. CONTAB - ';
      -- Calculamos cual es el ejercicio anterior, el ejercicio actual y
      -- la fecha de cierre del ejercicio anterior
      v_excact := TO_CHAR(pfcierre, 'yyyy');
      v_excant := v_excact - 1;
      v_fcierre_excant_efe := TO_DATE('3112' || v_excant, 'ddmmyyyy');

      BEGIN
         SELECT fcierre
           INTO v_fcierre_excant_proc
           FROM cierres
          WHERE ctipo = 1
            AND cestado = 1
            AND cempres = pcempres
            AND fperfin = TO_DATE('3112' || v_excant, 'ddmmyyyy');
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 111111;   -- Error al calcular la fecha de cierre del ejercicio anterior
            text_error := text_error1 || SQLERRM || ' ' || SQLCODE;
            RETURN num_err;
      END;

      -- Con este insert conseguimos saber todos los movimientos de seguro que tienen venta en
      -- los meses que nos interesan
      BEGIN
         INSERT INTO movventascontab
                     (sseguro, pdtoord, nanyven, nmesven, nmovimi, sproces, cramo, cmodali,
                      ctipseg, ccolect, cactivi, npoliza, ncertif, cagente, cagrpro, ctiprea,
                      ctipcoa, cempres)
            (SELECT m.sseguro, NVL(s.pdtoord, 0), m.nanyven, m.nmesven, nmovimi, psproces,
                    s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, s.npoliza, s.ncertif,
                    s.cagente, s.cagrpro, s.ctiprea, s.ctipcoa, s.cempres
               FROM movseguro m, seguros s
              WHERE s.cempres = pcempres
                AND s.sseguro = m.sseguro
                AND m.cmovseg <> 3
                AND m.nmesven BETWEEN 1 AND pnmesven   -- en ventas contabilidad se calculan las ventas desde enero
                AND m.nanyven = pnanyven);
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 108012;   -- Error al insertar en la tabla MOVVENTAS
            text_error := text_error1 || SQLERRM || '  ' || SQLCODE;
      END;

      -- Para cada registro calculamos los importes
      -- La select la hacemos con recibos con primas emitidas hasta el último día del mes que se
      -- está cerrando.
      FOR reg IN c_recibos LOOP
         -- Tenemos que hacer el reparto entre el ejercicio anterior y el ejercicio actual
         IF reg.ctiprec = 3
            AND reg.ipridev = 0 THEN
            num_err := f_rec_en_exact(reg.sseguro, reg.nmovimi, v_excant,
                                      todo_en_ejercicio_actual);

            IF num_err <> 0 THEN
               text_error := text_error1 || 'recibo =' || reg.nrecibo;
               RETURN num_err;
            END IF;
         ELSE
            todo_en_ejercicio_actual := TRUE;
         END IF;

-- Si el recibo es de cartera, tenemos que hacer el reparto
-- entre ejercicio anterior y actual. Si es de otro tipo (suplemento,
-- nueva producción,... la prima emitida siempre es del ejercicio actual
         IF NOT todo_en_ejercicio_actual THEN
            num_err := f_pe_excant(reg.sseguro, reg.fefecto, reg.fvencim, v_excant,
                                   v_fcierre_excant_efe, v_fcierre_excant_proc, pmoneda,
                                   v_pe_excant);
         ELSE
            v_pe_excant := 0;   -- no hay prima emitida del ejercicio anterior
         END IF;

         IF num_err <> 0 THEN
            text_error := text_error1 || 'recibo =' || reg.nrecibo;
            RETURN num_err;
         END IF;

         IF v_pe_excant <> 0
            AND reg.iprinet <> 0 THEN
            coefic := v_pe_excant / reg.iprinet;
            v_itotcon_ant := coefic * reg.it1con;
            v_iips_ant := coefic * reg.iips;
            v_idgs_ant := coefic * reg.idgs;
            v_iarbitr_ant := coefic * reg.iarbitr;
            v_ifng_ant := coefic * reg.ifng;
            v_irecfra_ant := coefic * reg.irecfra;
            v_idtoom_ant := coefic * reg.idtoom;
            v_iderreg_ant := coefic * reg.iderreg;
            -- Importes de coaseguro
            v_pe_excant_coa := coefic * reg.icednet;
            v_itotcon_coa_ant := coefic * reg.it2con;
            v_iips_coa_ant := coefic * reg.icedips;
            v_idgs_coa_ant := coefic * reg.iceddgs;
            v_iarbitr_coa_ant := coefic * reg.icedarb;
            v_ifng_coa_ant := coefic * reg.icedfng;
            v_irecfra_coa_ant := coefic * reg.icedrfr;
            v_idtoom_coa_ant := coefic * reg.iceddom;
            v_iderreg_coa_ant := coefic * reg.icedreg;
         ELSE
            v_itotcon_ant := 0;
            v_iips_ant := 0;
            v_idgs_ant := 0;
            v_iarbitr_ant := 0;
            v_ifng_ant := 0;
            v_irecfra_ant := 0;
            v_idtoom_ant := 0;
            v_iderreg_ant := 0;
            -- Importes de coaseguro
            v_pe_excant_coa := 0;
            v_itotcon_coa_ant := 0;
            v_iips_coa_ant := 0;
            v_idgs_coa_ant := 0;
            v_iarbitr_coa_ant := 0;
            v_ifng_coa_ant := 0;
            v_irecfra_coa_ant := 0;
            v_idtoom_coa_ant := 0;
            v_iderreg_coa_ant := 0;
         END IF;

         v_pe_excact := reg.iprinet - v_pe_excant;
         v_itotcon_act := reg.it1con - v_itotcon_ant;
         v_iips_act := reg.iips - v_iips_ant;
         v_idgs_act := reg.idgs - v_idgs_ant;
         v_iarbitr_act := reg.iarbitr - v_iarbitr_ant;
         v_ifng_act := reg.ifng - v_ifng_ant;
         v_irecfra_act := reg.irecfra - v_irecfra_ant;
         v_idtoom_act := reg.idtoom - v_idtoom_ant;
         v_iderreg_act := reg.iderreg - v_iderreg_ant;
         v_pe_excact_coa := reg.icednet - v_pe_excant_coa;
         v_itotcon_coa_act := reg.it2con - v_itotcon_coa_ant;
         v_iips_coa_act := reg.icedips - v_iips_coa_ant;
         v_idgs_coa_act := reg.iceddgs - v_idgs_coa_ant;
         v_iarbitr_coa_act := reg.icedarb - v_iarbitr_coa_ant;
         v_ifng_coa_act := reg.icedfng - v_ifng_coa_ant;
         v_irecfra_coa_act := reg.icedrfr - v_irecfra_coa_ant;
         v_idtoom_coa_act := reg.iceddom - v_idtoom_coa_ant;
         v_iderreg_coa_act := reg.icedreg - v_iderreg_coa_ant;

         IF pmodo IN(1, 2) THEN   -- si no es simulación grabamos en VENTASCONTAB
            BEGIN
               -- Sólo grabamos si hay algún importe distinto de 0
               IF v_pe_excant <> 0
                  OR v_itotcon_ant <> 0
                  OR v_iips_ant <> 0
                  OR v_idgs_ant <> 0
                  OR v_iarbitr_ant <> 0
                  OR v_ifng_ant <> 0
                  OR v_irecfra_ant <> 0
                  OR v_idtoom_ant <> 0
                  OR v_iderreg_ant <> 0
                  OR v_pe_excant_coa <> 0
                  OR v_itotcon_coa_ant <> 0
                  OR v_iips_coa_ant <> 0
                  OR v_idgs_ant <> 0
                  OR v_iarbitr_ant <> 0
                  OR v_ifng_ant <> 0
                  OR v_irecfra_ant <> 0
                  OR v_idtoom_ant <> 0
                  OR v_iderreg_ant <> 0 THEN
                  INSERT INTO ventascontab
                              (sseguro, ctipo, cexerci, nanyven, nmesven, sproces,
                               fcierre, fcalcul, cempres, cramo, cmodali,
                               ctipseg, ccolect, cactivi, npoliza,
                               ncertif, cagente, cagrpro, ctiprea,
                               ctipcoa, ipridev, iprinet, ipemiti, itotcon,
                               iips, idgs, iarbitr, ifng,
                               irecfra, idtoom, iderreg, ipridev_coa,
                               iprinet_coa, ipemiti_coa, itotcon_coa,
                               iips_coa, idgs_coa, iarbitr_coa,
                               ifng_coa, irecfra_coa, idtoom_coa,
                               iderreg_coa)
                       VALUES (reg.sseguro, reg.tipo, 0, reg.nanyven, reg.nmesven, psproces,
                               pfcierre, f_sysdate, reg.cempres, reg.cramo, reg.cmodali,
                               reg.ctipseg, reg.ccolect, reg.cactivi, reg.npoliza,
                               reg.ncertif, reg.cagente, reg.cagrpro, reg.ctiprea,
                               reg.ctipcoa, 0, v_pe_excant, v_pe_excant, v_itotcon_ant,
                               v_iips_ant, v_idgs_ant, v_iarbitr_ant, v_ifng_ant,
                               v_irecfra_ant, v_idtoom_ant, v_iderreg_ant, 0,
                               v_pe_excant_coa, v_pe_excant_coa, v_itotcon_coa_ant,
                               v_iips_coa_ant, v_idgs_coa_ant, v_iarbitr_coa_ant,
                               v_ifng_coa_ant, v_irecfra_coa_ant, v_idtoom_coa_ant,
                               v_iderreg_coa_ant);
               END IF;

               IF v_pe_excact <> 0
                  OR v_itotcon_act <> 0
                  OR v_iips_act <> 0
                  OR v_idgs_act <> 0
                  OR v_iarbitr_act <> 0
                  OR v_ifng_act <> 0
                  OR v_irecfra_act <> 0
                  OR v_idtoom_act <> 0
                  OR v_iderreg_act <> 0
                  OR v_pe_excact_coa <> 0
                  OR v_itotcon_coa_act <> 0
                  OR v_iips_coa_act <> 0
                  OR v_idgs_act <> 0
                  OR v_iarbitr_act <> 0
                  OR v_ifng_act <> 0
                  OR v_irecfra_act <> 0
                  OR v_idtoom_act <> 0
                  OR v_iderreg_act <> 0
                  OR reg.ipridev <> 0
                  OR reg.icedpdv <> 0 THEN
                  INSERT INTO ventascontab
                              (sseguro, ctipo, cexerci, nanyven, nmesven, sproces,
                               fcierre, fcalcul, cempres, cramo, cmodali,
                               ctipseg, ccolect, cactivi, npoliza,
                               ncertif, cagente, cagrpro, ctiprea,
                               ctipcoa, ipridev, iprinet, ipemiti,
                               itotcon, iips, idgs, iarbitr,
                               ifng, irecfra, idtoom, iderreg,
                               ipridev_coa, iprinet_coa, ipemiti_coa,
                               itotcon_coa, iips_coa, idgs_coa,
                               iarbitr_coa, ifng_coa, irecfra_coa,
                               idtoom_coa, iderreg_coa)
                       VALUES (reg.sseguro, reg.tipo, 1, reg.nanyven, reg.nmesven, psproces,
                               pfcierre, f_sysdate, reg.cempres, reg.cramo, reg.cmodali,
                               reg.ctipseg, reg.ccolect, reg.cactivi, reg.npoliza,
                               reg.ncertif, reg.cagente, reg.cagrpro, reg.ctiprea,
                               reg.ctipcoa, reg.ipridev, v_pe_excact, v_pe_excact,
                               v_itotcon_act, v_iips_act, v_idgs_act, v_iarbitr_act,
                               v_ifng_act, v_irecfra_act, v_idtoom_act, v_iderreg_act,
                               reg.icedpdv, v_pe_excact_coa, v_pe_excact_coa,
                               v_itotcon_coa_act, v_iips_coa_act, v_idgs_coa_act,
                               v_iarbitr_coa_act, v_ifng_coa_act, v_irecfra_coa_act,
                               v_idtoom_coa_act, v_iderreg_coa_act);
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := 1112;   -- Error al insertar en la tabla VENTASCONTAB
                  text_error := text_error1 || 'recibo =' || reg.nrecibo || ' ' || SQLERRM
                                || ' ' || SQLCODE;
            END;
         ELSIF pmodo = 3 THEN   -- simulación
            BEGIN
               -- Sólo grabamos si hay algún importe distinto de 0
               IF v_pe_excant <> 0
                  OR v_itotcon_ant <> 0
                  OR v_iips_ant <> 0
                  OR v_idgs_ant <> 0
                  OR v_iarbitr_ant <> 0
                  OR v_ifng_ant <> 0
                  OR v_irecfra_ant <> 0
                  OR v_idtoom_ant <> 0
                  OR v_iderreg_ant <> 0
                  OR v_pe_excant_coa <> 0
                  OR v_itotcon_coa_ant <> 0
                  OR v_iips_coa_ant <> 0
                  OR v_idgs_ant <> 0
                  OR v_iarbitr_ant <> 0
                  OR v_ifng_ant <> 0
                  OR v_irecfra_ant <> 0
                  OR v_idtoom_ant <> 0
                  OR v_iderreg_ant <> 0 THEN
                  INSERT INTO ventascontabaux
                              (sseguro, ctipo, cexerci, nanyven, nmesven, sproces,
                               fcierre, fcalcul, cempres, cramo, cmodali,
                               ctipseg, ccolect, cactivi, npoliza,
                               ncertif, cagente, cagrpro, ctiprea,
                               ctipcoa, ipridev, iprinet, ipemiti, itotcon,
                               iips, idgs, iarbitr, ifng,
                               irecfra, idtoom, iderreg, ipridev_coa,
                               iprinet_coa, ipemiti_coa, itotcon_coa,
                               iips_coa, idgs_coa, iarbitr_coa,
                               ifng_coa, irecfra_coa, idtoom_coa,
                               iderreg_coa)
                       VALUES (reg.sseguro, reg.tipo, 0, reg.nanyven, reg.nmesven, psproces,
                               pfcierre, f_sysdate, reg.cempres, reg.cramo, reg.cmodali,
                               reg.ctipseg, reg.ccolect, reg.cactivi, reg.npoliza,
                               reg.ncertif, reg.cagente, reg.cagrpro, reg.ctiprea,
                               reg.ctipcoa, 0, v_pe_excant, v_pe_excant, v_itotcon_ant,
                               v_iips_ant, v_idgs_ant, v_iarbitr_ant, v_ifng_ant,
                               v_irecfra_ant, v_idtoom_ant, v_iderreg_ant, 0,
                               v_pe_excant_coa, v_pe_excant_coa, v_itotcon_coa_ant,
                               v_iips_coa_ant, v_idgs_coa_ant, v_iarbitr_coa_ant,
                               v_ifng_coa_ant, v_irecfra_coa_ant, v_idtoom_coa_ant,
                               v_iderreg_coa_ant);
               END IF;

               IF v_pe_excact <> 0
                  OR v_itotcon_act <> 0
                  OR v_iips_act <> 0
                  OR v_idgs_act <> 0
                  OR v_iarbitr_act <> 0
                  OR v_ifng_act <> 0
                  OR v_irecfra_act <> 0
                  OR v_idtoom_act <> 0
                  OR v_iderreg_act <> 0
                  OR v_pe_excact_coa <> 0
                  OR v_itotcon_coa_act <> 0
                  OR v_iips_coa_act <> 0
                  OR v_idgs_act <> 0
                  OR v_iarbitr_act <> 0
                  OR v_ifng_act <> 0
                  OR v_irecfra_act <> 0
                  OR v_idtoom_act <> 0
                  OR v_iderreg_ant <> 0
                  OR reg.ipridev <> 0
                  OR reg.icedpdv <> 0 THEN
                  INSERT INTO ventascontabaux
                              (sseguro, ctipo, cexerci, nanyven, nmesven, sproces,
                               fcierre, fcalcul, cempres, cramo, cmodali,
                               ctipseg, ccolect, cactivi, npoliza,
                               ncertif, cagente, cagrpro, ctiprea,
                               ctipcoa, ipridev, iprinet, ipemiti,
                               itotcon, iips, idgs, iarbitr,
                               ifng, irecfra, idtoom, iderreg,
                               ipridev_coa, iprinet_coa, ipemiti_coa,
                               itotcon_coa, iips_coa, idgs_coa,
                               iarbitr_coa, ifng_coa, irecfra_coa,
                               idtoom_coa, iderreg_coa)
                       VALUES (reg.sseguro, reg.tipo, 1, reg.nanyven, reg.nmesven, psproces,
                               pfcierre, f_sysdate, reg.cempres, reg.cramo, reg.cmodali,
                               reg.ctipseg, reg.ccolect, reg.cactivi, reg.npoliza,
                               reg.ncertif, reg.cagente, reg.cagrpro, reg.ctiprea,
                               reg.ctipcoa, reg.ipridev, v_pe_excact, v_pe_excact,
                               v_itotcon_act, v_iips_act, v_idgs_act, v_iarbitr_act,
                               v_ifng_act, v_irecfra_act, v_idtoom_act, v_iderreg_act,
                               reg.icedpdv, v_pe_excact_coa, v_pe_excact_coa,
                               v_itotcon_coa_act, v_iips_coa_act, v_idgs_coa_act,
                               v_iarbitr_coa_act, v_ifng_coa_act, v_irecfra_coa_act,
                               v_idtoom_coa_act, v_iderreg_coa_act);
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := 111113;   -- Error al insertar en la tabla VENTASCONTABAUX
                  text_error := text_error1 || 'recibo =' || reg.nrecibo || ' ' || SQLERRM
                                || ' ' || SQLCODE;
            END;
         END IF;

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END LOOP;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         num_err := 444444;
         text_error := text_error1 || SQLERRM;
         RETURN num_err;
   END venta_generada;

-------------------------------------------------------------------------------------------------
   FUNCTION fecha_venta_recibo(
      pnrecibo IN NUMBER,
      psseguro IN NUMBER,
      pctiprec IN NUMBER,
      pnmovimi IN NUMBER,
      rec_nmesven OUT NUMBER,
      rec_nanyven OUT NUMBER,
      text_error OUT VARCHAR2)
      RETURN NUMBER IS
/***********************************************************************************************
 Calculamos el año de la venta del movimiento al cual pertenece el recibo
 Podemos entrar por nº de recibo, o por sseguro, tipo de recibo y movimiento
************************************************************************************************/
      v_sseguro      recibos.sseguro%TYPE;   --       v_sseguro      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ctiprec      recibos.ctiprec%TYPE;   --       v_ctiprec      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_nmovimi      recibos.nmovimi%TYPE;   --       v_nmovimi      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_fefecto      recibos.fefecto%TYPE;   --       v_fefecto      DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      num_err        NUMBER := 0;
   BEGIN
      IF pnrecibo IS NULL
         AND pctiprec IS NULL
         AND pnmovimi IS NULL
         AND psseguro IS NULL THEN
         num_err := 101901;   -- Paso incorrecto de parámetros a la función
         text_error := 'fecha_venta_recibo';
      ELSE
         IF pnrecibo IS NOT NULL THEN
            BEGIN
               SELECT ctiprec, nmovimi, sseguro, fefecto
                 INTO v_ctiprec, v_nmovimi, v_sseguro, v_fefecto
                 FROM recibos
                WHERE nrecibo = pnrecibo;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := 101902;   -- Recibo no encontrado en la tabla recibos
                  text_error := 'función fecha_venta_recibo';
            END;
         ELSE
            v_ctiprec := pctiprec;
            v_nmovimi := pnmovimi;
            v_sseguro := psseguro;
         END IF;

         IF v_ctiprec IN(0, 3) THEN   -- si el recibo es de nueva prod. o cartera
            DECLARE
               CURSOR c_anyven(pc_sseguro IN NUMBER, pc_nmovimi IN NUMBER) IS
                  SELECT   nanyven, nmesven
                      FROM movseguro
                     WHERE sseguro = pc_sseguro
                       AND nmovimi <= pc_nmovimi
                       AND cmovseg IN(0, 2)
                       AND nanyven IS NOT NULL
                  ORDER BY nanyven DESC;
            BEGIN
               OPEN c_anyven(v_sseguro, v_nmovimi);

               FETCH c_anyven
                INTO rec_nanyven, rec_nmesven;

               CLOSE c_anyven;
            -- BUG -21546_108724- 07/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
            EXCEPTION
               WHEN OTHERS THEN
                  IF c_anyven%ISOPEN THEN
                     CLOSE c_anyven;
                  END IF;
            END;
         ELSE   -- si el recibo es de suplemento, aport. extr.
            BEGIN
               SELECT nanyven, nmesven
                 INTO rec_nanyven, rec_nmesven
                 FROM movseguro
                WHERE sseguro = v_sseguro
                  AND nmovimi = v_nmovimi;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := 104349;   -- Error al leer de la tabla MOVSEGURO
                  text_error := 'función fecha_venta_recibo';
            END;
         END IF;

-- Si no se encuentra la venta (por ser excesivamente antiguo) lo devolvemos según su fefecto
         IF rec_nmesven IS NULL THEN
            rec_nmesven := TO_CHAR(v_fefecto, 'mm');
            rec_nanyven := TO_CHAR(v_fefecto, 'yyyy');
         END IF;
      END IF;

      RETURN num_err;
   END fecha_venta_recibo;

-------------------------------------------------------------------------------------------------
   FUNCTION anulaciones_recibos(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pnmesven IN NUMBER,
      pnanyven IN NUMBER,
      psproces IN NUMBER,
      pfcierre IN DATE,
      pfcierreanual IN DATE,
      pfcalcul IN DATE,
      pmoneda IN NUMBER,
      text_error OUT VARCHAR2)
      RETURN NUMBER IS
/********************************************************************************************
 Calcula las anulaciones de recibos
**********************************************************************************************/
      CURSOR c_recibos_anulados IS
         SELECT s.sseguro, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, s.npoliza,
                s.ncertif, s.nanuali, r.nmovimi, r.ctiprec, mvr.cmotmov, s.pdtoord, r.nrecibo,
                mvr.fmovdia, r.cempres, mvr.fmovini, r.cagente, s.cagrpro, s.ctiprea,
                s.ctipcoa, r.fefecto, r.fvencim, r.femisio, r.nperven
           FROM movrecibo mvr, recibos r, seguros s
          WHERE (mvr.fmovdia >= mvr.fmovini
                 AND mvr.fmovdia >= pfcierreanual
                 OR mvr.fmovdia < mvr.fmovini
                    AND mvr.fmovini >= pfcierreanual)
            AND mvr.cestrec = 2
            AND mvr.fmovini <= pfcalcul
            AND(mvr.fmovfin > pfcalcul + 30
                OR mvr.fmovfin IS NULL)
            AND r.nrecibo = mvr.nrecibo
            AND r.cempres = pcempres
            AND s.sseguro = r.sseguro;

      CURSOR c_vdetrecibos(pc_nrecibo IN NUMBER, pc_ctiprec IN NUMBER) IS
         SELECT DECODE(pc_ctiprec, 9, -ipridev, ipridev) ipridev,
                DECODE(pc_ctiprec, 9, -iprinet, iprinet) iprinet,
                DECODE(pc_ctiprec, 9, -it1con, it1con) it1con,
                DECODE(pc_ctiprec, 9, -idgs, idgs) idgs, DECODE(pc_ctiprec,
                                                                9, -iips,
                                                                iips) iips,
                DECODE(pc_ctiprec, 9, -iarbitr, iarbitr) iarbitr,
                DECODE(pc_ctiprec, 9, -ifng, ifng) ifng,
                DECODE(pc_ctiprec, 9, -irecfra, irecfra) irecfra,
                DECODE(pc_ctiprec, 9, -iderreg, iderreg) iderreg,
                DECODE(pc_ctiprec, 9, -idtoom, idtoom) idtoom,
                DECODE(pc_ctiprec, 9, -icedpdv, icedpdv) icedpdv,
                DECODE(pc_ctiprec, 9, -icednet, icednet) icednet,
                DECODE(pc_ctiprec, 9, -it2con, it2con) it2con,
                DECODE(pc_ctiprec, 9, -iceddgs, iceddgs) iceddgs,
                DECODE(pc_ctiprec, 9, -icedips, icedips) icedips,
                DECODE(pc_ctiprec, 9, -icedarb, icedarb) icedarb,
                DECODE(pc_ctiprec, 9, -icedfng, icedfng) icedfng,
                DECODE(pc_ctiprec, 9, -icedrfr, icedrfr) icedrfr,
                DECODE(pc_ctiprec, 9, -icedreg, icedreg) icedreg,
                DECODE(pc_ctiprec, 9, -iceddom, iceddom) iceddom
           FROM vdetrecibos
          WHERE nrecibo = pc_nrecibo;

      v_peremi       NUMBER;
      v_anyemi       ventascontab.nanyven%TYPE;   --       v_anyemi       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_mesemi       ventascontab.nmesven%TYPE;   --       v_mesemi       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_peranul      NUMBER;
      v_mesanul      ventascontab.nmesven%TYPE;   --       v_mesanul      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_anyanul      ventascontab.nanyven%TYPE;   --       v_anyanul      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      rec_nmesven    movseguro.nmesven%TYPE;   --       rec_nmesven    NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      rec_nanyven    movseguro.nanyven%TYPE;   --       rec_nanyven    NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_excant       NUMBER;
      v_excact       NUMBER;
      v_fcierre_excant_proc DATE;
      v_fcierre_excant_efe DATE;
      v_pe_excant    ventascontab.iprinet%TYPE;   --       v_pe_excant    NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_pe_excact    ventascontab.iprinet%TYPE;   --       v_pe_excact    NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      coefic         NUMBER;
      v_pe_excant_coa ventascontab.iprinet_coa%TYPE;   --       v_pe_excant_coa NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_pe_excact_coa ventascontab.iprinet_coa%TYPE;   --       v_pe_excact_coa NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      venta_excact   ventascontab.ipridev%TYPE;   --       venta_excact   NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      venta_excact_coa ventascontab.ipridev_coa%TYPE;   --       venta_excact_coa NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      venta_excant   ventascontab.ipridev%TYPE;   --       venta_excant   NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      venta_excant_coa ventascontab.ipridev_coa%TYPE;   --       venta_excant_coa NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      cexercici_act  ventascontab.cexerci%TYPE;   --       cexercici_act  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      cexercici_ant  ventascontab.cexerci%TYPE;   --       cexercici_ant  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_itotcon_ant  ventascontab.itotcon%TYPE;   --       v_itotcon_ant  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_itotcon_coa_ant ventascontab.itotcon_coa%TYPE;   --       v_itotcon_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iips_ant     ventascontab.iips%TYPE;   --       v_iips_ant     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iips_coa_ant ventascontab.iips_coa%TYPE;   --       v_iips_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idgs_ant     ventascontab.idgs%TYPE;   --       v_idgs_ant     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idgs_coa_ant ventascontab.idgs_coa%TYPE;   --       v_idgs_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iarbitr_ant  ventascontab.iarbitr%TYPE;   --       v_iarbitr_ant  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iarbitr_coa_ant ventascontab.iarbitr_coa%TYPE;   --       v_iarbitr_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ifng_ant     ventascontab.ifng%TYPE;   --       v_ifng_ant     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ifng_coa_ant ventascontab.ifng_coa%TYPE;   --       v_ifng_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_irecfra_ant  ventascontab.irecfra%TYPE;   --       v_irecfra_ant  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_irecfra_coa_ant ventascontab.irecfra_coa%TYPE;   --       v_irecfra_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idtoom_ant   ventascontab.idtoom%TYPE;   --       v_idtoom_ant   NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idtoom_coa_ant ventascontab.idtoom_coa%TYPE;   --       v_idtoom_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iderreg_ant  ventascontab.iderreg%TYPE;   --       v_iderreg_ant  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iderreg_coa_ant NUMBER;
      v_itotcon_act  ventascontab.itotcon%TYPE;   --       v_itotcon_act  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_itotcon_coa_act ventascontab.itotcon_coa%TYPE;   --       v_itotcon_coa_act NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iips_act     ventascontab.iips%TYPE;   --       v_iips_act     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iips_coa_act ventascontab.iips_coa%TYPE;   --       v_iips_coa_act NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idgs_act     ventascontab.idgs%TYPE;   --       v_idgs_act     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idgs_coa_act ventascontab.idgs_coa%TYPE;   --       v_idgs_coa_act NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iarbitr_act  ventascontab.iarbitr%TYPE;   --       v_iarbitr_act  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iarbitr_coa_act ventascontab.iarbitr_coa%TYPE;   --       v_iarbitr_coa_act NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ifng_act     ventascontab.ifng%TYPE;   --       v_ifng_act     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ifng_coa_act ventascontab.ifng_coa%TYPE;   --       v_ifng_coa_act NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_irecfra_act  ventascontab.irecfra%TYPE;   --       v_irecfra_act  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_irecfra_coa_act ventascontab.irecfra_coa%TYPE;   --       v_irecfra_coa_act NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idtoom_act   ventascontab.idtoom%TYPE;   --       v_idtoom_act   NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idtoom_coa_act ventascontab.idtoom_coa%TYPE;   --       v_idtoom_coa_act NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iderreg_act  ventascontab.iderreg%TYPE;   --       v_iderreg_act  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iderreg_coa_act NUMBER;
      num_err        NUMBER := 0;
      text_error1    VARCHAR2(150);
-- Para poder ejecutar la instruccion 'INSERT'
      v_cursor       INTEGER;
      v_insertventas VARCHAR2(40);
      v_insertventasaux VARCHAR2(40);
      v_restoinsert  VARCHAR2(32000);
      v_numrows      INTEGER;
   BEGIN
      FOR anul IN c_recibos_anulados LOOP
         text_error1 := '- FUNC. ANULAC. RECIBOS CONTAB- recibo = ' || anul.nrecibo || ' ';
         v_peranul := f_perventa(NULL, anul.fmovdia, anul.fmovini, anul.cempres);
         v_anyanul := ROUND(v_peranul / 100);
         v_mesanul := v_peranul - ROUND(v_peranul / 100) * 100;

         -- Sólo grabamos si el mes de la venta y el año están dentro del intervalo
         IF v_anyanul = pnanyven
            AND v_mesanul BETWEEN 1 AND pnmesven THEN
            FOR vdet IN c_vdetrecibos(anul.nrecibo, anul.ctiprec) LOOP
               -- Primero miramos la fecha de venta del movimiento del recibo(si es de cartera miramos la
               -- fecha de emisión), y entonces calculamos la fecha de cierre
               -- del ejercicio anterior a esa fecha.
               -- Si el recibo es del ejercicio actual, se prorratea la prima neta entre el ejercicio actual y
               -- el anterior(Ejemplo: ejer act = 2000 y ejer ant = 1999). Pero si el recibo es del ejercicio
               -- anterior (1999), se prorrateará entre el año 1999 y el año 1998, imputándose la venta del
               -- año 1998 al año 2000., y la del año 1999 al 1999.
               -- Calculamos la fecha de venta del recibo
               num_err := fecha_venta_recibo(anul.nrecibo, anul.sseguro, anul.ctiprec,
                                             anul.nmovimi, rec_nmesven, rec_nanyven,
                                             text_error);

               IF num_err <> 0 THEN
                  text_error := text_error1 || text_error;
                  RETURN num_err;
               END IF;

               -- Calculamos cual es el ejercicio anterior, el ejercicio actual y
               -- la fecha de cierre del ejercicio anterior
               v_excact := rec_nanyven;
               v_excant := v_excact - 1;
               v_fcierre_excant_efe := TO_DATE('3112' || v_excant, 'ddmmyyyy');

               BEGIN
                  SELECT fcierre
                    INTO v_fcierre_excant_proc
                    FROM cierres
                   WHERE ctipo = 1
                     AND cestado = 1
                     AND cempres = pcempres
                     AND fperfin = TO_DATE('3112' || v_excant, 'ddmmyyyy');
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := 111111;   -- Error al calcular la fecha de cierre del ejercicio anterior
                     text_error := text_error1 || SQLERRM || ' ' || SQLCODE;
                     RETURN num_err;
               END;

               -- Tenemos que hacer el reparto entre el ejercicio anterior y el ejercicio actual
               -- Para ello calculamos cuándo fue emitido el recibo (en el ejer.act o en el ant.)
               v_peremi := anul.nperven;
               v_anyemi := ROUND(v_peremi / 100);

               -- si el recibo es de cartera, tenemos que hacer
               -- el reparto entre ejercicio anterior y actual. Si es de otro tipo (suplemento,
               -- nueva producción,... la prima emitida siempre es del ejercicio actual
               IF anul.ctiprec = 3
                  AND vdet.ipridev = 0
                  AND v_anyemi = pnanyven THEN
                  num_err := f_pe_excant(anul.sseguro, anul.fefecto, anul.fvencim, v_excant,
                                         v_fcierre_excant_efe, v_fcierre_excant_proc, pmoneda,
                                         v_pe_excant);
               ELSE
                  v_pe_excant := 0;   -- no hay prima emitida del ejercicio anterior
               END IF;

               IF num_err <> 0 THEN
                  text_error := text_error1;
                  RETURN num_err;
               END IF;

               IF v_pe_excant <> 0 THEN
                  coefic := v_pe_excant / vdet.iprinet;
                  v_itotcon_ant := coefic * vdet.it1con;
                  v_iips_ant := coefic * vdet.iips;
                  v_idgs_ant := coefic * vdet.idgs;
                  v_iarbitr_ant := coefic * vdet.iarbitr;
                  v_ifng_ant := coefic * vdet.ifng;
                  v_irecfra_ant := coefic * vdet.irecfra;
                  v_idtoom_ant := coefic * vdet.idtoom;
                  v_iderreg_ant := coefic * vdet.iderreg;
                  -- Importes de coaseguro
                  v_pe_excant_coa := coefic * vdet.icednet;
                  v_itotcon_coa_ant := coefic * vdet.it2con;
                  v_iips_coa_ant := coefic * vdet.icedips;
                  v_idgs_coa_ant := coefic * vdet.iceddgs;
                  v_iarbitr_coa_ant := coefic * vdet.icedarb;
                  v_ifng_coa_ant := coefic * vdet.icedfng;
                  v_irecfra_coa_ant := coefic * vdet.icedrfr;
                  v_idtoom_coa_ant := coefic * vdet.iceddom;
                  v_iderreg_coa_ant := coefic * vdet.icedreg;
               ELSE
                  v_itotcon_ant := 0;
                  v_iips_ant := 0;
                  v_idgs_ant := 0;
                  v_iarbitr_ant := 0;
                  v_ifng_ant := 0;
                  v_irecfra_ant := 0;
                  v_idtoom_ant := 0;
                  v_iderreg_ant := 0;
                  -- Importes de coaseguro
                  v_pe_excant_coa := 0;
                  v_itotcon_coa_ant := 0;
                  v_iips_coa_ant := 0;
                  v_idgs_coa_ant := 0;
                  v_iarbitr_coa_ant := 0;
                  v_ifng_coa_ant := 0;
                  v_irecfra_coa_ant := 0;
                  v_idtoom_coa_ant := 0;
                  v_iderreg_coa_ant := 0;
               END IF;

               v_pe_excact := vdet.iprinet - v_pe_excant;
               v_itotcon_act := vdet.it1con - v_itotcon_ant;
               v_iips_act := vdet.iips - v_iips_ant;
               v_idgs_act := vdet.idgs - v_idgs_ant;
               v_iarbitr_act := vdet.iarbitr - v_iarbitr_ant;
               v_ifng_act := vdet.ifng - v_ifng_ant;
               v_irecfra_act := vdet.irecfra - v_irecfra_ant;
               v_idtoom_act := vdet.idtoom - v_idtoom_ant;
               v_iderreg_act := vdet.iderreg - v_iderreg_ant;
               v_pe_excact_coa := vdet.icednet - v_pe_excant_coa;
               v_itotcon_coa_act := vdet.it2con - v_itotcon_coa_ant;
               v_iips_coa_act := vdet.icedips - v_iips_coa_ant;
               v_idgs_coa_act := vdet.iceddgs - v_idgs_coa_ant;
               v_iarbitr_coa_act := vdet.icedarb - v_iarbitr_coa_ant;
               v_ifng_coa_act := vdet.icedfng - v_ifng_coa_ant;
               v_irecfra_coa_act := vdet.icedrfr - v_irecfra_coa_ant;
               v_idtoom_coa_act := vdet.iceddom - v_idtoom_coa_ant;
               v_iderreg_coa_act := vdet.icedreg - v_iderreg_coa_ant;
               -- Si cmotmov = 0, anulación de venta = iprinet. Prima emitida = iprinet
               -- Si cmotmov = 1, anulación de venta = ipridev. Prima emitida = iprinet
               -- Si cmotmov = 2, no hay anulación de venta, sólo de prima emitida. Prima emitida = iprinet
               cexercici_act := 1;
               cexercici_ant := 0;

               IF anul.cmotmov = 0 THEN
                  venta_excact := v_pe_excact;
                  venta_excact_coa := v_pe_excact_coa;
                  venta_excant := v_pe_excant;
                  venta_excant_coa := v_pe_excant_coa;
               ELSIF anul.cmotmov = 1 THEN
                  venta_excact := vdet.ipridev;
                  venta_excact_coa := vdet.icedpdv;
                  venta_excant := 0;
                  venta_excant_coa := 0;
               ELSIF anul.cmotmov = 2 THEN
                  venta_excact := 0;
                  venta_excact_coa := 0;
                  venta_excant := 0;
                  venta_excant_coa := 0;
               END IF;

               IF pmodo IN(1, 2) THEN
                  BEGIN
                     -- Sólo grabamos si hay algún importe distinto de 0
                     IF v_pe_excant <> 0
                        OR v_itotcon_ant <> 0
                        OR v_iips_ant <> 0
                        OR v_idgs_ant <> 0
                        OR v_iarbitr_ant <> 0
                        OR v_ifng_ant <> 0
                        OR v_irecfra_ant <> 0
                        OR v_idtoom_ant <> 0
                        OR v_iderreg_ant <> 0
                        OR v_pe_excant_coa <> 0
                        OR v_itotcon_coa_ant <> 0
                        OR v_iips_coa_ant <> 0
                        OR v_idgs_ant <> 0
                        OR v_iarbitr_ant <> 0
                        OR v_ifng_ant <> 0
                        OR v_irecfra_ant <> 0
                        OR v_idtoom_ant <> 0
                        OR v_iderreg_ant <> 0
                        OR venta_excant <> 0
                        OR venta_excant_coa <> 0 THEN
                        INSERT INTO ventascontab
                                    (sseguro, ctipo, cexerci, nanyven, nmesven,
                                     sproces, fcierre, fcalcul, cempres, cramo,
                                     cmodali, ctipseg, ccolect, cactivi,
                                     npoliza, ncertif, cagente, cagrpro,
                                     ctiprea, ctipcoa, ipridev, iprinet,
                                     ipemiti, itotcon, iips, idgs,
                                     iarbitr, ifng, irecfra, idtoom,
                                     iderreg, ipridev_coa, iprinet_coa,
                                     ipemiti_coa, itotcon_coa, iips_coa,
                                     idgs_coa, iarbitr_coa, ifng_coa,
                                     irecfra_coa, idtoom_coa, iderreg_coa)
                             VALUES (anul.sseguro, 3, cexercici_ant, v_anyanul, v_mesanul,
                                     psproces, pfcierre, f_sysdate, anul.cempres, anul.cramo,
                                     anul.cmodali, anul.ctipseg, anul.ccolect, anul.cactivi,
                                     anul.npoliza, anul.ncertif, anul.cagente, anul.cagrpro,
                                     anul.ctiprea, anul.ctipcoa, venta_excant, v_pe_excant,
                                     v_pe_excant, v_itotcon_ant, v_iips_ant, v_idgs_ant,
                                     v_iarbitr_ant, v_ifng_ant, v_irecfra_ant, v_idtoom_ant,
                                     v_iderreg_ant, venta_excant_coa, v_pe_excant_coa,
                                     v_pe_excant_coa, v_itotcon_coa_ant, v_iips_coa_ant,
                                     v_idgs_coa_ant, v_iarbitr_coa_ant, v_ifng_coa_ant,
                                     v_irecfra_coa_ant, v_idtoom_coa_ant, v_iderreg_coa_ant);
                     END IF;

                     IF v_pe_excact <> 0
                        OR v_itotcon_act <> 0
                        OR v_iips_act <> 0
                        OR v_idgs_act <> 0
                        OR v_iarbitr_act <> 0
                        OR v_ifng_act <> 0
                        OR v_irecfra_act <> 0
                        OR v_idtoom_act <> 0
                        OR v_iderreg_act <> 0
                        OR v_pe_excact_coa <> 0
                        OR v_itotcon_coa_act <> 0
                        OR v_iips_coa_act <> 0
                        OR v_idgs_act <> 0
                        OR v_iarbitr_act <> 0
                        OR v_ifng_act <> 0
                        OR v_irecfra_act <> 0
                        OR v_idtoom_act <> 0
                        OR v_iderreg_act <> 0
                        OR venta_excact <> 0
                        OR venta_excact_coa <> 0 THEN
                        INSERT INTO ventascontab
                                    (sseguro, ctipo, cexerci, nanyven, nmesven,
                                     sproces, fcierre, fcalcul, cempres, cramo,
                                     cmodali, ctipseg, ccolect, cactivi,
                                     npoliza, ncertif, cagente, cagrpro,
                                     ctiprea, ctipcoa, ipridev, iprinet,
                                     ipemiti, itotcon, iips, idgs,
                                     iarbitr, ifng, irecfra, idtoom,
                                     iderreg, ipridev_coa, iprinet_coa,
                                     ipemiti_coa, itotcon_coa, iips_coa,
                                     idgs_coa, iarbitr_coa, ifng_coa,
                                     irecfra_coa, idtoom_coa, iderreg_coa)
                             VALUES (anul.sseguro, 3, cexercici_act, v_anyanul, v_mesanul,
                                     psproces, pfcierre, f_sysdate, anul.cempres, anul.cramo,
                                     anul.cmodali, anul.ctipseg, anul.ccolect, anul.cactivi,
                                     anul.npoliza, anul.ncertif, anul.cagente, anul.cagrpro,
                                     anul.ctiprea, anul.ctipcoa, venta_excact, v_pe_excact,
                                     v_pe_excact, v_itotcon_act, v_iips_act, v_idgs_act,
                                     v_iarbitr_act, v_ifng_act, v_irecfra_act, v_idtoom_act,
                                     v_iderreg_act, venta_excact_coa, v_pe_excact_coa,
                                     v_pe_excact_coa, v_itotcon_coa_act, v_iips_coa_act,
                                     v_idgs_coa_act, v_iarbitr_coa_act, v_ifng_coa_act,
                                     v_irecfra_coa_act, v_idtoom_coa_act, v_iderreg_coa_act);
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        num_err := 108013;   -- Error al insertar en VENTASCONTAB
                        text_error := text_error1 || ' ' || SQLERRM || ' ' || SQLCODE;
                  END;
               ELSIF pmodo = 3 THEN   -- si es simulación se graba en VENTASAUX
                  BEGIN
                     -- Sólo grabamos si hay algún importe distinto de 0
                     IF v_pe_excant <> 0
                        OR v_itotcon_ant <> 0
                        OR v_iips_ant <> 0
                        OR v_idgs_ant <> 0
                        OR v_iarbitr_ant <> 0
                        OR v_ifng_ant <> 0
                        OR v_irecfra_ant <> 0
                        OR v_idtoom_ant <> 0
                        OR v_iderreg_ant <> 0
                        OR v_pe_excant_coa <> 0
                        OR v_itotcon_coa_ant <> 0
                        OR v_iips_coa_ant <> 0
                        OR v_idgs_ant <> 0
                        OR v_iarbitr_ant <> 0
                        OR v_ifng_ant <> 0
                        OR v_irecfra_ant <> 0
                        OR v_idtoom_ant <> 0
                        OR v_iderreg_ant <> 0
                        OR venta_excant <> 0
                        OR venta_excant_coa <> 0 THEN
                        INSERT INTO ventascontabaux
                                    (sseguro, ctipo, cexerci, nanyven, nmesven,
                                     sproces, fcierre, fcalcul, cempres, cramo,
                                     cmodali, ctipseg, ccolect, cactivi,
                                     npoliza, ncertif, cagente, cagrpro,
                                     ctiprea, ctipcoa, ipridev, iprinet,
                                     ipemiti, itotcon, iips, idgs,
                                     iarbitr, ifng, irecfra, idtoom,
                                     iderreg, ipridev_coa, iprinet_coa,
                                     ipemiti_coa, itotcon_coa, iips_coa,
                                     idgs_coa, iarbitr_coa, ifng_coa,
                                     irecfra_coa, idtoom_coa, iderreg_coa)
                             VALUES (anul.sseguro, 3, cexercici_ant, v_anyanul, v_mesanul,
                                     psproces, pfcierre, f_sysdate, anul.cempres, anul.cramo,
                                     anul.cmodali, anul.ctipseg, anul.ccolect, anul.cactivi,
                                     anul.npoliza, anul.ncertif, anul.cagente, anul.cagrpro,
                                     anul.ctiprea, anul.ctipcoa, venta_excant, v_pe_excant,
                                     v_pe_excant, v_itotcon_ant, v_iips_ant, v_idgs_ant,
                                     v_iarbitr_ant, v_ifng_ant, v_irecfra_ant, v_idtoom_ant,
                                     v_iderreg_ant, venta_excant_coa, v_pe_excant_coa,
                                     v_pe_excant_coa, v_itotcon_coa_ant, v_iips_coa_ant,
                                     v_idgs_coa_ant, v_iarbitr_coa_ant, v_ifng_coa_ant,
                                     v_irecfra_coa_ant, v_idtoom_coa_ant, v_iderreg_coa_ant);
                     END IF;

                     IF v_pe_excact <> 0
                        OR v_itotcon_act <> 0
                        OR v_iips_act <> 0
                        OR v_idgs_act <> 0
                        OR v_iarbitr_act <> 0
                        OR v_ifng_act <> 0
                        OR v_irecfra_act <> 0
                        OR v_idtoom_act <> 0
                        OR v_iderreg_act <> 0
                        OR v_pe_excact_coa <> 0
                        OR v_itotcon_coa_act <> 0
                        OR v_iips_coa_act <> 0
                        OR v_idgs_act <> 0
                        OR v_iarbitr_act <> 0
                        OR v_ifng_act <> 0
                        OR v_irecfra_act <> 0
                        OR v_idtoom_act <> 0
                        OR v_iderreg_act <> 0
                        OR venta_excact <> 0
                        OR venta_excact_coa <> 0 THEN
                        INSERT INTO ventascontabaux
                                    (sseguro, ctipo, cexerci, nanyven, nmesven,
                                     sproces, fcierre, fcalcul, cempres, cramo,
                                     cmodali, ctipseg, ccolect, cactivi,
                                     npoliza, ncertif, cagente, cagrpro,
                                     ctiprea, ctipcoa, ipridev, iprinet,
                                     ipemiti, itotcon, iips, idgs,
                                     iarbitr, ifng, irecfra, idtoom,
                                     iderreg, ipridev_coa, iprinet_coa,
                                     ipemiti_coa, itotcon_coa, iips_coa,
                                     idgs_coa, iarbitr_coa, ifng_coa,
                                     irecfra_coa, idtoom_coa, iderreg_coa)
                             VALUES (anul.sseguro, 3, cexercici_act, v_anyanul, v_mesanul,
                                     psproces, pfcierre, f_sysdate, anul.cempres, anul.cramo,
                                     anul.cmodali, anul.ctipseg, anul.ccolect, anul.cactivi,
                                     anul.npoliza, anul.ncertif, anul.cagente, anul.cagrpro,
                                     anul.ctiprea, anul.ctipcoa, venta_excact, v_pe_excact,
                                     v_pe_excact, v_itotcon_act, v_iips_act, v_idgs_act,
                                     v_iarbitr_act, v_ifng_act, v_irecfra_act, v_idtoom_act,
                                     v_iderreg_act, venta_excact_coa, v_pe_excact_coa,
                                     v_pe_excact_coa, v_itotcon_coa_act, v_iips_coa_act,
                                     v_idgs_coa_act, v_iarbitr_coa_act, v_ifng_coa_act,
                                     v_irecfra_coa_act, v_idtoom_coa_act, v_iderreg_coa_act);
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        num_err := 108013;   -- Error al insertar en VENTASCONTAB
                        text_error := text_error1 || ' ' || SQLERRM || ' ' || SQLCODE;
                  END;
               END IF;

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END LOOP;
         END IF;

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END LOOP;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         num_err := 444446;
         text_error := SQLERRM;
         RETURN num_err;
   END anulaciones_recibos;

-------------------------------------------------------------------------------------------------
   FUNCTION f_extexcant(
      psseguro IN NUMBER,
      pnanyven IN NUMBER,
      pfcierre IN DATE,
      piextorn OUT NUMBER)
      RETURN NUMBER IS
/*********************************************************************************************
   Calcula la part proporcional del rebut d'extorn d'anul.lació corresponent a l'exc. ant
**********************************************************************************************/
      l_pemitida     NUMBER;
      l_ppeea        NUMBER;
      l_pdevengada   NUMBER;
   BEGIN
      SELECT SUM(DECODE(ctipo,
                        1, DECODE(nmesven, 0, 0, ipemiti),
                        DECODE(nmesven, 0, 0, -ipemiti))) pemitida,
             SUM(DECODE(nmesven, 0, ipemiti, 0)) ppeea,
             SUM(DECODE(ctipo, 1, ipridev, -ipridev)) pdevengada
        INTO l_pemitida,
             l_ppeea,
             l_pdevengada
        FROM ventascontab
       WHERE sseguro = psseguro
         AND(fcierre = pfcierre
             OR(nmesven = 0
                AND nanyven = TO_CHAR(pfcierre, 'yyyy')))
         AND cexerci = 0;

      piextorn := NVL(l_pemitida, 0) - NVL(l_ppeea, 0) - NVL(l_pdevengada, 0);
      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         piextorn := 0;
         RETURN 0;
      WHEN OTHERS THEN
         RETURN 108183;
   END f_extexcant;

-------------------------------------------------------------------------------------------------
   FUNCTION anulaciones_poliza(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pnmesven IN NUMBER,
      pnanyven IN NUMBER,
      psproces IN NUMBER,
      pfcierre IN DATE,
      pfcalcul IN DATE,
      pmoneda IN NUMBER,
      text_error OUT VARCHAR2)
      RETURN NUMBER IS
/*********************************************************************************************
 Calcula la venta anulada cuando se anula una póliza
**********************************************************************************************/
      CURSOR c_anulaciones IS
         SELECT s.sseguro, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, s.npoliza,
                s.ncertif, s.nanuali, m.nmovimi, s.pdtoord, s.cempres, s.cagente, s.cagrpro,
                s.ctiprea, s.ctipcoa, m.fefecto, m.nanyven, m.nmesven
           FROM movseguro m, seguros s
          WHERE m.cmovseg = 3
            AND m.nmesven BETWEEN 1 AND pnmesven   -- siempre se calculan las ventas desde el primer mes del año
            AND m.nanyven = pnanyven
            AND m.sseguro = s.sseguro
            AND s.cempres = pcempres
            AND s.cramo = s.cramo;

      CURSOR c_vdetrecibos(pc_sseguro IN NUMBER, pc_nmovimi IN NUMBER) IS
         SELECT r.ctiprec tipo, vdet.ipridev, vdet.iprinet, vdet.it1con, vdet.idgs, vdet.iips,
                vdet.iarbitr, vdet.ifng, vdet.irecfra, vdet.iderreg, vdet.idtoom, vdet.icedpdv,
                vdet.icednet, vdet.it2con, vdet.iceddgs, vdet.icedips, vdet.icedarb,
                vdet.icedfng, vdet.icedrfr, vdet.icedreg, vdet.iceddom, r.ctiprec, r.fefecto,
                r.fvencim, r.nrecibo
           FROM vdetrecibos vdet, recibos r
          WHERE r.sseguro = pc_sseguro
            AND r.nmovimi = pc_nmovimi
            AND r.nrecibo = vdet.nrecibo
            AND(vdet.ipridev <> 0
                OR vdet.icedpdv <> 0);

      v_fcierre_exant DATE;   -- fecha de cierre del ejercicio anterior
      v_anul_excant  ventascontab.ipridev%TYPE;   --       v_anul_excant  NUMBER;   -- venta anulada del ejercicio anterior --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_anul_excact  ventascontab.ipridev%TYPE;   --       v_anul_excact  NUMBER;   -- venta anulada del ejercicio actual --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      coefic         NUMBER;
      v_anul_excant_coa ventascontab.ipridev_coa%TYPE;   --       v_anul_excant_coa NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_anul_excact_coa ventascontab.ipridev_coa%TYPE;   --       v_anul_excact_coa NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      num_err        NUMBER := 0;
      text_error1    VARCHAR2(150);
      v_iextorn_ant  ventascontab.iprinet%TYPE;   --       v_iextorn_ant  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_pe_excact    ventascontab.iprinet%TYPE;   --       v_pe_excact    NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_pe_excant_coa ventascontab.iprinet_coa%TYPE;   --       v_pe_excant_coa NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_pe_excact_coa ventascontab.iprinet_coa%TYPE;   --       v_pe_excact_coa NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_itotcon_ant  ventascontab.itotcon%TYPE;   --       v_itotcon_ant  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_itotcon_coa_ant ventascontab.itotcon_coa%TYPE;   --       v_itotcon_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iips_ant     ventascontab.iips%TYPE;   --       v_iips_ant     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iips_coa_ant ventascontab.iips_coa%TYPE;   --       v_iips_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idgs_ant     ventascontab.idgs%TYPE;   --       v_idgs_ant     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idgs_coa_ant ventascontab.idgs_coa%TYPE;   --       v_idgs_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iarbitr_ant  ventascontab.iarbitr%TYPE;   --       v_iarbitr_ant  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iarbitr_coa_ant ventascontab.iarbitr_coa%TYPE;   --       v_iarbitr_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ifng_ant     ventascontab.ifng%TYPE;   --       v_ifng_ant     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ifng_coa_ant ventascontab.ifng_coa%TYPE;   --       v_ifng_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_irecfra_ant  ventascontab.irecfra%TYPE;   --       v_irecfra_ant  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_irecfra_coa_ant ventascontab.irecfra_coa%TYPE;   --       v_irecfra_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idtoom_ant   ventascontab.idtoom%TYPE;   --       v_idtoom_ant   NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idtoom_coa_ant ventascontab.idtoom_coa%TYPE;   --       v_idtoom_coa_ant NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iderreg_ant  ventascontab.iderreg%TYPE;   --       v_iderreg_ant  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iderreg_coa_ant NUMBER;
      v_itotcon_act  ventascontab.itotcon%TYPE;   --       v_itotcon_act  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_itotcon_coa_act ventascontab.itotcon_coa%TYPE;   --       v_itotcon_coa_act NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iips_act     ventascontab.iips%TYPE;   --       v_iips_act     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iips_coa_act ventascontab.iips_coa%TYPE;   --       v_iips_coa_act NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idgs_act     ventascontab.idgs%TYPE;   --       v_idgs_act     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idgs_coa_act ventascontab.idgs_coa%TYPE;   --       v_idgs_coa_act NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iarbitr_act  ventascontab.iarbitr%TYPE;   --       v_iarbitr_act  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iarbitr_coa_act ventascontab.iarbitr_coa%TYPE;   --       v_iarbitr_coa_act NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ifng_act     ventascontab.ifng%TYPE;   --       v_ifng_act     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ifng_coa_act ventascontab.ifng_coa%TYPE;   --       v_ifng_coa_act NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_irecfra_act  ventascontab.irecfra%TYPE;   --       v_irecfra_act  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_irecfra_coa_act ventascontab.irecfra_coa%TYPE;   --       v_irecfra_coa_act NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idtoom_act   ventascontab.idtoom%TYPE;   --       v_idtoom_act   NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idtoom_coa_act ventascontab.idtoom_coa%TYPE;   --       v_idtoom_coa_act NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iderreg_act  ventascontab.iderreg%TYPE;   --       v_iderreg_act  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iderreg_coa_act NUMBER;
   BEGIN
      -- Averiguamos la fecha de cierre del ejercicio anterior (la fecha de cierre del mes de
      -- diciembre del año anterior)
      v_fcierre_exant := LAST_DAY(TO_DATE('12' ||(pnanyven - 1), 'mmyyyy'));

      FOR anul IN c_anulaciones LOOP
         FOR vdet IN c_vdetrecibos(anul.sseguro, anul.nmovimi) LOOP
            text_error1 := '- FUNC. ANULAC. PÓLIZAS CONTAB - sseguro = ' || anul.sseguro
                           || ' ';
            -- Calculamos la parte de la venta anulada que corresponde al ejercicio anterior
            -- y al ejercicio actual
            num_err := f_vanu_excant(anul.sseguro, pnanyven - 1, v_fcierre_exant,
                                     anul.fefecto, pmoneda, v_anul_excant);

            IF num_err <> 0 THEN
               text_error := text_error1;
               RETURN num_err;
            END IF;

            IF v_anul_excant <> 0 THEN
               coefic := v_anul_excant / vdet.ipridev;
               v_anul_excant_coa := coefic * vdet.icedpdv;
            ELSE
               v_anul_excant_coa := 0;
            END IF;

            v_anul_excact := vdet.ipridev - v_anul_excant;
            v_anul_excact_coa := vdet.icedpdv - v_anul_excant_coa;

            IF pmodo IN(1, 2) THEN   -- si no es simulación grabamos en VENTASCONTAB
               BEGIN
                  -- Si la venta anulada del ejercicio anterior <> 0, entonces insertamos el
                  -- registro del ejercicio anterior que sólo tendrá información
                  -- de venta (tipo 4 anulación de pólizas)
                  IF v_anul_excant <> 0
                     OR v_anul_excant_coa <> 0 THEN
                     INSERT INTO ventascontab
                                 (sseguro, ctipo, cexerci, nanyven, nmesven, sproces,
                                  fcierre, fcalcul, cempres, cramo,
                                  cmodali, ctipseg, ccolect, cactivi,
                                  npoliza, ncertif, cagente, cagrpro,
                                  ctiprea, ctipcoa, ipridev, iprinet, ipemiti, itotcon, iips,
                                  idgs, iarbitr, ifng, irecfra, idtoom, iderreg, ipridev_coa,
                                  iprinet_coa, ipemiti_coa, itotcon_coa, iips_coa, idgs_coa,
                                  iarbitr_coa, ifng_coa, irecfra_coa, idtoom_coa, iderreg_coa)
                          VALUES (anul.sseguro, 4, 0, anul.nanyven, anul.nmesven, psproces,
                                  pfcierre, f_sysdate, anul.cempres, anul.cramo,
                                  anul.cmodali, anul.ctipseg, anul.ccolect, anul.cactivi,
                                  anul.npoliza, anul.ncertif, anul.cagente, anul.cagrpro,
                                  anul.ctiprea, anul.ctipcoa, v_anul_excant, 0, 0, 0, 0,
                                  0, 0, 0, 0, 0, 0, v_anul_excant_coa,
                                  0, 0, 0, 0, 0,
                                  0, 0, 0, 0, 0);
                  END IF;

                  -- Si la venta anulada del ejercicio actual <> 0, entonces insertamos el
                  -- registro del ejercicio actual que sólo tendrá información
                  -- de venta (tipo 4 anulación de pólizas)
                  IF v_anul_excact <> 0
                     OR v_anul_excact_coa <> 0 THEN
                     INSERT INTO ventascontab
                                 (sseguro, ctipo, cexerci, nanyven, nmesven, sproces,
                                  fcierre, fcalcul, cempres, cramo,
                                  cmodali, ctipseg, ccolect, cactivi,
                                  npoliza, ncertif, cagente, cagrpro,
                                  ctiprea, ctipcoa, ipridev, iprinet, ipemiti, itotcon, iips,
                                  idgs, iarbitr, ifng, irecfra, idtoom, iderreg, ipridev_coa,
                                  iprinet_coa, ipemiti_coa, itotcon_coa, iips_coa, idgs_coa,
                                  iarbitr_coa, ifng_coa, irecfra_coa, idtoom_coa, iderreg_coa)
                          VALUES (anul.sseguro, 4, 1, anul.nanyven, anul.nmesven, psproces,
                                  pfcierre, f_sysdate, anul.cempres, anul.cramo,
                                  anul.cmodali, anul.ctipseg, anul.ccolect, anul.cactivi,
                                  anul.npoliza, anul.ncertif, anul.cagente, anul.cagrpro,
                                  anul.ctiprea, anul.ctipcoa, v_anul_excact, 0, 0, 0, 0,
                                  0, 0, 0, 0, 0, 0, v_anul_excact_coa,
                                  0, 0, 0, 0, 0,
                                  0, 0, 0, 0, 0);
                  END IF;

                  IF vdet.iprinet <> 0 THEN
                     -- Ahora insertamos los registros de prima extornada (tipo = 2) del recibo de anulación,
                     num_err := f_extexcant(anul.sseguro, pnanyven, pfcierre, v_iextorn_ant);

                     IF num_err <> 0 THEN
                        text_error := text_error1;
                        RETURN num_err;
                     END IF;

                     IF v_iextorn_ant <> 0 THEN
                        coefic := v_iextorn_ant / vdet.iprinet;
                        v_itotcon_ant := coefic * vdet.it1con;
                        v_iips_ant := coefic * vdet.iips;
                        v_idgs_ant := coefic * vdet.idgs;
                        v_iarbitr_ant := coefic * vdet.iarbitr;
                        v_ifng_ant := coefic * vdet.ifng;
                        v_irecfra_ant := coefic * vdet.irecfra;
                        v_idtoom_ant := coefic * vdet.idtoom;
                        v_iderreg_ant := coefic * vdet.iderreg;
                        -- Importes de coaseguro
                        v_pe_excant_coa := coefic * vdet.icednet;
                        v_itotcon_coa_ant := coefic * vdet.it2con;
                        v_iips_coa_ant := coefic * vdet.icedips;
                        v_idgs_coa_ant := coefic * vdet.iceddgs;
                        v_iarbitr_coa_ant := coefic * vdet.icedarb;
                        v_ifng_coa_ant := coefic * vdet.icedfng;
                        v_irecfra_coa_ant := coefic * vdet.icedrfr;
                        v_idtoom_coa_ant := coefic * vdet.iceddom;
                        v_iderreg_coa_ant := coefic * vdet.icedreg;
                     ELSE
                        v_itotcon_ant := 0;
                        v_iips_ant := 0;
                        v_idgs_ant := 0;
                        v_iarbitr_ant := 0;
                        v_ifng_ant := 0;
                        v_irecfra_ant := 0;
                        v_idtoom_ant := 0;
                        v_iderreg_ant := 0;
                        -- Importes de coaseguro
                        v_pe_excant_coa := 0;
                        v_itotcon_coa_ant := 0;
                        v_iips_coa_ant := 0;
                        v_idgs_coa_ant := 0;
                        v_iarbitr_coa_ant := 0;
                        v_ifng_coa_ant := 0;
                        v_irecfra_coa_ant := 0;
                        v_idtoom_coa_ant := 0;
                        v_iderreg_coa_ant := 0;
                     END IF;

                     v_pe_excact := vdet.iprinet - v_iextorn_ant;
                     v_itotcon_act := vdet.it1con - v_itotcon_ant;
                     v_iips_act := vdet.iips - v_iips_ant;
                     v_idgs_act := vdet.idgs - v_idgs_ant;
                     v_iarbitr_act := vdet.iarbitr - v_iarbitr_ant;
                     v_ifng_act := vdet.ifng - v_ifng_ant;
                     v_irecfra_act := vdet.irecfra - v_irecfra_ant;
                     v_idtoom_act := vdet.idtoom - v_idtoom_ant;
                     v_iderreg_act := vdet.iderreg - v_iderreg_ant;
                     v_pe_excact_coa := vdet.icednet - v_pe_excant_coa;
                     v_itotcon_coa_act := vdet.it2con - v_itotcon_coa_ant;
                     v_iips_coa_act := vdet.icedips - v_iips_coa_ant;
                     v_idgs_coa_act := vdet.iceddgs - v_idgs_coa_ant;
                     v_iarbitr_coa_act := vdet.icedarb - v_iarbitr_coa_ant;
                     v_ifng_coa_act := vdet.icedfng - v_ifng_coa_ant;
                     v_irecfra_coa_act := vdet.icedrfr - v_irecfra_coa_ant;
                     v_idtoom_coa_act := vdet.iceddom - v_idtoom_coa_ant;
                     v_iderreg_coa_act := vdet.icedreg - v_iderreg_coa_ant;

-- ANTERIOR   -- Sólo grabamos si hay algún importe distinto de 0
                     IF v_iextorn_ant <> 0
                        OR v_itotcon_ant <> 0
                        OR v_iips_ant <> 0
                        OR v_idgs_ant <> 0
                        OR v_iarbitr_ant <> 0
                        OR v_ifng_ant <> 0
                        OR v_irecfra_ant <> 0
                        OR v_idtoom_ant <> 0
                        OR v_iderreg_ant <> 0
                        OR v_pe_excant_coa <> 0
                        OR v_itotcon_coa_ant <> 0
                        OR v_iips_coa_ant <> 0
                        OR v_idgs_ant <> 0
                        OR v_iarbitr_ant <> 0
                        OR v_ifng_ant <> 0
                        OR v_irecfra_ant <> 0
                        OR v_idtoom_ant <> 0
                        OR v_iderreg_ant <> 0 THEN
                        INSERT INTO ventascontab
                                    (sseguro, ctipo, cexerci, nanyven, nmesven,
                                     sproces, fcierre, fcalcul, cempres, cramo,
                                     cmodali, ctipseg, ccolect, cactivi,
                                     npoliza, ncertif, cagente, cagrpro,
                                     ctiprea, ctipcoa, ipridev, iprinet,
                                     ipemiti, itotcon, iips, idgs,
                                     iarbitr, ifng, irecfra, idtoom,
                                     iderreg, ipridev_coa, iprinet_coa, ipemiti_coa,
                                     itotcon_coa, iips_coa, idgs_coa,
                                     iarbitr_coa, ifng_coa, irecfra_coa,
                                     idtoom_coa, iderreg_coa)
                             VALUES (anul.sseguro, 2, 0, anul.nanyven, anul.nmesven,
                                     psproces, pfcierre, f_sysdate, anul.cempres, anul.cramo,
                                     anul.cmodali, anul.ctipseg, anul.ccolect, anul.cactivi,
                                     anul.npoliza, anul.ncertif, anul.cagente, anul.cagrpro,
                                     anul.ctiprea, anul.ctipcoa, 0, v_iextorn_ant,
                                     v_iextorn_ant, v_itotcon_ant, v_iips_ant, v_idgs_ant,
                                     v_iarbitr_ant, v_ifng_ant, v_irecfra_ant, v_idtoom_ant,
                                     v_iderreg_ant, 0, v_pe_excant_coa, v_pe_excant_coa,
                                     v_itotcon_coa_ant, v_iips_coa_ant, v_idgs_coa_ant,
                                     v_iarbitr_coa_ant, v_ifng_coa_ant, v_irecfra_coa_ant,
                                     v_idtoom_coa_ant, v_iderreg_coa_ant);
                     END IF;

-- ACTUAL
                     IF v_pe_excact <> 0
                        OR v_itotcon_act <> 0
                        OR v_iips_act <> 0
                        OR v_idgs_act <> 0
                        OR v_iarbitr_act <> 0
                        OR v_ifng_act <> 0
                        OR v_irecfra_act <> 0
                        OR v_idtoom_act <> 0
                        OR v_iderreg_act <> 0
                        OR v_pe_excact_coa <> 0
                        OR v_itotcon_coa_act <> 0
                        OR v_iips_coa_act <> 0
                        OR v_idgs_act <> 0
                        OR v_iarbitr_act <> 0
                        OR v_ifng_act <> 0
                        OR v_irecfra_act <> 0
                        OR v_idtoom_act <> 0
                        OR v_iderreg_act <> 0 THEN
                        INSERT INTO ventascontab
                                    (sseguro, ctipo, cexerci, nanyven, nmesven,
                                     sproces, fcierre, fcalcul, cempres, cramo,
                                     cmodali, ctipseg, ccolect, cactivi,
                                     npoliza, ncertif, cagente, cagrpro,
                                     ctiprea, ctipcoa, ipridev, iprinet, ipemiti,
                                     itotcon, iips, idgs, iarbitr,
                                     ifng, irecfra, idtoom, iderreg,
                                     ipridev_coa, iprinet_coa, ipemiti_coa, itotcon_coa,
                                     iips_coa, idgs_coa, iarbitr_coa,
                                     ifng_coa, irecfra_coa, idtoom_coa,
                                     iderreg_coa)
                             VALUES (anul.sseguro, 2, 1, anul.nanyven, anul.nmesven,
                                     psproces, pfcierre, f_sysdate, anul.cempres, anul.cramo,
                                     anul.cmodali, anul.ctipseg, anul.ccolect, anul.cactivi,
                                     anul.npoliza, anul.ncertif, anul.cagente, anul.cagrpro,
                                     anul.ctiprea, anul.ctipcoa, 0, v_pe_excact, v_pe_excact,
                                     v_itotcon_act, v_iips_act, v_idgs_act, v_iarbitr_act,
                                     v_ifng_act, v_irecfra_act, v_idtoom_act, v_iderreg_act,
                                     0, v_pe_excact_coa, v_pe_excact_coa, v_itotcon_coa_act,
                                     v_iips_coa_act, v_idgs_coa_act, v_iarbitr_coa_act,
                                     v_ifng_coa_act, v_irecfra_coa_act, v_idtoom_coa_act,
                                     v_iderreg_coa_act);
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := 111112;   -- Error al insertar en la tabla VENTASCONTAB
                     text_error := text_error1 || SQLERRM || ' ' || SQLCODE;
               END;
            ELSIF pmodo = 3 THEN   -- simulación
/*******************************
           OJOOOOOOOOOO --> Falta repartir la prima del extorno para la simulación
                                       NUPACAMU.
**************************/
               BEGIN
                  -- Si la venta anulada del ejercicio anterior <> 0, entonces insertamos el
                  -- registro del ejercicio anterior que sólo tendrá información
                  -- de venta (tipo 4 anulación de pólizas)
                  IF v_anul_excant <> 0
                     OR v_anul_excant_coa <> 0 THEN
                     INSERT INTO ventascontabaux
                                 (sseguro, ctipo, cexerci, nanyven, nmesven, sproces,
                                  fcierre, fcalcul, cempres, cramo,
                                  cmodali, ctipseg, ccolect, cactivi,
                                  npoliza, ncertif, cagente, cagrpro,
                                  ctiprea, ctipcoa, ipridev, iprinet, ipemiti, itotcon, iips,
                                  idgs, iarbitr, ifng, irecfra, idtoom, iderreg, ipridev_coa,
                                  iprinet_coa, ipemiti_coa, itotcon_coa, iips_coa, idgs_coa,
                                  iarbitr_coa, ifng_coa, irecfra_coa, idtoom_coa, iderreg_coa)
                          VALUES (anul.sseguro, 4, 0, anul.nanyven, anul.nmesven, psproces,
                                  pfcierre, f_sysdate, anul.cempres, anul.cramo,
                                  anul.cmodali, anul.ctipseg, anul.ccolect, anul.cactivi,
                                  anul.npoliza, anul.ncertif, anul.cagente, anul.cagrpro,
                                  anul.ctiprea, anul.ctipcoa, v_anul_excant, 0, 0, 0, 0,
                                  0, 0, 0, 0, 0, 0, v_anul_excant_coa,
                                  0, 0, 0, 0, 0,
                                  0, 0, 0, 0, 0);
                  END IF;

                  -- Si la venta anulada del ejercicio actual <> 0, entonces insertamos el
                  -- registro del ejercicio actual que sólo tendrá información
                  -- de venta (tipo 4 anulación de pólizas)
                  IF v_anul_excact <> 0
                     OR v_anul_excact_coa <> 0 THEN
                     INSERT INTO ventascontabaux
                                 (sseguro, ctipo, cexerci, nanyven, nmesven, sproces,
                                  fcierre, fcalcul, cempres, cramo,
                                  cmodali, ctipseg, ccolect, cactivi,
                                  npoliza, ncertif, cagente, cagrpro,
                                  ctiprea, ctipcoa, ipridev, iprinet, ipemiti, itotcon, iips,
                                  idgs, iarbitr, ifng, irecfra, idtoom, iderreg, ipridev_coa,
                                  iprinet_coa, ipemiti_coa, itotcon_coa, iips_coa, idgs_coa,
                                  iarbitr_coa, ifng_coa, irecfra_coa, idtoom_coa, iderreg_coa)
                          VALUES (anul.sseguro, 4, 1, anul.nanyven, anul.nmesven, psproces,
                                  pfcierre, f_sysdate, anul.cempres, anul.cramo,
                                  anul.cmodali, anul.ctipseg, anul.ccolect, anul.cactivi,
                                  anul.npoliza, anul.ncertif, anul.cagente, anul.cagrpro,
                                  anul.ctiprea, anul.ctipcoa, v_anul_excact, 0, 0, 0, 0,
                                  0, 0, 0, 0, 0, 0, v_anul_excact_coa,
                                  0, 0, 0, 0, 0,
                                  0, 0, 0, 0, 0);
                  END IF;

                  -- Ahora insertamos el registro de prima extornada (tipo = 2) del recibo de anulación,
                  -- si la prima neta <> 0. Este registro siempre será sólo para el ejercicio actual
                  IF vdet.iprinet <> 0
                     OR vdet.iips <> 0
                     OR vdet.idgs <> 0
                     OR vdet.iarbitr <> 0
                     OR vdet.ifng <> 0
                     OR vdet.irecfra <> 0
                     OR vdet.idtoom <> 0
                     OR vdet.iderreg <> 0
                     OR vdet.it1con <> 0
                     OR vdet.icednet <> 0
                     OR vdet.it2con <> 0
                     OR vdet.icedips <> 0
                     OR vdet.iceddgs <> 0
                     OR vdet.icedarb <> 0
                     OR vdet.icedfng <> 0
                     OR vdet.icedrfr <> 0
                     OR vdet.iceddom <> 0
                     OR vdet.icedreg <> 0 THEN
                     INSERT INTO ventascontabaux
                                 (sseguro, ctipo, cexerci, nanyven, nmesven, sproces,
                                  fcierre, fcalcul, cempres, cramo,
                                  cmodali, ctipseg, ccolect, cactivi,
                                  npoliza, ncertif, cagente, cagrpro,
                                  ctiprea, ctipcoa, ipridev, iprinet, ipemiti,
                                  itotcon, iips, idgs, iarbitr, ifng,
                                  irecfra, idtoom, iderreg, ipridev_coa, iprinet_coa,
                                  ipemiti_coa, itotcon_coa, iips_coa, idgs_coa,
                                  iarbitr_coa, ifng_coa, irecfra_coa, idtoom_coa,
                                  iderreg_coa)
                          VALUES (anul.sseguro, 2, 1, anul.nanyven, anul.nmesven, psproces,
                                  pfcierre, f_sysdate, anul.cempres, anul.cramo,
                                  anul.cmodali, anul.ctipseg, anul.ccolect, anul.cactivi,
                                  anul.npoliza, anul.ncertif, anul.cagente, anul.cagrpro,
                                  anul.ctiprea, anul.ctipcoa, 0, vdet.iprinet, vdet.iprinet,
                                  vdet.it1con, vdet.iips, vdet.idgs, vdet.iarbitr, vdet.ifng,
                                  vdet.irecfra, vdet.idtoom, vdet.iderreg, 0, vdet.icednet,
                                  vdet.icednet, vdet.it2con, vdet.icedips, vdet.iceddgs,
                                  vdet.icedarb, vdet.icedfng, vdet.icedrfr, vdet.iceddom,
                                  vdet.icedreg);
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := 111112;   -- Error al insertar en la tabla VENTASCONTAB
                     text_error := text_error1 || SQLERRM || ' ' || SQLCODE;
               END;
            END IF;

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END LOOP;
      END LOOP;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         num_err := 444446;
         text_error := SQLERRM;
         RETURN num_err;
   END anulaciones_poliza;

----------------------------------------------------------------------------------------------
   FUNCTION calculo_ventas(
      psproces IN NUMBER,
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pfperfin IN DATE,
      text_error OUT VARCHAR2)
      RETURN NUMBER IS
/*********************************************************************************************
   función principal para el cálculo de ventas
**********************************************************************************************/-- Si el pmodo in (2,3), entonces sólo seleccionará la empresa del cierre. Si no,
 -- selecciona todas las empresas
      CURSOR c_empresas(pc_modo IN NUMBER) IS
         SELECT cempres
           FROM empresas
          WHERE cempres = DECODE(pc_modo, 1, cempres, pcempres);

      num_err        NUMBER;
      ult_fcierre    DATE;
      v_fcierre      cierres.fcierre%TYPE;   --       v_fcierre      DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
-- Para poder ejecutar la instruccion 'TRUNCATE'
      v_cursor       INTEGER;
      v_truncateventascontab VARCHAR2(40);
      v_truncatemovventascontab VARCHAR2(40);
      v_numrows      INTEGER;
   BEGIN
      IF pmodo = 1 THEN   -- si es el proceso diario para todas las empresas, hacemos un truncate
                          -- de las tablas porque es más optimo
         -- Borramos el contenido de la tablas
         BEGIN
            -- Para poder ejecutar la instruccion 'TRUNCATE' de movventass
            v_cursor := DBMS_SQL.open_cursor;
            v_truncatemovventascontab := 'TRUNCATE TABLE MOVVENTASCONTAB';
            DBMS_SQL.parse(v_cursor, v_truncatemovventascontab, DBMS_SQL.native);
            v_numrows := DBMS_SQL.EXECUTE(v_cursor);
            DBMS_SQL.close_cursor(v_cursor);
         EXCEPTION
            WHEN OTHERS THEN
               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;

               RETURN 108017;   -- Error al borrar las tablas
         END;
      ELSIF pmodo = 3 THEN   -- si hacemos una simulación del cierre truncamos otras tablas
         BEGIN
            -- Para poder ejecutar la instruccion 'TRUNCATE'
            v_cursor := DBMS_SQL.open_cursor;
            v_truncateventascontab := 'TRUNCATE TABLE VENTASCONTABAUX';
            v_truncatemovventascontab := 'TRUNCATE TABLE MOVVENTASCONTAB';
            DBMS_SQL.parse(v_cursor, v_truncateventascontab, DBMS_SQL.native);
            DBMS_SQL.parse(v_cursor, v_truncatemovventascontab, DBMS_SQL.native);
            v_numrows := DBMS_SQL.EXECUTE(v_cursor);
            DBMS_SQL.close_cursor(v_cursor);
         EXCEPTION
            WHEN OTHERS THEN
               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;

               RETURN 108017;   -- Error al borrar las tablas
         END;
      ELSE   -- si es cierre definitivo, sólo borramos de la tabla ventas los registros
             -- de la empresa que estamos cerrando
         COMMIT;
         SET TRANSACTION USE ROLLBACK SEGMENT rollbig;

         DELETE FROM movventascontab
               WHERE cempres = pcempres;
      END IF;

-- Primero lanzamos el proceso que graba en movseguro el mes y año de venta de los movimientos
-- que se han emitido durante el día
      num_err := f_fechventa;

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

-- Para cada empresa calculamos las ventas desde el último cierre
      FOR emp IN c_empresas(pmodo) LOOP
         -- Inicializamos las variables
         vg_nmesven := 0;
         vg_nanyven := 0;
         v_fcierre := NULL;

         IF pmodo IN(1, 3) THEN
            -- Miramos para que año y mes hay que hacer el cálculo
            num_err := fecha_calculo(emp.cempres, pmodo, v_fcierre, vg_nmesven, vg_nanyven);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         ELSIF pmodo = 2 THEN   --
            v_fcierre := pfperfin;
            vg_nmesven := TO_CHAR(pfperfin, 'mm');
            vg_nanyven := TO_CHAR(pfperfin, 'yyyy');
         END IF;

-- Borramos los meses no contabilizados de la empresa
         COMMIT;
         SET TRANSACTION USE ROLLBACK SEGMENT rollbig;

         DELETE FROM ventascontab v
               WHERE v.fcierre = v_fcierre
                 AND v.cempres = emp.cempres
                 AND NOT EXISTS(SELECT c.sproces
                                  FROM cierres c
                                 WHERE c.sproces = v.sproces);

         -- La fecha del último cierre del ejercicio anterior
         ult_fcierre := TO_DATE('0101' || vg_nanyven, 'ddmmyyyy');
         COMMIT;
         SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
         num_err := emitida_ejeant(pmodo, emp.cempres, psproces, v_fcierre, text_error);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         COMMIT;
         SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
         num_err := venta_generada(pmodo, emp.cempres, vg_nmesven, vg_nanyven, psproces,
                                   v_fcierre, f_sysdate, pmoneda, text_error);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         COMMIT;
         SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
         num_err := anulaciones_recibos(pmodo, emp.cempres, vg_nmesven, vg_nanyven, psproces,
                                        v_fcierre, ult_fcierre, f_sysdate, pmoneda, text_error);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         COMMIT;
         SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
         num_err := anulaciones_poliza(pmodo, emp.cempres, vg_nmesven, vg_nanyven, psproces,
                                       v_fcierre, f_sysdate, pmoneda, text_error);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         IF pmodo = 2
            AND vg_nmesven = 12 THEN   -- Si es el cierre definitivo de diciembre
                                       -- generamos la ppe con la que iniciaremos
            COMMIT;   -- el ejercicio siguiente.
            SET TRANSACTION USE ROLLBACK SEGMENT rollbig;
            num_err := f_ppeea(emp.cempres, vg_nanyven, pmoneda, psproces, text_error);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      END LOOP;

      RETURN num_err;
   END calculo_ventas;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_VENTASCONTAB" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_VENTASCONTAB" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_VENTASCONTAB" TO "PROGRAMADORESCSI";
