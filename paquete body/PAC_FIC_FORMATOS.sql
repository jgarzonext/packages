--------------------------------------------------------
--  DDL for Package Body PAC_FIC_FORMATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_FIC_FORMATOS" AS
/******************************************************************************
   NOMBRE:      PAC_FIC_FORMATOS
   PROPÓSITO:   Funciones para la gestion de informes

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        08/08/2013   DEV               1. Creación del package.
   1.1        20/08/2013   JMG               2. Modificacion del paquete.
******************************************************************************/
   TYPE t_array_number IS VARRAY(20) OF INTEGER;

   /*************************************************************************
   PROCEDURE p_generar_ficherocsv
      Genera informe en formato CSV
      param in tb_fichero : tabla dinamica con la estructura del fichero
      param in vterror    : codigo error
      param out v_path    : lista de rutas de los archivos creados
   *************************************************************************/
   PROCEDURE p_generar_ficherocsv(
      pr_tbfichero IN t_tabla_ficheros,
      p_nerror OUT NUMBER,
      pr_path OUT t_linea,
      v_anio IN NUMBER,
      v_mes IN VARCHAR2,
      v_dia IN VARCHAR2) IS
      v_index        NUMBER;
      v_indexpath    NUMBER := 1;
      v_formato      fic_formatos.tformat%TYPE;
      v_indenc       fic_formatos.tindenc%TYPE;
      v_separador    fic_gestores.tsepfor%TYPE;
      v_nocol        fic_formatos.nnucofo%TYPE;
      v_nombre_archivo VARCHAR2(4000);
      v_file         UTL_FILE.file_type;
      v_fic          ob_fichero;
      v_dir_oracle   VARCHAR2(4000);
      v_dir_red      VARCHAR2(4000);
   BEGIN
      pr_path := NEW t_linea();

      IF pr_tbfichero.COUNT() > 0 THEN
         v_index := pr_tbfichero.FIRST;
         v_fic := pr_tbfichero(v_index);

         SELECT tindenc, nnucofo
           INTO v_indenc, v_nocol
           FROM fic_formatos
          WHERE tformat = v_fic.tformat
            AND tgestor = v_fic.tgestor;

         IF SQL%NOTFOUND THEN
            v_indenc := 'N';
         END IF;

         SELECT tsepfor
           INTO v_separador
           FROM fic_gestores
          WHERE tgestor = v_fic.tgestor;

         IF SQL%NOTFOUND THEN
            v_separador := NULL;
         END IF;

         SELECT pac_parametros.f_parinstalacion_t('INFORMES') dir_oracle,
                pac_parametros.f_parinstalacion_t('INFORMES_C') dir_red
           INTO v_dir_oracle,
                v_dir_red
           FROM DUAL;

         v_nombre_archivo := 'Formato' || v_fic.tformat || ' '
                             || TO_CHAR(f_sysdate, 'dd_mm_yyyy HH24_MI_SS') || '.csv';
         v_file := UTL_FILE.fopen(v_dir_oracle, v_nombre_archivo, 'w', 3200);
         pr_path.EXTEND(1);
         pr_path(v_indexpath) := v_dir_red || '/' || v_nombre_archivo;
         v_formato := v_fic.tformat;
         p_escribir_titulo(v_file, v_fic, v_separador, v_nocol, v_anio, v_mes, v_dia);
         p_escribir_encabezado(v_file, v_fic, v_separador, v_nocol);
         p_escribir_bloque(v_file, v_fic, v_separador, v_nocol);

         IF pr_tbfichero.LAST > pr_tbfichero.FIRST THEN
            v_index := pr_tbfichero.NEXT(v_index);

            LOOP
               v_fic := pr_tbfichero(v_index);

               IF v_formato <> v_fic.tformat THEN
                  UTL_FILE.fclose(v_file);

                  SELECT tindenc, nnucofo
                    INTO v_indenc, v_nocol
                    FROM fic_formatos
                   WHERE tformat = v_fic.tformat
                     AND tgestor = v_fic.tgestor;

                  IF SQL%NOTFOUND THEN
                     v_indenc := 'N';
                  END IF;

                  v_nombre_archivo := 'Formato' || v_fic.tformat || ' '
                                      || TO_CHAR(f_sysdate, 'dd_mm_yyyy HH24_MI_SS') || '.csv';
                  v_file := UTL_FILE.fopen(v_dir_oracle, v_nombre_archivo, 'w', 3200);
                  pr_path.EXTEND(1);
                  pr_path(v_indexpath) := v_dir_red || '/' || v_nombre_archivo;
                  v_formato := v_fic.tformat;
                  p_escribir_encabezado(v_file, v_fic, v_separador, v_nocol);
               END IF;

               IF v_indenc = 'S' THEN
                  p_escribir_encabezado(v_file, v_fic, v_separador, v_nocol);
               END IF;

               p_escribir_bloque(v_file, v_fic, v_separador, v_nocol);
               EXIT WHEN v_index = pr_tbfichero.LAST();
               v_index := pr_tbfichero.NEXT(v_index);
            END LOOP;
         END IF;

         UTL_FILE.fclose(v_file);
      END IF;

      p_nerror := 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_FIC_FORMATOS.p_generar_ficherocsv', 1,
                     'parametros: pr_tbfichero = ', SQLERRM);
         p_nerror := 108190;
   END p_generar_ficherocsv;

   /*************************************************************************
   PROCEDURE p_escribir_fichero
      Escribe filas en el archivo CSV
      param in out v_file: archivo de carga
      param in v_linea  : fila a guardar
   *************************************************************************/
   PROCEDURE p_escribir_fichero(p_file IN OUT UTL_FILE.file_type, p_linea IN VARCHAR2) IS
   BEGIN
      UTL_FILE.put_line(p_file, p_linea);
   END p_escribir_fichero;

   /*************************************************************************
   PROCEDURE p_escribir_bloque
      Escribe bloque de unidad de captura
      param in out v_file: archivo de carga
      param in v_fic : objeto fichero
   *************************************************************************/
   PROCEDURE p_escribir_bloque(
      v_file IN OUT UTL_FILE.file_type,
      v_fic IN ob_fichero,
      v_separador IN VARCHAR2,
      v_nocol IN NUMBER) IS
      v_titulo       fic_bloques_datos.tdescri%TYPE;
      v_index        NUMBER;
   BEGIN
      SELECT tdescri
        INTO v_titulo
        FROM fic_bloques_datos
       WHERE tgestor = v_fic.tgestor
         AND tformat = v_fic.tformat
         AND tblqdat = v_fic.nunicap;

      IF SQL%NOTFOUND = FALSE
         AND v_fic.tgestor <> '8' THEN
         p_escribir_fichero(v_file,
                            p_llenar_columnas(v_titulo || v_separador, v_nocol, v_separador)
                            || TO_CHAR(v_fic.nunicap) || v_separador);
      END IF;

      v_index := v_fic.ttablineas.FIRST;

      LOOP
         p_escribir_fichero(v_file, v_fic.ttablineas(v_index));
         EXIT WHEN v_index = v_fic.ttablineas.LAST();
         v_index := v_fic.ttablineas.NEXT(v_index);
      END LOOP;
   END p_escribir_bloque;

   /*************************************************************************
   PROCEDURE p_escribir_encabezado
      Escribe encabezados de bloques
      param in out v_file: archivo de carga
      param in v_fic : objeto fichero
   *************************************************************************/
   PROCEDURE p_escribir_encabezado(
      v_file IN OUT UTL_FILE.file_type,
      v_fic IN ob_fichero,
      v_separador IN VARCHAR2,
      v_nocol IN NUMBER) IS
      TYPE cur_type IS REF CURSOR;

      cur_encabezado cur_type;
      v_query        VARCHAR2(4000);
      v_linea        VARCHAR2(4000);
      v_encabezado   fic_columna_formatos.tnombre%TYPE;
   BEGIN
      v_query := 'select tnombre from fic_columna_formatos where tblqdat = '
                 || TO_CHAR(v_fic.nunicap) || ' and tformat = ' || CHR(39) || v_fic.tformat
                 || CHR(39) || ' and tgestor = ' || CHR(39) || v_fic.tgestor || CHR(39)
                 || 'Order by ccoform';

      OPEN cur_encabezado FOR v_query;

      LOOP
         FETCH cur_encabezado
          INTO v_encabezado;

         IF cur_encabezado%NOTFOUND
            AND v_fic.tgestor <> '8' THEN
            v_linea := p_llenar_columnas(v_linea, v_nocol, v_separador);
            v_linea := v_linea || 'Unidad de Captura' || v_separador;
         END IF;

         EXIT WHEN cur_encabezado%NOTFOUND;

         IF v_encabezado IS NULL THEN
            v_encabezado := ' ';
         END IF;

         v_linea := v_linea || v_encabezado || v_separador;
      END LOOP;

      p_escribir_fichero(v_file, v_linea);
   END p_escribir_encabezado;

   /*************************************************************************
   PROCEDURE p_escribir_titulo
      Escribe titulo formato
      param in out v_file: archivo de carga
      param in v_fic : objeto fichero
      param in v_finicio: fecha inicial formato
      param in v_ffin: fecha final formato
   *************************************************************************/
   PROCEDURE p_escribir_titulo(
      v_file IN OUT UTL_FILE.file_type,
      v_fic IN ob_fichero,
      v_separador IN VARCHAR2,
      v_nocol IN NUMBER,
      v_anio IN NUMBER,
      v_mes IN VARCHAR2,
      v_dia IN VARCHAR2) IS
      TYPE cur_type IS REF CURSOR;

      cur_encabezado cur_type;
      v_query        VARCHAR2(4000);
      v_linea        VARCHAR2(4000);
      v_encabezado   fic_columna_formatos.tnombre%TYPE;
      v_nombre       VARCHAR2(100);
      v_circular     VARCHAR2(100);
      v_fcorte       DATE;
      v_tempres      empresas.tempres%TYPE;
   BEGIN
      SELECT tnombre, tdocdef
        INTO v_nombre, v_circular
        FROM fic_formatos
       WHERE tformat = v_fic.tformat
         AND tgestor = v_fic.tgestor;

      SELECT tempres
        INTO v_tempres
        FROM empresas
       WHERE cempres = v_fic.cempres;

      p_escribir_fichero(v_file, v_nombre);
      p_escribir_fichero(v_file, 'Formato ' || v_fic.tformat);
      p_escribir_fichero(v_file, v_circular);
      p_escribir_fichero(v_file, 'Empresa : ' || v_tempres);

      IF v_dia = '0'
         AND v_mes = '0' THEN
         v_fcorte := TO_DATE(v_anio, 'yyyy');
         p_escribir_fichero(v_file, 'Fecha De Corte:' || TO_CHAR(v_fcorte, 'yyyy'));
      ELSIF v_dia = '0' THEN
         v_fcorte := TO_DATE(v_mes || '/' || v_anio, 'mm/yyyy');
         p_escribir_fichero(v_file, 'Fecha De Corte:' || TO_CHAR(v_fcorte, 'mm/yyyy'));
      ELSE
         v_fcorte := TO_DATE(v_dia || '/' || v_mes || '/' || v_anio, 'dd/mm/yyyy');
         p_escribir_fichero(v_file, 'Fecha De Corte:' || TO_CHAR(v_fcorte, 'dd/mm/yyyy'));
      END IF;
   END p_escribir_titulo;

   /*************************************************************************
   FUNCTION p_llenar_columnas
      Llena columnas vacias
      param in out v_string : linea del archivo separada por el delimitador
      param in v_nocolumnas : numero de columnas del formato
      param in v_separador : delimitador de columnas
   *************************************************************************/
   FUNCTION p_llenar_columnas(v_string VARCHAR2, v_nocolumnas NUMBER, v_separador VARCHAR2)
      RETURN VARCHAR2 IS
      v_columnas     t_linea;
      v_index        NUMBER := 0;
      v_fila         VARCHAR2(4000);
   BEGIN
      v_columnas := f_split(v_string, v_separador);

      IF v_columnas.LAST() < v_nocolumnas THEN
         v_index := v_columnas.LAST() + 1;
         v_columnas.EXTEND(v_nocolumnas);

         LOOP
            v_columnas(v_index) := ' ' || v_separador;
            EXIT WHEN v_index = v_nocolumnas;
            v_index := v_columnas.NEXT(v_index);
         END LOOP;

         v_index := v_columnas.FIRST;

         LOOP
            v_fila := v_fila || v_columnas(v_index);
            EXIT WHEN v_index = v_columnas.LAST();
            v_index := v_columnas.NEXT(v_index);
         END LOOP;
      ELSE
         v_fila := v_string;
      END IF;

      RETURN v_fila;
   END p_llenar_columnas;

   /*************************************************************************
   FUNCTION f_split
      divide un string segun un deliminator en un array
      param in v_string : String a dividir
      param in v_delim: Delimitador
      RETURN t_linea : Array con los string inviduales separados por el delimitador
   *************************************************************************/
   FUNCTION f_split(v_string VARCHAR2, v_delim VARCHAR2)
      RETURN t_linea IS
      v_index        NUMBER := 0;
      v_pos          NUMBER := 0;
      v_str          VARCHAR2(4000) := v_string;
      v_strings      t_linea := NEW t_linea();
   BEGIN
      v_pos := INSTR(v_str, v_delim, 1, 1);

      WHILE(v_pos != 0) LOOP
         v_index := v_index + 1;
         v_strings.EXTEND(1);
         v_strings(v_index) := SUBSTR(v_str, 1, v_pos);
         v_str := SUBSTR(v_str, v_pos + 1, LENGTH(v_str));
         v_pos := INSTR(v_str, v_delim, 1, 1);

         IF v_pos = 0 THEN
            v_strings.EXTEND(1);
            v_strings(v_index + 1) := v_str;
         END IF;
      END LOOP;

      RETURN v_strings;
   END f_split;

      /*************************************************************************
   FUNCTION f_validar_columnas
      valida numero de columnas de una fila
      param in v_string : String a dividir
      param in v_delim: Delimitador
      RETURN BOOLEAN: retorna true cuando la fila esta correcta
   *************************************************************************/
   FUNCTION f_validar_columnas(p_tstring VARCHAR2, p_tdelim VARCHAR2, p_ncolumnas NUMBER)
      RETURN BOOLEAN IS
      v_columnas     t_linea := NEW t_linea();
   BEGIN
      v_columnas := f_split(p_tstring, p_tdelim);

      IF v_columnas.LAST = p_ncolumnas THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;

      RETURN FALSE;
   END f_validar_columnas;

   /*************************************************************************
   PROCEDURE p_set_fic_repositorio
      Inserta las filas que salen de la función p_ejecuta_funcion
      param in p_ob_fichero: archivo de carga
      param in p_tgestor : gestor del proceso
      param in p_tformat : formato del proceso
      param in p_anio : objeto fichero
      param in p_mes: archivo de carga
      param in p_dia : objeto fichero
      param in p_columnas: archivo de carga
      param in p_delim : objeto fichero
      param in p_sproces: archivo de carga
   *************************************************************************/
   PROCEDURE p_set_fic_repositorio(
      p_ob_fichero IN ob_fichero,
      p_tgestor fic_gestores.tgestor%TYPE,
      p_tformat fic_formatos.tformat%TYPE,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_columnas IN VARCHAR2,
      p_separador IN VARCHAR2,
      p_sproces IN NUMBER) IS
      v_index        NUMBER;
   BEGIN
      v_index := p_ob_fichero.ttablineas.FIRST;

      LOOP
         --consulta que obtiene la fila entregada como columna de datos
         INSERT INTO fic_repositorio_formatos
                     (tgestor, tformat, nejerci, tperiod, tdiasem, tblqdat, nsubcun, ncolumn,
                      tvalor, ttipdoc, tnumdoc, tnumpol, sproces)
            SELECT DISTINCT p_tgestor, p_tformat, p_anio, p_mes, p_dia, p_ob_fichero.nunicap,
                            DECODE
                               (p_tgestor,
                                '8', v_index,
                                TO_NUMBER
                                   (SUBSTR
                                       (p_ob_fichero.ttablineas(v_index), 0,   --obtiene el numero de fila para insertarlo en el campo subcuenta
                                        INSTR(p_ob_fichero.ttablineas(v_index), p_separador, 1,
                                              1)
                                        - 1))),
                            TO_NUMBER
                               (REGEXP_SUBSTR
                                   (p_columnas,   --voltea las filas para que sean columnas
                                    '[^' || p_separador || ']+', 1, LEVEL)) AS columna,
                            REPLACE
                               (REGEXP_SUBSTR
                                   (REPLACE(p_ob_fichero.ttablineas(v_index), ';;',
                                            ' ; ;'),   -- voltea los valores de las filas para que sean columnas
                                    '[^' || p_separador || ']*(.|$)', 1, LEVEL),
                                p_separador, '') AS valor,
                            p_ob_fichero.ttipdoc, p_ob_fichero.tnumdoc, p_ob_fichero.tnumpol,
                            p_sproces
                       FROM DUAL
                 CONNECT BY REGEXP_SUBSTR(p_columnas, '[^' || p_separador || ']+', 1, LEVEL) IS NOT NULL;   --controla el numero de columnas

         EXIT WHEN v_index = p_ob_fichero.ttablineas.LAST();
         v_index := p_ob_fichero.ttablineas.NEXT(v_index);
      END LOOP;
   END p_set_fic_repositorio;

      /*************************************************************************
    FUNCTION f_rowconcat
      Función para poder seleccionar el texto de varias filas en una única columna
      RETURN t_array : Array con los string inviduales separados por el delimitador
   *************************************************************************/
   FUNCTION f_rowconcat(p_string VARCHAR2, p_delim VARCHAR2)
      RETURN VARCHAR2 IS
      v_ret          VARCHAR2(4000);
      v_hold         VARCHAR2(4000);
      v_cur          sys_refcursor;
   BEGIN
      OPEN v_cur FOR p_string;

      LOOP
         FETCH v_cur
          INTO v_hold;

         EXIT WHEN v_cur%NOTFOUND;

         IF v_ret IS NULL THEN
            v_ret := v_hold;
         ELSE
            v_ret := v_ret || p_delim || v_hold;
         END IF;
      END LOOP;

      RETURN v_ret;
   END f_rowconcat;

    /*************************************************************************
   FUNCTION f_get_fic_repositorio
      Obtiene los registros de fic_respositorio formato y lo transforma para enviarselo a p_generar_ficherocsv
      param in p_separador: separador de la tabla fic_gestores
      param in p_tgestor: codigo de gestor
      param in p_tformato: codigo de formato
      param in p_empres: empresa
      param in p_anio : objeto fichero
      param in p_mes: archivo de carga
      param in p_dia : objeto fichero
      param in p_tnumdoc: numero documento
      param in p_ttipodoc : tipo documento
      param in p_tnumpol: numero de poliza
   *************************************************************************/
   FUNCTION f_get_fic_repositorio(
      p_separador IN VARCHAR2,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_empres IN NUMBER,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_tnumdoc IN VARCHAR2,
      p_ttipodoc IN VARCHAR2,
      p_tnumpol IN VARCHAR2)
      RETURN t_tabla_ficheros IS
      v_lineas       t_linea := NEW t_linea();
      v_tabla_ficheros t_tabla_ficheros := NEW t_tabla_ficheros();
      v_ob_fichero   ob_fichero;
      v_concatenados VARCHAR2(4000);
      v_index        NUMBER := 0;
      v_indexfic     NUMBER := 0;
      v_aux          NUMBER;
      v_tblqdat      NUMBER;
      vparam         VARCHAR2(800)
         := 'param: - p_separador : ' || p_separador || ',p_tgestor ' || p_tgestor
            || ',p_tformato ' || p_tformato || ',p_empres ' || p_empres || ',p_anio '
            || p_anio || ',p_mes ' || p_mes || ',p_dia ' || p_dia || ',p_tnumdoc '
            || p_tnumdoc || ',p_ttipodoc ' || p_ttipodoc || ',p_tnumpol ' || p_tnumpol;

      CURSOR bloques IS
         SELECT DISTINCT tblqdat, nsubcun
                    FROM fic_repositorio_formatos r
                   WHERE r.tgestor = p_tgestor
                     AND r.tformat = p_tformato
                     AND r.nejerci = p_anio
                     AND r.tperiod = p_mes
                     AND r.tdiasem = p_dia
                GROUP BY tblqdat, nsubcun
                ORDER BY tblqdat, nsubcun;

      v_registros    bloques%ROWTYPE;
   BEGIN
      /*SELECT MAX(tblqdat)
        INTO v_tblqdat
        FROM fic_repositorio_formatos r
       WHERE r.tgestor = p_tgestor
         AND r.tformat = p_tformato
         AND r.nejerci = p_anio
         AND r.tperiod = p_mes
         AND r.tdiasem = p_dia;*/
      FOR v_registros IN bloques LOOP
         IF v_index = 0 THEN
            v_aux := v_registros.tblqdat;

            --v_indexfic := v_indexfic + 1;
            SELECT   COUNT(DISTINCT r.nsubcun)
                INTO v_indexfic
                FROM fic_repositorio_formatos r
               WHERE r.tgestor = p_tgestor
                 AND r.tformat = p_tformato
                 AND r.nejerci = p_anio
                 AND r.tperiod = p_mes
                 AND r.tdiasem = p_dia
                 AND r.tblqdat = v_registros.tblqdat
            GROUP BY r.tgestor, r.tformat, r.nejerci, r.tperiod, r.tdiasem, r.tblqdat;
         END IF;

         v_concatenados :=
            f_rowconcat
               ('select tvalor from fic_repositorio_formatos r
       where r.tgestor =''' || p_tgestor || '''
        and r.tformat=''' || p_tformato || '''
        and r.nejerci =' || p_anio || '
        and r.tperiod =''' || p_mes || '''
        and r.tdiasem =''' || p_dia || '''
        and r.tblqdat =' || v_registros.tblqdat || '
        and r.nsubcun =' || v_registros.nsubcun
                || '
        order by r.tblqdat,r.nsubcun, r.ncolumn',
                p_separador);
         v_index := v_index + 1;
         v_lineas.EXTEND;
         v_lineas(v_lineas.LAST) := v_concatenados || p_separador;

         IF v_registros.tblqdat <> v_aux
            OR v_index = v_indexfic THEN
            v_ob_fichero := NEW ob_fichero(p_empres, p_tgestor, p_tformato,
                                           v_registros.tblqdat, v_lineas, p_ttipodoc,
                                           p_tnumdoc, p_tnumpol);
            v_tabla_ficheros.EXTEND;
            v_tabla_ficheros(v_tabla_ficheros.LAST) := v_ob_fichero;
            v_lineas := NEW t_linea();
            --v_indexfic := v_indexfic + 1;
            v_index := 0;
            v_aux := v_registros.tblqdat;
         END IF;
      END LOOP;

      RETURN v_tabla_ficheros;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_FIC_FORMATOS.f_get_fic_repositorio', 1, vparam,
                     SQLERRM);
   END f_get_fic_repositorio;

    /*************************************************************************
   PROCEDURE p_delete_ficrepositorio
      Elimina los registros de la tabla fic_repositorio para continuar proceso
      p_set_fic_repositorio
      param in p_tgestor: codigo gestor
      param in p_tformat: codigo formato
      param in p_anio : año
      param in p_mes: mes
      param in p_dia : dia

   *************************************************************************/
   PROCEDURE p_delete_ficrepositorio(
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2) IS
      vparam         VARCHAR2(800)
         := 'param: - p_tgestor : ' || p_tgestor || ',p_tformato ' || p_tformato || ',p_anio '
            || p_anio || ',p_mes ' || p_mes || ',p_dia ' || p_dia;
   BEGIN
      DELETE FROM fic_repositorio_formatos
            WHERE tgestor = p_tgestor
              AND tformat = NVL(p_tformato, tformat)
              AND nejerci = NVL(p_anio, nejerci)
              AND tperiod = NVL(p_mes, tperiod)
              AND tdiasem = NVL(p_dia, tdiasem);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_FIC_FORMATOS.p_set_del_ficrepositorio', 1,
                     vparam, SQLERRM);
   END p_delete_ficrepositorio;

    /*************************************************************************
   FUNCTION f_genera_formatos
      función principal que genera cada uno de los formatos
      param in pnempresa: codigo de empresa
      param in ptgestor: codigo gestor
      param in ptformatos: codigo formato
      param in pnanio : año
      param in pnmes: mes
      param in pnsem_dia : dia
      param in pchk_genera : Indicador del check de generar datos de pantalla
      param in pchkescribe : Indicador del check de escribir de pantalla

   *************************************************************************/
   FUNCTION f_genera_formatos(
      pnempresa fic_gestores.cempres%TYPE,
      ptgestor fic_gestores.tgestor%TYPE,
      ptformatos VARCHAR2,
      pnanio NUMBER,
      pnmes VARCHAR2,
      pnsem_dia VARCHAR2,
      pchk_genera VARCHAR2,
      pchkescribe VARCHAR2,
      psproces NUMBER)
      RETURN NUMBER IS
      vparam         VARCHAR2(800)
         := 'param: - pnempresa : ' || pnempresa || ',ptformatos ' || ptformatos || ',pnanio '
            || pnanio || ',pnmes ' || pnmes || ',pnsem_dia ' || pnsem_dia || ',pchk_genera '
            || pchk_genera || ',pchkescribe ' || pchkescribe || ',psproces ' || psproces;

      CURSOR cur_formatos(
         pempres fic_gestores.cempres%TYPE,
         pgestor fic_gestores.tgestor%TYPE,
         pformato fic_formatos.tformat%TYPE) IS
         SELECT *
           FROM fic_formatos
          WHERE tgestor = pgestor
            AND tformat = NVL(pformato, tformat);

      t_fichero      t_tabla_ficheros;
      e_control      EXCEPTION;
      v_error        NUMBER := 0;
      v_derror       VARCHAR2(300);
      v_terror       VARCHAR2(300);
      v_errorpro     NUMBER := 0;
      v_codproceso   NUMBER := psproces;
      v_separador    fic_gestores.tsepfor%TYPE;
      v_tipdoc       fic_repositorio_formatos.ttipdoc%TYPE;
      v_numdoc       fic_repositorio_formatos.tnumdoc%TYPE;
      v_tnumpol      fic_repositorio_formatos.tnumpol%TYPE;
      v_columnas     VARCHAR2(4000);
      v_pnprolin     NUMBER := 0;
      v_prolinini    NUMBER := 0;
      paths_dir      t_linea := NEW t_linea();
      v_path         VARCHAR2(100);
      vctiplin       NUMBER := 0;
      verr_camp      NUMBER := 0;
      verr_gen       NUMBER := 0;
      t_paramcolum   t_paramcol;
      paramcolum     paramcol;

      CURSOR p_cursorcol(
         pgestor fic_gestores.tgestor%TYPE,
         pformato fic_formatos.tformat%TYPE) IS
         SELECT   f.ccoform, f.ttipdat, f.tformca, f.ntamano, f.tobliga
             FROM fic_columna_formatos f
            WHERE f.tgestor = pgestor
              AND f.tformat = pformato
         ORDER BY f.ccoform;
   BEGIN
      SELECT tsepfor
        INTO v_separador
        FROM fic_gestores
       WHERE tgestor = ptgestor;

      IF (pchk_genera = 'S'
          AND pchkescribe = 'S') THEN   --genera formatos y escribe los CSV
         FOR rg_formatos IN cur_formatos(pnempresa, ptgestor, ptformatos) LOOP
            v_path := ' ';
            v_error := pac_fic_procesos.f_alta_proceso_detalle(v_codproceso,
                                                               'generacion formato '
                                                               || rg_formatos.tformat,
                                                               v_path, v_prolinini, 6);

            -- vaciar datos de la tabla fic_repositorio
            BEGIN
               p_delete_ficrepositorio(ptgestor, rg_formatos.tformat, pnanio, pnmes,
                                       pnsem_dia);
               COMMIT;
            EXCEPTION
               WHEN OTHERS THEN
                  verr_camp := 1;
                  v_derror := 'pac_fic_formatos.p_delete_ficrepositorio';
                  v_terror := SQLERRM || ' ' || SQLCODE;
                  p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error,
                              SQLERRM || ' ' || SQLCODE);
            END;

            -- ejecutar función de negocio para obtener tabla tipo t_tabla_ficheros
            BEGIN
               t_fichero := NEW t_tabla_ficheros();

               IF rg_formatos.tfunlle IS NOT NULL THEN
                  EXECUTE IMMEDIATE ('begin' || ' :1 :=' || rg_formatos.tfunlle || '('
                                     || pnempresa || ',''' || rg_formatos.tgestor || ''','''
                                     || rg_formatos.tformat || ''',' || pnanio || ',' || pnmes
                                     || ',' || pnsem_dia || ',''' || v_separador || '''); '
                                     || 'end;')
                              USING OUT t_fichero;
               ELSE
                  verr_camp := 2;
                  v_derror := 'EXECUTE rg_formatos.tfunlle ';
                  v_terror := 'param : = tfunlle is null' || rg_formatos.tgestor
                              || ' formato ' || rg_formatos.tformat;
                  p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error, v_terror);
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  verr_camp := 2;
                  v_derror := 'EXECUTE rg_formatos.tfunlle ';
                  v_terror := SQLERRM || ' ' || SQLCODE;
                  p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error, v_terror);
            END;

            IF t_fichero.COUNT > 0 THEN
               -- obtener cadena de columnas del formato para enviarsela al registro de fic_repositorio_formatos
               BEGIN
                  SELECT pac_fic_formatos.f_rowconcat
                              ('SELECT ccoform from fic_columna_formatos where tgestor ='''
                               || ptgestor || ''' and tformat=''' || rg_formatos.tformat
                               || ''' ',
                               v_separador) AS columnas
                    INTO v_columnas
                    FROM DUAL;
               EXCEPTION
                  WHEN OTHERS THEN
                     verr_camp := 3;
                     v_derror := 'pac_fic_formatos.f_rowconcat ';
                     v_terror := SQLERRM || ' ' || SQLCODE;
                     p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error, v_terror);
               END;

               -- validacion de datos en la tabla fic_repositorio_formatos
               BEGIN
                  t_paramcolum := NEW t_paramcol();

                  OPEN p_cursorcol(rg_formatos.tgestor, rg_formatos.tformat);

                  LOOP
                     FETCH p_cursorcol
                      INTO paramcolum.ccoform, paramcolum.ttipdat, paramcolum.tformca,
                           paramcolum.ntamano, paramcolum.tobliga;

                     EXIT WHEN p_cursorcol%NOTFOUND;
                     t_paramcolum.EXTEND;
                     t_paramcolum(t_paramcolum.LAST) := paramcolum;
                  END LOOP;

                  CLOSE p_cursorcol;

                  FOR reg_obfichero IN t_fichero.FIRST .. t_fichero.LAST LOOP
                     verr_camp := f_valida_formatos(rg_formatos.tgestor, rg_formatos.tformat,
                                                    t_fichero(reg_obfichero), v_separador,
                                                    t_paramcolum);
                  END LOOP;
               EXCEPTION
                  WHEN OTHERS THEN
                     verr_camp := 4;
                     v_derror := 'pac_fic_formatos.f_validar ';
                     v_terror := SQLERRM || ' ' || SQLCODE;
                     p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error, v_terror);
               END;
            ELSE
               verr_camp := 6;
               v_derror := 'NO DATA FOUND ';
               v_terror := SQLERRM || ' ' || SQLCODE;
               p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error, v_terror);
            END IF;

            IF verr_camp = 0 THEN
               -- registro de datos en la tabla fic_repositorio_formatos
               BEGIN
                  FOR reg_obfichero IN t_fichero.FIRST .. t_fichero.LAST LOOP
                     p_set_fic_repositorio(t_fichero(reg_obfichero), rg_formatos.tgestor,
                                           rg_formatos.tformat, pnanio, pnmes, pnsem_dia,
                                           v_columnas, v_separador, v_codproceso);
                  END LOOP;

                  COMMIT;
               EXCEPTION
                  WHEN OTHERS THEN
                     ROLLBACK;
                     verr_camp := 4;
                     v_derror := 'pac_fic_formatos.p_set_fic_repositorio ';
                     v_terror := SQLERRM || ' ' || SQLCODE;
                     p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error, v_terror);
               END;

               -- escritura de datos
               BEGIN
                  pac_fic_formatos.p_generar_ficherocsv(t_fichero, v_error, paths_dir, pnanio,
                                                        pnmes, pnsem_dia);
                  v_path := paths_dir(1);
               EXCEPTION
                  WHEN OTHERS THEN
                     verr_camp := 5;
                     v_derror := 'pac_fic_formatos.p_generar_ficherocsv ';
                     v_terror := SQLERRM || ' ' || SQLCODE;
                     p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error, v_terror);
               END;
            ELSE
               v_derror := 'pac_fic_formatos.f_validar ';
               v_terror := 'param p_obfichero.ttablineas error';
               p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error, v_terror);
            END IF;

            IF verr_camp = 0 THEN
               vctiplin := 4;
            ELSIF verr_camp = 6 THEN
               vctiplin := 5;
            ELSE
               vctiplin := 1;
               v_errorpro := 1;
               verr_gen := 1;
               v_path := ' ';
               verr_camp := 0;
            END IF;

            v_pnprolin := v_pnprolin + 1;
            v_error := pac_fic_procesos.f_alta_proceso_detalle(v_codproceso,
                                                               'generacion formato '
                                                               || rg_formatos.tformat,
                                                               v_path, v_pnprolin, vctiplin);
         END LOOP;
      ELSE
         IF (pchk_genera = 'S') THEN   --genera formatos
            FOR rg_formatos IN cur_formatos(pnempresa, ptgestor, ptformatos) LOOP
               v_path := ' ';
               v_error := pac_fic_procesos.f_alta_proceso_detalle(v_codproceso,
                                                                  'generacion formato '
                                                                  || rg_formatos.tformat,
                                                                  v_path, v_prolinini, 6);

               -- vaciar datos de la tabla fic_repositorio
               BEGIN
                  p_delete_ficrepositorio(ptgestor, rg_formatos.tformat, pnanio, pnmes,
                                          pnsem_dia);
                  COMMIT;
               EXCEPTION
                  WHEN OTHERS THEN
                     verr_camp := 1;
                     v_derror := 'pac_fic_formatos.p_delete_ficrepositorio ';
                     v_terror := SQLERRM || ' ' || SQLCODE;
                     p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error,
                                 SQLERRM || ' ' || SQLCODE);
               END;

               -- ejecutar función de negocio para obtener tabla tipo t_tabla_ficheros
               BEGIN
                  t_fichero := NEW t_tabla_ficheros();

                  IF rg_formatos.tfunlle IS NOT NULL THEN
                     EXECUTE IMMEDIATE ('begin' || ' :1 :=' || rg_formatos.tfunlle || '('
                                        || pnempresa || ',''' || rg_formatos.tgestor || ''','''
                                        || rg_formatos.tformat || ''',' || pnanio || ','
                                        || pnmes || ',' || pnsem_dia || ',''' || v_separador
                                        || '''); ' || 'end;')
                                 USING OUT t_fichero;
                  ELSE
                     verr_camp := 2;
                     v_derror := 'EXECUTE rg_formatos.tfunlle ';
                     v_terror := SQLERRM || ' ' || SQLCODE;
                     p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error,
                                 SQLERRM || ' ' || SQLCODE);
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     verr_camp := 2;
                     v_derror := 'EXECUTE rg_formatos.tfunlle ';
                     p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error,
                                 SQLERRM || ' ' || SQLCODE);
               END;

               IF t_fichero.COUNT > 0 THEN
                  -- obtener cadena de columnas del formato para enviarsela al registro de fic_repositorio_formatos
                  BEGIN
                     SELECT pac_fic_formatos.f_rowconcat
                               ('SELECT ccoform from fic_columna_formatos where tgestor ='''
                                || ptgestor || ''' and tformat=''' || rg_formatos.tformat
                                || ''' ',
                                v_separador) AS columnas
                       INTO v_columnas
                       FROM DUAL;
                  EXCEPTION
                     WHEN OTHERS THEN
                        verr_camp := 3;
                        v_derror := 'pac_fic_formatos.f_rowconcat ';
                        v_terror := SQLERRM || ' ' || SQLCODE;
                        p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error,
                                    SQLERRM || ' ' || SQLCODE);
                  END;

                  -- validacion de datos en la tabla fic_repositorio_formatos
                  BEGIN
                     t_paramcolum := NEW t_paramcol();

                     OPEN p_cursorcol(rg_formatos.tgestor, rg_formatos.tformat);

                     LOOP
                        FETCH p_cursorcol
                         INTO paramcolum.ccoform, paramcolum.ttipdat, paramcolum.tformca,
                              paramcolum.ntamano, paramcolum.tobliga;

                        EXIT WHEN p_cursorcol%NOTFOUND;
                        t_paramcolum.EXTEND;
                        t_paramcolum(t_paramcolum.LAST) := paramcolum;
                     END LOOP;

                     CLOSE p_cursorcol;

                     FOR reg_obfichero IN t_fichero.FIRST .. t_fichero.LAST LOOP
                        verr_camp := f_valida_formatos(rg_formatos.tgestor,
                                                       rg_formatos.tformat,
                                                       t_fichero(reg_obfichero), v_separador,
                                                       t_paramcolum);
                     END LOOP;
                  EXCEPTION
                     WHEN OTHERS THEN
                        verr_camp := 4;
                        v_derror := 'pac_fic_formatos.f_validar ';
                        v_terror := SQLERRM || ' ' || SQLCODE;
                        p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error,
                                    v_terror);
                  END;
               ELSE
                  verr_camp := 6;
                  v_derror := 'DATA NO FOUND ';
                  v_terror := SQLERRM || ' ' || SQLCODE;
                  p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error, v_terror);
               END IF;

               IF verr_camp = 0 THEN
                  -- registro de datos en la tabla fic_repositorio_formatos
                  BEGIN
                     FOR reg_obfichero IN t_fichero.FIRST .. t_fichero.LAST LOOP
                        p_set_fic_repositorio(t_fichero(reg_obfichero), rg_formatos.tgestor,
                                              rg_formatos.tformat, pnanio, pnmes, pnsem_dia,
                                              v_columnas, v_separador, v_codproceso);
                     END LOOP;

                     COMMIT;
                  EXCEPTION
                     WHEN OTHERS THEN
                        ROLLBACK;
                        verr_camp := 4;
                        v_derror := 'pac_fic_formatos.p_set_fic_repositorio ';
                        v_terror := SQLERRM || ' ' || SQLCODE;
                        p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error,
                                    v_terror);
                  END;
               ELSE
                  v_derror := 'pac_fic_formatos.f_validar ';
                  v_terror := 'param p_obfichero.ttablineas error';
                  p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error, v_terror);
               END IF;

               IF verr_camp = 0 THEN
                  vctiplin := 4;
               ELSIF verr_camp = 6 THEN
                  vctiplin := 5;
               ELSE
                  v_errorpro := 1;
                  vctiplin := 1;
                  verr_gen := 1;
                  v_path := ' ';
                  verr_camp := 0;
               END IF;

               v_pnprolin := v_pnprolin + 1;
               v_error := pac_fic_procesos.f_alta_proceso_detalle(v_codproceso,
                                                                  'generacion formato '
                                                                  || rg_formatos.tformat,
                                                                  v_path, v_pnprolin, vctiplin);
            END LOOP;
         ELSE
            IF (pchkescribe = 'S') THEN   --escribe los CSV
               FOR rg_formatos IN cur_formatos(pnempresa, ptgestor, ptformatos) LOOP
                  v_path := ' ';
                  v_error :=
                     pac_fic_procesos.f_alta_proceso_detalle(v_codproceso,
                                                             'generacion formato '
                                                             || rg_formatos.tformat,
                                                             v_path, v_prolinini, 6);

                  -- llamado tranformacion
                  BEGIN
                     SELECT DISTINCT ttipdoc, tnumdoc, tnumpol
                                INTO v_tipdoc, v_numdoc, v_tnumpol
                                FROM fic_repositorio_formatos
                               WHERE tgestor = ptgestor
                                 AND tformat = rg_formatos.tformat
                                 AND nejerci = NVL(pnanio, nejerci)
                                 AND tperiod = NVL(pnmes, tperiod)
                                 AND tdiasem = NVL(pnsem_dia, tdiasem);
                  EXCEPTION
                     WHEN OTHERS THEN
                        verr_camp := 1;
                        v_derror := 'Query fic_repositorio_formatos ';
                        v_terror := SQLERRM || ' ' || SQLCODE;
                        p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error,
                                    v_terror);
                  END;

                  BEGIN
                     t_fichero := pac_fic_formatos.f_get_fic_repositorio(v_separador,
                                                                         rg_formatos.tgestor,
                                                                         rg_formatos.tformat,
                                                                         pnempresa, pnanio,
                                                                         pnmes, pnsem_dia,
                                                                         v_numdoc, v_tipdoc,
                                                                         v_tnumpol);
                  EXCEPTION
                     WHEN OTHERS THEN
                        verr_camp := 2;
                        v_derror := 'pac_fic_formatos.f_get_fic_repositorio ';
                        v_terror := SQLERRM || ' ' || SQLCODE;
                        p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error,
                                    v_terror);
                  END;

                  IF t_fichero.COUNT > 0 THEN
                     -- validacion de datos en la tabla fic_repositorio_formatos
                     BEGIN
                        t_paramcolum := NEW t_paramcol();

                        OPEN p_cursorcol(rg_formatos.tgestor, rg_formatos.tformat);

                        LOOP
                           FETCH p_cursorcol
                            INTO paramcolum.ccoform, paramcolum.ttipdat, paramcolum.tformca,
                                 paramcolum.ntamano, paramcolum.tobliga;

                           EXIT WHEN p_cursorcol%NOTFOUND;
                           t_paramcolum.EXTEND;
                           t_paramcolum(t_paramcolum.LAST) := paramcolum;
                        END LOOP;

                        CLOSE p_cursorcol;

                        FOR reg_obfichero IN t_fichero.FIRST .. t_fichero.LAST LOOP
                           verr_camp := f_valida_formatos(rg_formatos.tgestor,
                                                          rg_formatos.tformat,
                                                          t_fichero(reg_obfichero),
                                                          v_separador, t_paramcolum);
                        END LOOP;
                     EXCEPTION
                        WHEN OTHERS THEN
                           verr_camp := 4;
                           v_derror := 'pac_fic_formatos.f_validar ';
                           v_terror := SQLERRM || ' ' || SQLCODE;
                           p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error,
                                       v_terror);
                     END;
                  ELSE
                     verr_camp := 6;
                     v_derror := 'DATA NO FOUND ';
                     v_terror := SQLERRM || ' ' || SQLCODE;
                     p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error, v_terror);
                  END IF;

                  IF verr_camp = 0 THEN
                     -- escritura de datos
                     BEGIN
                        pac_fic_formatos.p_generar_ficherocsv(t_fichero, v_error, paths_dir,
                                                              pnanio, pnmes, pnsem_dia);
                        v_path := paths_dir(1);
                     EXCEPTION
                        WHEN OTHERS THEN
                           verr_camp := 5;
                           v_derror := 'pac_fic_formatos.p_generar_ficherocsv ';
                           v_terror := SQLERRM || ' ' || SQLCODE;
                           p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error,
                                       v_terror);
                     END;
                  ELSE
                     v_derror := 'pac_fic_formatos.f_validar ';
                     v_terror := 'param p_obfichero.ttablineas error';
                     p_tab_error(f_sysdate, f_user, v_derror || vparam, 0, v_error, v_terror);
                  END IF;

                  IF verr_camp = 0 THEN
                     vctiplin := 4;
                  ELSIF verr_camp = 6 THEN
                     vctiplin := 5;
                  ELSE
                     vctiplin := 1;
                     v_errorpro := 1;
                     verr_gen := 1;
                     v_path := ' ';
                     verr_camp := 0;
                  END IF;

                  v_pnprolin := v_pnprolin + 1;
                  v_error := pac_fic_procesos.f_alta_proceso_detalle(v_codproceso,
                                                                     'generacion formato '
                                                                     || rg_formatos.tformat,
                                                                     v_path, v_pnprolin,
                                                                     vctiplin);
               END LOOP;
            END IF;
         END IF;
      END IF;

      v_error := pac_fic_procesos.f_update_procesofin(v_codproceso, verr_gen);

      IF v_error = 0 THEN
         COMMIT;
         RETURN 0;
      ELSE
         RETURN v_error;
      END IF;
   EXCEPTION
      WHEN e_control THEN
         p_tab_error(f_sysdate, f_user, 'pac_fic_formatos.genera_formato :' || vparam,
                     v_error, v_derror, v_terror);
         v_error := pac_fic_procesos.f_update_procesofin(v_codproceso, 1);
         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_fic_formatos.genera_formato :' || vparam, 0,
                     v_error, SQLERRM || ' ' || SQLCODE);
         v_error := pac_fic_procesos.f_update_procesofin(v_codproceso, 1);
         RETURN 1;
   END f_genera_formatos;

      /*************************************************************************
   FUNCTION f_valida_formatos
      función principal que genera cada uno de los formatos
      param in p_nempresa: codigo de empresa
      param in p_tgestor: codigo gestor
      param in p_tformatos: codigo formato
      param in p_obfichero : objeto fichero
      param in p_separador
      RETURN NUMBER;
   *************************************************************************/
   FUNCTION f_valida_formatos(
      p_tgestor fic_gestores.tgestor%TYPE,
      p_tformatos fic_formatos.tformat%TYPE,
      p_obfichero ob_fichero,
      p_separador VARCHAR2,
      t_paramcolum t_paramcol)
      RETURN NUMBER IS
      v_tvalor       fic_repositorio_formatos.tvalor%TYPE;
      vcolumnas      t_linea := NEW t_linea();
      v_number       NUMBER;
      v_fecha        DATE;
      p_error        NUMBER := 0;
   BEGIN
      FOR rg_objeto IN p_obfichero.ttablineas.FIRST .. p_obfichero.ttablineas.LAST LOOP
         vcolumnas := f_split(p_obfichero.ttablineas(rg_objeto), p_separador);

         IF vcolumnas.LAST = t_paramcolum.LAST THEN
            FOR rg_linea IN vcolumnas.FIRST .. vcolumnas.LAST LOOP
               v_tvalor := REPLACE(vcolumnas(rg_linea), p_separador);

               IF LENGTH(v_tvalor) > t_paramcolum(rg_linea).ntamano THEN
                  p_error := 5;
               ELSE
                  IF t_paramcolum(rg_linea).tobliga = 'S'
                     AND v_tvalor IS NULL
                     OR t_paramcolum(rg_linea).tobliga = 'S'
                        AND TRIM(v_tvalor) = '' THEN
                     p_error := 1;
                  ELSE
                     CASE t_paramcolum(rg_linea).ttipdat
                        WHEN 'N' THEN
                           IF v_tvalor IS NOT NULL
                              AND TRIM(v_tvalor) <> '' THEN
                              v_number := TO_NUMBER(REPLACE(v_tvalor, '.', ','));
                           END IF;
                        WHEN 'F' THEN
                           IF t_paramcolum(rg_linea).tformca IS NULL THEN
                              p_error := 2;
                           ELSE
                              IF v_tvalor IS NOT NULL
                                 AND TRIM(v_tvalor) <> '' THEN
                                 v_fecha := TO_DATE(v_tvalor, t_paramcolum(rg_linea).tformca);
                              END IF;
                           END IF;
                        WHEN 'C' THEN
                           NULL;
                        ELSE
                           p_error := 3;
                     END CASE;
                  END IF;
               END IF;
            END LOOP;
         ELSE
            p_error := 4;
         END IF;
      END LOOP;

      RETURN p_error;
   EXCEPTION
      WHEN OTHERS THEN
         p_error := 5;
         /*p_tab_error(f_sysdate, f_USER, 'pac_fic_formatos.VLIDACIONES :' || p_error, 0,
                     5, SQLERRM || ' ' || SQLCODE);*/
         RETURN p_error;
   END f_valida_formatos;

     /*************************************************************************
   PROCEDURE f_transformacion
      Funcion generica para transformar una consulta en un regitro del objeto t_tabla_ficheros
      param in p_tquery: string con la consulta del bloque
      param in p_empres: empresa
      param in p_tgestor: codigo de gestor
      param in p_tformato: codigo de formato
      param in p_nnunicap: unidad de captura
      param in p_separador: separador de la tabla fic_gestores
      param in p_subtotales: columnas a aplicar calculo de subtotales separadas por ';'
      param in p_col_estaticas: columnas estaticas para los subtotales
      param in out v_tbfichero: objeto fichero
   *************************************************************************/
   PROCEDURE f_transformacion(
      p_tquery IN VARCHAR2,
      p_empres IN NUMBER,
      p_tgestor IN VARCHAR2,
      p_tformato IN VARCHAR2,
      p_nnunicap IN NUMBER,
      p_separador IN VARCHAR2,
      p_subtotales IN VARCHAR2,
      p_col_estaticas IN t_linea,
      v_tbfichero IN OUT t_tabla_ficheros) IS
      TYPE cur_type IS REF CURSOR;

      cur_bloque     cur_type;
      cur_b          cur_type;
      v_linea        t_linea := NEW t_linea();
      v_tlinea       VARCHAR2(4000);
      v_c            NUMBER;
      v_i            NUMBER;
      v_index        NUMBER;
      v_subt         t_linea := NEW t_linea();
      v_j            NUMBER := 1;
      v_col_count    NUMBER;
      v_desc_tab     DBMS_SQL.desc_tab;
      v_nocol        fic_formatos.nnucofo%TYPE;
      v_subtotal     t_array_number := NEW t_array_number();
      v_pos          NUMBER;
      v_nsubtotales  NUMBER;
      vparam         VARCHAR2(4000)
         := 'p_tquery = ' || p_tquery || ' p_empres = ' || p_empres || 'p_tgestor = '
            || p_tgestor || 'p_tformato = ' || p_tformato || 'p_nnunicap = ' || p_nnunicap
            || 'p_separador = ' || p_separador || 'p_subtotales = ' || p_subtotales;
      v_querycol     VARCHAR2(4000);
      vr_consulta    DBMS_SQL.varchar2a;
      v_nlongitud    NUMBER;
      v_ind          NUMBER;
      v_nparts       NUMBER;

      CURSOR get_columns IS
         SELECT t2.COLUMN_VALUE.getrootelement() NAME,
                EXTRACTVALUE(t2.COLUMN_VALUE, 'node()') VALUE
           FROM (SELECT *
                   FROM TABLE(XMLSEQUENCE(cur_bloque))) t1,
                TABLE(XMLSEQUENCE(EXTRACT(t1.COLUMN_VALUE, '/ROW/node()'))) t2;
   BEGIN
      OPEN cur_bloque FOR p_tquery;

      v_pos := INSTR(p_tquery, 'WHERE', 1, 1);

      IF v_pos <> 0 THEN
         v_querycol := p_tquery || ' AND rownum=1';
      ELSE
         v_querycol := p_tquery || ' WHERE rownum=1';
      END IF;

      --OPEN cur_b FOR v_querycol;
      --v_c := DBMS_SQL.to_cursor_number(cur_b); <-- Nueva funcionalidad en BBDD 11g, se elimina para mantener
      --compatibilidad con versiones anteriores
      v_nparts := 1;
      v_ind := 1;

      LOOP
         vr_consulta(v_ind) := SUBSTR(v_querycol, v_nparts, 32767);
         v_nparts := v_nparts + 32767;
         EXIT WHEN v_nparts > v_nlongitud;
         v_ind := v_ind + 1;
      END LOOP;

      v_c := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_c, vr_consulta, 1, v_index, FALSE, DBMS_SQL.native);
      --Hasta aquí llega la modificación por retrocompatibilidad
      DBMS_SQL.describe_columns(v_c, v_col_count, v_desc_tab);
      v_i := 1;

      BEGIN
         SELECT nnucofo
           INTO v_nocol
           FROM fic_formatos
          WHERE tformat = p_tformato
            AND tgestor = p_tgestor;
      EXCEPTION
         WHEN OTHERS THEN
            v_nocol := 1;
      END;

      IF p_subtotales IS NOT NULL
         OR TRIM(p_subtotales) <> '' THEN
         v_subt := f_split(p_subtotales, ';');
         v_nsubtotales := v_subt.LAST;
         v_subtotal.EXTEND(v_nsubtotales);
      END IF;

      FOR rec_ IN get_columns LOOP
         IF v_i <= v_col_count THEN
            v_tlinea := v_tlinea || rec_.VALUE || p_separador;

            IF p_subtotales IS NOT NULL
               OR TRIM(p_subtotales) <> '' THEN
               v_pos := INSTR(p_subtotales, v_i || ';', 1, 1);

               IF v_pos <> 0 THEN
                  BEGIN
                     FOR v_indx IN v_subt.FIRST .. v_subt.LAST LOOP
                        IF v_i || ';' = v_subt(v_indx) THEN
                           v_j := v_indx;
                        END IF;
                     END LOOP;

                     v_subtotal(v_j) := NVL(v_subtotal(v_j), 0) + TO_NUMBER(rec_.VALUE);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'pac_fun_formatos.f_transformacion', 1,
                                    'Error', SQLERRM);
                  END;
               END IF;
            END IF;
         ELSE
            v_tlinea := rec_.VALUE || p_separador;
            v_i := 1;
         END IF;

         IF v_i = v_col_count THEN
            v_tlinea := p_llenar_columnas(v_tlinea, v_nocol, p_separador);
            v_linea.EXTEND;
            v_linea(v_linea.LAST) := v_tlinea;
         END IF;

         v_i := v_i + 1;
      END LOOP;

      IF cur_b%ISOPEN THEN
         CLOSE cur_b;
      END IF;

      CLOSE cur_bloque;

      IF p_col_estaticas.COUNT <> 0 THEN
         v_tlinea := '';

         FOR v_ind IN p_col_estaticas.FIRST .. p_col_estaticas.LAST LOOP
            v_tlinea := v_tlinea || p_col_estaticas(v_ind) || p_separador;
         END LOOP;
      END IF;

      IF p_subtotales IS NOT NULL
         OR TRIM(p_subtotales) <> '' THEN
         v_j := 1;

         FOR v_index IN p_col_estaticas.LAST .. v_col_count LOOP
            v_pos := INSTR(p_subtotales, v_index || ';', 1, 1);

            IF v_pos <> 0 THEN
               v_tlinea := v_tlinea || v_subtotal(v_j) || p_separador;
               v_j := v_j + 1;
            END IF;
         END LOOP;

         v_tlinea := p_llenar_columnas(v_tlinea, v_nocol, p_separador);
         v_linea.EXTEND;
         v_linea(v_linea.LAST) := v_tlinea;
      END IF;

      IF v_linea.COUNT > 0 THEN
         v_tbfichero.EXTEND;
         v_tbfichero(v_tbfichero.LAST) := NEW ob_fichero(p_empres, p_tgestor, p_tformato,
                                                         p_nnunicap, v_linea, NULL, NULL,
                                                         NULL);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF cur_bloque%ISOPEN THEN
            CLOSE cur_bloque;
         END IF;

         IF cur_b%ISOPEN THEN
            CLOSE cur_b;
         END IF;

         p_tab_error(f_sysdate, f_user, 'pac_fic_formatos.f_transformacion :' || vparam, 1,
                     'Error', SQLERRM);
   END f_transformacion;

     /*************************************************************************
   PROCEDURE p_calcular_periodos
      Calcula el rango de fechas para el formato
      param in p_tgestor: codigo de gestor
      param in p_anio : año generacion fichero
      param in p_mes: mes generacion fichero
      param in p_dia : dia generacion fichero
      param out p_fecha_inicio: fecha inicio del formato
      param out p_fecha_fin: fecha fin del formato
      param in p_forma: forma de calcular el periodo
   *************************************************************************/
   PROCEDURE p_calcular_periodos(
      p_tgestor IN VARCHAR2,
      p_anio IN NUMBER,
      p_mes IN VARCHAR2,
      p_dia IN VARCHAR2,
      p_fecha_inicio OUT DATE,
      p_fecha_fin OUT DATE,
      p_forma IN NUMBER) IS
      v_periodicidad fic_gestores.tgestor%TYPE;
   BEGIN
      SELECT tperiod
        INTO v_periodicidad
        FROM fic_gestores
       WHERE tgestor = p_tgestor;

      IF p_forma = 1 THEN
         IF v_periodicidad = 'T' THEN
            IF p_dia IS NULL
               OR TRIM(p_dia) = ''
               OR p_dia = '0' THEN
               p_fecha_fin := LAST_DAY(TO_DATE(LPAD(p_mes, 2, '0') || '/'
                                               || LPAD(p_anio, 4, '0'),
                                               'mm/yyyy'));
               p_fecha_inicio := ADD_MONTHS(TO_DATE('01' || '/' || LPAD(p_mes, 2, '0') || '/'
                                                    || LPAD(p_anio, 4, '0'),
                                                    'dd/mm/yyyy'),
                                            -2);
            ELSE
               p_fecha_fin := LAST_DAY(TO_DATE(LPAD(p_dia, 2, '0') || '/'
                                               || LPAD(p_mes, 2, '0') || '/'
                                               || LPAD(p_anio, 4, '0'),
                                               'dd/mm/yyyy'));
               p_fecha_inicio := ADD_MONTHS(TO_DATE('01' || '/' || LPAD(p_mes, 2, '0') || '/'
                                                    || LPAD(p_anio, 4, '0'),
                                                    'dd/mm/yyyy'),
                                            -2);
            END IF;
         END IF;
      END IF;
   END p_calcular_periodos;
END pac_fic_formatos;

/

  GRANT EXECUTE ON "AXIS"."PAC_FIC_FORMATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FIC_FORMATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FIC_FORMATOS" TO "PROGRAMADORESCSI";
