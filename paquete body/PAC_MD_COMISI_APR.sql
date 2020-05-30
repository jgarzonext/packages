--------------------------------------------------------
--  DDL for Package Body PAC_MD_COMISI_APR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_COMISI_APR" AS
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

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
      v_object       VARCHAR2(200) := 'PAC_MD_COMISI_APR.F_OBTENER_POLIZAS';
      v_numerr       NUMBER(10);
   BEGIN
      v_numerr := pac_comisi_adqui.f_obtener_polizas(p_cagente, p_tagente, p_npoliza,
                                                     p_ncertif, p_desde, p_hasta, p_refcursor);

      IF v_numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_numerr);
         RAISE e_object_error;
      END IF;

      RETURN v_numerr;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);

         IF p_refcursor%ISOPEN THEN
            CLOSE p_refcursor;
         END IF;

         RETURN 1;
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
      v_object       VARCHAR2(200) := 'PAC_MD_COMISI_APR.F_OBTENER_TOTAL_COMIS';
      v_numerr       NUMBER(10);
   BEGIN
      v_numerr := pac_comisi_adqui.f_obtener_total_comis(p_sseguro, p_npoliza, p_fefecto,
                                                         p_vto, p_totcom);

      IF v_numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_numerr);
         RAISE e_object_error;
      END IF;

      RETURN v_numerr;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
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
      v_object       VARCHAR2(200) := 'PAC_MD_COMISI_APR.F_OBTENER_COMISIONES';
      v_numerr       NUMBER(10);
   BEGIN
      v_numerr := pac_comisi_adqui.f_obtener_comisiones(p_sseguro, p_refcursor);

      IF v_numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_numerr);
         RAISE e_object_error;
      END IF;

      RETURN v_numerr;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);

         IF p_refcursor%ISOPEN THEN
            CLOSE p_refcursor;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF p_refcursor%ISOPEN THEN
            CLOSE p_refcursor;
         END IF;

         RETURN 1;
   END f_obtener_comisiones;
END pac_md_comisi_apr;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_COMISI_APR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_COMISI_APR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_COMISI_APR" TO "PROGRAMADORESCSI";
