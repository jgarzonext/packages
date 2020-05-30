--------------------------------------------------------
--  DDL for Package Body PAC_IAX_CARGA_SPL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_CARGA_SPL" IS
/******************************************************************************
   NOMBRE:     PAC_IAX_CARGA_SPL
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
      pcdarchi IN int_carga_archivo_spl.cdarchi%TYPE,
      pcarcest IN int_carga_archivo_spl.carcest%TYPE,
      pctiparc IN int_carga_archivo_spl.ctiparc%TYPE,
      pcsepara IN int_carga_archivo_spl.csepara%TYPE,
      pdsproces IN cfg_files.cproceso%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'Error en los parametros cdarchi=' || pcdarchi || ' carcest=' || pcarcest
            || ' ctiparc=' || pctiparc || ' csepara=' || pcsepara || ' dsproces=' || pdsproces;
      vobject        VARCHAR2(200) := 'PAC_IAX_CARGA_SPL.f_set_carga_archivo_spl';
   BEGIN
      IF pcdarchi IS NULL
         OR pcarcest IS NULL
         OR pctiparc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_carga_spl.f_set_carga_archivo_spl(pcdarchi, pcarcest, pctiparc,
                                                          pcsepara, pdsproces, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN vnumerr;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_carga_archivo_spl;

/*************************************************************************
   FUNCTION f_set_campo_spl

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
      pndecimal IN NUMBER DEFAULT NULL,   --RACS
      pcmask IN VARCHAR2 DEFAULT NULL,   --RACS
      pcmodo IN VARCHAR2,
      pcedit IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'cdarchi=' || pcdarchi || ' NORDEN=' || pnorden || ' CCAMPO =' || pccampo
            || ' CTIPCAM=' || pctipcam || ' NPOSICI =' || pnposici || ' NLONGITUD ='
            || pnlongitud || '  pntipo =' || pntipo;
      vobject        VARCHAR2(200) := 'PAC_IAX_CARGA_SPL.f_set_campo_spl';
   BEGIN
      IF pcdarchi IS NULL
         OR pccampo IS NULL
         OR pctipcam IS NULL
         OR pnposici IS NULL
         OR pnlongitud IS NULL
         OR pntipo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_carga_spl.f_set_campo_spl(pcdarchi, pnorden, pccampo, pctipcam,
                                                  pnordennew, pccamponew, pctipcamnew,
                                                  pnposici, pnlongitud, pntipo, pndecimal,
                                                  pcmask, pcmodo, pcedit, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN vnumerr;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_campo_spl;

/*************************************************************************
   FUNCTION f_set_campo_spl

*************************************************************************/
   FUNCTION f_set_carga_valida_spl(
      pcdarchi IN VARCHAR2,
      pccampo1 IN VARCHAR2,
      pctipcam1 IN NUMBER,
      pccampo2 IN VARCHAR2,
      pctipcam2 IN NUMBER,
      pcoperador IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'cdarchi=' || pcdarchi || ' ccampo1=' || pccampo1 || ' ctipcam1 =' || pctipcam1
            || ' ccampo2=' || pccampo2 || ' ctipcam2 =' || pctipcam2 || ' pcoperador ='
            || pcoperador;
      vobject        VARCHAR2(200) := 'PAC_IAX_CARGA_SPL.f_set_carga_valida_spl';
   BEGIN
      IF pcdarchi IS NULL
         OR pccampo1 IS NULL
         OR pctipcam1 IS NULL
         OR pccampo2 IS NULL
         OR pctipcam2 IS NULL
         OR pcoperador IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_carga_spl.f_set_carga_valida_spl(pcdarchi, pccampo1, pctipcam1,
                                                         pccampo2, pctipcam2, pcoperador,
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
         RETURN vnumerr;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_carga_valida_spl;

   FUNCTION f_get_campo_spl(cdarchiv IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'cdarchi' || cdarchiv;
      vobject        VARCHAR2(200) := 'pac_iax_carga.f_get_campo_spl';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_carga_spl.f_get_campo_spl(cdarchiv, mensajes);
      RETURN cur;
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

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_campo_spl;

   FUNCTION f_get_valida_spl(cdarchiv IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'cdarchi' || cdarchiv;
      vobject        VARCHAR2(200) := 'pac_md_carga.f_get_valida_spl';
      cur            sys_refcursor;
   BEGIN
      vpasexec := 1;
      cur := pac_md_carga_spl.f_get_valida_spl(cdarchiv, mensajes);
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
      vobject        VARCHAR2(200) := 'pac_md_carga.f_get_valida_spl';
      cur            sys_refcursor;
   BEGIN
      vpasexec := 1;
      cur := pac_md_carga_spl.f_get_cabecera_spl(cdarchiv, mensajes);
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

       /*******************************************************************************
        FUNCION f_del_campo_spl
        Encargada de borrar los registros de la tabla int_carga_campo_spl.
        Parámetros:
           cdarchi:   Código del archivo - Obligatorio
           norden:    Secuencia de orden de los campos
           ccampo:    Nombre del campo - Obligatorio
           ctipcam:   Tipo de campo ( HEADER 1, CONTENT 2, FOOTER 3) - Obligatorio
           nposici:   Posición dónde se encuentra el campo
           nlongitud: Longitud del campo
             sperson:   Secuencia única de identificación de una persona - Obligatorio
   *************************************************************************/
   FUNCTION f_del_campo_spl(
      pcdarchi IN int_carga_campo_spl.cdarchi%TYPE,
      pnorden IN int_carga_campo_spl.norden%TYPE,
      pccampo IN int_carga_campo_spl.ccampo%TYPE,
      pctipcam IN int_carga_campo_spl.ctipcam%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'cdarchi=' || pcdarchi || ' NORDEN=' || pnorden;
      vobject        VARCHAR2(200) := 'PAC_IAX_CARGA_SPL.f_del_campo_spl';
   BEGIN
      IF pcdarchi IS NULL
         OR pnorden IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_carga_spl.f_del_campo_spl(pcdarchi, pnorden, pccampo, pctipcam,
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
         RETURN vnumerr;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_campo_spl;

       /*******************************************************************************
        FUNCION f_del_valida_spl
        Encargada de borrar un registro de la tabla int_carga_valida_spl.
        Parámetros:
        cdarchi:   Código del archivo - Obligatorio
        ccampo1:   Campo 1 (tendrá que ser del tipo header o footer)
         ctipcam1:  Tipo de campo ( HEADER 1 o FOOTER 3)
          ccampo2:   Campo 2(tendrá que ser del tipo content)
          ctipcam2:  Tipo de campo ( CONTENT 2)
   *************************************************************************/
   FUNCTION f_del_valida_spl(pcdarchi IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'cdarchi=' || pcdarchi;
      vobject        VARCHAR2(200) := 'PAC_IAX_CARGA_SPL.f_del_valida_spl';
   BEGIN
      IF pcdarchi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_carga_spl.f_del_valida_spl(pcdarchi, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN vnumerr;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
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
      vobject        VARCHAR2(200) := 'PAC_IAX_CARGA_SPL.f_get_int_campo_spl';
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
      vnumerr := pac_md_carga_spl.f_get_int_campo_spl(pcdarchi, pnorden, pccampo, pctipcam,
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
END pac_iax_carga_spl;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_CARGA_SPL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CARGA_SPL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CARGA_SPL" TO "PROGRAMADORESCSI";
