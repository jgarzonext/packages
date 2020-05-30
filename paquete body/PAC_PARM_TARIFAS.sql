--------------------------------------------------------
--  DDL for Package Body PAC_PARM_TARIFAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PARM_TARIFAS" IS
   /******************************************************************************
      NOMBRE:     PAC_PARM_TARIFAS
      PROPÓSITO:  Funciones de parámetros de tarificación

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        XX/XX/XXXX   XXX                1. Creación del package.
      2.0        08/07/2009   RSC                2. Bug 10350: APR - Detalle de Garantía (Tarificación)
      3.0        20/01/2010   JMF                3. Bug 0012802: CEM - Acceso a la vista PERSONAS
      4.0        16/11/2011    JRH               4.0020149: LCOL_T001-Renovacion no anual (decenal)
      5.0        22/02/2012    APD               5. 0021121: MDP701 - TEC - DETALLE DE PRIMAS DE GARANTIAS
   ******************************************************************************/
   FUNCTION insertar_parametros_riesgo(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      pedad IN NUMBER,
      psexo IN NUMBER,
      pnasegur IN NUMBER,
      cont IN NUMBER,
      pbusca IN VARCHAR2,
      parms_transitorios IN OUT parms_transitorios_tabtyb)
      RETURN NUMBER IS
      -- Declaración de variables
      wcforpag       estseguros.cforpag%TYPE := 1;
      wpinttec       productos.pinttec%TYPE;
      wpgasext       productos.pgasext%TYPE;
      wpgasint       productos.pgasint%TYPE;
      wpgaexin       productos.pgaexin%TYPE;
      wpgaexex       productos.pgaexex%TYPE;
      wfnacimi       solriesgos.fnacimi%TYPE;
      wfcarpro       estseguros.fcarpro%TYPE;
      wfvencim       estseguros.fvencim%TYPE;
      wsexo          solriesgos.csexper%TYPE;
      wedad          NUMBER;
      l_cclarie      estriesgos.cclarie%TYPE;
      wsproduc       productos.sproduc%TYPE;
      xsqlerrm       VARCHAR2(2000);
      wssegpol       estseguros.ssegpol%TYPE;
      wfefepol       estseguros.fefecto%TYPE;
      num_err        NUMBER;
   BEGIN
      l_cclarie := NULL;

      -- Datos de seguros
      IF pbusca = 'EST' THEN
         parms_transitorios(cont).origen := 1;

         BEGIN
            SELECT cforpag, fcarpro, fvencim, ssegpol, fefecto
              INTO wcforpag, wfcarpro, wfvencim, wssegpol, wfefepol
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
            WHEN OTHERS THEN
               NULL;
         END;

         BEGIN
            IF parms_transitorios(cont).nriesgo IS NOT NULL THEN
               SELECT cclarie
                 INTO l_cclarie
                 FROM estriesgos
                WHERE sseguro = psseguro
                  AND nriesgo = parms_transitorios(cont).nriesgo;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      ELSIF pbusca = 'SOL' THEN
         parms_transitorios(cont).origen := 0;

         BEGIN
            SELECT cforpag, fvencim, falta
              INTO wcforpag, wfvencim, wfefepol
              FROM solseguros
             WHERE ssolicit = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
            WHEN OTHERS THEN
               NULL;
         END;
      ELSE
         parms_transitorios(cont).origen := 2;

         BEGIN
            SELECT cforpag, fcarpro, fvencim, fefecto
              INTO wcforpag, wfcarpro, wfvencim, wfefepol
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
            WHEN OTHERS THEN
               NULL;
         END;

         BEGIN
            IF parms_transitorios(cont).nriesgo IS NOT NULL THEN
               SELECT cclarie
                 INTO l_cclarie
                 FROM riesgos
                WHERE sseguro = psseguro
                  AND nriesgo = parms_transitorios(cont).nriesgo;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      END IF;

      IF pbusca = 'SOL' THEN
         SELECT fnacimi, csexper
           INTO wfnacimi, wsexo
           FROM solriesgos
          WHERE ssolicit = psseguro
            AND nriesgo = parms_transitorios(cont).nriesgo;
      ELSIF pbusca = 'EST' THEN   --JRH 06/2008
         BEGIN
            -- Bug 0012802 - 20/01/2010 - JMF
            SELECT fnacimi, csexper
              INTO wfnacimi, wsexo
              FROM estper_personas
             WHERE sperson = psperson;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      ELSE
         BEGIN
            -- Bug 0012802 - 20/01/2010 - JMF
            SELECT fnacimi, csexper
              INTO wfnacimi, wsexo
              FROM per_personas
             WHERE sperson = psperson;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      END IF;

      IF pedad IS NULL THEN
         num_err := f_difdata(wfnacimi, wfcarpro, 2, 1, wedad);
      ELSE
         wsexo := psexo;
         wedad := pedad;
      END IF;

      -- Datos de productos
      BEGIN
         SELECT sproduc, pinttec, pgasext, pgasint, pgaexin, pgaexex
           INTO wsproduc, wpinttec, wpgasext, wpgasint, wpgaexin, wpgaexex
           FROM productos
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF l_cclarie IS NULL THEN
         -- No està informat al risc
         BEGIN
            SELECT cclarie
              INTO l_cclarie
              FROM codiactseg
             WHERE cramo = pcramo
               AND cactivi = pcactivi;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;
      END IF;

      parms_transitorios(cont).cclarie := l_cclarie;
--      IF parms_transitorios (cont).caccion = 2
--      THEN
--         parms_transitorios (cont).sseguro := NVL (wssegpol, psseguro);
--      ELSE
      parms_transitorios(cont).sseguro := psseguro;
--      END IF;
      parms_transitorios(cont).cforpag := wcforpag;
      parms_transitorios(cont).sperson := psperson;
      parms_transitorios(cont).pinttec := NVL(wpinttec, 0);
      parms_transitorios(cont).pgasext := NVL(wpgasext, 0);
      parms_transitorios(cont).pgasint := NVL(wpgasint, 0);
      parms_transitorios(cont).pgaexex := NVL(wpgaexex, 0);
      parms_transitorios(cont).pgaexin := NVL(wpgaexin, 0);
      parms_transitorios(cont).sproduc := NVL(wsproduc, 0);
      parms_transitorios(cont).fnacimi := TO_NUMBER(TO_CHAR(wfnacimi, 'YYYYMMDD'));

      IF wfvencim IS NOT NULL THEN
         parms_transitorios(cont).fecven := TO_NUMBER(TO_CHAR(wfvencim, 'YYYYMMDD'));
      END IF;

      parms_transitorios(cont).edad := NVL(wedad, 0);
      parms_transitorios(cont).sexo := NVL(wsexo, 0);
      parms_transitorios(cont).nasegur := NVL(pnasegur, 0);
      parms_transitorios(cont).fefepol := TO_NUMBER(TO_CHAR(wfefepol, 'YYYYMMDD'));
/*******
    -- Parámetro de fecha efecto (fecha de tarifa).
    BEGIN
        INSERT INTO sgt_parms_transitorios(sesion,parametro,valor) VALUES
                (psesion,'FECEFE',to_number(to_char(nvl(pfecha,f_sysdate),'yyyymmdd')));
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 108592;
    END;
************/
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         xsqlerrm := SQLERRM;
         RETURN SQLERRM;
   END;

---------------------------------------------------------------------------------------------
   FUNCTION busca_valor_dinamico(
      pparametro IN VARCHAR2,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      porigen IN NUMBER,
      pfecefe IN NUMBER,
      pfecha IN NUMBER,   --JRH Tarea 6966
      pndetgar IN NUMBER,   -- Bug 10350 - 08/07/2009 - RSC - Detalle de Garantía (Tarificación)
      retorno OUT NUMBER)
      RETURN NUMBER IS
      x_cllamada     VARCHAR2(100);
      xs             VARCHAR2(1000);
   BEGIN
      IF porigen = 0 THEN
         x_cllamada := 'SOLICITUDES';
      ELSIF porigen = 1 THEN
         x_cllamada := 'ESTUDIOS';
      ELSE
         x_cllamada := 'GENERICO';
      END IF;

      --DBMS_OUTPUT.put_line('el valor que vamos a buscar' || pparametro || ' ** ' || x_cllamada);
      SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable || ' WHERE '
             || twhere || ' ; END;'
        INTO xs
        FROM sgt_carga_arg_prede
       WHERE termino = pparametro
         AND ttable IS NOT NULL
         AND cllamada = x_cllamada;

      --DBMS_OUTPUT.put_line('xs 1 =' || SUBSTR(xs, 0, 240));
      --
      xs := REPLACE(xs, ':FECEFE', pfecefe);
      xs := REPLACE(xs, ':FECHA', pfecha);   --JRH Tarea 6966
      xs := REPLACE(xs, ':SSEGURO', psseguro);
      xs := REPLACE(xs, ':SPRODUC', psproduc);
      xs := REPLACE(xs, ':CACTIVI', pcactivi);
      xs := REPLACE(xs, ':CGARANT', pcgarant);
      xs := REPLACE(xs, ':NRIESGO', pnriesgo);
      xs := REPLACE(xs, ':NMOVIMI', pnmovimi);
      -- Bug 10350 - 08/07/2009 - RSC - Detalle de garantías (Tarificación)
      xs := REPLACE(xs, ':NDETGAR', pndetgar);

      -- Fin Bug 10350

      --
      --DBMS_OUTPUT.put_line(SUBSTR('xs 2 =' || xs, 0, 254));
      BEGIN
         EXECUTE IMMEDIATE xs
                     USING OUT retorno;

         --DBMS_OUTPUT.put_line('despues execute ' || pparametro || ':' || retorno);
         IF retorno IS NULL THEN
            RETURN 103135;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'buscar valor dinámico', NULL,
                        'error al ejecutar la select dinámica SSEGURO =' || psseguro
                        || ' PFECHA=' || pfecefe || ' select =' || xs,
                        SQLERRM);
            --DBMS_OUTPUT.put_line('whn others ' || pparametro || ':' || 0);
            --DBMS_OUTPUT.put_line(SUBSTR(SQLERRM, 0, 254));
            RETURN 103135;
      END;

      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line('busca_valor_dinamico sqlerrm =' || SQLERRM);
         xs := NULL;
         retorno := NULL;
         RETURN 1;
   END busca_valor_dinamico;

---------------------------------------------------------------------------------------------
   -- Bug 21121 - APD - 22/02/2012 - se añade el parametro tregconcep
   PROCEDURE inserta_parametro(
      psesion IN NUMBER,
      pclave IN NUMBER,
      nreg IN NUMBER,
      parms_transitorios IN parms_transitorios_tabtyb,
      error IN OUT NUMBER,
      prim_tot IN NUMBER DEFAULT NULL,
      tregconcep IN tregconcep_tabtyp) IS
      num_err        NUMBER;
      valor          NUMBER;
      vvalor         VARCHAR2(100);

      CURSOR parm_formula IS
         SELECT parametro
           FROM sgt_trans_formula
          WHERE clave = pclave;

      prima_total    NUMBER;
      salir          EXCEPTION;
   BEGIN
      error := 0;

      FOR reg IN parm_formula LOOP
         num_err := 0;

         IF reg.parametro = 'CAPITAL' THEN
            num_err := graba_param(psesion, 'CAPITAL', parms_transitorios(nreg).icapital);

            IF num_err <> 0 THEN
               error := 108425;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'PRIMA_TARIFA' THEN
            num_err := graba_param(psesion, 'PRIMA_TARIFA', parms_transitorios(nreg).ipritar);

            IF num_err <> 0 THEN
               error := 108426;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'SPERSON' THEN
            num_err := graba_param(psesion, 'SPERSON', parms_transitorios(nreg).sperson);

            IF num_err <> 0 THEN
               error := 108426;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'PRIMA_ANUAL' THEN
            num_err := graba_param(psesion, 'PRIMA_ANUAL', parms_transitorios(nreg).iprianu);

            IF num_err <> 0 THEN
               error := 108427;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'PRIMA_TOTAL' THEN
            num_err := graba_param(psesion, 'PRIMA_TOTAL', prim_tot);

            IF num_err <> 0 THEN
               error := 108428;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'SSEGURO' THEN
            -- Inserción de parámetro de forma de pago
            num_err := graba_param(psesion, 'SSEGURO', parms_transitorios(nreg).sseguro);

            IF num_err <> 0 THEN
               error := 108751;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'FPAGPRIMA' THEN
            -- Inserción de parámetro de forma de pago
            num_err := graba_param(psesion, 'FPAGPRIMA', parms_transitorios(nreg).cforpag);

            IF num_err <> 0 THEN
               error := 108751;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'PINTTEC' THEN
            -- Inserción de parámetro de porcentaje de interés técnico.
            num_err := graba_param(psesion, 'PINTTEC', parms_transitorios(nreg).pinttec);

            IF num_err <> 0 THEN
               error := 108752;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'GEEE' THEN
            -- Inserción de parámetro de gastos externos del producto
            num_err := graba_param(psesion, 'GEEE', parms_transitorios(nreg).pgasext);

            IF num_err <> 0 THEN
               error := 108753;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'GIII' THEN
            -- Inserción de parámetro de gastos internos del producto
            num_err := graba_param(psesion, 'GIII', parms_transitorios(nreg).pgasint);

            IF num_err <> 0 THEN
               error := 108754;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'PGAEXIN' THEN
            -- Inserción de parámetro de gastos externos parte interna del producto
            num_err := graba_param(psesion, 'PGAEXIN', parms_transitorios(nreg).pgaexin);

            IF num_err <> 0 THEN
               error := 108754;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'PGAEXEX' THEN
            -- Inserción de parámetro de gastos externos parte externa del producto
            num_err := graba_param(psesion, 'PGAEXEX', parms_transitorios(nreg).pgaexex);

            IF num_err <> 0 THEN
               error := 108754;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'EDAD' THEN
            num_err := graba_param(psesion, 'EDAD', parms_transitorios(nreg).edad);

            IF num_err <> 0 THEN
               error := 1000;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'SEXO' THEN
            num_err := graba_param(psesion, 'SEXO', parms_transitorios(nreg).sexo);

            IF num_err <> 0 THEN
               error := 1000;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'NASEGUR' THEN
            num_err := graba_param(psesion, 'NASEGUR', parms_transitorios(nreg).nasegur);

            IF num_err <> 0 THEN
               error := 1000;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'CONTINENTE' THEN
            num_err := graba_param(psesion, 'CONTINENTE', parms_transitorios(nreg).contnte);

            IF num_err <> 0 THEN
               error := 108500;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'CONTENIDO' THEN
            num_err := graba_param(psesion, 'CONTENIDO', parms_transitorios(nreg).conttdo);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'RISK' THEN
            num_err := graba_param(psesion, 'RISK', parms_transitorios(nreg).cclarie);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'EXTRAPRIMA' THEN
            num_err := graba_param(psesion, 'EXTRAPRIMA', parms_transitorios(nreg).extrapr);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'ILIMITE' THEN
            num_err := graba_param(psesion, 'ILIMITE', parms_transitorios(nreg).ilimite);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'SCUMULO' THEN
            num_err := graba_param(psesion, 'SCUMULO', parms_transitorios(nreg).scumulo);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'SPERSON2' THEN
            num_err := graba_param(psesion, 'SPERSON2', parms_transitorios(nreg).sperson2);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'QCONTR' THEN
            num_err := graba_param(psesion, 'QCONTR', parms_transitorios(nreg).qcontr);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'FECVEN' THEN
            num_err := graba_param(psesion, 'FECVEN', parms_transitorios(nreg).fecven);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'FCARPRO' THEN
            num_err := graba_param(psesion, 'FCARPRO', parms_transitorios(nreg).fcarpro);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'NRIESGO' THEN
            num_err := graba_param(psesion, 'NRIESGO', parms_transitorios(nreg).nriesgo);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'IIMPPRE' THEN
            num_err := graba_param(psesion, 'IIMPPRE', parms_transitorios(nreg).iimppre);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'PINTPRE' THEN
            num_err := graba_param(psesion, 'PINTPRE', parms_transitorios(nreg).pintpre);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'NCAREN' THEN
            num_err := graba_param(psesion, 'NCAREN', parms_transitorios(nreg).ncaren);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'NNUMRECI' THEN
            num_err := graba_param(psesion, 'NNUMRECI', parms_transitorios(nreg).nnumreci);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'CFORAMOR' THEN
            num_err := graba_param(psesion, 'CFORAMOR', parms_transitorios(nreg).cforamor);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'FCARULT' THEN
            num_err := graba_param(psesion, 'FCARULT', parms_transitorios(nreg).fcarult);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'FEFECTO' THEN
            --DBMS_OUTPUT.put_line(' ------=======gravannnnnt '
            --                     || parms_transitorios(nreg).fefecto);
            num_err := graba_param(psesion, reg.parametro, parms_transitorios(nreg).fefecto);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'FECEFE' THEN
            num_err := graba_param(psesion, reg.parametro, parms_transitorios(nreg).fecefe);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'GARANTIA' THEN
            num_err := graba_param(psesion, 'GARANTIA', parms_transitorios(nreg).cgarant);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'REVALORA' THEN
            num_err := graba_param(psesion, 'REVALORA', parms_transitorios(nreg).prevali);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'FACTOR_MULTIPLICADOR' THEN
            num_err := graba_param(psesion, 'FACTOR_MULTIPLICADOR',
                                   parms_transitorios(nreg).nfactor);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'ORIGEN' THEN
            num_err := graba_param(psesion, 'ORIGEN', parms_transitorios(nreg).origen);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'SPRODUC' THEN
            num_err := graba_param(psesion, 'SPRODUC', parms_transitorios(nreg).sproduc);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'FNACIMI' THEN
            num_err := graba_param(psesion, 'FNACIMI', parms_transitorios(nreg).fnacimi);

            IF num_err <> 0 THEN
               error := 108499;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'ACCION' THEN
            num_err := graba_param(psesion, 'ACCION', parms_transitorios(nreg).caccion);

            IF num_err <> 0 THEN
               error := 151236;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'APORTEXT' THEN
            num_err := graba_param(psesion, 'APORTEXT', parms_transitorios(nreg).aportext);

            IF num_err <> 0 THEN
               error := 151236;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'FECMOV' THEN
            num_err := graba_param(psesion, 'FECMOV', parms_transitorios(nreg).fecmov);

            IF num_err <> 0 THEN
               error := 151236;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'NITERAC' THEN
            num_err := graba_param(psesion, 'NITERAC', parms_transitorios(nreg).niterac);

            IF num_err <> 0 THEN
               error := 151236;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'NMOVIMI' THEN
            num_err := graba_param(psesion, 'NMOVIMI', parms_transitorios(nreg).nmovimi);

            IF num_err <> 0 THEN
               error := 151236;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'FEFEPOL' THEN
            num_err := graba_param(psesion, 'FEFEPOL', parms_transitorios(nreg).fefepol);

            IF num_err <> 0 THEN
               error := 151236;
               RAISE salir;
            END IF;
         -- Bug 10350 - 09/07/2009 - RSC - Detalle de garantía (Tarificación)
         ELSIF reg.parametro = 'CREVALIDGAR' THEN
            num_err := graba_param(psesion, 'CREVALIDGAR',
                                   parms_transitorios(nreg).crevalidgar);

            IF num_err <> 0 THEN
               error := 151236;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'NDURCOBDGAR' THEN
            num_err := graba_param(psesion, 'NDURCOBDGAR',
                                   parms_transitorios(nreg).ndurcobdgar);

            IF num_err <> 0 THEN
               error := 151236;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'FINIEFEDGAR' THEN
            num_err := graba_param(psesion, 'FINIEFEDGAR',
                                   parms_transitorios(nreg).finiefedgar);

            IF num_err <> 0 THEN
               error := 151236;
               RAISE salir;
            END IF;
         ELSIF reg.parametro = 'PTIPINTDGAR' THEN
            -- Inserción de parámetro de porcentaje de interés técnico.
            num_err := graba_param(psesion, 'PTIPINTDGAR',
                                   parms_transitorios(nreg).pinttecdgar);

            IF num_err <> 0 THEN
               error := 108752;
               RAISE salir;
            END IF;
         -- Fin Bug 10350
         ELSIF reg.parametro = 'CUNICADGAR' THEN
            -- Inserción de parámetro de porcentaje de interés técnico.
            num_err := graba_param(psesion, 'CUNICADGAR', parms_transitorios(nreg).cunicadgar);

            IF num_err <> 0 THEN
               error := 108752;
               RAISE salir;
            END IF;
         -- Fin Bug 10350
         ELSIF reg.parametro = 'CTARIFADGAR' THEN
            -- Inserción de parámetro de porcentaje de interés técnico.
            num_err := graba_param(psesion, 'CTARIFADGAR',
                                   parms_transitorios(nreg).ctarifadgar);

            IF num_err <> 0 THEN
               error := 108752;
               RAISE salir;
            END IF;
         -- Fin Bug 10350
         ELSIF reg.parametro = 'SPROCESDGAR' THEN
            -- Inserción de parámetro de porcentaje de interés técnico.
            num_err := graba_param(psesion, 'SPROCESDGAR',
                                   parms_transitorios(nreg).sprocesdgar);

            IF num_err <> 0 THEN
               error := 108752;
               RAISE salir;
            END IF;
         -- Fin Bug 10350

         -- Bug 20149 - 16/11/2011 - JRH - 0020149: LCOL_T001-Renovacion no anual (decenal)
         ELSIF reg.parametro = 'TASA' THEN
            -- Inserción de parámetro de porcentaje de interés técnico.
            num_err := graba_param(psesion, 'TASA', parms_transitorios(nreg).tasa);

            IF num_err <> 0 THEN
               error := 108752;
               RAISE salir;
            END IF;
         -- Fi Bug 20149 - 16/11/2011 - JRH
         ELSE
            num_err :=
               busca_valor_dinamico
                  (reg.parametro, parms_transitorios(nreg).sproduc,
                   parms_transitorios(nreg).sseguro, 0, parms_transitorios(nreg).nriesgo,
                   parms_transitorios(nreg).cgarant, parms_transitorios(nreg).nmovimi,
                   parms_transitorios(nreg).origen, parms_transitorios(nreg).fecefe,
                   parms_transitorios(nreg).fcarpro,   --JRH Tarea 6966
                   parms_transitorios(nreg).ndetgar,   -- Bug 10350 - 08/07/2009 - RSC - Detalle de Garantía (Tarificación)
                   valor);

            IF num_err = 0 THEN
               num_err := graba_param(psesion, reg.parametro, valor);

               IF num_err <> 0 THEN
                  error := 151236;
                  RAISE salir;
               END IF;
            ELSIF num_err = 1 THEN
               -- No fem res si no hem trobat cap parámetre dinàmic
               -- Així es manté el funcionament antic
               -- Bug 21121 - APD - 22/02/2012 - se busca reg.parametro en la tabla tregconcep. Si se encuentra se inserta el valor como siempre
               --NULL;
               IF tregconcep IS NOT NULL THEN
                  error := 0;

                  FOR i IN 1 .. tregconcep.COUNT LOOP
                     --JRH
                     IF SUBSTR(reg.parametro, -2) = '_V' THEN
                        vvalor := SUBSTR(reg.parametro, 1, LENGTH(reg.parametro) - 2);
                     ELSE
                        vvalor := reg.parametro;
                     END IF;

                     --JRH

                     -- IF SUBSTR(reg.parametro, 1, LENGTH(reg.parametro) - 2) =
                     IF vvalor = tregconcep(i).cconcep THEN
                        IF SUBSTR(reg.parametro, -2) = '_V' THEN
                           num_err := graba_param(psesion, reg.parametro,
                                                  tregconcep(i).valor2);

                           IF num_err <> 0 THEN
                              error := 108752;
                              EXIT;
                           END IF;
                        ELSE
                           num_err := graba_param(psesion, reg.parametro, tregconcep(i).valor);

                           IF num_err <> 0 THEN
                              error := 108752;
                              EXIT;
                           END IF;
                        END IF;
                     END IF;
                  END LOOP;

                  IF error <> 0 THEN
                     RAISE salir;
                  END IF;
               END IF;
            -- fin Bug 21121 - APD - 22/02/2012
            ELSE
               error := num_err;
            --   raise salir;
            END IF;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN salir THEN
         NULL;
   END;

---------------------------------------------------------------------------------------------
   FUNCTION borra_param_sesion(psesion IN NUMBER)
      RETURN NUMBER IS
      -- JLB I
      vnerror        NUMBER;
   -- JLB F
   BEGIN
      --jlb - I
      -- DELETE FROM sgt_parms_transitorios
      -- WHERE sesion = psesion;
      vnerror := pac_sgt.del(psesion);
      --RETURN 0;
      RETURN vnerror;
   --jlb - F
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 9;
   END;

---------------------------------------------------------------------------------------------
   FUNCTION graba_param(psesion IN NUMBER, pparam IN VARCHAR2, pvalor IN NUMBER)
      RETURN NUMBER IS
      -- JLB I
      vnerror        NUMBER;
   -- JLB F
   BEGIN
      --jlb - I
          --INSERT INTO sgt_parms_transitorios
          --        (sesion, parametro, valor)
          -- VALUES (psesion, pparam, pvalor);
      vnerror := pac_sgt.put(psesion, pparam, pvalor);
      --RETURN 0;
      RETURN vnerror;
   --jlb - F
   EXCEPTION
      /*  -- JLB
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE sgt_parms_transitorios
               SET valor = pvalor
             WHERE sesion = psesion
               AND parametro = pparam;

            RETURN 0; */
      WHEN OTHERS THEN
         RETURN 9;
   END graba_param;

---------------------------------------------------------------------------------------------
   PROCEDURE borra_parametro(psesion IN NUMBER, pclave IN NUMBER) IS
      CURSOR parm_formula IS
         SELECT parametro
           FROM sgt_trans_formula
          WHERE clave = pclave
            AND parametro NOT LIKE 'RESP%'
            -- Bug 21121 - APD - 12/03/2012
            AND parametro NOT LIKE 'CAP-%'
            AND parametro NOT LIKE 'IPRIPUR-%'
            AND parametro NOT LIKE 'IPRITAR-%'
            AND parametro NOT LIKE 'IPRIANU-%'
            AND parametro NOT LIKE 'GAR_CONTRATADA-%'
            --JRH IMP   No Borramos los detalles de garantía para esta garantía para que sigan estando visibles
            AND NOT EXISTS(SELECT 1
                             FROM codcampo c
                            WHERE c.ccampo = sgt_trans_formula.parametro
                              AND c.cutili = 10)
            AND NOT EXISTS(SELECT 1
                             FROM codcampo c
                            WHERE c.ccampo || '_V' = sgt_trans_formula.parametro
                              AND c.cutili = 10);

      --JRH IMP   No Borramos los detalles de garantía para esta garantía para que sigan estando visibles
                  -- fin Bug 21121 - APD - 12/03/2012
      -- I - JLB
      vnerror        NUMBER;
   -- F - JLB
   BEGIN
      FOR reg IN parm_formula LOOP
         -- I - JLB
            --DELETE FROM sgt_parms_transitorios
              --    WHERE sesion = psesion
              --      AND parametro = reg.parametro;
         vnerror := pac_sgt.del(psesion, reg.parametro);
      -- F - JLB
      END LOOP;
   END;

---------------------------------------------------------------------------------------------
   PROCEDURE cargar_preguntas(
      pnriesgo IN NUMBER,
      pramo IN NUMBER,
      pmodali IN NUMBER,
      ptipseg IN NUMBER,
      pcolect IN NUMBER,
      cont IN OUT NUMBER) IS
-- Definición de variables
--    TYPE preg_resp IS RECORD (cpregun NUMBER,crespue NUMBER);
--    TYPE preg_resp_TabTyp IS TABLE OF preg_resp
--         INDEX BY BINARY_INTEGER;
--    preguntas preg_resp_TabTyp;  -- Declaración de tabla PL/SQL
      CURSOR cur_pregunpro IS
         SELECT   cpregun
             FROM pregunpro
            WHERE cramo = pramo
              AND cmodali = pmodali
              AND ctipseg = ptipseg
              AND ccolect = pcolect
         ORDER BY cpregun;

      item           VARCHAR2(20);
      respuest       NUMBER;
      num_err        NUMBER;
   BEGIN
      cont := 0;

      FOR reg IN cur_pregunpro LOOP
         cont := cont + 1;
         pac_parm_tarifas.pregun_respue(cont).cpregun := reg.cpregun;
         item := 'bk_pregun.valor' || cont;
         respuest := item;

         -- Dependiendo de si estoy en modo consulta o alta los datos
         -- están cargados en el record_group o en el bloque.
         IF respuest IS NOT NULL THEN
            pac_parm_tarifas.pregun_respue(cont).crespue := respuest;
         END IF;
      END LOOP;
   END;

   -- Bug 21121 - APD - 05/03/2012 - recupera el valor del parametro de una garantia
   FUNCTION val_gar(
      psesion IN NUMBER,
      pctipo IN NUMBER,
      pcgarant IN NUMBER,
      pnriesgo IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
         -- I -- jlb - OPTI
      --pvalor         sgt_parms_transitorios.valor%TYPE;
      pvalor         NUMBER;
      -- F -- jlb - OPTI
      param          VARCHAR2(100);
   BEGIN
      IF pctipo = 1 THEN
         param := 'CAP-' || pnriesgo || '-' || pcgarant;
      ELSIF pctipo = 2 THEN
         param := 'IPRIPUR-' || pnriesgo || '-' || pcgarant;
      ELSIF pctipo = 3 THEN
         param := 'IPRITAR-' || pnriesgo || '-' || pcgarant;
      ELSIF pctipo = 4 THEN
         param := 'IPRIANU-' || pnriesgo || '-' || pcgarant;
      ELSIF pctipo = 5 THEN
         param := 'GAR_CONTRATADA-' || pnriesgo || '-' || pcgarant;
      END IF;

      -- I - JLB
       -- SELECT valor
       --   INTO pvalor
       --   FROM sgt_parms_transitorios
       --  WHERE sesion = psesion
       --    AND parametro = param;
      pvalor := pac_sgt.get(psesion, param);

      IF pvalor IS NULL THEN
         IF pctipo = 5 THEN
            RETURN 0;
         ELSE
            RETURN NULL;
         END IF;
      END IF;

      -- F -- JLB
      RETURN(pvalor);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF pctipo = 5 THEN
            RETURN 0;
         ELSE
            RETURN NULL;
         END IF;
      WHEN OTHERS THEN
         RETURN NULL;
   END val_gar;

-- fin Bug 21121 - APD - 05/03/2012

   -- Bug 21121 - APD - 13/04/2012 - recupera el valor del parametro de un detalle de una garantia
   FUNCTION val_detprimas(
      psesion IN NUMBER,
      pcgarant IN NUMBER,
      pcconcep IN VARCHAR2,
      pnriesgo IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      viconcep       tmp_detprimas.iconcep%TYPE;
   BEGIN
      SELECT iconcep
        INTO viconcep
        FROM tmp_detprimas
       WHERE sseguro = pac_gfi.f_sgt_parms('SSEGURO', psesion)
         AND nriesgo = pnriesgo
         AND cgarant = pcgarant
         AND nmovimi = NVL(pac_gfi.f_sgt_parms('NMOVIMI', psesion), 1)
         AND cconcep = pcconcep
         AND sproces = pac_gfi.f_sgt_parms('SPROCESDGAR', psesion);

      RETURN(viconcep);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END val_detprimas;

-- fin Bug 21121 - APD - 13/04/2012

   --BUG 24656-XVM-16/11/2012
   FUNCTION cap_consorci(psesion IN NUMBER, pcgarant IN NUMBER, pnriesgo IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      vicapital      garanseg.icapital%TYPE;
      vicapital_old  garanseg.icapital%TYPE;
      v_hiha269      NUMBER;
   BEGIN
      IF pac_gfi.f_sgt_parms('ORIGEN', psesion) = 1 THEN
         BEGIN
            SELECT icapital
              INTO vicapital
              FROM estgaranseg
             WHERE sseguro = pac_gfi.f_sgt_parms('SSEGURO', psesion)
               AND NVL(cobliga, 0) = 1
               AND nriesgo = pnriesgo
               AND cgarant = pcgarant;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 0;
         END;
      ELSE
         --BUG 24657-XVM-27/11/2012
         SELECT COUNT(1)
           INTO v_hiha269
           FROM detmovseguro
          WHERE sseguro = pac_gfi.f_sgt_parms('SSEGURO', psesion)
            AND nmovimi = pac_gfi.f_sgt_parms('NMOVIMI', psesion)
            AND cmotmov = 269;

         IF pac_gfi.f_sgt_parms('ACCION', psesion) = 1
            OR v_hiha269 > 0 THEN   --N.P.,Cartera o cambio de forma de pago
            BEGIN
               SELECT icapital
                 INTO vicapital
                 FROM garanseg
                WHERE sseguro = pac_gfi.f_sgt_parms('SSEGURO', psesion)
                  AND nriesgo = pnriesgo
                  AND cgarant = pcgarant
                  AND nmovimi = NVL(pac_gfi.f_sgt_parms('NMOVIMI', psesion), 1);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 0;
            END;
         ELSE
            BEGIN
               SELECT icapital
                 INTO vicapital
                 FROM garanseg
                WHERE sseguro = pac_gfi.f_sgt_parms('SSEGURO', psesion)
                  AND nriesgo = pnriesgo
                  AND cgarant = pcgarant
                  AND nmovimi = NVL(pac_gfi.f_sgt_parms('NMOVIMI', psesion), 1);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vicapital := 0;
            END;

            BEGIN
               SELECT icapital
                 INTO vicapital_old
                 FROM garanseg
                WHERE sseguro = pac_gfi.f_sgt_parms('SSEGURO', psesion)
                  AND nriesgo = pnriesgo
                  AND cgarant = pcgarant
                  AND nmovimi IN(SELECT MAX(nmovimi)
                                   FROM garanseg
                                  WHERE sseguro = pac_gfi.f_sgt_parms('SSEGURO', psesion)
                                    AND nriesgo = pnriesgo
                                    AND cgarant = pcgarant
                                    AND nmovimi <
                                                NVL(pac_gfi.f_sgt_parms('NMOVIMI', psesion), 1));
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vicapital_old := 0;
            END;

            vicapital := vicapital - vicapital_old;
         END IF;
      END IF;

      RETURN(vicapital);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'cap_consorci', NULL,
                     'error al ejecutar cap_consorci =' || pcgarant || ' pnriesgo='
                     || pnriesgo,
                     SQLERRM);
         RETURN NULL;
   END cap_consorci;

   --BUG 24657-XVM-27/11/2012
   FUNCTION f_suplforpago(psesion IN NUMBER, pcgarant IN NUMBER, pnriesgo IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      v_hiha269      NUMBER;
   BEGIN
      IF pac_gfi.f_sgt_parms('ORIGEN', psesion) = 1 THEN
         RETURN 0;
      ELSE
         SELECT DECODE(COUNT(1), 0, 0, 1)
           INTO v_hiha269
           FROM detmovseguro
          WHERE sseguro = pac_gfi.f_sgt_parms('SSEGURO', psesion)
            AND nmovimi = pac_gfi.f_sgt_parms('NMOVIMI', psesion)
            AND cmotmov = 269;

         RETURN v_hiha269;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_supl_forpago', NULL,
                     'error al ejecutar f_supl_forpago =' || pcgarant || ' pnriesgo='
                     || pnriesgo,
                     SQLERRM);
         RETURN NULL;
   END f_suplforpago;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_PARM_TARIFAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PARM_TARIFAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PARM_TARIFAS" TO "PROGRAMADORESCSI";
