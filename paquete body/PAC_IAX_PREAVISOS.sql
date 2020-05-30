--------------------------------------------------------
--  DDL for Package Body PAC_IAX_PREAVISOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_PREAVISOS" AS
   /******************************************************************************
      NOMBRE:       PAC_IAX_PREAVISOS
      PROPÓSITO:    Funcionalidad para el módulo de preavisos

      REVISIONES:
      Ver        Fecha       Autor  Descripción
      ---------  ----------  -----  ------------------------------------
      1.0        10/04/2012  JTS    Creación del package. (BUG 21756)
   ****************************************************************************/
   FUNCTION f_buscarecibos(
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pdomiciliados IN NUMBER,
      pmediador IN NUMBER,
      ppfinanciero IN NUMBER,
      ppcomercial IN NUMBER,
      ptomador IN NUMBER,
      pfinici IN DATE,
      pfinal IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000);
      vobject        VARCHAR2(200) := 'PAC_IAX_PREAVISOS.F_buscarecibos';
   BEGIN
      cur := pac_md_preavisos.f_buscarecibos(pcempres, pcramo, psproduc, pdomiciliados,
                                             pmediador, ppfinanciero, ppcomercial, ptomador,
                                             pfinici, pfinal, mensajes);

      IF cur IS NULL THEN
         RAISE e_object_error;
      END IF;

      RETURN cur;
   EXCEPTION
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

         RETURN NULL;
   END f_buscarecibos;

   FUNCTION f_compruebamediador(pmediador IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000);
      vobject        VARCHAR2(200) := 'PAC_IAX_PREAVISOS.F_compruebamediador';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_preavisos.f_compruebamediador(pmediador, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_compruebamediador;

   FUNCTION f_realizapreaviso(
      plistrecibos VARCHAR2,
      osproces OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000);
      vobject        VARCHAR2(200) := 'PAC_IAX_PREAVISOS.F_realizapreaviso';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_preavisos.f_realizapreaviso(plistrecibos, osproces, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9903595);
      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_realizapreaviso;
END pac_iax_preavisos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_PREAVISOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PREAVISOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PREAVISOS" TO "PROGRAMADORESCSI";
