--------------------------------------------------------
--  DDL for Package Body PAC_IAX_GESTOR_FICHEROS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_GESTOR_FICHEROS" IS
   /****************************************************************************************
      FUNCTION f_generar_ficheros
      Aplica formateo a una columna de acuerdo a su tipo de dato y a su configuracion.
      param in ppempresa     : Empresa para la cual se genera el fichero del informe
               pptgestor     : Gestor o Informe del cual se va a generar el fichero
               pptformato    : Formato para el cual se va a generar el fichero
               ppnanio       : Anio de la informacion a generar en el fichero
               ppnmes        : Mes de la informacion a generar en el fichero
               ppndia        : Dia de la informacion a generar en el fichero
      return                 : Numero que indica si el proceso fue exitoso o si se
                               presento algun error
   *******************************************************************************************/
   FUNCTION f_generar_ficheros(
      ppempresa IN NUMBER,
      pptgestor IN NUMBER,
      pptformato IN VARCHAR2,
      ppnanio IN NUMBER,
      ppnmes IN NUMBER,
      ppndia IN NUMBER,
      sproces OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vnok           NUMBER;
      vnko           NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := NULL || ' pcempres=' || ppempresa || ' pptgestor=' || pptgestor || ' pptformato='
            || pptformato || ' ppnanio=' || ppnanio || ' ppnmes=' || ppnmes || ' ppndia='
            || ppndia;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTOR_FICHEROS.f_generar_ficheros';
   BEGIN
      --mensajes := t_iax_mensajes();
      vnumerr := pac_md_gestor_ficheros.f_generar_ficheros(ppempresa, pptgestor, pptformato,
                                                           ppnanio, ppnmes, ppndia, sproces,
                                                           mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
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
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1;
   END f_generar_ficheros;
END pac_iax_gestor_ficheros;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_GESTOR_FICHEROS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GESTOR_FICHEROS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GESTOR_FICHEROS" TO "PROGRAMADORESCSI";
