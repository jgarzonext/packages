--------------------------------------------------------
--  DDL for Package Body PAC_TARIFAS
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PAC_TARIFAS" AS
   /******************************************************************************
      NOMBRE:     PAC_TARIFAS
      PROPÓSITO:  Funciones tarifas

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ----------- ------------------------------------
      1.0        XX/XX/XXXX   XXX          1. Creación del package.
      1.1        20/03/2009   JRH          2. 0009541: CRE - Incidència Cartera de Decesos
      1.2        27/03/2009   XCG          3. 009595: Se ha modificado la llamada a la funció F_CTIPGAR (dentro de la función F_TMPGARANCAR)
      2.0        17/04/2009   APD          4. Bug 9699 - primero se ha de buscar para la actividad en concreto y si no se encuentra nada ir a buscar a PARGARANPRO para la actividad cero
      2.1        22/04/2009   YIL          5. Bug 9794 - Se añade un NVL en iprianu en f_tarifar_risc
      2.2        30/04/2009   YIL          6. Bug 9524 - Se cambia el orden by del cursor tmp_garancar de forma que tenga en cuenta el parámetro ORDEN_TARIF_CARTERA
      3.0        13/05/2009   AVT          7. 0009549: CRE - Reaseguro de ahorro.
      4.0        20/07/2009   ICV-DCT      8. 0010709: Modificación Recargo CLEA Ley 6/2009
      5.0        04/06/2009   RSC          9. Bug 10350: APR - Detalle garantías (tarificación) Iniciamos ajustes en PAC_TARIFAS para tarificación de DETGARANSEG.
      6.0        01/08/2009   NMM         10. Bug 10864: CEM - Tasa aplicable en Consorcio
      7.0        01/07/2009   NMM         11. Bug 10728: CEM - Asignación automática de sobreprima.
      8.0        29/10/2009   RSC         12. 0011636: APR - Error in renewals (previous) - sproces 539
      9.0        05/01/2010   JAS         13. 0012579: CEM - CARTERA: La cartera (amb renovació anual) del PIAM COL·LECTIU peta
      10.0       26/01/2010   DRA         14. 0011737: APR - suplemento de cambio de revalorización
      11.0       20/01/2010   RSC         15. 0011735: APR - suplemento de modificación de capital /prima
      16.0       26/04/2010   DRA         16. 0014172: CEM800 - SUPLEMENTS: Error en el suplement de preguntes de pòlissa de la pòlissa 60115905.
      17.0       24/02/2010   RSC         17. 0013727: APR - Análisis/Implementación de nuevas combinaciones de tarificación Flexilife Nueva Emisión
      18.0       07/05/2010   RSC-FAL     18. 0014336: APR03 - Error en la renovación de polizas de portfolio con sobreprima
      19.0       10/06/2010   RSC         19. 0013832: APRS015 - suplemento de aportaciones únicas
      20.0       30/07/2010   XPL         20. 14429: AGA005 - Primes manuals pels productes de Llar
      21.0       17/12/2010   SMF         21  0017035: AGA901 - control en el calculo de las primas manuales
      22.0       24/01/2011   JMP         22. 0017341: APR703 - Suplemento de preguntas - FlexiLife
      23.0       16/02/2011   ICV         23. 0017675: AGA800 - producte de facultatiu
      24.0       04/04/2011   JMF         24. 0018081: AGA800 : pólizas semestrales no cuadran
      25.0       14/04/2011   FAL         25. 0018172: CRT - Modificacion documentación
      26.0       26/09/2011   DRA         26. 0019532: CEM - Tratamiento de la extraprima en AXIS
      27.0       18/10/2011   JRH         27. 0019820: GIP - Preguntas riesgo CRM. Validación cforpag=0
      28.0       16/11/2011   JRH         28.0020149: LCOL_T001-Renovacion no anual (decenal)
      29.0       28/11/2011   JMP         29. 0018423: LCOL000 - Multimoneda
      30.0       29/11/2011   FAL         30. 0020314: GIP003 - Modificar el cálculo del Selo
      31.0       14/12/2011   ETM         31. 19612/100262: LCOL_T004: Formulación productos Vida Individual .
      32.0       28/12/2011   APD         32. 0020448: LCOL - UAT - TEC - Despeses d'expedició no es fraccionen
      33.0       14/01/2012   JRH         33. 0020671: LCOL_T001-LCOL - UAT - TEC: Contrataci?n
      34.0       01/02/2012   JRH         34  0020666: LCOL_T004-LCOL - UAT - TEC - Indicencias de Tarificaci?n
      35.0       03/01/2012   DRA         35. 0020498: LCOL_T001-LCOL - UAT - TEC - Beneficiaris de la p?lissa
      36.0       22/02/2012   APD         36. 0021121: MDP701 - TEC - DETALLE DE PRIMAS DE GARANTIAS
      37.0       08/03/2012   APD         37. 0021127: MDP_T001- TEC - PRIMA M�?NIMA
      38.0       23/04/2011   MDS         38. 0021907: MDP - TEC - Descuentos y recargos (técnico y comercial) a nivel de póliza/riesgo/garantía
      39.0       19/07/2012   FAL         39. 0022964: MDP - MHG 2008 - Revisión Incidencias
      40.0       02/08/2012   APD         40. 0023074: LCOL_T010-Tratamiento Gastos de Expedición
      41.0       30/08/2012   DCG         41. 0023174: CCAT804-CX - Fallo en renovación de intereses
      42.0       03/10/2012   JMF         0022787 CALI003-Incidències després del test de CA Life
      43.0       14/01/2013   MMS         43.24926/134686- Quitar el round en la sobreprima de la tarifa
      44.0       06/03/2013   dlF         44. 0025940: AGM801-Problema sobreprima con regularizacin por prima minina
      45.0       21/03/2013   dlF         45. 0026460: AGM801-Problema sobreprima con regularizacin por prima minina
      46.0       21/03/2013   dlF         46. 0025870: AGM900 - Nuevo producto sobreprecio frutales 2013
      47.0       06/05/2013   FAL         47. 0026835: GIP800 - Incidencias reportadas 23/4
      48.0       20/08/2013   JDS         48. 0026923: LCOL - TEC - Revisión Q-Trackers Fase 3A
      49.0       22/08/2013   JMF         0025537: RSA000 - Gestión de incidencias
      50.0       14/11/2013   JSV          0028610: LCOL - TARIFICACIÓN 6047 - TP (Colectivo Pesados)
      51.0       29/11/2013   MMM         51. 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL
      52.0       28/03/2014   AVT         52.0030326: LCOL_A004-Qtracker: 11612 y 11610 (11903)
      53.0       07/05/2014   DCT         53. 030326: LCOL_A004-Qtracker: 11612 y 11610 (11903)
      54.0       03/06/2014   JTT         54. 0029943: Modificaciones para el tratamiento de las PBs.
      55.0       07/10/2014   JMF         55. 32015/0188613 Evitar dividir por cero
      56.0       30/01/2015   AFM         56. 0034462: Suplementos de convenios (retroactivos)
      57.0       24/03/2015   AVT         57. 33993: MSV0003-Reinsurance Develpements
      58.0       01/02/2016   FAL         58. 0039498: ERROR AL REGULARIZAR (bug hermano interno)
      59.0       17/03/2016   JAEG        59. 41143/229973: Desarrollo Diseño técnico CONF_TEC-01_VIGENCIA_AMPARO
      60.0       19/06/2015   VCG         60. AMA-209-Redondeo SRI
      61.0       29/08/2019   DFR         61. IAXIS-5031: Primas m�nimas en RC (Nueva producci�n y Endosos)
   ******************************************************************************/
   vnmovimidef NUMBER;

   FUNCTION f_insertar_matriz(ptablas  IN VARCHAR2,
                              psproces IN NUMBER,
                              psseguro IN NUMBER,
                              pnriesgo IN NUMBER,
                              pfecha   IN DATE) RETURN NUMBER IS
      v_select      VARCHAR2(2000);
      s             VARCHAR2(2000);
      v_sproduc     NUMBER;
      ss            VARCHAR2(3000);
      funcion       VARCHAR2(3000);
      num_err       NUMBER;
      vcrespue_1961 pregunseg.crespue%TYPE;
      -- Bug 35872/205978 - APD - 29/05/2015
   BEGIN
      --solseguros
      IF ptablas = 'SOL'
      THEN
         v_select := 'select sproduc into :v_sproduc ' || 'from ' ||
                     ptablas || 'seguros ' || 'where ssolicit = :psseguro;';
      ELSE
         v_select := 'select sproduc into :v_sproduc ' || 'from ' ||
                     ptablas || 'seguros ' || 'where sseguro = :psseguro;';
      END IF;

      s := ' begin ' || v_select || ' end;';

      EXECUTE IMMEDIATE s
         USING OUT v_sproduc, IN psseguro;

      -- Bug 35872/205978 - APD - 29/05/2015
      num_err := pac_preguntas.f_get_pregunseg(psseguro,
                                               pnriesgo,
                                               1961,
                                               ptablas,
                                               vcrespue_1961);

      -- si el producto utiliza sumatorios, ejecutamos la función que nos inserta la matriz
      IF NVL(f_parproductos_v(v_sproduc, 'MATRIZ_TARIFAR'), 0) = 1 AND
         NVL(vcrespue_1961, 1904) = 1904
      THEN
         -- fin Bug 35872/205978 - APD - 29/05/2015
         funcion := f_detparproductos(v_sproduc, 'F_MATRIZ_TARIFAR', 2);

         IF funcion IS NOT NULL AND
            ptablas IS NOT NULL
         THEN
            ss := 'begin :num_err := ' || funcion ||
                  '(:ptablas, :psproces, :psseguro, :pfecha); end;';

            EXECUTE IMMEDIATE ss
               USING OUT num_err, IN ptablas, IN psproces, IN psseguro, IN pfecha;

            IF num_err <> 0
            THEN
               p_tab_error(f_sysdate,
                           f_user,
                           'pac_tarifas.f_insertar_matriz',
                           1,
                           'num_err funcion <> 0',
                           'SSEGURO =' || psseguro || ' PFECHA=' || pfecha ||
                           ' ptablas = ' || ptablas || ' sproces =' ||
                           psproces || ' num_err =' || num_err ||
                           ' funcion =' || funcion);
               RETURN num_err;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     'pac_tarifas.f_insertar_matriz',
                     2,
                     'when others SSEGURO =' || psseguro || ' PFECHA=' ||
                     pfecha || ' ptablas = ' || ptablas || ' sproces =' ||
                     psproces || ' num_err =' || num_err || ' funcion =' ||
                     funcion,
                     SQLERRM);
         RETURN 151588;
         -- error al insertar en la función pac_tarifas.f_insertar_matriz
   END f_insertar_matriz;

   FUNCTION f_clave(pcgarant IN NUMBER,
                    pcramo   IN NUMBER,
                    pcmodali IN NUMBER,
                    pctipseg IN NUMBER,
                    pccolect IN NUMBER,
                    pcactivi IN NUMBER,
                    pccampo  IN VARCHAR2,
                    pclave   OUT NUMBER) RETURN NUMBER IS
   BEGIN
      BEGIN
         SELECT clave
           INTO pclave
           FROM garanformula
          WHERE cgarant = pcgarant
            AND ccampo = pccampo
            AND cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect
            AND cactivi = pcactivi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT clave
                 INTO pclave
                 FROM garanformula
                WHERE cgarant = pcgarant
                  AND ccampo = pccampo
                  AND cramo = pcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect
                  AND cactivi = 0;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  pclave := NULL;
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate,
                              f_user,
                              'pac_tarifas.f_clave',
                              3,
                              'when others pcgarant =' || pcgarant ||
                              ' pcramo =' || pcramo || ' pcmodali =' ||
                              pcmodali || ' pctipseg =' || pctipseg ||
                              ' pccolect =' || pccolect || ' pccampo = ' ||
                              pccampo,
                              SQLERRM);
                  RETURN 108422; --'Error en selección del código'
            END;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'pac_tarifas.f_clave',
                        4,
                        'when others pcgarant =' || pcgarant || ' pcramo =' ||
                        pcramo || ' pcmodali =' || pcmodali ||
                        ' pctipseg =' || pctipseg || ' pccolect =' ||
                        pccolect || ' pccampo = ' || pccampo,
                        SQLERRM);
            RETURN 108422; --'Error en selección del código'
      END;

      RETURN 0;
   END f_clave;

   FUNCTION f_clave_rea(pscontra IN NUMBER,
                        pnversio IN NUMBER,
                        pcgarant IN NUMBER,
                        psproduc IN NUMBER,
                        pcampo   IN VARCHAR2,
                        pclav    OUT NUMBER) RETURN NUMBER IS
   BEGIN
      BEGIN
         SELECT clave
           INTO pclav
           FROM reaformula
          WHERE scontra = pscontra
            AND nversio = pnversio
            AND cgarant = pcgarant
            AND sproduc = psproduc
            AND ccampo = pcampo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT clave
                 INTO pclav
                 FROM reaformula
                WHERE scontra = pscontra
                  AND nversio = pnversio
                  AND cgarant = pcgarant
                  AND sproduc IS NULL
                  AND ccampo = pcampo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  pclav := NULL;
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate,
                              f_user,
                              'pac_tarifas.f_clave_rea',
                              3,
                              'when others pscontra =' || pscontra ||
                              ' pnversio =' || pnversio || ' pcgarant =' ||
                              pcgarant || ' psproduc =' || psproduc ||
                              ' pcampo =' || pcampo,
                              SQLERRM);
                  RETURN 108422; --'Error en selección del código'
            END;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'pac_tarifas.f_clave_rea',
                        4,
                        'when others pscontra =' || pscontra ||
                        ' pnversio =' || pnversio || ' pcgarant =' ||
                        pcgarant || ' psproduc =' || psproduc ||
                        ' pcampo =' || pcampo,
                        SQLERRM);
            RETURN 108422; --'Error en selección del código'
      END;

      RETURN 0;
   END f_clave_rea;

   FUNCTION f_tarifar(psesion            IN NUMBER,
                      pcmanual           IN NUMBER,
                      pcramo             IN NUMBER,
                      pcmodali           IN NUMBER,
                      pctipseg           IN NUMBER,
                      pccolect           IN NUMBER,
                      pcactivi           IN NUMBER,
                      pcgarant           IN NUMBER,
                      pcont              IN NUMBER,
                      parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb,
                      piprianu           IN OUT NUMBER,
                      pipritar           IN OUT NUMBER,
                      prevcap            IN OUT NUMBER,
                      pcapitalcal        OUT NUMBER,
                      pdtocom            OUT NUMBER,
                      ptasa              IN OUT NUMBER,
                      pmensa             IN OUT VARCHAR2,
                      pmoneda            IN NUMBER,
                      pctarifa           IN NUMBER,
                      pnmovimi           IN NUMBER,
                      pnmovima           IN NUMBER,
                      -- Mantis 10728.NMM.i.01/07/2009.CEM - Asignación automática de sobreprima.
                      p_iextrap OUT NUMBER /* Extraprima */,
                      p_isobrep OUT NUMBER, /* Sobreprima */
                      /* Mantis 10728.NMM.f. */
                      p_tregconcep OUT pac_parm_tarifas.tregconcep_tabtyp,
                      paccion      IN VARCHAR2 DEFAULT 'NP') -- BUG 34462 - AFM 01/2015)   -- Bug 21121 - APD - 22/02/2012
    RETURN NUMBER IS
      /******************************************************************************
       SMF: función que tarifa una garantia , parametros:
           pcmanual :ctarman de la poliza (garantia).
           pcont :numero de garantia en la que estamos.
      ******************************************************************************/
      clav         NUMBER := NULL;
      formula      VARCHAR2(2000);
      error        NUMBER;
      valor        NUMBER := NULL;
      xctipatr     NUMBER;
      num_err      NUMBER;
      clav_aux     NUMBER;
      pipritar_sum NUMBER := 0;
      pipritar_aux NUMBER := 0;
      nveces       NUMBER;
      /*ponemos la variable valor a null antes de realizar cualquier
      calculo de esta forma si el calculo genera un error lo podremos detectar*/
      -- I - JLB - OPTIMIZA
      --      CURSOR tmp IS
      --         SELECT *
      --           FROM sgt_parms_transitorios
      --          WHERE sesion = psesion;
      -- F - JLB - OPTIMIZA
      -- Bug 21121 - APD - 22/02/2012
      v_sproduc           productos.sproduc%TYPE;
      v_parprod_detprimas parproductos.cvalpar%TYPE;
      vnriesgo_ini        NUMBER;
      -- fin Bug 21121 - APD - 22/02/2012
	  vfinivig DATE;
      vffinvig DATE; 
      VALOR_MES NUMBER;
      CANTIDAD_MESES NUMBER;
	  
   BEGIN
      DECLARE
         -- I - JLB
         vnerror NUMBER;
         -- F - JLB
      BEGIN
         -- I - JLB
         --INSERT INTO sgt_parms_transitorios
         --          (sesion, parametro, valor)
         --  VALUES (psesion, 'SESION', psesion);
         vnerror := pac_sgt.put(psesion, 'SESION', psesion);

         IF vnerror <> 0
         THEN
            RETURN 108438;
         END IF;
         -- F - JLB
      EXCEPTION
         WHEN dup_val_on_index THEN
            NULL;
            --la sesion puede que se halla insertado previamente ya que es necesaria
         --para instroducir las preguntas (se inserta a nivel de riesgo no de seguro)
         WHEN OTHERS THEN
            RETURN 108438;
      END;

      BEGIN
         SELECT sproduc
           INTO v_sproduc
           FROM productos
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 102705; --Error al leer la tabla PRODUCTOS
      END;

      -- Bug 28041/155911 - APD - 15/10/2013
      IF (NOT (pac_iax_produccion.isaltacol AND
          NVL(pac_parametros.f_parproducto_n(v_sproduc,
                                                  'TARIFA_POLIZACERO'),
                   0) = 0)) OR
         NVL(pac_parametros.f_parproducto_n(v_sproduc, 'TARIFA_POLIZACERO'),
             0) = 1
      THEN
         IF pcmanual = 0
         THEN
            -- Bug 21121 - APD - 27/02/2012 - se busca el valor del parproducto DETPRIMAS
            v_parprod_detprimas := NVL(f_parproductos_v(v_sproduc,
                                                        'DETPRIMAS'),
                                       0);

            -- fin Bug 21121 - APD - 27/02/2012
            IF paccion = 'RG'
            THEN
               --PAra rgularización sólo calculamos TASA e IPRITAR
               IF v_parprod_detprimas = 1
               THEN
                  num_err := pac_tarifas.f_dettarifar(v_sproduc,
                                                      pcactivi,
                                                      pcgarant,
                                                      'TASA',
                                                      psesion,
                                                      pcont,
                                                      parms_transitorios,
                                                      p_tregconcep);

                  IF NVL(num_err, 0) <> 0
                  THEN
                     pmensa := pcgarant || '.Tasa';
                     RETURN num_err;
                  END IF;
               END IF;

               -- fin Bug 21121 - APD - 23/02/2012

               -- Para pcmanual = 2 se toma directamente la prima tarifa revalorizada.
               num_err := f_clave(pcgarant,
                                  pcramo,
                                  pcmodali,
                                  pctipseg,
                                  pccolect,
                                  pcactivi,
                                  'TASA',
                                  clav);

               IF NVL(num_err, 0) <> 0
               THEN
                  pmensa := pcgarant || '.Tasa';
                  RETURN 108422; --'Error en selección del código'
               END IF;

               IF clav IS NULL
               THEN
                  piprianu := 0;
                  pipritar := 0;
               ELSE
                  BEGIN
                     SELECT formula
                       INTO formula
                       FROM sgt_formulas
                      WHERE clave = clav;
                  EXCEPTION
                     WHEN OTHERS THEN
                        pmensa := pcgarant || '.Tasa';
                        RETURN 108423; -- Error en selección de sgt_formulas
                  END;

                  pac_parm_tarifas.inserta_parametro(psesion,
                                                     clav,
                                                     pcont,
                                                     parms_transitorios,
                                                     error,
                                                     NULL,
                                                     p_tregconcep);

                  -- Hay que asegurarse  que parms_tran, esta informado con todos los parametros
                  -- necesarios.
                  IF error <> 0
                  THEN
                     pmensa := pcgarant || '.Tasa';
                     RETURN(error);
                  END IF;

                  --JRH Bug 29920
                  --  IF NVL(f_parproductos_v(v_sproduc, 'SGT_CONMU'), 0) = 1 THEN
                  IF NVL(pac_parametros.f_pargaranpro_n(v_sproduc,
                                                        pcactivi,
                                                        pcgarant,
                                                        'SGT_CONMU'),
                         0) = 1
                  THEN
                     num_err := pac_formul_tarificador.iniciarparametros(psesion);
                  END IF;

                  --Fin JRH Bug 29920
                  valor := pk_formulas.eval(formula, psesion);

                  IF valor IS NULL
                  THEN
                     pmensa := pcgarant || '.Tasa';
                     p_tab_error(f_sysdate,
                                 f_user,
                                 'pac_tarifas',
                                 1,
                                 'tarifa no encontrada para la garantía',
                                 formula || '  Sesion: ' || psesion ||
                                 '  .Tasa');
                     RETURN 108437;
                  ELSE
                     IF pctarifa IS NOT NULL
                     THEN
                        BEGIN
                           SELECT ctipatr
                             INTO xctipatr
                             FROM coditarifa
                            WHERE ctarifa = pctarifa;
                        EXCEPTION
                           WHEN OTHERS THEN
                              RETURN 107633;
                        END;
                     END IF;

                     IF pctarifa IS NULL OR
                        xctipatr = 2
                     THEN
                        ptasa := valor;
                     ELSE
                        ptasa := f_round(valor, pmoneda);
                     END IF;
                  END IF;

                  pac_parm_tarifas.borra_parametro(psesion, clav);
               END IF;

               IF v_parprod_detprimas = 1
               THEN
                  -- INI BUG 34462 - AFM
                  parms_transitorios(pcont).icapital := NVL(pcapitalcal,
                                                            prevcap);
                  num_err := pac_tarifas.f_dettarifar(v_sproduc,
                                                      pcactivi,
                                                      pcgarant,
                                                      'PRIREGUL',
                                                      psesion,
                                                      pcont,
                                                      parms_transitorios,
                                                      p_tregconcep);

                  IF NVL(num_err, 0) <> 0
                  THEN
                     pmensa := pcgarant || '.Prima Regularización';
                     RETURN num_err;
                  END IF;
               END IF;

               -- fin Bug 21121 - APD - 23/02/2012
               clav  := NULL;
               valor := NULL;
               -- INI BUG 34462 - AFM
               num_err := f_clave(pcgarant,
                                  pcramo,
                                  pcmodali,
                                  pctipseg,
                                  pccolect,
                                  pcactivi,
                                  'PRIREGUL',
                                  clav);

               -- FIN BUG 34462 - AFM
               IF NVL(num_err, 0) <> 0
               THEN
                  -- INI BUG 34462 - AFM
                  pmensa := pcgarant || '.Prima Regularización';
                  -- FIN BUG 34462 - AFM
                  RETURN 108422; --'Error en selección del código'
               END IF;

               IF clav IS NULL
               THEN
                  piprianu := 0;
                  pipritar := 0;
                  -- INI BUG 34462 - AFM
                  pmensa := pcgarant || '.Prima Regularización';
                  -- FIN BUG 34462 - AFM
                  --RETURN 0;  -- -- No hay prima_tarifa para esta garantía.--> Tampoco prima_anual
               ELSE
                  BEGIN
                     SELECT formula
                       INTO formula
                       FROM sgt_formulas
                      WHERE clave = clav;
                  EXCEPTION
                     WHEN OTHERS THEN
                        -- INI BUG 34462 - AFM
                        pmensa := pcgarant || '.Prima Regularización';
                        -- FIN BUG 34462 - AFM
                        RETURN 108423;
                        -- mensa := 'Error en selección de sgt_formulas'||sqlcode||sqlerrm;
                  END;

                  parms_transitorios(pcont).icapital := NVL(pcapitalcal,
                                                            prevcap);
                  -- Bug 20149 - 16/11/2011 - JRH - 0020149: LCOL_T001-Renovacion no anual (decenal)
                  parms_transitorios(pcont).tasa := ptasa;
                  -- fi Bug 20149 - 16/11/2011 - JRH
                  pac_parm_tarifas.inserta_parametro(psesion,
                                                     clav,
                                                     pcont,
                                                     parms_transitorios,
                                                     error,
                                                     NULL,
                                                     p_tregconcep);

                  IF error <> 0
                  THEN
                     -- INI BUG 34462 - AFM
                     pmensa := pcgarant || '.Prima Regularización';
                     -- FIN BUG 34462 - AFM
                     RETURN(error);
                  END IF;

                  --JRH Bug 29920
                  IF NVL(pac_parametros.f_pargaranpro_n(v_sproduc,
                                                        pcactivi,
                                                        pcgarant,
                                                        'SGT_CONMU'),
                         0) = 1
                  THEN
                     num_err := pac_formul_tarificador.iniciarparametros(psesion);
                  END IF;

                  --Fin JRH Bug 29920
                  valor := pk_formulas.eval(formula, psesion);

                  IF valor IS NULL
                  THEN
                     -- INI BUG 34462 - AFM
                     pmensa := pcgarant || '.Prima Regularización';
                     -- FIN BUG 34462 - AFM
                     p_tab_error(f_sysdate,
                                 f_user,
                                 'pac_tarifas',
                                 4,
                                 'tarifa no encontrada para la garantía',
                                 formula || '  Sesion: ' || psesion ||
                                 '  .Prima tarifa');
                     RETURN 108437;
                  ELSE
                     --commit;
                     --return 108437;
                     pipritar := f_round(valor, pmoneda);
                  END IF;

                  pac_parm_tarifas.borra_parametro(psesion, clav);
               END IF;

               piprianu := pipritar;

               IF v_parprod_detprimas = 1
               THEN
                  --JRH IMP   Borramos los detalles de garantía para esta garantía
                  -- JLB - I
                  -- DELETE FROM sgt_parms_transitorios
                  --      WHERE sesion = psesion
                  --        AND EXISTS(SELECT 1
                  --                    FROM codcampo c
                  --                   WHERE c.ccampo = sgt_parms_transitorios.parametro
                  --                     AND c.cutili = 10);
                  FOR reg IN (SELECT ccampo
                                FROM codcampo c
                               WHERE --c.ccampo = sgt_parms_transitorios.parametro
                              --AND
                               c.cutili = 10)
                  LOOP
                     -- JLB - esto se tendria que optimizar
                     num_err := pac_sgt.del(psesion, reg.ccampo);
                     num_err := pac_sgt.del(psesion, reg.ccampo || '_V');
                  END LOOP;
                  -- JLB - ESTO LO ELIMINO PORQUE YA HE BORRADO TODOS EN EL CURSOR ANTERIOR
                  --DELETE FROM sgt_parms_transitorios
                  --      WHERE sesion = psesion
                  --       AND EXISTS(SELECT 1
                  --                    FROM codcampo c
                  --                   WHERE c.ccampo || '_V' = sgt_parms_transitorios.parametro
                  --                     AND c.cutili = 10);
                  -- JLB - F
               END IF;

               RETURN 0;
            END IF; -- RG

            -- Bug 21121 - APD - 23/02/2012 - se añade la llamada a f_dettarifar
            IF v_parprod_detprimas = 1
            THEN
               num_err := pac_tarifas.f_dettarifar(v_sproduc,
                                                   pcactivi,
                                                   pcgarant,
                                                   'TASA',
                                                   psesion,
                                                   pcont,
                                                   parms_transitorios,
                                                   p_tregconcep);

               IF NVL(num_err, 0) <> 0
               THEN
                  pmensa := pcgarant || '.Tasa';
                  RETURN num_err;
               END IF;
            END IF;

            -- fin Bug 21121 - APD - 23/02/2012

            -- Para pcmanual = 2 se toma directamente la prima tarifa revalorizada.
            num_err := f_clave(pcgarant,
                               pcramo,
                               pcmodali,
                               pctipseg,
                               pccolect,
                               pcactivi,
                               'TASA',
                               clav);

            IF NVL(num_err, 0) <> 0
            THEN
               pmensa := pcgarant || '.Tasa';
               RETURN 108422; --'Error en selección del código'
            END IF;

            IF clav IS NULL
            THEN
               piprianu := 0;
               pipritar := 0;
            ELSE
               BEGIN
                  SELECT formula
                    INTO formula
                    FROM sgt_formulas
                   WHERE clave = clav;
               EXCEPTION
                  WHEN OTHERS THEN
                     pmensa := pcgarant || '.Tasa';
                     RETURN 108423; -- Error en selección de sgt_formulas
               END;

               pac_parm_tarifas.inserta_parametro(psesion,
                                                  clav,
                                                  pcont,
                                                  parms_transitorios,
                                                  error,
                                                  NULL,
                                                  p_tregconcep);

               -- Hay que asegurarse  que parms_tran, esta informado con todos los parametros
               -- necesarios.
               IF error <> 0
               THEN
                  pmensa := pcgarant || '.Tasa';
                  RETURN(error);
               END IF;

               --JRH Bug 29920
               --  IF NVL(f_parproductos_v(v_sproduc, 'SGT_CONMU'), 0) = 1 THEN
               IF NVL(pac_parametros.f_pargaranpro_n(v_sproduc,
                                                     pcactivi,
                                                     pcgarant,
                                                     'SGT_CONMU'),
                      0) = 1
               THEN
                  num_err := pac_formul_tarificador.iniciarparametros(psesion);
               END IF;

               --Fin JRH Bug 29920
               valor := pk_formulas.eval(formula, psesion);

               IF valor IS NULL
               THEN
                  pmensa := pcgarant || '.Tasa';
                  p_tab_error(f_sysdate,
                              f_user,
                              'pac_tarifas',
                              1,
                              'tarifa no encontrada para la garantía',
                              formula || '  Sesion: ' || psesion ||
                              '  .Tasa');
                  RETURN 108437;
               ELSE
                  IF pctarifa IS NOT NULL
                  THEN
                     BEGIN
                        SELECT ctipatr
                          INTO xctipatr
                          FROM coditarifa
                         WHERE ctarifa = pctarifa;
                     EXCEPTION
                        WHEN OTHERS THEN
                           RETURN 107633;
                     END;
                  END IF;

                  IF pctarifa IS NULL OR
                     xctipatr = 2
                  THEN
                     ptasa := valor;
                  ELSE
                     ptasa := f_round(valor, pmoneda);
                  END IF;
               END IF;

               pac_parm_tarifas.borra_parametro(psesion, clav);
            END IF;

            -----------------------------------------
            -- Calculo del capital
            -----------------------------------------

            -- Bug 21121 - APD - 23/02/2012 - se añade la llamada a f_dettarifar
            IF v_parprod_detprimas = 1
            THEN
               num_err := pac_tarifas.f_dettarifar(v_sproduc,
                                                   pcactivi,
                                                   pcgarant,
                                                   'ICAPITAL',
                                                   psesion,
                                                   pcont,
                                                   parms_transitorios,
                                                   p_tregconcep);

               IF NVL(num_err, 0) <> 0
               THEN
                  pmensa := pcgarant || '.Capital';
                  RETURN num_err;
               END IF;
            END IF;

            -- fin Bug 21121 - APD - 23/02/2012
            clav    := NULL;
            valor   := NULL;
            num_err := f_clave(pcgarant,
                               pcramo,
                               pcmodali,
                               pctipseg,
                               pccolect,
                               pcactivi,
                               'ICAPITAL',
                               clav);

            IF NVL(num_err, 0) <> 0
            THEN
               pmensa := pcgarant || '.CapitalY';
               RETURN 108422; --'Error en selección del código'
            END IF;

            IF clav IS NULL
            THEN
               piprianu := 0;
               pipritar := 0;
               pmensa   := pcgarant || '.Capitalx';
            ELSE
               BEGIN
                  SELECT formula
                    INTO formula
                    FROM sgt_formulas
                   WHERE clave = clav;
               EXCEPTION
                  WHEN OTHERS THEN
                     pmensa := pcgarant || '.Capital';
                     RETURN 108423;
               END;

               parms_transitorios(pcont).icapital := prevcap;
               pac_parm_tarifas.inserta_parametro(psesion,
                                                  clav,
                                                  pcont,
                                                  parms_transitorios,
                                                  error,
                                                  NULL,
                                                  p_tregconcep);

               IF error <> 0
               THEN
                  pmensa := pcgarant || '.Capital';
                  RETURN(error);
               END IF;

               valor := pk_formulas.eval(formula, psesion);

               IF valor IS NULL
               THEN
                  pmensa := pcgarant || '.Capital';
                  p_tab_error(f_sysdate,
                              f_user,
                              'pac_tarifas',
                              2,
                              'tarifa no encontrada para la garantía',
                              formula || '  Sesion: ' || psesion ||
                              '  .Capital');
                  RETURN 108437;
               ELSE
                  prevcap := valor;
               END IF;

               pac_parm_tarifas.borra_parametro(psesion, clav);
            END IF;

            -- Calculo del capital CALCULADO
            -----------------------------------------

            -- Bug 21121 - APD - 23/02/2012 - se añade la llamada a f_dettarifar
            IF v_parprod_detprimas = 1
            THEN
               num_err := pac_tarifas.f_dettarifar(v_sproduc,
                                                   pcactivi,
                                                   pcgarant,
                                                   'ICAPCAL',
                                                   psesion,
                                                   pcont,
                                                   parms_transitorios,
                                                   p_tregconcep);

               IF NVL(num_err, 0) <> 0
               THEN
                  pmensa := pcgarant || '.Capital';
                  RETURN num_err;
               END IF;
            END IF;

            -- fin Bug 21121 - APD - 23/02/2012
            clav    := NULL;
            valor   := NULL;
            num_err := f_clave(pcgarant,
                               pcramo,
                               pcmodali,
                               pctipseg,
                               pccolect,
                               pcactivi,
                               'ICAPCAL',
                               clav);

            IF NVL(num_err, 0) <> 0
            THEN
               pmensa := pcgarant || '.CapitalY';
               RETURN 108422; --'Error en selección del código'
            END IF;

            IF clav IS NULL
            THEN
               piprianu := 0;
               pipritar := 0;
               pmensa   := pcgarant || '.Capitalx';
            ELSE
               BEGIN
                  SELECT formula
                    INTO formula
                    FROM sgt_formulas
                   WHERE clave = clav;
               EXCEPTION
                  WHEN OTHERS THEN
                     pmensa := pcgarant || '.Capital';
                     RETURN 108423;
               END;

               --  parms_transitorios(pcont).icapital := PREVCAP;
               pac_parm_tarifas.inserta_parametro(psesion,
                                                  clav,
                                                  pcont,
                                                  parms_transitorios,
                                                  error,
                                                  NULL,
                                                  p_tregconcep);

               IF error <> 0
               THEN
                  pmensa := pcgarant || '.Capital';
                  RETURN(error);
               END IF;

               --JRH Bug 29920
               IF NVL(pac_parametros.f_pargaranpro_n(v_sproduc,
                                                     pcactivi,
                                                     pcgarant,
                                                     'SGT_CONMU'),
                      0) = 1
               THEN
                  num_err := pac_formul_tarificador.iniciarparametros(psesion);
               END IF;

               --Fin JRH Bug 29920
               valor := pk_formulas.eval(formula, psesion);

               IF valor IS NULL
               THEN
                  pmensa := pcgarant || '.Capital';
                  p_tab_error(f_sysdate,
                              f_user,
                              'pac_tarifas',
                              3,
                              'tarifa no encontrada para la garantía',
                              formula || '  Sesion: ' || psesion ||
                              '  .Capital');
                  RETURN 108437;
               ELSE
                  pcapitalcal := valor;
               END IF;

               pac_parm_tarifas.borra_parametro(psesion, clav);
            END IF;

            -----------------------------------------
            -- Calculo del capital Maximo
            -----------------------------------------
            /*          ... codi eliminat ...         */
            -----------------------------------------------------------------------
            -- Mantis 10728.NMM.i.01/07/2009.CEM - Asig. automática de sobreprima.
            --
            -----------------------------------------
            -- Càlcul Import d' Extraprima.
            -----------------------------------------

            -- Bug 21121 - APD - 23/02/2012 - se añade la llamada a f_dettarifar
            IF v_parprod_detprimas = 1
            THEN
               num_err := pac_tarifas.f_dettarifar(v_sproduc,
                                                   pcactivi,
                                                   pcgarant,
                                                   'PEXTRAP',
                                                   psesion,
                                                   pcont,
                                                   parms_transitorios,
                                                   p_tregconcep);

               IF NVL(num_err, 0) <> 0
               THEN
                  pmensa := pcgarant || '.ExtraPrima';
                  RETURN num_err;
               END IF;
            END IF;

            -- fin Bug 21121 - APD - 23/02/2012
            clav    := NULL;
            valor   := NULL;
            num_err := f_clave(pcgarant,
                               pcramo,
                               pcmodali,
                               pctipseg,
                               pccolect,
                               pcactivi,
                               'PEXTRAP',
                               clav);

            IF NVL(num_err, 0) <> 0
            THEN
               pmensa := pcgarant || '.ExtraPrima';
               RETURN(108422); -- Error en selecció del codi.
            END IF;

            IF clav IS NULL
            THEN
               piprianu := 0;
               pipritar := 0;
               pmensa   := pcgarant || '.ExtraPrima';
            ELSE
               BEGIN
                  SELECT formula
                    INTO formula
                    FROM sgt_formulas
                   WHERE clave = clav;
               EXCEPTION
                  WHEN OTHERS THEN
                     pmensa := pcgarant || '.ExtraPrima';
                     RETURN(108423); -- Error en la selecció d'SGT_FORMULAS.
               END;

               --parms_transitorios(pcont).extrapr := p_iextrap;  -- ????????????

               -- Bug 20149 - 16/11/2011 - JRH - 0020149: LCOL_T001-Renovacion no anual (decenal)
               parms_transitorios(pcont).tasa := ptasa;
               -- fi Bug 20149 - 16/11/2011 - JRH
               pac_parm_tarifas.inserta_parametro(psesion,
                                                  clav,
                                                  pcont,
                                                  parms_transitorios,
                                                  error,
                                                  NULL,
                                                  p_tregconcep);

               IF error <> 0
               THEN
                  pmensa := pcgarant || '.ExtraPrima';
                  RETURN(error);
               END IF;

               valor := pk_formulas.eval(formula, psesion);

               IF valor IS NULL
               THEN
                  pmensa := pcgarant || '.ExtraPrima';
                  p_tab_error(f_sysdate,
                              f_user,
                              'pac_tarifas',
                              4,
                              'Extraprima',
                              formula || '  Sesion: ' || psesion ||
                              '  .ExtraPrima');
                  RETURN(108437);
                  -- No s'ha trobat la tarifa per a la garantia.
               ELSE
                  p_iextrap := valor; -- Variable de sortida.
               END IF;

               parms_transitorios(pcont).extrapr := p_iextrap;
               -- No hauria d'anar abans del inserta_parametro ????
               pac_parm_tarifas.borra_parametro(psesion, clav);
            END IF;

            -----------------------------------------
            -- Càlcul percentatge de Sobreprima.
            -----------------------------------------

            -- Bug 21121 - APD - 23/02/2012 - se añade la llamada a f_dettarifar
            IF v_parprod_detprimas = 1
            THEN
               num_err := pac_tarifas.f_dettarifar(v_sproduc,
                                                   pcactivi,
                                                   pcgarant,
                                                   'PSOBREP',
                                                   psesion,
                                                   pcont,
                                                   parms_transitorios,
                                                   p_tregconcep);

               IF NVL(num_err, 0) <> 0
               THEN
                  pmensa := pcgarant || '.SobrePrima';
                  RETURN num_err;
               END IF;
            END IF;

            -- fin Bug 21121 - APD - 23/02/2012
            clav    := NULL;
            valor   := NULL;
            num_err := f_clave(pcgarant,
                               pcramo,
                               pcmodali,
                               pctipseg,
                               pccolect,
                               pcactivi,
                               'PSOBREP',
                               clav);

            IF NVL(num_err, 0) <> 0
            THEN
               pmensa := pcgarant || '.SobrePrima';
               RETURN(108422); -- Error en selecció del codi.
            END IF;

            IF clav IS NULL
            THEN
               piprianu := 0;
               pipritar := 0;
               pmensa   := pcgarant || '.SobrePrima';
            ELSE
               BEGIN
                  SELECT formula
                    INTO formula
                    FROM sgt_formulas
                   WHERE clave = clav;
               EXCEPTION
                  WHEN OTHERS THEN
                     pmensa := pcgarant || '.SobrePrima';
                     RETURN(108423); -- Error en la selecció d'SGT_FORMULAS.
               END;

               pac_parm_tarifas.inserta_parametro(psesion,
                                                  clav,
                                                  pcont,
                                                  parms_transitorios,
                                                  error,
                                                  NULL,
                                                  p_tregconcep);

               IF error <> 0
               THEN
                  pmensa := pcgarant || '.SobrePrima';
                  RETURN(error);
               END IF;

               valor := pk_formulas.eval(formula, psesion);

               IF valor IS NULL
               THEN
                  pmensa := pcgarant || '.SobrePrima';
                  p_tab_error(f_sysdate,
                              f_user,
                              'pac_tarifas',
                              4,
                              'SobrePrima',
                              formula || '  Sesion: ' || psesion ||
                              '  .SobrePrima');
                  RETURN(108437);
                  -- No s'ha trobat la tarifa per a la garantia.
               ELSE
                  -- Bug 24926 - MMS - 14/01/2013 - Quitar el round en la sobreprima de la tarifa
                  p_isobrep := valor; -- Variable de sortida.
               END IF;

               pac_parm_tarifas.borra_parametro(psesion, clav);
            END IF;

            --
            -- Mantis 10728.NMM.f.01/07/2009.CEM - Assig. automática de sobreprima.
            -----------------------------------------------------------------------
            -----------------------------------------
            -- Calculo la prima tarifa de la garantía
            -----------------------------------------

            -- Bug 21121 - APD - 23/02/2012 - se añade la llamada a f_dettarifar
            IF v_parprod_detprimas = 1
            THEN
               parms_transitorios(pcont).icapital := NVL(pcapitalcal,
                                                         prevcap);
               num_err := pac_tarifas.f_dettarifar(v_sproduc,
                                                   pcactivi,
                                                   pcgarant,
                                                   'IPRITAR',
                                                   psesion,
                                                   pcont,
                                                   parms_transitorios,
                                                   p_tregconcep);

               IF NVL(num_err, 0) <> 0
               THEN
                  pmensa := pcgarant || '.Prima Tarifa';
                  RETURN num_err;
               END IF;
            END IF;

            -- fin Bug 21121 - APD - 23/02/2012
            clav    := NULL;
            valor   := NULL;
            num_err := f_clave(pcgarant,
                               pcramo,
                               pcmodali,
                               pctipseg,
                               pccolect,
                               pcactivi,
                               'IPRITAR',
                               clav);

            IF NVL(num_err, 0) <> 0
            THEN
               pmensa := pcgarant || '.Prima Tarifa';
               RETURN 108422; --'Error en selección del código'
            END IF;

            IF clav IS NULL
            THEN
               piprianu := 0;
               pipritar := 0;
               pmensa   := pcgarant || '.Prima Tarifa';
               --RETURN 0;  -- -- No hay prima_tarifa para esta garantía.--> Tampoco prima_anual
            ELSE
               BEGIN
                  SELECT formula
                    INTO formula
                    FROM sgt_formulas
                   WHERE clave = clav;
               EXCEPTION
                  WHEN OTHERS THEN
                     pmensa := pcgarant || '.Prima Tarifa';
                     RETURN 108423;
                     -- mensa := 'Error en selección de sgt_formulas'||sqlcode||sqlerrm;
               END;

               parms_transitorios(pcont).icapital := NVL(pcapitalcal,
                                                         prevcap);
               -- Bug 20149 - 16/11/2011 - JRH - 0020149: LCOL_T001-Renovacion no anual (decenal)
               parms_transitorios(pcont).tasa := ptasa;
               -- fi Bug 20149 - 16/11/2011 - JRH
               pac_parm_tarifas.inserta_parametro(psesion,
                                                  clav,
                                                  pcont,
                                                  parms_transitorios,
                                                  error,
                                                  NULL,
                                                  p_tregconcep);

               IF error <> 0
               THEN
                  pmensa := pcgarant || '.Prima Tarifa';
                  RETURN(error);
               END IF;

               --JRH Bug 29920
               IF NVL(pac_parametros.f_pargaranpro_n(v_sproduc,
                                                     pcactivi,
                                                     pcgarant,
                                                     'SGT_CONMU'),
                      0) = 1
               THEN
                  num_err := pac_formul_tarificador.iniciarparametros(psesion);
               END IF;

               --Fin JRH Bug 29920
               valor := pk_formulas.eval(formula, psesion);
			   
			   --bartolo herrera 23/07/2019 inicio

	       -- Inicio IAXIS-5031 29/08/2019
               -- Se comenta la siguiente secci�n de c�digo. Se traslada a la f�rmula 750022 para facilitar la
               -- implementaci�n de las primas m�nimas para dichos producto y garant�a.
               /*if pcgarant = 7762 AND pac_iax_produccion.poliza.det_poliza.sproduc = 8062 then 

                   select finivig,ffinvig into vfinivig,vffinvig from estgaranseg
                   WHERE sseguro = pac_iax_produccion.poliza.det_poliza.sseguro
                   AND nmovimi = pac_iax_produccion.poliza.det_poliza.nmovimi and cgarant = pcgarant;

                   CANTIDAD_MESES := MONTHS_BETWEEN(vffinvig,vfinivig);
                   VALOR_MES := valor/12;
                   valor := VALOR_MES * CANTIDAD_MESES;

               end if;*/

			  --bartolo herrera 23/07/2019 fin
               -- Fin IAXIS-5031 29/08/2019
			  
			  --bartolo herrera 02/08/2019 inicio
			  
			  if (pcgarant = 7050 AND pac_iax_produccion.poliza.det_poliza.sproduc = 8063) then 
                    
                    select NVL(CRESPUE, 0) INTO valor from estpregungaranseg where sseguro = pac_iax_produccion.poliza.det_poliza.sseguro
                    and cpregun = 2442 and nmovimi = pac_iax_produccion.poliza.det_poliza.nmovimi and cgarant = pcgarant;
                    
              end if;
			  
			  --bartolo herrera 02/08/2019 fin
			  
               IF valor IS NULL
               THEN
                  pmensa := pcgarant || '.Prima Tarifa';
                  p_tab_error(f_sysdate,
                              f_user,
                              'pac_tarifas',
                              4,
                              'tarifa no encontrada para la garantía',
                              formula || '  Sesion: ' || psesion ||
                              '  .Prima tarifa');
                  RETURN 108437;
               ELSE
                  --commit;
                  --return 108437;
                  pipritar := f_round(valor, pmoneda);
               END IF;

               pac_parm_tarifas.borra_parametro(psesion, clav);
            END IF;
         END IF; -- De pcmanual = 0

         ----------------------------------------
         -- Calculo la prima anual de la garantía
         ----------------------------------------

         -- Bug 21121 - APD - 23/02/2012 - se añade la llamada a f_dettarifar
         IF v_parprod_detprimas = 1
         THEN
            num_err := pac_tarifas.f_dettarifar(v_sproduc,
                                                pcactivi,
                                                pcgarant,
                                                'IPRIANU',
                                                psesion,
                                                pcont,
                                                parms_transitorios,
                                                p_tregconcep);

            IF NVL(num_err, 0) <> 0
            THEN
               pmensa := pcgarant || '.Prima Anual';
               RETURN num_err;
            END IF;
         END IF;

         -- fin Bug 21121 - APD - 23/02/2012
         clav    := NULL;
         valor   := NULL;
         num_err := f_clave(pcgarant,
                            pcramo,
                            pcmodali,
                            pctipseg,
                            pccolect,
                            pcactivi,
                            'IPRIANU',
                            clav);

         IF NVL(num_err, 0) <> 0
         THEN
            pmensa := pcgarant || '.Prima Anual';
            RETURN 108422; --'Error en selección del código'
         END IF;

         IF clav IS NULL
         THEN
            piprianu := pipritar;
            --   RETURN 0;  -- -- No hay prima_tarifa para esta garantía.--> Tampoco prima_anual
         ELSE
            BEGIN
               SELECT formula
                 INTO formula
                 FROM sgt_formulas
                WHERE clave = clav;
            EXCEPTION
               WHEN OTHERS THEN
                  pmensa := pcgarant || '.Prima Anual';
                  RETURN 108423;
                  --mensa := 'Error en selección de sgt_formulas'||sqlcode||sqlerrm;
            END;

            parms_transitorios(pcont).ipritar := pipritar;
            pac_parm_tarifas.inserta_parametro(psesion,
                                               clav,
                                               pcont,
                                               parms_transitorios,
                                               error,
                                               NULL,
                                               p_tregconcep);

            IF error <> 0
            THEN
               pmensa := pcgarant || '.Prima Anual';
               RETURN(error);
            END IF;

            valor := pk_formulas.eval(formula, psesion);

            IF valor IS NULL
            THEN
               pmensa := pcgarant || '.Prima Anual';
               p_tab_error(f_sysdate,
                           f_user,
                           'pac_tarifas',
                           7,
                           'tarifa no encontrada para la garantía',
                           formula || '  Sesion: ' || psesion ||
                           '  .Prima Anual');
               RETURN 108437;
            ELSE
               piprianu := f_round(valor, pmoneda);
            END IF;

            pac_parm_tarifas.borra_parametro(psesion, clav);
         END IF;

         -----------------------------------------
         -- Calculo del descuento comercial
         -----------------------------------------

         -- Bug 21121 - APD - 23/02/2012 - se añade la llamada a f_dettarifar
         IF v_parprod_detprimas = 1
         THEN
            num_err := pac_tarifas.f_dettarifar(v_sproduc,
                                                pcactivi,
                                                pcgarant,
                                                'PDTOCOM',
                                                psesion,
                                                pcont,
                                                parms_transitorios,
                                                p_tregconcep);

            IF NVL(num_err, 0) <> 0
            THEN
               pmensa := pcgarant || '.pdtocom';
               RETURN num_err;
            END IF;
         END IF;

         -- fin Bug 21121 - APD - 23/02/2012
         clav  := NULL;
         valor := NULL;

         BEGIN
            SELECT clave
              INTO clav
              FROM garanformula
             WHERE cgarant = pcgarant
               AND ccampo = 'PDTOCOM'
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
                     AND ccampo = 'PDTOCOM'
                     AND cramo = pcramo
                     AND cmodali = pcmodali
                     AND ctipseg = pctipseg
                     AND ccolect = pccolect
                     AND cactivi = 0;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     pdtocom := NULL;
                     pmensa  := pcgarant || '.pdtocomx';
                  WHEN OTHERS THEN
                     pmensa := pcgarant || '.pdtocomY';
                     RETURN 108422;
                     --mensa := 'Error en selección del código'||sqlcode||sqlerrm;
               END;
            WHEN OTHERS THEN
               pmensa := pcgarant || '.pdtocomZ';
               RETURN 108422;
               --mensa := 'Error en selección del código'||sqlcode||sqlerrm;
         END;

         IF clav IS NOT NULL
         THEN
            BEGIN
               SELECT formula
                 INTO formula
                 FROM sgt_formulas
                WHERE clave = clav;
            EXCEPTION
               WHEN OTHERS THEN
                  pmensa := pcgarant || '.pdtocom';
                  RETURN 108423;
            END;

            --  parms_transitorios(pcont).icapital := PREVCAP;
            pac_parm_tarifas.inserta_parametro(psesion,
                                               clav,
                                               pcont,
                                               parms_transitorios,
                                               error,
                                               NULL,
                                               p_tregconcep);

            IF error <> 0
            THEN
               pmensa := pcgarant || '.Pdtocom';
               RETURN(error);
            END IF;

            valor := pk_formulas.eval(formula, psesion);

            IF valor IS NULL
            THEN
               pmensa := pcgarant || '.Pdtocom';
               p_tab_error(f_sysdate,
                           f_user,
                           'pac_tarifas',
                           8,
                           'tarifa no encontrada para la garantía',
                           formula || '  Sesion: ' || psesion ||
                           '  .Pdtocom');
               RETURN 108437;
            ELSE
               pdtocom := valor;
            END IF;

            pac_parm_tarifas.borra_parametro(psesion, clav);
         END IF;

         -- Calculo del capital CALCULADO después de la prima
         -----------------------------------------

         -- Bug 21121 - APD - 23/02/2012 - se añade la llamada a f_dettarifar
         IF v_parprod_detprimas = 1
         THEN
            num_err := pac_tarifas.f_dettarifar(v_sproduc,
                                                pcactivi,
                                                pcgarant,
                                                'CAPCALPS',
                                                psesion,
                                                pcont,
                                                parms_transitorios,
                                                p_tregconcep);

            IF NVL(num_err, 0) <> 0
            THEN
               pmensa := pcgarant || '.Capital';
               RETURN num_err;
            END IF;
         END IF;

         -- fin Bug 21121 - APD - 23/02/2012
         clav    := NULL;
         valor   := NULL;
         num_err := f_clave(pcgarant,
                            pcramo,
                            pcmodali,
                            pctipseg,
                            pccolect,
                            pcactivi,
                            'CAPCALPS',
                            clav);

         IF NVL(num_err, 0) <> 0
         THEN
            pmensa := pcgarant || '.CapitalY';
            RETURN 108422; --'Error en selección del código'
         END IF;

         IF clav IS NOT NULL
         THEN
            BEGIN
               SELECT formula
                 INTO formula
                 FROM sgt_formulas
                WHERE clave = clav;
            EXCEPTION
               WHEN OTHERS THEN
                  pmensa := pcgarant || '.Capital POST';
                  RETURN 108423;
            END;

            parms_transitorios(pcont).iprianu := piprianu;
            pac_parm_tarifas.inserta_parametro(psesion,
                                               clav,
                                               pcont,
                                               parms_transitorios,
                                               error,
                                               NULL,
                                               p_tregconcep);

            IF error <> 0
            THEN
               pmensa := pcgarant || '.Capital';
               RETURN(error);
            END IF;

            valor := pk_formulas.eval(formula, psesion);

            IF valor IS NULL
            THEN
               pmensa := pcgarant || '.Capital';
               p_tab_error(f_sysdate,
                           f_user,
                           'pac_tarifas',
                           3,
                           'tarifa no encontrada para la garantía',
                           formula || '  Sesion: ' || psesion ||
                           '  .Capital POST');
               RETURN 108437;
            ELSE
               pcapitalcal := valor;
            END IF;

            pac_parm_tarifas.borra_parametro(psesion, clav);
         END IF;

         -- Bug 21121 - APD - 05/03/2012 - se inserta en sgt_parms_transitorios valores
         -- de la garantia para tenerlos al tarifar otras garantias
         IF v_parprod_detprimas = 1
         THEN
            --JRH IMP   Borramos los detalles de garantía para esta garantía
            -- JLB - I
            -- DELETE FROM sgt_parms_transitorios
            --      WHERE sesion = psesion
            --        AND EXISTS(SELECT 1
            --                    FROM codcampo c
            --                   WHERE c.ccampo = sgt_parms_transitorios.parametro
            --                     AND c.cutili = 10);
            FOR reg IN (SELECT ccampo
                          FROM codcampo c
                         WHERE --c.ccampo = sgt_parms_transitorios.parametro
                        --AND
                         c.cutili = 10)
            LOOP
               -- JLB - esto se tendria que optimizar
               num_err := pac_sgt.del(psesion, reg.ccampo);
               num_err := pac_sgt.del(psesion, reg.ccampo || '_V');
            END LOOP;
            -- JLB - ESTO LO ELIMINO PORQUE YA HE BORRADO TODOS EN EL CURSOR ANTERIOR
            --DELETE FROM sgt_parms_transitorios
            --      WHERE sesion = psesion
            --       AND EXISTS(SELECT 1
            --                    FROM codcampo c
            --                   WHERE c.ccampo || '_V' = sgt_parms_transitorios.parametro
            --                     AND c.cutili = 10);
            -- JLB - F
         END IF;
         -- fin Bug 21121 - APD - 05/03/2012
         -----------------------------------------
      END IF; -- fin Bug 28041/155911 - APD - 15/10/2013

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 99999;
   END f_tarifar;

   -------------------------------------------------------------------------------------
   FUNCTION f_tarifar_rea(psesion            IN NUMBER,
                          pscontra           IN NUMBER,
                          pnversio           IN NUMBER,
                          pcgarant           IN NUMBER,
                          pcont              IN NUMBER,
                          psobreprima        IN NUMBER,
                          parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb,
                          pitarrea           IN OUT NUMBER,
                          picaprea           IN OUT NUMBER,
                          picaparea          IN OUT NUMBER,
                          pipleno            IN OUT NUMBER,
                          pipritarrea        IN OUT NUMBER,
                          pidtosel           IN OUT NUMBER,
                          pmensa             IN OUT VARCHAR2,
                          pmoneda            IN NUMBER,
                          psproduc           IN NUMBER,
                          piextrea           IN OUT NUMBER,
                          -- 51.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                          pitarifrea IN OUT NUMBER)
   -- 51.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
    RETURN NUMBER IS
      /******************************************************************************
      Función que tarifa una garantia per a la reassegurança, parametros:
           pcont :numero de garantia en la que estamos.
      ******************************************************************************
       - Incorporados los cambios realizados por Nuría Paret para
      para el REASEGURO, se han realizados cambios en todo el PAC_TARIFAS.
      ******************************************************************************/
      clav      NUMBER := NULL;
      formula   VARCHAR2(2000);
      error     NUMBER;
      valor     NUMBER := NULL;
      xctipatr  NUMBER;
      v_pdtosel NUMBER;
      v_prieagr NUMBER;
      v_pdtocom NUMBER := pidtosel;
      -- I - JLB - OPTIMIZA
      --      CURSOR tmp IS
      --         SELECT *
      --           FROM sgt_parms_transitorios
      --          WHERE sesion = psesion;
      -- F - JLB - OPTIMIZA
      -- Bug 21121 - APD - 22/02/2012
      v_tregconcep pac_parm_tarifas.tregconcep_tabtyp;
   BEGIN
      BEGIN
         SELECT NVL(pdescuento, 0),
                NVL(priesgos, 0)
           INTO v_pdtosel,
                v_prieagr
           FROM contratos
          WHERE scontra = pscontra
            AND nversio = pnversio;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 104332; --  Contrato no encontrado en la tabla CONTRATOS
      END;

      BEGIN
         -- I - JLB
         --   INSERT INTO sgt_parms_transitorios
         --              (sesion, parametro, valor)
         --       VALUES (psesion, 'SESION', psesion);
         error := pac_sgt.put(psesion, 'SESION', psesion);

         IF error <> 0
         THEN
            RETURN 108438;
         END IF;
         -- F - JLB
      EXCEPTION
         WHEN dup_val_on_index THEN
            NULL;
            --la sesion puede que se haya insertado previamente ya que es necesaria
         --para instroducir las preguntas (se inserta a nivel de riesgo no de seguro)
         WHEN OTHERS THEN
            RETURN 108438;
      END;

      ----------------------------------------
      -- Publicamos el contrato y la versión -
      --  0033993 AVT 24/03/2015             -
      ----------------------------------------
      BEGIN
         error := pac_sgt.put(psesion, 'CONTRATO', pscontra);

         IF error <> 0
         THEN
            RETURN 9907484;
         END IF;

         error := pac_sgt.put(psesion, 'VERSION', pnversio);

         IF error <> 0
         THEN
            RETURN 9907485;
         END IF;
      EXCEPTION
         WHEN dup_val_on_index THEN
            NULL;
            --la sesion puede que se haya insertado previamente ya que es necesaria
         --para instroducir las preguntas (se inserta a nivel de riesgo no de seguro)
         WHEN OTHERS THEN
            RETURN 108438;
      END;

      --------------------------------------------------------------------------
      -- PRODUCTE
      --------------------------------------------------------------------------
      BEGIN
         -- I - JLB
         --  INSERT INTO sgt_parms_transitorios
         --              (sesion, parametro, valor)
         --      VALUES (psesion, 'SPRODUC', psproduc);
         error := pac_sgt.put(psesion, 'SPRODUC', psproduc);

         IF error <> 0
         THEN
            RETURN 109843;
         END IF;
         -- F - JLB
      EXCEPTION
         WHEN dup_val_on_index THEN
            NULL;
         WHEN OTHERS THEN
            RETURN 109843;
      END;

      /*
            BEGIN
               INSERT INTO SGT_PARMS_TRANSITORIOS
                           (sesion, parametro, valor)
                    VALUES (psesion, 'RIESG_AGRAV', v_prieagr);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  NULL;
               WHEN OTHERS THEN
                  RETURN 109843;
            END;
      */

      -- Bug 28041/155911 - APD - 15/10/2013
      IF (NOT
          (pac_iax_produccion.isaltacol AND
          NVL(pac_parametros.f_parproducto_n(psproduc, 'TARIFA_POLIZACERO'),
                0) = 0)) OR
         NVL(pac_parametros.f_parproducto_n(psproduc, 'TARIFA_POLIZACERO'),
             0) = 1
      THEN
         --------------------------------------------------------------------------
         -- CALCUL DEL PLE PER CADA GARANTIA (56)
         --------------------------------------------------------------------------
         -- Gravem el ple inicial
         clav    := NULL;
         formula := NULL;
         --pipleno    := 0;
         error := f_clave_rea(pscontra,
                              pnversio,
                              pcgarant,
                              psproduc,
                              'IPLENO',
                              clav);

         IF error <> 0
         THEN
            pmensa := pcgarant || '.Pleno';
            RETURN error; --'Error en selección del código'
         END IF;

         /*
               BEGIN
                  SELECT clave
                    INTO clav
                    FROM REAFORMULA
                   WHERE scontra = pscontra
                     AND nversio = pnversio
                     AND cgarant = pcgarant
                                 AND sproduc = psproduc --> JGR
                     AND ccampo  = 'IPLENO';
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                  WHEN OTHERS THEN
                     pmensa      := pcgarant || '.Pleno';
                     RETURN 108422; --'Error en selección del código'
               END;
         */
         IF clav IS NOT NULL
         THEN
            BEGIN
               SELECT formula
                 INTO formula
                 FROM sgt_formulas
                WHERE clave = clav;
            EXCEPTION
               WHEN OTHERS THEN
                  pmensa := pcgarant || '.ipleno';
                  RETURN 108423; -- Error en selección de sgt_formulas
            END;

            BEGIN
               -- I - JLB
               --  INSERT INTO sgt_parms_transitorios
               --             (sesion, parametro, valor)
               --      VALUES (psesion, 'PLENO_INICIAL', pipleno);
               error := pac_sgt.put(psesion, 'PLENO_INICIAL', pipleno);

               IF error <> 0
               THEN
                  RETURN 109843;
               END IF;
               -- F - JLB
            EXCEPTION
               WHEN dup_val_on_index THEN
                  NULL;
               WHEN OTHERS THEN
                  RETURN 109843;
            END;

            pac_parm_tarifas.inserta_parametro(psesion,
                                               clav,
                                               pcont,
                                               parms_transitorios,
                                               error,
                                               NULL,
                                               v_tregconcep);

            -- Hay que asegurarse  que parms_tran, esta informado con todos los parametros
            -- necesarios.
            IF error <> 0
            THEN
               pmensa := pcgarant || '.Ipleno';
               RETURN(error);
            END IF;

            -- nunu
            valor := pk_formulas.eval(formula, psesion);

            IF valor IS NULL
            THEN
               pmensa := pcgarant || '.Ipleno';
               p_tab_error(f_sysdate,
                           f_user,
                           'pac_tarifas',
                           9,
                           'tarifa no encontrada para la garantía',
                           formula || '  Sesion: ' || psesion ||
                           '  .Ipleno');
               RETURN 108437;
            ELSE
               pipleno := f_round(valor, pmoneda);
            END IF;

            pac_parm_tarifas.borra_parametro(psesion, clav);
         END IF;

         --------------------------------------------------------------------------
         -- CALCUL DE LA CAPACITAT DEL CONTRACTE PER LA GARANTIA (51) [icapaci]
         -- Gravem la capacitat inicial
         --------------------------------------------------------------------------
         clav    := NULL;
         formula := NULL;
         --        picaparea    := 0;
         error := f_clave_rea(pscontra,
                              pnversio,
                              pcgarant,
                              psproduc,
                              'ICAPAREA',
                              clav);

         IF error <> 0
         THEN
            pmensa := pcgarant || '.icaparea';
            RETURN error; --'Error en selección del código'
         END IF;

         /*
                  BEGIN
                  SELECT clave
                    INTO clav
                    FROM REAFORMULA
                   WHERE scontra = pscontra
                     AND nversio = pnversio
                     AND cgarant = pcgarant
                     AND ccampo  = 'ICAPAREA';
                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     picaparea    := 0;
                     WHEN OTHERS THEN
                     pmensa      := pcgarant || '.icaparea';
                     RETURN 108422; --'Error en selección del código'
                  END;
         */
         IF clav IS NOT NULL
         THEN
            BEGIN
               SELECT formula
                 INTO formula
                 FROM sgt_formulas
                WHERE clave = clav;
            EXCEPTION
               WHEN OTHERS THEN
                  pmensa := pcgarant || '.icaparea';
                  RETURN 108423; -- Error en selección de sgt_formulas
            END;

            BEGIN
               -- I - JLB
               --INSERT INTO sgt_parms_transitorios
               --            (sesion, parametro, valor)
               --     VALUES (psesion, 'CAPACI_INICIAL', picaparea);
               error := pac_sgt.put(psesion, 'CAPACI_INICIAL', picaparea);

               IF error <> 0
               THEN
                  RETURN 109843;
               END IF;
               -- F - JLB
            EXCEPTION
               WHEN dup_val_on_index THEN
                  NULL;
               WHEN OTHERS THEN
                  RETURN 109843;
            END;

            --BEGIN
            --   INSERT INTO SGT_PARMS_TRANSITORIOS
            --               (sesion, parametro, valor)
            --        VALUES (psesion, 'PLENO_INICIAL', pipleno);
            --EXCEPTION
            --   WHEN DUP_VAL_ON_INDEX THEN
            --      NULL;
            --   WHEN OTHERS THEN
            --      RETURN 109843;
            --END;
            pac_parm_tarifas.inserta_parametro(psesion,
                                               clav,
                                               pcont,
                                               parms_transitorios,
                                               error,
                                               NULL,
                                               v_tregconcep);

            -- Hay que asegurarse  que parms_tran, esta informado con todos los parametros
            -- necesarios.
            IF error <> 0
            THEN
               pmensa := pcgarant || '.Icaparea';
               RETURN(error);
            END IF;

            valor := pk_formulas.eval(formula, psesion);

            IF valor IS NULL
            THEN
               pmensa := pcgarant || '.Icaparea';
               p_tab_error(f_sysdate,
                           f_user,
                           'pac_tarifas',
                           10,
                           'tarifa no encontrada para la garantía',
                           formula || '  Sesion: ' || psesion ||
                           '  .Icaparea');
               RETURN 108437;
            ELSE
               picaparea := f_round(valor, pmoneda);
            END IF;

            pac_parm_tarifas.borra_parametro(psesion, clav);
         END IF;

         --------------------------------------------------------------------------
         -- CALCUL DEL CAPITAL CEDIT PER CADA GARANTIA (??)
         --------------------------------------------------------------------------
         -- Gravem el ple calculat

         /*

         BEGIN
            INSERT INTO SGT_PARMS_TRANSITORIOS
                        (sesion, parametro, valor)
                 VALUES (psesion, 'PLENO', pipleno);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               NULL;
            WHEN OTHERS THEN
               RETURN 109843;
         END;
         */
         -- BUG 9549 - 12/05/2009 - AVT - Se ajusta el cálculo del capital de cesión para reaseguro de ahorro
         clav    := NULL;
         formula := NULL;
         error   := f_clave_rea(pscontra,
                                pnversio,
                                pcgarant,
                                psproduc,
                                'ICAPREA',
                                clav);

         IF error <> 0
         THEN
            pmensa := pcgarant || '.icaprea';
            RETURN error; --'Error en selección del código'
         END IF;

         /*
            BEGIN
               SELECT clave
                 INTO clav
                 FROM reaformula
                WHERE scontra = pscontra
                  AND nversio = pnversio
                  AND cgarant = pcgarant
                  AND ccampo = 'ICAPREA';
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  pmensa := pcgarant || '.icaprea';
                  RETURN 108422;   --'Error en selección del código'
            END;
         */
         IF clav IS NOT NULL
         THEN
            BEGIN
               SELECT formula
                 INTO formula
                 FROM sgt_formulas
                WHERE clave = clav;
            EXCEPTION
               WHEN OTHERS THEN
                  pmensa := pcgarant || '.icaprea';
                  RETURN 108423; -- Error en selección de sgt_formulas
            END;

            pac_parm_tarifas.inserta_parametro(psesion,
                                               clav,
                                               pcont,
                                               parms_transitorios,
                                               error,
                                               NULL,
                                               v_tregconcep);

            -- Hay que asegurarse  que parms_tran, esta informado con todos los parametros
            -- necesarios.
            IF error <> 0
            THEN
               pmensa := pcgarant || '.Icaprea';
               RETURN(error);
            END IF;

            valor := pk_formulas.eval(formula, psesion);

            IF valor IS NULL
            THEN
               pmensa := pcgarant || '.Icaprea';
               RETURN 108437;
            ELSE
               picaprea := f_round(valor, pmoneda);
            END IF;

            pac_parm_tarifas.borra_parametro(psesion, clav);
         END IF;

         --*/ -- BUG 9549 - 12/05/2009 - AVT - Fin

         -- Gravem % descompte de selecció, % risc agreujats, % sobreprima
         --BEGIN
         --
         --   INSERT INTO SGT_PARMS_TRANSITORIOS
         --               (sesion, parametro, valor)
         --       VALUES (psesion, 'DESC_SELEC', v_pdtosel);
         --EXCEPTION
         --   WHEN DUP_VAL_ON_INDEX THEN
         --      NULL;
         --   WHEN OTHERS THEN
         --      RETURN 109843;
         --END;

         --------------------------------------------------------------------------
         -- CALCUL DE LA PRIMA DE TARIFA  (57, 58, 59, 60)
         ------------------------------------------------
         -- La prima de tarifa es el IPRITARREA
         clav        := NULL;
         formula     := NULL;
         pipritarrea := 0;
         error       := f_clave_rea(pscontra,
                                    pnversio,
                                    pcgarant,
                                    psproduc,
                                    'IPRITARE',
                                    clav);

         IF error <> 0
         THEN
            pmensa := pcgarant || '.ipritarrea';
            RETURN error; --'Error en selección del código'
         END IF;

         /*
               BEGIN
                  SELECT clave
                    INTO clav
                    FROM REAFORMULA
                   WHERE scontra = pscontra
                     AND nversio = pnversio
                     AND cgarant = pcgarant
                     AND ccampo  = 'IPRITARE';
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     pipritarrea    := 0;
                  WHEN OTHERS THEN
                     pmensa      := pcgarant || '.ipritarrea';
                     RETURN 108422; --'Error en selección del código'
               END;
         */
         IF clav IS NOT NULL
         THEN
            BEGIN
               SELECT formula
                 INTO formula
                 FROM sgt_formulas
                WHERE clave = clav;
            EXCEPTION
               WHEN OTHERS THEN
                  pmensa := pcgarant || '.ipritarrea';
                  RETURN 108423; -- Error en selección de sgt_formulas
            END;

            BEGIN
               -- I - JLB
               -- INSERT INTO sgt_parms_transitorios
               --             (sesion, parametro, valor)
               --      VALUES (psesion, 'CAPITAL_CED', picaprea);
               error := pac_sgt.put(psesion, 'CAPITAL_CED', picaprea);

               IF error <> 0
               THEN
                  RETURN 109843;
               END IF;
               -- F - JLB
            EXCEPTION
               WHEN dup_val_on_index THEN
                  NULL;
               WHEN OTHERS THEN
                  RETURN 109843;
            END;

            pac_parm_tarifas.inserta_parametro(psesion,
                                               clav,
                                               pcont,
                                               parms_transitorios,
                                               error,
                                               NULL,
                                               v_tregconcep);

            -- Hay que asegurarse  que parms_tran, esta informado con todos los parametros
            -- necesarios.
            IF error <> 0
            THEN
               pmensa := pcgarant || '.Ipritarrea';
               RETURN(error);
            END IF;

            valor := pk_formulas.eval(formula, psesion);

            IF valor IS NULL
            THEN
               pmensa := pcgarant || '.Ipritarrea';
               p_tab_error(f_sysdate,
                           f_user,
                           'pac_tarifas',
                           11,
                           'tarifa no encontrada para la garantía',
                           formula || '  Sesion: ' || psesion ||
                           '  .Ipritarea');
               RETURN 108437;
            ELSE
               pipritarrea := f_round(valor, pmoneda);
            END IF;

            pac_parm_tarifas.borra_parametro(psesion, clav);
         END IF;

         -- 51.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio

         ------------------------------------------------
         -- CALCULO DE LA TASA DE REASEGURO
         ------------------------------------------------
         -- La tasa de reaseguro en ITARIFREA - pitarifrea --> ITASARE
         clav       := NULL;
         formula    := NULL;
         pitarifrea := 0;
         error      := f_clave_rea(pscontra,
                                   pnversio,
                                   pcgarant,
                                   psproduc,
                                   'ITASARE',
                                   clav);

         IF error <> 0
         THEN
            pmensa := pcgarant || '.itarifrea';
            RETURN error; --'Error en selección del código'
         END IF;

         IF clav IS NOT NULL
         THEN
            BEGIN
               SELECT formula
                 INTO formula
                 FROM sgt_formulas
                WHERE clave = clav;
            EXCEPTION
               WHEN OTHERS THEN
                  pmensa := pcgarant || '.itarifrea';
                  RETURN 108423; -- Error en selección de sgt_formulas
            END;

            pac_parm_tarifas.inserta_parametro(psesion,
                                               clav,
                                               pcont,
                                               parms_transitorios,
                                               error,
                                               NULL,
                                               v_tregconcep);

            -- Hay que asegurarse  que parms_tran, esta informado con todos los parametros
            -- necesarios.
            IF error <> 0
            THEN
               pmensa := pcgarant || '.itarifrea';
               RETURN(error);
            END IF;

            valor := pk_formulas.eval(formula, psesion);

            IF valor IS NULL
            THEN
               pmensa := pcgarant || '.itarifrea';
               p_tab_error(f_sysdate,
                           f_user,
                           'pac_tarifas',
                           11,
                           'tarifa no encontrada para la garantía',
                           formula || '  Sesion: ' || psesion ||
                           '  .itarifrea');
               RETURN 108437;
            ELSE
               pitarifrea := valor;
               ---->>>>> NO !!!!!!! f_round(valor, pmoneda); 07/05/2014 avt
            END IF;

            pac_parm_tarifas.borra_parametro(psesion, clav);
         END IF;

         -- 51.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin

         --------------------------------------------------------------------------
         -- CALCUL DE LA EXTRAPRIMA
         ------------------------------------------------
         -- La priMA de tarifa es el IEXTREA
         clav    := NULL;
         formula := NULL;
         --piextrea    := 0;
         error := f_clave_rea(pscontra,
                              pnversio,
                              pcgarant,
                              psproduc,
                              'IEXTREA',
                              clav);

         IF error <> 0
         THEN
            pmensa := pcgarant || '.iextrea';
            RETURN error; --'Error en selección del código'
         END IF;

         /*
               BEGIN
                  SELECT clave
                    INTO clav
                    FROM REAFORMULA
                   WHERE scontra = pscontra
                     AND nversio = pnversio
                     AND cgarant = pcgarant
                     AND ccampo  = 'IEXTREA';
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     piextrea    := 0;
                  WHEN OTHERS THEN
                     pmensa      := pcgarant || '.iextrea';
                     RETURN 108422; --'Error en selección del código'
               END;
         */
         IF clav IS NOT NULL
         THEN
            BEGIN
               SELECT formula
                 INTO formula
                 FROM sgt_formulas
                WHERE clave = clav;
            EXCEPTION
               WHEN OTHERS THEN
                  pmensa := pcgarant || '.iextrea';
                  RETURN 108423; -- Error en selección de sgt_formulas
            END;

            BEGIN
               -- I - JLB
               --   INSERT INTO sgt_parms_transitorios
               --               (sesion, parametro, valor)
               --         VALUES (psesion, 'CAPITAL_CED', picaprea);
               error := pac_sgt.put(psesion, 'CAPITAL_CED', picaprea);

               IF error <> 0
               THEN
                  RETURN 109843;
               END IF;
               -- F - JLB
            EXCEPTION
               WHEN dup_val_on_index THEN
                  NULL;
               WHEN OTHERS THEN
                  RETURN 109843;
            END;

            pac_parm_tarifas.inserta_parametro(psesion,
                                               clav,
                                               pcont,
                                               parms_transitorios,
                                               error,
                                               NULL,
                                               v_tregconcep);

            -- Hay que asegurarse  que parms_tran, esta informado con todos los parametros
            -- necesarios.
            IF error <> 0
            THEN
               pmensa := pcgarant || '.iextrea';
               RETURN(error);
            END IF;

            valor := pk_formulas.eval(formula, psesion);

            IF valor IS NULL
            THEN
               pmensa := pcgarant || '.iextrea';
               p_tab_error(f_sysdate,
                           f_user,
                           'pac_tarifas',
                           12,
                           'tarifa no encontrada para la garantía',
                           formula || '  Sesion: ' || psesion ||
                           '  .Iextrarea');
               RETURN 108437;
            ELSE
               piextrea := f_round(valor, pmoneda);
               -- INCLUIMOS LA EXTRAPRIMA EN LA PRIMA REASEGURO
               pipritarrea := NVL(pipritarrea, 0);
               -- AVT 28/03/2014  + NVL(piextrea, 0);
            END IF;

            pac_parm_tarifas.borra_parametro(psesion, clav);
         END IF;

         BEGIN
            -- I - JLB
            --     INSERT INTO sgt_parms_transitorios
            --               (sesion, parametro, valor)
            --      VALUES (psesion, 'PRIMA_TAR_REA', pipritarrea);
            error := pac_sgt.put(psesion, 'PRIMA_TAR_REA', pipritarrea);

            IF error <> 0
            THEN
               RETURN 109843;
            END IF;
            -- F - JLB
         EXCEPTION
            WHEN dup_val_on_index THEN
               NULL;
            WHEN OTHERS THEN
               RETURN 109843;
         END;

         ----------------------------------------------------------------------------
         -- CALCUL DEL IMPORT DEL DESCOMPTE DE SELECCIÓ  (52, 55)   indirec (53, 54)
         ----------------------------------------------------------------------------
         clav     := NULL;
         formula  := NULL;
         pidtosel := 0;
         error    := f_clave_rea(pscontra,
                                 pnversio,
                                 pcgarant,
                                 psproduc,
                                 'IDTOSEL',
                                 clav);

         IF error <> 0
         THEN
            pmensa := pcgarant || '.pidtosel';
            RETURN error; --'Error en selección del código'
         END IF;

         /*
               BEGIN
                  SELECT clave
                    INTO clav
                    FROM REAFORMULA
                   WHERE scontra = pscontra
                     AND nversio = pnversio
                     AND cgarant = pcgarant
                     AND ccampo  = 'IDTOSEL';
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     pidtosel    := 0;
                  WHEN OTHERS THEN
                     pmensa      := pcgarant || '.pidtosel';
                     RETURN 108422; --'Error en selección del código'
               END;
         */
         IF clav IS NOT NULL
         THEN
            BEGIN
               SELECT formula
                 INTO formula
                 FROM sgt_formulas
                WHERE clave = clav;
            EXCEPTION
               WHEN OTHERS THEN
                  pmensa := pcgarant || '.pidtosel';
                  RETURN 108423; -- Error en selección de sgt_formulas
            END;

            BEGIN
               -- I - JLB
               --    INSERT INTO sgt_parms_transitorios
               --               (sesion, parametro, valor)
               --       VALUES (psesion, 'DESC_SELEC', v_pdtosel);
               error := pac_sgt.put(psesion, 'DESC_SELEC', v_pdtosel);

               IF error <> 0
               THEN
                  RETURN 109843;
               END IF;
               -- F - JLB
            EXCEPTION
               WHEN dup_val_on_index THEN
                  NULL;
               WHEN OTHERS THEN
                  RETURN 109843;
            END;

            BEGIN
               -- I - JLB
               --      INSERT INTO sgt_parms_transitorios
               --                  (sesion, parametro, valor)
               --           VALUES (psesion, 'RIESG_AGRAV', v_prieagr);
               error := pac_sgt.put(psesion, 'RIESG_AGRAV', v_prieagr);

               IF error <> 0
               THEN
                  RETURN 109843;
               END IF;
               -- F - JLB
            EXCEPTION
               WHEN dup_val_on_index THEN
                  NULL;
               WHEN OTHERS THEN
                  RETURN 109843;
            END;

            BEGIN
               -- I - JLB
               -- INSERT INTO sgt_parms_transitorios
               --            (sesion, parametro, valor)
               --     VALUES (psesion, 'SOBREPRIMA', psobreprima);
               error := pac_sgt.put(psesion, 'SOBREPRIMA', psobreprima);

               IF error <> 0
               THEN
                  RETURN 109843;
               END IF;
               -- F - JLB
            EXCEPTION
               WHEN dup_val_on_index THEN
                  NULL;
               WHEN OTHERS THEN
                  RETURN 109843;
            END;

            BEGIN
               -- I - JLB
               --INSERT INTO sgt_parms_transitorios
               --            (sesion, parametro, valor)
               --     VALUES (psesion, 'PDTO_COMERCIAL', v_pdtocom);
               error := pac_sgt.put(psesion, 'PDTO_COMERCIAL', v_pdtocom);

               IF error <> 0
               THEN
                  RETURN 109843;
               END IF;
               -- F - JLB
            EXCEPTION
               WHEN dup_val_on_index THEN
                  NULL;
               WHEN OTHERS THEN
                  RETURN 109843;
            END;

            pac_parm_tarifas.inserta_parametro(psesion,
                                               clav,
                                               pcont,
                                               parms_transitorios,
                                               error,
                                               NULL,
                                               v_tregconcep);

            -- Hay que asegurarse  que parms_tran, esta informado con todos los parametros
            -- necesarios.
            IF error <> 0
            THEN
               pmensa := pcgarant || '.pidtosel';
               RETURN(error);
            END IF;

            -- nunu
            valor := pk_formulas.eval(formula, psesion);

            IF valor IS NULL
            THEN
               pmensa := pcgarant || '.pidtosel';
               p_tab_error(f_sysdate,
                           f_user,
                           'pac_tarifas',
                           13,
                           'tarifa no encontrada para la garantía',
                           formula || '  Sesion: ' || psesion ||
                           '  .pidtosel');
               RETURN 108437;
            ELSE
               pidtosel := NVL(f_round(valor, pmoneda), 0);
            END IF;

            pac_parm_tarifas.borra_parametro(psesion, clav);
         END IF;

         --------------------------------------------------------------------------
         -- CALCUL DE LA PRIMA CEDIDA   (53)
         --------------------------------------------------------------------------
         clav     := NULL;
         formula  := NULL;
         pitarrea := 0;
         error    := f_clave_rea(pscontra,
                                 pnversio,
                                 pcgarant,
                                 psproduc,
                                 'ITARREA',
                                 clav);

         IF error <> 0
         THEN
            pmensa := pcgarant || '.itarrea';
            RETURN error; --'Error en selección del código'
         END IF;

         /*
         BEGIN
            SELECT clave
              INTO clav
              FROM REAFORMULA
             WHERE scontra = pscontra
               AND nversio = pnversio
               AND cgarant = pcgarant
               AND ccampo  = 'ITARREA';
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               pitarrea    := 0;
            WHEN OTHERS THEN
               pmensa      := pcgarant || '.itarrea';
               RETURN 108422; --'Error en selección del código'
         END;
             */
         IF clav IS NOT NULL
         THEN
            BEGIN
               SELECT formula
                 INTO formula
                 FROM sgt_formulas
                WHERE clave = clav;
            EXCEPTION
               WHEN OTHERS THEN
                  pmensa := pcgarant || '.itarrea';
                  RETURN 108423; -- Error en selección de sgt_formulas
            END;

            BEGIN
               --  I - JLB
               --  INSERT INTO sgt_parms_transitorios
               --              (sesion, parametro, valor)
               --       VALUES (psesion, 'RIESG_AGRAV', v_prieagr);
               error := pac_sgt.put(psesion, 'RIESG_AGRAV', v_prieagr);

               IF error <> 0
               THEN
                  RETURN 109843;
               END IF;
               -- F - JLB
            EXCEPTION
               WHEN dup_val_on_index THEN
                  NULL;
               WHEN OTHERS THEN
                  RETURN 109843;
            END;

            BEGIN
               -- I - JLB
               --  INSERT INTO sgt_parms_transitorios
               --              (sesion, parametro, valor)
               --       VALUES (psesion, 'SOBREPRIMA', psobreprima);
               error := pac_sgt.put(psesion, 'SOBREPRIMA', psobreprima);

               IF error <> 0
               THEN
                  RETURN 109843;
               END IF;
               -- F - JLB
            EXCEPTION
               WHEN dup_val_on_index THEN
                  NULL;
               WHEN OTHERS THEN
                  RETURN 109843;
            END;

            BEGIN
               -- I - JLB
               --  INSERT INTO sgt_parms_transitorios
               --             (sesion, parametro, valor)
               --      VALUES (psesion, 'PDTO_COMERCIAL', v_pdtocom);
               error := pac_sgt.put(psesion, 'PDTO_COMERCIAL', v_pdtocom);

               IF error <> 0
               THEN
                  RETURN 109843;
               END IF;
               -- F - JLB
            EXCEPTION
               WHEN dup_val_on_index THEN
                  NULL;
               WHEN OTHERS THEN
                  RETURN 109843;
            END;

            -- El capital de reasegurança és el picaprea
            pac_parm_tarifas.inserta_parametro(psesion,
                                               clav,
                                               pcont,
                                               parms_transitorios,
                                               error,
                                               NULL,
                                               v_tregconcep);

            -- Hay que asegurarse  que parms_tran, esta informado con todos los parametros
            -- necesarios.
            IF error <> 0
            THEN
               pmensa := pcgarant || '.Itarrea';
               RETURN(error);
            END IF;

            BEGIN
               -- I - JLB
               --  INSERT INTO sgt_parms_transitorios
               --              (sesion, parametro, valor)
               --      VALUES (psesion, 'PRIMA_TAR_REA', pipritarrea);
               error := pac_sgt.put(psesion, 'PRIMA_TAR_REA', pipritarrea);

               IF error <> 0
               THEN
                  RETURN 109843;
               END IF;
               -- F - JLB
            EXCEPTION
               WHEN dup_val_on_index THEN
                  NULL;
               WHEN OTHERS THEN
                  RETURN 109843;
            END;

            -- nunu
            valor := pk_formulas.eval(formula, psesion);

            IF valor IS NULL
            THEN
               pmensa := pcgarant || '.Itarrea';
               p_tab_error(f_sysdate,
                           f_user,
                           'pac_tarifas',
                           14,
                           'tarifa no encontrada para la garantía',
                           formula || '  Sesion: ' || psesion ||
                           '  .itarrea');
               RETURN 108437;
            ELSE
               pitarrea := f_round(valor, pmoneda);
            END IF;

            pac_parm_tarifas.borra_parametro(psesion, clav);
         END IF;
      END IF; -- fin Bug 28041/155911 - APD - 15/10/2013

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 9999;
   END f_tarifar_rea;

   ----------------------------
   FUNCTION f_tarifar_risc(psproces           IN NUMBER,
                           ptablas            IN VARCHAR2,
                           pfuncion           IN VARCHAR2,
                           pmodo              IN VARCHAR2,
                           pcramo             IN NUMBER,
                           pcmodali           IN NUMBER,
                           pctipseg           IN NUMBER,
                           pccolect           IN NUMBER,
                           psproduc           IN NUMBER,
                           pcactivi           IN NUMBER,
                           paplica_bonifica   IN NUMBER,
                           pbonifica          IN NUMBER,
                           psseguro           IN NUMBER,
                           pnriesgo           IN NUMBER,
                           pfcarpro           IN DATE,
                           pfefecto           IN DATE,
                           pcmanual           IN NUMBER,
                           pcobjase           IN NUMBER,
                           pcforpag           IN NUMBER,
                           pidioma            IN NUMBER,
                           pmes               IN NUMBER,
                           panyo              IN NUMBER,
                           pmoneda            IN NUMBER DEFAULT 2,
                           parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb,
                           ptotal_prima       OUT NUMBER,
                           pmensa             OUT VARCHAR2,
                           paccion            IN VARCHAR2 DEFAULT 'NP',
                           pnmovimi           IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      /************************************************************************

      Si hay un error dentro del cursor dinamico y hacemos un return tenemos que
      cerrar el cursor antes de hacer el return.
      Si el pfuncio='CAR'(cartera), hay que guardar el error en proceslin
      parametros:
         ptablas:'EST'/'DIF'/'SOL'/'WEB'... i null para las tablas de seguros',
         pfuncion: 'CAR'/'TAR'/'SUP'/'REA':Cartera =CAR, TAR: introducción de polizas/y suplementos,
                                     Suplementos = SUP, Reassegurança = REA.
             pmodo :'R'/'P'/..Real=R, Pruebas='P',
         pcgarant_regu : garantia de regularización,
         pnnorden :oreden de la garantia de regularizción.
             pmovimiento:movimimiento de la gar de regula (Es de salida),
             paplica_bonifica: si aplica bonificación (1 Si, otros no),
             pbonifica : bonificación,se aplica como descuentos
         pcmanual  :ctarman de la poliza,
        *************************************************************************/
      vpsesion NUMBER;
      v_select VARCHAR2(1000);
      v_selper VARCHAR2(500);
      cur      PLS_INTEGER; --:= DBMS_SQL.OPEN_CURSOR;
      cur2     PLS_INTEGER; --:= DBMS_SQL.OPEN_CURSOR;
      fdbk     PLS_INTEGER;
      --
      num_err             NUMBER := 0;
      num_err2            NUMBER := 2;
      v_cont              NUMBER := 0;
      v_nnumlin           NUMBER;
      v_lcte              NUMBER;
      v_lcdo              NUMBER;
      v_canvia_tarifa_pro NUMBER;
      v_canvia_tarifa_gar NUMBER;
      v_canvia_tarifa     NUMBER;
      v_aplicaprmin       NUMBER;
      --
      vtotal_prima NUMBER := 0;
      viprianu     NUMBER := 0;
      vipritar     NUMBER := 0;
      -- Reasseg
      vitarrea NUMBER := 0;
      vicaprea NUMBER := 0;
      vicapaci NUMBER := 0;
      vipleno  NUMBER := 0;
      ---
      virecarg NUMBER := 0;
      vidtocom NUMBER := 0;
      --
      vprevprima   NUMBER;
      vprevcap     NUMBER;
      vcapitalcal  NUMBER;
      vpdtocom     NUMBER;
      vprima_regu  NUMBER := 0;
      vprima_bonif NUMBER;
      v_registros  NUMBER;
      v_anulado    NUMBER;
      --
      v_cvalpar        NUMBER;
      v_texto          VARCHAR2(400);
      v_formula        VARCHAR2(1000);
      vestat_garan     VARCHAR2(25);
      vprima           NUMBER;
      vctarman         NUMBER;
      vfnacimi         DATE;
      vcsexper         NUMBER;
      v_edad           NUMBER;
      v_tasa           NUMBER := 0;
      v_idtocom        NUMBER := 0;
      v_irecarg        NUMBER := 0;
      v_nmovimi        NUMBER;
      vaplica_actual   NUMBER;
      vaplica_bonifica NUMBER;
      v_porcen         NUMBER;
      vipritarrea      NUMBER;
      vidtosel         NUMBER;
      vpsobreprima     NUMBER;
      lfecefe          NUMBER;
      --
      --parms_transitorios  pac_parm_tarifas.parms_transitorios_TabTyb;
      --
      vn_nmovimi NUMBER; --NUMERO DE MOV DEL PREGUNTES
      vn_nmovgar NUMBER; --NUMERO DE MOV DEL PREGUNTES GARANTIA
      vn_finiefe DATE; --DATA DEL ULT.MOV PREGUN GARANTIA
      --
      vr_sperson NUMBER;
      lsentencia VARCHAR2(1000);
      v_tablas   VARCHAR2(4);
      viextrea   NUMBER := 0;
      -- Extraprima reaseguro
      v_movimi  NUMBER;
      err       NUMBER;
      v_cramo   seguros.cramo%TYPE;
      v_cmodali seguros.cmodali%TYPE;
      v_ctipseg seguros.ctipseg%TYPE;
      v_ccolect seguros.ccolect%TYPE;
      -- 51.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
      vitarifrea NUMBER := 0;

      -- 51.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin

      -- Bug 10350 - 04/06/2009 - RSC - Detalle garantías (tarificación)
      TYPE assoc_array_garantia IS TABLE OF NUMBER INDEX BY VARCHAR2(100);

      v_totalgarantia assoc_array_garantia;
      -- Fin Bug 10350
      -- Mantis 10728.NMM.01/07/2009.i.CEM - Asignación automática de sobreprima.
      v_iextrap NUMBER; -- Import ExtraPrima
      v_psobrep NUMBER; -- Percentatge SobrePrima
      -- Mantis 10728.f.

      -- Bug 13727 - RSC - 07/05/2010 - APR - Análisis/Implementación de nuevas combinaciones de tarificación Flexilife Nueva Emisión
      v_prima    NUMBER;
      v_pirecarg NUMBER;
      v_pidtocom NUMBER;
      -- Fin bug 13727
      -- Ini Bug 21907 - MDS - 24/04/2012
      v_pidtotec NUMBER := 0;
      v_pireccom NUMBER := 0;
      -- Fin Bug 21907 - MDS - 24/04/2012
      v_extraprima NUMBER;
      --La recuperamos pero no hacemos nada con ella
      wndecima NUMBER;
      vpasexc  NUMBER := 1;

      --Bug 0020174 - FAL - 25/11/2011 - 0020174: GIP103 - Test de CMR.

      --
      -- Bug 9524 - YIL - 30/04/2009 - Se cambia el orden by del cursor tmp_garancar de forma que tenga en cuenta el parámetro ORDEN_TARIF_CARTERA
      -- Bug 10350 - RSC - 22/06/2009 - Detalle de Garantías (añadimos NDETGAR a la consulta)
      CURSOR cur_tmpgaran IS
         SELECT sseguro,
                cgarant,
                nriesgo,
                finiefe,
                norden,
                ctarifa,
                icaptot,
                icapital,
                precarg,
                ipritot,
                iprianu,
                ffinefe,
                cformul,
                iextrap,
                ctipfra,
                ifranqu,
                irecarg,
                idtocom,
                pdtocom,
                ipritar,
                crevali,
                prevali,
                irevali,
                itarifa,
                itarrea,
                ftarifa,
                feprev,
                fpprev,
                cderreg,
                percre,
                cref,
                cintref,
                pdif,
                pinttec,
                nparben,
                nbns,
                tmgaran,
                cmatch,
                tdesmat,
                pintfin,
                nmovima,
                nfactor,
                nmovi_ant,
                scontra,
                nvercon,
                icaprea,
                icapaci,
                ipleno,
                ipritarrea,
                idtosel,
                psobreprima,
                ndetgar,
                ndurcob,
                fefecto,
                contador,
                cunica,
                ctarman
           FROM tmp_garancar
          WHERE sproces = psproces
            AND sseguro = psseguro
            AND nriesgo = pnriesgo
            AND ffinefe IS NULL
               --AND NVL(ctarman, 0) = 0
            AND (canulado IS NULL --que no estigui anul·lat.
                OR canulado = 2) -- o que la estiguem rehabilitant
          ORDER BY DECODE(paccion,
                          'CAR',
                          DECODE(NVL(pac_parametros.f_pargaranpro_n(psproduc,
                                                                    pcactivi,
                                                                    cgarant,
                                                                    'ORDEN_TARIF_CARTERA'),
                                     0),
                                 0,
                                 cgarant,
                                 pac_parametros.f_pargaranpro_n(psproduc,
                                                                pcactivi,
                                                                cgarant,
                                                                'ORDEN_TARIF_CARTERA')),
                          DECODE(NVL(pac_parametros.f_pargaranpro_n(psproduc,
                                                                    pcactivi,
                                                                    cgarant,
                                                                    'ORDEN_TARIF'),
                                     0),
                                 0,
                                 cgarant,
                                 pac_parametros.f_pargaranpro_n(psproduc,
                                                                pcactivi,
                                                                cgarant,
                                                                'ORDEN_TARIF'))),
                   ndetgar;

      -- Bug 9524 - YIL - 30/04/2009 - Fin
      -- Fin Bug 10350

      -- BUG 0009541 - 02-02-09 - jrh - 0009541: CRE - Incidència Cartera de Decesos
      -- cursor de preguntas de la garantia de las tablas SGT.
      CURSOR cur_pregunrancar(psseguro IN NUMBER,
                              pnriesgo IN NUMBER,
                              pcgarant IN NUMBER,
                              pnmovimi IN NUMBER,
                              pnmovima IN NUMBER) IS
         SELECT cpregun
           FROM pregungarancar
          WHERE sproces = psproces
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND sseguro = psseguro
            AND nmovimi = NVL(pnmovimi, nmovimi)
            AND nmovima = NVL(pnmovima, nmovima);

      --cursor de preguntas por garantia al borrar
      --
      --    el campo crevalcar hay que elimarlo al volver.
      --
      -- Bug 21121 - APD - 22/02/2012
      v_tregconcep pac_parm_tarifas.tregconcep_tabtyp;
      -- fin Bug 21121 - APD - 22/02/2012
   BEGIN
      num_err := f_insertar_matriz(ptablas,
                                   psproces,
                                   psseguro,
                                   pnriesgo,
                                   pfcarpro);

      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      -- Seleccionamos el número de sesión del proceso.
      SELECT sgt_sesiones.nextval INTO vpsesion FROM dual;

      --borramos la información que tenemos del riesgo.
      -- JLB  - I
      -- DELETE FROM sgt_parms_transitorios
      --       WHERE sesion = vpsesion
      --         AND parametro <> 'SESION';
      num_err := pac_sgt.del(vpsesion);
      vpasexc := 2;

      -- JLB - F
      --empezamos a trabajar con la nueva sesion
      BEGIN
         -- JLB  - I
         -- INSERT INTO sgt_parms_transitorios
         --             (sesion, parametro, valor)
         --      VALUES (vpsesion, 'SESION', vpsesion);
         num_err := pac_sgt.put(vpsesion, 'SESION', vpsesion);

         IF num_err <> 0
         THEN
            RAISE NO_DATA_FOUND;
         END IF;
         -- JLB  - F
      EXCEPTION
         WHEN OTHERS THEN
            IF pfuncion = 'CAR' OR
               pfuncion = 'REA'
            THEN
               v_texto   := f_axis_literales(108438, pidioma);
               v_texto   := SUBSTR(v_texto || SQLERRM, 1, 100);
               v_nnumlin := NULL;
               num_err   := f_proceslin(psproces,
                                        v_texto,
                                        psseguro,
                                        v_nnumlin);
            END IF;

            RETURN 108438;
      END;

      --      Insertem el paràmetre pfunción per saber què estem fent
      --              desde SGT ( Cartera, Alta, suplement, Reasseg )
      DECLARE
         -- jlb - i
         vvalor NUMBER;
         -- jlb - f
      BEGIN
         -- JLB - I
         -- INSERT INTO sgt_parms_transitorios
         --               (sesion, parametro,
         --                valor)
         --        VALUES (vpsesion, 'FUNCION',
         --                DECODE(pfuncion, 'TAR', 1, 'SUP', 2, 'CAR', 3, 'REA', 4, 0));
         IF pfuncion = 'TAR'
         THEN
            vvalor := 1;
         ELSIF pfuncion = 'SUP'
         THEN
            vvalor := 2;
         ELSIF pfuncion = 'CAR'
         THEN
            vvalor := 3;
         ELSIF pfuncion = 'REA'
         THEN
            vvalor := 4;
         ELSE
            vvalor := 0;
         END IF;

         num_err := pac_sgt.put(vpsesion, 'FUNCION', vvalor);

         IF num_err <> 0
         THEN
            RAISE NO_DATA_FOUND;
         END IF;
         -- JLB  - F
      EXCEPTION
         WHEN OTHERS THEN
            IF pfuncion = 'CAR' OR
               pfuncion = 'REA'
            THEN
               v_texto   := f_axis_literales(109843, pidioma);
               v_texto   := SUBSTR(v_texto || SQLERRM, 1, 100);
               v_nnumlin := NULL;
               num_err   := f_proceslin(psproces,
                                        v_texto,
                                        psseguro,
                                        v_nnumlin);
            END IF;

            RETURN 109843;
      END;

      vpasexc := 3;

      --buscamos el último movimiento de pregunseg.
      BEGIN
         IF ptablas = 'SOL'
         THEN
            vn_nmovimi := 1;
         ELSE
            BEGIN
               SELECT DISTINCT (nmovi_ant)
                 INTO v_movimi
                 FROM tmp_garancar
                WHERE sproces = psproces
                  AND sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate,
                              f_user,
                              'pac_tarifas.f_tarifar_risc',
                              1833,
                              'p=' || psproces || ' s=' || psseguro,
                              SQLCODE || ' ' || SQLERRM);
                  RETURN 112315; -- error al leer de tm_garancar
            END;

            v_select := 'SELECT nvl(max(nmovimi),' || v_movimi ||
                        ') nmovimi' || ' FROM ' || ptablas || 'PREGUNSEG' ||
                        ' WHERE  sseguro =' || psseguro ||
                        '   AND  nriesgo =' || pnriesgo;
            cur      := dbms_sql.open_cursor; --nunu
            dbms_sql.parse(cur, v_select, dbms_sql.native);
            dbms_sql.define_column(cur, 1, vn_nmovimi);
            --definición de la columna
            fdbk := dbms_sql.execute(cur); --ejecución de la consulta

            IF dbms_sql.fetch_rows(cur) > 0
            THEN
               --posisción en el primer registro de la select
               dbms_sql.column_value(cur, 1, vn_nmovimi);
               --volcado del valor de la consulta en la variable
            ELSE
               vn_nmovimi := 1; --teoricamente aqui nunca entrará (nvl)
            END IF;

            dbms_sql.close_cursor(cur); --cerramos el cursor de la consulta
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            IF dbms_sql.is_open(cur)
            THEN
               --Cerramos el cursor si esta abierto.
               dbms_sql.close_cursor(cur);
            END IF;

            IF pfuncion = 'CAR' OR
               pfuncion = 'REA'
            THEN
               v_texto   := f_axis_literales(111714, pidioma);
               v_nnumlin := NULL;
               num_err   := f_proceslin(psproces,
                                        v_texto,
                                        psseguro,
                                        v_nnumlin);
            END IF;

            RETURN 111714;
            --error al leer el movimiento de EST/DIF/SOL/pregunseg
      END;

      vpasexc := 4;

      -----------------------------------------------------------
      --PREGUNTAS POR POLIZA
      -----------------------------------------------------------
      --Bug 26638/160974 - 03/04/2014 - AMC
      IF pfuncion = 'CAR'
      THEN
         -- Se está llamando desde cartera
         v_tablas := 'CAR';
      ELSE
         v_tablas := ptablas;
      END IF;

      num_err := pac_tarifas.f_insertar_preguntas_poliza(vpsesion,
                                                         psproces,
                                                         v_tablas,
                                                         psseguro,
                                                         pnriesgo,
                                                         pcramo,
                                                         pcmodali,
                                                         pctipseg,
                                                         pccolect,
                                                         vn_nmovimi,
                                                         pfcarpro,
                                                         pmodo);

      --Fi Bug 26638/160974 - 03/04/2014 - AMC
      IF num_err <> 0
      THEN
         p_tab_error(f_sysdate,
                     f_user,
                     'pac_tarifas.f_tarifar_risc',
                     NULL,
                     'llamada a pac_tarifas.f_insertar_preguntas_poliza',
                     num_err);

         IF pfuncion = 'CAR' OR
            pfuncion = 'REA'
         THEN
            v_texto   := f_axis_literales(num_err, pidioma);
            v_nnumlin := NULL;
            num_err2  := f_proceslin(psproces, v_texto, psseguro, v_nnumlin);
         END IF;

         RETURN num_err;
      END IF;

      vpasexc := 5;
      -----------------------------------------------------------
      --PREGUNTAS POR RIESGO
      -----------------------------------------------------------
      --Bug 26638/160974 - 03/04/2014 - AMC
      num_err := pac_tarifas.f_insertar_preguntas_riesgo(vpsesion,
                                                         psproces,
                                                         v_tablas,
                                                         psseguro,
                                                         pnriesgo,
                                                         pcramo,
                                                         pcmodali,
                                                         pctipseg,
                                                         pccolect,
                                                         vn_nmovimi,
                                                         pfcarpro,
                                                         pmodo);

      IF num_err <> 0
      THEN
         p_tab_error(f_sysdate,
                     f_user,
                     'pac_tarifas.f_tarifar_risc',
                     NULL,
                     'llamada a pac_tarifas.f_insertar_preguntas_riesgo',
                     num_err);

         IF pfuncion = 'CAR' OR
            pfuncion = 'REA'
         THEN
            v_texto   := f_axis_literales(num_err, pidioma);
            v_nnumlin := NULL;
            num_err2  := f_proceslin(psproces, v_texto, psseguro, v_nnumlin);
         END IF;

         RETURN num_err;
      END IF;

      vpasexc := 6;

      -------------------------------------------------------------------
      -- BUCLE POR GARANTIA: se insertan preguntas por garantia,
      -- se inicializan los parametros para tarifar, revalorizaciones.....
      -------------------------------------------------------------------
      FOR c IN cur_tmpgaran
      LOOP
         BEGIN
            ---------------------------------------------------
            -- copiamos los k y primas que hemos econtrado.
            -- si los valores son nulos es que vienen de formulario alctr126
            -- o alsup003 y hay que informarlos de los que hemos recuperado
            -- de la base de datos.
            ---------------------------------------------------

            -- Bug 10350 - RSC - 22/06/2009 - Detalle de garantías
            -- Para los productos con detalle de garantía y desde cartera el contador no va
            -- correlativo a la garantía ya que en cartera al realizar cont := cont + 1 estamos
            -- grabando el de un nuevo detalle.
            --
            -- Imaginemos la siguiente situación:
            --      cgarant ndetgar capital prima ctarifa
            --        2101    0     10000   100      1
            --        2101    1      4000    40      2
            --
            -- Al renovar:
            --
            -- Al tratar las garantías en PAC_DINCARTERA.f_garantarifa_sgt el contador de garantías
            -- (en este caso de detalles de garantía quedará de la siguiente manera)
            --
            --      cgarant ndetgar capital prima ctarifa
            --        2101    0     10000   100      1     (cont = 1)
            --        2101    1      4000    40      2     (cont = 3)
            --        2101    2       5,8     3      6     (cont = 2)
            --        2101    3       3,6   1,2      6     (cont = 4)
            --
            -- Por esta razón guardamos la correlación en el campo CONTADOR de la tabla
            -- TMP_GARANCAR.
            --
            -- Bug 29943 - JTT - 03/06/2014: Tambien recuperamos el indice de la tabla TMP_GARANCAR para DETALLE_GARANT = 2
            IF NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) IN
               (1, 2) AND
               pfuncion = 'CAR'
            THEN
               v_cont := c.contador;
            ELSE
               v_cont := v_cont + 1;
            END IF;

            -- Fin Bug 10350
            viprianu   := 0;
            vipritar   := 0;
            vitarrea   := 0;
            vprevcap   := 0;
            vprevprima := 0;
            v_tasa     := c.itarifa;
            vpasexc    := 7;

            -- Bug 11735 - RSC - 20/01/2010 - APR: suplemento de modificación de capital /prima
            IF NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) IN
               (1, 2) AND
               pfuncion = 'TAR'
            THEN
               parms_transitorios(v_cont).sitarifa := 1;
            END IF;

            -- Fin Bug 11735

            --Informamos la accion
            IF paccion = 'NP'
            THEN
               parms_transitorios(v_cont).caccion := 0;
               --(0.- Nueva Produccion)
               parms_transitorios(v_cont).aportext := 0;
            ELSIF paccion = 'APO'
            THEN
               parms_transitorios(v_cont).caccion := 1;
               -- (1.- Aportación extraordi)
               parms_transitorios(v_cont).aportext := c.icapital;
            ELSIF paccion = 'SUP' AND
                  f_prod_ahorro(psproduc) = 1
            THEN
               parms_transitorios(v_cont).caccion := 2; --( 2.- Suplemento)
               parms_transitorios(v_cont).aportext := 0;
            ELSIF paccion = 'CAR'
            THEN
               parms_transitorios(v_cont).caccion := 3; --( 3.- Cartera)
               parms_transitorios(v_cont).aportext := 0;
            ELSIF paccion = 'RG'
            THEN
               parms_transitorios(v_cont).caccion := 6;
            END IF;

            -- Bug 10350 - RSC - 08/07/2009 - Detalle de garantía (Tarificación)
            -- Bug 13832 - RSC - 09/06/2010 - APRS015 - suplemento de aportaciones únicas (Añadimos APO)
            IF (NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) = 1 AND
               paccion NOT IN ('NP', 'APO')) OR
               NVL(f_parproductos_v(psproduc, 'NUEVA_EMISION'), 1) = 0
            THEN
               -- Bug 13727 - RSC - 24/02/2010 - APR - Análisis/Implementación de nuevas combinaciones de tarificación Flexilife Nueva Emisión
               -- Si es portfolio debemos entrar por aqui! Nos los exige la tarificación (Alta de nuevos contratos
               -- no tenemos pero sí alta de garantías!

               -- EN PAC_PARM_TARIFAS
               -- Trataremo los siguientes ITEMS:
               --    CREVALIDGAR
               --    NDURCOBDGAR
               --    FINIEFEDGAR
               --    en inserta_parametro primero obtendremos este valor.
               --    Por otra parte, los parámetros los crearemos en SGT_CARGA_ARG_PREDE
               --    para obtenerlos en caso de provisiones.
               --
               --
               --
               parms_transitorios(v_cont).ndetgar := c.ndetgar;
               parms_transitorios(v_cont).ndurcobdgar := c.ndurcob;
               parms_transitorios(v_cont).crevalidgar := c.crevali;
               parms_transitorios(v_cont).finiefedgar := to_number(TO_CHAR(c.fefecto,
                                                                           'yyyymmdd'));
               parms_transitorios(v_cont).pinttecdgar := c.pinttec;
               -- Interés del detalle
               parms_transitorios(v_cont).cunicadgar := c.cunica;
               -- Indicador de si se trata de un detalle único
               parms_transitorios(v_cont).ctarifadgar := c.ctarifa;
               -- Indicador de tarifa del detalle
               parms_transitorios(v_cont).sprocesdgar := psproces;
               -- Indicador de proceso de tarificación
               -- Bug 13727 - RSC - 24/02/2010 - APR - Análisis/Implementación de nuevas combinaciones de tarificación Flexilife Nueva Emisión
               --ELSIF NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) = 2 THEN
               -- Fin Bug 13727
            ELSE
               -- Bug 11636 - 29/10/2009 - RSC - APR - Error in renewals (previous) - sproces 539
               parms_transitorios(v_cont).ndetgar := c.ndetgar;
               -- bug 24571 - 08/03/2013 - MRB - Per poder cridar el VAL_DETPRIMAS a LCOL i resta
               parms_transitorios(v_cont).sprocesdgar := psproces;
               -- Indicador de proceso de tarificación
               -- Bug 11636
            END IF;

            vpasexc := 8;
            -- Fin Bug 10350
            parms_transitorios(v_cont).cgarant := c.cgarant;
            parms_transitorios(v_cont).nriesgo := pnriesgo;
            parms_transitorios(v_cont).nfactor := NVL(parms_transitorios(v_cont)
                                                      .nfactor,
                                                      c.nfactor);
            parms_transitorios(v_cont).icapital := NVL(parms_transitorios(v_cont)
                                                       .icapital,
                                                       c.icapital);
            --Bug 9794 - APD - 22/04/2009 - Se añade el NVL(x,0) en iprianu en f_tarifar_risc
            parms_transitorios(v_cont).iprianu := NVL(NVL(parms_transitorios(v_cont)
                                                          .iprianu,
                                                          c.iprianu),
                                                      0);
            --Bug 9794 - APD - 22/04/2009 - Fin
            parms_transitorios(v_cont).ctarman := NVL(parms_transitorios(v_cont)
                                                      .ctarman,
                                                      0);
            parms_transitorios(v_cont).ipritar := NVL(parms_transitorios(v_cont)
                                                      .ipritar,
                                                      c.ipritar);
            --BUG 19612/100262--ETM-14/12/2011
            parms_transitorios(v_cont).tasa := NVL(parms_transitorios(v_cont).tasa,
                                                   c.itarifa);
            --
            parms_transitorios(v_cont).fefecto := to_number(TO_CHAR(pfefecto,
                                                                    'yyyymmdd'));
            -- Efecto del movimiento. A la función f_tarifar_risc se pasa en este parámetro
            parms_transitorios(v_cont).fecmov := to_number(TO_CHAR(pfcarpro,
                                                                   'yyyymmdd'));

            IF pfuncion <> 'REA'
            THEN
               parms_transitorios(v_cont).fecefe := to_number(TO_CHAR(NVL(c.ftarifa,
                                                                          pfcarpro),
                                                                      'yyyymmdd'));
            ELSE
               parms_transitorios(v_cont).fecefe := to_number(TO_CHAR(pfcarpro,
                                                                      'yyyymmdd'));
               parms_transitorios(v_cont).origen := NVL(parms_transitorios(v_cont)
                                                        .origen,
                                                        2);
            END IF;

            -- fcarpro necessaria per formules CS-Vida a Nova Producció.
            parms_transitorios(v_cont).fcarpro := to_number(TO_CHAR(pfcarpro,
                                                                    'yyyymmdd'));
            -- Añadimos la extraprima
            parms_transitorios(v_cont).extrapr := NVL(c.iextrap, 0);
            --JRH IMPORTANTE JRH
            num_err := pac_parm_tarifas.graba_param(vpsesion,
                                                    'GAR_CONTRATADA-' ||
                                                    NVL(pnriesgo, 1) || '-' ||
                                                    c.cgarant,
                                                    1);

            IF num_err <> 0
            THEN
               RETURN 108427;
            END IF;
            --JRH IMPORTANTE JRH
         END;
      END LOOP;

      vpasexc := 9;
      ---------------------------------------------------------
      --continente_contenido = continente_contenido
      ---------------------------------------------------------
      pac_tarifas.continente_contenido(pcramo,
                                       pcmodali,
                                       pctipseg,
                                       pccolect,
                                       pcactivi,
                                       v_cont,
                                       parms_transitorios);
      v_lcte := parms_transitorios(v_cont).contnte;
      v_lcdo := parms_transitorios(v_cont).conttdo;

      ------------------------------------------------------
      --   Edad: productos personales
      ------------------------------------------------------
      IF pcobjase = 1 AND
         ptablas = 'SOL'
      THEN
         SELECT fnacimi,
                csexper
           INTO vfnacimi,
                vcsexper
           FROM solriesgos
          WHERE ssolicit = psseguro
            AND nriesgo = pnriesgo;

         ---
         err := f_difdata(vfnacimi, pfcarpro, 2, 1, v_edad);
      ELSIF pcobjase = 1
      THEN
         BEGIN
            ---buscamos el último movimiento de pregunseg.
            v_selper := ' SELECT sperson ' || ' FROM ' || ptablas ||
                        'RIESGOS' || ' WHERE sseguro =' || psseguro ||
                        ' AND nriesgo =' || pnriesgo;
            cur2     := dbms_sql.open_cursor; --nunu
            dbms_sql.parse(cur2, v_selper, dbms_sql.native);
            dbms_sql.define_column(cur2, 1, vr_sperson);
            fdbk    := dbms_sql.execute(cur2);
            num_err := dbms_sql.fetch_rows(cur2);
            dbms_sql.column_value(cur2, 1, vr_sperson);
            dbms_sql.close_cursor(cur2);
         EXCEPTION
            WHEN OTHERS THEN
               IF dbms_sql.is_open(cur2)
               THEN
                  dbms_sql.close_cursor(cur2);
               END IF;

               IF pfuncion = 'CAR' OR
                  pfuncion = 'REA'
               THEN
                  v_texto   := f_axis_literales(103509, pidioma);
                  v_nnumlin := NULL;
                  num_err   := f_proceslin(psproces,
                                           v_texto,
                                           psseguro,
                                           v_nnumlin);
               END IF;

               num_err := 103509;
               RETURN 103509;
         END;

         IF ptablas IN ('SOL', 'EST')
         THEN
            BEGIN
               SELECT fnacimi,
                      csexper
                 INTO vfnacimi,
                      vcsexper
                 FROM estper_personas
                WHERE sperson = vr_sperson;
            EXCEPTION
               WHEN OTHERS THEN
                  IF pfuncion = 'CAR' OR
                     pfuncion = 'REA'
                  THEN
                     v_texto   := f_axis_literales(104389, pidioma);
                     v_nnumlin := NULL;
                     num_err   := f_proceslin(psproces,
                                              v_texto,
                                              psseguro,
                                              v_nnumlin);
                  END IF;

                  RETURN 104389;
            END;
         ELSE
            BEGIN
               SELECT fnacimi,
                      csexper
                 INTO vfnacimi,
                      vcsexper
                 FROM per_personas
                WHERE sperson = vr_sperson;
            EXCEPTION
               WHEN OTHERS THEN
                  IF pfuncion = 'CAR' OR
                     pfuncion = 'REA'
                  THEN
                     v_texto   := f_axis_literales(104389, pidioma);
                     v_nnumlin := NULL;
                     num_err   := f_proceslin(psproces,
                                              v_texto,
                                              psseguro,
                                              v_nnumlin);
                  END IF;

                  RETURN 104389;
            END;
         END IF;

         IF NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) = 3
         THEN
            v_edad := TRUNC(months_between(pfcarpro,
                                           (add_months(vfnacimi, 0) + 1)) / 12);
         ELSE
            v_edad := TRUNC(months_between(pfcarpro,
                                           (add_months(vfnacimi, -6) + 1)) / 12);
         END IF;
      END IF;

      vpasexc := 10;

      -- Bug 10350 - 04/06/2009 - RSC - Detalle garantías (tarificación)
      -- Bug 13727 - RSC - 24/02/2010 - APR - Análisis/Implementación de nuevas combinaciones de tarificación Flexilife Nueva Emisión
      -- Bug 13832 - RSC - 09/06/2010 - APRS015 - suplemento de aportaciones únicas (Añadimos APO)
      IF NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) = 1 AND
         paccion NOT IN ('NP', 'APO')
      THEN
         -- Acumulamos el total de garantía de todos sus detalles antes de hacer nada
         -- Este total es el que pasaremos al insertar las preguntas de garantía
         -- (una sola vez de momento. Se tendrá que ver si algún dia necesitamos
         --  preguntas a nivel de detalle de garantía.)
         FOR c IN cur_tmpgaran
         LOOP
            IF v_totalgarantia.exists(psseguro || '|' || c.cgarant || '|' ||
                                      pnriesgo || '|' || psproces)
            THEN
               v_totalgarantia(psseguro || '|' || c.cgarant || '|' || pnriesgo || '|' || psproces) := v_totalgarantia(psseguro || '|' ||
                                                                                                                      c.cgarant || '|' ||
                                                                                                                      pnriesgo || '|' ||
                                                                                                                      psproces) +
                                                                                                      c.icapital;
            ELSE
               v_totalgarantia(psseguro || '|' || c.cgarant || '|' || pnriesgo || '|' || psproces) := c.icapital;
            END IF;
         END LOOP;

         vpasexc := 11;

         -- Iteramos de nuevo para insertar las preguntas de garantía una sola vez
         FOR c IN cur_tmpgaran
         LOOP
            IF v_totalgarantia.exists(psseguro || '|' || c.cgarant || '|' ||
                                      pnriesgo || '|' || psproces)
            THEN
               IF pfuncion = 'CAR'
               THEN
                  -- Se está llamando desde cartera
                  v_tablas := 'CAR';
               ELSE
                  v_tablas := ptablas;
               END IF;

               vpasexc := 12;
               num_err := f_insertar_preguntas_garantia(vpsesion,
                                                        psproces,
                                                        psseguro,
                                                        pnriesgo,
                                                        c.cgarant,
                                                        psproduc,
                                                        pcactivi,
                                                        v_tablas,
                                                        pfcarpro,
                                                        c.nmovi_ant,
                                                        c.finiefe,
                                                        c.nmovima,
                                                        v_totalgarantia(psseguro || '|' ||
                                                                        c.cgarant || '|' ||
                                                                        pnriesgo || '|' ||
                                                                        psproces),

                                                        -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones únicas
                                                        paccion);

               IF num_err <> 0
               THEN
                  IF pfuncion = 'CAR' OR
                     pfuncion = 'REA'
                  THEN
                     v_texto   := f_axis_literales(num_err, pidioma);
                     v_nnumlin := NULL;
                     num_err2  := f_proceslin(psproces,
                                              v_texto,
                                              psseguro,
                                              v_nnumlin);
                  END IF;

                  RETURN num_err;
               END IF;

               -- Realizamos una sola vez la inserción de preguntas de garantía
               v_totalgarantia.delete(psseguro || '|' || c.cgarant || '|' ||
                                      pnriesgo || '|' || psproces);
            END IF;
         END LOOP;
      END IF;

      vpasexc := 13;
      -- Fin Bug 10350

      -------------------------------------------------------------------
      -- BUCLE POR GARANTIA: se insertan preguntas por garantia,
      -- se inicializan los parametros para tarifar, revalorizaciones.....
      -------------------------------------------------------------------
      v_cont := 0;

      FOR c IN cur_tmpgaran
      LOOP
         -- Bug 10350 - RSC - 22/06/2009 - Detalle de garantías
         -- Bug 29943 - JTT - 03/06/2014 - Añadimos detalle_garant = 2
         IF NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) IN (1, 2) AND
            pfuncion = 'CAR'
         THEN
            v_cont := c.contador;
         ELSE
            v_cont := v_cont + 1;
         END IF;

         vpasexc := 14;

         -- Fin Bug 10350
         IF parms_transitorios(v_cont).cgarant IS NOT NULL
         THEN
            --buscamos el último movimiento de pregungaranseg y la fecha del movimiento.
            --ordenamos por la fecha de finiefe y cojemos la más grande
            -----------------------------------------------------------
            --PREGUNTAS POR GARANTIA
            -----------------------------------------------------------

            -- Bug 10350 - 04/06/2009 - RSC - Detalle garantías (tarificación)
            -- Si no tiene detalle de garantías actuamos como siempre.

            -- Bug 13727 - RSC - 24/02/2010 - APR - Análisis/Implementación de nuevas combinaciones de tarificación Flexilife Nueva Emisión
            -- Bug 13832 - RSC - 21/06/2010 - APRS015 - suplemento de aportaciones únicas
            --IF NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) <> 1 OR NVL(f_parproductos_v(psproduc, 'NUEVA_EMISION'), 0) = 1 THEN
            IF NOT (NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) = 1 AND
                paccion NOT IN ('NP', 'APO')) OR
               NVL(f_parproductos_v(psproduc, 'NUEVA_EMISION'), 0) = 1
            THEN
               -- Fin Bug 13832
               vpasexc := 15;

               -- Fin Bug 13727
               IF pfuncion = 'CAR'
               THEN
                  -- Se está llamando desde cartera
                  v_tablas := 'CAR';
               ELSE
                  v_tablas := ptablas;
               END IF;

               num_err := f_insertar_preguntas_garantia(vpsesion,
                                                        psproces,
                                                        psseguro,
                                                        pnriesgo,
                                                        c.cgarant,
                                                        psproduc,
                                                        pcactivi,
                                                        v_tablas,
                                                        pfcarpro,
                                                        c.nmovi_ant,
                                                        c.finiefe,
                                                        c.nmovima,
                                                        c.icapital,

                                                        -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones únicas
                                                        paccion);

               IF num_err <> 0
               THEN
                  IF pfuncion = 'CAR' OR
                     pfuncion = 'REA'
                  THEN
                     v_texto   := f_axis_literales(num_err, pidioma);
                     v_nnumlin := NULL;
                     num_err2  := f_proceslin(psproces,
                                              v_texto,
                                              psseguro,
                                              v_nnumlin);
                  END IF;

                  RETURN num_err;
               END IF;
            END IF;

            vpasexc := 16;
            ---------------------------------------------------------------
            --guardamos los parametros e insertamos los parametros por riesgo
            ---------------------------------------------------------------
            vprevcap := parms_transitorios(v_cont).icapital;
            vctarman := parms_transitorios(v_cont).ctarman;
            parms_transitorios(v_cont).nmovimi := c.nmovi_ant;
            num_err := pac_parm_tarifas.insertar_parametros_riesgo(vpsesion,
                                                                   psseguro,
                                                                   vr_sperson,
                                                                   pcramo,
                                                                   pcmodali,
                                                                   pctipseg,
                                                                   pccolect,
                                                                   pcactivi,
                                                                   v_edad,
                                                                   vcsexper,
                                                                   NULL,
                                                                   v_cont,
                                                                   NVL(ptablas,
                                                                       'SEG'),
                                                                   parms_transitorios);
            vpasexc := 17;

            IF num_err <> 0
            THEN
               IF pfuncion = 'CAR' OR
                  pfuncion = 'REA'
               THEN
                  v_texto   := f_axis_literales(num_err, pidioma);
                  v_nnumlin := NULL;
                  num_err2  := f_proceslin(psproces,
                                           v_texto,
                                           psseguro,
                                           v_nnumlin);
               END IF;

               RETURN num_err;
            END IF;

            --BUG 19612/100262--ETM-14/12/2011
            v_tasa := parms_transitorios(v_cont).tasa;
            parms_transitorios(v_cont).contnte := v_lcte;
            parms_transitorios(v_cont).conttdo := v_lcdo;

            -----------------------------------------------------
            -- Modifiquem la bonificacio
            -- La bonificació la posem al descompte, només per cartera.
            -------------------------------------------------------
            IF paplica_bonifica = 1 AND
               pfuncion = 'CAR'
            THEN
               c.pdtocom := pbonifica;
            END IF;

            -----------------------------------------------------------
            -- asignación de las las primas para las garantias.
            -- teóricamente se pueden asignar sin mirar si es cartera o no
            -- lo es, ya que ya se ha tratado arriba.(bucle 1)
            --------------------------------------------------------------
            viprianu := parms_transitorios(v_cont).iprianu;
            vipritar := parms_transitorios(v_cont).ipritar;

            -- Bug 10350 - RSC - 22/06/2009 - Detalle de garantías
            -- Aunque fuera el caso de que revaloriza solo prima, para el nuevo
            -- detalle de garantía con la parte revalorizada se debe también grabar
            -- el capital. Si posteriormente se calcula el capital (ctarman in (0,2))
            -- ya se reactualizará el importe.
            IF NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) = 1 AND
               pfuncion = 'CAR'
            THEN
               vcapitalcal := parms_transitorios(v_cont).icapital;
            END IF;

            vpasexc := 18;
            -- Fin Bug 10350
            v_nnumlin := NULL;
            --------------------------------------------------------------
            -- insertamos la fecha de efecto en parametros transitorios
            -------------------------------------------------------------
            -- JLB - I
            -- DELETE FROM sgt_parms_transitorios
            --      WHERE sesion = vpsesion
            --        AND parametro = 'FECEFE';
            num_err := pac_sgt.del(vpsesion, 'FECEFE');

            -- JLB - F
            IF pfuncion <> 'REA'
            THEN
               lfecefe := to_number(TO_CHAR(NVL(c.ftarifa, pfcarpro),
                                            'yyyymmdd'));
            ELSE
               lfecefe := to_number(TO_CHAR(pfcarpro, 'yyyymmdd'));
            END IF;

            BEGIN
               -- I - JLB
               --INSERT INTO sgt_parms_transitorios
               --            (sesion, parametro, valor)
               --     VALUES (vpsesion, 'FECEFE', lfecefe);
               num_err := pac_sgt.put(vpsesion, 'FECEFE', lfecefe);

               IF num_err <> 0
               THEN
                  RAISE NO_DATA_FOUND;
               END IF;
               -- F - JLB
            EXCEPTION
               WHEN OTHERS THEN
                  IF pfuncion = 'CAR' OR
                     pfuncion = 'REA'
                  THEN
                     v_texto   := f_axis_literales(108797, pidioma);
                     v_nnumlin := NULL;
                     num_err   := f_proceslin(psproces,
                                              v_texto,
                                              psseguro,
                                              v_nnumlin);
                  END IF;

                  RETURN 108797;
            END;

            vpasexc := 19;

            IF parms_transitorios(v_cont).ctarman IN (0, 2)
            THEN
               -- Calculamos los recargos y descuentos técnicos.
               IF pfuncion <> 'REA'
               THEN
                  IF NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) = 1
                  THEN
                     IF parms_transitorios(v_cont).sitarifa = 1
                     THEN
                        -- Si no cal tarifar deixem el detall com està (sitarifa = 0)
                        -- Mantis 10728.NMM.01/07/2009.CEM - Afegim v_iextrap i v_isobrep ( params de sortida).i.
                        -- Bug 14429 - XPL - 30/07/2010 - AGA005 - Primes manuals pels productes de Llar
                        IF NVL(c.ctarman, 0) <> 1
                        THEN
                           -- Fin Bug 14429
                           vpasexc := 20;
                           num_err := pac_tarifas.f_tarifar(vpsesion,
                                                            vctarman,
                                                            pcramo,
                                                            pcmodali,
                                                            pctipseg,
                                                            pccolect,
                                                            pcactivi,
                                                            c.cgarant,
                                                            v_cont,
                                                            parms_transitorios,
                                                            viprianu,
                                                            vipritar,
                                                            vprevcap,
                                                            vcapitalcal,
                                                            vpdtocom,
                                                            v_tasa,
                                                            pmensa,
                                                            pmoneda,
                                                            c.ctarifa,
                                                            c.nmovi_ant,
                                                            c.nmovima,
                                                            v_iextrap,
                                                            v_psobrep,
                                                            v_tregconcep,
                                                            paccion);
                        END IF;
                     END IF;
                  ELSE
                     -- Bug 10350 - RSC - 27/07/2009 - Detalle de garantía (Tarificación)
                     IF parms_transitorios(v_cont)
                      .sitarifa IS NULL OR
                        parms_transitorios(v_cont).sitarifa = 1
                     THEN
                        -- Fin Bug 10350

                        -- Bug 14429 - XPL - 30/07/2010 - AGA005 - Primes manuals pels productes de Llar
                        IF NVL(c.ctarman, 0) <> 1
                        THEN
                           -- Fin Bug 14429
                           -- Mantis 10728.NMM.01/07/2009.CEM - Afegim v_iextrap i v_isobrep ( params de sortida).i.
                           num_err := pac_tarifas.f_tarifar(vpsesion,
                                                            vctarman,
                                                            pcramo,
                                                            pcmodali,
                                                            pctipseg,
                                                            pccolect,
                                                            pcactivi,
                                                            c.cgarant,
                                                            v_cont,
                                                            parms_transitorios,
                                                            viprianu,
                                                            vipritar,
                                                            vprevcap,
                                                            vcapitalcal,
                                                            vpdtocom,
                                                            v_tasa,
                                                            pmensa,
                                                            pmoneda,
                                                            c.ctarifa,
                                                            c.nmovi_ant,
                                                            c.nmovima,
                                                            v_iextrap,
                                                            v_psobrep,
                                                            v_tregconcep,
                                                            paccion);
                        ELSIF NVL(c.ctarman, 0) = 1
                        THEN
                           --0017035: AGA901 - control en el calculo de las primas manuales
                           -- Bug 19820 - JRH - 18/10/2011 - Bug 19820: GIP103 Preguntes CRM. Para cforpag=0 no validar
                           -- Bug 0020174 - FAL - 25/11/2011 - 0020174: GIP103 - Test de CMR.
                           BEGIN
                              SELECT ndecima
                                INTO wndecima
                                FROM monedas
                               WHERE cmoneda = pmoneda
                                 AND cidioma = pidioma;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 wndecima := 0;
                           END;

                           --IF MOD(viprianu, pcforpag) <> 0 AND NVL(pcforpag, 0) <> 0 THEN
                           IF MOD((f_round(viprianu, pmoneda) *
                                  power(10, wndecima)),
                                  pcforpag) <> 0 AND
                              NVL(pcforpag, 0) <> 0
                           THEN
                              -- Fi bug 0020174
                              RETURN 9901740;
                              --'La prima anual ha de ser múltiple de la forma de pagament'
                           END IF;
                           -- Fi Bug 19820 - JRH - 18/10/2011
                        END IF;
                     END IF;
                  END IF;
               ELSE
                  vpasexc := 21;
                  -- tarifem reassegurança
                  -- Ini de reassegurança
                  vicaprea    := NVL(f_capital_base(psseguro,
                                                    pnriesgo,
                                                    c.finiefe,
                                                    c.nmovi_ant),
                                     NVL(c.icaprea, c.icapital)); --> JGR
                  vicapaci    := c.icapaci;
                  vipleno     := c.ipleno;
                  vipritarrea := c.ipritarrea;
                  --vpsobreprima:= c.psobreprima;
                  vpsobreprima := NVL(c.precarg, 0); --> JGR
                  vidtosel     := NVL(c.pdtocom, 0); --> JGR
                  num_err      := f_tarifar_rea(vpsesion,
                                                c.scontra,
                                                c.nvercon,
                                                c.cgarant,
                                                v_cont,
                                                vpsobreprima,
                                                parms_transitorios,
                                                vitarrea,
                                                vicaprea,
                                                vicapaci,
                                                vipleno,
                                                vipritarrea,
                                                vidtosel,
                                                pmensa,
                                                pmoneda,
                                                psproduc,
                                                viextrea,
                                                -- 51.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                                                vitarifrea);
                  -- 51.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
               END IF;

               vpasexc := 22;

               IF num_err <> 0
               THEN
                  IF pfuncion = 'CAR' OR
                     pfuncion = 'REA'
                  THEN
                     v_texto   := f_axis_literales(num_err, pidioma);
                     v_nnumlin := NULL;
                     num_err2  := f_proceslin(psproces,
                                              v_texto,
                                              psseguro,
                                              v_nnumlin);
                  END IF;

                  RETURN num_err;
               END IF;

               --borramos las respuestas de la tabla temporal sgt_parms_transitorios
               -- Bug 26923/146905 - APD - 27/06/2013 - se sustituye c.nmovima por c.nmovi_ant
               FOR p IN cur_pregunrancar(psseguro,
                                         pnriesgo,
                                         c.cgarant,
                                         c.nmovi_ant,
                                         c.nmovima)
               LOOP
                  -- JLB - I
                  -- DELETE      sgt_parms_transitorios
                  --       WHERE sesion = vpsesion
                  --        AND parametro LIKE 'RESP' || p.cpregun;
                  num_err := pac_sgt.del(vpsesion, 'RESP' || p.cpregun);
                  -- JLB - F
               END LOOP;
            END IF;

            vpasexc := 23;

            BEGIN
               UPDATE tmp_garancar
                  SET sseguro  = psseguro,
                      cgarant  = c.cgarant,
                      nriesgo  = pnriesgo,
                      finiefe  = c.finiefe,
                      norden   = c.norden,
                      ctarifa  = c.ctarifa,
                      icapital = NVL(vcapitalcal,
                                     NVL(parms_transitorios(v_cont).icapital,
                                         c.icapital)),
                      -- Mantis 10728.NMM.01/07/2009.CEM - Asignación automática de sobreprima.i.
                      precarg     = NVL(v_psobrep, c.precarg),
                      iextrap     = NVL(v_iextrap, c.iextrap),
                      psobreprima = vpsobreprima,
                      -- Mantis 10728.NMM.f.
                      --iextrap = c.iextrap,   --> REA
                      --iextrap = parms_transitorios(v_cont).extrapr, --> REA
                      iprianu    = viprianu,
                      ffinefe    = NULL,
                      cformul    = c.cformul,
                      ctipfra    = c.ctipfra,
                      ifranqu    = c.ifranqu,
                      sproces    = psproces,
                      irecarg    = c.irecarg,
                      ipritar    = vipritar,
                      pdtocom    = NVL(vpdtocom, c.pdtocom),
                      idtocom    = v_idtocom,
                      crevali    = c.crevali,
                      prevali    = c.prevali,
                      irevali    = c.irevali,
                      itarifa    = v_tasa,
                      itarrea    = vitarrea, --> REA
                      icaprea    = vicaprea, --> REA
                      icapaci    = vicapaci, --> REA
                      ipleno     = vipleno, --> REA
                      ipritot    = NULL,
                      icaptot    = NULL,
                      ftarifa    = c.ftarifa,
                      cderreg    = c.cderreg,
                      feprev     = c.feprev,
                      fpprev     = c.fpprev,
                      percre     = c.percre,
                      cref       = c.cref,
                      cintref    = c.cintref,
                      pdif       = c.pdif,
                      pinttec    = c.pinttec,
                      nparben    = c.nparben,
                      nbns       = c.nbns,
                      tmgaran    = c.tmgaran,
                      cmatch     = c.cmatch,
                      tdesmat    = c.tdesmat,
                      pintfin    = c.pintfin,
                      nmovima    = c.nmovima,
                      nfactor    = parms_transitorios(v_cont).nfactor,
                      ipritarrea = vipritarrea, --> REA
                      idtosel    = vidtosel, --> REA
                      iextrea    = viextrea, --> REA
                      -- 51.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                      itarifrea = vitarifrea --> REA
               -- 51.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
                WHERE sseguro = psseguro
                  AND sproces = psproces
                  AND nriesgo = pnriesgo
                  AND cgarant = c.cgarant
                  AND finiefe = c.finiefe
                  AND nmovima = c.nmovima
                  AND ndetgar = c.ndetgar;

               vpasexc := 24;
               num_err := pac_parm_tarifas.graba_param(vpsesion,
                                                       'CAP-' ||
                                                       NVL(pnriesgo, 1) || '-' ||
                                                       c.cgarant,
                                                       NVL(vcapitalcal,
                                                           NVL(parms_transitorios(v_cont)
                                                               .icapital,
                                                               c.icapital)));

               IF num_err <> 0
               THEN
                  RETURN 108425;
               END IF;

               num_err := pac_parm_tarifas.graba_param(vpsesion,
                                                       'IPRITAR-' ||
                                                       NVL(pnriesgo, 1) || '-' ||
                                                       c.cgarant,
                                                       vipritar);

               IF num_err <> 0
               THEN
                  RETURN 108426;
               END IF;

               num_err := pac_parm_tarifas.graba_param(vpsesion,
                                                       'IPRIANU-' ||
                                                       NVL(pnriesgo, 1) || '-' ||
                                                       c.cgarant,
                                                       viprianu);

               IF num_err <> 0
               THEN
                  RETURN 108427;
               END IF;

               num_err := pac_parm_tarifas.graba_param(vpsesion,
                                                       'IPRIPUR-' ||
                                                       NVL(pnriesgo, 1) || '-' ||
                                                       c.cgarant,
                                                       NVL(NVL(vcapitalcal,
                                                               NVL(parms_transitorios(v_cont)
                                                                   .icapital,
                                                                   c.icapital)) *
                                                           v_tasa,
                                                           0));

               IF num_err <> 0
               THEN
                  RETURN 9903349;
               END IF;

               vpasexc := 25;

               IF NVL(f_parproductos_v(psproduc, 'DETPRIMAS'), 0) = 1
               THEN
                  -- Bug 21121 - APD - 22/02/2012 - se realiza el update en detprimas
                  FOR i IN 1 .. v_tregconcep.count
                  LOOP
                     BEGIN
                        INSERT INTO tmp_detprimas
                           (sseguro, nriesgo, cgarant, nmovimi, finiefe,
                            ccampo, cconcep, sproces, norden, iconcep,
                            iconcep2)
                        VALUES
                           (psseguro, pnriesgo, c.cgarant, pnmovimi,
                            c.finiefe, UPPER(v_tregconcep(i).ccampo),
                            UPPER(v_tregconcep(i).cconcep), psproces,
                            v_tregconcep(i).norden, v_tregconcep(i).valor,
                            v_tregconcep(i).valor2);
                     EXCEPTION
                        WHEN dup_val_on_index THEN
                           UPDATE tmp_detprimas
                              SET iconcep  = v_tregconcep(i).valor,
                                  iconcep2 = v_tregconcep(i).valor2,
                                  norden   = v_tregconcep(i).norden
                            WHERE sseguro = psseguro
                              AND nriesgo = pnriesgo
                              AND cgarant = c.cgarant
                              AND nmovimi = pnmovimi ---c.nmovima
                              AND finiefe = c.finiefe
                              AND ccampo = UPPER(v_tregconcep(i).ccampo)
                              AND cconcep = UPPER(v_tregconcep(i).cconcep)
                              AND sproces = psproces;
                     END;
                  END LOOP;
               END IF;

               -- fin Bug 21121 - APD - 22/02/2012
               --inicializamos las variables para la siguiente garatia
               viprianu    := 0;
               vipritar    := 0;
               vitarrea    := 0;
               vcapitalcal := NULL; --Bug.: 17675
            EXCEPTION
               WHEN OTHERS THEN
                  IF pfuncion = 'CAR' OR
                     pfuncion = 'REA'
                  THEN
                     v_texto   := f_axis_literales(101998, pidioma);
                     v_nnumlin := NULL;
                     num_err   := f_proceslin(psproces,
                                              SQLERRM,
                                              psseguro,
                                              v_nnumlin);
                  END IF;

                  RETURN 101998;
            END;
         END IF; --cgarant is null
      END LOOP;

      vpasexc := 26;

      -------------------------------------------------------------------------
      -- Prima total
      -------------------------------------------------------------------------
      -- Bug 9699 - APD - 08/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a PARGARANPRO para la actividad cero
      -- Esto ya se hace al llamar a la funcion f_pargaranpro_v
      SELECT SUM(iprianu)
        INTO vtotal_prima
        FROM tmp_garancar g
       WHERE g.sseguro = psseguro
         AND g.nriesgo = pnriesgo
         AND sproces = psproces
         AND NVL(f_pargaranpro_v(pcramo,
                                 pcmodali,
                                 pctipseg,
                                 pccolect,
                                 pcactivi,
                                 g.cgarant,
                                 'SUMA_PRIMA'),
                 1) <> 0;

      -- Bug 9699 - APD - 08/04/2009 - Fin
      ptotal_prima := vtotal_prima;
      v_cont       := 0;
      vpasexc      := 27;

      --
      FOR c IN cur_tmpgaran
      LOOP
         -- Bug 10350 - RSC - 22/06/2009 - Detalle de garantías
         -- Bug 29943 - JTT - 03/06/2014 - Añadimos detalle_garant = 2
         IF NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) IN (1, 2) AND
            pfuncion = 'CAR'
         THEN
            v_cont := c.contador;
         ELSE
            v_cont := v_cont + 1;
         END IF;

         -- Fin Bug 10350
         viprianu := c.iprianu;

         IF vctarman IN (0, 2)
         THEN
            num_err := pac_tarifas.f_dto_vol(vpsesion,
                                             psseguro,
                                             c.cgarant,
                                             pcramo,
                                             pcmodali,
                                             pctipseg,
                                             pccolect,
                                             pcactivi,
                                             v_cont,
                                             vtotal_prima,
                                             viprianu,
                                             pmensa,
                                             parms_transitorios);
         END IF;

         IF num_err <> 0
         THEN
            IF pfuncion = 'CAR' OR
               pfuncion = 'REA'
            THEN
               v_texto   := f_axis_literales(num_err, pidioma);
               v_nnumlin := NULL;
               num_err2  := f_proceslin(psproces,
                                        v_texto,
                                        psseguro,
                                        v_nnumlin);
            END IF;

            RETURN num_err;
         END IF;

         BEGIN
            UPDATE tmp_garancar
               SET iprianu = viprianu
             WHERE sseguro = psseguro
               AND cgarant = c.cgarant
               AND nriesgo = pnriesgo
               AND finiefe = c.finiefe
               AND sproces = psproces
               AND nmovima = c.nmovima
               AND ndetgar = c.ndetgar;
         EXCEPTION
            WHEN OTHERS THEN
               IF pfuncion = 'CAR' OR
                  pfuncion = 'REA'
               THEN
                  v_texto   := f_axis_literales(101998, pidioma);
                  v_nnumlin := NULL;
                  num_err   := f_proceslin(psproces,
                                           v_texto,
                                           psseguro,
                                           v_nnumlin);
               END IF;

               RETURN 101998;
         END;
      END LOOP;

      vpasexc := 28;

      -- Bug 13727 - RSC - 07/05/2010 - APR - Análisis/Implementación de nuevas combinaciones de tarificación Flexilife Nueva Emisión
      IF NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) = 1 AND
         pfuncion = 'CAR'
      THEN
         FOR v_gar IN (SELECT *
                         FROM tmp_garancar
                        WHERE sseguro = psseguro
                          AND nriesgo = pnriesgo
                          AND sproces = psproces)
         LOOP
            v_prima := v_gar.iprianu;

            IF parms_transitorios.exists(v_gar.contador) AND
               parms_transitorios(v_gar.contador).sitarifa = 1
            THEN
               -- BUG 20666-  01/2012 - JRH  -  20666: De momento aqui no lo ponemos. Buscar en las CAR Si tenemos el capitalo inicial informado la extraprima utiliza este capital

               -- Bug 21907 - MDS - 24/04/2012
               -- añadir parámetros nuevos : v_gar.pdtotec, v_gar.preccom, v_pidtotec, v_pireccom
               num_err := f_recdto(v_gar.precarg,
                                   v_gar.pdtocom,
                                   v_pirecarg,
                                   v_pidtocom,
                                   v_gar.pdtotec,
                                   v_gar.preccom,
                                   v_pidtotec,
                                   v_pireccom, -- Bug 21907 - MDS - 24/04/2012
                                   v_gar.iextrap,
                                   v_gar.icapital,
                                   v_extraprima, -- BUG19532:DRA:26/09/2011
                                   v_prima,
                                   pmoneda,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   psproduc); -- DCT - 02/12/2014

               IF num_err <> 0
               THEN
                  RETURN num_err;
               END IF;

               vpasexc := 29;

               BEGIN
                  UPDATE tmp_garancar
                     SET irecarg = v_pirecarg,
                         idtocom = v_pidtocom,
                         idtotec = v_pidtotec, -- Bug 21907 - MDS - 24/04/2012
                         ireccom = v_pireccom, -- Bug 21907 - MDS - 24/04/2012
                         iprianu = f_round_forpag(v_prima,
                                                  pcforpag,
                                                  pmoneda,
                                                  psproduc)
                   WHERE sseguro = psseguro
                     AND cgarant = v_gar.cgarant
                     AND nriesgo = v_gar.nriesgo
                     AND finiefe = v_gar.finiefe
                     AND nmovima = v_gar.nmovima
                     AND ndetgar = v_gar.ndetgar
                     AND sproces = psproces;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 101998;
               END;
            END IF;
         END LOOP;
      END IF;

      vpasexc := 30;
      -- Fin Bug 13727
      num_err := pac_parm_tarifas.borra_param_sesion(vpsesion);
      -- JLB - I
      --DELETE FROM sgt_parms_transitorios   -->
      --      WHERE sesion = vpsesion;   -->
      -- JLB - F
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF pfuncion = 'CAR' OR
            pfuncion = 'REA'
         THEN
            v_texto   := f_axis_literales(111721, pidioma);
            v_nnumlin := NULL;
            num_err2  := f_proceslin(psproces, SQLERRM, psseguro, v_nnumlin);
         END IF;

         RETURN 111721;
   END f_tarifar_risc;

   /************************************************************************
    : función que inserta las preguntas a nivel de poliza, se insertan en  preguncar
   las preguntas y respuestas, si el modo no es cartera las eliminamos una vez ya hemos
   insertado los valores en parametros transitorios.
   Hay que pasar el prefijo de las tablas de origen (EST,DIF,SOL,WEB,null...)
   ************************************************************************/
   FUNCTION f_insertar_preguntas_poliza(psesion  IN NUMBER,
                                        psproces IN NUMBER,
                                        ptablas  VARCHAR2,
                                        psseguro IN NUMBER,
                                        pnriesgo IN NUMBER,
                                        pcramo   IN NUMBER,
                                        pcmodali IN NUMBER,
                                        pctipseg IN NUMBER,
                                        pccolect IN NUMBER,
                                        pnmovimi IN NUMBER,
                                        pfcarpro IN DATE,
                                        pmodo    VARCHAR2) RETURN NUMBER IS
      num_err NUMBER := 0;

      TYPE t_cursor IS REF CURSOR;

      c_preguntas t_cursor;
      v_select    VARCHAR2(4000);
      v_resp      NUMBER;
      cur         PLS_INTEGER; --:= DBMS_SQL.OPEN_CURSOR;
      fdbk        PLS_INTEGER;
      cur1        PLS_INTEGER; --:= DBMS_SQL.OPEN_CURSOR;
      vg_npreord  NUMBER;
      vg_crespue  NUMBER;
      vg_trespue  VARCHAR2(2000);
      vg_cpregun  NUMBER;
      vg_cpretip  NUMBER;
      vg_tprefor  VARCHAR2(100);
      vg_nmovimi  NUMBER;
      v_nnumlin   NUMBER;
      num_err2    NUMBER;
      -- Bug 22839 - RSC - 26/07/2012 - LCOL - Funcionalidad Certificado 0
      v_sproduc  seguros.sproduc%TYPE;
      vg_esccero NUMBER; --pregunpro.esccero%TYPE;
      vg_npoliza NUMBER; --seguros.npoliza%TYPE;
      vg_cresdef NUMBER;
      -- Fin Bug 22839
      vtablas VARCHAR2(20); --Bug 26638/160974 - 03/04/2014 - AMC
   BEGIN
      -- Bug 22839 - RSC - 26/07/2012 - LCOL - Funcionalidad Certificado 0
      SELECT sproduc
        INTO v_sproduc
        FROM productos
       WHERE cramo = pcramo
         AND cmodali = pcmodali
         AND ctipseg = pctipseg
         AND ccolect = pccolect;

      -- Fin bug 22839

      --creación de la select para insertar en preguncar (EST,DIF,WEB,SOL...)
      BEGIN
         IF ptablas = 'SOL'
         THEN
            v_select := ' SELECT p.npreord npreord, e.crespue crespue, e.trespue trespue, e.cpregun cpregun, p.cpretip cpretip, tprefor tprefor,nmovimi nmovimi, p.esccero esccero, s.npoliza npoliza, p.cresdef cresdef' ||
                        ' FROM   PREGUNPOLCAR e, pregunpro p, solseguros s' ||
                        ' WHERE  e.cpregun = p.cpregun AND e.sseguro =' ||
                        psseguro ||
                        ' AND s.ssolicit = e.sseguro AND p.cramo   = s.cramo' ||
                        ' AND p.cmodali = s.cmodali AND p.ccolect = s.ccolect' ||
                        ' AND p.ctipseg = s.ctipseg AND p.cnivel  = ''P'' ' ||
                        ' AND e.nmovimi = ' || pnmovimi ||
                        ' AND e.sproces = ' || psproces ||
                        ' AND p.cpretip <> 2' || ' UNION' ||
                        ' SELECT p.npreord npreord, 0 crespue , null trespue, p.cpregun cpregun, p.cpretip cpretip, p.tprefor tprefor,' ||
                        pnmovimi ||
                        ' nmovimi, p.esccero esccero, s.npoliza npoliza, p.cresdef cresdef FROM pregunpro p, solseguros s' ||
                        ' WHERE p.cramo = s.cramo AND p.cmodali = s.cmodali ' ||
                        ' AND p.ctipseg = s.ctipseg AND p.ccolect = s.ccolect ' ||
                        ' AND p.cnivel  = ''P'' AND s.ssolicit =' ||
                        psseguro || ' AND p.cpretip = 2 ORDER BY npreord';
         ELSE
            --Bug 26638/160974 - 03/04/2014 - AMC
            IF ptablas = 'CAR'
            THEN
               vtablas := NULL;
            ELSE
               vtablas := ptablas;
            END IF;

            v_select := ' SELECT p.npreord npreord, crespue crespue, e.trespue trespue, e.cpregun cpregun, p.cpretip cpretip, tprefor tprefor,nmovimi nmovimi, p.esccero esccero, s.npoliza npoliza, p.cresdef cresdef' ||
                        ' FROM   PREGUNPOLCAR e, pregunpro p, ' || vtablas ||
                        'seguros s' ||
                        ' WHERE  e.cpregun = p.cpregun AND e.sseguro =' ||
                        psseguro ||
                        ' AND s.sseguro = e.sseguro AND p.cramo   = s.cramo' ||
                        ' AND p.cmodali = s.cmodali AND p.ccolect = s.ccolect' ||
                        ' AND p.ctipseg = s.ctipseg AND p.cnivel  = ''P'' ' ||
                        ' AND e.nmovimi = ' || pnmovimi ||
                        ' AND e.sproces = ' || psproces ||
                        ' AND p.cpretip <> 2' || ' UNION' ||
                        ' SELECT p.npreord npreord, 0 crespue, null trespue, p.cpregun cpregun, p.cpretip cpretip, p.tprefor tprefor,' ||
                        pnmovimi ||
                        ' nmovimi, p.esccero esccero, s.npoliza npoliza, p.cresdef cresdef FROM pregunpro p,' ||
                        vtablas || 'seguros s' ||
                        ' WHERE p.cramo = s.cramo AND p.cmodali = s.cmodali ' ||
                        ' AND p.ctipseg = s.ctipseg AND p.ccolect = s.ccolect ' ||
                        ' AND p.cnivel  = ''P'' AND s.sseguro =' ||
                        psseguro || ' AND p.cpretip = 2 ORDER BY npreord';
         END IF;

         cur1 := dbms_sql.open_cursor; --nunu
         dbms_sql.parse(cur1, v_select, dbms_sql.native);
         dbms_sql.define_column(cur1, 1, vg_npreord);
         dbms_sql.define_column(cur1, 2, vg_crespue);
         dbms_sql.define_column(cur1, 3, vg_trespue, 2000);
         dbms_sql.define_column(cur1, 4, vg_cpregun);
         dbms_sql.define_column(cur1, 5, vg_cpretip);
         dbms_sql.define_column(cur1, 6, vg_tprefor, 100);
         dbms_sql.define_column(cur1, 7, vg_nmovimi);
         -- Bug 22839 - RSC - 26/07/2012 - LCOL - Funcionalidad Certificado 0
         dbms_sql.define_column(cur1, 8, vg_esccero);
         dbms_sql.define_column(cur1, 9, vg_npoliza);
         dbms_sql.define_column(cur1, 10, vg_cresdef);
         -- Bug 22839
         fdbk := dbms_sql.execute(cur1);
      EXCEPTION
         WHEN OTHERS THEN
            dbms_sql.close_cursor(cur1);
            RETURN 111841;
      END;

      LOOP
         IF dbms_sql.fetch_rows(cur1) > 0
         THEN
            BEGIN
               dbms_sql.column_value(cur1, 1, vg_npreord);
               dbms_sql.column_value(cur1, 2, vg_crespue);
               dbms_sql.column_value(cur1, 3, vg_trespue);
               dbms_sql.column_value(cur1, 4, vg_cpregun);
               dbms_sql.column_value(cur1, 5, vg_cpretip);
               dbms_sql.column_value(cur1, 6, vg_tprefor);
               dbms_sql.column_value(cur1, 7, vg_nmovimi);
               -- Bug 22839 - RSC - 26/07/2012 - LCOL - Funcionalidad Certificado 0
               dbms_sql.column_value(cur1, 8, vg_esccero);
               dbms_sql.column_value(cur1, 9, vg_npoliza);
               dbms_sql.column_value(cur1, 10, vg_cresdef);
               -- Bug 22839
            EXCEPTION
               WHEN OTHERS THEN
                  dbms_sql.close_cursor(cur1);
                  RETURN 111842;
            END;

            BEGIN
               IF NVL(vg_cpretip, 1) = 2
               THEN
                  --Evaluación de las preguntas automáticas
                  v_resp := NULL;

                  -- Bug 22839 - RSC - 26/07/2012 - LCOL - Funcionalidad Certificado 0
                  IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'),
                         0) = 1 AND
                     vg_esccero = 1
                  THEN
                     num_err := pac_albsgt.f_tprefor(vg_tprefor,
                                                     ptablas,
                                                     psseguro,
                                                     pnriesgo,
                                                     pfcarpro,
                                                     pnmovimi,
                                                     0,
                                                     v_resp,
                                                     psproces,
                                                     1,
                                                     0,
                                                     vg_npoliza);
                  ELSE
                     -- Fin Bug 22839
                     num_err := pac_albsgt.f_tprefor(vg_tprefor,
                                                     ptablas,
                                                     psseguro,
                                                     pnriesgo,
                                                     pfcarpro,
                                                     pnmovimi,
                                                     0,
                                                     v_resp,
                                                     psproces,
                                                     1,
                                                     0);
                     -- Bug 22839 - RSC - 26/07/2012 - LCOL - Funcionalidad Certificado 0
                  END IF;

                  -- Fin Bug 22839
                  IF num_err <> 0
                  THEN
                     p_tab_error(f_sysdate,
                                 f_user,
                                 'pac_tarifas.f_insertar_preguntas_poliza',
                                 NULL,
                                 'llamada a pac_albsgt.f_tprefor ' ||
                                 vg_tprefor || ')',
                                 num_err);
                     dbms_sql.close_cursor(cur1);
                     RETURN 108424;
                  END IF;

                  v_resp := NVL(v_resp, vg_cresdef);

                  IF v_resp IS NULL
                  THEN
                     DELETE FROM pregunpolcar
                      WHERE cpregun = vg_cpregun
                        AND sseguro = psseguro
                        AND nmovimi = pnmovimi
                        AND sproces = psproces;
                  ELSE
                     BEGIN
                        INSERT INTO pregunpolcar
                           (sseguro, nmovimi, cpregun, crespue, sproces,
                            trespue)
                        VALUES
                           (psseguro, pnmovimi, vg_cpregun, v_resp,
                            psproces, vg_trespue);
                     EXCEPTION
                        WHEN dup_val_on_index THEN
                           BEGIN
                              UPDATE pregunpolcar
                                 SET crespue = v_resp, trespue = vg_trespue
                               WHERE cpregun = vg_cpregun
                                 AND sseguro = psseguro
                                 AND nmovimi = pnmovimi
                                 AND sproces = psproces;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 dbms_sql.close_cursor(cur1);
                                 RETURN 108424;
                           END;
                        WHEN OTHERS THEN
                           dbms_sql.close_cursor(cur1);
                           RETURN 108424;
                     END;
                  END IF;
               ELSE
                  v_resp := vg_crespue;
               END IF; --guardamos en valores transitorios

               -- JLB - I
               --INSERT INTO sgt_parms_transitorios
               ---           (sesion, parametro, valor)
               --   VALUES (psesion, 'RESP' || vg_cpregun, v_resp);
               num_err := pac_sgt.put(psesion, 'RESP' || vg_cpregun, v_resp);

               IF num_err <> 0
               THEN
                  RAISE NO_DATA_FOUND;
               END IF;
               -- F - JLB
            EXCEPTION
               WHEN OTHERS THEN
                  dbms_sql.close_cursor(cur1);
                  RETURN 108424;
            END;
         ELSE
            EXIT;
         END IF;
      END LOOP;

      IF dbms_sql.is_open(cur1)
      THEN
         dbms_sql.close_cursor(cur1);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF dbms_sql.is_open(cur1)
         THEN
            dbms_sql.close_cursor(cur1);
         END IF;

         RETURN 108424;
   END f_insertar_preguntas_poliza;

   /************************************************************************
    : función que inserta las preguntas a nivel de riesgo de
   una poliza, se insertan en  preguncar las preguntas y respuestas, si el modo
   no es cartera las eliminamos una vez ya hemos insertado los valores en para-
   metros transitorios.
   Hay que pasar el prefijo de las tablas de origen (EST,DIF,SOL,WEB,null...)
   ************************************************************************/
   FUNCTION f_insertar_preguntas_riesgo(psesion  IN NUMBER,
                                        psproces IN NUMBER,
                                        ptablas  VARCHAR2,
                                        psseguro IN NUMBER,
                                        pnriesgo IN NUMBER,
                                        pcramo   IN NUMBER,
                                        pcmodali IN NUMBER,
                                        pctipseg IN NUMBER,
                                        pccolect IN NUMBER,
                                        pnmovimi IN NUMBER,
                                        pfcarpro IN DATE,
                                        pmodo    VARCHAR2) RETURN NUMBER IS
      num_err NUMBER := 0;

      TYPE t_cursor IS REF CURSOR;

      c_preguntas t_cursor;
      v_select    VARCHAR2(4000);
      v_resp      NUMBER;
      cur         PLS_INTEGER; --:= DBMS_SQL.OPEN_CURSOR; nunu
      fdbk        PLS_INTEGER;
      cur1        PLS_INTEGER; --:= DBMS_SQL.OPEN_CURSOR; nunu
      vg_npreord  NUMBER;
      vg_crespue  NUMBER;
      vg_trespue  VARCHAR2(2000);
      vg_cpregun  NUMBER;
      vg_cpretip  NUMBER;
      vg_tprefor  VARCHAR2(100);
      vg_nmovimi  NUMBER;
      v_nnumlin   NUMBER;
      num_err2    NUMBER;
      -- Bug 22839 - RSC - 26/07/2012 - LCOL - Funcionalidad Certificado 0
      v_sproduc  seguros.sproduc%TYPE;
      vg_esccero pregunpro.esccero%TYPE;
      vg_npoliza seguros.npoliza%TYPE;
      vg_cresdef NUMBER;
      -- Fin Bug 22839
      vtablas VARCHAR2(100); --Bug 26638/160974 - 03/04/2014 - AMC
   BEGIN
      -- Bug 22839 - RSC - 26/07/2012 - LCOL - Funcionalidad Certificado 0
      SELECT sproduc
        INTO v_sproduc
        FROM productos
       WHERE cramo = pcramo
         AND cmodali = pcmodali
         AND ctipseg = pctipseg
         AND ccolect = pccolect;

      -- Fin bug 22839

      --creación de la select para insertar en preguncar (EST,DIF,WEB,SOL...)
      BEGIN
         IF ptablas = 'SOL'
         THEN
            v_select := ' SELECT p.npreord npreord, e.crespue crespue, e.trespue trespue, e.cpregun cpregun, p.cpretip cpretip, tprefor tprefor,nmovimi nmovimi, p.esccero esccero, s.npoliza npoliza, p.cresdef cresdef' ||
                        ' FROM   PREGUNCAR e, pregunpro p, ' ||
                        'solseguros s' || ' WHERE  e.cpregun = p.cpregun' ||
                        ' AND e.sseguro =' || psseguro ||
                        ' AND e.nriesgo =' || pnriesgo ||
                        ' AND s.ssolicit = e.sseguro' ||
                        ' AND p.cramo   = s.cramo' ||
                        ' AND p.cmodali = s.cmodali' ||
                        ' AND p.ccolect = s.ccolect' ||
                        ' AND p.ctipseg = s.ctipseg' ||
                        ' AND p.cnivel  = ''R'' ' || ' AND e.nmovimi = ' ||
                        pnmovimi || ' AND e.sproces = ' || psproces ||
                        ' AND p.cpretip <> 2' || 'UNION' ||
                        ' SELECT p.npreord npreord, 0 crespue , null trespue, p.cpregun cpregun, p.cpretip cpretip, p.tprefor tprefor,' ||
                        pnmovimi || ' nmovimi' ||
                        ', p.esccero esccero, s.npoliza npoliza, p.cresdef cresdef FROM pregunpro p,' ||
                        'solseguros s' || ' WHERE p.cramo = s.cramo ' ||
                        '   AND p.cmodali = s.cmodali ' ||
                        '   AND p.ctipseg = s.ctipseg ' ||
                        '   AND p.ccolect = s.ccolect ' ||
                        '   AND p.cnivel  = ''R'' ' ||
                        '   AND s.ssolicit =' || psseguro ||
                        ' AND p.cpretip = 2' || ' ORDER BY npreord';
         ELSE
            --Bug 26638/160974 - 03/04/2014 - AMC
            IF ptablas = 'CAR'
            THEN
               vtablas := NULL;
            ELSE
               vtablas := ptablas;
            END IF;

            v_select := ' SELECT p.npreord npreord, crespue crespue, e.trespue trespue, e.cpregun cpregun, p.cpretip cpretip, tprefor tprefor,nmovimi nmovimi, p.esccero esccero, s.npoliza npoliza, p.cresdef cresdef' ||
                        ' FROM   PREGUNCAR e, pregunpro p, ' || vtablas ||
                        'seguros s' || ' WHERE  e.cpregun = p.cpregun' ||
                        ' AND e.sseguro =' || psseguro ||
                        ' AND e.nriesgo =' || pnriesgo ||
                        ' AND s.sseguro = e.sseguro' ||
                        ' AND p.cramo   = s.cramo' ||
                        ' AND p.cmodali = s.cmodali' ||
                        ' AND p.ccolect = s.ccolect' ||
                        ' AND p.ctipseg = s.ctipseg' ||
                        ' AND p.cnivel  = ''R'' ' || ' AND e.nmovimi = ' ||
                        pnmovimi || ' AND e.sproces = ' || psproces ||
                        ' AND p.cpretip <> 2' || 'UNION' ||
                        ' SELECT p.npreord npreord, 0 crespue, null trespue, p.cpregun cpregun, p.cpretip cpretip, p.tprefor tprefor,' ||
                        pnmovimi || ' nmovimi' ||
                        ', p.esccero esccero, s.npoliza npoliza, p.cresdef cresdef FROM pregunpro p,' ||
                        vtablas || 'seguros s' ||
                        ' WHERE p.cramo = s.cramo ' ||
                        '   AND p.cmodali = s.cmodali ' ||
                        '   AND p.ctipseg = s.ctipseg ' ||
                        '   AND p.ccolect = s.ccolect ' ||
                        '   AND p.cnivel  = ''R'' ' || '   AND s.sseguro =' ||
                        psseguro || ' AND p.cpretip = 2' ||
                        ' ORDER BY npreord';
         END IF;

         cur1 := dbms_sql.open_cursor; --nunu
         dbms_sql.parse(cur1, v_select, dbms_sql.native);
         dbms_sql.define_column(cur1, 1, vg_npreord);
         dbms_sql.define_column(cur1, 2, vg_crespue);
         dbms_sql.define_column(cur1, 3, vg_trespue, 2000);
         dbms_sql.define_column(cur1, 4, vg_cpregun);
         dbms_sql.define_column(cur1, 5, vg_cpretip);
         dbms_sql.define_column(cur1, 6, vg_tprefor, 100);
         dbms_sql.define_column(cur1, 7, vg_nmovimi);
         -- Bug 22839 - RSC - 26/07/2012 - LCOL - Funcionalidad Certificado 0
         dbms_sql.define_column(cur1, 8, vg_esccero);
         dbms_sql.define_column(cur1, 9, vg_npoliza);
         dbms_sql.define_column(cur1, 10, vg_cresdef);
         -- Bug 22839
         fdbk := dbms_sql.execute(cur1);
      EXCEPTION
         WHEN OTHERS THEN
            dbms_sql.close_cursor(cur1);
            RETURN 111841;
      END;

      LOOP
         IF dbms_sql.fetch_rows(cur1) > 0
         THEN
            BEGIN
               dbms_sql.column_value(cur1, 1, vg_npreord);
               dbms_sql.column_value(cur1, 2, vg_crespue);
               dbms_sql.column_value(cur1, 3, vg_trespue);
               dbms_sql.column_value(cur1, 4, vg_cpregun);
               dbms_sql.column_value(cur1, 5, vg_cpretip);
               dbms_sql.column_value(cur1, 6, vg_tprefor);
               dbms_sql.column_value(cur1, 7, vg_nmovimi);
               -- Bug 22839 - RSC - 26/07/2012 - LCOL - Funcionalidad Certificado 0
               dbms_sql.column_value(cur1, 8, vg_esccero);
               dbms_sql.column_value(cur1, 9, vg_npoliza);
               dbms_sql.column_value(cur1, 10, vg_cresdef);
               -- Bug 22839
            EXCEPTION
               WHEN OTHERS THEN
                  dbms_sql.close_cursor(cur1);
                  RETURN 111842;
            END;

            BEGIN
               IF NVL(vg_cpretip, 1) = 2
               THEN
                  --Evaluación de las preguntas automáticas
                  v_resp := NULL;

                  -- Bug 22839 - RSC - 26/07/2012 - LCOL - Funcionalidad Certificado 0
                  IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'),
                         0) = 1 AND
                     vg_esccero = 1
                  THEN
                     num_err := pac_albsgt.f_tprefor(vg_tprefor,
                                                     ptablas,
                                                     psseguro,
                                                     pnriesgo,
                                                     pfcarpro,
                                                     pnmovimi,
                                                     0,
                                                     v_resp,
                                                     psproces,
                                                     1,
                                                     0,
                                                     vg_npoliza);
                  ELSE
                     -- Fin Bug 22839
                     num_err := pac_albsgt.f_tprefor(vg_tprefor,
                                                     ptablas,
                                                     psseguro,
                                                     pnriesgo,
                                                     pfcarpro,
                                                     pnmovimi,
                                                     0,
                                                     v_resp,
                                                     psproces,
                                                     1,
                                                     0);
                  END IF;

                  IF num_err <> 0
                  THEN
                     p_tab_error(f_sysdate,
                                 f_user,
                                 'pac_tarifas.f_insertar_preguntas_riesgo',
                                 NULL,
                                 'llamada a pac_albsgt.f_tprefor ' ||
                                 vg_tprefor || ')',
                                 num_err);
                     dbms_sql.close_cursor(cur1);
                     RETURN 108424;
                  END IF;

                  v_resp := NVL(v_resp, vg_cresdef);

                  IF v_resp IS NULL
                  THEN
                     DELETE FROM preguncar
                      WHERE cpregun = vg_cpregun
                        AND sseguro = psseguro
                        AND nriesgo = pnriesgo
                        AND nmovimi = pnmovimi
                        AND sproces = psproces;
                  ELSE
                     BEGIN
                        INSERT INTO preguncar
                           (sseguro, nriesgo, nmovimi, cpregun, crespue,
                            sproces, trespue)
                        VALUES
                           (psseguro, pnriesgo, pnmovimi, vg_cpregun,
                            v_resp, psproces, vg_trespue);
                     EXCEPTION
                        WHEN dup_val_on_index THEN
                           BEGIN
                              UPDATE preguncar
                                 SET crespue = v_resp, trespue = vg_trespue
                               WHERE cpregun = vg_cpregun
                                 AND sseguro = psseguro
                                 AND nriesgo = pnriesgo
                                 AND nmovimi = pnmovimi
                                 AND sproces = psproces;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 p_tab_error(f_sysdate,
                                             f_user,
                                             'pac_tarifas.f_insertar_preguntas_riesgo',
                                             1,
                                             'EXCEPTION WHEN OTHERS THEN',
                                             SQLERRM);
                                 dbms_sql.close_cursor(cur1);
                                 RETURN 108424;
                           END;
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate,
                                       f_user,
                                       'pac_tarifas.f_insertar_preguntas_riesgo',
                                       2,
                                       'EXCEPTION WHEN OTHERS THEN',
                                       SQLERRM);
                           dbms_sql.close_cursor(cur1);
                           RETURN 108424;
                     END;
                  END IF;
               ELSE
                  v_resp := vg_crespue;
               END IF; --guardamos en valores transitorios

               BEGIN
                  -- JLB - I
                  -- INSERT INTO sgt_parms_transitorios
                  --             (sesion, parametro, valor)
                  --     VALUES (psesion, 'RESP' || vg_cpregun, v_resp);
                  num_err := pac_sgt.put(psesion,
                                         'RESP' || vg_cpregun,
                                         v_resp);

                  IF num_err <> 0
                  THEN
                     RAISE NO_DATA_FOUND;
                  END IF;
                  --    EXCEPTION
                  --       WHEN DUP_VAL_ON_INDEX THEN
                  --         UPDATE sgt_parms_transitorios
                  --           SET valor = v_resp
                  --         WHERE sesion = psesion
                  --           AND parametro = 'RESP' || vg_cpregun;
                  -- JLB - F
               END;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate,
                              f_user,
                              'pac_tarifas.f_insertar_preguntas_riesgo',
                              3,
                              'EXCEPTION WHEN OTHERS THEN',
                              SQLERRM);
                  dbms_sql.close_cursor(cur1);
                  RETURN 108424;
            END;
         ELSE
            EXIT;
         END IF;
      END LOOP;

      IF dbms_sql.is_open(cur1)
      THEN
         dbms_sql.close_cursor(cur1);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF dbms_sql.is_open(cur1)
         THEN
            dbms_sql.close_cursor(cur1);
         END IF;

         p_tab_error(f_sysdate,
                     f_user,
                     'pac_tarifas.f_insertar_preguntas_riesgo',
                     4,
                     'EXCEPTION WHEN OTHERS THEN',
                     SQLERRM);
         RETURN 108424;
   END f_insertar_preguntas_riesgo;

   /******************************************************************
   *******************************************************************/
   FUNCTION f_insertar_preguntas_garantia(psesion   IN NUMBER,
                                          psproces  IN NUMBER,
                                          psseguro  IN NUMBER,
                                          pnriesgo  IN NUMBER,
                                          pcgarant  IN NUMBER,
                                          psproduc  IN NUMBER,
                                          pcactivi  IN NUMBER,
                                          ptablas   IN VARCHAR2,
                                          pfefecto  IN DATE,
                                          pnmovimi  IN NUMBER,
                                          pfiniefe  IN DATE,
                                          pnmovima  IN NUMBER,
                                          picapital IN NUMBER,
                                          paccion   IN VARCHAR2 DEFAULT 'NP')
   -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones únicas
    RETURN NUMBER IS
      v_resp    NUMBER;
      error     NUMBER;
      v_nnumlin NUMBER;
      num_err   NUMBER;

      CURSOR preg_gar IS
      -- Bug 9699 - APD - 08/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a PREGUNPROGARAN para la actividad cero
         SELECT p.npreord,
                p.cpregun,
                p.cpretip,
                p.tprefor,
                p.cgarant,
                pnmovima nmovima,
                p.esccero,
                cresdef
           FROM pregunprogaran p
          WHERE p.sproduc = psproduc
            AND p.cgarant = pcgarant
            AND p.cactivi = pcactivi
         UNION
         SELECT p.npreord,
                p.cpregun,
                p.cpretip,
                p.tprefor,
                p.cgarant,
                pnmovima nmovima,
                p.esccero,
                cresdef
           FROM pregunprogaran p
          WHERE p.sproduc = psproduc
            AND p.cgarant = pcgarant
            AND p.cactivi = 0
            AND NOT EXISTS (SELECT p.npreord,
                        p.cpregun,
                        p.cpretip,
                        p.tprefor,
                        p.cgarant,
                        pnmovima nmovima
                   FROM pregunprogaran p
                  WHERE p.sproduc = psproduc
                    AND p.cgarant = pcgarant
                    AND p.cactivi = pcactivi)
          ORDER BY 1; --p.npreord;

      -- Bug 9699 - APD - 08/04/2009 - Fin
      v_select VARCHAR2(4000);
      cur      PLS_INTEGER; -- := DBMS_SQL.OPEN_CURSOR;--nunu
      fdbk     PLS_INTEGER;
      -- Bug 22839 - RSC - 26/07/2012 - LCOL - Funcionalidad Certificado 0
      v_npoliza seguros.npoliza%TYPE;
      -- Fin Bug 22839
   BEGIN
      -- Bug 22839 - RSC - 26/07/2012 - LCOL - Funcionalidad Certificado 0
      IF ptablas = 'EST'
      THEN
         SELECT npoliza
           INTO v_npoliza
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT npoliza
           INTO v_npoliza
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      -- Fin Bug 22839

      --Paso las preguntas a pregungarancar
      FOR c IN preg_gar
      LOOP
         IF NVL(c.cpretip, 1) = 2
         THEN
            -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones únicas
            IF NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) IN
               (1, 2) AND
               paccion = 'APO'
            THEN
               BEGIN
                  SELECT crespue
                    INTO v_resp
                    FROM pregungarancar
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND cgarant = pcgarant
                     AND nmovima = pnmovima
                     AND nmovimi = pnmovimi
                     AND sproces = psproces
                     AND cpregun = c.cpregun;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     v_resp := NULL;
               END;
            ELSE
               -- Fin Bug 13832
               --Evaluación de las preguntas automáticas
               v_resp := 0;

               BEGIN
                  error := pac_albsgt.f_tprefor(c.tprefor,
                                                ptablas,
                                                psseguro,
                                                pnriesgo,

                                                -- JLB BUG BPM , al conectarse el BPM esta mascara da error
                                                --TO_DATE(TO_CHAR(pfefecto, 'ddmmyyyy')),
                                                TRUNC(pfefecto),
                                                -- entiendo que como mucho se queria hacer un trunc,
                                                pnmovimi,
                                                pcgarant,
                                                v_resp,
                                                psproces,
                                                pnmovima,
                                                picapital);
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 108424;
               END;

               IF error <> 0 OR
                  error IS NULL
               THEN
                  RETURN 108424;
               END IF;
            END IF;

            BEGIN
               --pfiniefe X pfefecto.Adso
               INSERT INTO pregungarancar
                  (sseguro, nriesgo, cgarant, nmovimi, cpregun, sproces,
                   crespue, nmovima, finiefe)
               VALUES
                  (psseguro, pnriesgo, pcgarant, pnmovimi, c.cpregun,
                   psproces, NVL(v_resp, c.cresdef), pnmovima, pfiniefe);
            EXCEPTION
               WHEN dup_val_on_index THEN
                  BEGIN
                     UPDATE pregungarancar
                     -- ini BUG 0025537 - 22/08/2013 - JMF
                     -- nota 0151180: pierde valor pregunta de garantia modificado, cuando se tarifa.
                     -- SET crespue = NVL(v_resp, c.cresdef)   -- v_resp
                        SET crespue = NVL(v_resp, NVL(crespue, c.cresdef))
                     -- fin BUG 0025537 - 22/08/2013 - JMF
                      WHERE sseguro = psseguro
                        AND nriesgo = pnriesgo
                        AND cgarant = pcgarant
                        AND nmovimi = pnmovimi
                        AND nmovima = pnmovima
                        AND cpregun = c.cpregun
                        AND sproces = psproces;
                  EXCEPTION
                     WHEN OTHERS THEN
                        RETURN 111662;
                  END;
               WHEN OTHERS THEN
                  RETURN 111661;
            END;
         ELSE
            BEGIN
               SELECT crespue
                 INTO v_resp
                 FROM pregungarancar
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND cgarant = pcgarant
                  AND nmovima = pnmovima
                  AND nmovimi = pnmovimi
                  AND sproces = psproces
                  AND cpregun = c.cpregun;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_resp := NULL;
            END;
         END IF;

         -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones únicas
         -- Las preguntas automáticas para la aportación extraordinaria las tratamos de forma
         -- diferente --> Son unicas y no deben variar la situación de la póliza !!!
         IF NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) IN (1, 2) AND
            paccion = 'APO'
         THEN
            IF NVL(c.cpretip, 1) = 2
            THEN
               --Evaluación de las preguntas automáticas
               v_resp := 0;

               BEGIN
                  error := pac_albsgt.f_tprefor(c.tprefor,
                                                ptablas,
                                                psseguro,
                                                pnriesgo,
                                                TRUNC(pfefecto),
                                                -- entiendo que como mucho se queria hacer un trunc,
                                                pnmovimi,
                                                pcgarant,
                                                v_resp,
                                                psproces,
                                                pnmovima,
                                                picapital);
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 108424;
               END;

               v_resp := NVL(v_resp, c.cresdef);

               IF error <> 0 OR
                  error IS NULL
               THEN
                  RETURN 108424;
               END IF;
            END IF;
         END IF;

         -- Bug 13832
         BEGIN
            -- I - JLB
            --    BEGIN
            --  INSERT INTO sgt_parms_transitorios
            --              (sesion, parametro, valor)
            --      VALUES (psesion, 'RESP' || c.cpregun, v_resp);
            error := pac_sgt.put(psesion, 'RESP' || c.cpregun, v_resp);

            IF error <> 0
            THEN
               RETURN 108438;
            END IF;
            --      EXCEPTION
            --         WHEN DUP_VAL_ON_INDEX THEN
            --            UPDATE sgt_parms_transitorios
            --               SET valor = v_resp
            --             WHERE sesion = psesion
            --               AND parametro = 'RESP' || c.cpregun;
            --      END;
            -- F - JLB
         EXCEPTION
            WHEN OTHERS THEN
               RETURN(111896);
         END;
      END LOOP;

      RETURN 0;
   END f_insertar_preguntas_garantia;

   -- BUG20498:DRA:03/01/2012:Inici
   FUNCTION f_insertar_preguntas_clausulas(psesion  IN NUMBER,
                                           psproces IN NUMBER,
                                           ptablas  VARCHAR2,
                                           psseguro IN NUMBER,
                                           pnriesgo IN NUMBER,
                                           pcramo   IN NUMBER,
                                           pcmodali IN NUMBER,
                                           pctipseg IN NUMBER,
                                           pccolect IN NUMBER,
                                           pnmovimi IN NUMBER,
                                           pfcarpro IN DATE,
                                           pmodo    VARCHAR2) RETURN NUMBER IS
      --
      num_err NUMBER := 0;

      TYPE t_cursor IS REF CURSOR;

      c_preguntas            t_cursor;
      v_select               VARCHAR2(4000);
      v_insert               VARCHAR2(4000);
      v_resp                 NUMBER;
      cur                    PLS_INTEGER;
      fdbk                   PLS_INTEGER;
      cur1                   PLS_INTEGER;
      vg_npreord             NUMBER;
      vg_crespue             NUMBER;
      vg_trespue             VARCHAR2(2000);
      vg_cpregun             NUMBER;
      vg_cpretip             NUMBER;
      vg_tprefor             VARCHAR2(100);
      vg_nmovimi             NUMBER;
      v_nnumlin              NUMBER;
      num_err2               NUMBER;
      v_delete_pol           VARCHAR2(1000);
      v_delete_pol2          VARCHAR2(1000);
      v_sentencia_delete_pol VARCHAR2(1000);
      v_insert_pol           VARCHAR2(1000);
      v_insert_pol2          VARCHAR2(1000);
      v_insert_pol3          VARCHAR2(1000);
      v_insert_pol4          VARCHAR2(1000);
      v_insert_pol5          VARCHAR2(1000);
      v_insert_pol6          VARCHAR2(1000);
      v_sentencia_insert_pol VARCHAR2(1000);
      vparam                 VARCHAR2(500) := 'params: psesion=' || psesion ||
                                              ' psproces=' || psproces ||
                                              ' ptablas=' || ptablas ||
                                              ' psseguro=' || psseguro ||
                                              ' pnriesgo=' || pnriesgo ||
                                              ' pcramo=' || pcramo ||
                                              ' pcmodali=' || pcmodali ||
                                              ' pctipseg=' || pctipseg ||
                                              ' pccolect=' || pccolect ||
                                              ' pnmovimi=' || pnmovimi ||
                                              ' pfcarpro=' || pfcarpro ||
                                              ' pmodo=' || pmodo;
   BEGIN
      --PREGUNTES A NIVELL DE POLISSA
      BEGIN
         v_select := NULL;
         v_insert := NULL;

         IF ptablas = 'SOL'
         THEN
            v_select := 'INSERT INTO PREGUNPOLCAR (sseguro,cpregun,crespue,trespue,nmovimi,sproces)' ||
                        ' SELECT p.ssolicit,p.cpregun,p.crespue,p.trespue,p.nmovimi,' ||
                        psproces || ' FROM ' || ptablas ||
                        'PREGUNPOLSEG p WHERE p.ssolicit =' || psseguro ||
                        ' AND p.cpregun IN (SELECT pp.cpregun FROM pregunpro pp WHERE pp.cpregun = p.cpregun' ||
                        ' AND pp.cramo =' || pcramo || ' AND pp.cmodali =' ||
                        pcmodali || ' AND pp.ctipseg =' || pctipseg ||
                        ' AND pp.ccolect =' || pccolect ||
                        ' AND pp.cnivel = ''C'')';
         ELSE
            -- BUG 0005557 - 02-02-09 - jmf - 0005557: CRE - Suplementos automáticos (cambio tabla).
            v_select := 'INSERT INTO PREGUNPOLCAR (sseguro,cpregun,crespue,trespue,nmovimi,sproces)' ||
                        ' SELECT p.sseguro,p.cpregun,p.crespue,p.trespue,p.nmovimi,' ||
                        psproces || ' FROM ' || ptablas ||
                        'PREGUNPOLSEG p WHERE p.sseguro =' || psseguro ||
                        ' AND p.nmovimi IN (SELECT MAX(ps.nmovimi) FROM ' ||
                        ptablas || 'PREGUNPOLSEG ps WHERE ps.sseguro =' ||
                        psseguro || ')' ||
                        ' AND p.cpregun IN (SELECT pp.cpregun FROM pregunpro pp WHERE pp.cpregun = p.cpregun' ||
                        ' AND pp.cramo =' || pcramo || ' AND pp.cmodali =' ||
                        pcmodali || ' AND pp.ctipseg =' || pctipseg ||
                        ' AND pp.ccolect =' || pccolect ||
                        ' AND pp.cnivel = ''C'')';
         END IF;

         BEGIN
            --ejecutamos el insert en preguncar, primero la borramos
            -- BUG 0005557 - 02-02-09 - jmf - 0005557: CRE - Suplementos automáticos (cambio tabla).
            DELETE pregunpolcar
             WHERE sproces = psproces
               AND sseguro = psseguro
               AND nmovimi = pnmovimi;

            EXECUTE IMMEDIATE v_select;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate,
                           f_user,
                           'PAC_TARIFAS.f_insertar_preguntas_clausulas',
                           0,
                           vparam || ' ' || SQLERRM,
                           v_select);
               RETURN 108424;
         END;
      END; -- A NIVELL DE POLISSA

      --creación de la select para insertar en preguncar (EST,DIF,WEB,SOL...)
      BEGIN
         IF ptablas = 'SOL'
         THEN
            v_select := ' SELECT p.npreord npreord, e.crespue crespue, e.trespue trespue, e.cpregun cpregun, p.cpretip cpretip, tprefor tprefor,nmovimi nmovimi' ||
                        ' FROM PREGUNPOLCAR e, pregunpro p, solseguros s' ||
                        ' WHERE e.cpregun = p.cpregun AND e.sseguro =' ||
                        psseguro ||
                        ' AND s.ssolicit = e.sseguro AND p.cramo = s.cramo' ||
                        ' AND p.cmodali = s.cmodali AND p.ccolect = s.ccolect' ||
                        ' AND p.ctipseg = s.ctipseg AND p.cnivel  = ''C'' AND e.nmovimi = ' ||
                        pnmovimi || ' AND e.sproces = ' || psproces ||
                        ' AND p.cpretip <> 2' || 'UNION' ||
                        ' SELECT p.npreord npreord, 0 crespue , null trespue, p.cpregun cpregun, p.cpretip cpretip, p.tprefor tprefor,' ||
                        pnmovimi ||
                        ' nmovimi FROM pregunpro p, solseguros s' ||
                        ' WHERE p.cramo = s.cramo AND p.cmodali = s.cmodali ' ||
                        ' AND p.ctipseg = s.ctipseg AND p.ccolect = s.ccolect ' ||
                        ' AND p.cnivel = ''C'' AND s.ssolicit =' ||
                        psseguro || ' AND p.cpretip = 2 ORDER BY npreord';
         ELSE
            v_select := ' SELECT p.npreord npreord, crespue crespue, e.trespue trespue, e.cpregun cpregun, p.cpretip cpretip, tprefor tprefor,nmovimi nmovimi' ||
                        ' FROM PREGUNPOLCAR e, pregunpro p, ' || ptablas ||
                        'seguros s' ||
                        ' WHERE  e.cpregun = p.cpregun AND e.sseguro =' ||
                        psseguro ||
                        ' AND s.sseguro = e.sseguro AND p.cramo = s.cramo' ||
                        ' AND p.cmodali = s.cmodali AND p.ccolect = s.ccolect' ||
                        ' AND p.ctipseg = s.ctipseg AND p.cnivel  = ''C'' AND e.nmovimi = ' ||
                        pnmovimi || ' AND e.sproces = ' || psproces ||
                        ' AND p.cpretip <> 2' || ' UNION ' ||
                        ' SELECT p.npreord npreord, 0 crespue, null trespue, p.cpregun cpregun, p.cpretip cpretip, p.tprefor tprefor,' ||
                        pnmovimi || ' nmovimi FROM pregunpro p,' || ptablas ||
                        'seguros s' ||
                        ' WHERE p.cramo = s.cramo AND p.cmodali = s.cmodali ' ||
                        ' AND p.ctipseg = s.ctipseg AND p.ccolect = s.ccolect ' ||
                        ' AND p.cnivel  = ''C'' AND s.sseguro =' ||
                        psseguro || ' AND p.cpretip = 2 ORDER BY npreord';
         END IF;

         cur1 := dbms_sql.open_cursor;
         dbms_sql.parse(cur1, v_select, dbms_sql.native);
         dbms_sql.define_column(cur1, 1, vg_npreord);
         dbms_sql.define_column(cur1, 2, vg_crespue);
         dbms_sql.define_column(cur1, 3, vg_trespue, 2000);
         dbms_sql.define_column(cur1, 4, vg_cpregun);
         dbms_sql.define_column(cur1, 5, vg_cpretip);
         dbms_sql.define_column(cur1, 6, vg_tprefor, 100);
         dbms_sql.define_column(cur1, 7, vg_nmovimi);
         fdbk := dbms_sql.execute(cur1);
      EXCEPTION
         WHEN OTHERS THEN
            dbms_sql.close_cursor(cur1);
            p_tab_error(f_sysdate,
                        f_user,
                        'pac_tarifas.f_insertar_preguntas_clausulas',
                        1,
                        num_err || ' - llamada a pac_albsgt.f_tprefor ' ||
                        vg_tprefor || ') - ' || vg_npreord || '-' ||
                        vg_crespue || '-' || vg_trespue || '-' ||
                        vg_cpregun || '-' || vg_cpretip || '-' ||
                        vg_nmovimi,
                        vparam);
            RETURN 111841;
      END;

      LOOP
         IF dbms_sql.fetch_rows(cur1) > 0
         THEN
            BEGIN
               dbms_sql.column_value(cur1, 1, vg_npreord);
               dbms_sql.column_value(cur1, 2, vg_crespue);
               dbms_sql.column_value(cur1, 3, vg_trespue);
               dbms_sql.column_value(cur1, 4, vg_cpregun);
               dbms_sql.column_value(cur1, 5, vg_cpretip);
               dbms_sql.column_value(cur1, 6, vg_tprefor);
               dbms_sql.column_value(cur1, 7, vg_nmovimi);
            EXCEPTION
               WHEN OTHERS THEN
                  dbms_sql.close_cursor(cur1);
                  p_tab_error(f_sysdate,
                              f_user,
                              'pac_tarifas.f_insertar_preguntas_clausulas',
                              2,
                              num_err ||
                              ' - llamada a pac_albsgt.f_tprefor ' ||
                              vg_tprefor || ') - ' || vg_npreord || '-' ||
                              vg_crespue || '-' || vg_trespue || '-' ||
                              vg_cpregun || '-' || vg_cpretip || '-' ||
                              vg_nmovimi,
                              vparam);
                  RETURN 111842;
            END;

            BEGIN
               IF NVL(vg_cpretip, 1) = 2
               THEN
                  --Evaluación de las preguntas automáticas
                  v_resp  := NULL;
                  num_err := pac_albsgt.f_tprefor(vg_tprefor,
                                                  ptablas,
                                                  psseguro,
                                                  pnriesgo,
                                                  pfcarpro,
                                                  pnmovimi,
                                                  0,
                                                  v_resp,
                                                  psproces,
                                                  1,
                                                  0);

                  IF num_err <> 0
                  THEN
                     p_tab_error(f_sysdate,
                                 f_user,
                                 'pac_tarifas.f_insertar_preguntas_clausulas',
                                 3,
                                 num_err ||
                                 ' - llamada a pac_albsgt.f_tprefor ' ||
                                 vg_tprefor || ')',
                                 vparam);
                     dbms_sql.close_cursor(cur1);
                     RETURN 108424;
                  END IF;

                  IF v_resp IS NULL
                  THEN
                     DELETE FROM pregunpolcar
                      WHERE cpregun = vg_cpregun
                        AND sseguro = psseguro
                        AND nmovimi = pnmovimi
                        AND sproces = psproces;
                  ELSE
                     BEGIN
                        INSERT INTO pregunpolcar
                           (sseguro, nmovimi, cpregun, crespue, sproces,
                            trespue)
                        VALUES
                           (psseguro, pnmovimi, vg_cpregun, v_resp,
                            psproces, vg_trespue);
                     EXCEPTION
                        WHEN dup_val_on_index THEN
                           BEGIN
                              UPDATE pregunpolcar
                                 SET crespue = v_resp, trespue = vg_trespue
                               WHERE cpregun = vg_cpregun
                                 AND sseguro = psseguro
                                 AND nmovimi = pnmovimi
                                 AND sproces = psproces;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 dbms_sql.close_cursor(cur1);
                                 p_tab_error(f_sysdate,
                                             f_user,
                                             'pac_tarifas.f_insertar_preguntas_clausulas',
                                             3,
                                             vparam || '-' || v_resp || '-' ||
                                             vg_trespue || '-' ||
                                             vg_cpregun,
                                             SQLERRM);
                                 RETURN 108424;
                           END;
                        WHEN OTHERS THEN
                           dbms_sql.close_cursor(cur1);
                           p_tab_error(f_sysdate,
                                       f_user,
                                       'pac_tarifas.f_insertar_preguntas_clausulas',
                                       4,
                                       vparam || '-' || v_resp || '-' ||
                                       vg_trespue || '-' || vg_cpregun,
                                       SQLERRM);
                           RETURN 108424;
                     END;
                  END IF;
               ELSE
                  v_resp := vg_crespue;
               END IF; --guardamos en valores transitorios

               -- I - JLB
               --     INSERT INTO sgt_parms_transitorios
               --                 (sesion, parametro, valor)
               --          VALUES (psesion, 'RESP' || vg_cpregun, v_resp);
               num_err := pac_sgt.put(psesion, 'RESP' || vg_cpregun, v_resp);

               IF num_err <> 0
               THEN
                  RETURN 108438;
               END IF;
               -- F - JLB
            EXCEPTION
               WHEN OTHERS THEN
                  dbms_sql.close_cursor(cur1);
                  p_tab_error(f_sysdate,
                              f_user,
                              'pac_tarifas.f_insertar_preguntas_clausulas',
                              5,
                              vparam || '-' || v_resp || '-' || vg_cpregun,
                              SQLERRM);
                  RETURN 108424;
            END;
         ELSE
            EXIT;
         END IF;
      END LOOP;

      IF dbms_sql.is_open(cur1)
      THEN
         dbms_sql.close_cursor(cur1);
      END IF;

      -- Traspasamos preguntas de poliza
      v_delete_pol := 'DELETE FROM ' || ptablas || 'pregunpolseg p ' ||
                      'WHERE p.cpregun IN (SELECT pg.cpregun FROM pregunpro pg,' ||
                      ptablas || 'seguros s WHERE pg.sproduc = s.sproduc' ||
                      ' AND pg.cpretip = 2 AND pg.cnivel = ''C'' ';

      IF ptablas = 'SOL'
      THEN
         v_delete_pol2 := 'AND s.ssolicit =' || psseguro ||
                          ') AND p.ssolicit = ' || psseguro || ';';
      ELSE
         v_delete_pol2 := 'AND s.sseguro =' || psseguro ||
                          ') AND p.sseguro = ' || psseguro ||
                          ' AND p.nmovimi =' || pnmovimi || ';';
      END IF;

      v_sentencia_delete_pol := 'begin ' || v_delete_pol || v_delete_pol2 ||
                                ' end;';

      BEGIN
         EXECUTE IMMEDIATE v_sentencia_delete_pol;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'PAC_TARIFAS.f_insertar_preguntas_clausulas',
                        6,
                        'delete preguntas poliza ptablas =' || ptablas ||
                        ' sseguro =' || psseguro,
                        ' sentencia =' || v_sentencia_delete_pol || SQLERRM);
            RETURN 105577;
      END;

      v_insert_pol := 'INSERT INTO ' || ptablas || 'pregunpolseg' ||
                      ' (nmovimi, cpregun, crespue,trespue, ';

      IF ptablas = 'SOL'
      THEN
         v_insert_pol2 := ' ssolicit) ';
         v_insert_pol6 := ' AND s.ssolicit =' || psseguro || ');';
      ELSE
         v_insert_pol2 := ' sseguro) ';
         v_insert_pol6 := ' AND s.sseguro =' || psseguro || ');';
      END IF;

      v_insert_pol3          := 'SELECT pp.nmovimi, pp.cpregun, pp.crespue, pp.trespue, pp.sseguro ';
      v_insert_pol5          := 'FROM pregunpolcar pp, codipregun cp WHERE pp.sproces =' ||
                                psproces || ' AND pp.sseguro = ' ||
                                psseguro || ' AND cp.cpregun = pp.cpregun ' -- BUG14172:DRA:27/04/2010
                                ||
                                ' AND((cp.ctippre IN(4, 5) AND pp.trespue IS NOT NULL) OR pp.crespue IS NOT NULL)' ||
                                ' AND pp.cpregun IN (SELECT pg.cpregun FROM pregunpro pg,' ||
                                ptablas ||
                                'seguros s WHERE pg.sproduc = s.sproduc AND pg.cpretip =2 AND pg.cnivel = ''C''';
      v_sentencia_insert_pol := 'begin ' || v_insert_pol || v_insert_pol2 ||
                                v_insert_pol3 || v_insert_pol4 ||
                                v_insert_pol5 || v_insert_pol6 || ' end;';

      BEGIN
         EXECUTE IMMEDIATE v_sentencia_insert_pol;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'PAC_TARIFAS.f_insertar_preguntas_clausulas',
                        5,
                        'insert preguntas poliza ptablas =' || ptablas ||
                        ' sseguro =' || psseguro,
                        'sentencia =' || v_sentencia_insert_pol || SQLERRM);
            RETURN 105577; --error al modificar las garantias
      END;

      --Borramos las tablas temporales
      DELETE pregunpolcar WHERE sproces = psproces;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF dbms_sql.is_open(cur1)
         THEN
            dbms_sql.close_cursor(cur1);
         END IF;

         p_tab_error(f_sysdate,
                     f_user,
                     'pac_tarifas.f_insertar_preguntas_clausulas',
                     99,
                     vparam,
                     SQLERRM);
         RETURN 108424;
   END f_insertar_preguntas_clausulas;

   -- BUG20498:DRA:03/01/2012:Fi
   FUNCTION f_tmpgarancar(ptablas  IN VARCHAR2,
                          psproces IN NUMBER,
                          psseguro IN NUMBER,
                          pnriesgo IN NUMBER,
                          pnmovimi IN NUMBER,
                          fecharef IN DATE := NULL) RETURN NUMBER IS
      v_select  VARCHAR2(4000);
      v_insert  VARCHAR2(4000);
      cur       PLS_INTEGER; -- := DBMS_SQL.OPEN_CURSOR; nunu
      fdbk      PLS_INTEGER;
      v_nmovima NUMBER;
      s         VARCHAR2(1000);
      s_sproduc NUMBER;
      -- jlb - i -- OPTIMI
      vfsysdate DATE;
      vfecharef DATE;

      -- JLB - F  --OPTIMI
      CURSOR preg_garan IS
         SELECT cgarant,
                nmovima,
                finiefe
           FROM tmp_garancar
          WHERE sproces = psproces
            AND sseguro = psseguro
            AND nriesgo = pnriesgo;
   BEGIN
      BEGIN
         -- JLB - I - OPTIMIZACION
         vfsysdate := TRUNC(f_sysdate);
         vfecharef := TRUNC(fecharef);

         /*
         --{Obtenemos el sproduc del seguro}
         IF ptablas = 'SOL' THEN
            v_select := 'select sproduc into :s_sproduc ' || 'from ' || ptablas || 'seguros '
                        || 'where ssolicit = :psseguro;';
         ELSE
            v_select := 'select sproduc into :s_sproduc ' || 'from ' || ptablas || 'seguros '
                        || 'where sseguro = :psseguro;';
         END IF;

         s := ' begin ' || v_select || ' end;';

         EXECUTE IMMEDIATE s
                     USING OUT s_sproduc, IN psseguro;
         */
         IF ptablas = 'SOL'
         THEN
            SELECT sproduc
              INTO s_sproduc
              FROM solseguros
             WHERE ssolicit = psseguro;
         ELSIF ptablas = 'EST'
         THEN
            SELECT sproduc
              INTO s_sproduc
              FROM estseguros
             WHERE sseguro = psseguro;
         ELSE
            SELECT sproduc
              INTO s_sproduc
              FROM seguros
             WHERE sseguro = psseguro;
         END IF;
         -- JLB - F - OPTIMIZACION
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'pac_tarifas',
                        1,
                        'REA',
                        'fasfas' || SQLERRM);
      END;

      -- Bug 21907 - MDS - 24/04/2012
      -- añadir PDTOTEC, PRECCOM, IDTOTEC, IRECCOM para el INSERT en TMP_GARANCAR
      -- JLB - I - OPTIMIZACION
      --      v_insert :=
      --        ' INSERT INTO TMP_GARANCAR'
      --        || ' (sseguro,cgarant,nriesgo,finiefe,norden,ctarifa,icapital,'
      --         || ' precarg,iprianu,ffinefe,cformul,iextrap,ctipfra,ifranqu,sproces,'
      --        || ' irecarg,ipritar,pdtocom,idtocom,crevali,prevali,irevali,itarifa,itarrea,'
      --        || ' ipritot,icaptot,ftarifa,cderreg,feprev,fpprev,percre,cref,'
      --        || ' cintref,pdif,pinttec,nparben,nbns,tmgaran,cmatch, tdesmat,pintfin,nmovima,nfactor,'
      --        || ' nmovi_ant,idtoint,ccampanya,nversio,cageven,nlinea,ndetgar,ctarman,PDTOTEC, PRECCOM, IDTOTEC, IRECCOM)';

      --      IF ptablas = 'SOL' THEN
      --            -- BUG 0018081 - 04-04-11 - JMF: regla 3.7
      --         -- Bug 21907 - MDS - 24/04/2012
      --         -- añadir PDTOTEC, PRECCOM, IDTOTEC, IRECCOM de la tabla SOLGARANSEG
      --         v_select :=
      --            ' SELECT ssolicit,cgarant,nriesgo,trunc(f_sysdate),norden,ctarifa,icapital,'
      --            || ' precarg,iprianu,null,cformul,iextrap,ctipfra,ifranqu,' || psproces || ','
      --            || ' irecarg,ipritar,pdtocom,idtocom,crevali,prevali,irevali,itarifa,itarrea,'
      --            --JRH Ponemos la fecha de referencia para las simulaciones de renovaciones
      --            || ' 0,0,' || 'TO_DATE(' || CHR(39)
      --            || NVL(TO_CHAR(fecharef, 'dd/mm/yyyy'), TO_CHAR(f_sysdate, 'dd/mm/yyyy'))
      --            || CHR(39) || ',''dd/mm/yyyy'')  ' || ',cderreg,feprev,fpprev,percre,cref,'
      --            || ' cintref,pdif,pinttec,nparben,nbns,tmgaran,cmatch, tdesmat,pintfin,1,1,'
      --            || ' 1,idtoint,ccampanya,nversio,null,1,0,null,PDTOTEC, PRECCOM, IDTOTEC, IRECCOM'
      --            || ' FROM ' || ptablas || 'GARANSEG';
      --         v_select := v_select || ' WHERE SSOLICIT = ' || psseguro || '   AND NRIESGO = '
      --                     || pnriesgo || ' AND NVL(cobliga,1) = 1 '
      --                     || ' AND NVL(ctipgar,0) NOT IN (8,9) ';
      --      ELSE
      --         -- Bug 10350 - 04/06/2009 - RSC - Detalle garantías (tarificación)
      --         IF NVL(f_parproductos_v(s_sproduc, 'DETALLE_GARANT'), 0) IN(1, 2) THEN
      --           -- Bug 21907 - MDS - 24/04/2012
      --            -- añadir PDTOTEC, PRECCOM, IDTOTEC, IRECCOM para el INSERT en TMP_GARANCAR
      --            v_insert :=
      --               ' INSERT INTO TMP_GARANCAR'
      --               || ' (sseguro,cgarant,nriesgo,finiefe,norden,ctarifa,icapital,'
      --               || ' precarg,iprianu,ffinefe,cformul,iextrap,ctipfra,ifranqu,sproces,'
      --               || ' irecarg,ipritar,pdtocom,idtocom,crevali,prevali,irevali,itarifa,itarrea,'
      --               || ' ipritot,icaptot,ftarifa,cderreg,feprev,fpprev,percre,cref,'
      --               || ' cintref,pdif,pinttec,nparben,nbns,tmgaran,cmatch, tdesmat,pintfin,nmovima,nfactor,'
      --               || ' nmovi_ant,idtoint,ccampanya,nversio,cageven,nlinea,ctarman,ndetgar,fefecto,fvencim,'
      --               || ' ndurcob,cparben,cprepost,ffincob,provmat0,fprovmat0,provmat1,fprovmat1,pintmin,'
      --               || ' ipripur,ipriinv,cunica,PDTOTEC, PRECCOM, IDTOTEC, IRECCOM)';
      --            -- Bug 21907 - MDS - 24/04/2012
      --           -- añadir PDTOTEC, PRECCOM, IDTOTEC, IRECCOM (todo a NULL) de la tabla DETGARANSEG
      --            v_select :=
      --               ' SELECT g.sseguro,g.cgarant,g.nriesgo,g.finiefe,g.norden,NVL(dg.ctarifa,g.ctarifa) ctarifa,NVL(dg.icapital,g.icapital) icapital,'
      --              || ' dg.precarg,NVL(dg.iprianu,g.ipritot) iprianu,g.ffinefe,g.cformul,g.iextrap,g.ctipfra,g.ifranqu,'
      --               || psproces || ','
      --               || ' dg.irecarg,NVL(dg.ipritar,g.ipritar) ipritar,NVL(dg.pdtocom,g.pdtocom) pdtocom, NVL(dg.idtocom, g.idtocom), '
      --               || ' NVL(dg.crevali,g.crevali) crevali,NVL(dg.prevali,g.prevali) prevali,NVL(dg.irevali,g.irevali) irevali,g.itarifa,dg.itarrea,'
      --               || ' g.ipritot,g.icaptot,NVL(dg.ftarifa,g.ftarifa) ftarifa,g.cderreg,g.feprev,g.fpprev,g.percre,g.cref,'
      --               || ' g.cintref,g.pdif,NVL(dg.pinttec,g.pinttec) pinttec,g.nparben,g.nbns,g.tmgaran,g.cmatch, g.tdesmat,g.pintfin,g.nmovima,g.nfactor,'
      --               || ' g.nmovimi,g.idtoint,g.ccampanya,g.nversio,NVL(dg.cagente,g.cageven) cageven,g.nlinea,dg.ctarman,NVL(dg.ndetgar,0),dg.fefecto,dg.fvencim,'
      --               || 'dg.ndurcob,dg.cparben,dg.cprepost,dg.ffincob,dg.provmat0,dg.fprovmat0,dg.provmat1,dg.fprovmat1,'
      --               || 'dg.pintmin,dg.ipripur,dg.ipriinv,NVL(dg.cunica,0),NULL, NULL, NULL, NULL'
      --               || ' FROM ' || ptablas || 'GARANSEG g, ' || ptablas || 'DETGARANSEG dg';
      -- Aqui se podria hacer la Left Join pero creemos que no es necesario
      --
      --            -- BUG 0018081 - 04-04-11 - JMF: regla 3.7
      --            v_select := v_select || ' WHERE g.SSEGURO = ' || psseguro || '   AND g.NRIESGO = '
      --                        || pnriesgo || '   AND g.FFINEFE IS NULL '
      --                        || '   AND g.sseguro = dg.sseguro '
      --                        || '   AND g.nriesgo = dg.nriesgo '
      --                        || '   AND g.cgarant = dg.cgarant '
      --                        || '   AND g.finiefe = dg.finiefe '
      --                        || '   AND g.nmovimi = dg.nmovimi ' || '   AND f_ctipgar('
      --                        || s_sproduc || ',g.cgarant,pac_seguros.ff_get_actividad(' || psseguro
      --                        || ',' || pnriesgo || ',' || CHR(39) || NVL(TO_CHAR(ptablas), 'null')
      --                        || CHR(39) || ')) <> 9  ';

      --            IF ptablas = 'EST' THEN
      --               v_select := v_select || '   AND NVL(g.cobliga,1)=1'
      --                           || '   AND NVL(g.ctipgar,0) NOT IN (8,9)'
      --                           || '   AND NVL(dg.cunica,0) NOT IN (1,2)';
      -- CUNICA NOT IN (1,2) -- Bug 11735 - RSC - 20/01/2010 - APR: suplemento de modificación de capital /prima
      --            END IF;
      --        ELSE
      --                  -- Fin Bug 10350
      --            -- Bug 21907 - MDS - 24/04/2012
      --            -- añadir PDTOTEC, PRECCOM, IDTOTEC, IRECCOM de la tabla ESTGARANSEG, GARANSEG
      --            v_select :=
      --               ' SELECT sseguro,cgarant,nriesgo,finiefe,norden,ctarifa,icapital,'
      --               || ' precarg,iprianu,ffinefe,cformul,iextrap,ctipfra,ifranqu,' || psproces
      --               || ','
      --               || ' irecarg,ipritar,pdtocom,idtocom,crevali,prevali,irevali,itarifa,itarrea,'
      --               || ' ipritot,icaptot,ftarifa,cderreg,feprev,fpprev,percre,cref,'
      --               || ' cintref,pdif,pinttec,nparben,nbns,tmgaran,cmatch, tdesmat,pintfin,nmovima,nfactor,'
      --               || ' nmovimi,idtoint,ccampanya,nversio,cageven,nlinea,0,ctarman, PDTOTEC, PRECCOM, IDTOTEC, IRECCOM'
      --               || ' FROM ' || ptablas || 'GARANSEG';
      --            -- BUG 0018081 - 04-04-11 - JMF: regla 3.7
      --            v_select := v_select || ' WHERE SSEGURO = ' || psseguro || '   AND NRIESGO = '
      --                        || pnriesgo || '   AND FFINEFE IS NULL ' || '   AND f_ctipgar('
      --                        || s_sproduc || ',cgarant,pac_seguros.ff_get_actividad(' || psseguro
      --                        || ',' || pnriesgo || ',' || CHR(39) || NVL(TO_CHAR(ptablas), 'null')
      --                        || CHR(39) || ')) <> 9  ';

      --            IF ptablas = 'EST' THEN
      --               v_select := v_select || '   AND NVL(cobliga,1)=1'
      --                           || '   AND NVL(ctipgar,0) NOT IN (8,9)';
      --            END IF;
      --         END IF;
      --      END IF;
      v_select := v_insert || v_select;

      -- JLB - F - OPTIMIZACION
      BEGIN
         -- JLB - I - OPTIMI
         -- EXECUTE IMMEDIATE v_select;
         IF ptablas = 'SOL'
         THEN
            INSERT INTO tmp_garancar
               (sseguro, cgarant, nriesgo, finiefe, norden, ctarifa,
                icapital, precarg, iprianu, ffinefe, cformul, iextrap,
                ctipfra, ifranqu, sproces, irecarg, ipritar, pdtocom,
                idtocom, crevali, prevali, irevali, itarifa, itarrea,
                ipritot, icaptot, ftarifa, cderreg, feprev, fpprev, percre,
                cref, cintref, pdif, pinttec, nparben, nbns, tmgaran, cmatch,
                tdesmat, pintfin, nmovima, nfactor, nmovi_ant, idtoint,
                ccampanya, nversio, cageven, nlinea, ndetgar, ctarman,
                pdtotec, preccom, idtotec, ireccom, finivig, ffinvig, ccobprima, ipridev
                 -- BUG 41143/229973 - 17/03/2016 - JAEG
                )
               SELECT ssolicit,
                      cgarant,
                      nriesgo,
                      vfsysdate,
                      norden,
                      ctarifa,
                      icapital,
                      precarg,
                      iprianu,
                      NULL,
                      cformul,
                      iextrap,
                      ctipfra,
                      ifranqu,
                      psproces,
                      irecarg,
                      ipritar,
                      pdtocom,
                      idtocom,
                      crevali,
                      prevali,
                      irevali,
                      itarifa,
                      itarrea,
                      --JRH Ponemos la fecha de referencia para las simulaciones de renovaciones
                      0,
                      0,
                      NVL(vfecharef, vfsysdate),
                      cderreg,
                      feprev,
                      fpprev,
                      percre,
                      cref,
                      cintref,
                      pdif,
                      pinttec,
                      nparben,
                      nbns,
                      tmgaran,
                      cmatch,
                      tdesmat,
                      pintfin,
                      1,
                      1,
                      1,
                      idtoint,
                      ccampanya,
                      nversio,
                      NULL,
                      1,
                      0,
                      NULL,
                      pdtotec,
                      preccom,
                      idtotec,
                      ireccom,
                      finivig,   -- BUG 41143/229973 - 17/03/2016 - JAEG
                      ffinvig,   -- BUG 41143/229973 - 17/03/2016 - JAEG
                      ccobprima, -- BUG 41143/229973 - 17/03/2016 - JAEG
                      ipridev    -- BUG 41143/229973 - 17/03/2016 - JAEG
                 FROM solgaranseg
                WHERE ssolicit = psseguro
                  AND nriesgo = pnriesgo
                  AND NVL(cobliga, 1) = 1
                  AND NVL(ctipgar, 0) NOT IN (8, 9);
         ELSIF ptablas = 'EST'
         THEN
            IF NVL(f_parproductos_v(s_sproduc, 'DETALLE_GARANT'), 0) IN
               (1, 2)
            THEN
               INSERT INTO tmp_garancar
                  (sseguro, cgarant, nriesgo, finiefe, norden, ctarifa,
                   icapital, precarg, iprianu, ffinefe, cformul, iextrap,
                   ctipfra, ifranqu, sproces, irecarg, ipritar, pdtocom,
                   idtocom, crevali, prevali, irevali, itarifa, itarrea,
                   ipritot, icaptot, ftarifa, cderreg, feprev, fpprev,
                   percre, cref, cintref, pdif, pinttec, nparben, nbns,
                   tmgaran, cmatch, tdesmat, pintfin, nmovima, nfactor,
                   nmovi_ant, idtoint, ccampanya, nversio, cageven, nlinea,
                   ctarman, ndetgar, fefecto, fvencim, ndurcob, cparben,
                   cprepost, ffincob, provmat0, fprovmat0, provmat1,
                   fprovmat1, pintmin, ipripur, ipriinv, cunica, pdtotec,
                   preccom, idtotec, ireccom, finivig, ffinvig, ccobprima, ipridev
                    -- BUG 41143/229973 - 17/03/2016 - JAEG
                   )
                  SELECT g.sseguro,
                         g.cgarant,
                         g.nriesgo,
                         g.finiefe,
                         g.norden,
                         NVL(dg.ctarifa, g.ctarifa) ctarifa,
                         NVL(dg.icapital, g.icapital) icapital,
                         dg.precarg,
                         NVL(dg.iprianu, g.ipritot) iprianu,
                         g.ffinefe,
                         g.cformul,
                         g.iextrap,
                         g.ctipfra,
                         g.ifranqu,
                         psproces,
                         dg.irecarg,
                         NVL(dg.ipritar, g.ipritar) ipritar,
                         NVL(dg.pdtocom, g.pdtocom) pdtocom,
                         NVL(dg.idtocom, g.idtocom),
                         NVL(dg.crevali, g.crevali) crevali,
                         NVL(dg.prevali, g.prevali) prevali,
                         NVL(dg.irevali, g.irevali) irevali,
                         g.itarifa,
                         dg.itarrea,
                         g.ipritot,
                         g.icaptot,
                         NVL(dg.ftarifa, g.ftarifa) ftarifa,
                         g.cderreg,
                         g.feprev,
                         g.fpprev,
                         g.percre,
                         g.cref,
                         g.cintref,
                         g.pdif,
                         NVL(dg.pinttec, g.pinttec) pinttec,
                         g.nparben,
                         g.nbns,
                         g.tmgaran,
                         g.cmatch,
                         g.tdesmat,
                         g.pintfin,
                         g.nmovima,
                         g.nfactor,
                         g.nmovimi,
                         g.idtoint,
                         g.ccampanya,
                         g.nversio,
                         g.cageven,
                         g.nlinea,
                         dg.ctarman,
                         NVL(dg.ndetgar, 0),
                         dg.fefecto,
                         dg.fvencim,
                         dg.ndurcob,
                         dg.cparben,
                         dg.cprepost,
                         dg.ffincob,
                         dg.provmat0,
                         dg.fprovmat0,
                         dg.provmat1,
                         dg.fprovmat1,
                         dg.pintmin,
                         dg.ipripur,
                         dg.ipriinv,
                         NVL(dg.cunica, 0),
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         finivig,   -- BUG 41143/229973 - 17/03/2016 - JAEG
                         ffinvig,   -- BUG 41143/229973 - 17/03/2016 - JAEG
			 -- BUG QT_1884 - 28/02/2018 - JLTS - se condiciona el ccobprima según cmotmov (918)
                         case when (g.cmotmov = 918) then 0 else ccobprima end, -- BUG 41143/229973 - 17/03/2016 - JAEG
                         ipridev    -- BUG 41143/229973 - 17/03/2016 - JAEG
                    FROM estgaranseg    g,
                         estdetgaranseg dg
                  -- Aqui se podria hacer la Left Join pero creemos que no es necesario
                   WHERE g.sseguro = psseguro
                     AND g.nriesgo = pnriesgo
                     AND g.ffinefe IS NULL
                     AND g.sseguro = dg.sseguro
                     AND g.nriesgo = dg.nriesgo
                     AND g.cgarant = dg.cgarant
                     AND g.finiefe = dg.finiefe
                     AND g.nmovimi = dg.nmovimi
                     AND f_ctipgar(s_sproduc,
                                   g.cgarant,
                                   pac_seguros.ff_get_actividad(psseguro,
                                                                pnriesgo,
                                                                ptablas)) <> 9
                     AND NVL(g.cobliga, 1) = 1
                     AND NVL(g.ctipgar, 0) NOT IN (8, 9)
                     AND NVL(dg.cunica, 0) NOT IN (1, 2);
            ELSE
               --EST y no es detalle garant
               INSERT INTO tmp_garancar
                  (sseguro, cgarant, nriesgo, finiefe, norden, ctarifa,
                   icapital, precarg, iprianu, ffinefe, cformul, iextrap,
                   ctipfra, ifranqu, sproces, irecarg, ipritar, pdtocom,
                   idtocom, crevali, prevali, irevali, itarifa, itarrea,
                   ipritot, icaptot, ftarifa, cderreg, feprev, fpprev,
                   percre, cref, cintref, pdif, pinttec, nparben, nbns,
                   tmgaran, cmatch, tdesmat, pintfin, nmovima, nfactor,
                   nmovi_ant, idtoint, ccampanya, nversio, cageven, nlinea,
                   ndetgar, ctarman, pdtotec, preccom, idtotec, ireccom,
                   finivig, ffinvig, ccobprima, ipridev
                    -- BUG 41143/229973 - 17/03/2016 - JAEG
                   )
                  SELECT sseguro,
                         cgarant,
                         nriesgo,
                         finiefe,
                         norden,
                         ctarifa,
                         icapital,
                         precarg,
                         iprianu,
                         ffinefe,
                         cformul,
                         iextrap,
                         ctipfra,
                         ifranqu,
                         psproces,
                         irecarg,
                         ipritar,
                         pdtocom,
                         idtocom,
                         crevali,
                         prevali,
                         irevali,
                         itarifa,
                         itarrea,
                         ipritot,
                         icaptot,
                         ftarifa,
                         cderreg,
                         feprev,
                         fpprev,
                         percre,
                         cref,
                         cintref,
                         pdif,
                         pinttec,
                         nparben,
                         nbns,
                         tmgaran,
                         cmatch,
                         tdesmat,
                         pintfin,
                         nmovima,
                         nfactor,
                         nmovimi,
                         idtoint,
                         ccampanya,
                         nversio,
                         cageven,
                         nlinea,
                         0,
                         ctarman,
                         pdtotec,
                         preccom,
                         idtotec,
                         ireccom,
                         finivig,   -- BUG 41143/229973 - 17/03/2016 - JAEG
                         ffinvig,   -- BUG 41143/229973 - 17/03/2016 - JAEG
			 -- BUG QT_1884 - 28/02/2018 - JLTS - se condiciona el ccobprima según cmotmov (918)
                         case when (g.cmotmov = 918) then 0 else ccobprima end, -- BUG 41143/229973 - 17/03/2016 - JAEG
                         ipridev    -- BUG 41143/229973 - 17/03/2016 - JAEG
                    FROM estgaranseg g
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND ffinefe IS NULL
                     AND f_ctipgar(s_sproduc,
                                   cgarant,
                                   pac_seguros.ff_get_actividad(psseguro,
                                                                pnriesgo,
                                                                ptablas)) <> 9
                     AND NVL(cobliga, 1) = 1
                     AND NVL(ctipgar, 0) NOT IN (8, 9);
            END IF;
         ELSE
            IF NVL(f_parproductos_v(s_sproduc, 'DETALLE_GARANT'), 0) IN
               (1, 2)
            THEN
               INSERT INTO tmp_garancar
                  (sseguro, cgarant, nriesgo, finiefe, norden, ctarifa,
                   icapital, precarg, iprianu, ffinefe, cformul, iextrap,
                   ctipfra, ifranqu, sproces, irecarg, ipritar, pdtocom,
                   idtocom, crevali, prevali, irevali, itarifa, itarrea,
                   ipritot, icaptot, ftarifa, cderreg, feprev, fpprev,
                   percre, cref, cintref, pdif, pinttec, nparben, nbns,
                   tmgaran, cmatch, tdesmat, pintfin, nmovima, nfactor,
                   nmovi_ant, idtoint, ccampanya, nversio, cageven, nlinea,
                   ctarman, ndetgar, fefecto, fvencim, ndurcob, cparben,
                   cprepost, ffincob, provmat0, fprovmat0, provmat1,
                   fprovmat1, pintmin, ipripur, ipriinv, cunica, pdtotec,
                   preccom, idtotec, ireccom, finivig, ffinvig, ccobprima, ipridev
                    -- BUG 41143/229973 - 17/03/2016 - JAEG
                   )
                  SELECT g.sseguro,
                         g.cgarant,
                         g.nriesgo,
                         g.finiefe,
                         g.norden,
                         NVL(dg.ctarifa, g.ctarifa) ctarifa,
                         NVL(dg.icapital, g.icapital) icapital,
                         dg.precarg,
                         NVL(dg.iprianu, g.ipritot) iprianu,
                         g.ffinefe,
                         g.cformul,
                         g.iextrap,
                         g.ctipfra,
                         g.ifranqu,
                         psproces,
                         dg.irecarg,
                         NVL(dg.ipritar, g.ipritar) ipritar,
                         NVL(dg.pdtocom, g.pdtocom) pdtocom,
                         NVL(dg.idtocom, g.idtocom),
                         NVL(dg.crevali, g.crevali) crevali,
                         NVL(dg.prevali, g.prevali) prevali,
                         NVL(dg.irevali, g.irevali) irevali,
                         g.itarifa,
                         dg.itarrea,
                         g.ipritot,
                         g.icaptot,
                         NVL(dg.ftarifa, g.ftarifa) ftarifa,
                         g.cderreg,
                         g.feprev,
                         g.fpprev,
                         g.percre,
                         g.cref,
                         g.cintref,
                         g.pdif,
                         NVL(dg.pinttec, g.pinttec) pinttec,
                         g.nparben,
                         g.nbns,
                         g.tmgaran,
                         g.cmatch,
                         g.tdesmat,
                         g.pintfin,
                         g.nmovima,
                         g.nfactor,
                         g.nmovimi,
                         g.idtoint,
                         g.ccampanya,
                         g.nversio,
                         g.cageven,
                         g.nlinea,
                         dg.ctarman,
                         NVL(dg.ndetgar, 0),
                         dg.fefecto,
                         dg.fvencim,
                         dg.ndurcob,
                         dg.cparben,
                         dg.cprepost,
                         dg.ffincob,
                         dg.provmat0,
                         dg.fprovmat0,
                         dg.provmat1,
                         dg.fprovmat1,
                         dg.pintmin,
                         dg.ipripur,
                         dg.ipriinv,
                         NVL(dg.cunica, 0),
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         finivig,   -- BUG 41143/229973 - 17/03/2016 - JAEG
                         ffinvig,   -- BUG 41143/229973 - 17/03/2016 - JAEG
                         ccobprima, -- BUG 41143/229973 - 17/03/2016 - JAEG
                         ipridev    -- BUG 41143/229973 - 17/03/2016 - JAEG
                    FROM garanseg    g,
                         detgaranseg dg
                   WHERE g.sseguro = psseguro
                     AND g.nriesgo = pnriesgo
                     AND g.ffinefe IS NULL
                     AND g.sseguro = dg.sseguro
                     AND g.nriesgo = dg.nriesgo
                     AND g.cgarant = dg.cgarant
                     AND g.finiefe = dg.finiefe
                     AND g.nmovimi = dg.nmovimi
                        -- INI RLLF 21052015 Garantias ocultas.
                     AND f_ctipgar(s_sproduc,
                                   g.cgarant,
                                   pac_seguros.ff_get_actividad(psseguro,
                                                                pnriesgo,
                                                                ptablas)) <> 9
                     AND NVL(pac_parametros.f_pargaranpro_n(s_sproduc,
                                                            0,
                                                            g.cgarant,
                                                            'EXCLUIR_PART_BENEF'),
                             0) <> 1;
               -- FIN RLLF 21052015 Garantias ocultas.
            ELSE
               -- REALES y si detprimas
               INSERT INTO tmp_garancar
                  (sseguro, cgarant, nriesgo, finiefe, norden, ctarifa,
                   icapital, precarg, iprianu, ffinefe, cformul, iextrap,
                   ctipfra, ifranqu, sproces, irecarg, ipritar, pdtocom,
                   idtocom, crevali, prevali, irevali, itarifa, itarrea,
                   ipritot, icaptot, ftarifa, cderreg, feprev, fpprev,
                   percre, cref, cintref, pdif, pinttec, nparben, nbns,
                   tmgaran, cmatch, tdesmat, pintfin, nmovima, nfactor,
                   nmovi_ant, idtoint, ccampanya, nversio, cageven, nlinea,
                   ndetgar, ctarman, pdtotec, preccom, idtotec, ireccom,
                   finivig, ffinvig, ccobprima, ipridev
                    -- BUG 41143/229973 - 17/03/2016 - JAEG
                   )
                  SELECT sseguro,
                         cgarant,
                         nriesgo,
                         finiefe,
                         norden,
                         ctarifa,
                         icapital,
                         precarg,
                         iprianu,
                         ffinefe,
                         cformul,
                         iextrap,
                         ctipfra,
                         ifranqu,
                         psproces,
                         irecarg,
                         ipritar,
                         pdtocom,
                         idtocom,
                         crevali,
                         prevali,
                         irevali,
                         itarifa,
                         itarrea,
                         ipritot,
                         icaptot,
                         ftarifa,
                         cderreg,
                         feprev,
                         fpprev,
                         percre,
                         cref,
                         cintref,
                         pdif,
                         pinttec,
                         nparben,
                         nbns,
                         tmgaran,
                         cmatch,
                         tdesmat,
                         pintfin,
                         nmovima,
                         nfactor,
                         nmovimi,
                         idtoint,
                         ccampanya,
                         nversio,
                         cageven,
                         nlinea,
                         0,
                         ctarman,
                         pdtotec,
                         preccom,
                         idtotec,
                         ireccom,
                         finivig,   -- BUG 41143/229973 - 17/03/2016 - JAEG
                         ffinvig,   -- BUG 41143/229973 - 17/03/2016 - JAEG
                         ccobprima, -- BUG 41143/229973 - 17/03/2016 - JAEG
                         ipridev    -- BUG 41143/229973 - 17/03/2016 - JAEG
                    FROM garanseg
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND ffinefe IS NULL
                     AND f_ctipgar(s_sproduc,
                                   cgarant,
                                   pac_seguros.ff_get_actividad(psseguro,
                                                                pnriesgo,
                                                                ptablas)) <> 9;
            END IF;
         END IF;
         -- JLB - F -
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'pac_tarifas',
                        1,
                        'REA',
                        'Z v_select =' || v_select || f_user || SQLERRM);
            RETURN 111930;
      END;

      --PREGUNTES A NIVELL DE POLISSA
      -- BEGIN
      -- jlb - I - OPTIMIZACION
      --v_select := NULL;
      -- v_insert := NULL;

      -- IF ptablas = 'SOL' THEN
      --    v_select :=
      --      'INSERT INTO PREGUNPOLCAR (sseguro,cpregun,crespue,trespue,nmovimi,sproces)'
      --      || ' SELECT ssolicit,cpregun,crespue,trespue,nmovimi,' || psproces || ' FROM '
      --      || ptablas || 'PREGUNPOLSEG' || ' WHERE ssolicit =' || psseguro;
      --  ELSE
      -- BUG 0005557 - 02-02-09 - jmf - 0005557: CRE - Suplementos automáticos (cambio tabla).
      --     v_select :=
      --        'INSERT INTO PREGUNPOLCAR(sseguro,cpregun,crespue,trespue,nmovimi,sproces)'
      --        || ' SELECT sseguro,cpregun,crespue,trespue,nmovimi,' || psproces || ' FROM '
      --        || ptablas || 'PREGUNPOLSEG' || ' WHERE sseguro =' || psseguro
      --        || '   AND nmovimi  in (select max(nmovimi)' || ' FROM ' || ptablas
      --        || 'PREGUNPOLSEG' || ' WHERE sseguro =' || psseguro || ')';
      --  END IF;
      BEGIN
         --ejecutamos el insert en preguncar, primero la borramos
         -- BUG 0005557 - 02-02-09 - jmf - 0005557: CRE - Suplementos automáticos (cambio tabla).
         DELETE pregunpolcar
          WHERE sproces = psproces
            AND sseguro = psseguro
            AND nmovimi = pnmovimi;

         -- I - JLB - OPTIMIZACION
         -- EXECUTE IMMEDIATE v_select;
         IF ptablas = 'SOL'
         THEN
            -- JLB - OPTI BIEN no existe la tabla SOLPREGUNPOLSEG
            -- INSERT INTO PREGUNPOLCAR (sseguro,cpregun,crespue,trespue,nmovimi,sproces)
            --  SELECT ssolicit,cpregun,crespue,trespue,nmovimi, psproces
            --   FROM  SOLPREGUNPOLSEG
            --  WHERE ssolicit = psseguro;
            NULL;
         ELSIF ptablas = 'EST'
         THEN
            INSERT INTO pregunpolcar
               (sseguro, cpregun, crespue, trespue, nmovimi, sproces)
               SELECT sseguro,
                      cpregun,
                      crespue,
                      trespue,
                      nmovimi,
                      psproces
                 FROM estpregunpolseg
                WHERE sseguro = psseguro
                  AND nmovimi IN (SELECT MAX(nmovimi)
                                    FROM estpregunpolseg
                                   WHERE sseguro = psseguro);
         ELSE
            INSERT INTO pregunpolcar
               (sseguro, cpregun, crespue, trespue, nmovimi, sproces)
               SELECT sseguro,
                      cpregun,
                      crespue,
                      trespue,
                      nmovimi,
                      psproces
                 FROM pregunpolseg
                WHERE sseguro = psseguro
                  AND nmovimi IN (SELECT MAX(nmovimi)
                                    FROM pregunpolseg
                                   WHERE sseguro = psseguro);
         END IF;
         -- F - JLB - OPTIMIZACION
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'PAC_TARIFAS.PREGUNTAS_POLIZA',
                        0,
                        'ptablas=' || ptablas || ' ' || SQLERRM,
                        v_select);
            RETURN 108424;
      END;

      --    END;   -- A NIVEL DE RISC
      -- I - jlb - OPTIM
      --BEGIN
      -- v_select := NULL;
      -- v_insert := NULL;
      -- F - jlb - OPTIM
      -- IF ptablas <> 'SOL' THEN
      -- BUG 0005557 - 02-02-09 - jmf - 0005557: CRE - Suplementos automáticos (cambio tabla).
      -- v_select :=
      --   'INSERT INTO PREGUNPOLCARTAB(sseguro,cpregun,nmovimi,sproces,nlinea,ccolumna,tvalor,fvalor,nvalor)'
      --   || ' SELECT sseguro,cpregun,nmovimi,' || psproces
      --   || ',nlinea,ccolumna,tvalor,fvalor,nvalor' || ' FROM ' || ptablas
      --   || 'PREGUNPOLSEGTAB' || ' WHERE sseguro =' || psseguro
      --   || '   AND nmovimi  in (select max(nmovimi)' || ' FROM ' || ptablas
      --   || 'PREGUNPOLSEGTAB' || ' WHERE sseguro =' || psseguro || ')';

      -- END IF;
      BEGIN
         --ejecutamos el insert en preguncar, primero la borramos
         -- BUG 0005557 - 02-02-09 - jmf - 0005557: CRE - Suplementos automáticos (cambio tabla).
         DELETE pregunpolcartab
          WHERE sproces = psproces
            AND sseguro = psseguro
            AND nmovimi = pnmovimi;

         IF ptablas = 'SOL'
         THEN
            NULL; -- no estan esas tablas
         ELSIF ptablas = 'EST'
         THEN
            INSERT INTO pregunpolcartab
               (sseguro, cpregun, nmovimi, sproces, nlinea, ccolumna,
                tvalor, fvalor, nvalor)
               SELECT sseguro,
                      cpregun,
                      nmovimi,
                      psproces,
                      nlinea,
                      ccolumna,
                      tvalor,
                      fvalor,
                      nvalor
                 FROM estpregunpolsegtab
                WHERE sseguro = psseguro
                  AND nmovimi IN (SELECT MAX(nmovimi)
                                    FROM estpregunpolsegtab
                                   WHERE sseguro = psseguro);
         ELSE
            INSERT INTO pregunpolcartab
               (sseguro, cpregun, nmovimi, sproces, nlinea, ccolumna,
                tvalor, fvalor, nvalor)
               SELECT sseguro,
                      cpregun,
                      nmovimi,
                      psproces,
                      nlinea,
                      ccolumna,
                      tvalor,
                      fvalor,
                      nvalor
                 FROM pregunpolsegtab
                WHERE sseguro = psseguro
                  AND nmovimi IN (SELECT MAX(nmovimi)
                                    FROM pregunpolsegtab
                                   WHERE sseguro = psseguro);
         END IF;
         -- EXECUTE IMMEDIATE v_select;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'PAC_TARIFAS.PREGUNTAS_POLIZA_TAB',
                        0,
                        'ptablas=' || ptablas || ' ' || SQLERRM,
                        v_select);
            RETURN 108424;
      END;

      -- I - jlb - OPTIM
      --END;   -- A NIVEL DE POLIZA TAB
      -- F - jlb - OPTIM

      --PREGUNTES A NIVELL DE RISC
      -- I - JLB - OPTIMIZACION
      --  BEGIN
      --v_select := NULL;
      --v_insert := NULL;

      --      IF ptablas = 'SOL' THEN
      --         v_select :=
      --            'INSERT INTO PREGUNCAR (sseguro,nriesgo,cpregun,crespue,trespue,nmovimi,sproces)'
      --            || ' SELECT ssolicit,nriesgo,cpregun,crespue,trespue,nmovimi,' || psproces
      --            || ' FROM ' || ptablas || 'PREGUNSEG' || ' WHERE ssolicit =' || psseguro
      --           || '   AND nriesgo = ' || pnriesgo;
      --     ELSE
      --        v_select :=
      --           'INSERT INTO PREGUNCAR (sseguro,nriesgo,cpregun,crespue,trespue,nmovimi,sproces)'
      --           || ' SELECT sseguro,nriesgo,cpregun,crespue,trespue,nmovimi,' || psproces
      --           || ' FROM ' || ptablas || 'PREGUNSEG' || ' WHERE sseguro =' || psseguro
      --           || '   AND nriesgo = ' || pnriesgo || '   AND nmovimi  in (select max(nmovimi)'
      --           || ' FROM ' || ptablas || 'PREGUNSEG' || ' WHERE sseguro =' || psseguro || ')';
      --     END IF;
      -- F - JLB - OPTIMIZACION
      BEGIN
         --ejecutamos el insert en preguncar, primero la borramos
         DELETE preguncar
          WHERE sproces = psproces
            AND sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi;

         -- i - jlb - OPTIM
         --      EXECUTE IMMEDIATE v_select;
         IF ptablas = 'SOL'
         THEN
            INSERT INTO preguncar
               (sseguro, nriesgo, cpregun, crespue, trespue, nmovimi,
                sproces)
               SELECT ssolicit,
                      nriesgo,
                      cpregun,
                      crespue,
                      trespue,
                      nmovimi,
                      psproces
                 FROM solpregunseg
                WHERE ssolicit = psseguro
                  AND nriesgo = pnriesgo;
         ELSIF ptablas = 'EST'
         THEN
            INSERT INTO preguncar
               (sseguro, nriesgo, cpregun, crespue, trespue, nmovimi,
                sproces)
               SELECT sseguro,
                      nriesgo,
                      cpregun,
                      crespue,
                      trespue,
                      nmovimi,
                      psproces
                 FROM estpregunseg
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND nmovimi IN (SELECT MAX(nmovimi)
                                    FROM estpregunseg
                                   WHERE sseguro = psseguro);
         ELSE
            INSERT INTO preguncar
               (sseguro, nriesgo, cpregun, crespue, trespue, nmovimi,
                sproces)
               SELECT sseguro,
                      nriesgo,
                      cpregun,
                      crespue,
                      trespue,
                      nmovimi,
                      psproces
                 FROM pregunseg
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND nmovimi IN (SELECT MAX(nmovimi)
                                    FROM pregunseg
                                   WHERE sseguro = psseguro);
         END IF;
         -- F - jlb -  OPTIMI
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'PAC_TARIFAS.PREGUNTAS_RIESGO',
                        0,
                        'ptablas=' || ptablas || ' ' || SQLERRM,
                        v_select);
            RETURN 108424;
      END;

      --  END;   -- A NIVEL DE RISC

      -- I - jlb -  OPTIMI
      --  BEGIN
      --     v_select := NULL;
      --     v_insert := NULL;
      -- IF ptablas <> 'SOL' THEN
      --      v_select :=
      --       'INSERT INTO PREGUNCARTAB (sseguro,nriesgo,cpregun,nmovimi,sproces,nlinea,ccolumna,tvalor,fvalor,nvalor)'
      --        || ' SELECT sseguro,nriesgo,cpregun,nmovimi,' || psproces
      --         || ',nlinea,ccolumna,tvalor,fvalor,nvalor' || ' FROM ' || ptablas
      --         || 'PREGUNSEGTAB' || ' WHERE sseguro =' || psseguro || '   AND nriesgo = '
      --         || pnriesgo || '   AND nmovimi  in (select max(nmovimi)' || ' FROM ' || ptablas
      --         || 'PREGUNSEGTAB' || ' WHERE sseguro =' || psseguro || ')';
      -- F - jlb -  OPTIMI
      BEGIN
         --ejecutamos el insert en preguncar, primero la borramos
         DELETE preguncartab
          WHERE sproces = psproces
            AND sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi;

         IF ptablas = 'SOL'
         THEN
            NULL;
         ELSIF ptablas = 'EST'
         THEN
            INSERT INTO preguncartab
               (sseguro, nriesgo, cpregun, nmovimi, sproces, nlinea,
                ccolumna, tvalor, fvalor, nvalor)
               SELECT sseguro,
                      nriesgo,
                      cpregun,
                      nmovimi,
                      psproces,
                      nlinea,
                      ccolumna,
                      tvalor,
                      fvalor,
                      nvalor
                 FROM estpregunsegtab
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND nmovimi IN (SELECT MAX(nmovimi)
                                    FROM estpregunsegtab
                                   WHERE sseguro = psseguro);
         ELSE
            INSERT INTO preguncartab
               (sseguro, nriesgo, cpregun, nmovimi, sproces, nlinea,
                ccolumna, tvalor, fvalor, nvalor)
               SELECT sseguro,
                      nriesgo,
                      cpregun,
                      nmovimi,
                      psproces,
                      nlinea,
                      ccolumna,
                      tvalor,
                      fvalor,
                      nvalor
                 FROM pregunsegtab
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND nmovimi IN (SELECT MAX(nmovimi)
                                    FROM pregunsegtab
                                   WHERE sseguro = psseguro);
         END IF;
         --  EXECUTE IMMEDIATE v_select;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'PAC_TARIFAS.PREGUNTAS_RIESGO_TAB',
                        0,
                        'ptablas=' || ptablas || ' ' || SQLERRM,
                        v_select);
            RETURN 108424;
      END;

      -- END IF;
      --    END;   -- A NIVEL DE RISC
      DELETE autdisriesgoscar
       WHERE sproces = psproces
         AND sseguro = psseguro
         AND nriesgo = pnriesgo
         AND nmovimi = pnmovimi;

      DELETE autdetriesgoscar
       WHERE sproces = psproces
         AND sseguro = psseguro
         AND nriesgo = pnriesgo
         AND nmovimi = pnmovimi;

      DELETE autriesgoscar
       WHERE sproces = psproces
         AND sseguro = psseguro
         AND nriesgo = pnriesgo
         AND nmovimi = pnmovimi;

      ---BUG 0026638: FAC LCOL - TEC - Cartera para Autos. (id 176-19)
      BEGIN
         v_select := NULL;

         BEGIN
            --ejecutamos el insert en preguncar
            IF ptablas = 'SOL'
            THEN
               NULL;
            ELSIF ptablas = 'EST'
            THEN
               INSERT INTO autriesgoscar
                  (sproces, sseguro, nriesgo, nmovimi, cversion, ctipmat,
                   cmatric, cuso, csubuso, fmatric, nkilometros, cvehnue,
                   ivehicu, npma, ntara, ccolor, nbastid, nplazas, cgaraje,
                   cusorem, cremolque, triesgo, cpaisorigen, cmotor, cchasis,
                   ivehinue, nkilometraje, ccilindraje, cpintura, ccaja,
                   ccampero, ctipcarroceria, cservicio, corigen, ctransporte,
                   codmotor, anyo, ciaant, ffinciant, cmodalidad, cpeso,
                   ctransmision, npuertas
                    --Bug 34371/199273 - 03/03/2015 - AMC
                   )
                  SELECT psproces,
                         sseguro,
                         nriesgo,
                         nmovimi,
                         cversion,
                         ctipmat,
                         cmatric,
                         cuso,
                         csubuso,
                         fmatric,
                         nkilometros,
                         cvehnue,
                         ivehicu,
                         npma,
                         ntara,
                         ccolor,
                         nbastid,
                         nplazas,
                         cgaraje,
                         cusorem,
                         cremolque,
                         triesgo,
                         cpaisorigen,
                         cmotor,
                         cchasis,
                         ivehinue,
                         nkilometraje,
                         ccilindraje,
                         cpintura,
                         ccaja,
                         ccampero,
                         ctipcarroceria,
                         cservicio,
                         corigen,
                         ctransporte,
                         codmotor,
                         anyo,
                         ciaant,
                         ffinciant,
                         cmodalidad,
                         cpeso,
                         ctransmision,
                         npuertas --Bug 34371/199273 - 03/03/2015 - AMC
                    FROM estautriesgos
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND nmovimi = NVL(pnmovimi, 1);
            ELSE
               INSERT INTO autriesgoscar
                  (sproces, sseguro, nriesgo, nmovimi, cversion, ctipmat,
                   cmatric, cuso, csubuso, fmatric, nkilometros, cvehnue,
                   ivehicu, npma, ntara, ccolor, nbastid, nplazas, cgaraje,
                   cusorem, cremolque, triesgo, cpaisorigen, cmotor, cchasis,
                   ivehinue, nkilometraje, ccilindraje, cpintura, ccaja,
                   ccampero, ctipcarroceria, cservicio, corigen, ctransporte,
                   codmotor, anyo, ciaant, ffinciant, cmodalidad, cpeso,
                   ctransmision, npuertas
                    --Bug 34371/199273 - 03/03/2015 - AMC
                   )
                  SELECT psproces,
                         sseguro,
                         nriesgo,
                         nmovimi,
                         cversion,
                         ctipmat,
                         cmatric,
                         cuso,
                         csubuso,
                         fmatric,
                         nkilometros,
                         cvehnue,
                         ivehicu,
                         npma,
                         ntara,
                         ccolor,
                         nbastid,
                         nplazas,
                         cgaraje,
                         cusorem,
                         cremolque,
                         triesgo,
                         cpaisorigen,
                         cmotor,
                         cchasis,
                         ivehinue,
                         nkilometraje,
                         ccilindraje,
                         cpintura,
                         ccaja,
                         ccampero,
                         ctipcarroceria,
                         cservicio,
                         corigen,
                         ctransporte,
                         codmotor,
                         anyo,
                         ciaant,
                         ffinciant,
                         cmodalidad,
                         cpeso,
                         ctransmision,
                         npuertas --Bug 34371/199273 - 03/03/2015 - AMC
                    FROM autriesgos
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND nmovimi = NVL(pnmovimi, 1);
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate,
                           f_user,
                           'PAC_TARIFAS.f_tmpgarancar - AUTRIESGOS',
                           0,
                           'ptablas=' || ptablas || ' ' || SQLERRM,
                           v_select);
               RETURN 9905489;
         END;
      END;

      BEGIN
         v_select := NULL;

         BEGIN
            --ejecutamos el insert en preguncar
            DELETE autconductorescar
             WHERE sproces = psproces
               AND sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi;

            IF ptablas = 'SOL'
            THEN
               NULL;
            ELSIF ptablas = 'EST'
            THEN
               INSERT INTO autconductorescar
                  (sproces, sseguro, nriesgo, nmovimi, norden, sperson,
                   fnacimi, fcarnet, csexo, npuntos, cdomici, cprincipal,
                   exper_manual, exper_cexper, exper_sinie,
                   exper_sinie_manual)
                  SELECT psproces,
                         sseguro,
                         nriesgo,
                         nmovimi,
                         norden,
                         sperson,
                         fnacimi,
                         fcarnet,
                         csexo,
                         npuntos,
                         cdomici,
                         cprincipal,
                         exper_manual,
                         exper_cexper,
                         exper_sinie,
                         exper_sinie_manual
                  -- Bug 26638/172760 - 22/04/2014 - AMC
                    FROM estautconductores
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND nmovimi = NVL(pnmovimi, 1);
            ELSE
               INSERT INTO autconductorescar
                  (sproces, sseguro, nriesgo, nmovimi, norden, sperson,
                   fnacimi, fcarnet, csexo, npuntos, cdomici, cprincipal,
                   exper_manual, exper_cexper, exper_sinie,
                   exper_sinie_manual)
                  SELECT psproces,
                         sseguro,
                         nriesgo,
                         nmovimi,
                         norden,
                         sperson,
                         fnacimi,
                         fcarnet,
                         csexo,
                         npuntos,
                         cdomici,
                         cprincipal,
                         exper_manual,
                         exper_cexper,
                         exper_sinie,
                         exper_sinie_manual
                  -- Bug 26638/172760 - 22/04/2014 - AMC
                    FROM autconductores
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND nmovimi = NVL(pnmovimi, 1);
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate,
                           f_user,
                           'PAC_TARIFAS.f_tmpgarancar - AUTCONDUTORES',
                           0,
                           'ptablas=' || ptablas || ' ' || SQLERRM,
                           v_select);
               RETURN 9905492;
         END;
      END;

      BEGIN
         BEGIN
            --ejecutamos el insert en preguncar
            IF ptablas = 'SOL'
            THEN
               NULL;
            ELSIF ptablas = 'EST'
            THEN
               INSERT INTO autdisriesgoscar
                  (sproces, sseguro, nriesgo, nmovimi, cversion,
                   cdispositivo, cpropdisp, ivaldisp, finicontrato,
                   ffincontrato, ncontrato, tdescdisp)
                  SELECT psproces,
                         sseguro,
                         nriesgo,
                         nmovimi,
                         cversion,
                         cdispositivo,
                         cpropdisp,
                         ivaldisp,
                         finicontrato,
                         ffincontrato,
                         ncontrato,
                         tdescdisp
                    FROM estautdisriesgos
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND nmovimi = NVL(pnmovimi, 1);
            ELSE
               INSERT INTO autdisriesgoscar
                  (sproces, sseguro, nriesgo, nmovimi, cversion,
                   cdispositivo, cpropdisp, ivaldisp, finicontrato,
                   ffincontrato, ncontrato, tdescdisp)
                  SELECT psproces,
                         sseguro,
                         nriesgo,
                         nmovimi,
                         cversion,
                         cdispositivo,
                         cpropdisp,
                         ivaldisp,
                         finicontrato,
                         ffincontrato,
                         ncontrato,
                         tdescdisp
                    FROM autdisriesgos
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND nmovimi = NVL(pnmovimi, 1);
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate,
                           f_user,
                           'PAC_TARIFAS.f_tmpgarancar - AUTDISRIESGOS',
                           0,
                           'ptablas=' || ptablas || ' ' || SQLERRM,
                           v_select);
               RETURN 9905491;
         END;
      END;

      BEGIN
         BEGIN
            --ejecutamos el insert en preguncar
            IF ptablas = 'SOL'
            THEN
               NULL;
            ELSIF ptablas = 'EST'
            THEN
               INSERT INTO autdetriesgoscar
                  (sproces, sseguro, nriesgo, nmovimi, cversion, caccesorio,
                   ctipacc, fini, ivalacc, tdesacc, casegurable)
                  SELECT psproces,
                         sseguro,
                         nriesgo,
                         nmovimi,
                         cversion,
                         caccesorio,
                         ctipacc,
                         fini,
                         ivalacc,
                         tdesacc,
                         casegurable
                    FROM estautdetriesgos
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND nmovimi = NVL(pnmovimi, 1);
            ELSE
               INSERT INTO autdetriesgoscar
                  (sproces, sseguro, nriesgo, nmovimi, cversion, caccesorio,
                   ctipacc, fini, ivalacc, tdesacc, casegurable)
                  SELECT psproces,
                         sseguro,
                         nriesgo,
                         nmovimi,
                         cversion,
                         caccesorio,
                         ctipacc,
                         fini,
                         ivalacc,
                         tdesacc,
                         casegurable
                    FROM autdetriesgos
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND nmovimi = NVL(pnmovimi, 1);
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate,
                           f_user,
                           'PAC_TARIFAS.f_tmpgarancar - AUTDETRIESGOS',
                           0,
                           'ptablas=' || ptablas || ' ' || SQLERRM,
                           v_select);
               RETURN 9905490;
         END;
      END;

      ---BUG 0026638: FAC LCOL - TEC - Cartera para Autos. (id 176-19)
      BEGIN
         -- para cada una de las garantia
         FOR c IN preg_garan
         LOOP
            BEGIN
               -- v_select := NULL;

               -- I - JLB - OPTIMIZACION
               /*
               IF ptablas = 'SOL' THEN
                  -- BUG 0018081 - 04-04-11 - JMF: regla 3.7
                  v_select :=
                     'INSERT INTO PREGUNGARANCAR (sseguro,nriesgo,cgarant,cpregun,crespue,trespue,nmovimi,sproces,nmovima,finiefe)'
                     || ' SELECT ssolicit,nriesgo,cgarant,cpregun,crespue,trespue,'
                     || pnmovimi || ',' || psproces || ',' || c.nmovima || ',' || CHR(39)
                     || TO_CHAR(f_sysdate, 'DD/MM/YYYY') || CHR(39) || ' FROM ' || ptablas
                     || 'PREGUNGARANSEG' || ' WHERE ssolicit =' || psseguro
                     || '   AND nriesgo = ' || pnriesgo || '   AND cgarant = ' || c.cgarant;
               ELSE
                  v_select :=
                     'INSERT INTO PREGUNGARANCAR (sseguro,nriesgo,cgarant,cpregun,crespue,trespue,nmovimi,sproces,nmovima,finiefe)'
                     || ' SELECT sseguro,nriesgo,cgarant,cpregun,crespue,trespue,nmovimi,'
                     || psproces || ',' || c.nmovima || ',finiefe' || ' FROM ' || ptablas
                     || 'PREGUNGARANSEG' || ' WHERE sseguro =' || psseguro
                     || '   AND nriesgo = ' || pnriesgo || '   AND nmovimi = '
                     || NVL(pnmovimi, 1) || '   AND nmovima = ' || NVL(c.nmovima, 1)
                     || '   AND cgarant = ' || c.cgarant;
               END IF;
                  */
               BEGIN
                  --ejecutamos el insert en preguncar
                  DELETE pregungarancar
                   WHERE sproces = psproces
                     AND sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND nmovimi = pnmovimi
                     AND nmovima = c.nmovima
                     AND cgarant = c.cgarant;

                  --EXECUTE IMMEDIATE v_select;
                  IF ptablas = 'SOL'
                  THEN
                     INSERT INTO pregungarancar
                        (sseguro, nriesgo, cgarant, cpregun, crespue,
                         trespue, nmovimi, sproces, nmovima, finiefe)
                        SELECT ssolicit,
                               nriesgo,
                               cgarant,
                               cpregun,
                               crespue,
                               trespue,
                               pnmovimi,
                               psproces,
                               c.nmovima,
                               vfsysdate
                          FROM solpregungaranseg
                         WHERE ssolicit = psseguro
                           AND nriesgo = pnriesgo
                              --  AND nmovimi = pnmovimi
                              --   AND nmovima = c.nmovima
                           AND cgarant = c.cgarant;
                  ELSIF ptablas = 'EST'
                  THEN
                     INSERT INTO pregungarancar
                        (sseguro, nriesgo, cgarant, cpregun, crespue,
                         trespue, nmovimi, sproces, nmovima, finiefe)
                        SELECT sseguro,
                               nriesgo,
                               cgarant,
                               cpregun,
                               crespue,
                               trespue,
                               nmovimi,
                               psproces,
                               c.nmovima,
                               finiefe
                          FROM estpregungaranseg
                         WHERE sseguro = psseguro
                           AND nriesgo = pnriesgo
                           AND nmovimi = NVL(pnmovimi, 1)
                           AND nmovima = NVL(c.nmovima, 1)
                           AND cgarant = c.cgarant;
                  ELSE
                     INSERT INTO pregungarancar
                        (sseguro, nriesgo, cgarant, cpregun, crespue,
                         trespue, nmovimi, sproces, nmovima, finiefe)
                        SELECT sseguro,
                               nriesgo,
                               cgarant,
                               cpregun,
                               crespue,
                               trespue,
                               nmovimi,
                               psproces,
                               c.nmovima,
                               finiefe
                          FROM pregungaranseg
                         WHERE sseguro = psseguro
                           AND nriesgo = pnriesgo
                           AND nmovimi = NVL(pnmovimi, 1)
                           AND nmovima = NVL(c.nmovima, 1)
                           AND cgarant = c.cgarant;
                  END IF;
                  -- F - JLB - OPTIMIZACION
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate,
                                 f_user,
                                 'PAC_TARIFAS.f_tmpgarancar - PREGUNGARANSEG',
                                 0,
                                 'ptablas=' || ptablas || ' ' || SQLERRM,
                                 v_select);
                     RETURN 111896;
               END;
            END;

            BEGIN
               v_select := NULL;

               -- IF ptablas <> 'SOL' THEN
               /*  v_select :=
               'INSERT INTO PREGUNGARANCARTAB (sseguro,nriesgo,cgarant,cpregun,nmovimi,sproces,nmovima,finiefe,nlinea,ccolumna,tvalor,fvalor,nvalor)'
               || ' SELECT sseguro,nriesgo,cgarant,cpregun,nmovimi,' || psproces || ','
               || c.nmovima || ',finiefe,nlinea,ccolumna,tvalor,fvalor,nvalor' || ' FROM '
               || ptablas || 'PREGUNGARANSEGTAB' || ' WHERE sseguro =' || psseguro
               || '   AND nriesgo = ' || pnriesgo || '   AND nmovimi = '
               || NVL(pnmovimi, 1) || '   AND nmovima = ' || NVL(c.nmovima, 1)
               || '   AND cgarant = ' || c.cgarant; */

               --  END IF;
               BEGIN
                  --ejecutamos el insert en preguncar
                  DELETE pregungarancartab
                   WHERE sproces = psproces
                     AND sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND nmovimi = pnmovimi
                     AND nmovima = c.nmovima
                     AND cgarant = c.cgarant;

                  -- EXECUTE IMMEDIATE v_select;
                  IF ptablas = 'EST'
                  THEN
                     INSERT INTO pregungarancartab
                        (sseguro, nriesgo, cgarant, cpregun, nmovimi,
                         sproces, nmovima, finiefe, nlinea, ccolumna, tvalor,
                         fvalor, nvalor)
                        SELECT sseguro,
                               nriesgo,
                               cgarant,
                               cpregun,
                               nmovimi,
                               psproces,
                               c.nmovima,
                               finiefe,
                               nlinea,
                               ccolumna,
                               tvalor,
                               fvalor,
                               nvalor
                          FROM estpregungaransegtab
                         WHERE sseguro = psseguro
                           AND nriesgo = pnriesgo
                           AND nmovimi = NVL(pnmovimi, 1)
                           AND nmovima = NVL(c.nmovima, 1)
                           AND cgarant = c.cgarant;
                  ELSE
                     INSERT INTO pregungarancartab
                        (sseguro, nriesgo, cgarant, cpregun, nmovimi,
                         sproces, nmovima, finiefe, nlinea, ccolumna, tvalor,
                         fvalor, nvalor)
                        SELECT sseguro,
                               nriesgo,
                               cgarant,
                               cpregun,
                               nmovimi,
                               psproces,
                               c.nmovima,
                               finiefe,
                               nlinea,
                               ccolumna,
                               tvalor,
                               fvalor,
                               nvalor
                          FROM pregungaransegtab
                         WHERE sseguro = psseguro
                           AND nriesgo = pnriesgo
                           AND nmovimi = NVL(pnmovimi, 1)
                           AND nmovima = NVL(c.nmovima, 1)
                           AND cgarant = c.cgarant;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate,
                                 f_user,
                                 'PAC_TARIFAS.f_tmpgarancar - PREGUNGARANSEGTAB',
                                 0,
                                 'ptablas=' || ptablas || ' ' || SQLERRM,
                                 v_select);
                     RETURN 111896;
               END;
            END;

            -- Bug 21121 - APD - 12/03/2012 - se realiza el traspaso de estdetprimas a tmp_detprimas
            IF NVL(f_parproductos_v(s_sproduc, 'DETPRIMAS'), 0) = 1
            THEN
               BEGIN
                  -- JLB - I - OPT
                  --    v_select := NULL;
                  -- se comenta el código de la tabla 'SOL' ya que no existe para DETPRIMAS
                  /*             -- jlb - F - OPT
                                 IF ptablas = 'SOL' THEN
                                    -- BUG 0018081 - 04-04-11 - JMF: regla 3.7
                                    v_select :=
                                       'INSERT INTO PREGUNGARANCAR (sseguro,nriesgo,cgarant,cpregun,crespue,trespue,nmovimi,sproces,nmovima,finiefe)'
                                       || ' SELECT ssolicit,nriesgo,cgarant,cpregun,crespue,trespue,'
                                       || pnmovimi || ',' || psproces || ',' || c.nmovima || ',' || CHR(39)
                                       || TO_CHAR(f_sysdate, 'DD/MM/YYYY') || CHR(39) || ' FROM ' || ptablas
                                       || 'PREGUNGARANSEG' || ' WHERE ssolicit =' || psseguro
                                       || '   AND nriesgo = ' || pnriesgo || '   AND cgarant = ' || c.cgarant;
                                 ELSE
                  */
                  -- JLB - I - OPTIMIZA
                  --    v_select :=
                  --       'INSERT INTO TMP_DETPRIMAS (sseguro, nriesgo, cgarant, nmovimi, finiefe, ccampo, cconcep, sproces, norden, iconcep, iconcep2)'
                  --       || ' SELECT sseguro,nriesgo,cgarant, nmovimi, finiefe, ccampo, cconcep,'
                  --       || psproces || ',norden, iconcep, iconcep2 ' || ' FROM ' || ptablas
                  --       || 'DETPRIMAS' || ' WHERE sseguro =' || psseguro || '   AND nriesgo = '
                  --       || pnriesgo || '   AND nmovimi = ' || NVL(pnmovimi, 1)
                  --       || '   AND cgarant = ' || c.cgarant;
                  -- JLB - F - OPTIMIZA
                  --               END IF;
                  BEGIN
                     --ejecutamos el insert en preguncar
                     DELETE tmp_detprimas
                      WHERE sproces = psproces
                        AND sseguro = psseguro
                        AND nriesgo = pnriesgo
                        AND nmovimi = pnmovimi
                        AND cgarant = c.cgarant;

                     -- JLB - I - OPTIMIZA
                     --EXECUTE IMMEDIATE v_select;
                     --/* lo quito segun hablado
                     IF ptablas = 'EST'
                     THEN
                        INSERT INTO tmp_detprimas
                           (sseguro, nriesgo, cgarant, nmovimi, finiefe,
                            ccampo, cconcep, sproces, norden, iconcep,
                            iconcep2)
                           SELECT sseguro,
                                  nriesgo,
                                  cgarant,
                                  nmovimi,
                                  finiefe,
                                  ccampo,
                                  cconcep,
                                  psproces,
                                  norden,
                                  iconcep,
                                  iconcep2
                             FROM estdetprimas
                            WHERE sseguro = psseguro
                              AND nriesgo = pnriesgo
                              AND nmovimi = NVL(pnmovimi, 1)
                              AND cgarant = c.cgarant;
                     ELSE
                        INSERT INTO tmp_detprimas
                           (sseguro, nriesgo, cgarant, nmovimi, finiefe,
                            ccampo, cconcep, sproces, norden, iconcep,
                            iconcep2)
                           SELECT sseguro,
                                  nriesgo,
                                  cgarant,
                                  nmovimi,
                                  finiefe,
                                  ccampo,
                                  cconcep,
                                  psproces,
                                  norden,
                                  iconcep,
                                  iconcep2
                             FROM detprimas
                            WHERE sseguro = psseguro
                              AND nriesgo = pnriesgo
                              AND nmovimi = NVL(pnmovimi, 1)
                              AND cgarant = c.cgarant;
                     END IF;
                     --*/

                     -- JLB - F - OPTIMIZA
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate,
                                    f_user,
                                    'PAC_TARIFAS.f_tmpgarancar - DETPRIMAS',
                                    0,
                                    'ptablas=' || ptablas || ' ' || SQLERRM,
                                    v_select);
                        RETURN 9903406;
                        -- Error en la inserción de detalle de primas
                  END;
               END;
            END IF;
            -- fin Bug 21121 - APD - 12/03/2012
         END LOOP;
      END;

      -- Bug 26638/161264 - 09/04/2014 - AMC
      BEGIN
         BEGIN
            DELETE bf_bonfransegcar
             WHERE sproces = psproces
               AND sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi;

            IF ptablas = 'SOL'
            THEN
               NULL;
            ELSIF ptablas = 'EST'
            THEN
               INSERT INTO bf_bonfransegcar
                  (sproces, sseguro, nriesgo, cgrup, csubgrup, cnivel,
                   cversion, nmovimi, finiefe, ctipgrup, cvalor1, impvalor1,
                   cvalor2, impvalor2, cimpmin, impmin, cimpmax, impmax,
                   ffinefe, cniveldefecto)
                  SELECT psproces,
                         sseguro,
                         nriesgo,
                         cgrup,
                         csubgrup,
                         cnivel,
                         cversion,
                         nmovimi,
                         finiefe,
                         ctipgrup,
                         cvalor1,
                         impvalor1,
                         cvalor2,
                         impvalor2,
                         cimpmin,
                         impmin,
                         cimpmax,
                         impmax,
                         ffinefe,
                         cniveldefecto
                    FROM estbf_bonfranseg
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND nmovimi = NVL(pnmovimi, 1);
            ELSE
               INSERT INTO bf_bonfransegcar
                  (sproces, sseguro, nriesgo, cgrup, csubgrup, cnivel,
                   cversion, nmovimi, finiefe, ctipgrup, cvalor1, impvalor1,
                   cvalor2, impvalor2, cimpmin, impmin, cimpmax, impmax,
                   ffinefe, cniveldefecto)
                  SELECT psproces,
                         sseguro,
                         nriesgo,
                         cgrup,
                         csubgrup,
                         cnivel,
                         cversion,
                         nmovimi,
                         finiefe,
                         ctipgrup,
                         cvalor1,
                         impvalor1,
                         cvalor2,
                         impvalor2,
                         cimpmin,
                         impmin,
                         cimpmax,
                         impmax,
                         ffinefe,
                         cniveldefecto
                    FROM bf_bonfranseg
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND nmovimi = NVL(pnmovimi, 1);
            END IF;
            --EXECUTE IMMEDIATE v_select;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate,
                           f_user,
                           'f_tmpgarancar - bf_bonfranseg',
                           1,
                           SQLCODE,
                           SQLERRM);
               RETURN 9906709;
         END;
      END;

      -- Fi Bug 26638/161264 - 09/04/2014 - AMC
      RETURN 0;
   END f_tmpgarancar;

   PROCEDURE continente_contenido(pcramo             IN NUMBER,
                                  pcmodali           IN NUMBER,
                                  pctipseg           IN NUMBER,
                                  pccolect           IN NUMBER,
                                  pcactivi           IN NUMBER,
                                  cont               IN NUMBER,
                                  parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb) IS
      -- Declaración de variables
      cte     NUMBER := 0;
      cdo     NUMBER := 0;
      cte2    NUMBER := 0;
      cdo2    NUMBER := 0;
      cap_cte NUMBER := 0;
      cap_cdo NUMBER := 0;
   BEGIN
      IF parms_transitorios IS NOT NULL AND
         parms_transitorios.count > 0
      THEN
         -- Inserción de parámetros de Continente/Contenido
         FOR i IN parms_transitorios.first .. parms_transitorios.last
         LOOP
            BEGIN
               SELECT DECODE(cvalpar, 1, 1, 0),
                      DECODE(cvalpar, 2, 1, 0)
                 INTO cte,
                      cdo
                 FROM pargaranpro
                WHERE cgarant = parms_transitorios(i).cgarant
                  AND cramo = pcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect
                  AND cactivi = pcactivi
                  AND cpargar = 'TIPO';

               cte2 := cte2 + cte; -- Tiene alguna garantía de continente.
               cdo2 := cdo2 + cdo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT DECODE(cvalpar, 1, 1, 0),
                            DECODE(cvalpar, 2, 1, 0)
                       INTO cte,
                            cdo
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

            IF cte = 1
            THEN
               cap_cte := cap_cte + parms_transitorios(i).icapital;
            ELSIF cdo = 1
            THEN
               cap_cdo := cap_cdo + parms_transitorios(i).icapital;
            END IF;
         END LOOP;

         parms_transitorios(cont).contnte := cap_cte;
         parms_transitorios(cont).conttdo := cap_cdo;
      ELSE
         parms_transitorios(cont).contnte := 0;
         parms_transitorios(cont).conttdo := 0;
      END IF;
   END;

   FUNCTION f_dto_vol(psesion            IN NUMBER,
                      psseguro           IN NUMBER,
                      pcgarant           IN NUMBER,
                      pcramo             IN NUMBER,
                      pcmodali           IN NUMBER,
                      pccolect           IN NUMBER,
                      pctipseg           IN NUMBER,
                      pcactivi           IN NUMBER,
                      cont               IN NUMBER,
                      prima_total        IN NUMBER,
                      piprianu           IN OUT NUMBER,
                      mensa              IN OUT VARCHAR2,
                      parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb)
      RETURN NUMBER IS
      -- Declaración de variables
      valor   NUMBER;
      formula VARCHAR2(2000);
      clav    NUMBER;
      num_err NUMBER;
      error   NUMBER;
      salir EXCEPTION;
      --
      -- Bug 21121 - APD - 22/02/2012
      v_tregconcep pac_parm_tarifas.tregconcep_tabtyp;
   BEGIN
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
                  RETURN 0;
                  -- No existen descuentos ni recargos por otros conceptos.
               WHEN OTHERS THEN
                  mensa := pcgarant || '.Dto. Vol';
                  RETURN 108422;
            END;
         WHEN OTHERS THEN
            mensa := pcgarant || '.Dto. Vol';
            RETURN 108422;
      END;

      BEGIN
         SELECT formula INTO formula FROM sgt_formulas WHERE clave = clav;
      EXCEPTION
         WHEN OTHERS THEN
            mensa := pcgarant || '.Dto. Vol';
            RETURN 108423;
      END;

      parms_transitorios(cont).iprianu := piprianu;
      pac_parm_tarifas.inserta_parametro(psesion,
                                         clav,
                                         cont,
                                         parms_transitorios,
                                         error,
                                         prima_total,
                                         v_tregconcep);

      IF error <> 0
      THEN
         mensa := pcgarant || '.Dto. Vol';
         RETURN(error);
      END IF;

      valor := pk_formulas.eval(formula, psesion);

      IF valor IS NULL
      THEN
         mensa := pcgarant || '.Dto. Vol';
         p_tab_error(f_sysdate,
                     f_user,
                     'pac_tarifas',
                     15,
                     'tarifa no encontrada para la garantía',
                     formula || '  Sesion: ' || psesion || '  .Dto vol');
         RETURN 108437;
      ELSE
         piprianu := valor;
      END IF;

      pac_parm_tarifas.borra_parametro(psesion, clav);
      RETURN 0;
   END;

   FUNCTION f_tarifar_126(psproces         IN NUMBER,
                          ptablas          IN VARCHAR2,
                          pfuncion         IN VARCHAR2,
                          pmodo            IN VARCHAR2,
                          pcramo           IN NUMBER,
                          pcmodali         IN NUMBER,
                          pctipseg         IN NUMBER,
                          pccolect         IN NUMBER,
                          psproduc         IN NUMBER,
                          pcactivi         IN NUMBER,
                          paplica_bonifica IN NUMBER,
                          pbonifica        IN NUMBER,
                          psseguro         IN NUMBER,
                          pnriesgo         IN NUMBER,
                          pfcarpro         IN DATE, --pfemisio           IN   DATE,
                          pfefecto         IN DATE,
                          pcmanual         IN NUMBER,
                          pcobjase         IN NUMBER,
                          pcforpag         IN NUMBER,
                          pidioma          IN NUMBER,
                          pmes             IN NUMBER,
                          panyo            IN NUMBER,
                          pmoneda          IN NUMBER,
                          pcclapri         IN NUMBER,
                          pprima_minima    OUT NUMBER,
                          ptotal_prima     OUT NUMBER,
                          pmensa           OUT VARCHAR2,
                          paccion          IN VARCHAR2 DEFAULT 'NP',
                          pnmovimi         IN NUMBER DEFAULT NULL --Bug 21127 - APD - 08/03/2012
                          ) RETURN NUMBER IS
      -----------------nununu
      CURSOR c_garan(wsproces NUMBER,
                     wsseguro NUMBER,
                     wnriesgo NUMBER) IS
         SELECT *
           FROM tmp_garancar
          WHERE sseguro = wsseguro
            AND nriesgo = wnriesgo
            AND sproces = wsproces;

      --   AND NVL(ctarman, 0) = 0;

      -----------------nununu
      parms_transitorios pac_parm_tarifas.parms_transitorios_tabtyb;
      num_err            NUMBER := 0;
      vpsesion           NUMBER;
      formula            VARCHAR2(2000);
      prima              NUMBER;
      lprima_bonif       NUMBER;
      pirecarg           NUMBER := 0;
      pidtocom           NUMBER := 0;
      -- Ini Bug 21907 - MDS - 24/04/2012
      v_pidtotec NUMBER := 0;
      v_pireccom NUMBER := 0;
      -- Fin Bug 21907 - MDS - 24/04/2012
      v_extraprima NUMBER;
      --La recuperamos pero no hacemos nada con ella
      vcapital_ini   NUMBER;
      vcapital_def   NUMBER;
      vapldtosenform NUMBER; --bfp bug 22212
      v_crespue_4942 pregungaranseg.crespue%TYPE;
      -- Bug 24704 - RSC - 17/12/2013
      v_crespue_4945 pregungaranseg.crespue%TYPE;
      -- Bug 24704 - RSC - 17/12/2013
   BEGIN
      num_err := f_tarifar_risc(psproces,
                                ptablas,
                                pfuncion,
                                pmodo,
                                pcramo,
                                pcmodali,
                                pctipseg,
                                pccolect,
                                psproduc,
                                pcactivi,
                                paplica_bonifica,
                                pbonifica,
                                psseguro,
                                pnriesgo,
                                pfcarpro,
                                pfefecto,
                                pcmanual,
                                pcobjase,
                                pcforpag,
                                pidioma,
                                pmes,
                                panyo,
                                pmoneda,
                                parms_transitorios,
                                ptotal_prima,
                                pmensa,
                                paccion,
                                pnmovimi);

      IF num_err <> 0
      THEN
         p_tab_error(f_sysdate,
                     f_user,
                     'PAC_TARIFAS.F_REGULARIZA',
                     1,
                     'llama al pac_tarifas.f_tarifar_risc',
                     num_err);
         RETURN num_err;
      END IF;

      --prima mínima
      FOR v_gar IN c_garan(psproces, psseguro, pnriesgo)
      LOOP
         -- loop de descomptes i recàrrecs
         prima := v_gar.iprianu;
         -- BUG 20666-  01/2012 - JRH  -  20666:  Buscar en las CAR Si tenemos el capitalo inicial informado la extraprima utiliza este capital
         vcapital_ini := NULL;
         vcapital_def := NULL;

         -- INI RLLF 28/05/2015 BUG-34418 Revalorización de capital (cambio puesto inicialmente por DCT en el pac_dincartera
         --Si tenemos parametrizado el producto a 1 no obtendremos el capital Inicial sino el que toque(revalorizado)
         IF NVL(f_parproductos_v(psproduc, 'CAPITAL_REVAL'), 0) <> 1
         THEN
            num_err := pac_preguntas.f_get_pregungaranseg(psseguro,
                                                          v_gar.cgarant,
                                                          v_gar.nriesgo,
                                                          4071,
                                                          'TMP',
                                                          vcapital_ini,
                                                          psproces);

            IF num_err = 0
            THEN
               vcapital_def := vcapital_ini;
            ELSIF num_err = 120135
            THEN
               vcapital_def := v_gar.icapital;
               --Bug 28610/0158926 - JSV - 14/11/2013
               num_err := 0;
            ELSE
               p_tab_error(f_sysdate,
                           f_user,
                           'pac_tarifas.f_tarifar_126',
                           1,
                           'Error extraprima',
                           num_err || ' - ' ||
                           'Erro buscando capital inicial');
               RETURN num_err;
            END IF;
         ELSE
            vcapital_def := v_gar.icapital;
         END IF;

         -- FIN RLLF 28/05/2015 BUG-34418 Revalorización de capital (cambio puesto inicialmente por DCT en el pac_dincartera

         -- Bug 24704 - RSC - 17/12/2013
         v_crespue_4942 := NVL(pac_preguntas.f_get_pregungaranseg_v(psseguro,
                                                                    v_gar.cgarant,
                                                                    v_gar.nriesgo,
                                                                    4942,
                                                                    'TMP',
                                                                    psproces),
                               0);
         v_crespue_4945 := NVL(pac_preguntas.f_get_pregungaranseg_v(psseguro,
                                                                    v_gar.cgarant,
                                                                    v_gar.nriesgo,
                                                                    4945,
                                                                    'TMP',
                                                                    psproces),
                               0);
         -- Fin bug 24704

         --  FiBUG 20666-  01/2012 - JRH
         --bfp bug 22212 ini
         vapldtosenform := NVL(f_parproductos_v(psproduc, 'APLDTOSENFORM'),
                               0);

         IF vapldtosenform <> 1
         THEN
            --bfp bug 22212 fi

            -- Veure si se li aplica el descompte amb el paràmetre APLICABONI
            -- Bug 21907 - MDS - 24/04/2012
            -- añadir parámetros nuevos : v_gar.pdtotec, v_gar.preccom, v_pidtotec, v_pireccom
            num_err := f_recdto(v_gar.precarg,
                                v_gar.pdtocom,
                                pirecarg,
                                pidtocom,
                                v_gar.pdtotec,
                                v_gar.preccom,
                                v_pidtotec,
                                v_pireccom, -- Bug 21907 - MDS - 24/04/2012
                                v_gar.iextrap,
                                vcapital_def,
                                v_extraprima, -- BUG19532:DRA:26/09/2011
                                prima,
                                pmoneda,
                                0,
                                lprima_bonif,
                                v_crespue_4942,
                                v_crespue_4945,
                                psproduc); -- DCT - 02/12/2014

            IF num_err <> 0
            THEN
               RETURN num_err;
            END IF;
            --bfp bug 22212 ini
         END IF;

         --bfp buf 22212 fi
         IF NVL(v_gar.ctarman, 0) <> 1
         THEN
            prima := f_round_forpag(prima, pcforpag, pmoneda, psproduc);
         END IF;

         BEGIN
            UPDATE tmp_garancar
               SET irecarg = pirecarg,
                   idtocom = pidtocom,
                   idtotec = v_pidtotec, -- Bug 21907 - MDS - 24/04/2012
                   ireccom = v_pireccom, -- Bug 21907 - MDS - 24/04/2012
                   iprianu = prima
             WHERE sseguro = psseguro
               AND cgarant = v_gar.cgarant
               AND nriesgo = v_gar.nriesgo
               AND finiefe = v_gar.finiefe
               AND nmovima = v_gar.nmovima
               AND sproces = psproces;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 101998;
         END;

         -- Bug 30171/173304 - 24/04/2014 - AMC
         num_err := f_factor_proteccion(psproduc,
                                        pcactivi,
                                        v_gar.cgarant,
                                        psseguro,
                                        pnriesgo,
                                        pnmovimi,
                                        v_gar.nmovima,
                                        pfefecto,
                                        psproces,
                                        prima,
                                        paccion);
      END LOOP; -- loop de descomptes i recàrrecs

      -- Bug 28041/155911 - APD - 15/10/2013
      IF (NOT
          (pac_iax_produccion.isaltacol AND
          NVL(pac_parametros.f_parproducto_n(psproduc, 'TARIFA_POLIZACERO'),
                0) = 0)) OR
         NVL(pac_parametros.f_parproducto_n(psproduc, 'TARIFA_POLIZACERO'),
             0) = 1
      THEN
         -- APD - 14/03/2012 - manera antigua de calcular la prima mínima pero de momento se deja
         num_err := f_regul_prima_min(ptablas,
                                      psseguro,
                                      pnriesgo,
                                      psproduc,
                                      pfefecto,
                                      ptotal_prima,
                                      pprima_minima,
                                      pcclapri,
                                      parms_transitorios,
                                      psproces,
                                      pcramo,
                                      pcmodali,
                                      pctipseg,
                                      pccolect,
                                      pcactivi,
                                      pfuncion);

         IF num_err <> 0
         THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'PAC_TARIFAS.F_REGULARIZA',
                        1,
                        'llama al pac_tarifas.f_regul_prima_min',
                        num_err);
            RETURN num_err;
         END IF;

         -- Bug 21127 - APD - 07/03/2012 - se aplica la prima minima
         -- Bug 26923/0146769 - APD - 21/06/2013 - se añade el parametro pmoneda
         num_err := pac_tarifas.f_prima_minima(ptablas,
                                               psseguro,
                                               pnriesgo,
                                               psproduc,
                                               pfefecto,
                                               parms_transitorios,
                                               psproces,
                                               pcactivi,
                                               pfuncion,
                                               2, --pcnivel (Riesgo)
                                               1, --pcposicion 1 (Después tarificar)
                                               pnmovimi,
                                               pmoneda,
                                               paccion); -- BUG 0039498 - FAL -01/20/2016

         IF num_err <> 0
         THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'PAC_TARIFAS.F_TARIFAR_126',
                        1,
                        'llama al pac_tarifas.f_prima_minima',
                        num_err);
            RETURN num_err;
         END IF;

         -- fin Bug 21127 - APD - 07/03/2012

         -- Bug 21127 - APD - 07/03/2012 - se calcula el bonus/malus
         num_err := pac_tarifas.f_calcula_bonusmalus(ptablas,
                                                     psseguro,
                                                     pnriesgo,
                                                     psproduc,
                                                     pfefecto,
                                                     parms_transitorios,
                                                     psproces,
                                                     pcactivi,
                                                     pfuncion,
                                                     pnmovimi);

         IF num_err <> 0
         THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'PAC_TARIFAS.F_TARIFAR_126',
                        1,
                        'llama al pac_tarifas.f_prima_minima',
                        num_err);
            RETURN num_err;
         END IF;

         -- Bug 21127 - APD - 07/03/2012 - se aplica la prima minima
         -- Bug 26923/0146769 - APD - 21/06/2013 - se añade el parametro pmoneda
         num_err := pac_tarifas.f_prima_minima(ptablas,
                                               psseguro,
                                               pnriesgo,
                                               psproduc,
                                               pfefecto,
                                               parms_transitorios,
                                               psproces,
                                               pcactivi,
                                               pfuncion,
                                               2, --pcnivel (Riesgo)
                                               2,
                                               --pcposicion 2 (Después bonus malsu)
                                               pnmovimi,
                                               pmoneda,
                                               paccion); -- BUG 0039498 - FAL -01/20/2016

         IF num_err <> 0
         THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'PAC_TARIFAS.F_TARIFAR_126',
                        1,
                        'llama al pac_tarifas.f_prima_minima',
                        num_err);
            RETURN num_err;
         END IF;
      END IF; -- fin Bug 28041/155911 - APD - 15/10/2013

      RETURN num_err;
   END;

   FUNCTION f_regul_prima_min(ptablas            IN VARCHAR2,
                              psseguro           IN NUMBER,
                              pnriesgo           IN NUMBER,
                              psproduc           IN NUMBER,
                              pfefecto           IN DATE,
                              pprima_total       IN NUMBER,
                              pprima_minima      OUT NUMBER,
                              pcclapri           IN NUMBER,
                              parms_transitorios IN OUT pac_parm_tarifas.parms_transitorios_tabtyb,
                              psproces           IN NUMBER,
                              pcramo             IN NUMBER,
                              pcmodali           IN NUMBER,
                              pctipseg           IN NUMBER,
                              pccolect           IN NUMBER,
                              pcactivi           IN NUMBER,
                              pfuncion           IN VARCHAR2) RETURN NUMBER IS
      i_iprimin productos.iprimin%TYPE; --NUMBER(13, 2);
      c_cprimin productos.cprimin%TYPE; --NUMBER;

      CURSOR cgarantias IS
         SELECT *
           FROM garanpro
          WHERE sproduc = psproduc
            AND ctipgar = 9;

      gar_regu     cgarantias%ROWTYPE;
      v_sentencia  VARCHAR2(1000);
      c_cobliga    NUMBER := 1; --MARCADA
      i_icapital   NUMBER;
      i_iprima     tmp_garancar.iprianu%TYPE; --NUMBER(13, 2);
      vtotal_prima tmp_garancar.iprianu%TYPE; --NUMBER(13, 2);
      v_prima      VARCHAR2(100);
      vpsesion     NUMBER;
      formula      VARCHAR2(250);
      pmensa       VARCHAR2(1000);
      v_nmovimi    NUMBER;
      num_err      NUMBER := 0;
      v_cramo      seguros.cramo%TYPE;
      v_cmodali    seguros.cmodali%TYPE;
      v_ctipseg    seguros.ctipseg%TYPE;
      v_ccolect    seguros.ccolect%TYPE;
      -- Bug 21121 - APD - 22/02/2012
      v_tregconcep pac_parm_tarifas.tregconcep_tabtyp;
   BEGIN
      /*********************************************************************
       Función que inserta la garantía de regularización si
          -- 1.- la prima minima de la póliza es menor a la del producto
         -- 2 .-Existe una garantía de tipo 9 para ese producto
      ***********************************************************************/
      BEGIN
         SELECT NVL(iprimin, 0),
                cprimin
           INTO i_iprimin,
                c_cprimin
           FROM productos
          WHERE sproduc = psproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 104347; -- producte no trobat a la taula PRODUCTOS
      END;

      -- Bug 9699 - APD - 08/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a PARGARANPRO para la actividad cero
      --- calculamos el  importe total del la poliza.
      -- Esto ya se hace al llamar a la funcion f_pargaranpro_v
      SELECT SUM(iprianu)
        INTO vtotal_prima
        FROM tmp_garancar g
       WHERE g.sseguro = psseguro
         AND g.nriesgo = pnriesgo
         AND sproces = psproces
         AND NVL(f_pargaranpro_v(pcramo,
                                 pcmodali,
                                 pctipseg,
                                 pccolect,
                                 pcactivi,
                                 g.cgarant,
                                 'SUMA_PRIMA'),
                 1) <> 0;

      -- Bug 9699 - APD - 08/04/2009 - Fin

      -- En el caso que la prima mínima calculada  buscamos cual es la prima mínima
      IF NVL(c_cprimin, 2) = 1
      THEN
         --prima mínima calculada
         i_iprimin := NULL;

         IF pcclapri IS NOT NULL
         THEN
            SELECT sgt_sesiones.nextval INTO vpsesion FROM dual;

            BEGIN
               SELECT formula
                 INTO formula
                 FROM sgt_formulas
                WHERE clave = pcclapri;
            EXCEPTION
               WHEN OTHERS THEN
                  pmensa := SUBSTR(SQLERRM, 1, 100);
                  RETURN 101150;
            END;

            BEGIN
               pac_parm_tarifas.inserta_parametro(vpsesion,
                                                  pcclapri,
                                                  1,
                                                  parms_transitorios,
                                                  num_err,
                                                  NULL,
                                                  v_tregconcep);

               IF num_err <> 0
               THEN
                  RETURN(num_err);
               END IF;

               --          Insertem el paràmetre pfunción per saber què estem fent
               --              desde SGT ( Cartera, Alta, suplement, Reasseg )
               -- JLB - I
               DECLARE
                  vvalor NUMBER;
                  -- JLB - F
               BEGIN
                  -- JLB - I
                  -- INSERT INTO sgt_parms_transitorios
                  --            (sesion, parametro,
                  --             valor)
                  --     VALUES (vpsesion, 'FUNCION',
                  --             DECODE(pfuncion, 'TAR', 1, 'SUP', 2, 'CAR', 3, 'REA', 4, 0));
                  IF pfuncion = 'TAR'
                  THEN
                     vvalor := 1;
                  ELSIF pfuncion = 'SUP'
                  THEN
                     vvalor := 2;
                  ELSIF pfuncion = 'CAR'
                  THEN
                     vvalor := 3;
                  ELSIF pfuncion = 'REA'
                  THEN
                     vvalor := 4;
                  ELSE
                     vvalor := 0;
                  END IF;

                  num_err := pac_sgt.put(vpsesion, 'FUNCION', vvalor);

                  IF num_err <> 0
                  THEN
                     RETURN 109843;
                  END IF;
                  -- JLB - F
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 109843;
               END;

               --trobem el valor de la prima minima
               i_iprimin := pk_formulas.eval(formula, vpsesion);
               num_err   := pac_parm_tarifas.borra_param_sesion(vpsesion);
            EXCEPTION
               WHEN OTHERS THEN
                  pmensa := SUBSTR(SQLERRM, 1, 100);
                  RETURN 9999;
            END;
         END IF;
      END IF;

      -- si la prima és més petita que la prima mínima del producte
      IF vtotal_prima < i_iprimin
      THEN
         -- lo hago con un cursor por si existe más de una me quedo con
         -- la última garantía de regularización.
         FOR c IN cgarantias
         LOOP
            gar_regu := c;
         END LOOP;

         -- si hay alguna gar de regularización insertamos en las tablas que toquen
         IF gar_regu.cgarant IS NOT NULL
         THEN
            -- obtenemos la prima y el capital
            i_icapital := 0;
            i_iprima   := (i_iprimin - vtotal_prima);
            v_prima    := TO_CHAR(i_iprima);
            v_prima    := REPLACE(v_prima, ',', '.');

            -- primero la borramos por si existe dinamicamente
            IF ptablas = 'SOL'
            THEN
               v_sentencia := 'delete from ' || ptablas ||
                              'garanseg where ssolicit =' || psseguro ||
                              ' and cgarant = ' || gar_regu.cgarant;
            ELSE
               v_sentencia := 'delete from ' || ptablas ||
                              'garanseg where sseguro =' || psseguro ||
                              ' and ffinefe is null and cgarant = ' ||
                              gar_regu.cgarant;
            END IF;

            BEGIN
               EXECUTE IMMEDIATE v_sentencia;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate,
                              f_user,
                              'PAC_TARIFAS.F_REGULARIZA',
                              1,
                              'DELETE DE GARANTIAS',
                              SQLERRM);
                  RETURN 151602; --error ins/borrar garantia de regul.
            END;

            --Obtenemos el mov que estamos tarifando para insertarlo más tarde
            BEGIN
               SELECT NVL(MAX(nmovi_ant), 1)
                 INTO v_nmovimi
                 FROM tmp_garancar
                WHERE sseguro = psseguro
                  AND sproces = psproces;
            END;

            BEGIN
               -- Siempre insertamos en tmp_garancar
               INSERT INTO tmp_garancar
                  (sseguro, cgarant, finiefe, nriesgo, norden, icapital,
                   precarg, iprianu, ffinefe, cformul, iextrap, sproces,
                   ctipfra, ifranqu, irecarg, ipritar, pdtocom, idtocom,
                   crevali, irevali, prevali, itarifa, itarrea, ipritot,
                   icaptot, ftarifa, nmovima, nmovi_ant)
               VALUES
                  (psseguro, gar_regu.cgarant, pfefecto, pnriesgo,
                   gar_regu.norden, 0, 0, i_iprima, NULL, NULL, NULL,
                   psproces, NULL, NULL, 0, i_iprima, 0, 0, 0, 0, 0,
                   i_iprima, 0, i_iprima, 0, pfefecto, v_nmovimi, v_nmovimi);
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate,
                              f_user,
                              'PAC_TARIFAS.F_REGULARIZA',
                              2,
                              'INSERT DE tmp_garancar',
                              SQLERRM);
            END;

            ------------------------------------------------------
            IF ptablas IS NOT NULL
            THEN
               IF ptablas = 'SOL'
               THEN
                  -- BUG 0018081 - 04-04-11 - JMF: regla 3.7
                  v_sentencia := 'INSERT INTO ' || ptablas || 'garanseg' ||
                                 '(ssolicit, nriesgo, cgarant, finiefe,' ||
                                 'crevali, prevali, irevali,' ||
                                 'ifranqu, ctarifa, nparben,' ||
                                 'nbns, cobliga, norden,' ||
                                 'ctipgar,icapital,iprianu,' ||
                                 'itarifa, ipritar)' || 'VALUES (' ||
                                 psseguro || ',' || pnriesgo || ',  ' ||
                                 gar_regu.cgarant || ', ' || chr(39) ||
                                 TO_CHAR(pfefecto, 'DD/MM/YYYY') || chr(39) || ', ' ||
                                 gar_regu.crevali || ', ' ||
                                 NVL(gar_regu.prevali, 0) || ', ' ||
                                 NVL(gar_regu.irevali, 0) || ', ' ||
                                 NVL(gar_regu.ifranqu, 0) || ', ' ||
                                 gar_regu.ctarifa || ', ' ||
                                 gar_regu.nparben || ', ' || gar_regu.nbns || ', ' ||
                                 c_cobliga || ', ' || gar_regu.norden || ', ' ||
                                 gar_regu.ctipgar || ', ' || i_icapital || ', ' ||
                                 v_prima || ' , ' || v_prima || ',' ||
                                 v_prima || ')';
               ELSE
                  -- BUG 0018081 - 04-04-11 - JMF: regla 3.7
                  v_sentencia := 'INSERT INTO ' || ptablas || 'garanseg' ||
                                 '(sseguro, nriesgo, nmovimi, cgarant, finiefe,' ||
                                 'ffinefe, crevali, prevali, irevali,' ||
                                 'ifranqu, ctarifa, nparben,' ||
                                 'nbns, cobliga, norden,' ||
                                 'ctipgar,icapital,icaptot,iprianu,' ||
                                 'ipritot,itarifa, ipritar)' || 'VALUES (' ||
                                 psseguro || ',' || pnriesgo || ', ' ||
                                 v_nmovimi || ', ' || gar_regu.cgarant || ', ' ||
                                 chr(39) || pfefecto || chr(39) || ', ' ||
                                 'NULL' || ', ' || gar_regu.crevali || ', ' ||
                                 NVL(gar_regu.prevali, 0) || ', ' ||
                                 NVL(gar_regu.irevali, 0) || ', ' ||
                                 NVL(gar_regu.ifranqu, 0) || ', ' ||
                                 gar_regu.ctarifa || ', ' ||
                                 gar_regu.nparben || ', ' || gar_regu.nbns || ', ' ||
                                 c_cobliga || ', ' || gar_regu.norden || ', ' ||
                                 gar_regu.ctipgar || ', ' || i_icapital || ', ' ||
                                 i_icapital || ', ' || v_prima || ', ' ||
                                 v_prima || ' , ' || v_prima || ',' ||
                                 v_prima || ')';
               END IF;
            ELSE
               -- BUG 0018081 - 04-04-11 - JMF: regla 3.7
               v_sentencia := 'INSERT INTO ' || ptablas || 'garanseg' ||
                              '(sseguro, nriesgo, nmovimi, cgarant, finiefe,' ||
                              'ffinefe, crevali, prevali, irevali,' ||
                              'ifranqu, ctarifa, nparben,' ||
                              'nbns,  norden,' ||
                              'icapital,icaptot,iprianu,' ||
                              'ipritot,itarifa, ipritar)' || 'VALUES (' ||
                              psseguro || ',' || pnriesgo || ', ' ||
                              v_nmovimi || ', ' || gar_regu.cgarant || ', ' ||
                              chr(39) || pfefecto || chr(39) || ', ' ||
                              'NULL' || ', ' || gar_regu.crevali || ', ' ||
                              NVL(gar_regu.prevali, 0) || ', ' ||
                              NVL(gar_regu.irevali, 0) || ', ' ||
                              NVL(gar_regu.ifranqu, 0) || ', ' ||
                              gar_regu.ctarifa || ', ' || gar_regu.nparben || ', ' ||
                              gar_regu.nbns || ', ' || gar_regu.norden || ', ' ||
                              i_icapital || ', ' || i_icapital || ', ' ||
                              v_prima || ', ' || v_prima || ' , ' ||
                              v_prima || ',' || v_prima || ')';
            END IF;

            BEGIN
               EXECUTE IMMEDIATE v_sentencia;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate,
                              f_user,
                              'PAC_TARIFAS.F_REGULARIZA',
                              1,
                              'INSERT DE GARANTIAS',
                              SQLERRM);
                  RETURN 151602; --error ins/borrar garantia de regul.
            END;
         END IF;
      ELSE
         -- vtotal_prima >= i_primin;
         FOR c IN cgarantias
         LOOP
            gar_regu := c;
         END LOOP;

         -- si hay alguna gar de regularización insertamos en las tablas que toquen
         IF gar_regu.cgarant IS NOT NULL
         THEN
            -- borramos de garanseg
            IF ptablas = 'SOL'
            THEN
               v_sentencia := 'delete from ' || ptablas ||
                              'garanseg where ssolicit =' || psseguro ||
                              ' and cgarant = ' || gar_regu.cgarant;
               --BUG 0026460 - 21-03-2013 - dlF y Txema
            ELSIF ptablas = 'EST'
            THEN
               --BUG 0025940 - 06-03-2013 - Txema ini (modificación dlF)
               v_sentencia := 'update ' || ptablas ||
                              'garanseg set cobliga=0, ipritar = 0,iprianu=0, ipritot=0, itarrea=0, itarifa=0, itotanu=0' ||
                              ' where sseguro = ' || psseguro ||
                              ' and cgarant = ' || gar_regu.cgarant ||
                              ' and ffinefe is null ';
               --fin BUG 0025940 - 06-03-2013 - Txema
            ELSE
               v_sentencia := 'delete from ' || ptablas ||
                              'garanseg where sseguro =' || psseguro ||
                              ' and ffinefe is null and cgarant = ' ||
                              gar_regu.cgarant;
            END IF;

            --fin BUG 0026460 - 21-03-2013 - dlF y Txema
            BEGIN
               EXECUTE IMMEDIATE v_sentencia;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate,
                              f_user,
                              'PAC_TARIFAS.f_regul_prima_min',
                              1,
                              SUBSTR('DELETE DE GARANTIAS - v_sentencia: ' ||
                                     v_sentencia,
                                     1,
                                     500),
                              SQLERRM);
                  RETURN 151602;
            END;

            --BUG 0025940 - 06-03-2013 - Txema ini (modificación dlF)
            DELETE tmp_garancar
             WHERE sseguro = psseguro
               AND cgarant = gar_regu.cgarant;
            --fin BUG 0025940 - 06-03-2013 - Txema
         END IF;
      END IF;

      pprima_minima := i_iprimin;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 151602;
   END f_regul_prima_min;

   -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones únicas
   PROCEDURE p_ajustes_detgaranseg(ptablas  IN VARCHAR2,
                                   psseguro IN NUMBER,
                                   pnriesgo IN NUMBER,
                                   pmodali  IN VARCHAR2) IS
      v_sproduc seguros.sproduc%TYPE;
      v_sseguro seguros.sseguro%TYPE;
      v_sproces tmp_garancar.sproces%TYPE;
   BEGIN
      -- Bug 11735 - RSC - 19/01/2010 - APR - suplemento de modificación de capital /prima
      IF ptablas = 'EST'
      THEN
         SELECT sproduc,
                ssegpol
           INTO v_sproduc,
                v_sseguro
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT sproduc,
                sseguro
           INTO v_sproduc,
                v_sseguro
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      -- Fin Bug 11735

      -- Bug 11735 - RSC - 19/01/2010 - APR - suplemento de modificación de capital /prima
      IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN (1, 2) AND
         pmodali IN ('ALTA', 'MODIF', 'EXTRA')
      THEN
         IF ptablas = 'EST'
         THEN
            -- Obtenemos un proceso temporal
            SELECT starifa.nextval INTO v_sproces FROM dual;

            -- Traspaso a TMP_GARANCAR (Para realizar el traspaso final)
            INSERT INTO tmp_garancar
               (sseguro, cgarant, nriesgo, finiefe, norden, ctarifa,
                icapital, precarg, iprianu, ffinefe, cformul, iextrap,
                ctipfra, ifranqu, sproces, irecarg, ipritar, pdtocom,
                idtocom, crevali, prevali, irevali, itarifa, itarrea,
                ipritot, icaptot, ftarifa, cderreg, feprev, fpprev, percre,
                cref, cintref, pdif, pinttec, nparben, nbns, tmgaran, cmatch,
                tdesmat, pintfin, nmovima, nfactor, nmovi_ant, idtoint,
                ccampanya, nversio, cageven, nlinea, ctarman, ndetgar,
                fefecto, fvencim, ndurcob, cparben, cprepost, ffincob,
                provmat0, fprovmat0, provmat1, fprovmat1, pintmin, ipripur,
                ipriinv, cunica)
               SELECT sseguro,
                      cgarant,
                      nriesgo,
                      finiefe,
                      0,
                      ctarifa,
                      icapital,
                      precarg,
                      iprianu,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      v_sproces,
                      irecarg,
                      ipritar,
                      pdtocom,
                      idtocom,
                      crevali,
                      prevali,
                      irevali,
                      NULL,
                      itarrea,
                      NULL,
                      NULL,
                      ftarifa,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      pinttec,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      nmovimi,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      cagente,
                      NULL,
                      ctarman,
                      ndetgar,
                      fefecto,
                      fvencim,
                      ndurcob,
                      cparben,
                      cprepost,
                      ffincob,
                      provmat0,
                      fprovmat0,
                      provmat1,
                      fprovmat1,
                      pintmin,
                      ipripur,
                      ipriinv,
                      cunica
                 FROM estdetgaranseg
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND cunica <> 1
                  AND pac_propio.f_prima_cero(psseguro,
                                              cgarant,
                                              ndetgar,
                                              ptablas) = 0;

            -- Borramos y reinsertamos en estdetgaranseg fusionado
            FOR regs IN (SELECT *
                           FROM estdetgaranseg
                          WHERE sseguro = psseguro
                            AND nriesgo = pnriesgo
                            AND cunica <> 1
                            AND pac_propio.f_prima_cero(psseguro,
                                                        cgarant,
                                                        ndetgar,
                                                        ptablas) = 0)
            LOOP
               DELETE estdetgaranseg
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND cgarant = regs.cgarant
                  AND ndetgar = regs.ndetgar;
            END LOOP;

            FOR regs IN (SELECT cgarant,
                                sseguro,
                                nriesgo,
                                finiefe,
                                nmovima,
                                ctarifa,
                                MIN(ndetgar) ndetgar,
                                MIN(fefecto) fefecto,
                                MAX(fvencim) fvencim,
                                MIN(ndurcob) ndurcob,
                                pinttec,
                                MIN(ftarifa) ftarifa,
                                MIN(crevali) crevali,
                                MIN(prevali) prevali,
                                SUM(irevali) irevali,
                                SUM(icapital) icapital,
                                SUM(iprianu) iprianu,
                                MIN(precarg) precarg,
                                SUM(irecarg) irecarg,
                                MIN(cparben) cparben,
                                MIN(cprepost) cprepost,
                                MAX(ffincob) ffincob,
                                SUM(ipritar) ipritar,
                                SUM(provmat0) provmat0,
                                MAX(fprovmat0) fprovmat0,
                                SUM(provmat1) provmat1,
                                MAX(fprovmat1) fprovmat1,
                                MIN(pintmin) pintmin,
                                MIN(pdtocom) pdtocom,
                                SUM(idtocom) idtocom,
                                MIN(ctarman) ctarman,
                                SUM(ipripur) ipripur,
                                SUM(ipriinv) ipriinv,
                                SUM(itarrea) itarrea
                           FROM tmp_garancar
                          WHERE sseguro = psseguro
                            AND nriesgo = pnriesgo
                            AND sproces = v_sproces
                          GROUP BY cgarant,
                                   sseguro,
                                   nriesgo,
                                   finiefe,
                                   nmovima,
                                   ctarifa,
                                   pinttec
                          ORDER BY cgarant,
                                   sseguro,
                                   nriesgo,
                                   finiefe,
                                   nmovima,
                                   ctarifa,
                                   pinttec)
            LOOP
               INSERT INTO estdetgaranseg
                  (sseguro, cgarant, nriesgo, finiefe, nmovimi, ctarifa,
                   icapital, precarg, iprianu, irecarg, ipritar, pdtocom,
                   idtocom, crevali, prevali, irevali, itarrea, ftarifa,
                   pinttec, cagente, ctarman, ndetgar, fefecto, fvencim,
                   ndurcob, cparben, cprepost, ffincob, provmat0, fprovmat0,
                   provmat1, fprovmat1, pintmin, ipripur, ipriinv, cunica)
                  SELECT regs.sseguro,
                         regs.cgarant,
                         regs.nriesgo,
                         regs.finiefe,
                         regs.nmovima,
                         regs.ctarifa,
                         regs.icapital,
                         regs.precarg,
                         regs.iprianu,
                         regs.irecarg,
                         regs.ipritar,
                         regs.pdtocom,
                         regs.idtocom,
                         regs.crevali,
                         regs.prevali,
                         regs.irevali,
                         regs.itarrea,
                         regs.ftarifa,
                         regs.pinttec,
                         NULL,
                         regs.ctarman,
                         regs.ndetgar,
                         regs.fefecto,
                         regs.fvencim,
                         regs.ndurcob,
                         regs.cparben,
                         regs.cprepost,
                         regs.ffincob,
                         regs.provmat0,
                         regs.fprovmat0,
                         regs.provmat1,
                         regs.fprovmat1,
                         regs.pintmin,
                         regs.ipripur,
                         regs.ipriinv,
                         0
                    FROM dual;
            END LOOP;

            -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones únicas
            IF pmodali IN ('ALTA', 'MODIF', 'EXTRA')
            THEN
               UPDATE estdetgaranseg
                  SET cunica = 0
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND cunica NOT IN (0, 1);
            END IF;

            -- Fin Bug 13832

            -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones únicas
            IF pmodali NOT IN ('EXTRA')
            THEN
               -- Fin Bug 13832
               FOR regs IN (SELECT sseguro,
                                   cgarant,
                                   nriesgo,
                                   SUM(icapital) icapital,
                                   SUM(iprianu) iprianu,
                                   SUM(irecarg) irecarg,
                                   SUM(ipritar) ipritar,
                                   SUM(idtocom) idtocom,
                                   SUM(itarrea) itarrea
                              FROM estdetgaranseg
                             WHERE sseguro = psseguro
                               AND nriesgo = pnriesgo
                               AND cunica <> 1
                            -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones únicas
                             GROUP BY sseguro,
                                      cgarant,
                                      nriesgo
                             ORDER BY sseguro,
                                      cgarant,
                                      nriesgo)
               LOOP
                  -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones únicas
                  IF pmodali IN ('MODIF')
                  THEN
                     UPDATE estgaranseg
                        SET icapital = regs.icapital,
                            iprianu  = regs.iprianu,
                            irecarg  = regs.irecarg,
                            ipritar  = regs.ipritar,
                            -- BUG 17341 - 24/01/2011 - JMP - Grabamos 'regs.ipritar' en IPRITAR
                            idtocom = regs.idtocom,
                            itarrea = regs.itarrea,
                            icaptot = regs.icapital,
                            ipritot = regs.iprianu
                      WHERE sseguro = psseguro
                        AND cgarant = regs.cgarant
                        AND nriesgo = regs.nriesgo
                        AND ffinefe IS NULL;
                  ELSE
                     -- Fin Bug 13832
                     UPDATE estgaranseg
                        SET icapital = regs.icapital,
                            iprianu  = regs.iprianu,
                            irecarg  = regs.irecarg,
                            ipritar  = regs.ipritar,
                            idtocom  = regs.idtocom,
                            itarrea  = regs.itarrea,
                            icaptot  = regs.icapital,
                            ipritot  = regs.iprianu
                      WHERE sseguro = psseguro
                        AND cgarant = regs.cgarant
                        AND nriesgo = regs.nriesgo
                        AND ffinefe IS NULL;
                  END IF;
               END LOOP;
               -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones únicas
            ELSE
               UPDATE estdetgaranseg
                  SET cunica = 1
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND ctarifa =
                      f_parproductos_v(v_sproduc, 'CTARIFA_APORTEXTRA');

               FOR regs IN (SELECT cgarant,
                                   nriesgo
                              FROM estgaranseg
                             WHERE sseguro = psseguro
                               AND nriesgo = pnriesgo)
               LOOP
                  UPDATE estgaranseg
                     SET (icapital,
                          iprianu,
                          irecarg,
                          ipritar,
                          idtocom,
                          itarrea,
                          icaptot,
                          ipritot) =
                         (SELECT icapital,
                                 iprianu,
                                 irecarg,
                                 ipritar,
                                 idtocom,
                                 itarrea,
                                 icaptot,
                                 ipritot
                            FROM garanseg
                           WHERE sseguro = v_sseguro
                             AND ffinefe IS NULL
                             AND cgarant = regs.cgarant
                             AND nriesgo = regs.nriesgo)
                   WHERE sseguro = psseguro
                     AND cgarant = regs.cgarant
                     AND nriesgo = regs.nriesgo
                     AND ffinefe IS NULL;
               END LOOP;
            END IF;
            -- Fin Bug 13832
         END IF;
      END IF;
      -- Fin Bug 11735
	  
	  
	  if v_sproduc not in (8062, 8063)then
		p_valida_garan(psseguro); --IAXIS-4779 CJMR
	  end if;

   END p_ajustes_detgaranseg;

   -- Fin Bug 13832

   -- Bug 11735 - RSC - 19/01/2010 - APR - suplemento de modificación de capital /prima (afegim parámetre pmodali)
   FUNCTION f_traspaso_de_tmp_a_tablas(ptablas  IN VARCHAR2,
                                       psseguro IN NUMBER,
                                       pnriesgo IN NUMBER,
                                       pnmovimi IN NUMBER,
                                       psproces IN NUMBER,
                                       pmoneda  IN NUMBER,
                                       pmodali  IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      num_err                 NUMBER;
      vmensa                  VARCHAR2(1000);
      vmodo                   VARCHAR2(10);
      v_update                VARCHAR2(1000);
      v_update2               VARCHAR2(1000);
      v_where                 VARCHAR2(1000);
      v_where2                VARCHAR2(1000);
      v_sentencia_update      VARCHAR2(1000);
      v_delete                VARCHAR2(1000);
      v_delete2               VARCHAR2(1000);
      v_sentencia_delete      VARCHAR2(1000);
      v_insert                VARCHAR2(1000);
      v_insert2               VARCHAR2(1000);
      v_insert3               VARCHAR2(1000);
      v_insert4               VARCHAR2(1000);
      v_insert5               VARCHAR2(1000);
      v_insert6               VARCHAR2(1000);
      v_sentencia_insert      VARCHAR2(1000);
      v_delete_risc           VARCHAR2(1000);
      v_delete_risc2          VARCHAR2(1000);
      v_sentencia_delete_risc VARCHAR2(1000);
      v_insert_risc           VARCHAR2(1000);
      v_insert_risc2          VARCHAR2(1000);
      v_insert_risc3          VARCHAR2(1000);
      v_insert_risc4          VARCHAR2(1000);
      v_insert_risc5          VARCHAR2(1000);
      v_insert_risc6          VARCHAR2(1000);
      v_sentencia_insert_risc VARCHAR2(1000);
      v_delete_pol            VARCHAR2(1000);
      v_delete_pol2           VARCHAR2(1000);
      v_sentencia_delete_pol  VARCHAR2(1000);
      v_insert_pol            VARCHAR2(1000);
      v_insert_pol2           VARCHAR2(1000);
      v_insert_pol3           VARCHAR2(1000);
      v_insert_pol4           VARCHAR2(1000);
      v_insert_pol5           VARCHAR2(1000);
      v_insert_pol6           VARCHAR2(1000);
      v_sentencia_insert_pol  VARCHAR2(1000);
      -- Bug 11735 - RSC - 19/01/2010 - APR - suplemento de modificación de capital /prima
      v_sproduc    seguros.sproduc%TYPE;
      v_sproces    NUMBER;
      v_update_aux VARCHAR2(200) := '';
      -- Fin Bug 11735
      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec NUMBER := 0;
      -- Fin Bug 23174

      -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones únicas
      v_sseguro seguros.sseguro%TYPE;

      -- Fin Bug 13832
      CURSOR garantias IS
         SELECT *
           FROM tmp_garancar
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND sproces = psproces;

      CURSOR preguntas_riesgo IS
         SELECT p.*
           FROM preguncar  p,
                pregunpro  pr,
                estseguros s,
                codipregun cp
          WHERE p.sseguro = psseguro
            AND p.nriesgo = pnriesgo
            AND p.sproces = psproces
            AND cp.cpregun = p.cpregun -- BUG14172:DRA:27/04/2010
            AND ((cp.ctippre IN (4, 5) AND p.trespue IS NOT NULL) OR
                p.crespue IS NOT NULL)
            AND pr.cpregun = p.cpregun
            AND s.sseguro = psseguro
            AND s.sproduc = pr.sproduc
            AND pr.cpretip = 2; -- (automáticas)
   BEGIN
      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 61;

      -- Fin Bug 23174

      -- Bug 11735 - RSC - 19/01/2010 - APR - suplemento de modificación de capital /prima
      IF ptablas = 'EST'
      THEN
         SELECT sproduc,
                ssegpol
           INTO v_sproduc,
                v_sseguro
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT sproduc,
                sseguro
           INTO v_sproduc,
                v_sseguro
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      -- Fin Bug 11735

      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 62;

      -- Fin Bug 23174
      -- traspasamo la información a las tablas EST
      FOR i IN garantias
      LOOP
         -- Bug 11735 - RSC - 19/01/2010 - APR - suplemento de modificación de capital /prima
         -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones únicas (añadimos EXTRA)
         IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN (1, 2) AND
            pmodali IN ('ALTA', 'MODIF', 'EXTRA')
         THEN
            v_update := 'update ' || ptablas || 'detgaranseg set ' ||
                        ' iprianu =' ||
                        TO_CHAR(NVL(i.iprianu, 0), '99999999999.99') ||
                        ', icapital =' ||
                        TO_CHAR(NVL(i.icapital, 0), '9999999999999.99') ||
                        ', ipritar = ' ||
                        TO_CHAR(NVL(i.ipritar, 0), '99999999999.99') ||
                        ', crevali = ' || NVL(TO_CHAR(i.crevali), 'null') ||
                        ', ctarifa = ' || NVL(TO_CHAR(i.ctarifa), 'null') ||
                        ', precarg = ' ||
                        TO_CHAR(NVL(i.precarg, 0), '9999.9999') ||
                        ', irecarg = '
                       -- BUG 17341 - 24/01/2011 - JMP - Informamos IRECARG
                        || TO_CHAR(NVL(i.irecarg, 0), '99999999999.99') ||
                        ', pdtocom = ' ||
                        TO_CHAR(NVL(i.pdtocom, 0), '9999.99') ||
                        ', idtocom = ' ||
                        TO_CHAR(NVL(i.idtocom, 0), '99999999999.99') ||
                        ', prevali = ' ||
                        TO_CHAR(NVL(i.prevali, 0), '999.99999') ||
                        ',irevali = ' ||
                        TO_CHAR(NVL(i.irevali, 0), '99999999999.99');
            v_where  := ' WHERE nriesgo =' || i.nriesgo || ' and cgarant =' ||
                        i.cgarant;
            -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
            vpasexec := 63;

            -- Fin Bug 23174
            IF ptablas = 'EST'
            THEN
               -- BUG 26245 - FAL - 13/05/2013
               BEGIN
                  SELECT sproduc
                    INTO v_sproduc
                    FROM estseguros
                   WHERE sseguro = psseguro;

                  UPDATE estdetgaranseg
                     SET iprianu  = f_round(NVL(i.iprianu, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         icapital = f_round(NVL(i.icapital, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         ipritar  = f_round(NVL(i.ipritar, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         crevali  = NVL(TO_CHAR(i.crevali), NULL),
                         ctarifa  = NVL(TO_CHAR(i.ctarifa), NULL),
                         precarg  = round(NVL(i.precarg, 0), 4),
                         irecarg  = f_round(NVL(i.irecarg, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         pdtocom  = round(NVL(i.pdtocom, 0), 2),
                         idtocom  = f_round(NVL(i.idtocom, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         prevali  = round(NVL(i.prevali, 0), 5),
                         irevali  = f_round(NVL(i.irevali, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc))
                   WHERE nriesgo = i.nriesgo
                     AND cgarant = i.cgarant
                     AND nmovimi = i.nmovi_ant
                     AND sseguro = psseguro
                     AND ndetgar = i.ndetgar;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate,
                                 f_user,
                                 'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas',
                                 1,
                                 'update garantias ptablas =' || ptablas ||
                                 ' sseguro =' || psseguro || ' nriesgo =' ||
                                 pnriesgo || ' cgarant =' || i.cgarant,
                                 'sentencia =' || v_update || v_update2 ||
                                 v_where || v_where2 || ' ' || SQLERRM);
                     RETURN 105577; --error al modificar las garantias
               END;

               -- FI BUG 26245 - FAL - 13/05/2013
               --v_update2 := ', icaptot = ' || TO_CHAR(NVL(i.icapital, 0), '9999999999.99')
               --             || ', ipritot = ' || TO_CHAR(NVL(i.iprianu, 0), '9999999999.99');
               v_where2 := ' and nmovimi =' || i.nmovi_ant ||
                           ' and sseguro = ' || psseguro ||
                           ' AND ndetgar = ' || i.ndetgar || ';';
            ELSE
               -- BUG 26245 - FAL - 13/05/2013
               BEGIN
                  SELECT sproduc
                    INTO v_sproduc
                    FROM seguros
                   WHERE sseguro = psseguro;

                  UPDATE detgaranseg
                     SET iprianu  = f_round(NVL(i.iprianu, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         icapital = f_round(NVL(i.icapital, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         ipritar  = f_round(NVL(i.ipritar, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         crevali  = NVL(TO_CHAR(i.crevali), NULL),
                         ctarifa  = NVL(TO_CHAR(i.ctarifa), NULL),
                         precarg  = round(NVL(i.precarg, 0), 4),
                         irecarg  = f_round(NVL(i.irecarg, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         pdtocom  = round(NVL(i.pdtocom, 0), 2),
                         idtocom  = f_round(NVL(i.idtocom, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         prevali  = round(NVL(i.prevali, 0), 5),
                         irevali  = f_round(NVL(i.irevali, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc))
                   WHERE nriesgo = i.nriesgo
                     AND cgarant = i.cgarant
                     AND nmovimi = i.nmovi_ant
                     AND sseguro = psseguro
                     AND ndetgar = i.ndetgar;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate,
                                 f_user,
                                 'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas',
                                 2,
                                 'update garantias ptablas =' || ptablas ||
                                 ' sseguro =' || psseguro || ' nriesgo =' ||
                                 pnriesgo || ' cgarant =' || i.cgarant,
                                 'sentencia =' || v_update || v_update2 ||
                                 v_where || v_where2 || ' ' || SQLERRM);
                     RETURN 105577; --error al modificar las garantias
               END;

               -- FI BUG 26245 - FAL - 13/05/2013
               --v_update2 := ', icaptot = ' || TO_CHAR(NVL(i.icapital, 0), '9999999999.99')
               --             || ', ipritot = ' || TO_CHAR(NVL(i.iprianu, 0), '9999999999.99');
               v_where2 := ' and nmovimi =' || i.nmovi_ant ||
                           ' and sseguro = ' || psseguro ||
                           ' AND ndetgar = ' || i.ndetgar || ';';
            END IF;
         ELSE
            -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
            vpasexec := 64;

            -- Fin Bug 23174
            -- Bug 11735 - RSC - 19/01/2010 - APR - suplemento de modificación de capital /prima
            IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) NOT IN
               (1, 2)
            THEN
               v_update_aux := ', ctarifa = ' ||
                               NVL(TO_CHAR(i.ctarifa), 'null');
            END IF;

            -- Fin Bug 11735
            v_update := 'update ' || ptablas || 'garanseg set ' ||
                        ' iprianu =' ||
                        TO_CHAR(NVL(i.iprianu, 0), '99999999999.99') ||
                        ', icapital =' ||
                        TO_CHAR(NVL(i.icapital, 0), '9999999999999.99') ||
                        ', ipritar = ' ||
                        TO_CHAR(NVL(i.ipritar, 0), '99999999999.99') ||
                        ', crevali = ' || NVL(TO_CHAR(i.crevali), 'null') ||
                        v_update_aux || ', precarg = ' ||
                        TO_CHAR(NVL(i.precarg, 0), '9999.99') ||
                        ', iextrap = ' ||
                        NVL(TO_CHAR(i.iextrap, '9999999.999999999999'),
                            'null') || ', cformul = ' ||
                        NVL(TO_CHAR(i.cformul), 'null') || ', ctipfra = ' ||
                        NVL(TO_CHAR(i.ctipfra), 'null') || ', ifranqu = ' ||
                        TO_CHAR(NVL(i.ifranqu, 0), '99999999999.99') ||
                        ', irecarg = ' ||
                        TO_CHAR(NVL(i.irecarg, 0), '99999999999.99') ||
                        ', pdtocom = ' ||
                        TO_CHAR(NVL(i.pdtocom, 0), '9999.99') ||
                        ', idtocom = ' ||
                        TO_CHAR(NVL(i.idtocom, 0), '99999999999.99') ||
                        ', prevali = ' ||
                        TO_CHAR(NVL(i.prevali, 0), '999.99999') ||
                        ',irevali = ' ||
                        TO_CHAR(NVL(i.irevali, 0), '99999999999.99')
                       -- BUG11737:DRA:26/01/2010
                        || ', itarifa = ' ||
                        TO_CHAR(NVL(i.itarifa, 0), '999999.999999999999');
            -- Bug 21907 - MDS - 24/04/2012
            -- añadir PDTOTEC, PRECCOM, IDTOTEC, IRECCOM de la tabla SOLGARANSEG, ESTGARANSEG, GARANSEG
            v_update := v_update || ', PDTOTEC = ' ||
                        TO_CHAR(NVL(i.pdtotec, 0), '9999.99') ||
                        ', PRECCOM = ' ||
                        TO_CHAR(NVL(i.preccom, 0), '9999.99') ||
                        ', IDTOTEC = ' ||
                        TO_CHAR(NVL(i.idtotec, 0), '99999999999.99') ||
                        ', IRECCOM = ' ||
                        TO_CHAR(NVL(i.ireccom, 0), '99999999999.99');
            v_where  := ' WHERE nriesgo =' || i.nriesgo || ' and cgarant =' ||
                        i.cgarant;
            -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
            vpasexec := 65;

            -- Fin Bug 23174
            IF ptablas = 'SOL'
            THEN
               -- BUG 26245 - FAL - 13/05/2013
               SELECT sproduc
                 INTO v_sproduc
                 FROM solseguros
                WHERE ssolicit = psseguro;

               BEGIN
                  UPDATE solgaranseg
                     SET iprianu  = f_round(NVL(i.iprianu, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         icapital = f_round(NVL(i.icapital, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         ipritar  = f_round(NVL(i.ipritar, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         crevali  = NVL(TO_CHAR(i.crevali), NULL),
                         precarg  = round(NVL(i.precarg, 0), 4),
                         iextrap  = NVL(round(i.iextrap, 12), NULL),
                         cformul  = NVL(TO_CHAR(i.cformul), NULL),
                         ctipfra  = NVL(TO_CHAR(i.ctipfra), NULL),
                         ifranqu  = f_round(NVL(i.ifranqu, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         irecarg  = f_round(NVL(i.irecarg, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         pdtocom  = round(NVL(i.pdtocom, 0), 2),
                         idtocom  = f_round(NVL(i.idtocom, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         prevali  = round(NVL(i.prevali, 0), 4),
                         irevali  = f_round(NVL(i.irevali, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         itarifa  = round(NVL(i.itarifa, 0), 12),
                         pdtotec  = round(NVL(i.pdtotec, 0), 2),
                         preccom  = round(NVL(i.preccom, 0), 2),
                         idtotec  = f_round(NVL(i.idtotec, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         ireccom  = f_round(NVL(i.ireccom, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc))
                   WHERE nriesgo = i.nriesgo
                     AND cgarant = i.cgarant
                     AND ssolicit = psseguro
                     AND cobliga = 1;

                  IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) NOT IN
                     (1, 2)
                  THEN
                     UPDATE solgaranseg
                        SET ctarifa = NVL(TO_CHAR(i.ctarifa), 'null')
                      WHERE nriesgo = i.nriesgo
                        AND cgarant = i.cgarant
                        AND ssolicit = psseguro
                        AND cobliga = 1;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate,
                                 f_user,
                                 'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas',
                                 3,
                                 'update garantias ptablas =' || ptablas ||
                                 ' sseguro =' || psseguro || ' nriesgo =' ||
                                 pnriesgo || ' cgarant =' || i.cgarant,
                                 'sentencia =' || v_update || v_update2 ||
                                 v_where || v_where2 || ' ' || SQLERRM);
                     RETURN 105577; --error al modificar las garantias
               END;

               -- FI BUG 26245 - FAL - 13/05/2013
               v_update2 := NULL;
               v_where2  := ' and ssolicit = ' || psseguro ||
                            ' and cobliga = 1;';
            ELSIF ptablas = 'EST'
            THEN
               v_update2 := ', icaptot = ' ||
                            TO_CHAR(NVL(i.icapital, 0),
                                    '999999999999999.99') || ', ipritot = ' ||
                            TO_CHAR(NVL(i.iprianu, 0), '9999999999999.99');
               v_where2  := ' and nmovimi =' || i.nmovi_ant ||
                            ' and sseguro = ' || psseguro ||
                            ' and cobliga = 1;';

               -- BUG 26245 - FAL - 13/05/2013
               BEGIN
                  SELECT sproduc
                    INTO v_sproduc
                    FROM estseguros
                   WHERE sseguro = psseguro;

                  UPDATE estgaranseg
                     SET iprianu  = f_round(NVL(i.iprianu, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         icapital = f_round(NVL(i.icapital, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         ipritar  = f_round(NVL(i.ipritar, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         crevali  = NVL(TO_CHAR(i.crevali), NULL),
                         precarg  = round(NVL(i.precarg, 0), 4),
                         iextrap  = NVL(round(i.iextrap, 12), NULL),
                         cformul  = NVL(TO_CHAR(i.cformul), NULL),
                         ctipfra  = NVL(TO_CHAR(i.ctipfra), NULL),
                         ifranqu  = f_round(NVL(i.ifranqu, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         irecarg  = f_round(NVL(i.irecarg, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         pdtocom  = round(NVL(i.pdtocom, 0), 2),
                         idtocom  = f_round(NVL(i.idtocom, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         prevali  = round(NVL(i.prevali, 0), 4),
                         irevali  = f_round(NVL(i.irevali, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         itarifa  = round(NVL(i.itarifa, 0), 12),
                         pdtotec  = round(NVL(i.pdtotec, 0), 2),
                         preccom  = round(NVL(i.preccom, 0), 2),
                         idtotec  = f_round(NVL(i.idtotec, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         ireccom  = f_round(NVL(i.ireccom, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         icaptot  = f_round(NVL(i.icapital, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         ipritot  = f_round(NVL(i.iprianu, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         nfactor  = i.nfactor
                  -- Bug 30171/173304 - 24/04/2014 - AMC
                   WHERE nriesgo = i.nriesgo
                     AND cgarant = i.cgarant
                     AND sseguro = psseguro
                     AND cobliga = 1
                     AND nmovimi = i.nmovi_ant;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate,
                                 f_user,
                                 'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas',
                                 4,
                                 'update garantias ptablas =' || ptablas ||
                                 ' sseguro =' || psseguro || ' nriesgo =' ||
                                 pnriesgo || ' cgarant =' || i.cgarant,
                                 'sentencia =' || v_update || v_update2 ||
                                 v_where || v_where2 || ' ' || SQLERRM);
                     RETURN 105577; --error al modificar las garantias
               END;
               -- FI BUG 26245 - FAL - 13/05/2013
            ELSE
               v_update2 := ', icaptot = ' ||
                            TO_CHAR(NVL(i.icapital, 0),
                                    '999999999999999.99') || ', ipritot = ' ||
                            TO_CHAR(NVL(i.iprianu, 0), '9999999999999.99');
               v_where2  := ' and nmovimi =' || i.nmovi_ant ||
                            ' and sseguro = ' || psseguro || ';';

               -- BUG 26245 - FAL - 13/05/2013
               BEGIN
                  SELECT sproduc
                    INTO v_sproduc
                    FROM seguros
                   WHERE sseguro = psseguro;

                  UPDATE garanseg
                     SET iprianu  = f_round(NVL(i.iprianu, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         icapital = f_round(NVL(i.icapital, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         ipritar  = f_round(NVL(i.ipritar, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         crevali  = NVL(TO_CHAR(i.crevali), NULL),
                         precarg  = round(NVL(i.precarg, 0), 4),
                         iextrap  = NVL(round(i.iextrap, 12), NULL),
                         cformul  = NVL(TO_CHAR(i.cformul), NULL),
                         ctipfra  = NVL(TO_CHAR(i.ctipfra), NULL),
                         ifranqu  = f_round(NVL(i.ifranqu, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         irecarg  = f_round(NVL(i.irecarg, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         pdtocom  = round(NVL(i.pdtocom, 0), 2),
                         idtocom  = f_round(NVL(i.idtocom, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         prevali  = round(NVL(i.prevali, 0), 4),
                         irevali  = f_round(NVL(i.irevali, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         itarifa  = round(NVL(i.itarifa, 0), 12),
                         pdtotec  = round(NVL(i.pdtotec, 0), 2),
                         preccom  = round(NVL(i.preccom, 0), 2),
                         idtotec  = f_round(NVL(i.idtotec, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         ireccom  = f_round(NVL(i.ireccom, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         icaptot  = f_round(NVL(i.icapital, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc)),
                         ipritot  = f_round(NVL(i.iprianu, 0),
                                            pac_monedas.f_moneda_producto(v_sproduc))
                   WHERE nriesgo = i.nriesgo
                     AND cgarant = i.cgarant
                     AND sseguro = psseguro
                     AND nmovimi = i.nmovi_ant;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate,
                                 f_user,
                                 'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas',
                                 5,
                                 'update garantias ptablas =' || ptablas ||
                                 ' sseguro =' || psseguro || ' nriesgo =' ||
                                 pnriesgo || ' cgarant =' || i.cgarant,
                                 'sentencia =' || v_update || v_update2 ||
                                 v_where || v_where2 || ' ' || SQLERRM);
                     RETURN 105577; --error al modificar las garantias
               END;
               -- FI BUG 26245 - FAL - 13/05/2013
            END IF;
         END IF;
         -- BUG 26245 - FAL - 13/05/2013
      /*
               v_sentencia_update := ' begin ' || v_update || v_update2 || v_where || v_where2
                                     || ' end;';

               BEGIN
                  EXECUTE IMMEDIATE v_sentencia_update;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas', 1,
                                 'update garantias ptablas =' || ptablas || ' sseguro =' || psseguro
                                 || ' nriesgo =' || pnriesgo || ' cgarant =' || i.cgarant,
                                 'sentencia =' || v_sentencia_update || ' ' || SQLERRM);
                     RETURN 105577;   --error al modificar las garantias
               END;
            */
      -- FI BUG 26245 - FAL - 13/05/2013
      END LOOP;

      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 66;
      -- Fin Bug 23174
      -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones únicas (añadimos EXTRA)
      p_ajustes_detgaranseg(ptablas, psseguro, pnriesgo, pmodali);
      -- Fin Bug 13832

      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 67;

      -- Fin Bug 23174
      -- TRASPASAMOS las preguntas por garantia
      -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones únicas (añadimos EXTRA)
      IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN (1, 2) AND
         pmodali IN ('ALTA', 'MODIF', 'EXTRA')
      THEN
         FOR i IN garantias
         LOOP
            -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
            vpasexec := 68;

            -- Fin Bug 23174
            -- I - JLB - OPTIMIZACIÓN
            --  v_delete := 'DELETE from ' || ptablas || 'pregungaranseg ' || 'where nriesgo = '
            --             || pnriesgo || ' and cpregun in (select cpregun '
            --              || 'from pregunprogaran pg,' || ptablas || 'seguros s'
            --              || ' where pg.sproduc = s.sproduc' || ' and pg.cpretip =2 ';
            BEGIN
               -- F - JLB - OPTIMIZACIÓN
               IF ptablas = 'SOL'
               THEN
                  DELETE FROM solpregungaranseg
                   WHERE nriesgo = pnriesgo
                     AND cpregun IN
                         (SELECT cpregun
                            FROM pregunprogaran pg,
                                 solseguros     s
                           WHERE pg.sproduc = s.sproduc
                             AND pg.cpretip = 2
                             AND s.ssolicit = psseguro)
                     AND ssolicit = psseguro;
               ELSIF ptablas = 'EST'
               THEN
                  DELETE FROM estpregungaranseg
                   WHERE nriesgo = pnriesgo
                     AND cpregun IN
                         (SELECT cpregun
                            FROM pregunprogaran pg,
                                 estseguros     s
                           WHERE pg.sproduc = s.sproduc
                             AND pg.cpretip = 2
                             AND s.sseguro = psseguro)
                     AND sseguro = psseguro
                     AND nmovimi = pnmovimi
                     AND cgarant = i.cgarant;
               ELSE
                  --v_delete2 := 'and s.sseguro =' || psseguro || ')' || 'and sseguro = '
                  --             || psseguro || ' and nmovimi =' || pnmovimi || ' and cgarant = '
                  --             || i.cgarant || ';';
                  DELETE FROM pregungaranseg
                   WHERE nriesgo = pnriesgo
                     AND cpregun IN
                         (SELECT cpregun
                            FROM pregunprogaran pg,
                                 seguros        s
                           WHERE pg.sproduc = s.sproduc
                             AND pg.cpretip = 2
                             AND s.sseguro = psseguro)
                     AND sseguro = psseguro
                     AND nmovimi = pnmovimi
                     AND cgarant = i.cgarant;
               END IF;
               -- I - JLB - OPTIMIZACIÓN
               -- v_sentencia_delete := ' begin ' || v_delete || v_delete2 || ' end;';
               -- I - JLB - OPTIMIZACIÓN
               --         BEGIN
               -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
               --          vpasexec := 69;
               -- I - JLB - OPTIMIZACIÓN
               -- Fin Bug 23174
               --          EXECUTE IMMEDIATE v_sentencia_delete;
               -- F - JLB - OPTIMIZACIÓN
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate,
                              f_user,
                              'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas',
                              2,
                              'delete preguntas garantia ptablas =' ||
                              ptablas || ' sseguro =' || psseguro ||
                              ' nriesgo =' || pnriesgo,
                              ' sentencia =' || v_sentencia_delete ||
                              SQLERRM);
                  RETURN 105577; --error al modificar las garantias
            END;

            -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
            vpasexec := 610;
            -- Fin Bug 23174
            v_insert := 'INSERT into ' || ptablas || 'pregungaranseg' ||
                        ' (nriesgo, cgarant, cpregun, crespue, trespue, ';

            IF ptablas = 'SOL'
            THEN
               v_insert2 := ' ssolicit) ';
               v_insert4 := NULL;
               v_insert6 := 'and s.ssolicit =' || psseguro || ');';
            ELSE
               v_insert2 := 'sseguro, nmovima, finiefe,nmovimi) ';
               v_insert4 := ', pp.nmovima, pp.finiefe, pp.nmovimi ';
               v_insert6 := 'and s.sseguro =' || psseguro || ');';
            END IF;

            v_insert3          := 'select pp.nriesgo, pp.cgarant, pp.cpregun, pp.crespue, pp.trespue, pp.sseguro ';
            v_insert5          := 'from pregungarancar pp, codipregun cp where pp.sproces =' ||
                                  psproces || ' and pp.sseguro = ' ||
                                  psseguro || ' and pp.cgarant = ' ||
                                  i.cgarant ||
                                  ' AND cp.cpregun = pp.cpregun' -- BUG14172:DRA:27/04/2010
                                  ||
                                  ' AND((cp.ctippre IN(4, 5) AND pp.trespue IS NOT NULL) OR pp.crespue IS NOT NULL)' ||
                                  ' and pp.nriesgo = ' || pnriesgo ||
                                  ' and pp.cpregun in (select pg.cpregun ' ||
                                  'from pregunprogaran pg,' || ptablas ||
                                  'seguros s' ||
                                  ' where pg.sproduc = s.sproduc and pg.cpretip =2 ';
            v_sentencia_insert := 'begin ' || v_insert || v_insert2 ||
                                  v_insert3 || v_insert4 || v_insert5 ||
                                  v_insert6 || ' end;';
            -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
            vpasexec := 611;

            -- Fin Bug 23174
            BEGIN
               EXECUTE IMMEDIATE v_sentencia_insert;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate,
                              f_user,
                              'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas',
                              3,
                              'insert preguntas garantia ptablas =' ||
                              ptablas || ' sseguro =' || psseguro ||
                              ' nriesgo =' || pnriesgo,
                              'sentencia =' || v_sentencia_insert ||
                              SQLERRM);
                  RETURN 105577; --error al modificar las garantias
            END;
         END LOOP;
      ELSE
         -- Fin Bug 13832
         v_delete := 'DELETE from ' || ptablas || 'pregungaranseg ' ||
                     'where nriesgo = ' || pnriesgo ||
                     ' and cpregun in (select cpregun ' ||
                     'from pregunprogaran pg,' || ptablas || 'seguros s' ||
                     ' where pg.sproduc = s.sproduc' ||
                     ' and pg.cpretip =2 ';
         -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
         vpasexec := 612;

         -- Fin Bug 23174
         IF ptablas = 'SOL'
         THEN
            v_delete2 := 'and s.ssolicit =' || psseguro || ')' ||
                         'and ssolicit = ' || psseguro || ';';
         ELSE
            v_delete2 := 'and s.sseguro =' || psseguro || ')' ||
                         'and sseguro = ' || psseguro || ' and nmovimi =' ||
                         pnmovimi || ';';
         END IF;

         v_sentencia_delete := ' begin ' || v_delete || v_delete2 ||
                               ' end;';
         -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
         vpasexec := 613;

         -- Fin Bug 23174
         BEGIN
            EXECUTE IMMEDIATE v_sentencia_delete;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate,
                           f_user,
                           'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas',
                           2,
                           'delete preguntas garantia ptablas =' || ptablas ||
                           ' sseguro =' || psseguro || ' nriesgo =' ||
                           pnriesgo,
                           ' sentencia =' || v_sentencia_delete || SQLERRM);
               RETURN 105577; --error al modificar las garantias
         END;

         v_insert := 'INSERT into ' || ptablas || 'pregungaranseg' ||
                     ' (nriesgo, cgarant, cpregun, crespue, trespue, ';
         -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
         vpasexec := 614;

         -- Fin Bug 23174
         IF ptablas = 'SOL'
         THEN
            v_insert2 := ' ssolicit) ';
            v_insert4 := NULL;
            v_insert6 := 'and s.ssolicit =' || psseguro || ');';
         ELSE
            v_insert2 := 'sseguro, nmovima, finiefe,nmovimi) ';
            v_insert4 := ', pp.nmovima, pp.finiefe, pp.nmovimi ';
            v_insert6 := 'and s.sseguro =' || psseguro || ');';
         END IF;

         v_insert3          := 'select pp.nriesgo, pp.cgarant, pp.cpregun, pp.crespue, pp.trespue, pp.sseguro ';
         v_insert5          := 'from pregungarancar pp, codipregun cp where pp.sproces =' ||
                               psproces || ' and pp.sseguro = ' || psseguro ||
                               ' AND cp.cpregun = pp.cpregun' -- BUG14172:DRA:27/04/2010
                               ||
                               ' AND((cp.ctippre IN(4, 5) AND pp.trespue IS NOT NULL) OR pp.crespue IS NOT NULL)' ||
                               ' and pp.nriesgo = ' || pnriesgo ||
                               ' and pp.cpregun in (select pg.cpregun ' ||
                               'from pregunprogaran pg,' || ptablas ||
                               'seguros s' ||
                               ' where pg.sproduc = s.sproduc and pg.cpretip =2 ';
         v_sentencia_insert := 'begin ' || v_insert || v_insert2 ||
                               v_insert3 || v_insert4 || v_insert5 ||
                               v_insert6 || ' end;';
         -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
         vpasexec := 615;

         -- Fin Bug 23174
         BEGIN
            EXECUTE IMMEDIATE v_sentencia_insert;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate,
                           f_user,
                           'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas',
                           3,
                           'insert preguntas garantia ptablas =' || ptablas ||
                           ' sseguro =' || psseguro || ' nriesgo =' ||
                           pnriesgo,
                           'sentencia =' || v_sentencia_insert || SQLERRM);
               RETURN 105577; --error al modificar las garantias
         END;
      END IF;

      -- TRASPASAMOS las preguntastab por garantia
      -- Bug 13832 - RSC - 10/06/2010 - APRS015 - suplemento de aportaciones únicas (añadimos EXTRA)
      IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN (1, 2) AND
         pmodali IN ('ALTA', 'MODIF', 'EXTRA')
      THEN
         FOR i IN garantias
         LOOP
            -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
            vpasexec := 616;
            -- Fin Bug 23174
            v_delete := 'DELETE from ' || ptablas || 'pregungaransegtab ' ||
                        'where nriesgo = ' || pnriesgo ||
                        ' and cpregun in (select cpregun ' ||
                        'from pregunprogaran pg,' || ptablas || 'seguros s' ||
                        ' where pg.sproduc = s.sproduc' ||
                        ' and pg.cpretip =2 ';

            IF ptablas = 'SOL'
            THEN
               v_delete2 := 'and s.ssolicit =' || psseguro || ')' ||
                            'and ssolicit = ' || psseguro || ';';
            ELSE
               v_delete2 := 'and s.sseguro =' || psseguro || ')' ||
                            'and sseguro = ' || psseguro ||
                            ' and nmovimi =' || pnmovimi ||
                            ' and cgarant = ' || i.cgarant || ';';
            END IF;

            v_sentencia_delete := ' begin ' || v_delete || v_delete2 ||
                                  ' end;';
            -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
            vpasexec := 617;

            -- Fin Bug 23174
            BEGIN
               EXECUTE IMMEDIATE v_sentencia_delete;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate,
                              f_user,
                              'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas tab',
                              2,
                              'delete preguntas garantia ptablas =' ||
                              ptablas || ' sseguro =' || psseguro ||
                              ' nriesgo =' || pnriesgo,
                              ' sentencia =' || v_sentencia_delete ||
                              SQLERRM);
                  RETURN 105577; --error al modificar las garantias
            END;

            v_insert := 'INSERT into ' || ptablas || 'pregungaransegtab' ||
                        ' (nriesgo, cgarant, cpregun, nlinea, ccolumna, tvalor, fvalor, nvalor, ';
            -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
            vpasexec := 618;

            -- Fin Bug 23174
            IF ptablas = 'SOL'
            THEN
               v_insert2 := ' ssolicit) ';
               v_insert4 := NULL;
               v_insert6 := 'and s.ssolicit =' || psseguro || ');';
            ELSE
               v_insert2 := 'sseguro, nmovima, finiefe,nmovimi) ';
               v_insert4 := ', pp.nmovima, pp.finiefe, pp.nmovimi ';
               v_insert6 := 'and s.sseguro =' || psseguro || ');';
            END IF;

            v_insert3          := 'select pp.nriesgo, pp.cgarant, pp.cpregun, pp.nlinea, pp.ccolumna, pp.tvalor, pp.fvalor, pp.nvalor, pp.sseguro ';
            v_insert5          := 'from pregungarancartab pp, codipregun cp where pp.sproces =' ||
                                  psproces || ' and pp.sseguro = ' ||
                                  psseguro || ' and pp.cgarant = ' ||
                                  i.cgarant ||
                                  ' AND cp.cpregun = pp.cpregun' -- BUG14172:DRA:27/04/2010
                                  ||
                                  ' AND(cp.ctippre IN(7) AND (pp.tvalor IS NOT NULL OR pp.nvalor IS NOT NULL OR pp.fvalor IS NOT NULL))' ||
                                  ' and pp.nriesgo = ' || pnriesgo ||
                                  ' and pp.cpregun in (select pg.cpregun ' ||
                                  'from pregunprogaran pg,' || ptablas ||
                                  'seguros s' ||
                                  ' where pg.sproduc = s.sproduc and pg.cpretip =2 ';
            v_sentencia_insert := 'begin ' || v_insert || v_insert2 ||
                                  v_insert3 || v_insert4 || v_insert5 ||
                                  v_insert6 || ' end;';
            -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
            vpasexec := 619;

            -- Fin Bug 23174
            BEGIN
               EXECUTE IMMEDIATE v_sentencia_insert;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate,
                              f_user,
                              'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas',
                              3,
                              'insert preguntas garantia ptablas =' ||
                              ptablas || ' sseguro =' || psseguro ||
                              ' nriesgo =' || pnriesgo,
                              'sentencia =' || v_sentencia_insert ||
                              SQLERRM);
                  RETURN 105577; --error al modificar las garantias
            END;
         END LOOP;
      ELSE
         -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
         vpasexec := 6101;
         -- Fin Bug 23174
         -- Fin Bug 13832
         v_delete := 'DELETE from ' || ptablas || 'pregungaransegtab ' ||
                     'where nriesgo = ' || pnriesgo ||
                     ' and cpregun in (select cpregun ' ||
                     'from pregunprogaran pg,' || ptablas || 'seguros s' ||
                     ' where pg.sproduc = s.sproduc' ||
                     ' and pg.cpretip =2 ';

         IF ptablas = 'SOL'
         THEN
            v_delete2 := 'and s.ssolicit =' || psseguro || ')' ||
                         'and ssolicit = ' || psseguro || ';';
         ELSE
            v_delete2 := 'and s.sseguro =' || psseguro || ')' ||
                         'and sseguro = ' || psseguro || ' and nmovimi =' ||
                         pnmovimi || ';';
         END IF;

         -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
         vpasexec := 6102;
         -- Fin Bug 23174
         v_sentencia_delete := ' begin ' || v_delete || v_delete2 ||
                               ' end;';

         BEGIN
            EXECUTE IMMEDIATE v_sentencia_delete;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate,
                           f_user,
                           'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas tab',
                           2,
                           'delete preguntas garantia ptablas =' || ptablas ||
                           ' sseguro =' || psseguro || ' nriesgo =' ||
                           pnriesgo,
                           ' sentencia =' || v_sentencia_delete || SQLERRM);
               RETURN 105577; --error al modificar las garantias
         END;

         v_insert := 'INSERT into ' || ptablas || 'pregungaransegtab' ||
                     ' (nriesgo, cgarant, cpregun, nlinea, ccolumna, tvalor, fvalor, nvalor, ';
         -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
         vpasexec := 6103;

         -- Fin Bug 23174
         IF ptablas = 'SOL'
         THEN
            v_insert2 := ' ssolicit) ';
            v_insert4 := NULL;
            v_insert6 := 'and s.ssolicit =' || psseguro || ');';
         ELSE
            v_insert2 := 'sseguro, nmovima, finiefe,nmovimi) ';
            v_insert4 := ', pp.nmovima, pp.finiefe, pp.nmovimi ';
            v_insert6 := 'and s.sseguro =' || psseguro || ');';
         END IF;

         v_insert3          := 'select pp.nriesgo, pp.cgarant, pp.cpregun, pp.nlinea, pp.ccolumna, pp.tvalor, pp.fvalor, pp.nvalor, pp.sseguro ';
         v_insert5          := 'from pregungarancartab pp, codipregun cp where pp.sproces =' ||
                               psproces || ' and pp.sseguro = ' || psseguro ||
                               ' AND cp.cpregun = pp.cpregun' -- BUG14172:DRA:27/04/2010
                               ||
                               ' AND(cp.ctippre IN(7) AND (pp.tvalor IS NOT NULL OR pp.nvalor IS NOT NULL OR pp.fvalor IS NOT NULL))' ||
                               ' and pp.nriesgo = ' || pnriesgo ||
                               ' and pp.cpregun in (select pg.cpregun ' ||
                               'from pregunprogaran pg,' || ptablas ||
                               'seguros s' ||
                               ' where pg.sproduc = s.sproduc and pg.cpretip =2 ';
         v_sentencia_insert := 'begin ' || v_insert || v_insert2 ||
                               v_insert3 || v_insert4 || v_insert5 ||
                               v_insert6 || ' end;';
         -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
         vpasexec := 6104;

         -- Fin Bug 23174
         BEGIN
            EXECUTE IMMEDIATE v_sentencia_insert;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate,
                           f_user,
                           'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas tab',
                           3,
                           'insert preguntas garantia ptablas =' || ptablas ||
                           ' sseguro =' || psseguro || ' nriesgo =' ||
                           pnriesgo,
                           'sentencia =' || v_sentencia_insert || SQLERRM);
               RETURN 105577; --error al modificar las garantias
         END;
      END IF;

      -- Traspasamos preguntas de riesgo
      v_delete_risc := 'DELETE from ' || ptablas || 'pregunseg ' ||
                       'where nriesgo = ' || pnriesgo ||
                       ' and cpregun in (select cpregun ' ||
                       'from pregunpro pg,' || ptablas || 'seguros s' ||
                       ' where pg.sproduc = s.sproduc' ||
                       ' and pg.cpretip =2 ';
      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 6105;

      -- Fin Bug 23174
      IF ptablas = 'SOL'
      THEN
         v_delete_risc2 := 'and s.ssolicit =' || psseguro || ')' ||
                           'and ssolicit = ' || psseguro || ';';
      ELSE
         v_delete_risc2 := 'and s.sseguro =' || psseguro || ')' ||
                           'and sseguro = ' || psseguro || ' and nmovimi =' ||
                           pnmovimi || ';';
      END IF;

      v_sentencia_delete_risc := 'begin ' || v_delete_risc ||
                                 v_delete_risc2 || ' end;';
      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 6106;

      -- Fin Bug 23174
      BEGIN
         EXECUTE IMMEDIATE v_sentencia_delete_risc;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas',
                        4,
                        'delete preguntas riesgo ptablas =' || ptablas ||
                        ' sseguro =' || psseguro || ' nriesgo =' ||
                        pnriesgo,
                        ' sentencia =' || v_sentencia_delete_risc ||
                        SQLERRM);
            RETURN 105577; --error al modificar las garantias
      END;

      v_insert_risc := 'INSERT into ' || ptablas || 'pregunseg' ||
                       ' (nriesgo, nmovimi, cpregun, crespue,trespue, ';
      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 6107;

      -- Fin Bug 23174
      IF ptablas = 'SOL'
      THEN
         v_insert_risc2 := ' ssolicit) ';
         -- v_insert_risc4 := 'ssolicit ';
         v_insert_risc6 := 'and s.ssolicit =' || psseguro || ');';
      ELSE
         v_insert_risc2 := ' sseguro) ';
         -- v_insert_risc4 := ' sseguro ';
         v_insert_risc6 := 'and s.sseguro =' || psseguro || ');';
      END IF;

      v_insert_risc3          := 'select pp.nriesgo, pp.nmovimi, pp.cpregun, pp.crespue, pp.trespue, pp.sseguro ';
      v_insert_risc5          := 'from preguncar pp, codipregun cp where pp.sproces =' ||
                                 psproces || ' and pp.sseguro = ' ||
                                 psseguro || ' AND cp.cpregun = pp.cpregun' -- BUG14172:DRA:27/04/2010
                                 ||
                                 ' AND((cp.ctippre IN(4, 5) AND pp.trespue IS NOT NULL) OR pp.crespue IS NOT NULL)' ||
                                 ' and pp.nriesgo = ' || pnriesgo ||
                                 ' and pp.cpregun in (select cpregun ' ||
                                 ' from pregunpro pg,' || ptablas ||
                                 'seguros s' ||
                                 ' where pg.sproduc = s.sproduc' ||
                                 ' and pg.cpretip =2 ';
      v_sentencia_insert_risc := 'begin ' || v_insert_risc ||
                                 v_insert_risc2 || v_insert_risc3 ||
                                 v_insert_risc4 || v_insert_risc5 ||
                                 v_insert_risc6 || ' end;';
      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 6108;

      -- Fin Bug 23174
      BEGIN
         EXECUTE IMMEDIATE v_sentencia_insert_risc;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas',
                        5,
                        'insert preguntas riesgo ptablas =' || ptablas ||
                        ' sseguro =' || psseguro || ' nriesgo =' ||
                        pnriesgo,
                        'sentencia =' || v_sentencia_insert_risc || SQLERRM);
            RETURN 105577; --error al modificar las garantias
      END;

      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 6109;
      -- Fin Bug 23174

      -- Traspasamos preguntastab de riesgo
      v_delete_risc := 'DELETE from ' || ptablas || 'pregunsegtab ' ||
                       'where nriesgo = ' || pnriesgo ||
                       ' and cpregun in (select cpregun ' ||
                       'from pregunpro pg,' || ptablas || 'seguros s' ||
                       ' where pg.sproduc = s.sproduc' ||
                       ' and pg.cpretip =2 ';

      IF ptablas = 'SOL'
      THEN
         --si es SOL en las preguntas TAB petaría por que no existe solpregunsegtab
         v_delete_risc2 := 'and s.ssolicit =' || psseguro || ')' ||
                           'and ssolicit = ' || psseguro || ';';
      ELSE
         v_delete_risc2 := 'and s.sseguro =' || psseguro || ')' ||
                           'and sseguro = ' || psseguro || ' and nmovimi =' ||
                           pnmovimi || ';';
      END IF;

      v_sentencia_delete_risc := 'begin ' || v_delete_risc ||
                                 v_delete_risc2 || ' end;';
      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 6110;

      -- Fin Bug 23174
      BEGIN
         EXECUTE IMMEDIATE v_sentencia_delete_risc;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas',
                        4,
                        'delete preguntastab riesgo ptablas =' || ptablas ||
                        ' sseguro =' || psseguro || ' nriesgo =' ||
                        pnriesgo,
                        ' sentencia =' || v_sentencia_delete_risc ||
                        SQLERRM);
            RETURN 105577; --error al modificar las garantias
      END;

      v_insert_risc := 'INSERT into ' || ptablas || 'pregunsegtab' ||
                       ' (nriesgo, nmovimi, cpregun, nlinea, ccolumna, tvalor, fvalor, nvalor, ';
      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 6111;

      -- Fin Bug 23174
      IF ptablas = 'SOL'
      THEN
         v_insert_risc2 := ' ssolicit) ';
         -- v_insert_risc4 := 'ssolicit ';
         v_insert_risc6 := 'and s.ssolicit =' || psseguro || ');';
      ELSE
         v_insert_risc2 := ' sseguro) ';
         -- v_insert_risc4 := ' sseguro ';
         v_insert_risc6 := 'and s.sseguro =' || psseguro || ');';
      END IF;

      v_insert_risc3          := 'select pp.nriesgo, pp.nmovimi, pp.cpregun, pp.nlinea, pp.ccolumna, pp.tvalor, pp.fvalor, pp.nvalor, pp.sseguro ';
      v_insert_risc5          := 'from preguncartab pp, codipregun cp where pp.sproces =' ||
                                 psproces || ' and pp.sseguro = ' ||
                                 psseguro || ' AND cp.cpregun = pp.cpregun' -- BUG14172:DRA:27/04/2010
                                 || ' and pp.nriesgo = ' || pnriesgo ||
                                 ' and pp.cpregun in (select cpregun ' ||
                                 ' from pregunpro pg,' || ptablas ||
                                 'seguros s' ||
                                 ' where pg.sproduc = s.sproduc' ||
                                 ' and pg.cpretip =2 ';
      v_sentencia_insert_risc := 'begin ' || v_insert_risc ||
                                 v_insert_risc2 || v_insert_risc3 ||
                                 v_insert_risc4 || v_insert_risc5 ||
                                 v_insert_risc6 || ' end;';
      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 6112;

      -- Fin Bug 23174
      BEGIN
         EXECUTE IMMEDIATE v_sentencia_insert_risc;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas',
                        5,
                        'insert preguntastab riesgo ptablas =' || ptablas ||
                        ' sseguro =' || psseguro || ' nriesgo =' ||
                        pnriesgo,
                        'sentencia =' || v_sentencia_insert_risc || SQLERRM);
            RETURN 105577; --error al modificar las garantias
      END;

      ---------------------------------------------------------------------------------------------------------------------
      ---------------------------------------------------------------------------------------------------------------------
      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 6113;
      -- Fin Bug 23174
      -- Traspasamos preguntas de poliza
      v_delete_pol := 'DELETE from ' || ptablas || 'pregunpolseg p ' ||
                      'WHERE p.cpregun IN (SELECT pg.cpregun FROM pregunpro pg,' ||
                      ptablas || 'seguros s WHERE pg.sproduc = s.sproduc' ||
                      ' AND pg.cpretip=2 AND pg.cnivel IN (''R'', ''P'') ';

      IF ptablas = 'SOL'
      THEN
         v_delete_pol2 := 'AND s.ssolicit =' || psseguro ||
                          ') AND p.ssolicit = ' || psseguro || ';';
      ELSE
         v_delete_pol2 := 'AND s.sseguro =' || psseguro ||
                          ') AND p.sseguro = ' || psseguro ||
                          ' AND p.nmovimi =' || pnmovimi || ';';
      END IF;

      v_sentencia_delete_pol := 'begin ' || v_delete_pol || v_delete_pol2 ||
                                ' end;';
      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 6114;

      -- Fin Bug 23174
      BEGIN
         EXECUTE IMMEDIATE v_sentencia_delete_pol;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas',
                        4,
                        'delete preguntas poliza ptablas =' || ptablas ||
                        ' sseguro =' || psseguro,
                        ' sentencia =' || v_sentencia_delete_pol || SQLERRM);
            RETURN 105577; --error al modificar las garantias
      END;

      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 6115;
      -- Fin Bug 23174
      v_insert_pol := 'INSERT into ' || ptablas || 'pregunpolseg' ||
                      ' (nmovimi, cpregun, crespue,trespue, ';

      IF ptablas = 'SOL'
      THEN
         v_insert_pol2 := ' ssolicit) ';
         v_insert_pol6 := 'and s.ssolicit =' || psseguro || ');';
      ELSE
         v_insert_pol2 := ' sseguro) ';
         v_insert_pol6 := 'and s.sseguro =' || psseguro || ');';
      END IF;

      v_insert_pol3          := 'select pp.nmovimi, pp.cpregun, pp.crespue, pp.trespue, pp.sseguro ';
      v_insert_pol5          := 'from pregunpolcar pp, codipregun cp where pp.sproces =' ||
                                psproces || ' and pp.sseguro = ' ||
                                psseguro || ' AND cp.cpregun = pp.cpregun ' -- BUG14172:DRA:27/04/2010
                                ||
                                ' AND((cp.ctippre IN(4, 5) AND pp.trespue IS NOT NULL) OR pp.crespue IS NOT NULL)' ||
                                ' and pp.cpregun in (select pg.cpregun from pregunpro pg,' ||
                                ptablas ||
                                'seguros s where pg.sproduc = s.sproduc' ||
                                ' and pg.cpretip =2 AND pg.cnivel IN (''R'', ''P'') ';
      v_sentencia_insert_pol := 'begin ' || v_insert_pol || v_insert_pol2 ||
                                v_insert_pol3 || v_insert_pol4 ||
                                v_insert_pol5 || v_insert_pol6 || ' end;';
      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 6116;

      -- Fin Bug 23174
      BEGIN
         EXECUTE IMMEDIATE v_sentencia_insert_pol;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas',
                        5,
                        'insert preguntas poliza ptablas =' || ptablas ||
                        ' sseguro =' || psseguro,
                        'sentencia =' || v_sentencia_insert_pol || SQLERRM);
            RETURN 105577; --error al modificar las garantias
      END;

      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 6117;
      -- Fin Bug 23174
      -- Traspasamos preguntas de poliza tab
      v_delete_pol := 'DELETE from ' || ptablas || 'pregunpolsegtab p ' ||
                      'WHERE p.cpregun IN (SELECT pg.cpregun FROM pregunpro pg,' ||
                      ptablas || 'seguros s WHERE pg.sproduc = s.sproduc' ||
                      ' AND pg.cpretip=2 AND pg.cnivel IN (''R'', ''P'') ';

      IF ptablas = 'SOL'
      THEN
         v_delete_pol2 := 'AND s.ssolicit =' || psseguro ||
                          ') AND p.ssolicit = ' || psseguro || ';';
      ELSE
         v_delete_pol2 := 'AND s.sseguro =' || psseguro ||
                          ') AND p.sseguro = ' || psseguro ||
                          ' AND p.nmovimi =' || pnmovimi || ';';
      END IF;

      v_sentencia_delete_pol := 'begin ' || v_delete_pol || v_delete_pol2 ||
                                ' end;';
      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 6118;

      -- Fin Bug 23174
      BEGIN
         EXECUTE IMMEDIATE v_sentencia_delete_pol;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas',
                        4,
                        'delete preguntastab poliza ptablas =' || ptablas ||
                        ' sseguro =' || psseguro,
                        ' sentencia =' || v_sentencia_delete_pol || SQLERRM);
            RETURN 105577; --error al modificar las garantias
      END;

      v_insert_pol := 'INSERT into ' || ptablas || 'pregunpolsegtab' ||
                      ' (nmovimi, cpregun, ';
      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 6119;

      -- Fin Bug 23174
      IF ptablas = 'SOL'
      THEN
         v_insert_pol2 := ' ssolicit, nlinea, ccolumna, tvalor, fvalor, nvalor) ';
         v_insert_pol6 := 'and s.ssolicit =' || psseguro || ');';
      ELSE
         v_insert_pol2 := ' sseguro, nlinea, ccolumna, tvalor, fvalor, nvalor) ';
         v_insert_pol6 := 'and s.sseguro =' || psseguro || ');';
      END IF;

      v_insert_pol3          := 'select pp.nmovimi, pp.cpregun, pp.sseguro, pp.nlinea, pp.ccolumna, pp.tvalor, pp.fvalor, pp.nvalor ';
      v_insert_pol5          := 'from pregunpolcartab pp, codipregun cp where pp.sproces =' ||
                                psproces || ' and pp.sseguro = ' ||
                                psseguro || ' AND cp.cpregun = pp.cpregun ' -- BUG14172:DRA:27/04/2010
                                ||
                                ' AND(cp.ctippre IN(7) AND (pp.tvalor IS NOT NULL OR pp.nvalor IS NOT NULL OR pp.fvalor IS NOT NULL))' ||
                                ' and pp.cpregun in (select pg.cpregun from pregunpro pg,' ||
                                ptablas ||
                                'seguros s where pg.sproduc = s.sproduc' ||
                                ' and pg.cpretip =2 AND pg.cnivel IN (''R'', ''P'') ';
      v_sentencia_insert_pol := 'begin ' || v_insert_pol || v_insert_pol2 ||
                                v_insert_pol3 || v_insert_pol4 ||
                                v_insert_pol5 || v_insert_pol6 || ' end;';
      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 6120;

      -- Fin Bug 23174
      BEGIN
         EXECUTE IMMEDIATE v_sentencia_insert_pol;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas tab',
                        5,
                        'insert preguntas poliza ptablas =' || ptablas ||
                        ' sseguro =' || psseguro,
                        'sentencia =' || v_sentencia_insert_pol || SQLERRM);
            RETURN 105577; --error al modificar las garantias
      END;

      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 6121;

      -- Fin Bug 23174
      ---------------------------------------------------------------------------------------------------------------------
      ---------------------------------------------------------------------------------------------------------------------

      -- TRASPASAMOS detalle de garanseg (detprimas)
      -- Bug 21121 - APD - 24/02/2012 -
      IF NVL(f_parproductos_v(v_sproduc, 'DETPRIMAS'), 0) = 1
      THEN
         IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN (1, 2) AND
            pmodali IN ('ALTA', 'MODIF', 'EXTRA')
         THEN
            FOR i IN garantias
            LOOP
               -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
               vpasexec := 6122;
               -- Fin Bug 23174
               v_delete := 'DELETE from ' || ptablas || 'detprimas ' ||
                           'where nriesgo = ' || pnriesgo;

               IF ptablas = 'SOL'
               THEN
                  v_delete2 := ' and ssolicit = ' || psseguro || ';';
               ELSE
                  v_delete2 := ' and sseguro = ' || psseguro ||
                               ' and nmovimi =' || pnmovimi ||
                               ' and cgarant = ' || i.cgarant || ';';
               END IF;

               v_sentencia_delete := ' begin ' || v_delete || v_delete2 ||
                                     ' end;';
               -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
               vpasexec := 6123;

               -- Fin Bug 23174
               BEGIN
                  EXECUTE IMMEDIATE v_sentencia_delete;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate,
                                 f_user,
                                 'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas',
                                 2,
                                 'delete detalle garantia ptablas =' ||
                                 ptablas || ' sseguro =' || psseguro ||
                                 ' nriesgo =' || pnriesgo,
                                 ' sentencia =' || v_sentencia_delete ||
                                 SQLERRM);
                     RETURN 105577; --error al modificar las garantias
               END;

               -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
               vpasexec := 6124;
               -- Fin Bug 23174
               v_insert := 'INSERT into ' || ptablas || 'detprimas' ||
                           ' (nriesgo, cgarant, ccampo, cconcep, norden, iconcep, iconcep2, ';

               IF ptablas = 'SOL'
               THEN
                  v_insert2 := ' ssolicit) ';
                  v_insert4 := NULL;
                  v_insert6 := ';';
               ELSE
                  v_insert2 := 'sseguro, finiefe,nmovimi) ';
                  v_insert4 := ', dp.finiefe, dp.nmovimi ';
                  v_insert6 := ';';
               END IF;

               v_insert3          := 'select dp.nriesgo, dp.cgarant, dp.ccampo, dp.cconcep, dp.norden, dp.iconcep, dp.iconcep2, dp.sseguro ';
               v_insert5          := 'from tmp_detprimas dp where dp.sproces =' ||
                                     psproces || ' and dp.sseguro = ' ||
                                     psseguro || ' and dp.cgarant = ' ||
                                     i.cgarant || ' and dp.nriesgo = ' ||
                                     pnriesgo;
               v_sentencia_insert := 'begin ' || v_insert || v_insert2 ||
                                     v_insert3 || v_insert4 || v_insert5 ||
                                     v_insert6 || ' end;';
               -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
               vpasexec := 6125;

               -- Fin Bug 23174
               BEGIN
                  EXECUTE IMMEDIATE v_sentencia_insert;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate,
                                 f_user,
                                 'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas',
                                 3,
                                 'insert detalle garantia ptablas =' ||
                                 ptablas || ' sseguro =' || psseguro ||
                                 ' nriesgo =' || pnriesgo,
                                 'sentencia =' || v_sentencia_insert ||
                                 SQLERRM);
                     RETURN 105577; --error al modificar las garantias
               END;
            END LOOP;
         ELSE
            -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
            vpasexec := 6126;
            -- Fin Bug 23174
            -- Fin Bug 13832
            v_delete := 'DELETE from ' || ptablas || 'detprimas ' ||
                        'where nriesgo = ' || pnriesgo;

            IF ptablas = 'SOL'
            THEN
               v_delete2 := ' and ssolicit = ' || psseguro || ';';
            ELSE
               v_delete2 := ' and sseguro = ' || psseguro ||
                            ' and nmovimi =' || pnmovimi || ';';
            END IF;

            v_sentencia_delete := ' begin ' || v_delete || v_delete2 ||
                                  ' end;';

            BEGIN
               EXECUTE IMMEDIATE v_sentencia_delete;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate,
                              f_user,
                              'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas',
                              2,
                              'delete detalle garantia ptablas =' ||
                              ptablas || ' sseguro =' || psseguro ||
                              ' nriesgo =' || pnriesgo,
                              ' sentencia =' || v_sentencia_delete ||
                              SQLERRM);
                  RETURN 105577; --error al modificar las garantias
            END;

            -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
            vpasexec := 6127;
            -- Fin Bug 23174
            v_insert := 'INSERT into ' || ptablas || 'detprimas' ||
                        ' (nriesgo, cgarant, ccampo, cconcep, norden, iconcep, iconcep2, ';

            IF ptablas = 'SOL'
            THEN
               v_insert2 := ' ssolicit) ';
               v_insert4 := NULL;
               v_insert6 := ';';
            ELSE
               v_insert2 := 'sseguro, finiefe,nmovimi) ';
               v_insert4 := ', dp.finiefe, dp.nmovimi ';
               v_insert6 := ';';
            END IF;

            v_insert3          := 'select dp.nriesgo, dp.cgarant, dp.ccampo, dp.cconcep, dp.norden, dp.iconcep, dp.iconcep2, dp.sseguro ';
            v_insert5          := 'from tmp_detprimas dp where dp.sproces =' ||
                                  psproces || ' and dp.sseguro = ' ||
                                  psseguro || ' and dp.nriesgo = ' ||
                                  pnriesgo;
            v_sentencia_insert := 'begin ' || v_insert || v_insert2 ||
                                  v_insert3 || v_insert4 || v_insert5 ||
                                  v_insert6 || ' end;';

            BEGIN
               EXECUTE IMMEDIATE v_sentencia_insert;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate,
                              f_user,
                              'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas',
                              3,
                              'insert detalle garantia ptablas =' ||
                              ptablas || ' sseguro =' || psseguro ||
                              ' nriesgo =' || pnriesgo,
                              'sentencia =' || v_sentencia_insert ||
                              SQLERRM);
                  RETURN 105577; --error al modificar las garantias
            END;
         END IF;
      END IF;

      -- FIN Bug 21121 - APD - 24/02/2012
      ---------------------------------------------------------------------------------------------------------------------
      ---------------------------------------------------------------------------------------------------------------------
      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 6128;

      -- Fin Bug 23174
      --Borramos las tablas temporales
      DELETE tmp_garancar WHERE sproces = psproces;

      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 6129;

      -- Fin Bug 23174
      DELETE pregungarancar WHERE sproces = psproces;

      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 6130;

      -- Fin Bug 23174
      DELETE preguncar WHERE sproces = psproces;

      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 6131;

      -- Fin Bug 23174
      DELETE pregunpolcar WHERE sproces = psproces;

      -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
      vpasexec := 6132;

      -- Fin Bug 23174
      -- Bug 21121 - APD - 24/02/2012 - se añade la tabla tmp_detprimas
      DELETE tmp_detprimas WHERE sproces = psproces;

      -- fin Bug 21121 - APD - 24/02/2012

      -- Bug 34371/198005 - 12/02/2015
      DELETE autdisriesgoscar WHERE sproces = psproces;

      DELETE autdetriesgoscar WHERE sproces = psproces;

      DELETE autconductorescar WHERE sproces = psproces;

      DELETE autriesgoscar WHERE sproces = psproces;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         -- Bug Bug 23174 - DCG - 30/08/2012 - CCAT804-CX - Fallo en renovación de intereses
         --         p_tab_error(f_sysdate, f_user, 'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas', 6,
         p_tab_error(f_sysdate,
                     f_user,
                     'PAC_TARIFAS.f_traspaso_de_tmp_a_tablas',
                     vpasexec,

                     -- Fin Bug 23174
                     ' error general ptablas =' || ptablas || ' sseguro =' ||
                     psseguro || ' nriesgo =' || pnriesgo,
                     'V_senetecia_update =' || v_sentencia_update ||
                     SQLERRM);
         RETURN 105577; --error al modificar las garantias
   END f_traspaso_de_tmp_a_tablas;

   -- Bug 11735 - RSC - 19/01/2010 - APR - suplemento de modificación de capital /prima (afegim parámetre pmodali)
   FUNCTION f_tarifar_riesgo_tot(ptablas  IN VARCHAR2,
                                 psseguro IN NUMBER,
                                 pnriesgo IN NUMBER,
                                 pnmovimi IN NUMBER,
                                 pmoneda  IN NUMBER,
                                 pfecha   IN DATE,
                                 paccion  IN VARCHAR2 DEFAULT 'NP',
                                 pmodali  IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      vsproces         NUMBER;
      num_err          NUMBER;
      vmensa           VARCHAR2(1000);
      vmodo            VARCHAR2(10);
      fecha_efec       DATE;
      vprimin          NUMBER;
      vprima_anual     NUMBER;
      v_cramo          NUMBER;
      v_cmodali        NUMBER;
      v_ctipseg        NUMBER;
      v_ccolect        NUMBER;
      v_cforpag        NUMBER;
      v_cidioma        NUMBER := 2;
      v_cobjase        NUMBER;
      v_cactivi        NUMBER;
      v_sproduc        NUMBER;
      v_select         VARCHAR2(1000);
      v_select2        VARCHAR2(1000);
      v_sentencia      VARCHAR2(1000);
      v_select_risc    VARCHAR2(1000);
      v_select_risc2   VARCHAR2(1000);
      v_sentencia_risc VARCHAR2(1000);
      v_cregul         movseguro.cregul%TYPE; -- BUG 34462 - AFM 01/2015
      -- bug 22008  - JLB - AGM - Calculo prima minima según formula
      v_cclapri productos.cclapri%TYPE;
      -- Bug 11735 - RSC - 02/01/2010 - APR - suplemento de modificación de capital /prima
      v_cont_tar NUMBER;
      -- Fin Bug 11735
   BEGIN
      -- Obtenemos la infomación de la póliza
      -- I - JLB - OPTIMI
      -- v_select :=
      --    'select sproduc, cramo, cmodali, ctipseg, ccolect, cforpag, cobjase, cactivi '
      --    || 'into :v_sproduc, :v_cramo, :v_cmodali, :v_ctipseg, :v_ccolect, :v_cforpag, :v_cobjase, '
      --    || ':v_cactivi' || ' from ' || ptablas || 'seguros where ';

      -- IF ptablas = 'SOL' THEN
      --    v_select2 := 'ssolicit =' || psseguro || ';';
      -- ELSE
      --    v_select2 := 'sseguro =' || psseguro || ';';
      -- END IF;

      --v_sentencia := ' begin ' || v_select || v_select2 || ' end;';
      -- F - JLB - OPTIMI
      BEGIN
         -- I- JLB - OPTIMINIZA
         --    EXECUTE IMMEDIATE v_sentencia
         --             USING OUT v_sproduc, OUT v_cramo, OUT v_cmodali, OUT v_ctipseg,
         --                      OUT v_ccolect, OUT v_cforpag, OUT v_cobjase, OUT v_cactivi;
         IF ptablas = 'SOL'
         THEN
            SELECT sproduc,
                   cramo,
                   cmodali,
                   ctipseg,
                   ccolect,
                   cforpag,
                   cobjase,
                   cactivi
              INTO v_sproduc,
                   v_cramo,
                   v_cmodali,
                   v_ctipseg,
                   v_ccolect,
                   v_cforpag,
                   v_cobjase,
                   v_cactivi
              FROM solseguros
             WHERE ssolicit = psseguro;
         ELSIF ptablas = 'EST'
         THEN
            SELECT sproduc,
                   cramo,
                   cmodali,
                   ctipseg,
                   ccolect,
                   cforpag,
                   cobjase,
                   cactivi,
                   cregul -- cregul BUG 34462 - AFM 01/2015
              INTO v_sproduc,
                   v_cramo,
                   v_cmodali,
                   v_ctipseg,
                   v_ccolect,
                   v_cforpag,
                   v_cobjase,
                   v_cactivi,
                   v_cregul -- cregul BUG 34462 - AFM 01/2015
              FROM estseguros
             WHERE sseguro = psseguro;
         ELSE
            SELECT sproduc,
                   cramo,
                   cmodali,
                   ctipseg,
                   ccolect,
                   cforpag,
                   cobjase,
                   cactivi
              INTO v_sproduc,
                   v_cramo,
                   v_cmodali,
                   v_ctipseg,
                   v_ccolect,
                   v_cforpag,
                   v_cobjase,
                   v_cactivi
              FROM seguros
             WHERE sseguro = psseguro;
         END IF;
         -- F - JLB - OpTIMI
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        'PAC_TARIFAS.f_tarifar_riesgo_tot',
                        5,
                        'select a seguros ptablas =' || ptablas ||
                        ' sseguro =' || psseguro || ' nriesgo =' ||
                        pnriesgo || 'sentencia =' || v_sentencia,
                        SQLERRM);
            RETURN 40301; --registro no encontrado
      END;

      -- obtenemos el proceso
      SELECT starifa.nextval INTO vsproces FROM dual;

      -- BUG 22008 jlb obtenemos el parametro de clave
      SELECT cclapri
        INTO v_cclapri
        FROM productos
       WHERE sproduc = v_sproduc;

      p_tratapre_detalle_garant(v_sproduc,
                                psseguro,
                                pnriesgo,
                                pnmovimi,
                                vsproces,
                                ptablas);
      -- traspasamos la información a las tablas de temporal tmp.
      num_err := pac_tarifas.f_tmpgarancar(ptablas,
                                           vsproces,
                                           psseguro,
                                           pnriesgo,
                                           pnmovimi,
                                           pfecha
                                           --JRH Fecha de referencia para simulaciones de renovaciones
                                           );

      IF num_err <> 0
      THEN
         p_tab_error(f_sysdate,
                     f_user,
                     'pac_tarifas.f_tarifar_riesgo_tot',
                     1,
                     'llamada a pac_tarifas.f_tmpgarancar',
                     num_err);
         RETURN num_err;
      END IF;

      -- Bug 11735 - RSC - 02/01/2010 - APR - suplemento de modificación de capital /prima
      IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN (1, 2)
      THEN
         -- jlb - optimizacion '*'
         SELECT COUNT('*')
           INTO v_cont_tar
           FROM tmp_garancar
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cunica NOT IN (1, 2);

         IF v_cont_tar = 0
         THEN
            RETURN 0;
            -- Nada que tarifar en este caso (y no es un error. Cosas de APRA)!
         END IF;
      END IF;

      -- Fin Bug 11735
      vnmovimidef := pnmovimi; --JRH IMP Cutre , pero efectivo
      --tarifamos la información que tenemos en EST.
      num_err := pac_tarifas.f_tarifar_126(vsproces,
                                           ptablas,
                                           'TAR',
                                           'R',
                                           v_cramo,
                                           v_cmodali,
                                           v_ctipseg,
                                           v_ccolect,
                                           v_sproduc,
                                           v_cactivi,
                                           NULL,
                                           NULL,
                                           psseguro,
                                           pnriesgo,
                                           pfecha,
                                           pfecha,
                                           0,
                                           v_cobjase,
                                           v_cforpag,
                                           v_cidioma,
                                           NULL,
                                           NULL,
                                           pmoneda,
                                           -- BUG 22008 - JLB
                                           -- NULL,
                                           v_cclapri,
                                           -- BUG 22008 -
                                           vprimin,
                                           vprima_anual,
                                           vmensa,
                                           paccion,
                                           pnmovimi); --Bug 21127 - APD - 08/03/2012

      IF num_err <> 0
      THEN
         p_tab_error(f_sysdate,
                     f_user,
                     'pac_tarifas.f_tarifar_riesgo_tot',
                     2,
                     'llamada a pac_tarifas.f_tarifar_126',
                     num_err);
         RETURN num_err;
      END IF;

      num_err := f_traspaso_de_tmp_a_tablas(ptablas,
                                            psseguro,
                                            pnriesgo,
                                            pnmovimi,
                                            vsproces,
                                            pmoneda,
                                            pmodali);

      IF num_err <> 0
      THEN
         p_tab_error(f_sysdate,
                     f_user,
                     'pac_tarifas.f_tarifar_riesgo_tot',
                     2,
                     'llamada a pac_tarifas.f_traspaso_de_tmp_a_tablas',
                     num_err);
         RETURN num_err;
      END IF;

      -- INI BUG 34462 - AFM 01/2015
      -- Miramos si es un suplemento de regularización o retroactivo, para llamar a la función que guarda los tramos
      IF ptablas <> 'EST'
      THEN
         SELECT cregul
           INTO v_cregul
           FROM movseguro
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;
      END IF;

      IF NVL(v_cregul, 0) = 1 OR
         paccion = 'RG'
      THEN
         IF paccion = 'RG'
         THEN
            -- Suplemento de regularización
            num_err := pac_tarifas.f_generar_tabla_tramos(ptablas,
                                                          psseguro,
                                                          pnriesgo,
                                                          pnmovimi,
                                                          pfecha,
                                                          2,
                                                          vsproces);
         ELSE
            -- Suplemento retroactivo
            num_err := pac_tarifas.f_generar_tabla_tramos(ptablas,
                                                          psseguro,
                                                          pnriesgo,
                                                          pnmovimi,
                                                          pfecha,
                                                          1,
                                                          vsproces);
         END IF;
      END IF;

      IF num_err <> 0
      THEN
         p_tab_error(f_sysdate,
                     f_user,
                     'pac_tarifas.f_tarifar_riesgo_tot',
                     2,
                     'llamada a pac_tarifas.f_generar_tabla_tramos',
                     num_err);
         RETURN num_err;
      END IF;

      -- FIN BUG 34462 - AFM 01/2015
      --
      p_trata_detalle_garant(v_sproduc,
                             psseguro,
                             pnriesgo,
                             pnmovimi,
                             vsproces,
                             ptablas);
      RETURN 0;
      --
   END f_tarifar_riesgo_tot;

   -- CHANGE

   /***********************************************************************
      Càlcul del recàrrec per fraccionament a aplicar en funció d'una determinada
      prima anual, forma de pagament i producte.
      param in pcramo      : código del ramo
      param in pcmodali    : código de la modalidad
      param in pctipseg    : código del tipo de seguro
      param in pccolect    : código del tipo de colectivo
      param in pcactivi    : código de la actividad
      param in pcgarant    : código de la garantia
      param in pcforpag    : código forma de pago
      param in piprianu    : prima anual
      param out oirecfrac  : importe del recargo por fraccionamento
      return               : 0/1 -> Ok/Error
   ***********************************************************************/
   FUNCTION f_calcula_recargo_fracc(pmode     IN VARCHAR2,
                                    psseguro  IN NUMBER,
                                    pnriesgo  IN NUMBER,
                                    pfiniefe  IN DATE,
                                    pcramo    IN NUMBER,
                                    pcmodali  IN NUMBER,
                                    pctipseg  IN NUMBER,
                                    pccolect  IN NUMBER,
                                    pcactivi  IN NUMBER,
                                    pcgarant  IN NUMBER,
                                    pcforpag  IN NUMBER,
                                    piprianu  IN NUMBER,
                                    pidtocom  IN NUMBER,
                                    oirecfrac OUT NUMBER,
                                    pnmovimi  IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      e_object_error EXCEPTION;
      e_param_error  EXCEPTION;
      vobjectname tab_error.tdescrip%TYPE;
      vparam      tab_error.tdescrip%TYPE;
      vpasexec    NUMBER(8);
      vnumerr     NUMBER(8);
      vprecarg    NUMBER;
      vcempres    NUMBER;
      -- LPS (10/09/2008). Variables para el nuevo módulo de impuestos.
      vctipcon NUMBER;
      vnvalcon NUMBER;
      vcfracci NUMBER;
      vcbonifi NUMBER;
      vcrecfra NUMBER;
      verr     NUMBER;
      -- Bug 10864.NMM.01/08/2009.
      w_climit  NUMBER;
      v_cmonimp imprec.cmoneda%TYPE;
      -- BUG 18423: LCOL000 - Multimoneda
      vcderreg NUMBER; -- Bug 0020314 - FAL - 29/11/2011
      -- LPS (10/09/2008). Nuevo módulo de impuestos.
      -- JLB - I - BUG 18423 COjo la moneda del producto
      vsproduc productos.sproduc%TYPE;
      vmoneda  monedas.cmoneda%TYPE;
      vfuncion VARCHAR2(3);
      -- JLB -F - BUG 18423 COjo la moneda del producto
      vvcaccion NUMBER;
      vcmovseg  NUMBER;
   BEGIN
      oirecfrac   := 0;
      vobjectname := 'PAC_TARIFAS.f_calcula_recargo_fracc';
      vparam      := 'parámetros - pcramo: ' || pcramo || ' - pcmodali: ' ||
                     pcmodali || ' - pctipseg: ' || pctipseg ||
                     ' - pccolect: ' || pccolect || ' - pcactivi: ' ||
                     pcactivi || ' - pcgarant: ' || pcgarant ||
                     ' - pcforpag: ' || pcforpag || ' - piprianu: ' ||
                     piprianu || ' - pmode: ' || pmode || '- psseguro: ' ||
                     psseguro || '- pnriesgo: ' || pnriesgo ||
                     '- pfiniefe: ' || pfiniefe;
      vnumerr     := 0;
      vpasexec    := 1;

      --Comprovació dels parámetres d'entrada
      IF pmode IS NULL OR
         psseguro IS NULL OR
         pnriesgo IS NULL OR
         pfiniefe IS NULL OR
         pcramo IS NULL OR
         pcmodali IS NULL OR
         pctipseg IS NULL OR
         pccolect IS NULL OR
         pcactivi IS NULL OR
         pcgarant IS NULL OR
         pcforpag IS NULL OR
         piprianu IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      -- LPS (10/09/2008). Se modifica la forma de obtener el recargo por el Nuevo módulo de impuestos.
      BEGIN
         SELECT cempres INTO vcempres FROM codiram WHERE cramo = pcramo;
      EXCEPTION
         WHEN OTHERS THEN
            vprecarg := 0;
      END;

      verr := f_concepto(8,
                         vcempres,
                         f_sysdate,
                         pcforpag,
                         pcramo,
                         pcmodali,
                         pctipseg,
                         pccolect,
                         pcactivi,
                         pcgarant,
                         vctipcon,
                         vnvalcon,
                         vcfracci,
                         vcbonifi,
                         vcrecfra,
                         w_climit, -- Bug 10864.NMM.01/08/2009.
                         v_cmonimp, -- BUG 18423: LCOL000 - Multimoneda
                         vcderreg -- Bug 0020314 - FAL - 29/11/2011
                         );

      IF verr <> 0
      THEN
         -- Si da error la función.
         vnvalcon := 0;
      END IF;

      vpasexec := 5;
      -- JLB - I - BUG 18423 COjo la moneda del producto
      vsproduc := pac_productos.f_get_sproduc(pcramo,
                                              pcmodali,
                                              pctipseg,
                                              pccolect);
      vmoneda  := pac_monedas.f_moneda_producto(vsproduc);

      -- JLB - F - BUG 18423 COjo la moneda del producto
      --Càlcul de l'import de recàrrec per pagament fraccionat
      --oirecfrac := f_round ((vprecarg * piprianu) / 100);
      IF vctipcon = 1
      THEN
         -- Tasa
         oirecfrac := f_round((NVL(piprianu, 0) * NVL(vnvalcon, 0)),
                              vmoneda,
                              NVL(pac_parametros.f_parempresa_n(vcempres,
                                                                'REDONDEO_SRI'),
                                  0));
      ELSIF vctipcon = 2
      THEN
         -- Importe fijo
         oirecfrac := f_round(NVL(vnvalcon, 0),
                              vmoneda,
                              NVL(pac_parametros.f_parempresa_n(vcempres,
                                                                'REDONDEO_SRI'),
                                  0));
      ELSIF vctipcon = 3
      THEN
         -- Porcentaje
         oirecfrac := f_round(((NVL(piprianu, 0) * (NVL(vnvalcon, 0)) / 100)),
                              vmoneda,
                              NVL(pac_parametros.f_parempresa_n(vcempres,
                                                                'REDONDEO_SRI'),
                                  0));
         /********************** CML *************************/
      ELSE
         IF pmode = 'POL'
         THEN
            vfuncion := 'SEG';
         ELSE
            vfuncion := 'EST';
         END IF;

         IF pnmovimi IS NOT NULL
         THEN
            IF pnmovimi > 1
            THEN
               IF vfuncion = 'EST'
               THEN
                  vvcaccion := 2;
               ELSE
                  BEGIN
                     SELECT cmovseg
                       INTO vcmovseg
                       FROM movseguro
                      WHERE sseguro = psseguro
                        AND nmovimi = pnmovimi;

                     IF vcmovseg = 2
                     THEN
                        vvcaccion := 3;
                     ELSE
                        vvcaccion := 2;
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vvcaccion := 3;
                  END;
               END IF;
            ELSE
               vvcaccion := 0;
            END IF;
         END IF;

         verr := pac_impuestos.f_calcula_impconcepto(vnvalcon,
                                                     piprianu,
                                                     piprianu,
                                                     pidtocom,
                                                     pidtocom,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     vctipcon,
                                                     pcforpag,
                                                     vcfracci,
                                                     vcbonifi,
                                                     vcrecfra,
                                                     oirecfrac,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     pfiniefe,
                                                     psseguro,
                                                     pnriesgo,
                                                     pcgarant,
                                                     vmoneda,
                                                     vfuncion,
                                                     vvcaccion);

         IF verr <> 0
         THEN
            -- Si da error la función.
            oirecfrac := 0;
         END IF;

         oirecfrac := f_round(NVL(oirecfrac, 0),
                              vmoneda,
                              NVL(pac_parametros.f_parempresa_n(vcempres,
                                                                'REDONDEO_SRI'),
                                  0));
         /********************************************** CML ******************************/
      END IF;

      RETURN 0;
      -- Fin LPS (10/09/2008).
      -- LPS (10/09/2008). Se comenta el funcionamiento anterior.
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 101901;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 180721;
   END f_calcula_recargo_fracc;

   /*FUNCTION f_calcula_iconcepto(
      piprianu IN NUMBER,
      pidtocom IN NUMBER,
      pnvalcon IN NUMBER,
      ptot_recfrac IN NUMBER,
      pctipcon IN NUMBER,
      pcforpag IN NUMBER,
      pcbonifica IN NUMBER,
      oiconcep OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      IF pctipcon = 1 THEN   -- Tasa
         oiconcep := f_round(((NVL(piprianu, 0) + NVL(ptot_recfrac, 0)
                               +(NVL(pcbonifica, 0) * NVL(pidtocom, 0)))
                              / pcforpag)
                             * NVL(pnvalcon, 0))
                     * pcforpag;
      ELSIF pctipcon = 2 THEN   -- Importe fijo
         oiconcep := f_round(NVL(pnvalcon, 0));
      ELSIF pctipcon = 3 THEN   -- Porcentaje
         oiconcep := f_round(((NVL(piprianu, 0) + NVL(ptot_recfrac, 0)
                               +(NVL(pcbonifica, 0) * NVL(pidtocom, 0)))
                              / pcforpag)
                             *(NVL(pnvalcon, 0) / 100))
                     * pcforpag;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_calcula_iconcepto;*/

   -- Bug 0020314 - FAL - 29/11/2011
   /***********************************************************************
      Càlcul del concepte de rebut 14 (drets registre) a aplicar en funció d'una determinada prima anual, forma de pagament i producte.
      param in pcderreg    : si la garantia aplica drets de registre
      param in vcempres    : codi empresa
      param in psproduc    : codi producte
      param in pnmovimi    : codi moviment
      param in pfiniefe    : fecha inicio efecto de la cobertura (para prorrateo)
      param in pcforpag    : código forma de pago
      param in xcramo      : código ramo
      param in xcmodali    : código modalidad
      param in xctipseg    : código tipseg
      param in xccolect    : código colect
      param in pcactivi    : código de la actividad
      param in pcgarant    : código de la garantia
      param in psseguro    : código sseguro
      param in pnriesgo    : código riesgo
      param in pmode       : código modo reales, estudio, ...
      param in xirecfrac   : importe recargo por fracc
      param in piprianu    : importe prima anual
      param in pidtocom    : Descuento comercial
      param in xcforpag    : forma pago
      return               : Importe derechos registro
   ***********************************************************************/
   FUNCTION f_calcul_derreg_por_impost(pcderreg  IN NUMBER,
                                       vcempres  IN NUMBER,
                                       psproduc  IN NUMBER,
                                       pnmovimi  IN NUMBER,
                                       pfiniefe  IN DATE,
                                       pcforpag  IN NUMBER,
                                       xcramo    IN NUMBER,
                                       xcmodali  IN NUMBER,
                                       xctipseg  IN NUMBER,
                                       xccolect  IN NUMBER,
                                       pcactivi  IN NUMBER,
                                       pcgarant  IN NUMBER,
                                       psseguro  IN NUMBER,
                                       pnriesgo  IN NUMBER,
                                       pmode     IN VARCHAR2,
                                       xirecfrac IN NUMBER,
                                       piprianu  IN NUMBER,
                                       pidtocom  IN NUMBER,
                                       xcforpag  IN NUMBER) RETURN NUMBER IS
      vpasexec NUMBER(8);
      vctipcon NUMBER;
      vnvalcon NUMBER;
      vcfracci NUMBER;
      vcbonifi NUMBER;
      vcrecfra NUMBER;
      verr     NUMBER;
      xderreg  NUMBER := 0;
      -- importe Derechos de registro
      w_climit    NUMBER;
      vcderreg    NUMBER;
      xicapital   NUMBER;
      tot_recfrac NUMBER;
      v_cmonimp   NUMBER;
      -- JLB - I - BUG 18423 COjo la moneda del producto
      vmoneda monedas.cmoneda%TYPE;
      -- JLB -F - BUG 18423 COjo la moneda del producto
      vfuncion      VARCHAR2(3);
      v_crespue9082 estpregungaranseg.crespue%TYPE;
      -- BUG 0026835 - FAL - 06/05/2013
   BEGIN
      IF pcderreg > 0
        -- Comprobamos si la garantía calcula Derechos de registro
         AND
         pnriesgo = 1
      THEN
         -- Bug 0020616 - FAL - 22/12/2011
         vpasexec := 61;
         vctipcon := NULL;
         vnvalcon := NULL;
         vcfracci := NULL;
         vcbonifi := NULL;
         vcrecfra := NULL;
         --
         verr := 0;

         IF NVL(pac_parametros.f_parempresa_n(vcempres, 'MODO_CALC_GASTEXP'),
                0) = 1 AND
            (NVL(pac_parametros.f_parproducto_n(psproduc, 'GASTEXP_CALCULO'),
                 0) = 0 OR
             (NVL(pac_parametros.f_parproducto_n(psproduc,
                                                 'GASTEXP_CALCULO'),
                  0) IN (1, 2) AND pnmovimi <> 1))
         THEN
            verr := 1; -- para que no calcule los gastos de expedicion
         END IF;

         -- BUG 0026835 - FAL - 06/05/2013
         IF NVL(pac_parametros.f_parempresa_n(vcempres, 'IMPOST_PER_PREG'),
                0) = 1 AND
            NVL(pac_parametros.f_parempresa_n(vcempres, 'PREG_GASTO_EMI'),
                0) <> 0
         THEN
            v_crespue9082 := NVL(pac_preguntas.f_get_pregungaranseg_v(psseguro,
                                                                      pcgarant,
                                                                      pnriesgo,
                                                                      9082,
                                                                      'EST',
                                                                      NULL),
                                 0);

            IF v_crespue9082 = 0
            THEN
               verr := 1; -- para que no calcule los gastos de expedicion
            END IF;
         END IF;

         -- FI BUG 0026835 - FAL - 06/05/2013
         IF verr <> 0
         THEN
            -- Si verr <> 0 es pq no se quiere que se calculen los gastos de expedicion
            xderreg := 0;
         ELSE
            verr := f_concepto(14,
                               vcempres,
                               pfiniefe,
                               pcforpag,
                               xcramo,
                               xcmodali,
                               xctipseg,
                               xccolect,
                               pcactivi,
                               pcgarant,
                               vctipcon,
                               vnvalcon,
                               vcfracci,
                               vcbonifi,
                               vcrecfra,
                               w_climit,
                               v_cmonimp, -- BUG 18423: LCOL000 - Multimoneda
                               vcderreg);

            IF vctipcon = 4
            THEN
               -- Para impuesto sobre capital (no sobre prima)
               verr := pac_impuestos.f_calcula_impuestocapital(psseguro,
                                                               pnmovimi,
                                                               pnriesgo,
                                                               pmode,
                                                               'CDERREG',
                                                               xicapital,
                                                               pcgarant);
            END IF;

            IF verr <> 0
            THEN
               -- Si da error la función.
               xderreg := 0;
            ELSE
               IF NVL(vcrecfra, 0) = 1
               THEN
                  tot_recfrac := xirecfrac;
               ELSE
                  tot_recfrac := 0;
               END IF;

               -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
               vmoneda := pac_monedas.f_moneda_producto(pac_productos.f_get_sproduc(xcramo,
                                                                                    xcmodali,
                                                                                    xctipseg,
                                                                                    xccolect));

               -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda

               -- Bug 0022964 - FAL - 19/07/2012
               IF pmode = 'POL'
               THEN
                  vfuncion := 'SEG';
               ELSE
                  vfuncion := 'EST';
               END IF;

               -- Fi Bug 0022964
               verr := pac_impuestos.f_calcula_impconcepto(vnvalcon,
                                                           piprianu,
                                                           piprianu,
                                                           pidtocom,
                                                           pidtocom,
                                                           NULL,
                                                           xicapital,
                                                           tot_recfrac,
                                                           NULL,
                                                           vctipcon,
                                                           xcforpag,
                                                           vcfracci,
                                                           vcbonifi,
                                                           vcrecfra,
                                                           xderreg,
                                                           NULL,
                                                           NULL,
                                                           NULL,
                                                           pfiniefe,
                                                           psseguro,
                                                           pnriesgo,
                                                           pcgarant,
                                                           vmoneda,
                                                           vfuncion);

               -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
               IF verr <> 0
               THEN
                  -- Si da error la función.
                  xderreg := 0;
               END IF;

               xderreg := f_round(NVL(xderreg, 0),
                                  vmoneda,
                                  NVL(pac_parametros.f_parempresa_n(vcempres,
                                                                    'REDONDEO_SRI'),
                                      0));
            END IF;
         END IF;
      END IF;

      RETURN NVL(xderreg, 0);
   END f_calcul_derreg_por_impost;

   -- Fi Bug 20314
   --Bug 24656-XVM-21/11/2012.Nueva función f_arbitrio. Inicio
   FUNCTION f_arbitrio(xcderreg  IN NUMBER,
                       vcempres  IN NUMBER,
                       psproduc  IN NUMBER,
                       pfiniefe  IN DATE,
                       pcforpag  IN NUMBER,
                       pcramo    IN NUMBER,
                       pcmodali  IN NUMBER,
                       pctipseg  IN NUMBER,
                       pccolect  IN NUMBER,
                       pcactivi  IN NUMBER,
                       pcgarant  IN NUMBER,
                       pirecfrac IN NUMBER,
                       psseguro  IN NUMBER,
                       pnriesgo  IN NUMBER,
                       pnmovimi  IN NUMBER,
                       piprianu  IN NUMBER,
                       pidtocom  IN NUMBER,
                       pmode     IN VARCHAR2) RETURN NUMBER IS
      xarb        NUMBER := 0; -- importe ARB
      vpasexec    NUMBER(8);
      vnvalcon    NUMBER;
      vcfracci    NUMBER;
      vcbonifi    NUMBER;
      vcrecfra    NUMBER;
      verror      NUMBER;
      xicapital   NUMBER;
      w_climit    NUMBER;
      v_cmonimp   imprec.cmoneda%TYPE;
      vcderreg    NUMBER;
      tot_recfrac NUMBER;
      xirecfrac   NUMBER := 0;
      xderreg     NUMBER := 0;
      v_cmonprod  codidivisa.cmoneda%TYPE;
      vctipcon    NUMBER;
      verr        NUMBER;
      vfuncion    VARCHAR2(100);
      vmoneda     monedas.cmoneda%TYPE;
   BEGIN
      vpasexec   := 41;
      vctipcon   := NULL;
      vnvalcon   := NULL;
      vcfracci   := NULL;
      vcbonifi   := NULL;
      vcrecfra   := NULL;
      v_cmonprod := pac_monedas.f_moneda_producto(psproduc);
      verr       := f_concepto(6,
                               vcempres,
                               pfiniefe,
                               pcforpag,
                               pcramo,
                               pcmodali,
                               pctipseg,
                               pccolect,
                               pcactivi,
                               pcgarant,
                               vctipcon,
                               vnvalcon,
                               vcfracci,
                               vcbonifi,
                               vcrecfra,
                               w_climit, -- Bug 10864.NMM.01/08/2009.
                               v_cmonimp, -- BUG 18423: LCOL000 - Multimoneda
                               vcderreg); -- Bug 0020314 - FAL - 29/11/2011

      IF vctipcon = 4
      THEN
         -- Para impuesto sobre capital (no sobre prima)
         verr := pac_impuestos.f_calcula_impuestocapital(psseguro,
                                                         pnmovimi,
                                                         pnriesgo,
                                                         pmode,
                                                         'CIMPARB',
                                                         xicapital,
                                                         pcgarant);
      END IF;

      IF verr <> 0
      THEN
         -- Si da error la función.
         xarb := 0;
      ELSE
         IF NVL(vcrecfra, 0) = 1
         THEN
            tot_recfrac := xirecfrac;
         ELSE
            tot_recfrac := 0;
         END IF;

         -- Bug 0020314 - FAL - 29/11/2011
         IF vcderreg = 1
         THEN
            xderreg := f_calcul_derreg_por_impost(xcderreg,
                                                  vcempres,
                                                  psproduc,
                                                  pnmovimi,
                                                  pfiniefe,
                                                  pcforpag,
                                                  pcramo,
                                                  pcmodali,
                                                  pctipseg,
                                                  pccolect,
                                                  pcactivi,
                                                  pcgarant,
                                                  psseguro,
                                                  pnriesgo,
                                                  pmode,
                                                  pirecfrac,
                                                  piprianu,
                                                  pidtocom,
                                                  pcforpag);
         END IF;

         -- Fin Bug 0020314 - FAL - 29/11/2011

         -- Bug 0022964 - FAL - 19/07/2012
         IF pmode = 'POL'
         THEN
            vfuncion := 'SEG';
         ELSE
            vfuncion := 'EST';
         END IF;

         -- Fi Bug 0022964
         verr := pac_impuestos.f_calcula_impconcepto(vnvalcon,
                                                     piprianu,
                                                     piprianu,
                                                     pidtocom,
                                                     pidtocom,
                                                     NULL,
                                                     xicapital,
                                                     tot_recfrac,
                                                     NULL,
                                                     vctipcon,
                                                     pcforpag,
                                                     vcfracci,
                                                     vcbonifi,
                                                     vcrecfra,
                                                     xarb,
                                                     xderreg,
                                                     vcderreg
                                                     -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                                    ,
                                                     -- Bug 0022964 - FAL - 19/07/2012
                                                     NULL,
                                                     pfiniefe,
                                                     psseguro,
                                                     pnriesgo,
                                                     pcgarant,
                                                     -- Fi Bug 0022964
                                                     v_cmonprod,
                                                     vfuncion
                                                     -- Bug 0022964 - FAL - 19/07/2012
                                                     -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                                     );

         -- Fin Bug 0020314 - FAL - 29/11/2011 - Añadir derechos de regisro
         IF verr <> 0
         THEN
            -- Si da error la función.
            xarb := 0;
         END IF;

         xarb := f_round(NVL(xarb, 0),
                         v_cmonimp,
                         NVL(pac_parametros.f_parempresa_n(vcempres,
                                                           'REDONDEO_SRI'),
                             0));
      END IF;

      RETURN xarb;
   END f_arbitrio;

   --Bug 24656-XVM-21/11/2012.Nueva función f_arbitrio. Final

   /***********************************************************************
      Càlcul del concepte de rebut a aplicar en funció d'una determinada prima anual, forma de pagament i producte.
      param in pcconcep    : código del concepto que se desea calcular (VF 27)
      param in pfiniefe    : fecha inicio efecto de la cobertura (para prorrateo)
      param in pffinefe    : fecha fin efecto de la cobertura (para prorrateo)
      param in pcrecfra    : indica si existe recargo por fraccionamiento o no
      param in pcactivi    : código de la actividad
      param in pcgarant    : código de la garantia
      param in pcforpag    : código forma de pago
      param in piprianu    : prima anual
      param out oiconcep   : importe del concepto
      return               : 0/1 -> Ok/Error
   ***********************************************************************/
   FUNCTION f_calcula_concepto(pcconcep IN NUMBER,
                               psseguro IN NUMBER,
                               pnriesgo IN NUMBER,
                               pnmovimi IN NUMBER,
                               pfiniefe IN DATE,
                               pffinefe IN DATE,
                               pcrecfra IN NUMBER,
                               psproduc IN NUMBER,
                               pcactivi IN NUMBER,
                               pcgarant IN NUMBER,
                               pcforpag IN NUMBER,
                               piprianu IN NUMBER,
                               pidtocom IN NUMBER,
                               pmode    IN VARCHAR2,
                               oiconcep OUT NUMBER) RETURN NUMBER IS
      e_object_error EXCEPTION;
      e_param_error  EXCEPTION;
      vobjectname tab_error.tdescrip%TYPE;
      vparam      tab_error.tdescrip%TYPE;
      vpasexec    NUMBER(8);
      vnumerr     NUMBER(8);
      xcramo      productos.cramo%TYPE;
      xcmodali    productos.cmodali%TYPE;
      xctipseg    productos.ctipseg%TYPE;
      xccolect    productos.ccolect%TYPE;
      xcprorra    productos.cprorra%TYPE;
      xcrevfpg    productos.crevfpg%TYPE;
      xcforpag    seguros.cforpag%TYPE;
      xips_fracc  NUMBER;
      -- indicador de si aplicamos IPS al recargo por fraccionamiento
      ximp_boni NUMBER;
      -- indicador de si aplicamos los impuestos sobre la prima bonificada
      xclea_fracc NUMBER;
      -- indicador de si aplicamos CLEA al recargo por fraccionamiento
      xcimpclea NUMBER;
      -- indicador de si la garantía calcula DGS (CLEA)
      xcimpips NUMBER; -- indicador de si la garantía calcula IPS
      xcderreg NUMBER;
      -- indicador de si la garantía calcula DER. REG.
      xcimparb NUMBER;
      -- indicador de si la garantía calcula ARBITRIOS
      xcimpfng  NUMBER; -- indicador de si la garantía calcula FNG
      xcimpcons NUMBER;
      -- indicador de si la garantía calcula CONSORCIO
      taxaips     NUMBER; -- % de IPS
      taxaclea    NUMBER; -- % de CLEA
      taxaarb     NUMBER; -- % de ARB
      taxafng     NUMBER; -- % de FNG
      taxacons    NUMBER; -- % de Consorci
      tot_recfrac NUMBER;
      xirecfrac   NUMBER := 0;
      -- importe de recargo por fraccionamiento de la garantía
      xips  NUMBER := 0; -- importe IPS
      xclea NUMBER := 0; -- importe CLEA
      xarb  NUMBER := 0; -- importe ARB
      xfng  NUMBER := 0; -- importe FNG
      xcons NUMBER := 0;
      -- importe Consorcio
      -- LPS (10/09/2008). Variables para el nuevo módulo de impuestos.
      xderreg NUMBER := 0;
      -- importe Derechos de registro
      -- Bug 23074 - APD - 02/08/2012
      xivaderreg NUMBER := 0;
      -- importe IVA Derechos de registro
      -- Bug 0019578 - FAL - 26/09/2011 - Cálculo derechos de registro
      vcempres         NUMBER;
      vnvalcon         NUMBER;
      vctipcon         NUMBER;
      vcfracci         NUMBER;
      vcbonifi         NUMBER;
      vcrecfra         NUMBER;
      verr             NUMBER;
      vffinrec         DATE;
      vnmovimi         NUMBER;
      xcmotmov         NUMBER;
      valtarisc        BOOLEAN;
      vtipo_movimiento NUMBER;
      vcapieve         NUMBER;
      xnconsorci       NUMBER;
      xicapital        NUMBER;
      vfacconsor       NUMBER;
      vfuncion         VARCHAR2(3);
      -- Bug 10864.NMM.01/08/2009.
      w_climit  NUMBER;
      v_cmonimp imprec.cmoneda%TYPE;
      -- BUG 18423: LCOL000 - Multimoneda
      vcderreg    NUMBER; -- Bug 0020314 - FAL - 29/11/2011
      v_cmultimon parempresas.nvalpar%TYPE;
      -- Bug 20448 - APD - 02/01/2012
      v_cmonprod codidivisa.cmoneda%TYPE;
      -- BUG 20448 - APD - 02/01/2012
      vfcambio  DATE; -- BUG 20448 - APD - 02/01/2012
      vitasa    NUMBER; -- BUG 20448 - APD - 02/01/2012
      vcrespue  NUMBER;
      verror    NUMBER;
      valor     NUMBER;
      voiconcep NUMBER;
      vcobjase  NUMBER;
   BEGIN
      oiconcep    := 0;
      vobjectname := 'PAC_TARIFAS.f_calcula_concepto';
      vparam      := 'parámetros - pcconcep: ' || pcconcep ||
                     ' - pfiniefe: ' || pfiniefe || ' - pffinefe: ' ||
                     pffinefe || ' - pcrecfra: ' || pcrecfra ||
                     ' - psproduc: ' || psproduc || ' - pcactivi: ' ||
                     pcactivi || ' - pcgarant: ' || pcgarant ||
                     ' - pcforpag: ' || pcforpag || ' - piprianu: ' ||
                     piprianu;
      vnumerr     := 0;
      vpasexec    := 1;

      --Comprovació dels parámetres d'entrada
      IF pcconcep IS NULL
        --OR pfiniefe IS NULL OR pffinefe IS NULL
         OR
         pcactivi IS NULL OR
         pcgarant IS NULL OR
         pcforpag IS NULL OR
         piprianu IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      --Obtenemos datos del producto
      SELECT p.cramo,
             p.cmodali,
             p.ctipseg,
             p.ccolect,
             p.cprorra,
             DECODE(pcforpag, 0, 1, pcforpag),
             crevfpg
        INTO xcramo,
             xcmodali,
             xctipseg,
             xccolect,
             xcprorra,
             xcforpag,
             xcrevfpg
        FROM productos p
       WHERE p.sproduc = psproduc;

      -- LPS (10/09/2008). Se modifica la forma de obtener los impuestos por el Nuevo módulo de impuestos.
      BEGIN
         SELECT cempres INTO vcempres FROM codiram WHERE cramo = xcramo;
      EXCEPTION
         WHEN OTHERS THEN
            vcempres := NULL;
      END;

      -- BUG 20448 - 02/01/2012 - APD - Multimoneda
      v_cmultimon := NVL(pac_parametros.f_parempresa_n(vcempres,
                                                       'MULTIMONEDA'),
                         0);
      v_cmonprod  := pac_monedas.f_moneda_producto(psproduc);

      -- fin BUG 20448 - 02/01/2012 - APD
      -- Comentado (LPS 17/09/2008), para el nuevo módulo de impuestos.
      -- El IPS se aplica al recargo de fraccionamiento 0.- No, 1.- Si
      --xips_fracc := NVL (f_parinstalacion_n ('IPS_FRACC'), 1);
      -- Los impuestos: CLEA, arbitris se aplican sobre la prima bonificada o no
      --ximp_boni := NVL (f_parinstalacion_n ('IMP_BONI'), 0);
      -- La CLEA se aplica al recargo por fraccionamiento 0.- no, 1.- si
      --xclea_fracc := NVL (f_parinstalacion_n ('CLEA_FRACC'), 0);
      BEGIN
         SELECT NVL(cimpdgs, 0),
                NVL(cimpips, 0),
                NVL(cderreg, 0),
                NVL(cimparb, 0),
                NVL(cimpfng, 0),
                NVL(cimpcon, 0)
           INTO xcimpclea,
                xcimpips,
                xcderreg,
                xcimparb,
                xcimpfng,
                xcimpcons
           FROM garanpro
          WHERE cramo = xcramo
            AND cmodali = xcmodali
            AND ctipseg = xctipseg
            AND ccolect = xccolect
            AND cactivi = pcactivi
            AND cgarant = pcgarant;
      EXCEPTION
         WHEN OTHERS THEN
            BEGIN
               SELECT NVL(cimpdgs, 0),
                      NVL(cimpips, 0),
                      NVL(cderreg, 0),
                      NVL(cimparb, 0),
                      NVL(cimpfng, 0),
                      NVL(cimpcon, 0)
                 INTO xcimpclea,
                      xcimpips,
                      xcderreg,
                      xcimparb,
                      xcimpfng,
                      xcimpcons
                 FROM garanpro
                WHERE cramo = xcramo
                  AND cmodali = xcmodali
                  AND ctipseg = xctipseg
                  AND ccolect = xccolect
                  AND cactivi = 0
                  AND cgarant = pcgarant;
            EXCEPTION
               WHEN OTHERS THEN
                  --Garantía erronea pel producte
                  RETURN 141095;
            END;
      END;

      vpasexec := 5;

      --Cálculo del recargo por fraccionamiento de pago (si aplica para el producto).
      IF pcrecfra = 1
      THEN
         vnumerr := f_calcula_recargo_fracc(pmode,
                                            psseguro,
                                            pnriesgo,
                                            pfiniefe,
                                            xcramo,
                                            xcmodali,
                                            xctipseg,
                                            xccolect,
                                            pcactivi,
                                            pcgarant,
                                            xcforpag,
                                            piprianu,
                                            pidtocom,
                                            xirecfrac,
                                            pnmovimi);

         IF vnumerr <> 0
         THEN
            RAISE e_object_error;
         END IF;
      ELSE
         xirecfrac := 0;
      END IF;

      vpasexec := 7;

      IF pcconcep = 2
      THEN
         -- Calculamos el consorcio
         IF xcimpcons > 0
         THEN
            -- Comprobamos si la garantía calcula Concorcio
            vpasexec := 11;
            -- Obtenemos la fecha de vencimiento para el cálculo del consorcio

            -- Se asigna valor a vnmovimi.
            vnmovimi := NVL(pnmovimi, 1);
            verr     := f_obtenerdatos_consorcio(pmode,
                                                 psseguro,
                                                 pnmovimi,
                                                 pfiniefe,
                                                 xcforpag,
                                                 xcmotmov,
                                                 -- Falta de obtener desde la tarificación IAXIS (para calculos de regulariazaciones y capitales eventuales)
                                                 xcprorra,
                                                 vffinrec,
                                                 vtipo_movimiento,
                                                 valtarisc,
                                                 vcapieve,
                                                 vfacconsor);

            IF pmode = 'POL'
            THEN
               vfuncion := 'CAR';
            ELSE
               vfuncion := 'TAR';
            END IF;

            verr := f_consorcip(NULL,
                                psseguro,
                                pnriesgo,
                                pcgarant,
                                pfiniefe, -- ¿pfefecto?
                                vffinrec,
                                piprianu,
                                0,
                                --vtipo_movimiento, siempre 0, por pantalla anualizado
                                pnmovimi,
                                1,
                                valtarisc,
                                xnconsorci,
                                vcapieve,
                                pmode,
                                vfuncion);

            -- Obtenemos el valor del importe del consorcio.
            IF verr <> 0
            THEN
               -- Si da error la función.
               xcons := 0;
            ELSE
               xcons := NVL(xnconsorci, 0);
            END IF;

            oiconcep := NVL(xcons, 0);
         END IF;
      ELSIF pcconcep = 4
      THEN
         -- Calculamos el IPS
         IF xcimpips > 0
         THEN
            -- Comprobamos si la garantía calcula IPS
            vpasexec := 21;
            vctipcon := NULL;
            vnvalcon := NULL;
            vcfracci := NULL;
            vcbonifi := NULL;
            vcrecfra := NULL;
            verr     := f_concepto(4,
                                   vcempres,
                                   pfiniefe,
                                   xcforpag,
                                   xcramo,
                                   xcmodali,
                                   xctipseg,
                                   xccolect,
                                   pcactivi,
                                   pcgarant,
                                   vctipcon,
                                   vnvalcon,
                                   vcfracci,
                                   vcbonifi,
                                   vcrecfra,
                                   w_climit, -- Bug 10864.NMM.01/08/2009.
                                   v_cmonimp, -- BUG 18423: LCOL000 - Multimoneda
                                   vcderreg); -- Bug 0020314 - FAL - 29/11/2011

            IF vctipcon = 4
            THEN
               -- Para impuesto sobre capital (no sobre prima)
               verr := pac_impuestos.f_calcula_impuestocapital(psseguro,
                                                               pnmovimi,
                                                               pnriesgo,
                                                               pmode,
                                                               'CIMPIPS',
                                                               xicapital,
                                                               pcgarant);
            END IF;

            IF verr <> 0
            THEN
               -- Si da error la función.
               xips := 0;
            ELSE
               IF NVL(vcrecfra, 0) = 1
               THEN
                  tot_recfrac := xirecfrac;
               ELSE
                  tot_recfrac := 0;
               END IF;

               -- Bug 0020314 - FAL - 29/11/2011
               IF vcderreg = 1
               THEN
                  xderreg := f_calcul_derreg_por_impost(xcderreg,
                                                        vcempres,
                                                        psproduc,
                                                        pnmovimi,
                                                        pfiniefe,
                                                        xcforpag,
                                                        xcramo,
                                                        xcmodali,
                                                        xctipseg,
                                                        xccolect,
                                                        pcactivi,
                                                        pcgarant,
                                                        psseguro,
                                                        pnriesgo,
                                                        pmode,
                                                        xirecfrac,
                                                        piprianu,
                                                        pidtocom,
                                                        xcforpag);
               END IF;

               --Bug 24656-XVM-21/11/2012.Inicio
               IF vctipcon = 9 AND
                  xcimparb > 0
               THEN
                  xarb := f_arbitrio(xcderreg,
                                     vcempres,
                                     psproduc,
                                     pfiniefe,
                                     pcforpag,
                                     xcramo,
                                     xcmodali,
                                     xctipseg,
                                     xccolect,
                                     pcactivi,
                                     pcgarant,
                                     xirecfrac,
                                     psseguro,
                                     pnriesgo,
                                     pnmovimi,
                                     piprianu,
                                     pidtocom,
                                     pmode);
               ELSE
                  xarb := 0;
               END IF;

               --Bug 24656-XVM-21/11/2012.Final

               -- Fin Bug 0020314 - FAL - 29/11/2011
               -- Bug 0022964 - FAL - 19/07/2012
               IF pmode = 'POL'
               THEN
                  vfuncion := 'SEG';
               ELSE
                  vfuncion := 'EST';
               END IF;

               -- Fi Bug 0022964
               verr := pac_impuestos.f_calcula_impconcepto(vnvalcon,
                                                           piprianu,
                                                           piprianu,
                                                           pidtocom,
                                                           pidtocom,
                                                           NULL,
                                                           xicapital,
                                                           tot_recfrac,
                                                           NULL,
                                                           vctipcon,
                                                           xcforpag,
                                                           vcfracci,
                                                           vcbonifi,
                                                           vcrecfra,
                                                           xips,
                                                           xderreg,
                                                           vcderreg
                                                           -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                                          ,

                                                           -- Bug 0022964 - FAL - 19/07/2012
                                                           -- NULL, NULL, NULL, NULL, NULL,
                                                           NULL,
                                                           pfiniefe,
                                                           psseguro,
                                                           pnriesgo,
                                                           pcgarant,
                                                           -- Fi Bug 0022964
                                                           v_cmonprod,
                                                           vfuncion,
                                                           1,
                                                           NVL(xarb, 0)
                                                           -- Bug 0022964 - FAL - 19/07/2012
                                                           -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                                           );

               -- Fin Bug 0020314 - FAL - 29/11/2011 - Añadir derechos de regisro
               IF verr <> 0
               THEN
                  -- Si da error la función.
                  xips := 0;
               END IF;

               xips := f_round(NVL(xips, 0),
                               v_cmonimp,
                               NVL(pac_parametros.f_parempresa_n(vcempres,
                                                                 'REDONDEO_SRI'),
                                   0));
            END IF;
         END IF;

         oiconcep := f_round(NVL(xips, 0),
                             v_cmonimp,
                             NVL(pac_parametros.f_parempresa_n(vcempres,
                                                               'REDONDEO_SRI'),
                                 0));
      ELSIF pcconcep = 5
      THEN
         -- Calculamos el CLEA
         IF xcimpclea > 0
         THEN
            -- Comprobamos si la garantía calcula CLEA
            vpasexec := 31;
            vctipcon := NULL;
            vnvalcon := NULL;
            vcfracci := NULL;
            vcbonifi := NULL;
            vcrecfra := NULL;
            --
            verr := f_concepto(5,
                               vcempres,
                               pfiniefe,
                               xcforpag,
                               xcramo,
                               xcmodali,
                               xctipseg,
                               xccolect,
                               pcactivi,
                               pcgarant,
                               vctipcon,
                               vnvalcon,
                               vcfracci,
                               vcbonifi,
                               vcrecfra,
                               w_climit, -- Bug 10864.NMM.01/08/2009.
                               v_cmonimp, -- BUG 18423: LCOL000 - Multimoneda
                               vcderreg); -- Bug 0020314 - FAL - 29/11/2011

            IF vctipcon = 4
            THEN
               -- Para impuesto sobre capital (no sobre prima)
               verr := pac_impuestos.f_calcula_impuestocapital(psseguro,
                                                               pnmovimi,
                                                               pnriesgo,
                                                               pmode,
                                                               'CIMPCLEA',
                                                               xicapital,
                                                               pcgarant);
            END IF;

            IF verr <> 0
            THEN
               -- Si da error la función.
               xclea := 0;
            ELSE
               IF NVL(vcrecfra, 0) = 1
               THEN
                  tot_recfrac := xirecfrac;
               ELSE
                  tot_recfrac := 0;
               END IF;

               -- Bug 0022964 - FAL - 19/07/2012
               IF pmode = 'POL'
               THEN
                  vfuncion := 'SEG';
               ELSE
                  vfuncion := 'EST';
               END IF;

               -- Fi Bug 0022964
               verr := pac_impuestos.f_calcula_impconcepto(vnvalcon,
                                                           piprianu,
                                                           piprianu,
                                                           pidtocom,
                                                           pidtocom,
                                                           NULL,
                                                           xicapital,
                                                           tot_recfrac,
                                                           NULL,
                                                           vctipcon,
                                                           xcforpag,
                                                           vcfracci,
                                                           vcbonifi,
                                                           vcrecfra,
                                                           xclea
                                                           -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                                           -- Bug 0022964 - FAL - 19/07/2012
                                                           --                                                           , NULL, NULL, NULL, NULL, NULL,
                                                          ,
                                                           NULL,
                                                           NULL,
                                                           NULL,
                                                           pfiniefe,
                                                           psseguro,
                                                           pnriesgo,
                                                           pcgarant,

                                                           -- Fi Bug 0022964
                                                           v_cmonprod,
                                                           vfuncion
                                                           -- Bug 0022964 - FAL - 19/07/2012
                                                           -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                                           );

               IF verr <> 0
               THEN
                  -- Si da error la función.
                  xclea := 0;
               END IF;

               xclea := NVL(xclea, 0);
            END IF;
         END IF;

         oiconcep := f_round(NVL(xclea, 0),
                             v_cmonimp,
                             NVL(pac_parametros.f_parempresa_n(vcempres,
                                                               'REDONDEO_SRI'),
                                 0));
      ELSIF pcconcep = 6
      THEN
         -- Calculamos el los impuestos arbitrarios
         IF xcimparb > 0
         THEN
            -- Comprobamos si la garantía calcula ARB
            vpasexec := 41;
            vctipcon := NULL;
            vnvalcon := NULL;
            vcfracci := NULL;
            vcbonifi := NULL;
            vcrecfra := NULL;
            --
            verr := f_concepto(6,
                               vcempres,
                               pfiniefe,
                               xcforpag,
                               xcramo,
                               xcmodali,
                               xctipseg,
                               xccolect,
                               pcactivi,
                               pcgarant,
                               vctipcon,
                               vnvalcon,
                               vcfracci,
                               vcbonifi,
                               vcrecfra,
                               w_climit, -- Bug 10864.NMM.01/08/2009.
                               v_cmonimp, -- BUG 18423: LCOL000 - Multimoneda
                               vcderreg); -- Bug 0020314 - FAL - 29/11/2011

            IF vctipcon = 4
            THEN
               -- Para impuesto sobre capital (no sobre prima)
               verr := pac_impuestos.f_calcula_impuestocapital(psseguro,
                                                               pnmovimi,
                                                               pnriesgo,
                                                               pmode,
                                                               'CIMPARB',
                                                               xicapital,
                                                               pcgarant);
            END IF;

            IF verr <> 0
            THEN
               -- Si da error la función.
               xarb := 0;
            ELSE
               IF NVL(vcrecfra, 0) = 1
               THEN
                  tot_recfrac := xirecfrac;
               ELSE
                  tot_recfrac := 0;
               END IF;

               -- Bug 0020314 - FAL - 29/11/2011
               IF vcderreg = 1
               THEN
                  xderreg := f_calcul_derreg_por_impost(xcderreg,
                                                        vcempres,
                                                        psproduc,
                                                        pnmovimi,
                                                        pfiniefe,
                                                        xcforpag,
                                                        xcramo,
                                                        xcmodali,
                                                        xctipseg,
                                                        xccolect,
                                                        pcactivi,
                                                        pcgarant,
                                                        psseguro,
                                                        pnriesgo,
                                                        pmode,
                                                        xirecfrac,
                                                        piprianu,
                                                        pidtocom,
                                                        xcforpag);
               END IF;

               -- Fin Bug 0020314 - FAL - 29/11/2011

               -- Bug 0022964 - FAL - 19/07/2012
               IF pmode = 'POL'
               THEN
                  vfuncion := 'SEG';
               ELSE
                  vfuncion := 'EST';
               END IF;

               -- Fi Bug 0022964
               verr := pac_impuestos.f_calcula_impconcepto(vnvalcon,
                                                           piprianu,
                                                           piprianu,
                                                           pidtocom,
                                                           pidtocom,
                                                           NULL,
                                                           xicapital,
                                                           tot_recfrac,
                                                           NULL,
                                                           vctipcon,
                                                           xcforpag,
                                                           vcfracci,
                                                           vcbonifi,
                                                           vcrecfra,
                                                           xarb,
                                                           xderreg,
                                                           vcderreg
                                                           -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                                          ,

                                                           -- Bug 0022964 - FAL - 19/07/2012
                                                           NULL,
                                                           pfiniefe,
                                                           psseguro,
                                                           pnriesgo,
                                                           pcgarant,
                                                           -- Fi Bug 0022964
                                                           v_cmonprod,
                                                           vfuncion
                                                           -- Bug 0022964 - FAL - 19/07/2012
                                                           -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                                           );

               -- Fin Bug 0020314 - FAL - 29/11/2011 - Añadir derechos de regisro
               IF verr <> 0
               THEN
                  -- Si da error la función.
                  xarb := 0;
               END IF;

               xarb := NVL(xarb, 0);
            END IF;
         END IF;

         oiconcep := f_round(NVL(xarb, 0),
                             v_cmonimp,
                             NVL(pac_parametros.f_parempresa_n(vcempres,
                                                               'REDONDEO_SRI'),
                                 0));
      ELSIF pcconcep = 7
      THEN
         -- Calculamos el FNG
         IF xcimpfng > 0
         THEN
            -- Comprobamos si la garantía calcula FNG
            vpasexec := 51;
            vctipcon := NULL;
            vnvalcon := NULL;
            vcfracci := NULL;
            vcbonifi := NULL;
            vcrecfra := NULL;
            --
            verr := f_concepto(7,
                               vcempres,
                               pfiniefe,
                               xcforpag,
                               xcramo,
                               xcmodali,
                               xctipseg,
                               xccolect,
                               pcactivi,
                               pcgarant,
                               vctipcon,
                               vnvalcon,
                               vcfracci,
                               vcbonifi,
                               vcrecfra,
                               w_climit, -- Bug 10864.NMM.01/08/2009.
                               v_cmonimp, -- BUG 18423: LCOL000 - Multimoneda
                               vcderreg); -- Bug 0020314 - FAL - 29/11/2011

            IF vctipcon = 4
            THEN
               -- Para impuesto sobre capital (no sobre prima)
               verr := pac_impuestos.f_calcula_impuestocapital(psseguro,
                                                               pnmovimi,
                                                               pnriesgo,
                                                               pmode,
                                                               'CIMPFNG',
                                                               xicapital,
                                                               pcgarant);
            END IF;

            IF verr <> 0
            THEN
               -- Si da error la función.
               xfng := 0;
            ELSE
               IF NVL(vcrecfra, 0) = 1
               THEN
                  tot_recfrac := xirecfrac;
               ELSE
                  tot_recfrac := 0;
               END IF;

               -- Bug 0022964 - FAL - 19/07/2012
               IF pmode = 'POL'
               THEN
                  vfuncion := 'SEG';
               ELSE
                  vfuncion := 'EST';
               END IF;

               -- Fi Bug 0022964
               verr := pac_impuestos.f_calcula_impconcepto(vnvalcon,
                                                           piprianu,
                                                           piprianu,
                                                           pidtocom,
                                                           pidtocom,
                                                           NULL,
                                                           xicapital,
                                                           tot_recfrac,
                                                           NULL,
                                                           vctipcon,
                                                           xcforpag,
                                                           vcfracci,
                                                           vcbonifi,
                                                           vcrecfra,
                                                           xfng
                                                           -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                                          ,
                                                           -- Bug 0022964 - FAL - 19/07/2012
                                                           NULL,
                                                           NULL,
                                                           NULL,
                                                           pfiniefe,
                                                           psseguro,
                                                           pnriesgo,
                                                           pcgarant,

                                                           -- Fi Bug 0022964
                                                           v_cmonprod,
                                                           vfuncion
                                                           -- Bug 0022964 - FAL - 19/07/2012
                                                           -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                                           );

               IF verr <> 0
               THEN
                  -- Si da error la función.
                  xfng := 0;
               END IF;

               xfng := NVL(xfng, 0);
            END IF;
         END IF;

         oiconcep := NVL(xfng, 0);
      ELSIF pcconcep = 8
      THEN
         -- Calculamo el recargo por fraccionamiento
         --recuperamos v_cmonimp
         verr     := f_concepto(8,
                                vcempres,
                                pfiniefe,
                                xcforpag,
                                xcramo,
                                xcmodali,
                                xctipseg,
                                xccolect,
                                pcactivi,
                                pcgarant,
                                vctipcon,
                                vnvalcon,
                                vcfracci,
                                vcbonifi,
                                vcrecfra,
                                w_climit, -- Bug 10864.NMM.01/08/2009.
                                v_cmonimp, -- BUG 18423: LCOL000 - Multimoneda
                                vcderreg);
         oiconcep := f_round(NVL(xirecfrac, 0),
                             v_cmonimp,
                             NVL(pac_parametros.f_parempresa_n(vcempres,
                                                               'REDONDEO_SRI'),
                                 0));
         -- Bug 0019578 - FAL - 26/09/2011 - Cálculo derechos de registro
      ELSIF pcconcep = 14
      THEN
         -- Calculamo el recargo por fraccionamiento
         IF xcderreg > 0
         THEN
            -- Comprobamos si la garantía calcula Derechos de registro
            vpasexec := 61;
            vctipcon := NULL;
            vnvalcon := NULL;
            vcfracci := NULL;
            vcbonifi := NULL;
            vcrecfra := NULL;
            --

            -- Bug 19557 - APD - 14/11/2011 - de momento para Liberty, los gastos de
            -- expedicion se calculan de manera diferente que para el resto de empresas
            -- por eso se crea el parempresa 'MODO_CALC_GASTEXP'
            -- El importe de los gastos de expedicion sólo se debe calcular en el
            -- momento de la emisión ('GASTEXP_CALCULO' = 1 (indica que si se debe calcular
            -- el importe de los gastos de expedicion para el producto) y
            -- pnmovimi = 1.-Nueva produccion para que sólo se calcule en el momento
            -- de la emisión)
            verr := 0;

            IF NVL(pac_parametros.f_parempresa_n(vcempres,
                                                 'MODO_CALC_GASTEXP'),
                   0) = 1 AND
               (NVL(pac_parametros.f_parproducto_n(psproduc,
                                                   'GASTEXP_CALCULO'),
                    0) = 0 OR
                (NVL(pac_parametros.f_parproducto_n(psproduc,
                                                    'GASTEXP_CALCULO'),
                     0) IN (1, 2) AND pnmovimi <> 1))
            THEN
               verr := 1; -- para que no calcule los gastos de expedicion
            END IF;

            -- BUG 20671-  01/2012 - JRH  -  0020671: LCOL_T001-LCOL - UAT - TEC: Contrataci?n En migración no hay derechos de registro
            IF verr = 0
            THEN
               IF NVL(pac_parametros.f_parproducto_n(psproduc,
                                                     'GASTEXP_CALCULO'),
                      0) IN (1, 2)
               THEN
                  -- BUG 20671-  01/2012 - JRH  -  0020671: LCOL_T001-LCOL - UAT - TEC: Contrataci?n
                  IF pac_seguros.f_es_migracion(psseguro, 'EST', valor) = 0
                  THEN
                     BEGIN
                        -- QT s/n  no esta aplicando gastos de expedición en autos de migración .
                        -- 20/01/2015
                        IF pmode = 'EST'
                        THEN
                           SELECT cobjase
                             INTO vcobjase
                             FROM estseguros
                            WHERE sseguro = psseguro;
                        ELSE
                           SELECT cobjase
                             INTO vcobjase
                             FROM seguros
                            WHERE sseguro = psseguro;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           vcobjase := 0;
                     END;

                     IF valor <> 0 AND
                        vcobjase <> 5
                     THEN
                        verr := 1;
                        --  Si estamos en migración  no debe generar derechos de registro
                     END IF;
                  ELSE
                     --Error, difñicil que suceda, pero por si acaso hacemos un raise para que savuelva a la función anterior
                     p_tab_error(f_sysdate,
                                 f_user,
                                 'f_imprecibos.f_control_cderreg',
                                 1,
                                 'psseguro : ' || psseguro || ' EST : ' ||
                                 'EST',
                                 'Error en pac_tarifas cálculo derechos de registro:' ||
                                 valor);
                     RAISE e_object_error;
                  END IF;
               END IF;
            END IF;

            -- Fi BUG 20671-  01/2012 - JRH

            -- Fi BUG 20671-  01/2012 - JRH
            IF verr <> 0
            THEN
               -- Si verr <> 0 es pq no se quiere que se calculen los gastos de expedicion
               xderreg := 0;
            ELSE
               -- Fin Bug 19557 - APD - 14/11/2011
               verr := f_concepto(14,
                                  vcempres,
                                  pfiniefe,
                                  xcforpag,
                                  xcramo,
                                  xcmodali,
                                  xctipseg,
                                  xccolect,
                                  pcactivi,
                                  pcgarant,
                                  vctipcon,
                                  vnvalcon,
                                  vcfracci,
                                  vcbonifi,
                                  vcrecfra,
                                  w_climit, -- Bug 10864.NMM.01/08/2009.
                                  v_cmonimp, -- BUG 18423: LCOL000 - Multimoneda
                                  vcderreg); -- Bug 0020314 - FAL - 29/11/2011

               IF vctipcon = 4
               THEN
                  -- Para impuesto sobre capital (no sobre prima)
                  verr := pac_impuestos.f_calcula_impuestocapital(psseguro,
                                                                  pnmovimi,
                                                                  pnriesgo,
                                                                  pmode,
                                                                  'CDERREG',
                                                                  xicapital,
                                                                  pcgarant);
               END IF;

               IF verr <> 0
               THEN
                  -- Si da error la función.
                  xderreg := 0;
               ELSE
                  IF NVL(vcrecfra, 0) = 1
                  THEN
                     tot_recfrac := xirecfrac;
                  ELSE
                     tot_recfrac := 0;
                  END IF;

                  -- Bug 0022964 - FAL - 19/07/2012
                  IF pmode = 'POL'
                  THEN
                     vfuncion := 'SEG';
                  ELSE
                     vfuncion := 'EST';
                  END IF;

                  -- Fi Bug 0022964
                  verr := pac_impuestos.f_calcula_impconcepto(vnvalcon,
                                                              piprianu,
                                                              piprianu,
                                                              pidtocom,
                                                              pidtocom,
                                                              NULL,
                                                              xicapital,
                                                              tot_recfrac,
                                                              NULL,
                                                              vctipcon,
                                                              xcforpag,
                                                              vcfracci,
                                                              vcbonifi,
                                                              vcrecfra,
                                                              xderreg
                                                              -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                                             ,

                                                              -- Bug 0022964 - FAL - 19/07/2012
                                                              NULL,
                                                              NULL,
                                                              NULL,
                                                              pfiniefe,
                                                              psseguro,
                                                              pnriesgo,
                                                              pcgarant,

                                                              -- Fi Bug 0022964
                                                              v_cmonprod,
                                                              vfuncion
                                                              -- Bug 0022964 - FAL - 19/07/2012
                                                              -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                                              );

                  IF verr <> 0
                  THEN
                     -- Si da error la función.
                     xderreg := 0;
                  END IF;

                  xderreg := NVL(xderreg, 0);
               END IF;
            END IF;
         END IF;

         oiconcep := f_round(NVL(xderreg, 0),
                             v_cmonimp,
                             NVL(pac_parametros.f_parempresa_n(vcempres,
                                                               'REDONDEO_SRI'),
                                 0));
         -- Bug 23074 - APD - 02/08/2012 - se añade el cconcep = 86 (v.f. 27)
      ELSIF pcconcep = 86
      THEN
         -- IVA - Gastos de expedicion
         IF xcderreg > 0
         THEN
            -- Comprobamos si la garantía calcula Derechos de registro
            vpasexec := 61;
            vctipcon := NULL;
            vnvalcon := NULL;
            vcfracci := NULL;
            vcbonifi := NULL;
            vcrecfra := NULL;
            --

            -- Bug 19557 - APD - 14/11/2011 - de momento para Liberty, los gastos de
            -- expedicion se calculan de manera diferente que para el resto de empresas
            -- por eso se crea el parempresa 'MODO_CALC_GASTEXP'
            -- El importe de los gastos de expedicion sólo se debe calcular en el
            -- momento de la emisión ('GASTEXP_CALCULO' = 1 (indica que si se debe calcular
            -- el importe de los gastos de expedicion para el producto) y
            -- pnmovimi = 1.-Nueva produccion para que sólo se calcule en el momento
            -- de la emisión)
            verr := 0;

            IF NVL(pac_parametros.f_parempresa_n(vcempres,
                                                 'MODO_CALC_GASTEXP'),
                   0) = 1 AND
               (NVL(pac_parametros.f_parproducto_n(psproduc,
                                                   'GASTEXP_CALCULO'),
                    0) = 0 OR (NVL(pac_parametros.f_parproducto_n(psproduc,
                                                                  'GASTEXP_CALCULO'),
                                   0) = 1 AND pnmovimi <> 1))
            THEN
               verr := 1; -- para que no calcule los gastos de expedicion
            END IF;

            -- BUG 20671-  01/2012 - JRH  -  0020671: LCOL_T001-LCOL - UAT - TEC: Contrataci?n En migración no hay derechos de registro
            IF verr = 0
            THEN
               -- BUG 20671-  01/2012 - JRH  -  0020671: LCOL_T001-LCOL - UAT - TEC: Contrataci?n
               IF pac_seguros.f_es_migracion(psseguro, 'EST', valor) = 0
               THEN
                  -- QT s/n  no esta aplicando gastos de expedición en autos de migración .
                  -- Mail de esperanza. 20/01/2015
                  IF pmode = 'EST'
                  THEN
                     SELECT cobjase
                       INTO vcobjase
                       FROM estseguros
                      WHERE sseguro = psseguro;
                  ELSE
                     SELECT cobjase
                       INTO vcobjase
                       FROM seguros
                      WHERE sseguro = psseguro;
                  END IF;

                  IF valor <> 0 AND
                     vcobjase <> 5
                  THEN
                     verr := 1;
                     --  Si estamos en migración  no debe generar derechos de registro
                  END IF;
               ELSE
                  --Error, difñicil que suceda, pero por si acaso hacemos un raise para que savuelva a la función anterior
                  p_tab_error(f_sysdate,
                              f_user,
                              'f_imprecibos.f_control_cderreg',
                              1,
                              'psseguro : ' || psseguro || ' EST : ' ||
                              'EST',
                              'Error en pac_tarifas cálculo derechos de registro:' ||
                              valor);
                  RAISE e_object_error;
               END IF;
            END IF;

            -- Fi BUG 20671-  01/2012 - JRH

            -- Fi BUG 20671-  01/2012 - JRH
            IF verr <> 0
            THEN
               -- Si verr <> 0 es pq no se quiere que se calculen los gastos de expedicion
               xivaderreg := 0;
            ELSE
               -- Fin Bug 19557 - APD - 14/11/2011
               verr := f_concepto(86,
                                  vcempres,
                                  pfiniefe,
                                  xcforpag,
                                  xcramo,
                                  xcmodali,
                                  xctipseg,
                                  xccolect,
                                  pcactivi,
                                  pcgarant,
                                  vctipcon,
                                  vnvalcon,
                                  vcfracci,
                                  vcbonifi,
                                  vcrecfra,
                                  w_climit, -- Bug 10864.NMM.01/08/2009.
                                  v_cmonimp, -- BUG 18423: LCOL000 - Multimoneda
                                  vcderreg); -- Bug 0020314 - FAL - 29/11/2011

               IF vctipcon = 4
               THEN
                  -- Para impuesto sobre capital (no sobre prima)
                  verr := pac_impuestos.f_calcula_impuestocapital(psseguro,
                                                                  pnmovimi,
                                                                  pnriesgo,
                                                                  pmode,
                                                                  'CDERREG',
                                                                  xicapital,
                                                                  pcgarant);
               END IF;

               IF verr <> 0
               THEN
                  -- Si da error la función.
                  xderreg := 0;
               ELSE
                  IF NVL(vcrecfra, 0) = 1
                  THEN
                     tot_recfrac := xirecfrac;
                  ELSE
                     tot_recfrac := 0;
                  END IF;

                  -- Siempre se debe calcular el valor del concepto 14 para
                  -- pasarselo a pac_impuestos.f_calcula_impconcepto y así
                  -- devolver el valor del concepto 86
                  --IF vcderreg = 1 THEN
                  xderreg := f_calcul_derreg_por_impost(xcderreg,
                                                        vcempres,
                                                        psproduc,
                                                        pnmovimi,
                                                        pfiniefe,
                                                        xcforpag,
                                                        xcramo,
                                                        xcmodali,
                                                        xctipseg,
                                                        xccolect,
                                                        pcactivi,
                                                        pcgarant,
                                                        psseguro,
                                                        pnriesgo,
                                                        pmode,
                                                        xirecfrac,
                                                        piprianu,
                                                        pidtocom,
                                                        xcforpag);

                  --END IF;

                  -- Bug 0022964 - FAL - 19/07/2012
                  IF pmode = 'POL'
                  THEN
                     vfuncion := 'SEG';
                  ELSE
                     vfuncion := 'EST';
                  END IF;

                  -- Fi Bug 0022964
                  verr := pac_impuestos.f_calcula_impconcepto(vnvalcon,
                                                              piprianu,
                                                              piprianu,
                                                              pidtocom,
                                                              pidtocom,
                                                              NULL,
                                                              xicapital,
                                                              tot_recfrac,
                                                              NULL,
                                                              vctipcon,
                                                              xcforpag,
                                                              vcfracci,
                                                              vcbonifi,
                                                              vcrecfra,
                                                              xivaderreg
                                                              -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                                             ,

                                                              -- Bug 0022964 - FAL - 19/07/2012
                                                              NULL,
                                                              xderreg,
                                                              NULL,
                                                              pfiniefe,
                                                              psseguro,
                                                              pnriesgo,
                                                              pcgarant,

                                                              -- Fi Bug 0022964
                                                              v_cmonprod,
                                                              vfuncion
                                                              -- Bug 0022964 - FAL - 19/07/2012
                                                              -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                                              );

                  IF verr <> 0
                  THEN
                     -- Si da error la función.
                     xivaderreg := 0;
                  END IF;

                  xivaderreg := NVL(xivaderreg, 0);
               END IF;
            END IF;
         END IF;

         oiconcep := f_round(NVL(xivaderreg, 0),
                             v_cmonimp,
                             NVL(pac_parametros.f_parempresa_n(vcempres,
                                                               'REDONDEO_SRI'),
                                 0));
      END IF;

      -- Fi Bug 0019578 - FAL - 26/09/2011 - Cálculo derechos de registro

      -- Bug 20448 - APD - 02/01/2012 - Si la divisa del producto es diferente a
      -- la divisa del impuesto, calcular el contravalor y pasar de la divisa del
      -- impuesto a la divisa del producto
      IF v_cmonprod <> v_cmonimp AND
         v_cmultimon = 1
      THEN
         vfcambio := pac_eco_tipocambio.f_fecha_max_cambio(pac_monedas.f_cmoneda_t(v_cmonimp),
                                                           pac_monedas.f_cmoneda_t(v_cmonprod));

         IF vfcambio IS NULL
         THEN
            RETURN 9902592;
            -- No se ha encontrado el tipo de cambio entre monedas
         END IF;

         vitasa   := pac_eco_tipocambio.f_cambio(pac_monedas.f_cmoneda_t(v_cmonimp),
                                                 pac_monedas.f_cmoneda_t(v_cmonprod),
                                                 vfcambio);
         oiconcep := pac_monedas.f_round(oiconcep * vitasa,
                                         v_cmonprod,
                                         NVL(pac_parametros.f_parempresa_n(vcempres,
                                                                           'REDONDEO_SRI'),
                                             0));
      END IF;

      -- fin Bug 20448 - APD - 02/01/2012
      -- BUG 0018081 - 04-04-11 - JMF
      --oiconcep := f_round_forpag(oiconcep, xcforpag, NULL, psproduc);
      -- JLB - I - BUG 18423 COjo la moneda del producto
      -- BUG 0022787 - 03/10/12 - JMF -->> oiconcep := f_round_forpag(oiconcep, xcforpag, v_cmonprod, psproduc);
      -- JLB - F - BUG 18423 COjo la moneda del producto
      /* HPM - INICIO-  BUG - 24179*/

      -- ini BUG 0022787 - 03/10/12 - JMF
      DECLARE
         v_pctipcon NUMBER;
         v_pnvalcon NUMBER;
         v_pcfracci NUMBER;
         v_pcbonifi NUMBER;
         v_pcrecfra NUMBER;
         v_pclimit  NUMBER;
         v_pcmoneda NUMBER;
         v_pcderreg NUMBER;
      BEGIN
         -- Buscar información de impuestos del concepto.
         verr     := f_concepto(pcconcep,
                                vcempres,
                                pfiniefe,
                                xcforpag,
                                xcramo,
                                xcmodali,
                                xctipseg,
                                xccolect,
                                pcactivi,
                                pcgarant,
                                v_pctipcon,
                                v_pnvalcon,
                                v_pcfracci,
                                v_pcbonifi,
                                v_pcrecfra,
                                v_pclimit,
                                v_pcmoneda,
                                v_pcderreg);
         oiconcep := f_round(oiconcep,
                             v_pcmoneda,
                             NVL(pac_parametros.f_parempresa_n(vcempres,
                                                               'REDONDEO_SRI'),
                                 0));
         /* IF verr = 0
            AND NVL(v_pcrecfra, -1) = 0 THEN
            -- Si tiene impuestos y no se fracciona (todo va al primer recibo) redondeamos con la moneda.
            oiconcep := f_round(oiconcep, v_pcmoneda);
         ELSE
            -- Para el resto de casos como siempre, redondeamos en funcion de la forma de pago.
            oiconcep := f_round_forpag(oiconcep, xcforpag, v_cmonprod, psproduc);
         END IF;*/
      END;

      -- fin BUG 0022787 - 03/10/12 - JMF*/

      -- HPM - FIN-  BUG - 24179
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 101901;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'Error al llamar procedimiento o función - numerr: ' ||
                     vnumerr);
         RETURN 180722;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 180722;
   END f_calcula_concepto;

   /***********************************************************************
      Càlcul del concepte de rebut a aplicar en funció d'una determinada prima anual, forma de pagament i producte.
      param in psseguro    : código del seguro
      param in pmode       : modo
      param in pcconcep    : código del concepto que se desea calcular (VF 27)
      param in pcrecfra    : indica si existe recargo por fraccionamiento o no
      param in pcgarant    : código de la garantia
      param in piprianu    : prima anual
      param out oiconcep   : importe del concepto
      return               : 0/1 -> Ok/Error
   ***********************************************************************/
   FUNCTION f_calcula_concepto(psseguro IN NUMBER,
                               pnriesgo IN NUMBER,
                               pnmovimi IN NUMBER,
                               pmode    IN VARCHAR2,
                               pcconcep IN NUMBER,
                               pcrecfra IN NUMBER,
                               pcgarant IN NUMBER,
                               piprianu IN NUMBER,
                               pidtocom IN NUMBER,
                               oiconcep OUT NUMBER) RETURN NUMBER IS
      e_object_error EXCEPTION;
      e_param_error  EXCEPTION;
      vobjectname tab_error.tdescrip%TYPE;
      vparam      tab_error.tdescrip%TYPE;
      vpasexec    NUMBER(8);
      vnumerr     NUMBER(8);
      vfefecto    seguros.fefecto%TYPE;
      vfcaranu    seguros.fcaranu%TYPE;
      vsproduc    seguros.sproduc%TYPE;
      vcactivi    seguros.cactivi%TYPE;
      vcforpag    seguros.cforpag%TYPE;
      viconcep    NUMBER;
      nmovren     movseguro.nmovimi%TYPE; --Bug  10709 - ICV
      vvariable   NUMBER; -- Bug.14345:04/05/2010:ASN
   BEGIN
      oiconcep    := 0;
      vobjectname := 'PAC_TARIFAS.f_calcula_concepto';
      vparam      := 'parámetros - psseguro: ' || psseguro || ' - pmode: ' ||
                     pmode || ' cconcep: ' || pcconcep || ' - pcrecfra: ' ||
                     pcrecfra || ' - pcgarant: ' || pcgarant ||
                     ' - piprianu: ' || piprianu || ' - pidtocom: ' ||
                     pidtocom;
      vnumerr     := 0;
      vpasexec    := 1;

      --Comprovació dels parámetres d'entrada
      IF psseguro IS NULL OR
         pmode IS NULL OR
         pcconcep IS NULL OR
         pcrecfra IS NULL OR
         pcgarant IS NULL OR
         piprianu IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      -- Bug 20488 - APD - 28/12/2011 - se sustituye todo el codigo para buscar el valor
      -- de las variables por la funcion pac_tarifas.f_param_concepto (el mismo codigo que
      -- habia antes esta ahora en la funcion)
      vnumerr := pac_tarifas.f_param_concepto(psseguro,
                                              pnriesgo,
                                              pnmovimi,
                                              pmode,
                                              pcconcep,
                                              pcrecfra,
                                              pcgarant,
                                              piprianu,
                                              pidtocom,
                                              NULL,
                                              vfefecto,
                                              vfcaranu,
                                              vsproduc,
                                              vcactivi,
                                              vcforpag);

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      -- fin Bug 20488 - APD - 28/12/2011
      vpasexec := 5;
      vnumerr  := f_calcula_concepto(pcconcep,
                                     psseguro,
                                     pnriesgo,
                                     pnmovimi,
                                     vfefecto,
                                     vfcaranu,
                                     pcrecfra,
                                     vsproduc,
                                     vcactivi,
                                     pcgarant,
                                     vcforpag,
                                     piprianu,
                                     pidtocom,
                                     pmode,
                                     viconcep);

      IF vnumerr <> 0
      THEN
         RAISE e_object_error;
      END IF;

      oiconcep := viconcep;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 101901;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'Error al llamar procedimiento o función - numerr: ' ||
                     vnumerr);
         RETURN 180722;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 180722;
   END f_calcula_concepto;

   /***********************************************************************
      Ens retorna informació anual de la pòlissa
      param in psseguro    : codi intern
      param in P_CONCEPTE  : Concepte que es desitja mostrar. Pot ser:
                             'PR_ANUAL_NETA' ---> Prima Anual Neta (iprianu de garanseg)
                             'PR_ANUAL'      ---> Prima Anual Neta + Consorci + IPS + CLEA
                             'CONSOR'        ---> Rec. Consorci
                             'IPS'           ---> Rec. IPS
                             'CLEA'          ---> Rec. CLEA/DGS
      param in P_MODE      : 'POL' / 'EST'
      return               : Concepte anual
   ***********************************************************************/
   FUNCTION f_importes_anuales(p_sseguro  IN NUMBER,
                               p_concepte IN VARCHAR2,
                               p_mode     IN VARCHAR2 DEFAULT 'POL',
                               p_nmovimi  IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      v_crecfra       NUMBER;
      v_err           NUMBER;
      v_aux           NUMBER := 0;
      v_pr_anual_neta NUMBER := 0;
      v_iconsor       NUMBER := 0;
      v_iips          NUMBER := 0;
      v_clea          NUMBER := 0;
      v_fracciona     NUMBER := 0;
      v_resultat      NUMBER;

      CURSOR cgarantias(pnseguro     NUMBER,
                        pnmovimiento NUMBER,
                        psmodo       VARCHAR2) IS
         SELECT sseguro,
                cgarant,
                iprianu,
                nriesgo,
                nmovimi,
                idtocom
           FROM garanseg g
          WHERE nmovimi = CASE
                   WHEN pnmovimiento IS NULL THEN
                    (SELECT nmovimi
                       FROM garanseg
                      WHERE sseguro = pnseguro
                        AND ffinefe IS NULL
                        AND ROWNUM = 1)
                   ELSE
                    pnmovimiento
                END
            AND g.sseguro = pnseguro
            AND NVL(psmodo, 'POL') = 'POL'
         UNION
         SELECT sseguro,
                cgarant,
                iprianu,
                nriesgo,
                nmovimi,
                idtocom
           FROM estgaranseg g
          WHERE nmovimi = CASE
                   WHEN pnmovimiento IS NULL THEN
                    (SELECT nmovimi
                       FROM estgaranseg
                      WHERE sseguro = pnseguro
                        AND ffinefe IS NULL
                        AND ROWNUM = 1)
                   ELSE
                    pnmovimiento
                END
            AND g.sseguro = pnseguro
            AND NVL(psmodo, 'POL') = 'EST';
   BEGIN
      IF NVL(p_mode, 'POL') = 'POL'
      THEN
         SELECT NVL(crecfra, 0)
           INTO v_crecfra
           FROM seguros
          WHERE sseguro = p_sseguro;
      ELSE
         SELECT NVL(crecfra, 0)
           INTO v_crecfra
           FROM estseguros
          WHERE sseguro = p_sseguro;
      END IF;

      /*
      FOR c IN (SELECT cgarant, iprianu, nriesgo, nmovimi, idtocom
                  FROM garanseg g
                 WHERE g.ffinefe IS NULL
                   AND g.sseguro = p_sseguro
                   AND NVL(p_mode, 'POL') = 'POL'
                UNION
                SELECT cgarant, iprianu, nriesgo, nmovimi, idtocom
                  FROM estgaranseg g
                 WHERE g.ffinefe IS NULL
                   AND g.sseguro = p_sseguro
                   AND NVL(p_mode, 'POL') = 'EST') LOOP
      */
      FOR c IN cgarantias(p_sseguro, p_nmovimi, p_mode)
      LOOP
         v_pr_anual_neta := v_pr_anual_neta + NVL(c.iprianu, 0);

         IF p_concepte IN ('PR_ANUAL', 'CONSOR')
         THEN
            v_err := pac_tarifas.f_calcula_concepto(p_sseguro,
                                                    c.nriesgo,
                                                    c.nmovimi,
                                                    NVL(p_mode, 'POL'),
                                                    2,
                                                    v_crecfra,
                                                    c.cgarant,
                                                    c.iprianu,
                                                    c.idtocom,
                                                    v_aux);

            IF v_err = 0
            THEN
               v_iconsor := v_iconsor + NVL(v_aux, 0);
            END IF;
         END IF;

         IF p_concepte IN ('PR_ANUAL', 'IPS')
         THEN
            v_err := pac_tarifas.f_calcula_concepto(p_sseguro,
                                                    c.nriesgo,
                                                    c.nmovimi,
                                                    NVL(p_mode, 'POL'),
                                                    4,
                                                    v_crecfra,
                                                    c.cgarant,
                                                    c.iprianu,
                                                    c.idtocom,
                                                    v_aux);

            IF v_err = 0
            THEN
               v_iips := v_iips + NVL(v_aux, 0);
            END IF;
         END IF;

         IF p_concepte IN ('PR_ANUAL', 'CLEA')
         THEN
            v_err := pac_tarifas.f_calcula_concepto(p_sseguro,
                                                    c.nriesgo,
                                                    c.nmovimi,
                                                    NVL(p_mode, 'POL'),
                                                    5,
                                                    v_crecfra,
                                                    c.cgarant,
                                                    c.iprianu,
                                                    c.idtocom,
                                                    v_aux);

            IF v_err = 0
            THEN
               v_clea := v_clea + NVL(v_aux, 0);
            END IF;
         END IF;

         IF p_concepte = 'FRACC'
         THEN
            v_err := pac_tarifas.f_calcula_concepto(p_sseguro,
                                                    c.nriesgo,
                                                    c.nmovimi,
                                                    NVL(p_mode, 'POL'),
                                                    8,
                                                    v_crecfra,
                                                    c.cgarant,
                                                    c.iprianu,
                                                    c.idtocom,
                                                    v_aux);

            IF v_err = 0
            THEN
               v_fracciona := v_fracciona + NVL(v_aux, 0);
            END IF;
         END IF;
      END LOOP;

      IF p_concepte = 'PR_ANUAL_NETA'
      THEN
         v_resultat := v_pr_anual_neta;
      ELSIF p_concepte = 'PR_ANUAL'
      THEN
         v_resultat := v_pr_anual_neta + v_iconsor + v_iips + v_clea;
      ELSIF p_concepte = 'CONSOR'
      THEN
         v_resultat := v_iconsor;
      ELSIF p_concepte = 'IPS'
      THEN
         v_resultat := v_iips;
      ELSIF p_concepte = 'CLEA'
      THEN
         v_resultat := v_clea;
      ELSIF p_concepte = 'FRACC'
      THEN
         v_resultat := v_fracciona;
      END IF;

      RETURN(v_resultat);
   END f_importes_anuales;

   -- Bug 18712 - FAL - 11-04-2011
   /***********************************************************************
      Ens retorna informació anual de la pòlissa
      param in psseguro    : codi intern
      param in P_CONCEPTE  : Concepte que es desitja mostrar. Pot ser:
                             'PR_ANUAL_NETA' ---> Prima Anual Neta (iprianu de garanseg)
                             'PR_ANUAL'      ---> Prima Anual Neta + Consorci + IPS + CLEA
                             'CONSOR'        ---> Rec. Consorci
                             'IPS'           ---> Rec. IPS
                             'CLEA'          ---> Rec. CLEA/DGS
                             'FRACC'         ---> Rec. Fraccionament
      param in P_NRIESGO   :  codi risc
      param in P_MODE      : 'POL' / 'EST'
      return               : Concepte anual
   ***********************************************************************/
   FUNCTION f_importes_anuales_riesgo(p_sseguro  IN NUMBER,
                                      p_concepte IN VARCHAR2,
                                      p_nriesgo  IN NUMBER,
                                      p_mode     IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER IS
      v_crecfra       NUMBER;
      v_err           NUMBER;
      v_aux           NUMBER := 0;
      v_pr_anual_neta NUMBER := 0;
      v_iconsor       NUMBER := 0;
      v_iips          NUMBER := 0;
      v_clea          NUMBER := 0;
      v_fracciona     NUMBER := 0;
      v_resultat      NUMBER;
      v_sproduc       seguros.sproduc%TYPE;
      v_cactivi       seguros.cactivi%TYPE;
   BEGIN
      IF NVL(p_mode, 'POL') = 'POL'
      THEN
         SELECT NVL(crecfra, 0),
                sproduc,
                cactivi
           INTO v_crecfra,
                v_sproduc,
                v_cactivi
           FROM seguros
          WHERE sseguro = p_sseguro;
      ELSE
         SELECT NVL(crecfra, 0),
                sproduc,
                cactivi
           INTO v_crecfra,
                v_sproduc,
                v_cactivi
           FROM estseguros
          WHERE sseguro = p_sseguro;
      END IF;

      FOR c IN (SELECT cgarant,
                       iprianu,
                       nriesgo,
                       nmovimi,
                       idtocom,
                       finiefe
                  FROM garanseg g
                 WHERE g.ffinefe IS NULL
                   AND g.sseguro = p_sseguro
                   AND g.nriesgo = p_nriesgo
                   AND NVL(p_mode, 'POL') = 'POL'
                UNION
                SELECT cgarant,
                       iprianu,
                       nriesgo,
                       nmovimi,
                       idtocom,
                       finiefe
                  FROM estgaranseg g
                 WHERE g.ffinefe IS NULL
                   AND g.sseguro = p_sseguro
                   AND g.nriesgo = p_nriesgo
                   AND NVL(p_mode, 'POL') = 'EST')
      LOOP
         v_pr_anual_neta := v_pr_anual_neta + NVL(c.iprianu, 0);

         IF p_concepte IN ('PR_ANUAL', 'CONSOR')
         THEN
            v_err := pac_tarifas.f_calcula_concepto(p_sseguro,
                                                    c.nriesgo,
                                                    c.nmovimi,
                                                    NVL(p_mode, 'POL'),
                                                    2,
                                                    v_crecfra,
                                                    c.cgarant,
                                                    c.iprianu,
                                                    c.idtocom,
                                                    v_aux);

            IF v_err = 0
            THEN
               v_iconsor := v_iconsor + NVL(v_aux, 0);
            END IF;
         END IF;

         IF p_concepte IN ('PR_ANUAL', 'IPS')
         THEN
            v_err := pac_tarifas.f_calcula_concepto(p_sseguro,
                                                    c.nriesgo,
                                                    c.nmovimi,
                                                    NVL(p_mode, 'POL'),
                                                    4,
                                                    v_crecfra,
                                                    c.cgarant,
                                                    c.iprianu,
                                                    c.idtocom,
                                                    v_aux);

            IF v_err = 0
            THEN
               v_iips := v_iips + NVL(v_aux, 0);
            END IF;
         END IF;

         IF p_concepte IN ('PR_ANUAL', 'CLEA')
         THEN
            v_err := pac_tarifas.f_calcula_concepto(p_sseguro,
                                                    c.nriesgo,
                                                    c.nmovimi,
                                                    NVL(p_mode, 'POL'),
                                                    5,
                                                    v_crecfra,
                                                    c.cgarant,
                                                    c.iprianu,
                                                    c.idtocom,
                                                    v_aux);

            IF v_err = 0
            THEN
               v_clea := v_clea + NVL(v_aux, 0);
            END IF;
         END IF;

         IF p_concepte = 'FRACC'
         THEN
            v_err := pac_tarifas.f_calcula_concepto(p_sseguro,
                                                    c.nriesgo,
                                                    c.nmovimi,
                                                    NVL(p_mode, 'POL'),
                                                    8,
                                                    v_crecfra,
                                                    c.cgarant,
                                                    c.iprianu,
                                                    c.idtocom,
                                                    v_aux);

            IF v_err = 0
            THEN
               v_fracciona := v_fracciona + NVL(v_aux, 0);
            END IF;
         END IF;
      END LOOP;

      IF p_concepte = 'PR_ANUAL_NETA'
      THEN
         v_resultat := v_pr_anual_neta;
      ELSIF p_concepte = 'PR_ANUAL'
      THEN
         v_resultat := v_pr_anual_neta + v_iconsor + v_iips + v_clea;
      ELSIF p_concepte = 'CONSOR'
      THEN
         v_resultat := v_iconsor;
      ELSIF p_concepte = 'IPS'
      THEN
         v_resultat := v_iips;
      ELSIF p_concepte = 'CLEA'
      THEN
         v_resultat := v_clea;
      ELSIF p_concepte = 'FRACC'
      THEN
         v_resultat := v_fracciona;
      END IF;

      RETURN(v_resultat);
   END f_importes_anuales_riesgo;

   -- Fi Bug 18712

   /***********************************************************************
      Funcion que devuelve algunos parametros (valores) necesarios para calcular
      el importe del concepto
      param in psseguro    : código del seguro
      param in pmode       : modo
      param in pcconcep    : código del concepto que se desea calcular (VF 27)
      param in pcrecfra    : indica si existe recargo por fraccionamiento o no
      param in pcgarant    : código de la garantia
      param in piprianu    : prima anual
      param in piconcep   : importe del concepto
      param out ofefecto : fecha inicio efecto de la cobertura
      param out ofcaranu : fecha fin efecto de la cobertura
      param out osproduc : identificador del producto
      param out ocactivi : codigo de la actividad
      param out ocforpag : forma de pago del seguro
      return               : importe del concepto dividido entre la forma de pago si aplica (segun imprec.cfracci)
   ***********************************************************************/
   -- Bug 20448 - APD - 28/12/2011 - se crea la funcion
   FUNCTION f_param_concepto(psseguro IN NUMBER,
                             pnriesgo IN NUMBER,
                             pnmovimi IN NUMBER,
                             pmode    IN VARCHAR2,
                             pcconcep IN NUMBER,
                             pcrecfra IN NUMBER,
                             pcgarant IN NUMBER,
                             piprianu IN NUMBER,
                             pidtocom IN NUMBER,
                             piconcep IN NUMBER,
                             ofefecto OUT DATE,
                             ofcaranu OUT DATE,
                             osproduc OUT NUMBER,
                             ocactivi OUT NUMBER,
                             ocforpag OUT NUMBER) RETURN NUMBER IS
      e_object_error EXCEPTION;
      e_param_error  EXCEPTION;
      vobjectname tab_error.tdescrip%TYPE;
      vparam      tab_error.tdescrip%TYPE;
      vpasexec    NUMBER(8);
      vnumerr     NUMBER(8);
      vfefecto    seguros.fefecto%TYPE;
      vfcaranu    seguros.fcaranu%TYPE;
      vsproduc    seguros.sproduc%TYPE;
      vcactivi    seguros.cactivi%TYPE;
      vcforpag    seguros.cforpag%TYPE;
      nmovren     movseguro.nmovimi%TYPE; --Bug  10709 - ICV
      vvariable   NUMBER; -- Bug.14345:04/05/2010:ASN
   BEGIN
      vobjectname := 'pac_tarifas.f_param_concepto';
      vparam      := 'parámetros - psseguro: ' || psseguro || ' - pmode: ' ||
                     pmode || ' cconcep: ' || pcconcep || ' - pcrecfra: ' ||
                     pcrecfra || ' - pcgarant: ' || pcgarant ||
                     ' - piprianu: ' || piprianu || ' - pidtocom: ' ||
                     pidtocom || ' - piconcep: ' || piconcep;
      vnumerr     := 0;
      vpasexec    := 1;

      --Comprovació dels parámetres d'entrada
      IF psseguro IS NULL OR
         pmode IS NULL OR
         pcconcep IS NULL OR
         pcrecfra IS NULL OR
         pcgarant IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      IF pmode = 'EST'
      THEN
         vpasexec := 2;

         SELECT e.fefecto,
                e.fcaranu,
                e.sproduc,
                e.cactivi,
                e.cforpag
           INTO vfefecto,
                vfcaranu,
                vsproduc,
                vcactivi,
                vcforpag
           FROM estseguros e
          WHERE e.sseguro = psseguro;

         vvariable := NVL(pac_parametros.f_parproducto_n(vsproduc,
                                                         'FECHA_IMPUESTOS'),
                          0); -- bug.14345
      ELSE
         vpasexec := 3;

         -- Bug.14345:04/05/2010:ASN.ini
         -- En el caso de tabla real buscamos la fec. efecto del movimiento
         -- si no llega o no se encuentra devolvemos la fecha de efecto del seguro como ya se hacía
         /*
         SELECT s.fefecto, s.fcaranu, s.sproduc, s.cactivi, s.cforpag
           INTO vfefecto, vfcaranu, vsproduc, vcactivi, vcforpag
            FROM seguros s
           WHERE s.sseguro = psseguro;
         */
         SELECT s.sproduc
           INTO vsproduc
           FROM seguros s
          WHERE s.sseguro = psseguro;

         vvariable := NVL(pac_parametros.f_parproducto_n(vsproduc,
                                                         'FECHA_IMPUESTOS'),
                          0);

         BEGIN
            IF pnmovimi IS NOT NULL AND
               vvariable <> 2
            THEN
               SELECT m.fefecto,
                      s.fcaranu,
                      s.cactivi,
                      s.cforpag
                 INTO vfefecto,
                      vfcaranu,
                      vcactivi,
                      vcforpag
                 FROM seguros   s,
                      movseguro m
                WHERE s.sseguro = psseguro
                  AND m.sseguro = s.sseguro
                  AND m.nmovimi = pnmovimi;
            ELSE
               SELECT s.fefecto,
                      s.fcaranu,
                      s.cactivi,
                      s.cforpag
                 INTO vfefecto,
                      vfcaranu,
                      vcactivi,
                      vcforpag
                 FROM seguros s
                WHERE s.sseguro = psseguro;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               SELECT s.fefecto,
                      s.fcaranu,
                      s.cactivi,
                      s.cforpag
                 INTO vfefecto,
                      vfcaranu,
                      vcactivi,
                      vcforpag
                 FROM seguros s
                WHERE s.sseguro = psseguro;
         END;

         vpasexec := 4;

         /*
         --Bug.: 10709 - ICV - 16/07/09 - Se elige la fecha de impuestos dependiendo de parametro.
         --Si no es la fecha de última renovación en este caso solo puede ser la fecha de efecto pol, no se controla fecha efecto recibo.
         IF pac_parametros.f_parproducto_n(vsproduc, 'FECHA_IMPUESTOS') = 0 THEN   --fecha ult renov.
            vnumerr := f_ultrenova(psseguro, vfefecto, vfefecto, nmovren);
               IF vnumerr <> 0 THEN
                  RAISE e_object_error;
               END IF;
            END IF;
         */
         IF vvariable = 0
         THEN
            --fecha ult renov.
            vnumerr := f_ultrenova(psseguro, vfefecto, vfefecto, nmovren);

            IF vnumerr <> 0
            THEN
               RAISE e_object_error;
            END IF;
         ELSIF vvariable = 1
         THEN
            vfefecto := f_sysdate;
         END IF;
         -- Bug.14345:04/05/2010:ASN.fin
      END IF;

      ofefecto := vfefecto;
      ofcaranu := vfcaranu;
      osproduc := vsproduc;
      ocactivi := vcactivi;
      ocforpag := vcforpag;
      vpasexec := 5;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 101901;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'Error al llamar procedimiento o función - numerr: ' ||
                     vnumerr);
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 140999;
   END f_param_concepto;

   /***********************************************************************
      Funcion que devuelve informada la tabla de conceptos tregconcep para un campo de GARANFORMULA
      param in psproduc    : código del producto
      param in pcactivi    : Actividad
      param in pcgarant    : codigo de la garantia
      param in pccampo     : campo de garanformula
      param in pssesion    : secuencia de la sesion
      param in/out ptregconcep : tabla de conceptos
      return               : 0 (todo Ok); num_err (si hay algún error)
   ***********************************************************************/
   -- Bug 21121 - APD - 22/02/2012 - se crea la funcion
   FUNCTION f_dettarifar(psproduc           IN NUMBER,
                         pcactivi           IN NUMBER,
                         pcgarant           IN NUMBER,
                         pccampo            IN VARCHAR2,
                         psesion            IN NUMBER,
                         pcont              IN NUMBER,
                         parms_transitorios IN pac_parm_tarifas.parms_transitorios_tabtyb,
                         ptregconcep        IN OUT pac_parm_tarifas.tregconcep_tabtyp)
      RETURN NUMBER IS
      e_object_error EXCEPTION;
      e_param_error  EXCEPTION;
      vobjectname tab_error.tdescrip%TYPE;
      vparam      tab_error.tdescrip%TYPE;
      vparam1     tab_error.tdescrip%TYPE;
      vpasexec    NUMBER(8);
      vnumerr     NUMBER(8);
      formula     sgt_formulas.formula%TYPE;
      valor       NUMBER;
      salir EXCEPTION;
      vcont_concep NUMBER;
   BEGIN
      vobjectname := 'pac_tarifas.f_dettarifar';
      vparam      := 'parámetros - psproduc: ' || psproduc ||
                     ' - pcactivi: ' || pcactivi || ' pccampo: ' || pccampo ||
                     ' - psesion: ' || psesion;
      vparam1     := vparam;
      vnumerr     := 0;
      vpasexec    := 1;

      --Comprovació dels parámetres d'entrada
      IF psproduc IS NULL OR
         pcactivi IS NULL OR
         pcgarant IS NULL OR
         pccampo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      FOR reg IN (SELECT sproduc,
                         cactivi,
                         cgarant,
                         ccampo,
                         cconcep,
                         norden,
                         clave,
                         clave2
                    FROM detgaranformula
                   WHERE sproduc = psproduc
                     AND cactivi = pcactivi
                     AND cgarant = pcgarant
                     AND ccampo = pccampo
                  UNION
                  SELECT sproduc,
                         cactivi,
                         cgarant,
                         ccampo,
                         cconcep,
                         norden,
                         clave,
                         clave2
                    FROM detgaranformula
                   WHERE sproduc = psproduc
                     AND cactivi = 0
                     AND cgarant = pcgarant
                     AND ccampo = pccampo
                     AND NOT EXISTS (SELECT 1
                            FROM detgaranformula
                           WHERE sproduc = psproduc
                             AND cactivi = pcactivi
                             AND cgarant = pcgarant
                             AND ccampo = pccampo)
                   ORDER BY norden)
      LOOP
         vparam   := vparam1 || ' - cgarant: ' || reg.cgarant ||
                     ' - cconcep: ' || reg.cconcep || ' - norden: ' ||
                     reg.norden || ' - clave: ' || reg.clave ||
                     ' - clave2: ' || reg.clave2;
         vpasexec := 3;

         IF reg.clave IS NOT NULL
         THEN
            vpasexec := 4;

            BEGIN
               SELECT formula
                 INTO formula
                 FROM sgt_formulas
                WHERE clave = reg.clave;
            EXCEPTION
               WHEN OTHERS THEN
                  vnumerr := 108423;
                  RAISE salir;
            END;

            vpasexec := 5;
            pac_parm_tarifas.inserta_parametro(psesion,
                                               reg.clave,
                                               pcont,
                                               parms_transitorios,
                                               vnumerr,
                                               NULL,
                                               ptregconcep);

            IF vnumerr <> 0
            THEN
               RAISE salir;
            END IF;

            vpasexec := 6;
            valor    := pk_formulas.eval(formula, psesion);

            IF valor IS NULL
            THEN
               p_tab_error(f_sysdate,
                           f_user,
                           vobjectname,
                           vpasexec,
                           'tarifa no encontrada para la garantía',
                           formula || '  Sesion: ' || psesion || reg.clave || ' ' ||
                           reg.cconcep);
               vnumerr := 108437;
               RAISE salir;
            ELSE
               vcont_concep := NVL(ptregconcep.count, 0) + 1;

               IF reg.ccampo = 'PRIREGUL'
               THEN
                  --JRH Igualmente lo dejamos como IPRITAR en la regularización (tema de duplicación de detalles de prima).
                  ptregconcep(vcont_concep).ccampo := 'IPRITAR';
               ELSE
                  ptregconcep(vcont_concep).ccampo := reg.ccampo;
               END IF;

               ptregconcep(vcont_concep).cconcep := reg.cconcep;
               ptregconcep(vcont_concep).norden := reg.norden;
               ptregconcep(vcont_concep).valor := valor;
               --JRH IMP   Guardamos directamente los detalles de garantía para esta garantía
               vnumerr := pac_parm_tarifas.graba_param(psesion,
                                                       reg.cconcep,
                                                       valor);

               IF vnumerr <> 0
               THEN
                  vnumerr := 9903350;
                  RAISE salir;
               END IF;
               --JRH IMP   Guardamos directamente los detalles de garantía para esta garantía
            END IF;

            vpasexec := 7;
            pac_parm_tarifas.borra_parametro(psesion, reg.clave);
         END IF;

         vpasexec := 8;

         IF reg.clave2 IS NOT NULL
         THEN
            vpasexec := 9;

            BEGIN
               SELECT formula
                 INTO formula
                 FROM sgt_formulas
                WHERE clave = reg.clave2;
            EXCEPTION
               WHEN OTHERS THEN
                  vnumerr := 108423;
                  RAISE salir;
            END;

            vpasexec := 10;
            pac_parm_tarifas.inserta_parametro(psesion,
                                               reg.clave2,
                                               pcont,
                                               parms_transitorios,
                                               vnumerr,
                                               NULL,
                                               ptregconcep);

            IF vnumerr <> 0
            THEN
               RAISE salir;
            END IF;

            vpasexec := 11;
            valor    := pk_formulas.eval(formula, psesion);

            IF valor IS NULL
            THEN
               p_tab_error(f_sysdate,
                           f_user,
                           vobjectname,
                           vpasexec,
                           'tarifa no encontrada para la garantía',
                           formula || '  Sesion: ' || psesion || reg.clave2);
               vnumerr := 108437;
               RAISE salir;
            ELSE
               ptregconcep(vcont_concep).valor2 := valor;
               --JRH IMP   Guardamos directamente los detalles de garantía para esta garantía
               vnumerr := pac_parm_tarifas.graba_param(psesion,
                                                       reg.cconcep || '_V',
                                                       valor);

               IF vnumerr <> 0
               THEN
                  vnumerr := 9903350;
                  RAISE salir;
               END IF;
               --JRH IMP   Guardamos directamente los detalles de garantía para esta garantía
            END IF;

            vpasexec := 12;
            pac_parm_tarifas.borra_parametro(psesion, reg.clave2);
         END IF;
      END LOOP;

      vpasexec := 13;
      RETURN 0;
   EXCEPTION
      WHEN salir THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     vnumerr || '.-' || f_axis_literales(vnumerr));
         RETURN vnumerr;
      WHEN e_param_error THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 101901;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'Error al llamar procedimiento o función - numerr: ' ||
                     vnumerr);
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 140999;
   END f_dettarifar;

   FUNCTION f_obtenercampo(psproduc IN NUMBER,
                           pcactivi IN NUMBER,
                           pcgarant IN NUMBER,
                           pcconcep IN VARCHAR2,
                           pnorden  OUT NUMBER) RETURN VARCHAR2 IS
      vobjectname tab_error.tobjeto%TYPE := 'PAC_TARIFAS.F_OBTENERCAMPO';
      vparam      tab_error.tdescrip%TYPE := 'psproduc = ' || psproduc ||
                                             '; pcactivi = ' || pcactivi ||
                                             '; pcgarant = ' || pcgarant ||
                                             '; pcconcep = ' || pcconcep;
      vpasexec    NUMBER(8);
      vccampo     detgaranformula.ccampo%TYPE;
      vnorden     detgaranformula.norden%TYPE;
   BEGIN
      BEGIN
         vpasexec := 1;

         SELECT ccampo,
                norden
           INTO vccampo,
                vnorden
           FROM detgaranformula d
          WHERE d.sproduc = psproduc
            AND cactivi = pcactivi
            AND cgarant = pcgarant
            AND cconcep = pcconcep;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vpasexec := 2;

            SELECT ccampo,
                   norden
              INTO vccampo,
                   vnorden
              FROM detgaranformula d
             WHERE d.sproduc = psproduc
               AND cactivi = 0
               AND cgarant = pcgarant
               AND cconcep = pcconcep;
            -- BUG 0038262 - FAL - 20/10/2015
         WHEN OTHERS THEN
            SELECT ccampo,
                   norden
              INTO vccampo,
                   vnorden
              FROM detgaranformula d
             WHERE d.sproduc = psproduc
               AND cactivi = pcactivi
               AND cgarant = pcgarant
               AND cconcep = pcconcep
               AND ccampo = 'IPRITAR';
            -- FI BUG 0038262
      END;

      vpasexec := 3;
      pnorden  := vnorden;
      RETURN vccampo;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_obtenercampo;

   /***********************************************************************
      Funcion que aplica la prima mínima
   ***********************************************************************/
   -- Bug 21127 - APD - 06/03/2012 - se crea la funcion
   FUNCTION f_prima_minima(ptablas            VARCHAR2,
                           psseguro           NUMBER,
                           pnriesgo           NUMBER,
                           psproduc           NUMBER,
                           pfefecto           DATE,
                           parms_transitorios pac_parm_tarifas.parms_transitorios_tabtyb,
                           psproces           NUMBER,
                           pcactivi           NUMBER,
                           pfuncion           VARCHAR2,
                           pcnivel            NUMBER,
                           pcposicion         NUMBER,
                           pnmovimi           NUMBER,
                           pmoneda            NUMBER, -- Bug 26923/0146769 - APD - 17/06/2013
                           paccion            VARCHAR2 DEFAULT NULL) -- BUG 0039498 - FAL - 01/02/2016
    RETURN NUMBER IS
      vobjectname tab_error.tobjeto%TYPE := 'PAC_TARIFAS.F_PRIMA_MINIMA';
      vparam      tab_error.tdescrip%TYPE := 'ptablas = ' || ptablas ||
                                             '; psseguro = ' || psseguro ||
                                             '; pnriesgo = ' || pnriesgo ||
                                             '; psproduc = ' || psproduc ||
                                             '; pfefecto = ' || pfefecto ||
                                             '; psproces = ' || psproces ||
                                             '; pcactivi = ' || pcactivi ||
                                             '; pfuncion = ' || pfuncion ||
                                             '; pcnivel = ' || pcnivel ||
                                             '; pcposicion = ' ||
                                             pcposicion || '; pnmovimi = ' ||
                                             pnmovimi;
      vpasexec    NUMBER(8);
      vcprimin    productos.cprimin%TYPE;
      vprim_min   NUMBER;
      vdpm        NUMBER; -- Diferencial de prima mínina
      vdpmgar     NUMBER;
      -- Diferencial de prima mínima a una garantia
      vdpmgar_acum NUMBER;
      -- Diferencial acumulado de primia mínima a una garantia
      vdpm_bas     NUMBER; -- Diferencial de prima mínima básica
      vdpm_fin     NUMBER; -- Diferencial de prima mínima final
      vsum_iprianu NUMBER; -- Suma de iprianu de todas las garantias
      vcont        NUMBER;
      i            NUMBER;
      viprianu     NUMBER;
      -- iprianu + Diferencial de prima mínima a una garantia
      viprianu_bas        NUMBER; -- iprianu básica
      viprianu_fin        NUMBER; -- iprianu final
      vvalor1             tmp_detprimas.iconcep%TYPE;
      vvalor2             tmp_detprimas.iconcep%TYPE;
      vccampo1            detgaranformula.ccampo%TYPE;
      vccampo2            detgaranformula.ccampo%TYPE;
      vcconcep1           detgaranformula.cconcep%TYPE;
      vcconcep2           detgaranformula.cconcep%TYPE;
      v_parprod_detprimas parproductos.cvalpar%TYPE;
      vfechaaccesoprim    DATE;
      vnumerr             NUMBER;
      vnorden1            NUMBER;
      vnorden2            NUMBER;
      salir EXCEPTION;
      vfecacceso       DATE;
      vsum_iprianu_ant NUMBER; -- BUG 0039498 - FAL - 01/02/2016

      FUNCTION f_obt_concepto(pcposicion   NUMBER,
                              pctipo       IN NUMBER,
                              pctipoconcep IN NUMBER) RETURN VARCHAR2 IS
         vobjectname tab_error.tobjeto%TYPE := 'PAC_TARIFAS.F_PRIMA_MINIMA.f_obt_concepto';
         vparam      tab_error.tdescrip%TYPE := 'pcposicion = ' ||
                                                pcposicion || '; pctipo = ' ||
                                                pctipo ||
                                                '; pctipoconcep = ' ||
                                                pctipoconcep;
         vpasexec    NUMBER(8);
         vnumerr     NUMBER;
         salir EXCEPTION;
         vcconcep detprimas.cconcep%TYPE;
      BEGIN
         vpasexec := 1;

         IF pcposicion = 1
         THEN
            -- Final tarificación (VF 1073)
            vpasexec := 2;

            IF pctipo = 1
            THEN
               -- Prima Mínima Básica (VF 1074)
               vpasexec := 3;

               IF pctipoconcep = 1
               THEN
                  -- diferencial
                  vpasexec := 4;
                  vcconcep := 'DPMINBAS';
               ELSIF pctipoconcep = 2
               THEN
                  -- importe
                  vpasexec := 5;
                  vcconcep := 'PRMINBAS';
               END IF;
            ELSIF pctipo = 2
            THEN
               -- Prima Mínima Total (VF 1074)
               vpasexec := 6;

               IF pctipoconcep = 1
               THEN
                  -- diferencial
                  vpasexec := 7;
                  vcconcep := 'DPMINFIN';
               ELSIF pctipoconcep = 2
               THEN
                  -- importe
                  vpasexec := 8;
                  vcconcep := 'PRMINFIN';
               END IF;
            END IF;
         ELSIF pcposicion = 2
         THEN
            -- Después del Bonus Malus (VF 1073)
            vpasexec := 9;

            IF pctipo = 2
            THEN
               -- Prima Mínima Total (VF 1074)
               vpasexec := 10;

               IF pctipoconcep = 1
               THEN
                  -- diferencial
                  vpasexec := 11;
                  vcconcep := 'DPMINFI2';
               ELSIF pctipoconcep = 2
               THEN
                  -- importe
                  vpasexec := 12;
                  vcconcep := 'PRIFINAL';
               END IF;
            END IF;
         END IF;

         vpasexec := 13;
         RETURN vcconcep;
      EXCEPTION
         WHEN salir THEN
            p_tab_error(f_sysdate,
                        f_user,
                        vobjectname,
                        vpasexec,
                        vparam,
                        vnumerr || '.-' || f_axis_literales(vnumerr));
            RETURN NULL;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        vobjectname,
                        vpasexec,
                        vparam,
                        'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
            RETURN NULL;
      END f_obt_concepto;

      FUNCTION f_obt_fecefecto(psproduc IN NUMBER,
                               psseguro IN NUMBER,
                               ptablas  IN VARCHAR2) RETURN DATE IS
         vfecefecto  DATE;
         vpasexec    NUMBER(8);
         vobjectname tab_error.tobjeto%TYPE := 'PAC_TARIFAS.F_PRIMA_MINIMA.f_obt_fecefecto';
         vparam      tab_error.tdescrip%TYPE := 'psproduc = ' || psproduc ||
                                                '; psseguro = ' || psseguro ||
                                                '; ptablas = ' || ptablas;
      BEGIN
         vpasexec := 1;

         IF ptablas = 'EST'
         THEN
            vpasexec := 2;

            SELECT fefecto
              INTO vfecefecto
              FROM estseguros
             WHERE sseguro = psseguro;
         ELSE
            vpasexec := 3;

            SELECT fefecto
              INTO vfecefecto
              FROM seguros
             WHERE sseguro = psseguro;
         END IF;

         vpasexec := 4;
         RETURN vfecefecto;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        vobjectname,
                        vpasexec,
                        vparam,
                        'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
            RETURN NULL;
      END f_obt_fecefecto;

      FUNCTION f_obt_fec_ultcart(psproduc IN NUMBER,
                                 psseguro IN NUMBER,
                                 pnmovimi IN NUMBER,
                                 pfefecto IN DATE,
                                 ptablas  IN VARCHAR2,
                                 pfuncion IN VARCHAR2 DEFAULT NULL)
         RETURN DATE IS
         vfecefecto       DATE;
         vpasexec         NUMBER(8);
         vparam           tab_error.tdescrip%TYPE := 'psproduc = ' ||
                                                     psproduc ||
                                                     '; psseguro = ' ||
                                                     psseguro ||
                                                     '; pnmovimi = ' ||
                                                     pnmovimi ||
                                                     '; pfefecto = ' ||
                                                     TO_CHAR(pfefecto,
                                                             'dd/mm/yyyy') ||
                                                     '; ptablas = ' ||
                                                     ptablas ||
                                                     '; pfuncion = ' ||
                                                     pfuncion;
         vobjectname      tab_error.tobjeto%TYPE := 'PAC_TARIFAS.F_PRIMA_MINIMA.f_obt_fec_ultcart';
         vsseguro_act     NUMBER;
         vfechaaccesoprim DATE;
         verror           NUMBER;
         vnmovimi2        NUMBER;
         salir EXCEPTION;
      BEGIN
         vpasexec := 1;

         IF pfuncion = 'CAR'
         THEN
            -- Si estamos en una renovación
            vpasexec         := 2;
            vfechaaccesoprim := pfefecto;
         ELSE
            vpasexec := 3;

            IF pnmovimi = 1
            THEN
               vpasexec         := 4;
               vfechaaccesoprim := pfefecto;
            ELSE
               vpasexec := 5;

               IF ptablas = 'EST'
               THEN
                  vpasexec := 6;

                  SELECT ssegpol
                    INTO vsseguro_act
                    FROM estseguros
                   WHERE sseguro = psseguro;
               ELSE
                  vpasexec     := 7;
                  vsseguro_act := psseguro;
               END IF;

               vpasexec := 8;
               verror   := f_ultrenova(vsseguro_act,
                                       pfefecto,
                                       vfechaaccesoprim,
                                       vnmovimi2);

               IF verror <> 0
               THEN
                  RAISE salir;
               END IF;
            END IF;
         END IF;

         vpasexec := 9;
         RETURN vfechaaccesoprim;
      EXCEPTION
         WHEN salir THEN
            p_tab_error(f_sysdate,
                        f_user,
                        vobjectname,
                        vpasexec,
                        vparam,
                        verror || ' .- ' || f_axis_literales(verror));
            RETURN NULL;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        vobjectname,
                        vpasexec,
                        vparam,
                        'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
            RETURN NULL;
      END f_obt_fec_ultcart;

      FUNCTION f_obt_fec_prim_min(psproduc IN NUMBER,
                                  psseguro IN NUMBER,
                                  pnmovimi IN NUMBER,
                                  pfefecto IN DATE,
                                  ptablas  IN VARCHAR2,
                                  pfuncion IN VARCHAR2 DEFAULT NULL)
         RETURN DATE IS
         vparfecmin       NUMBER;
         vfechaaccesoprim DATE;
         vobjectname      tab_error.tobjeto%TYPE := 'PAC_TARIFAS.F_PRIMA_MINIMA.f_obt_fec_prim_min';
         vparam           tab_error.tdescrip%TYPE := 'psproduc = ' ||
                                                     psproduc ||
                                                     '; psseguro = ' ||
                                                     psseguro ||
                                                     '; pnmovimi = ' ||
                                                     pnmovimi ||
                                                     '; pfefecto = ' ||
                                                     TO_CHAR(pfefecto,
                                                             'DD/MM/YYYY') ||
                                                     '; ptablas = ' ||
                                                     ptablas ||
                                                     '; pfuncion = ' ||
                                                     pfuncion;
         vpasexec         NUMBER(8);
      BEGIN
         vpasexec   := 1;
         vparfecmin := NVL(f_parproductos_v(psproduc, 'FEC_PRIM_MIN'), 1);
         vpasexec   := 2;

         IF vparfecmin = 1
         THEN
            -- Fecha efecto póliza
            vpasexec         := 3;
            vfechaaccesoprim := f_obt_fecefecto(psproduc, psseguro, ptablas);
         ELSE
            --Última renovación
            vpasexec         := 4;
            vfechaaccesoprim := f_obt_fec_ultcart(psproduc,
                                                  psseguro,
                                                  pnmovimi,
                                                  pfefecto,
                                                  ptablas,
                                                  pfuncion);
         END IF;

         vpasexec := 5;
         RETURN vfechaaccesoprim;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        vobjectname,
                        vpasexec,
                        vparam,
                        'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
            RETURN NULL;
      END f_obt_fec_prim_min;

      FUNCTION f_obt_prim_min_clave(psproduc           IN NUMBER,
                                    psseguro           IN NUMBER,
                                    pnmovimi           IN NUMBER,
                                    pnriesgo           IN NUMBER,
                                    psproces           IN NUMBER,
                                    pfefecto           IN DATE,
                                    pclave             IN NUMBER,
                                    pmodoacceso        IN NUMBER,
                                    parms_transitorios pac_parm_tarifas.parms_transitorios_tabtyb,
                                    ptablas            IN VARCHAR2,
                                    pfuncion           IN VARCHAR2 DEFAULT NULL)
         RETURN NUMBER IS
         vobjectname tab_error.tobjeto%TYPE := 'PAC_TARIFAS.F_PRIMA_MINIMA.f_obt_prim_min_clave';
         vparam      tab_error.tdescrip%TYPE := 'psproduc = ' || psproduc ||
                                                '; psseguro = ' || psseguro ||
                                                '; pnmovimi = ' || pnmovimi ||
                                                '; pfefecto = ' ||
                                                TO_CHAR(pfefecto,
                                                        'DD/MM/YYYY') ||
                                                '; pclave = ' || pclave ||
                                                '; pmodoacceso = ' ||
                                                pmodoacceso ||
                                                '; ptablas = ' || ptablas ||
                                                '; pfuncion = ' || pfuncion;
         vpasexec    NUMBER(8);
         vpsesion    NUMBER;
         vformula    sgt_formulas.formula%TYPE;
         vnumerr     NUMBER;
         salir EXCEPTION;
         vfecacceso   DATE;
         v_tregconcep pac_parm_tarifas.tregconcep_tabtyp;
         vvalor_param NUMBER;
         vprim_min    NUMBER;
         retorno      NUMBER;
         exgrabaparam EXCEPTION;
         e       NUMBER;
         vcuenta NUMBER; --  QT 11652 / Bug 29315

         CURSOR cur_termino(wclave NUMBER) IS
            SELECT parametro
              FROM sgt_trans_formula
             WHERE clave = wclave
             ORDER BY 1;

         x_cllamada VARCHAR2(1000);
         no_encuentra EXCEPTION;
         xs       VARCHAR2(20000);
         v_cursor INTEGER;
         v_filas  NUMBER;
      BEGIN
         IF pfuncion = 'CAR'
         THEN
            x_cllamada := 'GENERICO';
         ELSE
            x_cllamada := 'ESTUDIOS';

            --  QT 11652 / Bug 29315 - ini
            BEGIN
               SELECT COUNT(1)
                 INTO vcuenta
                 FROM estseguros
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  vcuenta := 0;
            END;

            IF vcuenta = 0
            THEN
               x_cllamada := 'GENERICO';
            END IF;
            --  QT 11652 / Bug 29315 - fin
         END IF;

         IF pclave IS NOT NULL
         THEN
            SELECT sgt_sesiones.nextval INTO vpsesion FROM dual;

            vpasexec := 10;

            BEGIN
               SELECT formula
                 INTO vformula
                 FROM sgt_formulas
                WHERE clave = pclave;
            EXCEPTION
               WHEN OTHERS THEN
                  vnumerr := 101150;
                  RAISE salir;
            END;

            vpasexec := 11;

            BEGIN
               IF pmodoacceso = 1
               THEN
                  -- Fecha efecto póliza
                  vpasexec   := 111;
                  vfecacceso := f_obt_fecefecto(psproduc, psseguro, ptablas);
               ELSE
                  --Última renovación
                  vpasexec   := 112;
                  vfecacceso := f_obt_fec_ultcart(psproduc,
                                                  psseguro,
                                                  pnmovimi,
                                                  pfefecto,
                                                  ptablas,
                                                  pfuncion);
               END IF;

               IF vfecacceso IS NULL
               THEN
                  vnumerr := 9903378;
                  --Error al buscar la fecha acceso versión prima mínima
                  RAISE salir;
               END IF;

               pac_parm_tarifas.inserta_parametro(vpsesion,
                                                  pclave,
                                                  1,
                                                  parms_transitorios,
                                                  vnumerr,
                                                  NULL,
                                                  v_tregconcep);

               IF vnumerr <> 0
               THEN
                  RAISE salir;
               END IF;

               vpasexec := 12;

               -- Insertem el paràmetre pfunción per saber què estem fent
               -- desde SGT ( Cartera, Alta, suplement, Reasseg )
               SELECT DECODE(pfuncion,
                             'TAR',
                             1,
                             'SUP',
                             2,
                             'CAR',
                             3,
                             'REA',
                             4,
                             0)
                 INTO vvalor_param
                 FROM dual;

               vpasexec := 13;
               vnumerr  := pac_parm_tarifas.graba_param(vpsesion,
                                                        'FUNCION',
                                                        vvalor_param);

               IF vnumerr <> 0
               THEN
                  vnumerr := 109843;
                  RAISE salir;
               END IF;

               vpasexec := 14;
               vnumerr  := pac_parm_tarifas.graba_param(vpsesion,
                                                        'FECEFE',
                                                        TO_CHAR(vfecacceso,
                                                                'YYYYMMDD'));

               --JRH IMP Ajustamos la fecha tarifa según prima mínima
               IF vnumerr <> 0
               THEN
                  vnumerr := 109843;
                  RAISE salir;
               END IF;

               FOR term IN cur_termino(pclave)
               LOOP
                  BEGIN
                     BEGIN
                        SELECT 'BEGIN SELECT ' || tcampo ||
                               ' INTO :RETORNO  FROM ' || ttable ||
                               ' WHERE ' || twhere || ' ; END;'
                          INTO xs
                          FROM sgt_carga_arg_prede
                         WHERE termino = term.parametro
                           AND ttable IS NOT NULL
                           AND cllamada = x_cllamada;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           IF x_cllamada = 'PREVIO'
                           THEN
                              BEGIN
                                 SELECT 'BEGIN SELECT ' || tcampo ||
                                        ' INTO :RETORNO  FROM ' || ttable ||
                                        ' WHERE ' || twhere || ' ; END;'
                                   INTO xs
                                   FROM sgt_carga_arg_prede
                                  WHERE termino = term.parametro
                                    AND ttable IS NOT NULL
                                    AND cllamada = 'GENERICO';
                              EXCEPTION
                                 WHEN NO_DATA_FOUND THEN
                                    RAISE no_encuentra;
                              END;
                           ELSE
                              RAISE no_encuentra;
                           END IF;
                     END;

                     IF dbms_sql.is_open(v_cursor)
                     THEN
                        dbms_sql.close_cursor(v_cursor);
                     END IF;

                     v_cursor := dbms_sql.open_cursor;
                     dbms_sql.parse(v_cursor, xs, dbms_sql.native);
                     dbms_sql.bind_variable(v_cursor, ':RETORNO', retorno);

                     IF INSTR(xs, ':FECHA') > 0
                     THEN
                        dbms_sql.bind_variable(v_cursor,
                                               ':FECHA',
                                               TO_CHAR(pfefecto, 'YYYYMMDD'));
                     END IF;

                     IF INSTR(xs, ':FECEFE') > 0
                     THEN
                        dbms_sql.bind_variable(v_cursor,
                                               ':FECEFE',
                                               TO_CHAR(vfecacceso,
                                                       'YYYYMMDD'));
                     END IF;

                     IF INSTR(xs, ':SSEGURO') > 0
                     THEN
                        dbms_sql.bind_variable(v_cursor,
                                               ':SSEGURO',
                                               psseguro);
                     END IF;

                     IF INSTR(xs, ':SPRODUC') > 0
                     THEN
                        dbms_sql.bind_variable(v_cursor,
                                               ':SPRODUC',
                                               psproduc);
                     END IF;

                     --            IF INSTR(xs, ':CACTIVI') > 0 THEN
                     --               DBMS_SQL.bind_variable(v_cursor, ':CACTIVI', pcactivi);
                     --            END IF;

                     --            IF INSTR(xs, ':CGARANT') > 0 THEN
                     --               DBMS_SQL.bind_variable(v_cursor, ':CGARANT', pcgarant);
                     --            END IF;
                     IF INSTR(xs, ':NRIESGO') > 0
                     THEN
                        dbms_sql.bind_variable(v_cursor,
                                               ':NRIESGO',
                                               pnriesgo);
                     END IF;

                     IF INSTR(xs, ':NMOVIMI') > 0
                     THEN
                        dbms_sql.bind_variable(v_cursor,
                                               ':NMOVIMI',
                                               pnmovimi);
                     END IF;

                     -- Bug 10690 - RSC - 22/12/2009 - APR - Provisiones en productos de cartera (PORTFOLIO)
                     --            IF pndetgar IS NOT NULL THEN
                     --               IF INSTR(xs, ':NDETGAR') > 0 THEN
                     --                  DBMS_SQL.bind_variable(v_cursor, ':NDETGAR', pndetgar);
                     --               END IF;
                     --            ELSE
                     --               IF INSTR(xs, ':NDETGAR') > 0 THEN
                     --                  DBMS_SQL.bind_variable(v_cursor, ':NDETGAR', -1);
                     --               END IF;
                     --            END IF;

                     -- Fin Bug 10690
                     BEGIN
                        v_filas := dbms_sql.execute(v_cursor);
                        dbms_sql.variable_value(v_cursor,
                                                'RETORNO',
                                                retorno);

                        IF dbms_sql.is_open(v_cursor)
                        THEN
                           dbms_sql.close_cursor(v_cursor);
                        END IF;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           -- 14/09/05 CPM: Mirem que no estiguem llançant sobre un tancament
                           --  d'estalvi Real
                           IF x_cllamada = 'PREVIO'
                           THEN
                              vpasexec := 7;

                              SELECT 'BEGIN SELECT ' || tcampo ||
                                     ' INTO :RETORNO  FROM ' || ttable ||
                                     ' WHERE ' || twhere || ' ; END;'
                                INTO xs
                                FROM sgt_carga_arg_prede
                               WHERE termino = term.parametro
                                 AND ttable IS NOT NULL
                                 AND cllamada = 'GENERICO';

                              IF dbms_sql.is_open(v_cursor)
                              THEN
                                 dbms_sql.close_cursor(v_cursor);
                              END IF;

                              v_cursor := dbms_sql.open_cursor;
                              dbms_sql.parse(v_cursor, xs, dbms_sql.native);
                              dbms_sql.bind_variable(v_cursor,
                                                     ':RETORNO',
                                                     retorno);

                              --
                              IF INSTR(xs, ':FECHA') > 0
                              THEN
                                 dbms_sql.bind_variable(v_cursor,
                                                        ':FECHA',
                                                        TO_CHAR(pfefecto,
                                                                'YYYYMMDD'));
                              END IF;

                              IF INSTR(xs, ':FECEFE') > 0
                              THEN
                                 dbms_sql.bind_variable(v_cursor,
                                                        ':FECEFE',
                                                        TO_CHAR(vfecacceso,
                                                                'YYYYMMDD'));
                              END IF;

                              IF INSTR(xs, ':SSEGURO') > 0
                              THEN
                                 dbms_sql.bind_variable(v_cursor,
                                                        ':SSEGURO',
                                                        psseguro);
                              END IF;

                              IF INSTR(xs, ':SPRODUC') > 0
                              THEN
                                 dbms_sql.bind_variable(v_cursor,
                                                        ':SPRODUC',
                                                        psproduc);
                              END IF;

                              --            IF INSTR(xs, ':CACTIVI') > 0 THEN
                              --               DBMS_SQL.bind_variable(v_cursor, ':CACTIVI', pcactivi);
                              --            END IF;

                              --            IF INSTR(xs, ':CGARANT') > 0 THEN
                              --               DBMS_SQL.bind_variable(v_cursor, ':CGARANT', pcgarant);
                              --            END IF;
                              IF INSTR(xs, ':NRIESGO') > 0
                              THEN
                                 dbms_sql.bind_variable(v_cursor,
                                                        ':NRIESGO',
                                                        pnriesgo);
                              END IF;

                              IF INSTR(xs, ':NMOVIMI') > 0
                              THEN
                                 dbms_sql.bind_variable(v_cursor,
                                                        ':NMOVIMI',
                                                        pnmovimi);
                              END IF;

                              -- Fin Bug 10690
                              v_filas := dbms_sql.execute(v_cursor);
                              dbms_sql.variable_value(v_cursor,
                                                      'RETORNO',
                                                      retorno);

                              IF dbms_sql.is_open(v_cursor)
                              THEN
                                 dbms_sql.close_cursor(v_cursor);
                              END IF;
                           ELSE
                              -- del PREVIO
                              p_tab_error(f_sysdate,
                                          f_user,
                                          'Pac_Calculo_Formulas.calc_formul',
                                          vpasexec,
                                          SUBSTR('error al ejecutar con ' ||
                                                 x_cllamada ||
                                                 ' la select dinámica SSEGURO =' ||
                                                 psseguro || ' PFECHA=' || '01' ||
                                                 ' pclave=' || pclave ||
                                                 ' select =' || xs,
                                                 1,
                                                 500),
                                          SQLERRM);
                              retorno := 0;
                           END IF;
                        WHEN OTHERS THEN
                           IF dbms_sql.is_open(v_cursor)
                           THEN
                              dbms_sql.close_cursor(v_cursor);
                           END IF;

                           p_tab_error(f_sysdate,
                                       f_user,
                                       'Pac_Calculo_Formulas.calc_formul',
                                       vpasexec,
                                       SUBSTR('error al ejecutar la select dinámica SSEGURO =' ||
                                              psseguro || ' PFECHA=' || '01' ||
                                              ' porigen=' || 1 ||
                                              ' select =' || xs,
                                              1,
                                              500),
                                       SQLERRM);
                           retorno := 0;
                     END;

                     IF retorno IS NULL
                     THEN
                        RETURN 103135;
                     ELSE
                        -- Quan hi ha error graba_param fa un RAISE exGrabaParam
                        e := pac_parm_tarifas.graba_param(vpsesion,
                                                          term.parametro,
                                                          retorno);
                     END IF;
                     --
                  EXCEPTION
                     WHEN no_encuentra THEN
                        xs := NULL;
                     WHEN exgrabaparam THEN
                        RETURN 109843;
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate,
                                    f_user,
                                    'Cálculo de Fórmulas',
                                    vpasexec,
                                    SUBSTR('error al buscar la select dinámica SSEGURO =' ||
                                           psseguro || ' PFECHA=' || '01' ||
                                           ' para el termino =' ||
                                           term.parametro,
                                           1,
                                           500),
                                    SQLERRM);
                        xs := NULL;
                  END;
               END LOOP;

               FOR reg IN (SELECT *
                             FROM tmp_garancar g
                            WHERE g.sseguro = psseguro
                              AND g.nriesgo = NVL(pnriesgo, nriesgo)
                              AND g.sproces = psproces
                                 --AND g.ffinefe IS NULL  --JRH IMP Revisar
                              AND g.ndetgar = 0)
               LOOP
                  vnumerr := pac_parm_tarifas.graba_param(vpsesion,
                                                          'CAP-' ||
                                                          NVL(reg.nriesgo, 1) || '-' ||
                                                          reg.cgarant,
                                                          reg.icapital);

                  IF vnumerr <> 0
                  THEN
                     RETURN 108425;
                  END IF;

                  vnumerr := pac_parm_tarifas.graba_param(vpsesion,
                                                          'IPRITAR-' ||
                                                          NVL(reg.nriesgo, 1) || '-' ||
                                                          reg.cgarant,
                                                          reg.ipritar);

                  IF vnumerr <> 0
                  THEN
                     RETURN 108426;
                  END IF;

                  vnumerr := pac_parm_tarifas.graba_param(vpsesion,
                                                          'IPRIANU-' ||
                                                          NVL(reg.nriesgo, 1) || '-' ||
                                                          reg.cgarant,
                                                          reg.iprianu);

                  IF vnumerr <> 0
                  THEN
                     RETURN 108427;
                  END IF;

                  vnumerr := pac_parm_tarifas.graba_param(vpsesion,
                                                          'IPRIPUR-' ||
                                                          NVL(reg.nriesgo, 1) || '-' ||
                                                          reg.cgarant,
                                                          NVL(reg.icapital *
                                                              reg.itarifa,
                                                              0));

                  IF vnumerr <> 0
                  THEN
                     RETURN 9903349;
                  END IF;

                  vnumerr := pac_parm_tarifas.graba_param(vpsesion,
                                                          'GAR_CONTRATADA-' ||
                                                          NVL(reg.nriesgo, 1) || '-' ||
                                                          reg.cgarant,
                                                          1);

                  IF vnumerr <> 0
                  THEN
                     RETURN 108427;
                  END IF;
               END LOOP;

               FOR reg IN (SELECT *
                             FROM pregunpolcar g
                            WHERE g.sseguro = psseguro
                                 --  AND g.nmovimi = NVL(pnmovimi, nmovimi)
                              AND g.sproces = psproces)
               LOOP
                  vnumerr := pac_parm_tarifas.graba_param(vpsesion,
                                                          'RESP' ||
                                                          reg.cpregun,
                                                          reg.crespue);

                  IF vnumerr <> 0
                  THEN
                     RETURN 108424;
                  END IF;
               END LOOP;

               FOR reg IN (SELECT *
                             FROM preguncar g
                            WHERE g.sseguro = psseguro
                                 --  AND g.nmovimi = NVL(pnmovimi, nmovimi)
                              AND g.nriesgo = NVL(pnriesgo, nriesgo)
                              AND g.sproces = psproces)
               LOOP
                  vnumerr := pac_parm_tarifas.graba_param(vpsesion,
                                                          'RESP' ||
                                                          reg.cpregun,
                                                          reg.crespue);

                  IF vnumerr <> 0
                  THEN
                     RETURN 108424;
                  END IF;
               END LOOP;

               vpasexec := 15;
               --trobem el valor de la prima minima
               vprim_min := pk_formulas.eval(vformula, vpsesion);
               vpasexec  := 16;
               vnumerr   := pac_parm_tarifas.borra_param_sesion(vpsesion);
            EXCEPTION
               WHEN OTHERS THEN
                  vpasexec := 17;
                  vnumerr  := 140999;
                  RAISE salir;
            END;
         ELSE
            vpasexec  := 18;
            vprim_min := NULL;
         END IF;

         vpasexec := 19;
         RETURN vprim_min;
      EXCEPTION
         WHEN salir THEN
            p_tab_error(f_sysdate,
                        f_user,
                        vobjectname,
                        vpasexec,
                        vparam,
                        vnumerr || '.-' || f_axis_literales(vnumerr));
            RETURN NULL;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        vobjectname,
                        vpasexec,
                        vparam,
                        'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
            RETURN NULL;
      END f_obt_prim_min_clave;
   BEGIN
      vpasexec := 1;

      SELECT cprimin INTO vcprimin FROM productos WHERE sproduc = psproduc;

      vpasexec := 2;

      -- Prima mínima por cuadro
      IF vcprimin = 3
      THEN
         -- v.f 685
         vpasexec := 3;
         -- se busca el valor del parproducto DETPRIMAS
         v_parprod_detprimas := NVL(f_parproductos_v(psproduc, 'DETPRIMAS'),
                                    0);
         vpasexec            := 4;
         -- se busca la fecha acceso versión prima mínima
         vfechaaccesoprim := f_obt_fec_prim_min(psproduc,
                                                psseguro,
                                                pnmovimi,
                                                pfefecto,
                                                ptablas,
                                                pfuncion);
         vpasexec         := 5;

         IF vfechaaccesoprim IS NULL
         THEN
            vnumerr := 9903378;
            --Error al buscar la fecha acceso versión prima mínima
            RAISE salir;
         END IF;

         vpasexec := 6;

         FOR reg IN (SELECT p.sproduc,
                            p.cactivi,
                            p.cnivel,
                            p.cposicion,
                            m.ctipo,
                            p.ffecini,
                            m.cmodocalc,
                            m.cmodoreparto,
                            m.clave,
                            m.importe,
                            m.cgarpri,
                            d.norden,
                            d.idpm,
                            m.cmodoacceso
                       FROM prim_min          m,
                            prod_prim_min     p,
                            det_prod_prim_min d
                      WHERE p.sproduc = d.sproduc
                        AND p.cactivi = d.cactivi
                        AND p.cnivel = d.cnivel
                        AND p.cposicion = d.cposicion
                        AND m.idpm = d.idpm
                        AND p.ffecini = d.ffecini
                        AND p.sproduc = psproduc
                        AND p.cactivi = pcactivi
                        AND p.cnivel = pcnivel
                        AND p.cposicion = pcposicion
                        AND p.ffecini <= vfechaaccesoprim
                        AND ((p.ffecfin IS NULL) OR
                            (p.ffecfin IS NOT NULL AND
                            p.ffecfin > vfechaaccesoprim))
                     UNION
                     SELECT p.sproduc,
                            p.cactivi,
                            p.cnivel,
                            p.cposicion,
                            m.ctipo,
                            p.ffecini,
                            m.cmodocalc,
                            m.cmodoreparto,
                            m.clave,
                            m.importe,
                            m.cgarpri,
                            d.norden,
                            d.idpm,
                            m.cmodoacceso
                       FROM prim_min          m,
                            prod_prim_min     p,
                            det_prod_prim_min d
                      WHERE p.sproduc = d.sproduc
                        AND p.cactivi = d.cactivi
                        AND p.cnivel = d.cnivel
                        AND p.cposicion = d.cposicion
                        AND m.idpm = d.idpm
                        AND p.ffecini = d.ffecini
                        AND p.sproduc = psproduc
                        AND p.cactivi = 0
                        AND p.cnivel = pcnivel
                        AND p.cposicion = pcposicion
                        AND p.ffecini <= vfechaaccesoprim
                        AND ((p.ffecfin IS NULL) OR
                            (p.ffecfin IS NOT NULL AND
                            p.ffecfin > vfechaaccesoprim))
                        AND NOT EXISTS
                      (SELECT 1
                               FROM prod_prim_min     p,
                                    det_prod_prim_min d
                              WHERE p.sproduc = d.sproduc
                                AND p.cactivi = d.cactivi
                                AND p.cnivel = d.cnivel
                                AND p.cposicion = d.cposicion
                                AND m.idpm = d.idpm
                                AND p.ffecini = d.ffecini
                                AND p.sproduc = psproduc
                                AND p.cactivi = pcactivi
                                AND p.cnivel = pcnivel
                                AND p.cposicion = pcposicion
                                AND p.ffecini <= vfechaaccesoprim
                                AND ((p.ffecfin IS NULL) OR
                                    (p.ffecfin IS NOT NULL AND
                                    p.ffecfin > vfechaaccesoprim)))
                      ORDER BY norden)
         LOOP
            --Inicializar variables
            --vdpm := -1;
            vpasexec := 7;

            -- Se busca el valor de la prima mínima
            IF reg.cmodocalc = 1
            THEN
               -- Importe Fijo (v.f.1075)
               vpasexec  := 8;
               vprim_min := NVL(reg.importe, 0);
            ELSIF reg.cmodocalc = 2
            THEN
               -- Fórmula (v.f. 1075)
               vpasexec  := 9;
               vprim_min := f_obt_prim_min_clave(psproduc,
                                                 psseguro,
                                                 pnmovimi,
                                                 pnriesgo,
                                                 psproces,
                                                 pfefecto,
                                                 reg.clave,
                                                 reg.cmodoacceso,
                                                 parms_transitorios,
                                                 ptablas,
                                                 pfuncion);

               IF vprim_min IS NULL
               THEN
                  vnumerr := 9903386;
                  --Error al calcular la fórmula de prima mínima
                  RAISE salir;
               END IF;
            END IF;

            -- En el caso que la prima mínima calculada  buscamos cual es la prima mínima
            vpasexec := 15;

            IF vprim_min = 0
            THEN
               vdpm := 0;
            END IF;

            SELECT SUM(iprianu) sum_iprianu,
                   COUNT(*)
              INTO vsum_iprianu,
                   vcont
              FROM tmp_garancar g,
                   det_prim_min d
             WHERE d.idpm = reg.idpm
               AND g.sseguro = psseguro
               AND g.cgarant = d.cgarant
               AND g.nriesgo = NVL(pnriesgo, nriesgo)
               AND g.sproces = psproces
                  --AND g.ffinefe IS NULL  --JRH IMP Revisar
               AND g.ndetgar = 0;

            vpasexec := 16;

            IF vprim_min <> 0
            THEN
               IF vsum_iprianu < vprim_min
               THEN
                  vdpm := vprim_min - vsum_iprianu;

                  -- BUG 0039498 - FAL - 01/02/2016
                  IF NVL(paccion, 'NP') = 'RG'
                  THEN
                     -- En regularizacíón comparamos con prima anterior para ver si aplicar prima mínima
                     BEGIN
                        SELECT SUM(iprianu)
                          INTO vsum_iprianu_ant
                          FROM garanseg
                         WHERE sseguro =
                               (SELECT ssegpol
                                  FROM estseguros
                                 WHERE sseguro = psseguro)
                           AND nriesgo = NVL(pnriesgo, nriesgo)
                           AND ffinefe IS NULL;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           vsum_iprianu_ant := 0;
                     END;

                     IF vsum_iprianu_ant >= vprim_min AND
                        vsum_iprianu_ant > vsum_iprianu
                     THEN
                        -- No aplica prima mínima si ya venia aplicada
                        vdpm := 0;
                     END IF;
                  END IF;
                  -- FI BUG 0039498 - FAL - 01/02/2016
               ELSE
                  vdpm := 0;
               END IF;
            END IF;

            vpasexec     := 17;
            i            := 0;
            vdpmgar_acum := 0;

            FOR reg2 IN (SELECT g.sseguro,
                                g.cgarant,
                                g.finiefe,
                                g.nriesgo,
                                g.sproces,
                                g.ndetgar,
                                g.iprianu,
                                g.nmovima
                           FROM tmp_garancar g,
                                det_prim_min d
                          WHERE d.idpm = reg.idpm
                            AND g.sseguro = psseguro
                            AND g.cgarant = d.cgarant
                            AND g.nriesgo = NVL(pnriesgo, nriesgo)
                            AND g.sproces = psproces
                            AND g.ndetgar = 0
                         -- AND g.ffinefe IS NULL JRH IMP
                         )
            LOOP
               vpasexec := 18;
               i        := i + 1;

               IF reg.cmodoreparto = 2
               THEN
                  -- A una garantía (v.f. 1076)
                  vpasexec := 19;

                  IF reg.cgarpri IS NULL
                  THEN
                     vnumerr := 9903377;
                     --Garantía no parametrizada en la tabla PRIM_MIN
                     RAISE salir; --JRH IMPO
                  END IF;

                  vpasexec := 20;

                  IF reg2.cgarant = reg.cgarpri
                  THEN
                     vdpmgar := vdpm;
                  ELSE
                     vdpmgar := 0;
                  END IF;
               ELSIF reg.cmodoreparto = 1
               THEN
                  -- Proporcionalmente entre garantías (v.f. 1076)
                  vpasexec := 21;

                  IF i <> vcont
                  THEN
                     -- no estamos en la última garantía
                     -- Bug 26923/0146769 - APD - 17/06/2013 - se debe realizar el redondeo de vdpmgar
                     -- a los decimales de la moneda
                     --vdpmgar := vdpm *(reg2.iprianu / vsum_iprianu);
                     -- BUG 0039498 - FAL - 01/02/2016
                     IF vsum_iprianu = 0
                     THEN
                        -- si total prima es 0 reparto directo entre total de garantías
                        vdpmgar := f_round((vdpm / vcont), pmoneda);
                     ELSE
                        -- FI BUG 0039498 - FAL - 01/02/2016
                        vdpmgar := f_round(vdpm *
                                           (reg2.iprianu / vsum_iprianu),
                                           pmoneda);
                     END IF;

                     -- fin Bug 26923/0146769 - APD - 17/06/2013

                     --Ponderación sobre total prima
                     vdpmgar_acum := vdpmgar_acum + vdpmgar;
                  ELSE
                     -- última garantia
                     vdpmgar := vdpm - vdpmgar_acum; --Evitamos redondeos
                  END IF;
               END IF;

               vpasexec := 22;
               viprianu := reg2.iprianu + vdpmgar;

               -- Cambiamos en tmp_garancar el valor de  IPRIANU por viprianu
               UPDATE tmp_garancar
                  SET iprianu = viprianu
                WHERE sseguro = reg2.sseguro
                  AND cgarant = reg2.cgarant
                  AND finiefe = reg2.finiefe
                  AND nriesgo = reg2.nriesgo
                  AND sproces = reg2.sproces
                  AND ndetgar = reg2.ndetgar;

               vpasexec := 23;
               vvalor1  := vdpmgar;
               vvalor2  := viprianu;

               IF v_parprod_detprimas = 1 AND
                  reg.ctipo IN (1, 2)
               THEN
                  vpasexec  := 24;
                  vcconcep1 := f_obt_concepto(pcposicion, reg.ctipo, 1);
                  vccampo1  := pac_tarifas.f_obtenercampo(psproduc,
                                                          pcactivi,
                                                          reg2.cgarant,
                                                          vcconcep1,
                                                          vnorden1);
                  vcconcep2 := f_obt_concepto(pcposicion, reg.ctipo, 2);
                  vccampo2  := pac_tarifas.f_obtenercampo(psproduc,
                                                          pcactivi,
                                                          reg2.cgarant,
                                                          vcconcep2,
                                                          vnorden2);
                  vpasexec  := 27;

                  IF vccampo1 IS NOT NULL
                  THEN
                     -- Solo insertamos si lo han parametrizado, no vamos a dar un error por esto de momento
                     vpasexec := 28;

                     BEGIN
                        INSERT INTO tmp_detprimas
                           (sseguro, nriesgo, cgarant, nmovimi, finiefe,
                            ccampo, cconcep, sproces, norden, iconcep,
                            iconcep2)
                        VALUES
                           (reg2.sseguro, reg2.nriesgo, reg2.cgarant,
                            NVL(pnmovimi, reg2.nmovima), reg2.finiefe,
                            vccampo1, vcconcep1, reg2.sproces, vnorden1,
                            vvalor1, NULL);
                     EXCEPTION
                        WHEN dup_val_on_index THEN
                           vpasexec := 29;

                           UPDATE tmp_detprimas
                              SET norden   = vnorden1,
                                  iconcep  = vvalor1,
                                  iconcep2 = NULL
                            WHERE sseguro = reg2.sseguro
                              AND nriesgo = reg2.nriesgo
                              AND cgarant = reg2.cgarant
                              AND nmovimi = NVL(pnmovimi, reg2.nmovima)
                              AND finiefe = reg2.finiefe
                              AND ccampo = vccampo1
                              AND cconcep = vcconcep1
                              AND sproces = psproces;
                     END;
                  END IF;

                  vpasexec := 30;

                  IF vccampo2 IS NOT NULL
                  THEN
                     vpasexec := 31;

                     BEGIN
                        INSERT INTO tmp_detprimas
                           (sseguro, nriesgo, cgarant, nmovimi, finiefe,
                            ccampo, cconcep, sproces, norden, iconcep,
                            iconcep2)
                        VALUES
                           (reg2.sseguro, reg2.nriesgo, reg2.cgarant,
                            NVL(pnmovimi, reg2.nmovima), reg2.finiefe,
                            vccampo2, vcconcep2, reg2.sproces, vnorden2,
                            vvalor2, NULL);
                     EXCEPTION
                        WHEN dup_val_on_index THEN
                           vpasexec := 32;

                           UPDATE tmp_detprimas
                              SET norden   = vnorden2,
                                  iconcep  = vvalor2,
                                  iconcep2 = NULL
                            WHERE sseguro = reg2.sseguro
                              AND nriesgo = reg2.nriesgo
                              AND cgarant = reg2.cgarant
                              AND nmovimi = NVL(pnmovimi, reg2.nmovima)
                              AND finiefe = reg2.finiefe
                              AND ccampo = vccampo2
                              AND cconcep = vcconcep2
                              AND sproces = psproces;
                     END;
                  END IF;
               END IF;
            END LOOP; -- reg2
         END LOOP; -- reg
      END IF;

      vpasexec := 33;
      RETURN 0;
   EXCEPTION
      WHEN salir THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     vnumerr || '.-' || f_axis_literales(vnumerr));
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 140999;
   END f_prima_minima;

   /***********************************************************************
      Funcion que calcula el BONUS/MALUS
   ***********************************************************************/
   -- Bug 21127 - APD - 08/03/2012 - se crea la funcion
   FUNCTION f_calcula_bonusmalus(ptablas            VARCHAR2,
                                 psseguro           NUMBER,
                                 pnriesgo           NUMBER,
                                 psproduc           NUMBER,
                                 pfefecto           DATE,
                                 parms_transitorios pac_parm_tarifas.parms_transitorios_tabtyb,
                                 psproces           NUMBER,
                                 pcactivi           NUMBER,
                                 pfuncion           VARCHAR2,
                                 pnmovimi           NUMBER) RETURN NUMBER IS
      vobjectname         tab_error.tobjeto%TYPE := 'PAC_TARIFAS.F_CALCULA_BONUSMALUS';
      vparam              tab_error.tdescrip%TYPE := 'ptablas = ' ||
                                                     ptablas ||
                                                     '; psseguro = ' ||
                                                     psseguro ||
                                                     '; pnriesgo = ' ||
                                                     pnriesgo ||
                                                     '; psproduc = ' ||
                                                     psproduc ||
                                                     '; pfefecto = ' ||
                                                     pfefecto ||
                                                     '; psproces = ' ||
                                                     psproces ||
                                                     '; pcactivi = ' ||
                                                     pcactivi ||
                                                     '; pfuncion = ' ||
                                                     pfuncion ||
                                                     '; pnmovimi = ' ||
                                                     pnmovimi;
      vpasexec            NUMBER(8);
      viprianu            NUMBER;
      vvalor1             tmp_detprimas.iconcep%TYPE;
      vvalor2             tmp_detprimas.iconcep%TYPE;
      vccampo1            detgaranformula.ccampo%TYPE;
      vccampo2            detgaranformula.ccampo%TYPE;
      vcconcep1           detgaranformula.cconcep%TYPE;
      vcconcep2           detgaranformula.cconcep%TYPE;
      v_parprod_detprimas parproductos.cvalpar%TYPE;
      vnumerr             NUMBER;
      vnorden1            NUMBER;
      vnorden2            NUMBER;
      salir EXCEPTION;
      vcrespue NUMBER;
      -- MRB 231122012
      v_parprod_bomalus_bf parproductos.cvalpar%TYPE;
      wcgrup               estbf_bonfranseg.cgrup%TYPE;
      wcsubgrup            estbf_bonfranseg.csubgrup%TYPE;
      wcversion            estbf_bonfranseg.cversion%TYPE;
      vporcen              NUMBER;

      --
      CURSOR c_bonfran IS
         SELECT *
           FROM estbf_bonfranseg
          WHERE sseguro = psseguro
            AND ctipgrup = 1
            AND nriesgo = NVL(pnriesgo, nriesgo)
          ORDER BY cgrup;

      --
      CURSOR c_garancar IS
         SELECT *
           FROM tmp_garancar
          WHERE sseguro = psseguro
            AND cgarant IN (SELECT cgarant
                              FROM bf_progarangrup
                             WHERE sproduc = psproduc
                               AND codgrup = wcgrup);
      -------------------------------------
   BEGIN
      vpasexec := 1;
      -- se busca el valor del parproducto DETPRIMAS
      v_parprod_detprimas := NVL(f_parproductos_v(psproduc, 'DETPRIMAS'), 0);
      -- MRB 23112012  .. Tarifica BONUS/MALUS basándose en las nuevsa tablas BF_XXXX
      v_parprod_bomalus_bf := NVL(f_parproductos_v(psproduc, 'BOMALUS_BF'),
                                  0);

      IF v_parprod_bomalus_bf = 1
      THEN
         --
         FOR regbf IN c_bonfran
         LOOP
            vpasexec  := 51;
            wcgrup    := regbf.cgrup;
            wcsubgrup := regbf.csubgrup;
            wcversion := regbf.cversion;
            --
            vporcen := pac_bonfran.f_porcen_bonus(regbf.cgrup,
                                                  regbf.csubgrup,
                                                  regbf.cversion,
                                                  regbf.cnivel);
            vvalor1 := vporcen;

            --
            IF vporcen IS NULL
            THEN
               vnumerr := 9903400;
               RAISE salir;
            END IF;

            --
            vpasexec := 52;
            vporcen  := (100 + vporcen) / 100;

            --
            FOR reggar IN c_garancar
            LOOP
               vpasexec := 53;
               viprianu := reggar.iprianu * vporcen;

               UPDATE tmp_garancar
                  SET iprianu = viprianu
                WHERE sseguro = psseguro
                  AND cgarant = reggar.cgarant
                  AND finiefe = reggar.finiefe
                  AND nriesgo = reggar.nriesgo
                  AND sproces = reggar.sproces
                  AND ndetgar = reggar.ndetgar;

               vpasexec := 54;

               IF v_parprod_detprimas = 1
               THEN
                  vpasexec  := 55;
                  vcconcep1 := 'BOMALUS';
                  vccampo1  := pac_tarifas.f_obtenercampo(psproduc,
                                                          pcactivi,
                                                          reggar.cgarant,
                                                          vcconcep1,
                                                          vnorden1);
                  --vvalor1 := vcrespue;
                  vpasexec  := 55;
                  vcconcep2 := 'PBOMALUS';
                  vccampo2  := pac_tarifas.f_obtenercampo(psproduc,
                                                          pcactivi,
                                                          reggar.cgarant,
                                                          vcconcep2,
                                                          vnorden2);
                  vvalor2   := viprianu;
                  vpasexec  := 56;

                  IF vccampo1 IS NOT NULL
                  THEN
                     -- Solo insertamos si lo han parametrizado, no vamos a dar un error por esto de momento
                     vpasexec := 57;

                     BEGIN
                        INSERT INTO tmp_detprimas
                           (sseguro, nriesgo, cgarant, nmovimi, finiefe,
                            ccampo, cconcep, sproces, norden, iconcep,
                            iconcep2)
                        VALUES
                           (psseguro, reggar.nriesgo, reggar.cgarant,
                            NVL(pnmovimi, reggar.nmovima), reggar.finiefe,
                            vccampo1, vcconcep1, reggar.sproces, vnorden1,
                            vvalor1, NULL);
                     EXCEPTION
                        WHEN dup_val_on_index THEN
                           vpasexec := 58;

                           UPDATE tmp_detprimas
                              SET norden   = vnorden1,
                                  iconcep  = vvalor1,
                                  iconcep2 = NULL
                            WHERE sseguro = reggar.sseguro
                              AND nriesgo = reggar.nriesgo
                              AND cgarant = reggar.cgarant
                              AND nmovimi = NVL(pnmovimi, reggar.nmovima)
                              AND finiefe = reggar.finiefe
                              AND ccampo = vccampo1
                              AND cconcep = vcconcep1
                              AND sproces = psproces;
                     END;
                  END IF;

                  vpasexec := 59;

                  IF vccampo2 IS NOT NULL
                  THEN
                     vpasexec := 60;

                     BEGIN
                        INSERT INTO tmp_detprimas
                           (sseguro, nriesgo, cgarant, nmovimi, finiefe,
                            ccampo, cconcep, sproces, norden, iconcep,
                            iconcep2)
                        VALUES
                           (reggar.sseguro, reggar.nriesgo, reggar.cgarant,
                            NVL(pnmovimi, reggar.nmovima), reggar.finiefe,
                            vccampo2, vcconcep2, reggar.sproces, vnorden2,
                            vvalor2, NULL);
                     EXCEPTION
                        WHEN dup_val_on_index THEN
                           vpasexec := 61;

                           UPDATE tmp_detprimas
                              SET norden   = vnorden2,
                                  iconcep  = vvalor2,
                                  iconcep2 = NULL
                            WHERE sseguro = reggar.sseguro
                              AND nriesgo = reggar.nriesgo
                              AND cgarant = reggar.cgarant
                              AND nmovimi = NVL(pnmovimi, reggar.nmovima)
                              AND finiefe = reggar.finiefe
                              AND ccampo = vccampo2
                              AND cconcep = vcconcep2
                              AND sproces = psproces;
                     END;
                  END IF;
               END IF; -- De IF v_parprod_detprimas = 1 THEN
            --
            END LOOP; -- De FOR reggar IN c_garancar
         --
         END LOOP; -- De FOR regbf IN c_bonfran
         ----
      ELSE
         ------------------------------------------------------------------------------------
         FOR reg IN (SELECT g.sseguro,
                            g.cgarant,
                            g.finiefe,
                            g.nriesgo,
                            g.sproces,
                            g.ndetgar,
                            g.iprianu,
                            p.crespue,
                            g.nmovima
                       FROM tmp_garancar g,
                            preguncar    p
                      WHERE g.sseguro = p.sseguro(+)
                        AND g.nriesgo = p.nriesgo(+)
                        AND g.sproces = p.sproces(+)
                           --  AND g.nmovima = p.nmovimi(+)
                        AND g.sseguro = psseguro
                        AND g.nriesgo = NVL(pnriesgo, g.nriesgo)
                        AND g.sproces = psproces
                        AND g.ndetgar = 0
                        AND p.cpregun = 2034
                        AND g.cgarant NOT IN
                            (2050, 2051, 2052, 2053, 2054, 2095))
         LOOP
            vpasexec := 7;
            vcrespue := pac_subtablas.f_vsubtabla(-1,
                                                  15001,
                                                  3,
                                                  1,
                                                  reg.crespue);

            IF vcrespue IS NULL
            THEN
               vnumerr := 9903400; --Valor de Bonus/Malus no parametrizado.
               RAISE salir;
            END IF;

            vpasexec := 22;
            viprianu := reg.iprianu * (1 + vcrespue / 100);

            -- Cambiamos en tmp_garancar el valor de  IPRIANU por viprianu
            UPDATE tmp_garancar
               SET iprianu = viprianu
             WHERE sseguro = reg.sseguro
               AND cgarant = reg.cgarant
               AND finiefe = reg.finiefe
               AND nriesgo = reg.nriesgo
               AND sproces = reg.sproces
               AND ndetgar = reg.ndetgar;

            vpasexec := 23;

            IF v_parprod_detprimas = 1
            THEN
               vpasexec  := 24;
               vcconcep1 := 'BOMALUS';
               vccampo1  := pac_tarifas.f_obtenercampo(psproduc,
                                                       pcactivi,
                                                       reg.cgarant,
                                                       vcconcep1,
                                                       vnorden1);
               vvalor1   := vcrespue;
               vpasexec  := 25;
               vcconcep2 := 'PBOMALUS';
               vccampo2  := pac_tarifas.f_obtenercampo(psproduc,
                                                       pcactivi,
                                                       reg.cgarant,
                                                       vcconcep2,
                                                       vnorden2);
               vvalor2   := viprianu;
               vpasexec  := 27;

               IF vccampo1 IS NOT NULL
               THEN
                  -- Solo insertamos si lo han parametrizado, no vamos a dar un error por esto de momento
                  vpasexec := 28;

                  BEGIN
                     INSERT INTO tmp_detprimas
                        (sseguro, nriesgo, cgarant, nmovimi, finiefe,
                         ccampo, cconcep, sproces, norden, iconcep, iconcep2)
                     VALUES
                        (reg.sseguro, reg.nriesgo, reg.cgarant,
                         NVL(pnmovimi, reg.nmovima), reg.finiefe, vccampo1,
                         vcconcep1, reg.sproces, vnorden1, vvalor1, NULL);
                  EXCEPTION
                     WHEN dup_val_on_index THEN
                        vpasexec := 29;

                        UPDATE tmp_detprimas
                           SET norden   = vnorden1,
                               iconcep  = vvalor1,
                               iconcep2 = NULL
                         WHERE sseguro = reg.sseguro
                           AND nriesgo = reg.nriesgo
                           AND cgarant = reg.cgarant
                           AND nmovimi = NVL(pnmovimi, reg.nmovima)
                           AND finiefe = reg.finiefe
                           AND ccampo = vccampo1
                           AND cconcep = vcconcep1
                           AND sproces = psproces;
                  END;
               END IF;

               vpasexec := 30;

               IF vccampo2 IS NOT NULL
               THEN
                  vpasexec := 31;

                  BEGIN
                     INSERT INTO tmp_detprimas
                        (sseguro, nriesgo, cgarant, nmovimi, finiefe,
                         ccampo, cconcep, sproces, norden, iconcep, iconcep2)
                     VALUES
                        (reg.sseguro, reg.nriesgo, reg.cgarant,
                         NVL(pnmovimi, reg.nmovima), reg.finiefe, vccampo2,
                         vcconcep2, reg.sproces, vnorden2, vvalor2, NULL);
                  EXCEPTION
                     WHEN dup_val_on_index THEN
                        vpasexec := 32;

                        UPDATE tmp_detprimas
                           SET norden   = vnorden2,
                               iconcep  = vvalor2,
                               iconcep2 = NULL
                         WHERE sseguro = reg.sseguro
                           AND nriesgo = reg.nriesgo
                           AND cgarant = reg.cgarant
                           AND nmovimi = NVL(pnmovimi, reg.nmovima)
                           AND finiefe = reg.finiefe
                           AND ccampo = vccampo2
                           AND cconcep = vcconcep2
                           AND sproces = psproces;
                  END;
               END IF;
            END IF;
         END LOOP;
         -- MRB 23112012  -- Del IF v_parprod_bomalus_bf = 1 THEN
      END IF;

      vpasexec := 33;
      RETURN 0;
   EXCEPTION
      WHEN salir THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     vnumerr || '.-' || f_axis_literales(vnumerr));
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 140999;
   END f_calcula_bonusmalus;

   --------------------------------------------------------------------------
   FUNCTION f_insert_tmpdetprimas(psproces IN NUMBER,
                                  psseguro IN NUMBER,
                                  pnriesgo IN NUMBER,
                                  pcgarant IN NUMBER,
                                  pnmovimi IN NUMBER,
                                  pfiniefe IN DATE,
                                  pccampo  VARCHAR2,
                                  pcconcep VARCHAR2,
                                  pnorden  IN NUMBER,
                                  piconcep IN NUMBER) RETURN NUMBER IS
      vcuenta NUMBER;
      vparam  VARCHAR2(500) := psseguro || ' - ' || pnriesgo || ' - ' ||
                               pcgarant || ' - ' || pnmovimi || ' - ' ||
                               pfiniefe || ' - ' || pccampo || ' - ' ||
                               pcconcep || ' - ' || pnorden || ' - ' ||
                               piconcep;
   BEGIN
      SELECT COUNT(1)
        INTO vcuenta
        FROM tmp_detprimas
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND cgarant = pcgarant
         AND nmovimi = pnmovimi
         AND ccampo = pccampo
         AND cconcep = pcconcep
            --AND norden = pnorden
         AND sproces = psproces;

      IF vcuenta = 0
      THEN
         INSERT INTO tmp_detprimas
            (sseguro, nriesgo, cgarant, nmovimi, finiefe, ccampo, cconcep,
             sproces, norden, iconcep, falta, cusualt)
         VALUES
            (psseguro, pnriesgo, pcgarant, pnmovimi, pfiniefe, pccampo,
             pcconcep, psproces, pnorden, piconcep, f_sysdate, f_user);
      ELSE
         UPDATE tmp_detprimas
            SET iconcep = piconcep, norden = pnorden
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = pnmovimi
            AND ccampo = pccampo
            AND cconcep = pcconcep
               --AND norden = pnorden
            AND sproces = psproces;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     'f_insert_tmpdetprimas',
                     1,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END;

   -- Bug 30171/173304 - 24/04/2014 - AMC
   FUNCTION f_factor_proteccion(psproduc IN NUMBER,
                                pcactivi IN NUMBER,
                                pcgarant IN NUMBER,
                                psseguro IN NUMBER,
                                pnriesgo IN NUMBER,
                                pnmovimi IN NUMBER,
                                pnmovima IN NUMBER,
                                pfefecto IN DATE,
                                psproces IN NUMBER,
                                pprima   IN NUMBER,
                                paccion  IN VARCHAR2) RETURN NUMBER IS
      vparam            VARCHAR2(500) := ' psproduc ' || psproduc ||
                                         ' -pcactivi  ' || pcactivi ||
                                         ' -pcgarant  ' || pcgarant ||
                                         ' -psseguro  ' || psseguro ||
                                         ' -pnriesgo ' || pnriesgo ||
                                         ' -pnmovimi ' || pnmovimi ||
                                         ' - pnmovima' || pnmovima ||
                                         ' - pfefecto' || pfefecto ||
                                         ' - psproces' || psproces ||
                                         ' - pprima' || pprima ||
                                         ' -paccion  ' || paccion;
      vprsiprot         VARCHAR2(100);
      vfactprot         VARCHAR2(100);
      vnorden           NUMBER;
      vnmovimi          NUMBER;
      viconcep          NUMBER;
      vcalfactprot      NUMBER;
      vftarifa          DATE;
      vnfactor          NUMBER;
      vcempres          NUMBER;
      w_ipritarold      NUMBER;
      w_ipritarold_capp NUMBER;
      w_ipritarold_flor NUMBER;
      w_capping         NUMBER;
      w_floring         NUMBER;
      w_priconprot      NUMBER;
      w_factorprot      NUMBER;
      w_version         NUMBER;
      vpas              NUMBER := 0;
   BEGIN
      vpas      := 1;
      vprsiprot := pac_parametros.f_pargaranpro_t(psproduc,
                                                  pcactivi,
                                                  pcgarant,
                                                  'CONCEP_PRSIPROT');

      IF vprsiprot IS NOT NULL
      THEN
         BEGIN
            SELECT norden
              INTO vnorden
              FROM detgaranformula_pac
             WHERE sproduc = psproduc
               AND cgarant = pcgarant
               AND cconcep = vprsiprot;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vnorden := 1000;
         END;

         vpas := 2;

         BEGIN
            INSERT INTO tmp_detprimas
               (sseguro, nriesgo, cgarant, nmovimi, finiefe, ccampo,
                cconcep, sproces, norden, iconcep, falta, cusualt)
            VALUES
               (psseguro, pnriesgo, pcgarant, pnmovimi, pfefecto, 'IPRITAR',
                vprsiprot, psproces, vnorden, pprima, f_sysdate, f_user);
         EXCEPTION
            WHEN dup_val_on_index THEN
               UPDATE tmp_detprimas
                  SET iconcep = pprima
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND cgarant = pcgarant
                  AND nmovimi = pnmovimi
                  AND finiefe = pfefecto
                  AND ccampo = 'IPRITAR'
                  AND cconcep = vprsiprot
                  AND sproces = psproces;
         END;
      END IF;

      vpas      := 3;
      vfactprot := pac_parametros.f_pargaranpro_t(psproduc,
                                                  pcactivi,
                                                  pcgarant,
                                                  'CONCEP_FACTPROT');
      vpas      := 4;

      IF vfactprot IS NOT NULL
      THEN
         vpas := 5;
         vpas := 6;

         BEGIN
            SELECT norden
              INTO vnorden
              FROM detgaranformula_pac
             WHERE sproduc = psproduc
               AND cgarant = pcgarant
               AND cconcep = vfactprot;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vnorden := 1001;
         END;

         IF paccion <> 'CAR'
         THEN
            vpas := 7;

            BEGIN
               SELECT nfactor
                 INTO vnfactor
                 FROM estgaranseg
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND cgarant = pcgarant;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vnfactor := 1;
            END;
         ELSE
            vpas := 88;

            SELECT MAX(nmovimi)
              INTO vnmovimi
              FROM garanseg g
             WHERE g.sseguro = psseguro
               AND g.nriesgo = pnriesgo
               AND g.nmovimi IN (SELECT MAX(g.nmovimi)
                                   FROM garanseg  g,
                                        movseguro m
                                  WHERE m.sseguro = g.sseguro
                                    AND g.nmovimi = m.nmovimi
                                    AND m.cmotmov != 403 -- Movimiento de Psu de cartera
                                    AND g.sseguro = psseguro);

            --Qt 16860 -- NO aplica el factor de protección, por que esta cogiendo la prima del movmiento 403
            vpas := 8;

            SELECT cempres
              INTO vcempres
              FROM seguros
             WHERE sseguro = psseguro;

            vcalfactprot := pac_parametros.f_pargaranpro_n(psproduc,
                                                           pcactivi,
                                                           pcgarant,
                                                           'CALCUL_FACTPROT');

            IF NVL(vcalfactprot, 0) = 1
            THEN
               vpas := 9;

               BEGIN
                  SELECT ftarifa
                    INTO vftarifa
                    FROM garanseg
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND nmovimi = vnmovimi
                     AND cgarant = pcgarant;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     vftarifa := NULL;
               END;

               vpas := 10;

               SELECT version
                 INTO w_version
                 FROM fact_prot_ver
                WHERE cempres = vcempres
                  AND sproduc = psproduc
                  AND fecini <= vftarifa
                  AND (fecfin >= vftarifa OR fecfin IS NULL);

               vpas := 11;

               SELECT capping,
                      floring
                 INTO w_capping,
                      w_floring
                 FROM fact_prot_det
                WHERE cempres = vcempres
                  AND sproduc = psproduc
                  AND cgarant = pcgarant
                  AND version = w_version;

               vpas := 12;

               SELECT iprianu
                 INTO w_ipritarold
                 FROM garanseg
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND nmovimi = vnmovimi
                  AND cgarant = pcgarant;

               vpas              := 13;
               w_ipritarold_capp := w_ipritarold * (1 + (w_capping / 100));
               vpas              := 14;
               w_ipritarold_flor := w_ipritarold * (1 - (w_floring / 100));
               vpas              := 15;

               SELECT greatest(least(pprima, w_ipritarold_capp),
                               w_ipritarold_flor)
                 INTO w_priconprot
                 FROM dual;

               vpas := 16;

               -- Bug 32015/0188613 - JMF - 07/10/2014 Evitar dividir por cero
               IF pprima = 0
               THEN
                  vnfactor := 1;
               ELSE
                  vnfactor := w_priconprot / pprima;
               END IF;
            ELSE
               vpas     := 17;
               vnfactor := 1;
            END IF;
         END IF;

         vpas := 18;

         BEGIN
            INSERT INTO tmp_detprimas
               (sseguro, nriesgo, cgarant, nmovimi, finiefe, ccampo,
                cconcep, sproces, norden, iconcep, falta, cusualt)
            VALUES
               (psseguro, pnriesgo, pcgarant, pnmovimi, pfefecto, 'IPRITAR',
                vfactprot, psproces, vnorden, NVL(vnfactor, 1), f_sysdate,
                f_user);
         EXCEPTION
            WHEN dup_val_on_index THEN
               UPDATE tmp_detprimas
                  SET iconcep = NVL(vnfactor, 1)
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND cgarant = pcgarant
                  AND nmovimi = pnmovimi
                  AND finiefe = pfefecto
                  AND ccampo = 'IPRITAR'
                  AND cconcep = vfactprot
                  AND sproces = psproces;
         END;

         vpas := 19;

         UPDATE tmp_garancar
            SET nfactor = NVL(vnfactor, 1),
                iprianu = iprianu * NVL(vnfactor, 1)
          WHERE sseguro = psseguro
            AND cgarant = pcgarant
            AND nriesgo = pnriesgo
            AND finiefe = pfefecto
            AND nmovima = pnmovima
            AND sproces = psproces;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     'f_factor_proteccion',
                     99,
                     vpas,
                     'VPARAM :' || vparam || 'vnfactor ' || vnfactor ||
                     ' vprsiprot ' || vprsiprot || ' vfactprot  ' ||
                     vfactprot || '   vnorden   ' || vnorden ||
                     ' vnmovimi     ' || vnmovimi || ' viconcep     ' ||
                     viconcep || ' vcalfactprot    ' || vcalfactprot ||
                     ' vftarifa         ' || vftarifa || ' vnfactor       ' ||
                     vnfactor || ' vcempres         ' || vcempres ||
                     ' w_ipritarold     ' || w_ipritarold ||
                     ' w_ipritarold_capp   ' || w_ipritarold_capp ||
                     ' w_ipritarold_flor   ' || w_ipritarold_flor ||
                     ' w_capping        ' || w_capping ||
                     ' w_floring        ' || w_floring ||
                     ' w_priconprot     ' || w_priconprot ||
                     ' w_factorprot     ' || w_factorprot || ' w_version ' ||
                     w_version || '  SQLERROR: ' || SQLCODE || ' - ' ||
                     SQLERRM);
         RETURN 1;
   END f_factor_proteccion;

   /***********************************************************************
      Funcion que genera registros en la tabla tramosregul
   ***********************************************************************/
   -- BUG 34462 - AFM 01/2015
   FUNCTION f_generar_tabla_tramos(ptablas  IN VARCHAR2,
                                   psseguro IN NUMBER,
                                   pnriesgo IN NUMBER,
                                   pnmovimi IN NUMBER,
                                   pfefecto IN DATE,
                                   pctipo   IN NUMBER,
                                   psproces IN NUMBER) RETURN NUMBER IS
      vparam       VARCHAR2(500) := 'tabla: ' || ptablas || ' psseguro: ' ||
                                    psseguro || ' pnriesgo: ' || pnriesgo ||
                                    ' pnmovimi: ' || pnmovimi ||
                                    ' pfefecto: ' || pfefecto || ' ptipo: ' ||
                                    pctipo || ' psproces: ' || psproces;
      vpas         NUMBER;
      vobject      VARCHAR2(200) := 'PAC_TARIFAS.F_GENERAR_TABLA_TRAMOS';
      lsseguro     seguros.sseguro%TYPE;
      lnnumlin     NUMBER;
      num_err      NUMBER;
      ltexto       VARCHAR2(2000);
      licapitalact garanseg.icapital%TYPE;
      liprianuact  garanseg.iprianu%TYPE;
      lfefecto_fin movseguro.fefecto%TYPE;
      vfcaranu     DATE;
      vfcarpro     DATE;

      -- Cursor de movimientos
      CURSOR c_movtos(vsseguro IN NUMBER,
                      pnmovimi IN NUMBER) IS
         SELECT sseguro,
                nmovimi,
                cmotmov,
                fmovimi,
                cmovseg,
                fefecto,
                fcontab,
                cimpres,
                canuext,
                nsuplem,
                nmesven,
                nanyven,
                ncuacoa,
                femisio,
                cusumov,
                cusuemi,
                cdomper,
                cmotven,
                nempleado,
                coficin,
                cestadocol,
                fanulac,
                cusuanu,
                cregul
           FROM movseguro m
          WHERE sseguro = vsseguro
            AND ((pnmovimi IS NULL) OR
                (pnmovimi IS NOT NULL AND m.nmovimi > pnmovimi))
            AND cmovseg IN (0, 1, 2)
               -- busca los movimientos economicos mayores a la fecha efecto
            AND ((nmovimi IN
                (SELECT nmovimi
                     FROM garanseg
                    WHERE sseguro = m.sseguro
                      AND nmovimi = m.nmovimi
                      AND finiefe <>
                          NVL(ffinefe, TO_DATE('31122999', 'ddmmyyyy'))) AND
                fefecto > pfefecto)
                -- Busca el primer movimiento economicos si la fecha efecto anterior y posterior esta entre fecha efecto del supl. actual
                OR
                (nmovimi IN
                (SELECT nmovimi
                     FROM garanseg
                    WHERE sseguro = m.sseguro
                      AND nmovimi = m.nmovimi
                      AND pfefecto BETWEEN finiefe AND
                          NVL(ffinefe, TO_DATE('31122999', 'ddmmyyyy'))
                      AND finiefe <>
                          NVL(ffinefe, TO_DATE('31122999', 'ddmmyyyy')))))
         UNION --Unimos el tramo inmediatamente anterior si existe
         SELECT sseguro,
                nmovimi,
                cmotmov,
                fmovimi,
                cmovseg,
                fefecto,
                fcontab,
                cimpres,
                canuext,
                nsuplem,
                nmesven,
                nanyven,
                ncuacoa,
                femisio,
                cusumov,
                cusuemi,
                cdomper,
                cmotven,
                nempleado,
                coficin,
                cestadocol,
                fanulac,
                cusuanu,
                cregul
           FROM movseguro m
          WHERE sseguro = vsseguro
            AND ((pnmovimi IS NULL) OR
                (pnmovimi IS NOT NULL AND m.nmovimi > pnmovimi))
            AND cmovseg IN (0, 1, 2)
               -- busca los movimientos economicos mayores a la fecha efecto
            AND ((nmovimi IN
                (SELECT nmovimi
                     FROM garanseg
                    WHERE sseguro = m.sseguro
                      AND nmovimi = m.nmovimi
                      AND finiefe <>
                          NVL(ffinefe, TO_DATE('31122999', 'ddmmyyyy'))) AND
                fefecto < pfefecto)
                -- Busca el primer movimiento economicos si la fecha efecto anterior y posterior esta entre fecha efecto del supl. actual
                OR
                (nmovimi IN
                (SELECT nmovimi
                     FROM garanseg
                    WHERE sseguro = m.sseguro
                      AND nmovimi = m.nmovimi
                      AND pfefecto BETWEEN finiefe AND
                          NVL(ffinefe, TO_DATE('31122999', 'ddmmyyyy'))
                      AND finiefe <>
                          NVL(ffinefe, TO_DATE('31122999', 'ddmmyyyy')))))
            AND m.nmovimi =
                (SELECT MAX(m.nmovimi)
                   FROM movseguro m
                  WHERE sseguro = vsseguro
                    AND ((pnmovimi IS NULL) OR
                        (pnmovimi IS NOT NULL AND m.nmovimi > pnmovimi))
                    AND cmovseg IN (0, 1, 2)
                       -- busca los movimientos economicos mayores a la fecha efecto
                    AND ((nmovimi IN
                        (SELECT nmovimi
                             FROM garanseg
                            WHERE sseguro = m.sseguro
                              AND nmovimi = m.nmovimi
                              AND finiefe <>
                                  NVL(ffinefe,
                                      TO_DATE('31122999', 'ddmmyyyy'))) AND
                        fefecto < pfefecto)
                        -- Busca el primer movimiento economicos si la fecha efecto anterior y posterior esta entre fecha efecto del supl. actual
                        OR
                        (nmovimi IN
                        (SELECT nmovimi
                             FROM garanseg
                            WHERE sseguro = m.sseguro
                              AND nmovimi = m.nmovimi
                              AND pfefecto BETWEEN finiefe AND
                                  NVL(ffinefe,
                                      TO_DATE('31122999', 'ddmmyyyy'))
                              AND finiefe <>
                                  NVL(ffinefe,
                                      TO_DATE('31122999', 'ddmmyyyy'))))))
          ORDER BY sseguro,
                   fefecto;

      CURSOR c_movtos2(vsseguro IN NUMBER,
                       pnmovimi IN NUMBER) IS
         SELECT sseguro,
                nmovimi,
                cmotmov,
                fmovimi,
                cmovseg,
                fefecto,
                fcontab,
                cimpres,
                canuext,
                nsuplem,
                nmesven,
                nanyven,
                ncuacoa,
                femisio,
                cusumov,
                cusuemi,
                cdomper,
                cmotven,
                nempleado,
                coficin,
                cestadocol,
                fanulac,
                cusuanu,
                cregul
           FROM movseguro m
          WHERE sseguro = vsseguro
            AND ((pnmovimi IS NULL) OR
                (pnmovimi IS NOT NULL AND m.nmovimi > pnmovimi))
            AND cmovseg IN (0, 1, 2)
            AND cmotmov <> 962 -- BUG 0040823 - FAL - 26/02/2016. Descartar movimientos de Cambios de version por ser posiblemente retroactivos y así evitar tramosregul con fecfin < fecini
               -- busca los movimientos economicos mayores a la fecha efecto
            AND ((nmovimi IN
                (SELECT nmovimi
                     FROM garanseg
                    WHERE sseguro = m.sseguro
                      AND nmovimi = m.nmovimi
                      AND finiefe <>
                          NVL(ffinefe, TO_DATE('31122999', 'ddmmyyyy'))) AND
                fefecto > pfefecto)
                -- Busca el primer movimiento economicos si la fecha efecto anterior y posterior esta entre fecha efecto del supl. actual
                OR
                (nmovimi IN
                (SELECT nmovimi
                     FROM garanseg
                    WHERE sseguro = m.sseguro
                      AND nmovimi = m.nmovimi
                      AND pfefecto BETWEEN finiefe AND
                          NVL(ffinefe, TO_DATE('31122999', 'ddmmyyyy'))
                      AND finiefe <>
                          NVL(ffinefe, TO_DATE('31122999', 'ddmmyyyy')))))
         UNION --Unimos el tramo inmediatamente anterior si existe
         SELECT sseguro,
                nmovimi,
                cmotmov,
                fmovimi,
                cmovseg,
                fefecto,
                fcontab,
                cimpres,
                canuext,
                nsuplem,
                nmesven,
                nanyven,
                ncuacoa,
                femisio,
                cusumov,
                cusuemi,
                cdomper,
                cmotven,
                nempleado,
                coficin,
                cestadocol,
                fanulac,
                cusuanu,
                cregul
           FROM movseguro m
          WHERE sseguro = vsseguro
            AND ((pnmovimi IS NULL) OR
                (pnmovimi IS NOT NULL AND m.nmovimi > pnmovimi))
            AND cmovseg IN (0, 1, 2)
            AND cmotmov <> 962 -- BUG 0040823 - FAL - 26/02/2016. Descartar movimientos de Cambios de version por ser posiblemente retroactivos y así evitar tramosregul con fecfin < fecini
               -- busca los movimientos economicos mayores a la fecha efecto
            AND ((nmovimi IN
                (SELECT nmovimi
                     FROM garanseg
                    WHERE sseguro = m.sseguro
                      AND nmovimi = m.nmovimi
                      AND finiefe <>
                          NVL(ffinefe, TO_DATE('31122999', 'ddmmyyyy'))) AND
                fefecto < pfefecto)
                -- Busca el primer movimiento economicos si la fecha efecto anterior y posterior esta entre fecha efecto del supl. actual
                OR
                (nmovimi IN
                (SELECT nmovimi
                     FROM garanseg
                    WHERE sseguro = m.sseguro
                      AND nmovimi = m.nmovimi
                      AND pfefecto BETWEEN finiefe AND
                          NVL(ffinefe, TO_DATE('31122999', 'ddmmyyyy'))
                      AND finiefe <>
                          NVL(ffinefe, TO_DATE('31122999', 'ddmmyyyy')))))
            AND m.nmovimi =
                (SELECT MAX(m.nmovimi)
                   FROM movseguro m
                  WHERE sseguro = vsseguro
                    AND ((pnmovimi IS NULL) OR
                        (pnmovimi IS NOT NULL AND m.nmovimi > pnmovimi))
                    AND cmovseg IN (0, 1, 2)
                       -- busca los movimientos economicos mayores a la fecha efecto
                    AND ((nmovimi IN
                        (SELECT nmovimi
                             FROM garanseg
                            WHERE sseguro = m.sseguro
                              AND nmovimi = m.nmovimi
                              AND finiefe <>
                                  NVL(ffinefe,
                                      TO_DATE('31122999', 'ddmmyyyy'))) AND
                        fefecto < pfefecto)
                        -- Busca el primer movimiento economicos si la fecha efecto anterior y posterior esta entre fecha efecto del supl. actual
                        OR
                        (nmovimi IN
                        (SELECT nmovimi
                             FROM garanseg
                            WHERE sseguro = m.sseguro
                              AND nmovimi = m.nmovimi
                              AND pfefecto BETWEEN finiefe AND
                                  NVL(ffinefe,
                                      TO_DATE('31122999', 'ddmmyyyy'))
                              AND finiefe <>
                                  NVL(ffinefe,
                                      TO_DATE('31122999', 'ddmmyyyy'))))))
          ORDER BY sseguro,
                   fefecto;

      -- Cursor de garantias según movimiento existente
      CURSOR c_garant(vsseguro    IN NUMBER,
                      vnmovimiorg IN NUMBER) IS
         SELECT cgarant,
                nmovimi,
                iprianu,
                icapital,
                finiefe,
                ffinefe
           FROM garanseg g
          WHERE g.sseguro = vsseguro
            AND g.nmovimi = vnmovimiorg
            AND g.nriesgo = NVL(pnriesgo, g.nriesgo)
          ORDER BY cgarant,
                   nmovimi;

      -- Cursor de garantias del movimiento creado
      CURSOR c_garant_act(vsseguro       IN NUMBER,
                          vssegpol       IN NUMBER,
                          vnmovimi       IN NUMBER,
                          vnmovimiorigen NUMBER) IS
         SELECT cgarant,
                nmovimi,
                iprianu,
                icapital,
                finiefe,
                ffinefe
           FROM estgaranseg g
          WHERE g.sseguro = vssegpol
            AND g.nmovimi = vnmovimi
            AND g.nriesgo = NVL(pnriesgo, g.nriesgo)
            AND NVL(g.cobliga, 0) = 1
            AND ptablas = 'EST'
            AND NOT EXISTS (SELECT 1
                   FROM garanseg g2
                  WHERE g2.sseguro = vsseguro
                    AND g2.nriesgo = g.nriesgo
                    AND g2.nmovimi = vnmovimiorigen
                    AND g2.cgarant = g.cgarant)
          ORDER BY cgarant,
                   nmovimi;

      -- Cursor movimiento de regularización
      CURSOR c_garant_gen(vsseguro    IN NUMBER,
                          vnmovimiorg IN NUMBER) IS
         SELECT cgarant,
                nmovimi,
                iprianu,
                icapital,
                finiefe,
                ffinefe
           FROM estgaranseg
          WHERE sseguro = vsseguro
            AND nmovimi = vnmovimiorg
            AND ptablas = 'EST'
            AND NVL(cobliga, 0) = 1
            AND nriesgo = NVL(pnriesgo, nriesgo)
          ORDER BY cgarant,
                   nmovimi;
   BEGIN
      --
      vpas := 1;

      IF ptablas <> 'EST'
      THEN
         --Suponemos no hemos de hacer nada en modo SEG
         RETURN 0;
      END IF;

      --
      BEGIN
         SELECT ssegpol,
                fcaranu,
                fcarpro
           INTO lsseguro,
                vfcaranu,
                vfcarpro
           FROM estseguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            lnnumlin := NULL;
            ltexto   := 'No existe registro en ESTSEGUROS';
            p_tab_error(f_sysdate, f_user, vobject, vpas, vparam, ltexto);
            RETURN 1;
         WHEN OTHERS THEN
            lnnumlin := NULL;
            ltexto   := 'Error al leer en ESTSEGUROS';
            p_tab_error(f_sysdate, f_user, vobject, vpas, vparam, ltexto);
            RETURN 1;
      END;

      --
      vpas := 2;

      --
      DELETE esttramosregul
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND nmovimi = pnmovimi;

      vpas := 3;

      --   Si es Suplemento retroactivo
      IF pctipo = 1
      THEN
         -- Miro movimientos
         FOR m IN c_movtos(lsseguro, NULL)
         LOOP
            vpas := 4;

            -- Buscamos la fecha efecto del siguiente movimiento para grabarla en la fecha final del tramo
            IF m.nmovimi <> pnmovimi
            THEN
               lfefecto_fin := NULL;

               FOR l IN c_movtos2(lsseguro, m.nmovimi)
               LOOP
                  lfefecto_fin := l.fefecto;
                  EXIT;
               END LOOP;

               lfefecto_fin := NVL(lfefecto_fin, vfcarpro);
            END IF;

            --
            vpas := 5;

            --
            FOR g IN c_garant(lsseguro, m.nmovimi)
            LOOP
               BEGIN
                  -- Garantías Actuales las del mvto acabado de hacer.
                  SELECT icapital,
                         iprianu
                    INTO licapitalact,
                         liprianuact
                    FROM estgaranseg
                   WHERE sseguro = psseguro
                     AND nmovimi = pnmovimi
                     AND cgarant = g.cgarant
                     AND nriesgo = pnriesgo;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     licapitalact := 0;
                     liprianuact  := 0;
               END;

               --
               vpas := 7;

               --
               BEGIN
                  INSERT INTO esttramosregul
                     (sseguro, nriesgo, nmovimi, cgarant, nmovimiorg,
                      fecini, fecfin, ctipo, iprianuorg, iprianufin,
                      icapitalorg, icapitalfin, iimprecibo, finiorigar,
                      ffinorigar)
                  VALUES
                     (psseguro, pnriesgo, pnmovimi, g.cgarant, g.nmovimi,
                      greatest(m.fefecto, pfefecto), lfefecto_fin, pctipo,
                      NVL(g.iprianu, 0), NVL(liprianuact, 0),
                      NVL(g.icapital, 0), NVL(licapitalact, 0), NULL,
                      g.finiefe, g.ffinefe);
               EXCEPTION
                  WHEN dup_val_on_index THEN
                     lnnumlin := NULL;
                     ltexto   := 'Error al insertar en ESTTRAMOSREGUL con sseguro: ' ||
                                 psseguro || ' nriesgo ' || pnriesgo ||
                                 ' nmovimi: ' || pnmovimi || ' cgarant:' ||
                                 g.cgarant || ' nmovimiorig:' || g.nmovimi ||
                                 ' fecini:' ||
                                 greatest(m.fefecto, pfefecto) ||
                                 ' fecfin:' || lfefecto_fin || ' ctipo: ' ||
                                 pctipo || ' iprianuorig:' || g.iprianu ||
                                 ' iprianufin:' || liprianuact ||
                                 ' icapitalorig: ' || g.icapital ||
                                 ' icapitalfin:' || licapitalact ||
                                 ' finiorigar:' || g.finiefe;
                     p_tab_error(f_sysdate,
                                 f_user,
                                 vobject,
                                 vpas,
                                 vparam,
                                 ltexto);
                     RETURN 1;
                  WHEN OTHERS THEN
                     lnnumlin := NULL;
                     ltexto   := SQLERRM;
                     p_tab_error(f_sysdate,
                                 f_user,
                                 vobject,
                                 vpas,
                                 vparam,
                                 ltexto);
                     RETURN 1;
               END;

               vpas := 8;
            END LOOP;

            FOR g IN c_garant_act(lsseguro, psseguro, pnmovimi, m.nmovimi)
            LOOP
               licapitalact := g.icapital;
               liprianuact  := g.iprianu;
               --
               vpas := 7;

               --
               BEGIN
                  INSERT INTO esttramosregul
                     (sseguro, nriesgo, nmovimi, cgarant, nmovimiorg,
                      fecini, fecfin, ctipo, iprianuorg, iprianufin,
                      icapitalorg, icapitalfin, iimprecibo, finiorigar,
                      ffinorigar)
                  VALUES
                     (psseguro, pnriesgo, pnmovimi, g.cgarant, m.nmovimi,
                      greatest(m.fefecto, pfefecto), lfefecto_fin, pctipo, 0,
                      NVL(liprianuact, 0), 0, NVL(licapitalact, 0), NULL,
                      NULL, NULL);
               EXCEPTION
                  WHEN dup_val_on_index THEN
                     lnnumlin := NULL;
                     --
                     ltexto := 'Error al insertar en ESTTRAMOSREGUL con sseguro: ' ||
                               psseguro || ' nriesgo ' || pnriesgo ||
                               ' nmovimi: ' || pnmovimi || ' cgarant:' ||
                               g.cgarant || ' nmovimiorig:' || m.nmovimi ||
                               ' fecini:' || greatest(m.fefecto, pfefecto) ||
                               ' fecfin:' || lfefecto_fin || ' ctipo: ' ||
                               pctipo || ' iprianuorig:' || g.iprianu ||
                               ' iprianufin:' || liprianuact ||
                               ' icapitalorig: ' || g.icapital ||
                               ' icapitalfin:' || licapitalact ||
                               ' finiorigar:' || g.finiefe;
                     p_tab_error(f_sysdate,
                                 f_user,
                                 vobject,
                                 vpas,
                                 vparam,
                                 ltexto);
                     RETURN 1;
                  WHEN OTHERS THEN
                     lnnumlin := NULL;
                     ltexto   := SQLERRM;
                     p_tab_error(f_sysdate,
                                 f_user,
                                 vobject,
                                 vpas,
                                 vparam,
                                 ltexto);
                     RETURN 1;
               END;

               --
               vpas := 8;
               --
            END LOOP;
            --
         END LOOP;

         --
         vpas := 11;
         --
      ELSE
         vpas := 12;

         --  Suplemento regularización
         FOR g IN c_garant_gen(psseguro, pnmovimi)
         LOOP
            vpas := 13;

            --
            BEGIN
               INSERT INTO esttramosregul
                  (sseguro, nriesgo, nmovimi, cgarant, nmovimiorg, fecini,
                   fecfin, ctipo, iprianuorg, iprianufin, icapitalorg,
                   icapitalfin, iimprecibo, finiorigar, ffinorigar)
               VALUES
                  (psseguro, pnriesgo, pnmovimi, g.cgarant, pnmovimi,
                   g.finiefe, NVL(g.ffinefe, add_months(g.finiefe, 12)),
                   pctipo, g.iprianu, g.iprianu, g.icapital, g.icapital,
                   NULL, g.finiefe, g.ffinefe);
            EXCEPTION
               WHEN dup_val_on_index THEN
                  lnnumlin := NULL;
                  ltexto   := 'Error al insertar en ESTTRAMOSREGUL con sseguro: ' ||
                              psseguro || ' nriesgo ' || pnriesgo ||
                              ' nmovimi: ' || pnmovimi || ' cgarant:' ||
                              g.cgarant || ' nmovimiorig:' || g.nmovimi ||
                              ' fecini:' || g.finiefe || ' fecfin:' ||
                              g.ffinefe || ' ctipo: ' || pctipo ||
                              ' iprianuorig:' || g.iprianu ||
                              ' iprianufin:' || g.iprianu ||
                              ' icapitalorig: ' || g.icapital ||
                              ' icapitalfin:' || g.icapital ||
                              ' finiorigar:' || g.finiefe || ' ffinorigar:' ||
                              g.ffinefe;
                  p_tab_error(f_sysdate,
                              f_user,
                              vobject,
                              vpas,
                              vparam,
                              ltexto);
                  RETURN 1;
               WHEN OTHERS THEN
                  lnnumlin := NULL;
                  ltexto   := SQLERRM;
                  p_tab_error(f_sysdate,
                              f_user,
                              vobject,
                              vpas,
                              vparam,
                              ltexto);
                  RETURN 1;
            END;

            vpas := 14;
            --
         END LOOP;
         --
      END IF;

      --
      --  select count(*) into vpas from esttramosregul where sseguro=psseguro;
      -- p_tab_error(f_sysdate, f_user, vobject, vpas, vparam, 'AQUI HAY REGISTROS');
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobject,
                     vpas,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_generar_tabla_tramos;

   --
   FUNCTION f_valor_act(psseguro IN NUMBER,
                        pnriesgo IN NUMBER,
                        pcgarant IN NUMBER,
                        pnmovimi IN NUMBER,
                        pcampo   IN VARCHAR2) RETURN NUMBER IS
      vobject    VARCHAR2(200) := 'PAC_TARIFAS.f_valor_act';
      vparam     VARCHAR2(200) := 'psseguro: ' || psseguro ||
                                  ' - pnriesgo: ' || pnriesgo ||
                                  ' - pcgarant: ' || pcgarant ||
                                  ' - pnmovimi: ' || pnmovimi;
      vtraza     NUMBER := 1;
      xprimaact  NUMBER;
      vresultado NUMBER := 0;
      xsegpol    NUMBER;
      vvaloract  NUMBER;
   BEGIN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vtraza,
                  vparam,
                  SQLCODE || '-' || SQLERRM);

      BEGIN
         SELECT ssegpol
           INTO xsegpol
           FROM estseguros
          WHERE sseguro = psseguro;

         IF pcampo = 'ICAPITAL'
         THEN
            SELECT icapital
              INTO vvaloract
              FROM garanseg
             WHERE sseguro = xsegpol
               AND nriesgo = pnriesgo
               AND cgarant = pcgarant
               AND nmovimi = (SELECT MAX(g.nmovimi)
                                FROM garanseg  g,
                                     movseguro m
                               WHERE g.sseguro = m.sseguro
                                 AND g.nmovimi = m.nmovimi
                                 AND g.sseguro = xsegpol
                                 AND m.nmovimi < pnmovimi);
         ELSIF pcampo = 'ICAPTOT'
         THEN
            SELECT icaptot
              INTO vvaloract
              FROM garanseg
             WHERE sseguro = xsegpol
               AND nriesgo = pnriesgo
               AND cgarant = pcgarant
               AND nmovimi = (SELECT MAX(g.nmovimi)
                                FROM garanseg  g,
                                     movseguro m
                               WHERE g.sseguro = m.sseguro
                                 AND g.nmovimi = m.nmovimi
                                 AND g.sseguro = xsegpol
                                 AND m.nmovimi < pnmovimi);
         ELSIF pcampo = 'IPRITOT'
         THEN
            SELECT ipritot
              INTO vvaloract
              FROM garanseg
             WHERE sseguro = xsegpol
               AND nriesgo = pnriesgo
               AND cgarant = pcgarant
               AND nmovimi = (SELECT MAX(g.nmovimi)
                                FROM garanseg  g,
                                     movseguro m
                               WHERE g.sseguro = m.sseguro
                                 AND g.nmovimi = m.nmovimi
                                 AND g.sseguro = xsegpol
                                 AND m.nmovimi < pnmovimi);
         ELSIF pcampo = 'IPRIANU'
         THEN
            SELECT iprianu
              INTO vvaloract
              FROM garanseg
             WHERE sseguro = xsegpol
               AND nriesgo = pnriesgo
               AND cgarant = pcgarant
               AND nmovimi = (SELECT MAX(g.nmovimi)
                                FROM garanseg  g,
                                     movseguro m
                               WHERE g.sseguro = m.sseguro
                                 AND g.nmovimi = m.nmovimi
                                 AND g.sseguro = xsegpol
                                 AND m.nmovimi < pnmovimi);
         ELSIF pcampo = 'IPRITAR'
         THEN
            SELECT ipritar
              INTO vvaloract
              FROM garanseg
             WHERE sseguro = xsegpol
               AND nriesgo = pnriesgo
               AND cgarant = pcgarant
               AND nmovimi = (SELECT MAX(g.nmovimi)
                                FROM garanseg  g,
                                     movseguro m
                               WHERE g.sseguro = m.sseguro
                                 AND g.nmovimi = m.nmovimi
                                 AND g.sseguro = xsegpol
                                 AND m.nmovimi < pnmovimi);
         ELSIF pcampo = 'IRECARG'
         THEN
            SELECT irecarg
              INTO vvaloract
              FROM garanseg
             WHERE sseguro = xsegpol
               AND nriesgo = pnriesgo
               AND cgarant = pcgarant
               AND nmovimi = (SELECT MAX(g.nmovimi)
                                FROM garanseg  g,
                                     movseguro m
                               WHERE g.sseguro = m.sseguro
                                 AND g.nmovimi = m.nmovimi
                                 AND g.sseguro = xsegpol
                                 AND m.nmovimi < pnmovimi);
         ELSIF pcampo = 'ITARREA'
         THEN
            SELECT itarrea
              INTO vvaloract
              FROM garanseg
             WHERE sseguro = xsegpol
               AND nriesgo = pnriesgo
               AND cgarant = pcgarant
               AND nmovimi = (SELECT MAX(g.nmovimi)
                                FROM garanseg  g,
                                     movseguro m
                               WHERE g.sseguro = m.sseguro
                                 AND g.nmovimi = m.nmovimi
                                 AND g.sseguro = xsegpol
                                 AND m.nmovimi < pnmovimi);
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vvaloract := 0;
      END;

      vresultado := vvaloract;
      RETURN NVL(vresultado, 0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobject,
                     vtraza,
                     vparam,
                     SQLCODE || '-' || SQLERRM);
         RETURN NULL;
   END f_valor_act;

   PROCEDURE p_tratapre_detalle_garant(psproduc IN NUMBER,
                                       psseguro IN NUMBER,
                                       pnriesgo IN NUMBER,
                                       pnmovimi IN NUMBER,
                                       psproces IN NUMBER,
                                       ptablas  IN VARCHAR2) IS
   BEGIN
      IF NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) = 3 AND
         pnmovimi > 1
      THEN
         IF ptablas = 'EST'
         THEN
            INSERT INTO garansegdet
               (sseguro, cgarant, nriesgo, finiefe, norden, ctarifa,
                icapital, precarg, iprianu, ffinefe, cformul, iextrap,
                ctipfra, ifranqu, sproces, irecarg, ipritar, pdtocom,
                idtocom, crevali, prevali, irevali, itarifa, itarrea,
                ipritot, icaptot, ftarifa, cderreg, feprev, fpprev, percre,
                cref, cintref, pdif, pinttec, nparben, nbns, tmgaran, cmatch,
                tdesmat, pintfin, nmovima, nfactor, nmovi_ant, idtoint,
                ccampanya, nversio, cageven, nlinea, ndetgar, ctarman,
                pdtotec, preccom, idtotec, ireccom)
               SELECT sseguro,
                      cgarant,
                      nriesgo,
                      finiefe,
                      norden,
                      ctarifa,
                      icapital,
                      precarg,
                      iprianu,
                      ffinefe,
                      cformul,
                      iextrap,
                      ctipfra,
                      ifranqu,
                      psproces,
                      irecarg,
                      ipritar,
                      pdtocom,
                      idtocom,
                      crevali,
                      prevali,
                      irevali,
                      itarifa,
                      itarrea,
                      ipritot,
                      icaptot,
                      ftarifa,
                      cderreg,
                      feprev,
                      fpprev,
                      percre,
                      cref,
                      cintref,
                      pdif,
                      pinttec,
                      nparben,
                      nbns,
                      tmgaran,
                      cmatch,
                      tdesmat,
                      pintfin,
                      nmovima,
                      nfactor,
                      nmovimi,
                      idtoint,
                      ccampanya,
                      nversio,
                      cageven,
                      nlinea,
                      0,
                      ctarman,
                      pdtotec,
                      preccom,
                      idtotec,
                      ireccom
                 FROM estgaranseg
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND ffinefe IS NULL
                  AND f_ctipgar(psproduc,
                                cgarant,
                                pac_seguros.ff_get_actividad(psseguro,
                                                             pnriesgo,
                                                             ptablas)) <> 9
                  AND NVL(cobliga, 1) = 1
                  AND NVL(ctipgar, 0) NOT IN (8, 9);

            UPDATE estgaranseg
               SET icapital = ABS(icapital -
                                  pac_tarifas.f_valor_act(psseguro,
                                                          pnriesgo,
                                                          cgarant,
                                                          pnmovimi,
                                                          'ICAPITAL')),
                   icaptot  = ABS(icaptot -
                                  pac_tarifas.f_valor_act(psseguro,
                                                          pnriesgo,
                                                          cgarant,
                                                          pnmovimi,
                                                          'ICAPTOT'))
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND ffinefe IS NULL
               AND f_ctipgar(psproduc,
                             cgarant,
                             pac_seguros.ff_get_actividad(psseguro,
                                                          pnriesgo,
                                                          ptablas)) <> 9
               AND NVL(cobliga, 1) = 1
               AND NVL(ctipgar, 0) NOT IN (8, 9);
         ELSE
            INSERT INTO garansegdet
               (sseguro, cgarant, nriesgo, finiefe, norden, ctarifa,
                icapital, precarg, iprianu, ffinefe, cformul, iextrap,
                ctipfra, ifranqu, sproces, irecarg, ipritar, pdtocom,
                idtocom, crevali, prevali, irevali, itarifa, itarrea,
                ipritot, icaptot, ftarifa, cderreg, feprev, fpprev, percre,
                cref, cintref, pdif, pinttec, nparben, nbns, tmgaran, cmatch,
                tdesmat, pintfin, nmovima, nfactor, nmovi_ant, idtoint,
                ccampanya, nversio, cageven, nlinea, ndetgar, ctarman,
                pdtotec, preccom, idtotec, ireccom)
               SELECT sseguro,
                      cgarant,
                      nriesgo,
                      finiefe,
                      norden,
                      ctarifa,
                      icapital,
                      precarg,
                      iprianu,
                      ffinefe,
                      cformul,
                      iextrap,
                      ctipfra,
                      ifranqu,
                      psproces,
                      irecarg,
                      ipritar,
                      pdtocom,
                      idtocom,
                      crevali,
                      prevali,
                      irevali,
                      itarifa,
                      itarrea,
                      ipritot,
                      icaptot,
                      ftarifa,
                      cderreg,
                      feprev,
                      fpprev,
                      percre,
                      cref,
                      cintref,
                      pdif,
                      pinttec,
                      nparben,
                      nbns,
                      tmgaran,
                      cmatch,
                      tdesmat,
                      pintfin,
                      nmovima,
                      nfactor,
                      nmovimi,
                      idtoint,
                      ccampanya,
                      nversio,
                      cageven,
                      nlinea,
                      0,
                      ctarman,
                      pdtotec,
                      preccom,
                      idtotec,
                      ireccom
                 FROM garanseg
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND ffinefe IS NULL
                  AND f_ctipgar(psproduc,
                                cgarant,
                                pac_seguros.ff_get_actividad(psseguro,
                                                             pnriesgo,
                                                             ptablas)) <> 9;

            UPDATE garanseg
               SET icapital = ABS(icapital -
                                  pac_tarifas.f_valor_act(psseguro,
                                                          pnriesgo,
                                                          cgarant,
                                                          pnmovimi,
                                                          'ICAPITAL')),
                   icaptot  = ABS(icaptot -
                                  pac_tarifas.f_valor_act(psseguro,
                                                          pnriesgo,
                                                          cgarant,
                                                          pnmovimi,
                                                          'ICAPTOT'))
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND ffinefe IS NULL
               AND f_ctipgar(psproduc,
                             cgarant,
                             pac_seguros.ff_get_actividad(psseguro,
                                                          pnriesgo,
                                                          ptablas)) <> 9;
         END IF;
      END IF;
   END;

   PROCEDURE p_trata_detalle_garant(psproduc IN NUMBER,
                                    psseguro IN NUMBER,
                                    pnriesgo IN NUMBER,
                                    pnmovimi IN NUMBER,
                                    psproces IN NUMBER,
                                    ptablas  IN VARCHAR2) IS
   BEGIN
      IF NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) = 3 AND
         pnmovimi > 1
      THEN
         IF ptablas = 'EST'
         THEN
            UPDATE estgaranseg
               SET icapital = DECODE(SIGN((SELECT icapital
                                             FROM garansegdet
                                            WHERE sseguro = psseguro
                                              AND nriesgo = pnriesgo
                                              AND nmovimi = pnmovimi
                                              AND sproces = psproces
                                              AND cgarant =
                                                  estgaranseg.cgarant) -
                                          pac_tarifas.f_valor_act(psseguro,
                                                                  pnriesgo,
                                                                  cgarant,
                                                                  pnmovimi,
                                                                  'ICAPITAL')),
                                     -1,
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'ICAPITAL') -
                                     estgaranseg.icapital, -- Decremento VA
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'ICAPITAL') +
                                     estgaranseg.icapital -- Incremento VA
                                     ),
                   iprianu  = DECODE(SIGN((SELECT icapital
                                             FROM garansegdet
                                            WHERE sseguro = psseguro
                                              AND nriesgo = pnriesgo
                                              AND nmovimi = pnmovimi
                                              AND sproces = psproces
                                              AND cgarant =
                                                  estgaranseg.cgarant) -
                                          pac_tarifas.f_valor_act(psseguro,
                                                                  pnriesgo,
                                                                  cgarant,
                                                                  pnmovimi,
                                                                  'ICAPITAL')),
                                     -1,
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'IPRIANU') -
                                     estgaranseg.iprianu, -- Decremento VA
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'IPRIANU') +
                                     estgaranseg.iprianu -- Incremento VA
                                     ),
                   irecarg  = DECODE(SIGN((SELECT icapital
                                             FROM garansegdet
                                            WHERE sseguro = psseguro
                                              AND nriesgo = pnriesgo
                                              AND nmovimi = pnmovimi
                                              AND sproces = psproces
                                              AND cgarant =
                                                  estgaranseg.cgarant) -
                                          pac_tarifas.f_valor_act(psseguro,
                                                                  pnriesgo,
                                                                  cgarant,
                                                                  pnmovimi,
                                                                  'ICAPITAL')),
                                     -1,
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'IRECARG') -
                                     estgaranseg.irecarg, -- Decremento VA
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'IRECARG') +
                                     estgaranseg.irecarg -- Incremento VA
                                     ),
                   ipritar  = DECODE(SIGN((SELECT icapital
                                             FROM garansegdet
                                            WHERE sseguro = psseguro
                                              AND nriesgo = pnriesgo
                                              AND nmovimi = pnmovimi
                                              AND sproces = psproces
                                              AND cgarant =
                                                  estgaranseg.cgarant) -
                                          pac_tarifas.f_valor_act(psseguro,
                                                                  pnriesgo,
                                                                  cgarant,
                                                                  pnmovimi,
                                                                  'ICAPITAL')),
                                     -1,
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'IPRITAR') -
                                     estgaranseg.ipritar, -- Decremento VA
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'IPRITAR') +
                                     estgaranseg.ipritar -- Incremento VA
                                     ),
                   idtocom  = DECODE(SIGN((SELECT icapital
                                             FROM garansegdet
                                            WHERE sseguro = psseguro
                                              AND nriesgo = pnriesgo
                                              AND nmovimi = pnmovimi
                                              AND sproces = psproces
                                              AND cgarant =
                                                  estgaranseg.cgarant) -
                                          pac_tarifas.f_valor_act(psseguro,
                                                                  pnriesgo,
                                                                  cgarant,
                                                                  pnmovimi,
                                                                  'ICAPITAL')),
                                     -1,
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'IDTOCOM') -
                                     estgaranseg.idtocom, -- Decremento VA
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'IDTOCOM') +
                                     estgaranseg.idtocom -- Incremento VA
                                     ),
                   itarrea  = DECODE(SIGN((SELECT icapital
                                             FROM garansegdet
                                            WHERE sseguro = psseguro
                                              AND nriesgo = pnriesgo
                                              AND nmovimi = pnmovimi
                                              AND sproces = psproces
                                              AND cgarant =
                                                  estgaranseg.cgarant) -
                                          pac_tarifas.f_valor_act(psseguro,
                                                                  pnriesgo,
                                                                  cgarant,
                                                                  pnmovimi,
                                                                  'ICAPITAL')),
                                     -1,
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'ITARREA') -
                                     estgaranseg.itarrea, -- Decremento VA
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'ITARREA') +
                                     estgaranseg.itarrea -- Incremento VA
                                     ),
                   icaptot  = DECODE(SIGN((SELECT icapital
                                             FROM garansegdet
                                            WHERE sseguro = psseguro
                                              AND nriesgo = pnriesgo
                                              AND nmovimi = pnmovimi
                                              AND sproces = psproces
                                              AND cgarant =
                                                  estgaranseg.cgarant) -
                                          pac_tarifas.f_valor_act(psseguro,
                                                                  pnriesgo,
                                                                  cgarant,
                                                                  pnmovimi,
                                                                  'ICAPITAL')),
                                     -1,
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'ICAPTOT') -
                                     estgaranseg.icaptot, -- Decremento VA
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'ICAPTOT') +
                                     estgaranseg.icaptot -- Incremento VA
                                     ),
                   ipritot  = DECODE(SIGN((SELECT icapital
                                             FROM garansegdet
                                            WHERE sseguro = psseguro
                                              AND nriesgo = pnriesgo
                                              AND nmovimi = pnmovimi
                                              AND sproces = psproces
                                              AND cgarant =
                                                  estgaranseg.cgarant) -
                                          pac_tarifas.f_valor_act(psseguro,
                                                                  pnriesgo,
                                                                  cgarant,
                                                                  pnmovimi,
                                                                  'ICAPITAL')),
                                     -1,
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'IPRITOT') -
                                     estgaranseg.ipritot, -- Decremento VA
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'IPRITOT') +
                                     estgaranseg.ipritot -- Incremento VA
                                     )
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND ffinefe IS NULL
               AND f_ctipgar(psproduc,
                             cgarant,
                             pac_seguros.ff_get_actividad(psseguro,
                                                          pnriesgo,
                                                          ptablas)) <> 9
               AND NVL(cobliga, 1) = 1
               AND NVL(ctipgar, 0) NOT IN (8, 9);
         ELSE
            UPDATE garanseg
               SET icapital = DECODE(SIGN((SELECT icapital
                                             FROM garansegdet
                                            WHERE sseguro = psseguro
                                              AND nriesgo = pnriesgo
                                              AND nmovimi = pnmovimi
                                              AND sproces = psproces
                                              AND cgarant = garanseg.cgarant) -
                                          pac_tarifas.f_valor_act(psseguro,
                                                                  pnriesgo,
                                                                  cgarant,
                                                                  pnmovimi,
                                                                  'ICAPITAL')),
                                     -1,
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'ICAPITAL') -
                                     garanseg.icapital, -- Decremento VA
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'ICAPITAL') +
                                     garanseg.icapital -- Incremento VA
                                     ),
                   iprianu  = DECODE(SIGN((SELECT icapital
                                             FROM garansegdet
                                            WHERE sseguro = psseguro
                                              AND nriesgo = pnriesgo
                                              AND nmovimi = pnmovimi
                                              AND sproces = psproces
                                              AND cgarant = garanseg.cgarant) -
                                          pac_tarifas.f_valor_act(psseguro,
                                                                  pnriesgo,
                                                                  cgarant,
                                                                  pnmovimi,
                                                                  'ICAPITAL')),
                                     -1,
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'IPRIANU') -
                                     garanseg.iprianu, -- Decremento VA
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'IPRIANU') +
                                     garanseg.iprianu -- Incremento VA
                                     ),
                   irecarg  = DECODE(SIGN((SELECT icapital
                                             FROM garansegdet
                                            WHERE sseguro = psseguro
                                              AND nriesgo = pnriesgo
                                              AND nmovimi = pnmovimi
                                              AND sproces = psproces
                                              AND cgarant = garanseg.cgarant) -
                                          pac_tarifas.f_valor_act(psseguro,
                                                                  pnriesgo,
                                                                  cgarant,
                                                                  pnmovimi,
                                                                  'ICAPITAL')),
                                     -1,
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'IRECARG') -
                                     garanseg.irecarg, -- Decremento VA
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'IRECARG') +
                                     garanseg.irecarg -- Incremento VA
                                     ),
                   ipritar  = DECODE(SIGN((SELECT icapital
                                             FROM garansegdet
                                            WHERE sseguro = psseguro
                                              AND nriesgo = pnriesgo
                                              AND nmovimi = pnmovimi
                                              AND sproces = psproces
                                              AND cgarant = garanseg.cgarant) -
                                          pac_tarifas.f_valor_act(psseguro,
                                                                  pnriesgo,
                                                                  cgarant,
                                                                  pnmovimi,
                                                                  'ICAPITAL')),
                                     -1,
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'IPRITAR') -
                                     garanseg.ipritar, -- Decremento VA
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'IPRITAR') +
                                     garanseg.ipritar -- Incremento VA
                                     ),
                   idtocom  = DECODE(SIGN((SELECT icapital
                                             FROM garansegdet
                                            WHERE sseguro = psseguro
                                              AND nriesgo = pnriesgo
                                              AND nmovimi = pnmovimi
                                              AND sproces = psproces
                                              AND cgarant = garanseg.cgarant) -
                                          pac_tarifas.f_valor_act(psseguro,
                                                                  pnriesgo,
                                                                  cgarant,
                                                                  pnmovimi,
                                                                  'ICAPITAL')),
                                     -1,
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'IDTOCOM') -
                                     garanseg.idtocom, -- Decremento VA
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'IDTOCOM') +
                                     garanseg.idtocom -- Incremento VA
                                     ),
                   itarrea  = DECODE(SIGN((SELECT icapital
                                             FROM garansegdet
                                            WHERE sseguro = psseguro
                                              AND nriesgo = pnriesgo
                                              AND nmovimi = pnmovimi
                                              AND sproces = psproces
                                              AND cgarant = garanseg.cgarant) -
                                          pac_tarifas.f_valor_act(psseguro,
                                                                  pnriesgo,
                                                                  cgarant,
                                                                  pnmovimi,
                                                                  'ICAPITAL')),
                                     -1,
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'ITARREA') -
                                     garanseg.itarrea, -- Decremento VA
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'ITARREA') +
                                     garanseg.itarrea -- Incremento VA
                                     ),
                   icaptot  = DECODE(SIGN((SELECT icapital
                                             FROM garansegdet
                                            WHERE sseguro = psseguro
                                              AND nriesgo = pnriesgo
                                              AND nmovimi = pnmovimi
                                              AND sproces = psproces
                                              AND cgarant = garanseg.cgarant) -
                                          pac_tarifas.f_valor_act(psseguro,
                                                                  pnriesgo,
                                                                  cgarant,
                                                                  pnmovimi,
                                                                  'ICAPITAL')),
                                     -1,
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'ICAPTOT') -
                                     garanseg.icaptot, -- Decremento VA
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'ICAPTOT') +
                                     garanseg.icaptot -- Incremento VA
                                     ),
                   ipritot  = DECODE(SIGN((SELECT icapital
                                             FROM garansegdet
                                            WHERE sseguro = psseguro
                                              AND nriesgo = pnriesgo
                                              AND nmovimi = pnmovimi
                                              AND sproces = psproces
                                              AND cgarant = garanseg.cgarant) -
                                          pac_tarifas.f_valor_act(psseguro,
                                                                  pnriesgo,
                                                                  cgarant,
                                                                  pnmovimi,
                                                                  'ICAPITAL')),
                                     -1,
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'IPRITOT') -
                                     garanseg.ipritot, -- Decremento VA
                                     pac_tarifas.f_valor_act(psseguro,
                                                             pnriesgo,
                                                             cgarant,
                                                             pnmovimi,
                                                             'IPRITOT') +
                                     garanseg.ipritot -- Incremento VA
                                     )
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND ffinefe IS NULL
               AND f_ctipgar(psproduc,
                             cgarant,
                             pac_seguros.ff_get_actividad(psseguro,
                                                          pnriesgo,
                                                          ptablas)) <> 9;
         END IF;
      END IF;
   END;
   
    
	--CJMR 4779
	PROCEDURE p_valida_garan(psseguro IN NUMBER)
	IS
	  vigencia NUMBER;
	  CURSOR c_valida IS
		SELECT cgarant,
			   icapital
		FROM   estgaranseg
		WHERE  sseguro = psseguro
			   AND MOD(norden, 2) = 0;
	BEGIN
		FOR evento IN c_valida LOOP
			CASE
			  WHEN evento.cgarant = 7030 THEN
				SELECT icapital
				INTO   vigencia
				FROM   estgaranseg
				WHERE  sseguro = psseguro
					   AND cgarant = 7050;

				IF ( NVL(evento.icapital, 0) > NVL(vigencia, 0) ) THEN
				  UPDATE estgaranseg
				  SET    icapital = vigencia
				  WHERE  cgarant = 7030
						 AND sseguro = psseguro;
				END IF;
			  WHEN evento.cgarant = 7031 THEN
				SELECT icapital
				INTO   vigencia
				FROM   estgaranseg
				WHERE  sseguro = psseguro
					   AND cgarant = 7051;

				IF ( NVL(evento.icapital, 0) > NVL(vigencia, 0) ) THEN
				  UPDATE estgaranseg
				  SET    icapital = vigencia
				  WHERE  cgarant = 7031
						 AND sseguro = psseguro;
				END IF;
			  WHEN evento.cgarant = 7032 THEN
				SELECT icapital
				INTO   vigencia
				FROM   estgaranseg
				WHERE  sseguro = psseguro
					   AND cgarant = 7052;

				IF ( NVL(evento.icapital, 0) > NVL(vigencia, 0) ) THEN
				  UPDATE estgaranseg
				  SET    icapital = vigencia
				  WHERE  cgarant = 7032
						 AND sseguro = psseguro;
				END IF;
			  WHEN evento.cgarant = 7033 THEN
				SELECT icapital
				INTO   vigencia
				FROM   estgaranseg
				WHERE  sseguro = psseguro
					   AND cgarant = 7053;

				IF ( NVL(evento.icapital, 0) > NVL(vigencia, 0) ) THEN
				  UPDATE estgaranseg
				  SET    icapital = vigencia
				  WHERE  cgarant = 7033
						 AND sseguro = psseguro;
				END IF;
			  WHEN evento.cgarant = 7034 THEN
				SELECT icapital
				INTO   vigencia
				FROM   estgaranseg
				WHERE  sseguro = psseguro
					   AND cgarant = 7054;

				IF ( NVL(evento.icapital, 0) > NVL(vigencia, 0) ) THEN
				  UPDATE estgaranseg
				  SET    icapital = vigencia
				  WHERE  cgarant = 7034
						 AND sseguro = psseguro;
				END IF;
			  WHEN evento.cgarant = 7035 THEN
				SELECT icapital
				INTO   vigencia
				FROM   estgaranseg
				WHERE  sseguro = psseguro
					   AND cgarant = 7055;

				IF ( NVL(evento.icapital, 0) > NVL(vigencia, 0) ) THEN
				  UPDATE estgaranseg
				  SET    icapital = vigencia
				  WHERE  cgarant = 7035
						 AND sseguro = psseguro;
				END IF;
			  WHEN evento.cgarant = 7036 THEN
				SELECT icapital
				INTO   vigencia
				FROM   estgaranseg
				WHERE  sseguro = psseguro
					   AND cgarant = 7056;

				IF ( NVL(evento.icapital, 0) > NVL(vigencia, 0) ) THEN
				  UPDATE estgaranseg
				  SET    icapital = vigencia
				  WHERE  cgarant = 7036
						 AND sseguro = psseguro;
				END IF;
			  WHEN evento.cgarant = 7037 THEN
				SELECT icapital
				INTO   vigencia
				FROM   estgaranseg
				WHERE  sseguro = psseguro
					   AND cgarant = 7057;

				IF ( NVL(evento.icapital, 0) > NVL(vigencia, 0) ) THEN
				  UPDATE estgaranseg
				  SET    icapital = vigencia
				  WHERE  cgarant = 7037
						 AND sseguro = psseguro;
				END IF;
			  WHEN evento.cgarant = 7038 THEN
				SELECT icapital
				INTO   vigencia
				FROM   estgaranseg
				WHERE  sseguro = psseguro
					   AND cgarant = 7058;

				IF ( NVL(evento.icapital, 0) > NVL(vigencia, 0) ) THEN
				  UPDATE estgaranseg
				  SET    icapital = vigencia
				  WHERE  cgarant = 7038
						 AND sseguro = psseguro;
				END IF;
			  WHEN evento.cgarant = 7039 THEN
				SELECT icapital
				INTO   vigencia
				FROM   estgaranseg
				WHERE  sseguro = psseguro
					   AND cgarant = 7059;

				IF ( NVL(evento.icapital, 0) > NVL(vigencia, 0) ) THEN
				  UPDATE estgaranseg
				  SET    icapital = vigencia
				  WHERE  cgarant = 7039
						 AND sseguro = psseguro;
				END IF;
			  WHEN evento.cgarant = 7040 THEN
				SELECT icapital
				INTO   vigencia
				FROM   estgaranseg
				WHERE  sseguro = psseguro
					   AND cgarant = 7060;

				IF ( NVL(evento.icapital, 0) > NVL(vigencia, 0) ) THEN
				  UPDATE estgaranseg
				  SET    icapital = vigencia
				  WHERE  cgarant = 7040
						 AND sseguro = psseguro;
				END IF;
			  WHEN evento.cgarant = 7041 THEN
				SELECT icapital
				INTO   vigencia
				FROM   estgaranseg
				WHERE  sseguro = psseguro
					   AND cgarant = 7061;

				IF ( NVL(evento.icapital, 0) > NVL(vigencia, 0) ) THEN
				  UPDATE estgaranseg
				  SET    icapital = vigencia
				  WHERE  cgarant = 7041
						 AND sseguro = psseguro;
				END IF;
			  WHEN evento.cgarant = 7042 THEN
				SELECT icapital
				INTO   vigencia
				FROM   estgaranseg
				WHERE  sseguro = psseguro
					   AND cgarant = 7062;

				IF ( NVL(evento.icapital, 0) > NVL(vigencia, 0) ) THEN
				  UPDATE estgaranseg
				  SET    icapital = vigencia
				  WHERE  cgarant = 7042
						 AND sseguro = psseguro;
				END IF;
			  WHEN evento.cgarant = 7043 THEN
				SELECT icapital
				INTO   vigencia
				FROM   estgaranseg
				WHERE  sseguro = psseguro
					   AND cgarant = 7063;

				IF ( NVL(evento.icapital, 0) > NVL(vigencia, 0) ) THEN
				  UPDATE estgaranseg
				  SET    icapital = vigencia
				  WHERE  cgarant = 7043
						 AND sseguro = psseguro;
				END IF;
			  WHEN evento.cgarant = 7044 THEN
				SELECT icapital
				INTO   vigencia
				FROM   estgaranseg
				WHERE  sseguro = psseguro
					   AND cgarant = 7064;

				IF ( NVL(evento.icapital, 0) > NVL(vigencia, 0) ) THEN
				  UPDATE estgaranseg
				  SET    icapital = vigencia
				  WHERE  cgarant = 7044
						 AND sseguro = psseguro;
				END IF;
			  WHEN evento.cgarant = 7045 THEN
				SELECT icapital
				INTO   vigencia
				FROM   estgaranseg
				WHERE  sseguro = psseguro
					   AND cgarant = 7065;

				IF ( NVL(evento.icapital, 0) > NVL(vigencia, 0) ) THEN
				  UPDATE estgaranseg
				  SET    icapital = vigencia
				  WHERE  cgarant = 7045
						 AND sseguro = psseguro;
				END IF;
			  WHEN evento.cgarant = 7046 THEN
				SELECT icapital
				INTO   vigencia
				FROM   estgaranseg
				WHERE  sseguro = psseguro
					   AND cgarant = 7066;

				IF ( NVL(evento.icapital, 0) > NVL(vigencia, 0) ) THEN
				  UPDATE estgaranseg
				  SET    icapital = vigencia
				  WHERE  cgarant = 7046
						 AND sseguro = psseguro;
				END IF;
			  WHEN evento.cgarant = 7784 THEN
				SELECT icapital
				INTO   vigencia
				FROM   estgaranseg
				WHERE  sseguro = psseguro
					   AND cgarant = 7783;

				IF ( NVL(evento.icapital, 0) > NVL(vigencia, 0) ) THEN
				  UPDATE estgaranseg
				  SET    icapital = vigencia
				  WHERE  cgarant = 7784
						 AND sseguro = psseguro;
				END IF;
			  WHEN evento.cgarant = 7786 THEN
				SELECT icapital
				INTO   vigencia
				FROM   estgaranseg
				WHERE  sseguro = psseguro
					   AND cgarant = 7785;

				IF ( NVL(evento.icapital, 0) > NVL(vigencia, 0) ) THEN
				  UPDATE estgaranseg
				  SET    icapital = vigencia
				  WHERE  cgarant = 7786
						 AND sseguro = psseguro;
				END IF;
			  WHEN evento.cgarant = 7790 THEN
				SELECT icapital
				INTO   vigencia
				FROM   estgaranseg
				WHERE  sseguro = psseguro
					   AND cgarant = 7789;

				IF ( NVL(evento.icapital, 0) > NVL(vigencia, 0) ) THEN
				  UPDATE estgaranseg
				  SET    icapital = vigencia
				  WHERE  cgarant = 7790
						 AND sseguro = psseguro;
				END IF;
			  WHEN evento.cgarant = 7794 THEN
				SELECT icapital
				INTO   vigencia
				FROM   estgaranseg
				WHERE  sseguro = psseguro
					   AND cgarant = 7793;

				IF ( NVL(evento.icapital, 0) > NVL(vigencia, 0) ) THEN
				  UPDATE estgaranseg
				  SET    icapital = vigencia
				  WHERE  cgarant = 7794
						 AND sseguro = psseguro;
				END IF;
			END CASE;
		END LOOP;
	END;
	--CJMR 4779

END pac_tarifas;

/
