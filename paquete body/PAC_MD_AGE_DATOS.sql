--------------------------------------------------------
--  DDL for Package Body PAC_MD_AGE_DATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_AGE_DATOS" AS
/******************************************************************************
   NOMBRE:       PAC_MD_AGE_DATOS
   PROPÓSITO: Funciones para gestionar Más datos de agentes

   REVISIONES:
   Ver        Fecha        Autor       Descripción
   ---------  ----------  ---------  ------------------------------------
   1.0        13/03/2012  MDS        1. Creación del package.

******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
    Función que traspasa de errores a mensajes
   *************************************************************************/
   FUNCTION f_traspasar_errores_mensajes(errores IN t_ob_error)
      RETURN t_iax_mensajes IS
      vnumerr        NUMBER(8) := 0;
      mensajesdst    t_iax_mensajes;
      errind         ob_error;
      msg            ob_iax_mensajes;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := ' ';
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_DATOS.f_traspasar_errores_mensajes';
   BEGIN
      mensajesdst := t_iax_mensajes();

      IF errores IS NOT NULL THEN
         IF errores.COUNT > 0 THEN
            FOR vmj IN errores.FIRST .. errores.LAST LOOP
               IF errores.EXISTS(vmj) THEN
                  errind := errores(vmj);
                  mensajesdst.EXTEND;
                  mensajesdst(mensajesdst.LAST) := ob_iax_mensajes();
                  mensajesdst(mensajesdst.LAST).tiperror := 1;
                  mensajesdst(mensajesdst.LAST).cerror := errind.cerror;
                  mensajesdst(mensajesdst.LAST).terror := errind.terror;
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN mensajesdst;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajesdst, vobject, 1000005, vpasexec, vparam);
         RETURN mensajesdst;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajesdst, vobject, 1000006, vpasexec, vparam);
         RETURN mensajesdst;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajesdst, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN mensajesdst;
   END f_traspasar_errores_mensajes;

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
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_DATOS.f_del_banco';
      errores        t_ob_error;
      cont           NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR pctipbanco IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- verificar que existe el registro en la tabla
      SELECT COUNT(1)
        INTO cont
        FROM age_bancos
       WHERE cagente = pcagente
         AND ctipbanco = pctipbanco;

      IF cont = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000402);
         RAISE e_object_error;
      END IF;

      vnumerr := pac_age_datos.f_del_banco(pcagente, pctipbanco, errores);
      mensajes := f_traspasar_errores_mensajes(errores);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RETURN 1;
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
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
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
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_DATOS.f_set_banco';
      errores        t_ob_error;
      cont           NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR pctipbanco IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_age_datos.f_set_banco(pcagente, pctipbanco, pctipbanco_orig, errores);
      mensajes := f_traspasar_errores_mensajes(errores);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RETURN 1;
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
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
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
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_DATOS.f_del_entidadaseg';
      errores        t_ob_error;
      cont           NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR pctipentidadaseg IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- verificar que existe el registro en la tabla
      SELECT COUNT(1)
        INTO cont
        FROM age_entidadesaseg
       WHERE cagente = pcagente
         AND ctipentidadaseg = pctipentidadaseg;

      IF cont = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000402);
         RAISE e_object_error;
      END IF;

      vnumerr := pac_age_datos.f_del_entidadaseg(pcagente, pctipentidadaseg, errores);
      mensajes := f_traspasar_errores_mensajes(errores);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RETURN 1;
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
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
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
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_DATOS.f_set_entidadaseg';
      errores        t_ob_error;
      cont           NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR pctipentidadaseg IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_age_datos.f_set_entidadaseg(pcagente, pctipentidadaseg,
                                                 pctipentidadaseg_orig, errores);
      mensajes := f_traspasar_errores_mensajes(errores);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RETURN 1;
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
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
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
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_DATOS.f_del_asociacion';
      errores        t_ob_error;
      cont           NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR pctipasociacion IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- verificar que existe el registro en la tabla
      SELECT COUNT(1)
        INTO cont
        FROM age_asociaciones
       WHERE cagente = pcagente
         AND ctipasociacion = pctipasociacion;

      IF cont = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000402);
         RAISE e_object_error;
      END IF;

      vnumerr := pac_age_datos.f_del_asociacion(pcagente, pctipasociacion, errores);
      mensajes := f_traspasar_errores_mensajes(errores);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RETURN 1;
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
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
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
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_DATOS.f_set_asociacion';
      errores        t_ob_error;
      cont           NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR pctipasociacion IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_age_datos.f_set_asociacion(pcagente, pctipasociacion, pnumcolegiado,
                                                pctipasociacion_orig, errores);
      mensajes := f_traspasar_errores_mensajes(errores);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RETURN 1;
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
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
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
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_DATOS.f_del_referencia';
      errores        t_ob_error;
      cont           NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR pnordreferencia IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- verificar que existe el registro en la tabla
      SELECT COUNT(1)
        INTO cont
        FROM age_referencias
       WHERE cagente = pcagente
         AND nordreferencia = pnordreferencia;

      IF cont = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000402);
         RAISE e_object_error;
      END IF;

      vnumerr := pac_age_datos.f_del_referencia(pcagente, pnordreferencia, errores);
      mensajes := f_traspasar_errores_mensajes(errores);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RETURN 1;
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
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
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
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_DATOS.f_set_referencia';
      errores        t_ob_error;
      cont           NUMBER;
   BEGIN
      IF pcagente IS NULL
         OR ptreferencia IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_age_datos.f_set_referencia(pcagente, pnordreferencia, ptreferencia,
                                                errores);
      mensajes := f_traspasar_errores_mensajes(errores);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RETURN 1;
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
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_referencia;

   /*************************************************************************
    Nueva función que se encarga de recuperar un registro de Banco
    return              : 0 Ok. 1 Error
   ************************************************************************/
   FUNCTION f_get_banco(
      pcagente IN age_bancos.cagente%TYPE,
      pctipbanco IN age_bancos.ctipbanco%TYPE,
      pobanco IN OUT ob_iax_age_banco,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                     := 'parámetros - pcagente: ' || pcagente || ' pctipbanco: ' || pctipbanco;
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_DATOS.f_get_banco';
   BEGIN
      pobanco := ob_iax_age_banco();
      --
      pobanco.cagente := pcagente;
      pobanco.ctipbanco := pctipbanco;
      pobanco.ttipbanco := ff_desvalorfijo(800076, pac_md_common.f_get_cxtidioma(),
                                           pctipbanco);
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
   END f_get_banco;

   /*************************************************************************
    Nueva función que se encarga de recuperar registros de Bancos
    return              : 0 Ok. 1 Error
   ************************************************************************/
   FUNCTION f_get_bancos(
      pcagente IN age_bancos.cagente%TYPE,
      ptbanco OUT t_iax_age_banco,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - pcagente: ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_DATOS.f_get_bancos';

      CURSOR c1 IS
         SELECT cagente, ctipbanco
           FROM age_bancos
          WHERE cagente = pcagente;
   BEGIN
      IF pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      ptbanco := t_iax_age_banco();

      FOR reg IN c1 LOOP
         ptbanco.EXTEND;
         ptbanco(ptbanco.LAST) := ob_iax_age_banco();
         vnumerr := f_get_banco(pcagente, reg.ctipbanco, ptbanco(ptbanco.LAST), mensajes);

         IF mensajes IS NOT NULL THEN
            IF mensajes.COUNT > 0 THEN
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

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
   END f_get_bancos;

   /*************************************************************************
    Nueva función que se encarga de recuperar un registro de Otra entidad aseguradora
    return              : 0 Ok. 1 Error
   ************************************************************************/
   FUNCTION f_get_entidadaseg(
      pcagente IN age_entidadesaseg.cagente%TYPE,
      pctipentidadaseg IN age_entidadesaseg.ctipentidadaseg%TYPE,
      poentidadaseg IN OUT ob_iax_age_entidadaseg,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - pcagente: ' || pcagente || ' pctipentidadaseg: ' || pctipentidadaseg;
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_DATOS.f_get_entidadaseg';
   BEGIN
      poentidadaseg := ob_iax_age_entidadaseg();
      --
      poentidadaseg.cagente := pcagente;
      poentidadaseg.ctipentidadaseg := pctipentidadaseg;
      poentidadaseg.ttipentidadaseg := ff_desvalorfijo(800077,
                                                       pac_md_common.f_get_cxtidioma(),
                                                       pctipentidadaseg);
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
   END f_get_entidadaseg;

   /*************************************************************************
    Nueva función que se encarga de recuperar registros de Otras entidades aseguradoras
    return              : 0 Ok. 1 Error
   ************************************************************************/
   FUNCTION f_get_entidadesaseg(
      pcagente IN age_entidadesaseg.cagente%TYPE,
      ptentidadaseg OUT t_iax_age_entidadaseg,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - pcagente: ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_DATOS.f_get_entidadesaseg';

      CURSOR c1 IS
         SELECT cagente, ctipentidadaseg
           FROM age_entidadesaseg
          WHERE cagente = pcagente;
   BEGIN
      IF pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      ptentidadaseg := t_iax_age_entidadaseg();

      FOR reg IN c1 LOOP
         ptentidadaseg.EXTEND;
         ptentidadaseg(ptentidadaseg.LAST) := ob_iax_age_entidadaseg();
         vnumerr := f_get_entidadaseg(pcagente, reg.ctipentidadaseg,
                                      ptentidadaseg(ptentidadaseg.LAST), mensajes);

         IF mensajes IS NOT NULL THEN
            IF mensajes.COUNT > 0 THEN
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

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
   END f_get_entidadesaseg;

   /*************************************************************************
    Nueva función que se encarga de recuperar un registro de Asociación
    return              : 0 Ok. 1 Error
   ************************************************************************/
   FUNCTION f_get_asociacion(
      pcagente IN age_asociaciones.cagente%TYPE,
      pctipasociacion IN age_asociaciones.ctipasociacion%TYPE,
      pnumcolegiado IN age_asociaciones.numcolegiado%TYPE,
      poasociacion IN OUT ob_iax_age_asociacion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
           := 'parámetros - pcagente: ' || pcagente || ' pctipasociacion: ' || pctipasociacion;
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_DATOS.f_get_asociacion';
   BEGIN
      poasociacion := ob_iax_age_asociacion();
      --
      poasociacion.cagente := pcagente;
      poasociacion.ctipasociacion := pctipasociacion;
      poasociacion.numcolegiado := pnumcolegiado;
      poasociacion.ttipasociacion := ff_desvalorfijo(800078, pac_md_common.f_get_cxtidioma(),
                                                     pctipasociacion);
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
   END f_get_asociacion;

   /*************************************************************************
    Nueva función que se encarga de recuperar registros de Asociaciones
    return              : 0 Ok. 1 Error
   ************************************************************************/
   FUNCTION f_get_asociaciones(
      pcagente IN age_asociaciones.cagente%TYPE,
      ptasociacion OUT t_iax_age_asociacion,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - pcagente: ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_DATOS.f_get_asociaciones';

      CURSOR c1 IS
         SELECT cagente, ctipasociacion, numcolegiado
           FROM age_asociaciones
          WHERE cagente = pcagente;
   BEGIN
      IF pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      ptasociacion := t_iax_age_asociacion();

      FOR reg IN c1 LOOP
         ptasociacion.EXTEND;
         ptasociacion(ptasociacion.LAST) := ob_iax_age_asociacion();
         vnumerr := f_get_asociacion(pcagente, reg.ctipasociacion, reg.numcolegiado,
                                     ptasociacion(ptasociacion.LAST), mensajes);

         IF mensajes IS NOT NULL THEN
            IF mensajes.COUNT > 0 THEN
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

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
   END f_get_asociaciones;

   /*************************************************************************
    Nueva función que se encarga de recuperar un registro de Otra referencia
    return              : 0 Ok. 1 Error
   ************************************************************************/
   FUNCTION f_get_referencia(
      pcagente IN age_referencias.cagente%TYPE,
      pnordreferencia IN age_referencias.nordreferencia%TYPE,
      ptreferencia IN age_referencias.treferencia%TYPE,
      poreferencia IN OUT ob_iax_age_referencia,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - pcagente: ' || pcagente || ' pnordreferencia: ' || pnordreferencia
            || ' ptreferencia: ' || ptreferencia;
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_DATOS.f_get_referencia';
   BEGIN
      poreferencia := ob_iax_age_referencia();
      --
      poreferencia.cagente := pcagente;
      poreferencia.nordreferencia := pnordreferencia;
      poreferencia.treferencia := ptreferencia;
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
   END f_get_referencia;

   /*************************************************************************
    Nueva función que se encarga de recuperar registros de Otras referencias
    return              : 0 Ok. 1 Error
   ************************************************************************/
   FUNCTION f_get_referencias(
      pcagente IN age_referencias.cagente%TYPE,
      ptreferencia OUT t_iax_age_referencia,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parámetros - pcagente: ' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_DATOS.f_get_referencias';

      CURSOR c1 IS
         SELECT cagente, nordreferencia, treferencia
           FROM age_referencias
          WHERE cagente = pcagente;
   BEGIN
      IF pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      ptreferencia := t_iax_age_referencia();

      FOR reg IN c1 LOOP
         ptreferencia.EXTEND;
         ptreferencia(ptreferencia.LAST) := ob_iax_age_referencia();
         vnumerr := f_get_referencia(pcagente, reg.nordreferencia, reg.treferencia,
                                     ptreferencia(ptreferencia.LAST), mensajes);

         IF mensajes IS NOT NULL THEN
            IF mensajes.COUNT > 0 THEN
               RETURN 1;
            END IF;
         END IF;
      END LOOP;

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
   END f_get_referencias;

   /*************************************************************************
    Nueva función que se encarga de recuperar los registros de la tabla prod_usu
    return              : t_iax_prod_usu
   *************************************************************************/
   FUNCTION f_get_prod_usu(
      pcagente IN prod_usu.cdelega%TYPE,
      pcramo IN prod_usu.cramo%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_prod_usu IS
      prod_usu       t_iax_prod_usu;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'pcagente= ' || pcagente || ' - pcramo= ' || pcramo;
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_DATOS.F_Get_prod_usu';
      vnumerr        NUMBER(8) := 0;

      CURSOR cr_prod_usu(vcr_agente NUMBER) IS
         SELECT   NVL(cdelega, vcr_agente) cdelega, sproduc, v.cramo, v.cmodali, v.ctipseg,
                  v.ccolect, ttitulo, NVL(emitir, 1) emitir, NVL(accesible, 1) accesible,
                  DECODE(cdelega, NULL, 0, 1) seleccionado, r.tramo
             FROM prod_usu p, productos v, titulopro t, codiram c, ramos r
            WHERE v.cramo = p.cramo(+)
              AND v.cmodali = p.cmodali(+)
              AND v.ctipseg = p.ctipseg(+)
              AND v.ccolect = p.ccolect(+)
              AND p.cdelega(+) = vcr_agente
              AND c.cramo = v.cramo
              AND r.cramo = c.cramo
              AND t.cramo = v.cramo
              AND t.cmodali = v.cmodali
              AND t.ctipseg = v.ctipseg
              AND t.ccolect = v.ccolect
              AND t.cidioma = pac_iax_common.f_get_cxtidioma
              AND r.cidioma = pac_md_common.f_get_cxtidioma
              AND c.cempres = pac_md_common.f_get_cxtempresa
              AND(r.cramo = pcramo
                  OR pcramo IS NULL)
         ORDER BY tramo, ttitulo;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      FOR c IN cr_prod_usu(pcagente) LOOP
         IF prod_usu IS NULL THEN
            prod_usu := t_iax_prod_usu();
         END IF;

         vpasexec := 5;
         prod_usu.EXTEND;
         prod_usu(prod_usu.LAST) := ob_iax_prod_usu();
         prod_usu(prod_usu.LAST).cdelega := c.cdelega;
         prod_usu(prod_usu.LAST).cramo := c.cramo;
         prod_usu(prod_usu.LAST).cmodali := c.cmodali;
         prod_usu(prod_usu.LAST).ctipseg := c.ctipseg;
         prod_usu(prod_usu.LAST).ccolect := c.ccolect;
         prod_usu(prod_usu.LAST).emitir := c.emitir;
         prod_usu(prod_usu.LAST).accesible := c.accesible;
         prod_usu(prod_usu.LAST).seleccionado := c.seleccionado;
         prod_usu(prod_usu.LAST).tramo := c.tramo;
         prod_usu(prod_usu.LAST).ttitulo := c.ttitulo;
         prod_usu(prod_usu.LAST).sproduc := c.sproduc;

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      END LOOP;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - pseleccionado: ' || pseleccionado || ' - pcdelega: ' || pcdelega
            || ' - pcramo: ' || pcramo || ' - pcmodali: ' || pcmodali || ' - pctipseg: '
            || pctipseg || ' - pccolect: ' || pccolect;
      vobject        VARCHAR2(200) := 'PAC_MD_AGE_DATOS.f_set_prod_usu';
      vregistros     NUMBER := 0;
   BEGIN
      IF pcdelega IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT COUNT(1)
        INTO vregistros
        FROM prod_usu
       WHERE cdelega = pcdelega
         AND cramo = pcramo
         AND cmodali = pcmodali
         AND ctipseg = pctipseg
         AND ccolect = pccolect;

      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                  vregistros || ' - ' || pseleccionado);

      IF vregistros = 0
         AND pseleccionado = 1 THEN
         vpasexec := 2;

         INSERT INTO prod_usu
                     (cdelega, cramo, cmodali, ctipseg, ccolect, emitir, accesible, imprimir,
                      estudis)
              VALUES (pcdelega, pcramo, pcmodali, pctipseg, pccolect, pemitir, paccesible, 0,
                      0);
      ELSIF vregistros = 1
            AND pseleccionado = 0 THEN
         vpasexec := 3;

         DELETE FROM prod_usu
               WHERE cdelega = pcdelega
                 AND cramo = pcramo
                 AND cmodali = pcmodali
                 AND ctipseg = pctipseg
                 AND ccolect = pccolect;
      ELSIF vregistros = 1
            AND pseleccionado = 1 THEN
         vpasexec := 4;

         UPDATE prod_usu
            SET emitir = pemitir,
                accesible = paccesible
          WHERE cdelega = pcdelega
            AND cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;
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
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_prod_usu;
END pac_md_age_datos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_AGE_DATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AGE_DATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AGE_DATOS" TO "PROGRAMADORESCSI";
