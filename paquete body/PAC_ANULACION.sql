/* Formatted on 2019/05/13 15:25 (Formatter Plus v4.8.8) */
--------------------------------------------------------
--  DDL for Package Body PAC_ANULACION
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY pac_anulacion
IS
      /******************************************************************************
         NOMBRE:       PAC_ANULACION
         PROP¿SITO: Funciones para anular
         REVISIONES:
         Ver        Fecha        Autor             Descripci¿n
         ---------  ----------  ---------------  ------------------------------------
         1.0        19/12/2007  JAS              1. Creaci¿n del package.
         1.1        01/06/2007  MSR              2. Afegir funci¿ F_VALIDA_PERMITE_ANULAR_POLIZA
         1.2        01/06/2007  MSR              3. Modificar funci¿ F_ANULACION_POLIZA
         1.3        02/03/2009  DCM              4. Modificaciones Bug 8850
         2.0        14/05/2009  APD              5. Bug 9639: se crea la funcion f_esta_prog_anulproxcar
         2.1        15/05/2009  APD              6. Bug 9685 - en lugar de coger la actividad de la tabla seguros, llamar a la
                                                    funci¿n pac_seguros.ff_get_actividad
         2.2        05/06/2009  ICV              7. 0010354: CRE - Incidencia baja a la pr¿xima cartera
         2.3        19/05/2009  JTS              8. Bug 9914 - ANULACI¿N DE P¿LIZA - Baja inmediata
         3.0        23/06/2009  DRA              9. 0010503: CRE - Anulacions dels productes d'estalvi
         4.0        01/06/2009  NMM              10.Mantis 10344.CRE - Cesiones a reaseguro incorrectas.i.
         5.0        28/07/2009  XVM              11.Mantis 0009028: Recibos temporales para tarificaci¿n
         6.0        28/07/2009  JRH              12.Mantis 0011400: CRE - Proceso autom¿tico de vencimiento de p¿lizas.
         7.0        20/11/2009  RSC              13. 0012166: CRE - Ajuste en anulaci¿n al vto para productos de inversi¿n
         8.0        30/10/2009  JMF              14.0011652 CRE - Generaci¿n de extornos incorrecta en el caso de p¿lizas con copago
         9.0        02/11/2009  JMF              15.0011653 CRE - Anulaci¿n de recibos de colectivos
        10.0        27/05/2009  RSC              16.0007926 APR - Fecha de vencimiento a nivel de garant¿a
        11.0        28/01/2010  AVT              17.0012811: CEM - RT - El vencimiento no debe generar rescate
        12.0        26/02/2009  ICV              18.0013068: CRE - Grabar el motivo de la anulaci¿n al anular la p¿liza
        13.0        26/03/2010  JRH              19.0013916: CEM800 - Vencimiento p¿lizas de ahorro
        14.0        23/04/2010  JRH              19.0014265: CEM800 - Corregir uso de variables de contexto
        15.0        15/05/2010  AVT              20.0015007: CEM800 - Anul¿lacions: error en el tractament de c¿muls
        21.0        13/09/2010  DRA              21.0015936: CIV800 - ERROR EN ANULACI¿N SIN EFECTO en VIDARIESGO
        22.0        13/08/2010  RSC              22. 14775: AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
        23.0        04/11/2010  APD              23. 16095: Implementacion y parametrizacion producto GROUPLIFE
        24.0        13/12/2010  ICV              24. 0016775: CRT101 - Baja de p¿lizas
        25.0        07/01/2011  XPL              25. 17205: ENSA101 - Incidencies en la baixa de particip
        26.0        03/03/2011  JGR              26. 0017672: CEM800 - Contracte Reaseguro 2011 - A¿adir nuevo par¿metro w_cdetces
        27.0        28/04/2011  FAL              27. 0016775: CRT101 - Baja de p¿lizas
        28.0        31/05/2011  DRA              28. 0018706: CRE800 - P¿lisses ULK que no passen cartera
        29.0        24/10/2011  JGR              29. 0019292: CRE800 - Rebuts d'extorn i cessions (AXIS3186)
        30.0        31/10/2011  APD              30. 0019557: LCOL_T001-Despeses expedici¿
        31.0        14/11/2011  FAL              31. 0019627: GIP102 - Reunificaci¿n de recibos
        32.0        22/11/2011  JMP              32. 0019557: LCOL_T001-Despeses expedici¿
        33.0        21/11/2011  JMP              33. 0018423: LCOL000 - Multimoneda
        34.0        22/11/2011  RSC              34. 0020241: LCOL_T004-Parametrizaci¿n de Rescates (retiros)
        35.0        05/12/2011  JMF              35. 0020414: LCOL_T001-Despeses d'expedici¿ no prorrategen al extornar-se.
        36.0        09/12/2011  RSC              36. 0019312: LCOL_T004 - Parametrizaci¿n Anulaciones
        37.0        30/12/2011  AVT              37. 0019885: LCOL898 - 05 - Crida al Host per rebut d'extorn
        38.0        12/01/2012  RSC              38. 0020664: LCOL_T001-LCOL - UAT - TEC - Anulaciones y Rehabilitaciones
        39.0        20/01/2012  APD              39. 0020664: LCOL_T001-LCOL - UAT - TEC - Anulaciones y Rehabilitaciones
        40.0        27/01/2012  JMF              40. 0021096: Suplemento de cambio de cuenta bancaria
        41.0        26/01/2012  MDS              41. 0020664: LCOL_T001-LCOL - UAT - TEC - Anulaciones y Rehabilitaciones
        42.0        08/02/2012  FAL              42. 0021289: Prorrateo en los recibos de extorno. No est¿ prorrateando ning¿n concepto en ninguna instalaci¿n.
        43.0        13/03/2012  AVT              43. 0021559: LCOL999-Cambios en el Reaseguro: no s'anul¿la la cessi¿ si ¿s a causa d'un sinistre
        44.0        15/03/2012  JGR              44. 0021096   15-3-2012   0021096: Suplemento cambio cuenta bancaria: no modificar los pendientes con "prenotificaci¿n en curso" -  0110348
        45.0        11/07/2012  APD              45. 0022826: LCOL_T010-Recargo por anulaci¿n a corto plazo
        46.0        03/08/2012  APD              46. 0023074: LCOL_T010-Tratamiento Gastos de Expedici¿n
        47.0        03/09/2012  JMF              47. 0022701: LCOL: Implementaci¿n de Retorno
        48.0        17/10/2012  JGR              48. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2
        49.0        27/09/2012  APD              49. 0023817: LCOL - Anulaci¿n de colectivos
        50.0        09/11/2012  APD              50. 0023940: LCOL_T010-LCOL - Certificado 0 renovable - Renovaci?n colectivos
        51.0        13/11/2012  DCT              51. 0023817/128727: LCOL - Anulaci¿n de colectivos
        52.0        21/11/2012  DRA              52. 0024802: LCOL_C001-LCOL: Anulaci?n de p?liza con co-corretaje
        53.0        12/12/2012  JMF              0024832 LCOL - Cartera colectivos - Procesos
        54.0        14/12/2012  JDS              53. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
        55.0        21/01/2013  APD              54. 0025542: LCOL_T031- LCOL - AUT - (id 431) Fecha de antig?edad en personas por agrupaci?n
        56.0        31/01/2013  ECP              56. 0025450: LCOL_T001-QT-5394 - El sistema no permite realizar un reemplazo si la p?liza tiene recibos pendientes
        57.0        08/02/2013  APD              57. 0025583: LCOL - Revision incidencias qtracker (IV)
        58.0        13/02/2013  JDS              58. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
        59.0        08/03/2013  JDS              59. 0026070: LCOL_T010-LCOL - Revision incidencias qtracker (V)
        60.0        21/03/2013  AFM              60. 0025951: RSA003 - M¿dulo de cobranza
        61.0        29/04/2013  APD              61. 0025827: LCOL_T031-LCOL - Fase 3 - (176-16) - Parametrizaci¿n de anulaciones y rehabilitaciones
        62.0        02/05/2013  APD              62. 0026830: QT: 7418, 7419, 7420 y 7421 Cesiones de p¿liza en Producci¿n
        63.0        28/05/2013  JGR              63. 0027044: Tratamiento de los recibos con cobros parciales en la anulaci¿n de p¿lizas
        64.0        31/05/2013  JGR              64. 0027044: Tratamiento de los recibos con cobros parciales en la anulaci¿n de p¿lizas - 0145617
        65.0        02/07/2013  dlF              65. 0027524 - Error al calcular el extorno de una p¿liza de sobreprecio
        66.0        11/07/2013  APD              66. 0027539/148870: LCOL_T010-LCOL - Revision incidencias qtracker (VII)
        67.0        12/07/2013  JGR              67. 0027644: No se ha de prorratear los conceptos de 14 y 86 en los recibos de tiempo transcurrido - QT-8596
        68.0        26/07/2013  APD              68. 0027539/149936: LCOL_T010-LCOL - Revision incidencias qtracker (VII)
        69.0        13/08/2013  MMM              69. 0027879: LCOL_T020-Qtracker: 0008849: ERROR AL VISUALIZAR POLIZA ANULADA 61006842
        70.0        13/09/2013  AVT              70. 0027883: LCOL_T020-Qtracker: 0008796: Se presenta un error desconocido en Anulaciones
        71.0        17/09/2013  MMM              71. 0027879: LCOL_T020-Qtracker: 0008849: ERROR AL VISUALIZAR POLIZA ANULADA - NOTA 0152786
        72.0        01/10/2013  MMM              72. 0026354: LCOL_A004-Qtracker: 0006001: Error cesion de polizas - NOTA 0154332
        73.0        11/10/2013  DCT              73. 0027048: LCOL_T010-Revision incidencias qtracker (V)
        74.0        07/11/2013  DCT              73. 0027048: LCOL_T010-Revision incidencias qtracker (V)
        75.0        21/11/2013  FAL              75. 0026835: GIP800 - Incidencias reportadas 23/4
        76.0        10/01/2014  JSV              76. 0028820: LCOL895-LCOL - Anulacion de aportaci?n (baja sin efecto)
        77.0        16/04/2014  JSV              77. 0029358: LCOL_T010-LCOL - Revision incidencias qtracker (VIII)
        78.0        14/03/2014  APD              78. 0030448/169686: LCOL_T010-Revision incidencias qtracker (2014/03)
        79.0        20/03/2014  FAL              79. 0029965: RSA702 - GAPS renovaci¿n
        80.0        14/05/2014  ECP              80. 0031204/ 0012594: El sistema no permite anular una p¿liza que tiene siniestro en estado anulado
        81.0        11/07/2014  DCT              81. 0032009: LCOL_PROD-LCOL_T031-Revisi¿n Fase 3A Producci¿n
        82.0        20/10/2014  RDD              82. 0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management)
        82.0        02/12/2014  RDD              82. 0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management)
        84.0        17/12/2014  JAMF             84. 0033921: Anulaci¿n de Recibos con pagos parciales
        85.0        18/05/2015  AQ               85. 0035775: Soporte cierres abril 2015
        86.0        10/06/2015  YDA              86. 0031548: Se modifica p_baja_automatico_vto para implementar el rescate por vencimiento
        87.0        13/10/2015  NMM              38020: Revisi¿ codi
        88.0        14/05/2019  ECP              89. IAXIS-3631 Cambio de Estado cuando las pólizas están vencidas (proceso nocturno)
        89.0        15/05/2019  ECP              90. IAXIS-3592 Proceso de terminación por no pago  
        90.0        19/09/2019  DFR              90. IAXIS-5327 Ajuste en la tabla MOVRECIBO 
        91.0        23/10/2019  DFR              91. IAXIS-4926: Anulación de póliza y movimientos con recibos abonados y Reversión de recaudos en recibos.
        92.0        18/11/2019  DFR              92. IAXIS-7627: Verificación de campo CSUBTIPREC de la tabla RECIBOS para efectos contables.
        93.0        05/02/2020  DFR              93. IAXIS-11903: Anulación de póliza
   ******************************************************************************/
   k_cempresa   CONSTANT empresas.cempres%TYPE
      := NVL (pac_md_common.f_get_cxtempresa,
              f_parinstalacion_n ('EMPRESADEF')
             );

   --
   --  Funci¿ privada : Torna una descripci¿ a gravar als error pel continugt de recibos_pend
   --
   FUNCTION f_recibostochar (ppend IN recibos_pend)
      RETURN VARCHAR2
   IS
      v_aux   VARCHAR2 (500);
   BEGIN
      IF ppend.FIRST IS NOT NULL
      THEN
         v_aux := '(' || ppend.COUNT || ':(nrecibo,fmovini,fefecto,fvencim) ';

         FOR i IN ppend.FIRST .. ppend.LAST
         LOOP
            v_aux :=
                  v_aux
               || '('
               || ppend (i).nrecibo
               || ','
               || ppend (i).fmovini
               || ','
               || ppend (i).fefecto
               || ','
               || ppend (i).fvencim
               || ') ';

            IF LENGTH (v_aux) >= 200
            THEN
               v_aux := v_aux || ' (...) ';
               EXIT;
            END IF;
         END LOOP;

         v_aux := v_aux || ')';
      ELSE
         v_aux := '(empty)';
      END IF;

      RETURN v_aux;
   END;

   --
   --  Funci¿ privada : Torna una descripci¿ a gravar als error pel continugt de recibos_cob
   --
   FUNCTION f_recibostochar (ppend IN recibos_cob)
      RETURN VARCHAR2
   IS
      v_aux   VARCHAR2 (500);
   BEGIN
      IF ppend.FIRST IS NOT NULL
      THEN
         v_aux := '(' || ppend.COUNT || ':(nrecibo,fmovini,fefecto,fvencim) ';

         FOR i IN ppend.FIRST .. ppend.LAST
         LOOP
            v_aux :=
                  v_aux
               || '('
               || ppend (i).nrecibo
               || ','
               || ppend (i).fmovini
               || ','
               || ppend (i).fefecto
               || ','
               || ppend (i).fvencim
               || ') ';

            IF LENGTH (v_aux) >= 200
            THEN
               v_aux := v_aux || ' (...) ';
               EXIT;
            END IF;
         END LOOP;

         v_aux := v_aux || ')';
      ELSE
         v_aux := '(empty)';
      END IF;

      RETURN v_aux;
   END;

   FUNCTION f_baja_tarj (
      psseguro   IN   NUMBER,
      pfanulac   IN   DATE,
      pnmovimi   IN   NUMBER
   )
      RETURN NUMBER
   IS
   BEGIN
         /*
      --      {Actualizamos las tarjetas con la fecha y movimiento de baja}
         */
      BEGIN
         UPDATE tarjetas
            SET fbaja = pfanulac,
                nmovimb = pnmovimi
          WHERE sseguro = psseguro AND fbaja IS NULL;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN 105125;               --{error al retroceder las tarjetas}
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_baja_tarj',
                      1,
                      SQLERRM,
                      SQLERRM
                     );
         RETURN 140999;                                 --{Error no controlat}
   END f_baja_tarj;

   FUNCTION f_baja_rea (
      psseguro   IN   NUMBER,
      pfanulac   IN   DATE,
      pcmoneda   IN   NUMBER
   )
      RETURN NUMBER
   IS
      ssproces   NUMBER;
      sscumulo   NUMBER;
      num_err    NUMBER;
      v_traza    NUMBER;
      vsproduc   NUMBER; -- IAXIS-11903 05/02/2020

      CURSOR riesgo (seguro IN NUMBER)
      IS
         SELECT rie.nriesgo, rie.sseguro, rea.scontra, rea.nversio,
                rea.scumulo
           FROM riesgos rie, reariesgos rea
          -- 15007 AVT 15-06-2010 s'afegeix REARIESGOS per considerar contracte i versi¿
         WHERE  rie.sseguro = rea.sseguro
            AND rie.nriesgo = rea.nriesgo
            AND rie.sseguro = seguro
            AND freafin IS NULL
            AND fanulac IS NULL;

      --27883 AVT 13/09/2013
      CURSOR c_no_riesgo (seguro IN NUMBER, cumulo IN NUMBER)
      IS
         SELECT rie.nriesgo, rie.sseguro, rea.scontra, rea.nversio,
                rea.scumulo, seg.csituac
           FROM riesgos rie, reariesgos rea, seguros seg
          WHERE rie.sseguro = rea.sseguro
            AND rie.nriesgo = rea.nriesgo
            AND rie.sseguro = seg.sseguro
            AND rie.sseguro <> seguro
            AND rea.scumulo = cumulo
            AND rea.freafin IS NULL
            AND rie.fanulac IS NULL;
   BEGIN
      /*
                {obtenemos el c¿digo de procesos}
      */
      SELECT sproces.NEXTVAL
        INTO ssproces
        FROM DUAL;

      /*
             {se tiran atras las cesiones de la poliza}
      */
      num_err := f_atras (ssproces, psseguro, pfanulac, 6, pcmoneda);

      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      /*
             {Para cada uno de los riesgos se da de baja los c¿mulos}
      */
      --
      -- Inicio IAXIS-11903 05/02/2020
      --
      -- Dejamos la regularización desactivada de momento por sugencia de negocio. Sin embargo, 
      -- se deja parametrizable para anulaciones de póliza en caso de necesitarse.
      --
      SELECT s.sproduc
        INTO vsproduc
        FROM seguros s
       WHERE s.sseguro = psseguro;
      IF NVL(f_parproductos_v(vsproduc, 'REGULARIZA'), 0) = 1 THEN
      --
      -- Fin IAXIS-11903 05/02/2020
      --  
      FOR c IN riesgo (psseguro)
      LOOP
         BEGIN
            -- 15007 AVT 15-06-2010
            sscumulo := c.scumulo;

            /*   SELECT scumulo
                             INTO sscumulo
                 FROM reariesgos
                WHERE sseguro = c.sseguro
                  AND nriesgo = c.nriesgo
                  AND freafin IS NULL;*/
            -- 15007 AVT 15-06-2010 fi
            IF sscumulo IS NOT NULL
            THEN
               /*
                            { damos de baja el riesgo en los cumulos}
               */
               num_err := f_bajacu (c.sseguro, pfanulac);

               IF num_err <> 0
               THEN
                  RETURN num_err;
               END IF;

               /*
                              { reajusta los cumulos despues de modificarlos}
               */
               -- Bug 26830 - APD - 02/05/2013 - se a¿ade el parametro c.sseguro a la llamada
               num_err :=
                  f_cumulo (ssproces,
                            sscumulo,
                            pfanulac,
                            1,
                            pcmoneda,
                            c.sseguro
                           );

               -- fin Bug 26830 - APD - 02/05/2013
               --27883 AVT 13/09/13 inici ----------------------------
               --IF num_err <> 0 THEN
               --    RETURN num_err;
               --END IF;
               IF num_err <> 0 AND num_err <> 99
               THEN
                  ROLLBACK;
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_anulacion.f_baja_rea',
                               92,
                                  'ssproces:'
                               || ssproces
                               || ' sscumulo:'
                               || sscumulo
                               || ' pfanulac:'
                               || pfanulac
                               || ' pcmoneda:'
                               || pcmoneda
                               || ' c.sseguro:'
                               || c.sseguro,
                               num_err
                              );
                  RETURN num_err;
               ELSIF num_err = 99
               THEN
                  num_err := 105382;                       --No te facultatiu
                  -->> ??????????????????????? pcmotret := 10;   -- BUG9640:DRA:30-03-2009
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_anulacion.f_baja_rea',
                               93,
                                  'ssproces:'
                               || ssproces
                               || ' sscumulo:'
                               || sscumulo
                               || ' pfanulac:'
                               || pfanulac
                               || ' pcmoneda:'
                               || pcmoneda
                               || ' c.sseguro:'
                               || c.sseguro,
                               num_err
                              );

                  BEGIN
                     v_traza := 1;
                  
                     DELETE      cesionesrea
                           WHERE sseguro = c.sseguro
                             AND cgenera = 6
                             AND TRUNC (fgenera) = TRUNC (f_sysdate);

                     v_traza := 2;

                     UPDATE cesionesrea
                        SET fanulac = NULL
                      WHERE sseguro = c.sseguro
                        AND cgenera <> 6
                        AND fanulac = pfanulac;

                     v_traza := 3;

                     UPDATE reariesgos
                        SET freafin = NULL
                      WHERE sseguro = c.sseguro AND freafin = pfanulac;

                     v_traza := 4;

                     DELETE      cesionesaux
                           WHERE sseguro = c.sseguro;

                     COMMIT;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        num_err := 102361;
                        p_tab_error (f_sysdate,
                                     f_user,
                                     'pac_anulacion.f_baja_rea',
                                     v_traza,
                                     'c.sseguro:' || c.sseguro,
                                     SQLERRM
                                    );
                  END;

                  --DBMS_OUTPUT.put_line('4 num_err:' || num_err);
                  FOR v_pol IN c_no_riesgo (psseguro, sscumulo)
                  LOOP
                     BEGIN
                        v_traza := 11;

                        DELETE      cesionesrea
                              WHERE sseguro = v_pol.sseguro
                                AND scumulo = v_pol.scumulo
                                AND cgenera = 1
                                AND TRUNC (fgenera) = TRUNC (f_sysdate)
                                --72. 01/10/2013 - MMM - 0026354: LCOL_A004-Qtracker: 0006001: Error cesion de polizas - NOTA 0154332 - Inicio
                                AND sproces = ssproces;

                        v_traza := 111;

                        DELETE      cesionesrea
                              WHERE sseguro = v_pol.sseguro
                                AND scumulo = v_pol.scumulo
                                AND cgenera = 8
                                AND TRUNC (fgenera) = TRUNC (f_sysdate)
                                AND sproces = ssproces;

                        --72. 01/10/2013 - MMM - 0026354: LCOL_A004-Qtracker: 0006001: Error cesion de polizas - NOTA 0154332 - Fin
                        v_traza := 12;

                        UPDATE cesionesrea
                           SET fregula = NULL
                         WHERE sseguro = v_pol.sseguro
                           AND cgenera <> 8
                           AND fregula >= pfanulac
                           AND scumulo = v_pol.scumulo;

                        v_traza := 13;

                        UPDATE seguros
                           --SET csituac = DECODE(v_pol.csituac, 0, 4, 1, 5, 10)
                        SET creteni = 1                             --Retenida
                         WHERE sseguro = v_pol.sseguro;

                        -- DBMS_OUTPUT.put_line('5 num_err:' || num_err || ' v_pol.sseguro:'
                          --                    || v_pol.sseguro);
                        COMMIT;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           num_err := 102361;
                           p_tab_error (f_sysdate,
                                        f_user,
                                        'pac_anulacion.f_baja_rea',
                                        v_traza,
                                        'v_pol.sseguro:' || v_pol.sseguro,
                                        SQLERRM
                                       );
                     END;
                  END LOOP;
               ELSIF num_err = 0
               THEN
                  FOR v_pol IN c_no_riesgo (psseguro, sscumulo)
                  LOOP
                     BEGIN
                        UPDATE seguros
                           SET creteni = 0                    --AVT 13/09/2013
                         WHERE sseguro = v_pol.sseguro
                           AND csituac = 0
                           AND creteni = 1;

                        COMMIT;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           num_err := 102361;
                           p_tab_error (f_sysdate,
                                        f_user,
                                        'pac_anulacion.f_baja_rea',
                                        v_traza,
                                        'v_pol.sseguro:' || v_pol.sseguro,
                                        SQLERRM
                                       );
                     END;
                  END LOOP;
               END IF;
            --27883 AVT 13/09/13 -------------------------------- fi
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;
      END LOOP;
      END IF; -- IAXIS-11903 05/02/2020

      RETURN num_err;                    --27883 AVT 13/09/13 RETORNAR L'ERROR
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_baja_rea',
                      101,
                      SQLERRM,
                      SQLERRM
                     );
         RETURN 140999;                                 --{Error no controlat}
   END f_baja_rea;

   FUNCTION f_baja_seg (
      psseguro     IN       NUMBER,
      pfanulac     IN       DATE,
      pcextorn     IN       NUMBER,
      pcmotmov     IN       NUMBER,
      pnmovimi     IN OUT   NUMBER,
      pcnotibaja   IN       NUMBER DEFAULT NULL,
      pcsituac     IN       NUMBER DEFAULT 2,
      pccauanul    IN       NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      num_err   NUMBER;
   --v_csitvto      NUMBER;
   BEGIN
      -- ini BUG 0021096 - 27/01/2012 - JMF
      -- Existen recibos con prenotificaci¿n en curso
      SELECT MAX (9903189)
        INTO num_err
        FROM recibos
       WHERE sseguro = psseguro AND cestimp = 12;

      -- 44. 21096: Suplemento cambio cuenta bancaria -  0110348

      --  AND cestimp = 11; -- 44. 21096: Suplemento cambio cuenta bancaria -  0110348
      IF num_err IS NOT NULL
      THEN
         RETURN num_err;
      END IF;

      -- fin BUG 0021096 - 27/01/2012 - JMF

      /*
            {generamos el movimiento de anulaci¿n}
      */

      --Ini Bug.: 13068 - 26/02/2010 - ICV - Se a¿ade el paso del parametro PCCAUANUL
      num_err :=
         f_anulaseg (psseguro,
                     pcextorn,
                     pfanulac,
                     pcmotmov,
                     NULL,
                     pcsituac,
                     pnmovimi,
                     pcnotibaja,
                     NULL,
                     NULL,
                     pccauanul
                    );

      --Fin Bug.: 13068
      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      /*
            {Actualizamos la poliza a anulada}
      */
      -- IAXIS-3592 -- ECP -- 15/05/2019
      if pcmotmov = 321 then
          BEGIN
         UPDATE seguros
            SET csituac = 19,
                creteni = 0
          WHERE sseguro = psseguro;
          end;
     
      
      else
      BEGIN
         UPDATE seguros
            SET csituac = pcsituac,
                creteni = 0
          WHERE sseguro = psseguro;
      END;
      end if;
      -- IAXIS-3592 -- ECP -- 15/05/2019
      -- Bug 25542 - APD - 16/01/2013
      -- Se actualiza la antiguedad de las personas de la poliza
      num_err := pac_persona.f_antiguedad_personas_pol (psseguro);

      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      -- Fin Bug 25542 - APD - 16/01/2013

      /*
            {damos de baja las tarjetas}
      */
      num_err := f_baja_tarj (psseguro, pfanulac, pnmovimi);

      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_baja_seg',
                      1,
                      SQLERRM,
                      SQLERRM
                     );
         RETURN 140999;                                 --{Error no controlat}
   END f_baja_seg;

   -- Bug 23817 - APD - 09/10/2012 - se crea la funcion
   -- Genera un recibo de extorno como copia un recibo
   FUNCTION f_extorn_rec_pend (pnrecibo IN NUMBER)
      RETURN NUMBER
   IS
      ssmovrec         NUMBER                      := 0;
      num_err          NUMBER;
      n_paso           NUMBER;
      v_nreciboclon    recibos.nrecibo%TYPE;
      v_sseguro        seguros.sseguro%TYPE;
      v_nmovimi        movseguro.nmovimi%TYPE;
      v_cempres        seguros.cempres%TYPE;
      -- Bug 26070 - RSC - 11/02/2013 - LCOL_T010-LCOL - Revision incidencias (modificaci¿n cursor)
      v_crespue_4092   pregunpolseg.crespue%TYPE;
      -- Fin Bug 26070

      -- 69. MMM - 13/08/2013 - 0027879: LCOL_T020-Qtracker: 0008849: ERROR AL VISUALIZAR POLIZA ANULADA 61006842 - Inicio
      xcestrec         movrecibo.cestrec%TYPE;
      xfmovini         movrecibo.fmovini%TYPE;
      xsmovrec         movrecibo.smovrec%TYPE;
   -- 69. MMM - 13/08/2013 - 0027879: LCOL_T020-Qtracker: 0008849: ERROR AL VISUALIZAR POLIZA ANULADA 61006842 - Fin
   BEGIN
      n_paso := 1;
      -- porigen = 2.-Anulacion
      num_err :=
         pac_adm.f_clonrecibo (1, pnrecibo, v_nreciboclon, ssmovrec, NULL, 2);
      n_paso := 2;

      -- fin Bug 22826 - APD - 11/07/2012
      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      -- 69. MMM - 13/08/2013 - 0027879: LCOL_T020-Qtracker: 0008849: ERROR AL VISUALIZAR POLIZA ANULADA 61006842 - Inicio
      SELECT MAX (smovrec)
        INTO xsmovrec
        FROM movrecibo
       WHERE nrecibo = v_nreciboclon;

      SELECT cestrec, fmovini
        INTO xcestrec, xfmovini
        FROM movrecibo
       WHERE smovrec = xsmovrec;

      num_err :=
         f_insctacoas (v_nreciboclon,
                       xcestrec,
                       v_cempres,
                       xsmovrec,
                       TRUNC (xfmovini)
                      );

      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      -- 69. MMM - 13/08/2013 - 0027879: LCOL_T020-Qtracker: 0008849: ERROR AL VISUALIZAR POLIZA ANULADA 61006842 - Fin
      n_paso := 3;

      SELECT sseguro, cempres
        INTO v_sseguro, v_cempres
        FROM recibos
       WHERE nrecibo = v_nreciboclon;

      n_paso := 4;

      SELECT MAX (nmovimi)
        INTO v_nmovimi
        FROM movseguro
       WHERE sseguro = v_sseguro;

      n_paso := 5;
      -- Bug 26070 - RSC - 11/02/2013 - LCOL_T010-LCOL - Revision incidencias (modificaci¿n cursor)
      num_err :=
         pac_preguntas.f_get_pregunpolseg (v_sseguro,
                                           4092,
                                           'SEG',
                                           v_crespue_4092
                                          );

      IF v_crespue_4092 = 1 AND num_err = 0
      THEN
-- Si es administrado lo dejamos con el cestaux del recibo original, es decir 2.
         UPDATE recibos r
            SET nmovimi = v_nmovimi,
                ctiprec = DECODE (ctiprec, 13, 15, 9, 1, 15, 13, 9),
                -- Bug 266488 - RSC. Adicionalmente BUG 27624.JLV
                femisio = f_sysdate
          WHERE nrecibo = v_nreciboclon;
      ELSE
         -- Fin Bug 26070
         UPDATE recibos r
            SET nmovimi = v_nmovimi,
                ctiprec = DECODE (ctiprec, 13, 15, 9, 1, 15, 13, 9),
                -- Bug 266488 - RSC. Adicionalmente BUG 27624.JLV
                cestaux = 0,                                 -- RSC 02/02/2013
                femisio = f_sysdate
          WHERE nrecibo = v_nreciboclon;
      -- Bug 26070 - RSC - 11/02/2013 - LCOL_T010-LCOL - Revision incidencias (modificaci¿n cursor)
      END IF;

      -- Fin Bug 26070
      n_paso := 6;

      -- BUG24802:DRA:20/11/2012:Inici
      IF pac_corretaje.f_tiene_corretaje (v_sseguro, NULL) = 1
      THEN
         n_paso := 7;
         --num_err := pac_corretaje.f_gen_comision_corr(v_sseguro, v_nmovimi, v_nreciboclon);
         num_err :=
            pac_corretaje.f_reparto_corretaje (v_sseguro,
                                               v_nmovimi,
                                               v_nreciboclon
                                              );

         IF num_err <> 0
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'pac_anulacion.f_extorn_rec_pend',
                         n_paso,
                            'pnrecibo:'
                         || pnrecibo
                         || ' v_sseguro:'
                         || v_sseguro
                         || ' v_nmovimi:'
                         || v_nmovimi
                         || ' v_nreciboclon:'
                         || v_nreciboclon,
                         f_axis_literales (num_err, f_usu_idioma)
                        );
            RETURN num_err;
         END IF;
      END IF;

      -- Bug 26070 - RSC - 11/02/2013 - LCOL_T010-LCOL - Revision incidencias (modificaci¿n cursor)
      IF v_crespue_4092 = 1 AND num_err = 0
      THEN
         NULL;
      -- Si es administrado no env¿ar a JDE. Se har¿ en un recibo agrupado.
      ELSE
         -- Fin Bug 26070

         -- Bug 25583 - APD - 08/02/2013
         --Despues de realizar los ajustes necesarios procedemos a  enviar el recibo a la ERP
         IF     NVL (pac_parametros.f_parempresa_n (v_cempres,
                                                    'GESTIONA_COBPAG'
                                                   ),
                     0
                    ) = 1
            AND num_err = 0
         THEN
            num_err :=
               pac_ctrl_env_recibos.f_proc_recpag_mov (v_cempres,
                                                       v_sseguro,
                                                       v_nmovimi,
                                                       4,
                                                       NULL
                                                      );
         END IF;
      -- fin Bug 25583 - APD - 08/02/2013

      -- Bug 26070 - RSC - 11/02/2013 - LCOL_T010-LCOL - Revision incidencias (modificaci¿n cursor)
      END IF;

      -- Fin Bug 26070

      -- BUG24802:DRA:20/11/2012:Fi
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_extorn_rec_pend',
                      n_paso,
                      'pnrecibo:' || pnrecibo,
                      SQLERRM
                     );
         RETURN 140999;                                 --{Error no controlat}
   END f_extorn_rec_pend;

   FUNCTION f_baja_rec_pend (
      pfanulac       IN   DATE,
      rpend          IN   recibos_pend,
      pskipextanul   IN   NUMBER DEFAULT 0,
      pnmovimi       IN   NUMBER DEFAULT NULL,
      pcmotmov       IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      ccdelega              NUMBER;
      ccempres              NUMBER;
      ffanularec            DATE;
      ccmotanul             NUMBER;
      nnliqmen              NUMBER;
      nnliqlin              NUMBER;
      ssmovrec              NUMBER                      := 0;
      num_err               NUMBER;
      n_paso                NUMBER;
      -- 48.0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Inicio
      vfcobros              DATE;
      vsmovagr              NUMBER;
      -- 48.0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Fin
      v_ctiprec             recibos.ctiprec%TYPE;
      -- Bug 23817 - APD - 09/10/2012
      v_extorna_rec_anula   NUMBER;           -- Bug 23817 - APD - 09/10/2012
      v_nrecunif            adm_recunif.nrecunif%TYPE   := NULL;
                                              -- Bug 23817 - APD - 09/10/2012
      --v_csituac      seguros.csituac%TYPE;   -- Bug 23817 - APD - 09/10/2012
      v_cont                NUMBER;           -- Bug 23817 - APD - 09/10/2012
      v_sseguro             seguros.sseguro%TYPE;
      wcestrec              NUMBER;
   BEGIN
      n_paso := 1;

      IF rpend.FIRST IS NOT NULL
      THEN
         FOR i IN rpend.FIRST .. rpend.LAST
         LOOP
            /*
                                             {buscamos la delegaci¿n}
                */
            BEGIN
               n_paso := 3;

               SELECT cdelega, cempres
                 INTO ccdelega, ccempres
                 FROM recibos
                WHERE nrecibo = rpend (i).nrecibo;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  RETURN 112614;    --{rebut no trobat a la llista de rebuts}
            END;

            -- 48.0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Inicio
            -- Si el recibo tiene cobros parciales se ha de anular por "pac_adm_cobparcial.f_anula_rec"
            IF pac_adm_cobparcial.f_get_importe_cobro_parcial
                                                            (rpend (i).nrecibo,
                                                             NULL,
                                                             NULL
                                                            ) > 0
            THEN
               num_err :=
                  pac_adm_cobparcial.f_anula_rec (rpend (i).nrecibo,
                                                  vfcobros,
                                                  vsmovagr
                                                 );

               IF num_err <> 0
               THEN
                  RETURN num_err;
               END IF;
            ELSE
               -- 48.0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Fin
                  -- Bug 23817 - APD - 09/10/2012 - se busca el valor del parempresa 'EXTORNA_REC_ANULA'
                  -- para saber si se debe extornar el recibo que se va a anular (1) o se debe
                  -- realmente anular (0)

               -- Bug 25583 - RSC - 28/01/2013
               IF pskipextanul = 1
               THEN
                  v_extorna_rec_anula := 0;
               ELSE
                  -- Fin Bug 25583
                  v_extorna_rec_anula :=
                     NVL (pac_parametros.f_parempresa_n (ccempres,
                                                         'EXTORNA_REC_ANULA'
                                                        ),
                          0
                         );
               END IF;

               -- fin Bug 23817 - APD - 09/10/2012

               /*
                           {
                La fecha de efecto de la anulaci¿n del recibo, para que sea coherente con las ventas ser¿:
                  1.- La de la anulaci¿n de la p¿liza si se anula con fecha futura.
                  2.- La del dia si no estamos en el tiempo a¿adido de un mes no cerrado.
                  3.- La del ¿ltimo dia del mes de ventas abierto , si estamos en en el tiempo a¿adido de un mes no cerrado.
                 Y siempre se tendr¿ en cuenta que no puede ser anterior al ¿ltimo movimiento
                }
               */
               IF pfanulac >= TRUNC (f_sysdate)
               THEN
                  n_paso := 5;
                  ffanularec := pfanulac;
               ELSE
                  n_paso := 7;

                  SELECT LAST_DAY (ADD_MONTHS (MAX (fperini), 1))
                    INTO ffanularec
                    FROM cierres
                   WHERE ctipo = 1 AND cestado = 1 AND cempres = ccempres;

                  IF TRUNC (f_sysdate) < ffanularec
                  THEN
                     n_paso := 9;
                     ffanularec := TRUNC (f_sysdate);
                  END IF;
               END IF;

               IF ffanularec < rpend (i).fmovini OR ffanularec IS NULL
               THEN
                  n_paso := 11;
                  ffanularec := rpend (i).fmovini;
               END IF;

               n_paso := 13;

               -- BUG 0024450 - INICIO - DCT - 27/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS.
               IF pcmotmov IS NOT NULL
               THEN
                  ccmotanul := pcmotmov;
               ELSE
                  ccmotanul := 0;      --{Nuevo funcionamiento de las ventas}
               END IF;

               -- BUG 0024450 - FIN - DCT - 27/11/2013 - LCOL_T010-LCOL - SUPLEMENTO DE SUSPENSI?N Y REINICIO DE VIGENCIAS.

               --BUG0011653-02/11/2009-JMF-ini
               DECLARE
                  n_recagr      adm_recunif.nrecunif%TYPE   := NULL;
                  n_estagr      NUMBER;
                  r_lisrec      t_lista_id                  := t_lista_id ();
                  n_numrec      NUMBER;
                  n_sproduc     seguros.sproduc%TYPE;
                  d_efenouuni   recibos.fefecto%TYPE;
                  n_estrec      NUMBER;       -- Bug 23817 - APD - 01/10/2012
               --rpendagr       pac_anulacion.recibos_pend;   -- Bug 23817 - APD - 01/10/2012
               --vcur           sys_refcursor;   -- Bug 23817 - APD - 01/10/2012
               --vcont          NUMBER := 1;   -- Bug 23817 - APD - 01/10/2012
               --vrecibos       VARCHAR2(10000) := NULL;   -- Bug 23817 - APD - 01/10/2012
               BEGIN
                  -- Buscar recibo padre para saber si esta agrupado.
                  n_paso := 15;

                  SELECT MAX (c.nrecunif), MAX (b.sproduc)
                    INTO n_recagr, n_sproduc
                    FROM recibos a, seguros b, adm_recunif c
                   WHERE a.nrecibo = rpend (i).nrecibo
                     AND b.sseguro = a.sseguro
                     AND NVL (f_parproductos_v (b.sproduc, 'RECUNIF'), 0) IN
                                                                       (1, 3)
                     --BUG 0019627: GIP102 - Reunificaci¿n de recibos - FAL - 10/11/2011
                     AND c.nrecibo = a.nrecibo;

                  n_paso := 17;

                  SELECT MAX (cestrec)
                    INTO n_estagr
                    FROM movrecibo
                   WHERE nrecibo = n_recagr AND fmovfin IS NULL;

                  -- Bug 23817 - APD - 09/10/2012 - se a¿ade la condificon v_extorna_rec_anula = 0
                  IF n_recagr IS NOT NULL AND v_extorna_rec_anula = 0
                  THEN
                     -- fin Bug 23817 - APD - 09/10/2012
                     -- es un recibo agrupado
                     IF n_estagr = 0
                     THEN
                        -- Si el unificado est¿ pendiente (recibo gordo)
                        -- Crear nova llista de rebuts excloent el rebut que estem anulant
                        r_lisrec.DELETE;
                        n_numrec := 0;
                        n_paso := 19;

                        FOR f1 IN (SELECT nrecibo
                                     FROM adm_recunif
                                    WHERE nrecunif = n_recagr
                                      AND nrecibo <> rpend (i).nrecibo)
                        LOOP
                           n_paso := 21;
                           n_numrec := n_numrec + 1;
                           r_lisrec.EXTEND;
                           r_lisrec (r_lisrec.LAST) := ob_lista_id ();
                           r_lisrec (r_lisrec.LAST).idd := f1.nrecibo;
                        END LOOP;

                        -- anulamos recibo agrupado.
                        n_paso := 23;
                        num_err :=
                           f_movrecibo (n_recagr,
                                        2,
                                        pfanulac,
                                        2,
                                        ssmovrec,
                                        nnliqmen,
                                        nnliqlin,
                                        ffanularec,
                                        NULL,
                                        ccdelega,
                                        ccmotanul,
                                        NULL
                                       );

                        IF NVL (num_err, 0) <> 0
                        THEN
                           RETURN num_err;
                        END IF;

                        n_paso := 24;

                        DECLARE
                           n_sec   adm_recunif_his.nsec%TYPE;
                        --n_recnou       adm_recunif.nrecunif%TYPE;
                        BEGIN
                           -- Guardamos conjunto anterior en el historico.
                           SELECT NVL (MAX (nsec), 0) + 1
                             INTO n_sec
                             FROM adm_recunif_his;

                           INSERT INTO adm_recunif_his
                                       (nrecibo, nrecunif, cuser, fhis, cobj,
                                        nsec)
                              SELECT nrecibo, nrecunif, f_user, f_sysdate,
                                     'pac_anulacion.f_baja_rec_pend', n_sec
                                FROM adm_recunif
                               WHERE nrecunif = n_recagr;
                        END;

                        n_paso := 25;

                        -- Calcular fecha efecto.
                        SELECT MAX (a.fefecto)
                          INTO d_efenouuni
                          FROM recibos a, adm_recunif b
                         WHERE a.nrecibo = b.nrecibo
                           AND b.nrecibo <> rpend (i).nrecibo
                           AND b.nrecunif = n_recagr;

                        n_paso := 26;

                        -- Borrar agrupaci¿n actual.
                        DELETE      adm_recunif
                              WHERE nrecunif = n_recagr;

                        n_paso := 27;

                        IF d_efenouuni IS NOT NULL
                        THEN
                           -- Crear nova agrupaci¿ amb nova llista rebuts que queden.
                           n_paso := 28;

                           -- Bug 23817 - APD - 09/10/2012 - se busca el tipo de recibo
                           -- del recibo agrupado que se a anular para que el nuevo recibo
                           -- agrupado que se crea sea del mismo tipo
                           BEGIN
                              SELECT ctiprec
                                INTO v_ctiprec
                                FROM recibos
                               WHERE nrecibo = n_recagr;
                           EXCEPTION
                              WHEN OTHERS
                              THEN
                                 v_ctiprec := 3;
                           -- Valor por defecto q recibe la funcion f_agruparecibo
                           END;

                           n_paso := 29;
                           num_err :=
                              pac_gestion_rec.f_agruparecibo (n_sproduc,
                                                              d_efenouuni,
                                                              --pfanulac,
                                                              ffanularec,
                                                              ccempres,
                                                              r_lisrec,
                                                              v_ctiprec
                                                             );

                           -- fin Bug 23817 - APD - 09/10/2012
                           IF NVL (num_err, 0) <> 0
                           THEN
                              RETURN num_err;
                           END IF;
                        END IF;
                     ELSE
                        -- Si el unificado NO est¿ pendiente (recibo gordo)
                        RETURN 152130;
                     -- Esta p¿liza tiene recibos en gesti¿n
                     END IF;
                  --BUG0011653-02/11/2009-JMF-fin
                  END IF;

                  n_paso := 30;

                  -- Bug 23817 - APD - 01/10/2012 -
                  -- si se est¿ anulando un recibo agrupado, entonces se deben anular
                  -- todos los recibos pendientes que cuelgan de ¿l (si v_extorna_rec_anula = 0)
                  -- o generar extorno de los recibos pendientes que cuelgan de ¿l (si
                  -- v_extorna_rec_anula = 1)
                  FOR reg IN (SELECT nrecibo
                                FROM adm_recunif a
                               WHERE nrecunif = rpend (i).nrecibo
                                 AND nrecibo != rpend (i).nrecibo)
                  LOOP
                     -- Variable que nos indicar¿ que el recibo a anular es un recibo unificado
                     v_nrecunif := rpend (i).nrecibo;
                     n_paso := 31;

                     -- BUG24802:DRA:20/11/2012:Inici
                     SELECT sseguro
                       INTO v_sseguro
                       FROM recibos
                      WHERE nrecibo = rpend (i).nrecibo;

                     -- BUG24802:DRA:20/11/2012:Fi
                     n_paso := 32;

                     SELECT MAX (cestrec)
                       INTO n_estrec
                       FROM movrecibo
                      WHERE nrecibo = reg.nrecibo AND fmovfin IS NULL;

                     IF n_estrec = 0
                     THEN
                        IF v_extorna_rec_anula = 0
                        THEN
                           n_paso := 33;
                           -- se anula el recibo peque¿o
                           num_err :=
                              f_movrecibo (reg.nrecibo,
                                           2,
                                           pfanulac,
                                           2,
                                           ssmovrec,
                                           nnliqmen,
                                           nnliqlin,
                                           ffanularec,
                                           NULL,
                                           ccdelega,
                                           ccmotanul,
                                           NULL
                                          );

                           IF num_err <> 0
                           THEN
                              RETURN num_err;
                           END IF;

                           n_paso := 34;

                           -- BUG24802:DRA:20/11/2012:Inici
                           IF pac_corretaje.f_tiene_corretaje (v_sseguro,
                                                               NULL) = 1
                           THEN
                              n_paso := 35;
                              /*num_err := pac_corretaje.f_gen_comision_corr(NULL, NULL,
                                                                           reg.nrecibo, -1);*/
                              num_err :=
                                 pac_corretaje.f_reparto_corretaje
                                                                 (NULL,
                                                                  NULL,
                                                                  reg.nrecibo
                                                                 );

                              IF num_err <> 0
                              THEN
                                 p_tab_error
                                            (f_sysdate,
                                             f_user,
                                             'pac_anulacion.f_baja_rec_pend',
                                             n_paso,
                                                'v_sseguro:'
                                             || v_sseguro
                                             || ' reg.nrecibo:'
                                             || reg.nrecibo,
                                             f_axis_literales (num_err,
                                                               f_usu_idioma
                                                              )
                                            );
                                 RETURN num_err;
                              END IF;
                           END IF;
                        -- BUG24802:DRA:20/11/2012:Fi
                        ELSIF v_extorna_rec_anula = 1
                        THEN
                           n_paso := 36;

                           -- se deben tratar los recibos de las polizas que se est¿n
                           -- tratando al anular el certificado 0, es decir, las
                           -- polizas que estan en detmovsegurocol para el certificado 0
                           SELECT COUNT (1)
                             INTO v_cont
                             FROM recibos r, detmovsegurocol d
                            WHERE r.nrecibo = reg.nrecibo
                              AND d.sseguro_cert = r.sseguro
                              AND 3 =
                                     (SELECT cmovseg
                                        FROM movseguro ms2
                                       WHERE ms2.sseguro = d.sseguro_0
                                         AND ms2.nmovimi = d.nmovimi_0);

                           /*AND d.nmovimi_0 IN NVL(pnmovimi,
                                                  (SELECT MAX(ms2.nmovimi)
                                                     FROM movseguro ms2
                                                    WHERE ms2.sseguro = d.sseguro_0
                                                      AND ms2.cmovseg = 3
                                                      AND ms2.cmotmov = 345
                                                      AND ms2.nmovimi >
                                                            (SELECT MAX(ms3.nmovimi)
                                                               FROM movseguro ms3
                                                              WHERE ms3.sseguro =
                                                                                 ms2.sseguro
                                                                AND ms3.cmovseg IN(0, 4))));*/
                           n_paso := 37;

                           IF v_cont = 1
                           THEN
                              -- se genera extorno del recibo peque¿o
                              num_err :=
                                 pac_anulacion.f_extorn_rec_pend (reg.nrecibo);

                              IF num_err <> 0
                              THEN
                                 RETURN num_err;
                              END IF;
                           END IF;
                        END IF;
                     -- fin Bug 23817 - APD - 02/10/2012
                     END IF;
                  END LOOP;

                  /*
                                     {creamos el movimiento de anulaci¿n del recibo}
                  */
                  n_paso := 38;

                  -- Bug 23817 - APD - 09/10/2012 - se debe generar extorno del recibo a anular
                                 -- si v_extorna_rec_anula = 1 y en funcion del recibo que se va a anular:
                  -- n_recagr --> si est¿ informado, el recibo a anular pertenece a un recibo unificado
                  -- v_nrecunif --> si est¿ informado, el recibo a anular es el recibo unificado
                  -- si no est¿n informadas ninguna de las variables anteriores, el recibo a anular
                  -- es un recibo normal, ni unificado ni perteneciente a un recibo unificado
                  IF n_recagr IS NOT NULL AND v_extorna_rec_anula = 1
                  THEN
                     n_paso := 39;
                     -- generar extorno del recibo a tratar
                     num_err :=
                          pac_anulacion.f_extorn_rec_pend (rpend (i).nrecibo);

                     IF num_err <> 0
                     THEN
                        RETURN num_err;
                     END IF;
                  ELSIF v_nrecunif IS NOT NULL AND v_extorna_rec_anula = 1
                  THEN
                     -- no debe hacer nada con el recibo a anular (ya se han generado
                     -- para este caso el extorno de los recibos pendientes que cuelgan del
                     -- recibo unificado)
                     NULL;
                  ELSE
                     n_paso := 40;

                     SELECT ctiprec
                       INTO v_ctiprec
                       FROM recibos
                      WHERE nrecibo = rpend (i).nrecibo;

                     -- BUG 0041116 - FAL - 11/03/2016 - Evitar anular recibo que ya has anulado
                     SELECT cestrec
                       INTO wcestrec
                       FROM movrecibo
                      WHERE nrecibo = rpend (i).nrecibo AND fmovfin IS NULL;

                     IF wcestrec <> 2
                     THEN
                        --BUG 0041116 - FAL - 11/03/2016 - Evitar anular recibo que ya has anulado

                        --27/12/2013 JRH Comentamos el if porque  si no, no anula el retorno en el padreIF v_ctiprec NOT IN(13) THEN   -- retorno
                        num_err :=
                           f_movrecibo (rpend (i).nrecibo,
                                        2,
                                        pfanulac,
                                        2,
                                        ssmovrec,
                                        nnliqmen,
                                        nnliqlin,
                                        ffanularec,
                                        NULL,
                                        ccdelega,
                                        ccmotanul,
                                        NULL
                                       );

                        IF num_err <> 0
                        THEN
                           RETURN num_err;
                        END IF;
                     END IF;

                     --END IF;
                     n_paso := 41;

                     -- BUG24802:DRA:20/11/2012:Inici
                     SELECT sseguro
                       INTO v_sseguro
                       FROM recibos
                      WHERE nrecibo = rpend (i).nrecibo;

                     -- BUG24802:DRA:20/11/2012:Fi
                     n_paso := 42;

                     -- BUG24802:DRA:20/11/2012:Inici
                     IF pac_corretaje.f_tiene_corretaje (v_sseguro, NULL) = 1
                     THEN
                        n_paso := 43;
                        /*num_err := pac_corretaje.f_gen_comision_corr(NULL, NULL,
                                                                     rpend(i).nrecibo, -1);*/
                        num_err :=
                           pac_corretaje.f_reparto_corretaje
                                                            (NULL,
                                                             NULL,
                                                             rpend (i).nrecibo
                                                            );

                        IF num_err <> 0
                        THEN
                           p_tab_error (f_sysdate,
                                        f_user,
                                        'pac_anulacion.f_baja_rec_pend',
                                        n_paso,
                                           'v_sseguro:'
                                        || v_sseguro
                                        || ' rpend(i).nrecibo:'
                                        || rpend (i).nrecibo,
                                        f_axis_literales (num_err,
                                                          f_usu_idioma
                                                         )
                                       );
                           RETURN num_err;
                        END IF;
                     END IF;
                  -- BUG24802:DRA:20/11/2012:Fi
                  END IF;
               -- fin Bug 23817 - APD - 09/10/2012
               END;
            END IF;
         -- 48.0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 (+)
         END LOOP;
      END IF;

      n_paso := 29;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_baja_rec_pend',
                      n_paso,
                         'pfanulac:'
                      || pfanulac
                      || ' rpend:'
                      || f_recibostochar (rpend),
                      SQLERRM
                     );
         RETURN 140999;                                 --{Error no controlat}
   END f_baja_rec_pend;

   FUNCTION f_extorn_ventapte (
      psseguro   IN   NUMBER,
      pcmotmov   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pfanulac   IN   DATE
   )
      RETURN NUMBER
   IS
      reg_seg     seguros%ROWTYPE;
      ffcaranu    DATE;
      ffmovimi    DATE;
      num_err     NUMBER;
      nnrecibo    NUMBER;
      ccdelega    NUMBER;
      nnimport    NUMBER;
      ssmovrec    NUMBER                      := 0;
      nnliqmen    NUMBER;
      nnliqlin    NUMBER;
      paso        NUMBER;
      vsproces    NUMBER                      := 1;
      vfefecto    DATE;
      -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186)
      vfvencim    DATE;
      -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186)
      vdecimals   NUMBER;
      -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186)
      v_cmodcom   comisionprod.cmodcom%TYPE;
   BEGIN
      /*
             {obtenemos los datos del seguro}
      */
      paso := 1;

      BEGIN
         SELECT *
           INTO reg_seg
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 103286;                               --{Seguro no existe}
      END;

      -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186) Inici
      BEGIN
         SELECT   -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                --DECODE(cdivisa, 2, 2, 3, 1, 0)
                pac_monedas.f_moneda_producto (sproduc)
           -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
         INTO   vdecimals
           FROM productos
          WHERE cramo = reg_seg.cramo
            AND cmodali = reg_seg.cmodali
            AND ctipseg = reg_seg.ctipseg
            AND ccolect = reg_seg.ccolect;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 104347;                  -- Producte no trobat a PRODUCTOS
         WHEN OTHERS
         THEN
            RETURN 102705;                    -- Error al llegir de PRODUCTOS
      END;

      -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186) Fi

      /*
             { El vencimiento del recibo ser¿ la fecha de renovaci¿n o la fecha vencimiento de la poliza}
      */
      IF reg_seg.fcaranu IS NOT NULL
      THEN
         ffcaranu := reg_seg.fcaranu;
      ELSE
         ffcaranu := reg_seg.fvencim;
      END IF;

      /*
             {Si se anula con fecha de cartera anual o posterior o ya no hay m¿s carteras no habr¿ P.Dev.}
      */
      IF reg_seg.fcarpro < ffcaranu AND reg_seg.fcarpro IS NOT NULL
      THEN
         paso := 2;

         /*
                {Generamos el recibo de anulaci¿n de venta pdte. de emitir}
         */
         IF f_es_renovacion (psseguro) = 0
         THEN                                                   -- es cartera
            v_cmodcom := 2;
         ELSE                                   -- si es 1 es nueva produccion
            v_cmodcom := 1;
         END IF;

         --BUG9028-XVM-01102009 inici
         IF NVL (pac_parametros.f_parinstalacion_n ('CALCULO_RECIBO'), 1) = 0
         THEN
            paso := 21;
            -- Bug 14775 - RSC - 13/08/2010 - AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
            num_err :=
               pac_adm.f_recries (1,
                                  psseguro,
                                  reg_seg.cagente,
                                  TRUNC (f_sysdate),
                                  reg_seg.fcarpro,
                                  ffcaranu,
                                  9,
                                  NULL,
                                  NULL,
                                  reg_seg.ccobban,
                                  NULL,
                                  NULL,
                                  1,
                                  'R',
                                  v_cmodcom,
                                  ffcaranu,
                                  0,
                                  pcmotmov,
                                  reg_seg.cempres,
                                  pnmovimi,
                                  reg_seg.csituac,
                                  nnimport
                                 );
         ELSE
            paso := 22;
            num_err :=
               f_recries (1,
                          psseguro,
                          reg_seg.cagente,
                          TRUNC (f_sysdate),
                          reg_seg.fcarpro,
                          ffcaranu,
                          9,
                          NULL,
                          NULL,
                          reg_seg.ccobban,
                          NULL,
                          NULL,
                          1,
                          'R',
                          v_cmodcom,
                          ffcaranu,
                          0,
                          pcmotmov,
                          NULL,
                          pnmovimi,
                          reg_seg.csituac,
                          nnimport
                         );
         END IF;

         --BUG9028-XVM-01102009 fi
         IF num_err <> 0
         THEN
            RETURN num_err;
         END IF;

         BEGIN
            /*
                      {buscamos el recibo creado}
            */
            paso := 23;

            BEGIN
               SELECT nrecibo, cdelega, fefecto, fvencim
                 -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186)
               INTO   nnrecibo, ccdelega, vfefecto, vfvencim
                 -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186)
               FROM   recibos
                WHERE sseguro = psseguro AND nmovimi = pnmovimi;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  -- BUG17025:DRA:22/12/2010:Inici
                  -- Si no se encuentra el recibo, puede ser que sea porque se ha borrado en el mismo
                  -- proceso f_recries por no tener detalle de recibo
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_anulacion.f_extorn_ventapte',
                               paso,
                                  'psseguro: '
                               || psseguro
                               || ' - pcmotmov: '
                               || pcmotmov
                               || ' - pnmovimi: '
                               || pnmovimi
                               || ' - pfanulac: '
                               || pfanulac,
                               SQLERRM
                              );
                  RETURN 0;
            -- BUG17025:DRA:22/12/2010:Fi
            END;

            paso := 24;

            /*
                         {borramos aquellos conceptos que no sean de venta}
              */
            DELETE      detrecibos
                  WHERE cconcep NOT IN (21, 71, 15, 16, 65, 66)
                    AND nrecibo = nnrecibo;

            paso := 25;

            /*
                         { Restauramos los totales del recibo}
            */
            -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
            DELETE FROM vdetrecibos_monpol
                  WHERE nrecibo = nnrecibo;

            -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
            DELETE      vdetrecibos
                  WHERE nrecibo = nnrecibo;

            paso := 26;
            num_err := f_vdetrecibos ('R', nnrecibo);

            -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186) - Inici
            -- IF num_err <> 0 THEN
            --   RETURN num_err;
            -- END IF;
            IF num_err = 0
            THEN
               num_err :=
                  pac_cesionesrea.f_cessio_det (vsproces,
                                                psseguro,
                                                nnrecibo,
                                                reg_seg.cactivi,
                                                reg_seg.cramo,
                                                reg_seg.cmodali,
                                                reg_seg.ctipseg,
                                                reg_seg.ccolect,
                                                vfefecto,
                                                vfvencim,
                                                1,
                                                vdecimals
                                               );
            ELSE
               RETURN num_err;
            END IF;

            -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186) - Fi

            /*
                         {Cambiamos el estado de recibo y su fecha de efecto}
            */
            paso := 3;

            UPDATE recibos
               SET cestimp = 0,
                   fefecto = pfanulac,
                   nperven = f_perventa (NULL, femisio, pfanulac, cempres)
             WHERE nrecibo = nnrecibo;

            --Despues de realizar los ajustes necesarios procedemos a  enviar el recibo a la ERP
            --Se a¿ade la llamada a los procesos de envio a ERP en el extrono de prima devengada, de momento
            --no se env¿an estos recibos a la ERP, pero se deja preparado.
            --Bug.: 20923 - 14/01/2012 - ICV
            IF     NVL (pac_parametros.f_parempresa_n (reg_seg.cempres,
                                                       'GESTIONA_COBPAG'
                                                      ),
                        0
                       ) = 1
               AND num_err = 0
            THEN
               num_err :=
                  pac_ctrl_env_recibos.f_proc_recpag_mov (reg_seg.cempres,
                                                          psseguro,
                                                          pnmovimi,
                                                          4,
                                                          NULL
                                                         );

               --Si ha dado error retornamos el error
               --De momento no retornamos el error
               /*
                           IF num_err <> 0 THEN
                 RETURN num_err;
               end if;*/
                  -- 71. MMM - 17/09/2013 - 0027879: LCOL_T020-Qtracker: 0008849: ERROR AL VISUALIZAR POLIZA ANULADA - NOTA 0152786 - Inicio
               FOR c IN (SELECT r.nrecibo, smovrec, cestrec, fmovini
                           FROM recibos r, movrecibo m
                          WHERE r.sseguro = psseguro
                            AND r.cempres = reg_seg.cempres
                            AND r.nmovimi = pnmovimi
                            AND r.nrecibo = m.nrecibo
                            AND m.fmovfin IS NULL
                            AND m.cestrec = 0
                            AND m.cestant = 0)
               LOOP
                  num_err :=
                     f_insctacoas (c.nrecibo,
                                   c.cestrec,
                                   reg_seg.cempres,
                                   c.smovrec,
                                   TRUNC (c.fmovini)
                                  );
               END LOOP;
            -- 71. MMM - 17/09/2013 - 0027879: LCOL_T020-Qtracker: 0008849: ERROR AL VISUALIZAR POLIZA ANULADA - NOTA 0152786 - Fin
            END IF;

            --Fi Bug.: 20923

            /*
                        {
             Cambiamos la fecha de pendiente del recibo y ponemos la posterior entre la fecha de anulacion
            y la del dia, y lo cobramo con esta fecha
            }
            */
            ffmovimi := GREATEST (TRUNC (f_sysdate), pfanulac);
            paso := 31;

            UPDATE movrecibo
               SET fmovini = ffmovimi
             WHERE nrecibo = nnrecibo;

            /*
                        { lo damos por cobrado }
            */
            paso := 4;
            num_err :=
               f_movrecibo (nnrecibo,
                            1,
                            NULL,
                            NULL,
                            ssmovrec,
                            nnliqmen,
                            nnliqlin,
                            ffmovimi,
                            NULL,
                            ccdelega,
                            NULL,
                            NULL
                           );

            IF num_err <> 0
            THEN
               RETURN num_err;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'pac_anulacion.f_extorn_ventapte',
                            paso,
                               'psseguro: '
                            || psseguro
                            || ' - pcmotmov: '
                            || pcmotmov
                            || ' - pnmovimi: '
                            || pnmovimi
                            || ' - pfanulac: '
                            || pfanulac,
                            SQLERRM
                           );
               RETURN 108288;
         --{ No se ha podido generar el recibo de ventas}
         END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_extorn_ventapte',
                      paso,
                      SQLERRM,
                      SQLERRM
                     );
         RETURN 140999;                                 --{Error no controlat}
   END f_extorn_ventapte;

   /***********************************************************************
                            Funcion que mira si se debe aplicar una reduccion (penalizacion) en la prima
     a extornar de los recibos en la anulacion
    1.   paplica_penali: Indica si se ha marcado (1) o no (0) el check 'Anulacion a corto plazo' (IN)
    2.   psseguro: Identificador del seguro (IN)
    3.   pnmovimi: Numero de movimiento (IN)
    4.   psproduc: Identificador del producto (IN)
    5.   pcconcep: Concepto del recibo a extornar (IN)
    6.   pnrecibo: Numero del recibo (IN)
    7.   pcgarant: C¿digo de la garantia (IN)
    8.   pnriesgo: Identificador del riesgo (IN)
    9.   pcmoneda: Codigo de la moneda (IN)
      return             : NUMBER (0 --> OK)
   ***********************************************************************/
   -- Bug 19557 - APD - 31/10/2011- se crea la funcion
   -- BUG 0020414 - 05/12/2011 - JMF: a¿adir pnfactor
   FUNCTION f_aplica_penali (
      paplica_penali   IN   NUMBER,
      psseguro         IN   NUMBER,
      pnmovimi         IN   NUMBER,
      psproduc         IN   NUMBER,
      pcconcep         IN   NUMBER,
      pnrecibo         IN   NUMBER,
      pcgarant         IN   NUMBER,
      pnriesgo         IN   NUMBER,
      pcmoneda         IN   NUMBER
   )
      RETURN NUMBER
   IS
      vtraza                NUMBER;
      vparam                VARCHAR2 (4000)
         :=    'paplica_penali = '
            || paplica_penali
            || '; psseguro = '
            || psseguro
            || '; pnmovimi = '
            || pnmovimi
            || '; psproduc = '
            || psproduc
            || '; pcconcep = '
            || pcconcep
            || '; pnrecibo = '
            || pnrecibo
            || '; pcgarant = '
            || pcgarant
            || '; pnriesgo = '
            || pnriesgo
            || '; pcmoneda = '
            || pcmoneda;
      num_err               NUMBER                    := 0;
      salir                 EXCEPTION;
      vcmotmov              movseguro.cmotmov%TYPE;
      v_nfactor             NUMBER;
      viconcep_0            detrecibos.iconcep%TYPE;
      --BUG 27048 - INICIO - DCT - 07/11/2013
      viconcep_8            detrecibos.iconcep%TYPE;
      v_calculo_iconcep_0   detrecibos.iconcep%TYPE;
      --BUG 27048 - FIN - DCT - 07/11/2013
   --vcont          NUMBER;
   BEGIN
      IF NVL (paplica_penali, 0) = 1
      THEN
         -- Se busca el motivo de movimiento de la anulacion
         SELECT cmotven                                              --cmotmov
           INTO vcmotmov
           FROM movseguro
          WHERE sseguro = psseguro AND nmovimi = pnmovimi;

         v_nfactor :=
            NVL (pac_parametros.f_parmotmov_n (vcmotmov,
                                               'PORC_PENALI_ANU',
                                               psproduc
                                              ),
                 0
                );

         IF     v_nfactor <> 0
            AND NVL
                   (pac_parametros.f_pargaranpro_n
                                     (psproduc,
                                      pac_seguros.ff_get_actividad (psseguro,
                                                                    pnriesgo
                                                                   ),
                                      pcgarant,
                                      'APLICA_PENALI_ANU'
                                     ),
                    1
                   ) = 1
         THEN
            -- a los conceptos (v.f.27) siguientes, no se les debe aplicar la reduccion (penalizacion):
            -- 14.-Gastos de expedici¿n (o Derechos de Registro)
            -- 86.-IVA - Gastos de expedici¿n (o Derechos de Registro)
            -- Bug 23074 - APD - 03/08/2012 - se a¿ade el cconcep = 86 (v.f. 27)
            IF pcconcep NOT IN (14, 86)
            THEN
               IF pcconcep = 0
               THEN
                  -- nos guardamos el valor el iconcep del concepto 0 antes de aplicarle la reduccion
                  -- para utilizarlo al insertar el concepto 85
                  SELECT iconcep
                    INTO viconcep_0
                    FROM detrecibos
                   WHERE nrecibo = pnrecibo
                     AND cconcep = pcconcep
                     AND cgarant = pcgarant
                     AND nriesgo = pnriesgo;
               END IF;

               IF pcconcep = 8
               THEN
                  -- nos guardamos el valor el iconcep del concepto 8 antes de aplicarle la reduccion
                  -- para utilizarlo al insertar el concepto 85
                  SELECT iconcep
                    INTO viconcep_8
                    FROM detrecibos
                   WHERE nrecibo = pnrecibo
                     AND cconcep = pcconcep
                     AND cgarant = pcgarant
                     AND nriesgo = pnriesgo;
               END IF;

               UPDATE detrecibos
                  SET iconcep =
                         f_round (iconcep - (iconcep * (v_nfactor / 100)),
                                  pcmoneda
                                 )
                WHERE nrecibo = pnrecibo
                  AND cconcep = pcconcep
                  AND cgarant = pcgarant
                  AND nriesgo = pnriesgo;
            END IF;

            -- v.f.27 - 85.-Reducci¿n Corto plazo
            -- Nos aseguramos que no exista el cconcep = 85 para volver a calcularlo
            -- (por si se ha anulado la poliza se ha vuelto a rehabilitar)
            IF pcconcep = 0
            THEN
               DELETE FROM detrecibos
                     WHERE nrecibo = pnrecibo
                       AND cconcep = 85
                       AND cgarant = pcgarant
                       AND nriesgo = pnriesgo;

               BEGIN
                  INSERT INTO detrecibos
                              (nrecibo, cconcep, cgarant, nriesgo,
                               iconcep
                              )
                       VALUES (pnrecibo, 85, pcgarant, pnriesgo,
                               f_round (viconcep_0 * (-1) * (v_nfactor / 100),
                                        pcmoneda
                                       )
                              );
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     num_err := 103513;   --{error al insertar en detrecibos}
                     RAISE salir;
               END;
            END IF;

            IF pcconcep = 8
            THEN
               --Recuperamos la cantidad de reducci¿n corto plazo para la prima neta (conecpto 0)
               SELECT iconcep
                 INTO v_calculo_iconcep_0
                 FROM detrecibos
                WHERE nrecibo = pnrecibo
                  AND cconcep = 85
                  AND cgarant = pcgarant
                  AND nriesgo = pnriesgo;

               --Sumamos la cantidad de reducci¿n corto plazo para la prima neta (conecpto 0) +
               --la reducci¿n corto plazo para el recargo de fraccionamiento (8)
               UPDATE detrecibos
                  SET iconcep =
                           f_round (viconcep_8 * (-1) * (v_nfactor / 100),
                                    pcmoneda
                                   )
                         + v_calculo_iconcep_0
                WHERE nrecibo = pnrecibo
                  AND cconcep = 85
                  AND cgarant = pcgarant
                  AND nriesgo = pnriesgo;
            END IF;
         END IF;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN salir
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_aplica_penali',
                      vtraza,
                      vparam,
                      f_axis_literales (num_err)
                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_aplica_penali',
                      vtraza,
                      vparam,
                      SQLERRM
                     );
         RETURN 1000455;                               -- Error no controlado.
   END f_aplica_penali;

   -- Bug 22826 - APD - 11/07/2012 - se a¿ade el parametro paplica_penali
   FUNCTION f_extorn_rec_cobrats (
      psseguro         IN   NUMBER,
      pcagente         IN   NUMBER,
      pnmovimi         IN   NUMBER,
      pfanulac         IN   DATE,
      pcmoneda         IN   NUMBER,
      prcob            IN   recibos_cob,
      paplica_penali   IN   NUMBER DEFAULT 0,
      pimpextorsion    IN   NUMBER DEFAULT 0,
      pnmovimiaux      IN   NUMBER DEFAULT NULL
   )                 -- 23183 14/12/2012  JDS  se a¿ade variable pimpextorsion
      RETURN NUMBER
   IS
      ffecextini       DATE;
      ffecextfin       DATE;
      num_err          NUMBER;
      nnrecibo         NUMBER;
      nnfactor         NUMBER;
      cccobban         NUMBER;
      ccdelega         NUMBER;
      cex_pdte_imp     NUMBER;
      nnpneta          NUMBER;
      nnpconsor        NUMBER;
      nnpdeven         NUMBER;
      ccvalpar         NUMBER;
      vfefecto         DATE;
      -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186)
      vfvencim         DATE;
      -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186)
      vdecimals        NUMBER;
      -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186)
      v_cmodcom        comisionprod.cmodcom%TYPE;
      --
      -- Inicio IAXIS-4926 23/10/2019
      --
      vnmovimirec      NUMBER; 
      vfmovdia         DATE;
      --
      -- Fin IAXIS-4926 23/10/2019
      --
      CURSOR rec_ext (pnrecibo IN NUMBER)
      IS
         SELECT   r.nrecibo, d.cconcep, d.cgarant, NVL (d.nriesgo, 1)
                                                                     nriesgo,
                  DECODE (ctiprec, 9, -d.iconcep, d.iconcep) iconcep,
                  d.fcambio
             FROM detrecibos d, recibos r, seguros s
            WHERE d.nrecibo = r.nrecibo
              AND d.cconcep NOT IN (21, 71, 15, 16, 65, 66, 2, 52)
              /*AND d.cconcep <>
                     DECODE
                        (pac_parametros.f_parproducto_n (s.sproduc,
                                                         'AFECTA_COMISESPPROD'
                                                        ),
                         1, 11,
                         -1
                        )      --rdd si esta activado la comiespecial entonces
              AND d.cconcep <>
                     DECODE
                        (pac_parametros.f_parproducto_n (s.sproduc,
                                                         'AFECTA_COMISESPPROD'
                                                        ),
                         1, 15,
                         -1
                        )                                                --rdd
              AND d.cconcep <>
                     DECODE
                        (pac_parametros.f_parproducto_n (s.sproduc,
                                                         'AFECTA_COMISESPPROD'
                                                        ),
                         1, 17,
                         -1
                        )                                                --rdd
              AND d.cconcep <>
                     DECODE
                        (pac_parametros.f_parproducto_n (s.sproduc,
                                                         'AFECTA_COMISESPPROD'
                                                        ),
                         1, 19,
                         -1
                        )                                                --rdd
              */
              AND r.sseguro = s.sseguro
              AND (       NVL (f_parproductos_v (s.sproduc, 'REC_SUP_PM'), 1) <>
                                                                             4
                      AND NOT (   (    NVL (f_pargaranpro_v (s.cramo,
                                                             s.cmodali,
                                                             s.ctipseg,
                                                             s.ccolect,
                                                             s.cactivi,
                                                             d.cgarant,
                                                             'REC_SUP_PM_GAR'
                                                            ),
                                            0
                                           ) = 1
                                   AND pfanulac <> s.fefecto
                                  )
                               OR (    NVL (f_pargaranpro_v (s.cramo,
                                                             s.cmodali,
                                                             s.ctipseg,
                                                             s.ccolect,
                                                             s.cactivi,
                                                             d.cgarant,
                                                             'REC_SUP_PM_GAR'
                                                            ),
                                            0
                                           ) = 2
                                   AND NVL
                                          (pac_preguntas.f_get_pregungaranseg_v
                                                                   (r.sseguro,
                                                                    d.cgarant,
                                                                    d.nriesgo,
                                                                    4045,
                                                                    NULL
                                                                   ),
                                           0
                                          ) = 1
                                  )
                              )
                   OR NVL (f_parproductos_v (s.sproduc, 'REC_SUP_PM'), 1) = 4
                  )
              AND r.nrecibo = pnrecibo
         ORDER BY d.cconcep ASC;

      CURSOR gar_venta (pnrecibo IN NUMBER)
      IS
         -- Bug 9685 - APD - 15/05/2009 - en lugar de coger la actividad de la tabla seguros,
         -- llamar a la funci¿n pac_seguros.ff_get_actividad
         SELECT DISTINCT cramo, cmodali, ctipseg, ccolect,
                         pac_seguros.ff_get_actividad
                                                     (s.sseguro,
                                                      NVL (d.nriesgo, 1)
                                                     ) cactivi,
                         cgarant
                    FROM recibos r, detrecibos d, seguros s
                   WHERE r.nrecibo = d.nrecibo
                     AND r.sseguro = s.sseguro
                     AND r.nrecibo = pnrecibo;

      --  85.0        18/05/2015  AQ               85. 0035775: Soporte cierres abril 2015
      CURSOR c_detrec
      IS
         SELECT DISTINCT cageven
                    FROM detrecibos dr, recibos r
                   WHERE r.nrecibo = dr.nrecibo
                     AND r.sseguro = psseguro
                     AND dr.cconcep = 17;

      xcempres         NUMBER;
      xcageven         NUMBER;
      -- Bug 9685 - APD - 15/05/2009 - fin
      v_sproces        NUMBER                      := 1;
      ximporx          NUMBER;
      reg_seg          seguros%ROWTYPE;
      v_nfactor        NUMBER;
      -- Bug 0022701 - 03/09/2012 - JMF
      v_retctiprec     recibos.ctiprec%TYPE;
      --------
      rcob             recibos_cob;            -- Bug 23817 - APD - 02/10/2012
      n_rec            NUMBER;                 -- Bug 23817 - APD - 02/10/2012
      vcont            NUMBER;                 -- Bug 23817 - APD - 02/10/2012
      rcob_unif        recibos_cob;            -- Bug 23817 - APD - 02/10/2012
      n_rec_unif       NUMBER;                 -- Bug 23817 - APD - 02/10/2012
      v_sseguro        seguros.sseguro%TYPE;   -- Bug 23817 - APD - 02/10/2012
      v_nmovimi        movseguro.nmovimi%TYPE; -- Bug 23817 - APD - 02/10/2012
      v_cagente        seguros.cagente%TYPE;   -- Bug 23817 - APD - 02/10/2012
      v_fefecto        recibos.fefecto%TYPE;   -- Bug 23817 - APD - 02/10/2012
      v_fvencim        recibos.fvencim%TYPE;   -- Bug 23817 - APD - 02/10/2012
      v_fmovini        movrecibo.fmovini%TYPE; -- Bug 23817 - APD - 02/10/2012
      -- Bug 26070 - RSC - 11/02/2013 - LCOL_T010-LCOL - Revision incidencias (modificaci¿n cursor)
      v_crespue_4092   pregunpolseg.crespue%TYPE;
      -- Fin Bug 26070

      -- Bug 27539 - RSC - 01/08/2013 - Anulaci¿n colectivos.
      vcctiprec        NUMBER;
      vcontrol         NUMBER;
      --BUG 0027048: - INICIO - DCT - 11/10/2013 - LCOL_T010-Revision incidencias qtracker (V)
      v_cprorra        productos.cprorra%TYPE;
      num_err1         NUMBER;
      num_err2         NUMBER;
      dias1            NUMBER;
      dias2            NUMBER;
      witotalr         NUMBER;
      -- BUG 37070/210785 : - Ini - JGR - 27/08/2015 - COLM - Revisar par¿metro "genera extorno"
      vsproduc         seguros.sseguro%TYPE;
         -- BUG 37070/210785 : - Fin - JGR - 27/08/2015 - COLM - Revisar par¿metro "genera extorno"
         --BUG 0027048: - FIN - DCT - 11/10/2013 - LCOL_T010-Revision incidencias qtracker (V)
      -- Fin Bug 27539
      vccobban         recibos.ccobban%TYPE;         -- Bug 37070 MMS 20150915
      vcagente         recibos.cagente%TYPE;         -- Bug 37070 MMS 20150915
      vsmovagr         movrecibo.smovagr%TYPE      := 0;
                                                     -- Bug 37070 MMS 20150915
      vnliqmen         NUMBER                      := NULL;
                                                     -- Bug 37070 MMS 20150915
      vnliqlin         NUMBER                      := NULL;
                                                     -- Bug 37070 MMS 20150915
      vfmovini         DATE;                         -- Bug 37070 MMS 20150915
      vestado          NUMBER;
      vpas             NUMBER;
      vexiste          NUMBER;

      TYPE rec_crea IS TABLE OF NUMBER
         INDEX BY PLS_INTEGER;

      t_rec_crea       rec_crea;
      vagente          seguros.cagente%TYPE;
      vcagente_anu     seguros.cagente%TYPE;
      fcamb            detrecibos.fcambio%TYPE;
   BEGIN
      -- Bug 23817 - APD - 02/10/2012 -
      -- De la lista de recibos cobrados, eliminados los recibos unificados
      -- ya que no se quiere realizar el extorno de estos recibos
      SELECT cempres
        INTO xcempres
        FROM empresas;

      rcob.DELETE;
      n_rec := 0;
      vpas := 1;

      IF prcob.FIRST IS NOT NULL
      THEN
         FOR i IN prcob.FIRST .. prcob.LAST
         LOOP
            SELECT COUNT (1)
              INTO vcont
              FROM adm_recunif a
             WHERE nrecunif = prcob (i).nrecibo
               AND nrecibo != prcob (i).nrecibo;

            -- BUG 37070/210785 : - Ini - JGR - 27/08/2015 - COLM - Revisar par¿metro "genera extorno"
            SELECT s.sproduc
              INTO vsproduc
              FROM seguros s
             WHERE sseguro = (SELECT r.sseguro
                                FROM recibos r
                               WHERE r.nrecibo = prcob (i).nrecibo);

            -- BUG 37070/210785 : - Fin - JGR - 27/08/2015 - COLM - Revisar par¿metro "genera extorno"

            -- el recibo no es unificado
            IF vcont = 0
            THEN
               -- BUG 37070/210785 : - Ini - JGR - 27/08/2015 - COLM - Revisar par¿metro "genera extorno"
               IF (NVL
                      (pac_parametros.f_parproducto_n (vsproduc,
                                                       'ANUL_EXTORN_REC_PEND'
                                                      ),
                       0
                      ) = 2
                  )
               THEN
                  IF (prcob (i).fefecto > pfanulac)
                  THEN
-- Inicio /////////////////////////////////////////////////////////
                     SELECT COUNT (1)
                       INTO vexiste
                       FROM adm_recunif a
                      WHERE nrecibo = prcob (i).nrecibo;

                     IF vexiste > 0
                     THEN          -- Es un recibo "agrupado" se debe extornar
                        n_rec := n_rec + 1;
                        rcob (n_rec).nrecibo := prcob (i).nrecibo;
                        rcob (n_rec).fmovini := prcob (i).fmovini;
                        rcob (n_rec).fefecto := prcob (i).fefecto;
                        rcob (n_rec).fvencim := prcob (i).fvencim;
                     ELSE
-- NO es un recibo "agrupado" -- Fin /////////////////////////////////////////////////////////
                        SELECT ccobban, cagente
                          INTO vccobban, vcagente
                          FROM recibos
                         WHERE nrecibo = prcob (i).nrecibo;
                                                     -- Bug 37070 MMS 20150915

                        SELECT fmovini
                          INTO vfmovini
                          FROM movrecibo
                         WHERE nrecibo = prcob (i).nrecibo AND fmovfin IS NULL;
                                                     -- Bug 37070 MMS 20150915

                        num_err :=
                           f_movrecibo (prcob (i).nrecibo,
                                        2,
                                        f_sysdate,
                                        2,
                                        vsmovagr,
                                        vnliqmen,
                                        vnliqlin,
                                        vfmovini,
                                        vccobban,
                                        NULL,
                                        NULL,
                                        vcagente
                                       );            -- Bug 37070 MMS 20150915

                        IF num_err <> 0
                        THEN
                           p_tab_error (f_sysdate,
                                        f_user,
                                        'pac_anulacion.f_extorn_rec_cobrats',
                                        972,
                                           'psseguro:'
                                        || psseguro
                                        || ' pnmovimi:'
                                        || pnmovimi
                                        || ' num_err='
                                        || num_err,
                                        SQLCODE || ' ' || SQLERRM
                                       );
                        END IF;
                     END IF;
                  ELSE
                     n_rec := n_rec + 1;
                     rcob (n_rec).nrecibo := prcob (i).nrecibo;
                     rcob (n_rec).fmovini := prcob (i).fmovini;
                     rcob (n_rec).fefecto := prcob (i).fefecto;
                     rcob (n_rec).fvencim := prcob (i).fvencim;
                  END IF;
               ELSE
                  n_rec := n_rec + 1;
                  rcob (n_rec).nrecibo := prcob (i).nrecibo;
                  rcob (n_rec).fmovini := prcob (i).fmovini;
                  rcob (n_rec).fefecto := prcob (i).fefecto;
                  rcob (n_rec).fvencim := prcob (i).fvencim;
               END IF;
            -- BUG 37070/210785 : - Fin - JGR - 27/08/2015 - COLM - Revisar par¿metro "genera extorno"
            ELSE
               -- si el recibo es unificado se debe realizar el extorno de todos
               -- los recibos cobrados que cuelgan de ¿l
               -- BUG 37070/210785 : - Ini - JGR - 31/08/2015 - COLM - Revisar par¿metro "genera extorno"
               -- IF (NVL(pac_parametros.f_parproducto_n(vsproduc, 'ANUL_EXTORN_REC_PEND'), 0) IN (0, 1)) THEN
                  -- BUG 37070/210785 : - Fin - JGR - 31/08/2015 - COLM - Revisar par¿metro "genera extorno"
               FOR reg IN (SELECT nrecibo
                             FROM adm_recunif a
                            WHERE nrecunif = prcob (i).nrecibo
                              AND nrecibo != prcob (i).nrecibo)
               LOOP
                  rcob_unif.DELETE;
                  n_rec_unif := 0;
                  vpas := 2;

                  BEGIN
                     -- se deben tratar los recibos de las polizas que se est¿n
                     -- tratando al anular el certificado 0, es decir, las
                     -- polizas que estan en detmovsegurocol para el certificado 0
                     -- Bug 27539/148870 - APD - 11/07/2013 - se a¿ade la UNION para
                     -- buscar los recibos propios del certificado 0
                     SELECT a.sseguro, a.cagente, a.fefecto, a.fvencim,
                            a.fmovini
                       INTO v_sseguro, v_cagente, v_fefecto, v_fvencim,
                            v_fmovini
                       FROM (SELECT r.sseguro, s.cagente, r.fefecto,
                                    r.fvencim, m.fmovini
                               FROM recibos r,
                                    movrecibo m,
                                    seguros s,
                                    movseguro ms,
                                    detmovsegurocol d
                              WHERE r.sseguro = s.sseguro
                                AND s.sseguro = ms.sseguro
                                -- Bug 27539/149936 - APD -26/07/2013 - mismo tratamiento
                                -- que en la funcion pac_anulacion.f_recibos
                                AND (   m.cestrec IN (1, 3)
                                     OR (    m.cestrec = 0
                                         AND (   (    pac_adm_cobparcial.f_get_importe_cobro_parcial
                                                                   (r.nrecibo,
                                                                    NULL,
                                                                    NULL
                                                                   ) > 0
                                                  AND NVL
                                                         (pac_parametros.f_parempresa_t
                                                             (s.cempres,
                                                              'NO_EXTORN_COB_PARC'
                                                             ),
                                                          0
                                                         ) = 0
                                                 --JAMF  33921  17/12/2014
                                                 )
                                              OR NVL
                                                    (pac_parametros.f_parproducto_n
                                                        ((SELECT sproduc
                                                            FROM seguros s
                                                           WHERE s.sseguro =
                                                                     r.sseguro),
                                                         'ANUL_EXTORN_REC_PEND'
                                                        ),
                                                     0
                                                    ) = 1
                                             )
                                        )
                                    )
                                -- fin Bug 27539/149936 - APD -26/07/2013
                                AND r.nrecibo = m.nrecibo
                                AND m.fmovfin IS NULL
                                AND r.nrecibo = reg.nrecibo
                                -- Bug 30448/169686 - APD - 14/03/2014
                                AND r.fvencim > pfanulac
                                -- fin Bug 30448/169686 - APD - 14/03/2014
                                AND d.sseguro_cert = s.sseguro
                                AND ms.nmovimi = d.nmovimi_cert
                                AND 3 =
                                       (SELECT cmovseg
                                          FROM movseguro ms2
                                         WHERE ms2.sseguro = d.sseguro_0
                                           AND ms2.nmovimi = d.nmovimi_0)
                                               -- El recibo es de la anulaci¿n
                             /*AND d.nmovimi_0 IN NVL(pnmovimiaux,
                                                    (SELECT ms2.nmovimi
                                                       FROM movseguro ms2
                                                      WHERE ms2.sseguro = d.sseguro_0
                                                        AND ms2.cmotmov = 345
                                                        AND ms2.cmovseg = 3
                                                        AND ms2.nmovimi >
                                                              (SELECT MAX(ms3.nmovimi)
                                                                 FROM movseguro ms3
                                                                WHERE ms3.sseguro = ms2.sseguro
                                                                  AND ms3.cmovseg IN(0, 4))));*/
                             UNION
                             SELECT r.sseguro, s.cagente, r.fefecto,
                                    r.fvencim, m.fmovini
                               FROM recibos r,
                                    movrecibo m,
                                    seguros s,
                                    movseguro ms,
                                    detmovsegurocol d
                              WHERE r.sseguro = s.sseguro
                                AND s.sseguro = ms.sseguro
                                -- Bug 27539/149936 - APD -26/07/2013 - mismo tratamiento
                                -- que en la funcion pac_anulacion.f_recibos
                                AND (   m.cestrec IN (1, 3)
                                     OR (    m.cestrec = 0
                                         AND (   (    pac_adm_cobparcial.f_get_importe_cobro_parcial
                                                                   (r.nrecibo,
                                                                    NULL,
                                                                    NULL
                                                                   ) > 0
                                                  AND NVL
                                                         (pac_parametros.f_parempresa_t
                                                             (s.cempres,
                                                              'NO_EXTORN_COB_PARC'
                                                             ),
                                                          0
                                                         ) = 0
                                                 --JAMF  33921  17/12/2014
                                                 )
                                              OR NVL
                                                    (pac_parametros.f_parproducto_n
                                                        ((SELECT sproduc
                                                            FROM seguros s
                                                           WHERE s.sseguro =
                                                                     r.sseguro),
                                                         'ANUL_EXTORN_REC_PEND'
                                                        ),
                                                     0
                                                    ) = 1
                                             )
                                        )
                                    )
                                -- fin Bug 27539/149936 - APD -26/07/2013
                                AND r.nrecibo = m.nrecibo
                                AND m.fmovfin IS NULL
                                AND r.nrecibo = reg.nrecibo
                                -- Bug 30448/169686 - APD - 14/03/2014
                                AND r.fvencim > pfanulac
                                -- fin Bug 30448/169686 - APD - 14/03/2014
                                AND d.sseguro_0 = s.sseguro
                                AND ms.nmovimi = d.nmovimi_0
                                AND 3 =
                                       (SELECT cmovseg
                                          FROM movseguro ms2
                                         WHERE ms2.sseguro = d.sseguro_0
                                           AND ms2.nmovimi = d.nmovimi_0)) a;
                  -- fin Bug 27539/148870 - APD - 11/07/2013
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        v_sseguro := NULL;
                  END;

                  vpas := 3;

                  IF v_sseguro IS NOT NULL
                  THEN
                     SELECT MAX (nmovimi)
                       INTO v_nmovimi
                       FROM movseguro
                      WHERE sseguro = v_sseguro;

                     n_rec_unif := n_rec_unif + 1;
                     rcob_unif (n_rec_unif).nrecibo := reg.nrecibo;
                     rcob_unif (n_rec_unif).fmovini := v_fmovini;
                     rcob_unif (n_rec_unif).fefecto := v_fefecto;
                     rcob_unif (n_rec_unif).fvencim := v_fvencim;
                     num_err :=
                        f_extorn_rec_cobrats (v_sseguro,
                                              v_cagente,
                                              v_nmovimi,
                                              pfanulac,
                                              pcmoneda,
                                              rcob_unif,
                                              paplica_penali,
                                              pimpextorsion
                                             );

                     -- 23183 14/12/2012  JDS  se a¿ade variable pimpextorsion
                     IF num_err <> 0
                     THEN
                        RETURN num_err;
                     END IF;
                  END IF;
               END LOOP;
            -- END IF;   -- BUG 37070/210785 : - Fin - JGR - 31/08/2015 - Cierro if
            END IF;
         END LOOP;
      END IF;

      vpas := 4;

      -- fin Bug 23817 - APD - 02/10/2012
      SELECT *
        INTO reg_seg
        FROM seguros
       WHERE sseguro = psseguro;

      vpas := 5;

      -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186) - Inici
      BEGIN
         SELECT   -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                  --DECODE(cdivisa, 2, 2, 3, 1, 0)
                pac_monedas.f_moneda_producto (sproduc), cprorra
           -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
         INTO   vdecimals, v_cprorra
           FROM productos
          WHERE cramo = reg_seg.cramo
            AND cmodali = reg_seg.cmodali
            AND ctipseg = reg_seg.ctipseg
            AND ccolect = reg_seg.ccolect;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 104347;                  -- Producte no trobat a PRODUCTOS
         WHEN OTHERS
         THEN
            RETURN 102705;                    -- Error al llegir de PRODUCTOS
      END;

      vpas := 6;

      -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186) - Fi
      -- BUG 28046_0153741 - JLTS - 2013/09/26 adiciona el IN (1, 4)
      IF     NVL (f_parproductos_v (reg_seg.sproduc, 'REC_SUP_PM'), 0) = 1
         AND pfanulac <> reg_seg.fefecto
      THEN
         -- si se debe generar un recibo de diferencia de provisi¿n
         IF f_es_renovacion (psseguro) = 0
         THEN                                                   -- es cartera
            v_cmodcom := 2;
         ELSE                                   -- si es 1 es nueva produccion
            v_cmodcom := 1;
         END IF;

         vpas := 7;

         --BUG9028-XVM-01102009 inici
         IF NVL (pac_parametros.f_parinstalacion_n ('CALCULO_RECIBO'), 1) = 0
         THEN
            -- Bug 14775 - RSC - 13/08/2010 - AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
            num_err :=
               pac_adm.f_recries (reg_seg.ctipreb,
                                  psseguro,
                                  reg_seg.cagente,
                                  f_sysdate,
                                  pfanulac,
                                  NVL (reg_seg.fvencim, pfanulac),
                                  9,
                                  NULL,
                                  NULL,
                                  reg_seg.ccobban,
                                  NULL,
                                  v_sproces,
                                  11,
                                  'R',
                                  v_cmodcom,
                                  reg_seg.fcaranu,
                                  0,
                                  NULL,
                                  reg_seg.cempres,
                                  pnmovimi,
                                  NULL,
                                  ximporx,
                                  NULL
                                 );
         ELSE
            num_err :=
               f_recries (reg_seg.ctipreb,
                          psseguro,
                          reg_seg.cagente,
                          f_sysdate,
                          pfanulac,
                          NVL (reg_seg.fvencim, pfanulac),
                          9,
                          NULL,
                          NULL,
                          reg_seg.ccobban,
                          NULL,
                          v_sproces,
                          11,
                          'R',
                          v_cmodcom,
                          reg_seg.fcaranu,
                          0,
                          NULL,
                          reg_seg.cempres,
                          pnmovimi,
                          NULL,
                          ximporx,
                          NULL
                         );
         END IF;

         vpas := 8;

         -- BUG24802:DRA:20/11/2012:Inici
         IF pac_corretaje.f_tiene_corretaje (psseguro, NULL) = 1
         THEN
            --num_err := pac_corretaje.f_gen_comision_corr(psseguro, pnmovimi, NULL);
            num_err :=
                 pac_corretaje.f_reparto_corretaje (psseguro, pnmovimi, NULL);

            IF num_err <> 0
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'pac_anulacion.f_extorn_rec_cobrats',
                            971,
                               'psseguro:'
                            || psseguro
                            || ' pnmovimi:'
                            || pnmovimi
                            || ' num_err='
                            || num_err,
                            f_axis_literales (num_err, f_usu_idioma)
                           );
               RETURN num_err;
            END IF;
         END IF;

         -- BUG24802:DRA:20/11/2012:Fi
         vpas := 9;

         -- ini Bug 0022701 - 03/09/2012 - JMF
         IF pac_retorno.f_tiene_retorno (NULL, psseguro, NULL) = 1
         THEN
            num_err :=
               pac_retorno.f_generar_retorno (psseguro, pnmovimi, NULL, NULL);

            IF num_err <> 0
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'pac_anulacion.f_extorn_rec_cobrats',
                            972,
                               'psseguro:'
                            || psseguro
                            || ' pnmovimi:'
                            || pnmovimi
                            || ' num_err='
                            || num_err,
                            SQLCODE || ' ' || SQLERRM
                           );
               RETURN num_err;
            END IF;
         END IF;

         -- fin Bug 0022701 - 03/09/2012 - JMF

         --Despues de realizar los ajustes necesarios procedemos a  enviar el recibo a la ERP
         --Se a¿ade la llamada a los procesos de envio a ERP en el extrono de prima devengada, de momento
         --no se env¿an estos recibos a la ERP, pero se deja preparado.
         --Bug.: 20923 - 14/01/2012 - ICV
         IF     NVL (pac_parametros.f_parempresa_n (reg_seg.cempres,
                                                    'GESTIONA_COBPAG'
                                                   ),
                     0
                    ) = 1
            AND num_err = 0
         THEN
            num_err :=
               pac_ctrl_env_recibos.f_proc_recpag_mov (reg_seg.cempres,
                                                       psseguro,
                                                       pnmovimi,
                                                       4,
                                                       NULL
                                                      );
            vpas := 10;

            --Si ha dado error retornamos el error
            --De momento no retornamos el error
            -- 71. MMM - 17/09/2013 - 0027879: LCOL_T020-Qtracker: 0008849: ERROR AL VISUALIZAR POLIZA ANULADA - NOTA 0152786 - Inicio
            FOR c IN (SELECT r.nrecibo, smovrec, cestrec, fmovini
                        FROM recibos r, movrecibo m
                       WHERE r.sseguro = psseguro
                         AND r.cempres = reg_seg.cempres
                         AND r.nmovimi = pnmovimi
                         AND r.nrecibo = m.nrecibo
                         AND m.fmovfin IS NULL
                         AND m.cestrec = 0
                         AND m.cestant = 0)
            LOOP
               num_err :=
                  f_insctacoas (c.nrecibo,
                                c.cestrec,
                                reg_seg.cempres,
                                c.smovrec,
                                TRUNC (c.fmovini)
                               );
            END LOOP;
         -- 71. MMM - 17/09/2013 - 0027879: LCOL_T020-Qtracker: 0008849: ERROR AL VISUALIZAR POLIZA ANULADA - NOTA 0152786 - Fin
         END IF;

         --Fi Bug.: 20923

         --BUG9028-XVM-01102009 fi
         RETURN num_err;
      ELSE
         /*
                  {Extornamos los recibos cobrados que nos pasan en el parametro rcob}
         */
         vpas := 11;

         IF rcob.FIRST IS NOT NULL
         THEN
            FOR i IN rcob.FIRST .. rcob.LAST
            LOOP
               /*
                            {buscamos la minima fecha de efecto y la m¿xima fecha de vencimiento}
                   */
               IF ffecextini IS NULL OR ffecextini > rcob (i).fefecto
               THEN
                  ffecextini := rcob (i).fefecto;
               END IF;

               IF ffecextfin IS NULL OR ffecextfin < rcob (i).fvencim
               THEN
                  ffecextfin := rcob (i).fvencim;
               END IF;
            END LOOP;
         END IF;

         /*
                         {si se anula desde la mitad de un perido}
         */
         IF ffecextini < pfanulac
         THEN
            -- Bug 0021289 - FAL- 08/02/2012
            -- ffecextfin := pfanulac;
            ffecextini := pfanulac;
         -- Fi Bug 0021289
         END IF;

         /*
                   {
           Marcamos un punto, por si el detalle de recibo no tiene los conceptos 0,2,50,52,21,71
          lo tiramos todo hacia atr¿s, pero solo hasta aqu¿. No es un error.
          }
         */
         vpas := 12;
         SAVEPOINT recibos_extorno;
         -- Bug 27539 - RSC - 01/08/2013 - Anulaci¿n colectivos.
         -- Bug 26070 - RSC - 11/02/2013 - LCOL_T010-LCOL - Revision incidencias (modificaci¿n cursor)
         num_err :=
            pac_preguntas.f_get_pregunpolseg (psseguro,
                                              4092,
                                              'SEG',
                                              v_crespue_4092
                                             );

         -- Fin Bug 26070
         -- Fin Bug 27539

         /*
                  { Si hab¿a recibos cobrados se devolver¿n aquellos que est¿n enteros y se prorratear¿
          si se devuelve parcialmente alg¿n recibo.}
         */
         IF rcob.FIRST IS NOT NULL
         THEN
            FOR i IN rcob.FIRST .. rcob.LAST
            LOOP
               -- ini Bug 0022701 - 03/09/2012 - JMF
               SELECT   MAX (ctiprec), cagente
                   INTO v_retctiprec, vcagente_anu
                   FROM recibos
                  WHERE nrecibo = rcob (i).nrecibo
               GROUP BY cagente;

               vpas := 13;

               -- Los recibos de retorno los tratamos aparte.
               IF v_retctiprec NOT IN (13, 15)
               THEN
                  -- fin Bug 0022701 - 03/09/2012 - JMF
                  IF    i = 1
                     OR f_parproductos_v (reg_seg.sproduc, 'REC_ANUL_REC_EXT') =
                                                                             1
                  THEN
                     DECLARE
                        -- 0011652 A¿adir tipo certificado cero o no.
                        v_tipocert   VARCHAR2 (20);
                     BEGIN
                        -- 0011652 A¿adir tipo certificado cero o no.
                        SELECT MAX (DECODE (esccero, 1, 'CERTIF0', NULL))
                          INTO v_tipocert
                          FROM recibos
                         WHERE nrecibo = rcob (i).nrecibo;

                        --                         {Creamos el recibo de extorno de primas}
                        vpas := 14;

                        -- Bug 27539 - RSC - 01/08/2013 - Anulaci¿n colectivos.
                        IF     NVL (f_parproductos_v (reg_seg.sproduc,
                                                      'ADMITE_CERTIFICADOS'
                                                     ),
                                    0
                                   ) = 1
                           AND NVL (f_parproductos_v (reg_seg.sproduc,
                                                      'RECUNIF'
                                                     ),
                                    0
                                   ) = 1
                           AND v_crespue_4092 = 1
                        THEN
                           IF v_retctiprec = 9
                           THEN
                              vcctiprec := 1;
                           ELSE
                              vcctiprec := 9;
                           END IF;
                        ELSE
                          --
                          -- Inicio IAXIS-4926 23/10/2019
                          -- Por convención de SAP para recibos cobrados:
                          -- Para un recibo de tipo extorno (tipo 9) se generará un recibo de tipo suplemento (tipo 1)
                          -- Para un recibo de tipo suplemento (tipo 1) se generará un recibo de tipo extorno (tipo 9)
                          --
                          IF v_retctiprec = 9 
                          THEN
                            vcctiprec := 1;
                          ELSE
                            vcctiprec := 9;
                          END IF;
                          --
                          -- Fin IAXIS-4926 23/10/2019
                          --  
                        END IF;

                        nnrecibo := NULL;

                        IF f_parproductos_v (reg_seg.sproduc,
                                             'REC_ANUL_REC_EXT'
                                            ) = 1
                        THEN
                           ffecextfin := rcob (i).fvencim;
                           vagente := vcagente_anu;
                        ELSE
                           vagente := pcagente;
                        END IF;

                        -- Fin Bug 27539
                        --
                        -- Inicio IAXIS-4926 23/10/2019
                        -- Recuperamos el número de movimiento del recibo recaudado. La idea es poder generar el nuevo recibo de compensación 
                        -- (tipo extorno o tipo suplemento) con el MISMO NÚMERO DE MOVIMIENTO que el recibo a partir del cual se está generando. 
                        -- Esto se realiza a petición de SAP.
                        --
                        SELECT r.nmovimi 
                          INTO vnmovimirec
                          FROM recibos r
                         WHERE r.nrecibo = rcob (i).nrecibo;
                        --
                        -- Fin IAXIS-4926 23/10/2019
                        --
                        -- 0011652 A¿adir tipo certificado cero o no.
                        num_err :=
                           f_insrecibo (psseguro,
                                        vagente,
                                        f_sysdate,
                                        ffecextini,
                                        ffecextfin,
                                        vcctiprec,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        nnrecibo,
                                        'R',
                                        NULL,
                                        NULL,
                                        NVL(vnmovimirec,pnmovimi), -- IAXIS-4926 23/10/2019
                                        f_sysdate,
                                        v_tipocert,
                                        pcsubtiprec => 17); -- IAXIS-7627 18/11/2019

                        --                                {El error 103108 , es un error controlado se genera el recibo}
                        IF num_err NOT IN (0, 103108)
                        THEN
                           RETURN num_err;
                        END IF;

                        t_rec_crea (i) := nnrecibo;
                        --
                        -- Inicio IAXIS-4926 23/10/2019
                        --
                        -- Guardamos la relación del recibo tratado y su correspondiente recibo generado de compensación (sea de extorno o suplemento) 
                        -- a fin de persistir dicha relación y tomarla como referencia para futuros procesos. Por el momento, se usará para realizar 
                        -- una copia de la información de la tabla COMRECIBO desde el recibo tratado hacia el recibo generado por compensación durante
                        -- la anulación. Usamos la tabla de recibos clonados para evitar la creación de una nueva tabla, pues a fin de cuentas, es un 
                        -- recibo idéntico pero de tipo diferente.
                        BEGIN
                          INSERT INTO recibosclon
                               (sseguro, nreciboant, nreciboact, frecclon, corigen)
                          VALUES 
                               (psseguro, rcob(i).nrecibo, nnrecibo, f_sysdate, 2);
                        END;
                        --
                        -- Fin IAXIS-4926 23/10/2019
                        --
                        vpas := 15;

                        --                         {Buscamos el nrecibo que hemos creado}
                        BEGIN
                           SELECT MAX (nrecibo), MAX (cdelega)
                             INTO nnrecibo, ccdelega
                             FROM recibos
                            WHERE sseguro = psseguro AND nmovimi = NVL(vnmovimirec, pnmovimi); -- IAXIS-4926 23/10/2019
                        END;

                        vpas := 16;

                        --                        {evaluamos el estado de impresi¿n}
                        BEGIN
                           SELECT ccobban
                             INTO cccobban
                             FROM seguros
                            WHERE sseguro = psseguro;
                        END;

                        vpas := 17;

                        IF cccobban IS NOT NULL
                        THEN
                           cex_pdte_imp :=
                                   NVL (f_parinstalacion_n ('EX_PTE_IMP'), 0);
                        END IF;

                        IF cex_pdte_imp = 0
                        THEN
                           UPDATE recibos
                              SET cestimp = 7
                            WHERE nrecibo = nnrecibo;
                        END IF;

                        vpas := 18;

                        --                        {borramos todos los conceptos}
                        DELETE      detrecibos
                              WHERE nrecibo = nnrecibo;

                        IF v_crespue_4092 = 1 AND num_err = 0
                        THEN
                           UPDATE recibos
                              SET cestaux = 2
                            WHERE nrecibo = nnrecibo;
                        ELSE
                           UPDATE recibos
                              SET cestaux = 0
                            WHERE nrecibo = nnrecibo;
                        END IF;
                     -- Fin Bug 26070
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           RETURN 105156;
                     END;
                  END IF;

                  vpas := 19;

                  --                         {Miramos si hay que proratear o incoporar}
                  -- Bug 27524 - 02-VII-2013 - dlF - Error al calcular el extorno de una p¿liza de sobreprecio
                  -- Al ANULAR una POLIZA.
                  -- Los productos de sobreprecio de AGM no prorratean.
                  IF NVL (f_parproductos_v (reg_seg.sproduc,
                                            'NO_PRORRATEO_SUPLEM'
                                           ),
                          0
                         ) = 1
                  THEN
                     nnfactor := 1;
                  ELSE
                     IF rcob (i).fefecto < pfanulac
                     THEN
                        --BUG 0027048: - INICIO - DCT - 11/10/2013 - LCOL_T010-Revision incidencias qtracker (V)
                        IF v_cprorra = 2
                        THEN
                           num_err1 :=
                              f_difdata (pfanulac,
                                         rcob (i).fvencim,
                                         3,
                                         3,
                                         dias1
                                        );

                           IF num_err1 <> 0
                           THEN
                              p_tab_error
                                       (f_sysdate,
                                        f_user,
                                        'pac_anulacion.f_extorn_rec_cobrats',
                                        1000,
                                        'dias1:' || dias1,
                                        num_err
                                       );
                              RETURN num_err1;
                           END IF;

                           num_err2 :=
                              f_difdata (rcob (i).fefecto,
                                         rcob (i).fvencim,
                                         3,
                                         3,
                                         dias2
                                        );

                           IF num_err2 <> 0
                           THEN
                              p_tab_error
                                       (f_sysdate,
                                        f_user,
                                        'pac_anulacion.f_extorn_rec_cobrats',
                                        1001,
                                        'dias2:' || dias2,
                                        num_err2
                                       );
                              RETURN num_err2;
                           END IF;

                           nnfactor := dias1 / dias2;
                        ELSE
                           nnfactor :=
                                (rcob (i).fvencim - pfanulac)
                              / (rcob (i).fvencim - rcob (i).fefecto);
                        END IF;
                     --BUG 0027048: - FIN - DCT - 11/10/2013 - LCOL_T010-Revision incidencias qtracker (V)
                     ELSE
                        nnfactor := 1;
                     END IF;
                  END IF;

                  vpas := 20;

                  -- fin Bug 27524 - 02-VII-2013 - dlF

                  -- {recuperamos y grabamos los conceptos de los recibos a extornar}
                  FOR c IN rec_ext (rcob (i).nrecibo)
                  LOOP
                     -- Bug 19557 - APD - 31/10/2011 -  funcion para determinar si se debe
                     -- realizar o no el retorno de un recibo a extornar

                     -- Bug 27539 - RSC - 01/08/2013 - Anulaci¿n colectivos.
--                     IF f_cestrec_mv(rcob(i).nrecibo, 2) = 0 THEN   -- Si esta pendiente los gastos se deben retornar
--                        num_err := 0;
--                        v_nfactor := 1;
--                     ELSE
                        -- Fin bug 27539

                     -- BUG 0020414 - 05/12/2011 - JMF: a¿adir factor
                     v_nfactor := nnfactor;
                     num_err :=
                        pac_anulacion.f_concep_retorna_anul (psseguro,
                                                             pnmovimi,
                                                             reg_seg.sproduc,
                                                             c.cconcep,
                                                             pfanulac,
                                                             -- BUG 19557 - 22/11/2011 - JMP - LCOL_T001-Despeses expedici¿
                                                             v_nfactor
                                                            );

                     -- Bug 27539 - RSC - 01/08/2013 - Anulaci¿n colectivos.
--                     END IF;

                     -- Fin Bug 27539

                     --  {El error 1 , es un error controlado}
                     IF num_err NOT IN (0, 1)
                     THEN
                        RETURN num_err;
                     END IF;

                     -- Bug 19557 - APD - 28/10/2011 - se a¿ade la condicion IF
                     -- si el error 0, se debe insertar en detrecibos (si se debe realizar el extorno)
                     -- si el error 1, NO se debe insetar en detrecibos (NO se retorna el recibo)
                     IF num_err = 0
                     THEN
                        BEGIN
                           --  85.0        18/05/2015  AQ               85. 0035775: Soporte cierres abril 2015
                           --IF xcempres = 16 THEN   -- SI es RSA
                           -- 38020.NMM
                           IF NVL
                                 (pac_parametros.f_parempresa_n (k_cempresa,
                                                                 'AGENT_VENTA'
                                                                ),
                                  0
                                 ) = 1
                           THEN
                              FOR rdr IN c_detrec
                              LOOP
                                 xcageven := rdr.cageven;
                              END LOOP;
                           END IF;

                           IF f_parproductos_v (reg_seg.sproduc,
                                                'REC_ANUL_REC_EXT'
                                               ) = 1
                           THEN
                              fcamb := c.fcambio;
                           ELSE
                              fcamb := NULL;
                           END IF;

                           INSERT INTO detrecibos
                                       (nrecibo, cconcep, cgarant,
                                        nriesgo,
                                        iconcep,
                                        cageven, fcambio
                                       )
                                VALUES (nnrecibo, c.cconcep, c.cgarant,
                                        c.nriesgo,
                                        f_round (c.iconcep * v_nfactor,
                                                 pcmoneda
                                                ),
                                        xcageven, fcamb
                                       );
                        --FI --  85.0        18/05/2015  AQ               85. 0035775: Soporte cierres abril 2015
                        EXCEPTION
                           WHEN DUP_VAL_ON_INDEX
                           THEN
                              BEGIN
                                 UPDATE detrecibos
                                    SET iconcep =
                                             iconcep
                                           + f_round (c.iconcep * v_nfactor,
                                                      pcmoneda
                                                     ),
                                        cageven = xcageven,
                                        fcambio = fcamb
--85.0        18/05/2015  AQ               85. 0035775: Soporte cierres abril 2015
                                 WHERE  nrecibo = nnrecibo
                                    AND cconcep = c.cconcep
                                    AND cgarant = c.cgarant
                                    AND nriesgo = c.nriesgo;
                              EXCEPTION
                                 WHEN OTHERS
                                 THEN
                                    RETURN 104377;
                              --{ error al modificar recibos}
                              END;
                           WHEN OTHERS
                           THEN
                              RETURN 103513;
                        --{error al insertar en detrecibos}
                        END;
                     END IF;
                  -- fin Bug 19557 - APD - 28/10/2011 - se a¿ade la condicion IF
                  END LOOP;
               END IF;
            -- fin Bug 0022701 - 03/09/2012 - JMF
            END LOOP;
         END IF;

         vpas := 21;

         IF t_rec_crea.FIRST IS NOT NULL
         THEN
            FOR i IN t_rec_crea.FIRST .. t_rec_crea.LAST
            LOOP
               --BUG 27048 - INICIO - DCT - 07/11/2013
               FOR c IN rec_ext (t_rec_crea (i))
               LOOP
                  -- Bug 22826 - APD - 11/07/2012 - se a¿ade la llamada a f_aplica_penali
                  -- para que aplique la reduccion (penalizacion) en la prima a extornar
                  num_err :=
                     pac_anulacion.f_aplica_penali (paplica_penali,
                                                    psseguro,
                                                    pnmovimi,
                                                    reg_seg.sproduc,
                                                    c.cconcep,
                                                    t_rec_crea (i),
                                                    c.cgarant,
                                                    c.nriesgo,
                                                    pcmoneda
                                                   );

                  IF num_err <> 0
                  THEN
                     RETURN num_err;
                  END IF;
               -- fin Bug 22826 - APD - 11/07/2012
               END LOOP;

               --BUG 27048 - FIN - DCT - 07/11/2013
               IF t_rec_crea (i) IS NOT NULL
               THEN                      -- bug 19451/92191 - 13/09/2011 - AMC
                  -- Bug 27539 - RSC - 01/08/2013 - Anulaci¿n colectivos.
                  UPDATE detrecibos
                     SET iconcep = ABS (iconcep)
                   WHERE nrecibo = t_rec_crea (i);

                  -- Fin bug 27539

                  -- {Calculamos el consorcio}
                  num_err :=
                     f_consoranul (psseguro,
                                   pfanulac,
                                   t_rec_crea (i),
                                   pcmoneda
                                  );

                  IF num_err <> 0
                  THEN
                     RETURN num_err;
                  END IF;

                  vpas := 22;

                  --             {Miramos si el recibo no tiene importe}
                  SELECT COUNT (DECODE (cconcep, 0, 'a', 50, 'a', NULL)),
                         --{num. registros prima neta}
                         COUNT (DECODE (cconcep, 2, 'a', 52, 'a', NULL)),
                         --{num. registros consoricio}
                         COUNT (DECODE (cconcep, 21, 'a', 71, 'a', NULL))
                    --{num. registros prima devengada}
                  INTO   nnpneta,
                         nnpconsor,
                         nnpdeven
                    FROM detrecibos
                   WHERE nrecibo = t_rec_crea (i)
                     AND cconcep IN (0, 50, 2, 52, 21, 71);

                  -- RSC 01/08/2013 - Los gastos no los est¿ teniendo en cuenta por esto!!!
                  vpas := 23;
                  -- Bug 27539 - RSC - 01/08/2013 - Anulaci¿n colectivos.
                  vcontrol := 0;

                  IF     NVL (f_parproductos_v (reg_seg.sproduc,
                                                'ADMITE_CERTIFICADOS'
                                               ),
                              0
                             ) = 1
                     AND NVL (f_parproductos_v (reg_seg.sproduc, 'RECUNIF'),
                              0) = 1
                     AND v_crespue_4092 = 1
                  THEN
                     SELECT COUNT (*)
                       INTO vcontrol
                       FROM detrecibos
                      WHERE nrecibo = t_rec_crea (i) AND cconcep = 14;
                  END IF;

                  -- Fin Bug 27539
                  vpas := 24;

                  -- {si el recibo no tiene los conceptos tiramos hacia atras, hasta el savepoint}
                  IF     nnpneta = 0
                     AND nnpconsor = 0
                     AND nnpdeven = 0
                     AND vcontrol = 0
                  THEN
                     ROLLBACK TO recibos_extorno;
                  ELSE
                     --            {grabamos una venta igual a la prima que extornamos}

                     --85.0 AQ
                     --IF xcempres = 16 THEN   -- SI es RSA
                     -- 38020.NMM
                     IF NVL (pac_parametros.f_parempresa_n (k_cempresa,
                                                            'AGENT_VENTA'
                                                           ),
                             0
                            ) = 1
                     THEN
                        FOR rdr IN c_detrec
                        LOOP
                           xcageven := rdr.cageven;
                        END LOOP;
                     END IF;

                     INSERT INTO detrecibos
                                 (nrecibo, cgarant, nriesgo, iconcep, cconcep,
                                  cageven, fcambio)
                        (SELECT nrecibo, cgarant, nriesgo, iconcep,
                                DECODE (cconcep,
                                        0, 21,
                                        11, 15,
                                        12, 16,
                                        50, 71,
                                        61, 65,
                                        62, 66,
                                        NULL
                                       ) cconcep,
                                xcageven, fcambio
                           FROM detrecibos
                          WHERE cconcep IN (0, 50, 11, 61, 12, 62)
                            AND nrecibo = t_rec_crea (i));

                     vpas := 25;

                     --FI --  85.0        18/05/2015  AQ               85. 0035775: Soporte cierres abril 2015
                     /*
                                 {Borramos las garant¿as que no generan venta}
                     */
                     FOR g IN gar_venta (t_rec_crea (i))
                     LOOP
                        num_err :=
                           f_pargaranpro (g.cramo,
                                          g.cmodali,
                                          g.ctipseg,
                                          g.ccolect,
                                          g.cactivi,
                                          g.cgarant,
                                          'GENVENTA',
                                          ccvalpar
                                         );

                        IF num_err <> 0
                        THEN
                           RETURN num_err;
                        END IF;

                        IF NVL (ccvalpar, 1) = 0
                        THEN
                           /*
                                       { La garantia no genera venta eliminamos los conceptos para esta garant¿a}
                           */
                           DELETE FROM detrecibos
                                 WHERE nrecibo = t_rec_crea (i)
                                   AND cgarant = g.cgarant
                                   AND cconcep IN (21, 71, 15, 16, 65, 66);
                        END IF;
                     END LOOP;

                     vpas := 27;

                     /*
                                    { restauramos los totales del recibo}
                     */
                     -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     DELETE FROM vdetrecibos_monpol
                           WHERE nrecibo = t_rec_crea (i);

                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     DELETE      vdetrecibos
                           WHERE nrecibo = t_rec_crea (i);

                     -- 23183 14/12/2012  JDS para las p¿lizas con coaseguro aceptado
                     IF reg_seg.ctipcoa = 8 AND NVL (pimpextorsion, 0) <> 0
                     THEN
                        num_err :=
                           f_calcul_extorn_recibos_manual (psseguro,
                                                           t_rec_crea (i),
                                                           pimpextorsion
                                                          );

                        IF NVL (pimpextorsion, 0) <> 0
                        THEN
                           DELETE      vdetrecibos_monpol
                                 WHERE nrecibo = t_rec_crea (i);

                           DELETE      vdetrecibos
                                 WHERE nrecibo = t_rec_crea (i);
                        END IF;
                     END IF;

                     vpas := 28;
                     num_err := f_vdetrecibos ('R', t_rec_crea (i));

                     -- fin 23183 14/12/2012  JDS
                     -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186) - Inici
                     -- IF num_err <> 0 THEN
                     --    RETURN num_err;
                     -- END IF;
                     IF num_err = 0
                     THEN
                        SELECT fefecto, fvencim
                          INTO vfefecto, vfvencim
                          FROM recibos
                         WHERE nrecibo = t_rec_crea (i);

                        num_err :=
                           pac_cesionesrea.f_cessio_det (v_sproces,
                                                         psseguro,
                                                         t_rec_crea (i),
                                                         reg_seg.cactivi,
                                                         reg_seg.cramo,
                                                         reg_seg.cmodali,
                                                         reg_seg.ctipseg,
                                                         reg_seg.ccolect,
                                                         vfefecto,
                                                         vfvencim,
                                                         1,
                                                         vdecimals
                                                        );
                     ELSE
                        RETURN num_err;
                     END IF;

                     -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186) - Fi
                     num_err :=
                        f_prima_minima_extorn (psseguro,
                                               t_rec_crea (i),
                                               2,
                                               NULL,
                                               NULL,
                                               7,
                                               pcagente,
                                               ffecextini
                                              );

                     IF num_err <> 0
                     THEN
                        RETURN num_err;
                     END IF;
                  END IF;

                  vpas := 29;

                  -- BUG24802:DRA:20/11/2012:Inici
                  --
                  -- Inicio IAXIS-4926 23/10/2019         
                  --
                  -- Se reemplaza la la función f_reparto_corretaje por una copia idéntica de la distribución de comisiones 
                  -- del recibo original.
                  -- 
                  --
                  /*IF pac_corretaje.f_tiene_corretaje (psseguro, NULL) = 1
                  THEN
                     --num_err := pac_corretaje.f_gen_comision_corr(psseguro, pnmovimi, nnrecibo);
                     num_err :=
                        pac_corretaje.f_reparto_corretaje (psseguro,
                                                           pnmovimi,
                                                           t_rec_crea (i)
                                                          );

                     IF num_err <> 0
                     THEN
                        p_tab_error (f_sysdate,
                                     f_user,
                                     'pac_anulacion.f_extorn_rec_cobrats',
                                     1312,
                                        'psseguro:'
                                     || psseguro
                                     || ' pnmovimi:'
                                     || pnmovimi
                                     || ' nnrecibo:'
                                     || t_rec_crea (i)
                                     || ' num_err='
                                     || num_err,
                                     f_axis_literales (num_err, f_usu_idioma)
                                    );
                        RETURN num_err;
                     END IF;
                  END IF;*/
                  
                  SELECT m.fmovdia
                    INTO vfmovdia
                    FROM movrecibo m
                   WHERE m.nrecibo = t_rec_crea(i)
                     AND m.smovrec =
                         (SELECT MAX(m1.smovrec)
                            FROM movrecibo m1
                           WHERE m1.nrecibo = m.nrecibo);
                  
                  FOR j IN (SELECT r.nreciboant FROM recibosclon r WHERE r.nreciboact = t_rec_crea(i)) 
                    LOOP 
                      BEGIN
                        INSERT INTO comrecibo
                          (nrecibo,
                           nnumcom,
                           cagente,
                           cestrec,
                           fmovdia,
                           fcontab,
                           icombru,
                           icomret,
                           icomdev,
                           iretdev,
                           nmovimi,
                           icombru_moncia,
                           icomret_moncia,
                           icomdev_moncia,
                           iretdev_moncia,
                           fcambio,
                           cgarant,
                           icomcedida,
                           icomcedida_moncia,
                           ccompan,
                           ivacomisi)
                          SELECT t_rec_crea(i),
                                 nnumcom,
                                 cagente,
                                 cestrec,
                                 vfmovdia,
                                 TRUNC(f_sysdate),
                                 icombru,
                                 icomret,
                                 icomdev,
                                 iretdev,
                                 nmovimi,
                                 icombru_moncia,
                                 icomret_moncia,
                                 icomdev_moncia,
                                 iretdev_moncia,
                                 fcambio,
                                 cgarant,
                                 icomcedida,
                                 icomcedida_moncia,
                                 ccompan,
                                 ivacomisi
                            FROM comrecibo
                           WHERE nrecibo = j.nreciboant;
                       EXCEPTION 
                         WHEN OTHERS THEN
                           p_tab_error(f_sysdate, 
                                       f_user, 
                                       'pac_anulacion.f_extorn_rec_cobrats', 
                                       vpas,
                                       'psseguro: '
                                       ||psseguro
                                       ||' pnmovimi: '
                                       ||NVL(vnmovimirec,pnmovimi)
                                       ||' nreciboact: '
                                       ||t_rec_crea(i)
                                       ||' nreciboant: '
                                       ||j.nreciboant,
                                       SQLERRM);
                       END;              
                    END LOOP;           
                  --
                  -- Fin IAXIS-4926 23/10/2019         
                  --

                  vpas := 30;

                  -- BUG24802:DRA:20/11/2012:Fi
                  -- ini Bug 0022701 - 03/09/2012 - JMF
                  IF pac_retorno.f_tiene_retorno (NULL, psseguro, NULL) = 1
                  THEN
                     -- INI RLLF 11/12/2015 0039201: POSES100-POSTEC - En las polizas de Salud con retorno, al hacer una anulaci¿n no se genera el recobr
                     /*BEGIN
                       SELECT DISTINCT cestrec
                               INTO vestado
                               FROM movrecibo m, recibos r, rtn_recretorno rt
                              WHERE r.sseguro = psseguro
                                AND r.nrecibo = rt.nrecibo
                                AND m.nrecibo = rt.nrecretorno
                                AND m.cestrec = 1   --Bug 37028/214287 - 22/09/2015 - AMC
                                AND m.cestant = 0   --Bug 37028/214287 - 22/09/2015 - AMC
                                AND fmovfin IS NULL;
                     EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                         vestado := NULL;
                     END;

                     IF vestado IS NOT NULL
                       AND vestado != 2 THEN*/
                     num_err :=
                        pac_retorno.f_generar_retorno (psseguro,
                                                       NULL,
                                                       t_rec_crea (i),
                                                       NULL
                                                      );

                     IF num_err <> 0
                     THEN
                        p_tab_error (f_sysdate,
                                     f_user,
                                     'pac_anulacion.f_extorn_rec_cobrats',
                                     1313,
                                        'psseguro:'
                                     || psseguro
                                     || ' pnmovimi:'
                                     || pnmovimi
                                     || ' num_err='
                                     || num_err,
                                     SQLCODE || ' ' || SQLERRM
                                    );
                        RETURN num_err;
                     END IF;
                  /*END IF;*/
                  -- FIN RLLF 11/12/2015 0039201: POSES100-POSTEC - En las polizas de Salud con retorno, al hacer una anulaci¿n no se genera el recobr
                  END IF;

                  -- fin Bug 0022701 - 03/09/2012 - JMF
                  IF v_crespue_4092 = 1 AND num_err = 0
                  THEN
                     NULL;
                  -- Si es administrado no env¿ar a JDE. Se har¿ en un recibo agrupado.
                  ELSE
                     --Se a¿ade la llamada a los procesos de envio a ERP en el extrono de prima devengada, de momento
                     --no se env¿an estos recibos a la ERP, pero se deja preparado.
                     --Bug.: 20923 - 14/01/2012 - ICV
                     IF     NVL
                               (pac_parametros.f_parempresa_n
                                                            (reg_seg.cempres,
                                                             'GESTIONA_COBPAG'
                                                            ),
                                0
                               ) = 1
                        AND num_err = 0
                     THEN
                        num_err :=
                           pac_ctrl_env_recibos.f_proc_recpag_mov
                                                            (reg_seg.cempres,
                                                             psseguro,
                                                             pnmovimi,
                                                             4,
                                                             NULL
                                                            );

                        --Si ha dado error retornamos el error
                        --De momento no retornamos el error
                        /*
                                 IF num_err <> 0 THEN
                         RETURN num_err;
                        end if;*/
                        -- 71. MMM - 17/09/2013 - 0027879: LCOL_T020-Qtracker: 0008849: ERROR AL VISUALIZAR POLIZA ANULADA - NOTA 0152786 - Inicio
                        FOR c IN (SELECT r.nrecibo, smovrec, cestrec, fmovini
                                    FROM recibos r, movrecibo m
                                   WHERE r.sseguro = psseguro
                                     AND r.cempres = reg_seg.cempres
                                     AND r.nmovimi = NVL(vnmovimirec, pnmovimi) -- IAXIS-4926 23/10/2019
                                     AND r.nrecibo = m.nrecibo
                                     AND m.fmovfin IS NULL
                                     AND m.cestrec = 0
                                     AND m.cestant = 0)
                        LOOP
                           num_err :=
                              f_insctacoas (c.nrecibo,
                                            c.cestrec,
                                            reg_seg.cempres,
                                            c.smovrec,
                                            TRUNC (c.fmovini)
                                           );
                        END LOOP;
                     -- 71. MMM - 17/09/2013 - 0027879: LCOL_T020-Qtracker: 0008849: ERROR AL VISUALIZAR POLIZA ANULADA - NOTA 0152786 - Fin
                     END IF;
                  --Fi Bug.: 20923
                  END IF;
               END IF;

               vpas := 31;
                   --------- INI BUG: 0025951: RSA003 - M¿dulo de cobranza
                   /*IF nnrecibo IS NOT NULL THEN     Bug  31135  Se traspasa a f_vdetrecibos
                     IF NVL(f_parproductos_v(reg_seg.sproduc, 'HAYCTACLIENTE'), 0) = 1 THEN
                       BEGIN
                         SELECT SUM(iconcep)
                           INTO witotalr
                           FROM detrecibos
                          WHERE cconcep IN(0, 1, 2, 3, 4, 5, 6, 7, 8, 14, 13, 86, 50, 51, 52, 53, 54,
                                       55, 56, 57, 58, 64, 63, 26)
                            AND
            --                  SELECT itotalr
            --                    INTO witotalr
            --                    FROM tmp_adm_vdetrecibos
            --                   WHERE
                              nrecibo = nnrecibo;
                       EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            RETURN 105031;
                         WHEN OTHERS THEN
                            RETURN 1000005;
                       END;

                       IF witotalr <> 0 THEN
                         num_err := pac_ctacliente.f_ins_movrecctacli(reg_seg.cempres, psseguro,
                                                           pnmovimi, nnrecibo);

                         IF num_err <> 0 THEN
                            RETURN num_err;
                         END IF;
                       END IF;
                     END IF;
                   ---------- FIN BUG: 0025951: RSA003 - M¿dulo de cobranza
                   END IF;   Bug 31135*/
            END LOOP;
         END IF;
      END IF;

      vpas := 33;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_extorn_rec_cobrats',
                      vpas,
                         'psseguro:'
                      || psseguro
                      || ' pcagente:'
                      || pcagente
                      || ' pnmovimi:'
                      || pnmovimi
                      || ' pcmoneda:'
                      || pcmoneda
                      || ' pfanulac:'
                      || pfanulac
                      || ' rcob:'
                      || f_recibostochar (rcob),
                      SQLERRM
                     );
         RETURN 140999;                                 --{Error no controlat}
   END f_extorn_rec_cobrats;

   FUNCTION f_anulada_al_emitir (psseguro IN NUMBER)
      RETURN NUMBER
   IS
/*******************************************************************/
/*   Retorna un 1 si la p¿liza tiene un movimiento con motivo de   */
/*     anulaci¿n 512 (anulaci¿n autom¿tica en el alta), sino       */
/*    retorna un 0                                               */
/*******************************************************************/
      vanul   NUMBER;
   BEGIN
      SELECT COUNT (1)
        INTO vanul
        FROM movseguro
       WHERE sseguro = psseguro AND cmotmov = 512;

      --anulada autom¿ticamente en el alta.
      IF vanul > 0
      THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END;

   FUNCTION f_anulacion_automatica (psseguro IN NUMBER, pfanulac IN DATE)
      RETURN NUMBER
   IS
      num_err       NUMBER;
      --movi_anula     NUMBER;
      sin_extorno   NUMBER       := 0;                         -- Sin extorno
      anu_rec       NUMBER       := 1;                -- Anulamos los recibos
      sin_agente    NUMBER       := NULL;
      --Como es sin extorno, no hace falta el agenrte
      cmotmov       NUMBER       := 512;    --Anulaci¿n autom¿tica en el alta
      pmoneda       NUMBER       := 1;
      rpend         recibos_pend;
      rcob          recibos_cob;

      --- cursor de recibos pendientes
      CURSOR recibo
      IS -- Leemos todos los recibos con estado pdte. sin considerar la fecha
         SELECT   r.nrecibo, r.fefecto, r.fvencim, r.cagente,
                  v.itotalr * DECODE (ctiprec, 9, -1, 1) itotalr, m.fmovini,
                  r.cempres, r.cdelega, ROWNUM - 1 contad
             FROM movrecibo m, recibos r, vdetrecibos v
            WHERE m.nrecibo = r.nrecibo
              AND m.nrecibo = v.nrecibo
              AND m.fmovfin IS NULL
              AND m.cestrec = 0
              AND r.sseguro = psseguro
         ORDER BY contad;
   BEGIN
      /*
                            {anulamos todos los recibos que est¿n pendientespara ese seguro}
      */
      FOR c IN recibo
      LOOP
         rpend (c.contad).nrecibo := c.nrecibo;
         rpend (c.contad).fmovini := c.fmovini;
         rpend (c.contad).fefecto := c.fefecto;
         rpend (c.contad).fvencim := c.fvencim;
      END LOOP;

      /*
            {llamamos a la anulaci¿n de p¿liza con
        - moneda =1
       - sin hacer extorno, y por tanto sin agente
       - anulando recibos pdtes.
      }
      */
      -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
      BEGIN
         SELECT pac_monedas.f_moneda_producto (sproduc)
           INTO pmoneda
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            pmoneda := pac_parametros.f_parinstalacion_n ('MONEDAINST');
      END;

      -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
      num_err :=
         f_anula_poliza (psseguro,
                         cmotmov,
                         pmoneda,
                         pfanulac,
                         sin_extorno,
                         anu_rec,
                         sin_agente,
                         rpend,
                         rcob
                        );

      --control temporal de las p¿lizas anuladas
--      p_tab_error(f_sysdate, f_user, 'pac_anulacion.f_anulacion_automatica', 7,
--                  'El resultado de anular el sseguro: ' || psseguro
--                  || ', con fecha es fanula: ' || pfanulac,
--                  'NUM ERROR : ' || num_err);
      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error
               (f_sysdate,
                f_user,
                'pac_anulacion.f_anulacion_automatica',
                8,
                   'Error inesperado en la funci¿n con el seguro, sseguro: '
                || psseguro
                || ', fanula: '
                || pfanulac,
                SQLCODE || '-' || SQLERRM
               );
         RETURN SQLCODE;
   END f_anulacion_automatica;

   -- Bug 22826 - APD - 11/07/2012 - se a¿ade el parametro paplica_penali
   FUNCTION f_anula_poliza (
      psseguro         IN   NUMBER,
      pcmotmov         IN   NUMBER,
      pcmoneda         IN   NUMBER,
      pfanulac         IN   DATE,
      pcextorn         IN   NUMBER,
      pcanular_rec     IN   NUMBER,
      pcagente         IN   NUMBER,
      rpend            IN   recibos_pend,
      rcob             IN   recibos_cob,
      psproduc         IN   NUMBER DEFAULT NULL,
      pcnotibaja       IN   NUMBER DEFAULT NULL,
      pcsituac         IN   NUMBER DEFAULT 2,
      pccauanul        IN   NUMBER DEFAULT NULL,
      paplica_penali   IN   NUMBER DEFAULT 0,
      pimpextorsion    IN   NUMBER DEFAULT 0
   )                 -- 23183 14/12/2012  JDS  se a¿ade variable pimpextorsion
      RETURN NUMBER
   IS
      ssproduc   NUMBER;
      num_err    NUMBER;
      nnmovimi   NUMBER;
      --v_fefepol      DATE;
      ptraza     NUMBER;
   BEGIN
      /*
         {comprobamos si tenemos toda la informaci¿n necesaria para anular la poliza
        1.- Tener el motivo de anulaci¿n
        2.- Que sea necesario la notificaci¿n de baja y no se informe.}
      */
      IF    pcmotmov IS NULL
         OR ((    NVL (f_parinstalacion_n ('NOTIFIBAJA'), 0) = 1
              AND pcnotibaja IS NULL
             )
            )
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.
         ',
                      2,
                      SUBSTR (   'psseguro:'
                              || psseguro
                              || ' pcmotmov:'
                              || pcmotmov
                              || ' pcmoneda:'
                              || pcmoneda
                              || ' pfanulac:'
                              || pfanulac
                              || ' pcextorn:'
                              || pcextorn
                              || ' pcanular_rec:'
                              || pcanular_rec
                              || ' pcagente:'
                              || pcagente
                              || ' psproduc:'
                              || psproduc
                              || ' pcnotibaja:'
                              || pcnotibaja
                              || ' pcsituac:'
                              || pcsituac,
                              1,
                              500
                             ),
                      NVL (f_parinstalacion_n ('NOTIFIBAJA'), 0)
                     );
         RETURN 40705;                               --{ERRORRRRRRRRRRRRRRRRR}
      END IF;

      IF psproduc IS NULL
      THEN
         /*
                               { buscamos el sproduc de productos para aquellas instalaciones que a¿n no lo
          tienen a nivel de seguros}
         */
         BEGIN
            --BUG10772-22/07/2009-JMF: CRE - Desanul¿lar programacions al venciment/propera cartera
            SELECT s.sproduc
              INTO ssproduc
              FROM seguros s
             WHERE s.sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'pac_anulacion.f_anula_poliza',
                            3,
                            SUBSTR (   'psseguro:'
                                    || psseguro
                                    || ' pcmotmov:'
                                    || pcmotmov
                                    || ' pcmoneda:'
                                    || pcmoneda
                                    || ' pfanulac:'
                                    || pfanulac
                                    || ' pcextorn:'
                                    || pcextorn
                                    || ' pcanular_rec:'
                                    || pcanular_rec
                                    || ' pcagente:'
                                    || pcagente
                                    || ' psproduc:'
                                    || psproduc
                                    || ' pcnotibaja:'
                                    || pcnotibaja
                                    || ' pcsituac:'
                                    || pcsituac,
                                    1,
                                    500
                                   ),
                            SQLERRM
                           );
               RETURN 103286;                             --{Seguro no existe}
         END;
      ELSE
         ssproduc := psproduc;
      END IF;

      /*
                                   { Tratamos el reaseguro }
      */
      ptraza := 1;

      -- 21559 AVT 13/03/2012 en cas d'anul¿laci¿ per sinistre no s'anul¿la la cessi¿ a la reasseguran¿a. Nom¿s sempre que hi hagi extorn.
      IF pcmotmov <> 505 AND pcextorn = 1
      THEN
         num_err := f_baja_rea (psseguro, pfanulac, pcmoneda);
      END IF;

      IF num_err <> 0
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_anula_poliza',
                      4,
                      SUBSTR (   'psseguro:'
                              || psseguro
                              || ' pcmotmov:'
                              || pcmotmov
                              || ' pcmoneda:'
                              || pcmoneda
                              || ' pfanulac:'
                              || pfanulac
                              || ' pcextorn:'
                              || pcextorn
                              || ' pcanular_rec:'
                              || pcanular_rec
                              || ' pcagente:'
                              || pcagente
                              || ' psproduc:'
                              || psproduc
                              || ' pcnotibaja:'
                              || pcnotibaja
                              || ' pcsituac:'
                              || pcsituac,
                              1,
                              500
                             ),
                      num_err
                     );
         RETURN num_err;
      END IF;

      /*
            {damos de baja el seguro}
      */
      ptraza := 2;
      --Ini Bug.: 13068 - 26/02/2010 - ICV - Se a¿ade el paso del parametro PCCAUANUL
      num_err :=
         f_baja_seg (psseguro,
                     pfanulac,
                     pcextorn,
                     pcmotmov,
                     nnmovimi,
                     pcnotibaja,
                     pcsituac,
                     pccauanul
                    );

      --Fin Bug.: 13068
      IF num_err <> 0
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_anula_poliza-->',
                      5,
                      SUBSTR (   'psseguro:'
                              || psseguro
                              || ' pcmotmov:'
                              || pcmotmov
                              || ' pcmoneda:'
                              || pcmoneda
                              || ' pfanulac:'
                              || pfanulac
                              || ' pcextorn:'
                              || pcextorn
                              || ' pcanular_rec:'
                              || pcanular_rec
                              || ' pcagente:'
                              || pcagente
                              || ' psproduc:'
                              || psproduc
                              || ' pcnotibaja:'
                              || pcnotibaja
                              || ' pcsituac:'
                              || pcsituac,
                              1,
                              500
                             ),
                      f_axis_literales (num_err, f_idiomauser)
                     );
         RETURN num_err;
      END IF;

      /*
            {anulamos los recibos pendientes }
      */
      ptraza := 3;

      IF pcanular_rec = 1
      THEN
         num_err := f_baja_rec_pend (pfanulac => pfanulac,rpend =>  rpend,pcmotmov => pcmotmov); -- IAXIS-5327 19/09/2019
      END IF;

      IF num_err <> 0
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_anula_poliza',
                      6,
                      SUBSTR (   'psseguro:'
                              || psseguro
                              || ' pcmotmov:'
                              || pcmotmov
                              || ' pcmoneda:'
                              || pcmoneda
                              || ' pfanulac:'
                              || pfanulac
                              || ' pcextorn:'
                              || pcextorn
                              || ' pcanular_rec:'
                              || pcanular_rec
                              || ' pcagente:'
                              || pcagente
                              || ' psproduc:'
                              || psproduc
                              || ' pcnotibaja:'
                              || pcnotibaja
                              || ' pcsituac:'
                              || pcsituac,
                              1,
                              500
                             ),
                      num_err
                     );
         RETURN num_err;
      END IF;

      /*
            {Realizamos el extorno de la venta pdte. de emitir}
      */
      IF NVL (f_parproductos_v (ssproduc, 'EXTORNO_VENTA'), 1) = 1
      THEN
         ptraza := 4;
         num_err :=
                   f_extorn_ventapte (psseguro, pcmotmov, nnmovimi, pfanulac);

         IF num_err <> 0
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'pac_anulacion.f_anula_poliza',
                         7,
                         SUBSTR (   'psseguro:'
                                 || psseguro
                                 || ' pcmotmov:'
                                 || pcmotmov
                                 || ' pcmoneda:'
                                 || pcmoneda
                                 || ' pfanulac:'
                                 || pfanulac
                                 || ' pcextorn:'
                                 || pcextorn
                                 || ' pcanular_rec:'
                                 || pcanular_rec
                                 || ' pcagente:'
                                 || pcagente
                                 || ' psproduc:'
                                 || psproduc
                                 || ' pcnotibaja:'
                                 || pcnotibaja
                                 || ' pcsituac:'
                                 || pcsituac,
                                 1,
                                 500
                                ),
                         num_err
                        );
            RETURN num_err;
         -- JRH Descomentar.8500: CRE - Incidencia de baja/anulaci¿n de p¿liza.
         END IF;
      END IF;

      /*
                {Realizamos el extorno de los recibos cobrados}
      */
      ptraza := 5;

      IF pcextorn = 1
      THEN
         -- ini 0011652 CRE - Generaci¿n de extornos incorrecta en el caso de p¿lizas con copago
         IF NVL (f_parproductos_v (ssproduc, 'RECUNIF'), 0) IN (1, 3)
         THEN
            -- BUG 0019627: GIP102 - Reunificaci¿n de recibos - FAL - 10/11/2011
            DECLARE
               rcob_cero   recibos_cob;
               rcob_norm   recibos_cob;
               n_esccero   recibos.esccero%TYPE;
               n_reccero   NUMBER;
               n_recnorm   NUMBER;
            BEGIN
               ptraza := 6;
               -- Los recibos seleccionados en pantalla,
               -- los separamos en dos listas (cero y no_cero).
               rcob_cero.DELETE;
               rcob_norm.DELETE;
               n_reccero := 0;
               n_recnorm := 0;

               IF rcob.FIRST IS NOT NULL
               THEN
                  FOR i IN rcob.FIRST .. rcob.LAST
                  LOOP
                     ptraza := 7;

                     SELECT MAX (esccero)
                       INTO n_esccero
                       FROM recibos
                      WHERE nrecibo = rcob (i).nrecibo;

                     IF n_esccero = 1
                     THEN
                        ptraza := 8;
                        n_reccero := n_reccero + 1;
                        rcob_cero (n_reccero).nrecibo := rcob (i).nrecibo;
                        rcob_cero (n_reccero).fmovini := rcob (i).fmovini;
                        rcob_cero (n_reccero).fefecto := rcob (i).fefecto;
                        rcob_cero (n_reccero).fvencim := rcob (i).fvencim;
                     ELSE
                        ptraza := 9;
                        n_recnorm := n_recnorm + 1;
                        rcob_norm (n_recnorm).nrecibo := rcob (i).nrecibo;
                        rcob_norm (n_recnorm).fmovini := rcob (i).fmovini;
                        rcob_norm (n_recnorm).fefecto := rcob (i).fefecto;
                        rcob_norm (n_recnorm).fvencim := rcob (i).fvencim;
                     END IF;
                  END LOOP;
               END IF;

               IF rcob_cero.FIRST IS NOT NULL
               THEN
                  ptraza := 10;
                  -- Bug 22826 - APD - 11/07/2012 - se a¿ade el parametro paplica_penali
                  num_err :=
                     f_extorn_rec_cobrats (psseguro,
                                           pcagente,
                                           nnmovimi,
                                           pfanulac,
                                           pcmoneda,
                                           rcob_cero,
                                           paplica_penali,
                                           pimpextorsion
                                          );

                  -- 23183 14/12/2012  JDS  se a¿ade variable pimpextorsion

                  -- fin Bug 22826 - APD - 11/07/2012
                  IF num_err <> 0
                  THEN
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'pac_anulacion.f_anula_poliza',
                                  8,
                                  SUBSTR (   'psseguro:'
                                          || psseguro
                                          || ' pcmotmov:'
                                          || pcmotmov
                                          || ' pcmoneda:'
                                          || pcmoneda
                                          || ' pfanulac:'
                                          || pfanulac
                                          || ' pcextorn:'
                                          || pcextorn
                                          || ' pcanular_rec:'
                                          || pcanular_rec
                                          || ' pcagente:'
                                          || pcagente
                                          || ' psproduc:'
                                          || psproduc
                                          || ' pcnotibaja:'
                                          || pcnotibaja
                                          || ' pcsituac:'
                                          || pcsituac,
                                          1,
                                          500
                                         ),
                                  num_err
                                 );
                     RETURN num_err;
                  END IF;
               END IF;

               IF rcob_norm.FIRST IS NOT NULL
               THEN
                  ptraza := 11;
                  -- Bug 22826 - APD - 11/07/2012 - se a¿ade el parametro paplica_penali
                  num_err :=
                     f_extorn_rec_cobrats (psseguro,
                                           pcagente,
                                           nnmovimi,
                                           pfanulac,
                                           pcmoneda,
                                           rcob_norm,
                                           paplica_penali,
                                           pimpextorsion
                                          );

                  -- 23183 14/12/2012  JDS  se a¿ade variable pimpextorsion

                  -- fin Bug 22826 - APD - 11/07/2012
                  IF num_err <> 0
                  THEN
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'pac_anulacion.f_anula_poliza',
                                  9,
                                  SUBSTR (   'psseguro:'
                                          || psseguro
                                          || ' pcmotmov:'
                                          || pcmotmov
                                          || ' pcmoneda:'
                                          || pcmoneda
                                          || ' pfanulac:'
                                          || pfanulac
                                          || ' pcextorn:'
                                          || pcextorn
                                          || ' pcanular_rec:'
                                          || pcanular_rec
                                          || ' pcagente:'
                                          || pcagente
                                          || ' psproduc:'
                                          || psproduc
                                          || ' pcnotibaja:'
                                          || pcnotibaja
                                          || ' pcsituac:'
                                          || pcsituac,
                                          1,
                                          500
                                         ),
                                  num_err
                                 );
                     RETURN num_err;
                  END IF;
               END IF;
            END;
         -- fin 0011652 CRE - Generaci¿n de extornos incorrecta en el caso de p¿lizas con copago
         ELSE
            /**/
            -- Bug 28820/162891 - INI
            IF NVL (f_parproductos_v (ssproduc, 'SEPARA_RIESGO_AHORRO'), 0) =
                                                                            1
            THEN
               DECLARE
                  rcob_riesgo   recibos_cob;
                  rcob_ahorro   recibos_cob;
                  n_recriesgo   NUMBER;
                  n_recahorro   NUMBER;
               BEGIN
                  n_recriesgo := 0;
                  n_recahorro := 0;
                  ptraza := 6;
                  -- Los recibos seleccionados en pantalla,
                  -- los separamos en dos listas (cero y no_cero).
                  rcob_riesgo.DELETE;
                  rcob_ahorro.DELETE;

                  IF rcob.FIRST IS NOT NULL
                  THEN
                     FOR i IN rcob.FIRST .. rcob.LAST
                     LOOP
                        ptraza := 7;

                        IF pac_adm.f_es_recibo_ahorro (rcob (i).nrecibo) = 0
                        THEN
                           ptraza := 8;
                           n_recriesgo := n_recriesgo + 1;
                           rcob_riesgo (n_recriesgo).nrecibo :=
                                                             rcob (i).nrecibo;
                           rcob_riesgo (n_recriesgo).fmovini :=
                                                             rcob (i).fmovini;
                           rcob_riesgo (n_recriesgo).fefecto :=
                                                             rcob (i).fefecto;
                           rcob_riesgo (n_recriesgo).fvencim :=
                                                             rcob (i).fvencim;
                        ELSE
                           ptraza := 9;
                           n_recahorro := n_recahorro + 1;
                           rcob_ahorro (n_recahorro).nrecibo :=
                                                             rcob (i).nrecibo;
                           rcob_ahorro (n_recahorro).fmovini :=
                                                             rcob (i).fmovini;
                           rcob_ahorro (n_recahorro).fefecto :=
                                                             rcob (i).fefecto;
                           rcob_ahorro (n_recahorro).fvencim :=
                                                             rcob (i).fvencim;
                        END IF;
                     END LOOP;
                  END IF;

                  IF rcob_riesgo.FIRST IS NOT NULL
                  THEN
                     ptraza := 10;
                     num_err :=
                        f_extorn_rec_cobrats (psseguro,
                                              pcagente,
                                              nnmovimi,
                                              pfanulac,
                                              pcmoneda,
                                              rcob_riesgo,
                                              paplica_penali,
                                              pimpextorsion
                                             );

                     IF num_err <> 0
                     THEN
                        p_tab_error (f_sysdate,
                                     f_user,
                                     'pac_anulacion.f_anula_poliza',
                                     8,
                                     SUBSTR (   'psseguro:'
                                             || psseguro
                                             || ' pcmotmov:'
                                             || pcmotmov
                                             || ' pcmoneda:'
                                             || pcmoneda
                                             || ' pfanulac:'
                                             || pfanulac
                                             || ' pcextorn:'
                                             || pcextorn
                                             || ' pcanular_rec:'
                                             || pcanular_rec
                                             || ' pcagente:'
                                             || pcagente
                                             || ' psproduc:'
                                             || psproduc
                                             || ' pcnotibaja:'
                                             || pcnotibaja
                                             || ' pcsituac:'
                                             || pcsituac,
                                             1,
                                             500
                                            ),
                                     num_err
                                    );
                        RETURN num_err;
                     END IF;
                  END IF;

                  IF rcob_ahorro.FIRST IS NOT NULL
                  THEN
                     ptraza := 11;
                     num_err :=
                        f_extorn_rec_cobrats (psseguro,
                                              pcagente,
                                              nnmovimi,
                                              pfanulac,
                                              pcmoneda,
                                              rcob_ahorro,
                                              paplica_penali,
                                              pimpextorsion
                                             );

                     IF num_err <> 0
                     THEN
                        p_tab_error (f_sysdate,
                                     f_user,
                                     'pac_anulacion.f_anula_poliza',
                                     9,
                                     SUBSTR (   'psseguro:'
                                             || psseguro
                                             || ' pcmotmov:'
                                             || pcmotmov
                                             || ' pcmoneda:'
                                             || pcmoneda
                                             || ' pfanulac:'
                                             || pfanulac
                                             || ' pcextorn:'
                                             || pcextorn
                                             || ' pcanular_rec:'
                                             || pcanular_rec
                                             || ' pcagente:'
                                             || pcagente
                                             || ' psproduc:'
                                             || psproduc
                                             || ' pcnotibaja:'
                                             || pcnotibaja
                                             || ' pcsituac:'
                                             || pcsituac,
                                             1,
                                             500
                                            ),
                                     num_err
                                    );
                        RETURN num_err;
                     END IF;
                  END IF;
               END;
            -- Bug 28820/162891 - FIN
            ELSE
               ptraza := 12;
               -- Bug 22826 - APD - 11/07/2012 - se a¿ade el parametro paplica_penali
               num_err :=
                  f_extorn_rec_cobrats (psseguro,
                                        pcagente,
                                        nnmovimi,
                                        pfanulac,
                                        pcmoneda,
                                        rcob,
                                        paplica_penali,
                                        pimpextorsion
                                       );

               -- 23183 14/12/2012  JDS  se a¿ade variable pimpextorsion

               -- fin Bug 22826 - APD - 11/07/2012
               IF num_err <> 0
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_anulacion.f_anula_poliza',
                               10,
                               SUBSTR (   'psseguro:'
                                       || psseguro
                                       || ' pcmotmov:'
                                       || pcmotmov
                                       || ' pcmoneda:'
                                       || pcmoneda
                                       || ' pfanulac:'
                                       || pfanulac
                                       || ' pcextorn:'
                                       || pcextorn
                                       || ' pcanular_rec:'
                                       || pcanular_rec
                                       || ' pcagente:'
                                       || pcagente
                                       || ' psproduc:'
                                       || psproduc
                                       || ' pcnotibaja:'
                                       || pcnotibaja
                                       || ' pcsituac:'
                                       || pcsituac,
                                       1,
                                       500
                                      ),
                               num_err
                              );
                  RETURN num_err;
               END IF;
            END IF;
         END IF;
      END IF;

      ptraza := 13;

      IF NVL (f_parproductos_v (ssproduc, 'POST_ANULACION'), 0) = 1
      THEN
         num_err :=
                   pac_propio.f_post_anulacion (psseguro, pfanulac, nnmovimi);

         IF num_err <> 0
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'pac_anulacion.f_anula_poliza',
                         11,
                         SUBSTR (   'psseguro:'
                                 || psseguro
                                 || ' pcmotmov:'
                                 || pcmotmov
                                 || ' pcmoneda:'
                                 || pcmoneda
                                 || ' pfanulac:'
                                 || pfanulac
                                 || ' pcextorn:'
                                 || pcextorn
                                 || ' pcanular_rec:'
                                 || pcanular_rec
                                 || ' pcagente:'
                                 || pcagente
                                 || ' psproduc:'
                                 || psproduc
                                 || ' pcnotibaja:'
                                 || pcnotibaja
                                 || ' pcsituac:'
                                 || pcsituac,
                                 1,
                                 500
                                ),
                         num_err
                        );
            RETURN num_err;
         END IF;
      END IF;

      -- Mantis 10344.01/06/2009.NMM.CRE - Cesiones a reaseguro incorrectas.i.
      ptraza := 14;

      --IF f_parproductos_v(ssproduc, 'REASEGURO') = 1 THEN -- BUG: 17672 JGR 23/02/2011
      IF f_cdetces (psseguro, nnmovimi) = 1
      THEN                                        -- BUG: 17672 JGR 23/02/2011
         num_err := pac_cesionesrea.f_del_reasegemi (psseguro, nnmovimi);
      END IF;

      --
      IF num_err <> 0
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_anula_poliza',
                      12,
                      SUBSTR (   'psseguro:'
                              || psseguro
                              || ' pcmotmov:'
                              || pcmotmov
                              || ' pcmoneda:'
                              || pcmoneda
                              || ' pfanulac:'
                              || pfanulac
                              || ' pcextorn:'
                              || pcextorn
                              || ' pcanular_rec:'
                              || pcanular_rec
                              || ' pcagente:'
                              || pcagente
                              || ' psproduc:'
                              || psproduc
                              || ' pcnotibaja:'
                              || pcnotibaja
                              || ' pcsituac:'
                              || pcsituac,
                              1,
                              500
                             ),
                      num_err
                     );
         RETURN (num_err);
      END IF;

      -- I - 18/10/2012 jlb - 23823
      -- Llamo a las listas restringidas
      -- Accion: anulaci¿n de p¿liza
      num_err :=
         pac_listarestringida.f_valida_listarestringida (psseguro,
                                                         nnmovimi,
                                                         NULL,
                                                         2,
                                                         NULL,
                                                         NULL,
                                                         NULL
                                                        -- Bug 31411/175020 - 16/05/2014 - AMC
                                                        );

      IF num_err <> 0
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_anula_poliza',
                      13,
                      SUBSTR (   'psseguro:'
                              || psseguro
                              || ' pcmotmov:'
                              || pcmotmov
                              || ' pcmoneda:'
                              || pcmoneda
                              || ' pfanulac:'
                              || pfanulac
                              || ' pcextorn:'
                              || pcextorn
                              || ' pcanular_rec:'
                              || pcanular_rec
                              || ' pcagente:'
                              || pcagente
                              || ' psproduc:'
                              || psproduc
                              || ' pcnotibaja:'
                              || pcnotibaja
                              || ' pcsituac:'
                              || pcsituac,
                              1,
                              500
                             ),
                      num_err
                     );
         RETURN num_err;
      END IF;

      -- F - 18/10/2012- jlb - 23823
      -- Mantis 10344.f.
      ptraza := 15;

      IF num_err = 0
      THEN
         IF     NVL (pac_parametros.f_parempresa_n (k_cempresa, 'ENVIO_SRI'),
                     0
                    ) = 1
            AND num_err = 0
         THEN
            num_err :=
                      pac_sri.p_envio_sri (k_cempresa, psseguro, nnmovimi, 4);

            --Si ha dado error
            IF num_err <> 0
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'pac_anulacion.f_anula_poliza',
                            14,
                            SUBSTR (   'psseguro:'
                                    || psseguro
                                    || ' pcmotmov:'
                                    || pcmotmov
                                    || ' pcmoneda:'
                                    || pcmoneda
                                    || ' pfanulac:'
                                    || pfanulac
                                    || ' pcextorn:'
                                    || pcextorn
                                    || ' pcanular_rec:'
                                    || pcanular_rec
                                    || ' pcagente:'
                                    || pcagente
                                    || ' psproduc:'
                                    || psproduc
                                    || ' pcnotibaja:'
                                    || pcnotibaja
                                    || ' pcsituac:'
                                    || pcsituac,
                                    1,
                                    500
                                   ),
                            num_err
                           );
            END IF;
         END IF;
      END IF;

      RETURN (0);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_anula_poliza',
                      ptraza,
                      SUBSTR (   'psseguro:'
                              || psseguro
                              || ' pcmotmov:'
                              || pcmotmov
                              || ' pcmoneda:'
                              || pcmoneda
                              || ' pfanulac:'
                              || pfanulac
                              || ' pcextorn:'
                              || pcextorn
                              || ' pcanular_rec:'
                              || pcanular_rec
                              || ' pcagente:'
                              || pcagente
                              || ' psproduc:'
                              || psproduc
                              || ' pcnotibaja:'
                              || pcnotibaja
                              || ' pcsituac:'
                              || pcsituac
                              || ' rpend:'
                              || f_recibostochar (rpend)
                              || ' rcob:'
                              || f_recibostochar (rcob),
                              1,
                              500
                             ),
                      SQLERRM
                     );
         RETURN 40735;                     --{Aquesta dada no pot estar buida}
   END f_anula_poliza;

   FUNCTION f_anula_poliza_vto (
      psseguro     IN   NUMBER,
      pcmotven     IN   NUMBER,
      pfanulac     IN   DATE,
      pcmotmov     IN   NUMBER DEFAULT 221,
      pnsuplem     IN   NUMBER DEFAULT NULL,
      pfcaranu     IN   DATE DEFAULT NULL,
      pcnotibaja   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      num_err     NUMBER;
      nnmovimi    NUMBER;
      nnsuplem    NUMBER;
      ffcaranu    DATE;
      v_sproduc   seguros.sproduc%TYPE;
   BEGIN
      -- BUG 8850 - 8850 - DCM ¿ Tratamiento tipo de anulacion fecha de proxima cartera
      --ini BUG10772-22/07/2009-JMF: CRE - Desanul¿lar programacions al venciment/propera cartera
      BEGIN
         --BUG10503:DRA:23/06/2009:Inici
         --Bug.: 0010354 - ICV - Incidencia baja a la pr¿xima cartera (Se a¿aden los nvl)
         --si el pnsuplem es null o fcaranu, lo buscamos en seguros
         SELECT sproduc, NVL (pnsuplem, nsuplem), NVL (pfcaranu, fcaranu)
           INTO v_sproduc, nnsuplem, ffcaranu
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 103286;                               --{Seguro no existe}
      END;

      --miramos si se permite anular movimientos}
      IF pac_parametros.f_parproducto_n (v_sproduc, 'PROGVENCIM') = 0
      THEN
         RETURN 109905;     --{No tiene permiso para realizar esta operacion}
      END IF;

      -- Bug 19312/98587 - RSC - 23/11/2011 - LCOL_T004 - Parametrizaci¿n Anulaciones
      IF     f_prod_ahorro (v_sproduc) = 1
         AND pac_parametros.f_parmotmov_n (pcmotmov,
                                           'AHORRO_PERMITE_VTO',
                                           v_sproduc
                                          ) = 0
      THEN
         RETURN 9001839;
      END IF;

      IF pac_parametros.f_parmotmov_n (pcmotmov, 'PROGVENCIMMOT', v_sproduc) =
                                                                             0
      THEN
         -- BUG 8850 - 8850 - DCM ¿ Tratamiento tipo de anulacion fecha de proxima cartera
         RETURN 151687;             --{Motivo no v¿lido para una baja al vto}
      END IF;

      --fin BUG10772-22/07/2009-JMF: CRE - Desanul¿lar programacions al venciment/propera cartera

      /*
            {Se crea el movimiento para la baja de p¿liza}
      */
      num_err :=
         f_movseguro (psseguro,
                      NULL,
                      pcmotmov,
                      1,
                      pfanulac,
                      NULL,
                      nnsuplem + 1,
                      1,
                      NULL,
                      nnmovimi,
                      f_sysdate,
                      NULL,
                      pcmotven
                     );

      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      /*
            {Se llama a f_act_hisseg para guardar la situaci¿n anterior al suplemento.
       El nmovimi es el anterior al del suplemento, por eso se le resta uno al reci¿n creado.}
      */
      num_err := f_act_hisseg (psseguro, nnmovimi - 1);

      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      /*
            {Actualizamos el seguro con la fecha de vto. y la notficaci¿n de baja}
      */
      UPDATE seguros
         SET fvencim = ffcaranu,
             nsuplem = nnsuplem + 1,
             cnotibaja = pcnotibaja
       WHERE sseguro = psseguro;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_anula_poliza_vto',
                      1,
                      'Error no controlado',
                      SQLERRM
                     );
         RETURN 40735;                     --{Aquesta dada no pot estar buida}
   END f_anula_poliza_vto;

   FUNCTION f_esta_anulada_vto (psseguro IN NUMBER)
      RETURN NUMBER
   IS
      /*
                            { 1.- si esta anulada al vto.
        0.- No est¿ anulada al vto.
       }
      */
      ccmotmov    NUMBER;
      --ini BUG10772-22/07/2009-JMF: CRE - Desanul¿lar programacions al venciment/propera cartera
      n_sproduc   seguros.sproduc%TYPE;
      n_pro       NUMBER (1);                                               --
      n_des       NUMBER (1);
      n_ret       NUMBER (1);
   BEGIN
      --Afegir els motius a par¿metres.
      n_ret := NULL;

      SELECT MAX (sproduc)
        INTO n_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      -- existeix Motius programaci¿ a nivell de producte
      SELECT NVL (MAX (1), 0)
        INTO n_pro
        FROM parmotmov a
       WHERE a.cparmot = 'PROGVENCIMMOT'
         AND a.cvalpar = 1
         AND a.sproduc = n_sproduc;

      -- existeix Motius desprogramaci¿ a nivell de producte
      SELECT NVL (MAX (1), 0)
        INTO n_des
        FROM parmotmov a
       WHERE a.cparmot = 'DESPROGVENCIMMOT'
         AND a.cvalpar = 1
         AND a.sproduc = n_sproduc;

      /*
             {miramos si el m¿ximo mov. entre anulaci¿n y desanulaci¿n es de anulaci¿n}
      */
      BEGIN
         SELECT cmotmov
           INTO ccmotmov
           FROM movseguro
          WHERE sseguro = psseguro
            AND nmovimi =
                   (SELECT MAX (nmovimi)
                      FROM movseguro
                     WHERE sseguro = psseguro
                       AND cmotmov IN (
                              SELECT cmotmov
                                FROM parmotmov
                               WHERE cparmot = 'PROGVENCIMMOT'
                                 AND cvalpar = 1
                                 AND sproduc = DECODE (n_pro,
                                                       1, n_sproduc,
                                                       0
                                                      )
                              UNION
                              SELECT cmotmov
                                FROM parmotmov
                               WHERE cparmot = 'DESPROGVENCIMMOT'
                                 AND cvalpar = 1
                                 AND sproduc = DECODE (n_des,
                                                       1, n_sproduc,
                                                       0
                                                      )
                                                       /* -- BUG 0040897 - FAL - 02/03/2016 - Se comenta. No permitia desanular Anulaciones al vto. ya vencidas (322)
                                                       UNION
                                                       SELECT cmotmov   -- BUG18706:DRA:31/05/2011
                                                         FROM codimotmov
                                                        WHERE cmotmov IN(306, 322, 324, 512)*/
                           ));
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            n_ret := 0;
      --{Si no tiene movimiento de anulaci¿n o desanulaci¿n, no permitimos seguir adelante}
      END;

      IF n_ret IS NULL
      THEN
         -- buscar si existeix motiu a llista anulaci¿ prog.vencim.
         SELECT NVL (MAX (1), 0)
           INTO n_ret
           FROM parmotmov
          WHERE cvalpar = 1
            AND cmotmov = ccmotmov
            AND cparmot = 'PROGVENCIMMOT'
            AND sproduc = DECODE (n_pro, 1, n_sproduc, 0);
      END IF;

      RETURN n_ret;
   --fin BUG10772-22/07/2009-JMF: CRE - Desanul¿lar programacions al venciment/propera cartera
   END;

   FUNCTION f_es_desanulable (
      psseguro   IN   NUMBER,
      psproduc   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      /*
         {Funci¿n que nos indica si es una poliza se puede desanular. Para mirar esto miramos si el ¿ltimo
       movimiento entre la anulaciones y desanulaciones es una anulaci¿n. En el caso de los vinculados
       tamb¿en tendremos que mirar que el contrato al que est¿n vinculados no est¿ anulado
       0.- no se puede desanular pero si anular
       1.- se puede desanular
       *.- Ni desanular , ni anular}
      */
      ssproduc     NUMBER;
      fffinprest   DATE;
   --ccmotmov       NUMBER;
   BEGIN
      --ini BUG10772-22/07/2009-JMF: CRE - Desanul¿lar programacions al venciment/propera cartera
      /*Buscamos el sproduc de productos*/
      IF psproduc IS NULL
      THEN
         BEGIN
            SELECT sproduc
              INTO ssproduc
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               RETURN 103286;                            --{seguro no existe}
         END;
      --fin BUG10772-22/07/2009-JMF: CRE - Desanul¿lar programacions al venciment/propera cartera
      ELSE
         ssproduc := psproduc;
      END IF;

      /*
            {Si el ¿ltimo es de anulaci¿n miramos el caso de los vinculados. El prestamo no puede haber sido anulado}
      */
      IF f_esta_anulada_vto (psseguro) = 1
      THEN
         IF f_prod_vinc (ssproduc) = 1
         THEN
            BEGIN
               -- Bug 11301 - APD - 21/10/2009 - se a¿ade la union z.falta = p.falta
               SELECT fbaja
                 INTO fffinprest
                 FROM prestamoseg p, prestamos z
                WHERE sseguro = psseguro
                  AND z.ctapres = p.ctapres
                  AND z.falta = p.falta;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  RETURN 103286;                         --{seguro no existe}
            END;

            IF fffinprest IS NULL
            THEN
               RETURN 1;
            --{prestamo no finalizado, podemos desanular la poliza}
            ELSE
               RETURN 151690;
            --{Contrato vinculado ya anulado, no anulable, ni desanulable}
            END IF;
         ELSE
            RETURN 1;                                         --{es anulable}
         END IF;
      ELSE
         RETURN 0;          --{si ya est¿ desanulado no permitimos continuar}
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_es_desanulable',
                      1,
                      'Error no controlado',
                      SQLERRM
                     );
         RETURN 140999;                      --{No es deanulable, ni anulable}
   END f_es_desanulable;

   FUNCTION f_desanula_poliza_vto (
      psseguro   IN   NUMBER,
      pfanulac   IN   DATE,
      pnsuplem   IN   NUMBER DEFAULT NULL,
      psproduc   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      --ccvalpar       NUMBER;
      nnmovimi   NUMBER;
      num_err    NUMBER;
      ssproduc   NUMBER;
      ffvencim   DATE;
      nnsuplem   NUMBER;
   BEGIN
      --ini BUG10772-22/07/2009-JMF: CRE - Desanul¿lar programacions al venciment/propera cartera
      --Obtenemos el sproduc si es NULL, si no est¿ a nivel de seguros los buscamos en productos
      BEGIN
         SELECT sproduc, NVL (pnsuplem, nsuplem)
           INTO ssproduc, nnsuplem
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 103286;                               --{seguro no existe}
      END;

      --fin BUG10772-22/07/2009-JMF: CRE - Desanul¿lar programacions al venciment/propera cartera

      /*
            { miramos si se permite desanular movimientos}
      */
      --ini BUG10772-22/07/2009-JMF: CRE - Desanul¿lar programacions al venciment/propera cartera
      IF pac_parametros.f_parproducto_n (ssproduc, 'PROGVENCIM') = 0
      THEN
         RETURN 109905;     --{No tiene permiso para realizar esta operacion}
      END IF;

      --fin BUG10772-22/07/2009-JMF: CRE - Desanul¿lar programacions al venciment/propera cartera
      /*
            {Creamos el movimiento de desanulaci¿n}
      */
      num_err :=
         f_movseguro (psseguro,
                      NULL,
                      228,
                      1,
                      pfanulac,
                      NULL,
                      nnsuplem + 1,
                      1,
                      NULL,
                      nnmovimi,
                      f_sysdate,
                      NULL,
                      NULL
                     );

      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      /*
            {Actualizamos el historico de seguros}
      */
      num_err := f_act_hisseg (psseguro, nnmovimi - 1);

      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      /*
            {Obtenemos la fecha de vencimiento de la poliza antes de hacer la anulaci¿n}
      */
      --ini BUG10772-22/07/2009-JMF: CRE - Desanul¿lar programacions al venciment/propera cartera
      DECLARE
         n_pro   NUMBER (1);
      BEGIN
         -- existeix Motius programaci¿ a nivell de producte
         SELECT NVL (MAX (1), 0)
           INTO n_pro
           FROM parmotmov a
          WHERE a.cparmot = 'PROGVENCIMMOT'
            AND a.cvalpar = 1
            AND a.sproduc = ssproduc;

         SELECT fvencim
           INTO ffvencim
           FROM historicoseguros
          WHERE sseguro = psseguro
            AND nmovimi =
                   (SELECT NVL (MAX (nmovimi) - 1, 0)
                      FROM movseguro
                     WHERE sseguro = psseguro
                       AND cmotmov IN (
                              SELECT cmotmov
                                FROM parmotmov
                               WHERE cparmot = 'PROGVENCIMMOT'
                                 AND cvalpar = 1
                                 AND sproduc = DECODE (n_pro, 1, ssproduc, 0)));
      -- BUG10503:DRA:23/06/2009
      --fin BUG10772-22/07/2009-JMF: CRE - Desanul¿lar programacions al venciment/propera cartera
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 151643;
      --{ Esta p¿liza no tiene ning¿n movimiento de anulaci¿n al vto}
      END;

      /*
            {Actualizamos la fecha de vto.}
      */
      UPDATE seguros
         SET fvencim = ffvencim,
             nsuplem = nnsuplem + 1,               -- BUG 10772:DRA:23/11/2009
             cnotibaja = NULL
       WHERE sseguro = psseguro;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_desanula_poliza_vto',
                      1,
                      'Error no controlado',
                      SQLERRM
                     );
         RETURN 40735;                     --{Aquesta dada no pot estar buida}
   END f_desanula_poliza_vto;

   FUNCTION f_fecha_anulacion (psseguro IN NUMBER, pnriesgo IN NUMBER)
      RETURN DATE
   IS
      w_fanulac   DATE   := NULL;
      w_csituac   NUMBER;
   BEGIN
      SELECT csituac, fanulac
        INTO w_csituac, w_fanulac
        FROM seguros
       WHERE sseguro = psseguro;

      -- Si la poliza esta anulada y es una prevision de alta,
      -- retorna la fecha de la tabla motreten_rev en vez de la
      -- fecha de anulacion de la tabla seguros.
      IF f_situacion_poliza (psseguro) = 2 AND w_csituac = 4
      THEN
         SELECT v.fusuauto
           INTO w_fanulac
           FROM motreten_rev v
          WHERE v.sseguro = psseguro
            AND v.nriesgo = pnriesgo
            AND v.cresulta = 3
            AND v.nmovimi = (SELECT MAX (s.nmovimi)
                               FROM movseguro s
                              WHERE s.sseguro = psseguro)
            AND (v.nmotret, v.cmotret) =
                       (SELECT MAX (r.nmotret), MAX (r.cmotret)
                          FROM motretencion r
                         WHERE r.sseguro = psseguro AND r.nmovimi = v.nmovimi);
      END IF;

      RETURN w_fanulac;
   END f_fecha_anulacion;

/*******************************************************************************
        p_baja_automatico_vto: Procesos de baja autom¿tica
   psproduc  PARAM IN : Producto
   psseguro PARAM IN : Seguro
   pfvencim PARAM IN : Fecha referencia para el vencimiento
   psproces PARAM OUT : Proceso generado.
********************************************************************************/
----------------------------------------------------------------------------------------------------------------------------------------
   PROCEDURE p_baja_automatico_vto (
      psproduc   IN       NUMBER,
      psseguro   IN       NUMBER,
      pfvencim   IN       DATE,
      psproces   OUT      NUMBER
   )
   IS
      empresa                  NUMBER;

      /*
       BUG: 34866/202261

       */
      CURSOR polizas_a_notifica_anular (
         p_sseguro   IN   NUMBER,
         p_sproduc   IN   NUMBER,
         p_fvencim   IN   DATE,
         p_ctipo     IN   NUMBER
      )
      IS
         SELECT   s.sseguro, f_parinstalacion_n ('MONEDAINST') cmoneda,
                  cagente, sproduc, npoliza, ncertif, fvencim, cfprest,
                  s.cempres
             FROM seguros s, seguros_aho sa
            WHERE s.sseguro = NVL (p_sseguro, s.sseguro)
              AND s.sproduc = NVL (p_sproduc, s.sproduc)
              AND s.fvencim IS NOT NULL
              AND sa.sseguro(+) = s.sseguro
              AND s.fvencim <=
                       TRUNC (p_fvencim)
                     + NVL (f_parproductos_v (s.sproduc,
                                              'NOTIFICA_VENCIMIENTO'
                                             ),
                            0
                           )
              --AND s.fvencim > TRUNC(p_fvencim)
              AND s.csituac =3
              AND (s.sseguro, p_ctipo, s.fvencim) NOT IN (
                                                  SELECT sseguro, ctipo,
                                                         fecha
                                                    FROM notificaseg
                                                   WHERE sseguro = s.sseguro)
              AND sa.ndurrev IS NULL    -- p¿lizas de Europlazo no programadas
         ORDER BY sproduc;
-- IAXIS-3631 --  ECP -- 14/05/2019
      CURSOR polizas_a_vencer 
      IS
        SELECT   s.sseguro, f_parinstalacion_n ('MONEDAINST') cmoneda,
                  cagente, sproduc, npoliza, ncertif, fvencim,
                  s.cempres
             FROM seguros s
            WHERE s.fvencim + NVL (f_parproductos_v (s.sproduc,
                                              'NOTIFICA_VENCIMIENTO'
                                             ),
                            0
                           ) <=
                       TRUNC (f_sysdate)
                     
              AND s.csituac = 0
            ORDER BY sproduc;
            --  IAXIS-3631 --  ECP -- 14/05/2019

      /*
      /*
         {proceso nocturno que detecta y anula aquellas p¿lizas en que su fecha de vencimiento
      coincide con la fecha actual (pfvencim)
      Este proceso tambi¿n debe tener en cuenta que las p¿lizas de Europlazo programadas para renovar no deben ser anuladas,
      s¿lo aquellas que no est¿n programadas}
      */
      -- IAXIS-3631 --  ECP -- 14/05/2019
      CURSOR polizas_a_anular (
         p_sseguro   IN   NUMBER,
         p_sproduc   IN   NUMBER,
         p_fvencim   IN   DATE
      )
      IS
         SELECT   s.sseguro, f_parinstalacion_n ('MONEDAINST') cmoneda,
                  cagente, sproduc, npoliza, ncertif, fvencim, cfprest,
                  s.cempres
             FROM seguros s, seguros_aho sa
            WHERE s.sseguro = NVL (p_sseguro, s.sseguro)
              AND s.sproduc = NVL (p_sproduc, s.sproduc)
              --AND s.npoliza = (801001415)
              AND s.fvencim IS NOT NULL
              AND sa.sseguro(+) = s.sseguro
              AND s.fvencim + NVL (f_parproductos_v (s.sproduc, 'DIASVTO'), 0) <=
                       TRUNC (p_fvencim)
                     
              AND s.csituac = 3
              AND pac_motretencion.f_esta_retenica_sin_resc (s.sseguro,
                                                             p_fvencim
                                                            ) = 0
              AND sa.ndurrev IS NULL    -- p¿lizas de Europlazo no programadas
         ORDER BY sproduc;
         -- IAXIS-3631 --  ECP -- 14/05/2019

      /*
                                                {p¿lizas que est¿n en suplemento y no se pueden anualar, solo avisamos}
      */
      CURSOR polizas_a_avisar (
         p_sseguro   IN   NUMBER,
         p_sproduc   IN   NUMBER,
         p_fvencim   IN   DATE
      )
      IS
         SELECT   sseguro, f_parinstalacion_n ('MONEDAINST') cmoneda, cagente,
                  sproduc, npoliza, ncertif, fvencim, csituac
             FROM seguros s
            WHERE s.sseguro = NVL (p_sseguro, s.sseguro)
              AND s.sproduc = NVL (p_sproduc, s.sproduc)
              AND s.fvencim IS NOT NULL
              AND s.fvencim <=
                       TRUNC (p_fvencim)
                     + NVL (f_parproductos_v (s.sproduc, 'DIASVTO'), 0)
              AND (   s.csituac IN (4, 5)
                   OR (    s.csituac = 0
                       AND pac_motretencion.f_esta_retenica_sin_resc
                                                                   (s.sseguro,
                                                                    p_fvencim
                                                                   ) = 1
                      )
                  )
         ORDER BY sproduc;

      -- Bug 0012811 AVT 21-01-2010 control productes amb rescat
      -- Bug 14265 - JRH - 23/04/2010 -  Pasamos la empresa como par¿metro
      CURSOR tieneresc (psproduc IN NUMBER, p_empresa IN NUMBER)
      IS
         -- Fi Bug 14265 - JRH - 23/04/2010
         SELECT 1
           FROM sin_gar_causa_motivo g, sin_causa_motivo c
          WHERE g.scaumot = c.scaumot
            AND sproduc = psproduc
            AND ccausin = 3
            -- BUG 13916-  03/2009 - JRH  - Se deben tener en cuenta los dos modelos de siniestros
            AND NVL (pac_parametros.f_parempresa_n (p_empresa, 'MODULO_SINI'),
                     0
                    ) = 1
         UNION
         SELECT 1
           FROM prodcaumotsin p
          WHERE p.sproduc = psproduc
            AND p.ccausin = 3
            AND NVL (pac_parametros.f_parempresa_n (p_empresa, 'MODULO_SINI'),
                     0
                    ) = 0;

      --Bug 0035712  14/05/2015 vencimiento de las garant¿as adicionales
      CURSOR polizas_a_notifica_adicionales (
         p_sseguro   IN   NUMBER,
         p_sproduc   IN   NUMBER,
         p_fvencim   IN   DATE,
         p_ctipo     IN   NUMBER
      )
      IS
         SELECT DISTINCT s.sseguro
                    FROM seguros s, garanseg g
                   WHERE s.sseguro = NVL (p_sseguro, s.sseguro)
                     AND s.sproduc = NVL (p_sproduc, s.sproduc)
                     AND s.sseguro = g.sseguro
                     AND g.ffinefe IS NULL
                     AND pac_seguros.f_vto_garantia (g.sseguro,
                                                     g.nriesgo,
                                                     g.cgarant,
                                                     g.nmovimi
                                                    ) <=
                              TRUNC (p_fvencim)
                            + NVL (f_parproductos_v (s.sproduc,
                                                     'NOTIFICA_VENCIMIENTO'
                                                    ),
                                   0
                                  )
                     AND pac_seguros.f_vto_garantia (g.sseguro,
                                                     g.nriesgo,
                                                     g.cgarant,
                                                     g.nmovimi
                                                    ) > TRUNC (p_fvencim)
                     AND s.csituac = 0
                     AND (s.sseguro, p_ctipo, s.fvencim) NOT IN (
                                                  SELECT sseguro, ctipo,
                                                         fecha
                                                    FROM notificaseg
                                                   WHERE sseguro = s.sseguro);

      -- Fi BUG 13916-  03/2009 - JRH  - Se deben tener en cuenta los dos modelos de siniestros
      fecha_vencimiento        DATE;
      num_err                  NUMBER;
      rpend                    recibos_pend;
      -- Bug 20664 - RSC - 12/01/2012 - LCOL_T001-LCOL - UAT - TEC - Anulaciones y Rehabilitaciones
      rpend_aux                recibos_pend;
      -- Fin Bug 20664
      rcob                     recibos_cob;
      vcmotmov                 NUMBER;
      --v_polizas_anu  VARCHAR2(3000);
      --v_polizas_err  VARCHAR2(3000);
      --v_polizas_avi  VARCHAR2(3000);
      --v_message      VARCHAR2(5000);
      --v_from         VARCHAR2(100);
      --v_to           VARCHAR2(100);
      error                    NUMBER;
      --      sproces              NUMBER;
      nprolin                  NUMBER;
      cont_malos               NUMBER                   := 0;
      texto                    VARCHAR2 (150);
      v_csitvto                NUMBER;
      cavis                    NUMBER;
      pdatos                   NUMBER;
      texto2                   VARCHAR2 (40);
      xnivel                   NUMBER;
      ocoderror                NUMBER;
      omsgerror                VARCHAR2 (2000);
      v_anyos_alargar_vencim   NUMBER;
      voficina                 VARCHAR2 (4);
      -- Bug 12166 - RSC - 20/11/2009 - CRE - Ajuste en anulaci¿n al vto para productos de inversi¿n
      v_fecha_resc             DATE;
      -- Bug 12811 AVT 21-01-2010
      tier                     NUMBER;
      v_cmotven                movseguro.cmotven%TYPE;
      -- FIn Bug 12166

      -- Bug 19312 - RSC - 24/11/2011 - LCOL_T004 - Parametrizaci¿n Anulaciones
      vcont                    NUMBER                   := 1;
      vcur                     sys_refcursor;
      vmarcado                 NUMBER;
      vtagente                 VARCHAR2 (200);
      vttiprec                 VARCHAR2 (200);
      vitotalr                 NUMBER;
      v_sperson                VARCHAR2 (200);
      v_per_notif_prefe        NUMBER;
      v_email                  VARCHAR2 (200);
      -- Fin Bug 19312
      -- BUG: 34866/202261
      v_ctipo                  NUMBER;
      t_imp                    t_iax_impresion          := t_iax_impresion ();
      t_mensajes               t_iax_mensajes;
      v_retemail               NUMBER;
      vnumerr                  NUMBER (8)               := 0;
      vseguro                  seguros.sseguro%TYPE;
      cont                     NUMBER                   := 1;
      v_res                    NUMBER;
      v_filename               VARCHAR2 (200);
      v_pruta                  VARCHAR2 (200);
      v_importe                NUMBER;
      v_nriesgo                riesgos.nriesgo%TYPE;
      v_traza                  NUMBER;
      v_ctipo_add              NUMBER;
      -- FIN BUG: 34866/202261
      vagente                  NUMBER;
   BEGIN
      /*
         reservamos el numero de proceso para la anulacion
      */
      BEGIN
         SELECT cempres
           INTO empresa
           FROM usuarios
          WHERE cusuari = f_user;

         SELECT ctipo
           INTO v_ctipo
           FROM cfg_plantillas_tipos
          WHERE ttipo = 'VENCIMIENTOS';
      END;

      BEGIN
         SELECT ctipo
           INTO v_ctipo_add
           FROM cfg_plantillas_tipos
          WHERE ttipo = 'VENCIMIENTO_GARAN';
      EXCEPTION
         WHEN OTHERS
         THEN
            v_ctipo_add := 0;
      END;

      error :=
         f_procesini (f_user,
                      empresa,
                      'pac_anulacion',
                      'Anulaciones vto',
                      psproces
                     );
      vcmotmov := 322;                --{Anulaci¿ per venciment de la p¿lissa}
      fecha_vencimiento := TRUNC (NVL (pfvencim, f_sysdate));

      /*
          BUG: 34866/202261

          */
          -- IAXIS-3631 --  ECP -- 14/05/2019
       FOR c IN polizas_a_vencer 
      LOOP
      
      
         UPDATE seguros
            SET csituac = 3
          WHERE sseguro = c.sseguro;
          
      END LOOP;
      -- IAXIS-3631 --  ECP -- 14/05/2019
  
      FOR c IN polizas_a_notifica_adicionales (psseguro,
                                               psproduc,
                                               fecha_vencimiento,
                                               v_ctipo_add
                                              )
      LOOP
         v_traza := 5;
        
         IF pac_seguros.f_suspendida (c.sseguro, pfvencim) = 0
         THEN     --JRH S¿lo generamos la documentaci¿n si no est¿ suspendida
            SELECT sperson
              INTO v_sperson
              FROM tomadores
             WHERE sseguro = c.sseguro AND nordtom = 1;

            SELECT cagente
              INTO vagente
              FROM seguros
             WHERE sseguro = c.sseguro;

            BEGIN
               SELECT nvalpar
                 INTO v_per_notif_prefe
                 FROM per_parpersonas
                WHERE cparam = 'PER_NOTIF_PREFE'
                  AND sperson = v_sperson
                  AND cagente = ff_agente_cpervisio (vagente);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_per_notif_prefe := 0;
            END;

            -- IF v_per_notif_prefe = 0 THEN
            pac_isql.p_docs_vencimiento_add (psproces, c.sseguro);

            /* ELSIF v_per_notif_prefe = 1 THEN
                t_imp := pac_md_impresion.f_get_documprod_tipo(c.sseguro, v_ctipo_add,
                                                               pac_md_common.f_get_cxtidioma,
                                                               t_mensajes);

                IF t_imp IS NOT NULL THEN
                   -- 1.- Recuperar el email de la persona:
                   SELECT MAX(tvalcon)
                     INTO v_email
                     FROM per_contactos p1
                    WHERE p1.sperson = v_sperson
                      AND p1.ctipcon = 3
                      AND p1.cmodcon IN(SELECT MIN(cmodcon)
                                          FROM per_contactos p2
                                         WHERE p2.sperson = p1.sperson
                                           AND p2.ctipcon = p1.ctipcon);

                   IF v_email IS NOT NULL THEN
                      v_res := pac_util.f_path_filename(t_imp(1).fichero, v_pruta, v_filename);
                      v_retemail :=
                         pac_md_informes.f_enviar_mail
                                                 (NULL, v_email, NULL, v_filename,
                                                  f_axis_literales(9908048,
                                                                   pac_md_common.f_get_cxtidioma),
                                                  NULL, NULL, NULL);
                   END IF;
                END IF;
             END IF;*/
            BEGIN
               INSERT INTO notificaseg
                           (sseguro, ctipo, fecha,
                            fregistra, sproces
                           )
                    VALUES (c.sseguro, v_ctipo_add, fecha_vencimiento,
                            f_sysdate, psproces
                           );
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  UPDATE notificaseg
                     SET fregistra = f_sysdate
                   WHERE sseguro = c.sseguro
                     AND ctipo = v_ctipo_add
                     AND fecha = fecha_vencimiento;
            END;
         END IF;
      END LOOP;

     

      FOR c IN polizas_a_notifica_anular (psseguro,
                                          psproduc,
                                          fecha_vencimiento,
                                          v_ctipo
                                         )
      LOOP
         -- Ver punto 5.-
         IF pac_seguros.f_suspendida (c.sseguro, pfvencim) = 0
         THEN     --JRH S¿lo generamos la documentaci¿n si no est¿ suspendida
            SELECT sperson
              INTO v_sperson
              FROM tomadores
             WHERE sseguro = c.sseguro AND nordtom = 1;

            SELECT cagente
              INTO vagente
              FROM seguros
             WHERE sseguro = c.sseguro;

            BEGIN
               SELECT nvalpar
                 INTO v_per_notif_prefe
                 FROM per_parpersonas
                WHERE cparam = 'PER_NOTIF_PREFE'
                  AND sperson = v_sperson
                  AND cagente = ff_agente_cpervisio (vagente);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_per_notif_prefe := 0;
            END;

            --IF v_per_notif_prefe = 0 THEN
            pac_isql.p_docs_vencimiento (psproces, c.sseguro);

            /* ELSIF v_per_notif_prefe = 1 THEN
               t_imp := pac_md_impresion.f_get_documprod_tipo(c.sseguro, v_ctipo,
                                                              pac_md_common.f_get_cxtidioma,
                                                              t_mensajes);

               IF t_imp IS NOT NULL THEN
                  -- 1.- Recuperar el email de la persona:
                  SELECT MAX(tvalcon)
                    INTO v_email
                    FROM per_contactos p1
                   WHERE p1.sperson = v_sperson
                     AND p1.ctipcon = 3
                     AND p1.cmodcon IN(SELECT MIN(cmodcon)
                                         FROM per_contactos p2
                                        WHERE p2.sperson = p1.sperson
                                          AND p2.ctipcon = p1.ctipcon);

                  IF v_email IS NOT NULL THEN
                     v_res := pac_util.f_path_filename(t_imp(1).fichero, v_pruta, v_filename);
                     v_retemail :=
                        pac_md_informes.f_enviar_mail
                                                (NULL, v_email, NULL, v_filename,
                                                 f_axis_literales(9907895,
                                                                  pac_md_common.f_get_cxtidioma),
                                                 NULL, NULL, NULL);
                  END IF;
               END IF;
            END IF;*/
            

            BEGIN
               INSERT INTO notificaseg
                           (sseguro, ctipo, fecha, fregistra,
                            sproces
                           )
                    VALUES (c.sseguro, v_ctipo, c.fvencim, f_sysdate,
                            psproces
                           );
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  UPDATE notificaseg
                     SET fregistra = f_sysdate
                   WHERE sseguro = c.sseguro
                     AND ctipo = v_ctipo
                     AND fecha = c.fvencim;
            END;
         END IF;
      END LOOP;

       FOR c IN polizas_a_anular(psseguro, psproduc, fecha_vencimiento) LOOP
          texto := NULL;
          -- Las p¿lizas de riesgo se anulan. Las p¿lizas de ahorro no se anulan
          -- si no que abren un rescate por vencimiento o se abre prestaci¿n en forma
          -- de renta
          -- Bug 0012811 AVT 21-01-2010 mirem si la p¿lissa te la possiblitat de rescatar
          tier := NULL;

          OPEN tieneresc(c.sproduc, c.cempres);

          FETCH tieneresc
           INTO tier;

          CLOSE tieneresc;
          
          
          --Ini Bug.: 13068 - 26/02/2010 - ICV - Se busca el cmotven del ¿ltimo movimiento de anulaci¿n al vencimiento
          BEGIN
             -- Bug 20664 - APD - 17/01/2012 - se a¿ade el cmotmov = 236.-Anulacion programada al proximo recibo
             SELECT cmotven
               INTO v_cmotven
               FROM movseguro m
              WHERE m.sseguro = c.sseguro
                AND m.nmovimi = (SELECT MAX(m2.nmovimi)
                                   FROM movseguro m2
                                  WHERE m2.sseguro = m.sseguro
                                    AND m2.cmotmov IN(221, 236));
          -- fin Bug 20664 - APD - 17/01/2012
          EXCEPTION
             WHEN OTHERS THEN
                v_cmotven := NULL;
          END;

          --Fin Bug.: 13068
          IF f_prod_ahorro(c.sproduc) = 1
             -- Bug 19312 - RSC - 21/11/2011 - LCOL_T004 - Parametrizaci¿n Anulaciones
             AND pac_parametros.f_parmotmov_n(vcmotmov, 'AHORRO_PERMITE_VTO', c.sproduc) = 0 THEN
             IF c.cfprest = 1 THEN
                -- Bug 1400 - JRH - 09/10/2009 -  Proceso autom¿tico de vencimiento de p¿lizas. Seg¿n el
                -- valor de este parametro. De momento si vale 1 se tiene que anular la p¿liza, sino
                -- hacemos lo mismo que hasta ahora.
                IF NVL(f_parproductos_v(c.sproduc, 'ACCION_VTO_PREST_REN'), 0) = 1 THEN
                   -- anulamos la p¿liza, sin extorno, sin anular recibos con el cmotmov = 322}
                   -- Bug 20664 - APD - 17/01/2012 - si est¿ programada la anulaci¿n al vencimiento o a la pr¿xima cartera
                   -- la poliza debe quedar anulada, sino lo que diga el parproducto 'CSIT_VTO'
                   IF f_esta_anulada_vto(psseguro) = 1 THEN
                      -- 1.- si esta anulada al vto.
                      -- 0.- No est¿ anulada al vto.
                      v_csitvto := 2;
                   ELSE
                      v_csitvto := NVL(f_parproductos_v(c.sproduc, 'CSIT_VTO'), 2);
                   END IF;

                   -- fin Bug 20664 - APD - 17/01/2012
                   --Ini Bug.: 13068 - 26/02/2010 - ICV - Se a¿ade el paso del cmotven
                   num_err := f_anula_poliza(c.sseguro, vcmotmov,

                                             -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                             --c.cmoneda,
                                             pac_monedas.f_moneda_producto(c.sproduc),
                                             -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                             c.fvencim, 0, 0, c.cagente, rpend, rcob, c.sproduc,
                                             NULL, v_csitvto, v_cmotven);

                   IF num_err = 0 THEN
                      error := f_proceslin(psproces,
                                           'Pol.anulada:  '
                                           || f_formatopol(c.npoliza, c.ncertif, 1),
                                           num_err, nprolin, 4);   -- Correcto
                      COMMIT;
                   ELSE   --Por defecto
                      ROLLBACK;
                      texto := f_axis_literales(num_err, 1);
                      error := f_proceslin(psproces,
                                           'Error ' || texto || 'pol. '
                                           || f_formatopol(c.npoliza, c.ncertif, 1),
                                           num_err, nprolin, 1);   -- Error
                      cont_malos := cont_malos + 1;
                      p_tab_error(f_sysdate, f_user, 'pac_anulacion.p_baja_automatica_vto', 1,
                                  'error al anular', num_err);
                      COMMIT;
                   END IF;
                -- fi Bug 1400 - JRH - 09/10/2009
                ELSE
                   --en forma de renta vitalicia
                   -- deber¿amos dejar retenida la p¿liza y abrir la renta
                   error := f_proceslin(psproces,
                                        'Solicitud Renta P¿l.:  '
                                        || f_formatopol(c.npoliza, c.ncertif, 1),
                                        num_err, nprolin, 4);   -- Correcto
                END IF;
             ELSIF NVL(f_parproductos_v(c.sproduc, 'ANYOS_ALARGAR_VENCIM'), 0) > 0 THEN
                -- se debe alargar la fecha de vencimiento de la p¿liza tantos a¿os como indique el parproducto 'ANYOS_ALARGAR_VENCIM'
                BEGIN
                   SELECT cdelega
                     INTO voficina
                     FROM usuarios
                    WHERE UPPER(cusuari) = UPPER(f_user);
                EXCEPTION
                   WHEN OTHERS THEN
                      voficina := NULL;
                END;

                v_anyos_alargar_vencim := NVL(f_parproductos_v(c.sproduc, 'ANYOS_ALARGAR_VENCIM'),
                                              0);
                -- Se realiza el suplemento de cambio de fecha de vencimiento
                num_err :=
                   pac_ref_contrata_aho.f_suplemento_fvencimiento
                                                      (c.sseguro, TRUNC(f_sysdate),
                                                       TRUNC(ADD_MONTHS(c.fvencim,
                                                                        v_anyos_alargar_vencim * 12)),
                                                       voficina, NULL, f_idiomauser, ocoderror,
                                                       omsgerror);

                IF num_err = 0 THEN
                   error := f_proceslin(psproces,
                                        'Suplemento FVencimiento realizado a P¿l.:  '
                                        || f_formatopol(c.npoliza, c.ncertif, 1),
                                        num_err, nprolin, 4);   -- Correcto
                   COMMIT;
                ELSE
                   ROLLBACK;
                   error := f_proceslin(psproces,
                                        'Error ' || omsgerror
                                        || ' en el Suplemento FVencimiento P¿l.:  '
                                        || f_formatopol(c.npoliza, c.ncertif, 1),
                                        ocoderror, nprolin, 1);   -- Error;
                   cont_malos := cont_malos + 1;
                END IF;
             ELSE
                IF NVL(tier, 0) = 1 THEN
                   -- Bug 0012811 AVT 21-01-2010  si te rescat segueix fent com fins ara:
                   -- Bug 12166 - RSC - 20/11/2009 - CRE - Ajuste en anulaci¿n al vto para productos de inversi¿n
                   IF NVL(f_parproductos_v(c.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
                      v_fecha_resc := GREATEST(f_sysdate, c.fvencim);
                   ELSE
                      v_fecha_resc := c.fvencim;
                   END IF;

                   -- Fin Bug 12166

                   -- BUG 13916-  03/2009 - JRH  - Se deben tener en cuenta los dos modelos de siniestros
                   IF NVL(pac_parametros.f_parempresa_n(c.cempres, 'MODULO_SINI'), 0) = 0 THEN
                      -- Fi BUG 13916-  03/2009 - JRH

                      -- abrimos rescate por vencimiento
                      num_err := pac_rescates.f_valida_permite_rescate(c.sseguro, NULL,
                                                                       v_fecha_resc, 3);

                      -- vencimiento
                      IF num_err <> 0 THEN
                         texto := f_axis_literales(num_err, 1);
                         error := f_proceslin(psproces,
                                              'P¿l. no permite rescate ' || texto || ' :  '
                                              || f_formatopol(c.npoliza, c.ncertif, 1),
                                              num_err, nprolin, 1);   -- Error
                      ELSE
                         num_err := pac_rescates.f_avisos_rescates(c.sseguro, v_fecha_resc, NULL,
                                                                   cavis, pdatos);

                         IF cavis IS NOT NULL THEN
                            xnivel := 2;   -- no se generan datos
                         ELSE
                            xnivel := 1;   -- se generar¿n tambi¿n los pagos
                         END IF;

                         num_err := pac_rescates.f_sol_rescate(c.sseguro, c.sproduc, 1, NULL, 2, 3,
                                                               NULL, v_fecha_resc, NULL, NULL,
                                                               NULL, NULL, xnivel);

                         IF num_err = 0 THEN
                            IF xnivel = 2 THEN
                               texto2 := ' sin pagos generados';
                            END IF;

                            error := f_proceslin(psproces,
                                                 'Rescate abierto' || texto2 || ' P¿l.:  '
                                                 || f_formatopol(c.npoliza, c.ncertif, 1),
                                                 num_err, nprolin, 4);   -- Correcto
                            COMMIT;
                         ELSE
                            ROLLBACK;
                            texto := f_axis_literales(num_err, 1);
                            error := f_proceslin(psproces,
                                                 'Error ' || texto || ' en el rescate P¿l.:  '
                                                 || f_formatopol(c.npoliza, c.ncertif, 1),
                                                 num_err, nprolin, 1);   -- Error;
                            cont_malos := cont_malos + 1;
                         END IF;
                      END IF;
                   ELSE
                      --Modulo nuevo
                      -- Bug 31548/206536
                      IF NVL(f_parproductos_v(c.sproduc, 'RESCATE_UNIDAD_PEND'), 0) IN(2, 3) THEN
                         v_importe := calc_rescates.fvalvenctotaho(NULL, c.sseguro,
                                                                   TO_CHAR(v_fecha_resc,
                                                                           'YYYYMMDD'));

                         BEGIN
                            SELECT r.nriesgo
                              INTO v_nriesgo
                              FROM riesgos r
                             WHERE r.sseguro = c.sseguro
                               AND r.nmovima = 1;
                         EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                               v_nriesgo := NULL;
                         END;

                         num_err := pac_md_sin_rescates.f_sol_rescate_fnd(c.sseguro, v_nriesgo,
                                                                          v_fecha_resc,
                                                                          f_usu_idioma, NULL, 2,
                                                                          v_importe, NULL, NULL,
                                                                          NULL, 3);

                         IF num_err <> 0 THEN
                            texto := f_axis_literales(num_err, 1);
                            error := f_proceslin(psproces,
                                                 'Error ' || texto || ' en el sin rescate P¿l.:  '
                                                 || f_formatopol(c.npoliza, c.ncertif, 1),
                                                 num_err, nprolin, 1);   -- Error;
                            cont_malos := cont_malos + 1;
                         END IF;
                      ELSE
                         -- abrimos rescate por vencimiento
                         num_err := pac_sin_rescates.f_valida_permite_rescate(c.sseguro, NULL,
                                                                              v_fecha_resc, 3);

                         -- vencimiento
                         IF num_err <> 0 THEN
                            texto := f_axis_literales(num_err, 1);
                            error := f_proceslin(psproces,
                                                 'P¿l. no permite rescate ' || texto || ' :  '
                                                 || f_formatopol(c.npoliza, c.ncertif, 1),
                                                 num_err, nprolin, 1);   -- Error
                         ELSE
                            num_err := pac_sin_rescates.f_avisos_rescates(c.sseguro, v_fecha_resc,
                                                                          NULL, cavis, pdatos);

                            IF cavis IS NOT NULL THEN
                               xnivel := 2;   -- no se generan datos
                            ELSE
                               xnivel := 1;   -- se generar¿n tambi¿n los pagos
                            END IF;

                            num_err := pac_sin_rescates.f_sol_rescate(c.sseguro, c.sproduc, 1,
                                                                      NULL, 2, 3, NULL,
                                                                      v_fecha_resc, NULL, NULL,
                                                                      NULL, NULL, xnivel);

                            IF num_err = 0 THEN
                               IF xnivel = 2 THEN
                                  texto2 := ' sin pagos generados';
                               END IF;

                               error := f_proceslin(psproces,
                                                    'Rescate abierto' || texto2 || ' P¿l.:  '
                                                    || f_formatopol(c.npoliza, c.ncertif, 1),
                                                    num_err, nprolin, 4);   -- Correcto
                               COMMIT;
                            ELSE
                               ROLLBACK;
                               texto := f_axis_literales(num_err, 1);
                               error := f_proceslin(psproces,
                                                    'Error ' || texto || ' en el rescate P¿l.:  '
                                                    || f_formatopol(c.npoliza, c.ncertif, 1),
                                                    num_err, nprolin, 1);   -- Error;
                               cont_malos := cont_malos + 1;
                            END IF;
                         END IF;
                      END IF;
                   END IF;
                END IF;
             END IF;   -- de cfprest
          --ELSE   -- de f_prod_ahorro
          END IF;

          -- Bug 0012811 AVT 21-01-2010 si no te rescat s'anul¿la igual que si no ¿s d'estalvi
          IF NVL(f_prod_ahorro(c.sproduc), 0) <> 1
             OR NVL(tier, 0) = 0
             OR
               -- Bug 19312 - RSC - 21/11/2011 - LCOL_T004 - Parametrizaci¿n Anulaciones
               pac_parametros.f_parmotmov_n(vcmotmov, 'AHORRO_PERMITE_VTO', c.sproduc) = 1 THEN
             -- anulamos la p¿liza, sin extorno, sin anular recibos con el cmotmov = 322}
             -- Bug 20664 - APD - 17/01/2012 - si est¿ programada la anulaci¿n al vencimiento o a la pr¿xima cartera
             -- la poliza debe quedar anulada, sino lo que diga el parproducto 'CSIT_VTO'
             IF f_esta_anulada_vto(psseguro) = 1 THEN
                -- 1.- si esta anulada al vto.
                -- 0.- No est¿ anulada al vto.
                v_csitvto := 2;
             ELSE
                v_csitvto := NVL(f_parproductos_v(c.sproduc, 'CSIT_VTO'), 2);
             END IF;

             -- fin Bug 20664 - APD - 17/01/2012
             -- Bug 19312 - RSC - 24/11/2011 - LCOL_T004 - Parametrizaci¿n Anulaciones
             IF pac_parametros.f_parmotmov_n(vcmotmov, 'ANULA_PENDIENTES_VTO', c.sproduc) = 1 THEN
                -- Bug 20664 - RSC - 12/01/2012 - LCOL_T001-LCOL - UAT - TEC - Anulaciones y Rehabilitaciones
                rpend := rpend_aux;   -- Reset
                -- Fin bug 20664
                vcur := pac_anulacion.f_recibos(c.sseguro, c.fvencim, 0,
                                                pac_md_common.f_get_cxtidioma, num_err);

                IF num_err <> 0 THEN
                   ROLLBACK;
                   texto := f_axis_literales(num_err, 1);
                   error := f_proceslin(psproces,
                                        'Error ' || texto || 'pol. '
                                        || f_formatopol(c.npoliza, c.ncertif, 1),
                                        num_err, nprolin, 1);   -- Error
                   cont_malos := cont_malos + 1;
                   p_tab_error(f_sysdate, f_user, 'pac_anulacion.p_baja_automatica_vto', 1,
                               'error al anular', num_err);
                   COMMIT;
                END IF;

                FETCH vcur
                 INTO rpend(vcont).nrecibo, rpend(vcont).fefecto, rpend(vcont).fvencim,
                      rpend(vcont).fmovini, vmarcado, vtagente, vttiprec, vitotalr;

                WHILE vcur%FOUND LOOP
                   vcont := vcont + 1;

                   FETCH vcur
                    INTO rpend(vcont).nrecibo, rpend(vcont).fefecto, rpend(vcont).fvencim,
                         rpend(vcont).fmovini, vmarcado, vtagente, vttiprec, vitotalr;
                END LOOP;
             END IF;

             -- Bug 19312

             --Ini Bug.: 13068 - 26/02/2010 - ICV - Se a¿ade el paso del cmotven
             num_err := f_anula_poliza(c.sseguro, vcmotmov,

                                       -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                       --c.cmoneda,
                                       pac_monedas.f_moneda_producto(c.sproduc),
                                       -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                       c.fvencim, 0,
                                       pac_parametros.f_parmotmov_n(vcmotmov,
                                                                    'ANULA_PENDIENTES_VTO',
                                                                    c.sproduc),
                                       c.cagente, rpend, rcob, c.sproduc, NULL, v_csitvto,
                                       v_cmotven);

             IF num_err = 0 THEN
                error := f_proceslin(psproces,
                                     'Pol.anulada:  ' || f_formatopol(c.npoliza, c.ncertif, 1),
                                     num_err, nprolin, 4);   -- Correcto
                COMMIT;
             ELSE
                ROLLBACK;
                texto := f_axis_literales(num_err, 1);
                error := f_proceslin(psproces,
                                     'Error ' || texto || 'pol. '
                                     || f_formatopol(c.npoliza, c.ncertif, 1),
                                     num_err, nprolin, 1);   -- Error
                cont_malos := cont_malos + 1;
                p_tab_error(f_sysdate, f_user, 'pac_anulacion.p_baja_automatica_vto', 1,
                            'error al anular', num_err);
                COMMIT;
             END IF;

             -- Bug 33632/209114
             IF num_err = 0 THEN
                SELECT ctipo
                  INTO v_ctipo
                  FROM cfg_plantillas_tipos
                 WHERE ttipo = 'VENCIMIENTO_LETTER';

                SELECT sperson
                  INTO v_sperson
                  FROM tomadores
                 WHERE sseguro = c.sseguro
                   AND nordtom = 1;

                SELECT cagente
                  INTO vagente
                  FROM seguros
                 WHERE sseguro = c.sseguro;

                BEGIN
                   SELECT nvalpar
                     INTO v_per_notif_prefe
                     FROM per_parpersonas
                    WHERE cparam = 'PER_NOTIF_PREFE'
                      AND sperson = v_sperson
                      AND cagente = ff_agente_cpervisio(vagente);
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                      v_per_notif_prefe := 0;
                END;

                --IF v_per_notif_prefe = 0 THEN
                pac_isql.p_docs_vencimiento_letter(psproces, c.sseguro);

                -- Si el m¿todo es env¿o por correo
                /*ELSIF v_per_notif_prefe = 1 THEN
                   t_imp :=
                      pac_md_impresion.f_get_documprod_tipo(c.sseguro, v_ctipo,
                                                            pac_md_common.f_get_cxtidioma,
                                                            t_mensajes);

                   IF t_imp IS NOT NULL THEN
                      -- 1.- Recuperar el email de la persona:
                      SELECT MAX(tvalcon)
                        INTO v_email
                        FROM per_contactos p1
                       WHERE p1.sperson = v_sperson
                         AND p1.ctipcon = 3
                         AND p1.cmodcon IN(SELECT MIN(cmodcon)
                                             FROM per_contactos p2
                                            WHERE p2.sperson = p1.sperson
                                              AND p2.ctipcon = p1.ctipcon);

                      IF v_email IS NOT NULL THEN
                         v_res := pac_util.f_path_filename(t_imp(1).fichero, v_pruta,
                                                           v_filename);
                         v_retemail :=
                            pac_md_informes.f_enviar_mail
                                              (NULL, v_email, NULL, v_filename,
                                               f_axis_literales(9908319,
                                                                pac_md_common.f_get_cxtidioma),
                                               NULL, NULL, NULL);
                      END IF;
                   END IF;
                END IF;*/
                BEGIN
                   INSERT INTO notificaseg
                               (sseguro, ctipo, fecha, fregistra, sproces)
                        VALUES (c.sseguro, v_ctipo, c.fvencim, pfvencim, psproces);
                EXCEPTION
                   WHEN DUP_VAL_ON_INDEX THEN
                      UPDATE notificaseg
                         SET fregistra = pfvencim
                       WHERE sseguro = c.sseguro
                         AND ctipo = v_ctipo
                         AND fecha = c.fvencim;
                END;
             END IF;
          END IF;
       END LOOP;

      /*
                                                   {p¿lizas que est¿n en suplemento y no se pueden anualar, solo avisamos}
      */
      FOR c IN polizas_a_avisar (psseguro, psproduc, fecha_vencimiento)
      LOOP
         IF c.csituac IN (4, 5)
         THEN
            error :=
               f_proceslin (psproces,
                               'No se anula, esta en propuesta, Pol. :   '
                            || f_formatopol (c.npoliza, c.ncertif, 1),
                            num_err,
                            nprolin,
                            2
                           );                                         -- Aviso
         ELSE
            error :=
               f_proceslin
                  (psproces,
                      'No se anula, est¿ retenida por siniestro o rescate, Pol. :   '
                   || f_formatopol (c.npoliza, c.ncertif, 1),
                   num_err,
                   nprolin,
                   2
                  );                                                  -- Aviso
         END IF;

         COMMIT;
      END LOOP;

      num_err := f_procesfin (psproces, cont_malos);
   EXCEPTION
      WHEN OTHERS
      THEN
         -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF tieneresc%ISOPEN
         THEN
            CLOSE tieneresc;
         END IF;

         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.p_baja_automatica_vto',
                      2,
                      'error al anular',
                      SQLERRM
                     );
   END p_baja_automatico_vto;

   PROCEDURE p_baja_automatico_solicitudes (
      psproduc     IN       NUMBER,
      psseguro     IN       NUMBER,
      pfcancel     IN       DATE,
      psproces     OUT      NUMBER,
      poriduplic   IN       NUMBER DEFAULT NULL
   )
   IS
      CURSOR solicitudes (
         p_sseguro   IN   NUMBER,
         p_sproduc   IN   NUMBER,
         p_fcancel   IN   DATE
      )
      IS
         SELECT   s.sseguro, NVL (m.nsuplem, 0) nsuplem, s.npoliza npoliza,
                  s.ncertif ncertif, s.sproduc sproduc, s.nsolici, s.fcancel
             FROM seguros s, movseguro m
            WHERE m.sseguro = s.sseguro
              AND s.sseguro = NVL (p_sseguro, s.sseguro)
              AND s.sproduc = NVL (p_sproduc, s.sproduc)
              AND s.csituac = 4
              AND s.creteni NOT IN (3, 4)
              AND s.fcancel IS NOT NULL
              AND s.fcancel <= p_fcancel
         ORDER BY sproduc;

      CURSOR solicitudes_voluntarias (
         p_sseguro   IN   NUMBER,
         p_sproduc   IN   NUMBER,
         p_fcancel   IN   DATE
      )
      IS
         SELECT   s.sseguro, NVL (m.nsuplem, 0) nsuplem, s.npoliza npoliza,
                  s.ncertif ncertif, s.sproduc sproduc, s.nsolici, s.fcancel
             FROM seguros s, movseguro m
            WHERE m.sseguro = s.sseguro
              AND s.sseguro = NVL (p_sseguro, s.sseguro)
              AND s.sproduc = NVL (p_sproduc, s.sproduc)
              AND s.csituac = 4
              AND s.creteni IN (1)
              AND s.fcancel IS NOT NULL
              AND s.fcancel <= p_fcancel
         ORDER BY sproduc;

      v_cmotmov    NUMBER;
      empresa      NUMBER;
      texto        VARCHAR2 (150);
      error        NUMBER;
      num_err      NUMBER;
      v_nprolin    NUMBER;
      cont_malos   NUMBER         := 0;
   BEGIN
      /*
               reservamos el numero de proceso para la anulacion
      */
      BEGIN
         SELECT cempres
           INTO empresa
           FROM usuarios
          WHERE cusuari = f_user;
      END;

      error :=
         f_procesini (f_user,
                      empresa,
                      'pac_anulacion',
                      'Cancelaci¿n de Solicitudes',
                      psproces
                     );
      v_cmotmov := 376;               -- Sin respuesta por parte del candidato

      IF NVL (pac_parametros.f_parempresa_n (empresa, 'VENC_PROP_VOLUNTARIA'),
              0
             ) = 1
      THEN
         FOR aux IN solicitudes_voluntarias (psseguro, psproduc, pfcancel)
         LOOP
            num_err :=
               pk_rechazo_movimiento.f_rechazo (aux.sseguro,
                                                v_cmotmov,
                                                aux.nsuplem,
                                                3,
                                                NULL,
                                                NULL,
                                                NULL,
                                                1
                                               );                --3 Anulaci¿n

            IF num_err = 0
            THEN
               error :=
                  f_proceslin (psproces,
                               'Sol.cacelada:  ' || aux.nsolici,
                               num_err,
                               v_nprolin,
                               4
                              );                                   -- Correcto
               COMMIT;
            ELSE
               ROLLBACK;
               texto := f_axis_literales (num_err, 1);
               num_err :=
                  f_proceslin (psproces,
                               'Error ' || texto || 'sol. ' || aux.nsolici,
                               num_err,
                               v_nprolin,
                               1
                              );                                      -- Error
               cont_malos := cont_malos + 1;
               p_tab_error (f_sysdate,
                            f_user,
                            'pk_rechazo_movimiento.f_rechazo',
                            1,
                            'error al cancelar',
                            num_err
                           );
               COMMIT;
            END IF;
         END LOOP;
      ELSE
         FOR aux IN solicitudes (psseguro, psproduc, pfcancel)
         LOOP
            num_err :=
               pk_rechazo_movimiento.f_rechazo (aux.sseguro,
                                                v_cmotmov,
                                                aux.nsuplem,
                                                3,
                                                NULL,
                                                NULL,
                                                NULL,
                                                1
                                               );                --3 Anulaci¿n

            IF num_err = 0
            THEN
               error :=
                  f_proceslin (psproces,
                               'Sol.cacelada:  ' || aux.nsolici,
                               num_err,
                               v_nprolin,
                               4
                              );                                   -- Correcto
               COMMIT;
            ELSE
               ROLLBACK;
               texto := f_axis_literales (num_err, 1);
               num_err :=
                  f_proceslin (psproces,
                               'Error ' || texto || 'sol. ' || aux.nsolici,
                               num_err,
                               v_nprolin,
                               1
                              );                                      -- Error
               cont_malos := cont_malos + 1;
               p_tab_error (f_sysdate,
                            f_user,
                            'pk_rechazo_movimiento.f_rechazo',
                            1,
                            'error al cancelar',
                            num_err
                           );
               COMMIT;
            END IF;
         END LOOP;
      END IF;

      error := f_procesfin (psproces, cont_malos);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.p_baja_automatica_solicitudes',
                      2,
                      'error al anular',
                      SQLERRM
                     );
   END p_baja_automatico_solicitudes;

   /**********************************************************************************************
                                                     Llista amb tots els rebu ts d'una p¿lissa.
    Par¿metres entrada:
       psSeguro : Identificador de l'asseguran¿a   (obligatori)
       pFAnulac : Data d'anulaci¿ de la p¿lissa    (obligatori)
        pValparcial : Valida parcialmente              (opcional)  -- tarea 8435
                     1 posici¿ = 0 o 1
                     2 posici¿ = 1 no valida dies anulaci¿ (11)
                     3 posici¿ = 1 ...
   Torna :
       0 si es permet anular la p¿lissa, altrament torna un codi d'error
   **********************************************************************************************/
   FUNCTION f_valida_permite_anular_poliza (
      psseguro      IN   seguros.sseguro%TYPE,
      pfanulac      IN   seguros.fanulac%TYPE,
      pvalparcial   IN   NUMBER DEFAULT 0,
      panumasiva    IN   NUMBER DEFAULT 0
   )                                                             -- tarea 8435
      RETURN NUMBER
   IS
      -- BUG 20664 - MDS - 26/01/2012 : modificar el tipo de la variabla v_error
      --v_error        literales.slitera%TYPE;
      v_error        NUMBER;
      n_siniestros   NUMBER;
      nsiniestro     NUMBER;
      v_es_ahorro    BOOLEAN;
      v_dias_anul    NUMBER;
      v_modsini      NUMBER;
      -- BUG 20664 - MDS - 26/01/2012 : a¿adir seguimiento de la traza
      v_traza        NUMBER;
      -- Bug 20995 - RSC - 09/02/2012 - LCOL - UAT - TEC - Incidencias de Contratacion
      v_contador     NUMBER;
      -- Fin Bug 20995
         --BUG 27539 - INICIO - DCT - 15/10/2013  - LCOL_T010-LCOL - Revision incidencias qtracker (VII)
      vnpoliza       NUMBER;
      visaldo_prod   NUMBER;
      vcount         NUMBER;
      v_sproduc      seguros.sproduc%TYPE;

      --BUG 27539 - FIN - DCT - 15/10/2013  - LCOL_T010-LCOL - Revision incidencias qtracker (VII)
      --BUG:23817/128727: DCT : 14/11/2012: FIN
         --BUG 27539 - INICIO - DCT - 15/10/2013  - LCOL_T010-LCOL - Revision incidencias qtracker (VII)
      CURSOR cur_certif (p_npoliza IN NUMBER)
      IS
         SELECT   sseguro, npoliza, ncertif
             FROM seguros
            WHERE npoliza = p_npoliza
              -- BUG 0026835 - FAL - 21/11/2013
              --AND csituac <> 2
              AND csituac NOT IN (2, 3)
              -- FI BUG 0026835
              AND NOT (csituac = 4 AND creteni = 4)
              AND ncertif <> 0
         ORDER BY ncertif;
   --BUG 27539 - FIN - DCT - 15/10/2013  - LCOL_T010-LCOL - Revision incidencias qtracker (VII)
   BEGIN
      v_traza := 1;
      -- ini BUG 0024832 - 12/12/2012 - JMF
      v_error := pac_seguros.f_anul_obert (psseguro);

      IF v_error <> 0
      THEN
         RETURN v_error;
      END IF;

      -- fin BUG 0024832 - 12/12/2012 - JMF

      -- Bug 26070 - RSC - 11/02/2013 - LCOL_T010-LCOL - Revision incidencias (modificaci¿n cursor)
      IF panumasiva = 0
      THEN
         -- Fin Bug 26070
         IF pac_seguros.f_get_escertifcero (NULL, psseguro) <> 1
         THEN
            -- ini BUG 0025033 - 14/12/2012 - JMF
            IF pac_seguros.f_suplem_obert (psseguro) <> 0
            THEN
               RETURN 9904544;
            END IF;
         -- fin BUG 0025033 - 14/12/2012 - JMF
         END IF;
      -- Bug 26070 - RSC - 11/02/2013 - LCOL_T010-LCOL - Revision incidencias (modificaci¿n cursor)
      END IF;

      -- Fin bug 26070

      --v_error := 111360;   -- P¿lissa no existeix

      --BUG 27539 - INICIO - DCT - 15/10/2013  - LCOL_T010-LCOL - Revision incidencias qtracker (VII)
      -- BUG 23817 - DCT - 13/11/2012 : 0023817: LCOL - Anulaci¿n de colectivos :  INICIO. A¿adir pac_seguros.f_suplem_obert(psseguro) = 0
      -- BUG 20664 - MDS - 26/01/2012 : a¿adir validaci¿n de los campos fcaranu, creteni
      FOR rseguros IN (SELECT sseguro, csituac, fefecto, fvencim, sproduc,
                              cempres, fcaranu, creteni, npoliza
                         FROM seguros
                        WHERE sseguro = psseguro
                          AND pac_seguros.f_suplem_obert (psseguro) = 0)
      LOOP
         -- BUG 23817 - DCT - 13/11/2012 : 0023817: LCOL - Anulaci¿n de colectivos :  FIN: A¿adir pac_seguros.f_suplem_obert(psseguro) = 0
         v_error := 0;                         -- Inicialment tot ¿s correcte

         -- Validaci¿ de la situaci¿ de la p¿lissa : ha d'estar a 0
         IF rseguros.csituac = 1
         THEN
            v_error := 101480;
         ELSIF rseguros.csituac = 2
         THEN
            v_error := 101483;
         ELSIF rseguros.csituac = 3
         THEN
            v_error := 101484;
         ELSIF rseguros.csituac = 4
         THEN
            v_error := 101666;
         ELSIF rseguros.csituac = 5
         THEN
            v_error := 101481;
         -- Bug 23940 - APD - 09/11/2012
         ELSIF rseguros.csituac = 17
         THEN
            v_error := 9904476;
         -- fin Bug 23940 - APD - 09/11/2012
         ELSIF rseguros.csituac NOT IN (0, 12, 14, 16)
         THEN
            v_error := 101947;
         ELSE
            v_traza := 2;

            -- Validem la data d'anul¿laci¿ :
                     -- 1.- Ha de ser posterior o igual a la data d'efecte i anterior a la data de cartera o venciment
            IF rseguros.fefecto > pfanulac
            THEN
               v_error := 101203;
            ELSIF (rseguros.fvencim IS NOT NULL
                   AND rseguros.fvencim < pfanulac
                  )
            THEN
               v_error := 109241;
            -- ini BUG 20664 - MDS - 26/01/2012
            -- a¿adir validaci¿n del campo fcaranu
            ELSIF (rseguros.fcaranu IS NOT NULL
                   AND rseguros.fcaranu < pfanulac
                  )
            THEN
               v_error := 9903181;
            -- a¿adir validaci¿n del campo creteni
            ELSIF (rseguros.creteni <> 0)
            THEN
               v_error := 103816;
            -- fin BUG 20664 - MDS - 26/01/2012
            ELSE
               v_es_ahorro :=
                           (f_esahorro (NULL, rseguros.sseguro, v_error) = 1
                           );

               -- tarea 8435
               IF NVL (SUBSTR (pvalparcial, 2, 1), 0) = 1
               THEN
                  v_dias_anul := NULL;
               ELSE
                  -- tarea 8435
                  -- No es pot anul¿lar despr¿s dels dies indicats al par¿metre DIAS_ANUL
                  v_dias_anul :=
                             f_parproductos_v (rseguros.sproduc, 'DIAS_ANUL');
               END IF;

               v_traza := 3;

               -- BUG15936:DRA:13/09/2010:Inici
--               p_tab_error(f_sysdate, f_user, 'pac_anulacion.f_valida_permite_anular_poliza',
--                           psseguro,
--                           'v_dias_anul: ' || v_dias_anul || ' fefecto: ' || rseguros.fefecto
--                           || '  pfanulac: ' || TO_CHAR(pfanulac, 'DD-MM-YYYY'),
--                           'v_error: ' || v_error || ' fecha: ' || f_sysdate);

               -- BUG15936:DRA:13/09/2010:Fi
               IF     v_dias_anul IS NOT NULL
                  AND (v_dias_anul + rseguros.fefecto < TRUNC (f_sysdate))
               THEN
                  v_error := 180382;
               -- Nom¿s es pot anul¿lar els primers 15 dies.
               ELSE
                  -- 2.- Per una p¿lissa d'estalvi ha de ser igual a la data d'efecte
                  IF     v_es_ahorro
                     AND rseguros.fefecto <> pfanulac
                     AND NVL
                            (pac_parametros.f_parproducto_n
                                                         (rseguros.sproduc,
                                                          'EXCEP_ANUL_PERMITE'
                                                         ),
                             0
                            ) = 0
                  THEN                               --Bug17205#XPL#07/01/2011
                     v_error := 151432;
                  ELSE
                     -- No pot tenir sinistres pendents
                     --BUG 27539 - INICIO - DCT - 15/10/2013  - LCOL_T010-LCOL - Revision incidencias qtracker (VII)
                     --Buscamos en los n certificados (y no en el ncertif= 0 ya que este no tendra nunca siniestros)
                     IF     NVL (f_parproductos_v (rseguros.sproduc,
                                                   'ADMITE_CERTIFICADOS'
                                                  ),
                                 1
                                ) = 1
                        AND pac_seguros.f_es_col_admin (rseguros.sseguro) = 1
                        AND pac_seguros.f_get_escertifcero (NULL,
                                                            rseguros.sseguro
                                                           ) = 1
                     THEN
                        FOR reg IN cur_certif (rseguros.npoliza)
                        LOOP
                           v_error := f_buscasin (reg.sseguro, n_siniestros);

                           IF n_siniestros > 0
                           THEN
                              EXIT;
                           END IF;
                        END LOOP;
                     ELSE
                        v_error :=
                                  f_buscasin (rseguros.sseguro, n_siniestros);
                     END IF;

                     --BUG 27539 - FIN - DCT - 15/10/2013  - LCOL_T010-LCOL - Revision incidencias qtracker (VII)
                     IF n_siniestros > 0
                     THEN
                        -- Els sinistres han d'estar tancats o sino la data del sinistre ha de ser anteriors a la data d'anul¿laci¿
                        IF NVL
                              (pac_parametros.f_parempresa_n
                                                            (rseguros.cempres,
                                                             'VAL_CANT_SIN'
                                                            ),
                               0
                              ) = 1
                        THEN
--parametro que valida si la empresa decide tomar la cantidad de siniestros abiertos o comunicados para poder anular la poliza--
                           RETURN 89905784;
                        END IF;

                        BEGIN
                           v_modsini :=
                              NVL
                                 (pac_parametros.f_parempresa_n
                                                            (rseguros.cempres,
                                                             'MODULO_SINI'
                                                            ),
                                  0
                                 );
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              v_modsini := 0;
                        -- Cero indica que va por el modulo antiguo. Tabla siniestros
                                -- Uno indica que va por el m¿dulo nuevo. Tabla Sin_siniestros.
                        END;

                        IF v_modsini IS NULL OR v_modsini = 0
                        THEN
                           FOR rfechamax IN
                              (SELECT
                                      -- Ini 31204/12594 --ECP -- 14/05/2014  Se cambia  MAX(fsinies) fecha_max por
                                      NVL (MAX (fsinies),
                                           pfanulac - 1
                                          ) fecha_max
                                 -- Fin 1204/12594 --ECP -- 14/05/2014
                               FROM   siniestros
                                WHERE sseguro = rseguros.sseguro
                                  AND cestsin IN (0, 1))
                           LOOP
                              IF rfechamax.fecha_max > pfanulac
                              THEN
                                 v_error := 107571;
                              END IF;
                           END LOOP;
                        ELSE
                           --BUG 27539 - INICIO - DCT - 15/10/2013  - LCOL_T010-LCOL - Revision incidencias qtracker (VII)
                           IF     NVL
                                     (f_parproductos_v (rseguros.sproduc,
                                                        'ADMITE_CERTIFICADOS'
                                                       ),
                                      1
                                     ) = 1
                              AND pac_seguros.f_es_col_admin (rseguros.sseguro) =
                                                                             1
                              AND pac_seguros.f_get_escertifcero
                                                             (NULL,
                                                              rseguros.sseguro
                                                             ) = 1
                           THEN
                              -- Obtener el NPOLIZA
                              SELECT npoliza
                                INTO vnpoliza
                                FROM seguros
                               WHERE sseguro = rseguros.sseguro;

                              FOR rfechamax IN
                                 (SELECT
                                         -- Ini 31204/12594 --ECP -- 14/05/2014  Se cambia  MAX(fsinies) fecha_max por
                                         NVL (MAX (fsinies),
                                              pfanulac - 1
                                             ) fecha_max
                                    -- Fin 1204/12594 --ECP -- 14/05/2014
                                  FROM   sin_siniestro s
                                   WHERE s.sseguro IN (
                                            SELECT ss.sseguro
                                              FROM seguros ss
                                             WHERE ss.npoliza = vnpoliza
                                               AND ss.ncertif <> 0
                                               AND ss.csituac = 0)
                                     AND (SELECT m.cestsin
                                            FROM sin_movsiniestro m
                                           WHERE m.nsinies = s.nsinies
                                             AND m.nmovsin =
                                                    (SELECT MAX (mm.nmovsin)
                                                       FROM sin_movsiniestro mm
                                                      WHERE mm.nsinies =
                                                                     s.nsinies)) IN
                                                                       (0, 1))
                              LOOP
                                 IF rfechamax.fecha_max > pfanulac
                                 THEN
                                    v_error := 107571;
                                 END IF;
                              END LOOP;
                           ELSE
                              FOR rfechamax IN
                                 (SELECT
                                         -- Ini 31204/12594 --ECP -- 14/05/2014  Se cambia  MAX(fsinies) fecha_max por
                                         NVL (MAX (fsinies),
                                              pfanulac - 1
                                             ) fecha_max
                                    -- Fin 1204/12594 --ECP -- 14/05/2014
                                  FROM   sin_siniestro s
                                   WHERE s.sseguro = rseguros.sseguro
                                     AND (SELECT m.cestsin
                                            FROM sin_movsiniestro m
                                           WHERE m.nsinies = s.nsinies
                                             AND m.nmovsin =
                                                    (SELECT MAX (mm.nmovsin)
                                                       FROM sin_movsiniestro mm
                                                      WHERE mm.nsinies =
                                                                     s.nsinies)) IN
                                                                       (0, 1))
                              LOOP
                                 IF rfechamax.fecha_max >= pfanulac
                                 THEN
                                    v_error := 107571;
                                 END IF;
                              END LOOP;
                           END IF;
                        --BUG 27539 - FIN - DCT - 15/10/2013  - LCOL_T010-LCOL - Revision incidencias qtracker (VII)
                        END IF;
                     END IF;
                  END IF;
               END IF;

               -- Bug 20995 - RSC - 09/02/2012 - LCOL - UAT - TEC - Incidencias de Contratacion
               IF NVL (f_parproductos_v (rseguros.sproduc,
                                         'RESCATE_UNIDAD_PEND'
                                        ),
                       1
                      ) = 0
               THEN
                  IF NVL (f_parproductos_v (rseguros.sproduc,
                                            'ES_PRODUCTO_INDEXADO'
                                           ),
                          0
                         ) = 1
                  THEN
                     SELECT COUNT (*)
                       INTO v_contador
                       FROM ctaseguro
                      WHERE sseguro = rseguros.sseguro
                        AND cesta IS NOT NULL
                        AND nunidad IS NULL;

                     IF v_contador > 0
                     THEN
                        RETURN 180704;     -- el producto no permite rescates
                     END IF;
                  END IF;
               END IF;

               --No se puede anular la p¿liza si todav¿a tiene UPs, a no ser que tenga un siniestro de Baja de Participe pagado
               IF NVL (f_parproductos_v (rseguros.sproduc,
                                         'ANUL_POL_BAJA_PARTIC'
                                        ),
                       0
                      ) = 1
               THEN
                  --Miramos si la p¿liza tiene provisi¿n
                  IF NVL
                        (pac_provmat_formul.f_calcul_formulas_provi
                                                            (rseguros.sseguro,
                                                             f_sysdate,
                                                             'IPROVAC'
                                                            ),
                         0
                        ) > 0
                  THEN
                     --Buscamos si tiene un siniestro de Baja Parti
                     SELECT NVL (MAX (nsinies), 0)
                       INTO nsiniestro
                       FROM sin_siniestro
                      WHERE cmotsin = 10 AND sseguro = rseguros.sseguro;

                     IF v_contador > 0
                     THEN
                        SELECT COUNT (*)
                          INTO v_contador
                          FROM sin_tramita_movpago tm, sin_tramita_pago tp
                         WHERE tm.sidepag = tp.sidepag
                           AND tp.nsinies = nsiniestro
                           AND tm.cestpag = 2;

                        IF v_contador > 0
                        THEN
                           SELECT COUNT (*)
                             INTO v_contador
                             FROM ctaseguro
                            WHERE sseguro = rseguros.sseguro
                              AND nsinies = nsiniestro
                              AND NVL (nunidad, 0) <> 0;

                           IF v_contador > 0
                           THEN
                              RETURN 9906658;
                           -- El pago tiene que tener asignadas las UPs.
                           END IF;
                        ELSE
                           RETURN 9906657;
                        --El siniestro de baja Participe tiene que estar pagado
                        END IF;
                     ELSE
                        RETURN 9906656;
--No se puede anular una p¿liza con provisi¿n y sin un siniestro de Baja Participe
                     END IF;
                  END IF;
               END IF;
            -- Fin Bug 20995
            END IF;
         END IF;

         EXIT;                 -- Nom¿s hi hauria d'haver un registre al bucle
      END LOOP;

      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      IF NVL (f_parproductos_v (v_sproduc, 'HAYCTACLIENTE'), 0) = 2
      THEN
         visaldo_prod := pac_ctacliente.f_transferible_spl (psseguro);

         IF NVL (visaldo_prod, 0) > 0
         THEN
            RETURN 9908586;
         END IF;
      END IF;

      v_traza := 10;
      -- BUG15936:DRA:13/09/2010:Inici
--      p_tab_error(f_sysdate, f_user, 'pac_anulacion.f_valida_permite_anular_poliza', psseguro,
--                  '2 - v_dias_anul: ' || v_dias_anul || ' pvalparcial: ' || pvalparcial
--                  || '  pfanulac: ' || TO_CHAR(pfanulac, 'DD-MM-YYYY'),
--                  'v_error: ' || v_error || ' fecha: ' || f_sysdate);
      -- BUG15936:DRA:13/09/2010:Fi
      RETURN v_error;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_valida_permite_anular_poliza',
                      v_traza,
                      'psseguro:' || psseguro || ' pfanulac:' || pfanulac,
                      SQLERRM
                     );
         -- Per versi¿ 10 es pot posar aix¿
         -- p_tab_error (f_sysdate,    F_USER,   'pac_anulacion.f_valida_permite_anular_poliza',   1, DBMS_UTILITY.FORMAT_ERROR_STACK || CHR(10)|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
         RETURN 140999;                                 --{Error no controlat}
   END;

   FUNCTION f_anulacion_reemplazo (
      psseguro   IN   NUMBER,
      psreempl   IN   NUMBER,
      pcagente   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      /******************************************************************************************
                                Esta funci¿n implementa el circuito de anulaci¿n por reemplazo
      ********************************************************************************************/
      num_err      NUMBER                      := 0;
      v_npoliza    seguros.npoliza%TYPE;
      v_csituac    seguros.csituac%TYPE;
      v_sperson1   per_personas.sperson%TYPE;
      v_sperson2   per_personas.sperson%TYPE;
      vnmovimi     movseguro.nmovimi%TYPE;
      vnsuplem     movseguro.nsuplem%TYPE;
   BEGIN
      BEGIN
         SELECT npoliza, csituac
           INTO v_npoliza, v_csituac
           FROM seguros
          WHERE sseguro = psreempl;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 111122;             --{Este n¿mero de solicitud no existe}
      END;

      IF v_csituac = 4
      THEN
         SELECT sperson
           INTO v_sperson1
           FROM tomadores
          WHERE sseguro = psseguro AND nordtom = 1;

         SELECT sperson
           INTO v_sperson2
           FROM tomadores
          WHERE sseguro = psreempl AND nordtom = 1;

         IF v_sperson1 <> v_sperson2
         THEN
            RETURN 152760;
         -- El titular de la solicitud no coincide con el titular de la p¿liza a anular
         END IF;

         SELECT NVL (MAX (nsuplem), 0) + 1
           INTO vnsuplem
           FROM movseguro
          WHERE sseguro = psseguro;

         -- Se graba un movimiento de seguro para saber qu¿ oficina pide la solicitud de anulaci¿n
         num_err :=
            f_movseguro (psseguro,
                         NULL,
                         323,
                         1,
                         f_sysdate,
                         NULL,
                         vnsuplem,
                         0,
                         f_sysdate,
                         vnmovimi
                        );

         -- Se actualiza el campo COFICIN con la oficina que pide la solicitud
         UPDATE movseguro
            SET coficin = pcagente
          WHERE sseguro = psseguro AND nmovimi = vnmovimi;

         -- grabar en reemplazos
         INSERT INTO reemplazos
                     (sseguro, sreempl, fmovdia, cusuario, cagente
                     )
              VALUES (psseguro, psreempl, f_sysdate, f_user, pcagente
                     );

         /*
                           num_err :=
                        pac_propio.f_anulacion_reemplazo (psseguro, psreempl, pcagente);
                  IF num_err = 0 THEN
                     COMMIT;
                  END IF;
         */
         RETURN (num_err);
      ELSE
         RETURN 101158;            -- Esta p¿liza no es una propuesta de alta
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_anulacion_reemplazo',
                      1,
                      SQLERRM,
                      SQLERRM
                     );
         RETURN 140999;                                 --{Error no controlat}
   END f_anulacion_reemplazo;

   /*************************************************************************
                             FUNCTION f_esta_prog_anulproxcar
      Verifica si est¿ programada la anulaci¿n.
      param in psseguro   : c¿digo del seguro
      return             : NUMBER -->  1.- si esta programada la anulaci¿n.
                                       0 .- No est¿ programada la anulaci¿n.
   *************************************************************************/
   FUNCTION f_esta_prog_anulproxcar (psseguro IN NUMBER)
      RETURN NUMBER
   IS
      /*
         { 1.- si esta programada la anulaci¿n.
        0 .- No est¿ programada la anulaci¿n.
       }
      */
      ccmotmov   NUMBER;
   BEGIN
      /*
             {miramos si el m¿ximo mov. entre anulaci¿n y desanulaci¿n es de anulaci¿n}
      */
      BEGIN
         SELECT cmotmov
           INTO ccmotmov
           FROM movseguro
          WHERE sseguro = psseguro
            AND nmovimi =
                   (SELECT MAX (nmovimi)
                      FROM movseguro
                     WHERE sseguro = psseguro
                       AND cmotmov IN (236, 228, 322, 512, 324, 306));
      -- BUG18706:DRA:01/06/2011
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 0;
      --{Si no tiene movimiento de anulaci¿n o desanulaci¿n, no permitimos seguir adelante}
      END;

      IF ccmotmov = 236
      THEN
         RETURN 1;                           --{Esta programada la anulaci¿n}
      ELSE
         RETURN 0;                        --{No esta programada la anulaci¿n}
      END IF;
   END f_esta_prog_anulproxcar;

   --BUG 9914 - JTS - 19/05/2009
   /*************************************************************************
         FUNCTION f_marcado
      param in pnrecibo  : Num. recibo
      param in pfanulac  : Fecha de anulacion
      return             : NUMBER -->  1.- Se tiene que anular
                                       0.- No se tiene que anular
   *************************************************************************/
   FUNCTION f_marcado (pnrecibo IN NUMBER, pfanulac IN DATE)
      RETURN NUMBER
   IS
      vret   NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO vret
        FROM recibos
       WHERE nrecibo = pnrecibo AND fefecto >= pfanulac;

      IF vret IS NULL OR vret = 0
      THEN
         vret := 0;
      ELSIF vret > 0
      THEN
         vret := 1;
      END IF;

      RETURN vret;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END f_marcado;

   /*************************************************************************
         FUNCTION f_recibos
      param in psseguro  : Num. seguro
      param in pfanulac  : Fecha de anulacion
      param out perror   : Numero de error
      param in pcestrec  : 0.- Pendiente, 1.- Cobrado
      return             : sys_refcursor
   *************************************************************************/
   -- Bug 23807 - APD - 08/10/2012
   -- se a¿ade el parametro pbajacol = 0.Se est¿ realizando la baja de un certificado normal
   -- 1.Se est¿ realizando la baja del certificado 0
   FUNCTION f_recibos (
      psseguro     IN       NUMBER,
      pfanulac     IN       DATE,
      pctipocon    IN       NUMBER,
      pcidioma     IN       NUMBER,
      perror       OUT      NUMBER,
      pextahorro   IN       NUMBER DEFAULT 1,
      pbajacol     IN       NUMBER DEFAULT 0
   )
      RETURN sys_refcursor
   IS
      vcur          sys_refcursor;
      vquery        VARCHAR2 (10000);
      -- Bug 19312 - RSC - 09/12/2011 - LCOL_T004 - Parametrizaci¿n Anulaciones
      v_sproduc     seguros.sproduc%TYPE;
      v_cempres     seguros.cempres%TYPE;
      vnumerr       NUMBER;
      v_crealiza    NUMBER;
      v_extahorro   NUMBER;
   -- Fin bug 19312
   BEGIN
      SELECT sproduc, cempres
        INTO v_sproduc, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      -- Bug 23817 - APD - 27/09/2012 - si estamos en un certificado 0
      -- se llama a la funcion f_recibos_colectivo
      -- se est¿ realizano la baja del certifiado 0
      IF pbajacol = 1
      THEN
         vquery :=
            pac_anulacion.f_recibos_colectivo (psseguro,
                                               pfanulac,
                                               pctipocon,
                                               pcidioma,
                                               perror
                                              );
      ELSE              -- se est¿ realizando la baja de un certificado normal
         -- fin Bug 23817 - APD - 27/09/2012
         IF pctipocon = 0
         THEN
            IF pextahorro = 1
            THEN              -- Como hasta ahora. Selecciona tambien ahorro.
               vquery :=
                     'SELECT r.nrecibo, r.fefecto, r.fvencim,'
                  || ' m.fmovini, pac_anulacion.f_marcado(r.nrecibo, to_date('''
                  || TO_CHAR (pfanulac, 'ddmmyyyy')
                  || ''',''ddmmyyyy'') ) marcado,'
                  || ' f_cagente(r.sseguro,1) || '' - '' || ff_desagente_per(f_cagente(r.sseguro,1)) tagente,'
                  || ' (select tatribu from detvalores where cvalor = 8 and catribu = ctiprec and cidioma = '
                  || pcidioma
                  || ') ttiprec, v.itotalr'
                  || ' FROM movrecibo m, recibos r, vdetrecibos v'
                  || ' WHERE m.nrecibo = r.nrecibo'
                  || ' AND m.fmovfin IS NULL'
                  || ' AND m.cestrec = 0'
                  || ' AND r.sseguro = '
                  || psseguro
                  -- BUG 29965 - FAL - 13/2/2014
                  || ' AND ((NVL(pac_parametros.f_parempresa_n('
                  || v_cempres
--                  || ',''ANUL_REC_POST_ANULAC''),0) = 1 AND r.fefecto >= to_date('''
                  || ',''ANUL_REC_POST_ANULAC''),0) = 1 AND r.fvencim >= to_date('''
                  --JAMF 33921 23/01/2015
                  || TO_CHAR (pfanulac, 'ddmmyyyy')
                  || ''',''ddmmyyyy''))'
                  || ' OR (NVL(pac_parametros.f_parempresa_n('
                  || v_cempres
                  || ', ''ANUL_REC_POST_ANULAC''), 0) = 0)) ';

               IF pac_parametros.f_parproducto_n
                                             (psproduc      => v_sproduc,
                                              pcparam       => 'AFECTA_COMISESPPROD'
                                             ) = 1
               THEN                                                      --rdd
                  vquery := vquery || ' and r.ctiprec != 5 ';
               END IF;

               -- FI BUG 29965 - FAL - 13/2/2014
               vquery :=
                       vquery || ' AND r.nrecibo = v.nrecibo ORDER BY r.nrecibo'; -- IAXIS-4926 23/10/2019
            ELSE
               vquery :=
                     'SELECT r.nrecibo, r.fefecto, r.fvencim,'
                  || ' m.fmovini, pac_anulacion.f_marcado(r.nrecibo, to_date('''
                  || TO_CHAR (pfanulac, 'ddmmyyyy')
                  || ''',''ddmmyyyy'') ) marcado,'
                  || ' f_cagente(r.sseguro,1) || '' - '' || ff_desagente_per(f_cagente(r.sseguro,1)) tagente,'
                  || ' (select tatribu from detvalores where cvalor = 8 and catribu = ctiprec and cidioma = '
                  || pcidioma
                  || ') ttiprec, v.itotalr'
                  || ' FROM movrecibo m, recibos r, vdetrecibos v'
                  || ' WHERE m.nrecibo = r.nrecibo'
                  || ' AND m.fmovfin IS NULL'
                  || ' AND m.cestrec = 0'
                  || ' AND r.sseguro = '
                  || psseguro
                  || ' AND r.nrecibo = v.nrecibo AND PAC_ADM.f_es_recibo_ahorro(r.nrecibo) = 0'
                  -- BUG 29965 - FAL - 13/2/2014
                  || ' AND ((NVL(pac_parametros.f_parempresa_n('
                  || v_cempres
--                  || ',''ANUL_REC_POST_ANULAC''),0) = 1 AND r.fefecto >= to_date('''
                  || ',''ANUL_REC_POST_ANULAC''),0) = 1 AND r.fvencim >= to_date('''
                  --JAMF 33921 23/01/2015
                  || TO_CHAR (pfanulac, 'ddmmyyyy')
                  || ''',''ddmmyyyy''))'
                  || ' OR (NVL(pac_parametros.f_parempresa_n('
                  || v_cempres
                  || ', ''ANUL_REC_POST_ANULAC''), 0) = 0)) ';

               IF pac_parametros.f_parproducto_n
                                             (psproduc      => v_sproduc,
                                              pcparam       => 'AFECTA_COMISESPPROD'
                                             ) = 1
               THEN                                                      --rdd
                  vquery := vquery || ' and r.ctiprec != 5 ';
               END IF;

               -- FI BUG 29965 - FAL - 13/2/2014
               vquery := vquery || ' ORDER BY r.nrecibo'; -- IAXIS-4926 23/10/2019
            END IF;
         ELSIF pctipocon = 1
         THEN
            -- Bug 19312 - RSC - 09/12/2011 - LCOL_T004 - Parametrizaci¿n Anulaciones
            v_extahorro := pextahorro;
            vnumerr :=
               pac_cfg.f_get_user_accion_permitida (f_user,
                                                    'EXTORNA_AHORRO',
                                                    v_sproduc,
                                                    v_cempres,
                                                    v_crealiza
                                                   );

            -- Ini Bug 22687 - MDS - 02/07/2012
            IF NVL (v_crealiza, 1) = 0
            THEN
               IF pextahorro <> 1
               THEN
                  v_extahorro := 0;
               END IF;
            END IF;

            -- Fin bug 22687

            -- Fin Bug 19312

            -- Se modifica la select para que busque los recibos cobrados (cestrec = 1) y los remesados (cestrec = 3) (detvalores = 1)
            IF v_extahorro = 1
            THEN               -- Como hasta ahora. Selecciona tambien ahorro.
               vquery :=
                     'SELECT r.nrecibo, r.fefecto, r.fvencim, m.fmovini, 1 marcado,'
                  || ' f_cagente(ms.sseguro,1) || '' - '' || ff_desagente_per(f_cagente(ms.sseguro,1)) tagente,'
                  || ' (select tatribu from detvalores where cvalor = 8 and catribu = ctiprec and cidioma = '
                  || pcidioma
                  || ') ttiprec, v.itotalr'
                  || ' FROM movrecibo m, recibos r, movseguro ms, vdetrecibos v'
                  || ' WHERE m.nrecibo = r.nrecibo'
                  || ' AND m.fmovfin IS NULL'
                  || ' AND m.cestrec IN (1,3)'
                  || ' AND r.fvencim > to_date('''
                  || TO_CHAR (pfanulac, 'ddmmyyyy')
                  || ''',''ddmmyyyy'') AND r.sseguro = '
                  || psseguro
                  || ' AND r.sseguro = ms.sseguro'
                  || ' AND r.nmovimi = ms.nmovimi'
                  || ' AND ms.cmovseg <> 3 AND r.nrecibo = v.nrecibo'
                  || ' ORDER BY r.nrecibo';
            ELSE
               vquery :=
                     'SELECT r.nrecibo, r.fefecto, r.fvencim, m.fmovini, 1 marcado,'
                  || ' f_cagente(ms.sseguro,1) || '' - '' || ff_desagente_per(f_cagente(ms.sseguro,1)) tagente,'
                  || ' (select tatribu from detvalores where cvalor = 8 and catribu = ctiprec and cidioma = '
                  || pcidioma
                  || ') ttiprec, v.itotalr'
                  || ' FROM movrecibo m, recibos r, movseguro ms, vdetrecibos v, seguros s'
                  || ' WHERE m.nrecibo = r.nrecibo'
                  || ' AND m.fmovfin IS NULL'
                  || ' AND m.cestrec IN (1,3)'
                  || ' AND r.fvencim > to_date('''
                  || TO_CHAR (pfanulac, 'ddmmyyyy')
                  || ''',''ddmmyyyy'') AND r.sseguro = '
                  || psseguro
                  || ' AND r.sseguro = s.sseguro AND r.sseguro = ms.sseguro'
                  || ' AND r.nmovimi = ms.nmovimi'
                  || ' AND ms.cmovseg <> 3 AND r.nrecibo = v.nrecibo AND PAC_ADM.f_es_recibo_ahorro(r.nrecibo) = 0'
                  || ' AND (NVL(f_parproductos_v(s.sproduc, ''REC_SUP_PM''), 1) <> 4 AND EXISTS (SELECT 1 FROM detrecibos d WHERE d.nrecibo = r.nrecibo '
                  || '              AND NOT((NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, d.cgarant, ''REC_SUP_PM_GAR''), 0) = 1 '
                  || '                           AND TO_DATE('''
                  || TO_CHAR (pfanulac, 'ddmmyyyy')
                  || ''',''dd/mm/yyyy'') <> s.fefecto)'
                  || '                         OR '
                  || '                      (NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi, d.cgarant, ''REC_SUP_PM_GAR''), 0) = 2 '
                  || '                         AND '
                  || '                       NVL(PAC_PREGUNTAS.f_get_pregungaranseg_v(r.sseguro, d.cgarant, d.nriesgo, 4045, NULL), 0) = 1 '
                  || '                  ))) OR NVL(f_parproductos_v(s.sproduc, ''REC_SUP_PM''), 1) = 4) '
                  || ' ORDER BY r.nrecibo';
            END IF;
         ELSIF pctipocon = 10
         THEN
            -- Es la misma condici¿n que la pctipocon = 0 pero a¿adiendo el filtro r.fefecto > pfanulac
            -- Bug 25450 -- ECP -- 31/01/2013 se cambia el filtro r.fefecto >= pfanulac
            IF pextahorro = 1
            THEN              -- Como hasta ahora. Selecciona tambien ahorro.
               vquery :=
                     'SELECT r.nrecibo, r.fefecto, r.fvencim,'
                  || ' m.fmovini, pac_anulacion.f_marcado(r.nrecibo, to_date('''
                  || TO_CHAR (pfanulac, 'ddmmyyyy')
                  || ''',''ddmmyyyy'') ) marcado,'
                  || ' f_cagente(r.sseguro,1) || '' - '' || ff_desagente_per(f_cagente(r.sseguro,1)) tagente,'
                  || ' (select tatribu from detvalores where cvalor = 8 and catribu = ctiprec and cidioma = '
                  || pcidioma
                  || ') ttiprec, v.itotalr'
                  || ' FROM movrecibo m, recibos r, vdetrecibos v'
                  || ' WHERE m.nrecibo = r.nrecibo'
                  || ' AND m.fmovfin IS NULL'
                  || ' AND m.cestrec = 0'
                  || ' AND r.sseguro = '
                  || psseguro
                  || ' AND r.fefecto >=  to_date('''
                  || TO_CHAR (pfanulac, 'ddmmyyyy')
                  || ''',''ddmmyyyy'')'
                  || ' AND r.nrecibo = v.nrecibo ORDER BY r.nrecibo'; -- IAXIS-4926 23/10/2019
            ELSE
               vquery :=
                     'SELECT r.nrecibo, r.fefecto, r.fvencim,'
                  || ' m.fmovini, pac_anulacion.f_marcado(r.nrecibo, to_date('''
                  || TO_CHAR (pfanulac, 'ddmmyyyy')
                  || ''',''ddmmyyyy'') ) marcado,'
                  || ' f_cagente(r.sseguro,1) || '' - '' || ff_desagente_per(f_cagente(r.sseguro,1)) tagente,'
                  || ' (select tatribu from detvalores where cvalor = 8 and catribu = ctiprec and cidioma = '
                  || pcidioma
                  || ') ttiprec, v.itotalr'
                  || ' FROM movrecibo m, recibos r, vdetrecibos v'
                  || ' WHERE m.nrecibo = r.nrecibo'
                  || ' AND m.fmovfin IS NULL'
                  || ' AND m.cestrec = 0'
                  || ' AND r.sseguro = '
                  || psseguro
                  || ' AND r.fefecto >=  to_date('''
                  || TO_CHAR (pfanulac, 'ddmmyyyy')
                  || ''',''ddmmyyyy'')'
                  || ' AND r.nrecibo = v.nrecibo AND PAC_ADM.f_es_recibo_ahorro(r.nrecibo) = 0'
                  || ' ORDER BY r.nrecibo'; -- IAXIS-4926 23/10/2019
            END IF;
         END IF;
      END IF;

      -- 64. 0027044: Tratamiento de los recibos con cobros parciales - 0145617 - Inicio
      -- 63. 0027044: Tratamiento de los recibos con cobros parciales - Inicio
      IF vquery IS NOT NULL
      THEN
         IF pctipocon IN (0, 10)
         THEN
            -- Los recibo con cobros parciales de excluyen de los pendientes
            vquery :=
               REPLACE
                  (vquery,
                   'm.cestrec = 0',
                      '(m.cestrec = 0 AND (pac_adm_cobparcial.f_get_importe_cobro_parcial(r.nrecibo, NULL, NULL) = 0 '
                   || 'AND (NVL(pac_parametros.f_parproducto_n((SELECT sproduc FROM seguros s WHERE s.sseguro = r.sseguro),''ANUL_EXTORN_REC_PEND''),0) = 0 )'
                   || 'OR (NVL(pac_parametros.f_parempresa_t((SELECT cempres FROM seguros s WHERE s.sseguro = r.sseguro), ''NO_EXTORN_COB_PARC''), 0) =1))'
                   || 'AND pac_anulacion.F_PADRE_COBRADO(r.nrecibo) = 0)'
                  --JAMF  33921  17/12/2014
                  );
         ELSIF pctipocon = 1
         THEN
            -- Los recibo con cobros parciales se incluyen en los cobrados (porque se tratar¿n igual)
            vquery :=
               REPLACE
                  (vquery,
                   'm.cestrec IN (1,3)',
                      '(m.cestrec IN (1,3)'
                   || ' OR ((m.cestrec = 0 AND (pac_adm_cobparcial.f_get_importe_cobro_parcial(r.nrecibo, NULL, NULL) > 0 '
                   || ' AND NVL(pac_parametros.f_parempresa_t((SELECT cempres FROM seguros s WHERE s.sseguro = r.sseguro), ''NO_EXTORN_COB_PARC''), 0) =0) '
                   --JAMF  33921  17/12/2014
                   || ' OR '
                   || ' NVL(pac_parametros.f_parproducto_n((SELECT sproduc FROM seguros s WHERE s.sseguro = r.sseguro),''ANUL_EXTORN_REC_PEND''),0) in (1,2)))'
                   || ' OR (m.cestrec = 0 AND pac_anulacion.F_PADRE_COBRADO(r.nrecibo) = 1))'
                                                     -- Bug 37070 MMS 20150915
                  --|| ' NVL(pac_parametros.f_parproducto_n((SELECT sproduc FROM seguros s WHERE s.sseguro = r.sseguro),''ANUL_EXTORN_REC_PEND''),0)  = 1)))'   -- Bug 37070 MMS 20150915
                  );
         END IF;
      END IF;
      --
      -- Inicio IAXIS-4926 23/10/2019
      --
      -- Se excluyen del proceso los recibos que hayan sido compensados ó que se hayan generado como resultado de una compensación 
      -- para evitar reprocesarlos o anularlos. 
      -- Por ejemplo: Considere una póliza con un suplemento cuyo recibo tiene un abono, pero dicho movimiento fue anulado y su recibo de extorno que compensa
      -- el recibo de suplemento fue generado en dicho rechazo de movimiento. Tanto el recibo de suplemento como el extorno generado siguen estando en estado
      -- "Pendiente" por lo que, si se genera una anulación de póliza:
      -- 1. Para El recibo de suplemento, al tener un abono, se generaría un nuevo recibo de extorno. Esto sería incorrecto pues dicho extorno ya se realizó 
      --    durante el proceso de anulación de movimiento.
      -- 2. Para el recibo de extorno, al estar pendiente, se anularía. Esto sería incorrecto pues dicho recibo de extorno se generó por compensación del recibo
      --    de suplemento con abono correspondiente al suplemento. 
      -- 
      IF vquery IS NOT NULL THEN
        vquery := REPLACE(vquery,'ORDER BY r.nrecibo', ' AND NOT EXISTS( SELECT 1 FROM recibosclon rc WHERE rc.nreciboant = r.nrecibo'|| 
                                                       ' OR rc.nreciboact = r.nrecibo AND rc.corigen = 2 ) ORDER BY r.nrecibo');
      END IF;  
      --
      -- Fin IAXIS-4926 23/10/2019
      -- 
      vnumerr := pac_log.f_log_consultas (vquery, 'pac_anulacion.f_recibos', 1);

      -- 63. 0027044: Tratamiento de los recibos con cobros parciales - Final
      -- 64. 0027044: Tratamiento de los recibos con cobros parciales - 0145617 - Final
      OPEN vcur FOR vquery;

      perror := 0;
      RETURN vcur;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF vcur%ISOPEN
         THEN
            CLOSE vcur;
         END IF;

         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_ANULACION.f_recibos',
                      1,
                         'psseguro: '
                      || psseguro
                      || ' - pfanulac: '
                      || pfanulac
                      || ' - pctipocon: '
                      || pctipocon,
                      SQLCODE || ' - ' || SQLERRM
                     );
         perror := SQLCODE;
         RETURN NULL;
   END f_recibos;

   FUNCTION f_recibos_anulados_mov (precibos IN VARCHAR2)                --rdd
      RETURN NUMBER
   IS                                                                    --rdd
      v_nmovimi    movseguro.nmovimi%TYPE;
      v_posicion   NUMBER                   := 1;
      v_nrecibo    recibos.nrecibo%TYPE;
      v_sseguro    seguros.sseguro%TYPE;
   BEGIN
--      p_tab_error(f_sysdate, f_user, 'PAC_ANULACION.f_recibos_anulados_mov', 1,
--                  'entrando a (0) precibos: ' || precibos, SQLCODE || ' - ' || SQLERRM);
      WHILE 1 = 1
      LOOP
         BEGIN
            v_nrecibo := pac_util.splitt (precibos, v_posicion, ',');
            v_posicion := v_posicion + 1;

            IF v_nrecibo IS NOT NULL
            THEN
               SELECT sseguro
                 INTO v_sseguro
                 FROM recibos
                WHERE nrecibo = v_nrecibo;

               SELECT MAX (nmovimi) + 1
                 INTO v_nmovimi
                 FROM movseguro
                WHERE sseguro = v_sseguro;

               INSERT INTO recanumov
                    VALUES (v_sseguro, v_nmovimi, v_nrecibo, f_sysdate);
            ELSE
               EXIT;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'PAC_ANULACION.f_recibos_anulados_mov',
                            1,
                               '(1) v_sseguro: '
                            || v_sseguro
                            || ' -v_nmovimi: '
                            || v_nmovimi
                            || ' v_nrecibo '
                            || v_nrecibo,
                            ' - sqlcode ' || SQLCODE || ' - ' || SQLERRM
                           );
               EXIT;
         END;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_ANULACION.f_recibos_anulados_mov',
                      1,
                         '(2) v_sseguro: '
                      || v_sseguro
                      || ' -v_nmovimi: '
                      || v_nmovimi
                      || ' v_nrecibo '
                      || v_nrecibo,
                      ' - sqlcode ' || SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 9907324;
   END;

   /*************************************************************************
               FUNCTION f_recibos_anulables
      param in precibos  : Recibos
      param out perror   : Numero de error
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_recibos_anulables (precibos IN VARCHAR2, perror OUT NUMBER)
      RETURN sys_refcursor
   IS
      vcur     sys_refcursor;
      vquery   VARCHAR2 (5000);
   BEGIN
      vquery :=
            'SELECT r.nrecibo, r.fefecto, r.fvencim, m.fmovini'
         || ' FROM movrecibo m, recibos r'
         || ' where r.nrecibo in ('
         || precibos
         || ')'
         || ' and m.nrecibo = r.nrecibo'
         || ' and m.fmovfin is null';

      OPEN vcur FOR vquery;

      --insert into sql_his values(vquery); --rdd
      perror := 0;
      RETURN vcur;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF vcur%ISOPEN
         THEN
            CLOSE vcur;
         END IF;

         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_ANULACION.f_recibos_anulables',
                      1,
                      'precibos: ' || precibos,
                      SQLCODE || ' - ' || SQLERRM
                     );
         perror := SQLCODE;
         RETURN NULL;
   END f_recibos_anulables;

   --
   --  NOTA : Par¿metres rpend i rcob  NO S'UTILITZEN : Enviar-los sempre a NULL.
   --
   --   MSR 2007/06/01   Modificar funci¿ F_ANULACION_POLIZA. Ref 1880.
   FUNCTION f_anulacion_poliza (
      psseguro       IN   NUMBER,
      pcmotmov       IN   NUMBER,
      pcmoneda       IN   NUMBER,
      pfanulac       IN   DATE,
      pcextorn       IN   NUMBER,
      pcanular_rec   IN   NUMBER,
      pcagente       IN   NUMBER,
      rpend          IN   VARCHAR2,
      rcob           IN   VARCHAR2,
      psproduc       IN   NUMBER DEFAULT NULL,
      pcnotibaja     IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      rec_pend   recibos_pend;
      rec_cobr   recibos_cob;
      num_err    NUMBER;
      vcur       sys_refcursor;
      vdummy     NUMBER;
      vdummy2    VARCHAR2 (150);
      vdummy4    NUMBER;
      vdummy3    VARCHAR2 (150);
      vcont      NUMBER;
   /*************************************************************************
         Se conserva la funci¿n para mantener la compatibilidad con
      la capa de negocio. BUG 9914
   *************************************************************************/
   BEGIN
      IF NVL (pcanular_rec, 0) = 1
      THEN
         vcur := f_recibos (psseguro, pfanulac, 0, 1, num_err);
         vcont := 1;

         IF num_err <> 0
         THEN
            RETURN num_err;
         END IF;

         FETCH vcur
          INTO rec_pend (vcont).nrecibo, rec_pend (vcont).fefecto,
               rec_pend (vcont).fvencim, rec_pend (vcont).fmovini, vdummy,
               vdummy2, vdummy3, vdummy4;

         WHILE vcur%FOUND
         LOOP
            vcont := vcont + 1;

            FETCH vcur
             INTO rec_pend (vcont).nrecibo, rec_pend (vcont).fefecto,
                  rec_pend (vcont).fvencim, rec_pend (vcont).fmovini, vdummy,
                  vdummy2, vdummy3, vdummy4;
         END LOOP;
      END IF;

      IF pcextorn = 1
      THEN
         vcur := f_recibos (psseguro, pfanulac, 1, 1, num_err);

         IF num_err <> 0
         THEN
            RETURN num_err;
         END IF;

         FETCH vcur
          INTO rec_cobr (vcont).nrecibo, rec_cobr (vcont).fefecto,
               rec_cobr (vcont).fvencim, rec_cobr (vcont).fmovini, vdummy,
               vdummy2, vdummy3, vdummy4;

         WHILE vcur%FOUND
         LOOP
            vcont := vcont + 1;

            FETCH vcur
             INTO rec_cobr (vcont).nrecibo, rec_cobr (vcont).fefecto,
                  rec_cobr (vcont).fvencim, rec_cobr (vcont).fmovini, vdummy,
                  vdummy2, vdummy3, vdummy4;
         END LOOP;
      END IF;

      num_err :=
         f_anula_poliza (psseguro,
                         pcmotmov,
                         pcmoneda,
                         pfanulac,
                         pcextorn,
                         pcanular_rec,
                         pcagente,
                         rec_pend,
                         rec_cobr,
                         psproduc,
                         pcnotibaja
                        );
      RETURN num_err;
   END f_anulacion_poliza;

   --Fi BUG 9914 - JTS - 19/05/2009

   /*************************************************************************
         FUNCTION f_anula_vto_cartera
        Indica si una garant¿a determinada vence o ha vencido a una fecha
        determinada.
      param in psseguro  : Identificador de seguro.
      param in pfecha    : Fecha de corte para el vencimiento
      return             : NUMBER (0 --> OK)
   *************************************************************************/
   -- Bug 7926 - 27/05/2009 - RSC - Fecha de vencimiento a nivel de garant¿a
   FUNCTION f_anula_vto_cartera (
      psseguro   IN   NUMBER,
      pcgarant   IN   NUMBER,
      pfecha     IN   DATE
   )
      RETURN NUMBER
   IS
      v_conta   seguros.sseguro%TYPE;
   BEGIN
      SELECT   COUNT (*)
          INTO v_conta
          FROM garanseg g, seguros s
         WHERE g.sseguro = psseguro
           AND g.cgarant = NVL (pcgarant, g.cgarant)
           AND f_parproductos_v (s.sproduc, 'CPREGUN_VTOGARAN') IS NOT NULL
           AND NVL (pac_seguros.f_vto_garantia (g.sseguro,
                                                g.nriesgo,
                                                g.cgarant,
                                                g.nmovimi
                                               ),
                    pfecha + 1
                   ) <= pfecha
           AND g.nmovimi =
                        (SELECT MAX (g2.nmovimi)
                           FROM garanseg g2
                          WHERE g2.sseguro = g.sseguro AND g2.ffinefe IS NULL)
           AND g.sseguro = s.sseguro
           AND g.ffinefe IS NULL
      ORDER BY s.npoliza, s.ncertif;

      IF v_conta > 0
      THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_anula_vto_cartera',
                      1,
                      'Error no controlado',
                      SQLERRM
                     );
         RETURN 1000001;
   END f_anula_vto_cartera;

   -- Fin Bug 7926

   /*************************************************************************
         FUNCTION f_anula_vto_garantias
        Realiza el vencimiento de aquellas garant¿as que hayan vencido.
      param in psseguro  : Identificador de seguro.
      param in pfecha    : Fecha de corte para el vencimiento
      return             : NUMBER (0 --> OK)
   *************************************************************************/
   -- Bug 7926 - 27/05/2009 - RSC - Fecha de vencimiento a nivel de garant¿a
   FUNCTION f_anula_vto_garantias (
      psseguro   IN   NUMBER,
      pfecha     IN   DATE,
      psproces   IN   NUMBER
   )
      RETURN NUMBER
   IS
      v_num_err     NUMBER;
      v_num_err2    NUMBER;
      v_nmovimi     NUMBER;
      v_nmovimi_r   NUMBER;
      v_sproces     NUMBER;
      v_texto       VARCHAR2 (120);
      v_num_lin     NUMBER;
      v_nerror      NUMBER         := 0;
      error_baja    EXCEPTION;
      v_contmovs    NUMBER;
      v_maxfmovs    DATE;
      v_fecha_sup   DATE;
      empresa       NUMBER;

      CURSOR garantias
      IS
         SELECT   g.sseguro, g.nriesgo, g.cgarant, g.nmovimi, s.npoliza,
                  s.ncertif, s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                  s.cactivi
             FROM garanseg g, seguros s
            WHERE g.sseguro = psseguro
              AND f_parproductos_v (s.sproduc, 'CPREGUN_VTOGARAN') IS NOT NULL
              AND NVL (pac_seguros.f_vto_garantia (g.sseguro,
                                                   g.nriesgo,
                                                   g.cgarant,
                                                   g.nmovimi
                                                  ),
                       pfecha + 1
                      ) <= pfecha
              AND g.nmovimi =
                        (SELECT MAX (g2.nmovimi)
                           FROM garanseg g2
                          WHERE g2.sseguro = g.sseguro AND g2.ffinefe IS NULL)
              AND g.sseguro = s.sseguro
              AND s.csituac = 0
              AND s.creteni = 0
              AND g.ffinefe IS NULL
         ORDER BY s.npoliza, s.ncertif;
   BEGIN
      BEGIN
         SELECT cempres
           INTO empresa
           FROM usuarios
          WHERE cusuari = f_user;
      END;

      -- Inicializamos proceso
      IF psproces IS NULL
      THEN
         v_num_err :=
            f_procesini (f_user,
                         empresa,
                         'VTO_GARANT:' || TO_CHAR (f_sysdate, 'yyyymmdd'),
                         f_axis_literales (9001725, f_idiomauser),
                         v_sproces
                        );
      ELSE
         v_sproces := psproces;
      END IF;

      FOR regs IN garantias
      LOOP
         -- El vencimiento de garant¿as se pasar¿ diariamente y tambi¿n en el proceso de cartera.
         -- En el proceso diario puede ser que un contrato tenga movimiento futuro por un suplemento.
         -- En este caso la fecha efecto del vencimiento debe ser a fecha m¿xima de movseguro.
         SELECT COUNT (*)
           INTO v_contmovs
           FROM movseguro
          WHERE sseguro = regs.sseguro AND fefecto > pfecha;

         IF v_contmovs > 0
         THEN
            SELECT MAX (fefecto)
              INTO v_maxfmovs
              FROM movseguro
             WHERE sseguro = regs.sseguro AND fefecto > pfecha;

            v_fecha_sup := v_maxfmovs;
         ELSE
            v_fecha_sup := pfecha;
         END IF;

         -- Bug 16095 - APD - 04/11/2010 - Si estamos tratando la garantia TEMPORARY,
         -- ¿sta no debe vencer sino 'renovar' (siempre y cuando la poliza no este vencida)
         IF regs.cgarant = 2118
         THEN                                            -- garantia TEMPORARY
            -- Se debe realizar el suplemento de renovacion de garantia
            v_num_err :=
               pac_sup_general.f_supl_vto_garantia (regs.sseguro,
                                                    regs.nriesgo,
                                                    v_fecha_sup,
                                                    331,
                                                    regs.cgarant,
                                                    v_nmovimi,
                                                    v_sproces
                                                   );
         ELSE
            -- para el resto de garantias el tratamiento ser¿ como hasta ahora, se realiza
            -- el suplemento de vencimiento de garantia
            v_num_err :=
               pac_sup_general.f_supl_vto_garantia (regs.sseguro,
                                                    regs.nriesgo,
                                                    v_fecha_sup,
                                                    517,
                                                    regs.cgarant,
                                                    v_nmovimi,
                                                    v_sproces
                                                   );
         END IF;

         -- Fin Bug 16095 - APD - 04/11/2010
         IF v_num_err <> 0
         THEN
            v_nerror := v_nerror + 1;
            ROLLBACK;
            v_texto := f_axis_literales (v_num_err, f_idiomauser);
            v_texto := v_texto || '.' || regs.npoliza || '-' || regs.ncertif;
            v_num_lin := NULL;
            v_num_err2 :=
                    f_proceslin (v_sproces, v_texto, regs.sseguro, v_num_lin);

            IF v_num_err2 = 0
            THEN
               RAISE error_baja;
            END IF;
         ELSE
            -- Si la garant¿a es de ahorro debe generar un rescate. Lo identificaremos
            -- con un par¿metro de garant¿a 'RESCATE_VTOGARAN'. De momento solo dejaremos
            -- la p¿liza retenida y grabaremos un mensaje de aviso en procesoslin
            IF NVL (f_pargaranpro_v (regs.cramo,
                                     regs.cmodali,
                                     regs.ctipseg,
                                     regs.ccolect,
                                     regs.cactivi,
                                     regs.cgarant,
                                     'RESCATE_VTOGARAN'
                                    ),
                    0
                   ) = 1
            THEN
               -- Retenci¿n de p¿liza
               v_num_err :=
                  f_movseguro (regs.sseguro,
                               NULL,
                               112,
                               10,
                               v_fecha_sup,
                               NULL,
                               NULL,
                               0,
                               NULL,
                               v_nmovimi_r,
                               f_sysdate
                              );

               IF v_num_err <> 0
               THEN
                  ROLLBACK;
                  v_texto := f_axis_literales (v_num_err, f_idiomauser);
                  v_texto :=
                        v_texto || '.' || regs.npoliza || '-' || regs.ncertif;
                  v_num_lin := NULL;
                  v_num_err :=
                     f_proceslin (v_sproces, v_texto, regs.sseguro,
                                  v_num_lin);

                  IF v_num_err <> 0
                  THEN
                     RAISE error_baja;
                  END IF;
               END IF;

               -- Mensaje de aviso en procesoslin
               v_texto := f_axis_literales (9001728, f_idiomauser);
               v_texto :=
                         v_texto || ' ' || regs.npoliza || '-' || regs.ncertif;
               v_num_lin := NULL;
               v_num_err :=
                     f_proceslin (v_sproces, v_texto, regs.sseguro, v_num_lin);

               IF v_num_err <> 0
               THEN
                  RAISE error_baja;
               END IF;
            END IF;
         END IF;
      END LOOP;

      -- Finalizamos proceso
      IF psproces IS NULL
      THEN
         v_num_err := f_procesfin (v_sproces, v_nerror);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN error_baja
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_anula_vto_garantias',
                      1,
                      'Error al dar de baja garant¿a.',
                      f_axis_literales (v_num_err, f_idiomauser)
                     );
         RETURN v_num_err;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_anula_vto_garantias',
                      1,
                      'Error no controlado',
                      SQLERRM
                     );
         RETURN 1000001;
   END f_anula_vto_garantias;

   -- Fin Bug 7926

   /*************************************************************************
         PROCEDURE de baja de garant¿as para ser llamado desde procesos nocturnos.
      param in psseguro  : Identificador de seguro.
      param in pfecha    : Fecha de corte para el vencimiento
      param in psproces  : Marcador de proceso.
   *************************************************************************/
   -- Bug 7926 - 27/05/2009 - RSC - Fecha de vencimiento a nivel de garant¿a
   PROCEDURE p_baja_automatica_gars (
      psseguro   IN   NUMBER,
      pfecha     IN   DATE,
      psproces   IN   NUMBER
   )
   IS
      v_error   NUMBER;
   BEGIN
      v_error :=
             pac_anulacion.f_anula_vto_garantias (psseguro, pfecha, psproces);

      IF v_error <> 0
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.p_baja_automatica_gars',
                      1,
                      'Error no controlado v_error = ' || v_error,
                      SQLERRM
                     );
      END IF;
   END p_baja_automatica_gars;

   --Ini Bug.: 16775 - ICV - 30/11/2010
   /***********************************************************************
         Funci¿n que realiza una solicitud de Anulaci¿n.
      param in psseguro  : c¿digo de seguro
      param in pcmotmov  : c¿digo de movimiento
      param in pnriesgo  : n¿mero de riesgo
      param in pfanulac  : fecha anulaci¿n
      param in ptobserv  : Observaciones.
      param in pTVALORD  : Descripci¿n del motivio.
      param in pcmotmov  : Causa anulacion.
      return             : 0.- proceso correcto
                           1.- error
   ***********************************************************************/
   FUNCTION f_set_solanulac (
      psseguro    IN   NUMBER,
      pctipanul   IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfanulac    IN   DATE,
      ptobserv    IN   VARCHAR2,
      ptvalord    IN   VARCHAR2,
      pcmotmov    IN   NUMBER
   )
      RETURN NUMBER
   IS
      num_err     NUMBER         := 0;
      v_nmovimi   NUMBER;
      vcmotmov    NUMBER;
      v_dummy     NUMBER         := 0;
      wnorden     NUMBER;
      wnpoliza    NUMBER;
      pcclagd     NUMBER;
      ptclagd     VARCHAR2 (100);
      vidapunte   NUMBER;
      v_cagente   NUMBER;
      v_ctipage   NUMBER;
      v_cempres   NUMBER;
      vcidioma    NUMBER;
   BEGIN
      SELECT MAX (nmovimi) + 1
        INTO v_nmovimi
        FROM movseguro m
       WHERE m.sseguro = psseguro;

      --BUG 18193 - 20/04/2011 - JRB - Se a¿ade motivo anulacion.
      IF pctipanul IS NULL
      THEN
         vcmotmov := pcmotmov;
      ELSE
         IF pctipanul = 1
         THEN
            vcmotmov := 306;
         ELSIF pctipanul = 5
         THEN                                        --JAMF   33921 23/01/2015
            vcmotmov := 444;
         ELSE
            vcmotmov := 324;
         END IF;
      END IF;

      --Comrpobamos que no exista ya una en estado pendiente
      SELECT COUNT ('1')
        INTO v_dummy
        FROM sup_solicitud ss
       WHERE ss.sseguro = psseguro
         AND ss.nmovimi = v_nmovimi
         AND ss.cmotmov = vcmotmov
         AND ss.nriesgo = NVL (pnriesgo, 0)
         AND ss.cgarant = 0
         AND ss.cpregun = 0
         AND ss.cestsup = 0;

      IF NVL (v_dummy, 0) <> 0
      THEN
         RETURN 9901731;
      END IF;

      --BUG 0016775 - 28/04/2011 - FAL - Se a¿ade secuencial para saber que baja imprimimr
      SELECT NVL (MAX (norden), 0) + 1
        INTO wnorden
        FROM sup_solicitud
       WHERE sseguro = psseguro;

      INSERT INTO sup_solicitud
                  (sseguro, nmovimi, cmotmov, nriesgo, cgarant, tvalora,
                   tvalord, cpregun, cestsup,
                   festsup, cususol, tobserv, norden
                  )
           VALUES (psseguro, v_nmovimi, vcmotmov, NVL (pnriesgo, 0), 0, NULL,
                   SUBSTR (ptvalord || ' - ' || ptobserv, 1, 1000), 0, 0,
                   pfanulac, f_user, ptobserv, wnorden
                  );

      --BUG 0016775 - 28/04/2011 - FAL - cambio situaci¿n Anulaci¿n ... si Nota informativa o Proyecto g¿rico
      UPDATE seguros
         SET csituac = DECODE (csituac, 12, 13, 14, 15),
             fanulac = pfanulac
       WHERE sseguro = psseguro AND csituac IN (12, 14);

      BEGIN
         --BUG 0016775 - 28/04/2011 - FAL - crear tarea en la agenda
         SELECT npoliza, cempres
           INTO wnpoliza, v_cempres
           FROM seguros
          WHERE sseguro = psseguro;

         SELECT s.cagente, r.ctipage, cidioma
           INTO v_cagente, v_ctipage, vcidioma
           FROM seguros s, redcomercial r
          WHERE s.sseguro = psseguro
            AND r.cagente = s.cagente
            AND r.fmovini =
                    (SELECT MAX (rr.fmovini)
                       FROM redcomercial rr
                      WHERE rr.cempres = v_cempres AND rr.cagente = s.cagente);

         pcclagd := 1;           -- C¿digo Clave Agenda 0:siniestro / 1:poliza
         ptclagd := wnpoliza;                            -- Valor Clave Agenda
         num_err :=
            pac_agenda.f_set_apunte
                             (NULL,
                              NULL,
                              pcclagd,
                              psseguro,
                              0,
                              0,
                              0,         --5,  -- Lo asgino al grupo 0 -- OBSV
                              pac_parametros.f_parempresa_t (v_cempres,
                                                             'ENV_TAREAS_DEF'
                                                            ),
                              f_axis_literales (9901672, vcidioma),
                              --9902334,  9216
                              f_axis_literales (9902335, vcidioma) || wnpoliza,
                              0,
                              0,
                              NULL,
                              NULL,
                              f_user,
                              NULL,
                              f_sysdate,
                              f_sysdate,
                              NULL,
                              vidapunte
                             );
         num_err :=
            pac_agenda.f_set_agenda
                             (vidapunte,
                              NULL,
                              NULL,
                              0,
                              --Lo enviamos al nodo superior de la red comercial
                              pac_parametros.f_parempresa_t (v_cempres,
                                                             'ENV_TAREAS_DEF'
                                                            ),
                              --enviamos la tarea al grupo gestion 921602
                              pcclagd,
                              psseguro,
                              NULL,
                              f_user,
                              v_ctipage,
                              v_cagente,
                              v_cempres,
                              vcidioma,
                              'SUPLEMENTO_BAJA'
                             );
      EXCEPTION
         WHEN OTHERS
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'pac_anulacion.f_set_agenda',
                         1,
                         'Error no controlado',
                         SQLERRM
                        );
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_set_solanulac',
                      1,
                      'Error no controlado',
                      SQLERRM
                     );
         RETURN 1000001;
   END f_set_solanulac;

   --Ini Bug.: 19276 - jbn - Reemplazos
   /***********************************************************************
        Funci¿n que anula la p¿liza a reemplazar a fecha de efecto de la
     nueva p¿liza, genera extorno de los recibos si corresponde y anula
     recibos pendientes con fecha de efecto posterior a la fecha
     de efecto del reemplazo
    1.   psseguro: Identificador del seguro (IN)
    2.   pcmotmov: Motivo de anulaci¿n de la p¿liza (IN)
    3.   pcmoneda: C¿digo de moneda (IN)
    4.   pfanulac: Fecha de anulaci¿n (IN)
    5.   pcextorn: Indica si se debe procesar el extorno (IN)
    6.   pcanular_rec: Indica si se deben anular recibos (IN)
    7.   pcagente: C¿digo del agente (IN)
    8.   rpend: Lista de recibos pendientes (de momento no se utiliza en el c¿digo) (IN)
    9.   rcob: Lista de recibos cobrados (de momento no se utiliza en el c¿digo) (IN)
    10.  psproduc: Identificador del producto (IN)
    11.  pcnotibaja (IN)
    12.  pcsituac (IN)
    13.  pccauanul: Causa de anulaci¿n de la p¿liza (IN)
      return             : 0.- proceso correcto
                           1.- error
   ***********************************************************************/
   FUNCTION f_anula_poliza_reemplazo (
      psseguro       IN   NUMBER,
      pcmotmov       IN   NUMBER,
      pcmoneda       IN   NUMBER,
      pfanulac       IN   DATE,
      pcextorn       IN   NUMBER,
      pcanular_rec   IN   NUMBER,
      pcagente       IN   NUMBER,
      rpend          IN   VARCHAR2,
      rcob           IN   VARCHAR2,
      psproduc       IN   NUMBER DEFAULT NULL,
      pcnotibaja     IN   NUMBER DEFAULT NULL,
      pcsituac       IN   NUMBER DEFAULT 2,
      pccauanul      IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      rec_pend   recibos_pend;
      rec_cobr   recibos_cob;
      num_err    NUMBER         := 0;
      vcur       sys_refcursor;
      vdummy     NUMBER;
      vdummy2    VARCHAR2 (150);
      vdummy4    NUMBER;
      vdummy3    VARCHAR2 (150);
      vcont      NUMBER;
   BEGIN
      IF NVL (pcanular_rec, 0) = 1
      THEN
         IF pcmotmov IN (336, 337)
         THEN
            -- Busca los recibos pendientes con fecha de efecto anterior y posterior a la fecha de efecto del reemplazo
            vcur :=
               f_recibos (psseguro,
                          pfanulac,
                          0,
                          pac_md_common.f_get_cxtidioma,
                          num_err
                         );
            vcont := 1;

            IF num_err <> 0
            THEN
               RETURN num_err;
            END IF;
         ELSE
            -- Busca los recibos pendientes con fecha de efecto posterior a la fecha de efecto del reemplazo
            vcur :=
               f_recibos (psseguro,
                          pfanulac,
                          10,
                          pac_md_common.f_get_cxtidioma,
                          num_err
                         );
            vcont := 1;

            IF num_err <> 0
            THEN
               RETURN num_err;
            END IF;
         END IF;

         FETCH vcur
          INTO rec_pend (vcont).nrecibo, rec_pend (vcont).fefecto,
               rec_pend (vcont).fvencim, rec_pend (vcont).fmovini, vdummy,
               vdummy2, vdummy3, vdummy4;

         WHILE vcur%FOUND
         LOOP
            vcont := vcont + 1;

            FETCH vcur
             INTO rec_pend (vcont).nrecibo, rec_pend (vcont).fefecto,
                  rec_pend (vcont).fvencim, rec_pend (vcont).fmovini, vdummy,
                  vdummy2, vdummy3, vdummy4;
         END LOOP;
      END IF;

      IF pcextorn = 1
      THEN
         -- Busca los recibos cobrados/remesados
         vcur :=
            f_recibos (psseguro,
                       pfanulac,
                       1,
                       pac_md_common.f_get_cxtidioma,
                       num_err
                      );

         IF num_err <> 0
         THEN
            RETURN num_err;
         END IF;

         FETCH vcur
          INTO rec_cobr (vcont).nrecibo, rec_cobr (vcont).fefecto,
               rec_cobr (vcont).fvencim, rec_cobr (vcont).fmovini, vdummy,
               vdummy2, vdummy3, vdummy4;

         WHILE vcur%FOUND
         LOOP
            vcont := vcont + 1;

            FETCH vcur
             INTO rec_cobr (vcont).nrecibo, rec_cobr (vcont).fefecto,
                  rec_cobr (vcont).fvencim, rec_cobr (vcont).fmovini, vdummy,
                  vdummy2, vdummy3, vdummy4;
         END LOOP;
      END IF;

      num_err :=
         f_anula_poliza (psseguro,
                         pcmotmov,
                         pcmoneda,
                         pfanulac,
                         pcextorn,
                         pcanular_rec,
                         pcagente,
                         rec_pend,
                         rec_cobr,
                         psproduc,
                         pcnotibaja,
                         pcsituac,
                         pccauanul
                        );
      RETURN num_err;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_set_solanulac',
                      1,
                      'Error no controlado',
                      SQLERRM
                     );
         RETURN 1000001;
   END f_anula_poliza_reemplazo;

   /***********************************************************************
              Funcion para determinar si se debe realizar o no el retorno de un recibo a extornar
    1.   psseguro: Identificador del seguro (IN)
    2.   pnmovimi: Numero de movimiento (IN)
    3.   psproduc: Identificador del producto (IN)
    4.   pcconcep: Concepto del recibo a extornar (IN)
    5.   pfanulac: Fecha de anulaci¿n
    6.   pnfactor: Factor
      return             : NUMBER (0 --> OK)
   ***********************************************************************/
   -- Bug 19557 - APD - 31/10/2011- se crea la funcion
   -- BUG 0020414 - 05/12/2011 - JMF: a¿adir pnfactor
   FUNCTION f_concep_retorna_anul (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      psproduc   IN       NUMBER,
      pcconcep   IN       NUMBER,
      pfanulac   IN       DATE,
      pnfactor   IN OUT   NUMBER,
      -- BUG 19557 - 22/11/2011 - JMP - LCOL_T001-Despeses expedici¿
      pcmotmov   IN       NUMBER DEFAULT NULL         -- 67. 0027644 - QT-8596
   )
      RETURN NUMBER
   IS
      num_err             NUMBER                   := 0;
      vcmotmov            movseguro.cmotmov%TYPE;
      v_fefecto           DATE;
      --bug0025826
      v_gastexp_calculo   NUMBER;
      v_val               NUMBER;
   BEGIN
      -- Si el concepto es 14.-Gastos Expedicion (para Liberty) o
      -- 'Derechos de Registro (para el resto de empresas) y NO se
      -- retorna el recibo '(GASTEXP_RETORNO' = 0), entonces no
      -- insertar en detrecibos (NO se debe realizar el extorno)
      -- en caso contrario (si se debe realizar el extorno) se
      -- inserta en detrecibos
      -- 67. 0027644 - QT-8596 - Inicio
      IF pcmotmov IS NOT NULL
      THEN
         vcmotmov := pcmotmov;
      ELSE
         -- 67. 0027644 - QT-8596 - Final
         -- Bug 25827 - APD - 29/04/2013
         SELECT NVL (cmotven, cmotmov)
           -- fin Bug 25827 - APD - 29/04/2013
         INTO   vcmotmov
           FROM movseguro
          WHERE sseguro = psseguro AND nmovimi = pnmovimi;
      END IF;                                         -- 67. 0027644 - QT-8596

      -- BUG 19557 - 22/11/2011 - JMP - LCOL_T001-Despeses expedici¿
      -- bug0025826
      SELECT fefecto, NVL (f_parproductos_v (sproduc, 'GASTEXP_CALCULO'), 0)
        INTO v_fefecto, v_gastexp_calculo
        FROM seguros
       WHERE sseguro = psseguro;

      IF v_gastexp_calculo = 2
      THEN
         -- Nueva produccion y cartera
         num_err := f_ultrenova (psseguro, v_fefecto, v_fefecto, v_val);
      END IF;

      -- FIN BUG 19557 - 22/11/2011 - JMP - LCOL_T001-Despeses expedici¿

      -- bug0025826
      v_val :=
         NVL (pac_parametros.f_parmotmov_n (vcmotmov,
                                            'GASTEXP_RETORNO',
                                            psproduc
                                           ),
              1
             );

      -- Bug 25827 - APD - 26/04/2013 - se a¿ade el concepto 86.-iva de los gastos de expedici¿n
      IF pcconcep IN (14, 86)
                             -- fin Bug 25827 - APD - 26/04/2013
         AND v_val = 0
      THEN
         RETURN 1;                          -- NO se debe realizar el extorno
      END IF;

      -- Bug 25827 - APD - 26/04/2013 - se a¿ade el concepto 86.-iva de los gastos de expedici¿n
      IF pcconcep IN (14, 86)
                             -- fin Bug 25827 - APD - 26/04/2013
         AND v_val = 1 AND v_fefecto <> pfanulac
      THEN
         RETURN 1;                          -- NO se debe realizar el extorno
      END IF;

      -- ini BUG 0020414 - 05/12/2011 - JMF
      -- JLB - 11/01/2012 - si se externo les despeses de expedicio, miramos si se proratea
      -- Bug 0021289 - FAL- 08/02/2012
      --IF NVL(pac_parametros.f_parproducto_n(psproduc, 'GASTEXP_ANUL_PROR'), 0) = 0 THEN
      -- Bug 25827 - APD - 26/04/2013 - se a¿ade el concepto 86.-iva de los gastos de expedici¿n
      IF     pcconcep IN (14, 86)
         -- fin Bug 25827 - APD - 26/04/2013
         AND NVL (pac_parametros.f_parproducto_n (psproduc,
                                                  'GASTEXP_ANUL_PROR'
                                                 ),
                  1
                 ) = 0
      THEN
         -- param GASTEXP_ANUL_PROR debe ser = 0 si no se prorratea los gastos de expedici¿n.
         -- Fi Bug 0021289
         pnfactor := 1;
      END IF;

      -- fin BUG 0020414 - 05/12/2011 - JMF
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_concep_retorna_anul',
                      1,
                      'Error no controlado',
                      SQLERRM
                     );
         RETURN 1000001;
   END f_concep_retorna_anul;

   /***********************************************************************
           Funcion para determinar si se debe mostrar o no el check Anulacion a corto plazo
    1.   psproduc: Identificador del producto (IN)
    2.   pcmotmov: Motivo de movimiento (IN)
    3.   psseguro: Identificador de la poliza (IN)
    4.   pcvisible: Devuelve 0 si no es visible, 1 si si es visible (OUT)
      return             : NUMBER (0 --> OK)
   ***********************************************************************/
   -- Bug 22826 - APD - 12/07/2012- se crea la funcion
   -- Bug 23817 - APD - 04/10/2012 - se a¿ade el parametro psseguro
   FUNCTION f_aplica_penali_visible (
      psproduc    IN       NUMBER,
      pcmotmov    IN       NUMBER,
      psseguro    IN       NUMBER,
      pcvisible   OUT      NUMBER
   )
      RETURN NUMBER
   IS
      num_err         NUMBER                      := 0;
      vntraza         NUMBER;
      vparam          VARCHAR2 (4000)
         :=    'psproduc = '
            || psproduc
            || ' - pcmotmov = '
            || pcmotmov
            || ' - psseguro = '
            || psseguro;
      vcvalpar        parmotmov.cvalpar%TYPE;
      vcparmot        parmotmov.cparmot%TYPE;
      vcrespue        pregunpolseg.crespue%TYPE;
      vescertifcero   NUMBER;
      salir           EXCEPTION;
   BEGIN
      vntraza := 1;
      vcparmot := 'PORC_PENALI_ANU';
      -- Por defecto se pone como no visible el campo
      -- Si s¿ existiera la configuracion, se marcaria como visible
      pcvisible := 0;
      vntraza := 2;
      -- Bug 23817 - APD - 04/10/2012 - si se trata de un colectivo administrado
      -- y el sseguro que le llega no corresponde a un certificado 0 entonces el
      -- check de corto plazo no debe ser visible
      num_err :=
           pac_preguntas.f_get_pregunpolseg (psseguro, 4092, 'REA', vcrespue);

      IF num_err NOT IN (0, 120135)
      THEN
         RAISE salir;
      END IF;

      vescertifcero :=
                      NVL (pac_seguros.f_get_escertifcero (NULL, psseguro), 0);

      -- vcrespue = 1.- Tipo de colectivo Administrado
      -- vescertifcero = 0 --> no es el certificado 0
      -- No debe estar visible el check Anulacion a corto plazo

      --Bug 29358/163020 - JSV - 16/01/2014
      --IF vcrespue = 1
      --   AND vescertifcero = 0 THEN
      --   pcvisible := 0;
      --ELSE
         -- fin Bug 23817 - APD - 04/10/2012
      BEGIN
         SELECT cvalpar
           INTO vcvalpar
           FROM parmotmov
          WHERE sproduc = psproduc AND cparmot = vcparmot
                AND cmotmov = pcmotmov;

         pcvisible := 1;
      -- SI hay configuracion y se debe ver el check 'Anulacion a corto plazo'
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               vntraza := 3;

               SELECT cvalpar
                 INTO vcvalpar
                 FROM parmotmov
                WHERE sproduc = 0 AND cparmot = vcparmot
                      AND cmotmov = pcmotmov;

               pcvisible := 1;
            -- SI hay configuracion y se debe ver el check 'Anulacion a corto plazo'
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  vntraza := 4;
               WHEN OTHERS
               THEN
                  vntraza := 5;
                  num_err := 1000455;
                  RAISE salir;
            END;
         WHEN OTHERS
         THEN
            vntraza := 6;
            num_err := 1000455;
            RAISE salir;
      END;

      --END IF;
      vntraza := 7;
      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_aplica_penali_visible',
                      vntraza,
                      vparam,
                      f_axis_literales (num_err)
                     );
         RETURN 1000001;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_anulacion.f_aplica_penali_visible',
                      vntraza,
                      'Error no controlado',
                      SQLERRM
                     );
         RETURN 1000001;
   END f_aplica_penali_visible;

   /*************************************************************************
                                       FUNCTION f_recibos_colectivo
      Funcion para recuperar los recibos de un colectivo (los recibos
      del certificado 0 m¿s todos los recibos de todos sus certificados
      teniendo en cuenta la agrupacion de recibos)
      param in psseguro  : Num. seguro
      param in pfanulac  : Fecha de anulacion
      param out perror   : Numero de error
      param in pcestrec  : 0.- Pendiente, 1.- Cobrado
      return             : sys_refcursor
   *************************************************************************/
   -- Bug 23817 - APD - 27/09/2012 - se crea la funcion
   FUNCTION f_recibos_colectivo (
      psseguro    IN       NUMBER,
      pfanulac    IN       DATE,
      pctipocon   IN       NUMBER,
      pcidioma    IN       NUMBER,
      perror      OUT      NUMBER
   )
      RETURN VARCHAR2
   IS
      vquery      VARCHAR2 (10000);
      vnpoliza    seguros.npoliza%TYPE;
      vmensaje    t_iax_mensajes;
      v_cempres   seguros.cempres%TYPE;        -- BUG 29965 - FAL - 13/2/2014
   BEGIN
      -- se busca el npoliza del certificado 0
      SELECT npoliza, cempres                   -- BUG 29965 - FAL - 13/2/2014
        INTO vnpoliza, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      -- si estamos en un certificado 0 (pac_seguros.f_get_escertifcero(NULL, psseguro) = 1)
      -- se buscaran todos los recibos del certificado 0
      -- m¿s todos los recibos de todos sus certificados
      -- teniendo en cuenta la agrupacion de recibos
      -- si NO estamos en un certificado 0 (pac_seguros.f_get_escertifcero(NULL, psseguro) = 0)
      -- se buscaran todos los recibos del certificado X
      -- teniendo en cuenta la agrupacion de recibos
      -- Nota: este segundo caso es cuando se est¿ realizando la anulacion masiva de certificados X
      -- porque se est¿ realizando la anulacion del certificado 0. En este caso se deben anular
      -- los recibos pedientes del certificado X que no pertenezcan a un rebido agrupado
      IF pctipocon = 0
      THEN
         vquery :=
               'SELECT r.nrecibo, r.fefecto, r.fvencim,'
            || ' m.fmovini, pac_anulacion.f_marcado(r.nrecibo, to_date('''
            || TO_CHAR (pfanulac, 'ddmmyyyy')
            || ''',''ddmmyyyy'') ) marcado,'
            || ' f_cagente(r.sseguro,1) || '' - '' || ff_desagente_per(f_cagente(r.sseguro,1)) tagente,'
            || ' (select tatribu from detvalores where cvalor = 8 and catribu = ctiprec and cidioma = '
            || pcidioma
            || ') ttiprec, v.itotalr'
            || ' FROM seguros s, movrecibo m, recibos r, movseguro ms, vdetrecibos v'
            || ' WHERE m.nrecibo = r.nrecibo'
            || ' AND m.fmovfin IS NULL'
            || ' AND r.sseguro = ms.sseguro'
            || ' AND r.nmovimi = ms.nmovimi'
            || ' AND ms.cmovseg <> 3 '
            || ' AND m.cestrec = 0'
            || ' AND r.sseguro = s.sseguro '
            || ' AND ((s.npoliza = '
            || vnpoliza
            || ' AND pac_seguros.f_get_escertifcero(NULL, '
            || psseguro
            || ') = 1 ) '
            || '  OR (s.sseguro = '
            || psseguro
            || ' AND pac_seguros.f_get_escertifcero(NULL, '
            || psseguro
            || ') = 0 )) '
            || ' AND r.nrecibo = v.nrecibo '
            || ' AND r.nrecibo NOT IN (SELECT nrecibo FROM adm_recunif) '
            -- BUG 29965 - FAL - 13/2/2014
            || ' AND ((NVL(pac_parametros.f_parempresa_n('
            || v_cempres
            || ',''ANUL_REC_POST_ANULAC''),0) = 1 AND r.fefecto >= to_date('''
            || TO_CHAR (pfanulac, 'ddmmyyyy')
            || ''',''ddmmyyyy''))'
            || ' OR (NVL(pac_parametros.f_parempresa_n('
            || v_cempres
            || ', ''ANUL_REC_POST_ANULAC''), 0) = 0))'
            -- FI BUG 29965 - FAL - 13/2/2014
            || ' ORDER BY nrecibo';
      ELSIF pctipocon = 1
      THEN
         -- Se modifica la select para que busque los recibos cobrados (cestrec = 1) y los remesados (cestrec = 3) (detvalores = 1)
         vquery :=
               'SELECT r.nrecibo, r.fefecto, r.fvencim, m.fmovini, 1 marcado,'
            || ' f_cagente(ms.sseguro,1) || '' - '' || ff_desagente_per(f_cagente(ms.sseguro,1)) tagente,'
            || ' (select tatribu from detvalores where cvalor = 8 and catribu = ctiprec and cidioma = '
            || pcidioma
            || ') ttiprec, v.itotalr'
            || ' FROM seguros s, movrecibo m, recibos r, movseguro ms, vdetrecibos v'
            || ' WHERE m.nrecibo = r.nrecibo'
            || ' AND m.fmovfin IS NULL'
            || ' AND m.cestrec IN (1,3)'
            || ' AND r.fvencim > to_date('''
            || TO_CHAR (pfanulac, 'ddmmyyyy')
            || ''',''ddmmyyyy'') '
            || ' AND r.sseguro = s.sseguro '
            || ' AND ((s.npoliza = '
            || vnpoliza
            || ' AND pac_seguros.f_get_escertifcero(NULL, '
            || psseguro
            || ') = 1 ) '
            || '  OR (s.sseguro = '
            || psseguro
            || ' AND pac_seguros.f_get_escertifcero(NULL, '
            || psseguro
            || ') = 0 )) '
            || ' AND r.sseguro = ms.sseguro'
            || ' AND r.nmovimi = ms.nmovimi'
            || ' AND ms.cmovseg <> 3 AND r.nrecibo = v.nrecibo '
            || ' AND r.nrecibo NOT IN (SELECT nrecibo FROM adm_recunif) '
            || ' ORDER BY r.nrecibo';
      ELSIF pctipocon = 10
      THEN
         -- Es la misma condici¿n que la pctipocon = 0 pero a¿adiendo el filtro r.fefecto > pfanulac
         vquery :=
               'SELECT r.nrecibo, r.fefecto, r.fvencim,'
            || ' m.fmovini, pac_anulacion.f_marcado(r.nrecibo, to_date('''
            || TO_CHAR (pfanulac, 'ddmmyyyy')
            || ''',''ddmmyyyy'') ) marcado,'
            || ' f_cagente(r.sseguro,1) || '' - '' || ff_desagente_per(f_cagente(r.sseguro,1)) tagente,'
            || ' (select tatribu from detvalores where cvalor = 8 and catribu = ctiprec and cidioma = '
            || pcidioma
            || ') ttiprec, v.itotalr'
            || ' FROM seguros s, movrecibo m, recibos r, movseguro ms, vdetrecibos v'
            || ' WHERE m.nrecibo = r.nrecibo'
            || ' AND m.fmovfin IS NULL'
            || ' AND m.cestrec = 0'
            || ' AND r.sseguro = s.sseguro '
            || ' AND r.sseguro = ms.sseguro'
            || ' AND r.nmovimi = ms.nmovimi'
            || ' AND ms.cmovseg <> 3 '
            || ' AND ((s.npoliza = '
            || vnpoliza
            || ' AND pac_seguros.f_get_escertifcero(NULL, '
            || psseguro
            || ') = 1 ) '
            || '  OR (s.sseguro = '
            || psseguro
            || ' AND pac_seguros.f_get_escertifcero(NULL, '
            || psseguro
            || ') = 0 )) '
            || ' AND r.fefecto >  to_date('''
            || TO_CHAR (pfanulac, 'ddmmyyyy')
            || ''',''ddmmyyyy'')'
            || ' AND r.nrecibo = v.nrecibo '
            || ' AND r.nrecibo NOT IN (SELECT nrecibo FROM adm_recunif) '
            || ' ORDER BY nrecibo';
      END IF;

      IF pac_md_log.f_log_consultas (vquery, 'ANULACIONES', 1, 4, vmensaje) =
                                                                             0
      THEN
         NULL;
      END IF;

      perror := 0;
      RETURN vquery;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_ANULACION.f_recibos_colectivo',
                      1,
                         'psseguro: '
                      || psseguro
                      || ' - pfanulac: '
                      || pfanulac
                      || ' - pctipocon: '
                      || pctipocon,
                      SQLCODE || ' - ' || SQLERRM
                     );
         perror := SQLCODE;
         RETURN NULL;
   END f_recibos_colectivo;

   /*************************************************************************
                                         FUNCTION F_CALCUL_EXTORN_RECIBOS_MANUAL
        Funcion que realiza el c¿lculo del extorno aplicado a partir del importe
        introducido por el usuario.
        param in psseguro  : Num. seguro
        param in pnrecibo  : Num recibo extorno
        param in pimpextorsion : Importe introducido por el usuario
        return   RESULT   : 0 - ok / 1 - ko
     *************************************************************************/-- 23183 JDS 14/12/2012  creaci¿n de funci¿n
   FUNCTION f_calcul_extorn_recibos_manual (
      pseguro         IN   NUMBER,
      pnrecibo        IN   NUMBER,
      pimpextorsion   IN   NUMBER
   )                 -- 23183 14/12/2012  JDS  se a¿ade variable pimpextorsion
      RETURN NUMBER
   IS
      RESULT                 NUMBER := 0;
      v_traza                NUMBER := 0;
      porcentaje             NUMBER;
      totalconceptos         NUMBER;
      diferencia             NUMBER;
      totalconcepextorsion   NUMBER;
      concepextorsion_suma   NUMBER := 0;
      vnumreg                NUMBER := 0;
      pimpextorsion_round    NUMBER;

      CURSOR cur_concep_recibo (pnrecibo IN NUMBER, pseguro IN NUMBER)
      IS
         SELECT   d.nrecibo, d.iconcep_monpol, d.iconcep, d.cconcep,
                  d.cgarant, ROWNUM numreg
             FROM detrecibos d, recibos r
            WHERE d.nrecibo = pnrecibo
              AND d.nrecibo = r.nrecibo
              AND r.sseguro = pseguro
         ORDER BY ROWNUM, d.cgarant, d.cconcep;

      CURSOR cur_concep0_recibo (pnrecibo IN NUMBER, pseguro IN NUMBER)
      IS
         SELECT   d.nrecibo, d.iconcep_monpol, d.iconcep, d.cconcep,
                  d.cgarant, ROWNUM numreg
             FROM detrecibos d, recibos r
            WHERE d.nrecibo = pnrecibo
              AND d.nrecibo = r.nrecibo
              AND r.sseguro = pseguro
              AND d.cconcep IN (0)
         ORDER BY ROWNUM;
   BEGIN
      v_traza := 1;
      pimpextorsion_round := f_round (pimpextorsion);

      --se calcula la cantidad total que se deber¿a extornar de los recibos del seguro con concepto 0 (prima devengada)
      SELECT SUM (iconcep)
        INTO totalconceptos
        FROM recibos r, detrecibos d
       WHERE r.sseguro = pseguro
         AND r.nrecibo = d.nrecibo
         AND r.nrecibo = pnrecibo
         AND d.cconcep IN (0);

      --se calcula la diferencia entre el total de conceptos 0 del recibo y el importe de extorsion introducido.
      IF totalconceptos <> 0
      THEN
         v_traza := 2;
         diferencia := pimpextorsion_round - totalconceptos;
         porcentaje := diferencia / totalconceptos;
         v_traza := 3;

         FOR concep IN cur_concep_recibo (pnrecibo, pseguro)
         LOOP
            v_traza := 4;

            IF concep.cconcep <> 14
            THEN
               --se calcula a partir del campo iconcep el importe estornado.
               totalconcepextorsion :=
                        f_round (porcentaje * concep.iconcep)
                        + concep.iconcep;
               v_traza := 5;

               BEGIN
                  UPDATE detrecibos
                     SET iconcep = totalconcepextorsion
                   WHERE nrecibo = pnrecibo
                     AND cconcep = concep.cconcep
                     AND cgarant = concep.cgarant;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     p_tab_error
                             (f_sysdate,
                              f_user,
                              'PAC_ANULACION.f_calcul_extorn_recibos_manual',
                              v_traza,
                                 'pseguro: '
                              || pseguro
                              || ' - pnrecibo: '
                              || pnrecibo
                              || ' - pimpextorsion: '
                              || pimpextorsion,
                              SQLCODE || ' - ' || SQLERRM
                             );
               END;
            ELSE
               v_traza := 6;

               BEGIN
                  UPDATE detrecibos
                     SET iconcep = 0
                   WHERE nrecibo = pnrecibo
                     AND cconcep = concep.cconcep
                     AND cgarant = concep.cgarant;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     p_tab_error
                             (f_sysdate,
                              f_user,
                              'PAC_ANULACION.f_calcul_extorn_recibos_manual',
                              v_traza,
                                 'pseguro: '
                              || pseguro
                              || ' - pnrecibo: '
                              || pnrecibo
                              || ' - pimpextorsion: '
                              || pimpextorsion,
                              SQLCODE || ' - ' || SQLERRM
                             );
               END;
            END IF;
         END LOOP;

         --se calcula el numero de conceptos 0 del recibo de extorno .
         SELECT COUNT (*)
           INTO vnumreg
           FROM detrecibos d, recibos r
          WHERE d.nrecibo = pnrecibo
            AND d.nrecibo = r.nrecibo
            AND r.sseguro = pseguro
            AND d.cconcep IN (0);

         v_traza := 7;

         --la suma de los conceptos 0 (campo iconcep) deberia ser igual al importe extornado, si no lo es (porque se han perdido decimales durante el redondeo)
         --se cuadrara la diferencia en el ultimo concepto 0 del recibo de extorno
         IF (totalconceptos <> pimpextorsion_round)
         THEN
            FOR concep0 IN cur_concep0_recibo (pnrecibo, pseguro)
            LOOP
               concepextorsion_suma := concepextorsion_suma + concep0.iconcep;

               IF (concep0.numreg = vnumreg)
               THEN
                  totalconcepextorsion :=
                       concep0.iconcep
                     + (pimpextorsion_round - concepextorsion_suma);

                  BEGIN
                     UPDATE detrecibos
                        SET iconcep = totalconcepextorsion
                      WHERE nrecibo = pnrecibo
                        AND cconcep = concep0.cconcep
                        AND cgarant = concep0.cgarant;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        p_tab_error
                             (f_sysdate,
                              f_user,
                              'PAC_ANULACION.f_calcul_extorn_recibos_manual',
                              v_traza,
                                 'pseguro: '
                              || pseguro
                              || ' - pnrecibo: '
                              || pnrecibo
                              || ' - pimpextorsion: '
                              || pimpextorsion,
                              SQLCODE || ' - ' || SQLERRM
                             );
                  END;
               END IF;
            END LOOP;
         END IF;

         RESULT := pac_oper_monedas.f_contravalores_recibo (pnrecibo, 'R');
      END IF;

      RETURN RESULT;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_ANULACION.f_calcul_extorn_recibos_manual',
                      v_traza,
                         'pseguro: '
                      || pseguro
                      || ' - pnrecibo: '
                      || pnrecibo
                      || ' - pimpextorsion: '
                      || pimpextorsion,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 1;
   END f_calcul_extorn_recibos_manual;

   /*********************************************
    Funcion que devuelve si el padre de un recibo esta cobrado
    Bug 37028/214287 - 23/09/2015 - AMC
   **********************************************/
   FUNCTION f_padre_cobrado (pnrecibo NUMBER)
      RETURN NUMBER
   IS
      vctiprec   NUMBER;
      vcount     NUMBER;
   BEGIN
      SELECT ctiprec
        INTO vctiprec
        FROM recibos
       WHERE nrecibo = pnrecibo;

      IF vctiprec IN (13, 15)
      THEN
         SELECT COUNT (m.nrecibo)
           INTO vcount
           FROM rtn_recretorno rt, movrecibo m
          WHERE rt.nrecretorno = pnrecibo
            AND rt.nrecibo = m.nrecibo
            AND m.cestrec = 1
            AND m.cestant = 0
            AND fmovfin IS NULL;

         IF vcount > 0
         THEN
            RETURN 1;
         ELSE
            RETURN 0;
         END IF;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_ANULACION.f_padre_cobrado',
                      1,
                      ' pnrecibo: ' || pnrecibo,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN -99;
   END f_padre_cobrado;
END pac_anulacion;
/