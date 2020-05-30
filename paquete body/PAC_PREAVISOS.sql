--------------------------------------------------------
--  DDL for Package Body PAC_PREAVISOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PREAVISOS" AS
   /******************************************************************************
      NOMBRE:       PAC_PREAVISOS
      PROPÓSITO:    Funcionalidad para el módulo de preavisos

      REVISIONES:
      Ver        Fecha       Autor  Descripción
      ---------  ----------  -----  ------------------------------------
      1.0        10/04/2012  JTS    Creación del package. (BUG 21756)
   ****************************************************************************/
   FUNCTION f_buscarecibos(
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pdomiciliados IN NUMBER,
      pmediador IN NUMBER,
      ppfinanciero IN NUMBER,
      ppcomercial IN NUMBER,
      ptomador IN NUMBER,
      pfinici IN DATE,
      pfinal IN DATE)
      RETURN VARCHAR2 IS
      vselect        VARCHAR2(32000);
   BEGIN
      vselect :=
         'SELECT pac_isqlfor.f_titulopro(s.sseguro) titpro, s.npoliza, r.nrecibo,
TRIM(pac_isqlfor.f_dades_persona(t.sperson, 5) || '', ''
|| pac_isqlfor.f_dades_persona(t.sperson, 4)) nomriesgo,
ff_desvalorfijo(8, pac_contexto.f_contextovalorparametro(''IAX_IDIOMA''),
r.ctiprec) ttiprec,
r.fefecto fefecto, r.fvencim fvencim,
r.cbancar, v.itotalr, (select max(p.fenvio) from preavisosrecibos p where r.nrecibo = p.nrecibo) fenvio,
ff_desvalorfijo(800105,pac_contexto.f_contextovalorparametro(''IAX_IDIOMA''),decode(f_es_renova(s.sseguro,f_sysdate),0,2,1)) tanuali
FROM recibos r, seguros s, vdetrecibos v, movrecibo m, tomadores t,
agentes a, productos pd, per_personas pp
WHERE ROWNUM <= NVL(pac_parametros.f_parinstalacion_n(''N_MAX_REC''),ROWNUM)
AND r.sseguro = s.sseguro
AND r.nrecibo = v.nrecibo
AND t.sseguro = s.sseguro
AND s.cagente = a.cagente
AND s.sproduc = pd.sproduc
AND m.nrecibo = r.nrecibo
AND m.fmovfin IS NULL
AND m.cestrec = 0
AND pp.sperson = t.sperson
AND(pp.cpreaviso = 1
OR(pp.cpreaviso IS NULL
AND(a.cpreaviso = 1
OR(a.cpreaviso IS NULL
AND(pd.cpreaviso = 1))))) ';

      IF pcramo IS NOT NULL THEN
         vselect := vselect || ' and s.cramo = ' || pcramo;
      END IF;

      IF psproduc IS NOT NULL THEN
         vselect := vselect || ' and s.sproduc = ' || psproduc;
      END IF;

      IF pdomiciliados IS NOT NULL THEN
         IF pdomiciliados = 0 THEN   --No
            vselect := vselect || ' and NVL(r.ctipcob, DECODE(r.cbancar, NULL, 1, 2)) != 2';
         ELSIF pdomiciliados = 1 THEN   --Si
            vselect := vselect || ' and NVL(r.ctipcob, DECODE(r.cbancar, NULL, 1, 2)) = 2';
         END IF;
      --En otro caso todos, no filtramos
      END IF;

      IF pmediador IS NOT NULL THEN
         vselect := vselect || ' and a.cagente = ' || pmediador;
      END IF;

      IF ptomador IS NOT NULL THEN
         vselect := vselect || ' and t.sperson = ' || ptomador;
      END IF;

      IF pfinici IS NOT NULL THEN
         vselect := vselect || ' and trunc(r.femisio) >= to_date('''
                    || TO_CHAR(pfinici, 'ddmmyyyy') || ''',''ddmmyyyy'')';
      END IF;

      IF pfinal IS NOT NULL THEN
         vselect := vselect || ' and trunc(r.femisio) <= to_date('''
                    || TO_CHAR(pfinal, 'ddmmyyyy') || ''',''ddmmyyyy'')';
      END IF;

      --Pendientes los siguientes filtros:
      --
      --filtrar que el mediador tenga el pago no confiado
      --
      IF ppfinanciero IS NOT NULL THEN
         vselect :=
            vselect
            || ' and exists(select 1 from agentes_comp ac where ac.cagente = r.cagente and ac.agrupador = '
            || ppfinanciero || ') ';
      END IF;

      IF ppcomercial IS NOT NULL THEN
         vselect :=
            vselect
            || ' and exists(select 1 from agentes_comp ac where ac.cagente = r.cagente and ac.agrupador = '
            || ppcomercial || ') ';
      END IF;

      RETURN vselect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_buscarecibos;

   FUNCTION f_nuevopreaviso(pcuser IN VARCHAR, osproces IN OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT NVL(MAX(sproces), 0) + 1 sproces
        INTO osproces
        FROM preavisosrecibos_cab;

      INSERT INTO preavisosrecibos_cab
                  (sproces, cuser, fpreaviso)
           VALUES (osproces, pcuser, f_sysdate);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 9903569;
   END f_nuevopreaviso;

   FUNCTION f_insertapreaviso(
      psproces IN NUMBER,
      pnrecibo IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER)
      RETURN NUMBER IS
      vcount         NUMBER;
   BEGIN
      INSERT INTO preavisosrecibos
                  (sproces, nrecibo, sseguro, nmovimi)
           VALUES (psproces, pnrecibo, psseguro, pnmovimi);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 9903569;
   END f_insertapreaviso;

   FUNCTION f_actualizapreaviso(psproces IN NUMBER, pnrecibo IN NUMBER)
      RETURN NUMBER IS
      v_num_err      NUMBER;
      v_idobs        NUMBER;
   BEGIN
      UPDATE preavisosrecibos
         SET fenvio = f_sysdate
       WHERE nrecibo = pnrecibo
         AND sproces = psproces;

--Apunte en la agenda
      v_num_err := pac_agenda.f_set_obs(pac_md_common.f_get_cxtempresa, NULL, 5, 0,
                                        f_axis_literales(9904215,
                                                         pac_md_common.f_get_cxtidioma),
                                        f_axis_literales(9904216,
                                                         pac_md_common.f_get_cxtidioma)
                                        || ' (' || TO_CHAR(f_sysdate, 'DD/MM/YYYY') || ')',
                                        f_sysdate, NULL, 2, NULL, NULL, NULL, NULL, 1,
                                        f_sysdate, v_idobs, NULL, pnrecibo, NULL, NULL, NULL);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 9903570;
   END f_actualizapreaviso;

   FUNCTION f_compruebamediador(pmediador IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      --Pendent del desenvolupament del módul CCM
      --De moment retornem ok
      --Si el mediador tingues pagament confiat
      --retornariem el literal: 9903572 (El mediador tiene pago confiado)
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 9903571;
   END f_compruebamediador;
END pac_preavisos;

/

  GRANT EXECUTE ON "AXIS"."PAC_PREAVISOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PREAVISOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PREAVISOS" TO "PROGRAMADORESCSI";
