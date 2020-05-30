--------------------------------------------------------
--  DDL for Function F_CONSORCI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CONSORCI" (
   psproces IN NUMBER,
   psseguro IN NUMBER,
   pnrecibo IN NUMBER,
   pnriesgo IN NUMBER,
   pfefecto IN DATE,
   pfvencim IN DATE,
   pcmodo IN VARCHAR2,
   ptipomovimiento IN NUMBER,
   pcramo IN NUMBER,
   pcmodali IN NUMBER,
   pcactivi IN NUMBER,
   pccolect IN NUMBER,
   pctipseg IN NUMBER,
   pcduraci IN NUMBER,
   pnduraci IN NUMBER,
   pnmovimi IN NUMBER,
   pgrabar OUT NUMBER,
   pnmovimiant IN NUMBER,
   pfacconsor IN NUMBER,
   pfacconsorfra IN NUMBER,   --JAMF 11903 - Factor de prorrateo para el consorcio fraccionado
   paltarisc IN BOOLEAN,
   pcapieve IN NUMBER DEFAULT NULL,
   pttabla IN VARCHAR2 DEFAULT NULL,
   pfuncion IN VARCHAR2 DEFAULT 'CAR',
   pctipapo IN NUMBER DEFAULT NULL)
   RETURN NUMBER AUTHID CURRENT_USER IS
      -- ALLIBADM. AQUESTA FUNCIÓ ÉS CRIDADA PER LA FUNCIÓ F_DETRECIBO, I S' ENCARREGA NOMÉS D' OMPLIR LA TAULA
      -- DETRECIBOS AMB LES DADES DEL CONSORCI.
      -- NOMÉS S' HA CREAT PER PROBLEMES D' ESPAI DE LA FUNCIÓ ORIGINAL F_DETRECIBO EN LA BD.
      -- ALLIBADM. CANVIA COMPLETAMENT.
      -- DARRERA MODIFICACIÓ = DRA 19-05-1999.
   -- ALLIBADM. SE IMPLEMENTA EL COASEGURO
   -- SE IMPLEMENTA EL TRATAMIENTO DEL CAPITAL A PRIMER RIESGO.
   -- SI SE HA DEFINIDO EL VALOR DEL CONSORCIO EN LA TABLA CONSORSEGU COGEMOS ÉSTE.
   -- NOTA: ESTE VALOR ES EL IMPORTE DEL CONSORCIO QUE TENDRÁ LA GARANTÍA PARA ESE RIESGO.
   --       EN EL CASO DE QUE HAYA UN CAPITAL A PRIMER RIESGO, A LOS IMPORTES DEFINIDOS
   --       EN ESTA TABLA SE APLICARÁ POSTERIORMENTE LOS COEFICIENTES DE LA TABLA DE LÍMITES.
   -- SI LA GARANTÍA NO ES CONSORCIABLE NO SE CALCULA EL CONSORCIO PARA ESA
   -- GARANTÍA AUNQUE LA TUVIERA FIJA.
   -- PARA CONSORCIOS DE CAPITAL EVENTUAL SE CALCULA LOS DÍAS QUE HA DURADO ESE EXCESO.
   -- PARA DURACIONES SUPERIORES AL AÑO SE PRORRATEARÁ POR EL TIEMPO QUE CORRESPONDA
   -- Tratamiento especial para AUTOS. Acceso a PARGARANPRO para obtener un CCLARIE
   --                 alternativo o para decidir si se debe grabar una garantía o no dependiendo de otras.
   -- Modificación para consorciar diferentes consorcios xctipcla=1 o xctipcla=2
   --                          o xctipcla = 3. Si existe un extorno no debe devolver el consorcio.
   -- Se añade el tipomovimiento = 11 ==> Suplemento con Recibo por diferencia
      --              de prima basada en provisión matemática (prima única)
   -- Sólo se considera de temporada si cduraci = 3 y cforpag = 0 (única).
   /*
     {Se añaden los parametros funcion y tabla para el calculo del primer recibo al tarifar,
      el parametro tabla indica a que tablas tiene que ir a buscar importes ('EST','SOL',NULLL),
      el parametro función indica si estoy tarifando (TAR) o en la cartera o previo de cartera (CAR)
     }
   */
   -- Se añaden los campos CAGEVEN y NMOVIMA en los cursores para poder grabar correctamente
   -- en DETRECIBOS o DETRECIBOSCAR. Ahora siempre graba NULL.

   /******************************************************************************
      NOMBRE:      F_CONSORCI
      PROPÓSITO:   FUNCIÓ QUE S' ENCARREGA NOMÉS D' OMPLIR LA TAULA DETRECIBOS AMB LES DADES DEL CONSORCI.

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        28/04/2009    DCT            1. Modificación Selects pargaranpro.
                                                 Si para actividad en concreto no DATA_FOUND
                                                 buscar para actividad 0. Bug:0009783
      2.0        01/08/2009    NMM            2. 10864: CEM - Taxa aplicable Consorci.
      3.0        11/11/2009    JAMF           3. 11903: CEM - Consorcio fraccionable
      4.0        31/03/2010    FAL            4. 0012589: CEM - Recibos con copago y consorcio
      5.0        18/04/2011    JMF            5. 0018135 CCAT701 - Paquetes propios y Consorcio de CTV en iAXIS
      6.0        28/11/2011    JMP            6. 0018423: LCOL000 - Multimoneda
      7.0        06/05/2012    DRA            7. 0022279: MDP - TEC - Parametrización producto de Comercio - Nueva producción
      8.0        10/04/2015    FAL            8. 0035409: T - Producto Convenios
   ******************************************************************************/
   error          NUMBER := 0;
   xmeses         NUMBER;
   xresult        NUMBER;
   xcclarie       NUMBER;
   xsegtemporada  BOOLEAN;
   xsegtemp1      NUMBER;
   xctipcla       NUMBER;
   xivalnor       NUMBER;
   xvalorconsorcio NUMBER;
   xcapitaltrobat NUMBER;
   xcapitaltotal  NUMBER;
   xpercent       NUMBER;
   xtotcapital    NUMBER;
   xnvalor1       NUMBER;
   xnvalor2       NUMBER;
   iconcep0       NUMBER;
   xcgarant       NUMBER;
   xnriesgo       NUMBER;
   xcgarantant    NUMBER;
   xtotcapitalant NUMBER;
   xcapitaltotalant NUMBER;
   xnriesgoant    NUMBER;
   xcgarantseg    NUMBER;
   xnriesgoseg    NUMBER;
   xgrabar        NUMBER := 0;
   xnmovimiant    NUMBER;
   xnmovimiseg    NUMBER;
   xfefectoant    DATE;
   xfefectoseg    DATE;
   decimals       NUMBER := 0;
   existant       BOOLEAN := TRUE;
   xinnomin       BOOLEAN;
   xnasegur1      NUMBER;
   xnasegur2      NUMBER;
   xcobjase       NUMBER;
   xinsert        BOOLEAN;
   xnmovima       NUMBER;
   xicapital      NUMBER;
   xicapitalant   NUMBER;
   xicapitalseg   NUMBER;
   xctipcoa       NUMBER;   -- COASEGURO
   xncuacoa       NUMBER;
   xploccoa       NUMBER;
   xsumaneta      NUMBER;
   xiconsor       NUMBER;
   xcimpcon       NUMBER;
   xfiniefe       DATE;
   xfiniefeant    DATE;
   xffinefe       DATE;
   xdifdiaseve    NUMBER;
   xcforpag       NUMBER;
   xorden         NUMBER;
   vselect        VARCHAR2(2000);
   xcageven       NUMBER;
   xxnmovima      NUMBER;
   xcempres       NUMBER;
   xcons          NUMBER;
   vcfracci       NUMBER;
   vcbonifi       NUMBER;
   vcrecfra       NUMBER;
   --
   w_climit       NUMBER;
   v_cmonimp      imprec.cmoneda%TYPE;   -- BUG 18423 - LCOL000 - Multimoneda
   w_resultat     NUMBER;
   w_cduraci      NUMBER;
   w_nduraci      NUMBER;
   xctipreb       NUMBER;
   -- ini Bug 0018135 - JMF - 18/04/2011
   v_sproduc      seguros.sproduc%TYPE;
   v_conspup      parproductos.cvalpar%TYPE;
   v_origenpup    NUMBER;
   v_clavepup     garanformula.clave%TYPE;
   -- fin Bug 0018135 - JMF - 18/04/2011
   vcderreg       NUMBER;   -- Bug 0020314 - FAL - 29/11/2011
   vpasexec       NUMBER := 1;
   vparam         VARCHAR2(2000)
      := 'psproces=' || psproces || ', psseguro=' || psseguro || ', pnrecibo=' || pnrecibo
         || ', pnriesgo=' || pnriesgo || ', pfefecto=' || pfefecto || ', pcmodo=' || pcmodo
         || ', pfvencim=' || pfvencim || ', pcmodo=' || pcmodo || ', ptipomovimiento='
         || ptipomovimiento || ', pcramo=' || pcramo || ', pcmodali=' || pcmodali
         || ', pcactivi=' || pcactivi || ', pccolect=' || pccolect || ', pctipseg='
         || pctipseg || ', pcduraci=' || pcduraci || ', pnduraci=' || pnduraci
         || ', pnmovimi=' || pnmovimi || ', pgrabar=' || pgrabar || ', pnmovimiant='
         || pnmovimiant || ', pfacconsor=' || pfacconsor || ', pfacconsorfra='
         || pfacconsorfra || ', pcapieve=' || pcapieve || ', pttabla=' || pttabla
         || ', pfuncion=' || pfuncion || ', pctipapo=' || pctipapo;

   TYPE tcursor IS REF CURSOR;

   curgaran       tcursor;

   -- AUTOS. Para recoger el cod. retorno de F_ORDENCONSORCIO
   CURSOR cur_garansegxrisc IS
      SELECT nriesgo, cgarant, finiefe, ffinefe, cageven, nmovima, icapital
        FROM garanseg
       WHERE sseguro = psseguro
         AND nriesgo = NVL(pnriesgo, nriesgo)
         AND nmovimi = pnmovimi;

   CURSOR cur_garansegant IS
      SELECT cgarant, nriesgo, finiefe, ffinefe, cageven, nmovima, icapital
        FROM garanseg
       WHERE sseguro = psseguro
         AND nriesgo = NVL(pnriesgo, nriesgo)
         AND nmovimi = pnmovimiant;

   CURSOR cur_garancarxrisc IS
      SELECT nriesgo, cgarant, finiefe, ffinefe, cageven, nmovima, icapital
        FROM garancar
       WHERE sproces = psproces
         AND sseguro = psseguro
         AND nriesgo = NVL(pnriesgo, nriesgo);

   -- Bug 12589 - FAL - 31/03/2010 -- 0012589: CEM - Recibos con copago y consorcio
   CURSOR cur_aportaseg(psseguro NUMBER, pfefecto DATE, pnorden NUMBER) IS
      SELECT ctipimp, pimport, iimport
        FROM aportaseg
       WHERE sseguro = psseguro
         AND finiefe <= pfefecto
         AND(ffinefe IS NULL
             OR ffinefe > pfefecto)
         AND(norden = pnorden
             OR pnorden IS NULL);

   FUNCTION f_esconsorciable(
      pfcgarant IN NUMBER,
      pfcramo IN NUMBER,
      pfcmodali IN NUMBER,
      pfccolect IN NUMBER,
      pfctipseg IN NUMBER,
      pfcactivi IN NUMBER,
      pfnerror OUT NUMBER)
      RETURN NUMBER IS
      --
      -- COMPROBACIÓN DE SI UNA GARANTÍA ES CONSORCIABLE
      --
      xfcimpcon      NUMBER;
   BEGIN
      BEGIN
         SELECT cimpcon
           INTO xfcimpcon
           FROM garanpro
          WHERE cramo = pfcramo
            AND cmodali = pfcmodali
            AND ccolect = pfccolect
            AND ctipseg = pfctipseg
            AND cgarant = pfcgarant
            AND cactivi = NVL(pfcactivi, 0);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT NVL(cimpcon, 0)
                 INTO xfcimpcon
                 FROM garanpro
                WHERE cramo = pfcramo
                  AND cmodali = pfcmodali
                  AND ccolect = pfccolect
                  AND ctipseg = pfctipseg
                  AND cgarant = pfcgarant
                  AND cactivi = 0;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  pfnerror := 104110;   -- PRODUCTE NO TROBAT A GARANPRO
                  RETURN 0;
               WHEN OTHERS THEN
                  pfnerror := 103503;   -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                  RETURN 0;
            END;
         WHEN OTHERS THEN
            pfnerror := 103503;   -- ERROR AL LLEGIR DE LA TAULA GARANPRO
            RETURN 0;
      END;

      pfnerror := 0;
      RETURN xfcimpcon;
   END f_esconsorciable;

   FUNCTION f_ordenconsorcio(
      pftablas IN NUMBER,
      pfcgarant IN NUMBER,
      pfcramo IN NUMBER,
      pfcmodali IN NUMBER,
      pfccolect IN NUMBER,
      pfctipseg IN NUMBER,
      pfcactivi IN NUMBER,
      pfsseguro IN NUMBER,
      pfnriesgo IN NUMBER,
      pfnmovimi IN NUMBER,
      pfnerror OUT NUMBER)
      RETURN NUMBER IS
      xorden         NUMBER;
      retorno        NUMBER;
   -- Varias garantias de la misma actividad son alternativas: solo se calcula el consorcio
   -- para una de ellas, segun la prioridad en PARGARANPRO.
   -- Si se ha contratado otra garantia con prioridad superior devolveremos '1' (para no grabar)
   -- Si no hay que hacer nada devolveremos 0.
   BEGIN
      --  Primero obtenemos el orden/prioridad de la garantia que estamos 'consorciando'
      BEGIN
         SELECT cvalpar
           INTO xorden
           FROM pargaranpro
          WHERE cpargar = 'ORDEN_CONSORCIO'
            AND cramo = pfcramo
            AND cmodali = pfcmodali
            AND ctipseg = pfctipseg
            AND ccolect = pfccolect
            AND cgarant = pfcgarant
            AND cactivi = pcactivi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            --BUG 9783 - 29/04/2009 - DCT - Añadir select por cactivi = 0
            BEGIN
               SELECT cvalpar
                 INTO xorden
                 FROM pargaranpro
                WHERE cpargar = 'ORDEN_CONSORCIO'
                  AND cramo = pfcramo
                  AND cmodali = pfcmodali
                  AND ctipseg = pfctipseg
                  AND ccolect = pfccolect
                  AND cgarant = pfcgarant
                  AND cactivi = 0;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  pfnerror := SQLCODE;
                  RETURN 1;
            END;
         --FI BUG 9783 - 29/04/2009 - DCT - Añadir select por cactivi = 0
         WHEN OTHERS THEN
            pfnerror := SQLCODE;
            RETURN 1;
      END;

      retorno := 0;

      -- Ahora miramos si hay otra con prioridad superior (orden:1-max, orden:9-min)
      IF xorden IS NOT NULL THEN
         IF pftablas = 1 THEN
            BEGIN
               SELECT '1'
                 INTO retorno
                 FROM pargaranpro
                WHERE cpargar = 'ORDEN_CONSORCIO'
                  AND cramo = pfcramo
                  AND cmodali = pfcmodali
                  AND ctipseg = pfctipseg
                  AND ccolect = pfccolect
                  AND cactivi = pfcactivi
                  AND cvalpar < xorden
                  AND cgarant IN(SELECT cgarant
                                   FROM garanseg
                                  WHERE sseguro = pfsseguro
                                    AND nriesgo = NVL(pfnriesgo, nriesgo)
                                    AND nmovimi = pfnmovimi);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT '1'
                       INTO retorno
                       FROM pargaranpro
                      WHERE cpargar = 'ORDEN_CONSORCIO'
                        AND cramo = pfcramo
                        AND cmodali = pfcmodali
                        AND ctipseg = pfctipseg
                        AND ccolect = pfccolect
                        AND cactivi = 0
                        AND cvalpar < xorden
                        AND cgarant IN(SELECT cgarant
                                         FROM garanseg
                                        WHERE sseguro = pfsseguro
                                          AND nriesgo = NVL(pfnriesgo, nriesgo)
                                          AND nmovimi = pfnmovimi);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        NULL;
                     WHEN TOO_MANY_ROWS THEN
                        retorno := 1;
                     WHEN OTHERS THEN
                        pfnerror := SQLCODE;
                        RETURN 1;
                  END;
               WHEN TOO_MANY_ROWS THEN
                  retorno := 1;
               WHEN OTHERS THEN
                  pfnerror := SQLCODE;
                  RETURN 1;
            END;
         ELSE   -- CARTERA
            BEGIN
               SELECT '1'
                 INTO retorno
                 FROM pargaranpro
                WHERE cpargar = 'ORDEN_CONSORCIO'
                  AND cramo = pfcramo
                  AND cmodali = pfcmodali
                  AND ctipseg = pfctipseg
                  AND ccolect = pfccolect
                  AND cactivi = pfcactivi
                  AND cvalpar < xorden
                  AND cgarant IN(SELECT cgarant
                                   FROM garancar
                                  WHERE sseguro = pfsseguro
                                    AND nriesgo = NVL(pfnriesgo, nriesgo));
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT '1'
                       INTO retorno
                       FROM pargaranpro
                      WHERE cpargar = 'ORDEN_CONSORCIO'
                        AND cramo = pfcramo
                        AND cmodali = pfcmodali
                        AND ctipseg = pfctipseg
                        AND ccolect = pfccolect
                        AND cactivi = 0
                        AND cvalpar < xorden
                        AND cgarant IN(SELECT cgarant
                                         FROM garancar
                                        WHERE sseguro = pfsseguro
                                          AND nriesgo = NVL(pfnriesgo, nriesgo));
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        NULL;
                     WHEN TOO_MANY_ROWS THEN
                        retorno := 1;
                     WHEN OTHERS THEN
                        pfnerror := SQLCODE;
                        RETURN 1;
                  END;
               WHEN TOO_MANY_ROWS THEN
                  retorno := 1;
               WHEN OTHERS THEN
                  pfnerror := SQLCODE;
                  RETURN 1;
            END;
         END IF;
      END IF;

      RETURN retorno;
   END f_ordenconsorcio;

-----------------------------------------------------------------------------
   PROCEDURE p_tracta_limit(
      p_climit IN NUMBER,
      p_cduraci IN seguros.cduraci%TYPE,
      p_nduraci IN seguros.nduraci%TYPE,
      p_cforpag IN NUMBER,
      p_fvencim IN DATE,
      p_fefecto IN DATE,
      p_segtemporada OUT BOOLEAN,
      p_mesos OUT NUMBER,
      p_nvalor1 OUT NUMBER,
      p_resultat OUT NUMBER) IS
   --
-----------------------------------------------------------------------------
   BEGIN
      IF p_climit IS NOT NULL THEN
         p_segtemporada := TRUE;

         IF p_cduraci = 1 THEN
            p_mesos := p_nduraci * 12;
         ELSIF p_cduraci = 2 THEN
            p_mesos := p_nduraci;
         ELSIF p_cduraci = 3
               AND p_cforpag = 0 THEN
            p_mesos := CEIL(MONTHS_BETWEEN(p_fvencim, p_fefecto));
         END IF;

         BEGIN
            SELECT MIN(nvalor1)
              INTO p_nvalor1
              FROM limites
             WHERE climite = p_climit
               AND p_mesos >= nminimo
               AND(p_mesos <= nmaximo
                   OR nmaximo IS NULL);

            p_resultat := 0;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- LÍMIT NO TROBAT A LA TAULA LIMITES
               p_resultat := 103834;
            WHEN OTHERS THEN
               -- ERROR AL LLEGIR DE LA TAULA LIMITES
               p_resultat := 103514;
         END;
      END IF;
-----------------------------------------------------------------------------
   END p_tracta_limit;
-----------------------------------------------------------------------------

--------------------------------------------------------------------------------
--                    F_CONSORCI
--------------------------------------------------------------------------------
BEGIN
-- ********************************************************************
-- *************  FASE 3  DE F_DETRECIBO ******************************
-- ********************************************************************
-- CÀLCUL DEL CONSORCI (CCONCEP 2) (TAULA GARANSEG)
   pgrabar := 0;   -- EN UN PRINCIPI, NO HEM GRABAT RES
   vpasexec := 1;

   BEGIN
      SELECT cobjase,   -- JLB - I - BUG 18423 COjo la moneda del producto --  DECODE(cdivisa, 2, 2, 3, 1)
                     pac_monedas.f_moneda_producto(sproduc)
        -- JLB - f - BUG 18423 COjo la moneda del producto
      INTO   xcobjase, decimals
        FROM productos
       WHERE cramo = pcramo
         AND cmodali = pcmodali
         AND ctipseg = pctipseg
         AND ccolect = pccolect;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 104347;   -- PRODUCTE NO TROBAT A PRODUCTOS
      WHEN OTHERS THEN
         RETURN 102705;   -- ERROR AL LLEGIR DE PRODUCTOS
   END;

   vpasexec := 2;

   IF xcobjase = 4 THEN   -- PRODUCTE INNOMINAT
      xinnomin := TRUE;
   ELSE
      xinnomin := FALSE;
   END IF;

   vpasexec := 3;

   -- BUSCAMOS EL PORCENTAJE LOCAL SI ES UN COASEGURO.
   -- Añadimos la empresa, para los cálculos del concepto (para f_concepto)
   IF pttabla = 'EST' THEN
      SELECT cempres, ctipcoa, ncuacoa, cforpag, cduraci, nduraci, ctipreb, sproduc
        INTO xcempres, xctipcoa, xncuacoa, xcforpag, w_cduraci, w_nduraci, xctipreb, v_sproduc
        FROM estseguros
       WHERE sseguro = psseguro;
   ELSIF pttabla = 'SOL' THEN
      SELECT cr.cempres, s.cforpag, cduraci, nduraci, sproduc
        INTO xcempres, xcforpag, w_cduraci, w_nduraci, v_sproduc
        FROM solseguros s, codiram cr
       WHERE s.cramo = cr.cramo
         AND ssolicit = psseguro;
   ELSE
      SELECT cempres, ctipcoa, ncuacoa, cforpag, cduraci, nduraci, ctipreb, sproduc
        INTO xcempres, xctipcoa, xncuacoa, xcforpag, w_cduraci, w_nduraci, xctipreb, v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;
   END IF;

   vpasexec := 4;

   -- Cerquem el percentatge local si és coassegurança.
   IF xctipcoa != 0 THEN
      SELECT ploccoa
        INTO xploccoa
        FROM coacuadro
       WHERE ncuacoa = xncuacoa
         AND sseguro = psseguro;
   END IF;

   -- bug 10864.NMM.01/08/2009. S'elimina un troç de codi.
   vpasexec := 5;
   -- Bug 0018135 - JMF - 18/04/2011
   v_conspup := NVL(pac_parametros.f_parproducto_n(v_sproduc, 'CONSORCI_PUP'), 0);
   vpasexec := 6;

   -- *********** ACTUEM DEPENENT DEL PCMODO (REAL O PROVES) *******************
   -- Bug 19096 - RSC - 03/08/2011 - LCOL - Parametrización básica producto Vida Individual Pagos Permanentes (Afegim 'RRIE')
   IF pcmodo IN('R', 'RRIE') THEN
      IF ptipomovimiento = 0
         OR ptipomovimiento = 6
         OR ptipomovimiento = 21
         OR ptipomovimiento = 22   --JAMF 11903 - Añadimos el cálculo para carteras no anuales
                                THEN
         vpasexec := 7;

         OPEN cur_garansegxrisc;

         FETCH cur_garansegxrisc
          INTO xnriesgo, xcgarant, xfiniefe, xffinefe, xcageven, xxnmovima, xicapital;

         vpasexec := 8;

         WHILE cur_garansegxrisc%FOUND LOOP
            xnasegur1 := 0;
            xnasegur2 := 0;
            xcclarie := NULL;
            vpasexec := 9;
            xcimpcon := f_esconsorciable(xcgarant, pcramo, pcmodali, pccolect, pctipseg,
                                         pcactivi, error);

            IF error <> 0 THEN
               CLOSE cur_garansegxrisc;

               RETURN error;
            END IF;

            vpasexec := 10;

            IF xcimpcon = 1 THEN   -- SI LA GARANTÍA ES CONSORCIABLE
               -- bug 10864.NMM.01/08/2009. S'afegeix una variable.
               vpasexec := 11;
               error := f_concepto(2, xcempres, pfefecto,
                                   --NULL,
                                   xcforpag,   --JAMF 11903 - Puede depender de la forma de pago
                                   pcramo, pcmodali, pctipseg, pccolect, pcactivi, xcgarant,
                                   xctipcla, xivalnor, vcfracci, vcbonifi, vcrecfra, w_climit,
                                   v_cmonimp,   -- BUG 18423 - LCOL000 - Multimoneda
                                   vcderreg);   -- Bug 0020314 - FAL - 29/11/2011
               --
               vpasexec := 12;
               p_tracta_limit(w_climit, w_cduraci, w_nduraci, xcforpag, pfvencim, pfefecto,
                              xsegtemporada, xmeses, xsegtemp1, w_resultat);

               IF w_resultat = 103834 THEN
                  -- LÍMIT NO TROBAT A LA TAULA LIMITES
                  RETURN(103834);
               ELSIF w_resultat = 103514 THEN
                  -- ERROR AL LLEGIR DE LA TAULA LIMITES
                  RETURN(103514);
               END IF;

               vpasexec := 13;

               -- bug 10864.f.
               IF error <> 0 THEN   -- Si da error la función.
                  CLOSE cur_garansegxrisc;

                  RETURN error;
               ELSE
                  vpasexec := 14;

                  BEGIN
                     SELECT DECODE(nasegur, NULL, 1, nasegur)
                       INTO xnasegur1
                       FROM riesgos
                      WHERE sseguro = psseguro
                        AND nriesgo = NVL(xnriesgo, 1);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE cur_garansegxrisc;

                        RETURN 103836;   -- RISC NO TROBAT A RIESGOS
                     WHEN OTHERS THEN
                        CLOSE cur_garansegxrisc;

                        RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                  END;

                  -- ini Bug 0018135 - JMF - 18/04/2011
                  vpasexec := 15;

                  IF v_conspup = 1
                     AND xctipcla = 1 THEN
                     -- CONSORCI SOBRE EL CAPITAL
                     -- AVT 26-03-2007 El càlcul del consorci del producte: Prima Única Protecció és formulat
                     IF pttabla IS NULL THEN
                        v_origenpup := 2;
                     ELSIF pttabla = 'SOL' THEN
                        v_origenpup := 1;
                     ELSIF pttabla = 'EST' THEN
                        v_origenpup := 0;
                     END IF;

                     vpasexec := 16;

                     BEGIN
                        SELECT clave
                          INTO v_clavepup
                          FROM garanformula
                         WHERE cramo = pcramo
                           AND cmodali = pcmodali
                           AND ctipseg = pctipseg
                           AND ccolect = pccolect
                           AND cactivi = pcactivi
                           AND cgarant = xcgarant
                           AND ccampo = 'ICONPUP';
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user, 'f_consorci', 1,
                                       'Error al llegir de GARANFORMULA', SQLERRM);
                           error := 110087;
                           -- Error al insertar en GARANFORMULA
                           RETURN(error);
                     END;

                     vpasexec := 17;
                     --(JAS)05.06.07 - Modifico la fòrmula del càlcul del consorci, perquè ens retorni el capital consorciable.
                     --Anteriorment retornava l'import final del consorci directement, de manera que ara caldrà aplicar la taxa
                     --de consorci corresponent sobre el capital consorciable calculat, per obtenir l'import final del consorci
                     --(com ja es feia amb els altres productes). Es realitza aquest canvi perquè la formulació aplicava la taxa
                     --de consorci a partir de la classe de risc (CODICLARIE), quan en realitat s'ha d'aplicar la taxa d'impost
                     --definit en la taula d'impostos (IMPREC) que ja tenim calculat a "xivalnor".
                     --BUG 24656-XVM-16/11/2012.Añadir paccion
                     error := pac_calculo_formulas.calc_formul(pfefecto, v_sproduc, pcactivi,
                                                               xcgarant, xnriesgo, psseguro,
                                                               v_clavepup, xcons, NULL, NULL,
                                                               v_origenpup, xfiniefe, NULL,
                                                               NULL, 0);

                     IF NVL(error, -1) <> 0 THEN
                        CLOSE cur_garansegxrisc;

                        RETURN error;
                     END IF;
                   -- AVT 26-03-2007 El càlcul del consorci del producte: Prima Única Protecció és formulat
                  -- fin Bug 0018135 - JMF - 18/04/2011
                  ELSIF ptipomovimiento = 6 THEN   --JRH El consorcio en regularización tendrá un nuevo campo como la prima y no aplica entonces ICONSUP
                     IF pttabla IS NULL THEN
                        v_origenpup := 2;
                     ELSIF pttabla = 'SOL' THEN
                        v_origenpup := 1;
                     ELSIF pttabla = 'EST' THEN
                        v_origenpup := 0;
                     END IF;

                     vpasexec := 16;

                     BEGIN
                        SELECT clave
                          INTO v_clavepup
                          FROM garanformula
                         WHERE cramo = pcramo
                           AND cmodali = pcmodali
                           AND ctipseg = pctipseg
                           AND ccolect = pccolect
                           AND cactivi = pcactivi
                           AND cgarant = xcgarant
                           AND ccampo = 'CONREGUL';
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           BEGIN
                              SELECT clave
                                INTO v_clavepup
                                FROM garanformula
                               WHERE cramo = pcramo
                                 AND cmodali = pcmodali
                                 AND ctipseg = pctipseg
                                 AND ccolect = pccolect
                                 AND cactivi = 0
                                 AND cgarant = xcgarant
                                 AND ccampo = 'CONREGUL';
                           EXCEPTION
                              WHEN OTHERS THEN
                                 p_tab_error(f_sysdate, f_user, 'f_consorci', 1,
                                             'Error al llegir de GARANFORMULA1', SQLERRM);
                                 error := 110087;
                                 -- Error al insertar en GARANFORMULA
                                 RETURN(error);
                           END;
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user, 'f_consorci', 1,
                                       'Error al llegir de GARANFORMULA1', SQLERRM);
                           error := 110087;
                           -- Error al insertar en GARANFORMULA
                           RETURN(error);
                     END;

                     vpasexec := 17;
                     --(JAS)05.06.07 - Modifico la fòrmula del càlcul del consorci, perquè ens retorni el capital consorciable.
                     --Anteriorment retornava l'import final del consorci directement, de manera que ara caldrà aplicar la taxa
                     --de consorci corresponent sobre el capital consorciable calculat, per obtenir l'import final del consorci
                     --(com ja es feia amb els altres productes). Es realitza aquest canvi perquè la formulació aplicava la taxa
                     --de consorci a partir de la classe de risc (CODICLARIE), quan en realitat s'ha d'aplicar la taxa d'impost
                     --definit en la taula d'impostos (IMPREC) que ja tenim calculat a "xivalnor".
                     --BUG 24656-XVM-16/11/2012.Añadir paccion
                     error :=
                        pac_calculo_formulas.calc_formul
                                       (pfefecto, v_sproduc, pcactivi, xcgarant, xnriesgo,
                                        psseguro, v_clavepup, xcons, pnmovimi, NULL,   -- BUG 34505 - FAL - 20/03/2015 - informar nmovimi
                                        v_origenpup, xfiniefe, NULL, NULL, 0);

                     IF NVL(error, -1) <> 0 THEN
                        CLOSE cur_garansegxrisc;

                        RETURN error;
                     END IF;
                  ELSE
                     vpasexec := 18;

                     -- Obtenemos la prima, para consorcio sobre prima
                     BEGIN
                        SELECT   SUM(iconcep)
                            INTO iconcep0
                            FROM detrecibos
                           WHERE nrecibo = pnrecibo
                             AND nriesgo = xnriesgo
                             AND cgarant = xcgarant
                             AND(cconcep = 0
                                 OR cconcep = 50)   -- LOCAL +  CEDIDA
                        GROUP BY nriesgo, cgarant;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           NULL;
                        WHEN OTHERS THEN
                           CLOSE cur_garansegxrisc;

                           error := 103512;
                           -- ERROR AL LLEGIR DE DETRECIBOS
                           RETURN error;
                     END;

                     vpasexec := 19;
                     --BUG 24656-XVM-16/11/2012.Añadir paccion. 0-N.P.
                     error := pac_impuestos.f_calcula_impconcepto(xivalnor, iconcep0, iconcep0,
                                                                  NULL, NULL, NULL, xicapital,
                                                                  NULL, NULL, xctipcla,
                                                                  xcforpag, vcfracci, vcbonifi,
                                                                  vcrecfra, xcons,
                                                                  -- JLB - I - BUG 18423 COjo la moneda del producto
                                                                  NULL, NULL, NULL, pfefecto,
                                                                  psseguro, xnriesgo, xcgarant,

                                                                  -- decimals, NULL, 0);   -- JLB - F - BUG 18423 COjo la moneda del producto
                                                                  decimals, NULL, 0, NULL,
                                                                  pnmovimi);   -- BUG 34505 - FAL - 17/03/2015

                     IF error <> 0 THEN   -- Si da error la función.
                        CLOSE cur_garansegxrisc;

                        RETURN error;
                     END IF;
                  END IF;

                  vpasexec := 20;

                  -- bug 10864.NMM.01/08/2009. S'elimina un troç de codi.
                  IF xinnomin
                     AND xctipcla = 4 THEN
                     xvalorconsorcio := NVL(xcons, 0) * xnasegur1;
                  ELSE
                     xvalorconsorcio := NVL(xcons, 0);
                  END IF;

                  vpasexec := 21;

                  IF xvalorconsorcio IS NOT NULL
                     AND xvalorconsorcio <> 0 THEN
                     IF xsegtemporada THEN
                        xvalorconsorcio := xvalorconsorcio * xsegtemp1;
                     -- bug 10864.NMM.01/08/2009. S'elimina un troç de codi.
                     ELSE
                        --JAMF 11903 - Se aplica el fraccionamiento si no es una regularización (6)
                        IF vcfracci = 1
                           AND ptipomovimiento NOT IN(6) THEN
                           xvalorconsorcio := xvalorconsorcio * pfacconsorfra;
                        ELSIF vcfracci = 0
                              AND ptipomovimiento = 22 THEN
                           xvalorconsorcio := 0;
                        ELSE
                           xvalorconsorcio := xvalorconsorcio * pfacconsor;
                        END IF;
                     END IF;

                     vpasexec := 22;

                     IF pcapieve = 1 THEN
                        -- APLIQUEM EL TEMPS EN CAPITAL EVENTUAL
                        error := f_difdata(xfiniefe, xffinefe, 3, 3, xdifdiaseve);

                        IF error = 0 THEN
                           xvalorconsorcio := xvalorconsorcio * xdifdiaseve / 360;
                        ELSE
                           RETURN(error);
                        END IF;
                     END IF;

                     vpasexec := 23;
                     xorden := f_ordenconsorcio(1, xcgarant, pcramo, pcmodali, pccolect,
                                                pctipseg, pcactivi, psseguro, xnriesgo,
                                                pnmovimi, error);

                     IF xorden <> 0 THEN
                        xvalorconsorcio := 0;
                     END IF;

                     vpasexec := 24;

                     IF NVL(xvalorconsorcio, 0) <> 0 THEN
                        -- Bug 12589 - FAL - 31/03/2010 -- 0012589: CEM - Recibos con copago y consorcio
                        IF xctipreb = 4 THEN
                           IF pctipapo = 1 THEN
                              FOR vapor IN cur_aportaseg(psseguro, pfefecto, xnriesgo) LOOP
                                 IF vapor.ctipimp = 1 THEN
                                    xvalorconsorcio :=
                                       f_round(xvalorconsorcio * vapor.pimport / 100,
                                               decimals);
                                 ELSIF vapor.ctipimp = 2 THEN
                                    xvalorconsorcio := LEAST(xvalorconsorcio, vapor.iimport);
                                 END IF;
                              END LOOP;
                           ELSIF pctipapo = 2 THEN
                              FOR vapor IN cur_aportaseg(psseguro, pfefecto, xnriesgo) LOOP
                                 IF vapor.ctipimp = 1 THEN
                                    xvalorconsorcio :=
                                       f_round(xvalorconsorcio *(1 -(vapor.pimport / 100)),
                                               decimals);
                                 ELSIF vapor.ctipimp = 2 THEN
                                    xvalorconsorcio :=
                                                  GREATEST(0, xvalorconsorcio - vapor.iimport);
                                 END IF;
                              END LOOP;
                           END IF;
                        END IF;

                        vpasexec := 25;
                        -- Fi Bug 12589
                        xvalorconsorcio := f_round(xvalorconsorcio, decimals);   -- JLB - I - BUG 18423 COjo la moneda del producto
                        vpasexec := 26;

                        IF NVL(xvalorconsorcio, 0) <> 0 THEN   -- Bug 12589 - FAL - 31/03/2010 -- 0012589: CEM - Recibos con copago y consorcio
                           error := f_insdetrec(pnrecibo, 2, xvalorconsorcio, xploccoa,
                                                xcgarant, xnriesgo, xctipcoa, xcageven,
                                                xxnmovima, 0, 0, 1, NULL, NULL, NULL,
                                                decimals);   -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda

                           IF error = 0 THEN
                              pgrabar := 1;
                           ELSE
                              CLOSE cur_garansegxrisc;

                              RETURN error;
                           END IF;
                        END IF;   -- Fi Bug 12589
                     END IF;
                  END IF;
               END IF;
            END IF;

            vpasexec := 27;

            FETCH cur_garansegxrisc
             INTO xnriesgo, xcgarant, xfiniefe, xffinefe, xcageven, xxnmovima, xicapital;
         END LOOP;

         CLOSE cur_garansegxrisc;

         -- bug 10864.NMM.01/08/2009. S'elimina un troç de codi.
         RETURN(0);
-- ********************************************************************************************
      ELSIF ptipomovimiento IN(1, 11) THEN   -- SUPLEMENTS MODUS 'R'
-- ********************************************************************************************
         vpasexec := 28;

         OPEN cur_garansegxrisc;

         FETCH cur_garansegxrisc
          INTO xnriesgo, xcgarant, xfiniefe, xffinefe, xcageven, xxnmovima, xicapital;

         vpasexec := 29;

         WHILE cur_garansegxrisc%FOUND LOOP
            xnasegur1 := 0;
            xnasegur2 := 0;
            xtotcapital := 0;
            xtotcapitalant := 0;
            xcclarie := NULL;
            vpasexec := 30;
            xcimpcon := f_esconsorciable(xcgarant, pcramo, pcmodali, pccolect, pctipseg,
                                         pcactivi, error);

            IF error <> 0 THEN
               CLOSE cur_garansegxrisc;

               RETURN error;
            END IF;

            vpasexec := 31;

            IF xcimpcon = 1 THEN   -- LA GARANTÍA ES CONSORCIABLE
               --   message('la garantia si tiene consorcio: estamos en suplements');pause;
               vpasexec := 32;

               BEGIN
                  SELECT DECODE(nasegur, NULL, 1, nasegur)
                    INTO xnasegur1
                    FROM riesgos
                   WHERE sseguro = psseguro
                     AND nriesgo = NVL(xnriesgo, 1);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     CLOSE cur_garansegxrisc;

                     RETURN 103836;   -- RISC NO TROBAT A RIESGOS
                  WHEN OTHERS THEN
                     CLOSE cur_garansegxrisc;

                     RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
               END;

               existant := TRUE;
               vpasexec := 33;
               -- bug 10864.NMM.01/08/2009. S'afegeix una variable.
               error := f_concepto(2, xcempres, pfefecto,
                                   --NULL,
                                   xcforpag,   --JAMF 11903 - Puede depender de la forma de pago
                                   pcramo, pcmodali, pctipseg, pccolect, pcactivi, xcgarant,
                                   xctipcla, xivalnor, vcfracci, vcbonifi, vcrecfra, w_climit,
                                   v_cmonimp,   -- BUG 18423 - LCOL000 - Multimoneda
                                   vcderreg);   -- Bug 0020314 - FAL - 29/11/2011
               --
               vpasexec := 34;
               p_tracta_limit(w_climit, w_cduraci, w_nduraci, xcforpag, pfvencim, pfefecto,
                              xsegtemporada, xmeses, xsegtemp1, w_resultat);

               IF w_resultat = 103834 THEN
                  -- LÍMIT NO TROBAT A LA TAULA LIMITES
                  RETURN(103834);
               ELSIF w_resultat = 103514 THEN
                  -- ERROR AL LLEGIR DE LA TAULA LIMITES
                  RETURN(103514);
               END IF;

               vpasexec := 35;

               -- bug 10864.f.
               IF error <> 0 THEN   -- Si da error la función.
                  CLOSE cur_garansegxrisc;

                  RETURN error;
               ELSE
                  vpasexec := 36;

                  -- Obtenemos la prima, para cuando consorcio sobre prima
                  BEGIN
                     SELECT   SUM(iconcep)
                         INTO iconcep0
                         FROM detrecibos
                        WHERE nrecibo = pnrecibo
                          AND nriesgo = xnriesgo
                          AND cgarant = xcgarant
                          AND(cconcep = 0
                              OR cconcep = 50)   -- LOCAL +  CEDIDA
                     GROUP BY nriesgo, cgarant;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        NULL;
                     WHEN OTHERS THEN
                        CLOSE cur_garansegxrisc;

                        error := 103512;
                        -- ERROR AL LLEGIR DE DETRECIBOS
                        RETURN error;
                  END;

                  -- OBTENIM LA GARANTIA ANTERIOR
                  xcgarantant := NULL;
                  xnriesgoant := NULL;
                  xnmovimiant := NULL;
                  vpasexec := 37;

                  BEGIN
                     SELECT cgarant, nriesgo, nmovimi, finiefe, icapital
                       INTO xcgarantant, xnriesgoant, xnmovimiant, xfiniefeant, xicapitalant
                       FROM garanseg
                      WHERE sseguro = psseguro
                        AND nriesgo = NVL(xnriesgo, nriesgo)
                        AND cgarant = NVL(xcgarant, cgarant)
                        AND nmovimi = pnmovimiant;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        existant := FALSE;   -- NO TENIM GARANTIA ANTERIOR
                     WHEN OTHERS THEN
                        CLOSE cur_garansegxrisc;

                        RETURN 103500;   -- ERROR AL LLEGIR DE GARANSEG
                  END;

                  vpasexec := 38;

                  IF xctipcla IN
                        (4, 6)   -- BUG 0035409 - FAL - 10/04/2015 - Añadir tipo concepto 6 (Fórmula que devuelve un % a aplicar al capital)
                     AND existant THEN
                     --xicapital := xicapitalant;
                     xicapital := xicapital - xicapitalant;
                  END IF;

                  vpasexec := 39;
                  --BUG 24656-XVM-16/11/2012.Añadir paccion. 2 Suple.
                  error := pac_impuestos.f_calcula_impconcepto(xivalnor, iconcep0, iconcep0,
                                                               NULL, NULL, NULL, xicapital,
                                                               NULL, NULL, xctipcla, xcforpag,
                                                               vcfracci, vcbonifi, vcrecfra,
                                                               xcons,
                                                               -- JLB - I - BUG 18423 COjo la moneda del producto
                                                               NULL, NULL, NULL, pfefecto,
                                                               psseguro, xnriesgo, xcgarant,

                                                               -- decimals, NULL, 2);   -- JLB - F - BUG 18423 COjo la moneda del producto
                                                               decimals, NULL, 2, NULL,
                                                               pnmovimi);   -- BUG 34505 - FAL - 17/03/2015

                  IF error <> 0 THEN   -- Si da error la función.
                     CLOSE cur_garansegxrisc;

                     RETURN error;
                  END IF;

                  vpasexec := 40;

                  IF xctipcla = 2
                     AND existant THEN
                     xcons := 0;
                  END IF;

                  -- bug 10864.NMM.01/08/2009. S'elimina un troç de codi.
                  IF xinnomin THEN
                     xvalorconsorcio := NVL(xcons, 0) * xnasegur1;
                  ELSE
                     xvalorconsorcio := NVL(xcons, 0);
                  END IF;

                  vpasexec := 41;

                  IF xvalorconsorcio IS NOT NULL
                     AND xvalorconsorcio <> 0 THEN
                     --  MESSAGE('ENTREM AL PRORRATEO DEL CONSORCI. VALOR CONSORCI: '||XVALORCONSORCIO);PAUSE;
                     IF xsegtemporada THEN
                        xvalorconsorcio := xvalorconsorcio * xsegtemp1;

                        IF xmeses > 12 THEN
                           -- ES HASTA EL VENCIMIENTO Y SUPERIOR AL AÑO
                           error := f_difdata(pfefecto, pfvencim, 3, 3, xresult);

                           IF error = 0 THEN
                              IF xctipcla = 2 THEN   -- ES IMPORTE FIJO
                                 xvalorconsorcio := xvalorconsorcio * CEIL(xresult / 360);
                              ELSIF xctipcla = 4 THEN
                                 -- ES SOBRE EL CAPITAL
                                 xvalorconsorcio := xvalorconsorcio * xresult / 360;
                              ELSE
                                 NULL;
                              END IF;
                           ELSE
                              RETURN error;
                           END IF;
                        END IF;
                     ELSE
                        --JAMF 11903 - Dejamos las diferencias de provisión como estaban
                        IF vcfracci = 1
                           AND ptipomovimiento NOT IN(11) THEN
                           xvalorconsorcio := NVL(xvalorconsorcio, 0) * pfacconsorfra;
                        ELSE
                           xvalorconsorcio := NVL(xvalorconsorcio, 0) * pfacconsor;
                        END IF;
                     END IF;

                     vpasexec := 42;

                     IF NVL(xvalorconsorcio, 0) <> 0 THEN
                        xinsert := TRUE;

                        IF paltarisc THEN   -- ES UN SUPLEMENT DE ALTA
                           BEGIN
                              SELECT nmovima
                                INTO xnmovima
                                FROM riesgos
                               WHERE sseguro = psseguro
                                 AND nriesgo = xnriesgo
                                 AND nmovima = pnmovimi;

                              xinsert := TRUE;
                           EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                 xinsert := FALSE;
                              WHEN OTHERS THEN
                                 CLOSE cur_garansegxrisc;

                                 RETURN 103509;
                           -- ERROR AL LLEGIR DE RIESGOS
                           END;
                        END IF;

                        vpasexec := 43;
                        xorden := f_ordenconsorcio(1, xcgarant, pcramo, pcmodali, pccolect,
                                                   pctipseg, pcactivi, psseguro, xnriesgo,
                                                   pnmovimi, error);

                        IF xorden <> 0 THEN
                           xvalorconsorcio := 0;
                        END IF;

                        vpasexec := 44;

                        IF xinsert THEN
                           -- Bug 12589 - FAL - 31/03/2010 -- 0012589: CEM - Recibos con copago y consorcio
                           IF xctipreb = 4 THEN
                              IF pctipapo = 1 THEN
                                 FOR vapor IN cur_aportaseg(psseguro, pfefecto, xnriesgo) LOOP
                                    IF vapor.ctipimp = 1 THEN
                                       xvalorconsorcio :=
                                          f_round(xvalorconsorcio * vapor.pimport / 100,
                                                  decimals);
                                    ELSIF vapor.ctipimp = 2 THEN
                                       xvalorconsorcio :=
                                                         LEAST(xvalorconsorcio, vapor.iimport);
                                    END IF;
                                 END LOOP;
                              ELSIF pctipapo = 2 THEN
                                 FOR vapor IN cur_aportaseg(psseguro, pfefecto, xnriesgo) LOOP
                                    IF vapor.ctipimp = 1 THEN
                                       xvalorconsorcio :=
                                          f_round(xvalorconsorcio *(1 -(vapor.pimport / 100)),
                                                  decimals);
                                    ELSIF vapor.ctipimp = 2 THEN
                                       xvalorconsorcio :=
                                                  GREATEST(0, xvalorconsorcio - vapor.iimport);
                                    END IF;
                                 END LOOP;
                              END IF;
                           END IF;

                           vpasexec := 45;
                           -- Fi Bug 12589
                           xvalorconsorcio := f_round(xvalorconsorcio, decimals);   -- JLB - I - BUG 18423 COjo la moneda del producto

                           IF NVL(xvalorconsorcio, 0) <> 0 THEN   -- Bug 12589 - FAL - 31/03/2010 -- 0012589: CEM - Recibos con copago y consorcio
                              vpasexec := 46;
                              error := f_insdetrec(pnrecibo, 2, xvalorconsorcio, xploccoa,
                                                   xcgarant, xnriesgo, xctipcoa, xcageven,
                                                   xxnmovima, 0, 0, 1, NULL, NULL, NULL,
                                                   decimals);   -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda

                              IF error = 0 THEN
                                 pgrabar := 1;
                              ELSE
                                 CLOSE cur_garansegxrisc;

                                 RETURN error;
                              END IF;
                           END IF;   -- Fi Bug 12589
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;

            vpasexec := 47;

            FETCH cur_garansegxrisc
             INTO xnriesgo, xcgarant, xfiniefe, xffinefe, xcageven, xxnmovima, xicapital;
         END LOOP;

         CLOSE cur_garansegxrisc;

         vpasexec := 48;

         -- ARA BUSCAREM LES GARANTIES QUE ESTAVEN EN (FEFECTO-1) I ARA NO ESTAN
         OPEN cur_garansegant;

         FETCH cur_garansegant
          INTO xcgarant, xnriesgo, xfiniefe, xffinefe, xcageven, xxnmovima, xicapital;

         vpasexec := 49;

         WHILE cur_garansegant%FOUND LOOP
            xnasegur1 := 0;
            xnasegur2 := 0;
            xtotcapital := 0;
            xtotcapitalant := 0;
            xcclarie := NULL;
            vpasexec := 50;
            xcimpcon := f_esconsorciable(xcgarant, pcramo, pcmodali, pccolect, pctipseg,
                                         pcactivi, error);

            IF error <> 0 THEN
               CLOSE cur_garansegant;

               RETURN error;
            END IF;

            vpasexec := 51;

            IF xcimpcon = 1 THEN   -- LA GARANTÍA ES CONSORCIABLE
               vpasexec := 52;
               -- bug 10864.NMM.01/08/2009. S'afegeix una variable.
               error := f_concepto(2, xcempres, pfefecto,
                                   --NULL,
                                   xcforpag,   --JAMF 11903 - Puede depender de la forma de pago
                                   pcramo, pcmodali, pctipseg, pccolect, pcactivi, xcgarant,
                                   xctipcla, xivalnor, vcfracci, vcbonifi, vcrecfra, w_climit,
                                   v_cmonimp,   -- BUG 18423 - LCOL000 - Multimoneda
                                   vcderreg);   -- Bug 0020314 - FAL - 29/11/2011
               --
               vpasexec := 53;
               p_tracta_limit(w_climit, w_cduraci, w_nduraci, xcforpag, pfvencim, pfefecto,
                              xsegtemporada, xmeses, xsegtemp1, w_resultat);

               IF w_resultat = 103834 THEN
                  -- LÍMIT NO TROBAT A LA TAULA LIMITES
                  RETURN(103834);
               ELSIF w_resultat = 103514 THEN
                  -- ERROR AL LLEGIR DE LA TAULA LIMITES
                  RETURN(103514);
               END IF;

               -- bug 10864.f.
               IF error <> 0 THEN
                  CLOSE cur_garansegant;

                  RETURN error;
               END IF;

               -- MIREM SI EXISTEIX LA GARANTIA ACTUALMENT
               xcgarantseg := NULL;
               xnriesgoseg := NULL;
               xnmovimiseg := NULL;
               vpasexec := 54;

               BEGIN
                  SELECT cgarant, nriesgo, nmovimi, xicapital
                    INTO xcgarantseg, xnriesgoseg, xnmovimiseg, xicapitalseg
                    FROM garanseg
                   WHERE sseguro = psseguro
                     AND nriesgo = NVL(xnriesgo, nriesgo)
                     AND cgarant = NVL(xcgarant, cgarant)
                     AND nmovimi = pnmovimi;

                  xgrabar := 0;   -- QUE NO GRABI
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     xgrabar := 1;   -- NO EXISTEIX LA GARANTIA ACTUALMENT
                  WHEN OTHERS THEN
                     CLOSE cur_garansegant;

                     RETURN 103500;   -- ERROR AL LLEGIR DE GARANSEG
               END;

               vpasexec := 55;

               IF xgrabar = 1 THEN   -- NO EXISTEIX LA GARANTIA ACTUALMENT
                  -- Obtenemos la prima, para consorcio sobre prima
                  BEGIN
                     SELECT   SUM(iconcep)
                         INTO iconcep0
                         FROM detrecibos
                        WHERE nrecibo = pnrecibo
                          AND nriesgo = xnriesgo
                          AND cgarant = xcgarant
                          AND(cconcep = 0
                              OR cconcep = 50)   -- LOCAL +  CEDIDA
                     GROUP BY nriesgo, cgarant;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        NULL;
                     WHEN OTHERS THEN
                        CLOSE cur_garansegxrisc;

                        error := 103512;
                        -- ERROR AL LLEGIR DE DETRECIBOS
                        RETURN error;
                  END;

                  vpasexec := 56;
                  --BUG 24656-XVM-16/11/2012.Añadir paccion. 2-Suplemento
                  error := pac_impuestos.f_calcula_impconcepto(xivalnor, iconcep0, iconcep0,
                                                               NULL, NULL, NULL, -xicapital,   -- Capital anterior.
                                                               NULL, NULL, xctipcla, xcforpag,
                                                               vcfracci, vcbonifi, vcrecfra,
                                                               xcons,
                                                               -- JLB - I - BUG 18423 COjo la moneda del producto
                                                               NULL, NULL, NULL, pfefecto,
                                                               psseguro, xnriesgo, xcgarant,

                                                               -- decimals, NULL, 2);   -- JLB - F - BUG 18423 COjo la moneda del producto
                                                               decimals, NULL, 2, NULL,
                                                               pnmovimiant);   -- BUG 34505 - FAL - 17/03/2015

                  IF error <> 0 THEN   -- Si da error la función.
                     CLOSE cur_garansegxrisc;

                     RETURN error;
                  END IF;

                  vpasexec := 57;

                  -- bug 10864.NMM.01/08/2009. S'elimina un troç de codi.
                  IF xinnomin
                     AND xctipcla = 4 THEN
                     xvalorconsorcio := NVL(xcons, 0) * xnasegur1;
                  ELSE
                     xvalorconsorcio := NVL(xcons, 0);
                  END IF;

                  vpasexec := 58;

                  IF xvalorconsorcio IS NOT NULL
                     AND xvalorconsorcio <> 0 THEN
                     IF xsegtemporada THEN
                        xvalorconsorcio := xvalorconsorcio * xsegtemp1;

                        IF xmeses > 12 THEN
                           vpasexec := 59;
                           -- ES HASTA EL VENCIMIENTO Y SUPERIOR AL AÑO
                           error := f_difdata(pfefecto, pfvencim, 3, 3, xresult);

                           IF error = 0 THEN
                              IF xctipcla = 2 THEN   -- ES IMPORTE FIJO
                                 xvalorconsorcio := xvalorconsorcio * CEIL(xresult / 360);
                              ELSIF xctipcla = 4 THEN
                                 -- ES SOBRE EL CAPITAL
                                 xvalorconsorcio := xvalorconsorcio * xresult / 360;
                              ELSE
                                 NULL;
                              END IF;
                           ELSE
                              RETURN error;
                           END IF;
                        END IF;
                     ELSE
                        --JAMF 11903 - Dejamos las diferencias de provisión como estaban
                        IF vcfracci = 1
                           AND ptipomovimiento NOT IN(11) THEN
                           xvalorconsorcio := NVL(xvalorconsorcio, 0) * pfacconsorfra;
                        ELSE
                           xvalorconsorcio := NVL(xvalorconsorcio, 0) * pfacconsor;
                        END IF;
                     END IF;

                     vpasexec := 60;
                     xorden := f_ordenconsorcio(1, xcgarant, pcramo, pcmodali, pccolect,
                                                pctipseg, pcactivi, psseguro, xnriesgo,
                                                pnmovimiant, error);

                     IF xorden <> 0 THEN
                        xvalorconsorcio := 0;
                     END IF;

                     vpasexec := 61;

                     IF NVL(xvalorconsorcio, 0) <> 0 THEN
                        -- Bug 12589 - FAL - 31/03/2010 -- 0012589: CEM - Recibos con copago y consorcio
                        IF xctipreb = 4 THEN
                           IF pctipapo = 1 THEN
                              FOR vapor IN cur_aportaseg(psseguro, pfefecto, xnriesgo) LOOP
                                 IF vapor.ctipimp = 1 THEN
                                    xvalorconsorcio :=
                                       f_round(xvalorconsorcio * vapor.pimport / 100,
                                               decimals);
                                 ELSIF vapor.ctipimp = 2 THEN
                                    xvalorconsorcio := LEAST(xvalorconsorcio, vapor.iimport);
                                 END IF;
                              END LOOP;
                           ELSIF pctipapo = 2 THEN
                              FOR vapor IN cur_aportaseg(psseguro, pfefecto, xnriesgo) LOOP
                                 IF vapor.ctipimp = 1 THEN
                                    xvalorconsorcio :=
                                       f_round(xvalorconsorcio *(1 -(vapor.pimport / 100)),
                                               decimals);
                                 ELSIF vapor.ctipimp = 2 THEN
                                    xvalorconsorcio :=
                                                  GREATEST(0, xvalorconsorcio - vapor.iimport);
                                 END IF;
                              END LOOP;
                           END IF;
                        END IF;

                        vpasexec := 62;
                        -- Fi Bug 12589
                        xvalorconsorcio := f_round(xvalorconsorcio, decimals);   -- JLB - I - BUG 18423 COjo la moneda del producto

                        IF NVL(xvalorconsorcio, 0) <> 0 THEN   -- Bug 12589 - FAL - 31/03/2010 -- 0012589: CEM - Recibos con copago y consorcio
                           vpasexec := 63;
                           error := f_insdetrec(pnrecibo, 2, xvalorconsorcio, xploccoa,
                                                xcgarant, xnriesgo, xctipcoa, xcageven,
                                                xxnmovima, 0, 0, 1, NULL, NULL, NULL,
                                                decimals);   -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda

                           IF error = 0 THEN
                              pgrabar := 1;
                           ELSE
                              CLOSE cur_garansegant;

                              RETURN error;
                           END IF;
                        END IF;   -- Fi Bug 12589
                     END IF;
                  END IF;
               END IF;   -- IF DEL XGRABAR
            END IF;

            vpasexec := 63;

            FETCH cur_garansegant
             INTO xcgarant, xnriesgo, xfiniefe, xffinefe, xcageven, xxnmovima, xicapital;
         END LOOP;

         CLOSE cur_garansegant;

         -- bug 10864.NMM.01/08/2009. S'elimina un troç de codi.
         RETURN(0);
--*****************************************************************
-- FI SUPLEMENTS PER MODUS 'R'
--*****************************************************************

      --JAMF 11903 - Ahora sí que se calcula consorcio en la cartera no anual si el consorcio es fraccionado
      --ELSIF ptipomovimiento = 22 THEN   -- RENOVACIONS NO ANUALS
      --   RETURN 0;   -- AQUÍ NO ES CALCULA EL CONSORCI
      ELSE
         RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
      END IF;
   /* ***** */
   -- FINS AQUÍ HEM TRACTAT SI EL PCMODO ÉS 'R'
   /* ***** */
   ELSIF pcmodo IN('P', 'N', 'PRIE') THEN
      vpasexec := 64;

      IF ptipomovimiento IN(0, 6) THEN
         vpasexec := 65;

         IF pfuncion = 'CAR' THEN
            vselect := 'SELECT nriesgo, cgarant, finiefe, ffinefe, icapital'
                       || ' FROM garanseg' || ' WHERE sseguro = ' || psseguro
                       || '  AND nmovimi = ' || pnmovimi;

            IF pnriesgo IS NOT NULL THEN
               vselect := vselect || ' AND nriesgo = ' || pnriesgo;
            END IF;
         ELSIF pfuncion = 'TAR' THEN
            vselect := 'SELECT nriesgo, cgarant, finiefe, ffinefe, icapital'
                       || ' FROM tmp_garancar' || ' WHERE sseguro = ' || psseguro;

            IF pnriesgo IS NOT NULL THEN
               vselect := vselect || ' AND nriesgo = ' || pnriesgo;
            END IF;
         END IF;

         vpasexec := 66;

         OPEN curgaran FOR vselect;

         FETCH curgaran
          INTO xnriesgo, xcgarant, xfiniefe, xffinefe, xicapital;

         vpasexec := 67;

         WHILE curgaran%FOUND LOOP
            xnasegur1 := 0;
            xnasegur2 := 0;
            xcclarie := NULL;
            vpasexec := 68;
            xcimpcon := f_esconsorciable(xcgarant, pcramo, pcmodali, pccolect, pctipseg,
                                         pcactivi, error);

            IF error <> 0 THEN
               CLOSE curgaran;

               RETURN error;
            END IF;

            vpasexec := 69;

            IF xcimpcon = 1 THEN   -- LA GARANTÍA ES CONSORCIABLE
               -- bug 10864.NMM.01/08/2009. S'afegeix una variable.
               vpasexec := 70;
               error := f_concepto(2, xcempres, pfefecto,
                                   --NULL,
                                   xcforpag,   --JAMF 11903 - Puede depender de la forma de pago
                                   pcramo, pcmodali, pctipseg, pccolect, pcactivi, xcgarant,
                                   xctipcla, xivalnor, vcfracci, vcbonifi, vcrecfra, w_climit,
                                   v_cmonimp,   -- BUG 18423 - LCOL000 - Multimoneda
                                   vcderreg);   -- Bug 0020314 - FAL - 29/11/2011
               --
               vpasexec := 71;
               p_tracta_limit(w_climit, w_cduraci, w_nduraci, xcforpag, pfvencim, pfefecto,
                              xsegtemporada, xmeses, xsegtemp1, w_resultat);

               IF w_resultat = 103834 THEN
                  -- LÍMIT NO TROBAT A LA TAULA LIMITES
                  RETURN(103834);
               ELSIF w_resultat = 103514 THEN
                  -- ERROR AL LLEGIR DE LA TAULA LIMITES
                  RETURN(103514);
               END IF;

               -- bug 10864.f.
               IF error <> 0 THEN
                  CLOSE curgaran;

                  RETURN error;
               END IF;

               vpasexec := 72;

               BEGIN
                  SELECT   SUM(iconcep)
                      INTO iconcep0
                      FROM detreciboscar
                     WHERE sproces = psproces
                       AND nrecibo = pnrecibo
                       AND nriesgo = xnriesgo
                       AND cgarant = xcgarant
                       AND(cconcep IN(0, 50))   -- LOCAL +  CEDIDA
                  GROUP BY nriesgo, cgarant;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     NULL;
                  WHEN OTHERS THEN
                     CLOSE curgaran;

                     error := 103516;
                     -- ERROR AL LLEGIR DE DETRECIBOSCAR
                     RETURN error;
               END;

               vpasexec := 73;
               --BUG 24656-XVM-16/11/2012.Añadir paccion
               error := pac_impuestos.f_calcula_impconcepto(xivalnor, iconcep0, iconcep0, NULL,
                                                            NULL, NULL, xicapital,   -- Capital anterior.
                                                            NULL, NULL, xctipcla, xcforpag,
                                                            vcfracci, vcbonifi, vcrecfra,
                                                            xcons,
                                                            -- JLB - I - BUG 18423 COjo la moneda del producto
                                                            NULL, NULL, NULL, pfefecto,
                                                            psseguro, xnriesgo, xcgarant,

                                                            -- decimals, NULL, 0);   -- JLB - F - BUG 18423 COjo la moneda del producto
                                                            decimals, NULL, 0, NULL, pnmovimi);   -- BUG 34505 - FAL - 17/03/2015
               vpasexec := 74;

               -- bug 10864.NMM.01/08/2009. S'elimina un troç de codi.
               IF xinnomin
                  AND xctipcla IN(2, 4) THEN
                  xvalorconsorcio := NVL(xcons, 0) * xnasegur1;
               ELSE
                  xvalorconsorcio := NVL(xcons, 0);
               END IF;

               vpasexec := 75;

               IF pttabla = 'SOL' THEN
                  BEGIN
                     SELECT DECODE(nasegur, NULL, 1, nasegur)
                       INTO xnasegur1
                       FROM solriesgos
                      WHERE ssolicit = psseguro
                        AND nriesgo = NVL(xnriesgo, 1);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE curgaran;

                        RETURN 103836;   -- RISC NO TROBAT A RIESGOS
                     WHEN OTHERS THEN
                        CLOSE curgaran;

                        RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                  END;
               ELSIF pttabla = 'EST' THEN
                  BEGIN
                     SELECT DECODE(nasegur, NULL, 1, nasegur)
                       INTO xnasegur1
                       FROM estriesgos
                      WHERE sseguro = psseguro
                        AND nriesgo = NVL(xnriesgo, 1);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE curgaran;

                        RETURN 103836;   -- RISC NO TROBAT A RIESGOS
                     WHEN OTHERS THEN
                        CLOSE curgaran;

                        RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                  END;
               ELSE
                  BEGIN
                     SELECT DECODE(nasegur, NULL, 1, nasegur)
                       INTO xnasegur1
                       FROM riesgos
                      WHERE sseguro = psseguro
                        AND nriesgo = NVL(xnriesgo, 1);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE curgaran;

                        RETURN 103836;   -- RISC NO TROBAT A RIESGOS
                     WHEN OTHERS THEN
                        CLOSE curgaran;

                        RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                  END;
               END IF;

               vpasexec := 76;

               IF xvalorconsorcio IS NOT NULL
                  AND xvalorconsorcio <> 0 THEN
                  IF xsegtemporada THEN
                     xvalorconsorcio := xvalorconsorcio * xsegtemp1;

                     IF xmeses > 12 THEN
                        -- ES HASTA EL VENCIMIENTO Y SUPERIOR AL AÑO
                        error := f_difdata(pfefecto, pfvencim, 3, 3, xresult);

                        IF error = 0 THEN
                           IF xctipcla = 2 THEN   -- ES IMOPORTE FIJO
                              xvalorconsorcio := xvalorconsorcio * CEIL(xresult / 360);
                           ELSIF xctipcla = 4 THEN
                              -- ES SOBRE EL CAPITAL
                              xvalorconsorcio := xvalorconsorcio * xresult / 360;
                           ELSE
                              NULL;
                           END IF;
                        ELSE
                           RETURN error;
                        END IF;
                     END IF;
                  ELSE
                     --JAMF 11903 - Se aplica el fraccionamiento si no es una regularización (6)
                     IF vcfracci = 1
                        AND ptipomovimiento NOT IN(6) THEN
                        xvalorconsorcio := xvalorconsorcio * pfacconsorfra;
                     ELSE
                        xvalorconsorcio := xvalorconsorcio * pfacconsor;
                     END IF;
                  END IF;

                  IF pcapieve = 1 THEN
                     -- APLIQUEM EL TEMPS EN CAPITAL EVENTUAL
                     error := f_difdata(xfiniefe, xffinefe, 3, 3, xdifdiaseve);

                     IF error = 0 THEN
                        xvalorconsorcio := xvalorconsorcio * xdifdiaseve / 360;
                     ELSE
                        RETURN error;
                     END IF;
                  END IF;

                  vpasexec := 77;
                  xorden := f_ordenconsorcio(1, xcgarant, pcramo, pcmodali, pccolect, pctipseg,
                                             pcactivi, psseguro, xnriesgo, pnmovimi, error);

                  IF xorden <> 0 THEN
                     xvalorconsorcio := 0;
                  END IF;

                  vpasexec := 78;

                  IF NVL(xvalorconsorcio, 0) <> 0 THEN
                     -- Bug 12589 - FAL - 31/03/2010 -- 0012589: CEM - Recibos con copago y consorcio
                     IF xctipreb = 4 THEN
                        IF pctipapo = 1 THEN
                           FOR vapor IN cur_aportaseg(psseguro, pfefecto, xnriesgo) LOOP
                              IF vapor.ctipimp = 1 THEN
                                 xvalorconsorcio :=
                                      f_round(xvalorconsorcio * vapor.pimport / 100, decimals);
                              ELSIF vapor.ctipimp = 2 THEN
                                 xvalorconsorcio := LEAST(xvalorconsorcio, vapor.iimport);
                              END IF;
                           END LOOP;
                        ELSIF pctipapo = 2 THEN
                           FOR vapor IN cur_aportaseg(psseguro, pfefecto, xnriesgo) LOOP
                              IF vapor.ctipimp = 1 THEN
                                 xvalorconsorcio :=
                                    f_round(xvalorconsorcio *(1 -(vapor.pimport / 100)),
                                            decimals);
                              ELSIF vapor.ctipimp = 2 THEN
                                 xvalorconsorcio :=
                                                  GREATEST(0, xvalorconsorcio - vapor.iimport);
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;

                     -- Fi Bug 12589
                     xvalorconsorcio := f_round(xvalorconsorcio, decimals);   -- JLB - I - BUG 18423 COjo la moneda del producto
                     vpasexec := 79;

                     IF NVL(xvalorconsorcio, 0) <> 0 THEN   -- Bug 12589 - FAL - 31/03/2010 -- 0012589: CEM - Recibos con copago y consorcio
                        error := f_insdetreccar(psproces, pnrecibo, 2, xvalorconsorcio,
                                                xploccoa, xcgarant, xnriesgo, xctipcoa,
                                                xcageven, xxnmovima, 0, 0, 1, NULL, NULL,
                                                NULL, decimals);   -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda

                        IF error = 0 THEN
                           pgrabar := 1;
                        ELSE
                           CLOSE curgaran;

                           RETURN error;
                        END IF;
                     END IF;   -- Fi Bug 12589
                  END IF;
               END IF;
            END IF;

            vpasexec := 80;

            FETCH curgaran
             INTO xnriesgo, xcgarant, xfiniefe, xffinefe, xicapital;
         END LOOP;

         CLOSE curgaran;

         -- bug 10864.NMM.01/08/2009. S'elimina un troç de codi.
         RETURN(0);
      ELSIF ptipomovimiento = 1 THEN   -- SUPLEMENTS
         vpasexec := 81;

         OPEN cur_garansegxrisc;

         FETCH cur_garansegxrisc
          INTO xnriesgo, xcgarant, xfiniefe, xffinefe, xcageven, xxnmovima, xicapital;

         WHILE cur_garansegxrisc%FOUND LOOP
            xnasegur1 := 0;
            xnasegur2 := 0;
            xtotcapital := 0;
            xtotcapitalant := 0;
            existant := TRUE;
            xcclarie := NULL;
            vpasexec := 82;
            xcimpcon := f_esconsorciable(xcgarant, pcramo, pcmodali, pccolect, pctipseg,
                                         pcactivi, error);

            IF error <> 0 THEN
               CLOSE cur_garansegxrisc;

               RETURN error;
            END IF;

            vpasexec := 83;

            IF xcimpcon = 1 THEN   -- LA GARANTÍA ES CONSORCIABLE
               vpasexec := 84;
               -- bug 10864.NMM.01/08/2009. S'afegeix una variable.
               error := f_concepto(2, xcempres, pfefecto,
                                   --NULL,
                                   xcforpag,   --JAMF 11903 - Puede depender de la forma de pago
                                   pcramo, pcmodali, pctipseg, pccolect, pcactivi, xcgarant,
                                   xctipcla, xivalnor, vcfracci, vcbonifi, vcrecfra, w_climit,
                                   v_cmonimp,   -- BUG 18423 - LCOL000 - Multimoneda
                                   vcderreg);   -- Bug 0020314 - FAL - 29/11/2011
               --
               vpasexec := 85;
               p_tracta_limit(w_climit, w_cduraci, w_nduraci, xcforpag, pfvencim, pfefecto,
                              xsegtemporada, xmeses, xsegtemp1, w_resultat);

               IF w_resultat = 103834 THEN
                  -- LÍMIT NO TROBAT A LA TAULA LIMITES
                  RETURN(103834);
               ELSIF w_resultat = 103514 THEN
                  -- ERROR AL LLEGIR DE LA TAULA LIMITES
                  RETURN(103514);
               END IF;

               -- bug 10864.f.
               IF error <> 0 THEN
                  CLOSE cur_garansegxrisc;

                  RETURN error;
               END IF;

               -- OBTENIM LA GARANTIA ANTERIOR
               xcgarantant := NULL;
               xnriesgoant := NULL;
               xnmovimiant := NULL;
               vpasexec := 86;

               BEGIN
                  SELECT cgarant, nriesgo, nmovimi, finiefe, icapital
                    INTO xcgarantant, xnriesgoant, xnmovimiant, xfiniefeant, xicapitalant
                    FROM garanseg
                   WHERE sseguro = psseguro
                     AND nriesgo = NVL(xnriesgo, nriesgo)
                     AND cgarant = NVL(xcgarant, cgarant)
                     AND nmovimi = pnmovimiant;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     existant := FALSE;   -- NO TENIM GARANTIA ANTERIOR
                  WHEN OTHERS THEN
                     CLOSE cur_garansegxrisc;

                     RETURN 103500;   -- ERROR AL LLEGIR DE GARANSEG
               END;

               vpasexec := 87;

               -- Obtenemos la prima, para cuando consorcio sobre prima
               BEGIN
                  SELECT   NVL(SUM(iconcep), 0)
                      INTO iconcep0
                      FROM detreciboscar
                     WHERE sproces = psproces
                       AND nrecibo = pnrecibo
                       AND nriesgo = xnriesgo
                       AND cgarant = xcgarant
                       AND(cconcep = 0
                           OR cconcep = 50)   -- LOCAL +  CEDIDA
                  GROUP BY nriesgo, cgarant;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     NULL;
                  WHEN OTHERS THEN
                     CLOSE cur_garansegxrisc;

                     error := 103516;
                     -- ERROR AL LLEGIR DE DETRECIBOSCAR
                     RETURN error;
               END;

               vpasexec := 88;

               IF xctipcla = 4 THEN
                  IF xinnomin THEN   -- ES INNOMINAT
                     BEGIN
                        SELECT DECODE(nasegur, NULL, 1, nasegur)
                          INTO xnasegur1
                          FROM riesgos
                         WHERE sseguro = psseguro
                           AND nriesgo = NVL(xnriesgo, 1);
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           CLOSE cur_garansegxrisc;

                           RETURN 103836;   -- RISC NO TROBAT A RIESGOS
                        WHEN OTHERS THEN
                           CLOSE cur_garansegxrisc;

                           RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                     END;

                     xtotcapital := NVL(xicapital, 0) * xnasegur1;
                  ELSE
                     xtotcapital := NVL(xicapital, 0);
                  END IF;

                  vpasexec := 89;

                  IF existant THEN
                     BEGIN
                        SELECT DECODE(nasegur, NULL, 1, nasegur)
                          INTO xnasegur2
                          FROM riesgos
                         WHERE sseguro = psseguro
                           AND nriesgo = NVL(xnriesgoant, 1);
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           CLOSE cur_garansegxrisc;

                           RETURN 103836;   -- RISC NO TROBAT A RIESGOS
                        WHEN OTHERS THEN
                           CLOSE cur_garansegxrisc;

                           RETURN 103509;   -- ERROR AL LLEGIR DE RIESGOS
                     END;

                     IF xinnomin THEN   -- ES INNOMINAT
                        xtotcapitalant := NVL(xicapitalant, 0) * xnasegur2;
                     ELSE
                        xtotcapitalant := NVL(xicapitalant, 0);
                     END IF;
                  END IF;
               ELSE
                  xcapitaltrobat := xicapital;
               END IF;

               vpasexec := 90;

               IF xctipcla IN
                     (4, 6)   -- BUG 0035409 - FAL - 10/04/2015 - Añadir tipo concepto 6 (Fórmula que devuelve un % a aplicar al capital)
                  AND existant THEN
                  xcapitaltrobat := xtotcapital - xtotcapitalant;
               ELSE
                  xcapitaltrobat := xicapital;
               END IF;

               vpasexec := 91;
               --BUG 24656-XVM-16/11/2012.Añadir paccion
               error := pac_impuestos.f_calcula_impconcepto(xivalnor, iconcep0, iconcep0, NULL,
                                                            NULL, NULL, xcapitaltrobat, NULL,
                                                            NULL, xctipcla, xcforpag, vcfracci,
                                                            vcbonifi, vcrecfra, xcons,
                                                            -- JLB - I - BUG 18423 COjo la moneda del producto
                                                            NULL, NULL, NULL, pfefecto,
                                                            psseguro, xnriesgo, xcgarant,

                                                            -- decimals, NULL, 2);   -- JLB - F - BUG 18423 COjo la moneda del producto
                                                            decimals, NULL, 2, NULL, pnmovimi);   -- BUG 34505 - FAL - 17/03/2015

               IF error <> 0 THEN
                  CLOSE cur_garansegxrisc;

                  RETURN error;
               END IF;

               IF xctipcla = 2
                  AND existant THEN
                  xcons := 0;
               END IF;

               vpasexec := 92;
               -- bug 10864.NMM.01/08/2009. S'elimina un troç de codi.
               xvalorconsorcio := NVL(xcons, 0);

               IF xvalorconsorcio IS NOT NULL
                  AND xvalorconsorcio <> 0 THEN
                  IF xsegtemporada THEN
                     xvalorconsorcio := xvalorconsorcio * xsegtemp1;

                     IF xmeses > 12 THEN
                        vpasexec := 93;
                        -- ES HASTA EL VENCIMIENTO Y SUPERIOR AL AÑO
                        error := f_difdata(pfefecto, pfvencim, 3, 3, xresult);

                        IF error = 0 THEN
                           IF xctipcla = 2 THEN   -- ES IMPORTE FIJO
                              xvalorconsorcio := xvalorconsorcio * CEIL(xresult / 360);
                           ELSIF xctipcla = 4 THEN
                              -- ES SOBRE EL CAPITAL
                              xvalorconsorcio := xvalorconsorcio * xresult / 360;
                           ELSE
                              NULL;
                           END IF;
                        ELSE
                           RETURN error;
                        END IF;
                     END IF;
                  ELSE
                     --JAMF 11903
                     IF vcfracci = 1 THEN
                        xvalorconsorcio := NVL(xvalorconsorcio, 0) * pfacconsorfra;
                     ELSE
                        xvalorconsorcio := NVL(xvalorconsorcio, 0) * pfacconsor;
                     END IF;
                  END IF;

                  vpasexec := 94;

                  IF NVL(xvalorconsorcio, 0) <> 0 THEN
                     xinsert := TRUE;

                     IF paltarisc THEN   -- ES UN SUPLEMENT DE ALTA
                        BEGIN
                           SELECT nmovima
                             INTO xnmovima
                             FROM riesgos
                            WHERE sseguro = psseguro
                              AND nriesgo = xnriesgo
                              AND nmovima = pnmovimi;

                           xinsert := TRUE;
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              xinsert := FALSE;
                           WHEN OTHERS THEN
                              CLOSE cur_garansegxrisc;

                              RETURN 103509;
                        -- ERROR AL LLEGIR DE RIESGOS
                        END;
                     END IF;

                     vpasexec := 95;

                     IF xinsert THEN
                        vpasexec := 96;
                        xorden := f_ordenconsorcio(1, xcgarant, pcramo, pcmodali, pccolect,
                                                   pctipseg, pcactivi, psseguro, xnriesgo,
                                                   pnmovimi, error);

                        IF xorden <> 0 THEN
                           xvalorconsorcio := 0;
                        END IF;

                        vpasexec := 97;

                        -- Bug 12589 - FAL - 31/03/2010 -- 0012589: CEM - Recibos con copago y consorcio
                        IF xctipreb = 4 THEN
                           IF pctipapo = 1 THEN
                              FOR vapor IN cur_aportaseg(psseguro, pfefecto, xnriesgo) LOOP
                                 IF vapor.ctipimp = 1 THEN
                                    xvalorconsorcio :=
                                       f_round(xvalorconsorcio * vapor.pimport / 100,
                                               decimals);
                                 ELSIF vapor.ctipimp = 2 THEN
                                    xvalorconsorcio := LEAST(xvalorconsorcio, vapor.iimport);
                                 END IF;
                              END LOOP;
                           ELSIF pctipapo = 2 THEN
                              FOR vapor IN cur_aportaseg(psseguro, pfefecto, xnriesgo) LOOP
                                 IF vapor.ctipimp = 1 THEN
                                    xvalorconsorcio :=
                                       f_round(xvalorconsorcio *(1 -(vapor.pimport / 100)),
                                               decimals);
                                 ELSIF vapor.ctipimp = 2 THEN
                                    xvalorconsorcio :=
                                                  GREATEST(0, xvalorconsorcio - vapor.iimport);
                                 END IF;
                              END LOOP;
                           END IF;
                        END IF;

                        vpasexec := 98;
                        -- Fi Bug 12589
                        xvalorconsorcio := f_round(xvalorconsorcio, decimals);   -- JLB - I - BUG 18423 COjo la moneda del producto

                        IF NVL(xvalorconsorcio, 0) <> 0 THEN   -- Bug 12589 - FAL - 31/03/2010 -- 0012589: CEM - Recibos con copago y consorcio
                           vpasexec := 99;
                           error := f_insdetreccar(psproces, pnrecibo, 2, xvalorconsorcio,
                                                   xploccoa, xcgarant, xnriesgo, xctipcoa,
                                                   xcageven, xxnmovima, 0, 0, 1, NULL, NULL,
                                                   NULL, decimals);   -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda

                           IF error = 0 THEN
                              pgrabar := 1;
                           ELSE
                              CLOSE cur_garansegxrisc;

                              RETURN error;
                           END IF;
                        END IF;   -- Fi Bug 12589
                     END IF;
                  END IF;
               END IF;
            END IF;

            vpasexec := 100;

            FETCH cur_garansegxrisc
             INTO xnriesgo, xcgarant, xfiniefe, xffinefe, xcageven, xxnmovima, xicapital;
         END LOOP;

         CLOSE cur_garansegxrisc;

         -- ARA BUSCAREM LES GARANTIES QUE ESTAVEN EN (FEFECTO-1) I ARA NO ESTAN
         vpasexec := 101;

         OPEN cur_garansegant;

         FETCH cur_garansegant
          INTO xcgarant, xnriesgo, xfiniefe, xffinefe, xcageven, xxnmovima, xicapital;

         WHILE cur_garansegant%FOUND LOOP
            xnasegur1 := 0;
            xnasegur2 := 0;
            xtotcapital := 0;
            xtotcapitalant := 0;
            xcclarie := NULL;
            vpasexec := 102;
            xcimpcon := f_esconsorciable(xcgarant, pcramo, pcmodali, pccolect, pctipseg,
                                         pcactivi, error);

            IF error <> 0 THEN
               CLOSE cur_garansegant;

               RETURN error;
            END IF;

            vpasexec := 103;

            IF xcimpcon = 1 THEN   -- LA GARANTÍA ES CONSORCIABLE
               vpasexec := 104;
               -- bug 10864.NMM.01/08/2009. S'afegeix una variable.
               error := f_concepto(2, xcempres, pfefecto,
                                   --NULL,
                                   xcforpag,   --JAMF 11903 - Puede depender de la forma de pago
                                   pcramo, pcmodali, pctipseg, pccolect, pcactivi, xcgarant,
                                   xctipcla, xivalnor, vcfracci, vcbonifi, vcrecfra, w_climit,
                                   v_cmonimp,   -- BUG 18423 - LCOL000 - Multimoneda
                                   vcderreg);   -- Bug 0020314 - FAL - 29/11/2011
               --
               vpasexec := 105;
               p_tracta_limit(w_climit, w_cduraci, w_nduraci, xcforpag, pfvencim, pfefecto,
                              xsegtemporada, xmeses, xsegtemp1, w_resultat);

               IF w_resultat = 103834 THEN
                  -- LÍMIT NO TROBAT A LA TAULA LIMITES
                  RETURN(103834);
               ELSIF w_resultat = 103514 THEN
                  -- ERROR AL LLEGIR DE LA TAULA LIMITES
                  RETURN(103514);
               END IF;

               -- bug 10864.f.
               IF error <> 0 THEN
                  CLOSE cur_garansegant;

                  RETURN error;
               END IF;

               vpasexec := 106;
               -- MIREM SI EXISTEIX LA GARANTIA ACTUALMENT
               xcgarantseg := NULL;
               xnriesgoseg := NULL;
               xnmovimiseg := NULL;
               xfefectoseg := NULL;

               BEGIN
                  SELECT cgarant, nriesgo, nmovimi, finiefe, icapital
                    INTO xcgarantseg, xnriesgoseg, xnmovimiseg, xfefectoseg, xicapitalseg
                    FROM garanseg
                   WHERE sseguro = psseguro
                     AND nriesgo = NVL(xnriesgo, nriesgo)
                     AND cgarant = NVL(xcgarant, cgarant)
                     AND nmovimi = pnmovimi;

                  xgrabar := 0;   -- QUE NO GRABI
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     xgrabar := 1;   -- NO TENIM GARANTIA SEGUENT
                  WHEN OTHERS THEN
                     CLOSE cur_garansegant;

                     RETURN 103500;   -- ERROR AL LLEGIR DE GARANSEG
               END;

               vpasexec := 107;

               IF xgrabar = 1 THEN
                  -- Obtenemos la prima, para cuando consorcio sobre prima
                  BEGIN
                     SELECT   NVL(SUM(iconcep), 0)
                         INTO iconcep0
                         FROM detrecibos
                        WHERE nrecibo = pnrecibo
                          AND nriesgo = xnriesgo
                          AND cgarant = xcgarant
                          AND(cconcep = 0
                              OR cconcep = 50)   -- LOCAL +  CEDIDA
                     GROUP BY nriesgo, cgarant;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        NULL;
                     WHEN OTHERS THEN
                        CLOSE cur_garansegant;

                        error := 103512;
                        -- ERROR AL LLEGIR DE DETRECIBOS
                        RETURN error;
                  END;

                  vpasexec := 108;

                  BEGIN
                     SELECT DECODE(nasegur, NULL, 1, nasegur)
                       INTO xnasegur1
                       FROM riesgos
                      WHERE sseguro = psseguro
                        AND nriesgo = NVL(xnriesgo, 1);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE cur_garansegant;

                        RETURN 103836;
                     -- RISC NO TROBAT A RIESGOS
                     WHEN OTHERS THEN
                        CLOSE cur_garansegant;

                        RETURN 103509;
                  -- ERROR AL LLEGIR DE RIESGOS
                  END;

                  vpasexec := 109;
                  --BUG 24656-XVM-16/11/2012.Añadir paccion
                  error := pac_impuestos.f_calcula_impconcepto(xivalnor, iconcep0, iconcep0,
                                                               NULL, NULL, NULL, -xicapital,
                                                               NULL, NULL, xctipcla, xcforpag,
                                                               vcfracci, vcbonifi, vcrecfra,
                                                               xcons,
                                                               -- JLB - I - BUG 18423 COjo la moneda del producto
                                                               NULL, NULL, NULL, pfefecto,
                                                               psseguro, xnriesgo, xcgarant,

                                                               -- decimals, NULL, 2);   -- JLB - F - BUG 18423 COjo la moneda del producto
                                                               decimals, NULL, 2, NULL,
                                                               pnmovimiant);   -- BUG 34505 - FAL - 17/03/2015

                  IF error <> 0 THEN
                     CLOSE cur_garansegxrisc;

                     RETURN error;
                  END IF;

                  vpasexec := 110;

                  -- bug 10864.NMM.01/08/2009. S'elimina un troç de codi.
                  IF xctipcla = 4 THEN   -- Hem de retornar el consorci.
                     IF xinnomin THEN
                        xvalorconsorcio := NVL(xcons, 0) * xnasegur1;
                     ELSE
                        xvalorconsorcio := NVL(xcons, 0);
                     END IF;
                  ELSE
                     xvalorconsorcio := 0;   -- No hem de retornar el consorci.
                  END IF;

                  vpasexec := 111;

                  IF xvalorconsorcio IS NOT NULL
                     AND xvalorconsorcio <> 0 THEN
                     IF xsegtemporada THEN
                        xvalorconsorcio := xvalorconsorcio * xsegtemp1;

                        IF xmeses > 12 THEN
                           vpasexec := 112;
                           -- ES HASTA EL VENCIMIENTO Y SUPERIOR AL AÑO
                           error := f_difdata(pfefecto, pfvencim, 3, 3, xresult);

                           IF error = 0 THEN
                              IF xctipcla = 2 THEN   -- ES IMPORTE FIJO
                                 xvalorconsorcio := xvalorconsorcio * CEIL(xresult / 360);
                              ELSIF xctipcla = 4 THEN
                                 -- ES SOBRE EL CAPITAL
                                 xvalorconsorcio := xvalorconsorcio * xresult / 360;
                              ELSE
                                 NULL;
                              END IF;
                           ELSE
                              RETURN error;
                           END IF;
                        END IF;
                     ELSE
                        --JAMF 11903
                        IF vcfracci = 1 THEN
                           xvalorconsorcio := NVL(xvalorconsorcio, 0) * pfacconsorfra;
                        ELSE
                           xvalorconsorcio := NVL(xvalorconsorcio, 0) * pfacconsor;
                        END IF;
                     END IF;

                     vpasexec := 113;
                     xorden := f_ordenconsorcio(1, xcgarant, pcramo, pcmodali, pccolect,
                                                pctipseg, pcactivi, psseguro, xnriesgo,
                                                pnmovimiant, error);

                     IF xorden <> 0 THEN
                        xvalorconsorcio := 0;
                     END IF;

                     vpasexec := 114;

                     IF NVL(xvalorconsorcio, 0) <> 0 THEN
                        -- Bug 12589 - FAL - 31/03/2010 -- 0012589: CEM - Recibos con copago y consorcio
                        IF xctipreb = 4 THEN
                           IF pctipapo = 1 THEN
                              FOR vapor IN cur_aportaseg(psseguro, pfefecto, xnriesgo) LOOP
                                 IF vapor.ctipimp = 1 THEN
                                    xvalorconsorcio :=
                                       f_round(xvalorconsorcio * vapor.pimport / 100,
                                               decimals);
                                 ELSIF vapor.ctipimp = 2 THEN
                                    xvalorconsorcio := LEAST(xvalorconsorcio, vapor.iimport);
                                 END IF;
                              END LOOP;
                           ELSIF pctipapo = 2 THEN
                              FOR vapor IN cur_aportaseg(psseguro, pfefecto, xnriesgo) LOOP
                                 IF vapor.ctipimp = 1 THEN
                                    xvalorconsorcio :=
                                       f_round(xvalorconsorcio *(1 -(vapor.pimport / 100)),
                                               decimals);
                                 ELSIF vapor.ctipimp = 2 THEN
                                    xvalorconsorcio :=
                                                  GREATEST(0, xvalorconsorcio - vapor.iimport);
                                 END IF;
                              END LOOP;
                           END IF;
                        END IF;

                        vpasexec := 115;
                        -- Fi Bug 12589
                        xvalorconsorcio := f_round(xvalorconsorcio, decimals);   -- JLB - I - BUG 18423 COjo la moneda del producto

                        IF NVL(xvalorconsorcio, 0) <> 0 THEN   -- Bug 12589 - FAL - 31/03/2010 -- 0012589: CEM - Recibos con copago y consorcio
                           vpasexec := 116;
                           error := f_insdetreccar(psproces, pnrecibo, 2, xvalorconsorcio,
                                                   xploccoa, xcgarant, xnriesgo, xctipcoa,
                                                   xcageven, xxnmovima, 0, 0, 1, NULL, NULL,
                                                   NULL, decimals);   -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda

                           IF error = 0 THEN
                              pgrabar := 1;
                           ELSE
                              CLOSE cur_garansegant;

                              RETURN error;
                           END IF;
                        END IF;   -- Fi Bug 12589
                     END IF;
                  END IF;
               END IF;
            END IF;

            vpasexec := 117;

            FETCH cur_garansegant
             INTO xcgarant, xnriesgo, xfiniefe, xffinefe, xcageven, xxnmovima, xicapital;
         END LOOP;

         CLOSE cur_garansegant;

         -- bug 10864.NMM.01/08/2009. S'elimina un troç de codi.
         RETURN(0);
      --JAMF 11903 - Ahora sí que se calcula consorcio en la cartera no anual si el consorcio es fraccionado
      --ELSIF ptipomovimiento = 22 THEN   -- RENOVACIONS NO ANUALS
      --   RETURN 0;   -- AQUÍ NO ES CALCULA EL CONSORCI
      ELSIF ptipomovimiento IN(21, 22) THEN   -- RENOVACIONS ANUALS --JAMF 11903 añadimos carteras no anuales
         vpasexec := 118;

         OPEN cur_garancarxrisc;

         FETCH cur_garancarxrisc
          INTO xnriesgo, xcgarant, xfiniefe, xffinefe, xcageven, xxnmovima, xicapital;

         WHILE cur_garancarxrisc%FOUND LOOP
            xnasegur1 := 0;
            xnasegur2 := 0;
            xcclarie := NULL;
            vpasexec := 119;
            xcimpcon := f_esconsorciable(xcgarant, pcramo, pcmodali, pccolect, pctipseg,
                                         pcactivi, error);

            IF error <> 0 THEN
               CLOSE cur_garancarxrisc;

               RETURN error;
            END IF;

            vpasexec := 120;

            IF xcimpcon = 1 THEN   -- LA GARANTÍA ES CONSORCIABLE
               -- bug 10864.NMM.01/08/2009. S'afegeix una variable.
               vpasexec := 121;
               error := f_concepto(2, xcempres, pfefecto,
                                   --NULL,
                                   xcforpag,   --JAMF 11903 - Puede depender de la forma de pago
                                   pcramo, pcmodali, pctipseg, pccolect, pcactivi, xcgarant,
                                   xctipcla, xivalnor, vcfracci, vcbonifi, vcrecfra, w_climit,
                                   v_cmonimp,   -- BUG 18423 - LCOL000 - Multimoneda
                                   vcderreg);   -- Bug 0020314 - FAL - 29/11/2011
               --
               vpasexec := 122;
               p_tracta_limit(w_climit, w_cduraci, w_nduraci, xcforpag, pfvencim, pfefecto,
                              xsegtemporada, xmeses, xsegtemp1, w_resultat);

               IF w_resultat = 103834 THEN
                  -- LÍMIT NO TROBAT A LA TAULA LIMITES
                  RETURN(103834);
               ELSIF w_resultat = 103514 THEN
                  -- ERROR AL LLEGIR DE LA TAULA LIMITES
                  RETURN(103514);
               END IF;

               -- bug 10864.f.
               IF error <> 0 THEN
                  CLOSE cur_garancarxrisc;

                  RETURN error;
               END IF;

               vpasexec := 123;

               -- Obtenemos la prima, para cuando consorcio sobre prima
               BEGIN
                  SELECT   NVL(SUM(iconcep), 0)
                      INTO iconcep0
                      FROM detrecibos
                     WHERE nrecibo = pnrecibo
                       AND nriesgo = xnriesgo
                       AND cgarant = xcgarant
                       AND(cconcep = 0
                           OR cconcep = 50)   -- LOCAL +  CEDIDA
                  GROUP BY nriesgo, cgarant;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     NULL;
                  WHEN OTHERS THEN
                     CLOSE cur_garansegant;

                     error := 103512;
                     -- ERROR AL LLEGIR DE DETRECIBOS
                     RETURN error;
               END;

               vpasexec := 124;

               BEGIN
                  SELECT DECODE(nasegur, NULL, 1, nasegur)
                    INTO xnasegur1
                    FROM riesgos
                   WHERE sseguro = psseguro
                     AND nriesgo = NVL(xnriesgo, 1);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     CLOSE cur_garansegant;

                     RETURN 103836;
                  -- RISC NO TROBAT A RIESGOS
                  WHEN OTHERS THEN
                     CLOSE cur_garansegant;

                     RETURN 103509;
               -- ERROR AL LLEGIR DE RIESGOS
               END;

               vpasexec := 125;
               --BUG 24656-XVM-16/11/2012.Añadir paccion
               error := pac_impuestos.f_calcula_impconcepto(xivalnor, iconcep0, iconcep0, NULL,
                                                            NULL, NULL, xicapital, NULL, NULL,
                                                            xctipcla, xcforpag, vcfracci,
                                                            vcbonifi, vcrecfra, xcons,
                                                            -- JLB - I - BUG 18423 COjo la moneda del producto
                                                            NULL, NULL, NULL, pfefecto,
                                                            psseguro, xnriesgo, xcgarant,

                                                            -- decimals, NULL, 0);   -- JLB - F - BUG 18423 COjo la moneda del producto
                                                            decimals, NULL, 0, NULL, pnmovimi);   -- BUG 34505 - FAL - 17/03/2015

               IF error <> 0 THEN
                  CLOSE cur_garansegxrisc;

                  RETURN error;
               END IF;

               vpasexec := 126;

               -- bug 10864.NMM.01/08/2009. S'elimina un troç de codi.
               IF xinnomin
                  AND xctipcla IN(2, 4) THEN
                  xvalorconsorcio := NVL(xcons, 0) * xnasegur1;
               ELSE
                  xvalorconsorcio := NVL(xcons, 0);
               END IF;

               IF xvalorconsorcio IS NOT NULL
                  AND xvalorconsorcio <> 0 THEN
                  IF xsegtemporada THEN
                     xvalorconsorcio := xvalorconsorcio * xsegtemp1;

                     IF xmeses > 12 THEN
                        vpasexec := 127;
                        -- ES HASTA EL VENCIMIENTO Y SUPERIOR AL AÑO
                        error := f_difdata(pfefecto, pfvencim, 3, 3, xresult);

                        IF error = 0 THEN
                           IF xctipcla = 2 THEN   -- ES IMPORTE FIJO
                              xvalorconsorcio := xvalorconsorcio * CEIL(xresult / 360);
                           ELSIF xctipcla = 4 THEN
                              -- ES SOBRE EL CAPITAL
                              xvalorconsorcio := xvalorconsorcio * xresult / 360;
                           ELSE
                              NULL;
                           END IF;
                        ELSE
                           RETURN error;
                        END IF;
                     END IF;
                  ELSE
                     --JAMF 11903 - No hay consorcio si no es fracionado (sólo en ptipomovimiento =0 o 21)
                     IF vcfracci = 1 THEN
                        xvalorconsorcio := xvalorconsorcio * pfacconsorfra;
                     ELSIF vcfracci = 0
                           AND ptipomovimiento = 22 THEN
                        xvalorconsorcio := 0;
                     ELSE
                        xvalorconsorcio := xvalorconsorcio * pfacconsor;
                     END IF;
                  END IF;

                  vpasexec := 128;
                  xorden := f_ordenconsorcio(2, xcgarant, pcramo, pcmodali, pccolect, pctipseg,
                                             pcactivi, psseguro, xnriesgo, pnmovimi, error);

                  IF xorden <> 0 THEN
                     xvalorconsorcio := 0;
                  END IF;

                  vpasexec := 129;

                  IF NVL(xvalorconsorcio, 0) <> 0 THEN
                     -- ******* CONSORCIO *******

                     -- Bug 12589 - FAL - 31/03/2010 -- 0012589: CEM - Recibos con copago y consorcio
                     IF xctipreb = 4 THEN
                        IF pctipapo = 1 THEN
                           FOR vapor IN cur_aportaseg(psseguro, pfefecto, xnriesgo) LOOP
                              IF vapor.ctipimp = 1 THEN
                                 xvalorconsorcio :=
                                      f_round(xvalorconsorcio * vapor.pimport / 100, decimals);
                              ELSIF vapor.ctipimp = 2 THEN
                                 xvalorconsorcio := LEAST(xvalorconsorcio, vapor.iimport);
                              END IF;
                           END LOOP;
                        ELSIF pctipapo = 2 THEN
                           FOR vapor IN cur_aportaseg(psseguro, pfefecto, xnriesgo) LOOP
                              IF vapor.ctipimp = 1 THEN
                                 xvalorconsorcio :=
                                    f_round(xvalorconsorcio *(1 -(vapor.pimport / 100)),
                                            decimals);
                              ELSIF vapor.ctipimp = 2 THEN
                                 xvalorconsorcio :=
                                                  GREATEST(0, xvalorconsorcio - vapor.iimport);
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;

                     vpasexec := 130;
                     -- Fi Bug 12589
                     xvalorconsorcio := f_round(xvalorconsorcio, decimals);   -- JLB - I - BUG 18423 COjo la moneda del producto

                     IF NVL(xvalorconsorcio, 0) <> 0 THEN   -- Bug 12589 - FAL - 31/03/2010 -- 0012589: CEM - Recibos con copago y consorcio
                        vpasexec := 131;
                        error := f_insdetreccar(psproces, pnrecibo, 2, xvalorconsorcio,
                                                xploccoa, xcgarant, xnriesgo, xctipcoa,
                                                xcageven, xxnmovima, 0, 0, 1, NULL, NULL,
                                                NULL, decimals);   -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda

                        IF error = 0 THEN
                           pgrabar := 1;
                        ELSE
                           CLOSE cur_garancarxrisc;

                           RETURN error;
                        END IF;
                     END IF;   -- Fi Bug 12589
                  END IF;
               END IF;
            END IF;

            vpasexec := 132;

            FETCH cur_garancarxrisc
             INTO xnriesgo, xcgarant, xfiniefe, xffinefe, xcageven, xxnmovima, xicapital;
         END LOOP;

         CLOSE cur_garancarxrisc;

         -- bug 10864.NMM.01/08/2009. S'elimina un troç de codi.
         RETURN(0);
      ELSE
         vpasexec := 133;
         RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
      END IF;
   ELSE
      vpasexec := 134;
      RETURN 101901;   -- PAS DE PARÀMETRES INCORRECTES A LA FUNCIÓ
   END IF;
-- BUG 21546_108724 - 08/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
EXCEPTION
   WHEN OTHERS THEN
      IF cur_garansegxrisc%ISOPEN THEN
         CLOSE cur_garansegxrisc;
      END IF;

      IF cur_garansegant%ISOPEN THEN
         CLOSE cur_garansegant;
      END IF;

      IF curgaran%ISOPEN THEN
         CLOSE curgaran;
      END IF;

      IF cur_garancarxrisc%ISOPEN THEN
         CLOSE cur_garancarxrisc;
      END IF;

      p_tab_error(f_sysdate, f_user, 'f_consorci', vpasexec, vparam, SQLERRM);
      RETURN 140999;
END f_consorci;

/

  GRANT EXECUTE ON "AXIS"."F_CONSORCI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CONSORCI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CONSORCI" TO "PROGRAMADORESCSI";
