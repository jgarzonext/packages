--------------------------------------------------------
--  DDL for Package PAC_CARGAS_FARAGGI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CARGAS_FARAGGI" IS
/******************************************************************************
 NOMBRE: AXIS_D51.PAC_CARGAS_FARAGGI
   PROPÓSITO: Funciones para la gestión de la carga de procesos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/10/2014   NSS              1. Creación del package.
******************************************************************************/
   k_empresaaxis CONSTANT empresas.cempres%TYPE := f_parinstalacion_n('EMPRESADEF');
   k_idiomaaaxis CONSTANT per_detper.cidioma%TYPE
              := pac_parametros.f_parempresa_n(f_parinstalacion_n('EMPRESADEF'), 'IDIOMA_DEF');
   k_paisdefaxis CONSTANT provincias.cpais%TYPE := f_parinstalacion_n('PAIS_DEF');   -- ESPAÑA
   k_motivoanula CONSTANT codimotmov.cmotmov%TYPE := 324;   -- Anul·lació inmediata
   k_motivomodif CONSTANT codimotmov.cmotmov%TYPE := 670;   -- Motiu múltiple (SR)
   k_agente CONSTANT agentes.cagente%TYPE
                        := pac_redcomercial.f_buscatipage(f_parinstalacion_n('EMPRESADEF'), 0);
   -- Bug 0016324. FAL. 18/10/2010
   k_para_carga   cfg_files.cpara_error%TYPE;

   -- Fi Bug 0016324

   /*************************************************************************
       procedimiento que ejecuta una carga SINIESTROS
       param in p_nombre   : Nombre fichero
       param in p_path   : Nuombre path
       param in  out psproces   : Número proceso (informado para recargar proceso).
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_sin_ejecutarcarga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,   -- BUG16130:DRA:15/10/2010
      psproces IN OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_sin_ejecutarcargaproceso(psproces IN NUMBER, p_cproces IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_sin_validarsiniestro(
      faraggi IN OUT carga_cab_faraggi%ROWTYPE,
      pterror IN OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_altasiniestro_mig(
      faraggi IN OUT carga_cab_faraggi%ROWTYPE,
      pterror IN OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_buscavalor(p_cod IN VARCHAR2, p_emp IN VARCHAR2)
      RETURN VARCHAR2;
END pac_cargas_faraggi;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_FARAGGI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_FARAGGI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_FARAGGI" TO "PROGRAMADORESCSI";
