--------------------------------------------------------
--  DDL for Function F_CUMULO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CUMULO" (
   pproces IN NUMBER,
   pscumulo IN NUMBER,
   pfecini IN DATE,
   porigen IN NUMBER,
   pmoneda IN NUMBER,
   pssegurono IN NUMBER DEFAULT NULL)
   RETURN NUMBER IS
/************************************************************************
      f_cumulo        : Funci¿ per reajustar les cessions despr¿s d'una
                        modificaci¿ de la composici¿ d'un c¿mul...
                        Com un c¿mul afecta ¿nicament a uns quants riscos,
                        no cal llen¿ar un proc¿s diferit com en el cas de
                        modificacions de contractes...
      Par¿metres d'entrada a la funci¿:
        - N¿ de proc¿s.
        - N¿ de c¿mul modificat.
        - Data del canvi.
        - Origen del canvi: 1 - cridat per programa d'anul.laci¿ de p¿lisses.
                            2 - cridat per programa de modificaci¿ de c¿mul.
        - Codi moneda.
      ALLIBREA
pssegurono -- No es recalcula aquest sseguro
***********************************************************************************************/

   -- ini Bug 0021242 - 15/02/2012 - JMF
   vpas           NUMBER := 0;
   vobj           VARCHAR2(200) := 'f_cumulo';
   vpar           VARCHAR2(500)
      := 'p=' || pproces || ' c=' || pscumulo || ' i=' || pfecini || ' o=' || porigen || ' m='
         || pmoneda || ' o=' || pssegurono;
   -- fin Bug 0021242 - 15/02/2012 - JMF
   codi_error     NUMBER := 0;
   err            NUMBER := 0;
   ttexto         VARCHAR2(100);
   numlin         cesionesaux.nnumlin%TYPE := 0;
   w_fconini      cesionesaux.fconini%TYPE;
   w_fconfin      cesionesaux.fconfin%TYPE;
   w_icapital     NUMBER;   --25803
   w_iprirea      NUMBER;   --25803
   w_cobjase      seguros.cobjase%TYPE;   --25803 NUMBER(2);
   w_nasegur      riesgos.nasegur%TYPE;   --25803 NUMBER(6);
   w_prima        garanseg.iprianu%TYPE;   --25803
   w_sseguro      seguros.sseguro%TYPE;
   w_nmovimi      garanseg.nmovimi%TYPE;
   w_nriesgo      cesionesrea.nriesgo%TYPE;
   w_cgarant      cesionesrea.cgarant%TYPE;
   w_cfacult      cesionesaux.cfacult%TYPE;
   w_numlin       cesionesaux.nnumlin%TYPE := 1;

   CURSOR cur_reariesb IS
      SELECT   *
          FROM reariesgos
         WHERE scumulo = pscumulo
           AND freafin = pfecini
           AND(sseguro <> pssegurono
               OR pssegurono IS NULL)
      ORDER BY sseguro, nriesgo, cgarant;   -- 15007 AVT 01-07-2010

   CURSOR cur_reariesa IS
      SELECT   *
          FROM reariesgos
         WHERE scumulo = pscumulo
           AND freaini = pfecini
           AND(sseguro <> pssegurono
               OR pssegurono IS NULL)
      ORDER BY sseguro, nriesgo, cgarant;   -- 15007 AVT 01-07-2010

-- ************************************************************************
-- ************************************************************************
-- ************************************************************************
   FUNCTION f_endavant(
      psproces NUMBER,
      pscumulo IN NUMBER,
      pfecini IN DATE,
      pmoneda IN NUMBER,
      pssegurono IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
/**************************************************************************
    F_ENDAVANT   : Funci¿ per crear cessions prorratejades per nou c¿mul...
**************************************************************************/
      codi_error     NUMBER := 0;
      err            NUMBER := 0;
      w_nriesgo      cesionesrea.nriesgo%TYPE;
      w_cgarant      cesionesrea.cgarant%TYPE;
      w_dias         NUMBER;
      w_dias_origen  NUMBER;
      w_scesrea      cesionesrea.scesrea%TYPE;
      w_cobjase      seguros.cobjase%TYPE;
      w_nasegur      riesgos.nasegur%TYPE;
      w_prima        garanseg.iprianu%TYPE;   --25803
      w_numlin       cesionesaux.nnumlin%TYPE := 1;
      w_cfacult      cesionesaux.cfacult%TYPE;
      w_ctiprea      codicontratos.ctiprea%TYPE;
      w_cramo        seguros.cramo%TYPE;
      w_cmodali      seguros.cmodali%TYPE;
      w_ctipseg      seguros.ctipseg%TYPE;
      w_ccolect      garanpro.ccolect%TYPE;
      w_cactivi      garanpro.cactivi%TYPE;
      w_creaseg      garanpro.creaseg%TYPE;
      w_icesion      cesionesrea.icesion%TYPE;
      w_sproduc      seguros.sproduc%TYPE;
      w_ctarman      seguros.ctarman%TYPE;
      w_capital      cesionesaux.icapital%TYPE;
      w_sgt          NUMBER;
      w_cforpag      seguros.cforpag%TYPE;
      w_cidioma      seguros.cidioma%TYPE;
      w_fefecto      seguros.fefecto%TYPE;
      lipleno        contratos.iretenc%TYPE;
      licapaci       contratos.icapaci%TYPE;
      ldetces        cesionesrea.cdetces%TYPE;
      lsseg_ant      seguros.sseguro%TYPE;
      lfefecto_ini   DATE;
      lcforamor      seguros.cforpag%TYPE;
      amortit        pk_cuadro_amortizacion.t_amortizacion;
      lfecha         DATE;
      lcapital       NUMBER;
      w_cempres      seguros.cempres%TYPE;
      v_ctiprea      codicontratos.ctiprea%TYPE;--BUG CONF-294  Fecha (09/11/2016) - HRE
      CURSOR cur_reariesgo(wscumulo NUMBER, wdata DATE, wsproces NUMBER, wssegurono NUMBER) IS
         SELECT DISTINCT sseguro, nriesgo, nmovimi, fefecto,
                         cdetces, scontra -- BUG: 17672 JGR 23/02/2011 - BUG CONF-294  Fecha (09/11/2016) - HRE
                    FROM cesionesrea
                   WHERE scumulo = wscumulo
                     AND cgenera = 8
                     AND sproces = wsproces
                     AND(sseguro <> wssegurono
                         OR wssegurono IS NULL)
                ORDER BY sseguro;   --bug: 21186  ETM 01/02/2012;

      -- nom¿s una vegada per garantia risc,p¿lissa i data (no tots els trams)
      CURSOR cur_cesiones(wsseguro NUMBER, wnriesgo NUMBER, wfefecto DATE, wsproces NUMBER) IS
         SELECT DISTINCT sseguro, nriesgo, cgarant, nmovimi, scontra, nversio,   --sfacult, !!!!!!!!!!!!!!!!!! 13/09/2013 AVT
                                                                              fefecto, fvencim,
                         cdetces, psobreprima, fanulac, fregula
                    FROM cesionesrea
                   WHERE sseguro = wsseguro
                     AND nriesgo = wnriesgo
                     AND fefecto = wfefecto
                     AND cgenera = 8
                     AND sproces = wsproces
                ORDER BY sseguro;

      CURSOR cgar(
         wsseguro IN NUMBER,
         wnriesgo IN NUMBER,
         wcgarant IN NUMBER,
         wnmovimi IN NUMBER) IS
         SELECT   *
             FROM garanseg
            WHERE sseguro = wsseguro
              AND nriesgo = wnriesgo
              AND(cgarant = wcgarant
                  OR wcgarant IS NULL)
              AND nmovimi = wnmovimi
         ORDER BY sseguro, nriesgo, nmovimi, cgarant;
   BEGIN
      vpas := 1000;
      -- Per cada pol del c¿mul i moviment
      lsseg_ant := -1;
      vpas := 1010;

      FOR regriesgo IN cur_reariesgo(pscumulo, pfecini, psproces, pssegurono) LOOP
--DBMS_OUTPUT.put_line('sseguro '||regriesgo.sseguro);
         BEGIN
            vpas := 1020;

            SELECT creafac, cramo, cmodali, ctipseg, ccolect, sproduc,
                   pac_seguros.ff_get_actividad(sseguro, regriesgo.nriesgo), ctarman,
                   cobjase, cforpag, DECODE(cidioma, 0, 1, cidioma), fefecto, cempres
              INTO w_cfacult, w_cramo, w_cmodali, w_ctipseg, w_ccolect, w_sproduc,
                   w_cactivi, w_ctarman,
                   w_cobjase, w_cforpag, w_cidioma, w_fefecto, w_cempres
              FROM seguros
             WHERE sseguro = regriesgo.sseguro;
         EXCEPTION
            WHEN OTHERS THEN
               -- Bug 0021242 - 15/02/2012 - JMF
               p_tab_error(f_sysdate, f_user, vobj, vpas,
                           vpar || ' seg=' || regriesgo.sseguro, SQLCODE || ' ' || SQLERRM);
               RETURN 101919;
         END;

         vpas := 1030;
         -- FAL 01/2009. Bug 8528. Se sustituye par¿metro de instalaci¿n por par¿metro de empresa
         w_sgt := NVL(pac_parametros.f_parempresa_n(w_cempres, 'REAS_SGT'), 0);
         lcforamor := w_cforpag;
         --DBMS_OUTPUT.put_line('bucle de cessions '||pfecini);
         --DBMS_OUTPUT.put_line('sseguro = '||regriesgo.sseguro);
         ldetces := NULL;
         ldetces := regriesgo.cdetces;   -- BUG: 17672 JGR 23/02/2011
         vpas := 1040;

         --INI BUG CONF-294  Fecha (09/11/2016) - HRE - Cumulos
         SELECT ctiprea
           INTO v_ctiprea
         FROM codicontratos
          WHERE scontra = regriesgo.scontra;
         --
         IF (v_ctiprea = 5) THEN
           FOR rg_cesiones in (SELECT ce.* FROM cesionesrea ce, seguros se
                                WHERE ce.sseguro = se.sseguro
                                  AND ce.sseguro = regriesgo.sseguro
                                  AND ce.cgenera != 8
                                  AND se.csituac NOT in (2, 4)) LOOP

             SELECT scesrea.NEXTVAL
             INTO w_scesrea
             FROM DUAL;
             INSERT INTO cesionesrea
             VALUES(w_scesrea, rg_cesiones.ncesion, rg_cesiones.icesion, rg_cesiones.icapces,
                    rg_cesiones.sseguro, rg_cesiones.nversio, rg_cesiones.scontra, rg_cesiones.ctramo,
                    rg_cesiones.sfacult, rg_cesiones.nriesgo, rg_cesiones.icomisi, rg_cesiones.icomreg,
                    rg_cesiones.scumulo, rg_cesiones.cgarant, rg_cesiones.spleno, rg_cesiones.ccalif1,
                    rg_cesiones.ccalif2, rg_cesiones.nsinies, rg_cesiones.fefecto, rg_cesiones.fvencim,
                    rg_cesiones.fcontab, rg_cesiones.pcesion, rg_cesiones.sproces, rg_cesiones.cgenera,
                    rg_cesiones.fgenera, NULL, rg_cesiones.fanulac, rg_cesiones.nmovimi, rg_cesiones.sidepag,
                    rg_cesiones.ipritarrea, rg_cesiones.idtosel, rg_cesiones.psobreprima, rg_cesiones.cdetces,
                    rg_cesiones.ipleno, rg_cesiones.icapaci, rg_cesiones.nmovigen, rg_cesiones.iextrap,
                    rg_cesiones.iextrea, rg_cesiones.nreemb, rg_cesiones.nfact, rg_cesiones.nlinea,
                    rg_cesiones.itarifrea, rg_cesiones.icomext, rg_cesiones.ctrampa, rg_cesiones.ctipomov, NULL);

             END LOOP;

         END IF;
         --FIN BUG CONF-294  - Fecha (09/11/2016) - HRE
         FOR vces IN cur_cesiones(regriesgo.sseguro, regriesgo.nriesgo, regriesgo.fefecto,
                                  psproces) LOOP
--DBMS_OUTPUT.put_line('IMPORTANT Dates de la cessi¿ '||vces.fanulac||' '||vces.fregula);
            w_capital := 0;
            w_icesion := 0;
            vpas := 1050;

            FOR vgar IN cgar(vces.sseguro, vces.nriesgo, vces.cgarant, vces.nmovimi) LOOP
               vpas := 1060;

               --KBR 28/05/2014. Sino est¿ informada la garant¿a se acumula tanto cesion como capital por defecto
               IF vces.cgarant IS NULL THEN
                  w_creaseg := 1;
               ELSE
                  codi_error := pac_cesionesrea.f_gar_rea(w_cramo, w_cmodali, w_ctipseg,
                                                          w_ccolect, w_cactivi, vces.cgarant,
                                                          w_creaseg);
               END IF;

               --KBR 28/05/2014.

               --DBMS_OUTPUT.put_line(' reaseg '||w_creaseg);
               IF codi_error <> 0 THEN
                  -- Bug 0021242 - 15/02/2012 - JMF
                  p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                              'err=' || codi_error || ' gar=' || vces.cgarant);
                  RETURN codi_error;
               END IF;

               IF NVL(ldetces, 0) = 2 THEN   -- calcul a l'amortitzaci¿ nom¿s farem la nova producci¿
                  IF lsseg_ant <> regriesgo.sseguro THEN
                     lsseg_ant := regriesgo.sseguro;
                     vpas := 1070;

                     SELECT ADD_MONTHS(TRUNC(LAST_DAY(w_fefecto), 'YYYY'),
                                       (12 / lcforamor)
                                       * CEIL(TO_NUMBER(TO_CHAR(LAST_DAY(w_fefecto), 'MM'))
                                              * lcforamor / 12))
                            - 1
                       INTO lfefecto_ini
                       FROM DUAL;

                     vpas := 1080;

                     IF vces.fefecto = LAST_DAY(vces.fefecto) THEN
                        lfecha := LAST_DAY(vces.fefecto);
                     ELSE
                        vpas := 1090;
                        lfecha := ADD_MONTHS(LAST_DAY(vces.fefecto), -12 / lcforamor);
                     END IF;

                     vpas := 1100;
                     pk_cuadro_amortizacion.calcular_cuadro(regriesgo.sseguro, lfefecto_ini);

                     FOR i IN 1 .. 2000 LOOP
                        vpas := 1110;
                        pk_cuadro_amortizacion.ver_mensajes(i, amortit);
                        -- Canviem el capital de la garantia pel que tenia en la data
                        vgar.icapital := amortit.pendiente;
                        lcapital := amortit.pendiente;

                        IF amortit.famort >= lfecha THEN
                           EXIT;
                        END IF;
                     END LOOP;
                  ELSE
                     vgar.icapital := lcapital;
                  END IF;
               END IF;

               IF w_creaseg = 1 THEN
                  vpas := 1120;
                  w_capital := w_capital + NVL(vgar.icapital, 0);
                  w_icesion := w_icesion + NVL(vgar.iprianu, 0);
               ELSIF w_creaseg = 2 THEN
                  vpas := 1130;
                  w_icesion := w_icesion + NVL(vgar.iprianu, 0);
               ELSIF w_creaseg = 3 THEN
                  vpas := 1140;
                  w_capital := w_capital + NVL(vgar.icapital, 0);
               END IF;
            END LOOP;

            --DBMS_OUTPUT.put_line('inserta ');

            -- busquem el ple i la capacitat inicial
            BEGIN
               vpas := 1150;

               SELECT iretenc, icapaci
                 INTO lipleno, licapaci
                 FROM contratos
                WHERE scontra = vces.scontra
                  AND nversio = vces.nversio;
            EXCEPTION
               WHEN OTHERS THEN
                  -- Bug 0021242 - 15/02/2012 - JMF
                  p_tab_error(f_sysdate, f_user, vobj, vpas,
                              vpar || ' con=' || vces.scontra || ' ver=' || vces.nversio,
                              SQLCODE || ' ' || SQLERRM);
                  RETURN 104704;
            END;

            BEGIN
--DBMS_OUTPUT.put_line('IMPORTANT INSERTO '||vces.cgarant||' '||vces.fefecto||' '||vces.fanulac||' '||vces.fregula||' '||lipleno||' '||licapaci);
               vpas := 1160;

               INSERT INTO cesionesaux
                           (sproces, nnumlin, sseguro, iprirea, icapital, cfacult,
                            cestado, nriesgo, nmovimi, ccalif1, ccalif2, spleno, cgarant,
                            scontra, nversio, fconini, fconfin, ipleno,
                            icapaci, scumulo, sfacult, nagrupa, ipritarrea, idtosel,
                            psobreprima, cdetces, fanulac, fregula)
                    VALUES (pproces, w_numlin, vces.sseguro, w_icesion, w_capital, w_cfacult,
                            0, vces.nriesgo, vces.nmovimi, NULL, NULL, NULL, vces.cgarant,
                            vces.scontra, vces.nversio, vces.fefecto, vces.fvencim, lipleno,
                            licapaci, pscumulo, NULL, NULL, 0, 0,
                            vces.psobreprima, vces.cdetces, vces.fanulac, vces.fregula);

               w_numlin := w_numlin + 1;
            EXCEPTION
               WHEN OTHERS THEN
                  --DBMS_OUTPUT.put_line('xx '||SQLERRM);
                  -- Bug 0021242 - 15/02/2012 - JMF
                  p_tab_error(f_sysdate, f_user, vobj, vpas,
                              vpar || ' seg=' || vces.sseguro || ' rie=' || vces.nriesgo
                              || ' gar=' || vces.cgarant,
                              SQLCODE || ' ' || SQLERRM);
                  RETURN 105193;
            END;
         END LOOP;

         vpas := 1170;

         IF w_sgt = 1
            AND NVL(f_parproductos_v(w_sproduc, 'NO_REA_SGT'), 0) = 0 THEN
            vpas := 1180;
            codi_error := pac_cesionesrea.f_garantarifa_rea(psproces, regriesgo.sseguro,
                                                            regriesgo.nmovimi, w_cramo,
                                                            w_cmodali, w_ctipseg, w_ccolect,
                                                            w_sproduc, w_cactivi,
                                                            regriesgo.fefecto, w_fefecto,
                                                            w_ctarman, w_cobjase, w_cforpag,
                                                            w_cidioma, pmoneda);

            --DBMS_OUTPUT.put_line(' f_garantarifa_rea '||codi_error);
            IF codi_error <> 0 THEN
               -- Bug 0021242 - 15/02/2012 - JMF
               p_tab_error(f_sysdate, f_user, vobj, vpas,
                           vpar || ' seg=' || regriesgo.sseguro || ' mov='
                           || regriesgo.nmovimi || ' efe=' || regriesgo.fefecto,
                           SQLCODE || ' ' || SQLERRM);
               RETURN(codi_error);
            END IF;
         END IF;

         vpas := 1190;
         --INI BUG CONF-294  Fecha (09/11/2016) - HRE - Cumulos
         IF (v_ctiprea != 5) THEN
            codi_error := f_cessio(pproces, 01, pmoneda);
         END IF;
         --FIN BUG CONF-294  - Fecha (09/11/2016) - HRE

         --DBMS_OUTPUT.put_line(' f_cessio '||codi_error);
         IF codi_error <> 0 THEN
            -- Bug 0021242 - 15/02/2012 - JMF
            p_tab_error(f_sysdate, f_user, vobj, vpas, vpar || ' pro=' || pproces,
                        codi_error || ' mon=' || pmoneda);
            RETURN(codi_error);
         ELSIF codi_error = 99 THEN   -- 14536 AVT 19-05-2010 Falta facultativo
            ttexto := f_axis_literales(105382, w_cidioma);
            w_numlin := 99;
            codi_error := f_proceslin(pproces, ttexto, regriesgo.sseguro, w_numlin);
         -- -- 14536 AVT 19-05-2010 fi
         END IF;
      END LOOP;

      vpas := 1199;
      RETURN 0;
   END f_endavant;

-- ************************************************************************
-- ************************************************************************
-- ************************************************************************
   FUNCTION f_solosi(regreariesb cur_reariesb%ROWTYPE)
      RETURN NUMBER IS
/**************************************************************************
    F_SOLOSI   : Funci¿ per crear cessions del risc independitzat...
**************************************************************************/
      codi_error     NUMBER := 0;
      w_sseguro      seguros.sseguro%TYPE;
      w_nriesgo      cesionesrea.nriesgo%TYPE;
      w_cgarant      cesionesrea.cgarant%TYPE;
      w_capital      cesionesaux.icapital%TYPE;
      w_icesion      cesionesrea.icesion%TYPE;
      w_dias         NUMBER;
      w_dias_origen  NUMBER;
      w_scesrea      cesionesrea.scesrea%TYPE;
      w_cobjase      seguros.cobjase%TYPE;
      w_nasegur      riesgos.nasegur%TYPE;
      w_prima        garanseg.iprianu%TYPE;   --25803
      w_numlin       cesionesaux.nnumlin%TYPE := 0;
      w_cfacult      cesionesaux.cfacult%TYPE;
      w_ctiprea      codicontratos.ctiprea%TYPE;
      w_cramo        seguros.cramo%TYPE;
      w_cmodali      seguros.cmodali%TYPE;
      w_ctipseg      seguros.ctipseg%TYPE;
      w_ccolect      garanpro.ccolect%TYPE;
      w_cactivi      garanpro.cactivi%TYPE;
      w_creaseg      garanpro.creaseg%TYPE;
      w_nmovimi      garanseg.nmovimi%TYPE;

      CURSOR cur_cesiones IS
         SELECT   *
             FROM cesionesrea
            WHERE sseguro = w_sseguro
              AND nriesgo = w_nriesgo
              AND(cgarant = w_cgarant
                  OR w_cgarant IS NULL)
              AND(cgenera = 01
                  OR cgenera = 03
                  OR cgenera = 04
                  OR cgenera = 05
                  OR cgenera = 09)
              AND fvencim > pfecini
              AND(fanulac > pfecini
                  OR fanulac IS NULL)
              AND(fregula > pfecini
                  OR fregula IS NULL)
         ORDER BY scesrea;   --bug: 21186  ETM 01/02/2012;

      CURSOR cur_garant IS
         SELECT sseguro, nriesgo, cgarant, icapital, iprianu
           FROM garanseg
          WHERE sseguro = w_sseguro
            AND nriesgo = w_nriesgo
            AND nmovimi = w_nmovimi
            AND(cgarant = w_cgarant
                OR w_cgarant IS NULL);
   BEGIN
      vpas := 1200;
      w_sseguro := regreariesb.sseguro;
      w_nriesgo := regreariesb.nriesgo;
      w_cgarant := regreariesb.cgarant;

      BEGIN
         vpas := 1210;

         SELECT cramo, cmodali, ctipseg, ccolect,
                pac_seguros.ff_get_actividad(sseguro, w_nriesgo), cobjase, creafac
           INTO w_cramo, w_cmodali, w_ctipseg, w_ccolect,
                w_cactivi, w_cobjase, w_cfacult
           FROM seguros
          WHERE sseguro = w_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            -- Bug 0021242 - 15/02/2012 - JMF
            p_tab_error(f_sysdate, f_user, vobj, vpas, vpar || ' seg=' || w_sseguro,
                        SQLCODE || ' ' || SQLERRM);
            codi_error := 101919;
            RETURN(codi_error);
      END;

      FOR regcesion IN cur_cesiones LOOP
         vpas := 1220;

         SELECT ctiprea   -- Nom¿s s'agafa un tram de cada cessi¿...
           INTO w_ctiprea   -- Si s'agafessin tots els trams,
           FROM codicontratos   -- duplicariem cessions...
          WHERE scontra = NVL(regcesion.scontra, 0);

         IF (w_ctiprea = 01
             AND regcesion.ctramo = 01)
            OR(w_ctiprea = 02
               AND regcesion.ctramo = 00)
            OR regcesion.ctramo = 05 THEN
            vpas := 1230;
            w_nmovimi := regcesion.nmovimi;

            IF regcesion.fefecto <= pfecini THEN
               w_fconini := pfecini;
            ELSE
               w_fconini := regcesion.fefecto;
            END IF;

            vpas := 1240;

            IF regcesion.fanulac IS NULL THEN
               IF regcesion.fregula IS NULL THEN
                  w_fconfin := regcesion.fvencim;
               ELSE
                  w_fconfin := regcesion.fregula;
               END IF;
            ELSE
               w_fconfin := regcesion.fanulac;
            END IF;

            w_icesion := 0;
            w_capital := 0;
            vpas := 1250;

            FOR reggarant IN cur_garant LOOP
               -- BUG 11100 - 16/09/2009 - FAL - Crida a la pac_cesionesrea.f_gar_rea per si garantia reasegurable
               vpas := 1260;
               codi_error := pac_cesionesrea.f_gar_rea(w_cramo, w_cmodali, w_ctipseg,
                                                       w_ccolect, w_cactivi,
                                                       reggarant.cgarant, w_creaseg);

               IF codi_error <> 0 THEN
                  -- Bug 0021242 - 15/02/2012 - JMF
                  p_tab_error(f_sysdate, f_user, vobj, vpas,
                              vpar || ' gar=' || reggarant.cgarant, codi_error);
                  RETURN codi_error;
               END IF;

--FI BUG 11100 - 16/09/2009 ¿ FAL
               vpas := 1270;

               IF w_creaseg <> 0 THEN
                  IF w_creaseg = 1
                     OR w_creaseg = 3 THEN
                     w_capital := NVL(reggarant.icapital, 0);
                  ELSE
                     w_capital := 0;
                  END IF;

                  IF w_cobjase = 4 THEN
                     vpas := 1280;

                     SELECT nasegur
                       INTO w_nasegur
                       FROM riesgos
                      WHERE sseguro = reggarant.sseguro
                        AND nriesgo = reggarant.nriesgo;

                     w_prima := reggarant.iprianu * w_nasegur;
                  ELSE
                     w_prima := reggarant.iprianu;
                  END IF;

                  IF w_creaseg = 3 THEN
                     w_prima := 0;
                  END IF;

                  w_icesion := NVL(w_prima, 0);

                  BEGIN
                     w_numlin := w_numlin + 1;
                     vpas := 1290;

                     INSERT INTO cesionesaux
                                 (sproces, nnumlin, sseguro, iprirea,
                                  icapital, cfacult, cestado, nriesgo,
                                  nmovimi, ccalif1, ccalif2, spleno, cgarant,
                                  scontra, nversio, fconini, fconfin,
                                  ipleno, icapaci, scumulo, sfacult, nagrupa)
                          VALUES (pproces, w_numlin, regcesion.sseguro, w_icesion,
                                  NVL(w_capital, 0), w_cfacult, 0, regcesion.nriesgo,
                                  regcesion.nmovimi, NULL, NULL, NULL, regcesion.cgarant,
                                  regcesion.scontra, regcesion.nversio, w_fconini, w_fconfin,
                                  NULL, NULL, NULL, regcesion.sfacult, NULL);
                  EXCEPTION
                     WHEN OTHERS THEN
                        -- Bug 0021242 - 15/02/2012 - JMF
                        p_tab_error(f_sysdate, f_user, vobj, vpas,
                                    vpar || ' seg=' || regcesion.sseguro,
                                    SQLCODE || ' ' || SQLERRM);
                        RETURN 105193;
                  END;
               END IF;
            END LOOP;

            vpas := 1300;
            codi_error := f_cessio(pproces, 01, pmoneda);

            IF codi_error <> 0 THEN
               -- Bug 0021242 - 15/02/2012 - JMF
               p_tab_error(f_sysdate, f_user, vobj, vpas, vpar || ' pro=' || pproces,
                           codi_error);
               RETURN(codi_error);
            END IF;
         END IF;
      END LOOP;

      vpas := 1310;
      RETURN 0;
   END f_solosi;

-- ************************************************************************
-- ************************************************************************
-- ************************************************************************
   FUNCTION f_solono(regreariesa cur_reariesa%ROWTYPE)
      RETURN NUMBER IS
/**************************************************************************
    F_SOLONO   : Funci¿ per crear cessions negatives del risc incorporat...
**************************************************************************/
      codi_error     NUMBER := 0;
      w_sseguro      seguros.sseguro%TYPE;
      w_nriesgo      cesionesrea.nriesgo%TYPE;
      w_cgarant      cesionesrea.cgarant%TYPE;
      w_capital      cesionesaux.icapital%TYPE;
      w_icesion      cesionesrea.icesion%TYPE;
      w_ipritarrea   cesionesrea.ipritarrea%TYPE;
      w_iextrea      cesionesrea.iextrea%TYPE;   -- bug 30326
      w_idtosel      cesionesrea.idtosel%TYPE;
      w_dias         NUMBER;
      w_dias_origen  NUMBER;
      w_scesrea      cesionesrea.scesrea%TYPE;
      w_cobjase      seguros.cobjase%TYPE;
      w_nasegur      riesgos.nasegur%TYPE;
      w_prima        garanseg.iprianu%TYPE;   --25803
      w_numlin       cesionesaux.nnumlin%TYPE := 0;
      w_cfacult      cesionesaux.cfacult%TYPE;
      w_finici       DATE;
      avui           DATE;
      lnmovigen      cesionesrea.nmovigen%TYPE;
      lcforpag       seguros.cforpag%TYPE;
      lsproduc       seguros.sproduc%TYPE;

      CURSOR cur_cesiones IS
         SELECT   *
             FROM cesionesrea
            WHERE sseguro = w_sseguro
              AND nriesgo = w_nriesgo
              AND(cgarant = w_cgarant
                  OR w_cgarant IS NULL)
              AND(cgenera = 01
                  OR cgenera = 03
                  OR cgenera = 04
                  OR cgenera = 05
                  OR cgenera = 09)
              AND fvencim > pfecini
              AND(fanulac > pfecini
                  OR fanulac IS NULL)
              AND(fregula > pfecini
                  OR fregula IS NULL)
         ORDER BY scesrea;   --bug: 21186  ETM 01/02/2012
   BEGIN
      vpas := 1320;
      avui := f_sysdate;
      w_sseguro := regreariesa.sseguro;
      w_nriesgo := regreariesa.nriesgo;
      w_cgarant := regreariesa.cgarant;

      -- Obtenim el n¿ nmovigen
      BEGIN
         vpas := 1330;

         SELECT NVL(MAX(nmovigen), 0) + 1
           INTO lnmovigen
           FROM cesionesrea
          WHERE sseguro = w_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            lnmovigen := 1;
      END;

      BEGIN
         vpas := 1340;

         SELECT cforpag, sproduc
           INTO lcforpag, lsproduc
           FROM seguros
          WHERE sseguro = w_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            -- Bug 0021242 - 15/02/2012 - JMF
            p_tab_error(f_sysdate, f_user, vobj, vpas, vpar || ' seg=' || w_sseguro,
                        SQLCODE || ' ' || SQLERRM);
            RETURN 101919;
      END;

      vpas := 1350;

      FOR regcesion IN cur_cesiones LOOP
         IF regcesion.fefecto <= pfecini THEN
            w_finici := pfecini;
         ELSE
            w_finici := regcesion.fefecto;
         END IF;

         BEGIN
            vpas := 1360;

            UPDATE cesionesrea
               SET fregula = w_finici
             WHERE scesrea = regcesion.scesrea;
         EXCEPTION
            WHEN OTHERS THEN
               -- Bug 0021242 - 15/02/2012 - JMF
               p_tab_error(f_sysdate, f_user, vobj, vpas,
                           vpar || ' ces=' || regcesion.scesrea, SQLCODE || ' ' || SQLERRM);
               RETURN 104589;   -- Error al modificar CESIONESREA
         END;

         vpas := 1370;
         codi_error := f_difdata(regcesion.fefecto, regcesion.fvencim, 3, 3, w_dias_origen);

         IF codi_error <> 0 THEN
            -- Bug 0021242 - 15/02/2012 - JMF
            p_tab_error(f_sysdate, f_user, vobj, vpas,
                        vpar || ' ini=' || regcesion.fefecto || ' fin=' || regcesion.fvencim,
                        codi_error);
            RETURN(codi_error);
         END IF;

         vpas := 1380;
         codi_error := f_difdata(w_finici, regcesion.fvencim, 3, 3, w_dias);

         IF codi_error <> 0 THEN
            -- Bug 0021242 - 15/02/2012 - JMF
            p_tab_error(f_sysdate, f_user, vobj, vpas,
                        vpar || ' ini=' || w_finici || ' fin=' || regcesion.fvencim,
                        codi_error);
            RETURN(codi_error);
         END IF;

-- BUG 11100 - 16/09/2009 - FAL - Substituir crida f_round_forpag per f_round
         vpas := 1390;
         w_icesion := f_round((regcesion.icesion * w_dias) / w_dias_origen, pmoneda);
         w_ipritarrea := f_round((regcesion.ipritarrea * w_dias) / w_dias_origen, pmoneda);
         w_idtosel := f_round((regcesion.idtosel * w_dias) / w_dias_origen, pmoneda);
         /*
         w_icesion := f_round_forpag((regcesion.icesion * w_dias) / w_dias_origen, lcforpag,
                                     pmoneda, lsproduc);
         w_ipritarrea := f_round_forpag((regcesion.ipritarrea * w_dias) / w_dias_origen,
                                        lcforpag, pmoneda, lsproduc);
         w_idtosel := f_round_forpag((regcesion.idtosel * w_dias) / w_dias_origen, lcforpag,
                                     pmoneda, lsproduc);
         */

         --FI BUG 11100 - 16/09/2009 ¿ FAL
         vpas := 1400;
         -- Bug 30326 - 12/09/2014 - DF: extraprima en caso de suplemento Inicio
         w_iextrea := f_round((regcesion.iextrea * w_dias) / w_dias_origen, pmoneda);

         -- Bug 30326 - 12/09/2014 - DF: extraprima en caso de suplemento Fin
         SELECT scesrea.NEXTVAL
           INTO w_scesrea
           FROM DUAL;

         BEGIN
            vpas := 1410;

            INSERT INTO cesionesrea
                        (scesrea, ncesion, icesion, icapces,
                         sseguro, nversio, scontra,
                         ctramo, sfacult, nriesgo,
                         icomisi, icomreg, scumulo,
                         cgarant, spleno, ccalif1,
                         ccalif2, nmovimi, fefecto, fvencim,
                         pcesion, sproces, cgenera, fgenera, ipritarrea, idtosel,
                         psobreprima, cdetces, nmovigen,
                         ipleno, icapaci, iextrea, itarifrea)
                 VALUES (w_scesrea, regcesion.ncesion, w_icesion * -1, regcesion.icapces,
                         regcesion.sseguro, regcesion.nversio, regcesion.scontra,
                         regcesion.ctramo, regcesion.sfacult, regcesion.nriesgo,
                         regcesion.icomisi, regcesion.icomreg, regcesion.scumulo,
                         regcesion.cgarant, regcesion.spleno, regcesion.ccalif1,
                         regcesion.ccalif2, regcesion.nmovimi, w_finici, regcesion.fvencim,
                         regcesion.pcesion, pproces, 08, avui, -w_ipritarrea, -w_idtosel,
                         regcesion.psobreprima, regcesion.cdetces, lnmovigen,
                         regcesion.ipleno, regcesion.icapaci, -w_iextrea, regcesion.itarifrea);
         EXCEPTION
            WHEN OTHERS THEN
               -- Bug 0021242 - 15/02/2012 - JMF
               p_tab_error(f_sysdate, f_user, vobj, vpas,
                           vpar || ' seg=' || regcesion.sseguro, SQLCODE || ' ' || SQLERRM);
               RETURN 105200;
         END;
      END LOOP;

      vpas := 1420;
      RETURN 0;
   END f_solono;
-- ***********************************************************************
-- ***********************************************************************
--  Anul.laci¿ de les cessions del c¿mul original...
--  ******************************************************
BEGIN
   vpas := 1430;
   codi_error := f_atras2(pproces, pfecini, 08,
                          -- BUG 18423 - I- 27/12/2011 - JLB - LCOL000 - Multimoneda
                          pmoneda,   --1,
                          -- BUG 18423 - F- - 27/12/2011 - JLB - LCOL000 - Multimoneda
                          pscumulo, 3, pssegurono);

   --DBMS_OUTPUT.put_line('f_Atras2 '||codi_error);
   IF codi_error <> 0 THEN
      -- Bug 0021242 - 15/02/2012 - JMF
      p_tab_error(f_sysdate, f_user, vobj, vpas, vpar || ' pro=' || pproces, codi_error);
      RETURN(codi_error);
   END IF;

   -- Tirem enrera les cessions de REASEGEMI
   vpas := 1440;
   codi_error := pac_cesionesrea.f_cesdet_anu_cum(pscumulo, pfecini, 4, pssegurono);

                                                  -- 4- Anul. per regulariutzaci¿ c¿mul
--DBMS_OUTPUT.put_line(' f_cesdet_anu_cum '||codi_error );
   IF codi_error <> 0 THEN
      -- Bug 0021242 - 15/02/2012 - JMF
      p_tab_error(f_sysdate, f_user, vobj, vpas, vpar || ' cum=' || pscumulo, codi_error);
      RETURN codi_error;
   END IF;

--  Analitzem l'origen del canvi...
--  *******************************
   IF porigen = 1 THEN   -- ANUL.LACI¿ DE P¿LISSA...
      vpas := 1450;
      codi_error := f_endavant(pproces, pscumulo, pfecini, pmoneda, pssegurono);

      -- Endavant les noves cessions del c¿mul...

      --DBMS_OUTPUT.put_line('f_endavant '||codi_error);
      IF codi_error <> 0 THEN
         -- Bug 0021242 - 15/02/2012 - JMF
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar || ' cum=' || pscumulo, codi_error);
         RETURN codi_error;
      ELSIF codi_error = 99 THEN   -- 14536 AVT hi ha faucltatiu pel c¿mul
         RETURN 0;
      END IF;

      --- Cal tornar a calcular el detall de cessions (reasegemi, detreasegemi)
      vpas := 1460;
      codi_error := pac_cesionesrea.f_cesdet_recalcul(pscumulo, pfecini, pproces, pssegurono);
      --DBMS_OUTPUT.put_line (' f_cesdet_recalc ' || codi_error);
      RETURN codi_error;
   END IF;

----------------------
   vpas := 1470;

   IF porigen = 2 THEN   -- MODIFICACI¿ DE C¿MUL...
      FOR regreariesb IN cur_reariesb   -- S'han tret riscos del c¿mul...
                                     LOOP
         vpas := 1480;
         codi_error := f_solosi(regreariesb);

         -- Endavant cessi¿ individual risc eliminat...
         IF codi_error <> 0 THEN
            -- Bug 0021242 - 15/02/2012 - JMF
            p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, codi_error);
            RETURN(codi_error);
         END IF;
      END LOOP;

      FOR regreariesa IN cur_reariesa   -- S'han afegit riscos al c¿mul...
                                     LOOP
         vpas := 1490;
         codi_error := f_solono(regreariesa);

         -- Enredera cessi¿ individual risc afegit...
         IF codi_error <> 0 THEN
            -- Bug 0021242 - 15/02/2012 - JMF
            p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, codi_error);
            RETURN(codi_error);
         END IF;
      END LOOP;

      vpas := 1500;
      codi_error := f_endavant(pproces, pscumulo, pfecini, pmoneda);

      -- Endavant les cessions del nou c¿mul...
      IF codi_error <> 0 THEN
         -- Bug 0021242 - 15/02/2012 - JMF
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar || ' cum=' || pscumulo, codi_error);
         RETURN(codi_error);
      ELSIF codi_error = 99 THEN   -- 14536 AVT hi ha faucltatiu pel c¿mul
         RETURN 0;
      END IF;

      vpas := 1510;
      codi_error := pac_cesionesrea.f_cesdet_recalcul(pscumulo, pfecini, pproces, pssegurono);
      RETURN codi_error;
   END IF;
END f_cumulo;

/

  GRANT EXECUTE ON "AXIS"."F_CUMULO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CUMULO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CUMULO" TO "PROGRAMADORESCSI";
