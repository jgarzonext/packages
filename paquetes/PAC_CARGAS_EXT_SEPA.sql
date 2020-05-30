--------------------------------------------------------
--  DDL for Package PAC_CARGAS_EXT_SEPA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CARGAS_EXT_SEPA" IS
   /******************************************************************************
      NOMBRE:      PAC_CARGAS_EXT_RSA
      PROPÓSITO: Funciones para la gestión de la carga de procesos para TABLAS EXTERNAS
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        03/11/2011   AFM              1. Creación del package.

   ******************************************************************************/
   k_empresaaxis CONSTANT empresas.cempres%TYPE := f_parinstalacion_n('EMPRESADEF');
   k_idiomaaxis CONSTANT per_detper.cidioma%TYPE
              := pac_parametros.f_parempresa_n(f_parinstalacion_n('EMPRESADEF'), 'IDIOMA_DEF');
   k_paisdefaxis CONSTANT provincias.cpais%TYPE := f_parinstalacion_n('PAIS_DEF');
   k_para_carga   cfg_files.cpara_error%TYPE;
   k_tab_external_ext CONSTANT VARCHAR2(4) := '_EXT';
   k_tab_int_sepa_respcobros CONSTANT VARCHAR2(30) := 'INT_SEPA_RESPCOBROS';

   /*************************************************************************
          procedimiento que ejecuta una carga
          param in p_nombre   : Nombre fichero
          param in  out psproces   : Número proceso (informado para recargar proceso).
          retorna 0 si ha ido bien, 1 en casos contrario
      *************************************************************************/
   FUNCTION f_ejecutar_carga_ext(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      p_sproces IN OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
          Insertar en la tabla DEVBANORDENANTES
          param in p_seqdev   : Número proceso
          param in pnnumnif   : Número de identificación
          param in ptsufijo   : Sufijo
          param in pfremesa   : Fecha remesa
          param in pccobban   : Cobrador bancario
          param in ptordnom   : Nombre ordenante
          param in pnordreg   : Orden registro
          param in ptotalr    : Importe total del recibo ITOTALR
          param in psproces   : SPROCES
          retorna 0 si ha ido bien, 1 en caso contrario
   *************************************************************************/
   FUNCTION f_insertar_devbanordenantes(
      p_seqdev IN NUMBER,
      pnnumnif IN VARCHAR2,
      ptsufijo IN VARCHAR2,
      pfremesa IN DATE,
      pccobban IN NUMBER,
      ptordnom IN VARCHAR2,
      pnordreg IN NUMBER,
      ptotalr IN NUMBER,
      psproces IN NUMBER,
      pfichero IN VARCHAR2)
      RETURN NUMBER;
END pac_cargas_ext_sepa;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_EXT_SEPA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_EXT_SEPA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_EXT_SEPA" TO "PROGRAMADORESCSI";
