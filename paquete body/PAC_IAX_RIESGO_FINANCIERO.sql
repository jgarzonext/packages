--------------------------------------------------------
--  DDL for Package Body PAC_IAX_RIESGO_FINANCIERO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_RIESGO_FINANCIERO" AS
  /*****************************************************************************
      NAME:       pac_iax_riesgo_financiero

   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   mensajes       t_iax_mensajes := NULL;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma;
   gempres        NUMBER := pac_md_common.f_get_cxtempresa;
   gusuari        VARCHAR2(20) := pac_md_common.f_get_cxtusuario;
   FUNCTION f_calcula_riesgo(
      sperson IN NUMBER,
      fefecto IN DATE,
      monto IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_tempres      VARCHAR2(50);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                        := 'sperson=' || sperson || ' fefecto=' || fefecto || ' monto=' || monto;
      vobject        VARCHAR2(200) := 'pac_iax_riesgo_financiero.f_calcula_riesgo ';
      nerror         NUMBER := 0;
   BEGIN
      vpasexec := 5;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'nerrr: : '||nerror);
      nerror := pac_md_riesgo_financiero.f_calcula_riesgo(sperson, fefecto, monto,mensajes);
      vpasexec := 6;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'nerrr: : '||nerror);
      IF nerror = 1
         OR nerror = 108469 THEN
         RAISE e_object_error;
      END IF;
  vpasexec := 7;
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'nerrr: : '||nerror);
      COMMIT;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL,
                                           f_axis_literales(9910038,
                                                            pac_md_common.f_get_cxtidioma()));
      RETURN nerror;
   EXCEPTION
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_calcula_riesgo;


    FUNCTION F_GET_RIESGOS_CALCULADOS(sperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'sperson= ' || sperson;
      vobject        VARCHAR2(200) := 'pac_iax_riesgo_financiero.F_GET_RIESGOS_CALCULADOS';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_riesgo_financiero.F_GET_RIESGOS_CALCULADOS(sperson, mensajes);
      RETURN cur;
   EXCEPTION
     --
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
  END F_GET_RIESGOS_CALCULADOS;



END pac_iax_riesgo_financiero;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_RIESGO_FINANCIERO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_RIESGO_FINANCIERO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_RIESGO_FINANCIERO" TO "PROGRAMADORESCSI";
