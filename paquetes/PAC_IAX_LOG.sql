--------------------------------------------------------
--  DDL for Package PAC_IAX_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_LOG" AS
      /*************************************************************************
   REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        13/09/2010   XPL                15685: CIV998 - Preparar la aplicación para que registre campos concretos en log_actividad
   ********************************************************************************/
      /*************************************************************************
         Inserta los parámetros de entrada en la tabla LOG_CONSULTAS.
         param in  ptconsulta     : Consulta realizada
         param in  ptllamada      : Nombre de la función desde donde se llama
         param in  pctipo         : Tipo de consulta: 1: Búsqueda, 2:Selección
         param in  pcorigen       : Donde se ha realizado la consulta
         param out mensajes       : mensajes de error
         return    NUMBER         : 0 -> Finaliza correctamente.
                                  : 1 -> Finaliza con error.
      *************************************************************************/
   FUNCTION f_log_consultas(
      ptconsulta IN VARCHAR2,
      ptllamada IN VARCHAR2,
      pctipo IN NUMBER,
      pcorigen IN NUMBER DEFAULT 0,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Inserta los parámetros de entrada en la tabla LOG_ACTIVIDAD.
      param in  ptorigen       : Qué opción hemos consultado
      param in  ptmodo         : modo acceso pantalla
      param out mensajes       : mensajes de error
      return    NUMBER         : 0 -> Finaliza correctamente.
                               : 1 -> Finaliza con error.
   *************************************************************************/
   FUNCTION f_log_actividad(
      ptorigen IN VARCHAR2,
      ptmodo IN VARCHAR2,   --BUG9290-02032009-XVM-Activar log activitat
      piddoc IN NUMBER,   --xpl 13092010 bug 15685
      pcontador IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 24278 - APD - 12/12/2012 - se crea la funcion
   /*************************************************************************
      Inserta los parámetros de entrada en la tabla LOG_SUP_DIFERIDOS.
      param in  psseguro     : Identificador del seguro
      param in  pctiplog     : Tipo del registro insertado en el LOG
      param in  pttexto         : Texto
      param in  ptllamada      : Nombre de la función desde donde se llama
      param in  pntraza         : Numero de la traza
      param out mensajes       : mensajes de error
      return    NUMBER         : 0 -> Finaliza correctamente.
                               : 1 -> Finaliza con error.
   *************************************************************************/
   PROCEDURE p_log_sup_diferidos(
      psseguro IN NUMBER,
      pctiplog IN NUMBER,
      pttexto IN VARCHAR2,
      ptllamada IN VARCHAR2,
      pntraza IN NUMBER,
      mensajes OUT t_iax_mensajes);
END pac_iax_log;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_LOG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LOG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LOG" TO "PROGRAMADORESCSI";
