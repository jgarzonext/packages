--------------------------------------------------------
--  DDL for Package Body PAC_CESIONESREA
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY "PAC_CESIONESREA"
IS
  /******************************************************************************
   NOMBRE:     PAC_CESIONESREA
   PROPÓSITO:  Funciones cesiones al reaseguro
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   -----  ----------  -------- ------------------------------------
   1.0     XX/XX/XXXX   XXX     1. Creación del package.
   1.1     13/05/2009   AVT     2. 0009549: CRE - Reaseguro de ahorro.
   2.0     16/06/2009   ETM     3. 0010462: IAX - REA - Eliminar tabla FACPENDIENTES
   3.0     01/06/2009   NMM     4. 10344: CRE - Cesiones a reaseguro incorrectas.
   4.0     20/10/2009   AVT     5. 10805: CRE - ULK - Creació inicial del producte ULK (Vida Risc)
   5.0     04/11/2009   JGR     6. 11674: CRE - Error en el cálculos de la cesiones de reaseguro para recibos en productos de ahorro
   6.0     17/11/2009   JMF     7. 0012020 CRE - Ajustar reassegurança d'estalvi (PPJ)
   7.0     30/11/2009   RSC     8. 0012178 CRE201 - error en emisión en pólizas colectivas de salud.
   8.0     01/12/2009   NMM     9. 11845.CRE - Ajustar reassegurança d'estalvi.
   9.0     10/02/2010   AVT    10. 0012993: CRE - Reasegurar garantias que no tienen prima
   10.0     19/02/2010   JMF    11. 0012803 AGA - Acceso a la vista PERSONAS
   11.0     04/03/2010   AVT    12. 13338: CRE201 - Error a la cessió d'extorns amb copagament
   12.0     10/03/2010   AVT    13. 0013195: CRE - REA error en el repartiment per trams
   13.0     07/04/2010   AVT    14. 0013946: CRE200 - Incidencia cartera - pólizas retenidas por facultativo
   14.0     03/04/2010   AVT    15. 0014400: CRE203 - Pólizas de Saldo Deutors paradas por cúmulo/facultativo
   15.0     25/05/2010   AVT    16. 14536: s'afegeix si les garanties acumulen entre elles (REACUMGAR)
   16.0     21/06/2010   AVT    17. 0015007: CEM800 - Anul·lacions: error en el tractament de cúmuls
   17.0     01/07/2010   RSC    18. 0013832: APRS015 - suplemento de aportaciones únicas
   18.0     29-07-2010   AVT    19. 0014871: CEM800 - Reaseguro: Nuevo contrato 2010
   19.0     10/08/2010   RSC    20. 14775: AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
   20.0     27/12/2010   JMP    20. 0017106: AGA601 - Reaseguro: Anul·lació del detall del rebut
   21.0     21/02/2010   RSC    21. 0017623: Revisió Cesiones MULTIRRIESGO.
   22.0     03/03/2011   JGR    22. 0017672: CEM800 - Contracte Reaseguro 2011 - Añadir nuevo parámetro cdetces
   23.0     19/10/2011   JRB    23. 19484 - Se añaden las funciones est para el reaseguro.
   24.0     02/01/2012   AVT    24. 19484:  Retención por facultativo antes de emitir la propuesta. control de varias garantías con facutativo
   25.0     31/01/2012   AVT    25. 21051 A0021051: LCOL_T001-LCOL - UAT - TEC - Incidencias Reaseguro: Taules reals al f_crear_facul
   26.0     14/02/2012   JMF    26. 0021242 CCAT998-CEM - Anulación pol vto 60160497
   27.0     07/03/2012   AVT    27. 21559: LCOL999-Cambios en el Reaseguro: fecha ce cesión según la temporalidad del plan (f_renovacion_anual_rea)
   28.0     12/03/2012   AVT    28. 21559: LCOL999-Cambios en el Reaseguro: Distribución de los Capitales con base en la garantía principal
   29.0     26/04/2012   AVT    29.0 0022020: LCOL999-Diferencias en las primas de reaseguro
   30.0     15/05/2012   AVT    30. 22237: LCOL_A002-Incidencias de QT sobre el reaseguro proporcional QT:4564
   31.0     15/02/2013   DCT    16. 0025502: LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos
   32.0     04/03/2013   KBR    17. 0026142: LCOL_A004-Qtracker: 6428: Error al emitir certificado cero después de realizar un supl en un certif individual
   33.0     05/03/2013   KBR    18. 0026321: LCOL_A004-Qtracker: 006337: Cambio Parametrizacion de Contratos
   34.0     14/03/2013   KBR    34. 0026283: Incidencia de cúmulo para colectivos Liberty
   35.0     20/03/2013   AFM    0025803: RSA001 - Ampliar los decimales que utiliza iAXIS
   36.0     20/06/2013   DCT    36. 0027379: LCOL_A004-Qtracker: 0007297: Error en la creacion de cuadros facultativos
   37.0     25/06/2013   RCL    37. 0024697: Canvi mida camp sseguro
   38.0     01/10/2013   AVT    38. 0028396: POSDE400-Incidencia 28393: POSTEC Validacion Reaseguro Facultativo,Accidentes personales (VS BUG: 26663)
   39.0     03/10/2013   AGG    39. 28358 Nueva función para calcular el capital del cumulo
   40.0     09/10/2013   AGG    40. 28358 Cambiado el nombre a la función que devuelve el capital del cumulo porque no cabe en sgt_Term_form
   41.0     10/10/2013   AGG    41. 28358 Cambiado el tipo del parametro pfdnombre a la función que devuelve el capital del cumulo porque no cabe en
   sgt_Term_form
   42.0     14/10/2013   AGG    42. 28358 CModificada la funcion f_capital, no devolvía bien el cúmulo del capital
   43.0     15/10/2013   MMM    43. 0028532: LCOL_A004-Qtracker: 9624: Validar la gestion de propuestas retenidas con suplementos (aumentos-disminuciones)
   facultativo
   44.0     16/10/2013   MMM    44. 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision
   45.0     13/11/2013   AVT    45  0028777: Incidencia 28761: POSREA Reaseguro facultativo
   46.0     26/11/2013   AVT    46  29011: LCOL_A004-Qtracker: 0010100: ERROR CESION DE POLIZAS
   47.0     29/11/2013   MMM    47. 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL
   48.0     10/12/2013   RCL    48. 0029038: LCOL_A002-Revisi? QT Producci?: 10163, 10177, 10178 i 10180
   49.0     19/12/2013   JMF    49. 0029068 La Rehabilitación de póliza no está rehabilitando los recibos
   50.0     27/02/2014   AGG    50. 0030356: Al intentar rehabilitar cualquier póliza aparece el siguiente mensaje "Registro no encontrado
   51.0     04/03/2014   AGG    51. 0030324: POSREA-V.I.PREVIHOY INMEDIATO -CRE. 0% Por un V/A de $25.000.000
   52.0     05/03/2014   KBR    52. 0030311: POSREA-V.I. -POSITIVA VIDA ANUAL Cre.5% Cesion Facultativo no corresponde amparos adicionales
   53.0     31/03/2014   AGG    53. 0030702: POSPG400-POSREA-V.I.REASEGUROS
   54.0     03/04/2014   DCT    54. 0030326: LCOL_A004-Qtracker: 11612 y 11610 (11903)
   55.0     08/05/2014   AGG    55. 0026622: POSND100-(POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 97 - Comisiones calculadas solo sobre extraprima
   0031509: LCOL_A002-Qtracker Produccio:0012660 --> UNIFICACION POLIZAS
   56.0     28/07/2014   DCT    56. 0032363: LCOL_PROD-QT 0013676: La solicitud de poliza No 30063906 hizo cesion sin haber sido emitida y en estado anulada
   57.0     01/09/2014   EDA    57. 0027104: LCOLF3BREA- ID 180 FASE 3B Nota 178353. Cesiones manuales
   58.0     24/11/2014   SHA    58. 0031921: LCOLF3BREA-LCOL_A004-Qtracker: 0013095: Validar condiciones de contratos parametrizados- Reposiciones/
   Reinstalamento.
   59.0     14/01/2015   KBR    59. 0034208: 0016463: No genera los cuadros facultattivos en propuestas retenidas uat
   60.0     27/05/2015   EDA    60  0036180: 0205781: En caso de que se exceda la Sobreprima de la prima se guardara directamente el PRECARG de GARANSEG.
   61.0     17/11/2015   DCT    61  0038692 Añadir nueva función f_calcula_vto_poliza
   62.0     25/04/2016   JCP    62. BUG 41728-234063 --JCP 25/04/2016 Creacion funcion f_control_cesion
   63.0     02/09/2016   HRE    63. CONF-250: Se incluye manejo de contratos Q1, Q2, Q3
   64.0     09/11/2016   HRE    64. CONF-294: Se incluye funciones para cumulo por tomador y zona geografica.
   65.0     20/01/2017   HRE    65. CONF-479: Suplemento aumento de valor
   66.0     22/05/2017   HRE    66. CONF-695: Redistribucion reaseguro
   67.0     29/07/2019   FEPP   67. IAXIS-4612 : No se puede hacer la cesion cuando tiene decimales se modifico procedure traspaso_inf_esttocesionesrea
   68.0     18-11-2019   INFORCOL 68. Reaseguro Fase 1 Sprint 1
   69.0     17-04-2020   FEPP    69. BUG/IAXIS-13249 Debe validarse que el proceso automático de cancelación de pólizas por no pago. Haga la anulación de la cesión de la póliza, pero, que no ejecute también la anulación por regularización.  
   70.0     27/04/2020   DFR    70. IAXIS-12992: Cesión en contratos con más de un tramo
   71.0     06-05-2020   INFORCOL 71. Bug 10555-10556 Reaseguro Ajustes para facultativo Dolares/Euros
   72.0     12/05/2020   JLTS   72. IAXIS-13133: Ajuste de la funcion f_cesdet_anu para que tome las cancelaciones
   ******************************************************************************/
   FUNCTION f_tmpcesaux(
         psproces IN NUMBER,
         psseguro IN NUMBER,
         pnriesgo IN NUMBER,
         pnmovimi IN NUMBER)
      RETURN NUMBER
   IS
      --------------------------------------------------------------------------------
      --   Inserta  a les taules tmp's per tarifar al SGT
      --------------------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_TMPCESAUX';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(p=' || psproces || ' s=' || psseguro || ' r=' || pnriesgo || ' m=' || pnmovimi || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      v_nmovima NUMBER;
      lc        NUMBER;
      hiha      NUMBER;
      -- Bug 0021242 - 14/02/2012 - JMF
      v_garins NUMBER(1);
      v_cempres seguros.cempres%TYPE;      -- BUG 36180 EDA 27/05/2015
      v_psobreprima garanseg.precarg%TYPE; -- BUG 36180 EDA 27/05/2015

      CURSOR preg_garan
      IS
          SELECT    cgarant, nmovima, finiefe
               FROM tmp_garancar
              WHERE sproces = psproces
               AND sseguro  = psseguro
               AND nriesgo  = pnriesgo;

      CURSOR tmp(wsseguro NUMBER, wnriesgo NUMBER, wnmovimi NUMBER)
      IS
          SELECT    g.sseguro, g.cgarant, g.nriesgo, g.finiefe, g.norden, g.ctarifa, DECODE(NVL(ce.icapital, 0), 0, g.icapital, ce.icapital) icapital,
               g.precarg, g.iprianu, g.cformul, g.iextrap, g.ctipfra, g.ifranqu, g.irecarg, g.ipritar, g.pdtocom, g.idtocom,
               g.crevali, g.prevali, g.irevali, g.itarifa, g.itarrea, g.ipritot, g.icaptot, g.ftarifa, g.cderreg, g.feprev,
               g.fpprev, g.percre, g.cref, g.cintref, g.pdif, g.pinttec, g.nparben, nbns, g.tmgaran, g.cmatch,
               g.tdesmat, g.pintfin, g.nmovima, g.nfactor, g.nmovimi, g.idtoint, g.ccampanya, g.nversio, g.cageven, g.nlinea,
               ce.icapaci, ce.ipleno, ce.scontra, ce.nversio nvercon, co.creafac, ce.ipritarrea, ce.idtosel, DECODE(g.ipritar, 0, 0, ROUND(((g.iprianu -
               g.ipritar) * 100 / g.ipritar), 2)) prima,

               -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
               ce.iextrea, ce.itarifrea
               -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
               FROM garanseg g, cesionesaux ce, codicontratos c, contratos co
              WHERE g.sseguro  = wsseguro
               AND g.nriesgo   = wnriesgo
               AND g.nmovimi   = wnmovimi
               AND g.sseguro   = ce.sseguro
               AND g.nriesgo   = ce.nriesgo
               AND g.cgarant   = ce.cgarant
               AND ce.scontra  = c.scontra
               AND ce.sproces  = psproces
               AND ce.scontra IS NOT NULL
               AND ce.nversio IS NOT NULL
               AND ce.scontra  = co.scontra
               AND ce.nversio  = co.nversio
               AND c.cvidaga  IN(1, 2);
      --
   BEGIN
      v_errlin := 1000;
      -- Bug 0021242 - 14/02/2012 - JMF
      v_garins := 0;

      FOR v IN tmp(psseguro, pnriesgo, pnmovimi)
      LOOP
         -- 10805 AVT 20-10-2009 Control de si hi ha formulació assignada a la garantia
         hiha := 0;

         BEGIN
            v_errlin := 1010;

             SELECT    COUNT( * )
                  INTO hiha
                  FROM reaformula
                 WHERE scontra = v.scontra
                  AND nversio  = v.nvercon
                  AND cgarant  = v.cgarant;
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' c=' || v.scontra || ' v=' || v.nvercon || ' g=' || v.cgarant);
            RETURN(9000787); -- Error al recuperar dades formula
         END;

         IF hiha > 0 THEN
            -- 10805 AVT 20-10-2009 fi
            -->-- -- dbms_output.put_line(' PLE I CAPACITAT '||
            -->       v.sseguro ||';'||v.cgarant||';'||v.nriesgo||';'||  v.finiefe||';'||v.norden ||';'||v.ctarifa||';'||
            -->       v.icapital||';'||v.precarg||';'||v.iprianu||';'||  v.cformul||';'||v.iextrap||';'||
            -->       v.ctipfra ||';'||v.ifranqu ||';'|| v.irecarg||';'||v.ipritar||';'||v.pdtocom||';'||
            -->       v.idtocom ||';'||v.crevali||';'||v.prevali||';'||  v.irevali||';'||v.itarifa||';'||v.itarrea||';'||
            -->       v.ipritot ||';'||v.icaptot||';'||v.ftarifa||';'||  v.cderreg||';'||v.feprev ||';'||v.fpprev||';'||
            -->       v.percre  ||';'||v.cref   ||';'||v.cintref||';'||  v.pdif   ||';'||v.pinttec||';'||v.nparben||';'||v.nbns||';'||
            -->       v.tmgaran ||';'||v.cmatch ||';'||v.tdesmat||';'||  v.pintfin||';'||v.nmovima||';'||v.nfactor||';'||
            -->       v.nmovimi ||';'||v.idtoint||';'||v.ccampanya||';'||v.nversio||';'||v.cageven||';'||v.nlinea||';'||
            -->       v.icapaci||';'|| v.ipleno||';'||v.scontra ||';'||  v.nvercon
            -->       ||';'||v.creafac||';'||
            -->       v.ipritarrea||';'||v.idtosel||';'||v.prima
            -->      );
            BEGIN
               v_errlin := 1020;

               -- Inicio EDA 27/05/2015 BUG 36180 Sobreprima excede a la prima excesivamente
                SELECT    cempres
                     INTO v_cempres
                     FROM seguros
                    WHERE sseguro                                                 = v.sseguro;

               v_errlin                                                          := 1021;

               IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'PRECARG_REA'), 0) = 1 THEN
                  v_psobreprima                                                  := v.precarg;
               ELSE
                  v_psobreprima := v.prima;
               END IF;

               -- Fin EDA  BUG 36180
                INSERT
                     INTO tmp_garancar
                     (
                        sseguro, cgarant, nriesgo, finiefe, norden, ctarifa, icapital, precarg, iprianu, ffinefe,
                        cformul, iextrap, ctipfra, ifranqu, sproces, irecarg, ipritar, pdtocom, idtocom, crevali,
                        prevali, irevali, itarifa, itarrea, ipritot, icaptot, ftarifa, cderreg, feprev, fpprev,
                        percre, cref, cintref, pdif, pinttec, nparben, nbns, tmgaran, cmatch, tdesmat,
                        pintfin, nmovima, nfactor, nmovi_ant, idtoint, ccampanya, nversio, cageven, nlinea, icapaci,
                        ipleno, scontra, nvercon, cfacult, ipritarrea, idtosel, psobreprima,
                        -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                        iextrea, itarifrea
                     )
                     -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
                     VALUES
                     (
                        v.sseguro, v.cgarant, v.nriesgo, v.finiefe, v.norden, v.ctarifa, v.icapital, v.precarg, v.iprianu, NULL,
                        v.cformul, v.iextrap, v.ctipfra, v.ifranqu, psproces, v.irecarg, v.ipritar, v.pdtocom, v.idtocom, v.crevali,
                        v.prevali, v.irevali, v.itarifa, v.itarrea, v.ipritot, v.icaptot, v.ftarifa, v.cderreg, v.feprev, v.fpprev,
                        v.percre, v.cref, v.cintref, v.pdif, v.pinttec, v.nparben, v.nbns, v.tmgaran, v.cmatch, v.tdesmat,
                        v.pintfin, v.nmovima, v.nfactor, v.nmovimi, v.idtoint, v.ccampanya, v.nversio, v.cageven, v.nlinea, v.icapaci,
                        v.ipleno, v.scontra, v.nvercon, v.creafac, v.ipritarrea, v.idtosel, v_psobreprima, -- BUG 36180 EDA 27/05/2015
                        -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                        v.iextrea, v.itarifrea
                     );

               -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin

               -- Bug 0021242 - 14/02/2012 - JMF
               v_garins := 1;
            EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               -->-- -- dbms_output.put_line(' dup ');

               -- Bug 0021242 - 14/02/2012 - JMF
               p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, 's=' || v.sseguro || ' g=' || v.cgarant || ' i=' || v.finiefe || ' r=' || v.nriesgo
               || ' p=' || psproces);
               NULL;
            WHEN OTHERS THEN
               -->-- -- dbms_output.put_line('Z  '|| SQLERRM);
               p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,

               -- ini Bug 0020294 - 05/12/2011 - JMF
               --v_errpar || ' s=' || v.sseguro || ' g=' || v.cgarant || ' f='|| v.finiefe || ' r=' || v.nriesgo
               ' 1s=' || v.sseguro || ' g=' || v.cgarant || ' r=' || v.nriesgo || ' i=' || v.finiefe || ' o=' || v.norden || ' t=' || v.ctarifa || ' 2c=' ||
               v.icapital || ' p=' || v.precarg || ' i=' || v.iprianu || ' f=' || v.cformul || ' e=' || v.iextrap || ' 3t=' || v.ctipfra || ' i=' || v.ifranqu
               || ' p=' || psproces || ' r=' || v.irecarg || ' t=' || v.ipritar || ' p=' || v.pdtocom || ' 4d=' || v.idtocom || ' r=' || v.crevali || ' p=' ||
               v.prevali || ' i=' || v.irevali || ' t=' || v.itarifa || ' r=' || v.itarrea || ' 5p=' || v.ipritot || ' c=' || v.icaptot || ' t=' || v.ftarifa
               || ' d=' || v.cderreg || ' p=' || v.feprev || ' f=' || v.fpprev || ' 6p=' || v.percre || ' r=' || v.cref || ' i=' || v.cintref || ' p=' ||
               v.pdif || ' i=' || v.pinttec || ' n=' || v.nparben || ' 7b=' || v.nbns || ' t=' || v.tmgaran || ' m=' || v.cmatch || ' t=' || v.tdesmat || ' i='
               || v.pintfin || ' m=' || v.nmovima || ' 8f=' || v.nfactor || ' n=' || v.nmovimi || ' d=' || v.idtoint || ' c=' || v.ccampanya || ' v=' ||
               v.nversio || ' 9a=' || v.cageven || ' l=' || v.nlinea || ' c=' || v.icapaci || ' p=' || v.ipleno || ' c=' || v.scontra || ' v=' || v.nvercon ||
               ' 10r=' || v.creafac || ' t=' || v.ipritarrea || ' d=' || v.idtosel || ' p=' || v.prima || '*'
               -- fin Bug 0020294 - 05/12/2011 - JMF
               );
               RETURN 111930;
            END;
         END IF; -- AVT 20-10-2009 fi
      END LOOP;

      -- ini Bug 0021242 - 14/02/2012 - JMF
      v_errlin   := 1022;

      IF v_garins = 0 THEN
         -- No hemos encontrado ninguna garantia para insertar.
         -- Error al leer de TMP_GARANCAR
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, v_errpar, 'garins=' || v_garins);
         RETURN 112315;
      END IF;

      -- fin Bug 0021242 - 14/02/2012 - JMF

      --PREGUNTES A NIVELL DE RISC
      BEGIN
         v_errlin := 1030;

          DELETE preguncar
              WHERE sproces = psproces
               AND sseguro  = psseguro
               AND nriesgo  = pnriesgo
               AND nmovimi  = pnmovimi;

         v_errlin          := 1040;

          INSERT
               INTO preguncar
               (
                  sseguro, nriesgo, cpregun, crespue, nmovimi, sproces, trespue
               )
          SELECT    sseguro, nriesgo, cpregun, crespue, nmovimi, psproces, trespue
               FROM pregunseg
              WHERE sseguro = psseguro
               AND nriesgo  = pnriesgo
               AND nmovimi IN
               (SELECT    MAX(nmovimi)
                     FROM pregunseg
                    WHERE sseguro = psseguro
               );

         v_errlin := 1031;

          DELETE preguncartab
              WHERE sproces = psproces
               AND sseguro  = psseguro
               AND nriesgo  = pnriesgo
               AND nmovimi  = pnmovimi;

         v_errlin          := 1041;

          INSERT
               INTO preguncartab
               (
                  sseguro, nriesgo, cpregun, nmovimi, sproces, nlinea, ccolumna, tvalor, fvalor, nvalor
               )
          SELECT    sseguro, nriesgo, cpregun, nmovimi, psproces, nlinea, ccolumna, tvalor, fvalor, nvalor
               FROM pregunsegtab
              WHERE sseguro = psseguro
               AND nriesgo  = pnriesgo
               AND nmovimi IN
               (SELECT    MAX(nmovimi)
                     FROM pregunsegtab
                    WHERE sseguro = psseguro
               );
      EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
      WHEN OTHERS THEN
         -->-- -- dbms_output.put_line(SQLERRM);
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         RETURN 108424;
      END; -- A NIVEL DE RISC

      BEGIN
         v_errlin := 1050;

          DELETE pregunpolcar
              WHERE sproces = psproces
               AND sseguro  = psseguro
               AND nmovimi  = pnmovimi;

         v_errlin          := 1060;

          INSERT
               INTO pregunpolcar
               (
                  sseguro, cpregun, crespue, nmovimi, sproces, trespue
               )
          SELECT    sseguro, cpregun, crespue, nmovimi, psproces, trespue
               FROM pregunpolseg
              WHERE sseguro = psseguro
               AND nmovimi IN
               (SELECT    MAX(nmovimi)
                     FROM pregunpolseg
                    WHERE sseguro = psseguro
               );

         v_errlin := 1051;

          DELETE pregunpolcartab
              WHERE sproces = psproces
               AND sseguro  = psseguro
               AND nmovimi  = pnmovimi;

         v_errlin          := 1061;

          INSERT
               INTO pregunpolcartab
               (
                  sseguro, cpregun, nmovimi, sproces, nlinea, ccolumna, tvalor, fvalor, nvalor
               )
          SELECT    sseguro, cpregun, nmovimi, psproces, nlinea, ccolumna, tvalor, fvalor, nvalor
               FROM pregunpolsegtab
              WHERE sseguro = psseguro
               AND nmovimi IN
               (SELECT    MAX(nmovimi)
                     FROM pregunpolsegtab
                    WHERE sseguro = psseguro
               );
      EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
      WHEN OTHERS THEN
         -->-- -- dbms_output.put_line(SQLERRM);
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         RETURN 108424;
      END; -- A NIVEL DE POLIZA

      BEGIN
         v_errlin := 1070;

          DELETE pregungarancar
              WHERE sproces = psproces
               AND sseguro  = psseguro
               AND nriesgo  = pnriesgo
               AND nmovimi  = pnmovimi;

         v_errlin          := 1080;

          INSERT
               INTO pregungarancar
               (
                  sseguro, nriesgo, cpregun, crespue, nmovimi, sproces, cgarant, nmovima, finiefe, trespue
               )
          SELECT    sseguro, nriesgo, cpregun, crespue, nmovimi, psproces, cgarant, nmovima, finiefe, trespue
               FROM pregungaranseg
              WHERE sseguro = psseguro
               AND nriesgo  = pnriesgo
               AND nmovimi IN
               (SELECT    MAX(nmovimi)
                     FROM pregungaranseg
                    WHERE sseguro = psseguro
               );

         v_errlin := 1071;

          DELETE pregungarancartab
              WHERE sproces = psproces
               AND sseguro  = psseguro
               AND nriesgo  = pnriesgo
               AND nmovimi  = pnmovimi;

         v_errlin          := 1081;

          INSERT
               INTO pregungarancartab
               (
                  sseguro, nriesgo, cpregun, nmovimi, sproces, cgarant, nmovima, finiefe, tvalor, fvalor,
                  nvalor, nlinea, ccolumna
               )
          SELECT    sseguro, nriesgo, cpregun, nmovimi, psproces, cgarant, nmovima, finiefe, tvalor, fvalor,
               nvalor, nlinea, ccolumna
               FROM pregungaransegtab
              WHERE sseguro = psseguro
               AND nriesgo  = pnriesgo
               AND nmovimi IN
               (SELECT    MAX(nmovimi)
                     FROM pregungaransegtab
                    WHERE sseguro = psseguro
               );
      EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
      WHEN OTHERS THEN
         -->-- -- dbms_output.put_line(SQLERRM);
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         RETURN 108424;
      END; -- A NIVEL DE POLIZA

      -- FALTA :
      -- para cada una de las garantia
      -- INSERTAR PREGUNCARANCAR
      RETURN 0;
   EXCEPTION
   WHEN OTHERS THEN
      -->-- -- dbms_output.put_line('2 '||SQLERRM);
      p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
      RETURN 108424;
   END f_tmpcesaux;

--BUG 19484 - 19/10/2011 - JRB - Se añaden las funciones est para el reaseguro.
-- Estas funciones contemplan tanto el trato de las tablas EST como el de las reales
---------------------------------------------------------------------------------------
   FUNCTION f_tmpcesaux_est(
         psproces IN NUMBER,
         psseguro IN NUMBER,
         pnriesgo IN NUMBER,
         pnmovimi IN NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER
   IS
      --------------------------------------------------------------------------------
      --   Inserta  a les taules tmp's per tarifar al SGT
      --------------------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_TMPCESAUX_EST';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(p=' || psproces || ' s=' || psseguro || ' r=' || pnriesgo || ' m=' || pnmovimi || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      v_nmovima NUMBER;
      lc        NUMBER;
      hiha      NUMBER;
      v_cempres seguros.cempres%TYPE;      -- BUG 36180 EDA 27/05/2015
      v_psobreprima garanseg.precarg%TYPE; -- BUG 36180 EDA 27/05/2015

      CURSOR preg_garan
      IS
          SELECT    cgarant, nmovima, finiefe
               FROM tmp_garancar
              WHERE sproces = psproces
               AND sseguro  = psseguro
               AND nriesgo  = pnriesgo;

      CURSOR tmp_est(wsseguro NUMBER, wnriesgo NUMBER, wnmovimi NUMBER)
      IS
          SELECT    g.sseguro, g.cgarant, g.nriesgo, g.finiefe, g.norden, g.ctarifa, DECODE(NVL(ce.icapital, 0), 0, g.icapital, ce.icapital) icapital,
               g.precarg, g.iprianu, g.cformul, g.iextrap, g.ctipfra, g.ifranqu, g.irecarg, g.ipritar, g.pdtocom, g.idtocom,
               g.crevali, g.prevali, g.irevali, g.itarifa, g.itarrea, g.ipritot, g.icaptot, g.ftarifa, g.cderreg, g.feprev,
               g.fpprev, g.percre, g.cref, g.cintref, g.pdif, g.pinttec, g.nparben, nbns, g.tmgaran, g.cmatch,
               g.tdesmat, g.pintfin, g.nmovima, g.nfactor, g.nmovimi, g.idtoint, g.ccampanya, g.nversio, g.cageven, g.nlinea,
               ce.icapaci, ce.ipleno, ce.scontra, ce.nversio nvercon, co.creafac, ce.ipritarrea, ce.idtosel, DECODE(g.ipritar, 0, 0, ROUND(((g.iprianu -
               g.ipritar) * 100 / g.ipritar), 2)) prima,

               -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
               ce.iextrea, ce.itarifrea
               -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - fin
               FROM estgaranseg g, cesionesaux ce, codicontratos c, contratos co
              WHERE g.sseguro = wsseguro
               AND g.nriesgo  = wnriesgo
               AND g.nmovimi --= wnmovimi -- AVT 02/12/2013 EL MOVIMENT NO TE PERQUE COINCIDIRÇ
               IN
               (SELECT    MAX(nmovimi)
                     FROM estgaranseg
                    WHERE sseguro = wsseguro
               )
            AND g.sseguro   = ce.sseguro
            AND g.nriesgo   = ce.nriesgo
            AND g.cgarant   = ce.cgarant
            AND ce.scontra  = c.scontra
            AND ce.sproces  = psproces
            AND ce.scontra IS NOT NULL
            AND ce.nversio IS NOT NULL
            AND ce.scontra  = co.scontra
            AND ce.nversio  = co.nversio
            AND c.cvidaga  IN(1, 2)
            AND g.cobliga   = 1; -- 21051 AVT 25/01/2012;

      CURSOR tmp(wsseguro NUMBER, wnriesgo NUMBER, wnmovimi NUMBER)
      IS
          SELECT    g.sseguro, g.cgarant, g.nriesgo, g.finiefe, g.norden, g.ctarifa, DECODE(NVL(ce.icapital, 0), 0, g.icapital, ce.icapital) icapital,
               g.precarg, g.iprianu, g.cformul, g.iextrap, g.ctipfra, g.ifranqu, g.irecarg, g.ipritar, g.pdtocom, g.idtocom,
               g.crevali, g.prevali, g.irevali, g.itarifa, g.itarrea, g.ipritot, g.icaptot, g.ftarifa, g.cderreg, g.feprev,
               g.fpprev, g.percre, g.cref, g.cintref, g.pdif, g.pinttec, g.nparben, nbns, g.tmgaran, g.cmatch,
               g.tdesmat, g.pintfin, g.nmovima, g.nfactor, g.nmovimi, g.idtoint, g.ccampanya, g.nversio, g.cageven, g.nlinea,
               ce.icapaci, ce.ipleno, ce.scontra, ce.nversio nvercon, co.creafac, ce.ipritarrea, ce.idtosel, DECODE(g.ipritar, 0, 0, ROUND(((g.iprianu -
               g.ipritar) * 100 / g.ipritar), 2)) prima,

               -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
               ce.iextrea, ce.itarifrea
               -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
               FROM garanseg g, cesionesaux ce, codicontratos c, contratos co
              WHERE g.sseguro  = wsseguro
               AND g.nriesgo   = wnriesgo
               AND g.nmovimi   = wnmovimi
               AND g.sseguro   = ce.sseguro
               AND g.nriesgo   = ce.nriesgo
               AND g.cgarant   = ce.cgarant
               AND ce.scontra  = c.scontra
               AND ce.sproces  = psproces
               AND ce.scontra IS NOT NULL
               AND ce.nversio IS NOT NULL
               AND ce.scontra  = co.scontra
               AND ce.nversio  = co.nversio
               AND c.cvidaga  IN(1, 2);

      CURSOR tmp_car(wsseguro NUMBER, wnriesgo NUMBER)
      IS
          SELECT    g.sseguro, g.cgarant, g.nriesgo, g.finiefe, g.norden, g.ctarifa, DECODE(NVL(ce.icapital, 0), 0, g.icapital, ce.icapital) icapital,
               g.precarg, g.iprianu, g.cformul, g.iextrap, g.ctipfra, g.ifranqu, g.irecarg, g.ipritar, g.pdtocom, g.idtocom,
               g.crevali, g.prevali, g.irevali, g.itarifa, g.itarrea, g.ipritot, g.icaptot, g.ftarifa, g.cderreg, g.feprev,
               g.fpprev, g.percre, g.cref, g.cintref, g.pdif, g.pinttec, g.nparben, nbns, g.tmgaran, g.cmatch,
               g.tdesmat, g.pintfin, g.nmovima, g.nfactor, g.nmovima nmovimi, g.idtoint, g.ccampanya, g.nversio, g.cageven, g.nlinea,
               ce.icapaci, ce.ipleno, ce.scontra, ce.nversio nvercon, co.creafac, ce.ipritarrea, ce.idtosel, DECODE(g.ipritar, 0, 0, ROUND(((g.iprianu -
               g.ipritar) * 100 / g.ipritar), 2)) prima,

               -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
               ce.iextrea, ce.itarifrea
               -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
               FROM garancar g, cesionesaux ce, codicontratos c, contratos co
              WHERE g.sseguro  = wsseguro
               AND g.nriesgo   = wnriesgo
               AND g.sseguro   = ce.sseguro
               AND g.nriesgo   = ce.nriesgo
               AND g.cgarant   = ce.cgarant
               AND g.sproces   = psproces
               AND ce.scontra  = c.scontra
               AND ce.sproces  = psproces
               AND ce.scontra IS NOT NULL
               AND ce.nversio IS NOT NULL
               AND ce.scontra  = co.scontra
               AND ce.nversio  = co.nversio
               AND c.cvidaga  IN(1, 2);
   BEGIN
      v_errlin  := 1000;

      IF ptablas = 'EST' THEN
         FOR v IN tmp_est(psseguro, pnriesgo, pnmovimi)
         LOOP
            -- 10805 AVT 20-10-2009 Control de si hi ha formulació assignada a la garantia
            hiha := 0;

            BEGIN
               v_errlin := 1010;

                SELECT    COUNT( * )
                     INTO hiha
                     FROM reaformula
                    WHERE scontra = v.scontra
                     AND nversio  = v.nvercon
                     AND cgarant  = v.cgarant;
            EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' c=' || v.scontra || ' v=' || v.nvercon || ' g=' || v.cgarant);
               RETURN(9000787); -- Error al recuperar dades formula
            END;

            IF hiha > 0 THEN
               -- 10805 AVT 20-10-2009 fi
               -->-- -- dbms_output.put_line(' PLE I CAPACITAT '||
               -->       v.sseguro ||';'||v.cgarant||';'||v.nriesgo||';'||  v.finiefe||';'||v.norden ||';'||v.ctarifa||';'||
               -->       v.icapital||';'||v.precarg||';'||v.iprianu||';'||  v.cformul||';'||v.iextrap||';'||
               -->       v.ctipfra ||';'||v.ifranqu ||';'|| v.irecarg||';'||v.ipritar||';'||v.pdtocom||';'||
               -->       v.idtocom ||';'||v.crevali||';'||v.prevali||';'||  v.irevali||';'||v.itarifa||';'||v.itarrea||';'||
               -->       v.ipritot ||';'||v.icaptot||';'||v.ftarifa||';'||  v.cderreg||';'||v.feprev ||';'||v.fpprev||';'||
               -->       v.percre  ||';'||v.cref   ||';'||v.cintref||';'||  v.pdif   ||';'||v.pinttec||';'||v.nparben||';'||v.nbns||';'||
               -->       v.tmgaran ||';'||v.cmatch ||';'||v.tdesmat||';'||  v.pintfin||';'||v.nmovima||';'||v.nfactor||';'||
               -->       v.nmovimi ||';'||v.idtoint||';'||v.ccampanya||';'||v.nversio||';'||v.cageven||';'||v.nlinea||';'||
               -->       v.icapaci||';'|| v.ipleno||';'||v.scontra ||';'||  v.nvercon
               -->       ||';'||v.creafac||';'||
               -->       v.ipritarrea||';'||v.idtosel||';'||v.prima
               -->      );
               BEGIN
                  v_errlin := 1020;

                  -- Inicio EDA 27/05/2015 BUG 36180 Sobreprima excede a la prima excesivamente
                   SELECT    cempres
                        INTO v_cempres
                        FROM estseguros
                       WHERE sseguro                                                 = v.sseguro;

                  v_errlin                                                          := 1021;

                  IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'PRECARG_REA'), 0) = 1 THEN
                     v_psobreprima                                                  := v.precarg;
                  ELSE
                     v_psobreprima := v.prima;
                  END IF;

                  -- Fin EDA  BUG 36180
                   INSERT
                        INTO tmp_garancar
                        (
                           sseguro, cgarant, nriesgo, finiefe, norden, ctarifa, icapital, precarg, iprianu, ffinefe,
                           cformul, iextrap, ctipfra, ifranqu, sproces, irecarg, ipritar, pdtocom, idtocom, crevali,
                           prevali, irevali, itarifa, itarrea, ipritot, icaptot, ftarifa, cderreg, feprev, fpprev,
                           percre, cref, cintref, pdif, pinttec, nparben, nbns, tmgaran, cmatch, tdesmat,
                           pintfin, nmovima, nfactor, nmovi_ant, idtoint, ccampanya, nversio, cageven, nlinea, icapaci,
                           ipleno, scontra, nvercon, cfacult, ipritarrea, idtosel, psobreprima,
                           -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                           iextrea, itarifrea
                        )
                        -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
                        VALUES
                        (
                           v.sseguro, v.cgarant, v.nriesgo, v.finiefe, v.norden, v.ctarifa, v.icapital, v.precarg, v.iprianu, NULL,
                           v.cformul, v.iextrap, v.ctipfra, v.ifranqu, psproces, v.irecarg, v.ipritar, v.pdtocom, v.idtocom, v.crevali,
                           v.prevali, v.irevali, v.itarifa, v.itarrea, v.ipritot, v.icaptot, v.ftarifa, v.cderreg, v.feprev, v.fpprev,
                           v.percre, v.cref, v.cintref, v.pdif, v.pinttec, v.nparben, v.nbns, v.tmgaran, v.cmatch, v.tdesmat,
                           v.pintfin, v.nmovima, v.nfactor, v.nmovimi, v.idtoint, v.ccampanya, v.nversio, v.cageven, v.nlinea, v.icapaci,
                           v.ipleno, v.scontra, v.nvercon, v.creafac, v.ipritarrea, v.idtosel, v_psobreprima, -- BUG 36180 EDA 27/05/2015
                           -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                           v.iextrea, v.itarifrea
                        );
                  -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
               EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  -->-- -- dbms_output.put_line(' dup ');
                  NULL;
               WHEN OTHERS THEN
                  -->-- -- dbms_output.put_line('Z  '|| SQLERRM);
                  p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' s=' || v.sseguro || ' g=' || v.cgarant || ' f=' || v.finiefe ||
                  ' r=' || v.nriesgo);
                  RETURN 111930;
               END;
            END IF; -- AVT 20-10-2009 fi
         END LOOP;
      ELSIF ptablas = 'CAR' THEN
         FOR v IN tmp_car
         (
            psseguro, pnriesgo
         )
         LOOP
            -- 10805 AVT 20-10-2009 Control de si hi ha formulació assignada a la garantia
            hiha := 0;

            BEGIN
               v_errlin := 1010;

                SELECT    COUNT( * )
                     INTO hiha
                     FROM reaformula
                    WHERE scontra = v.scontra
                     AND nversio  = v.nvercon
                     AND cgarant  = v.cgarant;
            EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' c=' || v.scontra || ' v=' || v.nvercon || ' g=' || v.cgarant);
               RETURN(9000787); -- Error al recuperar dades formula
            END;

            IF hiha > 0 THEN
               -- 10805 AVT 20-10-2009 fi
               --p_control_error('RSC', 'PAC_CESIONESREA', ' PLE I CAPACITAT '||
               --        v.sseguro ||';'||v.cgarant||';'||v.nriesgo||';'||  v.finiefe||';'||v.norden ||';'||v.ctarifa||';'||
               --        v.icapital||';'||v.precarg||';'||v.iprianu||';'||  v.cformul||';'||v.iextrap||';'||
               --        v.ctipfra ||';'||v.ifranqu ||';'|| v.irecarg||';'||v.ipritar||';'||v.pdtocom||';'||
               --        v.idtocom ||';'||v.crevali||';'||v.prevali||';'||  v.irevali||';'||v.itarifa||';'||v.itarrea||';'||
               --        v.ipritot ||';'||v.icaptot||';'||v.ftarifa||';'||  v.cderreg||';'||v.feprev ||';'||v.fpprev||';'||
               --        v.percre  ||';'||v.cref   ||';'||v.cintref||';'||  v.pdif   ||';'||v.pinttec||';'||v.nparben||';'||v.nbns||';'||
               --        v.tmgaran ||';'||v.cmatch ||';'||v.tdesmat||';'||  v.pintfin||';'||v.nmovima||';'||v.nfactor||';'||
               --        v.nmovimi ||';'||v.idtoint||';'||v.ccampanya||';'||v.nversio||';'||v.cageven||';'||v.nlinea||';'||
               --        v.icapaci||';'|| v.ipleno||';'||v.scontra ||';'||  v.nvercon
               --       ||';'||v.creafac||';'||
               --        v.ipritarrea||';'||v.idtosel||';'||v.prima
               --       );
               BEGIN
                  v_errlin := 1020;

                  -- Inicio EDA 27/05/2015 BUG 36180 Sobreprima excede a la prima excesivamente
                   SELECT    cempres
                        INTO v_cempres
                        FROM seguros
                       WHERE sseguro                                                 = v.sseguro;

                  v_errlin                                                          := 1021;

                  IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'PRECARG_REA'), 0) = 1 THEN
                     v_psobreprima                                                  := v.precarg;
                  ELSE
                     v_psobreprima := v.prima;
                  END IF;

                  -- Fin EDA  BUG 36180
                   INSERT
                        INTO tmp_garancar
                        (
                           sseguro, cgarant, nriesgo, finiefe, norden, ctarifa, icapital, precarg, iprianu, ffinefe,
                           cformul, iextrap, ctipfra, ifranqu, sproces, irecarg, ipritar, pdtocom, idtocom, crevali,
                           prevali, irevali, itarifa, itarrea, ipritot, icaptot, ftarifa, cderreg, feprev, fpprev,
                           percre, cref, cintref, pdif, pinttec, nparben, nbns, tmgaran, cmatch, tdesmat,
                           pintfin, nmovima, nfactor, nmovi_ant, idtoint, ccampanya, nversio, cageven, nlinea, icapaci,
                           ipleno, scontra, nvercon, cfacult, ipritarrea, idtosel, psobreprima,
                           -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                           iextrea, itarifrea
                        )
                        -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
                        VALUES
                        (
                           v.sseguro, v.cgarant, v.nriesgo, v.finiefe, v.norden, v.ctarifa, v.icapital, v.precarg, v.iprianu, NULL,
                           v.cformul, v.iextrap, v.ctipfra, v.ifranqu, psproces, v.irecarg, v.ipritar, v.pdtocom, v.idtocom, v.crevali,
                           v.prevali, v.irevali, v.itarifa, v.itarrea, v.ipritot, v.icaptot, v.ftarifa, v.cderreg, v.feprev, v.fpprev,
                           v.percre, v.cref, v.cintref, v.pdif, v.pinttec, v.nparben, v.nbns, v.tmgaran, v.cmatch, v.tdesmat,
                           v.pintfin, v.nmovima, v.nfactor, v.nmovimi, v.idtoint, v.ccampanya, v.nversio, v.cageven, v.nlinea, v.icapaci,
                           v.ipleno, v.scontra, v.nvercon, v.creafac, v.ipritarrea, v.idtosel, v_psobreprima, -- BUG 36180 EDA 27/05/2015
                           -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                           v.iextrea, v.itarifrea
                        );
                  -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
               EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  -->-- -- dbms_output.put_line(' dup ');
                  NULL;
               WHEN OTHERS THEN
                  -->-- -- dbms_output.put_line('Z  '|| SQLERRM);
                  p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' s=' || v.sseguro || ' g=' || v.cgarant || ' f=' || v.finiefe ||
                  ' r=' || v.nriesgo);
                  RETURN 111930;
               END;
            END IF; -- AVT 20-10-2009 fi
         END LOOP;
      ELSE
         FOR v IN tmp
         (
            psseguro, pnriesgo, pnmovimi
         )
         LOOP
            -- 10805 AVT 20-10-2009 Control de si hi ha formulació assignada a la garantia
            hiha := 0;

            BEGIN
               v_errlin := 1010;

                SELECT    COUNT( * )
                     INTO hiha
                     FROM reaformula
                    WHERE scontra = v.scontra
                     AND nversio  = v.nvercon
                     AND cgarant  = v.cgarant;
            EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' c=' || v.scontra || ' v=' || v.nvercon || ' g=' || v.cgarant);
               RETURN(9000787); -- Error al recuperar dades formula
            END;

            IF hiha > 0 THEN
               -- 10805 AVT 20-10-2009 fi
               -->-- -- dbms_output.put_line(' PLE I CAPACITAT '||
               -->       v.sseguro ||';'||v.cgarant||';'||v.nriesgo||';'||  v.finiefe||';'||v.norden ||';'||v.ctarifa||';'||
               -->       v.icapital||';'||v.precarg||';'||v.iprianu||';'||  v.cformul||';'||v.iextrap||';'||
               -->       v.ctipfra ||';'||v.ifranqu ||';'|| v.irecarg||';'||v.ipritar||';'||v.pdtocom||';'||
               -->       v.idtocom ||';'||v.crevali||';'||v.prevali||';'||  v.irevali||';'||v.itarifa||';'||v.itarrea||';'||
               -->       v.ipritot ||';'||v.icaptot||';'||v.ftarifa||';'||  v.cderreg||';'||v.feprev ||';'||v.fpprev||';'||
               -->       v.percre  ||';'||v.cref   ||';'||v.cintref||';'||  v.pdif   ||';'||v.pinttec||';'||v.nparben||';'||v.nbns||';'||
               -->       v.tmgaran ||';'||v.cmatch ||';'||v.tdesmat||';'||  v.pintfin||';'||v.nmovima||';'||v.nfactor||';'||
               -->       v.nmovimi ||';'||v.idtoint||';'||v.ccampanya||';'||v.nversio||';'||v.cageven||';'||v.nlinea||';'||
               -->       v.icapaci||';'|| v.ipleno||';'||v.scontra ||';'||  v.nvercon
               -->       ||';'||v.creafac||';'||
               -->       v.ipritarrea||';'||v.idtosel||';'||v.prima
               -->      );
               BEGIN
                  v_errlin := 1020;

                  -- Inicio EDA 27/05/2015 BUG 36180 Sobreprima excede a la prima excesivamente
                   SELECT    cempres
                        INTO v_cempres
                        FROM seguros
                       WHERE sseguro                                                 = v.sseguro;

                  v_errlin                                                          := 1021;

                  IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'PRECARG_REA'), 0) = 1 THEN
                     v_psobreprima                                                  := v.precarg;
                  ELSE
                     v_psobreprima := v.prima;
                  END IF;

                  -- Fin EDA  BUG 36180
                   INSERT
                        INTO tmp_garancar
                        (
                           sseguro, cgarant, nriesgo, finiefe, norden, ctarifa, icapital, precarg, iprianu, ffinefe,
                           cformul, iextrap, ctipfra, ifranqu, sproces, irecarg, ipritar, pdtocom, idtocom, crevali,
                           prevali, irevali, itarifa, itarrea, ipritot, icaptot, ftarifa, cderreg, feprev, fpprev,
                           percre, cref, cintref, pdif, pinttec, nparben, nbns, tmgaran, cmatch, tdesmat,
                           pintfin, nmovima, nfactor, nmovi_ant, idtoint, ccampanya, nversio, cageven, nlinea, icapaci,
                           ipleno, scontra, nvercon, cfacult, ipritarrea, idtosel, psobreprima,
                           -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                           iextrea, itarifrea
                        )
                        -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
                        VALUES
                        (
                           v.sseguro, v.cgarant, v.nriesgo, v.finiefe, v.norden, v.ctarifa, v.icapital, v.precarg, v.iprianu, NULL,
                           v.cformul, v.iextrap, v.ctipfra, v.ifranqu, psproces, v.irecarg, v.ipritar, v.pdtocom, v.idtocom, v.crevali,
                           v.prevali, v.irevali, v.itarifa, v.itarrea, v.ipritot, v.icaptot, v.ftarifa, v.cderreg, v.feprev, v.fpprev,
                           v.percre, v.cref, v.cintref, v.pdif, v.pinttec, v.nparben, v.nbns, v.tmgaran, v.cmatch, v.tdesmat,
                           v.pintfin, v.nmovima, v.nfactor, v.nmovimi, v.idtoint, v.ccampanya, v.nversio, v.cageven, v.nlinea, v.icapaci,
                           v.ipleno, v.scontra, v.nvercon, v.creafac, v.ipritarrea, v.idtosel, v_psobreprima, -- BUG 36180 EDA 27/05/2015
                           -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                           v.iextrea, v.itarifrea
                        );
                  -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
               EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  -->-- -- dbms_output.put_line(' dup ');
                  NULL;
               WHEN OTHERS THEN
                  -->-- -- dbms_output.put_line('Z  '|| SQLERRM);
                  p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' s=' || v.sseguro || ' g=' || v.cgarant || ' f=' || v.finiefe ||
                  ' r=' || v.nriesgo);
                  RETURN 111930;
               END;
            END IF; -- AVT 20-10-2009 fi
         END LOOP;
      END IF;

      --PREGUNTES A NIVELL DE RISC
      BEGIN
         v_errlin := 1030;

          DELETE preguncar
              WHERE sproces = psproces
               AND sseguro  = psseguro
               AND nriesgo  = pnriesgo
               AND nmovimi  = pnmovimi;

         v_errlin          := 1040;

         IF ptablas         = 'EST' THEN
             INSERT
                  INTO preguncar
                  (
                     sseguro, nriesgo, cpregun, crespue, nmovimi, sproces, trespue
                  )
             SELECT    sseguro, nriesgo, cpregun, crespue, nmovimi, psproces, trespue
                  FROM estpregunseg
                 WHERE sseguro = psseguro
                  AND nriesgo  = pnriesgo
                  AND nmovimi IN
                  (SELECT    MAX(nmovimi)
                        FROM estpregunseg
                       WHERE sseguro = psseguro
                  );
         ELSE
             INSERT
                  INTO preguncar
                  (
                     sseguro, nriesgo, cpregun, crespue, nmovimi, sproces, trespue
                  )
             SELECT    sseguro, nriesgo, cpregun, crespue, nmovimi, psproces, trespue
                  FROM pregunseg
                 WHERE sseguro = psseguro
                  AND nriesgo  = pnriesgo
                  AND nmovimi IN
                  (SELECT    MAX(nmovimi)
                        FROM pregunseg
                       WHERE sseguro = psseguro
                  );
         END IF;

         v_errlin := 1031;

          DELETE preguncartab
              WHERE sproces = psproces
               AND sseguro  = psseguro
               AND nriesgo  = pnriesgo
               AND nmovimi  = pnmovimi;

         v_errlin          := 1041;

         IF ptablas         = 'EST' THEN
             INSERT
                  INTO preguncartab
                  (
                     sseguro, nriesgo, cpregun, nmovimi, sproces, nlinea, ccolumna, tvalor, fvalor, nvalor
                  )
             SELECT    sseguro, nriesgo, cpregun, nmovimi, psproces, nlinea, ccolumna, tvalor, fvalor, nvalor
                  FROM estpregunsegtab
                 WHERE sseguro = psseguro
                  AND nriesgo  = pnriesgo
                  AND nmovimi IN
                  (SELECT    MAX(nmovimi)
                        FROM estpregunsegtab
                       WHERE sseguro = psseguro
                  );
         ELSE
             INSERT
                  INTO preguncartab
                  (
                     sseguro, nriesgo, cpregun, nmovimi, sproces, nlinea, ccolumna, tvalor, fvalor, nvalor
                  )
             SELECT    sseguro, nriesgo, cpregun, nmovimi, psproces, nlinea, ccolumna, tvalor, fvalor, nvalor
                  FROM pregunsegtab
                 WHERE sseguro = psseguro
                  AND nriesgo  = pnriesgo
                  AND nmovimi IN
                  (SELECT    MAX(nmovimi)
                        FROM pregunsegtab
                       WHERE sseguro = psseguro
                  );
         END IF;
      EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
      WHEN OTHERS THEN
         -->-- -- dbms_output.put_line(SQLERRM);
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         RETURN 108424;
      END; -- A NIVEL DE RISC

      BEGIN
         v_errlin := 1050;

          DELETE pregunpolcar
              WHERE sproces = psproces
               AND sseguro  = psseguro
               AND nmovimi  = pnmovimi;

         v_errlin          := 1060;

         IF ptablas         = 'EST' THEN
             INSERT
                  INTO pregunpolcar
                  (
                     sseguro, cpregun, crespue, nmovimi, sproces, trespue
                  )
             SELECT    sseguro, cpregun, crespue, nmovimi, psproces, trespue
                  FROM estpregunpolseg
                 WHERE sseguro = psseguro
                  AND nmovimi IN
                  (SELECT    MAX(nmovimi)
                        FROM estpregunpolseg
                       WHERE sseguro = psseguro
                  );
         ELSE
             INSERT
                  INTO pregunpolcar
                  (
                     sseguro, cpregun, crespue, nmovimi, sproces, trespue
                  )
             SELECT    sseguro, cpregun, crespue, nmovimi, psproces, trespue
                  FROM pregunpolseg
                 WHERE sseguro = psseguro
                  AND nmovimi IN
                  (SELECT    MAX(nmovimi)
                        FROM pregunpolseg
                       WHERE sseguro = psseguro
                  );
         END IF;

         v_errlin := 1051;

          DELETE pregunpolcartab
              WHERE sproces = psproces
               AND sseguro  = psseguro
               AND nmovimi  = pnmovimi;

         v_errlin          := 1061;

         IF ptablas         = 'EST' THEN
             INSERT
                  INTO pregunpolcartab
                  (
                     sseguro, cpregun, nmovimi, sproces, nlinea, ccolumna, tvalor, fvalor, nvalor
                  )
             SELECT    sseguro, cpregun, nmovimi, psproces, nlinea, ccolumna, tvalor, fvalor, nvalor
                  FROM estpregunpolsegtab
                 WHERE sseguro = psseguro
                  AND nmovimi IN
                  (SELECT    MAX(nmovimi)
                        FROM estpregunpolsegtab
                       WHERE sseguro = psseguro
                  );
         ELSE
             INSERT
                  INTO pregunpolcartab
                  (
                     sseguro, cpregun, nmovimi, sproces, nlinea, ccolumna, tvalor, fvalor, nvalor
                  )
             SELECT    sseguro, cpregun, nmovimi, psproces, nlinea, ccolumna, tvalor, fvalor, nvalor
                  FROM pregunpolsegtab
                 WHERE sseguro = psseguro
                  AND nmovimi IN
                  (SELECT    MAX(nmovimi)
                        FROM pregunpolsegtab
                       WHERE sseguro = psseguro
                  );
         END IF;
      EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
      WHEN OTHERS THEN
         -->-- -- dbms_output.put_line(SQLERRM);
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         RETURN 108424;
      END; -- A NIVEL DE POLIZA

      BEGIN
         v_errlin := 1070;

          DELETE pregungarancar
              WHERE sproces = psproces
               AND sseguro  = psseguro
               AND nriesgo  = pnriesgo
               AND nmovimi  = pnmovimi;

         v_errlin          := 1080;

         IF ptablas         = 'EST' THEN
             INSERT
                  INTO pregungarancar
                  (
                     sseguro, nriesgo, cpregun, crespue, nmovimi, sproces, cgarant, nmovima, finiefe, trespue
                  )
             SELECT    sseguro, nriesgo, cpregun, crespue, nmovimi, psproces, cgarant, nmovima, finiefe, trespue
                  FROM estpregungaranseg
                 WHERE sseguro = psseguro
                  AND nriesgo  = pnriesgo
                  AND nmovimi IN
                  (SELECT    MAX(nmovimi)
                        FROM estpregungaranseg
                       WHERE sseguro = psseguro
                  );
         ELSE
             INSERT
                  INTO pregungarancar
                  (
                     sseguro, nriesgo, cpregun, crespue, nmovimi, sproces, cgarant, nmovima, finiefe, trespue
                  )
             SELECT    sseguro, nriesgo, cpregun, crespue, nmovimi, psproces, cgarant, nmovima, finiefe, trespue
                  FROM pregungaranseg
                 WHERE sseguro = psseguro
                  AND nriesgo  = pnriesgo
                  AND nmovimi IN
                  (SELECT    MAX(nmovimi)
                        FROM pregungaranseg
                       WHERE sseguro = psseguro
                  );
         END IF;

         v_errlin := 1071;

          DELETE pregungarancartab
              WHERE sproces = psproces
               AND sseguro  = psseguro
               AND nriesgo  = pnriesgo
               AND nmovimi  = pnmovimi;

         v_errlin          := 1081;

         IF ptablas         = 'EST' THEN
             INSERT
                  INTO pregungarancartab
                  (
                     sseguro, nriesgo, cpregun, nmovimi, sproces, cgarant, nmovima, finiefe, tvalor, fvalor,
                     nvalor, nlinea, ccolumna
                  )
             SELECT    sseguro, nriesgo, cpregun, nmovimi, psproces, cgarant, nmovima, finiefe, tvalor, fvalor,
                  nvalor, nlinea, ccolumna
                  FROM estpregungaransegtab
                 WHERE sseguro = psseguro
                  AND nriesgo  = pnriesgo
                  AND nmovimi IN
                  (SELECT    MAX(nmovimi)
                        FROM estpregungaransegtab
                       WHERE sseguro = psseguro
                  );
         ELSE
             INSERT
                  INTO pregungarancartab
                  (
                     sseguro, nriesgo, cpregun, nmovimi, sproces, cgarant, nmovima, finiefe, tvalor, fvalor,
                     nvalor, nlinea, ccolumna
                  )
             SELECT    sseguro, nriesgo, cpregun, nmovimi, psproces, cgarant, nmovima, finiefe, tvalor, fvalor,
                  nvalor, nlinea, ccolumna
                  FROM pregungaransegtab
                 WHERE sseguro = psseguro
                  AND nriesgo  = pnriesgo
                  AND nmovimi IN
                  (SELECT    MAX(nmovimi)
                        FROM pregungaransegtab
                       WHERE sseguro = psseguro
                  );
         END IF;
      EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
      WHEN OTHERS THEN
         -->-- -- dbms_output.put_line(SQLERRM);
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         RETURN 108424;
      END; -- A NIVEL DE POLIZA

      -- FALTA :
      -- para cada una de las garantia
      -- INSERTAR PREGUNCARANCAR
      RETURN 0;
   EXCEPTION
   WHEN OTHERS THEN
      -->-- -- dbms_output.put_line('2 '||SQLERRM);
      p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
      RETURN 108424;
   END f_tmpcesaux_est;

---------------------------------------------------------------------------------------
   FUNCTION f_garantarifa_rea(
         psproces IN NUMBER,
         psseguro IN NUMBER,
         pnmovimi IN NUMBER,
         pcramo IN NUMBER,
         pcmodali IN NUMBER,
         pctipseg IN NUMBER,
         pccolect IN NUMBER,
         psproduc IN NUMBER,
         pcactivi IN NUMBER,
         pfcarpro IN DATE,
         pfemisio IN DATE,
         pcmanual IN NUMBER,
         pcobjase IN NUMBER,
         pcforpag IN NUMBER,
         pcidioma IN NUMBER,
         pmoneda IN NUMBER)
      RETURN NUMBER
   IS
      ----------------------------------
      --  Tarifar les garanties per SGT
      ----------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_GARANTARIFA_REA';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(p=' || psproces || ' s=' || psseguro || ' m=' || pnmovimi || ' r=' || pcramo || ' m=' || pcmodali || ' t=' || pctipseg ||
      ' c=' || pccolect || ' p=' || psproduc || ' a=' || pcactivi || ' c=' || pfcarpro || ' e=' || pfemisio || ' m=' || pcmanual || ' o=' || pcobjase || ' f='
      || pcforpag || ' i=' || pcidioma || ' m=' || pmoneda || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      parms_transitorios pac_parm_tarifas.parms_transitorios_tabtyb;
      psesion  NUMBER;
      num_err  NUMBER;
      ltotal   NUMBER;
      lmensa   VARCHAR2(100);
      lcfacult NUMBER;
      lnagrupa NUMBER;
      -- 14871 AVT 29-07-2010
      v_anuali NUMBER;
      v_accion VARCHAR2(4);
      v_idioma NUMBER;                          --bfp bug 23946
      ltexto   VARCHAR2(4000);                  -- bfp bug 23946
      w_iprirea cesionesaux.iprirea%TYPE;       --BUG 29347/163814 - 23/01/2014 - RCL
      w_icapital cesionesaux.icapital%TYPE;     --BUG 29347/163814 - 23/01/2014 - RCL
      w_ctipcoa seguros.ctipcoa%TYPE;           --BUG 29347/163814 - 23/01/2014 - RCL
      v_porcen coacuadro.ploccoa%TYPE;          --BUG 29347/163814 - 23/01/2014 - RCL
      w_ipritarrea cesionesaux.ipritarrea%TYPE; --BUG 30326/171842 - 04/04/2014  - DCT
      w_iextrea cesionesaux.iextrea%TYPE;       --BUG 30326/171842 - 04/04/2014  - DCT

      CURSOR c_risc(wpsproces NUMBER, wpsseguro IN NUMBER)
      IS
         SELECT DISTINCT nriesgo
               FROM cesionesaux c, reaformula r
              WHERE c.cgarant = r.cgarant(+)
               AND c.scontra  = r.scontra(+)
               AND c.nversio  = r.nversio(+)
               AND c.sproces  = wpsproces
               AND c.sseguro  = wpsseguro;

      CURSOR c_gar_risc(wpsproces NUMBER, wpsseguro NUMBER, wpnriesgo NUMBER)
      IS
          SELECT    *
               FROM tmp_garancar
              WHERE sproces = wpsproces
               AND sseguro  = wpsseguro
               AND nriesgo  = wpnriesgo;
   BEGIN
      v_errlin := 2000;
      parms_transitorios.DELETE; -- Inicializo la matriz de parms_transitorios

      -- 14871 AVT 29-07-2010 es gestiona el tipus de moviment per poder utilizar "ACCION" a la tarificació del Rea.
      BEGIN
          SELECT    nanuali, ctipcoa --BUG 29347/163814 - 23/01/2014 - RCL - ctipcoa
               INTO v_anuali, w_ctipcoa
               FROM seguros
              WHERE sseguro = psseguro;
      EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' s=' || psseguro);
         RETURN SQLERRM;
      END;

      IF v_anuali  = 1 THEN
         v_accion := 'NP';
      ELSE
         v_accion := 'CAR';
      END IF;

      -- 14871 AVT 29-07-2010  fi ------------------
      -- per cada risc
      ---->-- -- dbms_output.put_line(' IMPORTANT a tarifar rea sproce '||psproces||' sseg '||psseguro||' nmovimi '||pnmovimi);
      FOR v_risc IN c_risc(psproces, psseguro)
      LOOP
         -- insertar les garanties  a tmp_garancar
         ---->-- -- dbms_output.put_line(' IMPORTANT a tarifar rea dins bucle ');
         v_errlin   := 2010;
         num_err    := f_tmpcesaux(psproces, psseguro, v_risc.nriesgo, pnmovimi);

         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' err=' || num_err || ' r=' || v_risc.nriesgo);
            RETURN num_err;
         END IF;

         -->-- -- dbms_output.put_line(' ------------------------VAIG a TARIFAR risc------------- ');
         -->-- -- dbms_output.put_line(' fcarpro '||pfcarpro);
         -->-- -- dbms_output.put_line(' femsio '||pfemisio);
         v_errlin := 2020;
         num_err  := pac_tarifas.f_tarifar_risc(psproces, NULL, --ptablas
         'REA', 'R', pcramo, pcmodali, pctipseg, pccolect, psproduc, pac_seguros.ff_get_actividad(psseguro, v_risc.nriesgo), 0, 0, psseguro, v_risc.nriesgo,
         pfcarpro, pfemisio, pcmanual, pcobjase, pcforpag, pcidioma, NULL, --pmes
         NULL,                                                             --panyo
         pmoneda, parms_transitorios, ltotal, lmensa, v_accion);           -- 14871 AVT 29-07-2010

         ---->-- -- dbms_output.put_line(' f_tarifar_risc '||num_err);
         IF num_err <> 0 THEN -- bfp bug 23946
            --            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
            --                        v_errpar || ' err=' || num_err);
            ltexto := f_axis_literales(num_err, pcidioma);
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, ltexto, v_errpar || ' err=' || num_err);
            --bfp bug 23946
            RETURN num_err;
         END IF;

         lnagrupa := 1;

         -->P_Borrar_Jgr (3); --> BORRAR JGR
         FOR v_gar_risc IN c_gar_risc(psproces, psseguro, v_risc.nriesgo)
         LOOP
            -- nunu FALTA dtosreavida ( per descomptes)
            -- Mirem si exedeix de la capacitat, pq segons el camp cfacult (creafac
            -- del contracte) pot der-se el facultatiu per l'excés o pur
            lcfacult             := NULL;

            IF v_gar_risc.cfacult = 1 THEN
               -- Sempre que excedeixi es força si ho diu el contracte
               ---->-- -- dbms_output.put_line(' CFACULT = 1 --------------> v_gar_risc.icapaci < v_gar_risc.icaprea'||v_gar_risc.icapaci||' '||
               -- v_gar_risc.icaprea);
               IF v_gar_risc.icapaci < v_gar_risc.icaprea THEN
                  lcfacult          := 1;
               END IF;
            END IF;

            -->-- -- dbms_output.put_line(' ------------ UPDATE CESIONESAUX  ----------------');
            -->-- -- dbms_output.put_line(' v_gar_risc.itarrea     '||v_gar_risc.itarrea      );
            -->-- -- dbms_output.put_line(' v_gar_risc.ipritarrea  '||v_gar_risc.ipritarrea   );
            -->-- -- dbms_output.put_line(' v_gar_risc.idtosel     '||v_gar_risc.idtosel      );
            -->-- -- dbms_output.put_line(' v_gar_risc.psobreprima '||v_gar_risc.psobreprima  );
            -->-- -- dbms_output.put_line(' v_gar_risc.icaprea     '||v_gar_risc.icaprea      );
            -->-- -- dbms_output.put_line(' v_gar_risc.ipleno      '||v_gar_risc.ipleno       );
            -->-- -- dbms_output.put_line(' v_gar_risc.icapaci     '||v_gar_risc.icapaci      );
            -->-- -- dbms_output.put_line(' ------------ UPDATE CESIONESAUX  ----------------');
            v_errlin := 2030;
            --Inici BUG 29347/163814 - 23/01/2014 - RCL
            w_iprirea  := NVL(v_gar_risc.itarrea, 0);
            w_icapital := NVL(v_gar_risc.icaprea, 0);
            --Inici BUG 30326/171842 - DCT - 04/04/2014
            w_ipritarrea := NVL(v_gar_risc.ipritarrea, 0); --BASE (PP)
            w_iextrea    := NVL(v_gar_risc.iextrea, 0);    --EXTRAPRIMA

            --Fi BUG 29347/163814 - 23/01/2014 - RCL
             UPDATE cesionesaux
               SET iextrea   = NVL(w_iextrea, 0),                                                                               --BUG 30326/171842 - DCT - 04/04/2014
                  iextrap    = NVL(v_gar_risc.iextrap, 0),                                                                      --> REA
                  iprirea    = NVL(w_iprirea, 0),                                                                               --BUG 29347/163814 - 23/01/2014 - RCL
                  ipritarrea = NVL(w_ipritarrea, 0),                                                                            --BUG 30326/171842 - DCT - 04/04/2014
                  idtosel    = NVL(v_gar_risc.idtosel, 0), psobreprima = v_gar_risc.psobreprima, icapital = NVL(w_icapital, 0), --BUG 29347/163814 - 23/01/2014
                  -- - RCL
                  ipleno = NVL(v_gar_risc.ipleno, 0), icapaci = NVL(v_gar_risc.icapaci, 0), cfacult = NVL(lcfacult, cfacult), -- si es null deixem el que hi
                  -- havia
                  scontra = DECODE(lcfacult, 1, NULL, scontra), nversio = DECODE(lcfacult, 1, NULL, nversio), nagrupa = DECODE(lcfacult, 1, lnagrupa, nagrupa),
                  -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                  itarifrea = NVL(v_gar_risc.itarifrea, 0)
                  -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
                 WHERE sproces = psproces
                  AND sseguro  = psseguro
                  AND nriesgo  = v_risc.nriesgo
                  AND cgarant  = v_gar_risc.cgarant;

            -->-- -- dbms_output.put_line(' HA UPDATEJAT '||SQL%ROWCOUNT);
            lnagrupa := lnagrupa + 1;
            v_errlin := 2040;

             UPDATE garanseg
               SET itarrea     = v_gar_risc.itarrea
                 WHERE sseguro = psseguro
                  AND nriesgo  = v_risc.nriesgo
                  AND cgarant  = v_gar_risc.cgarant
                  AND nmovimi  = pnmovimi
                  AND nmovima  = v_gar_risc.nmovima;
            -->-- -- dbms_output.put_line(' HA UPDATEJAT GARANSEG  '||SQL%ROWCOUNT);
         END LOOP;

         -->P_Borrar_Jgr (4); --> BORRAR JGR
         v_errlin := 2050;

          DELETE
               FROM tmp_garancar
              WHERE sproces = psproces;

         v_errlin          := 2060;

          DELETE pregungarancar
              WHERE sproces = psproces;

         v_errlin          := 2070;

          DELETE preguncar
              WHERE sproces = psproces;

         v_errlin          := 2080;

          DELETE pregunpolcar
              WHERE sproces = psproces;
      END LOOP;

      RETURN 0;
   END f_garantarifa_rea;

--BUG 19484 - 19/10/2011 - JRB - Se añaden las funciones est para el reaseguro.
-- Estas funciones contemplan tanto el trato de las tablas EST como el de las reales
---------------------------------------------------------------------------------------
   FUNCTION f_garantarifa_rea_est(
         psproces IN NUMBER,
         psseguro IN NUMBER,
         pnmovimi IN NUMBER,
         pcramo IN NUMBER,
         pcmodali IN NUMBER,
         pctipseg IN NUMBER,
         pccolect IN NUMBER,
         psproduc IN NUMBER,
         pcactivi IN NUMBER,
         pfcarpro IN DATE,
         pfemisio IN DATE,
         pcmanual IN NUMBER,
         pcobjase IN NUMBER,
         pcforpag IN NUMBER,
         pcidioma IN NUMBER,
         pmoneda IN NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER
   IS
      ----------------------------------
      --  Tarifar les garanties per SGT
      ----------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_GARANTARIFA_REA_EST';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(p=' || psproces || ' s=' || psseguro || ' m=' || pnmovimi || ' r=' || pcramo || ' m=' || pcmodali || ' t=' || pctipseg ||
      ' c=' || pccolect || ' p=' || psproduc || ' a=' || pcactivi || ' c=' || pfcarpro || ' e=' || pfemisio || ' m=' || pcmanual || ' o=' || pcobjase || ' f='
      || pcforpag || ' i=' || pcidioma || ' m=' || pmoneda || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      parms_transitorios pac_parm_tarifas.parms_transitorios_tabtyb;
      psesion  NUMBER;
      num_err  NUMBER;
      ltotal   NUMBER;
      lmensa   VARCHAR2(100);
      lcfacult NUMBER;
      lnagrupa NUMBER;
      -- 14871 AVT 29-07-2010
      v_anuali  NUMBER;
      v_accion  VARCHAR2(4);
      v_ptablas VARCHAR2(3);
      v_idioma  NUMBER;                     --bfp bug 23946
      ltexto    VARCHAR2(4000);             -- bfp bug 23946
      w_iprirea cesionesaux.iprirea%TYPE;   --BUG 29347/163814 - 23/01/2014 - RCL
      w_icapital cesionesaux.icapital%TYPE; --BUG 29347/163814 - 23/01/2014 - RCL
      w_ctipcoa seguros.ctipcoa%TYPE;       --BUG 29347/163814 - 23/01/2014 - RCL
      v_porcen coacuadro.ploccoa%TYPE;      --BUG 29347/163814 - 23/01/2014 - RCL

      CURSOR c_risc(wpsproces NUMBER, wpsseguro IN NUMBER)
      IS
         SELECT DISTINCT nriesgo
               FROM cesionesaux c, reaformula r
              WHERE c.cgarant = r.cgarant(+)
               AND c.scontra  = r.scontra(+)
               AND c.nversio  = r.nversio(+)
               AND sproces    = wpsproces
               AND sseguro    = wpsseguro;

      CURSOR c_gar_risc(wpsproces NUMBER, wpsseguro NUMBER, wpnriesgo NUMBER)
      IS
          SELECT    *
               FROM tmp_garancar
              WHERE sproces = wpsproces
               AND sseguro  = wpsseguro
               AND nriesgo  = wpnriesgo;
   BEGIN
      v_errlin := 2000;
      parms_transitorios.DELETE; -- Inicializo la matriz de parms_transitorios

      -- 14871 AVT 29-07-2010 es gestiona el tipus de moviment per poder utilizar "ACCION" a la tarificació del Rea.
      IF ptablas = 'EST' THEN
         BEGIN
             SELECT    nanuali, ctipcoa --BUG 29347/163814 - 23/01/2014 - RCL - ctipcoa
                  INTO v_anuali, w_ctipcoa
                  FROM estseguros
                 WHERE sseguro = psseguro;
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' s=' || psseguro);
            RETURN SQLERRM;
         END;
      ELSIF ptablas = 'CAR' THEN
         BEGIN
             SELECT    nanuali
                  INTO v_anuali
                  FROM seguros
                 WHERE sseguro = psseguro;
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' s=' || psseguro);
            RETURN SQLERRM;
         END;
      ELSE
         BEGIN
             SELECT    nanuali
                  INTO v_anuali
                  FROM seguros
                 WHERE sseguro = psseguro;
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' s=' || psseguro);
            RETURN SQLERRM;
         END;
      END IF;

      IF v_anuali  = 1 THEN
         v_accion := 'NP';
      ELSE
         v_accion := 'CAR';
      END IF;

      -- 14871 AVT 29-07-2010  fi ------------------
      -- per cada risc
      ---->-- -- dbms_output.put_line(' IMPORTANT a tarifar rea sproce '||psproces||' sseg '||psseguro||' nmovimi '||pnmovimi);
      FOR v_risc IN c_risc(psproces, psseguro)
      LOOP
         -- insertar les garanties  a tmp_garancar
         ---->-- -- dbms_output.put_line(' IMPORTANT a tarifar rea dins bucle ');
         v_errlin   := 2010;
         num_err    := f_tmpcesaux_est(psproces, psseguro, v_risc.nriesgo, pnmovimi, ptablas);

         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' err=' || num_err || ' r=' || v_risc.nriesgo);
            RETURN num_err;
         END IF;

         -->-- -- dbms_output.put_line(' ------------------------VAIG a TARIFAR risc------------- ');
         -->-- -- dbms_output.put_line(' fcarpro '||pfcarpro);
         -->-- -- dbms_output.put_line(' femsio '||pfemisio);
         v_errlin := 2020;

         -- 21051 AVT 31/01/2012 anirem a les taules reals per crear els quadres de facultatiu
         -- Bug 21167 - RSC - 03/02/2012 - LCOL_T001-LCOL - UAT - TEC: Incidencias del proceso de Cartera (añadimos 'CAR')
         IF ptablas IN('REA', 'CAR') THEN
            -- Fin bug 21167
            v_ptablas := '';
         ELSE
            v_ptablas := ptablas;
         END IF;

         num_err := pac_tarifas.f_tarifar_risc(psproces, v_ptablas, -- 19484 ptablas EST
         'REA', 'R', pcramo, pcmodali, pctipseg, pccolect, psproduc, pac_seguros.ff_get_actividad(psseguro, v_risc.nriesgo), 0, 0, psseguro, v_risc.nriesgo,
         pfcarpro, pfemisio, pcmanual, pcobjase, pcforpag, pcidioma, NULL, --pmes
         NULL,                                                             --panyo
         pmoneda, parms_transitorios, ltotal, lmensa, v_accion);           -- 14871 AVT 29-07-2010

         ---->-- -- dbms_output.put_line(' f_tarifar_risc '||num_err);
         IF num_err <> 0 THEN --bfp bug 23946
            --            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
            --                        v_errpar || ' err=' || num_err);
            ltexto := f_axis_literales(num_err, pcidioma);
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, ltexto, v_errpar || ' err=' || num_err);
            --bfp bug 23946
            RETURN num_err;
         END IF;

         lnagrupa := 1;

         -->P_Borrar_Jgr (3); --> BORRAR JGR
         FOR v_gar_risc IN c_gar_risc(psproces, psseguro, v_risc.nriesgo)
         LOOP
            -- nunu FALTA dtosreavida ( per descomptes)
            -- Mirem si exedeix de la capacitat, pq segons el camp cfacult (creafac
            -- del contracte) pot der-se el facultatiu per l'excés o pur
            lcfacult             := NULL;

            IF v_gar_risc.cfacult = 1 THEN
               -- Sempre que excedeixi es força si ho diu el contracte
               ---->-- -- dbms_output.put_line(' CFACULT = 1 --------------> v_gar_risc.icapaci < v_gar_risc.icaprea'||v_gar_risc.icapaci||' '||
               -- v_gar_risc.icaprea);
               IF v_gar_risc.icapaci < v_gar_risc.icaprea THEN
                  lcfacult          := 1;
               END IF;
            END IF;

            -->-- -- dbms_output.put_line(' ------------ UPDATE CESIONESAUX  ----------------');
            -->-- -- dbms_output.put_line(' v_gar_risc.itarrea     '||v_gar_risc.itarrea      );
            -->-- -- dbms_output.put_line(' v_gar_risc.ipritarrea  '||v_gar_risc.ipritarrea   );
            -->-- -- dbms_output.put_line(' v_gar_risc.idtosel     '||v_gar_risc.idtosel      );
            -->-- -- dbms_output.put_line(' v_gar_risc.psobreprima '||v_gar_risc.psobreprima  );
            -->-- -- dbms_output.put_line(' v_gar_risc.icaprea     '||v_gar_risc.icaprea      );
            -->-- -- dbms_output.put_line(' v_gar_risc.ipleno      '||v_gar_risc.ipleno       );
            -->-- -- dbms_output.put_line(' v_gar_risc.icapaci     '||v_gar_risc.icapaci      );
            -->-- -- dbms_output.put_line(' ------------ UPDATE CESIONESAUX  ----------------');
            v_errlin := 2030;
            --Inici BUG 29347/163814 - 23/01/2014 - RCL
            w_iprirea  := NVL(v_gar_risc.itarrea, 0);
            w_icapital := NVL(v_gar_risc.icaprea, 0);

            --Fi BUG 29347/163814 - 23/01/2014 - RCL
             UPDATE cesionesaux
               SET iextrea   = NVL(v_gar_risc.iextrea, 0), --> REA.11845.NMM. Afegim nvl's.
                  iextrap    = NVL(v_gar_risc.iextrap, 0), --> REA
                  iprirea    = NVL(w_iprirea, 0),          -- BUG 29347/163814 - 23/01/2014 - RCL
                  ipritarrea = NVL(v_gar_risc.ipritarrea, 0), idtosel = NVL(v_gar_risc.idtosel, 0), psobreprima = v_gar_risc.psobreprima, icapital = NVL(
                  w_icapital, 0),                                                                                             -- BUG 29347/163814 - 23/01/2014 - RCL
                  ipleno = NVL(v_gar_risc.ipleno, 0), icapaci = NVL(v_gar_risc.icapaci, 0), cfacult = NVL(lcfacult, cfacult), -- si es null deixem el que hi
                  -- havia
                  scontra = DECODE(lcfacult, 1, NULL, scontra), nversio = DECODE(lcfacult, 1, NULL, nversio), nagrupa = DECODE(lcfacult, 1, lnagrupa, nagrupa),
                  -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                  itarifrea = NVL(v_gar_risc.itarifrea, 0) --> Tasa de Reaseguro
                  -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
                 WHERE sproces = psproces
                  AND sseguro  = psseguro
                  AND nriesgo  = v_risc.nriesgo
                  AND cgarant  = v_gar_risc.cgarant;

            -->-- -- dbms_output.put_line(' HA UPDATEJAT '||SQL%ROWCOUNT);
            lnagrupa  := lnagrupa + 1;
            v_errlin  := 2040;

            IF ptablas = 'EST' THEN
                UPDATE estgaranseg
                  SET itarrea     = v_gar_risc.itarrea
                    WHERE sseguro = psseguro
                     AND nriesgo  = v_risc.nriesgo
                     AND cgarant  = v_gar_risc.cgarant
                     AND nmovimi -- = pnmovimi -- AVT 02/12/2013 EL MOVIMENT NO TE PERQUE COINCIDIR
                     IN
                     (SELECT    MAX(nmovimi)
                           FROM estgaranseg
                          WHERE sseguro = psseguro
                     )
                     AND nmovima = v_gar_risc.nmovima
                     AND cobliga = 1; -- 21051 AVT 25/01/2012;
            ELSIF ptablas        = 'CAR' THEN
                UPDATE garancar
                  SET itarrea     = v_gar_risc.itarrea
                    WHERE sseguro = psseguro
                     AND nriesgo  = v_risc.nriesgo
                     AND cgarant  = v_gar_risc.cgarant
                     --AND nmovimi = pnmovimi
                     AND sproces = psproces
                     AND nmovima = v_gar_risc.nmovima;
            ELSE
                UPDATE garanseg
                  SET itarrea     = v_gar_risc.itarrea
                    WHERE sseguro = psseguro
                     AND nriesgo  = v_risc.nriesgo
                     AND cgarant  = v_gar_risc.cgarant
                     AND nmovimi  = pnmovimi
                     AND nmovima  = v_gar_risc.nmovima;
            END IF;
            -->-- -- dbms_output.put_line(' HA UPDATEJAT GARANSEG  '||SQL%ROWCOUNT);
         END LOOP;

         -->P_Borrar_Jgr (4); --> BORRAR JGR
         v_errlin := 2050;

          DELETE
               FROM tmp_garancar
              WHERE sproces = psproces;

         v_errlin          := 2060;

          DELETE pregungarancar
              WHERE sproces = psproces;

         v_errlin          := 2070;

          DELETE preguncar
              WHERE sproces = psproces;

         v_errlin          := 2080;

          DELETE pregunpolcar
              WHERE sproces = psproces;
      END LOOP;

      RETURN 0;
   END f_garantarifa_rea_est;

-----------------------------------------------------------------------
   FUNCTION f_traspas_cuafacul(
         psproces IN NUMBER,
         psseg_est IN NUMBER,
         psseguro IN NUMBER)
      RETURN NUMBER
   IS
      -----------------------------------------------------------------------
      -- Traspassa el quadre de l'estudi a la pòlissa
      -----------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_TRASPAS_CUAFACUL';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(p=' || psproces || ' e=' || psseg_est || ' s=' || psseguro || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      lsfacult NUMBER;
      lc       NUMBER;

      CURSOR c_cua(wsseg_est NUMBER)
      IS
          SELECT    *
               FROM cuafacul
              WHERE sseguro = wsseg_est;

      CURSOR c_cia(wsfacult NUMBER)
      IS
          SELECT    *
               FROM cuacesfac
              WHERE sfacult = wsfacult;
      /* BUG 10462: ETM:16/06/2009:--ANTES--
      CURSOR c_pend(wsseg_est NUMBER, wsfacult NUMBER) IS
      SELECT *
      FROM facpendientes
      WHERE sseguro = wsseg_est;
      /* BUG 10462: ETM:16/06/2009:*/
   BEGIN
      FOR v_cua IN c_cua(psseg_est)
      LOOP
         BEGIN
            v_errlin := 3000;

             SELECT    sfacult.NEXTVAL
                  INTO lsfacult
                  FROM DUAL;
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            RETURN 104342;
         END;

         BEGIN
            v_errlin := 3010;

             INSERT
                  INTO cuafacul
                  (
                     sfacult, cestado, finicuf, cfrebor, scontra, nversio, sseguro, cgarant, ccalif1, ccalif2,
                     spleno, nmovimi, scumulo, nriesgo, ffincuf, plocal, fultbor, pfacced, ifacced, ncesion
                  )
                  VALUES
                  (
                     lsfacult, v_cua.cestado, v_cua.finicuf, v_cua.cfrebor, v_cua.scontra, v_cua.nversio, psseguro, v_cua.cgarant, v_cua.ccalif1, v_cua.ccalif2
                     ,
                     v_cua.spleno, v_cua.nmovimi, v_cua.scumulo, v_cua.nriesgo, v_cua.ffincuf, v_cua.plocal, v_cua.fultbor, v_cua.pfacced, v_cua.ifacced,
                     v_cua.ncesion
                  );
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            RETURN 104343;
         END;

         FOR v_cia IN c_cia
         (
            v_cua.sfacult
         )
         LOOP
            BEGIN
               v_errlin := 3020;

                INSERT
                     INTO cuacesfac
                     (
                        sfacult, ccompani, ccomrea, pcesion, icesfij, icomfij, isconta, preserv, pintres, pcomisi
                     )
                     VALUES
                     (
                        lsfacult, v_cia.ccompani, v_cia.ccomrea, v_cia.pcesion, v_cia.icesfij, v_cia.icomfij, v_cia.isconta, v_cia.preserv, v_cia.pintres,
                        v_cia.pcomisi
                     );
            EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' cia=' || v_cia.ccompani || ' com=' || v_cia.ccomrea);
               RETURN 104345;
            END;
         END LOOP;
         /* BUG 10462: ETM:16/06/2009:--ANTES--
         FOR v_pend IN c_pend(psseg_est, v_cua.sfacult) LOOP
         BEGIN
         INSERT INTO facpendientes
         ...
         END;
         END LOOP;
         /* BUG 10462: ETM:16/06/2009:*/
      END LOOP;

      /* BUG 10462: ETM:16/06/2009:--ANTES--
      BEGIN
      DELETE FROM facpendientes
      ...
      END;
      /* BUG 10462: ETM:16/06/2009:*/
      RETURN 0;
   END f_traspas_cuafacul;

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
   FUNCTION f_crea_cumul
      (
         psperson IN NUMBER,
         pfefecto IN DATE,
         pctipcum IN NUMBER,
         pccumprod IN NUMBER,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         psseguro IN NUMBER,
         pscumulo IN OUT NUMBER
      )
      RETURN NUMBER
   IS
      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_CREA_CUMUL';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || 'p=' || psperson || ' e=' || pfefecto || ' t=' || pctipcum || ' p=' || pccumprod || 'c=' || pscontra || ' v=' ||
      pnversio || ' s=' || psseguro || ' c=' || pscumulo || ')';

      -- fin Bug 0012020 - 17/11/2009 - JMF

      -------------------------------------------------------------------------------------
      -- 13946 AVT 06-04-2010 s'afegeix el SCONTRA i la NVERSIO.
      CURSOR c_pol(wsperson NUMBER, wsseguro NUMBER, wccumprod NUMBER, wfefecto DATE, wscontra NUMBER, wnversio NUMBER)
      IS
         SELECT DISTINCT s.sseguro, r.nriesgo, r.fefecto, c.scontra, c.nversio
               FROM seguros s, riesgos r, cesionesrea c
              WHERE s.sseguro = r.sseguro
               AND r.sperson  = wsperson
               AND c.scontra  = wscontra
               AND c.nversio  = wnversio
               AND s.sseguro <> wsseguro -- No ens retorni la pòlissa actual
               AND s.sproduc IN
               (SELECT    sproduc
                     FROM cumulprod
                    WHERE ccumprod = wccumprod
               )
            AND s.sseguro  = c.sseguro
            AND r.nriesgo  = c.nriesgo
            AND c.cgenera IN(01, 03, 04, 05, 09, 40)
            AND c.fefecto <= wfefecto
            AND c.fvencim  > wfefecto
            AND(c.fanulac  > wfefecto
            OR c.fanulac  IS NULL)
            AND(c.fregula  > wfefecto
            OR c.fregula  IS NULL)
            AND s.csituac  < 7
            AND s.csituac != 4; --> JGR

      lprimer NUMBER      := 0;
      lnom descumulos.tobserv%TYPE;
      waux NUMBER := 0;
      --
   BEGIN
      IF pscumulo IS NULL THEN
         -- Si hi ha altres pòlisses crearem el cúmul
         ---->-- -- dbms_output.put_line(' anem a veure les pòlisses ');
         -- 13946 AVT 06-04-2010 s'afegeix el SCONTRA i la NVERSIO.
         FOR v_pol IN c_pol(psperson, psseguro, pccumprod, pfefecto, pscontra, pnversio)
         LOOP
            ---->-- -- dbms_output.put_line(' Pòlissa '||v_pol.sseguro);
            IF lprimer  = 0 THEN
               lprimer := 1;

               -- hem de crear una capçalera nova
               --Insertem cúmul per aquest assegurat
               BEGIN
                  v_errlin := 3050;

                   SELECT    scumulo.NEXTVAL
                        INTO pscumulo
                        FROM DUAL;

                  v_errlin := 3060;

                   INSERT
                        INTO cumulos
                        (
                           scumulo, fcumini, fcumfin, sperson, ctipcum, ccumprod
                        )
                        VALUES
                        (
                           pscumulo, pfefecto, NULL, psperson, pctipcum, pccumprod
                        );
                  ---->-- -- dbms_output.put_line(' insert cap del cúmul ');
               EXCEPTION
               WHEN OTHERS THEN
                  -->-- -- dbms_output.put_line(SQLERRM);
                  p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
                  RETURN 150963;
               END;

               BEGIN
                  -- Descripcció
                  v_errlin := 3060;

                  -- ini Bug 0012803 - 19/02/2010 - JMF: AGA - Acceso a la vista PERSONAS
                  --SELECT RTRIM(LTRIM(RTRIM(tnombre) || ' ' || LTRIM(tapelli))) INTO lnom FROM personas WHERE sperson=psperson;
                   SELECT    nnumide
                        INTO lnom
                        FROM per_personas
                       WHERE sperson = psperson;

                  -- fin Bug 0012803 - 19/02/2010 - JMF: AGA - Acceso a la vista PERSONAS

                  -- Modif. Francesc Alférez.i.#6.
                  FOR reg IN
                  (SELECT    cidioma
                        FROM idiomas
                  )
                  LOOP
                     v_errlin := 3070;

                      INSERT
                           INTO descumulos
                           (
                              scumulo, cidioma, tdescri, tobserv
                           )
                           VALUES
                           (
                              pscumulo, reg.cidioma, SUBSTR(lnom, 1, 40), lnom
                           );
                  END LOOP;
                  -- Modif. Francesc Alférez.f.
               EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
                  RETURN 150964;
               END;
            END IF;

            -- BUG 9781 - 04/05/2009 - FAL - Evitar inserción en reariesgos si ya existe.
            BEGIN
               v_errlin := 3080;

                SELECT    1
                     INTO waux
                     FROM reariesgos
                    WHERE sseguro = v_pol.sseguro
                     AND nriesgo  = v_pol.nriesgo
                     AND freaini  = pfefecto
                     AND scumulo  = pscumulo
                     AND scontra  = pscontra
                     AND nversio  = pnversio
                     AND freafin IS NULL;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_errlin := 3090;

               BEGIN
                   INSERT
                        INTO reariesgos
                        (
                           sseguro, nriesgo, freaini, scumulo, scontra, freafin, nversio
                        )
                        VALUES
                        (
                           v_pol.sseguro, v_pol.nriesgo, pfefecto, pscumulo, pscontra, NULL, pnversio
                        );
               EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
                  RETURN 150964;
               END;
            END;

            -- FI BUG 9781 - 04/05/2009 – FAL

            ---->-- -- dbms_output.put_line(' inserta reariesgos ');
            -- Actualitzem les cessions d'aquest pòlissa, per posar-li scumulo
            -->-- -- dbms_output.put_line(SQLERRM);
            v_errlin := 3095;

            -- 13946 AVT 06-04-2010 s'afegeix el SCONTRA i la NVERSIO.
            BEGIN
                UPDATE cesionesrea
                  SET scumulo     = pscumulo
                    WHERE sseguro = v_pol.sseguro
                     AND nriesgo  = v_pol.nriesgo
                     AND scontra  = pscontra
                     AND nversio  = pnversio
                     AND cgenera IN(01, 03, 04, 05, 09, 40)
                     AND fefecto <= pfefecto
                     AND fvencim  > pfefecto
                     AND(fanulac  > pfefecto
                     OR fanulac  IS NULL)
                     AND(fregula  > pfefecto
                     OR fregula  IS NULL);
            EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
               RETURN 104859;
            END;
            ---->-- -- dbms_output.put_line(' actual. cesionesrea '||sql%ROWCOUNT);
         END LOOP;
      END IF;

      RETURN 0;
   END f_crea_cumul;

------------------------------------------------------------------------------------
   FUNCTION f_reacumul(
         psseguro IN NUMBER,
         pnriesgo IN NUMBER,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pfefecto IN DATE,
         psproduc IN NUMBER,
         pscumulo OUT NUMBER)
      RETURN NUMBER
   IS
      ------------------------------------------------------------------------------------
      -- Cúmuls automàtics
      -- Es llegeix de la taula cumulprod on ens diu quins productes poden fer cúmul
      -- entre ells
      ------------------------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_REACUMUL';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || 's=' || psseguro || ' r=' || pnriesgo || ' c=' || pscontra || ' v=' || pnversio || 'e=' || pfefecto || ' p=' || psproduc
      || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      lctipcum NUMBER;
      lasseg   NUMBER;
      lscumulo NUMBER;
      lcum cumulos%ROWTYPE;
      num_err   NUMBER;
      lsseg     NUMBER;
      lccumprod NUMBER;
      waux      NUMBER := 0;
   BEGIN
      p_traza_proceso(24, 'TRAZA_CESIONES_REA', 777, 'PAC_CESIONESREA', 'F_REA_CUMUL', NULL, 7772,'inicio');
      -- Obtenim el tipus de cumul per aquest contracte
      BEGIN
         v_errlin := 4000;

          SELECT    ctipcum
               INTO lctipcum
               FROM codicontratos
              WHERE scontra = pscontra;
      EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         RETURN 104516;
      END;
      p_traza_proceso(24, 'TRAZA_CESIONES_REA', 777, 'PAC_CESIONESREA', 'F_REA_CUMUL', NULL, 7773,' lctipcum:'||
      lctipcum||' pscontra:'||pscontra);
      IF NVL(lctipcum, 0) = 0 THEN
         RETURN 0; -- Els manuals no es fa rès
      END IF;
      -- Obtenir el risc assegurat de la pòlissa
      BEGIN
         v_errlin := 4010;

          SELECT    sperson
               INTO lasseg
               FROM riesgos
              WHERE sseguro = psseguro
               AND nriesgo  = pnriesgo;
      p_traza_proceso(24, 'TRAZA_CESIONES_REA', 777, 'PAC_CESIONESREA', 'F_REA_CUMUL', NULL, 7774,'lasseg:'||
      lasseg||' psseguro:'||psseguro||' pnriesgo:'||pnriesgo);

         --INI BUG CONF-294  Fecha (09/11/2016) - HRE - Cumulos
         IF (lasseg IS NULL) THEN
                   SELECT t.sperson
                      INTO lasseg
                      FROM tomadores t, per_personas p
                     WHERE t.sseguro = psseguro
                       AND t.sperson = p.sperson;

         END IF;
         --FIN BUG CONF-294  - Fecha (09/11/2016) - HRE

      EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         RETURN 120007;
      END;

      -- Obtenim el codi del cúmul per producte
      BEGIN
         v_errlin := 4020;

          SELECT    ccumprod
               INTO lccumprod
               FROM cumulprod
              WHERE sproduc = psproduc
               AND finiefe <= pfefecto
               AND(ffinefe IS NULL
               OR ffinefe   > pfefecto);
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         lccumprod := - 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         RETURN 40301;
      END;

      -- Mirem si ja existeix un cumul per aquesta persona i aquest conjunt de productes
      -- que fan cúmul
      lscumulo := NULL;

      BEGIN
         v_errlin := 4030;

         -- 13946 AVT 12-04-2010 s'afegeix el SCONTRA i la NVERSIO.
         /*SELECT DISTINCT c.scumulo, c.fcumini, c.fcumfin, c.ccumprod, c.sperson, c.ctipcum, c.cramo, c.sproduc
               INTO lcum
               FROM cumulos c, reariesgos r --<<< AVT 12-04-2010
              WHERE sperson  = lasseg
               AND ccumprod  = lccumprod
               AND c.scumulo = r.scumulo
               AND r.scontra = pscontra
               AND r.nversio = pnversio
               AND fcumfin  IS NULL;

         ---->-- -- dbms_output.put_line(' trobat cumul '||lcum.scumulo);
         lscumulo := lcum.scumulo;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         lscumulo := NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' a=' || lasseg || ' c=' || lccumprod);
         RETURN 104665;*/
         num_err := f_get_scumulo(psseguro, lasseg, pscontra, pnversio, lccumprod, lctipcum, lscumulo);--BUG CONF-294  Fecha (09/11/2016) - HRE
      END;

      -- Mirem si cal tancar el cumul i fer un de nou
      -- i creem un cúmul nou (lscumulo pot canviar en aquesta funció)
      -- Insertem la pòlissa en aquest cumul
      IF lscumulo IS NULL THEN
         v_errlin := 4040;
         --INI BUG CONF-294 Fecha (09/11/2016) - HRE - Cumulos por tomador y zona geografica
         IF lctipcum = 2 THEN
            num_err := f_crea_cumul_tomador(pfefecto, lctipcum, lccumprod, pscontra, pnversio, psseguro, 'REA', lscumulo);
         ELSIF lctipcum = 3 THEN
            num_err := f_crea_cumul_zona(lasseg, pfefecto, lctipcum, lccumprod, pscontra, pnversio, psseguro, lscumulo);
         ELSE
            num_err := f_crea_cumul(lasseg, pfefecto, lctipcum, lccumprod, pscontra, pnversio, psseguro, lscumulo);
         END IF;
         --FIN BUG CONF-294  - Fecha (09/11/2016) - HRE
      END IF;
      ---->-- -- dbms_output.put_line('F_CREA_CUMUL '||num_Err);
      IF num_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' err=' || num_err || ' a=' || lasseg || ' t=' || lctipcum || ' c=' ||
         lccumprod);
         RETURN num_err;
      END IF;

      ---->-- -- dbms_output.put_line('Cumul tornat '||lscumulo);
      IF lscumulo IS NOT NULL THEN
         pscumulo := lscumulo;

         -- hem de mirar si ja existeix la pòlissa en el cúmul
         BEGIN
            v_errlin := 4050;

            SELECT DISTINCT sseguro
                  INTO lsseg
                  FROM reariesgos
                 WHERE scumulo = pscumulo
                  AND sseguro  = psseguro
                  AND nriesgo  = pnriesgo
                  AND freaini <= pfefecto
                  AND(freafin  > pfefecto
                  OR freafin  IS NULL); -- nunu
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- BUG 9781 - 04/05/2009 - FAL - Evitar inserción en reariesgos si ya existe.
            BEGIN
               v_errlin := 4060;

                SELECT    1
                     INTO waux
                     FROM reariesgos
                    WHERE sseguro = psseguro
                     AND nriesgo  = pnriesgo
                     AND freaini  = pfefecto
                     AND scumulo  = lscumulo
                     AND scontra  = pscontra
                     AND nversio  = pnversio
                     AND freafin IS NULL;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  ---->-- -- dbms_output.put_line(' inserta el propi sseguro '||psseguro);
                  v_errlin := 4070;

                   INSERT
                        INTO reariesgos
                        (
                           sseguro, nriesgo, freaini, scumulo, scontra, freafin, nversio
                        )
                        VALUES
                        (
                           psseguro, pnriesgo, pfefecto, lscumulo, pscontra, NULL, pnversio
                        );
               EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  NULL; -- Ja hi és
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' c=' || lscumulo);
                  RETURN 107096;
               END;
            END;
            -- FI BUG 9781 - 04/05/2009 – FAL
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            RETURN 104666;
         END;
      END IF;

      RETURN 0;
   END f_reacumul;

--BUG 19484 - 19/10/2011 - JRB - Se añaden las funciones est para el reaseguro.
-- Estas funciones contemplan tanto el trato de las tablas EST como el de las reales
------------------------------------------------------------------------------------
   FUNCTION f_reacumul_est
      (
         psseguro IN NUMBER,
         pnriesgo IN NUMBER,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pfefecto IN DATE,
         psproduc IN NUMBER,
         pscumulo OUT NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST'
      )
      RETURN NUMBER
   IS
      ------------------------------------------------------------------------------------
      -- Cúmuls automàtics
      -- Es llegeix de la taula cumulprod on ens diu quins productes poden fer cúmul
      -- entre ells
      ------------------------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_REACUMUL_EST';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || 's=' || psseguro || ' r=' || pnriesgo || ' c=' || pscontra || ' v=' || pnversio || 'e=' || pfefecto || ' p=' || psproduc
      || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      lctipcum NUMBER;
      lasseg   NUMBER;
      lscumulo NUMBER;
      lcum cumulos%ROWTYPE;
      num_err   NUMBER;
      lsseg     NUMBER;
      lccumprod NUMBER;
      waux      NUMBER := 0;
   BEGIN
      p_traza_proceso(24, 'TRAZA_CESIONES_REA', 777, 'PAC_CESIONESREA', 'F_REACUMUL_EST', NULL, 7774,'inicio:');

      -- Obtenim el tipus de cumul per aquest contracte
      BEGIN
         v_errlin := 4000;

          SELECT    ctipcum
               INTO lctipcum
               FROM codicontratos
              WHERE scontra = pscontra;
      EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         RETURN 104516;
      END;

      IF NVL(lctipcum, 0) = 0 THEN
         RETURN 0; -- Els manuals no es fa rès
      END IF;
      p_traza_proceso(24, 'TRAZA_CESIONES_REA', 777, 'PAC_CESIONESREA', 'F_REACUMUL_EST', NULL, 7775,'inicio:, lctipcum:'||
      lctipcum||' pscontra:'||pscontra);
      -- Obtenir el risc assegurat de la pòlissa
      -- 19484 --
      BEGIN
         v_errlin  := 4010;


         IF ptablas = 'EST' THEN
            BEGIN
             SELECT    spereal
                  INTO lasseg
                  FROM estriesgos r, estper_personas p
                 WHERE r.sseguro = psseguro
                  AND r.nriesgo  = pnriesgo
                  AND r.sperson  = p.sperson;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 --
                 -- Inicio IAXIS-12992 27/04/2020
                 --
                 BEGIN
                   SELECT p.spereal
                     INTO lasseg
                     FROM esttomadores t, estper_personas p
                    WHERE t.sseguro = psseguro
                      AND t.sperson = p.sperson;
                 EXCEPTION 
                   WHEN NO_DATA_FOUND THEN
                     lscumulo := NULL; --BUG CONF-294  Fecha (09/11/2016) - HRE - Cumulos
                 END;
                 --
                 -- Fin IAXIS-12992 27/04/2020
                 --
            END;

         ELSIF ptablas           = 'CAR' THEN
             SELECT    sperson
                  INTO lasseg
                  FROM riesgos
                 WHERE sseguro = psseguro
                  AND nriesgo  = pnriesgo;
         ELSE
             SELECT    sperson
                  INTO lasseg
                  FROM riesgos
                 WHERE sseguro = psseguro
                  AND nriesgo  = pnriesgo;

             --INI BUG CONF-294  Fecha (09/11/2016) - HRE - Cumulos
             IF (lasseg IS NULL) THEN
                SELECT t.sperson
                  INTO lasseg
                  FROM tomadores t, per_personas p
                 WHERE t.sseguro = psseguro
                   AND t.sperson = p.sperson;
             END IF;
             --FIN BUG CONF-250  - Fecha (09/11/2016) - HRE
         END IF;
      EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         RETURN 120007;
      END;

      -- Obtenim el codi del cúmul per producte
      BEGIN
         v_errlin := 4020;

          SELECT    ccumprod
               INTO lccumprod
               FROM cumulprod
              WHERE sproduc = psproduc
               AND finiefe <= pfefecto
               AND(ffinefe IS NULL
               OR ffinefe   > pfefecto);
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         lccumprod := - 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         RETURN 40301;
      END;
      p_traza_proceso(24, 'TRAZA_CESIONES_REA', 777, 'PAC_CESIONESREA', 'F_REACUMUL_EST', NULL, 7776,'lccumprod:'||
      lccumprod||' psproduc:'||psproduc||' pfefecto:'||pfefecto||' lasseg:'||lasseg);

      -- Mirem si ja existeix un cumul per aquesta persona i aquest conjunt de productes
      -- que fan cúmul
      lscumulo := NULL;

      BEGIN
         v_errlin := 4030;

         -- 13946 AVT 12-04-2010 s'afegeix el SCONTRA i la NVERSIO.
         SELECT DISTINCT c.scumulo, c.fcumini, c.fcumfin, c.ccumprod, c.sperson, c.ctipcum, c.cramo, c.sproduc,
               c.czona--BUG CONF-294  Fecha (09/11/2016) - HRE - se agrega la zona
               INTO lcum
               FROM cumulos c, reariesgos r --<<< AVT 12-04-2010
              WHERE sperson  = lasseg
               AND ccumprod  = lccumprod
               AND c.scumulo = r.scumulo
               AND r.scontra = pscontra
               --AND r.nversio = pnversio IAXIS-12992 27/04/2020
               AND fcumfin  IS NULL
               --INI BUG CONF-294  Fecha (09/11/2016) - HRE - Cumulos
               AND c.scumulo = (SELECT MAX(c1.scumulo) FROM cumulos c1, reariesgos r1 --<<< AVT 12-04-2010
                                WHERE sperson  = lasseg
                                 AND ccumprod  = lccumprod
                                 AND c1.scumulo = r1.scumulo
                                 AND r1.scontra = pscontra
                                 --AND r1.nversio = pnversio IAXIS-12992 27/04/2020
                                 AND fcumfin  IS NULL

               )
               AND ROWNUM = 1
               --FIN BUG CONF-294  - Fecha (09/11/2016) - HRE
               ;

         ---->-- -- dbms_output.put_line(' trobat cumul '||lcum.scumulo);
         lscumulo := lcum.scumulo;
         
         p_traza_proceso(24, 'TRAZA_CESIONES_REA', 777, 'PAC_CESIONESREA', 'F_REACUMUL_EST', NULL, 7777,'lccumprod:'||
      lccumprod||' psproduc:'||psproduc||' pfefecto:'||pfefecto||' lscumulo:'||lscumulo);
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         lscumulo := NULL;
         p_traza_proceso(24, 'TRAZA_CESIONES_REA', 777, 'PAC_CESIONESREA', 'F_REACUMUL_EST', NULL, 7778,'NO_DATA_FOUND');
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' a=' || lasseg || ' c=' || lccumprod);
         RETURN 104665;
      END;

      -- Mirem si cal tancar el cumul i fer un de nou
      -- i creem un cúmul nou (lscumulo pot canviar en aquesta funció)
      -- Insertem la pòlissa en aquest cumul
      IF lscumulo IS NULL THEN
         v_errlin := 4040;
         --INI BUG CONF-294 Fecha (09/11/2016) - HRE - Cumulos por tomador y zona geografica
         IF lctipcum = 2 THEN
            num_err := f_crea_cumul_tomador(pfefecto, lctipcum, lccumprod, pscontra, pnversio, psseguro, 'EST',lscumulo);
         ELSIF lctipcum = 3 THEN--si es cumulo x zona geografica, no se tiene en cuenta cumulos para validar
                                --capacidades de los contratos
            --num_err := f_crea_cumul_zona(lasseg, pfefecto, lctipcum, lccumprod, pscontra, pnversio, psseguro, lscumulo);
            num_err := 0;--f_crea_cumul_zona(lasseg, pfefecto, lctipcum, lccumprod, pscontra, pnversio, psseguro, lscumulo);
            lscumulo := NULL;
         ELSE
            num_err  := pac_cesionesrea.f_crea_cumul(lasseg, pfefecto, lctipcum, lccumprod, pscontra, pnversio, psseguro, lscumulo);
         END IF;
         --FIN BUG CONF-294  - Fecha (09/11/2016) - HRE
      END IF;
      ---->-- -- dbms_output.put_line('F_CREA_CUMUL '||num_Err);
      IF num_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' err=' || num_err || ' a=' || lasseg || ' t=' || lctipcum || ' c=' ||
         lccumprod);
         RETURN num_err;
      END IF;

      ---->-- -- dbms_output.put_line('Cumul tornat '||lscumulo);
      IF lscumulo IS NOT NULL THEN
         pscumulo := lscumulo;

         -- hem de mirar si ja existeix la pòlissa en el cúmul
         BEGIN
            v_errlin := 4050;

            SELECT DISTINCT sseguro
                  INTO lsseg
                  FROM reariesgos
                 WHERE scumulo = pscumulo
                  AND sseguro  = psseguro
                  AND nriesgo  = pnriesgo
                  AND freaini <= pfefecto
                  AND(freafin  > pfefecto
                  OR freafin  IS NULL); -- nunu
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- BUG 9781 - 04/05/2009 - FAL - Evitar inserción en reariesgos si ya existe.
            BEGIN
               v_errlin := 4060;

                SELECT    1
                     INTO waux
                     FROM reariesgos
                    WHERE sseguro = psseguro
                     AND nriesgo  = pnriesgo
                     AND freaini  = pfefecto
                     AND scumulo  = lscumulo
                     AND scontra  = pscontra
                     AND nversio  = pnversio
                     AND freafin IS NULL;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  ---->-- -- dbms_output.put_line(' inserta el propi sseguro '||psseguro);
                  v_errlin := 4070;

                   INSERT
                        INTO reariesgos
                        (
                           sseguro, nriesgo, freaini, scumulo, scontra, freafin, nversio
                        )
                        VALUES
                        (
                           psseguro, pnriesgo, pfefecto, lscumulo, pscontra, NULL, pnversio
                        );
               EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  NULL; -- Ja hi és
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' c=' || lscumulo);
                  RETURN 107096;
               END;
            END;
            -- FI BUG 9781 - 04/05/2009 – FAL
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            RETURN 104666;
         END;
      END IF;

      RETURN 0;
   END f_reacumul_est;

------------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------
   FUNCTION f_ple_cumul
      (
         psseguro IN NUMBER,
         pscumulo IN NUMBER,
         pcgarant IN NUMBER,
         pfefecto IN DATE,
         pcapcum OUT NUMBER,
         pipleno OUT NUMBER,
         picapaci OUT NUMBER
      )
      RETURN NUMBER
   IS
      ------------------------------------------------------------------------------
      -- Obtenim l'import sumat del tram 0 del cúmul
      -- Les garanties 1 i 8 fan cúmul juntes, cal veure com parametritzar-ho
      -- de moment les posem a pinyó
      ------------------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_PLE_CUMUL';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || 's=' || psseguro || ' c=' || pscumulo || ' g=' || pcgarant || ' e=' || pfefecto || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      lcmaxcum  NUMBER;
      v_fefecto DATE; --29011 AVT 13/11/13
   BEGIN
      v_errlin := 4081;

      -- 29011 AVT 13/11/13
       SELECT    MAX(freaini)
            INTO v_fefecto
            FROM reariesgos r
           WHERE r.scumulo = pscumulo
            AND(r.freafin  > pfefecto
            OR r.freafin  IS NULL);

      v_errlin            := 4080;

      -- 14536 AVT 25-05-2010 s'afegeix si les garanties acumulen entre elles (REACUMGAR)
       SELECT    NVL(SUM(c.icapces), 0), MAX(ipleno), MAX(icapaci)
            INTO pcapcum, pipleno, picapaci
            FROM seguros s, seguros s2, cesionesrea c, reariesgos r
           WHERE c.scumulo = pscumulo
            AND c.ctramo   = 0
            AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
            AND c.fvencim  > pfefecto
            AND(c.fanulac  > pfefecto
            OR c.fanulac  IS NULL)
            AND(c.fregula  > pfefecto
            OR c.fregula  IS NULL)
            AND r.scumulo  = c.scumulo
            AND r.sseguro  = c.sseguro
            AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
            AND(r.freafin  > pfefecto
            OR r.freafin  IS NULL)
            AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
            AND r.sseguro <> psseguro
            --AND c.cgarant = pcgarant -- 14536 AVT 25-05-2010
            AND s2.sseguro = psseguro
            AND s.sseguro  = c.sseguro
            AND c.scontra  = r.scontra
            AND c.nversio  = r.nversio
            AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR'), NVL(
            c.cgarant, 0)) = NVL(f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo), pcgarant,
            'REACUMGAR'), NVL(pcgarant, 0)); -- 14536 AVT 25-05-2010 fi

      -- 28777 AVT 13-11-13 nvl per quan fem cúmul de totes les garanties
      BEGIN
         v_errlin := 4085;

          SELECT    b.cmaxcum
               INTO lcmaxcum
               FROM cumulprod a, codicumprod b
              WHERE a.ccumprod = b.ccumprod
               AND a.sproduc   =
               (SELECT    sproduc
                     FROM seguros
                    WHERE sseguro = psseguro
               )
               AND a.finiefe <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
               AND(a.ffinefe IS NULL
               OR a.ffinefe   > pfefecto);
      EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         RETURN 40301;
      END;

      IF NVL(lcmaxcum, 0) = 0 THEN
         -- Retornem els maxims del ple i capital a zero,
         -- pq no s'han de tenir en compte
         pipleno  := 0;
         picapaci := 0;
      END IF;

      ---->-- -- dbms_output.put_line(' -------------- PCAPCUM '|| PCAPCUM);
      RETURN 0;
   EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
      RETURN 105297;
   END f_ple_cumul;

--BUG 19484 - 19/10/2011 - JRB - Se añaden las funciones est para el reaseguro.
-- Estas funciones contemplan tanto el trato de las tablas EST como el de las reales
------------------------------------------------------------------------------------
   FUNCTION f_ple_cumul_est(
         psseguro IN NUMBER,
         pscumulo IN NUMBER,
         pcgarant IN NUMBER,
         pfefecto IN DATE,
         pcapcum OUT NUMBER,
         pipleno OUT NUMBER,
         picapaci OUT NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER
   IS
      ------------------------------------------------------------------------------
      -- Obtenim l'import sumat del tram 0 del cúmul
      -- Les garanties 1 i 8 fan cúmul juntes, cal veure com parametritzar-ho
      -- de moment les posem a pinyó
      ------------------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_PLE_CUMUL_EST';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || 's=' || psseguro || ' c=' || pscumulo || ' g=' || pcgarant || ' e=' || pfefecto || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      lcmaxcum  NUMBER;
      v_fefecto DATE; --29011 AVT 13/11/13
   BEGIN
      v_errlin := 4081;

      -- 29011 AVT 13/11/13
       SELECT    MAX(freaini)
            INTO v_fefecto
            FROM reariesgos r
           WHERE r.scumulo = pscumulo
            AND(r.freafin  > pfefecto
            OR r.freafin  IS NULL);

      v_errlin            := 4080;

      IF ptablas           = 'EST' THEN
          SELECT    NVL(SUM(c.icapces), 0), MAX(ipleno), MAX(icapaci)
               INTO pcapcum, pipleno, picapaci
               FROM seguros s, estseguros s2, cesionesrea c, reariesgos r
              WHERE c.scumulo = pscumulo
               AND c.ctramo   = 0
               AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
               AND c.fvencim  > pfefecto
               AND(c.fanulac  > pfefecto
               OR c.fanulac  IS NULL)
               AND(c.fregula  > pfefecto
               OR c.fregula  IS NULL)
               AND r.scumulo  = c.scumulo
               AND r.sseguro  = c.sseguro
               AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13    --BUG 4867 CPM: Se controla la fecha inicio
               AND(r.freafin  > pfefecto
               OR r.freafin  IS NULL)
               AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
               AND r.sseguro <> psseguro
               AND s2.sseguro = psseguro
               AND s.sseguro  = c.sseguro
               AND c.scontra  = r.scontra
               AND c.nversio  = r.nversio
               AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR'),
               NVL(c.cgarant, 0)) = NVL(f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
               pcgarant, 'REACUMGAR'), NVL(pcgarant, 0)); -- 14536 AVT 25-05-2010 fi

         -- 28777 AVT 13-11-13 nvl per quan fem cúmul de totes les garanties
         BEGIN
            v_errlin := 4085;

             SELECT    b.cmaxcum
                  INTO lcmaxcum
                  FROM cumulprod a, codicumprod b
                 WHERE a.ccumprod = b.ccumprod
                  AND a.sproduc   =
                  (SELECT    sproduc
                        FROM estseguros
                       WHERE sseguro = psseguro
                  )
                  AND a.finiefe <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND(a.ffinefe IS NULL
                  OR a.ffinefe   > pfefecto);
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            --DBMS_OUTPUT.put_line('2:' || SQLERRM);
            RETURN 40301;
         END;
      ELSIF ptablas = 'CAR' THEN
          SELECT    NVL(SUM(c.icapces), 0), MAX(ipleno), MAX(icapaci)
               INTO pcapcum, pipleno, picapaci
               FROM seguros s, seguros s2, cesionesrea c, reariesgos r
              WHERE c.scumulo = pscumulo
               AND c.ctramo   = 0
               AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
               AND c.fvencim  > pfefecto
               AND(c.fanulac  > pfefecto
               OR c.fanulac  IS NULL)
               AND(c.fregula  > pfefecto
               OR c.fregula  IS NULL)
               AND r.scumulo  = c.scumulo
               AND r.sseguro  = c.sseguro
               AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13    --BUG 4867 CPM: Se controla la fecha inicio
               AND(r.freafin  > pfefecto
               OR r.freafin  IS NULL)
               AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
               AND r.sseguro <> psseguro
               --AND c.cgarant = pcgarant -- 14536 AVT 25-05-2010
               AND s2.sseguro = psseguro
               AND s.sseguro  = c.sseguro
               AND c.scontra  = r.scontra
               AND c.nversio  = r.nversio
               AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR'),
               NVL(c.cgarant, 0)) = NVL(f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
               pcgarant, 'REACUMGAR'), NVL(pcgarant, 0)); -- 14536 AVT 25-05-2010 fi

         -- 28777 AVT 13-11-13 nvl per quan fem cúmul de totes les garanties
         BEGIN
            v_errlin := 4085;

             SELECT    b.cmaxcum
                  INTO lcmaxcum
                  FROM cumulprod a, codicumprod b
                 WHERE a.ccumprod = b.ccumprod
                  AND a.sproduc   =
                  (SELECT    sproduc
                        FROM seguros
                       WHERE sseguro = psseguro
                  )
                  AND a.finiefe <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND(a.ffinefe IS NULL
                  OR a.ffinefe   > pfefecto);
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            RETURN 40301;
         END;
      ELSE
          SELECT    NVL(SUM(c.icapces), 0), MAX(ipleno), MAX(icapaci)
               INTO pcapcum, pipleno, picapaci
               FROM seguros s, seguros s2, cesionesrea c, reariesgos r
              WHERE c.scumulo = pscumulo
               AND c.ctramo   = 0
               AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
               AND c.fvencim  > pfefecto
               AND(c.fanulac  > pfefecto
               OR c.fanulac  IS NULL)
               AND(c.fregula  > pfefecto
               OR c.fregula  IS NULL)
               AND r.scumulo  = c.scumulo
               AND r.sseguro  = c.sseguro
               AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13    --BUG 4867 CPM: Se controla la fecha inicio
               AND(r.freafin  > pfefecto
               OR r.freafin  IS NULL)
               AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
               AND r.sseguro <> psseguro
               --AND c.cgarant = pcgarant -- 14536 AVT 25-05-2010
               AND s2.sseguro = psseguro
               AND s.sseguro  = c.sseguro
               AND c.scontra  = r.scontra
               AND c.nversio  = r.nversio
               AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR'),
               NVL(c.cgarant, 0)) = NVL(f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
               pcgarant, 'REACUMGAR'), NVL(pcgarant, 0)); -- 14536 AVT 25-05-2010 fi

         -- 28777 AVT 13-11-13 nvl per quan fem cúmul de totes les garanties
         BEGIN
            v_errlin := 4085;

             SELECT    b.cmaxcum
                  INTO lcmaxcum
                  FROM cumulprod a, codicumprod b
                 WHERE a.ccumprod = b.ccumprod
                  AND a.sproduc   =
                  (SELECT    sproduc
                        FROM seguros
                       WHERE sseguro = psseguro
                  )
                  AND a.finiefe <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND(a.ffinefe IS NULL
                  OR a.ffinefe   > pfefecto);
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            RETURN 40301;
         END;
      END IF;

      IF NVL(lcmaxcum, 0) = 0 THEN
         -- Retornem els maxims del ple i capital a zero,
         -- pq no s'han de tenir en compte
         pipleno  := 0;
         picapaci := 0;
      END IF;

      --DBMS_OUTPUT.put_line(' -------------- PCAPCUM ' || pcapcum);
      RETURN 0;
   EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
      RETURN 105297;
   END f_ple_cumul_est;

---------------------------------
   FUNCTION f_ple_cumul_tot(
         psseguro IN NUMBER,
         pscumulo IN NUMBER,
         pcgarant IN NUMBER,
         pfefecto IN DATE,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pcapcum_tot OUT NUMBER,
         pipleno_tot OUT NUMBER)
      RETURN NUMBER
   IS
      ------------------------------------------------------------------------------
      -- Obtenim l'import sumat del tram 0 del cúmul
      -- Les garanties 1 i 8 fan cúmul juntes, cal veure com parametritzar-ho
      -- de moment les posem a pinyó
      ------------------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_PLE_CUMUL_TOT';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || ' s=' || psseguro || ' c=' || pscumulo || ' g=' || pcgarant || ' e=' || pfefecto || ' c=' || pscontra || ' v=' ||
      pnversio || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      lcmaxcum NUMBER;
      liretenc NUMBER;
      lcgarrel NUMBER;
      v_cempres seguros.cempres%TYPE;
      v_ctiprea codicontratos.ctiprea%TYPE; -- 28777 13-11-13
      perr NUMBER;                          -->> 28492 AVT 12/11/2013
      v_cramo seguros.cramo%TYPE;           -->> 28492 AVT 12/11/2013
      v_cmodali seguros.cmodali%TYPE;       -->> 28492 AVT 12/11/2013
      v_ctipseg seguros.ctipseg%TYPE;       -->> 28492 AVT 12/11/2013
      v_ccolect seguros.ccolect%TYPE;       -->> 28492 AVT 12/11/2013
      v_cactivi seguros.cactivi%TYPE;       -->> 28492 AVT 12/11/2013
      v_scontra contratos.scontra%TYPE;     -->> 28492 AVT 12/11/2013
      v_nversio contratos.nversio%TYPE;     -->> 28492 AVT 12/11/2013
      v_icapaci contratos.icapaci%TYPE;     -->> 28492 AVT 12/11/2013
      v_cdetces cesionesrea.cdetces%TYPE;   -->> 28492 AVT 12/11/2013
      v_fefecto DATE;                       --29011 AVT 13/11/13
   BEGIN
      v_errlin := 5001;

      -- 29011 AVT 13/11/13
       SELECT    MAX(freaini)
            INTO v_fefecto
            FROM reariesgos r
           WHERE r.scumulo = pscumulo
            AND(r.freafin  > pfefecto
            OR r.freafin  IS NULL);

      v_errlin            := 5005;

       SELECT    cempres, cramo, cmodali, ctipseg, ccolect, cactivi
            INTO v_cempres, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi
            FROM seguros seg
           WHERE seg.sseguro = psseguro;

      v_errlin              := 5000;

      -- AVT 28777 13-11-13 en cas de XL el ple net de retnció és el total del Capital (hauia de ser el tram?...)
       SELECT    ctiprea
            INTO v_ctiprea
            FROM codicontratos
           WHERE scontra = pscontra;

      IF v_ctiprea       = 3 THEN
         --28492 AVT 13/11/2013 LA SELECT NO SERVEIX SI UN CONTRACTE COBREIS DOS O MÉS PRODUCTES.
         perr := f_buscacontrato(psseguro, pfefecto, v_cempres, pcgarant, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi, 11, v_scontra, v_nversio,
         liretenc, v_icapaci, v_cdetces); -- revisar evento!!!

         IF perr <> 0 THEN
            RETURN(perr);
         END IF;
         --         SELECT NVL(a.ilimsub, icapaci), NVL(cgarrel, 0)
         --           INTO liretenc, lcgarrel
         --           FROM contratos c, agr_contratos a
         --          WHERE c.scontra = a.scontra
         --            AND c.scontra = pscontra
         --            AND c.nversio = pnversio;
      ELSE -- 28777 13-11-13 fi --------------
          SELECT    iretenc, NVL(cgarrel, 0)
               INTO liretenc, lcgarrel
               FROM contratos
              WHERE scontra = pscontra
               AND nversio  = pnversio;
      END IF;

      ---- -- dbms_output.put_line (' liretenc '||liretenc);
      ---- -- dbms_output.put_line (' lcgarrel '||lcgarrel);
      ---- -- dbms_output.put_line (' pscontra '||pscontra);
      ---- -- dbms_output.put_line (' pnversio '||pnversio);

      -- BUG 9704 - 15/04/09 - ICV - Cambio del parametro REACUMGAR por REACUM de parempresas.
      --IF f_parinstalacion_n('REACUMGAR') = 1 THEN   -- JGR 2004-05-26 DESDE
      IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REACUM'), 0) = 1 THEN
         --FI BUG 9704  - 15/04/09 – ICV
         -- CPM 20/07/04: Afegim s2 per trobar les dades del seguro que estem tractant
         v_errlin := 5010;

         -- 13946 AVT 06-04-2010 s'afegeix el SCONTRA i la NVERSIO.
          SELECT    NVL(SUM(c.icapces), 0), NVL(MAX(ipleno), 0)
               INTO pcapcum_tot, pipleno_tot
               FROM seguros s, seguros s2, cesionesrea c, reariesgos r
              WHERE c.scumulo = pscumulo
               AND c.ctramo   = 0
               AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
               AND c.fvencim  > pfefecto
               AND(c.fanulac  > pfefecto
               OR c.fanulac  IS NULL)
               AND(c.fregula  > pfefecto
               OR c.fregula  IS NULL)
               AND r.scumulo  = c.scumulo
               AND r.sseguro  = c.sseguro
               AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
               AND(r.freafin  > pfefecto
               OR r.freafin  IS NULL)
               AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
               AND r.sseguro <> psseguro
               AND s2.sseguro = psseguro
               AND s.sseguro  = c.sseguro
               AND c.scontra  = pscontra
               AND c.nversio  = pnversio
               AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR'),
               NVL(c.cgarant, 0)) = NVL(f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
               pcgarant, 'REACUMGAR'), NVL(pcgarant, 0));
         -- 28777 AVT 13-11-13 nvl per quan fem cúmul de totes les garanties
      ELSE -- JGR 2004-05-26 HASTA
         -- AVT AQUESTA SELECT NO FUNCIONA PER lcgarrel = 0 (BUG:12665)
         v_errlin := 5015;

         -- 13946 AVT 06-04-2010 s'afegeix el SCONTRA i la NVERSIO.
          SELECT    NVL(SUM(c.icapces), 0), NVL(MAX(ipleno), 0)
               INTO pcapcum_tot, pipleno_tot
               FROM seguros s, cesionesrea c, reariesgos r
              WHERE c.scumulo  = pscumulo
               AND c.scontra   = pscontra
               AND c.nversio   = pnversio
               AND c.ctramo    = 0
               AND c.fefecto  <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
               AND c.fvencim   > pfefecto
               AND(c.fanulac   > pfefecto
               OR c.fanulac   IS NULL)
               AND(c.fregula   > pfefecto
               OR c.fregula   IS NULL)
               AND r.scumulo   = c.scumulo
               AND r.sseguro   = c.sseguro
               AND freaini    <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
               AND(r.freafin   > pfefecto
               OR r.freafin   IS NULL)
               AND cgenera    IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
               AND((lcgarrel   = 0
               AND c.cgarant   = pcgarant
               AND r.sseguro  <> psseguro
               AND r.sseguro   = s.sseguro) -- AVT bug: 12665 13-01-2010
               OR(lcgarrel     = 1
               AND((r.sseguro <> psseguro
               AND(c.cgarant   = DECODE(pcgarant, 1, 8, 8, 1, pcgarant)
               OR c.cgarant    = pcgarant))
               OR(r.sseguro    = psseguro
               AND c.cgarant  <> pcgarant
               AND pcgarant   IN(1, 8)
               AND c.cgarant  IN(1, 8)))));
      END IF; -- JGR 2004-05-26 HASTA

      -- Obtenir el ple del contracte, el total
      BEGIN
         v_errlin := 5020;

          SELECT    b.cmaxcum
               INTO lcmaxcum
               FROM cumulprod a, codicumprod b
              WHERE a.ccumprod = b.ccumprod
               AND a.sproduc   =
               (SELECT    sproduc
                     FROM seguros
                    WHERE sseguro = psseguro
               )
               AND a.finiefe <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
               AND(a.ffinefe IS NULL
               OR a.ffinefe   > pfefecto);
      EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         RETURN 40301;
      END;

      -- -- dbms_output.put_line('cmaxcum '||lcmaxcum );
      IF lcmaxcum = 0 THEN
         -- -- dbms_output.put_line('DINS FUNCIÓ canvia iretenc '||liretenc );
         pipleno_tot := liretenc;
         -- -- dbms_output.put_line('DINS FUNCIÓ canvia pipleno_tot '||pipleno_tot );
      ELSE -- el màxim
         IF liretenc     > pipleno_tot THEN
            pipleno_tot := liretenc;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
      RETURN 105297;
   END f_ple_cumul_tot;

---------------------------------
--BUG 19484 - 19/10/2011 - JRB - Se añaden las funciones est para el reaseguro.
-- Estas funciones contemplan tanto el trato de las tablas EST como el de las reales
-------------------------------------------------------------------------------------
   FUNCTION f_ple_cumul_tot_est(
         psseguro IN NUMBER,
         pscumulo IN NUMBER,
         pcgarant IN NUMBER,
         pfefecto IN DATE,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pcapcum_tot OUT NUMBER,
         pipleno_tot OUT NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER
   IS
      ------------------------------------------------------------------------------
      -- Obtenim l'import sumat del tram 0 del cúmul
      -- Les garanties 1 i 8 fan cúmul juntes, cal veure com parametritzar-ho
      -- de moment les posem a pinyó
      ------------------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_PLE_CUMUL_TOT_EST';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || ' s=' || psseguro || ' c=' || pscumulo || ' g=' || pcgarant || ' e=' || pfefecto || ' c=' || pscontra || ' v=' ||
      pnversio || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      lcmaxcum NUMBER;
      liretenc NUMBER;
      lcgarrel NUMBER;
      v_cempres seguros.cempres%TYPE;
      v_ctiprea codicontratos.ctiprea%TYPE; -- 28777 13-11-13
      perr NUMBER;                          -->> 28492 AVT 12/11/2013
      v_cramo seguros.cramo%TYPE;           -->> 28492 AVT 12/11/2013
      v_cmodali seguros.cmodali%TYPE;       -->> 28492 AVT 12/11/2013
      v_ctipseg seguros.ctipseg%TYPE;       -->> 28492 AVT 12/11/2013
      v_ccolect seguros.ccolect%TYPE;       -->> 28492 AVT 12/11/2013
      v_cactivi seguros.cactivi%TYPE;       -->> 28492 AVT 12/11/2013
      v_scontra contratos.scontra%TYPE;     -->> 28492 AVT 12/11/2013
      v_nversio contratos.nversio%TYPE;     -->> 28492 AVT 12/11/2013
      v_icapaci contratos.icapaci%TYPE;     -->> 28492 AVT 12/11/2013
      v_cdetces cesionesrea.cdetces%TYPE;   -->> 28492 AVT 12/11/2013
      v_fefecto DATE;                       --29011 AVT 13/11/13
   BEGIN
      v_errlin := 5001;

      -- 29011 AVT 13/11/13
       SELECT    MAX(freaini)
            INTO v_fefecto
            FROM reariesgos r
           WHERE r.scumulo = pscumulo
            AND(r.freafin  > pfefecto
            OR r.freafin  IS NULL);

      v_errlin            := 5000;

      -- AVT 28777 13-11-13 en cas de XL el ple net de retnció és el total del Capital (hauia de ser el tram?...)
       SELECT    ctiprea
            INTO v_ctiprea
            FROM codicontratos
           WHERE scontra = pscontra;

      v_errlin          := 5005;

      IF ptablas         = 'EST' THEN
          SELECT    cempres, cramo, cmodali, ctipseg, ccolect, cactivi
               INTO v_cempres, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi
               FROM estseguros seg
              WHERE seg.sseguro = psseguro;
      ELSE
          SELECT    cempres, cramo, cmodali, ctipseg, ccolect, cactivi
               INTO v_cempres, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi
               FROM seguros seg
              WHERE seg.sseguro = psseguro;
      END IF;

      IF v_ctiprea = 3 THEN
         --28492 AVT 13/11/2013 LA SELECT NO SERVEIX SI UN CONTRACTE COBREIS DOS O MÉS PRODUCTES.
         perr := f_buscacontrato(psseguro, pfefecto, v_cempres, pcgarant, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi, 11, v_scontra, v_nversio,
         liretenc, v_icapaci, v_cdetces); -- revisar evento!!!

         IF perr <> 0 THEN
            RETURN(perr);
         END IF;
         --         SELECT NVL(a.ilimsub, icapaci), NVL(cgarrel, 0)
         --           INTO liretenc, lcgarrel
         --           FROM contratos c, agr_contratos a
         --          WHERE c.scontra = a.scontra
         --            AND c.scontra = pscontra
         --            AND c.nversio = pnversio;
      ELSE -- 28777 13-11-13 fi --------------
          SELECT    iretenc, NVL(cgarrel, 0)
               INTO liretenc, lcgarrel
               FROM contratos
              WHERE scontra = pscontra
               AND nversio  = pnversio;
      END IF;

      v_errlin                                                        := 5005;

      IF ptablas                                                       = 'EST' THEN
         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REACUM'), 0) = 1 THEN
            v_errlin                                                  := 5010;

             SELECT    NVL(SUM(c.icapces), 0), NVL(MAX(ipleno), 0)
                  INTO pcapcum_tot, pipleno_tot
                  FROM seguros s, estseguros s2, cesionesrea c, reariesgos r
                 WHERE c.scumulo = pscumulo
                  AND c.ctramo   = 0
                  AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND c.fvencim  > pfefecto
                  AND(c.fanulac  > pfefecto
                  OR c.fanulac  IS NULL)
                  AND(c.fregula  > pfefecto
                  OR c.fregula  IS NULL)
                  AND r.scumulo  = c.scumulo
                  AND r.sseguro  = c.sseguro
                  AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
                  AND(r.freafin  > pfefecto
                  OR r.freafin  IS NULL)
                  AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
                  AND r.sseguro <> psseguro
                  AND s2.sseguro = psseguro
                  AND s.sseguro  = c.sseguro
                  AND c.scontra  = pscontra
                  AND c.nversio  = pnversio
                  AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR')
                  , NVL(c.cgarant, 0)) = NVL(f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
                  pcgarant, 'REACUMGAR'), NVL(pcgarant, 0));
         ELSE
            v_errlin := 5015;

             SELECT    NVL(SUM(c.icapces), 0), NVL(MAX(ipleno), 0)
                  INTO pcapcum_tot, pipleno_tot
                  FROM seguros s, cesionesrea c, reariesgos r
                 WHERE c.scumulo  = pscumulo
                  AND c.scontra   = pscontra
                  AND c.nversio   = pnversio
                  AND c.ctramo    = 0
                  AND c.fefecto  <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND c.fvencim   > pfefecto
                  AND(c.fanulac   > pfefecto
                  OR c.fanulac   IS NULL)
                  AND(c.fregula   > pfefecto
                  OR c.fregula   IS NULL)
                  AND r.scumulo   = c.scumulo
                  AND r.sseguro   = c.sseguro
                  AND freaini    <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
                  AND(r.freafin   > pfefecto
                  OR r.freafin   IS NULL)
                  AND cgenera    IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
                  AND((lcgarrel   = 0
                  AND c.cgarant   = pcgarant
                  AND r.sseguro  <> psseguro
                  AND r.sseguro   = s.sseguro) -- AVT bug: 12665 13-01-2010
                  OR(lcgarrel     = 1
                  AND((r.sseguro <> psseguro
                  AND(c.cgarant   = DECODE(pcgarant, 1, 8, 8, 1, pcgarant)
                  OR c.cgarant    = pcgarant))
                  OR(r.sseguro    = psseguro
                  AND c.cgarant  <> pcgarant
                  AND pcgarant   IN(1, 8)
                  AND c.cgarant  IN(1, 8)))));
         END IF; -- JGR 2004-05-26 HASTA
      ELSIF ptablas                                                    = 'CAR' THEN
         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REACUM'), 0) = 1 THEN
            --FI BUG 9704  - 15/04/09 – ICV
            -- CPM 20/07/04: Afegim s2 per trobar les dades del seguro que estem tractant
            v_errlin := 5010;

            -- 13946 AVT 06-04-2010 s'afegeix el SCONTRA i la NVERSIO.
             SELECT    NVL(SUM(c.icapces), 0), NVL(MAX(ipleno), 0)
                  INTO pcapcum_tot, pipleno_tot
                  FROM seguros s, seguros s2, cesionesrea c, reariesgos r
                 WHERE c.scumulo = pscumulo
                  AND c.ctramo   = 0
                  AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND c.fvencim  > pfefecto
                  AND(c.fanulac  > pfefecto
                  OR c.fanulac  IS NULL)
                  AND(c.fregula  > pfefecto
                  OR c.fregula  IS NULL)
                  AND r.scumulo  = c.scumulo
                  AND r.sseguro  = c.sseguro
                  AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
                  AND(r.freafin  > pfefecto
                  OR r.freafin  IS NULL)
                  AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
                  AND r.sseguro <> psseguro
                  AND s2.sseguro = psseguro
                  AND s.sseguro  = c.sseguro
                  AND c.scontra  = pscontra
                  AND c.nversio  = pnversio
                  AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR')
                  , NVL(c.cgarant, 0)) = NVL(f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
                  pcgarant, 'REACUMGAR'), NVL(pcgarant, 0));
         ELSE -- JGR 2004-05-26 HASTA
            -- AVT AQUESTA SELECT NO FUNCIONA PER lcgarrel = 0 (BUG:12665)
            v_errlin := 5015;

            -- 13946 AVT 06-04-2010 s'afegeix el SCONTRA i la NVERSIO.
             SELECT    NVL(SUM(c.icapces), 0), NVL(MAX(ipleno), 0)
                  INTO pcapcum_tot, pipleno_tot
                  FROM seguros s, cesionesrea c, reariesgos r
                 WHERE c.scumulo  = pscumulo
                  AND c.scontra   = pscontra
                  AND c.nversio   = pnversio
                  AND c.ctramo    = 0
                  AND c.fefecto  <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND c.fvencim   > pfefecto
                  AND(c.fanulac   > pfefecto
                  OR c.fanulac   IS NULL)
                  AND(c.fregula   > pfefecto
                  OR c.fregula   IS NULL)
                  AND r.scumulo   = c.scumulo
                  AND r.sseguro   = c.sseguro
                  AND freaini    <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
                  AND(r.freafin   > pfefecto
                  OR r.freafin   IS NULL)
                  AND cgenera    IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
                  AND((lcgarrel   = 0
                  AND c.cgarant   = pcgarant
                  AND r.sseguro  <> psseguro
                  AND r.sseguro   = s.sseguro) -- AVT bug: 12665 13-01-2010
                  OR(lcgarrel     = 1
                  AND((r.sseguro <> psseguro
                  AND(c.cgarant   = DECODE(pcgarant, 1, 8, 8, 1, pcgarant)
                  OR c.cgarant    = pcgarant))
                  OR(r.sseguro    = psseguro
                  AND c.cgarant  <> pcgarant
                  AND pcgarant   IN(1, 8)
                  AND c.cgarant  IN(1, 8)))));
         END IF; -- JGR 2004-05-26 HASTA
      ELSE
         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REACUM'), 0) = 1 THEN
            --FI BUG 9704  - 15/04/09 – ICV
            -- CPM 20/07/04: Afegim s2 per trobar les dades del seguro que estem tractant
            v_errlin := 5010;

            -- 13946 AVT 06-04-2010 s'afegeix el SCONTRA i la NVERSIO.
             SELECT    NVL(SUM(c.icapces), 0), NVL(MAX(ipleno), 0)
                  INTO pcapcum_tot, pipleno_tot
                  FROM seguros s, seguros s2, cesionesrea c, reariesgos r
                 WHERE c.scumulo = pscumulo
                  AND c.ctramo   = 0
                  AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND c.fvencim  > pfefecto
                  AND(c.fanulac  > pfefecto
                  OR c.fanulac  IS NULL)
                  AND(c.fregula  > pfefecto
                  OR c.fregula  IS NULL)
                  AND r.scumulo  = c.scumulo
                  AND r.sseguro  = c.sseguro
                  AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
                  AND(r.freafin  > pfefecto
                  OR r.freafin  IS NULL)
                  AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
                  AND r.sseguro <> psseguro
                  AND s2.sseguro = psseguro
                  AND s.sseguro  = c.sseguro
                  AND c.scontra  = pscontra
                  AND c.nversio  = pnversio
                  AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR')
                  , NVL(c.cgarant, 0)) = NVL(f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
                  pcgarant, 'REACUMGAR'), NVL(pcgarant, 0));
         ELSE -- JGR 2004-05-26 HASTA
            -- AVT AQUESTA SELECT NO FUNCIONA PER lcgarrel = 0 (BUG:12665)
            v_errlin := 5015;

            -- 13946 AVT 06-04-2010 s'afegeix el SCONTRA i la NVERSIO.
             SELECT    NVL(SUM(c.icapces), 0), NVL(MAX(ipleno), 0)
                  INTO pcapcum_tot, pipleno_tot
                  FROM seguros s, cesionesrea c, reariesgos r
                 WHERE c.scumulo  = pscumulo
                  AND c.scontra   = pscontra
                  AND c.nversio   = pnversio
                  AND c.ctramo    = 0
                  AND c.fefecto  <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND c.fvencim   > pfefecto
                  AND(c.fanulac   > pfefecto
                  OR c.fanulac   IS NULL)
                  AND(c.fregula   > pfefecto
                  OR c.fregula   IS NULL)
                  AND r.scumulo   = c.scumulo
                  AND r.sseguro   = c.sseguro
                  AND freaini    <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
                  AND(r.freafin   > pfefecto
                  OR r.freafin   IS NULL)
                  AND cgenera    IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
                  AND((lcgarrel   = 0
                  AND c.cgarant   = pcgarant
                  AND r.sseguro  <> psseguro
                  AND r.sseguro   = s.sseguro) -- AVT bug: 12665 13-01-2010
                  OR(lcgarrel     = 1
                  AND((r.sseguro <> psseguro
                  AND(c.cgarant   = DECODE(pcgarant, 1, 8, 8, 1, pcgarant)
                  OR c.cgarant    = pcgarant))
                  OR(r.sseguro    = psseguro
                  AND c.cgarant  <> pcgarant
                  AND pcgarant   IN(1, 8)
                  AND c.cgarant  IN(1, 8)))));
         END IF; -- JGR 2004-05-26 HASTA
      END IF;

      -- Obtenir el ple del contracte, el total
      IF ptablas = 'EST' THEN
         BEGIN
            v_errlin := 5020;

             SELECT    b.cmaxcum
                  INTO lcmaxcum
                  FROM cumulprod a, codicumprod b
                 WHERE a.ccumprod = b.ccumprod
                  AND a.sproduc   =
                  (SELECT    sproduc
                        FROM estseguros
                       WHERE sseguro = psseguro
                  )
                  AND a.finiefe <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND(a.ffinefe IS NULL
                  OR a.ffinefe   > pfefecto);
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            --DBMS_OUTPUT.put_line('3:' || SQLERRM);
            RETURN 40301;
         END;
      ELSE
         -- Obtenir el ple del contracte, el total
         BEGIN
            v_errlin := 5020;

             SELECT    b.cmaxcum
                  INTO lcmaxcum
                  FROM cumulprod a, codicumprod b
                 WHERE a.ccumprod = b.ccumprod
                  AND a.sproduc   =
                  (SELECT    sproduc
                        FROM seguros
                       WHERE sseguro = psseguro
                  )
                  AND a.finiefe <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND(a.ffinefe IS NULL
                  OR a.ffinefe   > pfefecto);
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            RETURN 40301;
         END;
      END IF;

      IF lcmaxcum     = 0 THEN
         pipleno_tot := liretenc;
      ELSE -- el màxim
         IF liretenc     > pipleno_tot THEN
            pipleno_tot := liretenc;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
      RETURN 105297;
   END f_ple_cumul_tot_est;

-----------------------------------

-------------------------------------------------------------------------------------
   FUNCTION f_gar_rea(
         pcramo IN NUMBER,
         pcmodali IN NUMBER,
         pctipseg IN NUMBER,
         pccolect IN NUMBER,
         pcactivi IN NUMBER,
         pcgarant IN NUMBER,
         pcreaseg OUT NUMBER)
      RETURN NUMBER
   IS
      -------------------------------------------------------------------------------------
      -- Mira si una garantia es reassegura, la actividad ja bé filtrada pel risc
      -------------------------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_GAR_REA';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || ' r=' || pcramo || ' m=' || pcmodali || ' t=' || pctipseg || ' c=' || pccolect || ' a=' || pcactivi || ' g=' || pcgarant
      || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
   BEGIN
      BEGIN
         v_errlin := 5040;

          SELECT    creaseg -- es reassegura...
               INTO pcreaseg
               FROM garanpro
              WHERE cramo  = pcramo
               AND cmodali = pcmodali
               AND ctipseg = pctipseg
               AND ccolect = pccolect
               AND cactivi = pcactivi
               AND cgarant = pcgarant;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         BEGIN
            v_errlin := 5050;

             SELECT    creaseg
                  INTO pcreaseg
                  FROM garanpro
                 WHERE cramo  = pcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect
                  AND cactivi = 0
                  AND cgarant = pcgarant;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            RETURN(104110);
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            RETURN(103503);
         END;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         RETURN(103503);
      END;

      RETURN 0;
   END f_gar_rea;

------------------------------------------------------------------------------
   FUNCTION f_cessio_det(
         psproces IN NUMBER,
         psseguro IN NUMBER,
         pnrecibo IN NUMBER,
         pcactivi IN NUMBER,
         pcramo IN NUMBER,
         pcmodali IN NUMBER,
         pctipseg IN NUMBER,
         pccolect IN NUMBER,
         pfefecto IN DATE,
         pfvencim IN DATE,
         pnfactor IN NUMBER,
         pmoneda IN NUMBER,
         pcmotces IN NUMBER DEFAULT 1,
         pmodo IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      ------------------------------------------------------------------------------
      /***********************************************************************
      PNFACTOR No s'utilitza, es calcula a dins de la funció
      F_CESSIO_DET: Aquesta funció genera el detall de rebut per la part cedida
      a la reassegurança. Es grava a la taula REASEGEMI i DETREASEGEMI
      NOMÉS es grava si el camp CDETCES de Cesionesrea val 1
      Es realitzen a partir de les dades i percentatges de cessió que figuren
      en els moviments de cessions efectuades, sempre en funció de les dates
      cobertes per la cessió amb relació a la data d'efecte del rebut.
      Primer buscarem cessions de igual garantía i si no en trobem, buscarem
      cessions del risc afectat amb la garantía a NULL.
      -- pcmotces 1 - EMISSIÓ, 3- Regularització cúmul
      -- La garantia ja ve filtrada pel risc.
      ***********************************************************************/

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_CESSIO_DET';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || ' p=' || psproces || ' s=' || psseguro || ' r=' || pnrecibo || ' a=' || pcactivi || ' r=' || pcramo || ' m=' || pcmodali
      || ' t=' || pctipseg || ' c=' || pccolect || ' e=' || pfefecto || ' v=' || pfvencim || ' f=' || pnfactor || ' m=' || pmoneda || ' c=' || pcmotces || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      codi_error NUMBER := 0;
      lsreaemi   NUMBER(8);
      -- w_trovat       NUMBER(1); -- 12626 AVT 13-01-2010  no es necessari
      licesion    NUMBER;
      lipritarrea NUMBER;
      lidtosel    NUMBER;
      liextrea    NUMBER;
      avui        DATE;
      lprimer     NUMBER;
      -- lcreaseg       NUMBER;  -- 12626 AVT 13-01-2010  no es necessari tornar-ho a mirar
      lctiprec NUMBER;
      ltotal   NUMBER;
      nprolin  NUMBER;
      lfactor  NUMBER;
      w_dias1  NUMBER;
      w_dias2  NUMBER;
      -- M.R.B. 12-03-2008
      -- w_iprianu      NUMBER(10, 2) := 0; -- 12626 AVT 13-01-2010  no es necessari
      -- w_suma_cesionesrea NUMBER(10, 2) := 0; -- 12626 AVT 13-01-2010  no es necessari
      -- w_factor_cessio NUMBER(12, 5) := 0; -- 12626 AVT 13-01-2010  no es necessari
      -- w_resta        NUMBER(10, 2) := 0; -- 12626 AVT 13-01-2010  no es necessari
      -- w_ultim_registre NUMBER(10) := 0; -- 12626 AVT 13-01-2010  no es necessari
      -- Bug 12178 - 09/12/2009 - RSC - CRE201 - error en emisión en pólizas colectivas de salud.
      v_sproduc NUMBER;
      v_esccero NUMBER;
      v_copago  NUMBER;
      lcmovseg  NUMBER; -- 13195 AVT 10-03-2010
      -- Fin Bug 12178

      -- Bug 17623 - RSC - 21/02/2010 - Revisió Cesiones MULTIRRIESGO.
      v_fefeadm DATE;
      w_ndurcob NUMBER; -- 20439 AVT 13/01/2012
      w_fvencim DATE;   -- 20439 AVT 13/01/2012
      w_fefecto DATE;   -- 20439 AVT 13/01/2012
      w_fconini DATE;   -- 20439 AVT 13/01/2012
      w_fconfin DATE;   -- 20439 AVT 16/01/2012

      -- Fin Bug 17623

      -- BUG 8939 - 13/08/2009 - JRB - Se sustituye la búsqueda por nmovigen, usando ahora fefecto <= pfefecto y fvencim > pfefecto
      CURSOR c_det(wsseguro NUMBER, wfefecto DATE)
      IS
         SELECT DISTINCT nriesgo, cgarant
               FROM cesionesrea
              WHERE sseguro = wsseguro
               AND fefecto <= wfefecto
               AND fvencim  > wfefecto
               --AND cgarant IS NOT NULL
               AND cgenera        <> 2
               AND NVL(cdetces, 0) = 1;

      -- BUG 8939 - 13/08/2009 - JRB - Se sustituye la búsqueda por nmovigen, usando ahora fefecto <= pfefecto y fvencim > pfefecto
      -- Per garantia
      -- BUG: 12961 AVT 02-02-2010 s'afegeix el tipus de rebut:
      CURSOR cur_cesion1(wsseguro NUMBER, wnriesgo NUMBER, wcgarant NUMBER, wfefecto DATE, wnrecibo NUMBER, wctiprec NUMBER, wcmovseg NUMBER)
      IS
          SELECT    *
               FROM cesionesrea
              WHERE sseguro = wsseguro
               AND fefecto <= wfefecto
               AND fvencim  > wfefecto
               -- 10805 AVT 20-10-2009 s'han de considerar només les cessions amb efecte
               AND(fanulac > wfefecto
               OR fanulac IS NULL)
               AND(fregula > wfefecto
               OR fregula IS NULL)
               -- 10805 AVT 20-10-2009 fi
               AND nriesgo = wnriesgo
               AND cgarant = wcgarant
               -- bug 0029068 19-12-2013 afegir rehabilitacio
               AND((cgenera       IN(1, 3, 4, 5, 9, 40) --> BUG: 13195 11-03-2010 AVT : Rebuts d'alta i cartera
               AND wctiprec       IN(0, 3)
               AND wcmovseg       IN(0, 1, 2, 4))          -- BUG: 14400 03-05-2010 AVT
               OR(cgenera         IN(1, 3, 4, 5, 7, 9, 40) --> BUG: 13195 11-03-2010 AVT : Suplements
               AND wctiprec       IN (1, 4)                --> Bug 13832 - 01/07/2010 - RSC -  APRS015 - suplemento de aportaciones únicas
               AND wcmovseg        = 1)
               OR(cgenera         IN(1, 3, 4, 5, 7, 9, 40)
               AND wctiprec        = 9 --> BUG: 13195 11-03-2010 AVT : Extorn sense anul·lació
               AND wcmovseg       <> 3)
               OR(wctiprec         = 9 --> BUG: 13195 11-03-2010 AVT : Extorn per anul·lació
               AND wcmovseg        = 3
               AND cgenera         = 6)) -- BUG: 12961 AVT 02-02-2010
               AND NVL(cdetces, 0) = 1
               -- BUG 11674 - 04/11/2009 - JGR - Error en el cálculos de la cesiones de reaseguro para recibos en productos de ahorro (desde)
               -- Bug 12178 - 09/12/2009 - RSC - CRE201 - error en emisión en pólizas colectivas de salud.
               -- Bug 12993 - 09-02-2010 - AVT - CRE - Reasegurar garantias que no tienen prima
               AND(cgarant, nriesgo) IN
               (SELECT    cgarant, nriesgo
                     FROM detrecibos
                    WHERE nrecibo = wnrecibo
               );

      -- BUG 8939 - 13/08/2009 - JRB - Se sustituye la búsqueda por nmovigen, usando ahora fefecto <= pfefecto y fvencim > pfefecto
      -- Per garantia
      -- BUG: 12961 AVT 02-02-2010 s'afegeix el tipus de rebut:
      CURSOR cur_cesion1_tmp(wsseguro NUMBER, wnriesgo NUMBER, wcgarant NUMBER, wfefecto DATE, wnrecibo NUMBER, wctiprec NUMBER, wcmovseg NUMBER)
      IS
          SELECT    *
               FROM cesionesrea
              WHERE sseguro = wsseguro
               AND fefecto <= wfefecto
               AND fvencim  > wfefecto
               -- 10805 AVT 20-10-2009 s'han de considerar només les cessions amb efecte
               AND(fanulac > wfefecto
               OR fanulac IS NULL)
               AND(fregula > wfefecto
               OR fregula IS NULL)
               -- 10805 AVT 20-10-2009 fi
               AND nriesgo = wnriesgo
               AND cgarant = wcgarant
               -- bug 0029068 19-12-2013 afegir rehabilitacio
               AND((cgenera       IN(1, 3, 4, 5, 9, 40) --> BUG: 13195 11-03-2010 AVT : Rebuts d'alta i cartera
               AND wctiprec       IN(0, 3)
               AND wcmovseg       IN(0, 1, 2, 4))          -- BUG: 14400 03-05-2010 AVT
               OR(cgenera         IN(1, 3, 4, 5, 7, 9, 40) --> BUG: 13195 11-03-2010 AVT : Suplements
               AND wctiprec       IN (1, 4)                --> Bug 13832 - 01/07/2010 - RSC -  APRS015 - suplemento de aportaciones únicas
               AND wcmovseg        = 1)
               OR(cgenera         IN(1, 3, 4, 5, 7, 9, 40)
               AND wctiprec        = 9 --> BUG: 13195 11-03-2010 AVT : Extorn sense anul·lació
               AND wcmovseg       <> 3)
               OR(wctiprec         = 9 --> BUG: 13195 11-03-2010 AVT : Extorn per anul·lació
               AND wcmovseg        = 3
               AND cgenera         = 6)) -- BUG: 12961 AVT 02-02-2010
               AND NVL(cdetces, 0) = 1
               -- BUG 11674 - 04/11/2009 - JGR - Error en el cálculos de la cesiones de reaseguro para recibos en productos de ahorro (desde)
               -- Bug 12178 - 09/12/2009 - RSC - CRE201 - error en emisión en pólizas colectivas de salud.
               -- Bug 12993 - 09-02-2010 - AVT - CRE - Reasegurar garantias que no tienen prima
               AND(cgarant, nriesgo) IN
               (SELECT    cgarant, nriesgo
                     FROM tmp_adm_detrecibos
                    WHERE nrecibo = wnrecibo
               );

      --AND nriesgo IN(SELECT nriesgo
      --               FROM detrecibos
      --            WHERE nrecibo = wnrecibo);

      -- FI BUG 11674 - 04/11/2009 – JGR

      -- BUG 8939 - 13/08/2009 - JRB - Se sustituye la búsqueda por nmovigen, usando ahora fefecto <= pfefecto y fvencim > pfefecto
      -- BUG: 12961 AVT 02-02-2010 s'afegeix el tipus de rebut: wctiprec
      CURSOR cur_cesion2(wsseguro NUMBER, wnriesgo NUMBER, wfefecto DATE, wctiprec NUMBER, wcmovseg NUMBER)
      IS
          SELECT    *
               FROM cesionesrea
              WHERE sseguro = wsseguro
               AND fefecto <= wfefecto
               AND fvencim  > wfefecto
               -- 10805 AVT 20-10-2009 s'han de considerar només les cessions amb efecte
               AND(fanulac > wfefecto
               OR fanulac IS NULL)
               AND(fregula > wfefecto
               OR fregula IS NULL)
               -- 10805 AVT 20-10-2009 fi
               AND nriesgo  = wnriesgo
               AND cgarant IS NULL
               -- bug 0029068 19-12-2013 afegir rehabilitacio
               AND((cgenera       IN(1, 3, 4, 5, 9, 40) --> BUG: 13195 11-03-2010 AVT : Rebuts d'alta i cartera
               AND wctiprec       IN(0, 3)
               AND wcmovseg       IN(0, 1, 2, 4))          -- BUG: 14400 03-05-2010 AVT
               OR(cgenera         IN(1, 3, 4, 5, 7, 9, 40) --> BUG: 13195 11-03-2010 AVT : Suplements
               AND wctiprec       IN (1, 4)                --> Bug 13832 - 01/07/2010 - RSC -  APRS015 - suplemento de aportaciones únicas
               AND wcmovseg        = 1)
               OR(cgenera         IN(1, 3, 4, 5, 7, 9, 40)
               AND wctiprec        = 9 --> BUG: 13195 11-03-2010 AVT : Extorn sense anul·lació
               AND wcmovseg       <> 3)
               OR(wctiprec         = 9 --> BUG: 13195 11-03-2010 AVT : Extorn per anul·lació
               AND wcmovseg        = 3
               AND cgenera         = 6)) -- BUG: 12961 AVT 02-02-2010
               AND NVL(cdetces, 0) = 1;
      --
   BEGIN
      -- Bug 12178 - 09/12/2009 - RSC - CRE201 - error en emisión en pólizas colectivas de salud.
       SELECT    sproduc, ndurcob, fvencim, fefecto
            INTO v_sproduc, w_ndurcob, w_fvencim, w_fefecto
            FROM seguros
           WHERE sseguro = psseguro;

      -- Bug 0014775 - RSC - 10/08/2010 - AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
      IF pmodo = 'EST' THEN
          SELECT    esccero
               INTO v_esccero
               FROM tmp_adm_recibos
              WHERE nrecibo = pnrecibo;
      ELSE
          SELECT    esccero
               INTO v_esccero
               FROM recibos
              WHERE nrecibo = pnrecibo;
      END IF;

      -- Fin Bug 0014775

      -- Fin Bug 12178
      v_errlin := 5060;
      avui     := TRUNC(f_sysdate);
      lprimer  := 1;

      -- w_trovat := 0; -- 12626 AVT 13-01-2010  no es necessari
      -- Mantis 10344.01/06/2009.NMM.Cesiones a reaseguro incorrectas.ini.
      -- Bug 0014775 - RSC - 10/08/2010 - AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
      IF pmodo = 'EST' THEN
         BEGIN
            v_errlin := 5065;

             SELECT    itotalr
                  INTO ltotal
                  FROM tmp_adm_vdetrecibos
                 WHERE nrecibo = pnrecibo;
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            RETURN(103936);
         END;
      ELSE
         -- Fin Bug 0014775
         BEGIN
            v_errlin := 5065;

             SELECT    itotalr
                  INTO ltotal
                  FROM vdetrecibos
                 WHERE nrecibo = pnrecibo;
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            RETURN(103936);
         END;
      END IF;

      IF ltotal = 0 THEN
         -- Acabem aquí
         RETURN(0);
      END IF;

      --END IF;-- Mantis 10344.fi.

      -- Bug 17623 - RSC - 21/02/2010 - Revisió Cesiones MULTIRRIESGO.
      IF pmodo = 'EST' THEN
         BEGIN
             SELECT    fefeadm
                  INTO v_fefeadm
                  FROM tmp_adm_movrecibo
                 WHERE nrecibo = pnrecibo
                  AND fmovfin IS NULL;
         EXCEPTION
         WHEN OTHERS THEN
            v_fefeadm := TRUNC(f_sysdate);
         END;
      ELSE
         BEGIN
             SELECT    fefeadm
                  INTO v_fefeadm
                  FROM movrecibo
                 WHERE nrecibo = pnrecibo
                  AND fmovfin IS NULL;
         EXCEPTION
         WHEN OTHERS THEN
            v_fefeadm := TRUNC(f_sysdate);
         END;
      END IF;

      avui := LEAST(v_fefeadm, TRUNC(f_sysdate));
      -- Fin Bug 17623
      v_errlin := 5070;

      FOR v_det IN c_det(psseguro, pfefecto)
      LOOP
         ---->-- -- dbms_output.put_line('GARANTIA '||v_det.cgarant);
         -- Mirem si la garantia es reassegura
         -- 10805 AVT 20-10-2009 Canviem aquest control dins del cursor de cessions per garantia
         v_errlin := 5075;

         -- 12961 AVT 02-02-2010 Considerar el tipus de rebut
         -- 13195 AVT 10-03-2010 Afegim el tipus de moviment

         -- Bug 14775 - RSC - 10/08/2010 - AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
         IF pmodo = 'EST' THEN
             SELECT    ctiprec, cmovseg
                  INTO lctiprec, lcmovseg
                  FROM tmp_adm_recibos r, movseguro m
                 WHERE nrecibo  = pnrecibo
                  AND r.sseguro = m.sseguro
                  AND r.nmovimi = m.nmovimi;
         ELSE
            -- Fin Bug 14775
             SELECT    ctiprec, cmovseg
                  INTO lctiprec, lcmovseg
                  FROM recibos r, movseguro m
                 WHERE nrecibo  = pnrecibo
                  AND r.sseguro = m.sseguro
                  AND r.nmovimi = m.nmovimi;
         END IF;

         IF pmodo = 'EST' THEN
            FOR v_ces1 IN cur_cesion1_tmp(psseguro, v_det.nriesgo, v_det.cgarant, pfefecto, pnrecibo, lctiprec, lcmovseg)
            LOOP
               IF lprimer     = 1 THEN
                  -- Inicio 23/05/2016 EDA Bug 37066 No debe prorratear los suplementos y si debe mantener la fecha de vigencia de la modificación.
                  IF  NVL(f_parproductos_v(v_sproduc, 'NO_PRORRATEA_REA_SUP'), 0) = 1 THEN
                    v_errlin := 5080;
                    lfactor := 1; -- >> NO PRORRATEA!
                  ELSE
                    v_errlin   := 5085;
                    codi_error := f_difdata(pfefecto, pfvencim, 3, 3, w_dias1);
                    codi_error := f_difdata(v_ces1.fefecto, v_ces1.fvencim, 3, 3, w_dias2);
                    lfactor    := w_dias1 / w_dias2;
                    v_errlin   := 5090;
                  END IF;
                  -- Fin  23/05/2016 EDA

                  lprimer    := 0;
                  v_errlin   := 5095;

                   SELECT    sreaemi_tmp.NEXTVAL
                        INTO lsreaemi
                        FROM DUAL;

                  -- Inserta la capçalera
                  BEGIN
                     v_errlin := 5100;

                      INSERT
                           INTO tmp_adm_reasegemi
                           (
                              sreaemi, sseguro, nrecibo, nfactor, fefecte, fvencim, fgenera, cmotces, sproces
                           )
                           VALUES
                           (
                              lsreaemi, psseguro, pnrecibo, lfactor, pfefecto, pfvencim, avui, pcmotces, psproces
                           );
                  EXCEPTION
                  WHEN OTHERS THEN
                     IF psproces   IS NOT NULL THEN --> JGR
                        codi_error := f_proceslin(psproces, SQLERRM, psseguro, nprolin);
                     END IF;

                     p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' r=' || lsreaemi || ' f=' || lfactor);
                     RETURN(151144);
                  END;
               END IF;

               IF lfactor                                                 IS NOT NULL THEN
                  IF NVL(f_parproductos_v(v_sproduc, 'RECIBOS_COPAGO'), 0) = 1 THEN
                     BEGIN
                         SELECT    pimport
                              INTO v_copago
                              FROM aportaseg
                             WHERE sseguro = psseguro
                              AND norden   = v_ces1.nriesgo;
                     EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' s=' || psseguro || ' r=' || v_ces1.nriesgo);
                        RETURN(140762); --Error al leer de la tabla APORTASEG
                     END;

                     IF v_esccero    = 1 THEN -- Lo que paga la empresa
                        v_errlin    := 5105;
                        licesion    := f_round(v_ces1.icesion * (v_copago / 100) * lfactor, pmoneda);
                        v_errlin    := 5106;
                        lipritarrea := f_round(v_ces1.ipritarrea * (v_copago / 100) * lfactor, pmoneda);
                        v_errlin    := 5107;
                        lidtosel    := f_round(v_ces1.idtosel * (v_copago / 100) * lfactor, pmoneda);
                        v_errlin    := 5108;
                        liextrea    := f_round(v_ces1.iextrea * (v_copago / 100) * lfactor, pmoneda);
                     ELSIF v_esccero = 0 THEN -- Lo que paga el asegurado
                        v_errlin    := 5105;
                        licesion    := f_round(v_ces1.icesion * (1 - (v_copago / 100)) * lfactor, pmoneda);
                        v_errlin    := 5106;
                        lipritarrea := f_round(v_ces1.ipritarrea * (1 - (v_copago / 100)) * lfactor, pmoneda);
                        v_errlin    := 5107;
                        lidtosel    := f_round(v_ces1.idtosel * (1 - (v_copago / 100)) * lfactor, pmoneda);
                        v_errlin    := 5108;
                        liextrea    := f_round(v_ces1.iextrea * (1 - (v_copago / 100)) * lfactor, pmoneda);
                     END IF;
                  ELSE
                     v_errlin    := 5105;
                     licesion    := f_round(v_ces1.icesion * lfactor, pmoneda);
                     v_errlin    := 5106;
                     lipritarrea := f_round(v_ces1.ipritarrea * lfactor, pmoneda);
                     v_errlin    := 5107;
                     lidtosel    := f_round(v_ces1.idtosel * lfactor, pmoneda);
                     v_errlin    := 5108;
                     liextrea    := f_round(v_ces1.iextrea * lfactor, pmoneda);
                  END IF;

                  BEGIN
                     ---->-- -- dbms_output.put_line('insert detall '||v_det.cgarant);
                     v_errlin := 5110;

                      INSERT
                           INTO tmp_adm_detreasegemi
                           (
                              sreaemi, cgarant, icesion, scontra, nversio, ctramo, ipritarrea, idtosel, psobreprima, nriesgo,
                              pcesion, sfacult, icapces, scesrea, iextrap, iextrea,
                              -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                              itarifrea
                           )
                           -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
                           VALUES
                           (
                              lsreaemi, v_det.cgarant, licesion, v_ces1.scontra, v_ces1.nversio, v_ces1.ctramo, lipritarrea, lidtosel, v_ces1.psobreprima,
                              v_ces1.nriesgo, v_ces1.pcesion, v_ces1.sfacult, v_ces1.icapces, v_ces1.scesrea, v_ces1.iextrap, liextrea,
                              -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                              v_ces1.itarifrea
                           );
                     -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
                  EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' r=' || lsreaemi || ' g=' || v_det.cgarant || ' c=' ||
                     v_ces1.scontra || ' v=' || v_ces1.nversio || ' t=' || v_ces1.ctramo);
                     RETURN(151143);
                  END;
               END IF;
            END LOOP;
         ELSE
            FOR v_ces1 IN cur_cesion1
            (
               psseguro, v_det.nriesgo, v_det.cgarant, pfefecto, pnrecibo, lctiprec, lcmovseg
            )
            LOOP
               ---->-- -- dbms_output.put_line(' v_ces1.scesrea '||v_ces1.scesrea);
               -- 10805 AVT 20-10-2009 Canviem aquest control dins del cursor de cessions per garantia
               -- 12626 AVT 13-01-2010 aixo ja s'hauria validat a la generació de CESIONESREA ?....
               IF lprimer = 1 THEN
                  -- M.R.B. 12-03-2008 Càlcul del factor en funciò de primes del rebut i-- cesions de cesisonesrea. S'ha tingut en compte les garanties que no
                  -- juguen al reaseguto en l'apartat de primes.--------------------------------------------------------------------------
                  v_errlin := 5085;
                  -- Bug 0012020 - 17/11/2009 - JMF: Afegir risc.
                  -- 12626 AVT 13-01-2010 deixem d'utilitzar: f_calcula_factor_rebut
                  -- El factor de prorrateig el calculem segons les dates del rebut, rspecte a les
                  -- de les cessions amb efecte del rebut.
                  -- Bug 12178 - RSC - 30/11/2009 - CRE201 - error en emisión en pólizas colectivas de salud.  --IF w_factor_cessio IS NOT NULL THEN
				          -- Inicio 23/05/2016 EDA Bug 37066 No debe prorratear los suplementos y si debe mantener la fecha de vigencia de la modificación.
                  IF  NVL(f_parproductos_v(v_sproduc, 'NO_PRORRATEA_REA_SUP'), 0) = 1 THEN
                    v_errlin := 5086;
                    lfactor := 1; -- >> NO PRORRATEA!
                  ELSE
                    v_errlin := 5088;
                    codi_error := f_difdata(pfefecto, pfvencim, 3, 3, w_dias1);
                    codi_error := f_difdata(v_ces1.fefecto, v_ces1.fvencim, 3, 3, w_dias2);
                    lfactor    := w_dias1 / w_dias2;
                  END IF;
				         -- Fin 23/05/2016 EDA Bug 37066.
                  -- 12626 AVT 13-01-2010 fi
                  -- BUG 8939 - 13/08/2009 - JRB - Se sustituye la búsqueda por nmovigen, usando ahora fefecto <= pfefecto y fvencim > pfefecto
                  v_errlin := 5090;
                  -- 12626 AVT 13-01-2010 no s'utilitza el w_ultim_registre
                  lprimer  := 0;
                  v_errlin := 5095;

                   SELECT    sreaemi.NEXTVAL
                        INTO lsreaemi
                        FROM DUAL;

                  -- Inserta la capçalera
                  BEGIN
                     v_errlin := 5100;

                      INSERT
                           INTO reasegemi
                           (
                              sreaemi, sseguro, nrecibo, nfactor, fefecte, fvencim, fgenera, cmotces, sproces
                           )
                           VALUES
                           (
                              lsreaemi, psseguro, pnrecibo, lfactor, pfefecto, pfvencim, avui, pcmotces, psproces
                           );
                     -- pcmotces 1 - EMISSIÓ, 3- Regularització cúmul
                  EXCEPTION
                  WHEN OTHERS THEN
                     IF psproces   IS NOT NULL THEN --> JGR
                        codi_error := f_proceslin(psproces, SQLERRM, psseguro, nprolin);
                     END IF;

                     p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' r=' || lsreaemi || ' f=' || lfactor);
                     -->-- -- dbms_output.put_line(' 1' ||SQLERRM);
                     RETURN(151144);
                  END;
                  -- Bug 12178 - RSC - 30/11/2009 - CRE201 - error en emisión en pólizas colectivas de salud.
               END IF;

               -- Fin Bug 12178
               -- 12626 AVT 13-01-2010 END IF;

               -- Bug 12178 - RSC - 30/11/2009 - CRE201 - error en emisión en pólizas colectivas de salud.
               -- Bug 12626 AVT 13-01-2010 IF w_factor_cessio IS NOT NULL THEN
               IF lfactor IS NOT NULL THEN
                  -- Fin Bug 12178

                  -- Bug 12178 - 09/12/2009 - RSC - CRE201 - error en emisión en pólizas colectivas de salud.
                  IF NVL(f_parproductos_v(v_sproduc, 'RECIBOS_COPAGO'), 0) = 1 THEN
                     -- Busquem per al risc quin copago tenim. (El nmovimi de aportaseg només guarda el últim nmovimi vigent).
                     -- bug: 12993 10-02-2010 AVT afegim control a la select sobre APORTASEG
                     BEGIN
                         SELECT    pimport
                              INTO v_copago
                              FROM aportaseg
                             WHERE sseguro = psseguro
                              AND norden   = v_ces1.nriesgo;
                     EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' s=' || psseguro || ' r=' || v_ces1.nriesgo);
                        RETURN(140762); --Error al leer de la tabla APORTASEG
                     END;

                     IF v_esccero    = 1 THEN -- Lo que paga la empresa
                        v_errlin    := 5105;
                        licesion    := f_round(v_ces1.icesion * (v_copago / 100) * lfactor, pmoneda);
                        v_errlin    := 5106;
                        lipritarrea := f_round(v_ces1.ipritarrea * (v_copago / 100) * lfactor, pmoneda);
                        v_errlin    := 5107;
                        lidtosel    := f_round(v_ces1.idtosel * (v_copago / 100) * lfactor, pmoneda);
                        v_errlin    := 5108;
                        liextrea    := f_round(v_ces1.iextrea * (v_copago / 100) * lfactor, pmoneda);
                     ELSIF v_esccero = 0 THEN -- Lo que paga el asegurado
                        v_errlin    := 5105;
                        licesion    := f_round(v_ces1.icesion * (1 - (v_copago / 100)) * lfactor, pmoneda);
                        v_errlin    := 5106;
                        lipritarrea := f_round(v_ces1.ipritarrea * (1 - (v_copago / 100)) * lfactor, pmoneda);
                        v_errlin    := 5107;
                        lidtosel    := f_round(v_ces1.idtosel * (1 - (v_copago / 100)) * lfactor, pmoneda);
                        v_errlin    := 5108;
                        liextrea    := f_round(v_ces1.iextrea * (1 - (v_copago / 100)) * lfactor, pmoneda);
                     END IF;
                  ELSE
                     v_errlin    := 5105;
                     licesion    := f_round(v_ces1.icesion * lfactor, pmoneda);
                     v_errlin    := 5106;
                     lipritarrea := f_round(v_ces1.ipritarrea * lfactor, pmoneda);
                     v_errlin    := 5107;
                     lidtosel    := f_round(v_ces1.idtosel * lfactor, pmoneda);
                     v_errlin    := 5108;
                     liextrea    := f_round(v_ces1.iextrea * lfactor, pmoneda);
                  END IF;

                  BEGIN
                     ---->-- -- dbms_output.put_line('insert detall '||v_det.cgarant);
                     v_errlin := 5110;

                      INSERT
                           INTO detreasegemi
                           (
                              sreaemi, cgarant, icesion, scontra, nversio, ctramo, ipritarrea, idtosel, psobreprima, nriesgo,
                              pcesion, sfacult, icapces, scesrea, iextrap, iextrea,
                              -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                              itarifrea
                           )
                           -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
                           VALUES
                           (
                              lsreaemi, v_det.cgarant, licesion, v_ces1.scontra, v_ces1.nversio, v_ces1.ctramo, lipritarrea, lidtosel, v_ces1.psobreprima,
                              v_ces1.nriesgo, v_ces1.pcesion, v_ces1.sfacult, v_ces1.icapces, v_ces1.scesrea, v_ces1.iextrap, liextrea,
                              -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                              v_ces1.itarifrea
                           );
                     -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
                  EXCEPTION
                  WHEN OTHERS THEN
                     -- -- dbms_output.put_line(SQLERRM);
                     -- 12626 AVT 13-01-2010 w_ultim_registre := w_ultim_registre + 1;
                     p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' r=' || lsreaemi || ' g=' || v_det.cgarant || ' c=' ||
                     v_ces1.scontra || ' v=' || v_ces1.nversio || ' t=' || v_ces1.ctramo);
                     RETURN(151143);
                  END;
                  -- Bug 12178 - RSC - 30/11/2009 - CRE201 - error en emisión en pólizas colectivas de salud.
               END IF;
               -- Fin Bug 12178
               --END IF;   -- 10805 AVT 20-10-2009 fi
            END LOOP;
         END IF;

         --IF w_trovat = 0 THEN -- 12626 AVT 13-01-2010  no es necessari
         ---->-- -- dbms_output.put_line(' NO TROBAT ');
         v_errlin := 5115;

         FOR v_ces2 IN cur_cesion2
         (
            psseguro, v_det.nriesgo, pfefecto, lctiprec, lcmovseg
         )
         LOOP
            IF lprimer     = 1 THEN
               IF NVL(f_parproductos_v(v_sproduc, 'NO_PRORRATEA_REA_SUP'), 0) = 1 THEN
                   v_errlin := 5116;
                   lfactor := 1; -- >> NO PRORRATEA!
                ELSE
				   codi_error := f_difdata
				   (
					  pfefecto, pfvencim, 3, 3, w_dias1
				   )
				   ;
				   codi_error := f_difdata(v_ces2.fefecto, v_ces2.fvencim, 3, 3, w_dias2);
				   lfactor    := w_dias1 / w_dias2;
				   v_errlin   := 5120;
               END IF;
               -- Bug 12178 - RSC - 30/11/2009 - CRE201 - error en emisión en pólizas colectivas de salud.
               -- 12626 AVT 13-01-2010 IF w_factor_cessio IS NOT NULL THEN
               IF lfactor IS NOT NULL THEN
                  -- Fin Bug 12178

                  -- BUG 8939 - 13/08/2009 - JRB - Se sustituye la búsqueda por nmovigen, usando ahora fefecto = pfefecto y fvencim = pfvencim
                  v_errlin := 5125;
                  -- 12626 AVT 13-01-2010  w_resta := w_suma_cesionesrea * w_factor_cessio;
                  lprimer  := 0;
                  v_errlin := 5130;

                  -- Bug 14775 - RSC - 10/08/2010 - AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
                  IF pmodo = 'EST' THEN
                      SELECT    sreaemi_tmp.NEXTVAL
                           INTO lsreaemi
                           FROM DUAL;
                  ELSE
                      SELECT    sreaemi.NEXTVAL
                           INTO lsreaemi
                           FROM DUAL;
                  END IF;

                  -- Fin Bug 14775

                  -- Insertar la capçalera
                  BEGIN
                     v_errlin := 5135;

                     -- Bug 14775 - RSC - 10/08/2010 - AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
                     IF pmodo = 'EST' THEN
                         INSERT
                              INTO tmp_adm_reasegemi
                              (
                                 sreaemi, sseguro, nrecibo, nfactor, fefecte, fvencim, fgenera, cmotces, sproces
                              )
                              VALUES
                              (
                                 lsreaemi, psseguro, pnrecibo, lfactor, pfefecto, pfvencim, avui, pcmotces, psproces
                              );
                     ELSE
                         INSERT
                              INTO reasegemi
                              (
                                 sreaemi, sseguro, nrecibo, nfactor, fefecte, fvencim, fgenera, cmotces, sproces
                              )
                              VALUES
                              (
                                 lsreaemi, psseguro, pnrecibo, lfactor, pfefecto, pfvencim, avui, pcmotces, psproces
                              );
                     END IF;
                     -- pcmotces 1 - EMISSIÓ, 3- Regularització cúmul
                  EXCEPTION
                  WHEN OTHERS THEN
                     IF psproces   IS NOT NULL THEN --> JGR
                        codi_error := f_proceslin(psproces, SQLERRM, psseguro, nprolin);
                     END IF;

                     p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' r=' || lsreaemi || ' f=' || lfactor);
                     RETURN(151144);
                  END;
               END IF;
            END IF;

            -- Bug 12178 - RSC - 30/11/2009 - CRE201 - error en emisión en pólizas colectivas de salud.
            -- 12626 AVT 13-01-2010 IF w_factor_cessio IS NOT NULL THEN
            IF lfactor IS NOT NULL THEN
               -- Fin Bug 12178
               v_errlin    := 5140;
               licesion    := f_round(v_ces2.icesion * lfactor, pmoneda);
               v_errlin    := 5141;
               lipritarrea := f_round(v_ces2.ipritarrea * lfactor, pmoneda);
               v_errlin    := 5142;
               lidtosel    := f_round(v_ces2.idtosel * lfactor, pmoneda);
               --
               v_errlin := 5143;

               -- 12626 AVT 13-01-2010 w_ultim_registre := w_ultim_registre - 1;
               BEGIN
                  v_errlin := 5145;

                  -- Bug 14775 - RSC - 10/08/2010 - AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
                  IF pmodo = 'EST' THEN
                      INSERT
                           INTO tmp_adm_detreasegemi
                           (
                              sreaemi, cgarant, icesion, scontra, nversio, ctramo, ipritarrea, idtosel, psobreprima, nriesgo,
                              pcesion, sfacult, icapces, scesrea, iextrap, iextrea,
                              -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                              itarifrea
                           )
                           -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
                           VALUES
                           (
                              lsreaemi, 0, -- BUG 11674: CRE - Error en el cálculos de la cesiones de reaseguro para recibos en productos de ahorro (hasta)
                              licesion, v_ces2.scontra, v_ces2.nversio, v_ces2.ctramo, lipritarrea, lidtosel, v_ces2.psobreprima, v_ces2.nriesgo,
                              v_ces2.pcesion, v_ces2.sfacult, v_ces2.icapces, v_ces2.scesrea, v_ces2.iextrap, liextrea,
                              -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                              v_ces2.itarifrea
                           );
                     -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
                  ELSE
                     -- Fin Bug 14775
                      INSERT
                           INTO detreasegemi
                           (
                              sreaemi, cgarant, icesion, scontra, nversio, ctramo, ipritarrea, idtosel, psobreprima, nriesgo,
                              pcesion, sfacult, icapces, scesrea, iextrap, iextrea,
                              -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                              itarifrea
                           )
                           -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
                           VALUES
                           (
                              lsreaemi, 0, -- BUG 11674: CRE - Error en el cálculos de la cesiones de reaseguro para recibos en productos de ahorro (hasta)
                              licesion, v_ces2.scontra, v_ces2.nversio, v_ces2.ctramo, lipritarrea, lidtosel, v_ces2.psobreprima, v_ces2.nriesgo,
                              v_ces2.pcesion, v_ces2.sfacult, v_ces2.icapces, v_ces2.scesrea, v_ces2.iextrap, liextrea,
                              -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                              v_ces2.itarifrea
                           );
                     -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
                  END IF;
               EXCEPTION
               WHEN OTHERS THEN
                  -->-- -- dbms_output.put_line(SQLERRM);
                  p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' r=' || lsreaemi || ' c=' || v_ces2.scontra || ' v=' ||
                  v_ces2.nversio || ' t=' || v_ces2.ctramo);
                  RETURN(151143);
               END;
               -- Bug 12178 - RSC - 30/11/2009 - CRE201 - error en emisión en pólizas colectivas de salud.
            END IF;
            -- Fin Bug 12178
         END LOOP;
         -- END IF; -- 12626 AVT 13-01-2010  no es necessari
         --END IF; 10805 AVT 20-10-2009
      END LOOP;

      -- 20439 12/01/2012 AVT RENOVACIÓ FINS AL DARRER REBUT DE COBRAMENT ------------
      -- 21559 08/03/2012 AVT JA NO APLICA -->
      --      IF pac_parametros.f_parproducto_t(v_sproduc, 'F_POST_EMISION') IS NOT NULL THEN
      --         IF w_ndurcob IS NOT NULL THEN
      --            BEGIN
      --               SELECT MAX(fefecto), MAX(fvencim)
      --                 INTO w_fconini, w_fconfin
      --                 FROM cesionesrea
      --                WHERE sseguro = psseguro
      --                  AND cgenera = 5;
      --            EXCEPTION
      --               WHEN NO_DATA_FOUND THEN
      --                  NULL;
      --               WHEN OTHERS THEN
      --                  codi_error := 105297;
      --                  RETURN(codi_error);
      --            END;

      --            IF w_fconini = ADD_MONTHS(w_fefecto,(w_ndurcob - 1) * 12)
      --               AND w_fconfin = pfvencim THEN   -- si hi ha detall per rebut ho hem de fer després de generar la cessió per rebut
      --               -- i estem al darrer rebut
      --               BEGIN
      --                  UPDATE cesionesrea
      --                     SET fvencim = w_fvencim
      --                   WHERE sseguro = psseguro
      --                     AND fefecto = w_fconini
      --                     AND cgenera = 5;
      --               EXCEPTION
      --                  WHEN NO_DATA_FOUND THEN
      --                     NULL;
      --                  WHEN OTHERS THEN
      --                     codi_error := 105200;
      --                     RETURN(codi_error);
      --               END;
      --            END IF;
      --         END IF;
      --      END IF;
      -- <--- 21559 08/03/2012 AVT JA NO APLICA --
      -- 20439 12/01/2012 AVT ----------------------------------------------------------
      RETURN 0;
   EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
      RETURN SQLCODE;
      -->-- -- dbms_output.put_line(SQLERRM);
   END f_cessio_det;

-----------------------------------------------------------------------------
-------------------------------------------------------------------------------
   FUNCTION f_cesdet_anu
      (
         pnrecibo IN NUMBER
      )
      RETURN NUMBER
   IS
      -------------------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_CESDET_ANU';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(r=' || pnrecibo || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      lrea reasegemi%ROWTYPE;
      lsreaemi  NUMBER;
      num_err   NUMBER;
      nprolin   NUMBER;
      v_cmotces NUMBER; -- 14536 AVT 21-06-2010
      v_cestrec movrecibo.cestrec%TYPE; --IAXIS-13133 - 12/05/2020
   BEGIN
      BEGIN
         -- Busquem l'emissió per fer l'apunt en negatiu
         v_errlin := 5150;

          SELECT    *
               INTO lrea
               FROM reasegemi
              WHERE nrecibo = pnrecibo
               AND cmotces  = 1 --emissió
               -- BUG 17106 - 27/12/2010 - JMP - Se vuelven a dejar las condiciones tal como estaban anteriormente
               --AND f_cestrec(nrecibo, fefecte) < 2   -- 14871 AVT 16-09-2010
               AND NOT EXISTS
               (SELECT    sreaemi
                     FROM reasegemi
                    WHERE nrecibo = pnrecibo
                     AND cmotces  = 2
               )
               AND sreaemi =
               (SELECT    MAX(sreaemi)
                     FROM reasegemi
                    WHERE nrecibo = pnrecibo
                     AND cmotces  = 1
               );
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0; -- Si no hi ha cessió no fem rès
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         RETURN 151161;
      END;

      -- 14536 AVT 21-06-2010 el CMOTCES dependrà de l'estat del rebut
      -- BUG 17106 - 27/12/2010 - JMP - El CMOTCES se calcula según estado a la fecha del día
    -- INI -IAXIS-13133 - 12/05/2020
    v_cestrec := f_cestrec(pnrecibo, trunc(f_sysdate));
    IF v_cestrec < 2 THEN
      -- FIN -IAXIS-13133 - 12/05/2020
         v_cmotces                            := 4;
      ELSE
         v_cmotces := 2;
      END IF;

      -- 14536 AVT fi
      -- Insertem la nova cessió per l'anul.lació amb els imports en negatiu
      BEGIN
         v_errlin := 5160;

          SELECT    sreaemi.NEXTVAL
               INTO lsreaemi
               FROM DUAL;

         v_errlin := 5165;

         -- Bug 12178 - RSC - 30/11/2009 - CRE201 - error en emisión en pólizas colectivas de salud.
         -- Añadimos nriesgo a reasegemi
          INSERT
               INTO reasegemi
               (
                  sreaemi, sseguro, nrecibo, nfactor, fefecte, fvencim, fgenera, cmotces, sproces
               )
               VALUES
               (
                  lsreaemi, lrea.sseguro, lrea.nrecibo, lrea.nfactor, lrea.fefecte, lrea.fvencim, TRUNC(f_sysdate), v_cmotces, lrea.sproces
               ); -- cmotces =2 - Anul·lació, 4. regularització
         -- Fin Bug 12178
      EXCEPTION
      WHEN OTHERS THEN
         -->-- -- dbms_output.put_line(' 3' ||SQLERRM);
         num_err := f_proceslin(lrea.sproces, SQLERRM, lrea.sseguro, nprolin);
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' r=' || lsreaemi || ' s=' || lrea.sseguro || ' r=' || lrea.nrecibo);
         RETURN 151144;
      END;

      -- Insertem el detall
    -- INI -IAXIS-13133 -12/05/2020
    IF v_cestrec = 3 AND v_cmotces = 2 THEN
      v_errlin := 5170;
    
      INSERT INTO detreasegemi
        (sreaemi,
         cgarant,
         icesion,
         scontra,
         nversio,
         ctramo,
         ipritarrea,
         idtosel,
         psobreprima,
         nriesgo,
         pcesion,
         sfacult,
         icapces,
         scesrea,
         iextrap,
         iextrea,
         itarifrea)
        SELECT lsreaemi,
               d.cgarant,
               c.icesion, -- de cesiones
               d.scontra,
               d.nversio,
               d.ctramo,
               d.ipritarrea,
               d.idtosel,
               d.psobreprima,
               d.nriesgo,
               d.pcesion,
               d.sfacult,
               c.icapces, -- de cesiones
               d.scesrea,
               d.iextrap,
               d.iextrea,
               d.itarifrea
          FROM cesionesrea  c,
               reasegemi    r,
               detreasegemi d
         WHERE c.sseguro = r.sseguro
           AND r.sreaemi = d.sreaemi
           AND c.scontra = d.scontra
           AND c.nversio = d.nversio
           AND c.ctramo = d.ctramo
              --AND c.scesrea = d.scesrea NO se tiene en cuenta esta condición
           AND c.sseguro = lrea.sseguro
           AND r.cmotces = 1 -- anulación
           AND c.cgenera = 6 -- anulación
           AND r.sreaemi = lrea.sreaemi;
    ELSIF v_cmotces = 2 THEN
      -- FIN -IAXIS-13133 -12/05/2020
      BEGIN
         v_errlin := 5170;

          INSERT
               INTO detreasegemi
               (
                  sreaemi, cgarant, icesion, scontra, nversio, ctramo, ipritarrea, idtosel, psobreprima, nriesgo,
                  pcesion, sfacult, icapces, scesrea, iextrap, iextrea,
                  -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                  itarifrea
               )
         -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
          SELECT    lsreaemi, cgarant, - icesion, scontra, nversio, ctramo, - ipritarrea, - idtosel, psobreprima, nriesgo,
               pcesion, sfacult, icapces, scesrea, iextrap, - iextrea,
               -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
               itarifrea
               -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
               FROM detreasegemi
              WHERE sreaemi = lrea.sreaemi;
      EXCEPTION
      WHEN OTHERS THEN
         -->-- -- dbms_output.put_line(SQLERRM);
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' r=' || lrea.sreaemi);
         RETURN 151143;
      END;
    END IF; --IAXIS-13133 - 12/05/2020
    RETURN 0;
  END f_cesdet_anu;

------------------------------------------------------------------------------
   FUNCTION f_cessio_det_per(
         psseguro IN NUMBER,
         pdataini IN DATE,
         pdatafi IN DATE,
         psproces IN NUMBER)
      RETURN NUMBER
   IS
      ------------------------------------------------------------------------------
      -- Genera les cessions a reasegemi i detreasegemi per les pòlisses que es
      -- calcula la seva cessió anualitzada (cesionesrea) en el quadre d'amortització
      -- Aquest detall serà exactament pel periode de cessionesrea i amb els mateixos
      -- imports, és a dir que es copia dels cessionesrea del procés psproces
      ------------------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_CESSIO_DET_PER';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || 's=' || psseguro || ' i=' || pdataini || ' f=' || pdatafi || ' p=' || psproces || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      lsreaemi NUMBER;
      num_err  NUMBER;
      nprolin  NUMBER;
   BEGIN
      BEGIN
         v_errlin := 5180;

          SELECT    sreaemi.NEXTVAL
               INTO lsreaemi
               FROM DUAL;

         v_errlin := 5185;

          INSERT
               INTO reasegemi
               (
                  sreaemi, sseguro, nrecibo, nfactor, fefecte, fvencim, fgenera, cmotces, sproces
               )
               VALUES
               (
                  lsreaemi, psseguro, NULL, 1, pdataini, pdatafi, TRUNC(f_sysdate), 1, psproces
               ); -- 2 - Q. Amort
      EXCEPTION
      WHEN OTHERS THEN
         IF psproces IS NOT NULL THEN --> JGR
            nprolin  := NULL;
            num_err  := f_proceslin(psproces, SQLERRM, psseguro, nprolin);
         END IF;

         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' r=' || lsreaemi);
         RETURN 151144;
      END;

      BEGIN
         v_errlin := 5190;

          INSERT
               INTO detreasegemi
               (
                  sreaemi, cgarant, icesion, scontra, nversio, ctramo, ipritarrea, idtosel, psobreprima, nriesgo,
                  pcesion, sfacult, icapces, scesrea, iextrap, iextrea,
                  -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                  itarifrea
               )
         -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
          SELECT    lsreaemi, cgarant, icesion, scontra, nversio, ctramo, ipritarrea, idtosel, psobreprima, nriesgo,
               pcesion, sfacult, icapces, scesrea, iextrap, iextrea,

               -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
               itarifrea
               -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
               FROM cesionesrea
              WHERE sseguro = psseguro
               AND fefecto  = pdataini
               AND fvencim  = pdatafi;
      EXCEPTION
      WHEN OTHERS THEN
         -->-- -- dbms_output.put_line(SQLERRM);
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' r=' || lsreaemi);
         RETURN 151143;
      END;

      RETURN 0;
   END f_cessio_det_per;

------------------------------------------------------------------------------
   FUNCTION f_cesdet_anu_per(
         psseguro IN NUMBER,
         pdata IN DATE,
         pmotces IN NUMBER)
      RETURN NUMBER
   IS
      ------------------------------------------------------------------------------
      -- Anul·la les cessions de la pòlissa a partir de la data pdata
      -- si està anul.lada ja no
      ------------------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_CESDET_ANU_PER';
      v_errlin NUMBER        := 0;
      -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
      vcmoneda monedas.cmoneda%TYPE;
      -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
      v_errpar VARCHAR2(500) := '(' || 's=' || psseguro || ' d=' || pdata || ' m=' || pmotces || ')';

      -- fin Bug 0012020 - 17/11/2009 - JMF
      CURSOR c_rea(wsseguro NUMBER, wdata DATE)
      IS
          SELECT    *
               FROM reasegemi r
              WHERE r.sseguro = wsseguro
               --AND r.fefecte >= wdata les que quedem al mig també.
               AND r.fvencim > wdata
               -- 15007 AVT 21-06-2010 en cas de dos o més rebuts pel mateix periode (suplements) només regularitzem l'ultim)
               AND r.cmotces  = 1
               AND r.nrecibo IN
               (SELECT    MAX(nrecibo)
                     FROM reasegemi rr
                    WHERE rr.sseguro = r.sseguro
                     AND rr.nfactor  = r.nfactor
                     AND rr.fefecte  = r.fefecte
                     AND rr.fvencim  = r.fvencim
                     AND rr.cmotces  = r.cmotces
               )
            AND NOT EXISTS
            (SELECT    sreaemi
                  FROM reasegemi
                 WHERE sseguro    = r.sseguro
                  AND((r.nrecibo IS NULL
                  AND nrecibo    IS NULL
                  AND fefecte     = r.fefecte
                  AND fvencim     = r.fvencim)
                  OR(r.nrecibo   IS NOT NULL
                  AND r.nrecibo   = nrecibo))
                  AND cmotces    IN(2)
            ); --, 4)); 15007 AVT 21-06-2010 pot haver una regularització anterior

      lsreaemi      NUMBER;
      w_dias        NUMBER;
      w_dias_origen NUMBER;
      w_icesion     NUMBER;                     -- 25803: Ampliar los decimales NUMBER(13, 2);
      w_ipritarrea cesionesrea.ipritarrea%TYPE; -- 25803  Ampliación de decimales  NUMBER(13, 2);
      w_idtosel cesionesrea.idtosel%TYPE;       -- 25803  Ampliación de decimales  NUMBER(13, 2);
      w_finianulces DATE;
      w_ffinanulces DATE;
      num_err       NUMBER;
      nprolin       NUMBER;
   BEGIN
      -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
      BEGIN
          SELECT    pac_monedas.f_moneda_producto(sproduc)
               INTO vcmoneda
               FROM seguros
              WHERE sseguro = psseguro;
      EXCEPTION
      WHEN OTHERS THEN
         vcmoneda := pac_md_common.f_get_parinstalacion_n('MONEDAINST');
      END;

      -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
      v_errlin := 5200;

      ---->-- -- dbms_output.put_line(' Dins f_cesdet_anu_per ');
      FOR vrea IN c_rea(psseguro, pdata)
      LOOP
         ---- -- dbms_output.put_line(' reasegemi '||vrea.sreaemi||' rebut '||vrea.nrecibo);
         IF vrea.fefecte   < pdata THEN
            w_finianulces := pdata;
         ELSE
            w_finianulces := vrea.fefecte;
         END IF;

         BEGIN
            v_errlin := 5210;

             SELECT    sreaemi.NEXTVAL
                  INTO lsreaemi
                  FROM DUAL;

            ---->-- -- dbms_output.put_line('inserta sreaemi '||lsreaemi);
            v_errlin := 5220;

             INSERT
                  INTO reasegemi
                  (
                     sreaemi, sseguro, nrecibo, nfactor, fefecte, fvencim, fgenera, cmotces, sproces
                  )
                  VALUES
                  (
                     lsreaemi, vrea.sseguro, vrea.nrecibo, vrea.nfactor, w_finianulces, vrea.fvencim, TRUNC(f_sysdate), pmotces, vrea.sproces
                  );
            -- pmotces = 2 - Anul·lació, 4 - Anul.per regularització de cúmul
         EXCEPTION
         WHEN OTHERS THEN
            -->-- -- dbms_output.put_line(' 5' ||SQLERRM);
            num_err := f_proceslin(vrea.sproces, SQLERRM, vrea.sseguro, nprolin);
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            RETURN 151144;
         END;

         -- Insertem el detall
         BEGIN
            ---->-- -- dbms_output.put_line(' insert detalls ');
            v_errlin := 5225;
            -- 44.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Inicio
            --num_err := f_difdata(vrea.fefecte, vrea.fvencim, 1, 3, w_dias_origen);
            num_err := f_difdata(vrea.fefecte, vrea.fvencim, 3, 3, w_dias_origen);

            -- 44.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Fin
            IF num_err <> 0 THEN
               p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' err=' || num_err || ' e=' || vrea.fefecte || ' f=' || vrea.fvencim);
               RETURN(num_err);
            END IF;

            v_errlin := 5230;
            -- 44.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Inicio
            --num_err := f_difdata(w_finianulces, vrea.fvencim, 1, 3, w_dias);
            num_err := f_difdata(w_finianulces, vrea.fvencim, 3, 3, w_dias);

            -- 44.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Fin
            IF num_err <> 0 THEN
               p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' err=' || num_err || ' i=' || w_finianulces || ' f=' || vrea.fvencim);
               RETURN(num_err);
            END IF;

            IF w_dias_origen  = 0 THEN
               w_dias_origen := 1;
            END IF;

            IF w_dias  = 0 THEN
               w_dias := 1;
            END IF;

            v_errlin := 5235;

             INSERT
                  INTO detreasegemi
                  (
                     sreaemi, cgarant, icesion, scontra, nversio, ctramo, ipritarrea, idtosel, psobreprima, nriesgo,
                     pcesion, sfacult, icapces, scesrea, iextrap, iextrea,
                     -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                     itarifrea
                  )
            -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
             SELECT    lsreaemi, cgarant, f_round(( - icesion * w_dias) / w_dias_origen, vcmoneda),      -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                  scontra, nversio, ctramo, f_round(( - ipritarrea * w_dias) / w_dias_origen, vcmoneda), -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 -
                  -- Multimoneda
                  f_round(( - idtosel * w_dias) / w_dias_origen, vcmoneda),                                                                    -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                  psobreprima, nriesgo, pcesion, sfacult, icapces, scesrea, iextrap, f_round(( - iextrea * w_dias) / w_dias_origen, vcmoneda), -- BUG 18423 - F
                  -- - 27/12/2011 - JLB - LCOL000 - Multimoneda
                  -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                  itarifrea
                  -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
                  FROM detreasegemi
                 WHERE sreaemi = vrea.sreaemi;
         EXCEPTION
         WHEN OTHERS THEN
            -->-- -- dbms_output.put_line(SQLERRM);
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' r=' || vrea.sreaemi);
            RETURN 151143;
         END;
      END LOOP;

      RETURN 0;
   END f_cesdet_anu_per;

--------------------------------------------------------------
   FUNCTION f_cesdet_anu_cum(
         pscumulo IN NUMBER,
         pdata IN DATE,
         pmotces IN NUMBER,
         pssegurono IN NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
      --------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_CESDET_ANU_CUM';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || 'c=' || pscumulo || ' d=' || pdata || ' m=' || pmotces || ' s=' || pssegurono || ')';

      -- fin Bug 0012020 - 17/11/2009 - JMF
      CURSOR c_cum(wscumulo NUMBER, wssegurono NUMBER)
      IS
          SELECT    *
               FROM reariesgos
              WHERE scumulo   = wscumulo
               AND freafin   IS NULL
               AND(sseguro   <> wssegurono
               OR wssegurono IS NULL)
           ORDER BY sseguro, nriesgo, cgarant; -- 15007 AVT 01-07-2010

      num_err NUMBER;
   BEGIN
      v_errlin := 5240;

      FOR vcum IN c_cum(pscumulo, pssegurono)
      LOOP
         -- anul.lem les cessions de cada pòlissa a partir de la data
         v_errlin   := 5245;
         num_err    := f_cesdet_anu_per(vcum.sseguro, pdata, pmotces);

         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' err=' || num_err || ' s=' || vcum.sseguro);
            RETURN num_err;
         END IF;
      END LOOP;

      RETURN 0;
   END f_cesdet_anu_cum;

---------------------------------------------------------------
   FUNCTION f_cesdet_recalcul(
         pscumulo IN NUMBER,
         pdata IN DATE,
         psproces IN NUMBER,
         pssegurono IN NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
      --------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_CESDET_RECALCUL';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || 'c=' || pscumulo || ' d=' || pdata || ' p=' || psproces || ' s=' || pssegurono || ')';

      -- fin Bug 0012020 - 17/11/2009 - JMF
      CURSOR c_cum(wscumulo NUMBER, wssegurono NUMBER)
      IS
         SELECT DISTINCT r.sseguro, s.sproduc, pac_seguros.ff_get_actividad(r.sseguro, r.nriesgo) cactivi, s.cramo, s.cmodali, s.ctipseg, s.ccolect
               FROM reariesgos r, seguros s
              WHERE r.scumulo = wscumulo
               AND r.freafin IS NULL
               AND r.sseguro  = s.sseguro
               AND(r.sseguro <> pssegurono
               OR pssegurono IS NULL)
           ORDER BY r.sseguro; -- 15007 AVT 01-07-2010

      CURSOR c_reb(wsseguro NUMBER, wdata DATE)
      IS
         SELECT DISTINCT r.nrecibo, r.fefecto, r.fvencim, c.nfactor
               FROM recibos r, movrecibo m, reasegemi c
              WHERE r.sseguro = wsseguro
               AND r.fvencim  > wdata
               AND c.nrecibo  = r.nrecibo
               AND c.cmotces  = 1 -- Emissió
               -- 15007 AVT 21-06-2010 en cas de dos o més rebuts pel mateix periode (suplements) només regularitzem l'ultim)
               AND c.nrecibo IN
               (SELECT    MAX(nrecibo)
                     FROM reasegemi rr
                    WHERE rr.sseguro = r.sseguro
                     AND rr.nfactor  = c.nfactor
                     AND rr.fefecte  = c.fefecte
                     AND rr.fvencim  = r.fvencim
                     AND rr.cmotces  = c.cmotces
               )
            AND r.nrecibo  = m.nrecibo
            AND m.fmovfin IS NULL
            AND m.cestrec <> 2;

      CURSOR c_ces(wsseguro NUMBER, wsproces NUMBER)
      IS
         SELECT DISTINCT fefecto, fvencim
               FROM cesionesrea
              WHERE sseguro = wsseguro
               AND sproces  = wsproces
               AND cgenera  = 1;

      ldetces NUMBER;
      num_err NUMBER;
      lefecto DATE;
      lfac    NUMBER;
   BEGIN
      v_errlin := 5250;

      ---->-- -- dbms_output.put_line(' dins f_cesdet_recalcul ');
      FOR vcum IN c_cum(pscumulo, pssegurono)
      LOOP
         -- Per cada pòlissa, mirem com es generen les seves cessions si
         -- per rebut o per periode al q. amortització
         ldetces  := NULL;
         v_errlin := 5255;
         --num_err := f_parproductos(vcum.sproduc, 'REASEGURO', ldetces); -- BUG: 17672 JGR 23/02/2011
         ldetces := f_cdetces(vcum.sseguro); -- BUG: 17672 JGR 23/02/2011

         --IF num_err = 0 THEN   -- BUG: 17672 JGR 23/02/2011
         IF NVL(ldetces, 0) = 1 THEN -- Emissió
            -- Per cada rebut de la pòlissa
            ---->-- -- dbms_output.put_line('calculats a l'' Emissió ');
            v_errlin := 5260;

            FOR vreb IN c_reb(vcum.sseguro, pdata)
            LOOP
               ---->-- -- dbms_output.put_line(' rebut '||vreb.nrecibo);
               IF vreb.fefecto < pdata THEN
                  lefecto     := pdata;
               ELSE
                  lefecto := vreb.fefecto;
               END IF;

               v_errlin := 5265;
               num_err  := f_cessio_det(psproces, vcum.sseguro, vreb.nrecibo, vcum.cactivi, vcum.cramo, vcum.cmodali, vcum.ctipseg, vcum.ccolect, lefecto,
               vreb.fvencim, NULL,

               -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
               --1,  -- moneda
               pac_monedas.f_moneda_producto(vcum.sproduc),
               -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
               3); --1 moneda

               -- 3 Regularitz. de cúmul
               -- passo factor a null pq es calcula a dins
               -- per aquest cas
               IF num_err <> 0 THEN
                  p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' err=' || num_err || ' s=' || vcum.sseguro || ' r=' || vreb.nrecibo)
                  ;
                  RETURN num_err;
               END IF;
            END LOOP;
         ELSIF NVL(ldetces, 0) = 2 THEN -- Q. amortització
            --
            v_errlin := 5270;

            FOR vces IN c_ces(vcum.sseguro, psproces)
            LOOP
               v_errlin   := 5275;
               num_err    := f_cessio_det_per(vcum.sseguro, vces.fefecto, vces.fvencim, psproces);

               IF num_err <> 0 THEN
                  p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' err=' || num_err || ' s=' || vcum.sseguro || ' e=' || vces.fefecto
                  || ' v=' || vces.fvencim);
                  RETURN num_err;
               END IF;
            END LOOP;
         END IF;
         -- END IF;    -- BUG: 17672 JGR 23/02/2011
      END LOOP;

      RETURN 0;
   END f_cesdet_recalcul;

--------------------------------------------------------------------------------------
   FUNCTION f_capces_ext(
         psseguro IN NUMBER,
         pnrecibo IN NUMBER,
         pnfactor IN NUMBER,
         pfefecte IN DATE,
         pfvencim IN DATE,
         pcmotces IN NUMBER,
         psproces IN NUMBER,
         psreaemi OUT NUMBER)
      RETURN NUMBER
   IS
      --------------------------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_CAPCES_EXT';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || 's=' || psseguro || ' r=' || pnrecibo || ' f=' || pnfactor || ' e=' || pfefecte || ' v=' || pfvencim || ' m=' ||
      pcmotces || ' p=' || psproces || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      l_c     NUMBER;
      num_err NUMBER;
      nprolin NUMBER;
   BEGIN
      -- Primer cal comprovar si es reassegura la pòlissa. La manera més ràpida és mirar
      -- si existeix alguna cessio a data d'efecte
      psreaemi := NULL;

      BEGIN
         v_errlin := 5280;

          SELECT    COUNT( * )
               INTO l_c
               FROM cesionesrea
              WHERE sseguro        = psseguro
               AND fefecto        <= pfefecte
               AND NVL(cdetces, 1) = 1;

         IF l_c                    = 0 THEN
            -- No hi ha cessions
            RETURN 0;
         END IF;
      EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         RETURN 105297;
      END;

      v_errlin := 5285;

       SELECT    sreaemi.NEXTVAL
            INTO psreaemi
            FROM DUAL;

      -- Insertar la capçalera
      BEGIN
         ---->-- -- dbms_output.put_line('insert capçalera');
         v_errlin := 5290;

          INSERT
               INTO reasegemi
               (
                  sreaemi, sseguro, nrecibo, nfactor, fefecte, fvencim, fgenera, cmotces, sproces
               )
               VALUES
               (
                  psreaemi, psseguro, pnrecibo, pnfactor, pfefecte, pfvencim, f_sysdate, pcmotces, psproces
               );
      EXCEPTION
      WHEN OTHERS THEN
         -->-- -- dbms_output.put_line(' 1' ||SQLERRM);
         nprolin := NULL;
         num_err := f_proceslin(psproces, SQLERRM, psseguro, nprolin);
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         RETURN 151144;
      END;

      RETURN 0;
   END f_capces_ext;

--------------------------------------------------------------------------------------
   FUNCTION f_ces_ext
      (
         psreaemi IN NUMBER,
         pnfactor IN NUMBER,
         pnrecibo_in IN NUMBER,
         pcgarant IN NUMBER,
         pnriesgo IN NUMBER,
         pmoneda IN NUMBER
      )
      RETURN NUMBER
   IS
      --------------------------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_CES_EXT';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || 'p=' || psreaemi || ' s=' || pnfactor || ' r=' || pnrecibo_in || ' m=' || pcgarant || 'p=' || pnriesgo || ' s=' ||
      pmoneda || ')';

      -- fin Bug 0012020 - 17/11/2009 - JMF
      CURSOR c_det(wnrecibo NUMBER, wnriesgo NUMBER, wcgarant NUMBER)
      IS
          SELECT    d.*
               FROM reasegemi r, detreasegemi d
              WHERE r.sreaemi = d.sreaemi
               AND r.nrecibo  = wnrecibo
               AND d.nriesgo  = wnriesgo
               AND d.cgarant  = wcgarant;
   BEGIN
      v_errlin := 5300;

      FOR v_det IN c_det(pnrecibo_in, pnriesgo, pcgarant)
      LOOP
         BEGIN
            v_errlin := 5305;

             INSERT
                  INTO detreasegemi
                  (
                     sreaemi, cgarant, icesion, scontra, nversio, ctramo, ipritarrea, idtosel, psobreprima, nriesgo,
                     pcesion, sfacult, icapces, scesrea, iextrap, iextrea,
                     -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                     itarifrea
                  )
                  -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
                  VALUES
                  (
                     psreaemi, pcgarant, - 1 * f_round(v_det.icesion * pnfactor, pmoneda), v_det.scontra, v_det.nversio, v_det.ctramo, - 1 * f_round(
                     v_det.ipritarrea * pnfactor, pmoneda), - 1 * f_round(v_det.idtosel * pnfactor, pmoneda), v_det.psobreprima, pnriesgo, v_det.pcesion,
                     v_det.sfacult, v_det.icapces, v_det.scesrea, v_det.iextrap, - 1 * f_round(v_det.iextrea * pnfactor, pmoneda),
                     -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                     v_det.itarifrea
                  );
            -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            RETURN 151143;
         END;
      END LOOP;

      RETURN 0;
   END f_ces_ext;

-------------------------------------------
   FUNCTION f_borra_cesdet_anu
      (
         pnrecibo IN NUMBER,
         pmodo IN VARCHAR2 DEFAULT NULL
      )
      RETURN NUMBER
   IS
      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_BORRA_CESDET_ANU';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || 'r=' || pnrecibo || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      lsreaemi NUMBER;
   BEGIN
      BEGIN
         v_errlin := 5310;

         -- Bug 0014775 - RSC - 10/08/2010 - AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
         IF pmodo = 'EST' THEN
             SELECT    sreaemi
                  INTO lsreaemi
                  FROM tmp_adm_reasegemi
                 WHERE nrecibo = pnrecibo
                  AND cmotces  = 2;
         ELSE
            -- Fin Bug 0014775
             SELECT    sreaemi
                  INTO lsreaemi
                  FROM reasegemi
                 WHERE nrecibo = pnrecibo
                  AND cmotces  = 2;
         END IF;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         RETURN 999;
      END;

      IF lsreaemi IS NOT NULL THEN
         BEGIN
            v_errlin := 5315;

            -- Bug 14775 - RSC - 10/08/2010 - AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
            IF pmodo = 'EST' THEN
                DELETE
                     FROM tmp_adm_detreasegemi
                    WHERE sreaemi = lsreaemi;
            ELSE
               -- Fin Bug 14775
                DELETE
                     FROM detreasegemi
                    WHERE sreaemi = lsreaemi;
            END IF;

            v_errlin := 5320;

            -- Bug 14775 - RSC - 10/08/2010 - AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
            IF pmodo = 'EST' THEN
                DELETE
                     FROM tmp_adm_reasegemi
                    WHERE sreaemi = lsreaemi;
            ELSE
               -- Fin Bug 14775
                DELETE
                     FROM reasegemi
                    WHERE sreaemi = lsreaemi;
            END IF;
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' r=' || lsreaemi);
            RETURN 999;
         END;
      END IF;

      RETURN 0;
   END f_borra_cesdet_anu;

-------------------------------------------------------
-------------------------------------
   FUNCTION f_recalcula_cumul(
         pssegurono IN NUMBER,
         pfefecmov DATE,
         psproces  NUMBER,
         pcempres  NUMBER)
      RETURN NUMBER
   IS
      -------------------------------------
      -- recalcula les pòlisses d'un cúmul excepte sseguro que és la que provoca el canvi
      -------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_RECALCULA_CUMUL';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || 's=' || pssegurono || ' e=' || pfefecmov || ' p=' || psproces || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      lcumulo   NUMBER;
      num_err   NUMBER := 0;
      ltexto    VARCHAR2(400);
      nprolin   NUMBER;
      v_cempres NUMBER;
      v_idioma  NUMBER;
      -- BUG 18423 - I -  27/12/2011 - JLB - LCOL000 - Multimoneda
      vmoneda monedas.cmoneda%TYPE;
      -- BUG 18423 - F -  27/12/2011 - JLB - LCOL000 - Multimoneda
	   vsproduc   NUMBER;  --BUG/IAXIS-13249 ANULACION POR REGULARIZACION PROCESO NOCTURNO
   BEGIN
      BEGIN
         v_errlin := 5330;

          SELECT    scumulo
               INTO lcumulo
               FROM reariesgos
              WHERE sseguro = pssegurono
               AND freafin IS NULL;

         v_errlin          := 5335;

              SELECT    cempres,
               -- BUG 18423 - I-  27/12/2011 - JLB - LCOL000 - Multimoneda
               pac_monedas.f_moneda_producto(sproduc),sproduc
               -- BUG 18423 - F -  27/12/2011 - JLB - LCOL000 - Multimoneda
               INTO v_cempres, vmoneda ,vsproduc   --BUG/IAXIS-13249 ANULACION POR REGULARIZACION PROCESO NOCTURNO
               FROM seguros
              WHERE sseguro = pssegurono;
              

         -->-- -- dbms_output.put_line(' TROBA CUMUL de A RECALCULAR '||lcumulo);
         IF lcumulo IS NOT NULL THEN
            ---->-- -- dbms_output.put_line(' F_CUMULO ');
            v_errlin := 5340;
            --num_err := f_cumulo(psproces, lcumulo, pfefecmov, 1, 1, pssegurono);
            -- 15007 AVT 01-07-2010 fem la crida sempre com regularitzacio
             IF NVL(f_parproductos_v(vsproduc, 'REGULARIZA'), 0) = 1 THEN
            num_err := f_cumulo(psproces, lcumulo, pfefecmov, 2,
            -- BUG 18423 - I-  27/12/2011 - JLB - LCOL000 - Multimoneda
            --1,
            vmoneda,
            -- BUG 18423 - F- 27/12/2011 - JLB - LCOL000 - Multimoneda
            pssegurono);  --BUG/IAXIS-13249 ANULACION POR REGULARIZACION PROCESO NOCTURNO
            ELSE 
            num_err := 0;
            END IF;


            IF num_err  <> 0 THEN
               nprolin  := NULL;
               v_idioma := pac_parametros.f_parempresa_n(v_cempres, 'IDIOMA_DEF');
               ltexto   := f_axis_literales(num_err, v_idioma);
               p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' err=' || num_err);
               num_err := f_proceslin(psproces, ltexto, pssegurono, nprolin);
               --COMMIT;
               ---->-- -- dbms_output.put_line('Error '||v_pol.sseguro||' num_err = '||num_err);
            END IF;
         END IF;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
      WHEN OTHERS THEN
         num_err := f_proceslin(psproces, 'Error al buscar cumul', pssegurono, nprolin);
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         --COMMIT;
         -->-- -- dbms_output.put_line(' Error al buscar cumul '||pssegurono||' ' ||SQLERRM);
      END;

      RETURN num_err;
   END f_recalcula_cumul;

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
   FUNCTION f_captram_cumul(
         psseguro IN NUMBER,
         pscumulo IN NUMBER,
         pcgarant IN NUMBER,
         pfefecto IN DATE,
         pctramo IN NUMBER,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pcapcum OUT NUMBER,
         piplenotot IN OUT NUMBER,
         picapital  IN NUMBER DEFAULT NULL   --BUG CONF-250  Fecha (02/09/2016) - HRE - se adiciona picapital
         )
      RETURN NUMBER
   IS
      --, picapaci OUT NUMBER) RETURN NUMBER IS
      ------------------------------------------------------------------------------
      -- Obtenim l'import sumat del tram ctramo del cúmul
      -- Les garanties 1 i 8 fan cúmul juntes, cal veure com parametritzar-ho
      -- de moment les posem a pinyó
      ------------------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_CAPTRAM_CUMUL';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || 's=' || psseguro || ' c=' || pscumulo || ' g=' || pcgarant || ' e=' || pfefecto || 't=' || pctramo || ' c=' || pscontra
      || ' v=' || pnversio || ' i=' || piplenotot || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      lcmaxcum NUMBER;
      lcgarrel NUMBER;
      liretenc NUMBER;
      v_ctiprea codicontratos.ctiprea%TYPE; -- 28777 13-11-13
      perr NUMBER;                          -->> 28492 AVT 12/11/2013
      v_cempres seguros.cempres%TYPE;       -->> 28492 AVT 12/11/2013
      v_cramo seguros.cramo%TYPE;           -->> 28492 AVT 12/11/2013
      v_cmodali seguros.cmodali%TYPE;       -->> 28492 AVT 12/11/2013
      v_ctipseg seguros.ctipseg%TYPE;       -->> 28492 AVT 12/11/2013
      v_ccolect seguros.ccolect%TYPE;       -->> 28492 AVT 12/11/2013
      v_cactivi seguros.cactivi%TYPE;       -->> 28492 AVT 12/11/2013
      v_scontra contratos.scontra%TYPE;     -->> 28492 AVT 12/11/2013
      v_nversio contratos.nversio%TYPE;     -->> 28492 AVT 12/11/2013
      v_icapaci contratos.icapaci%TYPE;     -->> 28492 AVT 12/11/2013
      v_cdetces cesionesrea.cdetces%TYPE;   -->> 28492 AVT 12/11/2013
      v_fefecto DATE;                       --29011 AVT 13/11/13
      v_porctramo NUMBER;--BUG CONF-250  Fecha (02/09/2016) - HRE
   BEGIN
      v_errlin := 5001;

      -- 29011 AVT 13/11/13
       SELECT    MAX(freaini)
            INTO v_fefecto
            FROM reariesgos r
           WHERE r.scumulo = pscumulo
            AND(r.freafin  > pfefecto
            OR r.freafin  IS NULL);

      v_errlin            := 5000;

      -- AVT 28777 13-11-13 en cas de XL el ple net de retnció és el total del Capital (hauia de ser el tram?...)
       SELECT    ctiprea
            INTO v_ctiprea
            FROM codicontratos
           WHERE scontra = pscontra;

      v_errlin          := 5005;

      --INI BUG CONF-250  Fecha (02/09/2016) - HRE - Contratos q1,q2,q3
      IF (v_ctiprea =  5) THEN
         v_porctramo := f_porcentaje_tramos_manual (pctramo, pscontra, pnversio);
         pcapcum := picapital * v_porctramo;
         RETURN 0;
      END IF;
      --FIN BUG CONF-250  - Fecha (02/09/2016) - HRE
      SELECT    cempres, cramo, cmodali, ctipseg, ccolect, cactivi
            INTO v_cempres, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi
            FROM seguros seg
           WHERE seg.sseguro = psseguro;

      IF v_ctiprea           = 3 THEN
         --28492 AVT 13/11/2013 LA SELECT NO SERVEIX SI UN CONTRACTE COBREIS DOS O MÉS PRODUCTES.
         perr := f_buscacontrato(psseguro, pfefecto, v_cempres, pcgarant, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi, 11, v_scontra, v_nversio,
         liretenc, v_icapaci, v_cdetces); -- revisar evento!!!

         IF perr <> 0 THEN
            RETURN(perr);
         END IF;
         --         SELECT NVL(a.ilimsub, icapaci), NVL(cgarrel, 0)
         --           INTO liretenc, lcgarrel
         --           FROM contratos c, agr_contratos a
         --          WHERE c.scontra = a.scontra
         --            AND c.scontra = pscontra
         --            AND c.nversio = pnversio;
      ELSE -- 28777 13-11-13 fi --------------
          SELECT    iretenc, NVL(cgarrel, 0)
               INTO liretenc, lcgarrel
               FROM contratos
              WHERE scontra = pscontra
               AND nversio  = pnversio;
      END IF;

      v_errlin := 5355;

      -- 13946 AVT 06-04-2010 s'afegeix el SCONTRA i la NVERSIO.
      -- 14536 AVT 25-05-2010 s'afegeix si les garanties acumulen entre elles (REACUMGAR)
       SELECT    NVL(SUM(c.icapces), 0) --, MAX(ipleno), MAX(icapaci)
            INTO pcapcum                --, pipleno, picapaci
            FROM seguros s, seguros s2, cesionesrea c, reariesgos r
           WHERE c.scumulo = pscumulo
            AND c.ctramo   = pctramo
            AND c.scontra  = pscontra
            AND c.nversio  = pnversio
            AND s.sseguro  = c.sseguro
            AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
            AND c.fvencim  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
            AND(c.fanulac  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
            OR c.fanulac  IS NULL)
            AND(c.fregula  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
            OR c.fregula  IS NULL)
            AND r.scumulo  = c.scumulo
            AND r.sseguro  = c.sseguro
            AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
            AND(r.freafin  > NVL(v_fefecto, pfefecto)  -- Bugs 31509 22-05-14
            OR r.freafin  IS NULL)
            AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
            AND((lcgarrel  = 0
            --AND c.cgarant = pcgarant -- 14536 AVT 25-05-2010
            AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR'), NVL(
            c.cgarant, 0)) = NVL (f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo), pcgarant,
            'REACUMGAR'), NVL(pcgarant, 0)) -- 14536 AVT 25-05-2010  fi
            AND r.sseguro <> psseguro
            AND s2.sseguro = psseguro)
            /*   OR(lcgarrel = 1
            AND((r.sseguro <> psseguro
            AND(c.cgarant = DECODE(pcgarant, 1, 8, 8, 1, pcgarant)
            OR c.cgarant = pcgarant))
            OR(r.sseguro = psseguro
            AND c.cgarant <> pcgarant
            AND pcgarant IN(1, 8)
            AND c.cgarant IN(1, 8))))*/
            );

      v_errlin      := 5360;

      IF lcgarrel    = 1 THEN
         piplenotot := liretenc;
      END IF;

      RETURN 0;
   EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
      RETURN 105297;
   END f_captram_cumul;

--BUG 19484 - 19/10/2011 - JRB - Se añaden las funciones est para el reaseguro.
-- Estas funciones contemplan tanto el trato de las tablas EST como el de las reales
-----------------------------------------------------------------------------------
   FUNCTION f_captram_cumul_est(
         psseguro IN NUMBER,
         pscumulo IN NUMBER,
         pcgarant IN NUMBER,
         pfefecto IN DATE,
         pctramo IN NUMBER,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pcapcum OUT NUMBER,
         piplenotot IN OUT NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER
   IS
      --, picapaci OUT NUMBER) RETURN NUMBER IS
      ------------------------------------------------------------------------------
      -- Obtenim l'import sumat del tram ctramo del cúmul
      -- Les garanties 1 i 8 fan cúmul juntes, cal veure com parametritzar-ho
      -- de moment les posem a pinyó
      ------------------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_CAPTRAM_CUMUL_EST';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || 's=' || psseguro || ' c=' || pscumulo || ' g=' || pcgarant || ' e=' || pfefecto || 't=' || pctramo || ' c=' || pscontra
      || ' v=' || pnversio || ' i=' || piplenotot || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      lcmaxcum NUMBER;
      lcgarrel NUMBER;
      liretenc NUMBER;
      v_ctiprea codicontratos.ctiprea%TYPE; -- 28777 13-11-13
      perr NUMBER;                          -->> 28492 AVT 12/11/2013
      v_cempres seguros.cempres%TYPE;       -->> 28492 AVT 12/11/2013
      v_cramo seguros.cramo%TYPE;           -->> 28492 AVT 12/11/2013
      v_cmodali seguros.cmodali%TYPE;       -->> 28492 AVT 12/11/2013
      v_ctipseg seguros.ctipseg%TYPE;       -->> 28492 AVT 12/11/2013
      v_ccolect seguros.ccolect%TYPE;       -->> 28492 AVT 12/11/2013
      v_cactivi seguros.cactivi%TYPE;       -->> 28492 AVT 12/11/2013
      v_scontra contratos.scontra%TYPE;     -->> 28492 AVT 12/11/2013
      v_nversio contratos.nversio%TYPE;     -->> 28492 AVT 12/11/2013
      v_icapaci contratos.icapaci%TYPE;     -->> 28492 AVT 12/11/2013
      v_cdetces cesionesrea.cdetces%TYPE;   -->> 28492 AVT 12/11/2013
      v_fefecto DATE;                       --29011 AVT 13/11/13
   BEGIN
      v_errlin := 5001;

      -- 29011 AVT 13/11/13
       SELECT    MAX(freaini)
            INTO v_fefecto
            FROM reariesgos r
           WHERE r.scumulo = pscumulo
            AND(r.freafin  > pfefecto
            OR r.freafin  IS NULL);

      v_errlin            := 5000;

      -- AVT 28777 13-11-13 en cas de XL el ple net de retnció és el total del Capital (hauia de ser el tram?...)
       SELECT    ctiprea
            INTO v_ctiprea
            FROM codicontratos
           WHERE scontra = pscontra;

      v_errlin          := 5005;

      IF v_ctiprea       = 3 THEN
         --28492 AVT 13/11/2013 LA SELECT NO SERVEIX SI UN CONTRACTE COBREIS DOS O MÉS PRODUCTES.
         IF ptablas = 'EST' THEN
             SELECT    cempres, cramo, cmodali, ctipseg, ccolect, cactivi
                  INTO v_cempres, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi
                  FROM estseguros seg
                 WHERE seg.sseguro = psseguro;
         ELSE
             SELECT    cempres, cramo, cmodali, ctipseg, ccolect, cactivi
                  INTO v_cempres, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi
                  FROM seguros seg
                 WHERE seg.sseguro = psseguro;
         END IF;

         perr := f_buscacontrato(psseguro, pfefecto, v_cempres, pcgarant, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi, 11, v_scontra, v_nversio,
         liretenc, v_icapaci, v_cdetces); -- revisar evento!!!

         IF perr <> 0 THEN
            RETURN(perr);
         END IF;
         --         SELECT NVL(a.ilimsub, icapaci), NVL(cgarrel, 0)
         --           INTO liretenc, lcgarrel
         --           FROM contratos c, agr_contratos a
         --          WHERE c.scontra = a.scontra
         --            AND c.scontra = pscontra
         --            AND c.nversio = pnversio;
      ELSE -- 28777 13-11-13 fi --------------
          SELECT    iretenc, NVL(cgarrel, 0)
               INTO liretenc, lcgarrel
               FROM contratos
              WHERE scontra = pscontra
               AND nversio  = pnversio;
      END IF;

      v_errlin  := 5355;

      IF ptablas = 'EST' THEN
          SELECT    NVL(SUM(c.icapces), 0)
               INTO pcapcum
               FROM seguros s, estseguros s2, cesionesrea c, reariesgos r
              WHERE c.scumulo = pscumulo
               AND c.ctramo   = pctramo
               AND c.scontra  = pscontra
               AND c.nversio  = pnversio
               AND s.sseguro  = c.sseguro
               AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
               AND c.fvencim  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               AND(c.fanulac  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               OR c.fanulac  IS NULL)
               AND(c.fregula  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               OR c.fregula  IS NULL)
               AND r.scumulo  = c.scumulo
               AND r.sseguro  = c.sseguro
               AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
               AND(r.freafin  > NVL(v_fefecto, pfefecto)  -- Bugs 31509 22-05-14
               OR r.freafin  IS NULL)
               AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
               AND((lcgarrel  = 0
               AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR'),
               NVL(c.cgarant, 0)) = NVL(f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
               pcgarant, 'REACUMGAR'), NVL(pcgarant, 0))
               AND r.sseguro <> psseguro
               AND s2.sseguro = psseguro));
      ELSIF ptablas           = 'CAR' THEN
          SELECT    NVL(SUM(c.icapces), 0) --, MAX(ipleno), MAX(icapaci)
               INTO pcapcum                --, pipleno, picapaci
               FROM seguros s, seguros s2, cesionesrea c, reariesgos r
              WHERE c.scumulo = pscumulo
               AND c.ctramo   = pctramo
               AND c.scontra  = pscontra
               AND c.nversio  = pnversio
               AND s.sseguro  = c.sseguro
               AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
               AND c.fvencim  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               AND(c.fanulac  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               OR c.fanulac  IS NULL)
               AND(c.fregula  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               OR c.fregula  IS NULL)
               AND r.scumulo  = c.scumulo
               AND r.sseguro  = c.sseguro
               AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
               AND(r.freafin  > NVL(v_fefecto, pfefecto)  -- Bugs 31509 22-05-14
               OR r.freafin  IS NULL)
               AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
               AND((lcgarrel  = 0
               --AND c.cgarant = pcgarant -- 14536 AVT 25-05-2010
               AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR'),
               NVL(c.cgarant, 0)) = NVL (f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
               pcgarant, 'REACUMGAR'), NVL(pcgarant, 0)) -- 14536 AVT 25-05-2010  fi
               AND r.sseguro <> psseguro
               AND s2.sseguro = psseguro)
               /*   OR(lcgarrel = 1
               AND((r.sseguro <> psseguro
               AND(c.cgarant = DECODE(pcgarant, 1, 8, 8, 1, pcgarant)
               OR c.cgarant = pcgarant))
               OR(r.sseguro = psseguro
               AND c.cgarant <> pcgarant
               AND pcgarant IN(1, 8)
               AND c.cgarant IN(1, 8))))*/
               );
      ELSE
          SELECT    NVL(SUM(c.icapces), 0) --, MAX(ipleno), MAX(icapaci)
               INTO pcapcum                --, pipleno, picapaci
               FROM seguros s, seguros s2, cesionesrea c, reariesgos r
              WHERE c.scumulo = pscumulo
               AND c.ctramo   = pctramo
               AND c.scontra  = pscontra
               AND c.nversio  = pnversio
               AND s.sseguro  = c.sseguro
               AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
               AND c.fvencim  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               AND(c.fanulac  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               OR c.fanulac  IS NULL)
               AND(c.fregula  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               OR c.fregula  IS NULL)
               AND r.scumulo  = c.scumulo
               AND r.sseguro  = c.sseguro
               AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
               AND(r.freafin  > NVL(v_fefecto, pfefecto)  -- Bugs 31509 22-05-14
               OR r.freafin  IS NULL)
               AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
               AND((lcgarrel  = 0
               --AND c.cgarant = pcgarant -- 14536 AVT 25-05-2010
               AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR'),
               NVL(c.cgarant, 0)) = NVL (f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
               pcgarant, 'REACUMGAR'), NVL(pcgarant, 0)) -- 14536 AVT 25-05-2010  fi
               AND r.sseguro <> psseguro
               AND s2.sseguro = psseguro)
               /*   OR(lcgarrel = 1
               AND((r.sseguro <> psseguro
               AND(c.cgarant = DECODE(pcgarant, 1, 8, 8, 1, pcgarant)
               OR c.cgarant = pcgarant))
               OR(r.sseguro = psseguro
               AND c.cgarant <> pcgarant
               AND pcgarant IN(1, 8)
               AND c.cgarant IN(1, 8))))*/
               );
      END IF;

      v_errlin      := 5360;

      IF lcgarrel    = 1 THEN
         piplenotot := liretenc;
      END IF;

      RETURN 0;
   EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
      RETURN 105297;
   END f_captram_cumul_est;

----------------------------------

------------------------------------------------------------------------------------
/*
FUNCTION f_recalcula_cumul(pssegurono IN NUMBER,pnriesgo IN NUMBER,
pfefecmov DATE, psproces NUMBER) RETURN NUMBER IS
-------------------------------------
-- recalcula les pòlisses d'un cúmul excepte sseguro que és la que provoca el canvi
-------------------------------------
lcumulo NUMBER;
num_err NUMBER := 0;
ltexto VARCHAR2(100);
nprolin NUMBER;
BEGIN
-->-- -- dbms_output.put_line(' BUSCA CUMUL de A RECALCULAR psseguro = '||pssegurono||' risc '||
pnriesgo||'data  '||pfefecmov);
BEGIN
SELECT scumulo
INTO lcumulo
FROM reariesgos
WHERE sseguro = pssegurono
AND nriesgo = pnriesgo
AND freafin IS NULL;
-->-- -- dbms_output.put_line(' TROBA CUMUL de A RECALCULAR '||lcumulo);
IF lcumulo IS NOT NULL THEN
---->-- -- dbms_output.put_line(' F_CUMULO ');
num_err := f_cumulo(psproces, lcumulo, pfefecmov, 1, 1, pssegurono);
IF num_Err <> 0 THEN
P_Literal2(num_err, 1, ltexto);
num_err := F_Proceslin(psproces, ltexto, pssegurono, nprolin);
--COMMIT;
---->-- -- dbms_output.put_line('Error '||v_pol.sseguro||' num_err = '||num_err);
END IF;
END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
NULL;
WHEN OTHERS THEN
num_err := F_Proceslin(psproces, 'Error al buscar cumul', pssegurono, nprolin);
--COMMIT;
--> dbms_output.put_line(' Error al buscar cumul '||pssegurono||' ' ||SQLERRM);
END;
RETURN num_Err;
END f_recalcula_cumul;
*/

-----------------------------------------------------------------------------------
-- Calcula el factor a aplicar a les cessions, però comparant'ho amb les primes
-- dels rebuts, en lloc de fer-ho per dates. M.RB. Financera 12-03-2008
-----------------------------------------------------------------------------------
   FUNCTION f_calcula_factor_rebut(
         psseguro IN NUMBER,
         pnrecibo IN NUMBER,
         pfefecto IN DATE,
         pcramo IN NUMBER,
         pcmodali IN NUMBER,
         pctipseg IN NUMBER,
         pccolect IN NUMBER,
         pcactivi IN NUMBER,
         pmoneda IN NUMBER,
         pnriesgo IN NUMBER,
         p_suma_cesionesrea OUT NUMBER,
         p_suma_iprimanu OUT NUMBER,
         p_factor_cessio OUT NUMBER)
      RETURN NUMBER
   IS
      --
      -- Bug 0012020 - 17/11/2009 - JMF Afegir risc com paràmetre.
      w_prima_gar garanseg.iprianu%TYPE := 0; -- 25803: Ampliar los decimales NUMBER(10, 2) := 0;
      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_CALCULA_FACTOR_REBUT';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || 's=' || psseguro || ' r=' || pnrecibo || ' e=' || pfefecto || ' r=' || pcramo || 'm=' || pcmodali || ' t=' || pctipseg
      || ' c=' || pccolect || ' a=' || pcactivi || 'm=' || pmoneda || ' r=' || pnriesgo || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      w_suma_iprimanu garanseg.iprianu%TYPE          := 0; -- 25803: Ampliar los decimales NUMBER(10, 2) := 0;
      w_suma_gar_rea_de_rebuts garanseg.iprianu%TYPE := 0; -- 25803: Ampliar los decimales NUMBER(10, 2) := 0;
      w_codi_error       NUMBER                            := 0;
      w_lcreaseg         NUMBER                            := 0;
      w_factor_cessio    NUMBER                            := 1;
      w_suma_cesionesrea NUMBER                            := 0; -- 25803: Ampliar los decimales NUMBER(10, 2) := 0;
      hiha               NUMBER;
      -- Bug 12178 - 09/12/2009 - RSC - CRE201 - error en emisión en pólizas colectivas de salud.
      v_sproduc NUMBER;
      v_esccero NUMBER;

      -- Fin Bug 12178

      -- 10805 AVT 20-10-2009 s'afegeix el cursor per controlar només els imports de les garanties reassegurables.
      CURSOR c_detrecibos
      IS
          SELECT    cgarant, cconcep, iconcep
               FROM detrecibos
              WHERE nrecibo = pnrecibo
               AND nriesgo  = pnriesgo -- Bug 0012020 - 17/11/2009 - JMF Afegir risc
               AND cconcep IN(0, 21);  -- (0) prima neta rebut i (21) prima devengada
   BEGIN
      v_errlin := 5365;
      hiha     := 0;

      -- Bug 12178 - 09/12/2009 - RSC - CRE201 - error en emisión en pólizas colectivas de salud.
       SELECT    sproduc
            INTO v_sproduc
            FROM seguros
           WHERE sseguro = psseguro;

       SELECT    esccero
            INTO v_esccero
            FROM recibos
           WHERE nrecibo = pnrecibo;

      -- Fin Bug 12178
      FOR reg IN c_detrecibos
      LOOP
         --
         v_errlin     := 5370;
         w_codi_error := pac_cesionesrea.f_gar_rea(pcramo, pcmodali, pctipseg, pccolect, pcactivi, reg.cgarant, w_lcreaseg);

         --
         IF w_codi_error                 = 0 AND w_lcreaseg IN(1, 2) THEN
            IF reg.cconcep               = 0 THEN
               w_suma_gar_rea_de_rebuts := w_suma_gar_rea_de_rebuts + NVL(reg.iconcep, 0);
            ELSIF reg.cconcep            = 21 THEN
               -- 10805 AVT 20-10-2009  pels suplements s'ha d'agafar només la part que creix (Prima devengada 21)
               w_suma_iprimanu := w_suma_iprimanu + NVL(reg.iconcep, 0);
            END IF;

            -- ini Bug 0012020 - 17/11/2009 - JMF
             SELECT    COUNT( * )
                  INTO hiha
                  FROM detrecibos
                 WHERE nrecibo = pnrecibo
                  AND nriesgo  = pnriesgo
                  AND cgarant  = reg.cgarant
                  AND cconcep  = 21;

            IF hiha            = 0 THEN
               w_prima_gar    := 0;

               BEGIN
                  v_errlin := 5375;

                  -- Bug 12178 - 09/12/2009 - RSC - CRE201 - error en emisión en pólizas colectivas de salud.
                  IF NVL(f_parproductos_v(v_sproduc, 'RECIBOS_COPAGO'), 0) = 1 THEN
                     IF v_esccero                                          = 1 THEN -- Lo que paga la empresa
                         SELECT    g.iprianu * (a.pimport / 100)
                              INTO w_prima_gar
                              FROM garanseg g, aportaseg a
                             WHERE g.sseguro = psseguro
                              AND g.cgarant  = reg.cgarant
                              AND g.nriesgo  = pnriesgo
                              AND g.ffinefe IS NULL
                              AND g.sseguro  = a.sseguro
                              AND g.nriesgo  = a.norden;
                     ELSIF v_esccero         = 0 THEN -- Lo que paga el asegurado
                         SELECT    g.iprianu * (1 - (a.pimport / 100))
                              INTO w_prima_gar
                              FROM garanseg g, aportaseg a
                             WHERE g.sseguro = psseguro
                              AND g.cgarant  = reg.cgarant
                              AND g.nriesgo  = pnriesgo
                              AND g.ffinefe IS NULL
                              AND g.sseguro  = a.sseguro
                              AND g.nriesgo  = a.norden;
                     END IF;
                  ELSE
                     -- Fin Bug 12178
                      SELECT    iprianu
                           INTO w_prima_gar
                           FROM garanseg
                          WHERE sseguro = psseguro
                           AND cgarant  = reg.cgarant
                           AND nriesgo  = pnriesgo
                           AND ffinefe IS NULL;
                     -- Bug 12178 - 09/12/2009 - RSC - CRE201 - error en emisión en pólizas colectivas de salud.
                  END IF;
                  -- Fin Bug 12178
               EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' g=' || reg.cgarant);
                  RETURN 9001092;
               END;

               w_suma_iprimanu := w_suma_iprimanu + w_prima_gar;
            END IF;
            -- fin Bug 0012020 - 17/11/2009 - JMF
         END IF;
      END LOOP;

      -- ini Bug 0012020 - 17/11/2009 - JMF: control division
      /*
      IF w_suma_iprimanu = 0 THEN   -- 10805 AVT 20-10-2009 els rebuts de Cartera no tenen prima devengada
      SELECT iprianu
      INTO w_suma_iprimanu
      FROM seguros
      WHERE sseguro = psseguro;
      END IF;
      */
      -- fin Bug 0012020 - 17/11/2009 - JMF: control division

      --10805 AVT 20-10-2009 per números molt petits donava zero
      --W_FACTOR_CESSIO := f_round(W_SUMA_GAR_REA_DE_REBUTS / W_SUMA_IPRIMANU, PMONEDA);
      v_errlin := 5380;

      -- ini Bug 0012020 - 17/11/2009 - JMF: control division
      IF w_suma_iprimanu = 0 THEN
         RETURN 9001107;
         -- fin Bug 0012020 - 17/11/2009 - JMF: control division
      ELSE
         v_errlin        := 5380;
         w_factor_cessio := w_suma_gar_rea_de_rebuts / w_suma_iprimanu;
      END IF;

      -- BUG 8939 - 13/08/2009 - JRB - Se sustituye la búsqueda por nmovigen, usando ahora fefecto <= pfefecto y fvencim > pfefecto
      v_errlin := 5385;

      -- Bug 12178 - 09/12/2009 - RSC - CRE201 - error en emisión en pólizas colectivas de salud.
      IF NVL(f_parproductos_v(v_sproduc, 'RECIBOS_COPAGO'), 0) = 1 THEN
         IF v_esccero                                          = 1 THEN
             SELECT    SUM(NVL(c.icesion * (a.pimport / 100), 0))
                  INTO w_suma_cesionesrea
                  FROM cesionesrea c, aportaseg a
                 WHERE c.sseguro = psseguro
                  AND(c.fanulac  > pfefecto
                  OR c.fanulac  IS NULL)
                  AND(c.fregula  > pfefecto
                  OR c.fregula  IS NULL)
                  AND c.fefecto <= pfefecto
                  AND c.fvencim  > pfefecto
                  AND c.sseguro  = a.sseguro
                  AND c.nriesgo  = a.norden;
         ELSIF v_esccero         = 0 THEN
             SELECT    SUM(NVL(c.icesion * (1 - (a.pimport / 100)), 0))
                  INTO w_suma_cesionesrea
                  FROM cesionesrea c, aportaseg a
                 WHERE c.sseguro = psseguro
                  AND(c.fanulac  > pfefecto
                  OR c.fanulac  IS NULL)
                  AND(c.fregula  > pfefecto
                  OR c.fregula  IS NULL)
                  AND c.fefecto <= pfefecto
                  AND c.fvencim  > pfefecto
                  AND c.sseguro  = a.sseguro
                  AND c.nriesgo  = a.norden;
         END IF;
      ELSE
         -- Fin Bug 12178
          SELECT    SUM(NVL(icesion, 0))
               INTO w_suma_cesionesrea
               FROM cesionesrea
              WHERE sseguro = psseguro
               -- 10805 AVT 20-10-2009 s'han de considerar només les cessions amb efecte
               AND(fanulac > pfefecto
               OR fanulac IS NULL)
               AND(fregula > pfefecto
               OR fregula IS NULL)
               -- 10805 AVT 20-10-2009 fi
               AND fefecto <= pfefecto
               AND fvencim  > pfefecto;
         -- Bug 12178 - 09/12/2009 - RSC - CRE201 - error en emisión en pólizas colectivas de salud.
      END IF;

      -- Fin Bug 12178
      v_errlin           := 5385;
      p_suma_iprimanu    := w_suma_iprimanu;
      p_factor_cessio    := w_factor_cessio;
      p_suma_cesionesrea := w_suma_cesionesrea;
      --
      RETURN w_codi_error;
      --
   END f_calcula_factor_rebut;

-------------------------------------------
   PROCEDURE p_cesiones_ahorro(
         psproces IN NUMBER,
         pmes IN NUMBER,
         panyo IN NUMBER,
         psseguro IN NUMBER DEFAULT NULL)
   IS
      /******************************************************************************
      NAME:        f_cesiones_ahorro
      Descripción: Procedimiento para calcular las cesiones mensuales en las pólizas
      que de ahorro
      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        05/05/2009  AVT              1. Created this procedure.
      2.0        01/07/2009  NMM              2. 10344: CRE - Cesiones a reaseguro incorrectas.
      - S'afegeix condició al cursor.
      3.0        31/07/2009  AVT              3.10693: CRE - Incidencia cálculo prima reaseguro de ahorro
      ******************************************************************************/

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.P_CESIONES_AHORRO';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || 'p=' || psproces || ' m=' || pmes || ' a=' || panyo || ' s=' || psseguro || ')';

      -- fin Bug 0012020 - 17/11/2009 - JMF
      CURSOR c_seg_ahorro
      IS
          SELECT    s.sseguro, s.sproduc, s.ctiprea, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, TO_DATE(panyo
               || LPAD(pmes, 2, '0')
               || '01', 'yyyymmdd') fefecmov, -- 10693 31/07/2009 AVT efecte de inici per 01 del mes
               MAX(nmovimi) nmovimi, s.cempres
               FROM seguros s, garanseg m, garanpro g, ctaseguro c -- 10693 31/07/2009 AVT modificada per que estigui a CTASEGURO
              WHERE m.sseguro                                      = s.sseguro
               AND s.sproduc                                       = g.sproduc
               AND m.cgarant                                       = g.cgarant
               AND g.creaseg                                       > 0
               AND(TRUNC(nrenova / 100)                           <= pmes
               OR pmes                                            IS NULL)
               AND((csituac                                        = 5)
               OR(creteni                                          = 0
               AND csituac NOT                                    IN(7, 8, 9, 10)))
               AND f_parproductos_v(s.sproduc, 'REASEGURO_AHORRO') = 1
               AND s.femisio                                      IS NOT NULL
               AND(s.sseguro                                       = psseguro
               OR psseguro                                        IS NULL)
               AND s.fefecto                                       < LAST_DAY(TO_DATE(panyo
               || LPAD(pmes, 2, '0')
               || '01', 'yyyymmdd')) + 1
               AND s.sseguro = c.sseguro
               AND c.cmovimi = 0
               AND c.fvalmov = LAST_DAY(TO_DATE(panyo
               || LPAD(pmes, 2, '0')
               || '01', 'yyyymmdd'))
           GROUP BY s.sseguro, s.sproduc, s.ctiprea, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, TO_DATE(panyo
               || LPAD(pmes, 2, '0')
               || '01', 'yyyymmdd'), s.cempres
           ORDER BY s.sseguro, nmovimi;

      lfini    DATE;
      lffi     DATE;
      num_err  NUMBER;
      lorigen  NUMBER;
      ldetces  NUMBER;
      ltexto   VARCHAR2(1000);
      lmotiu   NUMBER;
      nprolin  NUMBER;
      hiha     NUMBER;
      v_idioma NUMBER;
   BEGIN
      v_errlin := 5400;

      FOR v_pol IN c_seg_ahorro
      LOOP
         -- Mirem si hi ha cessions
         hiha     := 0;
         v_errlin := 5405;

          SELECT    COUNT( * )
               INTO hiha
               FROM cesionesrea c
              WHERE cgenera  = 5
               AND c.sseguro = v_pol.sseguro
               AND c.nmovimi = v_pol.nmovimi
               AND c.cgenera = 5
               AND c.fefecto = v_pol.fefecmov;

         IF hiha             = 0 THEN
            -- Cal obtenir les dates d'inici i final de cessió
            lfini    := v_pol.fefecmov;
            lffi     := ADD_MONTHS(lfini, 1); -- Calculem cessions mensuals
            lmotiu   := 5;                    -- Renovación
            lorigen  := 1;
            ldetces  := NULL;
            v_errlin := 5410;
            num_err  := f_buscactrrea(v_pol.sseguro, v_pol.nmovimi, psproces, lmotiu,

            -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
            --1,  -- moneda
            pac_monedas.f_moneda_producto(v_pol.sproduc),
            -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
            lorigen, lfini, lffi);

            --DBMS_OUTPUT.put_line('2.- num_err - f_buscactrrea:' || num_err);
            IF num_err  <> 0 AND num_err <> 99 THEN
               v_idioma := pac_parametros.f_parempresa_n(v_pol.cempres, 'IDIOMA_DEF');
               ltexto   := f_axis_literales(num_err, v_idioma);
               p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' err=' || num_err);
               num_err   := f_proceslin(psproces, ltexto, v_pol.sseguro, nprolin);
            ELSIF num_err = 99 THEN
               -- no troba contracte ???
               num_err := 0;
            ELSE
               v_errlin := 5415;
               num_err  := f_cessio(psproces, lmotiu, 1, lfini);

               --DBMS_OUTPUT.put_line('3.- num_err - f_cessio:' || num_err);
               IF num_err  <> 0 AND num_err <> 99 THEN
                  v_idioma := pac_parametros.f_parempresa_n(v_pol.cempres, 'IDIOMA_DEF');
                  ltexto   := f_axis_literales(num_err, v_idioma);
                  p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' err=' || num_err);
                  num_err   := f_proceslin(psproces, ltexto, v_pol.sseguro, nprolin);
               ELSIF num_err = 99 THEN
                  num_err   := 105382; --No te facultatiu
                  v_idioma  := pac_parametros.f_parempresa_n(v_pol.cempres, 'IDIOMA_DEF');
                  ltexto    := f_axis_literales(num_err, v_idioma);
                  num_err   := f_proceslin(psproces, ltexto, v_pol.sseguro, nprolin);
               END IF;
            END IF;
         END IF;
      END LOOP;
   END p_cesiones_ahorro;

-----------------------------------------------------------------------------
-- Mantis 10344.01/06/2009.NMM.CRE- Cessions a reasegurança incorrectes.i.
-----------------------------------------------------------------------------
   FUNCTION f_del_reasegemi(
         p_sseguro IN seguros.sseguro%TYPE,
         p_nmovimi IN movseguro.nmovimi%TYPE)
      RETURN NUMBER
   IS
      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_DEL_REASEGEMI';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || ' s=' || p_sseguro || ' m=' || p_nmovimi || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      w_sproces NUMBER := NULL;
      w_nrecibo NUMBER;
      w_nfactor NUMBER := NULL;
      w_pmoneda NUMBER;
      w_cmotces NUMBER := 2; -- Anul·lació.
      w_itotalr NUMBER;
      w_err     NUMBER;
      w_pas PLS_INTEGER;
      w_fefecto recibos.fefecto%TYPE;
      w_fvencim recibos.fvencim%TYPE;

      CURSOR c_seguros(c_sseguro IN seguros.sseguro%TYPE)
      IS
          SELECT    cactivi, cramo, cmodali, ctipseg, ccolect, sproduc --, fefecto, fvencim
               FROM seguros
              WHERE sseguro = c_sseguro;

      CURSOR c_rebuts(c_sseguro IN seguros.sseguro%TYPE, c_nmovimi IN movseguro.nmovimi%TYPE)
      IS
          SELECT    nrecibo
               FROM recibos
              WHERE sseguro = c_sseguro
               AND nmovimi  = c_nmovimi;

      r_seguros c_seguros%ROWTYPE;
      --
   BEGIN
      v_errlin := 5420;

      -- 0013338 04-03-2010 cessió d'extorns amb copagament (més d'un rebut)
      FOR reg IN c_rebuts(p_sseguro, p_nmovimi)
      LOOP
         w_nrecibo := reg.nrecibo;

         BEGIN
            -- Si hi ha algún error saltarà la excepció.
            v_errlin := 5425;

            -- 0013338 04-03-2010 cessió d'extorns amb copagament (més d'un rebut)
            --      SELECT MAX(nrecibo)
            --        INTO w_nrecibo
            --        FROM recibos
            --       WHERE sseguro = p_sseguro
            --         AND nmovimi = p_nmovimi;

            -- BUG: 12223 AVT 04-02-2010 control de si no hi ha rebut abans de seguir
            IF NVL(w_nrecibo, 0) = 0 THEN
               RETURN(0);
            END IF;

            -- BUG: 12223 AVT 04-02-2010 fi
            v_errlin := 5430;

             SELECT    itotalr
                  INTO w_itotalr
                  FROM vdetrecibos
                 WHERE nrecibo = w_nrecibo;
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' r=' || w_nrecibo);
            -- Retornarem un zero pq encara que hi hagués error el procés general continuï.
            RETURN(0);
         END;

         --------------------------------------------------------------------------

         -- Sempre s'esborrarà de les taules reasegemi i detreasegemi.
         v_errlin := 5435;

          DELETE
               FROM detreasegemi
              WHERE sreaemi IN
               (SELECT    sreaemi
                     FROM reasegemi
                    WHERE nrecibo = w_nrecibo
               );

         v_errlin := 5440;

          DELETE
               FROM reasegemi
              WHERE nrecibo = w_nrecibo;

         --
         IF w_itotalr <> 0 THEN
            v_errlin  := 5445;

            OPEN c_seguros(p_sseguro);

            v_errlin := 5450;

            FETCH c_seguros
                  INTO r_seguros;

            -- Llegirem la data d'efecte i de venciment del rebut.
            IF c_seguros%FOUND THEN
               v_errlin := 5455;

                SELECT    fefecto, fvencim
                     INTO w_fefecto, w_fvencim
                     FROM recibos
                    WHERE nrecibo = w_nrecibo;
            END IF;

            v_errlin := 5460;
            w_err    := pac_cesionesrea.f_cessio_det(w_sproces -- null
            , p_sseguro, w_nrecibo, r_seguros.cactivi, r_seguros.cramo, r_seguros.cmodali, r_seguros.ctipseg, r_seguros.ccolect, w_fefecto, w_fvencim,
            w_nfactor -- null
            ,

            -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
            --                                        pac_md_common.f_get_parinstalacion_n('MONEDAINST'),
            pac_monedas.f_moneda_producto(r_seguros.sproduc),

            -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
            w_cmotces -- 2.- Anul·lació
            );

            IF w_err <> 0 THEN
               p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' r=' || w_nrecibo);
            END IF;

            v_errlin := 5465;

            CLOSE c_seguros;
            --------------------------------------------------------------------------
         END IF;
      END LOOP; -- 13338 AVT 04-03-2010

      RETURN(0);
      --
   EXCEPTION
   WHEN OTHERS THEN
      -- BUG -21546_108724- 09/02/2012 - JLTS - Cierre de posibles cursores abiertos
      IF c_seguros%ISOPEN THEN
         CLOSE c_seguros;
      END IF;

      p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
      RETURN( - 1);
   END f_del_reasegemi;

-----------------------------------------------------------------------------
-- Mantis 10344.01/06/2009.NMM.CRE- Cessions a reasegurança incorrectes.f.
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Mantis 11845.12/2009.NMM.CRE - Ajustar reassegurança d'estalvi .i.
-----------------------------------------------------------------------------
   FUNCTION producte_reassegurable(
         p_sproduc IN productos.sproduc%TYPE)
      RETURN NUMBER
   IS
      w_creaseg productos.creaseg%TYPE;
      --
   BEGIN
       SELECT    creaseg
            INTO w_creaseg
            FROM productos
           WHERE sproduc = p_sproduc;

      RETURN(w_creaseg);
      --
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN(104347); -- Producte no trobat a la taula PRODUCTOS.
   WHEN OTHERS THEN
      RETURN(102705); -- Error al llegir la taula PRODUCTOS.
   END producte_reassegurable;

-----------------------------------------------------------------------------
-- Mantis 11845.12/2009.NMM.CRE - Ajustar reassegurança d'estalvi .f.
-----------------------------------------------------------------------------
/*
*/

-- Bug 19484 - JRB - 27/10/2011 - LCOL_T001: Retención por facultativo antes de emitir la propuesta
-- Estas funciones contemplan tanto el trato de las tablas EST como el de las reales
   FUNCTION f_buscactrrea_est(
         psseguro IN NUMBER,
         pnmovimi IN NUMBER,
         psproces IN NUMBER,
         pmotiu IN NUMBER,
         pmoneda IN NUMBER,
         porigen IN NUMBER DEFAULT 1,  -- 1- Ve d'emissió/renovació  2-Ve de q. d'amortització
         pfinici IN DATE DEFAULT NULL, -- Inici de cessió forçat
         pffin IN DATE DEFAULT NULL,
         ptablas IN VARCHAR2 DEFAULT 'EST') -- Fi de cessió forçat
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
      7.0        30/09/2011   AVT     8. 19484: LCOL_T001: Retención por facultativo antes de emitir la propuesta
      8.0        12/06/2012   AVT     9. 20439: LCOL_A002-Migracion de cesiones de polizas de pagos limitados
      ***********************************************************************/
      lfefecto_ini DATE;
      perr         NUMBER;
      w_cempres    NUMBER(2) := 24; --AMCY - 18/11/2019
      w_cramo      NUMBER(8);
      w_cmodali    NUMBER(2);
      w_ccolect    NUMBER(2);
      w_ctipseg    NUMBER(2);
      w_cactivi    NUMBER(4);
      w_cobjase    NUMBER(2);
      w_nasegur    NUMBER(6);
      w_iprianu garanseg.iprianu%TYPE;   -- 25803: Ampliar los decimales NUMBER(13, 2);
      w_icapital garanseg.icapital%TYPE; -- 25803: Ampliar los decimales NUMBER(15, 2);
      fpolefe   DATE;
      fpolvto   DATE;
      w_fconini DATE;
      w_fconfin DATE;
      w_numlin  NUMBER(6) := 0;
      w_scumulo NUMBER(6);
      w_cestado NUMBER(1);
      w_cfacult NUMBER(1);
      w_scontra NUMBER(6);
      w_nversio NUMBER(2);
      w_icapci  NUMBER;
      w_ipleno  NUMBER;
      w_cdetces NUMBER(1); -- BUG: 17672 JGR 23/02/2011
      -- w_cgarant  NUMBER(4);
      w_cduraci     NUMBER(1);
      w_scontra2    NUMBER(6);
      w_nversio2    NUMBER(2);
      w_olvidate    NUMBER(1);
      w_creaseg     NUMBER(1);
      w_ctiprea     NUMBER(1);
      w_datainici   DATE;
      w_datafinal   DATE;
      w_dias        NUMBER;
      w_dias_origen NUMBER;
      data_final    DATE;
      w_trovat      NUMBER(1);
      w_ctarifa     NUMBER(5);
      w_paplica     NUMBER(5, 2);
      w_ctipatr     NUMBER(1);
      w_ccolum      NUMBER(2);
      w_cfila       NUMBER(2);
      w_ipritar garanseg.ipritar%TYPE; -- 25803: Ampliar los decimales NUMBER(13, 2);
      w_atribu    NUMBER;
      w_iprima    NUMBER;
      w_pmoneda   NUMBER;
      w_nagrupa   NUMBER(4);
      w_moneda    NUMBER;
      w_nanuali   NUMBER(2);
      w_pdtorea   NUMBER(5, 2);
      w_anyefecte NUMBER(4);
      w_cvidaga   NUMBER(1);
      preg1       NUMBER(4);
      preg5       NUMBER(4);
      preg109     NUMBER(4);
      edat        NUMBER;
      sexe        NUMBER;
      w_fedad     DATE;
      w_void      NUMBER(1) := 0;
      resul       NUMBER;
      w_sgt       NUMBER;
      w_fcarpro   DATE;
      w_sproduc   NUMBER;
      w_ctarman   NUMBER;
      w_femisio   DATE;
      w_cforpag   NUMBER;
      w_cidioma   NUMBER;
      ldetces     NUMBER; -- Indica si te detall a reasegemi
      w_fefecto   DATE;
      w_itarrea   NUMBER; -- BUG: 12993 16-02-2010 AVT
      v_ssegpol   NUMBER;
      w_ndurcob   NUMBER;                -- 20439 12/01/2012 AVT
      w_fvencim   DATE;                  -- 20439 12/01/2012 AVT
      w_fpolefe   DATE;                  -- 21559 AVT 07/03/2012
      w_ctipcoa   NUMBER;                -- Bug 23183/126116 - 18/10/2012 - AMC
      v_porcen    NUMBER;                -- Bug 23183/126116 - 18/10/2012 - AMC
      v_cgenrec codimotmov.cgenrec%TYPE; -- 28777 AVT 14/11/2013
      w_cesion_anul_vig NUMBER;
      v_tablas          VARCHAR2(10);                         --0030702 AGG 31/03/2014
      v_base_rea        NUMBER := 0;                          --AGG 14/04/2014
      v_existe_fac_ant  NUMBER;                               -- AGG 14/04/2014
      vpar_traza        VARCHAR2(80) := 'TRAZA_CESIONES_REA'; -- 08/04/2014 AGG
      v_nom_paquete     VARCHAR2(80) := 'PAC_CESIONESREA';
      v_nom_funcion     VARCHAR2(80) := 'F_BUSCACTRREA_EST';
      v_fefecto_rea     DATE; -- 21/07/2014 EDA Bug 0027104/178353.
      v_fefecto_rea_ant DATE; -- 21/07/2014 EDA Bug 0027104/178353.
      v_rea_reten       NUMBER;
      w_iprirea         NUMBER; --31921/192351 - 24/11/2014 - SHA
      w_ipritarrea      NUMBER; --31921/192351 - 24/11/2014 - SHA
      w_iextrea         NUMBER; --31921/192351 - 24/11/2014 - SHA
      lnagrupa          NUMBER; --31921/192351 - 24/11/2014 - SHA
      lcfacult          NUMBER; --31921/192351 - 24/11/2014 - SHA

      CURSOR cur_garant_est
      IS
          SELECT    nmovimi, nriesgo, cgarant, icapital, iprianu, finiefe, ffinefe, iextrap, precarg
               FROM estgaranseg
              WHERE sseguro = psseguro
               AND nmovimi --= pnmovimi -- AVT 02/12/2013 EL MOVIMENT NO TE PERQUE COINCIDIR
               IN
               (SELECT    MAX(nmovimi)
                     FROM estgaranseg
                    WHERE sseguro = psseguro
               )
            AND cobliga = 1; -- 21051 AVT 25/01/2012;

      CURSOR cur_garant
      IS
          SELECT    nmovimi, nriesgo, cgarant, icapital, iprianu, finiefe, ffinefe, iextrap, precarg
               FROM garanseg
              WHERE sseguro = psseguro
               AND nmovimi  = pnmovimi;

      CURSOR cur_garant_car
      IS
          SELECT    nmovima, nriesgo, cgarant, icapital, iprianu, finiefe, ffinefe, iextrap, precarg
               FROM garancar
              WHERE sseguro = psseguro
               AND sproces  =
               (SELECT    MAX(sproces)
                     FROM garancar
                    WHERE sseguro = psseguro
               );

      CURSOR cur_cesaux
      IS
         -- select nriesgo,cgarant,scumulo,iprirea,icapital
         SELECT DISTINCT cgarant
               FROM cesionesaux
              WHERE scontra       IS NULL
               AND nversio        IS NULL
               AND NVL(cfacult, 0) = 0
               AND sproces         = psproces;

      --Bug 31921/192351 - 24/11/2014 - SHA
      CURSOR cur_cesaux2
      IS
          SELECT    *
               FROM cesionesaux
              WHERE scontra IS NOT NULL
               AND nversio  IS NOT NULL
               AND sproces   = psproces;

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
               AND p.cobjase IN (1, 3, 2)--BUG CONF-294  Fecha (09/11/2016) - HRE - se adiciona picapital
               AND sproces   = wsproces;

      --KBR 27/02/2014 - Si son tablas EST debe ir por ESTSEGUROS
      CURSOR c_cum_est(wsproces NUMBER)
      IS --Per cada risc, contracte, versio
         SELECT DISTINCT nriesgo, scontra, nversio
               FROM cesionesaux c, estseguros s, productos p
              WHERE scontra IS NOT NULL
               AND nversio  IS NOT NULL
               AND c.sseguro = s.sseguro
               AND s.sproduc = p.sproduc
               AND p.cobjase IN (1, 3, 2)--BUG CONF-294  Fecha (09/11/2016) - HRE - se adiciona picapital
               AND sproces   = wsproces;

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
               AND sproces    = wpsproces
               AND sseguro    = wpsseguro;
   BEGIN
      p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 1, 'Inicio proceso f_buscactrrea_est sseguro: ' || psseguro ||
      ' nmovimi: ' || pnmovimi || ' sproces: ' || psproces || ' pmotiu: ' || pmotiu || ' pmoneda: ' || pmoneda || ' porigen: ' || porigen || ' pfinici: ' ||
      pfinici || ' pffin: ' || pffin || ' ptablas: ' || ptablas);
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
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 2, 'Error: ' || perr);
         RETURN(perr);
      END;

      v_tablas := ptablas;

      --  AQUI S'OBTENEN DADES DE L'ASSEGURANÇA, TALS COM EL RAM, PRODUCTE,
      --  ACTIVITAT, DATA D'EFECTE I VENCIMENT,SI FACULTATIU FORÇAT...
      IF v_tablas = 'EST' THEN
         BEGIN
            -- Bug 23183/126116 - 18/10/2012 - AMC
             SELECT    s.fefecto, DECODE(s.fcaranu, NULL, s.fvencim, s.fcaranu), s.cramo, s.cmodali, s.ccolect, s.ctipseg, s.cactivi, s.cempres, s.creafac,
                  s.cobjase, s.ctiprea, s.cduraci, s.nanuali, s.fcarpro, s.sproduc, s.ctarman, s.femisio, s.cforpag, s.cidioma,
                  s.ndurcob, s.fvencim, s.fefecto, s.ctipcoa
                  INTO fpolefe, fpolvto, w_cramo, w_cmodali, w_ccolect, w_ctipseg, w_cactivi, w_cempres, w_cfacult, w_cobjase,
                  w_ctiprea, w_cduraci, w_nanuali, w_fcarpro, w_sproduc, w_ctarman, w_femisio, w_cforpag, w_cidioma, w_ndurcob,
                  w_fvencim, w_fefecto, w_ctipcoa
                  FROM estseguros s
                 WHERE s.sseguro = psseguro;

            -- Bug Fi 23183/126116 - 18/10/2012 - AMC
            lfefecto_ini := fpolefe;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            /*perr := 101903;
            RETURN(perr);*/
            v_tablas := 'CAR';
         WHEN OTHERS THEN
            perr := 101919;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 3, 'Error: ' || perr);
            RETURN(perr);
         END;
      END IF;

      --30702 AGG 31/03/2014
      IF v_tablas IN('CAR', 'REA') THEN
         BEGIN
            -- Bug 23183/126116 - 18/10/2012 - AMC
             SELECT    s.fefecto, DECODE(s.fcaranu, NULL, s.fvencim, s.fcaranu), s.cramo, s.cmodali, s.ccolect, s.ctipseg, s.cactivi, s.cempres, s.creafac,
                  s.cobjase, s.ctiprea, s.cduraci, s.nanuali, s.fcarpro, s.sproduc, s.ctarman, s.femisio, s.cforpag, s.cidioma,
                  s.ndurcob, s.fvencim, s.fefecto, s.ctipcoa
                  INTO fpolefe, fpolvto, w_cramo, w_cmodali, w_ccolect, w_ctipseg, w_cactivi, w_cempres, w_cfacult, w_cobjase,
                  w_ctiprea, w_cduraci, w_nanuali, w_fcarpro, w_sproduc, w_ctarman, w_femisio, w_cforpag, w_cidioma, w_ndurcob,
                  w_fvencim, w_fefecto, w_ctipcoa
                  FROM seguros s
                 WHERE s.sseguro = psseguro;

            --Fi Bug 23183/126116 - 18/10/2012 - AMC
            lfefecto_ini := fpolefe;
            ldetces      := NULL;
            perr         := f_parproductos(w_sproduc, 'REASEGURO', ldetces);

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
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 4, 'NO FEM LES CESSIONS: ' || ldetces);
                        RETURN 0; -- no fem les cessions
                     END IF;
                  END IF;
               ELSIF porigen         = 2 THEN -- Quadre d'amortització
                  IF NVL(ldetces, 0) = 1 THEN -- Per rebuts
                     --dbms_output.put_line(' SURT SENSE TARIFAR !!!!!!!!!!!!!!!! ');
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 5, 'SURT SENSE TARIFAR: ' || ldetces);
                     RETURN 0; -- no fem les cessions
                  END IF;
               END IF;
            ELSE
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 6, 'Error: ' || perr);
               --dbms_output.put_line('F_Parproductos('||w_sproduc||', ''REASEGURO'', '||ldetces||'); -->'||perr);
               RETURN perr;
            END IF;

            perr := 0;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            perr := 101903;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 7, 'Error: ' || perr);
            RETURN(perr);
         WHEN OTHERS THEN
            perr := 101919;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 8, 'Error: ' || perr);
            RETURN(perr);
         END;
      END IF;

      --AGG 24/07/2014
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

      --fin AGG 14/04/2014
      w_anyefecte   := TO_CHAR(fpolefe, 'yyyy');

      IF pffin      IS NULL THEN
         data_final := fpolvto;
      ELSE
         data_final := pffin;
      END IF;

      p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 9, 'Data Final: ' || data_final);

      --dbms_output.put_line('---------------------- data_final '||data_final);
      -- AQUI ES MIRA SI L'ASSEGURANÇA INDIVIDUALMENT ES REASSEGURA...
      /*IF w_ctiprea = 2 AND NVL(f_parproductos_v(w_sproduc, 'REASEGURO_AHORRO'), 0) = 0 THEN
         perr     := 99; -- Seguro no reassegurat...
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 10, 'Error: ' || perr);
         RETURN(perr); -- El perr 99 evita que es
      END IF;*/          -- realitzi la cessió...

      -- AQUI ES MIRA SI EL PRODUCTE GLOBAL ES REASSEGURA...
      -- BUG 9549 - 12/05/2009 - AVT - Se añade el reaseguro de ahorro por parámetro
      -- Mantis 11845.12/2009.NMM.CRE - Ajustar reassegurança d'estalvi .i.
      IF pac_cesionesrea.producte_reassegurable(w_sproduc) = 0 AND NVL(f_parproductos_v(w_sproduc, 'REASEGURO_AHORRO'), 0) = 0 THEN
         perr                                             := 99; -- Producte no reassegurat...
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 11, 'Error: ' || perr);
         RETURN(perr); -- El perr 99 evita que es realitzi
      END IF;          -- la cessió...

      --------------------------------------------------
      -- AQUI S'ESCRIU LA TAULA AUXILIAR "CESIONESAUX", A PARTIR DEL GARANSEG...
      IF v_tablas = 'EST' THEN
         FOR reggarant IN cur_garant_est
         LOOP
            IF reggarant.cgarant = 9999 THEN -- garantia 9999(despeses sinistre)
               w_creaseg        := 1;        -- sempre es reassegurra...
            ELSE
               perr    := pac_cesionesrea.f_gar_rea(w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi, reggarant.cgarant, w_creaseg);

               IF perr <> 0 THEN
                  --dbms_output.put_line('PAC_CESIONESREA.F_GAR_REA devuelve error ->'||perr);
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 12, 'Error: ' || perr);
                  RETURN perr;
               END IF;
            END IF;

            IF w_creaseg > 0 THEN
               -- 21/07/2014 EDA Bug 0027104/178353. Cesiones manuales.
               BEGIN
                   SELECT    TO_DATE(trespue, 'DD/MM/YYYY')
                        INTO v_fefecto_rea
                        FROM estpregunseg
                       WHERE sseguro = psseguro
                        AND nriesgo  = reggarant.nriesgo
                        AND cpregun  = f_parproductos_v(w_sproduc, 'CPREGUN_FEFECTO_REA')
                        AND nmovimi  = pnmovimi;
               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_fefecto_rea := NULL;
               WHEN OTHERS THEN
                  perr := 104349;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 13, ' Error: ' || perr);
                  p_tab_error(f_sysdate, f_user, 'f_buscactrrea', 13, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
                  RETURN(perr);
               END;

               BEGIN
                   SELECT    TO_DATE(trespue, 'DD/MM/YYYY')
                        INTO v_fefecto_rea_ant
                        FROM estpregunseg
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
                  perr := 104349;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 14, ' Error: ' || perr);
                  p_tab_error(f_sysdate, f_user, 'f_buscactrrea', 14, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
                  RETURN(perr);
                  --RETURN(perr);
               END;

               -- 21/07/2014 EDA Bug 0027104/178353. Cesiones manuales.
               IF v_fefecto_rea IS NOT NULL THEN
                  fpolefe       := v_fefecto_rea;
                  -- AQUI ES BUSCA LA DATA INICIAL DEL MOVIMENT...si no ve informada
               ELSIF pfinici IS NOT NULL THEN
                  fpolefe    := pfinici;
               ELSE
                  IF pmotiu    = 04 OR pmotiu = 05 THEN -- Es tracta d'un suplement o
                     fpolefe  := reggarant.finiefe;     -- cartera...
                  ELSIF pmotiu = 09 THEN                -- Es tracta d'una rehabilita-
                     BEGIN
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
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 15, 'Error: ' || perr);
                           RETURN(perr);
                        END IF;
                     EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        perr := 109198;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 16, 'Error: ' || perr);
                        RETURN(perr);
                     WHEN OTHERS THEN
                        perr := 104349;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 17, 'Error: ' || perr);
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
                  w_nagrupa   := 1;
                  --ELSIF w_creaseg = 4 THEN
                  -- w_icapital := NVL(pac_propio.ff_capital_pu(psseguro, fpolefe),
                  --                 reggarant.icapital);
               ELSIF w_creaseg = 5 THEN --Reaseguro retenido
                  --Mirar pregunta
                  BEGIN
                      SELECT    NVL(crespue, 0)
                           INTO v_rea_reten
                           FROM estpregungaranseg
                          WHERE sseguro = psseguro
                           AND nriesgo  = reggarant.nriesgo
                           AND cpregun  = f_parproductos_v(w_sproduc, 'CPREGUN_REA_RETEN')
                           AND cgarant  = reggarant.cgarant
                           AND nmovimi  = pnmovimi;
                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     v_rea_reten := 0;
                  WHEN OTHERS THEN
                     perr := 104349;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 18, ' Error: ' || perr);
                     RETURN(perr);
                  END;

                  --Si no reasegura o no esta respuesta, no hacemos nada     (comportamiento como w_creaseg=0)
                  IF v_rea_reten = 0 THEN
                     w_creaseg  := 0;
                  ELSE
                     --Si Reasegura (Comportamiento como CREASEG=1), con w_cfacult = 1
                     w_icapital := reggarant.icapital;
                     w_creaseg  := 1;
                     w_cfacult  := 1;
                     w_nagrupa  := 1;
                  END IF;
               END IF;

               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 19, 'w_icapital: ' || w_icapital || ' w_iprianu: ' ||
               w_iprianu || ' nagrupa: ' || w_nagrupa);

               IF w_cobjase = 4 THEN -- Es tracta d'un innominat...
                  BEGIN
                      SELECT    nasegur
                           INTO w_nasegur
                           FROM estriesgos
                          WHERE sseguro = psseguro
                           AND nriesgo  = reggarant.nriesgo;

                     w_iprianu         := w_iprianu * w_nasegur;
                     w_icapital        := w_icapital * w_nasegur;
                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     perr := 103836;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 20, 'Error: ' || perr);
                     RETURN(perr);
                  WHEN OTHERS THEN
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 21, 'Error: ' || perr);
                     perr := 103509;
                     RETURN(perr);
                  END;
               END IF;

               BEGIN
                  -- BUG: 12993 16-02-2010 AVT
                  IF pmotiu     = 4 THEN
                     w_itarrea := 0;

                     BEGIN
                         SELECT    COUNT( * )
                              INTO w_itarrea
                              FROM reaformula
                             WHERE cgarant = reggarant.cgarant
                              AND ccampo   = 'ITARREA';
                     EXCEPTION
                     WHEN OTHERS THEN
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 22, 'Error: ' || perr);
                        perr := 108423;
                     END;
                  END IF;

                  -------------- Gravarem si és renovació o nova producció tot i que no hi hagi prima ni capital
                  IF NVL(w_iprianu, 0) <> 0 OR NVL(w_icapital, 0) <> 0 OR pmotiu IN(5, 3) OR NVL(w_itarrea, 0) <> 0 THEN -- BUG: 12993 16-02-2010 AVT
                     w_void            := 1;
                     w_fconini         := fpolefe;

                     -- CPM 27/09/06: Se coge la fecha final correcta
                     IF w_cforpag  = 0 THEN
                        w_fconfin := ADD_MONTHS(data_final, ( - 12) * TRUNC(MONTHS_BETWEEN(data_final - 1, fpolefe) / 12));
                     ELSE
                        w_fconfin := data_final;
                     END IF;

                     w_cestado := 0;
                     w_numlin  := w_numlin + 1;

                     --P_Control_Error ('BUSCACTRREA','insert','w_scontra='||w_scontra||'w_nversio'||w_nversio);
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
                                 reggarant.precarg, 0
                              );
                     EXCEPTION
                     WHEN OTHERS THEN
                        perr := 108423;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 23, 'Error: ' || perr);
                        RETURN(perr);
                     END;
                  END IF;
               END;
            END IF;
         END LOOP;
      ELSIF v_tablas = 'CAR' THEN
         FOR reggarant IN cur_garant_car
         LOOP
            IF reggarant.cgarant = 9999 THEN -- garantia 9999(despeses sinistre)
               w_creaseg        := 1;        -- sempre es reassegurra...
            ELSE
               perr    := pac_cesionesrea.f_gar_rea(w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi, reggarant.cgarant, w_creaseg);

               IF perr <> 0 THEN
                  --dbms_output.put_line('PAC_CESIONESREA.F_GAR_REA devuelve error ->'||perr);
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 24, 'Error: ' || perr);
                  RETURN perr;
               END IF;
            END IF;

            IF w_creaseg > 0 THEN
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
                  perr := 104349;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 25, ' Error: ' || perr);
                  p_tab_error(f_sysdate, f_user, 'f_buscactrrea', 25, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
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
                  perr := 104349;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 26, ' Error: ' || perr);
                  p_tab_error(f_sysdate, f_user, 'f_buscactrrea', 26, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
                  RETURN(perr);
                  --RETURN(perr);
               END;

               -- 21/07/2014 EDA Bug 0027104/178353. Cesiones manuales.
               IF v_fefecto_rea IS NOT NULL THEN
                  fpolefe       := v_fefecto_rea;
                  -- AQUI ES BUSCA LA DATA INICIAL DEL MOVIMENT...si no ve informada
               ELSIF pfinici IS NOT NULL THEN
                  fpolefe    := pfinici;
               ELSE
                  IF pmotiu    = 04 OR pmotiu = 05 THEN -- Es tracta d'un suplement o
                     fpolefe  := reggarant.finiefe;     -- cartera...
                  ELSIF pmotiu = 09 THEN                -- Es tracta d'una rehabilita-
                     BEGIN                              -- ció: el moviment no està
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
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 27, 'Error: ' || perr);
                           RETURN(perr);
                        END IF;
                     EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 28, 'Error: ' || perr);
                        perr := 109198;
                        RETURN(perr);
                     WHEN OTHERS THEN
                        perr := 104349;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 29, 'Error: ' || perr);
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
                  w_nagrupa   := 1;
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
                     perr := 104349;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 30, ' Error: ' || perr);
                     RETURN(perr);
                  END;

                  --Si no reasegura o no esta respuesta, no hacemos nada     (comportamiento como w_creaseg=0)
                  IF v_rea_reten = 0 THEN
                     w_creaseg  := 0;
                  ELSE
                     --Si Reasegura (Comportamiento como CREASEG=1), con w_cfacult = 1
                     w_icapital := reggarant.icapital;
                     w_creaseg  := 1;
                     w_cfacult  := 1;
                     w_nagrupa  := 1;
                  END IF;
               END IF;

               IF w_cobjase = 4 THEN -- Es tracta d'un innominat...
                  BEGIN
                      SELECT    nasegur
                           INTO w_nasegur
                           FROM riesgos
                          WHERE sseguro = psseguro
                           AND nriesgo  = reggarant.nriesgo;

                     w_iprianu         := w_iprianu * w_nasegur;
                     w_icapital        := w_icapital * w_nasegur;
                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     perr := 103836;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 31, 'Error: ' || perr);
                     RETURN(perr);
                  WHEN OTHERS THEN
                     perr := 103509;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 32, 'Error: ' || perr);
                     RETURN(perr);
                  END;
               END IF;

               BEGIN
                  -----------     Busquem si el risc forma part d'un cumul...
                  w_scumulo := NULL;

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
                        perr := 104665;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 33, 'Error: ' || perr);
                        RETURN(perr);
                     END;
                  WHEN OTHERS THEN
                     perr := 104665;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 34, 'Error: ' || perr);
                     RETURN(perr);
                  END;

                  ----------     Busquem si hi ha algun risc, garantia o cumul a "piñón fijo"...
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
                           NULL;
                        WHEN OTHERS THEN
                           perr := 104666;
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 35, 'Error: ' || perr);
                           RETURN(perr);
                        END;
                     WHEN OTHERS THEN
                        perr := 104666;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 36, 'Error: ' || perr);
                        RETURN(perr);
                     END;
                  WHEN OTHERS THEN
                     perr := 104666;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 37, 'Error: ' || perr);
                     RETURN(perr);
                  END;

                  -- BUG: 12993 16-02-2010 AVT
                  IF pmotiu     = 4 THEN
                     w_itarrea := 0;

                     BEGIN
                         SELECT    COUNT( * )
                              INTO w_itarrea
                              FROM reaformula
                             WHERE cgarant = reggarant.cgarant
                              AND ccampo   = 'ITARREA';
                     EXCEPTION
                     WHEN OTHERS THEN
                        perr := 108423;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 38, 'Error: ' || perr);
                     END;
                  END IF;

                  -------------- Gravarem si és renovació o nova producció tot i que no hi hagi prima ni capital
                  IF NVL(w_iprianu, 0) <> 0 OR NVL(w_icapital, 0) <> 0 OR pmotiu IN(5, 3) OR NVL(w_itarrea, 0) <> 0 THEN -- BUG: 12993 16-02-2010 AVT
                     w_void            := 1;
                     w_fconini         := fpolefe;

                     -- CPM 27/09/06: Se coge la fecha final correcta
                     IF w_cforpag  = 0 THEN
                        w_fconfin := ADD_MONTHS(data_final, ( - 12) * TRUNC(MONTHS_BETWEEN(data_final - 1, fpolefe) / 12));
                     ELSE
                        w_fconfin := data_final;
                     END IF;

                     w_cestado := 0;
                     w_numlin  := w_numlin + 1;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 39, 'w_scontra: ' || w_scontra || ' w_nversio: ' ||
                     w_nversio);

                     --P_Control_Error ('BUSCACTRREA','insert','w_scontra='||w_scontra||'w_nversio'||w_nversio);
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
                        perr := 108423;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 40, 'Error: ' || perr);
                        RETURN(perr);
                     END;
                  END IF;
               END;
            END IF;
         END LOOP;
      ELSE
         FOR reggarant IN cur_garant
         LOOP
            IF reggarant.cgarant = 9999 THEN -- garantia 9999(despeses sinistre)
               w_creaseg        := 1;        -- sempre es reassegurra...
            ELSE
               perr    := pac_cesionesrea.f_gar_rea(w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi, reggarant.cgarant, w_creaseg);

               IF perr <> 0 THEN
                  --dbms_output.put_line('PAC_CESIONESREA.F_GAR_REA devuelve error ->'||perr);
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 41, 'Error: ' || perr);
                  RETURN perr;
               END IF;
            END IF;

            IF w_creaseg > 0 THEN
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
                  perr := 104349;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 42, ' Error: ' || perr);
                  p_tab_error(f_sysdate, f_user, 'f_buscactrrea', 42, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
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
                  perr := 104349;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 43, ' Error: ' || perr);
                  p_tab_error(f_sysdate, f_user, 'f_buscactrrea', 43, 'ERROR psseguro:' || psseguro || ' pnmovimi:' || pnmovimi, SQLERRM);
                  RETURN(perr);
                  --RETURN(perr);
               END;

               -- 21/07/2014 EDA Bug 0027104/178353. Cesiones manuales.
               IF v_fefecto_rea IS NOT NULL THEN
                  fpolefe       := v_fefecto_rea;
                  -- AQUI ES BUSCA LA DATA INICIAL DEL MOVIMENT...si no ve informada
               ELSIF pfinici IS NOT NULL THEN
                  fpolefe    := pfinici;
               ELSE
                  IF pmotiu    = 04 OR pmotiu = 05 THEN -- Es tracta d'un suplement o
                     fpolefe  := reggarant.finiefe;     -- cartera...
                  ELSIF pmotiu = 09 THEN                -- Es tracta d'una rehabilita-
                     BEGIN                              -- ció: el moviment no està
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
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 44, 'Error: ' || perr);
                           RETURN(perr);
                        END IF;
                     EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        perr := 109198;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 45, 'Error: ' || perr);
                        RETURN(perr);
                     WHEN OTHERS THEN
                        perr := 104349;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 46, 'Error: ' || perr);
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
                  w_nagrupa   := 1;
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
                     perr := 104349;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 47, ' Error: ' || perr);
                     RETURN(perr);
                  END;

                  --Si no reasegura o no esta respuesta, no hacemos nada     (comportamiento como w_creaseg=0)
                  IF v_rea_reten = 0 THEN
                     w_creaseg  := 0;
                  ELSE
                     --Si Reasegura (Comportamiento como CREASEG=1), con w_cfacult = 1
                     w_icapital := reggarant.icapital;
                     w_creaseg  := 1;
                     w_cfacult  := 1;
                     w_nagrupa  := 1;
                  END IF;
               END IF;

               IF w_cobjase = 4 THEN -- Es tracta d'un innominat...
                  BEGIN
                      SELECT    nasegur
                           INTO w_nasegur
                           FROM riesgos
                          WHERE sseguro = psseguro
                           AND nriesgo  = reggarant.nriesgo;

                     w_iprianu         := w_iprianu * w_nasegur;
                     w_icapital        := w_icapital * w_nasegur;
                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     perr := 103836;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 48, 'Error: ' || perr);
                     RETURN(perr);
                  WHEN OTHERS THEN
                     perr := 103509;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 49, 'Error: ' || perr);
                     RETURN(perr);
                  END;
               END IF;

               BEGIN
                  -----------     Busquem si el risc forma part d'un cumul...
                  w_scumulo := NULL;

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
                        perr := 104665;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 50, 'Error: ' || perr);
                        RETURN(perr);
                     END;
                  WHEN OTHERS THEN
                     perr := 104665;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 51, 'Error: ' || perr);
                     RETURN(perr);
                  END;

                  ----------     Busquem si hi ha algun risc, garantia o cumul a "piñón fijo"...
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
                           NULL;
                        WHEN OTHERS THEN
                           perr := 104666;
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 52, 'Error: ' || perr);
                           RETURN(perr);
                        END;
                     WHEN OTHERS THEN
                        perr := 104666;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 53, 'Error: ' || perr);
                        RETURN(perr);
                     END;
                  WHEN OTHERS THEN
                     perr := 104666;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 54, 'Error: ' || perr);
                     RETURN(perr);
                  END;

                  -- BUG: 12993 16-02-2010 AVT
                  IF pmotiu     = 4 THEN
                     w_itarrea := 0;

                     BEGIN
                         SELECT    COUNT( * )
                              INTO w_itarrea
                              FROM reaformula
                             WHERE cgarant = reggarant.cgarant
                              AND ccampo   = 'ITARREA';
                     EXCEPTION
                     WHEN OTHERS THEN
                        perr := 108423;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 55, 'Error: ' || perr);
                     END;
                  END IF;

                  -------------- Gravarem si és renovació o nova producció tot i que no hi hagi prima ni capital
                  IF NVL(w_iprianu, 0) <> 0 OR NVL(w_icapital, 0) <> 0 OR pmotiu IN(5, 3) OR NVL(w_itarrea, 0) <> 0 THEN -- BUG: 12993 16-02-2010 AVT
                     w_void            := 1;
                     w_fconini         := fpolefe;

                     -- CPM 27/09/06: Se coge la fecha final correcta
                     IF w_cforpag  = 0 THEN
                        w_fconfin := ADD_MONTHS(data_final, ( - 12) * TRUNC(MONTHS_BETWEEN(data_final - 1, fpolefe) / 12));
                        -- 20439 12/01/2012 AVT RENOVACIÓ FINS AL DARRER REBUT DE COBRAMENT ------------
                        -- 21559 08/03/2012 AVT JA NO APLICA                   ELSIF pac_parametros.f_parproducto_t(w_sproduc, 'F_POST_EMISION') IS NOT NULL
                        -- THEN
                        --                      w_fconfin := data_final;
                        --                        IF w_ndurcob IS NOT NULL THEN
                        --                           IF w_fconini = ADD_MONTHS(w_fefecto,(w_ndurcob - 1) * 12) THEN
                        --                              w_fconfin := w_fvencim;
                        --                           ELSIF w_fconini > ADD_MONTHS(w_fefecto,(w_ndurcob - 1) * 12) THEN
                        --                              EXIT;
                        --                           END IF;
                        --                        END IF;
                        -- 20439 12/01/2012 AVT ----------------------------------------------------------
                     ELSE
                        w_fconfin := data_final;
                     END IF;

                     w_cestado := 0;
                     w_numlin  := w_numlin + 1;

                     --P_Control_Error ('BUSCACTRREA','insert','w_scontra='||w_scontra||'w_nversio'||w_nversio);
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
                        perr := 108423;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 56, 'Error: ' || perr);
                        RETURN(perr);
                     END;
                  END IF;
               END;
            END IF;
         END LOOP;
      END IF;

      ------------------------------------------------------------------
      -- AQUI ANEM A EFECTUAR LES CERQUES SUCCESSIVES, PER CADA GARANTIA SENSE
      -- CONTRACTE ASSIGNAT, SEGONS EL QUADRE EXPOST EN ELS COMENTARIS INICIALS...
      -- ES FA UNA CERCA PER TOTES LES GARANTIES I DESPRES ES PASSA, SI FA FALTA,
      -- A LA SEGÜENT CERCA...
      FOR regcesion IN cur_cesaux
      LOOP -- llegim les garanties sense contracte...
         -- Si es calcula desde el Q. Amortització i és una prima única
         -- forçarem el contracte = al de la cessió anterior
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 570, 'w_scontra: ' || w_scontra || ' nversio: ' ||
               w_nversio || ' ipleno: ' || w_ipleno || ' icapaci: ' || w_icapci||' porigen:'||porigen||
               ' w_cforpag:'||w_cforpag);
         w_scontra := NULL;

         IF porigen = 2 AND w_cforpag = 0 THEN
            resul  := f_buscacontrato(psseguro, lfefecto_ini, w_cempres, regcesion.cgarant, w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi, pmotiu,
            w_scontra, w_nversio, w_ipleno, w_icapci, w_cdetces); -- BUG: 17672 JGR 23/02/2011

            --resul := f_buscacont_ant(psseguro, w_scontra , w_nversio,w_ipleno, w_icapci);
            IF resul <> 0 THEN
               --dbms_output.put_line('F_Buscacontrato devuelve -->'||resul);
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 57, 'f_buscacontrato: ' || resul);
               RETURN resul;
            END IF;
         END IF;

         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 58, 'Contracte Antic scontra: ' || w_scontra || ' nversio: ' ||
         w_nversio || ' ipleno: ' || w_ipleno || ' icapaci: ' || w_icapci);

         --dbms_output.put_line(' CONTRACTE ANTIC '||w_scontra||'-'||w_nversio||'-'||w_ipleno||'-'||w_icapci);
         --dbms_output.put_line('resul '||resul );
         -- Si no l'hem trobat ho fem normal
         IF w_scontra IS NULL THEN
            -- 21559 AVT 07/03/2012 segons temporalitat ------- QUE PASSA AMB 6018, 6019 ??? ---

            -- 26321 KBR 05/03/2013 Cambiamos parámetro técnico por uno propio del reaseguro
            IF (NVL(pac_parametros.f_parproducto_n(w_sproduc, 'PER_REV_NO_ANUAL_REA'), 0) > 1) THEN
               w_fpolefe                                                                 := pac_cesionesrea.f_renovacion_anual_rea(psseguro, fpolefe, v_tablas)
               ;
            ELSE
               w_fpolefe := fpolefe;
            END IF;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 571, 'w_scontra: ' || w_scontra || ' nversio: ' ||
               w_nversio || ' ipleno: ' || w_ipleno || ' icapaci: ' || w_icapci||' porigen:'||porigen||
               ' w_cforpag:'||w_cforpag);
            -- 21559 AVT 07/03/2012 fi-------------------------
            resul := f_buscacontrato(psseguro, w_fpolefe, w_cempres, regcesion.cgarant, w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi, pmotiu, w_scontra,
            w_nversio, w_ipleno, w_icapci, w_cdetces); -- BUG: 17672 JGR 23/02/2011
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 572, 'w_scontra: ' || w_scontra || ' nversio: ' ||
               w_nversio || ' ipleno: ' || w_ipleno || ' icapaci: ' || w_icapci||' porigen:'||porigen||
               ' w_cforpag:'||w_cforpag);
            -- 28396 AVT 01/10/2013 -> 26663 AVT 07/08/2013 busquem si hi ha XL per controlar el límit ----------------------
            IF resul  = 104485 THEN
               resul := f_buscacontrato(psseguro, w_fpolefe, w_cempres, regcesion.cgarant, w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi, 11, w_scontra,
               w_nversio, w_ipleno, w_icapci, w_cdetces);
            END IF;
            -- 28396 AVT 01/10/2013 -> 26663 AVT 07/08/2013  fi -------------------------------------------
         END IF;

         IF resul = 0 THEN
            BEGIN
                UPDATE cesionesaux
                  SET scontra = w_scontra, nversio = w_nversio, icapaci = w_icapci, ipleno = w_ipleno, scumulo = w_scumulo, cdetces = NVL(w_cdetces, cdetces)
                     -- BUG: 17672 JGR 23/02/2011
                    WHERE cgarant = regcesion.cgarant
                     AND sproces  = psproces;
               --P_Control_Error ('BUSCACTRREA','update','w_scontra='||w_scontra||'w_nversio'||w_nversio||' '||SQL%ROWCOUNT||' registros modificados');
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
               perr := 104677;
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 59, 'Error: ' || perr);
               RETURN(perr);
            WHEN OTHERS THEN
               perr := 104678;
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 60, 'Error: ' || perr);
               RETURN(perr);
            END;
         ELSE
            --dbms_output.put_line('f_buscacontrato '||w_scontra||' iple - devuelve --> '||resul);
            RETURN(resul);
         END IF;
      END LOOP;

      -----------------------------------------------------------------
      -- Anem a fer el càlcul automàtic dels cúmuls.
      -----------------------------------------------------------------

      --Per cada risc, contracte, versio
      IF v_tablas = 'EST' THEN
         FOR vcum IN c_cum_est(psproces)
         LOOP
            IF pmotiu = 4 THEN
                SELECT    ssegpol
                     INTO v_ssegpol
                     FROM estseguros
                    WHERE sseguro = psseguro;

               -- AVT 15-11-2011 nos vamos a la función sobre las tablas definitivas.
               resul := pac_cesionesrea.f_reacumul(v_ssegpol, vcum.nriesgo, vcum.scontra, vcum.nversio, fpolefe, w_sproduc, w_scumulo);
            ELSE
               resul := pac_cesionesrea.f_reacumul_est(psseguro, vcum.nriesgo, vcum.scontra, vcum.nversio, fpolefe, w_sproduc, w_scumulo, v_tablas);
            END IF;

            IF resul <> 0 THEN
               --dbms_output.put_line('Pac_Cesionesrea.f_reacumul - devuelve -->'||resul);
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 61, 'f_reacumul: ' || resul);
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
               perr := 104696;
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 62, 'Error: ' || perr);
               RETURN(perr);
            END;
         END LOOP;
      ELSE
         FOR vcum IN c_cum(psproces)
         LOOP
            resul    := pac_cesionesrea.f_reacumul_est(psseguro, vcum.nriesgo, vcum.scontra, vcum.nversio, fpolefe, w_sproduc, w_scumulo, v_tablas);

            IF resul <> 0 THEN
               --dbms_output.put_line('Pac_Cesionesrea.f_reacumul - devuelve -->'||resul);
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 63, 'f_reacumul: ' || resul);
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
               perr := 104696;
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 64, 'Error: ' || perr);
               RETURN(perr);
            END;
         END LOOP;
      END IF;

      -------------------------------------------------------------------------
      -- AQUI, SI ES VIDA, BUSCAREM LA TARIFA ESPECIAL I ACTUALITZAREM CESIONESAUX
      -- I EL ITARREA DE GARANSEG...
      --------------------------------------------------------------------------
      --dbms_output.put_line(' xxxxx ');
      --   w_sgt := NVL(F_Parinstalacion_N('REAS_SGT'),0);
      w_sgt := NVL(pac_parametros.f_parempresa_n(w_cempres, 'REAS_SGT'), 0); -- FAL 01/2009. Bug 8528. Se sustituye parámetro de instalación por parámetro de
      -- empresa

      --dbms_output.put_line(' crida a xl');
      ------------------------------------------------------------------------
      -- AL FINAL DE TOT, BUSQUEM SI HI HA ALGUN CONTRACTE "XL" O "SL" QUE
      -- AMPARI EL RAM, O BE SI CAP GARANTIA TE CONTRACTE...
      FOR regcesion IN cur_cesaux -- QUEDEN GARANTIES SENSE CONTRACTE...
      LOOP
         perr := 104769;

         FOR regcontrato IN cur_contra_xlsl -- PERÒ TENEN XL O SL QUE LES AMPARA...
         LOOP
            perr := 99;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 65, 'Error: ' || perr);
         END LOOP;
      END LOOP;

      IF w_void = 0 THEN -- El GARANSEG estava buit...
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 66, 'Error: ' || perr);
         perr := 99;
      END IF;

      IF perr = 99 THEN
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 67, 'Error: ' || perr);
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

      IF perr = 0 AND w_sgt = 1 AND NVL(f_parproductos_v(w_sproduc, 'NO_REA_SGT'), 0) = 0 THEN -- BUG: 12971 05-02-2010 AVT per productes que no tarifiquen
         DECLARE
            v_existe_garcar NUMBER;
         BEGIN
            v_existe_garcar := 0;

            IF v_tablas      = 'CAR' THEN
                SELECT    COUNT( * )
                     INTO v_existe_garcar
                     FROM garancar
                    WHERE sseguro = psseguro
                     AND finiefe  = data_final;
            END IF;

            IF v_existe_garcar = 0 THEN
               perr           := pac_cesionesrea.f_garantarifa_rea_est(psproces, psseguro, pnmovimi, w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_sproduc,
               w_cactivi,
               --w_fcarpro , --no és propera cartera sino la data del calcul
               -- per tant és l'inici de la cessio
               w_fefecto,    -- fpolefe (fcarpro)
               lfefecto_ini, --pfinici ,-- w_femisio
               w_ctarman, w_cobjase, w_cforpag, w_cidioma, pmoneda, v_tablas);

               IF perr <> 0 THEN
                  --dbms_output.put_line('Pac_Cesionesrea.f_garantarifa_rea '||perr);
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 6, 'Error: ' || perr);
                  RETURN perr;
               END IF;
            END IF;
         END;
      END IF;

      -- Inici Bug 31921/192351 - 24/11/2014 - SHA
      lnagrupa := 1;
      p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 68, 'v_risc... - ' || psproces || ', ' || psseguro);

      FOR v_risc IN c_risc(psproces, psseguro)
      LOOP
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 69, 'Entramos en v_risc');

         FOR v_gar_risc IN cur_cesaux2
         LOOP
            lcfacult := NULL;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 70, 'Entramos en v_gar_risc');

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
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 71, 'v_gar_risc.cgarant:' || v_gar_risc.cgarant ||
               ' w_ctipcoa:' || w_ctipcoa);

               --Bug 34208 KBR 14/01/2015 Manejar diferentes tipos de tablas
			   -- 4472 - INI - REVISAR SIEMPRE EL PORCENTAJE DE AMPARO
               IF w_ctipcoa = 1 THEN
                  BEGIN
                     IF v_tablas = 'EST' THEN
                         SELECT    NVL(c.ploccoa, 100)
                              INTO v_porcen
                              FROM estcoacuadro c, estseguros s
                             WHERE c.sseguro = s.sseguro
                              AND c.ncuacoa  = s.ncuacoa
                              AND s.ctipcoa <> 0
                              AND s.sseguro  = psseguro;
                     ELSE
                         SELECT    NVL(c.ploccoa, 100)
                              INTO v_porcen
                              FROM coacuadro c, seguros s
                             WHERE c.sseguro = s.sseguro
                              AND c.ncuacoa  = s.ncuacoa
                              AND s.ctipcoa <> 0
                              AND s.sseguro  = psseguro;
                     END IF;
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
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 72, 'v_porcen:' || v_porcen);
               END IF;
			   -- 4472 - INI - REVISAR SIEMPRE EL PORCENTAJE DE AMPARO
            END IF;

            --Fi BUG 29347/163814 - 23/01/2014 - RCL
             UPDATE cesionesaux
               SET iextrea   = NVL(w_iextrea, 0),          --> REA.11845.NMM. Afegim nvl's.
                  iextrap    = NVL(v_gar_risc.iextrap, 0), --> REA
                  iprirea    = NVL(w_iprirea, 0),          -- BUG 29347/163814 - 23/01/2014 - RCL
                  ipritarrea = NVL(w_ipritarrea, 0), idtosel = NVL(v_gar_risc.idtosel, 0), psobreprima = v_gar_risc.psobreprima, icapital = NVL(w_icapital, 0),
                  -- BUG 29347/163814 - 23/01/2014 - RCL
                  ipleno = NVL(v_gar_risc.ipleno, 0), icapaci = NVL(v_gar_risc.icapaci, 0), cfacult = NVL(lcfacult, cfacult), -- si es null deixem el que hi
                  -- havia
                  scontra = DECODE(lcfacult, 1, NULL, scontra), nversio = DECODE(lcfacult, 1, NULL, nversio), nagrupa = DECODE(lcfacult, 1, lnagrupa, nagrupa),
                  -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                  itarifrea = NVL(v_gar_risc.itarifrea, 0) --> Tasa de Reaseguro
                  -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
                 WHERE sproces = psproces
                  AND sseguro  = psseguro
                  AND nriesgo  = v_risc.nriesgo
                  AND cgarant  = v_gar_risc.cgarant;

            lnagrupa          := lnagrupa + 1;
         END LOOP;
      END LOOP;

      -- Fi Bug 31921/192351 - 24/11/2014 - SHA

      -- END IF;   -- 28777 AVT 13/11/2013 fi
      p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 69, 'Fin proceso: ' || perr);
      --   P_Borrar_Jgr (2); --> BORRAR JGR
      RETURN(perr);
   EXCEPTION
   WHEN OTHERS THEN
      --dbms_output.PUT_LINE(SQLERRM);
      RETURN(perr);
   END f_buscactrrea_est;

-- Estas funciones contemplan tanto el trato de las tablas EST como el de las reales
   FUNCTION f_capital_cumul_est(
         pctiprea IN NUMBER,
         pscumulo IN NUMBER,
         pfecini IN DATE,
         pcgarant IN NUMBER,
         pcapital IN OUT NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER
   IS
      /***********************************************************************
      f_capital_cumul        : Buscar el capital d'un cumul.
      ***********************************************************************/
      perr      NUMBER := 0;
      w_sseguro NUMBER;
      w_nriesgo NUMBER(6);
      w_cgarant NUMBER(4);
      w_cramo   NUMBER(8);
      w_cmodali NUMBER(2);
      w_ctipseg NUMBER(2);
      w_ccolect NUMBER(2);
      w_creaseg NUMBER(1);
      w_cactivi NUMBER(4);
      w_tabla   VARCHAR2(3);
      v_fefecto DATE; --29011 AVT 13/11/13

      CURSOR cur_reariesgos
      IS
          SELECT    sseguro, nriesgo, cgarant, freaini
               FROM reariesgos
              WHERE scumulo = pscumulo
               AND freaini <= NVL(v_fefecto, pfecini) --29011 AVT 13/11/13
               AND(freafin IS NULL
               OR freafin   > pfecini)
               AND(cgarant  = pcgarant
               OR cgarant  IS NULL); -- 13195 01-03-2010 AVT

      CURSOR cur_garanseg
      IS
          SELECT    icapital, cgarant
               FROM garanseg g
              WHERE g.sseguro = w_sseguro
               AND g.nriesgo  = w_nriesgo
               AND(cgarant    = w_cgarant
               OR w_cgarant  IS NULL)
               AND g.ffinefe IS NULL;

      --JRB -- Duda si se añade garancar o no
      CURSOR cur_garancar
      IS
          SELECT    icapital, cgarant
               FROM garancar g
              WHERE g.sseguro = w_sseguro
               AND g.nriesgo  = w_nriesgo
               AND(cgarant    = w_cgarant
               OR w_cgarant  IS NULL)
               AND g.ffinefe IS NULL;

      -- 19484
      CURSOR cur_garanseg_est
      IS
          SELECT    icapital, cgarant
               FROM estgaranseg g
              WHERE g.sseguro = w_sseguro
               AND g.nriesgo  = w_nriesgo
               AND(cgarant    = w_cgarant
               OR w_cgarant  IS NULL)
               AND g.ffinefe IS NULL
               AND g.cobliga  = 1; -- 21051 AVT 25/01/2012;
   BEGIN
      IF pctiprea  = 1 THEN
         pcapital := 0;

         -- 29011 AVT 13/11/13
          SELECT    MAX(freaini)
               INTO v_fefecto
               FROM reariesgos r
              WHERE r.scumulo = pscumulo
               AND(r.freafin  > pfecini
               OR r.freafin  IS NULL);

         FOR regcumul IN cur_reariesgos
         LOOP
            w_sseguro := regcumul.sseguro;
            w_nriesgo := regcumul.nriesgo;
            w_cgarant := regcumul.cgarant;

            BEGIN
                SELECT    cramo, cmodali, ctipseg, ccolect, pac_seguros.ff_get_actividad(sseguro, w_nriesgo)
                     INTO w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi
                     FROM estseguros
                    WHERE sseguro = w_sseguro;

               w_tabla           := 'EST'; -- AVT 15-11-2011
            EXCEPTION
            WHEN NO_DATA_FOUND THEN -- 19484
                SELECT    cramo, cmodali, ctipseg, ccolect, pac_seguros.ff_get_actividad(sseguro, w_nriesgo)
                     INTO w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi
                     FROM seguros
                    WHERE sseguro = w_sseguro;

               w_tabla           := NULL;
            WHEN OTHERS THEN
               perr := 101919;
            END;

            IF w_tabla = 'EST' AND ptablas = 'EST' THEN -- AVT 15-11-2011
               --19484 s'afegeix per acumular amb la pòlissa en Proposta d'Alta
               FOR reggaranseg IN cur_garanseg_est
               LOOP
                  perr        := pac_cesionesrea.f_gar_rea(w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi, reggaranseg.cgarant, w_creaseg);

                  IF w_creaseg = 1 OR w_creaseg = 3 THEN
                     pcapital := pcapital + NVL(reggaranseg.icapital, 0);
                  END IF;
               END LOOP;
            ELSIF ptablas = 'CAR' THEN
               FOR reggaranseg IN cur_garancar
               LOOP -- añadimos cartera
                  -- BUG 11100 - 16/09/2009 - FAL - Crida a la pac_cesionesrea.f_gar_rea per si garantia reasegurable
                  perr        := pac_cesionesrea.f_gar_rea(w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi, reggaranseg.cgarant, w_creaseg);

                  IF w_creaseg = 1 OR w_creaseg = 3 THEN
                     pcapital := pcapital + NVL(reggaranseg.icapital, 0);
                  END IF;
               END LOOP;
            ELSE
               FOR reggaranseg IN cur_garanseg
               LOOP
                  -- BUG 11100 - 16/09/2009 - FAL - Crida a la pac_cesionesrea.f_gar_rea per si garantia reasegurable
                  perr        := pac_cesionesrea.f_gar_rea(w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi, reggaranseg.cgarant, w_creaseg);

                  IF w_creaseg = 1 OR w_creaseg = 3 THEN
                     pcapital := pcapital + NVL(reggaranseg.icapital, 0);
                  END IF;
               END LOOP;
            END IF;
         END LOOP;
      ELSE -- tipus de contracte amb import propi fixe, no cal sumar capitals per trobar
         -- les proporcions
         --DBMS_OUTPUT.PUT_LINE(' ------------ f_capital_cumul RETORNA NULL -----------');
         NULL;
      END IF;

      RETURN(perr);
   END f_capital_cumul_est;

-- Estas funciones contemplan tanto el trato de las tablas EST como el de las reales
   FUNCTION f_cessio_est(
         psproces IN NUMBER,
         pmotiu IN NUMBER,
         pmoneda IN NUMBER,
         pfdatagen IN DATE DEFAULT f_sysdate,
         pcgesfac IN NUMBER DEFAULT 0,      -- AQUÍ S'HAURÀ DE CONTROLAR SI VENIM DE L'EMISSIÓ
         ptablas IN VARCHAR2 DEFAULT 'EST') -- 19484 1-Fer o 0-No Facultatiu)
      RETURN NUMBER
   IS
      /***********************************************************************
      F_CESSIO       : Fer cessions de reassegurança per totes
      les garanties d'una pòlissa determinada.
      Parteix de l'informació que hi ha a la
      taula auxiliar CESIONESAUX (omplert per
      la funció f_buscactrrea).
      Estat (cestado) del registres a CESIONESAUX:
      0 - Registre inicial, a refondre ...
      1 - Registres ja refosos...
      2 - Registres per els que es pot fer la cessió...
      Si la funció torna un perr 99, significa que hi
      ha un facultatiu pendent i que no s'ha fet la
      cessió...
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  -------  -------------------------------------
      1.0        XX/XX/XXXX   XXX     1. Creación de la función.
      2.0        18/03/2010   AVT     2. 12682: CRE996 - Creación de producto Credit Vida Privats
      3.0        07/04/2010   AVT     3. 13946: CRE200 - Incidencia cartera - pólizas retenidas por facultativo
      4.0        03/05/2010   AVT     4. 14400: CRE203 - Pólizas de Saldo Deutors paradas por cúmulo/facultativo
      5.0        14/05/2010   AVT     5. 14536: CRE200 - Reaseguro: Se requiere que un contrato se pueda utilizar
      en varias agrupaciones de producto
      6.0        26/05/2010   AVT     6. 14404: CIV200 - ERROR EN CAPITALES CEDIDOS DE REASEGURO
      7.0        30/07/2010   AVT     7. 15590: CRE800 - Quadres facultatius
      8.0        08/10/2010   AVT     8. 16263: AGA003 - Error de definición de los contratos de reaseguro de los
      productos de hogar y comunidades
      9.0        28/10/2013   JGR/AVT 9. 20606: LCOL_T004-LCOL_T001- Recalcul de les cessions per cúmul amb facultatiu - Nota:0101205
      10.0        02/01/2012   AVT    10. 19484: LCOL_T001: Retención por facultativo antes de emitir la propuesta: ajustar quan hi ha més d'un q.fac
      11.0        06/03/2012   AVT    11. 21559: LCOL999-Cambios en el Reaseguro: Distribución de los Capitales con base en la garantía principal
      12.0        14/05/2012   AVT    12. 22237: LCOL_A002-Incidencias de QT sobre el reaseguro proporcional QT:4564
      13.0        25/07/2012   AVT    13. 22686: LCOL_A004-Cumulos anulados anteriormente a la alta de polizas
      14.0        27/07/2012   GAG    14. 0022666: LCOL_A002-Qtracker: 0004556: Cesion capitales en riesgo
      15.0        13/08/2012   AVT    15. 22660: CALI003-Incidencies amb el contracte de la reasseguran
      16.0        15/02/2013   DCT    16. 0025502: LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos
      17.0        04/03/2013   KBR    17. 0026142: LCOL_A004-Qtracker: 6428: Error al emitir certificado cero después de realizar un supl en un certif
      individual
      18.0        14/03/2013   KBR    18. 0026283: Incidencia de cúmulo para colectivos Liberty
      19.0        07/08/2013   AVT    19. 0026663: POSPG400-(POSPG400)- Parametrizacion Reaseguro, Coaseguro - Parametrizacion contratos (???)
      20.0        16/10/2013   MMM    20. 0026194_NOTA_0156003_Qtracker 0006484 Cesion de prima por emision
      21.0        28/10/2013   AVT    21. 0028492: LCOLF3BREA-Revisi?n de los contratos de REASEGURO F3B (NOTA:0156038)
      ***********************************************************************/
      lpleno NUMBER;
      lnmovigen cesionesrea.nmovigen%TYPE;
      perr       NUMBER := 0;
      codi_error NUMBER;
      w_fconini cesionesaux.fconini%TYPE;
      w_dias NUMBER;
      w_iprirea cesionesrea.icesion%TYPE;
      w_ipritarrea cesionesrea.ipritarrea%TYPE;
      w_idtosel cesionesrea.idtosel%TYPE;
      w_iextrea cesionesrea.iextrea%TYPE; --BUG 30326/171842 - DCT - 03/04/2014
      w_iextrap cesionesrea.iextrap%TYPE; --BUG 30326/171842 - DCT - 03/04/2014
      w_spleno codicontratos.spleno%TYPE;
      w_ipleno cesionesaux.ipleno%TYPE;
      w_ccalif1 cesionesaux.ccalif1%TYPE;
      w_ccalif2 cesionesaux.ccalif2%TYPE;
      w_icapital cesionesaux.icapital%TYPE;
      w_cgarant garanpro.cgarant%TYPE;
      w_trobat NUMBER(1);
      w_nriesgo cesionesaux.nriesgo%TYPE;
      w_scontra cesionesaux.scontra%TYPE;
      w_nversio cesionesaux.nversio%TYPE;
      w_scumulo cesionesaux.scumulo%TYPE;
      cum_capital cesionesaux.icapital%TYPE;
      w_icapaci contratos.icapaci%TYPE;
      w_ctiprea seguros.ctiprea%TYPE;
      w_nplenos tramos.nplenos%TYPE;
      w_impfac  NUMBER(15, 2);
      w_cestado NUMBER(2);
      pfacult cuafacul.sfacult%TYPE;
      pncesion cuafacul.ncesion%TYPE;
      w_plocal cuafacul.plocal%TYPE;
      w_sproces cesionesaux.sproces%TYPE;
      w_sseguro seguros.sseguro%TYPE;
      w_nmovimi cesionesaux.nmovimi%TYPE;
      w_pcedido contratos.pcedido%TYPE;
      w_cduraci seguros.cduraci%TYPE;
      w_ctipre_seg seguros.ctiprea%TYPE; -- Ind. tipus reaseguranca ->> CVALOR = 60
      w_ifacced cuafacul.ifacced%TYPE;
      w_porcgarant   NUMBER(5, 2);
      w_switchgarant NUMBER(1);
      w_capgarant    NUMBER;                  -- 25803: Ampliar los decimales NUMBER(15, 2);
      w_icapacigarant capgarant.icapaci%TYPE; -- 25803: Ampliar los decimales NUMBER(15, 2);
      w_porcaux NUMBER(5, 2);
      w_capmax  NUMBER; -- 25803: Ampliar los decimales  NUMBER(15, 2);
      w_cvidaga codicontratos.cvidaga%TYPE;
      w_nagrupa cesionesaux.nagrupa%TYPE;
      --w_nagrupavi    NUMBER(4); 13195 AVT 16-02-2010
      w_cgar garanseg.cgarant%TYPE;
      w_cforpag seguros.cforpag%TYPE;
      w_divisoranual NUMBER;
      -- Divisor prorrateos año bisiesto
      w_dias_origen NUMBER;
      w_fefecto seguros.fefecto%TYPE;
      w_fvencim seguros.fvencim%TYPE;
      lcforamor     NUMBER;
      lcapicum      NUMBER;
      lplecum       NUMBER;
      lcapacum      NUMBER;
      lassumir      NUMBER;
      lcapaci_cum   NUMBER;
      lcapcumtram   NUMBER;
      lcapcum_tot   NUMBER;
      lplecum_tot   NUMBER;
      w_captram_tot NUMBER;
      w_sproduc     NUMBER;
      w_cramo seguros.cramo%TYPE;
      w_cmodali seguros.cmodali%TYPE;
      w_ctipseg seguros.ctipseg%TYPE;
      w_ccolect seguros.ccolect%TYPE;
      w_cactivi seguros.cactivi%TYPE;
      w_cempres           seguros.cempres%TYPE := 24; --AMCY - 18/11/2019
      registre cesionesaux%ROWTYPE;
      w_nmovigen          NUMBER;
      avui                DATE;
      w_gar_princ         NUMBER; -- 21559 / 111590
      w_fac_princ         NUMBER; -- 22237
      w_registre          NUMBER := 0;
      w_capital           NUMBER := 0; -- 22237 AVT 15/05/2012
      w_capital_principal NUMBER;
      w_cdetces           NUMBER;                               -- 28492 AVT 13/11/2013
      v_hiha_ces          NUMBER       := 0;                    -- 21/01/2014 AVT
      vpar_traza          VARCHAR2(80) := 'TRAZA_CESIONES_REA'; -- 08/04/2014 AGG
      v_nom_paquete       VARCHAR2(80) := 'PAC_CESIONESREA';
      v_nom_funcion       VARCHAR2(80) := 'F_CESSIO_EST';
      v_base_rea          NUMBER       := 0; --AGG 15/04/2014

      --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
      w_moninst          monedas.cmonint%TYPE;
      w_monpol           monedas.cmonint%TYPE;
      --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros

      --INI BUG CONF-695  Fecha (22/05/2017) - HRE - Redistribucion reaseguro
      CURSOR cur_tiprea(pcempres NUMBER, pmotiu NUMBER, pcramo NUMBER, pfefecto DATE) IS
       SELECT c.ctiprea
           FROM codicontratos c, contratos v, agr_contratos a
          WHERE c.scontra = v.scontra
            AND c.scontra = a.scontra
            AND c.cempres = pcempres
            AND a.cgarant IS NULL
            AND(c.ctiprea = DECODE(NVL(pmotiu, 0), 11, 3)
                OR(DECODE(NVL(pmotiu, 0), 11, 1, 0) = 0
                   AND(c.ctiprea = 1
                       OR c.ctiprea = 2
                       OR c.ctiprea = 5)))--BUG CONF-250  Fecha (02/09/2016) - HRE - se incluye v_valor
            AND a.cramo = pcramo
            AND a.cmodali IS NULL
            AND a.ctipseg IS NULL
            AND a.ccolect IS NULL
            AND a.cactivi IS NULL
            AND v.fconini <= pfefecto
            AND(v.fconfin IS NULL
                OR v.fconfin > pfefecto)
            AND c.nconrel IS NULL;
      --FIN BUG CONF-695  - Fecha (22/05/2017) - HRE
      v_ctiprea codicontratos.ctiprea%TYPE;
      v_cramo agr_contratos.cramo%TYPE;

      CURSOR cur_aux_1
      IS
          SELECT    *
               FROM cesionesaux
              WHERE sproces = psproces
           ORDER BY (icapaci - icapital), cgarant DESC; -- 19484 AVT 02/01/2012

      CURSOR cur_aux_2
      IS
          SELECT    *
               FROM cesionesaux
              WHERE cestado = 0
               AND sproces  = psproces
           ORDER BY nriesgo, spleno, ccalif1, ccalif2, scontra, nversio, scumulo, nagrupa, cgarant;

      CURSOR cur_aux_3
      IS
          SELECT    cgarant, iprirea, icapital, ipritarrea, idtosel
               FROM cesionesaux
              WHERE NVL(nriesgo, 0)  = NVL(w_nriesgo, 0)
               AND NVL(spleno, 0)    = NVL(w_spleno, 0)
               AND NVL(ccalif1, ' ') = NVL(w_ccalif1, ' ')
               AND NVL(ccalif2, 0)   = NVL(w_ccalif2, 0)
               AND NVL(scontra, 0)   = NVL(w_scontra, 0)
               AND NVL(nversio, 0)   = NVL(w_nversio, 0)
               AND NVL(scumulo, 0)   = NVL(w_scumulo, 0)
               AND NVL(nagrupa, 0)   = NVL(w_nagrupa, 0)
               AND cgarant          IS NULL
               AND cestado           = 1
               AND sproces           = psproces;

      CURSOR cur_aux_4
      IS
          SELECT    cgarant, iprirea, icapital, ipritarrea, idtosel
               FROM cesionesaux
              WHERE NVL(nriesgo, 0)  = NVL(w_nriesgo, 0)
               AND NVL(spleno, 0)    = NVL(w_spleno, 0)
               AND NVL(ccalif1, ' ') = NVL(w_ccalif1, ' ')
               AND NVL(ccalif2, 0)   = NVL(w_ccalif2, 0)
               AND NVL(scontra, 0)   = NVL(w_scontra, 0)
               AND NVL(nversio, 0)   = NVL(w_nversio, 0)
               AND NVL(scumulo, 0)   = NVL(w_scumulo, 0)
               AND NVL(nagrupa, 0)   = NVL(w_nagrupa, 0)
               AND cgarant          IS NOT NULL
               AND NVL(cgarant, 0)  <> NVL(w_cgarant, 0)
               AND cestado           = 1
               AND sproces           = psproces;

      CURSOR cur_aux_5
      IS
          SELECT    cgarant, iprirea, icapital, ipritarrea, idtosel
               FROM cesionesaux
              WHERE NVL(nriesgo, 0)  = NVL(w_nriesgo, 0)
               AND NVL(spleno, 0)    = NVL(w_spleno, 0)
               AND NVL(ccalif1, ' ') = NVL(w_ccalif1, ' ')
               AND NVL(ccalif2, 0)   = NVL(w_ccalif2, 0)
               AND NVL(scontra, 0)   = NVL(w_scontra, 0)
               AND NVL(nversio, 0)   = NVL(w_nversio, 0)
               AND NVL(scumulo, 0)   = NVL(w_scumulo, 0)
               AND NVL(nagrupa, 0)   = NVL(w_nagrupa, 0)
               AND cgarant          IS NOT NULL
               AND NVL(cgarant, 0)   = NVL(w_cgarant, 0)
               AND cestado           = 1
               AND sproces           = psproces;

      CURSOR cur_trams(wscontra NUMBER, wnversio NUMBER)
      IS
          SELECT    nplenos, DECODE(ctramo, 6, 0, ctramo) ctramo -- 28492 AVT 28/10/2013
               FROM tramos
              WHERE scontra = wscontra
               AND nversio  = wnversio;

      -- 21559 AVT 12/03/2012
      CURSOR garantia_principal(p_cgarant IN NUMBER, p_sproces IN NUMBER, p_sseguro IN NUMBER, p_nmovimi IN NUMBER, -- AVT 26/03/2012 per la migració sempre és
         -- el mateix procés
         p_motiu IN NUMBER)
      IS
          SELECT    *
               FROM cesionesrea c
              WHERE c.sproces = p_sproces
               AND c.sseguro  = p_sseguro
               AND c.cgarant  = p_cgarant
               AND nmovimi    = p_nmovimi
               AND cgenera    = p_motiu
           ORDER BY ctramo; -- AVT 14/03/2012

      -- BUG 32363 - DCT - 28/07/2014
      -- 22686 AVT 25/07/2012
      CURSOR riesgos_anul(p_cumul IN NUMBER)
      IS
         SELECT DISTINCT s.sseguro, s.fanulac
               FROM reariesgos r, seguros s, cesionesrea c
              WHERE r.scumulo = p_cumul
               AND r.scumulo  = c.scumulo
               AND r.sseguro  = c.sseguro
               AND r.sseguro  = s.sseguro
               AND s.fanulac IS NOT NULL
               AND freafin   IS NULL;

      -- *********************************************************************
      -- *********************************************************************
      -- *********************************************************************
      PROCEDURE cabfacul(
            regaux1 cur_aux_1%ROWTYPE)
      IS
         /**********************************************************************
         procediment CABFACUL per fer insert a capçalera de facultatiu (CUAFACUL)
         I A FACPENDIENTES ( si ja existeix, no fa res)...
         **********************************************************************/
         w_sfacult NUMBER(6);
         w_pfacced NUMBER(9, 6);
         w_ifacced cuafacul.ifacced%TYPE; -- 25803: Ampliar los decimales NUMBER(15, 2);
         w_controllat NUMBER(1);
         w_cramo      NUMBER(8);
         w_scontra    NUMBER(6);
         w_nversio    NUMBER(2);
         w_sproduc seguros.sproduc%TYPE;
      BEGIN
         ----dbms_outpuT.put_line('Entra a cabfacul');
         IF regaux1.scontra IS NULL THEN
            -- Busquem el ram per el SCONTRA ( si facultatiu pur)...
            IF ptablas = 'EST' THEN
               BEGIN -- Busquem el ram per el SCONTRA ( si facultatiu pur)...
                   SELECT    cramo, sproduc
                        INTO w_scontra, w_sproduc
                        FROM estseguros
                       WHERE sseguro = regaux1.sseguro;
               END;
            ELSIF ptablas = 'CAR' THEN
               BEGIN -- Busquem el ram per el SCONTRA ( si facultatiu pur)...
                   SELECT    cramo, sproduc
                        INTO w_scontra, w_sproduc
                        FROM seguros
                       WHERE sseguro = regaux1.sseguro;
               END;
            ELSE
               BEGIN -- Busquem el ram per el SCONTRA ( si facultatiu pur)...
                   SELECT    cramo
                        INTO w_scontra
                        FROM seguros
                       WHERE sseguro = regaux1.sseguro;
               END;
            END IF;

            w_nversio := 1;
         ELSE
            w_scontra := regaux1.scontra;
            w_nversio := regaux1.nversio;
         END IF;

         w_controllat := 0;

         BEGIN
             SELECT    COUNT( * )
                  INTO w_sfacult
                  FROM cuafacul
                  /* BUG 10462: ETM:16/06/2009:--ANTES--facpendientes*/
                 WHERE sseguro        = regaux1.sseguro
                  AND nriesgo         = regaux1.nriesgo
                  AND NVL(cgarant, 0) = NVL(regaux1.cgarant, 0)
                  AND nmovimi         = regaux1.nmovimi
                  AND cestado         = 1;
            /* BUG 10462: ETM:16/06/2009:--AÑADIMOS-- CESTADO=1-*/

            IF w_sfacult     > 0 THEN
               w_controllat := 1; -- Ja está a FACPENDIENTES...
            END IF;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
         WHEN OTHERS THEN
            perr := 105032;
         END;

         ----dbms_outpuT.put_line(' DINS DE CABFACUL garantia '||regaux1.cgarant);
         ----dbms_outpuT.put_line(' DINS DE CABFACUL el cumul és '||regaux1.scumulo);
         IF w_controllat        = 0 THEN -- Tenim que fer l'insert en FACPENDIENTES
            IF regaux1.scumulo IS NOT NULL THEN
               -- No existeix un registre de pendent i sí que forma cumul...
               -- Si ja existeix capçalera iniciada per el cumul, s'agafará
               -- el num. de cumul i es donará l'alta a FACPENDIENTES
               -- solsament...
               -- Si no existeix capçalera, es dona d'alta als dos llocs...
               ----dbms_outpuT.put_line(' cabfacul TE CUMUL ');
               BEGIN
                   SELECT    sfacult
                        INTO w_sfacult
                        FROM cuafacul
                       WHERE scumulo        = regaux1.scumulo
                        AND(cgarant         = regaux1.cgarant
                        OR regaux1.cgarant IS NULL)
                        AND cestado         = 1;

                  ----dbms_outpuT.put_line(' cabfacul TE QUADRE ');
                  w_controllat := 2; -- No hem de fer l'insert a CUAFACUL
               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
                  ----dbms_outpuT.put_line(' INsert pendent ');
               WHEN OTHERS THEN
                  perr := 104486;
               END;
            END IF;

            IF w_controllat = 0 THEN -- No tenim identificador de facultatiu
                SELECT    sfacult.NEXTVAL
                     INTO w_sfacult
                     FROM DUAL;
            END IF;

            IF w_controllat = 0 THEN
               -- Donem d'alta la capçalera nova a CUAFACUL
               IF regaux1.scontra IS NOT NULL THEN
                  BEGIN
                     BEGIN
                         SELECT    cempres, cramo, --ctiprea, 22660 AGM 13/08/2012
                              cmodali, ctipseg, ccolect, cactivi, sproduc
                              INTO w_cempres, w_cramo, --w_ctiprea,
                              w_cmodali, w_ctipseg, w_ccolect, w_cactivi, w_sproduc
                              FROM seguros
                             WHERE sseguro = regaux1.sseguro;
                     EXCEPTION
                     WHEN OTHERS THEN
                        perr := 101919;
                     END;

                     --BUG 21559 - INICIO - 23/05/2013 - DCT
                     IF NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 1
                        --BUG 21559 - FIN - 23/05/2013 - DCT
                        AND w_gar_princ <> regaux1.cgarant THEN -- 21559 / 111590
                        BEGIN
                            SELECT    ifacced, pfacced
                                 INTO w_ifacced, w_pfacced -- 24794 AVT 19/11/2012 (23/11/2012)
                                 FROM cuafacul c
                                WHERE (sseguro = regaux1.sseguro
                                 OR scumulo    = regaux1.scumulo)
                                 AND c.cgarant = w_gar_princ
                                 AND cestado   = 1;
                        EXCEPTION
                        WHEN OTHERS THEN
                           perr := 104486;
                        END;

                        -->DBMS_OUTPUT.put_line('>>> pfacced ' || w_pfacced);
                        -- 22237 AVT 14/05/2012 falta dividir per 100
                        --w_ifacced := regaux1.icapital * w_pfacced / 100; BUG: 22666

                        --25502/138082 - INICIO - DCT - 15/02/2013
                        w_pfacced := w_ifacced / w_capital_principal * 100;
                        --25502/138082 - FIN - DCT - 15/02/2013
                        w_ifacced := regaux1.icapital * w_ifacced / w_capital_principal;
                        -->DBMS_OUTPUT.put_line('>>> pfacced ' || w_pfacced);
                        -->DBMS_OUTPUT.put_line('>>> ifcaced ' || w_ifacced);
                     ELSE
                        --  En lugar de la capacidad màxima del registro, cogemos
                        --  la capacidad del cumulo
                        w_pfacced := (100 * (regaux1.icapital - lcapaci_cum) / regaux1.icapital);
                        w_ifacced := regaux1.icapital - lcapaci_cum;
                     END IF;
                     --regaux1.icapaci;
                     ----dbms_output.put_line ('regaux1.icapital ='||regaux1.icapital);
                     ----dbms_output.put_line ('lcapaci_cum ='||lcapaci_cum);
                     ----dbms_output.put_line ('regaux1.icapaci ='||regaux1.icapaci);
                     ----dbms_output.put_line ('ifacced ='||w_ifacced);
                     --regaux1.icapaci;
                     ----dbms_output.put_line ('regaux1.icapital ='||regaux1.icapital);
                     ----dbms_output.put_line ('lcapaci_cum ='||lcapaci_cum);
                     ----dbms_output.put_line ('regaux1.icapaci ='||regaux1.icapaci);
                     ----dbms_output.put_line ('ifacced ='||w_ifacced);
                  EXCEPTION
                  WHEN OTHERS THEN
                     w_pfacced := 0;
                     w_ifacced := 0;
                  END;
               ELSE
                  w_pfacced := 100;
                  w_ifacced := regaux1.icapital;
               END IF;

               ----dbms_outpuT.put_line ('pfacced '|| w_pfacced);
               ----dbms_outpuT.put_line ('ifcaced '||w_ifacced);
               -- 13946 AVT 06-04-2010 s'afegeix el SCONTRA i la NVERSIO.
               BEGIN -- Posem data final al quadre anterior...
                   UPDATE cuafacul
                     SET ffincuf            = regaux1.fconini
                       WHERE (sseguro       = regaux1.sseguro
                        OR scumulo          = NVL(regaux1.scumulo, - 1))
                        AND NVL(nriesgo, 0) = DECODE(scumulo, NULL, regaux1.nriesgo, 0) -- 15590 AVT 30-07-2010
                        AND(cgarant        IS NULL
                        OR cgarant          = regaux1.cgarant)
                        AND ffincuf        IS NULL
                        AND scontra         = w_scontra
                        AND nversio         = w_nversio;
               EXCEPTION
               WHEN OTHERS THEN
                  perr := 107512;
               END;

               BEGIN
                   INSERT
                        INTO cuafacul
                        (
                           sfacult, cestado, finicuf, cfrebor, scontra, nversio, sseguro, cgarant, ccalif1, ccalif2,
                           spleno, nmovimi, scumulo, nriesgo, ffincuf, plocal, fultbor, pfacced, ifacced, ncesion
                        )
                        VALUES
                        (
                           w_sfacult, 1, regaux1.fconini, 1, w_scontra, w_nversio, DECODE(regaux1.scumulo, NULL, regaux1.sseguro, NULL), regaux1.cgarant,
                           regaux1.ccalif1, regaux1.ccalif2, regaux1.spleno, regaux1.nmovimi, regaux1.scumulo, DECODE(regaux1.scumulo, NULL, regaux1.nriesgo,
                           NULL), NULL, NULL, NULL, w_pfacced, w_ifacced, 1
                        );
               EXCEPTION
               WHEN OTHERS THEN
                  perr := 104343;
               END;
            END IF;
         END IF;
      END cabfacul;

   -- *********************************************************************
   -- *********************************************************************
   -- *********************************************************************
   FUNCTION f_facult
      (
         psseguro IN NUMBER,
         pnriesgo IN NUMBER,
         pccalif1 IN VARCHAR2,
         pccalif2 IN NUMBER,
         pcgarant IN NUMBER,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pfinicuf IN DATE,
         pscumulo IN NUMBER,
         ptrovat OUT NUMBER,
         pcestado OUT NUMBER,
         pfacult OUT NUMBER,
         pifacced OUT NUMBER
      )
      RETURN NUMBER
   IS
      /***********************************************************************
      F_FACULT        : Buscar si existeix un facultatiu.
      ***********************************************************************/
      perr NUMBER := 0;

      CURSOR cur_facult
      IS
          SELECT    cestado, sfacult, ifacced
               FROM cuafacul c
              WHERE (sseguro = psseguro
               OR scumulo    = pscumulo)
               AND(nriesgo   = pnriesgo
               OR nriesgo   IS NULL)
               AND(ccalif1   = pccalif1
               OR ccalif1   IS NULL)
               AND(ccalif2   = pccalif2
               OR ccalif2   IS NULL)
               AND(cgarant   = pcgarant
               OR cgarant   IS NULL)
               AND(scontra   = pscontra
               OR pscontra  IS NULL
               OR pfdatagen <> f_sysdate) -- pfdatagen viene informado en la migración
               AND finicuf  <= pfinicuf
               AND(ffincuf   > pfinicuf
               OR ffincuf   IS NULL)
           ORDER BY sfacult DESC; --finicuf; DESC; -- 19484 AVT 02/01/2012
      -- Necessitem el registre correcte.
      -- 19484 AVT 02/01/2012 ja estem tractan els cúmuls en el primer cursor --
      /*CURSOR c_fac_cum(pscumulo IN NUMBER) IS
      SELECT *
      FROM cuafacul
      WHERE scumulo =  sseguro IN(SELECT sseguro
      FROM reariesgos
      WHERE scumulo = 4363
      AND freafin IS NULL); */
      -- fi 19484 AVT 02/01/2012
   BEGIN
      ptrovat  := 0;
      pcestado := NULL;
      pfacult  := NULL;

      --DBMS_OUTPUT.put_line(' CONTRACTE a f_facult ' || pscontra);
      --DBMS_OUTPUT.put_line(' GARNATIA a f_facult ' || pcgarant);
      FOR regfacult IN cur_facult
      LOOP
         ptrovat  := 1;
         pcestado := regfacult.cestado;
         pfacult  := regfacult.sfacult;
         pifacced := regfacult.ifacced;
         EXIT;
      END LOOP;

      --DBMS_OUTPUT.put_line(' ptrovat:' || ptrovat || ' pscumulo:' || pscumulo);
      -- si no l'he trobat, miro si hi ha alguna pòlissa del cumul
      -- amb quadre
      -- 19484 AVT 02/01/2012
      /* IF ptrovat = 0
      AND pscumulo IS NOT NULL THEN
      FOR v_fac_cum IN c_fac_cum(pscumulo) LOOP
      UPDATE cuafacul
      SET scumulo = pscumulo,
      sseguro = NULL
      WHERE sfacult = v_fac_cum.sfacult
      AND ffincuf IS NULL;
      ptrovat := 1;
      pcestado := v_fac_cum.cestado;
      pfacult := v_fac_cum.sfacult;
      pifacced := v_fac_cum.ifacced;
      --DBMS_OUTPUT.put_line(' pifacced:' || pifacced);
      EXIT;
      END LOOP;
      END IF;*/
      RETURN(perr);
   END f_facult;

-- *********************************************************************
-- *********************************************************************
-- *********************************************************************
--------------------------------------------------------------------------
--  Funció que fa l'insert
   FUNCTION f_insert_ces(
         pp_capces IN NUMBER,
         pp_tramo IN NUMBER,
         pp_facult IN NUMBER,
         pp_cesio IN NUMBER,
         pp_porce IN NUMBER,
         pp_sproduc IN NUMBER,
         pp_cgesfac IN NUMBER DEFAULT 0)
      RETURN NUMBER
   IS
      -- vsproduc       NUMBER; 13195 AVT 16-02-2010
      w_scesrea NUMBER(8);
      v_fconfin DATE;
      v_irecarg garanseg.irecarg%TYPE;   --08/05/2014 AGG
      v_iextrap garanseg.iextrap%TYPE;   --08/05/2014 AGG
      v_icapital garanseg.icapital%TYPE; --08/05/2014 AGG
      v_pcomext NUMBER;
      w_icomext NUMBER;
      --INICIO - BUG38692 - DCT - 17/11/2015.
      v_frenova seguros.frenova%TYPE;
      v_nrenova seguros.nrenova%TYPE;
      v_fefecto seguros.fefecto%TYPE;
      v_cramo seguros.cramo%TYPE;
      v_cmodali seguros.cmodali%TYPE;
      v_ctipseg seguros.ctipseg%TYPE;
      v_ccolect seguros.ccolect%TYPE;
      --FIN - BUG38692 - DCT - 17/11/2015.
   BEGIN
      --INICIO - BUG38692 - DCT - 17/11/2015. Si el pp_cgesfac = 1 quiere decir que hemos apretado el botón de Crear Facultativo
      --y por lo tanto no debemos crear las cesionesrea
      IF pp_cgesfac = 0 THEN
          SELECT    scesrea.NEXTVAL
               INTO w_scesrea
               FROM DUAL;

         -- BUG 0010844 - 14/09/2009 - FAL - Substituir f_round_forpag per f_round a f_insert_ces
         -->DBMS_OUTPUT.put_line('2.1 registre.iprirea:' || registre.iprirea);
         w_iprirea    := f_round(registre.iprirea * pp_porce, pmoneda);    -- INI BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
         w_ipritarrea := f_round(registre.ipritarrea * pp_porce, pmoneda); -- INI BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
         w_idtosel    := f_round(registre.idtosel * pp_porce, pmoneda);    -- INI BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
         w_iextrea    := f_round(registre.iextrea * pp_porce, pmoneda);    --BUG 30326/171842 - DCT - 03/04/2014
         w_iextrap    := f_round(registre.iextrap * pp_porce, pmoneda);    --BUG 30326/171842 - DCT - 03/04/2014

         -- FI BUG 0010844 - 14/09/2009 - FAL
         -->DBMS_OUTPUT.put_line('>>> Registre.CGARANT:' || registre.cgarant);
         -->DBMS_OUTPUT.put_line(' w_iprirea :' || w_iprirea || ' registre.iprirea:'
         --> || registre.iprirea || ' pp_porce:' || pp_porce || ' pmoneda:'
         -->|| pmoneda);
         ----dbms_outpuT.put_line('dif data 1 '||TO_CHAR(regaux1.fconini,'dd/mm/yyyy')||'-'|| TO_CHAR(w_fconfin,'dd/mm/yyyy'));
         -- 44.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Inicio
         --codi_error := f_difdata(registre.fconini, registre.fconfin, 1, 3, w_dias);

         --AGG 06/03/2014 Se puede dar el caso de que el campo fconfin no esté actualizado
         --ya que se calcula en un paso posterior a este, si es así, lo calculamos de la misma manera
         --que se calcula posteriormente
         IF registre.fconfin IS NULL THEN
             SELECT    DECODE(fcaranu, NULL, fvencim, fcaranu), frenova, nrenova, fefecto, cramo, cmodali, ctipseg, ccolect
                  INTO v_fconfin, v_frenova, v_nrenova, v_fefecto, v_cramo, v_cmodali, v_ctipseg, v_ccolect
                  FROM seguros
                 WHERE sseguro = registre.sseguro;

            --INICIO - BUG38692 - DCT - 17/11/2015
            IF v_fconfin IS NULL THEN
               /*Calculamos la fecha de vencimiento. Para la ppoliza propuesta de alta la fcaranu aun no esta calculada, por
               esto llamamos a la función para que la calcule*/
               v_fconfin := f_calcula_vto_poliza(v_frenova, v_nrenova, v_fefecto, v_cramo, v_cmodali, v_ctipseg, v_ccolect);
            END IF;

            --FIN - BUG38692 - DCT - 17/11/2015
            codi_error := f_difdata(registre.fconini, v_fconfin, 3, 3, w_dias);
         ELSE
            codi_error := f_difdata(registre.fconini, registre.fconfin, 3, 3, w_dias);
         END IF;

         -- 44.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Fin

         -- nos indica que sí se deberían prorratear los movimientos de suplementos.
         -- No hacemos diferencias por forma de pago (entre f.ini i fin max 1 año).

         -- BUG 0011512 - 21/10/2009 - FAL - Covertir el paràmetre de instal.lació de prorrateig en la N.P per un parproducto
         IF (pmotiu IN(9, 4, 1, 3)) THEN -- Añadimos el pmotiu 1
            -- BUG 0010844 - 31/08/2009 - FAL - Afegir prorrateig de la cessio en la Nova Producció unicament per CIV. Añadimos el pmotiu 3
            IF pmotiu                                                   = 3 AND -->> Per defecte tots els productes prorrategen <<--
               NVL(f_parproductos_v(pp_sproduc, 'NO_PRORRATEA_REA'), 0) = 1 THEN
               NULL; -- >> NO PRORRATEJA!
            ELSE
               -- FI BUG 0011512 - 21/10/2009 - FAL
               -- 44.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Inicio
               --codi_error := f_difdata(registre.fconini, ADD_MONTHS(registre.fconini, 12), 1, 3, w_divisoranual);   --Año bisiesto
               codi_error := f_difdata(registre.fconini, ADD_MONTHS(registre.fconini, 12), 3, 3, w_divisoranual);
               -- 44.0 - 16/10/2013 - MMM - 0026194: NOTA_0156003_Qtracker 0006484 Cesion de prima por emision - Fin
               -- BUG 0010844 - 14/09/2009 - FAL - Substituir f_round_forpag per f_round a f_insert_ces
               w_iprirea    := f_round((w_iprirea * w_dias) / w_divisoranual, pmoneda);    -- INI BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
               w_ipritarrea := f_round((w_ipritarrea * w_dias) / w_divisoranual, pmoneda); -- INI BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
               w_idtosel    := f_round((w_idtosel * w_dias) / w_divisoranual, pmoneda);    -- INI BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
               w_iextrea    := f_round((w_iextrea * w_dias) / w_divisoranual, pmoneda);    --BUG 30326/171842 - DCT - 03/04/2014
               w_iextrap    := f_round((w_iextrap * w_dias) / w_divisoranual, pmoneda);    --BUG 30326/171842 - DCT - 03/04/2014
               -- FI BUG 0010844 - 14/09/2009 - FAL
            END IF;
         END IF;

         --08/05/2014 AGG Añadimos la comisión de la extra prima
         BEGIN
             SELECT    irecarg, iextrap, icapital
                  INTO v_irecarg, v_iextrap, v_icapital
                  FROM garanseg
                 WHERE sseguro = registre.sseguro
                  AND cgarant  = registre.cgarant;

             SELECT    pcomext
                  INTO v_pcomext
                  FROM contratos
                 WHERE scontra = registre.scontra
                  AND nversio  = registre.nversio;

            --Comisión extra prima
            --(Extra prima cedia por salud + Valor extra prima cedida por ocupación) * %Comisión extraprima
            w_icomext := (v_irecarg + (v_iextrap * v_icapital)) * v_pcomext;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            w_icomext := 0;
         WHEN OTHERS THEN
            w_icomext := 0;
         END;

         --FIN AGG 08/05/2014
          INSERT
               INTO cesionesrea
               (
                  scesrea, ncesion, icesion, icapces, sseguro, nversio, scontra, ctramo, sfacult, nriesgo,
                  icomisi, icomreg, scumulo, cgarant, spleno, ccalif1, ccalif2, fefecto, fvencim, pcesion,
                  sproces, cgenera, fgenera, nmovimi, ipritarrea, idtosel, psobreprima, cdetces, fanulac, fregula,
                  nmovigen, ipleno, icapaci, iextrea,
                  -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                  iextrap, itarifrea,
                  --08/05/2014 AGG se añade la comisión de la extra prima
                  icomext
               )
               -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
               VALUES
               (
                  w_scesrea, pp_cesio, w_iprirea, pp_capces, registre.sseguro, DECODE(registre.cfacult, 0, registre.nversio, NULL), DECODE(registre.cfacult, 0,
                  registre.scontra, NULL), DECODE(pp_tramo, 6, 0, 7, 0, 8, 0, pp_tramo), -- 26663 AVT 08/07/2013 es guarden els trams com a propis,
                  pp_facult, registre.nriesgo, NULL, NULL, registre.scumulo, registre.cgarant, DECODE(registre.cfacult, 0, registre.spleno, NULL), DECODE(
                  registre.cfacult, 0, registre.ccalif1, NULL), DECODE(registre.cfacult, 0, registre.ccalif2, NULL), registre.fconini, registre.fconfin, (
                  pp_porce * 100), registre.sproces, pmotiu, avui, registre.nmovimi, w_ipritarrea, w_idtosel, registre.psobreprima, registre.cdetces,
                  registre.fanulac, registre.fregula, w_nmovigen, registre.ipleno, registre.icapaci, w_iextrea, --registre.iextrea, --BUG 30326/171842 - DCT -
                  -- 03/04/2014
                  -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                  --registre.iextrap,
                  w_iextrap, --BUG 30326/171842 - DCT - 03/04/2014
                  registre.itarifrea,
                  --08/05/2014 AGG
                  w_icomext
               );
      END IF; --FIN - BUG38692 - DCT - 17/11/2015

      -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
      RETURN(0);
   EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'f_cessio', 1, 'f_insert_ces', SQLERRM);
      perr := 104692;
      RETURN(perr);
   END f_insert_ces;

--------------------------------------------------------------------------
   FUNCTION f_ces
      (
         pnnumlin IN NUMBER,
         pmotiu IN NUMBER,
         pfacult IN NUMBER,
         pnmovigen IN NUMBER,
         psproduc IN NUMBER, -- 13195 AVT 16-02-2010 afegitS SPRODUC I CTIPREA
         pctiprea IN NUMBER, -- de CODICONTRATOS
         pctipre_seg IN NUMBER
      ) -- de SEGUROS
      RETURN NUMBER
   IS
      /***********************************************************************
      F_CES        : Realitza realment la cessió, creant registres
      a "CESIONESREA".
      ***********************************************************************/
      perr NUMBER := 0;
      --      registre       cesionesaux%ROWTYPE;
      --w_ctiprea      NUMBER(2); 13195 AVT 16-02-2010
      w_captram  NUMBER; -- 25803: Ampliar los decimales NUMBER(15, 2);
      w_resto    NUMBER; -- 25803: Ampliar los decimales NUMBER(15, 2);
      w_volta    NUMBER(2);
      w_yacedido NUMBER;                  -- 25803: Ampliar los decimales NUMBER(15, 2);
      w_porce    NUMBER;                  -- Falta de precisión NUMBER (10, 7);
      w_iprirea cesionesaux.iprirea%TYPE; -- 25803: Ampliar los decimales NUMBER(15, 2);
      w_res     NUMBER;                       -- 25803: Ampliar los decimales NUMBER(15, 2);
      w_scesrea NUMBER(8);
      w_nomes00 NUMBER(1);
      --w_ctipre       NUMBER(1); 13195 AVT 16-02-2010
      w_cramo     NUMBER(8);
      w_icapital2 NUMBER; -- 25803: Ampliar los decimales NUMBER(15, 2);
      w_ffalseado NUMBER(1);
      w_ifacced cuafacul.ifacced%TYPE; -- 25803: Ampliar los decimales NUMBER(15, 2);
      w_norden tramos.norden%TYPE;
      lcapcum       NUMBER;
      lplecum       NUMBER;
      lcapacum      NUMBER;
      lcaptram      NUMBER;
      lcapcum_tot   NUMBER;
      lplecum_tot   NUMBER;
      w_captram_tot NUMBER;
      w_contgar     NUMBER;
      w_cramo seguros.cramo%TYPE;
      w_cmodali seguros.cmodali%TYPE;
      w_ctipseg seguros.ctipseg%TYPE;
      w_ccolect seguros.ccolect%TYPE;
      w_cactivi seguros.cactivi%TYPE;
      w_cempres seguros.cempres%TYPE;
      hiha_formula NUMBER;      -- 22660 AVT 13/08/2012
      v_base_rea   NUMBER := 0; -- AGG 15/04/2014

      --Ini Bug 33993-214688 KJSC 25/09/2015 TODO CEDE AL CONTRATO INDEPENDIENTEMENTE DE SI SUPERA
      /*CURSOR cur_trams(wscontra NUMBER, wnversio NUMBER) IS
      SELECT   scontra, nversio, DECODE(ctramo, 6, 0, ctramo) ctramo, itottra, norden,
      ncesion   -- 28492 AVT 28/10/2013
      FROM tramos
      WHERE scontra = wscontra   --registre.scontra
      AND nversio = wnversio   --registre.nversio
      ORDER BY norden;*/
      CURSOR cur_trams(wscontra NUMBER, wnversio NUMBER)
      IS
          SELECT    t.scontra, t.nversio, DECODE(t.ctramo, 6, 0, t.ctramo) ctramo, t.itottra, t.norden, t.ncesion, DECODE(t.norden,
               (SELECT    MAX(t2.norden)
                     FROM tramos t2
                    WHERE t2.scontra = t.scontra
                     AND t2.nversio  = t.nversio
               ), 'F', '') ulttram,
               (SELECT    SUM(t3.itottra)
                     FROM tramos t3
                    WHERE t3.scontra = t.scontra
                     AND t3.nversio  = t.nversio
                     AND t3.norden   < t.norden
               ) restcapaci
               FROM tramos t
              WHERE t.scontra = wscontra --registre.scontra
               AND t.nversio  = wnversio --registre.nversio
           ORDER BY t.norden;
         --Fin Bug 33993-214688 KJSC 25/09/2015 TODO CEDE AL CONTRATO INDEPENDIENTEMENTE DE SI SUPERA
      BEGIN
         avui       := pfdatagen;
         w_nmovigen := pnmovigen;

          SELECT    *
               INTO registre
               FROM cesionesaux
              WHERE nnumlin = pnnumlin
               AND sproces  = psproces;

         -- 22660 AVT 16-08-2012 ho canviem de lloc
          SELECT    cempres
               INTO w_cempres
               FROM seguros seg
              WHERE seg.sseguro = registre.sseguro;

         IF registre.cfacult    = 0 THEN -- No es un facultatiu forçat...
            --   Aquí mirem si ja existeix un quadre de facultatiu per l'assegurança
            --   amb un import superior al que en principi li tocaria (capital pòlissa -
            --   capacitat contracte). Si existeix forçarem les quantitats que van contra
            --   el contracte en funció del import d'aquest facultatiu (w_ffalseado = 1)...
            --   També forçarem el facultatiu si es un cas de tipus "embarcacions" amb
            --   capacitats a nivell de garantia (w_switchgarant = 1)...
            w_icapital2 := registre.icapital;
            w_ifacced   := NULL;
            w_ffalseado := 0;

            ----dbms_outpuT.put_line(' F_CES capital garantia '||registre.cgarant||' = '||registre.icapital);
            IF registre.icapital > registre.icapaci THEN -- Es necessitarà facultatiu...
               BEGIN
                   SELECT    ifacced
                        INTO w_ifacced
                        FROM cuafacul
                       WHERE sseguro = registre.sseguro
                        AND nriesgo  = registre.nriesgo
                        AND cgarant  = registre.cgarant
                        AND cestado  = 2
                        AND finicuf <= registre.fconini
                        AND(ffincuf  > registre.fconini
                        OR ffincuf  IS NULL);
               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  w_ifacced := NULL;
               WHEN OTHERS THEN
                  perr := 104486;
                  RETURN(perr);
               END;

               IF w_ifacced   IS NOT NULL AND w_ifacced > (registre.icapital - registre.icapaci) THEN
                  w_icapital2 := registre.icapital - w_ifacced;
                  w_ffalseado := 1;
               END IF;

               --agg 15/04/2014
               v_base_rea   := NVL(pac_parametros.f_parproducto_n(w_sproduc, 'CESION_BASE_REA'), 0);

               IF v_base_rea = 1 THEN
                  p_tab_error(f_sysdate, f_user, 'pac_cesionesrea', 11, 'pasa por aqui wffalseado', NULL);
                  w_icapital2 := registre.icapital - w_ifacced;
                  w_ffalseado := 1;
               END IF;
               --fin agg 15/04/2014
            END IF;

            w_nomes00  := 0;
            w_volta    := 0;
            w_yacedido := 0;

            ----dbms_outpuT.put_line(' ctiprea '||w_ctiprea);
            -------------------------
            -- Ple net de retenció --
            -------------------------
            IF pctiprea IN(2, 3) THEN -- Creació tram 00... 28492 AVT 28/10/2013
               w_volta := 1;

               -- Si te cúmul, caldrà anar a mirar què s'ha assumit d'aquest cúmul
               IF registre.scumulo IS NOT NULL THEN
                  ----dbms_outpuT.put_line(' TE cumul '||registre.scumulo||'-'||registre.cgarant||'-'||registre.ipleno||'-'||registre.icapaci);
                  -- Calculem el capital assumit, el ple màxim i la capacitat màxima
                  perr := pac_cesionesrea.f_ple_cumul(registre.sseguro, registre.scumulo, registre.cgarant, registre.fconini, lcapcum, lplecum, lcapacum);

                  ----dbms_outpuT.put_line(' ple_cumul: '||lcapcum||'-'||lplecum||'-'||lcapacum);
                  IF perr <> 0 THEN
                     RETURN perr;
                  END IF;

                  -- Cal actualitzar el valor del ple amb el màxim del cúmul
                  IF NVL(lplecum, 0)  > registre.ipleno THEN
                     registre.ipleno := lplecum;
                  END IF;

                  -- Cal actualitzar el valor de la capacitat amb el màxim del cúmul
                  IF NVL(lcapacum, 0)  > registre.icapaci THEN
                     registre.icapaci := lcapacum;
                  END IF;

                  -- BUG 9704 - 15/04/09 - ICV - Cambio del parametro REACUMGAR por REACUM de parempresas.
                  -- 22660 AVT 16-08-2012 ho canviem de lloc
                  --               SELECT cempres
                  --                 INTO w_cempres
                  --                 FROM seguros seg
                  --                WHERE seg.sseguro = registre.sseguro;

                  --  Calculamos aquí el número de garantias
                  IF NVL(pac_parametros.f_parempresa_n(w_cempres, 'REACUM'), 0) = 1 THEN
                     --IF f_parinstalacion_n ('REACUMGAR') = 1 THEN
                     --FI BUG 9704  - 15/04/09 – ICV
                     -- Dividir capital fins el ple pel número de garanties acumulables per cumul, segons F_Pargaranpro_v('REACUMGAR')
                     -- (mort amb mort i IAC amb IAC) de la pòlissa tractada --> JGR
                      SELECT    COUNT(DISTINCT c.cgarant)
                           INTO w_contgar
                           FROM seguros s, cesionesaux c, reariesgos r
                          WHERE sproces  = psproces
                           AND(c.fanulac > registre.fconini
                           OR c.fanulac IS NULL)
                           AND(c.fregula > registre.fconini
                           OR c.fregula IS NULL)
                           AND r.scumulo = c.scumulo
                           AND r.sseguro = c.sseguro
                           AND(r.freafin > registre.fconini
                           OR r.freafin IS NULL)
                           AND r.sseguro = registre.sseguro
                           AND s.sseguro = c.sseguro
                           AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant,
                           'REACUMGAR'), c.cgarant) = NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro,
                           r.nriesgo), registre.cgarant, 'REACUMGAR'), registre.cgarant); -- 15007 AVT 23-06-2010 afegit el control del NVL

                     IF NVL(w_contgar, 0) = 0 THEN
                        w_contgar        := 1;
                     END IF;

                     lcapcum := lcapcum / w_contgar;
                  END IF;

                  w_captram := registre.ipleno - lcapcum;

                  ----dbms_outpuT.PUT_LINE(' ------------ PLE '||REGISTRE.IPLENO);
                  ----dbms_outpuT.PUT_LINE(' ------------ CAPCUM '||LCAPCUM);
                  ----dbms_outpuT.PUT_LINE(' ------------ CAPITAL DEL TRAM '||W_CAPTRAM);
                  IF w_captram  < 0 THEN
                     w_captram := 0;
                  END IF;

                  IF w_captram > 0 THEN
                     -- Una vegada trobat el capital que pot cedir la garantia(ella sola)
                     -- dins el cúmul, mirem la totalitat de les garanties que
                     -- van juntes més les de la pròpia pòlissa (no la garantia que tractem)
                     perr := pac_cesionesrea.f_ple_cumul_tot(registre.sseguro, registre.scumulo, registre.cgarant, registre.fconini, registre.scontra,
                     registre.nversio, lcapcum_tot, lplecum_tot);

                     ----dbms_outpuT.PUT_LINE('RETURN de ple_cumul_tot '||perr||' '||lcapcum_tot||' '||lplecum_tot);
                     IF perr <> 0 THEN
                        RETURN perr;
                     END IF;

                     w_captram_tot    := lplecum_tot - lcapcum_tot;

                     IF w_captram_tot  < 0 THEN
                        w_captram_tot := 0;
                     END IF;

                     -- BUG 9704 - 15/04/09 - ICV - Cambio del parametro REACUMGAR por REACUM de parempresas.
                     -- 22660 AVT 16-08-2012 ho canviem de lloc
                     --                  SELECT cempres
                     --                    INTO w_cempres
                     --                    FROM seguros seg
                     --                   WHERE seg.sseguro = registre.sseguro;
                     IF NVL(pac_parametros.f_parempresa_n(w_cempres, 'REACUM'), 0) = 1 THEN
                        --IF f_parinstalacion_n('REACUMGAR') = 1 THEN   -- DESDE
                        --FI BUG 9704  - 15/04/09 – ICV
                        w_captram_tot := w_captram_tot / w_contgar;
                     END IF; -- HASTA

                     -- Ens quedem amb l'import menor
                     IF w_captram_tot < w_captram THEN
                        -- si és menor canviem el valor del capital del tram
                        w_captram := w_captram_tot;
                        --ELSE
                        -- si és més gran ja és correcte assumuir w_captram
                     END IF;
                  END IF;
               ELSE
                  w_captram := registre.ipleno;
               END IF;

               --NUNUw_resto := registre.icapital - registre.ipleno;
               w_resto := registre.icapital - w_captram;

               ----dbms_outpuT.put_line('cap tram '||w_captram);
               ----dbms_outpuT.put_line(' Resto per tram 0 '||w_resto);
               IF w_resto  > 0 THEN
                  w_porce := w_captram / registre.icapital;
                  -->DBMS_OUTPUT.put_line('1. registre.iprirea:' || registre.iprirea);
                  perr    := f_insert_ces(w_captram, 00, NULL, 0, w_porce, psproduc, pcgesfac); -- 13195 AVT 16-02-2010

                  IF perr <> 0 THEN
                     RETURN perr;
                  END IF;

                  w_yacedido := w_yacedido + w_captram;
               ELSE
                  w_nomes00 := 1;
                  w_porce   := 1;

                  --w_res := registre.icapital;

                  --IF registre.icapital = 0 THEN
                  --w_porce := 1;
                  --ELSE
                  --   w_porce := w_res / registre.icapital;
                  --END IF;
                  -->DBMS_OUTPUT.put_line('2. registre.iprirea:' || registre.iprirea);
                  IF pctiprea = 3 AND registre.icapital = 0 AND registre.iprirea = 0 THEN --AVT 28/07/2014
                     NULL;
                  ELSE
                     perr    := f_insert_ces(registre.icapital, 00, NULL, 0, w_porce, psproduc, pcgesfac); -- 13195 AVT 16-02-2010

                     IF perr <> 0 THEN
                        RETURN perr;
                     END IF;
                  END IF;
               END IF;
            END IF;

            IF w_nomes00 = 0 THEN --> Resto ya es <= 0
               ----dbms_outpuT.put_line(' NOOOOO  NOMES 00');
               IF pctipre_seg = 1 OR pctipre_seg = 3 THEN -- REASEGURO QUE NUNCA SE PASA DE
                  BEGIN                                   -- CAPACIDAD...SE FUERZA...
                      SELECT    MAX(norden)
                           INTO w_norden
                           FROM tramos
                          WHERE scontra = registre.scontra
                           AND nversio  = registre.nversio;
                  END;
               ELSE
                  w_norden := NULL;
               END IF;

               FOR regtrams IN cur_trams(registre.scontra, registre.nversio)
               LOOP
                  --      El importe del primer tramo depende del número de garantías de la póliza
                  --       por lo que el número de tramos no nos vale el precalculado en tabla de tramos
                  --       optamos por informar simpre el capital del tramo final con el resto.
                  --       Trozo comentado DESDE (*)
                  --       w_captram := w_icapital2;   -- Descomentado después no hace tramos 05 facultativo

                  -- Si te cúmul, calcularem el capital
                  -- que s'ha assignat en aques tram, i deixarem com a
                  -- capacitat el que sobri
                  --dbms_outpuT.put_line('---->> 4. scontra:' || registre.scontra
                  --|| ' regtrams.ctramo:' || regtrams.ctramo);
                  IF registre.scumulo IS NOT NULL THEN
                     --perr :=0;
                     lcaptram          := 0;

                     IF regtrams.ctramo > 0 THEN -- 28777 AVT 13-11-13
                        perr           := pac_cesionesrea.f_captram_cumul(registre.sseguro, registre.scumulo, registre.cgarant, registre.fconini,
                        regtrams.ctramo, registre.scontra, registre.nversio, lcaptram, registre.ipleno);

                        IF perr <> 0 THEN
                           RETURN perr;
                        END IF;
                     END IF;

                     ----dbms_outpuT.put_line('registre.ipleno='||registre.ipleno||' regtrams.nplenos='||regtrams.nplenos||' lcaptram='||lcaptram);
                     -- CPM 26/10/06: Se modifica el calculo
                     --w_captram := (registre.ipleno * regtrams.nplenos) - lcaptram;
                     -- BUG: 12971 05-02-2010 AVT per productes que no tarifiquen és el captial del tram del contracte
                     -- BUG: 13195 16-02-2010 AVT depenent del tipus de reassegurança
                     IF NVL(f_parproductos_v(w_sproduc, 'NO_REA_SGT'), 0) = 1 OR pctiprea = 1 THEN
                        w_captram                                        := regtrams.itottra - lcaptram;
                        --dbms_outpuT.put_line('5. w_captram:' || w_captram);
                     ELSE
                        w_captram := (registre.icapaci - NVL(registre.ipleno, 0)) - lcaptram; -- 28492 AVT 28/10/2013
                        --dbms_outpuT.put_line('6. w_captram:' || w_captram);
                     END IF;

                     IF w_captram  < 0 THEN
                        w_captram := 0;
                     END IF;
                  ELSE
                     IF w_norden IS NULL OR regtrams.norden <> w_norden THEN
                        --w_captram := registre.ipleno * regtrams.nplenos;
                        -- BUG: 12971 05-02-2010 AVT per productes que no tarifiquen és el captial del tram del contracte
                        -- BUG: 13195 16-02-2010 AVT depenent del tipus de reassegurança
                        --dbms_outpuT.put_line('7. w_sproduc:' || w_sproduc);
                        --dbms_outpuT.put_line('7. pctiprea:' || pctiprea);
                        --dbms_outpuT.put_line('7. pctiprea:' || pctiprea);
                        IF NVL(f_parproductos_v(w_sproduc, 'NO_REA_SGT'), 0) = 1 OR pctiprea = 1 THEN
                           -- 16263 AVT 08-10-2010
                           IF registre.icapaci < regtrams.itottra THEN
                              w_captram       := registre.icapaci;
                           ELSE
                              --Ini Bug 33993-214688 KJSC 25/09/2015 TODO CEDE AL CONTRATO INDEPENDIENTEMENTE DE SI SUPERA
                              IF regtrams.ulttram = 'F' THEN
                                 w_captram       := registre.icapaci - NVL(regtrams.restcapaci, 0); -- AVT BUG-0040378 03/02/2016
                              ELSE
                                 w_captram := regtrams.itottra;
                              END IF;
                              --Fin Bug 33993-214688 KJSC 25/09/2015 TODO CEDE AL CONTRATO INDEPENDIENTEMENTE DE SI SUPERA
                           END IF;

                           IF pctiprea = 3 THEN
                              --w_captram := registre.icapaci;   -- 002666325/07/2013 capacitat del XL ??????????????????????
                              w_captram := registre.icapaci - NVL(registre.ipleno, 0); -- 31921/0187652 AVT 18/09/2014
                           END IF;
                           --w_captram := regtrams.itottra;
                           --dbms_outpuT.put_line('7. w_captram:' || w_captram);
                        ELSE
                           w_captram := registre.icapaci - NVL(registre.ipleno, 0); -- 28492 AVT 28/10/2013

                           --dbms_outpuT.put_line('8. w_captram:' || w_captram);

                           -- BUG: 12682 AVT 18-03-2010 en el cas d'haver-hi més d'un tram en un ple net de retenció
                           IF w_captram > regtrams.itottra THEN
                              ---------------------------------------------------------------
                              -- 22660 AVT 13/08/2012 En cas que el ple estigui Formulat: ---
                              -- hem de seguir restant el ple. La manera de definir els   ---
                              -- trams del contractes és diferent_ SUM(ITOTTRA) = ICAPACI ---
                              ---------------------------------------------------------------
                              IF NVL(pac_parametros.f_parempresa_n(w_cempres, 'SUM_TRAM_IGUAL_CAPIT'), 0) = 1 THEN
                                 hiha_formula                                                            := 0;

                                 BEGIN
                                     SELECT    COUNT( * )
                                          INTO hiha_formula
                                          FROM reaformula
                                         WHERE ccampo = 'IPLENO'
                                          AND scontra = registre.scontra
                                          AND nversio = registre.nversio
                                          AND cgarant = registre.cgarant;
                                 EXCEPTION
                                 WHEN NO_DATA_FOUND THEN
                                    hiha_formula := 0;
                                 WHEN OTHERS THEN
                                    perr := 108423;
                                    RETURN(perr);
                                 END;

                                 IF hiha_formula    = 0 THEN
                                    w_captram      := regtrams.itottra;
                                 ELSIF hiha_formula = 1 AND(regtrams.itottra + registre.ipleno) <= w_ipleno THEN
                                    w_captram      := w_ipleno - registre.ipleno;
                                 ELSE
                                    w_captram := regtrams.itottra - registre.ipleno;
                                 END IF;
                                 -- 22660 AVT 13/08/2012 FI -----------------------------------
                              ELSE
                                 w_captram := regtrams.itottra;
                              END IF;
                           END IF;
                           --dbms_outpuT.put_line('9. w_captram:' || w_captram);
                        END IF;
                     ELSE
                        IF regtrams.norden = w_norden THEN
                           w_captram      := w_icapital2;
                        END IF;
                     END IF;
                  END IF;

                  --       Trozo comentado HASTA (*)

                  ----dbms_outpuT.put_line(' CAPITAL DEL TRAM '||W_CAPTRAM);
                  IF w_switchgarant = 1 THEN -- CASO ESPECIAL TIPO "EMBARCACIONES"...
                     w_icapital2   := registre.icapaci;
                  END IF;

                  ----dbms_outpuT.put_line(' VOLTA '||W_VOLTA);
                  IF w_volta  = 0 THEN
                     w_resto := w_icapital2 - w_captram;
                     w_volta := 1;
                  ELSE
                     w_resto := w_resto - w_captram;
                  END IF;

                  ----dbms_outpuT.put_line(' RESTO '||W_RESTO);
                  IF w_resto  > 0 THEN
                     w_porce := w_captram / registre.icapital;

                     -->DBMS_OUTPUT.put_line('3. registre.iprirea:' || registre.iprirea);
                     IF --w_porce = 0
                        --AND NVL(registre.scumulo, 0) <> 0 AVT 13/11/2013 TIREM ENREA EL CANVI DEL 28/10/2013 PER POS
                        w_porce > 0                                                                                            -- 13-11-13
                        THEN                                                                                                   -- 28492 AVT 28/10/2013
                        perr    := f_insert_ces(w_captram, regtrams.ctramo, NULL, regtrams.ncesion, w_porce, psproduc, pcgesfac); -- 13195 AVT 16-02-2010

                        IF perr <> 0 THEN
                           RETURN perr;
                        END IF;

                         UPDATE tramos
                           SET ncesion     = (NVL(regtrams.ncesion, 0) + 1)
                             WHERE scontra = regtrams.scontra
                              AND nversio  = regtrams.nversio
                              AND ctramo   = DECODE(pctiprea, 3, 6, regtrams.ctramo); -- 28492 AVT 28/10/2013

                        w_yacedido        := w_yacedido + w_captram;
                     END IF;
                  ELSE
                     w_res               := w_icapital2 - w_yacedido;

                     IF registre.icapital = 0 THEN
                        w_porce          := 1;
                     ELSE
                        w_porce := w_res / registre.icapital;
                     END IF;

                     -->DBMS_OUTPUT.put_line('4. registre.iprirea:' || registre.iprirea);
                     IF NVL(pfacult, 0) > 0 AND pctiprea = 3 THEN -- 28492 AVT 13/11/2013 DETECTAT PER XL POS
                        perr           := f_insert_ces(w_res, 05, pfacult, regtrams.ncesion, w_porce, psproduc, pcgesfac);
                     ELSE
                        perr := f_insert_ces(w_res, regtrams.ctramo, NULL, regtrams.ncesion, w_porce, psproduc, pcgesfac); -- 13195 AVT 16-02-2010
                     END IF;

                     IF perr <> 0 THEN
                        RETURN perr;
                     END IF;

                      UPDATE tramos
                        SET ncesion     = (NVL(regtrams.ncesion, 0) + 1)
                          WHERE scontra = regtrams.scontra
                           AND nversio  = regtrams.nversio
                           AND ctramo   = DECODE(pctiprea, 3, 6, regtrams.ctramo); -- 28492 AVT 28/10/2013

                     w_yacedido        := w_yacedido + w_res;
                     EXIT; -- Ja ho hem cedit tot...
                  END IF;
               END LOOP;

               IF w_resto > 0 OR w_ffalseado = 1 OR w_switchgarant = 1 THEN -- Hi han cessions a facultatiu...
                  BEGIN
                      SELECT    ncesion
                           INTO pncesion
                           FROM cuafacul
                          WHERE sfacult = pfacult;
                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     ----dbms_outpuT.PUT_LINE(' 11111111111 '||registre.scontra);
                     perr := 104736;
                     RETURN(perr);
                  WHEN OTHERS THEN
                     perr := 104486;
                     RETURN(perr);
                  END;

                  IF w_ffalseado = 1 THEN
                     w_res      := w_ifacced;
                  ELSE
                     w_res := registre.icapital - w_yacedido;
                  END IF;

                  w_porce := w_res / registre.icapital;
                  -->DBMS_OUTPUT.put_line('5. registre.iprirea:' || registre.iprirea);
                  perr    := f_insert_ces(w_res, 05, pfacult, pncesion, w_porce, psproduc, pcgesfac); -- 13195 AVT 16-02-2010

                  IF perr <> 0 THEN
                     RETURN perr;
                  END IF;
               END IF;
            END IF;
         ELSE -- Es un facultatiu forçat...
            BEGIN
                SELECT    ncesion, plocal -- Busquem % nostre i num. cessió...
                     INTO pncesion, w_plocal
                     FROM cuafacul
                    WHERE sfacult = pfacult;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
               ----dbms_outpuT.PUT_LINE(' 22222222222 ');
               perr := 104736;
               RETURN(perr);
            WHEN OTHERS THEN
               perr := 104486;
               RETURN(perr);
            END;

            IF w_plocal IS NOT NULL THEN -- Es crea tram 00 nostre...
               w_res    := (registre.icapital * w_plocal) / 100;
               w_porce  := w_plocal / 100;
               -->DBMS_OUTPUT.put_line('6. registre.iprirea:' || registre.iprirea);
               perr    := f_insert_ces(w_res, 00, pfacult, pncesion, w_porce, psproduc, pcgesfac); -- 13195 AVT 16-02-2010

               IF perr <> 0 THEN
                  RETURN perr;
               END IF;
            END IF;

            -- Tram 05 del facultatiu...
            w_porce := (100 - NVL(w_plocal, 0));
            w_res   := (registre.icapital * w_porce) / 100;
            w_porce := w_porce / 100;
            -->DBMS_OUTPUT.put_line('7. registre.iprirea:' || registre.iprirea);
            perr    := f_insert_ces(w_res, 05, pfacult, pncesion, w_porce, psproduc, pcgesfac); -- 13195 AVT 16-02-2010

            IF perr <> 0 THEN
               RETURN perr;
            END IF;
         END IF;

         ---------
         RETURN(perr);
      END f_ces;
      -- *********************************************************************
      -- *********************************************************************
      BEGIN
         -- PART 1:
         -- ******
         -- AQUI ES PRORRATEJEN LES PRIMES ANUALS DE LES GARANTIES EN FUNCIÓ DE
         -- LES DATES INICIAL I FINAL D'ASSIGNACIÓ A UN CONTRACTE...
         -- TAMBÉ S'ADEQÜEN LES PRIMES DELS CONTRACTES SI EXISTEIX UN % DE REDUCCIÓ
         -- A NIVELL DE CONTRACTE (PCEDIDO)...
         -- TAMBÉ S'OMPLE EL CAMP NAGRUPA SEGONS CVIDAGA DE CODICONTRATOS (NO VIDA O
         -- GARANTIA A GARANTIA)
         w_nagrupa := 0;
         --w_nagrupavi := 0; 13195 AVT 16-02-2010
         w_porcgarant   := 0;
         w_switchgarant := 0;
         w_registre     := 0;
         --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
         BEGIN
            SELECT cmoneda
              INTO w_moninst
              FROM codicontratos
             WHERE scontra = (SELECT scontra
                                FROM cesionesaux
                               WHERE sproces = psproces
                               GROUP BY scontra);
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   SELECT cmonint
                     INTO w_moninst
                     FROM monedas
                    WHERE cidioma = pac_md_common.f_get_cxtidioma
                      AND cmoneda = pac_parametros.f_parinstalacion_n ('MONEDAINST');
         END;
         --      
         SELECT cmonint
           INTO w_monpol
           FROM monedas
          WHERE cidioma = pac_md_common.f_get_cxtidioma AND cmoneda = pmoneda;
         --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
         --AGG 10/04/2014
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 1, 'Inicio de proceso: ' || psproces || ' Motivo: ' || pmotiu ||
         ' Moneda: ' || pmoneda || ' Fecha: ' || pfdatagen || ' cgesfac: ' || pcgesfac || ' ptablas: ' || ptablas);

         ----dbms_outpuT.put_line('-- DINS DE F_CESSIO ----');
         --INI BUG CONF-695  Fecha (22/05/2017) - HRE - Redistribucion reaseguro
         p_traza_proceso(pac_md_common.f_get_cxtempresa, vpar_traza, psproces, v_nom_paquete,
                         v_nom_funcion, NULL, 1, 'Inicio proceso pac_cesionesrea.f_cessio_est psproces: ' || psproces);
         BEGIN
            SELECT cramo
              INTO v_cramo
              FROM estseguros
             WHERE sseguro = (SELECT sseguro
                                FROM cesionesaux
                               WHERE sproces = psproces
                                 AND ROWNUM = 1);

            p_traza_proceso(pac_md_common.f_get_cxtempresa, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 1,
                            'pac_cesionesrea.f_cessio_est paso 3, psproces:'||psproces);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_traza_proceso(pac_md_common.f_get_cxtempresa, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 1,
                               'pac_cesionesrea.f_cessio_est paso 4, psproces:'||psproces);

               SELECT cramo
                 INTO v_cramo
                 FROM seguros
                WHERE sseguro = (SELECT sseguro
                                   FROM cesionesaux
                                  WHERE sproces = psproces
                                    AND ROWNUM = 1);
               p_traza_proceso(pac_md_common.f_get_cxtempresa, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 1,
                               'pac_cesionesrea.f_cessio_est paso 5, psproces:'||psproces);

         END;

         OPEN cur_tiprea(pac_md_common.f_get_cxtempresa, pmotiu, v_cramo, pfdatagen);
         FETCH cur_tiprea INTO v_ctiprea;
         CLOSE cur_tiprea;
         p_traza_proceso(pac_md_common.f_get_cxtempresa, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 1,
         'pac_cesionesrea.f_cessio_est paso 7, psproces:'||psproces||' v_cramo:'||v_cramo||' pfdatagen:'||
         pfdatagen||' pmotiu:'||pmotiu||' v_ctiprea:'||v_ctiprea);

         --FIN BUG CONF-695  - Fecha (22/05/2017) - HRE

         --IF (v_ctiprea = 5) THEN--AMCY - 18/11/2019
         IF (v_ctiprea = 5 OR v_cramo = 802) THEN
            
              p_traza_proceso(pac_md_common.f_get_cxtempresa, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 1,
            'pac_cesionesrea.f_cessio_est paso 7_1 en el si, psproces1:'||psproces||' v_cramo:'||v_cramo||' pfdatagen:'||
            pfdatagen||' pmotiu:'||pmotiu||' v_ctiprea:'||v_ctiprea||' ptablas: '||ptablas);
            
            perr := pac_cesiones.f_cessio(psproces, pmotiu, pmoneda, pfdatagen, pcgesfac, ptablas);
            
          

         ELSE
          p_traza_proceso(pac_md_common.f_get_cxtempresa, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 1,
         'pac_cesionesrea.f_cessio_est paso 7_2 en el sino, psproces2:'||psproces||' v_cramo:'||v_cramo||' pfdatagen:'||
         pfdatagen||' pmotiu:'||pmotiu||' v_ctiprea:'||v_ctiprea);
            perr := pac_cesiones.f_cessio(psproces, pmotiu, pmoneda, pfdatagen, pcgesfac, ptablas);

         --FIN BUG CONF-250  Fecha (02/09/2016) - HRE - Contratos q1,q2,q3

         FOR regaux1 IN cur_aux_1
         LOOP
            ----dbms_outpuT.put_line('IPRIREA    '||regaux1.IPRIREA        );
            ----dbms_outpuT.put_line('ICAPITAL   '||regaux1.ICAPITAL       );
            ----dbms_outpuT.put_line('IPRITARREA '||regaux1.IPRITARREA);
            ----dbms_outpuT.put_line('IDTOSEL    '||regaux1.IDTOSEL        );
            w_fconini := regaux1.fconini;

            IF ptablas = 'EST' THEN
               BEGIN -- Busquem si prima prorratejable o no...
                   SELECT    cempres, cduraci, fefecto, fvencim, sproduc, cramo, cmodali, ctipseg, ccolect, cactivi,
                        ctiprea, sproduc
                        INTO w_cempres, w_cduraci, w_fefecto, w_fvencim, w_sproduc, w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi,
                        w_ctiprea, w_sproduc
                        FROM estseguros
                       WHERE sseguro = regaux1.sseguro;
               EXCEPTION
               WHEN OTHERS THEN
                  perr := 101919;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 2, 'Error: ' || perr);
                  RETURN(perr);
               END;
            ELSIF ptablas = 'CAR' THEN
               BEGIN -- Busquem si prima prorratejable o no...
                   SELECT    cempres, cduraci, fefecto, fvencim, sproduc, cramo, cmodali, ctipseg, ccolect, cactivi,
                        ctiprea, sproduc
                        INTO w_cempres, w_cduraci, w_fefecto, w_fvencim, w_sproduc, w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi,
                        w_ctiprea, w_sproduc
                        FROM seguros
                       WHERE sseguro = regaux1.sseguro;
               EXCEPTION
               WHEN OTHERS THEN
                  perr := 101919;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 3, 'Error: ' || perr);
                  RETURN(perr);
               END;
            ELSE
               BEGIN -- Busquem si prima prorratejable o no...
                   SELECT    cempres, cduraci, fefecto, fvencim, sproduc, cramo, cmodali, ctipseg, ccolect, cactivi,
                        ctiprea, sproduc
                        INTO w_cempres, w_cduraci, w_fefecto, w_fvencim, w_sproduc, w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi,
                        w_ctiprea, w_sproduc
                        FROM seguros
                       WHERE sseguro = regaux1.sseguro;
               EXCEPTION
               WHEN OTHERS THEN
                  perr := 101919;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 4, 'Error: ' || perr);
                  RETURN(perr);
               END;
            END IF;

            w_ctipre_seg := w_ctiprea; -- 22660 AVT 13/08/2012 es mante aquesta inicialització tot i que no és ? ctiprea de seguros de contratos ¿?....
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 5, 'ctiprea: ' || w_ctiprea);

            -- 21559 27/03/2012 AVT
            --BUG 21559 - INICIO - 23/05/2013 - DCT
            IF NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 1 THEN
               --BUG 21559 - FIN - 23/05/2013 - DCT
               w_registre := w_registre + 1;

               --w_capital_principal := regaux1.icapital;   --bug: 22666 -- 24794 AVT 17/11/2012 (23/11/2012)
               IF w_registre           = 1 THEN
                  w_capital_principal := regaux1.icapital; -- 24794 AVT 17/11/2012 (23/11/2012)
                  w_gar_princ         := regaux1.cgarant;
               END IF;
            END IF;

            -- 21559 AVT 09/03/2012 només reaprtim segons garantia principal --
            --BUG 21559 - INICIO - 23/05/2013 - DCT
            IF (NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0)   = 1 AND w_gar_princ = regaux1.cgarant) -- 21559 / 111590
               OR NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 0 THEN
               BEGIN                   -- Busquem si hi ha % de reducció de prima...
                   SELECT    pcedido   --, icapaci   -- 13195 AVT 16-02-2010
                        INTO w_pcedido --, w_icapaci
                        FROM contratos
                       WHERE scontra = regaux1.scontra
                        AND nversio  = regaux1.nversio;
                  ----dbms_outpuT.put_line(' reducció de prima ');
               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  w_pcedido := NULL;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 6, 'NO DATA FOUND scontra: ' || regaux1.scontra ||
                  ' nversio: ' || regaux1.nversio);
               WHEN OTHERS THEN
                  perr := 104704;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 7, 'Error: ' || perr);
                  RETURN(perr);
               END;

               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 8, 'pcedido: ' || w_pcedido);

               ----dbms_outpuT.put_line(' pcedido '||w_pcedido);
               IF w_pcedido    IS NOT NULL THEN
                  w_iprirea    := (regaux1.iprirea * w_pcedido) / 100;
                  w_ipritarrea := (regaux1.ipritarrea * w_pcedido) / 100;
                  w_idtosel    := (regaux1.idtosel * w_pcedido) / 100;
               ELSE
                  w_iprirea    := regaux1.iprirea;
                  w_ipritarrea := regaux1.ipritarrea;
                  w_idtosel    := regaux1.idtosel;
               END IF;

               ----dbms_outpuT.put_line(' scontra '||regaux1.scontra);
               --------------
               -- AQUI ES BUSQUEN EL SPLENO,CCALIF1,CCALIF2 I IPLENO EN FUNCIÓ DEL
               -- CONTRACTE/VERSIÓ ASSIGNAT...
               -------------
               w_spleno  := NULL;
               w_ccalif1 := NULL;
               w_ccalif2 := NULL;
               w_cgar    := NULL; -- 13195 AVT 16-02-2010

               -- Posem aquí la par dos pq es el mateix cursor
               ----dbms_outpuT.put_line(' a f_cessio IF regaux1.cfacult '||regaux1.cfacult);
               IF regaux1.cfacult <> 1 THEN
                  -- No es un facultatiu forçat...(si forçat No busquem res )
                  BEGIN
                     -- SELECT a.cgarant, cvidaga, spleno, ctiprea -- 13195 AVT 21-05-2010
                     --  INTO w_cgar, w_cvidaga, w_spleno, w_ctiprea
                      SELECT    cvidaga, spleno, ctiprea
                           INTO w_cvidaga, w_spleno, w_ctiprea
                           FROM codicontratos -- c, agr_contratos a  -- 13195 AVT 21-05-2010
                          WHERE scontra = regaux1.scontra;
                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     perr := 104697;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 9, 'Error: ' || perr);
                     RETURN(perr);
                  WHEN OTHERS THEN
                     perr := 104516;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 10, 'Error: ' || perr);
                     RETURN(perr);
                  END;

                  -- 13195 AVT 16-02-2010 Aquí es mira si cessions garantia a garantia (vida)...
                  IF w_cvidaga = 2 THEN
                     -- w_nagrupavi := w_nagrupavi + 1; AVT 16-02-2010
                     -- w_nagrupa := w_nagrupavi; AVT 16-02-2010
                     w_nagrupa := w_nagrupa + 1;
                  ELSE
                     w_nagrupa := 0;
                  END IF;

                  /*******************************************************************
                  F_BUSCACALIFI : Devuelve el ipleno y la calificacion de un riesgo
                  segun el seguro y el spleno (w_spleno de CODICONTRATOS)
                  ********************************************************************/
                  IF w_spleno      IS NOT NULL THEN
                     codi_error    := f_buscacalifi(regaux1.sseguro, w_spleno, w_ccalif1, w_ccalif2, w_ipleno);

                     IF codi_error <> 0 THEN
                        perr       := codi_error;
                        RETURN(perr);
                     END IF;
                  ELSE
                     w_ccalif1 := NULL;
                     w_ccalif2 := NULL;

                     /***************************
                     w_ctiprea = 1 - Quota PART
                     ***************************/
                     ----dbms_outpuT.put_line('a f_cessio  tot tra '||w_ctiprea);
                     IF w_ctiprea = 1 THEN
                        w_ipleno := 0; -- bug 19484 AVT 24/11/2011
                        /*BEGIN
                        SELECT itottra
                        INTO w_ipleno
                        FROM tramos
                        WHERE scontra = regaux1.scontra
                        AND nversio = regaux1.nversio
                        AND ctramo = 1;
                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                        perr := 104713;
                        RETURN(perr);
                        WHEN OTHERS THEN
                        perr := 104714;
                        RETURN(perr);
                        END;*/
                        /*********************************
                        w_ctiprea = 2 - Ple NET RETENCIO
                        **********************************/
                     ELSIF w_ctiprea = 2 THEN
                        BEGIN
                           ----dbms_outpuT.put_line(' SELECT DEL PLE ');
                            SELECT    iretenc
                                 INTO w_ipleno
                                 FROM contratos
                                WHERE scontra = regaux1.scontra
                                 AND nversio  = regaux1.nversio;

                           ----dbms_outpuT.put_line('           IRETENC  = '||w_ipleno);
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 11, 'ipleno: ' || w_ipleno);
                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           perr := 104332;
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 12, 'Error: ' || perr);
                           RETURN(perr);
                        WHEN OTHERS THEN
                           perr := 104704;
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 13, 'Error: ' || perr);
                           RETURN(perr);
                        END;
                        -- 28492 AVT 28/10/2013
                        /*********************************
                        w_ctiprea = 3 - COBERT PER XL
                        **********************************/
                     ELSIF w_ctiprea = 3 THEN
                        --28492 AVT 13/11/2013 LA SELECT NO SERVEIX SI UN CONTRACTE COBREIS DOS O MÉS PRODUCTES.
                        perr := f_buscacontrato(regaux1.sseguro, regaux1.fconini, w_cempres, regaux1.cgarant, w_cramo, w_cmodali, w_ctipseg, w_ccolect,
                        w_cactivi, 11, w_scontra, w_nversio, w_ipleno, w_icapaci, w_cdetces); -- revisar evento!!!

                        IF perr <> 0 THEN
                           RETURN(perr);
                        END IF;
                        --                     BEGIN
                        --                     -- 28777 AVT 13-11-13
                        ----                        SELECT icapaci
                        ----                          INTO w_ipleno
                        ----                          FROM contratos
                        ----                         WHERE scontra = regaux1.scontra
                        ----                           AND nversio = regaux1.nversio;
                        --                        SELECT NVL(a.ilimsub, icapaci)
                        --                          INTO w_ipleno
                        --                          FROM contratos c, agr_contratos a
                        --                         WHERE c.scontra = a.scontra
                        --                           AND c.scontra = regaux1.scontra
                        --                           AND c.nversio = regaux1.nversio;
                        --                     EXCEPTION
                        --                        WHEN NO_DATA_FOUND THEN
                        --                           perr := 104332;
                        --                           RETURN(perr);
                        --                        WHEN OTHERS THEN
                        --                           perr := 104704;
                        --                           RETURN(perr);
                        --                     END;
                     END IF;
                  END IF;

                  -- PART 2 BIS:
                  -- **********
                  -- AQUI ES MIRA SI ES UN CONTRACTE DE TIPUS "EMBARCACIONS" PER EL QUE
                  -- TENIM DE CONSIDERAR LES CAPACITATS A NIVELL DE GARANTIA (TAULA
                  -- "CAPGARANT") PER VEURE EL % QUE ANIRÀ A FACULTATIU ( EL % DE LA MÉS GRAN ).
                  -- A w_porcgarant QUEDA EL % MÉS GRAN DE SUPERACIÓ DE CAPACITAT, I QUE
                  -- ES TINDRÀ D'APLICAR COM A % A PASSAR A FACULTATIU PER TOTES LES
                  -- GARANTIES...
                  -- S'ADAPTA LA CAPACITAT EN FUNCIÓ D'AQUEST %...
                  ----dbms_outpuT.put_line('capaci');
                  BEGIN
                      SELECT    icapaci
                           INTO w_icapacigarant
                           FROM capgarant
                          WHERE scontra = regaux1.scontra
                           AND nversio  = regaux1.nversio
                           AND cgarant  = regaux1.cgarant;
                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     w_icapacigarant := NULL;
                  WHEN OTHERS THEN
                     perr := 105756;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 15, 'Error: ' || perr);
                     RETURN(perr);
                  END;

                  --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                  IF w_icapacigarant IS NOT NULL AND regaux1.icapital > ( w_icapacigarant / pac_eco_tipocambio.f_cambio(w_monpol,w_moninst,pfdatagen) ) THEN
                     w_switchgarant  := 1;
                     w_porcaux := ( 100 * (regaux1.icapital - (w_icapacigarant / pac_eco_tipocambio.f_cambio(w_monpol, w_moninst,pfdatagen))) ) / regaux1.icapital;
                  --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros

                     IF w_porcaux     > w_porcgarant THEN -- Es selecciona el %
                        w_porcgarant := w_porcaux;        -- més gran...
                     END IF;
                  END IF;
               END IF;

               -------------
               ------------
               BEGIN
                   UPDATE cesionesaux
                     SET iprirea                    = w_iprirea, ipritarrea = w_ipritarrea, idtosel = w_idtosel, nagrupa = DECODE(nagrupa, NULL, w_nagrupa, nagrupa), spleno = NVL
                        (w_spleno, spleno), ccalif1 = NVL(w_ccalif1, ccalif1), ccalif2 = NVL(w_ccalif2, ccalif2), ipleno = NVL(ipleno, w_ipleno)
                        -- Pot ser que ja estigui calculat de SGT
                       WHERE nnumlin = regaux1.nnumlin
                        AND sproces  = psproces;
                  --       post;
               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  perr := 104695;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 16, 'Error: ' || perr);
                  RETURN(perr);
               WHEN OTHERS THEN
                  perr := 104696;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 17, 'Error: ' || perr);
                  RETURN(perr);
               END;
            END IF; -- 21559 fi
         END LOOP;

         ------------------------------------------------------------------------
         -- PART 3:
         -- ******
         -- AQUI ES FUSIONEN ELS REGISTRES DE "CESIONESAUX" EN FUNCIÓ DE L'IGUALTAT
         -- DE RISC,SPLENO,CCALIF1,CCALIF2,SCONTRA,NVERSIO,SCUMULO,NAGRUPA...
         -- UTILITZAREM EL CAMP CESTADO PER DISTINGIR ELS REGISTRES NO FUSIONATS
         -- (cestado = 0) DELS FUSIONATS (cestado = 1)...
         FOR regaux2 IN cur_aux_2
         LOOP
            ---- 21559 AVT 09/03/2012  A les garanties no principals tb els hi actualitzem l'estat ............
            ---- 26142 KBR 04/03/2013  Cambiamos el estado 1 por 2 para que se salte el próximo paso
            --BUG 21559 - INICIO - 23/05/2013 - DCT
            IF ptablas = 'EST' THEN
               BEGIN
                   SELECT    sproduc
                        INTO w_sproduc
                        FROM estseguros
                       WHERE sseguro = regaux2.sseguro;
               EXCEPTION
               WHEN OTHERS THEN
                  perr := 101919;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 18, 'Error: ' || perr);
                  RETURN(perr);
               END;
            ELSIF ptablas = 'CAR' THEN
               BEGIN
                   SELECT    sproduc
                        INTO w_sproduc
                        FROM seguros
                       WHERE sseguro = regaux2.sseguro;
               EXCEPTION
               WHEN OTHERS THEN
                  perr := 101919;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 19, 'Error: ' || perr);
                  RETURN(perr);
               END;
            ELSE
               BEGIN -- Busquem si prima prorratejable o no...
                   SELECT    sproduc
                        INTO w_sproduc
                        FROM seguros
                       WHERE sseguro = regaux2.sseguro;
               EXCEPTION
               WHEN OTHERS THEN
                  perr := 101919;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 20, 'Error: ' || perr);
                  RETURN(perr);
               END;
            END IF;

            IF NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 1
               --BUG 21559 - FIN - 23/05/2013 - DCT
               AND w_gar_princ <> regaux2.cgarant THEN -- 21559 / 111590
                UPDATE cesionesaux
                  SET cestado     = 2
                    WHERE sproces = psproces
                     AND cgarant  = regaux2.cgarant;
            END IF;

            -- 21559 AVT 09/03/2012 només reaprtim segons garantia principal --
            --BUG 21559 - INICIO - 23/05/2013 - DCT
            IF (NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0)   = 1 AND w_gar_princ = regaux2.cgarant) -- 21559 / 111590
               OR NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 0 THEN
               --BUG 21559 - FIN - 23/05/2013 - DCT
               w_nriesgo          := regaux2.nriesgo;
               w_spleno           := regaux2.spleno;
               w_ccalif1          := regaux2.ccalif1;
               w_ccalif2          := regaux2.ccalif2;
               w_scontra          := regaux2.scontra;
               w_nversio          := regaux2.nversio;
               w_scumulo          := regaux2.scumulo;
               w_nagrupa          := regaux2.nagrupa;
               w_cgarant          := regaux2.cgarant;
               w_trobat           := 0;

               IF regaux2.cfacult <> 1 THEN
                  -- bug: 14404 AVT 25-05-2010 una mateixa pòlissa pot tenir 2 ó més contractes de tipus diferent
                  BEGIN
                      SELECT    ctiprea
                           INTO w_ctiprea -- 13195 AVT 16-02-2010
                           FROM codicontratos
                          WHERE scontra = regaux2.scontra;
                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     perr := 104697;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 21, 'Error: ' || perr);
                     RETURN(perr);
                  WHEN OTHERS THEN
                     perr := 104516;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 22, 'Error: ' || perr);
                     RETURN(perr);
                  END;
               END IF;

               FOR regaux3 IN cur_aux_3
               LOOP
                  w_trobat := 1;

                  BEGIN
                     w_iprirea    := regaux3.iprirea + regaux2.iprirea;
                     w_ipritarrea := regaux3.ipritarrea + regaux2.ipritarrea;
                     w_idtosel    := regaux3.idtosel + regaux2.idtosel;

                     -- Aquí busquem capital per tot el cúmul...
                     IF regaux2.scumulo IS NOT NULL THEN
                        --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                        cum_capital     := regaux3.icapital + regaux2.icapital;
                        --codi_error      := pac_cesionesrea.f_capital_cumul_est(w_ctiprea, regaux2.scumulo, regaux2.fconini, regaux3.cgarant, cum_capital,
                        --ptablas);
                        cum_capital := NVL (pac_eco_tipocambio.f_importe_cambio (w_monpol, w_moninst, pfdatagen, cum_capital),0);
                        codi_error  := pac_cesionesrea.f_capital_cumul_est_mon (w_ctiprea, regaux2.scumulo, regaux2.fconini, regaux3.cgarant, 
                                                                                w_moninst, pfdatagen, cum_capital, ptablas);
                        --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                        --FI BUG 11100 - 16/09/2009 – FAL
                        IF codi_error <> 0 THEN
                           perr       := codi_error;
                           RETURN(perr);
                        ELSE
                           --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                           --w_icapital := cum_capital;
                           w_icapital := cum_capital / pac_eco_tipocambio.f_cambio (w_monpol, w_moninst, pfdatagen);
                           --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                        END IF;
                     ELSE
                        w_icapital := regaux3.icapital + regaux2.icapital;
                     END IF;

                      UPDATE cesionesaux
                        SET iprirea              = w_iprirea, ipritarrea = w_ipritarrea, idtosel = w_idtosel, icapital = w_icapital
                          WHERE NVL(nriesgo, 0)  = NVL(regaux2.nriesgo, 0)
                           AND NVL(spleno, 0)    = NVL(regaux2.spleno, 0)
                           AND NVL(ccalif1, ' ') = NVL(regaux2.ccalif1, ' ')
                           AND NVL(ccalif2, 0)   = NVL(regaux2.ccalif2, 0)
                           AND NVL(scontra, 0)   = NVL(regaux2.scontra, 0)
                           AND NVL(nversio, 0)   = NVL(regaux2.nversio, 0)
                           AND NVL(scumulo, 0)   = NVL(regaux2.scumulo, 0)
                           AND NVL(nagrupa, 0)   = NVL(regaux2.nagrupa, 0)
                           AND cgarant          IS NULL
                           AND cestado           = 1
                           AND sproces           = psproces;

                     --           post;
                     EXIT;
                  EXCEPTION
                  WHEN OTHERS THEN
                     perr := 104700;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 23, 'Error: ' || perr);
                     RETURN(perr);
                  END;
               END LOOP;

               IF w_trobat = 0 THEN
                  FOR regaux4 IN cur_aux_4
                  LOOP
                     w_trobat := 1;

                     BEGIN
                        w_iprirea    := regaux4.iprirea + regaux2.iprirea;
                        w_ipritarrea := regaux4.ipritarrea + regaux2.ipritarrea;
                        w_idtosel    := regaux4.idtosel + regaux2.idtosel;

                        -- Aquí busquem capital per tot el cúmul...
                        IF regaux2.scumulo IS NOT NULL THEN
						   --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                           cum_capital     := regaux4.icapital + regaux2.icapital;
                           --codi_error      := pac_cesionesrea.f_capital_cumul_est(w_ctiprea, regaux2.scumulo, regaux2.fconini, regaux4.cgarant, cum_capital,
                           --ptablas);
                           cum_capital := NVL (pac_eco_tipocambio.f_importe_cambio (w_monpol,w_moninst,pfdatagen,cum_capital),0);
                           codi_error := pac_cesionesrea.f_capital_cumul_est_mon (w_ctiprea, regaux2.scumulo, regaux2.fconini, regaux4.cgarant, 
                                                                                  w_moninst, pfdatagen, cum_capital, ptablas);
                           --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros

                           --FI BUG 11100 - 16/09/2009 – FAL
                           IF codi_error <> 0 THEN
                              perr       := codi_error;
                              RETURN(perr);
                           ELSE
                              --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                              --w_icapital := cum_capital;
                              w_icapital := cum_capital / pac_eco_tipocambio.f_cambio (w_monpol, w_moninst, pfdatagen);
                              --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                           END IF;
                        ELSE
                           w_icapital := regaux4.icapital + regaux2.icapital;
                        END IF;

                         UPDATE cesionesaux
                           SET iprirea              = w_iprirea, ipritarrea = w_ipritarrea, idtosel = w_idtosel, icapital = w_icapital, cgarant = NULL
                             WHERE NVL(nriesgo, 0)  = NVL(regaux2.nriesgo, 0)
                              AND NVL(spleno, 0)    = NVL(regaux2.spleno, 0)
                              AND NVL(ccalif1, ' ') = NVL(regaux2.ccalif1, ' ')
                              AND NVL(ccalif2, 0)   = NVL(regaux2.ccalif2, 0)
                              AND NVL(scontra, 0)   = NVL(regaux2.scontra, 0)
                              AND NVL(nversio, 0)   = NVL(regaux2.nversio, 0)
                              AND NVL(scumulo, 0)   = NVL(regaux2.scumulo, 0)
                              AND NVL(nagrupa, 0)   = NVL(regaux2.nagrupa, 0)
                              AND cgarant          IS NOT NULL
                              AND NVL(cgarant, 0)  <> NVL(regaux2.cgarant, 0)
                              AND cestado           = 1
                              AND sproces           = psproces;

                        --              post;
                        EXIT;
                     EXCEPTION
                     WHEN OTHERS THEN
                        perr := 104701;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 24, 'Error: ' || perr);
                        RETURN(perr);
                     END;
                  END LOOP;
               END IF;

               IF w_trobat = 0 THEN
                  FOR regaux5 IN cur_aux_5
                  LOOP
                     w_trobat := 1;

                     BEGIN
                        w_iprirea    := regaux5.iprirea + regaux2.iprirea;
                        w_ipritarrea := regaux5.ipritarrea + regaux2.ipritarrea;
                        w_idtosel    := regaux5.idtosel + regaux2.idtosel;

                        -- Aquí busquem capital per tot el cúmul...
                        IF regaux2.scumulo IS NOT NULL THEN
                           --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
						   cum_capital     := regaux5.icapital + regaux2.icapital;
                           --codi_error      := pac_cesionesrea.f_capital_cumul_est(w_ctiprea, regaux2.scumulo, regaux2.fconini, regaux5.cgarant, cum_capital,
                           --ptablas);
                           cum_capital := NVL (pac_eco_tipocambio.f_importe_cambio(w_monpol, w_moninst, pfdatagen, cum_capital),0);
                           codi_error := pac_cesionesrea.f_capital_cumul_est_mon (w_ctiprea, regaux2.scumulo, regaux2.fconini, regaux5.cgarant, 
                                                                                  w_moninst, pfdatagen, cum_capital, ptablas);
                           --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                           --FI BUG 11100 - 16/09/2009 – FAL
                           IF codi_error <> 0 THEN
                              perr       := codi_error;
                              p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 25, 'Error: ' || perr);
                              RETURN(perr);
                           ELSE
                              --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                              --w_icapital := cum_capital;
                              w_icapital := cum_capital / pac_eco_tipocambio.f_cambio (w_monpol, w_moninst, pfdatagen);
                              --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                           END IF;
                        ELSE
                           w_icapital := regaux5.icapital + regaux2.icapital;
                        END IF;

                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 26, 'iprirea: ' || w_iprirea || ' ipritarrea: ' ||
                        w_ipritarrea || ' idtosel: ' || w_idtosel || ' icapital: ' || w_icapital);

                         UPDATE cesionesaux
                           SET iprirea              = w_iprirea, ipritarrea = w_ipritarrea, idtosel = w_idtosel, icapital = w_icapital
                             WHERE NVL(nriesgo, 0)  = NVL(regaux2.nriesgo, 0)
                              AND NVL(spleno, 0)    = NVL(regaux2.spleno, 0)
                              AND NVL(ccalif1, ' ') = NVL(regaux2.ccalif1, ' ')
                              AND NVL(ccalif2, 0)   = NVL(regaux2.ccalif2, 0)
                              AND NVL(scontra, 0)   = NVL(regaux2.scontra, 0)
                              AND NVL(nversio, 0)   = NVL(regaux2.nversio, 0)
                              AND NVL(scumulo, 0)   = NVL(regaux2.scumulo, 0)
                              AND NVL(nagrupa, 0)   = NVL(regaux2.nagrupa, 0)
                              AND cgarant          IS NOT NULL
                              AND NVL(cgarant, 0)   = NVL(regaux2.cgarant, 0)
                              AND cestado           = 1
                              AND sproces           = psproces;

                        --              post;
                        EXIT;
                     EXCEPTION
                     WHEN OTHERS THEN
                        perr := 104701;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 27, 'Error: ' || perr);
                        RETURN(perr);
                     END;
                  END LOOP;
               END IF;

               IF w_trobat = 0 THEN
                  BEGIN
                     w_cgar := NULL; --RAL BUG 0035314: FACTURABLE - Reaseguro - Incidencia por movimientos Reaseguro poliza 7000280  22/06/2015

                     -- 26283 KBR 14/03/2013 Incidencia al momento de hacer cúmulo para colectivos de Liberty
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 270, 'capital: ' || w_icapital
                                        ||' regaux2.scumulo:'||regaux2.scumulo||' w_cvidaga:'||w_cvidaga||
                                        ' w_nagrupa:'||w_nagrupa );

                     IF w_cvidaga   = 2 OR w_nagrupa <> 0 OR NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 1 THEN --KBR 04/12/2013
                        w_cgar     := regaux2.cgarant;
                        w_icapital := regaux2.icapital;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 271, 'capital: ' || w_icapital
                      ||' regaux2.scumulo:'||regaux2.scumulo );

                     ELSE
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 272, 'capital: ' || w_icapital
                                        ||' regaux2.scumulo:'||regaux2.scumulo );
                        -- Aquí busquem capital per tot el cúmul...
                        IF regaux2.scumulo IS NOT NULL THEN
                           cum_capital     := regaux2.icapital;
                           --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                           --codi_error      := f_capital_cumul(w_ctiprea, regaux2.scumulo, regaux2.fconini, regaux2.cgarant, cum_capital);
                           cum_capital := NVL (pac_eco_tipocambio.f_importe_cambio(w_monpol, w_moninst, pfdatagen, cum_capital),0);
                           codi_error  := pac_cesionesrea.f_capital_cumul_mon (w_ctiprea, regaux2.scumulo, regaux2.fconini, regaux2.cgarant, w_moninst, pfdatagen, cum_capital);
                           --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros

                           IF codi_error   <> 0 THEN
                              perr         := codi_error;
                              RETURN(perr);
                           ELSE
                              --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                              --w_icapital := cum_capital;
                              w_icapital := cum_capital / pac_eco_tipocambio.f_cambio (w_monpol, w_moninst, pfdatagen);
                             
                             --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                           END IF;
                        ELSE
                           w_icapital := regaux2.icapital;
                        END IF;
                     END IF;

                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 28, 'capital: ' || w_icapital);

                     -- FIN 26283 KBR 14/03/2013
                      INSERT
                           INTO cesionesaux
                           (
                              sproces, nnumlin, sseguro, iprirea, icapital, cfacult, cestado, nriesgo, nmovimi, ccalif1,
                              ccalif2, spleno, cgarant, scontra, nversio, fconini, fconfin, ipleno, icapaci, scumulo,
                              sfacult, nagrupa, iextrap, precarg, ipritarrea, idtosel, psobreprima, cdetces, fanulac, fregula,
                              iextrea,
                              -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                              itarifrea
                           )
                           -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
                           VALUES
                           (
                              regaux2.sproces, (regaux2.nnumlin * - 1), regaux2.sseguro, regaux2.iprirea, w_icapital, -- 21559 AVT 13/03/2012 regaux2.icapital,
                              -- w_icapital  BUG:14400 03-04-2010 AVT
                              regaux2.cfacult, 1, regaux2.nriesgo, regaux2.nmovimi, regaux2.ccalif1, regaux2.ccalif2, regaux2.spleno, w_cgar, regaux2.scontra,
                              regaux2.nversio, regaux2.fconini, regaux2.fconfin, regaux2.ipleno, regaux2.icapaci, regaux2.scumulo, regaux2.sfacult,
                              regaux2.nagrupa, regaux2.iextrap, regaux2.precarg, regaux2.ipritarrea, regaux2.idtosel, regaux2.psobreprima, regaux2.cdetces,
                              regaux2.fanulac, regaux2.fregula, regaux2.iextrea,
                              -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                              regaux2.itarifrea
                           );
                     -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
                     --             post;
                  EXCEPTION
                  WHEN OTHERS THEN
                     ----dbms_outpuT.put_line(SQLERRM);
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 29, 'Error: ' || perr);
                     perr := 104702;
                     RETURN(perr);
                  END;
               END IF;
            END IF; -- 21559 AVT 09/03/2012 fi ----------
         END LOOP;

         ------------------------------------------------------------------------
         -- PART 4:
         -- ******
         -- AQUI S'ESBORREN ELS REGISTRES DE "CESIONESAUX" AMB CESTADO A 0 PERQUÈ
         -- JA S'HAN FUSIONAT...
         BEGIN
            -->P_Borrar_Jgr (88); --> BORRAR JGR
             DELETE
                  FROM cesionesaux
                 WHERE cestado = 0
                  AND sproces  = psproces;
            --   post;
         EXCEPTION
         WHEN OTHERS THEN
            perr := 104703;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 30, 'Error: ' || perr);
            RETURN(perr);
         END;

         ------------------------------------------------------------------------
         -- PART 5:
         -- ******
         -- AQUI ES BUSCA EL ICAPACI EN FUNCIO DELS PLENS...
         FOR regaux1 IN cur_aux_1
         LOOP
            IF regaux1.cfacult = 1 THEN -- Es un facultatiu forçat...
               EXIT;
            END IF;

            --BUG 21559 - INICIO - 23/05/2013 - DCT
            IF ptablas = 'EST' THEN
               BEGIN
                   SELECT    sproduc
                        INTO w_sproduc
                        FROM estseguros
                       WHERE sseguro = regaux1.sseguro;
               EXCEPTION
               WHEN OTHERS THEN
                  perr := 101919;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 31, 'Error: ' || perr);
                  RETURN(perr);
               END;
            ELSIF ptablas = 'CAR' THEN
               BEGIN
                   SELECT    sproduc
                        INTO w_sproduc
                        FROM seguros
                       WHERE sseguro = regaux1.sseguro;
               EXCEPTION
               WHEN OTHERS THEN
                  perr := 101919;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 32, 'Error: ' || perr);
                  RETURN(perr);
               END;
            ELSE
               BEGIN -- Busquem si prima prorratejable o no...
                   SELECT    sproduc
                        INTO w_sproduc
                        FROM seguros
                       WHERE sseguro = regaux1.sseguro;
               EXCEPTION
               WHEN OTHERS THEN
                  perr := 101919;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 33, 'Error: ' || perr);
                  RETURN(perr);
               END;
            END IF;

            -- 21559 AVT 09/03/2012 només reaprtim segons garantia principal --
            IF (NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0)   = 1 AND w_gar_princ = regaux1.cgarant) -- 21559 / 111590
               OR NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 0 THEN
               --BUG 21559 - FIN - 23/05/2013 - DCT
               -- bug: 14404 AVT 25-05-2010 una mateixa pòlissa pot tenir 2 ó més contractes de tipus diferent
               BEGIN
                   SELECT    ctiprea
                        INTO w_ctiprea -- 13195 AVT 16-02-2010
                        FROM codicontratos
                       WHERE scontra = regaux1.scontra;
               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  perr := 104697;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 34, 'Error: ' || perr);
                  RETURN(perr);
               WHEN OTHERS THEN
                  perr := 104516;
                  RETURN(perr);
               END;

               IF regaux1.spleno IS NOT NULL THEN -- 13195 AVT 16-02-2010
                  w_scontra      := regaux1.scontra;
                  w_nversio      := regaux1.nversio;

                  IF w_ctiprea    = 1 THEN
                     w_nplenos   := 0;
                  ELSE
                     w_nplenos := 1;
                  END IF;

                  FOR regtram IN cur_trams(regaux1.scontra, regaux1.nversio)
                  LOOP
                     w_nplenos := w_nplenos + regtram.nplenos;
                  END LOOP;

                  --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                  --w_icapaci := regaux1.ipleno * w_nplenos;
                  w_icapaci := (regaux1.ipleno / pac_eco_tipocambio.f_cambio (w_monpol, w_moninst, pfdatagen)) * w_nplenos;
                  --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
               END IF;

               IF w_ctipre_seg    = 1 OR w_ctipre_seg = 3 THEN
                  w_switchgarant := 0;
                  w_icapaci      := w_icapital; -- regaux1.icapital; BUG: 14400 03-04-2010 AVT
                  --AGG 24/07/2014  Modificació per que no salte facultativo
                  v_base_rea   := NVL(pac_parametros.f_parproducto_n(w_sproduc, 'CESION_BASE_REA'), 0);

                  IF v_base_rea = 1 THEN
                     BEGIN
                         UPDATE cesionesaux
                           SET icapaci = w_icapaci -- sempre agafem primer la que s'ha formulat
                              --Per si ve calculat del SGT
                             WHERE nnumlin = regaux1.nnumlin
                              AND sproces  = psproces;
                        --       post;
                     EXCEPTION
                     WHEN OTHERS THEN
                        perr := 104705;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 37, 'Error: ' || perr || ' nnumlin: ' ||
                        regaux1.nnumlin);
                        RETURN(perr);
                     END;
                  END IF;
                  --fin AGG 14/04/2014
               ELSE
                  IF w_switchgarant = 1 THEN
                     w_icapaci     := regaux1.icapital - ((regaux1.icapital * w_porcgarant) / 100);
                  END IF;
               END IF;

               BEGIN
                   UPDATE cesionesaux
                     SET icapaci = NVL(icapaci, w_icapaci)
                        --Per si ve calculat del SGT
                       WHERE nnumlin = regaux1.nnumlin
                        AND sproces  = psproces;
                  --       post;
               EXCEPTION
               WHEN OTHERS THEN
                  perr := 104705;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 35, 'Error: ' || perr);
                  RETURN(perr);
               END;
            END IF; -- 21559 AVT 09/03/2012 fi --------------

            -- A les garanties no principals tb els hi actualitzem l'estat ............
            --BUG 21559 - INICIO - 23/05/2013 - DCT
            IF NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 1
               --BUG 21559 - FIN - 23/05/2013 - DCT
               AND w_gar_princ <> regaux1.cgarant THEN -- 21559 / 111590
                UPDATE cesionesaux
                  SET cestado     = 2
                    WHERE sproces = psproces
                     AND cgarant  = regaux1.cgarant;
            END IF;
         END LOOP;

         ------------------------------------------------------------------------
         -- PART 6:
         -- ******
         -- AQUI ES MIRA SI ES NECESSITA FACULTATIU I SI EXISTEIX JA...
         ------------------------------------------------------------------------
         perr    := 0;
         pfacult := NULL;

         FOR regaux1 IN cur_aux_1
         LOOP
            -- 21559 AVT 09/03/2012 només reaprtim segons garantia principal --
            -->DBMS_OUTPUT.put_line('*** GAR_PRINCIPAL_REA regaux1.cgarant:' || regaux1.cgarant);

            --BUG 21559 - INICIO - 23/05/2013 - DCT
            IF ptablas = 'EST' THEN
               BEGIN
                   SELECT    sproduc
                        INTO w_sproduc
                        FROM estseguros
                       WHERE sseguro = regaux1.sseguro;
               EXCEPTION
               WHEN OTHERS THEN
                  perr := 101919;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 36, 'Error: ' || perr);
                  RETURN(perr);
               END;
            ELSIF ptablas = 'CAR' THEN
               BEGIN
                   SELECT    sproduc
                        INTO w_sproduc
                        FROM seguros
                       WHERE sseguro = regaux1.sseguro;
               EXCEPTION
               WHEN OTHERS THEN
                  perr := 101919;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 37, 'Error: ' || perr);
                  RETURN(perr);
               END;
            ELSE
               BEGIN -- Busquem si prima prorratejable o no...
                   SELECT    sproduc
                        INTO w_sproduc
                        FROM seguros
                       WHERE sseguro = regaux1.sseguro;
               EXCEPTION
               WHEN OTHERS THEN
                  perr := 101919;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 38, 'Error: ' || perr);
                  RETURN(perr);
               END;
            END IF;

            IF (NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0)   = 1 AND w_gar_princ = regaux1.cgarant) -- 21559 / 111590
               OR NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 0 THEN
               --BUG 21559 - FIN - 23/05/2013 - DCT
               w_sproces                  := regaux1.sproces;
               w_sseguro                  := regaux1.sseguro;
               w_nmovimi                  := regaux1.nmovimi;

               IF NVL(regaux1.cfacult, 0) <> 0 THEN -- FACULTATIU FORÇAT...
                  w_fac_princ             := 1;

                  ------        buscar facultatiu...
                  IF regaux1.sfacult IS NOT NULL THEN
                     w_trobat        := 1;
                     pfacult         := regaux1.sfacult;
                  ELSE
                     codi_error := f_facult(regaux1.sseguro, regaux1.nriesgo, regaux1.ccalif1, regaux1.ccalif2, regaux1.cgarant, NULL, NULL, regaux1.fconini,
                     regaux1.scumulo, w_trobat, w_cestado, pfacult, w_ifacced);

                     IF codi_error <> 0 THEN
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 39, 'Error: ' || codi_error);
                        RETURN(codi_error);
                     END IF;

                     -->> AVT 21/01/2014  inici control dels facultatius existents en cas de cúmul
                     IF NVL(regaux1.scumulo, 0) > 0 THEN
                        BEGIN
                            SELECT    COUNT( * )
                                 INTO v_hiha_ces
                                 FROM cesionesrea
                                WHERE sfacult = pfacult;
                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           v_hiha_ces := 0;
                        WHEN OTHERS THEN
                           v_hiha_ces := 0;
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 40, 'Error facult: ' || pfacult);
                           p_tab_error(f_sysdate, f_user, 'f_cessio', 1, 'cesionesrea sfacult:' || pfacult, SQLCODE || ' - ' || SQLERRM);
                        END;
                     ELSE
                        v_hiha_ces := 0;
                     END IF;
                     -->> AVT 21/01/2014  fi
                  END IF;

                  IF w_trobat     = 1 AND v_hiha_ces = 0 THEN -->> AVT 21/01/2014
                     IF w_cestado = 2 AND w_ifacced = regaux1.icapital THEN
                        ------              cessió...
                        BEGIN
                            UPDATE cesionesaux
                              SET cestado     = 2, sfacult = pfacult
                                WHERE nnumlin = regaux1.nnumlin
                                 AND sproces  = psproces;
                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           perr := 104695;
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 41, 'Error: ' || perr);
                           RETURN(perr);
                        WHEN OTHERS THEN
                           perr := 104696;
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 42, 'Error: ' || perr);
                           RETURN(perr);
                        END;
                     ELSE
                        ------              a taula pendent...
                        --IF w_ifacced <> regaux1.icapital THEN
                        -- nunu trec trec If pq no fa la capçalera
                        -- 19484 cgesfac = 0-No generar QUADRE 1-Si generar QUADRE
                        IF pcgesfac = 1 THEN
                           cabfacul(regaux1);

                           IF perr <> 0 AND perr <> 99 THEN
                              p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 43, 'Error: ' || perr);
                              RETURN(perr);
                           END IF;

                           -- 19484 - AVT 02/01/2012
                           perr := 99;
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 44, 'Error: ' || perr);
                        ELSE
                           perr := 99;
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 45, 'Error: ' || perr);
                           EXIT;
                        END IF;
                     END IF;
                  ELSE
                     ------           a taula pendent...
                     -- 19484 cgesfac = 0-No generar QUADRE 1-Si generar QUADRE
                     IF pcgesfac = 1 THEN
                        cabfacul(regaux1);

                        IF perr <> 0 AND perr <> 99 THEN
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 46, 'Error: ' || perr);
                           RETURN(perr);
                        END IF;

                        -- 19484 - AVT 02/01/2012
                        perr := 99;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 47, 'Error: ' || perr);
                     ELSE
                        perr := 99;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 48, 'Error: ' || perr);
                        EXIT;
                     END IF;
                  END IF;
               ELSE -- del forçat
                  --nunununu
                  -- Cal veure si te cúmul per saber si excedeix del capital i va
                  -- a facultatiu
                  IF regaux1.scumulo IS NOT NULL THEN
                     -- Buscar el capital del cúmul
                     perr := pac_cesionesrea.f_ple_cumul_est(regaux1.sseguro, regaux1.scumulo, regaux1.cgarant, regaux1.fconini, lcapicum, lplecum, lcapacum,
                     ptablas);

                     IF perr <> 0 THEN
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 49, 'Error: ' || perr);
                        RETURN perr;
                     END IF;

                     -- Cal actualitzar el valor del ple amb el màxim del cúmul
                     IF NVL(lplecum, 0)    > regaux1.ipleno OR NVL(lcapacum, 0) > regaux1.icapaci THEN
                        IF NVL(lplecum, 0) > regaux1.ipleno THEN
                           regaux1.ipleno := lplecum;
                        END IF;

                        -- Cal actualitzar el valor de la capacitat amb el màxim del cúmul
                        IF NVL(lcapacum, 0) > regaux1.icapaci THEN
                           regaux1.icapaci := lcapacum;
                        END IF;

                         UPDATE cesionesaux
                           SET ipleno      = regaux1.ipleno, icapaci = regaux1.icapaci
                             WHERE nnumlin = regaux1.nnumlin
                              AND sproces  = psproces;
                     END IF;

                     ----dbms_outpuT.put_line('******** capicum ****' || lcapicum);
                     -- Valor que podem assumir
                     lassumir    := regaux1.ipleno - lcapicum;

                     IF lassumir  < 0 THEN
                        lassumir := 0;
                     END IF;

                     -- Una vegada trobat el capital que pot cedir la garantia(ella sola)
                     -- dins el cúmul, mirem la totalitat de les garanties que
                     -- van juntes més les de la pròpia pòlissa (no la garantia que tractem)
                     IF lassumir > 0 THEN
                        --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                        --perr    := pac_cesionesrea.f_ple_cumul_tot_est(regaux1.sseguro, regaux1.scumulo, regaux1.cgarant, regaux1.fconini, regaux1.scontra,
                        --regaux1.nversio, lcapcum_tot, lplecum_tot, ptablas);
                        perr := pac_cesionesrea.f_ple_cumul_tot_est_mon (regaux1.sseguro, regaux1.scumulo, regaux1.cgarant, regaux1.fconini, regaux1.scontra,
                                                                         regaux1.nversio, w_moninst, pfdatagen, lcapcum_tot, lplecum_tot, ptablas);
                        --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros

                        IF perr <> 0 THEN
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 50, 'Error: ' || perr);
                           RETURN perr;
                        END IF;

                        w_captram_tot := lplecum_tot - lcapcum_tot;

                        -- Ens quedem amb l'import menor
                        IF w_captram_tot < lassumir THEN
                           -- si és menor canviem el valor del capital del tram
                           lassumir := w_captram_tot;
                           --ELSE
                           -- si és més gran ja és correcte assumuir lassumir
                        END IF;
                     END IF;

                     -- la capacitat li restem el que NO HEM assumit encara
                     lcapaci_cum := regaux1.icapaci - (regaux1.ipleno - lassumir);

                     ----dbms_outpuT.put_line('************ lcapaci_cum ' || lcapaci_cum);

                     --Cal descomptar de la capacitat el que portem assumit de cada tram
                     FOR v_tram IN cur_trams(regaux1.scontra, regaux1.nversio)
                     LOOP
                        lcapcumtram     := 0;

                        IF v_tram.ctramo > 0 THEN -- 28777 AVT 13-11-13
                           --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                           --perr         := pac_cesionesrea.f_captram_cumul_est(regaux1.sseguro, regaux1.scumulo, regaux1.cgarant, regaux1.fconini,
                           --v_tram.ctramo, regaux1.scontra, regaux1.nversio, lcapcumtram, lpleno, ptablas); --nunu ???
                           perr := pac_cesionesrea.f_captram_cumul_est_mon (regaux1.sseguro, regaux1.scumulo, regaux1.cgarant, regaux1.fconini, v_tram.ctramo,
                                                                            regaux1.scontra, regaux1.nversio, w_moninst, pfdatagen, lcapcumtram, lpleno, ptablas);
                           --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros

                           IF perr <> 0 THEN
                              p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 51, 'Error: ' || perr);
                              RETURN perr;
                           END IF;
                        END IF;

                        lcapaci_cum := lcapaci_cum - NVL(lcapcumtram, 0);
                     END LOOP;

                     IF lcapaci_cum  < 0 THEN
                        lcapaci_cum := 0;
                     END IF;
                  ELSE
                     lcapaci_cum := regaux1.icapaci;
                  END IF;
                  --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                  lcapaci_cum := lcapaci_cum / pac_eco_tipocambio.f_cambio (w_monpol, w_moninst, pfdatagen);
                  --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                  -- nunununu
                  ----dbms_outpuT.put_line(regaux1.icapital || '>' || lcapaci_cum);
                  IF regaux1.icapital > lcapaci_cum OR w_switchgarant = 1 THEN -- NECESSITEM FACULTATIU...
                     w_fac_princ     := 1;                                     --22237
                     ------        buscar facultatiu...
                     codi_error := f_facult(regaux1.sseguro, regaux1.nriesgo, regaux1.ccalif1, regaux1.ccalif2, regaux1.cgarant, regaux1.scontra,
                     regaux1.nversio, regaux1.fconini, regaux1.scumulo, w_trobat, w_cestado, pfacult, w_ifacced);

                     IF codi_error <> 0 THEN
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 52, 'Error: ' || perr);
                        RETURN(codi_error);
                     END IF;

                     -->> AVT 21/01/2014  inici control dels facultatius existents en cas de cúmul
                     IF NVL(regaux1.scumulo, 0) > 0 THEN
                        BEGIN
                            SELECT    COUNT( * )
                                 INTO v_hiha_ces
                                 FROM cesionesrea
                                WHERE sfacult = pfacult;
                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           v_hiha_ces := 0;
                        WHEN OTHERS THEN
                           v_hiha_ces := 0;
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 53, 'Error facult: ' || pfacult);
                           p_tab_error(f_sysdate, f_user, 'f_cessio', 1, 'cesionesrea sfacult:' || pfacult, SQLCODE || ' - ' || SQLERRM);
                        END;
                     ELSE
                        v_hiha_ces := 0;
                     END IF;

                     -->> AVT 21/01/2014  fi

                     ----dbms_outpuT.put_line(w_trobat || ' =1');
                     IF w_trobat = 1 AND v_hiha_ces = 0 THEN -->> AVT 21/01/2014
                        -- CPM 26/5/06: En lugar de la capacidad màxima del registro, cogemos
                        --  la capacidad del cumulo
                        ----dbms_outpuT.put_line(w_cestado || ' = 2 AND ' || w_switchgarant || ' <> 1 AND'
                        --                    || w_ifacced);
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 54, 'w_cestado: ' || w_cestado ||
                        ' w_switchgarant: ' || w_switchgarant || ' w_ifacced: ' || w_ifacced || ' icapital: ' || regaux1.icapital || ' lcapaci_cum: ' ||
                        lcapaci_cum);
                        --AGG 24/07/2014
                        v_base_rea     := NVL(pac_parametros.f_parproducto_n(w_sproduc, 'CESION_BASE_REA'), 0);

                        IF (w_cestado   = 2 AND w_switchgarant <> 1 AND w_ifacced = (regaux1.icapital - lcapaci_cum)) OR(w_cestado = 2 AND w_switchgarant = 1 AND
                              w_ifacced = (regaux1.icapital - lcapaci_cum)) THEN
                           -------             cessió...
                           BEGIN
                               UPDATE cesionesaux
                                 SET cestado     = 2, sfacult = pfacult
                                   WHERE nnumlin = regaux1.nnumlin
                                    AND sproces  = psproces;
                           EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              perr := 104695;
                              p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 55, 'Error: ' || perr);
                              RETURN(perr);
                           WHEN OTHERS THEN
                              perr := 104696;
                              p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 56, 'Error: ' || perr);
                              RETURN(perr);
                           END;
                        ELSE
                           -- 19484 cgesfac = 0-No generar QUADRE 1-Si generar QUADRE
                           IF pcgesfac = 1 THEN
                              cabfacul(regaux1);

                              IF perr <> 0 AND perr <> 99 THEN
                                 p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 57, 'Error: ' || perr);
                                 RETURN(perr);
                              END IF;

                              -- 19484 - AVT 02/01/2012
                              perr := 99;
                              p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 58, 'Error: ' || perr);
                           ELSE
                              --agg 15/04/2014
                              IF (ptablas = 'CAR' AND v_base_rea = 1) THEN
                                  UPDATE cuafacul
                                    SET ifacced     = regaux1.icapital - lcapaci_cum
                                      WHERE sfacult = pfacult;

                                 perr              := 0;
                              ELSE
                                 perr := 99;
                                 p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 59, 'Error: ' || perr);
                                 EXIT;
                              END IF;
                              --fin agg 15/04/2014
                           END IF;
                        END IF;
                     ELSE
                        -------          a taula pendent...
                        -- 19484 cgesfac = 0-No generar QUADRE 1-Si generar QUADRE
                        IF pcgesfac = 1 THEN
                           cabfacul(regaux1);

                           IF perr <> 0 AND perr <> 99 THEN
                              p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 60, 'Error: ' || perr);
                              RETURN(perr);
                           END IF;

                           -- 19484 - AVT 02/01/2012
                           perr := 99;
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 61, 'Error: ' || perr);
                        ELSE
                           --AGG 26/05/2014 Modificación para que no salte facultativo
                           --en la renovación de cartera para POSITIVA
                           IF (ptablas = 'CAR' AND v_base_rea = 1) THEN
                               UPDATE cuafacul
                                 SET ifacced     = regaux1.icapital - lcapaci_cum
                                   WHERE sfacult = pfacult;

                              perr              := 0;
                           ELSE
                              perr := 99;
                              p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 62, 'Error: ' || perr);
                              EXIT;
                           END IF;
                        END IF;
                     END IF;
                  ELSE
                     ------        cessió...
                     BEGIN
                         UPDATE cesionesaux
                           SET cestado     = 2, sfacult = NULL
                             WHERE nnumlin = regaux1.nnumlin
                              AND sproces  = psproces;
                     EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        perr := 104695;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 63, 'Error: ' || perr);
                        RETURN(perr);
                     WHEN OTHERS THEN
                        perr := 104696;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 64, 'Error: ' || perr);
                        RETURN(perr);
                     END;
                  END IF;
               END IF;
            ELSIF                                                                                                                 --BUG 21559 - INICIO - 23/05/2013 - DCT
               NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 1 AND w_gar_princ <> regaux1.cgarant THEN -- A les garanties no
               -- principals tb els hi actualitzem l'estat ............
               -->DBMS_OUTPUT.put_line('abans del UPDATE regaux1.cgarant:' || regaux1.cgarant);
               -- 21559 / 111590
               -- 22237 AVT 24/05/2012 PER SI TENIM ELS QUADRES JA COMPLERTS PER LA RESTA DE GARANTIES
               IF w_fac_princ = 1 THEN
                  ------        buscar facultatiu...
                  codi_error := f_facult(regaux1.sseguro, regaux1.nriesgo, regaux1.ccalif1, regaux1.ccalif2, regaux1.cgarant, NULL, NULL, regaux1.fconini,
                  regaux1.scumulo, w_trobat, w_cestado, pfacult, w_ifacced);

                  IF codi_error <> 0 THEN
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 65, 'Error: ' || codi_error);
                     RETURN(codi_error);
                  END IF;

                  -->> AVT 21/01/2014  inici control dels facultatius existents en cas de cúmul
                  IF NVL(regaux1.scumulo, 0) > 0 THEN
                     BEGIN
                         SELECT    COUNT( * )
                              INTO v_hiha_ces
                              FROM cesionesrea
                             WHERE sfacult = pfacult;
                     EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        v_hiha_ces := 0;
                     WHEN OTHERS THEN
                        v_hiha_ces := 0;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 66, 'Error facult ' || pfacult);
                        p_tab_error(f_sysdate, f_user, 'f_cessio', 1, 'cesionesrea sfacult:' || pfacult, SQLCODE || ' - ' || SQLERRM);
                     END;
                  ELSE
                     v_hiha_ces := 0;
                  END IF;

                  -->> AVT 21/01/2014  fi
                  IF w_trobat     = 1 AND v_hiha_ces = 0 THEN -->> AVT 21/01/2014
                     IF w_cestado = 2 THEN
                        ------              cessió...
                        BEGIN
                            UPDATE cesionesaux
                              SET sfacult     = pfacult
                                WHERE nnumlin = regaux1.nnumlin
                                 AND sproces  = psproces;
                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           perr := 104695;
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 67, 'Error: ' || perr);
                           RETURN(perr);
                        WHEN OTHERS THEN
                           perr := 104696;
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 68, 'Error: ' || perr);
                           RETURN(perr);
                        END;
                     ELSE
                        cabfacul(regaux1);

                        IF perr <> 0 AND perr <> 99 THEN
                           RETURN(perr);
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 69, 'Error: ' || perr);
                        END IF;

                        perr := 99;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 70, 'Error: ' || perr);
                     END IF;
                  ELSE
                     ------           a taula pendent...
                     cabfacul(regaux1);

                     IF perr <> 0 AND perr <> 99 THEN
                        RETURN(perr);
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 71, 'Error: ' || perr);
                     END IF;

                     perr := 99; -- El perr 99 significa que ja no es pot
                     -- fer cap cessió perquè falta algún facultatiu
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 72, 'Error: ' || perr);
                  END IF;
               END IF;

               -- 22237 AVT 24/05/2012 FI
                UPDATE cesionesaux
                  SET cestado     = 3
                    WHERE sproces = psproces
                     AND cgarant  = regaux1.cgarant
                     AND nnumlin  = regaux1.nnumlin;
            END IF; -- 21559 AVT 09/03/2012  fi-----------
         END LOOP;

         ------------------------------------------------------------------------
         -- PART 7:
         -- ******
         -- AQUI ES FAN REALMENT LES CESSIONS I S'ESBORRA FACPENDIENTES SI HI HAVIA
         -- QUELCOM...
         -- SI ES UN SUPLEMENT (MOTIU = 04), PRIMER ES CRIDA A UNA FUNCIÓ
         -- (F_ATRAS) QUE ANUL.LI LES ULTIMES CESSIONS CORRESPONENTS
         -- A TOT EL SEGURO AFECTAT I CREI PARTS PRORRATEJADES EN SIGNE CONTRARI,
         -- DESDE LA DATA DEL SUPLEMENT FINS AL VENCIMENT DEL SUPLEMENT...
         --KBR 05/03/2014 Solo debe entrar si las tablas son las definitivas: REA
         IF ptablas NOT IN('EST', 'CAR') THEN -- IGUALAR F_CESSIO / F_CESSIO_EST 28/10/2013
            IF perr <> 99 THEN                -- No falta cap facultatiu...
               -- Obtenim el nº nmovigen
               BEGIN
                   SELECT    NVL(MAX(nmovigen), 0) + 1
                        INTO lnmovigen
                        FROM cesionesrea
                       WHERE sseguro = w_sseguro;
               EXCEPTION
               WHEN OTHERS THEN
                  lnmovigen := 1;
               END;

               IF pmotiu         = 04 THEN -- Es un suplement...
                  codi_error    := f_atras(psproces, w_sseguro, w_fconini, 07, pmoneda, lnmovigen, pfdatagen);

                  IF codi_error <> 0 THEN
                     perr       := codi_error;
                                          P_CONTROL_ERROR('LRB','PAC_CESIONESREA', PERR);

                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 73, 'Error: ' || perr);
                     RETURN(perr);
                  END IF;
               END IF;

               FOR regaux1 IN cur_aux_1
               LOOP
                  --BUG 21559 - INICIO - 23/05/2013 - DCT
                  BEGIN -- Busquem si prima prorratejable o no...
                      SELECT    sproduc
                           INTO w_sproduc
                           FROM seguros
                          WHERE sseguro = regaux1.sseguro;
                  EXCEPTION
                  WHEN OTHERS THEN
                     perr := 101919;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 74, 'Error: ' || perr);
                     RETURN(perr);
                  END;

                  w_scumulo := regaux1.scumulo; -- AVT 15007 17-06-2010

                  -->DBMS_OUTPUT.put_line('regaux1.cestado:' || regaux1.cestado);
                  IF regaux1.cestado     = 2 THEN
                     IF regaux1.cfacult <> 1 THEN -- AVT 16-11-2011
                        -- bug: 14404 AVT 25-05-2010 una mateixa pòlissa pot tenir 2 ó més contractes de tipus diferent
                        BEGIN
                            SELECT    ctiprea
                                 INTO w_ctiprea -- 13195 AVT 16-02-2010
                                 FROM codicontratos
                                WHERE scontra = regaux1.scontra;
                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           perr := 104697;
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 75, 'Error: ' || perr);
                           RETURN(perr);
                        WHEN OTHERS THEN
                           perr := 104516;
                           p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 76, 'Error: ' || perr);
                           RETURN(perr);
                        END;
                     END IF;

                     -- BUG 10462: ETM:16/06/2009:--ANTES
                     -- 13195 AVT 16-02-2010 afegim w_sproduc, w_ctipre a la crida a la funció F_CES
                     codi_error    := f_ces(regaux1.nnumlin, pmotiu, regaux1.sfacult, lnmovigen, w_sproduc, w_ctiprea, w_ctipre_seg);

                     IF codi_error <> 0 THEN
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 77, 'Error: ' || codi_error);
                        RETURN(codi_error);
                     END IF;

                     --           AQUI ES CANVIA EL CTIPREA DE 3 A 0, SI ERA 3...(SENSE FACULTATIU
                     --           OPCIONALMENT)...I DE 5 A 0...(SUPLEMENT AMB FACULTATIU QUE S'HA
                     --           TIRAT ENDAVANT)...
                     BEGIN
                        IF w_ctipre_seg = 3 OR w_ctipre_seg = 5 THEN
                            UPDATE seguros
                              SET ctiprea     = 0
                                WHERE sseguro = regaux1.sseguro;
                        END IF;
                     EXCEPTION
                     WHEN OTHERS THEN
                        perr := 105841;
                        p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 78, 'Error: ' || perr);
                        RETURN(perr);
                     END;
                  END IF;

                  -->DBMS_OUTPUT.put_line('>>>>>>>>>>>>>>>>>>>>>> w_cempres:' || w_cempres);

                  -- 21559 AVT 09/03/2012 només reaprtim segons garantia principal --
                  --BUG 21559 - INICIO - 23/05/2013 - DCT
                  IF NVL(pac_parametros.f_parproducto_n(w_sproduc, 'GAR_PRINCIPAL_REA'), 0) = 1 AND w_gar_princ <> regaux1.cgarant THEN -- 21559 / 111590
                     -->DBMS_OUTPUT.put_line('>>>>>>>>>>>>>>>>>>>>>>regaux1.cgarant:' || regaux1.cgarant
                     -->                  || ' regaux1.cestado:' || regaux1.cestado);
                     IF regaux1.cestado = 3 THEN
                        -->DBMS_OUTPUT.put_line('>>>>>>>>>>>>>>>>>>>>>>abans cursro:' || w_cramo || '-'
                        -->                  || w_cmodali || '-' || w_ctipseg || '-' || w_ccolect
                        -->               || '-' || w_cactivi || '-' || psproces);
                        FOR reg IN garantia_principal(w_gar_princ, psproces, regaux1.sseguro, regaux1.nmovimi, pmotiu)
                        LOOP
                           -->DBMS_OUTPUT.put_line('>>>>>>>>>>>>>>>>>>>>>despres cursro:' || w_cramo
                           -->                  || '-' || w_cmodali || '-' || w_ctipseg || '-'
                           -->               || w_ccolect || '-' || w_cactivi || '-' || psproces);
                            SELECT    *
                                 INTO registre
                                 FROM cesionesaux
                                WHERE nnumlin = regaux1.nnumlin
                                 AND sproces  = psproces;

                           -- variables globals que s'estan actualitzan a F_CES INI --
                           -->>>>>>>>w_porce := reg.pcesion / 100;
                           w_nmovigen := lnmovigen;
                           avui       := pfdatagen;
                           ------------------------------------------ F_CES FI -------
                           -->DBMS_OUTPUT.put_line('8. registre.iprirea:' || registre.iprirea);
                           -- w_capital := regaux1.icapital * reg.pcesion / 100; -- 22666 - GAG  - 27/07/2012
                           --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                           --w_capital    := regaux1.icapital * reg.icapces / w_capital_principal; -- 22666 - GAG  - 27/07/2012
                           w_capital := regaux1.icapital * (reg.icapces / pac_eco_tipocambio.f_cambio (w_monpol, w_moninst, pfdatagen)) / w_capital_principal; 
                           --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros

                           IF reg.ctramo = 5 THEN
                              --perr := f_insert_ces(w_capital, reg.ctramo, regaux1.sfacult, 0,  -- 22666 - GAG  - 27/07/2012
                              --                     reg.pcesion / 100, w_sproduc);             -- 22666 - GAG  - 27/07/2012
                              --INFORCOL INICIO 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
							  --perr := f_insert_ces(w_capital, reg.ctramo, regaux1.sfacult, 0, -- 22666 - GAG  - 27/07/2012
                              --reg.icapces / w_capital_principal, w_sproduc, pcgesfac);        -- 22666 - GAG  - 27/07/2012
                              perr := f_insert_ces(w_capital, reg.ctramo, regaux1.sfacult,0,(reg.icapces / pac_eco_tipocambio.f_cambio (w_monpol, w_moninst, pfdatagen)) / w_capital_principal, w_sproduc, pcgesfac);
                              --INFORCOL FIN 06-05-2020 Bug 10555-10556 Facultativo Dolares/Euros
                           ELSE
                              --perr := f_insert_ces(w_capital, reg.ctramo, NULL, 0, reg.pcesion  -- 22666 - GAG  - 27/07/2012
                              --/  100, w_sproduc);                      -- 22666 - GAG  - 27/07/2012
                              perr := f_insert_ces(w_capital, reg.ctramo, NULL, 0,     -- 22666 - GAG  - 27/07/2012
                              reg.icapces / w_capital_principal, w_sproduc, pcgesfac); -- 22666 - GAG  - 27/07/2012
                           END IF;

                           IF perr <> 0 THEN
                              p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 79, 'Error: ' || perr);
                              RETURN(perr);
                           END IF;
                        END LOOP;
                     END IF;
                  END IF; -- 21559 AVT 09/03/2012 -------------
               END LOOP;
               --   ELSIF perr = 99 THEN   -- 21559 AVT 09/03/2012 només reaprtim segons garantia principal --
               --      FOR regaux1 IN cur_aux_1 LOOP
               --         IF NVL(pac_parametros.f_parempresa_n(w_cempres, 'GAR_PRINCIPAL_REA'), 0) = 1
               --            AND w_gar_princ <> regaux1.cgarant THEN   -- 21559 / 111590
               --            cabfacul(regaux1);

               --            IF perr <> 0
               --               AND perr <> 99 THEN
               --               RETURN(perr);
               --            END IF;
               --         END IF;
               --      END LOOP;
            END IF;
         END IF;

         ---------------------------------
         -- PART 8:
         -- ******
         -- AIXO ES EL FINAL...
         --IF perr = 0          -- 9. 20606: LCOL_T004-LCOL_T001- Recalcul de les cessions - Nota:0101205
         --   OR perr = 99 THEN -- 9. 20606: LCOL_T004-LCOL_T001- Recalcul de les cessions - Nota:0101205
         --BUG 32363 - DCT - 25/07/2014
         IF NVL(pcgesfac, 0) = 0 AND ptablas = 'EST' THEN
            BEGIN
               --BUG 0036059 - DCT - 02/09/2015. Borramos reariesgos que no esten tambie´n en la tabla cesionesaux
               --BUG 18981 JRB -
                DELETE
                     FROM reariesgos r
                    WHERE r.sseguro = w_sseguro
                     AND NOT EXISTS
                     (SELECT    1
                           FROM cesionesrea c
                          WHERE c.sseguro = r.sseguro
                           AND c.scumulo  = r.scumulo
                       UNION
                      SELECT    1
                           FROM cesionesaux c2
                          WHERE c2.sseguro = r.sseguro
                           AND c2.scumulo  = r.scumulo
                     );
               -- AVT 05/12/2013 evitar deje registros en reariesgos
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 80, 'Error no_data_found: ' || perr);
            WHEN OTHERS THEN
               perr := 104666;
               p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 80, 'Error: ' || perr);
               RETURN(perr);
            END;
         END IF;

         BEGIN
             DELETE
                  FROM cesionesaux
                 WHERE sproces = psproces;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
         WHEN OTHERS THEN
            perr := 104703;
            p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 81, 'Error: ' || perr);
            RETURN(perr);
         END;

         -- END IF;

         -- 15007 AVT 17-06-2010 En cas de suplement d'una pòlissa amb cúmul recalculem la resta de pòlisses --
         --KBR 05/03/2014 Solo debe entrar si las tablas son las definitivas: REA
         IF ptablas NOT IN('EST', 'CAR') THEN                                         -- IGUALAR F_CESSIO / F_CESSIO_EST 28/10/2013
            IF perr       = 0                                                         -- 9. 20606: LCOL_T004-LCOL_T001- Recalcul de les cessions - Nota:0101205
               AND pmotiu = 04 AND w_scumulo IS NOT NULL AND NVL(pfacult, 0) = 0 THEN -- 19484 AVT 04/01/2012 Només recosntruirem la resta de cessions sinó
               -- necessita quadre facultatiu
               --BUG 19484 - 19/10/2011 - JRB - Se añade la empresa por parámetro.
                SELECT    cempres
                     INTO w_cempres
                     FROM seguros seg
                    WHERE seg.sseguro = w_sseguro;

               codi_error            := pac_cesionesrea.f_recalcula_cumul(w_sseguro, w_fconini, psproces, w_cempres);

               IF codi_error         <> 0 THEN
                  perr               := codi_error;
                  p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 82, 'Error: ' || perr);
                  RETURN(perr);
               ELSE
                  BEGIN
                      DELETE
                           FROM cesionesaux
                          WHERE sproces = psproces;
                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     NULL;
                  WHEN OTHERS THEN
                     perr := 104703;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 83, 'Error: ' || perr);
                     RETURN(perr);
                  END;
               END IF;
            END IF;

            -- BUG: 22686 - AVT -25/07/2012 es dona de baixa la pòlissa que tot i formar part del cúmul ja està anulada
            IF perr = 0 AND pmotiu IN(03, 05) AND w_scumulo IS NOT NULL AND NVL(pfacult, 0) = 0 THEN
               -- es busquen pòlisses del cúmul anul·lades
               FOR reg IN riesgos_anul(w_scumulo)
               LOOP
                  codi_error    := pac_anulacion.f_baja_rea(reg.sseguro, reg.fanulac, pmoneda);

                  IF codi_error <> 0 THEN
                     perr       := codi_error;
                     p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 84, 'Error: ' || perr);
                     p_tab_error(f_sysdate, f_user, 'f_cessio', 1, 'pac_anulacion.f_baja_rea:' || reg.sseguro || ' - ' || reg.fanulac || ' - ' || pmoneda,
                     codi_error);
                     RETURN(perr);
                  END IF;
               END LOOP;
            END IF;
         END IF;

         -- BUG: 22686 - AVT -25/07/2012  fi -------------------------
         ----dbms_outpuT.put_line('ffacult:' || perr);
         p_traza_proceso(w_cempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, 85, 'Error: ' || perr);
         END IF;--BUG CONF-250  Fecha (02/09/2016) - HRE
         RETURN(perr);
      EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'final F_Cessio_est =' || psproces || '  w_sseguro:' || w_sseguro, NULL, SUBSTR('error incontrolado', 1, 500), SQLERRM)
         ;
         RETURN(perr);
      END f_cessio_est;

      FUNCTION f_renovacion_anual_rea(
            psseguro IN NUMBER,
            pfcaranu IN DATE,
            ptablas IN VARCHAR2 DEFAULT NULL)
         RETURN DATE
      IS
         v_frenova DATE;
         hiha      NUMBER;
         v_sproduc NUMBER;
         v_fefecto DATE;
         v_count_renova number :=0;--BUG CONF-479  Fecha (20/01/2017) - HRE - suplemento aumento de valor
      BEGIN
         IF ptablas = 'EST' THEN
             SELECT    sproduc, fefecto
                  INTO v_sproduc, v_fefecto
                  FROM estseguros
                 WHERE sseguro = psseguro;
         ELSE
             SELECT    sproduc, fefecto
                  INTO v_sproduc, v_fefecto
                  FROM seguros
                 WHERE sseguro = psseguro;
         END IF;

         IF ptablas = 'EST' THEN
            BEGIN
                SELECT    TO_DATE(trespue, 'dd/mm/yyyy')
                     INTO v_fefecto
                     FROM estpregunpolseg a
                    WHERE a.sseguro = psseguro
                     AND a.nmovimi  =
                     (SELECT    MAX(nmovimi)
                           FROM estpregunpolseg b
                          WHERE b.sseguro = psseguro
                           AND b.sseguro  = a.sseguro
                           AND b.cpregun  = a.cpregun
                     )
                     AND a.cpregun = 4044; -- Fecha inicial de vigencia póliza original (dd/mm/yyyy)
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                   SELECT    TO_DATE(crespue, 'yyyymmdd')
                        INTO v_fefecto
                        FROM estpregunpolseg a
                       WHERE a.sseguro = psseguro
                        AND a.nmovimi  =
                        (SELECT    MAX(nmovimi)
                              FROM estpregunpolseg b
                             WHERE b.sseguro = psseguro
                              AND b.sseguro  = a.sseguro
                              AND b.cpregun  = a.cpregun
                        )
                        AND a.cpregun = 4046; -- Fecha de efecto migración (dd/mm/yyyy)
               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_fefecto := v_fefecto;
               END;
            END;
         ELSE
            BEGIN
                SELECT    TO_DATE(trespue, 'dd/mm/yyyy')
                     INTO v_fefecto
                     FROM pregunpolseg a
                    WHERE a.sseguro = psseguro
                     AND a.nmovimi  =
                     (SELECT    MAX(nmovimi)
                           FROM pregunpolseg b
                          WHERE b.sseguro = psseguro
                           AND b.sseguro  = a.sseguro
                           AND b.cpregun  = a.cpregun
                     )
                     AND a.cpregun = 4044; -- Fecha inicial de vigencia póliza original (dd/mm/yyyy)
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                   SELECT    TO_DATE(crespue, 'yyyymmdd')
                        INTO v_fefecto
                        FROM pregunpolseg a
                       WHERE a.sseguro = psseguro
                        AND a.nmovimi  =
                        (SELECT    MAX(nmovimi)
                              FROM pregunpolseg b
                             WHERE b.sseguro = psseguro
                              AND b.sseguro  = a.sseguro
                              AND b.cpregun  = a.cpregun
                        )
                        AND a.cpregun = 4046; -- Fecha de efecto migración (dd/mm/yyyy)
               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_fefecto := v_fefecto;
               END;
            END;
         END IF;

         -- 26321 KBR 05/03/2013 Cambiamos parámetro técnico por uno propio del reaseguro
         IF NVL(pac_parametros.f_parproducto_n(v_sproduc, 'PER_REV_NO_ANUAL_REA'), 0) IN(150) THEN
            v_frenova := v_fefecto;
         ELSE
            --INI BUG CONF-479  Fecha (20/01/2017) - HRE - Suplemento de aumento de valor
            IF pac_md_common.f_get_cxtempresa = 24 THEN
               SELECT COUNT(nmovimi)
                 INTO v_count_renova
                 FROM movseguro
                WHERE cmotmov = 404
                  AND sseguro = psseguro
                  AND fanulac IS NULL;

               IF NVL(pac_parametros.f_parproducto_n(v_sproduc, 'PER_REV_NO_ANUAL_REA'), 0) > 1
                  AND NVL(pac_parametros.f_parproducto_n(v_sproduc, 'PER_REV_NO_ANUAL_REA'), 0) <= v_count_renova THEN
                  v_frenova := v_fefecto;
                  RETURN v_frenova;
               END IF;
            END IF;
            --FIN BUG CONF-479  - Fecha (20/01/2017) - HRE
            IF ptablas    = 'EST' THEN
               v_frenova := TO_DATE(pac_seguros.ff_frenovacion(NULL, psseguro, 1), 'YYYYMMDD');
            ELSE
               v_frenova := TO_DATE(pac_seguros.ff_frenovacion(NULL, psseguro, 2), 'YYYYMMDD');
            END IF;

            IF v_frenova  < v_fefecto THEN
               v_frenova := v_fefecto;
            END IF;
         END IF;

         RETURN v_frenova;
      END f_renovacion_anual_rea;

   --Bug:28358 AGG 03/10/2013
   FUNCTION f_capital(
         psesion IN NUMBER,
         psseguro IN NUMBER,
         pnriesgo IN NUMBER,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pfefecto IN NUMBER,
         psproduc IN NUMBER,
         pngarantia IN NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER
   IS
      ------------------------------------------------------------------------------------
      -- Cúmuls automàtics
      -- Es llegeix de la taula cumulprod on ens diu quins productes poden fer cúmul
      -- entre ells
      ------------------------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_REACUMUL_EST';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || 's=' || psseguro || ' r=' || pnriesgo || ' c=' || pscontra || ' v=' || pnversio || 'e=' || pfefecto || ' p=' || psproduc
      || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      lctipcum NUMBER;
      lasseg   NUMBER;
      lscumulo NUMBER;
      lcum cumulos%ROWTYPE;
      num_err   NUMBER;
      lsseg     NUMBER;
      lccumprod NUMBER;
      waux      NUMBER := 0;
      w_sseguro NUMBER;
      w_nriesgo NUMBER(6);
      w_cgarant NUMBER(4);
      w_cramo   NUMBER(8);
      w_cmodali NUMBER(2);
      w_ctipseg NUMBER(2);
      w_ccolect NUMBER(2);
      w_creaseg NUMBER(1);
      w_cactivi NUMBER(4);
      vcapces   NUMBER := 0;
      v_tipo    NUMBER := 0;

      CURSOR cur_reariesgos
      IS
          SELECT    sseguro, nriesgo, cgarant, freaini
               FROM reariesgos
              WHERE scumulo = lctipcum
               AND freaini <= TO_DATE(pfefecto)
               AND(freafin IS NULL
               OR freafin   > TO_DATE(pfefecto))
               AND(cgarant  = pngarantia
               OR cgarant  IS NULL); -- 13195 01-03-2010 AVT

      CURSOR cur_garanseg
      IS
          SELECT    icapital, cgarant
               FROM garanseg
              WHERE sseguro  = w_sseguro
               AND nriesgo   = w_nriesgo
               AND(cgarant   = w_cgarant
               OR w_cgarant IS NULL)
               AND ffinefe  IS NULL;
   BEGIN
      -- Obtenim el tipus de cumul per aquest contracte
      BEGIN
         v_errlin := 4000;

          SELECT    ctipcum
               INTO lctipcum
               FROM codicontratos
              WHERE scontra = pscontra;
      EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         RETURN 104516;
      END;

      IF NVL(lctipcum, 0) = 0 THEN
         RETURN 0; -- Els manuals no es fa rès
      END IF;

      -- Obtenir el risc assegurat de la pòlissa
      -- 19484 --
      BEGIN
         v_errlin  := 4010;

         IF ptablas = 'EST' THEN
             SELECT    spereal
                  INTO lasseg
                  FROM estriesgos r, estper_personas p
                 WHERE r.sseguro = psseguro
                  AND r.nriesgo  = pnriesgo
                  AND r.sperson  = p.sperson;
         ELSIF ptablas           = 'CAR' THEN
             SELECT    sperson
                  INTO lasseg
                  FROM riesgos
                 WHERE sseguro = psseguro
                  AND nriesgo  = pnriesgo;
         ELSE
             SELECT    sperson
                  INTO lasseg
                  FROM riesgos
                 WHERE sseguro = psseguro
                  AND nriesgo  = pnriesgo;
         END IF;
      EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         RETURN 120007;
      END;

      -- Obtenim el codi del cúmul per producte
      BEGIN
         v_errlin := 4020;

          SELECT    ccumprod
               INTO lccumprod
               FROM cumulprod
              WHERE sproduc = psproduc
               AND finiefe <= TO_DATE(pfefecto, 'yyyymmdd')
               AND(ffinefe IS NULL
               OR ffinefe   > TO_DATE(pfefecto, 'yyyymmdd'));
      EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
         RETURN 40301;
      END;

      -- Mirem si ja existeix un cumul per aquesta persona i aquest conjunt de productes
      -- que fan cúmul
      lscumulo := NULL;

      BEGIN
         v_errlin := 4030;

         -- 13946 AVT 12-04-2010 s'afegeix el SCONTRA i la NVERSIO.
         SELECT DISTINCT c.scumulo, c.fcumini, c.fcumfin, c.ccumprod, c.sperson, c.ctipcum, c.cramo, c.sproduc,
               c.czona--BUG CONF-294  Fecha (09/11/2016) - HRE - se agrega la zona
               INTO lcum
               FROM cumulos c, reariesgos r
               --<<< AVT 12-04-2010
              WHERE sperson  = lasseg
               AND ccumprod  = lccumprod
               AND c.scumulo = r.scumulo
               AND r.scontra = pscontra
               AND r.nversio = pnversio
               AND fcumfin  IS NULL;

         lscumulo           := lcum.scumulo;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         lscumulo := NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' a=' || lasseg || ' c=' || lccumprod);
         RETURN 104665;
      END;

      v_tipo := f_capital_cumul(1, lscumulo, TO_DATE(pfefecto, 'yyyymmdd'), pngarantia, vcapces);
      RETURN vcapces;
   END f_capital;
/******************************************************************************************************/
--INICIO - BUG38692 - DCT - 17/11/2015
   FUNCTION f_calcula_vto_poliza(
         pfrenova DATE,
         pnrenova NUMBER,
         pfefecto DATE,
         pcramo   NUMBER,
         pcmodali NUMBER,
         pctipseg NUMBER,
         pccolect NUMBER)
      RETURN DATE
   IS
      dd        VARCHAR2(2);
      ddmm      VARCHAR2(4);
      fvtopol   DATE;
      v_ctipefe NUMBER(1);
      fecha_aux DATE;
   BEGIN
      IF pfrenova IS NOT NULL THEN
         dd       := TO_CHAR(pfrenova, 'dd');
         ddmm     := TO_CHAR(pfrenova, 'ddmm');
      ELSE
         dd   := SUBSTR(LPAD(pnrenova, 4, 0), 3, 2);
         ddmm := dd || SUBSTR(LPAD(pnrenova, 4, 0), 1, 2);
      END IF;

      IF pfrenova IS NOT NULL THEN
         fvtopol  := pfrenova;
      ELSE
         BEGIN
            IF TO_CHAR(pfefecto, 'DDMM') = ddmm OR LPAD(pnrenova, 4, 0) IS NULL THEN
               fvtopol                  := f_summeses(pfefecto, 12, dd);
            ELSE
               BEGIN
                   SELECT    ctipefe
                        INTO v_ctipefe
                        FROM productos
                       WHERE cramo  = pcramo
                        AND cmodali = pcmodali
                        AND ctipseg = pctipseg
                        AND ccolect = pccolect;
               EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_cesionesrea.f_calcula_vto_poliza', 1, 'pfrenova = ' || pfrenova || ' pnrenova = ' || pnrenova ||
                  ' pfefecto = ' || pfefecto || ' pcramo = ' || pcramo || ' pcmodali = ' || pcmodali || ' pctipseg = ' || pctipseg || ' pccolect = ' ||
                  pccolect, SQLERRM);
               END;

               IF v_ctipefe  = 2 THEN -- a día 1/mes por exceso
                  fecha_aux := ADD_MONTHS(pfefecto, 13);
                  fvtopol   := TO_DATE(ddmm || TO_CHAR(fecha_aux, 'YYYY'), 'DDMMYYYY');
               ELSE
                  BEGIN
                     fvtopol := TO_DATE(ddmm || TO_CHAR(pfefecto, 'YYYY'), 'DDMMYYYY');
                  EXCEPTION
                  WHEN OTHERS THEN
                     IF ddmm     = 2902 THEN
                        ddmm    := 2802;
                        fvtopol := TO_DATE(ddmm || TO_CHAR(pfefecto, 'YYYY'), 'DDMMYYYY');
                     END IF;
                  END;
               END IF;
            END IF;
         END;
      END IF;

      RETURN fvtopol;
   END f_calcula_vto_poliza;
--FIN - BUG38692 - DCT - 17/11/2015
/******************************************************************************************************/
--INICIO BUG 41728-234063 --JCP 25/04/2016
   FUNCTION f_control_cesion(
         ptabla IN VARCHAR2 DEFAULT 'REA',
         pcempres IN NUMBER,
         psseguro IN NUMBER,
         pnmovimi IN NUMBER,
         pnriesgo IN NUMBER,
         psproces IN NUMBER DEFAULT 0,
         pgenera_ces OUT NUMBER)
      RETURN NUMBER
   IS
      vobjectname VARCHAR2(500)         := 'PAC_CESIONESREA.F_CONTROL_CESION';
      vparam      VARCHAR2(500)         := 'ptabla:'||ptabla||' ,psseguro:'||psseguro||' ,pnmovimi:'||pnmovimi||' ,pnriesgo:'||pnriesgo;
      v_cgenrec codimotmov.cgenrec%TYPE := 1;
      vcapitalini   NUMBER                := 0;
      vcapitalfin   NUMBER                := 0;
      vprimaini     NUMBER                := 0;
      vprimafin     NUMBER                := 0;
      vpar_traza    VARCHAR2(80)          := 'TRAZA_CESIONES_REA'; -- 08/04/2014 AGG
      v_nom_paquete VARCHAR2(80)          := 'PAC_CESIONESREA';
      v_nom_funcion VARCHAR2(80)          := 'F_CONTROL_CESION';
      v_traza       NUMBER                := 0;
   BEGIN
      v_traza := 101;
      p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, v_traza, 'vparam: ' || vparam);
      IF pnmovimi > 1 THEN
         v_traza := 102;
         IF ptabla IN ('REA', 'CAR') THEN
            v_traza := 103;
            BEGIN
               --CAR
                SELECT    NVL (SUM (e.icapital), 0), NVL (SUM (e.iprianu), 0)
                     INTO vcapitalfin, vprimafin
                     FROM seguros s, garancar e, garanpro g
                    WHERE s.sseguro         = psseguro
                     AND e.sseguro          = s.sseguro
                     AND e.nriesgo          = pnriesgo
                     AND g.sproduc          = s.sproduc
                     AND g.cgarant          = e.cgarant
                     AND g.cactivi          = s.cactivi
                     AND NVL (g.creaseg, 1) = 1;
               p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, V_TRAZA, 'vcapitalfin, vprimafin: ' || vcapitalfin||', '||
               vprimafin);
               IF vcapitalfin = 0 AND vprimafin = 0 THEN
                  v_traza    := 104;
                  --REA
                   SELECT    NVL (SUM (e.icapital), 0), NVL (SUM (e.iprianu), 0)
                        INTO vcapitalfin, vprimafin
                        FROM seguros s, garanseg e, garanpro g
                       WHERE s.sseguro         = psseguro
                        AND e.sseguro          = s.sseguro
                        AND e.nmovimi          = pnmovimi
                        AND e.nriesgo          = pnriesgo
                        AND g.sproduc          = s.sproduc
                        AND g.cgarant          = e.cgarant
                        AND g.cactivi          = s.cactivi
                        AND NVL (g.creaseg, 1) = 1;
                  p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, V_TRAZA, 'vcapitalfin, vprimafin: ' || vcapitalfin||', '
                  ||vprimafin);
               END IF;
            EXCEPTION
            WHEN OTHERS THEN
               vcapitalfin := 0;
               vprimafin   := 0;
               p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, V_TRAZA, 'Error: ' || SQLERRM);
            END;
         ELSIF ptabla = 'EST' THEN
            v_traza  := 105;
            BEGIN
                SELECT    NVL (SUM (e.icapital), 0), NVL (SUM (e.iprianu), 0)
                     INTO vcapitalfin, vprimafin
                     FROM estseguros s, estgaranseg e, garanpro g
                    WHERE s.sseguro         = psseguro
                     AND e.sseguro          = s.sseguro
                     AND e.nmovimi          = pnmovimi
                     AND e.nriesgo          = pnriesgo
                     AND g.sproduc          = s.sproduc
                     AND g.cgarant          = e.cgarant
                     AND g.cactivi          = s.cactivi
                     AND NVL (e.cobliga, 1) = 1
                     AND NVL (g.creaseg, 1) = 1;
               p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, V_TRAZA, 'vcapitalfin, vprimafin: ' || vcapitalfin||', '||
               vprimafin);
            EXCEPTION
            WHEN OTHERS THEN
               vcapitalfin := 0;
               vprimafin   := 0;
               p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, V_TRAZA, 'Error: ' || SQLERRM);
            END;
         END IF;

         IF ptabla IN ('REA', 'CAR') THEN
            v_traza := 106;
            BEGIN
                SELECT    NVL (SUM (e.icapital), 0), NVL (SUM (e.iprianu), 0)
                     INTO vcapitalini, vprimaini
                     FROM seguros s, garanseg e, garanpro g
                    WHERE s.sseguro = psseguro
                     AND e.sseguro  = s.sseguro
                     AND e.nmovimi  =
                     (SELECT    MAX (nmovimi)
                           FROM garanseg e2
                          WHERE e2.sseguro = e.sseguro
                           AND e2.cgarant  = e.cgarant
                           AND e2.nriesgo  = e.nriesgo
                           AND e2.nmovimi  < pnmovimi
                     )
                     AND e.nriesgo          = pnriesgo
                     AND g.sproduc          = s.sproduc
                     AND g.cactivi          = s.cactivi
                     AND g.cgarant          = e.cgarant
                     AND NVL (g.creaseg, 1) = 1;
               p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, V_TRAZA, 'vcapitalini, vprimaini: ' || vcapitalini||', '||
               vprimaini);
            EXCEPTION
            WHEN OTHERS THEN
               vcapitalini := 0;
               vprimaini   := 0;
               p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, V_TRAZA, 'Error: ' || SQLERRM);
            END;
         ELSIF ptabla = 'EST' THEN
            v_traza  := 107;
            BEGIN
                SELECT    NVL (SUM (e.icapital), 0), NVL (SUM (e.iprianu), 0)
                     INTO vcapitalini, vprimaini
                     FROM estseguros s, garanseg e, garanpro g
                    WHERE s.sseguro = psseguro
                     AND e.sseguro  = s.ssegpol
                     AND e.nmovimi  =
                     (SELECT    MAX (nmovimi)
                           FROM garanseg e2
                          WHERE e2.sseguro = e.sseguro
                           AND e2.cgarant  = e.cgarant
                           AND e2.nriesgo  = e.nriesgo
                           AND e2.nmovimi <= pnmovimi
                     )
                     AND e.nriesgo          = pnriesgo
                     AND g.sproduc          = s.sproduc
                     AND g.cactivi          = s.cactivi
                     AND g.cgarant          = e.cgarant
                     AND NVL (g.creaseg, 1) = 1;
               p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, V_TRAZA, 'vcapitalini, vprimaini: ' || vcapitalini||', '||
               vprimaini);
            EXCEPTION
            WHEN OTHERS THEN
               vcapitalini := 0;
               vprimaini   := 0;
               p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, V_TRAZA, 'Error: ' || SQLERRM);
            END;
         END IF;
         v_traza                 := 108;

         IF NVL (vcapitalini, 0)  = NVL (vcapitalfin, 0) THEN --Si no hy cambio de capital no pedimos  mirar facultativo
            v_cgenrec            := 0;
            IF NVL(vprimaini, 0) <> NVL(vprimafin, 0) THEN -- si queremos modificar la Prima
               v_cgenrec         := 1;
            END IF;
         END IF;
         p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, V_TRAZA, 'v_cgenrec : ' || v_cgenrec );
      ELSE
         v_traza   := 109;
         v_cgenrec := 1;
         p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, V_TRAZA, 'v_cgenrec : ' || v_cgenrec );
      END IF;
      pgenera_ces := v_cgenrec;
      RETURN (0);
   EXCEPTION
   WHEN OTHERS THEN
      p_tab_error (f_sysdate, f_user, vobjectname, v_traza, vparam, 'ERROR: ' || SQLCODE || ' - ' || SQLERRM );
      p_traza_proceso(pcempres, vpar_traza, psproces, v_nom_paquete, v_nom_funcion, NULL, V_TRAZA, 'Error: ' || SQLERRM);
   END f_control_cesion;
--FIN BUG 41728-234063 --JCP 25/04/2016

   --INI BUG CONF-250  Fecha (02/09/2016) - HRE - creacion de funcion
   FUNCTION f_porcentaje_tramos_manual(pctramo IN tramos.ctramo%TYPE,
                                       pscontra IN tramos.scontra%TYPE,
                                       pnversio IN tramos.nversio%TYPE--,
                                       )
   RETURN NUMBER IS
      v_ptramo  NUMBER;

      CURSOR cur_ptramos IS
         SELECT ptramo
           FROM tramos
          WHERE scontra = pscontra
            AND nversio = pnversio
            AND ctramo = pctramo;

   BEGIN
     OPEN cur_ptramos;
     FETCH cur_ptramos INTO v_ptramo;
     CLOSE cur_ptramos;
     --
     RETURN ROUND(v_ptramo/100,5);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_cesionesrea', 1,
                     'f_porcentaje_tramos_manual . Error WHEN OTHERS.  pscontra = ' || pscontra||
                     ' pnversio:'||pnversio, SQLERRM);
         RETURN NULL;

   END f_porcentaje_tramos_manual;
   --INI BUG CONF-294 Fecha (09/11/2016) - HRE - Cumulos por tomador y zona geografica
   FUNCTION f_crea_cumul_tomador(pfefecto IN DATE, pctipcum IN NUMBER, pccumprod IN NUMBER, pscontra IN NUMBER, pnversio IN NUMBER, psseguro IN NUMBER, ptablas IN VARCHAR2,
                                 pscumulo OUT NUMBER
                                 )
      RETURN NUMBER IS
      CURSOR c_pol(wsseguro NUMBER, wccumprod NUMBER, wfefecto DATE,
                   wscontra NUMBER, wnversio NUMBER) IS
         SELECT DISTINCT s.sseguro, r.nriesgo, r.fefecto, c.scontra, c.nversio, t.sperson
                    FROM seguros s, riesgos r, cesionesrea c, tomadores t
                   WHERE s.sseguro = r.sseguro
                     AND t.sseguro = s.sseguro
                     AND t.sperson = (select sperson from tomadores where sseguro = wsseguro and nordtom = 1 AND
                                             ptablas != 'EST'
                                      UNION
                                      select spereal FROM estper_personas
                                        WHERE sperson = (select sperson
                                                            from esttomadores
                                                             where sseguro = wsseguro and nordtom = 1)

                                          AND ptablas = 'EST'
                                         )
                     AND c.scontra = wscontra
                     AND c.nversio = wnversio
                     AND s.sseguro <> wsseguro
                     AND s.sproduc IN(SELECT sproduc
                                        FROM cumulprod
                                       WHERE ccumprod = wccumprod)
                     AND s.sseguro = c.sseguro
                     AND r.nriesgo = c.nriesgo
                     AND c.cgenera IN(01, 03, 04, 05, 09, 40)
                     AND c.fefecto <= wfefecto
                     AND c.fvencim > wfefecto
                     AND(c.fanulac > wfefecto
                         OR c.fanulac IS NULL)
                     AND(c.fregula > wfefecto
                         OR c.fregula IS NULL)
                     AND s.csituac < 7
                     AND s.csituac != 4;

      lprimer        NUMBER := 0;
      lnom           descumulos.tobserv%TYPE;
      waux           NUMBER := 0;
      v_errlin       NUMBER;
      v_errfun       NUMBER;
      v_errpar       NUMBER;
   --
   BEGIN
      IF pscumulo IS NULL THEN
         FOR v_pol IN c_pol(psseguro, pccumprod, pfefecto, pscontra, pnversio) LOOP
            IF lprimer = 0 THEN
               lprimer := 1;

               BEGIN
                  v_errlin := 3050;
                  SELECT scumulo.NEXTVAL
                    INTO pscumulo
                    FROM DUAL;

                  v_errlin := 3060;

                  INSERT INTO cumulos
                              (scumulo, fcumini, fcumfin, sperson, ctipcum, ccumprod)
                       VALUES (pscumulo, pfefecto, NULL, v_pol.sperson, pctipcum, pccumprod);
               ---->-- -- dbms_output.put_line(' insert cap del cúmul ');
               EXCEPTION
                  WHEN OTHERS THEN
                     -->-- -- dbms_output.put_line(SQLERRM);
                     p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
                     RETURN 150963;
               END;

               BEGIN
                  -- Descripcció
                  v_errlin := 3060;
                  SELECT nnumide
                    INTO lnom
                    FROM per_personas
                   WHERE sperson = v_pol.sperson;
                  -- fin Bug 0012803 - 19/02/2010 - JMF: AGA - Acceso a la vista PERSONAS
                  FOR reg IN (SELECT cidioma
                                FROM idiomas) LOOP
                     v_errlin := 3070;

                     INSERT INTO descumulos
                                 (scumulo, cidioma, tdescri, tobserv)
                          VALUES (pscumulo, reg.cidioma, SUBSTR(lnom, 1, 40), lnom);
                  END LOOP;
               -- Modif. Francesc Alférez.f.
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
                     RETURN 150964;
               END;
            END IF;

            BEGIN
               v_errlin := 3080;

               SELECT 1
                 INTO waux
                 FROM reariesgos
                WHERE sseguro = v_pol.sseguro
                  AND nriesgo = v_pol.nriesgo
                  AND freaini = pfefecto
                  AND scumulo = pscumulo
                  AND scontra = pscontra
                  AND nversio = pnversio
                  AND freafin IS NULL;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_errlin := 3090;

                  BEGIN
                     INSERT INTO reariesgos
                                 (sseguro, nriesgo, freaini, scumulo, scontra,
                                  freafin, nversio)
                          VALUES (v_pol.sseguro, v_pol.nriesgo, pfefecto, pscumulo, pscontra,
                                  NULL, pnversio);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
                        RETURN 150964;
                  END;
            END;

            v_errlin := 3095;
            -- 13946 AVT 06-04-2010 s'afegeix el SCONTRA i la NVERSIO.
            BEGIN
               UPDATE cesionesrea
                  SET scumulo = pscumulo
                WHERE sseguro = v_pol.sseguro
                  AND nriesgo = v_pol.nriesgo
                  AND scontra = pscontra
                  AND nversio = pnversio
                  AND cgenera IN(01, 03, 04, 05, 09, 40)
                  AND fefecto <= pfefecto
                  AND fvencim > pfefecto
                  AND(fanulac > pfefecto
                      OR fanulac IS NULL)
                  AND(fregula > pfefecto
                      OR fregula IS NULL);
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
                  RETURN 104859;
            END;
         ---->-- -- dbms_output.put_line(' actual. cesionesrea '||sql%ROWCOUNT);
         END LOOP;
      END IF;

      RETURN 0;
   END f_crea_cumul_tomador;

   FUNCTION f_crea_cumul_zona(lasseg IN NUMBER, pfefecto IN DATE, pctipcum IN NUMBER, pccumprod IN NUMBER, pscontra IN NUMBER, pnversio IN NUMBER, psseguro IN NUMBER, pscumulo OUT NUMBER)
      RETURN NUMBER IS

      CURSOR c_pol(wsseguro NUMBER, wccumprod NUMBER, wfefecto DATE,
                   wscontra NUMBER, wnversio NUMBER) IS
         SELECT DISTINCT s.sseguro, r.nriesgo, r.fefecto, c.scontra, c.nversio, t.sperson
                    FROM seguros s, riesgos r, cesionesrea c, tomadores t
                   WHERE s.sseguro = r.sseguro
                     AND s.sseguro = t.sseguro
                     AND s.sseguro IN (select sseguro
                                         from seguros seg2
                                        where NVL(pac_preguntas.ff_buscapregunseg(seg2.sseguro, 1, 9748,NULL),0)  != 0   )
                     AND c.scontra = wscontra
                     AND c.nversio = wnversio
                     AND s.sseguro <> wsseguro   -- No ens retorni la pòlissa actual
                     AND s.sproduc IN(SELECT sproduc
                                        FROM cumulprod
                                       WHERE ccumprod = wccumprod)
                     AND s.sseguro = c.sseguro
                     AND r.nriesgo = c.nriesgo
                     AND c.cgenera IN(01, 03, 04, 05, 09, 40)
                     AND c.fefecto <= wfefecto
                     AND c.fvencim > wfefecto
                     AND(c.fanulac > wfefecto
                         OR c.fanulac IS NULL)
                     AND(c.fregula > wfefecto
                         OR c.fregula IS NULL)
                     AND s.csituac < 7
                     AND s.csituac != 4;   --> JGR
      lprimer        NUMBER := 0;
      lnom           descumulos.tobserv%TYPE;
      waux           NUMBER := 0;
      v_errlin NUMBER;
      v_errfun NUMBER;
      v_errpar NUMBER;
      v_czona  NUMBER;
      v_tzona  VARCHAR2(150);
      v_aseg   tomadores.sperson%TYPE;
   --
   BEGIN
      p_traza_proceso(24, 'TRAZA_CESIONES_REA', NULL, 'PAC_CESIONESREA', 'F_CREA_CUMUL_ZONA', NULL, 7771,'inicio, pscumulo:'||pscumulo);
      v_aseg := lasseg;
      IF pscumulo IS NULL THEN
         p_traza_proceso(24, 'TRAZA_CESIONES_REA', NULL, 'PAC_CESIONESREA', 'F_CREA_CUMUL_ZONA', NULL, 7772,'psseguro:'||psseguro||
                         ' pccumprod:'||pccumprod||' pfefecto:'||pfefecto||' pscontra:'||pscontra||' pnversio:'||
                         pnversio);

         BEGIN
         SELECT crespue
           INTO v_czona
           FROM estpregunseg a
          WHERE sseguro = psseguro
            AND nriesgo = 1
            AND cpregun = 9748
            AND nmovimi = (SELECT MAX(b.nmovimi)
                             FROM estpregunseg b
                            WHERE b.sseguro = psseguro
                              AND b.nriesgo = 1
                              AND b.cpregun = 9748
                              );
           p_traza_proceso(24, 'TRAZA_CESIONES_REA', NULL, 'PAC_CESIONESREA', 'F_CREA_CUMUL_ZONA', NULL, 77721,'paso 0,
                                v_czona:'||v_czona);
           EXCEPTION

           WHEN NO_DATA_FOUND THEN
         p_traza_proceso(24, 'TRAZA_CESIONES_REA', NULL, 'PAC_CESIONESREA', 'F_CREA_CUMUL_ZONA', NULL, 77723,'paso 2,
         v_czona:'||v_czona);

             BEGIN
               SELECT crespue
                 INTO v_czona
                 FROM pregunseg a
                WHERE sseguro = psseguro
                  AND nriesgo = 1
                  AND cpregun = 9748
                  AND nmovimi = (SELECT MAX(c11.nmovimi)
                                   FROM pregunseg c11
                                  WHERE c11.sseguro =  psseguro
                                    AND c11.nriesgo = 1
                                    AND c11.cpregun = 9748
                                  );

         p_traza_proceso(24, 'TRAZA_CESIONES_REA', NULL, 'PAC_CESIONESREA', 'F_CREA_CUMUL_ZONA', NULL, 77724,'paso 3,
         v_czona:'||v_czona);

           EXCEPTION
           WHEN OTHERS THEN
           p_traza_proceso(24, 'TRAZA_CESIONES_REA', NULL, 'PAC_CESIONESREA', 'F_CREA_CUMUL_ZONA', NULL, 77725,'paso 4,
           v_czona:'||v_czona);

             v_czona := NULL;
           END;
           WHEN OTHERS THEN
         p_traza_proceso(24, 'TRAZA_CESIONES_REA', NULL, 'PAC_CESIONESREA', 'F_CREA_CUMUL_ZONA', NULL, 77726,'paso 5,
         v_czona:'||v_czona);

             v_czona := NULL;
           END;

         p_traza_proceso(24, 'TRAZA_CESIONES_REA', NULL, 'PAC_CESIONESREA', 'F_CREA_CUMUL_ZONA', NULL, 77727,'paso 6,
         v_czona:'||v_czona);

              p_traza_proceso(24, 'TRAZA_CESIONES_REA', NULL, 'PAC_CESIONESREA', 'F_CREA_CUMUL_ZONA', NULL, 7773,'psseguro:'||psseguro||
               ' pccumprod:'||pccumprod||' pfefecto:'||pfefecto||' pscontra:'||pscontra||' pnversio:'||
               pnversio);

               BEGIN
                  v_errlin := 3050;

                  SELECT scumulo.NEXTVAL
                    INTO pscumulo
                    FROM DUAL;

                  v_errlin := 3060;

         p_traza_proceso(24, 'TRAZA_CESIONES_REA', NULL, 'PAC_CESIONESREA', 'F_CREA_CUMUL_ZONA', NULL, 7774,'psseguro:'||psseguro||
                         ' pccumprod:'||pccumprod||' pfefecto:'||pfefecto||' pscontra:'||pscontra||' pnversio:'||
                         pnversio||' v_aseg:'||v_aseg);
                  IF (v_aseg IS NULL) THEN
                     SELECT sperson
                       INTO v_aseg
                       FROM tomadores
                      WHERE sseguro = psseguro;

                  END IF;

         p_traza_proceso(24, 'TRAZA_CESIONES_REA', NULL, 'PAC_CESIONESREA', 'F_CREA_CUMUL_ZONA', NULL, 77741,'psseguro:'||psseguro||
                         ' pccumprod:'||pccumprod||' pfefecto:'||pfefecto||' pscontra:'||pscontra||' pnversio:'||
                         pnversio||' v_aseg:'||v_aseg);

                  INSERT INTO cumulos
                              (scumulo, fcumini, fcumfin, sperson, ctipcum, ccumprod, czona)
                       VALUES (pscumulo, pfefecto, NULL, v_aseg/*v_pol.sperson*/, pctipcum, pccumprod, v_czona/* pac_preguntas.ff_buscapregunseg(psseguro, 1, 9748,NULL)*/);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
                        p_traza_proceso(24, 'TRAZA_CESIONES_REA', NULL, 'PAC_CESIONESREA', 'F_CREA_CUMUL_ZONA', NULL, 7775,'psseguro:'||psseguro||
                         ' pccumprod:'||pccumprod||' pfefecto:'||pfefecto||' pscontra:'||pscontra||' pnversio:'||
                         pnversio);

                     RETURN 150963;
               END;

               BEGIN
                     p_traza_proceso(24, 'TRAZA_CESIONES_REA', NULL, 'PAC_CESIONESREA', 'F_CREA_CUMUL_ZONA', NULL, 7776,'psseguro:'||psseguro||
                      ' pccumprod:'||pccumprod||' pfefecto:'||pfefecto||' pscontra:'||pscontra||' pnversio:'||
                       pnversio);

                  -- Descripcció
                  v_errlin := 3060;
                  /*SELECT nnumide
                    INTO lnom
                    FROM per_personas
                   WHERE sperson = v_pol.sperson;*/

                   p_traza_proceso(24, 'TRAZA_CESIONES_REA', NULL, 'PAC_CESIONESREA', 'F_CREA_CUMUL_ZONA', NULL, 7777,'psseguro:'||psseguro||
                 ' pccumprod:'||pccumprod||' pfefecto:'||pfefecto||' pscontra:'||pscontra||' pnversio:'||
                 pnversio);

                  FOR reg IN (SELECT cidioma
                                FROM idiomas) LOOP
                     v_errlin := 3070;

                     SELECT tatribu
                      INTO v_tzona
                      FROM detvalores
                     WHERE cvalor = 8001172
                       AND catribu = v_czona
                       AND cidioma = reg.cidioma;

                     INSERT INTO descumulos
                                 (scumulo, cidioma, tdescri, tobserv)
                          VALUES (pscumulo, reg.cidioma, SUBSTR(v_tzona, 1, 40), v_tzona);
                  END LOOP;
               EXCEPTION
                  WHEN OTHERS THEN
                        p_traza_proceso(24, 'TRAZA_CESIONES_REA', NULL, 'PAC_CESIONESREA', 'F_CREA_CUMUL_ZONA', NULL, 7778,'psseguro:'||psseguro||
                         ' pccumprod:'||pccumprod||' pfefecto:'||pfefecto||' pscontra:'||pscontra||' pnversio:'||
                         pnversio);

                     p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
                     RETURN 150964;
               END;
            END IF;

            BEGIN
               v_errlin := 3080;

               SELECT 1
                 INTO waux
                 FROM reariesgos
                WHERE sseguro = psseguro--v_pol.sseguro
                  AND nriesgo = 1--v_pol.nriesgo
                  AND freaini = pfefecto
                  AND scumulo = pscumulo
                  AND scontra = pscontra
                  AND nversio = pnversio
                  AND freafin IS NULL;
         p_traza_proceso(24, 'TRAZA_CESIONES_REA', NULL, 'PAC_CESIONESREA', 'F_CREA_CUMUL_ZONA', NULL, 7779,'psseguro:'||psseguro||
                         ' pccumprod:'||pccumprod||' pfefecto:'||pfefecto||' pscontra:'||pscontra||' pnversio:'||
                         pnversio);

            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_errlin := 3090;
                           p_traza_proceso(24, 'TRAZA_CESIONES_REA', NULL, 'PAC_CESIONESREA', 'F_CREA_CUMUL_ZONA', NULL, 77710,'psseguro:'||psseguro||
                         ' pccumprod:'||pccumprod||' pfefecto:'||pfefecto||' pscontra:'||pscontra||' pnversio:'||
                         pnversio);

                  BEGIN
                         p_traza_proceso(24, 'TRAZA_CESIONES_REA', NULL, 'PAC_CESIONESREA', 'F_CREA_CUMUL_ZONA', NULL, 77711,'psseguro:'||psseguro||
                         ' pccumprod:'||pccumprod||' pfefecto:'||pfefecto||' pscontra:'||pscontra||' pnversio:'||
                         pnversio);

                     INSERT INTO reariesgos
                                 (sseguro, nriesgo, freaini, scumulo, scontra,
                                  freafin, nversio)
                          VALUES (psseguro, 1, pfefecto, pscumulo, pscontra,
                                  NULL, pnversio);
                  EXCEPTION
                     WHEN OTHERS THEN
                                p_traza_proceso(24, 'TRAZA_CESIONES_REA', NULL, 'PAC_CESIONESREA', 'F_CREA_CUMUL_ZONA', NULL, 77712,'psseguro:'||psseguro||
                         ' pccumprod:'||pccumprod||' pfefecto:'||pfefecto||' pscontra:'||pscontra||' pnversio:'||
                         pnversio);

                        p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
                        RETURN 150964;
                  END;
            END;

            v_errlin := 3095;

            BEGIN
         p_traza_proceso(24, 'TRAZA_CESIONES_REA', NULL, 'PAC_CESIONESREA', 'F_CREA_CUMUL_ZONA', NULL, 77713,'psseguro:'||psseguro||
                         ' pccumprod:'||pccumprod||' pfefecto:'||pfefecto||' pscontra:'||pscontra||' pnversio:'||
                         pnversio);

               UPDATE cesionesrea
                  SET scumulo = pscumulo
                WHERE sseguro = psseguro
                  AND nriesgo = 1
                  AND scontra = pscontra
                  AND nversio = pnversio
                  AND cgenera IN(01, 03, 04, 05, 09, 40)
                  AND fefecto <= pfefecto
                  AND fvencim > pfefecto
                  AND(fanulac > pfefecto
                      OR fanulac IS NULL)
                  AND(fregula > pfefecto
                      OR fregula IS NULL);
            EXCEPTION
               WHEN OTHERS THEN
         p_traza_proceso(24, 'TRAZA_CESIONES_REA', NULL, 'PAC_CESIONESREA', 'F_CREA_CUMUL_ZONA', NULL, 77714,'psseguro:'||psseguro||
                         ' pccumprod:'||pccumprod||' pfefecto:'||pfefecto||' pscontra:'||pscontra||' pnversio:'||
                         pnversio);

                  p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
                  RETURN 104859;
            END;
         --END LOOP;
      --END IF;

      RETURN 0;
   END f_crea_cumul_zona;

   FUNCTION f_get_scumulo(psseguro IN NUMBER, passeg IN NUMBER, pscontra IN NUMBER, pnversio IN NUMBER, pccumprod IN NUMBER, pctipcum IN NUMBER, pscumulo OUT NUMBER)
      RETURN NUMBER IS
            v_sperson per_personas.sperson%TYPE;
            v_zona number;
            lcum cumulos%ROWTYPE;
            v_errfun NUMBER;
            v_errlin NUMBER;
            v_errpar NUMBER;

   BEGIN
      IF pctipcum = 2 THEN
         SELECT SPERSON
           INTO v_sperson
           FROM TOMADORES
          WHERE NORDTOM = 1
            AND SSEGURO = pSSEGURO;
         v_zona := NULL;
      ELSIF pctipcum = 3 THEN
         v_sperson := passeg;
         v_zona := -1;--pac_preguntas.ff_buscapregunseg(psseguro, 1, 9748,NULL);
         p_traza_proceso(24, 'TRAZA_CESIONES_REA', NULL, 'PAC_CESIONESREA', 'f_get_scumulo', NULL, 777,'v_zona:' ||
                         v_zona);
      ELSE
         v_sperson := passeg;
         v_zona := NULL;
      END IF;

      SELECT DISTINCT  c.scumulo,
                       c.fcumini,
                       c.fcumfin,
                       c.ccumprod,
                       c.sperson,
                       c.ctipcum,
                       c.cramo,
                       c.sproduc,
                       czona
                  INTO lcum
                  FROM cumulos c, reariesgos r
                 WHERE sperson = NVL(v_sperson, sperson)
                   AND ccumprod = pccumprod
                   AND c.scumulo = r.scumulo
                   AND r.scontra = pscontra
                   --AND r.nversio = pnversio IAXIS-12992 27/04/2020
                   --AND c.czona = v_zona
                   AND NVL(c.czona,0) = NVL(v_zona, NVL(c.czona,0))
                   AND fcumfin IS NULL
                   AND c.scumulo = (SELECT MAX(c.scumulo)
                                    FROM cumulos c, reariesgos r
                                   WHERE sperson = nvl(v_sperson, sperson)
                                     AND ccumprod = pccumprod
                                     AND c.scumulo = r.scumulo
                                     AND r.scontra = pscontra
                                     --AND r.nversio = pnversio IAXIS-12992 27/04/2020
                                     --AND c.czona = v_zona
                                     AND NVL(c.czona,0) = NVL(v_zona, NVL(c.czona,0))
                                     AND fcumfin IS NULL);
      pscumulo := lcum.scumulo;
      RETURN 0;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pscumulo := NULL;
	          RETURN 1;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            RETURN 104665;
      END f_get_scumulo;
   /*************************************************************************
    FUNCTION f_captram_cumul_ret
    Permite obtener el valor de lo acumulado por aquellos movimientos de retenciones
    propias de contratos, es decir que no corresponde a retencion global.
    param in psseguro  : codigo del seguro
    param in pscumulo  : codigo del cumulo
    param in pcgarant   : codigo de la garantia
    param in pfefecto    : fecha de efecto
    param in pctramo  : tramo
    param in pscontra   : codigo de contrato de reaseguros
    param in pnversio    : version de contrato
    param in pmoninst        : moneda de instalacion
    param in pfcambio        : fecha para obtener la tasa de cambio
    param in ptablas    : tabla
    param out pcapcum : capital del cumulo
    param out piplenotot : pleno neto
    return             : number
  *************************************************************************/
   FUNCTION f_captram_cumul_ret(
         psseguro IN NUMBER,
         pscumulo IN NUMBER,
         pcgarant IN NUMBER,
         pfefecto IN DATE,
         pctramo IN NUMBER,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pmoninst IN VARCHAR2,--BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
         pfcambio IN DATE,    --BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
         pcapcum OUT NUMBER,
         piplenotot IN OUT NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER
   IS
      ------------------------------------------------------------------------------
      -- Obtenim l'import sumat del tram ctramo del cúmul
      -- Les garanties 1 i 8 fan cúmul juntes, cal veure com parametritzar-ho
      -- de moment les posem a pinyó
      ------------------------------------------------------------------------------
      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_CAPTRAM_CUMUL_EST';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || 's=' || psseguro || ' c=' || pscumulo || ' g=' || pcgarant || ' e=' || pfefecto || 't=' || pctramo || ' c=' || pscontra
      || ' v=' || pnversio || ' i=' || piplenotot || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      lcmaxcum NUMBER;
      lcgarrel NUMBER;
      liretenc NUMBER;
      v_ctiprea codicontratos.ctiprea%TYPE; -- 28777 13-11-13
      perr NUMBER;                          -->> 28492 AVT 12/11/2013
      v_cempres seguros.cempres%TYPE;       -->> 28492 AVT 12/11/2013
      v_cramo seguros.cramo%TYPE;           -->> 28492 AVT 12/11/2013
      v_cmodali seguros.cmodali%TYPE;       -->> 28492 AVT 12/11/2013
      v_ctipseg seguros.ctipseg%TYPE;       -->> 28492 AVT 12/11/2013
      v_ccolect seguros.ccolect%TYPE;       -->> 28492 AVT 12/11/2013
      v_cactivi seguros.cactivi%TYPE;       -->> 28492 AVT 12/11/2013
      v_scontra contratos.scontra%TYPE;     -->> 28492 AVT 12/11/2013
      v_nversio contratos.nversio%TYPE;     -->> 28492 AVT 12/11/2013
      v_icapaci contratos.icapaci%TYPE;     -->> 28492 AVT 12/11/2013
      v_cdetces cesionesrea.cdetces%TYPE;   -->> 28492 AVT 12/11/2013
      v_fefecto DATE;                       --29011 AVT 13/11/13
   BEGIN
      v_errlin := 5001;
      -- 29011 AVT 13/11/13
       SELECT    MAX(freaini)
            INTO v_fefecto
            FROM reariesgos r
           WHERE r.scumulo = pscumulo
            AND(r.freafin  > pfefecto
            OR r.freafin  IS NULL);

      v_errlin            := 5000;
      -- AVT 28777 13-11-13 en cas de XL el ple net de retnció és el total del Capital (hauia de ser el tram?...)
       SELECT    ctiprea
            INTO v_ctiprea
            FROM codicontratos
           WHERE scontra = pscontra;

      v_errlin          := 5005;

      IF v_ctiprea       = 3 THEN
         --28492 AVT 13/11/2013 LA SELECT NO SERVEIX SI UN CONTRACTE COBREIS DOS O MÉS PRODUCTES.
         IF ptablas = 'EST' THEN
             SELECT    cempres, cramo, cmodali, ctipseg, ccolect, cactivi
                  INTO v_cempres, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi
                  FROM estseguros seg
                 WHERE seg.sseguro = psseguro;
         ELSE
             SELECT    cempres, cramo, cmodali, ctipseg, ccolect, cactivi
                  INTO v_cempres, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi
                  FROM seguros seg
                 WHERE seg.sseguro = psseguro;
         END IF;

         perr := f_buscacontrato(psseguro, pfefecto, v_cempres, pcgarant, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi, 11, v_scontra, v_nversio,
         liretenc, v_icapaci, v_cdetces); -- revisar evento!!!

         IF perr <> 0 THEN
            RETURN(perr);
         END IF;
      ELSE -- 28777 13-11-13 fi --------------
          SELECT    iretenc, NVL(cgarrel, 0)
               INTO liretenc, lcgarrel
               FROM contratos
              WHERE scontra = pscontra
               AND nversio  = pnversio;
      END IF;

      v_errlin  := 5355;

      IF ptablas = 'EST' THEN
         SELECT NVL(SUM(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(s.sproduc)),
                                                            pmoninst,
                                                            pfcambio,
                                                            NVL(c.icapces, 0))),0)--BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
               INTO pcapcum
               FROM seguros s, estseguros s2, cesionesrea c, reariesgos r
              WHERE c.scumulo = pscumulo
               AND c.ctramo   = 0
               AND c.ctrampa   = pctramo
               AND c.scontra  = pscontra
               AND c.nversio  = pnversio
               AND s.sseguro  = c.sseguro
               AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
               AND c.fvencim  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               AND(c.fanulac  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               OR c.fanulac  IS NULL)
               AND(c.fregula  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               OR c.fregula  IS NULL)
               AND r.scumulo  = c.scumulo
               AND r.sseguro  = c.sseguro
               AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
               AND(r.freafin  > NVL(v_fefecto, pfefecto)  -- Bugs 31509 22-05-14
               OR r.freafin  IS NULL)
               AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
               AND((lcgarrel  = 0
               AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR'),
               NVL(c.cgarant, 0)) = NVL(f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
               pcgarant, 'REACUMGAR'), NVL(pcgarant, 0))
               AND r.sseguro <> psseguro
               AND s2.sseguro = psseguro));
      ELSIF ptablas           = 'CAR' THEN
         SELECT NVL(SUM(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(s.sproduc)),
                                                            pmoninst,
                                                            pfcambio,
                                                            NVL(c.icapces, 0))),0)--BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
               INTO pcapcum                --, pipleno, picapaci
               FROM seguros s, seguros s2, cesionesrea c, reariesgos r
              WHERE c.scumulo = pscumulo
               AND c.ctramo   = 0
               AND c.ctrampa = pctramo
               AND c.scontra  = pscontra
               AND c.nversio  = pnversio
               AND s.sseguro  = c.sseguro
               AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
               AND c.fvencim  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               AND(c.fanulac  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               OR c.fanulac  IS NULL)
               AND(c.fregula  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               OR c.fregula  IS NULL)
               AND r.scumulo  = c.scumulo
               AND r.sseguro  = c.sseguro
               AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
               AND(r.freafin  > NVL(v_fefecto, pfefecto)  -- Bugs 31509 22-05-14
               OR r.freafin  IS NULL)
               AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
               AND((lcgarrel  = 0
               AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR'),
               NVL(c.cgarant, 0)) = NVL (f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
               pcgarant, 'REACUMGAR'), NVL(pcgarant, 0)) -- 14536 AVT 25-05-2010  fi
               AND r.sseguro <> psseguro
               AND s2.sseguro = psseguro)
               );
      ELSE
         SELECT NVL(SUM(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(s.sproduc)),
                                                            pmoninst,
                                                            pfcambio,
                                                            NVL(c.icapces, 0))),0)--BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
               INTO pcapcum                --, pipleno, picapaci
               FROM seguros s, seguros s2, cesionesrea c, reariesgos r
              WHERE c.scumulo = pscumulo
               AND c.ctramo   = 0
               AND c.ctrampa = pctramo
               AND c.scontra  = pscontra
               AND c.nversio  = pnversio
               AND s.sseguro  = c.sseguro
               AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
               AND c.fvencim  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               AND(c.fanulac  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               OR c.fanulac  IS NULL)
               AND(c.fregula  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               OR c.fregula  IS NULL)
               AND r.scumulo  = c.scumulo
               AND r.sseguro  = c.sseguro
               AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
               AND(r.freafin  > NVL(v_fefecto, pfefecto)  -- Bugs 31509 22-05-14
               OR r.freafin  IS NULL)
               AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
               AND((lcgarrel  = 0
               AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR'),
               NVL(c.cgarant, 0)) = NVL (f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
               pcgarant, 'REACUMGAR'), NVL(pcgarant, 0)) -- 14536 AVT 25-05-2010  fi
               AND r.sseguro <> psseguro
               AND s2.sseguro = psseguro)
               );
      END IF;

      v_errlin      := 5360;

      IF lcgarrel    = 1 THEN
         piplenotot := liretenc;
      END IF;

      RETURN 0;
   EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
      RETURN 105297;
   END f_captram_cumul_ret;

------------------------------------------------------------------------------------
   /*************************************************************************
    FUNCTION f_ple_cumul_q
    Permite obtener el valor de lo acumulado en la retencion global sin tener
    en cuenta la retencion de los contratos.
    param in psseguro  : codigo del seguro
    param in pscumulo  : codigo del cumulo
    param in pcgarant  : codigo de la garantia
    param in pmoninst  : moneda local o de instalacion
    param in pfefecto  : fecha de efecto
    param out pcapcum  :  capital del cumulo
    param out pipleno  : importe de la retencion
    param out picapaci : importe de la capacidad
    param in ptablas   : tabla
    return             : number
  *************************************************************************/
   FUNCTION f_ple_cumul_qn(
         psseguro IN NUMBER,
         pscumulo IN NUMBER,
         pcgarant IN NUMBER,
         pmoninst IN VARCHAR2,--BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
         pfefecto IN DATE,
         pcapcum OUT NUMBER,
         pipleno OUT NUMBER,
         picapaci OUT NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER
   IS
      ------------------------------------------------------------------------------
      -- Obtenim l'import sumat del tram 0 del cúmul
      -- Les garanties 1 i 8 fan cúmul juntes, cal veure com parametritzar-ho
      -- de moment les posem a pinyó
      ------------------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_PLE_CUMUL_EST';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || 's=' || psseguro || ' c=' || pscumulo || ' g=' || pcgarant || ' e=' || pfefecto || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      lcmaxcum  NUMBER;
      v_fefecto DATE; --29011 AVT 13/11/13
   BEGIN
      v_errlin := 4081;

      -- 29011 AVT 13/11/13
       SELECT    MAX(freaini)
            INTO v_fefecto
            FROM reariesgos r
           WHERE r.scumulo = pscumulo
            AND(r.freafin  > pfefecto
            OR r.freafin  IS NULL);

      v_errlin            := 4080;

      IF ptablas           = 'EST' THEN
         SELECT NVL(SUM(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(s.sproduc)),
                                                                                    pmoninst,
                                                                                    pfefecto,
                                                                                    NVL(c.icapces, 0))),0),--BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
          MAX(ipleno), MAX(icapaci)
               INTO pcapcum, pipleno, picapaci
               FROM seguros s, estseguros s2, cesionesrea c, reariesgos r
              WHERE c.scumulo = pscumulo
               AND c.ctramo   = 0
               AND c.ctrampa IS NULL
               AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
               AND c.fvencim  > pfefecto
               AND(c.fanulac  > pfefecto
               OR c.fanulac  IS NULL)
               AND(c.fregula  > pfefecto
               OR c.fregula  IS NULL)
               AND r.scumulo  = c.scumulo
               AND r.sseguro  = c.sseguro
               AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13    --BUG 4867 CPM: Se controla la fecha inicio
               AND(r.freafin  > pfefecto
               OR r.freafin  IS NULL)
               AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
               AND r.sseguro <> psseguro
               AND s2.sseguro = psseguro
               AND s.sseguro  = c.sseguro
               AND c.scontra  = r.scontra
               AND c.nversio  = r.nversio
               AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR'),
               NVL(c.cgarant, 0)) = NVL(f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
               pcgarant, 'REACUMGAR'), NVL(pcgarant, 0)); -- 14536 AVT 25-05-2010 fi

         -- 28777 AVT 13-11-13 nvl per quan fem cúmul de totes les garanties
         BEGIN
            v_errlin := 4085;

             SELECT    b.cmaxcum
                  INTO lcmaxcum
                  FROM cumulprod a, codicumprod b
                 WHERE a.ccumprod = b.ccumprod
                  AND a.sproduc   =
                  (SELECT    sproduc
                        FROM estseguros
                       WHERE sseguro = psseguro
                  )
                  AND a.finiefe <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND(a.ffinefe IS NULL
                  OR a.ffinefe   > pfefecto);
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            --DBMS_OUTPUT.put_line('2:' || SQLERRM);
            RETURN 40301;
         END;
      ELSIF ptablas = 'CAR' THEN
         SELECT NVL(SUM(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(s.sproduc)),
                                                            pmoninst,
                                                            pfefecto,
                                                            NVL(c.icapces, 0))),0),--BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                MAX(ipleno), MAX(icapaci)
               INTO pcapcum, pipleno, picapaci
               FROM seguros s, seguros s2, cesionesrea c, reariesgos r
              WHERE c.scumulo = pscumulo
               AND c.ctramo   = 0
               AND c.ctrampa IS NULL
               AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
               AND c.fvencim  > pfefecto
               AND(c.fanulac  > pfefecto
               OR c.fanulac  IS NULL)
               AND(c.fregula  > pfefecto
               OR c.fregula  IS NULL)
               AND r.scumulo  = c.scumulo
               AND r.sseguro  = c.sseguro
               AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13    --BUG 4867 CPM: Se controla la fecha inicio
               AND(r.freafin  > pfefecto
               OR r.freafin  IS NULL)
               AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
               AND r.sseguro <> psseguro
               --AND c.cgarant = pcgarant -- 14536 AVT 25-05-2010
               AND s2.sseguro = psseguro
               AND s.sseguro  = c.sseguro
               AND c.scontra  = r.scontra
               AND c.nversio  = r.nversio
               AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR'),
               NVL(c.cgarant, 0)) = NVL(f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
               pcgarant, 'REACUMGAR'), NVL(pcgarant, 0)); -- 14536 AVT 25-05-2010 fi

         -- 28777 AVT 13-11-13 nvl per quan fem cúmul de totes les garanties
         BEGIN
            v_errlin := 4085;

             SELECT    b.cmaxcum
                  INTO lcmaxcum
                  FROM cumulprod a, codicumprod b
                 WHERE a.ccumprod = b.ccumprod
                  AND a.sproduc   =
                  (SELECT    sproduc
                        FROM seguros
                       WHERE sseguro = psseguro
                  )
                  AND a.finiefe <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND(a.ffinefe IS NULL
                  OR a.ffinefe   > pfefecto);
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            RETURN 40301;
         END;
      ELSE
         SELECT NVL(SUM(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(s.sproduc)),
                                                            pmoninst,
                                                            pfefecto,
                                                            NVL(c.icapces, 0))),0),--BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
                MAX(ipleno), MAX(icapaci)
               INTO pcapcum, pipleno, picapaci
               FROM seguros s, seguros s2, cesionesrea c, reariesgos r
              WHERE c.scumulo = pscumulo
               AND c.ctramo   = 0
               AND c.ctrampa IS NULL
               AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
               AND c.fvencim  > pfefecto
               AND(c.fanulac  > pfefecto
               OR c.fanulac  IS NULL)
               AND(c.fregula  > pfefecto
               OR c.fregula  IS NULL)
               AND r.scumulo  = c.scumulo
               AND r.sseguro  = c.sseguro
               AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13    --BUG 4867 CPM: Se controla la fecha inicio
               AND(r.freafin  > pfefecto
               OR r.freafin  IS NULL)
               AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
               AND r.sseguro <> psseguro
               --AND c.cgarant = pcgarant -- 14536 AVT 25-05-2010
               AND s2.sseguro = psseguro
               AND s.sseguro  = c.sseguro
               AND c.scontra  = r.scontra
               AND c.nversio  = r.nversio
               AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR'),
               NVL(c.cgarant, 0)) = NVL(f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
               pcgarant, 'REACUMGAR'), NVL(pcgarant, 0)); -- 14536 AVT 25-05-2010 fi

         -- 28777 AVT 13-11-13 nvl per quan fem cúmul de totes les garanties
         BEGIN
            v_errlin := 4085;

             SELECT    b.cmaxcum
                  INTO lcmaxcum
                  FROM cumulprod a, codicumprod b
                 WHERE a.ccumprod = b.ccumprod
                  AND a.sproduc   =
                  (SELECT    sproduc
                        FROM seguros
                       WHERE sseguro = psseguro
                  )
                  AND a.finiefe <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND(a.ffinefe IS NULL
                  OR a.ffinefe   > pfefecto);
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            RETURN 40301;
         END;
      END IF;

      IF NVL(lcmaxcum, 0) = 0 THEN
         -- Retornem els maxims del ple i capital a zero,
         -- pq no s'han de tenir en compte
         pipleno  := 0;
         picapaci := 0;
      END IF;

      --DBMS_OUTPUT.put_line(' -------------- PCAPCUM ' || pcapcum);
      RETURN 0;
   EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
      RETURN 105297;
   END f_ple_cumul_qn;
--FIN BUG CONF-294  - Fecha (09/11/2016) - HRE

--INI BUG CONF-479  Fecha (20/01/2017) - HRE - Suplemento de aumento de valor
FUNCTION f_mantener_repartos_supl(
   pmotiu IN NUMBER,
   psproduc IN NUMBER,
   pscontra IN NUMBER,
   psseguro IN NUMBER,
   pnversio IN NUMBER,
   pcgarant IN NUMBER,
   ptramo IN NUMBER,
   pporce IN NUMBER,
   pcapces IN NUMBER,
   picapital IN NUMBER,
   ppcapces_out OUT NUMBER,
   pporce_out OUT NUMBER)
   RETURN NUMBER IS

   vobjectname VARCHAR2(500)         := 'PAC_CESIONESREA.f_mantener_repartos_supl';
   vparam      VARCHAR2(500)         := 'pmotiu:'||pmotiu||' ,psproduc:'||psproduc||' ,pscontra:'||pscontra||' ,psseguro:'||psseguro
                                        ||' ,pnversio:'||pnversio||' ,pcgarant:'||pcgarant||' ,ptramo:'||ptramo||' ,pporce:'||pporce||' ,pcapces:'||pcapces||' ,picapital:'||picapital;
   v_traza     NUMBER :=0;
   
   --INI IAXIS BUG 10563 AABG: Variable para comprobar movimientos
   v_movims NUMBER := 0;
   --FIN IAXIS BUG 10563 AABG: Variable para comprobar movimientos

   BEGIN
      ---- Suplemento

	  p_control_error('bart_ces2','vobjectname:'||vobjectname,'vparam:'||vparam);
      
      --INI IAXIS BUG 10563 AABG: Se hace ajuste para tomar el ultimo registro o movimiento de cesiones
      SELECT COUNT(*) INTO v_movims FROM CESIONESREA c WHERE c.sseguro = psseguro AND c.scontra = pscontra AND c.nversio = pnversio AND  c.ctipomov = 'M';
      
      IF v_movims > 0 THEN
      
              IF (pmotiu = 4 AND NVL(pac_parametros.f_parcontrato_n(pscontra, 'REA_MANTIENE_SUPL', psproduc),0) = 1) THEN

          p_control_error('bart_ces3','vobjectname:'||vobjectname,'vparam:'||vparam);
    
             v_traza :=11;
             
             BEGIN
             SELECT SUM(pcesion) /*/ 100*/
               INTO pporce_out
               FROM cesionesrea c
              WHERE c.sseguro = psseguro
                AND c.scontra = pscontra
                AND c.nversio = pnversio
                AND (/*c.ctramo = ptramo OR*/
                  c.ctrampa = ptramo)
                AND(c.cgarant = pcgarant
                 OR c.cgarant IS NULL)
                --AND c.cgenera IN(3, 5)
                AND c.nmovigen = (SELECT MAX(cr.nmovigen) FROM cesionesrea cr WHERE cr.sseguro = psseguro AND cr.cgenera = 4 and cr.ctipomov = 'M')
                /*AND c.fefecto = (SELECT fefecto
                                  FROM movseguro
                                 WHERE sseguro = c.sseguro
                                   AND nmovimi = (SELECT MAX(nmovimi)
                                                    FROM movseguro
                                                   WHERE sseguro = c.sseguro
                                                     AND cmotmov IN(404, 100)))*/ --- RENOVACION CARTERA O ALTA
                                                           
             ORDER BY scesrea DESC;
            p_control_error('bart_ces4','pporce_out:'||pporce_out,'vparam:'||vparam);
             v_traza :=12;
             ppcapces_out := picapital * pporce_out;
            
             
             EXCEPTION
             WHEN NO_DATA_FOUND THEN
                pporce_out := pporce;
                ppcapces_out := pcapces;
               
             WHEN OTHERS THEN
                 pporce_out := pporce;
                ppcapces_out := pcapces;           
             END;
             --FIN IAXIS BUG 10563 AABG: Se hace ajuste para tomar el ultimo registro o movimiento de cesiones  
    
             p_control_error('bart_ces5','ppcapces_out:'||ppcapces_out,'vparam:'||vparam);
          ELSE
             v_traza :=2;
             pporce_out := pporce;
             ppcapces_out := pcapces;
              p_tab_error(f_sysdate, f_user, 'PAC_CESIONESREA', NULL,'AABG PAC_CESIONESREA 4',
                              'Error: paso 4,
                      pporce_out: '
                           || pporce_out
                           || ' ppcapces_out:'
                           || ppcapces_out
                          ); 
          END IF;
          
      ELSE
      
              IF (pmotiu = 4 AND NVL(pac_parametros.f_parcontrato_n(pscontra, 'REA_MANTIENE_SUPL', psproduc),0) = 1) THEN

              p_control_error('bart_ces3','vobjectname:'||vobjectname,'vparam:'||vparam);
        
                 v_traza :=11;
                 
                 BEGIN
                 SELECT SUM(pcesion) /*/ 100*/
                   INTO pporce_out
                   FROM cesionesrea c
                  WHERE c.sseguro = psseguro
                    AND c.scontra = pscontra
                    AND c.nversio = pnversio
                    AND (/*c.ctramo = ptramo OR*/
                      c.ctrampa = ptramo)
                    AND(c.cgarant = pcgarant
                     OR c.cgarant IS NULL)
                    --AND c.cgenera IN(3, 5)
                    AND c.nmovigen = (SELECT MAX(cr.nmovigen) FROM cesionesrea cr WHERE cr.sseguro = psseguro AND cr.cgenera = 3 and cr.ctipomov IS NULL)
                    /*AND c.fefecto = (SELECT fefecto
                                      FROM movseguro
                                     WHERE sseguro = c.sseguro
                                       AND nmovimi = (SELECT MAX(nmovimi)
                                                        FROM movseguro
                                                       WHERE sseguro = c.sseguro
                                                         AND cmotmov IN(404, 100)))*/ --- RENOVACION CARTERA O ALTA
                                                               
                 ORDER BY scesrea DESC;
                p_control_error('bart_ces4','pporce_out:'||pporce_out,'vparam:'||vparam);
                 v_traza :=12;
                 ppcapces_out := picapital * pporce_out;
                
                 
                 EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    pporce_out := pporce;
                    ppcapces_out := pcapces;
                   
                 WHEN OTHERS THEN
                     pporce_out := pporce;
                    ppcapces_out := pcapces;           
                 END;
                 --FIN IAXIS BUG 10563 AABG: Se hace ajuste para tomar el ultimo registro o movimiento de cesiones  
        
                 p_control_error('bart_ces5','ppcapces_out:'||ppcapces_out,'vparam:'||vparam);
              ELSE
                 v_traza :=2;
                 pporce_out := pporce;
                 ppcapces_out := pcapces;
                  p_tab_error(f_sysdate, f_user, 'PAC_CESIONESREA', NULL,'AABG PAC_CESIONESREA 4',
                                  'Error: paso 4,
                          pporce_out: '
                               || pporce_out
                               || ' ppcapces_out:'
                               || ppcapces_out
                              ); 
              END IF;
      
      END IF;


      v_traza :=3;
	  p_control_error('bart_ces6','v_traza:'||v_traza,'vparam:'||vparam);
      RETURN 0;
   EXCEPTION WHEN OTHERS THEN
      p_tab_error (f_sysdate, f_user, vobjectname, v_traza, vparam, 'ERROR: ' || SQLCODE || ' - ' || SQLERRM );
      RETURN -99;
   END f_mantener_repartos_supl;
--FIN BUG CONF-479  - Fecha (20/01/2017) - HRE

--INI IAXIS BUG 13246 AABG: Para consultar las cesiones manuales de endosos
FUNCTION f_mantener_repartos_supl_man(
   pmotiu IN NUMBER,
   psproduc IN NUMBER,
   pscontra IN NUMBER,
   psseguro IN NUMBER,
   pnversio IN NUMBER,
   pcgarant IN NUMBER,
   ptramo IN NUMBER,
   pporce IN NUMBER,
   pcapces IN NUMBER,
   picapital IN NUMBER,
   ppcapces_out OUT NUMBER,
   pporce_out OUT NUMBER,
   ppcapq_out OUT NUMBER,
   pporceq_out OUT NUMBER,
   psupl_out OUT NUMBER)
   RETURN NUMBER IS

   vobjectname VARCHAR2(500)         := 'PAC_CESIONESREA.f_mantener_repartos_supl';
   vparam      VARCHAR2(500)         := 'pmotiu:'||pmotiu||' ,psproduc:'||psproduc||' ,pscontra:'||pscontra||' ,psseguro:'||psseguro
                                        ||' ,pnversio:'||pnversio||' ,pcgarant:'||pcgarant||' ,ptramo:'||ptramo||' ,pporce:'||pporce||' ,pcapces:'||pcapces||' ,picapital:'||picapital;
   v_traza     NUMBER :=0;

   BEGIN 
      --INI IAXIS BUG 10563 AABG: Se hace ajuste para tomar el ultimo registro o movimiento de cesiones
    IF (pmotiu = 4 AND NVL(pac_parametros.f_parcontrato_n(pscontra, 'REA_MANTIENE_SUPL', psproduc),0) = 1) THEN    
             v_traza :=11;
             
             BEGIN
             SELECT SUM(pcesion)
               INTO pporce_out
               FROM cesionesrea c
              WHERE c.sseguro = psseguro
                AND c.scontra = pscontra
                AND c.nversio = pnversio
                AND (c.ctrampa = ptramo)
                AND(c.cgarant = pcgarant
                 OR c.cgarant IS NULL)
                AND c.nmovigen = (SELECT MAX(cr.nmovigen) FROM cesionesrea cr WHERE cr.sseguro = psseguro AND cr.cgenera = 4 and cr.ctipomov = 'M')                                                           
             ORDER BY scesrea DESC;            
             
             v_traza :=12;
             IF pporce_out IS NULL THEN
             
                 SELECT SUM(pcesion)
                   INTO pporceq_out
                   FROM cesionesrea c
                  WHERE c.sseguro = psseguro
                    AND c.scontra = pscontra
                    AND c.nversio = pnversio
                    AND (c.ctramo = ptramo)
                    AND(c.cgarant = pcgarant
                     OR c.cgarant IS NULL)
                    AND c.nmovigen = (SELECT MAX(cr.nmovigen) FROM cesionesrea cr WHERE cr.sseguro = psseguro AND cr.cgenera = 4 and cr.ctipomov = 'M')                                                           
                 ORDER BY scesrea DESC;                   
                 
                 IF pporceq_out IS NULL THEN
                    pporceq_out := 0;
                    ppcapq_out := 0;
                    psupl_out := 0;
                 ELSE
                    ppcapq_out := picapital * pporceq_out;
                    psupl_out := 1;
                 END IF;
             
                pporce_out := 0;
                ppcapces_out := 0;              
                
             ELSE 
                psupl_out := 1;
                ppcapces_out := picapital * pporce_out;
                
                 SELECT SUM(pcesion)
                   INTO pporceq_out
                   FROM cesionesrea c
                  WHERE c.sseguro = psseguro
                    AND c.scontra = pscontra
                    AND c.nversio = pnversio
                    AND (c.ctramo = ptramo)
                    AND(c.cgarant = pcgarant
                     OR c.cgarant IS NULL)
                    AND c.nmovigen = (SELECT MAX(cr.nmovigen) FROM cesionesrea cr WHERE cr.sseguro = psseguro AND cr.cgenera = 4 and cr.ctipomov = 'M')                                                           
                 ORDER BY scesrea DESC;               
                 
                 IF pporceq_out IS NULL THEN
                    pporceq_out := 0;
                    ppcapq_out := 0;
                 ELSE
                    ppcapq_out := picapital * pporceq_out;
                 END IF;
                
             END IF;            
             
             EXCEPTION
             WHEN NO_DATA_FOUND THEN
                pporce_out := pporce;
                ppcapces_out := pcapces;
                pporceq_out := 0;
                ppcapq_out := 0;
                psupl_out := 0;
             
               
             WHEN OTHERS THEN
                pporce_out := pporce;
                ppcapces_out := pcapces;   
                pporceq_out := 0;
                ppcapq_out := 0;
                psupl_out := 0;            
             END;
             
          ELSE
             v_traza :=2;
             pporce_out := pporce;
             ppcapces_out := pcapces;
             pporceq_out := 0;
             ppcapq_out := 0;
             psupl_out := 0;
 
          END IF;

      v_traza :=3;
      RETURN 0;
   EXCEPTION WHEN OTHERS THEN
      p_tab_error (f_sysdate, f_user, vobjectname, v_traza, vparam, 'ERROR: ' || SQLCODE || ' - ' || SQLERRM );
      RETURN -99;
   END f_mantener_repartos_supl_man;
--FIN IAXIS BUG 13246 AABG: Para consultar las cesiones manuales de endosos

   --INI BUG CONF-620  Fecha (01/03/2017) - HRE - Reaseguro moneda local
   /*************************************************************************
    FUNCTION f_capital_cumul_est_mon
    Permite obtener el capital del cumulo en moneda local
    param in pctiprea        : tipo de reaseguro
    param in pscumulo        : codigo del cumulo
    param in pfecini         : fecha inicial
    param in pcgarant        : garantia
    param in pmoninst        : moneda instalacion
    param in pfcambio        : fecha para obtener la tasa de cambio
    param in out pcapital    : capital del cumulo
    param out ptablas        : tipo de tabla
    return                   : number
   *************************************************************************/
   FUNCTION f_capital_cumul_est_mon(
         pctiprea IN NUMBER,
         pscumulo IN NUMBER,
         pfecini IN DATE,
         pcgarant IN NUMBER,
         pmoninst  IN VARCHAR2,
         pfcambio IN DATE,
         pcapital IN OUT NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER
   IS
      /***********************************************************************
      f_capital_cumul_mon        : Buscar el capital d'un cumul.
      ***********************************************************************/
      perr      NUMBER := 0;
      w_sseguro NUMBER;
      w_nriesgo NUMBER(6);
      w_cgarant NUMBER(4);
      w_cramo   NUMBER(8);
      w_cmodali NUMBER(2);
      w_ctipseg NUMBER(2);
      w_ccolect NUMBER(2);
      w_creaseg NUMBER(1);
      w_cactivi NUMBER(4);
      w_tabla   VARCHAR2(3);
      v_fefecto DATE; --29011 AVT 13/11/13
      v_sproduc productos.sproduc%TYPE;

      CURSOR cur_reariesgos
      IS
          SELECT    sseguro, nriesgo, cgarant, freaini
               FROM reariesgos
              WHERE scumulo = pscumulo
               AND freaini <= NVL(v_fefecto, pfecini) --29011 AVT 13/11/13
               AND(freafin IS NULL
               OR freafin   > pfecini)
               AND(cgarant  = pcgarant
               OR cgarant  IS NULL); -- 13195 01-03-2010 AVT

      CURSOR cur_garanseg
      IS
          SELECT    icapital, cgarant
               FROM garanseg g
              WHERE g.sseguro = w_sseguro
               AND g.nriesgo  = w_nriesgo
               AND(cgarant    = w_cgarant
               OR w_cgarant  IS NULL)
               AND g.ffinefe IS NULL;

      --JRB -- Duda si se añade garancar o no
      CURSOR cur_garancar
      IS
          SELECT    icapital, cgarant
               FROM garancar g
              WHERE g.sseguro = w_sseguro
               AND g.nriesgo  = w_nriesgo
               AND(cgarant    = w_cgarant
               OR w_cgarant  IS NULL)
               AND g.ffinefe IS NULL;

      -- 19484
      CURSOR cur_garanseg_est
      IS
          SELECT    icapital, cgarant
               FROM estgaranseg g
              WHERE g.sseguro = w_sseguro
               AND g.nriesgo  = w_nriesgo
               AND(cgarant    = w_cgarant
               OR w_cgarant  IS NULL)
               AND g.ffinefe IS NULL
               AND g.cobliga  = 1; -- 21051 AVT 25/01/2012;
   BEGIN

      IF pctiprea IN (1) THEN
         pcapital := 0;

         -- 29011 AVT 13/11/13
          SELECT    MAX(freaini)
               INTO v_fefecto
               FROM reariesgos r
              WHERE r.scumulo = pscumulo
               AND(r.freafin  > pfecini
               OR r.freafin  IS NULL);

         FOR regcumul IN cur_reariesgos
         LOOP
            w_sseguro := regcumul.sseguro;
            w_nriesgo := regcumul.nriesgo;
            w_cgarant := regcumul.cgarant;

            BEGIN
                SELECT    cramo, cmodali, ctipseg, ccolect, pac_seguros.ff_get_actividad(sseguro, w_nriesgo),
                          sproduc--
                     INTO w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi, v_sproduc
                     FROM estseguros
                    WHERE sseguro = w_sseguro;

               w_tabla           := 'EST'; -- AVT 15-11-2011
            EXCEPTION
            WHEN NO_DATA_FOUND THEN -- 19484
                SELECT    cramo, cmodali, ctipseg, ccolect, pac_seguros.ff_get_actividad(sseguro, w_nriesgo),
                          sproduc
                     INTO w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi, v_sproduc
                     FROM seguros
                    WHERE sseguro = w_sseguro;

               w_tabla           := NULL;
            WHEN OTHERS THEN
               perr := 101919;
            END;

            IF w_tabla = 'EST' AND ptablas = 'EST' THEN -- AVT 15-11-2011
               --19484 s'afegeix per acumular amb la pòlissa en Proposta d'Alta
               FOR reggaranseg IN cur_garanseg_est
               LOOP
                  perr        := pac_cesionesrea.f_gar_rea(w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi, reggaranseg.cgarant, w_creaseg);

                  --IF w_creaseg = 1 OR w_creaseg = 3 THEN
                  IF w_creaseg IN (1, 3, 5) THEN
                     pcapital := pcapital + NVL(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(v_sproduc)),
                                                         pmoninst,
                                                         pfcambio,
                                                         reggaranseg.icapital)
                                              , 0);
                  END IF;
               END LOOP;
            ELSIF ptablas = 'CAR' THEN
               FOR reggaranseg IN cur_garancar
               LOOP -- añadimos cartera
                  -- BUG 11100 - 16/09/2009 - FAL - Crida a la pac_cesionesrea.f_gar_rea per si garantia reasegurable
                  perr        := pac_cesionesrea.f_gar_rea(w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi, reggaranseg.cgarant, w_creaseg);

                  --IF w_creaseg = 1 OR w_creaseg = 3 THEN
                  IF w_creaseg IN (1, 3, 5) THEN
                     pcapital := pcapital + NVL(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(v_sproduc)),
                                                         pmoninst,
                                                         pfcambio,
                                                         reggaranseg.icapital)
                                              , 0);
                  END IF;
               END LOOP;
            ELSE
               FOR reggaranseg IN cur_garanseg
               LOOP
                  -- BUG 11100 - 16/09/2009 - FAL - Crida a la pac_cesionesrea.f_gar_rea per si garantia reasegurable
                  perr        := pac_cesionesrea.f_gar_rea(w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_cactivi, reggaranseg.cgarant, w_creaseg);

                  --IF w_creaseg = 1 OR w_creaseg = 3 THEN
                  IF w_creaseg IN (1, 3, 5) THEN
                     pcapital := pcapital + NVL(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(v_sproduc)),
                                                         pmoninst,
                                                         pfcambio,
                                                         reggaranseg.icapital)
                                              , 0);
                  END IF;
               END LOOP;
            END IF;
         END LOOP;
      ELSE -- tipus de contracte amb import propi fixe, no cal sumar capitals per trobar
         -- les proporcions
         --DBMS_OUTPUT.PUT_LINE(' ------------ f_capital_cumul RETORNA NULL -----------');
         NULL;
      END IF;

      RETURN(perr);
   END f_capital_cumul_est_mon;



   /*************************************************************************
    FUNCTION f_capital_cumul_mon
    Permite buscar el capital del cumulo en moneda local
    param in pctiprea        : tipo de reaseguro
    param in pscumulo        : codigo del cumulo
    param in pfecini         : fecha inicial
    param in pcgarant        : garantia
    param in pmoninst        : moneda instalacion
    param in pfcambio        : fecha para obtener la tasa de cambio
    param in out pcapital    : capital del cumulo
    return                   : number
   *************************************************************************/
   FUNCTION f_capital_cumul_mon(
      pctiprea IN NUMBER,
      pscumulo IN NUMBER,
      pfecini  IN DATE,
      pcgarant IN NUMBER,
      pmoninst IN VARCHAR2,
      pfcambio IN DATE,
      pcapital IN OUT NUMBER)
   RETURN NUMBER IS
  /***********************************************************************
     f_capital_cumul_mon        : Buscar el capital d'un cumul.
  ***********************************************************************/
   perr           NUMBER := 0;
   w_sseguro      NUMBER;
   w_nriesgo      NUMBER(6);
   w_cgarant      NUMBER(4);
   w_cramo        NUMBER(8);
   w_cmodali      NUMBER(2);
   w_ctipseg      NUMBER(2);
   w_ccolect      NUMBER(2);
   w_creaseg      NUMBER(1);
   w_cactivi      NUMBER(4);
   v_fefecto      DATE;   --29011 AVT 13/11/13
   v_sproduc productos.sproduc%TYPE;

   CURSOR cur_reariesgos IS
      SELECT sseguro, nriesgo, cgarant, freaini
        FROM reariesgos
       WHERE scumulo = pscumulo
         AND freaini <= NVL(v_fefecto, pfecini)   --29011 AVT 13/11/13
         AND(freafin IS NULL
             OR freafin > pfecini)
         AND(cgarant = pcgarant
             OR cgarant IS NULL);   -- 13195 01-03-2010 AVT

   CURSOR cur_garanseg IS
      SELECT icapital, cgarant
        FROM garanseg
       WHERE sseguro = w_sseguro
         AND nriesgo = w_nriesgo
         AND(cgarant = w_cgarant
             OR w_cgarant IS NULL)
         AND ffinefe IS NULL;
BEGIN
   IF pctiprea IN (1, 2) THEN
      pcapital := 0;

      -- 29011 AVT 13/11/13
      SELECT MAX(freaini)
        INTO v_fefecto
        FROM reariesgos r
       WHERE r.scumulo = pscumulo
         AND(r.freafin > pfecini
             OR r.freafin IS NULL);

      FOR regcumul IN cur_reariesgos LOOP
         w_sseguro := regcumul.sseguro;
         w_nriesgo := regcumul.nriesgo;
         w_cgarant := regcumul.cgarant;

         BEGIN
            SELECT cramo, cmodali, ctipseg, ccolect,
                   pac_seguros.ff_get_actividad(sseguro, w_nriesgo),
                   sproduc
              INTO w_cramo, w_cmodali, w_ctipseg, w_ccolect,
                   w_cactivi, v_sproduc
              FROM seguros
             WHERE sseguro = w_sseguro;
         EXCEPTION
            WHEN OTHERS THEN
               perr := 101919;
         END;

         FOR reggaranseg IN cur_garanseg LOOP
-- BUG 11100 - 16/09/2009 - FAL - Crida a la pac_cesionesrea.f_gar_rea per si garantia reasegurable
            perr := pac_cesionesrea.f_gar_rea(w_cramo, w_cmodali, w_ctipseg, w_ccolect,
                                              w_cactivi, reggaranseg.cgarant, w_creaseg);

            --IF w_creaseg = 1 OR w_creaseg = 3 THEN
            IF w_creaseg IN (1, 3, 5) THEN
                pcapital := pcapital + NVL(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(v_sproduc)),
                                                         pmoninst,
                                                         pfcambio,
                                                         reggaranseg.icapital)
                                              , 0);




            END IF;
         END LOOP;
      END LOOP;
   ELSE   -- tipus de contracte amb import propi fixe, no cal sumar capitals per trobar
          -- les proporcions
      NULL;
   END IF;

   RETURN(perr);
   END f_capital_cumul_mon;
   /*************************************************************************
    FUNCTION f_ple_cumul_est_mon
    Permite buscar el capital del cumulo en moneda local, para tramo 0(retencion)
    param in psseguro        : codigo seguro
    param in pscumulo        : codigo del cumulo
    param in pcgarant        : garantia
    param in pfefecto        : fecha efecto
    param in pmoninst        : moneda de instalacion
    param in pfcambio        : fecha para obtener la tasa de cambio
    param out pcapcum        : capital del cumulo
    param out pipleno        : importe del pleno(retencion)
    param out picapaci       : capacidad
    param in ptablas         : tablas
    return                   : number
   *************************************************************************/
   FUNCTION f_ple_cumul_est_mon(
      psseguro IN NUMBER,
      pscumulo IN NUMBER,
      pcgarant IN NUMBER,
      pfefecto IN DATE,
      pmoninst IN VARCHAR2,
      pfcambio IN DATE,
      pcapcum OUT NUMBER,
      pipleno OUT NUMBER,
      picapaci OUT NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST')
    RETURN NUMBER
   IS
      ------------------------------------------------------------------------------
      -- Obtenim l'import sumat del tram 0 del cúmul
      -- Les garanties 1 i 8 fan cúmul juntes, cal veure com parametritzar-ho
      -- de moment les posem a pinyó
      ------------------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_PLE_CUMUL_EST_MON';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || 's=' || psseguro || ' c=' || pscumulo || ' g=' || pcgarant || ' e=' || pfefecto || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      lcmaxcum  NUMBER;
      v_fefecto DATE; --29011 AVT 13/11/13
   BEGIN
      v_errlin := 4081;

      -- 29011 AVT 13/11/13
       SELECT    MAX(freaini)
            INTO v_fefecto
            FROM reariesgos r
           WHERE r.scumulo = pscumulo
            AND(r.freafin  > pfefecto
            OR r.freafin  IS NULL);

      v_errlin            := 4080;

      IF ptablas           = 'EST' THEN
          SELECT NVL(SUM(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(s.sproduc)),
                                                         pmoninst,
                                                         pfcambio,
                                                         NVL(c.icapces, 0))),0),
                 MAX(ipleno), MAX(icapaci)
               INTO pcapcum, pipleno, picapaci
               FROM seguros s, estseguros s2, cesionesrea c, reariesgos r
              WHERE c.scumulo = pscumulo
               AND c.ctramo   = 0
               AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
               AND c.fvencim  > pfefecto
               AND(c.fanulac  > pfefecto
               OR c.fanulac  IS NULL)
               AND(c.fregula  > pfefecto
               OR c.fregula  IS NULL)
               AND r.scumulo  = c.scumulo
               AND r.sseguro  = c.sseguro
               AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13    --BUG 4867 CPM: Se controla la fecha inicio
               AND(r.freafin  > pfefecto
               OR r.freafin  IS NULL)
               AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
               AND r.sseguro <> psseguro
               AND s2.sseguro = psseguro
               AND s.sseguro  = c.sseguro
               AND c.scontra  = r.scontra
               AND c.nversio  = r.nversio
               AND c.ctrampa IS NULL
               AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR'),
               NVL(c.cgarant, 0)) = NVL(f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
               pcgarant, 'REACUMGAR'), NVL(pcgarant, 0)); -- 14536 AVT 25-05-2010 fi

         -- 28777 AVT 13-11-13 nvl per quan fem cúmul de totes les garanties
         BEGIN
            v_errlin := 4085;

             SELECT    b.cmaxcum
                  INTO lcmaxcum
                  FROM cumulprod a, codicumprod b
                 WHERE a.ccumprod = b.ccumprod
                  AND a.sproduc   =
                  (SELECT    sproduc
                        FROM estseguros
                       WHERE sseguro = psseguro
                  )
                  AND a.finiefe <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND(a.ffinefe IS NULL
                  OR a.ffinefe   > pfefecto);
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            --DBMS_OUTPUT.put_line('2:' || SQLERRM);
            RETURN 40301;
         END;
      ELSIF ptablas = 'CAR' THEN
          SELECT NVL(SUM(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(s.sproduc)),
                                                         pmoninst,
                                                         pfcambio,
                                                         NVL(c.icapces, 0))),0),
                 MAX(ipleno), MAX(icapaci)
               INTO pcapcum, pipleno, picapaci
               FROM seguros s, seguros s2, cesionesrea c, reariesgos r
              WHERE c.scumulo = pscumulo
               AND c.ctramo   = 0
               AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
               AND c.fvencim  > pfefecto
               AND(c.fanulac  > pfefecto
               OR c.fanulac  IS NULL)
               AND(c.fregula  > pfefecto
               OR c.fregula  IS NULL)
               AND r.scumulo  = c.scumulo
               AND r.sseguro  = c.sseguro
               AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13    --BUG 4867 CPM: Se controla la fecha inicio
               AND(r.freafin  > pfefecto
               OR r.freafin  IS NULL)
               AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
               AND r.sseguro <> psseguro
               --AND c.cgarant = pcgarant -- 14536 AVT 25-05-2010
               AND s2.sseguro = psseguro
               AND s.sseguro  = c.sseguro
               AND c.scontra  = r.scontra
               AND c.nversio  = r.nversio
               AND c.ctrampa IS NULL
               AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR'),
               NVL(c.cgarant, 0)) = NVL(f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
               pcgarant, 'REACUMGAR'), NVL(pcgarant, 0)); -- 14536 AVT 25-05-2010 fi

         -- 28777 AVT 13-11-13 nvl per quan fem cúmul de totes les garanties
         BEGIN
            v_errlin := 4085;

             SELECT    b.cmaxcum
                  INTO lcmaxcum
                  FROM cumulprod a, codicumprod b
                 WHERE a.ccumprod = b.ccumprod
                  AND a.sproduc   =
                  (SELECT    sproduc
                        FROM seguros
                       WHERE sseguro = psseguro
                  )
                  AND a.finiefe <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND(a.ffinefe IS NULL
                  OR a.ffinefe   > pfefecto);
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            RETURN 40301;
         END;
      ELSE
          SELECT NVL(SUM(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(s.sproduc)),
                                                         pmoninst,
                                                         pfcambio,
                                                         NVL(c.icapces, 0))),0),
                 MAX(ipleno), MAX(icapaci)
               INTO pcapcum, pipleno, picapaci
               FROM seguros s, seguros s2, cesionesrea c, reariesgos r
              WHERE c.scumulo = pscumulo
               AND c.ctramo   = 0
               AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
               AND c.fvencim  > pfefecto
               AND(c.fanulac  > pfefecto
               OR c.fanulac  IS NULL)
               AND(c.fregula  > pfefecto
               OR c.fregula  IS NULL)
               AND r.scumulo  = c.scumulo
               AND r.sseguro  = c.sseguro
               AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13    --BUG 4867 CPM: Se controla la fecha inicio
               AND(r.freafin  > pfefecto
               OR r.freafin  IS NULL)
               AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
               AND r.sseguro <> psseguro
               --AND c.cgarant = pcgarant -- 14536 AVT 25-05-2010
               AND s2.sseguro = psseguro
               AND s.sseguro  = c.sseguro
               AND c.scontra  = r.scontra
               AND c.nversio  = r.nversio
               AND c.ctrampa IS NULL
               AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR'),
               NVL(c.cgarant, 0)) = NVL(f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
               pcgarant, 'REACUMGAR'), NVL(pcgarant, 0)); -- 14536 AVT 25-05-2010 fi

         -- 28777 AVT 13-11-13 nvl per quan fem cúmul de totes les garanties
         BEGIN
            v_errlin := 4085;

             SELECT    b.cmaxcum
                  INTO lcmaxcum
                  FROM cumulprod a, codicumprod b
                 WHERE a.ccumprod = b.ccumprod
                  AND a.sproduc   =
                  (SELECT    sproduc
                        FROM seguros
                       WHERE sseguro = psseguro
                  )
                  AND a.finiefe <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND(a.ffinefe IS NULL
                  OR a.ffinefe   > pfefecto);
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            RETURN 40301;
         END;
      END IF;

      IF NVL(lcmaxcum, 0) = 0 THEN
         -- Retornem els maxims del ple i capital a zero,
         -- pq no s'han de tenir en compte
         pipleno  := 0;
         picapaci := 0;
      END IF;

      --DBMS_OUTPUT.put_line(' -------------- PCAPCUM ' || pcapcum);
      RETURN 0;
   EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
      RETURN 105297;
   END f_ple_cumul_est_mon;

   /*************************************************************************
    FUNCTION f_ple_cumul_tot_est_mon
    Permite buscar el capital del cumulo en moneda local, para tramo 0(retencion)
    param in psseguro        : codigo seguro
    param in pscumulo        : codigo del cumulo
    param in pcgarant        : garantia
    param in pfefecto        : fecha efecto
    param in pscontra        : codigo contrato de reaseguro
    param in pscontra        : version contrato de reaseguro
    param in pmoninst        : moneda de instalacion
    param in pfcambio        : fecha para obtener la tasa de cambio
    param out pcapcum_tot        : capital del cumulo
    param out pipleno_tot        : importe del pleno(retencion)
    param in ptablas         : tablas
    return                   : number
   *************************************************************************/
   FUNCTION f_ple_cumul_tot_est_mon(
         psseguro IN NUMBER,
         pscumulo IN NUMBER,
         pcgarant IN NUMBER,
         pfefecto IN DATE,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pmoninst IN VARCHAR2,
         pfcambio IN DATE,
         pcapcum_tot OUT NUMBER,
         pipleno_tot OUT NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER
   IS
      ------------------------------------------------------------------------------
      -- Obtenim l'import sumat del tram 0 del cúmul
      -- Les garanties 1 i 8 fan cúmul juntes, cal veure com parametritzar-ho
      -- de moment les posem a pinyó
      ------------------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_PLE_CUMUL_TOT_EST_MON';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || ' s=' || psseguro || ' c=' || pscumulo || ' g=' || pcgarant || ' e=' || pfefecto || ' c=' || pscontra || ' v=' ||
      pnversio || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      lcmaxcum NUMBER;
      liretenc NUMBER;
      lcgarrel NUMBER;
      v_cempres seguros.cempres%TYPE;
      v_ctiprea codicontratos.ctiprea%TYPE; -- 28777 13-11-13
      perr NUMBER;                          -->> 28492 AVT 12/11/2013
      v_cramo seguros.cramo%TYPE;           -->> 28492 AVT 12/11/2013
      v_cmodali seguros.cmodali%TYPE;       -->> 28492 AVT 12/11/2013
      v_ctipseg seguros.ctipseg%TYPE;       -->> 28492 AVT 12/11/2013
      v_ccolect seguros.ccolect%TYPE;       -->> 28492 AVT 12/11/2013
      v_cactivi seguros.cactivi%TYPE;       -->> 28492 AVT 12/11/2013
      v_scontra contratos.scontra%TYPE;     -->> 28492 AVT 12/11/2013
      v_nversio contratos.nversio%TYPE;     -->> 28492 AVT 12/11/2013
      v_icapaci contratos.icapaci%TYPE;     -->> 28492 AVT 12/11/2013
      v_cdetces cesionesrea.cdetces%TYPE;   -->> 28492 AVT 12/11/2013
      v_fefecto DATE;                       --29011 AVT 13/11/13
   BEGIN
      v_errlin := 5001;

      -- 29011 AVT 13/11/13
       SELECT    MAX(freaini)
            INTO v_fefecto
            FROM reariesgos r
           WHERE r.scumulo = pscumulo
            AND(r.freafin  > pfefecto
            OR r.freafin  IS NULL);

      v_errlin            := 5000;

      -- AVT 28777 13-11-13 en cas de XL el ple net de retnció és el total del Capital (hauia de ser el tram?...)
       SELECT    ctiprea
            INTO v_ctiprea
            FROM codicontratos
           WHERE scontra = pscontra;

      v_errlin          := 5005;

      IF ptablas         = 'EST' THEN
          SELECT    cempres, cramo, cmodali, ctipseg, ccolect, cactivi
               INTO v_cempres, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi
               FROM estseguros seg
              WHERE seg.sseguro = psseguro;
      ELSE
          SELECT    cempres, cramo, cmodali, ctipseg, ccolect, cactivi
               INTO v_cempres, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi
               FROM seguros seg
              WHERE seg.sseguro = psseguro;
      END IF;

      IF v_ctiprea = 3 THEN
         --28492 AVT 13/11/2013 LA SELECT NO SERVEIX SI UN CONTRACTE COBREIS DOS O MÉS PRODUCTES.
         perr := f_buscacontrato(psseguro, pfefecto, v_cempres, pcgarant, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi, 11, v_scontra, v_nversio,
         liretenc, v_icapaci, v_cdetces); -- revisar evento!!!

         IF perr <> 0 THEN
            RETURN(perr);
         END IF;
         --         SELECT NVL(a.ilimsub, icapaci), NVL(cgarrel, 0)
         --           INTO liretenc, lcgarrel
         --           FROM contratos c, agr_contratos a
         --          WHERE c.scontra = a.scontra
         --            AND c.scontra = pscontra
         --            AND c.nversio = pnversio;
      ELSE -- 28777 13-11-13 fi --------------
          SELECT    iretenc, NVL(cgarrel, 0)
               INTO liretenc, lcgarrel
               FROM contratos
              WHERE scontra = pscontra
               AND nversio  = pnversio;
      END IF;

      v_errlin                                                        := 5005;

      IF ptablas                                                       = 'EST' THEN
         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REACUM'), 0) = 1 THEN
            v_errlin                                                  := 5010;

             SELECT NVL(SUM(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(s.sproduc)),
                                                         pmoninst,
                                                         pfcambio,
                                                         NVL(c.icapces, 0))),0),
                    NVL(MAX(ipleno), 0)
                  INTO pcapcum_tot, pipleno_tot
                  FROM seguros s, estseguros s2, cesionesrea c, reariesgos r
                 WHERE c.scumulo = pscumulo
                  AND c.ctramo   = 0
                  AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND c.fvencim  > pfefecto
                  AND(c.fanulac  > pfefecto
                  OR c.fanulac  IS NULL)
                  AND(c.fregula  > pfefecto
                  OR c.fregula  IS NULL)
                  AND r.scumulo  = c.scumulo
                  AND r.sseguro  = c.sseguro
                  AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
                  AND(r.freafin  > pfefecto
                  OR r.freafin  IS NULL)
                  AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
                  AND r.sseguro <> psseguro
                  AND s2.sseguro = psseguro
                  AND s.sseguro  = c.sseguro
                  AND c.scontra  = pscontra
                  AND c.nversio  = pnversio
                  AND c.ctrampa IS NULL
                  AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR')
                  , NVL(c.cgarant, 0)) = NVL(f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
                  pcgarant, 'REACUMGAR'), NVL(pcgarant, 0));
         ELSE
            v_errlin := 5015;

             SELECT NVL(SUM(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(s.sproduc)),
                                                         pmoninst,
                                                         pfcambio,
                                                         NVL(c.icapces, 0))),0),
                     NVL(MAX(ipleno), 0)
                  INTO pcapcum_tot, pipleno_tot
                  FROM seguros s, cesionesrea c, reariesgos r
                 WHERE c.scumulo  = pscumulo
                  AND c.scontra   = pscontra
                  AND c.nversio   = pnversio
                  AND c.ctramo    = 0
                  AND c.fefecto  <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND c.fvencim   > pfefecto
                  AND(c.fanulac   > pfefecto
                  OR c.fanulac   IS NULL)
                  AND(c.fregula   > pfefecto
                  OR c.fregula   IS NULL)
                  AND r.scumulo   = c.scumulo
                  AND r.sseguro   = c.sseguro
                  AND freaini    <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
                  AND(r.freafin   > pfefecto
                  OR r.freafin   IS NULL)
                  AND cgenera    IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
                  AND c.ctrampa IS NULL
                  AND((lcgarrel   = 0
                  AND c.cgarant   = pcgarant
                  AND r.sseguro  <> psseguro
                  AND r.sseguro   = s.sseguro) -- AVT bug: 12665 13-01-2010
                  OR(lcgarrel     = 1
                  AND((r.sseguro <> psseguro
                  AND(c.cgarant   = DECODE(pcgarant, 1, 8, 8, 1, pcgarant)
                  OR c.cgarant    = pcgarant))
                  OR(r.sseguro    = psseguro
                  AND c.cgarant  <> pcgarant
                  AND pcgarant   IN(1, 8)

                  AND c.cgarant  IN(1, 8)))));
         END IF; -- JGR 2004-05-26 HASTA
      ELSIF ptablas                                                    = 'CAR' THEN
         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REACUM'), 0) = 1 THEN
            --FI BUG 9704  - 15/04/09 – ICV
            -- CPM 20/07/04: Afegim s2 per trobar les dades del seguro que estem tractant
            v_errlin := 5010;

            -- 13946 AVT 06-04-2010 s'afegeix el SCONTRA i la NVERSIO.
             SELECT NVL(SUM(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(s.sproduc)),
                                                         pmoninst,
                                                         pfcambio,
                                                         NVL(c.icapces, 0))),0),
                    NVL(MAX(ipleno), 0)
                  INTO pcapcum_tot, pipleno_tot
                  FROM seguros s, seguros s2, cesionesrea c, reariesgos r
                 WHERE c.scumulo = pscumulo
                  AND c.ctramo   = 0
                  AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND c.fvencim  > pfefecto
                  AND(c.fanulac  > pfefecto
                  OR c.fanulac  IS NULL)
                  AND(c.fregula  > pfefecto
                  OR c.fregula  IS NULL)
                  AND r.scumulo  = c.scumulo
                  AND r.sseguro  = c.sseguro
                  AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
                  AND(r.freafin  > pfefecto
                  OR r.freafin  IS NULL)
                  AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
                  AND r.sseguro <> psseguro
                  AND s2.sseguro = psseguro
                  AND s.sseguro  = c.sseguro
                  AND c.scontra  = pscontra
                  AND c.nversio  = pnversio
                  AND c.ctrampa IS NULL
                  AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR')
                  , NVL(c.cgarant, 0)) = NVL(f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
                  pcgarant, 'REACUMGAR'), NVL(pcgarant, 0));
         ELSE -- JGR 2004-05-26 HASTA
            -- AVT AQUESTA SELECT NO FUNCIONA PER lcgarrel = 0 (BUG:12665)
            v_errlin := 5015;

            -- 13946 AVT 06-04-2010 s'afegeix el SCONTRA i la NVERSIO.
             SELECT NVL(SUM(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(s.sproduc)),
                                                         pmoninst,
                                                         pfcambio,
                                                         NVL(c.icapces, 0))),0),
                    NVL(MAX(ipleno), 0)
                  INTO pcapcum_tot, pipleno_tot
                  FROM seguros s, cesionesrea c, reariesgos r
                 WHERE c.scumulo  = pscumulo
                  AND c.scontra   = pscontra
                  AND c.nversio   = pnversio
                  AND c.ctramo    = 0
                  AND c.fefecto  <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND c.fvencim   > pfefecto
                  AND(c.fanulac   > pfefecto
                  OR c.fanulac   IS NULL)
                  AND(c.fregula   > pfefecto
                  OR c.fregula   IS NULL)
                  AND r.scumulo   = c.scumulo
                  AND r.sseguro   = c.sseguro
                  AND freaini    <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
                  AND(r.freafin   > pfefecto
                  OR r.freafin   IS NULL)
                  AND cgenera    IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
                  AND c.ctrampa IS NULL
                  AND((lcgarrel   = 0
                  AND c.cgarant   = pcgarant
                  AND r.sseguro  <> psseguro
                  AND r.sseguro   = s.sseguro) -- AVT bug: 12665 13-01-2010
                  OR(lcgarrel     = 1
                  AND((r.sseguro <> psseguro
                  AND(c.cgarant   = DECODE(pcgarant, 1, 8, 8, 1, pcgarant)
                  OR c.cgarant    = pcgarant))
                  OR(r.sseguro    = psseguro
                  AND c.cgarant  <> pcgarant
                  AND pcgarant   IN(1, 8)
                  AND c.cgarant  IN(1, 8)))));
         END IF; -- JGR 2004-05-26 HASTA
      ELSE
         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REACUM'), 0) = 1 THEN
            --FI BUG 9704  - 15/04/09 – ICV
            -- CPM 20/07/04: Afegim s2 per trobar les dades del seguro que estem tractant
            v_errlin := 5010;

            -- 13946 AVT 06-04-2010 s'afegeix el SCONTRA i la NVERSIO.
             SELECT NVL(SUM(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(s.sproduc)),
                                                         pmoninst,
                                                         pfcambio,
                                                         NVL(c.icapces, 0))),0),
                    NVL(MAX(ipleno), 0)
                  INTO pcapcum_tot, pipleno_tot
                  FROM seguros s, seguros s2, cesionesrea c, reariesgos r
                 WHERE c.scumulo = pscumulo
                  AND c.ctramo   = 0
                  AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND c.fvencim  > pfefecto
                  AND(c.fanulac  > pfefecto
                  OR c.fanulac  IS NULL)
                  AND(c.fregula  > pfefecto
                  OR c.fregula  IS NULL)
                  AND r.scumulo  = c.scumulo
                  AND r.sseguro  = c.sseguro
                  AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
                  AND(r.freafin  > pfefecto
                  OR r.freafin  IS NULL)
                  AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
                  AND r.sseguro <> psseguro
                  AND s2.sseguro = psseguro
                  AND s.sseguro  = c.sseguro
                  AND c.scontra  = pscontra
                  AND c.nversio  = pnversio
                  AND c.ctrampa IS NULL
                  AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR')
                  , NVL(c.cgarant, 0)) = NVL(f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
                  pcgarant, 'REACUMGAR'), NVL(pcgarant, 0));
         ELSE -- JGR 2004-05-26 HASTA
            -- AVT AQUESTA SELECT NO FUNCIONA PER lcgarrel = 0 (BUG:12665)
            v_errlin := 5015;

            -- 13946 AVT 06-04-2010 s'afegeix el SCONTRA i la NVERSIO.
             SELECT NVL(SUM(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(s.sproduc)),
                                                         pmoninst,
                                                         pfcambio,
                                                         NVL(c.icapces, 0))),0),
                    NVL(MAX(ipleno), 0)
                  INTO pcapcum_tot, pipleno_tot
                  FROM seguros s, cesionesrea c, reariesgos r
                 WHERE c.scumulo  = pscumulo
                  AND c.scontra   = pscontra
                  AND c.nversio   = pnversio
                  AND c.ctramo    = 0
                  AND c.fefecto  <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND c.fvencim   > pfefecto
                  AND(c.fanulac   > pfefecto
                  OR c.fanulac   IS NULL)
                  AND(c.fregula   > pfefecto
                  OR c.fregula   IS NULL)
                  AND r.scumulo   = c.scumulo
                  AND r.sseguro   = c.sseguro
                  AND freaini    <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
                  AND(r.freafin   > pfefecto
                  OR r.freafin   IS NULL)
                  AND cgenera    IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
                  AND c.ctrampa IS NULL
                  AND((lcgarrel   = 0
                  AND c.cgarant   = pcgarant
                  AND r.sseguro  <> psseguro
                  AND r.sseguro   = s.sseguro) -- AVT bug: 12665 13-01-2010
                  OR(lcgarrel     = 1
                  AND((r.sseguro <> psseguro
                  AND(c.cgarant   = DECODE(pcgarant, 1, 8, 8, 1, pcgarant)
                  OR c.cgarant    = pcgarant))
                  OR(r.sseguro    = psseguro
                  AND c.cgarant  <> pcgarant
                  AND pcgarant   IN(1, 8)
                  AND c.cgarant  IN(1, 8)))));
         END IF; -- JGR 2004-05-26 HASTA
      END IF;

      -- Obtenir el ple del contracte, el total
      IF ptablas = 'EST' THEN
         BEGIN
            v_errlin := 5020;

             SELECT    b.cmaxcum
                  INTO lcmaxcum
                  FROM cumulprod a, codicumprod b
                 WHERE a.ccumprod = b.ccumprod
                  AND a.sproduc   =
                  (SELECT    sproduc
                        FROM estseguros
                       WHERE sseguro = psseguro
                  )
                  AND a.finiefe <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND(a.ffinefe IS NULL
                  OR a.ffinefe   > pfefecto);
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            --DBMS_OUTPUT.put_line('3:' || SQLERRM);
            RETURN 40301;
         END;
      ELSE
         -- Obtenir el ple del contracte, el total
         BEGIN
            v_errlin := 5020;

             SELECT    b.cmaxcum
                  INTO lcmaxcum
                  FROM cumulprod a, codicumprod b
                 WHERE a.ccumprod = b.ccumprod
                  AND a.sproduc   =
                  (SELECT    sproduc
                        FROM seguros
                       WHERE sseguro = psseguro
                  )
                  AND a.finiefe <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
                  AND(a.ffinefe IS NULL
                  OR a.ffinefe   > pfefecto);
         EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
            RETURN 40301;
         END;
      END IF;

      IF lcmaxcum     = 0 THEN
         pipleno_tot := liretenc;
      ELSE -- el màxim
         IF liretenc     > pipleno_tot THEN
            pipleno_tot := liretenc;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
      RETURN 105297;
   END f_ple_cumul_tot_est_mon;
   /*************************************************************************
    FUNCTION f_captram_cumul_est_mon
    Permite buscar el capital del tramo en moneda local
    param in psseguro        : codigo seguro
    param in pscumulo        : codigo del cumulo
    param in pcgarant        : garantia
    param in pfefecto        : fecha efecto
    param in pctramo         : codigo del tramo
    param in pscontra        : codigo contrato de reaseguro
    param in pnversio        : version contrato de reaseguro
    param in pmoninst        : moneda de instalacion
    param in pfcambio        : fecha para obtener la tasa de cambio
    param out pcapcum        : capital del tramo
    param in-out piplenotot  : pleno total
    param in ptablas         : tablas
    return                   : number
   *************************************************************************/
   FUNCTION f_captram_cumul_est_mon(
         psseguro IN NUMBER,
         pscumulo IN NUMBER,
         pcgarant IN NUMBER,
         pfefecto IN DATE,
         pctramo IN NUMBER,
         pscontra IN NUMBER,
         pnversio IN NUMBER,
         pmoninst IN VARCHAR2,
         pfcambio IN DATE,
         pcapcum OUT NUMBER,
         piplenotot IN OUT NUMBER,
         ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER
   IS
      --, picapaci OUT NUMBER) RETURN NUMBER IS
      ------------------------------------------------------------------------------
      -- Obtenim l'import sumat del tram ctramo del cúmul
      -- Les garanties 1 i 8 fan cúmul juntes, cal veure com parametritzar-ho
      -- de moment les posem a pinyó
      ------------------------------------------------------------------------------

      -- ini Bug 0012020 - 17/11/2009 - JMF
      v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_CAPTRAM_CUMUL_EST';
      v_errlin NUMBER        := 0;
      v_errpar VARCHAR2(500) := '(' || 's=' || psseguro || ' c=' || pscumulo || ' g=' || pcgarant || ' e=' || pfefecto || 't=' || pctramo || ' c=' || pscontra
      || ' v=' || pnversio || ' i=' || piplenotot || ')';
      -- fin Bug 0012020 - 17/11/2009 - JMF
      lcmaxcum NUMBER;
      lcgarrel NUMBER;
      liretenc NUMBER;
      v_ctiprea codicontratos.ctiprea%TYPE; -- 28777 13-11-13
      perr NUMBER;                          -->> 28492 AVT 12/11/2013
      v_cempres seguros.cempres%TYPE;       -->> 28492 AVT 12/11/2013
      v_cramo seguros.cramo%TYPE;           -->> 28492 AVT 12/11/2013
      v_cmodali seguros.cmodali%TYPE;       -->> 28492 AVT 12/11/2013
      v_ctipseg seguros.ctipseg%TYPE;       -->> 28492 AVT 12/11/2013
      v_ccolect seguros.ccolect%TYPE;       -->> 28492 AVT 12/11/2013
      v_cactivi seguros.cactivi%TYPE;       -->> 28492 AVT 12/11/2013
      v_scontra contratos.scontra%TYPE;     -->> 28492 AVT 12/11/2013
      v_nversio contratos.nversio%TYPE;     -->> 28492 AVT 12/11/2013
      v_icapaci contratos.icapaci%TYPE;     -->> 28492 AVT 12/11/2013
      v_cdetces cesionesrea.cdetces%TYPE;   -->> 28492 AVT 12/11/2013
      v_fefecto DATE;                       --29011 AVT 13/11/13
   BEGIN
      v_errlin := 5001;

      -- 29011 AVT 13/11/13
       SELECT    MAX(freaini)
            INTO v_fefecto
            FROM reariesgos r
           WHERE r.scumulo = pscumulo
            AND(r.freafin  > pfefecto
            OR r.freafin  IS NULL);

      v_errlin            := 5000;

      -- AVT 28777 13-11-13 en cas de XL el ple net de retnció és el total del Capital (hauia de ser el tram?...)
       SELECT    ctiprea
            INTO v_ctiprea
            FROM codicontratos
           WHERE scontra = pscontra;

      v_errlin          := 5005;

      IF v_ctiprea       = 3 THEN
         --28492 AVT 13/11/2013 LA SELECT NO SERVEIX SI UN CONTRACTE COBREIS DOS O MÉS PRODUCTES.
         IF ptablas = 'EST' THEN
             SELECT    cempres, cramo, cmodali, ctipseg, ccolect, cactivi
                  INTO v_cempres, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi
                  FROM estseguros seg
                 WHERE seg.sseguro = psseguro;
         ELSE
             SELECT    cempres, cramo, cmodali, ctipseg, ccolect, cactivi
                  INTO v_cempres, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi
                  FROM seguros seg
                 WHERE seg.sseguro = psseguro;
         END IF;

         perr := f_buscacontrato(psseguro, pfefecto, v_cempres, pcgarant, v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi, 11, v_scontra, v_nversio,
         liretenc, v_icapaci, v_cdetces); -- revisar evento!!!

         IF perr <> 0 THEN
            RETURN(perr);
         END IF;

      ELSE -- 28777 13-11-13 fi --------------
          SELECT    iretenc, NVL(cgarrel, 0)
               INTO liretenc, lcgarrel
               FROM contratos
              WHERE scontra = pscontra
               AND nversio  = pnversio;
      END IF;

      v_errlin  := 5355;

      IF ptablas = 'EST' THEN
          SELECT NVL(SUM(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(s.sproduc)),
                                                         pmoninst,
                                                         pfcambio,
                                                         NVL(c.icapces, 0))),0)
               INTO pcapcum
               FROM seguros s, estseguros s2, cesionesrea c, reariesgos r
              WHERE c.scumulo = pscumulo
               AND c.ctramo   = pctramo
               AND c.scontra  = pscontra
               AND c.nversio  = pnversio
               AND s.sseguro  = c.sseguro
               AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
               AND c.fvencim  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               AND(c.fanulac  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               OR c.fanulac  IS NULL)
               AND(c.fregula  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               OR c.fregula  IS NULL)
               AND r.scumulo  = c.scumulo
               AND r.sseguro  = c.sseguro
               AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
               AND(r.freafin  > NVL(v_fefecto, pfefecto)  -- Bugs 31509 22-05-14
               OR r.freafin  IS NULL)
               AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
               AND((lcgarrel  = 0
               AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR'),
               NVL(c.cgarant, 0)) = NVL(f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
               pcgarant, 'REACUMGAR'), NVL(pcgarant, 0))
               AND r.sseguro <> psseguro
               AND s2.sseguro = psseguro));
      ELSIF ptablas           = 'CAR' THEN
          SELECT NVL(SUM(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(s.sproduc)),
                                                         pmoninst,
                                                         pfcambio,
                                                         NVL(c.icapces, 0))),0)
               INTO pcapcum                --, pipleno, picapaci
               FROM seguros s, seguros s2, cesionesrea c, reariesgos r
              WHERE c.scumulo = pscumulo
               AND c.ctramo   = pctramo
               AND c.scontra  = pscontra
               AND c.nversio  = pnversio
               AND s.sseguro  = c.sseguro
               AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
               AND c.fvencim  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               AND(c.fanulac  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               OR c.fanulac  IS NULL)
               AND(c.fregula  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               OR c.fregula  IS NULL)
               AND r.scumulo  = c.scumulo
               AND r.sseguro  = c.sseguro
               AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
               AND(r.freafin  > NVL(v_fefecto, pfefecto)  -- Bugs 31509 22-05-14
               OR r.freafin  IS NULL)
               AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
               AND((lcgarrel  = 0
               --AND c.cgarant = pcgarant -- 14536 AVT 25-05-2010
               AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR'),
               NVL(c.cgarant, 0)) = NVL (f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
               pcgarant, 'REACUMGAR'), NVL(pcgarant, 0)) -- 14536 AVT 25-05-2010  fi
               AND r.sseguro <> psseguro
               AND s2.sseguro = psseguro)
               );
      ELSE
          SELECT NVL(SUM(pac_eco_tipocambio.f_importe_cambio(pac_monedas.f_cmoneda_t(pac_monedas.f_moneda_producto(s.sproduc)),
                                                         pmoninst,
                                                         pfcambio,
                                                         NVL(c.icapces, 0))),0)
               INTO pcapcum                --, pipleno, picapaci
               FROM seguros s, seguros s2, cesionesrea c, reariesgos r
              WHERE c.scumulo = pscumulo
               AND c.ctramo   = pctramo
               AND c.scontra  = pscontra
               AND c.nversio  = pnversio
               AND s.sseguro  = c.sseguro
               AND c.fefecto <= NVL(v_fefecto, pfefecto) -- 29011 AVT 13/11/13
               AND c.fvencim  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               AND(c.fanulac  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               OR c.fanulac  IS NULL)
               AND(c.fregula  > NVL(v_fefecto, pfefecto) -- Bugs 31509 22-05-14
               OR c.fregula  IS NULL)
               AND r.scumulo  = c.scumulo
               AND r.sseguro  = c.sseguro
               AND freaini   <= NVL (v_fefecto, pfefecto) -- 29011 AVT 13/11/13   --BUG 4867 CPM: Se controla la fecha inicio
               AND(r.freafin  > NVL(v_fefecto, pfefecto)  -- Bugs 31509 22-05-14
               OR r.freafin  IS NULL)
               AND cgenera   IN(1, 3, 4, 5, 9, 10, 20, 40, 41)
               AND((lcgarrel  = 0
               --AND c.cgarant = pcgarant -- 14536 AVT 25-05-2010
               AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, pac_seguros.ff_get_actividad(s.sseguro, r.nriesgo), c.cgarant, 'REACUMGAR'),
               NVL(c.cgarant, 0)) = NVL (f_pargaranpro_v(s2.cramo, s2.cmodali, s2.ctipseg, s2.ccolect, pac_seguros.ff_get_actividad(s2.sseguro, r.nriesgo),
               pcgarant, 'REACUMGAR'), NVL(pcgarant, 0)) -- 14536 AVT 25-05-2010  fi
               AND r.sseguro <> psseguro
               AND s2.sseguro = psseguro)
               /*   OR(lcgarrel = 1
               AND((r.sseguro <> psseguro
               AND(c.cgarant = DECODE(pcgarant, 1, 8, 8, 1, pcgarant)
               OR c.cgarant = pcgarant))
               OR(r.sseguro = psseguro
               AND c.cgarant <> pcgarant
               AND pcgarant IN(1, 8)
               AND c.cgarant IN(1, 8))))*/
               );
      END IF;

      v_errlin      := 5360;

      IF lcgarrel    = 1 THEN
         piplenotot := liretenc;
      END IF;

      RETURN 0;
   EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
      RETURN 105297;
   END f_captram_cumul_est_mon;
   --FIN BUG CONF-620  - Fecha (01/03/2017) - HRE

  -- ERHF

  FUNCTION f_calcula_cesiones(
    psseguro IN NUMBER,
    pnmovimi IN NUMBER,
    psproces IN NUMBER,
    pmotiu   IN NUMBER,
    pmoneda  IN NUMBER,
    pnpoliza IN NUMBER DEFAULT -1,
    pncertif IN NUMBER DEFAULT -1,
    porigen  IN NUMBER DEFAULT 1,  -- 1- Ve d'emissió/renovació  2-Ve de q. d'amortització  3-Cesiones Manuales
    pfinici  IN DATE DEFAULT NULL, -- Inici de cessió forçat
    pffin    IN DATE DEFAULT NULL,
    ptablas  IN VARCHAR2 DEFAULT 'EST')
  RETURN NUMBER
IS
  v_existereg    NUMBER        := 0;
  v_existeregest NUMBER        := 0;
  v_mensaje      VARCHAR2(500) := NULL;
  vpasexec       NUMBER        := 0;
  v_cempres      NUMBER        := 12;
  num_err        NUMBER        := 0;
  vpar_traza     VARCHAR2(80)  := 'TRAZA_CESIONES_REA';
  --INICIO (QT23988 + BUG37400): AGG – 18/02/2016
  v_paquete VARCHAR2(100) := 'PAC_CESIONESREA';
  v_funcion VARCHAR2(100) := 'F_CALCULA_CESIONES';
  --FIN (QT23988 + BUG37400): AGG – 18/02/2016
  w_scesrea NUMBER := 0;
  v_scesrea NUMBER := 0;
  v_scontra NUMBER := 0;
  v_cvidaga NUMBER := 0;
  CURSOR cur_est_agrupa(psseguro IN NUMBER)
  IS
    SELECT scesrea,
      ncesion,
      icesion,
      icapces,
      psseguro,
      nversio,
      scontra,
      ctramo,
      sfacult,
      nriesgo,
      icomisi,
      scumulo,
      cgarant,
      spleno,
      nsinies,
      fefecto,
      fvencim,
      fcontab,
      pcesion,
      psproces,
      cgenera,
      fgenera,
      fregula,
      fanulac,
      pnmovimi,
      sidepag,
      ipritarrea,
      psobreprima,
      cdetces,
      ipleno,
      icapaci,
      nmovigen,
      iextrap,
      iextrea,
      nreemb,
      nfact,
      nlinea,
      itarifrea,
      icomext,
      sseguro,
      ctipomov
    FROM estcesionesrea
    WHERE (sseguro = psseguro)
    OR (ssegpol    = psseguro)
    AND cgarant   IS NULL;
  CURSOR cur_est(psseguro IN NUMBER)
  IS
    SELECT scesrea,
      ncesion,
      icesion,
      icapces,
      psseguro,
      nversio,
      scontra,
      ctramo,
      sfacult,
      nriesgo,
      icomisi,
      scumulo,
      cgarant,
      spleno,
      nsinies,
      fefecto,
      fvencim,
      fcontab,
      pcesion,
      psproces,
      cgenera,
      fgenera,
      fregula,
      fanulac,
      pnmovimi,
      sidepag,
      ipritarrea,
      psobreprima,
      cdetces,
      ipleno,
      icapaci,
      nmovigen,
      iextrap,
      iextrea,
      nreemb,
      nfact,
      nlinea,
      itarifrea,
      icomext,
      sseguro,
      ctipomov
    FROM estcesionesrea
    WHERE (sseguro = psseguro)
    OR(ssegpol     = psseguro);
BEGIN
  vpasexec := 1;
  --INICIO (QT23988 + BUG37400): AGG – 18/02/2016
  p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, 'Entra. psseguro ' || psseguro || ' pnmovimi: ' || pnmovimi || ' psproces: ' || psproces || ' pmotiu: ' || pmotiu || ' pmoneda: ' || pmoneda || ' pnpoliza: ' || pnpoliza || ' pncertif: ' || pncertif || 'porigen: ' || porigen || ' pfinici: ' || pfinici || ' pffin: ' || pffin || ' ptablas: ' || ptablas);
  --FIN (QT23988 + BUG37400): AGG – 18/02/2016
  SELECT COUNT(1)
  INTO v_existereg
  FROM estcesionesrea
  WHERE (ssegpol = psseguro
  OR sseguro     = psseguro)
  OR(npoliza     = pnpoliza
  AND ncertif    = pncertif);
  --INICIO (QT23988 + BUG37400): AGG – 18/02/2016
  vpasexec := 2;
  p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, 'v_existereg: ' || v_existereg);
  --FIN (QT23988 + BUG37400): AGG – 18/02/2016
  IF porigen = 3 THEN
    BEGIN
      v_mensaje := pac_cesionesrea.f_buscactrrea_est(psseguro, pnmovimi, psproces, pmotiu, pmoneda, porigen, pfinici, pffin, ptablas);
      --INICIO (QT23988 + BUG37400): AGG – 18/02/2016
      vpasexec := 3;
      p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, 'f_buscactrrea_est mensaje:' || v_mensaje);
      --FIN (QT23988 + BUG37400): AGG – 18/02/2016
      IF v_mensaje <> 0 AND v_mensaje <> 99 THEN
        --INICIO (QT23988 + BUG37400): AGG – 18/02/2016
        vpasexec := 4;
        --FIN (QT23988 + BUG37400): AGG – 18/02/2016
        num_err := 1;
        ROLLBACK;
        p_tab_error(f_sysdate, f_user, 'f_calcula_cesiones', vpasexec, 'pcempres = ' || v_cempres || ' psseguro = ' || psseguro || ' psproces = ' || psproces || ' pmoneda = ' || pmoneda, f_axis_literales(v_mensaje, 2));
        --INICIO (QT23988 + BUG37400): AGG – 18/02/2016
        p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, f_axis_literales(v_mensaje, 2));
        --FIN (QT23988 + BUG37400): AGG – 18/02/2016
      ELSIF v_mensaje = 99 THEN
        --INICIO (QT23988 + BUG37400): AGG – 18/02/2016
        vpasexec := 5;
        -- s'atura per facultatiu
        p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, v_mensaje);
        --FIN (QT23988 + BUG37400): AGG – 18/02/2016
        v_mensaje := 0;
      ELSE
        --INICIO (QT23988 + BUG37400): AGG – 18/02/2016
        vpasexec  := 6;
        v_mensaje := f_cessio_est(psproces, pmotiu, pmoneda, f_sysdate, 0, ptablas);
        p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, 'f_calcula_est mensaje:' || v_mensaje);
        --FIN (QT23988 + BUG37400): AGG – 18/02/2016
        IF v_mensaje <> 0 AND v_mensaje <> 99 THEN
          --INICIO (QT23988 + BUG37400): AGG – 18/02/2016
          vpasexec := 7;
          num_err  := 1;
          ROLLBACK;
          p_tab_error(f_sysdate, f_user, 'f_calcula_cesiones', vpasexec, 'pcempres = ' || v_cempres || ' psseguro = ' || psseguro || ' psproces = ' || psproces || ' pmoneda = ' || pmoneda, f_axis_literales(v_mensaje, 2));
          p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, f_axis_literales(v_mensaje, 2));
          --FIN (QT23988 + BUG37400): AGG – 18/02/2016
        ELSIF v_mensaje = 99 THEN
          --INICIO (QT23988 + BUG37400): AGG – 18/02/2016
          vpasexec := 8;
          num_err  := 1;
          /*AGG 28/08/2015
          Si estamos en modo real y no hay facultativo no se puede emitir la póliza y por lo tanto devolvemos un mensaje
          de error donde se indica que no hay facultativo devolviendo el v_mensaje = 105382.
          Sin embargo, cuando estamos trabajando con las tablas ''EST' no se debe devolver este error ya que es en este
          momento donde hay crear el facultativo*/
          IF ptablas   = 'REA' THEN
            v_mensaje := 105382; --No te facultatiu
          END IF;
          p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, 'v_mensaje: ' || v_mensaje);
          --FIN (QT23988 + BUG37400): AGG – 18/02/2016
          COMMIT;
        END IF;
      END IF;
    END;
  ELSE
    BEGIN
      IF (v_existereg > 0) AND(ptablas = 'REA') THEN
        BEGIN
          --INICIO (QT23988 + BUG37400): AGG – 18/02/2016
          vpasexec := 9;
          --primero borramos los registros originales
          DELETE cesionesrea
          WHERE sseguro = psseguro;
          --buscamos si agrupa por garantia
          BEGIN
            SELECT DISTINCT scontra
            INTO v_scontra
            FROM estcesionesrea
            WHERE ssegpol = psseguro
            AND ROWNUM    = 1;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_scontra := -1;
          END;
          BEGIN
            SELECT cvidaga INTO v_cvidaga FROM codicontratos WHERE scontra = v_scontra;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_cvidaga := -1;
          END;
          p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, 'v_cvidaga: ' || v_cvidaga || ' v_scontra: ' || v_scontra);
          --FIN (QT23988 + BUG37400): AGG – 18/02/2016
          IF v_cvidaga = 1 THEN
            BEGIN
              FOR v_est IN cur_est_agrupa(psseguro)
              LOOP
                BEGIN
                  --INICIO (QT23988 + BUG37400): AGG – 18/02/2016
                  vpasexec := 10;
                  SELECT scesrea.NEXTVAL INTO w_scesrea FROM DUAL;
                  INSERT
                  INTO cesionesrea
                    (
                      scesrea,
                      ncesion,
                      icesion,
                      icapces,
                      sseguro,
                      nversio,
                      scontra,
                      ctramo,
                      sfacult,
                      nriesgo,
                      icomisi,
                      scumulo,
                      cgarant,
                      spleno,
                      nsinies,
                      fefecto,
                      fvencim,
                      fcontab,
                      pcesion,
                      sproces,
                      cgenera,
                      fgenera,
                      fregula,
                      fanulac,
                      nmovimi,
                      sidepag,
                      ipritarrea,
                      psobreprima,
                      cdetces,
                      ipleno,
                      icapaci,
                      nmovigen,
                      iextrap,
                      iextrea,
                      nreemb,
                      nfact,
                      nlinea,
                      itarifrea,
                      icomext,
                      ctipomov
                    )
                  SELECT w_scesrea,
                    v_est.ncesion,
                    v_est.icesion,
                    v_est.icapces,
                    psseguro,
                    v_est.nversio,
                    v_est.scontra,
                    v_est.ctramo,
                    v_est.sfacult,
                    v_est.nriesgo,
                    v_est.icomisi,
                    v_est.scumulo,
                    v_est.cgarant,
                    v_est.spleno,
                    v_est.nsinies,
                    v_est.fefecto,
                    v_est.fvencim,
                    v_est.fcontab,
                    pcesion,
                    psproces,
                    v_est.cgenera,
                    v_est.fgenera,
                    v_est.fregula,
                    v_est.fanulac,
                    pnmovimi,
                    v_est.sidepag,
                    v_est.ipritarrea,
                    v_est.psobreprima,
                    v_est.cdetces,
                    v_est.ipleno,
                    v_est.icapaci,
                    v_est.nmovigen,
                    v_est.iextrap,
                    v_est.iextrea,
                    v_est.nreemb,
                    v_est.nfact,
                    v_est.nlinea,
                    v_est.itarifrea,
                    v_est.icomext,
                    v_est.ctipomov
                  FROM estcesionesrea
                  WHERE scesrea = v_est.scesrea;
                  p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, 'v_est.scesrea: ' || v_est.scesrea);
                  --FIN (QT23988 + BUG37400): AGG – 18/02/2016
                  DELETE estcesionesrea
                  WHERE (sseguro = psseguro)
                  OR (ssegpol    = psseguro)
                  AND scesrea    = v_est.scesrea;
                  COMMIT;
                  UPDATE detcesionesrea SET scesrea = w_scesrea WHERE scesrea = 1;
                  COMMIT;
                END;
              END LOOP;
            END;
          ELSE
            BEGIN
              --INICIO (QT23988 + BUG37400): AGG – 18/02/2016
              vpasexec := 11;
              FOR v_est IN cur_est(psseguro)
              LOOP
                BEGIN
                  vpasexec := 12;
                  SELECT scesrea.NEXTVAL INTO w_scesrea FROM DUAL;
                  INSERT
                  INTO cesionesrea
                    (
                      scesrea,
                      ncesion,
                      icesion,
                      icapces,
                      sseguro,
                      nversio,
                      scontra,
                      ctramo,
                      sfacult,
                      nriesgo,
                      icomisi,
                      scumulo,
                      cgarant,
                      spleno,
                      nsinies,
                      fefecto,
                      fvencim,
                      fcontab,
                      pcesion,
                      sproces,
                      cgenera,
                      fgenera,
                      fregula,
                      fanulac,
                      nmovimi,
                      sidepag,
                      ipritarrea,
                      psobreprima,
                      cdetces,
                      ipleno,
                      icapaci,
                      nmovigen,
                      iextrap,
                      iextrea,
                      nreemb,
                      nfact,
                      nlinea,
                      itarifrea,
                      icomext,
                      ctipomov
                    )
                  SELECT w_scesrea,
                    v_est.ncesion,
                    v_est.icesion,
                    v_est.icapces,
                    psseguro,
                    v_est.nversio,
                    v_est.scontra,
                    v_est.ctramo,
                    v_est.sfacult,
                    v_est.nriesgo,
                    v_est.icomisi,
                    v_est.scumulo,
                    v_est.cgarant,
                    v_est.spleno,
                    v_est.nsinies,
                    v_est.fefecto,
                    v_est.fvencim,
                    --INICIO (37400): AGG 02/02/2016
                    v_est.fcontab,
                    pcesion,
                    sproces,
                    v_est.cgenera,
                    v_est.fgenera,
                    v_est.fregula,
                    v_est.fanulac,
                    nmovimi,
                    --FIN (37400): AGG 02/02/2016
                    v_est.sidepag,
                    v_est.ipritarrea,
                    v_est.psobreprima,
                    v_est.cdetces,
                    v_est.ipleno,
                    v_est.icapaci,
                    v_est.nmovigen,
                    v_est.iextrap,
                    v_est.iextrea,
                    v_est.nreemb,
                    v_est.nfact,
                    v_est.nlinea,
                    v_est.itarifrea,
                    v_est.icomext,
                    v_est.ctipomov
                  FROM estcesionesrea
                  WHERE scesrea = v_est.scesrea;
                  p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, 'v_est.scesrea: ' || v_est.scesrea);
                  --FIN (QT23988 + BUG37400): AGG – 18/02/2016
                  DELETE estcesionesrea
                  WHERE (sseguro = psseguro)
                  OR (ssegpol    = psseguro)
                  AND scesrea    = v_est.scesrea;
                  COMMIT;
                END;
              END LOOP;
            END;
          END IF;
          --borro lo que quedara, si es que queda algo
          DELETE estcesionesrea
          WHERE (sseguro = psseguro)
          OR(ssegpol     = psseguro);
        END;
      ELSE
        BEGIN
          --INICIO (QT23988 + BUG37400): AGG – 18/02/2016
          vpasexec   := 14;
          IF (pmotiu  = 4) AND(v_existereg = 0) THEN
            vpasexec := 15;
            INSERT
            INTO estcesionesrea
              (
                scesrea,
                ncesion,
                icesion,
                icapces,
                sseguro,
                ssegpol,
                nversio,
                scontra,
                ctramo,
                sfacult,
                nriesgo,
                icomisi,
                scumulo,
                cgarant,
                spleno,
                nsinies,
                fefecto,
                fvencim,
                fcontab,
                pcesion,
                sproces,
                cgenera,
                fgenera,
                fregula,
                fanulac,
                nmovimi,
                sidepag,
                ipritarrea,
                psobreprima,
                cdetces,
                ipleno,
                icapaci,
                nmovigen,
                iextrap,
                iextrea,
                nreemb,
                nfact,
                nlinea,
                itarifrea,
                icomext,
                npoliza,
                ncertif,
                ctipomov
              )
            SELECT scesrea,
              ncesion,
              icesion,
              icapces,
              NULL,
              cr.sseguro,
              nversio,
              scontra,
              cr.ctramo,
              sfacult,
              nriesgo,
              icomisi,
              scumulo,
              cgarant,
              spleno,
              nsinies,
              cr.fefecto,
              cr.fvencim,
              fcontab,
              pcesion,
              sproces,
              cgenera,
              fgenera,
              fregula,
              cr.fanulac,
              nmovimi,
              sidepag,
              ipritarrea,
              psobreprima,
              cdetces,
              ipleno,
              icapaci,
              nmovigen,
              iextrap,
              iextrea,
              nreemb,
              nfact,
              cr.nlinea,
              itarifrea,
              icomext,
              npoliza,
              ncertif,
              ctipomov
            FROM cesionesrea cr,
              seguros s
            WHERE cr.sseguro = s.sseguro
            AND npoliza      = pnpoliza
            AND ncertif      = pncertif;
            v_mensaje       := pac_cesionesrea.f_buscactrrea_est(psseguro, pnmovimi, psproces, pmotiu, pmoneda, porigen, pfinici, pffin, ptablas);
            vpasexec        := 16;
            p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, 'f_buscactrrea_est mensaje:' || v_mensaje);
            IF v_mensaje <> 0 AND v_mensaje <> 99 THEN
              vpasexec   := 17;
              num_err    := 1;
              ROLLBACK;
              p_tab_error(f_sysdate, f_user, 'f_calcula_cesiones', vpasexec, 'pcempres = ' || v_cempres || ' psseguro = ' || psseguro || ' psproces = ' || psproces || ' pmoneda = ' || pmoneda, f_axis_literales(v_mensaje, 2));
              p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, 'f_buscactrrea_est mensaje:' || v_mensaje);
            ELSIF v_mensaje = 99 THEN
              vpasexec     := 18;
              -- s'atura per facultatiu
              v_mensaje := 0;
              p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, 'v_mensaje:' || v_mensaje);
            ELSE
              vpasexec  := 19;
              v_mensaje := f_cessio_est(psproces, pmotiu, pmoneda, f_sysdate, 0, ptablas);
              p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, 'f_cessio_est mensaje:' || v_mensaje);
              IF v_mensaje <> 0 AND v_mensaje <> 99 THEN
                vpasexec   := 20;
                num_err    := 1;
                ROLLBACK;
                p_tab_error(f_sysdate, f_user, 'f_calcula_cesiones', vpasexec, 'pcempres = ' || v_cempres || ' psseguro = ' || psseguro || ' psproces = ' || psproces || ' pmoneda = ' || pmoneda, f_axis_literales(v_mensaje, 2));
                p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, 'f_cessio_est mensaje:' || v_mensaje);
              ELSIF v_mensaje = 99 THEN
                vpasexec     := 21;
                num_err      := 1;
                /*AGG 28/08/2015
                Si estamos en modo real y no hay facultativo no se puede emitir la póliza y por lo tanto devolvemos un mensaje
                de error donde se indica que no hay facultativo devolviendo el v_mensaje = 105382.
                Sin embargo, cuando estamos trabajando con las tablas ''EST' no se debe devolver este error ya que es en este
                momento donde hay crear el facultativo*/
                IF ptablas   = 'REA' THEN
                  v_mensaje := 105382; --No te facultatiu
                END IF;
                COMMIT;
                p_tab_error(f_sysdate, f_user, 'f_calcula_cesiones', vpasexec, 'pcempres = ' || v_cempres || ' psseguro = ' || psseguro || ' psproces = ' || psproces || ' pmoneda = ' || pmoneda || ' v_mensaje: ' || v_mensaje, f_axis_literales(v_mensaje, 2));
                p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, f_axis_literales(v_mensaje, 2));
                BEGIN
                  vpasexec := 22;
                  /*ojo almudena de momento lo comento*/
                  /* IF lcmotmov <> 298 THEN   -- No es suspensió de pòlissa
                  -- no emet el suplement, queda en proposta
                  UPDATE seguros
                  SET csituac = DECODE(v_pol.csituac, 0, 4, 1, 5, NULL),
                  femisio = v_pol.femisio,
                  fcaranu = v_pol.fcaranu,
                  fcarpro = fcarpro,
                  ccartera = NULL
                  WHERE sseguro = v_pol.sseguro;
                  END IF;
                  COMMIT;*/
                EXCEPTION
                WHEN OTHERS THEN
                  num_err   := 1;
                  v_mensaje := 102361;
                  p_tab_error(f_sysdate, f_user, 'f_calcula_cesiones', vpasexec, 'pcempres = ' || v_cempres || ' psseguro = ' || psseguro || ' psproces = ' || psproces || ' pmoneda = ' || pmoneda, SQLERRM);
                  p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, 'SQLERRM: ' || SQLERRM);
                END;
              ELSE
                vpasexec := 23;
                -- Si és emissio d una pòlissa que es reassegura en
                -- el q.amortització :Cal calcular el detall de cessions
                -- pel periode de la emissió
                IF NVL(porigen, 1) = 2 THEN
                  num_err         := pac_cesionesrea.f_cessio_det_per(psseguro, pfinici, pffin, psproces);
                  p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, 'f_cessio_det_per num_err:' || num_err);
                END IF;
              END IF;
            END IF;
          END IF;
          --estamos en modo EST
          --primero comprobamos que no existan las cesiones en cesionesrea
          SELECT COUNT(1)
          INTO v_existeregest
          FROM estcesionesrea
          WHERE sseguro = psseguro
          OR(npoliza    = pnpoliza
          AND ncertif   = pncertif);
          vpasexec     := 24;
          p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, 'v_existeregest: ' || v_existeregest);
          IF (v_existeregest = 0) THEN
            BEGIN
              vpasexec  := 25;
              v_mensaje := pac_cesionesrea.f_buscactrrea_est(psseguro, pnmovimi, psproces, pmotiu, pmoneda, porigen, pfinici, pffin, ptablas);
              vpasexec  := 7;
              p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, 'f_buscactrrea_est mensaje:' || v_mensaje);
              IF v_mensaje <> 0 AND v_mensaje <> 99 THEN
                vpasexec   := 26;
                num_err    := 1;
                ROLLBACK;
                p_tab_error(f_sysdate, f_user, 'f_calcula_cesiones', vpasexec, 'pcempres = ' || v_cempres || ' psseguro = ' || psseguro || ' psproces = ' || psproces || ' pmoneda = ' || pmoneda, f_axis_literales(v_mensaje, 2));
                p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, f_axis_literales(v_mensaje, 2));
              ELSIF v_mensaje = 99 THEN
                vpasexec     := 27;
                -- s'atura per facultatiu
                v_mensaje := 0;
                p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, 'v_mensaje: ' || v_mensaje);
              ELSE
                vpasexec  := 28;
                v_mensaje := f_cessio_est(psproces, pmotiu, pmoneda, f_sysdate, 0, ptablas);
                p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, 'f_cessio_est mensaje:' || v_mensaje);
                IF v_mensaje <> 0 AND v_mensaje <> 99 THEN
                  vpasexec   := 29;
                  num_err    := 1;
                  ROLLBACK;
                  p_tab_error(f_sysdate, f_user, 'f_calcula_cesiones', vpasexec, 'pcempres = ' || v_cempres || ' psseguro = ' || psseguro || ' psproces = ' || psproces || ' pmoneda = ' || pmoneda, f_axis_literales(v_mensaje, 2));
                  p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, f_axis_literales(v_mensaje, 2));
                ELSIF v_mensaje = 99 THEN
                  vpasexec     := 30;
                  num_err      := 1;
                  /*AGG 28/08/2015
                  Si estamos en modo real y no hay facultativo no se puede emitir la póliza y por lo tanto devolvemos un mensaje
                  de error donde se indica que no hay facultativo devolviendo el v_mensaje = 105382.
                  Sin embargo, cuando estamos trabajando con las tablas ''EST' no se debe devolver este error ya que es en este
                  momento donde hay crear el facultativo*/
                  IF ptablas   = 'REA' THEN
                    v_mensaje := 105382; --No te facultatiu
                  END IF;
                  p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, 'v_mensaje: ' || v_mensaje);
                  COMMIT;
                  p_tab_error(f_sysdate, f_user, 'f_calcula_cesiones', vpasexec, 'pcempres = ' || v_cempres || ' psseguro = ' || psseguro || ' psproces = ' || psproces || ' pmoneda = ' || pmoneda || ' v_mensaje: ' || v_mensaje, f_axis_literales(v_mensaje, 2));
                  BEGIN
                    vpasexec := 31;
                    /*ojo almudena de momento lo comento*/
                    /* IF lcmotmov <> 298 THEN   -- No es suspensió de pòlissa
                    -- no emet el suplement, queda en proposta
                    UPDATE seguros
                    SET csituac = DECODE(v_pol.csituac, 0, 4, 1, 5, NULL),
                    femisio = v_pol.femisio,
                    fcaranu = v_pol.fcaranu,
                    fcarpro = fcarpro,
                    ccartera = NULL
                    WHERE sseguro = v_pol.sseguro;
                    END IF;
                    COMMIT;*/
                  EXCEPTION
                  WHEN OTHERS THEN
                    num_err   := 1;
                    v_mensaje := 102361;
                    p_tab_error(f_sysdate, f_user, 'f_calcula_cesiones', vpasexec, 'pcempres = ' || v_cempres || ' psseguro = ' || psseguro || ' psproces = ' || psproces || ' pmoneda = ' || pmoneda, SQLERRM);
                    p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, 'SQLERRM: ' || SQLERRM);
                  END;
                ELSE
                  vpasexec := 32;
                  -- Si és emissio d una pòlissa que es reassegura en
                  -- el q.amortització :Cal calcular el detall de cessions
                  -- pel periode de la emissió
                  IF NVL(porigen, 1) = 2 THEN
                    num_err         := pac_cesionesrea.f_cessio_det_per(psseguro, pfinici, pffin, psproces);
                    p_traza_proceso(v_cempres, vpar_traza, psproces, v_paquete, v_funcion, NULL, vpasexec, 'f_cessio_det_per num_err:' || num_err);
                  END IF;
                END IF;
              END IF;
            END;
          END IF;
          COMMIT;
        END;
      END IF;
    END;
  END IF;
  RETURN v_mensaje;
END f_calcula_cesiones;

PROCEDURE traspaso_inf_cesionesreatoest(
    pcempres IN NUMBER,
    psseguro IN NUMBER,
    pcidioma IN NUMBER,
    psproces IN NUMBER,
    pmoneda  IN NUMBER,
    pcgenera IN NUMBER,
    pnsinies IN NUMBER DEFAULT -1)
IS
  v_nsproces NUMBER;
  v_nnumerr  NUMBER;
  vnnumlin   NUMBER;
  v_nmovigen NUMBER;
BEGIN
  BEGIN
    --1. Pasamos los datos a la tabla ESTCESIONESREA
    IF pnsinies IS NULL THEN
      INSERT
      INTO estcesionesrea
        (
          scesrea,
          ncesion,
          icesion,
          icapces,
          sseguro,
          ssegpol,
          nversio,
          scontra,
          ctramo,
          sfacult,
          nriesgo,
          icomisi,
          scumulo,
          cgarant,
          spleno,
          nsinies,
          fefecto,
          fvencim,
          fcontab,
          pcesion,
          sproces,
          cgenera,
          fgenera,
          fregula,
          fanulac,
          nmovimi,
          sidepag,
          ipritarrea,
          psobreprima,
          cdetces,
          ipleno,
          icapaci,
          nmovigen,
          iextrap,
          iextrea,
          nreemb,
          nfact,
          nlinea,
          itarifrea,
          icomext,
          ctrampa,--BUG CONF-695  Fecha (22/05/2017) - HRE
          ctipomov
        )
      SELECT scesrea,
        ncesion,
        icesion,
        icapces,
        NULL,
        sseguro,
        nversio,
        scontra,
        ctramo,
        sfacult,
        nriesgo,
        icomisi,
        scumulo,
        cgarant,
        spleno,
        nsinies,
        fefecto,
        fvencim,
        fcontab,
        pcesion,
        sproces,
        cgenera,
        fgenera,
        fregula,
        fanulac,
        nmovimi,
        sidepag,
        ipritarrea,
        psobreprima,
        cdetces,
        ipleno,
        icapaci,
        nmovigen,
        iextrap,
        iextrea,
        nreemb,
        nfact,
        nlinea,
        itarifrea,
        icomext,
        ctrampa,--BUG CONF-695  Fecha (22/05/2017) - HRE
        ctipomov
      FROM cesionesrea
      WHERE sseguro = psseguro
      AND cgenera   = pcgenera
      AND nsinies  IS NULL;
    ELSE
      INSERT
      INTO estcesionesrea
        (
          scesrea,
          ncesion,
          icesion,
          icapces,
          sseguro,
          ssegpol,
          nversio,
          scontra,
          ctramo,
          sfacult,
          nriesgo,
          icomisi,
          scumulo,
          cgarant,
          spleno,
          nsinies,
          fefecto,
          fvencim,
          fcontab,
          pcesion,
          sproces,
          cgenera,
          fgenera,
          fregula,
          fanulac,
          nmovimi,
          sidepag,
          ipritarrea,
          psobreprima,
          cdetces,
          ipleno,
          icapaci,
          nmovigen,
          iextrap,
          iextrea,
          nreemb,
          nfact,
          nlinea,
          itarifrea,
          icomext,
          ctipomov
        )
      SELECT scesrea,
        ncesion,
        icesion,
        icapces,
        NULL,
        sseguro,
        nversio,
        scontra,
        ctramo,
        sfacult,
        nriesgo,
        icomisi,
        scumulo,
        cgarant,
        spleno,
        nsinies,
        fefecto,
        fvencim,
        fcontab,
        pcesion,
        sproces,
        cgenera,
        fgenera,
        fregula,
        fanulac,
        nmovimi,
        sidepag,
        ipritarrea,
        psobreprima,
        cdetces,
        ipleno,
        icapaci,
        nmovigen,
        iextrap,
        iextrea,
        nreemb,
        nfact,
        nlinea,
        itarifrea,
        icomext,
        ctipomov
      FROM cesionesrea
      WHERE nsinies = pnsinies
      AND cgenera   = pcgenera;
    END IF;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v_nnumerr := f_proceslin(v_nsproces, f_axis_literales(9908417, pcidioma), 1, vnnumlin);
  WHEN OTHERS THEN
    v_nnumerr := f_proceslin(v_nsproces, f_axis_literales(9908417, pcidioma), 1, vnnumlin);
  END;
  BEGIN
    INSERT
    INTO his_seguros
      (
        sseguro,
        cmodali,
        ccolect,
        ctipseg,
        casegur,
        cagente,
        cramo,
        npoliza,
        ncertif,
        nsuplem,
        fefecto,
        creafac,
        ctarman,
        ctipreb,
        cactivi,
        ctiprea,
        csituac,
        creteni,
        cempres,
        cagrpro
      )
    SELECT sseguro,
      cmodali,
      ccolect,
      ctipseg,
      casegur,
      cagente,
      cramo,
      npoliza,
      ncertif,
      nsuplem,
      fefecto,
      creafac,
      ctarman,
      ctipreb,
      cactivi,
      ctiprea,
      csituac,
      creteni,
      cempres,
      cagrpro
    FROM seguros
    WHERE sseguro = psseguro;
    --Bloqueamos la póliza
    UPDATE seguros
    SET csituac   = 5,
      creteni     = 2
    WHERE sseguro = psseguro;
  EXCEPTION
  WHEN OTHERS THEN
    v_nnumerr := f_proceslin(v_nsproces, f_axis_literales(9908418, pcidioma), 1, vnnumlin);
  END;
  COMMIT;
END traspaso_inf_cesionesreatoest;

PROCEDURE traspaso_inf_esttocesionesrea(
    pcempres IN NUMBER,
    psseguro IN NUMBER,
    pcidioma IN NUMBER,
    psproces IN NUMBER,
    pmoneda  IN NUMBER,
    pmensaje OUT VARCHAR2) --CONF-1082
IS
  v_csituac      NUMBER;
  v_creteni      NUMBER;
  v_nsproces     NUMBER;
  v_nnumerr      NUMBER;
  vnnumlin       NUMBER;
  v_nmovigen     NUMBER;
  v_scesrea      NUMBER;
  v_cuantos      NUMBER := 0;
  v_existecesrea NUMBER := 0;
  vpasexec       NUMBER;

  -- INICIO (QT 24893 + Bug 41045) AGG 29/03/2016
  v_nrecibo  NUMBER;
  v_error  NUMBER;
  v_numrecanul NUMBER := 0;
  v_cactivi  NUMBER;
  v_cramo NUMBER;
  v_cmodali NUMBER;
  v_ctipseg NUMBER;
  v_ccolect NUMBER;
  v_sproduc NUMBER;
  v_fecvencim DATE;
  -- FIN (QT 24893 + Bug 41045) AGG 29/03/2016
  --INI BUG CONF-695  Fecha (22/05/2017) - HRE - Redistribucion reaseguro
  v_crea_reasemi NUMBER(1) := 0;
  lrea   reasegemi%ROWTYPE;
  lsreaemi NUMBER;
  --FIN BUG CONF-695  - Fecha (22/05/2017) - HRE
  v_cambiofac NUMBER; --CONF-1082
  vterror    VARCHAR2(1000);

  CURSOR ces_est(psseguro IN NUMBER)
  IS
    SELECT *
    FROM estcesionesrea
    WHERE ssegpol = psseguro
    ORDER BY scesrea,
      nriesgo;
  CURSOR cesion(psseguro IN NUMBER, pscesrea IN NUMBER)
  IS
    SELECT *
    FROM cesionesrea
    WHERE sseguro = psseguro
    AND scesrea   = pscesrea
    ORDER BY scesrea,
      nriesgo;

  -- INICIO (QT 24893 + Bug 41045) AGG 29/03/2016
  CURSOR ces_recibos (psseguro IN NUMBER) IS
  /*SELECT * FROM CESIONESREA WHERE SSEGURO = psseguro AND cgenera = 4
  AND cdetces = 1 AND fcontab IS NULL AND fanulac IS NULL;*/
  SELECT * FROM reasegemi WHERE sseguro = psseguro AND cmotces =6;
  -- FIN (QT 24893 + Bug 41045) AGG 29/03/2016
BEGIN
  --1. Iniciamos el proceso
  v_nnumerr := f_procesini(f_user, pcempres, 'CESIONES_MANUALES', 'Cesiones Manuales de Reaseguro', v_nsproces);
  SELECT COUNT(*) INTO v_cuantos FROM estcesionesrea WHERE ssegpol = psseguro;
  vpasexec := 1;
  --
  --CONF-1082
  --Revisa si cambió el porcentaje/valor del facultativo
  BEGIN
    SELECT DISTINCT e.sfacult
      INTO v_cambiofac
      FROM estcesionesrea e
     WHERE e.ssegpol = psseguro
       AND e.ctramo = 5
       AND e.sfacult IS NOT NULL;
  EXCEPTION WHEN OTHERS THEN
    v_cambiofac := -1;
  END;

  IF v_cambiofac > 0 THEN
    vterror := f_axis_literales(89906010,
                                pac_md_common.f_get_cxtidioma);

    vterror := REPLACE(vterror, '#1#', v_cambiofac);
    pmensaje := vterror;
  END IF;


  --CONF-1082
  --
  --2. Realizamos las comprobaciones pertinentes
  --INI - AXIS 4105 - 05/06/2019 - AABG - SE OBTIENE EL SIGUIENTE MOVIMIENTO
   BEGIN
            SELECT NVL(MAX(nmovigen), 0) + 1
            INTO v_nmovigen
            FROM cesionesrea
            WHERE sseguro = psseguro;
          EXCEPTION
          WHEN OTHERS THEN
            v_nmovigen := 1;
          END;
  --FIN - AXIS 4105 - 05/06/2019 - AABG - SE OBTIENE EL SIGUIENTE MOVIMIENTO          
  FOR ces IN ces_est(psseguro)
  LOOP
    FOR v IN cesion(psseguro, ces.scesrea)
    LOOP
      --Comprobamos si han cambiado algun dato que no sean las fechas
      IF ((ces.icesion <> v.icesion) OR(ces.pcesion <> v.pcesion) OR(ces.icapces <> v.icapces)) AND((ces.fefecto = v.fefecto) AND(ces.fvencim = v.fvencim)) THEN
        BEGIN

          IF v_nnumerr <> 0 THEN
            v_nnumerr  := f_proceslin(v_nsproces, 'No han cambiado fechas. ' || f_axis_literales(9908421, pcidioma), 1, vnnumlin);
          END IF;
          BEGIN
            /*SELECT scesrea.NEXTVAL INTO v_scesrea FROM DUAL;
            --INI - AXIS 4105 - 05/06/2019 - AABG - SE INSERTA EL MOVIMIENTO
            INSERT
            INTO cesionesrea
              (
                scesrea,
                ncesion,
                icesion,
                icapces,
                sseguro,
                nversio,
                scontra,
                ctramo,
                sfacult,
                nriesgo,
                icomisi,
                scumulo,
                cgarant,
                spleno,
                nsinies,
                fefecto,
                fvencim,
                fcontab,
                pcesion,
                sproces,
                cgenera,
                fgenera,
                fregula,
                fanulac,
                nmovimi,
                sidepag,
                ipritarrea,
                psobreprima,
                cdetces,
                ipleno,
                icapaci,
                nmovigen,
                iextrap,
                iextrea,
                nreemb,
                nfact,
                nlinea,
                itarifrea,
                icomext,
                ctrampa,--BUG CONF-695  Fecha (22/05/2017) - HRE
                ctipomov
              )
            SELECT v_scesrea,
              ncesion,
              -icesion,
              --INICIO (28172 - LCOL-232): AGG 12/09/2016
              --icapces,
              icapces,
              sseguro,
              nversio,
              scontra,
              ctramo,
              sfacult,
              nriesgo,
              icomisi,
              scumulo,
              cgarant,
              spleno,
              nsinies,
              --INICIO (27133 - LCOL-172): AGG 25/08/2016
              --INICIO (24893 - LCOL-52): DCT 15/06/2016
              fefecto,
              --FIN (24893 - LCOL-52): DCT 15/06/2016
              --FIN (27133 - LCOL-172): AGG 25/08/2016
              fvencim,
               --fcontab,
              null,
              pcesion,
              v_nsproces,
              7,
              --INICIO (24893 - LCOL-52): DCT 15/06/2016
              --fgenera,
              f_sysdate,
              --FIN (24893 - LCOL-52): DCT 15/06/2016
              fregula,
              fanulac,
              v_nmovigen,
              sidepag,
              -ipritarrea,
              psobreprima,
              cdetces,
              ipleno,
              icapaci,
              v_nmovigen,
              -iextrap,
              -iextrea,
              nreemb,
              nfact,
              nlinea,
              itarifrea,
              icomext,
              ctrampa,--BUG CONF-695  Fecha (22/05/2017) - HRE
              --ctipomov
              'M'
              --FIN (28172 - LCOL-232): AGG 12/09/2016
            FROM cesionesrea
            WHERE sseguro = psseguro
            AND scesrea   = ces.scesrea;*/
           --FIN - AXIS 4105 - 05/06/2019 - AABG - SE INSERTA EL MOVIMIENTO

            -- INICIO (QT 24893 + Bug 41045) AGG 29/03/2016
            IF ces.cdetces  = 1 THEN
            BEGIN
                SELECT  nrecibo  INTO v_nrecibo FROM reasegemi
                WHERE sseguro = psseguro AND sreaemi =
                   (SELECT MAX(sreaemi) FROM reasegemi WHERE sseguro  = psseguro);
                --Primero  comprobamos que no se haya realizado la anulación del recibo
                --en reasegemi
                SELECT COUNT(1) INTO v_numrecanul FROM reasegemi WHERE nrecibo = v_nrecibo
                --AND cmotces = 6;
                AND cmotces = 4;--BUG CONF-695  Fecha (22/05/2017) - HRE
                IF v_numrecanul = 0 THEN
                   v_error := pac_cesionesrea.f_cesdet_anu(v_nrecibo, 1);
                END IF;
           END;
           END IF;
           -- FIN (QT 24893 + Bug 41045) AGG 29/03/2016



            UPDATE cesionesrea SET fanulac = f_sysdate WHERE scesrea = v.scesrea;
            SELECT scesrea.NEXTVAL INTO v_scesrea FROM DUAL;
            --INI - AXIS 4105 - 05/06/2019 - AABG - SE INSERTA EL MOVIMIENTO
            INSERT
            INTO cesionesrea
              (
                scesrea,
                ncesion,
                icesion,
                icapces,
                sseguro,
                nversio,
                scontra,
                ctramo,
                sfacult,
                nriesgo,
                icomisi,
                scumulo,
                cgarant,
                spleno,
                nsinies,
                fefecto,
                fvencim,
                fcontab,
                pcesion,
                sproces,
                cgenera,
                fgenera,
                fregula,
                fanulac,
                nmovimi,
                sidepag,
                ipritarrea,
                psobreprima,
                cdetces,
                ipleno,
                icapaci,
                nmovigen,
                iextrap,
                iextrea,
                nreemb,
                nfact,
                nlinea,
                itarifrea,
                icomext,
                ctrampa,--BUG CONF-695  Fecha (22/05/2017) - HRE
                ctipomov
              )
            SELECT v_scesrea,
              ncesion,
              icesion,
              icapces,
              ssegpol,
              nversio,
              scontra,
              ctramo,
              sfacult,
              nriesgo,
              icomisi,
              scumulo,
              cgarant,
              spleno,
              nsinies,
              --INICIO (27133 - LCOL-172): AGG 25/08/2016
              --INICIO (24893 - LCOL-52): DCT 15/06/2016
              fefecto,
              --FIN (24893 - LCOL-52): DCT 15/06/2016
              --FIN (27133 - LCOL-172): AGG 25/08/2016
              fvencim,
              --INICIO (28172 - LCOL-232): AGG 12/09/2016
              --fcontab,
              null,
              --FIN (28172 - LCOL-232): AGG 12/09/2016
              pcesion,
              v_nsproces,
              4,
              --INICIO (24893 - LCOL-52): DCT 15/06/2016
              --fgenera,
              f_sysdate,
              --FIN (24893 - LCOL-52): DCT 15/06/2016
              fregula,
              NULL,
              v_nmovigen,
              sidepag,
              ipritarrea,
              psobreprima,
              cdetces,
              ipleno,
              icapaci,
              v_nmovigen,
              iextrap,
              iextrea,
              nreemb,
              nfact,
              nlinea,
              itarifrea,
              icomext,
              ctrampa,--BUG CONF-695  Fecha (22/05/2017) - HRE
              --INICIO (21901 - LCOL-87): AGG 09/09/2016
              --ctipomov
              'M'
              --FIN (21901 - LCOL-87): AGG 09/09/2016
            FROM estcesionesrea
            WHERE ssegpol = psseguro
            AND scesrea   = ces.scesrea
            AND icapces != 0;--BUG CONF-695  Fecha (22/05/2017) - HRE
            --FIN - AXIS 4105 - 05/06/2019 - AABG - SE INSERTA EL MOVIMIENTO

            --INI BUG CONF-695  Fecha (22/05/2017) - HRE - Redistribucion reaseguro
            IF (v_crea_reasemi = 0) THEN

            BEGIN

          SELECT    *
               INTO lrea
               FROM reasegemi
              WHERE nrecibo = v_nrecibo
               AND cmotces  = 1 --emissió
               AND NOT EXISTS
               (SELECT    sreaemi
                     FROM reasegemi
                    WHERE nrecibo = v_nrecibo
                     AND cmotces  = 2
               )
               AND sreaemi =
               (SELECT    MAX(sreaemi)
                     FROM reasegemi
                    WHERE nrecibo = v_nrecibo
                     AND cmotces  = 1
               );
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        null; --rea03
        --p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
      WHEN OTHERS THEN
         null;--rea03
         --p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
      END;
      -- Insertem la nova cessió per l'anul.lació amb els imports en negatiu
      BEGIN
          SELECT    sreaemi.NEXTVAL
               INTO lsreaemi
               FROM DUAL;

         -- Añadimos nriesgo a reasegemi
          INSERT
               INTO reasegemi
               (
                  sreaemi, sseguro, nrecibo, nfactor, fefecte, fvencim, fgenera, cmotces, sproces
               )
               VALUES
               (
                  lsreaemi, lrea.sseguro, lrea.nrecibo, lrea.nfactor, lrea.fefecte, lrea.fvencim, lrea.fefecte/*TRUNC(f_sysdate)*/, 1
                  --v_cmotces
                  , lrea.sproces
               ); -- cmotces =2 - Anul·lació, 4. regularització

      EXCEPTION
      WHEN OTHERS THEN
         null;
         --p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' r=' || lsreaemi || ' s=' || lrea.sseguro || ' r=' || lrea.nrecibo);
      END;
         v_crea_reasemi := 1;
      END IF;

           IF (ces.icesion > 0 ) THEN
           INSERT
               INTO detreasegemi
               (
                  sreaemi, cgarant, icesion, scontra, nversio, ctramo, ipritarrea, idtosel, psobreprima, nriesgo,
                  pcesion, sfacult, icapces, scesrea, iextrap, iextrea,
                  -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
                  itarifrea
               )
               VALUES(lsreaemi,

               NVL(ces.cgarant, 0), ces.icesion, ces.scontra, ces.nversio, ces.ctramo, ces.ipritarrea, 0,
               --ces.idtosel,
               ces.psobreprima, ces.nriesgo,
                  ces.pcesion, ces.sfacult, ces.icapces, ces.scesrea, ces.iextrap, ces.iextrea,
                  ces.itarifrea);

             END IF;

            --FIN BUG CONF-695  - Fecha (22/05/2017) - HRE
            DELETE estcesionesrea WHERE ssegpol = psseguro AND scesrea = ces.scesrea;
            --INI - AXIS 4105 - 31/5/2019 - AABG - SE INSERTA HISTORIAL DE CESIONESREA
            BEGIN
                INSERT INTO HIS_CESIONESREA(scesrea, sseguro, cusualt, fmodif) VALUES(ces.scesrea, psseguro, f_user, f_sysdate);
            EXCEPTION
            WHEN OTHERS THEN
                p_tab_error(f_sysdate, f_user, 'pac_cesionesrea.traspaso_inf_esttocesionesrea', vpasexec, 'Error insercion de historico', SQLERRM);
            END;
            --FIN - AXIS 4105 - 31/5/2019 - AABG - SE INSERTA HISTORIAL DE CESIONESREA
            COMMIT;
          EXCEPTION
          WHEN OTHERS THEN
            v_nnumerr := f_proceslin(v_nsproces, 'No han cambiado fechas. ' || f_axis_literales(9908419, pcidioma), 1, vnnumlin);
          END;
          COMMIT;
        END;
      ELSIF (ces.icesion <> v.icesion) OR(ces.pcesion <> v.pcesion) OR(ces.icapces <> v.icapces) OR(ces.fefecto <> v.fefecto) OR(ces.fvencim <> v.fvencim) THEN --si han cambiado fechas
        BEGIN
          BEGIN
            SELECT NVL(MAX(nmovigen), 0) + 1
            INTO v_nmovigen
            FROM cesionesrea
            WHERE sseguro = psseguro;
          EXCEPTION
          WHEN OTHERS THEN
            v_nmovigen := 1;
          END;
          v_nnumerr    := f_atras(v_nsproces, psseguro, ces.fefecto, 7, pmoneda, v_nmovigen);
          IF v_nnumerr <> 0 THEN
            v_nnumerr  := f_proceslin(v_nsproces, 'Han cambiado fechas. ' || f_axis_literales(9908421, pcidioma), 1, vnnumlin);
          END IF;
          v_nnumerr    := pac_cesionesrea.f_calcula_cesiones(psseguro, ces.nmovimi, v_nsproces, 4, pmoneda, -1, -1, 3, ces.fefecto, ces.fvencim, 'REA');
          IF v_nnumerr <> 0 THEN
            v_nnumerr  := f_proceslin(v_nsproces, 'Han cambiado fechas. ' || f_axis_literales(9908422, pcidioma), 1, vnnumlin);
          END IF;
        --DELETE estcesionesrea WHERE ssegpol = psseguro AND scesrea = ces.scesrea;
        END;
     -- ELSE
        -- DELETE estcesionesrea WHERE ssegpol = psseguro AND scesrea = ces.scesrea;
        v_nnumerr := 0;
        COMMIT;
      END IF;
    END LOOP;
  END LOOP;
  vpasexec := 2;
  --Añadimos las cesiones nuevas
  --IAXIS - 4773 FEPP 22/08/2019
  FOR ces IN ces_est(psseguro)
  LOOP  
    BEGIN
    SELECT scesrea.NEXTVAL INTO v_scesrea FROM DUAL;
      INSERT
      INTO cesionesrea
        (
          scesrea,
          ncesion,
          icesion,
          icapces,
          sseguro,
          nversio,
          scontra,
          ctramo,
          sfacult,
          nriesgo,
          icomisi,
          scumulo,
          cgarant,
          spleno,
          nsinies,
          fefecto,
          fvencim,
          fcontab,
          pcesion,
          sproces,
          cgenera,
          fgenera,
          fregula,
          fanulac,
          nmovimi,
          sidepag,
          ipritarrea,
          psobreprima,
          cdetces,
          ipleno,
          icapaci,
          nmovigen,
          iextrap,
          iextrea,
          nreemb,
          nfact,
          nlinea,
          itarifrea,
          icomext,
          ctrampa,--BUG CONF-695  Fecha (22/05/2017) - HRE
          ctipomov
        )
      SELECT v_scesrea,
        ncesion,
        icesion,
        icapces,
        ssegpol,
        nversio,
        scontra,
        ctramo,
        sfacult,
        nriesgo,
        icomisi,
        scumulo,
        cgarant,
        spleno,
        nsinies,
        --INICIO (27133 - LCOL-172): AGG 25/08/2016
        --INICIO (24893 - LCOL-52): DCT 15/06/2016
        fefecto,
        --FIN (24893 - LCOL-52): DCT 15/06/2016
        --FIN (27133 - LCOL-172): AGG 25/08/2016
        fvencim,
        --INICIO (28172 - LCOL-232): AGG 12/09/2016
        --fcontab,
        null,
        pcesion,
        v_nsproces,
        4,
        --INICIO (24893 - LCOL-52): DCT 15/06/2016
        --fgenera,
        f_sysdate,
        --FIN (24893 - LCOL-52): DCT 15/06/2016
        fregula,
        fanulac,
        v_nmovigen,
        sidepag,
        ipritarrea,
        psobreprima,
        cdetces,
        ipleno,
        icapaci,
        v_nmovigen,
        iextrap,
        iextrea,
        nreemb,
        nfact,
        nlinea,
        itarifrea,
        icomext,
        ctrampa,--BUG CONF-695  Fecha (22/05/2017) - HRE
        --ctipomov
        'M'
        --FIN (28172 - LCOL-232): AGG 12/09/2016
      FROM estcesionesrea
      WHERE ssegpol = psseguro
      AND scesrea   = ces.scesrea;
      DELETE estcesionesrea WHERE ssegpol = psseguro AND scesrea = ces.scesrea;
      COMMIT;
    END;
  END LOOP;
  vpasexec := 3;
  --INICIO (28599 - LCOL-255): AGG 07/10/2016
  begin
  SELECT csituac,
    creteni
  INTO v_csituac,
    v_creteni
  FROM his_seguros
  WHERE sseguro = psseguro;
  exception
    when no_data_found then
      v_csituac := 0;
      v_creteni := 0;
    when others then
      v_csituac := 0;
      v_creteni := 0;
  end;
  --FIN (28599 - LCOL-255): AGG 07/10/2016
  --Desbloqueamos la póliza
  vpasexec := 4;
  UPDATE seguros
  SET csituac   = v_csituac,
    creteni     = v_creteni
  WHERE sseguro = psseguro;
  vpasexec     := 5;
  DELETE his_seguros WHERE sseguro = psseguro;
  COMMIT;


  -- INICIO (QT 24893 + Bug 41045) AGG 29/03/2016
   BEGIN
SELECT cactivi,cramo,cmodali,ctipseg,ccolect,sproduc
INTO v_cactivi,v_cramo, v_cmodali,v_ctipseg,v_ccolect, v_sproduc
FROM seguros WHERE sseguro = psseguro;
EXCEPTION
         WHEN  no_data_found THEN
           v_cactivi := -1;
           v_cramo :=-1;
          v_cmodali :=-1;
          v_ctipseg:=-1;
          v_ccolect :=-1;
          v_sproduc:=-1;
          END;
          BEGIN
          SELECT  nrecibo, fvencim
          INTO v_nrecibo, v_fecvencim
          FROM REASEGEMI WHERE SSEGURO = psseguro AND cmotces =6;
        EXCEPTION
        WHEN  no_data_found THEN
        v_nrecibo :=-1;
                      v_fecvencim:=NULL;
                      END;


        FOR rec IN ces_recibos(psseguro) LOOP
        v_nnumerr := f_cessio_det(psproces, psseguro,v_nrecibo, v_cactivi,v_cramo,v_cmodali, v_ctipseg,v_ccolect , f_sysdate,v_fecvencim,NULL, pac_monedas.f_moneda_producto(v_sproduc),5);
        END LOOP;
  -- FIN (QT 24893 + Bug 41045) AGG 29/03/2016

EXCEPTION
WHEN OTHERS THEN
  --dbms_output.put_line('***** band ozea10');
  p_tab_error(f_sysdate, f_user, 'pac_cesionesrea.traspaso_inf_esttocesionesrea', vpasexec, 'Error incontrolado', SQLERRM);
END traspaso_inf_esttocesionesrea;


  FUNCTION f_cesdet_anu
    (
      pnrecibo IN NUMBER,
      -- INICIO (QT 24893 + Bug 41045) AGG 29/03/2016
      pcesmanual IN NUMBER
      -- FIN (QT 24893 + Bug 41045) AGG 29/03/2016
     )
    RETURN NUMBER
  IS
    -------------------------------------------------------------------------------
    -- ini Bug 0012020 - 17/11/2009 - JMF
    v_errfun VARCHAR2(100) := 'PAC_CESIONESREA.F_CESDET_ANU';
    v_errlin NUMBER        := 0;
    v_errpar VARCHAR2(500) := '(r=' || pnrecibo || ')';
    -- fin Bug 0012020 - 17/11/2009 - JMF
    lrea reasegemi%ROWTYPE;
    lsreaemi  NUMBER;
    num_err   NUMBER;
    nprolin   NUMBER;
    v_cmotces NUMBER; -- 14536 AVT 21-06-2010
  BEGIN
    BEGIN
      -- Busquem l'emissió per fer l'apunt en negatiu
      v_errlin := 5150;
      SELECT *
      INTO lrea
      FROM reasegemi
      WHERE nrecibo = pnrecibo
      AND cmotces   = 1 --emissió
        -- BUG 17106 - 27/12/2010 - JMP - Se vuelven a dejar las condiciones tal como estaban anteriormente
        --AND f_cestrec(nrecibo, fefecte) < 2   -- 14871 AVT 16-09-2010
      AND NOT EXISTS
        (SELECT sreaemi FROM reasegemi WHERE nrecibo = pnrecibo AND cmotces = 2
        )
      AND sreaemi =
        (SELECT MAX(sreaemi) FROM reasegemi WHERE nrecibo = pnrecibo AND cmotces = 1
        );
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0; -- Si no hi ha cessió no fem rès
    WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar);
      RETURN 151161;
    END;
    -- 14536 AVT 21-06-2010 el CMOTCES dependrà de l'estat del rebut
    -- BUG 17106 - 27/12/2010 - JMP - El CMOTCES se calcula según estado a la fecha del día

    -- INICIO (QT 24893 + Bug 41045) AGG 29/03/2016
    IF pcesmanual = 1 THEN
       v_cmotces := 6;
    ELSE
    BEGIN
    IF f_cestrec(pnrecibo, TRUNC(f_sysdate)) < 2 THEN
      v_cmotces                             := 4;
    ELSE
      v_cmotces := 2;
    END IF;
    END;
    END IF;
    -- FIN (QT 24893 + Bug 41045) AGG 29/03/2016

    -- 14536 AVT fi
    -- Insertem la nova cessió per l'anul.lació amb els imports en negatiu
    BEGIN
      v_errlin := 5160;
      SELECT sreaemi.NEXTVAL INTO lsreaemi FROM DUAL;
      v_errlin := 5165;
      -- Bug 12178 - RSC - 30/11/2009 - CRE201 - error en emisión en pólizas colectivas de salud.
      -- Añadimos nriesgo a reasegemi
      INSERT
      INTO reasegemi
        (
          sreaemi,
          sseguro,
          nrecibo,
          nfactor,
          fefecte,
          fvencim,
          fgenera,
          cmotces,
          sproces
        )
        VALUES
        (
          lsreaemi,
          lrea.sseguro,
          lrea.nrecibo,
          lrea.nfactor,
          lrea.fefecte,
          lrea.fvencim,
          TRUNC(f_sysdate),
          v_cmotces,
          lrea.sproces
        ); -- cmotces =2 - Anul·lació, 4. regularització
      -- Fin Bug 12178
    EXCEPTION
    WHEN OTHERS THEN
      -->-- -- dbms_output.put_line(' 3' ||SQLERRM);
      num_err := f_proceslin(lrea.sproces, SQLERRM, lrea.sseguro, nprolin);
      p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' r=' || lsreaemi || ' s=' || lrea.sseguro || ' r=' || lrea.nrecibo);
      RETURN 151144;
    END;
    -- Insertem el detall
    BEGIN
      v_errlin := 5170;
      INSERT
      INTO detreasegemi
        (
          sreaemi,
          cgarant,
          icesion,
          scontra,
          nversio,
          ctramo,
          ipritarrea,
          idtosel,
          psobreprima,
          nriesgo,
          pcesion,
          sfacult,
          icapces,
          scesrea,
          iextrap,
          iextrea,
          -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
          itarifrea
        )
      -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
      SELECT lsreaemi,
        cgarant,
        -icesion,
        scontra,
        nversio,
        ctramo,
        -ipritarrea,
        -idtosel,
        psobreprima,
        nriesgo,
        pcesion,
        sfacult,
        icapces,
        scesrea,
        iextrap,
        -iextrea,
        -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Inicio
        itarifrea
        -- 47.0 - 29/11/2013 - MMM - 0028082 LCOL_A004-0008810 CLF2-4054 LISTADOS DE PRIMAS CEDIDAS VIDA PROPORCIONAL - Fin
      FROM detreasegemi
      WHERE sreaemi = lrea.sreaemi;
    EXCEPTION
    WHEN OTHERS THEN
      -->-- -- dbms_output.put_line(SQLERRM);
      p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' r=' || lrea.sreaemi);
      RETURN 151143;
    END;
    RETURN 0;
  END f_cesdet_anu;

--ERHF

END pac_cesionesrea;

/

  GRANT EXECUTE ON "AXIS"."PAC_CESIONESREA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CESIONESREA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CESIONESREA" TO "PROGRAMADORESCSI";
