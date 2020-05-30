--------------------------------------------------------
--  DDL for Package Body PAC_IAX_CARGA_PREGUNTAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_CARGA_PREGUNTAB" AS
/*******************************************************************************
   NOMBRE:       pac_carga_preguntab
   PROPÓSITO: Funciones para la carga de preguntas de tipo tabla

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ----------  ------------------------------------
   1.0        13/2/2015   AMC                1. Creación del package.
*******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

/***********************************************************************
      Recupera los datos del riesgo (preguntas)
      param in psproduc  : codigo del producto
      param in pcactivi  : codigo de actividad
      param in psimul    : indicador de simulacion
      param out mensajes : mensajes de error
      return             : objeto preguntas
   ***********************************************************************/
   FUNCTION f_get_preguntab_rie(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcpregun IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pcnivel IN VARCHAR2,
      psproduc IN NUMBER,
      psproces_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_preguntastab IS
      preg           t_iax_preguntastab;
      resp           t_iaxpar_respuestas;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'ptablas=' || ptablas || ', psseguro=' || psseguro || ', pnriesgo=' || pnriesgo
            || ' pcpregun:' || pcpregun || ' pcgarant:' || pcgarant || ' pnmovimi:'
            || pnmovimi;
      vobject        VARCHAR2(200) := 'PAC_IAX_CARGA_PREGUNTAB.f_get_preguntab_rie';
      vsproduc       NUMBER;
   BEGIN
      RETURN pac_md_carga_preguntab.f_get_preguntab_rie(ptablas, psseguro, pnriesgo, pcpregun,
                                                        pcgarant, pnmovimi, pcnivel, psproduc,
                                                        psproces_out, mensajes);
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
   END f_get_preguntab_rie;

   /***************************************************************************
        procedimiento que ejecuta una carga
        param in p_nombre   : Nombre fichero
        param in  out psproces   : Número proceso (informado para recargar proceso).
        retorna 0 si ha ido bien, 1 en casos contrario
     **************************************************************************/
   FUNCTION f_ejecutar_carga_preguntab(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_cpregun IN NUMBER,
      p_nmovimi IN NUMBER,
      ptablas IN VARCHAR2,
      psproces OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'ptablas=' || ptablas || ', p_sseguro=' || p_sseguro || ', pnriesgo=' || p_nriesgo
            || ' pcpregun:' || p_cpregun || ' pcgarant:' || p_cgarant || ' pnmovimi:'
            || p_nmovimi;
      vobject        VARCHAR2(200) := 'pac_iax_carga_preguntab.f_ejecutar_carga_preguntab';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_carga_preguntab.f_ejecutar_carga_preguntab(p_nombre, p_path,
                                                                   p_cproces, p_sseguro,
                                                                   p_nriesgo, p_cgarant,
                                                                   p_cpregun, p_nmovimi,
                                                                   ptablas, psproces,
                                                                   mensajes);
      RETURN vnumerr;
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
   END f_ejecutar_carga_preguntab;

   FUNCTION f_borrar_carga(
      psseguro IN NUMBER,
      pcpregun IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      pcnivel IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'pcnivel=' || pcnivel || ', psseguro=' || psseguro || ', pnriesgo=' || pnriesgo
            || ' pcpregun:' || pcpregun || ' pcgarant:' || pcgarant || ' pnmovimi:'
            || pnmovimi;
      vobject        VARCHAR2(200) := 'pac_iax_carga_preguntab.f_borrar_carga';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_carga_preguntab.f_borrar_carga(psseguro, pcpregun, pnriesgo, pcgarant,
                                                       pnmovimi, pcnivel, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vnumerr := pac_iax_produccion.f_borrarpreguntastab_carga(pcnivel, pnriesgo, pcpregun,
                                                               pcgarant, pnmovimi, mensajes);

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
   END f_borrar_carga;

   FUNCTION f_validar_carga(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pcpregun IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(100) := 'PAC_IAX_CARGA_PREGUNTAB.f_validar_carga';
      vparam         VARCHAR2(1000)
         := 'psproces:' || psproces || ' psseguro:' || psseguro || ' pnriesgo:' || pnriesgo
            || ' pcgarant:' || pcgarant || ' pcpregun:' || pcpregun || ' pnmovimi:'
            || pnmovimi;
      vpasexec       NUMBER(8) := 1;
      vnum_err       NUMBER;
   BEGIN
      vnum_err := pac_md_carga_preguntab.f_validar_carga(psproces, psseguro, pnriesgo,
                                                         pcgarant, pcpregun, pnmovimi,
                                                         mensajes);

      IF vnum_err <> 0 THEN
         RAISE e_object_error;
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
   END f_validar_carga;

   FUNCTION f_cargas_validadas(
      psseguro IN NUMBER,
      pemitir OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(100) := 'PAC_IAX_CARGA_PREGUNTAB.f_cargas_validadas';
      vparam         VARCHAR2(1000) := 'psseguro:' || psseguro;
      vpasexec       NUMBER(8) := 1;
      vnum_err       NUMBER;
      vmensaje       NUMBER;
   BEGIN
      vnum_err := pac_md_carga_preguntab.f_cargas_validadas(psseguro, pemitir, mensajes);

      IF vnum_err <> 0 THEN
         RAISE e_object_error;
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
   END f_cargas_validadas;
END pac_iax_carga_preguntab;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_CARGA_PREGUNTAB" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CARGA_PREGUNTAB" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CARGA_PREGUNTAB" TO "PROGRAMADORESCSI";
