--------------------------------------------------------
--  DDL for Package PAC_CARGAS_FIN_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CARGAS_FIN_CONF" AS
   /*******************************************************************************
   NOMBRE:       PAC_CARGAS_CONF
   PROP¿SITO: Fichero de carga
   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ----------  ------------------------------------
   1.0        08/06/2017   ERH         1. Creaci¿n del package.
   ******************************************************************************/

   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;
   e_rename_error EXCEPTION;
   e_format_error EXCEPTION;
   e_errdatos     EXCEPTION;

   k_empresaaxis CONSTANT empresas.cempres%TYPE := NVL(pac_md_common.f_get_cxtempresa,
                                                       f_parinstalacion_n('EMPRESADEF'));

   k_idiomaaaxis CONSTANT per_detper.cidioma%TYPE := pac_parametros.f_parempresa_n(f_parinstalacion_n('EMPRESADEF'),
                                                                                   'IDIOMA_DEF');

   k_paisdefaxis CONSTANT provincias.cpais%TYPE := f_parinstalacion_n('PAIS_DEF');

   k_para_carga cfg_files.cpara_error%TYPE;

   kidiomaaaxis NUMBER := pac_md_common.f_get_cxtidioma;
   kempresa     NUMBER := pac_md_common.f_get_cxtempresa;

  /*************************************************************************
   FUNCTION f_eje_carga_cifras_sectoriales
   *************************************************************************/
   FUNCTION f_eje_carga_cifras_sectoriales(p_nombre  IN VARCHAR2,
                                           p_path    IN VARCHAR2,
                                           p_cproces IN NUMBER,
                                           psproces  IN OUT NUMBER) RETURN NUMBER;

  /*************************************************************************
   FUNCTION f_eje_carga_fichero_cifras_sec
   *************************************************************************/
   FUNCTION f_eje_carga_fichero_cifras_sec(p_nombre  IN VARCHAR2,
                                           p_path    IN VARCHAR2,
                                           p_cproces IN NUMBER,
                                           psproces  OUT NUMBER) RETURN NUMBER;

  /*************************************************************************
   FUNCTION f_eje_carga_pais_riesgo
   *************************************************************************/
   FUNCTION f_eje_carga_pais_riesgo(p_nombre  IN VARCHAR2,
                                    p_path    IN VARCHAR2,
                                    p_cproces IN NUMBER,
                                    psproces  IN OUT NUMBER) RETURN NUMBER;

  /*************************************************************************
   FUNCTION f_eje_carga_fichero_pais_riesg
   *************************************************************************/
   FUNCTION f_eje_carga_fichero_pais_riesg(p_nombre  IN VARCHAR2,
                                           p_path    IN VARCHAR2,
                                           p_cproces IN NUMBER,
                                           psproces  OUT NUMBER) RETURN NUMBER;

  /*************************************************************************
   FUNCTION f_pais_r_ejecutarcarga
   *************************************************************************/
   FUNCTION f_pais_r_ejecutarcarga(p_nombre  IN VARCHAR2,
                                   p_path    IN VARCHAR2,
                                   p_cproces IN NUMBER,
                                   psproces  IN OUT NUMBER) RETURN NUMBER;


  /*************************************************************************
   FUNCTION f_pais_r_ejecutargafichero
   *************************************************************************/
   FUNCTION f_pais_r_ejecutargafichero(p_nombre  IN VARCHAR2,
                                       p_path    IN VARCHAR2,
                                       p_cproces IN NUMBER,
                                       psproces  OUT NUMBER) RETURN NUMBER;

END pac_cargas_fin_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_FIN_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_FIN_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_FIN_CONF" TO "PROGRAMADORESCSI";
