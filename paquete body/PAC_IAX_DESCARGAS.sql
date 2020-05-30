--------------------------------------------------------
--  DDL for Package Body PAC_IAX_DESCARGAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_DESCARGAS" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_DESCARGAS
   PROPOSITO: Funciones para gestionar descargas

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        29/08/2011  JMC              1. Creación del package.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

/***************************************************************************
      FUNCTION f_get_cias
      Función que retorna lista con las compañias que tiene configurada alguna
      descarga.
      param out mensajes : mensajes de error
      return             : ref cursor
   ***************************************************************************/
   FUNCTION f_get_cias(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_DESCARGAS.F_Get_Cias';
      vparam         VARCHAR2(500) := NULL;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_descargas.f_get_cias(mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
   END f_get_cias;

/***************************************************************************
      FUNCTION f_get_descargas
      Función que retorna lista con las descargas, se puede filtrar por
      compañia y/o tipo de petición.
      param in pccompani : Código compañía
      param in pctippet : Tipo de petición (1-Descarga, 2-Confirmación, 3-Listado)
      param out mensajes : mensajes de error
      return             : ref cursor
   ***************************************************************************/
   FUNCTION f_get_descargas(
      pccompani IN NUMBER,
      pctippet IN NUMBER,
      psseqdwl IN NUMBER,
      pctipfch IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_DESCARGAS.F_Get_Descargas';
      vparam         VARCHAR2(500)
                     := 'parámetros - pccompani: ' || pccompani || ' - pctippet: ' || pctippet;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_descargas.f_get_descargas(pccompani, pctippet, psseqdwl, pctipfch,
                                                  mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
   END f_get_descargas;

/***************************************************************************
      FUNCTION f_get_ficheros
      Función que retorna lista con los ficheros de una descarga.
      param in psseqdwl : Secuencia de descarga.
      param out mensajes : mensajes de error
      return             : ref cursor
   ***************************************************************************/
   FUNCTION f_get_ficheros(psseqdwl IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_DESCARGAS.F_Get_Ficheros';
      vparam         VARCHAR2(500) := 'parámetros - psseqdwl: ' || psseqdwl;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_descargas.f_get_ficheros(psseqdwl, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
   END f_get_ficheros;

/***************************************************************************
      FUNCTION f_set_peticion
      Función que realiza la petición de descarga.
      param in pccoddes : Código descarga.
      param in psseqdwl : Secuencia de descarga (listado).
      param in pnnumfil : Número de fichero.
      param out psseqout : secuencia de descarga (descarga).
      param out mensajes : mensajes de error
      return             : ref cursor
   ***************************************************************************/
   FUNCTION f_set_peticion(
      psseqdwl IN NUMBER,
      pnnumfil IN NUMBER,
      psseqout OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseqdwl=' || psseqdwl || ' pnnumfil=' || pnnumfil;
      vobject        VARCHAR2(200) := 'PAC_IAX_DESCARGAS.F_SET_PETICION';
      vnumerr        NUMBER;
   BEGIN
      IF psseqdwl IS NULL
         OR pnnumfil IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_descargas.f_set_peticion(psseqdwl, pnnumfil, psseqout, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1;
   END f_set_peticion;

   /***************************************************************************
      FUNCTION F_SET_PETICION_LST_FILES
      Función que realizara la petición de listado de ficheros para una compañia
      y tipo de listado. Esta función se lanzara desde la pantalla.
      param in  pccompani:     Código compañia.
      param in  pctipfch:      Tipo fichero 1-póliza 2-Recibo.
      param in  psseqout       Número de secuencia de descarga.
      return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_set_peticion_lst_files(
      pccompani IN NUMBER,
      pctipfch IN NUMBER,
      psseqout OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pccompani=' || pccompani || ' pctipfch=' || pctipfch;
      vobject        VARCHAR2(200) := 'PAC_IAX_DESCARGAS.F_SET_PETICION_LST_FILES';
      vnumerr        NUMBER;
   BEGIN
      IF pccompani IS NULL
         OR pctipfch IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_descargas.f_set_peticion_lst_files(pccompani, pctipfch, psseqout,
                                                           mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1;
   END f_set_peticion_lst_files;
END pac_iax_descargas;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_DESCARGAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DESCARGAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DESCARGAS" TO "PROGRAMADORESCSI";
