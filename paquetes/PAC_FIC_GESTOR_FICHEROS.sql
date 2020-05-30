--------------------------------------------------------
--  DDL for Package PAC_FIC_GESTOR_FICHEROS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_FIC_GESTOR_FICHEROS" IS
   /****************************************************************************************
   FUNCTION f_aplica_formato
      Aplica formateo a una columna de acuerdo a su tipo de dato y a su configuracion.
      param in p_tcadena     : cadena con el dato de la columna a la que se aplica formato
               p_ttip_dato   : tipo de dato de la columna a la que se aplica formato
               p_nlongitud   : longitud de la columna
               p_tformato    : determina el formato a aplicar(Ej: DDMMYYYY para fechas)
               p_tcar_relleno: caracter con el cual se rellena la cadena hasta
                               completa la longitud definida.
               p_ttip_justifi: indica hacia en que extremo de la cadena se debe
                               aplicar el caracter de relleno.
      return                 : retorna la cadena con el formato aplicado y completada con el
                               caracter de relleno indicado, con la justificacion indicada
   *******************************************************************************************/
   FUNCTION f_aplica_formato(
      p_tcadena VARCHAR2,
      p_ttip_dato fic_col_ficheros.ttipdat%TYPE,
      p_nlongitud fic_col_ficheros.nlongit%TYPE,
      p_tformato fic_col_ficheros.tforcol%TYPE,
      p_tcar_relleno fic_col_ficheros.tcarrel%TYPE,
      p_ttip_justifi fic_col_ficheros.ttipjus%TYPE)
      RETURN VARCHAR2;

   /*************************************************************************
      PROCEDURE p_eval_excluidos
      Realiza el llamado a la funcion f_eval_excluidos para determinar si
      se incrementa o no el contador de registris
      param in p_tprograma     : programa que determina si se excluye o no el
                                 registro del fichero final.
               p_treg_original : cadena con el registro completo, sin haberle
                                 aplicado formateo
      return                   :
   *************************************************************************/
   PROCEDURE p_eval_excluidos(p_tprograma VARCHAR2, p_treg_original VARCHAR2);

   /*************************************************************************
      FUNCTION f_eval_excluidos
      Evalua si de acuerdo a el resultado de un procedimiento se debe o no
      excluir ese registro en la escritura del fichero final.
      param in p_tprograma     : programa que determina si se excluye o no el
                                 registro del fichero final.
               p_treg_original : cadena con el registro completo, sin haberle
                                 aplicado formateo
      return                   : retorna la cadena con el formato aplicado y
                                 completada con el caracter de relleno indicado,
                                 con la justificacion indicada
   *************************************************************************/
   FUNCTION f_eval_excluidos(p_tprograma VARCHAR2, p_treg_original VARCHAR2)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_tokenizer
      Extrae el valor de una cadena, realizando la busqueda por una clave
      o subcaena y con base en unos separadores especificados
      param in p_tcadena     : Cadena con los datos del registro completo,
                               separando cada combinacion de clave valor
                               con un separador y la clave con su valor con
                               otro separador.
               p_tsubcadena  : clave que va a ser buscada dentro de la cadena
                               general para extraer el valor.
               p_tseparador  : Separador utilizado para identificar cada una de
                               las diferentes parejas de clave valor.
               p_tseparador2 : Separador utilizado para separar la clave del valor
                               como tal.
      return                 : retorna una cadena con el valor obtenido de acuerdo
                               a la clave o subcadena pasada.
   *************************************************************************/
   FUNCTION f_tokenizer(
      p_tcadena VARCHAR2,
      p_tsubcadena VARCHAR2,
      p_tseparador VARCHAR2,
      p_tseparador2 VARCHAR2)
      RETURN VARCHAR2;

   /*************************************************************************
      PROCEDURE p_procesa_campos
      Permite procesar cada uno de los campos configurados en la estructura
      del fichero final.
      param in p_tgestor       : Gestor o estructura base que define el fichero
                                 de salida.
               p_ntip_registro : tipo de registro o seccion del fichero final
                                 que tiene su propia configuracion de columnas.
      return                   :
   *************************************************************************/
   PROCEDURE p_procesa_campos(
      p_tgestor fic_gestores.tgestor%TYPE,
      p_ntip_registro fic_tip_registros.ntipreg%TYPE);

   /*************************************************************************
      PROCEDURE p_procesa_tip_registros
      Permite procesar cada tipo de registro o seccion del fichero con el
      proposito de obtener las columnas de ese tipo de registro y de acuerdo
      a la configuracion de cada una de ellas procesarlas.
      param in p_vr_registros : registro completo de la tabla fic_tip_registros
      return                   :
   *************************************************************************/
   PROCEDURE p_procesa_tip_registros(p_vr_registros fic_tip_registros%ROWTYPE);

   /*************************************************************************
      PROCEDURE p_crea_registros
      Permite realizar el llamado a cada uno de los tipos de registro.
      param in p_tgestor : gestor o estructura base que define el fichero de
                           salida y del cual se obtendran los tipos de registros
                           que deberan ser procesados.
      return             :
   *************************************************************************/
   PROCEDURE p_crea_registros(p_tgestor fic_gestores.tgestor%TYPE);

   /*************************************************************************
      FUNTION f_escribe_fichero
      Permite realizar la escritura en el fichero de las lineas generadas para
      cada tipo de registro.
      param in :
      return   : Devuelve el path y nombre del fichero generado
   *************************************************************************/
   FUNCTION f_escribe_fichero
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_proceso
      Funcion principal desde donde se lleva el control de flujo del
      proceso.
      param in p_nempresa  : empresa para la cual se va a generar el fichero.
               p_tgestor   : gestor o estructura base que define el fichero
                             final de salida.
               p_tformatos : formato o formatos que pertenezcan al gestor y
                             de los cuales se incluira su informacion en el
                             fichero final que se genere.
      return   :   Devuelve el nombre completo del fichero generado
   *************************************************************************/
   FUNCTION f_proceso(
      p_nempresa fic_gestores.cempres%TYPE,
      p_tgestor fic_gestores.tgestor%TYPE,
      p_tformatos VARCHAR2,
      p_nanio NUMBER,
      p_nmes NUMBER,
      p_nsem_dia NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      PROCEDURE p_proceso
      Procedimiento para ser llamado desde la capa media, que es ejecutado
      por el job
      proceso.
      param in p_nempresa  : empresa para la cual se va a generar el fichero.
               p_tgestor   : gestor o estructura base que define el fichero
                             final de salida.
               p_tformatos : formato o formatos que pertenezcan al gestor y
                             de los cuales se incluira su informacion en el
                             fichero final que se genere.
      return   :
   *************************************************************************/
   PROCEDURE p_proceso_job(
      p_nempresa fic_gestores.cempres%TYPE,
      p_tgestor fic_gestores.tgestor%TYPE,
      p_tformatos VARCHAR2,
      p_nanio NUMBER,
      p_nmes NUMBER,
      p_nsem_dia NUMBER,
      p_tuser fic_procesos.cusuari%TYPE,
      p_proceso fic_procesos.sproces%TYPE);
END pac_fic_gestor_ficheros;

/

  GRANT EXECUTE ON "AXIS"."PAC_FIC_GESTOR_FICHEROS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FIC_GESTOR_FICHEROS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FIC_GESTOR_FICHEROS" TO "PROGRAMADORESCSI";
