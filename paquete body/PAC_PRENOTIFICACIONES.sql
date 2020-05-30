--------------------------------------------------------
--  DDL for Package Body PAC_PRENOTIFICACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PRENOTIFICACIONES" AS
/******************************************************************************
  NOMBRE:       pac_prenotificaciones
  PROPÓSITO:  Mantenimiento notificaciones capa lógica

  REVISIONES:
  Ver        Fecha       Autor           Descripción
  ---------  ----------  --------------  -----------------------------------
  1.0        18/11/2011  JMF             0020000: LCOL_A001-Prenotificaciones
  2.0        25/11/2011  JGR             0020037: Parametrización de Devoluciones
  3.0        29/12/2011  JGR             0020735: Introduccion de cuenta bancaria, indicando tipo de cuenta y banco Nota:102170
  4.0        12/01/2012  JMF             0019894: LCOL898 - 12 - Interface Respuesta Cobros Débito automático Banco ACH
  5.0        17/01/2012  JGR             0020735: Introduccion de cuenta bancaria, indicando tipo de cuenta y banco
  6.0        19/01/2012  JGR             0020285: LCOL898 - Interface - Recaudos - Débito Automático Prenotificaciones Banco Helm - 0104346
  7.0        23/01/2012  MDS             0021003: LCOL_A001-LCOLA_001 - Errores en las prenotificaciones
  8.0        01/02/2012  APD             0021021: LCOL_A001-Listado de prenotificacion en previo no muestra columna tipo de cuenta
  9.0        13/02/2012  MDS             0021318: LCOL897-LCOL_A001-Añadir nuevos campos en el previo de domiciliaciones
 10.0        21/02/2012  JGR             0021358: LCOL898-Error al cambiar el estado de impresion de los recibo prenotificados en respuestas no exitosas
 11.0        21/02/2012  JGR             0021120: LCOL897-LCOL_A001-Resumen y detalle ... NOTA:0108092
 12.0        21/02/2012  JGR             0021120: LCOL897-LCOL_A001-Resumen y detalle ... NOTA:0108895 - Cambiar control estado prenotif.
 13.0        21/03/2012  JGR             0021795: LCOL_A001-Modificaciones en prenotificaciones - 0111022
 14.0        03/04/2012  JGR             0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176
 15.0        19/11/2012  ECP             0024672: LCOL_A003-Domiciliaciones - QT 0005339: Consultas en los aplciativos y validaciones pendientes
 16.0        12/12/2012  JGR             0024801: POSPG100-(POSPG100)-Parametrizacion- Administracion y Finanzas- Contemplar diferentes formatos ficheros domiciliacion
 17.0        06/03/2013  JGR             0025151: LCOL999-Redefinir el circuito de prenotificaciones
 18.0        03/04/2013  JGR             0025151: LCOL999-Redefinir el circuito de prenotificaciones - 0142020
 19.0        13/05/2013  JGR             0026956: Detectado que en algunos casos no agrupa bien los recibos de NOTIFIACIONES - 0144367
 20.0        19/06/2013  JGR             0027381: Texto que las notificaciones graba en la agenda del recibo incluye el código de la cuenta sin encriptar - QT-8085
 21.0        20/06/2013  JGR             0027411: Error al generar más de un número de matrícula para un mismo cliente en procesos de prenotificación diferentes - QT-8145
 22.0        03/07/2013  MMM             0027568: Error en campo Sucursal de listado previo y domiciliación ACH (86) Vida - QT8320
 23.0        31/07/2013  MMM             0027802: LCOL_MILL-No se han de notificar recibos de tipos (9, 13, 15) - QT-8147 (nota: 36305) y QT-8736
******************************************************************************/

   -----------------------------------------------------------------------------
   FUNCTION f_domiciliar_notifica(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pfefecto IN DATE,
      pfcobro IN DATE,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      -- BUG 18825 - 19/07/2011 - JMP
      pccobban IN NUMBER,
      pcbanco IN NUMBER,
      pctipcta IN NUMBER,
      pfvtotar IN VARCHAR2,
      pcreferen IN VARCHAR2,
      pdfefecto IN DATE,
      -- FIN BUG 18825 - 19/07/2011 - JMP
      pcidioma IN NUMBER,
      pfitxer OUT VARCHAR2,
      pnum_ok OUT NUMBER,
      pnum_ko OUT NUMBER)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(900) := 'pac_prenotificaciones.f_domiciliar_notifica';
      vpar           VARCHAR2(900)
         := NULL || ' psproces=' || psproces || ' pcempres=' || pcempres || ' pfefecto='
            || pfefecto || ' pfcobro=' || pfcobro || ' pcramo=' || pcramo || ' pcmodali='
            || pcmodali || ' pctipseg=' || pctipseg || ' pccolect=' || pccolect
            || ' pccobban=' || pccobban || ' pcbanco=' || pcbanco || ' pctipcta=' || pctipcta
            || ' pfvtotar=' || pfvtotar || ' pcreferen=' || pcreferen || ' pdfefecto='
            || pdfefecto || ' pcidioma=' || pcidioma;
      lwhere         VARCHAR2(1000);
      lctipemp       empresas.ctipemp%TYPE;   --NUMBER(10);
      lmincobdom     DATE;
      num_err        NUMBER := 0;
      num_err2       NUMBER;
   BEGIN
      vpas := 1000;

      -- Dades de empresa, n¿ de d¿ de carencia para el cobro desde la generaci¿n del soporte,
      -- i si ¿corredoria
      BEGIN
         SELECT ctipemp, TRUNC(f_sysdate) + NVL(ncardom, 0)
           INTO lctipemp, lmincobdom
           FROM empresas
          WHERE cempres = pcempres;
      EXCEPTION
         WHEN OTHERS THEN
            lmincobdom := TRUNC(f_sysdate);
            lctipemp := 0;
      END;

      -- Llamamos al proceso de domiciliaci¿n
      -- Bug 11835 - APD - 13/11/2009 - se comentar la llamada a pac_propio.p_predomiciliacion para que
      -- no se anulen recibos en el proceso de domiciliación
      --pac_propio.p_predomiciliacion(psproces, pcempres, pcidioma, pcramo, pcmodali, pctipseg,
      --                                    pccolect);
      -- Bug 11835 - APD - 13/11/2009 - Fin
      -- Obtenir els rebuts candidats i guardar-los a notificaciones
      vpas := 1010;
      num_err := pac_prenotificaciones.f_cobrament(psproces, pcempres, lmincobdom, pfefecto,
                                                   pfcobro, pcidioma, pcramo, pcmodali,
                                                   pctipseg, pccolect, pccobban, pcbanco,
                                                   pctipcta, pfvtotar, pcreferen, pdfefecto,
                                                   pnum_ok, pnum_ko);

      IF num_err = 0 THEN
         vpas := 1020;
         num_err := pac_prenotificaciones.f_domrecibos(lctipemp, pcidioma, psproces, pfitxer,
                                                       pfcobro);   --> -- Bug.: 13498 - JGR - 04/03/2010
      ELSIF num_err = 102903 THEN   -- Si no hi han rebuts
         -- Bug 11835 - MCA - 01/12/2009 - se incluye la empresa para saber el path
         vpas := 1030;
         num_err := pac_prenotificaciones.f_fitxer_buit(psproces, pcempres);
      END IF;

      RETURN num_err;
   END f_domiciliar_notifica;

-----------------------------------------------------------------------------
   FUNCTION f_cobrament(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pmincobdom DATE,
      pfefecto IN DATE,
      pfcobro IN DATE,
      pcidioma IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      -- BUG 18825 - 19/07/2011 - JMP
      pccobban IN NUMBER,
      pcbanco IN NUMBER,
      pctipcta IN NUMBER,
      pfvtotar IN VARCHAR2,
      pcreferen IN VARCHAR2,
      pdfefecto IN DATE,
      -- FIN BUG 18825 - 19/07/2011 - JMP
      pnum_ok OUT NUMBER,
      pnum_ko OUT NUMBER)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(900) := 'pac_prenotificaciones.f_cobrament';
      vpar           VARCHAR2(900)
         := NULL || ' psproces=' || psproces || ' pcempres=' || pcempres || ' pmincobdom='
            || pmincobdom || ' pfefecto=' || pfefecto || ' pfcobro=' || pfcobro
            || ' pcidioma=' || pcidioma || ' pcramo=' || pcramo || ' pcmodali=' || pcmodali
            || ' pctipseg=' || pctipseg || ' pccolect=' || pccolect || ' pccobban='
            || pccobban || ' pcbanco=' || pcbanco || ' pctipcta=' || pctipcta || ' pfvtotar='
            || pfvtotar || ' pcreferen=' || pcreferen || ' pdfefecto=' || pdfefecto;
-------------------------------------------------------------------------------------
-- S'omple la taula notificaciones amb els rebuts que volem domiciliar ,
-- els cobra i guarda l'estat, si ha anat be o no
--      estat          NUMBER;
      xcontad        NUMBER := 0;
      --     xfsituac       DATE;
      xfmovim        notificaciones.fefecto%TYPE;

      TYPE t_cursor IS REF CURSOR;

      c_rebuts       t_cursor;
      v_sel          VARCHAR2(4000);
      lcfeccob       productos.cfeccob%TYPE;   --NUMBER(10);
      lpgasint       productos.pgasint%TYPE;   --NUMBER(10);
      lpgasext       productos.pgasext%TYPE;   --NUMBER(10);
      lsproduc       productos.sproduc%TYPE;   --NUMBER(10);
      lefecto        VARCHAR2(10);
      lnliqlin       NUMBER;
      lnliqmen       NUMBER;
      lsmovagr       NUMBER;
      num_err        NUMBER;
      xnprolin       NUMBER;
      texto          VARCHAR2(400);
      lprodusu       productos.sproduc%TYPE;
      lcerror        NUMBER;
      -- bug 8416
      vtvalpar       parempresas.tvalpar%TYPE;

      -- bug 8416
      -- ini BUG 21003 - MDS - 25/01/2012
      -- añadir campos sucursal,ramo,actividad,entidad_bancaria,codigo_banco,tipo_cuenta
      -- numero_cuenta,fecha_vencimientotjt
      -- numide_tomador,asegurado,numide_asegurado,pagador,numide_pagador
      -- codi_prenotificacion,codi_redbancaria
      -- fin BUG 21003 - MDS - 25/01/2012
      TYPE registre IS RECORD(
         empresa        VARCHAR2(200),
         sucursal       VARCHAR2(200),
         ramo           VARCHAR2(200),
         producto       VARCHAR2(100),
         actividad      seguros.cactivi%TYPE,
         codbancar      VARCHAR2(200),
         cobrador       VARCHAR2(100),
         entidad_bancaria bancos.tbanco%TYPE,
         codigo_banco   cobbancario.ncuenta%TYPE,
         tipo_cuenta    VARCHAR2(200),
         numero_cuenta  recibos.cbancar%TYPE,
         entidad_bancaria_recibo bancos.tbanco%TYPE,
         codigo_banco_recibo recibos.cbancar%TYPE,
         cbancar        recibos.cbancar%TYPE,
         fecha_vencimientotjt DATE,
         nrecibo        NUMBER,   --(9);
         npoliza        VARCHAR2(20),   --(8);
         tipo_recibo    VARCHAR2(100),
         tomador        VARCHAR2(200),
         numide_tomador per_personas.nnumide%TYPE,
         asegurado      VARCHAR2(200),
         numide_asegurado per_personas.nnumide%TYPE,
         pagador        VARCHAR2(200),
         numide_pagador per_personas.nnumide%TYPE,
         fefecto        DATE,
         fvencim        DATE,
         itotalr        NUMBER,   --(15,2);
         codi_prenotificacion VARCHAR2(200),
         proceso        NUMBER,   --(100);
         fichero        VARCHAR2(500),
         -- BUG 18825 - 19/07/2011 - JMP
         estado         detvalores.tatribu%TYPE,
         testimp        VARCHAR2(500),
         fcorte         DATE,
         estdomi        detvalores.tatribu%TYPE,
         festado        DATE   -- FIN BUG 18825 - 19/07/2011 - JMP
      );

      r_nrecibo      recibos.nrecibo%TYPE;
      r_ccobban      cobbancario.ccobban%TYPE;
      c_tsufijo      cobbancario.tsufijo%TYPE;
      c_cdoment      cobbancario.cdoment%TYPE;
      c_cdomsuc      cobbancario.cdomsuc%TYPE;
      s_sproduc      productos.sproduc%TYPE;
      s_cramo        productos.cramo%TYPE;
      s_cmodali      productos.cmodali%TYPE;
      s_ctipseg      productos.ctipseg%TYPE;
      s_ccolect      productos.ccolect%TYPE;
      m_fmovini      movrecibo.fmovini%TYPE;
      r_cagente      recibos.cagente%TYPE;
      s_cagrpro      productos.cagrpro%TYPE;
      s_ccompani     productos.ccompani%TYPE;
      r_cempres      empresas.cempres%TYPE;
      e_ctipemp      empresas.ctipemp%TYPE;
      r_sseguro      seguros.sseguro%TYPE;
      r_ctiprec      recibos.ctiprec%TYPE;
      r_cbancar      recibos.cbancar%TYPE;
      r_nmovimi      recibos.nmovimi%TYPE;
      r_fefecto      recibos.fefecto%TYPE;
      r_ctipban      recibos.ctipban%TYPE;
      vtextobs       agd_apunte.tapunte%TYPE;   -- 11. 21/02/2012  JGR  0021120/0108092 - Inicio
      n_idnotif      notificaciones.idnotif%TYPE;   -- Bug 24672 - ECP - 19/11/2012
      rec            registre;
      -- BUG 0019999 - 14/11/2011 - JMF
      v_cobra_recdom parempresas.nvalpar%TYPE;

      -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliación
      CURSOR c_prod IS
         SELECT *
           FROM domisaux
          WHERE sproces = psproces;

      -- FI Bug 15750 - FAL - 27/08/2010
      v_num_err      NUMBER;   -- Bug 21116 - APD - 27/01/2012
      vtdescrip      cobbancario.descripcion%TYPE;   -- Bug 21116 - APD - 27/01/2012
      vtcobban       cobbancario.tcobban%TYPE;   -- Bug 21116 - APD - 27/01/2012
      -- 17. 0025151: LCOL999-Redefinir el circuito de prenotificaciones - Inicio
      e_salir        EXCEPTION;
      vcexistepagador tomadores.cexistepagador%TYPE;
      vsperson_notif tomadores.sperson%TYPE;
      vctipcc        tipos_cuenta.ctipcc%TYPE;
      vctipide       notificaciones.ctipide%TYPE;
      vnnumide       notificaciones.nnumide%TYPE;
   -- 17. 0025151: LCOL999-Redefinir el circuito de prenotificaciones - Final
   BEGIN
      vpas := 1000;
      lefecto := TO_CHAR(pfefecto + 1, 'dd/mm/yyyy');

      IF pcramo IS NOT NULL
         AND pcmodali IS NOT NULL
         AND pctipseg IS NOT NULL
         AND pccolect IS NOT NULL THEN
         BEGIN
            vpas := 1010;

            SELECT sproduc
              INTO lprodusu
              FROM productos
             WHERE cramo = pcramo
               AND cmodali = pcmodali
               AND ctipseg = pctipseg
               AND ccolect = pccolect;
         EXCEPTION
            WHEN OTHERS THEN
               lprodusu := NULL;
         END;
      ELSE
         lprodusu := NULL;
      END IF;

      -- Bug 9383 - 09/03/2009 - RSC - CRE: Unificación de recibos
      -- Añadimos 'RECUNIF' y tratamiento cestaux = 2
      --MCC/ 06/04/2009 / BUG 0009730: CEM - Recibos reunificados y notificaciones

      -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar productos en el proceso domiciliación
      vpas := 1020;

      FOR reg IN c_prod LOOP
         vpas := 1030;

         SELECT sproduc
           INTO lprodusu
           FROM productos
          WHERE cramo = reg.cramo
            AND cmodali = reg.cmodali
            AND ctipseg = reg.ctipseg
            AND ccolect = reg.ccolect;

         -- pcramo := reg.cramo;
         -- JGM - bug 11339 - 08/10/2009
         vpas := 1040;
         v_sel := pac_prenotificaciones.f_retorna_query(TO_CHAR(pfefecto, 'ddmmyyyy'),
                                                        reg.cramo, lprodusu, pcempres, NULL,
                                                        FALSE, pccobban, pcbanco, pctipcta,
                                                        pfvtotar, pcreferen,
                                                        TO_CHAR(pdfefecto, 'ddmmyyyy'));
         -- Fi Bug 15750 - FAL - 27/08/2010
         lsproduc := -1;
         lprodusu := 0;
         vpas := 1050;

         OPEN c_rebuts FOR v_sel;

         vpas := 1060;

         LOOP
            vpas := 1070;

            FETCH c_rebuts
             INTO rec;

            EXIT WHEN c_rebuts%NOTFOUND;

            BEGIN
               vpas := 1080;

               -- Bug 24672 - ECP - 19/11/2012  se inclutye el campo IDNOTIF en el insert
               SELECT r.nrecibo, r.ccobban, r.cagente, r.cempres, r.sseguro, r.ctiprec,
                      r.cbancar, r.nmovimi, r.fefecto, r.ctipban,
                      TO_NUMBER((SELECT to2.sperson
                                   FROM tomadores to2
                                  WHERE to2.sseguro = r.sseguro
                                    AND NVL(to2.nordtom, 1) = 1)
                                || (SELECT LPAD(MAX(cnordban), 2, '0')
                                      FROM per_ccc
                                     WHERE sperson IN(
                                              SELECT to2.sperson
                                                FROM tomadores to2
                                               WHERE to2.sseguro = r.sseguro
                                                 AND NVL(to2.nordtom, 1) = 1)
                                       AND cbancar = r.cbancar))
                 INTO r_nrecibo, r_ccobban, r_cagente, r_cempres, r_sseguro, r_ctiprec,
                      r_cbancar, r_nmovimi, r_fefecto, r_ctipban,
                      n_idnotif
                 FROM recibos r
                WHERE nrecibo = rec.nrecibo;

               vpas := 1090;

               SELECT c.tsufijo, c.cdoment, c.cdomsuc
                 INTO c_tsufijo, c_cdoment, c_cdomsuc
                 FROM cobbancario c
                WHERE c.ccobban = r_ccobban;   --|| '-' || c.descripcion = rec.codbancar;

               vpas := 1100;

               SELECT s.sproduc, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cagrpro,
                      s.ccompani
                 INTO s_sproduc, s_cramo, s_cmodali, s_ctipseg, s_ccolect, s_cagrpro,
                      s_ccompani
                 FROM seguros s
                WHERE s.sseguro = r_sseguro;   --s.npoliza || '-' || s.ncertif = rec.npoliza;

               vpas := 1110;

               SELECT m.fmovini
                 INTO m_fmovini
                 FROM movrecibo m
                WHERE m.nrecibo = rec.nrecibo
                  AND m.cestrec = 0
                  AND m.fmovfin IS NULL;

               vpas := 1120;

               SELECT e.ctipemp
                 INTO e_ctipemp
                 FROM empresas e, seguros s
                WHERE s.sseguro = r_sseguro   --s.npoliza || '-' || s.ncertif = rec.npoliza;
                  AND s.cempres = e.cempres;
            END;

            IF lsproduc <> s_sproduc THEN
               -- Es mira si l'usuari te restringit el producte (1-Pot cobrar 0 - no pot)
               vpas := 1130;
               lprodusu := f_produsu(s_cramo, s_cmodali, s_ctipseg, s_ccolect, 5);
               -- Canviem la data d'efecte per la de cobrament en cas de que ho
               -- digui el producte (cfeccob = 1 s'ha de canviar)
               vpas := 1140;

               SELECT cfeccob, pgasint, pgasext
                 INTO lcfeccob, lpgasint, lpgasext
                 FROM productos
                WHERE sproduc = s_sproduc;

               lsproduc := s_sproduc;
            END IF;

            IF lprodusu = 1 THEN
               IF NVL(lcfeccob, 0) = 1 THEN
                  vpas := 1150;
                  xfmovim := NVL(pfcobro, m_fmovini);
               ELSE
                  IF m_fmovini < pmincobdom THEN
                     xfmovim := pmincobdom;
                  ELSE
                     xfmovim := m_fmovini;
                  END IF;
               END IF;

               /*
                              -- Bug 21116 - APD - 27/01/2012 - Controlar que si existe una domiciliación
                              -- en curso para un cobrador bancario, no permitir realizar una nueva
                              -- domiciliación de este cobrador bancario (0.-No controlar, 1.-Si controlar)
                              IF NVL(pac_parametros.f_parempresa_n(pcempres, 'DOMI_COBBAN'), 0) = 1 THEN

                                 v_num_err := pac_prenotificaciones.f_valida_prenoti_cobban(pcempres, r_ccobban);

                                 IF v_num_err <> 0 THEN
                                    ROLLBACK;
                                    xnprolin := NULL;
                                    num_err := f_descobrador(r_ccobban, vtdescrip, vtcobban);

                                    IF num_err <> 0 THEN
                                       vtdescrip := NULL;
                                       vtcobban := NULL;
                                    END IF;

                                    texto := f_axis_literales(v_num_err, pcidioma) || ' ' || r_ccobban || '.-'
                                             || vtdescrip;
                                    texto := SUBSTR(texto, 1, 120);
                                    num_err := f_proceslin(psproces, texto, rec.nrecibo, xnprolin);
                                    COMMIT;
                                    RETURN v_num_err;
                                 END IF;
                              END IF;

                              -- fin Bug 21116 - APD - 27/01/2012
               */

               -- 17. 0025151: LCOL999-Redefinir el circuito de prenotificaciones - Inicio
               -- Se graban los nuevos campos en los que se basará saber si se requiere generar una nueva
               -- prenotificación en F_INSRECIBO vctipcc, vctipide, vnnumide cojuntamente con el CBANCAR

               -- 21.0 0027411: Error al generar más de un número de matrícula - QT-8145 - Inicio

               /*

               BEGIN
                  SELECT NVL(t.cexistepagador, 0), sperson   -- 10. 0025151 - 0139714
                    INTO vcexistepagador, vsperson_notif   -- 10. 0025151 - 0139714
                    FROM tomadores t
                   WHERE t.sseguro = r_sseguro
                     AND t.nordtom = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     num_err := 105111;   -- Tomador no encontrado en la tabla TOMADORES.
                     RAISE e_salir;
                  WHEN OTHERS THEN
                     num_err := 105112;   -- Error al leer de la tabla TOMADORES.
                     RAISE e_salir;
               END;

               IF vcexistepagador = 1 THEN
                  BEGIN
                     SELECT g.sperson
                       INTO vsperson_notif
                       FROM gescobros g
                      WHERE g.sseguro = r_sseguro;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        num_err := 9904082;   -- Gestor de cobro / Pagador no encontrado en la tabla GESCOBROS.
                        RAISE e_salir;
                     WHEN OTHERS THEN
                        num_err := 9904083;   -- Error al leer en la tabla GESCOBROS.
                        RAISE e_salir;
                  END;
               END IF;

               */
               vsperson_notif := pac_prenotificaciones.f_pagador_sperson(r_sseguro);

               -- 21.0 0027411: Error al generar más de un número de matrícula - QT-8145 - Final
               SELECT nnumide, ctipide
                 INTO vnnumide, vctipide
                 FROM per_personas
                WHERE sperson = vsperson_notif;

               IF r_ctipban IS NOT NULL THEN
                  SELECT ctipcc
                    INTO vctipcc
                    FROM tipos_cuenta
                   WHERE ctipban = r_ctipban;
               END IF;

               -- 17. 0025151: LCOL999-Redefinir el circuito de prenotificaciones - Final

               -- Guardem a notificaciones
               BEGIN
                  vpas := 1160;

                  INSERT INTO notificaciones
                              (sproces, nrecibo, ccobban, cempres, fefecto, cdoment,
                               cdomsuc, tsufijo, cagente, cagrpro, ccompani,
                               ctipemp, sseguro, ctiprec,
                               cbancar, nmovimi,
                               cramo, cmodali, ctipseg, ccolect, pgasint, pgasext,
                               cfeccob, fefecrec, ctipban, idnotif,
                                                                   -- 17. 0025151 - Inicio
                                                                   ctipcc,
                               ctipide, nnumide
                                               -- 17. 0025151 - Final
                  ,            smovrec   -- 19. 0026956 - 0144367
                                      )
                       VALUES (psproces, r_nrecibo, r_ccobban, pcempres, xfmovim, c_cdoment,
                               c_cdomsuc, c_tsufijo, r_cagente, s_cagrpro, s_ccompani,
                               e_ctipemp, r_sseguro, r_ctiprec,
                               REPLACE(REPLACE(rec.cbancar, '<', ''), '>', ''),   -- 11. 21/02/2012  JGR  0021120/0108092
                                                                               r_nmovimi,
                               s_cramo, s_cmodali, s_ctipseg, s_ccolect, lpgasint, lpgasext,
                               lcfeccob, rec.fefecto, r_ctipban, n_idnotif,
                                                                           -- 17. 0025151 - Inicio
                                                                           vctipcc,
                               vctipide, vnnumide
                                                 -- 17. - Final
                  ,            vsperson_notif   -- 19. 0026956 - 0144367
                                             );   -- Bug 24672 - ECP - 19/11/2012

                  xcontad := xcontad + 1;
               -- 14. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176 - Inicio
               -- Eliminado no se hará servir esta tabla "domici"
               -- sera solo la DOMICILIACIONES_CAB y solo en domiciliaciones.
               /*
               -- BUG 18825 - 19/07/2011 - JMP
               IF xcontad = 1
                  AND NVL(f_parinstalacion_n('DOMDEV'), 0) = 1 THEN
                  BEGIN
                     vpas := 1170;

                     INSERT INTO domici
                                 (sproces, cestado, festado)
                          VALUES (psproces, 1, f_sysdate);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        ROLLBACK;
                        xnprolin := NULL;
                        texto := REPLACE(f_axis_literales(800951, pcidioma), '#4#',
                                         'DOMICI');
                        texto := SUBSTR(texto || ' ' || SQLERRM, 1, 120);
                        num_err := f_proceslin(psproces, texto, rec.nrecibo, xnprolin);
                        COMMIT;
                        RETURN 800951;   -- Registre duplicat a DOMICI
                     WHEN OTHERS THEN
                        ROLLBACK;
                        xnprolin := NULL;
                        texto := REPLACE(f_axis_literales(120038, pcidioma), '#1',
                                         'DOMICI');
                        texto := SUBSTR(texto || ' ' || SQLERRM, 1, 120);
                        num_err := f_proceslin(psproces, texto, rec.nrecibo, xnprolin);
                        COMMIT;
                        RETURN 120038;   -- Error a l' inserir a DOMICI
                  END;
               END IF;
               -- FIN BUG 18825 - 19/07/2011 - JMP
               */
                 -- 14. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176 - Fin
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     ROLLBACK;
                     xnprolin := NULL;
                     texto := f_axis_literales(102920, pcidioma);
                     texto := SUBSTR(texto || SQLERRM, 1, 120);
                     num_err := f_proceslin(psproces, texto, rec.nrecibo, xnprolin);
                     COMMIT;
                     RETURN 102920;   -- Registre repetit a notificaciones
                  WHEN e_salir THEN
                     ROLLBACK;
                     xnprolin := NULL;
                     texto := f_axis_literales(num_err, pcidioma);
                     texto := SUBSTR(texto || SQLERRM, 1, 120);
                     num_err := f_proceslin(psproces, texto, rec.nrecibo, xnprolin);
                     COMMIT;
                     RETURN 105058;   -- Error a l' inserir a notificaciones
                  WHEN OTHERS THEN
                     ROLLBACK;
                     xnprolin := NULL;
                     texto := f_axis_literales(105058, pcidioma);
                     texto := SUBSTR(texto || SQLERRM, 1, 120);
                     num_err := f_proceslin(psproces, texto, rec.nrecibo, xnprolin);
                     COMMIT;
                     RETURN 105058;   -- Error a l' inserir a notificaciones
               END;

               IF NVL(pac_parametros.f_parempresa_n(pcempres, 'AGENDA_PRENOT'), 0) = 1 THEN   -- 17. 06/03/2012 - 0025151
                  -- Prenotificación en curso #1# de recibo #2# para cuenta o tarjeta #3#.
                  vtextobs := f_axis_literales(9903307, pcidioma);
                  vtextobs := REPLACE(vtextobs, '#1#', psproces);
                  vtextobs := REPLACE(vtextobs, '#2#', r_nrecibo);
                  vtextobs := REPLACE(vtextobs, '#3#',
                                      '***' || SUBSTR(REPLACE(rec.cbancar, '>', ''), -4));
                  num_err := pac_prenotificaciones.f_agd_observaciones(pcempres, r_nrecibo,
                                                                       vtextobs);
               END IF;   -- 17. 06/03/2012 - 0025151

               IF num_err <> 0 THEN
                  RETURN num_err;
               END IF;
            -- 11. 21/02/2012  JGR  0021120/0108092 - Fin
            END IF;
         END LOOP;

         vpas := 1180;
         COMMIT;

         IF xcontad <> 0 THEN
            -- Bug 19999 - APD - 07/11/2011 - el cobro de los recibos se pasa a la nueva funcion f_estado_domiciliacion
            vpas := 1190;
            num_err := pac_prenotificaciones.f_estado_domiciliacion(pcempres, psproces, NULL,
                                                                    1, pnum_ok, pnum_ko);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      END LOOP;

      IF xcontad = 0 THEN
         RETURN 102903;   -- No s' ha trobat cap registre
      END IF;

      -- fin Bug 19999 - APD - 07/11/2011

      ----
      BEGIN
         vpas := 1200;

         DELETE FROM notificaciones
               WHERE sproces = psproces
                 AND NVL(cerror, 1) <> 0;
      EXCEPTION
         WHEN OTHERS THEN
            xnprolin := NULL;
            texto := f_axis_literales(112491, pcidioma);
            texto := SUBSTR(texto || ' ' || SQLERRM, 1, 120);
            num_err := f_proceslin(psproces, texto, 0, xnprolin);
            COMMIT;
            RETURN 112491;
      END;

      vpas := 1210;
      RETURN 0;
   END f_cobrament;

-----------------------------------------------------------------------------
   FUNCTION f_domrecibos(
      pctipemp IN NUMBER,
      pcidioma IN NUMBER,
      psproces IN NUMBER,
      pruta OUT VARCHAR2,
      pfcobro IN DATE DEFAULT NULL   --> -- Bug.: 13498 - JGR - 04/03/2010
                                  )
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(900) := 'pac_prenotificaciones.f_domrecibos';
      vpar           VARCHAR2(900)
         := NULL || ' pctipemp=' || pctipemp || ' pcidioma=' || pcidioma || ' psproces='
            || psproces || ' pfcobro=' || pfcobro;
      xtsufijo       VARCHAR2(3);
      xtsufpresentador VARCHAR2(3);
      xccobban       cobbancario.ccobban%TYPE;
      xcempres       notificaciones.cempres%TYPE;   --NUMBER(10);
      xcdoment       notificaciones.cdoment%TYPE;   --NUMBER(10);
      xcdomsuc       notificaciones.cdomsuc%TYPE;   --NUMBER(10);
      xnprolin       NUMBER;
      nom_fitxer     VARCHAR2(100);
      error          NUMBER;
      xpath          VARCHAR2(100);
      xtitulopro     VARCHAR2(100);
      fitxer         UTL_FILE.file_type;   -- FAL. 08/07/2010. Bug 0015325: AGA - Renombrado final de los ficheros de notificaciones

      CURSOR cur_domicxccobban IS
         SELECT   b.ccobban, a.cempres, a.cdoment, a.cdomsuc,
                  b.tfunc   -- Bug 20735/102170 - 29/12/2011 - JGR
             FROM notificaciones a, cobbancario b
            WHERE b.ccobban = a.ccobban
              AND a.sproces = psproces
              AND a.cerror = 0
         GROUP BY b.ccobban, a.cempres, a.cdoment, a.cdomsuc, b.tfunc
         ORDER BY b.ccobban, a.cempres, a.cdoment, a.cdomsuc, b.tfunc;

      CURSOR domici IS
         SELECT nrecibo, fefecto
           FROM notificaciones
          WHERE sproces = psproces
            AND cerror = 0;

      pmarca         NUMBER;
      pfechacobro    DATE;
      --v_tfunc        tipos_cuenta.tfunc%TYPE; -- Bug 20735/102170 - 29/12/2011 - JGR
      v_tfunc        cobbancario.tfunc%TYPE;   -- Bug 20735/102170 - 29/12/2011 - JGR
      num_ok         NUMBER;
      num_ko         NUMBER;
      vtxt           VARCHAR2(100);   -- 16. 0024801
   BEGIN
      vpas := 1000;
      error := 0;
      xtsufpresentador := '000';
      vpas := 1010;

      OPEN cur_domicxccobban;

      vpas := 1020;

      FETCH cur_domicxccobban
       INTO xccobban, xcempres, xcdoment, xcdomsuc, v_tfunc;   -- Bug 20735/102170 - 29/12/2011 - JGR

      vpas := 1030;

      WHILE cur_domicxccobban%FOUND LOOP
         --  Bug 11835 - MCA - 01/12/2009 - Se incluye aqui la recuperación del path
         vpas := 1040;
         xpath := pac_parametros.f_parempresa_t(xcempres, 'PATH_DOMIS');

         IF xpath IS NULL THEN
            RETURN 112443;
         END IF;

         -- fin 11835
         nom_fitxer := NULL;

         DECLARE
            v_sent         VARCHAR2(3000);
         BEGIN
            -- PROCESO PARA CALCULAR NOMBRE FICHERO
            vpas := 1050;
            -- 16. 0024801 - Inicio
            vtxt := LOWER(pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                        'SUFIJO_EMP'));

            IF vtxt IS NOT NULL THEN
               vtxt := '_' || vtxt;
            END IF;

            -- 16. 0024801 - Fin
            v_sent :=
                      -- 16. 0024801 - Inicio

                      --   'begin :nom_fitxer :=' || ' pac_nombres_ficheros_lcol.f_nom_notifi('
                      'begin :nom_fitxer :=' || ' pac_nombres_ficheros' || vtxt
                      || '.f_nom_notifi('
                                         -- 16. 0024801 - Fin
                      || psproces || ', ' || xcempres || ', ' || xcdoment || ', ' || xcdomsuc
                      || ', ' || xccobban || '); end;';
            vpas := 1055;

            EXECUTE IMMEDIATE v_sent
                        USING OUT nom_fitxer;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobj, vpas, SQLCODE, v_sent);
         END;

         IF nom_fitxer IS NULL THEN
            vpas := 1060;
            nom_fitxer := 'NOTIF' || LPAD(psproces, 6, '0') || '.' || LPAD(xcempres, 2, '0')
                          || '.' || LPAD(xcdoment, 4, '0') || '.' || LPAD(xcdomsuc, 4, '0');
         END IF;

         --Ini Bug.: 12858 - ICV - 02/02/2010
         IF pruta IS NULL THEN
            vpas := 1080;
            pruta := pac_parametros.f_parempresa_t(xcempres, 'PATH_DOMIS_C') || '\'
                     || nom_fitxer;
         ELSE
            vpas := 1090;
            pruta := pruta || '||' || pac_parametros.f_parempresa_t(xcempres, 'PATH_DOMIS_C')
                     || '\' || nom_fitxer;
         END IF;

         -- FAL. 8/7/2010. Ini Bug 0015325. Comprobar si fichero a crear ya existe. En ese caso borrarlo
         BEGIN
            vpas := 1100;
            fitxer := UTL_FILE.fopen(xpath, nom_fitxer, 'r');
            UTL_FILE.fclose(fitxer);
            UTL_FILE.fremove(xpath, nom_fitxer);
         EXCEPTION
            WHEN OTHERS THEN   -- si no existe fichero a crear -> correcto
               NULL;
         END;

         -- FAL. 8/7/2010. Fin Bug 0015325
         vpas := 1110;
         nom_fitxer := '_' || nom_fitxer;
         -- ini BUG 0019999 - 14/11/2011 - JMF
         vpas := 1120;

         -- fin BUG 0019999 - 14/11/2011 - JMF

         -- Fi Bug 0013153
         --Fin Bug.: 12858
         IF v_tfunc IS NOT NULL THEN   -- Banco ACH
            vpas := 1150;

            DECLARE
               v_sent         VARCHAR2(3000);
               v_nomfic       VARCHAR2(500);
            BEGIN
               -- PROCESO PARA FUNCION
               v_sent := v_tfunc;

               IF INSTR(v_sent, ':psproces') > 0 THEN
                  vpas := 1160;
                  v_sent := REPLACE(v_sent, ':psproces', psproces);
               END IF;

               IF INSTR(v_sent, ':pbnotificaciones') > 0 THEN
                  vpas := 1165;
                  v_sent := REPLACE(v_sent, ':pbnotificaciones', 'TRUE');
               END IF;

               IF INSTR(v_sent, ':xtsufpresentador') > 0 THEN
                  vpas := 1170;
                  v_sent := REPLACE(v_sent, ':xtsufpresentador',
                                    CHR(39) || xtsufpresentador || CHR(39));
               END IF;

               IF INSTR(v_sent, ':xcempres') > 0 THEN
                  vpas := 1180;
                  v_sent := REPLACE(v_sent, ':xcempres', xcempres);
               END IF;

               IF INSTR(v_sent, ':xcdoment') > 0 THEN
                  vpas := 1190;
                  v_sent := REPLACE(v_sent, ':xcdoment', xcdoment);
               END IF;

               IF INSTR(v_sent, ':xcdomsuc') > 0 THEN
                  vpas := 1200;
                  v_sent := REPLACE(v_sent, ':xcdomsuc', xcdomsuc);
               END IF;

               IF INSTR(v_sent, ':nom_fitxer') > 0 THEN
                  vpas := 1210;
                  v_sent := REPLACE(v_sent, ':nom_fitxer', CHR(39) || nom_fitxer || CHR(39));
               END IF;

               IF INSTR(v_sent, ':pcidioma') > 0 THEN
                  vpas := 1220;
                  v_sent := REPLACE(v_sent, ':pcidioma', pcidioma);
               END IF;

               IF INSTR(v_sent, ':pctipemp') > 0 THEN
                  vpas := 1230;
                  v_sent := REPLACE(v_sent, ':pctipemp', pctipemp);
               END IF;

               IF INSTR(v_sent, ':xpath') > 0 THEN
                  vpas := 1240;
                  v_sent := REPLACE(v_sent, ':xpath', CHR(39) || xpath || CHR(39));
               END IF;

               vpas := 1250;
               v_sent := 'begin :error := ' || v_sent || ' end;';
               vpas := 1260;

               EXECUTE IMMEDIATE v_sent
                           USING OUT error;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, vobj, vpas,
                              SQLCODE || ' ' || vpar || ' xccobban=' || xccobban, v_sent);
            END;
         -- fin BUG 0019999 - 14/11/2011 - JMF
         END IF;

         IF error = 0 THEN
            vpas := 1240;
            xnprolin := NULL;
            error := f_proceslin(psproces, nom_fitxer, xtsufpresentador, xnprolin);

            IF error = 0 THEN
               vpas := 1250;

               FETCH cur_domicxccobban
                INTO xccobban, xcempres, xcdoment, xcdomsuc, v_tfunc;
            ELSE
               EXIT;
            END IF;
         ELSE
            EXIT;
         END IF;
      END LOOP;

      vpas := 1260;

      CLOSE cur_domicxccobban;

      IF error = 0
         AND xcempres IS NOT NULL THEN
         vpas := 1270;
         error := pac_prenotificaciones.f_estado_domiciliacion(xcempres, psproces, NULL, 2,
                                                               num_ok, num_ko);
      END IF;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar || ' xccobban=' || xccobban,
                     SQLCODE || ' ' || SQLERRM);
         RETURN 112318;
   END f_domrecibos;

-----------------------------------------------------------------------------
   FUNCTION f_fitxer_buit(psproces IN NUMBER, pcempres IN NUMBER)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(900) := 'pac_prenotificaciones.f_fitxer_buit';
      vpar           VARCHAR2(900)
                               := NULL || ' psproces=' || psproces || ' pcempres=' || pcempres;
      nom_fitxer     VARCHAR2(50);
      fitxer         UTL_FILE.file_type;
      xpath          VARCHAR2(100);
   BEGIN
      -- Bug 11835 - APD - 01/12/2009 - se sustituye f_parinstalacion_t('PATH_DOMIS') por f_parempresa_t('PATH_DOMIS')
      vpas := 1000;
      xpath := pac_parametros.f_parempresa_t(pcempres, 'PATH_DOMIS');

      IF xpath IS NULL THEN
         RETURN 112443;
      END IF;

      vpas := 1010;
      nom_fitxer := f_parinstalacion_t('NOM_DOMIC');

      IF nom_fitxer IS NULL THEN
         vpas := 1020;
         nom_fitxer := 'DR' || LPAD(psproces, 6, '0');
      END IF;

      vpas := 1030;
      fitxer := UTL_FILE.fopen(xpath, nom_fitxer, 'w');
      vpas := 1040;
      UTL_FILE.fclose(fitxer);
      vpas := 1050;
      UTL_FILE.fcopy(xpath, nom_fitxer, xpath,
                     'mvdom' || TO_CHAR(f_sysdate, 'YYYYMMDD') || '.txt');
      RETURN 0;
   END f_fitxer_buit;

-----------------------------------------------------------------------------

   --------------------------------
-- bug 11339 - 08/10/2009 - JGM -
/*************************************************************************
    FUNCTION f_retorna_select
    Función que retornará la select de PREVIO_notificaciones
    Ejemplo: 01/01/2009, null,null,null,2

    param in fefecto   : VARCHAR2 - Obligatoria - Fecha Efecto (formato DD/MM/YYYY)
    param in cramo     : NUMBER - Opcional - Codigo Ramo
    param in sproduc   : NUMBER - Opcional - Codigo Producto
    param in cempres   : NUMBER - Opcional - Codigo Empresa
    param in pccobban  : Código de cobrador bancario
    param in pcbanco   : Código de banco
    param in pctipcta  : Tipo de cuenta
    param in pfvtotar  : Fecha de vencimiento tarjeta
    param in pcreferen : Código de referencia
    return             : Devolverá un VARCHAR2 con la SELECT usada en Map, pantalla y proceso.
*************************************************************************/
   FUNCTION f_retorna_query(
      fefecto IN VARCHAR2,
      cramo IN NUMBER,
      psproduc IN NUMBER,
      cempres IN NUMBER,
      psprodom IN NUMBER DEFAULT NULL,
      filtradomaximo IN BOOLEAN DEFAULT FALSE,
      -- BUG 18825 - 19/07/2011 - JMP
      pccobban IN NUMBER DEFAULT NULL,
      pcbanco IN NUMBER DEFAULT NULL,
      pctipcta IN NUMBER DEFAULT NULL,
      pfvtotar IN VARCHAR2 DEFAULT NULL,
      pcreferen IN VARCHAR2 DEFAULT NULL,
      pdfefecto IN VARCHAR2 DEFAULT NULL)
      -- FIN BUG 18825 - 19/07/2011 - JMP
   RETURN VARCHAR2 IS
      vpas           NUMBER;
      vobj           VARCHAR2(900) := 'pac_prenotificaciones.f_retorna_query';
      vpar           VARCHAR2(900)
         := NULL || ' fefecto=' || fefecto || ' cramo=' || cramo || ' psproduc=' || psproduc
            || ' cempres=' || cempres || ' psprodom='
            || psprodom   --||' filtradomaximo='||filtradomaximo
                       || ' pccobban=' || pccobban || ' pcbanco=' || pcbanco || ' pctipcta='
            || pctipcta || ' pfvtotar=' || pfvtotar || ' pcreferen=' || pcreferen
            || ' pdfefecto=' || pdfefecto;
      v_max_reg      NUMBER;
      -- Ini Bug 21003 - MDS
      -- ampliar la variable de 4000 a 6000
      v_result       VARCHAR2(6000);
      -- Fin Bug 21003 - MDS
      wsproduc       productos.sproduc%TYPE := psproduc;
      v_cidioma      idiomas.cidioma%TYPE := pac_md_common.f_get_cxtidioma;   -- BUG 18825 - 19/07/2011 - JMP
   BEGIN
      vpas := 1000;

      IF v_cidioma IS NULL THEN
         SELECT MAX(nvalpar)
           INTO v_cidioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      END IF;

      vpas := 1010;
      v_result :=
         NULL || ' select'
         || '        pac_isqlfor.f_empresa(y3.sseguro) EMPRESA,'   -- Ini Bug 21003 - MDS
         -- 22.0 MMM. 0027568 Error en campo Sucursal de listado previo y domiciliación ACH (86) Vida - QT8320
         || 'ff_desagente(pac_redcomercial.f_busca_padre(y1.cempres, NVL(y1.cagente, y3.cagente), NULL, NULL)) SUCURSAL,'
         --|| '(SELECT ff_desagente(cagente)
         --      FROM recibosredcom
         --     WHERE nrecibo=y1.nrecibo
         --       AND cempres=y1.cempres
         --       AND ctipage=2) SUCURSAL, '
         -- 22.0 MMM. 0027568 Error en campo Sucursal de listado previo y domiciliación ACH (86) Vida - QT8320
         || 'FF_DESRAMO(y3.cramo, ' || v_cidioma || ') RAMO, '   -- Fin Bug 21003 - MDS
         || '        f_desproducto_t(y3.cramo, y3.cmodali, y3.ctipseg, y3.ccolect, 1, '
         || v_cidioma || ') PRODUCTO,'   -- Ini Bug 21003 - MDS
         || 'y3.cactivi ACTIVIDAD, '   -- Fin Bug 21003 - MDS
         || '        y4.ccobban || ''-'' || y4.descripcion CODBANCAR, SUBSTR(y4.ncuenta,5,length(y4.ncuenta)-4) COBRADOR,'   -- Ini Bug 21003 - MDS
         -- Ini Bug 21318 - MDS
         --|| '(select tbanco from bancos where cbanco=SUBSTR(y4.ncuenta,1,4)) ENTIDAD_BANCARIA, '
         -- 11. 21/02/2012  JGR  0021120/0108092 - Inicio
         --|| 'pac_domiciliaciones.ff_nombre_entidad(y4.ncuenta, y4.ctipban) ENTIDAD_BANCARIA, '
         || 'pac_prenotificaciones.ff_nombre_entidad(y4.ncuenta, y4.ctipban) ENTIDAD_BANCARIA, '
         -- 11. 21/02/2012  JGR  0021120/0108092 - Fin
         -- Ini Bug 21318 - MDS
         || 'SUBSTR(y4.ncuenta,1,4) CODIGO_BANCO, ' || '(SELECT ff_desvalorfijo(800049, '
         || v_cidioma
         || ', ctipcc) FROM tipos_cuenta where ctipban = y1.ctipban) TIPO_DE_CUENTA, '
         --|| 'SUBSTR(y1.cbancar,5,length(y1.cbancar)-4) NUMERO_DE_CUENTA_RECIBO, '
         || '''<'' || SUBSTR(y1.cbancar,5,length(y1.cbancar)-4) || ''>'' NUMERO_DE_CUENTA_RECIBO, '   --|| '(select tbanco from bancos where cbanco=SUBSTR(y1.cbancar,1,4)) ENTIDAD_BANCARIA_RECIBO, '
         -- Ini Bug 21318 - MDS
         --|| '(select tbanco from bancos where cbanco=SUBSTR(y1.cbancar,1,4)) ENTIDAD_BANCARIA_RECIBO, '
         -- 11. 21/02/2012  JGR  0021120/0108092 - Inicio
         --|| 'pac_domiciliaciones.ff_nombre_entidad(y1.cbancar, y1.ctipban) ENTIDAD_BANCARIA_RECIBO, '
         || 'pac_prenotificaciones.ff_nombre_entidad(y1.cbancar, y1.ctipban) ENTIDAD_BANCARIA_RECIBO, '
         -- 11. 21/02/2012  JGR  0021120/0108092 - Fin
         -- Ini Bug 21318 - MDS
         || ' SUBSTR(y1.cbancar,1,4) CODIGO_BANCO_RECIBO, '
         || '''<'' || y1.cbancar|| ''>'' CBANCAR, '
         || '  (SELECT MAX(fvencim)
               FROM per_ccc
              WHERE sperson = y.persona
                AND cbancar = y1.cbancar
                AND ctipban = y1.ctipban) FECHA_VENCIMIENTO, '   -- Fin Bug 21003 - MDS
         || '        y1.nrecibo NRECIBO,'
         || '        y3.npoliza || ''-'' || y3.ncertif NPOLIZA,'
         || '        ff_desvalorfijo(8, ' || v_cidioma || ', y1.ctiprec) TIPO_RECIBO,'
         || '        f_nombre(y.persona, 1, y3.cagente) TOMADOR,'   -- Ini Bug 21003 - MDS
         || '(SELECT pe.nnumide
                      FROM per_personas pe
                     WHERE sperson = y.persona) NUM_IDENTIFICA_TOMADOR, '
         || ' f_nombre(y.asegurado, 1, y3.cagente) NOM_ASEGURADO, '
         || '(SELECT pe.nnumide
                      FROM per_personas pe
                     WHERE sperson = y.asegurado) NUM_IDENTIFICA_ASEGURADO, '
         -- Bug 29243/160483 - 04/12/2013 - AMC
         || 'f_nombre(NVL(y1.sperson,y.persona), 1, y3.cagente) PAGADOR, '
         || '(SELECT pe.nnumide
                      FROM per_personas pe
                     WHERE sperson = NVL(y1.sperson,y.persona)) NUM_IDENTIFICA_PAGADOR, '   -- Fin Bug 21003 - MDS
         -- Fi Bug 29243/160483 - 04/12/2013 - AMC
         || '        y1.fefecto FEFECTO, y1.fvencim FVENCIM, ' || '        y5.itotalr'
         || '          +(DECODE(f_parproductos_v(y3.sproduc, ''RECUNIF''),'
         || '                   2, (SELECT NVL(SUM(v2.itotalr), 0)'
         || '                         FROM adm_recunif ar, vdetrecibos_monpol v2'
         || '                        WHERE ar.nrecunif = y1.nrecibo'
         || '                          AND ar.nrecibo = v2.nrecibo'
         || '                          AND ar.nrecunif <> ar.nrecibo),'
         || '                   0)) ITOTALR,'   -- Ini Bug 21003 - MDS
         -- 18. 0025151: LCOL999-Redefinir el circuito de prenotificaciones - 0142020 - Inicio
         -- El código de prenotificación no se calculará hasta que no se genere el archivo
         || ' ''<'' || ''***************'' || ''>''  CODIGO_PRENOTIFICACION, '
              /*
              || ' ''<'' || LPAD(substr((SELECT cagente
         FROM  recibosredcom
         WHERE nrecibo=y1.nrecibo
           AND cempres=y1.cempres
           AND ctipage=2), -3), 6, ''0'') || LPAD(y3.sproduc, 6, ''0'') || LPAD(y.persona, 8, ''0'') || LPAD((select MAX(p.cnordban) from per_ccc p where p.sperson = y.persona and p.cbancar= y1.cbancar),2,''0'') || LPAD(y3.npoliza, 8, ''0'') || ''>''  CODIGO_PRENOTIFICACION, '   -- Bug 21120 - 20120228 - JLTS
              */
              -- 18. 0025151: LCOL999-Redefinir el circuito de prenotificaciones - 0142020 - Fin
         || ' NULL PROCESO, NULL FICHERO,' || '        ff_desvalorfijo(1,' || v_cidioma
         || ', f_cestrec_mv(y1.nrecibo, ' || v_cidioma || ', NULL)) ESTADO,'
         || '        ff_desvalorfijo(75, ' || v_cidioma || ', y1.cestimp) TESTIMP'
         || ', to_date( ''' || fefecto
         || ''',''ddmmyyyy'') FCORTE , NULL EST_DOMI, NULL FESTADO'
         || '  from  ('   --|| ', y2.cvalida) TESTIMP' || ', NULL EST_DOMI, NULL FESTADO' || '  from  ('
         || '         select x.persona, (x.nrecibo) recibo'   -- Ini Bug 21003 - MDS
         || ', x.asegurado'   -- Fin Bug 21003 - MDS
                           || '          from  (' || '                 select r.nrecibo'
         || '                 , decode(r.nriesgo,null'
         || '                 ,(select to2.sperson from tomadores to2 where to2.sseguro=r.sseguro and nvl(to2.nordtom,1)=1)'
         || '                 ,(select ri2.sperson from riesgos ri2 where ri2.sseguro=r.sseguro and ri2.nriesgo=r.nriesgo)'
         || '                 ) persona'   -- Ini Bug 21003 - MDS
         || ', (select sperson asegurado
from   asegurados aseg
where  aseg.sseguro = r.sseguro
and    aseg.norden = (select min(norden)
                      from asegurados
                      where sseguro = r.sseguro)) asegurado '   -- Fin Bug 21003 - MDS
         || '                 FROM recibos r, seguros s, movrecibo m'
         || '                 WHERE r.fefecto <= to_date( ''' || fefecto
         || ''',''ddmmyyyy'')'   -- Bug 20735/102170 - 29/12/2011 - JGR - Inicio
                                 --      || '                 and exists (select 1 from tipos_cuenta a, cobbancario b'
                                 --      || '                 where a.tfunc is not null and a.ctipban=b.ctipban and b.ccobban=r.ccobban)'
         || '                 and exists (select 1 from cobbancario b where b.cnotifi=1 and b.ccobban=r.ccobban)'
         || '                 AND r.cestimp = 11 '   --|| '                 AND (r.cestimp=4 '
                                                     -- OR (r.cestimp=11 AND TRUNC(FESTIMP)<= trunc(f_sysdate)))
                                                     --|| '                 AND r.ctiprec<>9'
                                                     -- Bug 20735/102170 - 29/12/2011 - JGR - Fin
         || '                 AND r.sseguro=s.sseguro AND r.nrecibo=m.nrecibo AND m.cestrec=0 AND m.fmovfin is null'
         || '                 AND r.cestaux=0 AND nvl(r.cgescob,1)=1'
         || '                 AND ((F_Parproductos_v(s.sproduc,''RECUNIF'') IN (1,3) and r.nrecibo not in (select nrecibo from adm_recunif)) '
         || '                  or (F_Parproductos_v(s.sproduc,''RECUNIF'') = 2 and 0=(select count(0) from adm_recunif a where a.nrecibo = r.nrecibo and a.nrecunif<> r.nrecibo)) '
         || '                  or ( NVL(f_parproductos_v(s.sproduc, ''RECUNIF''), -1) NOT IN(1, 2, 3)))'
         -- 23. MMM - 0027802: LCOL_MILL-No se han de notificar recibos de tipos (9, 13, 15) - QT-8147 (nota: 36305) y QT-8736 - Inicio
         || '                 AND R.CTIPREC NOT IN (9, 13, 15)'
         || '                 AND R.CBANCAR IS NOT NULL'
         || '                 AND R.CTIPCOB = 2';

      -- 23. MMM - 0027802: LCOL_MILL-No se han de notificar recibos de tipos (9, 13, 15) - QT-8147 (nota: 36305) y QT-8736 - Fin
      IF psprodom IS NOT NULL THEN
         vpas := 1020;
         v_result := v_result
                     || ' and s.sproduc in (SELECT sproduc FROM tmp_domisaux WHERE sproces='
                     || psprodom || ' AND cestado=1)';
         wsproduc := NULL;
      END IF;

      IF cempres IS NOT NULL THEN
         vpas := 1030;
         v_result := v_result || ' AND r.cempres=' || cempres;
      END IF;

      IF pdfefecto IS NOT NULL THEN
         vpas := 1040;
         v_result := v_result || ' AND r.fefecto >= to_date(' || CHR(39) || pdfefecto
                     || CHR(39) || ',''ddmmyyyy'')';
      END IF;

      IF wsproduc IS NOT NULL THEN
         vpas := 1050;
         v_result := v_result || ' AND s.sproduc=' || wsproduc;
      END IF;

      IF cramo IS NOT NULL THEN
         vpas := 1060;
         v_result := v_result || ' AND S.cramo=' || cramo;
      END IF;

      IF pccobban IS NOT NULL THEN
         vpas := 1070;
         v_result := v_result || ' AND r.ccobban=' || pccobban;
      END IF;

      IF pctipcta IS NOT NULL THEN
         vpas := 1080;
         v_result := v_result || ' AND r.ctipban=' || pctipcta;
      END IF;

      IF pfvtotar IS NOT NULL THEN
         vpas := 1090;
         v_result := v_result || ' AND SUBSTR(r.cbancar, 21, 4)=' || pfvtotar;
      END IF;

      IF pcreferen IS NOT NULL THEN
         vpas := 1100;
         v_result := v_result || ' AND ' || pcreferen
                     || '=(SELECT rebut_ini FROM cnvrecibos WHERE nrecibo = r.nrecibo)';
      END IF;

      IF pcbanco IS NOT NULL THEN
         vpas := 1110;
         v_result := v_result || ' AND exists (select 1 from cobbancario c'
                     || ' where c.ccobban=r.ccobban and c.cempres=r.cempres'
                     || ' and c.cdoment=' || pcbanco || ')';
      END IF;

      vpas := 1120;
      v_result := v_result || '              ) x'
                  || '         group by x.persona, x.nrecibo'   -- Ini Bug 21003 - MDS
                  || ', x.asegurado'   -- Fin Bug 21003 - MDS
                                    || '    ) y' || '    , recibos y1' || '    , seguros y3'
                  || '    , cobbancario y4' || '    , vdetrecibos_monpol y5'
                  || ' where y1.nrecibo = y.recibo' || ' and   y3.sseguro = y1.sseguro'
                  || ' AND   y4.ccobban = y1.ccobban' || ' AND   y4.cempres = y1.cempres'
                  || ' and   y5.nrecibo = y1.nrecibo';
-- Bug 20735/102170 - 29/12/2011 - JGR - Inicio
--      v_result :=
--         v_result || '              ) x' || '         group by x.persona' || '    ) y'
--         || '    , recibos y1' || '    , per_ccc y2' || '    , seguros y3'
--         || '    , cobbancario y4' || '    , vdetrecibos y5' || ' where y1.nrecibo = y.recibo'
--         || ' and   y2.sperson = y.persona and y2.cagente=y1.cagente and y2.cvalida=1'
--         || ' and   y2.cbancar = y1.cbancar'
--         || ' and   y2.CNORDBAN = (select max(y22.CNORDBAN) from per_ccc y22'
--         || '                      where y22.sperson=y2.sperson and y22.cagente=y2.cagente'
--         || '                      and y22.cvalida=y2.cvalida and y22.cbancar=y2.cbancar)'
--         || ' and   y3.sseguro = y1.sseguro' || ' AND   y4.ccobban = y1.ccobban'
--         || ' AND   y4.cempres = y1.cempres' || ' and   y5.nrecibo = y1.nrecibo';
-- Bug 20735/102170 - 29/12/2011 - JGR - Fin
---------------------------------------------------------
      vpas := 1130;

      IF filtradomaximo = TRUE THEN
         vpas := 1140;
         v_max_reg := f_parinstalacion_n('N_MAX_REG');

         IF v_max_reg IS NOT NULL THEN
            vpas := 1150;
            v_result := v_result || ' and rownum <= ' || v_max_reg;
         END IF;
      END IF;

      vpas := 1160;
      -- Ini Bug 21003 - MDS
      --v_result := v_result || ' ORDER BY 3,11';
      v_result := v_result || ' ORDER BY 6,24';
      -- Fin Bug 21003 - MDS
      vpas := 1170;

      FOR i IN 1 .. 5 LOOP
         v_result := REPLACE(v_result, '  ', ' ');
      END LOOP;

      vpas := 1180;
      v_max_reg := pac_log.f_log_consultas(v_result, vobj, 1, 3);
      vpas := 1190;
      RETURN v_result;
   END f_retorna_query;

   FUNCTION f_retorna_query_detalle(sproces IN NUMBER, cempres IN NUMBER, ccobban IN NUMBER)
      RETURN VARCHAR2 IS
      v_result       VARCHAR2(32767);
      vtxt           VARCHAR2(100);
   BEGIN
      -- 16. 0024801 - Inicio
      vtxt := LOWER(pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                  'SUFIJO_EMP'));

      IF vtxt IS NOT NULL THEN
         vtxt := '_' || vtxt;
      END IF;

      -- 16. 0024801 - Fin
      v_result :=
         NULL || ' SELECT pac_isqlfor.f_empresa(s.sseguro) , '
         ||   -- EMPRESA

           -- 22.0 MMM. 0027568 Error en campo Sucursal de listado previo y domiciliación ACH (86) Vida - QT8320
           --  '    (select ff_desagente(cagente) from recibosredcom where nrecibo=r.nrecibo and cempres=d.cempres and ctipage = 2) , '
         'ff_desagente(pac_redcomercial.f_busca_padre(r.cempres, NVL(r.cagente, s.cagente), NULL, NULL)),'
         -- 22.0 MMM. 0027568 Error en campo Sucursal de listado previo y domiciliación ACH (86) Vida - QT8320 - FIN
         ||   -- SUCURSAL
           '    ff_desramo(s.cramo, nvalpar) , '
         ||   -- RAMO
           '    f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, nvalpar) , '
         ||   -- PRODUCTO
           '    s.cactivi , ' ||   -- ACTIVIDAD
                                '    cb.ccobban || ''-'' || cb.descripcion , '
         ||   -- COBRADOR BANCARIO
           '    SUBSTR(cb.ncuenta,5,length(cb.ncuenta)-4) , '
         ||   -- CUENTA RECAUDADORA
              --'    (select tbanco from bancos where cbanco=SUBSTR(cb.ncuenta,1,4)) , ' || -- ENTIDAD RECAUDADORA

           --' pac_domiciliaciones.ff_nombre_entidad(r.cbancar, r.ctipban) , ' -- 11. 21/02/2012  JGR  0021120/0108092
         ' pac_prenotificaciones.ff_nombre_entidad(r.cbancar, r.ctipban) , '   -- 11. 21/02/2012  JGR  0021120/0108092
         ||   -- ENTIDAD RECAUDADORA
           '    SUBSTR(cb.ncuenta,1,4) , '
         ||   -- CODIGO BANCO RECAUDADOR
              --'    (select tcd1.ttipo from tipos_cuenta tc1, tipos_cuentades tcd1  where tc1.ctipban = tcd1.ctipban and tc1.ctipban = r.ctipban and cidioma = nvalpar), ' || -- TIPO CUENTA
           ' (SELECT ff_desvalorfijo(800049, nvalpar, ctipcc) FROM tipos_cuenta where ctipban = r.ctipban) , '
         ||   -- TIPO CUENTA

           --  '  SUBSTR(r.cbancar,5,length(r.cbancar)-4) , '
         ' ''<'' ||  SUBSTR(r.cbancar,5,length(r.cbancar)-4)|| ''>'' , '
         ||   -- NUMERO DE CUENTA

             --'    (select tbanco from bancos where cbanco=SUBSTR(r.cbancar,1,4)) , ' || -- ENTIDAD BANCARIA RECIBO
           --' pac_domiciliaciones.ff_nombre_entidad(r.cbancar, r.ctipban) , ' -- 11. 21/02/2012  JGR  0021120/0108092
         ' pac_prenotificaciones.ff_nombre_entidad(r.cbancar, r.ctipban) , '   -- 11. 21/02/2012  JGR  0021120/0108092
         ||   -- ENTIDAD BANCARIA RECIBO
           ' SUBSTR(r.cbancar,1,4) , ' ||   -- CODIGO DE BANCO

                                         --        '    r.cbancar  , '
         '   ''<'' ||   r.cbancar || ''>'' , '
         ||   -- CUENTA BANCARIA
           ' (SELECT MAX(fvencim) FROM per_ccc WHERE sperson = (SELECT sperson FROM tomadores tom WHERE tom.sseguro = r.sseguro AND tom.nordtom = (SELECT MIN(nordtom) FROM tomadores WHERE sseguro = r.sseguro)) AND cbancar = r.cbancar AND ctipban = r.ctipban) , '
         ||   -- FECHA VENCIMIENTO TARJETA
           ' r.nrecibo , ' ||   -- RECIBO
                             '    s.npoliza , '
         ||   -- POLIZA
           '  ff_desvalorfijo(8, nvalpar, r.ctiprec) , '
         ||   -- TIPO RECIBO
           '  f_nombre((SELECT sperson FROM tomadores tom WHERE tom.sseguro = r.sseguro AND tom.nordtom = (SELECT MIN(nordtom) FROM tomadores WHERE sseguro = r.sseguro)), 1, s.cagente) , '
         ||   -- TOMADOR
           '  (SELECT pe.nnumide FROM per_personas pe WHERE sperson = (SELECT sperson FROM tomadores tom WHERE tom.sseguro = r.sseguro AND tom.nordtom = (SELECT MIN(nordtom) FROM tomadores WHERE sseguro = r.sseguro)))  , '
         ||   -- NUMERO IDENTIFICACION TOMADOR
           '  f_nombre((SELECT sperson FROM asegurados aseg WHERE aseg.sseguro = r.sseguro AND aseg.norden = (SELECT MIN(norden) FROM asegurados WHERE sseguro = r.sseguro)), 1, s.cagente) , '
         ||   -- ASEGURADO
           '  (SELECT pe.nnumide FROM per_personas pe WHERE sperson = (SELECT sperson FROM asegurados aseg WHERE aseg.sseguro = r.sseguro AND aseg.norden = (SELECT MIN(norden) FROM asegurados WHERE sseguro = r.sseguro)))  , '
         ||   -- NUMERO IDENTIFICACION ASEGURADO
           '  f_nombre( nvl(r.sperson,(SELECT sperson FROM tomadores tom WHERE tom.sseguro = r.sseguro AND tom.nordtom = (SELECT MIN(nordtom) FROM tomadores WHERE sseguro = r.sseguro))), 1, s.cagente) , '
         ||   -- PAGADOR
           '  (SELECT pe.nnumide FROM per_personas pe WHERE sperson = nvl(r.sperson,(SELECT sperson FROM tomadores tom WHERE tom.sseguro = r.sseguro AND tom.nordtom = (SELECT MIN(nordtom) FROM tomadores WHERE sseguro = r.sseguro))))  , '
         ||   -- NUMERO IDENTIFICACION PAGADOR
           '   trunc(d.fefecto) , ' ||   -- FECHA EFECTO
                                      '    trunc(r.fvencim) , '
         ||   -- FECHA VENCIMIENTO
           '   (dr.itotalr + (DECODE(f_parproductos_v(s.sproduc, ''RECUNIF''), 2, (SELECT NVL(SUM(v2.itotalr), 0) FROM adm_recunif ar, vdetrecibos_monpol v2 WHERE ar.nrecunif = r.nrecibo AND ar.nrecibo = v2.nrecibo AND ar.nrecunif <> ar.nrecibo), 0))) , '
         ||   -- IMPORTE

           --'   ''<'' || LPAD(substr((SELECT cagente FROM recibosredcom WHERE nrecibo=r.nrecibo AND cempres=d.cempres AND ctipage=2), -3), 6, ''0'') || LPAD(s.sproduc, 6, ''0'') || LPAD((SELECT to2.sperson FROM tomadores to2 WHERE to2.sseguro = r.sseguro AND NVL(to2.nordtom, 1) = 1), 8, ''0'') || LPAD((select cnordban from per_ccc where sperson in (SELECT to2.sperson FROM tomadores to2 WHERE to2.sseguro = r.sseguro AND NVL(to2.nordtom, 1) = 1) and cbancar= r.cbancar),2,''0'') ||''X''|| LPAD(s.npoliza, 8, ''0'') || ''>'', '   -- Bug 21120 - 20120228 - JLTS
           --'   ''<'' || LPAD(substr((SELECT cagente FROM recibosredcom WHERE nrecibo=r.nrecibo AND cempres=d.cempres AND ctipage=2), -3), 6, ''0'') || LPAD(s.sproduc, 6, ''0'') || LPAD((SELECT to2.sperson FROM tomadores to2 WHERE to2.sseguro = r.sseguro AND NVL(to2.nordtom, 1) = 1), 8, ''0'') || LPAD((select MAX(cnordban) from per_ccc where sperson in (SELECT to2.sperson FROM tomadores to2 WHERE to2.sseguro = r.sseguro AND NVL(to2.nordtom, 1) = 1) and cbancar= r.cbancar),2,''0'') ||LPAD(s.npoliza, 8, ''0'') || ''>'', '   -- Bug 21120 - 20120228 - JLTS  -- 18. 0025151 - 0142020 (+)
         '   ''<'' || d.idnotif2 || ''>'', '   -- 18. 0025151 - 0142020 (+)
         ||   -- CODIGO MATRICULA
           ' ff_desvalorfijo(386,nvalpar,(select MAX(cvalida) from per_ccc where sperson in (SELECT to2.sperson FROM tomadores to2 WHERE to2.sseguro = r.sseguro AND NVL(to2.nordtom, 1) = 1) and cbancar= r.cbancar)), '
         ||
            -- ESTADO MATRICULA -- Bug 21120 - 20120229 - JLTS
         '   d.sproces  , ' ||   -- PROCESO

                              -- 16. 0024801 - Inicio
                              --'   pac_nombres_ficheros_lcol.f_nom_notifi(d.sproces, d.cempres, d.cdoment, d.cdomsuc, cb.ccobban), '
         '   pac_nombres_ficheros' || vtxt
         || '.f_nom_notifi(d.sproces, d.cempres, d.cdoment, d.cdomsuc, cb.ccobban), '
         -- 16. 0024801 - Fin
         ||   -- FICHERO
           '  ff_desvalorfijo(1,nvalpar,f_cestrec_mv(r.nrecibo, nvalpar, d.ffiledev )), '
         ||   -- ESTADO RECIBO
           '  ff_desvalorfijo(75, nvalpar, pac_prenotificaciones.f_estimprec(r.nrecibo,d.ffiledev)),  '
         ||   -- SUBESTADO RECIBO -- Bug 21120 - 20120229 - JLTS
           '  TRUNC(pcab.fproini),  ' ||   -- FECHA PROCESO

                                        -- 16. 0024801 - Inicio
                                        --  '  TRUNC(GREATEST(r.fefecto,r.femisio)+pac_propio_lcol.f_numdias_periodo_gracia(r.sseguro)) '
         '  TRUNC(GREATEST(r.fefecto,r.femisio)+pac_propio' || vtxt
         || '.f_numdias_periodo_gracia(r.sseguro)) '
                                                    -- 16. 0024801 - Fin
         ||   -- FECHA LIMITE CONVENIO PAGO
           'FROM '
         || '    tomadores t, seguros s, recibos r, cobbancario cb, vdetrecibos_monpol dr, detvalores dv, '
         || '    notificaciones d, parinstalacion p, titulopro ti, productos pr, domici dd, procesoscab pcab '
         || 'WHERE ' || '    t.sseguro = s.sseguro AND NVL(t.nordtom, 1) = 1 '
         || '    AND pr.sproduc = s.sproduc ' || '    AND d.sproces = ' || sproces
         || '    AND d.cempres = NVL(''' || cempres || ''', d.cempres) '
         || '    AND d.ccobban = NVL(''' || ccobban || ''', d.ccobban) '
         || '    AND cb.ccobban = d.ccobban ' || '    AND dr.nrecibo = d.nrecibo '
         || '    AND r.nrecibo = d.nrecibo ' || '    AND s.sseguro = r.sseguro '
         || '    AND dv.cvalor = 8 ' || '    AND dv.catribu = r.ctiprec '
         || '    AND dv.cidioma = nvalpar ' || '    AND p.cparame = ''IDIOMARTF'' '
         || '    AND ti.cmodali = pr.cmodali ' || '    AND ti.ctipseg = pr.ctipseg '
         || '    AND ti.ccolect = pr.ccolect ' || '    AND ti.cramo = pr.cramo '
         || '    AND ti.cidioma = dv.cidioma ' || '    AND dd.sproces(+) = d.sproces '
         || ' AND pcab.sproces = d.sproces ' || 'ORDER BY '
         || '    d.cempres, s.sproduc, d.ccobban, r.fefecto, r.nrecibo';
      RETURN v_result;
   END f_retorna_query_detalle;

   -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar productos en el proceso domiciliación
   /*******************************************************************************
   FUNCION F_INSERT_TMP_DOMISAUX
   Función que insertará en la tabla temporal los productos seleccionados para el
   proceso de domiciliación de recibos.
   Parámetros:
    Entrada :
       Pcempres  NUMBER
       Psproces  NUMBER
       Psproduc  NUMBER
       Pseleccio NUMBER

    Retorna: un NUMBER con el id del error.
   ********************************************************************************/
   FUNCTION f_insert_tmp_domisaux(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      psproduc IN NUMBER,
      pseleccio IN NUMBER)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(900) := 'pac_prenotificaciones.f_insert_tmp_domisaux';
      vpar           VARCHAR2(900)
         := NULL || ' pcempres=' || pcempres || ' psproces=' || psproces || ' psproduc='
            || psproduc || ' pseleccio=' || pseleccio;
   BEGIN
      vpas := 1000;

      -- Control parametros entrada
      IF pcempres IS NULL
         OR psproces IS NULL
         OR psproduc IS NULL
         OR pseleccio IS NULL THEN
         RETURN 140974;   --Faltan parametros por informar
      END IF;

      -- Función que debe realizar un insert en la tabla tmp_carteraux, con la información recibida.
      vpas := 1010;

      INSERT INTO tmp_domisaux
                  (sproces, sproduc, cestado)
           VALUES (psproces, psproduc, pseleccio);

      vpas := 2;
      RETURN 0;
   EXCEPTION
      --En el caso de existir el registro debe actualizar  el campo selección.
      WHEN DUP_VAL_ON_INDEX THEN
         BEGIN
            vpas := 1020;

            UPDATE tmp_domisaux
               SET cestado = pseleccio
             WHERE sproces = psproces
               AND sproduc = psproduc;

            vpas := 3;
            RETURN 0;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLERRM);
               RETURN 9000691;
         END;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLERRM);
         RETURN 9000690;
   END f_insert_tmp_domisaux;

   -- FI Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar productos en el proceso domiciliación

   -- Bug 19999 - APD - 07/11/2011 - se crea la funcion
   /*******************************************************************************
   FUNCION f_estado_domiciliacion
   Función que modifica el estado de los recibos domiciliados.
   Parámetros:
    Entrada :
       Psproces  NUMBER
       pcestrec  NUMBER : Estado validacion per_ccc

    Retorna: un NUMBER con el id del error.
   ********************************************************************************/
   FUNCTION f_estado_domiciliacion(
      pcempres IN NUMBER DEFAULT pac_md_common.f_get_cxtempresa,
      psproces IN NUMBER,
      pnrecibo IN NUMBER,
      pcestrec IN NUMBER,
      pnum_ok OUT NUMBER,
      pnum_ko OUT NUMBER)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(900) := 'pac_prenotificaciones.f_estado_domiciliacion';
      vpar           VARCHAR2(900)
         := NULL || ' pcempres=' || pcempres || ' psproces=' || psproces || ' pnrecibo='
            || pnrecibo || ' pcestrec=' || pcestrec;

      CURSOR c_dom(psproces NUMBER, pnrecibo NUMBER) IS
         SELECT *
           FROM notificaciones
          WHERE sproces = psproces
            AND(nrecibo = pnrecibo
                OR pnrecibo IS NULL)
            AND(cerror = 0
                OR   --> 25/11/2011 JGR 0020037: Parametrización de Devoluciones (Necesario para LCOL)
                  cerror IS NULL);   --> 25/11/2011 JGR 0020037: Parametrización de Devoluciones (Necesario para LCOL)

      -- v_sperson      riesgos.sperson%TYPE; -- 19. 0026956 - 0144367 - Inicio
      num_err        NUMBER;
      lnliqlin       NUMBER;
      lnliqmen       NUMBER;
      lsmovagr       NUMBER;
      lcerror        notificaciones.cerror%TYPE;
      xnprolin       NUMBER;
      texto          VARCHAR2(400);
      salir          EXCEPTION;
   BEGIN
      vpas := 1000;

      -- Control parametros entrada
      IF psproces IS NULL
         OR pcestrec IS NULL THEN
         num_err := 140974;   --Faltan parametros por informar
         RAISE salir;
      END IF;

      vpas := 1010;
      pnum_ok := 0;
      pnum_ko := 0;
      lsmovagr := 0;
      vpas := 1030;

      FOR v_dom IN c_dom(psproces, pnrecibo) LOOP
         -- Cobrem el rebut
         vpas := 1040;
         lnliqmen := NULL;
         lnliqlin := NULL;
         num_err := 0;

         -- BUG 0019999 - 14/11/2011 - JMF
         IF pcestrec <> 0 THEN   -- notificaciones
            vpas := 1050;

            -- 19. 0026956: Detectado que en algunos casos no agrupa bien los recibos de NOTIFIACIONES - 0144367 - Inicio
            /*
            SELECT MAX(b.sperson)
              INTO v_sperson
              FROM recibos a, riesgos b
             WHERE a.nrecibo = v_dom.nrecibo
               AND b.sseguro = a.sseguro
               AND(b.nriesgo = a.nriesgo
                   OR b.nriesgo = (SELECT MAX(b1.nriesgo)
                                     FROM riesgos b1
                                    WHERE b1.nriesgo = b.nriesgo));

            IF v_sperson IS NOT NULL THEN
               vpas := 1060;

               UPDATE per_ccc
                  SET cvalida = pcestrec
                WHERE sperson = v_sperson
                  -- AND cagente = v_dom.cagente -- 6.0 20285/104346: LCOL898 - Interface - Recaudos
                  AND cbancar = v_dom.cbancar
                  AND NVL(cvalida, -1) <> NVL(pcestrec, -1);
            END IF;
            */
            UPDATE per_ccc
               SET cvalida = pcestrec
             WHERE sperson = v_dom.smovrec   -- Realmente contiene el valor de SPERSON
               AND cbancar = v_dom.cbancar
               AND ctipban = v_dom.ctipban
               AND NVL(cvalida, -1) <> NVL(pcestrec, -1);
         -- 19. 0026956: Detectado que en algunos casos no agrupa bien los recibos de NOTIFIACIONES - 0144367 - Final
         END IF;

         -- Si ha anat be fem commit, sino rollback
         -- per cada registre, i guardem el resultat
         -- a notificaciones
         vpas := 1070;
         lcerror := num_err;   -- Es guarda per updatar a notificaciones

         IF num_err = 0 THEN
            pnum_ok := pnum_ok + 1;
            COMMIT;
         ELSE
            pnum_ko := pnum_ko + 1;
            ROLLBACK;
            xnprolin := NULL;
            texto := f_axis_literales(num_err);
            num_err := f_proceslin(psproces, texto, v_dom.nrecibo, xnprolin);
            COMMIT;
         END IF;

         vpas := 6;

         BEGIN
            vpas := 1090;

            UPDATE notificaciones
               -- 19. 0026956 - 0144367 - Inicio
            SET
                -- smovrec = v_sperson,
                cerror = lcerror
             -- 19. 0026956 - 0144367 - Final
            WHERE  sproces = psproces
               AND nrecibo = v_dom.nrecibo;

            COMMIT;
         EXCEPTION
            WHEN OTHERS THEN
               xnprolin := NULL;
               texto := f_axis_literales(102922);
               texto := SUBSTR(texto || ' ' || SQLERRM, 1, 120);
               num_err := f_proceslin(psproces, texto, v_dom.nrecibo, xnprolin);
               COMMIT;
               RETURN 102922;
         END;
      END LOOP;

      vpas := 1100;
      RETURN 0;
   EXCEPTION
      WHEN salir THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, f_axis_literales(num_err));
         RETURN num_err;
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_estado_domiciliacion;

   FUNCTION f_domiciliar(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pfefecto IN DATE,
      pffeccob IN DATE,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliación
      psprodom IN NUMBER,
      -- FI Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliación
      -- BUG 18825 - 19/07/2011 - JMP
      pccobban IN NUMBER,
      pcbanco IN NUMBER,
      pctipcta IN NUMBER,
      pfvtotar IN VARCHAR2,
      pcreferen IN VARCHAR2,
      pdfefecto IN DATE,
      -- FIN BUG 18825 - 19/07/2011 - JMP
      pidioma IN NUMBER,
      pnok OUT NUMBER,
      pnko OUT NUMBER,
      ppath OUT VARCHAR2,
      nommap1 OUT VARCHAR2,   --Path Completo Fichero de map 318,
      nommap2 OUT VARCHAR2,   --Path Completo Fichero de map 347,
      nomdr OUT VARCHAR2,   --Path Completo Fichero de DR,
      vsproces OUT NUMBER)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(900) := 'pac_prenotificaciones.f_domiciliar';
      vpar           VARCHAR2(900)
         := NULL || ' psproces=' || psproces || ' pcempres=' || pcempres || ' pfefecto='
            || pfefecto || ' pffeccob=' || pffeccob || ' pcramo=' || pcramo || ' psproduc='
            || psproduc || ' psprodom=' || psprodom || ' pccobban=' || pccobban || ' pcbanco='
            || pcbanco || ' pctipcta=' || pctipcta || ' pfvtotar=' || pfvtotar
            || ' pcreferen=' || pcreferen || ' pdfefecto=' || pdfefecto || ' pidioma='
            || pidioma;
      ttexto         VARCHAR2(20) := 'PRENOTIFICACIONES';
      ttexto2        VARCHAR2(400);
      tprocesc       VARCHAR2(120);
      vnumerr        NUMBER(10) := 0;
      vcempres       empresas.cempres%TYPE;
      vcmodali       productos.cmodali%TYPE;
      vctipseg       productos.ctipseg%TYPE;
      vccolect       productos.ccolect%TYPE;
      vcramo         productos.cramo%TYPE;   -- BUG 15146 - PFA- Error selección domiciliación por productos
      vctipemp       empresas.ctipemp%TYPE;
      --   smapead        NUMBER;
      vtparpath      map_cabecera.tparpath%TYPE;
   --vcestpre       VARCHAR2(2); -->10. 0021358: LCOL898-Error al cambiar el estado -- 12. 0021120/0108895
   BEGIN
      vpas := 1000;

      IF psproces IS NULL THEN
         vpas := 1010;
         ttexto2 := f_axis_literales(102253, pidioma);   -- ' Cartera: '
         tprocesc := TO_CHAR(f_sysdate, 'dd-mm-yyyy hh24:mi') || '  ' || ttexto2 || '  '
                     || pcempres || '  ' || TO_CHAR(pfefecto, 'yyyy mm');
         vpas := 1020;
         vnumerr := f_procesini(f_user, pcempres, ttexto, tprocesc, vsproces);

         IF vnumerr <> 0 THEN
            RETURN vnumerr;
         END IF;

         IF psproduc IS NOT NULL THEN
            BEGIN
               vpas := 1030;

               SELECT cmodali, ctipseg, ccolect,
                      cramo
                 INTO vcmodali, vctipseg, vccolect,
                      vcramo   -- BUG 15146 - PFA- Error selección domiciliación por productos
                 FROM productos
                WHERE sproduc = psproduc;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  p_tab_error(f_sysdate, f_user, vobj, vpas, 'Producto inexistente',
                              SQLERRM || ' ' || SQLCODE);
                  RETURN 100503;   --Producto inexistente
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, vobj, vpas,
                              'Error al leer la tabla PRODUCTOS', SQLERRM || ' ' || SQLCODE);
                  RETURN 102705;   --Error al leer la tabla PRODUCTOS
            END;
         END IF;

         -- BUG 15146 - PFA- Error selección domiciliación por productos
         vpas := 1040;

         IF pcramo IS NOT NULL THEN
            vcramo := pcramo;
         END IF;

         -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliación
         IF psprodom IS NOT NULL THEN
            vpas := 1050;

            INSERT INTO domisaux
                        (sproces, cramo, cmodali, ctipseg, ccolect)
               SELECT vsproces, p.cramo, p.cmodali, p.ctipseg, p.ccolect
                 FROM productos p, tmp_domisaux t
                WHERE p.sproduc = t.sproduc
                  AND t.sproces = psprodom
                  AND t.cestado = 1;
         ELSE
            vpas := 1060;

            INSERT INTO domisaux
                        (sproces, cramo, cmodali, ctipseg, ccolect)
               SELECT vsproces, p.cramo, p.cmodali, p.ctipseg, p.ccolect
                 FROM productos p
                WHERE p.sproduc = NVL(psproduc, p.sproduc)
                  AND p.cramo = NVL(vcramo, p.cramo)
                  AND p.cmodali = NVL(vcmodali, p.cmodali)
                  AND p.ctipseg = NVL(vctipseg, p.ctipseg)
                  AND p.ccolect = NVL(vccolect, p.ccolect);
         END IF;

         -- FI Bug 15750 - FAL - 27/08/2010

         -- Fi BUG 15146 - PFA- Error selección domiciliación por productos
         vpas := 1070;
         vnumerr := pac_prenotificaciones.f_domiciliar_notifica(vsproces, pcempres, pfefecto,
                                                                pffeccob, vcramo, vcmodali,
                                                                vctipseg, vccolect, pccobban,
                                                                pcbanco, pctipcta, pfvtotar,
                                                                pcreferen, pdfefecto, pidioma,
                                                                nomdr, pnok, pnko);

         IF vnumerr <> 0 THEN
            RETURN vnumerr;
         END IF;
      --El procés està informat
      ELSE
         --comprobar si existeix el proces
         BEGIN
            vpas := 1080;

            SELECT DISTINCT (sproces)
                       INTO vsproces
                       FROM notificaciones
                      WHERE sproces = psproces;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_tab_error(f_sysdate, f_user, vobj, vpas, 'Proceso inexistente',
                           SQLERRM || ' ' || SQLCODE);
               RETURN 103778;   --proceso inexistente
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobj, vpas,
                           'Error al leer en la tabla notificaciones',
                           SQLERRM || ' ' || SQLCODE);
               RETURN 112318;   --Error al leer en la tabla notificaciones;
         END;

         IF pcempres IS NOT NULL THEN
            BEGIN
               vpas := 1090;

               SELECT ctipemp
                 INTO vctipemp
                 FROM empresas
                WHERE cempres = pcempres;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  p_tab_error(f_sysdate, f_user, vobj, vpas, 'Empresa inexistente',
                              SQLERRM || ' ' || SQLCODE);
                  RETURN 100501;   --Empresa inexistente
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, vobj, vpas,
                              'Error al leer en la tabla EMPRESAS', SQLERRM || ' ' || SQLCODE);
                  RETURN 103290;   --Error al leer en la tabla EMPRESAS;
            END;
         ELSE
            BEGIN
               vpas := 1100;

               SELECT DISTINCT (cempres)
                          INTO vcempres
                          FROM notificaciones
                         WHERE sproces = psproces;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  p_tab_error(f_sysdate, f_user, vobj, vpas, 'Empresa inexistente',
                              SQLERRM || ' ' || SQLCODE);
                  RETURN 100501;   --Empresa inexistente
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, vobj, vpas,
                              'Error al leer en la tabla notificaciones',
                              SQLERRM || ' ' || SQLCODE);
                  RETURN 112318;   --Error al leer en la tabla notificaciones;
            END;

            BEGIN
               vpas := 1110;

               SELECT ctipemp
                 INTO vctipemp
                 FROM empresas
                WHERE cempres = vcempres;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  p_tab_error(f_sysdate, f_user, vobj, vpas, 'Empresa inexistente',
                              SQLERRM || ' ' || SQLCODE);
                  RETURN 100501;   --Empresa inexistente
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, vobj, vpas,
                              'Error al leer en la tabla EMPRESAS', SQLERRM || ' ' || SQLCODE);
                  RETURN 103290;   --Error al leer en la tabla EMPRESAS;
            END;
         END IF;

          -- 12. 0021120: LCOL897-LCOL_A001-Resumen y detalle ... NOTA:0108895 - Inicio
          -->10. 0021358: LCOL898-Error al cambiar el estado ... Inicio
          --vpas := 1120;
          --vnumerr := pac_prenotificaciones.f_domrecibos(vctipemp, pidioma, psproces, nomdr);
          -- No se han de regenerar pronotificaciones cerradas
          /*
          SELECT DECODE(SUM(DECODE((SELECT cestimp
                                      FROM recibos r
                                     WHERE r.nrecibo = n.nrecibo), 12, 1, 0)),
                        0, 'C',   -- Cerrado
                        'A')   -- Abierto
            INTO vcestpre
            FROM notificaciones n
           WHERE n.sproces = psproces;
         */

         --IF vcestpre = 'C' THEN
         IF f_valida_prenoti_cobban(pcempres, NULL, NULL, psproces) = 0 THEN   -- PRENOTIFICACION CERRADA
            -->11. 21/02/2012  JGR  0021120/0108092
            vpas := 1118;
            -- Proceso de Prenotificación cerrado. No se permite regenerar archivo.
            vnumerr := 9903305;
         ELSE
            vpas := 1120;
            vnumerr := pac_prenotificaciones.f_domrecibos(vctipemp, pidioma, psproces, nomdr);
         END IF;

         -- 12. 0021120: LCOL897-LCOL_A001-Resumen y detalle ... NOTA:0108895 - Fin

         -->10. 0021358: LCOL898-Error al cambiar el estado ... Fin
         IF vnumerr <> 0 THEN
            RETURN vnumerr;
         END IF;
      END IF;

      BEGIN
         --buscar el path del fitxers
         vpas := 1130;

         SELECT tparpath
           INTO vtparpath
           FROM map_cabecera
          WHERE cmapead = '318';
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, vobj, vpas, 'Dato de cabecera inexistente',
                        SQLERRM || ' ' || SQLCODE);
            RETURN 151539;   --Error al buscar la información de la cabecera del fichero
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobj, vpas,
                        'Error al leer en la tabla MAP_CABECERA', SQLERRM || ' ' || SQLCODE);
            RETURN 151539;   --Error al buscar la información de la cabecera del fichero
      END;

      vpas := 1140;
      ppath := f_parinstalacion_t(vtparpath);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLERRM || ' ' || SQLCODE);
         RETURN -1;
   END f_domiciliar;

   FUNCTION f_get_domiciliacion(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pidioma IN NUMBER,
      psquery OUT VARCHAR2,
      psprodom IN NUMBER DEFAULT NULL,
      -- BUG 18825 - 19/07/2011 - JMP
      pccobban IN NUMBER DEFAULT NULL,
      pcbanco IN NUMBER DEFAULT NULL,
      pctipcta IN NUMBER DEFAULT NULL,
      pfvtotar IN VARCHAR2 DEFAULT NULL,
      pcreferen IN VARCHAR2 DEFAULT NULL,
      pdfefecto IN DATE DEFAULT NULL)
      -- FIN BUG 18825 - 19/07/2011 - JMP
   RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(900) := 'pac_prenotificaciones.f_get_domiciliacion';
      vpar           VARCHAR2(900)
         := NULL || ' psproces=' || psproces || ' pcempres=' || pcempres || ' pcramo='
            || pcramo || ' psproduc=' || psproduc || ' pfefecto=' || pfefecto || ' pidioma='
            || pidioma || ' psprodom=' || psprodom || ' pccobban=' || pccobban || ' pcbanco='
            || pcbanco || ' pctipcta=' || pctipcta || ' pfvtotar=' || pfvtotar
            || ' pcreferen=' || pcreferen || ' pdfefecto=' || pdfefecto;
      vcramo         productos.cramo%TYPE;
      vcmodali       productos.cmodali%TYPE;
      vctipseg       productos.ctipseg%TYPE;
      vccolect       productos.ccolect%TYPE;
      vsproces       notificaciones.sproces%TYPE;
      v_max_reg      parinstalacion.nvalpar%TYPE;
      xsproces       notificaciones.sproces%TYPE;
      vtxt           VARCHAR2(100);   -- 16. 0024801
   BEGIN
      vpas := 1000;
      v_max_reg := f_parinstalacion_n('N_MAX_REG');

      IF psproces IS NULL THEN
         IF pcramo IS NOT NULL THEN
            vcramo := pcramo;
         END IF;

         IF psproduc IS NOT NULL THEN
            BEGIN
               vpas := 1010;

               SELECT cramo, cmodali, ctipseg, ccolect
                 INTO vcramo, vcmodali, vctipseg, vccolect
                 FROM productos
                WHERE sproduc = psproduc;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  p_tab_error(f_sysdate, f_user, vobj, vpas, 'Producto inexistente',
                              SQLERRM || ' ' || SQLCODE);
                  RETURN 100503;   --Producto inexistente
               WHEN OTHERS THEN
                  p_tab_error
                             (f_sysdate, f_user, vobj, vpas,
                              'Error al leer la
                            tabla PRODUCTOS', SQLERRM || ' ' || SQLCODE);
                  RETURN 102705;   --Error al leer la tabla PRODUCTOS
            END;
         END IF;

         vpas := 1020;
         psquery := pac_prenotificaciones.f_retorna_query(TO_CHAR(pfefecto, 'ddmmyyyy'),
                                                          vcramo, psproduc, pcempres, psprodom,
                                                          TRUE,   -- BUG 18825 - 19/07/2011 - JMP
                                                          pccobban, pcbanco, pctipcta,
                                                          pfvtotar, pcreferen,
                                                          TO_CHAR(pdfefecto, 'ddmmyyyy'));   -- FIN BUG 18825 - 19/07/2011 - JMP
      ELSE
         vpas := 1030;
                  -- 6.0 20285/104346: LCOL898 - Interface - Recaudos - Inicio
                  /*
                  psquery :=
                     'select D.cempres empresa, f_desproducto_T(D.cramo,D.cmodali,D.ctipseg,D.ccolect,1,'
                     || pidioma
                     || ') producto, null CODBANCAR, C.ncuenta cobrador, D.nrecibo, S.npoliza,  '
                     || 'DV.tatribu tipo_recibo, null TOMADOR, R.fefecto, R.fvencim, R.cbancar,
                     DR.itotalr  +  (decode(f_parproductos_v(s.sproduc,''RECUNIF''),2, (SELECT NVL(SUM(v2.itotalr), 0)
                            FROM adm_recunif ar, vdetrecibos v2
                            WHERE ar.nrecunif = r.nrecibo
                              AND ar.nrecibo = v2.nrecibo
                              AND ar.nrecunif <> ar.nrecibo) ,0)) itotalr,
                     c.ctipban ctipban_cobra, r.ctipban ctipban_cban,  D.sproces proceso, '
         --            || 'LTRIM(PAC_NOMBRES_FICHEROS.f_nom_domici(d.sproces,d.cempres,d.cdoment,d.cdomsuc),''_'') fichero, '
                     || ' pac_nombres_ficheros_lcol.f_nom_notifi(D.sproces, D.cempres, d.cdoment, d.cdomsuc, d.ccobban) fichero,'
         --
                     || 'ff_desvalorfijo(383, ' || pidioma || ', f_cestrec_mv(r.nrecibo, ' || pidioma
                     || ', null)) estado, ' || 'ff_desvalorfijo(386, ' || pidioma
                     || ', xx.cvalida) testimp, ' || 'ff_desvalorfijo(800035, ' || pidioma
                     || ', dd.cestado) est_domi, dd.festado ' || 'from notificaciones D, seguros S, '
                     || 'detvalores DV, recibos R, cobbancario C, vdetrecibos DR, domici dd, per_ccc xx '
                     || 'where D.sproces = ' || psproces || ' and D.sseguro = S.sseguro and '
                     || 'DV.cvalor = 8 and DV.catribu = R.ctiprec and DV.cidioma = ' || pidioma
                     || ' and R.nrecibo = D.nrecibo and '
                     || 'R.sseguro = S.sseguro and D.ccobban = C.ccobban and '
                     || 'Dr.nrecibo = R.nrecibo  ' || 'and dd.sproces(+) = d.sproces '
                     || ' and xx.sperson(+)=D.smovrec' || ' and xx.cbancar(+)=D.cbancar'
                     || ' and xx.cagente(+)=D.cagente' || ' order by D.cempres, S.npoliza, D.nrecibo ';
                  */
                  -- 6.0 20285/104346: LCOL898 - Interface - Recaudos - Fin

         -- BUG 21003 - MDS - 25/01/2012
         -- añadir variables sucursal,ramo,actividad,entidad_bancaria,codigo_banco,tipo_cuenta
         -- numero_cuenta,fecha_vencimientotjt
         -- numide_tomador,asegurado,numide_asegurado,pagador,numide_pagador
         -- codi_prenotificacion,codi_redbancaria
         -- Ponerlos a NULL, ya que en principio no los utiliza la pantalla

         -- 16. 0024801 - Inicio
         vtxt := LOWER(pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                     'SUFIJO_EMP'));

         IF vtxt IS NOT NULL THEN
            vtxt := '_' || vtxt;
         END IF;

         -- 16. 0024801 - Fin
         psquery :=
            'select D.cempres empresa, NULL sucursal, NULL ramo, f_desproducto_T(D.cramo,D.cmodali,D.ctipseg,D.ccolect,1,'
            || pidioma
            || ') producto, NULL actividad, null CODBANCAR, SUBSTR(C.ncuenta,5,length(C.ncuenta)-4) cobrador, NULL entidad_bancaria, NULL codigo_banco, NULL TIPO_DE_CUENTA, NULL NUMERO_DE_CUENTA_RECIBO, NULL ENTIDAD_BANCARIA_RECIBO, NULL CODIGO_BANCO_RECIBO, R.cbancar CBANCAR, NULL fecha_vencimientotjt, D.nrecibo, S.npoliza,  '
            || 'DV.tatribu tipo_recibo, null TOMADOR, NULL numide_tomador, NULL asegurado, NULL numide_asegurado, NULL pagador, NULL numide_pagador,  R.fefecto, R.fvencim,
            DR.itotalr  +  (decode(f_parproductos_v(s.sproduc,''RECUNIF''),2, (SELECT NVL(SUM(v2.itotalr), 0)
                   FROM adm_recunif ar, vdetrecibos_monpol v2
                   WHERE ar.nrecunif = r.nrecibo
                     AND ar.nrecibo = v2.nrecibo
                     AND ar.nrecunif <> ar.nrecibo) ,0)) itotalr,
            NULL CODIGO_PRENOTIFICACION, D.sproces proceso, '
            -- 16. 0024801 - Inicio
            -- || ' pac_nombres_ficheros_lcol.f_nom_notifi(D.sproces, D.cempres, d.cdoment, d.cdomsuc, d.ccobban) fichero,'
            || ' pac_nombres_ficheros' || vtxt
            || '.f_nom_notifi(D.sproces, D.cempres, d.cdoment, d.cdomsuc, d.ccobban) fichero,'
            -- 16. 0024801 - Fin
            || 'ff_desvalorfijo(383, ' || pidioma || ', f_cestrec_mv(r.nrecibo, ' || pidioma
            || ', null)) estado, ' || 'ff_desvalorfijo(386, ' || pidioma
            || ', (SELECT MAX(xx.cvalida) FROM per_ccc xx '
            || '     WHERE xx.sperson = d.smovrec ' || '       AND xx.cbancar = d.cbancar '
            || '    )) testimp, null fcorte, '   -- GAG 11/02/2012
            || 'ff_desvalorfijo(800035, ' || pidioma || ', dd.cestado) est_domi, dd.festado '
            || 'from notificaciones D, seguros S, '
            || 'detvalores DV, recibos R, cobbancario C, vdetrecibos_monpol DR, domici dd '
            || 'where D.sproces = ' || psproces || ' and D.sseguro = S.sseguro and '
            || 'DV.cvalor = 8 and DV.catribu = R.ctiprec and DV.cidioma = ' || pidioma
            || ' and R.nrecibo = D.nrecibo and '
            || 'R.sseguro = S.sseguro and D.ccobban = C.ccobban and '
            || 'Dr.nrecibo = R.nrecibo  ' || 'and dd.sproces(+) = d.sproces '
            || ' order by D.cempres, S.npoliza, D.nrecibo ';

         IF v_max_reg IS NOT NULL THEN
            vpas := 1040;

            IF INSTR(psquery, 'order by', -1, 1) > 0 THEN
               -- se hace de esta manera para mantener el orden de los registros
               psquery := 'select * from (' || psquery || ') where rownum <= ' || v_max_reg;
            ELSE
               psquery := psquery || ' and rownum <= ' || v_max_reg;
            END IF;
         END IF;
      END IF;

      vpas := 1050;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 9001250;   --Error al recuperar les dades dels rebuts
   END f_get_domiciliacion;

   FUNCTION ff_nombre_entidad(pcbancar VARCHAR2, pctipban NUMBER)
      RETURN VARCHAR IS
      vpas           NUMBER;
      vobj           VARCHAR2(900) := 'pac_prenotificaciones.ff_nombre_entidad';
      vpar           VARCHAR2(900)
                            := 'parametros: pcbancar=' || pcbancar || ' pctipban=' || pctipban;
      vnombanc       bancos.tbanco%TYPE;
      vini           tipos_cuenta.pos_entidad%TYPE;
      vlong          tipos_cuenta.long_entidad%TYPE;
   BEGIN
      vpas := 1000;

      SELECT pos_entidad, long_entidad
        INTO vini, vlong
        FROM tipos_cuenta
       WHERE ctipban = pctipban;

      vpas := 1010;

      SELECT tbanco
        INTO vnombanc
        FROM bancos
       WHERE cbanco = TO_NUMBER(SUBSTR(pcbancar, vini, vlong));

      RETURN vnombanc;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, 'Error generic ' || vpar,   -- 11. 21/02/2012  JGR  0021120/0108092
                     SQLERRM || ' ' || SQLCODE);
         RETURN NULL;
   END ff_nombre_entidad;

   /*************************************************************************
      Actualiza los recibos despues de la confirmación/rechazo de las notificaciones
      param in p_sproces   : Id. del proceso
      return               : 0.-OK, otro.- error
   -- BUG 0019894 - 12/01/2012 - JMF
   *************************************************************************/
   FUNCTION f_actrecibos_notificados(p_sproces IN NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(500) := 'pac_prenotificaciones.f_actrecibos_notificados';
      vpas           NUMBER := 1;
      vpar           VARCHAR2(500) := p_sproces;
      n_retorno      NUMBER;
      vtextobs       agd_apunte.tapunte%TYPE;   --> 11. 21/02/2012  JGR  0021120/0108092
      vtrechazo      detrechazo_banco.trechazo%TYPE;   -- 17. 0025151: LCOL999-Redefinir el circuito de prenotificaciones
      vtiprechazo    detvalores.tatribu%TYPE;   -- 17. 0025151: LCOL999-Redefinir el circuito de prenotificaciones

      CURSOR c1 IS
         SELECT n.*
                --, DECODE(n.cnotest, 0, 11, 1, 4) cestimp   --> 15. 30/11/2012 ECP  24672/130762 --> 17. 06/03/2012 - 0025151
           --DECODE(n.cnotest, 0, 4, 1, 11) cestimp   -->11. 21/02/2012  JGR  0021120/0108092
         FROM   notificaciones n
          WHERE sproces = p_sproces
            AND n.tfiledev IS NOT NULL   -- 13. AXIS4227 21795: LCOL_A001-Modif.prenotificaciones - 0111022
            AND cnotest IN(1, 0);

      -- 17. 0025151 - Inicio
      vcestimp       recibos.cestimp%TYPE;

      /*************************************************************************
         Devuelve el CESTIMP que deberá tener el recibo despues del motivo de
         confirmación/rechazo de las notificaciones
         pcempres     : Empresa
         pccobban     : Código de cobrador bancario
         pcdomerr     : Código de rechazo
         return       : El cestimp que deberá tener el recibo según motivo de rechazo
      *************************************************************************/
      FUNCTION f_get_cestimp(pcempres NUMBER, pccobban NUMBER, pcdomerr VARCHAR2)
         RETURN NUMBER IS
         vctiprechazo   codrechazo_banco.ctiprechazo%TYPE;
         vcestimp       recibos.cestimp%TYPE := 5;
         vpasexec       NUMBER(8) := 1;
         vparam         VARCHAR2(200)
            := 'pccobban=' || pccobban || '; pcempres=' || pcempres || '; pcdomerr='
               || pcdomerr;
         vobject        VARCHAR2(200) := 'PAC_DOMIS.F_GET_CESTIMP';
      BEGIN
         vpasexec := 10;

         IF NVL(pcdomerr, 0) = 0 THEN   --> Error 0
            vpasexec := 20;
            vcestimp := 4;
         ELSE
            BEGIN
               vpasexec := 30;

               SELECT ctiprechazo
                 INTO vctiprechazo
                 FROM codrechazo_banco
                WHERE cempres = pcempres
                  AND ccobban = pccobban
                  AND crechazo = pcdomerr;

               vpasexec := 40;

               IF vctiprechazo = 10 THEN   --> Causal Permanente
                  vcestimp := 13;   --> Notificacion rechazada
               ELSE   --> Causal Temporal
                  vcestimp := 11;   --> Pendiente prenotificar
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vcestimp := 11;   --> Pendiente prenotificar
               WHEN OTHERS THEN
                  -- 9905078 - Error al leer la tabla codrechazo_banco
                  vcestimp := 13;   --> Notificacion rechazada
                  p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                              f_axis_literales(9905078) || ' ' || SQLERRM);
            END;
         END IF;

         RETURN vcestimp;
      END f_get_cestimp;
   -- 17. 0025151 - Final
   BEGIN
      n_retorno := 0;
      vpas := 100;

      FOR f1 IN c1 LOOP
         BEGIN
            vcestimp := f_get_cestimp(f1.cempres, f1.ccobban, f1.cnoterr);   --> 17. 06/03/2012  JGR  0025151 - Inicio
            -- notifica 1=ok --> rebut 4=Pendiente domiciliación
            -- notifica 0=KO --> rebut 12=Rechazo prenotificación
            vpas := 105;
            -- 21.0 0027411: Error al generar más de un número de matrícula - QT-8145 - Inicio
            /*
            --> 5. 0020735: Introduccion de cuenta bancaria - Inicio
            -- Modifica el estado de ese recibo
            --UPDATE recibos
            --   SET cestimp = DECODE(f1.cnotest, 1, 4, 0, 12)
            -- WHERE nrecibo = f1.nrecibo
            --   AND cbancar = f1.cbancar
            --   AND cestimp = 11;
            UPDATE recibos
                  -- AFM : 26/01/2012
                  --SET cestimp = DECODE(f1.cnotest, 1, 4, 0, 13)
                  --SET cestimp = DECODE(f1.cnotest, 0, 4, 1, 11) -->11. 21/02/2012  JGR  0021120/0108092
               -- 17. 0025151 - Inicio
               -- SET cestimp = f1.cestimp   -->11. 21/02/2012  JGR  0021120/0108092
            SET cestimp = vcestimp
             -- 17. 0025151 - Final
            WHERE  nrecibo = f1.nrecibo
               AND cbancar = f1.cbancar;

            --   AND cestimp = 12; -->11. 21/02/2012  JGR  0021120/0108092

            --> 5. 0020735: Introduccion de cuenta bancaria - Fin
            IF f1.smovrec IS NOT NULL THEN   -- SMOVREC = SPERSON --> Si viene informado
               -- Otros recibos de la persona/cuenta, notificados posteriormente
               vpas := 110;

               --> 5. 0020735: Introduccion de cuenta bancaria - Inicio
               --UPDATE recibos x
               --   SET x.cestimp = DECODE(f1.cnotest, 1, 4, 0, 12)
               -- WHERE EXISTS(SELECT *
               --                FROM recibos a, riesgos b
               --               WHERE a.nrecibo = x.nrecibo
               --                 AND a.cbancar = f1.cbancar
               --                 AND b.sseguro = a.sseguro
               --                 AND(b.nriesgo = a.nriesgo
               --                     OR b.nriesgo = (SELECT MAX(b1.nriesgo)
               --                                       FROM riesgos b1
               --                                      WHERE b1.nriesgo = b.nriesgo))
               --                 AND b.sperson = f1.smovrec)
               --   AND cestimp = 11;

               --> 5. 0020735: Introduccion de cuenta bancaria - Fin

               -->10. 0021358: LCOL898-Error al cambiar el estado ... Inicio
                  -- 17. 0025151 -- Fin
               UPDATE recibos a
                     --SET a.cestimp = DECODE(f1.cnotest, 0, 4, 1, 11) -->11. 21/02/2012  JGR  0021120/0108092
                  -- SET a.cestimp = f1.cestimp   -->11. 21/02/2012  JGR  0021120/0108092 -- 17. 0025151 (-)
               SET a.cestimp = vcestimp   -- 17. 0025151 (-)
                WHERE a.cbancar = f1.cbancar
                  AND a.nrecibo != f1.nrecibo   -- 17. 0025151 (+)
                  AND((a.nriesgo IS NULL
                       AND EXISTS(SELECT 1
                                    FROM tomadores b
                                   WHERE b.sperson = f1.smovrec
                                     AND b.sseguro = a.sseguro))
                      OR(a.nriesgo IS NOT NULL
                         AND EXISTS(SELECT 1
                                      FROM riesgos b
                                     WHERE b.sperson = f1.smovrec
                                       AND b.nriesgo = a.nriesgo
                                       AND b.sseguro = a.sseguro)));

               -- notifica 0=OK --> rebut 4=Pendiente domiciliación
               -- notifica 1=KO --> rebut 11=Pendiente prenotificación (1a fase)
               -- notifica 1=KO --> rebut 13=Rechazo prenotificación (2a fase)
               -- Para una segunda fase se hará que dependiendo el tipo de rechazo
               -- grabemos el cestimp 11 o 13, para primera fase siempre 11.

               -->10. 0021358: LCOL898-Error al cambiar el estado ... Fin
               vpas := 115;

               UPDATE per_ccc
                  -- AFM : 26/01/2012
                  -- SET cvalida = DECODE(f1.cnotest, 1, 4, 0, 3)
               SET cvalida = DECODE(f1.cnotest, 0, 4, 1, 3)
                WHERE sperson = f1.smovrec
                  -- AND cagente = f1.cagente -- 6.0 20285/104346: LCOL898 - Interface - Recaudos
                  AND cbancar = f1.cbancar
                  AND cvalida = 2;
            END IF;
            */
            p_actrecibos_x_matricula(f1.nrecibo, vcestimp);

            -- 21.0 0027411: Error al generar más de un número de matrícula - QT-8145 - Final

            -- ACC canivs
            -- 11. 21/02/2012  JGR  0021120/0108092 - Inicio
            -- Prenotificación respuesta #1# de recibo #2# para cuenta o tarjeta #3# - #4#.
            BEGIN
               vpas := 116;
               vtextobs := f_axis_literales(9903308, pac_md_common.f_get_cxtidioma);
               vtextobs := REPLACE(vtextobs, '#1#', p_sproces);
               vtextobs := REPLACE(vtextobs, '#2#', f1.nrecibo);
               -- 20.0  0027381: código de la cuenta sin encriptar - QT-8085 - Inicio
               -- vtextobs := REPLACE(vtextobs, '#3#', f1.cbancar);
               vtextobs := REPLACE(vtextobs, '#3#', '***' || SUBSTR(f1.cbancar, -4));
               -- 20.0  0027381: código de la cuenta sin encriptar - QT-8085 - Final
               vtextobs := REPLACE(vtextobs, '#4#',

                                   -- 17. 0025151 - Inicio
                                   -- f1.cestimp || ' '
                                   vcestimp || ' '
                                   -- 17. 0025151 - Fin
                                   || ff_desvalorfijo(75, pac_md_common.f_get_cxtidioma,

                                                      -- 17. 0025151 - Inicio
                                                                         -- f1.cestimp
                                                      vcestimp
                                                              -- 17. 0025151 - Fin
                                     ));
               -- 17. 0025151: LCOL999-Redefinir el circuito de prenotificaciones - Inicio
               vpas := 120;

               -- Descripción de los motivos de rechazos bancarios y tipos de rechazo
               BEGIN
                  SELECT d.trechazo,
                         ff_desvalorfijo(1122, pac_md_common.f_get_cxtidioma, c.ctiprechazo)
                    INTO vtrechazo,
                         vtiprechazo
                    FROM codrechazo_banco c, detrechazo_banco d
                   WHERE c.cempres = f1.cempres
                     AND c.ccobban = f1.ccobban
                     AND c.crechazo = f1.cnoterr
                     AND d.cempres = c.cempres
                     AND d.ccobban = c.ccobban
                     AND d.crechazo = c.crechazo
                     AND d.cidioma = pac_md_common.f_get_cxtidioma;
               EXCEPTION
                  WHEN OTHERS THEN
                     vtrechazo := NULL;
                     vtiprechazo := NULL;
               END;

               vpas := 130;
               vtextobs := REPLACE(vtextobs, '#5#', vtrechazo);
               vpas := 140;
               vtextobs := REPLACE(vtextobs, '#6#', vtiprechazo);
               vpas := 150;
               -- 17. 0025151: LCOL999-Redefinir el circuito de prenotificaciones - Final
               n_retorno := pac_prenotificaciones.f_agd_observaciones(f1.cempres, f1.nrecibo,
                                                                      vtextobs);
--            IF n_retorno <> 0 THEN
--               RETURN n_retorno;
--            END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, vobj, vpas, vpar || 'AGD rec=' || f1.nrecibo,
                              SQLERRM);
            END;
         -- 11. 21/02/2012  JGR  0021120/0108092 - Fin
         EXCEPTION
            WHEN OTHERS THEN
               n_retorno := SQLCODE;
               p_tab_error(f_sysdate, f_user, vobj, vpas, vpar || ' rec=' || f1.nrecibo,
                           SQLERRM);
         END;
      END LOOP;

      RETURN n_retorno;
   END f_actrecibos_notificados;

   -- Bug 21116 - APD - 27/01/2012 - se crea la funcion
   /*******************************************************************************
   FUNCION f_valida_prenoti_cobban
   Función que valida que si existe una pre notificación en curso para un cobrador bancario,
   no permita realizar una nueva pre notificacion de este cobrador bancario
   Parámetros:
    Entrada :
       pcempres NUMBER
       pccobban  NUMBER
       psseguro IN NUMBER

    Retorna: un NUMBER con el id del error.
   ********************************************************************************/
   FUNCTION f_valida_prenoti_cobban(
      pcempres IN NUMBER,
      pccobban IN NUMBER DEFAULT NULL,   -- 12. 0021120/0108895 + DEFAULT NULL
      psseguro IN NUMBER DEFAULT NULL,
      psproces IN NUMBER DEFAULT NULL   -- 12. 0021120/0108895
                                     )
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pccobban=' || pccobban || '; pcempres=' || pcempres || '; psseguro=' || psseguro
            || ' psproces:' || psproces;
      vobject        VARCHAR2(200) := 'PAC_DOMIS.F_VALIDA_PRENOTI_COBBAN';
      num_err        NUMBER;
      salir          EXCEPTION;
      v_cont         NUMBER;
      vsproces       NUMBER;
   BEGIN
      vpasexec := 2;

      SELECT COUNT(1)
        INTO v_cont
        FROM notificaciones n
       WHERE (n.ccobban = pccobban
              OR pccobban IS NULL)
         AND(n.cempres = pcempres
             OR pcempres IS NULL)
         AND(n.sseguro = psseguro
             OR psseguro IS NULL)
         -- 12. 0021120: LCOL897-LCOL_A001-Resumen y detalle ... NOTA:0108895 - Inicio
         AND(n.sproces = psproces
             OR psproces IS NULL)
         AND n.tfiledev IS NULL;

      --         AND n.nrecibo IN(SELECT r.nrecibo
--                            FROM recibos r
--                           WHERE r.nrecibo = n.nrecibo
--                             AND r.sseguro = n.sseguro
--                             AND r.cestimp = 12);   -- Prenotificación en curso (v.f. 75)
         -- 12. 0021120: LCOL897-LCOL_A001-Resumen y detalle ... NOTA:0108895 - Fin
      IF v_cont > 0 THEN
         num_err := 9903190;   --Existe una prenotificación en curso para el cobrador bancario
         RAISE salir;
      END IF;

      vpasexec := 7;
      RETURN 0;
   EXCEPTION
      WHEN salir THEN
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_valida_prenoti_cobban;

-- FI Bug 21116 - APD - 27/01/2012

   -- 11. 21/02/2012  JGR  0021120/0108092 - Inicio
   /*******************************************************************************
   FUNCION f_agd_observaciones
   Graba apuntes en la agenda del recibo, para los movimiento de prenotificaciones.
   Parámetros:
    Entrada :
       pcempres IN NUMBER
       pnrecibo IN NUMBER
       ptextobs IN VARCHAR2

    Retorna: un NUMBER con el id del error.
   ********************************************************************************/
   FUNCTION f_agd_observaciones(pcempres IN NUMBER, pnrecibo IN NUMBER, ptextobs IN VARCHAR2)
      RETURN NUMBER IS
      vidobs         agd_observaciones.idobs%TYPE;
      num_err        NUMBER;
      vpasexec       NUMBER;
      vobjectname    VARCHAR2(500) := 'PAC_PRENOTIFICACIONES.f_agd_observaciones';
      vparam         VARCHAR2(1000)
         := 'parámetros - pcempres: ' || pcempres || ' pnrecibo:' || pnrecibo || ' ptextobs:'
            || ptextobs;
   BEGIN
      vpasexec := 10;

      BEGIN
         SELECT NVL(MAX(idobs), 0) + 1
           INTO vidobs
           FROM agd_observaciones
          WHERE cempres = pcempres;
      EXCEPTION
         WHEN OTHERS THEN
            vidobs := 1;
      END;

      vpasexec := 20;
      num_err := pac_agenda.f_set_obs(pcempres, vidobs, 1, 0,
                                      f_axis_literales(9902717, pac_md_common.f_get_cxtidioma),
                                      ptextobs, f_sysdate, NULL, 2, NULL, NULL, NULL, 1, 1,
                                      f_sysdate, vidobs);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      vpasexec := 30;

      UPDATE agd_observaciones
         SET nrecibo = pnrecibo
       WHERE cempres = pcempres
         AND idobs = vidobs;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 806310;
   END f_agd_observaciones;

-- 11. 21/02/2012  JGR  0021120/0108092 - Fin

   --
   /*******************************************************************************
   FUNCION f_estimprec
   Retorna el estat d'impressió del rebut.

   Parámetros:
    Entrada :
       pnrecibo IN NUMBER
       pfecha IN DATE

    Retorna: un NUMBER con estat impressió rebut.
    Bug 21120 - 20120301 - JLTS
   ********************************************************************************/
   FUNCTION f_estimprec(pnrecibo IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      vestimp        recibos.cestimp%TYPE;
   BEGIN
      BEGIN
         SELECT h2.cestimp
           INTO vestimp
           FROM (SELECT MIN(h1.fhist) f_fin
                   FROM his_recibos h1
                  WHERE h1.nrecibo = pnrecibo
                    AND TRUNC(h1.fhist) >= pfecha) q1,
                his_recibos h2
          WHERE h2.nrecibo = pnrecibo
            AND h2.fhist = q1.f_fin;
      EXCEPTION
         WHEN OTHERS THEN
            vestimp := -1;
      END;

      IF vestimp = -1 THEN
         SELECT cestimp
           INTO vestimp
           FROM recibos
          WHERE nrecibo = pnrecibo;
      END IF;

      RETURN vestimp;
   END f_estimprec;

-- 21.0 0027411: Error al generar más de un número de matrícula - QT-8145 - Inicio
   /*******************************************************************************
   FUNCION F_PAGADOR_SPERSON
   Retorna tomador o pagador del recibo.

   Parámetros:
    Entrada :
       psseguro IN NUMBER

    Retorna: el SPERSON del tomador o pagador.
   ********************************************************************************/
   FUNCTION f_pagador_sperson(psseguro IN NUMBER)
      RETURN NUMBER IS
      vcexistepagador tomadores.cexistepagador%TYPE;
      vsperson_notif tomadores.sperson%TYPE;
      vpasexec       NUMBER;
      vobjectname    VARCHAR2(500) := 'PAC_PRENOTIFICACIONES.F_PAGADOR_SPERSON';
      vparam         VARCHAR2(1000) := 'parámetros - psseguro: ' || psseguro;
      e_error        EXCEPTION;
      verror         NUMBER;
   BEGIN
      vpasexec := 10;

      BEGIN
         SELECT NVL(t.cexistepagador, 0), sperson   -- 10. 0025151 - 0139714
           INTO vcexistepagador, vsperson_notif   -- 10. 0025151 - 0139714
           FROM tomadores t
          WHERE t.sseguro = psseguro
            AND t.nordtom = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            verror := 105111;   -- Tomador no encontrado en la tabla TOMADORES.
            RAISE e_error;
         WHEN OTHERS THEN
            verror := 105112;   -- Error al leer de la tabla TOMADORES.
            RAISE e_error;
      END;

      vpasexec := 20;

      IF vcexistepagador = 1 THEN
         BEGIN
            SELECT g.sperson
              INTO vsperson_notif
              FROM gescobros g
             WHERE g.sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               verror := 9904082;   -- Gestor de cobro / Pagador no encontrado en la tabla GESCOBROS.
               RAISE e_error;
            WHEN OTHERS THEN
               verror := 9904083;   -- Error al leer en la tabla GESCOBROS.
               RAISE e_error;
         END;
      END IF;

      RETURN vsperson_notif;
   EXCEPTION
      WHEN e_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     f_axis_literales(verror, pac_md_common.f_get_cxtidioma));
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_pagador_sperson;

   /*******************************************************************************
   PROCEDIMIENTO P_ACTRECIBOS_X_MATRICULA
   Actualiza el subestado (CRESTIMP) de un recibo y de todos los que tengan o
   le corresponda la misma matrícula. Porque puede ser que aún no tengan matrícula.

   Parámetros:
    Entrada :
       psseguro IN NUMBER
       pcestimp IN NUMBER

    Retorna: 0 OK ... sino código de ERROR
   ********************************************************************************/
   PROCEDURE p_actrecibos_x_matricula(pnrecibo IN NUMBER, pcestimp IN NUMBER) IS
      vsseguro       recibos.sseguro%TYPE;
      vcbancar       recibos.cbancar%TYPE;
      vctipban       recibos.ctipban%TYPE;
      vctipcc        tipos_cuenta.ctipcc%TYPE;
      vsperson       tomadores.sperson%TYPE;
      -- vobjectname    VARCHAR2(500) := 'PAC_PRENOTIFICACIONES.P_ACTRECIBOS_X_MATRICULA';
      -- vparam         VARCHAR2(1000) := 'parámetros - pnrecibo: ' || pnrecibo || ' pcestimp:' || pcestimp;
      vpasexec       NUMBER;
      vcnotifi       cobbancario.cnotifi%TYPE;
   BEGIN
      vpasexec := 10;

      SELECT r.sseguro, r.cbancar, r.ctipban, c.cnotifi
        INTO vsseguro, vcbancar, vctipban, vcnotifi
        FROM recibos r, tipos_cuenta t, cobbancario c
       WHERE r.nrecibo = pnrecibo
         AND t.ctipban = r.ctipban
         AND r.ccobban = c.ccobban;

      IF vcnotifi = 1 THEN
         vpasexec := 20;

         SELECT t.ctipcc
           INTO vctipcc
           FROM tipos_cuenta t
          WHERE ctipban = vctipban;

         vpasexec := 30;

         -- Modifica el recibo solicitado
         UPDATE recibos
            SET cestimp = pcestimp
          WHERE nrecibo = pnrecibo;

         vpasexec := 40;
         vsperson := f_pagador_sperson(vsseguro);
         vpasexec := 50;

         -- Modifica los recibos a los que les corresponde la misma matrícula
         UPDATE recibos a
            SET a.cestimp = pcestimp
          WHERE a.cbancar = vcbancar
            AND a.nrecibo != pnrecibo
            AND a.ctipban IN(SELECT ctipban
                               FROM tipos_cuenta t
                              WHERE ctipcc = vctipcc)
            AND f_pagador_sperson(a.sseguro) = vsperson;

         vpasexec := 60;

         -- 1 Pendiente de prenotificar
         -- 2 Prenotificación en tránsito
         -- 3 No Prenotificado o retenida
         -- 4 Validada o matriculada
         UPDATE per_ccc
            SET cvalida = DECODE(pcestimp, 11, 1, 12, 2, 13, 3, 4, 4)
          WHERE sperson = vsperson
            AND cbancar = vcbancar
            AND ctipban IN(SELECT ctipban
                             FROM tipos_cuenta t
                            WHERE ctipcc = vctipcc);
      END IF;
   END p_actrecibos_x_matricula;

   /*******************************************************************************
   FUNCION F_CESTIMP_PRENOTIF
   DEvuelve el subestado (CRESTIMP) que correspondería a un recibo según el estado
   de la matrícula matrícula en PER_CCC.CVALIDA.

   Parámetros:
    Entrada :
       psseguro IN NUMBER
       pcempres IN NUMBER,
       pcbancar IN VARCHAR2,
       pctipban IN NUMBER,
       psperson IN NUMBER,
       pccobban IN NUMBER,
       pcestimp IN OUT NUMBER

    Retorna: 0 OK ... sino código de ERROR
   ********************************************************************************/
   FUNCTION f_cestimp_prenotif(
      psseguro IN NUMBER,
      pcbancar IN VARCHAR2,
      pctipban IN NUMBER,
      pccobban IN NUMBER,
      pcestimp IN OUT NUMBER)
      RETURN NUMBER IS
      vvalidada      NUMBER;
      vcnotifi       NUMBER;
      vobj           VARCHAR2(200) := 'PAC_PRENOTIFICACIONES.F_CESTIMP_PRENOTIF';
      vpas           NUMBER := 1;
      vpar           VARCHAR2(500)
         -- 10. 0025151 - 0139714 - Inicio
      := SUBSTR(' pcbancar=' || pcbancar || ' psseguro=' || psseguro || ' pctipban='
                || pctipban || ' pccobban=' || pccobban || ' pcestimp=' || pcestimp,
                1, 500);
      vctipcc        tipos_cuenta.ctipcc%TYPE;
      vctipide       notificaciones.ctipide%TYPE;
      vnnumide       notificaciones.nnumide%TYPE;
   -- 10. 0025151 - 0139714 - Final
   BEGIN
      vpas := 100;

      -- El recibo le toca inicialmente estar 4- pendiente de domiciliar
      IF pcestimp = 4
         AND pcbancar IS NOT NULL
         AND pctipban IS NOT NULL   -- 10. 0025151 - 0139714
                                 THEN
         BEGIN
            vpas := 110;

            SELECT cnotifi
              INTO vcnotifi
              FROM cobbancario
             WHERE ccobban = pccobban;

            -- El cobrador bancario requiere prenotificación
            IF vcnotifi = 1 THEN
               vpas := 120;

               BEGIN
                  SELECT ctipcc
                    INTO vctipcc
                    FROM tipos_cuenta
                   WHERE ctipban = pctipban;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     vctipcc := NULL;
               END;

               vpas := 130;

               IF vctipcc IS NULL THEN
                  RETURN 180928;   -- Error al buscar la descripción de tipo o formato de cuenta ccc
               END IF;

               vpas := 140;

               -- CVALIDA --------------------- CESTIMP -----------------------
               -- 1 Pendiente de prenotificar   11 Pendiente de prenotificación
               -- 2 Prenotificación en tránsito 12 Prenotificación en curso
               -- 3 No Prenotificado o retenida 13 Rechazo prenotificación
               -- 4 Validada o matriculada      04 Pendiente domiciliación
               BEGIN
                  SELECT DECODE(NVL(cvalida, 1), 1, 11, 2, 12, 3, 13, 4, 4)
                    INTO pcestimp
                    FROM per_ccc
                   WHERE sperson = f_pagador_sperson(psseguro)
                     AND cbancar = pcbancar
                     AND ctipban IN(SELECT ctipban
                                      FROM tipos_cuenta t
                                     WHERE ctipcc = vctipcc);
               END;

               vpas := 150;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM
                           || ' error = ' || 103941);
               -- Error al leer la tabla COBBANCARIO
               RETURN 103941;
         END;
      END IF;

      RETURN 0;
   END;
-- 21.0 0027411: Error al generar más de un número de matrícula - QT-8145 - Final
END pac_prenotificaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_PRENOTIFICACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PRENOTIFICACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PRENOTIFICACIONES" TO "PROGRAMADORESCSI";
