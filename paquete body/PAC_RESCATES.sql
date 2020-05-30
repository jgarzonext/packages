--------------------------------------------------------
--  DDL for Package Body PAC_RESCATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_RESCATES" AS
   /******************************************************************************
   NOMBRE:       PAC_RESCATES
   PROPÓSITO:    Realiza los rescates
   REVISIONES:

   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0       -            -               1. Creación de package
    2.0       27/03/2009   RSC             2. Incidencia en el cálculo de compensación fiscal en rescates.
    3.0       09/07/2008   ICV             3. Modificació Bug.: 10615 - Revisió de la parametrització d'accions
    4.0       17/09/2009   RSC             4. Bug 0010828: CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
    5.0       23/09/2009   DRA             5. 0011183: CRE - Suplemento de alta de asegurado ya existente
    6.0       22/01/2010   RSC             6. 0012822 - CEM: RT - Tratamiento fiscal rentas a 2 cabezas
    7.0       03/02/2010   DRA             7. 0012384: CEM - Ajustes pantallas contatación/simulación de CRS (prima única)
    8.0       19/02/2010   ICV             8. 0013274: ERROR EN RESCATES PIAS
    9.0       11/03/2010   JRH             9. 0012136: CEM - RVI - Verificación productos RVI
    10.0      02/06/2010   JRH             10.0014802: Error validación rescates
    11.0      13/07/2011   DRA             11.0019054: CIV800-No funcionen les sol?licituds de rescats a Beta
    12.0      09/01/2011   JMP             12.0018423: LCOL705 - Multimoneda
   ******************************************************************************/
   FUNCTION f_vivo_o_muerto(psseguro IN NUMBER, pcestado IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      xcuantos       NUMBER;
      xvivos         NUMBER;
      xmuertos       NUMBER;
      xtodos         NUMBER;
   --********* Parámetros
   --**** ESTADO
   --****
   --**** 1- Devuelve los asegurados vivos
   --**** 2- Devuelve los asegurados muertos
   --**** 3- Devuelve el numero de asegurados tanto vivos como muertos
   BEGIN
      IF pcestado = 1 THEN
         SELECT COUNT(1)
           INTO xvivos
           FROM asegurados a
          WHERE a.sseguro = psseguro
            AND(a.ffecmue > pfecha
                OR a.ffecmue IS NULL)
            AND a.ffecfin IS NULL;   -- BUG11183:DRA:23/09/2009

         RETURN(xvivos);
      ELSIF pcestado = 2 THEN
         SELECT COUNT(1)
           INTO xmuertos
           FROM asegurados a
          WHERE a.sseguro = psseguro
            AND a.ffecmue <= pfecha;

         RETURN(xmuertos);
      ELSIF pcestado = 3 THEN
         SELECT COUNT(1)
           INTO xtodos
           FROM asegurados a
          WHERE a.sseguro = psseguro
            AND a.ffecfin IS NULL;   -- BUG11183:DRA:23/09/2009

         RETURN(xtodos);
      END IF;
   END f_vivo_o_muerto;

   FUNCTION f_tratar_sinies_fallec(psseguro IN NUMBER, pfrescat IN DATE)
      RETURN NUMBER IS
      --   Función que mira si hay algún asegurado fallecido. Si lo hay:
      --      1.- Debe reabrir el siniestro
      --      2.- Si no encuentra siniestro de fallecimiento de 1 titular (pólizas de migración)
      --         se abrirá en ese momento con la valoración del 50% de la provisión en el momento
      --         del fallecimiento
      xnsinies_mort  siniestros.nsinies%TYPE;   --       xnsinies_mort  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xcestsin_mort  siniestros.cestsin%TYPE;   --       xcestsin_mort  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      num_err        NUMBER;
      v_norden       asegurados.norden%TYPE;   --       v_norden       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_sproduc      seguros.sproduc%TYPE;   --       v_sproduc      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_cactivi      seguros.cactivi%TYPE;   --       v_cactivi      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vivalora       NUMBER;
      vipenali       NUMBER;
      vicapris       NUMBER;
      v_fsinies      siniestros.fsinies%TYPE;   --       v_fsinies      DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vnsinies       NUMBER;
      vnsinies_fall  NUMBER;
      entra          NUMBER := 0;   --> Entra = 1 querrá decir que hay siniestro y ya se ha valorado.
                                    --  Por tanto se pueden generar los pagos a los destinatarios, etc.
      vcramo         NUMBER;
      vcidioma       NUMBER;
      -- Bug 10828 - RSC - 10/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      v_cempres      seguros.cempres%TYPE;
      -- Fin Bug 10828
      vpasexec       NUMBER := 0;
   BEGIN
      vpasexec := 1;

      -- Buscamos el siniestro de baja de 1 titular (ccausin = 1 and cmotsin = 4) y si
      -- está cerrado lo reaperturamos. Si no existe lo damos de alta.
      FOR reg IN (SELECT   s.nsinies, cestsin, s.nasegur, s.fsinies, v.ivalora, seg.sproduc,
                           seg.cactivi
                      FROM siniestros s, valorasini v, seguros seg
                     WHERE s.sseguro = psseguro
                       AND s.nsinies = v.nsinies
                       AND seg.sseguro = s.sseguro
                       AND s.ccausin = 1   -- muerte
                       AND s.cmotsin = 4   -- baja 1 titular
                       AND v.cgarant = 1   -- cobertura de muerte
                       AND v.fvalora = (SELECT MAX(fvalora)
                                          FROM valorasini vv
                                         WHERE vv.nsinies = v.nsinies)
                  ORDER BY nsinies DESC) LOOP
         xnsinies_mort := reg.nsinies;
         xcestsin_mort := reg.cestsin;
         v_norden := reg.nasegur;
         v_fsinies := reg.fsinies;
         vivalora := reg.ivalora;
         v_sproduc := reg.sproduc;
         v_cactivi := reg.cactivi;
      END LOOP;

      vpasexec := 2;

      -- Bug 10828 - RSC - 10/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      BEGIN
         SELECT cempres
           INTO v_cempres
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101903;
      END;

      vpasexec := 3;

      -- Fin Bug 10828
      IF xnsinies_mort IS NULL
         OR xcestsin_mort IN(2, 3) THEN   -- no hay siniestro de cobertura
         -- de fallecimiento o está anulado o rechazado
         entra := 1;

         -- abrir siniestro de fallecimiento 1 titular
         BEGIN
            SELECT a.norden, NVL(a.ffecmue, a.ffecfin), s.sproduc, s.cactivi
              INTO v_norden, v_fsinies, v_sproduc, v_cactivi
              FROM asegurados a, seguros s
             WHERE a.sseguro = psseguro
               AND s.sseguro = a.sseguro
               AND a.ffecmue IS NOT NULL;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 120007;   -- error al leer de ASEGURADOS
         END;

         vpasexec := 4;

         -- RSC 12/12/2007 ----------------------------------------
         -- Miramos si existe el siniestro pero simplemente está sin valorar (ULK)
         BEGIN
            SELECT s.nsinies, s.cestsin, s.nasegur, s.fsinies
              INTO xnsinies_mort, xcestsin_mort, v_norden, v_fsinies
              FROM siniestros s
             WHERE s.sseguro = psseguro
               AND s.ccausin = 1
               AND s.cmotsin = 4
               AND (SELECT COUNT(*)
                      FROM valorasini v
                     WHERE v.nsinies = s.nsinies) = 0;
         EXCEPTION
            WHEN OTHERS THEN
               xnsinies_mort := NULL;
         END;

         vpasexec := 5;

         IF xnsinies_mort IS NOT NULL THEN   -- De verdad existe siniestro de fallecimiento previo a este rescate
                                             -- pero no se ha valorado todavia. Lo valoraremos aqui!!!
            vnsinies := xnsinies_mort;
         ELSE
            -- Se Inicializa el siniestro
            -- num_err := pac_sin.f_inicializar_siniestro(psseguro, v_norden, v_fsinies, trunc(f_sysdate), 'BAJA 1 TITULAR', 1, 4, 20, vnsinies, null);
            num_err := pac_sin_insert.f_insert_siniestros(vnsinies, psseguro, v_norden,
                                                          v_fsinies, TRUNC(f_sysdate), 0,
                                                          'BAJA 1 TITULAR', 1, NULL);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            vpasexec := 6;

            UPDATE siniestros
               SET cmotsin = 4,
                   nsubest = 20
             WHERE nsinies = vnsinies;

            num_err := pac_sin.f_tramitautomac(vnsinies);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;

         vpasexec := 7;

         IF (NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
             AND pac_mantenimiento_fondos_finv.f_cestas_valoradas(v_fsinies, v_cempres) = 0)
            OR(NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) <> 1) THEN
            vpasexec := 8;
            -- Se insertan las valoraciones
            num_err := pk_cal_sini.valo_pagos_sini(v_fsinies, psseguro, vnsinies, v_sproduc,
                                                   v_cactivi, 1, 1, 4, TRUNC(f_sysdate),
                                                   vivalora, vipenali, vicapris);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            vpasexec := 9;
            num_err := pac_sin_insert.f_insert_valoraciones(vnsinies, 1, TRUNC(f_sysdate),
                                                            vivalora, vipenali, vicapris);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;

         xnsinies_mort := vnsinies;
      ELSIF xcestsin_mort = 0 THEN   -- hay siniestro de fallecimiento en estado pendiente
         -- no hacemos nada. Se terminará de gestionar manualmente
         NULL;
      ELSE
         entra := 1;
         -- el xcestsin_mort = 1 -- finalizado
         -- lo reaperturamos
         vpasexec := 10;
         num_err := pac_sin.f_reabrir_sini(xnsinies_mort);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      vpasexec := 11;

      IF (NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
          AND pac_mantenimiento_fondos_finv.f_cestas_valoradas(v_fsinies, v_cempres) = 0)
         OR (NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) <> 1)
            AND entra = 1 THEN
         vpasexec := 12;
         -- Insertamos el destinatario: el asegurado vivo
         num_err := pac_sin_insert.f_insert_destinatarios(xnsinies_mort, psseguro, v_norden,
                                                          NULL, 1, 1, vivalora, NULL, NULL,
                                                          NULL);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         vpasexec := 13;
         pk_cal_sini.borra_mensajes;

         IF NVL(vivalora, 0) > 0 THEN
            vpasexec := 14;
            -- Generamos los pagos
            num_err := pk_cal_sini.gen_pag_sini(pfrescat, psseguro, xnsinies_mort, v_sproduc,
                                                v_cactivi, 1, 4, pfrescat);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            vpasexec := 15;
            num_err := pk_cal_sini.insertar_pagos(xnsinies_mort);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rescates.f_trata_sinies_fallec', vpasexec,
                     'Error no controlado', SQLERRM);
         RETURN 140999;
   END f_tratar_sinies_fallec;

   FUNCTION f_gest_siniestro(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pffecmov IN DATE,
      pctipmov IN NUMBER,
      pcidioma IN NUMBER,
      pimporte IN NUMBER,
      pipenali IN NUMBER,
      picaprm IN NUMBER,
      picapret IN NUMBER,
      picapred IN NUMBER,
      pnivel IN NUMBER,
      pnsinies OUT NUMBER)
      RETURN NUMBER IS
      xcausa         VARCHAR2(50);
      num_err        NUMBER := 0;
      xccausin       NUMBER;
      xcmotsin       NUMBER;
      xppagdes       NUMBER;
      xmoneda        NUMBER;
      xcestpag       NUMBER;
      xpretenc       NUMBER;
      xsperson       asegurados.sperson%TYPE;   --       xsperson       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xsproduc       seguros.sproduc%TYPE;   --       xsproduc       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xmuerto        NUMBER;
      ximport        NUMBER;
      ximport2       NUMBER;
      xfmuerte       asegurados.ffecmue%TYPE;   --       xfmuerte       DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vipenali       NUMBER;
      vivalora       NUMBER;
      vicapris       NUMBER;
      xcactivi       seguros.cactivi%TYPE;   --       xcactivi       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vivalora_tot   NUMBER;
      -- Bug 10828 - RSC - 10/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      v_cempres      seguros.cempres%TYPE;
      -- Fin Bug 10828
      vpasexec       NUMBER := 0;
   BEGIN
      vpasexec := 1;

      -- {Obtenemos el % de retención }
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

      vpasexec := 2;
      xpretenc := fbuscapreten(1, xsperson, xsproduc, TO_NUMBER(TO_CHAR(pffecmov, 'YYYYMMDD')));

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      IF pctipmov = 4 THEN
         xccausin := 4;   --{4.-  Rescats Total}
         xcmotsin := 0;
      ELSIF pctipmov = 5 THEN
         xccausin := 5;   --{5.-   Rescats Parcial}
         xcmotsin := 0;
      ELSIF pctipmov = 3 THEN   -- vencimiento
         xccausin := 3;
         xcmotsin := 0;
      END IF;

      vpasexec := 3;
      num_err := f_descausa(xccausin, pcidioma, xcausa);
       /*
      {creamos el siniestro associado
      */
      vpasexec := 4;
      num_err := pac_sin.f_inicializar_siniestro(psseguro, pnriesgo, pffecmov, pffecmov,
                                                 xcausa, xccausin, xcmotsin, 21,   --Pdte. Liquidación
                                                 pnsinies, NULL);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Bug 10828 - RSC - 10/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
      BEGIN
         SELECT cempres
           INTO v_cempres
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101903;
      END;

      -- Fin Bug 10828
      vpasexec := 5;

      -- RSC 11/12/2007 (lo haremos en el momento de asignar participaciones)
      IF (NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
          AND pac_mantenimiento_fondos_finv.f_cestas_valoradas(pffecmov, v_cempres) = 0)
         -- Bug 10828 - RSC - 10/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
         OR(NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
            AND xccausin = 5)
         -- Fin Bug 10828
         OR(NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) <> 1) THEN
         IF NVL(pimporte, 0) = 0 THEN   -- si el importe del rescte no viene informado
            vivalora_tot := 0;
            vpasexec := 6;

            FOR reg IN (SELECT cgarant
                          FROM prodcaumotsin
                         WHERE sproduc = xsproduc
                           AND ccausin = xccausin
                           AND cmotsin = xcmotsin) LOOP
               vpasexec := 7;
               -- Se ejecutan las valoraciones contra la garantía
               num_err := pk_cal_sini.valo_pagos_sini(pffecmov, psseguro, pnsinies, xsproduc,
                                                      xcactivi, reg.cgarant, xccausin,
                                                      xcmotsin, pffecmov, vivalora, vipenali,
                                                      vicapris);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               vpasexec := 8;
               num_err := pac_sin_insert.f_insert_valoraciones(pnsinies, reg.cgarant, pffecmov,
                                                               vivalora - vipenali, vipenali,
                                                               vicapris);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               vivalora_tot := vivalora_tot +(vivalora - vipenali);
            END LOOP;
         ELSE
            vivalora_tot := 0;
            vpasexec := 9;

            FOR reg IN (SELECT cgarant
                          FROM prodcaumotsin
                         WHERE sproduc = xsproduc
                           AND ccausin = xccausin
                           AND cmotsin = xcmotsin) LOOP
               /* {registramos la valoración del siniestro} */
               -- RSC 19/03/2008 (añado NVL en pipenali)
               vivalora := pimporte - NVL(pipenali, 0);
               vpasexec := 10;
               num_err := pac_sin_insert.f_insert_valoraciones(pnsinies, reg.cgarant,
                                                               pffecmov, vivalora,
                                                               NVL(pipenali, 0), pimporte);

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;

               vivalora_tot := vivalora_tot + vivalora;
            END LOOP;
         END IF;
      END IF;

      xppagdes := NULL;   -- tantos pagos como asegurados
      xmoneda := NULL;
      vpasexec := 11;

      -- Bug 12136 - JRH - 11/03/2010 - JRH - Este parámetro nos indicará cuantos pagos hacer
      IF NVL(f_parproductos_v(xsproduc, 'FISCALIDAD_2_CABEZAS'), 0) = 1 THEN
         xppagdes := 1;
      ELSE
         xppagdes := 0;
      END IF;

      -- Fi Bug 12136 - JRH - 11/03/2010 - JRH

      /*
      {Creamos los destinatarios del siniestro}
      */
      vpasexec := 12;

      IF (NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
          AND pac_mantenimiento_fondos_finv.f_cestas_valoradas(pffecmov, v_cempres) = 0)
         OR
           -- Bug 10828 - RSC - 10/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
         (  NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
            AND xccausin = 5)
         -- Fin Bug 10828
         OR(NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) <> 1) THEN
         vpasexec := 13;
         num_err := pac_sin_insert.f_insert_destinatarios(pnsinies, psseguro, pnriesgo,
                                                          xppagdes, 1, 1, vivalora_tot, NULL,
                                                          NULL, NULL);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         vpasexec := 14;
         pk_cal_sini.borra_mensajes;
      END IF;

      vpasexec := 15;

      -- Solo generamos pagos si el importe de la valoración es > 0
      IF (NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
          AND pac_mantenimiento_fondos_finv.f_cestas_valoradas(pffecmov, v_cempres) = 0)
         OR
           -- Bug 10828 - RSC - 10/09/2009 - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
         (  NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
            AND xccausin = 5)
         -- Fin Bug 10828
         OR(NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) <> 1) THEN
         IF NVL(vivalora_tot, 0) > 0
            AND pnivel = 1 THEN
            vpasexec := 16;
            -- Generamos los pagos
            num_err := pk_cal_sini.gen_pag_sini(pffecmov, psseguro, pnsinies, xsproduc,
                                                xcactivi, xccausin, xcmotsin, pffecmov);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            vpasexec := 17;
            num_err := pk_cal_sini.insertar_pagos(pnsinies);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;

            vpasexec := 18;
            num_err := f_traspaso_tmp_primas_cons(psseguro, NULL, pnsinies);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      END IF;

      vpasexec := 19;

      -- Tratamos ahora el siniestro en el caso de que haya un asegurado fallecido
      -- RSC 11/12/2007
      IF (NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
          AND pac_mantenimiento_fondos_finv.f_cestas_valoradas(pffecmov, v_cempres) = 0
          AND xccausin = 4)
         OR(NVL(f_parproductos_v(xsproduc, 'ES_PRODUCTO_INDEXADO'), 0) <> 1) THEN
         IF f_vivo_o_muerto(psseguro, 2, pffecmov) = 1 THEN   -- hay un asegurado fallecido
            vpasexec := 20;
            num_err := f_tratar_sinies_fallec(psseguro, pffecmov);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_gest_siniestro', vpasexec, 'Error no controlado',
                     SQLERRM);
         RETURN 140999;   --{Error no controlado}
   END f_gest_siniestro;

   FUNCTION f_to(pcagente IN NUMBER)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN f_parinstalacion_t('MAIL_RESC');
   END f_to;

   FUNCTION f_from(pcagente IN NUMBER)
      RETURN VARCHAR2 IS
      xcagente       agentes.sperson%TYPE;   --       xcagente       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xto            contactos.tvalcon%TYPE;   --       xto            VARCHAR2(100); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
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
        primera dirección de correo que existe.}
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
      psseguro IN NUMBER,
      pcagente IN NUMBER,
      pccausin IN NUMBER,
      pimport IN NUMBER,
      pfecha IN DATE,
      res OUT pk_cal_sini.t_val)
      RETURN NUMBER IS
      num_err        NUMBER;
      w_cgarant      prodcaumotsin.cgarant%TYPE;   --       w_cgarant      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_sproduc      seguros.sproduc%TYPE;   --       v_sproduc      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_cactivi      seguros.cactivi%TYPE;   --       v_cactivi      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      ximport        NUMBER;
   BEGIN
      -- Buscamos datos de la póliza
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

      -- buscamos la garantía a la cual se asigna el rescate
      BEGIN
         SELECT cgarant
           INTO w_cgarant
           FROM prodcaumotsin x
          WHERE x.ccausin = pccausin
            AND sproduc = v_sproduc;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'f_simulacion_rescate', NULL,
                        'error al buscar la garantía psseguro =' || psseguro || ' pcagente ='
                        || pcagente || ' pccausin =' || pccausin || 'pimport =' || pimport
                        || 'pfecha =' || pfecha,
                        SQLERRM);
            RETURN 110448;   -- el producto no está parametrizado correctamente
      END;

      IF pccausin = 5 THEN   --rescate parcial
         ximport := pimport;
         num_err := pk_cal_sini.f_simu_calc_sini(pfecha, pfecha, psseguro, v_cactivi,
                                                 v_sproduc, w_cgarant, 5, 0, ximport);
      ELSE
         ximport := NULL;
         num_err := pk_cal_sini.f_simu_calc_sini(pfecha, pfecha, psseguro, v_cactivi,
                                                 v_sproduc, w_cgarant, 4, 0, ximport);
      END IF;

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      res := pk_cal_sini.retorna_valores;
      pk_cal_sini.borra_mensajes;
      RETURN 0;
   END;

   FUNCTION f_sol_rescate(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pcmoneda IN NUMBER,
      pcagente IN NUMBER,
      pcidioma IN NUMBER,
      pccausin IN NUMBER,
      pimport IN NUMBER,
      pfecha IN DATE,
      pipenali IN NUMBER,
      pireduc IN NUMBER,
      pireten IN NUMBER,
      pirendi IN NUMBER,
      pnivel IN NUMBER)
      RETURN NUMBER IS
      rec_pend       pac_anulacion.recibos_pend;
      rec_cobr       pac_anulacion.recibos_cob;

      CURSOR recibos_pendientes IS
         SELECT r.nrecibo, m.fmovini, r.fefecto
           FROM recibos r, movrecibo m
          WHERE r.sseguro = psseguro
            AND NVL(f_cestrec(r.nrecibo, NULL), 0) = 0
            --AND f_cestrec_mv (r.nrecibo, 0) = 0
            AND m.nrecibo = r.nrecibo
            AND m.fmovfin IS NULL;

      nrec_pend      NUMBER := 0;
      xpersona       NUMBER;
      num_err        NUMBER;
      xnmovini       NUMBER;
      xtipo          NUMBER;
      xnsinies       NUMBER;
      xcmotmov       movseguro.cmotmov%TYPE := 112;   --Retencion por rescate   --       xcmotmov       NUMBER := 112;   --Retencion por rescate --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xfrom          VARCHAR2(1000);
      xto2           VARCHAR2(1000);
      xto            contactos.tvalcon%TYPE;   --       xto            VARCHAR2(1000); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xasunto        VARCHAR2(1000);
      xmessage       VARCHAR2(4000);
      reg_seg        seguros%ROWTYPE;
      v_norden       asegurados.norden%TYPE;   --       v_norden       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vpasexec       NUMBER := 0;
   BEGIN
      vpasexec := 1;

      /*
      {obtenemos los datos de la poliza}
      */
      BEGIN
         SELECT *
           INTO reg_seg
           FROM seguros
          WHERE sseguro = psseguro;
      END;

      vpasexec := 2;

      /*
      {busqueda de recibos pendientes}
      */
      FOR c IN recibos_pendientes LOOP
         rec_pend(nrec_pend).nrecibo := c.nrecibo;
         rec_pend(nrec_pend).fmovini := c.fmovini;
         rec_pend(nrec_pend).fvencim := NULL;
         rec_pend(nrec_pend).fefecto := c.fefecto;
         nrec_pend := nrec_pend + 1;
      END LOOP;

      IF nrec_pend > 0 THEN
         nrec_pend := 1;
      END IF;

      vpasexec := 3;

      /*
      {anulamos recibos, si existen pdtes}
      */
      IF nrec_pend = 1
         AND(pccausin = 4
             OR pccausin = 3) THEN   -- rescate total
         vpasexec := 4;
         num_err := pac_anulacion.f_baja_rec_pend(f_sysdate, rec_pend);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      vpasexec := 5;

      /*
      {Creamos el siniestro asociado a la demanda de rescate}
      */
      IF f_vivo_o_muerto(psseguro, 2, TRUNC(pfecha)) > 0 THEN   -- hay algún asegurado fallecido
         BEGIN
            SELECT norden
              INTO v_norden
              FROM asegurados
             WHERE sseguro = psseguro
               AND ffecmue IS NULL
               AND ffecfin IS NULL;   -- BUG11183:DRA:23/09/2009
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 120007;   -- error al leer de ASEGURADOS
         END;
      ELSE
         v_norden := 1;
      END IF;

      vpasexec := 6;

      DELETE FROM tmp_primas_consumidas
            WHERE sseguro = psseguro;

      vpasexec := 7;
      num_err := f_gest_siniestro(psseguro, v_norden, TRUNC(pfecha), pccausin, pcidioma,
                                  pimport, pipenali, pirendi, pireten, pireduc, pnivel,
                                  xnsinies);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      vpasexec := 8;

      /*
      Actualización de las primas consumidas, reservandolas
      */
      BEGIN
         INSERT INTO primas_consumidas
                     (sseguro, nnumlin, nriesgo, norden, ipricons, ircm, fecha, frescat,
                      cestado)
            SELECT sseguro, nnumlin, nriesgo, norden, ipricons, ircm, fecha, frescat, 1
              FROM tmp_primas_consumidas
             WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'f_sol_rescate', vpasexec,
                        'Error al reservar las primas consumidas', SQLERRM);
            RETURN 152110;   --{Error al reservar les primes consumides}
      END;

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_sol_rescate_total', vpasexec,
                     'Error no controlado', SQLERRM);
         RETURN 140999;   --{Error no controlado}
   END f_sol_rescate;

   FUNCTION f_es_rescatable(
      psseguro IN NUMBER,
      pfmovimi IN DATE,
      pccausin IN NUMBER,
      pirescate IN NUMBER)
      RETURN NUMBER IS
      /*
      {Función que nos indica si le podemos realizar rescates a una poliza
       = 0 .- Si se le pueden hacer más rescates
       <>0 .- No se le puede hacer rescates a las polizas.}
      */
      reg_seg        seguros%ROWTYPE;
      xanys          tmp_primas_consumidas.nanys%TYPE;   --       xanys          NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xiniran        NUMBER;
      xfinran        NUMBER;
      xmaxano        NUMBER;
      ximaximo       NUMBER;
      ximinimo       NUMBER;
      xnrescat       NUMBER;
      xcmovimi       prodcaumotsin.cmovimi%TYPE;   --       xcmovimi       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_fecha        DATE;
      v_frevant      seguros_aho.frevant%TYPE;   --       v_frevant      DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      -- RSC 18/03/2008
      xtmaxano       NUMBER;
      vimaximo       NUMBER;
      num_err        NUMBER;
      vpasexec       NUMBER := 0;
   BEGIN
      vpasexec := 1;

      /*
      {obtenesmos los datos de la poiza}
      */
      BEGIN
         SELECT *
           INTO reg_seg
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'f_es_rescatable.seguros', vpasexec,
                        'Error no controlado', SQLERRM);
            RETURN 101903;   --{Seguro no encontrado en la tabla seguros}
      END;

      vpasexec := 2;

      IF NVL(f_parproductos_v(reg_seg.sproduc, 'EVOLUPROVMATSEG'), 0) = 1 THEN
         BEGIN
            SELECT frevant
              INTO v_frevant
              FROM seguros_aho
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'f_es_rescatable.seguros_aho', vpasexec,
                           'Error no controlado', SQLERRM);
               RETURN 101903;   --{Seguro no encontrado en la tabla seguros}
         END;

         v_fecha := NVL(v_frevant, reg_seg.fefecto);
      ELSE
         v_fecha := reg_seg.fefecto;
      END IF;

      vpasexec := 3;
      xanys := MONTHS_BETWEEN(pfmovimi, v_fecha) / 12;
      -- CPM 23/12/05: Se redondea con 3 decimales para coger el + un día.
      --  Se tiene en cuenta que el la codificación de ctipmov en PRODTRARESC es
      -- diferente a la codificación de ccausin:
      -- ccausin = 4 (rescate total) ctipmov = 3
      -- ccausin = 5 (rescate parcial) ctipmov = 2
      vpasexec := 4;

      BEGIN
         SELECT niniran, nfinran, nmaxano, imaximo, iminimo, tmaxano
           INTO xiniran, xfinran, xmaxano, ximaximo, ximinimo, xtmaxano
           FROM detprodtraresc d, prodtraresc p
          WHERE d.sidresc = p.sidresc
            AND p.sproduc = reg_seg.sproduc
            AND p.ctipmov = DECODE(pccausin, 4, 3, 5, 2, pccausin)
            -- Bug 14802 - JRH - 01/06/2010 - JRH - Error validación rescates
            AND p.finicio <= pfmovimi   -- pfmovimi en lugar de fecefecto
            AND((p.ffin > pfmovimi
                 -- Fi Bug 14802 - JRH - 01/06/2010
                 AND p.ffin IS NOT NULL)
                OR(p.ffin IS NULL))
            AND d.niniran = (SELECT MIN(dp.niniran)
                               FROM detprodtraresc dp
                              WHERE dp.sidresc = d.sidresc
                                AND ROUND(xanys, 3) BETWEEN dp.niniran AND dp.nfinran);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 152065;
      --{No se ha encontrado parametrización para este rescate}
      END;

      vpasexec := 5;

      IF pccausin = 5 THEN
         IF pirescate < NVL(ximinimo, pirescate) THEN
            --{El importe no se encuentra entre los máximos y mínimos para hacer un rescate}
            RETURN 152066;
         END IF;

         vpasexec := 6;
         num_err := pk_cal_sini.f_imaximo_rescatep(psseguro, pfmovimi, 5, vimaximo);

         IF num_err <> 0 THEN
            RETURN 180809;
         END IF;

         vpasexec := 7;

         IF NVL(vimaximo, ximinimo) < ximinimo THEN   -- El valor máximo de rescate es menor que el doble del valor mínimo
            RETURN 180810;   --Provisión matemática inferior al máximo necesario para solicitar rescate parcial.
         END IF;

         vpasexec := 8;

         -- El importe de la provisión matemática, después del rescate,
         -- no podrá ser inferior a 6.000 (ximinimo).
         IF pirescate > NVL(vimaximo, pirescate) THEN
            RETURN 152066;
         END IF;

         xcmovimi := 33;   --{Rescate parcial}
         vpasexec := 9;

         IF xtmaxano = 1 THEN
            vpasexec := 10;

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
            vpasexec := 11;

            BEGIN
               SELECT COUNT(1)
                 INTO xnrescat
                 FROM ctaseguro c, siniestros sini
                WHERE c.nsinies = sini.nsinies
                  AND c.sseguro = psseguro
                  AND c.cmovimi = xcmovimi
                  AND sini.cestsin NOT IN(2, 3)   -- 2= Anulado, 3 = Rechazado
                  AND c.fvalmov BETWEEN ADD_MONTHS(reg_seg.fefecto, xiniran * 12)
                                    AND ADD_MONTHS(reg_seg.fefecto, xfinran * 12);
            END;
         END IF;

         IF xnrescat >= xmaxano THEN
            RETURN 109548;   -- Ha superado el maximo de rescates permitidos
         END IF;
      ELSE   -- Rescate total
         vpasexec := 12;

         IF pirescate < NVL(ximinimo, pirescate)
            OR pirescate > NVL(ximaximo, pirescate) THEN
            RETURN 152066;
         --{El importe no se encuentra entre los máximos y mínimos para hacer un rescate}
         END IF;

         xcmovimi := 34;   --{Rescate total}
         vpasexec := 13;

         BEGIN
            SELECT COUNT(1)
              INTO xnrescat
              FROM ctaseguro c, siniestros sini
             WHERE c.nsinies = sini.nsinies
               AND c.sseguro = psseguro
               AND c.cmovimi = xcmovimi
               AND sini.cestsin NOT IN(2, 3)   -- 2= Anulado, 3 = Rechazado
               AND c.fvalmov BETWEEN ADD_MONTHS(reg_seg.fefecto, xiniran * 12)
                                 AND ADD_MONTHS(reg_seg.fefecto, xfinran * 12);
         END;

         IF xnrescat >= xmaxano THEN
            RETURN 109548;   -- Ha superado el maximo de rescates permitidos
         END IF;
      END IF;

      RETURN 0;   --Si se le pueden hacer nuevos rescates
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rescate.f_es_rescatable', vpasexec,
                     'WHEN OTHERS', SQLERRM);
         RETURN 180714;
   END f_es_rescatable;

   FUNCTION f_sit_rescate(psseguro IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER IS
       /*
      {Función que nos devulve el estado de  una poliza
        0.- Pendiente
       1.- Realizado
       2.- Denegado
       3.- Transferido
       4.- Error
       }
      */
      xresulta       NUMBER;
      xmaxmov        NUMBER;
      xcmovseg       movseguro.cmovseg%TYPE;   --       xcmovseg       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xcmotmov       movseguro.cmotmov%TYPE;   --       xcmotmov       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
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

      --{Si es el último movimiento , es porque aún ni se ha Realizado, ni Transferido}
      IF xmaxmov = pnmovimi THEN
         --{Miramos el tipo de movimiento Pendiente, si es suplemento}
         IF xcmovseg = 10 THEN
            xresulta := 0;   --{aun no se ha tratado}
         ELSIF xcmovseg = 52 THEN
            xresulta := 2;   --{se ha rechazado el motivo}
         ELSE
            xresulta := 4;   --{No deberia pasar por aquí}
         END IF;
      ELSE
         xresulta := 1;
      --{De momento ponemos realizado para los transferidos y los aceptados}
      END IF;

      RETURN xresulta;
   END f_sit_rescate;

   FUNCTION f_rescate_total_abierto(psseguro IN NUMBER, pabierto IN OUT NUMBER)
      RETURN NUMBER IS
      /*
         {Función que nos muestra si una póliza tiene una solicitud de rescate abierta
           Si pabierto = 0.- Sin rescate total abierto.
                  1.- Rescate total abierto.
          Retorna 0.- Sin errores.
                 <> 0.- Algún error.
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
        FROM siniestros s
       WHERE s.sseguro = psseguro
         AND s.ccausin = 4   -- Siniestro por rescate total
         AND s.cestsin = 0;   -- Estado siniestro = 'Abierto'

      RETURN numerr;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, 'pac_rescates.f_rescate_total_abierto', 0,
                     'sseguro=' || psseguro, 'Error en el paso de parámetros.');
         numerr := 107839;
         RETURN(numerr);
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rescates.f_rescate_total_abierto', 1,
                     'sseguro=' || psseguro, SQLERRM);
         numerr := 105144;
         RETURN(numerr);
   END f_rescate_total_abierto;

   /*************************************************************************
      Función destinada al cálculo de la retención, rcm, reducción y conpensaciones
      fiscales, etc. y configurar los valores de la tabla PRIMAS_CONSUMIDAS a la hora
      de solicitar un rescate.

      param in psesion  : Identificador de sesion
      param in psseguro : Identificador de seguro
      param in pnriesgo : Identificador de riesgo
      param in pcgarant : Identificador de garantía
      param in pfefecto : Fecha efecto
      param in pfrescat : Fecha de rescate
      param in pctipres : Tipo de rescate
      param in pirescate: Importe de rescate
      param in pipenali : Importe de penalización
      param in pmoneda  : Moneda
      param out pireten : Importe de retención
      param out pireduc : Importe de reducción
      param out pirendi : Rendimiento
      return            : NUMBER
   *************************************************************************/
   FUNCTION f_retencion_simulada(
      psesion IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pfefecto IN DATE,   -- fecha de efecto (día que se hace)
      pfrescat IN DATE,   -- fecha de rescate
      pctipres IN NUMBER,   -- tipo de rescate 31-vencimiento, 33-rescate parcial, 34.- rescate total
      pirescate IN NUMBER,   -- importe de rescate (icapris
      pipenali IN NUMBER,   -- importe de penalización
      pmoneda IN NUMBER,
      pireten OUT NUMBER,   -- importe de retención
      pireduc OUT NUMBER,   -- importe de reducción
      pirendi OUT NUMBER)   -- RCM
      RETURN NUMBER IS
      r              NUMBER;   -- Rendimiento total antes de reducciones
      rt             tmp_primas_consumidas.ircm%TYPE;   --       rt             NUMBER;   -- Rendimiento asociado a la prima --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      rtr            NUMBER;   -- Rendimiento reducido
      rtra           NUMBER;   -- Rendimiento reducido por antigüedad
      xircm          NUMBER;
      sumrt          NUMBER;   -- Sumatorio de rendimientos antes de reducciones
      sumpa          NUMBER;   -- Sumatorio de prestaciones pagadas
      sumra          NUMBER;   -- Sumatorio de rendimientos asociados a prestaciones
      rbruto         NUMBER;   -- Suma de rendimientos reducidos
      red            NUMBER;   -- Porcentaje de reducción
      red_aux        NUMBER;   -- Porcentaje de reducción con el antiguo IRPF
                               -- Se graba pero no reduce el valor del rescate
      ret            NUMBER;   -- Porcentaje de retención
      ireduc         NUMBER;   -- importe de reducción
      xncoef_regtrans tmp_primas_consumidas.ncoef_regtrans%TYPE;   --       xncoef_regtrans NUMBER;   -- coeficiente a aplicar a rt para obtener el rcm --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      -- base al cual se aplicará el % de reduc. trans.
      w_ibrut_regtrans tmp_primas_consumidas.ibrut_regtrans%TYPE;   --       w_ibrut_regtrans NUMBER;   -- importe bruto RCM al cual se aplica el % de reduc. Trans. --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      rtr_regtrans   tmp_primas_consumidas.ircm_neto%TYPE;   --       rtr_regtrans   NUMBER;   -- RCM reducido después de reg. trans --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      sumireduc      NUMBER;   --SUMATORIO DE REDUCCIONES
      xrcmneto       NUMBER;   -- RCM NETO
      w_ireg_trans_aux tmp_primas_consumidas.ireg_transcomp%TYPE;   --       w_ireg_trans_aux NUMBER;   -- importe red. trans. con irpf anteriror a 2007 --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_ircm_netocomp tmp_primas_consumidas.ircm_netocomp%TYPE;   --       w_ircm_netocomp NUMBER;   -- RCM NETO con irpf anterior a 2007 --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      resto          tmp_primas_consumidas.ipricons%TYPE;   --       resto          NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      primasaportadas NUMBER;
      rescate_pend   NUMBER := 0;
      rescate_acum   NUMBER;
      sumprim        NUMBER;
      kat            NUMBER;
      sumatoriobruto NUMBER;
      sumatoriobruto_1 NUMBER;
      sumando        NUMBER;
      sumarentas     NUMBER;
      xcactivi       seguros.cactivi%TYPE;   --       xcactivi       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xsproduc       seguros.sproduc%TYPE;   --       xsproduc       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xfefecto       seguros.fefecto%TYPE;   --       xfefecto       DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xcumple        NUMBER;
      xsumpri        NUMBER;
      xsumppa        NUMBER;
      xanys          tmp_primas_consumidas.nanys%TYPE;   --       xanys          NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xerror         NUMBER;
      xcuantos       NUMBER := 0;
      xcoef          tmp_primas_consumidas.ncoefic%TYPE := 0;   --       xcoef          NUMBER := 0; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
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
      w_preg_trans   tmp_primas_consumidas.preg_trans%TYPE;   --       w_preg_trans   NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      w_ireg_trans   tmp_primas_consumidas.ireg_trans%TYPE;   --       w_ireg_trans   NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vpais          personas.cpais%TYPE;   --       vpais          NUMBER(3); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xfmuerte       asegurados.ffecmue%TYPE;   --       xfmuerte       DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xmuerto        NUMBER;
      xsperson       asegurados.sperson%TYPE;   --       xsperson       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
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
              AND ffecfin IS NULL   -- BUG11183:DRA:23/09/2009
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

      IF f_vivo_o_muerto(psseguro, 2, pfrescat) > 0
         AND f_vivo_o_muerto(psseguro, 1, pfrescat) > 0 THEN
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
      xcuantos := f_vivo_o_muerto(psseguro, 1, pfrescat);
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

      -- Cuenta cuantos rescate PARCIALES lleva esta póliza en el año.
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
               xcumple := 2;   -- Se le aplicara deducción 0
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

      -- Averigüo si se aplicara una deducción de coeficientes parametrizada o la máxima, siempre
      -- y cuando no sobrepase el limite de 3 rescates parciales que será una deducción 0.
      IF xcumple = 0 THEN
         IF pctipres IN(31, 33, 34) THEN
            IF pfrescat >= TO_DATE('01/01/2003', 'dd/mm/yyyy') THEN
               IF xfefecto > TO_DATE('31/12/1994', 'dd/mm/yyyy') THEN
                  IF CEIL((pfrescat - xfefecto) / 365) > 8 THEN
                     xsumppa := 0;
                     xsumpri := 0;
                     vpasexec := 14;

                     FOR r IN (SELECT (CASE
                                          WHEN fvalmov > NVL(xfmuerte, fvalmov) THEN iprima
                                          ELSE ROUND(iprima
                                                     / f_vivo_o_muerto(psseguro, 1, fvalmov),
                                                     5)
                                       END)
                                      - prima_consumida(psseguro, nnumlin, f_sysdate,
                                                        (CASE
                                                            WHEN fvalmov >
                                                                         NVL(xfmuerte, fvalmov) THEN NULL
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

      -- Cálculo del denominador para la determinación del rendimiento a nivel prima
      FOR r IN (SELECT (CASE
                           WHEN fvalmov > NVL(xfmuerte, fvalmov) THEN iprima
                           ELSE ROUND(iprima / f_vivo_o_muerto(psseguro, 1, fvalmov), 5)
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
      --Cálculo de PrimasAportadas
      -- RSC 25/03/2008 En primas aportadas ponemos las aportadas menos las consumidas
      w_error := pk_cal_sini.graba_param(psesion, 'IPRIMAS', primasaportadas);
      -- Las consumidas las restaremos al calcular r (RCM bruto) una pocas lineas mas abajo
      -- Bug 11227 - APD - 25/09/2009 - no es necesario sumar las primasconsum ya que después
      -- al calcular r las vuelve a restar con las variables sumpa y sumra
      -- así que si no se suman aquí no se deben restar abajo
      --primasaportadas := primasaportadas + primasconsum;
      -- Fin Bug 11227 - APD - 25/09/2009

      -- RSC para el cálculo del RCM no descontamos las counsumidas ya lo hacemos al dar valor a variable r (primasaportadas - sumpa)
      /*
      SELECT nvl(SUM (case WHEN fvalmov > nvl(xfmuerte,fvalmov)THEN iprima else round(iprima/f_vivo_o_muerto(psseguro,1,fvalmov),5) end),0)
        INTO primasaportadas
        FROM primas_aportadas
       WHERE sseguro = psseguro
         AND fvalmov <= pfrescat;
      */
      vpasexec := 19;

      --w_error := pk_cal_sini.graba_param (psesion, 'IPRIMAS', primasaportadas);
      BEGIN
         --Cálculo de Rentas
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
      -- la penalización se restarán directamente de los rendimientos
      IF pctipres = 33 THEN
         -- Bug 11227 - APD - 25/09/2009 - se sustituye xirescate por
         -- round(calc_rescates.FvalrescTotAho(psesion, psseguro, to_number(to_char(pfrescat,'yyyymmdd')))/xcuantos,5)
         -- Además, no es necesario restar la variables sumpa y sumra (primas consumidas)
         -- ya que realmente la variable primasaportadas son las primas aportadas menos las primas consumidas
         -- si se restan las variables sumpa y sumra estariamos restando 2 veces las primas consumidas
         --r := GREATEST(round(calc_rescates.FvalrescTotAho(psesion, psseguro, to_number(to_char(pfrescat,'yyyymmdd')))/xcuantos,5) - xipenali - (primasaportadas - sumpa) - sumra, 0);
         vpasexec := 21;
         -- Bug 13296 - 22/02/2010 - AMC
         r :=
            GREATEST(ROUND(calc_rescates.fvalresctotaho(psesion, psseguro,
                                                        TO_NUMBER(TO_CHAR(pfrescat,
                                                                          'yyyymmdd')))
                           / xcuantos,
                           5)
                     - primasaportadas,
                     0);
      -- Fi Bug 13296 - 22/02/2010 - AMC

      -- Fin Bug 11227 - APD - 25/09/2009
      ELSE
         -- Bug 11227 - APD - 25/09/2009 - no es necesario restar la variables sumpa y sumra (primas consumidas)
         -- ya que realmente la variable primasaportadas son las primas aportadas menos las primas consumidas
         -- si se restan las variables sumpa y sumra estariamos restando 2 veces las primas consumidas
         --r := xirescate - xipenali - (primasaportadas - sumpa) - sumra;
         vpasexec := 22;
         -- Bug 13296 - 22/02/2010 - AMC
         r := xirescate - primasaportadas;
      -- Fi Bug 13296 - 22/02/2010 - AMC

      -- Fin Bug 11227 - APD - 25/09/2009
      END IF;

      sumrt := 0;
      rbruto := 0;
      rescate_acum := 0;
      rtra := 0;
      xircm := 0;
      sumireduc := 0;
      sumresto := 0;   -- Bug 11227 - APD - 25/09/2009 - se inicializa la variable sumresto
      vpasexec := 23;

      -- Cálculo del rendimiento antes de reducciones a nivel de prima
      -- movimiento_ult := 0;
      FOR p IN (SELECT   sseguro, nnumlin, fvalmov, cmovimi,
                         (CASE
                             WHEN fvalmov > NVL(xfmuerte, fvalmov) THEN iprima
                             ELSE ROUND(iprima / f_vivo_o_muerto(psseguro, 1, fvalmov), 5)
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

         vpasexec := 26;
         -- Bug 13296 - 22/02/2010 - AMC
         rt := rt - xipenali;
         -- Fi Bug 13296 - 22/02/2010 - AMC
         rescate_acum := rescate_acum +(p.imovimi + rt);
         rescate_pend := xirescate - rescate_acum;
         resto := ROUND(p.imovimi * kat, 5);
         vpasexec := 27;

         IF p.imovimi > 0 THEN
            IF resto <> 0
               OR rt <> 0 THEN
               -- Grabación de la prima consumida
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
                     p_tab_error(f_sysdate, f_user, 'pac_rescate.f_retencion_simulada',
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
            SELECT p.cpais, a.sperson
              INTO vpais, xsperson
              FROM personas p, asegurados a
             WHERE p.sperson = a.sperson
               AND a.sseguro = psseguro
               AND a.norden = pnriesgo;
         EXCEPTION
            WHEN OTHERS THEN
               vpais := NVL(f_parinstalacion_n('PAIS_DEF'), 42);
         END;

         vpasexec := 32;

         IF vpais <> NVL(f_parinstalacion_n('PAIS_DEF'), 42) THEN
            xcumple := 3;   -- si es extranjero no se le aplica reducción
         END IF;

         vpasexec := 33;

         IF xcumple IN(0, 1) THEN
            red := NULL;

            -- Aplicamos el nuevo IRPF
            IF p.fvalmov >= TO_DATE('01/01/2007', 'dd/mm/yyyy')
               AND p.cmovimi = 1 THEN
               vpasexec := 34;
               -- Es una aportación extraordinaria con el nuevo IRPF
               red_aux := fbuscapreduc(1, xsproduc, xcactivi, pcgarant,
                                       TO_NUMBER(TO_CHAR(p.fvalmov, 'yyyymmdd')), xanys);
            ELSE
               vpasexec := 35;

               -- Bug 9589 - 27/03/2009 - RSC - Incidencia en el cálculo de compensación fiscal en rescates
               -- Entre 20/01/2006 y 31/12/2006 no existe compensación
               IF p.fvalmov < TO_DATE('20/01/2006', 'dd/mm/yyyy') THEN
                  red_aux := fbuscapreduc(1, xsproduc, xcactivi, pcgarant,
                                          TO_NUMBER(TO_CHAR(xfefecto, 'yyyymmdd')), xanys);
               ELSE
                  red_aux := 0;
               END IF;
            -- Fin Bug 9589 - 27/03/2009 - RSC - Incidencia en el cálculo de compensación fiscal en rescates
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

         -- Reducción adicional (primas anteriores a 31/12/1994)
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
            w_ireg_trans_aux := rt *(1 -(red_aux / 100)) * w_preg_trans;   -- para calcular compensación
         ELSE
            w_preg_trans := 0;
            w_ireg_trans := 0;
            xncoef_regtrans := 0;
            w_ibrut_regtrans := 0;
            w_ireg_trans_aux := 0;
         END IF;

         vpasexec := 45;

         IF p.fvalmov < TO_DATE('20/01/2006', 'dd/mm/yyyy') THEN
            --disposición transitoria decimotercera
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

      vpasexec := 49;

      -- Bug 11227 - APD - 25/09/2009 - se actualiza IPRIMAS con el total de primas consumidas
      IF sumresto IS NOT NULL THEN
         w_error := pk_cal_sini.graba_param(psesion, 'IPRIMAS', sumresto);
      END IF;

      -- Fin Bug 11227 - APD - 25/09/2009 - se actualiza IPRIMAS con el total de primas consumidas
      vpasexec := 50;
      --{Si es rescate total}
      xrcmneto := ROUND(sumrt, 5) - ROUND(sumireduc, 2);
      --xreducida := ROUND (sumrt, 2);
      --xredbruta := ROUND (xircm, 2);
      --xredreduc := ROUND (rtra, 2);
      vpasexec := 51;
      --****** Buscamos el % de retención
      ret := fbuscapreten(1, xsperson, xsproduc, TO_NUMBER(TO_CHAR(pfrescat, 'YYYYMMDD')));

      IF ret IS NULL THEN
         ret := 0;
      END IF;

      vpasexec := 52;
      xretenparcial := 0;
      xretenparcial := ROUND((xrcmneto * ret) / 100, 2);
      -- En el caso de que el rendimiento sea negativo se devolverá 0.
      -- Bug 13296 - 22/02/2010 - AMC
      pireten := GREATEST(xretenparcial, 0);
      pireduc := GREATEST(ROUND(sumireduc, 2), 0);
      pirendi := GREATEST(ROUND(sumrt, 2), 0);   --sumrt;
      --Fi Bug 13296 - 22/02/2010 - AMC
      vpasexec := 53;
      w_error := pk_cal_sini.graba_param(psesion, 'IRESRED', pireduc);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rescate.f_retencion_simulada', vpasexec,
                     'error no controlado', SQLERRM);
         RETURN 140999;   --{Error no controlat}
   END f_retencion_simulada;

   FUNCTION f_finaliza_rescate(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnsinies IN NUMBER,
      pmoneda IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;
      xnnumlin       NUMBER;
      xnnumlinshw    NUMBER;
      xcmovimi       prodcaumotsin.cmovimi%TYPE;   --       xcmovimi       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xcmotmov       movseguro.cmotmov%TYPE := 511;   --       xcmotmov       NUMBER := 511; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xpagoini       valorasini%ROWTYPE;
      xsinies        siniestros%ROWTYPE;
      reg_seg        seguros%ROWTYPE;
      rec_pend       pac_anulacion.recibos_pend;
      rec_cob        pac_anulacion.recibos_cob;
      fcuenta        siniestros.fsinies%TYPE;   --       fcuenta        DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      ntraza         NUMBER;
      xivalora       valorasini.ivalora%TYPE;   --       xivalora       NUMBER(13, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      -- RSC 13/12/2007
      seqgrupo       ctaseguro.cmovanu%TYPE;   --       seqgrupo       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      -- Variables para Ibex 35 Garantizado (PRODUCTO_MIXTO)
      vresceur       NUMBER;
      vrescibex      NUMBER;
      -- RSC 07/11/2008 -----
      vsaldof        NUMBER;
      vfsaldo        DATE;
      vclaveiprovac  NUMBER;
      vprovacibex    NUMBER;
      perror         NUMBER;
      -- Bug XXX - RSC - 25/11/2009 - Ajustes PPJ Dinámico / Pla Estudiant
      v_icaprisc     valorasini.icaprisc%TYPE;   --       v_icaprisc     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      -- Fin Bug XXX
      vtieneshw      NUMBER;
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
      vtieneshw := pac_ctaseguro.f_tiene_ctashadow(psseguro, NULL);

      --{Insertamos el movimiento en la libreta ctaseguro}
        --{obtenemos el numero de linea de ctaseguro}
      BEGIN
         SELECT MAX(nnumlin) + 1
           INTO xnnumlin
           FROM ctaseguro
          WHERE sseguro = psseguro;
      END;

      ntraza := 4;

      IF vtieneshw = 1 THEN
         SELECT MAX(nnumlin) + 1
           INTO xnnumlinshw
           FROM ctaseguro_shadow
          WHERE sseguro = psseguro;
      END IF;

      ntraza := 5;

      -- Buscamos el tipo de movimiento
      BEGIN
         SELECT p.cmovimi, i.fsinies, v.ivalora, v.icaprisc
           INTO xcmovimi, fcuenta, xivalora, v_icaprisc
           FROM siniestros i, seguros s, prodcaumotsin p, valorasini v
          WHERE p.ccausin = i.ccausin
            AND p.cmotsin = i.cmotsin
            AND s.sseguro = i.sseguro
            AND s.sproduc = p.sproduc
            AND i.nsinies = pnsinies
            AND v.cgarant = p.cgarant
            AND p.cmovimi IS NOT NULL
            AND v.nsinies = i.nsinies
            AND fvalora = (SELECT MAX(fvalora)
                             FROM valorasini
                            WHERE nsinies = pnsinies
                              AND cgarant <> 9998);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            xcmovimi := NULL;
         WHEN OTHERS THEN
            ntraza := 6;
            p_tab_error(f_sysdate, f_user, 'pac_rescates.f_finaliza_rescate', ntraza,
                        'Error no controlado', SQLERRM);
            RETURN 140999;   -- Error no controlado
/*
            --{obtenemos la información del siniestro}
            BEGIN
               SELECT *
                 INTO xsinies
                 FROM siniestros
                WHERE nsinies = pnsinies;
            END;

            IF xsinies.ccausin = 4 THEN     --Total
               xcmovimi := 34;
            ELSIF xsinies.ccausin = 5 THEN  -- rescate parcial
               xcmovimi := 33;
            ELSIF xsinies.ccausin = 3 THEN  -- vencimiento
               xcmovimi := 31;
            ELSIF xsinies.ccausin = 1 THEN  -- fallecimiento
               xcmovimi := 31;
            ELSE
               xcmovimi := 47;  -- traspaso de salida
            END IF;

            fcuenta := xsinies.fsinies;
*/
      END;

      ntraza := 7;

      SELECT scagrcta.NEXTVAL
        INTO seqgrupo
        FROM DUAL;

      -- Generamos los movimientos de detalle en caso de producto Unit Linked
      IF NVL(f_parproductos_v(reg_seg.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
         IF NVL(f_parproductos_v(reg_seg.sproduc, 'PRODUCTO_MIXTO'), 0) <> 1 THEN
            ntraza := 8;
            num_err := pac_ctaseguro.f_insctaseguro(psseguro, f_sysdate, xnnumlin, fcuenta,
                                                    fcuenta, xcmovimi, v_icaprisc, 0, NULL,
                                                    seqgrupo, 0, pnsinies, NULL, NULL);
            xnnumlin := xnnumlin + 1;

            IF num_err <> 0 THEN
               RETURN 102555;
            END IF;

            ntraza := 9;
            num_err := f_distribuye_ctaseguro(psseguro, xnnumlin, fcuenta, xcmovimi,
                                              v_icaprisc, seqgrupo, pnsinies);

            IF num_err <> 0 THEN
               RETURN 102555;
            END IF;

            IF vtieneshw = 1 THEN
               num_err := pac_ctaseguro.f_insctaseguro_shw(psseguro, f_sysdate, xnnumlinshw,
                                                           fcuenta, fcuenta, xcmovimi,
                                                           v_icaprisc, 0, NULL, seqgrupo, 0,
                                                           pnsinies, NULL, NULL);
               xnnumlinshw := xnnumlinshw + 1;

               IF num_err <> 0 THEN
                  RETURN 102555;
               END IF;

               ntraza := 9;
               num_err := f_distribuye_ctaseguro_shw(psseguro, xnnumlinshw, fcuenta, xcmovimi,
                                                     v_icaprisc, seqgrupo, pnsinies);

               IF num_err <> 0 THEN
                  RETURN 102555;
               END IF;
            END IF;
         ELSE   -- Ibex 35 Garantizado
            ntraza := 10;
            -- RSC 14/12/2007
            -- Obtencion de la parte de rescate a EUROPLAZO y la parte de rescate a Ibex 35
            vsaldof := ROUND(fbuscasaldo(NULL, psseguro, TO_CHAR(fcuenta, 'yyyymmdd')), 2);   -- Aqui tenemos Europlzao + Ibex 35
            ntraza := 11;
            vfsaldo := f_fechasaldo(psseguro, fcuenta);
            ntraza := 12;

            SELECT clave
              INTO vclaveiprovac
              FROM garanformula
             WHERE cramo = reg_seg.cramo
               AND ccampo = 'IPROVAC'
               AND cgarant = 48;

            ntraza := 13;
            perror := pac_calculo_formulas.calc_formul(vfsaldo, reg_seg.sproduc, 0, 48, 1,
                                                       psseguro, vclaveiprovac, vprovacibex,
                                                       NULL, NULL, 2, vfsaldo, 'R');
            -- Parte Europlazo del rescate
            vresceur := vsaldof - vprovacibex;   -- Descontamos la parte de Ibex 35 a fecha de ultimo saldo
            vprovacibex := 0;
            ntraza := 14;
            perror := pac_calculo_formulas.calc_formul(fcuenta, reg_seg.sproduc, 0, 48, 1,
                                                       psseguro, vclaveiprovac, vrescibex,
                                                       NULL, NULL, 2, fcuenta, 'R');
            /*
            SELECT xivalora*crespue / PAC_OPERATIVA_ULK.ff_primas_satisfechas (psseguro,NULL,NULL) INTO vresceur
            FROM pregunseg
            WHERE sseguro = psseguro
              AND cpregun = 1012
              AND nmovimi = (SELECT max(nmovimi)
                             FROM pregunseg
                             WHERE sseguro = psseguro
                               AND cpregun = 1012);

            SELECT xivalora*crespue / PAC_OPERATIVA_ULK.ff_primas_satisfechas (psseguro,NULL,NULL) INTO vrescibex
            FROM pregunseg
            WHERE sseguro = psseguro
              AND cpregun = 1013
              AND nmovimi = (SELECT max(nmovimi)
                             FROM pregunseg
                             WHERE sseguro = psseguro
                               AND cpregun = 1013);
            */
            ntraza := 15;
            -- Europlazo ----------
            num_err := pac_ctaseguro.f_insctaseguro(psseguro, f_sysdate, xnnumlin, fcuenta,
                                                    fcuenta, xcmovimi, vresceur, 0, NULL,
                                                    seqgrupo, 0, pnsinies, NULL, NULL);
            xnnumlin := xnnumlin + 1;

            IF num_err <> 0 THEN
               RETURN 102555;
            END IF;

            IF vtieneshw = 1 THEN
               num_err := pac_ctaseguro.f_insctaseguro_shw(psseguro, f_sysdate, xnnumlinshw,
                                                           fcuenta, fcuenta, xcmovimi,
                                                           vresceur, 0, NULL, seqgrupo, 0,
                                                           pnsinies, NULL, NULL);
               xnnumlinshw := xnnumlinshw + 1;

               IF num_err <> 0 THEN
                  RETURN 102555;
               END IF;
            END IF;

            ntraza := 16;
            -- Ibex 35 ------------
            num_err := pac_ctaseguro.f_insctaseguro(psseguro, f_sysdate, xnnumlin, fcuenta,
                                                    fcuenta, xcmovimi, vrescibex, 0, NULL,
                                                    seqgrupo, 0, pnsinies, NULL, NULL);
            xnnumlin := xnnumlin + 1;

            IF num_err <> 0 THEN
               RETURN 102555;
            END IF;

            IF vtieneshw = 1 THEN
               num_err := pac_ctaseguro.f_insctaseguro_shw(psseguro, f_sysdate, xnnumlinshw,
                                                           fcuenta, fcuenta, xcmovimi,
                                                           vrescibex, 0, NULL, seqgrupo, 0,
                                                           pnsinies, NULL, NULL);
               xnnumlinshw := xnnumlinshw + 1;

               IF num_err <> 0 THEN
                  RETURN 102555;
               END IF;
            END IF;

            ntraza := 17;
            num_err := f_distribuye_ctaseguro(psseguro, xnnumlin, fcuenta, xcmovimi, vrescibex,
                                              seqgrupo, pnsinies);

            IF num_err <> 0 THEN
               RETURN 102555;
            END IF;

            IF vtieneshw = 1 THEN
               num_err := f_distribuye_ctaseguro_shw(psseguro, xnnumlinshw, fcuenta, xcmovimi,
                                                     vrescibex, seqgrupo, pnsinies);

               IF num_err <> 0 THEN
                  RETURN 102555;
               END IF;
            END IF;
         END IF;
      ELSE   -- Ahorro, etc
         --{insertamos el registro del importe pagado}
         -- En comptes de fer l'insert directament sobre CTASEGURO, utilitzem la funció
         -- PAC_CTASEGURO.f_insctaseguro per què realitzi tant l'apunt al compte, com també l'apunt del
         -- rescat a la llibreta.
         ntraza := 18;

         IF xcmovimi IS NOT NULL THEN
            ntraza := 19;
            num_err := pac_ctaseguro.f_insctaseguro(psseguro, f_sysdate, xnnumlin, fcuenta,
                                                    fcuenta, xcmovimi, xivalora, 0, NULL, 0,
                                                    0, pnsinies, NULL, NULL);
            xnnumlin := xnnumlin + 1;

            IF num_err <> 0 THEN
               RETURN 102555;
            END IF;

            IF vtieneshw = 1 THEN
               num_err := pac_ctaseguro.f_insctaseguro_shw(psseguro, f_sysdate, xnnumlinshw,
                                                           fcuenta, fcuenta, xcmovimi,
                                                           xivalora, 0, NULL, 0, 0, pnsinies,
                                                           NULL, NULL);
               xnnumlinshw := xnnumlinshw + 1;

               IF num_err <> 0 THEN
                  RETURN 102555;
               END IF;
            END IF;

            ntraza := 20;

            IF xcmovimi = 53
               AND NVL(f_parproductos_v(reg_seg.sproduc, 'SALDO_AE'), 0) = 1 THEN
               ntraza := 21;
               num_err := pac_ctaseguro.f_inscta_prov_cap(psseguro, TRUNC(fcuenta), 'R', NULL);

               IF num_err <> 0 THEN
                  RETURN 102555;
               END IF;

               IF vtieneshw = 1 THEN
                  num_err := pac_ctaseguro.f_inscta_prov_cap_shw(psseguro, TRUNC(fcuenta),
                                                                 'R', NULL);

                  IF num_err <> 0 THEN
                     RETURN 102555;
                  END IF;
               END IF;

               ntraza := 22;
               num_err := pac_ctaseguro.f_recalcular_lineas_saldo(psseguro, fcuenta + 1);

               IF num_err <> 0 THEN
                  RETURN 102555;
               END IF;

               IF vtieneshw = 1 THEN
                  num_err := pac_ctaseguro.f_recalcular_lineas_saldo_shw(psseguro,
                                                                         fcuenta + 1);

                  IF num_err <> 0 THEN
                     RETURN 102555;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;

      ntraza := 23;

      -- 7/03/2008: no se graba la línea de penalización
      -- Bug 9276 - 27/02/2009 - APD - Se descomenta el IF de Penalización, ya que ahora sí se quiere que se grabe la linea de penalizacion
      --{insertamos el registro del importe de penalización}
      -- Solo insertamos si ha habido penalización
      IF NVL(xpagoini.ipenali, 0) <> 0 THEN
         ntraza := 24;
         xcmovimi := 27;   --{penalización (Cvalor = 83)}
         num_err := pac_ctaseguro.f_insctaseguro(psseguro, f_sysdate, xnnumlin, fcuenta,
                                                 fcuenta, xcmovimi, NVL(xpagoini.ipenali, 0),
                                                 0, NULL, 0, 0, pnsinies, NULL, NULL);
         xnnumlin := xnnumlin + 1;

         IF num_err <> 0 THEN
            RETURN 102555;
         END IF;

         IF vtieneshw = 1 THEN
            num_err := pac_ctaseguro.f_insctaseguro_shw(psseguro, f_sysdate, xnnumlinshw,
                                                        fcuenta, fcuenta, xcmovimi,
                                                        NVL(xpagoini.ipenali, 0), 0, NULL, 0,
                                                        0, pnsinies, NULL, NULL);
            xnnumlinshw := xnnumlinshw + 1;

            IF num_err <> 0 THEN
               RETURN 102555;
            END IF;
         END IF;

         ntraza := 25;

         -- Generamos los movimientos de detalle en caso de producto Unit Linked
         IF NVL(f_parproductos_v(reg_seg.sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
            ntraza := 26;
            num_err := f_distribuye_ctaseguro(psseguro, xnnumlin, fcuenta, xcmovimi,
                                              NVL(xpagoini.ipenali, 0), seqgrupo, pnsinies);

            IF num_err <> 0 THEN
               RETURN 102555;
            END IF;

            IF vtieneshw = 1 THEN
               num_err := f_distribuye_ctaseguro_shw(psseguro, xnnumlinshw, fcuenta, xcmovimi,
                                                     NVL(xpagoini.ipenali, 0), seqgrupo,
                                                     pnsinies);

               IF num_err <> 0 THEN
                  RETURN 102555;
               END IF;
            END IF;
         END IF;
      END IF;

      -- Si se trata de Ibex 35 o Ibex 35 Garantizado debemos insertar las lineas de CTASEGURO
      -- del siniestro de fallacimiento del primer titular en este caso
      /*
      IF NVL(F_PARPRODUCTOS_V(reg_seg.sproduc,'ES_PRODUCTO_INDEXADO'),0) = 1 THEN
        IF (NVL(F_PARPRODUCTOS_V(vsproduc,'PRODUCTO_MIXTO'),0) = 1 OR
               NVL(F_PARPRODUCTOS_V(vsproduc,'USA_EDAD_CFALLAC'),0) = 1) THEN -- Ibex 35 y Ibex 35 Garantizado

            num_err := PAC_CTASEGURO.f_insctaseguro (psseguro, f_sysdate, xnnumlin, fcuenta, fcuenta,
                                                     xcmovimi, xpagoini.ivalora,0,NULL,seqgrupo,
                                                     0,pnsinies,NULL,NULL);
            xnnumlin := xnnumlin + 1;
            IF num_err <> 0 THEN
                 RETURN 102555;
            END IF;

            num_err := f_distribuye_ctaseguro (psseguro, xnnumlin, fcuenta, xcmovimi, xpagoini.ivalora, seqgrupo, pnsinies);
            IF num_err <> 0 THEN
                 RETURN 102555;
            END IF;
        END IF;
      END IF;
      */

      --{Faltaría enviar mail a la oficina}
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rescates.f_finaliza_rescate', ntraza,
                     'Error no controlado', SQLERRM);
         RETURN 140999;
   END f_finaliza_rescate;

   /*
    RSC 13/12/2007. Función únicamente necesaria para los productos Unit Linked. (Parproducto ES_PRODUCTO_INDEXADO)
   */
   FUNCTION f_distribuye_ctaseguro(
      psseguro IN NUMBER,
      xnnumlin IN OUT NUMBER,
      fcuenta IN DATE,
      pxcmovimi IN NUMBER,
      pivalora IN NUMBER,
      seqgrupo IN NUMBER,
      pnsinies IN NUMBER)
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

      xcdetmovimi    ctaseguro.imovimi%TYPE;   --       xcdetmovimi    NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xidistrib      ctaseguro.imovim2%TYPE;   --       xidistrib      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      -- Bug XXX - RSC - 24/11/2009 - Ajustes PPJ Dinámico / PLA Estudiant
      viuniact       tabvalces.iuniact%TYPE;   --       viuniact       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      -- Fin Bug XXX
         -- BUG 18423 - 09/01/2012 - JMP - Multimoneda
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      v_f_sysdate    ctaseguro.fcontab%TYPE;   --       v_f_sysdate    DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_error        axis_literales.slitera%TYPE;
   -- FIN BUG 18423 - 09/01/2012 - JMP - Multimoneda
   BEGIN
      -- BUG 18423 - 09/01/2012 - JMP - Multimoneda
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);

      -- FIN BUG 18423 - 09/01/2012 - JMP - Multimoneda
      -- Obtenemos el código de detalle de movimiento en CTASEGURO
      IF pxcmovimi = 34 THEN
         xcdetmovimi := 94;   -- Detalle de Rescate Total
      ELSIF pxcmovimi = 33 THEN
         xcdetmovimi := 93;   -- Detalle de Rescate Parcial
      ELSIF pxcmovimi = 31 THEN
         xcdetmovimi := 91;   -- Detalle de Siniestro
      ELSIF pxcmovimi = 27 THEN
         xcdetmovimi := 87;   -- Detalle de Penal. rescate
      ELSE
         xcdetmovimi := 97;   -- Detalle de Traspaso de Salida
      END IF;

      FOR regs IN cur_distribucion LOOP
         --Calcula les distribucions
         xidistrib := (pivalora * regs.pdistrec) / 100;

         -- Bug XXX - RSC - 24/11/2009 - Ajustes PPJ Dinámico / PLA Estudiant
         BEGIN
            SELECT iuniact
              INTO viuniact
              FROM tabvalces
             WHERE ccesta = regs.ccesta
               AND TRUNC(fvalor) = TRUNC(fcuenta);

            --Inserta registres a cuenta seguro.
            BEGIN
               v_f_sysdate := f_sysdate;

               INSERT INTO ctaseguro
                           (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                            cmovimi, imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                            smovrec, cesta, cestado, nunidad,
                            fasign)
                    VALUES (psseguro, v_f_sysdate, NVL(xnnumlin, 1), fcuenta, fcuenta,
                            xcdetmovimi, xidistrib, NULL, NULL, seqgrupo, 0, pnsinies,
                            NULL, regs.ccesta, '2',((xidistrib / viuniact) * -1),
                            TRUNC(f_sysdate));

               -- BUG 18423 - 09/01/2012 - JMP - Multimoneda
               IF v_cmultimon = 1 THEN
                  v_error := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro, v_f_sysdate,
                                                                        NVL(xnnumlin, 1),
                                                                        fcuenta);

                  IF v_error <> 0 THEN
                     RETURN v_error;
                  END IF;
               END IF;

               -- FIN BUG 18423 - 09/01/2012 - JMP - Multimoneda
               xnnumlin := xnnumlin + 1;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  RETURN 104879;   -- Registre duplicat a CTASEGURO
               WHEN OTHERS THEN
                  RETURN 102555;   -- Error al insertar a la taula CTASEGURO
            END;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               --Inserta registres a cuenta seguro.
               BEGIN
                  v_f_sysdate := f_sysdate;

                  INSERT INTO ctaseguro
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                               cmovimi, imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                               smovrec, cesta, cestado)
                       VALUES (psseguro, v_f_sysdate, NVL(xnnumlin, 1), fcuenta, fcuenta,
                               xcdetmovimi, xidistrib, NULL, NULL, seqgrupo, 0, pnsinies,
                               NULL, regs.ccesta, '1');

                  -- BUG 18423 - 09/01/2012 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     v_error := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro,
                                                                           v_f_sysdate,
                                                                           NVL(xnnumlin, 1),
                                                                           fcuenta);

                     IF v_error <> 0 THEN
                        RETURN v_error;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 09/01/2012 - JMP - Multimoneda
                  xnnumlin := xnnumlin + 1;
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     RETURN 104879;   -- Registre duplicat a CTASEGURO
                  WHEN OTHERS THEN
                     RETURN 102555;   -- Error al insertar a la taula CTASEGURO
               END;
         END;
      -- Fin Bug
      END LOOP;

      RETURN 0;
   END f_distribuye_ctaseguro;

   FUNCTION f_distribuye_ctaseguro_shw(
      psseguro IN NUMBER,
      xnnumlin IN OUT NUMBER,
      fcuenta IN DATE,
      pxcmovimi IN NUMBER,
      pivalora IN NUMBER,
      seqgrupo IN NUMBER,
      pnsinies IN NUMBER)
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

      xcdetmovimi    ctaseguro_shadow.imovimi%TYPE;   --       xcdetmovimi    NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xidistrib      ctaseguro_shadow.imovim2%TYPE;   --       xidistrib      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      -- Bug XXX - RSC - 24/11/2009 - Ajustes PPJ Dinámico / PLA Estudiant
      viuniact       tabvalces.iuniact%TYPE;   --       viuniact       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      -- Fin Bug XXX
         -- BUG 18423 - 09/01/2012 - JMP - Multimoneda
      v_cempres      seguros.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      v_f_sysdate    ctaseguro_shadow.fcontab%TYPE;   --       v_f_sysdate    DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_error        axis_literales.slitera%TYPE;
   -- FIN BUG 18423 - 09/01/2012 - JMP - Multimoneda
   BEGIN
      -- BUG 18423 - 09/01/2012 - JMP - Multimoneda
      SELECT cempres
        INTO v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);

      -- FIN BUG 18423 - 09/01/2012 - JMP - Multimoneda
      -- Obtenemos el código de detalle de movimiento en CTASEGURO
      IF pxcmovimi = 34 THEN
         xcdetmovimi := 94;   -- Detalle de Rescate Total
      ELSIF pxcmovimi = 33 THEN
         xcdetmovimi := 93;   -- Detalle de Rescate Parcial
      ELSIF pxcmovimi = 31 THEN
         xcdetmovimi := 91;   -- Detalle de Siniestro
      ELSIF pxcmovimi = 27 THEN
         xcdetmovimi := 87;   -- Detalle de Penal. rescate
      ELSE
         xcdetmovimi := 97;   -- Detalle de Traspaso de Salida
      END IF;

      FOR regs IN cur_distribucion LOOP
         --Calcula les distribucions
         xidistrib := (pivalora * regs.pdistrec) / 100;

         -- Bug XXX - RSC - 24/11/2009 - Ajustes PPJ Dinámico / PLA Estudiant
         BEGIN
            SELECT iuniactvtashw
              INTO viuniact
              FROM tabvalces
             WHERE ccesta = regs.ccesta
               AND TRUNC(fvalor) = TRUNC(fcuenta);

            --Inserta registres a cuenta seguro.
            BEGIN
               v_f_sysdate := f_sysdate;

               INSERT INTO ctaseguro_shadow
                           (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                            cmovimi, imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                            smovrec, cesta, cestado, nunidad,
                            fasign)
                    VALUES (psseguro, v_f_sysdate, NVL(xnnumlin, 1), fcuenta, fcuenta,
                            xcdetmovimi, xidistrib, NULL, NULL, seqgrupo, 0, pnsinies,
                            NULL, regs.ccesta, '2',((xidistrib / viuniact) * -1),
                            TRUNC(f_sysdate));

               -- BUG 18423 - 09/01/2012 - JMP - Multimoneda
               IF v_cmultimon = 1 THEN
                  v_error := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro,
                                                                            v_f_sysdate,
                                                                            NVL(xnnumlin, 1),
                                                                            fcuenta);

                  IF v_error <> 0 THEN
                     RETURN v_error;
                  END IF;
               END IF;

               -- FIN BUG 18423 - 09/01/2012 - JMP - Multimoneda
               xnnumlin := xnnumlin + 1;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  RETURN 104879;   -- Registre duplicat a CTASEGURO
               WHEN OTHERS THEN
                  RETURN 102555;   -- Error al insertar a la taula CTASEGURO
            END;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               --Inserta registres a cuenta seguro.
               BEGIN
                  v_f_sysdate := f_sysdate;

                  INSERT INTO ctaseguro_shadow
                              (sseguro, fcontab, nnumlin, ffecmov, fvalmov,
                               cmovimi, imovimi, imovim2, nrecibo, ccalint, cmovanu, nsinies,
                               smovrec, cesta, cestado)
                       VALUES (psseguro, v_f_sysdate, NVL(xnnumlin, 1), fcuenta, fcuenta,
                               xcdetmovimi, xidistrib, NULL, NULL, seqgrupo, 0, pnsinies,
                               NULL, regs.ccesta, '1');

                  -- BUG 18423 - 09/01/2012 - JMP - Multimoneda
                  IF v_cmultimon = 1 THEN
                     v_error :=
                        pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro, v_f_sysdate,
                                                                       NVL(xnnumlin, 1),
                                                                       fcuenta);

                     IF v_error <> 0 THEN
                        RETURN v_error;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 09/01/2012 - JMP - Multimoneda
                  xnnumlin := xnnumlin + 1;
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     RETURN 104879;   -- Registre duplicat a CTASEGURO
                  WHEN OTHERS THEN
                     RETURN 102555;   -- Error al insertar a la taula CTASEGURO
               END;
         END;
      -- Fin Bug
      END LOOP;

      RETURN 0;
   END f_distribuye_ctaseguro_shw;

   FUNCTION f_valida_permite_rescate(
      psseguro IN NUMBER,
      pcagente IN NUMBER,
      pfrescate IN DATE,
      pccausin IN NUMBER,
      pimporte IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      num_err        NUMBER;
      v_sproduc      seguros.sproduc%TYPE;   --       v_sproduc      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_norden       asegurados.norden%TYPE;   --       v_norden       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_cempres      empresas.cempres%TYPE;
      vcrealiza      cfg_accion.crealiza%TYPE;
      vpasexec       NUMBER := 0;
   BEGIN
      vpasexec := 1;

      SELECT sproduc, cempres
        INTO v_sproduc, v_cempres
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;
      -- Primero mira si el producto y el usuario permite rescates
      --Bug.: 10615 - 09/07/2009 - ICV - Revisió de la parametrització d'accions
      num_err := pac_cfg.f_get_user_accion_permitida(f_user, 'RESCATES', v_sproduc, v_cempres,
                                                     vcrealiza);

      IF num_err <> 1 THEN
         IF num_err = 0 THEN
            RETURN 9000790;   -- BUG12384:DRA:03/02/2010
         ELSE
            RETURN num_err;
         END IF;
      END IF;

      vpasexec := 3;

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

      vpasexec := 4;
      num_err := pac_sin.f_permite_alta_siniestro(psseguro, v_norden, pfrescate,
                                                  TRUNC(f_sysdate), pccausin, 0);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Mirar que la póliza es de la misma oficina
      vpasexec := 5;
      -- Mirar si está permitido el rescate según la parametrización del producto
      --Bug.: 10615 - 09/07/2009 - ICV - Revisió de la parametrització d'accions   (Se añade el importe a la llamada)
      num_err := pac_rescates.f_es_rescatable(psseguro, pfrescate, pccausin, pimporte);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Mirar si tiene descuadres
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         num_err := 108190;   -- Error General
         p_tab_error(f_sysdate, getuser, 'pac_rescates.f_valida_permite_rescate_total',
                     vpasexec,
                     'parametros: psseguro=' || psseguro || ' pcagente=' || pcagente
                     || ' pfrescate =' || pfrescate,
                     SQLERRM);
         RETURN num_err;
   END f_valida_permite_rescate;

   FUNCTION f_avisos_rescates(
      psseguro IN NUMBER,
      pfrescate IN DATE,
      pirescate IN NUMBER,
      cavis OUT NUMBER,
      pdatos OUT NUMBER)
      RETURN NUMBER IS
      /*************************************************************************************
        Esta función mira si se deben mostrar mensajes de aviso en un rescate (cavis) y si se deben
        mostrar los datos en la simulación.
           cavis: null.- no hay aviso
                  literal .- si hay aviso
           pdatos: 0.- no mostrar datos de simulación
                   1.- mostrar datos de simulación
      ****************************************************************************************/
      vpasexec       NUMBER := 0;
   BEGIN
      vpasexec := 1;
      pdatos := 1;

      -- Mirar si hay descuadre de primas. En ese caso se dará un mensaje de aviso y no se mostrarán
      -- los datos
      IF pac_calc_comu.ff_desquadrament(psseguro, NULL) = 1 THEN
         cavis := 180665;   -- No se puede realizar simulación sobre esta póliza. ¿Proceder al rescate?
         pdatos := 0;
      END IF;

      vpasexec := 2;

      -- Mirar si el importe de rescate = 0. En ese caso se dará un mensaje de aviso pero sí
      -- se mostrarán los datos
      IF pirescate = 0 THEN
         cavis := 180666;   -- Penalización 100%. Importe 0€. ¿Proceder al rescate?
         pdatos := 1;
      END IF;

      vpasexec := 3;

      IF f_vivo_o_muerto(psseguro, 2, pfrescate) > 0 THEN
         cavis := 180797;
         pdatos := 0;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rescate.f_avisos_rescate', vpasexec,
                     'WHEN-OTHERS', SQLERRM);
         RETURN 108190;
   END f_avisos_rescates;

   -- Bug 12822 - RSC - 22/01/2010 - CEM - RT - Tratamiento fiscal rentas a 2 cabezas
   FUNCTION f_quien_muerto(psseguro IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      v_muertos      NUMBER;
      v_quienmue     asegurados.norden%TYPE;   --       v_quienmue     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      SELECT COUNT(1)
        INTO v_muertos
        FROM asegurados a
       WHERE a.sseguro = psseguro
         AND a.ffecmue <= pfecha;

      IF v_muertos > 0 THEN
         BEGIN
            SELECT norden
              INTO v_quienmue
              FROM asegurados a
             WHERE a.sseguro = psseguro
               AND a.ffecmue <= pfecha;
         EXCEPTION
            WHEN TOO_MANY_ROWS THEN
               RETURN(1);   -- Por si estan muertos los dos y calcula rentas!
         END;

         RETURN v_quienmue;
      END IF;

      RETURN(0);
   END f_quien_muerto;
-- Fin bug 12822
END pac_rescates;

/

  GRANT EXECUTE ON "AXIS"."PAC_RESCATES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_RESCATES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_RESCATES" TO "PROGRAMADORESCSI";
