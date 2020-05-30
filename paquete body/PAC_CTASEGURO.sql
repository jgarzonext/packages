--------------------------------------------------------
--  DDL for Package Body PAC_CTASEGURO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CTASEGURO" IS
   /******************************************************************************
      NOMBRE:     PAC_CTASEGURO
      PROPÓSITO:  Funciones de cuenta seguro

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        XX/XX/XXXX   XXX                1. Creación del package.
      2.0        27/04/2009   APD                2. Bug 9685 - primero se ha de buscar para la actividad en concreto
                                                    y si no se encuentra nada ir a buscar a GARANFORMULA para la actividad cero
      2.1        27/04/2009   APD                3. Bug 9685 - en lugar de coger la actividad de la tabla seguros, llamar a la
                                                    función pac_seguros.ff_get_actividad
      2.2        01/05/2009   JRH                7. Bug 9172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
      3.0        30/11/2009   NMM                8. 12101: CRE084 - Añadir rentabilidad en consulta de pólizas.
      4.0        17/12/2009   JAS                9. 0011302: CEM002 - Interface Libretas
      5.0        21/12/2009   APD               10. Bug 12426 : se crea la funcion f_anula_linea_ctaseguro
      6.0        01/01/2009   NCC               11. Bug 12907 : Se añade el control sobre la funcion pac_seguros.f_get_sseguro si es <> retorna mensaje.
      7.0        16/02/2010   ICV               12. 0012555: CEM002 - Interficie per apertura de llibretes
      8.0        16/03/2010   JRH               13. 0013692: ERROR PROVISIÓ POLISSA AMB 2 RESCATS PARCIALS
      9.0        15/07/2010   XPL               14. 15422: CEM998 - La Reimpressió de llibretes ha de permetre imprimir pendents + ja impressos
     10.0        22/07/2010   JRH               15. 0015485: CEM805 - Ordenación de la llibreta en la consulta de pólizas
     11.0        15/09/2010   JRH               16. 0012278: Proceso de PB para el producto PEA.
     12.0        11/04/2011   APD               17. 0018225: AGM704 - Realizar la modificación de precisión el cagente
     13.0        07/06/2011   ICV               18. 0018632: ENSA102-Aportaciones a nivel diferente de tomador
     14.0        14/12/2011   JMP               19. 0018423: LCOL705 - Multimoneda
     15.0        22/05/2012   MDS               20. 0022339: CRE998: Moviments compte-seguro CRE054. Canvi en la fórmula càlcul de variació
     16.0        25/03/2013   MMS               21. 0024741: (POSDE600)-Desarrollo-GAPS Tecnico-Id 30 - Anexo PU en Rentas Vitalicias. : modif en f_cierrepb
     17.0        14/03/2014   JLTS              22. 30417_0169644_QT-0011827: Se cambia el literal 104631 (Error al leer de la tabla USUARIOS) por 9906626 (Error de validación)
     18.0        25/03/2014   JTT               23. 0029943: POSRA200 - Gaps 27,28 Anexos de PU en VI
     19.0        29/04/2014   JTT               24. 0029943: Tratamiento de PUs
     20.0        19/05/2014   JTT               25. 0029943: Añadimos el nuevo tipo de PB 6 - Fondo de ahorro
     21.0        06/06/2014   JTT               26. 0029943: Proceso de PBs (TIPO_PB = 4)
     22.0        13/06/2014   JTT               27. 0029943: Proceso de PBs (TIPO_PB = 5)
     23.0        15/07/2014   AFM               28. 0032058: GAP. Prima de Riesgo, gastos y comisiones prepagables
     24.0        14/07/2015   YDA               24. 0031548: Se modifica la función f_cierepb para manejar los importes negativos por el parametro de producto BONUS_NEG.
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_numlin_next(psseguro IN NUMBER)
      RETURN NUMBER IS
      max_numlin     NUMBER;
   BEGIN
      SELECT NVL(MAX(nnumlin), 0)
        INTO max_numlin
        FROM ctaseguro
       WHERE sseguro = psseguro;

      max_numlin := max_numlin + 1;
      RETURN max_numlin;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_numlin_next;

   FUNCTION f_numlin_next_shw(psseguro IN NUMBER)
      RETURN NUMBER IS
      max_numlin     NUMBER;
   BEGIN
      SELECT NVL(MAX(nnumlin), 0)
        INTO max_numlin
        FROM ctaseguro_shadow
       WHERE sseguro = psseguro;

      max_numlin := max_numlin + 1;
      RETURN max_numlin;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_numlin_next_shw;

   FUNCTION f_insctaseguro(
      psseguro IN NUMBER,
      pfcontab IN DATE,
      pnnumlin IN NUMBER,
      pffecmov IN DATE,
      pffvalmov IN DATE,
      pcmovimi IN NUMBER,
      pimovimi IN NUMBER,
      pimovimi2 IN NUMBER,
      pnrecibo IN NUMBER,
      pccalint IN NUMBER,
      pcmovanu IN NUMBER,
      pnsinies IN NUMBER,
      psmovrec IN NUMBER,
      pcestado IN VARCHAR2,
      pmodo IN VARCHAR2 DEFAULT 'R',
      psproces IN NUMBER DEFAULT NULL,
      pnmovimi IN NUMBER DEFAULT NULL,
      pccapgar IN NUMBER DEFAULT NULL,
      pccapfal IN NUMBER DEFAULT NULL,
      psrecren IN NUMBER DEFAULT NULL,
      pigasext IN NUMBER DEFAULT NULL,
      pigasint IN NUMBER DEFAULT NULL,
      pipririe IN NUMBER DEFAULT NULL,
      pcesta IN NUMBER DEFAULT NULL,
      pfecmig IN DATE DEFAULT NULL,
      pctipapor IN NUMBER DEFAULT NULL
)
      RETURN NUMBER IS
      --
      -- Modif. del 15-03-1999. DRA. De moment, no té importancia el que vingui
      -- pel pfvalmov. En el camp de CTASEGURO, grabem la data efecte (xfefecto).
      --
      -- 25.10.2000 FM
      -- Modifiquem la forma d'insertar, fent que la data de contabilitzacio
      -- del moviment sigui la data de creacio del rebut, de forma que
      -- es contabilitzi correctament el cas d'un cobrament d'un rebut que ens
      -- arriba despres del seu "tancament"
      -- NP 26/03/2002 Si els imports són 0, tornem sense fer rès
      -- NP 17/05/2002 pcfeccob = 1, les dates son les fmovini
      -- BUG 32058. Se añade pipririe y pcesta.
      aux_fmovdia    DATE;
      encontrado     NUMBER;
      lffecmov       DATE;
      lffvalmov      DATE;
      v_nmovimi      NUMBER;
      v_icapital     NUMBER;
      v_nnumlin      NUMBER;
      v_ccapfal      NUMBER;
      v_cagrpro      NUMBER;
      --Bug.: 18632 - ICV - 07/06/2011
      v_ctipapor     NUMBER;
      v_sperapor     NUMBER;
      v_spermin      NUMBER;
      v_ctipaux      VARCHAR2(40);
      v_error        axis_literales.slitera%TYPE;
      v_cempres      seguros.cempres%TYPE;
   BEGIN
      IF pnnumlin IS NULL THEN
         v_nnumlin := f_numlin_next(psseguro);
      ELSE
         v_nnumlin := pnnumlin;
      END IF;

      IF pmodo = 'R' THEN
         --Bug.: 18632 - ICV - 07/06/2011
         SELECT cagrpro, cempres
           INTO v_cagrpro, v_cempres
           FROM seguros
          WHERE sseguro = psseguro;

         IF v_cagrpro = 11
            AND pnrecibo IS NOT NULL THEN
            BEGIN
               SELECT ctipapor, sperson
                 INTO v_ctipapor, v_sperapor
                 FROM recibos r
                WHERE r.nrecibo = pnrecibo;

               IF v_ctipapor = 4 THEN
                  v_ctipaux := 'PR';
               ELSIF v_ctipapor = 5 THEN
                  v_ctipaux := 'PA';
               ELSIF v_ctipapor = 6 THEN
                  v_ctipaux := 'SP';
               ELSIF v_ctipapor = 7 THEN
                  v_ctipaux := 'B';
               END IF;

               v_spermin := v_sperapor;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_ctipaux := NULL;
                  v_spermin := NULL;
            END;
         END IF;

         --Fi Bug.: 18632

         -- ALBERTO sobreescribirmos ctippaor
         IF PCTIPAPOR IS NOT NULL THEN
            v_ctipaux := pctipapor;
         END IF;


         INSERT INTO ctaseguro
                     (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                      imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cestado,
                      srecren, spermin, ctipapor, cesta, fectrasp)
              VALUES (psseguro, pfcontab, v_nnumlin, pffecmov, pffvalmov, pcmovimi, pimovimi,
                      pimovimi2, pnrecibo, pccalint, pcmovanu, pnsinies, psmovrec, pcestado,
                      psrecren, v_spermin, v_ctipaux, pcesta, pfecmig);

         -- BUG 18423 - 14/12/2011 - JMP - Multimoneda
         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0) = 1 THEN
            v_error := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro, pfcontab,
                                                                  v_nnumlin, pffvalmov);

            IF v_error <> 0 THEN
               RETURN v_error;
            END IF;
         END IF;
      -- FIN BUG 18423 - 14/12/2011 - JMP - Multimoneda
      ELSIF pmodo = 'P' THEN
         INSERT INTO ctaseguro_previo
                     (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                      imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cestado,
                      sproces, srecren, cesta)
              VALUES (psseguro, pfcontab, v_nnumlin, pffecmov, pffvalmov, pcmovimi, pimovimi,
                      pimovimi2, pnrecibo, pccalint, pcmovanu, pnsinies, psmovrec, pcestado,
                      psproces, psrecren, pcesta);
      END IF;

      -- sI SE GRABA MÁS INFORMACIÓN PARA LA LIBRETA
      IF NVL(f_parinstalacion_n('LIBRETA'), 0) = 1 THEN
         IF pcmovimi NOT IN(83, 84, 81) THEN
            v_nmovimi := pnmovimi;
            v_icapital := pccapgar;
            v_ccapfal := pccapfal;

            IF pmodo = 'R' THEN
               INSERT INTO ctaseguro_libreta
                           (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi,
                            sintbatch, nnumlib, igasext, igasint, ipririe)
                    VALUES (psseguro, v_nnumlin, pfcontab, v_icapital, v_ccapfal, v_nmovimi,
                            NULL, NULL, pigasext, pigasint, pipririe);
            ELSIF pmodo = 'P' THEN
               INSERT INTO ctaseguro_libreta_previo
                           (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi,
                            sintbatch, nnumlib, sproces, igasext, igasint, ipririe)
                    VALUES (psseguro, v_nnumlin, pfcontab, v_icapital, v_ccapfal, v_nmovimi,
                            NULL, NULL, psproces, pigasext, pigasint, pipririe);
            END IF;
         END IF;
      END IF;

         -- si el registro es de saldo ponemos la marca en las aportaciones como que ya han contado
      -- en ese saldo
      IF pmodo = 'R' THEN
         SELECT cagrpro
           INTO v_cagrpro
           FROM seguros
          WHERE sseguro = psseguro;

         IF pcmovimi = 0
            AND v_cagrpro = 2 THEN
            UPDATE ctaseguro
               SET ccalint = 1
             WHERE sseguro = psseguro
               AND cmovimi <> 0
               AND fvalmov <= pffvalmov;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_ctaseguro.insertar_ctaseguro', 1,
                     'error al insertar',
                     'SSEGURO =' || psseguro || ' nnumlin=' || pnnumlin || 'pmodo = ' || pmodo
                     || 'sqlerrm =' || SQLERRM);
         RETURN 102555;   -- error al insertar en ctaseguro
   END f_insctaseguro;

   FUNCTION f_insctaseguro_shw(
      psseguro IN NUMBER,
      pfcontab IN DATE,
      pnnumlin IN NUMBER,
      pffecmov IN DATE,
      pffvalmov IN DATE,
      pcmovimi IN NUMBER,
      pimovimi IN NUMBER,
      pimovimi2 IN NUMBER,
      pnrecibo IN NUMBER,
      pccalint IN NUMBER,
      pcmovanu IN NUMBER,
      pnsinies IN NUMBER,
      psmovrec IN NUMBER,
      pcestado IN VARCHAR2,
      pmodo IN VARCHAR2 DEFAULT 'R',
      psproces IN NUMBER DEFAULT NULL,
      pnmovimi IN NUMBER DEFAULT NULL,
      pccapgar IN NUMBER DEFAULT NULL,
      pccapfal IN NUMBER DEFAULT NULL,
      psrecren IN NUMBER DEFAULT NULL,
      pigasext IN NUMBER DEFAULT NULL,
      pigasint IN NUMBER DEFAULT NULL,
      pipririe IN NUMBER DEFAULT NULL,
      pcesta IN NUMBER DEFAULT NULL,
      pfecmig IN DATE DEFAULT NULL,
      pctipapor IN NUMBER DEFAULT NULL)


      RETURN NUMBER IS
      aux_fmovdia    DATE;
      encontrado     NUMBER;
      lffecmov       DATE;
      lffvalmov      DATE;
      v_nmovimi      NUMBER;
      v_icapital     NUMBER;
      v_nnumlin      NUMBER;
      v_ccapfal      NUMBER;
      v_cagrpro      NUMBER;
      --Bug.: 18632 - ICV - 07/06/2011
      v_ctipapor     NUMBER;
      v_sperapor     NUMBER;
      v_spermin      NUMBER;
      v_ctipaux      VARCHAR2(40);
      v_error        axis_literales.slitera%TYPE;
      v_cempres      seguros.cempres%TYPE;
   BEGIN
      IF pnnumlin IS NULL THEN
         v_nnumlin := f_numlin_next_shw(psseguro);
      ELSE
         v_nnumlin := pnnumlin;
      END IF;

      IF pmodo = 'R' THEN
         --Bug.: 18632 - ICV - 07/06/2011
         SELECT cagrpro, cempres
           INTO v_cagrpro, v_cempres
           FROM seguros
          WHERE sseguro = psseguro;

         IF v_cagrpro = 11
            AND pnrecibo IS NOT NULL THEN
            BEGIN
               SELECT ctipapor, sperson
                 INTO v_ctipapor, v_sperapor
                 FROM recibos r
                WHERE r.nrecibo = pnrecibo;

               IF v_ctipapor = 4 THEN
                  v_ctipaux := 'PR';
               ELSIF v_ctipapor = 5 THEN
                  v_ctipaux := 'PA';
               ELSIF v_ctipapor = 6 THEN
                  v_ctipaux := 'SP';
               ELSIF v_ctipapor = 7 THEN
                  v_ctipaux := 'B';
               END IF;

               v_spermin := v_sperapor;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_ctipaux := NULL;
                  v_spermin := NULL;
            END;
         END IF;


         -- ALBERTO sobreescribirmos ctippaor
         IF PCTIPAPOR IS NOT NULL THEN
            v_ctipaux := pctipapor;
         END IF;

         --Fi Bug.: 18632
         INSERT INTO ctaseguro_shadow
                     (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                      imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cestado,
                      srecren, spermin, ctipapor, cesta, fectrasp)
              VALUES (psseguro, pfcontab, v_nnumlin, pffecmov, pffvalmov, pcmovimi, pimovimi,
                      pimovimi2, pnrecibo, pccalint, pcmovanu, pnsinies, psmovrec, pcestado,
                      psrecren, v_spermin, v_ctipaux, pcesta, pfecmig);

         -- BUG 18423 - 14/12/2011 - JMP - Multimoneda
         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0) = 1 THEN
            v_error := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro, pfcontab,
                                                                      v_nnumlin, pffvalmov);

            IF v_error <> 0 THEN
               RETURN v_error;
            END IF;
         END IF;
      -- FIN BUG 18423 - 14/12/2011 - JMP - Multimoneda
      ELSIF pmodo = 'P' THEN
         INSERT INTO ctaseguro_previo_shw
                     (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                      imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cestado,
                      sproces, srecren, cesta)
              VALUES (psseguro, pfcontab, v_nnumlin, pffecmov, pffvalmov, pcmovimi, pimovimi,
                      pimovimi2, pnrecibo, pccalint, pcmovanu, pnsinies, psmovrec, pcestado,
                      psproces, psrecren, pcesta);
      END IF;

      -- sI SE GRABA MÁS INFORMACIÓN PARA LA LIBRETA
      IF NVL(f_parinstalacion_n('LIBRETA'), 0) = 1 THEN
         IF pcmovimi NOT IN(83, 84) THEN
            v_nmovimi := pnmovimi;
            v_icapital := pccapgar;
            v_ccapfal := pccapfal;

            IF pmodo = 'R' THEN
               INSERT INTO ctaseguro_libreta_shw
                           (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi,
                            sintbatch, nnumlib, igasext, igasint, ipririe)
                    VALUES (psseguro, v_nnumlin, pfcontab, v_icapital, v_ccapfal, v_nmovimi,
                            NULL, NULL, pigasext, pigasint, pipririe);
            ELSIF pmodo = 'P' THEN
               INSERT INTO ctaseguro_libreta_previo_shw
                           (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi,
                            sintbatch, nnumlib, sproces, igasext, igasint, ipririe)
                    VALUES (psseguro, v_nnumlin, pfcontab, v_icapital, v_ccapfal, v_nmovimi,
                            NULL, NULL, psproces, pigasext, pigasint, pipririe);
            END IF;
         END IF;
      END IF;

         -- si el registro es de saldo ponemos la marca en las aportaciones como que ya han contado
      -- en ese saldo
      IF pmodo = 'R' THEN
         SELECT cagrpro
           INTO v_cagrpro
           FROM seguros
          WHERE sseguro = psseguro;

         IF pcmovimi = 0
            AND v_cagrpro = 2 THEN
            UPDATE ctaseguro_shadow
               SET ccalint = 1
             WHERE sseguro = psseguro
               AND cmovimi <> 0
               AND fvalmov <= pffvalmov;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_ctaseguro.insertar_ctaseguro_shw', 1,
                     'error al insertar',
                     'SSEGURO =' || psseguro || ' nnumlin=' || pnnumlin || 'pmodo = ' || pmodo
                     || 'sqlerrm =' || SQLERRM);
         RETURN 102555;   -- error al insertar en ctaseguro
   END f_insctaseguro_shw;

     /*************************************************************************
      f_insctasegurodetalle: Inserta un detalle de CTASEGURO
      Param IN psseguro: Seguro
      Param IN pfcontab: Fecha Contable
      Param IN pnnumlin : Línea
      Param IN pccampo : Concepto
      Param IN pvalor : Vslor del concepto
      Param IN pmodo : Modo ('P'revio o 'R'eal)
      Param IN psproces : Proceso
      return : 0 Si todo ha ido bien, si no el código de error
   ****************************************************************************************/

   -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
   FUNCTION f_insctasegurodetalle(
      psseguro IN NUMBER,
      pfcontab IN DATE,
      pnnumlin IN NUMBER,
      pccampo IN VARCHAR,
      pvalor IN VARCHAR,
      pmodo IN VARCHAR2 DEFAULT 'R',
      psproces IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
   BEGIN
      IF pmodo = 'R' THEN
         BEGIN
            INSERT INTO ctaseguro_detalle
                        (sseguro, fcontab, nnumlin, ccampo, valor)
                 VALUES (psseguro, pfcontab, pnnumlin, pccampo, pvalor);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE ctaseguro_detalle
                  SET valor = pvalor
                WHERE sseguro = psseguro
                  AND fcontab = pfcontab
                  AND nnumlin = pnnumlin
                  AND ccampo = pccampo;
         END;
      ELSIF pmodo = 'P' THEN
         BEGIN
            INSERT INTO ctaseguro_detalle_previo
                        (sseguro, fcontab, nnumlin, ccampo, valor, sproces)
                 VALUES (psseguro, pfcontab, pnnumlin, pccampo, pvalor, psproces);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE ctaseguro_detalle_previo
                  SET valor = pvalor
                WHERE sseguro = psseguro
                  AND fcontab = pfcontab
                  AND nnumlin = pnnumlin
                  AND ccampo = pccampo;
         END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_ctaseguro.insctasegurodetalle', 1,
                     'error al insertar',
                     'SSEGURO =' || psseguro || ' nnumlin=' || pnnumlin || 'pmodo = ' || pmodo
                     || 'sqlerrm =' || SQLERRM);
         RETURN 102555;   -- error al insertar en ctaseguro
   END f_insctasegurodetalle;

      /*************************************************************************
      f_inscta_prov_cap_det: Inserta los detalles de CTASEGURO
      Param IN psseguro: Seguro
      Param IN pfecha: Fecha
      Param IN pfechaContable: Fecha Contable
      Param IN pnumLinea: Numero de linea
      Param IN pmodo : Modo ('P'revio o 'R'eal)
      Param IN ppsproces : Proceso
      Param IN pffecmov : Fecha efecto movimiento (puede ser nulo)
      return : 0 Si todo ha ido bien, si no el código de error
   ****************************************************************************************/

   -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
   FUNCTION f_inscta_prov_cap_det(
      psseguro IN NUMBER,
      pfecha IN DATE,
      pfechacontable IN DATE,
      pnumlinea IN NUMBER,
      pmodo IN VARCHAR2,
      ppsproces IN NUMBER,
      pffecmov IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      verr           NUMBER := 0;
   BEGIN
      verr := pac_propio.f_inscta_prov_cap_det(psseguro, pfecha, pfechacontable, pnumlinea,
                                               pmodo, ppsproces, pffecmov);
      RETURN verr;
   END f_inscta_prov_cap_det;

   FUNCTION f_aportacion_extraordinaria(
      pimporte IN NUMBER,
      pcapgarantit IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi OUT NUMBER,
      pcmotmov IN NUMBER DEFAULT 500)
      RETURN NUMBER IS
      suplemento     NUMBER;
      movimi_ant     NUMBER;
      num_movimi     NUMBER;
      v_cramo        NUMBER;
      v_cmodali      NUMBER;
      v_ctipseg      NUMBER;
      v_ccolect      NUMBER;
      v_cactivi      NUMBER;
      num_err        NUMBER;
      v_cgarant      NUMBER;
      v_norden       NUMBER;
      v_ctarifa      NUMBER;
      v_cformul      NUMBER;
      v_csituac      NUMBER;
   BEGIN
      BEGIN
         -- Bug 9685 - APD - 30/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
         SELECT cramo, cmodali, ctipseg, ccolect,
                pac_seguros.ff_get_actividad(sseguro, pnriesgo), csituac
           INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                v_cactivi, v_csituac
           FROM seguros
          WHERE sseguro = psseguro;
      -- Bug 9685 - APD - 30/04/2009 - Fin
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101919;
      END;

      -- CPM 30/12/05: Afegim el control de les pòlisses pdts. d'emetre
      IF v_csituac <> 4 THEN   -- Fem una aportació extraordinaria
         --Se genera un movimiento de seguro de suplemento
         SELECT (NVL(MAX(nsuplem), 0) + 1), MAX(nmovimi)
           INTO suplemento, movimi_ant
           FROM movseguro
          WHERE sseguro = psseguro;

         num_err := f_act_hisseg(psseguro, movimi_ant);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         num_err := f_movseguro(psseguro, NULL, pcmotmov, 1, TRUNC(f_sysdate), NULL,
                                suplemento, 0, NULL, num_movimi);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         pnmovimi := num_movimi;
         -- Se hace un duplicado de las garantias
         num_err := f_dupgaran(psseguro, TRUNC(f_sysdate), num_movimi);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

            -- Bug 9685 - APD - 30/04/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
         BEGIN
            SELECT cgarant, norden, ctarifa, cformul
              INTO v_cgarant, v_norden, v_ctarifa, v_cformul
              FROM garanpro
             WHERE cramo = v_cramo
               AND cmodali = v_cmodali
               AND ctipseg = v_ctipseg
               AND ccolect = v_ccolect
               AND cactivi = v_cactivi
               AND f_pargaranpro_v(cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, 'TIPO') =
                                                                                              4;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT cgarant, norden, ctarifa, cformul
                    INTO v_cgarant, v_norden, v_ctarifa, v_cformul
                    FROM garanpro
                   WHERE cramo = v_cramo
                     AND cmodali = v_cmodali
                     AND ctipseg = v_ctipseg
                     AND ccolect = v_ccolect
                     AND cactivi = 0
                     AND f_pargaranpro_v(cramo, cmodali, ctipseg, ccolect, cactivi, cgarant,
                                         'TIPO') = 4;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 101959;
               END;
            WHEN OTHERS THEN
               RETURN 101959;
         END;

         -- Bug 9685 - APD - 30/04/2009 - Fin
         BEGIN
            INSERT INTO garanseg
                        (cgarant, sseguro, nriesgo, finiefe, norden, crevali,
                         ctarifa, icapital, precarg, iprianu, iextrap, ffinefe, cformul,
                         ctipfra, ifranqu, irecarg, ipritar, pdtocom, idtocom, prevali,
                         irevali, itarifa, nmovimi, itarrea, ipritot, icaptot, nmovima,
                         ftarifa)
                 VALUES (v_cgarant, psseguro, pnriesgo, TRUNC(f_sysdate), v_norden, 0,
                         v_ctarifa, pimporte, NULL, 0, NULL, NULL, v_cformul,
                         NULL, NULL, 0, 0, NULL, 0, NULL,
                         NULL, NULL, num_movimi, NULL, 0, pimporte, num_movimi,
                         TRUNC(f_sysdate));
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 101959;
         END;

         -- Modificamos el capital de la garantia 287 (capital garantizado)
         BEGIN
            UPDATE garanseg
               SET icapital = pcapgarantit,
                   icaptot = pcapgarantit
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               --AND cgarant = 283
               AND f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi,
                                   cgarant, 'TIPO') = 5
               AND ffinefe IS NULL;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 101959;
         END;

         BEGIN
            -- Grabamos las preguntas
            INSERT INTO pregunseg
                        (cpregun, sseguro, nriesgo, nmovimi, crespue)
               SELECT cpregun, sseguro, nriesgo, num_movimi, crespue
                 FROM preguncar
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND crespue IS NOT NULL
                  AND sproces = (SELECT MAX(sproces)
                                   FROM preguncar
                                  WHERE sseguro = psseguro
                                    AND nriesgo = pnriesgo);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 112316;
         END;

         BEGIN
            -- Grabamos las preguntastab
            INSERT INTO pregunsegtab
                        (cpregun, sseguro, nriesgo, nmovimi, nlinea, ccolumna, tvalor, fvalor,
                         nvalor)
               SELECT cpregun, sseguro, nriesgo, num_movimi, nlinea, ccolumna, tvalor, fvalor,
                      nvalor
                 FROM preguncartab
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND(tvalor IS NOT NULL
                      OR fvalor IS NOT NULL
                      OR nvalor IS NOT NULL)
                  AND sproces = (SELECT MAX(sproces)
                                   FROM preguncartab
                                  WHERE sseguro = psseguro
                                    AND nriesgo = pnriesgo);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 112316;
         END;

         BEGIN
            INSERT INTO pregunseg
                        (cpregun, sseguro, nriesgo, nmovimi, crespue)
               SELECT cpregun, sseguro, nriesgo, num_movimi, crespue
                 FROM pregunseg
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM pregunseg x
                                  WHERE x.sseguro = psseguro
                                    AND x.nriesgo = pnriesgo
                                    AND cpregun = x.cpregun)
                  AND cpregun NOT IN(SELECT cpregun
                                       FROM pregunseg
                                      WHERE sseguro = psseguro
                                        AND nriesgo = pnriesgo
                                        AND nmovimi = num_movimi);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 112316;
         END;

         BEGIN
            INSERT INTO pregunsegtab
                        (cpregun, sseguro, nriesgo, nmovimi, nlinea, ccolumna, tvalor, fvalor,
                         nvalor)
               SELECT cpregun, sseguro, nriesgo, num_movimi, nlinea, ccolumna, tvalor, fvalor,
                      nvalor
                 FROM pregunsegtab
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM pregunsegtab x
                                  WHERE x.sseguro = psseguro
                                    AND x.nriesgo = pnriesgo
                                    AND cpregun = x.cpregun)
                  AND cpregun NOT IN(SELECT cpregun
                                       FROM pregunsegtab
                                      WHERE sseguro = psseguro
                                        AND nriesgo = pnriesgo
                                        AND nmovimi = num_movimi);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 112316;
         END;

         -----
         BEGIN
            INSERT INTO pregungaranseg
                        (sseguro, nriesgo, cgarant, nmovimi, cpregun, crespue, nmovima,
                         finiefe)
               SELECT sseguro, nriesgo, cgarant, num_movimi, cpregun, crespue, nmovima,
                      finiefe
                 FROM pregungarancar
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND crespue IS NOT NULL
                  AND sproces = (SELECT MAX(sproces)
                                   FROM pregungarancar
                                  WHERE sseguro = psseguro
                                    AND nriesgo = pnriesgo);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 112317;
         END;

         ----
         BEGIN
            INSERT INTO pregungaranseg
                        (sseguro, nriesgo, cgarant, nmovimi, cpregun, crespue, nmovima,
                         finiefe)
               SELECT sseguro, nriesgo, cgarant, num_movimi, cpregun, crespue, nmovima,
                      finiefe
                 FROM pregungaranseg
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM pregungaranseg x
                                  WHERE x.sseguro = psseguro
                                    AND x.nriesgo = pnriesgo
                                    AND cpregun = x.cpregun)
                  AND cpregun NOT IN(SELECT cpregun
                                       FROM pregungaranseg
                                      WHERE sseguro = psseguro
                                        AND nriesgo = pnriesgo
                                        AND nmovimi = num_movimi);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 112317;
         END;

         --Cambiamos el numero de suplemento en SEGUROS y la situacion
         BEGIN
            UPDATE seguros
               SET nsuplem = suplemento,
                   csituac = 5
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 101992;
         END;
      ELSE
         -- CPM: Modifiquem el mov. d'alta doncs tenim la pòlissa pdt. de emetre
           -- Modificamos el capital de la garantia principal
         BEGIN
            UPDATE garanseg
               SET icapital = pimporte,
                   iprianu = pimporte,
                   ipritar = pimporte,
                   itarifa = pimporte,
                   ipritot = pimporte,
                   icaptot = pimporte
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi,
                                   cgarant, 'TIPO') = 3
               AND ffinefe IS NULL;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 101959;
         END;

         -- Modificamos el capital de la garantia 287 (capital garantizado)
         BEGIN
            UPDATE garanseg
               SET icapital = pcapgarantit,
                   icaptot = pcapgarantit
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi,
                                   cgarant, 'TIPO') = 5
               AND ffinefe IS NULL;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 101959;
         END;

         num_err := pac_motretencion.f_desretener(psseguro, 1, '');

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      RETURN 0;
   END f_aportacion_extraordinaria;

   FUNCTION f_cierre_ahorro(
      pmodo IN VARCHAR2,
      pfcierre IN DATE,
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      pcagrpro IN NUMBER,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      psproces OUT NUMBER,
      indice OUT NUMBER,
      indice_error OUT NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      texto          VARCHAR2(400);
      titulo         VARCHAR2(1000);
      v_numlin       NUMBER;
      pnnumlin       NUMBER;
      cuentashw      NUMBER;
   BEGIN
      --Se graba en Procesoscab
      --Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
      --num_err := f_desempresa (pcempres, NULL, ptempresa);
      num_err := f_desvalorfijo(54, pcidioma, TO_NUMBER(TO_CHAR(pfcierre, 'mm')), texto);

      IF pmodo = 'P' THEN   -- previo del cierre
         titulo := 'Previo cierre mes de ' || texto || ' Prod. Ahorro';
      ELSE
         titulo := 'Cierre mes de ' || texto || ' Prod. Ahorro';
      END IF;

      IF pcagrpro IS NOT NULL THEN
         titulo := titulo || ' Agrupació: ' || pcagrpro;
      END IF;

      IF psproduc IS NOT NULL THEN
         titulo := titulo || ' Producto: ' || psproduc;
      END IF;

      IF psseguro IS NOT NULL THEN
         titulo := titulo || ' Póliza: ' || psseguro;
      END IF;

      num_err := f_procesini(f_user, pcempres, 'AHORRO', titulo, psproces);
      num_err := pac_propio.f_cierre_ahorro(pmodo, pfcierre, pcidioma, pcempres, pcagrpro,
                                            psproduc, psseguro, psproces, indice, indice_error);
      cuentashw := f_tiene_ctashadow(psseguro, psproduc);

      -- dramon 03-10-2008: Si hem llançat el tancament real, esborrem els previs
      IF pmodo = 'R' THEN
         BEGIN
            -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
            IF cuentashw = 1 THEN
               DELETE FROM ctaseguro_detalle_previo
                     WHERE (sseguro, nnumlin, fcontab) IN(SELECT sseguro, nnumlin, fcontab
                                                            FROM ctaseguro_previo_shw
                                                           WHERE ffecmov = pfcierre);

               --fi bug
               DELETE FROM ctaseguro_libreta_previo_shw
                     WHERE (sseguro, nnumlin, fcontab) IN(SELECT sseguro, nnumlin, fcontab
                                                            FROM ctaseguro_previo_shw
                                                           WHERE ffecmov = pfcierre);

               DELETE FROM ctaseguro_previo_shw
                     WHERE ffecmov = pfcierre;
            END IF;

            DELETE FROM ctaseguro_detalle_previo
                  WHERE (sseguro, nnumlin, fcontab) IN(SELECT sseguro, nnumlin, fcontab
                                                         FROM ctaseguro_previo
                                                        WHERE ffecmov = pfcierre);

            --fi bug
            DELETE FROM ctaseguro_libreta_previo
                  WHERE (sseguro, nnumlin, fcontab) IN(SELECT sseguro, nnumlin, fcontab
                                                         FROM ctaseguro_previo
                                                        WHERE ffecmov = pfcierre);

            DELETE FROM ctaseguro_previo
                  WHERE ffecmov = pfcierre;
         EXCEPTION
            WHEN OTHERS THEN
               texto := f_axis_literales(108017, pcidioma);
               indice_error := indice_error + 1;
               pnnumlin := NULL;
               num_err := f_proceslin(psproces, texto, psseguro, pnnumlin);
         END;
      ELSE
         -- dramon 03-10-2008: Esborrem previs anteriors
         BEGIN
            IF cuentashw = 1 THEN
               DELETE FROM ctaseguro_detalle_previo
                     WHERE (sseguro, nnumlin, fcontab) IN(
                                              SELECT sseguro, nnumlin, fcontab
                                                FROM ctaseguro_previo_shw
                                               WHERE ffecmov = pfcierre
                                                 AND sproces <> psproces);

               DELETE FROM ctaseguro_libreta_previo_shw
                     WHERE (sseguro, nnumlin, fcontab) IN(
                                               SELECT sseguro, nnumlin, fcontab
                                                 FROM ctaseguro_previo_shw
                                                WHERE ffecmov = pfcierre
                                                  AND sproces <> psproces);

               DELETE FROM ctaseguro_previo_shw
                     WHERE ffecmov = pfcierre
                       AND sproces <> psproces;
            END IF;

            -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
            DELETE FROM ctaseguro_detalle_previo
                  WHERE (sseguro, nnumlin, fcontab) IN(
                                               SELECT sseguro, nnumlin, fcontab
                                                 FROM ctaseguro_previo
                                                WHERE ffecmov = pfcierre
                                                  AND sproces <> psproces);

            --fi bug
            DELETE FROM ctaseguro_libreta_previo
                  WHERE (sseguro, nnumlin, fcontab) IN(
                                               SELECT sseguro, nnumlin, fcontab
                                                 FROM ctaseguro_previo
                                                WHERE ffecmov = pfcierre
                                                  AND sproces <> psproces);

            DELETE FROM ctaseguro_previo
                  WHERE ffecmov = pfcierre
                    AND sproces <> psproces;
         EXCEPTION
            WHEN OTHERS THEN
               texto := f_axis_literales(108017, pcidioma);
               indice_error := indice_error + 1;
               pnnumlin := NULL;
               num_err := f_proceslin(psproces, texto, psseguro, pnnumlin);
         END;
      END IF;

      num_err := f_procesfin(psproces, indice_error);
      RETURN num_err;
   END f_cierre_ahorro;

   FUNCTION f_np_tipo_garantias(psseguro IN NUMBER)
      RETURN NUMBER IS
--------------------------------------------------------------------------
-- Retorna:
--    1 si es va donar d'alta amb només prima periòdica
--    2 si es va donar d'alta amb prima periòdica i extraordinària
--    3 si es va donar d'alta sense cap de les dues (no es d'estalvi)
--
--   (sempre hi ha prima periòdica. Si es vol fer una sóla aportació,
--     es fa una periòdica amb forma de pagament única)
--------------------------------------------------------------------------
      vprima_periodica NUMBER;
      vprima_extraord NUMBER;
      vtipogar       NUMBER;
   BEGIN
      -- Bug 9685 - APD - 30/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
      SELECT COUNT(cgarant)
        INTO vprima_periodica
        FROM garanseg g, seguros s
       WHERE g.nmovimi = 1
         AND g.nriesgo = 1
         AND g.sseguro = psseguro
         AND g.sseguro = s.sseguro
         AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                             pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo), g.cgarant,
                             'TIPO') = 3;

                                                                --prima periòdica
      -- Bug 9685 - APD - 30/04/2009 - Fin

      -- Bug 9685 - APD - 30/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
      SELECT COUNT(cgarant)
        INTO vprima_extraord
        FROM garanseg g, seguros s
       WHERE g.nmovimi = 1
         AND g.nriesgo = 1
         AND g.sseguro = psseguro
         AND g.sseguro = s.sseguro
         AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                             pac_seguros.ff_get_actividad(s.sseguro, g.nriesgo), g.cgarant,
                             'TIPO') = 4;

                                                           --prima extraordinària
      -- Bug 9685 - APD - 30/04/2009 - Fin
      IF vprima_periodica = 1 THEN
         IF vprima_extraord = 1 THEN
            RETURN 2;   --alta amb única i periòdica
         ELSE
            RETURN 1;   --alta amb periòdica
         END IF;
      END IF;

      RETURN 3;   --cap de les dues
   END f_np_tipo_garantias;

   FUNCTION f_inscta_prov_cap_rentas(psseguro IN NUMBER)
      RETURN NUMBER IS
      vres           NUMBER;
   BEGIN
      RETURN(f_inscta_prov_cap(psseguro, f_sysdate, 'R', NULL));
   END f_inscta_prov_cap_rentas;

      -- JAS 23/01/2007 - Funció que realitza el càlcul de la provisió matemàtica. Aquesta funció ja existia,
   -- però era privada de en la funció "f_reduccion_total" d'aquest mateix package.
   FUNCTION f_inscta_prov_cap(
      psseguro IN NUMBER,
      pfecha IN DATE,
      pmodo IN VARCHAR2,
      ppsproces IN NUMBER,
      pffecmov IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      verr           NUMBER := 0;
      vpm            NUMBER;
      vcapfallec     NUMBER;
      vcapgar        NUMBER;
      xcmovimi       NUMBER;
      virentcap      NUMBER;   --JRH 11/2007 Rentas capitalizadas
      prodrent       NUMBER;   --JRH 11/2007 Rentas capitalizadas
      -- RSC 03/06/2008
      vsproduc       NUMBER;
      vexecute       VARCHAR2(2000);
      vformula       VARCHAR2(80);
      vresultado     NUMBER;
      vgastosext     NUMBER;
      vgastosint     NUMBER;
      -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
      vfechacontable DATE;
      vnumlinea      ctaseguro.nnumlin%TYPE;
      --fi bug
      -- Bug: 0032058 Primas, comision, gastos prepagables
      vahorro_prepagable NUMBER;
      vcagrpro       seguros.cagrpro%TYPE;
      vipririe       NUMBER;
   --
   BEGIN
      --dbms_output.put_line('ENTRAMOS EN LA FUNCION********************************************');
      SELECT sproduc, cagrpro
        INTO vsproduc, vcagrpro
        FROM seguros
       WHERE sseguro = psseguro;

      vahorro_prepagable := NVL(f_parproductos_v(vsproduc, 'AHORRO_PREPAGABLE'), 0);
      --dbms_output.put_line('entramos en pac-ctaseguro instca!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      vpm := pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha, 'IPROVAC');

      --      dbms_output.put_line('vpm !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!='||vpm);
      IF vpm IS NULL THEN
         verr := 151026;   -- Error en el cálculo de la provisión
      ELSE
         vcapfallec := pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha,
                                                                  'ICFALLAC');

         --         dbms_output.put_line('vcapfallec =!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'||vcapfallec);
         IF vcapfallec IS NULL THEN
            verr := 180158;   -- Error al calcular el capital de fallecimiento
         ELSE
            vcapgar := pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha, 'ICGARAC');

            --             dbms_output.put_line('vcapgar =!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'||vcapgar);
            IF vcapgar IS NULL THEN
               verr := 180159;   -- Error al calcular el Capital Garantizado
            ELSE
               IF NVL(f_parproductos_v(vsproduc, 'RENTA_CAPITALI'), 0) = 1 THEN   --JRH En el caso de rentas
                  virentcap := pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha,
                                                                          'IRENTCAP');

                  IF virentcap IS NULL THEN
                     verr := 180652;
                  -- Error al calcular el capital de fallecimiento
                  END IF;
               ELSE
                  virentcap := vpm;
               END IF;

               -- Bug: 0032058
               -- Si es prepagable no se debe informar en el detalle del cierre, ya que los datos calculados no corresponden
               -- al cierre actual sino que corresponden al siguiente cierre.
               --
               IF vahorro_prepagable = 0 THEN
                  vgastosext := pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha,
                                                                           'IGASEXT');

                  --             dbms_output.put_line('vgastos EXT =!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'||vgastosext);
                  IF vgastosext IS NULL THEN
                     --verr := 180652; -- Error al calcular LOS GASTOS;
                     vgastosext := 0;
                  END IF;

                  vgastosint := pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha,
                                                                           'IGASINT');

                  --             dbms_output.put_line('vgastos INT =!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'||vgastosint);
                  IF vgastosint IS NULL THEN
                     --verr := 180652; -- Error al calcular LOS GASTOS;
                     vgastosint := 0;
                  END IF;

                  --
                  -- Bug: 0032058
                  vipririe := pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha,
                                                                         'IPRIRIE');

                  --
                  IF vipririe IS NULL THEN
                     vipririe := 0;
                  END IF;
               --
               END IF;
            END IF;
         END IF;
      END IF;

      --END IF;
      IF verr = 0 THEN
         -- Grabamos el movimiento de saldo (provisión matemática)
         IF vpm >= 0 THEN
            xcmovimi := 0;
            -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
            vfechacontable := f_sysdate;

            -- fi Bug

            -- Bug: 0032058. Se realiza para que grabe antes del saldo si NO ser prepagable
            IF vahorro_prepagable = 0 THEN
               verr := f_ins_desglose_aho(psseguro, pfecha, xcmovimi, 0, pmodo, vcagrpro,
                                          vsproduc, vgastosext, vgastosint, vipririe);

               IF NVL(verr, 0) <> 0 THEN
                  RETURN verr;
               END IF;
            END IF;

            IF pffecmov IS NOT NULL THEN
               --dbms_output.put_line('inserta en ctaseguro!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
               verr := f_insctaseguro(psseguro, vfechacontable, NULL, pffecmov, pfecha,
                                      xcmovimi, vpm, virentcap, 0, 0, 0, 0, NULL, '2', pmodo,
                                      ppsproces, NULL, vcapgar, vcapfallec, NULL, vgastosext,
                                      vgastosint, vipririe);
            ELSE
               --dbms_output.put_line('inserta en ctaseguro!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
               verr := f_insctaseguro(psseguro, vfechacontable, NULL, pfecha, pfecha,
                                      xcmovimi, vpm, virentcap, 0, 0, 0, 0, NULL, '2', pmodo,
                                      ppsproces, NULL, vcapgar, vcapfallec, NULL, vgastosext,
                                      vgastosint, vipririe);
            END IF;

            -- Bug: 0032058. Se realiza para que grabe después del saldo al ser prepagable
            IF vahorro_prepagable = 1 THEN
               verr := f_ins_desglose_aho(psseguro, pfecha, xcmovimi, 0, pmodo, vcagrpro,
                                          vsproduc, vgastosext, vgastosint, vipririe);

               IF NVL(verr, 0) <> 0 THEN
                  RETURN verr;
               END IF;
            END IF;
         ELSIF vpm < 0 THEN
            verr := 151377;   -- Provisión matemática < 0
         END IF;
      END IF;

         -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
      -- Insertamos el detalle de CTASEGURO
      IF verr = 0
         AND(NVL(f_parproductos_v(vsproduc, 'DETCTASEG'), 0)) = 1 THEN
         BEGIN
            IF pmodo = 'R' THEN
               SELECT MAX(nnumlin)
                 INTO vnumlinea
                 FROM ctaseguro
                WHERE sseguro = psseguro
                  AND fcontab = vfechacontable;
            ELSE
               SELECT MAX(nnumlin)
                 INTO vnumlinea
                 FROM ctaseguro_previo
                WHERE sseguro = psseguro
                  AND fcontab = vfechacontable
                  AND sproces = ppsproces;
            END IF;

            verr := f_inscta_prov_cap_det(psseguro, pfecha, vfechacontable, vnumlinea, pmodo,
                                          ppsproces, pffecmov);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_ctaseguro.f_inscta_prov_cap', 2,
                           'psseguro = ' || psseguro || '  vnumLinea = ' || vnumlinea,
                           SQLERRM);
               verr := 151026;
         END;
      END IF;

      --fi bug
      RETURN verr;
   END f_inscta_prov_cap;

   FUNCTION f_inscta_prov_cap_shw(
      psseguro IN NUMBER,
      pfecha IN DATE,
      pmodo IN VARCHAR2,
      ppsproces IN NUMBER,
      pffecmov IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      verr           NUMBER := 0;
      vpm            NUMBER;
      vcapfallec     NUMBER;
      vcapgar        NUMBER;
      xcmovimi       NUMBER;
      virentcap      NUMBER;   --JRH 11/2007 Rentas capitalizadas
      prodrent       NUMBER;   --JRH 11/2007 Rentas capitalizadas
      -- RSC 03/06/2008
      vsproduc       NUMBER;
      vexecute       VARCHAR2(2000);
      vformula       VARCHAR2(80);
      vresultado     NUMBER;
      vgastosext     NUMBER;
      vgastosint     NUMBER;
      -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
      vfechacontable DATE;
      vnumlinea      ctaseguro.nnumlin%TYPE;
      --fi bug
      -- Bug: 0032058 Primas, comision, gastos prepagables
      vahorro_prepagable NUMBER;
      vcagrpro       seguros.cagrpro%TYPE;
      vipririe       NUMBER;
   --
   BEGIN
      SELECT sproduc, cagrpro
        INTO vsproduc, vcagrpro
        FROM seguros
       WHERE sseguro = psseguro;

      vahorro_prepagable := NVL(f_parproductos_v(vsproduc, 'AHORRO_PREPAGABLE'), 0);
      vpm := pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha, 'IPROVAC');

      --      dbms_output.put_line('vpm !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!='||vpm);
      IF vpm IS NULL THEN
         verr := 151026;   -- Error en el cálculo de la provisión
      ELSE
         vcapfallec := pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha,
                                                                  'ICFALLAC');

         IF vcapfallec IS NULL THEN
            verr := 180158;   -- Error al calcular el capital de fallecimiento
         ELSE
            vcapgar := pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha, 'ICGARAC');

            IF vcapgar IS NULL THEN
               verr := 180159;   -- Error al calcular el Capital Garantizado
            ELSE
               IF NVL(f_parproductos_v(vsproduc, 'RENTA_CAPITALI'), 0) = 1 THEN   --JRH En el caso de rentas
                  virentcap := pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha,
                                                                          'IRENTCAP');

                  IF virentcap IS NULL THEN
                     verr := 180652;
                  -- Error al calcular el capital de fallecimiento
                  END IF;
               ELSE
                  virentcap := vpm;
               END IF;

               -- Bug: 0032058
               -- Si es prepagable no se debe informar en el detalle del cierre, ya que los datos calculados no corresponden
               -- al cierre actual sino que corresponden al siguiente cierre.
               --
               IF vahorro_prepagable = 0 THEN
                  vgastosext := pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha,
                                                                           'IGASESHW');

                  IF vgastosext IS NULL THEN
                     --verr := 180652; -- Error al calcular LOS GASTOS;
                     vgastosext := 0;
                  END IF;

                  vgastosint := pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha,
                                                                           'IGASISHW');

                  IF vgastosint IS NULL THEN
                     --verr := 180652; -- Error al calcular LOS GASTOS;
                     vgastosint := 0;
                  END IF;

                  --
                  -- Bug: 0032058
                  vipririe := pac_provmat_formul.f_calcul_formulas_provi(psseguro, pfecha,
                                                                         'IPRIRSHW');

                  --
                  IF vipririe IS NULL THEN
                     vipririe := 0;
                  END IF;
               --
               END IF;
            END IF;
         END IF;
      END IF;

      --END IF;
      IF verr = 0 THEN
         -- Grabamos el movimiento de saldo (provisión matemática)
         IF vpm >= 0 THEN
            xcmovimi := 0;
            -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
            vfechacontable := f_sysdate;

            -- fi Bug

            -- Bug: 0032058. Se realiza para que grabe antes del saldo si NO ser prepagable
            IF vahorro_prepagable = 0 THEN
               verr := f_ins_desglose_aho_shw(psseguro, pfecha, xcmovimi, 0, pmodo, vcagrpro,
                                              vsproduc, vgastosext, vgastosint, vipririe);

               IF NVL(verr, 0) <> 0 THEN
                  RETURN verr;
               END IF;
            END IF;

            IF pffecmov IS NOT NULL THEN
               verr := f_insctaseguro_shw(psseguro, vfechacontable, NULL, pffecmov, pfecha,
                                          xcmovimi, vpm, virentcap, 0, 0, 0, 0, NULL, '2',
                                          pmodo, ppsproces, NULL, vcapgar, vcapfallec, NULL,
                                          vgastosext, vgastosint, vipririe);
            ELSE
               verr := f_insctaseguro_shw(psseguro, vfechacontable, NULL, pfecha, pfecha,
                                          xcmovimi, vpm, virentcap, 0, 0, 0, 0, NULL, '2',
                                          pmodo, ppsproces, NULL, vcapgar, vcapfallec, NULL,
                                          vgastosext, vgastosint, vipririe);
            END IF;

            -- Bug: 0032058. Se realiza para que grabe después del saldo al ser prepagable
            IF vahorro_prepagable = 1 THEN
               verr := f_ins_desglose_aho_shw(psseguro, pfecha, xcmovimi, 0, pmodo, vcagrpro,
                                              vsproduc, vgastosext, vgastosint, vipririe);

               IF NVL(verr, 0) <> 0 THEN
                  RETURN verr;
               END IF;
            END IF;
         ELSIF vpm < 0 THEN
            verr := 151377;   -- Provisión matemática < 0
         END IF;
      END IF;

         -- Bug 0009172 - JRH - 01/05/2009 - Nueva Función : Bug 0009172: CRE055 - Rentas regulares e irregulares con cálculos a partir de renta
      -- Insertamos el detalle de CTASEGURO
      IF verr = 0
         AND(NVL(f_parproductos_v(vsproduc, 'DETCTASEG'), 0)) = 1 THEN
         BEGIN
            IF pmodo = 'R' THEN
               SELECT MAX(nnumlin)
                 INTO vnumlinea
                 FROM ctaseguro_shadow
                WHERE sseguro = psseguro
                  AND fcontab = vfechacontable;
            ELSE
               SELECT MAX(nnumlin)
                 INTO vnumlinea
                 FROM ctaseguro_previo_shw
                WHERE sseguro = psseguro
                  AND fcontab = vfechacontable
                  AND sproces = ppsproces;
            END IF;

            verr := f_inscta_prov_cap_det(psseguro, pfecha, vfechacontable, vnumlinea, pmodo,
                                          ppsproces, pffecmov);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_ctaseguro.f_inscta_prov_cap_shw', 2,
                           'psseguro = ' || psseguro || '  vnumLinea = ' || vnumlinea,
                           SQLERRM);
               verr := 151026;
         END;
      END IF;

      --fi bug
      RETURN verr;
   END f_inscta_prov_cap_shw;

   --
    -- Bug: 0032058. Función que genera el desglos de gastos y prima de riesgo dependiendo de los parametros del producto DESGLOSE_AHORRO
    --
   FUNCTION f_ins_desglose_aho(
      psseguro IN NUMBER,
      pfmovdia IN DATE,
      pcmovimi IN NUMBER,
      pseqgrupo IN NUMBER,
      pmodo IN VARCHAR2,
      pcagrpro IN NUMBER,
      psproduc IN NUMBER DEFAULT NULL,
      pigasext IN NUMBER DEFAULT NULL,
      pigasint IN NUMBER DEFAULT NULL,
      pipririe IN NUMBER DEFAULT NULL,
      pnrecibo IN NUMBER DEFAULT NULL,
      pnsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      --
      num_err        NUMBER;
      v_fecha        DATE;
      v_sproduc      productos.sproduc%TYPE;
      v_ipririe      ctaseguro.imovimi%TYPE;
      v_cmovimi      ctaseguro.cmovimi%TYPE;
      v_graba        NUMBER;
      v_gastosext    ctaseguro.imovimi%TYPE;
      v_gastosint    ctaseguro.imovimi%TYPE;
      v_gastos       ctaseguro.imovimi%TYPE;
      v_desglose_ahorro NUMBER;
      v_ahorro_prepagable NUMBER;
      v_cmodcom      comisionprod.cmodcom%TYPE;
      v_ccomisi      comisionprod.ccomisi%TYPE;
      v_cretenc      agentes.cretenc%TYPE;
   --
   BEGIN
      IF pcmovimi IN(0, 1, 2, 4, 8) THEN
         v_desglose_ahorro := NVL(f_parproductos_v(psproduc, 'DESGLOSE_AHORRO'), 0);
         v_ahorro_prepagable := NVL(f_parproductos_v(psproduc, 'AHORRO_PREPAGABLE'), 0);

         IF v_desglose_ahorro = 0 THEN
            RETURN 0;
         END IF;

         -- Si es prepagable miro si existe un movimiento de Prima de Riesgo de la primera aportación
         IF pcmovimi IN(1, 2, 4, 8)
            AND v_ahorro_prepagable = 1 THEN
            SELECT DECODE(COUNT(1), 0, 1, 0)
              INTO v_graba
              FROM ctaseguro
             WHERE sseguro = psseguro
               AND cmovimi IN(21, 22);
         ELSE
            v_graba := 1;
         END IF;

         -- Si es 0, salimos no hay que grabar apunte
         IF v_graba = 0 THEN
            RETURN 0;
         END IF;

         -- Si es prepagable y se está ejecutando el cierre la fecha será 01 mes siguiente cierre.
         -- para planes e ULK no ajusta fecha lo hará en pac_operativa_finv
         IF pcagrpro NOT IN(11, 21) THEN
            IF v_ahorro_prepagable = 1
               AND pcmovimi = 0 THEN
               v_fecha := TRUNC(pfmovdia) + 1;
            ELSE
               -- Si NO es prepagable y no es el cierre se graba la fecha de entrada.
               v_fecha := TRUNC(pfmovdia);
            END IF;
         ELSE
            v_fecha := TRUNC(pfmovdia);
         END IF;

         /* Se realiza el apunte de la prima de riesgo */
         IF v_desglose_ahorro IN(1, 2) THEN
            --
            -- Generamos lineas de Gastos de Seguro de Cobertura (Prima de Riesgo)
            --
            v_cmovimi := 21;

            -- Si es ULK o Planes los apuntes se gestionan en el packages pac_operativa_finv
            IF pcagrpro IN(11, 21) THEN
               num_err := pac_operativa_finv.f_cta_gastos_scobertura(psseguro, v_fecha,
                                                                     psproduc, pmodo,
                                                                     pcmovimi, pipririe,
                                                                     pnrecibo, pnsinies);
            ELSE
               --
               -- Si viene informado NO se calcula
               --
               IF pipririe IS NULL THEN
                  v_ipririe := pac_provmat_formul.f_calcul_formulas_provi(psseguro, v_fecha,
                                                                          'IPRIRIE', NULL,
                                                                          NULL, 1, NULL, NULL,
                                                                          pnrecibo, pnsinies);

                  --
                  IF v_ipririe IS NULL THEN
                     v_ipririe := 0;
                  END IF;
               --
               ELSE
                  v_ipririe := NVL(pipririe, 0);
               END IF;

               --
               IF NVL(v_ipririe, 0) <> 0 THEN
                  --
                  num_err := pac_ctaseguro.f_insctaseguro(psseguro, v_fecha, NULL, v_fecha,
                                                          v_fecha, v_cmovimi, v_ipririe, NULL,
                                                          NULL, pseqgrupo, NULL, NULL, NULL,
                                                          NULL, pmodo, NULL, NULL, NULL, NULL);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               --
               END IF;
            --
            END IF;
         --
         END IF;

         /* Se realiza el apunte de Gastos (Internos y Externos) */
         IF v_desglose_ahorro IN(1, 3) THEN
            --
            v_cmovimi := 22;

            -- Si es ULK o Planes los apuntes se gestionan en el packages pac_operativa_finv
            IF pcagrpro IN(11, 21) THEN
               num_err := pac_operativa_finv.f_cta_gastos_gestion(psseguro, v_fecha, pmodo,
                                                                  pcmovimi, pnrecibo,
                                                                  pnsinies);
            ELSE
               --
               IF pigasint IS NULL THEN
                  v_gastosint := pac_provmat_formul.f_calcul_formulas_provi(psseguro, v_fecha,
                                                                            'IGASINT', NULL,
                                                                            NULL, 1, NULL,
                                                                            NULL, pnrecibo,
                                                                            pnsinies);

                  --
                  IF v_gastosint IS NULL THEN
                     v_gastosint := 0;
                  END IF;
               ELSE
                  v_gastosint := NVL(pigasint, 0);
               END IF;

               --
               --
               -- Si viene informado no lo calculamos de nuevo
               --
               IF pigasext IS NULL THEN
                  v_gastosext := pac_provmat_formul.f_calcul_formulas_provi(psseguro, v_fecha,
                                                                            'IGASEXT', NULL,
                                                                            NULL, 1, NULL,
                                                                            NULL, pnrecibo,
                                                                            pnsinies);

                  --
                  IF v_gastosext IS NULL THEN
                     v_gastosext := 0;
                  END IF;
               ELSE
                  v_gastosext := NVL(pigasext, 0);
               END IF;

               --
               v_gastos := v_gastosext + v_gastosint;

               --
               IF NVL(v_gastos, 0) <> 0 THEN
                  --
                  num_err := pac_ctaseguro.f_insctaseguro(psseguro, v_fecha, NULL, v_fecha,
                                                          v_fecha, v_cmovimi, v_gastos, NULL,
                                                          NULL, pseqgrupo, NULL, NULL, NULL,
                                                          NULL, pmodo, NULL, NULL, NULL, NULL);

                  --
                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               --
               END IF;
            END IF;
         END IF;   -- desglose ahorro
      END IF;   --pcmovimi in (0, 1, 2, 4, 8)

      --
      -- Grabamos RECIBO de COMISION sin hay gastos externos y es primera aportación o cierre de mes
      --
      IF pcmovimi IN(1, 2, 4, 8) THEN
         num_err := pac_propio.f_graba_rec_comision(pmodo, v_fecha, pcagrpro, psproduc,
                                                    psseguro);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      --
      RETURN 0;
   --
   END f_ins_desglose_aho;

   FUNCTION f_ins_desglose_aho_shw(
      psseguro IN NUMBER,
      pfmovdia IN DATE,
      pcmovimi IN NUMBER,
      pseqgrupo IN NUMBER,
      pmodo IN VARCHAR2,
      pcagrpro IN NUMBER,
      psproduc IN NUMBER DEFAULT NULL,
      pigasext IN NUMBER DEFAULT NULL,
      pigasint IN NUMBER DEFAULT NULL,
      pipririe IN NUMBER DEFAULT NULL,
      pnrecibo IN NUMBER DEFAULT NULL,
      pnsinies IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      --
      num_err        NUMBER;
      v_fecha        DATE;
      v_sproduc      productos.sproduc%TYPE;
      v_ipririe      ctaseguro_shadow.imovimi%TYPE;
      v_cmovimi      ctaseguro_shadow.cmovimi%TYPE;
      v_graba        NUMBER;
      v_gastosext    ctaseguro_shadow.imovimi%TYPE;
      v_gastosint    ctaseguro_shadow.imovimi%TYPE;
      v_gastos       ctaseguro_shadow.imovimi%TYPE;
      v_desglose_ahorro NUMBER;
      v_ahorro_prepagable NUMBER;
      v_cmodcom      comisionprod.cmodcom%TYPE;
      v_ccomisi      comisionprod.ccomisi%TYPE;
      v_cretenc      agentes.cretenc%TYPE;
   --
   BEGIN
      IF pcmovimi IN(0, 1, 2, 4, 8) THEN
         v_desglose_ahorro := NVL(f_parproductos_v(psproduc, 'DESGLOSE_AHORRO'), 0);
         v_ahorro_prepagable := NVL(f_parproductos_v(psproduc, 'AHORRO_PREPAGABLE'), 0);

         IF v_desglose_ahorro = 0 THEN
            RETURN 0;
         END IF;

         -- Si es prepagable miro si existe un movimiento de Prima de Riesgo de la primera aportación
         IF pcmovimi IN(1, 2, 4, 8)
            AND v_ahorro_prepagable = 1 THEN
            SELECT DECODE(COUNT(1), 0, 1, 0)
              INTO v_graba
              FROM ctaseguro_shadow
             WHERE sseguro = psseguro
               AND cmovimi IN(21, 22);
         ELSE
            v_graba := 1;
         END IF;

         -- Si es prepagable y se está ejecutando el cierre la fecha será 01 mes siguiente cierre.
         -- para planes e ULK no ajusta fecha lo hará en pac_operativa_finv
         IF pcagrpro NOT IN(11, 21) THEN
            IF v_ahorro_prepagable = 1
               AND pcmovimi = 0 THEN
               v_fecha := TRUNC(pfmovdia) + 1;
            ELSE
               -- Si NO es prepagable y no es el cierre se graba la fecha de entrada.
               v_fecha := TRUNC(pfmovdia);
            END IF;
         ELSE
            v_fecha := TRUNC(pfmovdia);
         END IF;

         /* Se realiza el apunte de la prima de riesgo */
         IF v_desglose_ahorro IN(1, 2) THEN
            --
            -- Generamos lineas de Gastos de Seguro de Cobertura (Prima de Riesgo)
            --
            v_cmovimi := 21;

            -- Si es ULK o Planes los apuntes se gestionan en el packages pac_operativa_finv
            IF pcagrpro IN(11, 21)
               AND v_graba = 1 THEN
               num_err := pac_operativa_finv.f_cta_gastos_scobertura_shw(psseguro, v_fecha,
                                                                         psproduc, pmodo,
                                                                         pcmovimi, pipririe,
                                                                         pnrecibo, pnsinies);
            ELSE
               --
               -- Si viene informado NO se calcula
               --
               IF pipririe IS NULL THEN
                  v_ipririe := pac_provmat_formul.f_calcul_formulas_provi(psseguro, v_fecha,
                                                                          'IPRIRSHW', NULL,
                                                                          NULL, 1, NULL, NULL,
                                                                          pnrecibo, pnsinies);

                  --
                  IF v_ipririe IS NULL THEN
                     v_ipririe := 0;
                  END IF;
               --
               ELSE
                  v_ipririe := NVL(pipririe, 0);
               END IF;

               --
               IF NVL(v_ipririe, 0) <> 0
                  AND v_graba = 1 THEN
                  --
                  num_err := pac_ctaseguro.f_insctaseguro_shw(psseguro, v_fecha, NULL,
                                                              v_fecha, v_fecha, v_cmovimi,
                                                              v_ipririe, NULL, NULL,
                                                              pseqgrupo, NULL, NULL, NULL,
                                                              NULL, pmodo, NULL, NULL, NULL,
                                                              NULL);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               --
               END IF;
            --
            END IF;
         --
         END IF;

         /* Se realiza el apunte de Gastos (Internos y Externos) */
         IF v_desglose_ahorro IN(1, 3) THEN
            --
            v_cmovimi := 22;

            -- Si es ULK o Planes los apuntes se gestionan en el packages pac_operativa_finv
            IF pcagrpro IN(11, 21)
               AND v_graba = 1 THEN
               num_err := pac_operativa_finv.f_cta_gastos_gestion_shw(psseguro, v_fecha,
                                                                      pmodo, pcmovimi,
                                                                      pnrecibo, pnsinies);
            ELSE
               --
               IF pigasint IS NULL THEN
                  v_gastosint := pac_provmat_formul.f_calcul_formulas_provi(psseguro, v_fecha,
                                                                            'IGASISHW', NULL,
                                                                            NULL, 1, NULL,
                                                                            NULL, pnrecibo,
                                                                            pnsinies);

                  --
                  IF v_gastosint IS NULL THEN
                     v_gastosint := 0;
                  END IF;
               ELSE
                  v_gastosint := NVL(pigasint, 0);
               END IF;

               --
               --
               -- Si viene informado no lo calculamos de nuevo
               --
               IF pigasext IS NULL THEN
                  v_gastosext := pac_provmat_formul.f_calcul_formulas_provi(psseguro, v_fecha,
                                                                            'IGASESHW', NULL,
                                                                            NULL, 1, NULL,
                                                                            NULL, pnrecibo,
                                                                            pnsinies);

                  --
                  IF v_gastosext IS NULL THEN
                     v_gastosext := 0;
                  END IF;
               ELSE
                  v_gastosext := NVL(pigasext, 0);
               END IF;

               --
               v_gastos := v_gastosext + v_gastosint;

               --
               IF NVL(v_gastos, 0) <> 0
                  AND v_graba = 1 THEN
                  --
                  num_err := pac_ctaseguro.f_insctaseguro_shw(psseguro, v_fecha, NULL,
                                                              v_fecha, v_fecha, v_cmovimi,
                                                              v_gastos, NULL, NULL, pseqgrupo,
                                                              NULL, NULL, NULL, NULL, pmodo,
                                                              NULL, NULL, NULL, NULL);

                  --
                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               --
               END IF;
            END IF;
         END IF;   -- desglose ahorro
      END IF;   --pcmovimi in (0, 1, 2, 4, 8)

      --
      RETURN 0;
   --
   END f_ins_desglose_aho_shw;

   FUNCTION f_reduccion_total(psseguro IN NUMBER, pcidioma_user IN NUMBER DEFAULT f_idiomauser)
      RETURN NUMBER IS
      num_err        NUMBER;
      vcmotmov       NUMBER;
      v_npoliza      NUMBER;
      v_ncertif      NUMBER;
      v_nsuplem      NUMBER;
      v_efecpol      DATE;
      v_efesupl      DATE;
      vcdelega       NUMBER;
      ocoderror      NUMBER;
      omsgerror      VARCHAR2(2000);
      vprevali       NUMBER;
      error          EXCEPTION;
   BEGIN
      vcmotmov := 266;   -- Suspensión de pago periódico
      -- Se busca la póliza
      num_err := f_buscapoliza(psseguro, v_npoliza, v_ncertif);

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

      -- Se busca la fecha del último suplemento
      num_err := f_ultsupl(v_npoliza, v_ncertif, v_nsuplem, v_efecpol, v_efesupl);

      IF num_err <> 0 THEN
         RAISE error;
      END IF;

      num_err := pac_ref_contrata_comu.f_valida_poliza_permite_supl(v_npoliza, v_ncertif,
                                                                    TRUNC(v_efesupl), vcmotmov,
                                                                    pcidioma_user, ocoderror,
                                                                    omsgerror);

      IF num_err IS NULL THEN
         num_err := ocoderror;
         RAISE error;
      END IF;

      BEGIN
         SELECT cdelega
           INTO vcdelega
           FROM usuarios
          WHERE cusuari = UPPER(f_user);
      EXCEPTION
         WHEN OTHERS THEN
            num_err := 9906626;   -- Error de validación
      END;

      -- Se busca el prevali de la póliza, ya que se le debe pasar el mismo para que no detecte cambio de % de revalorización
      SELECT prevali
        INTO vprevali
        FROM seguros
       WHERE sseguro = psseguro;

      num_err := pac_ref_contrata_aho.f_suplemento_aportacion_revali(psseguro,
                                                                     TRUNC(v_efesupl), 0, 0,
                                                                     vprevali, vcdelega,
                                                                     vcdelega, pcidioma_user,
                                                                     ocoderror, omsgerror);

      IF num_err IS NULL THEN
         num_err := ocoderror;
         RAISE error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN error THEN
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_ctaseguro.f_reduccion_total', NULL,
                     'psseguro = ' || psseguro || '  pcidioma_user = ' || pcidioma_user,
                     SQLERRM);
         RETURN 151981;   -- Esta póliza no puede ser reducida
   END f_reduccion_total;

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
      num_err        NUMBER;
      indice         NUMBER;
      v_modo         VARCHAR2(1);
   BEGIN
      IF pmodo = 2 THEN
         v_modo := 'R';
      ELSE
         v_modo := 'P';
      END IF;

      num_err := f_cierre_ahorro(v_modo, pfcierre, pcidioma, pcempres, NULL, NULL, NULL,
                                 psproces, indice, pcerror);

      IF num_err = 0 THEN
         pcerror := 0;
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      pfproces := f_sysdate;
   END proceso_batch_cierre;

   FUNCTION f_esta_reducida(psseguro IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      RETURN pac_propio.f_esta_reducida(psseguro);
   END f_esta_reducida;

     /*
     FUNCTION f_recalcular_aport_ibex(psseguro IN NUMBER, pfecha IN DATE) RETURN NUMBER IS
        -- RSC 26/11/2007
        seqgrupo  NUMBER;
        xnnumlin  NUMBER;
        icapibex  NUMBER;
        num_err   NUMBER;

           v_ccalint NUMBER;
        v_fvalmov DATE;
        v_nunidad NUMBER;
        v_iuniact NUMBER;
        xidistrib  NUMBER;

           ntraza    NUMBER := 1;

           --Cursor sobre la distribución del modelo de inversión asociado a la póliza.
        CURSOR cur_segdisin2 (seguro number) IS
          select sseguro,ccesta,pdistrec
          from segdisin2
          where sseguro = seguro
            and nmovimi = (select MAX(nmovimi)
                           from segdisin2
                           where sseguro=seguro
                             and ffin IS NULL)
            and ffin IS NULL;
     BEGIN
        BEGIN
          SELECT c.ccalint, c2.fvalmov, c2.nunidad INTO v_ccalint, v_fvalmov, v_nunidad
          FROM ctaseguro c, ctaseguro c2
          WHERE c.sseguro = psseguro
            AND c.cmovimi = 2
            AND c.cmovanu = 0
            AND 1 = (SELECT COUNT(*)
                     FROM ctaseguro c3
                     WHERE c3.sseguro = psseguro
                       AND c3.ccalint = c.ccalint
                       AND c3.cmovimi = 45
                       AND c3.cesta IS NOT NULL) -- Aportación que tiene detalle (Ibex 35)
            AND c2.sseguro = psseguro
            AND c2.cmovimi = 45
            AND c2.cmovanu = 0
            AND c2.ccalint = c.ccalint;
        EXCEPTION
          WHEN OTHERS THEN
            RETURN 104882;
        END;

           BEGIN
          SELECT crespue INTO icapibex
          FROM PREGUNSEG
          WHERE sseguro = psseguro
            AND nriesgo = 1
            AND nmovimi = (select max(nmovimi)
                           FROM PREGUNSEG
                           WHERE sseguro = psseguro
                             AND nriesgo = 1
                             AND cpregun = 1013)
            AND cpregun = 1013; -- Parte de prima a Ibex 35
        EXCEPTION
          WHEN OTHERS THEN
            RETURN 120307;
        END;

           IF v_nunidad is NOT NULL THEN
          -- Anulación de lineas de la antigua aportación
          -- Actualizamos movimiento general
          UPDATE ctaseguro
          SET imovimi = icapibex
          WHERE sseguro = psseguro
            AND ccalint = v_ccalint
            AND cesta IS NULL;

             -- Ponemos la linea de detalle (mov 45 de la aportación)
          -- Actualizamos movimiento detalle
          FOR valor IN cur_segdisin2 (psseguro) LOOP
            --Calcula les distribucions
            xidistrib := (icapibex * valor.pdistrec) / 100;

               BEGIN
              SELECT iuniact INTO v_iuniact
              FROM TABVALCES
              WHERE ccesta = valor.ccesta
                AND trunc(fvalor) = trunc(v_fvalmov);
            EXCEPTION
              WHEN OTHERS THEN
                RETURN 180619;
            END;

               -- Actualizamos el movimiento de detalle
            UPDATE ctaseguro
            SET imovimi = xidistrib, nunidad = xidistrib/v_iuniact
            WHERE sseguro = psseguro
              AND ccalint = v_ccalint
              AND cesta = valor.ccesta;
          END LOOP;
        ELSE
          -- Anulación de lineas de la antigua aportación
          UPDATE ctaseguro
          SET imovimi = icapibex
          WHERE sseguro = psseguro
            AND ccalint = v_ccalint;
        END IF;

          RETURN (0);
     END f_recalcular_aport_ibex;
   */

   -- RSC 26/11/2007 --------------------------------------------------------
-- RSC 09/07/2008
-- Ajustes por cmovimi que se graba a partir de ahora es 1
-- Por otra parte el tema del CCALINT no funciona ya que se introdujo una modificacion
-- que pone el ccalint a 0 (modificacion de ahorro)
   FUNCTION f_recalcular_aport_ibex(psseguro IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      -- RSC 26/11/2007
      seqgrupo       NUMBER;
      xnnumlin       NUMBER;
      icapibex       NUMBER;
      num_err        NUMBER;
      v_ccalint      NUMBER;
      v_fvalmov      DATE;
      v_nunidad      NUMBER;
      v_iuniact      NUMBER;
      v_cmovimi      NUMBER;
      xidistrib      NUMBER;
      ntraza         NUMBER := 1;
      -- RSC 09/07/2008 Error detectado al recalcular aportaciones de Ibex 35 en CTASEGURO
      -- el recalculo se debe hacer por si hay un suplemento de cambio de % de interés
      -- Por tanto la parte de Ibex varia y se debe recalcular
      v_nnumlin      NUMBER;
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;

      --Cursor sobre la distribución del modelo de inversión asociado a la póliza.
      CURSOR cur_segdisin2(seguro NUMBER) IS
         SELECT sseguro, ccesta, pdistrec
           FROM segdisin2
          WHERE sseguro = seguro
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = seguro
                              AND ffin IS NULL)
            AND ffin IS NULL;

      -- RSC 09/07/2008 Modificamos cursor
      CURSOR cur_aport_ibex(seguro NUMBER) IS
         SELECT c.cmovimi, c.nnumlin, c.fvalmov
           FROM ctaseguro c
          WHERE c.sseguro = seguro
            AND c.cmovimi IN(1, 51)
            AND EXISTS(SELECT *
                         FROM ctaseguro
                        WHERE sseguro = c.sseguro
                          AND cmovimi IN(45, 58)
                          AND nnumlin = c.nnumlin + 1
                          AND cesta IS NOT NULL);
                                     -- Aportación que tiene detalle (Ibex 35)
   /*
     SELECT c.cmovimi, c.ccalint, c2.fvalmov, c2.nunidad
     FROM ctaseguro c, ctaseguro c2
     WHERE c.sseguro = seguro
       AND c.cmovimi IN (2,51)
       AND 1 = (SELECT COUNT(*)
                FROM ctaseguro c3
                WHERE c3.sseguro = seguro
                  AND c3.ccalint = c.ccalint
                  AND c3.cmovimi IN (45,58)
                  AND c3.cesta IS NOT NULL) -- Aportación que tiene detalle (Ibex 35)
       AND c2.sseguro = seguro
       AND c2.cmovimi IN (45,58)
       AND c2.ccalint = c.ccalint;
     */
   BEGIN
      -- BUG 18423 - 14/12/2011 - JMP - Multimoneda
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);

      -- FIN BUG 18423 - 14/12/2011 - JMP - Multimoneda
      BEGIN
         SELECT crespue
           INTO icapibex
           FROM pregunseg
          WHERE sseguro = psseguro
            AND nriesgo = 1
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM pregunseg
                            WHERE sseguro = psseguro
                              AND nriesgo = 1
                              AND cpregun = 1013)
            AND cpregun = 1013;   -- Parte de prima a Ibex 35
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 120307;
      END;

      FOR regs IN cur_aport_ibex(psseguro) LOOP
         --v_ccalint := regs.ccalint;
         -- RSC 09/07/2008
         v_nnumlin := regs.nnumlin;
         v_fvalmov := regs.fvalmov;
         --v_nunidad := regs.nunidad;
         v_cmovimi := regs.cmovimi;

         -- RSC 09/07/2008
         SELECT nunidad
           INTO v_nunidad
           FROM ctaseguro
          WHERE sseguro = psseguro
            AND nnumlin =(v_nnumlin + 1);

         IF v_nunidad IS NOT NULL THEN
            -- Anulación de lineas de la antigua aportación
            -- Actualizamos movimiento general
            UPDATE ctaseguro
               SET imovimi = icapibex,
                   imovim2 = icapibex
             WHERE sseguro = psseguro
               --AND ccalint = v_ccalint -- RSC 09/07/2008
               AND nnumlin = v_nnumlin
               AND cesta IS NULL;

            -- RSC 09/07/2008
            UPDATE ctaseguro
               SET imovimi = icapibex,
                   imovim2 = icapibex
             WHERE sseguro = psseguro
               --AND ccalint = v_ccalint -- RSC 09/07/2008
               AND nnumlin = v_nnumlin + 1
               AND cesta IS NULL;

            -- BUG 18423 - 14/12/2011 - JMP - Multimoneda
            IF v_cmultimon = 1 THEN
               FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                             FROM ctaseguro
                            WHERE sseguro = psseguro
                              AND nnumlin IN(v_nnumlin, v_nnumlin + 1)
                              AND cesta IS NULL) LOOP
                  num_err := pac_oper_monedas.f_update_ctaseguro_monpol(reg.sseguro,
                                                                        reg.fcontab,
                                                                        reg.nnumlin,
                                                                        reg.fvalmov);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END LOOP;
            END IF;

            -- FIN BUG 18423 - 14/12/2011 - JMP - Multimoneda

            -- Ponemos la linea de detalle (mov 45 de la aportación)
            -- Actualizamos movimiento detalle
            FOR valor IN cur_segdisin2(psseguro) LOOP
               --Calcula les distribucions
               xidistrib := (icapibex * valor.pdistrec) / 100;

               BEGIN
                  SELECT iuniact
                    INTO v_iuniact
                    FROM tabvalces
                   WHERE ccesta = valor.ccesta
                     AND TRUNC(fvalor) = TRUNC(v_fvalmov);
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 180619;
               END;

               -- Actualizamos el movimiento de detalle
               IF v_cmovimi IN(1, 2, 4) THEN
                  UPDATE ctaseguro
                     SET imovimi = xidistrib,
                         imovim2 = xidistrib,
                         nunidad = xidistrib / v_iuniact
                   WHERE sseguro = psseguro
                     --AND ccalint = v_ccalint RSC 09/07/2008
                     AND nnumlin =(v_nnumlin + 1)
                     AND cesta = valor.ccesta;
               ELSIF v_cmovimi IN(51) THEN
                  UPDATE ctaseguro
                     SET imovimi = xidistrib,
                         imovim2 = xidistrib,
                         nunidad = (xidistrib / v_iuniact) * -1
                   WHERE sseguro = psseguro
                     --AND ccalint = v_ccalint -- RSC 09/07/2008
                     AND nnumlin =(v_nnumlin + 1)
                     AND cesta = valor.ccesta;
               END IF;

               -- BUG 18423 - 14/12/2011 - JMP - Multimoneda
               IF v_cmultimon = 1 THEN
                  FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                FROM ctaseguro
                               WHERE sseguro = psseguro
                                 AND nnumlin =(v_nnumlin + 1)
                                 AND cesta = valor.ccesta
                                 AND v_cmovimi IN(1, 2, 4, 51)) LOOP
                     num_err := pac_oper_monedas.f_update_ctaseguro_monpol(reg.sseguro,
                                                                           reg.fcontab,
                                                                           reg.nnumlin,
                                                                           reg.fvalmov);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END LOOP;
               END IF;
            -- FIN BUG 18423 - 14/12/2011 - JMP - Multimoneda
            END LOOP;
         ELSE
            -- Anulación de lineas de la antigua aportación
            UPDATE ctaseguro
               SET imovimi = icapibex,
                   imovim2 = icapibex
             WHERE sseguro = psseguro
               --AND ccalint = v_ccalint; -- RSC 09/07/2008
               AND nnumlin = v_nnumlin;

            -- RSC 09/07/2008
            UPDATE ctaseguro
               SET imovimi = icapibex,
                   imovim2 = icapibex
             WHERE sseguro = psseguro
               --AND ccalint = v_ccalint; -- RSC 09/07/2008
               AND nnumlin = v_nnumlin + 1;

            -- BUG 18423 - 14/12/2011 - JMP - Multimoneda
            IF v_cmultimon = 1 THEN
               FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                             FROM ctaseguro
                            WHERE sseguro = psseguro
                              AND nnumlin IN(v_nnumlin, v_nnumlin + 1)) LOOP
                  num_err := pac_oper_monedas.f_update_ctaseguro_monpol(reg.sseguro,
                                                                        reg.fcontab,
                                                                        reg.nnumlin,
                                                                        reg.fvalmov);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END LOOP;
            END IF;
         -- FIN BUG 18423 - 14/12/2011 - JMP - Multimoneda
         END IF;
      END LOOP;

      RETURN(0);
   END f_recalcular_aport_ibex;

   FUNCTION f_recalcular_lineas_saldo(psseguro IN NUMBER, pfecha IN DATE DEFAULT NULL)
      RETURN NUMBER IS
-----------------------------------------------------------------------------------------------------------
-- Función que recalcula todas las lineas de saldo con fecha valor >= fecha de alta o última renovación.
-- sólo recalcula un saldo por fecha, es decir, si hay más de un registro de saldo para la misma ffecmov
-- sólo recalcula un registro y anulará todos los de esa fecha.
-- Las líneas de saldo existentes afectadas se anularán

      -----------------------------------------------------------------------------------------------------------
      CURSOR c_lineas(par_fecha IN DATE) IS
         SELECT   ffecmov   --fcontab, nnumlin
             FROM ctaseguro
            WHERE cmovimi = 0
              AND cmovanu = 0
              AND TRUNC(fvalmov) >= TRUNC(par_fecha)
              AND sseguro = psseguro
         GROUP BY ffecmov
         ORDER BY ffecmov;

      num_err        NUMBER;
      vfecha         DATE;
      v_sproduc      NUMBER;
      -- RSC 19/05/2008
      xfefecto       DATE;
      xfrevisio      DATE;
      xfrevant       DATE;
      xndurper       NUMBER;
      vcambio        BOOLEAN := FALSE;
      -- RSC 23/05/2008
      v_sproces      NUMBER;
      verror         NUMBER;
      vtexto         VARCHAR2(200);
      perror         NUMBER;
      vnprolin       NUMBER;
      vtratadas      NUMBER := 0;
   BEGIN
      num_err := 0;

      IF pfecha IS NULL THEN
         vfecha := TO_DATE(frenovacion(NULL, psseguro, 2), 'yyyy/mm/dd');

         IF vfecha IS NULL THEN
            RETURN 180309;   -- Error al calcular la fecha de alta o renovación
         END IF;
      ELSE
         vfecha := pfecha;
      END IF;

-- RSC 26/11/2007 --------------------------------------------------------------
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      IF (NVL(f_parproductos_v(v_sproduc, 'PRODUCTO_MIXTO'), 0) = 1
          AND NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1) THEN   -- Ibex 35 Garantizado
         num_err := f_recalcular_aport_ibex(psseguro, pfecha);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

   -------------------------------------------------------------------------------
-- Modificamos las líneas de aportación como que no han contado en el saldo
-- para que las vuelva a coger
      UPDATE ctaseguro
         SET ccalint = 0
       WHERE sseguro = psseguro
         AND cmovanu = 0
         AND cmovimi <> 0
         AND TRUNC(fvalmov) >= TRUNC(vfecha);

      SELECT s.fefecto, sa.frevisio, sa.frevant, sa.ndurper
        INTO xfefecto, xfrevisio, xfrevant, xndurper
        FROM seguros s LEFT JOIN seguros_aho sa ON s.sseguro = sa.sseguro
       WHERE s.sseguro = psseguro;

      -- RSC 23/05/2008 Añadimos un LOG de las líneas recalculadas
      verror := f_procesini(getuser, f_parinstalacion_n('EMPRESADEF'), 'RECALCULA_SALDOS',
                            f_axis_literales(180844, f_idiomauser), v_sproces);

      FOR reg IN c_lineas(vfecha) LOOP
         IF xndurper IS NULL THEN
            IF reg.ffecmov = vfecha
               AND reg.ffecmov <> xfefecto THEN
               UPDATE seguros_aho
                  SET frevisio = xfrevant
                WHERE sseguro = psseguro;

               vcambio := TRUE;
            END IF;
         END IF;

         --num_err := F_INSCTA_PROV_CAP(psseguro, reg.ffecmov , 'R', null);
         UPDATE ctaseguro
            SET cmovanu = 1   -- 1 = Movimiento Anulado
          WHERE sseguro = psseguro
            AND ffecmov = reg.ffecmov
            AND cmovimi = 0
            AND cmovanu = 0;

         -- Insertamos linea de log
         vtexto := f_axis_literales(180845, f_idiomauser);
         vtexto := vtexto || ': ffecmov =' || reg.ffecmov || ' sseguro =' || psseguro;
         perror := f_proceslin(v_sproces, vtexto, psseguro, vnprolin, 2);
         vtratadas := vtratadas + 1;
         num_err := f_inscta_prov_cap(psseguro, reg.ffecmov, 'R', NULL);

         IF num_err <> 0 THEN
            EXIT;
         END IF;

         IF xndurper IS NULL THEN
            IF vcambio THEN
               UPDATE seguros_aho
                  SET frevisio = xfrevisio
                WHERE sseguro = psseguro;
            END IF;
         END IF;

         vcambio := FALSE;
      END LOOP;

      -- Finalizamos proces
      verror := f_procesfin(v_sproces, vtratadas);
      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_ctaseguro.f_recalcular_lineas_saldo', NULL,
                     'psseguro = ' || psseguro || '  pfecha = ' || pfecha, SQLERRM);
         RETURN 102537;   -- Error al modificar la tabla CTASEGURO
   END f_recalcular_lineas_saldo;

   FUNCTION f_recalcular_lineas_saldo_shw(psseguro IN NUMBER, pfecha IN DATE DEFAULT NULL)
      RETURN NUMBER IS
-----------------------------------------------------------------------------------------------------------
-- Función que recalcula todas las lineas de saldo con fecha valor >= fecha de alta o última renovación.
-- sólo recalcula un saldo por fecha, es decir, si hay más de un registro de saldo para la misma ffecmov
-- sólo recalcula un registro y anulará todos los de esa fecha.
-- Las líneas de saldo existentes afectadas se anularán

      -----------------------------------------------------------------------------------------------------------
      CURSOR c_lineas(par_fecha IN DATE) IS
         SELECT   ffecmov   --fcontab, nnumlin
             FROM ctaseguro_shadow
            WHERE cmovimi = 0
              AND cmovanu = 0
              AND TRUNC(fvalmov) >= TRUNC(par_fecha)
              AND sseguro = psseguro
         GROUP BY ffecmov
         ORDER BY ffecmov;

      num_err        NUMBER;
      vfecha         DATE;
      v_sproduc      NUMBER;
      -- RSC 19/05/2008
      xfefecto       DATE;
      xfrevisio      DATE;
      xfrevant       DATE;
      xndurper       NUMBER;
      vcambio        BOOLEAN := FALSE;
      -- RSC 23/05/2008
      v_sproces      NUMBER;
      verror         NUMBER;
      vtexto         VARCHAR2(200);
      perror         NUMBER;
      vnprolin       NUMBER;
      vtratadas      NUMBER := 0;
      vcempres       NUMBER;
   BEGIN
      num_err := 0;

      IF pfecha IS NULL THEN
         vfecha := TO_DATE(frenovacion(NULL, psseguro, 2), 'yyyy/mm/dd');

         IF vfecha IS NULL THEN
            RETURN 180309;   -- Error al calcular la fecha de alta o renovación
         END IF;
      ELSE
         vfecha := pfecha;
      END IF;

-- RSC 26/11/2007 --------------------------------------------------------------
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

-------------------------------------------------------------------------------
-- Modificamos las líneas de aportación como que no han contado en el saldo
-- para que las vuelva a coger
      UPDATE ctaseguro_shadow
         SET ccalint = 0
       WHERE sseguro = psseguro
         AND cmovanu = 0
         AND cmovimi <> 0
         AND TRUNC(fvalmov) >= TRUNC(vfecha);

      SELECT s.fefecto, sa.frevisio, sa.frevant, sa.ndurper, s.cempres
        INTO xfefecto, xfrevisio, xfrevant, xndurper, vcempres
        FROM seguros s LEFT JOIN seguros_aho sa ON s.sseguro = sa.sseguro
       WHERE s.sseguro = psseguro;

      -- RSC 23/05/2008 Añadimos un LOG de las líneas recalculadas
      verror := f_procesini(f_user, vcempres, 'RECALCULA_SALDOS_SHW',
                            f_axis_literales(180844, f_idiomauser), v_sproces);

      FOR reg IN c_lineas(vfecha) LOOP
         --num_err := F_INSCTA_PROV_CAP(psseguro, reg.ffecmov , 'R', null);
         UPDATE ctaseguro_shadow
            SET cmovanu = 1   -- 1 = Movimiento Anulado
          WHERE sseguro = psseguro
            AND ffecmov = reg.ffecmov
            AND cmovimi = 0
            AND cmovanu = 0;

         -- Insertamos linea de log
         vtexto := f_axis_literales(180845, f_idiomauser);
         vtexto := vtexto || ': ffecmov =' || reg.ffecmov || ' sseguro =' || psseguro;
         perror := f_proceslin(v_sproces, vtexto, psseguro, vnprolin, 2);
         vtratadas := vtratadas + 1;

         UPDATE ctaseguro_shadow
            SET cmovanu = 1   -- 1 = Movimiento Anulado
          WHERE sseguro = psseguro
            AND ffecmov = reg.ffecmov
            AND cmovimi = 0
            AND cmovanu = 0;

         num_err := f_inscta_prov_cap_shw(psseguro, reg.ffecmov, 'R', NULL);
         vcambio := FALSE;
      END LOOP;

      -- Finalizamos proces
      verror := f_procesfin(v_sproces, vtratadas);
      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_ctaseguro.f_recalcular_lineas_saldo_shw', NULL,
                     'psseguro = ' || psseguro || '  pfecha = ' || pfecha, SQLERRM);
         RETURN 102537;   -- Error al modificar la tabla CTASEGURO
   END f_recalcular_lineas_saldo_shw;

   FUNCTION f_restaura_frevisio_interes(psseguro IN NUMBER, pfecha IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      vfefecto       DATE;
      vpfecha        DATE;
   BEGIN
      SELECT fefecto
        INTO vfefecto
        FROM seguros
       WHERE sseguro = psseguro;

      IF pfecha IS NULL THEN
         SELECT fefecto
           INTO vpfecha
           FROM movseguro
          WHERE sseguro = psseguro
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM movseguro
                            WHERE sseguro = psseguro);
      ELSE
         vpfecha := pfecha;
      END IF;

      IF vpfecha <> vfefecto THEN
         UPDATE seguros_aho
            SET frevisio = ADD_MONTHS(frevisio, 12)
          WHERE sseguro = psseguro;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_ctaseguro.f_restaura_frevisio_interes', NULL,
                     'psseguro = ' || psseguro || '  pfecha = ' || pfecha, SQLERRM);
         RETURN 102537;   -- Error al modificar la tabla CTASEGURO
   END f_restaura_frevisio_interes;

   FUNCTION f_garan_riesgo_suspendidas(psseguro IN NUMBER)
      RETURN NUMBER IS
-----------------------------------------------------------------------------------------------------------
-- Función que indica si una póliza tiene las garantías de cobertura adicional suspendidas.
-- Dependerá de si la póliza está o no suspendida por impago o a petición del cliente.
-- Parámetros de entrada:
--    psseguro = Identificador de la póliza
-- La función devolverá:
--    0 .- no tiene garantías suspendidas
--    1 .- garantías suspendidas
-----------------------------------------------------------------------------------------------------------
   BEGIN
      -- Se mira si la póliza está suspendida a petición del cliente.
      IF pac_ctaseguro.f_esta_reducida(psseguro) = 1 THEN
         RETURN 1;   -- garantías suspendidas
      END IF;

      -- Se mira si la póliza tiene 2 recibos pendientes (impagados)
      IF f_recpen_pp(psseguro, 1) > 1 THEN
         RETURN 1;   -- garantías suspendidas
      END IF;

      RETURN 0;   -- no tiene garantías suspendidas
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_ctaseguro.f_garan_riesgo_suspendidas', NULL,
                     'psseguro = ' || psseguro, SQLERRM);
         RETURN 1;   -- garantías suspendidas
   END f_garan_riesgo_suspendidas;

   FUNCTION f_garan_suspendida(psseguro IN NUMBER, pcgarant IN NUMBER)
      RETURN NUMBER IS
-----------------------------------------------------------------------------------------------------------
-- Función que indica si garantía de una póliza está suspendida.
-- Parámetros de entrada:
--    psseguro = Identificador de la póliza
--    pcgarant = Código de la garantía
-- La función devolverá:
--    0 .- no está suspendida
--    1 .- sí está suspendida
-----------------------------------------------------------------------------------------------------------
      v_cramo        NUMBER;
      v_cmodali      NUMBER;
      v_ctipseg      NUMBER;
      v_ccolect      NUMBER;
      v_cactivi      NUMBER;
   BEGIN
      -- Bug 9685 - APD - 30/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
      -- De momento no se modifica la funcion pues no tenemos el nriesgo
      -- Bug 9685 - APD - 30/04/2009 - Fin
      SELECT cramo, cmodali, ctipseg, ccolect, cactivi
        INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi
        FROM seguros
       WHERE sseguro = psseguro;

         -- Se mira si la póliza tiene garantías suspendidas y si la garantía que se quiere comprobar es una
      -- garantía de riesgo: 'TIPO' = 6 (fallecimiento) o 'TIPO' = 7 (accidentes)
      IF NVL(f_pargaranpro_v(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi, pcgarant,
                             'TIPO'),
             0) IN(6, 7)
         AND f_garan_riesgo_suspendidas(psseguro) = 1 THEN
         RETURN 1;   -- garantías suspendidas
      END IF;

      RETURN 0;   -- no tiene garantías suspendidas
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_ctaseguro.f_garan_suspendida', NULL,
                     'psseguro = ' || psseguro || '  pcgarant = ' || pcgarant, SQLERRM);
         RETURN 1;   -- garantías suspendidas
   END f_garan_suspendida;

   -- Función llamada des de alulk028.fmb (referencia Planes de Pensiones)
   FUNCTION f_anulacion_aportacion(
      psseguro IN NUMBER,
      pctanrecibo IN NUMBER,
      paapffecmov IN DATE,
      paapfvalmov IN DATE,
      paapnnumlin IN NUMBER,
      paapimovimi IN NUMBER,
      pnrecibo IN OUT NUMBER)
      RETURN NUMBER IS
      -- ORIGINALES
      agente         NUMBER;
      -- Bug 18225 - APD - 11/04/2011 - la precisión debe ser NUMBER
      riesgo         NUMBER(8);
      delegacion     NUMBER;
      psmovagr       NUMBER(8);
      pnliqmen       NUMBER;
      pnliqlin       NUMBER;
      importe        NUMBER(25, 10);
      pccobban       NUMBER(3);
      empresa        NUMBER;
      emision        DATE;
      num_err        NUMBER;
      num_movimi     NUMBER;
      -- RSC 03/01/2008 -- Ajustes para Ibex 35 Garantizado
      vsproduc       NUMBER;
      vimovimitotal  NUMBER;
      suplemento     NUMBER;
      -- RSC 02/06/2008
      xpaapffecmov   DATE;
      xpaapfvalmov   DATE;
      pfvalor_aux    DATE;
      pffecmov_aux   DATE;
      v_cmodcom      comisionprod.cmodcom%TYPE;
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
   BEGIN
      -- RSC 03/01/2008 Obtenemos el sproduc del seguro
      SELECT sproduc, cempres
        INTO vsproduc, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);
                                 -- BUG 18423 - 14/12/2011 - JMP - Multimoneda
      -- RSC 02/06/2008 --------------------------------------------------------
      xpaapffecmov := paapffecmov;
      xpaapfvalmov := paapfvalmov;

      IF NVL(f_parproductos_v(vsproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
         -- El distinct es por Ibex 35 Garantizado que tiene dos movimientos de aportación (1)
         -- uno para la parte de Ibex 35 y otro para la parte de EUROPLAZO
         -- Bug 12426 - APD - 22/12/2009 -- si el parametro pctanrecibo is null no se debe
         -- realizar la select
         IF pctanrecibo IS NOT NULL THEN
            SELECT DISTINCT TRUNC(ffecmov), TRUNC(fvalmov)
                       INTO pffecmov_aux, pfvalor_aux
                       FROM ctaseguro
                      WHERE sseguro = psseguro
                        AND nrecibo = pctanrecibo
                        AND cesta IS NULL;
         END IF;
      ELSE
         -- Bug 12426 - APD - 22/12/2009 -- si el parametro pctanrecibo is null no se debe
         -- realizar la select
         IF pctanrecibo IS NOT NULL THEN
            SELECT ffecmov, fvalmov
              INTO pffecmov_aux, pfvalor_aux
              FROM ctaseguro
             WHERE sseguro = psseguro
               AND nrecibo = pctanrecibo;
         END IF;
      END IF;

      IF pfvalor_aux <> xpaapfvalmov THEN
         xpaapfvalmov := pfvalor_aux;
      --xpaapffecmov := pffecmov_aux;
      END IF;

--------------------------------------------------------------------------
      pnrecibo := NULL;   -- Recibo nuevo que se genera

      ----Modificamos el registro/registros que hemos anulado
      -- Bug 12426 - APD - 22/12/2009 -- si el parametro pctanrecibo is null no se debe
      -- realizar el update
      IF pctanrecibo IS NOT NULL THEN
         UPDATE ctaseguro
            SET cmovanu = 1
          WHERE sseguro = psseguro
            AND nrecibo = pctanrecibo;
      END IF;

      --**** insertamos el recibo
      SELECT ccobban, cempres, cagente, femisio
        INTO pccobban, empresa, agente, emision
        FROM seguros
       WHERE sseguro = psseguro;

      SELECT nriesgo
        INTO riesgo
        FROM riesgos
       WHERE sseguro = psseguro;

      num_err := f_buscanmovimi(psseguro, 1, 1, num_movimi);

      IF num_err <> 0 THEN
         RETURN num_err;   --Error en la funcion insrecibo
      END IF;

      -- Insertamos un nuevo recibo
      num_err := f_insrecibo(psseguro, agente, f_sysdate, xpaapfvalmov, xpaapfvalmov + 1, 9,
                             NULL, NULL, pccobban, 0, riesgo, pnrecibo, 'A', NULL, 51,
                             num_movimi, xpaapffecmov);

      IF num_err <> 0 THEN
         RETURN num_err;   --Error en la funcion insrecibo
      END IF;

      -- Bug 19777/95194 - 26/10/2011 -AMC
      IF f_es_renovacion(psseguro) = 0 THEN   -- es cartera
         v_cmodcom := 2;
      ELSE   -- si es 1 es nueva produccion
         v_cmodcom := 1;
      END IF;

      -- Insertamos el detalle del recibo (vdetrecibos)
      IF NVL(f_parproductos_v(vsproduc, 'PRODUCTO_MIXTO'), 0) = 1 THEN   -- Ibex 35 Garantizado
         SELECT SUM(imovimi)
           INTO vimovimitotal
           FROM ctaseguro
          WHERE sseguro = psseguro
            AND nrecibo = pctanrecibo
            AND cmovimi IN(1, 2, 4);

         num_err := f_detrecibo(NULL, psseguro, pnrecibo, NULL, 'A', v_cmodcom, f_sysdate,
                                xpaapfvalmov, NULL, NULL, vimovimitotal, NULL, paapnnumlin,
                                NULL, importe);
      ELSE
         num_err := f_detrecibo(NULL, psseguro, pnrecibo, NULL, 'A', v_cmodcom, f_sysdate,
                                xpaapfvalmov, NULL, NULL, paapimovimi, NULL, paapnnumlin,
                                NULL, importe);
      END IF;

      -- Fi Bug 19777/95194 - 26/10/2011 -AMC
      IF num_err <> 0 THEN
         RETURN(num_err);
      END IF;

   -- RSC 02/06/2008 --------------------------------------------------------
--xpaapffecmov := pffecmov_aux;
--------------------------------------------------------------------------

      --Se envía la emisión del recibo a la ERP
      --Bug.: 20923 - 14/01/2012 - ICV
      IF NVL(pac_parametros.f_parempresa_n(empresa, 'GESTIONA_COBPAG'), 0) = 1
         AND num_err = 0 THEN
         num_err := pac_ctrl_env_recibos.f_proc_recpag_mov(empresa, psseguro, num_movimi, 4,
                                                           NULL);
      /*--Si ha dado error
      --De momento comentado
      IF num_err <> 0 THEN
         RETURN(num_err);
      END IF;*/
      END IF;

      -- Generamos los movimientos en cuenta seguro (cobramos el recibo)
      delegacion := f_delegacion(pnrecibo, empresa, agente, emision);
      psmovagr := 0;
      num_err := f_movrecibo(pnrecibo, 1, xpaapfvalmov, 51, psmovagr, pnliqmen, pnliqlin,
                             xpaapffecmov, pccobban, delegacion, NULL, NULL, NULL,   -- pcagrpro
                             NULL,   -- pccompani
                             NULL,   -- pcempres
                             NULL,   -- pctipemp
                             NULL,   -- psseguro
                             NULL,   -- pctiprec
                             NULL,   -- pcbancar
                             NULL,   -- pnmovimi
                             NULL,   -- pcramo
                             NULL,   -- pcmodali
                             NULL,   -- pctipseg
                             NULL,   -- pccolect
                             NULL,   -- pnomovrec
                             NULL,   -- pusu_cob
                             NULL,   -- pfefecrec
                             NULL,   -- ppgasint
                             NULL,   -- ppgasext
                             NULL,   -- pcfeccob
                             0   -- pctipcob
                              );

      -- Ponemos a estado pendiente de transferir
      UPDATE recibos
         SET cestimp = 7
       WHERE nrecibo = pnrecibo;

      UPDATE ctaseguro
         SET imovimi = ABS(imovimi),
             nparpla = ABS(nparpla),
             spermin = NULL,
             ctipapor = NULL,
             --fvalmov = xpaapfvalmov,
             ffecmov = xpaapffecmov
       WHERE nrecibo = pnrecibo
         AND sseguro = psseguro;

      UPDATE ctaseguro
         SET imovimi = ABS(imovimi),
             nparpla = ABS(nparpla),
             spermin = NULL,
             ctipapor = NULL,
             --fvalmov = xpaapfvalmov,
             ffecmov = xpaapffecmov
       WHERE nnumlin = paapnnumlin + 1   -- linea de saldo
         AND sseguro = psseguro;

      IF num_err <> 0 THEN
         RETURN(num_err);
      END IF;

      -- BUG 18423 - 14/12/2011 - JMP - Multimoneda
      IF v_cmultimon = 1 THEN
         FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                       FROM ctaseguro
                      WHERE sseguro = psseguro
                        AND(nrecibo = pnrecibo
                            OR nnumlin = paapnnumlin + 1)) LOOP
            num_err := pac_oper_monedas.f_update_ctaseguro_monpol(reg.sseguro, reg.fcontab,
                                                                  reg.nnumlin, reg.fvalmov);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END LOOP;
      END IF;

      -- FIN BUG 18423 - 14/12/2011 - JMP - Multimoneda
      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_ctaseguro.f_anulacion_aportacion', NULL,
                     'psseguro = ' || psseguro || ' pctanrecibo = ' || pctanrecibo
                     || ' paapffecmov = ' || paapffecmov || ' paapfvalmov = ' || paapfvalmov
                     || ' paapnnumlin = ' || paapnnumlin || ' paapimovimi = ' || paapimovimi,
                     SQLERRM);
         RETURN 108190;   -- f_anulacion_aportacion
   END f_anulacion_aportacion;

   FUNCTION f_anulacion_aportacion_shw(
      psseguro IN NUMBER,
      pctanrecibo IN NUMBER,
      paapffecmov IN DATE,
      paapfvalmov IN DATE,
      paapnnumlin IN NUMBER,
      paapimovimi IN NUMBER,
      pnrecibo IN OUT NUMBER)
      RETURN NUMBER IS
      -- ORIGINALES
      agente         NUMBER;
      -- Bug 18225 - APD - 11/04/2011 - la precisión debe ser NUMBER
      riesgo         NUMBER(8);
      delegacion     NUMBER;
      psmovagr       NUMBER(8);
      pnliqmen       NUMBER;
      pnliqlin       NUMBER;
      importe        NUMBER(25, 10);
      pccobban       NUMBER(3);
      empresa        NUMBER;
      emision        DATE;
      num_err        NUMBER;
      num_movimi     NUMBER;
      -- RSC 03/01/2008 -- Ajustes para Ibex 35 Garantizado
      vsproduc       NUMBER;
      vimovimitotal  NUMBER;
      suplemento     NUMBER;
      -- RSC 02/06/2008
      xpaapffecmov   DATE;
      xpaapfvalmov   DATE;
      pfvalor_aux    DATE;
      pffecmov_aux   DATE;
      v_cmodcom      comisionprod.cmodcom%TYPE;
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
   BEGIN
      -- RSC 03/01/2008 Obtenemos el sproduc del seguro
      SELECT sproduc, cempres
        INTO vsproduc, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);
                                 -- BUG 18423 - 14/12/2011 - JMP - Multimoneda
      -- RSC 02/06/2008 --------------------------------------------------------
      xpaapffecmov := paapffecmov;
      xpaapfvalmov := paapfvalmov;

      IF NVL(f_parproductos_v(vsproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
         -- El distinct es por Ibex 35 Garantizado que tiene dos movimientos de aportación (1)
         -- uno para la parte de Ibex 35 y otro para la parte de EUROPLAZO
         -- Bug 12426 - APD - 22/12/2009 -- si el parametro pctanrecibo is null no se debe
         -- realizar la select
         IF pctanrecibo IS NOT NULL THEN
            SELECT DISTINCT TRUNC(ffecmov), TRUNC(fvalmov)
                       INTO pffecmov_aux, pfvalor_aux
                       FROM ctaseguro_shadow
                      WHERE sseguro = psseguro
                        AND nrecibo = pctanrecibo
                        AND cesta IS NULL;
         END IF;
      ELSE
         -- Bug 12426 - APD - 22/12/2009 -- si el parametro pctanrecibo is null no se debe
         -- realizar la select
         IF pctanrecibo IS NOT NULL THEN
            SELECT ffecmov, fvalmov
              INTO pffecmov_aux, pfvalor_aux
              FROM ctaseguro_shadow
             WHERE sseguro = psseguro
               AND nrecibo = pctanrecibo;
         END IF;
      END IF;

      IF pfvalor_aux <> xpaapfvalmov THEN
         xpaapfvalmov := pfvalor_aux;
      --xpaapffecmov := pffecmov_aux;
      END IF;

      ----Modificamos el registro/registros que hemos anulado
      -- Bug 12426 - APD - 22/12/2009 -- si el parametro pctanrecibo is null no se debe
      -- realizar el update
      IF pctanrecibo IS NOT NULL THEN
         UPDATE ctaseguro_shadow
            SET cmovanu = 1
          WHERE sseguro = psseguro
            AND nrecibo = pctanrecibo;
      END IF;

      UPDATE ctaseguro_shadow
         SET imovimi = ABS(imovimi),
             nparpla = ABS(nparpla),
             spermin = NULL,
             ctipapor = NULL,
             --fvalmov = xpaapfvalmov,
             ffecmov = xpaapffecmov
       WHERE nrecibo = pnrecibo
         AND sseguro = psseguro;

      UPDATE ctaseguro_shadow
         SET imovimi = ABS(imovimi),
             nparpla = ABS(nparpla),
             spermin = NULL,
             ctipapor = NULL,
             --fvalmov = xpaapfvalmov,
             ffecmov = xpaapffecmov
       WHERE nnumlin = paapnnumlin + 1   -- linea de saldo
         AND sseguro = psseguro;

      IF num_err <> 0 THEN
         RETURN(num_err);
      END IF;

      -- BUG 18423 - 14/12/2011 - JMP - Multimoneda
      IF v_cmultimon = 1 THEN
         FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                       FROM ctaseguro_shadow
                      WHERE sseguro = psseguro
                        AND(nrecibo = pnrecibo
                            OR nnumlin = paapnnumlin + 1)) LOOP
            num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(reg.sseguro,
                                                                      reg.fcontab,
                                                                      reg.nnumlin,
                                                                      reg.fvalmov);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END LOOP;
      END IF;

      -- FIN BUG 18423 - 14/12/2011 - JMP - Multimoneda
      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_ctaseguro.f_anulacion_aportacion_shw', NULL,
                     'psseguro = ' || psseguro || ' pctanrecibo = ' || pctanrecibo
                     || ' paapffecmov = ' || paapffecmov || ' paapfvalmov = ' || paapfvalmov
                     || ' paapnnumlin = ' || paapnnumlin || ' paapimovimi = ' || paapimovimi,
                     SQLERRM);
         RETURN 108190;   -- f_anulacion_aportacion
   END f_anulacion_aportacion_shw;

      /*************************************************************************
     FUNCTION f_suma_aportacio
     param in psseguro  : codi assegurança
     return             : suma aportació

        Bug 12101 - 30/11/2009 - NMM.i.
   *************************************************************************/
   FUNCTION f_suma_aportacio(p_sseguro IN VARCHAR2)
      RETURN VARCHAR2 IS
      w_suma_aportacio VARCHAR2(100);
   --
   BEGIN
      SELECT TO_CHAR(SUM(DECODE(cmovimi,
                                1, imovimi,
                                2, imovimi,
                                3, imovimi,
                                4, imovimi,
                                8, imovimi,
                                10, imovimi,
                                -imovimi)),
                     'FM999G999G999G990D00')
        INTO w_suma_aportacio
        FROM ctaseguro
       WHERE sseguro = p_sseguro
         AND cmovimi IN(1, 2, 3, 4, 8, 10, 33, 32, 34, 47, 51, 53);

      --RETURN(TO_CHAR(w_suma_aportacio, 'FM999G999G999G990D00'));
      RETURN(w_suma_aportacio);
   --
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('0,00');
   END f_suma_aportacio;

   ---- 30/11/2009.NMM.f.12101: CRE084 - Añadir rentabilidad en consulta de pólizas.

   /*************************************************************************
      Impresió llibretad d'estalvi
      param in  pcempres:       codi d'empresa
      param in  psseguro:       sseguro de la pòlissa
      param in  pnpoliza:       npoliza de la pòlissa
      param in  pncertif:       ncertif de la pòlissa
      param in  pnpolcia:       número de pòlissa de la companyia
      param in  pvalsaldo:      flag per indicar si cal realitzar validació de saldo
      param in  pisaldo:        saldo del moviment de llibreta a partir del qual se vol imprimir (per validacions).
      param in  pcopcion:       opció d'impressió
                                    1 -> Actualització de registres pendents
                                    2 -> Reimpressió a partir de número de seqüència
                                    3 -> Reimpressió i Impressió de registres pendents   15/07/2010#XPL#Bug.15422
      param in  pnseq:          número de seqüència a partir del qual realitzar la reimpressió (opció d'impressió 2)
      param in  pfrimpresio     Data a partir del qual realitzar la reimpressió (opció d'impressió 2)
      param in  pnmov           número de moviments a retornar (-1 vol dir tots)
      param in  orden           ordenació de la llista
                                    0 -> fcontab
                                    1 -> fvalmov
                                    2 -> fefecmov
      param in  pcidioma        idioma de les descripcions de moviments de llibreta
      param out pcur_reg_lib    cursor/llista de moviments de llibreta impressos
      return                    0/numerr -> Tot OK/error
   *************************************************************************/
   FUNCTION f_imprimir_libreta(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnpolcia IN VARCHAR2,
      pvalsaldo IN NUMBER,
      pisaldo IN NUMBER,
      pcopcion IN NUMBER,
      pnseq IN NUMBER,
      pfrimpresio IN DATE,
      pnmov IN NUMBER,
      porden IN NUMBER,
      pcidioma IN NUMBER,
      literalretorno OUT VARCHAR2,
      pcur_reg_lib OUT sys_refcursor)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_CTASEGURO.f_imprimir_libreta';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro: ' || psseguro || ' - pnpoliza: ' || pnpoliza
            || ' - pncertif: ' || pncertif || ' - pnpolcia: ' || pnpolcia || ' - pvalsaldo: '
            || pvalsaldo || ' - pisaldo: ' || pisaldo || ' - pcopcion: ' || pcopcion
            || ' - pnseq: ' || pnseq || ' - pfrimpresio: ' || pfrimpresio || ' - pnmov: '
            || pnmov || ' - porden: ' || porden || ' - pcidioma: ' || pcidioma;
      vpasexec       NUMBER(8) := 1;
      vnumerr        NUMBER(8) := 0;

      CURSOR cr_cta_libreta(
         vcr_sseguro IN NUMBER,
         vcr_fdate IN DATE,
         vcr_opcion IN NUMBER,
         vcr_nseq IN NUMBER,
         vcr_frimpresio IN DATE,
         vcr_orden IN NUMBER) IS
         SELECT   cta.sseguro, cta.fcontab, cta.nnumlin, cta.ffecmov, cta.fvalmov,
                  cta.cmovimi, cta.imovimi, DECODE(cta.cmovimi, 0, cta.imovimi, 0) saldo,
                  cta_lib.ccapgar, cta_lib.ccapfal, cta_lib.nnumlib, cta_lib.fimpres
             FROM ctaseguro cta, ctaseguro_libreta cta_lib
            WHERE cta.sseguro = vcr_sseguro
              AND cta.sseguro = cta_lib.sseguro
              AND cta.fcontab = cta_lib.fcontab
              AND cta.nnumlin = cta_lib.nnumlin
              AND TRUNC(cta.fcontab) <= TRUNC(vcr_fdate)
              AND((vcr_opcion IN(2, 3)
--15/07/2010#XPL#Bug.15422, s'afegeix opció 3, per tal que agafi tant pendents com no
                   AND cta_lib.fimpres IS NOT NULL
                   AND((NVL(cta_lib.nnumlib, vcr_nseq) >= vcr_nseq)
                       OR(DECODE(cmovimi, 0, TRUNC(cta.fvalmov), TRUNC(cta.fcontab)) >=
                                                                          TRUNC(vcr_frimpresio))))
                  OR(vcr_opcion IN(1, 3)
-- 15/07/2010#XPL#Bug.15422, s'afegeix opció 3, per tal que agafi tant pendents com no
                     AND cta_lib.nnumlib IS NULL))
         ORDER BY DECODE(vcr_orden,
                         -- Bug 13692 - JRH - 16/03/2010 - Nuevo orden en la libreta

                         --0, DECODE(cta.cmovimi, 0, cta.fvalmov, TRUNC(cta.fcontab)),
                          -- Bug 15485 - JRH - 22/07/2010 - 0015485: CEM805 - Ordenación de la llibreta en la consulta de pólizas
                         0, DECODE(cta.cmovimi,
                                   0, cta.fvalmov,
                                   2, cta.fvalmov,
                                   53, cta.fvalmov,
                                   TRUNC(cta.fcontab)),
                         -- Fi Bug 15485 - JRH - 22/07/2010

                         -- Fi Bug 13692 - JRH - 16/03/2010
                         1, cta.fvalmov,
                         2, cta.ffecmov) ASC,
                  nnumlin ASC;

      vsseguro       seguros.sseguro%TYPE;
      vnpoliza       seguros.npoliza%TYPE;
      vncertif       seguros.ncertif%TYPE;
      vnpolcia       VARCHAR2(100);
      vnnumlinb      ctaseguro_libreta.nnumlib%TYPE;
      visaldo        ctaseguro_libreta.ccapgar%TYPE;
      vfirst_nnumlib ctaseguro_libreta.nnumlib%TYPE;
      vlast_nnumlib  ctaseguro_libreta.nnumlib%TYPE;
      vlast_nnumlib_imp ctaseguro_libreta.nnumlib%TYPE;
      vnumreg        NUMBER(8);
   BEGIN
      IF (psseguro IS NULL
          AND pnpoliza IS NULL
          AND pnpolcia IS NULL)
         OR pcempres IS NULL
         OR pvalsaldo IS NULL
         OR(pvalsaldo IS NOT NULL
            AND pisaldo IS NULL)
         OR(pcopcion IS NULL
            OR(pcopcion = 2
               AND pnseq IS NULL
               AND pfrimpresio IS NULL))
         OR porden IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vsseguro := psseguro;
      vnpoliza := pnpoliza;
      vncertif := NVL(pncertif, 0);
      vnpolcia := pnpolcia;

      --Si s'invoca la funció amb número de pòlissa de companyia, obtenim el número de pòlissa AXIS.
      IF pnpolcia IS NOT NULL THEN
         vnpoliza := pac_propio.f_extrae_npoliza(vnpolcia, pcempres);
         vncertif := 0;

         IF vnpoliza IS NULL THEN
            RETURN 9900866;
         END IF;
      END IF;

      vpasexec := 5;

      --Si tenim el número de pòlissa AXIS, obtenim el sseguro per poder treballar contra els apunts de llibreta.
      IF vnpoliza IS NOT NULL
         AND vncertif IS NOT NULL THEN
         vnumerr := pac_seguros.f_get_sseguro(vnpoliza, vncertif, 'POL', vsseguro);

         IF vnumerr <> 0 THEN
            RETURN 100500;   -- Poliza inexistente
         END IF;
      END IF;

      vpasexec := 7;

      --Si es tracta d'una re-impressió de llibreta, comprovem que hi hagi moviments per re-imprimir.
      IF pcopcion = 2 THEN
         BEGIN
            SELECT MAX(cta_lib.nnumlib)
              INTO vlast_nnumlib
              FROM ctaseguro_libreta cta_lib
             WHERE cta_lib.sseguro = vsseguro
               AND cta_lib.fimpres IS NOT NULL
               AND((pnseq IS NOT NULL
                    AND pfrimpresio IS NULL
                    AND nnumlib = pnseq)
                   OR(pnseq IS NULL
                      AND pfrimpresio IS NOT NULL
                      AND fcontab >= TRUNC(pfrimpresio)));
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 9900867;   --El moviment de llibreta no existeix.
         END;

         IF vlast_nnumlib IS NULL THEN
            RETURN 9900867;
         END IF;
      END IF;

      vpasexec := 9;

      --Validació saldo llibreta (si aplica)
      IF pvalsaldo <> 0 THEN
         BEGIN
            SELECT NVL(imovimi, 0)
              INTO visaldo
              FROM ctaseguro
             WHERE sseguro = vsseguro
               AND nnumlin = (SELECT MAX(cta.nnumlin)
                                FROM ctaseguro cta
                               WHERE cta.sseguro = vsseguro
                                 AND cta.cmovimi = 0
                                 AND((pcopcion IN(2, 3)
                                      --15/07/2010#XPL#Bug.15422,validant es comporta com si fos opció 2
                                      AND(cta.nnumlin <=
                                             (SELECT NVL(nnumlin, 0)
                                                FROM ctaseguro_libreta
                                               WHERE sseguro = cta.sseguro
                                                 AND nnumlib = NVL(pnseq, -1)
                                                 AND pfrimpresio IS NULL)
                                          OR cta.nnumlin <=
                                               (SELECT MAX(NVL(nnumlin, 0))
                                                  FROM ctaseguro
                                                 WHERE sseguro = cta.sseguro
                                                   AND DECODE(cmovimi, 0, fvalmov, fcontab) <=
                                                                             TRUNC(pfrimpresio)
                                                   AND pnseq IS NULL)))
                                     OR(pcopcion = 1
                                        AND cta.nnumlin =
                                              (SELECT MAX(cta_lib2.nnumlin)
                                                 FROM ctaseguro_libreta cta_lib2,
                                                      ctaseguro cta2
                                                WHERE cta2.sseguro = cta.sseguro
                                                  AND cta2.cmovimi = 0
                                                  AND cta2.sseguro = cta_lib2.sseguro
                                                  AND cta2.fcontab = cta_lib2.fcontab
                                                  AND cta2.nnumlin = cta_lib2.nnumlin
                                                  AND cta_lib2.fimpres IS NOT NULL
                                                  AND cta_lib2.nnumlib IS NOT NULL))));
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               visaldo := 0;
         END;

         vpasexec := 11;

         --Validació del saldo
         IF pisaldo <> visaldo THEN
            literalretorno := f_axis_literales(9900868) || '('
                              || LTRIM(TO_CHAR(visaldo, '9G999G990D00')) || ')';
            RETURN 9900868;   --Saldo incorrecte.
         END IF;
      END IF;

      vpasexec := 13;

      --Obtenim l'últim número de linea de llibreta impresa
      SELECT NVL(MAX(cta_lib.nnumlib), 0)
        INTO vlast_nnumlib
        FROM ctaseguro_libreta cta_lib
       WHERE cta_lib.sseguro = vsseguro
         AND cta_lib.fimpres IS NOT NULL;

      vpasexec := 11;
      vnumreg := 0;
      vfirst_nnumlib := 0;

      FOR cr IN cr_cta_libreta(vsseguro, f_sysdate, pcopcion, pnseq, pfrimpresio, porden) LOOP
         vpasexec := 15;

         IF pnmov IS NOT NULL
            AND vnumreg >= pnmov THEN
            EXIT;
         END IF;

         vnumreg := vnumreg + 1;

         IF cr.nnumlib IS NULL THEN
            UPDATE ctaseguro_libreta
               SET nnumlib = vlast_nnumlib + 1,
                   fimpres = f_sysdate
             WHERE sseguro = cr.sseguro
               AND nnumlin = cr.nnumlin
               AND fcontab = cr.fcontab;

            IF vfirst_nnumlib = 0 THEN
               vfirst_nnumlib := vlast_nnumlib + vnumreg;
               vlast_nnumlib := vfirst_nnumlib;
            ELSE
               vlast_nnumlib := vlast_nnumlib + 1;
            END IF;
         ELSE
            UPDATE ctaseguro_libreta
               SET sreimpre = 1,
                   fimpres = f_sysdate
             WHERE sseguro = cr.sseguro
               AND nnumlin = cr.nnumlin
               AND fcontab = cr.fcontab;

            IF vfirst_nnumlib = 0 THEN
               vfirst_nnumlib := cr.nnumlib;
               vlast_nnumlib := vfirst_nnumlib;
            ELSE
               vlast_nnumlib := vlast_nnumlib + 1;
            END IF;
         END IF;
      END LOOP;

      vpasexec := 21;

      IF vfirst_nnumlib = 0 THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(9900869));
         RETURN 9900869;   --Error no hi ha registres per imprimir.
      END IF;

      COMMIT;
      vpasexec := 23;

      OPEN pcur_reg_lib FOR 'SELECT   s.cagente, cta.sseguro, DECODE(cta.cmovimi, 0, cta.fvalmov, cta.fcontab) fcontab, cta.nnumlin, cta.ffecmov, cta.fvalmov, cta.cmovimi, d.tatribu,
                                 cta.imovimi, decode(cta.cmovimi,0,cta.imovimi,0) saldo, cta_lib.ccapgar, cta_lib.ccapfal, cta_lib.nnumlib, cta_lib.fimpres
                            FROM seguros s, ctaseguro cta, ctaseguro_libreta cta_lib, detvalores d
                           WHERE s.sseguro = '
                            || vsseguro
                            || '
                             AND s.sseguro = cta.sseguro
                             AND cta.sseguro = cta_lib.sseguro
                             AND cta.fcontab = cta_lib.fcontab
                             AND cta.nnumlin = cta_lib.nnumlin
                             AND cta_lib.nnumlib >= '
                            || vfirst_nnumlib
                            || '
                             AND cta_lib.nnumlib <= ' || vlast_nnumlib
                            || '
                             AND d.cvalor = 83
                             AND cta.cmovimi = d.catribu
                             AND d.cidioma = '
                            || pcidioma
                            || '
                        ORDER BY cta_lib.nnumlib ASC';

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(1000005));

         IF pcur_reg_lib%ISOPEN THEN
            CLOSE pcur_reg_lib;
         END IF;

         ROLLBACK;
         RETURN 1000005;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(1000006));

         IF pcur_reg_lib%ISOPEN THEN
            CLOSE pcur_reg_lib;
         END IF;

         ROLLBACK;
         RETURN 1000006;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);

         IF pcur_reg_lib%ISOPEN THEN
            CLOSE pcur_reg_lib;
         END IF;

         ROLLBACK;
         RETURN 100500;   --Poliza inexistente
   END f_imprimir_libreta;

    -- Bug 12426 - APD - 21/12/2009 - se crea la funcion f_anula_linea_ctaseguro
   /*************************************************************************
       Funcion que anulará una linea en ctasseguro
       param in psseguro  : póliza
       param in pfcontab  : fecha contable
       param in pnnumlin  : Número de línea de ctaseguro
       return             : 0 si todo ha ido bien o 1 si ha habido algún error
    *************************************************************************/
   FUNCTION f_anula_linea_ctaseguro(
      psseguro IN NUMBER,
      pfcontab IN DATE,
      pnnumlin IN NUMBER,
      pcidioma IN NUMBER,
      pnrecibo OUT NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;
      vcmovimi       ctaseguro.cmovimi%TYPE;
      vcmovanu       ctaseguro.cmovanu%TYPE;
      vfvalmov       ctaseguro.fvalmov%TYPE;
      vfvalmovshw    ctaseguro_shadow.fvalmov%TYPE;
      vnrecibo       ctaseguro.nrecibo%TYPE;
      vsrecren       ctaseguro.srecren%TYPE;
      vimovimi       ctaseguro.imovimi%TYPE;
      vimovimishw    ctaseguro_shadow.imovimi%TYPE;
      vcsituac       seguros.csituac%TYPE;
      vsproduc       seguros.sproduc%TYPE;
      num_linea      NUMBER;
      num_lineashw   NUMBER;
      vimovimitotal  NUMBER;
      vimovimitotalshw NUMBER;
      vffecmov       pagosrenta.ffecpag%TYPE;
      vtmovimi       VARCHAR2(100);
      vtmovanu       VARCHAR2(100);
      vnrecibo_out   ctaseguro.nrecibo%TYPE;
   BEGIN
      SELECT cmovimi, cmovanu, fvalmov, nrecibo, srecren, imovimi
        INTO vcmovimi, vcmovanu, vfvalmov, vnrecibo, vsrecren, vimovimi
        FROM ctaseguro
       WHERE sseguro = psseguro
         AND fcontab = pfcontab
         AND nnumlin = pnnumlin;

      IF f_tiene_ctashadow(psseguro, NULL) = 1 THEN
         SELECT fvalmov, imovimi
           INTO vfvalmovshw, vimovimishw
           FROM ctaseguro_shadow
          WHERE sseguro = psseguro
            AND fcontab = pfcontab
            AND nnumlin = pnnumlin;
      END IF;

      SELECT csituac, sproduc
        INTO vcsituac, vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      IF (vcmovimi IN(1, 2, 4)
                              /*OR(vcmovimi = 53
                                 AND vsrecren IS NOT NULL)*/
         )
-- se elimina la validacion NRECIBO IS NOT NULL porque sino no funciona con los datos migrados
         AND vcmovanu = 0 THEN
         -- CMOVIMI : 1 = Aportación Extraordinaria, 2 = Aportación Periódica, 4 =
         IF vcsituac <> 0 THEN
            RETURN 101483;   -- La póliza está anulada.
         END IF;
      ELSE
         RETURN 180693;
      -- Anulación no permitida para este tipo de movimiento
      END IF;

      -----------Calculamos el número de línea----------------------------------
      BEGIN
         SELECT MAX(nnumlin)
           INTO num_linea
           FROM ctaseguro
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      num_linea := NVL(num_linea + 1, 1);

      IF f_tiene_ctashadow(psseguro, NULL) = 1 THEN
         BEGIN
            SELECT MAX(nnumlin)
              INTO num_lineashw
              FROM ctaseguro_shadow
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         num_lineashw := NVL(num_lineashw + 1, 1);
      END IF;

      -----------Calculamos el texto del código de movimiento---------------------
      IF vcmovimi = 53 THEN
         num_err := f_desvalorfijo(83, pcidioma, 10, vtmovimi);
         num_err := f_desvalorfijo(86, pcidioma, vcmovanu, vtmovanu);
      ELSE
         num_err := f_desvalorfijo(83, pcidioma, 51, vtmovimi);
         num_err := f_desvalorfijo(86, pcidioma, vcmovanu, vtmovanu);
      END IF;

      -----------Calculamos el resto de valores necesarios para insertar en ctaseguro---------------------
      IF vcmovimi = 53
         AND vsrecren IS NOT NULL THEN   --Buscamos la fecha en la anulaciónde pagos de renta
         SELECT ffecpag
           INTO vffecmov
           FROM pagosrenta
          WHERE srecren = vsrecren;
      ELSE
         vffecmov := f_sysdate;
      END IF;

      IF NVL(f_parproductos_v(vsproduc, 'PRODUCTO_MIXTO'), 0) = 1 THEN   -- Ibex 35 Garantizado
         SELECT SUM(imovimi)
           INTO vimovimitotal
           FROM ctaseguro
          WHERE sseguro = psseguro
            AND nrecibo = vnrecibo
            AND cmovimi IN(1, 2, 4);

         vimovimi := vimovimitotal;

         IF f_tiene_ctashadow(psseguro, NULL) = 1 THEN
            SELECT SUM(imovimi)
              INTO vimovimitotalshw
              FROM ctaseguro_shadow
             WHERE sseguro = psseguro
               AND nrecibo = vnrecibo
               AND cmovimi IN(1, 2, 4);

            vimovimishw := vimovimitotalshw;
         END IF;
      ELSE
         vimovimi := vimovimi;
         vimovimishw := vimovimishw;
      END IF;

      -----------Se anula la linea en ctaseguro---------------------
      IF (vcmovimi = 53
          AND vsrecren IS NOT NULL) THEN   --Si es el pago de una renta
         num_err := pk_rentas.anula_rec(vffecmov, psseguro, vsrecren);
      ELSE   --lo que se hacía hasta ahora
         num_err := pac_ctaseguro.f_anulacion_aportacion(psseguro, vnrecibo, vffecmov,
                                                         vfvalmov, num_linea, vimovimi,
                                                         vnrecibo_out);

         IF f_tiene_ctashadow(psseguro, NULL) = 1 THEN
            num_err := pac_ctaseguro.f_anulacion_aportacion_shw(psseguro, vnrecibo, vffecmov,
                                                                vfvalmov, num_lineashw,
                                                                vimovimishw, vnrecibo_out);
         END IF;
      END IF;

      IF num_err = 0 THEN
         IF vnrecibo IS NULL THEN   --Migracion. Nos aseguramos que anulamos el mov.
            UPDATE ctaseguro
               SET cmovanu = 1
             WHERE sseguro = psseguro
               AND fcontab = pfcontab
               AND nnumlin = pnnumlin;

            IF f_tiene_ctashadow(psseguro, NULL) = 1 THEN
               UPDATE ctaseguro_shadow
                  SET cmovanu = 1
                WHERE sseguro = psseguro
                  AND fcontab = pfcontab
                  AND nnumlin = pnnumlin;
            END IF;
         END IF;

         COMMIT;
         pnrecibo := vnrecibo_out;
         RETURN 0;
      ELSE
         ROLLBACK;
         RETURN num_err;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'pac_ctaseguro.f_anula_linea_ctaseguro', NULL,
                     'psseguro = ' || psseguro || ' pfcontab = ' || pfcontab || ' pnnumlin = '
                     || pnnumlin,
                     SQLERRM);
         RETURN 108190;   -- Error general
   END f_anula_linea_ctaseguro;

   --Ini Bug.: 0012555 - ICV - 16/02/2010 - CEM002 - Interficie per apertura de llibretes
   FUNCTION f_imprimir_portada_libreta(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnpolcia IN VARCHAR2,
      pcidioma IN NUMBER,
      ptproducto OUT VARCHAR2,
      pnnumide OUT VARCHAR2,
      ptnombre OUT VARCHAR2)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_CTASEGURO.f_imprimir_portada_libreta';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro: ' || psseguro || ' - pnpoliza: ' || pnpoliza
            || ' - pcidioma: ' || pcidioma || ' - pncertif: ' || pncertif || ' - pnpolcia: '
            || pnpolcia;
      vpasexec       NUMBER(8) := 1;
      vnumerr        NUMBER(8) := 0;

      CURSOR cr_cta_portada_nombre(vcr_sseguro IN NUMBER) IS
         SELECT per_personas.nnumide,
                per_detper.tnombre || ' ' || per_detper.tapelli1 || ' '
                || per_detper.tapelli2 titular,
                titulopro.ttitulo, per_detper.cagente
           FROM tomadores, ctaseguro, per_detper, per_personas, titulopro, productos, seguros
          WHERE tomadores.sseguro = seguros.sseguro
            AND per_personas.sperson = tomadores.sperson
            AND per_detper.sperson = per_personas.sperson
            AND per_detper.cagente = ff_agente_cpervisio(seguros.cagente, NULL, pcempres)
            AND titulopro.cramo = productos.cramo
            AND titulopro.cmodali = productos.cmodali
            AND titulopro.ctipseg = productos.ctipseg
            AND titulopro.ccolect = productos.ccolect
            AND seguros.sproduc = productos.sproduc
            AND seguros.sseguro = ctaseguro.sseguro(+)
            AND titulopro.cidioma = pcidioma
            AND seguros.sseguro = vcr_sseguro;

      vsseguro       seguros.sseguro%TYPE;
      --Faltaba declarar las variables
      vnpoliza       seguros.npoliza%TYPE;
      vncertif       seguros.ncertif%TYPE;
      vnpolcia       VARCHAR2(100);
   BEGIN
      IF (psseguro IS NULL
          AND pnpoliza IS NULL
          AND pnpolcia IS NULL) THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vsseguro := psseguro;
      vnpoliza := pnpoliza;
      vncertif := NVL(pncertif, 0);
      vnpolcia := pnpolcia;

      --Si s'invoca la funció amb número de pòlissa de companyia, obtenim el número de pòlissa AXIS.
      IF pnpolcia IS NOT NULL THEN
         vnpoliza := pac_propio.f_extrae_npoliza(vnpolcia, pcempres);
         vncertif := 0;

         IF vnpoliza IS NULL THEN
            RETURN 9900866;
         END IF;
      END IF;

      vpasexec := 5;

      --Si tenim el número de pòlissa AXIS, obtenim el sseguro per poder treballar contra els apunts de llibreta.
      IF vnpoliza IS NOT NULL
         AND vncertif IS NOT NULL THEN
         vnumerr := pac_seguros.f_get_sseguro(vnpoliza, vncertif, 'POL', vsseguro);

         IF vnumerr <> 0 THEN
            RETURN 100500;
         END IF;
      END IF;

      vpasexec := 7;
      vpasexec := 13;
      vpasexec := 11;

      FOR cr IN cr_cta_portada_nombre(vsseguro) LOOP
         vpasexec := 15;
         ptproducto := cr.ttitulo;
         pnnumide := cr.nnumide;
         ptnombre := cr.titular;
         EXIT;   -- nos basta el primer registro
      END LOOP;

      vpasexec := 21;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(1000005));

--Faltaba cambiar nombre
         IF cr_cta_portada_nombre%ISOPEN THEN
            CLOSE cr_cta_portada_nombre;
         END IF;

         ROLLBACK;
         RETURN 1000005;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(1000006));

         IF cr_cta_portada_nombre%ISOPEN THEN
            CLOSE cr_cta_portada_nombre;
         END IF;

         ROLLBACK;
         RETURN 1000006;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);

         IF cr_cta_portada_nombre%ISOPEN THEN
            CLOSE cr_cta_portada_nombre;
         END IF;

         ROLLBACK;
         RETURN 9900869;   --Error imprimint llibreta
   END f_imprimir_portada_libreta;

--Fin Bug.: 0012555

   -- BUG 12278 -  09/2010 - JRH  - 0012278: Proceso de PB para el producto PEA.

   -- BUG 12278 -  09/2010 - JRH  - 0012278: Proceso de PB para el producto PEA.
   /*
   -- Bug 0029943 - 11/06/2014 - JTT: Modificamos la funcion para llamar las funciones
        f_insrecibo
        f_insdetrec
        f_vdetrecibos
        f_emision_pagorec
      para generar y enviar el recibo manual
   */
   FUNCTION f_genera_recibo(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pfproces IN DATE,
      pfperini IN DATE,
      pfperfin IN DATE,
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pimporte IN NUMBER,
      pcidioma IN NUMBER,
      pnmovimi IN NUMBER,
      pctipopago IN NUMBER,
      pnrecibo OUT NUMBER,
      psproduc NUMBER,
      pctipopu NUMBER)
      RETURN NUMBER IS
      vtobjeto       VARCHAR2(500) := 'PAC_CTASEGURO.f_genera_recibo';
      vparam         VARCHAR2(500)
         := ' psseguro:' || psseguro || ' - ' || ' pimporte:' || pimporte || ' - '
            || ' pcidioma:' || pcidioma || ' - ' || ' pfproces:'
            || TO_CHAR(pfproces, 'DD/MM/YYYY') || ' pctipopu: ' || pctipopu;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      e_error        EXCEPTION;
      num_err        NUMBER;
      wnmovimi       NUMBER;
      wnrecibo       NUMBER;
      aux            NUMBER;
      wcdelega       NUMBER;
      wsmovagr       NUMBER;
      wliqmen        NUMBER;
      wliqlin        NUMBER;
      vcgarantfin    garanpro.cgarant%TYPE;
      v_cmodcom      comisionprod.cmodcom%TYPE;
      vsmovrec       NUMBER;
      vsubfi         VARCHAR2(500);
      ss             VARCHAR2(500);
      v_cursor       INTEGER;
      v_ttippag      NUMBER;
      v_filas        INTEGER;
      vtipo          VARCHAR2(20);
      vctipreb       NUMBER;
      vterminal      usuarios.cterminal%TYPE;
      vpsinterf      NUMBER;
      vemitido       NUMBER;
      verror_pago    VARCHAR2(500);
   BEGIN
      wnrecibo := NULL;
      vpasexec := 2;
      wnmovimi := pnmovimi;

      SELECT ctipreb
        INTO vctipreb
        FROM seguros
       WHERE sseguro = psseguro;

      IF vctipreb = 4 THEN
         vtipo := 'CERTIF0';
      ELSIF vctipreb = 3 THEN
         vtipo := 'SI';
      END IF;

      vpasexec := 3;

      -- 29943 - 29/04/2014 - JTT: Si el tipo de PB es 5
      IF pctipopu = 5 THEN
         vtipo := NULL;
      END IF;

      num_err := f_insrecibo(psseguro, NULL, f_sysdate, pfperini, pfperfin, pctipopago, NULL,
                             NULL, NULL, 0, NULL, wnrecibo, 'R', NULL, NULL, wnmovimi,
                             f_sysdate, vtipo);
      vpasexec := 4;

      IF num_err <> 0 THEN
         RAISE e_error;
      ELSE
         vpasexec := 5;

         BEGIN
            SELECT g.cgarant
              INTO vcgarantfin
              FROM seguros s, garanpro g
             WHERE s.sseguro = psseguro
               AND g.sproduc = s.sproduc
               AND g.cactivi = pcactivi
               AND NVL(f_pargaranpro_v(g.cramo, g.cmodali, g.ctipseg, g.ccolect,
                                       NVL(s.cactivi, 0), g.cgarant, 'TIPO'),
                       0) = 12;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := 105710;

               -- Garantía no encontrada en la tabla GARANPRO
               IF num_err <> 0 THEN
                  RAISE e_error;
               END IF;
         END;
      END IF;

      -- Bug 19777/95194 - 26/10/2011 -AMC
      IF f_es_renovacion(psseguro) = 0 THEN   -- es cartera
         v_cmodcom := 2;
      ELSE   -- si es 1 es nueva produccion
         v_cmodcom := 1;
      END IF;

      -- Generamos el detalle - DETRECIBOS
      vpasexec := 6;
      num_err := f_insdetrec(wnrecibo, 0, pimporte, 100, vcgarantfin, 1, 0, NULL, wnmovimi, 0,
                             psseguro, 1, NULL, NULL, NULL, NULL);

      IF num_err <> 0 THEN
         RAISE e_error;
      END IF;

      -- Generamos el total del detalle - VDETRECIBOS
      vpasexec := 7;
      num_err := f_vdetrecibos('R', wnrecibo, psproces);

      IF num_err <> 0 THEN
         RAISE e_error;
      END IF;

      -- Si todo ha ido bien lo enviamos al SAP
      vpasexec := 8;

      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'GESTIONA_COBPAG'), 0) = 1 THEN
         num_err := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vterminal);
         vpsinterf := NULL;
         num_err := pac_con.f_emision_pagorec(pcempres, 1, 4, wnrecibo, NULL, vterminal,
                                              vemitido, vpsinterf, verror_pago, f_user, NULL,
                                              NULL, NULL, 1);

         IF num_err <> 0
            OR TRIM(verror_pago) IS NOT NULL THEN
            IF num_err = 0 THEN
               num_err := 9903116;
            END IF;

            RAISE e_error;
         END IF;
      END IF;

      pnrecibo := wnrecibo;
      RETURN 0;
   EXCEPTION
      WHEN e_error THEN
         p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec, num_err,
                     f_axis_literales(num_err));
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vtobjeto, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 140999;   --Error no controlado
   END f_genera_recibo;

   /************************************************************************
      f_cierrePB
         Proceso de inserción de la PB en CTASEGURO

       Parámetros Entrada:

           psmodo : Modo ('P'revio, 'R'eal, 'A' Reproceso PB)
           pfecha : Fecha Cálculo
           pcidioma: Idioma
           pcempresa: Empresa
           pcagrpro: Agrupación
           psproduc: Producto
           psseguro: Seguro
           psprcpb: Numero de proceso anterior de calculo de la PB


       Parámetros Salida:
           psproces: Proceso
           pindice : Pólizas que han ido bien
           pindice_error : Pólizas que han ido mal

       retorna 0 si ha ido todo bien o código de error en caso contrario
   *************************************************************************/
   FUNCTION f_cierrepb(
      psmodo IN VARCHAR2,
      pfecha IN DATE,
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      pcagrpro IN NUMBER,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      psproces OUT NUMBER,
      pindice OUT NUMBER,
      pindice_error OUT NUMBER,
      psprcpb IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      --
      CURSOR polizas IS
         SELECT   sseguro, cbancar, ctipban, sproduc, NVL(fcarpro, pfecha) fcarpro, s.cactivi,
                  s.cidioma, ncertif, s.npoliza   -- MMS
             FROM seguros s
            WHERE ((s.sproduc = psproduc
                    AND psproduc IS NOT NULL)
                   OR(psproduc IS NULL))
              --AND s.fefecto < pfecha
              AND s.cempres = pcempres
              -- AND s.sseguro = 23378
              AND((s.cagrpro = pcagrpro
                   AND pcagrpro IS NOT NULL)
                  OR(pcagrpro IS NULL))
              AND((s.sseguro = psseguro
                   AND psseguro IS NOT NULL)
                  OR(psseguro IS NULL))
              AND(s.fvencim > pfecha
                  OR s.fvencim IS NULL)
              AND f_situacion_v(s.sseguro, pfecha) = 1
              AND s.fefecto < pfecha + 1
              AND EXISTS(SELECT 1
                           FROM garanpro c
                          WHERE c.sproduc = s.sproduc
                            AND f_pargaranpro_v(c.cramo, c.cmodali, c.ctipseg, c.ccolect,
                                                c.cactivi, c.cgarant, 'TIPO') = 12)   --Tipo PB
              AND EXISTS(SELECT 1
                           FROM garanformula g
                          WHERE g.cramo = s.cramo
                            AND g.cmodali = s.cmodali
                            AND g.ctipseg = s.ctipseg
                            AND g.ccolect = s.ccolect
                            AND g.cactivi = s.cactivi
                            AND g.ccampo = 'IPARTBEN')   --Tipo PB
              AND(
                  -- 29943: Tipo de PB <> 5 y certificados <> 0
                  ((NVL(f_parproductos_v(s.sproduc, 'TIPO_PB'), 0) IN(4, 7))
                   AND((NVL(f_parproductos_v(s.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 0)
                       OR((NVL(f_parproductos_v(s.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1)
                          AND(ncertif <> 0))))   -- MMS (20130604) Admite Certificados
                  -- 29943: Tipo de PB = 5 + certificado 0
                  OR((NVL(f_parproductos_v(s.sproduc, 'TIPO_PB'), 0) = 5)
                     AND((NVL(f_parproductos_v(s.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 0)
                         OR((NVL(f_parproductos_v(s.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1)
                            AND(ncertif = 0)))))
         ORDER BY s.npoliza;

      -- 29943 - 07/04/2014 - JTT: Duplicamos el cursor añadiendo la tabla ADM_PROCESO_PU con las PU pendientes de procesar
      CURSOR polizas_no_procesadas IS
         SELECT   s.sseguro, cbancar, ctipban, sproduc, NVL(fcarpro, pfecha) fcarpro,
                  s.cactivi, s.cidioma, s.ncertif, s.npoliza, app.sproces, app.nriesgo,
                  app.nmovimi, app.fefecto, app.fcalcul
             FROM seguros s, adm_proceso_pu app
            WHERE ((s.sproduc = psproduc
                    AND psproduc IS NOT NULL)
                   OR(psproduc IS NULL))
              AND s.cempres = pcempres
              AND((s.cagrpro = pcagrpro
                   AND pcagrpro IS NOT NULL)
                  OR(pcagrpro IS NULL))
              AND((s.sseguro = psseguro
                   AND psseguro IS NOT NULL)
                  OR(psseguro IS NULL))
              AND(s.fvencim > pfecha
                  OR s.fvencim IS NULL)
              AND f_situacion_v(s.sseguro, pfecha) = 1
              AND s.fefecto < pfecha + 1
              AND app.sseguro = s.sseguro
              AND app.fcalcul <= pfecha
              AND app.sproces = psprcpb
              AND app.cestado = 0
              AND EXISTS(SELECT 1
                           FROM garanpro c
                          WHERE c.sproduc = s.sproduc
                            AND f_pargaranpro_v(c.cramo, c.cmodali, c.ctipseg, c.ccolect,
                                                c.cactivi, c.cgarant, 'TIPO') = 12)
              AND EXISTS(SELECT 1
                           FROM garanformula g
                          WHERE g.cramo = s.cramo
                            AND g.cmodali = s.cmodali
                            AND g.ctipseg = s.ctipseg
                            AND g.ccolect = s.ccolect
                            AND g.cactivi = s.cactivi
                            AND g.ccampo = 'IPARTBEN')
              AND(
                  -- 29943: Tipo de PB <> 5 y certificados <> 0
                  ((NVL(f_parproductos_v(s.sproduc, 'TIPO_PB'), 0) IN(4, 7))
                   AND((NVL(f_parproductos_v(s.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 0)
                       OR((NVL(f_parproductos_v(s.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1)
                          AND(ncertif <> 0))))
                  -- 29943: Tipo de PB = 5 + certificado 0
                  OR((NVL(f_parproductos_v(s.sproduc, 'TIPO_PB'), 0) = 5)
                     AND((NVL(f_parproductos_v(s.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 0)
                         OR((NVL(f_parproductos_v(s.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1)
                            AND(ncertif = 0)))))
         ORDER BY s.npoliza;

      CURSOR c_rec_env(vsproces NUMBER) IS
         SELECT DISTINCT (ctipopago)
                    FROM estado_proc_recibos e, recibos r
                   WHERE e.cestado = 0
                     AND e.sproces = vsproces
                     AND r.nrecibo = e.npago
                     AND e.ctipopago = 4
                     AND r.cestaux <> 2;

      reg            polizas%ROWTYPE;
      reg_adm        polizas_no_procesadas%ROWTYPE;
      verrparms      EXCEPTION;
      verrproc       EXCEPTION;
      i              NUMBER := 0;
      l              NUMBER := 0;
      vtexto         VARCHAR2(1000);
      vtitulo        VARCHAR2(1000);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := ' psmodo= ' || psmodo || 'pfecha= ' || TO_CHAR(pfecha, 'DD/MM/YYYY')
            || 'pcidioma= ' || pcidioma || 'pcempres= ' || pcempres || 'pcagrpro= ' || pcagrpro
            || 'psproduc= ' || psproduc || 'psseguro= ' || psseguro || '  ';
      vobject        VARCHAR2(200) := 'PAC_CTASEGURO.f_cierrePB';
      vnum_err       NUMBER := 0;
      verr           NUMBER := 0;
      vnumlin        ctaseguro.nnumlin%TYPE;
      vnumlinshw     ctaseguro_shadow.nnumlin%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      pnok           NUMBER;
      pnko           NUMBER;
      v_lista        t_lista_id := t_lista_id();
      vfechauso      DATE;
      vncertif       NUMBER;
      v_tipopb       NUMBER;
      v_cmovimi      ctaseguro.cmovimi%TYPE;
      v_iuniacts     NUMBER;
      v_iuniacts_shw NUMBER;
      v_signo        NUMBER;
      xnnumlin       ctaseguro.nnumlin%TYPE;
      xnnumlinshw    ctaseguro_shadow.nnumlin%TYPE;
   BEGIN
      IF psmodo IS NULL
         OR pcidioma IS NULL
         OR pcempres IS NULL
         OR pfecha IS NULL THEN
         vnum_err := 103135;
         RAISE verrparms;
      END IF;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);
      -- BUG 18423 - 29/12/2011 - JMP - Multimoneda
      vpasexec := 2;
      vnum_err := f_desvalorfijo(54, pcidioma, TO_NUMBER(TO_CHAR(pfecha, 'mm')), vtexto);

      IF vnum_err <> 0 THEN
         RAISE verrproc;
      END IF;

      vpasexec := 3;

      IF psmodo = 'P' THEN   -- previo del cierre
         vtitulo := 'Previo cierre PB de ' || vtexto || ' Prod. Ahorro';

         DELETE      adm_proceso_pu_previo
               WHERE fcalcul = pfecha
                 AND ctipopu IN(4, 5, 7);
      ELSIF psmodo = 'A' THEN   -- Reproceso de PBs
         vtitulo := 'Reproceso cierre PB de ' || vtexto || ' Prod. Ahorro';
      ELSE
         vtitulo := 'Cierre PB de ' || vtexto || ' Prod. Ahorro';
      END IF;

      IF pcagrpro IS NOT NULL THEN
         vtitulo := vtitulo || ' Agrupació: ' || pcagrpro;
      END IF;

      IF psproduc IS NOT NULL THEN
         vtitulo := vtitulo || ' Producto: ' || psproduc;
      END IF;

      IF psseguro IS NOT NULL THEN
         vtitulo := vtitulo || ' Póliza: ' || psseguro;
      END IF;

      vpasexec := 4;
      vnum_err := f_procesini(f_user, pcempres, 'CIERRE_PB', vtitulo, psproces);

      IF vnum_err <> 0 THEN
         vnum_err := 109388;
         RAISE verrproc;
      END IF;

      i := 0;
      l := 0;
      vpasexec := 5;

      -- 29943 - 07/04/2014 - JTT: Si el modo es 'A' usamos el cursor polizas_no_procesadas
      IF psmodo IN('A') THEN
         OPEN polizas_no_procesadas;
      ELSE
         OPEN polizas;
      END IF;

      LOOP
         IF psmodo IN('A') THEN
            FETCH polizas_no_procesadas
             INTO reg_adm;

            EXIT WHEN polizas_no_procesadas%NOTFOUND;
            reg.sseguro := reg_adm.sseguro;
            reg.cbancar := reg_adm.cbancar;
            reg.ctipban := reg_adm.ctipban;
            reg.sproduc := reg_adm.sproduc;
            reg.fcarpro := reg_adm.fcarpro;
            reg.cactivi := reg_adm.cactivi;
            reg.cidioma := reg_adm.cidioma;
            reg.ncertif := reg_adm.ncertif;
            reg.ncertif := reg_adm.ncertif;
            vfechauso := reg_adm.fcalcul;
         ELSE
            FETCH polizas
             INTO reg;

            EXIT WHEN polizas%NOTFOUND;
         END IF;

         -- Recuperamos el TIPO de PB del producto.
         v_tipopb := f_parproductos_v(reg.sproduc, 'TIPO_PB');
         --FOR reg IN polizas LOOP
         l := l + 1;

         DECLARE
            v_cgarant      NUMBER;
            vimppb         NUMBER;
            vnumerr        NUMBER := 0;
            vnmovimi       NUMBER;
            verrorsup      EXCEPTION;
            vtexto         VARCHAR2(500);
            vnum_lin       NUMBER;
            vfechasup      DATE;
            vnrecibo       NUMBER;
            v_nmovimi      NUMBER;
            vacumpercent   NUMBER := 0;
            vimport        NUMBER := 0;
            vacumrounded   NUMBER := 0;
            v_cestas       NUMBER;
         BEGIN
            vpasexec := 6;
            vimppb := pac_provmat_formul.f_calcul_formulas_provi(reg.sseguro,
                                                                 NVL(vfechauso, pfecha),
                                                                 'IPARTBEN');

            IF vimppb IS NULL THEN
               vnumerr := 120193;
               RAISE verrorsup;
            END IF;

            vpasexec := 7;

            --Buscamos la cobertura de tipo PB
            SELECT (g.cgarant), s.ncertif
              INTO v_cgarant, vncertif
              FROM garanpro g, seguros s
             WHERE g.sproduc = s.sproduc
               AND g.cramo = s.cramo
               AND g.cmodali = s.cmodali
               AND g.ctipseg = s.ctipseg
               AND g.ccolect = s.ccolect
               AND g.cactivi = s.cactivi
               AND f_pargaranpro_v(g.cramo, g.cmodali, g.ctipseg, g.ccolect, g.cactivi,
                                   g.cgarant, 'TIPO') = 12
               AND s.sseguro = reg.sseguro;

            vpasexec := 8;

            IF v_cgarant IS NULL THEN
               vnumerr := 105812;
               RAISE verrorsup;
            END IF;

            IF (NVL(vimppb, 0) > 0)
               OR(NVL(vimppb, 0) < 0
                  AND NVL(f_parproductos_v(reg.sproduc, 'BONUS_NEG'), 0) = 1) THEN
               --
               IF NVL(vimppb, 0) < 0
                  AND NVL(f_parproductos_v(reg.sproduc, 'BONUS_NEG'), 0) = 1 THEN
                  v_cmovimi := 39;
                  v_signo := -1;
               ELSE
                  v_cmovimi := 9;
                  v_signo := 1;
               END IF;

               IF psmodo IN('R', 'A') THEN
                  -- Para el modo real generamos el suplemento con el importe de la PB calculado anteriormente.
                  IF NVL(f_parproductos_v(reg.sproduc, 'GEN_MOV_PB'), 0) = 1 THEN
                     --De momento el riesgo vale 1
                     vpasexec := 9;

                     --vfechasup := TRUNC(GREATEST(reg.fcarpro, pfecha));
                     SELECT MAX(fefecto)
                       INTO vfechasup
                       FROM movseguro
                      WHERE sseguro = reg.sseguro;

                     vfechasup := TRUNC(GREATEST(vfechasup, NVL(vfechauso, pfecha)));

                     SELECT NVL(MAX(nnumlin), 0)
                       INTO vnumlin
                       FROM ctaseguro
                      WHERE sseguro = reg.sseguro;

                     --Para determinar el movimiento
                     IF f_tiene_ctashadow(reg.sseguro, NULL) = 1 THEN
                        SELECT NVL(MAX(nnumlin), 0)
                          INTO vnumlinshw
                          FROM ctaseguro_shadow
                         WHERE sseguro = reg.sseguro;
                     --Para determinar el movimiento
                     END IF;

                     IF NVL(pac_parametros.f_parproducto_n(reg.sproduc, 'ADMITE_CERTIFICADOS'),
                            0) = 1
                        AND vncertif = 0 THEN
                        vnumerr := pac_sup_general.f_suplemento_pu(reg.sseguro,
                                                                   NVL(reg_adm.nriesgo, 1),
                                                                   vfechasup, 556, v_cgarant,
                                                                   vimppb, FALSE, vnmovimi,
                                                                   psproces);
                     ELSE
                        vnumerr := pac_call.f_suplemento_garant(reg.sseguro, 1, vfechasup,
                                                                vimppb, reg.ctipban,
                                                                reg.cbancar, v_cgarant,
                                                                vnmovimi);
                     END IF;

                     IF vnumerr <> 0 THEN
                        RAISE verrorsup;
                     END IF;

                     IF NVL(pac_mdpar_productos.f_get_parproducto('ES_APORT_EXTRAOR',
                                                                  reg.sproduc),
                            0) = 0 THEN
                        IF (NVL(vimppb, 0) > 0)
                           OR(NVL(vimppb, 0) < 0
                              AND NVL(f_parproductos_v(reg.sproduc, 'BONUS_NEG'), 0) = 1) THEN
                           UPDATE ctaseguro c
                              SET ffecmov = TRUNC(NVL(vfechauso, pfecha)),
                                  fvalmov = TRUNC(NVL(vfechauso, pfecha))
                            WHERE c.sseguro = reg.sseguro
                              AND c.cmovimi = v_cmovimi
                              AND c.cmovanu <> 1
                              AND c.fvalmov = vfechasup
                              AND c.nnumlin > vnumlin;

                           IF SQL%ROWCOUNT <> 1 THEN
                              vnumerr := 102537;
                              RAISE verrorsup;
                           END IF;

                           IF f_tiene_ctashadow(reg.sseguro, NULL) = 1 THEN
                              UPDATE ctaseguro_shadow c
                                 SET ffecmov = TRUNC(NVL(vfechauso, pfecha)),
                                     fvalmov = TRUNC(NVL(vfechauso, pfecha))
                               WHERE c.sseguro = reg.sseguro
                                 AND c.cmovimi = v_cmovimi
                                 AND c.cmovanu <> 1
                                 AND c.fvalmov = vfechasup
                                 AND c.nnumlin > vnumlinshw;
                           END IF;

                           -- BUG 18423 - 29/12/2011 - JMP - Multimoneda
                           IF v_cmultimon = 1 THEN
                              FOR reg1 IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                             FROM ctaseguro
                                            WHERE sseguro = reg.sseguro
                                              AND cmovimi = v_cmovimi
                                              AND cmovanu <> 1
                                              AND fvalmov = vfechasup
                                              AND nnumlin > vnumlin) LOOP
                                 vnumerr :=
                                    pac_oper_monedas.f_update_ctaseguro_monpol(reg1.sseguro,
                                                                               reg1.fcontab,
                                                                               reg1.nnumlin,
                                                                               reg1.fvalmov);

                                 IF vnumerr <> 0 THEN
                                    RAISE verrorsup;
                                 END IF;
                              END LOOP;

                              IF f_tiene_ctashadow(reg.sseguro, NULL) = 1 THEN
                                 FOR reg1 IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                                                FROM ctaseguro_shadow
                                               WHERE sseguro = reg.sseguro
                                                 AND cmovimi = v_cmovimi
                                                 AND cmovanu <> 1
                                                 AND fvalmov = vfechasup
                                                 AND nnumlin > vnumlinshw) LOOP
                                    vnumerr :=
                                       pac_oper_monedas.f_update_ctaseguro_shw_monpol
                                                                                (reg1.sseguro,
                                                                                 reg1.fcontab,
                                                                                 reg1.nnumlin,
                                                                                 reg1.fvalmov);

                                    IF vnumerr <> 0 THEN
                                       RAISE verrorsup;
                                    END IF;
                                 END LOOP;
                              END IF;
                           END IF;
                        END IF;
                     -- FIN BUG 18423 - 29/12/2011 - JMP - Multimoneda
                     ELSE
                        vnumerr := f_genera_recibo(pcempres, psproces, NVL(vfechauso, pfecha),
                                                   vfechasup, vfechasup + 1, reg.sseguro,
                                                   reg.cactivi, vimppb, reg.cidioma, vnmovimi,
                                                   13, vnrecibo, reg.sproduc,
                                                   NVL(f_parproductos_v(reg.sproduc,
                                                                        'TIPO_PB'),
                                                       0));

                        IF vnumerr <> 0 THEN
                           RAISE verrorsup;
                        END IF;

                        --SHA BUG 26559 - 166938 : 20/02/2014
                        UPDATE ctaseguro c
                           SET nrecibo = vnrecibo
                         WHERE c.sseguro = reg.sseguro
                           AND c.cmovimi = v_cmovimi
                           AND c.cmovanu <> 1
                           AND c.fvalmov = vfechasup
                           AND c.nnumlin > vnumlin;

                        IF f_tiene_ctashadow(reg.sseguro, NULL) = 1 THEN
                           UPDATE ctaseguro_shadow c
                              SET nrecibo = vnrecibo
                            WHERE c.sseguro = reg.sseguro
                              AND c.cmovimi = v_cmovimi
                              AND c.cmovanu <> 1
                              AND c.fvalmov = vfechasup
                              AND c.nnumlin > vnumlinshw;
                        END IF;
                     --SHA BUG 26559 - 166938 : 20/02/2014
                     END IF;

                     vpasexec := 10;
                  ELSE
                     vpasexec := 11;

                     -- Miramos si tiene distribución por cestas.
                     SELECT COUNT(1)
                       INTO v_cestas
                       FROM segdisin2 s
                      WHERE s.sseguro = reg.sseguro
                        AND s.ffin IS NULL
                        AND s.nmovimi = (SELECT MAX(s1.nmovimi)
                                           FROM segdisin2 s1
                                          WHERE s1.sseguro = reg.sseguro
                                            AND s1.ffin IS NULL);

                     vpasexec := 111;

                     IF v_cestas <> 0 THEN
                        vpasexec := 112;

                        -- Si tiene distribución por cestas, distribuimos el valor dela IMPPB
                        FOR ces IN (SELECT s.ccesta, s.pdistrec
                                      FROM segdisin2 s
                                     WHERE s.sseguro = reg.sseguro
                                       AND s.ffin IS NULL
                                       AND s.nmovimi =
                                             (SELECT MAX(s1.nmovimi)
                                                FROM segdisin2 s1
                                               WHERE s1.sseguro = reg.sseguro
                                                 AND s1.ffin IS NULL)) LOOP
                           vpasexec := 113;

                           BEGIN
                              -- RSC 18/03/2008 (ultimo valor lo cogemos de tabvalces)
                              -- Tarea 31548/206135 Management expenses
                              SELECT NVL(iuniact, 0), NVL(iuniactvtashw, NVL(iuniact, 0))
                                INTO v_iuniacts, v_iuniacts_shw
                                FROM tabvalces
                               WHERE ccesta = ces.ccesta
                                 AND TRUNC(fvalor) =
                                       TRUNC(NVL(vfechauso, pfecha))
                                       + pac_md_fondos.f_get_diasdep(ces.ccesta);
                           EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                 p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                                             'No hay valor liquidativo para la fecha.', 50);
                                 v_iuniacts := 0;
                                 v_iuniacts_shw := 0;
                           END;

                           --Calcula les distribucions
                           vacumpercent := vacumpercent + vimppb *(ces.pdistrec / 100);
                           vimport := ROUND(vacumpercent - vacumrounded, 2);
                           vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);
                           vpasexec := 114;

                           IF v_iuniacts = 0 THEN
                              vnumerr :=
                                 pac_ctaseguro.f_insctaseguro
                                                       (reg.sseguro, f_sysdate, NULL,   --nvl(xnnumlin,0)+1,
                                                        TRUNC(NVL(vfechauso, pfecha)),
                                                        TRUNC(NVL(vfechauso, pfecha)),
                                                        v_cmovimi,   --pcmovimi, Part. Beneficios
                                                        vimport, vimport, NULL, 0, 0, NULL,
                                                        NULL, '1', 'R', psproces, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        ces.ccesta);

                              IF vnumerr <> 0 THEN
                                 RAISE verrorsup;
                              END IF;
                           ELSE
                              xnnumlin := pac_ctaseguro.f_numlin_next(reg.sseguro);

                              INSERT INTO ctaseguro
                                          (sseguro, fcontab, nnumlin,
                                           ffecmov,
                                           fvalmov, cmovimi, imovimi,
                                           imovim2, nrecibo, ccalint, cmovanu, nsinies,
                                           smovrec, cesta,
                                           nunidad, cestado, fasign)
                                   VALUES (reg.sseguro, f_sysdate, xnnumlin,
                                           TRUNC(NVL(vfechauso, pfecha)),
                                           TRUNC(NVL(vfechauso, pfecha)), v_cmovimi, vimport,
                                           NULL, NULL, 0, 0, NULL,
                                           NULL, ces.ccesta,
                                           v_signo *(ABS(vimport) / v_iuniacts), '2', f_sysdate);

                              -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                              IF v_cmultimon = 1 THEN
                                 vnumerr :=
                                    pac_oper_monedas.f_update_ctaseguro_monpol
                                                                       (reg.sseguro,
                                                                        TRUNC(f_sysdate),
                                                                        xnnumlin,
                                                                        TRUNC(NVL(vfechauso,
                                                                                  pfecha)));

                                 IF vnumerr <> 0 THEN
                                    RAISE verrorsup;
                                 END IF;
                              END IF;

                              INSERT INTO ctaseguro_libreta
                                          (sseguro, nnumlin, fcontab, ccapgar, ccapfal,
                                           nmovimi, sintbatch, nnumlib, igasext, igasint,
                                           ipririe)
                                   VALUES (reg.sseguro, xnnumlin, f_sysdate, NULL, NULL,
                                           NULL, NULL, NULL, NULL, NULL,
                                           NULL);
                           END IF;

                           vpasexec := 115;

                           IF f_tiene_ctashadow(reg.sseguro, NULL) = 1 THEN
                              vpasexec := 116;

                              IF v_iuniacts_shw = 0 THEN
                                 vnumerr :=
                                    pac_ctaseguro.f_insctaseguro_shw
                                                       (reg.sseguro, f_sysdate, NULL,   --nvl(xnnumlin,0)+1,
                                                        TRUNC(NVL(vfechauso, pfecha)),
                                                        TRUNC(NVL(vfechauso, pfecha)),
                                                        v_cmovimi,   --pcmovimi, Part. Beneficios
                                                        vimport, vimport, NULL, 0, 0, NULL,
                                                        NULL, '1', 'R', psproces, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        ces.ccesta);

                                 IF vnumerr <> 0 THEN
                                    RAISE verrorsup;
                                 END IF;
                              ELSE
                                 xnnumlinshw := pac_ctaseguro.f_numlin_next_shw(reg.sseguro);

                                 INSERT INTO ctaseguro_shadow
                                             (sseguro, fcontab, nnumlin,
                                              ffecmov,
                                              fvalmov, cmovimi,
                                              imovimi, imovim2, nrecibo, ccalint, cmovanu,
                                              nsinies, smovrec, cesta,
                                              nunidad, cestado,
                                              fasign)
                                      VALUES (reg.sseguro, f_sysdate, xnnumlinshw,
                                              TRUNC(NVL(vfechauso, pfecha)),
                                              TRUNC(NVL(vfechauso, pfecha)), v_cmovimi,
                                              vimport, NULL, NULL, 0, 0,
                                              NULL, NULL, ces.ccesta,
                                              v_signo *(ABS(vimport) / v_iuniacts_shw), '2',
                                              f_sysdate);

                                 -- BUG 18423 - 15/12/2011 - JMP - Multimoneda
                                 IF v_cmultimon = 1 THEN
                                    vnumerr :=
                                       pac_oper_monedas.f_update_ctaseguro_shw_monpol
                                                                       (reg.sseguro,
                                                                        TRUNC(f_sysdate),
                                                                        xnnumlinshw,
                                                                        TRUNC(NVL(vfechauso,
                                                                                  pfecha)));

                                    IF vnumerr <> 0 THEN
                                       RAISE verrorsup;
                                    END IF;
                                 END IF;

                                 INSERT INTO ctaseguro_libreta_shw
                                             (sseguro, nnumlin, fcontab, ccapgar, ccapfal,
                                              nmovimi, sintbatch, nnumlib, igasext, igasint,
                                              ipririe)
                                      VALUES (reg.sseguro, xnnumlinshw, f_sysdate, NULL, NULL,
                                              NULL, NULL, NULL, NULL, NULL,
                                              NULL);
                              END IF;
                           END IF;
                        END LOOP;
                     ELSE
                        vpasexec := 117;
                        vnumerr :=
                           pac_ctaseguro.f_insctaseguro
                                                       (reg.sseguro, TRUNC(f_sysdate), NULL,   --nvl(xnnumlin,0)+1,
                                                        TRUNC(NVL(vfechauso, pfecha)),
                                                        TRUNC(NVL(vfechauso, pfecha)),
                                                        v_cmovimi,   --pcmovimi, Part. Beneficios
                                                        vimppb, vimppb, NULL, 0, 0, NULL,
                                                        NULL, '1', 'R', psproces, NULL, NULL,
                                                        NULL);

                        IF vnumerr <> 0 THEN
                           RAISE verrorsup;
                        END IF;

                        vpasexec := 118;

                        IF f_tiene_ctashadow(reg.sseguro, NULL) = 1 THEN
                           vnumerr :=
                              pac_ctaseguro.f_insctaseguro_shw
                                                       (reg.sseguro, TRUNC(f_sysdate), NULL,   --nvl(xnnumlin,0)+1,
                                                        TRUNC(NVL(vfechauso, pfecha)),
                                                        TRUNC(NVL(vfechauso, pfecha)),
                                                        v_cmovimi,   --pcmovimi, Part. Beneficios
                                                        vimppb, vimppb, NULL, 0, 0, NULL,
                                                        NULL, '1', 'R', psproces, NULL, NULL,
                                                        NULL);

                           IF vnumerr <> 0 THEN
                              RAISE verrorsup;
                           END IF;
                        END IF;
                     END IF;

                     vpasexec := 12;

                     --SHA BUG 26559 - 166938 : 20/02/2014
                     --Aqui nos vamos a petar la ctaseguro_previo para este mes
                     --(lo hago dentro del bucle porque si se va por exception no quiero dejarme de borrarlas)
                     DELETE      ctaseguro_previo
                           WHERE sseguro = reg.sseguro
                             AND nnumlin = vnumlin
                             AND TO_CHAR(fcontab, 'mmyyyy') =
                                                      TO_CHAR(NVL(vfechauso, pfecha), 'mmyyyy');

                     IF f_tiene_ctashadow(reg.sseguro, NULL) = 1 THEN
                        DELETE      ctaseguro_previo_shw
                              WHERE sseguro = reg.sseguro
                                AND nnumlin = vnumlinshw
                                AND TO_CHAR(fcontab, 'mmyyyy') =
                                                      TO_CHAR(NVL(vfechauso, pfecha), 'mmyyyy');
                     END IF;
                  --SHA BUG 26559 - 166938 : 20/02/2014
                  END IF;
               ELSIF psmodo = 'P' THEN
                  --Para el previo insertamos en CTASEGURO_PREVIO con el importe de la PB calculado anteriormente.
                  vpasexec := 13;

                  -- Miramos si tiene distribución por cestas.
                  SELECT COUNT(1)
                    INTO v_cestas
                    FROM segdisin2 s
                   WHERE s.sseguro = reg.sseguro
                     AND s.ffin IS NULL
                     AND s.nmovimi = (SELECT MAX(s1.nmovimi)
                                        FROM segdisin2 s1
                                       WHERE s1.sseguro = reg.sseguro
                                         AND s1.ffin IS NULL);

                  vpasexec := 131;

                  IF v_cestas <> 0 THEN
                     vpasexec := 132;

                     -- Si tiene distribución por cestas, distribuimos el valor dela IMPPB
                     FOR ces IN (SELECT s.ccesta, s.pdistrec
                                   FROM segdisin2 s
                                  WHERE s.sseguro = reg.sseguro
                                    AND s.ffin IS NULL
                                    AND s.nmovimi =
                                           (SELECT MAX(s1.nmovimi)
                                              FROM segdisin2 s1
                                             WHERE s1.sseguro = reg.sseguro
                                               AND s1.ffin IS NULL)) LOOP
                        vpasexec := 133;

                        BEGIN
                           -- RSC 18/03/2008 (ultimo valor lo cogemos de tabvalces)
                           -- Tarea 31548/206135 Management expenses
                           SELECT NVL(iuniact, 0), NVL(iuniactvtashw, NVL(iuniact, 0))
                             INTO v_iuniacts, v_iuniacts_shw
                             FROM tabvalces
                            WHERE ccesta = ces.ccesta
                              AND TRUNC(fvalor) =
                                    TRUNC(NVL(vfechauso, pfecha))
                                    + pac_md_fondos.f_get_diasdep(ces.ccesta);
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                                          'No hay valor liquidativo para la fecha.', 50);
                              v_iuniacts := 0;
                              v_iuniacts_shw := 0;
                        END;

                        --Calcula les distribucions
                        vacumpercent := vacumpercent + vimppb *(ces.pdistrec / 100);
                        vimport := ROUND(vacumpercent - vacumrounded, 2);
                        vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);
                        vpasexec := 134;

                        IF v_iuniacts = 0 THEN
                           vnumerr :=
                              pac_ctaseguro.f_insctaseguro
                                                       (reg.sseguro, f_sysdate, NULL,   --nvl(xnnumlin,0)+1,
                                                        TRUNC(NVL(vfechauso, pfecha)),
                                                        TRUNC(NVL(vfechauso, pfecha)),
                                                        v_cmovimi,   --pcmovimi, Part. Beneficios
                                                        vimport, vimport, NULL, 0, 0, NULL,
                                                        NULL, '1', 'P', psproces, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        ces.ccesta);

                           IF vnumerr <> 0 THEN
                              RAISE verrorsup;
                           END IF;
                        ELSE
                           xnnumlin := pac_ctaseguro.f_numlin_next(reg.sseguro);

                           INSERT INTO ctaseguro_previo
                                       (sseguro, fcontab, nnumlin,
                                        ffecmov,
                                        fvalmov, cmovimi, imovimi,
                                        imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec,
                                        cesta, nunidad, cestado,
                                        fasign)
                                VALUES (reg.sseguro, f_sysdate, xnnumlin,
                                        TRUNC(NVL(vfechauso, pfecha)),
                                        TRUNC(NVL(vfechauso, pfecha)), v_cmovimi, vimport,
                                        NULL, NULL, 0, 0, NULL, NULL,
                                        ces.ccesta, v_signo *(ABS(vimport) / v_iuniacts), '2',
                                        f_sysdate);

                           INSERT INTO ctaseguro_libreta_previo
                                       (sseguro, nnumlin, fcontab, ccapgar, ccapfal, nmovimi,
                                        sintbatch, nnumlib, igasext, igasint, ipririe)
                                VALUES (reg.sseguro, xnnumlin, f_sysdate, NULL, NULL, NULL,
                                        NULL, NULL, NULL, NULL, NULL);
                        END IF;

                        vpasexec := 135;

                        IF f_tiene_ctashadow(reg.sseguro, NULL) = 1 THEN
                           vpasexec := 136;

                           IF v_iuniacts_shw = 0 THEN
                              vnumerr :=
                                 pac_ctaseguro.f_insctaseguro_shw
                                                       (reg.sseguro, f_sysdate, NULL,   --nvl(xnnumlin,0)+1,
                                                        TRUNC(NVL(vfechauso, pfecha)),
                                                        TRUNC(NVL(vfechauso, pfecha)),
                                                        v_cmovimi,   --pcmovimi, Part. Beneficios
                                                        vimport, vimport, NULL, 0, 0, NULL,
                                                        NULL, '1', 'P', psproces, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        ces.ccesta);

                              IF vnumerr <> 0 THEN
                                 RAISE verrorsup;
                              END IF;
                           ELSE
                              xnnumlinshw := pac_ctaseguro.f_numlin_next_shw(reg.sseguro);

                              INSERT INTO ctaseguro_previo_shw
                                          (sseguro, fcontab, nnumlin,
                                           ffecmov,
                                           fvalmov, cmovimi, imovimi,
                                           imovim2, nrecibo, ccalint, cmovanu, nsinies,
                                           smovrec, cesta,
                                           nunidad, cestado,
                                           fasign)
                                   VALUES (reg.sseguro, f_sysdate, xnnumlinshw,
                                           TRUNC(NVL(vfechauso, pfecha)),
                                           TRUNC(NVL(vfechauso, pfecha)), v_cmovimi, vimport,
                                           NULL, NULL, 0, 0, NULL,
                                           NULL, ces.ccesta,
                                           v_signo *(ABS(vimport) / v_iuniacts_shw), '2',
                                           f_sysdate);

                              INSERT INTO ctaseguro_libreta_previo_shw
                                          (sseguro, nnumlin, fcontab, ccapgar, ccapfal,
                                           nmovimi, sintbatch, nnumlib, igasext, igasint,
                                           ipririe)
                                   VALUES (reg.sseguro, xnnumlinshw, f_sysdate, NULL, NULL,
                                           NULL, NULL, NULL, NULL, NULL,
                                           NULL);
                           END IF;
                        END IF;
                     END LOOP;
                  ELSE
                     vpasexec := 137;
                     vnumerr :=
                        pac_ctaseguro.f_insctaseguro(reg.sseguro, f_sysdate, NULL,   --nvl(xnnumlin,0)+1,
                                                     TRUNC(NVL(vfechauso, pfecha)),
                                                     TRUNC(NVL(vfechauso, pfecha)), v_cmovimi,   --pcmovimi, Part. Beneficios
                                                     vimppb, vimppb, NULL, 0, 0, NULL, NULL,
                                                     '1', 'P', psproces, NULL, NULL, NULL);

                     IF vnumerr <> 0 THEN
                        RAISE verrorsup;
                     END IF;

                     vpasexec := 138;

                     IF f_tiene_ctashadow(reg.sseguro, NULL) = 1 THEN
                        vnumerr :=
                           pac_ctaseguro.f_insctaseguro_shw
                                                       (reg.sseguro, f_sysdate, NULL,   --nvl(xnnumlin,0)+1,
                                                        TRUNC(NVL(vfechauso, pfecha)),
                                                        TRUNC(NVL(vfechauso, pfecha)),
                                                        v_cmovimi,   --pcmovimi, Part. Beneficios
                                                        vimppb, vimppb, NULL, 0, 0, NULL,
                                                        NULL, '1', 'P', psproces, NULL, NULL,
                                                        NULL);

                        IF vnumerr <> 0 THEN
                           RAISE verrorsup;
                        END IF;
                     END IF;
                  END IF;

                  vpasexec := 14;
               END IF;
            END IF;

            -- 29943 - 07/04/2014 - JTT: Si todo ha ido bien actualizamos el estado en las tablas ADM_PROCESO_PU
            IF vnumerr = 0 THEN
               IF psmodo = 'R' THEN   -- Real
                  verr := f_buscanmovimi(reg.sseguro, 1, 1, v_nmovimi);

                  INSERT INTO adm_proceso_pu
                              (sproces, sseguro, nriesgo, nmovimi, fefecto, fcalcul, ctipopu,
                               cestado, importe)
                       VALUES (psproces, reg.sseguro, 1, v_nmovimi, pfecha, pfecha, v_tipopb,
                               1, vimppb);
               ELSIF psmodo = 'P' THEN   -- Previo
                  verr := f_buscanmovimi(reg.sseguro, 1, 1, v_nmovimi);

                  INSERT INTO adm_proceso_pu_previo
                              (sproces, sseguro, nriesgo, nmovimi, fefecto, fcalcul, ctipopu,
                               cestado, importe)
                       VALUES (psproces, reg.sseguro, 1, v_nmovimi, pfecha, pfecha, v_tipopb,
                               1, vimppb);
               ELSIF psmodo = 'A' THEN   -- reproceso
                  UPDATE adm_proceso_pu
                     SET cestado = 1,   -- Estado tratado
                         importe = vimppb,
                         fcalcul = pfecha,
                         freproc = f_sysdate,
                         cerror = NULL,
                         terror = NULL
                   WHERE sproces = reg_adm.sproces
                     AND sseguro = reg_adm.sseguro
                     AND nriesgo = reg_adm.nriesgo
                     AND fefecto = reg_adm.fefecto;
               END IF;
            END IF;

            COMMIT;
         EXCEPTION
            --Las que fallan no las tratamos y las dejamos para más adelante
            WHEN verrorsup THEN
               ROLLBACK;
               p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                           'Error:' || vparam || ' numerr:' || vnumerr, 'Error en suplemento');
               p_literal2(vnumerr, pcidioma, vtexto);
               vtexto := vtexto || '.' || reg.sseguro || '. npoliza: ' || reg.npoliza;
               -- Grabamos un registro en la tabla de procesos PU con cestado = 0 - Pdte procesar
               verr := f_buscanmovimi(reg.sseguro, 1, 1, v_nmovimi);

               IF psmodo = 'R' THEN
                  INSERT INTO adm_proceso_pu
                              (sproces, sseguro, nriesgo, nmovimi, fefecto, fcalcul, cestado,
                               ctipopu, importe, cerror, terror)
                       VALUES (psproces, reg.sseguro, 1, v_nmovimi, pfecha, pfecha, 0,
                               v_tipopb, vimppb, vnumerr, vtexto);
               ELSIF psmodo = 'P' THEN
                  INSERT INTO adm_proceso_pu_previo
                              (sproces, sseguro, nriesgo, nmovimi, fefecto, fcalcul, cestado,
                               ctipopu, importe, cerror, terror)
                       VALUES (psproces, reg.sseguro, 1, v_nmovimi, pfecha, pfecha, 0,
                               v_tipopb, vimppb, vnumerr, vtexto);
               ELSIF psmodo = 'A' THEN
                  UPDATE adm_proceso_pu
                     SET cestado = 0,
                         importe = vimppb,
                         fcalcul = pfecha,
                         freproc = f_sysdate,
                         cerror = vnumerr,
                         terror = vtexto
                   WHERE sproces = reg_adm.sproces
                     AND sseguro = reg_adm.sseguro
                     AND nriesgo = reg_adm.nriesgo
                     AND fefecto = reg_adm.fefecto;
               END IF;

               vnum_lin := NULL;
               vnum_err := f_proceslin(psproces, vtexto, reg.sseguro, vnum_lin);

               IF vnum_err <> 0 THEN
                  p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                              'Error no controlado en proceslin:' || vparam || ' importe: '
                              || vimppb,
                              vnum_err);
               END IF;

               i := i + 1;
               COMMIT;
               RAISE verrproc;   --Si algo va mal anulamos todo el proceso
            WHEN OTHERS THEN
               ROLLBACK;
               p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                           'Error no controlado:' || vparam || ' importe: ' || vimppb,
                           SQLERRM);
               -- Grabamos un registro en la tabla de procesos PU con cestado = 0 - Pdte procesar
               vtexto := 'Error no controlado:' || vparam || ' importe: ' || vimppb
                         || ' SQLERROR: ' || SQLERRM;
               verr := f_buscanmovimi(reg.sseguro, 1, 1, v_nmovimi);

               IF psmodo = 'R' THEN
                  INSERT INTO adm_proceso_pu
                              (sproces, sseguro, nriesgo, nmovimi, fefecto, fcalcul, cestado,
                               ctipopu, importe, cerror, terror)
                       VALUES (psproces, reg.sseguro, 1, v_nmovimi, pfecha, pfecha, 0,
                               v_tipopb, vimppb, vnumerr, vtexto);
               ELSIF psmodo = 'P' THEN
                  INSERT INTO adm_proceso_pu_previo
                              (sproces, sseguro, nriesgo, nmovimi, fefecto, fcalcul, cestado,
                               ctipopu, importe, cerror, terror)
                       VALUES (psproces, reg.sseguro, 1, v_nmovimi, pfecha, pfecha, 0,
                               v_tipopb, vimppb, vnumerr, vtexto);
               ELSIF psmodo = 'A' THEN
                  UPDATE adm_proceso_pu
                     SET cestado = 0,
                         importe = vimppb,
                         fcalcul = pfecha,
                         freproc = f_sysdate,
                         cerror = vnumerr,
                         terror = vtexto
                   WHERE sproces = reg_adm.sproces
                     AND sseguro = reg_adm.sseguro
                     AND nriesgo = reg_adm.nriesgo
                     AND fefecto = reg_adm.fefecto;
               END IF;

               vnum_lin := NULL;
               vnum_err := f_proceslin(psproces, SQLERRM, reg.sseguro, vnum_lin);

               IF vnum_err <> 0 THEN
                  p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                              'Error no controlado en proceslin:' || vparam || ' importe: '
                              || vimppb,
                              vnum_err);
               END IF;

               i := i + 1;
               COMMIT;
               RAISE verrproc;   --Si algo va mal anulamos todo el proceso
         END;
      END LOOP;   --end loop

      IF psmodo IN('A') THEN
         CLOSE polizas_no_procesadas;
      ELSE
         CLOSE polizas;
      END IF;

      vpasexec := 17;
      pindice := l;   -- - i;
      pindice_error := i;
      vnum_err := f_procesfin(psproces, pindice_error);

      IF vnum_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'Error no controlado en proceslin:' || vparam, vnum_err);
      END IF;

      vpasexec := 18;

      FOR reg IN (SELECT DISTINCT s.sproduc, s.npoliza
                             --Agrupamos los recibos que sean de colectivos que se hayan generado
                  FROM            estado_proc_recibos e, recibos r, seguros s
                            WHERE e.cestado = 0
                              AND e.sproces = psproces
                              AND r.nrecibo = e.npago
                              AND e.ctipopago = 4
                              AND r.esccero = 1
                              AND r.nrecibo NOT IN(SELECT nrecibo
                                                     FROM adm_recunif)
                              AND r.cestaux = 2
                              AND s.sseguro = r.sseguro
                              AND NVL(f_parproductos_v(s.sproduc, 'ADMITE_CERTIFICADOS'), 0) =
                                                                                              1
                              AND NVL(f_parproductos_v(s.sproduc, 'TIPO_PB'), 0) <> 5) LOOP
         v_lista := t_lista_id();   --JRH IMP MIrar si es así

         FOR reg2 IN (SELECT r.nrecibo, e.ctipopago, e.npago, e.nmov
                        FROM estado_proc_recibos e, recibos r, seguros s
                       WHERE e.sproces = psproces
                         AND r.nrecibo = e.npago
                         AND e.ctipopago = 4
                         AND e.cestado = 0
                         AND r.esccero = 1
                         AND s.sseguro = r.sseguro
                         AND r.nrecibo NOT IN(SELECT nrecibo
                                                FROM adm_recunif)
                         AND r.cestaux = 2
                         AND s.npoliza = reg.npoliza) LOOP
            v_lista.EXTEND;
            v_lista(v_lista.LAST) := ob_lista_id();
            v_lista(v_lista.LAST).idd := reg2.nrecibo;

            UPDATE estado_proc_recibos
               --Dejamos los ctipaux2 a procesados , no los borramos para dejar un rastro
            SET cestado = 1
             WHERE ctipopago = reg2.ctipopago
               AND npago = reg2.npago
               AND nmov = reg2.nmov;
         END LOOP;

         IF v_lista IS NOT NULL THEN
            IF v_lista.COUNT > 0 THEN
               vnum_err := pac_gestion_rec.f_agruparecibo(reg.sproduc, NVL(vfechauso, pfecha),
                                                          TRUNC(f_sysdate), pcempres, v_lista,
                                                          13, 0, 1);

               IF vnum_err <> 0 THEN
                  p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                              'Error no controlado en pac_gestion_rec.f_agruparecibo:'
                              || vparam,
                              vnum_err);
                  RAISE verrproc;
               END IF;
            END IF;
         END IF;
      END LOOP;

      FOR rc IN c_rec_env(psproces) LOOP
         --Procesamos todos los recibos insertados
         /* -- BUG:26265 04/03/2013 AMJ
         num_err := pac_ctrl_env_recibos.f_procesar_pendientes_proc(vsproces, pnok, pnko,
                                                                    rc.ctipopago);*/
          -- BUG:26265 04/03/2013 AMJ
         vnum_err := pac_ctrl_env_recibos.f_procesar_pendientes_proc(psproces, pnok, pnko,
                                                                     rc.ctipopago, NULL, NULL,
                                                                     NULL);
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN verrparms THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'Faltan parámetros=' || vparam,
                     SQLERRM);
         pindice := l - i;
         pindice_error := i;
         RETURN vnum_err;
      WHEN verrproc THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, 'Error proceso=' || vparam,
                     SQLERRM);
         pindice := l - i;
         pindice_error := i;
         RETURN vnum_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'Error When others,sqlcode=' || vparam, SQLERRM);
         pindice := l - i;
         pindice_error := i;
         RETURN vnum_err;
   END f_cierrepb;

   /*************************************************************************
      FUNCTION f_suma_aportacio1
      param in psseguro  : codi assegurança
      return             : suma aportació

      Bug 22339 - MDS - 22/05/2012
      -- versión de f_suma_aportacio: cmovimi = 33,34,53,47
    *************************************************************************/
   FUNCTION f_suma_aportacio1(p_sseguro IN VARCHAR2)
      RETURN VARCHAR2 IS
      w_suma_aportacio VARCHAR2(100);
   BEGIN
      SELECT TO_CHAR(SUM(DECODE(cmovimi,
                                1, imovimi,
                                2, imovimi,
                                3, imovimi,
                                4, imovimi,
                                8, imovimi,
                                10, imovimi,
                                -imovimi)),
                     'FM999G999G999G990D00')
        INTO w_suma_aportacio
        FROM ctaseguro
       WHERE sseguro = p_sseguro
         AND cmovimi IN(33, 34, 53, 32, 47);

      RETURN(NVL(w_suma_aportacio, '0,00'));
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('0,00');
   END f_suma_aportacio1;

   /*************************************************************************
      FUNCTION f_suma_aportacio2
      param in psseguro  : codi assegurança
      return             : suma aportació

      Bug 22339 - MDS - 22/05/2012
      -- versión de f_suma_aportacio: cmovimi = 1,2,3,4,8
    *************************************************************************/
   FUNCTION f_suma_aportacio2(p_sseguro IN VARCHAR2)
      RETURN VARCHAR2 IS
      w_suma_aportacio VARCHAR2(100);
   BEGIN
      SELECT TO_CHAR(SUM(DECODE(cmovimi,
                                1, imovimi,
                                2, imovimi,
                                3, imovimi,
                                4, imovimi,
                                8, imovimi,
                                10, imovimi,
                                -imovimi)),
                     'FM999G999G999G990D00')
        INTO w_suma_aportacio
        FROM ctaseguro
       WHERE sseguro = p_sseguro
         AND cmovimi IN(1, 2, 3, 4, 8);

      RETURN(NVL(w_suma_aportacio, '0,00'));
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('0,00');
   END f_suma_aportacio2;

   /*************************************************************************
      FUNCTION f_suma_aportacio3
      param in psseguro  : codi assegurança
      return             : suma aportació

      Bug 22339 - MDS - 22/05/2012
      -- versión de f_suma_aportacio: cmovimi = 10,51
    *************************************************************************/
   FUNCTION f_suma_aportacio3(p_sseguro IN VARCHAR2)
      RETURN VARCHAR2 IS
      w_suma_aportacio VARCHAR2(100);
   BEGIN
      SELECT TO_CHAR(SUM(DECODE(cmovimi,
                                1, imovimi,
                                2, imovimi,
                                3, imovimi,
                                4, imovimi,
                                8, imovimi,
                                10, imovimi,
                                -imovimi)),
                     'FM999G999G999G990D00')
        INTO w_suma_aportacio
        FROM ctaseguro
       WHERE sseguro = p_sseguro
         AND cmovimi IN(10, 51);

      RETURN(NVL(w_suma_aportacio, '0,00'));
   EXCEPTION
      WHEN OTHERS THEN
         RETURN('0,00');
   END f_suma_aportacio3;

   /*************************************************************************
      FUNCTION f_tiene_ctashadow
      param in psseguro  : codi assegurança
      param in psproduc   : codi producte
      return             : suma aportació

   ***************************************************************************/
   FUNCTION f_tiene_ctashadow(psseguro IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER IS
      vcshadow       NUMBER := 0;
   BEGIN
      --     dbms_output.put_line ( 'pac_ctaseguro.f_tiene_ctashadow ' || psseguro);
      IF psseguro IS NOT NULL THEN
         SELECT NVL(f_parproductos_v(s.sproduc, 'SHADOW_ACCOUNT'), 0)
           INTO vcshadow
           FROM seguros s
          WHERE s.sseguro = psseguro;
      ELSIF psproduc IS NOT NULL THEN
         vcshadow := NVL(f_parproductos_v(psproduc, 'SHADOW_ACCOUNT'), 0);
      END IF;

      RETURN vcshadow;
   END f_tiene_ctashadow;

   /*************************************************************************
       FUNCTION f_ctaseguro_consolidada
       param in pffecha  : data d'aplicacio
       param in pcempres   : codi empresa
       param in pccesta   : codi fondo
       param in psseguro   : codi seguro
       param in ver_shdw   : Se usa shadow
       return             : suma aportació
   ***************************************************************************/
   FUNCTION f_ctaseguro_consolidada(
      pffecha IN DATE,
      pcempres IN NUMBER,
      pccesta IN NUMBER,
      psseguro IN NUMBER,
      ver_shdw IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      consolidado    NUMBER := 0;
      estacon        NUMBER := 0;
   BEGIN
      IF ver_shdw = 1 THEN
         SELECT COUNT(1)
           INTO consolidado
           FROM ctaseguro_shadow
          WHERE cesta = pccesta
            AND sseguro = psseguro
            AND fvalmov <= TRUNC(pffecha)
            AND nunidad IS NULL;
      ELSE
         SELECT COUNT(1)
           INTO consolidado
           FROM ctaseguro
          WHERE cesta = pccesta
            AND sseguro = psseguro
            AND fvalmov <= TRUNC(pffecha)
            AND nunidad IS NULL;
      END IF;

      IF consolidado = 0 THEN
         estacon := 1;
      END IF;

      RETURN estacon;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_CTASEGURO.f_ctaseguro_consolidada', 1,
                     'Error When others', SQLERRM);
   END f_ctaseguro_consolidada;
END pac_ctaseguro;

/

  GRANT EXECUTE ON "AXIS"."PAC_CTASEGURO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CTASEGURO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CTASEGURO" TO "PROGRAMADORESCSI";
