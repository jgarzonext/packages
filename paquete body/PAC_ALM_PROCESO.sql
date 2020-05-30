--------------------------------------------------------
--  DDL for Package Body PAC_ALM_PROCESO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_ALM_PROCESO" IS
        /****************************************************************************
              NOMBRE:       PAC_ALM_PROCESO
              PROPÓSITO:  Funciones para cálculo provisiones CEM

              REVISIONES:
      Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------  ----------------------------------
      1.0        13/12/2010    JRH     16981: CEM - Proceso ALM  - Creación package.
      2.0        20/12/2010    JRH     16981: CEM - Proceso ALM
      3.0        27/01/2011    JRH     17441: Verificació dels fluxes del mes de desembre.
      4.0        17/03/2011    RSC      8999: IAX014 - iAXIS - Mnt. Parámetros
     ****************************************************************************/
   -- BUG 0016981 - 12/2010 - JRH  -  Proceso ALM
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;
   ult_momento    NUMBER := DBMS_UTILITY.get_time;

/*************************************************************************
      Generar Fichero
      psproces: Proceso
      pmodo: Modo
      Retorna Tiempo
   *************************************************************************/
   FUNCTION f_generar_fichero(psproces IN NUMBER, pmodo IN VARCHAR2)
      RETURN NUMBER IS
      vnomsalida     VARCHAR2(100);
      vficherosalida UTL_FILE.file_type;
      vempresa       NUMBER;

      CURSOR c_proces IS
         SELECT *
           FROM alm_proceso_previo
          WHERE sproces = psproces
            AND pmodo = 'P'
         UNION
         SELECT *
           FROM alm_proceso
          WHERE sproces = psproces
            AND pmodo <> 'P';

      vobjectname    VARCHAR2(500) := 'PAC_ALM_PROCESO.f_generar_Fichero';
      vparam         VARCHAR2(500) := 'psproces:' || psproces || ' ' || 'pmodo:' || pmodo;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_linea        VARCHAR2(2000);
      pdata_proces   DATE;
   BEGIN
      vnumerr := 0;
      vnomsalida := '_RAXIS_ALM_' || pmodo
                    || TRIM(TO_CHAR(NVL(pdata_proces, f_sysdate), 'yyyymmdd')) || '_'
                    || TRIM(TO_CHAR(f_sysdate, 'hh24miss')) || '_DWH.txt';
      vpasexec := 2;
      --Fin Bug.: 15747
      vficherosalida := UTL_FILE.fopen(pac_nombres_ficheros.ff_ruta_fichero(4, 10, 1),
                                       vnomsalida, 'w', 32767);
      vempresa := f_parinstalacion_n('EMPRESADEF');
      vpasexec := 3;
      --Cabecera
      v_linea := NULL;
      v_linea := v_linea || LPAD('FPROCES', 14, ' ');
      v_linea := v_linea || LPAD('SPRODUC', 14, ' ');
      v_linea := v_linea || LPAD('FECVTOREF', 14, ' ');
      v_linea := v_linea || LPAD('INTERES', 14, ' ');
      v_linea := v_linea || LPAD('NMES', 14, ' ');
      v_linea := v_linea || LPAD('FPREST', 14, ' ');
      v_linea := v_linea || LPAD('CRAMO', 14, ' ');
      v_linea := v_linea || LPAD('CMODALI', 14, ' ');
      v_linea := v_linea || LPAD('CTIPSEG', 14, ' ');
      v_linea := v_linea || LPAD('CCOLECT', 14, ' ');
      v_linea := v_linea || LPAD('APORTACION', 14, ' ');
      v_linea := v_linea || LPAD('RENTA', 14, ' ');
      v_linea := v_linea || LPAD('RENTAMIN', 14, ' ');
      v_linea := v_linea || LPAD('CAPRIES', 14, ' ');
      -- v_linea := v_linea || LPAD('BRUTOSUPERV', 14, ' ');
      v_linea := v_linea || LPAD('BRUTOSUPERV2', 14, ' ');
      v_linea := v_linea || LPAD('BRUTODEF', 14, ' ');
      -- v_linea := v_linea || LPAD('GASTOBRUTO', 14, ' ');
      v_linea := v_linea || LPAD('GASTOBRUTO2', 14, ' ');
      v_linea := v_linea || LPAD('GASTOBRUTORIES', 14, ' ');
      -- v_linea := v_linea || LPAD('PROBSUPERV', 14, ' ');
      v_linea := v_linea || LPAD('PROBSUPERV2', 14, ' ');
      v_linea := v_linea || LPAD('PROBDEF', 14, ' ');
      -- v_linea := v_linea || LPAD('GASTOBRUTOPROB', 14, ' ');
      v_linea := v_linea || LPAD('GASTBRUTO2PROB', 14, ' ');
      v_linea := v_linea || LPAD('GASTBRTRIEPROB', 14, ' ');
      -- v_linea := v_linea || LPAD('BRUTOSUPERVACT', 14, ' ');
      v_linea := v_linea || LPAD('BRUTSUPERVACT2', 14, ' ');
      v_linea := v_linea || LPAD('BRUTODEFACT', 14, ' ');
      -- v_linea := v_linea || LPAD('GASTOBRUTOACT', 14, ' ');
      v_linea := v_linea || LPAD('GASTOBRUTOACT2', 14, ' ');
      v_linea := v_linea || LPAD('GASTOBRUTOACTRIES', 14, ' ');
      --  v_linea := v_linea || LPAD('PROBSUPERVACT', 14, ' ');
      v_linea := v_linea || LPAD('PROBSUPERVACT2', 14, ' ');
      v_linea := v_linea || LPAD('PROBDEFACT', 14, ' ');
      --v_linea := v_linea || LPAD('GASTBRTPROBACT', 14, ' ');
      v_linea := v_linea || LPAD('GASTBRTPRBACT2', 14, ' ');
      v_linea := v_linea || LPAD('GASTBRTRIPBACT', 14, ' ');
      v_linea := v_linea || LPAD('PM1', 14, ' ');
      v_linea := v_linea || LPAD('PM2', 14, ' ');
      v_linea := v_linea || LPAD('PMR1', 14, ' ');
      v_linea := v_linea || LPAD('PMT', 14, ' ');
      v_linea := v_linea || LPAD('PMT2', 14, ' ');
      vpasexec := 4;
      UTL_FILE.put_line(vficherosalida, v_linea);
      vpasexec := 5;

      FOR reg IN c_proces LOOP
         v_linea := NULL;
         v_linea := v_linea || LPAD(TO_CHAR(reg.fproces, 'DD/MM/YYYY'), 14, ' ');
         v_linea := v_linea || LPAD(reg.sproduc, 14, ' ');
         v_linea := v_linea || LPAD(TO_CHAR(reg.fecvtoref, 'DD/MM/YYYY'), 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.interes, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(reg.nmes, 14, ' ');
         v_linea := v_linea || LPAD(TO_CHAR(reg.fprest, 'DD/MM/YYYY'), 14, ' ');
         v_linea := v_linea || LPAD(reg.cramo, 14, ' ');
         v_linea := v_linea || LPAD(reg.cmodali, 14, ' ');
         v_linea := v_linea || LPAD(reg.ctipseg, 14, ' ');
         v_linea := v_linea || LPAD(reg.ccolect, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.aportacion_acum, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.renta_acum, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.rentamin_acum, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.capries_acum, 2) * 100, 14, ' ');
         --  v_linea := v_linea || LPAD(ROUND(reg.impacumbrutosuperv, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.impacumbrutosuperv2, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.impacumbrutodef, 2) * 100, 14, ' ');
         --  v_linea := v_linea || LPAD(ROUND(reg.impacumgastobruto, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.impacumgastobruto2, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.impacumgastobrutories, 2) * 100, 14, ' ');
         --   v_linea := v_linea || LPAD(ROUND(reg.impacumprobsuperv, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.impacumprobsuperv2, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.impacumprobdef, 2) * 100, 14, ' ');
         --  v_linea := v_linea || LPAD(ROUND(reg.impacumgastobrutoprob, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.impacumgastobruto2prob, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.impacumgastobrutoriesprob, 2) * 100, 14, ' ');
         --  v_linea := v_linea || LPAD(ROUND(reg.impacumbrutosupervact, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.impacumbrutosupervact2, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.impacumbrutodefact, 2) * 100, 14, ' ');
         --  v_linea := v_linea || LPAD(ROUND(reg.impacumgastobrutoact, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.impacumgastobrutoact2, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.impacumgastobrutoactries, 2) * 100, 14, ' ');
         --   v_linea := v_linea || LPAD(ROUND(reg.impacumprobsupervact, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.impacumprobsupervact2, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.impacumprobdefact, 2) * 100, 14, ' ');
         -- v_linea := v_linea || LPAD(ROUND(reg.impacumgastobrutoprobact, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.impacumgastobrutoprobact2, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.impacumgastobrutoriesprobact, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.impacumpm1, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.impacumpm2, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.impacumpmr1, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.impacumpmt, 2) * 100, 14, ' ');
         v_linea := v_linea || LPAD(ROUND(reg.impacumpmt2, 2) * 100, 14, ' ');
         vpasexec := 6;
         UTL_FILE.put_line(vficherosalida, v_linea);
         vpasexec := 7;
      END LOOP;

      IF UTL_FILE.is_open(vficherosalida) THEN
         UTL_FILE.fclose(vficherosalida);
      END IF;

      vpasexec := 8;
      UTL_FILE.frename(pac_nombres_ficheros.ff_ruta_fichero(4, 10, 1), vnomsalida,
                       pac_nombres_ficheros.ff_ruta_fichero(4, 10, 1),
                       SUBSTR(vnomsalida,(LENGTH(vnomsalida) - 1) * -1), TRUE);
      vpasexec := 9;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 1000005;   --Error al gravar la variable de contexto agente de producción.
      WHEN e_object_error THEN
         IF UTL_FILE.is_open(vficherosalida) THEN
            UTL_FILE.fclose(vficherosalida);
         END IF;

         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Error al ejecutar procedimiento o funció - vnumerr: ' || vnumerr);
         RETURN 1000006;   --Error al gravar la variable de contexto agente de producción.
      WHEN OTHERS THEN
         IF UTL_FILE.is_open(vficherosalida) THEN
            UTL_FILE.fclose(vficherosalida);
         END IF;

         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000001;   --Error al gravar la variable de contexto agente de producción.
   END f_generar_fichero;

/*************************************************************************
      f_fvencimcapgar
      Calcula una teórica fecha de vencimiento
      Param in psseguro : seguro
      pnmovimi : novimi
      ptabla: 'EST' o 'SEG'
      Retorna La fecha
   *************************************************************************/
   FUNCTION f_fvencimcapgar(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      ptabla IN VARCHAR2 DEFAULT 'SEG')
      RETURN DATE IS
      vtraza         NUMBER;
      vfvencim       DATE;
      vedad          NUMBER;
      vedad2         NUMBER;
      vfnacimi       DATE;
   BEGIN
      vtraza := 1;

      IF ptabla = 'EST' THEN
         SELECT fvencim
           INTO vfvencim
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT fvencim
           INTO vfvencim
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      vtraza := 2;

      IF vfvencim IS NULL THEN
         vtraza := 3;

         IF ptabla = 'EST' THEN
            /*SELECT crespue
              INTO vedad
              FROM estpregunseg a
             WHERE sseguro = psseguro
               AND nriesgo = 1
               AND cpregun = 1
               AND nmovimi = (SELECT MAX(b.nmovimi)
                                FROM estpregunseg b
                               WHERE b.sseguro = psseguro
                                 AND b.nriesgo = 1
                                 AND b.cpregun = 1);*/
            SELECT p.fnacimi
              INTO vfnacimi
              FROM estassegurats a, estpersonas p
             WHERE a.sseguro = psseguro
               AND a.norden = 1
               AND a.sperson = p.sperson;
         ELSE
            /*SELECT crespue
              INTO vedad
              FROM pregunseg a
             WHERE sseguro = psseguro
               AND nriesgo = 1
               AND cpregun = 1
               AND nmovimi = (SELECT MAX(b.nmovimi)
                                FROM pregunseg b
                               WHERE b.sseguro = psseguro
                                 AND b.nriesgo = 1
                                 AND b.cpregun = 1);*/
            SELECT p.fnacimi
              INTO vfnacimi
              FROM asegurados a, personas p
             WHERE a.sseguro = psseguro
               AND a.norden = 1
               AND a.sperson = p.sperson;
         END IF;

         vtraza := 4;
         vedad := MONTHS_BETWEEN(f_sysdate, vfnacimi) / 12;

         IF NVL(vedad, 0) <= 65 THEN
            vtraza := 5;
            vfvencim := ADD_MONTHS(vfnacimi, 65 * 12);
         ELSE   --Si la edad supera 65 ponemos como fecha vencimiento el multipo de 5 más cercano
            vtraza := 6;

            IF MOD(vedad, 10) < 5 THEN
               vedad2 := TRUNC(vedad / 10) * 10 + 5;
            ELSIF MOD(vedad, 10) > 5 THEN
               vedad2 := TRUNC(vedad / 10) * 10 + 10;
            ELSE
               vedad2 := vedad;
            END IF;

            vtraza := 7;
            vfvencim := ADD_MONTHS(vfnacimi, NVL(vedad2, 65) * 12);
         END IF;
      END IF;

      RETURN vfvencim;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_alm_proceso.f_fvencimcapgar', vtraza,
                     'psseguro = ' || psseguro || ';pnmovimi = ' || pnmovimi || ';ptabla = '
                     || ptabla,
                     SQLERRM);
         RETURN NULL;
   END f_fvencimcapgar;

/*************************************************************************
      MEDIR_TIEMPO
      Mide intervalos de tiempo
      Retorna Tiempo
   *************************************************************************/
   FUNCTION medir_tiempo
      RETURN NUMBER IS
      vdif           NUMBER;
   BEGIN
      NULL;
      vdif := DBMS_UTILITY.get_time - ult_momento;
      ult_momento := DBMS_UTILITY.get_time;
      RETURN vdif;
   END medir_tiempo;

/*************************************************************************
      f_traspasar_det
      Texto con valores en pbasestecnicas
      param in pbasestecnicas : objeto detalle poliza
      Retorna diferente de 0 (un código de error) en caso de error
   *************************************************************************/
   FUNCTION f_traspasar_det(psproces NUMBER, pmodo IN VARCHAR2)
      RETURN VARCHAR2 IS
      vobjectname    VARCHAR2(500) := 'PAC_ALM_PROCESO.f_traspasar_det';
      vparam         VARCHAR2(500) := 'psproces:' || psproces || ' ' || 'pmodo:' || pmodo;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vtexto         VARCHAR2(6500);
   BEGIN
      IF pmodo = 'R' THEN
         INSERT INTO alm_proceso
                     (sproces, fproces, nmes, fprest, cramo, cmodali, ccolect, ctipseg,
                      sproduc, fecvtoref, interes, aportacion_acum, renta_acum, rentamin_acum,
                      capries_acum,
--Importes brutos acumulados
                                   impacumbrutosuperv, impacumbrutosuperv2, impacumbrutodef,
                      impacumgastobruto, impacumgastobruto2, impacumgastobrutories,

--Importes brutos probabilizados acumulados
                      impacumprobsuperv, impacumprobsuperv2, impacumprobdef,
                      impacumgastobrutoprob, impacumgastobruto2prob,
                      impacumgastobrutoriesprob,
--Importes brutos  actualizados    acumulados
                                                impacumbrutosupervact, impacumbrutosupervact2,
                      impacumbrutodefact, impacumgastobrutoact, impacumgastobrutoact2,
                      impacumgastobrutoactries,
--Importes probabilizados  actualizados acumulados
                                               impacumprobsupervact, impacumprobsupervact2,
                      impacumprobdefact, impacumgastobrutoprobact, impacumgastobrutoprobact2,
                      impacumgastobrutoriesprobact,
--Provisiones
                                                   impacumpm1, impacumpm2, impacumpmr1,
                      impacumpmt, impacumpmt2)
            SELECT   sproces, fproces, nmes, fprest, cramo, cmodali, ccolect, ctipseg,
                     sproduc, fecvtoref, inter_tecn, SUM(aportacion), SUM(renta),
                     SUM(renta_min), SUM(capital_riesgo), SUM(impbrutosuperv),
                     SUM(impbrutosuperv2), SUM(impbrutodef), SUM(gastobruto),
                     SUM(gastobruto2), SUM(gastobrutories), SUM(impprobsuperv),
                     SUM(impprobsuperv2), SUM(impprobdef), SUM(gastobrutoprob),
                     SUM(gastobruto2prob), SUM(gastobrutoriesprob), SUM(impbrutosupervact),
                     SUM(impbrutosupervact2), SUM(impbrutodefact), SUM(gastobrutoact),
                     SUM(gastobrutoact2), SUM(gastobrutoactries), SUM(impprobsupervact),
                     SUM(impprobsupervact2), SUM(impprobdefact), SUM(gastobrutoprobact),
                     SUM(gastobrutoprobact2), SUM(gastobrutoriesprobact), SUM(pm1), SUM(pm2),
                     SUM(pmr1), SUM(pmt), SUM(pmt2)
                FROM alm_proceso_det
               WHERE sproces = psproces
            GROUP BY sproces, fproces, nmes, fprest, cramo, cmodali, ccolect, ctipseg,
                     sproduc, inter_tecn, fecvtoref;
      ELSE
         INSERT INTO alm_proceso_previo
                     (sproces, fproces, nmes, fprest, cramo, cmodali, ccolect, ctipseg,
                      sproduc, fecvtoref, interes, aportacion_acum, renta_acum, rentamin_acum,
                      capries_acum,
--Importes brutos acumulados
                                   impacumbrutosuperv, impacumbrutosuperv2, impacumbrutodef,
                      impacumgastobruto, impacumgastobruto2, impacumgastobrutories,

--Importes brutos probabilizados acumulados
                      impacumprobsuperv, impacumprobsuperv2, impacumprobdef,
                      impacumgastobrutoprob, impacumgastobruto2prob,
                      impacumgastobrutoriesprob,
--Importes brutos  actualizados    acumulados
                                                impacumbrutosupervact, impacumbrutosupervact2,
                      impacumbrutodefact, impacumgastobrutoact, impacumgastobrutoact2,
                      impacumgastobrutoactries,
--Importes probabilizados  actualizados acumulados
                                               impacumprobsupervact, impacumprobsupervact2,
                      impacumprobdefact, impacumgastobrutoprobact, impacumgastobrutoprobact2,
                      impacumgastobrutoriesprobact,
--Provisiones
                                                   impacumpm1, impacumpm2, impacumpmr1,
                      impacumpmt, impacumpmt2)
            SELECT   sproces, fproces, nmes, fprest, cramo, cmodali, ccolect, ctipseg,
                     sproduc, fecvtoref, inter_tecn, SUM(aportacion), SUM(renta),
                     SUM(renta_min), SUM(capital_riesgo), SUM(impbrutosuperv),
                     SUM(impbrutosuperv2), SUM(impbrutodef), SUM(gastobruto),
                     SUM(gastobruto2), SUM(gastobrutories), SUM(impprobsuperv),
                     SUM(impprobsuperv2), SUM(impprobdef), SUM(gastobrutoprob),
                     SUM(gastobruto2prob), SUM(gastobrutoriesprob), SUM(impbrutosupervact),
                     SUM(impbrutosupervact2), SUM(impbrutodefact), SUM(gastobrutoact),
                     SUM(gastobrutoact2), SUM(gastobrutoactries), SUM(impprobsupervact),
                     SUM(impprobsupervact2), SUM(impprobdefact), SUM(gastobrutoprobact),
                     SUM(gastobrutoprobact2), SUM(gastobrutoriesprobact), SUM(pm1), SUM(pm2),
                     SUM(pmr1), SUM(pmt), SUM(pmt2)
                FROM alm_proc_det_prev
               WHERE sproces = psproces
            GROUP BY sproces, fproces, nmes, fprest, cramo, cmodali, ccolect, ctipseg,
                     sproduc, inter_tecn, fecvtoref;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 1000005;   --Error al gravar la variable de contexto agente de producción.
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Error al ejecutar procedimiento o funció - vnumerr: ' || vnumerr);
         RETURN 1000006;   --Error al gravar la variable de contexto agente de producción.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000001;   --Error al gravar la variable de contexto agente de producción.
   END f_traspasar_det;

/*************************************************************************
      f_obtener_bases_desc:
      Texto con valores en pbasestecnicas
      param in pbasestecnicas : objeto detalle poliza
      Retorna diferente de 0 (un código de error) en caso de error
   *************************************************************************/
   FUNCTION f_obtener_bases_desc(pbasestecnicas t_basestecnicas)
      RETURN VARCHAR2 IS
      vobjectname    VARCHAR2(500) := 'PAC_ALM_PROCESO.f_obtener_bases_desc';
      vparam         VARCHAR2(500) := NULL;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vtexto         VARCHAR2(6500);
   BEGIN
      vtexto := '  vsseguro                       =' || pbasestecnicas.vsseguro;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vfecproc                        ='
                || TO_CHAR(pbasestecnicas.vfecproc, 'dd/mm/yyyy');
      vtexto := vtexto || CHR(10) || CHR(13) || '  vnummes                       ='
                || pbasestecnicas.vnummes;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vfechaprest                     ='
                || TO_CHAR(pbasestecnicas.vfechaprest, 'dd/mm/yyyy');
      vtexto := vtexto || CHR(10) || CHR(13) || '  vefecpol                        ='
                || TO_CHAR(pbasestecnicas.vefecpol, 'dd/mm/yyyy');
      vtexto := vtexto || CHR(10) || CHR(13) || '  vsproduc                        ='
                || pbasestecnicas.vsproduc;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vinteres_tec                    ='
                || pbasestecnicas.vinteres_tec;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vinteres_min                    ='
                || pbasestecnicas.vinteres_min;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vinteres                        ='
                || pbasestecnicas.vinteres;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vtablariesgo                    ='
                || pbasestecnicas.vtablariesgo;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vtablaahorro                    ='
                || pbasestecnicas.vtablaahorro;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vgee                            ='
                || pbasestecnicas.vgee;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vgii                            ='
                || pbasestecnicas.vgii;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vgprovext                       ='
                || pbasestecnicas.vgprovext;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vgprovint                       ='
                || pbasestecnicas.vgprovint;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vgadqui                         ='
                || pbasestecnicas.vgadqui;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vgrenta                         ='
                || pbasestecnicas.vgrenta;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vfecrevi                        ='
                || TO_CHAR(pbasestecnicas.vfecrevi, 'dd/mm/yyyy');
      vtexto := vtexto || CHR(10) || CHR(13) || '  vfecrevi2                       ='
                || TO_CHAR(pbasestecnicas.vfecrevi2, 'dd/mm/yyyy');
      vtexto := vtexto || CHR(10) || CHR(13) || '  vfecvto                         ='
                || TO_CHAR(pbasestecnicas.vfecvto, 'dd/mm/yyyy');
      vtexto := vtexto || CHR(10) || CHR(13) || '  vfecvto2                        ='
                || TO_CHAR(pbasestecnicas.vfecvto2, 'dd/mm/yyyy');
      vtexto := vtexto || CHR(10) || CHR(13) || '  vfnacimi1                       ='
                || TO_CHAR(pbasestecnicas.vfnacimi1, 'dd/mm/yyyy');
      vtexto := vtexto || CHR(10) || CHR(13) || '  vsexo1                          ='
                || pbasestecnicas.vsexo1;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vfnacimi2                       ='
                || TO_CHAR(pbasestecnicas.vfnacimi2, 'dd/mm/yyyy');
      vtexto := vtexto || CHR(10) || CHR(13) || '  vsexo2                          ='
                || pbasestecnicas.vsexo2;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vpcapfall                       ='
                || pbasestecnicas.vpcapfall;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vpdoscab                        ='
                || pbasestecnicas.vpdoscab;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vicapren                        ='
                || pbasestecnicas.vicapren;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vfrevant                        ='
                || TO_CHAR(pbasestecnicas.vfrevant, 'dd/mm/yyyy');
      vtexto := vtexto || CHR(10) || CHR(13) || '  vsobremort                      ='
                || pbasestecnicas.vsobremort;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vcrevali                        ='
                || pbasestecnicas.vcrevali;
      vtexto := vtexto || CHR(10) || CHR(13) || '  virevali                        ='
                || pbasestecnicas.virevali;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vprevali                        ='
                || pbasestecnicas.vprevali;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vanyosmenos                     ='
                || pbasestecnicas.vanyosmenos;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vctipefe                        ='
                || pbasestecnicas.vctipefe;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vnrenova                        ='
                || pbasestecnicas.vnrenova;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vanyostot                       ='
                || pbasestecnicas.vanyostot;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vinteres_gast_tec               ='
                || pbasestecnicas.vinteres_gast_tec;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vinteres_gast_min               ='
                || pbasestecnicas.vinteres_gast_min;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vinteres_gast                   ='
                || pbasestecnicas.vinteres_gast;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vinteres_mens_tec               ='
                || pbasestecnicas.vinteres_mens_tec;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vinteres_mens_min               ='
                || pbasestecnicas.vinteres_mens_min;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vinteres_mens                   ='
                || pbasestecnicas.vinteres_mens;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vcclaren                        ='
                || pbasestecnicas.vcclaren;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vedadlimite                     ='
                || pbasestecnicas.vedadlimite;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vlimitegenerico                 ='
                || pbasestecnicas.vlimitegenerico;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vlimitesalud                    ='
                || pbasestecnicas.vlimitesalud;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vlimiteedad                     ='
                || pbasestecnicas.vlimiteedad;
      vtexto := vtexto || CHR(10) || CHR(13) || '  valmaxcapirisc                  ='
                || pbasestecnicas.valmaxcapirisc;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vporccapital                    ='
                || pbasestecnicas.vporccapital;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vcapitalriesgo                  ='
                || pbasestecnicas.vcapitalriesgo;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vaportacion                     ='
                || pbasestecnicas.vaportacion;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vrenta                          ='
                || pbasestecnicas.vrenta;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vforpagren                      ='
                || pbasestecnicas.vforpagren;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vcforpag                        ='
                || pbasestecnicas.vcforpag;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vfcaranu                        ='
                || pbasestecnicas.vfcaranu;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vfprimrent                      ='
                || TO_CHAR(pbasestecnicas.vfprimrent, 'dd/mm/yyyy');
      vtexto := vtexto || CHR(10) || CHR(13) || '  vedeadini1                      ='
                || pbasestecnicas.vedeadini1;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vedeadini2                      ='
                || pbasestecnicas.vedeadini2;
      vtexto := vtexto || CHR(10) || CHR(13) || '  vndurper                        ='
                || pbasestecnicas.vndurper;
      RETURN vtexto;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN NULL;   --Error al gravar la variable de contexto agente de producción.
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Error al ejecutar procedimiento o funció - vnumerr: ' || vnumerr);
         RETURN NULL;   --Error al gravar la variable de contexto agente de producción.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;   --Error al gravar la variable de contexto agente de producción.
   END f_obtener_bases_desc;

/*************************************************************************
      f_obtener_tabla_desc
      Texto con valores en palmproceso
      param in palmproceso : alm_proceso
      Retorna diferente de 0 (un código de error) en caso de error
   *************************************************************************/
   FUNCTION f_obtener_tabla_desc(palmproceso alm_proceso_det%ROWTYPE)
      RETURN VARCHAR2 IS
      vobjectname    VARCHAR2(500) := 'PAC_ALM_PROCESO.f_obtener_tabla_desc';
      vparam         VARCHAR2(500) := NULL;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vtexto         VARCHAR2(6500);
   BEGIN
      vtexto := '  SPROCES                       =' || palmproceso.sproces;
      vtexto := vtexto || CHR(10) || CHR(13) || '  FPROCES                        ='
                || TO_CHAR(palmproceso.fproces, 'dd/mm/yyyy');
      vtexto := vtexto || CHR(10) || CHR(13) || '  SSEGURO                       ='
                || palmproceso.sseguro;
      vtexto := vtexto || CHR(10) || CHR(13) || '  NRIESGO                        ='
                || palmproceso.nriesgo;
      vtexto := vtexto || CHR(10) || CHR(13) || '  FACT_ACT1                    ='
                || palmproceso.fact_act1;
      vtexto := vtexto || CHR(10) || CHR(13) || '  FACT_ACT2                     ='
                || palmproceso.fact_act2;
      vtexto := vtexto || CHR(10) || CHR(13) || '  renta                        ='
                || palmproceso.renta;
      vtexto := vtexto || CHR(10) || CHR(13) || '  APORTACION                    ='
                || palmproceso.aportacion;
      vtexto := vtexto || CHR(10) || CHR(13) || '  CAPITAL_RIESGO                    ='
                || palmproceso.capital_riesgo;
      vtexto := vtexto || CHR(10) || CHR(13) || '  INTER_TECN                            ='
                || palmproceso.inter_tecn;
      vtexto := vtexto || CHR(10) || CHR(13) || '  INTER_MIN                            ='
                || palmproceso.inter_min;
      vtexto := vtexto || CHR(10) || CHR(13) || '  INTER_DEF                       ='
                || palmproceso.inter_def;
      vtexto := vtexto || CHR(10) || CHR(13) || '  INTER_TECN_MENS                       ='
                || palmproceso.inter_tecn_mens;
      vtexto := vtexto || CHR(10) || CHR(13) || '  INTER_MIN_MENS                         ='
                || palmproceso.inter_min_mens;
      vtexto := vtexto || CHR(10) || CHR(13) || '  INTER_DEF_MENS                         ='
                || palmproceso.inter_def_mens;
      vtexto := vtexto || CHR(10) || CHR(13) || '  FPREST                        ='
                || TO_CHAR(palmproceso.fprest, 'dd/mm/yyyy');
      vtexto := vtexto || CHR(10) || CHR(13) || '  IMPBRUTOSUPERV                          ='
                || palmproceso.impbrutosuperv;
      vtexto := vtexto || CHR(10) || CHR(13) || '  IMPPROBSUPERV                          ='
                || palmproceso.impprobsuperv;
      vtexto := vtexto || CHR(10) || CHR(13) || '  IMPBRUTODEF                       ='
                || palmproceso.impbrutodef;
      vtexto := vtexto || CHR(10) || CHR(13) || '  IMPPROBDEF                        ='
                || palmproceso.impprobdef;
      vtexto := vtexto || CHR(10) || CHR(13)
                || '  IMPACUMBRUTOSUPERV                        ='
                || palmproceso.impacumbrutosuperv;
      vtexto := vtexto || CHR(10) || CHR(13) || '  IMPACUMPROBSUPERV                      ='
                || palmproceso.impacumprobsuperv;
      vtexto := vtexto || CHR(10) || CHR(13) || '  IMPACUMBRUTODEF                        ='
                || palmproceso.impacumbrutodef;
      vtexto := vtexto || CHR(10) || CHR(13) || '  IMPACUMPROBDEF                        ='
                || palmproceso.impacumprobdef;
      vtexto := vtexto || CHR(10) || CHR(13) || '  IMPBRUTOSUPERVACT                        ='
                || palmproceso.impbrutosupervact;
      vtexto := vtexto || CHR(10) || CHR(13) || '  IMPPROBSUPERVACT                     ='
                || palmproceso.impprobsupervact;
      vtexto := vtexto || CHR(10) || CHR(13) || '  IMPBRUTODEFACT                        ='
                || palmproceso.impbrutodefact;
      vtexto := vtexto || CHR(10) || CHR(13) || '  IMPPROBDEFACT                        ='
                || palmproceso.impprobdefact;
      vtexto := vtexto || CHR(10) || CHR(13)
                || '  IMPACUMBRUTOSUPERVACT                       ='
                || palmproceso.impacumbrutosupervact;
      vtexto := vtexto || CHR(10) || CHR(13) || '  IMPACUMPROBSUPERVACT               ='
                || palmproceso.impacumprobsupervact;
      vtexto := vtexto || CHR(10) || CHR(13) || '  IMPACUMBRUTODEFACT               ='
                || palmproceso.impacumbrutodefact;
      vtexto := vtexto || CHR(10) || CHR(13) || '  IMPACUMPROBDEFACT                   ='
                || palmproceso.impacumprobdefact;
      vtexto := vtexto || CHR(10) || CHR(13) || '  GASTOBRUTO               ='
                || palmproceso.gastobruto;
      vtexto := vtexto || CHR(10) || CHR(13) || '  APORTACION_ACUM               ='
                || palmproceso.aportacion_acum;
      vtexto := vtexto || CHR(10) || CHR(13) || '  RENTA_ACUM               ='
                || palmproceso.renta_acum;
      vtexto := vtexto || CHR(10) || CHR(13) || '  PROGRESION_PRIMA               ='
                || palmproceso.progresion_prima;
      vtexto := vtexto || CHR(10) || CHR(13) || '  PROGRESION_RENTA                   ='
                || palmproceso.progresion_renta;
      vtexto := vtexto || CHR(10) || CHR(13) || '  PX                        ='
                || palmproceso.px;
      vtexto := vtexto || CHR(10) || CHR(13) || '  MFINX                     ='
                || palmproceso.mfinx;
--   vtexto:=   vtexto||chr(10)||chr(13)||     '  vlimitegenerico                 ='||palmproceso.vlimitegenerico                   ;
--vtexto:=   vtexto||chr(10)||chr(13)||       '  vlimitesalud                    ='||palmproceso.vlimitesalud                      ;
--   vtexto:=   vtexto||chr(10)||chr(13)||     '  vlimiteedad                     ='||palmproceso.vlimiteedad                       ;
--vtexto:=   vtexto||chr(10)||chr(13)||       '  valmaxcapirisc                  ='||palmproceso.valmaxcapirisc                    ;
--  vtexto:=   vtexto||chr(10)||chr(13)||      '  vporccapital                    ='||palmproceso.vporccapital                   ;
--vtexto:=   vtexto||chr(10)||chr(13)||       '  vcapitalriesgo                  ='||palmproceso.vcapitalriesgo                 ;
--   vtexto:=   vtexto||chr(10)||chr(13)||     '  vaportacion                     ='||palmproceso.vaportacion                    ;
--vtexto:=   vtexto||chr(10)||chr(13)||       '  vrenta                          ='||palmproceso.vrenta                         ;
--  vtexto:=   vtexto||chr(10)||chr(13)||      '  vforpagren                      ='||palmproceso.vforpagren                     ;
--vtexto:=   vtexto||chr(10)||chr(13)||       '  vcforpag                        ='||palmproceso.vcforpag                       ;
--    vtexto:=   vtexto||chr(10)||chr(13)||    '  vfcaranu                        ='||palmproceso.vfcaranu                       ;
--vtexto:=   vtexto||chr(10)||chr(13)||       '  vfprimrent                      ='||to_char(palmproceso.vfprimrent,'dd/mm/yyyy')                            ;
--   vtexto:=   vtexto||chr(10)||chr(13)||     '  vedeadini1                      ='||palmproceso.vedeadini1                     ;
--vtexto:=   vtexto||chr(10)||chr(13)||       '  vedeadini2                      ='||palmproceso.vedeadini2                     ;
--  vtexto:=   vtexto||chr(10)||chr(13)||      '  vndurper                        ='||palmproceso.vndurper                       ;
      RETURN vtexto;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN NULL;   --Error al gravar la variable de contexto agente de producción.
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Error al ejecutar procedimiento o funció - vnumerr: ' || vnumerr);
         RETURN NULL;   --Error al gravar la variable de contexto agente de producción.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;   --Error al gravar la variable de contexto agente de producción.
   END f_obtener_tabla_desc;

/*************************************************************************
      f_obtener_cap_risc
      Obtiene el capital de riesgo
      param in t_basestecnicas : tipo t_basestecnicas
      Retorna diferente de 0 (un código de error) en caso de error
   *************************************************************************/
   FUNCTION f_obtener_cap_risc(
      pbasestecnicas IN OUT NOCOPY t_basestecnicas,
      palmreg_ant IN alm_proceso_det%ROWTYPE)
      --FUNCTION f_obtener_cap_risc(pssegro in number)--pbasestecnicas IN OUT t_basestecnicas)
   RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_ALM_PROCESO.f_obtener_cap_risc';
      vparam         VARCHAR2(500) := NULL;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vestadosalud   NUMBER := 1;
      vsobreprim     NUMBER;
      vsobreprim0    NUMBER;
      vsobreprim1    NUMBER;
      vimporteprorratacum NUMBER;
      vlimitecapital NUMBER;
      vedad          NUMBER;
      vaportcons     NUMBER;
      vpm_anterior   NUMBER;
      vtasa          NUMBER;
      vinteres_mensual NUMBER;
   BEGIN
      IF pbasestecnicas.vesrenta THEN
         pbasestecnicas.vcapitalriesgo := pbasestecnicas.vicapren * pbasestecnicas.vpcapfall
                                          / 100;
         vpasexec := 1;

         IF NVL(pbasestecnicas.vctipren, 0) = 0 THEN   --HI (renta diferida)
            IF pbasestecnicas.vfechaprest < pbasestecnicas.vfproxrent THEN
               pbasestecnicas.vcapitalriesgo := 0;
            END IF;
         END IF;
      ELSE
         vedad := (TO_CHAR(pbasestecnicas.vfechaprest, 'YYYYMMDD')
                   - TO_CHAR(pbasestecnicas.vfnacimi1, 'YYYYMMDD'))
                  / 10000;
         pbasestecnicas.vcapitalriesgo := 0;
         vsobreprim := 1;
         vsobreprim0 := 1;
         vsobreprim1 := 1;
         vpasexec := 2;

         IF vestadosalud = 0 THEN
            vlimitecapital := pbasestecnicas.vlimitesalud;
            vsobreprim := vsobreprim0;
         ELSE
            vlimitecapital := pbasestecnicas.vlimitegenerico;
            vsobreprim := vsobreprim1;
         END IF;

         vpasexec := 3;

         IF vedad < pbasestecnicas.vedadlimite THEN
            vlimitecapital := vlimitecapital;
         ELSE
            vlimitecapital := pbasestecnicas.vlimiteedad;
         END IF;

         vpasexec := 4;

         IF NVL(pbasestecnicas.vcramo, 2) = 80
            AND NVL(pbasestecnicas.vcmodali, 0) = 3 THEN
            vlimitecapital := vlimitecapital
                              * POWER((1 /(1 + pbasestecnicas.vinteres_gast)),(1 / 12));
         END IF;

         vpasexec := 5;
         vaportcons := pbasestecnicas.vaportacion
                       *(1 -(pbasestecnicas.vgee / 100) -(pbasestecnicas.vgii / 100)
                         -(pbasestecnicas.vgadqui / 100));
         vaportcons := vaportcons * pbasestecnicas.vpagaprima;

         IF pbasestecnicas.vcramo = 80
            AND pbasestecnicas.vcmodali IN(1, 2) THEN   --JRH ??????
            vaportcons := 0;
         END IF;

         --DBMS_OUTPUT.put_line('vaportcons:' || vaportcons);
         vpm_anterior := NVL(pbasestecnicas.vultsaldo, 0);
         vimporteprorratacum := (vpm_anterior + vaportcons)
--                      + vaportextini
--                        *((32 - 1) / 31)   --JRH No debe prorratear la aprot. extraordinaria
--                      + 0 *((32 - vdiaaportsup) / 31))
                                *(pbasestecnicas.vporccapital / 100);
         vpasexec := 6;

         --   dbms_output.put_line('pbasestecnicas.vporccapital:'||pbasestecnicas.vporccapital);
         IF NVL(pbasestecnicas.vcramo, 2) = 80
            AND NVL(pbasestecnicas.vcmodali, 0) = 3 THEN
            --dbms_output.put_line(to_char(  1+((vcoef2-vcoef1)/vcoef1) )); tb
            BEGIN
               vimporteprorratacum :=
                  vimporteprorratacum
                  * POWER((1
                           +((pbasestecnicas.vconmur(pbasestecnicas.vnummes + 12).vlxi
                              - pbasestecnicas.vconmur(pbasestecnicas.vnummes).vlxi)
                             / pbasestecnicas.vconmur(pbasestecnicas.vnummes).vlxi)),
                          (1 / 12));
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         END IF;

         vpasexec := 7;

         BEGIN
            vtasa := 1
                     - POWER(pbasestecnicas.vconmur(pbasestecnicas.vnummes + 12).vlxi
                             / pbasestecnicas.vconmur(pbasestecnicas.vnummes).vlxi,
                             (1 / 12));
         EXCEPTION
            WHEN OTHERS THEN
               vtasa := 0;
         END;

         IF vimporteprorratacum > NVL(vlimitecapital, 0) THEN
            vimporteprorratacum := NVL(vlimitecapital, 0);
         END IF;

         IF pbasestecnicas.valmaxcapirisc = 0 THEN
            NULL;
         ELSE
            IF vimporteprorratacum > pbasestecnicas.valmaxcapirisc THEN
               vimporteprorratacum := 0;   --Si superamos el valor máximo ya no lo tenenos en cuenta
            ELSE
               vimporteprorratacum := pbasestecnicas.valmaxcapirisc - vimporteprorratacum;
            END IF;
         END IF;

         vpasexec := 8;
         pbasestecnicas.vcapitalriesgo := vimporteprorratacum;
         vimporteprorratacum := vimporteprorratacum * NVL(vtasa, 0);
         vinteres_mensual := pbasestecnicas.vinteres_mens;   --ROUND(POWER((1 + pbasestecnicas.vinteres_gast),(1 / 12)) - 1, 6);
         pbasestecnicas.vultsaldo := (vpm_anterior + vaportcons - vimporteprorratacum)
                                     *(1 + vinteres_mensual);
--         DBMS_OUTPUT.put_line('pbasestecnicas.vultsaldo:' || pbasestecnicas.vultsaldo
--                              || '   pbasestecnicas.vcapitalriesgo:'
--                              || pbasestecnicas.vcapitalriesgo || ' vimporteprorratacum:'
--                              || vimporteprorratacum);
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 1000005;   --Error al gravar la variable de contexto agente de producción.
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Error al ejecutar procedimiento o funció - vnumerr: ' || vnumerr);
         RETURN 1000006;   --Error al gravar la variable de contexto agente de producción.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000001;   --Error al gravar la variable de contexto agente de producción.
   END f_obtener_cap_risc;

/*************************************************************************
      f_obtener_cap_risc
      Obtiene el capital de riesgo
      param in out t_basestecnicas : tipo t_basestecnicas
       param in out t_palmreg_ant : tipo alm_proceso anterior
       Retorna diferente de 0 (un código de error) en caso de error
   *************************************************************************/
   FUNCTION f_inicializar_mes_poliza(
      pbasestecnicas IN OUT NOCOPY t_basestecnicas,
      palmreg_ant IN alm_proceso_det%ROWTYPE)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_ALM_PROCESO.f_inicializar_mes_poliza';
      vparam         VARCHAR2(500) := NULL;   --SUBSTR(f_obtener_bases_desc(pbasestecnicas), 1, 480);
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vprog          NUMBER;
      vnum           NUMBER;
      vmesprimerpago NUMBER;
      vmesactual     NUMBER;
      vcad           VARCHAR2(20);
      vdiaprest      VARCHAR2(20);
      vfecha         DATE;
      vcount         NUMBER;
   BEGIN
      --DBMS_OUTPUT.put_line('f_inicializar_mes_poliza_1' || medir_tiempo);
      IF pbasestecnicas.vsseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      pbasestecnicas.vfechaprest := ADD_MONTHS(pbasestecnicas.vfecproc,
                                               pbasestecnicas.vnummes - 1);
      vpasexec := 2;

      IF pbasestecnicas.vesrenta THEN
--
         NULL;
--         IF pbasestecnicas.vesrentairreg THEN
--            SELECT pk_rentas.f_valida_date
--                      (LPAD
--                          (DECODE
--                              (
--                               -- Ini Bug 16830 - SRA - 26/11/2010
--                               NVL(pac_preguntas.ff_buscapregunseg(pbasestecnicas.vsseguro, 1,
--                                                                   9004, NULL, NULL),
--                                   f_parproductos_v(pbasestecnicas.vsproduc, 'DIAPAGORENTA')),
--                               NULL, 1,
--                               0, 1,
--                               NVL(pac_preguntas.ff_buscapregunseg(pbasestecnicas.vsseguro, 1,
--                                                                   9004, NULL, NULL),
--                                   f_parproductos_v(pbasestecnicas.vsproduc, 'DIAPAGORENTA'))),
--
--                           -- FiN Bug 16830 - SRA - 26/11/2010
--                           2, '0'))
--              INTO pbasestecnicas.vfechaprest
--              FROM DUAL;
--         ELSE
--            BEGIN
--               vfecha := pbasestecnicas.vfechaprest;
--               vcad := TO_CHAR(pbasestecnicas.vfechaprest, 'MMYYYY');
--               vdiaprest := LPAD(TO_CHAR(pbasestecnicas.vfproxrent, 'DD'), 2, '0');
--               pbasestecnicas.vfechaprest := TO_DATE(vdiaprest || '/' || vcad, 'dd/mm/yyyy');
--               pbasestecnicas.vfechaprest := pk_rentas.f_valida_date(vdiaprest || vcad);
--            EXCEPTION
--               WHEN OTHERS THEN
--                  pbasestecnicas.vfechaprest := LAST_DAY(vfecha);
--            END;
--         END IF;
      END IF;

      --Progresiones

      --De renta
      vprog := 0;

      IF pbasestecnicas.vesrenta THEN
         vnum := FLOOR(MONTHS_BETWEEN(pbasestecnicas.vfechaprest, pbasestecnicas.vfprimrent)
                       / 12);
         vprog := POWER(1 +(NVL(pbasestecnicas.vprevali, 0) / 100), vnum)
                  + vnum *(NVL(pbasestecnicas.virevali, 0) / pbasestecnicas.vrentainifija);
      ELSE
         NULL;
      END IF;

      pbasestecnicas.vprogresionrenta := vprog;
      --De prima  y pago en prima única
      vprog := 0;
      vpasexec := 4;
      pbasestecnicas.vpagaprima := 0;

      IF pbasestecnicas.vcforpag = 0 THEN
         IF TO_CHAR(pbasestecnicas.vfechaprest, 'MMYYYY') =
                                                    TO_CHAR(pbasestecnicas.vefecpol, 'MMYYYY') THEN
            pbasestecnicas.vaportacion := pbasestecnicas.vaportacioninifija;
            pbasestecnicas.vpagaprima := 1;
            vprog := 1;
         END IF;
      ELSE
         IF pbasestecnicas.vfcaranu IS NOT NULL THEN
            IF pbasestecnicas.vfechaprest >= pbasestecnicas.vfcaranu THEN
               NULL;
               vnum := FLOOR(MONTHS_BETWEEN(pbasestecnicas.vfechaprest,
                                            pbasestecnicas.vfcaranu)
                             / 12);
               vprog := POWER(1 +(NVL(pbasestecnicas.vprevali, 0) / 100), vnum)
                        + vnum
                          *(NVL(pbasestecnicas.virevali, 0) / pbasestecnicas.vaportacioninifija);
               pbasestecnicas.vaportacion := pbasestecnicas.vaportacionfija * vprog;

               IF NVL(pbasestecnicas.virevali, 0) <> 0 THEN
                  pbasestecnicas.vaportacion := pbasestecnicas.vaportacionfija
                                                + vnum * NVL(pbasestecnicas.virevali, 0);
               END IF;
            ELSE
               vprog := 1;
            END IF;
         END IF;
      END IF;

      vpasexec := 5;
      pbasestecnicas.vprogresionprima := vprog;

      --Fecha revision
      IF pbasestecnicas.vfechaprest < pbasestecnicas.vfecrevi2 THEN
         pbasestecnicas.vinteres := pbasestecnicas.vinteres_tec;
         pbasestecnicas.vinteres_gast := pbasestecnicas.vinteres_gast_tec;
         pbasestecnicas.vinteres_mens := pbasestecnicas.vinteres_mens_tec;
         pbasestecnicas.vrenta := pbasestecnicas.vprogresionrenta
                                  * pbasestecnicas.vrentamaxfija;
         pbasestecnicas.vrentamin := pbasestecnicas.vprogresionrenta
                                     * pbasestecnicas.vrentaminfija;
      ELSE
         pbasestecnicas.vinteres := pbasestecnicas.vinteres_min;
         pbasestecnicas.vinteres_gast := pbasestecnicas.vinteres_gast_min;
         pbasestecnicas.vinteres_mens := pbasestecnicas.vinteres_mens_min;
         pbasestecnicas.vrenta := pbasestecnicas.vprogresionrenta
                                  * pbasestecnicas.vrentaminfija;   --La renta mínima
         pbasestecnicas.vrentamin := pbasestecnicas.vprogresionrenta
                                     * pbasestecnicas.vrentaminfija;
      END IF;

      --Tiempos
      --dbms_output.put_line('pbasestecnicas.vprogresionprima:'||pbasestecnicas.vprogresionprima||' vprog:'||vprog||' pbasestecnicas.vfechaprest:'||pbasestecnicas.vfechaprest||' pbasestecnicas.vfcaranu:'||pbasestecnicas.vfcaranu);
      pbasestecnicas.vtiemp := MONTHS_BETWEEN(pbasestecnicas.vfechaprest,
                                              pbasestecnicas.vfecproc);   -- + 1;
      pbasestecnicas.vtiempmax := MONTHS_BETWEEN(pbasestecnicas.vfechaprest,
                                                 pbasestecnicas.vfecproc);   -- pbasestecnicas.vfechaprest - pbasestecnicas.vfecproc + 1;

      IF pbasestecnicas.vfechaprest > pbasestecnicas.vfecrevi2 THEN
         pbasestecnicas.vtiempmax := MONTHS_BETWEEN(pbasestecnicas.vfecrevi2,
                                                    pbasestecnicas.vfecproc);   --pbasestecnicas.vfecrevi2 - pbasestecnicas.vfecproc + 1;
      END IF;

      IF pbasestecnicas.vfechaprest <= pbasestecnicas.vfecrevi2 THEN
         pbasestecnicas.vtiempmin := 0;
      ELSE
         pbasestecnicas.vtiempmin := MONTHS_BETWEEN(pbasestecnicas.vfechaprest,
                                                    pbasestecnicas.vfecrevi2);   --pbasestecnicas.vfechaprest - pbasestecnicas.vfecrevi2;   --+ 1;
      END IF;

      --Indicador de si paga renta/Irregulares
      vpasexec := 6;
      pbasestecnicas.vpagarenta := 1;

      IF pbasestecnicas.vesrenta THEN
         vmesprimerpago := TO_NUMBER(TO_CHAR(pbasestecnicas.vfproxrent, 'MM'));
         vmesactual := TO_NUMBER(TO_CHAR(pbasestecnicas.vfechaprest, 'MM'));
         vpasexec := 7;

         IF MOD(vmesprimerpago - vmesactual,(12 / pbasestecnicas.vforpagren)) <> 0 THEN
            pbasestecnicas.vpagarenta := 0;
         END IF;
      ELSE
         pbasestecnicas.vpagarenta := 0;
      END IF;

      IF pbasestecnicas.vesrenta THEN
         IF NVL(pbasestecnicas.vctipren, 0) = 0 THEN   --HI (renta diferida)
            IF pbasestecnicas.vfechaprest < pbasestecnicas.vfproxrent THEN
               pbasestecnicas.vpagarenta := 0;
            END IF;
         END IF;

         IF pbasestecnicas.vesrentairreg THEN
            BEGIN
               SELECT importe
                 INTO vcount
                 FROM planrentasirreg
                WHERE planrentasirreg.sseguro = pbasestecnicas.vsseguro
                  AND planrentasirreg.mes = TO_NUMBER(TO_CHAR(pbasestecnicas.vfechaprest, 'MM'))
                  AND planrentasirreg.anyo = TO_NUMBER(TO_CHAR(pbasestecnicas.vfechaprest,
                                                               'YYYY'));

               pbasestecnicas.vrenta := vcount;
               pbasestecnicas.vrentamin := vcount;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  pbasestecnicas.vpagarenta := 0;
            END;
         END IF;
      END IF;

      --Anualidad Poliza. Indicador si paga prima.
      pbasestecnicas.vanualidad := 0;

      IF NOT pbasestecnicas.vesrenta
         AND pbasestecnicas.vcforpag <> 0 THEN
         vmesprimerpago := TO_NUMBER(TO_CHAR(pbasestecnicas.vfcaranu, 'MM'));
         vmesactual := TO_NUMBER(TO_CHAR(pbasestecnicas.vfechaprest, 'MM'));
         vpasexec := 8;
         pbasestecnicas.vanualidad := FLOOR(MONTHS_BETWEEN(pbasestecnicas.vfechaprest,
                                                           pbasestecnicas.vfcaranu)
                                            / 12)
                                      + 1;

         IF MOD(vmesprimerpago - vmesactual,(12 / pbasestecnicas.vcforpag)) <> 0 THEN
            pbasestecnicas.vpagaprima := 0;
         ELSE
            pbasestecnicas.vpagaprima := 1;
         END IF;
      ELSE
         --pbasestecnicas.vpagaprima := 0;
         NULL;   --Controlado antes
      END IF;

      vpasexec := 9;
      -- DBMS_OUTPUT.put_line('f_inicializar_mes_poliza_2' || medir_tiempo);
      vnumerr := pac_alm_proceso.f_obtener_cap_risc(pbasestecnicas, palmreg_ant);
      vpasexec := 10;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

--DBMS_OUTPUT.put_line('f_inicializar_mes_poliza_3' || medir_tiempo);
      vpasexec := 20;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 1000005;   --Error al gravar la variable de contexto agente de producción.
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Error al ejecutar procedimiento o funció - vnumerr: ' || vnumerr);
         RETURN 1000006;   --Error al gravar la variable de contexto agente de producción.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000001;   --Error al gravar la variable de contexto agente de producción.
   END f_inicializar_mes_poliza;

/*************************************************************************
      f_obtener_mes_alm_poliza
      Obtiene una varaiable tipo palm (registro de la tabla ALM)
      param in out pbasestecnicas : variable tipo basestecnicas
      param in  palmreg_ant : variable tipo alm_proceso
      param  out palm : variable tipo palm
      Retorna diferente de 0 (un código de error) en caso de error
   *************************************************************************/
   FUNCTION f_obtener_mes_alm_poliza(
      psproces IN NUMBER,
      pbasestecnicas IN OUT NOCOPY t_basestecnicas,
      palmreg_ant IN alm_proceso_det%ROWTYPE,
      palm OUT alm_proceso_det%ROWTYPE)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_ALM_PROCESO.f_obtener_mes_alm_poliza';
      vparam         VARCHAR2(500) := NULL;   --SUBSTR(f_obtener_bases_desc(pbasestecnicas), 1, 480);
      vpasexec       NUMBER(5) := 0;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF pbasestecnicas.vsseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      --DBMS_OUTPUT.put_line('obt___mes_alm_1' || medir_tiempo);
      vpasexec := 1;
      vnumerr := f_inicializar_mes_poliza(pbasestecnicas, palmreg_ant);
      vpasexec := 2;

      --DBMS_OUTPUT.put_line('obt___mes_alm_2' || medir_tiempo);
      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      palm.sproces := psproces;
      palm.fproces := pbasestecnicas.vfecprocreal;
      palm.nmes := pbasestecnicas.vnummes;
      palm.anualidad := pbasestecnicas.vanualidad;
      palm.sseguro := pbasestecnicas.vsseguro;
      palm.cmodali := pbasestecnicas.vcmodali;
      palm.ccolect := pbasestecnicas.vccolect;
      palm.ctipseg := pbasestecnicas.vctipseg;
      palm.cramo := pbasestecnicas.vcramo;
      palm.sproduc := pbasestecnicas.vsproduc;
      palm.nriesgo := NVL(pbasestecnicas.vnriesgo, 1);
      palm.npoliza := pbasestecnicas.vnpoliza;
      palm.fprest := pbasestecnicas.vfechaprest;
      palm.tiemp := pbasestecnicas.vtiemp;
      palm.tiempmax := pbasestecnicas.vtiempmax;
      palm.tiempmin := pbasestecnicas.vtiempmin;
      palm.fecvtoref := pbasestecnicas.vfecfinal;

      IF pbasestecnicas.vesrenta THEN   --La prestación
         palm.renta := pbasestecnicas.vpagarenta * pbasestecnicas.vrenta;
         palm.renta_min := pbasestecnicas.vpagarenta * pbasestecnicas.vrentamin;

         IF INSTR('|' || pbasestecnicas.vpagasextra || '|',
                  '|' || TRIM(LEADING '0' FROM TO_CHAR(pbasestecnicas.vfechaprest, 'MM'))
                  || '|') <> 0 THEN
            palm.renta := 2 * pbasestecnicas.vrenta;
            palm.renta_min := 2 * pbasestecnicas.vrentamin;
         END IF;

         IF TO_CHAR(palm.fecvtoref, 'MMYYYY') = TO_CHAR(pbasestecnicas.vfechaprest, 'MMYYYY') THEN   --Le enchufamos la prov. a fecha de revicion
            IF NVL(pbasestecnicas.vcclaren, 0) <> 0
               AND pbasestecnicas.vfecrevi IS NULL THEN   --JRH En renta temporal no
               NULL;
            ELSE
               palm.renta := pbasestecnicas.vprovfecrevi;
               palm.renta_min := pbasestecnicas.vprovfecrevi;
            END IF;
         END IF;
      ELSE
--         IF TO_CHAR(pbasestecnicas.vfechaprest, 'MMYYYY') =
--                       TO_CHAR(NVL(pbasestecnicas.vfecvto, pbasestecnicas.vfecvto2), 'MMYYYY') THEN
--            palm.renta := pbasestecnicas.vultcapgar;
--            palm.renta_min := pbasestecnicas.vultcapgar;
--         ELSE
--            palm.renta := 0;
--            palm.renta_min := 0;
--         END IF;
         IF TO_CHAR(palm.fecvtoref, 'MMYYYY') = TO_CHAR(pbasestecnicas.vfechaprest, 'MMYYYY') THEN
            --palm.renta := pbasestecnicas.vprovfecrevi;
            --palm.renta_min := pbasestecnicas.vprovfecrevi;
            palm.renta := pbasestecnicas.vprovfecrevi;
            palm.renta_min := pbasestecnicas.vprovfecrevi;
         ELSE
            palm.renta := 0;
            palm.renta_min := 0;
         END IF;
      END IF;

      palm.renta_acum := NVL(palmreg_ant.renta_acum, 0) + palm.renta;
      palm.rentamin_acum := NVL(palmreg_ant.rentamin_acum, 0) + palm.renta_min;
      palm.aportacion := pbasestecnicas.vpagaprima * pbasestecnicas.vaportacion;
      palm.aportacion_acum := NVL(palmreg_ant.aportacion_acum, 0) + palm.aportacion;
      palm.capital_riesgo := pbasestecnicas.vcapitalriesgo;
      palm.inter_tecn := pbasestecnicas.vinteres_tec;
      palm.inter_min := pbasestecnicas.vinteres_min;
      palm.inter_def := pbasestecnicas.vinteres;
      palm.inter_tecn_mens := pbasestecnicas.vinteres_mens_tec;
      palm.inter_min_mens := pbasestecnicas.vinteres_mens_min;
      palm.inter_def_mens := pbasestecnicas.vinteres_mens;
      palm.progresion_prima := pbasestecnicas.vprogresionprima;
      palm.progresion_renta := pbasestecnicas.vprogresionrenta;
      palm.vanyosmenos := pbasestecnicas.vanyosmenos;
      palm.sobrem := pbasestecnicas.vsobremort;
      palm.giii := pbasestecnicas.vgii;
      palm.geee := pbasestecnicas.vgee;
      palm.gadquis := pbasestecnicas.vgadqui;
      palm.gprovint := pbasestecnicas.vgprovint;
      palm.gprovext := pbasestecnicas.vgprovext;
      palm.grenta := pbasestecnicas.vgrenta;
      palm.edad1 := pbasestecnicas.vconmu(palm.nmes).vedadactx;
      palm.edad2 := pbasestecnicas.vconmu(palm.nmes).vedadacty;
      palm.tab_ries := pbasestecnicas.vtablaahorro;
      palm.tab_aho := pbasestecnicas.vtablariesgo;
      palm.fact_act1 := POWER((1 + palm.inter_min_mens), -palm.tiemp - 0)
                        * POWER((1 + pbasestecnicas.vinteremindia), -1);
      palm.fact_act2 := POWER((1 + palm.inter_tecn_mens), -palm.tiempmax - 0)
                        * POWER((1 + palm.inter_min_mens), -palm.tiempmin - 0)
                        * POWER((1 + pbasestecnicas.vinteresdia), -1);
      --parte ahorro
      palm.lx0 := pbasestecnicas.vconmu(1).vlxi;

      IF NVL(pbasestecnicas.vsexo2, 0) <> 0 THEN
         palm.ly0 := pbasestecnicas.vconmu(1).vlyi;
      ELSE
         palm.ly0 := 1;
      END IF;

      palm.lxy0 := palm.lx0 * palm.ly0;
      palm.lx := pbasestecnicas.vconmu(palm.nmes).vlxi;

      IF NVL(pbasestecnicas.vsexo2, 0) <> 0 THEN
         palm.ly := pbasestecnicas.vconmu(palm.nmes).vlyi;
      ELSE
         palm.ly := 0;
      END IF;

      palm.lxy := palm.lx * palm.ly;
      palm.lx1 := pbasestecnicas.vconmu(palm.nmes).vlxi1;

      IF NVL(pbasestecnicas.vsexo2, 0) <> 0 THEN
         palm.ly1 := pbasestecnicas.vconmu(palm.nmes).vlyi1;
      ELSE
         palm.ly1 := 0;
      END IF;

      palm.lxy1 := palm.lx1 * palm.ly1;
      palm.mx := pbasestecnicas.vconmu(palm.nmes).vmx;
      palm.my := pbasestecnicas.vconmu(palm.nmes).vmy;
      palm.mxy := pbasestecnicas.vconmu(palm.nmes).vmxy;
      palm.px :=((palm.lx / palm.lx0)
                 + (NVL(pbasestecnicas.vpdoscab, 0) / 100)
                   *((palm.ly / palm.ly0) -((palm.lx * palm.ly) /(palm.lx0 * palm.ly0))));
      --palm.mfinx := palm.mx + pbasestecnicas.vpdoscab *(palm.my - palm.mxy);
      palm.mfinx :=(((palm.lx - palm.lx1) / palm.lx0)
                    + (NVL(pbasestecnicas.vpdoscab, 0) / 100)
                      *(((palm.ly - palm.ly1) / palm.ly0)
                        -((palm.lx * palm.ly - palm.lx1 * palm.ly1) /(palm.lx0 * palm.ly0))));
      --parte riesgo
      palm.lx0r := pbasestecnicas.vconmur(1).vlxi;

      IF NVL(pbasestecnicas.vsexo2, 0) <> 0 THEN
         palm.ly0r := pbasestecnicas.vconmur(1).vlyi;
      ELSE
         palm.ly0r := 1;
      END IF;

      palm.lxy0r := palm.lx0r * palm.ly0r;
      palm.lxr := pbasestecnicas.vconmur(palm.nmes).vlxi;

      IF NVL(pbasestecnicas.vsexo2, 0) <> 0 THEN
         palm.lyr := pbasestecnicas.vconmur(palm.nmes).vlyi;
      ELSE
         palm.lyr := 0;
      END IF;

      palm.lxyr := palm.lxr * palm.lyr;
      palm.lx1r := pbasestecnicas.vconmur(palm.nmes).vlxi1;

      IF NVL(pbasestecnicas.vsexo2, 0) <> 0 THEN
         palm.ly1r := pbasestecnicas.vconmur(palm.nmes).vlyi1;
      ELSE
         palm.ly1r := 0;
      END IF;

      palm.lxy1r := palm.lx1r * palm.ly1r;
      palm.mxr := pbasestecnicas.vconmur(palm.nmes).vmx;
      palm.myr := pbasestecnicas.vconmur(palm.nmes).vmy;
      palm.mxyr := pbasestecnicas.vconmur(palm.nmes).vmxy;
      palm.pxr :=((palm.lxr / palm.lx0r)
                  + (NVL(pbasestecnicas.vpdoscab, 0) / 100)
                    *((palm.lyr / palm.ly0r) -((palm.lxr * palm.lyr) /(palm.lx0r * palm.ly0r))));
      --palm.mfinx := palm.mx + pbasestecnicas.vpdoscab *(palm.my - palm.mxy);
      palm.mfinxr :=(((palm.lxr - palm.lx1r) / palm.lx0r)
                     + (NVL(pbasestecnicas.vpdoscab, 0) / 100)
                       *(((palm.lyr - palm.ly1r) / palm.ly0r)
                         -((palm.lxr * palm.lyr - palm.lx1r * palm.ly1r)
                           /(palm.lx0r * palm.ly0r))));
--pac_Conmutadors

      --Importes brutos
      palm.impbrutosuperv := palm.renta_min;
      palm.impbrutosuperv2 := palm.renta;
      palm.impbrutodef := palm.capital_riesgo;
      palm.gastobruto := palm.impbrutosuperv
                         *((1 +(palm.grenta / 100)) /(1 -(palm.giii / 100)) - 1);
      palm.gastobruto2 := palm.impbrutosuperv2
                          *((1 +(palm.grenta / 100)) /(1 -(palm.giii / 100)) - 1);
      palm.gastobrutories := palm.impbrutodef *(1 /(1 -(palm.giii / 100)) - 1);

      IF   --pbasestecnicas.vesrenta   --Para este caso si que cambia
         -- AND
         palm.fecvtoref IS NOT NULL THEN
         IF TO_CHAR(palm.fecvtoref, 'MMYYYY') = TO_CHAR(pbasestecnicas.vfechaprest, 'MMYYYY') THEN
            palm.capital_riesgo := 0;
            palm.impbrutodef := 0;
            palm.gastobruto2 := 0;
            palm.gastobrutories := 0;
         END IF;
      END IF;

--Importes brutos acumulados
      palm.impacumbrutosuperv := NVL(palmreg_ant.impacumbrutosuperv, 0) + palm.impbrutosuperv;
      palm.impacumbrutosuperv2 := NVL(palmreg_ant.impacumbrutosuperv2, 0)
                                  + palm.impbrutosuperv2;
      palm.impacumbrutodef := NVL(palmreg_ant.impacumbrutodef, 0) + palm.impbrutodef;
      palm.impacumgastobruto := NVL(palmreg_ant.impacumgastobruto, 0) + palm.gastobruto;
      palm.impacumgastobruto2 := NVL(palmreg_ant.impacumgastobruto2, 0) + palm.gastobruto2;
      palm.impacumgastobrutories := NVL(palmreg_ant.impacumgastobrutories, 0)
                                    + palm.gastobrutories;
--Importes brutos probabilizados
      palm.impprobsuperv := palm.impbrutosuperv * palm.px;
      palm.impprobsuperv2 := palm.impbrutosuperv2 * palm.px;
      palm.impprobdef := palm.impbrutodef * palm.mfinxr;
      palm.gastobrutoprob := palm.impprobsuperv
                             *((1 +(palm.grenta / 100)) /(1 -(palm.giii / 100)) - 1);
      palm.gastobruto2prob := palm.impprobsuperv2
                              *((1 +(palm.grenta / 100)) /(1 -(palm.giii / 100)) - 1);
      palm.gastobrutoriesprob := palm.impprobdef *(1 /(1 -(palm.giii / 100)) - 1);

      IF   --pbasestecnicas.vesrenta   --Para este caso si que cambia
           --AND pbasestecnicas.vfecrevi IS NOT NULL THEN
           --IF
         TO_CHAR(palm.fecvtoref, 'MMYYYY') = TO_CHAR(pbasestecnicas.vfechaprest, 'MMYYYY') THEN
         palm.gastobruto2prob := 0;
         palm.gastobrutoriesprob := 0;
      END IF;

      --END IF;

      --Importes brutos probabilizados acumulados
      palm.impacumprobsuperv := NVL(palmreg_ant.impacumprobsuperv, 0) + palm.impprobsuperv;
      palm.impacumprobsuperv2 := NVL(palmreg_ant.impacumprobsuperv2, 0) + palm.impprobsuperv2;
      palm.impacumprobdef := NVL(palmreg_ant.impacumprobdef, 0) + palm.impprobdef;
      palm.impacumgastobrutoprob := NVL(palmreg_ant.impacumgastobrutoprob, 0)
                                    + palm.gastobrutoprob;
      palm.impacumgastobruto2prob := NVL(palmreg_ant.impacumgastobruto2prob, 0)
                                     + palm.gastobruto2prob;
      palm.impacumgastobrutoriesprob := NVL(palmreg_ant.impacumgastobrutoriesprob, 0)
                                        + palm.gastobrutoriesprob;
--Importes brutos  actualizados
      palm.impbrutosupervact := palm.impbrutosuperv * palm.fact_act1;
      palm.impbrutosupervact2 := palm.impbrutosuperv2 * palm.fact_act2;
      palm.impbrutodefact := palm.impbrutodef * palm.fact_act1;
      palm.gastobrutoact := palm.gastobruto * palm.fact_act1;
      palm.gastobrutoact2 := palm.gastobruto2 * palm.fact_act2;
      palm.gastobrutoactries := palm.gastobrutories * palm.fact_act1;
--Importes brutos  actualizados    acumulados
      palm.impacumbrutosupervact := NVL(palmreg_ant.impacumbrutosupervact, 0)
                                    + palm.impbrutosupervact;
      palm.impacumbrutosupervact2 := NVL(palmreg_ant.impacumbrutosupervact2, 0)
                                     + palm.impbrutosupervact2;
      palm.impacumbrutodefact := NVL(palmreg_ant.impacumbrutodefact, 0) + palm.impbrutodefact;
      palm.impacumgastobrutoact := NVL(palmreg_ant.impacumgastobrutoact, 0)
                                   + palm.gastobrutoact;
      palm.impacumgastobrutoact2 := NVL(palmreg_ant.impacumgastobrutoact2, 0)
                                    + palm.gastobrutoact2;
      palm.impacumgastobrutoactries := NVL(palmreg_ant.impacumgastobrutoactries, 0)
                                       + palm.gastobrutoactries;
--Importes probabilizados  actualizados
      palm.impprobsupervact := palm.impprobsuperv * palm.fact_act1;
      palm.impprobsupervact2 := palm.impprobsuperv2 * palm.fact_act2;
      palm.impprobdefact := palm.impprobdef * palm.fact_act1;
      palm.gastobrutoprobact := palm.gastobrutoprob * palm.fact_act1;
      palm.gastobrutoprobact2 := palm.gastobruto2prob * palm.fact_act2;
      palm.gastobrutoriesprobact := palm.gastobrutoriesprob * palm.fact_act1;
--Importes probabilizados  actualizados acumulados
      palm.impacumprobsupervact := NVL(palmreg_ant.impacumprobsupervact, 0)
                                   + palm.impprobsupervact;
      palm.impacumprobsupervact2 := NVL(palmreg_ant.impacumprobsupervact2, 0)
                                    + palm.impprobsupervact2;
      palm.impacumprobdefact := NVL(palmreg_ant.impacumprobdefact, 0) + palm.impprobdefact;
      palm.impacumgastobrutoprobact := NVL(palmreg_ant.impacumgastobrutoprobact, 0)
                                       + palm.gastobrutoprobact;
      palm.impacumgastobrutoprobact2 := NVL(palmreg_ant.impacumgastobrutoprobact2, 0)
                                        + palm.gastobrutoprobact2;
      palm.impacumgastobrutoriesprobact := NVL(palmreg_ant.impacumgastobrutoriesprobact, 0)
                                           + palm.gastobrutoriesprobact;
--Provisiones
      palm.pm1 := palm.impprobsupervact + palm.gastobrutoprobact;
      palm.pm2 := palm.impprobsupervact2 + palm.gastobrutoprobact2;
      palm.pmr1 := palm.impprobdefact + palm.gastobrutoriesprobact;
      palm.pmt := palm.pm1 + palm.pmr1;
      palm.pmt2 := palm.pm2 + palm.pmr1;
      palm.impacumpm1 := NVL(palmreg_ant.impacumpm1, 0) + palm.pm1;
      palm.impacumpm2 := NVL(palmreg_ant.impacumpm2, 0) + palm.pm2;
      palm.impacumpmr1 := NVL(palmreg_ant.impacumpmr1, 0) + palm.pmr1;
      palm.impacumpmt := NVL(palmreg_ant.impacumpmt, 0) + palm.pmt;
      palm.impacumpmt2 := NVL(palmreg_ant.impacumpmt2, 0) + palm.pmt2;
      --DBMS_OUTPUT.put_line('obt___mes_alm_3' || medir_tiempo);
      vpasexec := 3;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 1000005;   --Error al gravar la variable de contexto agente de producción.
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Error al ejecutar procedimiento o funció - vnumerr: ' || vnumerr);
         RETURN 1000006;   --Error al gravar la variable de contexto agente de producción.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000001;   --Error al gravar la variable de contexto agente de producción.
   END f_obtener_mes_alm_poliza;

/*************************************************************************
      f_obtener_bastec_poliza
      Obtiene en un t_basestecnicas las bases técnicas de la póliza
      param in   pfproces : Fecha del proceso
      param in  psseguro : Sseguro
      param  out pbasestecnicas : variable tipo t_basestecnicas
      Retorna diferente de 0 (un código de error) en caso de error
   *************************************************************************/
   FUNCTION f_obtener_bastec_poliza(
      pfproces IN DATE,
      psseguro IN NUMBER,
      pbasestecnicas OUT NOCOPY t_basestecnicas)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_ALM_PROCESO.f_obtener_bastec_poliza';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro: ' || psseguro || ' - pfproces: '
            || TO_CHAR(pfproces, 'DD/MM/YYYY');
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vanyosmaxtab   NUMBER;
      vfpag          NUMBER;
      vmi            NUMBER;
      vmi2           NUMBER;
      vanyoefecto1   NUMBER;
      vanyoefecto2   NUMBER;
      vnmesextra     VARCHAR2(200) := NULL;
      vnumanys       NUMBER;
      v_antos_hasta_fecvto NUMBER;
      vfechamaxnacim DATE;
      vcount         NUMBER;
      vedadprueb1    NUMBER;
      vedadprueb2    NUMBER;
   BEGIN
      IF pfproces IS NULL
         OR psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      --DBMS_OUTPUT.put_line('obt___mes_basest_1' || medir_tiempo);
      vpasexec := 0;
      pbasestecnicas.vsseguro := psseguro;
      pbasestecnicas.vfecproc := pfproces;
      pbasestecnicas.vnummes := 0;
      pbasestecnicas.vfechaprest := NULL;
      vpasexec := 1;

      SELECT seguros.fefecto, seguros.sproduc, seguros.fvencim,
             seguros.crevali, seguros.irevali, seguros.prevali,
             productos.ctipefe, seguros.nrenova, seguros.cforpag,
             seguros.fcaranu, seguros.cramo, seguros.cmodali,
             seguros.ctipseg, seguros.ccolect, seguros.npoliza
        INTO pbasestecnicas.vefecpol, pbasestecnicas.vsproduc, pbasestecnicas.vfecvto,
             pbasestecnicas.vcrevali, pbasestecnicas.virevali, pbasestecnicas.vprevali,
             pbasestecnicas.vctipefe, pbasestecnicas.vnrenova, pbasestecnicas.vcforpag,
             pbasestecnicas.vfcaranu, pbasestecnicas.vcramo, pbasestecnicas.vcmodali,
             pbasestecnicas.vctipseg, pbasestecnicas.vccolect, pbasestecnicas.vnpoliza
        FROM seguros, productos
       WHERE sseguro = pbasestecnicas.vsseguro
         AND productos.sproduc = seguros.sproduc;

      --JRH IMP Si lanzamos a años anteriores
      IF pbasestecnicas.vfcaranu IS NOT NULL THEN
         IF pbasestecnicas.vfecproc > pbasestecnicas.vfcaranu THEN
            vnumanys := FLOOR((pbasestecnicas.vfecproc - pbasestecnicas.vfcaranu) / 365.25)
                        + 1;
            pbasestecnicas.vfcaranu := ADD_MONTHS(pbasestecnicas.vfcaranu, vnumanys * 12);
         END IF;
      END IF;

      SELECT icapital
        INTO pbasestecnicas.vaportacion
        FROM garanseg
       WHERE sseguro = pbasestecnicas.vsseguro
         AND nriesgo = 1
         AND finiefe <= pfproces
         AND((ffinefe IS NULL)
             OR(ffinefe IS NOT NULL
                AND ffinefe > pfproces))
         AND cgarant = 48;

      SELECT icapital
        INTO pbasestecnicas.vaportacioninifija
        FROM garanseg
       WHERE sseguro = pbasestecnicas.vsseguro
         AND nriesgo = 1
         AND finiefe <= pfproces
         AND nmovimi = (SELECT MIN(nmovimi)
                          FROM garanseg
                         WHERE sseguro = pbasestecnicas.vsseguro)
         AND cgarant = 48;

      BEGIN
         SELECT icapital
           INTO pbasestecnicas.vrentamin
           FROM garanseg
          WHERE sseguro = pbasestecnicas.vsseguro
            AND nriesgo = 1
            AND finiefe <= pfproces
            AND((ffinefe IS NULL)
                OR(ffinefe IS NOT NULL
                   AND ffinefe > pfproces))
            AND cgarant = 51;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pbasestecnicas.vrentamin := NULL;
      END;

      BEGIN   --JRH Se cambia más abajo, pero es por si queremos un histórico
         SELECT icapital
           INTO pbasestecnicas.vrenta
           FROM garanseg
          WHERE sseguro = pbasestecnicas.vsseguro
            AND nriesgo = 1
            AND finiefe <= pfproces
            AND((ffinefe IS NULL)
                OR(ffinefe IS NOT NULL
                   AND ffinefe > pfproces))
            AND cgarant = 52;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pbasestecnicas.vrenta := NULL;
      END;

      BEGIN   --JRH Se cambia más abajo, pero es por si queremos un histórico
         SELECT icapital
           INTO pbasestecnicas.vrentainifija
           FROM garanseg
          WHERE sseguro = pbasestecnicas.vsseguro
            AND nriesgo = 1
            AND finiefe <= pfproces
            AND nmovimi = 1
            AND cgarant = 52;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pbasestecnicas.vrenta := NULL;
      END;

      vpasexec := 2;

      BEGIN
         SELECT fnacimi, csexper
           INTO pbasestecnicas.vfnacimi1, pbasestecnicas.vsexo1
           FROM asegurados, per_personas
          WHERE asegurados.sseguro = pbasestecnicas.vsseguro
            AND asegurados.norden = 1
            AND asegurados.ffecfin IS NULL
            AND per_personas.sperson = asegurados.sperson;

         BEGIN
            SELECT fnacimi, csexper
              INTO pbasestecnicas.vfnacimi2, pbasestecnicas.vsexo2
              FROM asegurados, per_personas
             WHERE asegurados.sseguro = pbasestecnicas.vsseguro
               AND asegurados.norden = 2
               AND asegurados.ffecfin IS NULL
               AND per_personas.sperson = asegurados.sperson;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               pbasestecnicas.vfnacimi2 := NULL;
               pbasestecnicas.vsexo2 := NULL;
         END;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT fnacimi, csexper
              INTO pbasestecnicas.vfnacimi1, pbasestecnicas.vsexo1
              FROM asegurados, per_personas
             WHERE asegurados.sseguro = pbasestecnicas.vsseguro
               AND asegurados.norden = 2
               AND asegurados.ffecfin IS NULL
               AND per_personas.sperson = asegurados.sperson;

            pbasestecnicas.vfnacimi2 := NULL;
            pbasestecnicas.vsexo2 := NULL;
      END;

      vpasexec := 3;
      pbasestecnicas.vesrentairreg := FALSE;

      BEGIN
         SELECT seguros_ren.pcapfall, seguros_ren.pdoscab, producto_ren.cclaren,
                seguros_ren.ibruren, seguros_ren.cforpag, seguros_ren.f1paren,
                seguros_ren.icapren, seguros_ren.fppren, producto_ren.ctipren,
                producto_ren.nmesextra
           INTO pbasestecnicas.vpcapfall, pbasestecnicas.vpdoscab, pbasestecnicas.vcclaren,
                pbasestecnicas.vrenta, pbasestecnicas.vforpagren, pbasestecnicas.vfprimrent,
                pbasestecnicas.vicapren, pbasestecnicas.vfproxrent, pbasestecnicas.vctipren,
                pbasestecnicas.vpagasextra
           FROM seguros_ren, seguros, producto_ren
          WHERE seguros.sseguro = psseguro
            AND seguros_ren.sseguro = seguros.sseguro
            AND producto_ren.sproduc = seguros.sproduc;

         IF NVL(pbasestecnicas.vctipren, 0) = 0 THEN   --HI (renta diferida)
            IF pbasestecnicas.vfecproc < pbasestecnicas.vfproxrent THEN
               --pbasestecnicas.vfecproc := pbasestecnicas.vfproxrent;
               NULL;
            END IF;
         END IF;

         pbasestecnicas.vesrenta := TRUE;

         SELECT COUNT(*)
           INTO vcount
           FROM planrentasirreg
          WHERE sseguro = psseguro;

         IF vcount > 0 THEN
            pbasestecnicas.vesrentairreg := TRUE;
         END IF;

         pbasestecnicas.vrentamin := NVL(pbasestecnicas.vrentamin, pbasestecnicas.vrenta);   --Por si no tiene definida la garantia 51
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pbasestecnicas.vpcapfall := NULL;
            pbasestecnicas.vpdoscab := NULL;
            pbasestecnicas.vcclaren := NULL;
            pbasestecnicas.vrenta := NULL;
            pbasestecnicas.vrentamin := NULL;
            pbasestecnicas.vforpagren := NULL;
            pbasestecnicas.vfprimrent := NULL;
            pbasestecnicas.vicapren := NULL;
            pbasestecnicas.vesrenta := FALSE;
      END;

      vpasexec := 30;

      IF NOT pbasestecnicas.vesrenta THEN
         IF pbasestecnicas.vfecvto IS NULL THEN
            pbasestecnicas.vfecvto := f_fvencimcapgar(pbasestecnicas.vsseguro, 1);
         END IF;
      END IF;

      vpasexec := 4;
      pbasestecnicas.vfecvto2 := pbasestecnicas.vfecvto;
      vpasexec := 5;
      pbasestecnicas.vtablariesgo := NVL(pac_preguntas.ff_buscapregunpolseg(psseguro, 590,
                                                                            NULL),
                                         0);

      IF pbasestecnicas.vtablariesgo = 0 THEN
         pbasestecnicas.vtablariesgo :=
            NVL(f_gettramo1(pbasestecnicas.vefecpol,
                            f_gettramo1(pbasestecnicas.vefecpol, 1640,
                                        pbasestecnicas.vsproduc),
                            1),
                0);
      END IF;

      vpasexec := 6;
      pbasestecnicas.vtablaahorro := NVL(pac_preguntas.ff_buscapregunpolseg(psseguro, 590,
                                                                            NULL),
                                         0);

      IF pbasestecnicas.vtablaahorro = 0 THEN
         pbasestecnicas.vtablaahorro :=
            NVL(f_gettramo1(pbasestecnicas.vefecpol,
                            f_gettramo1(pbasestecnicas.vefecpol, 1640,
                                        pbasestecnicas.vsproduc),
                            1),
                0);
      END IF;

      vpasexec := 7;
      pbasestecnicas.vesvitalicia := FALSE;
      vanyosmaxtab := pac_conmutadors.f_anyos_maxtabla(pbasestecnicas.vtablaahorro);

      IF pbasestecnicas.vfecvto2 IS NULL THEN   --JRH IMP Si es vitalicia
         vanyosmaxtab := vanyosmaxtab + 1;
         vfechamaxnacim := GREATEST(NVL(pbasestecnicas.vfnacimi2, pbasestecnicas.vfnacimi1),
                                    pbasestecnicas.vfnacimi1);
         --DBMS_OUTPUT.put_line('hola pbasestecnicas.vfechamaxnacim:' || to_date(vfechamaxnacim,'DD/MM/YYYY'));
         pbasestecnicas.vfecvto2 :=(ADD_MONTHS(vfechamaxnacim, vanyosmaxtab * 12));
         --DBMS_OUTPUT.put_line('hola pbasestecnicas.vfecvto2:' || to_date(pbasestecnicas.vfecvto2,'DD/MM/YYYY'));
         pbasestecnicas.vesvitalicia := TRUE;
      ELSE
         pbasestecnicas.vesvitalicia := FALSE;
      END IF;

--
      vpasexec := 8;

      SELECT frevisio, frevant
        INTO pbasestecnicas.vfecrevi, pbasestecnicas.vfrevant
        FROM seguros_aho
       WHERE sseguro = pbasestecnicas.vsseguro;

      IF pbasestecnicas.vesrenta THEN
         IF NVL(pbasestecnicas.vctipren, 0) = 0 THEN   --HI (renta diferida)
            pbasestecnicas.vfecrevi := NULL;
         END IF;
      END IF;

      pbasestecnicas.vfecrevi2 := pbasestecnicas.vfecrevi;

      IF pbasestecnicas.vfecrevi2 IS NULL THEN
         pbasestecnicas.vfecrevi2 := pbasestecnicas.vfecvto2;
      ELSE
         IF pbasestecnicas.vfecrevi2 < pbasestecnicas.vfecproc THEN
            vpasexec := 91;
            RAISE e_object_error;
         END IF;
      END IF;

--JRH PARA ESTAS BASES TECNIVAS SE TENDRÍA QUE UTILIZAR EL PAC_PROPIO_BASTEC_CEM pero bueno en principio
-- no pasa nada si lo hacemos así puesto que ya en CEM no se van a hacer nuevos desarrollos ni cambios
--y las bases técnicas siempre se calcularán como a continuación.
--Pero para futuros clientes sería lo mejor , ultitlizar el PAC_PROPIO_BASTEC_aaa.
      vpasexec := 9;
      pbasestecnicas.vinteres_tec := pac_inttec.ff_int_seguro('SEG', psseguro,
                                                              NVL(pbasestecnicas.vfrevant,
                                                                  pbasestecnicas.vefecpol));
      vpasexec := 10;
      pbasestecnicas.vinteres_min := NVL(pac_preguntas.ff_buscapregunpolseg(psseguro, 595,
                                                                            NULL),
                                         0);
      vpasexec := 11;

      IF NVL(pbasestecnicas.vinteres_min, 0) = 0 THEN
         pbasestecnicas.vinteres_min := pac_inttec.ff_int_producto(pbasestecnicas.vsproduc, 1,
                                                                   pbasestecnicas.vefecpol, 0);
      END IF;

      vpasexec := 12;

      IF NVL(pbasestecnicas.vcclaren, 0) <> 0
         AND pbasestecnicas.vfecrevi IS NULL THEN   --En renta temporal sin revision los dos intereses son iguales
         pbasestecnicas.vinteres_min := pbasestecnicas.vinteres_tec;
      END IF;

      IF NOT pbasestecnicas.vesrenta THEN
         IF pbasestecnicas.vfecrevi IS NULL THEN
            pbasestecnicas.vinteres_min := pbasestecnicas.vinteres_tec;
         END IF;
      END IF;

      pbasestecnicas.vinteres := pbasestecnicas.vinteres_tec;
      vpasexec := 13;
      vpasexec := 14;
      pbasestecnicas.vgprovint := NVL(pac_preguntas.ff_buscapregunpolseg(psseguro, 565, NULL),
                                      0)
                                  / 1;
      vpasexec := 15;
      pbasestecnicas.vgee := NVL(f_gettramo1(pbasestecnicas.vefecpol,
                                             f_gettramo1(pbasestecnicas.vefecpol, 1622,
                                                         pbasestecnicas.vsproduc),
                                             1),
                                 0);
      pbasestecnicas.vgii := NVL(pac_preguntas.ff_buscapregunpolseg(psseguro, 550, NULL), 0)
                             / 1;
      vpasexec := 16;
      pbasestecnicas.vgadqui := NVL(pac_preguntas.ff_buscapregunpolseg(psseguro, 551, NULL), 0)
                                / 1;
      vpasexec := 17;
      pbasestecnicas.vgprovext := NVL(pac_preguntas.ff_buscapregunpolseg(psseguro, 591, NULL),
                                      0)
                                  / 1;
      vpasexec := 18;
      pbasestecnicas.vgrenta := NVL(pac_preguntas.ff_buscapregunpolseg(psseguro, 564, NULL), 0)
                                / 1;
      vpasexec := 19;
      pbasestecnicas.vsobremort := 0;
      vpasexec := 20;
      pbasestecnicas.vanyosmenos := 0;
      pbasestecnicas.vporccapital := NVL(f_detparproductos(pbasestecnicas.vsproduc,
                                                           'PORCAPITALRISC', 2),
                                         0)
                                     / 1;
      vpasexec := 20;
      -- Bug 8999 - RSC - 17/03/2011 (f_detparproductos --> f_parproductos_v)
      pbasestecnicas.vedadlimite := NVL(f_parproductos_v(pbasestecnicas.vsproduc,
                                                         'EDADCORTEIMMAXCAP'),
                                        0);
      -- Fin Bug 8999
      vpasexec := 21;
      pbasestecnicas.vlimitegenerico := NVL(f_detparproductos(pbasestecnicas.vsproduc,
                                                              'IMMAXCAPSIN1ASE', 2),
                                            0);
      vpasexec := 22;
      pbasestecnicas.vlimitesalud := NVL(f_detparproductos(pbasestecnicas.vsproduc,
                                                           'IMMAXCAPSIN1ASESALUD', 2),
                                         0);
      vpasexec := 23;
      pbasestecnicas.vlimiteedad := NVL(f_detparproductos(pbasestecnicas.vsproduc,
                                                          'IMMAXCAPSIN65', 2),
                                        0);
      vpasexec := 24;
      pbasestecnicas.valmaxcapirisc := NVL(f_detparproductos(pbasestecnicas.vsproduc,
                                                             'VALMAXCAPIRISC', 2),
                                           0);
      vpasexec := 25;
      pbasestecnicas.vinteres_gast_tec :=((1 +(pbasestecnicas.vinteres_tec / 100))
                                          *(1
                                            -((pbasestecnicas.vgprovext / 100)
                                              +(pbasestecnicas.vgprovint / 100)))
                                          - 1);
      pbasestecnicas.vinteres_mens_tec := ROUND(POWER((1 + pbasestecnicas.vinteres_gast_tec),
                                                      (1 / 12))
                                                - 1,
                                                8);
      pbasestecnicas.vinteresdia := ROUND(POWER((1 + pbasestecnicas.vinteres_gast_tec),
                                                (1 / 365))
                                          - 1,
                                          8);
      vpasexec := 26;
      pbasestecnicas.vinteres_gast_min :=((1 +(pbasestecnicas.vinteres_min / 100))
                                          *(1
                                            -((pbasestecnicas.vgprovext / 100)
                                              +(pbasestecnicas.vgprovint / 100)))
                                          - 1);
      vpasexec := 28;
      pbasestecnicas.vinteres_mens_min := ROUND(POWER((1 + pbasestecnicas.vinteres_gast_min),
                                                      (1 / 12))
                                                - 1,
                                                8);
      pbasestecnicas.vinteremindia := ROUND(POWER((1 + pbasestecnicas.vinteres_gast_min),
                                                  (1 / 365))
                                            - 1,
                                            8);
      vpasexec := 29;
      pbasestecnicas.vinteres_gast :=((1 +(pbasestecnicas.vinteres / 100))
                                      *(1
                                        -((pbasestecnicas.vgprovext / 100)
                                          +(pbasestecnicas.vgprovint / 100)))
                                      - 1);
      vpasexec := 30;
      pbasestecnicas.vinteres_mens := ROUND(POWER((1 + pbasestecnicas.vinteres_gast),(1 / 12))
                                            - 1,
                                            8);
--       pbasestecnicas.vndurper := TRUNC(MONTHS_BETWEEN(pbasestecnicas.vfecrevi2,
--                                           nvl(pbasestecnicas.vfrevant,pbasestecnicas.vefecpol)))
--                     / 12;
      pbasestecnicas.vndurper := TRUNC(MONTHS_BETWEEN(pbasestecnicas.vfecrevi2,
                                                      pbasestecnicas.vfecproc))
                                 / 12;
      vpasexec := 31;

      IF pbasestecnicas.vesrenta THEN
         IF pbasestecnicas.vforpagren = 0 THEN
            vfpag := 12;
         ELSE
            vfpag := pbasestecnicas.vforpagren;
         END IF;

         vmi := TO_NUMBER(TO_CHAR(pbasestecnicas.vfprimrent, 'MM'));
         vmi2 := TO_NUMBER(TO_CHAR(pbasestecnicas.vefecpol, 'MM'));
      ELSE
         IF pbasestecnicas.vcforpag = 0 THEN
            vfpag := 12;
         ELSE
            vfpag := pbasestecnicas.vcforpag;
         END IF;

         IF pbasestecnicas.vctipefe = 0 THEN
            vmi := 1;
         ELSE
            vmi := TO_NUMBER(TO_CHAR(pbasestecnicas.vefecpol, 'MM'));
         END IF;

         vmi2 := TO_NUMBER(TO_CHAR(pbasestecnicas.vefecpol, 'MM'));
      END IF;

      vpasexec := 32;
      pbasestecnicas.vedeadini1 := (pbasestecnicas.vfecproc - pbasestecnicas.vfnacimi1)
                                   / 365.25;
      pbasestecnicas.vedeadini2 := (pbasestecnicas.vfecproc - pbasestecnicas.vfnacimi2)
                                   / 365.25;
      --vedadprueb1:=  pbasestecnicas.vedeadini1;
      --vedadprueb2:=  pbasestecnicas.vedeadini2;
      pbasestecnicas.vedeadini1 := TRUNC(pbasestecnicas.vedeadini1 * 12 + 0.5);
      pbasestecnicas.vedeadini2 := TRUNC(pbasestecnicas.vedeadini2 * 12 + 0.5);
--      if vedadprueb1 - pbasestecnicas.vedeadini1 then
--
--      end if;
--
--      if vedadprueb2 - pbasestecnicas.vedeadini2 then
--
--      end if;
      pbasestecnicas.vedeadini1 := pbasestecnicas.vedeadini1 / 12 -(1 / 12);
      pbasestecnicas.vedeadini2 := pbasestecnicas.vedeadini2 / 12 -(1 / 12);
      --pbasestecnicas.vedeadini1:=(814.5 / 12);
      vanyoefecto1 := TO_NUMBER(TO_CHAR(pbasestecnicas.vfnacimi1, 'YYYY'));
      vanyoefecto2 := TO_NUMBER(TO_CHAR(pbasestecnicas.vfnacimi2, 'YYYY'));
      vpasexec := 33;
      v_antos_hasta_fecvto := FLOOR(pbasestecnicas.vfecvto2 - pbasestecnicas.vfecproc) / 365.25;

      IF NVL(pbasestecnicas.vedeadini2, 1000) > pbasestecnicas.vedeadini1 THEN
         --    dbms_output.put_line('enro en 111111111111111111111111');
         IF vanyosmaxtab - pbasestecnicas.vedeadini1 <= v_antos_hasta_fecvto THEN
            pbasestecnicas.vanyostot := vanyosmaxtab - pbasestecnicas.vedeadini1;
         ELSE
            pbasestecnicas.vanyostot := v_antos_hasta_fecvto;
         END IF;
      ELSE
         -- dbms_output.put_line('enro en 22222222222222222222222');
         IF vanyosmaxtab - pbasestecnicas.vedeadini2 <= v_antos_hasta_fecvto THEN
            --  dbms_output.put_line('enro en 33333333333333333333333333333');
            pbasestecnicas.vanyostot := vanyosmaxtab - pbasestecnicas.vedeadini2;
         ELSE
            -- dbms_output.put_line('enro en 4444444444444444444444');
            pbasestecnicas.vanyostot := v_antos_hasta_fecvto;
         END IF;
      END IF;

      IF NVL(pbasestecnicas.vcclaren, 0) <> 0
         AND pbasestecnicas.vfecrevi IS NULL THEN   --En renta temporal corregimos panyos
         pbasestecnicas.vanyostot := pbasestecnicas.vanyostot +(1 / 12);
      END IF;

      vpasexec := 34;

--dbms_output.put_line('pbasestecnicas.vedeadini1:'||pbasestecnicas.vedeadini1);
--      dbms_output.put_line('pbasestecnicas.vsexo1:'||pbasestecnicas.vsexo1);
--      dbms_output.put_line('pbasestecnicas.vedeadini2:'||pbasestecnicas.vedeadini2);
--      dbms_output.put_line('vanyoefecto1:'||vanyoefecto1);
--      dbms_output.put_line('pbasestecnicas.vtablaahorro:'||pbasestecnicas.vtablaahorro);
--      dbms_output.put_line('pbasestecnicas.vinteres_gast_tec:'||pbasestecnicas.vinteres_gast_tec);
--      dbms_output.put_line('pbasestecnicas.vinteres_gast_min:'||pbasestecnicas.vinteres_gast_min);
--      dbms_output.put_line('pbasestecnicas.vndurper:'||pbasestecnicas.vndurper);
--      dbms_output.put_line('pbasestecnicas.vanyostot:'||pbasestecnicas.vanyostot);
--      dbms_output.put_line('pbasestecnicas.vanyosmenos:'||pbasestecnicas.vanyosmenos);
--dbms_output.put_line('pbasestecnicas.vfpag:'||vfpag);
--dbms_output.put_line('pbasestecnicas.vmi:'||vmi);
--dbms_output.put_line('pbasestecnicas.vmi2:'||vmi2);
      IF (pbasestecnicas.vedeadini1 IS NULL)
         OR(pbasestecnicas.vsexo1 IS NULL)
         OR(vanyoefecto1 IS NULL)
         OR(pbasestecnicas.vtablaahorro IS NULL)
         OR(pbasestecnicas.vinteres_gast_tec IS NULL)
         OR(pbasestecnicas.vinteres_gast_min IS NULL)
         OR(pbasestecnicas.vndurper IS NULL)
         OR(pbasestecnicas.vanyostot IS NULL)
         OR(pbasestecnicas.vanyosmenos IS NULL)
         OR(vfpag IS NULL)
         OR(vmi IS NULL)
         OR(vmi2 IS NULL) THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 35;
      pbasestecnicas.vrentamaxfija := pbasestecnicas.vrenta;
      pbasestecnicas.vrentaminfija := pbasestecnicas.vrentamin;
      pbasestecnicas.vaportacionfija := pbasestecnicas.vaportacion;
      p_datos_ult_saldo(pbasestecnicas.vsseguro,   --JRH Ssseguro
                        pbasestecnicas.vfecproc, pbasestecnicas.vultfecha,
                        pbasestecnicas.vultsaldo, pbasestecnicas.vultcapgar,
                        pbasestecnicas.vultcapfall, pbasestecnicas.vnnumlin);
      vpasexec := 36;
      pbasestecnicas.vconmu :=
         pac_conmutadors.calculaconmu(-1, pbasestecnicas.vedeadini1, pbasestecnicas.vsexo1,
                                      vanyoefecto1, pbasestecnicas.vedeadini2,
                                      pbasestecnicas.vsexo2, vanyoefecto2,
                                      pbasestecnicas.vtablaahorro,
                                      (1 /(1 +(pbasestecnicas.vinteres_gast_tec))),
                                      (1 /(1 +(pbasestecnicas.vinteres_gast_min))),
                                      pbasestecnicas.vndurper, NVL(pbasestecnicas.vprevali, 0),
                                      NVL(pbasestecnicas.virevali, 0),
                                      pbasestecnicas.vanyostot, pbasestecnicas.vanyostot,
                                      pbasestecnicas.vanyosmenos, 1, vfpag, vmi, 0,
                                      pbasestecnicas.vsobremort, 0,
                                      NVL(pbasestecnicas.vpdoscab, 0), NULL, vnmesextra, vmi2,
                                      1, 1, 0, 0);

      IF pbasestecnicas.vconmu IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 36;
      pbasestecnicas.vconmur :=
         pac_conmutadors.calculaconmu(-1, pbasestecnicas.vedeadini1, pbasestecnicas.vsexo1,
                                      vanyoefecto1, pbasestecnicas.vedeadini2,
                                      pbasestecnicas.vsexo2, vanyoefecto2,
                                      pbasestecnicas.vtablariesgo,
                                      (1 /(1 +(pbasestecnicas.vinteres_gast_tec))),
                                      (1 /(1 +(pbasestecnicas.vinteres_gast_min))),
                                      pbasestecnicas.vndurper, NVL(pbasestecnicas.vprevali, 0),
                                      NVL(pbasestecnicas.virevali, 0),
                                      pbasestecnicas.vanyostot, pbasestecnicas.vanyostot,
                                      pbasestecnicas.vanyosmenos, 1, vfpag, vmi, 0,
                                      pbasestecnicas.vsobremort, 0,
                                      NVL(pbasestecnicas.vpdoscab, 0), NULL, vnmesextra, vmi2,
                                      1, 1, 0, 0);

      IF pbasestecnicas.vconmu IS NULL THEN
         RAISE e_object_error;
      END IF;

      --dbms_output.put_line('____________________:'||pbasestecnicas.vconmur(1).vlxi);
      IF pbasestecnicas.vesrenta THEN
         IF pbasestecnicas.vfecrevi IS NOT NULL THEN
            pbasestecnicas.vfecfinal := pbasestecnicas.vfecrevi;
         ELSE
            pbasestecnicas.vfecfinal := NVL(pbasestecnicas.vfecvto, pbasestecnicas.vfecvto2);   --NVL para HI
         END IF;

         pbasestecnicas.vprovfecrevi :=
            pac_provmat_formul.f_calcul_formulas_provi(pbasestecnicas.vsseguro,
                                                       pbasestecnicas.vfecfinal, 'IPROVAC');
         pbasestecnicas.vanyosfinal := FLOOR(MONTHS_BETWEEN(pbasestecnicas.vfecfinal,
                                                            pbasestecnicas.vfecproc));
         pbasestecnicas.vanyosfinal := pbasestecnicas.vanyosfinal / 12;
--         pbasestecnicas.vanyosfinal := (pbasestecnicas.vfecfinal - pbasestecnicas.vfecproc)
--                                       / 365.25;
      ELSE
         IF pbasestecnicas.vcramo = 80
            AND pbasestecnicas.vcmodali = 3 THEN
            IF pbasestecnicas.vfecrevi IS NOT NULL THEN
               pbasestecnicas.vfecfinal := pbasestecnicas.vfecrevi;
            ELSE
               pbasestecnicas.vfecfinal := NVL(pbasestecnicas.vfecvto,
                                               pbasestecnicas.vfecvto2);
            END IF;

            --         pbasestecnicas.vprovfecrevi :=
            --            pac_provmat_formul.f_calcul_formulas_provi(pbasestecnicas.vsseguro,
            --                                                       pbasestecnicas.vfecfinal, 'IPROVAC');
--            pbasestecnicas.vanyosfinal := (pbasestecnicas.vfecfinal - pbasestecnicas.vfecproc)
--                                          / 365.25;
            pbasestecnicas.vanyosfinal := FLOOR(MONTHS_BETWEEN(pbasestecnicas.vfecfinal,
                                                               pbasestecnicas.vfecproc));
            pbasestecnicas.vanyosfinal := pbasestecnicas.vanyosfinal / 12;
            pbasestecnicas.vprovfecrevi :=
               pac_provmat_formul.f_calcul_formulas_provi(pbasestecnicas.vsseguro,
                                                          pbasestecnicas.vfecfinal, 'ICAPREV');
         ELSE
--           IF pbasestecnicas.vfecrevi IS NOT NULL THEN
--                pbasestecnicas.vfecfinal := pbasestecnicas.vfecrevi;
--             ELSE
            pbasestecnicas.vfecfinal := NVL(pbasestecnicas.vfecvto, pbasestecnicas.vfecvto2);
            -- END IF;

            --         pbasestecnicas.vprovfecrevi :=
            --            pac_provmat_formul.f_calcul_formulas_provi(pbasestecnicas.vsseguro,
            --                                                       pbasestecnicas.vfecfinal, 'IPROVAC');
--            pbasestecnicas.vanyosfinal := (pbasestecnicas.vfecfinal - pbasestecnicas.vfecproc)
--                                          / 365.25;
            pbasestecnicas.vanyosfinal := FLOOR(MONTHS_BETWEEN(pbasestecnicas.vfecfinal,
                                                               pbasestecnicas.vfecproc));
            pbasestecnicas.vanyosfinal := pbasestecnicas.vanyosfinal / 12;
            pbasestecnicas.vprovfecrevi :=
               pac_provmat_formul.f_calcul_formulas_provi(pbasestecnicas.vsseguro, f_sysdate,
                                                          'ICGARAC');
         END IF;
      END IF;

      pbasestecnicas.vfecprocreal := pfproces;
      --DBMS_OUTPUT.put_line('pbasestecnicas.vaportacion:' || pbasestecnicas.vaportacion);
      vpasexec := 37;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 1000005;   --Error al gravar la variable de contexto agente de producción.
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Error al ejecutar procedimiento o funció - vnumerr: ' || vnumerr || ' '
                     || SUBSTR(f_obtener_bases_desc(pbasestecnicas), 1, 2000));
         RETURN 1000006;   --Error al gravar la variable de contexto agente de producción.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM || ' '
                     || SUBSTR(f_obtener_bases_desc(pbasestecnicas), 1, 2000));
         RETURN 1000001;   --Error al gravar la variable de contexto agente de producción.
   END f_obtener_bastec_poliza;

/*************************************************************************
      f_generar_alm_poliza
      Genera alm de una póliza
      param in   psproces : Número de proceso
      param in   pfproces : Fecha del proceso
      param in  psseguro : Sseguro
      Retorna diferente de 0 (un código de error) en caso de error
   *************************************************************************/
   FUNCTION f_generar_alm_poliza(
      psproces IN NUMBER,
      pfproces IN DATE,
      psseguro IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_ALM_PROCESO.f_generar_alm_poliza';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro: ' || psseguro || ' - pfproces: '
            || TO_CHAR(pfproces, 'DD/MM/YYYY') || '  psproces:' || psproces || ' pmodo:'
            || pmodo;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_basestecnicas t_basestecnicas;
      v_almreg       alm_proceso_det%ROWTYPE;
      v_almreg_ant   alm_proceso_det%ROWTYPE;
      vnprolin       NUMBER;
   BEGIN
      vpasexec := 0;

      IF pfproces IS NULL
         OR psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := f_obtener_bastec_poliza(pfproces, psseguro, v_basestecnicas);
      vpasexec := 1;

      IF vnumerr <> 0 THEN
         vnumerr := 9900879;
         RAISE e_object_error;
      END IF;

--         vanyostot number
      FOR i IN 1 .. ROUND(v_basestecnicas.vanyosfinal * 12) + 1 LOOP
         --  v_basestecnicas.
         v_basestecnicas.vnummes := i;
         vpasexec := 2;
         vnumerr := f_obtener_mes_alm_poliza(psproces, v_basestecnicas, v_almreg_ant,
                                             v_almreg);
         vpasexec := 3;

         IF vnumerr <> 0 THEN
            vnumerr := 109388;
            RAISE e_object_error;
         END IF;

         vpasexec := 4;

         IF pmodo = 'R' THEN
            INSERT INTO alm_proceso_det
                 VALUES v_almreg;
         ELSE
            INSERT INTO alm_proc_det_prev
                 VALUES v_almreg;
         END IF;

         v_almreg_ant := v_almreg;
         vpasexec := 5;
      END LOOP;

--
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         vnumerr := f_proceslin(psproces,
                                1000005 || ' - ' || f_axis_literales(1000005, f_idiomauser),
                                psseguro, vnprolin, 1);
         RETURN 1000005;   --Error al gravar la variable de contexto agente de producción.
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Error al ejecutar procedimiento o funció - vnumerr: ' || vnumerr || ' '
                     || SUBSTR(f_obtener_bases_desc(v_basestecnicas), 1, 2000));
         vnumerr := f_proceslin(psproces,
                                vnumerr || ' - ' || f_axis_literales(vnumerr, f_idiomauser),
                                psseguro, vnprolin, 1);
         RETURN 1000006;   --Error al gravar la variable de contexto agente de producción.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM || ' '
                     || SUBSTR(f_obtener_bases_desc(v_basestecnicas), 1, 2000));
         vnumerr := f_proceslin(psproces, SQLCODE || ' - ' || SQLERRM, psseguro, vnprolin, 1);
         RETURN 1000001;   --Error al gravar la variable de contexto agente de producción.
   END f_generar_alm_poliza;

/*************************************************************************
      f_generar_alm
      Genera alm de una póliza
      param in   psproces : Número de proceso
      param in   pfproces : Fecha del proceso
      param in   pcramo : Ramo
      param in   psproduc : Producto
      param in  psseguro : Sseguro
      Retorna diferente de 0 (un código de error) en caso de error
   *************************************************************************/
   FUNCTION f_generar_alm(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pfproces IN DATE,
      pcagrup IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_ALM_PROCESO.f_generar_alm';
      vparam         VARCHAR2(500)
         := 'parámetros - psproces: ' || psproces || ' - pfproces: '
            || TO_CHAR(pfproces, 'DD/MM/YYYY') || '   pcramo:   ' || pcramo
            || '  psproduc:   ' || psproduc || '  psseguro:   ' || psseguro || '  pmodo:   '
            || pmodo;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;

-- BUG 0016981 - 12/2010 - JRH  -  Proceso ALM
      --f_traspasar_det
      CURSOR c_polizas IS
         SELECT *
           FROM seguros s
          WHERE ((s.sseguro = psseguro
                  AND psseguro IS NOT NULL)
                 OR(psseguro IS NULL))
            AND((s.cramo = cramo
                 AND cramo IS NOT NULL)
                OR(cramo IS NULL))
            AND((s.sproduc = psproduc
                 AND psproduc IS NOT NULL)
                OR(psproduc IS NULL))
            AND((s.cagrpro = pcagrup
                 AND pcagrup IS NOT NULL)
                OR(pcagrup IS NULL))
            AND s.cempres = pcempres
            AND s.cagrpro IN(2, 10, 21)
            AND f_situacion_v(s.sseguro, pfproces) = 1
            AND fefecto <= pfproces;

-- Fi BUG 0016981 - 12/2010 - JRH  -  Proceso ALM
      vi             NUMBER := 0;
      verrores       NUMBER := 0;
      vnprolin       NUMBER;
   BEGIN
      vpasexec := 0;

      IF pfproces IS NULL
         OR psproces IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

-- BUG 0017441 - 01/2011 - JRH  -  Proceso ALM
      IF pmodo = 'P' THEN
         BEGIN
            EXECUTE IMMEDIATE ('truncate table ALM_PROC_DET_PREV');

            EXECUTE IMMEDIATE ('truncate table ALM_PROCESO_PREVIO');
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      END IF;

-- Fi BUG 0017441 - 01/2011 - JRH

      --DBMS_OUTPUT.put_line('psseguro:' || psseguro || ' pfproces:' || pfproces);
      vpasexec := 2;

--      DELETE      alm_proceso_det a
--            WHERE fproces = pfproces
--                 AND sproces = psproces
--              AND((a.sseguro = psseguro
--                   AND psseguro IS NOT NULL)
--                  OR(psseguro IS NULL))
--              AND((a.cramo = cramo
--                   AND cramo IS NOT NULL)
--                  OR(cramo IS NULL))
--              AND((a.sproduc = psproduc
--                   AND psproduc IS NOT NULL)
--                  OR(psproduc IS NULL));
      FOR reg IN c_polizas LOOP
         --DBMS_OUTPUT.put_line('1');
         vi := vi + 1;
         vpasexec := 3;
         vnumerr := f_generar_alm_poliza(psproces, pfproces, reg.sseguro, pmodo);
         vpasexec := 4;

         IF vnumerr <> 0 THEN
            verrores := verrores + 1;
            ROLLBACK;
         ELSE
            --RAISE e_object_error;
            COMMIT;
         END IF;

         vpasexec := 5;
      END LOOP;

      vpasexec := 7;
      vnumerr := f_traspasar_det(psproces, pmodo);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 8;
--      DELETE      alm_proceso_det
--            WHERE fproces = pfproces
--              AND sproces <> psproces;
      vnumerr := f_proceslin(psproces,
                             'Nº Total de pólizas procesadas = ' || vi
                             || ' ; Nº Pólizas Correctas = ' || TO_CHAR(vi - verrores)
                             || ' , Nº Pólizas Incorrectas = ' || verrores,
                             0, vnprolin, 4);
--
      vpasexec := 9;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 1000005;   --Error al gravar la variable de contexto agente de producción.
      WHEN e_object_error THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Error al ejecutar procedimiento o funció - vnumerr: ' || vnumerr);
         RETURN 1000006;   --Error al gravar la variable de contexto agente de producción.
      WHEN OTHERS THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000001;   --Error al gravar la variable de contexto agente de producción.
   END f_generar_alm;

   /************************************************************************
       f_proceso_cierre
          Proceso batch de inserción de la ALM en CTASEGURO

        Parámetros Entrada:

            psmodo : Modo (1-->Previo y '2 --> Real)
            pcempres: Empresa
            pmoneda: Divisa
            pcidioma: Idioma
            pfperini: Fecha Inicio
            pfperfin: Fecha Fin
            pfcierre: Fecha Cierre

        Parámetros Salida:

            pcerror : <>0 si ha habido algún error
            psproces : Proceso
            pfproces : Fecha en que se realiza el proceso

    *************************************************************************/
   PROCEDURE p_proceso_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcagrup IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
      -- 16/9/04 CPM:
      --
      --    Proceso que lanzará el proceso de cierre de ahorro de forma batch
      --
      --   Esta llamada tiene parámetros que no son necesarios por ser requeridos
      --     para que sea compatible con el resto de cierres programados.
      --
      vobjectname    VARCHAR2(500) := 'PAC_ALM_PROCESO.f_proceso_cierre';
      vparam         VARCHAR2(500)
         := 'parámetros - psproces: ' || psproces || ' - pfproces: '
            || TO_CHAR(pfproces, 'DD/MM/YYYY') || '   pcramo:   ' || pcramo
            || '  psproduc:   ' || psproduc || '  psseguro:   ' || psseguro || '  pmodo:   '
            || pmodo || ' pcempres:' || pcempres;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vnum_err       NUMBER;
      vindice        NUMBER;
      v_modo         VARCHAR2(1);
      vtitulo        VARCHAR2(2000);
      vtexto         VARCHAR2(100);
      vnprolin       NUMBER;
   BEGIN
      IF pfcierre IS NULL
         OR pmodo IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;

      IF pmodo = 2 THEN
         v_modo := 'R';
      ELSE
         v_modo := 'P';
      END IF;

      vpasexec := 2;
      vnum_err := f_desvalorfijo(54, pcidioma, TO_NUMBER(TO_CHAR(pfcierre, 'mm')), vtexto);
      vpasexec := 3;

      IF vnum_err <> 0 THEN
         RAISE e_param_error;
      END IF;

      IF v_modo = 'P' THEN   -- previo del cierre
         vtitulo := 'Previo ALM de' || vtexto || ' Prod. Ahorro';
      ELSE
         vtitulo := 'Cierre PB de ' || vtexto || ' Prod. Ahorro';
      END IF;

      IF pcagrup IS NOT NULL THEN
         vtitulo := vtitulo || ' Agrupación: ' || pcagrup;
      END IF;

      IF pcramo IS NOT NULL THEN
         vtitulo := vtitulo || ' Ramo: ' || pcramo;
      END IF;

      IF psproduc IS NOT NULL THEN
         vtitulo := vtitulo || ' Producto: ' || psproduc;
      END IF;

      IF psseguro IS NOT NULL THEN
         vtitulo := vtitulo || ' Póliza: ' || psseguro;
      END IF;

      vpasexec := 4;
      vnum_err := f_procesini(f_user, pcempres, 'CIERRE_ALM', vtitulo, psproces);

      IF vnum_err <> 0 THEN
         vnum_err := 109388;
         RAISE e_object_error;
      END IF;

      pfproces := TO_DATE('01' || TO_CHAR(ADD_MONTHS(pfcierre, 1), 'MMYYYY'), 'DDMMYYYY');
      vpasexec := 5;
      vnum_err := f_generar_alm(pcempres, psproces, pfproces, pcagrup, pcramo, psproduc,
                                psseguro, v_modo);
      vpasexec := 6;

      IF vnum_err = 0 THEN
         vnum_err := f_generar_fichero(psproces, v_modo);

         IF vnum_err <> 0 THEN
            vnum_err := 151632;
            vnumerr := f_proceslin(psproces,
                                   vnumerr || ' - ' || f_axis_literales(vnumerr, f_idiomauser),
                                   psseguro, vnprolin, 1);
         END IF;
      END IF;

      IF vnum_err = 0 THEN
         pcerror := 0;
         vpasexec := 7;
         vnum_err := f_procesfin(psproces, 0);

         IF vnum_err <> 0 THEN
            vnum_err := 800727;
            RAISE e_object_error;
         END IF;

         vpasexec := 8;
         COMMIT;
      ELSE
         pcerror := vnum_err;
         vpasexec := 9;
         vnum_err := f_procesfin(psproces, 1);

         IF vnum_err <> 0 THEN
            vnum_err := 800727;
            RAISE e_object_error;
         END IF;

         vpasexec := 10;
         ROLLBACK;
      END IF;

      vpasexec := 11;
      pfproces := f_sysdate;
   EXCEPTION
      WHEN e_param_error THEN
         pcerror := 1000005;
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
      --Error al gravar la variable de contexto agente de producción.
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Error al ejecutar procedimiento o funció - vnumerr: ' || vnumerr);
         pcerror := vnumerr;
         ROLLBACK;
      --Error al gravar la variable de contexto agente de producción.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         pcerror := 1000001;
         ROLLBACK;
   --Error al gravar la variable de contexto agente de producción.
   END p_proceso_cierre;

    /************************************************************************
      proceso_batch_cierre
         Proceso batch de inserción de la PB en CTASEGURO

       Parámetros Entrada:

           psmodo : Modo (1-->Previo y '2 --> Real)
           pcempres: Empresa
           pmoneda: Divisa
           pcidioma: Idioma
           pfperini: Fecha Inicio
           pfperfin: Fecha Fin
           pfcierre: Fecha Cierre

       Parámetros Salida:

           pcerror : <>0 si ha habido algún error
           psproces : Proceso
           pfproces : Fecha en que se realiza el proceso

   *************************************************************************/
   PROCEDURE proceso_batch_cierre(
      pmodo IN NUMBER,
      pcempres IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE) IS
      -- 16/9/04 CPM:
      --
      --    Proceso que lanzará el proceso de cierre de ahorro de forma batch
      --
      --   Esta llamada tiene parámetros que no son necesarios por ser requeridos
      --     para que sea compatible con el resto de cierres programados.
      --
      vnum_err       NUMBER;
      vindice        NUMBER;
      v_modo         VARCHAR2(1);
   BEGIN
      p_proceso_cierre(pmodo, pcempres, pmoneda, pcidioma, pfperini, pfperfin, pfcierre, NULL,
                       NULL, NULL, NULL, pcerror, psproces, pfproces);

      IF NVL(pcerror, 0) <> 0 THEN
         pcerror := 109388;
      END IF;
   END proceso_batch_cierre;
-- Fi BUG 0016981 - 12/2010 - JRH
END pac_alm_proceso;

/

  GRANT EXECUTE ON "AXIS"."PAC_ALM_PROCESO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ALM_PROCESO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ALM_PROCESO" TO "PROGRAMADORESCSI";
