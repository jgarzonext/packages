--------------------------------------------------------
--  DDL for Package Body PK_CUMUL_RIE_VIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_CUMUL_RIE_VIDA" IS
-- ****************************************************************
--  Busca cumulos de 0-Contratos y 1-Capitales
-- ****************************************************************
   FUNCTION buscar_cumulo(
      psproduc IN NUMBER,
      pfecefe IN DATE,
      pcont IN NUMBER,
      parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb)
      RETURN NUMBER IS
      xcramo         NUMBER;
      xctipseg       NUMBER;
      xcmodali       NUMBER;
      xccolect       NUMBER;
      num_err        NUMBER;
      xcumulo        NUMBER;

      CURSOR cum_prod_r IS
         SELECT cp.ccumulo
           FROM cum_cumprod cp, cum_cumulo cc
          WHERE cproduc = psproduc
            AND cc.scumulo = cp.ccumulo
            AND cc.cnivel = 0;
   BEGIN
      mensa.DELETE;
      errs := 0;
-- Miro los cumulos por producto
      xcumulo := 0;

      FOR cum_prod IN cum_prod_r LOOP
         IF cum_prod.ccumulo <> xcumulo THEN
            num_err := tratar_cumulos(cum_prod.ccumulo, pfecefe, 0, pcont, parms_transitorios);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;

         xcumulo := cum_prod.ccumulo;
      END LOOP;

--  Miro los cumulos por garantía
      BEGIN
         SELECT cramo, cmodali, ctipseg, ccolect
           INTO xcramo, xcmodali, xctipseg, xccolect
           FROM productos
          WHERE sproduc = psproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN -102705;
         WHEN OTHERS THEN
            RETURN -102705;
      END;

      xcumulo := 0;

      FOR cum_gara IN (SELECT cg.ccumulo
                         FROM cum_cumgaran cg, cum_cumulo cc
                        WHERE cramo = xcramo
                          AND cmodali = xcmodali
                          AND ctipseg = xctipseg
                          AND ccolect = xccolect
                          AND cc.scumulo = cg.ccumulo
                          AND cc.cnivel = 1) LOOP
         IF cum_gara.ccumulo <> xcumulo THEN
            num_err := tratar_cumulos(cum_gara.ccumulo, pfecefe, 1, pcont, parms_transitorios);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;

         xcumulo := cum_gara.ccumulo;
      END LOOP;

--
      RETURN(errs);
--
   END buscar_cumulo;

-- ****************************************************************
--  Busca cumulos de 2-Garantías
-- ****************************************************************
   FUNCTION busca_cum_gar(
      psproduc IN NUMBER,
      pfecefe IN DATE,
      pcont IN NUMBER,
      parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb)
      RETURN NUMBER IS
      xcramo         NUMBER;
      xctipseg       NUMBER;
      xcmodali       NUMBER;
      xccolect       NUMBER;
      num_err        NUMBER;
      xcumulo        NUMBER;
   BEGIN
      mensa.DELETE;
      errs := 0;
      xcumulo := 0;

      BEGIN
         SELECT cramo, cmodali, ctipseg, ccolect
           INTO xcramo, xcmodali, xctipseg, xccolect
           FROM productos
          WHERE sproduc = psproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN -102705;
         WHEN OTHERS THEN
            RETURN -102705;
      END;

      FOR cum_gara IN (SELECT cg.ccumulo
                         FROM cum_cumgaran cg, cum_cumulo cc
                        WHERE cramo = xcramo
                          AND cmodali = xcmodali
                          AND ctipseg = xctipseg
                          AND ccolect = xccolect
                          AND cc.scumulo = cg.ccumulo
                          AND cc.cnivel = 2) LOOP
         IF xcumulo <> cum_gara.ccumulo THEN
            num_err := tratar_cumulos(cum_gara.ccumulo, pfecefe, 2, pcont, parms_transitorios);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;

         xcumulo := cum_gara.ccumulo;
      END LOOP;

--
      RETURN(errs);
--
   END busca_cum_gar;

-- ****************************************************************
--  Tratar cumulos
-- ****************************************************************
   FUNCTION tratar_cumulos(
      pccumulo IN NUMBER,
      pfecefe IN DATE,
      pnivel IN NUMBER,   -- 0-Contratos 1-Capitales 2-Garantias
      pcont IN NUMBER,
      parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb)
      RETURN NUMBER IS
      xilimite       NUMBER;
      xcformul       NUMBER;
      xformula       VARCHAR2(2000);
      xcodigo        VARCHAR2(30);
      xclave         NUMBER;
      xsesion        NUMBER;
      xtotal         NUMBER;
      xval           NUMBER;
      num_err        NUMBER;
      error          NUMBER;
      nfecefe        NUMBER;
      v_tregconcep   pac_parm_tarifas.tregconcep_tabtyp;   -- Bug 21121 - APD - 23/02/2012
   BEGIN
-- Busco detalle del cumulo
      BEGIN
         SELECT ilimite, cformul, clave
           INTO xilimite, xcformul, xclave
           FROM cum_detcumulo
          WHERE ccumulo = pccumulo
            AND ffecini = (SELECT MAX(ffecini)
                             FROM cum_detcumulo
                            WHERE ccumulo = pccumulo
                              AND ffecini <= pfecefe);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN -104331;
         WHEN OTHERS THEN
            RETURN -104665;
      END;

-- Si Tiene formula asociada
      IF xcformul IS NOT NULL THEN
         num_err := buscar_formula(xcformul, xformula, xcodigo);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         SELECT sgt_sesiones.NEXTVAL
           INTO xsesion
           FROM DUAL;

         IF xsesion IS NULL THEN
            RETURN -108418;
         ELSE
              -- I - JLB - OPTIMIZACION
            /* BEGIN
                INSERT INTO sgt_parms_transitorios
                            (sesion, parametro, valor)
                     VALUES (xsesion, 'SESION', xsesion);
             EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                   UPDATE sgt_parms_transitorios
                      SET valor = xsesion
                    WHERE sesion = xsesion
                      AND parametro = 'SESION';
                WHEN OTHERS THEN
                   RETURN -9;
             END;
             */
            num_err := pac_sgt.put(xsesion, 'SESION', xsesion);

            IF num_err <> 0 THEN
               RETURN -9;
            END IF;

            -- F - JLB - OPTIMIZACION
            nfecefe := TO_NUMBER(TO_CHAR(pfecefe, 'YYYYMMDD'));
            -- I - JLB - OPTIMIZACION
            /*
            BEGIN
               INSERT INTO sgt_parms_transitorios
                           (sesion, parametro, valor)
                    VALUES (xsesion, 'FECEFE', nfecefe);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  UPDATE sgt_parms_transitorios
                     SET valor = nfecefe
                   WHERE sesion = xsesion
                     AND parametro = 'FECEFE';
               WHEN OTHERS THEN
                  RETURN -9;
            END;
            */
            num_err := pac_sgt.put(xsesion, 'FECEFE', nfecefe);

            IF num_err <> 0 THEN
               RETURN -9;
            END IF;

            -- F - JLB - OPTIMIZACION
            parms_transitorios(pcont).scumulo := pccumulo;
            -- Bug 21121 - APD - 23/02/2012 - se inserta el parametro v_tregconcep
            pac_parm_tarifas.inserta_parametro(xsesion, xcformul, pcont, parms_transitorios,
                                               error, NULL, v_tregconcep);

            -- fin Bug 21121 - APD - 23/02/2012
            IF error <> 0 THEN
               errs := errs + 1;
               mensa(errs).texto := f_axis_literales(error, 1);
               mensa(errs).contr := 2;
               mensa(errs).tipo := pnivel;
               mensa(errs).texto := mensa(errs).texto || xcodigo;
            ELSE
--   ------------------> Evaluar formula
--p_control_error(null, 'cumulos', 'xformula ='||xformula);
--p_control_error(null, 'cumulos', 'xsesion ='||xsesion);
               xval := pk_formulas.eval(xformula, xsesion);

--p_control_error(null, 'cum','xval capital ='||xval);
               IF xval IS NULL THEN
--commit;
                  errs := errs + 1;
                  mensa(errs).contr := 2;
                  mensa(errs).tipo := pnivel;
                  mensa(errs).texto := ' Falta parametro en formula: ' || xcodigo;
               ELSIF xval >= 0 THEN
--p_control_error(null, 'cumulos', 'xval capital ='||xval);
                  errs := errs + 1;
                  mensa(errs).total := xval;
                  mensa(errs).tipo := pnivel;

                  IF xval > xilimite THEN
                     mensa(errs).texto := ' Sobrepasa limite: ' || TO_CHAR(xilimite)
                                          || ' el cumulo: ' || TO_CHAR(pccumulo);
                     mensa(errs).contr := 1;
                     -- No se para que servía este valor "E", además impide que quede
                     -- retenida la póliza en PAC_EMISION_MV
                     --mensa(errs).docum := 'E';
                     mensa(errs).docum := 1;
                  ELSE
                     mensa(errs).texto := ' Para el cumulo: ' || TO_CHAR(pccumulo);
                     mensa(errs).contr := 0;

                     ------------------> Evaluar Clave
                     IF xclave IS NOT NULL THEN
                        num_err := buscar_formula(xclave, xformula, xcodigo);

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;

                        parms_transitorios(pcont).icapital := xval;
                        -- Bug 21121 - APD - 23/02/2012 - se añade el parametro v_tregconcep
                        pac_parm_tarifas.inserta_parametro(xsesion, xclave, pcont,
                                                           parms_transitorios, error, NULL,
                                                           v_tregconcep);

                        -- fin Bug 21121 - APD - 23/02/2012
                        IF error <> 0 THEN
                           mensa(errs).texto := f_axis_literales(error, 1);
                           mensa(errs).contr := 2;
                           mensa(errs).tipo := pnivel;
                           mensa(errs).texto := mensa(errs).texto || xcodigo;
                        ELSE
                           xval := pk_formulas.eval(xformula, xsesion);

-- dbms_output.put_line('Val; '||xval||' Formula:'||xformula||' Errs:'||errs);
                           IF xval IS NULL THEN
                              mensa(errs).contr := 2;
                              mensa(errs).tipo := pnivel;
                              mensa(errs).texto := ' Falta parametro en formula: ' || xcodigo;
                           ELSE
                              IF xval > 0 THEN
                                 mensa(errs).contr := 1;
                              ELSE
                                 mensa(errs).contr := 0;
                              END IF;

                              mensa(errs).docum := xval;
                           END IF;   --xval IS NULL
                        END IF;
                     END IF;   -- xclave is not null
                  END IF;   -- XVAL> XILIMITE
--   ------------------> Fin Evaluar Clave
               ELSE   -- xval < 0
                  errs := errs + 1;
                  mensa(errs).tipo := pnivel;
                  mensa(errs).contr := 3;
                  mensa(errs).total := xval;
                  mensa(errs).texto := ' Error en la funcion del Cumulo: '
                                       || TO_CHAR(pccumulo);
               END IF;
--   ------------------> Fin Evaluar formula
            END IF;   -- ERROR <> 0
         END IF;   -- xsesion is not null
      ELSE   -- xcformul is null
-- No tiene formula asociada
         errs := errs + 1;
         mensa(errs).tipo := pnivel;

         IF pnivel = 0 THEN
            mensa(errs).total := parms_transitorios(pcont).qcontr;
            xtotal := parms_transitorios(pcont).qcontr;
         ELSE
            mensa(errs).total := parms_transitorios(pcont).icapital;
            xtotal := parms_transitorios(pcont).icapital;
         END IF;

         IF xilimite <= xtotal THEN
            mensa(errs).texto := ' Para el cumulo: ' || TO_CHAR(pccumulo);
            mensa(errs).contr := 0;
         ELSE
            mensa(errs).texto := ' Sobrepasa limite: ' || TO_CHAR(xilimite) || ' el cumulo: '
                                 || TO_CHAR(pccumulo);
            mensa(errs).contr := 1;
         END IF;
      END IF;   -- xcformul is not null

 --   num_err:=Pac_Parm_Tarifas.borra_param_sesion(xsesion);
--      dbms_output.put_line('BORRA; '||NUM_ERR);
      RETURN 0;
   END tratar_cumulos;

-- ****************************************************************
--  Buscar formula
-- ****************************************************************
   FUNCTION buscar_formula(pclave IN NUMBER, pformula OUT VARCHAR2, pcodigo OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      BEGIN
         SELECT formula, codigo
           INTO pformula, pcodigo
           FROM sgt_formulas
          WHERE clave = pclave;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN -108423;
         WHEN OTHERS THEN
            RETURN -108423;
      END;

      RETURN 0;
   END buscar_formula;

-- ****************************************************************
--  Ver mensajes
-- ****************************************************************
   FUNCTION ver_mensajes(nerr IN NUMBER)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN pk_cumul_rie_vida.mensa(nerr).contr || ';' || pk_cumul_rie_vida.mensa(nerr).tipo
             || ';' || pk_cumul_rie_vida.mensa(nerr).total || ';'
             || pk_cumul_rie_vida.mensa(nerr).texto || ';'
             || pk_cumul_rie_vida.mensa(nerr).docum;
   END ver_mensajes;

-- ****************************************************************
--  Borra mensajes
-- ****************************************************************
   PROCEDURE borra_mensajes IS
   BEGIN
      mensa.DELETE;
      errs := 0;
   END borra_mensajes;
END pk_cumul_rie_vida;

/

  GRANT EXECUTE ON "AXIS"."PK_CUMUL_RIE_VIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_CUMUL_RIE_VIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_CUMUL_RIE_VIDA" TO "PROGRAMADORESCSI";
