--------------------------------------------------------
--  DDL for Package Body PAC_MD_CBANCAR_SEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_CBANCAR_SEG" AS
/******************************************************************************
   NOMBRE:    PAC_MD_CBANCAR_SEG
   PROPÓSITO: Contiene el módulo de Cuentas bancarias de la capa MD

   REVISIONES:
   Ver        Fecha       Autor            Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        16/01/2009  MCC              1. Creación del package.
******************************************************************************/

   /*************************************************************************
      Retorna un cursor con el histirico de cuentas asociadas a una póliza
      param in PSSEGURO : código seguro
      param out PRESULT  : cursor de resultados
      param out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_get_cbancar_seghis(psseguro IN NUMBER, presult OUT sys_refcursor,
   mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER;
      vobject        VARCHAR2(200) := 'PAC_MD_CBANCAR_SEG.F_GET_CBANCAR_SEGHIS';
      vparam         VARCHAR2(900)
                                := 'MD F_GET_CBANCAR_SEGHIS PARAMETROS: PSSEGURO=' || psseguro;
      e_param_error  EXCEPTION;
      e_object_error EXCEPTION;
      vpasexec       NUMBER(8) := 1;
   BEGIN
      v_error := pac_cbancar_seg.f_get_cbancar_seghis(psseguro, presult);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_error;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_error;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_error;
   END f_get_cbancar_seghis;

   /*************************************************************************
        Retorna la última cuenta de cargo asociada a la póliza
        param in PSSEGURO  : código seguro
        param in DATE      : fecha
        param out PCBANCAR : cuenta bancaria
        param out PCBANCOB : cuenta de cobro
     *************************************************************************/
   FUNCTION f_get_cbancar_seg(psseguro IN NUMBER, pfecha IN DATE, pcbancar OUT VARCHAR2,
   pcbancob OUT VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER;
      vobject        VARCHAR2(200) := 'PAC_MD_CBANCAR_SEG.F_GET_CBANCAR_SEG';
      vparam         VARCHAR2(900)
          := 'MD F_GET_CBANCAR_SEG PARAMETROS: PSSEGURO=' || psseguro || ',PFECHA= ' || pfecha;
      e_param_error  EXCEPTION;
      e_object_error EXCEPTION;
      vpasexec       NUMBER(8) := 1;
   --MENSAJES  T_IAX_MENSAJES;
   BEGIN
      v_error := pac_cbancar_seg.f_get_cbancar_seg(psseguro, pfecha, pcbancar, pcbancob);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_error;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_error;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_error;
   END f_get_cbancar_seg;

   /*************************************************************************
       La función se encarga de grabar los datos de la cuenta de cargo
       param in PSSEGURO : código seguro
       param in PCBANCOB : cuenta de cobro
    *************************************************************************/
   FUNCTION f_set_cbancar_seg(psseguro IN NUMBER, pcbancob IN VARCHAR2,
   mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER;
      vobject        VARCHAR2(200) := 'PAC_MD_CBANCAR_SEG.F_SET_CBANCAR_SEG';
      vparam         VARCHAR2(900)
         := 'MD F_SET_CBANCAR_SEG PARAMETROS: PSSEGURO=' || psseguro || ',PCBANCOB= '
            || pcbancob;
      e_param_error  EXCEPTION;
      e_object_error EXCEPTION;
      vpasexec       NUMBER(8) := 1;
   --MENSAJES  T_IAX_MENSAJES;
   BEGIN
      v_error := pac_cbancar_seg.f_set_cbancar_seg(psseguro, pcbancob);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         RAISE e_object_error;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_error;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_error;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_error;
   END f_set_cbancar_seg;
END pac_md_cbancar_seg;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_CBANCAR_SEG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CBANCAR_SEG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CBANCAR_SEG" TO "PROGRAMADORESCSI";
