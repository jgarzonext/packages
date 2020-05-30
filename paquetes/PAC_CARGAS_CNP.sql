--------------------------------------------------------
--  DDL for Package PAC_CARGAS_CNP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CARGAS_CNP" IS
/******************************************************************************
   NOMBRE:    PAC_CARGAS_CNP
   PROPÓSITO: Funciones para la gestión de la carga de procesos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        22/07/2010   JMF              1. 0015490: CRT002 - Carga de polizas,recibos, siniestros CNP
   2.0        15/10/2010   DRA              2. 0016130: CRT - Error informando el codigo de proceso en carga
   3.0        18/10/2010   FAL              3. 0016324: CRT - Configuracion de las cargas
******************************************************************************/
/*
   vg_nempresaaxis CONSTANT empresas.cempres%TYPE
      := pac_contexto.f_contextovalorparametro(f_parinstalacion_t('CONTEXT_USER'),
                                               'IAX_EMPRESA');
*/
   vg_nempresaaxis CONSTANT empresas.cempres%TYPE := f_parinstalacion_n('EMPRESADEF');
   vg_nidiomaaxis CONSTANT per_detper.cidioma%TYPE
              := pac_parametros.f_parempresa_n(f_parinstalacion_n('EMPRESADEF'), 'IDIOMA_DEF');
   -- Bug 0016324. FAL. 18/10/2010
   k_para_carga   cfg_files.cpara_error%TYPE;
   k_busca_host   cfg_files.cbusca_host%TYPE;
   -- Fi Bug 0016324
   -- Bug 0016696. FAL. 18/11/2010
   k_motivomodif CONSTANT codimotmov.cmotmov%TYPE := 670;   -- Motiu múltiple (SR)
   k_motivoanula CONSTANT codimotmov.cmotmov%TYPE := 324;   -- Anul·lació inmediata
   k_agente CONSTANT agentes.cagente%TYPE
                        := pac_redcomercial.f_buscatipage(f_parinstalacion_n('EMPRESADEF'), 0);

   -- Fi Bug 0016696

   /*************************************************************************
       procedimiento que ejecuta una carga Planes de Pensiones
       param in p_tnombre   : Nombre fichero
       param in p_tpath   : Nuombre path
       param in  out p_ssproces   : Número proceso (informado para recargar proceso).
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_ejecutarcarga_pp(
      p_tnombre IN VARCHAR2,
      p_tpath IN VARCHAR2,
      p_cproces IN NUMBER,   -- BUG16130:DRA:15/10/2010
      p_ssproces IN OUT NUMBER)
      RETURN NUMBER;

/*************************************************************************
       procedimiento que ejecuta una carga Unit Linked
       param in p_nombre   : Nombre fichero
       param in p_path   : Nuombre path
       param in  out psproces   : Número proceso (informado para recargar proceso).
       retorna 0 si ha ido bien, 1 en casos contrario
   ............
   en un futuro
   ............
   FUNCTION f_ejecutarcarga_UL (p_nombre IN VARCHAR2, p_path IN VARCHAR2, psproces IN OUT NUMBER)
      RETURN NUMBER;
   *************************************************************************/
   PROCEDURE p_ejecutar_carga(p_nombre IN VARCHAR2, p_path IN VARCHAR2, p_cproces IN NUMBER);

   -- Bug 0015490. FAL. 15/02/2011
   /*************************************************************************
       procedimiento que ejecuta una carga mediante un job
       param in  out psproces   : Número proceso (informado para recargar proceso).
       retorna 9901606 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_ejecutar_carga_job(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;
-- Fi Bug 0015490
END pac_cargas_cnp;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_CNP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_CNP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_CNP" TO "PROGRAMADORESCSI";
