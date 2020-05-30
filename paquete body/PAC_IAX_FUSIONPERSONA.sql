--------------------------------------------------------
--  DDL for Package Body PAC_IAX_FUSIONPERSONA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_FUSIONPERSONA" IS
   /******************************************************************************
       NOMBRE:       PAC_IAX_FUSIONPERSONA
       PROPÃ“SITO: Funciones para gestionar personas

       REVISIONES:
       Ver        Fecha        Autor             DescripciÃ³n
       ---------  ----------  ---------------  ------------------------------------
       1.0        20/02/2012  AMC               1. Creación del package.

    ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   pmode          VARCHAR2(20);

    /*************************************************************************
      Función que sirve para realizar fusionar des personas

        retorno : 0 ok
                  1 error
     Bug 20945/104041 - 20/02/2012 -  AMC
   *************************************************************************/
   FUNCTION f_fusionar_per(
      psperson1 IN NUMBER,
      pcagente1 IN NUMBER,
      psperson2 IN NUMBER,
      pcagente2 IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_IAX_FUSIONPERSONA.f_fusionar_per';
      vparam         VARCHAR2(2000)
         := 'PSPERSON1= ' || psperson1 || ', PCAGENTE1= ' || pcagente1 || ', PSPERSON2= '
            || psperson2 || ', PCAGENTE2= ' || pcagente2;
      vpasexec       NUMBER;
      vnumerr        NUMBER;
   BEGIN
      vpasexec := 1;
      vnumerr := pac_md_fusionpersona.f_fusionar_per(psperson1, pcagente1, psperson2,
                                                     pcagente2, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_fusionar_per;

   /*************************************************************************
      Función que devuelve el sperson de la segunda persona con el mismo nif

        retorno : 0 ok
                  1 error
     Bug 20945/104041 - 21/02/2012 -  AMC
   *************************************************************************/
   FUNCTION f_get_perduplicada(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      psperson2 OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_IAX_FUSIONPERSONA.f_fusionar_per';
      vparam         VARCHAR2(2000) := 'PSPERSON= ' || psperson || ', PCAGENTE= ' || pcagente;
      vpasexec       NUMBER;
      vnumerr        NUMBER;
   BEGIN
      vpasexec := 1;
      vnumerr := pac_md_fusionpersona.f_get_perduplicada(psperson, pcagente, psperson2,
                                                         mensajes);

      IF vnumerr <> 0 THEN
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
   END f_get_perduplicada;
END pac_iax_fusionpersona;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_FUSIONPERSONA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_FUSIONPERSONA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_FUSIONPERSONA" TO "PROGRAMADORESCSI";
