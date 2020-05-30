--------------------------------------------------------
--  DDL for Package Body PAC_IAX_COMPANIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_COMPANIAS" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_COMPANIAS
   PROPÃ“SITO: Funciones para gestionar compañias

   REVISIONES:
   Ver        Fecha        Autor       DescripciÃ³n
   ---------  ----------  ---------  ------------------------------------
   1.0        09/07/2012  JRB        1. CreaciÃ³n del package.
   2.0        03/05/2013  KBR        2. 25822 RSA003 Gestión de compañías reaseguradoras (Nota: 143771)
   4.0        08/05/2013  KBR        4. 25822: RSA003 Gestión de compañías reaseguradoras (Nota: 143961)
   5.0        05/02/2014  AGG
   6.0        31/01/2019  ACL        6. TCS_1569B: Se agrega la funcion f_get_indicador_comp.
******************************************************************************/

   /*************************************************************************
    Nueva funciÃ³n que se encarga de borrar un registro de compañias
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_del_compania(pccompani IN companias.ccompani%TYPE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parÃ¡metros - pccompani: ' || pccompani;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMPANIAS.f_del_compania';
   BEGIN
      IF pccompani IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_companias.f_del_compania(pccompani, mensajes);

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
   END f_del_compania;

   /*************************************************************************
    Nueva funciÃ³n que se encarga de insertar un registro de compañia
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_compania(
      psperson IN companias.sperson%TYPE,
      pccompani IN companias.ccompani%TYPE,
      ptcompani IN companias.tcompani%TYPE,
      pcpais IN companias.cpais%TYPE,
      pctipiva IN companias.ctipiva%TYPE,
      pccomisi IN companias.ccomisi%TYPE,
      pcunespa IN companias.cunespa%TYPE,
      pffalta IN companias.ffalta%TYPE,
      pfbaja IN companias.fbaja%TYPE,
      pccontable IN companias.ccontable%TYPE,
      pctipcom IN companias.ctipcom%TYPE,
      pcafili IN companias.cafili%TYPE,
      pccasamat IN companias.ccasamat%TYPE,
      pcsuperfinan IN companias.csuperfinan%TYPE,
      pcdian IN companias.cdian%TYPE,
      pccalifi IN companias.ccalifi%TYPE,
      pcenticalifi IN companias.centicalifi%TYPE,
      pnanycalif IN companias.nanycalif%TYPE,
      pnpatrimonio IN companias.npatrimonio%TYPE,
      ppimpint IN companias.pimpint%TYPE,
      pctramtax IN companias.ctramtax%TYPE,   --25822 KBR 03052013 Se agrega campo CTRAMTAX
      pccompani_new OUT companias.ccompani%TYPE,
      pcinverfas IN companias.cinverfas%TYPE,   -- Bug 32034 - SHA - 11/08/2014
	  pcresidfisc IN par_companias_rea.cvalpar%TYPE,   --CONFCC-5
      pfresfini IN par_companias_rea.ffini%TYPE,   --CONFCC-5
      pfresffin IN par_companias_rea.ffini%TYPE,   --CONFCC-5
	  pctiprea IN companias.ctiprea%TYPE,   --IAXIS-4823
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                      := 'parÃ¡metros - pccompani: ' || pccompani || ' psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMPANIAS.f_set_compania';
      vccompani      companias.ccompani%TYPE;
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pccompani IS NOT NULL THEN
         vccompani := pccompani;
      END IF;

      --25822 KBR 03052013 Se agrega campo CTRAMTAX
      vnumerr := pac_md_companias.f_set_compania(psperson, vccompani, ptcompani, pcpais,
                                                 pctipiva, pccomisi, pcunespa, pffalta, pfbaja,
                                                 pccontable, pctipcom, pcafili, pccasamat,
                                                 pcsuperfinan, pcdian, pccalifi, pcenticalifi,
                                                 pnanycalif, pnpatrimonio, ppimpint, pctramtax,
                                                 pcinverfas, pcresidfisc, pfresfini, pfresffin, --CONFCC-5
												 pctiprea,--IAXIS-4823
                                                 mensajes);
      COMMIT;
      pccompani_new := vccompani;
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
   END f_set_compania;

   FUNCTION f_get_compania(
      pccompani IN companias.ccompani%TYPE,
      psperson IN companias.sperson%TYPE,
      ptcompani IN companias.tcompani%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_companias IS
      v_result       ob_iax_companias;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pccompani:' || pccompani;   --Solo los obligatorios
      vobject        VARCHAR2(200) := 'PAC_IAX_COMPANIAS.F_GET_COMPANIA';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;
      v_result := pac_md_companias.f_get_compania(pccompani, psperson, ptcompani, mensajes);
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
   END f_get_compania;

   FUNCTION f_get_companias(mensajes OUT t_iax_mensajes)
      RETURN t_iax_companias IS
      v_result       t_iax_companias;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - ';   --Solo los obligatorios
      vobject        VARCHAR2(200) := 'PAC_IAX_COMPANIAS.F_GET_COMPANIAS';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;
      v_result := pac_md_companias.f_get_companias(mensajes);
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
   END f_get_companias;

   /*************************************************************************
    Nueva funciÃ³n que se encarga de insertar un registro de compañia calificadora
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_compania_calif(
      psperson IN compcalificacion.sperson%TYPE,
      pcenticalifi IN compcalificacion.centicalifi%TYPE,
      pccompani IN compcalificacion.ccompani%TYPE,
      pccalifi IN compcalificacion.ccalifi%TYPE,
      pprecargo IN compcalificacion.precargo%TYPE,
      pfefecto in compcalificacion.fefecto%type,
      pofc_repres in compcalificacion.ofc_repres%type,
      pcestado_califi in compcalificacion.cestado_califi%type,
      pfinscrip in compcalificacion.finscrip%type,
      panyoactualiz in compcalificacion.anyoactualiz%type,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
              := 'parÃ¡metros - psperson: ' || psperson || ' - pcenticalifi: ' || pcenticalifi;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMPANIAS.f_set_compania_calif';
      v_user         VARCHAR2(50);
      v_fecha        DATE;
   BEGIN
      v_user := f_user;
      v_fecha := f_sysdate;
      vnumerr := pac_md_companias.f_set_compania_calif(psperson, pcenticalifi, pccompani,
                                                       pccalifi, NVL(pfefecto, v_fecha), NULL,
                                                       pprecargo, v_fecha, v_user, v_fecha,
                                                       v_user, pofc_repres, pcestado_califi, pfinscrip, panyoactualiz, mensajes);

      --No se permiten altas con fecha de efecto menor a la fecha del día
      IF vnumerr = -100 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9905536);
         RAISE e_object_error;
      END IF;

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
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_compania_calif;

   /*************************************************************************
    Nueva funciÃ³n que se encarga de recuperar las compañias calificadoras
    o solo una.
    return              : Referencia al cursor con las compañías
   *************************************************************************/
   FUNCTION f_get_companias_calif(
      psperson IN compcalificacion.sperson%TYPE,
      pcenticalifi IN compcalificacion.centicalifi%TYPE DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_result       sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMPANIAS.F_GET_COMPANIAS_CALIF';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;
      v_result := pac_md_companias.f_get_companias_calif(psperson, pcenticalifi, mensajes);
      RETURN v_result;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_get_companias_calif;

   /*************************************************************************
    Nueva funciÃ³n que se encarga de borrar un registro de compañia calificadora
    return              : 0 Ok. -1 Error
   *************************************************************************/
   FUNCTION f_del_compania_calif(
      psperson IN compcalificacion.sperson%TYPE,
      pcenticalifi IN compcalificacion.centicalifi%TYPE,
      pfefecto IN compcalificacion.fefecto%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
              := 'parÃ¡metros - psperson: ' || psperson || ' - pcenticalifi: ' || pcenticalifi;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMPANIAS.f_del_compania_calif';
   BEGIN
      IF psperson IS NULL
         OR pcenticalifi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_companias.f_del_compania_calif(psperson, pcenticalifi, pfefecto,
                                                       mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_compania_calif;

   /*************************************************************************
    Nueva funciÃ³n que se encarga de validar si existen al menos dos calificaciones
    para la compañía
    return              : X nro de calificaciones. -1 Error
   *************************************************************************/
   FUNCTION f_val_companias_calif(
      psperson IN compcalificacion.sperson%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumcalif      NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'parÃ¡metros - psperson: ' || psperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMPANIAS.f_val_companias_calif';
   BEGIN
      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumcalif := pac_md_companias.f_val_companias_calif(psperson, mensajes);

      IF vnumcalif = -1 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumcalif;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN -1;
   END f_val_companias_calif;

   /*************************************************************************
    Función que se encarga de recuperar el indicador de la compañía
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_indicador_cia(
      pccompani IN indicadores_cias.ccompani%TYPE,
      pctipind IN indicadores_cias.ctipind%TYPE,
      pffinivig IN indicadores_cias.finivig%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_indicadores_cias IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pccompani = ' || pccompani;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMPANIAS.f_get_indicador_cia';
      v_fich         VARCHAR2(400);
      v_tnombre      VARCHAR2(100);
      v_result       ob_iax_indicadores_cias;
   BEGIN
      vpasexec := 1;
      v_result := pac_md_companias.f_get_indicador_cia(pccompani, pctipind, pffinivig,
                                                       mensajes);
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
   END f_get_indicador_cia;

   FUNCTION f_get_indicadores_cias(
      pccompani IN indicadores_cias.ccompani%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_indicadores_cias IS
      v_result       t_iax_indicadores_cias;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - ';   --Solo los obligatorios
      vobject        VARCHAR2(200) := 'PAC_IAX_COMPANIAS.F_GET_INDICADORES_CIAS';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;
      v_result := pac_md_companias.f_get_indicadores_cias(pccompani, mensajes);
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
   END f_get_indicadores_cias;

   /*************************************************************************
    Función que se encarga de insertar un registro en indicadores de compañia
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_set_indicador_cia(
      pccompani IN indicadores_cias.ccompani%TYPE,
      pctipind IN indicadores_cias.ctipind%TYPE,
      pnvalor IN indicadores_cias.nvalor%TYPE,
      pfinivig IN indicadores_cias.finivig%TYPE,
      pffinvig IN indicadores_cias.ffinvig%TYPE,
      pcenviosap IN indicadores_cias.cenviosap%TYPE,
      pcaplica IN indicadores_cias.caplica%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                         := 'parÃ¡metros - pccompani:' || pccompani || 'pctipind:' || pctipind;
      vobject        VARCHAR2(200) := 'PAC_MD_COMPANIAS.F_SET_INDICADOR_CIA';
      vnumerr        NUMBER;
      v_ctipcom      companias.ctipcom%TYPE;   --OJO
      v_host         VARCHAR2(10);
      vcterminal     usuarios.cterminal%TYPE;   --OJO
      vsinterf       NUMBER;
      vterror        VARCHAR(2000);
   BEGIN
      vnumerr := pac_md_companias.f_set_indicador_cia(pccompani, pctipind, pnvalor, pfinivig,
                                                      pffinvig, pcenviosap, pcaplica,
                                                      mensajes);
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
   END f_set_indicador_cia;

    /*************************************************************************
      FUNCTION f_get_tindicadorescia
      Recupera los tipos de indicadores para las compañias
      param out mensajes : missatges d'error
      return             : refcursor
   *************************************************************************/
   FUNCTION f_get_tindicadorescia(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_result       sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'paràmetres:';
      vobject        VARCHAR2(200) := 'PAC_MD_COMPANIAS.F_Get_tindicadorescia';
   BEGIN
      vpasexec := 1;
      v_result := pac_md_companias.f_get_tindicadorescia(mensajes);
      RETURN v_result;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_get_tindicadorescia;

   -- Ini TCS_1569B - ACL - 31/01/2019
   /*************************************************************************
    Funci¨®n que se encarga de recuperar el indicador de la compa?¨ªa
    return              : 0 Ok. 1 Error
   *************************************************************************/
   FUNCTION f_get_indicador_comp(
      pccompani IN indicadores_cias.ccompani%TYPE,
      pctipind IN indicadores_cias.ctipind%TYPE,
      pffinivig IN indicadores_cias.finivig%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_indicadores_cias IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'par¨¢metros - pccompani = ' || pccompani;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMPANIAS.f_get_indicador_comp';
      v_fich         VARCHAR2(400);
      v_tnombre      VARCHAR2(100);
      v_result       ob_iax_indicadores_cias;
   BEGIN
      vpasexec := 1;
      v_result := pac_md_companias.f_get_indicador_comp(pccompani, pctipind, pffinivig,
                                                       mensajes);
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
   END f_get_indicador_comp;
   -- Fin TCS_1569B - ACL - 31/01/2019
END pac_iax_companias;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMPANIAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMPANIAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMPANIAS" TO "PROGRAMADORESCSI";
