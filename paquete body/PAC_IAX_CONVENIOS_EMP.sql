--------------------------------------------------------
--  DDL for Package Body PAC_IAX_CONVENIOS_EMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_CONVENIOS_EMP" IS
         /******************************************************************************
      --      NOMBRE:       PAC_MD_CONVENIOS_EMP
            PROPOSITO: Tratamiento convenios en capa presentación

            REVISIONES:
            Ver        Fecha        Autor             Descripcion
            ---------  ----------  ---------------  ------------------------------------
            1.0        04/02/2015   JRH                1. Creacion del package.
   *****************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;
   vg_idioma      NUMBER := pac_md_common.f_get_cxtidioma;
   vpmode         VARCHAR2(3);
   vsolicit       NUMBER;
   vnmovimi       NUMBER;

/***********************************************************************
      Devuelve  los tramos de regularización para la consulta de detalle de  movimiento
         param in psseguro  : Número interno de seguro
       param in pnmovimi  : Número interno de pnmovimi
                mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_get_tramosregul(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psseguro: ' || psseguro || ', pnmovimi: ' || pnmovimi;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONVENIOS_EMP.f_get_tramosregul';
      cur            sys_refcursor;
      squery         VARCHAR2(2000);
   BEGIN
      IF psseguro IS NULL
         OR pnmovimi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      cur := pac_md_convenios_emp.f_get_tramosregul(psseguro, pnmovimi, mensajes);
      vpasexec := 3;
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tramosregul;

   /***********************************************************************
      Devuelve  los datos del suplemento de regularización
         param in psseguro  : Número interno de seguro
       param in pnmovimi  : Número interno de pnmovimi
                mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_datos_sup_regul(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psseguro: ' || psseguro || ', pnmovimi: ' || pnmovimi;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONVENIOS_EMP.f_datos_sup_regul';
      cur            sys_refcursor;
      squery         VARCHAR2(2000);
   BEGIN
      IF psseguro IS NULL
         OR pnmovimi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      cur := pac_md_convenios_emp.f_datos_sup_regul(psseguro, pnmovimi, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_datos_sup_regul;

   /***********************************************************************
       Devuelve  los ámbitos de convenios para el producto
          param in psproduc  :  Producto
        param in pdescri  :  Descripción
                 mensajes : mensajes de error
       return             : number
    ***********************************************************************/
   FUNCTION f_get_lstambitos(
      psproduc IN NUMBER,
      pdescri IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psproduc: ' || psproduc || ', pdescri: ' || pdescri;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONVENIOS_EMP.f_get_lstambitos';
      cur            sys_refcursor;
      squery         VARCHAR2(2000);
   BEGIN
      --IF psproduc IS NULL THEN
      --   RAISE e_param_error;
      --END IF;
      vpasexec := 2;
      cur := pac_md_convenios_emp.f_get_lstambitos(psproduc, pdescri, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstambitos;

   /***********************************************************************
      Devuelve  los convenios activos para el producto
         param in psproduc  :  Producto y Provincia
       param in pdescri  :  Descripción
                mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_get_lstconvempvers(
      psproduc IN NUMBER,
      pprovin IN NUMBER,
      pdescri IN VARCHAR2,
      ptcodconv IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_convempvers IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psproduc: ' || psproduc || ', pprovin: ' || pprovin;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONVENIOS_EMP.f_get_lstconvempvers';
      vvers          t_iax_convempvers;
   BEGIN
      IF pprovin IS NULL
         AND ptcodconv IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vvers := pac_md_convenios_emp.f_get_lstconvempvers(psproduc, pprovin, pdescri, ptcodconv,
                                                         mensajes);
      vpasexec := 3;
      RETURN vvers;
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
   END f_get_lstconvempvers;

      /***********************************************************************
      Graba el convenio y valida en la propuesta (pantalla de datos de gestión o simulación).
         param in pversion  :  Versión
       param out  mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_get_grabarconvempvers(pversion IN ob_iax_convempvers, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_CONVENIOS_EMP.F_GET_GRABARCONVEMPVERS';
      vvers          t_iax_convempvers;
      vdet_poliza    ob_iax_detpoliza;
   BEGIN
      IF pversion IS NULL THEN
         RAISE e_param_error;
      END IF;

--
    --  PAC_CONVENIOS_EMP.F_GET_CONVCONTRATABLE (pversion);
      vdet_poliza := pac_iobj_prod.f_getpoliza(mensajes);
      vdet_poliza.convempvers := pversion;
      vpasexec := 2;
       --JRH IMP Falta la validación pendiente de CROSS
      -- vvers := pac_md_convenios_emp.f_get_lstconvempvers(psproduc, psproduc, pdescri, mensajes);
      vpasexec := 3;
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
   END f_get_grabarconvempvers;

   FUNCTION f_proceso_camb_verscon(
      ptcodconv IN VARCHAR2,
      pcidioma IN NUMBER,
      psproces OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                               := 'param - Convenio: ' || ptcodconv || ' Idioma: ' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONVENIOS_EMP.F_PROCESO_CAMB_VERSCON';
      num_err        NUMBER;
      vesaviso       NUMBER;
   BEGIN
      --
      num_err := pac_md_convenios_emp.f_proceso_camb_verscon(ptcodconv, pcidioma, psproces,
                                                             mensajes);

      IF num_err <> 0 THEN
         ROLLBACK;
         RETURN 1;
      END IF;

      COMMIT;
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_proceso_camb_verscon;

   FUNCTION f_proceso_anul_verscon(
      ptcodconv IN VARCHAR2,
      pcidioma IN NUMBER,
      psproces OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                               := 'param - Convenio: ' || ptcodconv || ' Idioma: ' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONVENIOS_EMP.F_PROCESO_ANUL_VERSCON';
      num_err        NUMBER;
      vesaviso       NUMBER;
   BEGIN
      --
      num_err := pac_md_convenios_emp.f_proceso_anul_verscon(ptcodconv, pcidioma, psproces,
                                                             mensajes);

      IF num_err <> 0 THEN
         ROLLBACK;
         RETURN 1;
      END IF;

      COMMIT;
      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_proceso_anul_verscon;

   /***********************************************************************
      Devuelve un sys_refcursor con los asegurados de un riesgo
      param in pversion  :  VersiÃ³n
      param out  mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_get_asegurados_innom(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnombre IN VARCHAR2,
      pnmovimi IN NUMBER,
      pfecha IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONVENIOS_EMP.F_GET_ASEGURADOS_INNOM';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_convenios_emp.f_get_asegurados_innom(psseguro, pnriesgo, pnombre, pnmovimi,
                                                         pfecha, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_asegurados_innom;

   /***********************************************************************
      Devuelve  los convenios activos para el producto
         param in psproduc  :  Producto y Provincia
       param in pdescri  :  Descripción
                mensajes : mensajes de error
      return             : number
      Bug 34461-210152 KJSC Por medio de email enviado el 28/07/2015 de Jordi Vidal se crea nueva funcion
   ***********************************************************************/
   FUNCTION f_get_lstconvemp(
      psproduc IN NUMBER,
      pprovin IN NUMBER,
      pdescri IN VARCHAR2,
      ptcodconv IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_convempvers IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psproduc: ' || psproduc || ', pprovin: ' || pprovin;
      vobject        VARCHAR2(200) := 'PAC_IAX_CONVENIOS_EMP.f_get_lstconvemp';
      vvers          t_iax_convempvers;
   BEGIN
      vpasexec := 2;
      vvers := pac_md_convenios_emp.f_get_lstconvemp(psproduc, pprovin, pdescri, ptcodconv,
                                                     mensajes);
      vpasexec := 3;
      RETURN vvers;
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
   END f_get_lstconvemp;
END pac_iax_convenios_emp;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_CONVENIOS_EMP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CONVENIOS_EMP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CONVENIOS_EMP" TO "PROGRAMADORESCSI";
