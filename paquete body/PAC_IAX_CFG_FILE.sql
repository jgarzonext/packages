--------------------------------------------------------
--  DDL for Package Body PAC_IAX_CFG_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_CFG_FILE" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_CFG_FILE
   PROPÓSITO:    Control y gestión de tratamiento de ficheros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        12/02/2009   JTS                1. Creación del package.
   2.0        31/05/2010   PFA                2. 14750: ENSA101 - Reproceso de procesos ya existentes
   3.0        14/09/2010   PFA                3. 15730: CRT - Avisar que el fichero ya esta cargado
   4.0        04/11/2010   FAL                4. 0016525: CRT002 - Incidencias en cargas (primera carga inicial)
   5.0        25/09/2015   BLA                5. 0033886-212377 -  Se adiciona control de error para el literar 105245
******************************************************************************/
   e_object_error EXCEPTION;

   /*************************************************************************
      BUG9077 - 12/02/2009 - JTS
      Abre un cursor con los procesos definidos en CFG_FILES
      param out p_tprocesos   : sys_refcursor
      param out mensajes      : mensajes de error
      return                  : 0.- OK
                                1.- error
   *************************************************************************/
   FUNCTION f_get_procesos(p_tprocesos OUT sys_refcursor, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := '';
      v_object       VARCHAR2(200) := 'PAC_IAX_CFG_FILE.f_get_procesos';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_cfg_file.f_get_procesos(p_tprocesos, mensajes);

      IF v_error != 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_procesos;

   /*************************************************************************
      BUG9077 - 12/02/2009 - JTS
      Retorna los parámetros para la ejecución de un proceso
      param in  p_cproceso    : Id. del proceso
      param out p_tdestino    : Directorio de destino
      param out p_tproceso    : Proceso de base de datos
      param out mensajes      : mensajes de error
      return                  : 0.- OK
                                1.- error
   *************************************************************************/
   FUNCTION f_get_datos_proceso(
      p_cproceso IN NUMBER,
      p_tdestino OUT VARCHAR2,
      p_tproceso OUT VARCHAR2,
      -- Bug 0016525. FAL. 04/11/2010. Se añade parametro q indica si borrar fichero del servidor
      p_borrafich OUT NUMBER,
      -- Fi Bug 0016525
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := 'p_cproceso = ' || p_cproceso;
      v_object       VARCHAR2(200) := 'PAC_IAX_CFG_FILE.f_get_datos_proceso';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_cfg_file.f_get_datos_proceso(p_cproceso, p_tdestino, p_tproceso,
                                                     p_borrafich, mensajes);

      IF v_error != 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_datos_proceso;

   /*************************************************************************
      BUG9077 - 12/02/2009 - JTS
      Realiza el tratamiento del fichero
      param in  p_cproceso    : Id. del proceso
      param in  p_tfile       : Nombre del fichero
      param in  p_sproces     : Num de proceso
      param out p_sprocessal  : Num de proceso   --Bug 14750-PFA-31/05/2010- psproces IN OUT
      param out p_tpantalla   : Pantalla de navegación siguiente
      param out mensajes      : mensajes de error
      return                  : 0.- OK
                                1.- error
   *************************************************************************/
   FUNCTION f_ejecuta_proceso(
      p_cproceso IN NUMBER,
      p_tfile IN VARCHAR2,
      p_sproces IN NUMBER,
      p_nnumcaso IN NUMBER,   -- Bug 28263/156016 - 15/10/2013 - AMC
      p_sprocessal OUT NUMBER,   --Bug 14750-PFA-31/05/2010- psproces IN OUT
      p_tpantalla OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
                                  := 'p_cproceso = ' || p_cproceso || ' p_tfile = ' || p_tfile;
      v_object       VARCHAR2(200) := 'PAC_IAX_CFG_FILE.f_ejecuta_proceso';
      v_error        NUMBER(8);
   BEGIN
      p_sprocessal := p_sproces;
      v_error :=
         pac_md_cfg_file.f_ejecuta_proceso(p_cproceso, p_tfile, p_sprocessal, p_nnumcaso,   -- Bug 28263/156016 - 15/10/2013 - AMC
                                           p_tpantalla, mensajes);

      IF v_error = 105245 THEN   --Mantis 33886/212377 - abre if - BLA - DD25/MM09/2015.
         ROLLBACK;
         RETURN 105245;
      END IF;   --Mantis 33886/212377 - cierra if - BLA - DD25/MM09/2015.

      IF v_error != 0
         AND v_error != 9901606 THEN   -- si es un proceso job no devolvemos error
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN v_error;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_ejecuta_proceso;

   /*************************************************************************
      BUG15730 - 14/09/2010 - PFA
      Comprueba si el fichero ya está cargado
      param in  pcproceso     : Id. del proceso
      param in  ptfichero     : Nombre del fichero
      param out mensajes      : mensajes de error
      return                  : 0.- OK
                                1.- error
   *************************************************************************/
   FUNCTION f_get_proceso_cargado(
      pcproceso IN NUMBER,
      ptfichero IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
                                := 'pcproceso = ' || pcproceso || ' ptfichero = ' || ptfichero;
      v_object       VARCHAR2(200) := 'PAC_IAX_CFG_FILE.f_get_proceso_cargado';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_md_cfg_file.f_get_proceso_cargado(pcproceso, ptfichero, mensajes);
      RETURN v_error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN SQLCODE;
   END f_get_proceso_cargado;
END pac_iax_cfg_file;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_CFG_FILE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CFG_FILE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CFG_FILE" TO "PROGRAMADORESCSI";
