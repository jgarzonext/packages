--------------------------------------------------------
--  DDL for Package PAC_MD_GESTOR_FICHEROS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_GESTOR_FICHEROS" IS
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   e_error_controlat EXCEPTION;

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
   FUNCTION f_generar_ficheros(
      ppempresa IN NUMBER,
      pptgestor IN NUMBER,
      pptformato IN VARCHAR2,
      ppnanio IN NUMBER,
      ppnmes IN NUMBER,
      ppndia IN NUMBER,
      sproces OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_gestor_ficheros;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTOR_FICHEROS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTOR_FICHEROS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTOR_FICHEROS" TO "PROGRAMADORESCSI";
