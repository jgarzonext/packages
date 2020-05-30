--------------------------------------------------------
--  DDL for Package Body PAC_CARTERA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CARTERA" IS
/******************************************************************************
   NOMBRE:      PAC_DINCARTERA
   PROPÓSITO:
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
                                           1. Creación del package.
   2.0        23/04/2011     MDS           2. 0021907: MDP - TEC - Descuentos y recargos (técnico y comercial) a nivel de póliza/riesgo/garantía
******************************************************************************/
   PROCEDURE garantia_regularitzacio(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcprimin OUT NUMBER,
      piprimin OUT NUMBER,
      pcclapri OUT NUMBER,
      pcgarant_regu OUT NUMBER,
      pnorden OUT NUMBER) IS
------------------------------------------------------------------------------------
-- Atenció!!!!! , Mirem sempre les garanties de l'activitat 0, per que considerem que
-- la prima mínima és per producte
------------------------------------------------------------------------------------
      CURSOR c_gar IS
         SELECT *
           FROM garanpro
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect
            AND cactivi = 0;

      num_err        NUMBER;
      lcvalpar       NUMBER;
   BEGIN
      pcgarant_regu := NULL;
      pnorden := NULL;
      pcprimin := NULL;
      piprimin := NULL;
      pcclapri := NULL;

      BEGIN
         SELECT cprimin, iprimin, cclapri
           INTO pcprimin, piprimin, pcclapri
           FROM productos
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF pcprimin IS NOT NULL THEN
         FOR v_gar IN c_gar LOOP
            num_err := f_pargaranpro(pcramo, pcmodali, pctipseg, pccolect, 0, v_gar.cgarant,
                                     'TIPO', lcvalpar);

            IF NVL(lcvalpar, 0) = 3 THEN
               pcgarant_regu := v_gar.cgarant;
               pnorden := v_gar.norden;
            END IF;
         END LOOP;
      END IF;
   END garantia_regularitzacio;

   PROCEDURE media_edad(psseguro IN NUMBER, edad_media OUT NUMBER) IS
      -- Bug 0012802 - 20/01/2010 - JMF
      CURSOR c_media_edad IS
         SELECT r.sperson, p.fnacimi
           FROM per_personas p, riesgos r
          WHERE sseguro = psseguro
            AND r.fanulac IS NULL
            AND r.sperson = p.sperson;

      psperson       NUMBER;
      pfnacimi       DATE;
      i              NUMBER;
      edad_total     NUMBER;
      num_err        NUMBER;
      edad           NUMBER;
   BEGIN
      i := 0;
      edad_total := 0;

      OPEN c_media_edad;

      LOOP
         FETCH c_media_edad
          INTO psperson, pfnacimi;

         EXIT WHEN c_media_edad%NOTFOUND;
         i := i + 1;
         num_err := f_difdata(pfnacimi, f_sysdate, 2, 1, edad);
         edad_total := edad_total + edad;
      END LOOP;

      CLOSE c_media_edad;

      edad_media := edad_total / i;
   END;

   PROCEDURE continente_contenido(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      cont IN NUMBER,
      parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb) IS
-- Declaración de variables
      cte            NUMBER := 0;
      cdo            NUMBER := 0;
      cte2           NUMBER := 0;
      cdo2           NUMBER := 0;
      cap_cte        NUMBER := 0;
      cap_cdo        NUMBER := 0;
   BEGIN
      -- Inserción de parámetros de Continente/Contenido
      FOR i IN parms_transitorios.FIRST .. parms_transitorios.LAST LOOP
         BEGIN
            SELECT DECODE(cvalpar, 1, 1, 0), DECODE(cvalpar, 2, 1, 0)
              INTO cte, cdo
              FROM pargaranpro
             WHERE cgarant = parms_transitorios(i).cgarant
               AND cramo = pcramo
               AND cmodali = pcmodali
               AND ctipseg = pctipseg
               AND ccolect = pccolect
               AND cactivi = pcactivi
               AND cpargar = 'TIPO';

            cte2 := cte2 + cte;   -- Tiene alguna garantía de continente.
            cdo2 := cdo2 + cdo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT DECODE(cvalpar, 1, 1, 0), DECODE(cvalpar, 2, 1, 0)
                    INTO cte, cdo
                    FROM pargaranpro
                   WHERE cgarant = parms_transitorios(i).cgarant
                     AND cramo = pcramo
                     AND cmodali = pcmodali
                     AND ctipseg = pctipseg
                     AND ccolect = pccolect
                     AND cactivi = 0
                     AND cpargar = 'TIPO';

                  cte2 := cte2 + cte;
                  cdo2 := cdo2 + cdo;
               EXCEPTION
                  WHEN OTHERS THEN
                     cte := 0;
                     cdo := 0;
               END;
            WHEN OTHERS THEN
               cte := 0;
               cdo := 0;
         END;

         IF cte = 1 THEN
            cap_cte := cap_cte + parms_transitorios(i).icapital;
         ELSIF cdo = 1 THEN
            cap_cdo := cap_cdo + parms_transitorios(i).icapital;
         END IF;
      END LOOP;

      parms_transitorios(cont).contnte := cap_cte;
      parms_transitorios(cont).conttdo := cap_cdo;
   END;

   PROCEDURE prima_max_min(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      prima IN OUT NUMBER) IS
-- Declaración de variables
      ultim_rec      NUMBER;
      cur_rec        NUMBER;
      prim_max       garanpro.iprimax%TYPE;   --       prim_max       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      prim_min       garanpro.iprimin%TYPE;   --       prim_min       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      BEGIN
         SELECT iprimax, iprimin
           INTO prim_max, prim_min
           FROM garanpro
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect
            AND cactivi = pcactivi
            AND cgarant = pcgarant;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT iprimax, iprimin
              INTO prim_max, prim_min
              FROM garanpro
             WHERE cramo = pcramo
               AND cmodali = pcmodali
               AND ctipseg = pctipseg
               AND ccolect = pccolect
               AND cactivi = 0
               AND cgarant = pcgarant;
         WHEN OTHERS THEN
            prim_max := NULL;
            prim_min := NULL;
      END;

      IF prima < NVL(prim_min, 0) THEN
         prima := prim_min;
      END IF;

      IF (prim_max IS NOT NULL
          AND prima > prim_max) THEN
         prima := prim_max;
      END IF;
   END;

   FUNCTION f_garantarifa_sgt(
      pmodo IN VARCHAR2,
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pcobjase IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pctipo IN NUMBER,
      pnduraci IN NUMBER,
      conta_proces IN NUMBER,
      pcdurcob IN NUMBER,
      pfcarpro IN DATE,
      pmes IN VARCHAR2,
      panyo IN NUMBER,
      tipo IN NUMBER,
      pcagrpro IN NUMBER,
      pcmanual IN NUMBER,
      pcactivi IN NUMBER,
      num_risc IN NUMBER,
      pfemisio IN DATE,
      movimiento OUT NUMBER,
      anulado OUT NUMBER,
      pmoneda IN NUMBER,
      parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb,
      pbonifica IN NUMBER,
      paplica_bonifica IN NUMBER,
      psproduc IN NUMBER,
      pcforpag IN NUMBER,
      pidioma IN NUMBER,
      pcgarant_regu IN NUMBER,
      pnorden IN NUMBER,
      pcprimin IN NUMBER,
      piprimin IN NUMBER,
      pcclapri IN NUMBER,
      pnedamar IN NUMBER,
      pciedmar IN NUMBER)
      RETURN NUMBER IS
/***********************************************************************************************
        F_GARANTARIFA_SGT: 1.- Revaloriza el seguro
                     2.- Tarifica
                     3.- Grabamos en GARANCAR
************************************************************************************************/
      num_err        NUMBER := 0;
      prevcap        NUMBER;
      piprima        NUMBER;
      cont           NUMBER := 0;
      texto          VARCHAR2(80);
      registros      NUMBER;
      estat_garan    VARCHAR2(20);
      tecnico        garanpro.ctecnic%TYPE;   --       tecnico        NUMBER;   -- Si hay descuento tecnico --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      porcen         coacuadro.ploccoa%TYPE;   --       porcen         NUMBER;   -- Porcentaje del coaseguro --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      old_riesgo     NUMBER := 0;
      total_prima    NUMBER;
      wsperson       NUMBER;
      wedad          NUMBER;
      wcsexper       per_personas.csexper%TYPE;   --       wcsexper       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      wfnacimi       per_personas.fnacimi%TYPE;   --       wfnacimi       DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      mensa          VARCHAR2(100);
      lprima_bonif   NUMBER;
      laplica_actual NUMBER;
      lcanvia_tarifa NUMBER;
      nfactor        NUMBER;
      -- Ini Bug 21907 - MDS - 03/05/2012
      pidtotec       garancar.idtotec%TYPE := 0;   --       pidtotec       NUMBER := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pireccom       garancar.ireccom%TYPE := 0;   --       pireccom       NUMBER := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---

      -- Fin Bug 21907 - MDS - 03/05/2012
      CURSOR cur_risc IS
         SELECT DISTINCT sseguro, nriesgo
                    FROM garanseg
                   WHERE sseguro = psseguro
                     AND ffinefe IS NULL;

      CURSOR c_garanseg_risc(wnriesgo IN NUMBER) IS
         SELECT   sseguro, cgarant, nriesgo, nmovimi, finiefe, norden, ctarifa,
                  icaptot icapital, precarg, ipritot iprianu, ffinefe, cformul, iextrap,
                  ctipfra, ifranqu, irecarg, idtocom, pdtocom, ipritar, crevali, prevali,
                  irevali, itarifa, itarrea, ftarifa, crevalcar
             FROM garanseg
            WHERE sseguro = psseguro
              AND nriesgo = wnriesgo
              AND ffinefe IS NULL
         ORDER BY nriesgo;

      CURSOR c_garancar IS
         SELECT   sseguro, cgarant, nriesgo, finiefe, norden, ctarifa, icapital, precarg,
                  iprianu, ffinefe, cformul, iextrap, sproces, ctipfra, ifranqu, irecarg,
                  ipritar, idtocom, pdtocom, crevali, prevali, irevali, itarifa, itarrea,
                  ftarifa,
                          -- Ini Bug 21907 - MDS - 03/05/2012
                          pdtotec, preccom, idtotec, ireccom
             -- FIN Bug 21907 - MDS - 03/05/2012
         FROM     garancar
            WHERE sseguro = psseguro
              AND sproces = conta_proces
         ORDER BY nriesgo;

      CURSOR cur_preguntas(psseguro IN NUMBER, priesgo IN NUMBER) IS
         SELECT crespue, cpregun
           FROM pregunseg
          WHERE sseguro = psseguro
            AND nriesgo = priesgo
            AND nmovimi IN(SELECT MAX(nmovimi)
                             FROM pregunseg
                            WHERE sseguro = psseguro
                              AND nriesgo = priesgo);

      ppsproces      garancar.ipritar%TYPE := conta_proces;   --       ppsproces      NUMBER := conta_proces; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      piprianu       garancar.cformul%TYPE := 0;   --       piprianu       NUMBER := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pipritar       garancar.idtocom%TYPE := 0;   --       pipritar       NUMBER := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pirecarg       garancar.irecarg%TYPE := 0;   --       pirecarg       NUMBER := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pidtocom       garancar.prevali%TYPE := 0;   --       pidtocom       NUMBER := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      prima          seguros.iprianu%TYPE := 0;   --       prima          NUMBER := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      prevprima      NUMBER;
      pnnumlin       NUMBER;
      garantia       garanseg.cgarant%TYPE;   --       garantia       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      wprima         NUMBER;
      -- I - JLB - OPTIMIZACION
      --psesion        sgt_parms_transitorios.sesion%TYPE;   --       psesion        NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      psesion        BINARY_INTEGER;
      -- F - JLB - OPTIMIZACION
      tasa           garancar.ipritot%TYPE := 0;   --       tasa           NUMBER := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      lnmovimi       NUMBER;
      lcte           NUMBER := 0;
      lcdo           NUMBER := 0;
      lprima_minima  NUMBER;
      formula        sgt_formulas.formula%TYPE;   --       formula        VARCHAR2(2000); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      lprima_regu    garancar.iprianu%TYPE;   --       lprima_regu    NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      lcvalpar       NUMBER;
      laplicaprmin   NUMBER;
      lfactor        NUMBER;
      v_extraprima   NUMBER;   -- BUG19532:DRA:26/09/2011
      v_tregconcep   pac_parm_tarifas.tregconcep_tabtyp;   -- Bug 21121 - APD - 23/02/2012
   BEGIN
      parms_transitorios.DELETE;   -- Inicializo la matriz de parms_transitorios

      -- Seleccionamos el número de sesión del proceso.
      SELECT sgt_sesiones.NEXTVAL
        INTO psesion
        FROM DUAL;

      BEGIN
           -- jlb - I - Optimización
         --  INSERT INTO sgt_parms_transitorios
          --             (sesion, parametro, valor)
          --      VALUES (psesion, 'SESION', psesion);
         num_err := pac_sgt.put(psesion, 'SESION', psesion);

         IF num_err <> 0 THEN
            RETURN 108438;
         END IF;
      -- jlb - F - Optimización
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 108438;
      END;

      -- Cal veure si el producte aplica canvi de tarifa al renovar
      num_err := f_parproductos(psproduc, 'NOVATARIFA', lcanvia_tarifa);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Cal veure si per aquesta pòlissa en concret existeix l'excepció de no
      -- aplicar la prima mínima (Valor fixe 820, concepte = 1), etc.
      num_err := f_excepcionsegu(psseguro, 1, laplicaprmin);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

-------------------
-- Cursor de riscos
-------------------
      FOR v_risc IN cur_risc LOOP
         -- Inicialitzar parms
         parms_transitorios.DELETE;
         --
         -- i - jlb -  optimización
         --DELETE FROM sgt_parms_transitorios
          --     WHERE sesion = psesion
           --      AND parametro <> 'SESION';
         num_err := pac_sgt.del(psesion);

         IF num_err <> 0 THEN
            RETURN 108438;
         END IF;

         num_err := pac_sgt.put(psesion, 'SESION', psesion);

         IF num_err <> 0 THEN
            RETURN 108424;
         END IF;

              -- F - jlb -  optimización
-------------------
-- Preguntes del risc
-------------------
         FOR reg_preg IN cur_preguntas(v_risc.sseguro, v_risc.nriesgo) LOOP
            BEGIN
                  -- I - jlb -  optimización
               --   INSERT INTO sgt_parms_transitorios
               --               (sesion, parametro, valor)
               --        VALUES (psesion, 'RESP' || reg_preg.cpregun, reg_preg.crespue);
               num_err := pac_sgt.put(psesion, 'RESP' || reg_preg.cpregun, reg_preg.crespue);

               IF num_err <> 0 THEN
                  RETURN 108424;
               END IF;
            -- F - jlb -  optimización
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 108424;
            END;
         END LOOP;

-------------------------------------------------------------------------
-- 1er bucle de garanties:
-- Inicialitzem cgarant, nriesgo ,capital i prima revaloritzats
-- Es comprova l'anul.lació per edat
-------------------------------------------------------------------------
         cont := 0;

         FOR v_gar IN c_garanseg_risc(v_risc.nriesgo) LOOP
            cont := cont + 1;
            piprianu := 0;
            pipritar := 0;
            prevcap := 0;
            prevprima := 0;
            parms_transitorios(cont).cgarant := v_gar.cgarant;
            parms_transitorios(cont).nriesgo := v_risc.nriesgo;
            -- Miramos si se tiene que anular la garantía por la edad.
            -- Si fuera así en la función anuledad ya se anula
            num_err := f_anuledad(psseguro, v_gar.nriesgo, v_gar.cgarant, v_gar.nmovimi,
                                  v_gar.finiefe, pfcarpro, pcramo, pcmodali, pctipseg,
                                  pccolect, pcobjase, pmodo, pnedamar, pciedmar, estat_garan);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            IF estat_garan = 'NO_CAMBIADA' THEN   -- si la garantía no se anula por la edad
               -- En los productos de ahorro solo se revaloriza la prima periodica(cgarant=48).
               -- Además, si la forma de pago es única no se revaloriza

               -- Tres tipos de pólizas al tarifar(ctarman<-->pcmanual):
               -- 1) ctarman = 1,3 (manuales). Revalorizan capital y prima. Se les aplican
               --    descuentos y recargos no técnicos y descuentos por volumen.
               -- 2) ctarman = 2. Revalorizan capital y prima. Sobre la prima tarifa se
               --    aplican descuentos y recargos técnicos,desc. por volumen y descuentos
               --    y recargos no técnicos. Es decir, como ctarman =1,3 pero aplicando
               --    además descuentos y recargos técnicos.
               -- 3) ctarman = 0. Sólo revaloriza el capital y vuelve a tarifar con las
               --    nuevas tasas.
               IF pcforpag <> 0 THEN
                  -- Si el camp crevalcar de garanseg te un 0, no es revaloritzará
                  -- la garantia, perquè ha tingut un suplement de canvi de capitals
                  -- amb data de renovació.
                  IF NVL(v_gar.crevalcar, 1) = 1 THEN
                     -- Se tiene que pasar IPRITAR, pero como ahora
                     -- hay algunas pólizas con el ipritar = 0, ponemos el iprianu.
                     IF v_gar.ipritar = 0 THEN
                        wprima := v_gar.iprianu;
                     ELSE
                        wprima := v_gar.ipritar;
                     END IF;

                     --Llamamos la rutina f_revalgar-----------
                     --message('antes de f_revalgar:'||reg.cgarant||'/'||reg.icapital||'/'||wprima);
                     num_err := f_revalgar(psseguro, pcmanual, v_gar.cgarant, pcactivi, pcramo,
                                           pcmodali, pctipseg, pccolect, v_gar.icapital,
                                           wprima, v_gar.crevali, v_gar.irevali, v_gar.prevali,
                                           TO_NUMBER(pmes), panyo, prevcap, prevprima, lfactor);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  ELSE
                     prevcap := v_gar.icapital;
                  END IF;
               ELSE
                  prevcap := v_gar.icapital;
               END IF;   -- De si revaloriza o no

               IF pcmanual IN(1, 2, 3) THEN   -- Manual
                  piprianu := prevprima;
                  pipritar := prevprima;
               END IF;

               parms_transitorios(cont).icapital := NVL(prevcap, v_gar.icapital);
               parms_transitorios(cont).iprianu := piprianu;
               parms_transitorios(cont).ipritar := pipritar;
            ELSE   -- CAMBIADA
               -- La garantia s'anul.la per edat, la treiem per no tarifar-la
               parms_transitorios(cont).cgarant := NULL;
            END IF;
         END LOOP;

-------------------------------------------------------------------------
-- Cte_cdo. per risc
-------------------------------------------------------------------------
         pac_cartera.continente_contenido(pcramo, pcmodali, pctipseg, pccolect, pcactivi, cont,
                                          parms_transitorios);
         lcte := parms_transitorios(cont).contnte;
         lcdo := parms_transitorios(cont).conttdo;

-------------------------------------------------------------------------
-- Edad
-------------------------------------------------------------------------
         IF pcobjase = 1 THEN
            BEGIN
               SELECT sperson
                 INTO wsperson
                 FROM riesgos
                WHERE sseguro = v_risc.sseguro
                  AND nriesgo = num_risc;
            EXCEPTION
               WHEN OTHERS THEN
                  num_err := 103509;
                  RETURN 103509;
            END;

            BEGIN
               -- Bug 0012802 - 20/01/2010 - JMF
               SELECT fnacimi, csexper
                 INTO wfnacimi, wcsexper
                 FROM per_personas
                WHERE sperson = wsperson;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 104389;
            END;

            wedad := TRUNC(MONTHS_BETWEEN(pfcarpro,(ADD_MONTHS(wfnacimi, -6) + 1)) / 12);
         END IF;

-------------------------------------------------------------------------
-- 2on cursor de garanties : Tarificació
-------------------------------------------------------------------------
         cont := 0;

         FOR v_gar IN c_garanseg_risc(v_risc.nriesgo) LOOP
            cont := cont + 1;

            -- Mirem si hem eliminat la garantia per l'edat
            IF parms_transitorios(cont).cgarant IS NOT NULL THEN
               prevcap := parms_transitorios(cont).icapital;
               num_err := pac_parm_tarifas.insertar_parametros_riesgo(psesion, v_risc.sseguro,
                                                                      wsperson, pcramo,
                                                                      pcmodali, pctipseg,
                                                                      pccolect, pcactivi,
                                                                      wedad, wcsexper, NULL,
                                                                      cont, 'SEG',
                                                                      parms_transitorios);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               parms_transitorios(cont).contnte := lcte;
               parms_transitorios(cont).conttdo := lcdo;

               -- Si cal aplicar la nova tarifa canviem la data f_tarifa
               IF NVL(lcanvia_tarifa, 0) = 1 THEN
                  v_gar.ftarifa := pfcarpro;
               END IF;

               -- Modifiquem la bonificacio
               IF paplica_bonifica = 1 THEN
                  -- La bonificació la posem al descompte.
                  v_gar.pdtocom := pbonifica;
               END IF;

--
               IF pcmanual IN(1, 3) THEN   -- Manual
                  piprianu := parms_transitorios(cont).iprianu;
                  pipritar := parms_transitorios(cont).ipritar;
               ELSE   -- Revaloritza prima
                  IF pcmanual = 2 THEN
                     pipritar := parms_transitorios(cont).ipritar;
                  ELSE
                               -- TArifica
                               -- Inserto el parámetro de la fecha tarifa
                     -- JLB - I - Optimización
                             --  DELETE FROM sgt_parms_transitorios
                              --       WHERE sesion = psesion
                               --        AND parametro = 'FECEFE';

                     --    BEGIN
                            -- JLB - I - Optimización
                           -- INSERT INTO sgt_parms_transitorios
                           --             (sesion, parametro,
                           --              valor)
                           --      VALUES (psesion, 'FECEFE',
                            --             TO_NUMBER(TO_CHAR(NVL(v_gar.ftarifa, pfcarpro),
                            --                               'yyyymmdd')));
                     num_err := pac_sgt.put(psesion, 'FECEFE',
                                            TO_NUMBER(TO_CHAR(NVL(v_gar.ftarifa, pfcarpro),
                                                              'yyyymmdd')));

                     IF num_err <> 0 THEN
                        RETURN 108797;
                     END IF;

                         -- JLB - F - Optimización
                     --    EXCEPTION
                     --       WHEN OTHERS THEN
                     --          RETURN 108797;
                     --    END;

                     -- JLB - I - Optimización
                     /*
                     BEGIN
                         INSERT INTO sgt_parms_transitorios
                                     (sesion, parametro,
                                      valor)
                              VALUES (psesion, 'FCARPRO',
                                      TO_NUMBER(TO_CHAR(pfcarpro, 'yyyymmdd')));
                      EXCEPTION
                         WHEN DUP_VAL_ON_INDEX THEN
                            UPDATE sgt_parms_transitorios
                               SET valor = TO_NUMBER(TO_CHAR(pfcarpro, 'yyyymmdd'))
                             WHERE sesion = psesion
                               AND parametro = 'FCARPRO';
                         WHEN OTHERS THEN
                            RETURN 108797;
                      END;
                     */
                     num_err := pac_sgt.put(psesion, 'FCARPRO',
                                            TO_NUMBER(TO_CHAR(pfcarpro, 'yyyymmdd')));

                     IF num_err <> 0 THEN
                        RETURN 108797;
                     END IF;

                     -- Calculamos los recargos y descuentos técnicos.
                     num_err := f_tarifar_sgt(pmoneda, psesion, pcmanual, psseguro,
                                              v_gar.cgarant, cont, pcramo, pcmodali, pctipseg,
                                              pccolect, v_gar.nriesgo, prevcap, tasa, pipritar,
                                              piprianu, pcactivi, num_risc, mensa,
                                              parms_transitorios);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;
               END IF;

               BEGIN
                  INSERT INTO garancar
                              (sseguro, cgarant, nriesgo, finiefe,
                               norden, ctarifa,
                               icapital,
                               precarg, iprianu, ffinefe, cformul, iextrap,
                               ctipfra, ifranqu, sproces, irecarg,
                               ipritar, pdtocom, idtocom, crevali,
                               prevali, irevali, itarifa, itarrea, ipritot, icaptot,
                               ftarifa)
                       VALUES (psseguro, v_gar.cgarant, NVL(v_gar.nriesgo, 0), pfcarpro,
                               v_gar.norden, v_gar.ctarifa,
                               NVL(parms_transitorios(cont).icapital, v_gar.icapital),
                               v_gar.precarg, piprianu, NULL, v_gar.cformul, v_gar.iextrap,
                               v_gar.ctipfra, v_gar.ifranqu, ppsproces, v_gar.irecarg,
                               pipritar, v_gar.pdtocom, pidtocom, v_gar.crevali,
                               v_gar.prevali, v_gar.irevali, tasa, NULL, NULL, NULL,
                               v_gar.ftarifa);
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 101998;
               END;
            END IF;
         END LOOP;

-------------------------------------------------------------------------
-- Prima total
-------------------------------------------------------------------------
         SELECT SUM(iprianu)
           INTO total_prima
           FROM garancar g
          WHERE g.sseguro = psseguro
            AND g.nriesgo = v_risc.nriesgo
            AND sproces = conta_proces
            AND g.cgarant NOT IN(SELECT cgarant
                                   FROM pargaranpro
                                  WHERE cramo = pcramo
                                    AND cmodali = pcmodali
                                    AND ctipseg = pctipseg
                                    AND ccolect = pccolect
                                    AND cactivi = pcactivi
                                    AND cpargar = 'SUMA_PRIMA'
                                    AND cvalpar = 0);

         cont := 0;

-------------------------------------------------------------------------
-- 3er cursor de garanties (ara de garancar). Descomptes per volumn
-------------------------------------------------------------------------
         FOR v_gar IN c_garancar LOOP
            cont := cont + 1;
            piprianu := v_gar.iprianu;
            num_err := pac_cartera.f_dto_vol(psesion, v_gar.sseguro, v_gar.cgarant, cont,
                                             total_prima, piprianu, mensa, parms_transitorios);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            BEGIN
               UPDATE garancar
                  SET iprianu = piprianu
                WHERE sseguro = psseguro
                  AND cgarant = v_gar.cgarant
                  AND nriesgo = v_gar.nriesgo
                  AND finiefe = v_gar.finiefe
                  AND sproces = v_gar.sproces;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 101998;
            END;
         END LOOP;

------------------------------------------------
-- COMPROVACIÓ de prima mínima, cal regularitzar
------------------------------------------------
-- Si s'ha de comprovar la prima mínima, cal veure si hi ha garantia
-- de regularització.
--
-- Si la prima mínima és calculada, cal cridar al SGT
         lprima_minima := NULL;

         IF pcgarant_regu IS NOT NULL
            AND NVL(pcprimin, 0) = 1
            AND NVL(laplicaprmin, 1) = 1 THEN
            BEGIN
               SELECT formula
                 INTO formula
                 FROM sgt_formulas
                WHERE clave = pcclapri;

               -- Bug 21121 - APD - 23/02/2012 - se añade el parametro v_tregconcep
               pac_parm_tarifas.inserta_parametro(psesion, pcclapri, 1, parms_transitorios,
                                                  num_err, NULL, v_tregconcep);

               -- fin Bug 21121 - APD - 23/02/2012
               IF num_err <> 0 THEN
                  mensa := pcgarant_regu || '.Regulariza';
                  RETURN(num_err);
               END IF;

               --trobem el valor de la prima minima
               lprima_minima := pk_formulas.eval(formula, psesion);
            EXCEPTION
               WHEN OTHERS THEN
                  texto := f_axis_literales(101150, pidioma);
                  pnnumlin := NULL;
                  num_err := f_proceslin(ppsproces, texto, psseguro, pnnumlin);
                  RETURN 101150;
            END;
         ELSIF pcgarant_regu IS NOT NULL
               AND NVL(pcprimin, 1) = 0
               AND NVL(laplicaprmin, 1) = 1 THEN
            lprima_minima := piprimin;
         END IF;

         IF total_prima < NVL(lprima_minima, 0)
            AND NVL(laplicaprmin, 1) = 1 THEN
            -- Insertem a garancar la garantia de regularització
            BEGIN
               lprima_regu := lprima_minima - total_prima;

               INSERT INTO garancar
                           (sseguro, cgarant, nriesgo, finiefe, norden, ctarifa,
                            icapital, precarg, iprianu, ffinefe, cformul, iextrap, ctipfra,
                            ifranqu, sproces, irecarg, ipritar, pdtocom, idtocom, crevali,
                            prevali, irevali, itarifa, itarrea, ipritot, icaptot, ftarifa)
                    VALUES (psseguro, pcgarant_regu, v_risc.nriesgo, pfcarpro, pnorden, NULL,
                            NULL, NULL, lprima_regu, NULL, NULL, NULL, NULL,
                            NULL, ppsproces, NULL, NULL, NULL, NULL, 0,
                            NULL, NULL, NULL, NULL, lprima_regu, NULL, pfcarpro);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  UPDATE garancar
                     SET iprianu = lprima_regu
                   WHERE sproces = ppsproces
                     AND sseguro = psseguro
                     AND nriesgo = v_risc.nriesgo
                     AND cgarant = pcgarant_regu;
               WHEN OTHERS THEN
                  RETURN 101998;
            END;
         ELSE
            -- Esborrem la garantia de regularització si no n'ha de tenir, pq tenim la
            -- del moviment anterior
            DELETE FROM garancar
                  WHERE sproces = ppsproces
                    AND sseguro = psseguro
                    AND nriesgo = v_risc.nriesgo
                    AND cgarant = pcgarant_regu;
         END IF;

         pac_parm_tarifas.borra_parametro(psesion, pcclapri);
-- jlb - I - Optimización
        -- DELETE FROM sgt_parms_transitorios
        --       WHERE sesion = psesion;
         num_err := pac_sgt.del(psesion);
-- jlb - F - Optimización
         parms_transitorios.DELETE;   -- Inicializo la matriz de parms_transitorios
         -- Realitzem un bucle per calcular els descomptes
         --  (despres d'haver tingut en compte les respostes de les preguntes)
         -- Per la bonificació, comprovem quina prima és la menor entre la nova
         -- i l'anualitat anterior
         laplica_actual := NULL;

         IF NVL(paplica_bonifica, 0) = 1 THEN
            -- Retorna 1 si s'aplica el descompte a la prima actual
            -- Retorna 0 si s'aplica el descompte a la prima de l'anualitat anterior
            laplica_actual := pac_bonifica.calcul_bonificacio_actual(psseguro, conta_proces,
                                                                     NULL, lnmovimi);
         END IF;

-------------------------------------------------------------------------
-- 4art bucle de garanties (garancar ). Descomptes i recàrrecs
-------------------------------------------------------------------------
         FOR v_gar IN c_garancar LOOP   -- loop de descomptes i recàrrecs
            IF NVL(laplica_actual, 1) = 1 THEN
               lprima_bonif := v_gar.iprianu;
            ELSE
               lprima_bonif := pac_bonifica.calcul_prima_ant(psseguro, lnmovimi,
                                                             v_gar.nriesgo, v_gar.cgarant);

               IF lprima_bonif IS NULL THEN
                  lprima_bonif := 0;
               END IF;
            END IF;

            prima := v_gar.iprianu;
            -- Veure si se li aplica el descompte amb el paràmetre APLICABONI
            --
            num_err := f_pargaranpro(pcramo, pcmodali, pctipseg, pccolect, pcactivi,
                                     v_gar.cgarant, 'APLICABONI', lcvalpar);

            IF NVL(lcvalpar, 1) = 1 THEN
               -- Bug 21907 - MDS - 03/05/2012
               -- añadir parámetros nuevos : v_gar.pdtotec, v_gar.preccom, pidtotec, pireccom
               num_err := f_recdto(v_gar.precarg, v_gar.pdtocom, pirecarg, pidtocom,
                                   v_gar.pdtotec, v_gar.preccom, pidtotec, pireccom,   -- Bug 21907 - MDS - 03/05/2012
                                   v_gar.iextrap, v_gar.icapital, v_extraprima,   -- BUG19532:DRA:26/09/2011
                                   prima, pmoneda, paplica_bonifica, lprima_bonif, NULL, NULL,
                                   psproduc);   --DCT - 02/12/2014

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               -- Modificamos la tabla GARANCAR con las primas nuevas
               -- Se redondea la prima en funcion de la forma de pago
               BEGIN
                  UPDATE garancar
                     SET irecarg = pirecarg,
                         idtocom = pidtocom,
                         idtotec = pidtotec,   -- Bug 21907 - MDS - 03/05/2012
                         ireccom = pireccom,   -- Bug 21907 - MDS - 03/05/2012
                         iprianu = f_round_forpag(prima, pcforpag, pmoneda, psproduc)
                   WHERE sseguro = psseguro
                     AND cgarant = v_gar.cgarant
                     AND nriesgo = v_gar.nriesgo
                     AND finiefe = v_gar.finiefe
                     AND sproces = v_gar.sproces;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 101998;
               END;
            END IF;
         END LOOP;   -- loop de descomptes i recàrrecs
      END LOOP;   -- loop de riscos

        -- Mirem si s'ha d'anular la pòlissa després de tarifar tots els riscos.
        -- S'ha canviat de posisció pq abans s'estava fent dins del bucle de riscos
        -- i si s'anulava el primer anulava la pol sense haver mirat els altres
--nunu
        /******************************************************
           Se verifican las anulaciones
        *******************************************************/
      anulado := 0;

      IF pmodo = 'P' THEN
         BEGIN
            SELECT COUNT(*)
              INTO registros
              FROM garancar
             WHERE sseguro = psseguro
               AND sproces = conta_proces;
         EXCEPTION
            WHEN OTHERS THEN
               registros := 0;
         END;

         --Si no hay registros grabados en GARANCAR se
         --anula el seguro
         IF registros = 0 THEN
            -- Grabamos un registro en PROCESLIN para avisar
            -- que el seguro se va a anular.
            anulado := 1;
            texto := f_axis_literales(105735, pidioma);
            pnnumlin := NULL;
            num_err := f_proceslin(ppsproces, texto, psseguro, pnnumlin);
            RETURN num_err;
         END IF;
      ELSIF pmodo = 'R' THEN
         --Hemos grabado las garantías que no se anulan en GARANCAR.
         -- Ahora tenemos que mirar si se anula algun riesgo o el seguro
         num_err := f_anular(psseguro, pfcarpro, conta_proces, pfcarpro, pfemisio, movimiento,
                             anulado);
      END IF;

      IF anulado = 0 THEN
--------------------------------------------------------------------------
-- Se calcula el porcentaje también para el coaseguro
-- aceptado (ctipcoa <> 0)
         BEGIN
            SELECT c.ploccoa
              INTO porcen
              FROM coacuadro c, seguros s
             WHERE c.sseguro = s.sseguro
               AND c.ncuacoa = s.ncuacoa
               AND s.ctipcoa <> 0
               AND s.sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               porcen := 100;   -- No hay coaseguro cedido
         END;

         num_err := f_garancoa('P', porcen, psseguro);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      RETURN 0;
   END f_garantarifa_sgt;

   FUNCTION f_anuledad(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pfiniefe IN DATE,
      pfcarpro IN DATE,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcobjase IN NUMBER,
      pmodo IN VARCHAR2,
      pnedamar IN NUMBER,
      pciedmar IN NUMBER,
      estat_garan OUT VARCHAR2)
      RETURN NUMBER IS
      fech_nacim     DATE;
      num_err        NUMBER;
      edad           NUMBER;
      edadmax        garanpro.nedamar%TYPE;   --       edadmax        NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      actividad      seguros.cactivi%TYPE;   --       actividad      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      real_actu      NUMBER;
   BEGIN
      estat_garan := 'NO_CAMBIADA';

      IF pcobjase = 1 THEN   -- si el tipo de riesgo es personal
         --Calculamos la edad del riesgo
         BEGIN
            -- Bug 0012802 - 20/01/2010 - JMF
            SELECT fnacimi
              INTO fech_nacim
              FROM per_personas p, riesgos r
             WHERE r.sseguro = psseguro
               AND r.nriesgo = pnriesgo
               AND r.sperson = p.sperson;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               --Riesgo no encontrado en la tabla PERSONAS
               RETURN 105709;
         END;

         -- Comprovem si ha arribat a la data màxima de renovació per producte
         -- abans que per garantia.
         IF pnedamar IS NOT NULL THEN
            IF NVL(pciedmar, 0) = 0 THEN
               real_actu := 2;
            ELSIF NVL(pciedmar, 0) = 1 THEN
               real_actu := 1;
            ELSE
               real_actu := 1;
            END IF;

            num_err := f_difdata(fech_nacim, pfcarpro, real_actu, 1, edad);

            IF pnedamar < edad THEN
               estat_garan := 'CAMBIADA';
            END IF;
         END IF;

         IF estat_garan <> 'CAMBIADA' THEN
            -- Calculamos la edad máxima de esta garantía en este producto
            SELECT cactivi
              INTO actividad
              FROM seguros
             WHERE sseguro = psseguro;

            BEGIN
               SELECT nedamar, DECODE(NVL(ciedmar, 0), 0, 2, 1, 1)
                 INTO edadmax, real_actu
                 FROM garanpro
                WHERE cgarant = pcgarant
                  AND cramo = pcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect
                  AND cactivi = actividad;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT nedamar, DECODE(NVL(ciedmar, 0), 0, 2, 1, 1)
                       INTO edadmax, real_actu
                       FROM garanpro
                      WHERE cgarant = pcgarant
                        AND cramo = pcramo
                        AND cmodali = pcmodali
                        AND ctipseg = pctipseg
                        AND ccolect = pccolect
                        AND cactivi = 0;
                  EXCEPTION
                     WHEN OTHERS THEN
                        --Garantía no encontrada en la tabla GARANPRO
                        RETURN 105710;
                  END;
               WHEN OTHERS THEN
                  --Garantía no encontrada en la tabla GARANPRO
                  RETURN 105710;
            END;

            -- Se calcula la edad en funcion del parametro del producto CIEDMAR
            IF edadmax IS NOT NULL THEN
               num_err := f_difdata(fech_nacim, pfcarpro, real_actu, 1, edad);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;

            IF edad > NVL(edadmax, 9999999) THEN
               estat_garan := 'CAMBIADA';

               IF pmodo = 'R' THEN
                  BEGIN
                     UPDATE garanseg
                        SET ffinefe = pfcarpro
                      WHERE sseguro = psseguro
                        AND nriesgo = pnriesgo
                        AND cgarant = pcgarant
                        AND nmovimi = pnmovimi
                        AND finiefe = pfiniefe;
                  EXCEPTION
                     WHEN OTHERS THEN
                        RETURN 101959;
                  END;
               END IF;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   END;

   FUNCTION f_tarifar_sgt(
      pmoneda IN NUMBER,
      psesion IN NUMBER,
      pcmanual IN NUMBER,
      psseguro IN NUMBER,
      pcgarant IN NUMBER,
      cont IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      priesgo IN NUMBER,
      prevcap IN OUT NUMBER,
      tasa IN OUT NUMBER,
      pipritar IN OUT NUMBER,
      piprianu IN OUT NUMBER,
      pcactivi IN NUMBER,
      pnum_risc IN NUMBER,
      mensa IN OUT VARCHAR2,
      parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb)
      RETURN NUMBER IS
      valor          NUMBER;
      sesion         NUMBER;
      formula        sgt_formulas.formula%TYPE;   --       formula        VARCHAR2(2000); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      clav           garanformula.clave%TYPE;   --       clav           NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      num_err        NUMBER;
      num_err        NUMBER;
      error          NUMBER;
      salir          EXCEPTION;
      v_tregconcep   pac_parm_tarifas.tregconcep_tabtyp;   -- Bug 21121 - APD - 23/02/2012
   BEGIN
      IF pcmanual = 0 THEN   -- Para pcmanual = 2 se toma directamente la prima tarifa revalorizada.
---------------------------------------------------
-- Capturamos la tasa o importe fijo de la garantía
---------------------------------------------------
         clav := NULL;

         BEGIN
            SELECT clave
              INTO clav
              FROM garanformula
             WHERE cgarant = pcgarant
               AND ccampo = 'TASA'
               AND cramo = pcramo
               AND cmodali = pcmodali
               AND ctipseg = pctipseg
               AND ccolect = pccolect
               AND cactivi = pcactivi;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT clave
                    INTO clav
                    FROM garanformula
                   WHERE cgarant = pcgarant
                     AND ccampo = 'TASA'
                     AND cramo = pcramo
                     AND cmodali = pcmodali
                     AND ctipseg = pctipseg
                     AND ccolect = pccolect
                     AND cactivi = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     piprianu := 0;
                     pipritar := 0;
                  WHEN OTHERS THEN
                     mensa := pcgarant || '.Tasa';
                     RETURN 108422;   --'Error en selección del código'
               END;
            WHEN OTHERS THEN
               mensa := pcgarant || '.Tasa';
               RETURN 108422;
         END;

         IF clav IS NOT NULL THEN
            BEGIN
               SELECT formula
                 INTO formula
                 FROM sgt_formulas
                WHERE clave = clav;
            EXCEPTION
               WHEN OTHERS THEN
                  mensa := pcgarant || '.Tasa';
                  RETURN 108423;   -- Error en selección de sgt_formulas
            END;

            -- Bug 21121 - APD - 23/02/2012 - se añade el parametro v_tregconcep
            pac_parm_tarifas.inserta_parametro(psesion, clav, cont, parms_transitorios, error,
                                               NULL, v_tregconcep);

            -- fin Bug 21121 - APD - 23/02/2012
            IF error <> 0 THEN
               mensa := pcgarant || '.Tasa';
               RETURN(error);
            END IF;

            valor := pk_formulas.eval(formula, psesion);

            IF valor IS NULL THEN
               mensa := pcgarant || '.Tasa';
               RETURN 108437;
            ELSE
               tasa := f_round(valor, pmoneda);
            END IF;

            pac_parm_tarifas.borra_parametro(psesion, clav);
         END IF;

-----------------------------------------
-- Calculo del capital
-----------------------------------------
         clav := NULL;

         BEGIN
            SELECT clave
              INTO clav
              FROM garanformula
             WHERE cgarant = pcgarant
               AND ccampo = 'ICAPITAL'
               AND cramo = pcramo
               AND cmodali = pcmodali
               AND ctipseg = pctipseg
               AND ccolect = pccolect
               AND cactivi = pcactivi;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT clave
                    INTO clav
                    FROM garanformula
                   WHERE cgarant = pcgarant
                     AND ccampo = 'ICAPITAL'
                     AND cramo = pcramo
                     AND cmodali = pcmodali
                     AND ctipseg = pctipseg
                     AND ccolect = pccolect
                     AND cactivi = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     piprianu := 0;
                     pipritar := 0;
                  WHEN OTHERS THEN
                     mensa := pcgarant || '.Capital';
                     RETURN 108422;
--                      mensa := 'Error en selección del código'||sqlcode||sqlerrm;
               END;
            WHEN OTHERS THEN
               mensa := pcgarant || '.Capital';
               RETURN 108422;
--              mensa := 'Error en selección del código'||sqlcode||sqlerrm;
         END;

         IF clav IS NOT NULL THEN
            BEGIN
               SELECT formula
                 INTO formula
                 FROM sgt_formulas
                WHERE clave = clav;
            EXCEPTION
               WHEN OTHERS THEN
                  mensa := pcgarant || '.Capital';
                  RETURN 108423;
--                mensa := 'Error en selección de sgt_formulas'||sqlcode||sqlerrm;
            END;

            parms_transitorios(cont).icapital := prevcap;
            -- Bug 21121 - APD - 23/02/2012 - se añade el parametro v_tregconcep
            pac_parm_tarifas.inserta_parametro(psesion, clav, cont, parms_transitorios, error,
                                               NULL, v_tregconcep);

            -- fin Bug 21121 - APD - 23/02/2012
            IF error <> 0 THEN
               mensa := pcgarant || '.Capital';
               RETURN(error);
            END IF;

            valor := pk_formulas.eval(formula, psesion);

            IF valor IS NULL THEN
               mensa := pcgarant || '.Capital';
               RETURN 108437;
            ELSE
               prevcap := valor;
            END IF;

            pac_parm_tarifas.borra_parametro(psesion, clav);
         END IF;

-----------------------------------------
-- Calculo la prima tarifa de la garantía
-----------------------------------------
         clav := NULL;

         BEGIN
            SELECT clave
              INTO clav
              FROM garanformula
             WHERE cgarant = pcgarant
               AND ccampo = 'IPRITAR'
               AND cramo = pcramo
               AND cmodali = pcmodali
               AND ctipseg = pctipseg
               AND ccolect = pccolect
               AND cactivi = pcactivi;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT clave
                    INTO clav
                    FROM garanformula
                   WHERE cgarant = pcgarant
                     AND ccampo = 'IPRITAR'
                     AND cramo = pcramo
                     AND cmodali = pcmodali
                     AND ctipseg = pctipseg
                     AND ccolect = pccolect
                     AND cactivi = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     piprianu := 0;
                     pipritar := 0;
                     RETURN 0;   -- No hay prima_tarifa para esta garantía.--> Tampoco prima_anual
                  WHEN OTHERS THEN
                     mensa := pcgarant || '.Prima Tarifa';
                     RETURN 108422;
--                      mensa := 'Error en selección del código'||sqlcode||sqlerrm;
               END;
            WHEN OTHERS THEN
               mensa := pcgarant || '.Prima Tarifa';
               RETURN 108422;
--              mensa := 'Error en selección del código'||sqlcode||sqlerrm;
         END;

         IF clav IS NOT NULL THEN
            BEGIN
               SELECT formula
                 INTO formula
                 FROM sgt_formulas
                WHERE clave = clav;
            EXCEPTION
               WHEN OTHERS THEN
                  mensa := pcgarant || '.Prima Tarifa';
                  RETURN 108423;
            --                mensa := 'Error en selección de sgt_formulas'||sqlcode||sqlerrm;
            END;

            parms_transitorios(cont).icapital := prevcap;
            -- Bug 21121 - APD - 23/02/2012 - se añade el parametro v_tregconcep
            pac_parm_tarifas.inserta_parametro(psesion, clav, cont, parms_transitorios, error,
                                               NULL, v_tregconcep);

            -- fin Bug 21121 - APD - 23/02/2012
            IF error <> 0 THEN
               mensa := pcgarant || '.Prima Tarifa';
               RETURN(error);
            END IF;

            valor := pk_formulas.eval(formula, psesion);

            IF valor IS NULL THEN
               mensa := pcgarant || '.Prima Tarifa';
               RETURN 108437;
            ELSE
               pipritar := f_round(valor, pmoneda);
            END IF;

            pac_parm_tarifas.borra_parametro(psesion, clav);
         END IF;
      END IF;   -- De pcmanual = 0

----------------------------------------
-- Calculo la prima anual de la garantía
----------------------------------------
      clav := NULL;

      BEGIN
         SELECT clave
           INTO clav
           FROM garanformula
          WHERE cgarant = pcgarant
            AND ccampo = 'IPRIANU'
            AND cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect
            AND cactivi = pcactivi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT clave
                 INTO clav
                 FROM garanformula
                WHERE cgarant = pcgarant
                  AND ccampo = 'IPRIANU'
                  AND cramo = pcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect
                  AND cactivi = 0;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  piprianu := pipritar;
                  RETURN 0;
               WHEN OTHERS THEN
                  mensa := pcgarant || '.Prima Anual';
                  RETURN 108422;
--                        mensa := 'Error en selección del código'||sqlcode||sqlerrm;
            END;
         WHEN OTHERS THEN
            mensa := pcgarant || '.Prima Anual';
            RETURN 108422;
--                mensa := 'Error en selección del código'||sqlcode||sqlerrm;
      END;

      BEGIN
         SELECT formula
           INTO formula
           FROM sgt_formulas
          WHERE clave = clav;
      EXCEPTION
         WHEN OTHERS THEN
            mensa := pcgarant || '.Prima Anual';
            RETURN 108423;
--                mensa := 'Error en selección de sgt_formulas'||sqlcode||sqlerrm;
      END;

      parms_transitorios(cont).ipritar := pipritar;
      -- Bug 21121 - APD - 23/02/2012 - se añade el parametro v_tregconcep
      pac_parm_tarifas.inserta_parametro(psesion, clav, cont, parms_transitorios, error, NULL,
                                         v_tregconcep);

      -- fin Bug 21121 - APD - 23/02/2012
      IF error <> 0 THEN
         mensa := pcgarant || '.Prima Anual';
         RETURN(error);
      END IF;

      valor := pk_formulas.eval(formula, psesion);

      IF valor IS NULL THEN
         mensa := pcgarant || '.Prima Anual';
         RETURN 108437;
      ELSE
         piprianu := f_round(valor, pmoneda);
      END IF;

      pac_parm_tarifas.borra_parametro(psesion, clav);
      RETURN 0;
   END;

   FUNCTION f_dto_vol(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pcgarant IN NUMBER,
      cont IN NUMBER,
      prima_total IN NUMBER,
      piprianu IN OUT NUMBER,
      mensa IN OUT VARCHAR2,
      parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb)
      RETURN NUMBER IS
-- Declaración de variables
      pcramo         seguros.cramo%TYPE;   --       pcramo         NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pcmodali       seguros.cmodali%TYPE;   --       pcmodali       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pctipseg       seguros.ctipseg%TYPE;   --       pctipseg       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pccolect       seguros.ccolect%TYPE;   --       pccolect       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pcactivi       seguros.cactivi%TYPE;   --       pcactivi       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      valor          NUMBER;
      formula        sgt_formulas.formula%TYPE;   --       formula        VARCHAR2(2000); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      clav           garanformula.clave%TYPE;   --       clav           NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      num_err        NUMBER;
      error          NUMBER;
      salir          EXCEPTION;
      v_tregconcep   pac_parm_tarifas.tregconcep_tabtyp;   -- Bug 21121 - APD - 23/02/2012
   BEGIN
      SELECT cramo, cmodali, ctipseg, ccolect, cactivi
        INTO pcramo, pcmodali, pctipseg, pccolect, pcactivi
        FROM seguros
       WHERE sseguro = psseguro;

      -- Calculamos los descuentos por volumen.
      BEGIN
         SELECT clave
           INTO clav
           FROM garanformula
          WHERE cgarant = pcgarant
            AND ccampo = 'VOL_PRIM'
            AND cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect
            AND cactivi = pcactivi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT clave
                 INTO clav
                 FROM garanformula
                WHERE cgarant = pcgarant
                  AND ccampo = 'VOL_PRIM'
                  AND cramo = pcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect
                  AND cactivi = 0;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 0;   -- No existen descuentos ni recargos por otros conceptos.
               WHEN OTHERS THEN
                  mensa := pcgarant || '.Dto. Vol';
                  RETURN 108422;
            END;
         WHEN OTHERS THEN
            mensa := pcgarant || '.Dto. Vol';
            RETURN 108422;
      END;

      BEGIN
         SELECT formula
           INTO formula
           FROM sgt_formulas
          WHERE clave = clav;
      EXCEPTION
         WHEN OTHERS THEN
            mensa := pcgarant || '.Dto. Vol';
            RETURN 108423;
      END;

      parms_transitorios(cont).iprianu := piprianu;
      -- Bug 21121 - APD - 23/02/2012 - se añade el parametro v_tregconcep
      pac_parm_tarifas.inserta_parametro(psesion, clav, cont, parms_transitorios, error,
                                         prima_total, v_tregconcep);

      -- fin Bug 21121 - APD - 23/02/2012
      IF error <> 0 THEN
         mensa := pcgarant || '.Dto. Vol';
         RETURN(error);
      END IF;

      valor := pk_formulas.eval(formula, psesion);

      IF valor IS NULL THEN
         mensa := pcgarant || '.Dto. Vol';
         RETURN 108437;
      ELSE
         piprianu := valor;
      END IF;

      pac_parm_tarifas.borra_parametro(psesion, clav);
      RETURN 0;
   END;

   FUNCTION f_anular(
      psseguro IN NUMBER,
      pfcaranu IN DATE,
      psproces IN NUMBER,
      pfcontab IN DATE,
      pfemisio IN DATE,
      pnmovimi OUT NUMBER,
      panulado OUT NUMBER)
      RETURN NUMBER IS
/**************************************************************************
    F_ANULAR : Anula el seguro o sólo riesgos dependiendo de lo que
            se haya grabado en GARANCAR
            Si se anula algun riesgo, ya genera el movim. de CARTERA,
            y devuelve pnmovimi. Si no pnmovimi = null.
            Si se anula el seguro, ya se genera un movim. de anulacion,
            y panulado = 1.
****************************************************************************/
      CURSOR c_riesgos IS
         SELECT nriesgo
           FROM riesgos
          WHERE sseguro = psseguro
            AND(fanulac IS NULL
                OR fanulac > pfcaranu);

      num_riesgos    NUMBER;
      num_garant     NUMBER;
      num_err        NUMBER;
      registros      NUMBER;
      movimi         NUMBER;
   BEGIN
      panulado := 0;   -- inicializamos la variable que nos indica seguro anulado
      pnmovimi := NULL;

      -- Ahora miramos los registros que hemos grabado en GARANCAR
      BEGIN
         SELECT COUNT(*)
           INTO num_garant
           FROM garancar
          WHERE sseguro = psseguro
            AND sproces = psproces;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 103502;
      END;

      IF num_garant = 0 THEN   -- no se ha grabado ningun registro
         -- Anulamos el seguro.
         num_err := f_anulaseg(psseguro, 0, pfcaranu, 503, NULL, 3, movimi);

         IF num_err <> 0 THEN
            RETURN num_err;
         ELSE
            panulado := 1;
         END IF;
      ELSE   -- Se han grabado registros
         -- Miramos cuantos registros se han grabado por riesgo.
         FOR valor IN c_riesgos LOOP
            SELECT COUNT(*)
              INTO registros
              FROM garancar
             WHERE sseguro = psseguro
               AND sproces = psproces
               AND nriesgo = valor.nriesgo;

            IF registros = 0 THEN
               --Si no hay registros grabados en GARANCAR se
               --anula el riesgo
               -- Primero generamos el movimiento de seguro de CARTERA
               -- si es el primer riesgo que se anula
               IF pnmovimi IS NULL THEN
                  -- Se pasa pcimpres = null para coger
                  -- el estado de impresion del ultimo movimiento
                  num_err := f_movseguro(psseguro, NULL, 404, 2, pfcaranu, NULL, NULL, NULL,
                                         pfcontab, pnmovimi, pfemisio);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;

                  -- Se llama a f_act_hisseg para guardar la
                  -- situación anterior al suplemento.
                  -- El nmovimi es el anterior al del suplemento,
                  -- por eso se le resta uno al recién creado.
                  num_err := f_act_hisseg(psseguro, pnmovimi - 1);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;

               num_err := f_anularisc(psseguro, valor.nriesgo, pfcaranu, pnmovimi);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;
         END LOOP;
      END IF;

      RETURN 0;
   END;

   FUNCTION p_cartera(
      pmoneda IN NUMBER,
      pidioma IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      p_sseguro IN NUMBER,
      p_cramo IN NUMBER,
      p_cmodali IN NUMBER,
      p_ctipseg IN NUMBER,
      p_ccolect IN NUMBER,
      p_ctarman IN NUMBER,
      p_ccobban IN NUMBER,
      p_nrenova IN NUMBER,
      p_ctipreb IN NUMBER,
      p_cforpag IN NUMBER,
      p_nduraci IN NUMBER,
      p_ndurcob IN NUMBER,
      p_cactivi IN OUT NUMBER,
      p_csubpro IN NUMBER,
      p_cobjase IN NUMBER,
      p_cagrpro IN NUMBER,
      p_fefecto IN DATE,
      p_fvencim IN DATE,
      p_fcarpro IN OUT DATE,
      p_fcaranu IN OUT DATE,
      p_nanuali OUT NUMBER,
      p_nfracci OUT NUMBER,
      p_fcarant OUT DATE,
      ppsproces IN NUMBER,
      indice IN OUT NUMBER,
      indice_error IN OUT NUMBER,
      pfemisio IN DATE,
      pcorrecte OUT NUMBER,
      p_sproduc IN NUMBER,
      p_nsuplem IN NUMBER,
      pcgarant_regu IN NUMBER,
      pnorden IN NUMBER,
      pcprimin IN NUMBER,
      piprimin IN NUMBER,
      pcclapri IN NUMBER,
      pnedamar IN NUMBER,
      pciedmar IN NUMBER)
      RETURN NUMBER IS
      vfemisio       DATE;
      pempresa       NUMBER;
      encontrado     NUMBER := 0;
      codi_ramo      NUMBER;
      mes_conta      DATE;
      algun_error    NUMBER := 0;
      num_err        NUMBER := 0;
      prevcap        NUMBER(13, 2);
      texto          VARCHAR2(100);
      piprima        NUMBER(13, 2);
      psperson       NUMBER(10);
      conta_proces   NUMBER;
      error          NUMBER;
      fcarpronueva   seguros.fcarpro%TYPE := NULL;   --       fcarpronueva   DATE := NULL; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      fcarantnueva   seguros.fcarant%TYPE := NULL;   --       fcarantnueva   DATE := NULL; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      fcaranunueva   seguros.fcaranu%TYPE := NULL;   --       fcaranunueva   DATE := NULL; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      nanualinueva   seguros.nanuali%TYPE := NULL;   --       nanualinueva   NUMBER := NULL; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      nfraccinueva   seguros.nfracci%TYPE;   --       nfraccinueva   NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      frenovanueva   seguros.frenova%TYPE := NULL;
      pnrecibo       NUMBER;
      tipo           codiram.cgtarif%TYPE;   --       tipo           NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      fec            VARCHAR2(20);
      texto2         VARCHAR2(60);
      num            NUMBER;
      ttexto         VARCHAR2(30);
      piregula       NUMBER;
      ptempresa      VARCHAR2(70);
      pnnumlin       NUMBER;
      num_risc       NUMBER;
      pnimport2      NUMBER;
      pcmovimi       NUMBER;
      pnmovimi2      NUMBER;
      movimiento     NUMBER;
      anulado        NUMBER;
      fecha_carpro   empresas.fcarpro%TYPE;   --       fecha_carpro   DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      fecha_carant   empresas.fcarant%TYPE;   --       fecha_carant   DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      dia            VARCHAR2(4);
      fechini        DATE;
      primaant       NUMBER;
      pfech          DATE;
      prima          seguros.iprianu%TYPE;   --       prima          NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      modcom         NUMBER;
      fultrenova     DATE;
      nmovimi        NUMBER;
      parms_transitorios pac_parm_tarifas.parms_transitorios_tabtyb;
      lbonifica      NUMBER;
      laplica_bonifica NUMBER;
      lcumple        NUMBER;
      num_lin        NUMBER;
      lcactivi       NUMBER;
   BEGIN
      pcorrecte := 0;
      vfemisio := pfemisio;
      conta_proces := ppsproces;
      fcarantnueva := NULL;
      fcarpronueva := NULL;
      fcaranunueva := NULL;
      nanualinueva := NULL;
      nfraccinueva := NULL;
      frenovanueva := NULL;

      IF p_fcarpro IS NOT NULL THEN
         indice := indice + 1;
         algun_error := 0;
         num_err := 0;

         WHILE(p_fcarpro <(LAST_DAY(TO_DATE(LPAD(pmes, 2, '0') || panyo, 'mmyyyy')) + 1)
               AND algun_error = 0
               AND(p_fcarpro < p_fvencim
                   OR p_fvencim IS NULL)) LOOP
            IF algun_error = 0 THEN
               IF p_fcarpro = p_fcaranu THEN
                  --
                  num_err := pac_cambiocartera.cambiocartera('R', p_sproduc, p_cactivi,
                                                             p_sseguro, p_cramo, p_cmodali,
                                                             p_ctipseg, p_ccolect, p_fcaranu,
                                                             p_nsuplem, lcumple, lcactivi);

                  IF lcumple = 1
                     AND num_err = 0 THEN
                     p_cactivi := lcactivi;
                     texto := f_axis_literales(110406, pidioma);
                     texto := texto || '.' || p_sseguro;
                     num_lin := NULL;
                     num_err := f_proceslin(ppsproces, texto, p_sseguro, num_lin);

                     IF num_err = 0 THEN
                        COMMIT;
                     END IF;
------
                  END IF;

                  IF num_err = 0 THEN
                     -- La pòlissa renova , cal comprovar si te bonificació
                     -- per no sinistralitat
                     num_err := pac_bonifica.f_bonifica_poliza(p_cramo, p_cmodali, p_ctipseg,
                                                               p_ccolect, p_sseguro,
                                                               p_fcaranu, p_fefecto,
                                                               lbonifica, laplica_bonifica);
                  END IF;

                  IF num_err <> 0 THEN
                     algun_error := 1;
                     indice_error := indice_error + 1;
                  ELSE
                     -- Se comprueba si el seguro tiene regularizacion y
                     -- si es así se calcula el importe de regularización y se genera
                     -- el recibo de extorno
                     -- La prima anterior se calcula con la función
                     -- f_recprima, no es el iprianu de seguros
                     dia := SUBSTR(LPAD(p_nrenova, 4, '0'), 3, 2);
                     --   fechini := f_summeses(p_fcaranu, -12, dia);
                     num_err := f_ultrenova(p_sseguro, p_fcaranu, fultrenova, nmovimi);

                     IF num_err <> 0 THEN
                        algun_error := 1;
                        indice_error := indice_error + 1;
                     ELSE
                        primaant := f_recprima(p_sseguro, fultrenova, p_fcaranu);
                        num_err := f_regulariza(p_sseguro, primaant, fultrenova, p_fcaranu,
                                                ppsproces, vfemisio, piregula);

                        IF num_err <> 0
                           AND num_err <> 1000 THEN
                           algun_error := 1;
                           indice_error := indice_error + 1;
                        ELSE
                           num_err := 0;

                           BEGIN
                              SELECT cgtarif
                                INTO tipo
                                FROM codiram
                               WHERE cramo = p_cramo;
                           EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                 num_err := 101904;
                                 algun_error := 1;
                                 indice_error := indice_error + 1;
                              WHEN OTHERS THEN
                                 num_err := 104793;
                                 algun_error := 1;
                                 indice_error := indice_error + 1;
                           END;

                           IF num_err = 0 THEN
                              -- Se busca el parámetro num_risc
                              BEGIN
                                 SELECT COUNT(*)
                                   INTO num_risc
                                   FROM riesgos
                                  WHERE sperson IS NOT NULL
                                    AND sseguro = p_sseguro;
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    num_risc := 0;
                              END;

                              -- Selección que nos permite saber si se tarifa por
                              -- el método tradicional o por sgt.

                              --31786:NSS:09/10/2014  Eliminar la tabla SGT_PRODUCTOS. Es una tabla obsoleta que no tiene sentido mantener.

                              /*
                              SELECT COUNT(cramo)
                                INTO encontrado
                                FROM sgt_productos
                               WHERE cramo = p_cramo
                                 AND cmodali = p_cmodali
                                 AND ctipseg = p_ctipseg
                                 AND ccolect = p_ccolect;
                              */

                              --Llamamos a la función f_garantarifa que nos calcula la tarifa
-----------------------------------------------------------

                              /*
                              IF encontrado = 1 THEN
                                 num_err := f_garantarifa_sgt('R', p_sseguro, p_cramo,
                                                              p_cmodali, p_cobjase, p_ctipseg,
                                                              p_ccolect, tipo, p_nduraci,
                                                              conta_proces, p_ndurcob,
                                                              p_fcarpro, pmes, panyo, tipo,
                                                              p_cagrpro, p_ctarman, p_cactivi,
                                                              num_risc, vfemisio, movimiento,
                                                              anulado, pmoneda,
                                                              parms_transitorios, lbonifica,
                                                              laplica_bonifica, p_sproduc,
                                                              p_cforpag, pidioma,
                                                              pcgarant_regu, pnorden,
                                                              pcprimin, piprimin, pcclapri,
                                                              pnedamar, pciedmar);

                                 IF num_err <> 0 THEN
                                    algun_error := 1;
                                    indice_error := indice_error + 1;
                                 END IF;
                              ELSE
*/
-- Llamamos a la función f_garantarifa que nos calcula la tarifa
-----------------------------------------------------------
                              num_err := f_garantarifa(pmoneda, p_sseguro, p_cramo, p_cmodali,
                                                       p_cobjase, p_ctipseg, p_ccolect, tipo,
                                                       p_nduraci, conta_proces, p_ndurcob,
                                                       p_fcarpro, pmes, panyo, tipo, p_cagrpro,
                                                       p_ctarman, p_cactivi, num_risc,
                                                       vfemisio, movimiento, anulado);

                              IF num_err > 0 THEN
                                 algun_error := 1;
                                 indice_error := indice_error + 1;
                              END IF;
--31786:NSS:09/10/2014  Eliminar la tabla SGT_PRODUCTOS. Es una tabla obsoleta que no tiene sentido mantener.
--                             END IF;

                           -- Despues de la funcion, podemos haber anulado el seguro o
                           -- algun riesgo, y por lo tanto haber hecho ya el movimiento de
                           -- seguro
                           END IF;

                           IF num_err = 0 THEN
                              IF anulado = 0 THEN   -- si el seguro no se ha anulado
                                 IF movimiento IS NULL THEN   -- si no se han anulado riesgos
                                    -- Se hace un movimiento de seguro de cartera
                                    --Llamamos la función f_movseguro----
                                    -- Se pasa pcimpres = null para coger
                                    -- el estado de impresion del ultimo movimiento
                                    num_err := f_movseguro(p_sseguro, NULL, 404, 2, p_fcarpro,
                                                           NULL, NULL, NULL, mes_conta,
                                                           movimiento, vfemisio);

                                    IF num_err = 0 THEN
                                       -- Se llama a f_act_hisseg para guardar la
                                       -- situación anterior al suplemento.
                                       -- El nmovimi es el anterior al del suplemento,
                                       -- por eso se le resta uno al recién creado.
                                       num_err := f_act_hisseg(p_sseguro, movimiento - 1);
                                    END IF;
                                 END IF;

                                 IF num_err <> 0 THEN
                                    algun_error := 1;
                                    indice_error := indice_error + 1;
                                 ELSE
                                    -- Ya no se compara, se graban todos
                                    --los registros de garancar en garanseg con nmovimi = pnmovimi
                                    ---Llamamos la función f_traspasgar que nos traspasa las
                                    --garantías de garancar a garanseg
                                    num_err := f_traspasgar(conta_proces, p_sseguro,
                                                            p_fcarpro, movimiento);

                                    IF num_err <> 0 THEN
                                       algun_error := 1;
                                       indice_error := indice_error + 1;
                                    ELSE
                                       ----Ya están todas las garantías de GARANSEG y GARANCOLEC tarificadas---
                                       ----Llamamos la función que actualiza datos de la próxima cartera-----
                                       num_err :=
                                          f_acproxcar(p_sseguro, fcarantnueva, fcarpronueva,
                                                      fcaranunueva, nanualinueva,
                                                      nfraccinueva, frenovanueva);

                                       IF num_err <> 0 THEN
                                          algun_error := 1;
                                          indice_error := indice_error + 1;
                                       ELSE
                                          -- Calculamos la nueva iprianu de SEGUROS
                                          -- Se calcula la prima a fecha de la renovación (fcarantnueva)
                                          prima := f_segprima(p_sseguro, fcarantnueva);

                                          BEGIN
                                             UPDATE seguros
                                                SET fcarant = fcarantnueva,
                                                    fcarpro = fcarpronueva,
                                                    fcaranu = fcaranunueva,
                                                    nanuali = nanualinueva,
                                                    nfracci = nfraccinueva,
                                                    iprianu = prima,
                                                    frenova = frenovanueva
                                              WHERE sseguro = p_sseguro;
                                          EXCEPTION
                                             WHEN OTHERS THEN
                                                num_err := 102361;
                                                algun_error := 1;
                                                indice_error := indice_error + 1;
                                          END;
                                       END IF;

                                       --    REASEGURO
                                       IF algun_error = 0 THEN
                                          -- REASEGURO
                                          num_err :=
                                             f_buscactrrea(p_sseguro, movimiento, ppsproces,
                                                           5, pmoneda);

                                          IF num_err <> 0
                                             AND num_err <> 99 THEN
                                             algun_error := 1;
                                             indice_error := indice_error + 1;
                                          ELSIF num_err = 99 THEN   -- Error controlado
                                             NULL;
                                          ELSE
                                             num_err := f_cessio(ppsproces, 5, pmoneda);

                                             IF num_err <> 0
                                                AND num_err <> 99 THEN
                                                algun_error := 1;
                                                indice_error := indice_error + 1;
                                             ELSIF num_err = 99 THEN   -- Falta facultativo
                                                texto := f_axis_literales(105382, pidioma);
                                                pnnumlin := NULL;
                                                num_err :=
                                                   f_proceslin(ppsproces, texto, p_sseguro,
                                                               pnnumlin);
                                             END IF;
                                          END IF;
                                       END IF;

                                       IF algun_error = 0 THEN
                                          -- Se utiliza la función f_recries para calcular el recibo
                                          -- Se controlan las pólizas de ahorro
                                          IF p_cagrpro = 2 THEN
                                             pcmovimi := 2;   -- indica aportación periódica
                                          ELSE
                                             pcmovimi := NULL;
                                          END IF;

                                          -- Si la forma de pago es única no se genera recibo
                                          IF p_cforpag <> 0 THEN
                                             --Llamamos la función de calcular recibos

                                             -- Bug 19777/95194 - 26/10/2011 -AMC
                                             IF f_es_renovacion(p_sseguro) = 0 THEN   -- es cartera
                                                modcom := 2;
                                             ELSE   -- si es 1 es nueva produccion
                                                modcom := 1;
                                             END IF;

                                             vfemisio :=
                                                TO_DATE('01/' || TO_CHAR(TO_NUMBER(pmes))
                                                        || '/' || TO_CHAR(panyo),
                                                        'dd/mm/yyyy');
                                             num_err :=
                                                f_recries(p_ctipreb, p_sseguro, NULL, pfemisio,
                                                          fcarantnueva, fcarpronueva, 3,
                                                          nanualinueva, nfraccinueva,
                                                          p_ccobban, NULL, ppsproces, 21, 'R',
                                                          modcom, fcaranunueva, NULL, pcmovimi,
                                                          pempresa, movimiento, 1, pnimport2);

                                             -- Fi Bug 19777/95194 - 26/10/2011 -AMC
                                             IF num_err <> 0 THEN
                                                algun_error := 1;
                                                indice_error := indice_error + 1;
                                             END IF;
                                          END IF;
                                       END IF;
                                    END IF;
                                 END IF;
                              END IF;
                           ELSE
                              algun_error := 1;
                              indice_error := indice_error + 1;
                           END IF;
                        END IF;
                     END IF;
                  END IF;
               ELSE   -- NO RENOVACIÓN, SÓLO RECIBO
                  ----Llamamos la función que actualiza datos de la próxima cartera-----
                  num_err := f_acproxcar(p_sseguro, fcarantnueva, fcarpronueva, fcaranunueva,
                                         nanualinueva, nfraccinueva, frenovanueva);

                  IF num_err <> 0 THEN
                     algun_error := 1;
                     indice_error := indice_error + 1;
                  ELSE
                     BEGIN
                        UPDATE seguros
                           SET fcarant = fcarantnueva,
                               fcarpro = fcarpronueva,
                               fcaranu = fcaranunueva,
                               nanuali = nanualinueva,
                               nfracci = nfraccinueva,
                               frenova = frenovanueva
                         WHERE sseguro = p_sseguro;
/*
                                       INSERT INTO carteraaux VALUES (ppsproces,
                                                                   p_sseguro,
                                                                   fcarantnueva,
                                                                   fcarpronueva,
                                                                   fcaranunueva,
                                                                   nanualinueva,
                                                                   nfraccinueva,
                                                                   null); */
                     EXCEPTION
                        WHEN OTHERS THEN
                           num_err := 102361;
                           algun_error := 1;
                           indice_error := indice_error + 1;
                     END;

                     -- No se genera movimiento de seguro. Se busca
                     -- el último movimiento vigente
                     num_err := f_buscanmovimi(p_sseguro, 1, 1, pnmovimi2);

                     IF num_err <> 0 THEN
                        algun_error := 1;
                        indice_error := indice_error + 1;
                     ELSE
                        IF p_cagrpro = 2 THEN
                           pcmovimi := 2;   -- indica aportación periódica
                        ELSE
                           pcmovimi := NULL;
                        END IF;

                        --Llamamos la función de calcular recibos
                        vfemisio := TO_DATE('1/' || TO_CHAR(TO_NUMBER(pmes)) || '/'
                                            || TO_CHAR(panyo),
                                            'dd/mm/yyyy');

                        -- Se mira si es nueva producción o cartera para
                        -- aplicar como modo de comision un 1 o un 2
                        IF f_es_renovacion(p_sseguro) = 0 THEN   -- es cartera
                           modcom := 2;
                        ELSE   -- si es 1 es nueva produccion
                           modcom := 1;
                        END IF;

                        num_err := f_recries(p_ctipreb, p_sseguro, NULL, vfemisio,
                                             fcarantnueva, fcarpronueva, 3, nanualinueva,
                                             nfraccinueva, p_ccobban, NULL, ppsproces, 22, 'R',
                                             modcom, fcaranunueva, NULL, pcmovimi, pempresa,
                                             pnmovimi2, 1, pnimport2);

                        IF num_err <> 0 THEN
                           algun_error := 1;
                           indice_error := indice_error + 1;
                        END IF;
                     END IF;
                  END IF;
               END IF;
--            ELSE
--                EXIT;
            END IF;

            IF algun_error = 0 THEN
               -- Se borran los registros de GARANCAR
               BEGIN
                  DELETE FROM garancar
                        WHERE sseguro = p_sseguro;
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

               -- Se graba el seguro en la tabla SEGCARTERA
               num_err := f_inssegcartera(ppsproces, p_sseguro, p_fcarpro, p_fcaranu,
                                          p_fcarant, p_nanuali, p_nfracci);

               IF num_err <> 0 THEN
                  algun_error := 1;
                  indice_error := indice_error + 1;
               ELSE
                  pcorrecte := 1;
                  p_fcarant := fcarantnueva;
                  p_fcarpro := fcarpronueva;
                  p_fcaranu := fcaranunueva;
                  p_nanuali := nanualinueva;
                  p_nfracci := nfraccinueva;
               END IF;
            END IF;
         END LOOP;
      END IF;

      RETURN num_err;
   END;

   FUNCTION f_garantarifa(
      pmoneda IN NUMBER,
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pcobjase IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pctipo IN NUMBER,
      pnduraci IN NUMBER,
      conta_proces IN NUMBER,
      pcdurcob IN NUMBER,
      pfcarpro IN DATE,
      pmes IN VARCHAR2,
      panyo IN NUMBER,
      tipo IN NUMBER,
      pcagrpro IN NUMBER,
      pcmanual IN NUMBER,
      pcactivi IN NUMBER,
      num_risc IN NUMBER,
      pfemisio IN DATE,
      movimiento OUT NUMBER,
      anulado OUT NUMBER)
      RETURN NUMBER IS
/****************************************************************************
    F_CSUBPRO: 1.- Revaloriza el seguro
             2.- Tarifica
             3.- Grabamos en GARANCAR
        - Desaparece GARANCOLEC
          Modificamos la tarificación de hogar y de comercio.
        Añadimos el coaseguro
                Se cambia la revalorización de las garantías
                que depende de las demás contratadas.
                Se añade caso de ctarman=3
    Si la tarifa es manual también calcula descuentos y sobreprimas
             Se añade el parámetro ptarifar en f_tarifas, para distinguir las
             pólizas que vuelven a tarifar, o sólo revalorizan prima y calculan
             descuentos y recargos por las preguntas
****************************************************************************/
      num_err        NUMBER;
      prevcap        NUMBER;
      piprima        NUMBER;
      psperson       NUMBER;
      texto          VARCHAR2(80);
      total_prima2   NUMBER;
      riesg_ant      NUMBER;
      num_reg        NUMBER;
      registros      NUMBER;
      estat_garan    VARCHAR2(20);
      tecnico        garanpro.ctecnic%TYPE;   --       tecnico        NUMBER;   -- Si hay descuento tecnico --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      porcen         coacuadro.ploccoa%TYPE;   --       porcen         NUMBER;   -- Porcentaje del coaseguro --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      -- Ini Bug 21907 - MDS - 03/05/2012
      pidtotec       garancar.idtotec%TYPE := 0;   --       pidtotec       NUMBER := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pireccom       garancar.ireccom%TYPE := 0;   --       pireccom       NUMBER := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---

      -- Fin Bug 21907 - MDS - 03/05/2012

      --  Para calcular la nueva prima cogeremos la prima total en vez
--  de la local
      CURSOR c_garanseg IS
         SELECT   sseguro, cgarant, nriesgo, nmovimi, finiefe, norden, ctarifa,
                  icaptot icapital, precarg, ipritot iprianu, ffinefe, cformul, iextrap,
                  ctipfra, ifranqu, irecarg, idtocom, pdtocom, ipritar, crevali, prevali,
                  irevali, itarifa, itarrea, ftarifa
             FROM garanseg
            WHERE sseguro = psseguro
              AND ffinefe IS NULL
         ORDER BY nriesgo;

      CURSOR c_garancar IS
         SELECT   sseguro, cgarant, nriesgo, finiefe, norden, ctarifa, icapital, precarg,
                  iprianu, ffinefe, cformul, iextrap, sproces, ctipfra, ifranqu, irecarg,
                  ipritar, idtocom, pdtocom, crevali, prevali, irevali, itarifa, itarrea,
                  ftarifa,
                          -- Ini Bug 21907 - MDS - 03/05/2012
                          pdtotec, preccom, idtotec, ireccom
             -- FIN Bug 21907 - MDS - 03/05/2012
         FROM     garancar
            WHERE sseguro = psseguro
              AND sproces = conta_proces
         ORDER BY nriesgo;

      reg            c_garanseg%ROWTYPE;
      regcar         c_garancar%ROWTYPE;
      ppsproces      garancar.ipritar%TYPE := conta_proces;   --       ppsproces      NUMBER := conta_proces; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pctipcap       NUMBER;
      ppctipcap      NUMBER;
      pcgardep       NUMBER;
      preg1          NUMBER;
      preg2          NUMBER;
      preg3          NUMBER;
      preg4          NUMBER;
      preg5          NUMBER;
      preg6          NUMBER;
      preg7          NUMBER;
      preg8          NUMBER;
      preg9          NUMBER;
      preg10         NUMBER;
      preg11         NUMBER;
      preg12         NUMBER;
      preg13         NUMBER;
      total_prima    NUMBER := 0;
      piprianu       garancar.cformul%TYPE := 0;   --       piprianu       NUMBER := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pipritar       garancar.idtocom%TYPE := 0;   --       pipritar       NUMBER := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      tasa           garancar.ipritot%TYPE := 0;   --       tasa           NUMBER := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pirecarg       garancar.irecarg%TYPE := 0;   --       pirecarg       NUMBER := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pidtocom       garancar.prevali%TYPE := 0;   --       pidtocom       NUMBER := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      prima          garancar.iprianu%TYPE := 0;   --       prima          NUMBER := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      prevprima      NUMBER;
      pnnumlin       NUMBER;
      garantia       garancar.cgarant%TYPE;   --       garantia       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      indicador      VARCHAR2(20);
      cant_riesgos   NUMBER;
      formpag        seguros.cforpag%TYPE;   --       formpag        NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      capit          garancar.icapital%TYPE;   --       capit          NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      tot_prima      NUMBER;
      forpag2        seguros.cforpag%TYPE;   --       forpag2        NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      gar_excep      NUMBER;   --Garantía que se revaloriza
      --dependiendo del resto, como un 10%
      suma_excep     NUMBER;   --Suma de las primas del resto de las garantías
      capmax         NUMBER;   --Capital máximo de la garantía según producto
      capmin         NUMBER;   --Capital mínimo de la garantía según producto
      wprima         NUMBER;
      ptarifar       NUMBER;
      old_riesgo     NUMBER;
      lfactor        NUMBER;
      vsproduc       seguros.sproduc%TYPE;   --       vsproduc       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_extraprima   NUMBER;   -- BUG19532:DRA:26/09/2011
   BEGIN
      ---Abrimos el cursor
      OPEN c_garanseg;

      LOOP
         FETCH c_garanseg
          INTO reg;

         EXIT WHEN c_garanseg%NOTFOUND;
         -- Miramos si se tiene que anular la garantía por la edad.
         -- Si fuera así en la función anuledad ya se anula
         num_err := pac_cartera.f_anuledad(psseguro, reg.nriesgo, reg.cgarant, reg.nmovimi,
                                           reg.finiefe, pfcarpro, pcramo, pcmodali, pctipseg,
                                           pccolect, pcobjase, 'R', NULL, NULL, estat_garan);   --paramters null perque compili

         IF num_err <> 0 THEN
            IF c_garanseg%ISOPEN THEN
               CLOSE c_garanseg;
            END IF;

            RETURN num_err;
         ELSE
            IF estat_garan = 'NO_CAMBIADA' THEN   -- si la garantía no se anula por la edad
               -- Ya no se criba si el seguro tiene revalorización, porque se hace
               -- por garantía no por seguro.
                  -- En los productos de ahorro solo se revaloriza
               -- la prima periodica (cgarant = 48);
               IF pcagrpro <> 2
                  OR(pcagrpro = 2
                     AND reg.cgarant = 48)
                  OR(pcagrpro = 2
                     AND pcmodali <> 1) THEN
                  -- Si es forma de pago única no revaloriza
                  BEGIN
-- NUNU : TREURE SELECT
                     SELECT cforpag
                       INTO forpag2
                       FROM seguros
                      WHERE sseguro = psseguro;
                  EXCEPTION
                     WHEN OTHERS THEN
                        NULL;
                  END;

                  IF forpag2 <> 0 THEN
                     -- Se debe pasar la IPRITAR , pero como hay garantías
                     -- mal con ipritar = 0 , si es así se pone IPRIANU
                     IF reg.ipritar = 0 THEN
                        wprima := reg.iprianu;
                     ELSE
                        wprima := reg.ipritar;
                     END IF;

                     --Llamamos la rutina f_revalgar-----------
                     num_err := f_revalgar(psseguro, pcmanual, reg.cgarant, pcactivi, pcramo,
                                           pcmodali, pctipseg, pccolect, reg.icapital, wprima,
                                           reg.crevali, reg.irevali, reg.prevali,
                                           TO_NUMBER(pmes), panyo, prevcap, prevprima, lfactor);
                  ELSE
                     prevcap := reg.icapital;
                  END IF;
               ELSE   -- no se revaloriza pero se pone el mismo parametro
                  -- para llamar a f_tarifar
                  prevcap := reg.icapital;
               END IF;

               IF num_err <> 0 THEN
                  IF c_garanseg%ISOPEN THEN
                     CLOSE c_garanseg;
                  END IF;

                  RETURN num_err;
               ELSE
                  --- Se mira si la tarifa es automática o manual
                  IF pcmanual = 1 THEN   --si la tarifa es manual
                     piprianu := prevprima;
                     pipritar := prevprima;
                  ELSIF pcmanual = 3 THEN   -- Manual, pero revaloriza también el capital
                     piprianu := prevprima;
                     pipritar := prevprima;
                  -- prevcap toma el valor que devuelve la funcion
                  ELSIF pcmanual IN(0, 2) THEN   -- si la tarifa es automática o es automática
                     -- pero revaloriza también la prima en cartera
                     IF pcmanual = 2 THEN   -- Automática, pero revaloriza también el capital
                        piprianu := prevprima;
                        pipritar := prevprima;
                        -- prevcap toma el valor que devuelve la funcion
                        ptarifar := 0;   -- en las funciones de tarifas, no pasará por f_tarifas
                     ELSE
                        ptarifar := 1;   -- en las funciones que calculan la tarifa,
                     -- no pasará por la función f_tarifas
                     END IF;

                     -- Si es fórmula tendra el mismo iprianu
                                             -- Tiene que ser ipritar para que no calcule
                                             --el descuento dos veces.
                     IF reg.cformul IS NOT NULL THEN
                        IF reg.cformul = 1 THEN
                           piprianu := reg.ipritar;
                           pipritar := reg.ipritar;
                        END IF;
                     ELSE
                        -- Buscamos el campo CTECNIC de Garanpro
                        BEGIN
                           SELECT ctecnic
                             INTO tecnico
                             FROM garanpro
                            WHERE cramo = pcramo
                              AND cmodali = pcmodali
                              AND ccolect = pccolect
                              AND ctipseg = pctipseg
                              AND cgarant = reg.cgarant
                              AND cactivi = pcactivi;
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              BEGIN
                                 SELECT ctecnic
                                   INTO tecnico
                                   FROM garanpro
                                  WHERE cramo = pcramo
                                    AND cmodali = pcmodali
                                    AND ccolect = pccolect
                                    AND ctipseg = pctipseg
                                    AND cgarant = reg.cgarant
                                    AND cactivi = 0;
                              EXCEPTION
                                 WHEN OTHERS THEN
                                    tecnico := 0;
                              END;
                        END;

                        --Llamamos la función f_tarifar
                        num_err := f_tarifar(pmoneda, psseguro, pcramo, pcmodali, pctipseg,
                                             pccolect, reg.nriesgo, pcobjase, reg.ctarifa,
                                             reg.cformul, prevcap, reg.precarg, reg.iextrap,
                                             pnduraci, pcdurcob, pctipo, pcagrpro, pipritar,
                                             tasa, piprianu, pcactivi, num_risc, pfcarpro,
                                             tecnico, ptarifar, pcmanual, pmes, panyo);

                        IF num_err <> 0 THEN
                           IF c_garanseg%ISOPEN THEN
                              CLOSE c_garanseg;
                           END IF;

                           RETURN num_err;
                        END IF;
                     END IF;   --de si cformul not null
                  END IF;   --de si tarifa automática

                  ---Introducimos los datos en la tabla GARANCAR
                  BEGIN
                     INSERT INTO garancar
                                 (sseguro, cgarant, nriesgo, finiefe,
                                  norden, ctarifa, icapital,
                                  precarg, iprianu, ffinefe, cformul, iextrap,
                                  ctipfra, ifranqu, sproces, irecarg, ipritar,
                                  pdtocom, idtocom, crevali, irevali,
                                  prevali, itarifa, itarrea, ipritot, icaptot, ftarifa)
                          VALUES (psseguro, reg.cgarant, NVL(reg.nriesgo, 0), pfcarpro,
                                  reg.norden, reg.ctarifa, NVL(prevcap, reg.icapital),
                                  reg.precarg, piprianu, NULL, reg.cformul, reg.iextrap,
                                  reg.ctipfra, reg.ifranqu, ppsproces, reg.irecarg, pipritar,
                                  reg.pdtocom, pidtocom, reg.crevali, reg.irevali,
                                  reg.prevali, tasa, NULL, NULL, NULL, reg.ftarifa);
                  EXCEPTION
                     WHEN OTHERS THEN
                        IF c_garanseg%ISOPEN THEN
                           CLOSE c_garanseg;
                        END IF;

                        RETURN 101998;
                  END;
               END IF;
            END IF;
         END IF;   --de si estat_garan = 'NO_CAMBIADA'

         riesg_ant := reg.nriesgo;
      END LOOP;

      CLOSE c_garanseg;

      --Hemos grabado las garantías que no se anulan en GARANCAR.
      -- Ahora tenemos que mirar si se anula algun riesgo o el seguro
      num_err := pac_cartera.f_anular(psseguro, pfcarpro, conta_proces, pfcarpro, pfemisio,
                                      movimiento, anulado);

      IF anulado = 0 THEN   -- si el seguro no se ha anulado THEN
-----------------------------------------------------------------------------
        -- Se hace sólo si la tarifa es automática.
        -- Si revaloriza
         IF pcmanual IN(0, 2) THEN
            -- La modalidad se controla en tarllar2 y tarcom2
            IF tipo = 3
               OR tipo = 4 THEN
               old_riesgo := 0;

               OPEN c_garancar;

               LOOP
                  FETCH c_garancar
                   INTO regcar;

                  EXIT WHEN c_garancar%NOTFOUND;
                  buscar_respue(preg1, preg2, preg3, preg4, preg5, preg6, preg7, preg8, preg9,
                                preg10, preg11, preg12, preg13, psseguro, tipo, pcmodali,
                                regcar.nriesgo, pcagrpro, num_risc);

                  --Se recorre la tabla GARANCAR para hacer la suma de las
                  --primas en el caso del hogar y de los comercios y aplicar los descuentos
                  --pertinentes
                          -- El cálculo de la prima total se calcula para cada riesgo
                          -- una única vez antes de que se aplique ningún descuento.
                  IF regcar.nriesgo <> old_riesgo THEN
                     SELECT SUM(iprianu)
                       INTO total_prima
                       FROM garancar
                      WHERE sseguro = psseguro
                        AND nriesgo = regcar.nriesgo
                        AND sproces = conta_proces;

                     old_riesgo := regcar.nriesgo;
                  END IF;

                  BEGIN
                     SELECT ctecnic
                       INTO tecnico
                       FROM garanpro
                      WHERE cramo = pcramo
                        AND cmodali = pcmodali
                        AND ccolect = pccolect
                        AND ctipseg = pctipseg
                        AND cgarant = regcar.cgarant
                        AND cactivi = pcactivi;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        BEGIN
                           SELECT ctecnic
                             INTO tecnico
                             FROM garanpro
                            WHERE cramo = pcramo
                              AND cmodali = pcmodali
                              AND ccolect = pccolect
                              AND ctipseg = pctipseg
                              AND cgarant = regcar.cgarant
                              AND cactivi = 0;
                        EXCEPTION
                           WHEN OTHERS THEN
                              tecnico := 0;
                        END;
                  END;

                  IF tipo = 3 THEN
                     piprianu := regcar.iprianu;
                     pipritar := regcar.ipritar;
                     num_err := f_tarllar2(regcar.ctarifa, total_prima, NVL(preg1, preg4),
                                           preg7, preg8, tecnico, pcmodali, ptarifar,
                                           pipritar, tasa, piprianu, pmoneda);
                  ELSE
                     piprianu := regcar.iprianu;
                     pipritar := regcar.ipritar;
                     num_err := f_tarcom2(regcar.ctarifa, total_prima, preg9, tecnico,
                                          pcmodali, pctipseg, ptarifar, pipritar, tasa,
                                          piprianu, pmoneda);
                  END IF;

                  IF num_err <> 0 THEN
                     IF c_garancar%ISOPEN THEN
                        CLOSE c_garancar;
                     END IF;

                     RETURN num_err;
                  ELSE
                     ---Modificamos la tabla GARANCAR con las primas nuevas
                     BEGIN
                        UPDATE garancar
                           SET iprianu = piprianu,
                               ipritar = pipritar
                         WHERE sseguro = psseguro
                           AND cgarant = regcar.cgarant
                           AND nriesgo = regcar.nriesgo
                           AND finiefe = regcar.finiefe
                           AND sproces = regcar.sproces;
                     EXCEPTION
                        WHEN OTHERS THEN
                           IF c_garancar%ISOPEN THEN
                              CLOSE c_garancar;
                           END IF;

                           RETURN 101998;
                     END;
                  END IF;
               END LOOP;

               CLOSE c_garancar;
            END IF;

            verifica_tarifa(psseguro, pcramo, pcmodali, pctipseg, pccolect, ppsproces);

-----------------------------------------------------------------------------
            -- Realitzem un tercer bucle per calcular els descomptes
            --  despres d'haver tingut en compte les respostes de les preguntes)
            OPEN c_garancar;

            LOOP
               FETCH c_garancar
                INTO regcar;

               EXIT WHEN c_garancar%NOTFOUND;
               --buscar_respue(preg1, preg2, preg3, preg4, preg5, preg6, preg7,
               --    preg8, preg9, preg10, preg11,psseguro, tipo, pcmodali,
               --    reg.nriesgo,pcsubpro,pcagrpro);
               prima := regcar.iprianu;
               -- Bug 21907 - MDS - 03/05/2012
               -- añadir parámetros nuevos : regcar.pdtotec, regcar.preccom, pidtotec, pireccom
               num_err := f_recdto(regcar.precarg, regcar.pdtocom, pirecarg, pidtocom,
                                   regcar.pdtotec, regcar.preccom, pidtotec, pireccom,   -- Bug 21907 - MDS - 03/05/2012
                                   regcar.iextrap, regcar.icapital, v_extraprima,   -- BUG19532:DRA:26/09/2011
                                   prima, pmoneda, NULL, NULL, NULL, NULL, vsproduc);   --DCT 02/12/2014

               IF num_err <> 0 THEN
                  IF c_garancar%ISOPEN THEN
                     CLOSE c_garancar;
                  END IF;

                  RETURN num_err;
               ELSE
                  ---Modificamos la tabla GARANCAR con las primas nuevas
                  -- Se redondea la prima por la forma de pago
                  BEGIN
                     SELECT cforpag, sproduc
                       INTO formpag, vsproduc
                       FROM seguros
                      WHERE sseguro = psseguro;

                     UPDATE garancar
                        SET irecarg = pirecarg,
                            idtocom = pidtocom,
                            idtotec = pidtotec,   -- Bug 21907 - MDS - 03/05/2012
                            ireccom = pireccom,   -- Bug 21907 - MDS - 03/05/2012
                            iprianu = f_round_forpag(prima, formpag, pmoneda, vsproduc)
                      WHERE sseguro = psseguro
                        AND cgarant = regcar.cgarant
                        AND nriesgo = regcar.nriesgo
                        AND finiefe = regcar.finiefe
                        AND sproces = regcar.sproces;
                  EXCEPTION
                     WHEN OTHERS THEN
                        IF c_garancar%ISOPEN THEN
                           CLOSE c_garancar;
                        END IF;

                        RETURN 101998;
                  END;
               END IF;
            END LOOP;

            CLOSE c_garancar;

-----------------------------------------------------------------------------
            -- Controlem els productes de ESTALVI
            -- La aport. periód. ya no está en una pregunta
            -- sino en cgarant = 48;
            -- Controlamos también los UNIT LINK.
            IF (pcagrpro = 2
                AND pcmodali = 1)
               OR pcagrpro = 21 THEN
               --    buscar_respue(preg1, preg2, preg3, preg4, preg5, preg6, preg7,
               --        preg8, preg9, preg10, preg11,psseguro, tipo, pcmodali,
               --        reg.nriesgo,pcagrpro,num_risc);
               --    piprianu := preg11 - total_prima;
               -- Se cambia. Ya no se multiplica por la forma
               -- de pago, se graba con la prima anual
                   -- Calculamos la prima grabada hasta ahora (sólo tenemos la prima
                   -- de muerte, la garantía 48 de momento no tiene prima, la calculamos ahora)
               SELECT SUM(iprianu)
                 INTO tot_prima
                 FROM garancar
                WHERE sseguro = psseguro
                  AND sproces = conta_proces;

               -- Miramos cual es la forma de pago
               SELECT DECODE(cforpag, 0, 1, cforpag)
                 INTO formpag
                 FROM seguros
                WHERE sseguro = psseguro;

               -- En capital tenemos informado la aportación no anual
               SELECT icapital
                 INTO capit
                 FROM garancar
                WHERE sseguro = psseguro
                  AND sproces = conta_proces
                  AND cgarant = 48;

               -- la prima anual de la garantía 48 será la aportación anual menos la prima de las
               -- otras garantías contratadas.
               piprianu := (capit * formpag) - tot_prima;

               BEGIN
                  UPDATE garancar
                     SET iprianu = piprianu
                   WHERE sseguro = psseguro
                     AND sproces = conta_proces
                     AND cgarant = 48;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 101998;
               END;
            END IF;
         -- Si la tarifa es manual también se calculan descuentos y sobreprimas
         ELSE   -- si la tarifa es manual
            --  Realitzem un bucle per calcular els descomptes
            OPEN c_garancar;

            LOOP
               FETCH c_garancar
                INTO regcar;

               EXIT WHEN c_garancar%NOTFOUND;
               --buscar_respue(preg1, preg2, preg3, preg4, preg5, preg6, preg7,
               --    preg8, preg9, preg10, preg11,psseguro, tipo, pcmodali,
               --    reg.nriesgo,pcsubpro,pcagrpro);
               prima := regcar.iprianu;
               -- Bug 21907 - MDS - 03/05/2012
               -- añadir parámetros nuevos : regcar.pdtotec, regcar.preccom, pidtotec, pireccom
               num_err := f_recdto(regcar.precarg, regcar.pdtocom, pirecarg, pidtocom,
                                   regcar.pdtotec, regcar.preccom, pidtotec, pireccom,   -- Bug 21907 - MDS - 03/05/2012
                                   regcar.iextrap, regcar.icapital, v_extraprima,   -- BUG19532:DRA:26/09/2011
                                   prima, pmoneda, NULL, NULL, NULL, NULL, vsproduc);   --DCT 02/12/2014

               IF num_err <> 0 THEN
                  IF c_garancar%ISOPEN THEN
                     CLOSE c_garancar;
                  END IF;

                  RETURN num_err;
               ELSE
                  ---Modificamos la tabla GARANCAR con las primas nuevas
                  -- Se redondea la prima por la forma de pago
                  BEGIN
                     SELECT cforpag, sproduc
                       INTO formpag, vsproduc
                       FROM seguros
                      WHERE sseguro = psseguro;

                     UPDATE garancar
                        SET irecarg = pirecarg,
                            idtocom = pidtocom,
                            iprianu = f_round_forpag(prima, formpag, pmoneda, vsproduc)
                      WHERE sseguro = psseguro
                        AND cgarant = regcar.cgarant
                        AND nriesgo = regcar.nriesgo
                        AND finiefe = regcar.finiefe
                        AND sproces = regcar.sproces;
                  EXCEPTION
                     WHEN OTHERS THEN
                        IF c_garancar%ISOPEN THEN
                           CLOSE c_garancar;
                        END IF;

                        RETURN 101998;
                  END;
               END IF;
            END LOOP;

            CLOSE c_garancar;
         END IF;   -- de cmanual = 0 , si la tarifa es automática

        -- Se mira a ver si tiene contratada la garantía 241. Si es
        -- así la prima de esta garantía es el 10% de la suma de las que tiene
        -- hasta ahora
        -- Se añaden las garantias 9843 y la 9852
        -- Añadimos la garantia 281
        -- Se sabe que las garantías no pueden estar a la vez en la misma póliza(producto)
/*        BEGIN
            SELECT cgarant INTO garantia
            FROM GARANCAR
            WHERE cgarant in (241,281,9843,9852)
            AND sseguro = psseguro
            AND sproces = conta_proces;
            indicador := 'CONTRATADA';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                indicador := 'NO_CONTRATADA';
        END;
        IF indicador = 'CONTRATADA' THEN
            SELECT sum(iprianu) INTO total_prima2
            FROM GARANCAR
            WHERE sseguro = psseguro
            AND sproces = conta_proces
            AND cgarant not in (241,281,9843,9852);
            prima := f_round_forpag(0.10*(NVL(total_prima2,0)),formpag,pmoneda);
            -- Se controla un máximo y un mímino de la prima.
            -- Se busca el máximo y el mínimo en GARANPRO.
            -- Se deja como estaba
            IF prima > 6000 THEN
                prima := 6000;
            ELSIF prima < 2500 THEN
                prima := 2500;
            END IF;
            ---Modificamos la tabla GARANCAR con la prima nueva
            BEGIN
                UPDATE GARANCAR SET
                iprianu = prima
                WHERE sseguro = psseguro
                AND cgarant = garantia
                AND sproces = conta_proces;
            EXCEPTION
                WHEN OTHERS THEN
                    RETURN 101998;
            END;
        END IF;
*/
         DECLARE
            --Creamos un Cursor porque podemos tener estas garantias en varios riesgos
            CURSOR garancar_esp IS
               SELECT nriesgo, cgarant, finiefe
                 FROM garancar
                WHERE cgarant IN(241, 281, 9843, 9852)
                  AND sseguro = psseguro
                  AND sproces = conta_proces;
         BEGIN
            FOR aux IN garancar_esp LOOP
               BEGIN
                  SELECT cgarant
                    INTO garantia
                    FROM garancar
                   WHERE cgarant IN(241, 281, 9843, 9852)
                     AND sseguro = psseguro
                     AND sproces = conta_proces
                     AND nriesgo = aux.nriesgo;

                  indicador := 'CONTRATADA';
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     indicador := 'NO_CONTRATADA';
               END;

               IF indicador = 'CONTRATADA' THEN
                  SELECT SUM(g.iprianu), s.sproduc
                    INTO total_prima2, vsproduc
                    FROM garancar g, seguros s
                   WHERE g.sseguro = psseguro
                     AND g.sseguro = s.sseguro
                     AND g.sproces = conta_proces
                     AND g.cgarant NOT IN(241, 281, 9843, 9852)
                     AND g.nriesgo = aux.nriesgo;

                  prima := f_round_forpag(0.10 *(NVL(total_prima2, 0)), formpag, pmoneda,
                                          vsproduc);

                  -- Se controla un máximo y un mímino de la prima.
                  -- Se busca el máximo y el mínimo en GARANPRO.
                  IF prima > 6000 THEN
                     prima := 6000;
                  ELSIF prima < 2500 THEN
                     prima := 2500;
                  END IF;

                  ---Modificamos la tabla GARANCAR con la prima nueva
                  BEGIN
                     UPDATE garancar
                        SET iprianu = prima
                      WHERE sseguro = psseguro
                        AND cgarant = garantia
                        AND sproces = conta_proces
                        AND nriesgo = aux.nriesgo;
                  EXCEPTION
                     WHEN OTHERS THEN
                        RETURN 101998;
                  END;
               END IF;
            END LOOP;
         END;

         -- Se calcula el porcentaje para coaseg. cedido y aceptado
         BEGIN
            SELECT c.ploccoa
              INTO porcen
              FROM coacuadro c, seguros s
             WHERE c.sseguro = s.sseguro
               AND c.ncuacoa = s.ncuacoa
               AND s.ctipcoa <> 0
               AND s.sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               porcen := 100;   -- No hay coaseguro cedido
         END;

         num_err := f_garancoa('P', porcen, psseguro);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;   -- de anulado = 0, si no se ha anulado el seguro

      RETURN 0;
   END;

   FUNCTION f_traspasgar(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pdata IN DATE,
      pnmovimi IN NUMBER)
      RETURN NUMBER IS
/***********************************************************************
    F_COMPCAR : Se traspasan los registros grabados en GARANCAR a
            GARANSEG y se informa ffinefe de los últimos registros de
            GARANSEG
    ALLIBCTR - Gestión de datos referentes a los seguros
***********************************************************************/
   BEGIN
      --Primero modificamos ffinefe de GARANSEG
      BEGIN
         UPDATE garanseg
            SET ffinefe = pdata
          WHERE sseguro = psseguro
            AND ffinefe IS NULL;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101959;   --Error al modificar en GARANSEG
      END;

      --Insertamos en GARANSEG los registros de GARANCAR
      BEGIN
         INSERT INTO garanseg
                     (sseguro, cgarant, nriesgo, nmovimi, finiefe, norden, ctarifa, icapital,
                      precarg, iprianu, ffinefe, cformul, iextrap, ctipfra, ifranqu, irecarg,
                      idtocom, pdtocom, ipritar, crevali, prevali, irevali, itarifa, itarrea,
                      icaptot, ipritot, ftarifa,
                                                -- Ini Bug 21907 - MDS - 03/05/2012
                                                pdtotec, preccom, idtotec, ireccom
                                                                                  -- Fin Bug 21907 - MDS - 03/05/2012
                     )
            (SELECT sseguro, cgarant, nriesgo, pnmovimi, finiefe, norden, ctarifa, icapital,
                    precarg, iprianu, ffinefe, cformul, iextrap, ctipfra, ifranqu, irecarg,
                    idtocom, pdtocom, ipritar, crevali, prevali, irevali, itarifa, itarrea,
                    icaptot, ipritot, ftarifa,
                                              -- Ini Bug 21907 - MDS - 03/05/2012
                                              pdtotec, preccom, idtotec, ireccom
               -- Fin Bug 21907 - MDS - 03/05/2012
             FROM   garancar
              WHERE sseguro = psseguro
                AND sproces = psproces);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101959;
      END;

      RETURN 0;
   END;

   FUNCTION f_tarifar(
      pmoneda IN NUMBER,
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pnriesgo IN NUMBER,
      pcobjase IN NUMBER,
      pctarifa IN NUMBER,
      pcformul IN NUMBER,
      picapital IN NUMBER,
      pprecarg IN NUMBER,
      piextrap IN NUMBER,
      pnduraci IN NUMBER,
      pndurcob IN NUMBER,
      tipo IN NUMBER,
      pcagrpro IN NUMBER,
      pipritar IN OUT NUMBER,
      tasa OUT NUMBER,
      piprianu IN OUT NUMBER,
      pcactivi IN NUMBER,
      num_risc IN NUMBER,
      pfcarpro IN DATE,
      ptecnic IN NUMBER,
      ptarifar IN NUMBER,
      pcmanual IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER)
      RETURN NUMBER IS
-- Añadimos preguntas y modificamos las tarifas de comercios
--    y hogar. Necesitamos un nuevo parámetro: ptecnic.
-- Añadimos el parámetro pccolect.
--              Cambiamos parámetros de f_tarllar1 y f_tarllar2.
-- Se añade el parámetro ptarifar en todas las funciones de tarifas
-- para distinguir las pólizas que tienen que volver a tarifar, y las que sólo
-- revalorizan prima, pero luego tienen que volver a calcular descuentos y recargos.
      num_err        NUMBER;
      tarifa         NUMBER;
      colum          coditarifa.ccolum%TYPE;   --       colum          NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      fila           coditarifa.cfila%TYPE;   --       fila           NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      tipatr         coditarifa.ctipatr%TYPE;   --       tipatr         NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      ttexto         VARCHAR2(100);
      preg1          NUMBER := NULL;
      preg2          NUMBER := NULL;
      preg3          NUMBER := NULL;
      preg4          NUMBER := NULL;
      preg5          NUMBER := NULL;
      preg6          NUMBER := NULL;
      preg7          NUMBER := NULL;
      preg8          NUMBER := NULL;
      preg9          NUMBER := NULL;
      preg10         NUMBER := NULL;
      preg11         NUMBER := NULL;
      preg12         NUMBER := NULL;
      preg13         NUMBER := NULL;
      primer_capital NUMBER := 0;
      edad           NUMBER;
      sexo           per_personas.csexper%TYPE;   --       sexo           NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      fecha_nacim    per_personas.fnacimi%TYPE;   --       fecha_nacim    DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      edad_media     NUMBER := 0;
      orden          NUMBER;
      cte_cto        NUMBER;
      person         riesgos.sperson%TYPE := NULL;   --       person         NUMBER := NULL; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      num_err := 0;
      -- Se buscan los datos necesarios
      -- para calcular las tarifas.
      verifica_garan(psseguro, pcramo, pcmodali, cte_cto);
      buscar_respue(preg1, preg2, preg3, preg4, preg5, preg6, preg7, preg8, preg9, preg10,
                    preg11, preg12, preg13, psseguro, tipo, pcmodali, pnriesgo, pcagrpro,
                    num_risc);

--    Buscamos la edad y el sexo del asegurado
      IF pcobjase = 1 THEN
         -- Bug 0012802 - 20/01/2010 - JMF
         SELECT p.fnacimi, p.csexper
           INTO fecha_nacim, sexo
           FROM per_personas p, riesgos r
          WHERE r.sseguro = psseguro
            AND r.nriesgo = pnriesgo
            AND r.sperson = p.sperson;

         num_err := f_difdata(fecha_nacim, pfcarpro, 2, 1, edad);

         IF pcramo = 30
            AND pcmodali = 11
            AND pctipseg = 1 THEN
            media_edad(psseguro, edad_media);
            edad := ROUND(edad_media);
         END IF;
      END IF;

      -- Para este producto la preg1 será el grupo de actividad
      -- del seguro
      --  Se vuelve a dejar la pregunta
      --IF pcramo = 40 AND pcmodali = 2 THEN
      --    preg1 := pcactivi;
      --END IF;
      -- Si es fórmula se pone el mismo iprianu que ya tenia
      -- Afegim les fórmules
      --IF pcformul IS NOT NULL THEN
      --    formulas(pcramo,pcmodali,pcformul, edad, sexo,pnduraci,
      --          pndurcob, picapital, piprianu);
      --    pipritar := piprianu;
      --ELSE
      IF pctarifa IS NOT NULL THEN
         -- Calculamos la nueva garantía aquí cuando
         -- tenemos embarcaciones
         IF preg2 = 2
            AND tipo = 5 THEN
            IF pctarifa = 123 THEN
               tarifa := 124;
                  -- No se realiza este cambio para embarcaciones (alctr111)
            --    ELSIF pctarifa IN (125, 126, 127, 128) THEN
            --        tarifa := pctarifa + 5;
            ELSE
               tarifa := pctarifa;
            END IF;
         ELSE
            tarifa := pctarifa;
         END IF;

         -- Afegim les noves funcions per calcular les tarifas
         BEGIN
            SELECT ccolum, cfila, ctipatr
              INTO colum, fila, tipatr
              FROM coditarifa
             WHERE ctarifa = tarifa;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               num_err := 100569;
         END;

         IF tipo = 1 THEN
            num_err := f_tarvida(tarifa, colum, fila, tipatr, picapital, piextrap, edad, sexo,
                                 preg1, preg2, preg3, ptarifar, pipritar, tasa, piprianu,
                                 pmoneda);
         ELSIF tipo = 2 THEN
            num_err := f_taracci(tarifa, colum, fila, tipatr, picapital, piextrap, edad,
                                 preg1, preg2, preg3, preg4, preg5, preg6, preg7, ptecnic,
                                 ptarifar, pipritar, tasa, piprianu, pmoneda);
         ELSIF tipo = 3 THEN
            -- Afagim nous paràmetres per comunitats (cmodali=3)
            -- La resposta de la 37 està en preg10
                ---Para el caso de tarifas de hogar-----
            IF tarifa = 59 THEN
               SELECT sperson
                 INTO person
                 FROM riesgos
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND fanulac IS NULL;
            END IF;

            IF person IS NULL THEN
               IF pcmodali = 3 THEN
                  -- Calculamos la suma del capital de las garantías básicas
                  -- del producto 13-3-0-0 para luego pasarselo a f_tarifar
                  verifica_tarifa_comunidades(pcramo, pcmodali, pctipseg, pccolect, psseguro,
                                              pnriesgo, pcmanual, pcactivi, pmes, panyo,
                                              primer_capital);
               END IF;

               num_err := f_tarllar1(tarifa, colum, fila, tipatr, picapital, piextrap, preg1,
                                     preg2, preg3, preg4, preg5, preg6, preg9, preg1, preg2,
                                     preg3, preg4, preg5, preg6, preg7, preg10, preg11, preg12,
                                     cte_cto, ptecnic, pcmodali, primer_capital, ptarifar,
                                     pipritar, tasa, piprianu, pmoneda);
            END IF;
         -- Afegim la funció pels comerços
         -- Afegim nous camps i tenim en compte la modalitat
         ELSIF tipo = 4 THEN
            num_err := f_tarcom1(tarifa, colum, fila, tipatr, picapital, piextrap, preg1,
                                 preg2, preg3, preg4, preg5, preg6, preg7, preg8, preg9,
                                 preg10, preg11, preg2, preg3, cte_cto, pcmodali, ptecnic,
                                 ptarifar, pipritar, tasa, piprianu, pmoneda);
         -- Afegim la funció per les embarcacions
         ELSIF tipo = 5 THEN
            num_err := f_taremb(tarifa, colum, fila, tipatr, picapital, piextrap, preg1,
                                preg2, preg3, preg4, preg5, preg6, preg7, preg8, preg9,
                                preg10, ptarifar, pipritar, tasa, piprianu, pmoneda);
         -- Afegim la funció per SALUT
         ELSIF tipo = 6 THEN
            --Se añade preg4 y pcramo como parámetros
            --Se quita preg2,preg3,preg4 y se pone icapital
            --Se añade la pregunta preg2 y preg3 (cpregun 116 y 117)
            num_err := f_tarsal(tarifa, colum, fila, tipatr, picapital, piextrap, preg1,
                                picapital, picapital, picapital, preg5, preg2, preg3,
                                pnriesgo, sexo, edad, pcramo, ptarifar, pipritar, tasa,
                                piprianu, pmoneda);
         --Afegim la funció pels transports
         ELSIF tipo = 7 THEN
            num_err := f_tartran(tarifa, colum, fila, tipatr, picapital, piextrap, preg1,
                                 preg2, preg3, preg4, preg5, preg6, preg7, preg8, preg9,
                                 ptarifar, pipritar, tasa, piprianu, pmoneda);
         -- Afegim la funció per la construcció
         ELSIF tipo = 8 THEN
            num_err := f_tarcons(tarifa, colum, fila, tipatr, picapital, piextrap, preg1,
                                 preg2, preg3, preg4, preg5, preg6, preg7, ptarifar, pipritar,
                                 tasa, piprianu, pmoneda);
         -- Afegim la funció per la resta de productes
         ELSE
            num_err := f_tardive(tarifa, colum, fila, tipatr, picapital, piextrap, preg1,
                                 preg2, preg3, pcactivi, ptarifar, pipritar, tasa, piprianu,
                                 pmoneda);
         END IF;

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      ELSE   ---Si pctarifa is null
         IF ptarifar = 1 THEN
            piprianu := 0;
            pipritar := 0;
         END IF;
      END IF;

      --END IF;  -- Del IF de las fórmulas
      RETURN 0;
   END;

   PROCEDURE buscar_respue(
      preg1 IN OUT NUMBER,
      preg2 IN OUT NUMBER,
      preg3 IN OUT NUMBER,
      preg4 IN OUT NUMBER,
      preg5 IN OUT NUMBER,
      preg6 IN OUT NUMBER,
      preg7 IN OUT NUMBER,
      preg8 IN OUT NUMBER,
      preg9 IN OUT NUMBER,
      preg10 IN OUT NUMBER,
      preg11 IN OUT NUMBER,
      preg12 IN OUT NUMBER,
      preg13 IN OUT NUMBER,
      psseguro IN NUMBER,
      tipo IN NUMBER,
      modali IN NUMBER,
      riesgo IN NUMBER,
      pcagrpro IN NUMBER,
      num_risc IN NUMBER) IS
----
---  Se añade un parámetro num_risc que nos indica el numero de
---  riesgos con garantia de accidentes.
----
----
---  Desaparece preguncolec. Por lo tanto ya no hace falta el
---  parámetro de entrada csubpro.
----
---  Añadimos dos preguntas más para hogar (113, 114)
----
---- Se añade una pregunta en accidentes (118) y dos en salud (117,118)
      CURSOR c_busc_resp_seg IS
         SELECT crespue, cpregun
           FROM pregunseg
          WHERE sseguro = psseguro
            AND nriesgo = riesgo
            AND nmovimi IN(SELECT MAX(nmovimi)
                             FROM pregunseg
                            WHERE sseguro = psseguro
                              AND nriesgo = riesgo);

--    CURSOR c_busc_resp_colec IS
--        SELECT crespue, cpregun
--        FROM PREGUNCOLEC
--        WHERE  sseguro = psseguro;
      pcrespue       NUMBER;
      pcpregun       NUMBER;
   BEGIN
      preg1 := NULL;
      preg2 := NULL;
      preg3 := NULL;
      preg4 := NULL;
      preg5 := NULL;
      preg6 := NULL;
      preg7 := NULL;
      preg8 := NULL;
      preg9 := NULL;
      preg10 := NULL;
      preg11 := NULL;
      preg12 := NULL;
      preg13 := NULL;

      OPEN c_busc_resp_seg;

      LOOP
         FETCH c_busc_resp_seg
          INTO pcrespue, pcpregun;

         EXIT WHEN c_busc_resp_seg%NOTFOUND;

         IF tipo = 1 THEN
            IF pcpregun = 1 THEN
               preg1 := pcrespue;
            ELSIF pcpregun = 5 THEN
               preg2 := pcrespue;
            ELSIF pcpregun = 109 THEN
               preg3 := pcrespue;
            END IF;
         ELSIF tipo = 2 THEN
            IF pcpregun = 2 THEN
               preg1 := pcrespue;
            ELSIF pcpregun = 3 THEN
               preg2 := pcrespue;
            ELSIF pcpregun = 4 THEN
               preg3 := pcrespue;
            ELSIF pcpregun = 5 THEN
               preg4 := pcrespue;
            -- Se quita esta pregunta
            --    ELSIF pcpregun = 13 THEN
            --            preg5 := pcrespue;
            ELSIF pcpregun = 14 THEN
               preg6 := pcrespue;
            ELSIF pcpregun = 29 THEN
               preg7 := pcrespue;
            -- Se añade esta pregunta
            ELSIF pcpregun = 118 THEN
               preg5 := pcrespue;
            END IF;
         ELSIF tipo = 3 THEN
            IF modali = 3 THEN
               preg10 := num_risc;

               IF pcpregun = 30 THEN
                  preg1 := pcrespue;
               ELSIF pcpregun = 31 THEN
                  preg2 := pcrespue;
               ELSIF pcpregun = 32 THEN
                  preg3 := pcrespue;
               ELSIF pcpregun = 33 THEN
                  preg4 := pcrespue;
               ELSIF pcpregun = 34 THEN
                  preg5 := pcrespue;
               ELSIF pcpregun = 35 THEN
                  preg6 := pcrespue;
               ELSIF pcpregun = 36 THEN
                  preg7 := pcrespue;
               END IF;
            ELSE
               IF pcpregun = 20 THEN
                  preg1 := pcrespue;
               ELSIF pcpregun = 21 THEN
                  preg2 := pcrespue;
               ELSIF pcpregun = 22 THEN
                  preg3 := pcrespue;
               ELSIF pcpregun = 23 THEN
                  preg11 := pcrespue;
               ELSIF pcpregun = 24 THEN
                  preg4 := pcrespue;
               ELSIF pcpregun = 25 THEN
                  preg5 := pcrespue;
               ELSIF pcpregun = 26 THEN
                  preg6 := pcrespue;
               ELSIF pcpregun = 27 THEN
                  preg7 := pcrespue;
               ELSIF pcpregun = 28 THEN
                  preg8 := pcrespue;
               ELSIF pcpregun = 29 THEN
                  preg9 := pcrespue;
               -- Añadimos las preguntas 113, 114
               ELSIF pcpregun = 113 THEN
                  preg11 := pcrespue;
               ELSIF pcpregun = 114 THEN
                  preg12 := pcrespue;
               END IF;
            END IF;

            -- Se sustituye la pregunta 37 por num. de riesgos con
            -- garantia de accidentes.
            preg10 := num_risc;
         ELSIF tipo = 4 THEN
            IF modali <> 2 THEN
               -- Se sustituye la pregunta 37 por num. de riesgos con
               -- garantia de accidentes.
               preg1 := num_risc;

               IF pcpregun = 38 THEN
                  preg2 := pcrespue;
               ELSIF pcpregun = 39 THEN
                  preg3 := pcrespue;
               ELSIF pcpregun = 40 THEN
                  preg4 := pcrespue;
               ELSIF pcpregun = 41 THEN
                  preg5 := pcrespue;
               ELSIF pcpregun = 42 THEN
                  preg6 := pcrespue;
               ELSIF pcpregun = 43 THEN
                  preg7 := pcrespue;
               ELSIF pcpregun = 44 THEN
                  preg8 := pcrespue;
               ELSIF pcpregun = 45 THEN
                  preg9 := pcrespue;
               ELSIF pcpregun = 46 THEN
                  preg10 := pcrespue;
               ELSIF pcpregun = 47 THEN
                  preg11 := pcrespue;
               END IF;
            ELSIF modali = 2 THEN
               IF pcpregun = 37 THEN
                  preg1 := pcrespue;
               ELSIF pcpregun = 48 THEN
                  preg2 := pcrespue;
               ELSIF pcpregun = 49 THEN
                  preg3 := pcrespue;
               ELSIF pcpregun = 45 THEN
                  preg9 := pcrespue;   --se pone en la 9 para que coincida con modalidad 1
               END IF;
            END IF;
         ----------- Afegim la tarificació per les embarcacions
         ELSIF tipo = 5 THEN
            IF pcpregun = 37 THEN
               preg1 := pcrespue;
            ELSIF pcpregun = 50 THEN
               preg2 := pcrespue;
            ELSIF pcpregun = 51 THEN
               preg3 := pcrespue;
            ELSIF pcpregun = 52 THEN
               preg4 := pcrespue;
            ELSIF pcpregun = 53 THEN
               preg5 := pcrespue;
            ELSIF pcpregun = 54 THEN
               preg6 := pcrespue;
            ELSIF pcpregun = 55 THEN
               preg7 := pcrespue;
            ELSIF pcpregun = 56 THEN
               preg8 := pcrespue;
            ELSIF pcpregun = 57 THEN
               preg9 := pcrespue;
            ELSIF pcpregun = 58 THEN
               preg10 := pcrespue;
            END IF;
         ----------- Afegim la tarificació per salud
         ------------ Solo tipo 6, sin modalidad
         ELSIF tipo = 6 THEN
            IF pcpregun = 59 THEN
               preg1 := pcrespue;
            --  Se quitan preguntas
            --    ELSIF pcpregun = 94 THEN
            --        preg2 := pcrespue;
            --    ELSIF pcpregun = 95 THEN
            --        preg3 := pcrespue;
            --    ELSIF pcpregun = 103 THEN
            --        preg4 := pcrespue;
            -- Se añade la pregunta 109
            ELSIF pcpregun = 109 THEN
               preg5 := pcrespue;
            -- Se añaden preguntas
            ELSIF pcpregun = 116 THEN
               preg2 := pcrespue;
            ELSIF pcpregun = 117 THEN
               preg3 := pcrespue;
            END IF;
         -----------Afegim la tarificació pels tranports
         ELSIF tipo = 7 THEN
            IF pcpregun = 60 THEN
               preg1 := pcrespue;
            ELSIF pcpregun = 61 THEN
               preg2 := pcrespue;
            ELSIF pcpregun = 62 THEN
               preg3 := pcrespue;
            ELSIF pcpregun = 63 THEN
               preg4 := pcrespue;
            ELSIF pcpregun = 64 THEN
               preg5 := pcrespue;
            ELSIF pcpregun = 65 THEN
               preg6 := pcrespue;
            ELSIF pcpregun = 66 THEN
               preg7 := pcrespue;
            ELSIF pcpregun = 78 THEN
               preg8 := pcrespue;
            ELSIF pcpregun = 79 THEN
               preg9 := pcrespue;
            END IF;
         ----------- Afegim la tarificació per la construcció
         ELSIF tipo = 8 THEN
            IF pcpregun = 81 THEN
               preg1 := pcrespue;
            ELSIF pcpregun = 82 THEN
               preg2 := pcrespue;
            ELSIF pcpregun = 83 THEN
               preg3 := pcrespue;
            ELSIF pcpregun = 84 THEN
               preg4 := pcrespue;
            ELSIF pcpregun = 87 THEN
               preg5 := pcrespue;
            ELSIF pcpregun = 88 THEN
               preg6 := pcrespue;
            ELSIF pcpregun = 89 THEN
               preg7 := pcrespue;
            END IF;
         ---- Afegim la comprovació per la resta de productes
         ELSE
            IF pcpregun = 91 THEN
               preg1 := pcrespue;
            ELSIF pcpregun = 92 THEN
               preg2 := pcrespue;
            ELSIF pcpregun = 97 THEN
               preg3 := pcrespue;
            END IF;
         END IF;
          -- Controlem els productes de ESTALVI
          -- Guardarem la aportació total en la pregunta 11
          -- La aportacion ya no se guarda en una pregunta
      --    IF pcagrpro = 2 THEN
      --        IF pcpregun = 93 THEN
      --            preg11 := pcrespue;
      --        END IF;
      --    END IF;
      END LOOP;

      CLOSE c_busc_resp_seg;
   END;

   PROCEDURE verifica_tarifa(
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      conta_proces IN NUMBER) IS
-- Procediment per fer calculs entre tarifes
      CURSOR c_garancar IS
         SELECT sseguro, cgarant, nriesgo, finiefe, norden, ctarifa, icapital, precarg,
                iprianu, ffinefe, cformul, iextrap, sproces, ctipfra, ifranqu, ipritar,
                ftarifa
           FROM garancar
          WHERE sseguro = psseguro
            AND sproces = conta_proces;

      reg            c_garancar%ROWTYPE;
      prima          garancar.iprianu%TYPE;   --       prima          NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      gar_dep        garanpro.cgardep%TYPE;   --       gar_dep        NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      cap_dep        garanpro.pcapdep%TYPE;   --       cap_dep        NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pri_tar        NUMBER;
      garantia       garancar.cgarant%TYPE;   --       garantia       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      descuento      BOOLEAN;
   BEGIN
      OPEN c_garancar;

      LOOP
         FETCH c_garancar
          INTO reg;

         EXIT WHEN c_garancar%NOTFOUND;

         IF reg.ctarifa = 165 THEN
            BEGIN
               SELECT cgardep, pcapdep
                 INTO gar_dep, cap_dep
                 FROM garanpro
                WHERE cgarant = reg.cgarant
                  AND cramo = pcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
            END;

            -- Miramos si también tiene contratada la garantia dependiente
            -- para hacer el descuento
            BEGIN
               SELECT cgarant
                 INTO garantia
                 FROM garancar
                WHERE cgarant = gar_dep
                  AND sseguro = reg.sseguro
                  AND nriesgo = reg.nriesgo
                  AND sproces = conta_proces;

               descuento := TRUE;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  descuento := FALSE;
               WHEN OTHERS THEN
                  descuento := FALSE;
            END;

            IF descuento = TRUE THEN
               prima := cap_dep * reg.ipritar;

               UPDATE garancar
                  SET iprianu = prima
                WHERE sseguro = reg.sseguro
                  AND nriesgo = reg.nriesgo
                  AND cgarant = reg.cgarant
                  AND sproces = conta_proces;
            END IF;
         END IF;
      END LOOP;

      CLOSE c_garancar;
   END;

   PROCEDURE verifica_tarifa_comunidades(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcmanual IN NUMBER,
      pcactivi IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      capital_total OUT NUMBER) IS
      CURSOR c_garantias IS
         SELECT g.cgarant, g.icaptot icapital, g.crevali, g.prevali, g.irevali, g.ipritar
           FROM garanpro gp, garanseg g
          WHERE g.sseguro = psseguro
            AND g.nriesgo = pnriesgo
            AND g.ffinefe IS NULL
            AND g.cgarant = gp.cgarant
            AND gp.cramo = pcramo
            AND gp.cmodali = pcmodali
            AND gp.ctipseg = pctipseg
            AND gp.ccolect = pccolect
            AND gp.cbasica = 1
            AND gp.cactivi = 0;

      prevcap        NUMBER;
      prevprima      NUMBER;
      num_err        NUMBER;
      lfactor        NUMBER;
   BEGIN
      prevcap := 0;
      capital_total := 0;

      FOR reg IN c_garantias LOOP
         num_err := f_revalgar(psseguro, pcmanual, reg.cgarant, pcactivi, pcramo, pcmodali,
                               pctipseg, pccolect, reg.icapital, reg.ipritar, reg.crevali,
                               reg.irevali, reg.prevali, pmes, panyo, prevcap, prevprima,
                               lfactor);
         capital_total := capital_total + prevcap;
      END LOOP;
   END;

   PROCEDURE verifica_garan(
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      cte_cto IN OUT NUMBER) IS
-- Procediment per fer calculs entre garanties
      garantia       garanseg.cgarant%TYPE;   --       garantia       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      cte_cto := 0;

      IF pcramo = 6 THEN
         BEGIN
            SELECT cgarant
              INTO garantia
              FROM garanseg
             WHERE sseguro = psseguro
               AND(cgarant = 57
                   OR cgarant = 58)
               AND ffinefe IS NULL;

            cte_cto := 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
            WHEN TOO_MANY_ROWS THEN
               cte_cto := 1;
            WHEN OTHERS THEN
               NULL;
         END;

         BEGIN
            SELECT cgarant
              INTO garantia
              FROM garanseg
             WHERE sseguro = psseguro
               AND(cgarant = 29
                   OR cgarant = 30
                   OR cgarant = 31)
               AND ffinefe IS NULL;

            IF cte_cto = 1 THEN
               cte_cto := 3;
            ELSE
               cte_cto := 2;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
            WHEN TOO_MANY_ROWS THEN
               IF cte_cto = 1 THEN
                  cte_cto := 3;
               ELSE
                  cte_cto := 2;
               END IF;
            WHEN OTHERS THEN
               NULL;
         END;
      -- Mirem si tenim contractades les garanties 28 i 60
        -- Mirem si tenim contractades les garanties 70 i 212
      ELSIF pcramo = 7
            AND pcmodali = 1 THEN
         BEGIN
            SELECT cgarant
              INTO garantia
              FROM garanseg
             WHERE sseguro = psseguro
               AND cgarant IN(28, 70, 212)
               AND ffinefe IS NULL;

            cte_cto := 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
            WHEN TOO_MANY_ROWS THEN
               cte_cto := 1;
            WHEN OTHERS THEN
               cte_cto := 1;
         END;

         BEGIN
            SELECT cgarant
              INTO garantia
              FROM garanseg
             WHERE sseguro = psseguro
               AND cgarant = 60
               AND ffinefe IS NULL;

            IF cte_cto = 1 THEN
               cte_cto := 3;
            ELSE
               cte_cto := 2;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
            WHEN OTHERS THEN
               IF cte_cto = 1 THEN
                  cte_cto := 3;
               ELSE
                  cte_cto := 2;
               END IF;
         END;
      END IF;
   END;

----------------------------------------------------------------------------------------
   FUNCTION cartera_producte(
      pempresa IN NUMBER,
      psproces_prod IN NUMBER,
      psproces IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER,
      pidioma IN NUMBER,
      pmoneda IN NUMBER,
      pfemisio IN DATE,
      indice OUT NUMBER,
      indice_error OUT NUMBER)
      RETURN NUMBER IS
      fecha_empresa  DATE;
      fecha_producto DATE;
      num_total_registres NUMBER;
      v_seg          seguros%ROWTYPE;
      cartera        NUMBER;
      encontrado     NUMBER := 0;
--    PCRAMO             NUMBER;
--    PCMODALI             NUMBER;
--    PCTIPSEG             NUMBER;
--    PCCOLECT             NUMBER;
--    PPRODUCTO            VARCHAR2(70);
      curblk         VARCHAR2(30);
      codi_ramo      NUMBER;
      mes_conta      DATE;
      pcsubpro       NUMBER;
      algun_error    NUMBER := 0;
      num_err        NUMBER := 0;
      prevcap        NUMBER(13, 2);
      texto          VARCHAR2(100);
      piprima        NUMBER(13, 2);
      psperson       NUMBER(10);
      conta_proces   NUMBER;
      error          NUMBER;
      fcarpronueva   seguros.fefecto%TYPE := NULL;   --       fcarpronueva   DATE := NULL; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      fcarantnueva   seguros.fefecto%TYPE := NULL;   --       fcarantnueva   DATE := NULL; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      fcaranunueva   seguros.fefecto%TYPE := NULL;   --       fcaranunueva   DATE := NULL; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      nanualinueva   NUMBER := NULL;
      nfraccinueva   NUMBER;
      pnrecibo       NUMBER;
      tipo           codiram.cgtarif%TYPE;   --       tipo           NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pcobjase       NUMBER;
      pnduraci       NUMBER;
      pndurcob       NUMBER;
      fec            VARCHAR2(20);
      texto2         VARCHAR2(60);
      pcagrpro       NUMBER;
      num            NUMBER;
      ttexto         VARCHAR2(30);
      piregula       NUMBER;
      ptempresa      VARCHAR2(70);
      pnnumlin       NUMBER;
      pcactivi       seguros.cactivi%TYPE;   --       pcactivi       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      num_risc       NUMBER;
      pnimport2      NUMBER;
      pcmovimi       NUMBER;
      pnmovimi2      NUMBER;
      movimiento     NUMBER;
      anulado        NUMBER;
      fecha_carpro   empresas.fcarpro%TYPE;   --       fecha_carpro   DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      fecha_carant   empresas.fcarant%TYPE;   --       fecha_carant   DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      dia            VARCHAR2(4);
      fechini        DATE;
      primaant       NUMBER;
      pfech          DATE;
      prima          seguros.iprianu%TYPE;   --       prima          NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      modcom         NUMBER;
      fultrenova     DATE;
      nmovimi        NUMBER;
      vwhere         VARCHAR2(100);
      vccarpro       NUMBER;
      num_prod       NUMBER;
      pcorrecte      NUMBER := 0;
      wrecord        NUMBER;
      lcsubpro       productos.csubpro%TYPE;   --       lcsubpro       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      lcobjase       productos.cobjase%TYPE;   --       lcobjase       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      lcagrpro       productos.cagrpro%TYPE;   --       lcagrpro       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      num_lin        NUMBER;
      lcprimin       NUMBER;
      liprimin       NUMBER;
      lcclapri       NUMBER;
      lcgarant_regu  NUMBER;
      lnorden        NUMBER;
      lmoneda        NUMBER;   -- NO UTILITZEM LA MONEDA DEL PARÀMETRE SINO LA DEL PRODUCTE
      lnedamar       NUMBER;
      lciedmar       NUMBER;

      CURSOR c_prod IS
         SELECT *
           FROM carteraaux
          WHERE sproces = psproces_prod;

      CURSOR c_seg(wram NUMBER, wmod NUMBER, wtip NUMBER, wcol NUMBER) IS
         SELECT *
           FROM seguros
          WHERE cramo = wram
            AND cmodali = wmod
            AND ctipseg = wtip
            AND ccolect = wcol
            AND creteni = 0
            AND csituac = 0
            AND fcarpro <(LAST_DAY(TO_DATE(LPAD(pmes, 2, '0') || panyo, 'mmyyyy')) + 1)
--           AND (fvencim > (last_day(to_date(lpad(pmes,2,'0')||panyo,'mmyyyy'))) OR fvencim is null)
            AND(fvencim >(LAST_DAY(TO_DATE(LPAD(pmes, 2, '0') || panyo, 'mmyyyy')))
                OR(fvencim <=(LAST_DAY(TO_DATE(LPAD(pmes, 2, '0') || panyo, 'mmyyyy')))
                   AND TO_CHAR(fvencim, 'mmyyyy') = LPAD(pmes, 2, '0') || panyo
                   AND fvencim > fcarpro)
                OR fvencim IS NULL)
            AND EXISTS(SELECT sseguro
                         FROM movseguro m
                        WHERE nmovimi = (SELECT MAX(nmovimi)
                                           FROM movseguro m3
                                          WHERE m3.sseguro = m.sseguro
                                            AND TRUNC(m3.fefecto) <=
                                                  LAST_DAY(TO_DATE(LPAD(pmes, 2, '0') || panyo,
                                                                   'mmyyyy'))
                                            AND m3.cmovseg <> 6)
                          AND cmovseg <> 3
                          AND femisio IS NOT NULL
                          AND sseguro = seguros.sseguro)
            AND f_produsu(cramo, cmodali, ctipseg, ccolect, 3) = 1
            AND NVL(f_ultima_cartera(sseguro, fcarpro), fcarpro) >= fcarpro;
   BEGIN
      indice := 0;
      indice_error := 0;

      FOR v_prod IN c_prod LOOP
--------------------------------------------------
-- Per cada producte, farem el traspàs de diferits
-- del mes
--------------------------------------------------
         pac_trans_diferits.p_traspaso_diferits(LAST_DAY(TO_DATE(LPAD(pmes, 2, '0') || panyo,
                                                                 'mmyyyy')),
                                                v_prod.cramo, v_prod.cmodali, v_prod.ctipseg,
                                                v_prod.ccolect);
-------------------------------------------------
-- Mirem si el producte contempla la prima mínima
-------------------------------------------------
-- Si s'ha de comprovar la prima mínima, cal veure si hi ha garantia
-- de regularització.
         garantia_regularitzacio(v_prod.cramo, v_prod.cmodali, v_prod.ctipseg, v_prod.ccolect,
                                 lcprimin, liprimin, lcclapri, lcgarant_regu, lnorden);

         BEGIN
            UPDATE prodcartera
               SET fcarpro = ADD_MONTHS(TO_DATE('01' || LPAD(pmes, 2, '0') || panyo,
                                                'ddmmyyyy'),
                                        1),
                   fcarant = TO_DATE('01' || LPAD(pmes, 2, '0') || panyo, 'ddmmyyyy')
             WHERE cempres = pempresa
               AND cramo = v_prod.cramo
               AND cmodali = v_prod.cmodali
               AND ctipseg = v_prod.ctipseg
               AND ccolect = v_prod.ccolect;

            COMMIT;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 102705;
         END;

         BEGIN
            SELECT csubpro, cobjase, cagrpro, DECODE(cdivisa, 3, 1, 2), nedamar, ciedmar
              INTO lcsubpro, lcobjase, lcagrpro, lmoneda, lnedamar, lciedmar
              FROM productos
             WHERE cramo = v_prod.cramo
               AND cmodali = v_prod.cmodali
               AND ctipseg = v_prod.ctipseg
               AND ccolect = v_prod.ccolect;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 102705;
         END;

         FOR v_seg IN c_seg(v_prod.cramo, v_prod.cmodali, v_prod.ctipseg, v_prod.ccolect) LOOP
            pcorrecte := 0;
            num_err := p_cartera(lmoneda, pidioma, pmes, panyo, v_seg.sseguro, v_seg.cramo,
                                 v_seg.cmodali, v_seg.ctipseg, v_seg.ccolect, v_seg.ctarman,
                                 v_seg.ccobban, v_seg.nrenova, v_seg.ctipreb, v_seg.cforpag,
                                 v_seg.nduraci, v_seg.ndurcob, v_seg.cactivi, lcsubpro,
                                 lcobjase, lcagrpro, v_seg.fefecto, v_seg.fvencim,
                                 v_seg.fcarpro, v_seg.fcaranu, v_seg.nanuali, v_seg.nfracci,
                                 v_seg.fcarant, psproces, indice, indice_error, pfemisio,
                                 pcorrecte, v_seg.sproduc, v_seg.nsuplem, lcgarant_regu,
                                 lnorden, lcprimin, liprimin, lcclapri, lnedamar, lciedmar);

            IF num_err = 0 THEN
               COMMIT;
            ELSE
               ROLLBACK;
               texto := f_axis_literales(num_err, pidioma);
               texto := texto || '.' || v_seg.sseguro;
               num_lin := NULL;
               num_err := f_proceslin(psproces, texto, v_seg.sseguro, num_lin);

               IF num_err = 0 THEN
                  COMMIT;
               END IF;
            END IF;
         END LOOP;
      END LOOP;

      SELECT COUNT(*)
        INTO num_total_registres
        FROM prodcartera
       WHERE cempres = pempresa;

      SELECT COUNT(*)
        INTO num_prod
        FROM prodcartera
       WHERE cempres = pempresa
         AND fcarant = TO_DATE('01' || pmes || panyo, 'ddmmyyyy');

      IF num_total_registres = num_prod THEN
         -- Se actualiza fcarpro de EMPRESAS.
         BEGIN
            SELECT fcarpro, fcarant
              INTO fecha_carpro, fecha_carant
              FROM empresas
             WHERE cempres = pempresa;

            IF TO_CHAR(fecha_carpro, 'mmyyyy') = LPAD(pmes, 2, '0') || panyo THEN
               UPDATE empresas
                  SET fcarpro = ADD_MONTHS(fecha_carpro, 1),
                      fcarant = ADD_MONTHS(fecha_carant, 1)
                WHERE cempres = pempresa;

               COMMIT;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
--                    p_error(102531,ppsproces, sqlcode);
               algun_error := 1;
         END;
      END IF;

      -- BUIDEM LA LLISTA DE PRODUCTES
      DELETE FROM carteraaux
            WHERE sproces = psproces_prod;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 9999;
   END cartera_producte;

-----------------------------------------------------------------------------------------
   FUNCTION f_excepcionsegu(psseguro IN NUMBER, pcconcep IN NUMBER, pcvalor OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      -- Obtenim el valor per el concepte
      SELECT cvalor
        INTO pcvalor
        FROM excepcionsegu
       WHERE sseguro = psseguro
         AND cconcep = pcconcep;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pcvalor := NULL;
         RETURN 0;
      WHEN OTHERS THEN
         RETURN 110536;
   END f_excepcionsegu;
-----------------------------------------------------------------------------------------
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARTERA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARTERA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARTERA" TO "PROGRAMADORESCSI";
