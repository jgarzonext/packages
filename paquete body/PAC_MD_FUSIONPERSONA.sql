--------------------------------------------------------
--  DDL for Package Body PAC_MD_FUSIONPERSONA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_FUSIONPERSONA" IS
   /******************************************************************************
       NOMBRE:       PAC_MD_FUSIONPERSONA
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_MD_FUSIONPERSONA.f_fusionar_per';
      vparam         VARCHAR2(2000)
         := 'PSPERSON1= ' || psperson1 || ', PCAGENTE1= ' || pcagente1 || ', PSPERSON2= '
            || psperson2 || ', PCAGENTE2= ' || pcagente2;
      vpasexec       NUMBER;
      persona1       ob_iax_personas;
      persona2       ob_iax_personas;
      vnumerr        NUMBER;
      vborrarper     NUMBER;
   BEGIN
      vpasexec := 1;
      persona1 := pac_md_persona.f_get_persona(psperson1, pcagente1, mensajes, 'POL');

      IF mensajes IS NOT NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      persona2 := pac_md_persona.f_get_persona(psperson2, pcagente2, mensajes, 'POL');

      IF mensajes IS NOT NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 3;

      --si una es persona publica y la otra no, no se fusiona. Devolvemos mensaje.
      IF persona1.swpubli != persona2.swpubli THEN
         RETURN 9904452;
      END IF;

      vnumerr := pac_fusionpersona.f_fusion_per(psperson2, pcagente2, psperson1, pcagente1);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
       /*
         No borramos la persona, de momento las personas no se borran por que los recibos sperson, pagos de siniestros,
         fiscalidad no se modifica el campo sperson

        */
--        vborrarper := pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
--                                                  'DELPERSONA');

      --         IF NVL(vborrarper, 0) = 1 THEN
--            vpasexec := 5;
--            vnumerr := pac_fusionpersona.f_del_persona(psperson2, pcagente2);

      --            IF vnumerr <> 0 THEN
--               RAISE e_object_error;
--            END IF;
--         END IF;
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
      psperson2 IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_MD_FUSIONPERSONA.f_get_perduplicada';
      vparam         VARCHAR2(2000) := 'PSPERSON= ' || psperson || ', PCAGENTE= ' || pcagente;
      vpasexec       NUMBER;
      vnumerr        NUMBER;
   BEGIN
      vpasexec := 1;
      vnumerr := pac_fusionpersona.f_get_perduplicada(psperson, pcagente, psperson2);

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
END pac_md_fusionpersona;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_FUSIONPERSONA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FUSIONPERSONA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FUSIONPERSONA" TO "PROGRAMADORESCSI";
