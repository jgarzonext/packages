--------------------------------------------------------
--  DDL for Package PAC_CARGAS_MSV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CARGAS_MSV" IS
/******************************************************************************
   NOMBRE:      PAC_CARGAS_MSV
   PROPÓSITO: Funciones para la gestión de la carga de procesos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        17/09/2013   FAL              1. Creación del package.
******************************************************************************/


   k_empresaaxis CONSTANT empresas.cempres%TYPE := f_parinstalacion_n('EMPRESADEF');
   k_para_carga   cfg_files.cpara_error%TYPE;
   k_idiomaaaxis CONSTANT per_detper.cidioma%TYPE := pac_parametros.f_parempresa_n(f_parinstalacion_n('EMPRESADEF'), 'IDIOMA_DEF');

   /*************************************************************************
      procedimiento que ejecuta una carga del censo
      param in p_nombre : Nombre fichero
      param in p_path : Nuombre path
      param in out psproces : Número proceso (informado para recargar proceso).
      retorna 0 si ha ido bien, 1 en casos contrario
  *************************************************************************/
    FUNCTION f_censo_ejecutarcarga(
        p_nombre IN VARCHAR2,
        p_path IN VARCHAR2,
        p_cproces IN NUMBER,
        psproces IN OUT NUMBER)
        RETURN NUMBER;

   /*************************************************************************
      Procedimiento que ejecuta una carga
      param in p_nombre : Nombre fichero
      param out psproces : Número proceso
      retorna 0 si ha ido bien, 1 en casos contrario
  *************************************************************************/ 
    FUNCTION f_censo_ejecutarcargafichero (
        p_nombre IN VARCHAR2,
        p_path IN VARCHAR2,
        p_cproces IN NUMBER,
        psproces   OUT NUMBER)
        RETURN NUMBER;
      
    FUNCTION f_censo_ejecutarcargaproceso (
        p_ssproces IN NUMBER) 
        RETURN NUMBER;       

END pac_cargas_msv; 

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_MSV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_MSV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_MSV" TO "PROGRAMADORESCSI";
