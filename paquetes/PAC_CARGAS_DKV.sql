--------------------------------------------------------
--  DDL for Package PAC_CARGAS_DKV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CARGAS_DKV" IS
/******************************************************************************
   NOMBRE:      PAC_CARGAS_DKV
   PROPÓSITO: Funciones para la gestión de la carga de procesos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/06/2010   FAL              1. Creación del package.
   2.0        15/10/2010   DRA              2. 0016130: CRT - Error informando el codigo de proceso en carga
   3.0        18/10/2010   FAL              3. 0016324: CRT - Configuracion de las cargas
   4.0        24/01/2010   FAL              4. 0017282: CRT002 - DKV cargar un asegurado genérico
******************************************************************************/
   k_empresaaxis CONSTANT empresas.cempres%TYPE := f_parinstalacion_n('EMPRESADEF');
   k_idiomaaaxis CONSTANT per_detper.cidioma%TYPE
              := pac_parametros.f_parempresa_n(f_parinstalacion_n('EMPRESADEF'), 'IDIOMA_DEF');
   k_paisdefaxis CONSTANT provincias.cpais%TYPE := f_parinstalacion_n('PAIS_DEF');   -- ESPAÑA
   k_motivoanula CONSTANT codimotmov.cmotmov%TYPE := 324;   -- Anul·lació inmediata
   k_motivomodif CONSTANT codimotmov.cmotmov%TYPE := 670;   -- Motiu múltiple (SR)
   k_agentenoban CONSTANT agentes.cagente%TYPE := 9999;   -- Agente para los que no son del banco 3081
   k_agentedefec CONSTANT agentes.cagente%TYPE
                        := pac_redcomercial.f_buscatipage(f_parinstalacion_n('EMPRESADEF'), 0);   -- Agente por defecto (si no existe redcomercial).
   -- Bug 0016324. FAL. 18/10/2010
   k_para_carga   cfg_files.cpara_error%TYPE;
   -- Fi Bug 0016324
   -- Bug 0017282. FAL. 18/10/2010
   k_aseg_gen_sin_detallar CONSTANT per_personas.sperson%TYPE := 79999;

   -- Fi Bug 0017282

   /*************************************************************************
       procedimiento que ejecuta una carga
       param in p_nombre   : Nombre fichero
       param in p_path   : Nuombre path
       param in  out psproces   : Número proceso (informado para recargar proceso).
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_ejecutar_carga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,   -- BUG16130:DRA:15/10/2010
      psproces IN OUT NUMBER)
      RETURN NUMBER;

/*************************************************************************
       procedimiento que ejecuta una carga RECIBOS
       param in p_nombre   : Nombre fichero
       param in p_path   : Nuombre path
       param in  out psproces   : Número proceso (informado para recargar proceso).
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_rec_ejecutarcarga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,   -- BUG16130:DRA:15/10/2010
      psproces IN OUT NUMBER)
      RETURN NUMBER;
END pac_cargas_dkv;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_DKV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_DKV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_DKV" TO "PROGRAMADORESCSI";
