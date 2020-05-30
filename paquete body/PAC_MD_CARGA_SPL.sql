--------------------------------------------------------
--  DDL for Package Body PAC_MD_CARGA_SPL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_CARGA_SPL" IS
/******************************************************************************
   NOMBRE:     PAC_MD_CARGA_SPL
   PROPÓSITO:  gestionar las consultas, inserciones, actualizaciones y
               bajas hacia las tablas INT_CARGA_ARCHIVO_SPL, INT_CARGA_CAMPO_SPL
               y la tabla INT_CARGA_VALIDA_SPL.
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        18/03/2015   MSV               1. Creación del package.

******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

/*************************************************************************
   FUNCTION f_set_carga_archivo_spl
*************************************************************************/
   FUNCTION f_set_carga_archivo_spl(
      pcdarchi IN VARCHAR2,
      pcarcest IN NUMBER,
      pctiparc IN NUMBER,
      pcsepara IN VARCHAR2,
      pdsproces IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
         := 'cdarchi=' || pcdarchi || ' carcest=' || pcarcest || ' ctiparc=' || pctiparc
            || ' csepara=' || pcsepara || ' dsproces=' || pdsproces;
      vobject        VARCHAR2(200) := 'PAC_MD_CARGA_SPL.f_set_carga_archivo_spl';
      vtmsg          VARCHAR2(4000);
      vpasexec       NUMBER(8) := 1;
   BEGIN
      vnumerr := pac_carga_spl.f_set_carga_archivo_spl(pcdarchi, pcarcest, pctiparc, pcsepara,
                                                       pdsproces);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

--vtmsg := pac_iobj_mensajes.f_get_descmensaje(parametro_de_mensaje_axis_literales_slitera, pac_md_common.f_get_cxtidioma());
--pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, vtmsg);
      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec,
                                           f_axis_literales(vnumerr));
         RETURN vnumerr;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_carga_archivo_spl;

/*************************************************************************
   FUNCTION f_set_carga_archivo_spl
*************************************************************************/
   FUNCTION f_set_campo_spl(
      pcdarchi IN VARCHAR2,
      pnorden IN NUMBER,
      pccampo IN VARCHAR2,
      pctipcam IN VARCHAR2,
      pnordennew IN NUMBER,
      pccamponew IN VARCHAR2,
      pctipcamnew IN VARCHAR2,
      pnposici IN NUMBER,
      pnlongitud IN NUMBER,
      pntipo IN NUMBER,
      pndecimal IN NUMBER,   --RACS
      pcmask IN VARCHAR2,   --RACS
      pcmodo IN VARCHAR2,
      pcedit IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
         := 'cdarchi=' || pcdarchi || ' NORDEN=' || pnorden || ' CCAMPO =' || pccampo
            || ' CTIPCAM=' || pctipcam || ' NPOSICI =' || pnposici || ' NLONGITUD ='
            || pnlongitud || ' pntipo' || pntipo;
      vobject        VARCHAR2(200) := 'PAC_MD_CARGA_SPL.f_set_campo_spl';
      vtmsg          VARCHAR2(4000);
      vpasexec       NUMBER(8) := 1;
   BEGIN
      vnumerr := pac_carga_spl.f_set_campo_spl(pcdarchi, pnorden, pccampo, pctipcam,
                                               pnordennew, pccamponew, pctipcamnew, pnposici,
                                               pnlongitud, pntipo, pndecimal, pcmask, pcmodo, pcedit);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --vtmsg := pac_iobj_mensajes.f_get_descmensaje(parametro_de_mensaje_axis_literales_slitera, pac_md_common.f_get_cxtidioma());
      --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, vtmsg);
      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec,
                                           f_axis_literales(vnumerr));
         RETURN vnumerr;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_campo_spl;

   /*************************************************************************
   FUNCTION f_set_carga_valida_spl
*************************************************************************/
   FUNCTION f_set_carga_valida_spl(
      pcdarchi IN VARCHAR2,
      pccampo1 IN VARCHAR2,
      pctipcam1 IN NUMBER,
      pccampo2 IN VARCHAR2,
      pctipcam2 IN NUMBER,
      pcoperador IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(2000)
         := 'cdarchi=' || pcdarchi || ' ccampo1=' || pccampo1 || ' ctipcam1 =' || pctipcam1
            || ' ccampo2=' || pccampo2 || ' ctipcam2 =' || pctipcam2 || ' pcoperador ='
            || pcoperador;
      vobject        VARCHAR2(200) := 'PAC_MD_CARGA_SPL.f_set_carga_valida_spl';
      vtmsg          VARCHAR2(4000);
      vpasexec       NUMBER(8) := 1;
   BEGIN
      vnumerr := pac_carga_spl.f_set_carga_valida_spl(pcdarchi, pccampo1, pctipcam1, pccampo2,
                                                      pctipcam2, pcoperador);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

--vtmsg := pac_iobj_mensajes.f_get_descmensaje(parametro_de_mensaje_axis_literales_slitera, pac_md_common.f_get_cxtidioma());
--pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, vtmsg);
      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec,
                                           f_axis_literales(vnumerr));
         RETURN vnumerr;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_carga_valida_spl;

   FUNCTION f_get_campo_spl(cdarchiv IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'cdarchi' || cdarchiv;
      vobject        VARCHAR2(200) := 'pac_md_carga.f_get_campo_spl';
      cur            sys_refcursor;
   BEGIN
      vpasexec := 1;
      cur := pac_carga_spl.f_get_campo_spl(cdarchiv);
      vpasexec := 5;
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

         RETURN cur;
   END f_get_campo_spl;

   FUNCTION f_get_valida_spl(cdarchiv IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'cdarchi' || cdarchiv;
      vobject        VARCHAR2(200) := 'pac_md_carga.f_get_campo_spl';
      cur            sys_refcursor;
   BEGIN
      vpasexec := 1;
      cur := pac_carga_spl.f_get_valida_spl(cdarchiv);
      vpasexec := 5;
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

         RETURN cur;
   END f_get_valida_spl;

   FUNCTION f_get_cabecera_spl(cdarchiv IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'cdarchi' || cdarchiv;
      vobject        VARCHAR2(200) := 'pac_md_carga.f_get_campo_spl';
      cur            sys_refcursor;
   BEGIN
      vpasexec := 1;
      cur := pac_carga_spl.f_get_cabecera_spl(cdarchiv);
      vpasexec := 5;
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

         RETURN cur;
   END f_get_cabecera_spl;

/*************************************************************************
   FUNCTION f_del_campo_spl
*************************************************************************/
   FUNCTION f_del_campo_spl(
      pcdarchi IN int_carga_campo_spl.cdarchi%TYPE,
      pnorden IN int_carga_campo_spl.norden%TYPE,
      pccampo IN int_carga_campo_spl.ccampo%TYPE,
      pctipcam IN int_carga_campo_spl.ctipcam%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(2000) := 'cdarchi=' || pcdarchi || ' norden=' || pnorden;
      vobject        VARCHAR2(200) := 'PAC_MD_CARGA_SPL.f_del_campo_spl';
      vtmsg          VARCHAR2(4000);
      vpasexec       NUMBER(8) := 1;
   BEGIN
      vnumerr := pac_carga_spl.f_del_campo_spl(pcdarchi, pnorden, pccampo, pctipcam);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec,
                                           f_axis_literales(vnumerr));
         RETURN vnumerr;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_del_campo_spl;

/*************************************************************************
   FUNCTION f_del_valida_spl
*************************************************************************/
   FUNCTION f_del_valida_spl(pcdarchi IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vparam         VARCHAR2(2000) := 'cdarchi=' || pcdarchi;
      vobject        VARCHAR2(200) := 'PAC_MD_CARGA_SPL.f_del_valida_spl';
      vtmsg          VARCHAR2(4000);
      vpasexec       NUMBER(8) := 1;
   BEGIN
      vnumerr := pac_carga_spl.f_del_valida_spl(pcdarchi);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec,
                                           f_axis_literales(vnumerr));
         RETURN vnumerr;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_del_valida_spl;

   FUNCTION f_get_int_campo_spl(
      pcdarchi IN int_carga_campo_spl.cdarchi%TYPE,
      pnorden IN int_carga_campo_spl.norden%TYPE,
      pccampo IN int_carga_campo_spl.ccampo%TYPE,
      pctipcam IN int_carga_campo_spl.ctipcam%TYPE,
      obccampo OUT ob_iax_cargacampo_spl,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcdarchi= ' || pcdarchi || ' pnorden= ' || pnorden || ' pccampo= ' || pccampo
            || ' pctipcam= ' || pctipcam;
      vobject        VARCHAR2(200) := 'PAC_MD_CARGA_SPL.f_get_int_campo_spl';
   --
   BEGIN
      --
      IF pcdarchi IS NULL
         OR pnorden IS NULL
         OR pccampo IS NULL
         OR pctipcam IS NULL THEN
         RAISE e_param_error;
      END IF;

      --
      vpasexec := 2;
      --
      vnumerr := pac_carga_spl.f_get_int_campo_spl(pcdarchi, pnorden, pccampo, pctipcam,
                                                   obccampo, mensajes);

      --
      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --
      RETURN vnumerr;
   --
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
   END f_get_int_campo_spl;
END pac_md_carga_spl;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_CARGA_SPL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CARGA_SPL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CARGA_SPL" TO "PROGRAMADORESCSI";
