--------------------------------------------------------
--  DDL for Package Body PAC_IAX_GESTIONBPM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_GESTIONBPM" IS
/******************************************************************************
   NOMBRE:       PAC_IAX_GESTIONBPM
   PROPÓSITO: Funciones para integracion de BPM con AXIS

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        27/09/2013   AMC              1. Creación del package.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*******************************************************************************************
       FUNTION f_get_casos
       Función que retorna los casos de bpm
       param in pncaso_bpm. Número de caso BPM
       param in pnsolici_bpm. Número de solicitud BPM
       param in pcusuasignado. Usuario asignado
       param in pcestado. Estado del caso
       param in pctipmov_bpm. Tipo de movimiento
       param in pcramo. Ramo
       param in psproduc. Producto
       param in pnpoliza. Póliza
       param in pncertif. Certificado
       param in pnnumide. Número de identificación
       param in ptnomcom. Nombre del tomador

       Bug 28263/153355 - 27/09/2013 - AMC
   *******************************************************************************************/
   FUNCTION f_get_casos(
      pncaso_bpm IN NUMBER,
      pnsolici_bpm IN NUMBER,
      pcusuasignado IN VARCHAR2,
      pcestado IN NUMBER,
      pctipmov_bpm IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnomcom IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobject        VARCHAR2(500) := 'PAC_IAX_BPM.f_get_casos';
      vparam         VARCHAR2(500)
         := 'parámetros - pncaso_bpm:' || pncaso_bpm || ' pnsolici_bpm:' || pnsolici_bpm
            || ' pcusuasignado:' || pcusuasignado || ' pcestado:' || pcestado
            || ' pctipmov_bpm:' || pctipmov_bpm || ' pcramo:' || pcramo || ' psproduc:'
            || psproduc || ' pnpoliza:' || pnpoliza || ' pncertif:' || pncertif
            || ' pnnumide:' || pnnumide || ' ptnomcom:' || ptnomcom;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_gestionbpm.f_get_casos(pncaso_bpm, pnsolici_bpm, pcusuasignado, pcestado,
                                           pctipmov_bpm, pcramo, psproduc, pnpoliza, pncertif,
                                           pnnumide, ptnomcom, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_casos;

   /***************************************************************************************
    * Funcion f_get_tomcaso
    * Funcion que devuelve el nombre del tomador del cso BPM
    *
    * Parametros: pnnumcaso: Numero de caso
    *             pncaso_bpm: Numero de caso BPM
    *             pnsolici_bpm: Numero de solicitud BPM
    *             ptnomcom: Nombre completo del tomador
    *
    * Return: 0 OK, otro valor error.
    ****************************************************************************************/
   FUNCTION f_get_tomcaso(
      pnnumcaso IN NUMBER,
      pncaso_bpm IN NUMBER,
      pnsolici_bpm IN NUMBER,
      ptnomcom OUT VARCHAR2,
      pnnumcaso_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(100) := 'PAC_IAX_GESTIONBPM.F_GET_TOMCASO';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'Parametros: pnnumcaso= ' || pnnumcaso || ' pncaso_bpm=' || pncaso_bpm
            || ' pnsolici_bpm:' || pnsolici_bpm;
      vnumerr        NUMBER;
   BEGIN
      IF pnnumcaso IS NULL
         AND pncaso_bpm IS NULL
         AND pnsolici_bpm IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_gestionbpm.f_get_tomcaso(pnnumcaso, pncaso_bpm, pnsolici_bpm, ptnomcom,
                                                 pnnumcaso_out, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1000005;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1000006;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1000001;
   END f_get_tomcaso;

   /*************************************************************************
      Devuelve el caso bpm
       Parametros in: pnnumcaso: Numero de caso
                      pncaso_bpm: Numero de caso BPM
                      pnsolici_bpm: Numero de solicitud BPM
       param out mensajes : mesajes de error
      return             : caso bpm

      Bug 28263/153355 - 01/10/2013 - AMC
   *************************************************************************/
   FUNCTION f_lee_caso_bpm(
      pnnumcaso IN NUMBER,
      pncaso_bpm IN NUMBER,
      pnsolici_bpm IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_bpm IS
      num_err        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'Parametros: pnnumcaso= ' || pnnumcaso || ' pncaso_bpm=' || pncaso_bpm
            || ' pnsolici_bpm:' || pnsolici_bpm;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONBPM.f_lee_caso_bpm';
      casobpm        ob_iax_bpm;
   BEGIN
      IF pnnumcaso IS NULL
         AND pncaso_bpm IS NULL
         AND pnsolici_bpm IS NULL THEN
         RAISE e_param_error;
      END IF;

      casobpm := pac_md_gestionbpm.f_lee_caso_bpm(pnnumcaso, pncaso_bpm, pnsolici_bpm,
                                                  mensajes);
      RETURN casobpm;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_lee_caso_bpm;

   /*************************************************************************
      Valida los datos del caso bpm
      param in pmodo : modo para realizar las validaciones
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error

      Bug 28263/153355 - 02/10/2013 - AMC
   *************************************************************************/
   FUNCTION f_valida_datosbpm(pmodo IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100);
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONBPM.f_valida_datosbpm';
      v_nerror       NUMBER;
      poliza         ob_iax_detpoliza;
   BEGIN
      -- Recuperamos la póliza
      poliza := pac_iax_produccion.f_get_detpoliza(mensajes);
      v_nerror := pac_md_gestionbpm.f_valida_datosbpm(poliza, pmodo, mensajes);
      RETURN v_nerror;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_datosbpm;

   /*************************************************************************
      Valida el tomador del caso bpm
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error

      Bug 28263/153355 - 02/10/2013 - AMC
   *************************************************************************/
   FUNCTION f_valida_tomadorbpm(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100);
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONBPM.f_valida_tomadorbpm';
      v_nerror       NUMBER;
      poliza         ob_iax_detpoliza;
   BEGIN
      -- Recuperamos la póliza
      poliza := pac_iax_produccion.f_get_detpoliza(mensajes);
      v_nerror := pac_md_gestionbpm.f_valida_tomadorbpm(poliza, mensajes);
      RETURN v_nerror;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_tomadorbpm;

   /*************************************************************************
      Valida los datos del caso bpm para certificados
      param in pncaso_bpm: Numero de caso BPM
               pnsolici_bpm: Numero de solicitud BPM

      return : 0 todo correcto
               <> 0 ha habido un error

      Bug 28263/153355 - 07/10/2013 - AMC
   *************************************************************************/
   FUNCTION f_valida_datosbpmcertif(
      pncaso_bpm IN NUMBER,
      pnsolici_bpm IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100);
      vobject        VARCHAR2(200) := 'PAC_MD_DATOSBPMCERTIF.f_valida_datosbpmcertif';
      v_nerror       NUMBER;
      poliza         ob_iax_detpoliza;
   BEGIN
      -- Recuperamos la póliza
      poliza := pac_iax_produccion.f_get_detpoliza(mensajes);
      v_nerror := pac_md_gestionbpm.f_valida_datosbpmcertif(pncaso_bpm, pnsolici_bpm, poliza,
                                                            mensajes);
      RETURN v_nerror;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_datosbpmcertif;

   /***********************************************************************
        Recupera : Retorna un objeto ob_iax_bpm y determina si se debe mostrar o no por pantalla
        param in  psseguro  : codigo de seguro
        param in  pnmovimi  : número de movimiento
        param out pmostrar : indica si se debe mostrar el caso BPM
        param out mensajes : mensajes de error
        return             : ob_iax_bpm
     ***********************************************************************/
   FUNCTION f2_get_caso_bpm(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pmostrar OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_bpm IS
      vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(500) := 'psseguro: ' || psseguro || ', pnmovimi: ' || pnmovimi;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONBPM.f2_get_caso_bpm';
      caso_bpm       ob_iax_bpm;
   BEGIN
      caso_bpm := pac_md_gestionbpm.f2_get_caso_bpm(psseguro, pnmovimi, pmostrar, mensajes);
      vpasexec := 10;
      RETURN caso_bpm;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN caso_bpm;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN caso_bpm;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN caso_bpm;
   END f2_get_caso_bpm;

   /*************************************************************************
      Valida los datos del caso bpm para certificados
      param in pnpoliza: Numero de póliza
               pncertif: Numero de certificado
               poperacion : Tipo de operacion.
      param out pcasobpm : Caso BPM
      return : 0 todo correcto
               <> 0 ha habido un error

      Bug 28263/155120 - 08/10/2013 - AMC
   *************************************************************************/
   FUNCTION f_get_caso_bpm(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      poperacion IN VARCHAR2,
      pcasobpm OUT ob_iax_bpm,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100)
         := 'pnpoliza:' || pnpoliza || ' pncertif:' || pncertif || ' poperacion:'
            || poperacion;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONBPM.f_get_caso_bpm';
      v_nerror       NUMBER;
      vcount         NUMBER;
      vnnumcaso      NUMBER;
   BEGIN
      IF pnpoliza IS NULL THEN
         RAISE e_param_error;
      END IF;

      pcasobpm := ob_iax_bpm();
      v_nerror := pac_md_gestionbpm.f_get_caso_bpm(pnpoliza, pncertif, poperacion, pcasobpm,
                                                   mensajes);

      IF v_nerror <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN v_nerror;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_caso_bpm;

   /***********************************************************************
       Recupera : validaciónes BPM segun el tipo de operacion
       param in  pncaso_bpm  : numero de caso bpm
       param in  pnsolici_bpm: numero de solicitud bpm
       param in  psproduc    : codigo de producto
       param in  pnpoliza    : codigo de poliza
       param in  pncertif    : número de certificado
       param in  poperacion  : Tipo de operacion.
       param out mensajes    : mensajes de error
       return             NUMBER : 0--> OK , codigo error
    ***********************************************************************/
   FUNCTION f2_valida_datosbpm(
      pncaso_bpm IN NUMBER,
      pnsolici_bpm IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      poperacion IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(500)
         := 'pncaso_bpm: ' || pncaso_bpm || ', pnsolici_bpm: ' || pnsolici_bpm
            || ', psproduc: ' || psproduc || ', pnpoliza: ' || pnpoliza || ', pncertif: '
            || pncertif || ', poperacion: ' || poperacion;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONBPM.f2_valida_datosbpm';
      v_nerror       NUMBER;
   BEGIN
      v_nerror := pac_md_gestionbpm.f2_valida_datosbpm(pncaso_bpm, pnsolici_bpm, psproduc,
                                                       pnpoliza, pncertif, poperacion,
                                                       mensajes);
      vpasexec := 10;
      RETURN v_nerror;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f2_valida_datosbpm;

   /*************************************************************************
      grabar registro en la tabla CASOS_BPMSEG
      param in pcempres_in
               psseguro:     identificador del seguro
               pnmovimi:     número de movimiento de seguro
               pncaso_bpm:   número del caso en el BPM
               pnsolici_bpm: número de la solicitud en el BPM
               pnnumcaso:    número del caso interno de iAxis
      return : 0 todo correcto
               1 ha habido un error
   *************************************************************************/
   FUNCTION f_trata_movpoliza(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pncaso_bpm IN NUMBER,
      pnsolici_bpm IN NUMBER,
      pnnumcaso IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := ' psseguro:' || psseguro || ' pnmovimi:' || pnmovimi || ' pncaso_bpm:'
            || pncaso_bpm || ' pnsolici_bpm:' || pnsolici_bpm || ' pnnumcaso:' || pnnumcaso;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONBPM.f_trata_movpoliza';
      v_nerror       NUMBER;
   BEGIN
      v_nerror := pac_md_gestionbpm.f_trata_movpoliza(psseguro, pnmovimi, pncaso_bpm,
                                                      pnsolici_bpm, pnnumcaso, mensajes);
      vpasexec := 10;

      IF (v_nerror = 0) THEN
         vpasexec := 11;
         COMMIT;
      ELSE
         vpasexec := 12;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_nerror);
         ROLLBACK;
         RETURN 1;
      END IF;

      vpasexec := 20;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_trata_movpoliza;

    /*************************************************************************
      Valida los datos del caso bpm para cargas
      param in pncaso_bpm: Numero de caso BPM
               pnnumcaso: Numero de caso
               pfichero: nombre del fichero

      return : 0 todo correcto
               <> 0 ha habido un error

      Bug 28263/155558 - 14/10/2013 - AMC
   *************************************************************************/
   FUNCTION f_valida_datosbpmcarga(
      pncaso_bpm IN NUMBER,
      pnnumcaso IN NUMBER,
      pfichero IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100)
         := 'pncaso_bpm:' || pncaso_bpm || ' pnnumcaso:' || pnnumcaso || ' pfichero:'
            || pfichero;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONBPM.f_valida_datosbpmcarga';
      v_nerror       NUMBER;
   BEGIN
      v_nerror := pac_md_gestionbpm.f_valida_datosbpmcarga(pncaso_bpm, pnnumcaso, pfichero,
                                                           mensajes);

      IF v_nerror <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_datosbpmcarga;
END pac_iax_gestionbpm;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_GESTIONBPM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GESTIONBPM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GESTIONBPM" TO "PROGRAMADORESCSI";
