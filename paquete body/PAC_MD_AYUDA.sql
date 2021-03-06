--------------------------------------------------------
--  DDL for Package Body PAC_MD_AYUDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_AYUDA" AS
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Para la ayuda de AXIS, se encargará de de retornar el contenido de la
      tabla AXIS_AYUDA
      param in  AYUDACURSOR    : Cursor con todos los valores de la tabla
                                  AXIS_AYUDA
      param out mensajes       : mensajes de error
      return    NUMBER         : 0 -> Finaliza correctamente.
                               : 1 -> Finaliza con error.
   *************************************************************************/
   FUNCTION f_get_ayuda(ayudacursor OUT sys_refcursor, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(50) := 'PAC_MD_AYUDA.F_GET_AYUDA';
      vparam         VARCHAR2(4000) := 'parámetros - AYUDACURSOR=';
      vpasexec       NUMBER(2) := 1;
      vret           NUMBER;
   BEGIN
      vret := pac_ayuda.f_get_ayuda(ayudacursor, mensajes);

      IF vret <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vret);
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
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_ayuda;
 FUNCTION f_get_ayuda(
      cidioma IN NUMBER,
      cform IN VARCHAR2,
      ayudacursor OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(50) := 'PAC_MD_AYUDA.F_GET_AYUDA';
      vparam         VARCHAR2(4000) := 'parámetros - AYUDACURSOR=';
      vpasexec       NUMBER(2) := 1;
      vret           NUMBER;
   BEGIN
      vret := pac_ayuda.f_get_ayuda(cidioma, cform, ayudacursor, mensajes);

      IF vret <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vret);
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
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_ayuda;
END pac_md_ayuda;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_AYUDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AYUDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AYUDA" TO "PROGRAMADORESCSI";
