--------------------------------------------------------
--  DDL for Package Body PAC_IAX_AGE_DATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_AGE_DATOS" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_AGE_DATOS
   PROPÓSITO: Funciones para gestionar Más datos de agentes

   REVISIONES:
   Ver        Fecha        Autor       Descripción
   ---------  ----------  ---------  ------------------------------------
   1.0        13/03/2012  MDS        1. Creación del package.

******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
    Nueva función que se encarga de borrar un registro de Banco
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_banco(
      pcagente IN age_bancos.cagente%TYPE,
      pctipbanco IN age_bancos.ctipbanco%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                     := 'parámetros - pcagente: ' || pcagente || ' pctipbanco: ' || pctipbanco;
      vobject        VARCHAR2(200) := 'PAC_IAX_AGE_DATOS.f_del_banco';
   BEGIN
      IF pcagente IS NULL
         OR pctipbanco IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_age_datos.f_del_banco(pcagente, pctipbanco, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_banco;

   /*************************************************************************
    Nueva función que se encarga de insertar un registro de Banco
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_banco(
      pcagente IN age_bancos.cagente%TYPE,
      pctipbanco IN age_bancos.ctipbanco%TYPE,
      pctipbanco_orig IN age_bancos.ctipbanco%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                     := 'parámetros - pcagente: ' || pcagente || ' pctipbanco: ' || pctipbanco;
      vobject        VARCHAR2(200) := 'PAC_IAX_AGE_DATOS.f_set_banco';
   BEGIN
      IF pcagente IS NULL
         OR pctipbanco IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_age_datos.f_set_banco(pcagente, pctipbanco, pctipbanco_orig, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_banco;

   /*************************************************************************
    Nueva función que se encarga de borrar un registro de Otra entidad aseguradora
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_entidadaseg(
      pcagente IN age_entidadesaseg.cagente%TYPE,
      pctipentidadaseg IN age_entidadesaseg.ctipentidadaseg%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - pcagente: ' || pcagente || ' pctipentidadaseg: ' || pctipentidadaseg;
      vobject        VARCHAR2(200) := 'PAC_IAX_AGE_DATOS.f_del_entidadaseg';
   BEGIN
      IF pcagente IS NULL
         OR pctipentidadaseg IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_age_datos.f_del_entidadaseg(pcagente, pctipentidadaseg, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_entidadaseg;

   /*************************************************************************
    Nueva función que se encarga de insertar un registro de Otra entidad aseguradora
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_entidadaseg(
      pcagente IN age_entidadesaseg.cagente%TYPE,
      pctipentidadaseg IN age_entidadesaseg.ctipentidadaseg%TYPE,
      pctipentidadaseg_orig IN age_entidadesaseg.ctipentidadaseg%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - pcagente: ' || pcagente || ' pctipentidadaseg: ' || pctipentidadaseg;
      vobject        VARCHAR2(200) := 'PAC_IAX_AGE_DATOS.f_set_entidadaseg';
   BEGIN
      IF pcagente IS NULL
         OR pctipentidadaseg IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_age_datos.f_set_entidadaseg(pcagente, pctipentidadaseg,
                                                    pctipentidadaseg_orig, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_entidadaseg;

   /*************************************************************************
    Nueva función que se encarga de borrar un registro de Asociación
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_asociacion(
      pcagente IN age_asociaciones.cagente%TYPE,
      pctipasociacion IN age_asociaciones.ctipasociacion%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
           := 'parámetros - pcagente: ' || pcagente || ' pctipasociacion: ' || pctipasociacion;
      vobject        VARCHAR2(200) := 'PAC_IAX_AGE_DATOS.f_del_asociacion';
   BEGIN
      IF pcagente IS NULL
         OR pctipasociacion IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_age_datos.f_del_asociacion(pcagente, pctipasociacion, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_asociacion;

   /*************************************************************************
    Nueva función que se encarga de insertar un registro de Asociación
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_asociacion(
      pcagente IN age_asociaciones.cagente%TYPE,
      pctipasociacion IN age_asociaciones.ctipasociacion%TYPE,
      pnumcolegiado IN age_asociaciones.numcolegiado%TYPE,
      pctipasociacion_orig IN age_asociaciones.ctipasociacion%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - pcagente: ' || pcagente || ' pctipasociacion: ' || pctipasociacion
            || ' pnumcolegiado: ' || pnumcolegiado;
      vobject        VARCHAR2(200) := 'PAC_IAX_AGE_DATOS.f_set_asociacion';
   BEGIN
      IF pcagente IS NULL
         OR pctipasociacion IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_age_datos.f_set_asociacion(pcagente, pctipasociacion, pnumcolegiado,
                                                   pctipasociacion_orig, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_asociacion;

   /*************************************************************************
    Nueva función que se encarga de borrar un registro de Otra referencia
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_referencia(
      pcagente IN age_referencias.cagente%TYPE,
      pnordreferencia IN age_referencias.nordreferencia%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
           := 'parámetros - pcagente: ' || pcagente || ' pnordreferencia: ' || pnordreferencia;
      vobject        VARCHAR2(200) := 'PAC_IAX_AGE_DATOS.f_del_referencia';
   BEGIN
      IF pcagente IS NULL
         OR pnordreferencia IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_age_datos.f_del_referencia(pcagente, pnordreferencia, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_referencia;

   /*************************************************************************
    Nueva función que se encarga de insertar un registro de Otra referencia
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_referencia(
      pcagente IN age_referencias.cagente%TYPE,
      pnordreferencia IN age_referencias.nordreferencia%TYPE,
      ptreferencia IN age_referencias.treferencia%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - pcagente: ' || pcagente || ' ptreferencia: ' || ptreferencia
            || ' pnordreferencia: ' || pnordreferencia;
      vobject        VARCHAR2(200) := 'PAC_IAX_AGE_DATOS.f_set_referencia';
   BEGIN
      IF pcagente IS NULL
         OR ptreferencia IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_age_datos.f_set_referencia(pcagente, pnordreferencia, ptreferencia,
                                                   mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_referencia;

/*************************************************************************
    Nueva función que se encarga de insertar un registro de Otra entidad aseguradora
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_entidadaseg(
      pcagente IN age_entidadesaseg.cagente%TYPE,
      pctipentidadaseg IN age_entidadesaseg.ctipentidadaseg%TYPE,
      poentidadaseg OUT ob_iax_age_entidadaseg,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - pcagente: ' || pcagente || ' pctipentidadaseg: ' || pctipentidadaseg;
      vobject        VARCHAR2(200) := 'PAC_IAX_AGE_DATOS.f_get_entidadaseg';
   BEGIN
      IF pcagente IS NULL
         OR pctipentidadaseg IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_age_datos.f_get_entidadaseg(pcagente, pctipentidadaseg, poentidadaseg,
                                                    mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_get_entidadaseg;

   /*************************************************************************
    Nueva función que se encarga de recuperar un registro de Otra entidad aseguradora
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_banco(
      pcagente IN age_bancos.cagente%TYPE,
      pctipbanco IN age_bancos.ctipbanco%TYPE,
      pobanco OUT ob_iax_age_banco,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                     := 'parámetros - pcagente: ' || pcagente || ' pctipbanco: ' || pctipbanco;
      vobject        VARCHAR2(200) := 'PAC_IAX_AGE_DATOS.f_get_banco';
   BEGIN
      IF pcagente IS NULL
         OR pctipbanco IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_age_datos.f_get_banco(pcagente, pctipbanco, pobanco, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_get_banco;

   /*************************************************************************
    Nueva función que se encarga de recuperar un registro de Otra entidad aseguradora
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_asociacion(
      pcagente IN age_asociaciones.cagente%TYPE,
      pctipasociacion IN age_asociaciones.ctipasociacion%TYPE,
      pnumcolegiado IN age_asociaciones.numcolegiado%TYPE,
      poasociacion OUT ob_iax_age_asociacion,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - pcagente: ' || pcagente || ' pctipasociacion: ' || pctipasociacion
            || ' pnumcolegiado: ' || pnumcolegiado;
      vobject        VARCHAR2(200) := 'PAC_IAX_AGE_DATOS.f_get_asociacion';
   BEGIN
      IF pcagente IS NULL
         OR pctipasociacion IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_age_datos.f_get_asociacion(pcagente, pctipasociacion, pnumcolegiado,
                                                   poasociacion, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_get_asociacion;

   /*************************************************************************
    Nueva función que se encarga de recuperar un registro de Otra entidad aseguradora
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_referencia(
      pcagente IN age_referencias.cagente%TYPE,
      pnordreferencia IN age_referencias.nordreferencia%TYPE,
      ptreferencia IN age_referencias.treferencia%TYPE,
      poreferencia OUT ob_iax_age_referencia,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - pcagente: ' || pcagente || ' pnordreferencia: ' || pnordreferencia
            || ' ptreferencia: ' || ptreferencia;
      vobject        VARCHAR2(200) := 'PAC_IAX_AGE_DATOS.f_get_referencia';
   BEGIN
      IF pcagente IS NULL
         OR pnordreferencia IS NULL
         OR ptreferencia IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_age_datos.f_get_referencia(pcagente, pnordreferencia, ptreferencia,
                                                   poreferencia, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_get_referencia;

    /*************************************************************************
    Nueva función que se encarga de recuperar los registros de la tabla prod_usu
    return              : t_iax_prod_usu
   *************************************************************************/
   FUNCTION f_get_prod_usu(
      pcagente IN prod_usu.cdelega%TYPE,
      pcramo IN prod_usu.cramo%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_prod_usu IS
      prod_usu       t_iax_prod_usu;
      num_err        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'cagente= ' || pcagente || ' - cramo= ' || pcramo;
      vobject        VARCHAR2(200) := 'PAC_IAX_AGE_DATOS.F_Get_prod_usu';
   BEGIN
      --Comprovacio dels parametres d'entrada
      IF pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      prod_usu := pac_md_age_datos.f_get_prod_usu(pcagente, pcramo, mensajes);
      RETURN prod_usu;
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
   END f_get_prod_usu;

   /*************************************************************************
    Nueva función que se encarga del mantenimiento de los registros de la tabla prod_usu
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_prod_usu(
      pseleccionado IN NUMBER,
      pcdelega IN prod_usu.cdelega%TYPE,
      pcramo IN prod_usu.cramo%TYPE,
      pcmodali IN prod_usu.cmodali%TYPE,
      pctipseg IN prod_usu.ctipseg%TYPE,
      pccolect IN prod_usu.ccolect%TYPE,
      pemitir IN prod_usu.emitir%TYPE,
      paccesible IN prod_usu.accesible%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - pseleccionado: ' || pseleccionado || ' pcdelega: ' || pcdelega
            || ' pemitir: ' || pemitir;
      vobject        VARCHAR2(200) := 'PAC_IAX_AGE_DATOS.f_set_prod_usu';
   BEGIN
      IF pseleccionado IS NULL
         OR pcdelega IS NULL
         OR pcramo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_age_datos.f_set_prod_usu(pseleccionado, pcdelega, pcramo, pcmodali,
                                                 pctipseg, pccolect, pemitir, paccesible,
                                                 mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_prod_usu;
END pac_iax_age_datos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_AGE_DATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AGE_DATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AGE_DATOS" TO "PROGRAMADORESCSI";
