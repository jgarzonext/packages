--------------------------------------------------------
--  DDL for Package Body PAC_FUN_FORMATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_FUN_FORMATOS" AS
/******************************************************************************
   NOMBRE:      PAC_FUN_FORMATOS
   PROPÓSITO:   Funciones para obtener la data de cada formato

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        08/08/2013   JMG               1. Creación del package.
******************************************************************************/

   /*************************************************************************
     FUNCTION f_get_negocio
        Obtiene los registro de negocio para la generacion de formatos
        param in p_separador: separador de la tabla fic_gestores
        param in p_tgestor: codigo de gestor
        param in p_tformato: codigo de formato
        param in p_empres: empresa
        param in p_anio : objeto fichero
        param in p_mes: archivo de carga
        param in p_dia : objeto fichero
     *************************************************************************/
   FUNCTION f_get_negocio(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros IS
      tbfichero      t_tabla_ficheros := NEW t_tabla_ficheros();
      lineas         t_linea := NEW t_linea();
      verror         NUMBER;
      paths_dir      t_linea := NEW t_linea();
   BEGIN
      lineas.EXTEND(3);
      lineas(1) := '1;19;1;A;01/01/2013;01/01/2013;1;A;100;21;5;100';
      lineas(2) := '2;20;1;B;02/01/2013;02/01/2013;1;A;200;21;5;200';
      lineas(3) := '3;85;2;A;03/01/2013;03/01/2013;1;A;300;21;5;300';
      tbfichero.EXTEND(1);
      tbfichero(1) := NEW ob_fichero(p_empres, p_tgestor, p_tformato, '1', lineas, 'TIPONUM',
                                     'DOCNUM', 'NUMPOL');
      --pac_fic_formatos.p_generar_ficherocsv(tbfichero, verror, paths_dir);
      RETURN tbfichero;
   END f_get_negocio;

   FUNCTION f_get_negocio483(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros IS
      tbfichero      t_tabla_ficheros := NEW t_tabla_ficheros();
      lineas         t_linea := NEW t_linea();
      verror         NUMBER;
      paths_dir      t_linea := NEW t_linea();
   BEGIN
      lineas.EXTEND(3);
      lineas(1) := '1;19;1;A;01/01/2013;01/01/2013;1;A;100;21;5;100;300;800';
      lineas(2) := '2;20;1;B;02/01/2013;02/01/2013;1;A;200;21;5;200;300;800';
      lineas(3) := '3;85;2;A;03/01/2013;03/01/2013;1;A;300;21;5;300;300;800';
      tbfichero.EXTEND(1);
      tbfichero(1) := NEW ob_fichero(17, '12', '483', '1', lineas, 'TIPONUM', 'DOCNUM',
                                     'NUMPOL');
      --pac_fic_formatos.p_generar_ficherocsv(tbfichero, verror, paths_dir);
      RETURN tbfichero;
   END f_get_negocio483;

   /*************************************************************************
    FUNCTION f_get_nomina_reaseguradores
       Obtiene los registro de la nomina de reaseguradores - contratos de reaseguros
       proporcionales y no proporcionales para la generacion del formato 485.
       param in p_empres: empresa
       param in p_tgestor: codigo de gestor
       param in p_tformato: codigo de formato
       param in p_anio : objeto fichero
       param in p_mes: archivo de carga
       param in p_dia : objeto fichero
       param in p_separador: separador de la tabla fic_gestores
    *************************************************************************/
   FUNCTION f_get_nomina_reaseguradores(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros IS
      v_contexto     VARCHAR2(4000);
      v_finicio      DATE;
      v_ffin         DATE;
      v_linea        VARCHAR2(4000);
      v_lineas       t_linea := NEW t_linea();
      v_subcuenta    NUMBER;
      v_tbfichero    t_tabla_ficheros := NEW t_tabla_ficheros();

      CURSOR cur_datos(p_empres IN NUMBER, p_finicio IN DATE, p_ffin IN DATE) IS
         SELECT   TO_CHAR(s.fefecto, 'dd/mm/rrrr') finicio,
                  TO_CHAR(s.fvencim, 'dd/mm/rrrr') ffin, r.ccompani codigo_reasegurador,

                  --co.tcompani "Reasegurador",
                  co.cpais pais_origen,
                  NVL((SELECT dv.tatribu
                         FROM detvalores dv
                        WHERE dv.cvalor = 800100
                          AND dv.catribu = co.ccalifi
                          AND dv.cidioma = 2),
                      '') calificacion,
                  NVL((SELECT dv.tatribu
                         FROM detvalores dv
                        WHERE dv.cvalor = 800101
                          AND dv.catribu = co.centicalifi
                          AND dv.cidioma = 2),
                      '') agencia_calificadora,
                  co.nanycalif anio_actualizacion, NVL(c.ccorred, -1) codigo_corredor,

                  --(SELECT bro.tcompani
                  -- FROM companias bro
                  --WHERE bro.ccompani = c.ccorred) corredor,
                  r.ctramo codigo_tipo_contrato,
                                                --CASE
                                                --   WHEN r.ctramo = 1
                                                --     OR r.ctramo = 2
                                                --     OR r.ctramo = 3
                                                --     OR r.ctramo = 4 THEN 'Ctr. Aut. Proporcional'
                                                --   WHEN r.ctramo = 5 THEN 'Facultativo'
                                                --   ELSE 'No Proporcional (XL)'
                                                --END "Tipo de Contrato",
                                                cd.spleno capa, r.cramo ramo,
                  r.pporcen pcj_participacion
             FROM reaseguro r LEFT JOIN seguros s ON(r.sseguro = s.sseguro)
                  LEFT JOIN ctatecnica c
                  ON(r.scontra = c.scontra
                     AND c.nversio = r.nversio
                     AND c.ctramo = r.ctramo
                     AND c.ccompani = r.ccompani
                     AND c.cempres = r.cempres
                     AND c.sproduc = s.sproduc)
                  LEFT JOIN codicontratos cd
                  ON(cd.scontra = r.scontra
                     AND cd.scontra = c.scontra)
                  LEFT JOIN companias co ON(co.ccompani = r.ccompani)
            WHERE r.cgenera <> 2
              AND r.cempres = p_empres
              AND r.fcierre >= p_finicio
              AND r.fcierre <= p_ffin
         ORDER BY r.fcierre, s.fefecto;
   BEGIN
      -- Crear el Contexto para poder usar p_tab_errror
      SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(17, 'USER_BBDD'))
        INTO v_contexto
        FROM DUAL;

      -- Calcular fecha inicio y fecha fin
      v_finicio := TO_DATE('01' || LPAD(p_mes, 2, '0') || p_anio, 'ddmmyyyy');

      SELECT LAST_DAY(v_finicio)
        INTO v_ffin
        FROM DUAL;

      v_subcuenta := 5;

      -- Generar la información del Formato
      FOR registro IN cur_datos(p_empres, v_finicio, v_ffin) LOOP
         BEGIN
            v_linea := LPAD('' || v_subcuenta, 3, '0');
            v_linea := v_linea || p_separador || registro.finicio;
            v_linea := v_linea || p_separador || registro.ffin;
            v_linea := v_linea || p_separador || registro.codigo_reasegurador;
            v_linea := v_linea || p_separador || registro.pais_origen;
            v_linea := v_linea || p_separador || registro.calificacion;
            v_linea := v_linea || p_separador || registro.agencia_calificadora;
            v_linea := v_linea || p_separador || registro.anio_actualizacion;
            v_linea := v_linea || p_separador || registro.codigo_corredor;
            v_linea := v_linea || p_separador || registro.codigo_tipo_contrato;
            v_linea := v_linea || p_separador || registro.capa;
            v_linea := v_linea || p_separador || registro.ramo;
            v_linea := v_linea || p_separador || registro.pcj_participacion;
            v_subcuenta := v_subcuenta + 5;
            v_lineas.EXTEND;
            v_lineas(v_lineas.LAST) := v_linea;
         END;
      END LOOP;

      -- Almacena la información en el objeto a retornar
      v_tbfichero.EXTEND;
      v_tbfichero(v_tbfichero.LAST) := NEW ob_fichero(p_empres, p_tgestor, p_tformato, '1',
                                                      v_lineas, NULL, NULL, NULL);
      RETURN v_tbfichero;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_fun_formatos.f_get_nomina_reaseguradores', 1,
                     'Error', SQLERRM);
         RAISE;
   END f_get_nomina_reaseguradores;

   /*************************************************************************
    FUNCTION f_get_contratos_noproporcional
       Obtiene los registro de los contratos de reaseguros de tipo no proporcionales
       para la generacion del formato 484.
       param in p_empres: empresa
       param in p_tgestor: codigo de gestor
       param in p_tformato: codigo de formato
       param in p_anio : objeto fichero
       param in p_mes: archivo de carga
       param in p_dia : objeto fichero
       param in p_separador: separador de la tabla fic_gestores
    *************************************************************************/
   FUNCTION f_get_contratos_noproporcional(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros IS
      v_contexto     VARCHAR2(4000);
      v_finicio      DATE;
      v_ffin         DATE;
      v_linea        VARCHAR2(4000);
      v_lineas       t_linea := NEW t_linea();
      v_subcuenta    NUMBER;
      v_tbfichero    t_tabla_ficheros := NEW t_tabla_ficheros();

      CURSOR cur_datos(p_empres IN NUMBER, p_finicio IN DATE, p_ffin IN DATE) IS
         SELECT   ced.tcompani cedente,
                  DECODE(m.sproduc,
                         0, 'no prod',
                         (SELECT tt.cramo   --ttitulo
                            FROM titulopro tt, productos pp
                           WHERE pp.cramo = tt.cramo
                             AND pp.cmodali = tt.cmodali
                             AND pp.ctipseg = tt.ctipseg
                             AND pp.ccolect = tt.ccolect
                             AND tt.cidioma = 2
                             AND pp.sproduc = m.sproduc)) ramo,
                  s.tcontra tipo_contrato, 0 modalidad, s.fconini finicio, s.fconfin ffin,
                  m.ctramo capa, tr.ixlprio prioridad, tr.itottra monto_max_capa,
                  SUM(DECODE(m.cconcep, 23, iimport, 0)) reinstalamiento_xl,
                  SUM(DECODE(m.cconcep, 16, iimport, 0)) tasa_ajuste,
                  SUM(DECODE(m.cconcep, 20, iimport, 0)) prima_minima
             FROM movctatecnica m LEFT JOIN cuadroces c
                  ON(m.ccompani = c.ccompani
                     AND m.nversio = c.nversio
                     AND m.scontra = c.scontra
                     AND m.ctramo = c.ctramo)
                  LEFT JOIN contratos s ON(c.scontra = s.scontra
                                           AND c.nversio = s.nversio)
                  LEFT JOIN tipoctarea t ON(m.cconcep = t.cconcep)
                  LEFT JOIN tramos tr
                  ON(tr.scontra = m.scontra
                     AND tr.nversio = m.nversio
                     AND tr.ctramo = m.ctramo)
                  LEFT JOIN companias ced ON(ced.ccompani = m.ccompapr)
            WHERE m.ctramo IN(6, 7)
              AND m.cempres = p_empres
              AND m.fmovimi >= p_finicio
              AND m.fmovimi <= p_ffin
         GROUP BY ced.tcompani, s.fconini, s.fconfin, m.sproduc, s.tcontra, m.ctramo,
                  tr.ixlprio, tr.itottra
         ORDER BY ced.tcompani, m.sproduc, s.tcontra;
   BEGIN
      -- Crear el Contexto para poder usar p_tab_errror
      SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(17, 'USER_BBDD'))
        INTO v_contexto
        FROM DUAL;

      -- Calcular fecha inicio y fecha fin
      v_finicio := TO_DATE('01' || LPAD(p_mes, 2, '0') || p_anio, 'ddmmyyyy');

      SELECT LAST_DAY(v_finicio)
        INTO v_ffin
        FROM DUAL;

      v_subcuenta := 5;

      -- Generar la información del Formato
      FOR registro IN cur_datos(p_empres, v_finicio, v_ffin) LOOP
         BEGIN
            v_linea := LPAD('' || v_subcuenta, 3, '0');
            v_linea := v_linea || p_separador || registro.ramo;
            v_linea := v_linea || p_separador || registro.tipo_contrato;
            v_linea := v_linea || p_separador || registro.modalidad;
            v_linea := v_linea || p_separador || registro.finicio;
            v_linea := v_linea || p_separador || registro.ffin;
            v_linea := v_linea || p_separador || registro.capa;
            v_linea := v_linea || p_separador || registro.prioridad;
            v_linea := v_linea || p_separador || registro.monto_max_capa;
            v_linea := v_linea || p_separador || registro.reinstalamiento_xl;
            v_linea := v_linea || p_separador || registro.tasa_ajuste;
            v_linea := v_linea || p_separador || registro.prima_minima;
            v_subcuenta := v_subcuenta + 5;
            v_lineas.EXTEND;
            v_lineas(v_lineas.LAST) := v_linea;
         END;
      END LOOP;

      -- Almacena la información en el objeto a retornar
      v_tbfichero.EXTEND;
      v_tbfichero(v_tbfichero.LAST) := NEW ob_fichero(p_empres, p_tgestor, p_tformato, '1',
                                                      v_lineas, NULL, NULL, NULL);
      RETURN v_tbfichero;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_fun_formatos.f_get_contratos_noproporcional', 1,
                     'Error', SQLERRM);
         RAISE;
   END f_get_contratos_noproporcional;

   /*************************************************************************
    FUNCTION f_get_contratos_proporcionales
       Obtiene los registro de los contratos de reaseguros de tipo proporcionales
       para la generacion del formato 483.
       param in p_empres: empresa
       param in p_tgestor: codigo de gestor
       param in p_tformato: codigo de formato
       param in p_anio : objeto fichero
       param in p_mes: archivo de carga
       param in p_dia : objeto fichero
       param in p_separador: separador de la tabla fic_gestores
    *************************************************************************/
   FUNCTION f_get_contratos_proporcionales(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros IS
      v_contexto     VARCHAR2(4000);
      v_finicio      DATE;
      v_ffin         DATE;
      v_linea        VARCHAR2(4000);
      v_lineas       t_linea := NEW t_linea();
      v_subcuenta    NUMBER;
      v_tbfichero    t_tabla_ficheros := NEW t_tabla_ficheros();

      CURSOR cur_datos(p_empres IN NUMBER, p_finicio IN DATE, p_ffin IN DATE) IS
         SELECT '' ramo, '' finicio, '' ffin, '' monto_max_sus, '' pcj_retencion_cuota,
                '' comisiones_esc_cuota, '' limite_perdida_cuota, '' monto_pleno,
                '' num_lineas_mult, '' monto_max_cesion, '' comisiones_esc_exc,
                '' limite_perdida_exc, '' monto_max_cobertura, '' pcj_retencion_facob,
                '' comisiones_esc_fabob, '' limite_perdida_facob
           FROM DUAL;
   BEGIN
      -- Crear el Contexto para poder usar p_tab_errror
      SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(17, 'USER_BBDD'))
        INTO v_contexto
        FROM DUAL;

      -- Calcular fecha inicio y fecha fin
      v_finicio := TO_DATE('01' || LPAD(p_mes, 2, '0') || p_anio, 'ddmmyyyy');

      SELECT LAST_DAY(v_finicio)
        INTO v_ffin
        FROM DUAL;

      v_subcuenta := 5;

      -- Generar la información del Formato
      FOR registro IN cur_datos(p_empres, v_finicio, v_ffin) LOOP
         BEGIN
            v_linea := LPAD('' || v_subcuenta, 3, '0');
            v_linea := v_linea || p_separador || registro.ramo;
            v_linea := v_linea || p_separador || registro.finicio;
            v_linea := v_linea || p_separador || registro.ffin;
            v_linea := v_linea || p_separador || registro.monto_max_sus;
            v_linea := v_linea || p_separador || registro.pcj_retencion_cuota;
            v_linea := v_linea || p_separador || registro.comisiones_esc_cuota;
            v_linea := v_linea || p_separador || registro.limite_perdida_cuota;
            v_linea := v_linea || p_separador || registro.monto_pleno;
            v_linea := v_linea || p_separador || registro.num_lineas_mult;
            v_linea := v_linea || p_separador || registro.monto_max_cesion;
            v_linea := v_linea || p_separador || registro.comisiones_esc_exc;
            v_linea := v_linea || p_separador || registro.limite_perdida_exc;
            v_linea := v_linea || p_separador || registro.monto_max_cobertura;
            v_linea := v_linea || p_separador || registro.pcj_retencion_facob;
            v_linea := v_linea || p_separador || registro.comisiones_esc_fabob;
            v_linea := v_linea || p_separador || registro.limite_perdida_facob;
            v_subcuenta := v_subcuenta + 5;
            v_lineas.EXTEND;
            v_lineas(v_lineas.LAST) := v_linea;
         END;
      END LOOP;

      -- Almacena la información en el objeto a retornar
      v_tbfichero.EXTEND;
      v_tbfichero(v_tbfichero.LAST) := NEW ob_fichero(p_empres, p_tgestor, p_tformato, '1',
                                                      v_lineas, NULL, NULL, NULL);
      RETURN v_tbfichero;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_fun_formatos.f_get_contratos_proporcionales', 1,
                     'Error', SQLERRM);
         RAISE;
   END f_get_contratos_proporcionales;
END pac_fun_formatos;

/

  GRANT EXECUTE ON "AXIS"."PAC_FUN_FORMATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FUN_FORMATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FUN_FORMATOS" TO "PROGRAMADORESCSI";
