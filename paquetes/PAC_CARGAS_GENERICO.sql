--------------------------------------------------------
--  DDL for Package PAC_CARGAS_GENERICO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CARGAS_GENERICO" IS
   /******************************************************************************
      NOMBRE:      PAC_CARGAS_GENERICO
      PROP¿SITO: Funciones para la gesti¿n de la carga de procesos
      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  ---------------  ------------------------------------
      1.0        31/08/2012   JLB              1. Creaci¿n del package.
	  2.0		 03/05/2019	  Swapnil 		   2. Cambios de IAXIS-3650 
   ******************************************************************************/

   /*************************************************************************
          procedimiento que ejecuta una carga de p¿lizas
       param in  out psproces   : N¿mero proceso (informado para recargar proceso).
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_pol_ejecutar_carga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
        Procedimiento que ejecuta una carga de recibos
        param in  out psproces   : N¿mero proceso (informado para recargar proceso).
        retorna 0 si ha ido bien, 1 en casos contrario
    *************************************************************************/
   FUNCTION f_rec_ejecutar_carga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

/*************************************************************************
        Procedimiento que ejecuta una carga de siniestros
        param in  out psproces   : N¿mero proceso (informado para recargar proceso).
        retorna 0 si ha ido bien, 1 en casos contrario
    *************************************************************************/
   FUNCTION f_sin_ejecutar_carga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

/*************************************************************************
        Procedimiento que ejecuta una carga de personas
        param in  out psproces   : N¿mero proceso (informado para recargar proceso).
        retorna 0 si ha ido bien, 1 en casos contrario
*************************************************************************/
   FUNCTION f_per_ejecutar_carga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;


/*************************************************************************
       Procedimiento que ejecuta una carga de polizas mediante un job
       param in  out psproces   : N¿mero proceso (informado para recargar proceso).
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_pol_ejecutar_carga_job(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;

/*************************************************************************
       Procedimiento que ejecuta una carga de recibos mediante un job
       param in  out psproces   : N¿mero proceso (informado para recargar proceso).
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_rec_ejecutar_carga_job(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;


/*************************************************************************
       Procedimiento que ejecuta una carga de siniestros mediante un job
       param in  out psproces   : N¿mero proceso (informado para recargar proceso).
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_sin_ejecutar_carga_job(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;


/*************************************************************************
       Procedimiento que ejecuta una carga de personas mediante un job
       param in  out psproces   : N¿mero proceso (informado para recargar proceso).
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_per_ejecutar_carga_job(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;

/*************************************************************************
       Procedimiento que ejecuta una carga de profesionales mediante un job
       param in  out psproces   : N¿mero proceso (informado para recargar proceso).
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_prof_ejecutar_carga_job(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;
/*************************************************************************
        Procedimiento que ejecuta una carga de profesionales
        param in  out psproces   : N¿mero proceso (informado para recargar proceso).
        retorna 0 si ha ido bien, 1 en casos contrario
*************************************************************************/
   FUNCTION f_prof_ejecutar_carga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

/*************************************************************************
        Procedimiento que ejecuta una carga pagos resevas agencias
        param in  out psproces   : N¿mero proceso (informado para recargar proceso).
        retorna 0 si ha ido bien, 1 en casos contrario
*************************************************************************/
 FUNCTION f_reser_ejecutar_carga_proceso(p_ssproces IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
        Procedimiento que ejecuta una carga pagos resevas agencias       param in  out psproces   : N¿mero proceso (informado para recargar proceso).
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_reserva_ejecutar_carga_job(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;
/*************************************************************************
        Procedimiento que ejecuta una carga pagos resevas agencias        param in  out psproces   : N¿mero proceso (informado para recargar proceso).
        retorna 0 si ha ido bien, 1 en casos contrario
*************************************************************************/
   FUNCTION f_reserva_ejecutar_carga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
	  
/* Cambios de IAXIS-3650 :start */   

  FUNCTION F_MODI_DATOS_INFORME_EXT(P_NOMBRE VARCHAR2, P_PATH IN VARCHAR2)
  RETURN NUMBER;
     
  function P_TRASP_DATOS_INFORME(PDESERROR OUT VARCHAR2, PSPROCES IN NUMBER) 
  RETURN NUMBER;
          
  FUNCTION F_CARGA_PROCESO_INFORME(PRUTA IN VARCHAR2,
                                   PSPROCES IN NUMBER)
  RETURN NUMBER;  
       
  FUNCTION F_CARGA_INFORME(P_NOMBRE  IN VARCHAR2,
                           P_PATH    IN VARCHAR2,
                           P_CPROCES IN NUMBER,
                           PSPROCES  IN OUT NUMBER)
  RETURN NUMBER;  
  
  FUNCTION F_EJECUTAR_CARGA_INFORME(P_NOMBRE  IN VARCHAR2,
                                    P_PATH    IN VARCHAR2,
                                    P_CPROCES IN NUMBER,
                                    PSPROCES  IN OUT NUMBER)
  RETURN NUMBER;
  
/* Cambios de IAXIS-3650 :end */ 
--Inico IAXIS 4184 07/06/2019 MOS Incluir Cambios Cargue Masivo para pagos
  /***********************************************************************
     FUNCTION f_ejecutar_cargue_masivo_proc:
          realiza el cargue masivo de pagos
          autor: Marcelo Ozawa de Sousa - 06/06/2019
   ***********************************************************************/
	  
   FUNCTION f_ejecutar_cargue_masivo_proc(p_ssproces IN NUMBER)
      RETURN NUMBER;
  /***********************************************************************
     FUNCTION f_res_ejecutar_cargue_masivo:
          realiza el cargue masivo de pagos
          autor: Marcelo Ozawa de Sousa - 06/06/2019
   ***********************************************************************/
   FUNCTION f_res_ejecutar_cargue_masivo(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
  /***********************************************************************
     FUNCTION f_ejecutar_cargue_masivo_job:
          realiza el cargue masivo de pagos
          autor: Marcelo Ozawa de Sousa - 06/06/2019
   ***********************************************************************/
  FUNCTION f_ejecutar_cargue_masivo_job(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;
--Fin IAXIS 4184 07/06/2019 MOS Incluir Cambios Cargue Masivo para pagos
END pac_cargas_generico;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_GENERICO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_GENERICO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_GENERICO" TO "PROGRAMADORESCSI";
