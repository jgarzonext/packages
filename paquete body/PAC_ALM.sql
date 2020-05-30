--------------------------------------------------------
--  DDL for Package Body PAC_ALM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_ALM" IS
/******************************************************************************
   NOMBRE:       pac_alm
   PROPÓSITO: Información del proceso ALM-Asset Liability Management

   REVISIONES:

   Ver        Fecha        Autor  Descripción
   ---------  ----------  ------  ------------------------------------
     1        14/09/2010   JMF    1. 0015956 CEM - ALM
******************************************************************************/

   /*************************************************************************
       Función que consulta si existe detalle ALM para una fecha
       param p_cempres    in : empresa
       param p_fcalcul    in : fecha calculo
       retorno 0-No existe, 1-Si existe
   *************************************************************************/
   FUNCTION f_existe_detalle(p_cempres IN NUMBER, p_fcalcul IN DATE)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_ALM.F_EXISTE_DETALLE';
      v_tparam       VARCHAR2(100)
                             := 'e=' || p_cempres || ' f=' || TO_CHAR(p_fcalcul, 'dd-mm-yyyy');
      v_ntraza       NUMBER;
      v_nexiste      NUMBER;

      CURSOR cur_detalle IS
         SELECT 1
           FROM alm_detalle
          WHERE cempres = p_cempres
            AND fvalora = p_fcalcul;
   BEGIN
      v_ntraza := 1;

      OPEN cur_detalle;

      FETCH cur_detalle
       INTO v_nexiste;

      IF cur_detalle%NOTFOUND THEN
         v_nexiste := 0;
      END IF;

      CLOSE cur_detalle;

      RETURN v_nexiste;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 07/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF cur_detalle%ISOPEN THEN
            CLOSE cur_detalle;
         END IF;

         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam,
                     SQLCODE || '-' || SQLERRM);
         RETURN 0;
   END f_existe_detalle;

   /*************************************************************************
       Función que borra el detalle para un producto.
       param p_cempres in : empresa
       param p_sproduc in : producto
       retorno 0-Correcto, 1-Error
   *************************************************************************/
   FUNCTION f_borra_detalle(p_cempres IN NUMBER, p_sproduc IN NUMBER)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_ALM.F_BORRA_DETALLE';
      v_tparam       VARCHAR2(100) := 'e=' || p_cempres || ' p=' || p_sproduc;
      v_ntraza       NUMBER;
      v_nnumerr      NUMBER;
      e_salir        EXCEPTION;
   BEGIN
      v_ntraza := 10;

      IF p_cempres IS NULL THEN
         v_nnumerr := 103135;
         RAISE e_salir;
      END IF;

      v_ntraza := 15;

      DELETE FROM alm_detalle
            WHERE cempres = p_cempres
              AND sproduc = NVL(p_sproduc, sproduc);

      RETURN 0;
   EXCEPTION
      WHEN e_salir THEN
         RETURN v_nnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam,
                     SQLCODE || '-' || SQLERRM);
         RETURN 1000455;
   END f_borra_detalle;

   /*************************************************************************
       Función que genera el proceso ALM
       param p_cempres    in : empresa
       param p_fcalcul    in : fecha calculo
       param p_sproduc    in : producto
       param p_pintfutdef in : Interés futuro defecto
       param p_pcredibdef in : Porcentaje de credibilidad defecto
       retorno 0-Correcto, 1-Código Error
   *************************************************************************/
   FUNCTION f_genera_alm(
      p_cempres IN NUMBER,
      p_fcalcul IN DATE,
      p_sproduc IN NUMBER,
      p_pintfutdef IN NUMBER,
      p_pcredibdef IN NUMBER,
      p_cramo IN NUMBER)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_ALM.F_GENERA_ALM';
      v_tparam       VARCHAR2(100)
         := 'e=' || p_cempres || ' f=' || TO_CHAR(p_fcalcul, 'dd-mm-yyyy') || ' p='
            || p_sproduc || ' i=' || p_pintfutdef || ' c=' || p_pcredibdef || ' r=' || p_cramo;
      v_ntraza       NUMBER;
      v_nnumerr      NUMBER;

      CURSOR cur_polizas IS
         SELECT s.sseguro, s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.sproduc, s.npoliza,
                p_fcalcul fvalora, NVL(s.fvencim, h.frevisio) fvencim, s.cforpag,
                f_sysdate fmodif, p.csexper,
                ROUND(MONTHS_BETWEEN(p_fcalcul, p.fnacimi) / 12) edadase, 0 ipromat,
                r.pinttec
           FROM seguros s, asegurados a, per_personas p, productos r, seguros_aho h
          WHERE s.cempres = p_cempres
            AND f_prod_ahorro(s.sproduc) = 1   -- Productes d'estalvi
            AND f_vigente(s.sseguro, NULL, p_fcalcul) = 0
            AND s.sproduc = NVL(p_sproduc, s.sproduc)
            AND s.cramo = NVL(p_cramo, s.cramo)
            AND a.sseguro = s.sseguro
            AND a.ffecfin IS NULL
            AND a.norden = (SELECT MIN(aa.norden)
                              FROM asegurados aa
                             WHERE aa.sseguro = a.sseguro
                               AND aa.ffecfin IS NULL)
            AND p.sperson = a.sperson
            AND h.sseguro(+) = s.sseguro
            AND r.sproduc = s.sproduc;

      CURSOR cur_criteri IS
         SELECT   *
             FROM alm_criterio
            WHERE cempres = p_cempres
         ORDER BY norden;

      v_ndiasano     NUMBER := 36525 / 100;
      reg_almdetalle alm_detalle%ROWTYPE;
      v_ncredib      alm_detalle.pcredibi%TYPE;
      v_nintfut      alm_detalle.pintfut%TYPE;
      v_naux         NUMBER;
      v_fhoy         DATE;
      v_rowid        ROWID;
      v_pinteres     NUMBER;
      e_salir        EXCEPTION;
   BEGIN
      v_ntraza := 1000;
      v_fhoy := f_sysdate;
      v_ntraza := 1005;

      IF p_pintfutdef < 0
         OR p_pintfutdef >= 100 THEN
         v_nnumerr := 9901557;   -- Valor erroneo para Interés futuro
         RAISE e_salir;
      END IF;

      DECLARE
         v_nint         alm_detalle.pintfut%TYPE;
      BEGIN
         v_nint := p_pintfutdef;
      EXCEPTION
         WHEN OTHERS THEN
            v_nnumerr := 1000150;
            RAISE e_salir;
      END;

      v_ntraza := 1010;

      IF p_pcredibdef < 0
         OR p_pcredibdef > 1 THEN
         v_nnumerr := 9901556;   -- Valor erroni per percentatge de credibilitat
         RAISE e_salir;
      END IF;

      DECLARE
         v_ncre         alm_detalle.pcredibi%TYPE;
      BEGIN
         v_ncre := p_pcredibdef;
      EXCEPTION
         WHEN OTHERS THEN
            v_nnumerr := 1000150;
            RAISE e_salir;
      END;

      v_ntraza := 1015;
      v_nnumerr := f_borra_detalle(p_cempres, p_sproduc);

      IF v_nnumerr <> 0 THEN
         RAISE e_salir;
      END IF;

      v_ntraza := 1020;
      v_ntraza := 1025;

      FOR f1 IN cur_polizas LOOP
         v_ntraza := 1030;
         reg_almdetalle := NULL;
         v_ntraza := 1060;

         INSERT INTO alm_detalle
                     (cempres, sseguro, cramo, cmodali, ctipseg, ccolect,
                      sproduc, npoliza, fvalora, fvencim, nedadase, csexo,
                      cforpag, ipromat)
              VALUES (p_cempres, f1.sseguro, f1.cramo, f1.cmodali, f1.ctipseg, f1.ccolect,
                      f1.sproduc, f1.npoliza, f1.fvalora, f1.fvencim, f1.edadase, f1.csexper,
                      f1.cforpag, f1.ipromat);

--------------------------------------------------------------------------
-- Modificar porcentajes en función de criterios establecidos.
         v_nintfut := NULL;
         v_ncredib := NULL;
         v_ntraza := 1035;

         FOR reg IN cur_criteri LOOP
            v_ntraza := 1040;

            EXECUTE IMMEDIATE 'BEGIN SELECT COUNT(1) INTO :v_naux FROM ALM_DETALLE WHERE sseguro = '
                              || f1.sseguro || ' AND ' || reg.tcriterio || ';END;'
                        USING OUT v_naux;

            IF v_naux >= 1 THEN
               v_ntraza := 1045;
               v_nintfut := reg.pintfut;
               v_ncredib := reg.pcredibi;
               EXIT;
            END IF;
         END LOOP;

         -- Si no encuentra criterios, asigna valores por defecto.
         v_ntraza := 1050;
         reg_almdetalle.pintfut := NVL(v_nintfut, p_pintfutdef);
         v_ntraza := 1051;
         reg_almdetalle.pcredibi := NVL(v_ncredib, p_pcredibdef);
--------------------------------------------------------------------------
         f1.ipromat := pac_provmat_formul.f_calcul_formulas_provi(f1.sseguro, p_fcalcul,
                                                                  'IPROVAC');
         -- Buscar interes
         v_ntraza := 1055;
         v_nnumerr := pac_provi_mv.f_pintec_adicional(0, f1.sproduc, f1.ipromat, f1.fvalora,
                                                      v_pinteres, f1.sseguro);

         IF v_nnumerr <> 0 THEN
            v_pinteres := 0;
         END IF;

         reg_almdetalle.ipromat := f1.ipromat;
         v_ntraza := 1065;
         reg_almdetalle.icapgar := f_round(pac_provi_mv.f_capital_actual(f1.sseguro,
                                                                         f1.fvalora, v_nnumerr)
-- JLB - I - BUG 18423 COjo la moneda del producto
                                           ,
                                           pac_monedas.f_moneda_producto(f1.sproduc)
-- JLB - F - BUG 18423 COjo la moneda del producto
                                  );
         v_ntraza := 1070;
         reg_almdetalle.pinttec := NVL(f1.pinttec, 0) + NVL(v_pinteres, 0);
         v_ntraza := 1075;
         reg_almdetalle.ndias := (f1.fvencim - f1.fvalora) * reg_almdetalle.pcredibi;
         v_ntraza := 1080;
         reg_almdetalle.fvenest := f1.fvalora + reg_almdetalle.ndias;
         reg_almdetalle.fmodif := v_fhoy;

         IF reg_almdetalle.ndias > 365 THEN
            v_ntraza := 1085;
            reg_almdetalle.iproyec := reg_almdetalle.ipromat
                                      *(1 + reg_almdetalle.pinttec / 100)
                                      * POWER(1 + reg_almdetalle.pintfut / 100,
                                              (reg_almdetalle.ndias / v_ndiasano) - 1);
         ELSE
            v_ntraza := 1090;
            reg_almdetalle.iproyec := reg_almdetalle.ipromat
                                      * POWER(1 + reg_almdetalle.pinttec / 100,
                                              (reg_almdetalle.ndias / v_ndiasano));
         END IF;

         v_ntraza := 1100;

         UPDATE alm_detalle
            SET icapgar = reg_almdetalle.icapgar,
                pcredibi = reg_almdetalle.pcredibi,
                pintfut = reg_almdetalle.pintfut,
                ndias = reg_almdetalle.ndias,
                fvenest = reg_almdetalle.fvenest,
                iproyec = reg_almdetalle.iproyec,
                fmodif = reg_almdetalle.fmodif,
                pinttec = reg_almdetalle.pinttec,
                ipromat = reg_almdetalle.ipromat
          WHERE sseguro = f1.sseguro
            AND fvencim = f1.fvencim
            AND cempres = p_cempres;
      END LOOP;

      v_ntraza := 1110;
      RETURN 0;
   EXCEPTION
      WHEN e_salir THEN
         RETURN v_nnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam,
                     SQLCODE || '-' || SQLERRM);
         RETURN 1000455;
   END f_genera_alm;

   /*************************************************************************
       Función que crea registro nuevo en ALM_CRITERIO
       si el parametro ORDEN no esta informado. Resto casos actualiza registro.
       param p_cempres    in : empresa
       param p_TCRITERIO  IN : Criterio
       param p_NORDEN     IN : Orden
       param p_PCREDIBI   IN : Porcentaje credibilidad
       param p_PINTFUT    IN : Porcentaje interes
       retorno 0-Correcto, 1-Código error.
   *************************************************************************/
   FUNCTION f_set_almcriterio(
      p_cempres IN NUMBER,
      p_tcriterio IN VARCHAR2,
      p_norden IN NUMBER,
      p_pcredibi IN NUMBER,
      p_pintfut IN NUMBER)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_ALM.F_SET_ALMCRITERIO';
      v_tparam       VARCHAR2(200)
         := 'e=' || p_cempres || ' o=' || p_norden || ' c=' || p_pcredibi || ' i='
            || p_pintfut;
      v_ntraza       NUMBER;
      v_nnumerr      NUMBER;
      v_nexiste      NUMBER;
      v_norden       alm_criterio.norden%TYPE;
      e_salir        EXCEPTION;
   BEGIN
      v_ntraza := 1;

      SELECT v_tparam || ' c=' || SUBSTR(p_tcriterio, 1, 100)
        INTO v_tparam
        FROM DUAL;

      v_ntraza := 3;

      IF p_cempres IS NULL THEN
         v_nnumerr := 9000819;
         RAISE e_salir;
      END IF;

      IF p_pintfut < 0
         OR p_pintfut >= 100 THEN
         v_nnumerr := 9901557;   -- Valor erroneo para Interés futuro
         RAISE e_salir;
      END IF;

      IF p_pcredibi < 0
         OR p_pcredibi > 1 THEN
         v_nnumerr := 9901556;   -- Valor erroni per percentatge de credibilitat
         RAISE e_salir;
      END IF;

      IF p_norden IS NULL THEN
         -- alta
         -- alta
         -- alta
         v_ntraza := 5;

         SELECT NVL(MAX(norden), 0) + 1
           INTO v_norden
           FROM alm_criterio
          WHERE cempres = p_cempres;

         IF p_tcriterio IS NULL THEN
            v_nnumerr := 103135;
            RAISE e_salir;
         END IF;

         v_ntraza := 7;

         SELECT NVL(MAX(1), 0)
           INTO v_nexiste
           FROM alm_criterio
          WHERE cempres = p_cempres
            AND tcriterio = p_tcriterio;

         IF v_nexiste = 1 THEN
            v_nnumerr := 108959;
            RAISE e_salir;
         END IF;

         v_ntraza := 9;

         INSERT INTO alm_criterio
                     (cempres, tcriterio, norden, pcredibi, pintfut)
              VALUES (p_cempres, p_tcriterio, v_norden, p_pcredibi, p_pintfut);
      ELSE
         -- update
         -- update
         -- update
         v_ntraza := 11;

         SELECT NVL(MAX(1), 0)
           INTO v_nexiste
           FROM alm_criterio
          WHERE cempres = p_cempres
            AND norden = p_norden;

         IF v_nexiste = 0 THEN
            v_nnumerr := 102903;
            RAISE e_salir;
         END IF;

         v_ntraza := 13;

         UPDATE alm_criterio
            SET tcriterio = p_tcriterio,
                pcredibi = p_pcredibi,
                pintfut = p_pintfut
          WHERE cempres = p_cempres
            AND norden = p_norden;
      END IF;

      v_ntraza := 15;
      RETURN 0;
   EXCEPTION
      WHEN e_salir THEN
         RETURN v_nnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam,
                     SQLCODE || '-' || SQLERRM);
         RETURN 1000455;
   END f_set_almcriterio;

   /*************************************************************************
       Función que borra registro de ALM_CRITERIO
       param p_cempres    in : empresa
       param p_NORDEN     IN : Orden
       retorno 0-Correcto, 1-Código error.
   *************************************************************************/
   FUNCTION f_del_almcriterio(p_cempres IN NUMBER, p_norden IN NUMBER)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_ALM.F_DEL_ALMCRITERIO';
      v_tparam       VARCHAR2(200) := 'e=' || p_cempres || ' o=' || p_norden;
      v_ntraza       NUMBER;
      v_nnumerr      NUMBER;
      v_nexiste      NUMBER;
      v_norden       alm_criterio.norden%TYPE;
      e_salir        EXCEPTION;
   BEGIN
      v_ntraza := 1;

      IF p_cempres IS NULL THEN
         v_nnumerr := 9000819;
         RAISE e_salir;
      ELSIF p_norden IS NULL THEN
         v_nnumerr := 103135;
         RAISE e_salir;
      END IF;

      v_ntraza := 3;

      SELECT NVL(MAX(1), 0)
        INTO v_nexiste
        FROM alm_criterio
       WHERE cempres = p_cempres
         AND norden = p_norden;

      IF v_nexiste = 0 THEN
         v_nnumerr := 102903;
         RAISE e_salir;
      END IF;

      v_ntraza := 5;

      DELETE      alm_criterio
            WHERE cempres = p_cempres
              AND norden = p_norden;

      v_ntraza := 7;
      RETURN 0;
   EXCEPTION
      WHEN e_salir THEN
         RETURN v_nnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza, v_tparam,
                     SQLCODE || '-' || SQLERRM);
         RETURN 1000455;
   END f_del_almcriterio;
END pac_alm;

/

  GRANT EXECUTE ON "AXIS"."PAC_ALM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ALM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ALM" TO "PROGRAMADORESCSI";
