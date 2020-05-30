--------------------------------------------------------
--  DDL for Package Body PAC_IAX_TERMINALES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_TERMINALES" AS
/******************************************************************************
   NOMBRE:      PAC_IAX_TERMINALES
   PROPÓSITO:   Funciones para la gestión de los terminales

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        06/11/2008   AMC                1. Creación del package.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
       Inserta o Modifica un terminal.
       param in pcempres   : código de la empresa
       param in pcmaqfisi  : Máquina física
       param in pcterminal : Terminal Axis
       param out mensajes: mensajes de error
       return           : 0 indica cambio realizado correctamente
                          <> 0 indica error
    *************************************************************************/
   FUNCTION f_set_terminal(
      pcempres NUMBER,
      pcmaqfisi VARCHAR2,
      pcterminal VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_TERMINALES.F_SET_TERMINAL';
      vparam         VARCHAR2(500)
         := 'parámetros - pcempres:' || pcempres || ' pcmaqfisi:' || pcmaqfisi
            || ' pcterminal:' || pcterminal;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pcempres IS NULL
         OR pcmaqfisi IS NULL
         OR pcterminal IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_terminales.f_set_terminal(pcempres, pcmaqfisi, pcterminal, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
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
         RETURN 1;
   END f_set_terminal;

    /*************************************************************************
      Borra un terminal.
      param in pcempres   : código de la empresa
      param in pcmaqfisi  : Máquina física
      param in pcterminal : Terminal Axis
      param out mensajes: mensajes de error
      return           : 0 indica cambio realizado correctamente
                         <> 0 indica error
   *************************************************************************/
   FUNCTION f_del_terminal(
      pcempres NUMBER,
      pcmaqfisi VARCHAR2,
      pcterminal VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_TERMINALES.F_DEL_TERMINAL';
      vparam         VARCHAR2(500)
         := 'parámetros - pcempres:' || pcempres || ' pcmaqfisi:' || pcmaqfisi
            || ' pcterminal:' || pcterminal;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pcempres IS NULL
         OR pcmaqfisi IS NULL
         OR pcterminal IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_terminales.f_del_terminal(pcempres, pcmaqfisi, pcterminal, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
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
         RETURN 1;
   END f_del_terminal;

   /*************************************************************************
      Modifica un terminal.
      param in pcempres   : código de la empresa
      param in pcmaqfisi  : Máquina física
      param in pcterminal : Terminal Axis
      param in pnewcmaqfisi  : Nueva Máquina física
      param in pnewcterminal : Nuevo Terminal Axis
      param out mensajes: mensajes de error
      return           : 0 indica cambio realizado correctamente
                         <> 0 indica error
   *************************************************************************/
   FUNCTION f_update_terminal(
      pcempres NUMBER,
      pcmaqfisi VARCHAR2,
      pcterminal VARCHAR2,
      pnewcmaqfisi VARCHAR2,
      pnewcterminal VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_TERMINALES.F_UPDATE_TERMINAL';
      vparam         VARCHAR2(500)
         := 'parámetros - pcempres:' || pcempres || ' pcmaqfisi:' || pcmaqfisi
            || ' pcterminal:' || pcterminal || ' pnewcmaqfisi:' || pnewcmaqfisi
            || ' pnewcterminal:' || pnewcterminal;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pcempres IS NULL
         OR pcmaqfisi IS NULL
         OR pcterminal IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_terminales.f_update_terminal(pcempres, pcmaqfisi, pcterminal,
                                                     pnewcmaqfisi, pnewcterminal, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
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
         RETURN 1;
   END f_update_terminal;

   /*************************************************************************
      Devuelve los terminales que cumplan con el criterio de selección
      param in pcempres   : código de la empresa
      param in pcmaqfisi  : Máquina física
      param in pcterminal : Terminal Axis
      param out mensajes    : mensajes de error
      return                : ref cursor
   *************************************************************************/
   FUNCTION f_consulta_terminales(
      pcempres NUMBER,
      pcmaqfisi VARCHAR2,
      pcterminal VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vobject        VARCHAR2(500) := 'PAC_IAX_TERMINALES.F_CONSULTA_TERMINALES';
      vparam         VARCHAR2(500)
         := 'parámetros - pcempres:' || pcempres || ' pcmaqfisi:' || pcmaqfisi
            || ' pcterminal:' || pcterminal;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      cur := pac_md_terminales.f_consulta_terminales(pcempres, pcmaqfisi, pcterminal,
                                                     mensajes);
      COMMIT;   -- Hace falta por el LOG de las consultas
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_consulta_terminales;
END pac_iax_terminales;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_TERMINALES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_TERMINALES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_TERMINALES" TO "PROGRAMADORESCSI";
