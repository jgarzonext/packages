--------------------------------------------------------
--  DDL for Function F_BUSCACTRREA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_BUSCACTRREA" (
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      psproces IN NUMBER,
      pmotiu IN NUMBER,
      pmoneda IN NUMBER,
      porigen IN NUMBER DEFAULT 1,  -- 1- Ve d'emissió/renovació  2-Ve de q. d'amortització
      pfinici IN DATE DEFAULT NULL, -- Inici de cessió forçat
      pffin IN DATE DEFAULT NULL)   -- Fi de cessió forçat
   RETURN NUMBER
IS
   /***********************************************************************
   F_BUSCACTRREA: Obtenció del contracte/versió de reassegurança
   per totes les garanties d'una pòlissa determinada.
   Deixa l'informació a la taula auxiliar.
   QUADRE DE CERQUES ORDENAT:
   -------------------------
   B1   Ram    Producte    Activitat   Garantía
   B2   Ram    --------    Activitat   Garantía
   B3   Ram    Producte    ---------   Garantía
   B4   Ram    --------    ---------   Garantía
   B5   Ram    Producte    Activitat   --------
   B6   Ram    --------    Activitat   --------
   B7   Ram    Producte    ---------   --------
   B8   Ram    --------    ---------   --------
   error devuelto:
   ** 99      : Hay garantías sin contrato y hay un XL o SL que
   las ampara o bien la póliza o el producto no se
   reaseguran...
   No se realizará cesión...
   ALLIBREA
   S'ha passat la búsqueda dels contractes a
   la funció F_BUSCACONTRATO
   Els param. finici i ffin son per quan la cessió no es calcula desde l'emissió
   o renovació sino desde quadre d'amortització
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  -------  -------------------------------------
   1.0        XX/XX/XXXX   XXX     1. Creación de la función.
   1.1        12/05/2009   AVT     2. 0009549: CRE - Reaseguro de ahorro.
   2.0        01/12/2009   NMM     3. 11845.CRE - Ajustar reassegurança d'estalvi.
   3.0        05/02/2010   AVT     4. 12971: Incidencia cierre reaseguro producto 244 (Credit Vida Host)
   4.0        16/02/2010   AVT     5. 12993: CRE - Reasegurar garantias que no tienen prima
   5.0        14/05/2010   AVT     6. 14536: CRE200 - Reaseguro: Se requiere que un contrato se pueda utilizar
   en varias agrupaciones de producto
   6.0        23/02/2011   JGR     7. 17672: CEM800 - Contracte Reaseguro 2011 - Añadir nuevo parámetro w_cdetces
   7.0        12/06/2012   AVT     8. 20439: LCOL_A002-Migracion de cesiones de polizas de pagos limitados
   8.0        07/03/2012   AVT     9. 21559: LCOL999-Cambios en el Reaseguro: ceder con la versión inicial de la póliza o con la temporalidad del plan
   9.0        26/04/2012   AVT    10. 0022020: LCOL999-Diferencias en las primas de reaseguro
   10.0        02/08/2012   AVT    11. 0022668: LCOL_A002-Qtracker: 0004693: Error en la validacion de limites de contratos
   11.0        26/02/2013   LCF    12. 0025803: RSA001 - Ampliar los decimales que utiliza iAXIS
   12.0        05/03/2013   KBR    13. 0026321: LCOL_A004-Qtracker: 006337: Cambio Parametrizacion de Contratos
   13.0        07/08/2013   AVT    14. 0026663: POSPG400-(POSPG400)- Parametrizacion Reaseguro, Coaseguro - Parametrizacion contratos
   14.0        13/11/2013   AVT    15  0028777: Incidencia 28761: POSREA Reaseguro facultativo
   15.0        10/12/2013   RCL    16. 0029038: LCOL_A002-Revisi? QT Producci?: 10163, 10177, 10178 i 10180
   16.0        27/02/2014   AGG    16. 0030356: Al intentar rehabilitar cualquier póliza aparece el siguiente mensaje "Registro no encontrado
   17.0        01/09/2014   EDA    17. 0027104: LCOLF3BREA- ID 180 FASE 3B Nota 178353. Cesiones manuales
   18.0        24/11/2014   SHA    18. 0031921: LCOLF3BREA-LCOL_A004-Qtracker: 0013095: Validar condiciones de contratos parametrizados- Reposiciones/
   Reinstalamento.
   19.0        22/01/2015   EDA    19. 0037052: Cuando poseea más de un riesgo y no posea formulación guarde correctamente los importes calculados
   20.0        09/11/2016   HRE    20. CONF-294: Se incluye cobjase 3.
   ***********************************************************************/
   lfefecto_ini seguros.fefecto%TYPE;
   perr NUMBER;
   w_cempres seguros.cempres%TYPE;
   w_cramo seguros.cramo%TYPE;
   w_cmodali seguros.cmodali%TYPE;
   w_ccolect seguros.ccolect%TYPE;
   w_ctipseg seguros.ctipseg%TYPE;
   w_cactivi seguros.cactivi%TYPE;
   w_cobjase seguros.cobjase%TYPE;
   w_nasegur riesgos.nasegur%TYPE;
   w_iprianu garanseg.iprianu%TYPE;
   w_icapital cesionesaux.icapital%TYPE;
   fpolefe contratos.fconini%TYPE;         --25803
   fpolvto contratos.fconfin%TYPE;         --25803
   w_fconini contratos.fconini%TYPE;       --25803
   w_fconfin contratos.fconfin%TYPE;       --25803
   w_numlin cesionesaux.nnumlin%TYPE := 0; --25803
   w_scumulo cesionesaux.scumulo%TYPE;
   w_cestado cesionesaux.cestado%TYPE;
   w_cfacult cesionesaux.cfacult%TYPE;
   w_scontra cesionesaux.scontra%TYPE;
   w_nversio cesionesaux.nversio%TYPE;
   w_icapci cesionesaux.icapaci%TYPE;
   w_ipleno cesionesaux.ipleno%TYPE;
   w_cdetces cesionesaux.cdetces%TYPE; -- BUG: 17672 JGR 23/02/2011
   -- w_cgarant  NUMBER(4);
   w_cduraci seguros.cduraci%TYPE;
   w_scontra2 cesionesaux.scontra%TYPE;
   w_nversio2 cesionesaux.nversio%TYPE;
   w_olvidate NUMBER(1);
   w_creaseg  NUMBER(1);
   w_ctiprea seguros.ctiprea%TYPE;
   w_datainici   DATE;
   w_datafinal   DATE;
   w_dias        NUMBER;
   w_dias_origen NUMBER;
   data_final    DATE;
   w_trovat      NUMBER(1);
   w_ctarifa coditarifa.ctarifa%TYPE;
   w_paplica tarifrea.paplica%TYPE;
   w_ctipatr coditarifa.ctipatr%TYPE;
   w_ccolum coditarifa.ccolum%TYPE;
   w_cfila coditarifa.cfila%TYPE;
   w_ipritar cesionesaux.iprirea%TYPE;
   w_atribu  NUMBER;
   w_iprima  NUMBER;
   w_pmoneda NUMBER;
   w_nagrupa cesionesaux.nagrupa%TYPE;
   w_moneda NUMBER;
   w_nanuali seguros.nanuali%TYPE;
   w_pdtorea dtosreavida.pdtorea%TYPE;
   w_anyefecte NUMBER(4);
   w_cvidaga codicontratos.cvidaga%TYPE;
   preg1 pregunseg.cpregun%TYPE;   --25803;
   preg5 pregunseg.cpregun%TYPE;   --25803;
   preg109 pregunseg.cpregun%TYPE; --25803;
   edat NUMBER;
   sexe NUMBER;
   w_fedad movseguro.fefecto%TYPE;
   w_void NUMBER(1) := 0;
   resul  NUMBER;
   w_sgt  NUMBER;
   w_fcarpro seguros.fcarpro%TYPE;
   w_sproduc seguros.sproduc%TYPE;
   w_ctarman seguros.ctarman%TYPE;
   w_femisio seguros.femisio%TYPE;
   w_cforpag seguros.cforpag%TYPE;
   w_cidioma seguros.cidioma%TYPE;
   ldetces NUMBER; -- Indica si te detall a reasegemi
   w_fefecto seguros.fefecto%TYPE;
   w_itarrea NUMBER;                  -- BUG: 12993 16-02-2010 AVT
   w_ndurcob seguros.ndurcob%TYPE;    -- 20439 12/01/2012 AVT
   w_fvencim seguros.fvencim%TYPE;    -- 20439 12/01/2012 AVT
   w_fpolefe contratos.fconini%TYPE;  --25803   -- 21559 AVT 07/03/2012
   w_ctipcoa seguros.ctipcoa%TYPE;    -- Bug 23183/126116 - 18/10/2012 - AMC
   v_porcen coacuadro.ploccoa%TYPE;   -- Bug 23183/126116 - 18/10/2012 - AMC
   v_cgenrec codimotmov.cgenrec%TYPE; -- 28777 AVT 14/11/2013
   v_cmotmov codimotmov.cmotmov%TYPE; -- 28777 AVT 14/11/2013
   w_cesion_anul_vig NUMBER;
   vpar_traza        VARCHAR2(80) := 'TRAZA_CESIONES_REA'; -- 09/04/2014 AGG
   v_nom_paquete     VARCHAR2(80) := NULL;
   v_nom_funcion     VARCHAR2(80) := 'F_BUSCACTRREA';
   v_base_rea        NUMBER       := 0; --cambio
   v_existe_fac_ant  NUMBER;            --cambio
   v_fefecto_rea     DATE;              -- 21/07/2014 EDA Bug 0027104/178353.
   v_fefecto_rea_ant DATE;              -- 21/07/2014 EDA Bug 0027104/178353.
   v_traza           NUMBER := 0;
   v_rea_reten       NUMBER;
   w_iprirea         NUMBER;         --Bug 31921/192351 - 24/11/2014 - SHA
   w_ipritarrea      NUMBER;         --Bug 31921/192351 - 24/11/2014 - SHA
   w_iextrea         NUMBER;         --Bug 31921/192351 - 24/11/2014 - SHA
   lcfacult          NUMBER;         --Bug 31921/192351 - 24/11/2014 - SHA
   lnagrupa          NUMBER;         --Bug 31921/192351 - 24/11/2014 - SHA
   lnriesgo          NUMBER := NULL; -- Bug 37052 22/01/2015  EDA

   CURSOR cur_garant
   IS
       SELECT    nmovimi, nriesgo, cgarant, icapital, iprianu, finiefe, ffinefe, iextrap, precarg
            FROM garanseg
           WHERE sseguro = psseguro
            AND nmovimi  = pnmovimi;

   CURSOR cur_cesaux
   IS
      -- select nriesgo,cgarant,scumulo,iprirea,icapital
      SELECT DISTINCT cgarant
            FROM cesionesaux
           WHERE scontra       IS NULL
            AND nversio        IS NULL
            AND NVL(cfacult, 0) = 0
            AND sproces         = psproces;

   --AGG 27/02/2014 Se cambia el cursor para que sólo haga cúmulo en el caso de que
   --el asegurado sea una persona
   CURSOR c_cum(wsproces NUMBER)
   IS --Per cada risc, contracte, versio
      SELECT DISTINCT nriesgo, scontra, nversio
            FROM cesionesaux c, seguros s, productos p
           WHERE scontra IS NOT NULL
            AND nversio  IS NOT NULL
            AND c.sseguro = s.sseguro
            AND s.sproduc = p.sproduc
            AND p.cobjase in (1, 3, 2)-- --BUG CONF-294  Fecha (09/11/2016) - HRE - se cobjase 3
            AND sproces   = wsproces;

   CURSOR cur_cesaux2(wnriesgo IN NUMBER)
   IS -- Bug 37052 22/01/2015  EDA
       SELECT    *
            FROM cesionesaux
           WHERE scontra IS NOT NULL
            AND nversio  IS NOT NULL
            AND sproces   = psproces
            AND nriesgo   = NVL(wnriesgo, nriesgo); -- Bug 37052 22/01/2015  EDA

   CURSOR cur_resp(psseguro IN NUMBER, pnriesgo IN NUMBER)
   IS
       SELECT    crespue, cpregun
            FROM pregunseg
           WHERE sseguro = psseguro
            AND nriesgo  = pnriesgo
            AND nmovimi IN
            (SELECT    MAX(nmovimi)
                  FROM pregunseg
                 WHERE sseguro = psseguro
                  AND nriesgo  = pnriesgo
            );

   CURSOR cur_contra_xlsl
   IS
       SELECT    v.scontra, v.nversio
            FROM codicontratos c, contratos v, agr_contratos a
           WHERE c.scontra = v.scontra
            AND c.scontra  = a.scontra -- 14536 14-05-2010 AVT
            AND c.cempres  = w_cempres
            AND a.cgarant IS NULL
            AND(c.ctiprea  = 3
            OR c.ctiprea   = 4)
            AND a.cramo    = w_cramo
            AND(a.cmodali  = w_cmodali
            OR a.cmodali  IS NULL)
            AND(a.ctipseg  = w_ctipseg
            OR a.ctipseg  IS NULL)
            AND(a.ccolect  = w_ccolect
            OR a.ccolect  IS NULL)
            AND a.cactivi IS NULL
            AND v.fconini <= fpolvto
            AND v.fconini <= fpolefe
            AND(v.fconfin IS NULL
            OR v.fconfin   > fpolefe)
            AND c.nconrel IS NULL
        ORDER BY fconini;

   CURSOR c_risc(wpsproces NUMBER, wpsseguro IN NUMBER)
   IS
      SELECT DISTINCT nriesgo
            FROM cesionesaux c, reaformula r
           WHERE c.cgarant = r.cgarant(+)
            AND c.scontra  = r.scontra(+)
            AND c.nversio  = r.nversio(+)
            AND c.sproces  = wpsproces
            AND c.sseguro  = wpsseguro;
BEGIN
   --AGG 09/04/2014
   p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Inicio de proceso: ' || psproces || ' Seguro: ' || psseguro
   || ' nmovimi: ' || NVL(pnmovimi, 0) || ' Motiu: ' || NVL(pmotiu, 0));
   --dbms_output.put_line('Entro en F_BUSCACTRREA');
   SAVEPOINT reaseguro;
   perr := 0;

   -- AQUI ESBORREM QUALSEVOL COSA QUE HI HAGI A LA TAULA CESIONESAUX...
   BEGIN
       DELETE
            FROM cesionesaux
           WHERE sproces = psproces;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      NULL;
   WHEN OTHERS THEN
      perr := 104703;
      RETURN(perr);
   END;

--  AQUI S'OBTENEN DADES DE L'ASSEGURANÇA, TALS COM EL RAM, PRODUCTE,
--  ACTIVITAT, DATA D'EFECTE I VENCIMENT,SI FACULTATIU FORÇAT...
BEGIN
   -- Bug 23183/126116 - 18/10/2012 - AMC
    SELECT    s.fefecto, DECODE(s.fcaranu, NULL, s.fvencim, s.fcaranu), s.cramo, s.cmodali, s.ccolect, s.ctipseg, s.cactivi, s.cempres, s.creafac, s.cobjase,
         s.ctiprea, s.cduraci, s.nanuali, s.fcarpro, s.sproduc, s.ctarman, s.femisio, s.cforpag, s.cidioma, s.ndurcob,
         s.fvencim, s.fefecto, s.ctipcoa
         INTO fpolefe, fpolvto, w_cramo, w_cmodali, w_ccolect, w_ctipseg, w_cactivi, w_cempres, w_cfacult, w_cobjase,
         w_ctiprea, w_cduraci, w_nanuali, w_fcarpro, w_sproduc, w_ctarman, w_femisio, w_cforpag, w_cidioma, w_ndurcob,
         w_fvencim, w_fefecto, w_ctipcoa
         FROM seguros s
        WHERE s.sseguro = psseguro;

   -- Bug 23183/126116 - 18/10/2012 - AMC
   lfefecto_ini := fpolefe;
EXCEPTION
WHEN NO_DATA_FOUND THEN
   perr := 101903;
   --AGG 09/04/2014
   v_traza := 2;
   p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error: ' || perr);
   RETURN(perr);
WHEN OTHERS THEN
   perr := 101919;
   --AGG 09/04/2014
   v_traza := 3;
   p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error: ' || perr);
   RETURN(perr);
END;

-- Npr 9/10/2003 ---
-- Mirem el paràmetre per producte REASSEGURO, ( 0-No te detall a reasegemi,
--                                               1-El detall es calcula amb rebuts
--                                               2-El detall es calcula al q.amortitz)
ldetces := NULL;
perr    := f_parproductos(w_sproduc, 'REASEGURO', ldetces);
--AGG 24/07/2014 Pruebas para las cesiones de reaseguro, para el mantenimiento de los porcentajes
v_base_rea := NVL(pac_parametros.f_parproducto_n(w_sproduc, 'CESION_BASE_REA'), 0);

IF pnmovimi > 1 AND pmotiu = 5 AND v_base_rea = 1 THEN
    SELECT    COUNT( * )
         INTO v_existe_fac_ant
         FROM cesionesrea
        WHERE sseguro  = psseguro
         AND nmovimi   < pnmovimi
         AND sfacult  IS NOT NULL;

   IF v_existe_fac_ant = 0 THEN
       UPDATE seguros
         SET ctiprea     = 1
           WHERE sseguro = psseguro;
   END IF;
END IF;

--fin cambio

-- BUG: 17672 JGR 23/02/2011 -
/*
Aquí no se hizo servir la f_cdetces porque aprovechamos que se estaban llamando
al PARINSTALACIÓN primero y más abajo en al BUSCACONTRATO al que le hemos añadido
el nuevo parámetro CDETCES y nos basta con hacer un NVL de ambos valores en el
"UPDATE cesionesaux"
*/
IF perr = 0 THEN
   -- Si l'origen i el paràmetre no es corresponen, sotirem sense fer rès
   IF porigen            = 1 THEN -- Emissió /renovació
      IF NVL(ldetces, 0) = 2 THEN -- calcul a l'amortització només farem la nova producció
         -- en l'emissió la resta en el q. amortització
         IF pmotiu <> 3 THEN
            --AGG 09/04/2014
            v_traza := 4;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'pmotiu: ' || pmotiu);
            RETURN 0; -- no fem les cessions
         END IF;
      END IF;
   ELSIF porigen         = 2 THEN -- Quadre d'amortització
      IF NVL(ldetces, 0) = 1 THEN -- Per rebuts
         --AGG 09/04/2014
         v_traza := 5;
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, ' Sale sin Tarifar. Detces: ' || ldetces || ' Proceso: '
         || psproces || ' Seguro: ' || psseguro || ' nmovimi: ' || NVL(pnmovimi, 0) || ' Motiu: ' || NVL(pmotiu, 0));
         --dbms_output.put_line(' SURT SENSE TARIFAR !!!!!!!!!!!!!!!! ');
         RETURN 0; -- no fem les cessions
      END IF;
   END IF;
ELSE
   --dbms_output.put_line('F_Parproductos('||w_sproduc||', ''REASEGURO'', '||ldetces||'); -->'||perr);
   RETURN perr;
END IF;

perr          := 0;
w_anyefecte   := TO_CHAR(fpolefe, 'yyyy');

IF pffin      IS NULL THEN
   data_final := fpolvto;
ELSE
   data_final := pffin;
END IF;

v_traza := 6;
--AGG 09/04/2014
p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, ' Sale sin Tarifar. Detces: ' || ldetces || ' Proceso: ' ||
psproces || ' Seguro: ' || psseguro || ' nmovimi: ' || NVL(pnmovimi, 0) || ' Motiu: ' || NVL(pmotiu, 0));

--DBMS_OUTPUT.put_line('---------------------- data_final ' || data_final);

-- AQUI ES MIRA SI L'ASSEGURANÇA INDIVIDUALMENT ES REASSEGURA...
IF w_ctiprea = 2 AND NVL(f_parproductos_v(w_sproduc, 'REASEGURO_AHORRO'), 0) = 0 THEN
   v_traza  := 7;
   p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, ' Error: ' || perr || ' Seguro no reasegurado.');
   perr := 99;   -- Seguro no reassegurat...
   RETURN(perr); -- El perr 99 evita que es
END IF;          -- realitzi la cessió...

-- AQUI ES MIRA SI EL PRODUCTE GLOBAL ES REASSEGURA...
-- BUG 9549 - 12/05/2009 - AVT - Se añade el reaseguro de ahorro por parámetro
-- Mantis 11845.12/2009.NMM.CRE - Ajustar reassegurança d'estalvi .i.
IF pac_cesionesrea.producte_reassegurable(w_sproduc) = 0 AND NVL(f_parproductos_v(w_sproduc, 'REASEGURO_AHORRO'), 0) = 0 THEN
   v_traza                                          := 8;
   p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, ' Error: ' || perr || ' Producto Global no reasegurable.');
   perr := 99;   -- Producte no reassegurat...
   RETURN(perr); -- El perr 99 evita que es realitzi
END IF;          -- la cessió...


-- 28777 AVT 14/11/2013 control de si el moviment és econòmic
IF pmotiu = 4 THEN
   BEGIN
       SELECT    c.cgenrec, c.cmotmov
            INTO v_cgenrec, v_cmotmov
            FROM codimotmov c, movseguro m
           WHERE m.sseguro = psseguro
            AND m.nmovimi  = pnmovimi
            AND m.cmotmov  = c.cmotmov;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      perr    := 112158;
      v_traza := 9;
      p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, ' Error: ' || perr);
      RETURN(perr);
   WHEN OTHERS THEN
      perr    := 104349;
      v_traza := 10;
      p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, ' Error: ' || perr);
      RETURN(perr);
   END;
   --18/08/2015 - DCT - Comentamos ya que en los suplementos diferidos
   -- si existe un suplemento de cambio de forma de pago para POSITIVA NO FUNCIONA
   --BUG interno 35912
   /*IF v_cmotmov = 269
   AND w_cempres = 17 THEN   -- 28777 AVT 14/11/2013 FALTA PARAMETRE!!!!!!!!!!!!!!!
   v_cgenrec := 0;
   END IF;*/
ELSE
   v_cgenrec := 1;
END IF;

IF v_cgenrec = 1 THEN
   -- 28777 AVT 14/11/2013  fi
   --------------------------------------------------
   -- AQUI S'ESCRIU LA TAULA AUXILIAR "CESIONESAUX", A PARTIR DEL GARANSEG...
   FOR reggarant IN cur_garant
   LOOP
      --BUG 41728#c234063 JCP 26/04/2016
      IF pmotiu = 4 THEN
         perr  := pac_cesionesrea.f_control_cesion('REA', w_cempres, psseguro, pnmovimi, reggarant.nriesgo, psproces, v_cgenrec);
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, ' Error: ' || perr);
      END IF;
      --FIN 41728#c234063 JCP 26/04/2016
      -- 41728 AVT 29/04/2016
      IF v_cgenrec            = 1 THEN

         IF reggarant.cgarant = 9999 THEN -- garantia 9999(despeses sinistre)
            w_creaseg        := 1;        -- sempre es reassegurra...
         ELSE
            perr    := pac_cesionesrea.f_gar_rea(w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi, reggarant.cgarant, w_creaseg);

            IF perr <> 0 THEN
               --dbms_output.put_line('PAC_CESIONESREA.F_GAR_REA devuelve error ->'||perr);
               v_traza := 11;
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, ' Error: ' || perr);
               RETURN perr;
            END IF;
         END IF;

         IF w_creaseg > 0 THEN
            -- AQUI ES BUSCA LA DATA INICIAL DEL MOVIMENT...si no ve informada
            -- 21/07/2014 EDA Bug 0027104/178353. Cesiones manuales.
            BEGIN
                SELECT    TO_DATE(trespue, 'DD/MM/YYYY')
                     INTO v_fefecto_rea
                     FROM pregunseg
                    WHERE sseguro = psseguro
                     AND nriesgo  = reggarant.nriesgo
                     AND cpregun  = f_parproductos_v(w_sproduc, 'CPREGUN_FEFECTO_REA')
                     AND nmovimi  = pnmovimi;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_fefecto_rea := NULL;
            WHEN OTHERS THEN
               perr    := 104349;
               v_traza := 12;
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, ' Error: ' || perr);
               p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
               RETURN(perr);
            END;

            BEGIN
                SELECT    TO_DATE(trespue, 'DD/MM/YYYY')
                     INTO v_fefecto_rea_ant
                     FROM pregunseg
                    WHERE sseguro = psseguro
                     AND cpregun  = f_parproductos_v(w_sproduc, 'CPREGUN_FEFECTO_REA')
                     AND nriesgo  = reggarant.nriesgo
                     AND nmovimi  < pnmovimi
                     AND ROWNUM   = 1
                 ORDER BY nmovimi DESC;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_fefecto_rea_ant := NULL;
            WHEN OTHERS THEN
               perr    := 104349;
               v_traza := 13;
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, ' Error: ' || perr);
               p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
               RETURN(perr);
               --RETURN(perr);
            END;

            -- 21/07/2014 EDA Bug 0027104/178353. Cesiones manuales.
            IF v_fefecto_rea IS NOT NULL THEN
               fpolefe       := v_fefecto_rea;
            ELSIF pfinici    IS NOT NULL THEN
               fpolefe       := pfinici;
            ELSE
               IF pmotiu    = 04 OR pmotiu = 05 THEN -- Es tracta d'un suplement o
                  fpolefe  := reggarant.finiefe;     -- cartera...
               ELSIF pmotiu = 09 THEN                -- Es tracta d'una rehabilita-
                  BEGIN                              -- ció: el moviment no està
                     --BUG 29038/159721 - RCL - 10/12/2013
                     -- BUG 29068 - FAL - 18/02/2014
                     w_cesion_anul_vig := 0;

                      SELECT    COUNT(1)
                           INTO w_cesion_anul_vig
                           FROM cesionesrea c
                          WHERE c.sseguro = psseguro
                           AND c.cgenera  = 6
                           AND c.nmovimi IN
                           (SELECT    MAX(nmovimi)
                                 FROM cesionesrea
                                WHERE sseguro = psseguro
                                 AND cgenera  = 6
                           )
                           AND NOT EXISTS
                           (SELECT    1
                                 FROM cesionesrea
                                WHERE sseguro = psseguro
                                 AND cgenera  = 9
                                 AND fgenera  > c.fgenera
                           );

                     IF w_cesion_anul_vig > 0 THEN
                        -- FI BUG 29068 - FAL - 18/02/2014
                         SELECT    MAX(fefecto)
                              INTO fpolefe -- CESIONESREA...
                              FROM cesionesrea c
                             WHERE c.sseguro = psseguro
                              AND c.cgenera  = 6
                              AND c.nmovimi IN
                              (SELECT    MAX(nmovimi)
                                    FROM cesionesrea
                                   WHERE sseguro = psseguro
                                    AND cgenera  = 6
                              )
                              -- BUG 29068 - FAL - 18/02/2014
                              AND NOT EXISTS
                              (SELECT    1
                                    FROM cesionesrea
                                   WHERE sseguro = psseguro
                                    AND cgenera  = 9
                                    AND fgenera  > c.fgenera
                              );
                     ELSE
                        perr := 99;
                        RETURN(perr);
                     END IF;
                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     perr    := 109198;
                     v_traza := 14;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, ' Error: ' || perr);
                     p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
                     RETURN(perr);
                  WHEN OTHERS THEN
                     perr    := 104349;
                     v_traza := 15;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, ' Error: ' || perr);
                     p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
                     RETURN(perr);
                  END;
               END IF;
            END IF;

            w_nagrupa      := NULL;
            w_iprianu      := reggarant.iprianu;

            IF w_creaseg    = 1 THEN -- Suma capital i prima...
               w_icapital  := reggarant.icapital;
            ELSIF w_creaseg = 2 THEN -- Suma solsament prima...
               w_icapital  := 0;
            ELSIF w_creaseg = 3 THEN -- Suma solsament capital...
               w_icapital  := reggarant.icapital;
               w_iprianu   := 0;
               --w_nagrupa := 1; --31921 - DCT - 31/07/2014
               w_nagrupa   := 1; -- 31921 AVT 27/08/2014 (ES DEIXA TAL COM ESTAVA QT 13142/70737)
            ELSIF w_creaseg = 4 THEN
               w_icapital  := NVL(pac_propio.ff_capital_pu(psseguro, fpolefe), reggarant.icapital);
            ELSIF w_creaseg = 5 THEN --Reaseguro retenido
               --Mirar pregunta
               BEGIN
                   SELECT    NVL(crespue, 0)
                        INTO v_rea_reten
                        FROM pregungaranseg
                       WHERE sseguro = psseguro
                        AND nriesgo  = reggarant.nriesgo
                        AND cpregun  = f_parproductos_v(w_sproduc, 'CPREGUN_REA_RETEN')
                        AND cgarant  = reggarant.cgarant
                        AND nmovimi  = pnmovimi;
               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_rea_reten := 0;
               WHEN OTHERS THEN
                  perr    := 104349;
                  v_traza := 16;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, ' Error: ' || perr);
                  p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
                  RETURN(perr);
               END;

               --Si no reasegura o no esta respuesta, no hacemos nada     (comportamiento como w_creaseg=0)
               IF v_rea_reten = 0 THEN
                  w_creaseg  := 0;
                  w_icapital := 0; -- AVT 21/10/2014
                  w_iprianu  := 0;
               ELSE
                  --Si Reasegura (Comportamiento como CREASEG=1), con w_cfacult = 1
                  w_icapital := reggarant.icapital;
                  w_creaseg  := 1;
                  w_cfacult  := 1;
                  w_nagrupa  := 1;
               END IF;
            END IF;

            IF w_creaseg > 0 THEN -- avt 21/10/2014  tornar a controlar si ha de reassegurar la pòlissa
               v_traza  := 17;
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, '  w_creaseg: ' || w_creaseg || ' w_icapital: ' ||
               w_icapital || ' w_iprianu: ' || w_iprianu || ' w_nagrupa: ' || w_nagrupa || ' Proceso: ' || psproces || ' Seguro: ' || psseguro || ' nmovimi: '
               || NVL(pnmovimi, 0) || ' Motiu: ' || NVL(pmotiu, 0));

               IF w_cobjase = 4 THEN -- Es tracta d'un innominat...
                  BEGIN
                      SELECT    nasegur
                           INTO w_nasegur
                           FROM riesgos
                          WHERE sseguro = psseguro
                           AND nriesgo  = reggarant.nriesgo;

                     w_iprianu         := w_iprianu * w_nasegur;
                     w_icapital        := w_icapital * w_nasegur;
                     v_traza           := 18;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, ' w_icapital: ' || w_icapital ||
                     ' w_iprianu: ' || w_iprianu);
                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     perr    := 103836;
                     v_traza := 19;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error: ' || perr);
                     p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
                     RETURN(perr);
                  WHEN OTHERS THEN
                     perr    := 103509;
                     v_traza := 20;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error: ' || perr);
                     p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
                     RETURN(perr);
                  END;
               END IF;

               BEGIN
                  -----------     Busquem si el risc forma part d'un cumul...
                  w_scumulo := NULL;
                  v_traza   := 21;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'sseguro: ' || psseguro);

                  BEGIN
                      SELECT    r.scumulo
                           INTO w_scumulo
                           FROM reariesgos r, cumulos c
                          WHERE ROWNUM           = 1
                           AND r.sseguro         = psseguro
                           AND r.nriesgo         = reggarant.nriesgo
                           AND r.cgarant         = reggarant.cgarant
                           AND fpolefe          >= r.freaini
                           AND(fpolefe           < r.freafin
                           OR r.freafin         IS NULL)
                           AND r.scumulo        IS NOT NULL
                           AND r.scumulo         = c.scumulo
                           AND NVL(c.ctipcum, 0) = 0; --MANUAL
                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                         SELECT    r.scumulo
                              INTO w_scumulo
                              FROM reariesgos r, cumulos c
                             WHERE ROWNUM           = 1
                              AND r.sseguro         = psseguro
                              AND r.nriesgo         = reggarant.nriesgo
                              AND r.cgarant        IS NULL
                              AND fpolefe          >= r.freaini
                              AND(fpolefe           < r.freafin
                              OR r.freafin         IS NULL)
                              AND r.scumulo        IS NOT NULL
                              AND r.scumulo         = c.scumulo
                              AND NVL(c.ctipcum, 0) = 0; --MANUAL
                     EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        NULL;
                     WHEN OTHERS THEN
                        perr    := 104665;
                        v_traza := 22;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error: ' || perr);
                        p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
                        RETURN(perr);
                     END;
                  WHEN OTHERS THEN
                     perr    := 104665;
                     v_traza := 23;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error: ' || perr);
                     p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
                     RETURN(perr);
                  END;

                  ----------     Busquem si hi ha algun risc, garantia o cumul a "piñón fijo"...
                  v_traza := 24;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'w_scumulo: ' || w_scumulo);
                  w_scontra := NULL;
                  w_nversio := NULL;

                  BEGIN
                      SELECT    r.scontra, r.nversio
                           INTO w_scontra, w_nversio
                           FROM reariesgos r, cumulos c
                          WHERE ROWNUM           = 1
                           AND r.sseguro         = psseguro
                           AND r.nriesgo         = reggarant.nriesgo
                           AND r.cgarant         = reggarant.cgarant
                           AND r.nversio        IS NOT NULL
                           AND fpolefe          >= r.freaini
                           AND fpolefe           < NVL(r.freafin, TO_DATE('31/12/3000', 'DD/MM/YYYY'))
                           AND r.scumulo         = c.scumulo(+)
                           AND NVL(c.ctipcum, 0) = 0; --MANUAL
                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                         SELECT    r.scontra, r.nversio
                              INTO w_scontra, w_nversio
                              FROM reariesgos r, cumulos c
                             WHERE ROWNUM           = 1
                              AND r.sseguro         = psseguro
                              AND r.nriesgo         = reggarant.nriesgo
                              AND r.cgarant        IS NULL
                              AND r.nversio        IS NOT NULL
                              AND fpolefe          >= r.freaini
                              AND fpolefe           < NVL(r.freafin, TO_DATE('31/12/3000', 'DD/MM/YYYY'))
                              AND r.scumulo         = c.scumulo(+)
                              AND NVL(c.ctipcum, 0) = 0; --MANUAL
                     EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        BEGIN
                           IF w_scumulo IS NOT NULL THEN
                               SELECT    r.scontra, r.nversio
                                    INTO w_scontra, w_nversio
                                    FROM reariesgos r, cumulos c
                                   WHERE ROWNUM         = 1
                                    AND r.scumulo       = w_scumulo
                                    AND r.nversio      IS NOT NULL
                                    AND fpolefe        >= r.freaini
                                    AND fpolefe         < NVL(r.freafin, TO_DATE('31/12/3000', 'DD/MM/YYYY'))
                                    AND r.scumulo       = c.scumulo
                                    AND NVL(ctipcum, 0) = 0; --MANUAL
                           END IF;
                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           v_traza := 25;
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'No data found');
                           p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
                           NULL;
                        WHEN OTHERS THEN
                           perr    := 104666;
                           v_traza := 26;
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error: ' || perr);
                           p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
                           RETURN(perr);
                        END;
                     WHEN OTHERS THEN
                        perr    := 104666;
                        v_traza := 27;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error: ' || perr);
                        p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
                        RETURN(perr);
                     END;
                  WHEN OTHERS THEN
                     perr    := 104666;
                     v_traza := 28;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error: ' || perr);
                     p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
                     RETURN(perr);
                  END;

                  -- BUG: 12993 16-02-2010 AVT
                  IF pmotiu     = 4 THEN
                     w_itarrea := 0;
                     v_traza   := 29;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Garantia: ' || reggarant.cgarant);

                     BEGIN
                         SELECT    COUNT( * )
                              INTO w_itarrea
                              FROM reaformula
                             WHERE cgarant = reggarant.cgarant
                              AND ccampo   = 'ITARREA';
                     EXCEPTION
                     WHEN OTHERS THEN
                        perr    := 108423;
                        v_traza := 30;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error: ' || perr);
                        p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
                     END;
                  END IF;

                  -------------- Gravarem si és renovació o nova producció tot i que no hi hagi prima ni capital
                  IF NVL(w_iprianu, 0) <> 0 OR NVL(w_icapital, 0) <> 0 OR pmotiu IN(5, 3) OR NVL(w_itarrea, 0) <> 0 THEN -- BUG: 12993 16-02-2010 AVT
                     w_void            := 1;
                     w_fconini         := fpolefe;

                     -- CPM 27/09/06: Se coge la fecha final correcta -- PAGAMENT UNIC --
                     IF w_cforpag  = 0 THEN
                        w_fconfin := ADD_MONTHS(data_final, ( - 12) * TRUNC(MONTHS_BETWEEN(data_final - 1, fpolefe) / 12));
                        -- 20439 12/01/2012 AVT RENOVACIÓ FINS AL DARRER REBUT DE COBRAMENT ------------
                        -- 21559 08/03/2012 AVT JA NO APLICA --> ELSIF pac_parametros.f_parproducto_t(w_sproduc, 'F_POST_EMISION') IS NOT NULL THEN
                        -- 21559 08/03/2012 AVT JA NO APLICA -->    w_fconfin := data_final;

                        -- 21559 08/03/2012 AVT JA NO APLICA -->    IF w_ndurcob IS NOT NULL THEN
                        -- 21559 08/03/2012 AVT JA NO APLICA -->      IF w_fconini = ADD_MONTHS(w_fefecto,(w_ndurcob - 1) * 12)
                        -- 21559 08/03/2012 AVT JA NO APLICA -->          AND NVL(ldetces, 0) = 0 THEN   -- si hi ha detall per rebut ho hem de fer després de
                        -- generar la cessió per rebut
                        -- 21559 08/03/2012 AVT JA NO APLICA -->          w_fconfin := w_fvencim;
                        -- 21559 08/03/2012 AVT JA NO APLICA -->       ELSIF w_fconini > ADD_MONTHS(w_fefecto,(w_ndurcob - 1) * 12) THEN
                        -- 21559 08/03/2012 AVT JA NO APLICA -->          EXIT;
                        -- 21559 08/03/2012 AVT JA NO APLICA -->       END IF;
                        -- 21559 08/03/2012 AVT JA NO APLICA -->    END IF;
                        -- 20439 12/01/2012 AVT ----------------------------------------------------------
                     ELSE
                        w_fconfin := data_final;
                     END IF;

                     v_traza := 31;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'w_fconfin: ' || w_fconfin);
                     w_cestado := 0;
                     w_numlin  := w_numlin + 1;

                     -- Fi Bug 23183/126116 - 18/10/2012 - AMC
                     BEGIN
                         INSERT
                              INTO cesionesaux
                              (
                                 sproces, nnumlin, sseguro, iprirea, icapital, cestado, cfacult, nriesgo, nmovimi, cgarant,
                                 scontra, fconini, fconfin, nversio, scumulo, nagrupa, icapit2, iextrap, precarg, cdetces
                              )
                              VALUES
                              (
                                 psproces, w_numlin, psseguro, NVL(w_iprianu, 0), NVL(w_icapital, 0), w_cestado, w_cfacult, reggarant.nriesgo, pnmovimi,
                                 reggarant.cgarant, w_scontra, w_fconini, w_fconfin, w_nversio, w_scumulo, w_nagrupa, reggarant.icapital, reggarant.iextrap,
                                 reggarant.precarg, ldetces
                              );
                     EXCEPTION
                     WHEN OTHERS THEN
                        perr    := 108423;
                        v_traza := 33;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error: ' || perr);
                        p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
                        RETURN(perr);
                     END;
                  END IF;
               END;
            END IF; -- avt 21/10/2014
         END IF;
      ELSE
         -- AQUI ESBORREM QUALSEVOL COSA QUE HI HAGI A LA TAULA CESIONESAUX...
         BEGIN
             DELETE
                  FROM cesionesaux
                 WHERE sproces = psproces;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
         WHEN OTHERS THEN
            perr := 104703;
            RETURN(perr);
         END;
      END IF; -- AVT 29/04/2016 FIN
   END LOOP;

   ------------------------------------------------------------------
   -- AQUI ANEM A EFECTUAR LES CERQUES SUCCESSIVES, PER CADA GARANTIA SENSE
   -- CONTRACTE ASSIGNAT, SEGONS EL QUADRE EXPOST EN ELS COMENTARIS INICIALS...
   -- ES FA UNA CERCA PER TOTES LES GARANTIES I DESPRES ES PASSA, SI FA FALTA,
   -- A LA SEGÜENT CERCA...
   FOR regcesion IN cur_cesaux
   LOOP -- llegim les garanties sense contracte...
      -- Si es calcula desde el Q. Amortització i és una prima única
      -- forçarem el contracte = al de la cessió anterior
      w_scontra := NULL;

      IF porigen = 2 AND w_cforpag = 0 THEN
         resul  := f_buscacontrato(psseguro, lfefecto_ini, w_cempres, regcesion.cgarant, w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi, pmotiu, w_scontra
         , w_nversio, w_ipleno, w_icapci, w_cdetces); -- BUG: 17672 JGR 23/02/2011

         --resul := f_buscacont_ant(psseguro, w_scontra , w_nversio,w_ipleno, w_icapci);
         IF resul <> 0 THEN
            --dbms_output.put_line('F_Buscacontrato devuelve -->'||resul);
            v_traza := 34;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'resul: ' || resul);
            RETURN resul;
         END IF;
      END IF;

      --dbms_output.put_line(' CONTRACTE ANTIC '||w_scontra||'-'||w_nversio||'-'||w_ipleno||'-'||w_icapci);
      --dbms_output.put_line('resul '||resul );
      -- Si no l'hem trobat ho fem normal
      IF w_scontra IS NULL THEN
         -- 21559 AVT 07/03/2012 segons temporalitat ------- QUE PASSA AMB 6018, 6019 ??? ---
         -- 22020 AVT 26/04/2012 es canvia la fpolefe per la data de renovació: fpolvto
         w_fpolefe := NULL;

         -- 26321 KBR 05/03/2013 Cambiamos parámetro técnico por uno propio del reaseguro
         IF (NVL(pac_parametros.f_parproducto_n(w_sproduc, 'PER_REV_NO_ANUAL_REA'), 0) > 1) THEN
            w_fpolefe                                                                 := pac_cesionesrea.f_renovacion_anual_rea(psseguro, fpolvto);
         ELSE
            w_fpolefe := fpolefe;
         END IF;

         -- 21559 AVT 07/03/2012 fi-------------------------
         resul := f_buscacontrato(psseguro, w_fpolefe, w_cempres, regcesion.cgarant, w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi, pmotiu, w_scontra,
         w_nversio, w_ipleno, w_icapci, w_cdetces); -- BUG: 17672 JGR 23/02/2011
         v_traza := 35;
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'w_fpolefe: ' || w_fpolefe || ' resul: ' || resul);

         -- 26663 AVT 07/08/2013 busquem si hi ha XL per controlar el límit ----------------------
         IF resul  = 104485 THEN
            resul := f_buscacontrato(psseguro, w_fpolefe, w_cempres, regcesion.cgarant, w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi, 11, w_scontra,
            w_nversio, w_ipleno, w_icapci, w_cdetces);
         END IF;
         -- 26663 AVT 07/08/2013  fi -------------------------------------------
      END IF;

      IF resul = 0 THEN
         BEGIN
             UPDATE cesionesaux
               SET scontra = w_scontra, nversio = w_nversio, icapaci = w_icapci, ipleno = w_ipleno, scumulo = w_scumulo, cdetces = NVL(w_cdetces, cdetces) --
                  -- BUG: 17672 JGR 23/02/2011
                  -- 22668 avt 02/08/2012 NO S'HA D'ACTUALITZAR LA DATA D'EFECTE DE LA CESSIÓ
                  -- fconini = NVL(w_fpolefe, fconini)   -- 22020 AVT 26/04/2012
                 WHERE cgarant = regcesion.cgarant
                  AND sproces  = psproces;
            --P_Control_Error ('BUSCACTRREA','update','w_scontra='||w_scontra||'w_nversio'||w_nversio||' '||SQL%ROWCOUNT||' registros modificados');
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            perr    := 104677;
            v_traza := 36;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error: ' || perr);
            p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
            RETURN(perr);
         WHEN OTHERS THEN
            perr    := 104678;
            v_traza := 37;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error: ' || perr);
            p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
            RETURN(perr);
         END;
      ELSE
         v_traza := 38;
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'f_buscacontrato: ' || w_scontra ||
         ' iple - devuelve -->' || resul);
         --dbms_output.put_line('f_buscacontrato '||w_scontra||' iple - devuelve --> '||resul);
         RETURN(resul);
      END IF;
   END LOOP;

   -----------------------------------------------------------------
   -- Anem a fer el càlcul automàtic dels cúmuls.
   -----------------------------------------------------------------

   --Per cada risc, contracte, versio
   FOR vcum IN c_cum(psproces)
   LOOP
      --dbms_output.put_line(' dins bucle cumul ');
      resul      := pac_cesionesrea.f_reacumul(psseguro, vcum.nriesgo, vcum.scontra, vcum.nversio, fpolefe, w_sproduc, w_scumulo);

      IF resul   <> 0 THEN
         v_traza := 39;
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Pac_Cesionesrea.f_reacumul - devuelve -->' || resul);
         --dbms_output.put_line('Pac_Cesionesrea.f_reacumul - devuelve -->'||resul);
         RETURN resul;
      END IF;

      --dbms_output.put_line(' update cesionesaux ');
      -- 13946 AVT 06-04-2010 s'afegeix el SCONTRA i la NVERSIO.
      BEGIN -- Update de CESIONESAUX...
          UPDATE cesionesaux
            SET scumulo     = w_scumulo
              WHERE sproces = psproces
               AND nriesgo  = vcum.nriesgo
               AND scontra  = vcum.scontra
               AND nversio  = vcum.nversio;
      EXCEPTION
      WHEN OTHERS THEN
         perr    := 104696;
         v_traza := 40;
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error: ' || perr);
         p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
         RETURN(perr);
      END;
   END LOOP;

   -------------------------------------------------------------------------
   -- AQUI, SI ES VIDA, BUSCAREM LA TARIFA ESPECIAL I ACTUALITZAREM CESIONESAUX
   -- I EL ITARREA DE GARANSEG...
   --------------------------------------------------------------------------
   --dbms_output.put_line(' xxxxx ');
   --   w_sgt := NVL(F_Parinstalacion_N('REAS_SGT'),0);
   w_sgt := NVL(pac_parametros.f_parempresa_n(w_cempres, 'REAS_SGT'), 0); -- FAL 01/2009. Bug 8528. Se sustituye parámetro de instalación por parámetro de
   -- empresa

   FOR reg IN cur_cesaux2(lnriesgo)
   LOOP -- Bug 37052 22/01/2015  EDA
      w_trovat  := 0;
      w_cvidaga := NULL;

      BEGIN
          SELECT    cvidaga
               INTO w_cvidaga
               FROM codicontratos
              WHERE scontra = reg.scontra;
      END;

      v_traza := 41;
      p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'REAS_SGT: ' || w_sgt);

      --dbms_output.put_line(' REAS_SGT '||w_sgt);
      IF w_cvidaga = 2 AND w_sgt = 0 THEN
         BEGIN                              -- Es busca el codi de tarifa especial
             SELECT    ctarifa, paplica     -- segons contracte, versió i garantia...
                  INTO w_ctarifa, w_paplica -- Això indica si es vida...
                  FROM tarifrea
                 WHERE scontra = reg.scontra
                  AND nversio  = reg.nversio
                  AND cgarant  = reg.cgarant;

            w_trovat          := 1;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            perr    := 107796;
            v_traza := 42;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error: ' || perr);
            p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
            RETURN(perr);
         WHEN OTHERS THEN
            perr    := 107631;
            v_traza := 43;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error: ' || perr);
            p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
            RETURN(perr);
         END;
      END IF;

      IF w_trovat = 1 THEN -- Es vida...NO SGT !!!!
         v_traza := 44;
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Tarifa: ' || w_ctarifa);

         BEGIN
             SELECT    ctipatr, ccolum, cfila
                  INTO w_ctipatr, w_ccolum, w_cfila
                  FROM coditarifa
                 WHERE ctarifa = w_ctarifa;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            perr    := 107632;
            v_traza := 45;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error: ' || perr);
            p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
            RETURN(perr);
         WHEN OTHERS THEN
            perr    := 107633;
            v_traza := 46;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error: ' || perr);
            p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
            RETURN(perr);
         END;

         IF pmotiu   = 4 THEN -- Si suplement, calculem l'edat en el
            v_traza := 47;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Suplemento. motiu: ' || pmotiu || ' sseguro: ' ||
            reg.sseguro);

            BEGIN                 -- moment de l'última cartera o nova
                SELECT    fefecto -- producció. Sino, la calculem a data
                     INTO w_fedad -- de l'efecte del moviment...
                     FROM movseguro
                    WHERE sseguro = reg.sseguro
                     AND cmovseg IN(0, 2)
                     AND nmovimi IN
                     (SELECT    MAX(nmovimi)
                           FROM movseguro
                          WHERE sseguro = reg.sseguro
                           AND cmovseg IN(0, 2)
                           AND nmovimi  < pnmovimi
                     );
            EXCEPTION
            WHEN OTHERS THEN
               w_fedad := reg.fconini;
            END;

            perr := f_edad_sexo(reg.sseguro, w_fedad, 2, edat, sexe, reg.nriesgo);
         ELSE
            perr := f_edad_sexo(reg.sseguro, reg.fconini, 2, edat, sexe, reg.nriesgo);
         END IF;

         IF perr <> 0 THEN
            --dbms_output.put_line('F_Edad_Sexo() devuelve -->'||perr);
            v_traza := 48;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'F_Edad_Sexo Error ' || perr);
            RETURN(perr);
         END IF;

         preg1   := NULL;
         preg5   := NULL;
         preg109 := NULL;

         FOR reg_preg IN cur_resp(reg.sseguro, reg.nriesgo)
         LOOP
            IF reg_preg.cpregun    = 1 THEN
               preg1              := reg_preg.crespue;
            ELSIF reg_preg.cpregun = 5 THEN
               preg5              := reg_preg.crespue;
            ELSIF reg_preg.cpregun = 109 THEN
               preg109            := reg_preg.crespue;
            END IF;
         END LOOP;

         w_moneda := pmoneda;
         perr     := f_tarvidarea(w_ctarifa, w_ccolum, w_cfila, w_ctipatr, reg.icapit2, reg.iextrap, edat, sexe, preg1, preg5, preg109, reg.precarg, w_paplica,
         w_ipritar, w_atribu, w_iprima, w_moneda);

         IF perr <> 0 THEN
            --dbms_output.put_line('F_Tarvidarea() devuelve -->'||perr);
            v_traza := 49;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'F_Tarvidarea() devuelve --> ' || perr);
            RETURN(perr);
         END IF;

         -- Mirem si hi han descomptes especials
         -- segons el contracte la versio,garantia anualitat y date efecte.
         BEGIN
             SELECT    d.pdtorea
                  INTO w_pdtorea
                  FROM dtosreavida d, cuaddtosreavida c
                 WHERE nanuini  <= w_nanuali
                  AND(nanufin    > w_nanuali
                  OR nanufin    IS NULL)
                  AND d.ncuadro  = c.ncuadro
                  AND d.cgarant  = c.cgarant
                  AND d.nversio  = c.nversio
                  AND d.scontra  = c.scontra
                  AND c.fperini <= fpolefe
                  AND(c.fperfin  > fpolefe
                  OR c.fperfin  IS NULL)
                  AND c.cgarant  = reg.cgarant
                  AND c.nversio  = reg.nversio
                  AND c.scontra  = reg.scontra;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            w_pdtorea := NULL;
         WHEN OTHERS THEN
            perr    := 107732;
            v_traza := 50;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 46, 'Error: ' || perr);
            p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
            RETURN(perr);
         END;

         IF w_pdtorea IS NOT NULL THEN
            w_ipritar := w_ipritar - ((w_ipritar * w_pdtorea) / 100);
         END IF;

         IF w_cobjase  = 4 THEN -- Es tracta d'un innominat...
            w_ipritar := w_ipritar * w_nasegur;
         END IF;

         IF w_nagrupa  = 1 AND reg.iprirea = 0 THEN -- Garantia que no
            w_ipritar := 0;                         -- sumava prima...
         END IF;

         BEGIN -- Update de CESIONESAUX...
             UPDATE cesionesaux
               SET iprirea     = w_ipritar
                 WHERE cgarant = reg.cgarant
                  AND nriesgo  = reg.nriesgo
                  AND sproces  = psproces;
         EXCEPTION
         WHEN OTHERS THEN
            perr    := 104696;
            v_traza := 51;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error: ' || perr);
            p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
            RETURN(perr);
         END;

         BEGIN -- Update de GARANSEG...
             UPDATE garanseg
               SET itarrea     = w_ipritar
                 WHERE sseguro = psseguro
                  AND nmovimi  = pnmovimi
                  AND nriesgo  = reg.nriesgo
                  AND cgarant  = reg.cgarant;
         EXCEPTION
         WHEN OTHERS THEN
            perr    := 101959;
            v_traza := 52;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error: ' || perr);
            p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
            RETURN(perr);
         END;
      END IF; -- Tarificació vida sense SGT
   END LOOP;

   --dbms_output.put_line(' crida a xl');
   ------------------------------------------------------------------------
   -- AL FINAL DE TOT, BUSQUEM SI HI HA ALGUN CONTRACTE "XL" O "SL" QUE
   -- AMPARI EL RAM, O BE SI CAP GARANTIA TE CONTRACTE...
   FOR regcesion IN cur_cesaux -- QUEDEN GARANTIES SENSE CONTRACTE...
   LOOP
      perr := 104769;

      FOR regcontrato IN cur_contra_xlsl -- PERÒ TENEN XL O SL QUE LES AMPARA...
      LOOP
         perr    := 99;
         v_traza := 53;
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error: ' || perr);
      END LOOP;
   END LOOP;

   IF w_void   = 0 THEN -- El GARANSEG estava buit...
      v_traza := 54;
      p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error: ' || perr || ' w_void: ' || w_void);
      perr := 99;
   END IF;

   IF perr = 99 THEN
      ROLLBACK TO reaseguro;
   END IF;

   --dbms_output.put_line(' anem a tarifar sgt ');

   --   P_Borrar_Jgr (1); --> BORRAR JGR
   -- BUG 9549 - 04/06/2009 - AVT - Se añade el reaseguro de ahorro por parámetro
   IF NVL(f_parproductos_v(w_sproduc, 'REASEGURO_AHORRO'), 0) = 0 THEN
      w_fefecto                                              := NVL(pfinici, fpolefe);
   ELSE
      w_fefecto := pffin;
   END IF;

   IF perr  = 0 AND w_sgt = 1 AND NVL(f_parproductos_v(w_sproduc, 'NO_REA_SGT'), 0) = 0 THEN -- BUG: 12971 05-02-2010 AVT per productes que no tarifiquen
      perr := pac_cesionesrea.f_garantarifa_rea(psproces, psseguro, pnmovimi, w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_sproduc, w_cactivi,
      --w_fcarpro , --no és propera cartera sino la data del calcul
      -- per tant és l'inici de la cessio
      w_fefecto,    -- fpolefe (fcarpro)
      lfefecto_ini, --pfinici ,-- w_femisio
      w_ctarman, w_cobjase, w_cforpag, w_cidioma, pmoneda);

      IF perr    <> 0 THEN
         v_traza := 55;
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Pac_Cesionesrea.f_garantarifa_rea : ' || perr);
         --dbms_output.put_line('Pac_Cesionesrea.f_garantarifa_rea '||perr);
         RETURN perr;
      END IF;
   END IF;
END IF;

-- Inici Bug 31921/192351 - 24/11/2014 - SHA
lnagrupa := 1;
p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'v_risc... - ' || psproces || ', ' || psseguro);

FOR v_risc IN c_risc(psproces, psseguro)
LOOP
   p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Entramos en v_risc');

   FOR v_gar_risc IN cur_cesaux2(v_risc.nriesgo)
   LOOP -- Bug 37052 22/01/2015  EDA
      lcfacult := NULL;
      p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Entramos en v_gar_risc');

      IF v_gar_risc.cfacult = 1 THEN
         -- Sempre que excedeixi es força si ho diu el contracte
         IF v_gar_risc.icapaci < v_gar_risc.icapital THEN
            lcfacult          := 1;
         END IF;
      END IF;

      w_iprirea  := NVL(v_gar_risc.iprirea, 0);
      w_icapital := NVL(v_gar_risc.icapital, 0);
      --Inici BUG 30326/171842 - DCT - 04/04/2014
      w_ipritarrea                                                                                            := NVL(v_gar_risc.ipritarrea, 0); --BASE (PP)
      w_iextrea                                                                                               := NVL(v_gar_risc.iextrea, 0);

      IF NVL(pac_parametros.f_pargaranpro_n(w_sproduc, w_cactivi, v_gar_risc.cgarant, 'NO_CEDE_COASEGURO'), 0) = 0 THEN
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'v_gar_risc.cgarant:' || v_gar_risc.cgarant ||
         ' w_ctipcoa:' || w_ctipcoa);

         -- Bug 23183/126116 - 18/10/2012 - AMC
         IF w_ctipcoa = 1 THEN
            BEGIN
                SELECT    NVL(c.ploccoa, 100)
                     INTO v_porcen
                     FROM coacuadro c, seguros s
                    WHERE c.sseguro = s.sseguro
                     AND c.ncuacoa  = s.ncuacoa
                     AND s.ctipcoa <> 0
                     AND s.sseguro  = psseguro;
            EXCEPTION
            WHEN OTHERS THEN
               v_porcen := 100; -- No hay coaseguro cedido
            END;

            w_iprirea  := NVL(w_iprirea, 0) * NVL(v_porcen, 100) / 100;
            w_icapital := NVL(w_icapital, 0) * NVL(v_porcen, 100) / 100;
            --Inici BUG 30326/171842 - DCT - 04/04/2014
            w_ipritarrea := NVL(w_ipritarrea, 0) * NVL(v_porcen, 100) / 100; --BASE (PP)
            w_iextrea    := NVL(w_iextrea, 0) * NVL(v_porcen, 100) / 100;    --EXTRAPRIMA
            --Fi BUG 30326/171842 - DCT - 04/04/2014
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'v_porcen:' || v_porcen);
         END IF;
      END IF;

      -- Inicio Bug 37052 22/01/2015  EDA
      v_traza := 56;
      p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'v_gar_risc.cgarant:' || v_gar_risc.cgarant ||
      ' w_iprirea:' || w_iprirea || ' v_gar_risc.nriesgo:' || v_gar_risc.nriesgo || ' v_risc.nriesgo ' || v_risc.nriesgo); -- Fin Bug 37052 22/01/2015  EDA

      --Fi BUG 29347/163814 - 23/01/2014 - RCL
       UPDATE cesionesaux
         SET iextrea   = NVL(w_iextrea, 0),                                                                                 --BUG 30326/171842 - DCT - 04/04/2014
            iextrap    = NVL(v_gar_risc.iextrap, 0),                                                                        --> REA
            iprirea    = NVL(w_iprirea, 0),                                                                                 --BUG 29347/163814 - 23/01/2014 - RCL
            ipritarrea = NVL(w_ipritarrea, 0),                                                                              --BUG 30326/171842 - DCT - 04/04/2014
            idtosel    = NVL(v_gar_risc.idtosel, 0), psobreprima = v_gar_risc.psobreprima, icapital = NVL(w_icapital, 0),   --BUG 29347/163814 - 23/01/2014 - RCL
            ipleno     = NVL(v_gar_risc.ipleno, 0), icapaci = NVL(v_gar_risc.icapaci, 0), cfacult = NVL(lcfacult, cfacult), -- si es null deixem el que hi
            -- havia
            scontra = DECODE(lcfacult, 1, NULL, scontra), nversio = DECODE(lcfacult, 1, NULL, nversio), nagrupa = DECODE(lcfacult, 1, lnagrupa, nagrupa), --
            -- lnagrupa := 1;
            -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
            itarifrea = NVL(v_gar_risc.itarifrea, 0)
            -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
           WHERE sproces = psproces
            AND sseguro  = psseguro
            AND nriesgo  = v_gar_risc.nriesgo --  Bug 37052 22/01/2015  EDA
            AND cgarant  = v_gar_risc.cgarant;

      lnagrupa          := lnagrupa + 1;
   END LOOP;
END LOOP;

-- Fi Bug 31921/192351 - 24/11/2014 - SHA
v_traza := 57;
p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Fin proceso : ' || perr);
-- 28777 AVT 14/11/2013  fi
--   P_Borrar_Jgr (2); --> BORRAR JGR
RETURN(perr);
EXCEPTION
WHEN OTHERS THEN
   v_traza := 58;
   p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'Error no controlado : ' || perr, 1);
   p_tab_error(f_sysdate, f_user, 'f_buscactrrea', v_traza, 'error_no_controlado psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
   RETURN(perr);
   --dbms_output.PUT_LINE(SQLERRM);
END;

/

  GRANT EXECUTE ON "AXIS"."F_BUSCACTRREA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_BUSCACTRREA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_BUSCACTRREA" TO "PROGRAMADORESCSI";
