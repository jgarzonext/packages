--------------------------------------------------------
--  DDL for Package PAC_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_LOG" AS
   /*************************************************************************
      Traspasa de LOG_CONSULTAS a HISLOG_CONSULTAS  y de LOG_ACTIVIDAD a HISLOG_ACTIVIDAD.
      return    NUMBER         : 0   -> Finaliza correctamente.
                               : <>0 -> Finaliza con error.
   *************************************************************************/
   FUNCTION f_traspaso_log
      RETURN NUMBER;

    /*************************************************************************
      Inserta los parámetros de entrada en la tabla LOG_CONSULTAS.
      param in  ptconsulta     : Consulta realizada
      param in  ptllamada      : Nombre de la función desde donde se llama
      param in  pctipo         : Tipo de consulta: 1: Búsqueda, 2:Selección
      param in  pcorigen       : Donde se ha realizado la consulta
      param in  pfconsulta     : Fecha en que se realiza la consulta
      param in  pcusuari       : Usuario que ha realizado la consulta
      return    NUMBER         : 0   -> Finaliza correctamente.
                               : <>0 -> Finaliza con error.
   *************************************************************************/
   FUNCTION f_log_consultas(
      ptconsulta IN VARCHAR2,
      ptllamada IN VARCHAR2,
      pctipo IN NUMBER,
      pcorigen IN NUMBER DEFAULT 0,
      pfconsulta IN DATE DEFAULT f_sysdate,
      pcusuari IN VARCHAR2 DEFAULT f_user)
      RETURN NUMBER;

   /*************************************************************************
      Inserta los parámetros de entrada en la tabla LOG_ACTIVIDAD.
      param in  pcorigen       : Qué opción hemos consultado
      param in  pfconsulta     : Fecha en que se realiza la consulta
      param in  pcusuari       : Usuario que ha realizado la consulta
      param in  ptmodo         : modo acceso pantalla
      return    NUMBER         : 0   -> Finaliza correctamente.
                               : <>0 -> Finaliza con error.
   *************************************************************************/
   FUNCTION f_log_actividad(
      ptorigen IN VARCHAR2,
      pfecha IN DATE DEFAULT f_sysdate,
      pcusuari IN VARCHAR2 DEFAULT f_user,
      ptmodo IN VARCHAR2,
      piddoc IN NUMBER,
      ptcolumna IN VARCHAR2,
      ptvalor IN VARCHAR2,
      ptdescripcion IN VARCHAR2,
      pttipo IN VARCHAR2,
      pcidioma IN NUMBER,
      pfichero IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_log_interfases(
      pcusuario VARCHAR2,
      pfinterf DATE,
      psinterf NUMBER,
      pcinterf VARCHAR2,
      pnresult NUMBER,
      pterror VARCHAR2,
      ptindentificador VARCHAR2,
      pnidentificador VARCHAR2,
      pobservaciones VARCHAR2)
      RETURN NUMBER;

   -- Bug 24278 - APD - 12/12/2012 - se crea la funcion
   /*************************************************************************
      Inserta los parámetros de entrada en la tabla LOG_SUP_DIFERIDOS.
      param in  psseguro     : Identificador del seguro
      param in  pctiplog     : Tipo del registro insertado en el LOG
      param in  pttexto         : Texto
      param in  ptllamada      : Nombre de la función desde donde se llama
      param in  pntraza         : Numero de la traza
      return    NUMBER         : 0 -> Finaliza correctamente.
                               : 1 -> Finaliza con error.
   *************************************************************************/
   PROCEDURE p_log_sup_diferidos(
      psseguro IN NUMBER,
      pctiplog IN NUMBER,
      pttexto IN VARCHAR2,
      ptllamada IN VARCHAR2,
      pntraza IN NUMBER);
END pac_log;

/

  GRANT EXECUTE ON "AXIS"."PAC_LOG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LOG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LOG" TO "PROGRAMADORESCSI";
