--------------------------------------------------------
--  DDL for Package Body PAC_MD_PRESTAMOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_PRESTAMOS" AS
    /******************************************************************************
       NOMBRE:      PAC_MD_PRESTAMOS
       PROPÓSITO:   Contiene las funciones de gestión de los prestamos

       REVISIONES:
       Ver        Fecha        Autor             Descripción
       ---------  ----------  ---------------  ------------------------------------
       1.0        28/09/2011   DRA               1. 0019238: LCOL_T001- Prèstecs de pòlisses de vida
       2.0        24/01/2012   JMF               2. 0019238: LCOL_T001- Prèstecs de pòlisses de vida
       3.0        26/01/2012   JMC               3. 0019238: LCOL_T001- Prèstecs de pòlisses de vida
                                                             (Adaptación tipo moneda)
       4.0       21/03/2012    ETM               4.0021751: LCOL_T001-- Incidencies pantalles de prestecs
       5.0        23/04/2012   JMC               5.0021731: LCOL - Prestecs - Canvis en els model dades
       6.0        29/08/2012   JRH               6.0023252: LCOL_T001-qtracker 4804 / 4801 - dates de prestecs
       7.0        05/09/2012   MDS               7.0023588: LCOL - Canvis pantalles de prestecs
       8.0        12/09/2012   MDS               8.0023653: LCOL_T001-Filtre. El filtre per nom de persona no funciona a axisctr181 (qtracker 4972)
       9.0        12/09/2012   MDS               9.0023588: LCOL - Canvis pantalles de prestecs
      10.0        19/09/2012   MDS              10.0023749: LCOL_T001-Autoritzaci? de prestecs
      11.0        01/10/2012   MDS              11.0023772: LCOL_T001-Reversi? de prestecs
      12.0        25/10/2012   MDS              12. 0024192: LCOL898-Modificacions Notificaci? recaudo CxC
      13.0        05/11/2012   MDS              13. 0024553: LCOL_T001- qtracker 5348 - interessos prestecs anulats/cancelats/reversats
      14.0        30/11/2012   AEG              14. 0024898: LCOL_T001-QT5354: Los prestamos que son cancelados o reversados no deben mostrarse en SIR para eventuales pagos de cuotas.
      15.0        30/11/2012   JRV              15. 0024448: LCOL_T001-LCOL - qtracker 5181 - Calcul venciments quadre amortitzaci?
      16.0        11/03/2013   AMJ              16. 0024448: LCOL_T001-LCOL - qtracker 5181 - Calcul venciments quadre amortitzaci?
      17.0        19/03/2014   RCL              17. 0029952: LCOL895-QT 4345: Validacion de Campos Listado Superfinanciera y otros QT de F1
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   e_salirerror   EXCEPTION;

   FUNCTION f_get_lstprestamos(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psseguro=' || psseguro || ', pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_MD_PRESTAMOS.f_get_lstprestamos';
      vnumerr        NUMBER := 0;
      squery         VARCHAR2(2000);
      cur            sys_refcursor;
   BEGIN
      vpasexec := 1;
      -- Bug 19238/104039 - 18/01/2012 - AMC
      squery :=
         'SELECT p.ctapres, ps.finiprest, ps.ffinprest, p.icapini, '
         -- BUG: 24448  11/03/2012 AMJ
         --|| ' pac_prestamos.f_calc_interesco_prestamo(p.ctapres,p.falta,trunc(f_sysdate),ps.sseguro,ps.finiprest) iinteres, '
         || ' pac_prestamos.f_calc_interesco_total(p.ctapres,p.falta,trunc(f_sysdate),ps.finiprest,ps.sseguro) iinteres, '
         || ' pac_prestamos.f_calc_interesdm_prestamo(p.ctapres,p.falta,trunc(f_sysdate),ps.sseguro,ps.finiprest) idemora, '
         || ' pac_prestamos.f_get_cappend(p.ctapres, p.falta, f_sysdate) icappendiente,'
         || ' p.cestado cestado, ff_desvalorfijo(1058, pac_md_common.f_get_cxtidioma, p.cestado) testado,'
         || ' p.itasa ' || ' FROM prestamos p, prestamoseg ps '
         || ' WHERE p.ctapres = ps.ctapres AND p.falta = ps.falta ' || '   AND ps.sseguro = '
         || psseguro || '   AND ps.nriesgo = ' || NVL(TO_CHAR(pnriesgo), 'ps.nriesgo');
      -- Fi Bug 19238/104039 - 18/01/2012 - AMC
      vpasexec := 2;
      cur := pac_md_listvalores.f_opencursor(squery, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 3;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_lstprestamos;

-- Ini Bug 23588 - 05/09/2012 - MDS
   FUNCTION f_get_pago(pctapres IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prestamopago IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pctapres=' || pctapres;
      vobject        VARCHAR2(200) := 'PAC_MD_PRESTAMOS.f_get_pago';
      vnumerr        NUMBER := 0;
      vtobprestpago  t_iax_prestamopago;
      vticapital     NUMBER := 0;
      vtiinteres     NUMBER := 0;
      vtidemora      NUMBER := 0;
   BEGIN
      vpasexec := 1;
      vtobprestpago := t_iax_prestamopago();

      FOR cur IN (SELECT pp.npago, pp.fefecto, pp.icapital, pp.falta, pp.fcontab,
                         pp.icapital_monpago, pp.cmonpago, pp.fcambio
                    FROM prestamopago pp
                   WHERE pp.ctapres = pctapres) LOOP
         vtobprestpago.EXTEND();
         vtobprestpago(vtobprestpago.LAST) := ob_iax_prestamopago();
         vtobprestpago(vtobprestpago.LAST).npago := cur.npago;
         vtobprestpago(vtobprestpago.LAST).fefecto := cur.fefecto;
         vtobprestpago(vtobprestpago.LAST).icapital := cur.icapital;
         vtobprestpago(vtobprestpago.LAST).falta := cur.falta;
         vtobprestpago(vtobprestpago.LAST).fcontab := cur.fcontab;
         vtobprestpago(vtobprestpago.LAST).icapital_monpago := cur.icapital_monpago;
         vtobprestpago(vtobprestpago.LAST).cmonpago := cur.cmonpago;
         vtobprestpago(vtobprestpago.LAST).fcambio := cur.fcambio;
      END LOOP;

      RETURN vtobprestpago;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_pago;

-- Fin Bug 23588 - 05/09/2012 - MDS
   FUNCTION f_get_detprestamo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pctapres IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes,
      pcuotadesc IN NUMBER DEFAULT 0,
      phastahoy IN NUMBER DEFAULT 0)
      RETURN ob_iax_prestamo IS
      --
      vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(100)
          := 'psseguro=' || psseguro || ', pnriesgo=' || pnriesgo || ', pctapres=' || pctapres;
      vobject        VARCHAR2(200) := 'PAC_MD_PRESTAMOS.f_get_detprestamo';
      vnumerr        NUMBER := 0;
      vobjprest      ob_iax_prestamo := ob_iax_prestamo();
      vobjprestseg   ob_iax_prestamoseg;
      vtprestcua     t_iax_prestcuadro := t_iax_prestcuadro();
      vimppend       NUMBER := 0;
      vsproduc       NUMBER;
      vdatecon       ob_iax_datoseconomicos := ob_iax_datoseconomicos();
      vivalpre       NUMBER;
      vcempres       NUMBER;
      -- BUG 0019238 - 24/01/2012 - JMF
      vporcen        NUMBER;
      vnpoliza       seguros.npoliza%TYPE;
      vncertif       seguros.ncertif%TYPE;
      vctipide       personas.ctipide%TYPE;
      vnnumide       personas.nnumide%TYPE;
      vvalidarecib   NUMBER;
      -- BUG 0023253: LCOL_T001-qtracker 4813 - Primas pagades vs prestecs  HPM
      viotrospre     NUMBER;
      videmora       NUMBER;
      vcmoneda       monedas.cmoneda%TYPE;
      vnum_recpend   NUMBER;
      vivalres       NUMBER;
      ves_migracion  NUMBER;
      v_anuali       NUMBER;
      ves_primeranyo NUMBER;
      vcappend       NUMBER;
      vinteres       NUMBER;
      v_prestamo_cancelado NUMBER := 0;   -- Bug 24553 - MDS - 05/11/2011
      vsucursal      VARCHAR2(300);
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;
      vobjprest.sseguro := psseguro;
      vobjprest.nriesgo := NVL(pnriesgo, 1);
      vpasexec := 2;

      SELECT sproduc, cempres, npoliza, ncertif
        INTO vsproduc, vcempres, vnpoliza, vncertif
        FROM seguros
       WHERE sseguro = psseguro;

      SELECT DECODE(cdivisa, 3, 1, cdivisa)
        INTO vcmoneda
        FROM seguros s, productos p
       WHERE p.sproduc = s.sproduc
         AND s.sseguro = psseguro;

      SELECT t.sperson
        INTO vobjprest.sperson
        FROM tomadores t
       WHERE t.sseguro = psseguro
         AND t.nordtom = (SELECT MIN(t1.nordtom)
                            FROM tomadores t1
                           WHERE t1.sseguro = t.sseguro);

      SELECT ctipide, nnumide
        INTO vctipide, vnnumide
        FROM per_personas
       WHERE sperson = vobjprest.sperson;

      SELECT DECODE(pac_parametros.f_parlistado_n(s.cempres, 'SUCURSAL/ADN'),
                    1, NVL(pac_redcomercial.f_busca_padre(s.cempres, s.cagente, NULL,
                                                          f_sysdate),
                           '0'),
                    NULL)
        INTO vsucursal
        FROM seguros s
       WHERE s.sseguro = psseguro;

      vobjprest.sproduc := vsproduc;
      vobjprest.npoliza := vnpoliza;
      vobjprest.ncertif := vncertif;
      vobjprest.ctipide := vctipide;
      vobjprest.nnumide := vnnumide;
      vobjprest.tsucursal := vsucursal;
      vnumerr := pac_md_datosctaseguro.f_obtdatecon(psseguro, NVL(pnriesgo, 1), f_sysdate,
                                                    vdatecon, mensajes);
      vivalpre := 0;
      -- Inicio  Bug: 0023253: LCOL_T001-qtracker 4813 - Primas pagades vs prestecs  HPM
      vvalidarecib := 0;
      vvalidarecib := pac_prestamos.f_verif_pago_recb(psseguro);

/*      IF (vvalidarecib <= 0) THEN
         IF (vvalidarecib = 0) THEN
            vdatecon.impprovresc :=
               pac_provmat_formul.f_calcul_formulas_provi(psseguro, TRUNC(f_sysdate),
                                                          'IPROVRES');
         ELSE
            vdatecon.impprovresc :=
               pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                          TRUNC(f_sysdate, 'yyyy') - 1,
                                                          'IPROVRES');
         END IF;
      ELSE
         vnumerr := vvalidarecib;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   --JRH
         RAISE e_salirerror;
      END IF;*/-- Si tiene recibos pendientes no se puede dar de alta un prestamo
      -- pero sí que se puede consultar
      IF (vvalidarecib > 0)
         AND pctapres IS NOT NULL THEN
         vnumerr := vvalidarecib;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   --JRH
         RAISE e_salirerror;
      END IF;

      -- averiguar número de recibo pendientes
      SELECT COUNT(*)
        INTO vnum_recpend
        FROM movrecibo r
       WHERE r.nrecibo IN(SELECT nrecibo
                            FROM recibos
                           WHERE sseguro = psseguro)
         AND NVL(f_cestrec(r.nrecibo, TRUNC(f_sysdate)), 0) = 0;

      IF vnum_recpend = 0
                         -- NO hay recibo pendientes
      THEN
         --BUG 29952/169038 - 19/03/2014 - RCL
         vivalres := pac_provmat_formul.f_calcul_formulas_provi(psseguro, TRUNC(f_sysdate),
                                                                'IVALRES');
      ELSE
            -- SI hay recibo pendientes
         -- averiguar si se trata de una póliza de migración
         vnumerr := pac_seguros.f_es_migracion(psseguro, 'SEG', ves_migracion);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            --JRH
            RAISE e_salirerror;
         END IF;

         -- averiguar si es el primer año en IAXIS
         SELECT MONTHS_BETWEEN(f_sysdate, MIN(finiefe)) / 12
           INTO v_anuali
           FROM garanseg
          WHERE sseguro = psseguro
            AND nmovimi = 1;

         IF v_anuali < 1 THEN
            ves_primeranyo := 1;
         ELSE
            ves_primeranyo := 0;
         END IF;

         -- calcular la provisión
         IF ves_primeranyo = 1
            AND ves_migracion = 1 THEN
            -- primer año en iaxis, y la póliza es de migración
            vivalres := pac_propio.f_calc_prov_migrada(psseguro, NVL(pnriesgo, 1));
         ELSIF ves_primeranyo = 1
               AND ves_migracion = 0 THEN
            -- primer año en iaxis, y la póliza NO es de migración
            -- no permitir el préstamo
            vnumerr := 9904110;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            --JRH
            RAISE e_salirerror;
         ELSIF ves_primeranyo = 0 THEN
            -- NO es el primer año en iaxis, y tanto da si la póliza es de migración o no
            vivalres :=
               pac_provmat_formul.f_calcul_formulas_provi(psseguro,
                                                          TO_DATE(frenovacion(NULL, psseguro,
                                                                              2),
                                                                  'yyyymmdd')
                                                          - 1,
                                                          'IPROVRES');
         END IF;
      END IF;

      vdatecon.impprovresc := vivalres;
      -- Inicio BUG 0023344: LCOL_T001-Para las p?lizas que tienen financiaciones no se
      --                     le pueden realizar prestamos y debe traer el saldo de la deuda HPM
      --vnumerr := pac_iax_con.f_importe_financiacion_pdte(psseguro, vivalpre, mensajes);
      -- FIN BUG 0023344: LCOL_T001-Para las p?lizas que tienen financiaciones no se
      --                    le pueden realizar prestamos y debe traer el saldo de la deuda HPM

      -- Fin  Bug: 0023253: LCOL_T001-qtracker 4813 - Primas pagades vs prestecs  HPM

      -- fin BUG 0023254: LCOL - qtrackers 4806 / 4808. Màxim dels prestecs. HPM

      /***********************
      FOR x IN (SELECT   p.ctapres, p.falta
                    FROM prestamos p, prestamoseg ps, tomadores t
                   WHERE ps.ctapres = p.ctapres
                     AND ps.falta = p.falta
                     AND t.sseguro = ps.sseguro
                     AND t.sperson = vobjprest.sperson
                     AND p.cestado = 1
                     AND ps.sseguro <> psseguro
                ORDER BY p.ctapres) LOOP
         vivalpre := vivalpre + pac_prestamos.f_get_cappend(x.ctapres, x.falta, f_sysdate);
      END LOOP;
      ******************/
      viotrospre := 0;

      FOR x IN (SELECT   p.ctapres, p.falta, ps.finiprest
                    FROM prestamos p, prestamoseg ps
                   WHERE ps.ctapres = p.ctapres
                     AND ps.falta = p.falta
                     AND p.cestado = 1
                     AND ps.sseguro = psseguro
                ORDER BY p.ctapres) LOOP
         -- Ini Bug 24553 - MDS - 05/11/2011, saber si el préstamo está cancelado a fecha de hoy
         v_prestamo_cancelado := pac_prestamos.f_prestamo_cancelado(x.ctapres, TRUNC(x.falta),
                                                                    TRUNC(f_sysdate));

         -- Fin Bug 24553 - MDS - 05/11/2011
         FOR reg IN (SELECT *
                       FROM prestcuadro
                      WHERE ctapres = x.ctapres
                        AND falta = x.falta
                        AND ffincua IS NULL
                        AND fpago IS NULL) LOOP
            -- Bug 24553 - MDS - 05/11/2011, si lo está el interés es 0 sinó calculado
            IF v_prestamo_cancelado = 1 THEN
               videmora := 0;
            ELSE
               vnumerr := pac_prestamos.f_calc_demora_cuota_prorr(vcmoneda, reg.icapital,
                                                                  x.finiprest, reg.fvencim,
                                                                  psseguro, vsproduc,
                                                                  TRUNC(f_sysdate), videmora);
            END IF;

            --- Se deben considerar los intereses diarios
            ----viotrospre := viotrospre + reg.icapital + reg.iinteres + NVL(videmora, 0);
            viotrospre := viotrospre + reg.icapital + NVL(videmora, 0);
         END LOOP;

         vcappend := pac_prestamos.f_get_cappend(x.ctapres, x.falta, TRUNC(f_sysdate));

         -- Bug 24553 - MDS - 05/11/2011, si lo está el interés es 0 sinó calculado
         IF v_prestamo_cancelado = 1 THEN
            vinteres := 0;
         ELSE
            -- BUG: 24448 11/03/2013 AMJ
              /* vnumerr := pac_prestamos.f_calc_interes(vcmoneda, vcappend, x.finiprest, psseguro,
                                                       vsproduc, TRUNC(f_sysdate), vinteres);*/
             -- BUG: 24448 11/03/2013 AMJ
            --BUG 29952/169038 - 19/03/2014 - RCL
            vinteres := pac_prestamos.f_calc_interesco_total(x.ctapres, x.falta,
                                                             TRUNC(f_sysdate), x.finiprest,
                                                             psseguro);
         END IF;

         viotrospre := viotrospre + NVL(vinteres, 0);
      END LOOP;

      vobjprest.ivalpre := NVL(viotrospre, 0);
      --vobjprest.ivaldis := 0;
      -- INICIO BUG 0023254: LCOL - qtrackers 4806 / 4808. Màxim dels prestecs. HPM
      vporcen := pac_parametros.f_parproducto_n(vsproduc, 'PREST_POR_DISP');

      IF vporcen IS NOT NULL THEN
         vobjprest.ivaldis := (vdatecon.impprovresc *(vporcen / 100)) - vobjprest.ivalpre;
      ELSE
         vobjprest.ivaldis := 0;
      END IF;

      -- FIN BUG 0023254: LCOL - qtrackers 4806 / 4808. Màxim dels prestecs. HPM
      IF pctapres IS NOT NULL THEN
         vpasexec := 3;

         SELECT p.ctapres, p.ctippres, p.ctipint, p.icapini,
                p.falta, p.cestado, p.itasa, p.ctipban,
                p.cbancar, p.cforpag, p.icapini_moncia,
                p.fcambio,
                ff_desvalorfijo(1058, pac_md_common.f_get_cxtidioma, p.cestado) testado   -- Bug 23588 - 12/09/2012 - MDS
           INTO vobjprest.ctapres, vobjprest.ctippres, vobjprest.ctipint, vobjprest.icapini,
                vobjprest.falta, vobjprest.cestado, vobjprest.itasa, vobjprest.ctipban,
                vobjprest.cbancar, vobjprest.cforpag, vobjprest.icapini_moncia,
                vobjprest.fcambio,
                vobjprest.testado   -- Bug 23588 - 12/09/2012 - MDS
           FROM prestamos p
          WHERE p.ctapres = pctapres
            AND p.falta = (SELECT MAX(p1.falta)
                             FROM prestamos p1
                            WHERE p1.ctapres = p.ctapres);

         vpasexec := 4;
         vnumerr := 0;
         vobjprestseg := pac_md_prestamos.f_get_prestamoseg(psseguro, NVL(pnriesgo, 1),
                                                            pctapres, vnumerr, mensajes);

         IF vnumerr <> 0
            AND mensajes IS NOT NULL THEN
            IF mensajes.COUNT > 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;

         vpasexec := 5;
         vobjprest.finiprest := vobjprestseg.finiprest;
         vobjprest.ffinprest := vobjprestseg.ffinprest;
         vpasexec := 6;
         vtprestcua := pac_md_prestamos.f_get_prestcuadro(pctapres, vobjprestseg.cmoneda,
                                                          psseguro, vcempres, mensajes,
                                                          pcuotadesc, phastahoy);
         vpasexec := 7;

         IF mensajes IS NOT NULL THEN
            IF mensajes.COUNT > 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;

         IF vtprestcua IS NOT NULL THEN
            IF vtprestcua.COUNT > 0 THEN
               FOR vreg IN vtprestcua.FIRST .. vtprestcua.LAST LOOP
                  IF vtprestcua.EXISTS(vreg) THEN
                     vimppend := vimppend + NVL(vtprestcua(vreg).icappend, 0);
                  END IF;
               END LOOP;
            END IF;
         END IF;

         vpasexec := 8;
         vobjprest.cuadro := vtprestcua;
         vpasexec := 9;
         vobjprest.ipendent := 0;
         --Se tiene que recuperar por interficie--NVL(vimppend, 0);
         vpasexec := 10;
         vobjprest.cuotas := t_iax_prestamocuotas();
         vpasexec := 11;
         -- Bug 19238/104039 - 18/01/2012 - AMC
         vobjprest.cuotas := pac_md_prestamos.f_get_cuotas(pctapres, vobjprest.ticapitalcuota,
                                                           vobjprest.tiinterescuota,
                                                           vobjprest.tidemoracuota, mensajes);
         -- Fi Bug 19238/104039 - 18/01/2012 - AMC
         vpasexec := 12;

         IF mensajes IS NOT NULL THEN
            IF mensajes.COUNT > 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;

-- Ini Bug 23588 - 05/09/2012 - MDS
         vpasexec := 30;
         vobjprest.pago := t_iax_prestamopago();
         vobjprest.pago := pac_md_prestamos.f_get_pago(pctapres, mensajes);
         vpasexec := 31;

         IF mensajes IS NOT NULL THEN
            IF mensajes.COUNT > 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;

-- Fin Bug 23588 - 05/09/2012 - MDS
         vobjprest.ivalres := vdatecon.impprovresc;
         vpasexec := 13;

         --vobjprest.ivalpre := 2;

         -- ini BUG 0019238 - 24/01/2012 - JMF
         IF vobjprest.ivalres < 0 THEN
            -- Per concedir anticip, el valor de rescat ha de ser superior a cero.
            vnumerr := 9903165;
            RAISE e_salirerror;
         END IF;

         -- fin BUG 0019238 - 24/01/2012 - JMF
         vobjprest.isaldo := pac_prestamos.f_get_cappend(vobjprest.ctapres, vobjprest.falta,
                                                         TRUNC(f_sysdate));
         vpasexec := 14;

         -- Bug 19238/104039 - 18/01/2012 - AMC
         BEGIN
            SELECT fefecto
              INTO vobjprest.forden
              FROM prestamopago
             WHERE ctapres = pctapres
               AND npago = (SELECT MAX(npago)
                              FROM prestamopago
                             WHERE ctapres = pctapres);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vobjprest.forden := TRUNC(f_sysdate);
         END;

         -- Fi Bug 19238/104039 - 18/01/2012 - AMC
         vpasexec := 15;

         --SELECT TO_DATE('01' || TO_CHAR(fvencim, 'mmyyyy'), 'ddmmyyyy') --JRH No es això
         SELECT fefecto
           INTO vobjprest.fcuota1
           FROM prestcuadro
          WHERE ctapres = pctapres
            AND falta = vobjprest.falta
            AND fvencim = (SELECT MIN(fvencim)
                             FROM prestcuadro
                            WHERE ctapres = pctapres
                              AND falta = vobjprest.falta
                              AND ffincua IS NULL)
            AND ffincua IS NULL;   -->> Sólo cuadros vigentes
      ELSE
         vpasexec := 20;
         vobjprest.ctapres := NULL;
         vobjprest.ctippres := 3;   -- Anticipo
         vobjprest.ctipint := 1;   -- Fijo
         vobjprest.cestado := 0;   -- Abierto
         vobjprest.icapini := 0;
         vobjprest.falta := f_sysdate;
         vobjprest.finiprest := f_sysdate;
         vpasexec := 22;
         vnumerr := pac_seguros.f_get_sproduc(psseguro, 'POL', vsproduc);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         vpasexec := 23;
         vnumerr := pac_md_prestamos.f_obtener_porcentaje(f_sysdate, vsproduc, vobjprest.itasa,
                                                          mensajes);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            --JRH
            RAISE e_object_error;
         END IF;

         vpasexec := 24;
         vobjprest.ipendent := NVL(vimppend, 0);
         vpasexec := 25;

         SELECT MAX(nmovimi)
           INTO vobjprest.nmovimi
           FROM movseguro
          WHERE sseguro = psseguro;

         vpasexec := 26;
         vobjprest.ctipban := NULL;
         vobjprest.cbancar := NULL;
         --vobjprest.ivalpre := 2;
         vobjprest.ivalres := vdatecon.impprovresc;

         -- ini BUG 0019238 - 24/01/2012 - JMF
         IF vobjprest.ivalres < 0 THEN
            -- Per concedir anticip, el valor de rescat ha de ser superior a cero.
            vnumerr := 9903165;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_salirerror;
         END IF;

         -- fin BUG 0019238 - 24/01/2012 - JMF
         vobjprest.isaldo := 0;
         vpasexec := 27;
         vobjprest.cuotas := t_iax_prestamocuotas();
         vobjprest.forden := f_sysdate;
         vobjprest.ffinprest := ADD_MONTHS(vobjprest.forden, 12);
         -- inicio BUG 0023252: LCOL_T001-qtracker 4804 / 4801 - dates de prestecs  09/08/2012 HPM
         vobjprest.fcuota1 := ADD_MONTHS(vobjprest.forden, 1);
      -- fin BUG 0023252 09/08/2012 HPM
      END IF;

      RETURN vobjprest;
   EXCEPTION
      WHEN e_salirerror THEN
         -- BUG 0019238 - 24/01/2012 - JMF
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
         RETURN NULL;
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_detprestamo;

   FUNCTION f_consulta_presta(
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pctapres IN VARCHAR2,
      pnnumide IN VARCHAR2,
      psnip IN VARCHAR2,
      pbuscar IN VARCHAR2,
      ptipoper IN NUMBER,
      pcactivi IN NUMBER,
      pfiltro IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'pcramo=' || pcramo || ', psproduc=' || psproduc || ', pnpoliza=' || pnpoliza
            || ', pncertif=' || pncertif || ', pctapres=' || pctapres || ', pnnumide='
            || pnnumide || ', psnip=' || psnip || ', pbuscar=' || pbuscar || ', ptipoper='
            || ptipoper || ', pcactivi=' || pcactivi || ', pfiltro=' || pfiltro;
      vobject        VARCHAR2(200) := 'PAC_MD_PRESTAMOS.f_consulta_presta';
      vnumerr        NUMBER := 0;
      squery         VARCHAR2(4000);
      buscar         VARCHAR2(2000) := NULL;
      subus          VARCHAR2(500);
      auxnom         VARCHAR2(200);
      tabtp          VARCHAR2(10) := NULL;
      vsseguro       NUMBER;
      vsproduc       NUMBER;
      vnpoliza       NUMBER;
      vncertif       NUMBER;
      vcactivi       NUMBER;
      vcramo         NUMBER;
      vdescprod      VARCHAR2(32000);
      vdesagente     VARCHAR2(32000);
      vtactivi       VARCHAR2(32000);
      vtnomtom       VARCHAR2(32000);
      cur            sys_refcursor;
      v_perprest     NUMBER;
   BEGIN
      vpasexec := 1;

      IF pcramo IS NOT NULL THEN
         buscar := buscar || ' AND s.cramo = ' || pcramo;
      END IF;

      vpasexec := 2;

      IF psproduc IS NOT NULL THEN
         buscar := buscar || ' AND s.sproduc = ' || psproduc;
      END IF;

      vpasexec := 3;

      IF pnpoliza IS NOT NULL THEN
         buscar := buscar || ' AND s.npoliza = ' || pnpoliza;
      END IF;

      vpasexec := 4;

      IF pncertif IS NOT NULL THEN
         buscar := buscar || ' AND s.ncertif = ' || pncertif;
      END IF;

      vpasexec := 5;
      -- ini BUG 0019238 - 24/01/2012 - JMF
      buscar := buscar || ' AND s.csituac=0 and s.cempres=' || pac_md_common.f_get_cxtempresa
                                                                                             ();

      -- fin BUG 0019238 - 24/01/2012 - JMF

      -- buscar per personas
      IF (pnnumide IS NOT NULL
          OR NVL(psnip, ' ') <> ' '
          OR pbuscar IS NOT NULL)
         AND NVL(ptipoper, 0) > 0 THEN
         --
         vpasexec := 6;

         IF ptipoper = 1 THEN   -- Prenador
            tabtp := 'tomadores';
         ELSIF ptipoper = 2 THEN   -- Asegurat
            tabtp := 'asegurados';
         END IF;

         vpasexec := 7;

         IF tabtp IS NOT NULL THEN
            subus := ' and s.sseguro IN (SELECT a.sseguro FROM ' || tabtp
                     || ' a, personas p WHERE a.sperson = p.sperson';
            vpasexec := 8;

            IF ptipoper = 2 THEN   -- Asegurat
               subus := subus || ' AND a.ffecfin IS NULL';
            END IF;

            vpasexec := 9;

            IF pnnumide IS NOT NULL THEN
               --Bug 371152-21271 Busqueda de NIF minuscula KJSC 27/08/2015
               IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                    'NIF_MINUSCULAS'),
                      0) = 1 THEN
                  subus := subus || ' AND UPPER(p.nnumnif)= UPPER(' || CHR(39) || pnnumide
                           || CHR(39) || ')';
               ELSE
                  subus := subus || ' AND p.nnumnif = ' || CHR(39) || pnnumide || CHR(39)
                           || '';
               END IF;
            END IF;

            vpasexec := 10;

            IF NVL(psnip, ' ') <> ' ' THEN
               subus := subus || ' AND upper(p.snip)=upper(' || CHR(39) || psnip || CHR(39)
                        || ')';
            END IF;

            vpasexec := 11;

            IF pbuscar IS NOT NULL THEN
               vnumerr := f_strstd(pbuscar, auxnom);
               subus := subus || ' AND upper(p.tbuscar) like upper(''%' || auxnom || '%'
                        || CHR(39) || ')';
            END IF;

            subus := subus || ')';
         END IF;
      END IF;

      vpasexec := 12;

      IF pctapres IS NOT NULL THEN
         buscar := buscar || ' AND s.sseguro IN (SELECT ps.sseguro FROM prestamoseg ps'
                   || ' WHERE ps.ctapres = ' || pctapres || ') ';
      END IF;

      vpasexec := 13;

      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'FILTRO_AGE'), 0) =
                                                                                              1 THEN
         buscar := buscar || ' AND s.cagente IN (SELECT a.cagente '
                   || ' FROM (SELECT LEVEL nivel, cagente '
                   || '         FROM redcomercial r WHERE r.fmovfin IS NULL '
                   || '        START WITH r.cagente = pac_md_common.f_get_cxtagente() '
                   || '               AND r.cempres = pac_md_common.f_get_cxtempresa() '
                   || '               AND r.fmovfin is null '
                   || '        CONNECT BY PRIOR r.cagente =(r.cpadre + 0) '
                   || '               AND PRIOR r.cempres =(r.cempres + 0) '
                   || '               AND r.fmovfin IS NULL '
                   || '               AND r.cagente >= 0) rr, agentes a '
                   || ' WHERE rr.cagente = a.cagente)';
      END IF;

      vpasexec := 14;
      squery :=
         'SELECT s.sseguro, s.sproduc, s.npoliza, s.ncertif, s.cactivi, s.cramo, '
         || '    f_desproducto_t (s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, '
         || '    pac_md_common.f_get_cxtidioma) tproduc, ff_desagente (s.cagente) tagente, '
         || '    ff_desactividad (s.cactivi, s.cramo, pac_md_common.f_get_cxtidioma) tactivi, '
         || '    f_nombre (t.sperson, 1, pac_md_common.f_get_cxtagente()) tnomtom '
         || ' FROM seguros s, tomadores t WHERE t.sseguro = s.sseguro '
         || '  AND t.nordtom = (SELECT MIN (t1.nordtom) FROM tomadores t1 WHERE t1.sseguro = t.sseguro) '
         -- Ini Bug 23653 - MDS - 12/09/2012
         || '  AND NVL(pac_parametros.f_parproducto_n(s.sproduc, ''PERMITE_PREST''), 0) <> 0 '
         -- Fin Bug 23653 - MDS - 12/09/2012
         || buscar || subus;
      -- ini BUG 0019238 - 24/01/2012 - JMF
      vpasexec := 15;

      IF pac_md_log.f_log_consultas(squery, 'PAC_MD_PRESTAMOS.F_CONSULTA_PRESTA', 1, 2,
                                    mensajes) = 0 THEN
         NULL;
      END IF;

      -- fin BUG 0019238 - 24/01/2012 - JMF
      vpasexec := 16;
      cur := pac_md_listvalores.f_opencursor(squery, mensajes);

      -- Bug 21751/110708 - 21/03/2012  - ETM  --INI
      FETCH cur
       INTO vsseguro, vsproduc, vnpoliza, vncertif, vcactivi, vcramo, vdescprod, vdesagente,
            vtactivi, vtnomtom;

      IF cur%NOTFOUND THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903473);
         RAISE e_object_error;
      ELSE
         v_perprest := NVL(pac_parametros.f_parproducto_n(vsproduc, 'PERMITE_PREST'), 0);

         IF v_perprest = 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903473);
            RAISE e_object_error;
         END IF;
      END IF;

      CLOSE cur;

      cur := pac_md_listvalores.f_opencursor(squery, mensajes);

      -- FIN Bug 21751/110708 - 21/03/2012  - ETM
      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 17;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_consulta_presta;

   FUNCTION f_consulta_lstprst(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pctapres IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
          := 'psseguro=' || psseguro || ', pnriesgo=' || pnriesgo || ', pctapres=' || pctapres;
      vobject        VARCHAR2(200) := 'PAC_MD_PRESTAMOS.f_consulta_lstprst';
      vnumerr        NUMBER := 0;
      squery         VARCHAR2(4000);
      buscar         VARCHAR2(2000) := NULL;
      subus          VARCHAR2(500);
      auxnom         VARCHAR2(200);
      tabtp          VARCHAR2(10) := NULL;
      cur            sys_refcursor;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      -- BUG 22650-118888-20120726-JLTS-Se adiciona el campo ICAPPEND (pac_prestamos.f_get_cappend(p.ctapres, p.falta, f_sysdate)
      squery :=
         'SELECT s.sseguro, s.npoliza, s.ncertif, ps.ctapres, ps.nriesgo, s.sproduc, '
         || ' f_nombre (t.sperson, 1, pac_md_common.f_get_cxtagente()) tnomtom, '
         || ' f_desproducto_t (s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1, '
         || ' pac_md_common.f_get_cxtidioma) tproduc, ps.finiprest, ps.ffinprest, '
         || ' ps.icapital, pac_prestamos.f_get_cappend(p.ctapres, p.falta, TRUNC(f_sysdate)) icappend, '
         || ' ps.isaldo, p.cestado, ff_desvalorfijo (1058, pac_md_common.F_GET_CXTIDIOMA, p.cestado) testado '
         -- Ini Bug : 23588 - MDS - 17/09/2012
         || ', pac_prestamos.f_get_totalpend(p.ctapres, p.falta, TRUNC(f_sysdate), s.sseguro, s.sproduc, NULL, TRUNC(ps.finiprest)) ITOTALPEND'
         -- Fin Bug : 23588 - MDS - 17/09/2012
         || ' FROM seguros s, tomadores t, prestamoseg ps, prestamos p WHERE s.sseguro = '
         || psseguro
         || ' AND t.sseguro = s.sseguro AND t.nordtom = (SELECT MIN (t1.nordtom) FROM tomadores t1 WHERE t1.sseguro = t.sseguro) ';

      IF pctapres IS NOT NULL THEN
         squery := squery || ' AND ps.ctapres = ' || pctapres;
      END IF;

      squery := squery || ' AND ps.sseguro = s.sseguro';

      IF pnriesgo IS NOT NULL THEN
         squery := squery || ' AND ps.nriesgo = ' || pnriesgo;
      END IF;

      squery :=
         squery
         || ' AND p.ctapres = ps.ctapres AND p.falta = (SELECT MAX (p1.falta) FROM prestamos p1 '
         || ' WHERE p1.ctapres = p.ctapres) ';
      vpasexec := 3;
      cur := pac_md_listvalores.f_opencursor(squery, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 4;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_consulta_lstprst;

   FUNCTION f_get_prestamoseg(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pctapres IN VARCHAR2,
      pnerror OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_prestamoseg IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
          := 'psseguro=' || psseguro || ', pnriesgo=' || pnriesgo || ', pctapres=' || pctapres;
      vobject        VARCHAR2(200) := 'PAC_MD_PRESTAMOS.f_get_prestamoseg';
      vnumerr        NUMBER := 0;
      vobprestseg    ob_iax_prestamoseg;
      t_cuadroseg    t_iax_prestcuadroseg;
      v_falta        DATE;
      v_nmovimi      NUMBER;
   BEGIN
      vpasexec := 1;
      vnumerr := pac_prestamos.f_fecha_ult_prest(pctapres, v_falta);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 2;

      SELECT MAX(ps.nmovimi)
        INTO v_nmovimi
        FROM prestamoseg ps
       WHERE ps.sseguro = psseguro
         AND ps.nriesgo = pnriesgo
         AND ps.ctapres = pctapres;

      vpasexec := 3;
      vobprestseg := ob_iax_prestamoseg();

      SELECT ps.sseguro, ps.nmovimi, ps.finiprest,
             ps.ffinprest, ps.pporcen, ps.ctapres,
             ps.ctipcuenta,
             ff_desvalorfijo(401, pac_md_common.f_get_cxtidioma, ps.ctipcuenta),
             ps.descripcion, ps.ctipban, tc.ttipo,
             ps.ctipimp, ff_desvalorfijo(402, pac_md_common.f_get_cxtidioma, ps.ctipimp),
             ps.isaldo, ps.porcen, ps.ilimite, ps.icapmax,
             ps.icapital, ps.cmoneda, ps.icapaseg,
             ps.falta, 1
        INTO vobprestseg.sseguro, vobprestseg.nmovimi, vobprestseg.finiprest,
             vobprestseg.ffinprest, vobprestseg.pporcen, vobprestseg.idcuenta,
             vobprestseg.ctipcuenta,
             vobprestseg.ttipcuenta,
             vobprestseg.descripcion, vobprestseg.ctipban, vobprestseg.ttipban,
             vobprestseg.ctipimp, vobprestseg.ttipimp,
             vobprestseg.isaldo, vobprestseg.porcen, vobprestseg.ilimite, vobprestseg.icapmax,
             vobprestseg.icapital, vobprestseg.cmoneda, vobprestseg.icapaseg,
             vobprestseg.falta, vobprestseg.selsaldo
        FROM prestamos p, prestamoseg ps, tipos_cuentades tc
       WHERE p.ctapres = pctapres
         AND p.falta = v_falta
         AND ps.ctapres = p.ctapres
         AND ps.sseguro = psseguro
         AND ps.nriesgo = pnriesgo
         AND ps.nmovimi = v_nmovimi
         AND tc.ctipban(+) = p.ctipban
         AND tc.cidioma(+) = pac_md_common.f_get_cxtidioma;

      vpasexec := 4;
      t_cuadroseg := t_iax_prestcuadroseg();
      vpasexec := 5;

      FOR cur IN (SELECT ctapres, sseguro, nmovimi, finicuaseg, ffincuaseg, fefecto, fvencim,
                         icapital, iinteres, icappend, falta
                    FROM prestcuadroseg
                   WHERE sseguro = psseguro
                     AND ctapres = pctapres
                     AND falta = v_falta) LOOP
         t_cuadroseg.EXTEND();
         t_cuadroseg(t_cuadroseg.LAST) := ob_iax_prestcuadroseg();
         t_cuadroseg(t_cuadroseg.LAST).sseguro := cur.sseguro;
         t_cuadroseg(t_cuadroseg.LAST).nmovimi := cur.nmovimi;
         t_cuadroseg(t_cuadroseg.LAST).ctapres := cur.ctapres;
         t_cuadroseg(t_cuadroseg.LAST).finicuaseg := cur.finicuaseg;
         t_cuadroseg(t_cuadroseg.LAST).ffincuaseg := cur.ffincuaseg;
         t_cuadroseg(t_cuadroseg.LAST).fefecto := cur.fefecto;
         t_cuadroseg(t_cuadroseg.LAST).fvencim := cur.fvencim;
         t_cuadroseg(t_cuadroseg.LAST).icapital := cur.icapital;
         t_cuadroseg(t_cuadroseg.LAST).iinteres := cur.iinteres;
         t_cuadroseg(t_cuadroseg.LAST).icappend := cur.icappend;
         t_cuadroseg(t_cuadroseg.LAST).icuota := NVL(cur.icapital, 0) + NVL(cur.iinteres, 0);
         t_cuadroseg(t_cuadroseg.LAST).falta := cur.falta;
      END LOOP;

      vpasexec := 6;
      vobprestseg.cuadro := t_cuadroseg;
      pnerror := 0;
      RETURN vobprestseg;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         pnerror := 1;
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         pnerror := 1;
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         pnerror := 1;
         RETURN NULL;
   END f_get_prestamoseg;

   FUNCTION f_get_prestamos(
      pctipdoc IN NUMBER,
      ptdoc IN VARCHAR2,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pctapres IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes,
      -- 2012/11/30 aeg BUG:0024898 se agrega el sig. parametro.
      pcestado IN NUMBER DEFAULT NULL,
      pcuotadesc IN NUMBER DEFAULT 0,
      phastahoy IN NUMBER DEFAULT 0)
      RETURN t_iax_prestamo IS
      vsolicit       NUMBER(6);

      CURSOR personas IS
         SELECT t.sseguro
           FROM tomadores t, per_personas p, seguros s
          WHERE p.sperson = t.sperson
            AND p.ctipide = pctipdoc
            AND p.nnumide = ptdoc
            AND s.sseguro = t.sseguro
            AND((s.npoliza = pnpoliza
                 AND s.ncertif = pncertif)
                OR pnpoliza IS NULL);

      -- 2012/11/30 aeg bug: 0024898: LCOL_T001-QT5354
      -- se modifica el query para tomas solo nmovimis con movimiento igual al parametro creado = 1
      CURSOR polseg IS
         SELECT d.*
           FROM prestamoseg d
          WHERE d.sseguro = vsolicit
            AND d.nmovimi = (SELECT MAX(nmovimi)
                               FROM prestamoseg es
                              WHERE es.sseguro = vsolicit
                                AND(es.ctapres = pctapres
                                    OR pctapres IS NULL))
            AND(d.ctapres = pctapres
                OR pctapres IS NULL)
            AND pcestado = (SELECT cestado
                              FROM mov_prestamos mp
                             WHERE mp.ctapres = d.ctapres
                               AND fmovfin IS NULL);

      vtprestamo     t_iax_prestamo := t_iax_prestamo();
      vobprestseg    ob_iax_prestamo := ob_iax_prestamo();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'pctipdoc: ' || pctipdoc || ', ptdoc: ' || ptdoc || ', pnpoliza: ' || pnpoliza
            || ', pncertif: ' || pncertif || ', pctapres: ' || pctapres;
      vobject        VARCHAR2(200) := 'PAC_MD_PRESTAMOS.F_get_prestamos';
      vctapres       prestamos.ctapres%TYPE;
      e_poliza_noencontrada EXCEPTION;
      e_prestamo_noencontrado EXCEPTION;
   BEGIN
      IF pctipdoc IS NOT NULL
         AND ptdoc IS NOT NULL THEN
         FOR psegper IN personas LOOP
            vsolicit := psegper.sseguro;
            vpasexec := 2;

            FOR pseg IN polseg LOOP
               vpasexec := 3;
               vobprestseg := pac_md_prestamos.f_get_detprestamo(pseg.sseguro, pseg.nriesgo,
                                                                 pseg.ctapres, mensajes,
                                                                 pcuotadesc, phastahoy);
               vtprestamo.EXTEND;
               vtprestamo(vtprestamo.LAST) := vobprestseg;
               vobprestseg := ob_iax_prestamo();
            END LOOP;
         END LOOP;
      ELSIF pnpoliza IS NOT NULL
            AND pncertif IS NOT NULL THEN
         vpasexec := 4;

         BEGIN
            SELECT sseguro
              INTO vsolicit
              FROM seguros
             WHERE npoliza = pnpoliza
               AND ncertif = pncertif
               AND csituac = 0
               AND NVL(pac_parametros.f_parproducto_n(sproduc, 'PERMITE_PREST'), 0) = 1;
         EXCEPTION
            WHEN OTHERS THEN
               vsolicit := NULL;
               RAISE e_poliza_noencontrada;
         END;

         FOR pseg IN polseg LOOP
            vpasexec := 5;
            vobprestseg := pac_md_prestamos.f_get_detprestamo(pseg.sseguro, pseg.nriesgo,
                                                              pseg.ctapres, mensajes,
                                                              pcuotadesc, phastahoy);
            vtprestamo.EXTEND;
            vtprestamo(vtprestamo.LAST) := vobprestseg;
            vobprestseg := ob_iax_prestamo();
         END LOOP;
      ELSIF pctapres IS NOT NULL THEN
         vpasexec := 6;

         BEGIN
            SELECT sseguro
              INTO vsolicit
              FROM prestamoseg
             WHERE ctapres = pctapres;
         EXCEPTION
            WHEN OTHERS THEN
               vsolicit := NULL;
               RAISE e_prestamo_noencontrado;
         END;

         FOR pseg IN polseg LOOP
            vpasexec := 7;
            vobprestseg := pac_md_prestamos.f_get_detprestamo(pseg.sseguro, pseg.nriesgo,
                                                              pseg.ctapres, mensajes,
                                                              pcuotadesc, phastahoy);
            vtprestamo.EXTEND;
            vtprestamo(vtprestamo.LAST) := vobprestseg;
            vobprestseg := ob_iax_prestamo();
         END LOOP;
      ELSE
         RAISE e_param_error;
      END IF;

      RETURN vtprestamo;
   EXCEPTION
      WHEN e_poliza_noencontrada THEN
         IF personas%ISOPEN THEN
            CLOSE personas;
         END IF;

         IF polseg%ISOPEN THEN
            CLOSE polseg;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9903473, vpasexec, vparam);
         RETURN NULL;
      WHEN e_prestamo_noencontrado THEN
         IF personas%ISOPEN THEN
            CLOSE personas;
         END IF;

         IF polseg%ISOPEN THEN
            CLOSE polseg;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9904181, vpasexec, vparam);
         RETURN NULL;
      WHEN e_param_error THEN
         IF personas%ISOPEN THEN
            CLOSE personas;
         END IF;

         IF polseg%ISOPEN THEN
            CLOSE polseg;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         IF personas%ISOPEN THEN
            CLOSE personas;
         END IF;

         IF polseg%ISOPEN THEN
            CLOSE polseg;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         IF personas%ISOPEN THEN
            CLOSE personas;
         END IF;

         IF polseg%ISOPEN THEN
            CLOSE polseg;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_prestamos;

   FUNCTION f_get_prestcuadro(
      pctapres IN VARCHAR2,
      pcmoneda IN VARCHAR2,
      psseguro IN NUMBER,
      pcempres IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pcuotadesc IN NUMBER DEFAULT 0,
      phastahoy IN NUMBER DEFAULT 0)
      RETURN t_iax_prestcuadro IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pctapres=' || pctapres;
      vobject        VARCHAR2(200) := 'PAC_MD_PRESTAMOS.f_get_prestcuadro';
      vnumerr        NUMBER := 0;
      vncuota        NUMBER;
      vfiniprest     DATE;
      vtobprestcua   t_iax_prestcuadro;
      v_cmonemp_t    monedas.cmoneda%TYPE;
      v_cmonprod_t   monedas.cmoneda%TYPE;
      v_prestamo_cancelado NUMBER := 0;   -- Bug 24553 - MDS - 05/11/2011
      vicapital_yp   NUMBER;
      viinteres_yp   NUMBER;
      videmora_yp    NUMBER;
      vfpago_yp      DATE;
   BEGIN
      vpasexec := 1;
      vtobprestcua := t_iax_prestcuadro();
      v_cmonemp_t := pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP');
      vncuota := 0;

      SELECT finiprest
        INTO vfiniprest
        FROM prestamoseg
       WHERE ctapres = pctapres;

      vpasexec := 2;

      -- BUG 0019238 - 24/01/2012 - JMF: Añadir fefecto
      FOR cur IN (SELECT   pc.ctapres, pc.finicua, pc.ffincua, pc.fvencim, pc.icapital,
                           pc.iinteres, pc.icappend, pc.falta, pc.fpago, pc.fefecto,
                           pc.icapital_moncia, pc.iinteres_moncia, pc.icappend_moncia,
                           pc.fcambio, pc.norden
                      FROM prestcuadro pc
                     WHERE pc.ctapres = pctapres
                       AND pc.ffincua IS NULL
                  ----AND pc.finicua = (SELECT MAX(pc1.finicua)
                  ----                   FROM prestcuadro pc1
                  ----                   WHERE pc1.ctapres = pc.ctapres)
                  ORDER BY pc.fvencim) LOOP
         vpasexec := 21;
         -- Ini Bug 24553 - MDS - 05/11/2011, saber si el préstamo está cancelado a fecha de hoy
         v_prestamo_cancelado := pac_prestamos.f_prestamo_cancelado(cur.ctapres,
                                                                    TRUNC(cur.falta),
                                                                    TRUNC(f_sysdate));
         -- Fin Bug 24553 - MDS - 05/11/2011
         vncuota := vncuota + 1;
         vtobprestcua.EXTEND();
         vtobprestcua(vtobprestcua.LAST) := ob_iax_prestcuadro();
         vtobprestcua(vtobprestcua.LAST).finicua := cur.finicua;
         vtobprestcua(vtobprestcua.LAST).ffincua := cur.ffincua;
         vtobprestcua(vtobprestcua.LAST).fvencim := cur.fvencim;
         vtobprestcua(vtobprestcua.LAST).icapital := cur.icapital;
         vtobprestcua(vtobprestcua.LAST).icappend := cur.icappend;
         vtobprestcua(vtobprestcua.LAST).ncuota := vncuota;
         v_cmonprod_t := pac_monedas.f_cmoneda_n(pcmoneda);
         v_cmonemp_t := pac_parametros.f_parempresa_n(pcempres, 'MONEDAEMP');
         vnumerr := pac_prestamos.f_impcuota_yapagada(pctapres, cur.finicua, cur.icappend,
                                                      cur.norden, vicapital_yp, viinteres_yp,
                                                      videmora_yp, vfpago_yp);

         ---- pcuotadesc 0: No descontamos ningun valor pagado
         ---- pcuotadesc 1: Descontamos valor pagado de intereses correientes  y capitales.
         ---- pcutoadesc 1: Si ha pagado capital: Intereses de mora sobre el capital pendiente y no descontamos
         ----                si no ha pagado capital descontamos los intereses pagados.
         ---- pcutoadesc 2: No descontamos valor pagado de intereses correientes  y capitales.
         ---- pcutoadesc 2: Si ha pagado capital: Intereses de mora sobre el capital pendiente y no descontamos
         ----                si no ha pagado capital descontamos los intereses pagados.
         IF pcuotadesc = 1 THEN
            IF vicapital_yp > 0 THEN
               videmora_yp := 0;
            END IF;
         ELSIF pcuotadesc = 2 THEN
            viinteres_yp := 0;

            IF vicapital_yp > 0 THEN
               videmora_yp := 0;
            END IF;
         ELSIF pcuotadesc = 0 THEN
            viinteres_yp := 0;
            vicapital_yp := 0;
            videmora_yp := 0;
         END IF;

         IF pcuotadesc = 2 THEN
            vtobprestcua(vtobprestcua.LAST).icapital := cur.icapital;
         ELSE
            vtobprestcua(vtobprestcua.LAST).icapital := cur.icapital - vicapital_yp;
         END IF;

         vpasexec := 22;

         IF phastahoy = 0 THEN
            vtobprestcua(vtobprestcua.LAST).iinteres := cur.iinteres;
         ELSE
            IF cur.fvencim <= TRUNC(f_sysdate) THEN
               vtobprestcua(vtobprestcua.LAST).iinteres := cur.iinteres;
            ELSIF cur.fvencim > TRUNC(f_sysdate) THEN
               IF cur.fefecto >= TRUNC(f_sysdate) THEN
                  vtobprestcua(vtobprestcua.LAST).iinteres := 0;
               ELSE
                  vtobprestcua(vtobprestcua.LAST).iinteres :=
                     pac_prestamos.f_calc_interesco_cuota(pctapres, cur.falta, f_sysdate,
                                                          psseguro, cur.fefecto, cur.fvencim,
                                                          cur.iinteres);
               END IF;
            END IF;
         END IF;

         vtobprestcua(vtobprestcua.LAST).iinteres :=
                 f_round(vtobprestcua(vtobprestcua.LAST).iinteres - viinteres_yp, v_cmonprod_t);

         -- Bug 24553 - MDS - 05/11/2011, si lo está el interés es 0 sinó calculado
         IF v_prestamo_cancelado = 1 THEN
            vtobprestcua(vtobprestcua.LAST).idemora := 0;
         ELSE
            vnumerr := f_calc_demora_cuota_prorr(v_cmonprod_t, cur.icapital - vicapital_yp,
                                                 vfiniprest, cur.fvencim, psseguro, NULL,
                                                 TRUNC(f_sysdate),
                                                 vtobprestcua(vtobprestcua.LAST).idemora,
                                                 mensajes);
            vtobprestcua(vtobprestcua.LAST).idemora :=
                  f_round(vtobprestcua(vtobprestcua.LAST).idemora - videmora_yp, v_cmonprod_t);
         END IF;

         vpasexec := 23;
         -- ini BUG 0019238 - 24/01/2012 - JMF: Añadir fefecto
         --vtobprestcua(vtobprestcua.LAST).falta := cur.falta;
         vtobprestcua(vtobprestcua.LAST).falta := cur.fefecto;
         -- fin BUG 0019238 - 24/01/2012 - JMF: Añadir fefecto
         vtobprestcua(vtobprestcua.LAST).fpago := cur.fpago;
         --ini BUG 0019238 - 26/01/2012 - JMC se añaden los campos para moneda
         vtobprestcua(vtobprestcua.LAST).icapital_moncia := cur.icapital_moncia;
         -------vtobprestcua(vtobprestcua.LAST).iinteres_moncia := cur.iinteres_moncia;
         vtobprestcua(vtobprestcua.LAST).icappend_moncia := cur.icappend_moncia;
         vnumerr := pac_prestamos.f_impcuota_yapagada(pctapres, cur.finicua, cur.icappend,
                                                      cur.norden, vicapital_yp, viinteres_yp,
                                                      videmora_yp, vfpago_yp);

         ---- pcuotadesc 0: No descontamos ningun valor pagado
         ---- pcuotadesc 1: Descontamos valor pagado de intereses correientes  y capitales.
         ---- pcutoadesc 1: Si ha pagado capital: Intereses de mora sobre el capital pendiente y no descontamos
         ----                si no ha pagado capital descontamos los intereses pagados.
         ---- pcutoadesc 2: No descontamos valor pagado de intereses correientes  y capitales.
         ---- pcutoadesc 2: Si ha pagado capital: Intereses de mora sobre el capital pendiente y no descontamos
         ----                si no ha pagado capital descontamos los intereses pagados.
         IF pcuotadesc = 1 THEN
            IF vicapital_yp > 0 THEN
               videmora_yp := 0;
            END IF;
         ELSIF pcuotadesc = 2 THEN
            viinteres_yp := 0;

            IF vicapital_yp > 0 THEN
               videmora_yp := 0;
            END IF;
         ELSIF pcuotadesc = 0 THEN
            viinteres_yp := 0;
            vicapital_yp := 0;
            videmora_yp := 0;
         END IF;

         IF pcuotadesc = 2 THEN
            vtobprestcua(vtobprestcua.LAST).icapital_moncia := cur.icapital;
         ELSE
            vtobprestcua(vtobprestcua.LAST).icapital_moncia := cur.icapital - vicapital_yp;
         END IF;

         IF phastahoy = 0 THEN
            vtobprestcua(vtobprestcua.LAST).iinteres_moncia := cur.iinteres_moncia;
         ELSE
            IF cur.fvencim <= TRUNC(f_sysdate) THEN
               vtobprestcua(vtobprestcua.LAST).iinteres_moncia := cur.iinteres_moncia;
            ELSIF cur.fvencim > TRUNC(f_sysdate) THEN
               IF cur.fefecto >= TRUNC(f_sysdate) THEN
                  vtobprestcua(vtobprestcua.LAST).iinteres_moncia := 0;
               ELSE
                  vtobprestcua(vtobprestcua.LAST).iinteres_moncia :=
                     pac_prestamos.f_calc_interesco_cuota(pctapres, cur.falta, f_sysdate,
                                                          psseguro, cur.fefecto, cur.fvencim,
                                                          cur.iinteres_moncia);
               END IF;
            END IF;
         END IF;

         vpasexec := 24;
         vtobprestcua(vtobprestcua.LAST).iinteres_moncia :=
            f_round(vtobprestcua(vtobprestcua.LAST).iinteres_moncia - viinteres_yp,
                    v_cmonemp_t);

         -- Bug 24553 - MDS - 05/11/2011, si lo está el interés es 0 sinó calculado
         IF v_prestamo_cancelado = 1 THEN
            vtobprestcua(vtobprestcua.LAST).idemora_moncia := 0;
         ELSE
            vnumerr :=
               f_calc_demora_cuota_prorr(v_cmonemp_t, cur.icapital_moncia - vicapital_yp,
                                         vfiniprest, cur.fvencim, psseguro, NULL,
                                         TRUNC(f_sysdate),
                                         vtobprestcua(vtobprestcua.LAST).idemora_moncia,
                                         mensajes);
            vtobprestcua(vtobprestcua.LAST).idemora_moncia :=
               f_round(vtobprestcua(vtobprestcua.LAST).idemora_moncia - videmora_yp,
                       v_cmonemp_t);
         END IF;

         vtobprestcua(vtobprestcua.LAST).fcambio := cur.fcambio;
         vpasexec := 25;
      --fin BUG 0019238 - 26/01/2012 - JMC
      END LOOP;

      vpasexec := 3;
      RETURN vtobprestcua;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_prestcuadro;

   FUNCTION f_obtener_porcentaje(
      pfiniprest IN DATE,
      psproduc IN NUMBER,
      pinteres OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100)
         := 'pfiniprest=' || pfiniprest || ', psproduc=' || psproduc || ', pinteres='
            || pinteres;
      vobject        VARCHAR2(200) := 'PAC_MD_PRESTAMOS.f_obtener_porcentaje';
      vnumerr        NUMBER := 0;
   BEGIN
      vpasexec := 1;
      -- Llamada con el TIPO = 1 (Interes normal)
      vnumerr := pac_prestamos.f_obtener_porcentaje(pfiniprest, psproduc, 1, pinteres);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_obtener_porcentaje;

   FUNCTION f_insertar_prestamo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pctapres IN VARCHAR2,
      pfiniprest IN DATE,
      pffinprest IN DATE,
      pfalta IN DATE,
      picapital IN NUMBER,
      pcmoneda IN VARCHAR2,
      pporcen IN NUMBER,
      pctipo IN NUMBER,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR2,
      pf1cuota IN DATE,
      pffecpag IN DATE,
      pcforpag IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro=' || psseguro || ', pnriesgo=' || pnriesgo || ', pctapres=' || pctapres
            || ', pfiniprest=' || pfiniprest || ', pffinprest=' || pffinprest || ', pfecpag='
            || pffecpag || ', picapital=' || picapital || ', pcmoneda=' || pcmoneda
            || ', pporcen=' || pporcen || ', pctipo=' || pctipo || ', pctipban=' || pctipban;
      vobject        VARCHAR2(100) := 'PAC_MD_PRESTAMOS.f_insertar_prestamo';
      vnumerr        NUMBER := 0;
      --vcmoneda       prestamoseg.cmoneda%TYPE;
      vcmoneda       monedas.cmoneda%TYPE;
      vpinteres      NUMBER;
      -- BUG 0023253: LCOL_T001-qtracker 4813 - Primas pagades vs prestecs  HPM
      vvalidarecib   NUMBER;
   BEGIN
      -- BUG 0023253: LCOL_T001-qtracker 4813 - Primas pagades vs prestecs  HPM
      vvalidarecib := 0;
      vvalidarecib := pac_prestamos.f_verif_pago_recb(psseguro);

      IF (vvalidarecib <= 0) THEN
         vpasexec := 1;

         --SELECT pac_monedas.f_cmoneda_t(DECODE(cdivisa, 3, 1, cdivisa))
         SELECT DECODE(cdivisa, 3, 1, cdivisa)
           INTO vcmoneda
           FROM seguros s, productos p
          WHERE p.sproduc = s.sproduc
            AND s.sseguro = psseguro;

         vpasexec := 2;
         vnumerr := pac_prestamos.f_insertar_prestamo(psseguro, NVL(pnriesgo, 1), pnmovimi,
                                                      pctapres, pfiniprest, pffinprest, pfalta,
                                                      picapital, vcmoneda, pporcen, pctipo,
                                                      pctipban, pcbancar, pf1cuota, pffecpag,
                                                      pcforpag);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      ELSE
         vnumerr := vvalidarecib;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   --JRH
         RAISE e_salirerror;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_salirerror THEN
         -- BUG 0023253: LCOL_T001-qtracker 4813 - Primas pagades vs prestecs  HPM
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
         RETURN 1;
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_insertar_prestamo;

   FUNCTION f_anula_prestamo(pctapres IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'pctapres=' || pctapres;
      vobject        VARCHAR2(200) := 'PAC_MD_PRESTAMOS.f_anula_prestamo';
      vnumerr        NUMBER := 0;
   BEGIN
      vpasexec := 1;
      RETURN pac_prestamos.f_anulacion(pctapres);   -- bug 23749 - MDS - 19/09/2012
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_anula_prestamo;

-- Bug 19238/104039 - 18/01/2012 - AMC - Se añaden nuevos parametros a la función
   FUNCTION f_get_cuotas(
      pctapres IN VARCHAR2,
      pticapital OUT NUMBER,
      ptiinteres OUT NUMBER,
      ptidemora OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prestamocuotas IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pctapres=' || pctapres;
      vobject        VARCHAR2(200) := 'PAC_MD_PRESTAMOS.f_get_cuotas';
      vnumerr        NUMBER := 0;
      vtobprestcuo   t_iax_prestamocuotas;
      vticapital     NUMBER := 0;
      vtiinteres     NUMBER := 0;
      vtidemora      NUMBER := 0;
   BEGIN
      vpasexec := 1;
      vtobprestcuo := t_iax_prestamocuotas();

      FOR cur IN (SELECT pc.ctapres, pc.finicua, pc.icappend, pc.fvencim, pc.idpago,
                         pc.nlinea, pc.fpago, pc.icapital, pc.iinteres, pc.idemora,
                         pc.icapital_moncia, pc.iinteres_moncia, pc.icappend_moncia,
                         pc.fcambio
                    FROM prestamocuotas pc
                   WHERE pc.ctapres = pctapres) LOOP
---                     AND pc.finicua = (SELECT MAX(pc1.finicua)
---                                         FROM prestamocuotas pc1
---                                        WHERE pc1.ctapres = pc.ctapres)) LOOP
         vtobprestcuo.EXTEND();
         vtobprestcuo(vtobprestcuo.LAST) := ob_iax_prestamocuotas();
         vtobprestcuo(vtobprestcuo.LAST).fvencim := cur.fvencim;
         vtobprestcuo(vtobprestcuo.LAST).idpago := cur.idpago;
         vtobprestcuo(vtobprestcuo.LAST).nlinea := cur.nlinea;
         vtobprestcuo(vtobprestcuo.LAST).fpago := cur.fpago;
         vtobprestcuo(vtobprestcuo.LAST).icapital := cur.icapital;
         vtobprestcuo(vtobprestcuo.LAST).iinteres := cur.iinteres;
         vtobprestcuo(vtobprestcuo.LAST).idemora := cur.idemora;
         vtobprestcuo(vtobprestcuo.LAST).icappend := cur.icappend;
         vtobprestcuo(vtobprestcuo.LAST).icuota := cur.icapital + cur.iinteres + cur.idemora;
         vticapital := vticapital + cur.icapital;
         vtiinteres := vtiinteres + cur.iinteres;
         vtidemora := vtidemora + cur.idemora;
         --ini BUG 0019238 - 26/01/2012 - JMC se añaden los campos para moneda
         vtobprestcuo(vtobprestcuo.LAST).icapital_moncia := cur.icapital_moncia;
         vtobprestcuo(vtobprestcuo.LAST).iinteres_moncia := cur.iinteres_moncia;
         vtobprestcuo(vtobprestcuo.LAST).icappend_moncia := cur.icappend_moncia;
         vtobprestcuo(vtobprestcuo.LAST).fcambio := cur.fcambio;
      --fin BUG 0019238 - 26/01/2012 - JMC
      END LOOP;

      pticapital := vticapital;
      ptiinteres := vtiinteres;
      ptidemora := vtidemora;
      RETURN vtobprestcuo;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_cuotas;

   --ini BUG 0021731 - 23/04/2012 - JMC - Se añaden nuevas funciones
   FUNCTION f_calc_demora_cuota(
      pcmoneda IN NUMBER,
      picapital IN NUMBER,
      pfvencim IN DATE,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfecha IN DATE,
      pidemora OUT NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pforigen IN DATE)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmoneda=' || pcmoneda || ',picapital=' || picapital || ',pfvencim=' || pfvencim
            || ',psseguro=' || psseguro || ',psproduc=' || psproduc || ',pfecha=' || pfecha;
      vobject        VARCHAR2(200) := 'PAC_MD_PRESTAMOS.f_calc_demora_cuota';
      num_err        NUMBER;
   BEGIN
      IF pcmoneda IS NULL
         OR picapital IS NULL
         OR pfvencim IS NULL
         OR pfecha IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF psproduc IS NULL
         AND psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_prestamos.f_calc_demora_cuota(pcmoneda, picapital,
                                                   NVL(pforigen, pfvencim), pfvencim, psseguro,
                                                   psproduc, pfecha, pidemora);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_calc_demora_cuota;

   /*************************************************************************
       f_mov_prestamocuota
       Funcion para insertar movimiento en las cuotas del prestamo
       param in pctapres      : Identificador del préstamo
       param in pfinicua     : Versión del cuadro
       param in picappend    : capital pendiente
       param in pfvencim        : Fecha vencimiento de la cuota
       param in pidpago     : identificador del pago
       param in pnlinea      : identificador de la linea
       param out psmovcuo    : Secuencia movimiento cuota
       return              : 0 (todo Ok)
                             <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_mov_prestamocuota(
      pctapres IN VARCHAR2,
      pfinicua IN DATE,
      picappend IN NUMBER,
      pfvencim IN DATE,
      pidpago IN NUMBER,
      pnlinea IN NUMBER,
      pfmovini IN DATE,
      pcestcuo IN NUMBER,
      psmovcuo OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pctapres=' || pctapres || ',pfinicua=' || pfinicua || ',picappend=' || picappend
            || ',pfvencim=' || pfvencim || ',pidpago=' || pidpago || ',pnlinea=' || pnlinea
            || ',pfmovini=' || pfmovini || ',pcestcuo=' || pcestcuo;
      vobject        VARCHAR2(200) := 'PAC_MD_PRESTAMOS.f_mov_prestamocuota';
      num_err        NUMBER;
   BEGIN
      IF pctapres IS NULL
         OR pfinicua IS NULL
         OR picappend IS NULL
         OR pfvencim IS NULL
         OR pidpago IS NULL
         OR pnlinea IS NULL
         OR pfmovini IS NULL
         OR pcestcuo IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_prestamos.f_mov_prestamocuota(pctapres, pfinicua, picappend, pfvencim,
                                                   pidpago, pnlinea, pfmovini, pcestcuo,
                                                   psmovcuo);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_mov_prestamocuota;

   /*************************************************************************
       f_mov_prestamopago
       Funcion para insertar movimiento en el pago del prestamo
       param in pctapres      : Identificador del préstamo
       param in pnpago     : Versión del cuadro
       param in pcestpag    : capital pendiente
       param in pcsubpag        : Fecha vencimiento de la cuota
       param in pfefecto     : identificador del pago
       param out pnmovpag    : Número de movimiento del pago
       return              : 0 (todo Ok)
                             <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_mov_prestamopago(
      pctapres IN VARCHAR2,
      pnpago IN NUMBER,
      pcestpag IN NUMBER,
      pcsubpag IN NUMBER,
      pfefecto IN DATE,
      pnmovpag OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pctapres=' || pctapres || ',pnpago=' || pnpago || ',pcestpag=' || pcestpag
            || ',pcsubpag=' || pcsubpag || ',pfefecto=' || pfefecto;
      vobject        VARCHAR2(200) := 'PAC_MD_PRESTAMOS.f_mov_prestamopago';
      num_err        NUMBER;
   BEGIN
      IF pctapres IS NULL
         OR pnpago IS NULL
         OR pcestpag IS NULL
         OR pcsubpag IS NULL
         OR pfefecto IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_prestamos.f_mov_prestamopago(pctapres, pnpago, pcestpag, pcsubpag,
                                                  pfefecto, pnmovpag);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_mov_prestamopago;

--fin BUG 0021731 - 23/04/2012 - JMC - Se añaden nuevas funciones

   -- Ini Bug : 23749 - MDS - 19/09/2012
   /*************************************************************************
       f_mov_prestamos
       Función para insertar un movimiento de préstamos
       param in  pctapres  : Identificador del préstamo
       param in  pfalta    : Fecha de alta del préstamo
       param in  pcestado  : Nuevo estado actual del préstamo
       param in  pfmovini  : Fecha inicio de vigencia del nuevo estado
       param out psmovpres : Secuencia del nuevo movimiento
       return              : 0 (todo OK)
                             <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_mov_prestamos(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pcestado IN NUMBER,
      pfmovini IN DATE,
      psmovpres OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pctapres=' || pctapres || ',pfalta=' || pfalta || ',pcestado=' || pcestado
            || ',pfmovini=' || pfmovini;
      vobject        VARCHAR2(200) := 'PAC_MD_PRESTAMOS.f_mov_prestamos';
      num_err        NUMBER;
   BEGIN
      -- control de parámetros, todos son obligatorios
      IF pctapres IS NULL
         OR pfalta IS NULL
         OR pcestado IS NULL
         OR pfmovini IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_prestamos.f_mov_prestamos(pctapres, pfalta, pcestado, pfmovini, psmovpres);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_mov_prestamos;

   /*************************************************************************
       f_autorizar
       Función para autorizar un préstamo
       param in  pctapres    : Identificador del préstamo
       param in  pfalta      : Fecha de alta del préstamo
       param in  pfautoriza  : Fecha de autorización del préstamo
       param in  pnmovimi    : Número de movimiento
       param in  pffecpag    : Fecha de efecto del préstamo
       param in  picapital   : Capital del préstamo
       return                : 0 (todo OK)
                               <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_autorizar(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pfautoriza IN DATE,
      pnmovimi IN NUMBER,
      pffecpag IN DATE,
      picapital IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pctapres=' || pctapres || ',pfalta=' || pfalta || ',pfautoriza=' || pfautoriza
            || ',pnmovimi=' || pnmovimi || ',pffecpag=' || pffecpag || ',picapital='
            || picapital;
      vobject        VARCHAR2(200) := 'PAC_MD_PRESTAMOS.f_autorizar';
      num_err        NUMBER;
   BEGIN
      -- control de parámetros, todos son obligatorios excepto pnmovimi
      IF pctapres IS NULL
         OR pfalta IS NULL
         OR pfautoriza IS NULL
         OR pffecpag IS NULL
         OR picapital IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_prestamos.f_autorizar(pctapres, pfalta, pfautoriza, pnmovimi, pffecpag,
                                           picapital);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_autorizar;

-- Fin Bug : 23749 - MDS - 19/09/2012

   -- Ini Bug 23772 - MDS - 01/10/2012

   /*************************************************************************
       f_reversar_prestamo
       Función para reversar un préstamo
       param in  pctapres    : Identificador del préstamo
       param in  pfalta      : Fecha de alta del préstamo
       param in  pfrechaza   : Fecha de reversión del préstamo
       param in  pnmovimi    : Número de movimiento
       return                : 0 (todo OK)
                               <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_reversar_prestamo(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pfrechaza IN DATE,
      pnmovimi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pctapres=' || pctapres || ',pfalta=' || pfalta || ',pfrechaza=' || pfrechaza
            || ',pnmovimi=' || pnmovimi;
      vobject        VARCHAR2(200) := 'PAC_MD_PRESTAMOS.f_reversar_prestamo';
      num_err        NUMBER;
   BEGIN
      -- control de parámetros, todos son obligatorios excepto pnmovimi
      IF pctapres IS NULL
         OR pfalta IS NULL
         OR pfrechaza IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_prestamos.f_reversar_prestamo(pctapres, pfalta, pfrechaza, pnmovimi);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_reversar_prestamo;

-- Fin Bug 23772 - MDS - 01/10/2012
   FUNCTION f_permite_reversar(
      pctapres IN VARCHAR2,
      psepermite OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pctapres=' || pctapres;
      vobject        VARCHAR2(200) := 'PAC_MD_PRESTAMOS.f_permite_reversar';
      num_err        NUMBER;
   BEGIN
      /*
      IF pctapres IS NULL THEN
         RAISE e_param_error;
      END IF;
      */
      num_err := pac_prestamos.f_permite_reversar(pctapres, psepermite);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_permite_reversar;

   -- Ini Bug 24192 - MDS - 26/10/2012
   FUNCTION f_fecha_ult_prest(
      p_ctapres IN VARCHAR2,
      p_falta OUT DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'p_ctapres=' || p_ctapres;
      vobject        VARCHAR2(200) := 'PAC_MD_PRESTAMOS.f_fecha_ult_pres';
      num_err        NUMBER;
   BEGIN
      IF p_ctapres IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_prestamos.f_fecha_ult_prest(p_ctapres, p_falta);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_fecha_ult_prest;

-- Fin Bug 24192 - MDS - 26/10/2012
   FUNCTION f_calc_demora_cuota_prorr(
      pcmoneda IN NUMBER,
      picapital IN NUMBER,
      pforigen IN DATE,
      pfvencim IN DATE,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfecha IN DATE,
      pidemora OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmoneda=' || pcmoneda || ',picapital=' || picapital || ',pforigen=' || pforigen
            || ',pfvencim=' || pfvencim || ',psseguro=' || psseguro || ',psproduc='
            || psproduc || ',pfecha=' || pfecha;
      vobject        VARCHAR2(200) := 'PAC_MD_PRESTAMOS.f_calc_demora_cuota_prorr';
      num_err        NUMBER;
   BEGIN
      IF pcmoneda IS NULL
         OR picapital IS NULL
         OR pfvencim IS NULL
         OR pfecha IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_prestamos.f_calc_demora_cuota_prorr(pcmoneda, picapital,
                                                         NVL(pforigen, pfvencim), pfvencim,
                                                         psseguro, psproduc, pfecha, pidemora);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_calc_demora_cuota_prorr;
END pac_md_prestamos;
-- Fi Bug 19238/104039 - 18/01/2012 - AMC

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PRESTAMOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PRESTAMOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PRESTAMOS" TO "PROGRAMADORESCSI";
