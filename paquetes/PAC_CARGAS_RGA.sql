--------------------------------------------------------
--  DDL for Package PAC_CARGAS_RGA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CARGAS_RGA" IS
/******************************************************************************
   NOMBRE:      PAC_CARGAS_RGA
   PROPÓSITO: Funciones para la gestión de la carga de procesos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        23/07/2010   ICV              1. Creación del package.
   2.0        15/10/2010   DRA              2. 0016130: CRT - Error informando el codigo de proceso en carga
   3.0        18/10/2010   FAL              3. 0016324: CRT - Configuracion de las cargas
******************************************************************************/
   k_empresaaxis CONSTANT empresas.cempres%TYPE := f_parinstalacion_n('EMPRESADEF');
   k_idiomaaaxis CONSTANT per_detper.cidioma%TYPE
              := pac_parametros.f_parempresa_n(f_parinstalacion_n('EMPRESADEF'), 'IDIOMA_DEF');
   k_paisdefaxis CONSTANT provincias.cpais%TYPE := f_parinstalacion_n('PAIS_DEF');   -- ESPAÑA
   k_motivoanula CONSTANT codimotmov.cmotmov%TYPE := 324;   -- Anul·lació inmediata
   k_motivomodif CONSTANT codimotmov.cmotmov%TYPE := 670;   -- Motiu múltiple (SR)
   -- Bug 0016324. FAL. 18/10/2010
   k_para_carga   cfg_files.cpara_error%TYPE;
   k_busca_host   cfg_files.cbusca_host%TYPE;
   k_agente CONSTANT agentes.cagente%TYPE
                        := pac_redcomercial.f_buscatipage(f_parinstalacion_n('EMPRESADEF'), 0);

   -- Fi Bug 0016324

   /*************************************************************************
       procedimiento que ejecuta una carga
       param in  out psproces   : Número proceso (informado para recargar proceso).
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_ejecutar_carga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,   -- BUG16130:DRA:15/10/2010
      psproces IN OUT NUMBER)
      RETURN NUMBER;

   PROCEDURE p_ejecutar_carga(p_nombre IN VARCHAR2, p_path IN VARCHAR2, p_cproces IN NUMBER);

   -- Bug 0016324. FAL. 18/10/2010
   /*************************************************************************
       procedimiento que ejecuta una carga mediante un job
       param in  out psproces   : Número proceso (informado para recargar proceso).
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_ejecutar_carga_job(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;
-- Fi Bug 0016324
END pac_cargas_rga;
 

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_RGA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_RGA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_RGA" TO "PROGRAMADORESCSI";
