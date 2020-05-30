--------------------------------------------------------
--  DDL for Package Body PAC_SIN_RESCATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SIN_RESCATES" AS
   /******************************************************************************
      NOMBRE:       PAC_SIN_RESCATES
      PROP?SITO:
      REVISIONES:
      Ver        Fecha        Autor             Descripci?n
      ---------  ----------  ---------------  ------------------------------------
       1.0       -            -               1. Creaci?n de package
       2.0       17/09/2009   RSC             2. Bug 0010828: CRE - Revisi?n de los productos PPJ din?mico y Pla Estudiant (ajustes)
       3.0       30/09/2009   DRA             3. 0011183: CRE - Suplemento de alta de asegurado ya existente
       4.0       25/11/2009   RSC             8. 0012199: CRE201 - Incidencia suplemento de anulaci?n de garant?a por siniestro
       5.0       22/02/2010   RSC             5. 0013296: CEM - Revisi?n m?dulo de rescates
       6.0       24/02/2010   JRH             6. 0013367: CEM - Error en la tarificaci?n de los productos ahorro
       7.0       19/02/2010   JMF             7. 0012803 AGA - Acceso a la vista PERSONAS
       8.0       10/03/2010   JRH             8. 0012136: CEM - RVI - Verificaci?n productos RVI
       9.0       16/03/2010   FAL             9. 0013672: CEM - Moviment llibreta pagament PPA
       10.0      20/05/2010   RSC             10.0013829: APRB78 - Parametrizacion y adapatacion de rescastes
       11.0      01/06/2010   JRH             11.0014802: Error validaci?n rescates
       12.0      10/06/2010   ASN             12.0014834: CRE800 - Provisiones: Provisi?n matem?tica de las p?lizas con rescates pendientes
       13.0      13/09/2010   JRH             13.0015992: CEM - Falla rescate parcial de renta asegurada
       14.0      04/10/2010   AVT             14.0015362: CEM800 - Provisiones: Provisi?n matem?tica de las p?lizas con rescates pendientes
       15.0      06/10/2010   FAL             15.0016219: GRC - Pagos de siniestros de dos garant?as
       16.0      03/11/2010   ETM             16.0015362: CEM800 - Provisiones: Provisión matemática de las pólizas con rescates pendientes
       17.0      03/12/2010   JMP             17.0016903: CEM - Bloqueo de rescates si fecha de revisión anterior al efecto del rescate
       18.0      18/01/2011   JMP             18.0017316: CRE800 - Provisions amb rescats anul·lats
       19.0      10/05/2011   JMF             19.0018439 CCAT998 - ELIMINACIÓ PROV MATEMÁTICA SINISTRES MORT RENDES I ESTALVI
       20.0      01/07/2011   APD             20.0018913: CRE998 - Afegir motiu de Rescats
       21.0      12/07/2011   ICV             21.0018977: LCOL_S001 - SIN -Asignación automática de tramitadores
       22.0      22/11/2011   RSC             14.0020241: LCOL_T004-Parametrización de Rescates (retiros)
       23.0      29/11/2011   RSC             23.0020309: LCOL_T004-Parametrización Fondos
       24.0      14/11/2011   JMP             24.0018423: LCOL000 - Multimoneda
       25.0      14/11/2011   RSC             25.0019312: LCOL_T004 - Parametrización Anulaciones
       26.0      27/12/2011   JMP             26.0018423: LCOL705 - Multimoneda
       27.0      06/03/2012   JGR             27.0021570: LCOL_A001-Temas pendientes de la terminacion por no pago - Convenio - 0109147
       28.0      26/06/2012   DCG             28.0022587: ENSA102-Corrección en el calculo de la provisión con ipenali
       29.0      20/09/2012   ETM              29.0023116: ENSA102-Comprobar la realización de pagos parciales en el ambiente de PRE de ENSA
       30.0      14/05/2013   ECP             30. 0026676: LCOL_T001- QT 7040: Error cierre de provisiones por c?digo de transacci?n en movimiento de anulaciones errado. Nota 144248
       31.0      20/01/2014   JTT             31. 0033544/192270: Compensación recibos pendientes al saldar/prorrogar la poliza
       32.0      20-08-2015   ACL             32. 0033884/212340: Corregir la llamada a la función F_INS_PAGO, añadiendo el parámetro ncheque.
   ******************************************************************************/
   FUNCTION f_vivo_o_muerto(
      psseguro IN seguros.sseguro%TYPE,
      pcestado IN NUMBER,
      pfecha IN DATE)
      RETURN NUMBER IS
      xcuantos       NUMBER;
      xvivos         NUMBER;
      xmuertos       NUMBER;
      xtodos         NUMBER;
   --********* Par?metros
   --**** ESTADO
   --****
   --**** 1- Devuelve los asegurados vivos
   --**** 2- Devuelve los asegurados muertos
   --**** 3- Devuelve el numero de asegurados tanto vivos como muertos
   BEGIN
      IF pcestado = 1 THEN
         SELECT COUNT(1)
           INTO xvivos
           FROM asegurados
          WHERE sseguro = psseguro
            AND(ffecmue > pfecha
                OR ffecmue IS NULL)
            AND(ffecfin > pfecha
                OR ffecfin IS NULL);   -- BUG11183:DRA:30/09/2009

         RETURN(xvivos);
      ELSIF pcestado = 2 THEN
         SELECT COUNT(1)
           INTO xmuertos
           FROM asegurados
          WHERE sseguro = psseguro
            AND ffecmue <= pfecha;

         RETURN(xmuertos);
      ELSIF pcestado = 3 THEN
         SELECT COUNT(1)
           INTO xtodos
           FROM asegurados
          WHERE sseguro = psseguro
            AND ffecfin IS NULL;   -- BUG11183:DRA:30/09/2009

         RETURN(xtodos);
      END IF;
   END f_vivo_o_muerto;

   FUNCTION f_tratar_sinies_fallec(psseguro IN seguros.sseguro%TYPE, pfrescat IN DATE)
      RETURN NUMBER IS
      --   Funci?n que mira si hay alg?n asegurado fallecido. Si lo hay:
      --      1.- Debe reabrir el siniestro
      --      2.- Si no encuentra siniestro de fallecimiento de 1 titular (p?lizas de migraci?n)
      --         se abrir? en ese momento con la valoraci?n del 50% de la provisi?n en el momento
      --         del fallecimiento
      xnsinies_mort  sin_siniestro.nsinies%TYPE;
      xcestsin_mort  sin_movsiniestro.cestsin%TYPE;
      num_err        NUMBER;
      v_norden       NUMBER;
      v_sproduc      productos.sproduc%TYPE;
      v_cactivi      activisegu.cactivi%TYPE;
      vivalora       sin_tramita_reserva.ireserva%TYPE;
      vipenali       sin_tramita_reserva.ipenali%TYPE;
      vicapris       sin_tramita_reserva.icaprie%TYPE;
      v_fsinies      sin_siniestro.fsinies%TYPE;
      vnsinies       sin_siniestro.nsinies%TYPE;
      vnsinies_fall  sin_siniestro.nsinies%TYPE;
      entra          NUMBER := 0;   --> Entra = 1 querr? decir que hay siniestro y ya se ha valorado.
      --  Por tanto se pueden generar los pagos a los destinatarios, etc.
      vcramo         codiram.cramo%TYPE;
      vcidioma       idiomas.cidioma%TYPE;
      v_nriesgo      riesgos.nriesgo%TYPE;
      v_nmovimi      movseguro.nmovimi%TYPE;
      v_cuenta1      seguros.cbancar%TYPE;
      v_ctipban1     seguros.ctipban%TYPE;
      v_cempres      empresas.cempres%TYPE;
      v_cunitra      sin_redtramitador.ctramitad%TYPE;
      v_ctramitad    sin_redtramitador.ctramitad%TYPE;
      v_nmovsin      sin_movsiniestro.nmovsin%TYPE;
      v_ntramit      sin_tramitacion.ntramit%TYPE;
      v_nmovtra      sin_tramita_movimiento.nmovtra%TYPE;
      v_nmovres      sin_tramita_reserva.nmovres%TYPE;
      v_sidepag      sin_tramita_pago.sidepag%TYPE;
      v_ipago        sin_tramita_reserva.ipago%TYPE;
      v_iingreso     sin_tramita_reserva.iingreso%TYPE;
      v_irecobro     sin_tramita_reserva.irecobro%TYPE;
      v_icaprie      sin_tramita_reserva.icaprie%TYPE;
      v_ipenali      sin_tramita_reserva.ipenali%TYPE;
      v_ctipres      sin_tramita_reserva.ctipres%TYPE := 1;
      v_cgarant      sin_tramita_reserva.cgarant%TYPE := 1;
      v_ccausin      sin_siniestro.ccausin%TYPE := 1;
      v_cmotsin      sin_siniestro.cmotsin%TYPE := 4;
      --Bug 20665 - RSC - 24/01/2012 - LCOL_T001-LCOL - UAT - TEC - Rescates
      v_ccesta       segdisin2.ccesta%TYPE;
      vifranq        sin_tramita_reserva.ifranq%TYPE;   --27059:NSS:05/06/2013
   --Bug 20665
   BEGIN
      -- Buscamos el siniestro de baja de 1 titular (ccausin = 1 and cmotsin = 4) y si
      -- est? cerrado lo reaperturamos. Si no existe lo damos de alta.
      FOR reg IN (SELECT   si.nsinies, sm.cestsin, si.nasegur, si.fsinies, str.ireserva,
                           seg.sproduc,
                           pac_seguros.ff_get_actividad(si.sseguro, si.nriesgo, NULL) cactivi
                      FROM sin_siniestro si, sin_movsiniestro sm, sin_tramita_reserva str,
                           seguros seg
                     WHERE si.sseguro = psseguro
                       AND si.nsinies = str.nsinies
                       AND seg.sseguro = si.sseguro
                       AND si.nsinies = sm.nsinies
                       AND sm.nmovsin = (SELECT MAX(nmovsin)
                                           FROM sin_movsiniestro
                                          WHERE nsinies = si.nsinies)
                       AND si.ccausin = v_ccausin   -- muerte
                       AND si.cmotsin = 0   -- baja 1 titular
                       AND f_pargaranpro_v(seg.cramo, seg.cmodali, seg.ctipseg, seg.ccolect,
                                           pac_seguros.ff_get_actividad(si.sseguro, si.nriesgo,
                                                                        NULL),
                                           str.cgarant, 'TIPO') = 6
                       AND str.ntramit = 0
                       AND str.ctipres = 1   -- jlb - 18423#c105054
                       AND str.nmovres = (SELECT MAX(str1.nmovres)
                                            FROM sin_tramita_reserva str1
                                           WHERE str1.nsinies = str.nsinies
                                             AND str1.ntramit = str.ntramit
                                             AND str1.ctipres =
                                                              str.ctipres   -- jlb - 18423#c105054
                                                                         )
                  ORDER BY si.nsinies DESC) LOOP
         xnsinies_mort := reg.nsinies;
         xcestsin_mort := reg.cestsin;
         v_norden := reg.nasegur;
         v_fsinies := reg.fsinies;
         vivalora := reg.ireserva;
         v_sproduc := reg.sproduc;
         v_cactivi := reg.cactivi;
      END LOOP;

      -- Bug 10828 - RSC - 10/09/2009 - CRE - Revisi?n de los productos PPJ din?mico y Pla Estudiant (ajustes)
      BEGIN
         SELECT cempres
           INTO v_cempres
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101903;
      END;

      -- Bug 20665 - RSC - 24/01/2012 - LCOL_T001-LCOL - UAT - TEC - Rescates
      BEGIN
         SELECT ccesta
           INTO v_ccesta
           FROM segdisin2
          WHERE sseguro = psseguro
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = psseguro);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
         WHEN TOO_MANY_ROWS THEN
            v_ccesta := NULL;
      END;

      -- Fin Bug 20665

      -- Fin Bug 10828
      IF xnsinies_mort IS NULL
         OR xcestsin_mort IN(2, 3) THEN   -- no hay siniestro de cobertura de fallecimiento o est? anulado/rechazado
         entra := 1;

         -- abrir siniestro de fallecimiento 1 titular
         BEGIN
            SELECT a.norden, NVL(a.ffecmue, a.ffecfin), s.sproduc,
                   pac_seguros.ff_get_actividad(a.sseguro, a.nriesgo, NULL) cactivi,
                   a.nriesgo, s.cempres
              INTO v_norden, v_fsinies, v_sproduc,
                   v_cactivi,
                   v_nriesgo, v_cempres
              FROM asegurados a, seguros s
             WHERE a.sseguro = psseguro
               AND s.sseguro = a.sseguro
               AND a.ffecmue IS NOT NULL;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 120007;   -- error al leer de ASEGURADOS
         END;

         -- RSC 12/12/2007 ----------------------------------------
         -- Miramos si existe el siniestro pero simplemente est? sin valorar (ULK)
         BEGIN
            SELECT si.nsinies, sm.cestsin, si.nasegur, si.fsinies
              INTO xnsinies_mort, xcestsin_mort, v_norden, v_fsinies
              FROM sin_siniestro si, sin_movsiniestro sm
             WHERE si.sseguro = psseguro
               AND si.nsinies = sm.nsinies
               AND sm.nmovsin = (SELECT MAX(nmovsin)
                                   FROM sin_movsiniestro
                                  WHERE nsinies = si.nsinies)
               AND si.ccausin = v_ccausin
               AND si.cmotsin = v_cmotsin
               AND (SELECT COUNT(1)
                      FROM sin_tramita_reserva
                     WHERE nsinies = si.nsinies
                       AND ctipres = 1   -- jlb - 18423#c105054
                                      ) = 0;
         EXCEPTION
            WHEN OTHERS THEN
               xnsinies_mort := NULL;
         END;

         IF xnsinies_mort IS NOT NULL THEN   -- De verdad existe siniestro de fallecimiento previo a este rescate
            -- pero no se ha valorado todavia. Lo valoraremos aqui!!!
            vnsinies := xnsinies_mort;
         ELSE
            -- Se recupera el n?mero de movimiento de las garant?as
            BEGIN
               SELECT MAX(nmovimi)
                 INTO v_nmovimi
                 FROM garanseg
                WHERE sseguro = psseguro
                  AND nriesgo = v_nriesgo
                  AND ffinefe IS NULL;
            EXCEPTION
               WHEN OTHERS THEN
                  v_nmovimi := NULL;
            END;

            -- Inserci?n cabecera siniestro
            num_err := pac_siniestros.f_ins_siniestro(psseguro, v_norden, v_nmovimi, v_fsinies,
                                                      TRUNC(f_sysdate), v_ccausin, v_cmotsin,
                                                      NULL, NULL, NULL, v_norden, NULL, NULL,
                                                      NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                      NULL, 'BAJA 1 TITULAR', NULL, NULL, NULL,
                                                      NULL, NULL, vnsinies);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            -- Recuperaci?n Unidad Tramitaci?n y Tramitador por defecto
            --Ini Bug.: 18977 - 12/07/2011 - ICV
            --num_err := pac_siniestros.f_get_unitradefecte(v_cempres, v_cunitra, v_ctramitad);
            num_err := pac_siniestros.f_get_tramitador_defecto(v_cempres, f_user, psseguro,
                                                               v_ccausin, v_cmotsin, NULL,
                                                               NULL,   -- 22108:ASN:06/06/2012
                                                               NULL, v_cunitra, v_ctramitad);

            IF NVL(num_err, 99999) > 1 THEN
               RETURN num_err;
            END IF;

            num_err := 0;
            --Fin bug.: 18977

            -- Inserci?n movimiento siniestro
            num_err := pac_siniestros.f_ins_movsiniestro(vnsinies, 0, TRUNC(f_sysdate), NULL,
                                                         v_cunitra, v_ctramitad, v_nmovsin);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            -- Inserci?n tramitaci?n global siniestro
            num_err := pac_siniestros.f_ins_tramitacion(vnsinies, 0, 0, 0, v_ntramit);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            -- Inserci?n movimiento tramitaci?n
            num_err := pac_siniestros.f_ins_tramita_movimiento(vnsinies, v_ntramit, v_cunitra,
                                                               v_ctramitad, 0, 20,
                                                               TRUNC(f_sysdate), v_nmovtra);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;

         IF (NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
             AND pac_mantenimiento_fondos_finv.f_cestas_valoradas(v_fsinies, v_cempres,
                                                                  v_ccesta, psseguro) = 0)
            OR(NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) <> 1) THEN
            -- Se calcula la reserva
            num_err := pac_sin_formula.f_cal_valora(v_fsinies, psseguro, v_nriesgo, vnsinies,
                                                    v_ntramit, 0, v_sproduc, v_cactivi,
                                                    v_cgarant, v_ccausin, v_cmotsin,
                                                    TRUNC(f_sysdate), TRUNC(f_sysdate), NULL,
                                                    NULL, vivalora, vipenali, vicapris,
                                                    vifranq   --Bug 27059:NSS:05/06/2013
                                                           );

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            -- Se inserta la reserva
            num_err :=
               pac_siniestros.f_ins_reserva
                  (vnsinies, v_ntramit, v_ctipres, v_cgarant, 1, TRUNC(f_sysdate), NULL,   -- BUG 18423 - 14/11/2011 - JMP - Pasamos moneda reserva NULL para que la coja en función
                                                                                           -- de si es multimoneda o no
                   vivalora, NULL, vicapris, vipenali, NULL, NULL, NULL, NULL, NULL, NULL,
                   NULL, NULL, v_nmovres, 1   --cmovres --0031294/0174788: NSS:23/05/2014
                                           );

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;

         xnsinies_mort := vnsinies;
      ELSIF xcestsin_mort = 0 THEN   -- hay siniestro de fallecimiento en estado pendiente
         -- no hacemos nada. Se terminar? de gestionar manualmente
         NULL;
      ELSE
         entra := 1;
         -- el xcestsin_mort = 1 -- finalizado
         -- lo reaperturamos
         num_err := pac_siniestros.f_reabrir_sin(xnsinies_mort);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      IF (NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
          AND pac_mantenimiento_fondos_finv.f_cestas_valoradas(v_fsinies, v_cempres, v_ccesta,
                                                               psseguro) = 0)
         OR (NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) <> 1)
            AND entra = 1 THEN
         -- Insertamos el destinatario: el asegurado vivo
         BEGIN
            SELECT cbancar, ctipban
              INTO v_cuenta1, v_ctipban1
              FROM seguros s
             WHERE s.sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               v_cuenta1 := NULL;
               v_ctipban1 := NULL;
         END;

         IF NVL(f_parproductos_v(v_sproduc, '2_CABEZAS'), 0) = 1 THEN
            -- Se debe buscar el sperson de la persona que queda vigente, no de la fallecida
            BEGIN
               SELECT sperson
                 INTO v_nriesgo
                 FROM asegurados a
                WHERE a.sseguro = psseguro
                  AND a.norden <> NVL(v_norden, 1)
                  AND a.ffecfin IS NULL;   -- BUG11183:DRA:30/09/2009
            EXCEPTION
               WHEN OTHERS THEN
                  -- Por si acaso s?lo hay un asegurado
                  v_nriesgo := v_norden;
            END;
         ELSE
            BEGIN
               SELECT sperson
                 INTO v_nriesgo
                 FROM riesgos r
                WHERE r.sseguro = psseguro
                  AND nriesgo = NVL(v_norden, 1);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 105709;   --{Riesgo no encontrado en la tabla ...}
            END;
         END IF;

         FOR aseg IN (SELECT   sperson, norden
                          FROM asegurados
                         WHERE sseguro = psseguro
                           AND ffecmue IS NULL
                           AND ffecfin IS NULL   -- BUG11183:DRA:30/09/2009
                      ORDER BY norden) LOOP
            /*
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              { Si el producto indica que solo tiene que hacer un pago por
            siniestro solo lo hacemos al riesgo}
            */
            num_err := pac_siniestros.f_ins_destinatario(xnsinies_mort, v_ntramit,
                                                         aseg.sperson, v_cuenta1, v_ctipban1,
                                                         NULL, NULL, 1, 1, NULL);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END LOOP;

         pac_sin_formula.p_borra_mensajes;

         IF NVL(vivalora, 0) > 0 THEN
            -- Generamos los pagos
            num_err :=
               pac_sin_formula.f_genera_pago
                  (psseguro, v_nriesgo,   -- Bug 16219. FAL. 06/10/2010. Parametrizar que la generaci?n del pago sea por garantia
                   v_cgarant,   -- Fi Bug 16219
                   v_sproduc, v_cactivi, xnsinies_mort, v_ntramit, v_ccausin, v_cmotsin,
                   pfrescat, pfrescat);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            num_err := pac_sin_formula.f_inserta_pago(xnsinies_mort, v_ntramit, v_ctipres,
                                                      v_cgarant, v_sidepag, v_ipago);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

---------------------------------
-- Actualizar reserva con pago --
---------------------------------
            num_err := pac_sin_formula.f_actualiza_reserva(xnsinies_mort, v_ntramit, 1, 1,
                                                           v_ipago, v_iingreso, v_irecobro,
                                                           v_icaprie, v_ipenali, NULL, NULL,
                                                           v_sidepag);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sin_rescates.f_tratar_sinies_fallec', NULL,
                     'Error no controlado', SQLERRM);
         RETURN 140999;
   END f_tratar_sinies_fallec;

   FUNCTION f_gest_siniestro(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN riesgos.nriesgo%TYPE,
      pffecmov IN DATE,
      pctipmov IN NUMBER,
      pcidioma IN idiomas.cidioma%TYPE,
      pimporte IN sin_tramita_reserva.ireserva%TYPE,
      pipenali IN sin_tramita_reserva.ipenali%TYPE,
      picaprm IN sin_tramita_reserva.icaprie%TYPE,
      picapret IN NUMBER,
      picapred IN NUMBER,
      pnivel IN NUMBER,
      pnsinies OUT sin_siniestro.nsinies%TYPE,
      pimprcm IN NUMBER DEFAULT NULL,   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      ppctreten IN NUMBER DEFAULT NULL,   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      pcmotresc IN NUMBER DEFAULT NULL,   -- Bug 18913 - APD - 01/07/2011
      pcmotsin IN sin_siniestro.cmotsin%TYPE DEFAULT NULL,   -- BUG 20241 - RSC - 22/11/2011
      pctipdes IN sin_tramita_destinatario.ctipdes%TYPE DEFAULT NULL,
      -- Ini Bug 26676 -- ECP -- 14/05/2013
      pdiafinv NUMBER DEFAULT 0,
      pskipfanulac NUMBER DEFAULT 0
                                   -- Fin Bug 26676 -- ECP -- 14/05/2013
   )
      -- BUG 20241 - RSC - 22/11/2011
   RETURN NUMBER IS
      xcausa         VARCHAR2(50);
      num_err        NUMBER := 0;
      xccausin       sin_codcausa.ccausin%TYPE;
      xcmotsin       sin_codmotcau.cmotsin%TYPE;
      xppagdes       NUMBER;
      xmoneda        eco_codmonedas.cmoneda%TYPE;
      xcestpag       NUMBER;
      xpretenc       NUMBER;
      xsperson       per_personas.sperson%TYPE;
      xsproduc       productos.sproduc%TYPE;
      xmuerto        NUMBER;
      ximport        NUMBER;
      ximport2       NUMBER;
      xfmuerte       DATE;
      vipenali       sin_tramita_reserva.ipenali%TYPE;
      vivalora       sin_tramita_reserva.ireserva%TYPE;
      vicapris       sin_tramita_reserva.icaprie%TYPE;
      xcactivi       activisegu.cactivi%TYPE;
      vivalora_tot   sin_tramita_reserva.ireserva%TYPE;
      v_ntramit      sin_tramitacion.ntramit%TYPE;
      v_nmovsin      sin_movsiniestro.nmovsin%TYPE;
      v_ctipres      sin_tramita_reserva.ctipres%TYPE := 1;
      v_cgarant      sin_tramita_reserva.cgarant%TYPE;
      v_nmovres      sin_tramita_reserva.nmovres%TYPE;
      v_sidepag      sin_tramita_reserva.sidepag%TYPE;
      v_ipago        sin_tramita_reserva.ipago%TYPE;
      -- Bug 10828 - RSC - 10/09/2009 - CRE - Revisi?n de los productos PPJ din?mico y Pla Estudiant (ajustes)
      v_cempres      seguros.cempres%TYPE;
      -- Fin Bug 10828

      --Bug 20665 - RSC - 24/01/2012 - LCOL_T001-LCOL - UAT - TEC - Rescates
      v_ccesta       segdisin2.ccesta%TYPE;
      vifranq        sin_tramita_reserva.ifranq%TYPE;   --27059:NSS:05/06/2013
      --Bug 20665
      v_pffecmov     DATE;
      v_fsinies      DATE;
      hay_reserva    NUMBER;
   BEGIN
      -- {Obtenemos el % de retenci?n }
      BEGIN
         SELECT r.sperson, s.sproduc, s.cactivi
           INTO xsperson, xsproduc, xcactivi
           FROM asegurados r, seguros s
          WHERE r.sseguro = s.sseguro
            AND s.sseguro = psseguro
            AND r.norden = pnriesgo;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 102819;   --{Riesgo no encontrado}
      END;

      xpretenc := pac_sin_rescates.f_busca_preten(1, xsperson, xsproduc,
                                                  TO_NUMBER(TO_CHAR(pffecmov, 'YYYYMMDD')));

      IF pctipmov = 4 THEN
         xccausin := 4;   --{4.-  Rescats Total}
         xcmotsin := NVL(pcmotsin, 0);
      ELSIF pctipmov = 5 THEN
         xccausin := 5;   --{5.-   Rescats Parcial}
         xcmotsin := NVL(pcmotsin, 0);
      ELSIF pctipmov = 3 THEN   -- vencimiento
         xccausin := 3;
         xcmotsin := NVL(pcmotsin, 0);
      ELSIF pctipmov = 44 THEN   -- Rescate total riesgo (Valor de rescate)
         xccausin := 44;
         xcmotsin := NVL(pcmotsin, 0);
      END IF;

      num_err := pac_siniestros.f_descausa(xccausin, pcidioma, xcausa);

      -- creamos el siniestro associado

      -- creamos el siniestro associado
      IF NVL(f_parproductos_v(xsproduc, 'RESCATE_VENTANA'), 0) = 1
         AND xccausin = 4 THEN
         num_err := pac_siniestros.f_inicializa_sin(psseguro, pnriesgo, NULL, pffecmov,
                                                    TRUNC(f_sysdate), xcausa, xccausin,
                                                    xcmotsin, 21, pnsinies, v_nmovsin,
                                                    v_ntramit, pdiafinv, pskipfanulac);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         num_err := pac_siniestros.f_estado_final(pnsinies, hay_reserva);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      ELSE
         num_err := pac_siniestros.f_inicializa_sin(psseguro, pnriesgo, NULL, pffecmov,
                                                    pffecmov, xcausa, xccausin, xcmotsin, 21,
                                                    pnsinies, v_nmovsin, v_ntramit, pdiafinv,
                                                    pskipfanulac);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         -- Bug 10828 - RSC - 10/09/2009 - CRE - Revisi?n de los productos PPJ din?mico y Pla Estudiant (ajustes)
         BEGIN
            SELECT cempres
              INTO v_cempres
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 101903;
         END;

         -- Bug 20665 - RSC - 24/01/2012 - LCOL_T001-LCOL - UAT - TEC - Rescates
         BEGIN
            SELECT ccesta
              INTO v_ccesta
              FROM segdisin2
             WHERE sseguro = psseguro
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM segdisin2
                               WHERE sseguro = psseguro);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_ccesta := NULL;
            WHEN TOO_MANY_ROWS THEN
               v_ccesta := NULL;
         END;

         -- Fin Bug 20665
         v_pffecmov := pffecmov;

         IF NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
            AND xccausin = 5 THEN
            SELECT fsinies
              INTO v_fsinies
              FROM sin_siniestro
             WHERE nsinies = pnsinies;

            v_pffecmov := GREATEST(v_pffecmov, v_fsinies);
         END IF;

         -- Fin Bug 10828
         -- RSC 11/12/2007 (lo haremos en el momento de asignar participaciones)
         IF (NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
             AND pac_mantenimiento_fondos_finv.f_cestas_valoradas(v_pffecmov, v_cempres,
                                                                  v_ccesta, psseguro) = 0)
            -- Bug 10828 - RSC - 10/09/2009 - CRE - Revisi?n de los productos PPJ din?mico y Pla Estudiant (ajustes)
            OR(NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
               AND xccausin = 5)
            -- Fin Bug 10828
            OR(NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) <> 1)
            OR(xccausin = 4
               AND xcmotsin = 2) THEN
            IF NVL(pimporte, 0) = 0 THEN   -- si el importe del rescte no viene informado
               vivalora_tot := 0;

               FOR reg IN (SELECT DISTINCT cgarant
                                      FROM sin_gar_causa_motivo sgcm, sin_causa_motivo scm
                                     WHERE sgcm.scaumot = scm.scaumot
                                       AND scm.ccausin = xccausin
                                       AND scm.cmotsin = xcmotsin
                                       AND sgcm.sproduc = xsproduc
                                       AND sgcm.cactivi = xcactivi) LOOP
                  v_cgarant := reg.cgarant;
                  -- Se ejecutan las valoraciones contra la garant?a
                  num_err := pac_sin_formula.f_cal_valora(v_pffecmov, psseguro, pnriesgo,
                                                          pnsinies, v_ntramit, 0, xsproduc,
                                                          xcactivi, v_cgarant, xccausin,
                                                          xcmotsin, v_pffecmov, v_pffecmov,
                                                          NULL, NULL, vivalora, vipenali,
                                                          vicapris,
                                                          vifranq   --27059:NSS:05/06/2013
                                                                 );

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;

                  -- Se inserta la reserva
                  num_err :=
                     pac_siniestros.f_ins_reserva
                        (pnsinies, v_ntramit, v_ctipres, v_cgarant, 1, v_pffecmov, NULL,   -- BUG 18423 - 14/11/2011 - JMP - Pasamos moneda reserva NULL para que la coja en función

                         -- de si es multimoneda o no
                         NVL(vivalora, 0) - NVL(vipenali, 0), NULL, vicapris, vipenali, NULL,
                         NULL, NULL, NULL, NULL, NULL, NULL, NULL, v_nmovres,
                         1   --cmovres --0031294/0174788: NSS:23/05/2014
                          );

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;

                  vivalora_tot := vivalora_tot +(NVL(vivalora, 0) - NVL(vipenali, 0));
               END LOOP;
            ELSE
               vivalora_tot := 0;

               FOR reg IN (SELECT DISTINCT cgarant
                                      FROM sin_gar_causa_motivo sgcm, sin_causa_motivo scm
                                     WHERE sgcm.scaumot = scm.scaumot
                                       AND scm.ccausin = xccausin
                                       AND scm.cmotsin = xcmotsin
                                       AND sgcm.sproduc = xsproduc
                                       AND sgcm.cactivi = xcactivi) LOOP
                  /* {registramos la valoraci?n del siniestro} */
                  -- RSC 19/03/2008 (a?ado NVL en pipenali)
                  v_cgarant := reg.cgarant;
                  vivalora := pimporte - NVL(pipenali, 0);
                  -- Se inserta la reserva
                  num_err :=
                     pac_siniestros.f_ins_reserva
                        (pnsinies, v_ntramit, v_ctipres, v_cgarant, 1, v_pffecmov, NULL,   -- BUG 18423 - 14/11/2011 - JMP - Pasamos moneda reserva NULL para que la coja en función

                         -- de si es multimoneda o no
                         NVL(vivalora, 0), NULL, pimporte, NVL(pipenali, 0), NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL, v_nmovres,
                         1   --cmovres --0031294/0174788: NSS:23/05/2014
                          );

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;

                  vivalora_tot := vivalora_tot + vivalora;
               END LOOP;
            END IF;
         END IF;

         xppagdes := NULL;   -- tantos pagos como asegurados

         -- Bug 12136 - JRH - 11/03/2010 - JRH - Este par?metro nos indicar? cuantos pagos hacer
         IF NVL(f_parproductos_v(xsproduc, 'FISCALIDAD_2_CABEZAS'), 0) = 1 THEN
            xppagdes := 1;
         ELSE
            xppagdes := 0;
         END IF;

         -- Fi Bug 12136 - JRH - 11/03/2010 - JRH

         --Creamos los destinatarios del siniestro}
         IF (NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
             AND pac_mantenimiento_fondos_finv.f_cestas_valoradas(v_pffecmov, v_cempres,
                                                                  v_ccesta, psseguro) = 0)
            OR   -- Bug 10828 - RSC - 10/09/2009 - CRE - Revisi?n de los productos PPJ din?mico y Pla Estudiant (ajustes)
              (NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
               AND xccausin = 5)
            -- Fin Bug 10828
            OR(NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) <> 1)
            OR(xccausin = 4
               AND xcmotsin = 2) THEN
            -- Bug 19312 - RSC - 21/11/2011 - LCOL_T004 - Parametrización Anulaciones
            IF (pnivel IN(1, 2)
                OR NVL(f_parproductos_v(xsproduc, 'FISCALIDAD_2_CABEZAS'), 0) <> 0) THEN
               -- Fin Bug 19312
               num_err :=
                  pac_sin_rescates.f_ins_destinatario
                                               (pnsinies, v_ntramit, psseguro, pnriesgo,
                                                xppagdes, NVL(pctipdes, 1),   -- BUG 20241 - RSC - 22/11/2011
                                                1, NULL, NULL, NULL, NULL);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            -- Bug 19312 - RSC - 21/11/2011 - LCOL_T004 - Parametrización Anulaciones
            END IF;

            -- Fin bug 19312
            pac_sin_formula.p_borra_mensajes;
         END IF;

         -- Solo generamos pagos si el importe de la valoraci?n es > 0
         IF (NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
             AND pac_mantenimiento_fondos_finv.f_cestas_valoradas(v_pffecmov, v_cempres,
                                                                  v_ccesta, psseguro) = 0)
            OR   -- Bug 10828 - RSC - 10/09/2009 - CRE - Revisi?n de los productos PPJ din?mico y Pla Estudiant (ajustes)
              (NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
               AND xccausin = 5)
            -- Fin Bug 10828
            OR(NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) <> 1)
            OR(xccausin = 4
               AND xcmotsin = 2) THEN
            IF NVL(vivalora_tot, 0) > 0
               AND((pnivel = 1
                    OR NVL(f_parproductos_v(xsproduc, 'FISCALIDAD_2_CABEZAS'), 0) <> 0)) THEN
               -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
               IF pimprcm IS NOT NULL
                  OR ppctreten IS NOT NULL THEN
                  -- Generamos los pagos
                  num_err :=
                     pac_sin_formula.f_genera_pago
                        (psseguro, pnriesgo,   -- Bug 16219. FAL. 06/10/2010. Parametrizar que la generaci?n del pago sea por garantia
                         v_cgarant,
                         -- Fi Bug 16219
                         xsproduc, xcactivi, pnsinies, v_ntramit, xccausin, xcmotsin,
                         v_pffecmov, v_pffecmov, NULL, NULL, pimprcm, ppctreten);
               ELSE
                  -- Fin Bug 13829
                  -- Generamos los pagos
                  num_err :=
                     pac_sin_formula.f_genera_pago
                        (psseguro, pnriesgo,   -- Bug 16219. FAL. 06/10/2010. Parametrizar que la generaci?n del pago sea por garantia
                         v_cgarant,
                         -- Fi Bug 16219
                         xsproduc, xcactivi, pnsinies, v_ntramit, xccausin, xcmotsin,
                         v_pffecmov, v_pffecmov);
               END IF;

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               num_err := pac_sin_formula.f_inserta_pago(pnsinies, v_ntramit, v_ctipres,
                                                         v_cgarant, v_sidepag, v_ipago);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               -- Bug 13423 - 17/03/2010 - AMC
               -- La actualizaci?n de la reserva lo realiza al insertar el pago no es necesaria realizarla aqui
               -- Fi Bug 13423 - 17/03/2010 - AMC
               num_err := f_traspaso_tmp_primas_cons(psseguro, NULL, pnsinies);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;
         END IF;

         -- Tratamos ahora el siniestro en el caso de que haya un asegurado fallecido
         -- RSC 11/12/2007
         IF (NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
             AND pac_mantenimiento_fondos_finv.f_cestas_valoradas(v_pffecmov, v_cempres,
                                                                  v_ccesta, psseguro) = 0
             AND xccausin = 4)
            OR(NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) <> 1) THEN
            IF f_vivo_o_muerto(psseguro, 2, v_pffecmov) = 1 THEN   -- hay un asegurado fallecido
               -- Bug 15992 - JRH - 13/09/2010 - JRH - 0015992: CEM - Falla rescate parcial de renta asegurada
               IF xccausin = 4
                  AND NVL(f_parproductos_v(xsproduc, 'FISCALIDAD_2_CABEZAS'), 0) <> 1 THEN   --Solo se llama en el caso de FISCALIDAD primera cabeza
                  num_err := pac_sin_rescates.f_tratar_sinies_fallec(psseguro, v_pffecmov);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;
            -- Fi Bug 15992 - JRH - 13/09/2010 - JRH - 0015992: CEM - Falla rescate parcial de renta asegurada
            END IF;
         END IF;
      END IF;

      -- Bug 18913 - APD - 01/07/2011 - se actualiza el cambio CMOTRESC
      -- Motivo de rescate del siniestro
      UPDATE sin_siniestro
         SET cmotresc = pcmotresc
       WHERE nsinies = pnsinies;

      -- fin Bug 18913 - APD - 01/07/2011
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sin_rescates.f_gest_siniestro', 1,
                     'Error no controlado', SQLERRM);
         RETURN 140999;   --{Error no controlado}
   END f_gest_siniestro;

   FUNCTION f_to(pcagente IN agentes.cagente%TYPE)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN f_parinstalacion_t('MAIL_RESC');
   END f_to;

   FUNCTION f_from(pcagente IN agentes.cagente%TYPE)
      RETURN VARCHAR2 IS
      xcagente       NUMBER;
      xto            VARCHAR2(100);
   BEGIN
      /*
                                                                                                                                                                                                                                                                   {buscamos la direccion de la oficina de la poliza.}
      */
      BEGIN
         SELECT sperson
           INTO xcagente
           FROM agentes a
          WHERE a.cagente = pcagente;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 014472;   --{Agente no encontrado en..}
      END;

      /*
                                                                                                                                                                                                                                                                                                     {La buscamos en contactos de la oficina es la
        primera direcci?n de correo que existe.}
       */
      BEGIN
         SELECT tvalcon
           INTO xto
           FROM contactos
          WHERE sperson = xcagente
            AND ctipcon = 3;
      EXCEPTION
         WHEN TOO_MANY_ROWS THEN
            SELECT tvalcon
              INTO xto
              FROM contactos
             WHERE sperson = xcagente
               AND ctipcon = 3
               AND cmodcon = (SELECT MIN(cmodcon)
                                FROM contactos
                               WHERE sperson = xcagente
                                 AND ctipcon = 3);
         WHEN OTHERS THEN
            xto := NULL;
      END;

      RETURN xto;
   END f_from;

   FUNCTION f_simulacion_rescate(
      psseguro IN seguros.sseguro%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pccausin IN sin_codcausa.ccausin%TYPE,
      pimport IN NUMBER,
      pfecha IN DATE,
      pctipcal IN NUMBER,
      res OUT pac_sin_formula.t_val,
      pimppenali IN NUMBER DEFAULT NULL,
      pimprcm IN NUMBER DEFAULT NULL,   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      ppctreten IN NUMBER DEFAULT NULL)   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      RETURN NUMBER IS
      num_err        NUMBER;
      w_cgarant      NUMBER;
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      ximport        NUMBER;
      cmotsin        NUMBER;
   BEGIN
      -- Buscamos datos de la p?liza
      BEGIN
         SELECT sproduc, cactivi
           INTO v_sproduc, v_cactivi
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'f_simulacion_rescate:datos seguro', NULL,
                        'psseguro =' || psseguro || ' pcagente =' || pcagente || ' pccausin ='
                        || pccausin || 'pimport =' || pimport || 'pfecha =' || pfecha,
                        SQLERRM);
            RETURN 101919;   --error al leer datos de la tabla seguros
      END;

      -- buscamos la garant?a a la cual se asigna el rescate
      BEGIN
         SELECT DISTINCT sgcm.cgarant
                    INTO w_cgarant
                    FROM sin_gar_causa_motivo sgcm, sin_causa_motivo scm, garanpro g
                   WHERE sgcm.scaumot = scm.scaumot
                     AND scm.ccausin = pccausin
                     AND sgcm.sproduc = v_sproduc
                     AND sgcm.sproduc = g.sproduc
                     AND sgcm.cgarant = g.cgarant
                     AND g.ctipgar <> 8;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'f_simulacion_rescate', NULL,
                        'error al buscar la garant?a psseguro =' || psseguro || ' pcagente ='
                        || pcagente || ' pccausin =' || pccausin || 'pimport =' || pimport
                        || 'pfecha =' || pfecha,
                        SQLERRM);
            RETURN 110448;   -- el producto no est? parametrizado correctamente
      END;

      --
      IF pccausin = 5 THEN   --rescate parcial
         --
         IF pctipcal = 3 THEN
            cmotsin := 5;
         ELSE
            cmotsin := 0;
         END IF;

         --
         ximport := pimport;
         num_err := pac_sin_formula.f_simu_calc_sin(psseguro, NULL, v_cactivi, w_cgarant,
                                                    v_sproduc, pfecha, pfecha, 5, cmotsin,
                                                    ximport, NULL, 1, pimppenali);
      ELSE
         -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
         IF NVL(f_parproductos_v(v_sproduc, 'RECALC_PAGOSVAL'), 1) = 0 THEN
            ximport := pimport;
         ELSE
            -- Fin Bug 13829
            ximport := NULL;
         END IF;

         num_err := pac_sin_formula.f_simu_calc_sin(psseguro, NULL, v_cactivi, w_cgarant,
                                                    v_sproduc, pfecha, pfecha, 4, 0, ximport,
                                                    NULL, 1, pimppenali, pimprcm, ppctreten);
      END IF;

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      res := pac_sin_formula.f_retorna_valores;
      pac_sin_formula.p_borra_mensajes;
      RETURN 0;
   END f_simulacion_rescate;

   FUNCTION f_sol_rescate(
      psseguro IN seguros.sseguro%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pcmoneda IN eco_codmonedas.cmoneda%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pccausin IN sin_codcausa.ccausin%TYPE,
      pimport IN NUMBER,
      pfecha IN DATE,
      pipenali IN sin_tramita_reserva.ipenali%TYPE,
      pireduc IN NUMBER,
      pireten IN NUMBER,
      pirendi IN NUMBER,
      pnivel IN NUMBER,
      pimprcm IN NUMBER DEFAULT NULL,   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      ppctreten IN NUMBER DEFAULT NULL,   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      pcmotresc IN NUMBER DEFAULT NULL)   -- Bug 18913 - APD - 01/07/2011
      RETURN NUMBER IS
      rec_pend       pac_anulacion.recibos_pend;
      rec_cobr       pac_anulacion.recibos_cob;

      CURSOR recibos_pendientes IS
         SELECT r.nrecibo, m.fmovini, r.fefecto
           FROM recibos r, movrecibo m
          WHERE r.sseguro = psseguro
            AND NVL(f_cestrec(r.nrecibo, NULL), 0) = 0
            AND m.nrecibo = r.nrecibo
            AND m.fmovfin IS NULL
            AND pac_adm.f_es_recibo_ahorro(r.nrecibo) = 1;

      nrec_pend      NUMBER := 0;
      xpersona       NUMBER;
      num_err        NUMBER;
      xnmovini       NUMBER;
      xtipo          NUMBER;
      xnsinies       sin_siniestro.nsinies%TYPE;
      xcmotmov       NUMBER := 112;   --Retencion por rescate
      xfrom          VARCHAR2(1000);
      xto2           VARCHAR2(1000);
      xto            VARCHAR2(1000);
      xasunto        VARCHAR2(1000);
      xmessage       VARCHAR2(4000);
      reg_seg        seguros%ROWTYPE;
      v_norden       NUMBER;
   BEGIN
       /*
                                                                                                                                                                                                                                                                                                                                                                         {obtenemos los datos de la poliza}
      */
      BEGIN
         SELECT *
           INTO reg_seg
           FROM seguros
          WHERE sseguro = psseguro;
      END;

       /*
                                                                        {busqueda de recibos pendientes}
      */
      FOR c IN recibos_pendientes LOOP
         -- 16465 - SMF, si no fan servir llibreta nom?s anulem els que tenen efecte posterior a la data d'efecte al suplement.
         IF NVL(f_parproductos_v(psproduc, 'AHOSINLIBRETA'), 0) = 0
            OR c.fefecto > pfecha THEN
            rec_pend(nrec_pend).nrecibo := c.nrecibo;
            rec_pend(nrec_pend).fmovini := c.fmovini;
            rec_pend(nrec_pend).fvencim := NULL;
            rec_pend(nrec_pend).fefecto := c.fefecto;
            nrec_pend := nrec_pend + 1;
         END IF;
      END LOOP;

      IF nrec_pend > 0 THEN
         nrec_pend := 1;
      END IF;

      /*
                                                                                                         {anulamos recibos, si existen pdtes}
      */
      IF nrec_pend = 1
         AND(pccausin IN(3, 4)) THEN   -- rescate total
         num_err := pac_anulacion.f_baja_rec_pend(f_sysdate, rec_pend);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      /*
                                                                                                                                                {Creamos el siniestro asociado a la demanda de rescate}
      */
      IF pac_sin_rescates.f_vivo_o_muerto(psseguro, 2, TRUNC(pfecha)) > 0 THEN   -- hay alg?n asegurado fallecido
         BEGIN
            SELECT norden
              INTO v_norden
              FROM asegurados
             WHERE sseguro = psseguro
               AND ffecmue IS NULL
               AND ffecfin IS NULL;   -- BUG11183:DRA:30/09/2009
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 120007;   -- error al leer de ASEGURADOS
         END;
      ELSE
         v_norden := 1;
      END IF;

      DELETE FROM tmp_primas_consumidas
            WHERE sseguro = psseguro;

      -- Bug 18913 - APD - 01/07/2011 - se añade el parametro pcmotresc
      num_err := pac_sin_rescates.f_gest_siniestro(psseguro, v_norden, TRUNC(pfecha), pccausin,
                                                   pcidioma, pimport, pipenali, pirendi,
                                                   pireten, pireduc, pnivel, xnsinies, pimprcm,
                                                   ppctreten, pcmotresc);

      -- fin Bug 18913 - APD - 01/07/2011
      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      BEGIN
         INSERT INTO primas_consumidas
                     (sseguro, nnumlin, nriesgo, norden, ipricons, ircm, fecha, frescat,
                      cestado)
            SELECT sseguro, nnumlin, nriesgo, norden, ipricons, ircm, fecha, frescat, 1
              FROM tmp_primas_consumidas
             WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'f_sol_rescate', 1,
                        'Error al reservar las primas consumidas', SQLERRM);
            RETURN 152110;   --{Error al reservar les primes consumides}
      END;

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_sol_rescate_total', 1, 'Error no controlado',
                     SQLERRM);
         RETURN 140999;   --{Error no controlado}
   END f_sol_rescate;

   FUNCTION f_es_rescatable(
      psseguro IN seguros.sseguro%TYPE,
      pfmovimi IN DATE,
      pccausin IN sin_codcausa.ccausin%TYPE,
      pirescate IN NUMBER)
      RETURN NUMBER IS
      /*
                                                                                                                                                                                                                                                                   {Funci?n que nos indica si le podemos realizar rescates a una poliza
       = 0 .- Si se le pueden hacer m?s rescates
       <>0 .- No se le puede hacer rescates a las polizas.}
      */
      reg_seg        seguros%ROWTYPE;
      xanys          NUMBER;
      xiniran        NUMBER;
      xfinran        NUMBER;
      xmaxano        NUMBER;
      ximaximo       NUMBER;
      ximinimo       NUMBER;
      xnrescat       NUMBER;
      xcmovimi       NUMBER;
      v_fecha        DATE;
      v_frevant      DATE;
      -- RSC 18/03/2008
      xtmaxano       NUMBER;
      vimaximo       NUMBER;
      num_err        NUMBER;
      -- Bug 13296 - RSC - 22/02/2010 - CEM - Revisi?n m?dulo de rescates
      v_ctipmov      NUMBER;
      v_frevisio     DATE;
      v_crealiza     cfg_accion.crealiza%TYPE;
      -- Fin Bug 13296

      -- Bug 20241 - RSC - 28/11/2011 - LCOL_T004-Parametrización de Rescates (retiros)
      v_cgarant      garanseg.cgarant%TYPE;
      v_existe       NUMBER;
   -- Fin bug 20241
   BEGIN
      /*
                                       {obtenemos los datos de la poiza}
      */
      BEGIN
         SELECT *
           INTO reg_seg
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'f_es_rescatable.seguros', NULL,
                        'Error no controlado', SQLERRM);
            RETURN 101903;   --{Seguro no encontrado en la tabla seguros}
      END;

      -- BUG 16903 - 03/12/2010 - JMP - Bloquear rescates si fecha de revisión anterior al efecto del rescate.
      BEGIN
         SELECT frevisio
           INTO v_frevisio
           FROM seguros_aho
          WHERE sseguro = psseguro;

         num_err := pac_cfg.f_get_user_accion_permitida(f_user, 'RESCATE_NO_REVISA',
                                                        reg_seg.sproduc, reg_seg.cempres,
                                                        v_crealiza);

         IF num_err <> 1 THEN
            IF v_frevisio < pfmovimi THEN
               RETURN 9901722;   -- La fecha de revisión es anterior al efecto del rescate
            END IF;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;

      -- Bug 20241 - RSC - 28/11/2011 - LCOL_T004-Parametrización de Rescates (retiros)
      SELECT DISTINCT s.cgarant
                 INTO v_cgarant
                 FROM sin_gar_causa_motivo s, sin_causa_motivo sc, seguros ss, garanpro g
                WHERE s.scaumot = sc.scaumot
                  AND sc.ccausin = pccausin
                  AND s.sproduc = ss.sproduc
                  AND ss.sseguro = psseguro
                  AND ss.sproduc = g.sproduc
                  AND s.cgarant = g.cgarant
                  AND g.ctipgar <> 8;

      SELECT COUNT(*)
        INTO v_existe
        FROM garanseg
       WHERE sseguro = psseguro
         AND cgarant = v_cgarant
         AND((finiefe <= pfmovimi)
             AND(ffinefe IS NULL
                 OR ffinefe > pfmovimi));

      IF v_existe = 0 THEN
         RETURN 9902853;
      END IF;

      -- Fin Bug 20241

      -- Bug 13296 - RSC - 22/02/2010 - CEM - Revisi?n m?dulo de rescates
      --IF NVL(f_parproductos_v(reg_seg.sproduc, 'EVOLUPROVMATSEG'), 0) = 1 THEN
      --   BEGIN
      --     SELECT frevant
      --        INTO v_frevant
      --        FROM seguros_aho
      --       WHERE sseguro = psseguro;
      --   EXCEPTION
      --      WHEN OTHERS THEN
      --         p_tab_error(f_sysdate, f_user, 'f_es_rescatable.seguros_aho', NULL,
      --                     'Error no controlado', SQLERRM);
      --         RETURN 101903;   --{Seguro no encontrado en la tabla seguros}
      --   END;
      --
      --   v_fecha := NVL(v_frevant, reg_seg.fefecto);
      --ELSE
      --   v_fecha := reg_seg.fefecto;
      --END IF;
      --
      --xanys := MONTHS_BETWEEN(pfmovimi, v_fecha) / 12;
      SELECT DECODE(pccausin, 4, 3, 5, 2, pccausin)
        INTO v_ctipmov
        FROM DUAL;

      xanys := calc_rescates.f_get_anyos_porcenpenali(psseguro,
                                                      TO_NUMBER(TO_CHAR(pfmovimi, 'yyyymmdd')),
                                                      v_ctipmov);

      -- Fin Bug 13296

      -- CPM 23/12/05: Se redondea con 3 decimales para coger el + un d?a.
      --  Se tiene en cuenta que el la codificaci?n de ctipmov en PRODTRARESC es
      -- diferente a la codificaci?n de ccausin:
      -- ccausin = 4 (rescate total) ctipmov = 3
      -- ccausin = 5 (rescate parcial) ctipmov = 2
      BEGIN
         SELECT niniran, nfinran, nmaxano, imaximo, iminimo, tmaxano
           INTO xiniran, xfinran, xmaxano, ximaximo, ximinimo, xtmaxano
           FROM detprodtraresc d, prodtraresc p
          WHERE d.sidresc = p.sidresc
            AND p.sproduc = reg_seg.sproduc
            AND p.ctipmov = DECODE(pccausin, 4, 3, 5, 2, pccausin)
            -- Bug 14802 - JRH - 01/06/2010 - JRH - Error validaci?n rescates
            AND p.finicio <= pfmovimi   -- pfmovimi en lugar de fecefecto
            AND((p.ffin > pfmovimi   -- Fi Bug 14802 - JRH - 01/06/2010
                 AND p.ffin IS NOT NULL)
                OR(p.ffin IS NULL))
            AND d.niniran = (SELECT MIN(dp.niniran)
                               FROM detprodtraresc dp
                              WHERE dp.sidresc = d.sidresc
                                AND ROUND(xanys, 3) BETWEEN dp.niniran AND dp.nfinran);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 152065;
      --{No se ha encontrado parametrizaci?n para este rescate}
      END;

      IF pccausin = 5 THEN
         IF pirescate < NVL(ximinimo, pirescate) THEN
            --{El importe no se encuentra entre los m?ximos y m?nimos para hacer un rescate}
            RETURN 152066;
         END IF;

         num_err := pac_sin_formula.f_imaximo_rescatep(psseguro, pfmovimi, 5, vimaximo);

         IF num_err <> 0 THEN
            RETURN 180809;
         END IF;

         IF NVL(vimaximo, ximinimo) < ximinimo THEN   -- El valor m?ximo de rescate es menor que el doble del valor m?nimo
            RETURN 180810;   --Provisi?n matem?tica inferior al m?ximo necesario para solicitar rescate parcial.
         END IF;

         -- El importe de la provisi?n matem?tica, despu?s del rescate,
         -- no podr? ser inferior a 6.000 (ximinimo).
         IF pirescate > NVL(vimaximo, pirescate) THEN
            RETURN 152066;
         END IF;

         xcmovimi := 33;   --{Rescate parcial}

         IF xtmaxano = 1 THEN
            BEGIN
               SELECT COUNT(1)
                 INTO xnrescat
                 FROM ctaseguro
                WHERE sseguro = psseguro
                  AND cmovimi = xcmovimi
                  AND fvalmov BETWEEN ADD_MONTHS(reg_seg.fefecto,(TRUNC(xanys)) * 12)
                                  AND ADD_MONTHS(reg_seg.fefecto,(TRUNC(xanys) + 1) * 12);
            END;
         ELSE
            BEGIN
               SELECT COUNT(1)
                 INTO xnrescat
                 FROM ctaseguro c, sin_siniestro sini, sin_movsiniestro sm
                WHERE c.nsinies = sini.nsinies
                  AND sini.nsinies = sm.nsinies
                  AND sm.nmovsin = (SELECT MAX(nmovsin)
                                      FROM sin_movsiniestro
                                     WHERE nsinies = sm.nsinies)
                  AND c.sseguro = psseguro
                  AND c.cmovimi = xcmovimi
                  AND sm.cestsin NOT IN(2, 3)   -- 2= Anulado, 3 = Rechazado
                  AND c.fvalmov BETWEEN ADD_MONTHS(reg_seg.fefecto, xiniran * 12)
                                    AND ADD_MONTHS(reg_seg.fefecto, xfinran * 12);
            END;
         END IF;

         IF xnrescat >= xmaxano THEN
            RETURN 109548;   -- Ha superado el maximo de rescates permitidos
         END IF;
      ELSE   -- Rescate total
         IF pirescate < NVL(ximinimo, pirescate)
            OR pirescate > NVL(ximaximo, pirescate) THEN
            RETURN 152066;
         --{El importe no se encuentra entre los m?ximos y m?nimos para hacer un rescate}
         END IF;

         xcmovimi := 34;   --{Rescate total}

         BEGIN
            SELECT COUNT(1)
              INTO xnrescat
              FROM ctaseguro c, sin_siniestro sini, sin_movsiniestro sm
             WHERE c.nsinies = sini.nsinies
               AND sini.nsinies = sm.nsinies
               AND c.sseguro = psseguro
               AND c.cmovimi = xcmovimi
               AND sm.nmovsin = (SELECT MAX(nmovsin)
                                   FROM sin_movsiniestro
                                  WHERE nsinies = sm.nsinies)
               AND sm.cestsin NOT IN(2, 3)   -- 2= Anulado, 3 = Rechazado
               AND c.fvalmov BETWEEN ADD_MONTHS(reg_seg.fefecto, xiniran * 12)
                                 AND ADD_MONTHS(reg_seg.fefecto, xfinran * 12);
         END;

         IF xnrescat >= xmaxano THEN
            RETURN 109548;   -- Ha superado el maximo de rescates permitidos
         END IF;
      END IF;

      RETURN 0;   --Si se le pueden hacer nuevos rescates
   END f_es_rescatable;

   FUNCTION f_sit_rescate(
      psseguro IN seguros.sseguro%TYPE,
      pnmovimi IN movseguro.nmovimi%TYPE)
      RETURN NUMBER IS
       /*
                                                                                                                                                                           {Funci?n que nos devulve el estado de  una poliza
        0.- Pendiente
       1.- Realizado
       2.- Denegado
       3.- Transferido
       4.- Error
       }
      */
      xresulta       NUMBER;
      xmaxmov        NUMBER;
      xcmovseg       NUMBER;
      xcmotmov       NUMBER;
   BEGIN
      BEGIN
         SELECT MAX(nmovimi)
           INTO xmaxmov
           FROM movseguro
          WHERE sseguro = psseguro;
      END;

      SELECT cmovseg, cmotmov
        INTO xcmovseg, xcmotmov
        FROM movseguro
       WHERE nmovimi = pnmovimi
         AND sseguro = psseguro;

      IF xcmotmov NOT IN(110) THEN
         RETURN 4;   --{No es un movimiento de sol. de rescate}
      END IF;

      --{Si es el ?ltimo movimiento , es porque a?n ni se ha Realizado, ni Transferido}
      IF xmaxmov = pnmovimi THEN
         --{Miramos el tipo de movimiento Pendiente, si es suplemento}
         IF xcmovseg = 10 THEN
            xresulta := 0;   --{aun no se ha tratado}
         ELSIF xcmovseg = 52 THEN
            xresulta := 2;   --{se ha rechazado el motivo}
         ELSE
            xresulta := 4;   --{No deberia pasar por aqu?}
         END IF;
      ELSE
         xresulta := 1;
      --{De momento ponemos realizado para los transferidos y los aceptados}
      END IF;

      RETURN xresulta;
   END f_sit_rescate;

   FUNCTION f_rescate_total_abierto(psseguro IN seguros.sseguro%TYPE, pabierto IN OUT NUMBER)
      RETURN NUMBER IS
      /*
                                                                           {Funci?n que nos muestra si una p?liza tiene una solicitud de rescate abierta
           Si pabierto = 0.- Sin rescate total abierto.
                  1.- Rescate total abierto.
          Retorna 0.- Sin errores.
                 <> 0.- Alg?n error.
          }
         */
      numerr         NUMBER;
      e_param_error  EXCEPTION;
   BEGIN
      numerr := 0;

      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT DECODE(COUNT(*), 0, 0, 1)
        INTO pabierto
        FROM sin_siniestro s, sin_movsiniestro sm
       WHERE s.sseguro = psseguro
         AND s.ccausin = 4   -- Siniestro por rescate total
         AND s.nsinies = sm.nsinies
         AND sm.nmovsin = (SELECT MAX(nmovsin)
                             FROM sin_movsiniestro
                            WHERE nsinies = sm.nsinies)
         AND sm.cestsin = 0;   -- Estado siniestro = 'Abierto'

      RETURN numerr;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, 'pac_sin_rescates.f_rescate_total_abierto', 0,
                     'sseguro=' || psseguro, 'Error en el paso de par?metros.');
         numerr := 107839;
         RETURN(numerr);
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sin_rescates.f_rescate_total_abierto', 1,
                     'sseguro=' || psseguro, SQLERRM);
         numerr := 105144;
         RETURN(numerr);
   END f_rescate_total_abierto;

   /*************************************************************************
                                                                                                                                                                                                                                                                                                                                                                                            Funci?n destinada al c?lculo de la retenci?n, rcm, reducci?n y conpensaciones
      fiscales, etc. y configurar los valores de la tabla PRIMAS_CONSUMIDAS a la hora
      de solicitar un rescate.
      param in psesion  : Identificador de sesion
      param in psseguro : Identificador de seguro
      param in pnriesgo : Identificador de riesgo
      param in pcgarant : Identificador de garant?a
      param in pfefecto : Fecha efecto
      param in pfrescat : Fecha de rescate
      param in pctipres : Tipo de rescate
      param in pirescate: Importe de rescate
      param in pipenali : Importe de penalizaci?n
      param in pmoneda  : Moneda
      param out pireten : Importe de retenci?n
      param out pireduc : Importe de reducci?n
      param out pirendi : Rendimiento
      return            : NUMBER
   *************************************************************************/
   FUNCTION f_retencion_simulada(
      psesion IN NUMBER,
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN riesgos.nriesgo%TYPE,
      pcgarant IN codigaran.cgarant%TYPE,
      pfefecto IN seguros.fefecto%TYPE,   -- fecha de efecto (d?a que se hace)
      pfrescat IN DATE,   -- fecha de rescate
      pctipres IN NUMBER,   -- tipo de rescate 31-vencimiento, 33-rescate parcial, 34.- rescate total
      pirescate IN sin_tramita_reserva.icaprie%TYPE,   -- importe de rescate (icapris
      pipenali IN sin_tramita_reserva.ipenali%TYPE,   -- importe de penalizaci?n
      pmoneda IN eco_codmonedas.cmoneda%TYPE,
      pireten OUT NUMBER,   -- importe de retenci?n
      pireduc OUT NUMBER,   -- importe de reducci?n
      pirendi OUT NUMBER)   -- RCM
      RETURN NUMBER IS
      r              NUMBER;   -- Rendimiento total antes de reducciones
      rt             NUMBER;   -- Rendimiento asociado a la prima
      rtr            NUMBER;   -- Rendimiento reducido
      rtra           NUMBER;   -- Rendimiento reducido por antig?edad
      xircm          NUMBER;
      sumrt          NUMBER;   -- Sumatorio de rendimientos antes de reducciones
      sumpa          NUMBER;   -- Sumatorio de prestaciones pagadas
      sumra          NUMBER;   -- Sumatorio de rendimientos asociados a prestaciones
      rbruto         NUMBER;   -- Suma de rendimientos reducidos
      red            NUMBER;   -- Porcentaje de reducci?n
      red_aux        NUMBER;   -- Porcentaje de reducci?n con el antiguo IRPF
      -- Se graba pero no reduce el valor del rescate
      ret            NUMBER;   -- Porcentaje de retenci?n
      ireduc         NUMBER;   -- importe de reducci?n
      xncoef_regtrans NUMBER;   -- coeficiente a aplicar a rt para obtener el rcm
      -- base al cual se aplicar? el % de reduc. trans.
      w_ibrut_regtrans NUMBER;   -- importe bruto RCM al cual se aplica el % de reduc. Trans.
      rtr_regtrans   NUMBER;   -- RCM reducido despu?s de reg. trans
      sumireduc      NUMBER;   --SUMATORIO DE REDUCCIONES
      xrcmneto       NUMBER;   -- RCM NETO
      w_ireg_trans_aux NUMBER;   -- importe red. trans. con irpf anteriror a 2007
      w_ircm_netocomp NUMBER;   -- RCM NETO con irpf anterior a 2007
      resto          NUMBER;
      primasaportadas NUMBER;
      rescate_pend   NUMBER := 0;
      rescate_acum   NUMBER;
      sumprim        NUMBER;
      kat            NUMBER;
      sumatoriobruto NUMBER;
      sumatoriobruto_1 NUMBER;
      sumando        NUMBER;
      sumarentas     NUMBER;
      xcactivi       NUMBER;
      xsproduc       NUMBER;
      xfefecto       DATE;
      xcumple        NUMBER;
      xsumpri        NUMBER;
      xsumppa        NUMBER;
      xanys          NUMBER;
      xerror         NUMBER;
      xcuantos       NUMBER := 0;
      xcoef          NUMBER := 0;
      xtipo          NUMBER := 0;
      xirescate      NUMBER := 0;
      xipenali       NUMBER := 0;
      xreducida      NUMBER := 0;
      xredbruta      NUMBER := 0;
      xredreduc      NUMBER := 0;
      xpago          NUMBER := 0;
      xpago_parcial  NUMBER := 0;
      xreducida_parcial NUMBER := 0;
      xredbruta_parcial NUMBER := 0;
      xredreduc_parcial NUMBER := 0;
      sum_pago_parcial NUMBER := 0;
      sum_redu_parcial NUMBER := 0;
      sum_rbru_parcial NUMBER := 0;
      sum_rred_parcial NUMBER := 0;
      xretenparcial  NUMBER := 0;
      w_orden        NUMBER;
      w_preg_trans   NUMBER;
      w_ireg_trans   NUMBER;
      vpais          NUMBER(3);
      xfmuerte       DATE;
      xmuerto        NUMBER;
      xsperson       NUMBER;
      xcuantos_resc  NUMBER;
      w_error        NUMBER;
      --RSC 26/03/2008
      primasconsum   NUMBER;
      -- Bug 11227 - APD - 25/09/2009
      sumresto       NUMBER;
      vpasexec       NUMBER := 0;

      CURSOR c_asegurados IS
         SELECT   sperson, norden
             FROM asegurados
            WHERE sseguro = psseguro
              AND ffecmue IS NULL
              AND ffecfin IS NULL   -- BUG11183:DRA:30/09/2009
         ORDER BY norden;

      aseg           c_asegurados%ROWTYPE;

      FUNCTION f_preduc_trans(pfecha IN DATE)
         RETURN NUMBER IS
      BEGIN
         IF pfecha BETWEEN TO_DATE('01/01/1985', 'dd/mm/yyyy')
                       AND TO_DATE('31/12/1987', 'dd/mm/yyyy') THEN
            RETURN 1;
         ELSIF pfecha BETWEEN TO_DATE('01/01/1988', 'dd/mm/yyyy')
                          AND TO_DATE('31/12/1988', 'dd/mm/yyyy') THEN
            RETURN 0.9996;
         ELSIF pfecha BETWEEN TO_DATE('01/01/1989', 'dd/mm/yyyy')
                          AND TO_DATE('31/12/1989', 'dd/mm/yyyy') THEN
            RETURN 0.8568;
         ELSIF pfecha BETWEEN TO_DATE('01/01/1990', 'dd/mm/yyyy')
                          AND TO_DATE('31/12/1990', 'dd/mm/yyyy') THEN
            RETURN 0.7140;
         ELSIF pfecha BETWEEN TO_DATE('01/01/1991', 'dd/mm/yyyy')
                          AND TO_DATE('31/12/1991', 'dd/mm/yyyy') THEN
            RETURN 0.5712;
         ELSIF pfecha BETWEEN TO_DATE('01/01/1992', 'dd/mm/yyyy')
                          AND TO_DATE('31/12/1992', 'dd/mm/yyyy') THEN
            RETURN 0.4284;
         ELSIF pfecha BETWEEN TO_DATE('01/01/1993', 'dd/mm/yyyy')
                          AND TO_DATE('31/12/1993', 'dd/mm/yyyy') THEN
            RETURN 0.2856;
         ELSIF pfecha BETWEEN TO_DATE('01/01/1994', 'dd/mm/yyyy')
                          AND TO_DATE('31/12/1994', 'dd/mm/yyyy') THEN
            RETURN 0.1428;
         ELSE
            RETURN 0;
         END IF;
      END f_preduc_trans;
   BEGIN
      vpasexec := 1;

      -- borramos la tabla temporal de primas consumidas
      DELETE      tmp_primas_consumidas
            WHERE sseguro = NVL(psseguro, 0)
              AND nriesgo = pnriesgo;

      vpasexec := 2;

      DELETE      primas_consumidas
            WHERE sseguro = NVL(psseguro, 0)
              AND nriesgo = pnriesgo
              AND cestado = 1;

      vpasexec := 3;

      IF pac_sin_rescates.f_vivo_o_muerto(psseguro, 2, pfrescat) > 0
         AND pac_sin_rescates.f_vivo_o_muerto(psseguro, 1, pfrescat) > 0 THEN
         xmuerto := 1;

         BEGIN
            SELECT ffecmue
              INTO xfmuerte
              FROM asegurados
             WHERE sseguro = psseguro
               AND ffecmue IS NOT NULL;
         END;
      ELSE
         xmuerto := 0;
         xfmuerte := NULL;
      END IF;

      vpasexec := 4;
      xcuantos := pac_sin_rescates.f_vivo_o_muerto(psseguro, 1, pfrescat);
      vpasexec := 5;
      xirescate := ROUND(pirescate / xcuantos, 5);
      vpasexec := 6;
      xipenali := ROUND(pipenali / xcuantos, 5);
      vpasexec := 7;
      xpago := ROUND(pirescate / xcuantos, 5);
      vpasexec := 8;
      rescate_pend := ROUND(pirescate / xcuantos, 5);
      xcumple := 0;
      vpasexec := 9;

      -- Cuenta cuantos rescate PARCIALES lleva esta p?liza en el a?o.
      IF pfrescat >= TO_DATE('01/01/2003', 'dd/mm/yyyy') THEN
         IF pctipres IN(33) THEN
            vpasexec := 10;

            SELECT COUNT(*)
              INTO xcuantos_resc
              FROM ctaseguro
             WHERE sseguro = psseguro
               AND TO_NUMBER(TO_CHAR(fvalmov, 'yyyy')) = TO_NUMBER(TO_CHAR(pfrescat, 'yyyy'))
               AND cmovimi IN(33);

            IF (xcuantos_resc + 1) > 1 THEN
               xcumple := 2;   -- Se le aplicara deducci?n 0
            END IF;
         END IF;
      END IF;

      vpasexec := 11;

      SELECT NVL(SUM(ipricons), 0) + NVL(SUM(ircm), 0), NVL(SUM(ircm), 0)
        INTO sumpa, sumra
        FROM primas_consumidas
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND fecha < pfrescat;

      vpasexec := 12;

      --
      SELECT sproduc, cactivi, fefecto
        INTO xsproduc, xcactivi, xfefecto
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 13;

      -- Averig?o si se aplicara una deducci?n de coeficientes parametrizada o la m?xima, siempre
      -- y cuando no sobrepase el limite de 3 rescates parciales que ser? una deducci?n 0.
      IF xcumple = 0 THEN
         IF pctipres IN(31, 33, 34) THEN
            IF pfrescat >= TO_DATE('01/01/2003', 'dd/mm/yyyy') THEN
               IF xfefecto > TO_DATE('31/12/1994', 'DD/MM/YYYY') THEN
                  IF CEIL((pfrescat - xfefecto) / 365) > 8 THEN
                     xsumppa := 0;
                     xsumpri := 0;
                     vpasexec := 14;

                     FOR r IN
                        (SELECT (CASE
                                    WHEN fvalmov > NVL(xfmuerte, fvalmov) THEN iprima
                                    ELSE ROUND(iprima
                                               / pac_sin_rescates.f_vivo_o_muerto(psseguro, 1,
                                                                                  fvalmov),
                                               5)
                                 END)
                                - prima_consumida(psseguro, nnumlin, f_sysdate,
                                                  (CASE
                                                      WHEN fvalmov > NVL(xfmuerte, fvalmov) THEN NULL
                                                      ELSE pnriesgo
                                                   END)) prima,
                                fvalmov
                           FROM primas_aportadas
                          WHERE sseguro = psseguro
                            AND fvalmov <= pfrescat) LOOP
                        xsumpri := xsumpri + r.prima;
                        xsumppa := xsumppa +(r.prima *(pfrescat - r.fvalmov));
                     END LOOP;

                     vpasexec := 15;

                     -- BUG19054:DRA:13/07/2011:Inici
                     IF xsumpri = 0 THEN
                        p_tab_error(f_sysdate, f_user, 'pac_rescates.f_retencion_simulada',
                                    vpasexec, 'Primas incorrectas',
                                    'psseguro=' || psseguro || ', xsumpri=' || xsumpri
                                    || ', xsumppa=' || xsumppa);
                        RETURN 9902217;
                     END IF;

                     -- BUG19054:DRA:13/07/2011:Fi
                     xanys := CEIL((xsumppa / xsumpri) / 365);

                     IF xanys > 4 THEN
                        xcumple := 1;
                     ELSE
                        xcumple := 0;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;

      --
      sumprim := 0;
      sumatoriobruto := 0;
      sumatoriobruto_1 := 0;
      primasaportadas := 0;
      primasconsum := 0;
      vpasexec := 16;

      -- C?lculo del denominador para la determinaci?n del rendimiento a nivel prima
      FOR r IN (SELECT (CASE
                           WHEN fvalmov > NVL(xfmuerte, fvalmov) THEN iprima
                           ELSE ROUND(iprima
                                      / pac_sin_rescates.f_vivo_o_muerto(psseguro, 1, fvalmov),
                                      5)
                        END)
                       - prima_consumida(psseguro, nnumlin, f_sysdate,
                                         (CASE
                                             WHEN fvalmov > NVL(xfmuerte, fvalmov) THEN NULL
                                             ELSE pnriesgo
                                          END)) prima,
                       fvalmov,
                       prima_consumida(psseguro, nnumlin, f_sysdate,
                                       (CASE
                                           WHEN fvalmov > NVL(xfmuerte, fvalmov) THEN NULL
                                           ELSE pnriesgo
                                        END)) pconsum
                  FROM primas_aportadas
                 WHERE sseguro = psseguro
                   AND fvalmov <= pfrescat) LOOP
         vpasexec := 17;
         sumprim := sumprim + r.prima * GREATEST((pfrescat - r.fvalmov), 1) / 365;
         primasaportadas := primasaportadas + r.prima;
         primasconsum := primasconsum + r.pconsum;
      END LOOP;

      vpasexec := 18;
      -- RSC 19/03/2008 --> Para rescates parciales deberiamos realizar esta query en lugar de descontar las primas consumidas
      -- El problema esta en que la tabla primasaportadas no se varia al realizar un rescate.
      --C?lculo de PrimasAportadas
      -- RSC 25/03/2008 En primas aportadas ponemos las aportadas menos las consumidas
      w_error := pac_sin_formula.f_graba_param(psesion, 'IPRIMAS', primasaportadas);

      -- Las consumidas las restaremos al calcular r (RCM bruto) una pocas lineas mas abajo
      -- Bug 11227 - APD - 25/09/2009 - no es necesario sumar las primasconsum ya que despu?s
      -- al calcular r las vuelve a restar con las variables sumpa y sumra
      -- as? que si no se suman aqu? no se deben restar abajo
      --primasaportadas := primasaportadas + primasconsum;
      -- Fin Bug 11227 - APD - 25/09/2009
      BEGIN
         --C?lculo de Rentas
         SELECT NVL(SUM(NVL(isinret, 0) - NVL(ibase, 0)), 0)
           INTO sumarentas
           FROM pagosrenta
          WHERE sseguro = psseguro
            AND ffecefe <= ultima_hora(pfrescat);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 109617;   --{Persona no trobada}
      END;

      vpasexec := 20;

      -- Rendimiento total antes de reducciones
      --r := GREATEST(xirescate - xipenali -(primasaportadas - sumpa) - sumra, 0);
      -- la penalizaci?n se restar?n directamente de los rendimientos
      IF pctipres = 33 THEN
         -- Bug 11227 - APD - 25/09/2009 - se sustituye xirescate por
         -- round(calc_rescates.FvalrescTotAho(psesion, psseguro, to_number(to_char(pfrescat,'yyyymmdd')))/xcuantos,5)
         -- Adem?s, no es necesario restar la variables sumpa y sumra (primas consumidas)
         -- ya que realmente la variable primasaportadas son las primas aportadas menos las primas consumidas
         -- si se restan las variables sumpa y sumra estariamos restando 2 veces las primas consumidas
         --r := GREATEST(round(calc_rescates.FvalrescTotAho(psesion, psseguro, to_number(to_char(pfrescat,'yyyymmdd')))/xcuantos,5) - xipenali - (primasaportadas - sumpa) - sumra, 0);
         vpasexec := 21;
         -- bug 13296 - 22/02/2010 - AMC
         r :=
            GREATEST(ROUND(calc_rescates.fvalresctotaho(psesion, psseguro,
                                                        TO_NUMBER(TO_CHAR(pfrescat,
                                                                          'yyyymmdd')))
                           / xcuantos,
                           5)
                     - primasaportadas,
                     0);
      -- Fi bug 13296 - 22/02/2010 - AMC
      -- Fin Bug 11227 - APD - 25/09/2009
      ELSE
         -- Bug 11227 - APD - 25/09/2009 - no es necesario restar la variables sumpa y sumra (primas consumidas)
         -- ya que realmente la variable primasaportadas son las primas aportadas menos las primas consumidas
         -- si se restan las variables sumpa y sumra estariamos restando 2 veces las primas consumidas
         --r := xirescate - xipenali - (primasaportadas - sumpa) - sumra;
         vpasexec := 22;
         -- bug 13296 - 22/02/2010 - AMC
         r := xirescate - primasaportadas;
      -- Fi bug 13296 - 22/02/2010 - AMC
      -- Fin Bug 11227 - APD - 25/09/2009
      END IF;

      -- Fi bug 13296 - 22/02/2010 - AMC
      sumrt := 0;
      rbruto := 0;
      rescate_acum := 0;
      rtra := 0;
      xircm := 0;
      sumireduc := 0;
      sumresto := 0;   -- Bug 11227 - APD - 25/09/2009 - se inicializa la variable sumresto
      vpasexec := 23;

      -- C?lculo del rendimiento antes de reducciones a nivel de prima
      -- movimiento_ult := 0;
      FOR p IN (SELECT   sseguro, nnumlin, fvalmov, cmovimi,
                         (CASE
                             WHEN fvalmov > NVL(xfmuerte, fvalmov) THEN iprima
                             ELSE ROUND(iprima
                                        / pac_sin_rescates.f_vivo_o_muerto(psseguro, 1,
                                                                           fvalmov),
                                        5)
                          END)
                         - prima_consumida(psseguro, nnumlin, f_sysdate,
                                           (CASE
                                               WHEN fvalmov > NVL(xfmuerte, fvalmov) THEN NULL
                                               ELSE pnriesgo
                                            END)) imovimi
                    FROM primas_aportadas
                   WHERE sseguro = psseguro
                     AND fvalmov <= pfrescat
                ORDER BY fvalmov) LOOP
         vpasexec := 24;

         -- BUG19054:DRA:13/07/2011:Inici
         IF sumprim = 0 THEN
            p_tab_error(f_sysdate, f_user, 'pac_rescates.f_retencion_simulada', vpasexec,
                        'Primas incorrectas',
                        'psseguro=' || psseguro || ', p.imovimi=' || p.imovimi || ', sumprim='
                        || sumprim || ', r=' || r || ', xcoef=' || xcoef);
            RETURN 9902217;
         END IF;

         -- BUG19054:DRA:13/07/2011:Fi
         xcoef := p.imovimi *((pfrescat - p.fvalmov) / 365) / sumprim;
         rt := r * xcoef;
         sumando :=(p.imovimi + rt);
         sumatoriobruto := sumatoriobruto + sumando;
         kat := 1;
         vpasexec := 25;

         IF pctipres = 33 THEN
            IF p.imovimi = 0 THEN
               kat := 0;
            ELSIF xirescate > sumatoriobruto THEN
               kat := 1;
            ELSIF xirescate BETWEEN sumatoriobruto_1 AND sumatoriobruto THEN
               vpasexec := 26;
               kat := (xirescate - sumatoriobruto_1) /(p.imovimi + rt);
            ELSE
               kat := 0;
            END IF;

            rt := ROUND(rt * kat, 5);
         END IF;

         -- Bug 13296 - 22/02/2010  - AMC
         -- Bug 13367 - JRH - 24/02/2010 -  Comentado
         --rt := rt - xipenali;
         -- Fi Bug 13367 - JRH - 24/02/2010
         -- Fi Bug 13296 - 22/02/2010  - AMC
         rescate_acum := rescate_acum +(p.imovimi + rt);
         rescate_pend := xirescate - rescate_acum;
         resto := ROUND(p.imovimi * kat, 5);
         vpasexec := 27;

         IF p.imovimi > 0 THEN
            IF resto <> 0
               OR rt <> 0 THEN
               -- Grabaci?n de la prima consumida
               DECLARE
                  xxorden        NUMBER;
               BEGIN
                  vpasexec := 28;

                  SELECT NVL(MAX(norden), 0)
                    INTO xxorden
                    FROM primas_consumidas
                   WHERE sseguro = p.sseguro
                     AND nnumlin = p.nnumlin;

                  w_orden := xxorden + 1;
                  vpasexec := 29;

                  INSERT INTO tmp_primas_consumidas
                              (sseguro, nnumlin, norden, nriesgo, ipricons, ircm,
                               fecha, frescat, ndias, ncoefic, nanys,
                               preduc, ireduc, preg_trans, ireg_trans, ircm_neto,
                               ncoef_regtrans, ibrut_regtrans, rcmbrut_reducido)
                       VALUES (p.sseguro, p.nnumlin, xxorden + 1, pnriesgo, resto, rt,
                               p.fvalmov, pfrescat,(pfrescat - p.fvalmov), xcoef, xanys,
                               NULL, NULL, NULL, NULL, NULL,
                               NULL, NULL, NULL);

                  -- Bug 11227 - APD - 25/09/2009 - se guarda el total de primas consumidas
                  sumresto := sumresto + resto;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'pac_sin_rescates.f_retencion_simulada',
                                 vpasexec, 'error al grabar', SQLERRM);
                     RETURN NULL;
               END;
            END IF;
         END IF;

         vpasexec := 30;

         IF xcumple = 1 THEN
            xanys := 900;
         ELSE
            xanys := TRUNC((pfrescat - p.fvalmov) / 365, 3);
         END IF;

         vpasexec := 31;

         BEGIN
            -- ini Bug 0012803 - 19/02/2010 - JMF
            -- SELECT p.cpais, a.sperson
            --   INTO vpais, xsperson
            --   FROM personas p, asegurados a
            --  WHERE p.sperson = a.sperson
            --    AND a.sseguro = psseguro
            --    AND a.norden = pnriesgo;
            SELECT p.cpais, a.sperson
              INTO vpais, xsperson
              FROM per_detper p, asegurados a, seguros s
             WHERE s.sseguro = psseguro
               AND a.sseguro = s.sseguro
               AND a.norden = pnriesgo
               AND p.sperson = a.sperson
               AND p.cagente = ff_agente_cpervisio(s.cagente, f_sysdate, s.cempres);
         -- fin Bug 0012803 - 19/02/2010 - JMF
         EXCEPTION
            WHEN OTHERS THEN
               vpais := NVL(f_parinstalacion_n('PAIS_DEF'), 42);
         END;

         vpasexec := 32;

         IF vpais <> NVL(f_parinstalacion_n('PAIS_DEF'), 42) THEN
            xcumple := 3;   -- si es extranjero no se le aplica reducci?n
         END IF;

         vpasexec := 33;

         IF xcumple IN(0, 1) THEN
            red := NULL;

            -- Aplicamos el nuevo IRPF
            IF p.fvalmov >= TO_DATE('01/01/2007', 'dd/mm/yyyy')
               AND p.cmovimi = 1 THEN
               vpasexec := 34;
               -- Es una aportaci?n extraordinaria con el nuevo IRPF
               red_aux := fbuscapreduc(1, xsproduc, xcactivi, pcgarant,
                                       TO_NUMBER(TO_CHAR(p.fvalmov, 'yyyymmdd')), xanys);
            ELSE
               vpasexec := 35;

               -- Bug 9589 - 27/03/2009 - RSC - Incidencia en el c?lculo de compensaci?n fiscal en rescates
               -- Entre 20/01/2006 y 31/12/2006 no existe compensaci?n
               IF p.fvalmov < TO_DATE('20/01/2006', 'dd/mm/yyyy') THEN
                  red_aux := fbuscapreduc(1, xsproduc, xcactivi, pcgarant,
                                          TO_NUMBER(TO_CHAR(xfefecto, 'yyyymmdd')), xanys);
               ELSE
                  red_aux := 0;
               END IF;
            -- Fin Bug 9589 - 27/03/2009 - RSC - Incidencia en el c?lculo de compensaci?n fiscal en rescates
            END IF;

            vpasexec := 36;
            red := fbuscapreduc(1, xsproduc, xcactivi, pcgarant,
                                TO_NUMBER(TO_CHAR(pfrescat, 'yyyymmdd')), xanys);

            IF red IS NULL THEN
               RETURN 107710;   --{Registre NO trobat a ULFISCALE}
            END IF;
         ELSE
            red := 0;
         END IF;

         vpasexec := 37;
         --
         ireduc := rt *(red / 100);
         rtr := rt - ireduc;
         -- xrtra := xrtra + rtr; -- suma de rcm bruto reducido
         -- xircm := xircm + rt;  -- suma de rendimiento bruto
         vpasexec := 38;

         -- Reducci?n adicional (primas anteriores a 31/12/1994)
         IF p.fvalmov < TO_DATE('31/12/1994', 'dd/mm/yyyy') THEN
            vpasexec := 39;
            xncoef_regtrans := (TO_DATE('20/01/2006', 'dd/mm/yyyy') - p.fvalmov)
                               /(pfrescat - p.fvalmov);
            vpasexec := 40;
            w_ibrut_regtrans := rt * xncoef_regtrans;
            vpasexec := 41;
            w_preg_trans := f_preduc_trans(p.fvalmov);
            vpasexec := 42;
            w_ireg_trans := w_ibrut_regtrans * w_preg_trans;
            vpasexec := 43;
            w_ireg_trans_aux := rt *(1 -(red_aux / 100)) * w_preg_trans;   -- para calcular compensaci?n
         ELSE
            w_preg_trans := 0;
            w_ireg_trans := 0;
            xncoef_regtrans := 0;
            w_ibrut_regtrans := 0;
            w_ireg_trans_aux := 0;
         END IF;

         vpasexec := 45;

         IF p.fvalmov < TO_DATE('20/01/2006', 'dd/mm/yyyy') THEN
            --disposici?n transitoria decimotercera
            w_ircm_netocomp := rt -(rt * red_aux / 100) - w_ireg_trans_aux;
         ELSE
            w_ircm_netocomp := 0;
         END IF;

         vpasexec := 46;
         rtr_regtrans := rtr - NVL(w_ireg_trans, 0);
         --  rbruto := rbruto + rtr;
         --  sumrt := sumrt + rtr;
         sumatoriobruto_1 := sumatoriobruto;
         vpasexec := 47;

         UPDATE tmp_primas_consumidas
            SET nanys = xanys,
                preduc = red_aux / 100,
                ireduc =(rt * red_aux / 100),
                ircm_neto = rtr_regtrans,
                preg_trans = w_preg_trans,
                ireg_trans = w_ireg_trans,
                ncoef_regtrans = xncoef_regtrans,
                ibrut_regtrans = w_ibrut_regtrans,
                rcmbrut_reducido = rt *(1 -(red_aux / 100)),
                ircm_netocomp = w_ircm_netocomp,
                ireg_transcomp = w_ireg_trans_aux
          WHERE sseguro = p.sseguro
            AND nnumlin = p.nnumlin
            AND norden = w_orden
            AND nriesgo = pnriesgo;

         vpasexec := 48;
         sumrt := sumrt + rt;
         sumireduc := sumireduc + w_ireg_trans;
      END LOOP;

      -- Bug 13367 - JRH - 24/02/2010 -  Se resta al total
      sumrt := sumrt - xipenali;
      -- Fi Bug 13367 - JRH - 24/02/2010
      vpasexec := 49;

      -- Bug 11227 - APD - 25/09/2009 - se actualiza IPRIMAS con el total de primas consumidas
      IF sumresto IS NOT NULL THEN
         w_error := pac_sin_formula.f_graba_param(psesion, 'IPRIMAS', sumresto);
      END IF;

      -- Fin Bug 11227 - APD - 25/09/2009 - se actualiza IPRIMAS con el total de primas consumidas
      vpasexec := 50;
      --{Si es rescate total}
      xrcmneto := ROUND(sumrt, 5) - ROUND(sumireduc, 2);
      vpasexec := 51;
      --****** Buscamos el % de retenci?n
      ret := pac_sin_rescates.f_busca_preten(1, xsperson, xsproduc,
                                             TO_NUMBER(TO_CHAR(pfrescat, 'YYYYMMDD')));

      IF ret IS NULL THEN
         ret := 0;
      END IF;

      vpasexec := 52;
      xretenparcial := 0;
      xretenparcial := ROUND((xrcmneto * ret) / 100, 2);
      -- bug 13296 - 22/02/2010 - AMC
      pireten := GREATEST(xretenparcial, 0);
      pireduc := GREATEST(ROUND(sumireduc, 2), 0);
      pirendi := GREATEST(ROUND(sumrt, 2), 0);   --sumrt;
      -- Fi bug 13296 - 22/02/2010 - AMC
      vpasexec := 53;
      w_error := pac_sin_formula.f_graba_param(psesion, 'IRESRED', pireduc);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sin_rescates.f_retencion_simulada', vpasexec,
                     'error no controlado', SQLERRM);
         RETURN 140999;   --{Error no controlat}
   END f_retencion_simulada;

   FUNCTION f_finaliza_rescate(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN riesgos.nriesgo%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pmoneda IN eco_codmonedas.cmoneda%TYPE)
      RETURN NUMBER IS
      num_err        NUMBER;
      xnnumlin       NUMBER;
      xnnumlinshw    NUMBER;
      xcmovimi       NUMBER;
      xcmotmov       NUMBER := 511;
      reg_seg        seguros%ROWTYPE;
      rec_pend       pac_anulacion.recibos_pend;
      rec_cob        pac_anulacion.recibos_cob;
      fcuenta        DATE;
      ntraza         NUMBER;
      xivalora       NUMBER;
      -- RSC 13/12/2007
      seqgrupo       NUMBER;
      -- Variables para Ibex 35 Garantizado (PRODUCTO_MIXTO)
      vresceur       NUMBER;
      vrescibex      NUMBER;
      -- RSC 07/11/2008 -----
      vsaldof        NUMBER;
      vfsaldo        DATE;
      vclaveiprovac  NUMBER;
      vprovacibex    NUMBER;
      perror         NUMBER;
      v_ipenali      sin_tramita_reserva.ipenali%TYPE;
      -- Bug 12199 - RSC - 25/11/2009 - CRE201 - Incidencia suplemento de anulaci?n de garant?a por siniestro
      v_icaprisc     NUMBER;
      -- Fin Bug 12199

      -- Bug 20241 - RSC - 25/11/2011 - LCOL_T004-Parametrización de Rescates (retiros)
      v_ccausin      sin_siniestro.ccausin%TYPE;
      v_cmotsin      sin_siniestro.cmotsin%TYPE;
      v_icaprisc_pa  NUMBER := 0;
      v_icaprisc_shw NUMBER := 0;
      xivalora_pa    NUMBER := 0;
      xivalora_shw   NUMBER := 0;
      vresceur_pa    NUMBER := 0;
      vresceur_shw   NUMBER := 0;
      vrescibex_pa   NUMBER := 0;
      vrescibex_shw  NUMBER := 0;
      v_nmovimi      NUMBER;
      v_icapesp      NUMBER := 0;
   -- Fin Bug 20241
   BEGIN
      ntraza := 1;

      --{Obtenemos los datos del seguro}
      BEGIN
         SELECT *
           INTO reg_seg
           FROM seguros
          WHERE sseguro = psseguro;
      END;

      ntraza := 2;

      --{Actualizamos primas consumidas}
      UPDATE primas_consumidas
         SET cestado = 0
       WHERE sseguro = psseguro
         AND cestado = 1;

      ntraza := 3;
      --{Insertamos el movimiento en la libreta ctaseguro}
      --{obtenemos el numero de linea de ctaseguro}
      xnnumlin := pac_ctaseguro.f_numlin_next(psseguro);
      xnnumlinshw := pac_ctaseguro.f_numlin_next_shw(psseguro);
      ntraza := 5;

      -- Buscamos el tipo de movimiento
      BEGIN
         -- Bug 12199 - RSC - 25/11/2009 - CRE201 - Incidencia suplemento de anulaci?n de garant?a por siniestro
         -- Afegim , str.icaprie
         SELECT scm.cmovimi, i.fsinies, str.ipago, NVL(str.ipenali, 0), NVL(str.icaprie, 0)
           INTO xcmovimi, fcuenta, xivalora, v_ipenali, v_icaprisc
           FROM sin_siniestro i, seguros s, sin_causa_motivo scm, sin_gar_causa_motivo sgcm,
                sin_tramita_reserva str
          WHERE scm.ccausin = i.ccausin
            AND scm.cmotsin = i.cmotsin
            AND scm.scaumot = sgcm.scaumot
            AND s.sseguro = i.sseguro
            AND s.sproduc = sgcm.sproduc
            AND i.nsinies = pnsinies
            AND str.nsinies = i.nsinies
            AND str.cgarant = sgcm.cgarant
            AND str.ctipres = 1   -- jlb - 18423#c105054
            AND scm.cmovimi IS NOT NULL
            AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                                    str.cgarant, 'GAR_CONTRA_CTASEGURO'),
                    1) = 1   --Bug 20241 - RSC - 25/11/2011
            AND str.nmovres = (SELECT MAX(nmovres)
                                 FROM sin_tramita_reserva
                                WHERE nsinies = str.nsinies
                                  AND ntramit = str.ntramit
                                  AND cgarant = str.cgarant
                                  AND ctipres = 1   -- jlb - 18423#c105054
                                                 );
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            xcmovimi := NULL;
            xivalora := 0;
            v_ipenali := 0;
            v_icaprisc := 0;
         WHEN OTHERS THEN
            ntraza := 6;
            p_tab_error(f_sysdate, f_user, 'pac_sin_rescates.f_finaliza_rescate', ntraza,
                        'Error no controlado', SQLERRM);
            RETURN 140999;   -- Error no controlado
      END;

      -- Bug 20241 - RSC - 25/11/2011 - LCOL_T004-Parametrización de Rescates (retiros)
      SELECT ccausin, cmotsin
        INTO v_ccausin, v_cmotsin
        FROM sin_siniestro
       WHERE nsinies = pnsinies;

      -- Fin Bug 20241
      ntraza := 7;

      -- Bug 0013672 - FAL - 16/03/2010 -  Moviment llibreta pagament PPA. Recupera ?ltima fecha de pago del siniestro en funci?n del par?metro FCUENTA_FIN_SINIES
      IF NVL(pac_parametros.f_parempresa_n(reg_seg.cempres, 'FCUENTA_FIN_SINIES'), 0) = 1 THEN
         BEGIN
            SELECT MAX(fordpag)
              INTO fcuenta
              FROM sin_tramita_pago
             WHERE nsinies = pnsinies;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_sin_rescates.f_finaliza_rescate', ntraza,
                           'Error no controlado', SQLERRM);
               RETURN 140999;   -- Error no controlado
         END;
      END IF;

      -- Fin Bug 0013672 - FAL - 16/03/2010 - Recupera ?ltima fecha de pago del siniestro en funci?n del par?metro FCUENTA_FIN_SINIESTRO
      SELECT scagrcta.NEXTVAL
        INTO seqgrupo
        FROM DUAL;

      -- Generamos los movimientos de detalle en caso de producto Unit Linked
      IF NOT(v_ccausin = 4
             AND v_cmotsin = 2) THEN
         IF NVL(f_parproductos_v(reg_seg.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
            IF NVL(f_parproductos_v(reg_seg.sproduc, 'PRODUCTO_MIXTO'), 0) <> 1 THEN
               --Bug 20241 - RSC - 25/11/2011
               IF (NVL(pac_parametros.f_parproducto_n(reg_seg.sproduc, 'GRABA_PENALIZACION'),
                       0) IN(1, 2)) THEN
                  IF xivalora > 0 THEN
                     IF NVL(pac_parametros.f_parempresa_n(reg_seg.cempres,
                                                          'CTASEG_PAGO_PARCIAL'),
                            0) <> 1 THEN
                        num_err := pac_propio.f_reparto_shadow(psseguro, NULL, NULL, xivalora,
                                                               xivalora_pa, xivalora_shw);
                        -- Bug 12199 - RSC - 25/11/2009 - CRE201 - Incidencia suplemento de anulaci?n de garant?a por siniestro
                        num_err :=
                           pac_ctaseguro.f_insctaseguro
                                     (psseguro, f_sysdate, xnnumlin, fcuenta, fcuenta,
                                      xcmovimi,
                                      f_round(xivalora_pa,
                                              pac_monedas.f_moneda_producto(reg_seg.sproduc)),
                                      0, NULL, seqgrupo, 0, pnsinies, NULL, NULL);
                        -- Bug 12199
                        xnnumlin := xnnumlin + 1;

                        IF num_err <> 0 THEN
                           RETURN 102555;
                        END IF;

                        -- Bug 12199 - RSC - 25/11/2009 - CRE201 - Incidencia suplemento de anulaci?n de garant?a por siniestro
                        num_err := f_distribuye_ctaseguro(psseguro, xnnumlin, fcuenta,
                                                          xcmovimi, xivalora_pa, seqgrupo,
                                                          pnsinies);

                        -- Fin Bug 12199
                        IF num_err <> 0 THEN
                           RETURN 102555;
                        END IF;

                        IF pac_ctaseguro.f_tiene_ctashadow(psseguro, NULL) = 1 THEN
                           num_err :=
                              pac_ctaseguro.f_insctaseguro_shw
                                     (psseguro, f_sysdate, xnnumlinshw, fcuenta, fcuenta,
                                      xcmovimi,
                                      f_round(xivalora_shw,
                                              pac_monedas.f_moneda_producto(reg_seg.sproduc)),
                                      0, NULL, seqgrupo, 0, pnsinies, NULL, NULL);
                           -- Bug 12199
                           xnnumlinshw := xnnumlinshw + 1;

                           IF num_err <> 0 THEN
                              RETURN 102555;
                           END IF;

                           -- Bug 12199 - RSC - 25/11/2009 - CRE201 - Incidencia suplemento de anulaci?n de garant?a por siniestro
                           num_err := f_distribuye_ctaseguro_shw(psseguro, xnnumlinshw,
                                                                 fcuenta, xcmovimi,
                                                                 xivalora_shw, seqgrupo,
                                                                 pnsinies);

                           -- Fin Bug 12199
                           IF num_err <> 0 THEN
                              RETURN 102555;
                           END IF;
                        END IF;
                     END IF;
                  END IF;
               ELSE
                  IF v_icaprisc > 0 THEN
                     -- Fin Bug 20241
                     SELECT SUM(ireserva), SUM(ireservashw)
                       INTO v_icaprisc_pa, v_icaprisc_shw
                       FROM sin_tramita_prereserva_fnd
                      WHERE nsinies = pnsinies;

                     IF NVL(v_icaprisc_pa, 0) = 0 THEN
                        v_icaprisc_pa := v_icaprisc;
                     END IF;

                     IF NVL(v_icaprisc_shw, 0) = 0 THEN
                        v_icaprisc_shw := v_icaprisc;
                     END IF;

                     -- BUG 23116:ETM:20/09/2012   --INI
                     IF NVL(pac_parametros.f_parempresa_n(reg_seg.cempres,
                                                          'CTASEG_PAGO_PARCIAL'),
                            0) <> 1 THEN
                        -- Bug 12199 - RSC - 25/11/2009 - CRE201 - Incidencia suplemento de anulaci?n de garant?a por siniestro
                        num_err :=
                           pac_ctaseguro.f_insctaseguro
                                     (psseguro, f_sysdate, xnnumlin, fcuenta, fcuenta,
                                      xcmovimi,
                                      f_round(v_icaprisc_pa,
                                              pac_monedas.f_moneda_producto(reg_seg.sproduc)),
                                      0, NULL, seqgrupo, 0, pnsinies, NULL, NULL);
                        -- Bug 12199
                        xnnumlin := xnnumlin + 1;

                        IF num_err <> 0 THEN
                           RETURN 102555;
                        END IF;

                        -- Bug 12199 - RSC - 25/11/2009 - CRE201 - Incidencia suplemento de anulaci?n de garant?a por siniestro
                        num_err := f_distribuye_ctaseguro(psseguro, xnnumlin, fcuenta,
                                                          xcmovimi, v_icaprisc_pa, seqgrupo,
                                                          pnsinies);

                        -- Fin Bug 12199
                        IF num_err <> 0 THEN
                           RETURN 102555;
                        END IF;

                        IF pac_ctaseguro.f_tiene_ctashadow(psseguro, NULL) = 1 THEN
                           num_err :=
                              pac_ctaseguro.f_insctaseguro_shw
                                     (psseguro, f_sysdate, xnnumlinshw, fcuenta, fcuenta,
                                      xcmovimi,
                                      f_round(v_icaprisc_shw,
                                              pac_monedas.f_moneda_producto(reg_seg.sproduc)),
                                      0, NULL, seqgrupo, 0, pnsinies, NULL, NULL);
                           -- Bug 12199
                           xnnumlinshw := xnnumlinshw + 1;

                           IF num_err <> 0 THEN
                              RETURN 102555;
                           END IF;

                           -- Bug 12199 - RSC - 25/11/2009 - CRE201 - Incidencia suplemento de anulaci?n de garant?a por siniestro
                           num_err := f_distribuye_ctaseguro_shw(psseguro, xnnumlinshw,
                                                                 fcuenta, xcmovimi,
                                                                 v_icaprisc_shw, seqgrupo,
                                                                 pnsinies);

                           -- Fin Bug 12199
                           IF num_err <> 0 THEN
                              RETURN 102555;
                           END IF;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            ELSE   -- Ibex 35 Garantizado
               -- RSC 14/12/2007
               -- Obtencion de la parte de rescate a EUROPLAZO y la parte de rescate a Ibex 35
               vsaldof := ROUND(fbuscasaldo(NULL, psseguro, TO_CHAR(fcuenta, 'yyyymmdd')), 2);   -- Aqui tenemos Europlzao + Ibex 35
               vfsaldo := f_fechasaldo(psseguro, fcuenta);

               SELECT sfcm.cclave
                 INTO vclaveiprovac
                 FROM sin_for_causa_motivo sfcm, sin_gar_causa_motivo sgcm, productos pr
                WHERE sfcm.scaumot = sgcm.scaumot
                  AND sgcm.sproduc = pr.sproduc
                  AND pr.cramo = reg_seg.cramo
                  AND sfcm.ccampo = 'IPROVAC'
                  AND sgcm.ctramit = 0
                  AND f_pargaranpro_v(pr.cramo, pr.cmodali, pr.ctipseg, pr.ccolect,
                                      pac_seguros.ff_get_actividad(psseguro, pnriesgo, NULL),
                                      sgcm.cgarant, 'TIPO') = 3;

               perror := pac_calculo_formulas.calc_formul(vfsaldo, reg_seg.sproduc, 0, 48, 1,
                                                          psseguro, vclaveiprovac, vprovacibex,
                                                          NULL, NULL, 2, vfsaldo, 'R');
               -- Parte Europlazo del rescate
               vresceur := vsaldof - vprovacibex;   -- Descontamos la parte de Ibex 35 a fecha de ultimo saldo
               vprovacibex := 0;
               perror := pac_calculo_formulas.calc_formul(fcuenta, reg_seg.sproduc, 0, 48, 1,
                                                          psseguro, vclaveiprovac, vrescibex,
                                                          NULL, NULL, 2, fcuenta, 'R');

               -- BUG 23116:ETM:20/09/2012   --INI
               IF NVL(pac_parametros.f_parempresa_n(reg_seg.cempres, 'CTASEG_PAGO_PARCIAL'), 0) <>
                                                                                              1 THEN
                  num_err := pac_propio.f_reparto_shadow(psseguro, NULL, NULL, vresceur,
                                                         vresceur_pa, vresceur_shw);
                  -- Europlazo ----------
                  num_err :=
                     pac_ctaseguro.f_insctaseguro
                                     (psseguro, f_sysdate, xnnumlin, fcuenta, fcuenta,
                                      xcmovimi,
                                      f_round(vresceur_pa,
                                              pac_monedas.f_moneda_producto(reg_seg.sproduc)),
                                      0, NULL, seqgrupo, 0, pnsinies, NULL, NULL);
                  xnnumlin := xnnumlin + 1;

                  IF num_err <> 0 THEN
                     RETURN 102555;
                  END IF;

                  num_err := pac_propio.f_reparto_shadow(psseguro, NULL, NULL, vrescibex,
                                                         vrescibex_pa, vrescibex_shw);
                  -- Ibex 35 ------------
                  num_err :=
                     pac_ctaseguro.f_insctaseguro
                                      (psseguro, f_sysdate, xnnumlin, fcuenta, fcuenta,
                                       xcmovimi,
                                       f_round(vrescibex_pa,
                                               pac_monedas.f_moneda_producto(reg_seg.sproduc)),
                                       0, NULL, seqgrupo, 0, pnsinies, NULL, NULL);
                  xnnumlin := xnnumlin + 1;

                  IF num_err <> 0 THEN
                     RETURN 102555;
                  END IF;

                  num_err := f_distribuye_ctaseguro(psseguro, xnnumlin, fcuenta, xcmovimi,
                                                    vrescibex_pa, seqgrupo, pnsinies);

                  IF num_err <> 0 THEN
                     RETURN 102555;
                  END IF;

                  IF pac_ctaseguro.f_tiene_ctashadow(psseguro, NULL) = 1 THEN
                     -- Europlazo ----------
                     num_err :=
                        pac_ctaseguro.f_insctaseguro_shw
                                     (psseguro, f_sysdate, xnnumlinshw, fcuenta, fcuenta,
                                      xcmovimi,
                                      f_round(vresceur_shw,
                                              pac_monedas.f_moneda_producto(reg_seg.sproduc)),
                                      0, NULL, seqgrupo, 0, pnsinies, NULL, NULL);
                     xnnumlinshw := xnnumlinshw + 1;

                     IF num_err <> 0 THEN
                        RETURN 102555;
                     END IF;

                     -- Ibex 35 ------------
                     num_err :=
                        pac_ctaseguro.f_insctaseguro_shw
                                      (psseguro, f_sysdate, xnnumlinshw, fcuenta, fcuenta,
                                       xcmovimi,
                                       f_round(vrescibex_shw,
                                               pac_monedas.f_moneda_producto(reg_seg.sproduc)),
                                       0, NULL, seqgrupo, 0, pnsinies, NULL, NULL);
                     xnnumlinshw := xnnumlinshw + 1;

                     IF num_err <> 0 THEN
                        RETURN 102555;
                     END IF;

                     num_err := f_distribuye_ctaseguro_shw(psseguro, xnnumlinshw, fcuenta,
                                                           xcmovimi, vrescibex_shw, seqgrupo,
                                                           pnsinies);

                     IF num_err <> 0 THEN
                        RETURN 102555;
                     END IF;
                  END IF;
               END IF;
            END IF;
         ELSE   -- Ahorro, etc
            --{insertamos el registro del importe pagado}
            -- En comptes de fer l'insert directament sobre CTASEGURO, utilitzem la funci?
            -- PAC_CTASEGURO.f_insctaseguro per qu? realitzi tant l'apunt al compte, com tamb? l'apunt del
            -- rescat a la llibreta.
            --Bug 20241 - RSC - 25/11/2011
            IF xivalora > 0 THEN
               -- Fin Bug 20241
               IF xcmovimi IS NOT NULL THEN
                  -- BUG 23116:ETM:20/09/2012   --INI
                  IF NVL(pac_parametros.f_parempresa_n(reg_seg.cempres, 'CTASEG_PAGO_PARCIAL'),
                         0) <> 1 THEN
                     num_err := pac_propio.f_reparto_shadow(psseguro, NULL, NULL, xivalora,
                                                            xivalora_pa, xivalora_shw);
                     num_err :=
                        pac_ctaseguro.f_insctaseguro
                                     (psseguro, f_sysdate, xnnumlin, fcuenta, fcuenta,
                                      xcmovimi,
                                      f_round(xivalora_pa,
                                              pac_monedas.f_moneda_producto(reg_seg.sproduc)),
                                      0, NULL, 0, 0, pnsinies, NULL, NULL);

                     IF num_err <> 0 THEN
                        RETURN 102555;
                     END IF;

                     IF pac_ctaseguro.f_tiene_ctashadow(psseguro, NULL) = 1 THEN
                        num_err :=
                           pac_ctaseguro.f_insctaseguro_shw
                                     (psseguro, f_sysdate, xnnumlinshw, fcuenta, fcuenta,
                                      xcmovimi,
                                      f_round(xivalora_shw,
                                              pac_monedas.f_moneda_producto(reg_seg.sproduc)),
                                      0, NULL, 0, 0, pnsinies, NULL, NULL);

                        IF num_err <> 0 THEN
                           RETURN 102555;
                        END IF;

                        xnnumlinshw := xnnumlinshw + 1;
                     END IF;

                     xnnumlin := xnnumlin + 1;

                     IF xcmovimi = 53
                        AND NVL(f_parproductos_v(reg_seg.sproduc, 'SALDO_AE'), 0) = 1 THEN
                        num_err := pac_ctaseguro.f_inscta_prov_cap(psseguro, TRUNC(fcuenta),
                                                                   'R', NULL);

                        IF num_err <> 0 THEN
                           RETURN 102555;
                        END IF;

                        IF pac_ctaseguro.f_tiene_ctashadow(psseguro, NULL) = 1 THEN
                           num_err := pac_ctaseguro.f_inscta_prov_cap_shw(psseguro,
                                                                          TRUNC(fcuenta), 'R',
                                                                          NULL);
                        END IF;

                        num_err := pac_ctaseguro.f_recalcular_lineas_saldo(psseguro,
                                                                           fcuenta + 1);

                        IF num_err <> 0 THEN
                           RETURN 102555;
                        END IF;

                        IF pac_ctaseguro.f_tiene_ctashadow(psseguro, NULL) = 1 THEN
                           num_err := pac_ctaseguro.f_recalcular_lineas_saldo_shw(psseguro,
                                                                                  fcuenta + 1);

                           IF num_err <> 0 THEN
                              RETURN 102555;
                           END IF;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;

         ntraza := 8;

         -- 7/03/2008: no se graba la l?nea de penalizaci?n
         -- Bug 9276 - 27/02/2009 - APD - Se descomenta el IF de Penalizaci?n, ya que ahora s? se quiere que se grabe la linea de penalizacion
         --{insertamos el registro del importe de penalizaci?n}
         -- Solo insertamos si ha habido penalizaci?n
         IF NVL(v_ipenali, 0) <> 0
-- BUG 22587 - 26/06/2012 - DCG - Inici
--            AND NVL(pac_parametros.f_parproducto_n(reg_seg.sproduc, 'GRABA_PENALIZACION'), 0) =
--                                                                                              1 THEN
         THEN
            IF NVL(pac_parametros.f_parproducto_n(reg_seg.sproduc, 'GRABA_PENALIZACION'), 0) =
                                                                                             1 THEN
               -- BUG 22587 - 26/06/2012 - DCG - Fi
               xcmovimi := 27;   --{penalizaci?n (Cvalor = 83)}

               -- BUG 23116:ETM:20/09/2012   --INI
               IF NVL(pac_parametros.f_parempresa_n(reg_seg.cempres, 'CTASEG_PAGO_PARCIAL'),
                      0) <> 1 THEN
                  ntraza := 9;
                  num_err :=
                     pac_ctaseguro.f_insctaseguro
                                     (psseguro, f_sysdate, xnnumlin, fcuenta, fcuenta,
                                      xcmovimi,

                                      -- BUG 22587 - 26/06/2012 - DCG - Inici
                                      f_round(NVL(v_ipenali, 0),

                                              -- f_round(NVL(xivalora, 0),
                                              -- BUG 22587 - 26/06/2012 - DCG - Fi
                                              pac_monedas.f_moneda_producto(reg_seg.sproduc)),
                                      0, NULL, seqgrupo, 0, pnsinies, NULL, NULL);

                  IF num_err <> 0 THEN
                     RETURN 102555;
                  END IF;

                  IF pac_ctaseguro.f_tiene_ctashadow(psseguro, NULL) = 1 THEN
                     ntraza := 10;
                     num_err :=
                        pac_ctaseguro.f_insctaseguro_shw
                                     (psseguro, f_sysdate, xnnumlinshw, fcuenta, fcuenta,
                                      xcmovimi,

                                      -- BUG 22587 - 26/06/2012 - DCG - Inici
                                      f_round(NVL(v_ipenali, 0),
                                              pac_monedas.f_moneda_producto(reg_seg.sproduc)),
                                      0, NULL, seqgrupo, 0, pnsinies, NULL, NULL);

                     IF num_err <> 0 THEN
                        RETURN 102555;
                     END IF;

                     xnnumlinshw := xnnumlinshw + 1;
                  END IF;

                  xnnumlin := xnnumlin + 1;

                  -- Generamos los movimientos de detalle en caso de producto Unit Linked
                  IF NVL(f_parproductos_v(reg_seg.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
                     ntraza := 11;
                     num_err := pac_sin_rescates.f_distribuye_ctaseguro(psseguro, xnnumlin,
                                                                        fcuenta, xcmovimi,
                                                                        NVL(v_ipenali, 0),
                                                                        seqgrupo, pnsinies);

                     IF num_err <> 0 THEN
                        RETURN 102555;
                     END IF;

                     IF pac_ctaseguro.f_tiene_ctashadow(psseguro, NULL) = 1 THEN
                        num_err :=
                           pac_sin_rescates.f_distribuye_ctaseguro_shw(psseguro, xnnumlinshw,
                                                                       fcuenta, xcmovimi,
                                                                       NVL(v_ipenali, 0),
                                                                       seqgrupo, pnsinies);

                        IF num_err <> 0 THEN
                           RETURN 102555;
                        END IF;
                     END IF;
                  END IF;
               END IF;
-- BUG 22587 - 26/06/2012 - DCG - Inici
            ELSE
--               xcmovimi := 27;   --{penalizaci?n (Cvalor = 83)}
--               num_err :=
--                  pac_ctaseguro.f_insctaseguro
--                                     (psseguro, f_sysdate, xnnumlin, fcuenta, fcuenta,
--                                      xcmovimi,
--                                      f_round(NVL(v_ipenali, 0),
--                                              pac_monedas.f_moneda_producto(reg_seg.sproduc)),
--                                      0, NULL, 0, 0, pnsinies, NULL, NULL);
               NULL;
            END IF;
-- BUG 22587 - 26/06/2012 - DCG - Fi
         END IF;
      END IF;

      --{Faltar?a enviar mail a la oficina}
      IF NVL(f_parproductos_v(reg_seg.sproduc, 'PROY_AHO_RESC'), 0) = 1 THEN
         ntraza := 15;

         -- Recalculamos la simulacion de rescate con el importe del rescate parcial
         SELECT MAX(nmovimi)
           INTO v_nmovimi
           FROM movseguro
          WHERE sseguro = psseguro;

         num_err := pac_propio.f_proy_aho_resc(psseguro, NVL(pnriesgo, 1), v_nmovimi,
                                               TO_CHAR(fcuenta, 'YYYYMMDD'), 0, v_icapesp);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         INSERT INTO evoluprovmatseg
                     (sseguro, nmovimi, nanyo, nscenario, fprovmat, iprovmat, icapfall,
                      prescate, pinttec, iprovest, crevisio, ivalres, iprima, iprima2, iprima3)
            SELECT psseguro, v_nmovimi, nanyo, nscenario, fprovmat, iprovmat, icapfall,
                   prescate, pinttec, iprovest, crevisio, ivalres, iprima, iprima2, iprima3
              FROM solevoluprovmatseg
             WHERE ssolicit = psseguro;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sin_rescates.f_finaliza_rescate', ntraza,
                     'Error no controlado', SQLERRM);
         RETURN 140999;
   END f_finaliza_rescate;

   /*
     RSC 13/12/2007. Funci?n ?nicamente necesaria para los productos Unit Linked. (Parproducto ES_PRODUCTO_INDEXADO)
   */
   FUNCTION f_distribuye_ctaseguro(
      psseguro IN seguros.sseguro%TYPE,
      xnnumlin IN OUT NUMBER,
      fcuenta IN DATE,
      pxcmovimi IN NUMBER,
      pivalora IN sin_tramita_reserva.ireserva%TYPE,
      seqgrupo IN NUMBER,
      pnsinies IN sin_siniestro.nsinies%TYPE)
      RETURN NUMBER IS
      CURSOR cur_distribucion IS
         SELECT ccesta, pdistrec
           FROM segdisin2
          WHERE sseguro = psseguro
            AND ffin IS NULL
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = psseguro
                              AND ffin IS NULL);

      xcdetmovimi    NUMBER;
      xidistrib      NUMBER;
      -- Bug 12199 - RSC - 25/11/2009 - CRE201 - Incidencia suplemento de anulaci?n de garant?a por siniestro
      viuniact       NUMBER;
      -- Fin Bug 12199
      -- BUG 18423 - 27/12/2011 - JMP - Multimoneda
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      v_f_sysdate    DATE;
      num_err        axis_literales.slitera%TYPE;
      -- FIN BUG 18423 - 27/12/2011 - JMP - Multimoneda
      v_valor_multiplica NUMBER;   ------BFP
      -- Bug 20665 - RSC - 28/02/2012 - LCOL_T001-LCOL - UAT - TEC - Rescates
      v_sproduc      NUMBER;
      -- Fin Bug 20665

      -- Bug 20665 - RSC - 08/03/2012
      v_unidades     NUMBER;
      -- Fin bug 20665
      vireserva      NUMBER;
      bnoprereserva  BOOLEAN := TRUE;
      v_ccausin      sin_siniestro.ccausin%TYPE;
      v_cmotsin      sin_siniestro.cmotsin%TYPE;
   BEGIN
      -- BUG 18423 - 27/12/2011 - JMP - Multimoneda
      BEGIN
         SELECT cempres, sproduc
           INTO v_cempres, v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101903;   -- Seguro no encontrado en la tabla SEGUROS
      END;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);

      -- FIN BUG 18423 - 27/12/2011 - JMP - Multimoneda

      -- Obtenemos el c?digo de detalle de movimiento en CTASEGURO
      IF pxcmovimi = 34 THEN
         xcdetmovimi := 94;   -- Detalle de Rescate Total
      ELSIF pxcmovimi = 33 THEN
         xcdetmovimi := 93;   -- Detalle de Rescate Parcial

         BEGIN
            SELECT ccausin, cmotsin
              INTO v_ccausin, v_cmotsin
              FROM sin_siniestro
             WHERE nsinies = pnsinies;

            IF v_ccausin = 5
               AND v_cmotsin = 5 THEN
               xcdetmovimi := 37;   -- Detalle de Rescate Parcial de Part. Beneficios
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_sin_rescates.f_distribuye_ctaseguro', 1,
                           psseguro || '-' || xnnumlin || '-' || fcuenta || '-' || pxcmovimi
                           || '-' || pivalora || '-' || seqgrupo || '-' || pnsinies,
                           SQLERRM);
         END;
      ELSIF pxcmovimi = 31 THEN
         xcdetmovimi := 91;   -- Detalle de Siniestro
      ELSIF pxcmovimi = 27 THEN
         xcdetmovimi := 87;   -- Detalle de Penal. rescate
      --BUG20419--09/12/2011--JTS
      ELSIF pxcmovimi = 10 THEN
         xcdetmovimi := 90;   -- Detalle de Penal. rescate
      --FiBUG20419
      ELSE
         xcdetmovimi := 97;   -- Detalle de Traspaso de Salida
      END IF;

      IF xnnumlin IS NULL THEN
         xnnumlin := pac_ctaseguro.f_numlin_next(psseguro);
      END IF;

      FOR prereserva IN (SELECT ireserva, ccesta, iunidad
                           FROM sin_tramita_prereserva_fnd
                          WHERE nsinies = pnsinies) LOOP
         bnoprereserva := FALSE;
         xidistrib := prereserva.ireserva;
         viuniact := prereserva.iunidad;

         --Inserta registres a cuenta seguro.
         BEGIN
            v_f_sysdate := f_sysdate;   -- BUG 18423 - 27/12/2011 - JMP - Multimoneda

---------------------Ini BFP 16/01/2012 bug: 20419
            IF pxcmovimi = 10 THEN
               v_valor_multiplica := 1;
            ELSE
               v_valor_multiplica := -1;
            END IF;

-----------------------Fi BFP 16/01/2012 bug: 20419

            -- Bug 20665 - RSC - 08/03/2012
            v_unidades := f_ajustar_unidades(psseguro, xcdetmovimi, xnnumlin,
                                             prereserva.ccesta, xidistrib, viuniact,
                                             v_valor_multiplica);

            -- Fin Bug 20665
            INSERT INTO ctaseguro
                        (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                         cmovimi,
                         imovimi, imovim2,
                         nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta, cestado,
                         nunidad, fasign)
                 VALUES (psseguro, v_f_sysdate, NVL(xnnumlin, 1), fcuenta, fcuenta,
                         xcdetmovimi,
                         f_round(xidistrib, pac_monedas.f_moneda_producto(v_sproduc)), NULL,
                         NULL, seqgrupo, 0, pnsinies, NULL, prereserva.ccesta, '2',
                         v_unidades,   -- Bug 20665 - RSC - 08/03/2012
                                    TRUNC(f_sysdate));

            ---BFP hem canviat el -1 per la variable (v_valor_multiplica) BUG:20419 16/01/2012

            -- BUG 18423 - 27/12/2011 - JMP - Multimoneda
            IF v_cmultimon = 1 THEN
               num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro, v_f_sysdate,
                                                                     NVL(xnnumlin, 1),
                                                                     fcuenta);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;

            -- FIN BUG 18423 - 27/12/2011 - JMP - Multimoneda
            xnnumlin := xnnumlin + 1;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               RETURN 104879;   -- Registre duplicat a CTASEGURO
            WHEN OTHERS THEN
               RETURN 102555;   -- Error al insertar a la taula CTASEGURO
         END;
      END LOOP;

      IF bnoprereserva THEN
         FOR regs IN cur_distribucion LOOP
            --Calcula les distribucions
            xidistrib := (pivalora * regs.pdistrec) / 100;

            -- Bug 12199 - RSC - 25/11/2009 - CRE201 - Incidencia suplemento de anulaci?n de garant?a por siniestro
            BEGIN
               SELECT iuniact
                 INTO viuniact
                 FROM tabvalces
                WHERE ccesta = regs.ccesta
                  AND TRUNC(fvalor) + pac_iax_fondos.f_get_diasdep(regs.ccesta) =
                                                                                 TRUNC(fcuenta);

               --Inserta registres a cuenta seguro.
               BEGIN
                  v_f_sysdate := f_sysdate;   -- BUG 18423 - 27/12/2011 - JMP - Multimoneda

---------------------Ini BFP 16/01/2012 bug: 20419
                  IF pxcmovimi = 10 THEN
                     v_valor_multiplica := 1;
                  ELSE
                     v_valor_multiplica := -1;
                  END IF;

-----------------------Fi BFP 16/01/2012 bug: 20419

                  -- Bug 20665 - RSC - 08/03/2012
                  v_unidades := f_ajustar_unidades(psseguro, xcdetmovimi, xnnumlin,
                                                   regs.ccesta, xidistrib, viuniact,
                                                   v_valor_multiplica);

                  -- Fin Bug 20665
                  INSERT INTO ctaseguro
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                               cmovimi,
                               imovimi,
                               imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta,
                               cestado, nunidad, fasign)
                       VALUES (psseguro, v_f_sysdate, NVL(xnnumlin, 1), fcuenta, fcuenta,
                               xcdetmovimi,
                               f_round(xidistrib, pac_monedas.f_moneda_producto(v_sproduc)),
                               NULL, NULL, seqgrupo, 0, pnsinies, NULL, regs.ccesta,
                               '2', v_unidades,   -- Bug 20665 - RSC - 08/03/2012
                                               TRUNC(f_sysdate));

                  ---BFP hem canviat el -1 per la variable (v_valor_multiplica) BUG:20419 16/01/2012

                  -- BUG 18423 - 27/12/2011 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro,
                                                                           v_f_sysdate,
                                                                           NVL(xnnumlin, 1),
                                                                           fcuenta);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 27/12/2011 - JMP - Multimoneda
                  xnnumlin := xnnumlin + 1;
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     RETURN 104879;   -- Registre duplicat a CTASEGURO
                  WHEN OTHERS THEN
                     RETURN 102555;   -- Error al insertar a la taula CTASEGURO
               END;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- Fin 12199
                  --Inserta registres a cuenta seguro.
                  BEGIN
                     v_f_sysdate := f_sysdate;   -- BUG 18423 - 27/12/2011 - JMP - Multimoneda

                     INSERT INTO ctaseguro
                                 (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                                  cmovimi, imovimi, imovim2, nrecibo, ccalint, cmovanu,
                                  nsinies, smovrec, cesta, cestado)
                          VALUES (psseguro, v_f_sysdate, NVL(xnnumlin, 1), fcuenta, fcuenta,
                                  xcdetmovimi, xidistrib, NULL, NULL, seqgrupo, 0,
                                  pnsinies, NULL, regs.ccesta, '1');

                     -- BUG 18423 - 27/12/2011 - JMP - Multimoneda
                     IF v_cmultimon = 1 THEN
                        num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro,
                                                                              v_f_sysdate,
                                                                              NVL(xnnumlin, 1),
                                                                              fcuenta);

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;

                     -- FIN BUG 18423 - 27/12/2011 - JMP - Multimoneda
                     xnnumlin := xnnumlin + 1;
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        RETURN 104879;   -- Registre duplicat a CTASEGURO
                     WHEN OTHERS THEN
                        RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                  END;
            -- Bug 12199 - RSC - 25/11/2009 - CRE201 - Incidencia suplemento de anulaci?n de garant?a por siniestro
            END;
         -- Fin 12199
         -- Fin Bug
         END LOOP;
      END IF;

      RETURN 0;
   END f_distribuye_ctaseguro;

   FUNCTION f_distribuye_ctaseguro_shw(
      psseguro IN seguros.sseguro%TYPE,
      xnnumlin IN OUT NUMBER,
      fcuenta IN DATE,
      pxcmovimi IN NUMBER,
      pivalora IN sin_tramita_reserva.ireserva%TYPE,
      seqgrupo IN NUMBER,
      pnsinies IN sin_siniestro.nsinies%TYPE)
      RETURN NUMBER IS
      CURSOR cur_distribucion IS
         SELECT ccesta, pdistrec
           FROM segdisin2
          WHERE sseguro = psseguro
            AND ffin IS NULL
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = psseguro
                              AND ffin IS NULL);

      xcdetmovimi    NUMBER;
      xidistrib      NUMBER;
      -- Bug 12199 - RSC - 25/11/2009 - CRE201 - Incidencia suplemento de anulaci?n de garant?a por siniestro
      viuniact       NUMBER;
      -- Fin Bug 12199
      -- BUG 18423 - 27/12/2011 - JMP - Multimoneda
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      v_f_sysdate    DATE;
      num_err        axis_literales.slitera%TYPE;
      -- FIN BUG 18423 - 27/12/2011 - JMP - Multimoneda
      v_valor_multiplica NUMBER;   ------BFP
      -- Bug 20665 - RSC - 28/02/2012 - LCOL_T001-LCOL - UAT - TEC - Rescates
      v_sproduc      NUMBER;
      -- Fin Bug 20665

      -- Bug 20665 - RSC - 08/03/2012
      v_unidades     NUMBER;
      vireservashw   NUMBER;
      bnoprereserva  BOOLEAN := TRUE;
      -- Fin bug 20665
      v_ccausin      sin_siniestro.ccausin%TYPE;
      v_cmotsin      sin_siniestro.cmotsin%TYPE;
   BEGIN
      -- BUG 18423 - 27/12/2011 - JMP - Multimoneda
      BEGIN
         SELECT cempres, sproduc
           INTO v_cempres, v_sproduc
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101903;   -- Seguro no encontrado en la tabla SEGUROS
      END;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);

      -- FIN BUG 18423 - 27/12/2011 - JMP - Multimoneda

      -- Obtenemos el c?digo de detalle de movimiento en CTASEGURO
      IF pxcmovimi = 34 THEN
         xcdetmovimi := 94;   -- Detalle de Rescate Total
      ELSIF pxcmovimi = 33 THEN
         xcdetmovimi := 93;   -- Detalle de Rescate Parcial

         BEGIN
            SELECT ccausin, cmotsin
              INTO v_ccausin, v_cmotsin
              FROM sin_siniestro
             WHERE nsinies = pnsinies;

            IF v_ccausin = 5
               AND v_cmotsin = 5 THEN
               xcdetmovimi := 37;   -- Detalle de Rescate Parcial de Part. Beneficios
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_sin_rescates.f_distribuye_ctaseguro_shw',
                           1,
                           psseguro || '-' || xnnumlin || '-' || fcuenta || '-' || pxcmovimi
                           || '-' || pivalora || '-' || seqgrupo || '-' || pnsinies,
                           SQLERRM);
         END;
      ELSIF pxcmovimi = 31 THEN
         xcdetmovimi := 91;   -- Detalle de Siniestro
      ELSIF pxcmovimi = 27 THEN
         xcdetmovimi := 87;   -- Detalle de Penal. rescate
      --BUG20419--09/12/2011--JTS
      ELSIF pxcmovimi = 10 THEN
         xcdetmovimi := 90;   -- Detalle de Penal. rescate
      --FiBUG20419
      ELSE
         xcdetmovimi := 97;   -- Detalle de Traspaso de Salida
      END IF;

      IF xnnumlin IS NULL THEN
         xnnumlin := pac_ctaseguro.f_numlin_next_shw(psseguro);
      END IF;

      FOR prereserva IN (SELECT ireservashw, ccesta, iunidadshw
                           FROM sin_tramita_prereserva_fnd
                          WHERE nsinies = pnsinies) LOOP
         bnoprereserva := FALSE;
         xidistrib := prereserva.ireservashw;
         viuniact := prereserva.iunidadshw;

         --Inserta registres a cuenta seguro.
         BEGIN
            v_f_sysdate := f_sysdate;   -- BUG 18423 - 27/12/2011 - JMP - Multimoneda

            ---------------------Ini BFP 16/01/2012 bug: 20419
            IF pxcmovimi = 10 THEN
               v_valor_multiplica := 1;
            ELSE
               v_valor_multiplica := -1;
            END IF;

            -----------------------Fi BFP 16/01/2012 bug: 20419

            -- Bug 20665 - RSC - 08/03/2012
            v_unidades := f_ajustar_unidades_shw(psseguro, xcdetmovimi, xnnumlin,
                                                 prereserva.ccesta, xidistrib, viuniact,
                                                 v_valor_multiplica);

            -- Fin Bug 20665
            INSERT INTO ctaseguro_shadow
                        (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                         cmovimi,
                         imovimi, imovim2,
                         nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta, cestado,
                         nunidad, fasign)
                 VALUES (psseguro, v_f_sysdate, NVL(xnnumlin, 1), fcuenta, fcuenta,
                         xcdetmovimi,
                         f_round(xidistrib, pac_monedas.f_moneda_producto(v_sproduc)), NULL,
                         NULL, seqgrupo, 0, pnsinies, NULL, prereserva.ccesta, '2',
                         v_unidades,   -- Bug 20665 - RSC - 08/03/2012
                                    TRUNC(f_sysdate));

            ---BFP hem canviat el -1 per la variable (v_valor_multiplica) BUG:20419 16/01/2012

            -- BUG 18423 - 27/12/2011 - JMP - Multimoneda
            IF v_cmultimon = 1 THEN
               num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro,
                                                                         v_f_sysdate,
                                                                         NVL(xnnumlin, 1),
                                                                         fcuenta);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;

            -- FIN BUG 18423 - 27/12/2011 - JMP - Multimoneda
            xnnumlin := xnnumlin + 1;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               RETURN 104879;   -- Registre duplicat a CTASEGURO
            WHEN OTHERS THEN
               RETURN 102555;   -- Error al insertar a la taula CTASEGURO
         END;
      END LOOP;

      IF bnoprereserva THEN
         FOR regs IN cur_distribucion LOOP
            --Calcula les distribucions
            xidistrib := (pivalora * regs.pdistrec) / 100;

            -- Bug 12199 - RSC - 25/11/2009 - CRE201 - Incidencia suplemento de anulaci?n de garant?a por siniestro
            BEGIN
               SELECT iuniactvtashw
                 INTO viuniact
                 FROM tabvalces
                WHERE ccesta = regs.ccesta
                  AND TRUNC(fvalor) + pac_iax_fondos.f_get_diasdep(regs.ccesta) =
                                                                                 TRUNC(fcuenta);

               --Inserta registres a cuenta seguro.
               BEGIN
                  v_f_sysdate := f_sysdate;   -- BUG 18423 - 27/12/2011 - JMP - Multimoneda

                  ---------------------Ini BFP 16/01/2012 bug: 20419
                  IF pxcmovimi = 10 THEN
                     v_valor_multiplica := 1;
                  ELSE
                     v_valor_multiplica := -1;
                  END IF;

                  -----------------------Fi BFP 16/01/2012 bug: 20419

                  -- Bug 20665 - RSC - 08/03/2012
                  v_unidades := f_ajustar_unidades_shw(psseguro, xcdetmovimi, xnnumlin,
                                                       regs.ccesta, xidistrib, viuniact,
                                                       v_valor_multiplica);

                  -- Fin Bug 20665
                  INSERT INTO ctaseguro_shadow
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                               cmovimi,
                               imovimi,
                               imovim2, nrecibo, ccalint, cmovanu, nsinies, smovrec, cesta,
                               cestado, nunidad, fasign)
                       VALUES (psseguro, v_f_sysdate, NVL(xnnumlin, 1), fcuenta, fcuenta,
                               xcdetmovimi,
                               f_round(xidistrib, pac_monedas.f_moneda_producto(v_sproduc)),
                               NULL, NULL, seqgrupo, 0, pnsinies, NULL, regs.ccesta,
                               '2', v_unidades,   -- Bug 20665 - RSC - 08/03/2012
                                               TRUNC(f_sysdate));

                  ---BFP hem canviat el -1 per la variable (v_valor_multiplica) BUG:20419 16/01/2012

                  -- BUG 18423 - 27/12/2011 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     num_err :=
                        pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro, v_f_sysdate,
                                                                       NVL(xnnumlin, 1),
                                                                       fcuenta);

                     IF num_err <> 0 THEN
                        RETURN num_err;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 27/12/2011 - JMP - Multimoneda
                  xnnumlin := xnnumlin + 1;
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     RETURN 104879;   -- Registre duplicat a CTASEGURO
                  WHEN OTHERS THEN
                     RETURN 102555;   -- Error al insertar a la taula CTASEGURO
               END;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- Fin 12199
                  --Inserta registres a cuenta seguro.
                  BEGIN
                     v_f_sysdate := f_sysdate;   -- BUG 18423 - 27/12/2011 - JMP - Multimoneda

                     INSERT INTO ctaseguro_shadow
                                 (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                                  cmovimi, imovimi, imovim2, nrecibo, ccalint, cmovanu,
                                  nsinies, smovrec, cesta, cestado)
                          VALUES (psseguro, v_f_sysdate, NVL(xnnumlin, 1), fcuenta, fcuenta,
                                  xcdetmovimi, xidistrib, NULL, NULL, seqgrupo, 0,
                                  pnsinies, NULL, regs.ccesta, '1');

                     -- BUG 18423 - 27/12/2011 - JMP - Multimoneda
                     IF v_cmultimon = 1 THEN
                        num_err :=
                           pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro,
                                                                          v_f_sysdate,
                                                                          NVL(xnnumlin, 1),
                                                                          fcuenta);

                        IF num_err <> 0 THEN
                           RETURN num_err;
                        END IF;
                     END IF;

                     -- FIN BUG 18423 - 27/12/2011 - JMP - Multimoneda
                     xnnumlin := xnnumlin + 1;
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        RETURN 104879;   -- Registre duplicat a CTASEGURO
                     WHEN OTHERS THEN
                        RETURN 102555;   -- Error al insertar a la taula CTASEGURO
                  END;
            -- Bug 12199 - RSC - 25/11/2009 - CRE201 - Incidencia suplemento de anulaci?n de garant?a por siniestro
            END;
         -- Fin 12199
         -- Fin Bug
         END LOOP;
      END IF;

      RETURN 0;
   END f_distribuye_ctaseguro_shw;

   FUNCTION f_valida_permite_rescate(
      psseguro IN seguros.sseguro%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pfrescate IN DATE,
      pccausin IN sin_codcausa.ccausin%TYPE)
      RETURN NUMBER IS
      num_err        NUMBER;
      v_sproduc      NUMBER;
      v_norden       NUMBER;
      v_cempres      NUMBER;
      vcrealiza      cfg_accion.crealiza%TYPE;
   BEGIN
      SELECT sproduc, cempres
        INTO v_sproduc, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      -- Primero mira si el producto y el usuario permite rescates
      /*IF pac_wizard.f_get_accion(f_user, 'RESCATES', v_sproduc) = 0 THEN
                                                                           RETURN 180676;   -- el producto no permite rescates
      END IF;*/
      num_err := pac_cfg.f_get_user_accion_permitida(f_user, 'RESCATES', v_sproduc, v_cempres,
                                                     vcrealiza);

      IF num_err = 0 THEN
         RETURN 180676;   -- el producto no permite rescates
      ELSIF num_err <> 1 THEN
         RETURN num_err;
      END IF;

      -- Miramos las validaciones generales de siniestros
      --buscamos el asegurado vigente
      BEGIN
         SELECT norden
           INTO v_norden
           FROM asegurados
          WHERE sseguro = psseguro
            AND ffecfin IS NULL;
      EXCEPTION
         WHEN TOO_MANY_ROWS THEN
            v_norden := 1;
         WHEN NO_DATA_FOUND THEN
            v_norden := 1;
      END;

      num_err := pac_siniestros.f_permite_alta_siniestro(psseguro, v_norden, pfrescate,
                                                         TRUNC(f_sysdate), pccausin, 0);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Mirar que la p?liza es de la misma oficina

      -- Mirar si est? permitido el rescate seg?n la parametrizaci?n del producto
      num_err := pac_sin_rescates.f_es_rescatable(psseguro, pfrescate, pccausin, NULL);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Mirar si tiene descuadres
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         num_err := 108190;   -- Error General
         p_tab_error(f_sysdate, f_user, 'pac_sin_rescates.f_valida_permite_rescate', NULL,
                     'parametros: psseguro=' || psseguro || ' pcagente=' || pcagente
                     || ' pfrescate =' || pfrescate,
                     SQLERRM);
         RETURN num_err;
   END f_valida_permite_rescate;

   FUNCTION f_avisos_rescates(
      psseguro IN seguros.sseguro%TYPE,
      pfrescate IN DATE,
      pirescate IN NUMBER,
      cavis OUT NUMBER,
      pdatos OUT NUMBER)
      RETURN NUMBER IS
   /*************************************************************************************
                                                                                                                                                                                                                                                                                                              Esta funci?n mira si se deben mostrar mensajes de aviso en un rescate (cavis) y si se deben
     mostrar los datos en la simulaci?n.
        cavis: null.- no hay aviso
               literal .- si hay aviso
        pdatos: 0.- no mostrar datos de simulaci?n
                1.- mostrar datos de simulaci?n
   ****************************************************************************************/
   BEGIN
      pdatos := 1;

      -- Mirar si hay descuadre de primas. En ese caso se dar? un mensaje de aviso y no se mostrar?n
      -- los datos
      IF pac_calc_comu.ff_desquadrament(psseguro, NULL) = 1 THEN
         cavis := 180665;   -- No se puede realizar simulaci?n sobre esta p?liza. ?Proceder al rescate?
         pdatos := 0;
      END IF;

      -- Mirar si el importe de rescate = 0. En ese caso se dar? un mensaje de aviso pero s?
      -- se mostrar?n los datos
      IF pirescate = 0 THEN
         cavis := 180666;   -- Penalizaci?n 100%. Importe 0?. ?Proceder al rescate?
         pdatos := 1;
      END IF;

      IF pac_sin_rescates.f_vivo_o_muerto(psseguro, 2, pfrescate) > 0 THEN
         cavis := 180797;
         pdatos := 0;
      END IF;

      RETURN 0;
   END f_avisos_rescates;

   /******************************************************************************
                                                                                                                                                                                                                                                                                         NOMBRE:       F_BUSCA_PRETEN
      DESCRIPCION:  Retorna un % de I.R.P.F.
      PARAMETROS:
      INPUT: PSESION(number) --> Nro. de sesi?n del evaluador de f?rmulas
             PPERSON(number) --> Clave del asegurado
           PCACTPRO(number) --> Actividad Profesional. 4 = Cliente
           PFECHA(number)  --> Fecha a aplicar la retenci?n
      RETORNA VALUE:
             VALOR(NUMBER)-----> % DE RETENCI?N
                               NULL --> No existe en la tabla PROFESIONALES
   ******************************************************************************/
   FUNCTION f_busca_preten(
      psesion IN NUMBER,
      pperson IN per_personas.sperson%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pfecha IN NUMBER,
      pnsinies IN sin_siniestro.nsinies%TYPE DEFAULT NULL,
      pntramit IN sin_tramitacion.ntramit%TYPE DEFAULT NULL)
      RETURN NUMBER IS
      valor          NUMBER;
      xcpais         NUMBER;
      xcprovin       NUMBER := 0;   -- SHA -- Bug 38224/216445 --11/11/2015
      xfecha         DATE;
   BEGIN
      valor := NULL;
      xfecha := TO_DATE(pfecha, 'YYYYMMDD');

      --
      IF pnsinies IS NOT NULL THEN
         --MCA se incluye la b?squeda en destinatarios seg?n pa?s de residencia
         BEGIN
            SELECT DISTINCT cpaisre, NVL(cprovin, 0)   -- SHA -- Bug 38224/216445 --11/11/2015
                       INTO xcpais, xcprovin
                       FROM sin_tramita_destinatario
                      WHERE nsinies = pnsinies
                        AND ntramit = pntramit
                        AND sperson = pperson;
         EXCEPTION
            WHEN OTHERS THEN
               BEGIN
                  SELECT DISTINCT cpais
                             INTO xcpais
                             FROM per_detper
                            WHERE sperson = pperson;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN NULL;
               END;
         END;
      ELSE
         BEGIN
            SELECT DISTINCT cpais
                       INTO xcpais
                       FROM per_detper
                      WHERE sperson = pperson;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;
      END IF;

      --
      IF xcpais IS NULL THEN
         BEGIN
            SELECT cpais
              INTO xcpais
              FROM per_direcciones d, provincias p
             WHERE p.cprovin = d.cprovin
               AND d.sperson = pperson
               AND d.cdomici = (SELECT MIN(cdomici)
                                  FROM per_direcciones
                                 WHERE sperson = pperson);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;
      END IF;

      -- SHA -- Inici Bug 38224/216445 --11/11/2015
      IF xcprovin IS NULL THEN
         BEGIN
            SELECT NVL(d.cprovin, 0)
              INTO xcprovin
              FROM per_direcciones d, provincias p
             WHERE p.cprovin = d.cprovin
               AND d.sperson = pperson
               AND d.cdomici = (SELECT MIN(cdomici)
                                  FROM per_direcciones
                                 WHERE sperson = pperson);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN NULL;
         END;
      END IF;

      -- SHA -- Fin Bug 38224/216445 --11/11/2015
      BEGIN
         SELECT pretenc
           INTO valor
           FROM paisprete
          WHERE cpais = xcpais
            AND cprovin = xcprovin   -- SHA -- Bug 38224/216445 --11/11/2015
            AND sproduc = psproduc
            AND finicio = (SELECT MAX(finicio)
                             FROM paisprete
                            WHERE cpais = xcpais
                              AND cprovin = xcprovin   -- SHA -- Bug 38224/216445 --11/11/2015
                              AND sproduc = psproduc
                              AND finicio <= xfecha);

         RETURN valor;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT pretenc
                 INTO valor
                 FROM paisprete
                WHERE cpais = xcpais
                  AND cprovin = 0   -- SHA -- Bug 38224/216445 --11/11/2015
                  AND sproduc = psproduc
                  AND finicio = (SELECT MAX(finicio)
                                   FROM paisprete
                                  WHERE cpais = xcpais
                                    AND cprovin = 0   -- SHA -- Bug 38224/216445 --11/11/2015
                                    AND sproduc = psproduc
                                    AND finicio <= xfecha);

               RETURN valor;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT pretenc
                       INTO valor
                       FROM retenciones
                      WHERE cretenc = 3   -- Pers.Fis.No Residentes
                        AND finivig = (SELECT MAX(finivig)
                                         FROM retenciones
                                        WHERE cretenc = 3   -- Pers.Fis.No Residentes
                                          AND finivig <= xfecha);

                     RETURN valor;
                  EXCEPTION
                     WHEN OTHERS THEN
                        RETURN NULL;
                  END;
               WHEN OTHERS THEN
                  RETURN NULL;
            END;
         WHEN OTHERS THEN
            RETURN NULL;
      END;
   END f_busca_preten;

   FUNCTION f_ins_destinatario(
      pnsinies IN sin_tramita_destinatario.nsinies%TYPE,
      pntramit IN sin_tramita_destinatario.ntramit%TYPE,
      psseguro IN sin_siniestro.sseguro%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      ppagdes IN NUMBER,
      pctipdes IN sin_tramita_destinatario.ctipdes%TYPE,
      pcpagdes IN sin_tramita_destinatario.cpagdes%TYPE,
      ppasigna IN sin_tramita_destinatario.pasigna%TYPE,
      pcactpro IN sin_tramita_destinatario.cactpro%TYPE,
      pcbancar IN sin_tramita_destinatario.cbancar%TYPE,
      pcbancar2 IN sin_tramita_destinatario.cbancar%TYPE,
      pctipban IN sin_tramita_destinatario.ctipban%TYPE DEFAULT NULL,
      pctipban2 IN sin_tramita_destinatario.ctipban%TYPE DEFAULT NULL)
      RETURN NUMBER IS
      num_err        NUMBER;

      CURSOR c_asegurados IS
         SELECT   sperson, norden
             FROM asegurados
            WHERE asegurados.sseguro = psseguro
              AND ffecmue IS NULL
              AND ffecfin IS NULL   -- BUG11183:DRA:30/09/2009
         ORDER BY norden;

      xcuenta        seguros.cbancar%TYPE;
      xcuenta1       seguros.cbancar%TYPE;
      xcuenta2       seguros.cbancar%TYPE;
      xctipban       seguros.ctipban%TYPE;
      xctipban1      seguros.ctipban%TYPE;
      xctipban2      seguros.ctipban%TYPE;
      xriesgo        NUMBER;
      ndestina       NUMBER;
      ntotal         NUMBER;
      vsproduc       productos.sproduc%TYPE;
      v_cpais        sin_tramita_destinatario.cpaisre%TYPE;
      vcagente       NUMBER;

      CURSOR c_tomadores IS
         SELECT   sperson
             FROM tomadores
            WHERE sseguro = psseguro
         ORDER BY nordtom;

      CURSOR c_gescobro IS
         SELECT sperson
           FROM gescobros
          WHERE sseguro = psseguro;
   BEGIN
      -- Si es producto es a '2_CABEZAS', el valor del par?metro pnriesgo ser? el norden del Asegurado
      -- Si el proudcto NO es a '2_CABEZAS', el valor del par?metro pnriesgo ser? el nriesgo del Riesgo

      --{Selecionamos la cuenta del seguro, si no nos informan ninguna cuenta por defecto}
      IF pcbancar IS NULL THEN
         BEGIN
            SELECT cbancar, ctipban
              INTO xcuenta1, xctipban1
              FROM seguros s
             WHERE s.sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               xcuenta1 := NULL;
               xctipban1 := NULL;
         END;
      ELSE
         xcuenta1 := pcbancar;
         xctipban1 := pctipban;   -- BUG10581:DRA:30/06/2009
      END IF;

      IF pcbancar2 IS NULL THEN
         xcuenta2 := xcuenta1;
         xctipban2 := xctipban1;
      ELSE
         xcuenta2 := pcbancar2;
         xctipban2 := pctipban2;
      END IF;

      -- Si el producto es a '2_CABEZAS', el sperson se busca de la tabla Asegurados
      -- Sino de la tabla Riesgos
      BEGIN
         SELECT sproduc, cagente
           INTO vsproduc, vcagente
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101919;   -- Error al leer datos de la tabla SEGUROS
      END;

      IF pctipdes = 7 THEN   -- Valor fijo 10: Tomador
         FOR tom IN c_tomadores LOOP
            xcuenta := xcuenta1;
            xctipban := xctipban1;

            BEGIN
               SELECT DISTINCT cpais
                          INTO v_cpais
                          FROM per_detper
                         WHERE sperson = tom.sperson
                           AND cagente = ff_agente_cpervisio(vcagente);
            EXCEPTION
               WHEN OTHERS THEN
                  IF v_cpais IS NULL THEN
                     BEGIN
                        SELECT cpais
                          INTO v_cpais
                          FROM per_direcciones d, provincias p
                         WHERE p.cprovin = d.cprovin
                           AND d.sperson = tom.sperson
                           AND d.cdomici = (SELECT MIN(cdomici)
                                              FROM per_direcciones
                                             WHERE sperson = tom.sperson
                                               AND cagente = ff_agente_cpervisio(vcagente));
                     EXCEPTION
                        WHEN OTHERS THEN
                           RETURN NULL;
                     END;
                  END IF;
            END;

            num_err := pac_siniestros.f_ins_destinatario(pnsinies, pntramit, tom.sperson,
                                                         xcuenta, xctipban, ppasigna, v_cpais,
                                                         pctipdes, pcpagdes, pcactpro);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END LOOP;
      ---etm ini
      ELSIF pctipdes = 43 THEN   -- gestor de cobro
         FOR ges IN c_gescobro LOOP
            xcuenta := xcuenta1;
            xctipban := xctipban1;

            BEGIN
               SELECT DISTINCT cpais
                          INTO v_cpais
                          FROM per_detper
                         WHERE sperson = ges.sperson
                           AND cagente = ff_agente_cpervisio(vcagente);
            EXCEPTION
               WHEN OTHERS THEN
                  IF v_cpais IS NULL THEN
                     BEGIN
                        SELECT cpais
                          INTO v_cpais
                          FROM per_direcciones d, provincias p
                         WHERE p.cprovin = d.cprovin
                           AND d.sperson = ges.sperson
                           AND d.cdomici = (SELECT MIN(cdomici)
                                              FROM per_direcciones
                                             WHERE sperson = ges.sperson
                                               AND cagente = ff_agente_cpervisio(vcagente));
                     EXCEPTION
                        WHEN OTHERS THEN
                           RETURN NULL;
                     END;
                  END IF;
            END;

            num_err := pac_siniestros.f_ins_destinatario(pnsinies, pntramit, ges.sperson,
                                                         xcuenta, xctipban, ppasigna, v_cpais,
                                                         pctipdes, pcpagdes, pcactpro);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END LOOP;
      --etm fin
      ELSE
         IF NVL(f_parproductos_v(vsproduc, '2_CABEZAS'), 0) = 1 THEN
            -- Se debe buscar el sperson de la persona que queda vigente, no de la fallecida
            BEGIN
               SELECT a.sperson
                 INTO xriesgo
                 FROM asegurados a
                WHERE a.sseguro = psseguro
                  AND a.norden = NVL(pnriesgo, 1)   --JRH Aqui va un = no un <>
                  AND a.ffecfin IS NULL;   -- BUG11183:DRA:30/09/2009
            EXCEPTION
               WHEN OTHERS THEN
                  -- Por si acaso s?lo hay un asegurado
                  xriesgo := pnriesgo;
            END;
         ELSE
            BEGIN
               SELECT r.sperson
                 INTO xriesgo
                 FROM riesgos r
                WHERE r.sseguro = psseguro
                  AND r.nriesgo = NVL(pnriesgo, 1);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 105709;   --{Riesgo no encontrado en la tabla ...}
            END;
         END IF;

         FOR aseg IN c_asegurados LOOP
            /*
             siniestro solo lo hacemos al riesgo}
            */
            IF (NVL(ppagdes, 0) = 1
                AND xriesgo = aseg.sperson)
               OR(NVL(ppagdes, 0) = 0) THEN
               IF aseg.norden = 1 THEN
                  xcuenta := xcuenta1;
                  xctipban := xctipban1;
               --{Si es el 1er aseg. agafem la seva compte}
               ELSIF aseg.norden = 2 THEN
                  xcuenta := xcuenta2;
                  xctipban := xctipban2;
               END IF;

               BEGIN
                  SELECT DISTINCT cpais
                             INTO v_cpais
                             FROM per_detper
                            WHERE sperson = aseg.sperson
                              AND cagente = ff_agente_cpervisio(vcagente);
               EXCEPTION
                  WHEN OTHERS THEN
                     IF v_cpais IS NULL THEN
                        BEGIN
                           SELECT cpais
                             INTO v_cpais
                             FROM per_direcciones d, provincias p
                            WHERE p.cprovin = d.cprovin
                              AND d.sperson = aseg.sperson
                              AND d.cdomici = (SELECT MIN(cdomici)
                                                 FROM per_direcciones
                                                WHERE sperson = aseg.sperson
                                                  AND cagente = ff_agente_cpervisio(vcagente));
                        EXCEPTION
                           WHEN OTHERS THEN
                              RETURN NULL;
                        END;
                     END IF;
               END;

               num_err := pac_siniestros.f_ins_destinatario(pnsinies, pntramit, aseg.sperson,
                                                            xcuenta, xctipban, ppasigna,
                                                            v_cpais, 1, pcpagdes, pcactpro);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            END IF;
         END LOOP;
      END IF;

      --MCA  se asigna seg?n el n? de destinatarios y se actualiza pais de residencia
      SELECT COUNT('x')
        INTO ndestina
        FROM sin_tramita_destinatario
       WHERE nsinies = pnsinies
         AND ntramit = pntramit;

      IF ndestina > 0 THEN
         UPDATE sin_tramita_destinatario std
            SET std.pasigna = ROUND(100 / ndestina, 2),
                std.cpaisre = (SELECT DISTINCT cpais
                                          FROM per_detper
                                         WHERE sperson = std.sperson
                                           AND cagente = ff_agente_cpervisio(vcagente))
          WHERE std.nsinies = pnsinies
            AND std.ntramit = pntramit;

         SELECT SUM(NVL(pasigna, 0))
           INTO ntotal
           FROM sin_tramita_destinatario
          WHERE nsinies = pnsinies
            AND ntramit = pntramit;

         IF ntotal <> 100 THEN
            --Asignaci?n para llegar al 100%
            UPDATE sin_tramita_destinatario
               SET pasigna = pasigna + 0.01
             WHERE nsinies = pnsinies
               AND ntramit = pntramit
               AND ROWNUM = 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sin_rescates.f_ins_destinatario', 1,
                     'Error no controlado', SQLERRM);
         RETURN 140999;   --{Error no controlado}
   END f_ins_destinatario;

   -- Bug14834:10/06/2010:ASN:ini
   /******************************************************************************
                                       NOMBRE:       F_PROVMAT
      DESCRIPCION:  Calcula la provision matematica teniendo en cuenta los rescates
      PARAMETROS:
      INPUT: psseguro IN sin_siniestro.sseguro%TYPE,
             pfecha   IN NUMBER
      RETORNA VALUE:
             VALOR(NUMBER)-----> Provision Matematica
   ******************************************************************************/
   FUNCTION f_provmat(psesion IN NUMBER, psseguro IN seguros.sseguro%TYPE, pfecha IN NUMBER)
      RETURN NUMBER IS
      v_provision    NUMBER := 0;
      -- Bug 0018439 - 10/05/2011 - JMF
      v_saldo        NUMBER;
   BEGIN
      -- Bug 0018439 - 10/05/2011 - JMF
      v_provision := NULL;

      SELECT NVL(fbuscasaldo(1, psseguro, pfecha), 0)
        INTO v_saldo
        FROM DUAL;

      BEGIN
         SELECT a.provision
           INTO v_provision
           FROM (SELECT DECODE(si.ccausin,
                               4, 0,
                               5, GREATEST(v_saldo - pa.isinret, 0),
                               v_provision) provision   -- modelo antiguo de siniestros
                   FROM siniestros si, pagosini pa, seguros se
                  WHERE pa.nsinies = si.nsinies
                    AND si.ccausin IN(4, 5)
                    AND pa.cestpag IN
                          (0, 1, 2)   -- BUG 17316 - 18/01/2011 - JMP - pagaments pendents, acceptats o cobrats
                    AND(pa.fefepag > TO_DATE(pfecha, 'yyyymmdd')
                        OR pa.fefepag IS NULL)
                    AND si.sseguro = psseguro
                    AND si.sseguro = se.sseguro
                    AND NVL(pac_parametros.f_parempresa_n(se.cempres, 'MODULO_SINI'), 0) = 0
                 UNION
                 SELECT DECODE(si.ccausin,
                               4, 0,
                               5, GREATEST(v_saldo - pa.isinret, 0),
                               v_provision)   -- modelo nuevo
                   FROM sin_siniestro si, sin_tramita_pago pa, sin_tramita_movpago mp,
                        seguros se
                  WHERE pa.nsinies = si.nsinies
                    AND si.ccausin IN(4, 5)
                    AND mp.sidepag = pa.sidepag
                    --  AND(mp.fefepag > TO_DATE(pfecha, 'yyyymmdd') 15362 AVT 04-10-2010
                    --  OR mp.fefepag IS NULL) 15362 AVT 04-10-2010
                    --INI--bug 15362--ETM--03/11/2010--CEM- Provisiones: Provisión matemática de las pólizas con rescates pendientes
                    -- Bud 0023580 - 12/09/2012 - JMF: control data fefepag
                    AND mp.nmovpag = (SELECT MAX(nmovpag)
                                        FROM sin_tramita_movpago m
                                       WHERE m.sidepag = pa.sidepag
                                         AND TRUNC(m.fefepag) <= TO_DATE(pfecha, 'yyyymmdd'))
                    --FIN--bug 15362--ETM--03/11/2010--CEM- Provisiones: Provisión matemática de las pólizas con rescates pendientes
                    AND mp.cestpag IN(0, 1)
                    AND si.sseguro = psseguro
                    AND si.sseguro = se.sseguro
                    AND NVL(pac_parametros.f_parempresa_n(se.cempres, 'MODULO_SINI'), 0) = 1) a;
      EXCEPTION
         WHEN OTHERS THEN
            -- Bug 0018439 - 10/05/2011 - JMF
            v_provision := NULL;
      END;

      -- ini Bug 0018439 - 10/05/2011 - JMF
      IF v_provision IS NULL THEN
         BEGIN
            -- sinistro defunción, -- obert, reapertura --> asignamos provisión 0.
            SELECT NVL(MAX(0), v_saldo)
              INTO v_provision
              FROM sin_siniestro si, seguros se, sin_movsiniestro ms
             WHERE si.ccausin IN(1, 2402)
               AND si.cmotsin = 0
               AND si.sseguro = psseguro
               AND si.sseguro = se.sseguro
               AND NVL(pac_parametros.f_parempresa_n(se.cempres, 'MODULO_SINI'), 0) = 1
               AND ms.nsinies = si.nsinies
               AND ms.nmovsin = (SELECT MAX(ms1.nmovsin)
                                   FROM sin_movsiniestro ms1
                                  WHERE ms1.nsinies = ms.nsinies
                                    AND ms1.festsin <= TO_DATE(pfecha, 'yyyymmdd'))
               AND ms.cestsin IN(0, 4);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN v_saldo;
         END;
      END IF;

      -- fin Bug 0018439 - 10/05/2011 - JMF
      RETURN v_provision;
   EXCEPTION
      WHEN OTHERS THEN
         -- Bug 0018439 - 10/05/2011 - JMF
         RETURN v_saldo;
   END f_provmat;

-- Bug14834:10/06/2010:ASN:fin

   -- Bug 20241 - RSC - 23/11/2011 - LCOL_T004-Parametrización de Rescates (retiros)
   FUNCTION f_alta_siniestro_final(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pffecmov IN DATE,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pimporte IN NUMBER,
      pipenali IN NUMBER,
      pctipdes IN NUMBER DEFAULT 1,
      pnivel IN NUMBER DEFAULT 1,
      pfinal IN NUMBER DEFAULT 1,
      pcidioma IN NUMBER DEFAULT pac_md_common.f_get_cxtidioma,
      -- Ini Bug 26676 -- ECP -- 14/05/2013
      pdiafinv NUMBER DEFAULT 0,
      pskipfanulac NUMBER DEFAULT 0
                                   -- Fin Bug 26676 -- ECP -- 14/05/2013
   )
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_SIN_RESCATES.f_alta_siniestro_final';
      vparams        VARCHAR2(500)
         := 'psseguro = ' || psseguro || ' pnriesgo = ' || pnriesgo || ' pffecmov = '
            || pffecmov || ' pccausin = ' || pccausin || ' pcmotsin = ' || pcmotsin
            || ' pimporte = ' || pimporte || ' pipenali = ' || pipenali || ' pctipdes = '
            || pctipdes || ' pnivel = ' || pnivel || ' pfinal = ' || pfinal || ' pcidioma = '
            || pcidioma || ' pdiafinv = ' || pdiafinv || ' pskipfanulac = ' || pskipfanulac;
      v_nsinies      sin_siniestro.nsinies%TYPE;
      v_nmovpag      sin_tramita_movpago.nmovpag%TYPE;
      vnum_err       NUMBER;
      v_cempres      NUMBER;
      vcunitra       sin_redtramitador.ctramitad%TYPE;
      vctramitad     sin_codtramitador.ctramitad%TYPE;
      vtraza         NUMBER := 0;   -- 27.0021570 / 0109147
      vsinterf       NUMBER;
   BEGIN
      DELETE FROM tmp_primas_consumidas
            WHERE sseguro = psseguro;

      vtraza := 110;   -- 27.0021570 / 0109147
      vnum_err := pac_sin_rescates.f_gest_siniestro(psseguro, pnriesgo, pffecmov, pccausin,
                                                    pcidioma, pimporte, pipenali, NULL, NULL,
                                                    NULL, pnivel, v_nsinies, NULL, NULL, NULL,
                                                    pcmotsin, pctipdes, pdiafinv,
                                                    pskipfanulac);

      IF vnum_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'PAC_SIN_RESCATES.f_alta_siniestro_final', 1,
                     'Error al llamar pac_siniestros.f_gest_siniestro',
                     f_axis_literales(vnum_err));
         RETURN vnum_err;
      END IF;

      BEGIN
         vtraza := 120;   -- 27.0021570 / 0109147

         INSERT INTO primas_consumidas
                     (sseguro, nnumlin, nriesgo, norden, ipricons, ircm, fecha, frescat,
                      cestado)
            SELECT sseguro, nnumlin, nriesgo, norden, ipricons, ircm, fecha, frescat, 1
              FROM tmp_primas_consumidas
             WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_SIN_RESCATES.f_alta_siniestro_final', 1,
                        'Error al reservar las primas consumidas', SQLERRM);
            RETURN 152110;   --{Error al reservar les primes consumides}
      END;

      IF pfinal = 1 THEN
         vtraza := 130;   -- 27.0021570 / 0109147

         -- Forzamos a pagado automáticamente
         FOR regs IN (SELECT sidepag
                        FROM sin_tramita_pago
                       WHERE nsinies = v_nsinies) LOOP
            -- Aceptado
            vtraza := 140;   -- 27.0021570 / 0109147
            vnum_err := pac_siniestros.f_ins_movpago(regs.sidepag, 1, pffecmov, 1, NULL, NULL,
                                                     0, v_nmovpag, 0, 0);

            IF vnum_err <> 0 THEN
               p_tab_error(f_sysdate, f_user, 'PAC_SIN_RESCATES.f_alta_siniestro_final', 2,
                           'Error al llamar pac_siniestros.f_ins_movpago',
                           f_axis_literales(vnum_err));
               RETURN vnum_err;
            END IF;

            -- Pagado
            vtraza := 150;   -- 27.0021570 / 0109147
            vnum_err := pac_siniestros.f_ins_movpago(regs.sidepag, 2, pffecmov, 1, NULL, NULL,
                                                     0, v_nmovpag, 0, 0);

            IF vnum_err <> 0 THEN
               p_tab_error(f_sysdate, f_user, 'PAC_SIN_RESCATES.f_alta_siniestro_final', 3,
                           'Error al llamar pac_siniestros.f_ins_movpago',
                           f_axis_literales(vnum_err));
               RETURN vnum_err;
            END IF;
         END LOOP;

         -- Finaliza rescate
         vtraza := 160;   -- 27.0021570 / 0109147
         vnum_err := pac_sin_rescates.f_finaliza_rescate(psseguro, pnriesgo, v_nsinies, 1);

         IF vnum_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_SIN_RESCATES.f_alta_siniestro_final', 4,
                        'Error al llamar pac_siniestros.f_finaliza_rescate',
                        f_axis_literales(vnum_err));
            RETURN vnum_err;
         END IF;

         vtraza := 170;   -- 27.0021570 / 0109147

         SELECT cempres
           INTO v_cempres
           FROM seguros
          WHERE sseguro = psseguro;

         vtraza := 180;   -- 27.0021570 / 0109147
         vnum_err := pac_siniestros.f_get_unitradefecte(v_cempres, vcunitra, vctramitad);

         IF vnum_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_SIN_RESCATES.f_alta_siniestro_final', 5,
                        'Error al llamar pac_siniestros.f_get_unitradefecte',
                        f_axis_literales(vnum_err));
            RETURN vnum_err;
         END IF;

         vtraza := 190;   -- 27.0021570 / 0109147
         vnum_err := pac_siniestros.f_estado_siniestro(v_nsinies, 1, NULL, vcunitra,
                                                       vctramitad, NULL, TRUNC(f_sysdate));

         IF vnum_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'PAC_SIN_RESCATES.f_alta_siniestro_final', 6,
                        'Error al llamar pac_siniestros.f_estado_siniestro',
                        f_axis_literales(vnum_err));
            RETURN vnum_err;
         END IF;
      -- 27.0021570: LCOL_A001-Temas pdtes.terminacion por no pago - 0109147 - Inicio
      ELSIF pfinal = 2 THEN
         vtraza := 200;

         -- Forzamos a pagado automáticamente
         FOR regs IN (SELECT sidepag
                        FROM sin_tramita_pago
                       WHERE nsinies = v_nsinies) LOOP
            -- Aceptado
            vtraza := 210;
            vnum_err := pac_siniestros.f_ins_movpago(regs.sidepag, 1, pffecmov, 1, NULL, NULL,
                                                     0, v_nmovpag, 0, 0);

            IF vnum_err <> 0 THEN
               p_tab_error(f_sysdate, f_user, 'PAC_SIN_RESCATES.f_alta_siniestro_final', 2,
                           'Error al llamar pac_siniestros.f_ins_movpago',
                           f_axis_literales(vnum_err));
               RETURN vnum_err;
            -- 28.0021570: LCOL_A001-Temas pdtes terminacion por no pago - Convenio - 0110567 - Inicio
            ELSE
               vnum_err := pac_siniestros.f_gestiona_cobpag(regs.sidepag, v_nmovpag, 1,
                                                            pffecmov, NULL, vsinterf);

               IF vnum_err <> 0 THEN
                  RETURN vnum_err;
               END IF;
            -- 28.0021570: LCOL_A001-Temas pdtes terminacion por no pago - Convenio - 0110567 - Fin
            END IF;
         -- No se deja Pagado
         END LOOP;
      -- 27.0021570: LCOL_A001-Temas pdtes.terminacion por no pago - 0109147 - Fin
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparams, SQLERRM);
         RETURN NULL;
   END f_alta_siniestro_final;

-- Fin Bug 20241

   -- Bug 20665 - RSC - 08/03/2012
   FUNCTION f_ajustar_unidades(
      psseguro IN NUMBER,
      pdetmovi IN NUMBER,
      pnnumlin IN NUMBER,
      pcesta IN NUMBER,
      pimport IN NUMBER,
      pvalliq IN NUMBER,
      pmultipl IN NUMBER)
      RETURN NUMBER IS
      v_resultado    NUMBER;
      v_nparacts     NUMBER;
   BEGIN
      v_resultado :=((pimport / pvalliq) * pmultipl);

      IF pdetmovi = 94 THEN
         SELECT NVL(SUM(nunidad), 0)
           INTO v_nparacts
           FROM ctaseguro
          WHERE sseguro = psseguro
            AND cesta = pcesta
            AND nnumlin < pnnumlin
            AND((cestado <> '9')
                OR(cestado = '9'
                   AND imovimi <> 0
                   AND imovimi IS NOT NULL));

         IF pmultipl = 1 THEN
            v_resultado := v_resultado +(v_nparacts - v_resultado);
         ELSIF pmultipl = -1 THEN
            v_resultado := v_resultado -(v_nparacts - ABS(v_resultado));
         END IF;
      END IF;

      RETURN v_resultado;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sin_rescates.f_ajustar_unidades', 1,
                     'Error no controlado', SQLERRM);
         RETURN NULL;
   END f_ajustar_unidades;

-- Fin Bug 20665
   FUNCTION f_ajustar_unidades_shw(
      psseguro IN NUMBER,
      pdetmovi IN NUMBER,
      pnnumlin IN NUMBER,
      pcesta IN NUMBER,
      pimport IN NUMBER,
      pvalliq IN NUMBER,
      pmultipl IN NUMBER)
      RETURN NUMBER IS
      v_resultado    NUMBER;
      v_nparacts     NUMBER;
   BEGIN
      v_resultado :=((pimport / pvalliq) * pmultipl);

      IF pdetmovi = 94 THEN
         SELECT NVL(SUM(nunidad), 0)
           INTO v_nparacts
           FROM ctaseguro_shadow
          WHERE sseguro = psseguro
            AND cesta = pcesta
            AND nnumlin < pnnumlin
            AND((cestado <> '9')
                OR(cestado = '9'
                   AND imovimi <> 0
                   AND imovimi IS NOT NULL));

         IF pmultipl = 1 THEN
            v_resultado := v_resultado +(v_nparacts - v_resultado);
         ELSIF pmultipl = -1 THEN
            v_resultado := v_resultado -(v_nparacts - ABS(v_resultado));
         END IF;
      END IF;

      RETURN v_resultado;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sin_rescates.f_ajustar_unidades_shw', 1,
                     'Error no controlado', SQLERRM);
         RETURN NULL;
   END f_ajustar_unidades_shw;

   FUNCTION f_ins_prereserva(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pffecmov IN DATE,
      pretenc IN NUMBER,
      pipenal IN NUMBER,
      pctipcal IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO sin_tramita_prereserva
                  (nsinies, ntramit, freserva, pretenc, ipenali, ctipcal)
           VALUES (pnsinies, pntramit, pffecmov, pretenc, pipenal, pctipcal);

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         UPDATE sin_tramita_prereserva
            SET freserva = pffecmov,
                pretenc = pretenc,
                ipenali = pipenal,
                ctipcal = pctipcal
          WHERE nsinies = pnsinies
            AND ntramit = pntramit;

         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sin_rescates.f_ins_prereserva', 1,
                     'Error no controlado', SQLERRM);
         RETURN -1;
   END f_ins_prereserva;

    /************************************************************
     Guarda los datos utilizados para el calculo de la preserva
      param in  pnsinies
      param in  pntramit
      param in  pffecmov
      param in  pretenc
      param in  pipenal
      param in  pctipcal
      return number.
   ************************************************************/
   FUNCTION f_ins_prereserva_fnd(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pffecmov IN DATE,
      pcesta IN NUMBER,
      pireserva IN NUMBER,
      pnunidad IN NUMBER,
      piunidad IN NUMBER,
      pretenc IN NUMBER,
      pipenal IN NUMBER,
      pcgarant IN NUMBER,
      pireservashw IN NUMBER,
      piunidadshw IN NUMBER,
      pnunidadshw IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO sin_tramita_prereserva_fnd
                  (nsinies, ntramit, ccesta, nunidad, iunidad, cgarant, ireserva,
                   ireservashw, iunidadshw, nunidadshw)
           VALUES (pnsinies, pntramit, pcesta, pnunidad, piunidad, pcgarant, pireserva,
                   pireservashw, piunidadshw, pnunidadshw);

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         UPDATE sin_tramita_prereserva_fnd
            SET
                --        nunidad = pnunidad,
                iunidad = piunidad,
                iunidadshw = piunidadshw
          WHERE nsinies = pnsinies
            AND ntramit = pntramit
            AND ccesta = pcesta
            AND cgarant = pcgarant;

         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sin_rescates.f_ins_prereserva_fnd', 1,
                     'Error no controlado', SQLERRM);
         RETURN -1;
   END f_ins_prereserva_fnd;

   /************************************************************
     Funcion que realiza la compensacion entre los pagos de ahorro y rescate de la poliza anulada
     y el recibo de la nueva poliza saldada / prorrogada.
      param in  psseguro
      param in  pfanulac
      return number.
   ************************************************************/
   FUNCTION f_compensa_poliza_saldada(psseguro IN seguros.sseguro%TYPE, pfanulac IN DATE)
      RETURN NUMBER IS
      error_controlado EXCEPTION;
      vobject        VARCHAR2(500) := 'PAC_SIN_RESCATES.F_COMPENSA_POLIZA_SALDADA';
      vparams        VARCHAR2(500) := 'psseguro = ' || psseguro;
      vtraza         NUMBER := 0;
      v_numerr       NUMBER;
      v_query        VARCHAR2(2000);
      v_tot_pagos    NUMBER;
      v_sperson      per_personas.sperson%TYPE;
      v_cempres      NUMBER;
      vcunitra       sin_redtramitador.ctramitad%TYPE;
      vctramitad     sin_codtramitador.ctramitad%TYPE;
      v_num_siniestros NUMBER;
      v_nrecibo      recibos.nrecibo%TYPE;
      v_nrecibo_new  recibos.nrecibo%TYPE;
      v_cdelega      recibos.cdelega%TYPE;
      v_itotalr      vdetrecibos.itotalr%TYPE;
      v_sseguro_new  recibos.sseguro%TYPE;
      v_sidepag_new  sin_tramita_pago.sidepag%TYPE;
      v_smovagr      NUMBER;
      v_nliqmen      NUMBER;
      v_nliqlin      NUMBER;
      v_iparcialp    NUMBER;
      v_cestcomp     sin_recibos_compensados.cestcomp%TYPE;
      lsproces       NUMBER;
   BEGIN
      vtraza := 1;

      -- Recuperamos el numero de siniestros y el importe total de los
      -- pagos de ahorro (causa 4 motivo 1) y rescate (4 - 2)
      -- Solo compensamos los pagos al tomador (CTIPDES = 7)
      SELECT SUM(p.isinret), COUNT(s.nsinies)
        INTO v_tot_pagos, v_num_siniestros
        FROM sin_tramita_pago p, sin_siniestro s, sin_tramita_movpago m
       WHERE s.sseguro = psseguro
         AND s.ccausin = 4
         AND s.cmotsin IN(1, 2)
         AND p.nsinies = s.nsinies
         AND p.ctipdes = 7   -- Tomador
         AND m.sidepag = p.sidepag
         AND m.nmovpag = (SELECT MAX(nmovpag)
                            FROM sin_tramita_movpago
                           WHERE sidepag = p.sidepag)
         AND m.cestpag = 0;

      vtraza := 2;

      -- Recuperamos el importe total del recibo de la nueva poliza
      -- Las polizas de saldado / prorrogado solo tienen 1 riesgo
      BEGIN
         SELECT r.nrecibo, v.itotalr, r.sseguro, r.cdelega
           INTO v_nrecibo, v_itotalr, v_sseguro_new, v_cdelega
           FROM recibos r,
                movrecibo m,
                vdetrecibos v,
                (SELECT irestorec, cestcomp, nrecibo, sseguro
                   FROM sin_recibos_compensados
                  WHERE cestcomp = 'P') rc
          WHERE m.nrecibo = r.nrecibo
            AND NOT EXISTS(SELECT 1
                             FROM sin_recibos_compensados rc1
                            WHERE m.nrecibo = rc1.nrecibo
                              AND r.sseguro = rc1.sseguro
                              AND rc1.cestcomp = 'C')
            AND r.sseguro = (SELECT MAX(sseguro)
                               FROM reemplazos
                              WHERE sreempl = psseguro)
            AND NVL(r.nriesgo, 1) = 1
            AND m.cestrec = 0
            AND m.smovrec = (SELECT MAX(smovrec)
                               FROM movrecibo m1
                              WHERE m1.nrecibo = m.nrecibo)
            AND v.nrecibo = r.nrecibo
            AND r.ctiprec NOT IN(9, 13, 15)
            AND r.sseguro = rc.sseguro(+)
            AND r.nrecibo = rc.nrecibo(+);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 9907498;
      END;

      -- Validamos que el importe de los pagos y del recibo coincidan, sino no continuamos.
      IF v_tot_pagos <> v_itotalr THEN
         RETURN 9907498;
      END IF;

      vtraza := 3;

      -- Comunicamos a SAP el recibo correspondiente a la prima de la nueva poliza
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'GESTIONA_COBPAG'),
             0) = 1 THEN
         SELECT sproces.NEXTVAL
           INTO lsproces
           FROM DUAL;

         vtraza := 31;
         v_numerr := pac_ctrl_env_recibos.f_proc_recpag_mov(pac_md_common.f_get_cxtempresa(),
                                                            v_sseguro_new, 1, 4, lsproces);

         IF v_numerr <> 0 THEN
            RAISE error_controlado;
         END IF;
      END IF;

      vtraza := 32;

      -- Si hay dos pagos, anulamos el recibo original, se creara un recibo por cada pago. Para
      -- compensar un recibo se tiene que hacer por la totalidad del importe.
      IF v_num_siniestros > 1 THEN
         v_smovagr := 0;
         v_numerr := f_movrecibo(v_nrecibo, 2, pfanulac, 2, v_smovagr, v_nliqmen, v_nliqlin,
                                 pfanulac, NULL, v_cdelega, NULL, NULL);

         IF v_numerr <> 0 THEN
            RAISE error_controlado;
         END IF;

         -- Comunicamos a SAP la anulación correspondiente a la prima de la nueva poliza
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                              'GESTIONA_COBPAG'),
                0) = 1 THEN
            vtraza := 33;
            -- Comunicamos los recibos al SAP
            v_numerr :=
               pac_ctrl_env_recibos.f_proc_recpag_mov(pac_md_common.f_get_cxtempresa(),
                                                      v_sseguro_new, 1, 4, lsproces);

            IF v_numerr <> 0 THEN
               RAISE error_controlado;
            END IF;
         END IF;
      END IF;

      vtraza := 4;
      v_iparcialp := 0;   -- Importe acumulado de la cantidad pagada

      -- Por cada pago (1 pago 1 siniestro) realizamos las siguientes acciones
      FOR reg IN (SELECT p.sidepag, p.isinret, p.nsinies, p.ntramit, s.sseguro
                    FROM sin_tramita_pago p, sin_siniestro s, sin_tramita_movpago m
                   WHERE s.sseguro = psseguro
                     AND s.ccausin = 4
                     AND s.cmotsin IN(1, 2)
                     AND p.nsinies = s.nsinies
                     AND p.ctipdes = 7   -- Tomador
                     AND m.sidepag = p.sidepag
                     AND m.nmovpag = (SELECT MAX(nmovpag)
                                        FROM sin_tramita_movpago
                                       WHERE sidepag = p.sidepag)
                     AND m.cestpag = 0) LOOP
         vtraza := 4;

         --Si hay mas de un pago, creamos un recibo por pago.
         IF v_num_siniestros > 1 THEN
            vtraza := 5;
            v_numerr := f_crea_recibo_parcial(NULL, v_nrecibo, v_nrecibo_new, v_smovagr,
                                              reg.isinret);

            IF v_numerr <> 0 THEN
               RAISE error_controlado;
            END IF;
         ELSE
            -- Si solo hay 1 siniestro, el recibo a compensar es el original
            v_nrecibo_new := v_nrecibo;
         END IF;

         vtraza := 6;
         -- Creamos el destinatario del pago (Compañia)
         v_numerr := pac_siniestros.f_destinatario_empresa(reg.nsinies, reg.ntramit,
                                                           pac_md_common.f_get_cxtempresa(),
                                                           v_sperson);

         IF v_numerr <> 0 THEN
            RAISE error_controlado;
         END IF;

         vtraza := 7;
         -- Anulamos el pago original realizado contra el tomador
         v_numerr := f_anula_pago_inicial(reg.sidepag, pfanulac);

         IF v_numerr <> 0 THEN
            RAISE error_controlado;
         END IF;

         vtraza := 8;
         -- Creamos el nuevo pago
         v_iparcialp := v_iparcialp + reg.isinret;
--         IF v_iparcialp >= v_itotalr THEN
--            v_cestcomp := 'C';
--         ELSE
--            v_cestcomp := 'P';
--         END IF;

         -- Compensamos siempre por la totalidad del importe, se ha dividido el recibo original en diversos
         v_numerr := f_crear_pago_compensatorio_cia(reg.sidepag, psseguro, pfanulac, v_sperson,
                                                    v_sidepag_new, v_nrecibo_new, 'C');

         IF v_numerr <> 0 THEN
            RAISE error_controlado;
         END IF;

         vtraza := 9;
      -- Cierre del siniestro
      -- El nuevo pago se genera con la marca de 'ultimo pago' el siniestro se cerrara automaticamente
      -- cuando el pago sea confirmado por el SAP.
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN error_controlado THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparams, SQLERRM);
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'v_numerr = ' || v_numerr, NULL);
         RETURN v_numerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparams, SQLERRM);
         RETURN 1;
   END f_compensa_poliza_saldada;

   FUNCTION f_anula_pago_inicial(psidepag IN sin_tramita_pago.sidepag%TYPE, pfanulac IN DATE)
      RETURN NUMBER IS
      error_controlado EXCEPTION;
      vobject        VARCHAR2(500) := 'PAC_SIN_RESCATES.f_anula_pago_inicial';
      vparams        VARCHAR2(500) := 'psidepag = ' || psidepag || ' pfanulac = ' || pfanulac;
      vtraza         NUMBER := 0;
      v_numerr       NUMBER;
      vnmovpag       sin_tramita_movpago.nmovpag%TYPE;
      vnmovres       sin_tramita_reserva.nmovres%TYPE;
      vres           sin_tramita_reserva%ROWTYPE;
      vpago          sin_tramita_pago%ROWTYPE;
   BEGIN
      vtraza := 1;
      -- Movimiento de anulacion del pago
      v_numerr := pac_siniestros.f_ins_movpago(psidepag, 8,   -- cestpag
                                               pfanulac,   -- fefepag
                                               0,   -- cestval
                                               TRUNC(f_sysdate),   -- fcontab
                                               NULL,   -- sproces
                                               0,   -- cestpagant
                                               vnmovpag, 0,   -- csubpag
                                               0);   -- csubpagant

      IF v_numerr <> 0 THEN
         RAISE error_controlado;
      END IF;

      vtraza := 2;

      SELECT *
        INTO vpago
        FROM sin_tramita_pago
       WHERE sidepag = psidepag;

      vtraza := 3;

      SELECT *
        INTO vres
        FROM sin_tramita_reserva
       WHERE sidepag = psidepag
         AND nmovres = (SELECT MAX(nmovres)
                          FROM sin_tramita_reserva
                         WHERE sidepag = psidepag);

      vtraza := 4;
      -- Movimiento de reserva por la anulacion del pago
      v_numerr := pac_siniestros.f_ins_reserva(vres.nsinies,   --pnsinies
                                               vres.ntramit,   -- pntramit
                                               vres.ctipres,   --pctipres
                                               vres.cgarant,   --pcgarant
                                               1,   -- ctipcal
                                               TRUNC(f_sysdate),   --fmovres
                                               vres.cmonres,   --pcmonres
                                               vres.ireserva + vpago.isinret,   --pireserva
                                               vres.ipago - vpago.isinret,   --pipago
                                               vres.icaprie,   --picaprie
                                               vres.ipenali,   --pipenali
                                               vres.iingreso,   --piingreso
                                               vres.irecobro,   --piingreso
                                               vres.fresini,   --pfresini
                                               vres.fresfin,   --pfresfin
                                               NULL,   --pfultpag
                                               psidepag,   --psidepag
                                               vres.iprerec,   --piprerec
                                               vres.ctipgas,   --pctipgas
                                               vnmovres,   --pcmovres
                                               5   --cmovres
                                                );

      IF v_numerr <> 0 THEN
         RAISE error_controlado;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN error_controlado THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparams, SQLERRM);
         p_tab_error(f_sysdate, f_user, vobject, vtraza, 'v_numerr = ' || v_numerr, NULL);
         RETURN v_numerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparams, SQLERRM);
         RETURN 1;
   END f_anula_pago_inicial;

   FUNCTION f_crear_pago_compensatorio_cia(
      psidepag IN sin_tramita_pago.sidepag%TYPE,
      psseguro IN seguros.sseguro%TYPE,
      pfanulac IN DATE,
      psperson IN per_personas.sperson%TYPE,
      psidepag_nou OUT sin_tramita_pago.sidepag%TYPE,
      pnrecibo IN recibos.nrecibo%TYPE,
      pcestcomp IN sin_recibos_compensados.cestcomp%TYPE)
      RETURN NUMBER IS
      error_controlado EXCEPTION;
      vobject        VARCHAR2(500) := 'PAC_SIN_RESCATES.f_crear_pago_compensatorio_cia';
      vparams        VARCHAR2(500)
         := 'psidepag = ' || psidepag || ' psseguro = ' || psseguro || ' pfanulac = '
            || pfanulac || ' psperson = ' || psperson || ' pnrecibo = ' || pnrecibo
            || ' pcestcomp = ' || pcestcomp;
      vtraza         NUMBER := 0;
      v_numerr       NUMBER;
      vnmovpag       sin_tramita_movpago.nmovpag%TYPE;
      vnmovres       sin_tramita_reserva.nmovres%TYPE;
      vres           sin_tramita_reserva%ROWTYPE;
      vpago          sin_tramita_pago%ROWTYPE;
      vccc           per_ccc%ROWTYPE;
      vsidepag       sin_tramita_pago.sidepag%TYPE;
      vnsinies       sin_tramita_reserva.nsinies%TYPE;
      vidres         sin_tramita_reserva.idres%TYPE;
      vsinterf       NUMBER;
   BEGIN
      vtraza := 1;

      SELECT *
        INTO vpago
        FROM sin_tramita_pago
       WHERE sidepag = psidepag;

      vtraza := 2;

      SELECT nsinies, idres
        INTO vnsinies, vidres
        FROM sin_tramita_reserva
       WHERE sidepag = psidepag
         AND nmovres = (SELECT MAX(nmovres)
                          FROM sin_tramita_reserva
                         WHERE sidepag = psidepag);

      SELECT *
        INTO vres
        FROM sin_tramita_reserva
       WHERE nsinies = vnsinies
         AND idres = vidres
         AND nmovres = (SELECT MAX(nmovres)
                          FROM sin_tramita_reserva
                         WHERE nsinies = vnsinies
                           AND idres = vidres);

      vtraza := 3;

      BEGIN
         SELECT *
           INTO vccc
           FROM per_ccc
          WHERE sperson = psperson;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- Si no encontramos la CCC correspondiente a la Cia no la informamos, no es necesaria.
            NULL;
      END;

      vtraza := 4;
      -- Movvimiento de disminucion de la reserva por pago
      v_numerr := pac_siniestros.f_ins_reserva(vres.nsinies,   --pnsinies
                                               vres.ntramit,   -- pntramit
                                               vres.ctipres,   --pctipres
                                               vres.cgarant,   --pcgarant
                                               1,   -- ctipcal
                                               TRUNC(f_sysdate),   --fmovres
                                               vres.cmonres,   --pcmonres
                                               vres.ireserva - vpago.isinret,   --pireserva
                                               vres.ipago + vpago.isinret,   --pipago
                                               vres.icaprie,   --picaprie
                                               vres.ipenali,   --pipenali
                                               vres.iingreso,   --piingreso
                                               vres.irecobro,   --piingreso
                                               vres.fresini,   --pfresini
                                               vres.fresfin,   --pfresfin
                                               NULL,   --pfultpag
                                               NULL,   --psidepag
                                               vres.iprerec,   --piprerec
                                               vres.ctipgas,   --pctipgas
                                               vnmovres,   --pcmovres
                                               4   --cmovres
                                                );

      IF v_numerr <> 0 THEN
         RAISE error_controlado;
      END IF;

      vtraza := 5;
      -- Creacion de la cabecera del pago
      vsidepag := NULL;
      v_numerr :=
         pac_siniestros.f_ins_pago(vsidepag, vres.nsinies, vres.ntramit, psperson, 4,   -- ctipdes CIA
                                   2,   -- ctippag PAGO
                                   vpago.cconpag,   -- cconpag
                                   vpago.ccauind,   -- ccauind,
                                   vpago.cforpag,   -- cforpag,
                                   vpago.fordpag,   -- fordpag,
                                   vccc.ctipban,   -- ctipban,
                                   vccc.cbancar,   -- cbancar,
                                   vpago.isinret,   -- isinret,
                                   vpago.iretenc,   -- piretenc
                                   vpago.iiva,   -- iiva
                                   vpago.isuplid,   -- isuplid
                                   vpago.ifranq,   -- ifranq
                                   vpago.iresrcm,   -- iresrcm
                                   vpago.iresred,   -- iresred
                                   NULL,   -- nfacref
                                   NULL,   -- ffacref
                                   1,   -- sidepagtemp  --> Solicitud de creacion de nuevo pago
                                   1,   -- cultpag  --> Es ultimo pago
                                   NULL,   -- ncheque  -- Bug 33884/212340 ACL
                                   vpago.ireteiva,   -- ireteiva
                                   vpago.ireteica,   -- ireteica
                                   vpago.ireteivapag,   -- ireteivapag
                                   vpago.ireteicapag,   -- ireteicapag
                                   vpago.iica,   -- iica
                                   vpago.iicapag,   -- iicapag
                                   vpago.cmonpag);   -- pcmonres

      IF v_numerr <> 0 THEN
         RAISE error_controlado;
      END IF;

      vtraza := 6;
      --  Movimiento inicial del pago (pago Aceptado)
      vnmovpag := 0;   -- Movimiento inicial
      v_numerr := pac_siniestros.f_ins_movpago(vsidepag, 1, vpago.fordpag, 1, NULL, NULL, 0,
                                               vnmovpag, 0, 0);

      IF v_numerr <> 0 THEN
         RAISE error_controlado;
      END IF;

      vtraza := 7;
      -- Creacion del detalle del pago
      v_numerr :=
         pac_siniestros.f_ins_pago_gar
                       (vres.nsinies, vres.ntramit, vsidepag, vres.ctipres, vnmovres - 1,   -- nmovres (Correspondiente al movimiento de reserva previo)
                        vres.cgarant, NULL,   --fresini
                        NULL,   --fresfin
                        vres.cmonres, vpago.isinret,   --isinret
                        vpago.iiva,   --iiva
                        vpago.isuplid,   --isuplid,
                        vpago.iretenc,   --iretenc,
                        vpago.ifranq,   --ifranq,
                        vpago.iresrcm,   --iresrcm,
                        vpago.iresred,   --iresred,
                        NULL,   --pretenc,
                        vpago.iiva,   --piva,
                        vpago.cmonres, vpago.isinret,   --isinretpag,
                        vpago.iiva,   --iivapag,
                        vpago.isuplid,   --isuplidpag,
                        vpago.iretenc,   --iretencpag,
                        vpago.ifranq,   --ifranqpag,
                        vpago.fcambio,   --fcambio,
                        vpago.cconpag,   --pcconpag
                        1,   --pnordem
                        NULL,   --preteiva,
                        NULL,   --preteica,
                        NULL,   --ireteiva,
                        NULL,   --ireteica,
                        NULL,   --ireteivapag,
                        NULL,   --ireteicapag,
                        NULL,   --pica,
                        NULL,   --iica,
                        NULL   --iicapag
                            );

      IF v_numerr <> 0 THEN
         RAISE error_controlado;
      END IF;

      vtraza := 8;

      -- Insertamos en la tabla de compensacíon de pagos
      INSERT INTO sin_recibos_compensados
                  (nsinies, sseguro, sidepag_old, nrecibo, sidepag_new, irestorec, cestcomp)
           VALUES (vres.nsinies, psseguro, psidepag, pnrecibo, vsidepag, 0, pcestcomp);

      vtraza := 9;
      -- Comunicamos el pago al SAP, el pago pasa a estado 'Remesado'
      v_numerr := pac_siniestros.f_gestiona_cobpag(vsidepag, vnmovpag, 1, vpago.fordpag, NULL,
                                                   vsinterf);

      IF v_numerr <> 0 THEN
         RAISE error_controlado;
      END IF;

      psidepag_nou := vsidepag;
      RETURN 0;
   EXCEPTION
      WHEN error_controlado THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparams, SQLERRM);
         p_tab_error(f_sysdate, f_user, vobject, vtraza,
                     'v_numerr = ' || v_numerr || ' vnmovres = ' || vnmovres || ' vsidepag = '
                     || vsidepag,
                     NULL);
         RETURN v_numerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vtraza, vparams, SQLERRM);
         RETURN 1;
   END f_crear_pago_compensatorio_cia;

   FUNCTION f_crea_recibo_parcial(
      pmodali IN NUMBER,
      pnrecibo IN NUMBER,
      pnreciboclon OUT NUMBER,
      psmovagr IN OUT NUMBER,
      pirecibo IN NUMBER,
      pfefecto IN DATE DEFAULT NULL,
      porigen IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_SIN_RESCATES.f_crea_recibo_parcial';
      vpasexec       NUMBER := 0;
      vparam         VARCHAR2(100)
         := ' m=' || pmodali || ' r=' || pnrecibo || ' a=' || psmovagr || ' e=' || pfefecto
            || ' o=' || porigen;
      w_nrecclon     recibos.nrecibo%TYPE := 0;
      w_fechaux      recibosclon.frecclon%TYPE := f_sysdate;
      w_cagente      recibos.cagente%TYPE;
      w_sseguro      recibos.sseguro%TYPE;
      w_cdelega      recibos.cdelega%TYPE;
      w_sproduc      seguros.sproduc%TYPE;
      w_nliqmen      NUMBER := NULL;
      w_nliqlin      NUMBER := NULL;
      n_error        NUMBER;
      xccobban       recibos.ccobban%TYPE;
      xcempres       recibos.cempres%TYPE;
      xctipcoa       NUMBER;
      xsmovrec       NUMBER;
      xfmovim        DATE;
      xfemisio       DATE;
      xfefecto       DATE;
      v_por_irecibo  NUMBER;
      v_iconcep      NUMBER;
   BEGIN
      -- Esta funcion es una copia de la funcion pac_adm.f_clonrecibo adaptada al proceso de compensacion
      vpasexec := 1000;
      n_error := 0;

      --
      -- Recuperamos datos del recibo original
      --
      BEGIN
         vpasexec := 1010;

         SELECT r.sseguro, r.cagente, r.cdelega, r.ccobban, r.cempres, r.femisio, r.fefecto,
                r.ctipcoa, s.sproduc
           INTO w_sseguro, w_cagente, w_cdelega, xccobban, xcempres, xfemisio, xfefecto,
                xctipcoa, w_sproduc
           FROM recibos r, seguros s
          WHERE r.nrecibo = pnrecibo
            AND s.sseguro = r.sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            -- Recibo no encontrado en la tabla RECIBOS
            RETURN 101902;
      END;

      vpasexec := 1020;
      pnreciboclon := NULL;
      w_nrecclon := pac_adm.f_get_seq_cont(xcempres);

      IF NVL(w_nrecclon, 0) = 0 THEN
         -- Devuelto número de recibo incorrecto
         RETURN 102876;
      END IF;

      --
      -- Inserción de recibos en tabla RECIBOS
      --
      vpasexec := 1030;

      BEGIN
         INSERT INTO recibos
                     (nrecibo, cagente, cempres, nmovimi, sseguro, femisio, fefecto, fvencim,
                      ctiprec, cdelega, ccobban, cestaux, nanuali, nfracci, cestimp, nriesgo,
                      cforpag, cbancar, nmovanu, cretenc, pretenc, ncuacoa, ctipcoa, cestsop,
                      cmanual, nperven, ctransf, cgescob, festimp, ctipban, esccero, ctipcob,
                      creccia, cvalidado, sperson, ctipapor, ctipaportante, cmodifi, ncuotar)
            SELECT w_nrecclon, cagente, cempres, nmovimi, sseguro, w_fechaux,   -- femisio -- bug: 29068
                   NVL(pfefecto, fefecto), fvencim, ctiprec, cdelega, xccobban, cestaux,
                   nanuali, nfracci, cestimp, nriesgo, cforpag, cbancar, nmovanu, cretenc,
                   pretenc, ncuacoa, ctipcoa, cestsop, cmanual, nperven, ctransf, cgescob,
                   festimp, ctipban, esccero, ctipcob, creccia, cvalidado, sperson, ctipapor,
                   ctipaportante, cmodifi, ncuotar
              FROM recibos
             WHERE nrecibo = pnrecibo;
      EXCEPTION
         WHEN OTHERS THEN
            -- Error al insertar en RECIBOS
            RETURN 103847;
      END;

      --
      -- Duplicación del recibo clonado en la tabla DETRECIBOS.
      --
      vpasexec := 1040;

      BEGIN
         SELECT iconcep
           INTO v_iconcep
           FROM detrecibos
          WHERE nrecibo = pnrecibo
            AND cconcep = 0;

         v_por_irecibo := ROUND(pirecibo / v_iconcep, 10);

         INSERT INTO detrecibos
                     (nrecibo, cconcep, cgarant, nriesgo, iconcep, cageven, nmovima)
            SELECT w_nrecclon, cconcep, cgarant, nriesgo, f_round(iconcep * v_por_irecibo),
                   cageven, nmovima
              FROM detrecibos
             WHERE nrecibo = pnrecibo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 103469;   -- Registre no trobat a DETRECIBOS
         WHEN DUP_VAL_ON_INDEX THEN
            RETURN 102311;   -- Registre duplicat en DETRECIBOS
         WHEN OTHERS THEN
            RETURN 103513;   -- Error a l' inserir a DETRECIBOS
      END;

      --
      -- Duplicación del recibo clonado en la tabla RECIBOSREDCOM.
      --
      vpasexec := 1050;

      BEGIN
         INSERT INTO recibosredcom
                     (nrecibo, cempres, cagente, ctipage, nnivel)
            SELECT w_nrecclon, cempres, cagente, ctipage, nnivel
              FROM recibosredcom
             WHERE nrecibo = pnrecibo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 103909;   -- Registre no trobat a RECIBOSREDCOM
         WHEN DUP_VAL_ON_INDEX THEN
            RETURN 103907;   -- Registre duplicat en RECIBOSREDCOM
         WHEN OTHERS THEN
            RETURN 103354;   -- Error a l' inserir a RECIBOSREDCOM
      END;

      --
      -- Duplicación del recibo clonado en la tabla VDETRECIBOS.
      --
      vpasexec := 1060;
      n_error := f_vdetrecibos('R', w_nrecclon);

      IF n_error <> 0 THEN
         RETURN 103473;   -- Error a l' inserir a VDETRECIBOS
      END IF;

      --
      --Insertem els registres necessaris a movrecibo
      --
      vpasexec := 1070;
      n_error := f_movrecibo(w_nrecclon, 0, NULL, NULL, psmovagr, w_nliqmen, w_nliqlin,
                             w_fechaux, xccobban, w_cdelega, NULL, w_cagente);

      IF NVL(f_parproductos_v(w_sproduc, 'HAYCTACLIENTE'), 0) = 1 THEN
         vpasexec := 1067;
         n_error := pac_ctacliente.f_ins_movrecctacli(xcempres, w_sseguro, NULL, w_nrecclon);

         IF n_error <> 0 THEN
            RETURN n_error;
         END IF;
      END IF;

      --
      -- Inserción del recibo clonado en la tabla RECIBOSCLON.
      --
      vpasexec := 1090;

      BEGIN
         INSERT INTO recibosclon
                     (sseguro, nreciboant, nreciboact, frecclon, corigen)
              VALUES (w_sseguro, pnrecibo, w_nrecclon, w_fechaux, porigen);
      END;

      vpasexec := 1100;
      pnreciboclon := w_nrecclon;

      IF NVL(xctipcoa, 0) > 0 THEN
         BEGIN
            SELECT smovrec
              INTO xsmovrec
              FROM movrecibo
             WHERE nrecibo = pnreciboclon
               AND fmovfin IS NULL;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user,
                           'PAC_ADM.f_clonrecibo  num_recibo = ' || pnreciboclon, NULL,
                           'WHEN OTHERS RETURN 104043', SQLERRM);
               RETURN 104043;
         END;

         xfefecto := NVL(pfefecto, xfefecto);

         IF xfemisio < xfefecto THEN
            xfmovim := xfefecto;
         ELSE
            xfmovim := xfemisio;
         END IF;

         n_error := f_insctacoas(pnreciboclon, 0, xcempres, xsmovrec, xfmovim);

         IF n_error <> 0 THEN
            RETURN n_error;
         END IF;
      END IF;   -- Del IF que mira si tiene coaseguro

      vpasexec := 1100;

      DECLARE
         xcactivi       seguros.cactivi%TYPE;
         xcramo         seguros.cramo%TYPE;
         xcmodali       seguros.cmodali%TYPE;
         xctipseg       seguros.ctipseg%TYPE;
         xccolect       seguros.ccolect%TYPE;
         xfefecto       recibos.fefecto%TYPE;
         xfvencim       recibos.fvencim%TYPE;
         xcmoneda       codidivisa.cmoneda%TYPE;
         xnproces       procesoscab.sproces%TYPE;
      BEGIN
         vpasexec := 1110;
         n_error := f_procesini(f_user, xcempres, 'CLONRECIBO',
                                'Ant=' || pnrecibo || ' Act=' || w_nrecclon, xnproces);

         SELECT b.cactivi, b.cramo, b.cmodali, b.ctipseg, b.ccolect, a.fefecto, a.fvencim,
                pac_monedas.f_moneda_producto(b.sproduc)
           INTO xcactivi, xcramo, xcmodali, xctipseg, xccolect, xfefecto, xfvencim,
                xcmoneda
           FROM recibos a, seguros b
          WHERE a.nrecibo = w_nrecclon
            AND b.sseguro = a.sseguro;

         vpasexec := 1120;
         n_error := pac_cesionesrea.f_cessio_det(xnproces, w_sseguro, w_nrecclon, xcactivi,
                                                 xcramo, xcmodali, xctipseg, xccolect,
                                                 xfefecto, xfvencim, 1, xcmoneda);

         IF n_error <> 0 THEN
            RAISE NO_DATA_FOUND;
         END IF;
      END;

      -- Comunicamos el nuevo recibo a SAP
      DECLARE
         k_cempresa CONSTANT empresas.cempres%TYPE
                      := NVL(pac_md_common.f_get_cxtempresa, f_parinstalacion_n('EMPRESADEF'));
         vterminal      VARCHAR2(100);
         vpsinterf      NUMBER;
         vemitido       NUMBER;
         verror_pago    NUMBER;
      BEGIN
         IF NVL(pac_parametros.f_parempresa_n(k_cempresa, 'CONTAB_ONLINE'), 0) = 1
            AND NVL(pac_parametros.f_parempresa_n(k_cempresa, 'GESTIONA_COBPAG'), 0) = 1 THEN
            n_error := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vterminal);
            vpasexec := 2000;
            vpsinterf := NULL;
            n_error := pac_con.f_emision_pagorec(k_cempresa, 1, 4, w_nrecclon, NULL,
                                                 vterminal, vemitido, vpsinterf, verror_pago,
                                                 f_user, NULL, NULL, NULL, 1);

            IF n_error <> 0
               OR TRIM(verror_pago) IS NOT NULL THEN
               IF n_error = 0 THEN
                  RETURN 9903116;   -- Error al enviar al ERP
               END IF;

               p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                           'Genera recibo - error no controlado ',
                           verror_pago || ' - ' || n_error);
               RETURN n_error;
            END IF;
         END IF;
      END;

      RETURN n_error;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam || ' e=' || n_error,
                     SQLCODE || ' ' || SQLERRM);
         RETURN 180272;
   END f_crea_recibo_parcial;

   /*******************************************************************************
   p_calc_rescatev: Procedimiento que calcula todos los datos necesarios para
                    pasar de pre-siniestro a siniestro para los rescates
                    de productos definidos con una ventana de liquidez.
                    Reservas, destinatarios, pagos, etc.
   ********************************************************************************/
----------------------------------------------------------------------------------------------------------------------------------------
   PROCEDURE p_calc_rescatev IS
      v_cempres      NUMBER;
      v_sproces      NUMBER;
      num_err        NUMBER;
      error          NUMBER;
      vivalora_tot   sin_tramita_reserva.ireserva%TYPE;
      v_cgarant      sin_tramita_reserva.cgarant%TYPE;
      v_ctipres      sin_tramita_reserva.ctipres%TYPE := 1;
      v_nmovres      sin_tramita_reserva.nmovres%TYPE;
      vipenali       sin_tramita_reserva.ipenali%TYPE;
      vivalora       sin_tramita_reserva.ireserva%TYPE;
      vicapris       sin_tramita_reserva.icaprie%TYPE;
      xppagdes       NUMBER;
      v_sidepag      sin_tramita_reserva.sidepag%TYPE;
      v_ipago        sin_tramita_reserva.ipago%TYPE;
      v_nprolin      NUMBER;
      v_ccesta       NUMBER;
      cont_malos     NUMBER := 0;
      hayrescates    NUMBER := 0;
      v_cunitra      VARCHAR2(200);
      v_ctramitad    VARCHAR2(200);
      v_nmovsin      NUMBER;
      vifranq        sin_tramita_reserva.ifranq%TYPE;

      CURSOR c_ventanas(pcempres IN NUMBER) IS
         SELECT   sproduc, fsolici, fvaloracion, factivos
             FROM rescate_ventana
            WHERE cempres = pcempres
              AND fvaloracion <= TRUNC(f_sysdate)
              AND isfvaloracion IS NULL
         ORDER BY sproduc;

      CURSOR c_rescates(p_sproduc IN NUMBER, p_fsol IN DATE, p_fvalora IN DATE) IS
         SELECT s.sseguro, s.cempres, s.cactivi, s.sproduc, ss.nsinies, ss.ccausin, ss.cmotsin,
                ss.nriesgo, ss.fsinies, ss.fnotifi
           FROM sin_movsiniestro ms, sin_siniestro ss, seguros s
          WHERE s.sproduc = p_sproduc
            AND ss.sseguro = s.sseguro
            AND ss.ccausin = 4
            AND ss.cmotsin = 0
            AND ss.fsinies >= p_fsol
            AND ss.fsinies <= p_fvalora
            AND ms.nsinies = ss.nsinies
            AND ms.nmovsin IN(SELECT MAX(nmovsin)
                                FROM sin_movsiniestro b
                               WHERE b.nsinies = ms.nsinies)
            AND ms.cestsin = 5;
   BEGIN
      BEGIN
         SELECT cempres
           INTO v_cempres
           FROM usuarios
          WHERE cusuari = f_user;
      END;

      error := f_procesini(f_user, v_cempres, 'CALCRESCATEV',
                           'Calculo rescates ventana liquidez', v_sproces);

      FOR i IN c_ventanas(v_cempres) LOOP
         hayrescates := 1;

         FOR c IN c_rescates(i.sproduc, i.fsolici, i.fvaloracion) LOOP
            hayrescates := 0;   --Hay rescates. De momento no cierro la ventana

            BEGIN
               SELECT ccesta
                 INTO v_ccesta
                 FROM segdisin2
                WHERE sseguro = c.sseguro
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM segdisin2
                                  WHERE sseguro = c.sseguro);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_ccesta := NULL;
               WHEN TOO_MANY_ROWS THEN
                  v_ccesta := NULL;
            END;

            IF (NVL(f_parproductos_v(c.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
                AND pac_mantenimiento_fondos_finv.f_cestas_valoradas(i.fvaloracion, v_cempres,
                                                                     v_ccesta, c.sseguro) = 0) THEN
               vivalora_tot := 0;

               FOR reg IN (SELECT DISTINCT cgarant
                                      FROM sin_gar_causa_motivo sgcm, sin_causa_motivo scm
                                     WHERE sgcm.scaumot = scm.scaumot
                                       AND scm.ccausin = c.ccausin
                                       AND scm.cmotsin = c.cmotsin
                                       AND sgcm.sproduc = c.sproduc
                                       AND sgcm.cactivi = c.cactivi) LOOP
                  v_cgarant := reg.cgarant;
                  num_err := pac_sin_formula.f_cal_valora(c.fsinies, c.sseguro, c.nriesgo,
                                                          c.nsinies, 0, 0, c.sproduc,
                                                          c.cactivi, v_cgarant, c.ccausin,
                                                          c.cmotsin, c.fnotifi, i.fvaloracion,
                                                          NULL, NULL, vivalora, vipenali,
                                                          vicapris, vifranq);

                  IF num_err <> 0 THEN
                     --Error al calcular los valores de rescate
                     v_nprolin := 0;
                     error := f_proceslin(v_sproces,
                                          f_axis_literales(107405) || ' -- nsinies '
                                          || c.nsinies || ' -- error ' || num_err,
                                          c.sseguro, v_nprolin, 1);
                     cont_malos := cont_malos + 1;
                     ROLLBACK;
                     GOTO error1;
                  END IF;

                  -- Se inserta la reserva
                  num_err := pac_siniestros.f_ins_reserva(c.nsinies, 0, v_ctipres, v_cgarant,
                                                          1, i.fvaloracion, NULL,
                                                          NVL(vivalora, 0) - NVL(vipenali, 0),
                                                          NULL, vicapris, vipenali, NULL, NULL,
                                                          NULL, NULL, NULL, NULL, NULL, NULL,
                                                          v_nmovres, 1);

                  IF num_err <> 0 THEN
                     v_nprolin := 0;
                     --Error reserva
                     error := f_proceslin(v_sproces,
                                          f_axis_literales(9000464) || ' '
                                          || f_axis_literales(9001408) || ' -- nsinies '
                                          || c.nsinies || ' -- error ' || num_err,
                                          c.sseguro, v_nprolin, 1);
                     cont_malos := cont_malos + 1;
                     ROLLBACK;
                     GOTO error1;
                  END IF;

                  vivalora_tot := vivalora_tot +(NVL(vivalora, 0) - NVL(vipenali, 0));
               END LOOP;

               xppagdes := NULL;   -- tantos pagos como asegurados

               IF NVL(f_parproductos_v(c.sproduc, 'FISCALIDAD_2_CABEZAS'), 0) = 1 THEN
                  xppagdes := 1;
               ELSE
                  xppagdes := 0;
               END IF;

               --Creamos los destinatarios del siniestro}
               num_err :=
                  pac_sin_rescates.f_ins_destinatario(c.nsinies, 0, c.sseguro, c.nriesgo,
                                                      xppagdes, 1,   -- BUG 20241 - RSC - 22/11/2011
                                                      1, NULL, NULL, NULL, NULL);

               IF num_err <> 0 THEN
                  --Error en el calculo de destinatario
                  v_nprolin := 0;
                  error := f_proceslin(v_sproces,
                                       f_axis_literales(151907) || ' -- nsinies ' || c.nsinies
                                       || ' -- error ' || num_err,
                                       c.sseguro, v_nprolin, 1);
                  cont_malos := cont_malos + 1;
                  ROLLBACK;
                  GOTO error1;
               END IF;

               pac_sin_formula.p_borra_mensajes;

               IF NVL(vivalora_tot, 0) > 0 THEN
                  num_err := pac_sin_formula.f_genera_pago(c.sseguro, c.nriesgo, v_cgarant,
                                                           i.sproduc, c.cactivi, c.nsinies, 0,
                                                           c.ccausin, c.cmotsin, c.fsinies,
                                                           c.fnotifi);

                  IF num_err <> 0 THEN
                     --Error Generar Pago
                     v_nprolin := 0;
                     error := f_proceslin(v_sproces,
                                          f_axis_literales(9000464) || ' '
                                          || f_axis_literales(9000497) || ' '
                                          || f_axis_literales(103463) || ' -- nsinies'
                                          || c.nsinies || ' -- error ' || num_err,
                                          c.sseguro, v_nprolin, 1);
                     cont_malos := cont_malos + 1;
                     ROLLBACK;
                     GOTO error1;
                  END IF;

                  num_err := pac_sin_formula.f_inserta_pago(c.nsinies, 0, v_ctipres, v_cgarant,
                                                            v_sidepag, v_ipago);

                  IF num_err <> 0 THEN
                     --Pago
                     v_nprolin := 0;
                     error := f_proceslin(v_sproces,
                                          f_axis_literales(103463) || ' -- nsinies '
                                          || c.nsinies || ' -- error ' || num_err,
                                          c.sseguro, v_nprolin, 1);
                     cont_malos := cont_malos + 1;
                     ROLLBACK;
                     GOTO error1;
                  END IF;

                  num_err := f_traspaso_tmp_primas_cons(c.sseguro, NULL, c.nsinies);

                  IF num_err <> 0 THEN
                     v_nprolin := 0;
                     error := f_proceslin(v_sproces,
                                          'Trasp. prima. cons. -- nsinies ' || c.nsinies
                                          || ' -- error ' || num_err,
                                          c.sseguro, v_nprolin, 1);
                     cont_malos := cont_malos + 1;
                     ROLLBACK;
                     GOTO error1;
                  END IF;
               END IF;

               IF f_vivo_o_muerto(c.sseguro, 2, i.fvaloracion) = 1 THEN   -- hay un asegurado fallecido
                  IF NVL(f_parproductos_v(c.sproduc, 'FISCALIDAD_2_CABEZAS'), 0) <> 1 THEN
                     num_err := pac_sin_rescates.f_tratar_sinies_fallec(c.sseguro, c.fsinies);

                     IF num_err <> 0 THEN
                        v_nprolin := 0;
                        error := f_proceslin(v_sproces,
                                             'Tratar sinies fallec ' || c.nsinies
                                             || ' -- error ' || num_err,
                                             c.sseguro, v_nprolin, 1);
                        cont_malos := cont_malos + 1;
                        ROLLBACK;
                        GOTO error1;
                     END IF;
                  END IF;
               END IF;

               num_err := pac_siniestros.f_get_tramitador(c.nsinies, 99, 99, v_cunitra,
                                                          v_ctramitad);

               IF NVL(num_err, 99999) > 1 THEN
                  error := f_proceslin(v_sproces,
                                       'Error tramitador ' || c.nsinies || ' -- error '
                                       || num_err,
                                       c.sseguro, v_nprolin, 1);
                  cont_malos := cont_malos + 1;
                  ROLLBACK;
                  GOTO error1;
               END IF;

               num_err := pac_siniestros.f_ins_movsiniestro(c.nsinies, 0, f_sysdate, NULL,
                                                            v_cunitra, v_ctramitad, v_nmovsin);

               IF num_err <> 0 THEN
                  error := f_proceslin(v_sproces,
                                       'Error cambio estado ' || c.nsinies || ' -- error '
                                       || num_err,
                                       c.sseguro, v_nprolin, 1);
                  cont_malos := cont_malos + 1;
                  ROLLBACK;
                  GOTO error1;
               END IF;

               hayrescates := 1;   -- Ha ido todo bien. Cerraré la ventana si no hay problemas
               COMMIT;

               <<error1>>
               NULL;
            ELSE
               hayrescates := 0;   --No hay cesta para algun sseguro o producto,
                                   --de momento no cierro la ventana de liquidacion.
            END IF;
         END LOOP;

         IF hayrescates = 1 THEN
            UPDATE rescate_ventana
               SET isfvaloracion = 1
             WHERE cempres = v_cempres
               AND sproduc = i.sproduc
               AND fsolici = i.fsolici
               AND fvaloracion = i.fvaloracion;

            COMMIT;
         END IF;
      END LOOP;

      num_err := f_procesfin(v_sproces, cont_malos);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sin_rescates.p_calc_rescatev', 2,
                     'error al calcular rescate', SQLERRM);
   END p_calc_rescatev;

   /*******************************************************************************
   p_pag_rescatev: Procedimiento que acepta los pagos de los rescates
                   de productos definidos con una ventana de liquidez.
   ********************************************************************************/
----------------------------------------------------------------------------------------------------------------------------------------
   PROCEDURE p_pag_rescatev IS
      v_cempres      NUMBER;
      v_sproces      NUMBER;
      error          NUMBER;
      num_err        NUMBER;
      v_nmovpag      NUMBER;
      v_nprolin      NUMBER;
      cont_malos     NUMBER := 0;

      CURSOR c_ventanas(pcempres IN NUMBER) IS
         SELECT   sproduc, fsolici, fvaloracion, factivos
             FROM rescate_ventana
            WHERE cempres = pcempres
              AND factivos = TRUNC(f_sysdate)
         ORDER BY sproduc;

      CURSOR c_rescates(p_sproduc IN NUMBER, p_fsol IN DATE, p_fvalora IN DATE) IS
         SELECT   s.sseguro, s.cempres, s.cactivi, s.sproduc, ss.nsinies, ss.ccausin,
                  ss.cmotsin, ss.nriesgo, ss.fsinies, ss.fnotifi
             FROM sin_movsiniestro ms, sin_siniestro ss, seguros s
            WHERE s.sproduc = 573
              AND ss.sseguro = s.sseguro
              AND ss.ccausin = 4
              AND ss.cmotsin = 0
              AND ss.fsinies >= '03/12/2015'
              AND ss.fsinies <= '24/11/2016'
              AND ms.nsinies = ss.nsinies
              AND ms.nmovsin IN(SELECT MAX(nmovsin)
                                  FROM sin_movsiniestro b
                                 WHERE b.nsinies = ms.nsinies)
              AND ms.cestsin = 0
              AND EXISTS(SELECT nsinies
                           FROM sin_movsiniestro a
                          WHERE a.nsinies = ms.nsinies
                            AND a.cestsin = 5
                            AND a.nmovsin = 1)
         ORDER BY sproduc;
   BEGIN
      BEGIN
         SELECT cempres
           INTO v_cempres
           FROM usuarios
          WHERE cusuari = f_user;
      END;

      error := f_procesini(f_user, v_cempres, 'PAGORESCATEV', 'Pago rescates ventana liquidez',
                           v_sproces);

      FOR i IN c_ventanas(v_cempres) LOOP
         FOR c IN c_rescates(i.sproduc, i.fsolici, i.fvaloracion) LOOP
            FOR regs IN (SELECT sidepag
                           FROM sin_tramita_pago
                          WHERE nsinies = c.nsinies) LOOP
               -- Aceptado
               num_err := pac_siniestros.f_ins_movpago(regs.sidepag, 1, i.factivos, 1, NULL,
                                                       NULL, 0, v_nmovpag, 0, 0);

               IF num_err <> 0 THEN
                  v_nprolin := 0;
                  error := f_proceslin(v_sproces,
                                       f_axis_literales(9000464) || ' '
                                       || f_axis_literales(9903655) || ' -- nsinies '
                                       || c.nsinies || ', sidepag=' || regs.sidepag
                                       || ' -- error ' || num_err,
                                       c.sseguro, v_nprolin, 1);
                  cont_malos := cont_malos + 1;
                  ROLLBACK;
               ELSE
                  COMMIT;
               END IF;
            END LOOP;
         END LOOP;
      END LOOP;

      num_err := f_procesfin(v_sproces, cont_malos);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_sin_rescates.p_pag_rescatev', 2,
                     'error al aceptar pago de rescate', SQLERRM);
   END p_pag_rescatev;
END pac_sin_rescates;

/

  GRANT EXECUTE ON "AXIS"."PAC_SIN_RESCATES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_RESCATES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_RESCATES" TO "PROGRAMADORESCSI";
