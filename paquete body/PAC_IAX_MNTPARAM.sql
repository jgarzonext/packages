--------------------------------------------------------
--  DDL for Package Body PAC_IAX_MNTPARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_MNTPARAM" AS
/******************************************************************************
   NOMBRE:      PAC_IAX_MNTPARAM
   PROPÓSITO:   Funciones para el mantenimiento de las tablas de parámetros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        28/01/2007   JAS               1. Creación del package.
   2.0        18/02/2009   AMC               2. Codificación funciones GET,SET por MOTIVO MOVIMIENTO
   3.0        12/03/2009   XCG               3. Modificación del package body:  Adaptació commit i rollback en les funcions _set_ (9325)
******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

   /*************************************************************************
      Devuelve la lista de detalles del parámetro de entrada
      param in pcparam   : código de parámetro
      param out mensajes : mensajes de error
      return             : descripción del parámetro -> Si ha ido bién
                           NULL -> Si ha ido mal
   *************************************************************************/
   FUNCTION f_get_detparam(pcparam IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vobject        VARCHAR2(500) := 'PAC_IAX_MNTPARAM.F_Get_DetParam';
      vparam         VARCHAR2(500) := 'pcparam: ' || pcparam;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vdescparam     VARCHAR2(100);
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Recuperació dels paràmetres del producte.
      vcursor := pac_md_mntparam.f_get_detparam(pcparam, mensajes);
      --Tot ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_detparam;

   /*************************************************************************
      Devuelve la descripción del parámetro de entrada
      param in pcparam   : código de parámetro
      param out mensajes : mensajes de error
      return             : descripción del parámetro -> Si ha ido bién
                           NULL -> Si ha ido mal
   *************************************************************************/
   FUNCTION f_get_descparam(pcparam IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vobject        VARCHAR2(500) := 'PAC_IAX_MNTPARAM.F_Get_DescParam';
      vparam         VARCHAR2(500) := 'parámetros - pcparam: ' || pcparam;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vdescparam     VARCHAR2(100);
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Recuperació dels paràmetres del producte.
      vdescparam := pac_md_mntparam.f_get_descparam(pcparam, pac_md_common.f_get_cxtidioma,
                                                    mensajes);
      --Tot ok
      RETURN vdescparam;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_descparam;

-- ===========================================================================
--  P A R A M E T R O S  C O N E X I O N
-- ===========================================================================
    /*************************************************************************
       Devuelve la lista de parámetros de CONEXION
       param out mensajes : mensajes de error
       return             : descripción del parámetro -> Si ha ido bién
                            NULL -> Si ha ido mal
    *************************************************************************/
   FUNCTION f_get_conparam(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPARAM.F_Get_ConParam';
   BEGIN
      vpasexec := 3;
      --Recuperació dels paràmetres del producte.
      vcursor := pac_md_mntparam.f_get_conparam(mensajes);
      --Tot ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_conparam;

   /*************************************************************************
      Modifica el valor de un parámetro de CONEXION
      param in  pcparam  : codigo parametro
      param in  pcvalpar : valor numérico parametro
      param in  ptvalpar : valor texto parametro
      param in  pfvalpar : valor fecha parametro
      param out mensajes : mensajes de error
      return             : 0 -> Si ha ido bién
                           1 -> Si ha ido mal
   *************************************************************************/
   FUNCTION f_set_conparam(
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcparam=' || pcparam || ', pcvalpar=' || pcvalpar || ', ptvalpar=' || ptvalpar
            || ', pfvalpar=' || pfvalpar;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPARAM.F_Set_ConParam';
   BEGIN
      -- Verificación de los parámetros
      IF pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcvalpar IS NOT NULL
         AND ptvalpar IS NOT NULL THEN
         RAISE e_param_error;
      END IF;

      IF ptvalpar IS NOT NULL
         AND pfvalpar IS NOT NULL THEN
         RAISE e_param_error;
      END IF;

      IF pfvalpar IS NOT NULL
         AND pcvalpar IS NOT NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcvalpar IS NULL
         AND ptvalpar IS NULL
         AND pfvalpar IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntparam.f_set_conparam(pcparam, pcvalpar, ptvalpar, pfvalpar,
                                                mensajes);

      IF vnumerr <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      END IF;

      COMMIT;
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
   END f_set_conparam;

   /*************************************************************************
      Elimina un parámetro de CONEXION
      param in  pcparam  : codigo parametro
      param out mensajes : mensajes de error
      return             : 0 -> Si ha ido bién
                           1 -> Si ha ido mal
   *************************************************************************/
   FUNCTION f_set_elimconparam(pcparam IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcparam=' || pcparam;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPARAM.F_Set_ElimConParam';
   BEGIN
      -- Verificación de los parámetros
      IF pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntparam.f_set_elimconparam(pcparam, mensajes);

      IF vnumerr <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      END IF;

      COMMIT;
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
   END f_set_elimconparam;

-- ===========================================================================
--  P A R A M E T R O S  I N S T A L A C I O N
-- ===========================================================================
    /*************************************************************************
       Devuelve la lista de parámetros de INSTALACION
       param out mensajes : mensajes de error
       return             : descripción del parámetro -> Si ha ido bién
                            NULL -> Si ha ido mal
    *************************************************************************/
   FUNCTION f_get_insparam(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPARAM.F_Get_InsParam';
   BEGIN
      vpasexec := 3;
      --Recuperació dels paràmetres del producte.
      vcursor := pac_md_mntparam.f_get_insparam(mensajes);
      --Tot ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_insparam;

   /*************************************************************************
      Modifica el valor de un parámetro de INSTALACION
      param in  pcparam  : codigo parametro
      param in  pcvalpar : valor numérico parametro
      param in  ptvalpar : valor texto parametro
      param in  pfvalpar : valor fecha parametro
      param out mensajes : mensajes de error
      return             : 0 -> Si ha ido bién
                           1 -> Si ha ido mal
   *************************************************************************/
   FUNCTION f_set_insparam(
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcparam=' || pcparam || ', pcvalpar=' || pcvalpar || ', ptvalpar=' || ptvalpar
            || ', pfvalpar=' || pfvalpar;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPARAM.F_Set_InsParam';
   BEGIN
      -- Verificación de los parámetros
      IF pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcvalpar IS NOT NULL
         AND ptvalpar IS NOT NULL THEN
         RAISE e_param_error;
      END IF;

      IF ptvalpar IS NOT NULL
         AND pfvalpar IS NOT NULL THEN
         RAISE e_param_error;
      END IF;

      IF pfvalpar IS NOT NULL
         AND pcvalpar IS NOT NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcvalpar IS NULL
         AND ptvalpar IS NULL
         AND pfvalpar IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntparam.f_set_insparam(pcparam, pcvalpar, ptvalpar, pfvalpar,
                                                mensajes);

      IF vnumerr <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      END IF;

      COMMIT;
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
   END f_set_insparam;

   /*************************************************************************
      Elimina un parámetro de INSTALACION
      param in  pcparam  : codigo parametro
      param out mensajes : mensajes de error
      return             : 0 -> Si ha ido bién
                           1 -> Si ha ido mal
   *************************************************************************/
   FUNCTION f_set_eliminsparam(pcparam IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcparam=' || pcparam;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPARAM.F_Set_ElimInsParam';
   BEGIN
      -- Verificación de los parámetros
      IF pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntparam.f_set_eliminsparam(pcparam, mensajes);

      IF vnumerr <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      END IF;

      COMMIT;
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
   END f_set_eliminsparam;

-- ===========================================================================
--  P A R A M E T R O S  E M P R E S A
-- ===========================================================================
    /*************************************************************************
       Devuelve la lista de parámetros de EMPRESA
       param in pcempres  : codigo de la empresa
       param out mensajes : mensajes de error
       return             : descripción del parámetro -> Si ha ido bién
                            NULL -> Si ha ido mal
    *************************************************************************/
   FUNCTION f_get_empparam(pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcempres=' || pcempres;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPARAM.F_Set_EmpParam';
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Recuperació dels paràmetres del producte.
      vcursor := pac_md_mntparam.f_get_empparam(pcempres, mensajes);
      --Tot ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_empparam;

   /*************************************************************************
      Modifica el valor de un parámetro de EMPRESA
      param in  pcempres : codigo empresa
      param in  pcparam  : codigo parametro
      param in  pcvalpar : valor numérico parametro
      param in  ptvalpar : valor texto parametro
      param in  pfvalpar : valor fecha parametro
      param out mensajes : mensajes de error
      return             : 0 -> Si ha ido bién
                           1 -> Si ha ido mal
   *************************************************************************/
   FUNCTION f_set_empparam(
      pcempres IN NUMBER,
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcempres=' || pcempres || ', pcparam=' || pcparam || ', pcvalpar=' || pcvalpar
            || ', ptvalpar=' || ptvalpar || ', pfvalpar=' || pfvalpar;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPARAM.F_Set_EmpParam';
   BEGIN
      -- Verificación de los parámetros
      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcvalpar IS NOT NULL
         AND ptvalpar IS NOT NULL THEN
         RAISE e_param_error;
      END IF;

      IF ptvalpar IS NOT NULL
         AND pfvalpar IS NOT NULL THEN
         RAISE e_param_error;
      END IF;

      IF pfvalpar IS NOT NULL
         AND pcvalpar IS NOT NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcvalpar IS NULL
         AND ptvalpar IS NULL
         AND pfvalpar IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntparam.f_set_empparam(pcempres, pcparam, pcvalpar, ptvalpar,
                                                pfvalpar, mensajes);

      IF vnumerr <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      END IF;

      COMMIT;
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
   END f_set_empparam;

   /*************************************************************************
      Elimina un parámetro de EMPRESA
      param in  pcempres : codigo empresa
      param in  pcparam  : codigo parametro
      param out mensajes : mensajes de error
      return             : 0 -> Si ha ido bién
                           1 -> Si ha ido mal
   *************************************************************************/
   FUNCTION f_set_elimempparam(
      pcempres IN NUMBER,
      pcparam IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pcempres=' || pcempres || ', pcparam=' || pcparam;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPARAM.F_Set_ElimEmpParam';
   BEGIN
      -- Verificación de los parámetros
      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntparam.f_set_elimempparam(pcempres, pcparam, mensajes);

      IF vnumerr <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      END IF;

      COMMIT;
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
   END f_set_elimempparam;

-- ===========================================================================
--  P A R A M E T R O S  P R O D U C T O
-- ===========================================================================
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Autor: Jordi Azorín (01/04/2004)
    Descripción: Recupera los parámetros de producto del producto pasado por parámetro
    Parámetros entrada: psproduc    -> Código del producto
    Parámetros salida:  mensajes    -> Mensajes de error
    Retorno:            RefCursor   -> Parametros del producto
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   FUNCTION f_get_prodparam(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPARAM.F_Get_ProdParam';
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Recuperació dels paràmetres del producte.
      vcursor := pac_md_mntparam.f_get_prodparam(psproduc, mensajes);
      --Tot ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_prodparam;

   /*************************************************************************
      Modifica el valor de un parámetro de PRODUCTO
      param in  psproduc : codigo producto
      param in  pcparam  : codigo parametro
      param in  pcvalpar : valor numérico parametro
      param in  ptvalpar : valor texto parametro
      param in  pfvalpar : valor fecha parametro
      param out mensajes : mensajes de error
      return             : 0 -> Si ha ido bién
                           1 -> Si ha ido mal
   *************************************************************************/
   FUNCTION f_set_prodparam(
      psproduc IN NUMBER,
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'psproduc=' || psproduc || ', pcparam=' || pcparam || ', pcvalpar=' || pcvalpar
            || ', ptvalpar=' || ptvalpar || ', pfvalpar=' || pfvalpar;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPARAM.F_Set_ProdParam';
   BEGIN
      -- Verificación de los parámetros
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcvalpar IS NOT NULL
         AND ptvalpar IS NOT NULL THEN
         RAISE e_param_error;
      END IF;

      IF ptvalpar IS NOT NULL
         AND pfvalpar IS NOT NULL THEN
         RAISE e_param_error;
      END IF;

      IF pfvalpar IS NOT NULL
         AND pcvalpar IS NOT NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcvalpar IS NULL
         AND ptvalpar IS NULL
         AND pfvalpar IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntparam.f_set_prodparam(psproduc, pcparam, pcvalpar, ptvalpar,
                                                 pfvalpar, mensajes);

      IF vnumerr <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      END IF;

      COMMIT;
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
   END f_set_prodparam;

   /*************************************************************************
      Elimina un parámetro de PRODUCTO
      param in  psproduc : codigo producto
      param in  pcparam  : codigo parametro
      param out mensajes : mensajes de error
      return             : 0 -> Si ha ido bién
                           1 -> Si ha ido mal
   *************************************************************************/
   FUNCTION f_set_elimprodparam(
      psproduc IN NUMBER,
      pcparam IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psproduc=' || psproduc || ', pcparam=' || pcparam;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPARAM.F_Set_ElimProdParam';
   BEGIN
      -- Verificación de los parámetros
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntparam.f_set_elimprodparam(psproduc, pcparam, mensajes);

      IF vnumerr <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      END IF;

      COMMIT;
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
   END f_set_elimprodparam;

-- ===========================================================================
--  P A R A M E T R O S  A C T I V I D A D
-- ===========================================================================
    /*************************************************************************
       Devuelve la lista de parámetros de ACTIVIDAD
       param in psproduc  : codigo producto
       param in pcactivi  : codigo actividad
       param out mensajes : mensajes de error
       return             : descripción del parámetro -> Si ha ido bién
                            NULL -> Si ha ido mal
    *************************************************************************/
   FUNCTION f_get_actparam(psproduc IN NUMBER, pcactivi IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psproduc=' || psproduc || ', pcactivi=' || pcactivi;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPARAM.F_Get_ActParam';
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Recuperació dels paràmetres del producte.
      vcursor := pac_md_mntparam.f_get_actparam(psproduc, pcactivi, mensajes);
      --Tot ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_actparam;

   /*************************************************************************
      Modifica el valor de un parámetro de ACTIVIDAD
      param in  psproduc : codigo producto
      param in  pcactivi : codigo actividad
      param in  pcparam  : codigo parametro
      param in  pcvalpar : valor numérico parametro
      param in  ptvalpar : valor texto parametro
      param in  pfvalpar : valor fecha parametro
      param out mensajes : mensajes de error
      return             : 0 -> Si ha ido bién
                           1 -> Si ha ido mal
   *************************************************************************/
   FUNCTION f_set_actparam(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'psproduc=' || psproduc || ', pcactivi=' || pcactivi || ', pcparam=' || pcparam
            || ', pcvalpar=' || pcvalpar || ', ptvalpar=' || ptvalpar || ', pfvalpar='
            || pfvalpar;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPARAM.F_Set_ActParam';
   BEGIN
      -- Verificación de los parámetros
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF pcvalpar IS NOT NULL
         AND ptvalpar IS NOT NULL THEN
         RAISE e_param_error;
      END IF;

      IF ptvalpar IS NOT NULL
         AND pfvalpar IS NOT NULL THEN
         RAISE e_param_error;
      END IF;

      IF pfvalpar IS NOT NULL
         AND pcvalpar IS NOT NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcvalpar IS NULL
         AND ptvalpar IS NULL
         AND pfvalpar IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 5;
      vnumerr := pac_md_mntparam.f_set_actparam(psproduc, pcactivi, pcparam, pcvalpar,
                                                ptvalpar, pfvalpar, mensajes);

      IF vnumerr <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      END IF;

      COMMIT;
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
   END f_set_actparam;

   /*************************************************************************
      Elimina un parámetro de ACTIVIDAD
      param in  psproduc : codigo producto
      param in  pcactivi : codigo actividad
      param in  pcparam  : codigo parametro
      param out mensajes : mensajes de error
      return             : 0 -> Si ha ido bién
                           1 -> Si ha ido mal
   *************************************************************************/
   FUNCTION f_set_elimactparam(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcparam IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
            := 'psproduc=' || psproduc || ', pcactivi=' || pcactivi || ', pcparam=' || pcparam;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPARAM.F_Set_ElimActParam';
   BEGIN
      -- Verificación de los parámetros
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntparam.f_set_elimactparam(psproduc, pcactivi, pcparam, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
         ROLLBACK;
      END IF;

      COMMIT;
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
   END f_set_elimactparam;

   /*************************************************************************
       OJO!! Esta función no tiene réplica en PAC_MD_MNTPARAM
       Va contra PAC_MDPAR_PRODUCTOS
      Devuelve la lista de ACTIVIDADES de un PRODUCTO
      param in psproduc  : codigo producto
      param out mensajes : mensajes de error
      return             : actividades del producto -> Si ha ido bién
                           NULL -> Si ha ido mal
   *************************************************************************/
   FUNCTION f_get_actprod(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iaxpar_actividades IS
      activ          t_iaxpar_actividades;
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPARAM.F_Get_ActProd';
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Recuperació de las actividades del producte.
      activ := pac_mdpar_productos.f_get_actividades(psproduc, mensajes);
      --Tot ok
      RETURN activ;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN activ;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN activ;
   END f_get_actprod;

-- ===========================================================================
--  P A R A M E T R O S  G A R A N T I A
-- ===========================================================================
    /*************************************************************************
       Devuelve la lista de parametros por GARANTIA/ACTIVIDAD/PRODUCTO
       param in psproduc  : codigo producto
       param in pcactivi  : codigo actividad
       param in pcgarant  : codigo garantia
       param out mensajes : mensajes de error
       return             : parametros de la garantia -> Si ha ido bién
                            NULL -> Si ha ido mal
    *************************************************************************/
   FUNCTION f_get_garparam(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
          := 'psproduc=' || psproduc || ', pcactivi=' || pcactivi || ', pcgarant=' || pcgarant;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPARAM.F_Get_GarParam';
   BEGIN
      --Comprovació de paràmetres d'entrada
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Recuperació dels paràmetres del producte.
      vcursor := pac_md_mntparam.f_get_garparam(psproduc, pcactivi, pcgarant, mensajes);
      --Tot ok
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_garparam;

   /*************************************************************************
      Modifica el valor de un parámetro de GARANTIA
      param in  psproduc : codigo producto
      param in  pcactivi : codigo actividad
      param in  pcgarant : codigo garantia
      param in  pcparam  : codigo parametro
      param in  pcvalpar : valor numérico parametro
      param in  ptvalpar : valor texto parametro
      param in  pfvalpar : valor fecha parametro
      param out mensajes : mensajes de error
      return             : 0 -> Si ha ido bién
                           1 -> Si ha ido mal
   *************************************************************************/
   FUNCTION f_set_garparam(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'psproduc=' || psproduc || ', pcactivi=' || pcactivi || ', pcgarant=' || pcgarant
            || ', pcparam=' || pcparam || ', pcvalpar=' || pcvalpar || ', ptvalpar='
            || ptvalpar || ', pfvalpar=' || pfvalpar;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPARAM.F_Set_GarParam';
   BEGIN
      -- Verificación de los parámetros
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcvalpar IS NOT NULL
         AND ptvalpar IS NOT NULL THEN
         RAISE e_param_error;
      END IF;

      IF ptvalpar IS NOT NULL
         AND pfvalpar IS NOT NULL THEN
         RAISE e_param_error;
      END IF;

      IF pfvalpar IS NOT NULL
         AND pcvalpar IS NOT NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcvalpar IS NULL
         AND ptvalpar IS NULL
         AND pfvalpar IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntparam.f_set_garparam(psproduc, pcactivi, pcgarant, pcparam,
                                                pcvalpar, ptvalpar, pfvalpar, mensajes);

      IF vnumerr <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      END IF;

      COMMIT;
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
   END f_set_garparam;

   /*************************************************************************
      Elimina un parámetro de GARANTIA
      param in  psproduc : codigo producto
      param in  pcactivi : codigo actividad
      param in  pcgarant : codigo garantia
      param in  pcparam  : codigo parametro
      param out mensajes : mensajes de error
      return             : 0 -> Si ha ido bién
                           1 -> Si ha ido mal
   *************************************************************************/
   FUNCTION f_set_elimgarparam(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcparam IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'psproduc=' || psproduc || ', pcactivi=' || pcactivi || ', pcgarant=' || pcgarant
            || ', pcparam=' || pcparam;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPARAM.F_Set_ElimGarParam';
   BEGIN
      -- Verificación de los parámetros
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntparam.f_set_elimgarparam(psproduc, pcactivi, pcgarant, pcparam,
                                                    mensajes);

      IF vnumerr <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      END IF;

      COMMIT;
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
   END f_set_elimgarparam;

-- ===========================================================================
--  P A R A M E T R O S  POR MOTIVO MOVIMIENTO
-- ===========================================================================
    /*************************************************************************
       Devuelve la lista de parametros por MOVIMIENTO/PRODUCTO
       param in psproduc  : codigo producto
       param in pcmotmov  : codigo movimiento
       param out mensajes : mensajes de error
       return             : parametros de la garantia -> Si ha ido bién
                            NULL -> Si ha ido mal
    *************************************************************************/
   FUNCTION f_get_movparam(psproduc IN NUMBER, pcmotmov IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vcursor        sys_refcursor;
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psproduc=' || psproduc || ', pcmotmov=' || pcmotmov;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPARAM.F_Get_MovParam';
   BEGIN
      vpasexec := 1;
      -- BUG 8789 - Fecha 18/02/2009 - AMC - Recuperació dels paràmetres del producte.”
      vcursor := pac_md_mntparam.f_get_movparam(psproduc, pcmotmov, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_movparam;

   /*************************************************************************
      Elimina un parametro por MOVIMIENTO/PRODUCTO
      param in psproduc  : codigo producto
      param in pcmotmov  : codigo movimiento
      param in pcparmot  : codigo motivo
      param out mensajes : mensajes de error
      return             : 0 -> Si ha ido bién
                           1 -> Si ha ido mal
   *************************************************************************/
   FUNCTION f_set_elimmovparam(
      psproduc IN NUMBER,
      pcmotmov IN NUMBER,
      pcparmot IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
           := 'psproduc=' || psproduc || ', pcmotmov=' || pcmotmov || ' pcparmot=' || pcparmot;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPARAM.F_Set_ElimMovParam';
   BEGIN
      -- BUG 8789 - Fecha 18/02/2009 - AMC - Verificación de los parámetros”
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcmotmov IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcparmot IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntparam.f_set_elimmovparam(psproduc, pcmotmov, pcparmot, mensajes);

      IF vnumerr <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      END IF;

      COMMIT;
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
   END f_set_elimmovparam;

   /*************************************************************************
      Modifica el valor de un parámetro de EMPRESA
      param in  pcempres : codigo empresa
      param in  pcparam  : codigo parametro
      param in  pcvalpar : valor numérico parametro
      param in  ptvalpar : valor texto parametro
      param in  pfvalpar : valor fecha parametro
      param out mensajes : mensajes de error
      return             : 0 -> Si ha ido bién
                           1 -> Si ha ido mal
   *************************************************************************/
   FUNCTION f_set_motmovparam(
      psproduc IN NUMBER,
      pcmotmov IN NUMBER,
      pcparam IN VARCHAR2,
      pcvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'psproduc=' || psproduc || ', pcparam=' || pcparam || ', pcmotmov=' || pcmotmov
            || ', pcvalpar=' || pcvalpar || ', ptvalpar=' || ptvalpar || ', pfvalpar='
            || pfvalpar;
      vobject        VARCHAR2(200) := 'PAC_IAX_MNTPARAM.F_Set_MotMovParam';
   BEGIN
      -- BUG 8789 - Fecha 18/02/2009 - AMC - Verificación de los parámetros”
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcmotmov IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcparam IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcvalpar IS NOT NULL
         AND ptvalpar IS NOT NULL THEN
         RAISE e_param_error;
      END IF;

      IF ptvalpar IS NOT NULL
         AND pfvalpar IS NOT NULL THEN
         RAISE e_param_error;
      END IF;

      IF pfvalpar IS NOT NULL
         AND pcvalpar IS NOT NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcvalpar IS NULL
         AND ptvalpar IS NULL
         AND pfvalpar IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_mntparam.f_set_motmovparam(psproduc, pcmotmov, pcparam, pcvalpar,
                                                   ptvalpar, pfvalpar, mensajes);

      IF vnumerr <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      END IF;

      COMMIT;
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
   END f_set_motmovparam;
END pac_iax_mntparam;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_MNTPARAM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MNTPARAM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MNTPARAM" TO "PROGRAMADORESCSI";
