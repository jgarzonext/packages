--------------------------------------------------------
--  DDL for Package Body PAC_IAX_ESC_RIESGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_ESC_RIESGO" AS
/******************************************************************************
   NOMBRE:     pac_iax_esc_riesgo
   PROP¿SITO:  Funciones para realizar una conexi¿n
               a base de datos de la capa de negocio

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        23/03/2017   ERH              1. Creaci¿n del package.
   2.0        11/03/2019   DFR              2. IAXIS-2016: Scoring
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /**********************************************************************
	  FUNCTION F_GRABAR_ESCALA_RIESGO
      Funci¿n que almacena los datos de la escala de riesgo.
      Firma (Specification)
      Param IN pcescrie: cescrie
      Param IN pndesde: ndesde
	    Param IN pnhasta: nhasta
      Param OUT mensajes : mesajes de error
      return             : 0 todo ha sido correcto
                           1 ha habido un error
     **********************************************************************/
      FUNCTION f_grabar_escala_riesgo(
        pcescrie IN NUMBER,
         pndesde IN NUMBER,
         pnhasta IN NUMBER,
        pindicad IN VARCHAR2,
        mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_ESC_RIESGO.f_grabar_escala_riesgo';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(1000) := 'par¿metros - ';

       BEGIN

          vnumerr := pac_md_esc_riesgo.f_grabar_escala_riesgo(pcescrie, pndesde, pnhasta, pindicad, mensajes);

          IF vnumerr = 1 THEN
             RAISE e_object_error;
          END IF;
          COMMIT;
          RETURN 0;
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
       END f_grabar_escala_riesgo;


     /**********************************************************************
      FUNCTION F_GET_ESCALA_RIESGO
      Funci¿n que retorna los datos de la escala de riesgo
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_escala_riesgo(
          mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' = ';
      vobject        VARCHAR2(200) := 'PAC_IAX_ESCALA_RIESGO.f_get_escala_riesgo';
      cur            sys_refcursor;

       BEGIN

          cur := pac_md_esc_riesgo.f_get_escala_riesgo(mensajes);

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
       END f_get_escala_riesgo;

    -- Inicio IAXIS-2016: Scoring 11/03/2019
    /**********************************************************************
      FUNCTION F_CALCULA_MODELO
      Funci¿n que genera el calculo modelo de la ficha financiera
      Firma (Specification):
      Param IN  psfinanci: sfinanci
      Param IN  pcesvalor: cesvalor
      Param IN  pcuposug: cuposug
      Param IN  pcupogar: cupogar
     **********************************************************************/
        FUNCTION f_calcula_modelo(
        psperson IN NUMBER,
        psproduc IN NUMBER,
        pcagente IN NUMBER,
        pcdomici IN NUMBER,
        mensajes IN OUT T_IAX_MENSAJES )
        RETURN NUMBER IS
        vnumerr        NUMBER;
        vobjectname    VARCHAR2(500) := 'PAC_IAX_ESCALA_RIESGO.f_calcula_modelo';
        vpasexec       NUMBER(5) := 1;
        vparam         VARCHAR2(1000) := 'par¿metros - ';

       BEGIN
         --
         vnumerr := pac_md_esc_riesgo.f_calcula_modelo(psperson, psproduc, pcagente, pcdomici, mensajes);
         --
         IF vnumerr = 1 THEN
           RAISE e_object_error;
         END IF;
         --COMMIT;
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
       END f_calcula_modelo;
    -- Fin IAXIS-2016: Scoring 11/03/2019

    /**********************************************************************
      FUNCTION F_GET_SCORING_GENERAL
      Funci¿n que retorna los datos de scoring por persona.
      Param IN    psperson : sperson
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_scoring_general(
          psperson IN NUMBER,
          mensajes IN OUT T_IAX_MENSAJES)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psperson = ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_ESCALA_RIESGO.f_get_scoring_general';
      cur            sys_refcursor;

       BEGIN

          IF psperson IS NULL THEN
             RAISE e_object_error;
          END IF;

          cur := pac_md_esc_riesgo.f_get_scoring_general(psperson, mensajes);

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
       END f_get_scoring_general;

END pac_iax_esc_riesgo;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_ESC_RIESGO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_ESC_RIESGO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_ESC_RIESGO" TO "PROGRAMADORESCSI";
