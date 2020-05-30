--------------------------------------------------------
--  DDL for Package PAC_CARGA_PREGUNTAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CARGA_PREGUNTAB" IS
/*******************************************************************************
   NOMBRE:       pac_carga_preguntab
   PROPÓSITO: Funciones para la carga de preguntas de tipo tabla

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ----------  ------------------------------------
   1.0        13/2/2015   AMC                1. Creación del package.
*******************************************************************************/
   k_empresaaxis CONSTANT empresas.cempres%TYPE := f_parinstalacion_n('EMPRESADEF');
   k_idiomaaaxis CONSTANT per_detper.cidioma%TYPE
              := pac_parametros.f_parempresa_n(f_parinstalacion_n('EMPRESADEF'), 'IDIOMA_DEF');
   k_paisdefaxis CONSTANT provincias.cpais%TYPE := f_parinstalacion_n('PAIS_DEF');   -- ESPAÑA
   k_para_carga   cfg_files.cpara_error%TYPE;

/***************************************************************************
        procedimiento que ejecuta una carga
        param in p_nombre   : Nombre fichero
        param in  out psproces   : Número proceso (informado para recargar proceso).
        retorna 0 si ha ido bien, 1 en casos contrario
     **************************************************************************/
   FUNCTION f_ejecutar_carga_preguntab(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_cpregun IN NUMBER,
      p_nmovimi IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_ejecutar_carga_fichero(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_modi_tabla(p_nombre VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_ejecutar_carga(
      psproces IN NUMBER,
      p_cproces IN NUMBER,
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_cpregun IN NUMBER,
      p_nmovimi IN NUMBER)
      RETURN NUMBER;

   PROCEDURE p_genera_logs(
      p_tabobj IN VARCHAR2,
      p_tabtra IN NUMBER,
      p_tabdes IN VARCHAR2,
      p_taberr IN VARCHAR2,
      p_propro IN NUMBER,
      p_protxt IN VARCHAR2);

   FUNCTION bloquea_tablas
      RETURN NUMBER;

   FUNCTION f_borrar_carga(
      psseguro IN NUMBER,
      pcpregun IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pcnivel IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_validar_carga(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pcpregun IN NUMBER,
      pnmovimi IN NUMBER,
      pmensaje IN OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_cargas_validadas(
      psseguro IN NUMBER,
      pemitir IN OUT NUMBER,
      pmensaje IN OUT VARCHAR2)
      RETURN NUMBER;
END pac_carga_preguntab;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGA_PREGUNTAB" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGA_PREGUNTAB" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGA_PREGUNTAB" TO "PROGRAMADORESCSI";
