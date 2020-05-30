--------------------------------------------------------
--  DDL for Package Body PAC_IAX_BONFRAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_BONFRAN" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_BONFRAN
   PROP¿SITO:  Permite modificar deducibles - franquicias

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        04/10/2016   IGIL              1. Creaci¿n del package

   *************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   mensajes       t_iax_mensajes := NULL;

   FUNCTION f_set_deducible(
      pcgrup IN NUMBER,
      pcsubgrup IN NUMBER,
      pcversion IN NUMBER,
      pcnivel IN NUMBER,
      pcvalor1 IN NUMBER,
      pimpvalor1 IN NUMBER,
      pcimpmin IN NUMBER,
      pimpmin IN NUMBER,
      pcimpmax IN NUMBER,
      pimpmax IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
             := ' pcgrup=' || pcgrup || ';pcsubgrup=' || pcsubgrup || ';pcversion=' || pcversion || ' pcnivel=' || pcnivel || ';pcvalor1=' || pcvalor1 || ';pimpvalor1=' || pimpvalor1|| ';pcimpmin=' || pcimpmin || ';pimpmin=' || pimpmin || ' pcimpmax=' || pcimpmax || ';pimpmax=' || pimpmax;
      vobject        VARCHAR2(200) := 'PAC_IAX_BONFRAN.f_set_deducible';
   BEGIN
      numerr := pac_md_bonfran.f_set_deducible(pcgrup, pcsubgrup, pcversion, pcnivel, pcvalor1, pimpvalor1, pcimpmin, pimpmin, pcimpmax, pimpmax, mensajes);
      vpasexec := 2;

      IF numerr <> 0 THEN
         RETURN 1;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 111313);   -- Proceso Correcto.
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
   END f_set_deducible;
   FUNCTION f_validar_deducible_manual(
      pcgrup IN NUMBER,
      pcsubgrup IN NUMBER,
      pcversion IN NUMBER,
      pcnivel IN NUMBER,
      pcvalor1 OUT NUMBER,
      pimpvalor1 OUT NUMBER,
      pcimpmin OUT NUMBER,
      pimpmin OUT NUMBER,
      pcimpmax OUT NUMBER,
      pimpmax OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER  IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
             := ' pcgrup=' || pcgrup || ';pcsubgrup=' || pcsubgrup || ';pcversion=' || pcversion || ' pcnivel=' || pcnivel || ';pcvalor1=' || pcvalor1 || ';pimpvalor1=' || pimpvalor1|| ';pcimpmin=' || pcimpmin || ';pimpmin=' || pimpmin || ' pcimpmax=' || pcimpmax || ';pimpmax=' || pimpmax;
      vobject        VARCHAR2(200) := 'PAC_IAX_BONFRAN.f_validar_deducible_manual';
   BEGIN
      numerr := pac_md_bonfran.f_validar_deducible_manual(pcgrup, pcsubgrup, pcversion, pcnivel, pcvalor1, pimpvalor1, pcimpmin, pimpmin, pcimpmax, pimpmax, mensajes);
      vpasexec := 2;

      IF numerr <> 0 THEN
        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 111313);
        RETURN 1;
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
  END f_validar_deducible_manual;
END pac_iax_bonfran;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_BONFRAN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_BONFRAN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_BONFRAN" TO "PROGRAMADORESCSI";
