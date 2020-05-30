--------------------------------------------------------
--  DDL for Package Body PAC_IAX_TR234_OUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_TR234_OUT" AS
/******************************************************************************
   NOMBRE:       pac_iax_TR234_OUT
   PROPÓSITO:    Package para llamadas desde JAVA a funciones del paquete PK_TR234_OUT (envio ficheros norma 234)

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        15/01/2010   JGM                1. Creación del package. Bug 13503
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
         Función que sirve para generar el fichero MAP de norm 234
           1.    PCINOUT: Tipo numérico. Parámetro de entrada. Nos dice si es traspaso de Entrada (1) o Salida (2)
           2.    PFHASTA: Tipo Fecha. Parámetro de entrada. Hasta que fecha hacemos el fichero de traspasos
           3.    PTNOMFICH: Tipo String. Parámetro de salida. Nombre del fichero resultado
           4.    MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.
           5.    PNFICHERO: Tipo NUMBER (opcional) indica que numero de orden de fichero (0-9) queremos generar
   *************************************************************************/
   FUNCTION f_generar_fichero(
      pcinout IN NUMBER,
      pfhasta IN DATE,
      ptnomfich OUT VARCHAR2,
      mensajes OUT t_iax_mensajes,
      pnfichero IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vestsseguro    NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'pcinout=' || pcinout || ' ptnomfich:' || ptnomfich;
      vobject        VARCHAR2(200) := 'pac_iax_TR234_OUT.f_generar_fichero';
   BEGIN
      IF pcinout IS NULL
         OR NVL(pnfichero, 1) <= 0
         OR NVL(pnfichero, 1) > 9 THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_tr234_out.f_generar_fichero(pcinout, pfhasta, ptnomfich, mensajes,
                                                    pnfichero);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN vnumerr;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN vnumerr;
   END f_generar_fichero;

   FUNCTION f_buscar_traspasos(pcinout IN NUMBER, pfhasta IN DATE, mensajes OUT t_iax_mensajes)
      RETURN t_iax_traspasos IS
      vnumerr        NUMBER := 0;
      vestsseguro    NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'pcinout=' || pcinout;
      vobject        VARCHAR2(200) := 'pac_iax_TR234_OUT.f_buscar_traspasos';
      v_result       t_iax_traspasos;
   BEGIN
      IF pcinout IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_result := pac_md_tr234_out.f_buscar_traspasos(pcinout, pfhasta, mensajes);
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_buscar_traspasos;
END pac_iax_tr234_out;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_TR234_OUT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_TR234_OUT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_TR234_OUT" TO "PROGRAMADORESCSI";
