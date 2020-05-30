--------------------------------------------------------
--  DDL for Function F_DETRECIBOEXTRA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DETRECIBOEXTRA" (
   pnproces IN NUMBER,
   psseguro IN NUMBER,
   pnrecibo IN NUMBER,
   ptipomovimiento IN NUMBER,
   pmodo IN VARCHAR2,
   pcmodcom IN NUMBER,
   pfemisio IN DATE,
   pfefecto IN DATE,
   pfvencim IN DATE,
   pfcaranu IN DATE,
   pnimport IN NUMBER,
   pnriesgo IN NUMBER,
   pnmovimi IN NUMBER,
   pcpoliza IN NUMBER,
   pnimport2 OUT NUMBER)
   RETURN NUMBER IS
/************************************************************************
 Nueva función para generacion de recibos con conceptos extraordinarios
************************************************************************/
-- Para el fetch
   porcagente     NUMBER;
   porragente     NUMBER;
   w_error        VARCHAR2(4000);
   xcgarant       NUMBER;
   xnriesgo       NUMBER;
   xfiniefe       DATE;
   xnorden        NUMBER;
   xctarifa       NUMBER;
   xicapital      NUMBER;
   xprecarg       NUMBER;
   xiprianu       NUMBER;
   xfinefe        DATE;
   xcformul       NUMBER;
   xiextrap       NUMBER;
   xctipfra       NUMBER;
   xifranqu       NUMBER;
   xnmovimi       NUMBER;
   xidtocom       NUMBER;
   xnmovimiant    NUMBER;
-- Variables recuperadas de seguros
   xcforpag       NUMBER;
   xcrecfra       NUMBER;
   xpdtoord       NUMBER;
   xcagente       NUMBER;
   xfemisio       DATE;
   xcmodali       NUMBER;
   xccolect       NUMBER;
   xcramo         NUMBER;
   xctipseg       NUMBER;
   xcactivi       NUMBER;
   xcduraci       NUMBER;
   xnduraci       NUMBER;
   xndurcob       NUMBER;
   xcsituac       NUMBER;
   xctipcoa       NUMBER;
   xncuacoa       NUMBER;
   xinnomin       NUMBER;
   xfefepol       DATE;
   xnpoliza       NUMBER;
-- Para el select del garanseg con el movimiento anterior
   grabar         NUMBER;
   decimals       NUMBER := 0;
   xiconcep       NUMBER;
   difiprianu     NUMBER;
   comis_agente   NUMBER := 0;
   reten_agente   NUMBER := 0;
   xffinrec       DATE;
   xiprianu2      NUMBER;
   error          NUMBER := 0;
   xtotprimaneta  NUMBER;
   xtotprimadeve  NUMBER;
   ha_grabat      BOOLEAN := FALSE;
   pgrabar        NUMBER;
   xidtocom2      NUMBER;
   difidtocom     NUMBER;
   xnmeses        NUMBER;
   xffinany       DATE;
   xnimpcom       NUMBER;
   xnimpret       NUMBER;
   xccomisi       NUMBER;
   xcretenc       NUMBER;
   xccalcom       NUMBER;
   xcprorra       NUMBER;
   xcmodulo       NUMBER;
   xcmotmov       NUMBER;
   xaltarisc      BOOLEAN;
   xinsert        BOOLEAN;
   xnasegur       NUMBER;
   xnasegur1      NUMBER;
-- xcontriesg    NUMBER;
   xctiprec       NUMBER;
   xcimprim       NUMBER;
   xploccoa       NUMBER;
   xpcomcoa       NUMBER;
   xcapieve       NUMBER;
   xfmovim        DATE;
   xsproduc       NUMBER;
-- Variables para el cálculo de prorrateos
   difdias        NUMBER;
   difdiasanu     NUMBER;
   difdias2       NUMBER;
   difdiasanu2    NUMBER;
   divisor        NUMBER;
   divisor2       NUMBER;
   fanyoprox      DATE;
   facnet         NUMBER;
   facdev         NUMBER;
   facnetsup      NUMBER;
   facdevsup      NUMBER;
   facconsor      NUMBER;
   xpro_np_360    NUMBER;
   comis_cia      NUMBER := 0;
   xex_pte_imp    NUMBER;
   lcvalpar       NUMBER;
   xcestaux       NUMBER;
   xcageven_gar   NUMBER;
   xnmovima       NUMBER;
   xnmovima_gar   NUMBER;
   xxcageven_gar  NUMBER;
   xxnmovima_gar  NUMBER;
   sw_aln         NUMBER;
   sw_cextr       NUMBER;
   w_nmeses_cexter NUMBER;
   w_importe_aux  NUMBER;

   CURSOR cur_garanseg IS
      SELECT cgarant, nriesgo, finiefe, norden, ctarifa, NVL(icaptot, 0), precarg,
             NVL(ipritot, 0), ffinefe, cformul, iextrap, ctipfra, ifranqu, nmovimi, idtocom,
             cageven, nmovima
        FROM garanseg
       WHERE sseguro = psseguro
         AND nriesgo = NVL(pnriesgo, nriesgo)
         AND nmovimi = pnmovimi;

   CURSOR cur_garancar IS
      SELECT cgarant, nriesgo, finiefe, norden, ctarifa, NVL(icaptot, 0), precarg,
             NVL(ipritot, 0), ffinefe, cformul, iextrap, idtocom, cageven, nmovima
        FROM garancar
       WHERE sseguro = psseguro
         AND nriesgo = NVL(pnriesgo, nriesgo);

--     AND TRUNC(pfefecto) >= TRUNC(finiefe)
--     AND ((TRUNC(pfefecto) < TRUNC(ffinefe)) OR (ffinefe is null));
   FUNCTION fl_inbucle_extrarec(
      pnrecibo IN NUMBER,
      pfemisrec IN DATE,
      psseguro IN NUMBER,
      pcgarant IN NUMBER,
      pploccoa IN NUMBER,
      pctipcoa IN NUMBER,
      pcageven IN NUMBER,
      pnmovima IN NUMBER,
      pnproces IN NUMBER,
      pnriesgo IN NUMBER,
      pnmeses IN NUMBER)
      RETURN NUMBER IS
      CURSOR cur_inbucle_extrarec(
         esseguro NUMBER,
         ecgarant NUMBER,
         enriesgo NUMBER,
         enmeses NUMBER,
         eefemis DATE) IS
         SELECT SUM(NVL(iextrarec, 0))
           FROM extrarec
          WHERE sseguro = esseguro
            AND cgarant = ecgarant
            AND nriesgo = enriesgo
            AND nrecibo IS NULL;

      w_importe      NUMBER(15, 3);
   BEGIN
--
-- Rutina que, dentro del bucle de tratamiento del recibo, graba acumulados
--   de conceptos extraordinarios para la garantia dada
--
      OPEN cur_inbucle_extrarec(psseguro, pcgarant, pnriesgo, pnmeses, pfemisrec);

      FETCH cur_inbucle_extrarec
       INTO w_importe;

      IF cur_inbucle_extrarec%NOTFOUND THEN
         CLOSE cur_inbucle_extrarec;

         RETURN 0;
      END IF;

      CLOSE cur_inbucle_extrarec;

      IF w_importe <> 0 THEN
--
-- Insercion de un registro en DETRECIBOS con codigo de concepto 26, y posterior
--   UPDATE de la tabla EXTRAREC informando NRECIBO en los registros sumados en
--   el cursor.
--
         IF pmodo = 'R' THEN   -- (MODE REAL PRODUCCIÓ I CARTERA)
            error := f_insdetrec(pnrecibo, 26, w_importe, pploccoa, pcgarant, pnriesgo,
                                 pctipcoa, pcageven, pnmovima);
         ELSE
            error := f_insdetreccar(pnproces, pnrecibo, 26, w_importe, pploccoa, pcgarant,
                                    pnriesgo, pctipcoa, pcageven, pnmovima);
         END IF;

         IF error <> 0 THEN
            RETURN error;
         END IF;

         IF pmodo = 'R' THEN
            BEGIN
               UPDATE extrarec
                  SET nrecibo = pnrecibo
                WHERE sseguro = psseguro
                  AND cgarant = pcgarant
                  AND nriesgo = pnriesgo;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 111939;   -- Error modificando tabla EXTRAREC
            END;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF cur_inbucle_extrarec%ISOPEN THEN
            CLOSE cur_inbucle_extrarec;
         END IF;

         RETURN 111938;   -- Error leyendo datos de la tabla EXTRAREC
   END fl_inbucle_extrarec;

   FUNCTION fl_grabar_calcomisprev(
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pcgarant IN NUMBER,
      pnriesgo IN NUMBER,
      pcageven IN NUMBER,
      pnmovima IN NUMBER,
      picalcom IN OUT NUMBER,
      pfefecto_rec IN DATE,
      pfvto_rec IN DATE,
      pmodo IN VARCHAR2)
      RETURN NUMBER IS
      sw_cgencom     NUMBER(1);
      sw_cgendev     NUMBER(1);
      error          NUMBER;
      w_difmeses     NUMBER;
      w_fechaux1     DATE;
      w_fechaux2     DATE;
      w_calcom       NUMBER;
      w_nmeses       NUMBER;
      w_icomcob      NUMBER := 0;
   BEGIN
--
-- Funcion que graba los datos necesarios en la tabla CALCOMISPREV
--   para poder realizar el calculo de comisiones para ALN
--

      --
-- Buscamos la primera fecha de inicio de la garantia en la tabla MOVRECIBO
--
      BEGIN
         SELECT fefecto
           INTO w_fechaux1
           FROM movseguro
          WHERE sseguro = psseguro
            AND nmovimi = pnmovima;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 104349;
         WHEN OTHERS THEN
            RETURN 104349;
      END;

--
-- Buscamos la diferencia en meses de la fecha de efecto de la garantia
--   y la fecha de efecto del recibo
--
      error := f_difdata(w_fechaux1, pfefecto_rec, 1, 2, w_difmeses);

      IF error <> 0 THEN
         RETURN error;
      END IF;

--
-- Si la diferencia en meses es cero, generamos la comision devengada
--
      IF w_difmeses = 0 THEN
         sw_cgendev := 1;
      ELSE
         sw_cgendev := 0;
      END IF;

--
-- Si la diferencia de meses es menor que el numero de meses de pago, se generan
--   comisiones
--
      BEGIN
         SELECT DECODE(NVL(nmescob, 0), 0, 12, nmescob)
           INTO w_nmeses
           FROM agentes
          WHERE cagente = pcageven;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            w_nmeses := 12;
         WHEN OTHERS THEN
            w_nmeses := 12;
      END;

--
-- Calculamos el importe a aplicar a los agentes cobradores
--
      IF pmodo = 'R' THEN
         BEGIN
            SELECT SUM(NVL(iconcep, 0))
              INTO w_icomcob
              FROM detrecibos
             WHERE nrecibo = pnrecibo
               AND cgarant = pcgarant
               AND nriesgo = pnriesgo
               AND cconcep IN(0, 26);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               w_icomcob := 0;
            WHEN OTHERS THEN
               w_icomcob := 0;
         END;
      ELSE
         BEGIN
            SELECT SUM(NVL(iconcep, 0))
              INTO w_icomcob
              FROM detreciboscar
             WHERE nrecibo = pnrecibo
               AND cgarant = pcgarant
               AND nriesgo = pnriesgo
               AND cconcep IN(0, 26);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               w_icomcob := 0;
            WHEN OTHERS THEN
               w_icomcob := 0;
         END;
      END IF;

      IF w_difmeses <= w_nmeses THEN
         sw_cgencom := 1;
      ELSE
         sw_cgencom := 0;
      END IF;

--
-- Calculo del porcentaje de comisión a pagar para dicho recibo
--
      w_fechaux2 := ADD_MONTHS(w_fechaux1, w_nmeses);

      IF pfvto_rec < w_fechaux2 THEN
         w_fechaux1 := pfvto_rec;
      ELSE
         w_fechaux1 := w_fechaux2;
      END IF;

      IF pfefecto_rec > w_fechaux1 THEN
         w_calcom := 0;
         sw_cgencom := 0;
         sw_cgendev := 0;
      ELSE
         error := f_difdata(pfefecto_rec, w_fechaux1, 1, 2, w_difmeses);

         IF error <> 0 THEN
            RETURN error;
         END IF;

         w_calcom := w_difmeses;
      END IF;

      IF NVL(picalcom, 0) = 0 THEN
--
-- Si el importe es nulo o cero, no se calcularán comisiones
--
         sw_cgencom := 0;
         sw_cgendev := 0;
      END IF;

      BEGIN
         INSERT INTO calcomisprev
                     (nrecibo, cgarant, nriesgo, cageven, nmovima, icalcom, pcalcom,
                      icomcob, nmesagt, cgencom, cgendev)
              VALUES (pnrecibo, pcgarant, pnriesgo, pcageven, pnmovima, picalcom, w_calcom,
                      w_icomcob, w_nmeses, sw_cgencom, sw_cgendev);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 111923;   -- Error al insertar datos en la tabla CALCOMISPREV
      END;

      RETURN 0;
   END fl_grabar_calcomisprev;
BEGIN
-- Cal veure si s'han de deixar els extorns pendents d'imprimir o de transferir
   xex_pte_imp := NVL(f_parinstalacion_n('EX_PTE_IMP'), 0);
   sw_aln := 0;

   IF NVL(f_parinstalacion_t('CONCEPEXTR'), 'NO') = 'SI' THEN
      sw_cextr := 1;
      w_nmeses_cexter := NVL(f_parinstalacion_n('CEXTRNMES'), 0);
   ELSE
      sw_cextr := 0;
   END IF;

   BEGIN
      SELECT cforpag, crecfra, pdtoord, cagente, femisio, cmodali, ccolect, cramo,
             ctipseg, pac_seguros.ff_get_actividad(sseguro, pnriesgo), cduraci, nduraci,
             ndurcob, csituac, ctipcoa, ncuacoa, cobjase, fefecto, npoliza, sproduc
        INTO xcforpag, xcrecfra, xpdtoord, xcagente, xfemisio, xcmodali, xccolect, xcramo,
             xctipseg, xcactivi, xcduraci, xnduraci,
             xndurcob, xcsituac, xctipcoa, xncuacoa, xinnomin, xfefepol, xnpoliza, xsproduc
        FROM seguros
       WHERE sseguro = psseguro;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 101903;   -- Seguro no encontrado en la tabla SEGUROS
      WHEN OTHERS THEN
         RETURN 101919;   -- Error al llegir dades de la taula SEGUROS
   END;

   BEGIN
      SELECT ccalcom, cprorra, DECODE(cdivisa, 2, 2, 3, 1)
        INTO xccalcom, xcprorra, decimals
        FROM productos
       WHERE cramo = xcramo
         AND cmodali = xcmodali
         AND ctipseg = xctipseg
         AND ccolect = xccolect;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 104347;   -- Producte no trobat a PRODUCTOS
      WHEN OTHERS THEN
         RETURN 102705;   -- Error al llegir de PRODUCTOS
   END;

   IF pmodo = 'A' THEN   -- només grabem a DETRECIBOS
      NULL;
   ELSE
      -- Estem en el cas de proves ('P') o real ('R') o recibo anual impresión ('N') o
      -- recibo sobre intereses ('I')
      -- Comprobem si existeix l' assegurança entrada com a paràmetre
      IF pmodo = 'N' THEN   -- Estem en el cas de rebut previ (anual)
         xcforpag := 1;
      END IF;

      error := f_buscanmovimi(psseguro, 1, 1, xnmovimiant);

      IF error <> 0 THEN
         RETURN error;
      END IF;

      IF xccalcom = 1 THEN   -- Sobre prima
         error := f_pcomisi(psseguro, pcmodcom, f_sysdate, comis_agente, reten_agente);

         IF error <> 0 THEN
            RETURN error;
         END IF;

         -- Se añade el calculo de la comision para la compañia.
         error := f_pcomisi_cia(xcramo, xcmodali, xctipseg, xccolect, xcactivi, pcmodcom,
                                comis_cia);

         IF error <> 0 THEN
            RETURN error;
         END IF;
      ELSIF xccalcom = 2 THEN   -- Sobre interés
         comis_agente := 0;
         reten_agente := 0;
         comis_cia := 0;
      ELSIF xccalcom = 3 THEN   -- Sobre prov. mat.
         comis_agente := 0;
         reten_agente := 0;
         comis_cia := 0;
      END IF;

      IF pnmovimi IS NOT NULL THEN
         BEGIN
            SELECT cmotmov
              INTO xcmotmov
              FROM movseguro
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi;

            IF xcmotmov = 243 THEN
               xaltarisc := TRUE;
            ELSE
               xaltarisc := FALSE;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 104348;   -- Num. moviment no trobat a MOVSEGURO
            WHEN OTHERS THEN
               RETURN 104349;   -- Error al llegir de MOVSEGURO
         END;
      END IF;

      IF ptipomovimiento = 6 THEN   -- Estem en el cas de rebut de regularització
         xcforpag := 0;   -- Calcularem com a forma de pagament única

         -- Si no es una regularització de tickets
         IF xcmotmov NOT IN(602, 604) THEN   -- o de capital eventual
            xcduraci := 3;   -- Aplicarem reducció per assegurança de temporada
         ELSIF xcmotmov = 604 THEN
            xcapieve := 1;   -- Es de capital eventual
         END IF;
      END IF;

      /******** Cálculo de los factores a aplicar para el prorrateo ********/
      xffinrec := pfvencim;
      xffinany := pfcaranu;
      fanyoprox := ADD_MONTHS(pfefecto, 12);   -- Para calcular el divisor del modulo 365 (365 o 366)

      IF xcforpag <> 0 THEN
         IF xffinany IS NULL THEN
            IF xndurcob IS NULL THEN
               RETURN 104515;   -- El camp ndurcob de SEGUROS ha de estar informat
            END IF;

            xnmeses := (xndurcob + 1) * 12;
            xffinany := ADD_MONTHS(pfefecto, xnmeses);

            IF xffinrec IS NULL THEN
               xffinrec := xffinany;
            END IF;
         END IF;
      ELSE
         xffinany := xffinrec;
      END IF;

      -- Cálculo de días
      IF xcprorra = 2 THEN   -- Mod. 360
         xcmodulo := 3;
      ELSE   -- Mod. 365
         xcmodulo := 1;
      END IF;

      error := f_difdata(pfefecto, xffinrec, 3, 3, difdias);

      IF error <> 0 THEN
         RETURN error;
      END IF;

      error := f_difdata(pfefecto, xffinany, 3, 3, difdiasanu);

      IF error <> 0 THEN
         RETURN error;
      END IF;

      error := f_difdata(pfefecto, xffinrec, xcmodulo, 3, difdias2);   -- dias recibo

      IF error <> 0 THEN
         RETURN error;
      END IF;

      error := f_difdata(pfefecto, xffinany, xcmodulo, 3, difdiasanu2);   -- dias venta

      IF error <> 0 THEN
         RETURN error;
      END IF;

      error := f_difdata(pfefecto, fanyoprox, xcmodulo, 3, divisor2);

      IF error <> 0 THEN
         RETURN error;
      END IF;

      error := f_difdata(xfefepol, xffinrec, xcmodulo, 3, divisor);

      IF error <> 0 THEN
         RETURN error;
      END IF;

      -- Calculem els factors a aplicar per prorratejar
      IF xcprorra IN(1, 2) THEN   -- Per dies
         IF xcforpag <> 0
            --  DRA:28/10/2013:0028690: POSTEC Camio forma de pago
            OR NVL(f_parproductos_v(xsproduc, 'PRORR_PRIMA_UNICA'), 0) = 1 THEN
            -- El càlcul del factor a la nova producció si s'ha de prorratejar, es fará modul 360 o
            -- mòdul 365 segon un paràmetre d'instal.lació
            xpro_np_360 := f_parinstalacion_n('PRO_NP_360');

            IF NVL(xpro_np_360, 1) = 1 THEN
               facnet := difdias / 360;
               facdev := difdiasanu / 360;
            ELSE
               IF MOD(difdias, 30) = 0 THEN
                  -- No hi ha prorrata
                  facnet := difdias / 360;
                  facdev := difdiasanu / 360;
               ELSE
                  -- Hi ha prorrata, prorratejem mòdul 365
                  facnet := difdias2 / divisor2;
                  facdev := difdiasanu2 / divisor2;
               END IF;
            END IF;

            facnetsup := difdias2 / divisor2;
            facdevsup := difdiasanu2 / divisor2;
         ELSE
            facnet := 1;
            facdev := 1;
            facnetsup := difdias2 / divisor;
            facdevsup := difdiasanu2 / divisor;
         END IF;
      ELSIF xcprorra = 3 THEN
         BEGIN
            SELECT f1.npercen / 100
              INTO facnet
              FROM federaprimas f1
             WHERE f1.npoliza = xnpoliza
               AND f1.diames = (SELECT MAX(f2.diames)
                                  FROM federaprimas f2
                                 WHERE f1.npoliza = f2.npoliza
                                   AND f2.diames <= TO_CHAR(pfefecto, 'mm/dd'));
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 109086;   -- Porcentajes de prorrateo no dados de alta para la póliza
         END;

         IF xcforpag <> 0 THEN
            RETURN 109087;   -- Tipo de prorrateo incompatible con la forma de pago
         ELSE
            facdev := facnet;
            facnetsup := facnet;
            facdevsup := facnet;
         END IF;
      ELSE
         RETURN 109085;   -- Codi de prorrateig inexistent
      END IF;

      IF pmodo = 'R'
         OR pmodo = 'I' THEN
         BEGIN
            SELECT ctiprec, cestaux
              INTO xctiprec, xcestaux
              FROM recibos
             WHERE nrecibo = pnrecibo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 101902;   -- Rebut no trobat a RECIBOS
            WHEN OTHERS THEN
               RETURN 102367;   -- Error al llegir de RECIBOS
         END;
      ELSE
         BEGIN
            SELECT ctiprec, cestaux
              INTO xctiprec, xcestaux
              FROM reciboscar
             WHERE sproces = pnproces
               AND nrecibo = pnrecibo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 105304;   -- Rebut no trobat a RECIBOSCAR
            WHEN OTHERS THEN
               RETURN 105305;   -- Error al llegir de RECIBOSCAR
         END;
      END IF;

      -- Buscamos el porcentaje local si es un coaseguro.
      IF xctipcoa != 0 THEN
         BEGIN
            SELECT ploccoa
              INTO xploccoa
              FROM coacuadro
             WHERE ncuacoa = xncuacoa
               AND sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 105447;
         END;
      END IF;

--****************************************************************
--******************   M O D O    R E A L  ***********************
--****************************************************************
      IF pmodo = 'R' THEN   -- MODE REAL (Producció i Cartera)
         OPEN cur_garanseg;

         FETCH cur_garanseg
          INTO xcgarant, xnriesgo, xfiniefe, xnorden, xctarifa, xicapital, xprecarg, xiprianu,
               xfinefe, xcformul, xiextrap, xctipfra, xifranqu, xnmovimi, xidtocom,
               xcageven_gar, xnmovima_gar;

         WHILE cur_garanseg%FOUND LOOP
            xnasegur := NULL;
            xnasegur1 := NULL;
            xidtocom := 0 - NVL(xidtocom, 0);

            -- comprobem si hi ha més d'un registre pel mateix cgarant-nriesgo-
            -- nmovimi-finiefe
            BEGIN
               SELECT DECODE(nasegur, NULL, 1, nasegur), nmovima
                 INTO xnasegur, xnmovima
                 FROM riesgos
                WHERE sseguro = psseguro
                  AND nriesgo = xnriesgo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  CLOSE cur_garanseg;

                  RETURN 103836;
               WHEN OTHERS THEN
                  CLOSE cur_garanseg;

                  RETURN 103509;
            END;

-- *******************************************************************************
-- Cálcul de la prima del concepte 26.
-- *******************************************************************************

            -- ********** Conceptos extraordinarios ***********
            IF sw_cextr = 1 THEN
               error := fl_inbucle_extrarec(pnrecibo, pfemisio, psseguro, xcgarant, xploccoa,
                                            xctipcoa, xcageven_gar, xnmovima_gar, NULL,
                                            xnriesgo, w_nmeses_cexter);

               IF error <> 0 THEN
                  CLOSE cur_garanseg;

                  RETURN error;
               END IF;

               IF sw_aln = 1 THEN
                  w_importe_aux := 0;
                  error := fl_grabar_calcomisprev(psseguro, pnrecibo, xcgarant, xnriesgo,
                                                  xcageven_gar, xnmovima_gar, w_importe_aux,
                                                  pfefecto, pfvencim, pmodo);

                  IF error <> 0 THEN
                     CLOSE cur_garanseg;

                     RETURN error;
                  END IF;

                  IF xctipcoa = 8
                     OR xctipcoa = 9 THEN
                     BEGIN
                        SELECT pcomcoa
                          INTO xpcomcoa
                          FROM coacedido
                         WHERE sseguro = psseguro
                           AND ncuacoa = xncuacoa;
                     EXCEPTION
                        WHEN OTHERS THEN
                           CLOSE cur_garanseg;

                           RETURN 105582;   -- ERROR AL LEER DE LA TABLA COACEDIDO
                     END;

                     IF xpcomcoa IS NULL THEN
                        porcagente := comis_agente;
                        porragente := reten_agente;
                     ELSE
                        porcagente := 0;
                        porragente := 0;
                     END IF;
                  ELSE
                     porcagente := comis_agente;
                     porragente := reten_agente;
                  END IF;

                  error := f_calculocomisiones(pnproces, pnrecibo, xploccoa, xcgarant,
                                               NVL(xnriesgo, 0), xctipcoa, psseguro, pmodo,
                                               pcmodcom, porcagente, porragente);

                  IF error <> 0 THEN
                     CLOSE cur_garanseg;

                     RETURN error;
                  END IF;
               END IF;
            END IF;

            FETCH cur_garanseg
             INTO xcgarant, xnriesgo, xfiniefe, xnorden, xctarifa, xicapital, xprecarg,
                  xiprianu, xfinefe, xcformul, xiextrap, xctipfra, xifranqu, xnmovimi,
                  xidtocom, xcageven_gar, xnmovima_gar;
         END LOOP;

         CLOSE cur_garanseg;

         error := f_vdetrecibos(pmodo, pnrecibo);

         IF error <> 0 THEN
            RETURN error;
         END IF;
      ELSIF pmodo = 'P' THEN   -- proves (avanç cartera)
--*****************************************************************
--********************** M O D O    P R U E B A S *****************
--*****************************************************************
         OPEN cur_garancar;

         FETCH cur_garancar
          INTO xcgarant, xnriesgo, xfiniefe, xnorden, xctarifa, xicapital, xprecarg, xiprianu,
               xfinefe, xcformul, xiextrap, xidtocom, xcageven_gar, xnmovima_gar;

         WHILE cur_garancar%FOUND LOOP
            xnasegur := NULL;
            xnasegur1 := NULL;

            BEGIN
               SELECT DECODE(nasegur, NULL, 1, nasegur)
                 INTO xnasegur
                 FROM riesgos
                WHERE sseguro = psseguro
                  AND nriesgo = xnriesgo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  CLOSE cur_garancar;

                  RETURN 103836;
               WHEN OTHERS THEN
                  CLOSE cur_garancar;

                  RETURN 103509;
            END;

            xidtocom := 0 - NVL(xidtocom, 0);

            -- ********** Conceptos extraordinarios ***********
            IF sw_cextr = 1 THEN
               error := fl_inbucle_extrarec(pnrecibo, pfemisio, psseguro, xcgarant, xploccoa,
                                            xctipcoa, xcageven_gar, xnmovima_gar, pnproces,
                                            xnriesgo, w_nmeses_cexter);

               IF error <> 0 THEN
                  CLOSE cur_garancar;

                  RETURN error;
               END IF;

               IF sw_aln = 1 THEN
                  w_importe_aux := 0;
                  error := fl_grabar_calcomisprev(psseguro, pnrecibo, xcgarant, xnriesgo,
                                                  xcageven_gar, xnmovima_gar, w_importe_aux,
                                                  pfefecto, pfvencim, pmodo);

                  IF error <> 0 THEN
                     CLOSE cur_garancar;

                     RETURN error;
                  END IF;

                  IF xctipcoa = 8
                     OR xctipcoa = 9 THEN
                     BEGIN
                        SELECT pcomcoa
                          INTO xpcomcoa
                          FROM coacedido
                         WHERE sseguro = psseguro
                           AND ncuacoa = xncuacoa;
                     EXCEPTION
                        WHEN OTHERS THEN
                           CLOSE cur_garancar;

                           RETURN 105582;   -- ERROR AL LEER DE LA TABLA COACEDIDO
                     END;

                     IF xpcomcoa IS NULL THEN
                        porcagente := comis_agente;
                        porragente := reten_agente;
                     ELSE
                        porcagente := 0;
                        porragente := 0;
                     END IF;
                  ELSE
                     porcagente := comis_agente;
                     porragente := reten_agente;
                  END IF;

                  error := f_calculocomisiones(pnproces, pnrecibo, xploccoa, xcgarant,
                                               NVL(xnriesgo, 0), xctipcoa, psseguro, pmodo,
                                               pcmodcom, porcagente, porragente);

                  IF error <> 0 THEN
                     CLOSE cur_garancar;

                     RETURN error;
                  END IF;
               END IF;
            END IF;

            FETCH cur_garancar
             INTO xcgarant, xnriesgo, xfiniefe, xnorden, xctarifa, xicapital, xprecarg,
                  xiprianu, xfinefe, xcformul, xiextrap, xidtocom, xcageven_gar, xnmovima_gar;
         END LOOP;

         CLOSE cur_garancar;

         error := f_vdetrecibos(pmodo, pnrecibo, pnproces);

         IF error <> 0 THEN
            RETURN error;
         END IF;
      END IF;
   END IF;

   RETURN 0;
END f_detreciboextra;

/

  GRANT EXECUTE ON "AXIS"."F_DETRECIBOEXTRA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DETRECIBOEXTRA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DETRECIBOEXTRA" TO "PROGRAMADORESCSI";
