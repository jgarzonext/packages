--------------------------------------------------------
--  DDL for Package Body PAC_MD_LISTADO_CARTERA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_LISTADO_CARTERA" IS
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /******************************************************************************
      NOMBRE:     PAC_MD_LISTADO_CARTERA
      PROPÓSITO:  Funciones para la obtención de listados de cartera
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        04/10/2010   SRA             1. Bug 0016137: Creación del package.
      2.0        30/12/2010   ICV             2. 0016137: CRT003 - Carga fichero cartera -> Listado cartera
      3.0        08/11/2011   APD             3. 0019316: CRT - Adaptar pantalla de comisiones
   ******************************************************************************/

   -- BUG 0016137 - 04/10/2010 - SRA
   /*************************************************************************
      f_listado_compara_carteras                     : Para una fecha de cartera dada, se obtiene un listado de recibos de nueva producción
                                                     : y renovación emitidos en dicha fecha y compara sus importes diversos con los de la cartera
                                                     : anterior. Es posible filtrar por empresa o producto.
      pccompani in companipro.ccompani%type          : identificador de la compañía que oferta el producto en AXIS
      psproduc in seguros.sproduc%TYPE               : identificador en AXIS del producto del cual se quiere obtener un listado
      pfechacartera in date                          : fecha de cartera del listado que se quiere generar
      plistadocarteras out t_iax_comparacarteras:    : objeto que alberga el resultado del listado
      return number                                  : control de errores
   **************************************************************************/
   --bug 16137 - 08/06/2011 -AMC
   FUNCTION f_listado_compara_carteras(
      pccompani IN companipro.ccompani%TYPE,
      psproduc IN seguros.sproduc%TYPE,
      pfdesde IN DATE,
      pfhasta IN DATE,
      plistadocarteras OUT t_iax_comparacarteras,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_LISTADO_CARTERA.F_LISTADO_COMPARA_CARTERAS';
      vparam         VARCHAR2(500)
         := 'parámetros - pccompani: ' || pccompani || ' - psproduc: ' || psproduc
            || ' - pfdesde : ' || pfdesde || ' pfhasta : ' || pfhasta;
      vpasexec       NUMBER(5) := 0;
      vnresult       NUMBER(8) := 0;
      vcempres       NUMBER(8);
      vsquery        VARCHAR2(5000);
      i              NUMBER := 0;
      vcursor        sys_refcursor;
      num_err        NUMBER;
   BEGIN
      vpasexec := 1;

      IF pfdesde IS NULL
         OR pfhasta IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vcempres := pac_md_common.f_get_cxtempresa;

      IF vcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vnresult := pac_listado_cartera.f_listado_carteras(vcempres, pccompani, psproduc,
                                                         pfdesde, pfhasta, vsquery);

      IF vnresult <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, vnresult, vpasexec, vparam);
         RAISE e_object_error;
      END IF;

      vpasexec := 4;

      IF pac_md_log.f_log_consultas(vsquery,
                                    'PAC_MD_LISTADO_CARTERA.F_LISTADO_COMPARA_CARTERAS', 1, 4,
                                    mensajes) <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      vcursor := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 6;
      plistadocarteras := t_iax_comparacarteras();

      LOOP
         DECLARE
            vsseguro       seguros.sseguro%TYPE;
            vnpoliza       seguros.npoliza%TYPE;
            vcpolcia       seguros.cpolcia%TYPE;
            vccompani      seguros.ccompani%TYPE;
            vtcompani      companias.tcompani%TYPE;
            vcforpag       seguros.cforpag%TYPE;
            vcagente       seguros.cagente%TYPE;
            --Recibos
            vcreccia       recibos.creccia%TYPE;
            vnrecibo       recibos.nrecibo%TYPE;
            viprinet       vdetrecibos.iprinet%TYPE;
            vicombru       vdetrecibos.icombru%TYPE;
            vfefecto_rec   recibos.fefecto%TYPE;
            vfvencim_rec   recibos.fvencim%TYPE;
            vnmovimi       recibos.nmovimi%TYPE;
            vfemisio_rec   recibos.femisio%TYPE;
            vfcarpro       VARCHAR2(10);
            vfcarant       VARCHAR2(10);
            vcsituac       NUMBER;
            vnresult2      NUMBER := 0;
            vpcomisi       NUMBER;
            vpretenc       NUMBER;
         BEGIN
            vpasexec := 7;

            FETCH vcursor
             INTO vsseguro, vnpoliza, vcpolcia, vccompani, vcagente, vfcarpro, vfcarant,
                  vcsituac, vcreccia, vnrecibo, viprinet, vicombru, vfefecto_rec,
                  vfvencim_rec, vnmovimi, vfemisio_rec;

            EXIT WHEN vcursor%NOTFOUND;

            IF vccompani IS NOT NULL THEN
               BEGIN
                  SELECT tcompani
                    INTO vtcompani
                    FROM companias c
                   WHERE c.ccompani = vccompani;
               EXCEPTION
                  WHEN OTHERS THEN
                     vtcompani := NULL;
               END;
            END IF;

            plistadocarteras.EXTEND;
            i := i + 1;
            plistadocarteras(i) := ob_iax_comparacarteras();
            plistadocarteras(i).npoliza := vnpoliza;
            plistadocarteras(i).fcarpro := vfcarpro;
            plistadocarteras(i).fcarant := vfcarant;
            plistadocarteras(i).tsituac := ff_desvalorfijo(61, pac_md_common.f_get_cxtidioma(),
                                                           vcsituac);
            plistadocarteras(i).tcompani := vtcompani;
            plistadocarteras(i).cpolcia := vcpolcia;
            plistadocarteras(i).cagente := vcagente;
            plistadocarteras(i).creccia_ultimo := vcreccia;
            plistadocarteras(i).nrecibo_ultimo := vnrecibo;
            plistadocarteras(i).fefector_ultimo := vfefecto_rec;
            plistadocarteras(i).fvencimr_ultimo := vfvencim_rec;
            plistadocarteras(i).femisior_ultimo := vfemisio_rec;   --bug 16137 - 08/06/2011 -AMC
            plistadocarteras(i).iprinet_ultimo := viprinet;
            plistadocarteras(i).icombru_ultimo := vicombru;

            --bug 16137 - 08/06/2011 -AMC
            -- Buscamos datos del tomador
            DECLARE
               vnorden        asegurados.norden%TYPE;
               vcidioma       seguros.cidioma%TYPE;
            BEGIN
               SELECT MIN(nordtom)
                 INTO vnorden
                 FROM tomadores t
                WHERE t.sseguro = vsseguro;

               SELECT nnumide
                 INTO plistadocarteras(i).nnumidetom
                 FROM tomadores t, per_personas p
                WHERE t.sseguro = vsseguro
                  AND t.nordtom = vnorden
                  AND t.sperson = p.sperson;

               num_err := f_tomador(vsseguro, vnorden, plistadocarteras(i).tnombretom,
                                    vcidioma);
            EXCEPTION
               WHEN OTHERS THEN
                  plistadocarteras(i).tnombretom := '**';
            END;

            --Fi bug 16137 - 08/06/2011 -AMC

            --Buscamos las comisión
            DECLARE
               vcramo         seguros.cramo%TYPE;
               vcmodali       seguros.cmodali%TYPE;
               vctipseg       seguros.ctipseg%TYPE;
               vccolect       seguros.ccolect%TYPE;
               vcactivi       seguros.cactivi%TYPE;
            BEGIN
               /*    SELECT pcomisi
                     INTO vpcomisi
                     FROM comisionsegu
                    WHERE sseguro = vsseguro;
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN*/
               SELECT cramo, cmodali, ctipseg, ccolect, cactivi,
                      fefecto
                 INTO vcramo, vcmodali, vctipseg, vccolect, vcactivi,
                      plistadocarteras(i).fefectopol
                 FROM seguros
                WHERE sseguro = vsseguro;

               num_err := f_desproducto(vcramo, vcmodali, 1, pac_md_common.f_get_cxtidioma(),
                                        plistadocarteras(i).titulopro, vctipseg, vccolect);
               num_err := f_desactivi(vcactivi, vcramo, pac_md_common.f_get_cxtidioma(),
                                      plistadocarteras(i).tactivi);
               --num_err := f_pcomisi_cia(vcramo, vcmodali, vctipseg, vccolect, vcactivi, 1,
                 --                       vpcomisi);
               -- Bug 19316 - APD - 08/11/2011 - en vez de llamar a la funcion f_pcomisi
               -- se llamara a la función pac_listado_cartera.f_pcomisi_correduria
               --num_err := f_pcomisi(vsseguro, 1, f_sysdate, vpcomisi, vpretenc);
               num_err := pac_listado_cartera.f_pcomisi_correduria(vsseguro, 1, f_sysdate,
                                                                   vpcomisi, vpretenc);
               -- Fin Bug 19316 - APD - 08/11/2011
               /*   WHEN OTHERS THEN
                     vpcomisi := NULL;*/
               vpcomisi := NVL(vpcomisi, 0);
            END;

            plistadocarteras(i).pcomisi := vpcomisi;

            IF vpcomisi IS NOT NULL THEN
               plistadocarteras(i).icomisi := ROUND((viprinet * vpcomisi) / 100, 2);

               BEGIN
                  SELECT   s.cforpag, SUM(g.iprianu)
                      INTO vcforpag, plistadocarteras(i).ipriforpag
                      FROM seguros s, garanseg g
                     WHERE s.sseguro = g.sseguro
                       AND s.sseguro = vsseguro
                       --AND g.nmovimi = vnmovimi
                       AND g.ffinefe IS NULL
                  GROUP BY s.cforpag;

                  IF NVL(vcforpag, -1) = -1 THEN
                     RAISE NO_DATA_FOUND;
                  END IF;

                  plistadocarteras(i).tforpag :=
                                 ff_desvalorfijo(17, pac_md_common.f_get_cxtidioma(), vcforpag);

                  IF vcforpag = 0 THEN
                     vcforpag := 1;
                  END IF;

                  plistadocarteras(i).ipriforpag := plistadocarteras(i).ipriforpag / vcforpag;
                  plistadocarteras(i).icomisiforpag :=
                                      ROUND(plistadocarteras(i).ipriforpag * vpcomisi / 100, 2);
                  plistadocarteras(i).ipriforpag := ROUND(plistadocarteras(i).ipriforpag, 2);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     plistadocarteras(i).ipriforpag := NULL;
                     plistadocarteras(i).icomisiforpag := NULL;
                     plistadocarteras(i).tforpag := NULL;
               END;
            ELSE
               plistadocarteras(i).icomisi := NULL;
               plistadocarteras(i).ipriforpag := NULL;
               plistadocarteras(i).icomisiforpag := NULL;
               plistadocarteras(i).tforpag := NULL;
            END IF;

            vpasexec := 8;
            vnresult2 :=
               pac_listado_cartera.f_compara_recibos_poliza
                                                         (vsseguro, vnrecibo, vfefecto_rec,
                                                          viprinet, vicombru,
                                                          plistadocarteras(i).nrecibo_anterior,
                                                          plistadocarteras(i).fefector_anterior,
                                                          plistadocarteras(i).fvencimr_anterior,
                                                          plistadocarteras(i).iprinet_anterior,
                                                          plistadocarteras(i).iprinet_variacion,
                                                          plistadocarteras(i).icombru_anterior,
                                                          plistadocarteras(i).icombru_variacion,
                                                          plistadocarteras(i).creccia_anterior);

            IF vnresult2 != 0 THEN
               vparam := vparam || ' - vsseguro: ' || vsseguro;
               RAISE e_object_error;
            END IF;

            --bug 16137 - 08/06/2011 -AMC
            plistadocarteras(i).icombru_variacion :=
                NVL(plistadocarteras(i).icombru_ultimo, 0)
                - NVL(plistadocarteras(i).icomisi, 0);
            --Fi bug 16137 - 08/06/2011 -AMC
            plistadocarteras(i).ccompani := pccompani;
         EXCEPTION
            WHEN OTHERS THEN
               vparam := vparam || ' - vnpoliza: ' || vnpoliza;
               RAISE;
         END;
      END LOOP;

      vpasexec := 9;
      RETURN vnresult;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1000005;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1000006;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1000001;
   END f_listado_compara_carteras;

   -- BUG 0016137 - 04/10/2010 - SRA
   /*************************************************************************
      f_listado_compara_carteras                     : Para una fecha de cartera dada, se obtiene un listado de recibos de nueva producción
                                                     : y renovación emitidos en dicha fecha y compara sus importes diversos con los de la cartera
                                                     : anterior. Es posible filtrar por empresa o producto.
      pccompani in companipro.ccompani%type          : identificador de la compañía que oferta el producto en AXIS
      psproduc in seguros.sproduc%TYPE               : identificador en AXIS del producto del cual se quiere obtener un listado
      pfechacartera in date                          : fecha de cartera del listado que se quiere generar
      plistadocarteras out t_iax_comparacarteras:    : objeto que alberga el resultado del listado
      return number                                  : control de errores
   **************************************************************************/
   FUNCTION f_listado_polizas_sincartera(
      pccompani IN companipro.ccompani%TYPE,
      psproduc IN seguros.sproduc%TYPE,
      pfdesde IN DATE,
      pfhasta IN DATE,
      plistadocarteras OUT t_iax_comparacarteras,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_LISTADO_CARTERA.F_LISTADO_POLIZAS_SINCARTERA';
      vparam         VARCHAR2(500)
         := 'parámetros - pccompani: ' || pccompani || ' - psproduc: ' || psproduc
            || ' - pfdesde : ' || pfdesde || ' - pfhasta : ' || pfhasta;
      vpasexec       NUMBER(5) := 0;
      vnresult       NUMBER(8) := 0;
      vcempres       seguros.cempres%TYPE;
      vsquery        VARCHAR2(5000);
      i              NUMBER := 0;
      vcursor        sys_refcursor;
      num_err        NUMBER := 0;
   BEGIN
      vpasexec := 1;

      IF pfdesde IS NULL
         OR pfhasta IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vcempres := pac_md_common.f_get_cxtempresa;

      IF vcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vnresult := pac_listado_cartera.f_listado_polizas_sincartera(vcempres, pccompani,
                                                                   psproduc, pfdesde, pfhasta,
                                                                   vsquery);

      IF vnresult <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, vnresult, vpasexec, vparam);
         RAISE e_object_error;
      END IF;

      vpasexec := 4;

      IF pac_md_log.f_log_consultas(vsquery,
                                    'PAC_MD_LISTADO_CARTERA.F_LISTADO_POLIZAS_SINCARTERA', 1,
                                    4, mensajes) <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      vcursor := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 6;
      plistadocarteras := t_iax_comparacarteras();

      LOOP
         DECLARE
            vsseguro       seguros.sseguro%TYPE;
            vnpoliza       seguros.npoliza%TYPE;
            vcpolcia       seguros.cpolcia%TYPE;
            vccompani      seguros.ccompani%TYPE;
            vtcompani      companias.tcompani%TYPE;
            vnresult2      NUMBER := 0;
            vfcarpro       VARCHAR2(10);
            vfcarant       VARCHAR2(10);
            vcsituac       NUMBER;
            vcforpag       seguros.cforpag%TYPE;
            vcagente       seguros.cagente%TYPE;
            --Recibos
            vcreccia       recibos.creccia%TYPE;
            vnrecibo       recibos.nrecibo%TYPE;
            viprinet       vdetrecibos.iprinet%TYPE;
            vicombru       vdetrecibos.icombru%TYPE;
            vfefecto_rec   recibos.fefecto%TYPE;
            vfvencim_rec   recibos.fvencim%TYPE;
            vfemisio_rec   recibos.femisio%TYPE;
            vnmovimi       recibos.nmovimi%TYPE;
            vpcomisi       NUMBER;
            vpretenc       NUMBER;
         BEGIN
            vpasexec := 7;

            FETCH vcursor
             INTO vsseguro, vnpoliza, vcpolcia, vccompani, vcagente, vfcarpro, vfcarant,
                  vcsituac, vcreccia, vnrecibo, viprinet, vicombru, vfefecto_rec,
                  vfvencim_rec, vnmovimi, vfemisio_rec;

            EXIT WHEN vcursor%NOTFOUND;

            IF vccompani IS NOT NULL THEN
               BEGIN
                  SELECT tcompani
                    INTO vtcompani
                    FROM companias c
                   WHERE c.ccompani = vccompani;
               EXCEPTION
                  WHEN OTHERS THEN
                     vtcompani := NULL;
               END;
            END IF;

            plistadocarteras.EXTEND;
            i := i + 1;
            plistadocarteras(i) := ob_iax_comparacarteras();
            plistadocarteras(i).npoliza := vnpoliza;
            plistadocarteras(i).fcarpro := vfcarpro;
            plistadocarteras(i).fcarant := vfcarant;
            plistadocarteras(i).tsituac := ff_desvalorfijo(61, pac_md_common.f_get_cxtidioma(),
                                                           vcsituac);
            --plistadocarteras(i).ccompani := vccompani;
            plistadocarteras(i).tcompani := vtcompani;
            plistadocarteras(i).cpolcia := vcpolcia;
            plistadocarteras(i).cagente := vcagente;
            plistadocarteras(i).creccia_ultimo := vcreccia;
            plistadocarteras(i).fefector_ultimo := vfefecto_rec;
            plistadocarteras(i).fvencimr_ultimo := vfvencim_rec;
            plistadocarteras(i).femisior_ultimo := vfemisio_rec;   --bug 16137 - 08/06/2011 -AMC
            plistadocarteras(i).nrecibo_ultimo := vnrecibo;
            plistadocarteras(i).iprinet_ultimo := viprinet;
            plistadocarteras(i).icombru_ultimo := vicombru;

            --bug 16137 - 08/06/2011 -AMC
            -- Buscamos datos del tomador
            DECLARE
               vnorden        asegurados.norden%TYPE;
               vcidioma       seguros.cidioma%TYPE;
            BEGIN
               SELECT MIN(nordtom)
                 INTO vnorden
                 FROM tomadores t
                WHERE t.sseguro = vsseguro;

               SELECT nnumide
                 INTO plistadocarteras(i).nnumidetom
                 FROM tomadores t, per_personas p
                WHERE t.sseguro = vsseguro
                  AND t.nordtom = vnorden
                  AND t.sperson = p.sperson;

               num_err := f_tomador(vsseguro, vnorden, plistadocarteras(i).tnombretom,
                                    vcidioma);
            EXCEPTION
               WHEN OTHERS THEN
                  plistadocarteras(i).tnombretom := '**';
            END;

            --Fi bug 16137 - 08/06/2011 -AMC

            --Buscamos las comisión
            DECLARE
               vcramo         seguros.cramo%TYPE;
               vcmodali       seguros.cmodali%TYPE;
               vctipseg       seguros.ctipseg%TYPE;
               vccolect       seguros.ccolect%TYPE;
               vcactivi       seguros.cactivi%TYPE;
            BEGIN
                /*  SELECT pcomisi
                    INTO vpcomisi
                    FROM comisionsegu
                   WHERE sseguro = vsseguro;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN*/
               SELECT cramo, cmodali, ctipseg, ccolect, cactivi,
                      fefecto
                 INTO vcramo, vcmodali, vctipseg, vccolect, vcactivi,
                      plistadocarteras(i).fefectopol
                 FROM seguros
                WHERE sseguro = vsseguro;

               num_err := f_desproducto(vcramo, vcmodali, 1, pac_md_common.f_get_cxtidioma(),
                                        plistadocarteras(i).titulopro, vctipseg, vccolect);
               num_err := f_desactivi(vcactivi, vcramo, pac_md_common.f_get_cxtidioma(),
                                      plistadocarteras(i).tactivi);
               -- num_err := f_pcomisi_cia(vcramo, vcmodali, vctipseg, vccolect, vcactivi, 1,
                 --                        vpcomisi);
               -- Bug 19316 - APD - 08/11/2011 - en vez de llamar a la funcion f_pcomisi
               -- se llamara a la función pac_listado_cartera.f_pcomisi_correduria
               --num_err := f_pcomisi(vsseguro, 1, f_sysdate, vpcomisi, vpretenc);
               num_err := pac_listado_cartera.f_pcomisi_correduria(vsseguro, 1, f_sysdate,
                                                                   vpcomisi, vpretenc);
               -- Fin Bug 19316 - APD - 08/11/2011
               /*  WHEN OTHERS THEN
                    vpcomisi := NULL;*/
               vpcomisi := NVL(vpcomisi, 0);
            END;

            plistadocarteras(i).pcomisi := vpcomisi;
            vpasexec := 8;
            vnresult2 :=
               pac_listado_cartera.f_compara_recibos_poliza
                           (vsseguro, vnrecibo,
                            --pfdesde,
                            pfhasta,   --  que coja el último recibo realemente dentro del periodo
                            viprinet, vicombru, plistadocarteras(i).nrecibo_anterior,
                            plistadocarteras(i).fefector_anterior,
                            plistadocarteras(i).fvencimr_anterior,
                            plistadocarteras(i).iprinet_anterior,
                            plistadocarteras(i).iprinet_variacion,
                            plistadocarteras(i).icombru_anterior,
                            plistadocarteras(i).icombru_variacion,
                            plistadocarteras(i).creccia_anterior);

            IF vpcomisi IS NOT NULL THEN
               plistadocarteras(i).icomisi := ROUND((plistadocarteras(i).iprinet_anterior
                                                     * vpcomisi)
                                                    / 100,
                                                    2);

               BEGIN
                  /*  SELECT nmovimi
                      INTO vnmovimi
                      FROM recibos
                     WHERE nrecibo = plistadocarteras(i).nrecibo_anterior;*/
                  SELECT   s.cforpag, SUM(g.iprianu)
                      INTO vcforpag, plistadocarteras(i).ipriforpag
                      FROM seguros s, garanseg g
                     WHERE s.sseguro = g.sseguro
                       AND s.sseguro = vsseguro
                       --AND g.nmovimi = vnmovimi
                       AND g.ffinefe IS NULL
                  GROUP BY s.cforpag;

                  IF NVL(vcforpag, -1) = -1 THEN
                     RAISE NO_DATA_FOUND;
                  END IF;

                  plistadocarteras(i).tforpag :=
                                 ff_desvalorfijo(17, pac_md_common.f_get_cxtidioma(), vcforpag);

                  IF vcforpag = 0 THEN
                     vcforpag := 1;
                  END IF;

                  plistadocarteras(i).ipriforpag := plistadocarteras(i).ipriforpag / vcforpag;
                  plistadocarteras(i).icomisiforpag :=
                                      ROUND(plistadocarteras(i).ipriforpag * vpcomisi / 100, 2);
                  plistadocarteras(i).ipriforpag := ROUND(plistadocarteras(i).ipriforpag, 2);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     plistadocarteras(i).ipriforpag := NULL;
                     plistadocarteras(i).icomisiforpag := NULL;
                     plistadocarteras(i).tforpag := NULL;
               END;
            ELSE
               plistadocarteras(i).icomisi := NULL;
               plistadocarteras(i).ipriforpag := NULL;
               plistadocarteras(i).icomisiforpag := NULL;
               plistadocarteras(i).tforpag := NULL;
            END IF;

            IF vnresult2 != 0 THEN
               vparam := vparam || ' - vsseguro: ' || vsseguro;
               RAISE e_object_error;
            END IF;

            plistadocarteras(i).ccompani := pccompani;
         EXCEPTION
            WHEN OTHERS THEN
               vparam := vparam || ' - vnpoliza: ' || vnpoliza;
               RAISE;
         END;
      END LOOP;

      vpasexec := 9;
      RETURN vnresult;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1000005;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1000006;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1000001;
   END f_listado_polizas_sincartera;
END pac_md_listado_cartera;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTADO_CARTERA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTADO_CARTERA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTADO_CARTERA" TO "PROGRAMADORESCSI";
