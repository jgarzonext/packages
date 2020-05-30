--------------------------------------------------------
--  DDL for Package Body PAC_MD_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_LOG" AS
/******************************************************************************
   NOMBRE:      PAC_MD_LOG

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0       13/09/2010   XPL                15685: CIV998 - Preparar la aplicación para que registre campos concretos en log_actividad
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(50) := 'PAC_MD_LOG.F_LOG_CONSULTAS';
      vparam         VARCHAR2(4000)
         := 'parámetros - ptconsulta=' || ptconsulta || ', ptllamada=' || ptllamada
            || ', pctipo=' || pctipo || ', pcorigen=' || pcorigen;
      vpasexec       NUMBER(2) := 1;
      vret           NUMBER;
   BEGIN
      vret := pac_log.f_log_consultas(ptconsulta, ptllamada, pctipo, pcorigen, f_sysdate,
                                      pac_md_common.f_get_cxtusuario);

      IF vret <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vret);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_log_consultas;

   /*************************************************************************
      Inserta los parámetros de entrada en la tabla LOG_ACTIVIDAD.
      param in  pcorigen       : Qué opción hemos consultado
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
      pcontador IN NUMBER,   --xpl 13092010 bug 15685
      pfichero IN VARCHAR2,   --xpl 19042011 bug 15685
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(50) := 'PAC_MD_LOG.F_LOG_ACTIVIDAD';
      vparam         VARCHAR2(4000) := 'parámetros - ptorigen=' || ptorigen;
      vpasexec       NUMBER(2) := 1;
      vret           NUMBER;
      vdesc          VARCHAR2(2000);
      vnombre_columna VARCHAR2(4000);
      vvalor_columna VARCHAR2(4000);
   BEGIN
      IF NVL(f_parinstalacion_n('REG_LOGS'), 1) = 1 THEN
         IF ptorigen = 'axisimprimir'
            AND(pimpresion IS NOT NULL
                AND pimpresion.COUNT > 0) THEN
            FOR i IN pimpresion.FIRST .. pimpresion.LAST LOOP
               IF (pcontador IS NOT NULL
                   AND pcontador + 1 = i) THEN
                  --  OR pcontador IS NULL THEN
                  IF pimpresion(i).info_campos IS NOT NULL
                     AND pimpresion(i).info_campos.COUNT > 0 THEN
                     FOR j IN pimpresion(i).info_campos.FIRST .. pimpresion(i).info_campos.LAST LOOP
                        IF vnombre_columna IS NOT NULL THEN
                           vnombre_columna := vnombre_columna || '##'
                                              || pimpresion(i).info_campos(j).nombre_columna;
                        ELSE
                           vnombre_columna := pimpresion(i).info_campos(j).nombre_columna;
                        END IF;

                        IF vvalor_columna IS NOT NULL THEN
                           vvalor_columna := vvalor_columna || '##'
                                             || pimpresion(i).info_campos(j).valor_columna;
                        ELSE
                           vvalor_columna := pimpresion(i).info_campos(j).valor_columna;
                        END IF;
                     END LOOP;
                  END IF;

                  IF vnombre_columna IS NOT NULL
                     OR vvalor_columna IS NOT NULL THEN
                     vret := pac_log.f_log_actividad(ptorigen, f_sysdate,
                                                     pac_md_common.f_get_cxtusuario, ptmodo,
                                                     piddoc, vnombre_columna, vvalor_columna,
                                                     pimpresion(i).descripcion,
                                                     pimpresion(i).ttipo,
                                                     pac_md_common.f_get_cxtidioma, pfichero);
                  ELSE
                     vret := pac_log.f_log_actividad(ptorigen, f_sysdate,
                                                     pac_md_common.f_get_cxtusuario, ptmodo,
                                                     piddoc, NULL, NULL, NULL, NULL,
                                                     pac_md_common.f_get_cxtidioma, pfichero);
                  END IF;
               END IF;
            END LOOP;
         ELSE
            vret := pac_log.f_log_actividad(ptorigen, f_sysdate,
                                            pac_md_common.f_get_cxtusuario, ptmodo, piddoc,
                                            NULL, NULL, NULL, NULL,
                                            pac_md_common.f_get_cxtidioma, pfichero);

            IF vret <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vret);
               RAISE e_object_error;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_log_actividad;

   -- Bug 24278 - APD - 12/12/2012 - se crea la funcion
   /*************************************************************************
      Inserta los par�metros de entrada en la tabla LOG_SUP_DIFERIDOS.
      param in  psseguro     : Identificador del seguro
      param in  pctiplog     : Tipo del registro insertado en el LOG
      param in  pttexto         : Texto
      param in  ptllamada      : Nombre de la funci�n desde donde se llama
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
      mensajes IN OUT t_iax_mensajes) IS
      vobject        VARCHAR2(50) := 'PAC_MD_LOG.P_LOG_SUP_DIFERIDOS';
      vparam         VARCHAR2(4000)
         := 'psseguro = ' || psseguro || '; pctiplog = ' || pctiplog || '; pttexto = '
            || pttexto || '; ptllamada = ' || ptllamada || '; pntraza = ' || pntraza;
      vpasexec       NUMBER(2) := 1;
      vret           NUMBER;
   BEGIN
      pac_log.p_log_sup_diferidos(psseguro, pctiplog, pttexto, ptllamada, pntraza);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
   END p_log_sup_diferidos;
END pac_md_log;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_LOG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LOG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LOG" TO "PROGRAMADORESCSI";
