--------------------------------------------------------
--  DDL for Package Body PAC_IAX_COMISIONEGOCIO
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "AXIS"."PAC_IAX_COMISIONEGOCIO" AS
   /******************************************************************************
     NOMBRE:     pac_iax_comisionegocio
     PROPÓSITO:  Package para gestionar los convenios de comisión especial

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        19/12/2012   FAL             0025214: LCOL_C004-LCOL: Realizar desarrollo Comisiones Especiales negocio
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Recupera la lista de los convenios de comisión especial en función de los parámetros recibidos
      param in pccodconv : identificador del convenio
      param in ptdesconv : descripción del convenio
      param in pfinivig  : fecha de inicio de vigencia del convenio
      param in pffinvig  : fecha de fin de vigencia del convenio
      param in psproduc  : código de producto
      param in pcagente  : código de agente
      param in ptnomtom  : nombre de tomador
      param in pcramo    : código de ramo
      param out mensajes : colección mensajes error
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_lstconvcomesp(
      pccodconv IN NUMBER,
      ptdesconv IN VARCHAR2,
      pfinivig IN DATE,
      pffinvig IN DATE,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      ptnomtom IN VARCHAR2,
      pcramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_iax_comisionegocio.f_get_lstconvcomesp';
      vpar           VARCHAR2(500)
         := 'c=' || pccodconv || ' t=' || ptdesconv || ' i=' || pfinivig || ' f=' || pffinvig
            || ' p=' || psproduc || ' a=' || pcagente || ' n=' || ptnomtom || ' ramo='
            || pcramo;
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      --RCL 25/06/2013 - BUG 27327 - Permitimos buscar por RAMO
      cur := pac_md_comisionegocio.f_get_lstconvcomesp(pccodconv, ptdesconv, pfinivig,
                                                       pffinvig, psproduc, pcagente, ptnomtom,
                                                       pcramo, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_lstconvcomesp;

   /*************************************************************************
      Recupera los datos del convenio de comisión especial
      param in pccodconv : identificador del convenio
      param out mensajes : colección mensajes error
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_datconvcomesp(pccodconv IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_convcomesp IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_iax_comisionegocio.f_get_datconvcomesp';
      vpar           VARCHAR2(500) := 'i=' || pccodconv;
      cur            sys_refcursor;
      convenio       ob_iax_convcomesp;
   BEGIN
      vpas := 1;
      convenio := pac_md_comisionegocio.f_get_datconvcomesp(pccodconv, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN convenio;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_datconvcomesp;

   /*************************************************************************
      Recupera los datos del producto del convenio de comisión especial
      param in pccodconv : identificador del convenio
      param out mensajes : colección mensajes error
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_prodconvcomesp(pccodconv IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_iax_comisionegocio.f_get_prodconvcomesp';
      vpar           VARCHAR2(500) := 'i=' || pccodconv;
      vsquery        VARCHAR2(2000);
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      cur := pac_md_comisionegocio.f_get_prodconvcomesp(pccodconv, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_prodconvcomesp;

   /*************************************************************************
      Recupera los datos del agente del convenio de comisión especial
      param in pccodconv : identificador del convenio
      param out mensajes : colección mensajes error
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_ageconvcomesp(pccodconv IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_iax_comisionegocio.f_get_ageconvcomesp';
      vpar           VARCHAR2(500) := 'i=' || pccodconv;
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      cur := pac_md_comisionegocio.f_get_ageconvcomesp(pccodconv, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_ageconvcomesp;

   /*************************************************************************
      Recupera los datos del tomador del convenio de comisión especial
      param in pccodconv : identificador del convenio
      param out mensajes : colección mensajes error
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_tomconvcomesp(pccodconv IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_iax_comisionegocio.f_get_tomconvcomesp';
      vpar           VARCHAR2(500) := 'i=' || pccodconv;
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      cur := pac_md_comisionegocio.f_get_tomconvcomesp(pccodconv, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_tomconvcomesp;

   /*************************************************************************
      Borra los el agente de un convenio de comisión especial
      param in pccodconv : identificador del convenio
      param in pcagente  : código de agente
      param out mensajes : colección mensajes error
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_del_ageconvcomesp(
      pccodconv IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_iax_comisionegocio.f_del_ageconvcomesp';
      vpar           VARCHAR2(500) := 'i=' || pccodconv || ' a=' || pcagente;
      num_err        NUMBER;
   BEGIN
      vpas := 1;
      num_err := pac_md_comisionegocio.f_del_ageconvcomesp(pccodconv, pcagente, mensajes);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_ageconvcomesp;

   /*************************************************************************
      Borra el tomador de un convenio de comisión especial
      param in pccodconv : identificador del convenio
      param in psperson  : código del tomador
      param out mensajes : colección mensajes error
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_del_tomconvcomesp(
      pccodconv IN NUMBER,
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_iax_comisionegocio.f_del_tomconvcomesp';
      vpar           VARCHAR2(500) := 'i=' || pccodconv || ' p=' || psperson;
      num_err        NUMBER;
   BEGIN
      vpas := 1;
      num_err := pac_md_comisionegocio.f_del_tomconvcomesp(pccodconv, psperson, mensajes);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_tomconvcomesp;

  /*************************************************************************
      Actualiza/inserta los datos de un convenio de comisión especial
      param in pccodconv : identificador del convenio
      param in ptdesconv : descripción del convenio
      param in pfinivig  : fecha de inicio de vigencia del convenio
      param in pffinvig  : fecha de fin de vigencia del convenio
      param in plistaprods : colección de productos que intervienen en el convenio
      param in plistacomis : colección de comisiones que intervienen en el convenio (según cmodcom con su %)
      param in pcagente  : % de comisión especial del convenio
      param in psperson  : sperson del tomador que interviene en el convenio
      param in pprimausd  : prima en USD
      param in pprimaeur  : prima en EUR
      param out pccodconv_out  : identificador del nuevo convenio creado
      param out mensajes : colección mensajes error
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   --INI IAXIS 4081 AABG: Se realiza insercion en nueva tabla y con los nuevos parametros
   FUNCTION f_set_datconvcomesp(
      pccodconv IN NUMBER,
      ptdesconv IN VARCHAR2,
      pfinivig IN DATE,
      pffinvig IN DATE,
      plistaprods IN t_iax_info,
      plistacomis IN t_iax_info,
      pcagente IN NUMBER,
      psperson IN VARCHAR2,
      pnnumide IN VARCHAR2,
      ptasa IN  NUMBER,
      pprima IN NUMBER,
      pprimausd IN NUMBER,
      pprimaeur IN NUMBER,
      pccodconv_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_iax_comisionegocio.f_set_datconvcomesp';
      vpar           VARCHAR2(500)
         := ' c=' || pccodconv || ' t=' || ptdesconv || ' i=' || pfinivig || ' f=' || pffinvig
            || ' age=' || pcagente || ' tom=' || psperson || ' io=' || pccodconv_out;
      num_err        NUMBER;
   BEGIN
      vpas := 1;
      num_err := pac_md_comisionegocio.f_set_datconvcomesp(pccodconv, ptdesconv, pfinivig,
                                                           pffinvig, plistaprods, plistacomis,
                                                           pcagente, psperson, pnnumide, ptasa, pprima, pprimausd, pprimaeur, pccodconv_out,
                                                           mensajes);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9904860);
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, num_err);
         --pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         ROLLBACK;
         RETURN num_err;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_datconvcomesp;
   --FIN IAXIS 4081 AABG: Se realiza insercion en nueva tabla y con los nuevos parametros

   /*************************************************************************
      Parametriza un producto como afectado por un convenio de comisión especial
      param in pccodconv : identificador del convenio
      param in plistaprods  : colección de ids de producto
      param out mensajes : colección mensajes error
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/

   /*
      FUNCTION f_set_prodconvcomesp(
         pccodconv IN NUMBER,
         plistaprods IN t_iax_info,
         mensajes OUT t_iax_mensajes)
         RETURN NUMBER IS
         vpas           NUMBER;
         vobj           VARCHAR2(500) := 'pac_iax_comisionegocio.f_set_prodconvcomesp';
         vpar           VARCHAR2(500) := 'i=' || pccodconv;
         num_err        NUMBER;
      BEGIN
         vpas := 1;
         num_err := pac_md_comisionegocio.f_set_prodconvcomesp(pccodconv, plistaprods, mensajes);

         IF num_err <> 0 THEN
            RAISE e_object_error;
         END IF;

         COMMIT;
         RETURN 0;
      EXCEPTION
         WHEN e_param_error THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
            ROLLBACK;
            RETURN 1;
         WHEN e_object_error THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
            ROLLBACK;
            RETURN 1;
         WHEN OTHERS THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                              psqcode => SQLCODE, psqerrm => SQLERRM);
            ROLLBACK;
            RETURN 1;
      END f_set_prodconvcomesp;
   */

   /*************************************************************************
      Parametriza un agente como afectado por un convenio de comisión especial
      param in pccodconv : identificador del convenio
      param in pcagente  : código de agente
      param out mensajes : colección mensajes error
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/

   /*
      FUNCTION f_set_ageconvcomesp(
         pccodconv IN NUMBER,
         pcagente IN NUMBER,
         mensajes OUT t_iax_mensajes)
         RETURN NUMBER IS
         vpas           NUMBER;
         vobj           VARCHAR2(500) := 'pac_iax_comisionegocio.f_set_ageconvcomesp';
         vpar           VARCHAR2(500) := 'i=' || pccodconv || ' a=' || pcagente;
         num_err        NUMBER;
      BEGIN
         vpas := 1;
         num_err := pac_md_comisionegocio.f_set_ageconvcomesp(pccodconv, pcagente, mensajes);

         IF num_err <> 0 THEN
            RAISE e_object_error;
         END IF;

         COMMIT;
         RETURN 0;
      EXCEPTION
         WHEN e_param_error THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
            ROLLBACK;
            RETURN 1;
         WHEN e_object_error THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
            ROLLBACK;
            RETURN 1;
         WHEN OTHERS THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                              psqcode => SQLCODE, psqerrm => SQLERRM);
            ROLLBACK;
            RETURN 1;
      END f_set_ageconvcomesp;
   */

   /*************************************************************************
      Parametriza un tomador como afectado por un convenio de comisión especial
      param in pccodconv : identificador del convenio
      param in psperson  : código del tomador
      param out mensajes : colección mensajes error
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/

   /*
      FUNCTION f_set_tomconvcomesp(
         pccodconv IN NUMBER,
         psperson IN NUMBER,
         mensajes OUT t_iax_mensajes)
         RETURN NUMBER IS
         vpas           NUMBER;
         vobj           VARCHAR2(500) := 'pac_iax_comisionegocio.f_set_tomconvcomesp';
         vpar           VARCHAR2(500) := 'i=' || pccodconv || ' s=' || psperson;
         num_err        NUMBER;
      BEGIN
         vpas := 1;
         num_err := pac_md_comisionegocio.f_set_tomconvcomesp(pccodconv, psperson, mensajes);

         IF num_err <> 0 THEN
            RAISE e_object_error;
         END IF;

         COMMIT;
         RETURN 0;
      EXCEPTION
         WHEN e_param_error THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
            ROLLBACK;
            RETURN 1;
         WHEN e_object_error THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
            ROLLBACK;
            RETURN 1;
         WHEN OTHERS THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                              psqcode => SQLCODE, psqerrm => SQLERRM);
            ROLLBACK;
            RETURN 1;
      END f_set_tomconvcomesp;
   */

   /*************************************************************************
      Recuperar la modalidad y % de comisión especial de un convenio
      param in psproduc : código del producto
      param in pcagente : código de agente
      param in psperson : código del tomador
      param in pfemisio : fecha emisión de la póliza
      return            : t_iax_gstcomision
   *************************************************************************/
   FUNCTION f_get_porcenconvcomesp(
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      psperson IN NUMBER,
      pfemisio IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_gstcomision IS
      colcom         t_iax_gstcomision;
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_iax_comisionegocio.f_get_porcenconvcomesp';
      vpar           VARCHAR2(500)
          := 'p=' || psproduc || ' a=' || pcagente || ' tom=' || psperson || ' f=' || pfemisio;
      num_err        NUMBER;
   BEGIN
      RETURN pac_md_comisionegocio.f_get_porcenconvcomesp(psproduc, pcagente, psperson,
                                                          pfemisio, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         ROLLBACK;
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN NULL;
   END f_get_porcenconvcomesp;

   /*************************************************************************
      Recuperar el siguiene código de convenio

      return  : id del convenio
   *************************************************************************/
   FUNCTION f_get_next_conv(pccodconv_out OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comisionegocio.f_get_next_conv';
      vpar           VARCHAR2(500);
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_comisionegocio.f_get_next_conv(pccodconv_out, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_next_conv;

   /*************************************************************************
      Nos devuelve si un tomador o agente tiene parametrizado un convenio
      param in pspersonton : identificador del tomador
      param in pcagente    : identificador del agente
      param out pconvenio  : 0 - no tiene conveno parametrizado 1 - Si
      return             : Codigo de error

      Bug 27327/146916 - 27/06/2013 - AMC
   *************************************************************************/
   FUNCTION f_get_tieneconvcomesp(
      pspersonton IN NUMBER,
      pcagente IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pconvenio OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_iax_comisionegocio.f_get_tieneconvcomesp';
      vpar           VARCHAR2(500)
                                  := 'pspersonton=' || pspersonton || ' pcagente=' || pcagente;
      num_err        NUMBER;
   BEGIN
      IF pspersonton IS NULL
         AND pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_md_comisionegocio.f_get_tieneconvcomesp(pspersonton, pcagente, psproduc,
                                                             pfefecto, pconvenio, mensajes);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_tieneconvcomesp;
   
  /*************************************************************************
      Obtiene la tasa o prima de un producto para un asegurado
      param in pccodconv : identificador del convenio
      param in pcnnumide  : numero identificacion asegurado
      param in pccodproducto : identificador del producto
      param in pcopcion  : opcion a consultar (1-> Tasa, 2-> Prima)
      return             : 0 si está todo Ok y 1 si existe algún tipo de error
   *************************************************************************/
   FUNCTION f_get_tasa_prima(
      pccodconv IN NUMBER, 
      pcnnumide IN NUMBER, 
      pccodproducto IN NUMBER, 
      pcopcion IN NUMBER,
      pccodgarantia IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_iax_comisionegocio.f_get_tasa_prima';
      vpar           VARCHAR2(500) := 'i=' || pccodconv || ' a=' || pcnnumide || 'c=' || pccodproducto || ' d=' || pcopcion;
      num_err        NUMBER;
   BEGIN
      vpas := 1;
      num_err := pac_md_comisionegocio.f_get_tasa_prima(pccodconv, pcnnumide, pccodproducto, pcopcion, pccodgarantia, mensajes);

      IF num_err = -1 THEN
         RAISE e_object_error;
      END IF;
      RETURN num_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         ROLLBACK;
         RETURN -1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         ROLLBACK;
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN -1;
   END f_get_tasa_prima;   
   
END pac_iax_comisionegocio;

/
