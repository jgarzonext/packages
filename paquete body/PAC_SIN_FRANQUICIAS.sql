--------------------------------------------------------
--  DDL for Package Body PAC_SIN_FRANQUICIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SIN_FRANQUICIAS" IS
   FUNCTION f_franquicia(
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_fecha IN NUMBER,
      p_cvalor1 OUT NUMBER,
      p_impvalor1 OUT NUMBER,
      p_cimpmin OUT NUMBER,
      p_impmin OUT NUMBER,
      p_cimpmax OUT NUMBER,
      p_impmax OUT NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_sin_franquicias.f_franquicia';
      vparam         VARCHAR2(4000)
         := 'parametros - p_sseguro:' || p_sseguro || ' p_nmovimi:' || p_nmovimi
            || ' p_nriesgo: ' || p_nriesgo || ' p_cgarant:' || p_cgarant || ' p_fecha:'
            || p_fecha;
      vpasexec       NUMBER(5) := 1;
      v_cgrup        NUMBER;
      v_csubgrup     NUMBER;
      v_cversion     NUMBER;
      v_cnivel       NUMBER;
   BEGIN
      SELECT f.cgrup, f.csubgrup, f.cversion, f.cnivel
        INTO v_cgrup, v_csubgrup, v_cversion, v_cnivel
        FROM bf_bonfranseg f, bf_progarangrup g, seguros s, bf_codgrup cg
       WHERE f.sseguro = p_sseguro
         AND g.codgrup = f.cgrup
         AND f.sseguro = s.sseguro
         AND g.sproduc = s.sproduc
         AND cg.cgrup = g.codgrup
         AND f.cversion = cg.cversion
         AND f.ctipgrup = cg.ctipgrup
         AND cg.ctipgrup = 2
         AND g.cgarant = p_cgarant
         AND f.nmovimi = p_nmovimi;

      vpasexec := 5;

      SELECT cvalor1, impvalor1, cimpmin, impmin, cimpmax, impmax
        INTO p_cvalor1, p_impvalor1, p_cimpmin, p_impmin, p_cimpmax, p_impmax
        FROM bf_bonfranseg
       WHERE sseguro = p_sseguro
         AND nriesgo = p_nriesgo
         AND nmovimi = p_nmovimi
         AND cgrup = v_cgrup
         AND csubgrup = v_csubgrup
         AND cversion = v_cversion
         AND cnivel = v_cnivel;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN SQLCODE;
   END f_franquicia;

   FUNCTION f_fran_val(
      p_cvalor IN NUMBER,
      p_imp IN NUMBER,
      p_importe IN NUMBER,
      p_fecha IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_sin_franquicias.f_franquicia_valor';
      vparam         VARCHAR2(4000)
         := 'parametros - p_cvalor: ' || p_cvalor || ' p_imp:' || p_imp || ' p_importe:'
            || p_importe || ' p_fecha:' || p_fecha;
      vresultado     NUMBER := 0;
      vpasexec       NUMBER(5) := 1;
      v_cambio       NUMBER;
      moneda_empresa VARCHAR2(3);
      v_fcambio      DATE;
   BEGIN
      IF p_cvalor = 1 THEN
         vpasexec := 5;
         vresultado := (p_importe * p_imp) / 100;
      ELSIF p_cvalor = 2 THEN
         vpasexec := 10;
         vresultado := p_imp;
      ELSIF p_cvalor = 3 THEN
         vpasexec := 15;
         vresultado := NULL;
      ELSIF p_cvalor = 4 THEN
         vpasexec := 20;
         moneda_empresa :=
            pac_monedas.f_cmoneda_t
                               (pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                              'MONEDAEMP'));
         vpasexec := 22;
         v_fcambio := pac_eco_tipocambio.f_fecha_max_cambio('SMV', moneda_empresa);

         IF v_fcambio IS NULL THEN
            p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                        'No se ha encontrado el tipo de cambio entre monedas');
            RETURN 9902592;
         -- No se ha encontrado el tipo de cambio entre monedas
         END IF;

         vpasexec := 25;
         v_cambio := pac_eco_tipocambio.f_cambio('SMV', moneda_empresa, v_fcambio);
         vpasexec := 30;
         vresultado := pac_monedas.f_round(p_imp * v_cambio,
                                           pac_monedas.f_cmoneda_n(moneda_empresa));
      END IF;

      RETURN vresultado;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN vresultado;   -- En caso de error devuelve 0 por inicalización
   END f_fran_val;

   FUNCTION f_fran_tot(
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_importe IN NUMBER,
      p_fecha IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_sin_franquicias.f_franquicia_total';
      vparam         VARCHAR2(4000)
         := 'parametros - p_sseguro: ' || p_sseguro || ' p_nmovimi:' || p_nmovimi
            || ' p_nriesgo:' || p_nriesgo || ' p_cgarant:' || p_cgarant || ' p_importe:'
            || p_importe || ' p_fecha:' || p_fecha;
      vpasexec       NUMBER(5) := 1;
      vfranquicia    NUMBER := 0;
      vcvalor1       NUMBER;
      vimpvalor1     NUMBER;
      vcimpmin       NUMBER;
      vimpmin        NUMBER;
      vcimpmax       NUMBER;
      vimpmax        NUMBER;
      v_mayorvalor   NUMBER := 0;
   BEGIN
      vfranquicia := f_franquicia(p_sseguro, p_nmovimi, p_nriesgo, p_cgarant, p_fecha,
                                  vcvalor1, vimpvalor1, vcimpmin, vimpmin, vcimpmax, vimpmax);

      IF vfranquicia = 0 THEN
         vpasexec := 5;

         BEGIN
            SELECT GREATEST(f_fran_val(vcvalor1, vimpvalor1, p_importe, p_fecha),
                            f_fran_val(vcimpmin, vimpmin, p_importe, p_fecha))
              INTO v_mayorvalor
              FROM DUAL;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN v_mayorvalor;   -- En caso de error devuelve 0 por inicalización
         END;

         RETURN v_mayorvalor;
      ELSE
         RETURN vfranquicia;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN v_mayorvalor;   -- En caso de error devuelve 0 por inicalización
   END f_fran_tot;

   FUNCTION f_cob_ded(p_sseguro IN NUMBER, p_nmovimi IN NUMBER, p_nriesgo IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_sin_franquicias.f_cob_ded';
      vparam         VARCHAR2(4000)
         := 'parametros - p_sseguro: ' || p_sseguro || ' p_nmovimi: ' || p_nmovimi
            || ' p_nriesgo: ' || p_nriesgo;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER := 0;
      vfranquicia    NUMBER := 0;
      vgarantias     t_iax_garansini;
      vfsinies       NUMBER;   --sin_siniestro.fsinies%TYPE;
      vcgarant       NUMBER;
      vimporte       NUMBER;
   BEGIN
      vnumerr := pac_call.f_garantias_siniestro(vgarantias);

      IF vgarantias IS NOT NULL
         AND vgarantias.COUNT > 0 THEN
         FOR k IN vgarantias.FIRST .. vgarantias.LAST LOOP
            vpasexec := 140;

            IF vgarantias(k).cgarant IN(758, 759)   --PTH, PTD
                                                 THEN
               vcgarant := vgarantias(k).cgarant;
               vimporte := vgarantias(k).icaprisc;
            END IF;
         END LOOP;
      END IF;

      IF vcgarant IS NOT NULL THEN
         vfranquicia := f_fran_tot(p_sseguro, p_nmovimi, p_nriesgo, vcgarant, vimporte,
                                   vfsinies);
      ELSE
         vfranquicia := 0;
      END IF;

      RETURN vfranquicia;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 0;   -- En caso de error devuelve 0 por inicalización
   END f_cob_ded;

   FUNCTION f_get_nmovimi_gar(
      p_sseguro IN NUMBER,
      p_cgarant IN NUMBER,
      p_fecha IN DATE,
      p_nmovimi OUT NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_sin_franquicias.f_get_nmovimi_gar';
      vparam         VARCHAR2(4000)
         := 'parametros - p_sseguro: ' || p_sseguro || ' p_cgarant: ' || p_cgarant
            || ' p_fecha: ' || p_fecha;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER := 0;
   BEGIN
      BEGIN
         SELECT gg.nmovimi
           INTO p_nmovimi
           FROM garanseg gg
          WHERE gg.finiefe <= p_fecha
            AND(gg.ffinefe IS NULL
                OR gg.ffinefe - 1 >= p_fecha)
            AND gg.cgarant = p_cgarant
            AND gg.sseguro = p_sseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 1;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;   -- En caso de error devuelve 0 por inicalización
   END f_get_nmovimi_gar;
END pac_sin_franquicias;

/

  GRANT EXECUTE ON "AXIS"."PAC_SIN_FRANQUICIAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_FRANQUICIAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_FRANQUICIAS" TO "PROGRAMADORESCSI";
