--------------------------------------------------------
--  DDL for Package Body PAC_REEMBOLSOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_REEMBOLSOS" IS
/******************************************************************************
   NOMBRE:     pac_reembolso
   PROPÓSITO:  Contiene funciones y procedimientos para operar con reembolsos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        ??/??/????   ???              1. Creación del objeto.
   2.0        03/07/2009   DRA              2. 0010631: CRE - Modificaciónes modulo de reembolsos
   3.0        14/07/2009   DRA              3. 0010704: CRE - Traspaso de facturas para reembolso con mismo Nº Hoja CASS
   4.0        24/08/2009   DRA              4. 0010949: CRE - Pruebas módulo reembolsos
   5.0        10/09/2009   DRA              5. 0011106: CRE - Reembolsos traspaso de facturas
   6.0        02/10/2009   XVM              6. 0011285: CRE - Transferencias de reembolsos
   7.0        10/03/2010   DRA              7. 0012676: CRE201 - Consulta de reembolsos - Ocultar descripción de Acto y otras mejoras
   8.0        21/03/2010   DRA              8. 0013927: CRE049 - Control cambio de estado reembolso
   9.0        26/04/2010   DRA              9. 0014227: CRE201 - Modificaciones reembolsos
  10.0        26/01/2011   JMP             10. 0017367: GRC003 - Personalización del número de siniestro
  11.0        08/02/2011   DRA             11. 0016576: AGA602 - Parametrització de reemborsaments per veterinaris
  12.0        22/02/2011   DRA             12. 0017732: CRE998 - Modificacions mòdul reemborsaments
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

--------------------------------------------------------------------------------
   FUNCTION ff_contador_reembolsos(psseguro IN seguros.sseguro%TYPE, pnreemb OUT NUMBER)
      RETURN NUMBER IS
      vcramo         productos.cramo%TYPE;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'pac_reembolsos.ff_contador_reembolsos';
      vcempres       seguros.cempres%TYPE;
   BEGIN
      vpasexec := 1;

      BEGIN
         SELECT cramo, cempres
           INTO vcramo, vcempres
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vpasexec := 2;
            RETURN 111360;
      END;

      IF vcramo IS NOT NULL THEN
         vpasexec := 3;
         -- BUG 17367 - 26/01/2011 - JMP - Llamar a PAC_PROPIO.F_CONTADOR2 para la generación del número de reembolso (contador siniestros)
--         pnreemb := pac_propio.f_contador2(vcempres, '01', vcramo);
         pnreemb := pac_propio.f_contador2(vcempres, '01', vcramo, psseguro);   -- 210032:ASN:23/01/2012

         IF pnreemb = 0 THEN
            vpasexec := 4;
            RETURN 103234;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.ff_contador_reembolsos', vpasexec,
                     'error no controlat', SQLERRM);
         RETURN 1000005;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.ff_contador_reembolsos', vpasexec,
                     'error no controlat', SQLERRM);
         RETURN 1000006;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.ff_contador_reembolsos', vpasexec,
                     'error no controlat', SQLERRM);
         RETURN SQLCODE;
   END ff_contador_reembolsos;

--------------------------------------------------------------------------------
   FUNCTION f_ins_reembolso(
      pnreemb IN OUT reembolsos.nreemb%TYPE,
      psseguro IN reembolsos.sseguro%TYPE,
      pnriesgo IN reembolsos.nriesgo%TYPE,
      pcgarant IN reembolsos.cgarant%TYPE,
      pcestado IN reembolsos.cestado%TYPE,
      pfestado IN reembolsos.festado%TYPE,
      ptobserv IN reembolsos.tobserv%TYPE,
      pcbancar IN reembolsos.cbancar%TYPE,
      pctipban IN reembolsos.ctipban%TYPE,
      pcorigen IN reembolsos.corigen%TYPE)
      RETURN NUMBER IS
      vsperson       reembolsos.sperson%TYPE;
      v_agrsalud     NUMBER(8);
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'pac_reembolsos.f_ins_reembolso';
   BEGIN
      vpasexec := 1;

      -- BUG16576:DRA:08/02/2011:Inici
      BEGIN
         SELECT sperson
           INTO vsperson
           FROM riesgos
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 1000646;
      END;

      IF vsperson IS NULL THEN
         BEGIN
            SELECT a.sperson
              INTO vsperson
              FROM asegurados a
             WHERE a.sseguro = psseguro
               AND a.norden = (SELECT MIN(a1.norden)
                                 FROM asegurados a1
                                WHERE a1.sseguro = a.sseguro);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 9001086;
         END;
      END IF;

      -- BUG16576:DRA:08/02/2011:Fi
      vpasexec := 2;

      BEGIN
         SELECT p.cvalpar
           INTO v_agrsalud
           FROM parproductos p, seguros s
          WHERE s.sseguro = psseguro
            AND s.sproduc = p.sproduc
            AND p.cparpro = 'AGR_SALUD';
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_agrsalud := NULL;
      END;

      vpasexec := 3;

      IF psseguro IS NOT NULL
         AND pnriesgo IS NOT NULL
         AND pcgarant IS NOT NULL
         AND pcestado IS NOT NULL
         AND pfestado IS NOT NULL
         AND pcbancar IS NOT NULL
         AND pctipban IS NOT NULL
         AND pcorigen IS NOT NULL
         AND vsperson IS NOT NULL THEN   --AND
         -- v_agrsalud IS NOT NULL THEN
         IF v_agrsalud IS NULL THEN
            v_agrsalud := 0;
         END IF;

         IF pnreemb IS NULL THEN   -- INSERT
            vpasexec := 4;
            vnumerr := ff_contador_reembolsos(psseguro, pnreemb);

            IF vnumerr = 0 THEN
               vpasexec := 5;

               INSERT INTO reembolsos
                           (nreemb, sseguro, nriesgo, cgarant, agr_salud, sperson,
                            cestado, festado, tobserv, cbancar, ctipban, corigen)
                    VALUES (pnreemb, psseguro, pnriesgo, pcgarant, v_agrsalud, vsperson,
                            pcestado, pfestado, ptobserv, pcbancar, pctipban, pcorigen);
            ELSE
               RAISE e_object_error;
            END IF;
         ELSE   -- UPDATE
            vpasexec := 6;

            UPDATE reembolsos
               SET sseguro = psseguro,
                   nriesgo = pnriesgo,
                   cgarant = pcgarant,
                   agr_salud = v_agrsalud,
                   sperson = vsperson,
                   cestado = pcestado,
                   festado = pfestado,
                   tobserv = ptobserv,
                   cbancar = pcbancar,
                   ctipban = pctipban
             WHERE nreemb = pnreemb;

            IF SQL%ROWCOUNT = 0 THEN
               vpasexec := 7;
               RETURN 9000481;
            END IF;
         END IF;

         COMMIT;
      ELSE
         --v_error := 9000480;
         RAISE e_param_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.f_ins_reembolso', vpasexec,
                     'error no controlat', SQLERRM);
         RETURN 1000005;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.f_ins_reembolso', vpasexec,
                     'error no controlat', SQLERRM);
         RETURN 1000006;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.f_ins_reembolso', vpasexec,
                     'error no controlat', SQLERRM);
         ROLLBACK;
         RETURN SQLCODE;
   END f_ins_reembolso;

--------------------------------------------------------------------------------
   FUNCTION f_ins_reemfact(
      pnfact IN OUT reembfact.nfact%TYPE,
      pnreemb IN reembfact.nreemb%TYPE,
      pnfactcli IN reembfact.nfact_cli%TYPE,
      pctipofac IN reembfact.ctipofac%TYPE,   -- BUG10704:DRA:14/07/2009
      pfechafact IN reembfact.ffactura%TYPE,
      pfechacu IN reembfact.facuse%TYPE,
      pimporte IN reembfact.impfact%TYPE,
      porigen IN reembfact.corigen%TYPE DEFAULT 1,
      pfbaja IN reembfact.fbaja%TYPE,
      pncass IN reembfact.ncass_ase%TYPE,
      pncasscli IN reembfact.ncass%TYPE,
      pnfactext IN reembfact.nfactext%TYPE,   -- BUG10631:DRA:03/07/2009
      pctractat IN reembfact.ctractat%TYPE)   -- BUG177321:DRA:22/02/2011
      RETURN NUMBER IS
      v_num_fact     NUMBER;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'pnfact=' || pnfact || ', pnreemb=' || pnreemb || ', pnfactcli=' || pnfactcli
            || ', pctipofac=' || pctipofac || ', pfechafact=' || pfechafact || ', pfechacu='
            || pfechacu || ', pimporte=' || pimporte || ', porigen=' || porigen || ', pfbaja='
            || pfbaja || ', pncass=' || pncass || ', pncasscli=' || pncasscli
            || ', pnfactext=' || pnfactext || ', pctractat=' || pctractat;
      vobject        VARCHAR2(200) := 'pac_reembolsos.f_ins_reemfact';
      vorigen        reembfact.corigen%TYPE;
      vusubaja       VARCHAR2(20);
   BEGIN
      vpasexec := 1;
      vorigen := NVL(porigen, 1);

      IF pnreemb IS NOT NULL
         AND pctipofac IS NOT NULL
         AND pfechafact IS NOT NULL
         AND pfechacu IS NOT NULL
         AND pimporte IS NOT NULL
         AND vorigen IS NOT NULL THEN
         vpasexec := 2;

         IF pnfact IS NULL THEN   -- INSERT
            vpasexec := 3;

            BEGIN
               SELECT MAX(nfact)
                 INTO v_num_fact
                 FROM reembfact
                WHERE nreemb = pnreemb;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_num_fact := 0;
            END;

            vpasexec := 4;
            v_num_fact := NVL(v_num_fact, 0);
            vpasexec := 5;

            IF v_num_fact > 0
               AND TO_NUMBER(TO_CHAR(f_sysdate, 'YYYYMM')) >
                                                            TO_NUMBER(SUBSTR(v_num_fact, 1, 6)) THEN
               v_num_fact := 0;
            END IF;

            vpasexec := 6;

            IF v_num_fact = 0 THEN
               pnfact := TO_NUMBER(TO_CHAR(f_sysdate, 'YYYYMM') || TO_CHAR(v_num_fact + 1));
            ELSE
               pnfact := v_num_fact + 1;
            END IF;

            vpasexec := 7;

            INSERT INTO reembfact
                        (nreemb, nfact, nfact_cli, ncass_ase, ncass, facuse,
                         ffactura, impfact, ctipofac, cimpresion,   -- BUG10704:DRA:14/07/2009
                                                                 corigen, fbaja, falta,
                         cusualta, nfactext,   -- BUG10631:DRA:03/07/2009
                                            ctractat)   -- BUG17732:DRA:22/02/2011
                 VALUES (pnreemb, pnfact, UPPER(pnfactcli), pncass, pncasscli, pfechacu,   -- BUG12676:DRA:10/03/2010
                         pfechafact, pimporte, pctipofac, 'N',   -- BUG10704:DRA:14/07/2009
                                                              vorigen, pfbaja, f_sysdate,
                         f_user, pnfactext,   -- BUG10631:DRA:03/07/2009
                                           pctractat);   -- BUG17732:DRA:22/02/2011
         ELSE   -- UPDATE
            vpasexec := 8;

            IF pfbaja IS NOT NULL THEN
               vusubaja := f_user;
            ELSE
               vusubaja := NULL;
            END IF;

            UPDATE reembfact
               SET ncass_ase = pncass,   -- BUG12676:DRA:10/03/2010
                   ncass = pncasscli,   -- BUG12676:DRA:10/03/2010
                   facuse = pfechacu,
                   ffactura = pfechafact,
                   impfact = pimporte,
                   ctipofac = pctipofac,   -- BUG10704:DRA:14/07/2009
                   fbaja = pfbaja,
                   cusubaja = vusubaja,
                   nfact_cli = UPPER(pnfactcli),   -- BUG10631:DRA:03/07/2009
                   nfactext = pnfactext,   -- BUG10631:DRA:03/07/2009
                   ctractat = pctractat   -- BUG17732:DRA:22/02/2011
             WHERE nreemb = pnreemb
               AND nfact = pnfact;

            vpasexec := 9;

            IF SQL%ROWCOUNT = 0 THEN
               RETURN 9000481;
            END IF;
         END IF;

         COMMIT;
      ELSE
         RAISE e_param_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pnfact := NULL;
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.f_ins_reemfact', vpasexec,
                     'error no controlat', SQLERRM);
         RETURN 1000005;
      WHEN e_object_error THEN
         pnfact := NULL;
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.f_ins_reemfact', vpasexec,
                     'error no controlat', SQLERRM);
         RETURN 1000006;
      WHEN OTHERS THEN
         pnfact := NULL;
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.f_ins_reemfact', vpasexec,
                     'error no controlat', SQLERRM);
         ROLLBACK;
         RETURN SQLCODE;
   END f_ins_reemfact;

--------------------------------------------------------------------------------
   FUNCTION f_ins_reembactosfac(
      pnreemb IN reembactosfac.nreemb%TYPE,
      pnfact IN reembactosfac.nfact%TYPE,
      pnlinea IN OUT reembactosfac.nlinea%TYPE,
      pcacto IN reembactosfac.cacto%TYPE,
      pnacto IN reembactosfac.nacto%TYPE,
      pfacto IN reembactosfac.facto%TYPE,
      pitarcass IN reembactosfac.itarcass%TYPE,
      ppreemb IN reembactosfac.preemb%TYPE,
      picass IN reembactosfac.icass%TYPE,
      pitot IN reembactosfac.itot%TYPE,
      piextra IN reembactosfac.iextra%TYPE,
      pipago IN reembactosfac.ipago%TYPE,
      piahorro IN reembactosfac.iahorro%TYPE,
      pcerror IN reembactosfac.cerror%TYPE,
      pftrans IN reembactosfac.ftrans%TYPE,
      pcorigen IN reembactosfac.corigen%TYPE,
      pnremesa IN reembactosfac.nremesa%TYPE,
      pfbaja IN reembactosfac.fbaja%TYPE,
      pctipo IN reembactosfac.ctipo%TYPE,   -- BUG10704:DRA:14/07/2009
      pipagocomp IN reembactosfac.ipagocomp%TYPE,   -- BUG10704:DRA:14/07/2009
      pftranscomp IN reembactosfac.ftranscomp%TYPE,   -- BUG10704:DRA:14/07/2009
      pnremesacomp IN reembactosfac.nremesacomp%TYPE)   -- BUG10704:DRA:14/07/2009
      RETURN NUMBER IS
      --
      v_num_lin      NUMBER;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'pnreemb=' || pnreemb || ', pnfact=' || pnfact || ', pnlinea=' || pnlinea
            || ', pcacto=' || pcacto || ', pnacto=' || pnacto || ', pitarcass=' || pitarcass
            || ', ppreemb=' || ppreemb || ', picass=' || picass || ', pitot=' || pitot
            || ', piextra=' || piextra || ', pipago=' || pipago || ', piahorro=' || piahorro
            || ', pcerror=' || pcerror || ', pftrans=' || pftrans || ', pcorigen=' || pcorigen
            || ', pnremesa=' || pnremesa || ', pfbaja=' || pfbaja || ', pctipo=' || pctipo
            || ', pipagocomp=' || pipagocomp || ', pftranscomp=' || pftranscomp
            || ', pnremesacomp=' || pnremesacomp;
      vobject        VARCHAR2(200) := 'pac_reembolsos.f_ins_reembactosfac';
   BEGIN
      vpasexec := 1;

      IF pnreemb IS NOT NULL
         AND pnfact IS NOT NULL
         AND pcacto IS NOT NULL
         AND pnacto IS NOT NULL
         AND pfacto IS NOT NULL
         AND pcorigen IS NOT NULL THEN
         vpasexec := 2;

         IF pnlinea IS NULL THEN   -- INSERT
            BEGIN
               SELECT MAX(nlinea)
                 INTO v_num_lin
                 FROM reembactosfac
                WHERE nreemb = pnreemb
                  AND nfact = pnfact;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_num_lin := 0;
            END;

            vpasexec := 3;
            pnlinea := NVL(v_num_lin, 0) + 1;
            vpasexec := 4;

            INSERT INTO reembactosfac
                        (nreemb, nfact, nlinea, cacto, nacto, facto, itarcass, preemb,
                         icass, itot, iextra, ipago, iahorro, cerror, ftrans, corigen,
                         nremesa, fbaja, ctipo, ipagocomp, ftranscomp, nremesacomp)   -- BUG10704:DRA:14/07/2009
                 --BUG11285-XVM-02102009
            VALUES      (pnreemb, pnfact, pnlinea, pcacto, pnacto, pfacto, pitarcass, ppreemb,
                         picass, pitot, piextra, pipago, piahorro, pcerror, pftrans, pcorigen,
                         pnremesa, pfbaja, pctipo, pipagocomp, pftranscomp, pnremesacomp);   -- BUG10704:DRA:14/07/2009
         ELSE   -- UPDATE
            vpasexec := 5;

            UPDATE reembactosfac
               SET cacto = pcacto,
                   nacto = pnacto,
                   facto = pfacto,
                   itarcass = pitarcass,
                   preemb = ppreemb,
                   icass = picass,
                   itot = pitot,
                   iextra = piextra,
                   ipago = pipago,
                   iahorro = piahorro,
                   cerror = pcerror,
                   -- ftrans = pftrans,  -- BUG10761:DRA:27/07/2009
                   -- sremesa = psremesa, -- BUG10761:DRA:27/07/2009
                   fbaja = pfbaja,
                   ctipo = pctipo,   -- BUG10704:DRA:14/07/2009
                   ipagocomp = pipagocomp   -- BUG10704:DRA:14/07/2009
             -- ftranscomp = pftranscomp,   -- BUG10761:DRA:27/07/2009
             -- sremesacomp = psremesacomp   -- BUG10761:DRA:27/07/2009
            WHERE  nreemb = pnreemb
               AND nfact = pnfact
               AND nlinea = pnlinea;

            IF SQL%ROWCOUNT = 0 THEN
               vpasexec := 6;
               RETURN 9000481;
            END IF;
         END IF;

         COMMIT;
      ELSE
         RAISE e_param_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.f_ins_reemfactosfac', vpasexec,
                     'error no controlat - ' || vparam, SQLERRM);
         RETURN 1000005;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.f_ins_reemfactosfac', vpasexec,
                     'error no controlat - ' || vparam, SQLERRM);
         RETURN 1000006;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.f_ins_reemfactosfac', vpasexec,
                     'error no controlat - ' || vparam, SQLERRM);
         ROLLBACK;
         RETURN SQLCODE;
   END f_ins_reembactosfac;

--------------------------------------------------------------------------------
   FUNCTION f_act_estado_reemb(pnreemb IN reembolsos.nreemb%TYPE)
      RETURN NUMBER IS
      vpasexec       NUMBER(1) := 1;
      vparam         VARCHAR2(100) := 'pnreemb = ' || pnreemb;
   BEGIN
      --Si el reembolso está en estado GESTIÓN OFICINAS(0) se actualizará a GESTIÓN COMPAÑÍA (sólo en este caso).
      UPDATE reembolsos
         SET cestado = 1
       WHERE nreemb = pnreemb
         AND cestado = 0;

      vpasexec := 3;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.f_act_estado_reemb', vpasexec,
                     'error no controlat - ' || vparam, SQLERRM);
         RETURN -1;
   END f_act_estado_reemb;

--------------------------------------------------------------------------------
   FUNCTION f_valida_estado_reemb(
      pnreemb IN reembolsos.nreemb%TYPE,
      pnuevoestado IN reembolsos.cestado%TYPE)
      RETURN NUMBER IS
      vpasexec       NUMBER(1) := 1;
      vparam         VARCHAR2(100)
                             := 'pnreemb = ' || pnreemb || ', pnuevoestado = ' || pnuevoestado;
      v_quants       NUMBER(1);
   BEGIN
      IF pnuevoestado = 2 THEN
         -- Aceptado: No se permite cambiar a aceptado si todas los actos de sus facturas no están con cerror=0 o con fecha baja informada (líneas anuladas).
         SELECT COUNT(1)
           INTO v_quants
           FROM reembactosfac
          WHERE nreemb = pnreemb
            AND(NVL(cerror, 0) <> 0
                AND fbaja IS NULL)   -- BUG14227:DRA:26/04/2010
            AND ROWNUM = 1;

         IF v_quants > 0 THEN
            RETURN(1000655);
         END IF;
      ELSIF pnuevoestado = 3 THEN
         vpasexec := 2;

         -- BUG13927:DRA:21/04/2010:Inici
         SELECT COUNT(1)
           INTO v_quants
           FROM reembactosfac
          WHERE nreemb = pnreemb
            AND NOT(ftrans IS NOT NULL
                    OR(ftrans IS NULL
                       AND NVL(ipago, 0) = 0
                       AND NVL(ipagocomp, 0) = 0))
            AND ROWNUM = 1;

         -- BUG13927:DRA:21/04/2010:Fi

         -- Transferido: El paso a Transferido se debe realizar desde transferencias de forma automática.
         IF v_quants > 0 THEN
            RETURN(110300);
         END IF;
      ELSIF pnuevoestado = 4 THEN
         vpasexec := 3;

         -- Anulado: No se puede anular un reembolso que tenga actos con transferencia generada (fecha de transferencia informada).
         SELECT COUNT(1)
           INTO v_quants
           FROM reembactosfac
          WHERE nreemb = pnreemb
            AND ftrans IS NOT NULL
            AND ROWNUM = 1;

         IF v_quants > 0 THEN
            RETURN(1000654);
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.f_valida_estado_reemb', vpasexec,
                     'error no controlat - ' || vparam, SQLERRM);
         RETURN -1;
   END f_valida_estado_reemb;

--------------------------------------------------------------------------------
   FUNCTION f_valida_fecha_fact(
      pnreemb IN reembolsos.nreemb%TYPE,
      pffact IN DATE,
      pfacuse IN DATE)
      RETURN NUMBER IS
      vpasexec       NUMBER(1) := 1;
      vparam         VARCHAR2(100)
         := 'pnreemb = ' || pnreemb || ', pffact = ' || TO_CHAR(pffact, 'DD/MM/YYYY')
            || ', pfacuse = ' || TO_CHAR(pfacuse, 'DD/MM/YYYY');
      v_fefecto      DATE;
   BEGIN
      IF TRUNC(pffact) > TRUNC(f_sysdate) THEN
         RETURN(180899);
      END IF;

      vpasexec := 2;

      SELECT ri.fefecto
        INTO v_fefecto
        FROM riesgos ri, reembolsos re
       WHERE ri.sseguro = re.sseguro
         AND ri.nriesgo = re.nriesgo
         AND re.nreemb = pnreemb;

      vpasexec := 3;

      IF TRUNC(pffact) < TRUNC(v_fefecto) THEN
         RETURN(180898);
      END IF;

      vpasexec := 4;

      IF NOT(TRUNC(pfacuse) BETWEEN TRUNC(pffact) AND TRUNC(f_sysdate)) THEN
         RETURN(180900);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.f_valida_fecha_fact', vpasexec,
                     'error no controlat - ' || vparam, SQLERRM);
         RETURN -1;
   END f_valida_fecha_fact;

   -- BUG10704:DRA:14/07/2009:Inici
   /***********************************************************************
      Función que actualizará el estado de impresión de la factura
      param in  pnreemb   : codi del reembossament
      param in  pnfact    : codi estat
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_act_factura(pnreemb IN reembfact.nreemb%TYPE, pnfact IN reembfact.nfact%TYPE)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(1) := 1;
      vparam         VARCHAR2(100) := 'pnreemb = ' || pnreemb || ', pnfact = ' || pnfact;
   BEGIN
      UPDATE reembfact
         SET cimpresion = 'S'
       WHERE nreemb = pnreemb
         AND nfact = pnfact;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.f_act_factura', vpasexec,
                     'error no controlat - ' || vparam, SQLERRM);
         RETURN 9000485;
   END f_act_factura;

   /***********************************************************************
      Función que hará el traspaso de una factura a un reembolso ya existente
      param in  pnreemb   : codi del reembossament
      param in  pnfact    : codi estat
      param in  pnfactcli : Número factura cliente
      param in  pnreembori: reembolso al cual tenemos que traspasar la factura
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_traspasar_factura(
      pnreemb IN reembfact.nreemb%TYPE,
      pnfact IN reembfact.nfact%TYPE,
      pnfactcli IN reembfact.nfact_cli%TYPE,
      pnreembori IN reembfact.nreemb%TYPE)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(1) := 1;
      vparam         VARCHAR2(100)
         := 'pnreemb = ' || pnreemb || ', pnfact = ' || pnfact || ', pnfactcli = '
            || pnfactcli || ', pnreembori = ' || pnreembori;
      v_nfact        reembfact.nfact%TYPE;
      v_numregs      NUMBER;
   BEGIN
      -- Miramos si tiene actos hijos, y si es así, abortamos
      SELECT COUNT(1)
        INTO v_numregs
        FROM reembactosfac
       WHERE nreemb = pnreemb
         AND nfact = pnfact;

      IF NVL(v_numregs, 0) > 0 THEN
         RETURN 9001981;
      END IF;

      -- Miramos cual es el último numero de factura
      SELECT MAX(NVL(nfact, 0)) + 1
        INTO v_nfact
        FROM reembfact
       WHERE nreemb = pnreembori;

      UPDATE reembfact
         SET nreemb = pnreembori,
             nfact = v_nfact,
             nfact_cli = UPPER(pnfactcli)
       WHERE nreemb = pnreemb
         AND nfact = pnfact;

      DELETE FROM reembolsos r
            WHERE r.nreemb = pnreemb
              AND NOT EXISTS(SELECT '1'
                               FROM reembfact rf
                              WHERE rf.nreemb = r.nreemb);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.f_traspasar_factura', vpasexec,
                     'error no controlat - ' || vparam, SQLERRM);
         RETURN 9000485;
   END f_traspasar_factura;

   /***********************************************************************
      Función que nos dirá si se puede o no modificar la factura
      param in  pnreemb   : codi del reembossament
      param in  pnfact    : codi estat
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_modif_factura(
      pnreemb IN reembfact.nreemb%TYPE,
      pnfact IN reembfact.nfact%TYPE,
      pcimpresion OUT reembfact.cimpresion%TYPE)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(1) := 1;
      vparam         VARCHAR2(100) := 'pnreemb = ' || pnreemb || ', pnfact = ' || pnfact;
   BEGIN
      SELECT cimpresion
        INTO pcimpresion
        FROM reembfact
       WHERE nreemb = pnreemb
         AND nfact = pnfact;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.f_modif_factura', vpasexec,
                     'error no controlat - ' || vparam, SQLERRM);
         RETURN 9000485;
   END f_modif_factura;

   /***********************************************************************
      Función para detectar si el nº hoja CASS ya existe
      param in pnreemb    : codi del reembossament
      param in  pnfactcli : codi factura client
      param out pnreembdest  : codi del reembossament
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_existe_factcli(
      pnreemb IN reembfact.nreemb%TYPE,
      pnfactcli IN reembfact.nfact_cli%TYPE,
      pnreembdest OUT reembfact.nreemb%TYPE)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(1) := 1;
      vparam         VARCHAR2(100)
                                  := 'pnreemb = ' || pnreemb || ' - pnfactcli = ' || pnfactcli;
      v_ret          NUMBER := 0;
   BEGIN
      BEGIN
         SELECT DISTINCT f.nreemb
                    INTO pnreembdest
                    FROM reembfact f, reembolsos r, reembolsos ree_ori
                   WHERE f.nfact_cli = UPPER(pnfactcli)
                     AND f.nreemb <> pnreemb
                     AND r.nreemb = f.nreemb
                     AND r.cestado <> 4
                     AND ree_ori.nreemb = pnreemb   -- BUG11106:DRA:10/09/2009
                     AND r.sseguro = ree_ori.sseguro   -- BUG11106:DRA:10/09/2009
                     AND r.nriesgo = ree_ori.nriesgo;   -- BUG11106:DRA:10/09/2009
      EXCEPTION
         WHEN TOO_MANY_ROWS THEN
            pnreembdest := NULL;
            v_ret := 9002006;
         WHEN NO_DATA_FOUND THEN
            pnreembdest := NULL;
            v_ret := 0;
      END;

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.f_existe_factcli', vpasexec,
                     'error no controlat - ' || vparam, SQLERRM);
         RETURN 9000485;
   END f_existe_factcli;

   /***********************************************************************
      Función para detectar si la factura es Ordinaria o Complementaria
      param in pnreemb    : codi del reembossament
      param in  pnfact    : codi factura
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_tipo_factura(pnreemb IN reembfact.nreemb%TYPE, pnfact IN reembfact.nfact%TYPE)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(1) := 1;
      vparam         VARCHAR2(100) := 'pnreemb = ' || pnreemb || ' - pnfact = ' || pnfact;
      v_ret          NUMBER := 0;
      vtipofac       reembfact.ctipofac%TYPE;
   BEGIN
      BEGIN
         SELECT f.ctipofac
           INTO vtipofac
           FROM reembfact f
          WHERE f.nreemb = pnreemb
            AND f.nfact = pnfact;
      EXCEPTION
         WHEN OTHERS THEN
            vtipofac := NULL;
            v_ret := 0;
      END;

      IF vtipofac = 0 THEN   --Factura complementaria, no puede dar de alta Actos
         v_ret := 9002035;
      ELSE   --Factura Ordinaria
         v_ret := 0;   -- Todo bien
      END IF;

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.f_tipo_factura', vpasexec,
                     'error no controlat - ' || vparam, SQLERRM);
         RETURN 9000485;
   END f_tipo_factura;

-- BUG10949:JGM:19/08/2009:Fi
   /***********************************************************************
      Función para detectar si la factura tiene fecha de baja y cual
      param in pnreemb    : codi del reembossament
      param in  pnfact    : codi factura
      fbaja out  date    : data baixa
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_get_data_baixa(pnreemb IN NUMBER, pnfact IN NUMBER, pfbaja OUT DATE)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(1) := 1;
      vparam         VARCHAR2(100) := 'pnreemb = ' || pnreemb || ' - pnfact = ' || pnfact;
      v_ret          NUMBER := 0;
      vfbaja         reembfact.fbaja%TYPE := NULL;
   BEGIN
      BEGIN
         SELECT f.fbaja
           INTO vfbaja
           FROM reembfact f
          WHERE f.nreemb = pnreemb
            AND f.nfact = pnfact;
      EXCEPTION
         WHEN OTHERS THEN
            vfbaja := NULL;
            v_ret := 0;
      END;

      pfbaja := vfbaja;
      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.f_get_data_baixa', vpasexec,
                     'error no controlat - ' || vparam, SQLERRM);
         RETURN 9000485;
   END f_get_data_baixa;

   -- BUG10949:JGM:19/08/2009:Fi

   -- BUG17732:DRA:22/02/2011:Inici
   /***********************************************************************
      Función para modificar la CCC del reembolso
      param in pnreemb    : codi del reembossament
      param in pcbancar   : codi CCC
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_modificar_ccc(pnreemb IN NUMBER, pcheck IN NUMBER, pcbancar IN VARCHAR2)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(1) := 1;
      vparam         VARCHAR2(100)
         := 'pnreemb = ' || pnreemb || ' - pcheck = ' || pcheck || ' - pcbancar = '
            || pcbancar;
   BEGIN
      UPDATE reembolsos
         SET cbancar = NVL(pcbancar, cbancar),   -- Si es NULL dejaremos la que hay
             cbanhosp = NVL(pcheck, 0)
       WHERE nreemb = pnreemb;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.f_get_data_baixa', vpasexec,
                     'error no controlat - ' || vparam, SQLERRM);
         RETURN 9000485;
   END f_modificar_ccc;

   /***********************************************************************
      Función para retornar la CCC a grabar en el reembolso
      param in psseguro   : Identificador del seguro
      param in pnreemb    : codi del reembossament
      param out pctipban  : codi tipus banc
      param out pcbancar  : codi CCC
      return              : 0 OK     num_lit ERROR
   ***********************************************************************/
   FUNCTION f_obtener_ccc(
      psseguro IN NUMBER,
      pnreemb IN NUMBER,
      pctipban OUT NUMBER,
      pcbancar OUT VARCHAR2)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(1) := 1;
      vparam         VARCHAR2(100) := 'psseguro = ' || psseguro || ' - pnreemb = ' || pnreemb;
      vsseguro       seguros.sseguro%TYPE;
   BEGIN
      IF pnreemb IS NOT NULL THEN
         SELECT sseguro
           INTO vsseguro
           FROM reembolsos
          WHERE nreemb = pnreemb;
      ELSE
         vsseguro := psseguro;
      END IF;

      vpasexec := 2;

      BEGIN
         --esta respondida la pregun
         BEGIN
            SELECT crespue
              INTO pctipban
              FROM pregunpolseg
             WHERE sseguro = vsseguro
               AND cpregun = 9000
               AND nmovimi = (SELECT MAX(p2.nmovimi)
                                FROM pregunpolseg p2
                               WHERE p2.sseguro = vsseguro
                                 AND p2.cpregun = 9000);   --12025  MCA 27/11/2009  v_movimi;

            vpasexec := 3;

            SELECT trespue
              INTO pcbancar
              FROM pregunpolseg
             WHERE sseguro = vsseguro
               AND cpregun = 9001
               AND nmovimi = (SELECT MAX(p2.nmovimi)
                                FROM pregunpolseg p2
                               WHERE p2.sseguro = vsseguro
                                 AND p2.cpregun = 9001);   --12025  MCA 27/11/2009  v_movimi;
         EXCEPTION
            WHEN OTHERS THEN
               vpasexec := 4;

               -- bug 0010266: etm : 02-06-2009--FIN
               SELECT s.ctipban, s.cbancar
                 INTO pctipban, pcbancar
                 FROM seguros s
                WHERE s.sseguro = vsseguro;
         END;
      EXCEPTION
         WHEN OTHERS THEN
            vpasexec := 5;
            pctipban := NULL;
            pcbancar := NULL;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_REEMBOLSOS.f_obtener_ccc', vpasexec,
                     'error no controlat - ' || vparam, SQLERRM);
         RETURN 180928;
   END f_obtener_ccc;
-- BUG17732:DRA:22/02/2011:Fi
END pac_reembolsos;

/

  GRANT EXECUTE ON "AXIS"."PAC_REEMBOLSOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REEMBOLSOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REEMBOLSOS" TO "PROGRAMADORESCSI";
