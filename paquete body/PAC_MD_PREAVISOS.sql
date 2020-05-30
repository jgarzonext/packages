--------------------------------------------------------
--  DDL for Package Body PAC_MD_PREAVISOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_PREAVISOS" AS
   /******************************************************************************
      NOMBRE:       PAC_MD_PREAVISOS
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
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000);
      vobject        VARCHAR2(200) := 'PAC_MD_PREAVISOS.F_buscarecibos';
      vquery         VARCHAR2(32000);
   BEGIN
      vquery := pac_preavisos.f_buscarecibos(pcempres, pcramo, psproduc, pdomiciliados,
                                             pmediador, ppfinanciero, ppcomercial, ptomador,
                                             pfinici, pfinal);

      IF vquery IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903573);
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vquery, mensajes);
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

   FUNCTION f_compruebamediador(pmediador IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000);
      vobject        VARCHAR2(200) := 'PAC_MD_PREAVISOS.F_compruebamediador';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_preavisos.f_compruebamediador(pmediador);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
      osproces IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(32000);
      vobject        VARCHAR2(200) := 'PAC_MD_PREAVISOS.F_realizapreaviso';
      vnumerr        NUMBER;
      vnrecibo       NUMBER;
      vsseguro       NUMBER;
      vnmovimi       NUMBER;
      vsproces       NUMBER;
   BEGIN
      IF plistrecibos IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_preavisos.f_nuevopreaviso(f_user(), vsproces);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      DECLARE
         lv_appendstring VARCHAR2(32000) := plistrecibos;
         lv_resultstring VARCHAR2(500);
         lv_count       NUMBER;
      BEGIN
         LOOP
            EXIT WHEN NVL(INSTR(lv_appendstring, ';'), -99) < 0;
            lv_resultstring := SUBSTR(lv_appendstring, 1,(INSTR(lv_appendstring, ';') - 1));
            lv_count := INSTR(lv_appendstring, ';') + 1;
            lv_appendstring := SUBSTR(lv_appendstring, lv_count, LENGTH(lv_appendstring));

            SELECT nrecibo, sseguro, nmovimi
              INTO vnrecibo, vsseguro, vnmovimi
              FROM recibos
             WHERE nrecibo = lv_resultstring;

            vnumerr := pac_preavisos.f_insertapreaviso(vsproces, vnrecibo, vsseguro, vnmovimi);

            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END LOOP;
      END;

      FOR i IN (SELECT nrecibo, sseguro, nmovimi
                  FROM preavisosrecibos
                 WHERE sproces = vsproces) LOOP
         --Pendiente de realizar
         --
         --Llamada al modulo de impresiones para generar los avisos
         --y proceder a su envio
         --
         --Una vez realizado en envio, se marca como realizado
         vnumerr := pac_preavisos.f_actualizapreaviso(vsproces, i.nrecibo);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      END LOOP;

      osproces := vsproces;
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
   END f_realizapreaviso;
END pac_md_preavisos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PREAVISOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PREAVISOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PREAVISOS" TO "PROGRAMADORESCSI";
