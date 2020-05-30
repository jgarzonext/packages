--------------------------------------------------------
--  DDL for Package Body PAC_SUP_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY PAC_SUP_GENERAL AS
/******************************************************************************
 NAME:       PAC_SUP_GENERAL
 PURPOSE:    Contiene las funciones necesarias para realizar un suplemento

 REVISIONS:
 Ver        Date        Author           Description
 ---------  ----------  ---------------  ------------------------------------
 1.0        29/05/2009  RSC              1. Created this package body.
 2.0        29/05/2009  ICV              2. 0008947: CRE046 - Gestión de cobertura Enfermedad Grave en siniestros
 3.0        04/11/20010 APD              3. 16095: Implementacion y parametrizacion producto GROUPLIFE
 4.0        20/12/2011  ASN              4. 0020620: LCOL - SIN - PAC_SUP_GENERAL
 5.0        16/03/2012  JRH              5. 0021686: MdP - MIG - Viabilidad tarificación productos de migración
 6.0        28/05/2013  NSS              6. 0026962: LCOL_S010-SIN - Autos - Acciones iniciar/terminar siniestro
 7.0        09/07/2013  JRH              7. 0027279: Cargas ARL
 8.0        10/07/2013  JGR              0025611: (POSDE100)-Desarrollo-GAPS Administracion-Id 1 - Manejo de pagos de ARP
 9.0        10/07/2013  JGR              0025611#c155551 - En pruebas internas de cargas de ARL vemos que no se crean los recaudos.
 10.0       18/02/2014  ETM              10.0029943: POSRA200 - Gaps 27,28 Anexos de PU en VI
 11.0       03/04/2014  JTT              11. 29943/170733: Tarificar suplementos de PU
 12.0       26/06/2014  JTT              12: 26472/178271: Modificaions f_reduce_capital para informar la pregunta 4866 y EXCLUGARSEG
 13.0       30/06/2015  AFM              13:0034462/208987: Se incorpora nueva función
 14.0       10/05/2019  ECP              14. IAXIS -3631. CAmbio de Estado cuando las pòlizas estàn vencidas
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   mensajes       t_iax_mensajes := NULL;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma;
   v_nmovimi      NUMBER;
   v_est_sseguro  NUMBER;

   FUNCTION iniciarsuple
      RETURN NUMBER IS
   BEGIN
      v_nmovimi := NULL;
      v_est_sseguro := NULL;
      RETURN 0;
   END;

   FUNCTION f_supl_generico(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pcmotmov IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi OUT NUMBER,
      psproces IN NUMBER)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pcgarant= ' || pcgarant
            || ' fecha= ' || pfecha;
      vobject        VARCHAR2(200) := 'PAC_MD_SUP_GENERICO.f_supl_generico';
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      salida         EXCEPTION;
      error_fin_supl EXCEPTION;
      warn_fin_supl  EXCEPTION;
      onpoliza       NUMBER;
      osseguro       NUMBER;
      oncertif       NUMBER;
      onrecibo       NUMBER;
      onsolici       NUMBER;
      v_cforpag      NUMBER;
      v_sperson      NUMBER;
      vcont          NUMBER;
      vcempres       NUMBER;
      vnpoliza       NUMBER;
      vncertif       NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vcidioma       NUMBER;
      v_texto        VARCHAR2(200);
      v_sproces      NUMBER;
      v_nnumlin      NUMBER := NULL;
      v_err          NUMBER;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pfecha IS NULL /*OR pcmotmov IS NULL*/ THEN
         RAISE e_param_error;
      END IF;

-- bug20620:ASN:20/12/2011 ini
/*
      -- Si no viene informacio SPROCES creamos uno
      IF psproces IS NULL THEN
         numerr := f_procesini(getuser, 1, 'SUPL_AUT:' || TO_CHAR(f_sysdate, 'yyyymmdd'),
                               f_axis_literales(805824, f_idiomauser), v_sproces);
      ELSE
         v_sproces := psproces;
      END IF;
*/
-- bug20620:ASN:20/12/2011 fin
--------------------------------------------------------------------------
-- Validar el importe de la prima (si pprima <> 0)
--------------------------------------------------------------------------
      vpasexec := 2;

      SELECT cempres, npoliza, ncertif, cramo, cmodali, ctipseg, ccolect, sproduc,
             cforpag, cactivi, cidioma
        INTO vcempres, vnpoliza, vncertif, vcramo, vcmodali, vctipseg, vccolect, v_sproduc,
             v_cforpag, v_cactivi, vcidioma
        FROM seguros
       WHERE sseguro = psseguro;

-- bug20620:ASN:20/12/2011 ini
      vpasexec := 200;

      -- Si no viene informacio SPROCES creamos uno
      IF psproces IS NULL THEN
         numerr := f_procesini(getuser, vcempres,
                               'SUPL_AUT:' || TO_CHAR(f_sysdate, 'yyyymmdd'),
                               f_axis_literales(805824, f_idiomauser), v_sproces);
      ELSE
         v_sproces := psproces;
      END IF;

-- bug20620:ASN:20/12/2011 fin
      vpasexec := 3;

      SELECT sperson
        INTO v_sperson
        FROM asegurados
       WHERE sseguro = psseguro
         AND norden = 1;

      vpasexec := 4;

-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
-- Todas las funciones a partir de esta deben tener RAISE error_fin_supl
      IF v_est_sseguro IS NULL THEN   --Si ya tenemos el suplemento en las EST no lo creamos de nuevo
         vpasexec := 5;
         --BUG11376-XVM-13102009
         numerr := pk_suplementos.f_permite_suplementos(psseguro, pfecha, pcmotmov);

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;

         vpasexec := 6;

         IF pcmotmov IS NOT NULL THEN
            numerr := pk_suplementos.f_permite_este_suplemento(psseguro, pfecha, pcmotmov);

            IF numerr <> 0 THEN
               v_texto := f_axis_literales (numerr, f_idiomauser);
               v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
               RAISE error_fin_supl;
            END IF;
         END IF;

         vpasexec := 7;
         numerr := pk_suplementos.f_inicializar_suplemento(psseguro, 'SUPLEMENTO', pfecha,
                                                           'BBDD', '*', pcmotmov,
                                                           v_est_sseguro, v_nmovimi);

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;
      END IF;

---------------------------------- CAMBIO ------------------------------
      vpasexec := 8;

      IF pnriesgo IS NULL THEN
         -- bug 0011645 El riesgo no debe estar anulado
         FOR regs3 IN (SELECT r.nriesgo
                         FROM estriesgos r, estseguros s
                        WHERE r.sseguro = s.sseguro
                          AND NVL(r.fanulac, pfecha + 1) > pfecha
                          AND s.sseguro = v_est_sseguro) LOOP
            numerr :=
               pac_tarifas.f_tarifar_riesgo_tot('EST', v_est_sseguro, regs3.nriesgo,
                                                v_nmovimi,

                                                -- JLB - I - BUG 18423 COjo la moneda del producto
                                                                                       --        f_parinstalacion_n('MONEDAINST'),
                                                pac_monedas.f_moneda_producto(v_sproduc),

-- JLB - F - BUG 18423 COjo la moneda del producto
                                                pfecha);

            IF numerr <> 0 THEN
               v_texto := f_axis_literales (numerr, f_idiomauser);
               v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
               RAISE error_fin_supl;
            END IF;
         END LOOP;
      ELSE
         numerr := pac_tarifas.f_tarifar_riesgo_tot('EST', v_est_sseguro, pnriesgo, v_nmovimi,

-- JLB - I - BUG 18423 COjo la moneda del producto
                                          --        f_parinstalacion_n('MONEDAINST'),
                                                    pac_monedas.f_moneda_producto(v_sproduc),

-- JLB - F - BUG 18423 COjo la moneda del producto
                                                    pfecha);

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;
      END IF;

------------------------------------------------------------------------
      vpasexec := 9;
      --
      --Bug 0021686 - JRH - 15/03/2012 - 0021686: MdP - MIG - Viabilidad tarificación productos de migración Se añade el moivo como parámetro
      numerr := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                 'BBDD', 'SUPLEMENTO', vcidioma, pcmotmov);

      --Fi Bug 0021686 - JRH - 15/03/2012
      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      vpasexec := 10;

      BEGIN
         -- s'ha de validar que hi hagin registres
         SELECT COUNT(*)
           INTO vcont
           FROM estdetmovseguro
          WHERE sseguro = v_est_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RAISE error_fin_supl;
      END;

      IF vcont = 0 THEN   -- No hi hagut canvis
         --RAISE error_fin_supl;
         RAISE warn_fin_supl;
      END IF;

      -- Es grava el suplement a las taules reals
      vpasexec := 11;
      numerr := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
      vpasexec := 12;
      numerr := pac_prod_comu.f_emite_propuesta(psseguro, onpoliza, oncertif, onrecibo,
                                                onsolici);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (151237, f_idiomauser);
         v_err := f_procesfin(v_sproces, numerr);
         RAISE error_fin_supl;
      END IF;

      v_est_sseguro := NULL;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 1;
      WHEN warn_fin_supl THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_DIFERIDOS.f_supl_automatic', vpasexec,
                     'Warning: ' || f_axis_literales(numerr, f_idiomauser), numerr);
         numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 0;
      WHEN error_fin_supl THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_supl_generico', vpasexec,
                     'Warning: ' || f_axis_literales(numerr, f_idiomauser), numerr);
         numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_supl_generico', vpasexec,
                     f_axis_literales(numerr, f_idiomauser), SQLERRM);
         numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 1;
   END f_supl_generico;

   -- Cambiar nombre pior f_supl_anul_garantia
   -- Tener en cuenta las garantías dependientes (tamibén en los diferidos)
   FUNCTION f_supl_vto_garantia(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pcmotmov IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi OUT NUMBER,
      psproces IN NUMBER,
      ptarifa IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pcgarant= ' || pcgarant
            || ' fecha= ' || pfecha;
      vobject        VARCHAR2(200) := 'PAC_MD_SUP_GENERICO.f_supl_vto_garantia';
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      salida         EXCEPTION;
      error_fin_supl EXCEPTION;
      warn_fin_supl  EXCEPTION;
      onpoliza       NUMBER;
      osseguro       NUMBER;
      oncertif       NUMBER;
      onrecibo       NUMBER;
      onsolici       NUMBER;
      v_cforpag      NUMBER;
      v_sperson      NUMBER;
      vcont          NUMBER;
      vcempres       NUMBER;
      vnpoliza       NUMBER;
      vncertif       NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vcidioma       NUMBER;
      v_texto        VARCHAR2(200);
      v_sproces      NUMBER;
      v_nnumlin      NUMBER := NULL;
      v_err          NUMBER;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pfecha IS NULL /*OR pcmotmov IS NULL*/ THEN
         RAISE e_param_error;
      END IF;

-- bug 20620:ASN:20/12/2011 ini
/*
      -- Si no viene informacio SPROCES creamos uno
      IF psproces IS NULL THEN
         numerr := f_procesini(getuser, 1, 'SUPL_AUT:' || TO_CHAR(f_sysdate, 'yyyymmdd'),
                               f_axis_literales(805824, f_idiomauser), v_sproces);
      ELSE
         v_sproces := psproces;
      END IF;
*/
-- bug 20620:ASN:20/12/2011 fin

      --------------------------------------------------------------------------
-- Validar el importe de la prima (si pprima <> 0)
--------------------------------------------------------------------------
      vpasexec := 2;

      SELECT cempres, npoliza, ncertif, cramo, cmodali, ctipseg, ccolect, sproduc,
             cforpag, cactivi, cidioma
        INTO vcempres, vnpoliza, vncertif, vcramo, vcmodali, vctipseg, vccolect, v_sproduc,
             v_cforpag, v_cactivi, vcidioma
        FROM seguros
       WHERE sseguro = psseguro;

-- bug 20620:ASN:20/12/2011 ini
      vpasexec := 200;

      -- Si no viene informacio SPROCES creamos uno
      IF psproces IS NULL THEN
         numerr := f_procesini(getuser, vcempres,
                               'SUPL_VTO_GAR' || TO_CHAR(f_sysdate, 'yyyymmdd'),   --bug 29353/174334:NSS;08/05/2014
                               f_axis_literales(805824, f_idiomauser), v_sproces);
      ELSE
         v_sproces := psproces;
      END IF;

-- bug 20620:ASN:20/12/2011 fin
      vpasexec := 3;

      SELECT sperson
        INTO v_sperson
        FROM asegurados
       WHERE sseguro = psseguro
         AND norden = 1;

      vpasexec := 4;

-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
-- Todas las funciones a partir de esta deben tener RAISE error_fin_supl
      IF v_est_sseguro IS NULL THEN   --Si ya tenemos el suplemento en las EST no lo creamos de nuevo
         vpasexec := 5;
         --BUG11376-XVM-13102009
         numerr := pk_suplementos.f_permite_suplementos(psseguro, pfecha, pcmotmov);

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;

         vpasexec := 6;

         IF pcmotmov IS NOT NULL THEN
            numerr := pk_suplementos.f_permite_este_suplemento(psseguro, pfecha, pcmotmov);

            IF numerr <> 0 THEN
               v_texto := f_axis_literales (numerr, f_idiomauser);
               v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
               RAISE error_fin_supl;
            END IF;
         END IF;

         vpasexec := 7;
         numerr := pk_suplementos.f_inicializar_suplemento(psseguro, 'SUPLEMENTO', pfecha,
                                                           'BBDD', '*', pcmotmov,
                                                           v_est_sseguro, v_nmovimi,'NOPRAGMA');

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;
      END IF;

      --Bug.: 8947 - ICV -04/06/2009
      --Actualizamos el creteni de las EST por si estubiese retenida.
      UPDATE estseguros
         SET creteni = 0
       WHERE sseguro = v_est_sseguro;

---------------------------------- CAMBIO ------------------------------
      DELETE      estgaranseg
            WHERE sseguro = v_est_sseguro
              AND nriesgo = pnriesgo
              AND cgarant = pcgarant;

      ---- Damos de baja las garantías dependientes ----
      FOR gar IN (SELECT *
                    FROM garanpro
                   WHERE cgardep = pcgarant
                     AND sproduc = v_sproduc
                     AND cactivi = pac_seguros.ff_get_actividad(v_est_sseguro, pnriesgo, 'EST')) LOOP
         DELETE      estgaranseg
               WHERE sseguro = v_est_sseguro
                 AND nriesgo = pnriesgo
                 AND cgarant = gar.cgarant;
      END LOOP;

      vpasexec := 8;

      IF ptarifa = 1 THEN
         IF pnriesgo IS NULL THEN
            -- bug 0011645 El riesgo no debe estar anulado
            FOR regs3 IN (SELECT r.nriesgo
                            FROM estriesgos r, estseguros s
                           WHERE r.sseguro = s.sseguro
                             AND NVL(r.fanulac, pfecha + 1) > pfecha
                             AND s.sseguro = v_est_sseguro) LOOP
               numerr :=
                  pac_tarifas.f_tarifar_riesgo_tot('EST', v_est_sseguro, regs3.nriesgo,
                                                   v_nmovimi,

                                                   -- JLB - I - BUG 18423 COjo la moneda del producto
                                                                                          --        f_parinstalacion_n('MONEDAINST'),
                                                   pac_monedas.f_moneda_producto(v_sproduc),

                                                   -- JLB - F - BUG 18423 COjo la moneda del producto
                                                   pfecha);

               IF numerr <> 0 THEN
                  v_texto := f_axis_literales (numerr, f_idiomauser);
                  v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
                  RAISE error_fin_supl;
               END IF;
            END LOOP;
         ELSE
            numerr :=
               pac_tarifas.f_tarifar_riesgo_tot('EST', v_est_sseguro, pnriesgo, v_nmovimi,

                                                -- JLB - I - BUG 18423 COjo la moneda del producto
                                                                                       --        f_parinstalacion_n('MONEDAINST'),
                                                pac_monedas.f_moneda_producto(v_sproduc),

                                                -- JLB - F - BUG 18423 COjo la moneda del producto
                                                pfecha);

            IF numerr <> 0 THEN
               v_texto := f_axis_literales (numerr, f_idiomauser);
               v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
               RAISE error_fin_supl;
            END IF;
         END IF;
      END IF;

-----------------------------------------------------------------------
      vpasexec := 9;
      --Ini Bug.: 8947 - ICV - 29/05/2009 - Se añade el paso de parametro pcmotmov
      numerr := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                 'BBDD', 'SUPLEMENTO', vcidioma, pcmotmov);

      --Fin Bug.: 8947 - ICV
      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      vpasexec := 10;

      BEGIN
         -- s'ha de validar que hi hagin registres
         SELECT COUNT(*)
           INTO vcont
           FROM estdetmovseguro
          WHERE sseguro = v_est_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RAISE error_fin_supl;
      END;

      IF vcont = 0 THEN   -- No hi hagut canvis
         --RAISE error_fin_supl;
         RAISE warn_fin_supl;
      END IF;

      -- Es grava el suplement a las taules reals
      vpasexec := 11;
      numerr := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
      vpasexec := 12;

      --bug 26472/0169132:NSS;11/03/2014
      IF pac_seguros.f_es_col_admin(psseguro, 'POL') = 0 THEN
         numerr := pac_prod_comu.f_emite_propuesta(psseguro, onpoliza, oncertif, onrecibo,
                                                   onsolici);

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (151237, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;
      END IF;

      --fin bug 26472/0169132:NSS;11/03/2014
      IF numerr <> 0 THEN
         v_texto := f_axis_literales (151237, f_idiomauser);
         v_err := f_procesfin(v_sproces, numerr);   --bug 29353/174334:NSS;08/05/2014
         RAISE error_fin_supl;
      END IF;

      pnmovimi := v_nmovimi;   -- Bug 26472 - 14/07/2014 -  JTT: Devolvemos el numero de movimiento del suplemento
      v_est_sseguro := NULL;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN numerr;
      WHEN warn_fin_supl THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_DIFERIDOS.f_supl_vto_garantia', vpasexec,
                     'Warning: ' || f_axis_literales(numerr, f_idiomauser), numerr);
         numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 0;
      WHEN error_fin_supl THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_supl_vto_garantia', vpasexec,
                     'Error: ' || f_axis_literales(numerr, f_idiomauser), numerr);
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN numerr;
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_supl_vto_garantia', vpasexec,
                     f_axis_literales(numerr, f_idiomauser), SQLERRM);
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN numerr;
   END f_supl_vto_garantia;

   -- Bug 16095 - APD - 04/11/2010
   -- se crea la funcion f_supl_renova_garantia
   FUNCTION f_supl_renova_garantia(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pcmotmov IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi OUT NUMBER,
      psproces IN NUMBER)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pcgarant= ' || pcgarant
            || ' fecha= ' || pfecha;
      vobject        VARCHAR2(200) := 'PAC_SUP_GENERAL.f_supl_renova_garantia';
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      salida         EXCEPTION;
      error_fin_supl EXCEPTION;
      warn_fin_supl  EXCEPTION;
      onpoliza       NUMBER;
      osseguro       NUMBER;
      oncertif       NUMBER;
      onrecibo       NUMBER;
      onsolici       NUMBER;
      v_cforpag      NUMBER;
      v_sperson      NUMBER;
      vcont          NUMBER;
      vcempres       NUMBER;
      vnpoliza       NUMBER;
      vncertif       NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vcidioma       NUMBER;
      v_texto        VARCHAR2(200);
      v_sproces      NUMBER;
      v_nnumlin      NUMBER := NULL;
      v_err          NUMBER;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pfecha IS NULL /*OR pcmotmov IS NULL*/ THEN
         RAISE e_param_error;
      END IF;

-- bug 20620:ASN:20/12/2011 ini
/*
      -- Si no viene informacio SPROCES creamos uno
      IF psproces IS NULL THEN
         numerr := f_procesini(getuser, 1, 'SUPL_AUT:' || TO_CHAR(f_sysdate, 'yyyymmdd'),
                               f_axis_literales(805824, f_idiomauser), v_sproces);
      ELSE
         v_sproces := psproces;
      END IF;
*/
-- bug 20620:ASN:20/12/2011 fin

      --------------------------------------------------------------------------
-- Validar el importe de la prima (si pprima <> 0)
--------------------------------------------------------------------------
      vpasexec := 2;

      SELECT cempres, npoliza, ncertif, cramo, cmodali, ctipseg, ccolect, sproduc,
             cforpag, cactivi, cidioma
        INTO vcempres, vnpoliza, vncertif, vcramo, vcmodali, vctipseg, vccolect, v_sproduc,
             v_cforpag, v_cactivi, vcidioma
        FROM seguros
       WHERE sseguro = psseguro;

-- bug 20620:ASN:20/12/2011 ini
      vpasexec := 200;

      -- Si no viene informacio SPROCES creamos uno
      IF psproces IS NULL THEN
         numerr := f_procesini(getuser, vcempres,
                               'SUPL_AUT:' || TO_CHAR(f_sysdate, 'yyyymmdd'),
                               f_axis_literales(805824, f_idiomauser), v_sproces);
      ELSE
         v_sproces := psproces;
      END IF;

-- bug 20620:ASN:20/12/2011 fin
      vpasexec := 3;

      SELECT sperson
        INTO v_sperson
        FROM asegurados
       WHERE sseguro = psseguro
         AND norden = 1;

      vpasexec := 4;

-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
-- Todas las funciones a partir de esta deben tener RAISE error_fin_supl
      IF v_est_sseguro IS NULL THEN   --Si ya tenemos el suplemento en las EST no lo creamos de nuevo
         vpasexec := 5;
         --BUG11376-XVM-13102009
         numerr := pk_suplementos.f_permite_suplementos(psseguro, pfecha, pcmotmov);

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;

         vpasexec := 6;

         IF pcmotmov IS NOT NULL THEN
            numerr := pk_suplementos.f_permite_este_suplemento(psseguro, pfecha, pcmotmov);

            IF numerr <> 0 THEN
               v_texto := f_axis_literales (numerr, f_idiomauser);
               v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
               RAISE error_fin_supl;
            END IF;
         END IF;

         vpasexec := 7;
         numerr := pk_suplementos.f_inicializar_suplemento(psseguro, 'SUPLEMENTO', pfecha,
                                                           'BBDD', '*', pcmotmov,
                                                           v_est_sseguro, v_nmovimi);

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;
      END IF;

      --Bug.: 8947 - ICV -04/06/2009
      --Actualizamos el creteni de las EST por si estubiese retenida.
      UPDATE estseguros
         SET creteni = 0
       WHERE sseguro = v_est_sseguro;

---------------------------------- CAMBIO ------------------------------
      -- se debe añadir un año a la fecha de vencimiento (ya que la garantia renueva)
      UPDATE estdetgaranseg
         SET fvencim = ADD_MONTHS(fvencim, 12),
             cunica = 3
       WHERE sseguro = v_est_sseguro
         AND nriesgo = pnriesgo
         AND cgarant = pcgarant
         AND nmovimi = (SELECT MAX(d.nmovimi)
                          FROM garanseg g, detgaranseg d, estseguros s
                         WHERE s.sseguro = v_est_sseguro
                           AND s.ssegpol = g.sseguro
                           AND g.cgarant = pcgarant
                           AND g.ffinefe IS NULL
                           AND d.sseguro = g.sseguro
                           AND d.cgarant = g.cgarant
                           AND d.nriesgo = g.nriesgo
                           AND d.nmovimi = g.nmovimi
                           AND g.nriesgo = pnriesgo
                           AND cunica <> 1)
         AND ndetgar IN(SELECT d.ndetgar
                          FROM garanseg g, detgaranseg d, estseguros s
                         WHERE s.sseguro = v_est_sseguro
                           AND s.ssegpol = g.sseguro
                           AND g.cgarant = pcgarant
                           AND g.ffinefe IS NULL
                           AND d.sseguro = g.sseguro
                           AND d.cgarant = g.cgarant
                           AND d.nriesgo = g.nriesgo
                           AND d.nmovimi = g.nmovimi
                           AND g.nriesgo = pnriesgo
                           AND cunica <> 1)
         AND cunica <> 1;   -- cunica = 1 --> Aportación extra. Estas se deben quedar como están!

      -- se modifica la pregunta 1043 de la garantia 'TEMPORARY' con valor de
      -- respuesta (fecha) + 1 año
      UPDATE estpregungaranseg
         SET crespue = TO_CHAR(ADD_MONTHS(TO_DATE(crespue, 'yyyymmdd'), 12), 'yyyymmdd')
       WHERE sseguro = v_est_sseguro
         AND nriesgo = pnriesgo
         AND cgarant = pcgarant
         AND nmovimi = (SELECT MAX(nmovimi)
                          FROM estpregungaranseg
                         WHERE sseguro = v_est_sseguro
                           AND nriesgo = pnriesgo
                           AND cgarant = pcgarant
                           AND cpregun = 1043)
         AND cpregun = 1043;

      vpasexec := 8;

      IF pnriesgo IS NULL THEN
         -- bug 0011645 El riesgo no debe estar anulado
         FOR regs3 IN (SELECT r.nriesgo
                         FROM estriesgos r, estseguros s
                        WHERE r.sseguro = s.sseguro
                          AND NVL(r.fanulac, pfecha + 1) > pfecha
                          AND s.sseguro = v_est_sseguro) LOOP
            numerr :=
               pac_tarifas.f_tarifar_riesgo_tot('EST', v_est_sseguro, regs3.nriesgo,
                                                v_nmovimi,

                                                -- JLB - I - BUG 18423 COjo la moneda del producto
                                                                                       --        f_parinstalacion_n('MONEDAINST'),
                                                pac_monedas.f_moneda_producto(v_sproduc),

-- JLB - F - BUG 18423 COjo la moneda del producto
                                                pfecha, 'NP', 'MODIF');

            IF numerr <> 0 THEN
               v_texto := f_axis_literales (numerr, f_idiomauser);
               v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
               RAISE error_fin_supl;
            END IF;
         END LOOP;
      ELSE
         numerr := pac_tarifas.f_tarifar_riesgo_tot('EST', v_est_sseguro, pnriesgo, v_nmovimi,

                                                    -- JLB - I - BUG 18423 COjo la moneda del producto
                                                                                           --        f_parinstalacion_n('MONEDAINST'),
                                                    pac_monedas.f_moneda_producto(v_sproduc),

-- JLB - F - BUG 18423 COjo la moneda del producto
                                                    pfecha, 'NP', 'MODIF');

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;
      END IF;

-----------------------------------------------------------------------
      vpasexec := 9;
      --Ini Bug.: 8947 - ICV - 29/05/2009 - Se añade el paso de parametro pcmotmov
      numerr := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                 'BBDD', 'SUPLEMENTO', vcidioma, pcmotmov);

      --Fin Bug.: 8947 - ICV
      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      vpasexec := 10;

      BEGIN
         -- s'ha de validar que hi hagin registres
         SELECT COUNT(*)
           INTO vcont
           FROM estdetmovseguro
          WHERE sseguro = v_est_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RAISE error_fin_supl;
      END;

      IF vcont = 0 THEN   -- No hi hagut canvis
         --RAISE error_fin_supl;
         RAISE warn_fin_supl;
      END IF;

      -- Es grava el suplement a las taules reals
      vpasexec := 11;
      numerr := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
      vpasexec := 12;
      numerr := pac_prod_comu.f_emite_propuesta(psseguro, onpoliza, oncertif, onrecibo,
                                                onsolici);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (151237, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      v_est_sseguro := NULL;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN numerr;
      WHEN warn_fin_supl THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_DIFERIDOS.f_supl_renova_garantia', vpasexec,
                     'Warning: ' || f_axis_literales(numerr, f_idiomauser), numerr);
         numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 0;
      WHEN error_fin_supl THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_supl_renova_garantia', vpasexec,
                     'Error: ' || f_axis_literales(numerr, f_idiomauser), numerr);
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN numerr;
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_supl_renova_garantia', vpasexec,
                     f_axis_literales(numerr, f_idiomauser), SQLERRM);
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN numerr;
   END f_supl_renova_garantia;

-- Fin Bug 16095 - APD - 04/11/2010
   FUNCTION f_supl_exonera(   -- bug 19416:ASN:28/10/2011
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pcmotmov IN NUMBER,
      pnmovimi OUT NUMBER,
      psproces IN NUMBER)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
              := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' fecha= ' || pfecha;
      vobject        VARCHAR2(200) := 'PAC_SUP_GENERAL.f_supl_exonera';
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      salida         EXCEPTION;
      error_fin_supl EXCEPTION;
      warn_fin_supl  EXCEPTION;
      onpoliza       NUMBER;
      osseguro       NUMBER;
      oncertif       NUMBER;
      onrecibo       NUMBER;
      onsolici       NUMBER;
      v_cforpag      NUMBER;
      v_sperson      NUMBER;
      vcont          NUMBER;
      vcempres       NUMBER;
      vnpoliza       NUMBER;
      vncertif       NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vcidioma       NUMBER;
      v_texto        VARCHAR2(200);
      v_sproces      NUMBER;
      v_nnumlin      NUMBER := NULL;
      v_err          NUMBER;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pfecha IS NULL
         OR pcmotmov IS NULL THEN
         RAISE e_param_error;
      END IF;

-- bug 20620:ASN:20/12/2011 ini
/*
      -- Si no viene informacio SPROCES creamos uno
      IF psproces IS NULL THEN
         numerr := f_procesini(getuser, 1, 'SUPL_AUT:' || TO_CHAR(f_sysdate, 'yyyymmdd'),
                               f_axis_literales(805824, f_idiomauser), v_sproces);
      ELSE
         v_sproces := psproces;
      END IF;
*/
-- bug 20620:ASN:20/12/2011 fin
      vpasexec := 2;

      SELECT cempres, npoliza, ncertif, cramo, cmodali, ctipseg, ccolect, sproduc,
             cforpag, cactivi, cidioma
        INTO vcempres, vnpoliza, vncertif, vcramo, vcmodali, vctipseg, vccolect, v_sproduc,
             v_cforpag, v_cactivi, vcidioma
        FROM seguros
       WHERE sseguro = psseguro;

-- bug 20620:ASN:20/12/2011 ini
      vpasexec := 200;

      -- Si no viene informacio SPROCES creamos uno
      IF psproces IS NULL THEN
         numerr := f_procesini(getuser, vcempres,
                               'SUPL_AUT:' || TO_CHAR(f_sysdate, 'yyyymmdd'),
                               f_axis_literales(805824, f_idiomauser), v_sproces);
      ELSE
         v_sproces := psproces;
      END IF;

-- bug 20620:ASN:20/12/2011 fin
      vpasexec := 3;
-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
      vpasexec := 5;
      numerr := pk_suplementos.f_permite_suplementos(psseguro, pfecha, pcmotmov);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      vpasexec := 6;

      IF pcmotmov IS NOT NULL THEN
         numerr := pk_suplementos.f_permite_este_suplemento(psseguro, pfecha, pcmotmov);

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;
      END IF;

      vpasexec := 7;
      numerr := pk_suplementos.f_inicializar_suplemento(psseguro, 'SUPLEMENTO', pfecha, 'BBDD',
                                                        '*', pcmotmov, v_est_sseguro,
                                                        v_nmovimi);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      --Bug.: 8947 - ICV -04/06/2009
      --Actualizamos el creteni de las EST por si estuviese retenida.
      UPDATE estseguros
         SET creteni = 0
       WHERE sseguro = v_est_sseguro;

---------------------------------- CAMBIO ------------------------------

      -- Baja de garantias
      UPDATE estgaranseg
         SET cobliga = 0
       WHERE sseguro = v_est_sseguro
         AND nriesgo = pnriesgo
         AND cgarant IN(SELECT cgarant
                          FROM pargaranpro
                         WHERE cpargar = 'AFECTADA_POR_EXO'
                           AND sproduc = v_sproduc
                           AND cvalpar = 1);

-- bug 21402:ASN:20/02/2012 ini
-- Modificar la cta bancaria de la poliza
/*      UPDATE estseguros
         SET (ctipcob, cbancar, ctipban) =
                (SELECT 2,   -- domiciliacion
                          cbancar, ctipban
                   FROM per_ccc p, empresas e
                  WHERE p.sperson = e.sperson
                    AND e.cempres = pac_md_common.f_get_cxtempresa
                    AND p.cdefecto = 1)
       WHERE sseguro = v_est_sseguro;*/

      -- Modificar la forma de cobro
      UPDATE estseguros
         SET ctipcob = 18   -- efectivo
       WHERE sseguro = v_est_sseguro;

-- bug 21402:ASN:20/02/2012 fin

      -- Modificar revalorizacion
      UPDATE estgaranseg
--         SET crevali = 0 -- 19416:ASN:24/02/2012
      SET prevali = 0
       WHERE sseguro = v_est_sseguro
         AND nriesgo = pnriesgo;

      UPDATE estseguros
         SET crevali = 0
       WHERE sseguro = v_est_sseguro;

-- Tarificamos
      numerr := pac_tarifas.f_tarifar_riesgo_tot('EST', v_est_sseguro, pnriesgo, v_nmovimi,

                                                 -- JLB - I - BUG 18423 COjo la moneda del producto
                                                                                        --        f_parinstalacion_n('MONEDAINST'),
                                                 pac_monedas.f_moneda_producto(v_sproduc),

-- JLB - F - BUG 18423 COjo la moneda del producto
                                                 pfecha);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      vpasexec := 9;
      numerr := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                 'BBDD', 'SUPLEMENTO', vcidioma, pcmotmov);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      vpasexec := 10;

      BEGIN
         -- s'ha de validar que hi hagin registres
         SELECT COUNT(*)
           INTO vcont
           FROM estdetmovseguro
          WHERE sseguro = v_est_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RAISE error_fin_supl;
      END;

      IF vcont = 0 THEN   -- No hi hagut canvis
         RAISE warn_fin_supl;
      END IF;

-- Se graba el suplemento en las tablas reales
      vpasexec := 11;
      numerr := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      UPDATE movseguro
         SET cmotmov = pcmotmov
       WHERE sseguro = psseguro
         AND nmovimi = v_nmovimi;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
      vpasexec := 12;
      numerr := pac_prod_comu.f_emite_propuesta(psseguro, onpoliza, oncertif, onrecibo,
                                                onsolici);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (151237, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN numerr;
      WHEN warn_fin_supl THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_supl_exonera', vpasexec,
                     'Warning: ' || f_axis_literales(numerr, f_idiomauser), numerr);
         numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 0;
      WHEN error_fin_supl THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_supl_exonera', vpasexec,
                     'Error: ' || f_axis_literales(numerr, f_idiomauser), numerr);
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN numerr;
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_supl_exonera', vpasexec,
                     f_axis_literales(numerr, f_idiomauser), SQLERRM);
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN numerr;
   END f_supl_exonera;

   FUNCTION f_reduce_capital(   -- creacion bug 21131:ASN:09/02/2012
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pcmotmov IN NUMBER,
      pcgarant IN NUMBER,
      pivalora IN NUMBER,
      pnmovimi OUT NUMBER,
      psproces IN NUMBER)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pcgarant= ' || pcgarant
            || ' fecha= ' || pfecha || ' pcgarant= ' || pcgarant || ' pivalora= ' || pivalora;
      vobject        VARCHAR2(200) := 'PAC_SUP_GENERAL.f_reduce_capital';
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      salida         EXCEPTION;
      error_fin_supl EXCEPTION;
      warn_fin_supl  EXCEPTION;
      onpoliza       NUMBER;
      osseguro       NUMBER;
      oncertif       NUMBER;
      onrecibo       NUMBER;
      onsolici       NUMBER;
      v_cforpag      NUMBER;
      v_sperson      NUMBER;
      vcont          NUMBER;
      vcempres       NUMBER;
      vnpoliza       NUMBER;
      vncertif       NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vcidioma       NUMBER;
      v_texto        VARCHAR2(200);
      v_sproces      NUMBER;
      v_nnumlin      NUMBER := NULL;
      v_err          NUMBER;
      vicapital_new  NUMBER;
      v_nmovima      NUMBER;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pfecha IS NULL
         OR pcgarant IS NULL
         OR pivalora IS NULL THEN
         RAISE e_param_error;
      END IF;

--------------------------------------------------------------------------
-- Validar el importe de la prima (si pprima <> 0)
--------------------------------------------------------------------------
      vpasexec := 2;

      SELECT cempres, npoliza, ncertif, cramo, cmodali, ctipseg, ccolect, sproduc,
             cforpag, cactivi, cidioma
        INTO vcempres, vnpoliza, vncertif, vcramo, vcmodali, vctipseg, vccolect, v_sproduc,
             v_cforpag, v_cactivi, vcidioma
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 200;

      -- Si no viene informacio SPROCES creamos uno
      IF psproces IS NULL THEN
         numerr := f_procesini(getuser, vcempres,
                               'SUPL_RED_CAP' || TO_CHAR(f_sysdate, 'yyyymmdd'),
                               f_axis_literales(805824, f_idiomauser), v_sproces);
      ELSE
         v_sproces := psproces;
      END IF;

      vpasexec := 3;

      SELECT sperson
        INTO v_sperson
        FROM asegurados
       WHERE sseguro = psseguro
         AND norden = 1;

      vpasexec := 4;

-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
      IF v_est_sseguro IS NULL THEN   --Si ya tenemos el suplemento en las EST no lo creamos de nuevo
         vpasexec := 5;
         numerr := pk_suplementos.f_permite_suplementos(psseguro, pfecha, pcmotmov);

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;

         vpasexec := 6;

         IF pcmotmov IS NOT NULL THEN
            numerr := pk_suplementos.f_permite_este_suplemento(psseguro, pfecha, pcmotmov);

            IF numerr <> 0 THEN
               v_texto := f_axis_literales (numerr, f_idiomauser);
               v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
               RAISE error_fin_supl;
            END IF;
         END IF;

         vpasexec := 7;
         numerr := pk_suplementos.f_inicializar_suplemento(psseguro, 'SUPLEMENTO', pfecha,
                                                           'BBDD', '*', pcmotmov,
                                                           v_est_sseguro, v_nmovimi);

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;
      END IF;

      --Actualizamos el creteni de las EST por si estubiese retenida.
      vpasexec := 8;

      UPDATE estseguros
         SET creteni = 0
       WHERE sseguro = v_est_sseguro;

---------------------------------- CAMBIO ------------------------------
      SELECT icapital - pivalora
        INTO vicapital_new
        FROM estgaranseg
       WHERE sseguro = v_est_sseguro
         AND nriesgo = pnriesgo
         AND cgarant = pcgarant;

      vpasexec := 9;

      SELECT nmovima
        INTO v_nmovima
        FROM estgaranseg
       WHERE sseguro = v_est_sseguro
         AND nriesgo = pnriesgo
         AND cgarant = pcgarant
         AND nmovimi = v_nmovimi;

      IF vicapital_new > 0 THEN
         vpasexec := 10;

         UPDATE estgaranseg
            SET icapital = vicapital_new
          WHERE sseguro = v_est_sseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant;
      ELSE   -- si se ha agotado el capital, damos de baja la garantia
         vpasexec := 11;
         numerr := f_marcar_excluir_garantia(psseguro, pnriesgo, pcgarant, v_nmovimi);   -- 26472

         DELETE      estgaranseg
               WHERE sseguro = v_est_sseguro
                 AND nriesgo = pnriesgo
                 AND cgarant = pcgarant;

         ---- Damos de baja las garantías dependientes ----
         FOR gar IN (SELECT *
                       FROM garanpro
                      WHERE cgardep = pcgarant
                        AND sproduc = v_sproduc
                        AND cactivi = pac_seguros.ff_get_actividad(v_est_sseguro, pnriesgo,
                                                                   'EST')) LOOP
            DELETE      estgaranseg
                  WHERE sseguro = v_est_sseguro
                    AND nriesgo = pnriesgo
                    AND cgarant = gar.cgarant;
         END LOOP;
      END IF;

      vpasexec := 12;

      -- Bug 26472 - 26/06/2014 - JTT
      -- Añadimos/modificamos la pregunta 4866 de la garantia con el importe que reducimos del capital
      IF vicapital_new > 0 THEN
         BEGIN
            vpasexec := 13;

            INSERT INTO estpregungaranseg
                        (sseguro, nriesgo, cgarant, nmovimi, cpregun, crespue,
                         nmovima, finiefe, trespue)
                 VALUES (v_est_sseguro, pnriesgo, pcgarant, v_nmovimi, 4866, pivalora,
                         v_nmovima, pfecha, NULL);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               vpasexec := 14;

               UPDATE estpregungaranseg
                  SET crespue = NVL(crespue, 0) + pivalora
                WHERE sseguro = v_est_sseguro
                  AND nriesgo = pnriesgo
                  AND cgarant = pcgarant
                  AND nmovimi = v_nmovimi
                  AND cpregun = 4866;
         END;
      END IF;

      vpasexec := 15;

      -- Fi bug 26472
      IF pnriesgo IS NULL THEN
         FOR regs3 IN (SELECT r.nriesgo
                         FROM estriesgos r, estseguros s
                        WHERE r.sseguro = s.sseguro
                          AND NVL(r.fanulac, pfecha + 1) > pfecha
                          AND s.sseguro = v_est_sseguro) LOOP
            numerr :=
               pac_tarifas.f_tarifar_riesgo_tot('EST', v_est_sseguro, regs3.nriesgo,
                                                v_nmovimi,
                                                pac_monedas.f_moneda_producto(v_sproduc),
                                                pfecha);

            IF numerr <> 0 THEN
               v_texto := f_axis_literales (numerr, f_idiomauser);
               v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
               RAISE error_fin_supl;
            END IF;
         END LOOP;
      ELSE
         numerr := pac_tarifas.f_tarifar_riesgo_tot('EST', v_est_sseguro, pnriesgo, v_nmovimi,
                                                    pac_monedas.f_moneda_producto(v_sproduc),
                                                    pfecha);

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;
      END IF;

-----------------------------------------------------------------------
      vpasexec := 16;
      numerr := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                 'BBDD', 'SUPLEMENTO', vcidioma, pcmotmov);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      vpasexec := 17;

      BEGIN
         -- se ha de validar que haya registros
         SELECT COUNT(*)
           INTO vcont
           FROM estdetmovseguro
          WHERE sseguro = v_est_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RAISE error_fin_supl;
      END;

      IF vcont = 0 THEN   -- No hay canbios
         RAISE warn_fin_supl;
      END IF;

      vpasexec := 18;
      numerr := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      UPDATE movseguro
         SET cmotmov = pcmotmov
       WHERE sseguro = psseguro
         AND nmovimi = v_nmovimi;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
      vpasexec := 19;

      --bug 26472/0169132:NSS;11/03/2014
      IF pac_seguros.f_es_col_admin(psseguro, 'POL') = 0 THEN
         numerr := pac_prod_comu.f_emite_propuesta(psseguro, onpoliza, oncertif, onrecibo,
                                                   onsolici);

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (151237, f_idiomauser);
            v_err := f_procesfin(v_sproces, numerr);   --bug 29353/174334:NSS;08/05/2014
            RAISE error_fin_supl;
         END IF;
      END IF;

      --fin bug 26472/0169132:NSS;11/03/2014
      v_est_sseguro := NULL;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobject, 0, vparam, 'error parametros');
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN numerr;
      WHEN warn_fin_supl THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_reduce_capital', vpasexec,
                     numerr || ' Warning: ' || f_axis_literales(numerr, f_idiomauser), vparam);
         numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 0;
      WHEN error_fin_supl THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_reduce_capital', vpasexec,
                     f_axis_literales(numerr, f_idiomauser) || ' ' || vparam, numerr);
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN numerr;
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_reduce_capital', vpasexec,
                     f_axis_literales(numerr, f_idiomauser) || ' ' || vparam, SQLERRM);
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN numerr;
   END f_reduce_capital;

   FUNCTION f_revalorizacion_poliza(   -- creacion bug 26962:NSS:22/05/2013
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pcmotmov IN NUMBER,
      pcgarant IN NUMBER,
      pivalora IN NUMBER,
      pnmovimi OUT NUMBER,
      psproces IN NUMBER)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := ' psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pcgarant= '
            || pcgarant || ' fecha= ' || pfecha || ' pcgarant= ' || pcgarant || ' pivalora= '
            || pivalora;
      vobject        VARCHAR2(200) := 'PAC_SUP_GENERAL.f_revalorizacion_poliza';
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      salida         EXCEPTION;
      error_fin_supl EXCEPTION;
      warn_fin_supl  EXCEPTION;
      onpoliza       NUMBER;
      osseguro       NUMBER;
      oncertif       NUMBER;
      onrecibo       NUMBER;
      onsolici       NUMBER;
      v_cforpag      NUMBER;
      v_sperson      NUMBER;
      vcont          NUMBER;
      vcempres       NUMBER;
      vnpoliza       NUMBER;
      vncertif       NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vcidioma       NUMBER;
      v_texto        VARCHAR2(200);
      v_sproces      NUMBER;
      v_nnumlin      NUMBER := NULL;
      v_err          NUMBER;
      vicapital_new  NUMBER;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pfecha IS NULL
         OR pcgarant IS NULL
         OR pivalora IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      SELECT cempres, npoliza, ncertif, cramo, cmodali, ctipseg, ccolect, sproduc,
             cforpag, cactivi, cidioma
        INTO vcempres, vnpoliza, vncertif, vcramo, vcmodali, vctipseg, vccolect, v_sproduc,
             v_cforpag, v_cactivi, vcidioma
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 200;

      -- Si no viene informacio SPROCES creamos uno
      IF psproces IS NULL THEN
         numerr := f_procesini(getuser, vcempres,
                               'SUP_REVA_POL' || TO_CHAR(f_sysdate, 'yyyymmdd'),
                               f_axis_literales(805824, f_idiomauser), v_sproces);
      ELSE
         v_sproces := psproces;
      END IF;

      vpasexec := 3;

      SELECT sperson
        INTO v_sperson
        FROM asegurados
       WHERE sseguro = psseguro
         AND norden = 1;

      vpasexec := 4;

-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
      IF v_est_sseguro IS NULL THEN   --Si ya tenemos el suplemento en las EST no lo creamos de nuevo
         vpasexec := 5;
         numerr := pk_suplementos.f_permite_suplementos(psseguro, pfecha, pcmotmov);

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;

         vpasexec := 6;

         IF pcmotmov IS NOT NULL THEN
            numerr := pk_suplementos.f_permite_este_suplemento(psseguro, pfecha, pcmotmov);

            IF numerr <> 0 THEN
               v_texto := f_axis_literales (numerr, f_idiomauser);
               v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
               RAISE error_fin_supl;
            END IF;
         END IF;

         vpasexec := 7;
         numerr := pk_suplementos.f_inicializar_suplemento(psseguro, 'SUPLEMENTO', pfecha,
                                                           'BBDD', '*', pcmotmov,
                                                           v_est_sseguro, v_nmovimi);

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;
      END IF;

      --Actualizamos el creteni de las EST por si estubiese retenida.
      UPDATE estseguros
         SET creteni = 0
       WHERE sseguro = v_est_sseguro;

      vpasexec := 8;

---------------------------------- CAMBIO ------------------------------
      UPDATE estautriesgos
         SET ivehicu = pivalora
       WHERE sseguro = v_est_sseguro
         AND nriesgo = pnriesgo
         AND nmovimi = v_nmovimi;

      vpasexec := 9;
-- Tarificamos
      numerr := pac_tarifas.f_tarifar_riesgo_tot('EST', v_est_sseguro, pnriesgo, v_nmovimi,
                                                 pac_monedas.f_moneda_producto(v_sproduc),
                                                 pfecha);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

-----------------------------------------------------------------------
      vpasexec := 10;
      numerr := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                 'BBDD', 'SUPLEMENTO', vcidioma, pcmotmov);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      vpasexec := 11;

      BEGIN
         -- se ha de validar que haya registros
         SELECT COUNT(*)
           INTO vcont
           FROM estdetmovseguro
          WHERE sseguro = v_est_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RAISE error_fin_supl;
      END;

      IF vcont = 0 THEN   -- No hay canbios
         RAISE warn_fin_supl;
      END IF;

      vpasexec := 12;
      numerr := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      UPDATE movseguro
         SET cmotmov = pcmotmov
       WHERE sseguro = psseguro
         AND nmovimi = v_nmovimi;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
      vpasexec := 13;
      numerr := pac_prod_comu.f_emite_propuesta(psseguro, onpoliza, oncertif, onrecibo,
                                                onsolici);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (151237, f_idiomauser);
         v_err := f_procesfin(v_sproces, numerr);   --bug 29353/174334:NSS;08/05/2014
         RAISE error_fin_supl;
      END IF;

      v_est_sseguro := NULL;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobject, 0, vparam, 'error parametros');
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN numerr;
      WHEN warn_fin_supl THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_revalorizacion_poliza', vpasexec,
                     numerr || ' Warning: ' || f_axis_literales(numerr, f_idiomauser), vparam);
         numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 0;
      WHEN error_fin_supl THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_revalorizacion_poliza', vpasexec,
                     f_axis_literales(numerr, f_idiomauser) || ' ' || vparam, numerr);
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN numerr;
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_revalorizacion_poliza', vpasexec,
                     f_axis_literales(numerr, f_idiomauser) || ' ' || vparam, SQLERRM);
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN numerr;
   END f_revalorizacion_poliza;

   --Bug 0021686 - JRH - 10/07/2013 - 0027279: POS  - Carga ARL
   FUNCTION f_suplemento_factuacion(   -- creacion bug 27279:JRH:09/02/2012
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pcmotmov IN NUMBER,
      pcgarant IN NUMBER,
      pibruto IN NUMBER,
      pineto IN NUMBER,
      pnmovimi OUT NUMBER,
      pnrecibo OUT NUMBER,
      psproces IN NUMBER)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pcgarant= ' || pcgarant
            || ' fecha= ' || pfecha || ' pcgarant= ' || pcgarant || ' pimporte= ' || pibruto;
      vobject        VARCHAR2(200) := 'PAC_SUP_GENERAL.f_suplemento_factuacion';
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      salida         EXCEPTION;
      error_fin_supl EXCEPTION;
      warn_fin_supl  EXCEPTION;
      onpoliza       NUMBER;
      osseguro       NUMBER;
      oncertif       NUMBER;
      onrecibo       NUMBER;
      onsolici       NUMBER;
      v_cforpag      NUMBER;
      v_sperson      NUMBER;
      vcont          NUMBER;
      vcempres       NUMBER;
      vnpoliza       NUMBER;
      vncertif       NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vcidioma       NUMBER;
      v_texto        VARCHAR2(200);
      v_sproces      NUMBER;
      v_nnumlin      NUMBER := NULL;
      v_err          NUMBER;
      vicapital_new  NUMBER;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pfecha IS NULL
         OR pcgarant IS NULL
         OR pibruto IS NULL THEN
         RAISE e_param_error;
      END IF;

--------------------------------------------------------------------------
-- Validar el importe de la prima (si pprima <> 0)
--------------------------------------------------------------------------
      vpasexec := 2;

      SELECT cempres, npoliza, ncertif, cramo, cmodali, ctipseg, ccolect, sproduc,
             cforpag, cactivi, cidioma
        INTO vcempres, vnpoliza, vncertif, vcramo, vcmodali, vctipseg, vccolect, v_sproduc,
             v_cforpag, v_cactivi, vcidioma
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 200;

      -- Si no viene informacio SPROCES creamos uno
      IF psproces IS NULL THEN
         numerr := f_procesini(getuser, vcempres,
                               'SUPL_AUT:' || TO_CHAR(f_sysdate, 'yyyymmdd'),
                               f_axis_literales(805824, f_idiomauser), v_sproces);
      ELSE
         v_sproces := psproces;
      END IF;

      vpasexec := 3;
      -- 0025611: (POSDE100)-Desarrollo-GAPS Administracion-Id 1 - Manejo de pagos de ARP - Inicio
      /*
      SELECT sperson
        INTO v_sperson
        FROM asegurados
       WHERE sseguro = psseguro
         AND norden = 1;
      */
      -- 0025611: (POSDE100)-Desarrollo-GAPS Administracion-Id 1 - Manejo de pagos de ARP - Final
      vpasexec := 4;

-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
      IF v_est_sseguro IS NULL THEN   --Si ya tenemos el suplemento en las EST no lo creamos de nuevo
         vpasexec := 5;
         numerr := pk_suplementos.f_permite_suplementos(psseguro, pfecha, pcmotmov);

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;

         vpasexec := 6;

         IF pcmotmov IS NOT NULL THEN
            numerr := pk_suplementos.f_permite_este_suplemento(psseguro, pfecha, pcmotmov);

            IF numerr <> 0 THEN
               v_texto := f_axis_literales (numerr, f_idiomauser);
               v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
               RAISE error_fin_supl;
            END IF;
         END IF;

         vpasexec := 7;
         numerr := pk_suplementos.f_inicializar_suplemento(psseguro, 'SUPLEMENTO', pfecha,
                                                           'BBDD', '*', pcmotmov,
                                                           v_est_sseguro, v_nmovimi);

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;
      END IF;

      --Actualizamos el creteni de las EST por si estubiese retenida.
--      UPDATE estseguros
--         SET creteni = 0
--       WHERE sseguro = v_est_sseguro;

      ---------------------------------- CAMBIO ------------------------------
      UPDATE estgaranseg
         -- 9.0 - 0025611#c155551 - En pruebas internas de cargas de ARL ... - Inicio
         --SET icapital = pibruto
      SET icapital = pibruto,
          iprianu = pibruto,
          ipritot = pibruto
       -- 9.0 - 0025611#c155551 - En pruebas internas de cargas de ARL ... - Final
      WHERE  sseguro = v_est_sseguro
         AND nriesgo = pnriesgo
         AND cgarant = pcgarant;

/* -- Comentado

      IF vicapital_new > 0 THEN
         UPDATE estgaranseg
            SET icapital = vicapital_new
          WHERE sseguro = v_est_sseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant;
      ELSE   -- si se ha agotado el capital, damos de baja la garantia
         DELETE      estgaranseg
               WHERE sseguro = v_est_sseguro
                 AND nriesgo = pnriesgo
                 AND cgarant = pcgarant;

         ---- Damos de baja las garantías dependientes ----
         FOR gar IN (SELECT *
                       FROM garanpro
                      WHERE cgardep = pcgarant
                        AND sproduc = v_sproduc
                        AND cactivi = pac_seguros.ff_get_actividad(v_est_sseguro, pnriesgo,
                                                                   'EST')) LOOP
            DELETE      estgaranseg
                  WHERE sseguro = v_est_sseguro
                    AND nriesgo = pnriesgo
                    AND cgarant = gar.cgarant;
         END LOOP;
      END IF;
      */
      vpasexec := 8;
--      IF pnriesgo IS NULL THEN
--         FOR regs3 IN (SELECT r.nriesgo
--                         FROM estriesgos r, estseguros s
--                        WHERE r.sseguro = s.sseguro
--                          AND NVL(r.fanulac, pfecha + 1) > pfecha
--                          AND s.sseguro = v_est_sseguro) LOOP
--            numerr :=
--               pac_tarifas.f_tarifar_riesgo_tot('EST', v_est_sseguro, regs3.nriesgo,
--                                                v_nmovimi,
--                                                pac_monedas.f_moneda_producto(v_sproduc),
--                                                pfecha);

      --            IF numerr <> 0 THEN
--               v_texto := f_axis_literales (numerr, f_idiomauser);
--               v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
--               RAISE error_fin_supl;
--            END IF;
--         END LOOP;
--      ELSE
--         numerr := pac_tarifas.f_tarifar_riesgo_tot('EST', v_est_sseguro, pnriesgo, v_nmovimi,
--                                                    pac_monedas.f_moneda_producto(v_sproduc),
--                                                    pfecha);

      --         IF numerr <> 0 THEN
--            v_texto := f_axis_literales (numerr, f_idiomauser);
--            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
--            RAISE error_fin_supl;
--         END IF;
--      END IF;

      -----------------------------------------------------------------------
      vpasexec := 9;
      numerr := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                 'BBDD', 'SUPLEMENTO', vcidioma, pcmotmov);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      vpasexec := 10;

      BEGIN
         -- se ha de validar que haya registros
         SELECT COUNT(*)
           INTO vcont
           FROM estdetmovseguro
          WHERE sseguro = v_est_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RAISE error_fin_supl;
      END;

      IF vcont = 0 THEN   -- No hay canbios
         RAISE warn_fin_supl;
      END IF;

      vpasexec := 11;
      numerr := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      UPDATE movseguro
         SET cmotmov = pcmotmov
       WHERE sseguro = psseguro
         AND nmovimi = v_nmovimi;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
      vpasexec := 12;
      numerr := pac_prod_comu.f_emite_propuesta(psseguro, onpoliza, oncertif, onrecibo,
                                                onsolici);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (151237, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      -- 0025611: (POSDE100)-Desarrollo-GAPS Administracion-Id 1 - Manejo de pagos de ARP - Inicio
      /*
      BEGIN
         SELECT nrecibo
           INTO pnrecibo
           FROM recibos
          WHERE sseguro = psseguro
            AND nmovimi = v_nmovimi;
      EXCEPTION
         WHEN OTHERS THEN
            v_texto := f_axis_literales (102367, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
      END;
      */
      -- 0025611: (POSDE100)-Desarrollo-GAPS Administracion-Id 1 - Manejo de pagos de ARP - Final
      v_est_sseguro := NULL;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobject, 0, vparam, 'error parametros');
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN numerr;
      WHEN warn_fin_supl THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_suplemento_factuacion', vpasexec,
                     numerr || ' Warning: ' || f_axis_literales(numerr, f_idiomauser), vparam);
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         -- 9.0 - 0025611#c155551 - En pruebas internas de cargas de ARL ... - Inicial
         -- RETURN 0;
         RETURN numerr;
      -- 9.0 - 0025611#c155551 - En pruebas internas de cargas de ARL ... - Final
      WHEN error_fin_supl THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_suplemento_factuacion', vpasexec,
                     f_axis_literales(numerr, f_idiomauser) || ' ' || vparam, numerr);
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN numerr;
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_suplemento_factuacion', vpasexec,
                     f_axis_literales(numerr, f_idiomauser) || ' ' || vparam, SQLERRM);
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN numerr;
   END f_suplemento_factuacion;

--Fin Bug 0021686 - JRH - 10/07/2013

   --Bug 0026472/165729 - NSS - 11/02/2014 -
   FUNCTION f_baja_asegurado(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pssegpol IN NUMBER,
      pcnotibaja IN NUMBER DEFAULT NULL,
      pcmotmov IN NUMBER DEFAULT NULL,
      psproces IN NUMBER)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'psseguro= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pfecha= ' || pfecha
            || ' pssegpol= ' || pssegpol || ' pcnotibaja= ' || pcnotibaja || ' pcmotmov= '
            || pcmotmov || ' psproces= ' || psproces;
      vobject        VARCHAR2(200) := 'PAC_MD_SUP_GENERICO.f_supl_generico';
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      salida         EXCEPTION;
      error_fin_supl EXCEPTION;
      warn_fin_supl  EXCEPTION;
      onpoliza       NUMBER;
      osseguro       NUMBER;
      oncertif       NUMBER;
      onrecibo       NUMBER;
      onsolici       NUMBER;
      v_cforpag      NUMBER;
      v_sperson      NUMBER;
      vcont          NUMBER;
      vcempres       NUMBER;
      vnpoliza       NUMBER;
      vncertif       NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vcidioma       NUMBER;
      v_texto        VARCHAR2(200);
      v_sproces      NUMBER;
      v_nnumlin      NUMBER := NULL;
      v_err          NUMBER;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pfecha IS NULL THEN
         RAISE e_param_error;
      END IF;

-- bug20620:ASN:20/12/2011 ini
/*
      -- Si no viene informacio SPROCES creamos uno
      IF psproces IS NULL THEN
         numerr := f_procesini(getuser, 1, 'SUPL_AUT:' || TO_CHAR(f_sysdate, 'yyyymmdd'),
                               f_axis_literales(805824, f_idiomauser), v_sproces);
      ELSE
         v_sproces := psproces;
      END IF;
*/
-- bug20620:ASN:20/12/2011 fin
--------------------------------------------------------------------------
-- Validar el importe de la prima (si pprima <> 0)
--------------------------------------------------------------------------
      vpasexec := 2;

      SELECT cempres, npoliza, ncertif, cramo, cmodali, ctipseg, ccolect, sproduc,
             cforpag, cactivi, cidioma
        INTO vcempres, vnpoliza, vncertif, vcramo, vcmodali, vctipseg, vccolect, v_sproduc,
             v_cforpag, v_cactivi, vcidioma
        FROM seguros
       WHERE sseguro = psseguro;

-- bug20620:ASN:20/12/2011 ini
      vpasexec := 200;

      -- Si no viene informacio SPROCES creamos uno
      IF psproces IS NULL THEN
         numerr := f_procesini(getuser, vcempres,
                               'SUP_BAJA_ASE' || TO_CHAR(f_sysdate, 'yyyymmdd'),   --bug 29353/174334:NSS;08/05/2014
                               f_axis_literales(805824, f_idiomauser), v_sproces);
      ELSE
         v_sproces := psproces;
      END IF;

-- bug20620:ASN:20/12/2011 fin
      vpasexec := 3;

      SELECT sperson
        INTO v_sperson
        FROM asegurados
       WHERE sseguro = psseguro
         AND norden = 1;

      vpasexec := 4;

-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
-- Todas las funciones a partir de esta deben tener RAISE error_fin_supl
      IF v_est_sseguro IS NULL THEN   --Si ya tenemos el suplemento en las EST no lo creamos de nuevo
         vpasexec := 5;
         --BUG11376-XVM-13102009
         numerr := pk_suplementos.f_permite_suplementos(psseguro, pfecha, pcmotmov);

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;

         vpasexec := 6;

         IF pcmotmov IS NOT NULL THEN
            numerr := pk_suplementos.f_permite_este_suplemento(psseguro, pfecha, pcmotmov);

            IF numerr <> 0 THEN
               v_texto := f_axis_literales (numerr, f_idiomauser);
               v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
               RAISE error_fin_supl;
            END IF;
         END IF;

         vpasexec := 7;
         numerr := pk_suplementos.f_inicializar_suplemento(psseguro, 'SUPLEMENTO', pfecha,
                                                           'BBDD', '*', pcmotmov,
                                                           v_est_sseguro, v_nmovimi);

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;
      END IF;

---------------------------------- CAMBIO ------------------------------
      vpasexec := 8;
      numerr := pk_suplementos.f_anular_riesgo(v_est_sseguro, pnriesgo, pfecha, v_nmovimi,
                                               pssegpol, pcnotibaja, pcmotmov);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

------------------------------------------------------------------------
      vpasexec := 9;
      --
      --Bug 0021686 - JRH - 15/03/2012 - 0021686: MdP - MIG - Viabilidad tarificación productos de migración Se añade el moivo como parámetro
      numerr := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                 'BBDD', 'SUPLEMENTO', vcidioma, pcmotmov);

      --Fi Bug 0021686 - JRH - 15/03/2012
      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      vpasexec := 10;

      BEGIN
         -- s'ha de validar que hi hagin registres
         SELECT COUNT(*)
           INTO vcont
           FROM estdetmovseguro
          WHERE sseguro = v_est_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RAISE error_fin_supl;
      END;

      IF vcont = 0 THEN   -- No hi hagut canvis
         --RAISE error_fin_supl;
         RAISE warn_fin_supl;
      END IF;

      -- Es grava el suplement a las taules reals
      vpasexec := 11;
      numerr := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
      vpasexec := 12;

      --bug 26472/0169132:NSS;11/03/2014
      IF pac_seguros.f_es_col_admin(psseguro, 'POL') = 0 THEN
         numerr := pac_prod_comu.f_emite_propuesta(psseguro, onpoliza, oncertif, onrecibo,
                                                   onsolici);

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (151237, f_idiomauser);
            v_err := f_procesfin(v_sproces, numerr);   --bug 29353/174334:NSS;08/05/2014
            RAISE error_fin_supl;
         END IF;
      END IF;

      --fin bug 26472/0169132:NSS;11/03/2014
      v_est_sseguro := NULL;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 1;
      WHEN warn_fin_supl THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_DIFERIDOS.f_baja_asegurado', vpasexec,
                     'Warning: ' || f_axis_literales(numerr, f_idiomauser), numerr);
         numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 0;
      WHEN error_fin_supl THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_baja_asegurado', vpasexec,
                     'Warning: ' || f_axis_literales(numerr, f_idiomauser), numerr);
         numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_baja_asegurado', vpasexec,
                     f_axis_literales(numerr, f_idiomauser), SQLERRM);
         numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 1;
   END f_baja_asegurado;

--Fin Bug 0026472/165729 - NSS - 11/02/2014 -
--Bug 29943/0166559 -ETM- 18/02/2014--INI
   FUNCTION f_suplemento_pu(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pcmotmov IN NUMBER,
      pcgarant IN NUMBER,
      pibruto IN NUMBER,
      pdetalle IN BOOLEAN,
      pnmovimi OUT NUMBER,
      psproces IN NUMBER)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(900)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' fecha= ' || pfecha
            || ' pcmotmov= ' || pcmotmov || ' pcgarant= ' || pcgarant || ' pibruto= '
            || pibruto || ' psproces= ' || psproces;
      vobject        VARCHAR2(200) := 'PAC_SUP_GENERAL.f_suplemento_pu';
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      salida         EXCEPTION;
      error_fin_supl EXCEPTION;
      warn_fin_supl  EXCEPTION;
      onpoliza       NUMBER;
      osseguro       NUMBER;
      oncertif       NUMBER;
      onrecibo       NUMBER;
      onsolici       NUMBER;
      v_cforpag      NUMBER;
      v_sperson      NUMBER;
      vcont          NUMBER;
      vcempres       NUMBER;
      vnpoliza       NUMBER;
      vncertif       NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vcidioma       NUMBER;
      v_texto        VARCHAR2(200);
      v_sproces      NUMBER;
      v_nnumlin      NUMBER := NULL;
      v_err          NUMBER;
      vicapital_new  NUMBER;
      v_cgarant      garanpro.cgarant%TYPE;
      v_norden       garanpro.norden%TYPE;
      v_ctarifa      garanpro.ctarifa%TYPE;
      v_cformul      garanpro.cformul%TYPE;
      v_tipo         NUMBER;
      v_max_ndetgar  NUMBER := 0;
      v_crevali      garanseg.crevali%TYPE;
      v_prevali      garanseg.prevali%TYPE;
      v_clave        garanformula.clave%TYPE;
      v_ccampo       garanformula.ccampo%TYPE;
      v_importe      NUMBER;
      v_regdet0      detgaranseg%ROWTYPE;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pfecha IS NULL
         OR pcgarant IS NULL
         OR pibruto IS NULL THEN
         RAISE e_param_error;
      END IF;

--------------------------------------------------------------------------
-- Validar el importe de la prima (si pprima <> 0)
--------------------------------------------------------------------------
      vpasexec := 2;

      SELECT cempres, npoliza, ncertif, cramo, cmodali, ctipseg, ccolect, sproduc,
             cforpag, cactivi, cidioma
        INTO vcempres, vnpoliza, vncertif, vcramo, vcmodali, vctipseg, vccolect, v_sproduc,
             v_cforpag, v_cactivi, vcidioma
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 200;

      -- Si no viene informacio SPROCES creamos uno
      IF psproces IS NULL THEN
         numerr := f_procesini(getuser, vcempres,
                               'SUPL_AUT:' || TO_CHAR(f_sysdate, 'yyyymmdd'),
                               f_axis_literales(805824, f_idiomauser), v_sproces);
      ELSE
         v_sproces := psproces;
      END IF;

      vpasexec := 3;
      vpasexec := 4;

-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
      IF v_est_sseguro IS NULL THEN   --Si ya tenemos el suplemento en las EST no lo creamos de nuevo
         vpasexec := 5;
         numerr := pk_suplementos.f_permite_suplementos(psseguro, pfecha, pcmotmov);

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;

         vpasexec := 6;

         IF pcmotmov IS NOT NULL THEN
            numerr := pk_suplementos.f_permite_este_suplemento(psseguro, pfecha, pcmotmov);

            IF numerr <> 0 THEN
               v_texto := f_axis_literales (numerr, f_idiomauser);
               v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
               RAISE error_fin_supl;
            END IF;
         END IF;

         vpasexec := 7;
         numerr := pk_suplementos.f_inicializar_suplemento(psseguro, 'SUPLEMENTO', pfecha,
                                                           'BBDD', '*', pcmotmov,
                                                           v_est_sseguro, v_nmovimi);

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;

         pnmovimi := v_nmovimi;
      END IF;

---------------------------------- CAMBIO ------------------------------

      --Participació en beneficis o promoció
      BEGIN
         SELECT g.cgarant, g.norden, g.ctarifa, g.cformul
           -- f_pargaranpro_v(g.cramo, g.cmodali, g.ctipseg, g.ccolect, g.cactivi, g.cgarant,
                        --   'TIPO')
         INTO   v_cgarant, v_norden, v_ctarifa, v_cformul
           FROM garanpro g, seguros s
          WHERE g.sproduc = s.sproduc
            AND g.cramo = s.cramo
            AND g.cmodali = s.cmodali
            AND g.ctipseg = s.ctipseg
            AND g.ccolect = s.ccolect
            AND g.cactivi = s.cactivi
            AND g.cgarant = 290   --JRH Ahora escogemos la garantÃa
            AND f_pargaranpro_v(g.cramo, g.cmodali, g.ctipseg, g.ccolect, g.cactivi, g.cgarant,
                                'TIPO') = 12
            AND s.sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            numerr := 1000607;
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
      END;

      BEGIN
         SELECT crevali, prevali
           INTO v_crevali, v_prevali
           FROM garanseg
          WHERE cgarant = v_cgarant
            AND sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM garanseg
                            WHERE cgarant = v_cgarant
                              AND sseguro = psseguro
                              AND nriesgo = pnriesgo);
      EXCEPTION
         WHEN OTHERS THEN
            v_crevali := 0;
            v_prevali := NULL;
      END;

      vpasexec := 8;

-------------------------------------------------------------------------------------------
-- Se registra la aportaciÃ³n extraordinaria en las tablas EST
-------------------------------------------------------------------------------------------
      BEGIN
         --  dbms_output.put_line('1:'||1);
         INSERT INTO estgaranseg
                     (cgarant, sseguro, nriesgo, finiefe, norden, crevali,
                      ctarifa, icapital, precarg, iprianu, iextrap, ffinefe, cformul,
                      ctipfra, ifranqu, irecarg, ipritar, pdtocom, idtocom, prevali, irevali,
                      itarifa, nmovimi, itarrea, ipritot, icaptot, nmovima, cobliga)
              VALUES (v_cgarant, v_est_sseguro, pnriesgo, TRUNC(pfecha), v_norden, v_crevali,
                      v_ctarifa, pibruto, NULL, 0, NULL, TRUNC(pfecha), v_cformul,
                      NULL, NULL, 0, 0, NULL, 0, v_prevali, NULL,
                      NULL, v_nmovimi, NULL, 0, pibruto, v_nmovimi, 1);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            vpasexec := 9;

            BEGIN
               UPDATE estgaranseg
                  SET icapital = pibruto,
                      icaptot = pibruto,
                      nmovima = v_nmovimi,
                      cobliga = 1
                WHERE cgarant = v_cgarant
                  AND nriesgo = pnriesgo
                  AND nmovimi = v_nmovimi
                  AND sseguro = v_est_sseguro
                  AND finiefe = TRUNC(pfecha);
            EXCEPTION
               WHEN OTHERS THEN
                  v_texto := f_axis_literales (101959, f_idiomauser);   --axis_literales
                  v_err := f_proceslin(v_sproces, v_texto || v_est_sseguro, v_est_sseguro,
                                       v_nnumlin);
                  RAISE error_fin_supl;
            END;
         WHEN OTHERS THEN
            v_texto := f_axis_literales (101959, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto || v_est_sseguro, v_est_sseguro,
                                 v_nnumlin);
            RAISE error_fin_supl;
      END;

      vpasexec := 10;

      IF pdetalle = TRUE THEN
         SELECT NVL(MAX(ndetgar), 0) + 1
           INTO v_max_ndetgar
           FROM estdetgaranseg
          WHERE cgarant = pcgarant
            AND nriesgo = pnriesgo
            AND nmovimi = v_nmovimi
            AND sseguro = v_est_sseguro;

         INSERT INTO estdetgaranseg
                     (cgarant, nriesgo, nmovimi, sseguro, finiefe,
                      ndetgar, icapital, crevali, prevali, fefecto, iprianu)
              VALUES (pcgarant, pnriesgo, v_nmovimi, v_est_sseguro, TRUNC(pfecha),
                      v_max_ndetgar, pibruto, v_crevali, v_prevali, pfecha, pibruto);

         --  detgaranseg para la garantía pcgarant con capital igual a ibruto.
         FOR reg IN (SELECT *
                       FROM garanseg g
                      WHERE g.cgarant <> pcgarant
                        AND g.sseguro = psseguro
                        AND g.nriesgo = pnriesgo
                        AND g.nmovimi = (SELECT MAX(g2.nmovimi)
                                           FROM garanseg g2
                                          WHERE g2.cgarant = g.cgarant
                                            AND g2.sseguro = g.sseguro
                                            AND g2.nriesgo = g.nriesgo)) LOOP
            INSERT INTO estdetgaranseg   --Insertamos detalle del resto de garantías a 0
                        (cgarant, nriesgo, nmovimi, sseguro, finiefe,
                         ndetgar, icapital, crevali, prevali, fefecto, iprianu)
                 VALUES (reg.cgarant, pnriesgo, v_nmovimi, v_est_sseguro, TRUNC(pfecha),
                         v_max_ndetgar, 0, 0, 0, pfecha, 0);
         END LOOP;
      END IF;

-----------------------------------------------------------------------
      -- Bug 29943 - 03/04/2014 - JTT: Tarificar suplementos de PU
      IF pdetalle = TRUE THEN
         vpasexec := 101;

         -- Determinamos la clave de la formula a usar
         SELECT gf.clave, gf.ccampo
           INTO v_clave, v_ccampo
           FROM garanformula gf, codcampo cd
          WHERE gf.cgarant = pcgarant
            AND gf.cramo = vcramo
            AND gf.cmodali = vcmodali
            AND gf.ctipseg = vctipseg
            AND gf.ccolect = vccolect
            AND gf.cactivi = v_cactivi
            AND cd.ccampo = gf.ccampo
            AND cd.cutili = 8
            AND cd.ccampo = 'CPTALPU'
         UNION
         SELECT gf.clave, gf.ccampo
           FROM garanformula gf, codcampo cd
          WHERE gf.cgarant = pcgarant
            AND gf.cramo = vcramo
            AND gf.cmodali = vcmodali
            AND gf.ctipseg = vctipseg
            AND gf.ccolect = vccolect
            AND gf.cactivi = 0
            AND cd.ccampo = gf.ccampo
            AND cd.cutili = 8
            AND cd.ccampo = 'CPTALPU'
            AND NOT EXISTS(SELECT gf.clave, gf.ccampo
                             FROM garanformula gf, codcampo cd
                            WHERE gf.cgarant = pcgarant
                              AND gf.cramo = vcramo
                              AND gf.cmodali = vcmodali
                              AND gf.ctipseg = vctipseg
                              AND gf.ccolect = vccolect
                              AND gf.cactivi = v_cactivi
                              AND cd.ccampo = gf.ccampo
                              AND cd.cutili = 8
                              AND cd.ccampo = 'CPTALPU');

         -- Calculamos el importe (v_importe)
         vpasexec := 102;
         numerr := pac_calculo_formulas.calc_formul(pfecha, v_sproduc, v_cactivi, pcgarant,
                                                    pnriesgo, v_est_sseguro, v_clave,
                                                    v_importe, v_nmovimi, NULL, 1, pfecha, 'R',
                                                    v_max_ndetgar);

         IF numerr <> 0 THEN
            v_texto := f_axis_literales (numerr, f_idiomauser);
            v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            RAISE error_fin_supl;
         END IF;

         -- Actualizamos el importe en e registro que acabamos de insertar en la tabla ESTDETGARANSEG
         vpasexec := 103;

         UPDATE estdetgaranseg
            SET icapital = v_importe
          WHERE sseguro = v_est_sseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = v_nmovimi
            AND finiefe = TRUNC(pfecha)
            AND ndetgar = v_max_ndetgar;

         -- INI 25/05/2016 RLLF BUG-38606 0038606: POSES100-POSACT SUPLEMENTO DE BENEFICIO-MAYOR VALOR ASEGURADO
         IF (pac_parametros.f_parproducto_n(v_sproduc, 'PU_INVPRIMACAPITAL')=1) THEN
          UPDATE estdetgaranseg
            SET icapital = iprianu
          WHERE sseguro = v_est_sseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = v_nmovimi
            AND finiefe = TRUNC(pfecha)
            AND ndetgar = v_max_ndetgar;

          UPDATE estdetgaranseg
            SET iprianu = v_importe
          WHERE sseguro = v_est_sseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = v_nmovimi
            AND finiefe = TRUNC(pfecha)
            AND ndetgar = v_max_ndetgar;
         END IF;
         -- FIN 25/05/2016 RLLF BUG-38606 0038606: POSES100-POSACT SUPLEMENTO DE BENEFICIO-MAYOR VALOR ASEGURADO

         -- Actualizamos el regitro que acabamos de insertar en ESTDETGARANSEG
         -- con los campos crevali, prevali, fvencim, ndurcob, pinttec, precarg,
         -- irecarg,ffincob,pdtocom,idtocom,itarrea,cagente,cunica
         -- corresondientes al detalle 0 (ndetgar = 0)
         vpasexec := 104;

         SELECT *
           INTO v_regdet0
           FROM estdetgaranseg
          WHERE sseguro = v_est_sseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = v_nmovimi
            AND finiefe = TRUNC(pfecha)
            AND ndetgar = 0;

         UPDATE estdetgaranseg
            SET crevali = v_regdet0.crevali,
                prevali = v_regdet0.prevali,
                fvencim = v_regdet0.fvencim,
                ndurcob = v_regdet0.ndurcob,
                pinttec = v_regdet0.pinttec,
                precarg = v_regdet0.precarg,
                irecarg = v_regdet0.irecarg,
                ffincob = v_regdet0.ffincob,
                pdtocom = v_regdet0.pdtocom,
                idtocom = v_regdet0.idtocom,
                itarrea = v_regdet0.itarrea,
                cagente = v_regdet0.cagente,
                cunica = v_regdet0.cunica
          WHERE sseguro = v_est_sseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = v_nmovimi
            AND finiefe = TRUNC(pfecha)
            AND ndetgar = v_max_ndetgar;
      END IF;

      -- Fi bug 29943

      -----------------------------------------------------------------------
      vpasexec := 11;
      numerr := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                 'BBDD', 'SUPLEMENTO', vcidioma, pcmotmov);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      vpasexec := 12;

      BEGIN
         -- se ha de validar que haya registros
         SELECT COUNT(*)
           INTO vcont
           FROM estdetmovseguro
          WHERE sseguro = v_est_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RAISE error_fin_supl;
      END;

      IF vcont = 0 THEN   -- No hay canbios
         RAISE warn_fin_supl;
      END IF;

      vpasexec := 13;
      numerr := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (numerr, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      UPDATE movseguro
         SET cmotmov = pcmotmov
       WHERE sseguro = psseguro
         AND nmovimi = v_nmovimi;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
      vpasexec := 14;
      numerr := pac_prod_comu.f_emite_propuesta(psseguro, onpoliza, oncertif, onrecibo,
                                                onsolici);

      IF numerr <> 0 THEN
         v_texto := f_axis_literales (151237, f_idiomauser);
         v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         RAISE error_fin_supl;
      END IF;

      v_est_sseguro := NULL;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobject, 0, vparam, 'error parametros');
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN numerr;
      WHEN warn_fin_supl THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_suplemento_pu', vpasexec,
                     numerr || ' Warning: ' || f_axis_literales(numerr, f_idiomauser), vparam);
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN numerr;
      WHEN error_fin_supl THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_suplemento_pu', vpasexec,
                     f_axis_literales(numerr, f_idiomauser) || ' ' || vparam, numerr);
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN numerr;
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_suplemento_pu', vpasexec,
                     f_axis_literales(numerr, f_idiomauser) || ' ' || vparam, SQLERRM);
         v_err := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN numerr;
   END f_suplemento_pu;

--FIN -29943/0166559 -ETM- 18/02/2014--
   /*
      Inserta un registro en la tabla de garantias excluidas EXCLUGARSEG

      param IN psseguro : Seguro
      param IN pnriesgo : Numero de riesgo
      param IN pcgarant . Codigo de garantia
      param IN pnmovimi : Movimiento en que se realiza el movimiento de baja
      param IN pnmovima : Movimiento de alta de la garantia

   */
   FUNCTION f_marcar_excluir_garantia(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vobject        VARCHAR2(200) := 'PAC_SUP_GENERAL.f_marcar_excluir_garantia';
      vparam         VARCHAR2(900)
         := 'sseguro= ' || psseguro || ' nriesgo= ' || pnriesgo || ' cgarant= ' || pcgarant
            || ' nmovimi= ' || pnmovimi;
      v_sproduc      seguros.sproduc%TYPE;
      v_cactivi      seguros.cactivi%TYPE;
   BEGIN
      INSERT INTO exclugarseg
                  (sseguro, nriesgo, cgarant, nmovima, nmovimb)
           VALUES (psseguro, pnriesgo, pcgarant, pnmovimi, NULL);

      vpasexec := 2;

      SELECT sproduc, cactivi
        INTO v_sproduc, v_cactivi
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 3;

      -- Tambien marcamos las garantias dependientes en la tabla EXCLUGARSEG
      FOR gar IN (SELECT *
                    FROM garanpro
                   WHERE cgardep = pcgarant
                     AND sproduc = v_sproduc
                     AND cactivi = v_cactivi) LOOP
         vpasexec := 4;

         INSERT INTO exclugarseg
                     (sseguro, nriesgo, cgarant, nmovima, nmovimb)
              VALUES (psseguro, pnriesgo, gar.cgarant, pnmovimi, NULL);
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 9906845;   -- Error al insertar en EXCLUGARSEG
   END f_marcar_excluir_garantia;

   FUNCTION f_borrar_garantia(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      v_pasexec      NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'psseguro= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pcgarant= ' || pcgarant
            || ' pnmovimi= ' || pnmovimi;
      vobject        VARCHAR2(200) := 'PAC_MD_SUP_GENERICO.f_borrar_garantia';
   BEGIN
      v_pasexec := 18;

      DELETE FROM estgaransegcom
            WHERE sseguro = psseguro
              AND nriesgo = pnriesgo
              AND cgarant = pcgarant
              AND nmovimi = pnmovimi;

      v_pasexec := 19;

      DELETE FROM estgaranseggas
            WHERE sseguro = psseguro
              AND nriesgo = pnriesgo
              AND cgarant = pcgarant
              AND nmovimi = pnmovimi;

      v_pasexec := 20;

      DELETE FROM estgaranseg_sbpri
            WHERE sseguro = psseguro
              AND nriesgo = pnriesgo
              AND cgarant = pcgarant
              AND nmovimi = pnmovimi;

      v_pasexec := 21;

      DELETE FROM estpregungaranseg
            WHERE sseguro = psseguro
              AND nriesgo = pnriesgo
              AND cgarant = pcgarant
              AND nmovimi = pnmovimi;

      DELETE FROM estpregungaransegtab
            WHERE sseguro = psseguro
              AND nriesgo = pnriesgo
              AND cgarant = pcgarant
              AND nmovimi = pnmovimi;

      v_pasexec := 22;

      DELETE FROM estresulseg
            WHERE sseguro = psseguro
              AND nriesgo = pnriesgo
              AND cgarant = pcgarant
              AND nmovimi = pnmovimi;

      v_pasexec := 23;

      -- Bug 10757 - RSC - 21/07/2009 - APR - Grabar en la tabla DETGARANSEG en los productos de Nueva Emisión
      DELETE FROM estdetgaranseg
            WHERE sseguro = psseguro
              AND nriesgo = pnriesgo
              AND cgarant = pcgarant
              AND nmovimi = pnmovimi;

      v_pasexec := 24;

      -- Fin Bug 10757

      -- Bug 21121 - APD - 21/02/2012 - borrar la tabla estdetprimas antes de borrar en la tabla estgaranseg
      DELETE FROM estdetprimas
            WHERE sseguro = psseguro
              AND nriesgo = pnriesgo
              AND cgarant = pcgarant
              AND nmovimi = pnmovimi;

      -- Fin Bug 21121
      v_pasexec := 25;

      -- Bug 27014 - SHA - 29/07/2013
      DELETE FROM estprimasgaranseg
            WHERE sseguro = psseguro
              AND nriesgo = pnriesgo
              AND cgarant = pcgarant
              AND nmovimi = pnmovimi;

      -- Fin Bug 27014
      v_pasexec := 26;

      --CONVENIOS
      DELETE FROM esttramosregul
            WHERE sseguro = psseguro
              AND nriesgo = pnriesgo
              AND cgarant = pcgarant
              AND nmovimi = pnmovimi;

      --CONVENIOS
      v_pasexec := 27;

      DELETE FROM estgaranseg
            WHERE sseguro = psseguro
              AND nriesgo = pnriesgo
              AND cgarant = pcgarant
              AND nmovimi = pnmovimi;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_borrar_garantia', v_pasexec,
                     f_axis_literales(180194, f_idiomauser), vparam || SQLERRM);
         RETURN 180194;
   END f_borrar_garantia;

   FUNCTION f_alta_garantia(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      pfecha IN DATE,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      picapital IN NUMBER,
      pnorden IN NUMBER,
      pctarifa IN NUMBER,
      pcformul IN NUMBER,
      pprevali IN NUMBER,
      pcrevali IN NUMBER,
      pirevali IN NUMBER)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      v_pasexec      NUMBER(8) := 1;
      vparam         VARCHAR2(400)
         := 'psseguro= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pcgarant= ' || pcgarant
            || ' pnmovimi= ' || pnmovimi;
      vobject        VARCHAR2(200) := 'PAC_MD_SUP_GENERICO.f_alta_garantia';
      vtrespue       VARCHAR2(1000);
      vcrespue       VARCHAR2(1000);
   BEGIN
      v_pasexec := 18;

--  Damos de alta en estgaranseg la garantía.
      BEGIN
         INSERT INTO estgaranseg
                     (cgarant, sseguro, nriesgo, finiefe, norden, crevali,
                      ctarifa, icapital, precarg, iprianu, iextrap, ffinefe, cformul,
                      ctipfra, ifranqu, irecarg, ipritar, pdtocom, idtocom, prevali, irevali,
                      itarifa, nmovimi, itarrea, ipritot, icaptot, nmovima, cobliga)
              VALUES (pcgarant, psseguro, pnriesgo, TRUNC(pfecha), pnorden, pcrevali,
                      pctarifa, picapital, NULL, 0, NULL, TRUNC(pfecha), pcformul,
                      NULL, NULL, 0, 0, NULL, 0, pprevali, pirevali,
                      NULL, pnmovimi, NULL, 0, picapital, pnmovimi, 1);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN   --Si ya exsite el registro tan solo lo activamos
            UPDATE estgaranseg
               SET icapital = picapital,
                   icaptot = picapital,
                   cobliga = 1
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND cgarant = pcgarant
               AND nmovimi = pnmovimi;

            RETURN 0;
      END;

      v_pasexec := 19;

--JRH Damos de alta sus preguntas
      FOR preg IN (SELECT   sproduc, cactivi, cgarant, ppg.cpregun, cpretip, npreord, tprefor,
                            cpreobl, npreimp, cresdef, cofersn, ctabla, tvalfor, esccero,
                            visiblecol, visiblecert, cvisible, cmodo, cp.ctippre
                       FROM pregunprogaran ppg, codipregun cp
                      WHERE cp.cpregun = ppg.cpregun
                        AND ppg.sproduc = psproduc
                        AND ppg.cgarant = pcgarant
                        AND ppg.cactivi = pcactivi
                        AND ppg.visiblecol = 0
                        AND ppg.visiblecert = 1
                   UNION
                   SELECT   sproduc, cactivi, cgarant, ppg.cpregun, cpretip, npreord, tprefor,
                            cpreobl, npreimp, cresdef, cofersn, ctabla, tvalfor, esccero,
                            visiblecol, visiblecert, cvisible, cmodo, cp.ctippre
                       FROM pregunprogaran ppg, codipregun cp
                      WHERE cp.cpregun = ppg.cpregun
                        AND ppg.sproduc = psproduc
                        AND ppg.cgarant = pcgarant
                        AND ppg.cactivi = 0
                        AND ppg.visiblecol = 0
                        AND ppg.visiblecert = 1
                        AND NOT EXISTS(SELECT 1
                                         FROM pregunprogaran p
                                        WHERE p.sproduc = psproduc
                                          AND p.cgarant = pcgarant
                                          AND p.cactivi = pcactivi)
                   ORDER BY npreord) LOOP
         vtrespue := 'NULL';
         vcrespue := 'NULL';
         v_pasexec := 20;

         IF preg.cpretip = 1 THEN
            v_pasexec := 21;

            --Ponemos el valor por defecto en las preguntas manuales

            --Manual
            IF preg.ctippre NOT IN(4, 5, 7) THEN
               IF preg.cresdef IS NOT NULL THEN
                  vcrespue := TO_CHAR(preg.cresdef);
                  v_pasexec := 22;
               ELSE
                  v_pasexec := 23;
                  vcrespue := 'NULL';
               END IF;
            ELSE
               v_pasexec := 24;

               SELECT DECODE(preg.cresdef, NULL, 'NULL', CHR(39) || preg.cresdef || CHR(39))
                 INTO vtrespue
                 FROM DUAL;

               v_pasexec := 25;
            END IF;
         ELSIF(preg.cpretip = 3
               OR(preg.cpretip = 2
                  AND preg.esccero = 1)) THEN
            v_pasexec := 26;

--  Resolvemos, calculamos las automáticas y semi automáticas
                        --Semi-Automática
            IF preg.ctippre NOT IN(4, 5, 7) THEN
               v_pasexec := 27;
               vcrespue := pac_sup_diferidos.f_sup_dif_cal_pregar_semi(preg.tprefor, 'EST',
                                                                       psseguro, pnriesgo,
                                                                       pfecha, pnmovimi,
                                                                       pcgarant);
--                                                              NVL(TO_CHAR(preg.cresdef),
--                                                                  'NULL')); --JRH IMP
               v_pasexec := 28;
            ELSE
               v_pasexec := 29;
               vtrespue := pac_sup_diferidos.f_sup_dif_cal_pregar_semi(preg.tprefor, 'EST',
                                                                       psseguro, pnriesgo,
                                                                       pfecha, pnmovimi,
                                                                       pcgarant);
               --   TO_CHAR(preg.cresdef));
               v_pasexec := 30;
            END IF;
         END IF;

         v_pasexec := 31;

         -- Insertamos la pregunta con su valor encontrado.
         INSERT INTO estpregungaranseg
                     (sseguro, nriesgo, cgarant, nmovimi, cpregun, crespue,
                      nmovima, finiefe, trespue)
              VALUES (psseguro, pnriesgo, pcgarant, pnmovimi, preg.cpregun, vcrespue,
                      pnmovimi, pfecha, vtrespue);

         v_pasexec := 32;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_SUP_GENERAL.f_alta_garantia', v_pasexec,
                     f_axis_literales(9900939, f_idiomauser), vparam || SQLERRM);
         RETURN 9900939;
   END f_alta_garantia;

   --CONVENIOS
   FUNCTION f_cambio_verscon(
      psseguro IN NUMBER,
      pfecha IN DATE,
      pcmotmov IN NUMBER,
      pnmovimi OUT NUMBER,
      psproces IN NUMBER)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
              := 'psproduc= ' || psseguro || ' pcmotmov= ' || pcmotmov || ' fecha= ' || pfecha;
      vobject        VARCHAR2(200) := 'PAC_SUP_GENERICO.f_cambio_verscon';
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      salida         EXCEPTION;
      error_fin_supl EXCEPTION;
      warn_fin_supl  EXCEPTION;
      onpoliza       NUMBER;
      osseguro       NUMBER;
      oncertif       NUMBER;
      onrecibo       NUMBER;
      onsolici       NUMBER;
      v_cforpag      NUMBER;
      v_sperson      NUMBER;
      vcont          NUMBER;
      vcempres       NUMBER;
      vnpoliza       NUMBER;
      vncertif       NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vcidioma       NUMBER;
      v_texto        VARCHAR2(200);
      v_sproces      NUMBER;
      v_nnumlin      NUMBER := NULL;
      v_err          NUMBER;
      vfechavers     DATE;
      vidversion     NUMBER;
      lexiste        NUMBER;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL
         OR pfecha IS NULL
         OR pcmotmov IS NULL THEN
         RAISE e_param_error;
      END IF;

-- bug20620:ASN:20/12/2011 ini
/*
      -- Si no viene informacio SPROCES creamos uno
      IF psproces IS NULL THEN
         numerr := f_procesini(getuser, 1, 'SUPL_AUT:' || TO_CHAR(f_sysdate, 'yyyymmdd'),
                               f_axis_literales(805824, f_idiomauser), v_sproces);
      ELSE
         v_sproces := psproces;
      END IF;
*/
-- bug20620:ASN:20/12/2011 fin
--------------------------------------------------------------------------
-- Validar el importe de la prima (si pprima <> 0)
--------------------------------------------------------------------------
      vpasexec := 2;

      SELECT cempres, npoliza, ncertif, cramo, cmodali, ctipseg, ccolect, sproduc,
             cforpag, cactivi, cidioma
        INTO vcempres, vnpoliza, vncertif, vcramo, vcmodali, vctipseg, vccolect, v_sproduc,
             v_cforpag, v_cactivi, vcidioma
        FROM seguros
       WHERE sseguro = psseguro;

-- bug20620:ASN:20/12/2011 ini
      vpasexec := 200;

      -- Si no viene informacio SPROCES creamos uno
      IF psproces IS NULL THEN
         numerr := f_procesini(getuser, vcempres,
                               'SUPL_AUT:' || TO_CHAR(f_sysdate, 'yyyymmdd'),
                               f_axis_literales(805824, f_idiomauser), v_sproces);
      ELSE
         v_sproces := psproces;
      END IF;

-- bug20620:ASN:20/12/2011 fin
      vpasexec := 3;

      SELECT sperson
        INTO v_sperson
        FROM asegurados
       WHERE sseguro = psseguro
         AND norden = 1;

      vpasexec := 4;

-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
-- Todas las funciones a partir de esta deben tener RAISE error_fin_supl
      IF v_est_sseguro IS NULL THEN   --Si ya tenemos el suplemento en las EST no lo creamos de nuevo
         vpasexec := 5;
         --BUG11376-XVM-13102009
         numerr := pk_suplementos.f_permite_suplementos(psseguro, pfecha, pcmotmov);

         IF numerr <> 0 THEN
            -- BUG 0039481 - FAL - 0039481/0227245
            -- v_texto := f_axis_literales (numerr, f_idiomauser);
            -- v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            v_err := f_proceslin(v_sproces, f_axis_literales(numerr, f_idiomauser), psseguro, v_nnumlin);
            -- FI BUG 0039481 - FAL - 0039481/0227245
            RAISE error_fin_supl;
         END IF;

         vpasexec := 6;

         IF pcmotmov IS NOT NULL THEN
            numerr := pk_suplementos.f_permite_este_suplemento(psseguro, pfecha, pcmotmov);

            IF numerr <> 0 THEN
               -- BUG 0039481 - FAL - 0039481/0227245
               -- v_texto := f_axis_literales (numerr, f_idiomauser);
               -- v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
               v_err := f_proceslin(v_sproces, f_axis_literales(numerr, f_idiomauser), psseguro, v_nnumlin);
               -- FI BUG 0039481 - FAL - 0039481/0227245
               RAISE error_fin_supl;
            END IF;
         END IF;

         vpasexec := 7;
         numerr := pk_suplementos.f_inicializar_suplemento(psseguro, 'SUPLEMENTO', pfecha,
                                                           'BBDD', '*', pcmotmov,
                                                           v_est_sseguro, v_nmovimi);

         IF numerr <> 0 THEN
            -- BUG 0039481 - FAL - 0039481/0227245
            -- v_texto := f_axis_literales (numerr, f_idiomauser);
            -- v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            v_err := f_proceslin(v_sproces, f_axis_literales(numerr, f_idiomauser), psseguro, v_nnumlin);
            -- FI BUG 0039481 - FAL - 0039481/0227245
            RAISE error_fin_supl;
         END IF;
      END IF;

---------------------------------- CAMBIO ------------------------------
      vpasexec := 8;
      numerr := pk_suplementos.f_fversconv(psseguro, 'SEG', vfechavers, vidversion);

      IF numerr <> 0 THEN
            -- BUG 0039481 - FAL - 0039481/0227245
            -- v_texto := f_axis_literales (numerr, f_idiomauser);
            -- v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            v_err := f_proceslin(v_sproces, f_axis_literales(numerr, f_idiomauser), psseguro, v_nnumlin);
            -- FI BUG 0039481 - FAL - 0039481/0227245
         RAISE error_fin_supl;
      END IF;

      IF vidversion = pac_convenios_emp.f_ultverscnv_poliza(psseguro, 'SEG') THEN   --JRH Ya tiene la versión correcta
         RETURN 0;
      END IF;

      IF vidversion < pac_convenios_emp.f_ultverscnv_poliza(psseguro, 'SEG') THEN
         RETURN 0;
      END IF;

      vpasexec := 81;

      -- bug 0011645 El riesgo no debe estar anulado
      FOR regs3 IN (SELECT r.nriesgo
                      FROM estriesgos r, estseguros s
                     WHERE r.sseguro = s.sseguro
                       AND NVL(r.fanulac, pfecha + 1) > pfecha
                       AND s.sseguro = v_est_sseguro) LOOP
         vpasexec := 82;

         --MIramos garantías que están en la versión y están  no están en la póliza original
         FOR reggar IN (SELECT v.cgarant, v.icapital, v.cobligatoria, g.norden, g.ctarifa,
                               g.cformul, g.prevali, g.crevali, g.irevali, g.sproduc,
                               g.cactivi
                          FROM cnv_conv_emp_vers_gar v, seguros s, garanpro g
                         WHERE s.sseguro = psseguro
                           AND v.idversion = vidversion
                           AND v.cgarant = g.cgarant
                           AND v.cobligatoria = 1
                           AND s.sproduc = g.sproduc
                           AND s.cactivi = g.cactivi) LOOP
            BEGIN
               SELECT 1
                 INTO lexiste
                 FROM estgaranseg
                WHERE sseguro = v_est_sseguro
                  AND nmovimi = v_nmovimi
                  AND nriesgo = regs3.nriesgo
                  AND cgarant = reggar.cgarant
                  AND cobliga = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  lexiste := 0;
                  numerr := f_alta_garantia(v_est_sseguro, regs3.nriesgo, v_nmovimi,
                                            reggar.cgarant, pfecha, reggar.sproduc,
                                            reggar.cactivi, reggar.icapital, reggar.norden,
                                            reggar.ctarifa, reggar.cformul, reggar.prevali,
                                            reggar.crevali, reggar.irevali);

                  IF numerr <> 0 THEN
            -- BUG 0039481 - FAL - 0039481/0227245
            -- v_texto := f_axis_literales (numerr, f_idiomauser);
            -- v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            v_err := f_proceslin(v_sproces, f_axis_literales(numerr, f_idiomauser), psseguro, v_nnumlin);
            -- FI BUG 0039481 - FAL - 0039481/0227245

                     RAISE error_fin_supl;
                  END IF;
            END;

            --
            IF lexiste = 1 THEN
               UPDATE estgaranseg
                  SET icapital = reggar.icapital,
                      icaptot = reggar.icapital
                WHERE sseguro = v_est_sseguro
                  AND nriesgo = regs3.nriesgo
                  AND cgarant = reggar.cgarant
                  AND nmovimi = v_nmovimi;
            END IF;
         --
         END LOOP;

         --JRH Miramos las garantías de estgaranseg  que no están en la versión y las borramos (aunque incluso sean opcionales)
         FOR reggar2 IN (SELECT *
                           FROM estgaranseg est
                          WHERE est.sseguro = v_est_sseguro
                            AND est.nriesgo = regs3.nriesgo
                            AND est.cobliga = 1
                            AND est.nmovimi = v_nmovimi
                            AND NOT EXISTS(SELECT 1
                                             FROM cnv_conv_emp_vers_gar v
                                            WHERE v.idversion = vidversion
                                              AND v.cgarant = est.cgarant)) LOOP
            numerr := f_borrar_garantia(v_est_sseguro, regs3.nriesgo, v_nmovimi,
                                        reggar2.cgarant);

            IF numerr <> 0 THEN
            -- BUG 0039481 - FAL - 0039481/0227245
            -- v_texto := f_axis_literales (numerr, f_idiomauser);
            -- v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            v_err := f_proceslin(v_sproces, f_axis_literales(numerr, f_idiomauser), psseguro, v_nnumlin);
            -- FI BUG 0039481 - FAL - 0039481/0227245

               RAISE error_fin_supl;
            END IF;
         END LOOP;

         --tarificamos el riesgo
         numerr := pac_tarifas.f_tarifar_riesgo_tot('EST', v_est_sseguro, regs3.nriesgo,
                                                    v_nmovimi,

                                                    -- JLB - I - BUG 18423 COjo la moneda del producto
                                                                                           --        f_parinstalacion_n('MONEDAINST'),
                                                    pac_monedas.f_moneda_producto(v_sproduc),

-- JLB - F - BUG 18423 COjo la moneda del producto
                                                    pfecha);

         IF numerr <> 0 THEN
            -- BUG 0039481 - FAL - 0039481/0227245
            -- v_texto := f_axis_literales (numerr, f_idiomauser);
            -- v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            v_err := f_proceslin(v_sproces, f_axis_literales(numerr, f_idiomauser), psseguro, v_nnumlin);
            -- FI BUG 0039481 - FAL - 0039481/0227245
            RAISE error_fin_supl;
         END IF;
      END LOOP;

      UPDATE estcnv_conv_emp_seg
         SET idversion = vidversion
       WHERE sseguro = v_est_sseguro;

------------------------------------------------------------------------
      vpasexec := 9;
      --
      --Bug 0021686 - JRH - 15/03/2012 - 0021686: MdP - MIG - Viabilidad tarificación productos de migración Se añade el moivo como parámetro
      numerr := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                 'BBDD', 'SUPLEMENTO', vcidioma, pcmotmov);

      --Fi Bug 0021686 - JRH - 15/03/2012
      IF numerr <> 0 THEN
            -- BUG 0039481 - FAL - 0039481/0227245
            -- v_texto := f_axis_literales (numerr, f_idiomauser);
            -- v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            v_err := f_proceslin(v_sproces, f_axis_literales(numerr, f_idiomauser), psseguro, v_nnumlin);
            -- FI BUG 0039481 - FAL - 0039481/0227245
         RAISE error_fin_supl;
      END IF;

      vpasexec := 10;

      BEGIN
         -- s'ha de validar que hi hagin registres
         SELECT COUNT(*)
           INTO vcont
           FROM estdetmovseguro
          WHERE sseguro = v_est_sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RAISE error_fin_supl;
      END;

      IF vcont = 0 THEN   -- No hi hagut canvis
         --RAISE error_fin_supl;
         RAISE warn_fin_supl;
      END IF;

      -- Es grava el suplement a las taules reals
      vpasexec := 11;
      numerr := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);

      IF numerr <> 0 THEN
            -- BUG 0039481 - FAL - 0039481/0227245
            -- v_texto := f_axis_literales (numerr, f_idiomauser);
            -- v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            v_err := f_proceslin(v_sproces, f_axis_literales(numerr, f_idiomauser), psseguro, v_nnumlin);
            -- FI BUG 0039481 - FAL - 0039481/0227245
         RAISE error_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------

      --JRH NO hay tratamiento de ADMINISTRADOS PORQUE EN PRINCIPIO CONVENIOS NO PODRÁ SER ADMINISTRADO
      vpasexec := 12;
      numerr := pac_prod_comu.f_emite_propuesta(psseguro, onpoliza, oncertif, onrecibo,
                                                onsolici);

      IF numerr <> 0 THEN
            -- BUG 0039481 - FAL - 0039481/0227245
            -- v_texto := f_axis_literales (numerr, f_idiomauser);
            -- v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
            v_err := f_proceslin(v_sproces, f_axis_literales(numerr, f_idiomauser), psseguro, v_nnumlin);
            -- FI BUG 0039481 - FAL - 0039481/0227245
         RAISE error_fin_supl;
      END IF;

      v_est_sseguro := NULL;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 9000505;
      WHEN warn_fin_supl THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'Warning: ' || f_axis_literales(numerr, f_idiomauser), numerr);
         numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 0;
      WHEN error_fin_supl THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'Warning: ' || f_axis_literales(numerr, f_idiomauser), numerr);
         numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;

         SELECT DECODE(NVL(numerr, 0), 0, 1000455, numerr)
           INTO numerr
           FROM DUAL;

         RETURN numerr;
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     f_axis_literales(numerr, f_idiomauser), SQLERRM);
         numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;

         SELECT DECODE(NVL(numerr, 0), 0, 1000455, numerr)
           INTO numerr
           FROM DUAL;

         RETURN numerr;
   END f_cambio_verscon;
   -- --------------------------------------------------------------------------------------
   -- Suplemento de cambio de asegurados AUTOMATICO.
   -- Requisito: antes se haga (nmovimi - 1) un suplemento de regularización.
   --
   --                      0034462/208987. AFM
   --
   -- --------------------------------------------------------------------------------------
   FUNCTION f_cambio_aut_numaseg(psseguro IN NUMBER)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(400)
              := 'psproduc= ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_SUP_GENERICO.f_cambio_aut_numaseg';
      v_cempres      seguros.cempres%type;
      v_sproduc      seguros.sproduc%type;
      v_fcarpro      seguros.fcarpro%type;
      v_fcaranu      seguros.fcaranu%type;
      v_csituac      seguros.csituac%type;
      v_cidioma      NUMBER := f_idiomauser;
      v_paseg        pregunseg.crespue%type;
      v_ffecsup      movseguro.fefecto%type;
      v_cmotmov      movseguro.cmotmov%type := 685;
      v_nmov_ant     movseguro.nmovimi%type;
      --
      warn_fin_supl  EXCEPTION;
      onpoliza       NUMBER;
      oncertif       NUMBER;
      onrecibo       NUMBER;
      onsolici       NUMBER;
      vcont          NUMBER;
      --
      v_texto        VARCHAR2(200);
      v_sproces      NUMBER;
      v_nnumlin      NUMBER := NULL;
      v_hayerror     NUMBER := 0;
      v_err          NUMBER;
      --
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;
--------------------------------------------------------------------------
-- Buscamos la póliza
--------------------------------------------------------------------------
      -- Todas los controles a partir de este deben tener RAISE error_fin_supl
      vpasexec := 2;
      SELECT cempres, sproduc, fcarpro, fcaranu, csituac
        INTO v_cempres, v_sproduc, v_fcarpro, v_fcaranu, v_csituac
        FROM seguros
       WHERE sseguro = psseguro;


      vpasexec := 3;
      -- creamos un SPROCES
   --   numerr := f_procesini(getuser, v_cempres,'SUPL_AUT_REGUL',
   --                         f_axis_literales(805824, v_cidioma), v_sproces);
   -- Ini IAXIS-3631 -- ECP -- 10/05/2019
      IF v_csituac in (0,3) THEN
         -- La póliza no está en situación de hacer suplementos
         numerr := 104257;
         RAISE warn_fin_supl;
      END IF;
      -- Fin IAXIS-3631 -- ECP -- 10/05/2019
--------------------------------------------------------------------------
-- Buscamos que el movimiento anterior sea de regularización
--------------------------------------------------------------------------
      vpasexec := 4;
      BEGIN
        SELECT M.FEFECTO, M.NMOVIMI
          INTO v_ffecsup, v_nmov_ant
          FROM MOVSEGURO M
         WHERE M.sseguro = psseguro
           AND M.CMOVSEG = 6
           AND M.CMOTMOV = 601
           AND M.NMOVIMI = (SELECT MAX(NMOVIMI)
                              FROM MOVSEGURO
                             WHERE SSEGURO = M.SSEGURO
                               AND M.CMOTMOV=601
                               AND M.CMOVSEG=6);
      EXCEPTION
        WHEN OTHERS THEN
            -- No se ha encontrado suplemento de regularización.
            numerr := 9908262;
            RAISE warn_fin_supl;
      END;
--------------------------------------------------------------------------
-- El suplemento de regularización siempre coincide con la anualidad.
-- Validamos que a fecha de suplemento no se haya pasado la cartera
--      Si se ha pasado cartera no se hace este suplemento
--------------------------------------------------------------------------
      vpasexec := 5;
      IF v_ffecsup <> v_fcaranu THEN
         -- A la fecha de suplemento la cartera se ha ejecutado.
         numerr := 9908261;
         RAISE warn_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
      IF v_est_sseguro IS NULL THEN   --Si ya tenemos el suplemento en las EST no lo creamos de nuevo
         vpasexec := 6;

         numerr := pk_suplementos.f_permite_suplementos(psseguro, v_ffecsup, v_cmotmov);
         IF numerr <> 0 THEN
            RAISE warn_fin_supl;
         END IF;

         vpasexec := 7;

         IF v_cmotmov IS NOT NULL THEN
            numerr := pk_suplementos.f_permite_este_suplemento(psseguro, v_ffecsup, v_cmotmov);

            IF numerr <> 0 THEN
               RAISE warn_fin_supl;
            END IF;
         END IF;

         vpasexec := 8;
         numerr := pk_suplementos.f_inicializar_suplemento(psseguro, 'SUPLEMENTO', v_ffecsup,
                                                           'BBDD', '*', v_cmotmov,
                                                           v_est_sseguro, v_nmovimi);

         IF numerr <> 0 THEN
            RAISE warn_fin_supl;
         END IF;
      END IF;

---------------------------------- CAMBIO ------------------------------
      vpasexec := 9;


      -- El riesgo no debe estar anulado
      FOR regs3 IN (SELECT r.nriesgo
                      FROM estriesgos r, estseguros s
                     WHERE r.sseguro = s.sseguro
                       AND NVL(r.fanulac, v_ffecsup + 1) > v_ffecsup
                       AND s.sseguro = v_est_sseguro) LOOP
         vpasexec := 10;
         --
         -- Buscamos el promedio del suplemento de regularización anterior
         --
         BEGIN
           SELECT round(AVG(naseg),2)
             INTO v_paseg
             FROM ASEGURADOSMES
            WHERE sseguro = psseguro
              AND nriesgo = regs3.nriesgo
              AND nmovimi = v_nmov_ant;
         EXCEPTION
           WHEN OTHERS THEN
           -- No se ha podido calcular el promedio de asegurados.
                numerr := 9908263;
                RAISE warn_fin_supl;
         END;
         vpasexec := 11;
         --
         -- Modificamos la pregunta de nro de asegurados
         --
         UPDATE estpregunseg
            SET crespue = v_paseg
          WHERE sseguro = v_est_sseguro
            AND cpregun = 7102
            AND nriesgo = regs3.nriesgo
            AND nmovimi = v_nmovimi;
         vpasexec := 12;
         --
         --tarificamos el riesgo
         --
         numerr := pac_tarifas.f_tarifar_riesgo_tot('EST', v_est_sseguro, regs3.nriesgo,
                                                    v_nmovimi,
                                                    pac_monedas.f_moneda_producto(v_sproduc),
                                                    v_ffecsup);
         IF numerr <> 0 THEN
            RAISE warn_fin_supl;
         END IF;
         vpasexec := 13;
      END LOOP;

------------------------------------------------------------------------
      vpasexec := 14;
      --
      --Viabilidad tarificación productos de migración Se añade el moivo como parámetro
      numerr := pk_suplementos.f_validar_cambios(f_user, v_est_sseguro, v_nmovimi, v_sproduc,
                                                 'BBDD', 'SUPLEMENTO', v_cidioma, v_cmotmov);
      IF numerr <> 0 THEN
         RAISE warn_fin_supl;
      END IF;

      vpasexec := 15;

      -- Se graba el suplemento en las tablas reales
      vpasexec := 16;
      numerr := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);

      IF numerr <> 0 THEN
         RAISE warn_fin_supl;
      END IF;

-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
      vpasexec := 17;
      numerr := pac_prod_comu.f_emite_propuesta(psseguro, onpoliza, oncertif, onrecibo,
                                                onsolici);

      IF numerr <> 0 THEN
         numerr := 151237;
         RAISE warn_fin_supl;
      END IF;
      vpasexec := 18;
      v_est_sseguro := NULL;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 9000505;
      WHEN warn_fin_supl THEN
         ROLLBACK;
         v_texto := f_axis_literales (numerr, f_idiomauser);
   --      v_err := f_proceslin(v_sproces, v_texto, psseguro, v_nnumlin);
         v_hayerror := v_hayerror + 1;
         v_err := f_procesfin(v_sproces, v_hayerror);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     'Warning: ' || f_axis_literales(numerr, v_cidioma), numerr);
         numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;

         SELECT DECODE(NVL(numerr, 0), 0, 1000455, numerr)
           INTO numerr
           FROM DUAL;

         RETURN numerr;
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     f_axis_literales(numerr, v_cidioma), SQLERRM);
         numerr := pk_suplementos.f_final_suplemento(v_est_sseguro, v_nmovimi, psseguro);
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;

         SELECT DECODE(NVL(numerr, 0), 0, 1000455, numerr)
           INTO numerr
           FROM DUAL;

         RETURN numerr;
   END f_cambio_aut_numaseg;
   --
END pac_sup_general;

/