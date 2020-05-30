--------------------------------------------------------
--  DDL for Package Body PAC_MD_ECO_MONEDAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_ECO_MONEDAS" AS
/******************************************************************************
   NOMBRE:       PAC_MD_ADMIN
   PROPÓSITO: Funciones para consultas recibos
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        18/06/2008   JMR               1. Creación del package.

******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_obtener_moneda_seguro2(
      psseguro IN seguros.sseguro%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN eco_codmonedas.cmoneda%TYPE IS
      vobjectname    VARCHAR2(500) := 'pac_md_eco_monedas.f_obtener_moneda_seguro2';
      vparam         VARCHAR2(500) := 'parámetros - psseguro: ' || psseguro;
      vpasexec       NUMBER(5) := 100;
      vret           eco_codmonedas.cmoneda%TYPE := NULL;
   BEGIN
      vpasexec := 101;

      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 102;
      vret := pac_eco_monedas.f_obtener_moneda_seguro2(psseguro);
      vpasexec := 103;

      IF vret IS NULL THEN
         RAISE e_object_error;
      END IF;

      RETURN vret;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_obtener_moneda_seguro2;

   FUNCTION f_obtener_moneda_producto2(
      psproduc IN productos.sproduc%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN eco_codmonedas.cmoneda%TYPE IS
      vobjectname    VARCHAR2(500) := 'pac_md_eco_monedas.f_obtener_moneda_producto2';
      vparam         VARCHAR2(500) := 'parámetros - psproduc: ' || psproduc;
      vpasexec       NUMBER(5) := 100;
      vret           eco_codmonedas.cmoneda%TYPE := NULL;
   BEGIN
      vpasexec := 101;

      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 102;
      vret := pac_eco_monedas.f_obtener_moneda_producto2(psproduc);
      vpasexec := 103;

      IF vret IS NULL THEN
         RAISE e_object_error;
      END IF;

      RETURN vret;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_obtener_moneda_producto2;

   FUNCTION f_obtener_cmonint(pmoneda IN monedas.cmoneda%TYPE, mensajes IN OUT t_iax_mensajes)
      RETURN monedas.cmonint%TYPE IS
      vobjectname    VARCHAR2(500) := 'pac_md_eco_monedas.f_obtener_cmonint';
      vparam         VARCHAR2(500) := 'parámetros - pmoneda: ' || pmoneda;
      vpasexec       NUMBER(5) := 100;
      vret           monedas.cmonint%TYPE := NULL;
   BEGIN
      vpasexec := 101;

      IF pmoneda IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 102;
      vret := pac_eco_monedas.f_obtener_cmonint(pmoneda);
      vpasexec := 103;

      IF vret IS NULL THEN
         RAISE e_object_error;
      END IF;

      RETURN vret;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_obtener_cmonint;

   FUNCTION f_obtener_cmoneda(pmoneda IN monedas.cmonint%TYPE, mensajes IN OUT t_iax_mensajes)
      RETURN monedas.cmoneda%TYPE IS
      vobjectname    VARCHAR2(500) := 'pac_md_eco_monedas.f_obtener_cmoneda';
      vparam         VARCHAR2(500) := 'parámetros - pmoneda: ' || pmoneda;
      vpasexec       NUMBER(5) := 100;
      vret           monedas.cmoneda%TYPE := NULL;
   BEGIN
      vpasexec := 101;

      IF pmoneda IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 102;
      vret := pac_eco_monedas.f_obtener_cmoneda(pmoneda);
      vpasexec := 103;

      IF vret IS NULL THEN
         RAISE e_object_error;
      END IF;

      RETURN vret;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_obtener_cmoneda;
END pac_md_eco_monedas;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_ECO_MONEDAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_ECO_MONEDAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_ECO_MONEDAS" TO "PROGRAMADORESCSI";
