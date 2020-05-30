--------------------------------------------------------
--  DDL for Package Body PAC_COMISI_ADQUI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_COMISI_ADQUI" AS
/******************************************************************************
   NOMBRE:      PAC_COMISI_ADQUI
   PROPÓSITO: Funciones para las comisiones de adquisición

   REVISIONES:
   Ver        Fecha        Autor  Descripción
   ---------  ----------  ------  ------------------------------------
   1.0        XX/XX/XXXX   XXX    Creacion del package
   2.0        29/01/2010   JTS    BUG 12389: APR - pantallas de comisiones de adquisición
******************************************************************************/

   /*************************************************************************
      FUNCTION f_obtener_polizas
      param in p_cagente      : NUMBER,
      param in p_tagente      : VARCHAR,
      param in p_npoliza      : NUMBER,
      param in p_ncertif      : NUMBER,
      param in p_desde        : DATE,
      param in p_hasta        : DATE
      param out p_refcursor   : sys_refcursor
      return               : OB_INFO_IMP
   *************************************************************************/
   FUNCTION f_obtener_polizas(
      p_cagente IN NUMBER,
      p_tagente IN VARCHAR,
      p_npoliza IN NUMBER,
      p_ncertif IN NUMBER,
      p_desde IN DATE,
      p_hasta IN DATE,
      p_refcursor OUT sys_refcursor)
      RETURN NUMBER IS
      v_contexto     VARCHAR2(100);
      v_tagecont     VARCHAR2(100);
      v_cagente      VARCHAR2(50);
      v_squery       VARCHAR2(2000);
   BEGIN
      v_contexto := f_parinstalacion_t('CONTEXT_USER');
      v_tagecont := 'IAX_AGENTE';
      v_cagente := pac_contexto.f_contextovalorparametro(v_contexto, v_tagecont);
      --BUG 12389 - JTS - 29/01/2010
      v_squery := 'SELECT distinct a.cagente cagente, f_nombre(a.sperson,1,' || v_cagente
                  || ') tagente, s.npoliza npoliza, f_nombre(t.sperson,1,' || v_cagente
                  || ') tnombre, s.sseguro sseguro '
                  || 'FROM comisigaranseg c, seguros s, agentes a, tomadores t '
                  || 'WHERE s.sseguro = c.sseguro ' || 'AND s.cagente = a.cagente '
                  || 'AND t.sseguro = s.sseguro ' || 'AND s.cagente = nvl('
                  || NVL(TO_CHAR(p_cagente), 'NULL') || ',s.cagente) '
                  || 'AND s.cagente IN (SELECT a.cagente ' || 'FROM agentes a, per_detper p '
                  || 'WHERE a.sperson = p.sperson AND p.tbuscar LIKE ''%''||nvl(' || CHR(39)
                  || NVL(p_tagente, '') || CHR(39) || ',p.tbuscar)||''%'') '
                  || 'AND s.npoliza = nvl(' || NVL(TO_CHAR(p_npoliza), 'NULL')
                  || ',s.npoliza) ' || 'AND s.ncertif = nvl('
                  || NVL(TO_CHAR(p_ncertif), 'NULL') || ',s.ncertif) ';

      IF p_desde IS NOT NULL THEN
         v_squery := v_squery || 'AND c.finiefe >= nvl(to_date('''
                     || TO_CHAR(p_desde, 'ddmmyyyy') || ''',''ddmmyyyy''),c.finiefe) ';
      END IF;

      IF p_hasta IS NOT NULL THEN
         v_squery := v_squery || 'AND (c.ffinpg is null or c.ffinpg <= nvl(to_date('''
                     || TO_CHAR(p_hasta, 'ddmmyyyy') || ''',''ddmmyyyy''),c.ffinpg))';
      END IF;
      --Fi BUG 12389

      OPEN p_refcursor FOR v_squery;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_obtener_polizas;

   FUNCTION f_obtener_total_comis(
      p_sseguro IN NUMBER,
      p_npoliza OUT NUMBER,
      p_fefecto OUT DATE,
      p_vto OUT DATE,
      p_totcom OUT NUMBER)
      RETURN NUMBER IS
   BEGIN
      SELECT   s.npoliza, MIN(c.finiefe) fefecto, MAX(c.ffinpg) vto, SUM(c.itotcom) totcom
          INTO p_npoliza, p_fefecto, p_vto, p_totcom
          FROM seguros s, comisigaranseg c
         WHERE s.sseguro = c.sseguro
           AND s.sseguro = p_sseguro
      GROUP BY s.npoliza;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_obtener_total_comis;

   FUNCTION f_obtener_comisiones(p_sseguro IN NUMBER, p_refcursor OUT sys_refcursor)
      RETURN NUMBER IS
      v_contexto     VARCHAR2(100);
      v_tagecont     VARCHAR2(100);
      v_tidicont     VARCHAR2(100);
      v_cagente      VARCHAR2(50);
      v_cidioma      VARCHAR2(50);
      v_squery       VARCHAR2(2000);
   BEGIN
      v_contexto := f_parinstalacion_t('CONTEXT_USER');
      v_tagecont := 'IAX_AGENTE';
      v_cagente := pac_contexto.f_contextovalorparametro(v_contexto, v_tagecont);
      v_tidicont := 'IAX_IDIOMA';
      v_cidioma := pac_contexto.f_contextovalorparametro(v_contexto, v_tidicont);
      v_squery :=
         'SELECT a.cagente cagente, f_nombre(a.sperson,1,' || v_cagente
         || ') tagente, g.tgarant,'
         || 'c.finiefe fefecto,c.ffinpg fvencim,c.iprianu,c.pcomisi,c.icomanu,c.itotcom '
         || 'FROM comisigaranseg c, seguros s, agentes a, garangen g '
         || 'WHERE c.sseguro = s.sseguro ' || 'AND s.cagente = a.cagente '
         || 'AND c.cgarant = g.cgarant ' || 'AND g.cidioma = ' || v_cidioma || ' '
         || 'AND c.sseguro = ' || p_sseguro;

      OPEN p_refcursor FOR v_squery;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_obtener_comisiones;
END pac_comisi_adqui;

/

  GRANT EXECUTE ON "AXIS"."PAC_COMISI_ADQUI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_COMISI_ADQUI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_COMISI_ADQUI" TO "PROGRAMADORESCSI";
