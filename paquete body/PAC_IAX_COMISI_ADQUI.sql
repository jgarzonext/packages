--------------------------------------------------------
--  DDL for Package Body PAC_IAX_COMISI_ADQUI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_COMISI_ADQUI" AS
   e_param_error  EXCEPTION;

   FUNCTION f_obtener_polizas(
      p_cagente IN NUMBER,
      p_tagente IN VARCHAR,
      p_npoliza IN NUMBER,
      p_ncertif IN NUMBER,
      p_desde IN DATE,
      p_hasta IN DATE,
      p_refcursor OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'p_cagente=' || p_cagente || ' p_tagente=' || p_tagente || ' p_npoliza='
            || p_npoliza || ' p_ncertif=' || p_ncertif || ' p_desde=' || p_desde
            || ' p_hasta=' || p_hasta;
      v_object       VARCHAR2(200) := 'PAC_IAX_COMISI_ADQUI.F_OBTENER_POLIZAS';
      v_numerr       NUMBER(10);
   BEGIN
      v_numerr := pac_md_comisi_adqui.f_obtener_polizas(p_cagente, p_tagente, p_npoliza,
                                                        p_ncertif, p_desde, p_hasta,
                                                        p_refcursor, mensajes);
      RETURN v_numerr;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF p_refcursor%ISOPEN THEN
            CLOSE p_refcursor;
         END IF;

         RETURN 1;
   END f_obtener_polizas;

   FUNCTION f_obtener_total_comis(
      p_sseguro IN NUMBER,
      p_npoliza OUT NUMBER,
      p_fefecto OUT DATE,
      p_vto OUT DATE,
      p_totcom OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := 'p_sseguro=' || p_sseguro;
      v_object       VARCHAR2(200) := 'PAC_IAX_COMISI_ADQUI.F_OBTENER_TOTAL_COMIS';
      v_numerr       NUMBER(10);
   BEGIN
      IF p_sseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_numerr := pac_md_comisi_adqui.f_obtener_total_comis(p_sseguro, p_npoliza, p_fefecto,
                                                            p_vto, p_totcom, mensajes);
      RETURN v_numerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_obtener_total_comis;

   FUNCTION f_obtener_comisiones(
      p_sseguro IN NUMBER,
      p_refcursor OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := 'p_sseguro=' || p_sseguro;
      v_object       VARCHAR2(200) := 'PAC_IAX_COMISI_ADQUI.F_OBTENER_COMISIONES';
      v_numerr       NUMBER(10);
   BEGIN
      IF p_sseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_numerr := pac_md_comisi_adqui.f_obtener_comisiones(p_sseguro, p_refcursor, mensajes);
      RETURN v_numerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF p_refcursor%ISOPEN THEN
            CLOSE p_refcursor;
         END IF;

         RETURN 1;
   END f_obtener_comisiones;
END pac_iax_comisi_adqui;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMISI_ADQUI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMISI_ADQUI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMISI_ADQUI" TO "PROGRAMADORESCSI";
