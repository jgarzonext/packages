--------------------------------------------------------
--  DDL for Package Body PAC_IAX_MANDATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_MANDATOS" IS
      /*******************************************************************************
    FUNCION f_consulta_mandatos
         -- Descripcion
   Parámetros:
    Entrada :


     Retorna un valor numérico: 0 si ha grabado el mandato y 1 si se ha producido algún error.

   */
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_consulta_mandatos(
      pnnumide IN VARCHAR2 DEFAULT NULL,
      pnombre IN VARCHAR2 DEFAULT NULL,
      pdeudormandante IN NUMBER DEFAULT NULL,
      pfvencimiento IN VARCHAR2 DEFAULT NULL,
      pformapago IN NUMBER DEFAULT NULL,
      pcbanco IN NUMBER DEFAULT NULL,
      pcbancar IN VARCHAR2 DEFAULT NULL,
      ptipotarjeta IN NUMBER DEFAULT NULL,
      pnumtarjeta IN VARCHAR2 DEFAULT NULL,
      pinstemisora IN NUMBER DEFAULT NULL,
      pmandato IN NUMBER DEFAULT NULL,
      paccion IN NUMBER DEFAULT NULL,
      psucursal IN VARCHAR2 DEFAULT NULL,
      pestado IN NUMBER DEFAULT NULL,
      pconsulta IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pnnumide= ' || pnnumide || 'pnombre= ' || pnombre || 'pdeudormandante= '
            || pdeudormandante || 'pfvencimiento= ' || pfvencimiento || ', pformapago= '
            || pformapago || ',pcbanco= ' || pcbanco || ', psucursal= ' || psucursal
            || ', pcbancar= ' || pcbancar || ', ptipotarjeta= ' || ptipotarjeta
            || ', pnumtarjeta= ' || pnumtarjeta || ', pinstemisora= ' || pinstemisora
            || ', pmandato= ' || pmandato || ', paccion= ' || paccion || 'psucursal'
            || psucursal || 'pestado= ' || pestado || 'pconsulta= ' || pconsulta;
      vobject        VARCHAR2(200) := 'PAC_IAX_MANDATOS.f_consulta_mandatos';
   BEGIN
      cur := pac_md_mandatos.f_consulta_mandatos(pnnumide, pnombre, pdeudormandante,
                                                 pfvencimiento, pformapago, pcbanco, pcbancar,
                                                 ptipotarjeta, pnumtarjeta, pinstemisora,
                                                 pmandato, paccion, psucursal, pestado,
                                                 pconsulta);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_consulta_mandatos;

   FUNCTION f_consulta_mandatos_masiva(
      pestado IN NUMBER DEFAULT NULL,
      pnomina IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pestado= ' || pestado || 'pnomina= ' || pnomina;
      vobject        VARCHAR2(200) := 'PAC_IAX_MANDATOS.f_consulta_mandatos_masiva';
   BEGIN
      IF pestado IS NULL
         AND pnomina IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_mandatos.f_consulta_mandatos_masiva(pestado, pnomina);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_consulta_mandatos_masiva;

   FUNCTION f_set_mandatos_gestion(
      pnumfolio IN mandatos_gestion.numfolio%TYPE,
      paccion IN mandatos_gestion.accion%TYPE,
      pfproxaviso IN mandatos_gestion.fproxaviso%TYPE,
      pmotrechazo IN mandatos_gestion.motrechazo%TYPE DEFAULT NULL,
      pcomentario IN mandatos_gestion.comentario%TYPE DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - pnumfolio: ' || pnumfolio || ' - paccion: ' || paccion
            || ' pfproxaviso' || pfproxaviso;
      vobject        VARCHAR2(200) := 'PAC_IAX_MANDATOS.f_set_mandatos_gestion';
   BEGIN
      IF pnumfolio IS NULL
         OR paccion IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 10;
      vnumerr := pac_md_mandatos.f_set_mandatos_gestion(pnumfolio, paccion, pfproxaviso,
                                                        pmotrechazo, pcomentario, mensajes);
      vpasexec := 20;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_mandatos_gestion;

   FUNCTION f_get_lstacciones_mandato(
      pnumfolio IN mandatos_estados.numfolio%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pnumfolio = ' || pnumfolio;
      vobject        VARCHAR2(200) := 'PAC_IAX_MANDATOS.f_get_acciones_mandato';
   BEGIN
      cur := pac_md_mandatos.f_get_lstacciones_mandato(pnumfolio, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstacciones_mandato;

   FUNCTION f_get_lstestados_mandmasiva(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000);
      vobject        VARCHAR2(200) := 'PAC_IAX_MANDATOS.f_get_lstestados_mandmasiva';
   BEGIN
      cur := pac_md_mandatos.f_get_lstestados_mandmasiva(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstestados_mandmasiva;

   FUNCTION f_get_acciones_mandmasiva(
      pestado IN mandatos.cestado%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000);
      vobject        VARCHAR2(200) := 'PAC_IAX_MANDATOS.f_get_acciones_mandmasiva';
   BEGIN
      cur := pac_md_mandatos.f_get_acciones_mandmasiva(pestado, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_acciones_mandmasiva;

   FUNCTION f_getestadosmandato(
      pnumfolio IN mandatos_estados.numfolio%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pnumfolio = ' || pnumfolio;
      vobject        VARCHAR2(200) := 'PAC_IAX_MANDATOS.f_getestadosmandato';
   BEGIN
      cur := pac_md_mandatos.f_getestadosmandato(pnumfolio, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_getestadosmandato;

   FUNCTION f_getpolizasmandato(
      pnumfolio IN mandatos_seguros.numfolio%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pnumfolio = ' || pnumfolio;
      vobject        VARCHAR2(200) := 'PAC_IAX_MANDATOS.f_getpolizasmandato';
   BEGIN
      cur := pac_md_mandatos.f_getpolizasmandato(pnumfolio, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_getpolizasmandato;

   FUNCTION f_getgestionesmandato(
      pnumfolio IN mandatos_gestion.numfolio%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pnumfolio = ' || pnumfolio;
      vobject        VARCHAR2(200) := 'PAC_IAX_MANDATOS.f_getgestionesmandato';
   BEGIN
      cur := pac_md_mandatos.f_getgestionesmandato(pnumfolio, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_getgestionesmandato;

   FUNCTION f_set_mandatos_gestion_masiva(
      pcadenanumfol IN VARCHAR2,
      paccion IN mandatos_masiva.accion%TYPE,
      pnomina OUT mandatos_masiva.nomina%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
               := 'parámetros - pcadenanumfol: ' || pcadenanumfol || ' - paccion: ' || paccion;
      vobject        VARCHAR2(200) := 'PAC_IAX_MANDATOS.f_set_mandatos_gestion_masiva';
      v_nomina       mandatos_masiva.nomina%TYPE;
   BEGIN
      IF pcadenanumfol IS NULL
         OR paccion IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_md_mandatos.f_set_mandatos_gestion_masiva(pcadenanumfol, paccion,
                                                               v_nomina, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      pnomina := v_nomina;
      COMMIT;
      vpasexec := 3;
      vnumerr := pac_md_mandatos.f_imp_mandatos_gestion_masiva(paccion, v_nomina, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_mandatos_gestion_masiva;

   FUNCTION f_consulta_documentos(
      pnomina IN mandatos_masiva.nomina%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pnomina = ' || pnomina;
      vobject        VARCHAR2(200) := 'PAC_IAX_MANDATOS.f_consulta_documentos';
   BEGIN
      cur := pac_md_mandatos.f_consulta_documentos(pnomina, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_consulta_documentos;

   FUNCTION f_conscobradoresbanc(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000);
      vobject        VARCHAR2(200) := 'PAC_IAX_MANDATOS.f_conscobradoresbanc';
   BEGIN
      cur := pac_md_mandatos.f_conscobradoresbanc(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_conscobradoresbanc;

   FUNCTION f_set_mandatos_documentos(
      piddocgedox IN NUMBER,
      pnumfolio IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
               := 'parámetros - piddocgedox: ' || piddocgedox || ' - pnumfolio: ' || pnumfolio;
      vobject        VARCHAR2(200) := 'PAC_IAX_MANDATOS.f_set_mandatos_documentos';
   BEGIN
      IF piddocgedox IS NULL
         OR pnumfolio IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 10;
      vnumerr := pac_md_mandatos.f_set_mandatos_documentos(piddocgedox, pnumfolio, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 20;
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_mandatos_documentos;

   FUNCTION f_cons_doc_mandato(pnumfolio IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pnumfolio = ' || pnumfolio;
      vobject        VARCHAR2(200) := 'PAC_IAX_MANDATOS.f_cons_doc_mandato';
   BEGIN
      cur := pac_md_mandatos.f_cons_doc_mandato(pnumfolio, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_cons_doc_mandato;

   FUNCTION f_usupermisogestion(
      pcmandato IN VARCHAR2,
      pnumfolio IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                   := 'parámetros - pcmandato: ' || pcmandato || ' - pnumfolio: ' || pnumfolio;
      vobject        VARCHAR2(200) := 'PAC_IAX_MANDATOS.f_usupermisogestion';
   BEGIN
      IF pcmandato IS NULL
         OR pcmandato IS NULL THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 10;
      vnumerr := pac_md_mandatos.f_usupermisogestion(pcmandato, pnumfolio, mensajes);

      IF vnumerr = -1 THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 20;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 0;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 0;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 0;
   END f_usupermisogestion;
END pac_iax_mandatos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_MANDATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MANDATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MANDATOS" TO "PROGRAMADORESCSI";
