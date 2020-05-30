--------------------------------------------------------
--  DDL for Function F_SOLDETRECIBO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SOLDETRECIBO" (
   pnproces IN NUMBER,
   pssolicit IN NUMBER,
   pnrecibo IN NUMBER,
   pcforpag IN NUMBER,
   pmodo IN VARCHAR2,
   pfefecto IN DATE,
   pfvencim IN DATE,
   pfcaranu IN DATE,
   pnriesgo IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/* ******************************************************************
                FUNCIÓN LLAMADA DESDE LOS PROGRAMAS DE ESTUDIOS PARA REALIZAR
                EL CÁLCULO DEL  PRIMER RECIBO Y RECIBO ANUAL EN LA IMPRESIÓN
                DE LA SOLICITUD.
PARÁMETROS:
            PNPROCES : Nº DE PROCESO.
            PSSOLICIT: Nº DE SOLICITUD.
            PNRECIBO : Nº DEL RECIBO A CALCULAR.
            PCFORPAG : FORMA DE PAGO AL CALCULAR.
            PMODO    : MODO DE LA LLAMADA. VALORES: 'PR': PRIMER RECIBO.
                                                    'AN': RECIBO ANUAL.
            PFEFECTO : EFECTO DEL RECIBO.
            PFVENCIM : VENCIMIENTO DEL RECIBO.
            PFCARANU : FECHA DE LA RENOVACIÓN ANUAL.
            PNRIESGO : NUM. DEL RIESGO.    VALORES: NULL: UN RECIBO PARA TODOS LOS RIESGOS.
                                                    Nº. : UN RECIBO PARA ESE RIESGO.
************************************************************************ */
-- PARA EL FETCH
   xcgarant       NUMBER;
   xnriesgo       NUMBER;
   xnorden        NUMBER;
   xctarifa       NUMBER;
   xicapital      NUMBER;
   xprecarg       NUMBER;
   xiprianu       NUMBER;
   xcformul       NUMBER;
   xiextrap       NUMBER;
   xctipfra       NUMBER;
   xifranqu       NUMBER;
   xidtocom       NUMBER;
-- VARIABLES RECUPERADAS DE SOLSEGUROS
   xcforpag       NUMBER;
   xcagente       NUMBER;
   xcramo         NUMBER;
   xcmodali       NUMBER;
   xccolect       NUMBER;
   xctipseg       NUMBER;
   xcactivi       NUMBER;
   xcduraci       NUMBER;
   xnduraci       NUMBER;
   xndurcob       NUMBER;
   xsproduc       NUMBER;
   xinnomin       NUMBER;
/* POR SI SE AÑADE EL COASEGURO */
   xctipcoa       NUMBER := 0;   -- FORZAMOS A "NO COASEGURO"
--    XNCUACOA      NUMBER;
-- VARIABLES RECUPERADAS DE PRODUCTOS
   xcrecfra       NUMBER;
-- VARIABLES DE TRABAJO
   grabar         NUMBER;
   decimals       NUMBER := 0;
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
   xcmotmov       NUMBER;
   xaltarisc      BOOLEAN;
   xinsert        BOOLEAN;
   xnasegur       NUMBER;
   xcontriesg     NUMBER;
   xcimprim       NUMBER;
   xfmovim        DATE;
   xploccoa       NUMBER;
-- VARIABLES PARA EL CÁLCULO DE PRORRATEOS
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

/* COASEGURO: USAR EL ICAPTOT Y EL IPRITOT */
   CURSOR cur_garanseg IS
      SELECT cgarant, nriesgo, norden, ctarifa, /* NVL(ICAPTOT,0),*/ NVL(icapital, 0),
             precarg, /*NVL(IPRITOT, 0),*/ NVL(iprianu, 0), cformul, iextrap, ctipfra,
             ifranqu, idtocom
        FROM solgaranseg
       WHERE ssolicit = pssolicit
--               AND NRIESGO = NVL(PNRIESGO, NRIESGO);
         AND(nriesgo = pnriesgo
             OR pnriesgo IS NULL);
BEGIN
   -- COMPROBEM SI EXISTEIX L' ASSEGURANÇA ENTRADA COM A PARÀMETRE
   BEGIN
      SELECT cagente, cmodali, ccolect, cramo, ctipseg, cactivi, cduraci, nduraci,
             ndurcob, cobjase, sproduc
        INTO xcagente, xcmodali, xccolect, xcramo, xctipseg, xcactivi, xcduraci, xnduraci,
             xndurcob, xinnomin, xsproduc
        FROM solseguros
       WHERE ssolicit = pssolicit;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 101903;   -- SEGURO NO ENCONTRADO EN LA TABLA SEGUROS
      WHEN OTHERS THEN
         RETURN 101919;   -- ERROR AL LLEGIR DADES DE LA TAULA SEGUROS
   END;

   xcforpag := pcforpag;

   IF pmodo = 'AN' THEN   -- ESTEM EN EL CAS DE REBUT PREVI (ANUAL)
      xcforpag := 1;
   END IF;

   BEGIN
      SELECT crecfra
        INTO xcrecfra
        FROM productos
       WHERE cramo = xcramo
         AND cmodali = xcmodali
         AND ctipseg = xctipseg
         AND ccolect = xccolect;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 104347;   -- PRODUCTE NO TROBAT A PRODUCTOS
      WHEN OTHERS THEN
         RETURN 102705;   -- ERROR AL LLEGIR DE PRODUCTOS
   END;

--
/******** CÁLCULO DE LOS FACTORES A APLICAR PARA EL PRORRATEO ********/
--
   xffinrec := pfvencim;
   xffinany := pfcaranu;
   fanyoprox := ADD_MONTHS(pfefecto, 12);   -- PARA CALCULAR EL DIVISOR DEL MODULO 365 (365 O 366)

   IF xcforpag <> 0 THEN
      IF xffinany IS NULL THEN
         IF xndurcob IS NULL THEN
            RETURN 104515;   -- EL CAMP NDURCOB DE SEGUROS HA DE ESTAR INFORMAT
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

   error := f_difdata(pfefecto, xffinrec, 3, 3, difdias);

   IF error <> 0 THEN
      RETURN error;
   END IF;

   error := f_difdata(pfefecto, xffinany, 3, 3, difdiasanu);

   IF error <> 0 THEN
      RETURN error;
   END IF;

   error := f_difdata(pfefecto, xffinrec, 1, 3, difdias2);   -- DIAS RECIBO

   IF error <> 0 THEN
      RETURN error;
   END IF;

   error := f_difdata(pfefecto, xffinany, 1, 3, difdiasanu2);   -- DIAS VENTA

   IF error <> 0 THEN
      RETURN error;
   END IF;

   error := f_difdata(pfefecto, fanyoprox, 1, 3, divisor2);   -- DIVISOR DEL MÓDULO DE SUPLEMENTOS PARA PAGOS ANUALES

   IF error <> 0 THEN
      RETURN error;
   END IF;

   error := f_difdata(pfefecto, xffinrec, 1, 3, divisor);   -- DIVISOR DEL PERIODO PARA PAGO ÚNICO

   IF error <> 0 THEN
      RETURN error;
   END IF;

   -- CALCULEM ELS FACTORS A APLICAR PER PRORRATEJAR
   IF xcforpag <> 0
      --  DRA:28/10/2013:0028690: POSTEC Camio forma de pago
      OR NVL(f_parproductos_v(xsproduc, 'PRORR_PRIMA_UNICA'), 0) = 1 THEN
      facnet := difdias / 360;
      facdev := difdiasanu / 360;
      facnetsup := difdias2 / divisor2;
      facdevsup := difdiasanu2 / divisor2;
   ELSE
      facnet := 1;
      facdev := 1;
      facnetsup := difdias2 / divisor;
      facdevsup := difdiasanu2 / divisor;
   END IF;

/************* DE MOMENTO NO HAY COASEGURO
   -- BUSCAMOS EL PORCENTAJE LOCAL SI ES UN COASEGURO.
   IF XCTIPCOA!= 0 THEN
     BEGIN
       SELECT PLOCCOA
         INTO XPLOCCOA
         FROM SOLCOACUADRO
        WHERE NCUACOA = XNCUACOA
          AND SSEGURO = PSSOLICIT;
   EXCEPTION
     WHEN OTHERS THEN
       RETURN 105447;
   END;
   END IF;
******************/
-- INICIO DEL CÁLCULO DE LOS CONCEPTOS DEL RECIBO
   OPEN cur_garanseg;

   FETCH cur_garanseg
    INTO xcgarant, xnriesgo, xnorden, xctarifa, xicapital, xprecarg, xiprianu, xcformul,
         xiextrap, xctipfra, xifranqu, xidtocom;

   WHILE cur_garanseg%FOUND LOOP
      xnasegur := NULL;
      xidtocom := 0 - NVL(xidtocom, 0);

      -- BUSCAMOS  EL Nº DE ASEGURADOS.
      BEGIN
         SELECT DECODE(nasegur, NULL, 1, nasegur)
           INTO xnasegur
           FROM solriesgos
          WHERE ssolicit = pssolicit
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
-- FASE 1: CÀLCUL DE LA PRIMA NETA (CCONCEP = 0) Y DE LA PRIMA DEVENGADA (FASE 2).
-- *******************************************************************************
    -- ********** PRIMA NETA ***********
      IF pmodo = 'PR' THEN   -- PRIMER RECIBO
         xiprianu2 := ROUND(xiprianu * facnet * xnasegur, decimals);
      ELSE   -- RECIBO ANUAL
         xiprianu2 := ROUND(xiprianu * xnasegur, decimals);
      END IF;

      IF NVL(xiprianu2, 0) <> 0 THEN
         error := f_insdetreccar(pnproces, pnrecibo, 0, xiprianu2, xploccoa, xcgarant,
                                 xnriesgo, xctipcoa);

         IF error = 0 THEN
            ha_grabat := TRUE;
         ELSE
            CLOSE cur_garanseg;

            RETURN error;
         END IF;
      END IF;

      --  ******* DESCUENTO COMERCIAL *******
      IF pmodo = 'PR' THEN   -- PRIMER RECIBO
         xidtocom2 := ROUND(xidtocom * facnet * xnasegur, decimals);
      ELSE   -- RECIBO ANUAL
         xidtocom2 := ROUND(xidtocom * xnasegur, decimals);
      END IF;

      IF xidtocom2 <> 0
         AND xidtocom2 IS NOT NULL THEN
         error := f_insdetreccar(pnproces, pnrecibo, 10, xidtocom2, xploccoa, xcgarant,
                                 xnriesgo, xctipcoa);

         IF error = 0 THEN
            ha_grabat := TRUE;
         ELSE
            CLOSE cur_garanseg;

            RETURN error;
         END IF;
      END IF;

      FETCH cur_garanseg
       INTO xcgarant, xnriesgo, xnorden, xctarifa, xicapital, xprecarg, xiprianu, xcformul,
            xiextrap, xctipfra, xifranqu, xidtocom;
   END LOOP;

   CLOSE cur_garanseg;

-- **********************************************************
-- ARA CRIDAREM A LA FUNCIÓ QUE CALCULA LES DADES DEL CONSORCI
-- **********************************************************
   IF pmodo = 'PR' THEN   -- PRIMER RECIBO
      facconsor := facdev;
   ELSE   -- RECIBO ANUAL
      facconsor := 1;   -- NO DEBE PRORRATEAR NUNCA
   END IF;

   error := f_solconsorci(pnproces, pssolicit, pnrecibo, pnriesgo, pfefecto, xffinrec, xcramo,
                          xcmodali, xcactivi, xccolect, xctipseg, xcduraci, xnduraci, pgrabar,
                          facconsor);

   IF error = 0 THEN
      IF pgrabar = 1 THEN
         ha_grabat := TRUE;
      END IF;
   ELSE
      RETURN error;
   END IF;

-- **********************************************************
-- FASE 3 : CÀLCUL DESCOMPTES, RECÀRRECS I IMPOSTOS
-- **********************************************************
   error := f_solimprecibos(pnproces, pnrecibo, pnriesgo, xcrecfra, xcforpag, xcramo, xcmodali,
                            xctipseg, xccolect, xcactivi, pssolicit);

   IF error <> 0 THEN
      RETURN error;
   END IF;

--
-- CALCULAMOS LOS TOTALES DEL RECIBO
--
   IF ha_grabat = TRUE THEN
      error := f_vdetrecibos('N', pnrecibo, pnproces);   -- FORZAMOS EL CÁLCULO CON VDETRECIBOSCAR
      RETURN error;
   ELSE   -- NO HA GRABAT RES A DETRECIBOS
      IF xinnomin = 4 THEN   -- SI ES INNOMINADO
         BEGIN
            SELECT NVL(COUNT(nriesgo), 0)
              INTO xcontriesg
              FROM solriesgos
             WHERE ssolicit = pssolicit
               AND((nriesgo = pnriesgo)
                   OR pnriesgo IS NULL)
               AND nasegur > 0;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
         END;

         IF xcontriesg = 0 THEN   -- ES INNOMINAT I TOTS ELS
                        -- RISCS TÉNEN NASEGUR = 0
            -- SI NASEGUR = 0, GRABAMOS EL CONCEPTO 99 EN DETRECIBOS,
            -- Y GENERAMOS VDETRECIBOS, Y HACEMOS EL RECIBO NO IMPRIMIBLE
            BEGIN
               SELECT MIN(cgarant), MIN(nriesgo)
                 INTO xcgarant, xnriesgo
                 FROM solgaranseg
                WHERE ssolicit = pssolicit;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 103500;   -- ERROR AL LLEGIR DE GARANSEG
            END;

            error := f_insdetreccar(pnproces, pnrecibo, 99, 0, xploccoa, xcgarant, xnriesgo,
                                    xctipcoa);

            IF error = 0 THEN
               error := f_vdetrecibos('N', pnrecibo, pnproces);
               RETURN error;
            ELSE
               RETURN error;
            END IF;
         ELSE
            RETURN 103108;   -- NO SE HA GRABADO NINGÚN REGISTRO EN EL CÁLCULO DE RECIBOS
         END IF;
      ELSE   -- NO ÉS INNOMINAT
         RETURN 103108;   -- NO S' HA GRABAT CAP REGISTRE EN EL CÀLCUL DE REBUTS
      END IF;
   END IF;
END;

/

  GRANT EXECUTE ON "AXIS"."F_SOLDETRECIBO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SOLDETRECIBO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SOLDETRECIBO" TO "PROGRAMADORESCSI";
