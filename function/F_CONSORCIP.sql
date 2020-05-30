--------------------------------------------------------
--  DDL for Function F_CONSORCIP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CONSORCIP" (
/******************************************************************************
   NOMBRE:      f_consorcip
   PROPÓSITO:   Retorna el importe del impuesto de consorcio para mostralor en pantalla.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1                                       1. Creación de la función.
   2          10/06/2009   AMC             2. BUG 9733 - Se elimina una inserción en control error.
   3          01/08/2009   NMM             3. 10864: CEM - Taxa aplicable Consorci.
   4          05/01/2010   ETM             4. 0016503: CRT101 - Error en cálculo consorcio tarificación
   5.0        18/04/2011   JMF             5. 0018135 CCAT701 - Paquetes propios y Consorcio de CTV en iAXIS
   6.0        28/11/2011   JMP             6. 0018423: LCOL000 - Multimoneda
   7.0        29/11/2011   FAL             7. 0020314: GIP003 - Modificar el cálculo del Selo
   8.0        19/03/2012   JMF             8. 0021655 MDP - TEC - Cálculo del Consorcio
   9.0        06/05/2012   DRA             9. 0022279: MDP - TEC - Parametrización producto de Comercio - Nueva producción
  10.0        03/10/2012   JMF             0022787 CALI003-Incidències després del test de CA Life

******************************************************************************/
   psproces IN NUMBER,
   psseguro IN NUMBER,
   pnriesgo IN NUMBER,
   pcgarant IN NUMBER,
   pfefecto IN DATE,
   pfvencim IN DATE,
   piconcep0 IN NUMBER,
   ptipomovimiento IN NUMBER,
   pnmovimi IN NUMBER,
   pfacconsor IN NUMBER,
   paltarisc IN BOOLEAN,
   pnconsorci OUT NUMBER,
   pcapieve IN NUMBER DEFAULT NULL,
   pttabla IN VARCHAR2 DEFAULT NULL,
   pfuncion IN VARCHAR2 DEFAULT 'CAR')
   RETURN NUMBER AUTHID CURRENT_USER IS
   error          NUMBER := 0;
   --xmeses         NUMBER;
   xresult        NUMBER;
   xcclarie       NUMBER;
   xsegtemp1      NUMBER;
   xctipcla       NUMBER;
   xivalnor       NUMBER;
   xvalorconsorcio NUMBER;
   xcapitaltrobat NUMBER;
   xtotcapital    NUMBER;
   iconcep0       NUMBER;
   xcgarant       NUMBER;
   xnriesgo       NUMBER;
   xinnomin       BOOLEAN;
   xnasegur1      NUMBER;
   xnasegur2      NUMBER;
   xcobjase       NUMBER;
   xnmovima       NUMBER;
   xctipcoa       NUMBER;   -- COASEGURO
   xncuacoa       NUMBER;
   xploccoa       NUMBER;
   xiconsor       NUMBER;
   xcimpcon       NUMBER;
   xfiniefe       DATE;
   xffinefe       DATE;
   xdifdiaseve    NUMBER;
   xcforpag       NUMBER;
   xorden         NUMBER;
   vselect        VARCHAR2(2000);
   vcduraci       seguros.cduraci%TYPE;
   vnduraci       seguros.nduraci%TYPE;
   vcramo         productos.cramo%TYPE;
   vcmodali       productos.cmodali%TYPE;
   vctipseg       productos.ctipseg%TYPE;
   vccolect       productos.ccolect%TYPE;
   vcactivi       seguros.cactivi%TYPE;
   vcmodo         VARCHAR2(1) := 'P';
   vsegtemp       NUMBER := 0;
   vcfracci       NUMBER;
   vcbonifi       NUMBER;
   vcrecfra       NUMBER;
   xcempres       NUMBER;
   xcons          NUMBER;
   xicapital      NUMBER;
   --
   w_climit       NUMBER;
   v_cmonimp      imprec.cmoneda%TYPE;   -- BUG 18423 - LCOL000 - Multimoneda
   w_segtemporada BOOLEAN;
   w_resultat     NUMBER;
   -- ini Bug 0018135 - JMF - 18/04/2011
   v_sproduc      seguros.sproduc%TYPE;
   v_conspup      parproductos.cvalpar%TYPE;
   v_origenpup    NUMBER;
   v_clavepup     garanformula.clave%TYPE;
   vorigen        NUMBER;   -- JAS 05.06.07
   -- fin Bug 0018135 - JMF - 18/04/2011
   vcderreg       NUMBER;   -- Bug 0020314 - FAL - 29/11/2011
   vpasexec       NUMBER := 1;
   vparam         VARCHAR2(2000)
      := 'psproces=' || psproces || ', psseguro=' || psseguro || ', pnriesgo=' || pnriesgo
         || ', pcgarant=' || pcgarant || ', pfefecto=' || pfefecto || ', pfvencim='
         || pfvencim || ', piconcep0=' || piconcep0 || ', ptipomovimiento=' || ptipomovimiento
         || ', pnmovimi=' || pnmovimi || ', pfacconsor=' || pfacconsor || ', pnconsorci='
         || pnconsorci || ', pcapieve=' || pcapieve || ', pttabla=' || pttabla
         || ', pfuncion=' || pfuncion;

   TYPE tcursor IS REF CURSOR;

   curgaran       tcursor;
   vesregularizacion NUMBER := 0;   --JRH Regularización 03/2015
   var            NUMBER := 0;

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

   -- Si se ha contratado otra garantia con prioridad superior devolveremos '1' (para nograbar)
   -- Si no hay que hacer nada devolveremos 0.
   BEGIN
      -- Primero obtenemos el orden/prioridad de la garantia que estamos 'consorciando'
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
            AND cactivi = vcactivi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
         WHEN OTHERS THEN
            pfnerror := SQLCODE;
            RETURN(1);
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
                  NULL;
               WHEN TOO_MANY_ROWS THEN
                  retorno := 1;
               WHEN OTHERS THEN
                  pfnerror := SQLCODE;
                  RETURN(1);
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
                  NULL;
               WHEN TOO_MANY_ROWS THEN
                  retorno := 1;
               WHEN OTHERS THEN
                  pfnerror := SQLCODE;
                  RETURN(1);
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
      p_nvalor1 OUT NUMBER,
      p_resultat OUT NUMBER) IS
      --
      w_mesos        NUMBER;
-----------------------------------------------------------------------------
   BEGIN
      IF p_climit IS NOT NULL THEN
         p_segtemporada := TRUE;

         IF p_cduraci = 1 THEN
            w_mesos := p_nduraci * 12;
         ELSIF p_cduraci = 2 THEN
            w_mesos := p_nduraci;
         ELSIF p_cduraci = 3
               AND p_cforpag = 0 THEN
            w_mesos := CEIL(MONTHS_BETWEEN(p_fvencim, p_fefecto));
         END IF;

         BEGIN
            SELECT MIN(nvalor1)
              INTO p_nvalor1
              FROM limites
             WHERE climite = p_climit
               AND w_mesos >= nminimo
               AND(w_mesos <= nmaximo
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
--                    F_CONSORCIP
--------------------------------------------------------------------------------
BEGIN
   vpasexec := 2;
   vesregularizacion := 0;   --JRH  Suplemento de regularización

   -- CÀLCUL DEL CONSORCI
   IF pttabla = 'EST' THEN
      SELECT cempres, ctipcoa, ncuacoa, cforpag, cduraci, nduraci, cramo, cmodali,
             ctipseg, ccolect, cactivi, sproduc, 0 origen
        INTO xcempres, xctipcoa, xncuacoa, xcforpag, vcduraci, vnduraci, vcramo, vcmodali,
             vctipseg, vccolect, vcactivi, v_sproduc, vorigen
        FROM estseguros
       WHERE sseguro = psseguro;

      BEGIN
         SELECT 1
           INTO var
           FROM codimotmov mov, pds_estsegurosupl p
          WHERE p.sseguro = psseguro
            AND p.nmovimi = pnmovimi
            AND p.cestado = 'X'
            AND mov.cmotmov = p.cmotmov
            AND mov.cmovseg = 6;

         vesregularizacion := 1;   --JRH 03/2015 miramos si el último movimiento es de regularizacióny así lo indicamos
      EXCEPTION
         WHEN OTHERS THEN
            vesregularizacion := 0;
      END;
   ELSIF pttabla = 'SOL' THEN
      SELECT cr.cempres, s.cforpag, s.cduraci, s.nduraci, s.cramo, s.cmodali, s.ctipseg,
             s.ccolect, s.cactivi, sproduc, 1 origen
        INTO xcempres, xcforpag, vcduraci, vnduraci, vcramo, vcmodali, vctipseg,
             vccolect, vcactivi, v_sproduc, vorigen
        FROM solseguros s, codiram cr
       WHERE s.cramo = cr.cramo
         AND s.ssolicit = psseguro;
   ELSE
      SELECT cempres, ctipcoa, ncuacoa, cforpag, cduraci, nduraci, cramo, cmodali,
             ctipseg, ccolect, cactivi, sproduc, 2 origen
        INTO xcempres, xctipcoa, xncuacoa, xcforpag, vcduraci, vnduraci, vcramo, vcmodali,
             vctipseg, vccolect, vcactivi, v_sproduc, vorigen
        FROM seguros
       WHERE sseguro = psseguro;

      BEGIN
         SELECT 1
           INTO var
           FROM codimotmov mov, movseguro m
          WHERE m.sseguro = psseguro
            AND m.nmovimi = pnmovimi
            AND mov.cmotmov = m.cmotmov
            AND mov.cmovseg = 6;

         vesregularizacion := 1;   --JRH 03/2015 miramos si el último movimiento es de regularizacióny así lo indicamos
      EXCEPTION
         WHEN OTHERS THEN
            vesregularizacion := 0;
      END;
   END IF;

   vpasexec := 3;

   BEGIN
      SELECT cobjase
        INTO xcobjase
        FROM productos
       WHERE cramo = vcramo
         AND cmodali = vcmodali
         AND ctipseg = vctipseg
         AND ccolect = vccolect;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN(104347);   -- PRODUCTE NO TROBAT A PRODUCTOS
      WHEN OTHERS THEN
         RETURN(102705);   -- ERROR AL LLEGIR DE PRODUCTOS
   END;

   vpasexec := 4;

   IF xcobjase = 4 THEN   -- PRODUCTE INNOMINAT
      xinnomin := TRUE;
   ELSE
      xinnomin := FALSE;
   END IF;

   vpasexec := 5;
   -- Bug 0018135 - JMF - 18/04/2011
   v_conspup := NVL(pac_parametros.f_parproducto_n(v_sproduc, 'CONSORCI_PUP'), 0);
   vpasexec := 6;

   -- BUSCAMOS EL PORCENTAJE LOCAL SI ES UN COASEGURO.
   IF xctipcoa <> 0 THEN
      SELECT ploccoa
        INTO xploccoa
        FROM coacuadro
       WHERE ncuacoa = xncuacoa
         AND sseguro = psseguro;
   END IF;

   -- bug 10864.NMM.01/08/2009. S'elimina un troç de codi.
   vpasexec := 7;

   -- BUG 9733-10/06/09-AMC- Se elimina una inserción en control error.
   IF ptipomovimiento IN(0, 6) THEN
      IF pfuncion = 'CAR' THEN
         vselect := 'SELECT nriesgo, cgarant, finiefe, ffinefe, icapital' || ' FROM garanseg'
                    || ' WHERE sseguro = ' || psseguro || '  AND ffinefe IS NULL';   -- BUG 9371 - 30/03/2009 - LPS - Datos consorcio (no por nmovimi)

         IF pnriesgo IS NOT NULL THEN
            vselect := vselect || ' AND nriesgo = ' || pnriesgo;
         END IF;

         IF pcgarant IS NOT NULL THEN
            vselect := vselect || ' AND cgarant = ' || pcgarant;
         END IF;
      ELSIF pfuncion = 'TAR' THEN
         vselect :=
            'SELECT nriesgo, cgarant, finiefe, ffinefe, icapital' || ' FROM estgaranseg'
            || ' WHERE sseguro = ' || psseguro || ' AND cgarant = '
            || pcgarant   --bug 16503 - 05/11/2010--ETM --0016503: CRT101 - Error en cálculo consorcio tarificación
            || ' AND ffinefe IS NULL';   -- BUG 9371 - 30/03/2009 - LPS - Datos consorcio (no por nmovimi)

         IF pnriesgo IS NOT NULL THEN
            vselect := vselect || ' AND nriesgo = ' || pnriesgo;
         END IF;
      END IF;

      vpasexec := 8;

      OPEN curgaran FOR vselect;

      FETCH curgaran
       INTO xnriesgo, xcgarant, xfiniefe, xffinefe, xicapital;

      vpasexec := 9;

      WHILE curgaran%FOUND LOOP
         xnasegur1 := 0;
         xnasegur2 := 0;
         xcclarie := NULL;
         vpasexec := 10;
         xcimpcon := f_esconsorciable(xcgarant, vcramo, vcmodali, vccolect, vctipseg,
                                      vcactivi, error);
         vpasexec := 11;

         IF error <> 0 THEN
            CLOSE curgaran;

            RETURN error;
         END IF;

         vpasexec := 12;

         IF xcimpcon = 1 THEN   -- LA GARANTÍA ES CONSORCIABLE
            -- bug 10864.NMM.01/08/2009. S'afegeix una variable.i.
            error := f_concepto(2, xcempres, pfefecto,
                                --NULL,
                                xcforpag,   --JAMF 11903 - Puede depender de la forma de pago
                                vcramo, vcmodali, vctipseg, vccolect, vcactivi, xcgarant,
                                xctipcla, xivalnor, vcfracci, vcbonifi, vcrecfra, w_climit,
                                v_cmonimp,   -- BUG 18423: LCOL000 - Multimoneda
                                vcderreg);   -- Bug 0020314 - FAL - 29/11/2011
            --
            vpasexec := 13;
            p_tracta_limit(w_climit, vcduraci, vnduraci, xcforpag, pfvencim, pfefecto,
                           w_segtemporada, xsegtemp1, w_resultat);
            vpasexec := 14;

            IF w_resultat = 103834 THEN
               -- LÍMIT NO TROBAT A LA TAULA LIMITES
               RETURN(103834);
            ELSIF w_resultat = 103514 THEN
               -- ERROR AL LLEGIR DE LA TAULA LIMITES
               RETURN(103514);
            END IF;

            vpasexec := 15;

            -- bug 10864.f.
            -- BUG 9371 - 30/03/2009 - LPS - Prueba consorcio
            IF error <> 0 THEN   -- Si da error la función.
               xcons := 0;
            ELSE
               vpasexec := 16;

               -- ini Bug 0018135 - JMF - 18/04/2011
               IF v_conspup = 1
                  AND xctipcla = 1 THEN
                  BEGIN
                     SELECT clave
                       INTO v_clavepup
                       FROM garanformula
                      WHERE cramo = vcramo
                        AND cmodali = vcmodali
                        AND ctipseg = vctipseg
                        AND ccolect = vccolect
                        AND cactivi = vcactivi
                        AND cgarant = xcgarant
                        AND ccampo = 'ICONPUP';
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'f_consorcip', 1,
                                    'Error al llegir de GARANFORMULA', SQLERRM);
                        error := 110087;
                        -- Error al insertar en GARANFORMULA
                        RETURN(error);
                  END;

                  vpasexec := 17;
                  error := pac_calculo_formulas.calc_formul(pfefecto, v_sproduc, vcactivi,
                                                            xcgarant, xnriesgo, psseguro,
                                                            v_clavepup, xcons,   -- CONSORCI (PUP)
                                                            NULL, NULL, vorigen, xfiniefe,
                                                            NULL);

                  IF error <> 0 THEN   -- Si da error la función.
                     xcons := 0;
                  END IF;

                  vpasexec := 18;
               ELSIF vesregularizacion = 1 THEN   --JRH El consorcio en regularización tendrá un nuevo campo como la prima (lo separamos para que se vea claro)
                  BEGIN
                     SELECT clave
                       INTO v_clavepup
                       FROM garanformula
                      WHERE cramo = vcramo
                        AND cmodali = vcmodali
                        AND ctipseg = vctipseg
                        AND ccolect = vccolect
                        AND cactivi = vcactivi
                        AND cgarant = xcgarant
                        AND ccampo = 'CONREGUL';
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        BEGIN
                           SELECT clave
                             INTO v_clavepup
                             FROM garanformula
                            WHERE cramo = vcramo
                              AND cmodali = vcmodali
                              AND ctipseg = vctipseg
                              AND ccolect = vccolect
                              AND cactivi = 0
                              AND cgarant = xcgarant
                              AND ccampo = 'CONREGUL';
                        EXCEPTION
                           WHEN OTHERS THEN
                              p_tab_error(f_sysdate, f_user, 'f_consorcip', 1,
                                          'Error al llegir de GARANFORMULA', SQLERRM);
                              error := 110087;
                              -- Error al insertar en GARANFORMULA
                              RETURN(error);
                        END;
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'f_consorcip', 1,
                                    'Error al llegir de GARANFORMULA', SQLERRM);
                        error := 110087;
                        -- Error al insertar en GARANFORMULA
                        RETURN(error);
                  END;

                  vpasexec := 17;
                  error :=
                     pac_calculo_formulas.calc_formul
                                   (pfefecto, v_sproduc, vcactivi, xcgarant, xnriesgo,
                                    psseguro, v_clavepup, xcons,   -- CONSORCI (PUP)
                                    pnmovimi, NULL, vorigen, xfiniefe,   -- BUG 34505 - FAL - 20/03/2015 - informar nmovimi
                                    NULL);

                  IF error <> 0 THEN   -- Si da error la función.
                     xcons := 0;
                  END IF;

                  vpasexec := 18;
               ELSE
                  vpasexec := 19;
                  -- JLB - I - BUG 18423 COjo la moneda del producto
                  -- Bug 0021655 - 19/03/2012 - JMF
                  error :=
                     pac_impuestos.f_calcula_impconcepto
                                   (xivalnor,   -- pnvalcon
                                    piconcep0,   -- piconcep0
                                    piconcep0,   -- piconcep21
                                    NULL,   -- pidto
                                    NULL,   -- pidto21
                                    NULL,   -- pidtocam
                                    xicapital,   -- picapital
                                    NULL,   -- ptotrecfracc
                                    NULL,   -- pprecfra
                                    xctipcla,   -- pctipcon
                                    xcforpag,   -- pcforpag
                                    vcfracci,   -- pcfracci
                                    vcbonifi,   -- pcbonifi
                                    vcrecfra,   -- pcrecfra
                                    xcons,   -- oiconcep
                                    NULL,   -- pgastos
                                    NULL,   -- pcderreg
                                    NULL,   -- piconcep0neto
                                    pfefecto,   -- pfefecto
                                    psseguro,   -- psseguro
                                    xnriesgo,   -- pnriesgo
                                    xcgarant,   -- pcgarant
                                    pac_monedas.f_moneda_producto(v_sproduc), pttabla,   -- pttabla
                                    0, NULL,
                                    pnmovimi   -- BUG 34505 - FAL - 20/03/2015 - informar nmovimi
                                            );

                  -- BUG 9371 - 30/03/2009 - LPS - Prueba consorcio
                  IF error <> 0 THEN   -- Si da error la función.
                     xcons := 0;
                  END IF;

                  vpasexec := 20;
                  xcons := NVL(xcons, 0);
               END IF;
            END IF;

            vpasexec := 21;

            IF xctipcla IS NOT NULL THEN
               vpasexec := 22;

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

               vpasexec := 23;

               IF xinnomin THEN
                  xvalorconsorcio := xcons * xnasegur1;
               ELSE
                  xvalorconsorcio := xcons;
               END IF;

               vpasexec := 24;

               -- BUG 9371 - 30/03/2009 - LPS - Prueba consorcio
               IF xvalorconsorcio IS NOT NULL
                  AND xvalorconsorcio <> 0 THEN
                  vpasexec := 25;

                  IF w_segtemporada THEN
                     xvalorconsorcio := xvalorconsorcio * xsegtemp1;
                  -- bug 10864.NMM.01/08/2009. S'elimina un troç de codi.
                  ELSE
                     IF vesregularizacion <> 1 THEN
                        xvalorconsorcio := xvalorconsorcio * pfacconsor;
                     END IF;
                  END IF;

                  vpasexec := 26;

                  -- BUG 9371 - 30/03/2009 - LPS - Prueba consorcio
                  IF pcapieve = 1 THEN   -- APLIQUEM EL TEMPS EN CAPITAL EVENTUAL
                     error := f_difdata(xfiniefe, xffinefe, 3, 3, xdifdiaseve);

                     IF error = 0 THEN
                        xvalorconsorcio := xvalorconsorcio * xdifdiaseve / 360;
                     ELSE
                        RETURN error;
                     END IF;
                  END IF;

                  vpasexec := 27;
                  -- BUG 9371 - 30/03/2009 - LPS - Prueba consorcio
                  xorden := f_ordenconsorcio(1, xcgarant, vcramo, vcmodali, vccolect, vctipseg,
                                             vcactivi, psseguro, xnriesgo, pnmovimi, error);

                  IF xorden <> 0 THEN
                     xvalorconsorcio := 0;
                  END IF;

                  vpasexec := 28;

                  IF NVL(xvalorconsorcio, 0) <> 0 THEN
                     -- ini BUG 0022787 - 03/10/12 - JMF
                     --pnconsorci := f_round(xvalorconsorcio);
                     pnconsorci := f_round(xvalorconsorcio,
                                           pac_monedas.f_moneda_producto(v_sproduc));

                     -- fin BUG 0022787 - 03/10/12 - JMF
                     IF error <> 0 THEN
                        vpasexec := 29;

                        CLOSE curgaran;

                        RETURN error;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;

         vpasexec := 30;

         -- BUG 9371 - 30/03/2009 - LPS - Prueba consorcio
         FETCH curgaran
          INTO xnriesgo, xcgarant, xfiniefe, xffinefe, xicapital;
      END LOOP;

      CLOSE curgaran;

      vpasexec := 31;
      RETURN(0);
   ELSE
      RETURN(500064);   -- PAS DE PARÀMETRES INCORRECTE A LA FUNCIÓ
   END IF;
-- BUG 21546_108724 - 07/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
EXCEPTION
   WHEN OTHERS THEN
      IF curgaran%ISOPEN THEN
         CLOSE curgaran;
      END IF;

      p_tab_error(f_sysdate, f_user, 'f_consorcip', vpasexec, vparam, SQLERRM);
      RETURN 140999;
END f_consorcip;

/

  GRANT EXECUTE ON "AXIS"."F_CONSORCIP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CONSORCIP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CONSORCIP" TO "PROGRAMADORESCSI";
