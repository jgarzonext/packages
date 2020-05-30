--------------------------------------------------------
--  DDL for Package PAC_AUDITORIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_AUDITORIA" AS
 /*****************************************************************************************
 NOMBRE: PAC_AUDITORIA
      PROPÓSITO: Funciones para la auditoria
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ----------------------------------------------
      1.0        27/04/2012    lcf            1. Creación del package.
      2.0        27/04/2012    lcf            2. 0110901 p_get_rec_rastros - PROCESO REGISTRO DE RASTROS DE AUDITORIA
      3.0        27/01/2014    RCL            3. 0029765: LCOL_MILL-LCOL - Fase Mejoras - Proceso nocturno de auditoria

   **************************************************************************************/
/****************************************************************************************
       Prcedimiento p_get_rec_rastros, PROCESO REGISTRO DE RASTROS DE AUDITORIA
       Registra todos los cambios en Tabla AUD_RASTROS
       param in  p_fecha_ini,
                 p_fecha_fin,
                 p_login
    ************************************************************************************/
   PROCEDURE p_get_rec_rastros(
      p_fecha_ini IN DATE,
      p_fecha_fin IN DATE,
      p_login IN VARCHAR2 DEFAULT NULL);

   /************************************************************************************
       Inicia una auditoria.
       param in  pcusuari: Usuario de la ejecución
                 pcempres: Empresa asociada
                 pcaudit: Código de auditoria
                 ptaudit: Texto de la auditoria
       param out psauditoria: Número de proceso de la auditoria
   ************************************************************************************/
   FUNCTION f_auditoriaini(
      pcusuari IN VARCHAR2,
      pcempres IN NUMBER,
      pcaudit IN VARCHAR2,
      ptaudit IN VARCHAR2,
      psauditoria OUT NUMBER)
      RETURN NUMBER;

   /************************************************************************************
       CREA O MODIFICA UNA LINEA EN LA TABLA DE CONTROL DE AUDITORIAS
       Registra todos los cambios en Tabla AUDITORIALIN
       param in psauditoria: Número de proceso de la auditoria
                par_taudlin
                pnaudnum
                pnaudlin
                pctiplin: Tipo de línea
   ************************************************************************************/
   FUNCTION f_auditorialin(
      psauditoria IN NUMBER,
      par_taudlin IN VARCHAR2,
      pnaudnum IN NUMBER,
      pnaudlin IN OUT NUMBER,
      pctiplin IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /************************************************************************************
       Finaliza una auditoria.
       param in psauditoria: nº de proceso de auditoria a finalizar
                pnerror : nº de errores en el proceso
   ************************************************************************************/
   FUNCTION f_auditoriafin(psauditoria IN NUMBER, pnerror IN NUMBER)
      RETURN NUMBER;
END pac_auditoria;

/

  GRANT EXECUTE ON "AXIS"."PAC_AUDITORIA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_AUDITORIA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_AUDITORIA" TO "PROGRAMADORESCSI";
