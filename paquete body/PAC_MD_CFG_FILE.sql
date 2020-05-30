--------------------------------------------------------
--  DDL for Package Body PAC_MD_CFG_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_CFG_FILE" AS
   /******************************************************************************
      NOMBRE:       PAC_MD_CFG_FILE
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
      param in out mensajes   : mensajes de error
      return                  : 0.- OK
                                1.- error
   *************************************************************************/
   FUNCTION f_get_procesos(p_tprocesos OUT sys_refcursor, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := '';
      v_object       VARCHAR2(200) := 'PAC_MD_CFG_FILE.f_get_procesos';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_cfg_file.f_get_procesos(pac_md_common.f_get_cxtempresa,
                                             pac_md_common.f_get_cxtidioma, p_tprocesos);

      IF v_error != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
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
      param in out mensajes   : mensajes de error
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := 'p_cproceso = ' || p_cproceso;
      v_object       VARCHAR2(200) := 'PAC_MD_CFG_FILE.f_get_datos_proceso';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_cfg_file.f_get_datos_proceso(p_cproceso, pac_md_common.f_get_cxtempresa,
                                                  p_tdestino, p_tproceso, p_borrafich);

      IF v_error != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
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
      param in out p_sproces  : Num de proceso
      param out p_tpantalla   : Pantalla de navegación siguiente
      param in out mensajes   : mensajes de error
      return                  : 0.- OK
                                1.- error
   *************************************************************************/
   FUNCTION f_ejecuta_proceso(
      p_cproceso IN NUMBER,
      p_tfile IN VARCHAR2,
      p_sproces IN OUT NUMBER,   --Bug 14750-PFA-31/05/2010- psproces IN OUT
      p_nnumcaso IN NUMBER,   -- Bug 28263/156016 - 15/10/2013 - AMC
      p_tpantalla OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'p_cproceso = ' || p_cproceso || ' p_tfile = ' || p_tfile || ' p_sproces = '
            || p_sproces;
      v_object       VARCHAR2(200) := 'PAC_MD_CFG_FILE.f_ejecuta_proceso';
      v_error        NUMBER(8);
   BEGIN
      v_error :=
         pac_cfg_file.f_ejecuta_proceso(p_cproceso, p_tfile, pac_md_common.f_get_cxtempresa,
                                        p_sproces, p_nnumcaso,   -- Bug 28263/156016 - 15/10/2013 - AMC
                                        p_tpantalla);

      IF v_error != 0 THEN
         --Mantis 33886/212377 - se adiciona literal 105245 en la validacion  - BLA - DD25/MM09/2015.
         IF v_error = 105245 THEN   -- jlb es un error controlado de job lanzado
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, v_error);
            RETURN v_error;   -- si es job encolado devuelvo correcto
         END IF;

         IF v_error IN(9901606, 9907390) THEN   -- jlb es un error controlado de job lanzado
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, v_error);
            RETURN 0;   -- si es job encolado devuelvo correcto
         END IF;

         -- sino devuelve el error real
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
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
      v_object       VARCHAR2(200) := 'PAC_MD_CFG_FILE.f_get_proceso_cargado';
      v_error        NUMBER(8);
   BEGIN
      v_error := pac_cfg_file.f_get_proceso_cargado(pcproceso, ptfichero);

      IF v_error NOT IN(0, 1) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN v_error;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN SQLCODE;
   END f_get_proceso_cargado;
END pac_md_cfg_file;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_CFG_FILE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CFG_FILE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CFG_FILE" TO "PROGRAMADORESCSI";
