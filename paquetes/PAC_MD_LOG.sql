--------------------------------------------------------
--  DDL for Package PAC_MD_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_LOG" AS
/******************************************************************************
   NOMBRE:      PAC_MD_LOG

   REVISIONES:
   Ver        Fecha        Autor             Descripci贸n
   ---------  ----------  ---------------  ------------------------------------
   1.0       13/09/2010   XPL                15685: CIV998 - Preparar la aplicaci贸n para que registre campos concretos en log_actividad
******************************************************************************/
   /*************************************************************************
      Inserta los par谩metros de entrada en la tabla LOG_CONSULTAS.
      param in  ptconsulta     : Consulta realizada
      param in  ptllamada      : Nombre de la funci贸n desde donde se llama
      param in  pctipo         : Tipo de consulta: 1: B煤squeda, 2:Selecci贸n
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Inserta los par谩metros de entrada en la tabla LOG_ACTIVIDAD.
      param in  ptorigen       : Qu茅 opci贸n hemos consultado
      param in  ptmodo         : modo acceso pantalla
      param out mensajes       : mensajes de error
      return    NUMBER         : 0 -> Finaliza correctamente.
                               : 1 -> Finaliza con error.
   *************************************************************************/
   FUNCTION f_log_actividad(
      ptorigen IN VARCHAR2,
      ptmodo IN VARCHAR2,   --BUG9290-02032009-XVM-Activar log activitat
      piddoc IN NUMBER,   --xpl 13092010 bug 15685
      pimpresion IN t_iax_impresion,
      pcontador IN NUMBER,
      pfichero IN VARCHAR2,   --xpl 19042011 bug 15685
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 24278 - APD - 12/12/2012 - se crea la funcion
   /*************************************************************************
      Inserta los par醡etros de entrada en la tabla LOG_SUP_DIFERIDOS.
      param in  psseguro     : Identificador del seguro
      param in  pctiplog     : Tipo del registro insertado en el LOG
      param in  pttexto         : Texto
      param in  ptllamada      : Nombre de la funci髇 desde donde se llama
      param in  pntraza         : Numero de la traza
      param in out mensajes       : mensajes de error
      return    NUMBER         : 0 -> Finaliza correctamente.
                               : 1 -> Finaliza con error.
   *************************************************************************/
   PROCEDURE p_log_sup_diferidos(
      psseguro IN NUMBER,
      pctiplog IN NUMBER,
      pttexto IN VARCHAR2,
      ptllamada IN VARCHAR2,
      pntraza IN NUMBER,
      mensajes IN OUT t_iax_mensajes);
END pac_md_log;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_LOG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LOG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LOG" TO "PROGRAMADORESCSI";
