--------------------------------------------------------
--  DDL for Package Body PAC_PROVMAT_FORMUL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROVMAT_FORMUL" 
IS
/******************************************************************************
 NOMBRE:     Pac_Provmat_Formul
 PROPÓSITO:  Funciones de provisiones

 REVISIONES:
 Ver        Fecha        Autor             Descripción
 ---------  ----------  ---------------  ------------------------------------
 1.0        XX/XX/XXXX   XXX                1. Creación del package.
 2.0        27/04/2009   APD                2. Bug 9699 - primero se ha de buscar para la actividad en concreto
                                               y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
 2.1        27/04/2009   APD                3. Bug 9685 - en lugar de coger la actividad de la tabla seguros, llamar a la
                                               función pac_seguros.ff_get_actividad
 3.0        14/12/2009   NMM                4. 12275: CRE - Cálculo de provisión en vencimientos del PPJ Dinámico.
 4.0        22/12/2009   RSC                5. 0010690: APR - Provisiones en productos de cartera (PORTFOLIO)
 5.0        10/02/2010   AVT                6. 13047: CRE - Se detectan pólizas del PPJ Dinàmic que no tienen calcula la provisión matemática de Enero
                                               Per defecte les pòlisses retingudes per rescat parcial Si generaran PM
 6.0        02/03/2010   RSC                7. 0013463: CRE - La baja de garantía 'Muerte / Invalidez' provoca que deje de calcularse la provisión (PPJ / PLA Estudiant)
 7.0        09/02/2011   DRA                8. 0017591: CRT002 - Configurar provisión matemática para productos RGA
 8.0        02/11/2011   JMP                9. 0018423: LCOL000 - Multimoneda
 9.0        29/03/2012   RSC               10. 0021863: LCOL - Incidencias Reservas
10.0        26/04/2013   ECP               11. 0024704: LCOL - Descuentos comerciales sobre prima para pólizas de migración - Vida Individual. Nota 0142669
11.0        20/05/2015   YDA               11. 0034636 Se modifica la función ff_evolu para incluir el parámetro pnscenario
******************************************************************************/-- ****************************************************************
 -- Cursor para el calculo de la provisión-- 28-3-2007. Se tiene en cuenta la fecha tarifa en las fórmulas
 -- ****************************************************************
   FUNCTION f_commit_calcul_pm_formul (
      pcempres   IN   NUMBER,
      pfcalcul   IN   DATE,
      psproces   IN   NUMBER,
      pcidioma   IN   NUMBER,
      pcmoneda   IN   NUMBER,
      pmodo      IN   VARCHAR2 DEFAULT 'R'
   )
      RETURN NUMBER
   IS
-- Definición de cursores
-- Cursor de Polizas
-- RSC 16/11/2007 --------------------------------------------------------
-- Se excluyen las tablas PROVISPROD y CODPROVISIONES de la query de selección
-- de pólizas. Al no tener éstas tablas parametrizadas tanto para los productos
-- de ahorro como para Unit Linked, el cierre de provisiones no podia funcionar
-- al no seleccionar pólizas. De momento se ha tomado la decisión de excluir estas
-- tablas y guardar un 0 en la tabla PROVMAT para el campo CPROVIS. Se tiene
-- en cuenta que el valor 0 en la tabla CODPROVISIONES indica que "NO cálcula
-- provisiones", pero en este caso simplemente no indica nada. Este campo no
-- se utiliza.
-- APD 05/12/2008 --------------------------------------------------------
-- Se cambia el valor 0 (No calcula provisión) del campo cprovis por el valor 99 (Provisión matemática)
-- ya que se elimina de la tabla CODPROVISIONES la provision 0.
-- Bug 9699 - APD - 27/04/2009 - primero se ha de buscar para la actividad en concreto
-- y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
-- Bug 9685 - APD - 27/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
      CURSOR c_pol
      IS
         SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro,
                pac_seguros.ff_get_actividad (s.sseguro, gs.nriesgo) cactivi,
                s.cforpag, s.fvencim, gs.cgarant, gs.icaptot, gs.nriesgo,
                p.sproduc, p.cramdgs, s.fanulac, 99 cprovis,    --pr.cprovis,
                                                            gs.ipritot,
                gs.ftarifa
           FROM productos p, codiram r, seguros s, garanseg gs
          WHERE r.cempres = pcempres
            AND p.cramo = r.cramo
            AND p.sproduc = s.sproduc
            AND (s.fvencim > pfcalcul OR s.fvencim IS NULL)
            AND f_situacion_v (s.sseguro, pfcalcul) = 1
            AND s.fefecto < pfcalcul + 1
            AND (    (gs.finiefe <= pfcalcul)
                 AND (gs.ffinefe IS NULL OR gs.ffinefe > pfcalcul)
                )
            AND s.sseguro = gs.sseguro
            -- AND pac_motretencion.f_esta_retenica_sin_resc(s.sseguro, pfcalcul) = 0 BUG: 13047 10-02-2010 AVT
            AND pac_propio.f_retenida_siniestro (s.sseguro,
                                                 pfcalcul,
                                                 gs.cgarant,
                                                 3
                                                ) = 0
            -- Bug 21863 - RSC - 29/03/2012 - LCOL - Incidencias Reservas
            AND EXISTS (
                   SELECT gf.cgarant
                     FROM garanformula gf, codcampo cd
                    WHERE gf.cramo = s.cramo
                      AND s.cmodali = gf.cmodali
                      AND s.ctipseg = gf.ctipseg
                      AND s.ccolect = gf.ccolect
                      AND pac_seguros.ff_get_actividad (s.sseguro, gs.nriesgo) =
                                                                    gf.cactivi
                      AND gs.cgarant = gf.cgarant
                      AND gf.ccampo = cd.ccampo
                      AND cd.cutili = 8
                      AND cd.ccampo IN ('IPROVMAT', 'ICAPFALL', 'ICAPGAR')
                   UNION
                   SELECT gf.cgarant
                     FROM garanformula gf, codcampo cd
                    WHERE gf.cramo = s.cramo
                      AND s.cmodali = gf.cmodali
                      AND s.ctipseg = gf.ctipseg
                      AND s.ccolect = gf.ccolect
                      AND 0 = gf.cactivi
                      AND gs.cgarant = gf.cgarant
                      AND gf.ccampo = cd.ccampo
                      AND cd.cutili = 8
                      AND cd.ccampo IN ('IPROVMAT', 'ICAPFALL', 'ICAPGAR')
                      AND NOT EXISTS (
                             SELECT gf.cgarant
                               FROM garanformula gf, codcampo cd
                              WHERE gf.cramo = s.cramo
                                AND s.cmodali = gf.cmodali
                                AND s.ctipseg = gf.ctipseg
                                AND s.ccolect = gf.ccolect
                                AND pac_seguros.ff_get_actividad (s.sseguro,
                                                                  gs.nriesgo
                                                                 ) =
                                                                    gf.cactivi
                                AND gs.cgarant = gf.cgarant
                                AND gf.ccampo = cd.ccampo
                                AND cd.cutili = 8
                                AND cd.ccampo IN
                                          ('IPROVMAT', 'ICAPFALL', 'ICAPGAR')));

      -- formulas de provisiones

      -- Bug 9685 - APD - 27/04/2009 - Fin
      -- Bug 9699 - APD - 27/04/2009 - Fin

      -- Cursor de formulas de provisiones
      CURSOR c_provis (
         pcgarant   IN   NUMBER,
         pcramo     IN   NUMBER,
         pcmodali   IN   NUMBER,
         pctipseg   IN   NUMBER,
         pccolect   IN   NUMBER,
         pcactivi   IN   NUMBER
      )
      IS
         -- Bug 9699 - APD - 27/04/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
         SELECT gf.clave, gf.ccampo
           FROM garanformula gf, codcampo cd
          WHERE gf.cgarant = pcgarant
            AND gf.cramo = pcramo
            AND gf.cmodali = pcmodali
            AND gf.ctipseg = pctipseg
            AND gf.ccolect = pccolect
            AND gf.cactivi = pcactivi
            AND cd.ccampo = gf.ccampo
            AND cd.cutili = 8
            AND cd.ccampo IN ('IPROVMAT', 'ICAPFALL', 'ICAPGAR')
         UNION
         SELECT gf.clave, gf.ccampo
           FROM garanformula gf, codcampo cd
          WHERE gf.cgarant = pcgarant
            AND gf.cramo = pcramo
            AND gf.cmodali = pcmodali
            AND gf.ctipseg = pctipseg
            AND gf.ccolect = pccolect
            AND gf.cactivi = 0
            AND cd.ccampo = gf.ccampo
            AND cd.cutili = 8
            AND cd.ccampo IN ('IPROVMAT', 'ICAPFALL', 'ICAPGAR')
            AND NOT EXISTS (
                   SELECT gf.clave, gf.ccampo
                     FROM garanformula gf, codcampo cd
                    WHERE gf.cgarant = pcgarant
                      AND gf.cramo = pcramo
                      AND gf.cmodali = pcmodali
                      AND gf.ctipseg = pctipseg
                      AND gf.ccolect = pccolect
                      AND gf.cactivi = pcactivi
                      AND cd.ccampo = gf.ccampo
                      AND cd.cutili = 8
                      AND cd.ccampo IN ('IPROVMAT', 'ICAPFALL', 'ICAPGAR'));

         -- Bug 9699 - APD - 27/04/2009 - Fin
      --
      xprovmat   NUMBER;
      num_err    NUMBER;
      nlin       NUMBER;
      cont_err   NUMBER;
      ttexto     VARCHAR2 (400);
      valor      NUMBER;
      xcapfall   NUMBER;
      xcapgar    NUMBER;
      xorigen    NUMBER         := 2;
   --
   BEGIN
      --
      cont_err := 0;

      --
      FOR pol IN c_pol
      LOOP
         xprovmat := 0;
         xcapfall := 0;
         xcapgar := 0;

         FOR prov IN c_provis (pol.cgarant,
                               pol.cramo,
                               pol.cmodali,
                               pol.ctipseg,
                               pol.ccolect,
                               pol.cactivi
                              )
         LOOP
            valor := 0;
            num_err :=
               pac_calculo_formulas.calc_formul (pfcalcul,
                                                 pol.sproduc,
                                                 pol.cactivi,
                                                 pol.cgarant,
                                                 pol.nriesgo,
                                                 pol.sseguro,
                                                 prov.clave,
                                                 valor,
                                                 NULL,
                                                 NULL,
                                                 xorigen,
                                                 pol.ftarifa,
                                                 pmodo
                                                );

            IF num_err = 0
            THEN
               IF prov.ccampo = 'IPROVMAT'
               THEN
                  xprovmat := valor;
               ELSIF prov.ccampo = 'ICAPFALL'
               THEN
                  xcapfall := valor;
               ELSIF prov.ccampo = 'ICAPGAR'
               THEN
                  xcapgar := valor;
               ELSE
                  --num_err := 151350;
                  -- error al calcular el valor de la provisión
                  EXIT;
               END IF;
            ELSE
               num_err := 151350;
               EXIT;
            END IF;
         END LOOP;

         IF num_err = 0
         THEN
            BEGIN
               IF pmodo = 'R'
               THEN
                  INSERT INTO provmat
                              (cempres, fcalcul, sproces, cramdgs,
                               cramo, cmodali, ctipseg,
                               ccolect, sseguro, cgarant,
                               cprovis, ipriini,
                               ivalact, icapgar,
                               ipromat, cerror, nriesgo
                              )
                       VALUES (pcempres, pfcalcul, psproces, pol.cramdgs,
                               pol.cramo, pol.cmodali, pol.ctipseg,
                               pol.ccolect, pol.sseguro, pol.cgarant,
                               pol.cprovis, NVL (pol.ipritot, 0),
                               NVL (xcapfall, 0), NVL (xcapgar, 0),
                               xprovmat, 0, pol.nriesgo
                              );

                  -- BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
                  IF NVL (pac_parametros.f_parempresa_n (pcempres,
                                                         'MULTIMONEDA'
                                                        ),
                          0
                         ) = 1
                  THEN
                     num_err :=
                        pac_oper_monedas.f_contravalores_provmat
                                                                (psproces,
                                                                 pol.sseguro,
                                                                 pol.nriesgo,
                                                                 pol.cgarant,
                                                                 pfcalcul
                                                                );
                  END IF;
               -- FIN BUG 18423 - 02/11/2011 - JMP - LCOL000 - Multimoneda
               ELSIF pmodo = 'P'
               THEN
                  INSERT INTO provmat_previo
                              (cempres, fcalcul, sproces, cramdgs,
                               cramo, cmodali, ctipseg,
                               ccolect, sseguro, cgarant,
                               cprovis, ipriini,
                               ivalact, icapgar,
                               ipromat, cerror, nriesgo
                              )
                       VALUES (pcempres, pfcalcul, psproces, pol.cramdgs,
                               pol.cramo, pol.cmodali, pol.ctipseg,
                               pol.ccolect, pol.sseguro, pol.cgarant,
                               pol.cprovis, NVL (pol.ipritot, 0),
                               NVL (xcapfall, 0), NVL (xcapgar, 0),
                               xprovmat, 0, pol.nriesgo
                              );
               END IF;

               COMMIT;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'CIERRE PROVISIONES MAT PROCESO =' || psproces,
                               NULL,
                                  'error al insertar en provmat SSEGURO ='
                               || pol.sseguro
                               || ' PFECHA='
                               || pfcalcul,
                               SQLERRM
                              );
                  p_tab_error (f_sysdate,
                               f_user,
                               'PROVISIONES',
                               NULL,
                               NULL,
                                  'PREV.PROV'
                               || pcempres
                               || '-'
                               || '-'
                               || psproces
                               || '-'
                               || pol.cramdgs
                               || '-'
                               || pol.cramo
                               || '-'
                               || pol.cmodali
                               || '-'
                               || pol.ctipseg
                               || '-'
                               || pol.ccolect
                               || '-'
                               || pol.sseguro
                               || '-'
                               || pol.cgarant
                               || '-'
                               || pol.cprovis
                               || '-'
                               || pol.ipritot
                               || '-'
                               || NVL (xcapfall, 0)
                               || '-'
                               || NVL (xcapgar, 0)
                               || '-'
                               || xprovmat
                               || '-'
                               || 0
                               || '-'
                               || pol.nriesgo
                              );
                  num_err := 107110;  -- Error al insertar en la tabla PORVMAT
            END;
         END IF;

         IF num_err <> 0
         THEN
            ROLLBACK;
            ttexto := f_axis_literales (num_err, pcidioma);
            num_err :=
               f_proceslin (psproces,
                            ttexto || ' - PROVMAT ' || pol.cprovis,
                            pol.sseguro,
                            nlin
                           );
            COMMIT;
            cont_err := cont_err + 1;
            nlin := NULL;
         END IF;
      --
      END LOOP;                                           -- Cursor de Pólizas

      --
      RETURN cont_err;
   --
   END f_commit_calcul_pm_formul;

-------------------------------------------------------------------------------
   FUNCTION f_calcul_pm_seguro (
      psseguro   IN   NUMBER,
      pfcalcul   IN   DATE,
      pmodo      IN   VARCHAR2 DEFAULT 'R'
   )
      RETURN NUMBER
   IS
      /*******************************************************************************************
         Calcula la provisión matemática de una póliza a una fecha determinada

         Devuelve la suma de la provisión de todas las garantías que calculan provisión en esa póliza
      ********************************************************************************************/

      -- Cursor de garantías-fórmulas
      CURSOR c_pol
      IS
         -- Bug 9699 - APD - 27/04/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
         -- Bug 9685 - APD - 27/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
         SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro,
                pac_seguros.ff_get_actividad (s.sseguro, gs.nriesgo) cactivi,
                s.cforpag, s.fvencim, s.sproduc, gs.cgarant, gs.icaptot,
                gs.nriesgo, s.fanulac, gf.clave, gf.ccampo, gs.ftarifa
           FROM seguros s, garanseg gs, garanformula gf, codcampo cd
          WHERE s.sseguro = psseguro
            AND s.sseguro = gs.sseguro
            AND (    (gs.finiefe <= pfcalcul)
                 AND (gs.ffinefe IS NULL OR gs.ffinefe >= pfcalcul)
                )
            AND gf.cramo = s.cramo
            AND s.cmodali = gf.cmodali
            AND s.ctipseg = gf.ctipseg
            AND s.ccolect = gf.ccolect
            AND pac_seguros.ff_get_actividad (s.sseguro, gs.nriesgo) =
                                                                    gf.cactivi
            AND gs.cgarant = gf.cgarant
            AND gf.ccampo = cd.ccampo
            AND cd.ccampo = 'IPROVMAT'
            AND cd.cutili = 8
            --and gf.cgarant = 1
            AND (s.fvencim > pfcalcul OR s.fvencim IS NULL)
            AND f_situacion_v (s.sseguro, pfcalcul) = 1
            AND s.fefecto < pfcalcul + 1
         UNION
         SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro,
                pac_seguros.ff_get_actividad (s.sseguro, gs.nriesgo) cactivi,
                s.cforpag, s.fvencim, s.sproduc, gs.cgarant, gs.icaptot,
                gs.nriesgo, s.fanulac, gf.clave, gf.ccampo, gs.ftarifa
           FROM seguros s, garanseg gs, garanformula gf, codcampo cd
          WHERE s.sseguro = psseguro
            AND s.sseguro = gs.sseguro
            AND (    (gs.finiefe <= pfcalcul)
                 AND (gs.ffinefe IS NULL OR gs.ffinefe >= pfcalcul)
                )
            AND gf.cramo = s.cramo
            AND s.cmodali = gf.cmodali
            AND s.ctipseg = gf.ctipseg
            AND s.ccolect = gf.ccolect
            AND gf.cactivi = 0
            AND gs.cgarant = gf.cgarant
            AND gf.ccampo = cd.ccampo
            AND cd.ccampo = 'IPROVMAT'
            AND cd.cutili = 8
            AND (s.fvencim > pfcalcul OR s.fvencim IS NULL)
            AND f_situacion_v (s.sseguro, pfcalcul) = 1
            AND s.fefecto < pfcalcul + 1
            AND NOT EXISTS (
                   SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro,
                          pac_seguros.ff_get_actividad (s.sseguro,
                                                        gs.nriesgo
                                                       ) cactivi,
                          s.cforpag, s.fvencim, s.sproduc, gs.cgarant,
                          gs.icaptot, gs.nriesgo, s.fanulac, gf.clave,
                          gf.ccampo, gs.ftarifa
                     FROM seguros s, garanseg gs, garanformula gf,
                          codcampo cd
                    WHERE s.sseguro = psseguro
                      AND s.sseguro = gs.sseguro
                      AND (    (gs.finiefe <= pfcalcul)
                           AND (gs.ffinefe IS NULL OR gs.ffinefe >= pfcalcul
                               )
                          )
                      AND gf.cramo = s.cramo
                      AND s.cmodali = gf.cmodali
                      AND s.ctipseg = gf.ctipseg
                      AND s.ccolect = gf.ccolect
                      AND pac_seguros.ff_get_actividad (s.sseguro, gs.nriesgo) =
                                                                    gf.cactivi
                      AND gs.cgarant = gf.cgarant
                      AND gf.ccampo = cd.ccampo
                      AND cd.ccampo = 'IPROVMAT'
                      AND cd.cutili = 8
                      AND (s.fvencim > pfcalcul OR s.fvencim IS NULL)
                      AND f_situacion_v (s.sseguro, pfcalcul) = 1
                      AND s.fefecto < pfcalcul + 1);

      -- Bug 9699 - APD - 27/04/2009 - Fin
      -- Bug 9685 - APD - 27/04/2009 - Fin
      --
      xprovmat       NUMBER;
      num_err        NUMBER;
      valor          NUMBER;
      xprovmat_tot   NUMBER;
      s              VARCHAR2 (500);
   --
   BEGIN
      --
      FOR pol IN c_pol
      LOOP                                               -- Cursor de Pólizas
         -- s := 'begin  :num_err := pac_provmat_formul.calc_provmat(:pfcalcul, :psproduc, :pcactivi,'||
         --    ':pcgarant, :pnriesgo, :psseguro, :pclave, :pvalor); end;';
         --EXECUTE IMMEDIATE s USING out num_err, in pfcalcul, in pol.sproduc, in pol.cactivi,
         --                        in pol.cgarant, in pol.nriesgo, in psseguro, in pol.clave,
         --               out valor;
         num_err :=
            pac_calculo_formulas.calc_formul (pfcalcul,
                                              pol.sproduc,
                                              pol.cactivi,
                                              pol.cgarant,
                                              pol.nriesgo,
                                              pol.sseguro,
                                              pol.clave,
                                              valor,
                                              NULL,
                                              NULL,
                                              2,
                                              pol.ftarifa,
                                              pmodo
                                             );

         IF num_err = 0
         THEN
            xprovmat := valor;
         ELSE
            p_tab_error
                       (f_sysdate,
                        f_user,
                        'CALCULO PROV. MAT. PÓLIZA',
                        NULL,
                           'error al calcular la prov. matemática SSEGURO ='
                        || pol.sseguro
                        || ' CGARANT ='
                        || pol.cgarant
                        || ' PFECHA='
                        || pfcalcul,
                        'num_err =' || num_err
                       );
            RETURN NULL;
         END IF;

         xprovmat_tot := NVL (xprovmat_tot, 0) + xprovmat;
      END LOOP;

      RETURN xprovmat_tot;
   --
   END f_calcul_pm_seguro;

-------------------------------------------------------------------------------
   FUNCTION f_ins_garansegprovmat (psseguro IN NUMBER)
      RETURN NUMBER
   IS
       /*******************************************************************************************
       6/7/2004 YIL. Calcula la provisión matemática de cada garantía en la fecha
         t0 (alta o renovación) y t1 (año siguiente).
         Nos basaremos en estos datos para calcular la provisión matemática cada mes, la participación
         en beneficios y la prima de renovación
      ********************************************************************************************/-- Cursor de garantías-fórmulas
      -- Bug 9699 - APD - 27/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
      -- Bug 9685 - APD - 27/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
      CURSOR c_gar
      IS
         SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro,
                pac_seguros.ff_get_actividad (s.sseguro, gs.nriesgo) cactivi,
                s.sproduc, gs.cgarant, gs.nriesgo, gs.nmovimi, gs.finiefe,
                gs.nmovima, gf.clave, gf.ccampo, s.fcaranu, m.cmovseg,
                s.fefecto fefepol, m.fefecto,
                (SELECT fefecto
                   FROM movseguro mmm
                  WHERE sseguro = psseguro AND gs.nmovima = mmm.nmovimi)
                                                                       falta
           FROM seguros s,
                garanseg gs,
                garanformula gf,
                codcampo cd,
                movseguro m
          WHERE s.sseguro = psseguro
            AND s.sseguro = gs.sseguro
            AND m.sseguro = s.sseguro
            AND m.nmovimi = (SELECT MAX (mm.nmovimi)
                               FROM movseguro mm
                              WHERE mm.sseguro = psseguro)
            AND m.nmovimi = gs.nmovimi
            --  AND gs.ffinefe IS NULL
            AND gf.cramo = s.cramo
            AND s.cmodali = gf.cmodali
            AND s.ctipseg = gf.ctipseg
            AND s.ccolect = gf.ccolect
            AND pac_seguros.ff_get_actividad (s.sseguro, gs.nriesgo) =
                                                                    gf.cactivi
            AND gs.cgarant = gf.cgarant
            AND gf.ccampo = cd.ccampo
            AND cd.ccampo = 'IPROVT0'
            AND cd.cutili = 8
         UNION
         SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro,
                pac_seguros.ff_get_actividad (s.sseguro, gs.nriesgo) cactivi,
                s.sproduc, gs.cgarant, gs.nriesgo, gs.nmovimi, gs.finiefe,
                gs.nmovima, gf.clave, gf.ccampo, s.fcaranu, m.cmovseg,
                s.fefecto fefepol, m.fefecto,
                (SELECT fefecto
                   FROM movseguro mmm
                  WHERE sseguro = psseguro AND gs.nmovima = mmm.nmovimi)
                                                                        falta
           FROM seguros s,
                garanseg gs,
                garanformula gf,
                codcampo cd,
                movseguro m
          WHERE s.sseguro = psseguro
            AND s.sseguro = gs.sseguro
            AND m.sseguro = s.sseguro
            AND m.nmovimi = (SELECT MAX (mm.nmovimi)
                               FROM movseguro mm
                              WHERE mm.sseguro = psseguro)
            AND m.nmovimi = gs.nmovimi
            --  AND gs.ffinefe IS NULL
            AND gf.cramo = s.cramo
            AND s.cmodali = gf.cmodali
            AND s.ctipseg = gf.ctipseg
            AND s.ccolect = gf.ccolect
            AND gf.cactivi = 0
            AND gs.cgarant = gf.cgarant
            AND gf.ccampo = cd.ccampo
            AND cd.ccampo = 'IPROVT0'
            AND cd.cutili = 8
            AND NOT EXISTS (
                   SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro,
                          pac_seguros.ff_get_actividad (s.sseguro,
                                                        gs.nriesgo
                                                       ) cactivi,
                          s.sproduc, gs.cgarant, gs.nriesgo, gs.nmovimi,
                          gs.finiefe, gs.nmovima, gf.clave, gf.ccampo,
                          s.fcaranu, m.cmovseg, s.fefecto fefepol, m.fefecto,
                          (SELECT fefecto
                             FROM movseguro mmm
                            WHERE sseguro = psseguro
                              AND gs.nmovima = mmm.nmovimi) falta
                     FROM seguros s,
                          garanseg gs,
                          garanformula gf,
                          codcampo cd,
                          movseguro m
                    WHERE s.sseguro = psseguro
                      AND s.sseguro = gs.sseguro
                      AND m.sseguro = s.sseguro
                      AND m.nmovimi = (SELECT MAX (mm.nmovimi)
                                         FROM movseguro mm
                                        WHERE mm.sseguro = psseguro)
                      AND m.nmovimi = gs.nmovimi
                      --  AND gs.ffinefe IS NULL
                      AND gf.cramo = s.cramo
                      AND s.cmodali = gf.cmodali
                      AND s.ctipseg = gf.ctipseg
                      AND s.ccolect = gf.ccolect
                      AND pac_seguros.ff_get_actividad (s.sseguro, gs.nriesgo) =
                                                                    gf.cactivi
                      AND gs.cgarant = gf.cgarant
                      AND gf.ccampo = cd.ccampo
                      AND cd.ccampo = 'IPROVT0'
                      AND cd.cutili = 8);

      -- Bug 9699 - APD - 27/04/2009 - Fin
      -- Bug 9685 - APD - 27/04/2009 - Fin

      --and gf.cgarant = 1
      v_fprovt0   DATE;
      v_fprovt1   DATE;
      v_cmovseg   NUMBER;
      clav        NUMBER;
      num_err     NUMBER;
      valor       NUMBER;
      xprovt0     NUMBER;
      xprovt1     NUMBER;
      v_anyo      NUMBER;
   BEGIN
      FOR gar IN c_gar
      LOOP
         --  v_anyo := TRUNC (MONTHS_BETWEEN (gar.fefecto, gar.fefepol) / 12) + 1;
         SELECT MAX (nanyo)
           INTO v_anyo
           FROM garansegprovmat
          WHERE sseguro = psseguro;

         --  AND nriesgo = gar.nriesgo;
         v_fprovt0 := NULL;
         v_fprovt1 := NULL;

         -- v_anyo := null;
         IF gar.nmovima = gar.nmovimi
         THEN                                              -- ALTA DE GARANTIA
            v_fprovt0 := gar.falta;
            v_fprovt1 := gar.fcaranu;

            -- v_anyo := 1;
            IF gar.nmovimi = 1
            THEN
               v_anyo :=
                     TRUNC (MONTHS_BETWEEN (gar.fefecto, gar.fefepol) / 12)
                     + 1;
            END IF;
         ELSIF gar.cmovseg = 2
         THEN                                                       -- CARTERA
            v_fprovt0 := gar.finiefe;
            v_fprovt1 := gar.fcaranu;

            SELECT MAX (nanyo)
              INTO v_anyo
              FROM garansegprovmat
             WHERE sseguro = psseguro
               AND nriesgo = gar.nriesgo
               AND cgarant = gar.cgarant;

            v_anyo := v_anyo + 1;
         ELSE
            -- buscamos la última FPROVT0
            SELECT MAX (fprovt0), MAX (fprovt1), MAX (nanyo)
              INTO v_fprovt0, v_fprovt1, v_anyo
              FROM garansegprovmat
             WHERE sseguro = psseguro
               AND nriesgo = gar.nriesgo
               AND cgarant = gar.cgarant
               AND nmovima = gar.nmovima;

            IF v_fprovt0 IS NULL
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'f_ins_garansegprovmat',
                            NULL,
                               'v_fprovt0 is null ='
                            || psseguro
                            || ' CGARANT ='
                            || gar.cgarant
                            || ' PFECHA='
                            || gar.finiefe,
                            NULL
                           );
               RETURN 104349;
            END IF;
         END IF;

         -- Calculamos la provisión en T0
         num_err :=
            pac_calculo_formulas.calc_formul (gar.finiefe,
                                              gar.sproduc,
                                              gar.cactivi,
                                              gar.cgarant,
                                              gar.nriesgo,
                                              psseguro,
                                              gar.clave,
                                              valor
                                             );

         IF num_err = 0
         THEN
            xprovt0 := valor;
         ELSE
            p_tab_error
               (f_sysdate,
                f_user,
                'f_ins_garansegprovmat',
                NULL,
                   'error al calcular la prov. matemática IPROVT0 SSEGURO ='
                || psseguro
                || ' CGARANT ='
                || gar.cgarant
                || ' nriesgo ='
                || gar.nriesgo
                || ' PFECHA='
                || gar.finiefe,
                'num_err =' || num_err
               );
            RETURN 108422;
         END IF;

         num_err :=
            pac_tarifas.f_clave (gar.cgarant,
                                 gar.cramo,
                                 gar.cmodali,
                                 gar.ctipseg,
                                 gar.ccolect,
                                 gar.cactivi,
                                 'IPROVT1',
                                 clav
                                );

         IF num_err <> 0
         THEN
            RETURN 108422;                  --'Error en selección del código'
         END IF;

         num_err :=
            pac_calculo_formulas.calc_formul (gar.finiefe,
                                              gar.sproduc,
                                              gar.cactivi,
                                              gar.cgarant,
                                              gar.nriesgo,
                                              psseguro,
                                              clav,
                                              valor
                                             );

         IF num_err = 0
         THEN
            xprovt1 := valor;
         ELSE
            p_tab_error
               (f_sysdate,
                f_user,
                'F_INS_GARANSEGPROVMAT',
                NULL,
                   'error al calcular la prov. matemática IPROVT1 SSEGURO ='
                || psseguro
                || ' CGARANT ='
                || gar.cgarant
                || ' nriesgo ='
                || gar.nriesgo
                || ' PFECHA='
                || gar.finiefe,
                'num_err =' || num_err
               );
            RETURN 108422;
         END IF;

         -- Insertamos en la tabla GARANSEGPROVMAT
         BEGIN
            INSERT INTO garansegprovmat
                        (sseguro, nriesgo, cgarant, nmovimi,
                         finiefe, nmovima, nanyo, fprovt0,
                         iprovt0, fprovt1, iprovt1
                        )
                 VALUES (psseguro, gar.nriesgo, gar.cgarant, gar.nmovimi,
                         gar.finiefe, gar.nmovima, v_anyo, v_fprovt0,
                         xprovt0, v_fprovt1, xprovt1
                        );
         EXCEPTION
            WHEN OTHERS
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'insert garanprovmat',
                            NULL,
                               'error al insertar SSEGURO ='
                            || psseguro
                            || ' CGARANT ='
                            || gar.cgarant
                            || ' pnriesgo ='
                            || gar.nriesgo
                            || ' pnmovimi ='
                            || gar.nmovimi
                            || ' PFECHA='
                            || gar.finiefe,
                            SQLERRM
                           );
               RETURN 108422;
         END;
      END LOOP;

      RETURN 0;
   END f_ins_garansegprovmat;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
   FUNCTION ff_evolu (
      porigen      IN   NUMBER,
      pvalor       IN   NUMBER,
      psseguro     IN   NUMBER,
      pnmovimi     IN   NUMBER,
      pnanyo       IN   NUMBER,
      pnscenario   IN   NUMBER DEFAULT 1
   )
      RETURN NUMBER
   IS
      /**************************************************************************************************************************************
         Función que evuelve el valor solicitado de la tabla EVOLUPROVMATSEG
           pvalor : 1 -- capital garantizado o provisión matematica
                           2 -- capital de fallecimiento
                       3 -- porcentaje de rescate
                       4 -- porcentaje de interés
                       5 -- capital garantizado estimado
                       6 -- fecha ejercicio

         porigen: 0 -- 'SOL'
                          1 -- 'EST
                      2 -- 'SEG'

       ***********************************************************************************************************************************/
      salida   NUMBER;
   BEGIN
      IF porigen = 0
      THEN
         SELECT DECODE (pvalor,
                        1, iprovmat,
                        2, icapfall,
                        3, prescate,
                        4, pinttec,
                        5, iprovest,
                        6, TO_CHAR (fprovmat, 'yyyymmdd')
                       )
           INTO salida
           FROM solevoluprovmatseg
          WHERE ssolicit = psseguro AND nmovimi = pnmovimi AND nanyo = pnanyo;
      ELSIF porigen = 1
      THEN
         SELECT DECODE (pvalor,
                        1, iprovmat,
                        2, icapfall,
                        3, prescate,
                        4, pinttec,
                        5, iprovest,
                        6, TO_CHAR (fprovmat, 'yyyymmdd')
                       )
           INTO salida
           FROM estevoluprovmatseg
          WHERE sseguro = psseguro
            AND nmovimi =
                   (SELECT MAX (nmovimi)
                      FROM estevoluprovmatseg
                     WHERE sseguro = psseguro
                       AND nmovimi <= pnmovimi
                       AND nanyo = pnanyo)
            AND nanyo = pnanyo
            AND nscenario = pnscenario;
      ELSIF porigen = 2
      THEN
         SELECT DECODE (pvalor,
                        1, iprovmat,
                        2, icapfall,
                        3, prescate,
                        4, pinttec,
                        5, iprovest,
                        6, TO_CHAR (fprovmat, 'yyyymmdd')
                       )
           INTO salida
           FROM evoluprovmatseg
          WHERE sseguro = psseguro
            AND nmovimi =
                   (SELECT MAX (nmovimi)
                      FROM evoluprovmatseg
                     WHERE sseguro = psseguro
                       AND nmovimi <= pnmovimi
                       AND nanyo = pnanyo)
            AND nanyo = pnanyo
            AND nscenario = pnscenario;
      END IF;

      RETURN salida;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_provmat_formul.ff_evoluprovmatseg',
                      NULL,
                         'parametros: psseguro ='
                      || psseguro
                      || 'pnmovimi ='
                      || pnmovimi
                      || ' porigen ='
                      || porigen
                      || ' pnanyo ='

                      || pnanyo
                      || ' pnscenario = '
                      || pnscenario,
                      SQLERRM
                     );
         RETURN 1;
   END ff_evolu;

   -- Bug 10690 - RSC - 22/12/2009 - APR - Provisiones en productos de cartera (PORTFOLIO)
   -- Añadimos pcgarant y pndetgar
    -- Ini Bug 24704 --ECP-- 26/04/2013
   FUNCTION f_calcul_formulas_provi (
      psseguro   IN   NUMBER,
      pfecha     IN   DATE,
      pcampo     IN   VARCHAR2,
      pcgarant   IN   NUMBER DEFAULT NULL,
      pndetgar   IN   NUMBER DEFAULT NULL,
      psituac    IN   NUMBER DEFAULT 1,
      psesion    IN   NUMBER DEFAULT NULL,
      pnmovimi   IN   NUMBER DEFAULT NULL,          -- BUG31548:DRA:23/09/2014
      pnrecibo   IN   NUMBER DEFAULT NULL,          -- BUG31548:DRA:23/09/2014
      pnsinies   IN   NUMBER DEFAULT NULL
   )                                                -- BUG31548:DRA:23/09/2014
      RETURN NUMBER
   IS
      -- Fin Bug 24704 --ECP-- 26/04/2013
          /*******************************************************************************************
         21/3/2007 APD. Función que mira qué fórmula se tiene que ejecutar dependiendo del parámetro
         de GARANFORMULA (valor del parámetro pcampo). Una vez tiene esta fórmula (clave), la ejecuta
         a través de la función PAC_CALCULO_FORMULAS.CALC_FORMUL y el resultado de este cálculo es lo
         que devuelve la función. Si la póliza no está vigente (está anulada) la función devuelve 0.
         Si no se encuentra ninguna fórmula asociada la función devuelve null.
        ********************************************************************************************/
      capgar      NUMBER;
      resultat    NUMBER := 0;
      v_ftarifa   DATE;
      v_clave     NUMBER;
      v_sproduc   NUMBER;
      v_cactivi   NUMBER;
      v_cgarant   NUMBER;
      num_err     NUMBER;

      CURSOR cur_garanprovi
      IS
         SELECT DISTINCT cgarant
                    FROM garanseg g, seguros s
                   WHERE g.sseguro = s.sseguro
                     AND f_pargaranpro_v
                                    (s.cramo,
                                     s.cmodali,
                                     s.ctipseg,
                                     s.ccolect,
                                     pac_seguros.ff_get_actividad (s.sseguro,
                                                                   g.nriesgo
                                                                  ),
                                     -- BUG17591:DRA:09/02/2011
                                     g.cgarant,
                                     'CALCULA_PROVI'
                                    ) = 1
                     AND s.sseguro = psseguro
                     AND g.cgarant = NVL (pcgarant, g.cgarant)
-- Bug 10690 - RSC - 22/12/2009 - APR - Provisiones en productos de cartera (PORTFOLIO)
                     AND g.finiefe <= pfecha
                     AND (g.ffinefe IS NULL OR g.ffinefe > pfecha);

-- Bug 13463 - RSC - 02/03/2010 - CRE - La baja de garantía 'Muerte / Invalidez'
--             provoca que deje de calcularse la provisión (PPJ / PLA Estudiant)
      v_entra     NUMBER := 0;
   BEGIN
      -- Bug 20309 - RSC - 28/02/2012 - LCOL_T004-Parametrización Fondos
      IF psituac = 1
      THEN
         -- Fin bug 20309

         -- Si la póliza está anulada en esta fecha la provisión = 0
         -- Miramos si está anulada a esta fecha
         IF f_situacion_v (psseguro, pfecha) = 2
         THEN
            RETURN 0;
         -- Mantis 12275.NMM.14/12/2009.Comentem l'elsif
         /*ELSIF f_situacion_v(psseguro, pfecha - 1) = 3 THEN   --si la fecha es el mismo día del vencimiento sí queremos que calcule
            RETURN 0;*/
         END IF;
      -- Bug 20309 - RSC - 28/02/2012 - LCOL_T004-Parametrización Fondos
      END IF;

      -- Fin bug 20309

      -- CPM 20/10/06: Se añade la llamada a las formulas del GFI
      -- RSC 06/11/2007: Se añade el tratamiento por garantia de seguro
      -- Para las pólizas <> Ibex 35 Garantizado no cambia nada ya que solo tendrán una garantia que calcule
      -- provisión. Para Ibex 35 Garantizado tendremos dos garantias que calculan provisión y por tanto
      -- tendremos dos iteraciones aquí.
      FOR regs IN cur_garanprovi
      LOOP
         v_entra := 1;

         -- Buscamos los datos del seguro para PFECHA
         BEGIN
            -- Bug 9685 - APD - 27/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
            SELECT gf.clave, ss.sproduc,
                   pac_seguros.ff_get_actividad (ss.sseguro, g.nriesgo),
                   g.ftarifa, g.cgarant
              INTO v_clave, v_sproduc,
                   v_cactivi,
                   v_ftarifa, v_cgarant
              FROM garanformula gf, garanseg g, historicoseguros s,
                   seguros ss
             WHERE gf.cgarant = g.cgarant
               AND gf.cramo = ss.cramo
               AND gf.cmodali = ss.cmodali
               AND gf.ctipseg = ss.ctipseg
               AND gf.ccolect = ss.ccolect
               AND g.cgarant = regs.cgarant
               AND gf.ccampo = pcampo
               AND gf.cactivi =
                          pac_seguros.ff_get_actividad (ss.sseguro, g.nriesgo)
               AND g.finiefe <= pfecha
               AND (g.ffinefe IS NULL OR g.ffinefe > pfecha)
               AND g.sseguro = s.sseguro
               --AND F_Pargaranpro_V(ss.cramo, ss.cmodali, ss.ctipseg, ss.ccolect,pac_seguros.ff_get_actividad(ss.sseguro, g.nriesgo),g.cgarant, 'TIPO') = 5 -- Capital garantizado
               AND f_pargaranpro_v (ss.cramo,
                                    ss.cmodali,
                                    ss.ctipseg,
                                    ss.ccolect,
                                    pac_seguros.ff_get_actividad (ss.sseguro,
                                                                  g.nriesgo
                                                                 ),
                                    -- BUG17591:DRA:09/02/2011
                                    g.cgarant,
                                    'CALCULA_PROVI'
                                   ) = 1
               AND s.sseguro = ss.sseguro
               AND ss.sseguro = psseguro
               AND s.nmovimi =
                      (SELECT MAX (nmovimi)
                         FROM movseguro
                        WHERE sseguro = psseguro
                          AND fefecto <= pfecha
                          AND femisio < pfecha + 1);
         -- Bug 9685 - APD - 27/04/2009 - Fin
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  -- Bug 9699 - APD - 27/04/2009 - primero se ha de buscar para la actividad en concreto
                  -- y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
                  SELECT gf.clave, ss.sproduc,
                         pac_seguros.ff_get_actividad (ss.sseguro, g.nriesgo),
                         g.ftarifa, g.cgarant
                    INTO v_clave, v_sproduc,
                         v_cactivi,
                         v_ftarifa, v_cgarant
                    FROM garanformula gf,
                         garanseg g,
                         historicoseguros s,
                         seguros ss
                   WHERE gf.cgarant = g.cgarant
                     AND gf.cramo = ss.cramo
                     AND gf.cmodali = ss.cmodali
                     AND gf.ctipseg = ss.ctipseg
                     AND gf.ccolect = ss.ccolect
                     AND g.cgarant = regs.cgarant
                     AND gf.ccampo = pcampo
                     AND gf.cactivi = 0
                     AND g.finiefe <= pfecha
                     AND (g.ffinefe IS NULL OR g.ffinefe > pfecha)
                     AND g.sseguro = s.sseguro
                     --AND F_Pargaranpro_V(ss.cramo, ss.cmodali, ss.ctipseg, ss.ccolect,0,g.cgarant, 'TIPO') = 5 -- Capital garantizado
                     AND f_pargaranpro_v (ss.cramo,
                                          ss.cmodali,
                                          ss.ctipseg,
                                          ss.ccolect,
                                          0,
                                          g.cgarant,
                                          'CALCULA_PROVI'
                                         ) = 1
                     AND s.sseguro = ss.sseguro
                     AND ss.sseguro = psseguro
                     AND s.nmovimi =
                            (SELECT MAX (nmovimi)
                               FROM movseguro
                              WHERE sseguro = psseguro
                                AND fefecto <= pfecha
                                AND femisio < pfecha + 1);
               -- Bug 9699 - APD - 27/04/2009 - Fin
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     BEGIN
                        -- Bug 9685 - APD - 27/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
                        SELECT gf.clave, s.sproduc,
                               pac_seguros.ff_get_actividad (s.sseguro,
                                                             g.nriesgo
                                                            ),
                               g.ftarifa, g.cgarant
                          INTO v_clave, v_sproduc,
                               v_cactivi,
                               v_ftarifa, v_cgarant
                          FROM garanformula gf, garanseg g, seguros s
                         WHERE gf.cgarant = g.cgarant
                           AND gf.cramo = s.cramo
                           AND gf.cmodali = s.cmodali
                           AND gf.ctipseg = s.ctipseg
                           AND gf.ccolect = s.ccolect
                           AND g.cgarant = regs.cgarant
                           AND gf.ccampo = pcampo
                           AND gf.cactivi =
                                  pac_seguros.ff_get_actividad (s.sseguro,
                                                                g.nriesgo
                                                               )
                           AND g.finiefe <= pfecha
                           AND (g.ffinefe IS NULL OR g.ffinefe > pfecha)
                           AND g.sseguro = s.sseguro
                           --AND F_Pargaranpro_V(s.cramo, s.cmodali, s.ctipseg, s.ccolect,pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo),g.cgarant, 'TIPO') = 5 -- Capital garantizado
                           AND f_pargaranpro_v
                                    (s.cramo,
                                     s.cmodali,
                                     s.ctipseg,
                                     s.ccolect,
                                     pac_seguros.ff_get_actividad (s.sseguro,
                                                                   g.nriesgo
                                                                  ),
                                     -- BUG17591:DRA:09/02/2011
                                     g.cgarant,
                                     'CALCULA_PROVI'
                                    ) = 1
                           AND s.sseguro = psseguro;
                     -- Bug 9685 - APD - 27/04/2009 - Fin
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           -- Bug 9699 - APD - 27/04/2009 - primero se ha de buscar para la actividad en concreto
                           -- y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
                           SELECT gf.clave, s.sproduc,
                                  pac_seguros.ff_get_actividad (s.sseguro,
                                                                g.nriesgo
                                                               ),
                                  g.ftarifa, g.cgarant
                             INTO v_clave, v_sproduc,
                                  v_cactivi,
                                  v_ftarifa, v_cgarant
                             FROM garanformula gf, garanseg g, seguros s
                            WHERE gf.cgarant = g.cgarant
                              AND gf.cramo = s.cramo
                              AND gf.cmodali = s.cmodali
                              AND gf.ctipseg = s.ctipseg
                              AND gf.ccolect = s.ccolect
                              AND g.cgarant = regs.cgarant
                              AND gf.ccampo = pcampo
                              AND gf.cactivi = 0
                              AND g.finiefe <= pfecha
                              AND (g.ffinefe IS NULL OR g.ffinefe > pfecha)
                              AND g.sseguro = s.sseguro
                              --AND F_Pargaranpro_V(s.cramo, s.cmodali, s.ctipseg, s.ccolect,0,g.cgarant, 'TIPO') = 5 -- Capital garantizado
                              AND f_pargaranpro_v (s.cramo,
                                                   s.cmodali,
                                                   s.ctipseg,
                                                   s.ccolect,
                                                   0,
                                                   g.cgarant,
                                                   'CALCULA_PROVI'
                                                  ) = 1
                              AND s.sseguro = psseguro;
                     -- Bug 9699 - APD - 27/04/2009 - Fin
                     END;
               END;
         END;

         -- Bug 10690 - RSC - 22/12/2009 - 0010690: APR - Provisiones en productos de cartera (PORTFOLIO)
         IF NVL (f_parproductos_v (v_sproduc, 'DETALLE_GARANT'), 0) IN (1, 2)
         THEN
            -- Ini Bug 24704 --ECP-- 26/04/2013
            /*num_err := pac_calculo_formulas.calc_formul(pfecha, v_sproduc, v_cactivi,
                                                       v_cgarant, 1, psseguro, v_clave,
                                                       capgar, NULL, NULL, 2, v_ftarifa, 'R',
                                                       pndetgar);*/
            num_err :=
               pac_calculo_formulas.calc_formul (pfecha,
                                                 v_sproduc,
                                                 v_cactivi,
                                                 v_cgarant,
                                                 1,
                                                 psseguro,
                                                 v_clave,
                                                 capgar,
                                                 pnmovimi,
                                                 psesion,
                                                 2,
                                                 v_ftarifa,
                                                 'R',
                                                 pndetgar,
                                                 1,
                                                 NULL,
                                                 pnrecibo,
                                                 pnsinies
                                                );
            -- Fin Bug 24704 --ECP-- 26/04/2013
            resultat := resultat + capgar;
         ELSE
            -- Bug 10690
            -- Ini Bug 24704 --ECP-- 26/04/2013
             /*num_err := pac_calculo_formulas.calc_formul(pfecha, v_sproduc, v_cactivi,
                                                        v_cgarant, 1, psseguro, v_clave,
                                                        capgar, NULL, NULL, 2, v_ftarifa, 'R');*/
            num_err :=
               pac_calculo_formulas.calc_formul (pfecha,
                                                 v_sproduc,
                                                 v_cactivi,
                                                 v_cgarant,
                                                 1,
                                                 psseguro,
                                                 v_clave,
                                                 capgar,
                                                 pnmovimi,
                                                 psesion,
                                                 2,
                                                 v_ftarifa,
                                                 'R',
                                                 NULL,
                                                 1,
                                                 NULL,
                                                 pnrecibo,
                                                 pnsinies
                                                );
            -- Fin Bug 24704 --ECP-- 26/04/2013
            resultat := resultat + capgar;
         -- Bug 10690 - RSC - 22/12/2009 - 0010690: APR - Provisiones en productos de cartera (PORTFOLIO)
         END IF;
      -- Fin Bug 10690
      END LOOP;

      IF v_entra = 0
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_provmat_formul.f_calcul_formulas_provi',
                      NULL,
                         'pfecha ='
                      || pfecha
                      || ' sseguro='
                      || psseguro
                      || ' campo='
                      || pcampo
                      || ' pndetgar='
                      || pndetgar
                      || ' psituac='
                      || psituac
                      || ' psesion='
                      || psesion
                      || ' pnmovimi='
                      || pnmovimi
                      || ' pnrecibo='
                      || pnrecibo
                      || ' pnsinies='
                      || pnsinies,
                      'no encuentra formula asignada al campo'
                     );
         num_err := 100825;                -- No hi ha cap garantia introduida
         RETURN NULL;
      ELSE
         RETURN resultat;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_provmat_formul.f_calcul_formulas_provi',
                      NULL,
                         'pfecha ='
                      || pfecha
                      || ' sseguro='
                      || psseguro
                      || ' campo='
                      || pcampo
                      || ' pndetgar='
                      || pndetgar
                      || ' psituac='
                      || psituac
                      || ' psesion='
                      || psesion
                      || ' pnmovimi='
                      || pnmovimi
                      || ' pnrecibo='
                      || pnrecibo
                      || ' pnsinies='
                      || pnsinies,
                      SQLERRM
                     );
         -- Protegim l'error de final de canal de comunicació o altres
         num_err := 100825;                -- No hi ha cap garantia introduida
         RETURN NULL;
   END f_calcul_formulas_provi;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
END pac_provmat_formul;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROVMAT_FORMUL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROVMAT_FORMUL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROVMAT_FORMUL" TO "PROGRAMADORESCSI";
