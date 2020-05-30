--------------------------------------------------------
--  DDL for Package Body PAC_PROVIMAT_PBEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROVIMAT_PBEX" IS
/******************************************************************************
   NOMBRE:     pac_provimat_pbex
   PROPÓSITO:  Agrupa las funciones que calculan las provisiones matématicas y las
               provisiones pbex

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        XX/XX/XXXX   XXX                1. Creación del package.
   2.0        27/04/2009   APD                2. Bug 9685 - primero se ha de buscar para la actividad en concreto
                                                 y si no se encuentra nada ir a buscar a PREGUNPROGARAN para la actividad cero
                                                 También en lugar de coger la actividad de la tabla seguros, llamar a la función
                                                 pac_seguros.ff_get_actividad
   3.0        15/09/2010   JRH                3. 0012278: Proceso de PB para el producto PEA.
   4.0        22/11/2010   JRH                4. 0012278: Proceso de PB para el producto PEA.
   5.0        04/04/2014   JTT                5. 0029943: Proceso de PUs, nueva funcion f_procesar_pu
   6.0        29/04/2014   JTT                6. 0029943: Proceso de PUs
   7.0        19/05/2014   JTT                7. 0029943: Añadimos el nuevo tipo de PB 6 - Fondo de ahorro
   8.0        06/06/2014   JTT                8. 0029943: Proceso de PBs (TIPO_PB = 4)
******************************************************************************/

   -- BUG 12278 -  09/2010 - JRH  - 0012278: Proceso de PB para el producto PEA.

   /************************************************************************
      f_commit_pbex
         Proceso de inserción de la PB en PBEX/PBEX_PREVIO (Participación de Beneficios)

       Parámetros Entrada:

           pcidioma: Idioma
           pfcalcul : Fecha Cálculo
           psproces: Proceso
           pcidioma: Idioma
           pcmoneda: Divisa/Moneda
           pmodo: Modo ('P'revio y 'R'eal)

       retorna 0 si ha ido todo bien o código de error en caso contrario
   *************************************************************************/
   FUNCTION f_commit_pbex(
      pcempres IN NUMBER,
      pfcalcul IN DATE,
      psproces IN NUMBER,
      pcidioma IN NUMBER,
      pcmoneda IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER IS
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
      CURSOR c_pol IS
         SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sseguro,
                pac_seguros.ff_get_actividad(s.sseguro, gs.nriesgo) cactivi, s.cforpag,
                s.fvencim, gs.cgarant, gs.icaptot, gs.nriesgo, p.sproduc, p.cramdgs,
                s.fanulac, 99 cprovis,   --pr.cprovis,
                                      gs.ipritot, gs.ftarifa, s.npoliza, s.fefecto
           FROM productos p, codiram r, seguros s, garanseg gs
          WHERE r.cempres = pcempres
            AND p.cramo = r.cramo
            AND p.sproduc = s.sproduc
            AND(s.fvencim > pfcalcul
                OR s.fvencim IS NULL)
            AND f_situacion_v(s.sseguro, pfcalcul) = 1
            AND s.fefecto < pfcalcul + 1
            AND((gs.finiefe <= pfcalcul)
                AND(gs.ffinefe IS NULL
                    OR gs.ffinefe > pfcalcul))
            AND s.sseguro = gs.sseguro
            AND(
                -- 29943: Tipo de PB <> 5 y certificados <> 0
                ((NVL(f_parproductos_v(s.sproduc, 'TIPO_PB'), 0) <> 5)
                 AND((NVL(f_parproductos_v(s.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 0)
                     OR((NVL(f_parproductos_v(s.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1)
                        AND(ncertif <> 0))))   -- MMS (20130604) Admite Certificados
                -- 29943: Tipo de PB = 5 + certificado 0
                OR((NVL(f_parproductos_v(s.sproduc, 'TIPO_PB'), 0) = 5)
                   AND((NVL(f_parproductos_v(s.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 0)
                       OR((NVL(f_parproductos_v(s.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1)
                          AND(ncertif = 0)))))
            -- AND pac_motretencion.f_esta_retenica_sin_resc(s.sseguro, pfcalcul) = 0 BUG: 13047 10-02-2010 AVT
            AND EXISTS(SELECT gf.cgarant
                         FROM garanformula gf, codcampo cd
                        WHERE gf.cramo = s.cramo
                          AND s.cmodali = gf.cmodali
                          AND s.ctipseg = gf.ctipseg
                          AND s.ccolect = gf.ccolect
                          AND pac_seguros.ff_get_actividad(s.sseguro, gs.nriesgo) = gf.cactivi
                          AND gs.cgarant = gf.cgarant
                          AND gf.ccampo = cd.ccampo
                          AND cd.cutili = 8
                          AND cd.ccampo = 'IPBENAC'
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
                          AND cd.ccampo = 'IPBENAC'
                          AND NOT EXISTS(SELECT gf.cgarant
                                           FROM garanformula gf, codcampo cd
                                          WHERE gf.cramo = s.cramo
                                            AND s.cmodali = gf.cmodali
                                            AND s.ctipseg = gf.ctipseg
                                            AND s.ccolect = gf.ccolect
                                            AND pac_seguros.ff_get_actividad(s.sseguro,
                                                                             gs.nriesgo) =
                                                                                     gf.cactivi
                                            AND gs.cgarant = gf.cgarant
                                            AND gf.ccampo = cd.ccampo
                                            AND cd.cutili = 8
                                            AND cd.ccampo = 'IPBENAC'));   -- formulas de provisiones

      -- Bug 9685 - APD - 27/04/2009 - Fin
      -- Bug 9699 - APD - 27/04/2009 - Fin

      -- Cursor de formulas de provisiones
      CURSOR c_provis(
         pcgarant IN NUMBER,
         pcramo IN NUMBER,
         pcmodali IN NUMBER,
         pctipseg IN NUMBER,
         pccolect IN NUMBER,
         pcactivi IN NUMBER) IS
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
            AND cd.ccampo = 'IPBENAC'
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
            AND cd.ccampo = 'IPBENAC'
            AND NOT EXISTS(SELECT gf.clave, gf.ccampo
                             FROM garanformula gf, codcampo cd
                            WHERE gf.cgarant = pcgarant
                              AND gf.cramo = pcramo
                              AND gf.cmodali = pcmodali
                              AND gf.ctipseg = pctipseg
                              AND gf.ccolect = pccolect
                              AND gf.cactivi = pcactivi
                              AND cd.ccampo = gf.ccampo
                              AND cd.cutili = 8
                              AND cd.ccampo = 'IPBENAC');

         -- Bug 9699 - APD - 27/04/2009 - Fin
      --
      vpb            NUMBER;
      vnum_err       NUMBER := 0;
      vnlin          NUMBER;
      vcont_err      NUMBER;
      vttexto        VARCHAR2(400);
      valor          NUMBER;
      vorigen        NUMBER := 2;
      vcrespue       NUMBER;
      v_newpoliza    NUMBER;
      v_ctipopu      NUMBER;
   --
   BEGIN
      --
      vcont_err := 0;

      --
      FOR pol IN c_pol LOOP
         --DBMS_OUTPUT.put_line ('sseguro ************************************************************************=' || pol.sseguro);
         vpb := 0;

         FOR prov IN c_provis(pol.cgarant, pol.cramo, pol.cmodali, pol.ctipseg, pol.ccolect,
                              pol.cactivi) LOOP
            --DBMS_OUTPUT.put_line ('CALC_PORVMAT CAMPO =**********************************************************' || prov.ccampo);
            valor := 0;
--DBMS_OUTPUT.put_line(pfcalcul||','||pol.sproduc||','||
                     --pol.cactivi||','||pol.cgarant||','||
                     --pol.nriesgo||','||pol.sseguro||','||
                     --prov.clave||','||valor||','||NULL||','||NULL||','||xorigen||','||pol.ftarifa||','||pmodo);
            vnum_err := pac_calculo_formulas.calc_formul(pfcalcul, pol.sproduc, pol.cactivi,
                                                         pol.cgarant, pol.nriesgo,
                                                         pol.sseguro, prov.clave, valor, NULL,
                                                         NULL, vorigen, pol.ftarifa, pmodo);

            IF vnum_err = 0 THEN
               --DBMS_OUTPUT.put_line ('VALOR =********************************************************************************' || valor);
               vpb := valor;
            ELSE
               vnum_err := 151350;
              -- BUG 12278 -  11/2010 - JRH  - 0012278: No salir
            --EXIT;
              -- Fi BUG 12278 -  11/2010 - JRH
            END IF;
         END LOOP;

         --dbms_output.put_line(' xprovmat = '||xprovmat||' xcapfall='||xcapfall||' xcapgar='||xcapgar);
         IF vnum_err = 0 THEN
            -- Bug 29943 - 23/04/2014 - JTT: Recuperem el tipo de PU. Substituim la pregunta 9132 per el parametre TIPO_PU.
--            vnum_err := pac_preguntas.f_get_pregungaranseg(pol.sseguro, pol.cgarant,
--                                                           pol.nriesgo, 9132, 'SEG', vcrespue);
           -- v_ctipopu := NVL(f_parproductos_v(pol.sproduc, 'TIPO_PB'), 0);

            -- IF v_ctipopu = 0 THEN
            BEGIN
               IF pmodo = 'R' THEN
                  INSERT INTO pbex
                              (cempres, fcalcul, sproces, cramdgs, cramo,
                               cmodali, ctipseg, ccolect, sseguro,
                               cgarant, ivalact, icapgar, ipromat, cerror, nriesgo)
                       VALUES (pcempres, pfcalcul, psproces, pol.cramdgs, pol.cramo,
                               pol.cmodali, pol.ctipseg, pol.ccolect, pol.sseguro,
                               pol.cgarant, NVL(vpb, 0), 0, 0, 0, pol.nriesgo);
               ELSIF pmodo = 'P' THEN
                  INSERT INTO pbex_previo
                              (cempres, fcalcul, sproces, cramdgs, cramo,
                               cmodali, ctipseg, ccolect, sseguro,
                               cgarant, ivalact, icapgar, ipromat, cerror, nriesgo)
                       VALUES (pcempres, pfcalcul, psproces, pol.cramdgs, pol.cramo,
                               pol.cmodali, pol.ctipseg, pol.ccolect, pol.sseguro,
                               pol.cgarant, NVL(vpb, 0), 0, 0, 0, pol.nriesgo);
               END IF;

               COMMIT;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user,
                              'CIERRE PROVISIONES PBEX PROCESO =' || psproces, NULL,
                              'error al insertar en pbEX SSEGURO =' || pol.sseguro
                              || ' PFECHA=' || pfcalcul,
                              SQLERRM);
                  p_tab_error(f_sysdate, f_user, 'PROVISIONES_PB', 1, NULL,
                              'PREV.PROV' || pcempres || '-' || '-' || psproces || '-'
                              || pol.cramdgs || '-' || pol.cramo || '-' || pol.cmodali || '-'
                              || pol.ctipseg || '-' || pol.ccolect || '-' || pol.sseguro
                              || '-' || pol.cgarant || '-' || pol.cprovis || '-'
                              || pol.ipritot || '-' || NVL(vpb, 0) || '-' || NVL(0, 0) || '-'
                              || 0 || '-' || 0 || '-' || pol.nriesgo);
                  vnum_err := 107110;   -- Error al insertar en la tabla PORVMAT
            END;
--            ELSIF v_ctipopu = 1 THEN
--                                 /**
--                   - Si vale 1 si estamos en previo inserte en PBEXTPREVIO igual pero si es real llame a la función :
--                   pac_propio.f_alta_detalle_gar (seguro, fecha, importe) . Si va bien insertar en procesoslin que se ha generado
--                   el detalle de la póliza y en la agenda de la póliza tb. Si va mal insertar el error en procesoslin.

         --                   - Si vale 2 si estamos en previo   inserte en PBEXTPREVIO sino llamar a pac_propio.F_ALTA_POLIZA_PU
--                   (seguro, fecha, importe).Si va bien insertar en procesoslin que se ha generado la nueva póliza de la póliza
--                   y en la agenda de la póliza tb. Si va mal insertar el error en procesoslin.
--               **/
--               BEGIN
--                   --JTT se comenta lo añadido en la nueva función
--                  /*IF pmodo = 'R' THEN
--                     vnum_err := pac_propio.f_alta_detalle_gar(pol.sseguro, pol.fefecto,
--                                                               NVL(vpb, 0), pcempres);

         --                     IF vnum_err = 0 THEN
--                        vttexto := f_axis_literales(9906583, pcidioma);
--                        vnum_err := f_proceslin(psproces,
--                                                vttexto || ' - PBEX ' || pol.cprovis,
--                                                pol.sseguro, vnlin);
--                        vnum_err := pac_agensegu.f_set_datosapunte(pol.npoliza,
--                                                                   pol.sseguro, 1, vttexto,
--                                                                   vttexto, 6, 1,
--                                                                   f_sysdate, f_sysdate, 0,
--                                                                   1);
--                        COMMIT;
--                     ELSE
--                        vttexto := f_axis_literales(vnum_err, pcidioma);
--                        vnum_err := f_proceslin(psproces,
--                                                vttexto || ' - PBEX ' || pol.cprovis,
--                                                pol.sseguro, vnlin);
--                        COMMIT;
--                        vcont_err := vcont_err + 1;
--                        vnlin := NULL;
--                     END IF;
--                  ELS*/
--                  IF pmodo = 'P' THEN
--                     INSERT INTO pbex_previo
--                                 (cempres, fcalcul, sproces, cramdgs, cramo,
--                                  cmodali, ctipseg, ccolect, sseguro,
--                                  cgarant, ivalact, icapgar, ipromat, cerror, nriesgo)
--                          VALUES (pcempres, pfcalcul, psproces, pol.cramdgs, pol.cramo,
--                                  pol.cmodali, pol.ctipseg, pol.ccolect, pol.sseguro,
--                                  pol.cgarant, NVL(vpb, 0), 0, 0, 0, pol.nriesgo);
--                  END IF;

         --                  COMMIT;
--               EXCEPTION
--                  WHEN OTHERS THEN
--                     p_tab_error(f_sysdate, f_user,
--                                 'CIERRE PROVISIONES PBEX PROCESO =' || psproces, NULL,
--                                 'error al insertar en pbEX SSEGURO =' || pol.sseguro
--                                 || ' PFECHA=' || pfcalcul,
--                                 SQLERRM);
--                     p_tab_error(f_sysdate, f_user, 'PROVISIONES_PB', 2, NULL,
--                                 'PREV.PROV' || pcempres || '-' || '-' || psproces || '-'
--                                 || pol.cramdgs || '-' || pol.cramo || '-' || pol.cmodali
--                                 || '-' || pol.ctipseg || '-' || pol.ccolect || '-'
--                                 || pol.sseguro || '-' || pol.cgarant || '-' || pol.cprovis
--                                 || '-' || pol.ipritot || '-' || NVL(vpb, 0) || '-'
--                                 || NVL(0, 0) || '-' || 0 || '-' || 0 || '-' || pol.nriesgo);
--                     vnum_err := 107110;   -- Error al insertar en la tabla PORVMAT
--               END;
--            ELSIF v_ctipopu = 2 THEN
--                                 /**
--                   - Si vale 1 si estamos en previo inserte en PBEXTPREVIO igual pero si es real llame a la función :
--                   pac_propio.f_alta_detalle_gar (seguro, fecha, importe) . Si va bien insertar en procesoslin que se ha generado
--                   el detalle de la póliza y en la agenda de la póliza tb. Si va mal insertar el error en procesoslin.

         --                   - Si vale 2 si estamos en previo   inserte en PBEXTPREVIO sino llamar a pac_propio.F_ALTA_POLIZA_PU
--                   (seguro, fecha, importe).Si va bien insertar en procesoslin que se ha generado la nueva póliza de la póliza
--                   y en la agenda de la póliza tb. Si va mal insertar el error en procesoslin.
--               **/
--               BEGIN
--                  --JTT se comenta lo añadido en la nueva función
--                  /*IF pmodo = 'R' THEN
--                     vnum_err := pac_propio.f_alta_poliza_pu(pol.sseguro, pol.fefecto,
--                                                             NVL(vpb, 0), pcempres,
--                                                             v_newpoliza);

         --                     IF vnum_err = 0 THEN
--                        vttexto := f_axis_literales(9906584, pcidioma);
--                        vnum_err := f_proceslin(psproces,
--                                                vttexto || ' - PBEX ' || pol.cprovis,
--                                                pol.sseguro, vnlin);
--                        vnum_err := pac_agensegu.f_set_datosapunte(pol.npoliza,
--                                                                   pol.sseguro, 1, vttexto,
--                                                                   vttexto, 6, 1,
--                                                                   f_sysdate, f_sysdate, 0,
--                                                                   1);
--                        COMMIT;
--                     ELSE
--                        vttexto := f_axis_literales(vnum_err, pcidioma);
--                        vnum_err := f_proceslin(psproces,
--                                                vttexto || ' - PBEX ' || pol.cprovis,
--                                                pol.sseguro, vnlin);
--                        COMMIT;
--                        vcont_err := vcont_err + 1;
--                        vnlin := NULL;
--                     END IF;
--                  ELS*/
--                  IF pmodo = 'P' THEN
--                     INSERT INTO pbex_previo
--                                 (cempres, fcalcul, sproces, cramdgs, cramo,
--                                  cmodali, ctipseg, ccolect, sseguro,
--                                  cgarant, ivalact, icapgar, ipromat, cerror, nriesgo)
--                          VALUES (pcempres, pfcalcul, psproces, pol.cramdgs, pol.cramo,
--                                  pol.cmodali, pol.ctipseg, pol.ccolect, pol.sseguro,
--                                  pol.cgarant, NVL(vpb, 0), 0, 0, 0, pol.nriesgo);
--                  END IF;

         --                  COMMIT;
--               EXCEPTION
--                  WHEN OTHERS THEN
--                     p_tab_error(f_sysdate, f_user,
--                                 'CIERRE PROVISIONES PBEX PROCESO =' || psproces, NULL,
--                                 'error al insertar en pbEX SSEGURO =' || pol.sseguro
--                                 || ' PFECHA=' || pfcalcul,
--                                 SQLERRM);
--                     p_tab_error(f_sysdate, f_user, 'PROVISIONES_PB', 2, NULL,
--                                 'PREV.PROV' || pcempres || '-' || '-' || psproces || '-'
--                                 || pol.cramdgs || '-' || pol.cramo || '-' || pol.cmodali
--                                 || '-' || pol.ctipseg || '-' || pol.ccolect || '-'
--                                 || pol.sseguro || '-' || pol.cgarant || '-' || pol.cprovis
--                                 || '-' || pol.ipritot || '-' || NVL(vpb, 0) || '-'
--                                 || NVL(0, 0) || '-' || 0 || '-' || 0 || '-' || pol.nriesgo);
--                     vnum_err := 107110;   -- Error al insertar en la tabla PORVMAT
--               END;
--            END IF;
--            IF vnum_err <> 0 THEN
--               ROLLBACK;
--               vttexto := f_axis_literales(vnum_err, pcidioma);
--               vnum_err := f_proceslin(psproces, vttexto || ' - PBEX ' || pol.cprovis,
--                                       pol.sseguro, vnlin);
--               COMMIT;
--               vcont_err := vcont_err + 1;
--               vnlin := NULL;
--            END IF;
         END IF;

         IF vnum_err <> 0 THEN
            ROLLBACK;
            vttexto := f_axis_literales(vnum_err, pcidioma);
            vnum_err := f_proceslin(psproces, vttexto || ' - PBEX ' || pol.cprovis,
                                    pol.sseguro, vnlin);
            COMMIT;
            vcont_err := vcont_err + 1;
            vnlin := NULL;
         END IF;
      --
      END LOOP;   -- Cursor de Pólizas

      --
      RETURN vcont_err;
   END f_commit_pbex;

   /************************************************************************
       proceso_batch_cierre
          Proceso batch de inserción de la PB en CTASEGURO

        Parámetros Entrada:

            psmodo : Modo (1-->Previo y '2 --> Real)
            pcempres: Empresa
            pmoneda: Divisa
            pcidioma: Idioma
            pfperini: Fecha Inicio
            pfperfin: Fecha Fin
            pfcierre: Fecha Cierre

        Parámetros Salida:

            pcerror : <>0 si ha habido algún error
            psproces : Proceso
            pfproces : Fecha en que se realiza el proceso

    *************************************************************************/
   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
      -- 16/9/04 CPM:
      --
      --    Proceso que lanzará el proceso de cierre de ahorro de forma batch
      --
      --   Esta llamada tiene parámetros que no son necesarios por ser requeridos
      --     para que sea compatible con el resto de cierres programados.
      --
      vnum_err       NUMBER;
      vindice        NUMBER;
      v_modo         VARCHAR2(1);
   BEGIN
      IF pmodo = 2 THEN
         v_modo := 'R';
      ELSE
         v_modo := 'P';
      END IF;

      vnum_err := pac_ctaseguro.f_cierrepb(v_modo, pfcierre, pcidioma, pcempres, NULL, NULL,
                                           NULL, psproces, vindice, pcerror);

      IF vnum_err = 0 THEN
         pcerror := 0;
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      pfproces := f_sysdate;
   END proceso_batch_cierre;

-- Fi BUG 12278 -  09/2010 - JRH

   /************************************************************************
      f_procesar_pu
         Proceso de inserción de la PB en PBEX/PBEX_PREVIO (Participación de Beneficios)

       Parámetros Entrada:

           pcempres: Empresa
           pfecha: Fecha Calculo
           psproduc: Producto
           psseguro: Id. Seguro

       retorna 0 si ha ido todo bien o código de error en caso contrario
   *************************************************************************/
   FUNCTION f_procesar_pu(
      pcempres IN NUMBER,
      pfecha IN DATE,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      psproces IN NUMBER,
      pcidioma IN NUMBER)
      RETURN NUMBER IS
      CURSOR c_polizas IS
         SELECT a.sproces, a.sseguro, a.nriesgo, a.nmovimi, a.fefecto, a.fcalcul, a.ctipopu,
                a.cestado, s.sproduc
           FROM adm_proceso_pu a, seguros s
          WHERE (a.sseguro = psseguro
                 OR psseguro IS NULL)
            AND a.fcalcul <= pfecha
            AND a.cestado = 0   -- Pendientes de procesar
            AND a.ctipopu NOT IN(4, 5)
            AND s.sseguro = a.sseguro
         UNION
         SELECT DISTINCT a.sproces, NULL, NULL, NULL, a.fefecto, NULL, a.ctipopu, NULL, NULL
                    FROM adm_proceso_pu a, seguros s
                   WHERE (a.sseguro = psseguro
                          OR psseguro IS NULL)
                     AND a.fcalcul <= pfecha
                     AND a.cestado = 0   -- Pendientes de procesar
                     AND a.ctipopu IN(4, 5)   --Van por proceso
                     AND s.sseguro = a.sseguro;

      vnum_err       NUMBER;
      vindice        NUMBER;
      pcerror        NUMBER;
      v_sproces      NUMBER;
   BEGIN
      v_sproces := psproces;

      FOR pol IN c_polizas LOOP
         IF pol.ctipopu IN(1, 2, 3, 6) THEN
            vnum_err := pac_dincartera.f_tratamiento_pb(pcempres, pol.sproduc, pol.sseguro,
                                                        pol.fefecto, pol.nmovimi, 'A',
                                                        pol.nriesgo, pol.sproces);
         ELSIF pol.ctipopu IN(4, 5) THEN
            vnum_err := pac_ctaseguro.f_cierrepb('A', pol.fefecto, pcidioma, pcempres, NULL,
                                                 NULL, NULL, v_sproces, vindice, pcerror,
                                                 pol.sproces);
         END IF;

         IF vnum_err = 0 THEN
            pcerror := 0;
            COMMIT;
         ELSE
            ROLLBACK;
         END IF;
      END LOOP;

      RETURN 0;
   END f_procesar_pu;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROVIMAT_PBEX" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROVIMAT_PBEX" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROVIMAT_PBEX" TO "PROGRAMADORESCSI";
