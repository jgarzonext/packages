--------------------------------------------------------
--  DDL for Package Body PAC_RECAUDOS_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_RECAUDOS_CONF" IS
/******************************************************************************
   NOMBRE:       pac_recaudos_conf
   PROP¿SITO:
   REVISIONES:

   Ver  Fecha       Autor  Descripci¿n

******************************************************************************/

   -----------------------------------------------------------------------------
   k_tag_productos CONSTANT VARCHAR2(10) := 'PRODUCTOS';
   k_tag_bancos CONSTANT VARCHAR2(10) := 'BANCOS';
   k_ctipban_cobros_ach CONSTANT NUMBER := 51;
   k_sep_comma CONSTANT VARCHAR2(1) := ',';
   k_error_linea CONSTANT NUMBER := -1;
   k_error_proces CONSTANT NUMBER := -2;
   k_error_others CONSTANT NUMBER := -3;
   k_empresa_conf CONSTANT NUMBER := 24;   --conf
   fichero        UTL_FILE.file_type;
   e_salida       EXCEPTION;
   nlinerr        NUMBER(8);
   error          NUMBER(8);
   nlinea         NUMBER(8);
   vnomobj        VARCHAR2(100);
   vlinea         VARCHAR2(2000);
   gbdomiciliacion BOOLEAN DEFAULT TRUE;
   pcdivisa       parproductos.cvalpar%TYPE := f_parinstalacion_n('MONEDAINST');
   xndecima       monedas.ndecima%TYPE;
   isomonedainst  monedas.ciso4217n%TYPE;
   xmoniso        monedas.cmonint%TYPE;
   xnrecibo       domiciliaciones.nrecibo%TYPE;
   xcramo         domiciliaciones.cramo%TYPE;
   xccobban       domiciliaciones.ccobban%TYPE;
   xcdoment       domiciliaciones.cdoment%TYPE;
   xcdomsuc       domiciliaciones.cdomsuc%TYPE;
   xcempres       domiciliaciones.cempres%TYPE;
   xsseguro       domiciliaciones.sseguro%TYPE;
   xcbancar       domiciliaciones.cbancar%TYPE;
   xcbancarsb     domiciliaciones.cbancar%TYPE;
   xctipban       domiciliaciones.ctipban%TYPE;
   xidnotif       domiciliaciones.idnotif%TYPE;
   xidnotif2      domiciliaciones.idnotif2%TYPE;
   xnpoliza       seguros.npoliza%TYPE;
   xncertif       seguros.ncertif%TYPE;
   xsproduc       seguros.sproduc%TYPE;
   xcmodali       seguros.cmodali%TYPE;
   xctipseg       seguros.ctipseg%TYPE;
   xccolect       seguros.ccolect%TYPE;
   xcobjase       seguros.cobjase%TYPE;
   xfvencim_rec   recibos.fvencim%TYPE;
   xfefecto_rec   recibos.fefecto%TYPE;
   xcagente       recibos.cagente%TYPE;
   xnriesgo       recibos.nriesgo%TYPE;
   xctiprec       recibos.ctiprec%TYPE;
   xfefecto       recibos.fefecto%TYPE;
   xctipcob       recibos.ctipcob%TYPE;
   xncuotar       recibos.ncuotar%TYPE;
   xitotalr       vdetrecibos.itotalr%TYPE;
   xiprinet       vdetrecibos.iprinet%TYPE;
   xiips          vdetrecibos.iips%TYPE;
   xitotalr_entero NUMBER;
   xiprinet_entero NUMBER;
   xiips_entero   NUMBER;
   xitotrec       NUMBER;
   xitotrec_entero NUMBER;
   xit1imp        NUMBER;
   xit1imp_entero NUMBER;



PROCEDURE p_recibos_convenio(
      p_fecha IN DATE DEFAULT NULL,
      p_dev IN OUT NUMBER,
      p_pro IN OUT NUMBER,
      p_err IN OUT NUMBER) IS
      vobjectname    VARCHAR2(500) := 'pac_recaudos_pos.p_recibos_convenio';
      vparam         VARCHAR2(1000) := ' fec=' || p_fecha;
      vpasexec       NUMBER(5) := 1;
      d_fecpro       DATE;

      CURSOR c1 IS
         SELECT b.sproduc, b.sseguro, b.csituac, c.nrecibo, c.femisio, c.fefecto, c.cbancar,
                e.itotalr, c.ccobban, c.ctipban, GREATEST(c.femisio, c.fefecto) fec_mayor
           FROM seguros b, recibos c, vdetrecibos_monpol e
          WHERE c.sseguro = b.sseguro
            --AND c.ctipcob NOT IN(2, 12)   -- debito o recaudo
            -- 8.0  14/05/2014  JGR    0029175#c174800: POSND100-POSADM - D?as de Gracia
            -- AND c.ctiprec <> 14
            -- excluyan los extornos, retornos, CTIPREC NOT IN(9, 13, 14, 15), adem¿s de los recibos pertenecientes a p¿lizas con facultativo.
            -- 9  Extorno
            -- 13 Retorno
            -- 14 Prima Devengada Terminaci¿n autom¿tica
            -- 15 Recobro del Retorno
            AND c.ctiprec NOT IN(9, 13, 14, 15)
            AND NOT EXISTS(SELECT 1
                             FROM cuafacul f
                            WHERE f.sseguro = b.sseguro)
            -- 8.0  14/05/2014  JGR    0029175#c174800: POSND100-POSADM - D?as de Gracia
            --08/10/2014 JRB 29371.- No se deben de anular recibos de colectivos administrados por terminaci¿n por no pago
            AND NOT EXISTS(SELECT 1
                             FROM pregunpolseg p
                            WHERE p.sseguro = b.sseguro
                              AND p.cpregun = 4092
                              AND p.crespue = 1)
            AND EXISTS(SELECT 1
                         FROM movrecibo d
                        WHERE d_fecpro >= d.fmovini
                          AND(d_fecpro < d.fmovfin
                              OR d.fmovfin IS NULL)
                          AND d.nrecibo = c.nrecibo
                          AND d.cestrec = 0
                          AND c.cestimp NOT IN(12))   -- 19. 0022738 / 0118685
            AND NVL(b.ctipcoa, 0) <> 8
            AND e.nrecibo = c.nrecibo;

      v_err          NUMBER;
      v_usu          usuarios.cusuari%TYPE;
      v_emp          empresas.cempres%TYPE;
      d_hoy          DATE;
      v_dev          devbanpresentadores.sdevolu%TYPE;
      v_pro          procesoscab.sproces%TYPE;
      n_tot          devbanpresentadores.nprereg%TYPE;
      n_toterr       NUMBER;
      nprolin        NUMBER := NULL;
      v_periodo_gracia NUMBER;
      vitotalr       NUMBER := 0;   -- 18. 0021718: MDP_A001-Domiciliaciones - 0111176
   BEGIN
      vpasexec := 100;
      p_dev := NULL;
      p_pro := NULL;
      p_err := 0;
      vpasexec := 110;
      d_hoy := f_sysdate;
      v_usu := f_user;
      v_emp := f_empres;
      d_fecpro := NVL(p_fecha, d_hoy);

      IF v_pro IS NULL THEN
         vpasexec := 120;
         v_err := f_procesini(v_usu, v_emp, 'Convenio',
                              'Inicio convenio recibos anulados : '
                              || TO_CHAR(d_hoy, 'MM-DD-YYYY HH:MI'),
                              v_pro);
      END IF;

      IF v_dev IS NULL THEN
         vpasexec := 130;

         SELECT NVL(MAX(sdevolu), 0) + 1
           INTO v_dev
           FROM devbanpresentadores;
      END IF;

      BEGIN
         vpasexec := 140;

         INSERT INTO devbanpresentadores
                     (sdevolu, cempres, cdoment, cdomsuc, fsoport, nnumnif, tsufijo, tprenom,
                      fcarga, cusuari, tficher, nprereg, ipretot_r, ipretot_t, npretot_r,
                      npretot_t, sproces)
              VALUES (v_dev, v_emp, 0, 0, d_hoy, 'x', 'x', 'Convenio',
                      d_hoy, f_user, 'x', NULL, NULL, NULL, NULL,
                      NULL, v_pro);
      EXCEPTION
         WHEN OTHERS THEN
            v_err := f_proceslin(v_pro,
                                 SUBSTR(v_dev || ' ' || SQLCODE || ' ' || SQLERRM, 1, 120), 0,
                                 nprolin);
      END;

      n_tot := 0;
      n_toterr := 0;
      vpasexec := 150;

      BEGIN
         INSERT INTO devbanordenantes
                     (sdevolu, nnumnif, tsufijo, fremesa, ccobban, tordnom, nordccc, nordreg,
                      iordtot_r, iordtot_t, nordtot_r, nordtot_t, ctipban)
              VALUES (v_dev, 'x', 'x', d_hoy, 202, 'Convenio', 'x', 1,
                      NULL, NULL, NULL, NULL, NULL);
      EXCEPTION
         WHEN OTHERS THEN
            v_err := f_proceslin(v_pro,
                                 SUBSTR(v_dev || ' ' || SQLCODE || ' ' || SQLERRM, 1, 120), 0,
                                 nprolin);
      END;

      FOR f1 IN c1 LOOP
         IF pac_propio.f_esta_en_exoneracion(f1.sseguro) <> 1 THEN
            vpasexec := 151;
            v_periodo_gracia := 0;
            vpasexec := 152;
            vpasexec := 154;

            IF (TRUNC(pac_devolu.f_fecha_periodo_gracia(v_pro, f1.nrecibo)) + v_periodo_gracia)
               - TRUNC(d_fecpro) < 0 THEN
               vpasexec := 155;

               BEGIN
                  n_tot := n_tot + 1;
                  vitotalr := vitotalr + f1.itotalr;
                  vpasexec := 160;

                  INSERT INTO devbanrecibos
                              (sdevolu, nnumnif, tsufijo, fremesa, crefere, nrecibo,
                               trecnom, nrecccc, irecdev, cdevrec,
                               crefint, cdevmot, cdevsit, tprilin, ccobban, ctipban)
                       VALUES (v_dev, 'x', 'x', d_hoy, LPAD(f1.nrecibo, 12, '0'), f1.nrecibo,
                               'Convenio', NVL(f1.cbancar, -1), f1.itotalr, 'x',
                               LPAD(f1.nrecibo, 10, '0'), 9, 1, NULL, f1.ccobban, f1.ctipban);
               EXCEPTION
                  WHEN OTHERS THEN
                     n_toterr := n_toterr + 1;
                     v_err := f_proceslin(v_pro, SUBSTR(SQLCODE || ' ' || SQLERRM, 1, 120),
                                          f1.nrecibo, nprolin);
               END;
            END IF;
         END IF;
      END LOOP;

      vpasexec := 170;

      UPDATE devbanpresentadores
         SET nprereg = n_tot
       WHERE sdevolu = v_dev;

      UPDATE devbanordenantes
         SET nordreg = n_tot,
             iordtot_r = vitotalr,
             iordtot_t = vitotalr,
             nordtot_r = n_tot,
             nordtot_t = n_tot
       WHERE sdevolu = v_dev;

      vpasexec := 180;
      p_procesfin(v_pro, n_toterr);
      vpasexec := 190;
      p_dev := v_dev;
      p_pro := v_pro;
   EXCEPTION
      WHEN OTHERS THEN
         p_err := SQLCODE;
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'ERROR: ' || p_err || ' - ' || SQLERRM);
   END p_recibos_convenio;
END pac_recaudos_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_RECAUDOS_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_RECAUDOS_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_RECAUDOS_CONF" TO "PROGRAMADORESCSI";
