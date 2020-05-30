--------------------------------------------------------
--  DDL for Package Body PAC_IAX_CODIGOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_CODIGOS" AS
/******************************************************************************
   NOMBRE:      pac_iax_CODIGOS
   PROPÃ“SITO:

   REVISIONES:
   Ver        Fecha        Autor             DescripciÃ³n
   ---------  ----------  ---------------  ------------------------------------
   1.0        09/02/2011   XPL               1. CreaciÃ³n del package.

******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

/*
      Funció que transformar el clob d'entrada a una colecció d'objecte ob_iax_info
       pparams IN clob                   paràmetres que enviem desde la pantalla,
                                        format : SSEGURO#123123;NRIESGO#1;
      mensajes OUT  t_iax_mensajes       Mensajes
      return t_iax_info
*/
   FUNCTION f_convertir_varchar_coleccion(pparams IN CLOB, mensajes OUT t_iax_mensajes)
      RETURN t_iax_info IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_CODIGOS.f_convertir_varchar_coleccion';
      vparam         VARCHAR2(1000) := 'parámetros - pparams :';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vtinfo         t_iax_info := t_iax_info();
      tipo           VARCHAR2(2000);
      nombre_columna VARCHAR2(1000);
      valor_columna  VARCHAR2(1000);
      vinfo          ob_iax_info;
      pos            NUMBER;
      posdp          NUMBER;
      posvalor       NUMBER;
   BEGIN
      vtinfo := t_iax_info();

      FOR i IN 1 .. LENGTH(pparams) LOOP
         pos := INSTR(pparams, '#', 1, i);
         posdp := INSTR(pparams, '#', 1, i + 1);
         tipo := SUBSTR(pparams, NVL(pos, 0) + 1,(posdp - NVL(pos, 0)) - 1);
         posvalor := INSTR(tipo, ';', 1, 1);
         nombre_columna := SUBSTR(tipo, 1, posvalor - 1);
         valor_columna := SUBSTR(tipo, posvalor + 1);

         IF valor_columna IS NOT NULL THEN
            IF nombre_columna = 'CIDIOMA' THEN
               vinfo := ob_iax_info();
               vtinfo.EXTEND;
               vinfo.nombre_columna := 'CEMPRES';
               vinfo.valor_columna := pac_md_common.f_get_cxtempresa;
               vtinfo(vtinfo.LAST) := vinfo;
               vinfo := ob_iax_info();
               vinfo := ob_iax_info();
               vtinfo.EXTEND;
               vinfo.nombre_columna := nombre_columna;
               vinfo.valor_columna := valor_columna;
               vtinfo(vtinfo.LAST) := vinfo;
            ELSE
               vinfo := ob_iax_info();
               vtinfo.EXTEND;
               vinfo.nombre_columna := nombre_columna;
               vinfo.valor_columna := valor_columna;
               vtinfo(vtinfo.LAST) := vinfo;
            END IF;
         END IF;
      END LOOP;

      RETURN vtinfo;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_convertir_varchar_coleccion;

   FUNCTION f_get_tipcodigos(pcurtipcodigos OUT sys_refcursor, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_CODIGOS.f_get_tipcodigos';
      vparam         VARCHAR2(1000) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         VARCHAR2(3000);
      vparams        t_iax_info;
   BEGIN
      vnumerr := pac_md_codigos.f_get_tipcodigos(pcurtipcodigos, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_tipcodigos;

   FUNCTION f_get_idiomas_activos(pcuridiomas OUT sys_refcursor, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_CODIGOS.f_get_idiomas_activos';
      vparam         VARCHAR2(1000) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         VARCHAR2(3000);
      vparams        t_iax_info;
   BEGIN
      vnumerr := pac_md_codigos.f_get_idiomas_activos(pcuridiomas, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_idiomas_activos;

/*


*/
   FUNCTION f_get_codigos(
      pparams IN CLOB,
      pcodigo OUT VARCHAR2,
      ptinfo OUT ob_iax_info,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_CODIGOS.f_get_codigos';
      vparam         VARCHAR2(1000) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         VARCHAR2(3000);
      vparams        t_iax_info;
   BEGIN
      --Convertim el clob d'entrada a un t_iax_info
      vparams := f_convertir_varchar_coleccion(pparams, mensajes);
      vnumerr := pac_md_codigos.f_get_codigos(vparams, pcodigo, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_get_codigos;

   FUNCTION f_set_codsproduc(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pccolect IN NUMBER,
      pctipseg IN NUMBER,
      pcodigo OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_CODIGOS.f_set_codsproduc';
      vparam         VARCHAR2(1000)
         := 'pcramo=' || pcramo || ',pcmodali:' || pcmodali || ',pccolect:' || pccolect
            || ',pctipseg:' || pctipseg;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_codigos.f_set_codsproduc(pcempres, pcidioma, pcramo, pcmodali,
                                                 pccolect, pctipseg, pcodigo, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_codsproduc;

   FUNCTION f_set_codcgarant(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcodigo OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_CODIGOS.f_set_codcgarant';
      vparam         VARCHAR2(1000) := 'pcempres=' || pcempres || ',pcidioma:' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_codigos.f_set_codcgarant(pcempres, pcidioma, pcodigo, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_codcgarant;

   FUNCTION f_set_codpregun(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcodigo OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_CODIGOS.f_set_codpregun';
      vparam         VARCHAR2(1000) := 'pcempres=' || pcempres || ',pcidioma:' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_codigos.f_set_codpregun(pcempres, pcidioma, pcodigo, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_codpregun;

   FUNCTION f_set_codramo(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcodigo OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_CODIGOS.f_set_codramo';
      vparam         VARCHAR2(1000) := 'pcempres=' || pcempres || ',pcidioma:' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_codigos.f_set_codramo(pcempres, pcidioma, pcodigo, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_codramo;

   FUNCTION f_set_codactivi(
      pcramo IN NUMBER,
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcodigo OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_CODIGOS.f_set_codactivi';
      vparam         VARCHAR2(1000)
                := 'pcramo:' || pcramo || ',pcempres=' || pcempres || ',pcidioma:' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_codigos.f_set_codactivi(pcramo, pcempres, pcidioma, pcodigo, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_codactivi;

   FUNCTION f_set_codliterales(
      ptlitera_1 IN VARCHAR2,
      ptlitera_2 IN VARCHAR2,
      ptlitera_3 IN VARCHAR2,
      ptlitera_4 IN VARCHAR2,
      ptlitera_5 IN VARCHAR2,
      ptlitera_6 IN VARCHAR2,
      ptlitera_7 IN VARCHAR2,
      ptlitera_8 IN VARCHAR2,
      ptlitera_9 IN VARCHAR2,
      ptlitera_10 IN VARCHAR2,
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcodigo OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_CODIGOS.f_set_codliterales';
      vparam         VARCHAR2(1000) := 'pcempres=' || pcempres || ',pcidioma:' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_md_codigos.f_set_codliterales(ptlitera_1, ptlitera_2, ptlitera_3,
                                                   ptlitera_4, ptlitera_5, ptlitera_6,
                                                   ptlitera_7, ptlitera_8, ptlitera_9,
                                                   ptlitera_10, pcempres, pcidioma, pcodigo,
                                                   mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_codliterales;
END pac_iax_codigos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_CODIGOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CODIGOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CODIGOS" TO "PROGRAMADORESCSI";
