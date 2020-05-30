create or replace PACKAGE BODY pac_formatos_conf AS
   /******************************************************************************
    NOMBRE:      pac_formatos_conf
    PROPoSITO:   Funciones para obtener la data de cada formato para Confianza

    REVISIONES:
    Ver        Fecha        Autor             DescripciON
    ---------  ----------  ---------------  ------------------------------------
    1.0        06/09/2013   RCM              1. CreaciON del package.
    2.0        06/05/2014   DEV              1. 0026811: POSRE600-(POSR600)-Informes y reportes-Tecnico - Listados oficiales
    3.0        27/03/2017   HAG              0045754: Formato 394_Fasecolda_Circular externa 014 de 2016 - Campos Deslizamiento SMLV
    3.1        10/04/2017   HAG              0038884: Deshabilitar formato 8-fasecolda e incluir campos en formato 7
   ******************************************************************************/
   TYPE t_array_numbers IS VARRAY(20) OF NUMBER;

   -- BUG 0026180 - 28/08/2014 - JMF
   -- Quitar que sean polizas con provisiones
   -- Interes tecnico en funcion
   -- Nombre en mayusculas
   -- invalidez_vejez trunc
   -- Excluir polizas que no tengan persona para recibir la mesada
   -- Estudios_B parentesto valido
   -- Estudios_C parentesto valido
   -- Estudios_D parentesto valido

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

      CURSOR cur_datos(p_empres IN NUMBER, p_finicio IN DATE) IS
     SELECT  (select SUBSTR(A.CNV_SPR,1,instr(A.CNV_SPR,'|')-1)from CNVPRODUCTOS_EXT a,
          productos b where b.cramo= agr.cramo and rownum=1 and A.SPRODUC =B.SPRODUC) as  ramo
      , con.FECINI vigencia_desde, con.FCONFIN as  vigencia_hasta
            ,    (SELECT distinct con2.iretenc / 1000000
                   FROM contratos con2 INNER JOIN tramos tra2
                        ON tra2.scontra = con2.scontra
                      AND tra2.nversio = con2.nversio
                  WHERE con2.scontra = con.scontra
                    AND con2.nversio = con.nversio
                    AND tra2.ctramo IN(1)) monto_pleno_cuota
                ,(SELECT distinct DECODE(tra2.nplenos,
                               NULL, ROUND(((tra2.itottra * con2.iretenc) / 100), 1),
                               tra2.nplenos)
                   FROM contratos con2 INNER JOIN tramos tra2
                        ON tra2.scontra = con2.scontra
                      AND tra2.nversio = con2.nversio
                  WHERE con2.scontra = con.scontra
                    AND con2.nversio = con.nversio
                    AND tra2.ctramo IN(1)) porcentaje_ret_cuota,
                '2' comision_escalonada_cuota, '2' limite_perdida_cuota
               ,
               (SELECT sum( con2.iretenc) / 1000000
                   FROM contratos con2 INNER JOIN tramos tra2
                        ON tra2.scontra = con2.scontra
                      AND tra2.nversio = con2.nversio
                  WHERE con2.scontra = con.scontra
                    AND con2.nversio = con.nversio
                    AND tra2.ctramo IN(2,3)) monto_pleno_exd
                , (SELECT sum (DECODE(tra2.nplenos,
                               NULL, ROUND(tra2.itottra / con2.iretenc, 1),
                               tra2.nplenos))
                   FROM contratos con2 INNER JOIN tramos tra2
                        ON tra2.scontra = con2.scontra
                      AND tra2.nversio = con2.nversio
                  WHERE con2.scontra = con.scontra
                    AND con2.nversio = con.nversio
                    AND tra2.ctramo IN(2, 3)) no_pleno_exd
              , (SELECT sum( tra2.itottra) / 1000000
                   FROM  (select a.SCONTRA, a.FECINI ,B.FCONFINAUX as FCONFIN ,NVERSIO
        from (select SCONTRA,max(FCONINI)FECINI from CONTRATOS group by SCONTRA )a, CONTRATOS B
        where a.SCONTRA=B.SCONTRA and a.FECINI=B.FCONINI) con2
           INNER JOIN tramos tra2
                        ON tra2.scontra = con2.scontra
                      AND tra2.nversio = con2.nversio
                  WHERE con2.scontra = con.scontra
                    AND con2.nversio = con.nversio
                    AND tra2.ctramo IN(2, 3)) monto_cesion_exd
               , '2' comision_escalonada_exd, '2' limite_perdida_exd
              ,  (SELECT distinct con2.iretenc / 1000000
                   FROM contratos con2 INNER JOIN tramos tra2
                        ON tra2.scontra = con2.scontra
                      AND tra2.nversio = con2.nversio
                  WHERE con2.scontra = con.scontra
                    AND con2.nversio = con.nversio
                    AND tra2.ctramo IN(4)) monto_pleno_facob,
                (SELECT distinct DECODE(tra2.nplenos,
                               NULL, ROUND(((tra2.itottra * con2.iretenc) / 100), 1),
                               tra2.nplenos)
                   FROM contratos con2 INNER JOIN tramos tra2
                        ON tra2.scontra = con2.scontra
                      AND tra2.nversio = con2.nversio
                  WHERE con2.scontra = con.scontra
                    AND con2.nversio = con.nversio
                    AND tra2.ctramo IN(4)) porcentaje_ret_facob
                ,'2' comision_escalonada_facob, '2' limite_perdida_facob
 FROM codicontratos cod,
        (select a.SCONTRA, a.FECINI ,B.FCONFINAUX as FCONFIN ,NVERSIO
        from (select SCONTRA,max(FCONINI)FECINI from CONTRATOS group by SCONTRA )a, CONTRATOS B
        where a.SCONTRA=B.SCONTRA and a.FECINI=B.FCONINI) con
       ,tramos tra, agr_contratos agr
          where cod.scontra=con.scontra
           and  con.scontra= tra.scontra
           AND  con.nversio=tra.nversio
           and  cod.scontra = agr.scontra
         and tra.ctramo IN(1, 2, 3, 4)
            AND cod.cempres = p_empres
            AND con.FECINI >= p_finicio
            AND NVL(con.fconfin, ADD_MONTHS(con.FECINI, 12)) >= p_finicio;
          /* SELECT agr.cramo ramo,
  con.FECINI vigencia_desde, con.fconfin vigencia_hasta
            ,    (SELECT distinct con2.iretenc / 1000000
                   FROM contratos con2 INNER JOIN tramos tra2
                        ON tra2.scontra = con2.scontra
                      AND tra2.nversio = con2.nversio
                  WHERE con2.scontra = con.scontra
                    AND con2.nversio = con.nversio
                    AND tra2.ctramo IN(1)) monto_pleno_cuota
                ,(SELECT distinct DECODE(tra2.nplenos,
                               NULL, ROUND(((tra2.itottra * con2.iretenc) / 100), 1),
                               tra2.nplenos)
                   FROM contratos con2 INNER JOIN tramos tra2
                        ON tra2.scontra = con2.scontra
                      AND tra2.nversio = con2.nversio
                  WHERE con2.scontra = con.scontra
                    AND con2.nversio = con.nversio
                    AND tra2.ctramo IN(1)) porcentaje_ret_cuota,
                '2' comision_escalonada_cuota, '2' limite_perdida_cuota
               ,
               (SELECT sum( con2.iretenc) / 1000000
                   FROM contratos con2 INNER JOIN tramos tra2
                        ON tra2.scontra = con2.scontra
                      AND tra2.nversio = con2.nversio
                  WHERE con2.scontra = con.scontra
                    AND con2.nversio = con.nversio
                    AND tra2.ctramo IN(2,3)) monto_pleno_exd
                , (SELECT sum (DECODE(tra2.nplenos,
                               NULL, ROUND(tra2.itottra / con2.iretenc, 1),
                               tra2.nplenos))
                   FROM contratos con2 INNER JOIN tramos tra2
                        ON tra2.scontra = con2.scontra
                      AND tra2.nversio = con2.nversio
                  WHERE con2.scontra = con.scontra
                    AND con2.nversio = con.nversio
                    AND tra2.ctramo IN(2, 3)) no_pleno_exd
              , (SELECT sum( tra2.itottra) / 1000000
                   FROM  (select a.SCONTRA, a.FECINI ,NVL(B.FCONFIN,TO_DATE('01/12/9999','dd/mm/yyyy'))as FCONFIN,NVERSIO,iretenc
        from (select SCONTRA,max(FCONINI)FECINI from CONTRATOS group by SCONTRA )a, CONTRATOS B
        where a.SCONTRA=B.SCONTRA and a.FECINI=B.FCONINI) con2 INNER JOIN tramos tra2
                        ON tra2.scontra = con2.scontra
                      AND tra2.nversio = con2.nversio
                  WHERE con2.scontra = con.scontra
                    AND con2.nversio = con.nversio
                    AND tra2.ctramo IN(2, 3)) monto_cesion_exd
               , '2' comision_escalonada_exd, '2' limite_perdida_exd
              ,  (SELECT distinct con2.iretenc / 1000000
                   FROM contratos con2 INNER JOIN tramos tra2
                        ON tra2.scontra = con2.scontra
                      AND tra2.nversio = con2.nversio
                  WHERE con2.scontra = con.scontra
                    AND con2.nversio = con.nversio
                    AND tra2.ctramo IN(4)) monto_pleno_facob,
                (SELECT distinct DECODE(tra2.nplenos,
                               NULL, ROUND(((tra2.itottra * con2.iretenc) / 100), 1),
                               tra2.nplenos)
                   FROM contratos con2 INNER JOIN tramos tra2
                        ON tra2.scontra = con2.scontra
                      AND tra2.nversio = con2.nversio
                  WHERE con2.scontra = con.scontra
                    AND con2.nversio = con.nversio
                    AND tra2.ctramo IN(4)) porcentaje_ret_facob
                ,'2' comision_escalonada_facob, '2' limite_perdida_facob
 FROM codicontratos cod,
 (select a.SCONTRA, a.FECINI ,NVL(B.FCONFIN,TO_DATE('01/12/9999','dd/mm/yyyy'))as FCONFIN,NVERSIO
        from (select SCONTRA,max(FCONINI)FECINI from CONTRATOS group by SCONTRA )a, CONTRATOS B
        where a.SCONTRA=B.SCONTRA and a.FECINI=B.FCONINI) con,tramos tra, agr_contratos agr
          where cod.scontra=con.scontra
           and  con.scontra= tra.scontra
           AND  con.nversio=tra.nversio
           and  cod.scontra = agr.scontra
         and tra.ctramo IN(1, 2, 3, 4)
            AND cod.cempres = p_empres
            AND p_finicio >= con.FECINI
            AND p_finicio <= NVL(con.fconfin, ADD_MONTHS(con.FECINI, 12));*/
   BEGIN
      -- Calcular fecha inicio y fecha fin
      v_finicio := TO_DATE('01' || LPAD(NVL(p_mes, '01'), 2, '0') || p_anio, 'ddmmyyyy');
      v_subcuenta := 5;

      -- Generar la informaciON del Formato
      FOR registro IN cur_datos(p_empres, v_finicio) LOOP
         BEGIN
            v_linea := LPAD('' || v_subcuenta, 6, '0');
            v_linea := v_linea || p_separador || registro.ramo;
            v_linea := v_linea || p_separador || registro.vigencia_desde;
            v_linea := v_linea || p_separador || registro.vigencia_hasta;
            v_linea := v_linea || p_separador || registro.monto_pleno_cuota;
            v_linea := v_linea || p_separador || registro.porcentaje_ret_cuota;
            v_linea := v_linea || p_separador || registro.comision_escalonada_cuota;
            v_linea := v_linea || p_separador || registro.limite_perdida_cuota;
            v_linea := v_linea || p_separador || registro.monto_pleno_exd;
            v_linea := v_linea || p_separador || registro.no_pleno_exd;
            v_linea := v_linea || p_separador || registro.monto_cesion_exd;
            v_linea := v_linea || p_separador || registro.comision_escalonada_exd;
            v_linea := v_linea || p_separador || registro.limite_perdida_exd;
            v_linea := v_linea || p_separador || registro.monto_pleno_facob;
            v_linea := v_linea || p_separador || registro.porcentaje_ret_facob;
            v_linea := v_linea || p_separador || registro.comision_escalonada_facob;
            v_linea := v_linea || p_separador || registro.limite_perdida_facob;
            v_linea := v_linea || p_separador;
            v_subcuenta := v_subcuenta + 5;
            v_lineas.EXTEND;
            v_lineas(v_lineas.LAST) := v_linea;
         END;
      END LOOP;

      -- Almacena la informaciON en el objeto a retornar
      IF (v_lineas.COUNT > 0) THEN
         v_tbfichero.EXTEND;
         v_tbfichero(v_tbfichero.LAST) := NEW ob_fichero(p_empres, p_tgestor, p_tformato, '1',
                                                         v_lineas, NULL, NULL, NULL);
      END IF;

      RETURN v_tbfichero;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_formatos_CONF.f_get_contratos_proporcionales', 1,
                     'Error no controlado', SQLERRM);
         RAISE;
   END f_get_contratos_proporcionales;


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

      CURSOR cur_datos(p_empres IN NUMBER, p_finicio IN DATE) IS
          SELECT (select SUBSTR(A.CNV_SPR,1,instr(A.CNV_SPR,'|')-1)from CNVPRODUCTOS_EXT a,
          productos b where b.cramo= agr.cramo and rownum=1 and A.SPRODUC =B.SPRODUC) as ramo,
                CASE
                   WHEN cod2.ctiprea = 3
                   AND cdevento = 0 THEN 1
                   WHEN cod2.ctiprea = 3
                   AND cdevento = 1 THEN 3
                   ELSE 0
                END tipo_contrato,
                '1' modalidad, con2.fconini vigencia_desde, con2.fconfin vigencia_fin,
                TO_NUMBER(ctramo)
                - (SELECT MIN(TO_NUMBER(ctramo) - 1)
                     FROM tramos t
                    WHERE t.scontra = tra2.scontra
                      AND t.nversio = tra2.nversio) no_capa,
                ixlprio prioridad, itottra monto_max_capa,
                crepos || ' al ' || preest || '%' no_porc_reinst_cpa, ptasaajuste porc_ajuste,
                ROUND(ipmd / 1000000, 0) prima_min
           FROM (select a.SCONTRA, a.FECINI as  fconini ,B.FCONFINAUX as FCONFIN ,NVERSIO
        from (select SCONTRA,max(FCONINI)FECINI from CONTRATOS group by SCONTRA )a, CONTRATOS B
        where a.SCONTRA=B.SCONTRA and a.FECINI=B.FCONINI) con2
           INNER JOIN codicontratos cod2 ON con2.scontra = cod2.scontra
                INNER JOIN agr_contratos agr ON con2.scontra = agr.scontra
                INNER JOIN tramos tra2
                ON tra2.scontra = con2.scontra
              AND tra2.nversio = con2.nversio
          WHERE cod2.cempres = 24
            AND tra2.ctramo NOT IN(1, 2, 3, 4)
            AND con2.fconini  >=  p_finicio
            AND NVL(con2.fconfin, ADD_MONTHS(con2.fconini, 12)) >= p_finicio  ;
        /* SELECT agr.cramo ramo,
                CASE
                   WHEN ctiprea = 3
                   AND cdevento = 0 THEN 1
                   WHEN ctiprea = 3
                   AND cdevento = 1 THEN 3
                   ELSE 0
                END tipo_contrato,
                '1' modalidad, fconini vigencia_desde, fconfin vigencia_fin,
                TO_NUMBER(ctramo)
                - (SELECT MIN(TO_NUMBER(ctramo) - 1)
                     FROM tramos t
                    WHERE t.scontra = tra2.scontra
                      AND t.nversio = tra2.nversio) no_capa,
                ixlprio prioridad, itottra monto_max_capa,
                crepos || ' al ' || preest || '%' no_porc_reinst_cpa, ptasaajuste porc_ajuste,
                ROUND(ipmd / 1000000, 0) prima_min
           FROM contratos con2 INNER JOIN codicontratos cod2 ON con2.scontra = cod2.scontra
                INNER JOIN agr_contratos agr ON con2.scontra = agr.scontra
                INNER JOIN tramos tra2
                ON tra2.scontra = con2.scontra
              AND tra2.nversio = con2.nversio
          WHERE cod2.cempres = p_empres
            AND tra2.ctramo NOT IN(1, 2, 3, 4)
            AND p_finicio >= con2.fconini
            AND p_finicio <= NVL(con2.fconfin, ADD_MONTHS(con2.fconini, 12));*/
   BEGIN
      -- Calcular fecha inicio y fecha fin
      v_finicio := TO_DATE('01' || LPAD(p_mes, 2, '0') || p_anio, 'ddmmyyyy');
      v_subcuenta := 5;

      -- Generar la informaciON del Formato
      FOR registro IN cur_datos(p_empres, v_finicio) LOOP
         BEGIN
            v_linea := LPAD('' || v_subcuenta, 6, '0');
            v_linea := v_linea || p_separador || registro.ramo;
            v_linea := v_linea || p_separador || registro.tipo_contrato;
            v_linea := v_linea || p_separador || registro.modalidad;
            v_linea := v_linea || p_separador || registro.vigencia_desde;
            v_linea := v_linea || p_separador || registro.vigencia_fin;
            v_linea := v_linea || p_separador || registro.no_capa;
            v_linea := v_linea || p_separador || registro.prioridad;
            v_linea := v_linea || p_separador || registro.monto_max_capa;
            v_linea := v_linea || p_separador || registro.no_porc_reinst_cpa;
            v_linea := v_linea || p_separador || registro.porc_ajuste;
            v_linea := v_linea || p_separador || registro.prima_min;
            v_linea := v_linea || p_separador;
            v_subcuenta := v_subcuenta + 5;
            v_lineas.EXTEND;
            v_lineas(v_lineas.LAST) := v_linea;
         END;
      END LOOP;

      -- Almacena la informaciON en el objeto a retornar
      IF (v_lineas.COUNT > 0) THEN
         v_tbfichero.EXTEND;
         v_tbfichero(v_tbfichero.LAST) := NEW ob_fichero(p_empres, p_tgestor, p_tformato, '1',
                                                         v_lineas, NULL, NULL, NULL);
      END IF;

      RETURN v_tbfichero;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_formatos_conf.f_get_contratos_noproporcional', 1,
                     'Error no controlado', SQLERRM);
         RAISE;
   END f_get_contratos_noproporcional;

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

      CURSOR cur_datos(p_empres IN NUMBER, p_finicio IN DATE) IS
         SELECT con.fconini vigencia_desde, con.fconfin vigencia_hasta,
                TO_CHAR(LPAD(com.cpais, 3, '0') || LPAD(com.CSUPERFINAN, 5, '0')) codigo_rea,
                TO_CHAR(LPAD(com.cpais, 3, '0')) pais_rea,
                ff_desvalorfijo(800100, 8, com.ccalifi) calificacion,
                ff_desvalorfijo(800101, 8, com.centicalifi) agencia_cal,
                com.fmovimi fecha_act,   --fecha de actualizacion de compa¿ia pero no exclusivamente del la calificacion ,
                                      ces.ccorred codigo_corredor,
                CASE
                   WHEN tra.ctramo = 1 THEN 1
                   WHEN tra.ctramo IN(2, 3) THEN 2
                   WHEN tra.ctramo = 4 THEN 3
                   WHEN com.ctiprea = 3  AND cdevento = 0 THEN 4
                   WHEN com.ctiprea = 3  AND cdevento = 1 THEN 6
                   ELSE 8
                END clase_contrato,
                TO_NUMBER(tra.ctramo)
                - (SELECT MIN(TO_NUMBER(ctramo) - 1)
                     FROM tramos t
                    WHERE t.scontra = tra.scontra
                      AND t.nversio = tra.nversio) no_capa,
               (select SUBSTR(A.CNV_SPR,1,instr(A.CNV_SPR,'|')-1)from CNVPRODUCTOS_EXT a,
          productos b where b.cramo= agr.cramo and rownum=1 and A.SPRODUC =B.SPRODUC) ramo
                , ces.pcesion
           FROM (select a.SCONTRA, a.FECINI as  fconini ,B.FCONFINAUX as FCONFIN ,NVERSIO
        from (select SCONTRA,max(FCONINI)FECINI from CONTRATOS group by SCONTRA )a, CONTRATOS B
        where a.SCONTRA=B.SCONTRA and a.FECINI=B.FCONINI) con
           INNER JOIN codicontratos cod ON con.scontra = cod.scontra
                INNER JOIN tramos tra ON tra.scontra = con.scontra
                                    AND tra.nversio = con.nversio
                INNER JOIN cuadroces ces
                ON con.scontra = ces.scontra
              AND con.nversio = ces.nversio
              AND tra.ctramo = ces.ctramo
                INNER JOIN companias com ON ces.ccompani = com.ccompani
                INNER JOIN agr_contratos agr ON con.scontra = agr.scontra
          WHERE cod.cempres = p_empres
            AND con.fconini  >=  p_finicio
            AND NVL(con.fconfin, ADD_MONTHS(con.fconini, 12)) >= p_finicio;
    /* SELECT con.fconini vigencia_desde, con.fconfin vigencia_hasta,
                TO_CHAR(LPAD(com.cpais, 3, '0') || LPAD(com.CSUPERFINAN, 5, '0')) codigo_rea,
                TO_CHAR(LPAD(com.cpais, 3, '0')) pais_rea,
                ff_desvalorfijo(800100, 8, com.ccalifi) calificacion,
                ff_desvalorfijo(800101, 8, com.centicalifi) agencia_cal,
                com.fmovimi fecha_act,   --fecha de actualizacion de compa¿ia pero no exclusivamente del la calificacion ,
                                      ces.ccorred codigo_corredor,
                CASE
                   WHEN tra.ctramo = 1 THEN 1
                   WHEN tra.ctramo IN(2, 3) THEN 2
                   WHEN tra.ctramo = 4 THEN 3
                   WHEN ctiprea = 3
                   AND cdevento = 0 THEN 4
                   WHEN ctiprea = 3
                   AND cdevento = 1 THEN 6
                   ELSE 8
                END clase_contrato,
                TO_NUMBER(tra.ctramo)
                - (SELECT MIN(TO_NUMBER(ctramo) - 1)
                     FROM tramos t
                    WHERE t.scontra = tra.scontra
                      AND t.nversio = tra.nversio) no_capa,
                agr.cramo ramo, ces.pcesion
           FROM contratos con INNER JOIN codicontratos cod ON con.scontra = cod.scontra
                INNER JOIN tramos tra ON tra.scontra = con.scontra
                                    AND tra.nversio = con.nversio
                INNER JOIN cuadroces ces
                ON con.scontra = ces.scontra
              AND con.nversio = ces.nversio
              AND tra.ctramo = ces.ctramo
                INNER JOIN companias com ON ces.ccompani = com.ccompani
                INNER JOIN agr_contratos agr ON con.scontra = agr.scontra
          WHERE cod.cempres = p_empres
            AND p_finicio >= con.fconini
            AND p_finicio <= NVL(con.fconfin, ADD_MONTHS(con.fconini, 12));*/
   BEGIN
      -- Calcular fecha inicio y fecha fin
      v_finicio := TO_DATE('01' || LPAD(p_mes, 2, '0') || p_anio, 'ddmmyyyy');
      v_subcuenta := 5;
      v_linea := '';

      -- Generar la informaciON del Formato
      FOR registro IN cur_datos(p_empres, v_finicio) LOOP
         BEGIN
            v_linea := LPAD('' || v_subcuenta, 6, '0');
            v_linea := v_linea || p_separador || registro.vigencia_desde;
            v_linea := v_linea || p_separador || registro.vigencia_hasta;
            v_linea := v_linea || p_separador || registro.codigo_rea;
            v_linea := v_linea || p_separador || registro.pais_rea;
            v_linea := v_linea || p_separador || registro.calificacion;
            v_linea := v_linea || p_separador || registro.agencia_cal;
            v_linea := v_linea || p_separador || registro.fecha_act;
            v_linea := v_linea || p_separador || registro.codigo_corredor;
            v_linea := v_linea || p_separador || registro.clase_contrato;
            v_linea := v_linea || p_separador || registro.no_capa;
            v_linea := v_linea || p_separador || registro.ramo;
            v_linea := v_linea || p_separador || registro.pcesion;
            v_linea := v_linea || p_separador;
            v_subcuenta := v_subcuenta + 5;
            v_lineas.EXTEND;
            v_lineas(v_lineas.LAST) := v_linea;
         END;
      END LOOP;

      -- Almacena la informaciON en el objeto a retornar
      IF (v_lineas.COUNT > 0) THEN
         v_tbfichero.EXTEND;
         v_tbfichero(v_tbfichero.LAST) := NEW ob_fichero(p_empres, p_tgestor, p_tformato, '1',
                                                         v_lineas, NULL, NULL, NULL);
      END IF;

      RETURN v_tbfichero;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_formatos_conf.f_get_nomina_reaseguradores', 1,
                     'Error no controlado', SQLERRM);
         RAISE;
   END f_get_nomina_reaseguradores;

   /*************************************************************************
    FUNCTION f_get_primas_cedidas
       Obtiene los registro de las primas cedidas en reaseguros
       para la generacion del formato 487
       param in p_empres: empresa
       param in p_tgestor: codigo de gestor
       param in p_tformato: codigo de formato
       param in p_anio : objeto fichero
       param in p_mes: archivo de carga
       param in p_dia : objeto fichero
       param in p_separador: separador de la tabla fic_gestores
    *************************************************************************/
   FUNCTION f_get_primas_cedidas(
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
      v_lineas       t_linea := NEW t_linea();--OBJETO VARCHAR2(4000)
      v_subcuenta    NUMBER;
      v_tbfichero    t_tabla_ficheros := NEW t_tabla_ficheros();--OBJETO QUE RECIBE LOS PARAMETROS INICIALES Y QUE A SU VEZ INGRESA LOS CAMPOS DEL FORMATO EN UNA VARIABLE OBJETO DE TIPO T_LINEA,
                                                                -- PARA ASI HACER COINCIDENCIA CON LOS CAMPOS DE LA TABLA "FIC_COLUMNA_FORMATOS" FILTRANDO POR GESTOR Y TIPO DE FORMATO
                                                                -- Y ENVIARLOS A UN ARCHIVO .CSV
      CURSOR cur_datos(p_empres IN NUMBER, p_finicio IN DATE, p_ffin IN DATE) IS
        SELECT LPAD(com.cpais, 3, '0') || LPAD(com.CSUPERFINAN, 5, '0') codigo_rea,--cambio de codigo reasegurador entendiendo que el que se pide es el de la superfinanciera 25/04/2017
                --LPAD(com.cpais, 3, '0') || LPAD(com.ccompani, 5, '0') codigo_rea,
                LPAD(com.cpais, 3, '0') pais_rea,
                ff_desvalorfijo(800100, 8, com.ccalifi) calificacion,
                ff_desvalorfijo(800101, 8, com.centicalifi) agencia_cal,
                com.fmovimi fecha_act,   --fecha de actualizacion de compa¿ia pero no exclusivamente del la calificacion ,
                CASE
                   WHEN cta.ctramo IN(4, 5) THEN (select distinct comp.CSUPERFINAN from companias comp where  cta.ccorred=comp.CCOMPANI)
                   ELSE
                (select distinct comp.CSUPERFINAN from companias comp where comp.CCOMPANI=
                   (SELECT ces.ccorred  FROM cuadroces ces  WHERE cta.scontra = ces.scontra  AND cta.nversio = ces.nversio AND cta.ctramo = ces.ctramo  AND cta.ccompani = ces.ccompani)
                )
                END-- se cambia por el codigo de superfinanciera de la tabla companias
                codigo_corredor,
                CASE
                   WHEN cta.ctramo IN(1, 2, 3) THEN 1
                   WHEN cta.ctramo IN(4, 5) THEN 3
                   WHEN((com.ctiprea = 3
                         AND cdevento = 0)
                        OR(com.ctiprea = 3
                           AND cdevento = 1)) THEN 2
                   ELSE 4
                END clase_contrato,
                  (select SUBSTR(A.CNV_SPR,1,instr(A.CNV_SPR,'|')-1)from CNVPRODUCTOS_EXT a,
                   productos b where b.cramo= agr.cramo and rownum=1 and A.SPRODUC =B.SPRODUC) as  ramo
                , con.fconini vigencia_desde, con.fconfin vigencia_hasta,
                NVL(pri.comision, '0') prima, NVL(comi.comision, '0') comis,
                NVL(cot.comision, '0') costo
           FROM ctatecnica cta INNER JOIN companias com ON cta.ccompani = com.ccompani
                INNER JOIN
        (select a.SCONTRA, a.FCONINI ,B.FCONFINAUX FCONFIN,NVERSIO,ICAPACI,CLOSSCORRIDOR
                 from (select SCONTRA,max(FCONINI)FCONINI from CONTRATOS group by SCONTRA )a, CONTRATOS B
                 where a.SCONTRA=B.SCONTRA and a.FCONINI=B.FCONINI) con
                ON cta.scontra = con.scontra
              AND cta.nversio = con.nversio
                INNER JOIN codicontratos cod ON con.scontra = cod.scontra
                INNER JOIN agr_contratos agr ON con.scontra = agr.scontra
                LEFT JOIN
                (SELECT   cempres, ccompani, scontra, nversio, ctramo, sproduc,------------------------------------------------------------------------------------
                          SUM(iimport) comision
                     FROM movctatecnica
                    WHERE cconcep IN(2)---------------------------------------------CONCEPTO DE COMISION      /*PRIMAS CEDIDAS NETAS*/Primas con Descuentos
                      AND fefecto >= p_finicio
                      AND fefecto <= p_ffin
                 GROUP BY cempres, ccompani, scontra, nversio, ctramo, sproduc) comi--------------------------------------------------------------------------------
                ON comi.ccompani = cta.ccompani
              AND comi.nversio = cta.nversio
              AND comi.scontra = cta.scontra
              AND comi.ctramo = cta.ctramo
              AND comi.cempres = cta.cempres
              AND comi.sproduc = cta.sproduc
                LEFT JOIN
                (SELECT   cempres, ccompani, scontra, nversio, ctramo, sproduc,-------------------------------------------------------------------------------------
                          SUM(iimport) comision
                     FROM movctatecnica
                    WHERE cconcep = 1-----------------------------------------------CONCEPTO DE PRIMA           /*PRIMAS CEDIDAS BRUTAS*/Primas sin descuentos
                      AND fefecto >= p_finicio
                      AND fefecto <= p_ffin
                 GROUP BY cempres, ccompani, scontra, nversio, ctramo, sproduc) pri----------------------------------------------------------------------------------
                ON pri.ccompani = cta.ccompani
              AND pri.nversio = cta.nversio
              AND pri.scontra = cta.scontra
              AND pri.ctramo = cta.ctramo
              AND pri.cempres = cta.cempres
              AND pri.sproduc = cta.sproduc
                LEFT JOIN
                (SELECT   cempres, ccompani, scontra, nversio, ctramo, sproduc,---------------------------------------------------------------------------------------
                          SUM(iimport) comision
                     FROM movctatecnica
                    WHERE cconcep = 22---------------------------------------------CONCEPTO DE COSTO          /*COSTO CONTRATOS*/
                      AND fefecto >= p_finicio
                      AND fefecto <= p_ffin
                 GROUP BY cempres, ccompani, scontra, nversio, ctramo, sproduc) cot-------------------------------------------------------------------------------------
                ON cot.ccompani = cta.ccompani
              AND cot.nversio = cta.nversio
              AND cot.scontra = cta.scontra
              AND cot.ctramo = cta.ctramo
              AND cot.cempres = cta.cempres
              AND cot.sproduc = cta.sproduc
          WHERE cod.cempres = p_empres
            AND(pri.comision IS NOT NULL
                OR cot.comision IS NOT NULL);
     /*  SELECT LPAD(com.cpais, 3, '0') || LPAD(com.CSUPERFINAN, 5, '0') codigo_rea,--cambio de codigo reasegurador entendiendo que el que se pide es el de la superfinanciera 25/04/2017
                --LPAD(com.cpais, 3, '0') || LPAD(com.ccompani, 5, '0') codigo_rea,
                LPAD(com.cpais, 3, '0') pais_rea,
                ff_desvalorfijo(800100, 8, com.ccalifi) calificacion,
                ff_desvalorfijo(800101, 8, com.centicalifi) agencia_cal,
                com.fmovimi fecha_act,   --fecha de actualizacion de compa¿ia pero no exclusivamente del la calificacion ,
                CASE
                   WHEN cta.ctramo IN(4, 5) THEN cta.ccorred
                   ELSE (SELECT ces.ccorred
                           FROM cuadroces ces
                          WHERE cta.scontra = ces.scontra
                            AND cta.nversio = ces.nversio
                            AND cta.ctramo = ces.ctramo
                            AND cta.ccompani = ces.ccompani)
                END codigo_corredor,
                CASE
                   WHEN cta.ctramo IN(1, 2, 3) THEN 1
                   WHEN cta.ctramo IN(4, 5) THEN 3
                   WHEN((ctiprea = 3
                         AND cdevento = 0)
                        OR(ctiprea = 3
                           AND cdevento = 1)) THEN 2
                   ELSE 4
                END clase_contrato,
                agr.cramo ramo, con.fconini vigencia_desde, con.fconfin vigencia_hasta,
                NVL(pri.comision, '0') prima, NVL(comi.comision, '0') comis,
                NVL(cot.comision, '0') costo
           FROM ctatecnica cta INNER JOIN companias com ON cta.ccompani = com.ccompani
                INNER JOIN contratos con
                ON cta.scontra = con.scontra
              AND cta.nversio = con.nversio
                INNER JOIN codicontratos cod ON con.scontra = cod.scontra
                INNER JOIN agr_contratos agr ON con.scontra = agr.scontra
                LEFT JOIN
                (SELECT   cempres, ccompani, scontra, nversio, ctramo, sproduc,------------------------------------------------------------------------------------
                          SUM(iimport) comision
                     FROM movctatecnica
                    WHERE cconcep IN(2) ---------------------------------------------CONCEPTO DE COMISION      --PRIMAS CEDIDAS NETAS--Primas con Descuentos
                      AND fefecto >= p_finicio
                      AND fefecto <= p_ffin
                 GROUP BY cempres, ccompani, scontra, nversio, ctramo, sproduc) comi--------------------------------------------------------------------------------
                ON comi.ccompani = cta.ccompani
              AND comi.nversio = cta.nversio
              AND comi.scontra = cta.scontra
              AND comi.ctramo = cta.ctramo
              AND comi.cempres = cta.cempres
              AND comi.sproduc = cta.sproduc
                LEFT JOIN
                (SELECT   cempres, ccompani, scontra, nversio, ctramo, sproduc,-------------------------------------------------------------------------------------
                          SUM(iimport) comision
                     FROM movctatecnica
                    WHERE cconcep = 1 -----------------------------------------------CONCEPTO DE PRIMA           --PRIMAS CEDIDAS BRUTAS--Primas sin descuentos
                      AND fefecto >= p_finicio
                      AND fefecto <= p_ffin
                 GROUP BY cempres, ccompani, scontra, nversio, ctramo, sproduc) pri----------------------------------------------------------------------------------
                ON pri.ccompani = cta.ccompani
              AND pri.nversio = cta.nversio
              AND pri.scontra = cta.scontra
              AND pri.ctramo = cta.ctramo
              AND pri.cempres = cta.cempres
              AND pri.sproduc = cta.sproduc
                LEFT JOIN
                (SELECT   cempres, ccompani, scontra, nversio, ctramo, sproduc,---------------------------------------------------------------------------------------
                          SUM(iimport) comision
                     FROM movctatecnica
                    WHERE cconcep = 22 ---------------------------------------------CONCEPTO DE COSTO          --COSTO CONTRATOS--
                      AND fefecto >= p_finicio
                      AND fefecto <= p_ffin
                 GROUP BY cempres, ccompani, scontra, nversio, ctramo, sproduc) cot-------------------------------------------------------------------------------------
                ON cot.ccompani = cta.ccompani
              AND cot.nversio = cta.nversio
              AND cot.scontra = cta.scontra
              AND cot.ctramo = cta.ctramo
              AND cot.cempres = cta.cempres
              AND cot.sproduc = cta.sproduc
          WHERE cod.cempres = p_empres
            AND(pri.comision IS NOT NULL
                OR cot.comision IS NOT NULL);*/
   BEGIN

   /*P_CONTROL_ERROR('ERR_GET_PRIMA_CEDIDA','PAC_FORMATOS_CONF',p_empres || ', ' || p_tgestor || ', ' || p_tformato || ', ' || p_anio || ', ' || p_mes || ', ' || p_dia || ', ' || p_separador );
   SELECT * FROM CONTROL_ERROR WHERE UPPER(ID)='ERR_GET_PRIMA_CEDIDA'*/ --HABILITAR SI SE NECESITA VALIDAR ALGUN ERROR--


      IF TRIM(p_mes) = '0' THEN
         -- Calcular fecha inicio y fecha fin
         v_finicio := TO_DATE('01' || '01' || p_anio, 'ddmmyyyy');
      ELSE
         v_finicio := TO_DATE('01' || LPAD(p_mes, 2, '0') || p_anio, 'ddmmyyyy');
      END IF;

      SELECT LAST_DAY(v_finicio)
        INTO v_ffin
        FROM DUAL;

      v_subcuenta := 5;

      -- Generar la informaciON del Formato
      FOR registro IN cur_datos(p_empres, v_finicio, v_ffin) LOOP
         v_linea := LPAD('' || v_subcuenta, 6, '0');
         v_linea := v_linea || p_separador || registro.codigo_rea;
         v_linea := v_linea || p_separador || registro.pais_rea;
         v_linea := v_linea || p_separador || registro.calificacion;
         v_linea := v_linea || p_separador || registro.agencia_cal;
         v_linea := v_linea || p_separador || registro.fecha_act;
         v_linea := v_linea || p_separador || registro.codigo_corredor;
         v_linea := v_linea || p_separador || registro.clase_contrato;
         v_linea := v_linea || p_separador || registro.ramo;
         v_linea := v_linea || p_separador || registro.vigencia_desde;
         v_linea := v_linea || p_separador || registro.vigencia_hasta;
         v_linea := v_linea || p_separador || registro.prima;
         v_linea := v_linea || p_separador || registro.comis;
         v_linea := v_linea || p_separador || registro.costo;
         v_linea := v_linea || p_separador;
         v_subcuenta := v_subcuenta + 5;
         v_lineas.EXTEND;
         v_lineas(v_lineas.LAST) := v_linea;
      END LOOP;

      -- Almacena la informaciON en el objeto a retornar
      IF (v_lineas.COUNT > 0) THEN
         v_tbfichero.EXTEND;
         v_tbfichero(v_tbfichero.LAST) := NEW ob_fichero(p_empres, p_tgestor, p_tformato, '1',
                                                         v_lineas, NULL, NULL, NULL);
      END IF;

      RETURN v_tbfichero;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_formatos_conf.f_get_primas_cedidas', 1,
                     'Error no controlado', SQLERRM);
         RAISE;
   END f_get_primas_cedidas;


    /*************************************************************************
     FUNCTION f_get_garant_u_cumplimiento
        Obtiene los registro de la nomina de reaseguradores - GARANTIAS unicas DE CUMPLIMIENTO DE
    ENTIDADES ESTATALES del formato 489.
        param in p_empres: empresa
        param in p_tgestor: codigo de gestor
        param in p_tformato: codigo de formato
        param in p_anio : objeto fichero
        param in p_mes: archivo de carga
        param in p_dia : objeto fichero
        param in p_separador: separador de la tabla fic_gestores
     *************************************************************************/

FUNCTION f_get_garant_u_cumplimiento(
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
      v_lineas       t_linea := NEW t_linea(); --OBJETO VARCHAR2(4000)
      v_subcuenta    NUMBER;
      v_tbfichero    t_tabla_ficheros := NEW t_tabla_ficheros(); --OBJETO QUE RECIBE LOS PARAMETROS INICIALES Y QUE A SU VEZ INGRESA LOS CAMPOS DEL FORMATO EN UNA VARIABLE OBJETO DE TIPO T_LINEA,
                                                                 -- PARA ASI HACER COINCIDENCIA CON LOS CAMPOS DE LA TABLA "FIC_COLUMNA_FORMATOS" FILTRANDO POR GESTOR Y TIPO DE FORMATO
                                                                 -- Y ENVIARLOS A UN ARCHIVO .CSV

      CURSOR cur_datos(p_empres IN NUMBER, v_finicio IN DATE, v_ffin IN DATE) IS
 SELECT POLIZA,
          CERTIFICADO,
          AFIANZADO,
          NIT_TOMADOR ,
          ASEGURADO,
          NIT_ASEGURADO,
          fecha_de_expedicion,
          FEFECTO FECHA_DE_INICIO_VIGENCIA,
          FECHA_FIN_VIGENCIA,
          AMPAROS,
          COASEGURO,
          VALOR_ASEGURADO,
          SUM(VALOR_ASEGURADO_FUTURO) VALOR_ASEGURADO_FUTURO,
          SUM(PORC_RETENCION_CUOTAPARTE) PORC_RETENCION_CUOTAPARTE,
          SUM(RETENCION) RETENCION_CUOTAPARTE,
          SUM(POR_CESI_CUOTAPARTE) POR_CESI_CUOTAPARTE,
          SUM(CUOTA_PARTE1) VALOR_CESION_QP1,
          SUM(CUOTA_PARTE2) VALOR_CESION_QP2,
          SUM(CUOTA_PARTE3) VALOR_CESION_QP3,
          ANIO_CONTRATO,
          SUM(LIMITE_CONTRATO_CESION_QP) LIMITE_CONTRATO_CESION_QP ,
          SUM(VALOR_RETENCION_OTROSCONTRATOS) VALOR_RETENCION_OTROSCONTRATOS,
          SUM(PORC_RETENCION_OTROSCONTRATOS) PORC_RETENCION_OTROSCONTRATOS,
          SUM(POR_CESION_EXCEDENTE) POR_CESION_EXCEDENTE,
          SUM(VAL_CESION_EXCEDENTE) VAL_CESION_EXCEDENTE,
          ANIO_CONTRATO_CESION_EX,
          SUM(LIMITE_CONTRATO_CESION_EX) LIMITE_CONTRATO_CESION_EX,
          PORCENTAJE_FACOB,
          VALOR_FACOB,
          ANIO_FACOB,
          '2' LIMITE_FACOB,
          SUM(PORCENTAJE_FACULTATIVO) PORCENTAJE_FACULTATIVO,
          SUM(FACULTATIVO) FACULTATIVO,
          '0' PRIORIDAD_FACULTATIVO,
          '0' LIMITE_FACULTATIVO
      FROM
         (SELECT POLIZA,
                 CERTIFICADO,
                 SEGURO,
                 SPERSON,
                 NIT_TOMADOR,
                 NIT_ASEGURADO,
                 AFIANZADO,
                 ASEGURADO,
                 fecha_de_expedicion,
                 FEFECTO,
                 FECHA_FIN_VIGENCIA,
                 VALOR_ASEGURADO,
                 COASEGURO,
                 AMPAROS,
                 SERIE,
                 CGARANT,
                 CMONINT,
                 CGENERA,
                 CEMPRES,
                 PORCENTAJE_FACOB,
                 VALOR_FACOB,
                 ANIO_FACOB,
                 ANIO_CONTRATO,
                 ANIO_CONTRATO_CESION_EX,
                 SUM(RETENCION) RETENCION,
                 SUM(PORC_RETENCION_CUOTAPARTE) PORC_RETENCION_CUOTAPARTE,
                 SUM(VALOR_ASEGURADO_FUTURO) VALOR_ASEGURADO_FUTURO,
                 SUM(POR_CESI_CUOTAPARTE) POR_CESI_CUOTAPARTE,
                 SUM(CUOTA_PARTE1) CUOTA_PARTE1,
                 SUM(CUOTA_PARTE2) CUOTA_PARTE2,
                 SUM(CUOTA_PARTE3) CUOTA_PARTE3,
                 SUM(FACULTATIVO) FACULTATIVO,
                 SUM(VAL_CESION_EXCEDENTE) VAL_CESION_EXCEDENTE,
                 SUM(POR_CESION_EXCEDENTE) POR_CESION_EXCEDENTE,
                 SUM(PORCENTAJE_FACULTATIVO) PORCENTAJE_FACULTATIVO,
                 SUM(VALOR_RETENCION_OTROSCONTRATOS) VALOR_RETENCION_OTROSCONTRATOS,
                 SUM(PORC_RETENCION_OTROSCONTRATOS) PORC_RETENCION_OTROSCONTRATOS,
                 SUM(LIMITE_CONTRATO_CESION_QP) LIMITE_CONTRATO_CESION_QP,
                 SUM(LIMITE_CONTRATO_CESION_EX) LIMITE_CONTRATO_CESION_EX
         FROM
                (SELECT S.NPOLIZA POLIZA,
                        S.NCERTIF  CERTIFICADO,
                        PT.SPERSON,
                        PT.NNUMIDE  NIT_TOMADOR ,
                        PA.NNUMIDE  NIT_ASEGURADO,
                        S.SSEGURO SEGURO,
                        S.FEMISIO  fecha_de_expedicion,
                        S.FEFECTO,
                        S.FVENCIM  FECHA_FIN_VIGENCIA,
                        S.CTIPCOA  COASEGURO,
                        GB.ICAPITAL  VALOR_ASEGURADO,
                        DC.CGARANT GARAN,
                        CMONINT,
                        UPPER(PAC_ISQLFOR.F_PERSONA(S.SSEGURO, 1, T.SPERSON))  AFIANZADO,
                        UPPER(PAC_ISQLFOR.F_PERSONA(S.SSEGURO, 2, T.SPERSON))  ASEGURADO,
                        GA.CGARANT,
                        GA.TGARANT AMPAROS,
                        CE.CGENERA,
                        CD.CEMPRES,
                        TO_CHAR(CE.FEFECTO, 'YYYY') SERIE,
                        CON.FECINI ANIO_FACOB,
                        CON.FCONINI ANIO_CONTRATO,
                        CON.FCONINI ANIO_CONTRATO_CESION_EX,

                        (SELECT DISTINCT DECODE(TRA2.NPLENOS, NULL, ROUND(((TRA2.ITOTTRA * CON2.IRETENC) / 100), 1), TRA2.NPLENOS)
                        FROM  (SELECT A.SCONTRA, A.FECINI ,B.FCONFIN AS FCONFIN,NVERSIO,ICAPACI,CLOSSCORRIDOR,IRETENC
                FROM (SELECT SCONTRA,MAX(FCONINI)FECINI FROM CONTRATOS GROUP BY SCONTRA )A, CONTRATOS B
                WHERE A.SCONTRA=B.SCONTRA AND A.FECINI=B.FCONINI) CON2
                        INNER JOIN TRAMOS TRA2
                        ON TRA2.SCONTRA    = CON2.SCONTRA
                        AND TRA2.NVERSIO   = CON2.NVERSIO
                        WHERE CON2.SCONTRA = CON.SCONTRA
                        AND CON2.NVERSIO   = CON.NVERSIO
                        AND TRA2.CTRAMO   IN(4)
                        ) PORCENTAJE_FACOB,

                        (SELECT DISTINCT CON2.IRETENC / 1000000
                        FROM (SELECT A.SCONTRA, A.FECINI ,B.FCONFIN AS FCONFIN,NVERSIO,ICAPACI,CLOSSCORRIDOR,IRETENC
                FROM (SELECT SCONTRA,MAX(FCONINI)FECINI FROM CONTRATOS GROUP BY SCONTRA )A, CONTRATOS B
                WHERE A.SCONTRA=B.SCONTRA AND A.FECINI=B.FCONINI) CON2
                        INNER JOIN TRAMOS TRA2
                        ON TRA2.SCONTRA    = CON2.SCONTRA
                        AND TRA2.NVERSIO   = CON2.NVERSIO
                        WHERE CON2.SCONTRA = CON.SCONTRA
                        AND CON2.NVERSIO   = CON.NVERSIO
                        AND TRA2.CTRAMO   IN(4)
                        ) VALOR_FACOB,

                        DECODE(CE.CTRAMO, 0, DECODE(NVL(CTRAMPA, 0), 0,NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(M.CMONINT, 'COP', TO_DATE(SYSDATE), DC.ICAPCES)), 0), 0), 0) RETENCION,
                        DECODE(CE.CTRAMO, 0, DECODE(NVL(CTRAMPA, 0), 0,(CE.PCESION), 0), 0) PORC_RETENCION_CUOTAPARTE,
                        DECODE(CE.CTRAMO, 0, DECODE(NVL(CTRAMPA, 0), 0,(GB.ICAPITAL), 0), 0) VALOR_ASEGURADO_FUTURO,
                        DECODE(CE.CTRAMO, 2, DECODE(NVL(CTRAMPA, 0), 0,(CE.PCESION), 0), 0) POR_CESI_CUOTAPARTE,
                        DECODE(CE.CTRAMO, 3, DECODE(NVL(CTRAMPA, 0), 0,(CE.PCESION), 0), 0) POR_CESION_EXCEDENTE,
                        DECODE(CE.CTRAMO, 5, DECODE(NVL(CTRAMPA, 0), 0,(CE.PCESION), 0), 0) PORCENTAJE_FACULTATIVO,
                        DECODE(CE.CTRAMO, 0, DECODE(NVL(CTRAMPA, 0), 0,NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(M.CMONINT, 'COP', TO_DATE(SYSDATE), DC.ICAPCES)), 0), 0), 0) VALOR_RETENCION_OTROSCONTRATOS,
                        DECODE(CE.CTRAMO, 0, DECODE(NVL(CTRAMPA, 0), 0,(CE.PCESION), 0), 0) PORC_RETENCION_OTROSCONTRATOS,
                        DECODE(CE.CTRAMO, 0, DECODE(NVL(CTRAMPA, 0), 0,(SELECT ITOTTRA FROM TRAMOS where CTRAMO =CE.CTRAMO), 0), 0) LIMITE_CONTRATO_CESION_EX,
                        DECODE(CE.CTRAMO, 0, DECODE(NVL(CTRAMPA, 0), 0,(SELECT ITOTTRA FROM TRAMOS where CTRAMO =CE.CTRAMO), 0), 0) LIMITE_CONTRATO_CESION_QP,
                        DECODE(CD.CTIPREA, 2,NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(M.CMONINT, 'COP', TO_DATE(SYSDATE), DC.ICAPCES)), 0), 0) + DECODE(CE.CTRAMO, 0,DECODE(NVL(CTRAMPA, 0), 2, NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(M.CMONINT, 'COP', TO_DATE(SYSDATE), DC.ICAPCES)), 0), 0), 0) VAL_CESION_EXCEDENTE,
                        DECODE(CE.CTRAMO, 1,NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(M.CMONINT, 'COP', TO_DATE(SYSDATE), DC.ICAPCES)), 0), 0) + DECODE(CE.CTRAMO, 0, DECODE(NVL(CTRAMPA, 0), 1, NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(M.CMONINT, 'COP', TO_DATE(SYSDATE), DC.ICAPCES)), 0), 0), 0) CUOTA_PARTE1,
                        DECODE(CE.CTRAMO, 2,NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(M.CMONINT, 'COP', TO_DATE(SYSDATE), DC.ICAPCES)), 0), 0) + DECODE(CE.CTRAMO, 0, DECODE(NVL(CTRAMPA, 0), 2, NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(M.CMONINT, 'COP', TO_DATE(SYSDATE), DC.ICAPCES)), 0), 0), 0) CUOTA_PARTE2,
                        DECODE(CE.CTRAMO, 3,NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(M.CMONINT, 'COP', TO_DATE(SYSDATE), DC.ICAPCES)), 0), 0) + DECODE(CE.CTRAMO, 0, DECODE(NVL(CTRAMPA, 0), 3, NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(M.CMONINT, 'COP', TO_DATE(SYSDATE), DC.ICAPCES)), 0), 0), 0) CUOTA_PARTE3,
                        DECODE(CE.CTRAMO, 5,NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(M.CMONINT, 'COP', TO_DATE(SYSDATE), DC.ICAPCES)), 0), 0) FACULTATIVO
                   FROM TOMADORES T,
                        ASEGURADOS A,
                        PER_PERSONAS PT,
                        PER_PERSONAS PA,
                        PER_DETPER PDT,
                        PER_DETPER DPA,
                        GARANGEN GA,
                        GARANSEG GB,
                        DET_CESIONESREA DC,
                        CESIONESREA CE,
                        SEGUROS S,
                        DETVALORES DV,
                        MONEDAS M,
                        CODICONTRATOS CD,
                        (SELECT A.SCONTRA, A.FECINI ,B.FCONFIN as FCONFIN,NVERSIO,ICAPACI,CLOSSCORRIDOR,FCONINI
                FROM (SELECT SCONTRA,MAX(FCONINI)FECINI FROM CONTRATOS GROUP BY SCONTRA )A, CONTRATOS B
                WHERE A.SCONTRA=B.SCONTRA AND A.FECINI=B.FCONINI) CON

                  WHERE /*PT.NNUMIDE = '12000673'
                  AND */S.SSEGURO = T.SSEGURO
                  AND S.SSEGURO = A.SSEGURO
                  AND T.SPERSON = PDT.SPERSON
                  AND A.SPERSON = DPA.SPERSON
                  AND T.SPERSON = PT.SPERSON
                  AND A.SPERSON = PA.SPERSON
                  AND GA.CGARANT = GB.CGARANT
                  AND GB.SSEGURO = S.SSEGURO
                  AND DC.SSEGURO = S.SSEGURO
                  AND CE.SSEGURO = S.SSEGURO
                  AND DC.SCESREA = CE.SCESREA
                  AND DV.CATRIBU = CE.CGENERA
                  AND CE.SCONTRA = CD.SCONTRA
                  AND CD.SCONTRA = CON.SCONTRA
                  AND CVALOR = 128
                  AND DV.CIDIOMA = 8
                  AND DC.CGARANT = GA.CGARANT
                  AND GA.CIDIOMA = 8
                  AND M.CIDIOMA = 8
                  AND M.CMONEDA = PAC_MONEDAS.F_MONEDA_PRODUCTO(S.SPRODUC)
                  )
          GROUP BY POLIZA,
                   CERTIFICADO,
                   SEGURO,
                   NIT_TOMADOR,
                   NIT_ASEGURADO,
                   fecha_de_expedicion,
                   FECHA_FIN_VIGENCIA,
                   FEFECTO,
                   COASEGURO,
                   VALOR_ASEGURADO,
                   PORCENTAJE_FACOB,
                   VALOR_FACOB,
                   ANIO_FACOB,
                   ANIO_CONTRATO,
                   ANIO_CONTRATO_CESION_EX,
                   SPERSON,
                   AMPAROS,
                   SERIE,
                   CGARANT,
                   CMONINT,
                   AFIANZADO,
                   ASEGURADO,
                   CGENERA,
                   GARAN,
                   CEMPRES,
                   NVL(PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(CMONINT, 'COP', TO_DATE(SYSDATE)
                   , PAC_CUMULOS_CONF.F_CALCULA_DEPURA_MANUAL(TO_DATE(SYSDATE), SEGURO, GARAN, 4, SPERSON)), 0),
                   NVL(PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(CMONINT, 'COP', TO_DATE(SYSDATE)
                   , PAC_CUMULOS_CONF.F_CALCULA_DEPURA_AUTO(TO_DATE(SYSDATE), SEGURO, GARAN, SPERSON)), 0)
          ) VALORES,
            GARANSEG GAR
WHERE GAR.SSEGURO = VALORES.SEGURO
      AND GAR.CGARANT   = VALORES.CGARANT
      AND GAR.NMOVIMI = (SELECT MAX(NMOVIMI) FROM GARANSEG GAR2 WHERE GAR2.SSEGURO = GAR.SSEGURO)
      AND cempres = p_empres
      AND FEFECTO  >= v_finicio
      AND FEFECTO <= v_ffin

GROUP BY POLIZA,
              CERTIFICADO,
              NIT_TOMADOR,
              NIT_ASEGURADO,
              AFIANZADO,
              ASEGURADO,
              fecha_de_expedicion,
              FEFECTO,
              FECHA_FIN_VIGENCIA,
              COASEGURO,
              VALOR_ASEGURADO,
             PORCENTAJE_FACOB,
              VALOR_FACOB,
              ANIO_FACOB,
              ANIO_CONTRATO,
              ANIO_CONTRATO_CESION_EX,
              CMONINT,
              SERIE,
              SPERSON,
              GAR.CGARANT,
              AMPAROS
    ;

   /* SELECT POLIZA,
          CERTIFICADO,
          AFIANZADO,
          NIT_TOMADOR ,
          ASEGURADO,
          NIT_ASEGURADO,
          fecha_de_expedicion,
          FEFECTO FECHA_DE_INICIO_VIGENCIA,
          FECHA_FIN_VIGENCIA,
          AMPAROS,
          COASEGURO,
          VALOR_ASEGURADO,
          SUM(VALOR_ASEGURADO_FUTURO) VALOR_ASEGURADO_FUTURO,
          SUM(PORC_RETENCION_CUOTAPARTE) PORC_RETENCION_CUOTAPARTE,
          SUM(RETENCION) RETENCION_CUOTAPARTE,
          SUM(POR_CESI_CUOTAPARTE) POR_CESI_CUOTAPARTE,
          SUM(CUOTA_PARTE1) VALOR_CESION_QP1,
          SUM(CUOTA_PARTE2) VALOR_CESION_QP2,
          SUM(CUOTA_PARTE3) VALOR_CESION_QP3,
          ANIO_CONTRATO,
          SUM(LIMITE_CONTRATO_CESION_QP) LIMITE_CONTRATO_CESION_QP ,
          SUM(VALOR_RETENCION_OTROSCONTRATOS) VALOR_RETENCION_OTROSCONTRATOS,
          SUM(PORC_RETENCION_OTROSCONTRATOS) PORC_RETENCION_OTROSCONTRATOS,
          SUM(POR_CESION_EXCEDENTE) POR_CESION_EXCEDENTE,
          SUM(VAL_CESION_EXCEDENTE) VAL_CESION_EXCEDENTE,
          ANIO_CONTRATO_CESION_EX,
          SUM(LIMITE_CONTRATO_CESION_EX) LIMITE_CONTRATO_CESION_EX,
          PORCENTAJE_FACOB,
          VALOR_FACOB,
          ANIO_FACOB,
          '2' LIMITE_FACOB,
          SUM(PORCENTAJE_FACULTATIVO) PORCENTAJE_FACULTATIVO,
          SUM(FACULTATIVO) FACULTATIVO,
          '0' PRIORIDAD_FACULTATIVO,
          '0' LIMITE_FACULTATIVO
FROM
         (SELECT POLIZA,
                 CERTIFICADO,
                 SEGURO,
                 SPERSON,
                 NIT_TOMADOR,
                 NIT_ASEGURADO,
                 AFIANZADO,
                 ASEGURADO,
                 fecha_de_expedicion,
                 FEFECTO,
                 FECHA_FIN_VIGENCIA,
                 VALOR_ASEGURADO,
                 COASEGURO,
                 AMPAROS,
                 SERIE,
                 CGARANT,
                 CMONINT,
                 CGENERA,
                 CEMPRES,
                 PORCENTAJE_FACOB,
                 VALOR_FACOB,
                 ANIO_FACOB,
                 ANIO_CONTRATO,
                 ANIO_CONTRATO_CESION_EX,

                 SUM(RETENCION) RETENCION,
                 SUM(PORC_RETENCION_CUOTAPARTE) PORC_RETENCION_CUOTAPARTE,
                 SUM(VALOR_ASEGURADO_FUTURO) VALOR_ASEGURADO_FUTURO,
                 SUM(POR_CESI_CUOTAPARTE) POR_CESI_CUOTAPARTE,
                 SUM(CUOTA_PARTE1) CUOTA_PARTE1,
                 SUM(CUOTA_PARTE2) CUOTA_PARTE2,
                 SUM(CUOTA_PARTE3) CUOTA_PARTE3,
                 SUM(FACULTATIVO) FACULTATIVO,
                 SUM(VAL_CESION_EXCEDENTE) VAL_CESION_EXCEDENTE,
                 SUM(POR_CESION_EXCEDENTE) POR_CESION_EXCEDENTE,
                 SUM(PORCENTAJE_FACULTATIVO) PORCENTAJE_FACULTATIVO,
                 SUM(VALOR_RETENCION_OTROSCONTRATOS) VALOR_RETENCION_OTROSCONTRATOS,
                 SUM(PORC_RETENCION_OTROSCONTRATOS) PORC_RETENCION_OTROSCONTRATOS,
                 SUM(LIMITE_CONTRATO_CESION_QP) LIMITE_CONTRATO_CESION_QP,
                 SUM(LIMITE_CONTRATO_CESION_EX) LIMITE_CONTRATO_CESION_EX



           FROM
                (SELECT S.NPOLIZA POLIZA,
                        S.NCERTIF  CERTIFICADO,
                        PT.SPERSON,
                        PT.NNUMIDE  NIT_TOMADOR ,
                        PA.NNUMIDE  NIT_ASEGURADO,
                        S.SSEGURO SEGURO,
                        S.FEMISIO  fecha_de_expedicion,
                        S.FEFECTO,
                        S.FVENCIM  FECHA_FIN_VIGENCIA,
                        S.CTIPCOA  COASEGURO,
                        GB.ICAPITAL  VALOR_ASEGURADO,
                        DC.CGARANT GARAN,
                        CMONINT,
                        UPPER(PAC_ISQLFOR.F_PERSONA(S.SSEGURO, 1, T.SPERSON))  AFIANZADO,
                        UPPER(PAC_ISQLFOR.F_PERSONA(S.SSEGURO, 2, T.SPERSON))  ASEGURADO,
                        GA.CGARANT,
                        GA.TGARANT AMPAROS,
                        CE.CGENERA,
                        CD.CEMPRES,
                        TO_CHAR(CE.FEFECTO, 'YYYY') SERIE,
                        CON.FECINI ANIO_FACOB,
                        CON.FCONINI ANIO_CONTRATO,
                        CON.FCONINI ANIO_CONTRATO_CESION_EX,

                        (SELECT DISTINCT DECODE(TRA2.NPLENOS, NULL, ROUND(((TRA2.ITOTTRA * CON2.IRETENC) / 100), 1), TRA2.NPLENOS)
                        FROM  (SELECT A.SCONTRA, A.FECINI ,NVL(B.FCONFIN,TO_DATE('01/12/9999','DD/MM/YYYY'))AS FCONFIN,NVERSIO,ICAPACI,CLOSSCORRIDOR,IRETENC
                        FROM (SELECT SCONTRA,MAX(FCONINI)FECINI FROM CONTRATOS GROUP BY SCONTRA )A, CONTRATOS B
                        WHERE A.SCONTRA=B.SCONTRA AND A.FECINI=B.FCONINI) CON2
                        INNER JOIN TRAMOS TRA2
                        ON TRA2.SCONTRA    = CON2.SCONTRA
                        AND TRA2.NVERSIO   = CON2.NVERSIO
                        WHERE CON2.SCONTRA = CON.SCONTRA
                        AND CON2.NVERSIO   = CON.NVERSIO
                        AND TRA2.CTRAMO   IN(4)
                        ) PORCENTAJE_FACOB,

                        (SELECT DISTINCT CON2.IRETENC / 1000000
                        FROM CONTRATOS CON2
                        INNER JOIN TRAMOS TRA2
                        ON TRA2.SCONTRA    = CON2.SCONTRA
                        AND TRA2.NVERSIO   = CON2.NVERSIO
                        WHERE CON2.SCONTRA = CON.SCONTRA
                        AND CON2.NVERSIO   = CON.NVERSIO
                        AND TRA2.CTRAMO   IN(4)
                        ) VALOR_FACOB,

                        DECODE(CE.CTRAMO, 0, DECODE(NVL(CTRAMPA, 0), 0,NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(M.CMONINT, 'COP', TO_DATE(SYSDATE), DC.ICAPCES)), 0), 0), 0) RETENCION,
                        DECODE(CE.CTRAMO, 0, DECODE(NVL(CTRAMPA, 0), 0,(CE.PCESION), 0), 0) PORC_RETENCION_CUOTAPARTE,
                        DECODE(CE.CTRAMO, 0, DECODE(NVL(CTRAMPA, 0), 0,(GB.ICAPITAL), 0), 0) VALOR_ASEGURADO_FUTURO,
                        DECODE(CE.CTRAMO, 2, DECODE(NVL(CTRAMPA, 0), 0,(CE.PCESION), 0), 0) POR_CESI_CUOTAPARTE,
                        DECODE(CE.CTRAMO, 3, DECODE(NVL(CTRAMPA, 0), 0,(CE.PCESION), 0), 0) POR_CESION_EXCEDENTE,
                        DECODE(CE.CTRAMO, 5, DECODE(NVL(CTRAMPA, 0), 0,(CE.PCESION), 0), 0) PORCENTAJE_FACULTATIVO,
                        DECODE(CE.CTRAMO, 0, DECODE(NVL(CTRAMPA, 0), 0,NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(M.CMONINT, 'COP', TO_DATE(SYSDATE), DC.ICAPCES)), 0), 0), 0) VALOR_RETENCION_OTROSCONTRATOS,
                        DECODE(CE.CTRAMO, 0, DECODE(NVL(CTRAMPA, 0), 0,(CE.PCESION), 0), 0) PORC_RETENCION_OTROSCONTRATOS,
                        DECODE(CE.CTRAMO, 0, DECODE(NVL(CTRAMPA, 0), 0,(SELECT ITOTTRA FROM TRAMOS where CTRAMO =CE.CTRAMO), 0), 0) LIMITE_CONTRATO_CESION_EX,
                        DECODE(CE.CTRAMO, 0, DECODE(NVL(CTRAMPA, 0), 0,(SELECT ITOTTRA FROM TRAMOS where CTRAMO =CE.CTRAMO), 0), 0) LIMITE_CONTRATO_CESION_QP,
                        DECODE(CD.CTIPREA, 2,NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(M.CMONINT, 'COP', TO_DATE(SYSDATE), DC.ICAPCES)), 0), 0) + DECODE(CE.CTRAMO, 0,DECODE(NVL(CTRAMPA, 0), 2, NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(M.CMONINT, 'COP', TO_DATE(SYSDATE), DC.ICAPCES)), 0), 0), 0) VAL_CESION_EXCEDENTE,
                        DECODE(CE.CTRAMO, 1,NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(M.CMONINT, 'COP', TO_DATE(SYSDATE), DC.ICAPCES)), 0), 0) + DECODE(CE.CTRAMO, 0, DECODE(NVL(CTRAMPA, 0), 1, NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(M.CMONINT, 'COP', TO_DATE(SYSDATE), DC.ICAPCES)), 0), 0), 0) CUOTA_PARTE1,
                        DECODE(CE.CTRAMO, 2,NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(M.CMONINT, 'COP', TO_DATE(SYSDATE), DC.ICAPCES)), 0), 0) + DECODE(CE.CTRAMO, 0, DECODE(NVL(CTRAMPA, 0), 2, NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(M.CMONINT, 'COP', TO_DATE(SYSDATE), DC.ICAPCES)), 0), 0), 0) CUOTA_PARTE2,
                        DECODE(CE.CTRAMO, 3,NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(M.CMONINT, 'COP', TO_DATE(SYSDATE), DC.ICAPCES)), 0), 0) + DECODE(CE.CTRAMO, 0, DECODE(NVL(CTRAMPA, 0), 3, NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(M.CMONINT, 'COP', TO_DATE(SYSDATE), DC.ICAPCES)), 0), 0), 0) CUOTA_PARTE3,
                        DECODE(CE.CTRAMO, 5,NVL((PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(M.CMONINT, 'COP', TO_DATE(SYSDATE), DC.ICAPCES)), 0), 0) FACULTATIVO
                   FROM TOMADORES T,
                        ASEGURADOS A,
                        PER_PERSONAS PT,
                        PER_PERSONAS PA,
                        PER_DETPER PDT,
                        PER_DETPER DPA,
                        GARANGEN GA,
                        GARANSEG GB,
                        DET_CESIONESREA DC,
                        CESIONESREA CE,
                        SEGUROS S,
                        DETVALORES DV,
                        MONEDAS M,
                        CODICONTRATOS CD,
                        (SELECT A.SCONTRA, A.FECINI ,NVL(B.FCONFIN,TO_DATE('01/12/9999','DD/MM/YYYY'))AS FCONFIN,NVERSIO,ICAPACI,CLOSSCORRIDOR,FCONINI
                        FROM (SELECT SCONTRA,MAX(FCONINI)FECINI FROM CONTRATOS GROUP BY SCONTRA )A, CONTRATOS B
                        WHERE A.SCONTRA=B.SCONTRA AND A.FECINI=B.FCONINI) CON

                  WHERE S.SSEGURO = T.SSEGURO
                  AND S.SSEGURO = A.SSEGURO
                  AND T.SPERSON = PDT.SPERSON
                  AND A.SPERSON = DPA.SPERSON
                  AND T.SPERSON = PT.SPERSON
                  AND A.SPERSON = PA.SPERSON
                  AND GA.CGARANT = GB.CGARANT
                  AND GB.SSEGURO = S.SSEGURO
                  AND DC.SSEGURO = S.SSEGURO
                  AND CE.SSEGURO = S.SSEGURO
                  AND DC.SCESREA = CE.SCESREA
                  AND DV.CATRIBU = CE.CGENERA
                  AND CE.SCONTRA = CD.SCONTRA
                  AND CD.SCONTRA = CON.SCONTRA
                  AND CVALOR = 128
                  AND DV.CIDIOMA = 8
                  AND DC.CGARANT = GA.CGARANT
                  AND GA.CIDIOMA = 8
                  AND M.CIDIOMA = 8
                  AND M.CMONEDA = PAC_MONEDAS.F_MONEDA_PRODUCTO(S.SPRODUC)
                  )
          GROUP BY POLIZA,
                   CERTIFICADO,
                   SEGURO,
                   NIT_TOMADOR,
                   NIT_ASEGURADO,
                   fecha_de_expedicion,
                   FECHA_FIN_VIGENCIA,
                   FEFECTO,
                   COASEGURO,
                   VALOR_ASEGURADO,
                   PORCENTAJE_FACOB,
                   VALOR_FACOB,
                   ANIO_FACOB,
                   ANIO_CONTRATO,
                   ANIO_CONTRATO_CESION_EX,
                   SPERSON,
                   AMPAROS,
                   SERIE,
                   CGARANT,
                   CMONINT,
                   AFIANZADO,
                   ASEGURADO,
                   CGENERA,
                   GARAN,
                   CEMPRES,
                   NVL(PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(CMONINT, 'COP', TO_DATE(SYSDATE)
                   , PAC_CUMULOS_CONF.F_CALCULA_DEPURA_MANUAL(TO_DATE(SYSDATE), SEGURO, GARAN, 4, SPERSON)), 0),
                   NVL(PAC_ECO_TIPOCAMBIO.F_IMPORTE_CAMBIO(CMONINT, 'COP', TO_DATE(SYSDATE)
                   , PAC_CUMULOS_CONF.F_CALCULA_DEPURA_AUTO(TO_DATE(SYSDATE), SEGURO, GARAN, SPERSON)), 0)
          ) VALORES,
            GARANSEG GAR
WHERE GAR.SSEGURO = VALORES.SEGURO
      AND GAR.CGARANT   = VALORES.CGARANT
      AND GAR.NMOVIMI = (SELECT MAX(NMOVIMI) FROM GARANSEG GAR2 WHERE GAR2.SSEGURO = GAR.SSEGURO)
      AND cempres = p_empres
      AND FEFECTO  >= v_finicio
      AND FEFECTO <= v_ffin

GROUP BY POLIZA,
              CERTIFICADO,
              NIT_TOMADOR,
              NIT_ASEGURADO,
              AFIANZADO,
              ASEGURADO,
              fecha_de_expedicion,
              FEFECTO,
              FECHA_FIN_VIGENCIA,
              COASEGURO,
              VALOR_ASEGURADO,
             PORCENTAJE_FACOB,
              VALOR_FACOB,
              ANIO_FACOB,
              ANIO_CONTRATO,
              ANIO_CONTRATO_CESION_EX,
              CMONINT,
              SERIE,
              SPERSON,
              GAR.CGARANT,
              AMPAROS
    ;*/



   BEGIN

      IF TRIM(p_mes) = '0' THEN
         -- Calcular fecha inicio y fecha fin
         v_finicio := TO_DATE('01' || '01' || p_anio, 'ddmmyyyy');
      ELSE
         v_finicio := TO_DATE('01' || LPAD(p_mes, 2, '0') || p_anio, 'ddmmyyyy');
      END IF;

      SELECT LAST_DAY(v_finicio)
        INTO v_ffin
        FROM DUAL;

      v_subcuenta := 5;

      -- Generar la informaciON del Formato
      FOR registro IN cur_datos(p_empres, v_finicio, v_ffin) LOOP
         v_linea := LPAD('' || v_subcuenta, 6, '0');
           v_linea := v_linea || p_separador || registro.POLIZA;
            v_linea := v_linea || p_separador || registro.CERTIFICADO;
            v_linea := v_linea || p_separador || registro.AFIANZADO;
            v_linea := v_linea || p_separador || registro.NIT_TOMADOR;
            v_linea := v_linea || p_separador || registro.ASEGURADO;
            v_linea := v_linea || p_separador || registro.NIT_ASEGURADO;
            v_linea := v_linea || p_separador || registro.fecha_de_expedicion;
            v_linea := v_linea || p_separador || registro.FECHA_DE_INICIO_VIGENCIA;
            v_linea := v_linea || p_separador || registro.FECHA_FIN_VIGENCIA;
            v_linea := v_linea || p_separador || registro.AMPAROS;
            v_linea := v_linea || p_separador || registro.COASEGURO;
            v_linea := v_linea || p_separador || registro.VALOR_ASEGURADO;
            v_linea := v_linea || p_separador || registro.VALOR_ASEGURADO_FUTURO;
            v_linea := v_linea || p_separador || registro.PORC_RETENCION_CUOTAPARTE;
            v_linea := v_linea || p_separador || registro.RETENCION_CUOTAPARTE;
            v_linea := v_linea || p_separador || registro.POR_CESI_CUOTAPARTE;
            v_linea := v_linea || p_separador || registro.VALOR_CESION_QP1;
            v_linea := v_linea || p_separador || registro.VALOR_CESION_QP2;
            v_linea := v_linea || p_separador || registro.VALOR_CESION_QP3;
            v_linea := v_linea || p_separador || registro.ANIO_CONTRATO;
            v_linea := v_linea || p_separador || registro.LIMITE_CONTRATO_CESION_QP;
            v_linea := v_linea || p_separador || registro.PORC_RETENCION_OTROSCONTRATOS;
            v_linea := v_linea || p_separador || registro.VALOR_RETENCION_OTROSCONTRATOS;
            v_linea := v_linea || p_separador || registro.POR_CESION_EXCEDENTE;
            v_linea := v_linea || p_separador || registro.VAL_CESION_EXCEDENTE;
            v_linea := v_linea || p_separador || registro.ANIO_CONTRATO_CESION_EX;
            v_linea := v_linea || p_separador || registro.LIMITE_CONTRATO_CESION_EX;
            v_linea := v_linea || p_separador || registro.PORCENTAJE_FACOB;
            v_linea := v_linea || p_separador || registro.VALOR_FACOB;
            v_linea := v_linea || p_separador || registro.ANIO_FACOB;
            v_linea := v_linea || p_separador || registro.LIMITE_FACOB;
            v_linea := v_linea || p_separador || registro.PORCENTAJE_FACULTATIVO;
            v_linea := v_linea || p_separador || registro.FACULTATIVO;
            v_linea := v_linea || p_separador || registro.PRIORIDAD_FACULTATIVO;
            v_linea := v_linea || p_separador || registro.LIMITE_FACULTATIVO;
         v_linea := v_linea || p_separador;
         v_subcuenta := v_subcuenta + 5;
         v_lineas.EXTEND;
         v_lineas(v_lineas.LAST) := v_linea;
      END LOOP;

      -- Almacena la informaciON en el objeto a retornar
      IF (v_lineas.COUNT > 0) THEN
         v_tbfichero.EXTEND;
         v_tbfichero(v_tbfichero.LAST) := NEW ob_fichero(p_empres, p_tgestor, p_tformato, '1',
                                                         v_lineas, NULL, NULL, NULL);
      END IF;

      RETURN v_tbfichero;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_formatos_conf.f_get_garant_u_cumplimiento', 1,
                     'Error no controlado', SQLERRM);
         RAISE;
   END f_get_garant_u_cumplimiento;

  /*************************************************************************
   FUNCTION f_get_saldos_siniestros
      Obtiene los registro de los Saldos cuenta corriente y reservas para siniestros
      para la generacion del formato 490.
      param in p_empres: empresa
      param in p_tgestor: codigo de gestor
      param in p_tformato: codigo de formato
      param in p_anio : objeto fichero
      param in p_mes: archivo de carga
      param in p_dia : objeto fichero
      param in p_separador: separador de la tabla fic_gestores
   *************************************************************************/
   FUNCTION f_get_saldos_siniestros(
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_separador IN VARCHAR2)
      RETURN t_tabla_ficheros IS
      v_tbfichero    t_tabla_ficheros := NEW t_tabla_ficheros();
      v_lineas       t_linea := NEW t_linea();
      v_finicio      DATE;
      v_ffin         DATE;
      v_contexto     VARCHAR2(4000);
      v_subcuenta    NUMBER;
      v_linea        VARCHAR2(4000);
      v_pacumsal_h180 NUMBER := 0;   --acumulador para sumatori de saldos_hasta180
      v_pacumsal_m180 NUMBER := 0;   -- acumulador para sumatori de masde180
      v_sacumsal_h180 NUMBER := 0;
      v_sacumsal_m180 NUMBER := 0;
      v_tacumsal_h180 NUMBER := 0;
      v_tacumsal_m180 NUMBER := 0;
      v_cacumsal_h180 NUMBER := 0;
      v_cacumsal_m180 NUMBER := 0;

      CURSOR cur_datos(p_empres IN NUMBER, v_finicio IN DATE, v_ffin IN DATE) IS
          SELECT DISTINCT LPAD(com.cpais, 3, '0') || LPAD(com.CSUPERFINAN, 5, '0') codigo_rea,--cambio de codigo reasegurador entendiendo que el que se pide es el de la superfinanciera 26/05/2017
                         LPAD(com.cpais, 3, '0') pais_rea,
                         ff_desvalorfijo(800100, 8, com.ccalifi) calificacion,
                         REPLACE(ff_desvalorfijo(800101, 8, com.centicalifi),
                                 CHR(39)) agencia_cal,
                         com.fmovimi fecha_act,   --fecha de actualizacion de compa¿ia pero no exclusivamente del la calificacion--
                         comi.activo_h180_1545
             ,pri.activo_m180_1545
             ,cot.pasivo_h180_2350
             ,pas.pasivo_m180_2350
             ,res.resrva_sin_h180_2660
             ,res2.reserva_sin_m180_2660
             ,NVL(comi.activo_h180_1545, 0) - NVL(cot.pasivo_h180_2350, 0)+ NVL(res.resrva_sin_h180_2660, 0) saldoh180
             ,NVL(pri.activo_m180_1545, 0) - NVL(pas.pasivo_m180_2350, 0)+ NVL(res2.reserva_sin_m180_2660, 0) saldom180
                    FROM ctatecnica cta INNER JOIN companias com ON cta.ccompani =com.ccompani
                         INNER JOIN (select a.SCONTRA, a.FCONINI ,B.FCONFINAUX FCONFIN,NVERSIO,ICAPACI,CLOSSCORRIDOR
                 from (select SCONTRA,max(FCONINI)FCONINI from CONTRATOS group by SCONTRA )a, CONTRATOS B
                 where a.SCONTRA=B.SCONTRA and a.FCONINI=B.FCONINI) con ON cta.scontra = con.scontra   AND cta.nversio = con.nversio
                         INNER JOIN codicontratos cod ON con.scontra = cod.scontra
                         INNER JOIN agr_contratos agr ON con.scontra = agr.scontra
                         LEFT JOIN
                         (SELECT   cempres, ccompani,
                                   ROUND(ABS(SUM(iimport)), 2) activo_h180_1545
                              FROM movctatecnica
                             WHERE cconcep IN(3, 33, 34, 51, 6)--Cta  1678 , antes 1545 nombre reaseguradores exterior cuenta corriente (para los activos )
                               AND iimport > 0
                               AND v_ffin - fefecto <= 180
                               AND fefecto >= v_finicio
                               AND fefecto <= v_ffin
                          GROUP BY cempres, ccompani) comi
                         ON comi.ccompani = cta.ccompani  AND comi.cempres = cta.cempres
                         LEFT JOIN
                         (SELECT   cempres, ccompani,
                                   ROUND(ABS(SUM(iimport)), 2) activo_m180_1545
                              FROM movctatecnica
                             WHERE cconcep IN(3, 33, 34, 51, 6)--Cta  1678 , antes 1545 nombre reaseguradores exterior cuenta corriente (para los activos )
                               AND iimport > 0
                               AND v_ffin - fefecto > 180
                                AND fefecto <= v_finicio
                               --AND TO_DATE(fefecto,'DD/MM/YY') <= TO_DATE(v_ffin,'DD/MM/YY')
                          GROUP BY cempres, ccompani) pri
                         ON pri.ccompani = cta.ccompani
                       AND pri.cempres = cta.cempres
                         LEFT JOIN
                         (SELECT   cempres, ccompani,
                                   ROUND(ABS(SUM(iimport)), 2) pasivo_h180_2350
                              FROM movctatecnica
                             WHERE cconcep IN(1, 2, 22, 4)--Cta  2551, antes 2350 nombre reaseguradores exterior cuenta corriente (para los pasivos)
                               AND iimport < 0
                                AND v_ffin - fefecto <= 180
                               AND fefecto >= v_finicio
                               AND fefecto <= v_ffin
                          GROUP BY cempres, ccompani) cot
                         ON cot.ccompani = cta.ccompani
                       AND cot.cempres = cta.cempres
                         LEFT JOIN
                         (SELECT   cempres, ccompani,
                                   ROUND(ABS(SUM(iimport)), 2) pasivo_m180_2350
                              FROM movctatecnica
                             WHERE cconcep IN(1, 2, 22, 4)--Cta  2551, antes 2350 nombre reaseguradores exterior cuenta corriente (para los pasivos)
                               AND iimport < 0
                               AND v_ffin - fefecto > 180
                                AND fefecto <= v_finicio
                              -- AND fefecto <= v_ffin
                          GROUP BY cempres, ccompani) pas
                         ON pas.ccompani = cta.ccompani
                       AND pas.cempres = cta.cempres
                         LEFT JOIN
                         (SELECT   cempres, ccompani,
                                   ROUND(ABS(SUM(iimport)), 2) resrva_sin_h180_2660
                              FROM movctatecnica
                             WHERE cconcep IN(25)--cuenta tecnica para las reservas
                                AND v_ffin - fefecto <= 180
                               AND fefecto >= v_finicio
                               AND fefecto <= v_ffin
                          GROUP BY cempres, ccompani) res
                         ON res.ccompani = cta.ccompani
                       AND res.cempres = cta.cempres
                         LEFT JOIN
                         (SELECT   cempres, ccompani,
                                   ROUND(ABS(SUM(iimport)), 2) reserva_sin_m180_2660
                              FROM movctatecnica
                             WHERE cconcep IN(25)--cuenta tecnica para las reservas
                               AND v_ffin - fefecto > 180
                                AND fefecto <= v_finicio
                               --AND fefecto <= v_ffin
                          GROUP BY cempres, ccompani) res2
                         ON res2.ccompani = cta.ccompani
                       AND res2.cempres = cta.cempres
                   WHERE cod.cempres = p_empres
                     AND com.ctipcom = 0 --comision habitual--
                   --  AND com.cpais <> 170--filtro debido a que todos los reaseguradores son externos a Colombia
                     AND(pri.activo_m180_1545 IS NOT NULL
                         OR comi.activo_h180_1545 IS NOT NULL
                         OR cot.pasivo_h180_2350 IS NOT NULL
                         OR pas.pasivo_m180_2350 IS NOT NULL
                         OR res.resrva_sin_h180_2660 IS NOT NULL
                         OR res2.reserva_sin_m180_2660 IS NOT NULL);
     /*SELECT DISTINCT LPAD(com.cpais, 3, '0') || LPAD(com.CSUPERFINAN, 5, '0') codigo_rea, --cambio de codigo reasegurador entendiendo que el que se pide es el de la superfinanciera 26/05/2017
                         LPAD(com.cpais, 3, '0') pais_rea,
                         ff_desvalorfijo(800100, 8, com.ccalifi) calificacion,
                         REPLACE(ff_desvalorfijo(800101, 8, com.centicalifi),
                                 CHR(39)) agencia_cal,
                         com.fmovimi fecha_act,   --fecha de actualizacion de compa¿ia pero no exclusivamente del la calificacion--
                         comi.activo_h180_1545
             ,pri.activo_m180_1545
             ,cot.pasivo_h180_2350
             ,pas.pasivo_m180_2350
             ,res.resrva_sin_h180_2660
             ,res2.reserva_sin_m180_2660
             ,NVL(comi.activo_h180_1545, 0) - NVL(cot.pasivo_h180_2350, 0)+ NVL(res.resrva_sin_h180_2660, 0) saldoh180
             ,NVL(pri.activo_m180_1545, 0) - NVL(pas.pasivo_m180_2350, 0)+ NVL(res2.reserva_sin_m180_2660, 0) saldom180
                    FROM ctatecnica cta INNER JOIN companias com ON cta.ccompani =com.ccompani
                         INNER JOIN contratos con ON cta.scontra = con.scontra   AND cta.nversio = con.nversio
                         INNER JOIN codicontratos cod ON con.scontra = cod.scontra
                         INNER JOIN agr_contratos agr ON con.scontra = agr.scontra
                         LEFT JOIN
                         (SELECT   cempres, ccompani,
                                   ROUND(ABS(SUM(iimport)), 2) activo_h180_1545
                              FROM movctatecnica
                             WHERE cconcep IN(3, 33, 34, 51, 6) --Cta  1678 , antes 1545 nombre reaseguradores exterior cuenta corriente (para los activos )
                               AND iimport > 0
                               AND v_ffin - fefecto <= 180
                               AND fefecto >= v_finicio
                               AND fefecto <= v_ffin
                          GROUP BY cempres, ccompani) comi
                         ON comi.ccompani = cta.ccompani  AND comi.cempres = cta.cempres
                         LEFT JOIN
                         (SELECT   cempres, ccompani,
                                   ROUND(ABS(SUM(iimport)), 2) activo_m180_1545
                              FROM movctatecnica
                             WHERE cconcep IN(3, 33, 34, 51, 6) --Cta  1678 , antes 1545 nombre reaseguradores exterior cuenta corriente (para los activos )
                               AND iimport > 0
                               AND v_ffin - fefecto > 180
                               AND fefecto >= v_finicio
                               AND fefecto <= v_ffin
                          GROUP BY cempres, ccompani) pri
                         ON pri.ccompani = cta.ccompani
                       AND pri.cempres = cta.cempres
                         LEFT JOIN
                         (SELECT   cempres, ccompani,
                                   ROUND(ABS(SUM(iimport)), 2) pasivo_h180_2350
                              FROM movctatecnica
                             WHERE cconcep IN(1, 2, 22, 4) --Cta  2551, antes 2350 nombre reaseguradores exterior cuenta corriente (para los pasivos)
                               AND iimport < 0
                               AND v_ffin - fefecto <= 180
                               AND fefecto >= v_finicio
                               AND fefecto <= v_ffin
                          GROUP BY cempres, ccompani) cot
                         ON cot.ccompani = cta.ccompani
                       AND cot.cempres = cta.cempres
                         LEFT JOIN
                         (SELECT   cempres, ccompani,
                                   ROUND(ABS(SUM(iimport)), 2) pasivo_m180_2350
                              FROM movctatecnica
                             WHERE cconcep IN(1, 2, 22, 4) --Cta  2551, antes 2350 nombre reaseguradores exterior cuenta corriente (para los pasivos)
                               AND iimport < 0
                               AND v_ffin - fefecto > 180
                               AND fefecto >= v_finicio
                               AND fefecto <= v_ffin
                          GROUP BY cempres, ccompani) pas
                         ON pas.ccompani = cta.ccompani
                       AND pas.cempres = cta.cempres
                         LEFT JOIN
                         (SELECT   cempres, ccompani,
                                   ROUND(ABS(SUM(iimport)), 2) resrva_sin_h180_2660
                              FROM movctatecnica
                             WHERE cconcep IN(25) --cuenta tecnica para las reservas
                               AND v_ffin - fefecto <= 180
                               AND fefecto >= v_finicio
                               AND fefecto <= v_ffin
                          GROUP BY cempres, ccompani) res
                         ON res.ccompani = cta.ccompani
                       AND res.cempres = cta.cempres
                         LEFT JOIN
                         (SELECT   cempres, ccompani,
                                   ROUND(ABS(SUM(iimport)), 2) reserva_sin_m180_2660
                              FROM movctatecnica
                             WHERE cconcep IN(25) --cuenta tecnica para las reservas
                               AND v_ffin - fefecto > 180
                               AND fefecto >= v_finicio
                               AND fefecto <= v_ffin
                          GROUP BY cempres, ccompani) res2
                         ON res2.ccompani = cta.ccompani
                       AND res2.cempres = cta.cempres
                   WHERE cod.cempres = p_empres
                     AND com.ctipcom = 0 --comision habitual--
                     AND com.cpais <> 170 --filtro debido a que todos los reaseguradores son externos a Colombia
                     AND(pri.activo_m180_1545 IS NOT NULL
                         OR comi.activo_h180_1545 IS NOT NULL
                         OR cot.pasivo_h180_2350 IS NOT NULL
                         OR pas.pasivo_m180_2350 IS NOT NULL
                         OR res.resrva_sin_h180_2660 IS NOT NULL
                         OR res2.reserva_sin_m180_2660 IS NOT NULL);*/
   BEGIN
      -- Calcular fecha inicio y fecha fin
      v_ffin := LAST_DAY(TO_DATE('01' || LPAD(p_mes, 2, '0') || p_anio, 'dd/mm/yyyy'));
      v_finicio := TO_DATE('01' || TO_CHAR(ADD_MONTHS(v_ffin, -3), 'mmyyyy'), 'dd/mm/yyyy');
      v_subcuenta := 1;

      -- Generar la informaciON del Formato unidad captura 1
      FOR registro IN cur_datos(p_empres, v_finicio, v_ffin) LOOP
         v_linea := LPAD('' || v_subcuenta, 6, '0');
         v_linea := v_linea || p_separador || registro.codigo_rea;
         v_linea := v_linea || p_separador || registro.pais_rea;
         v_linea := v_linea || p_separador || registro.calificacion;
         v_linea := v_linea || p_separador || registro.agencia_cal;
         v_linea := v_linea || p_separador || registro.fecha_act;
         v_linea := v_linea || p_separador || registro.activo_h180_1545;
         v_linea := v_linea || p_separador || registro.activo_m180_1545;
         v_linea := v_linea || p_separador || registro.pasivo_h180_2350;
         v_linea := v_linea || p_separador || registro.pasivo_m180_2350;
         v_linea := v_linea || p_separador || registro.resrva_sin_h180_2660;
         v_linea := v_linea || p_separador || registro.reserva_sin_m180_2660;
         v_linea := v_linea || p_separador || registro.saldoh180;
         v_linea := v_linea || p_separador || registro.saldom180;
         v_linea := v_linea || p_separador;
         v_subcuenta := v_subcuenta + 1;
         v_lineas.EXTEND;
         v_lineas(v_lineas.LAST) := v_linea;
         -- sumatoria para acumuladores
         v_pacumsal_h180 := v_pacumsal_h180 + NVL(registro.activo_h180_1545, 0);
         v_pacumsal_m180 := v_pacumsal_m180 + NVL(registro.activo_m180_1545, 0);
         v_sacumsal_h180 := v_sacumsal_h180 + NVL(registro.pasivo_h180_2350, 0);
         v_sacumsal_m180 := v_sacumsal_m180 + NVL(registro.pasivo_m180_2350, 0);
         v_tacumsal_h180 := v_tacumsal_h180 + NVL(registro.resrva_sin_h180_2660, 0);
         v_tacumsal_m180 := v_tacumsal_m180 + NVL(registro.reserva_sin_m180_2660, 0);
         v_cacumsal_h180 := v_cacumsal_h180 + NVL(registro.saldoh180, 0);
         v_cacumsal_m180 := v_cacumsal_m180 + NVL(registro.saldom180, 0);
      END LOOP;

      -- Almacena la informaciON en el objeto a retornar para unidad  captura 1
      IF (v_lineas.COUNT > 0) THEN
         v_tbfichero.EXTEND;
         v_tbfichero(v_tbfichero.LAST) := NEW ob_fichero(p_empres, p_tgestor, p_tformato, '1',
                                                         v_lineas, NULL, NULL, NULL);
         -- Almacena la informaciON de la sumatoria
         v_linea := '005' || p_separador || NULL || p_separador || NULL || p_separador || NULL
                    || p_separador || NULL || p_separador || NULL || p_separador
                    || NVL(v_pacumsal_h180, 0) || p_separador || NVL(v_pacumsal_m180, 0)
                    || p_separador || NVL(v_sacumsal_h180, 0) || p_separador
                    || NVL(v_sacumsal_m180, 0) || p_separador || NVL(v_tacumsal_h180, 0)
                    || p_separador || NVL(v_tacumsal_m180, 0) || p_separador
                    || NVL(v_cacumsal_h180, 0) || p_separador || NVL(v_cacumsal_m180, 0)
                    || p_separador;
         v_lineas := NEW t_linea();
         v_lineas.EXTEND;
         v_lineas(v_lineas.LAST) := v_linea;
         v_tbfichero.EXTEND;
         v_tbfichero(v_tbfichero.LAST) := NEW ob_fichero(p_empres, p_tgestor, p_tformato, '2',
                                                         v_lineas, NULL, NULL, NULL);
      END IF;

      RETURN v_tbfichero;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_formatos_pos.f_get_saldos_siniestros', 1,
                     'Error', SQLERRM);
         RAISE;
   END f_get_saldos_siniestros;


   END pac_formatos_conf;