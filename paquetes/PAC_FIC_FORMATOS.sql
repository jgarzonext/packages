--------------------------------------------------------
--  DDL for Package PAC_FIC_FORMATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_FIC_FORMATOS" AS
/******************************************************************************
   NOMBRE:      PAC_FIC_FORMATOS
   PROPÓSITO:   Funciones para la gestion de informes

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        08/08/2013   DEV               1. Creación del package.
   1.1        20/08/2013   JMG               2. Modificacion del paquete.
******************************************************************************/
   TYPE paramcol IS RECORD(
      ccoform        fic_columna_formatos.ccoform%TYPE,
      ttipdat        fic_columna_formatos.ttipdat%TYPE,
      tformca        fic_columna_formatos.tformca%TYPE,
      ntamano        fic_columna_formatos.ntamano%TYPE,
      tobliga        fic_columna_formatos.tobliga%TYPE
   );

   TYPE t_paramcol IS TABLE OF paramcol;

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
      v_dia IN VARCHAR2);

   /*************************************************************************
   PROCEDURE p_escribir_fichero
      Escribe filas en el archivo CSV
      param in out v_file: archivo de carga
      param in v_linea  : fila a guardar
   *************************************************************************/
   PROCEDURE p_escribir_fichero(p_file IN OUT UTL_FILE.file_type, p_linea IN VARCHAR2);

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
      v_nocol IN NUMBER);

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
      v_nocol IN NUMBER);

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
      v_dia IN VARCHAR2);

   /*************************************************************************
   FUNCTION p_llenar_columnas
      Llena columnas vacias
      param in v_string : linea del archivo separada por el delimitador
      param in v_nocolumnas : numero de columnas del formato
      param in v_separador : delimitador de columnas
   *************************************************************************/
   FUNCTION p_llenar_columnas(v_string VARCHAR2, v_nocolumnas NUMBER, v_separador VARCHAR2)
      RETURN VARCHAR2;

   /*************************************************************************
   FUNCTION f_split
      divide un string segun un deliminator en un array
      param in v_string : String a dividir
      param in v_delim: Delimitador
      RETURN t_array : Array con los string inviduales separados por el delimitador
   *************************************************************************/
   FUNCTION f_split(v_string VARCHAR2, v_delim VARCHAR2)
      RETURN t_linea;

   /*************************************************************************
   FUNCTION f_validar_columnas
      valida numero de columnas de una fila
      param in v_string : String a dividir
      param in v_delim: Delimitador
      RETURN BOOLEAN: retorna true cuando la fila esta correcta
   *************************************************************************/
   FUNCTION f_validar_columnas(p_tstring VARCHAR2, p_tdelim VARCHAR2, p_ncolumnas NUMBER)
      RETURN BOOLEAN;

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
      p_sproces IN NUMBER);

   /*************************************************************************
    FUNCTION f_rowconcat
      Función para poder seleccionar el texto de varias filas en una única columna
      RETURN t_array : Array con los string inviduales separados por el delimitador
   *************************************************************************/
   FUNCTION f_rowconcat(p_string VARCHAR2, p_delim VARCHAR2)
      RETURN VARCHAR2;

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
      RETURN t_tabla_ficheros;

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
      p_dia IN VARCHAR2);

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
      RETURN NUMBER;

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
      RETURN NUMBER;

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
      v_tbfichero IN OUT t_tabla_ficheros);

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
      p_forma IN NUMBER);
END pac_fic_formatos;

/

  GRANT EXECUTE ON "AXIS"."PAC_FIC_FORMATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FIC_FORMATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FIC_FORMATOS" TO "PROGRAMADORESCSI";
