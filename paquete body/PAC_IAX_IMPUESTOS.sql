--------------------------------------------------------
--  DDL for Package Body PAC_IAX_IMPUESTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_IMPUESTOS" AS
/******************************************************************************
   NOMBRE:     PAC_IAX_IMPUESTOS
   PROPÓSITO:  Funciones del modelo de impuestos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/12/2008   JTS                1. Creación del package.
   2.0        10/06/2010   AMC                2. Bug 14748 - Se añaden nuevas funciones
******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

   /*************************************************************************
      Recupera los impuestos de una empresa
      param in pcempres  : empresa a consultar
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_impempres(pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vr_cur         sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000) := pcempres;
      v_object       VARCHAR2(200) := 'PAC_IAX_IMPUESTOS.F_Get_ImpImpres';
   BEGIN
      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vr_cur := pac_md_impuestos.f_get_impempres(pcempres, mensajes);
      RETURN vr_cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);

         IF vr_cur%ISOPEN THEN
            CLOSE vr_cur;
         END IF;

         RETURN vr_cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vr_cur%ISOPEN THEN
            CLOSE vr_cur;
         END IF;

         RETURN vr_cur;
   END f_get_impempres;

   /*************************************************************************
      Inserta impuestos para una empresa
      param in pcempres  : empresa
      param in pcconcep  : impuesto a insertar
      param out mensajes : mesajes de error
      return             : numero de error
   *************************************************************************/
   FUNCTION f_set_impempres(pcempres IN NUMBER, pcconcep IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER(8);
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000) := 'pcempres ' || pcempres || ' pcconcep ' || pcconcep;
      v_object       VARCHAR2(200) := 'PAC_IAX_IMPUESTOS.F_Set_ImpImpres';
   BEGIN
      IF pcempres IS NULL
         AND pcconcep IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_md_impuestos.f_set_impempres(pcempres, pcconcep, mensajes);

      IF v_error = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         ROLLBACK;
         RETURN 107839;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_impempres;

   /*************************************************************************
      Borra impuestos para una empresa
      param in pcempres  : empresa
      param in pcconcep  : impuesto a borrar
      param out mensajes : mesajes de error
      return             : numero de error
   *************************************************************************/
   FUNCTION f_del_impempres(pcempres IN NUMBER, pcconcep IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER(8);
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000) := 'pcempres ' || pcempres || ' pcconcep ' || pcconcep;
      v_object       VARCHAR2(200) := 'PAC_IAX_IMPUESTOS.F_Del_ImpImpres';
   BEGIN
      IF pcempres IS NULL
         AND pcconcep IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_md_impuestos.f_del_impempres(pcempres, pcconcep, mensajes);

      IF v_error = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         ROLLBACK;
         RETURN 107839;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_impempres;

   /*************************************************************************
      Recupera los impuestos segun los parámetros de entrada
      param in pcempres  : empresa
      param in pcconcep  : impuesto
      param in pnconcep  :
      param in pcforpag  ;
      param in psproduc  :
      param in pcramo    :
      param in pcactivi  :
      param in pcgarant  :
      param in pfinivig  :
      param in pffinvig  :
      param out mensajes : mesajes de error
      return ref cursor  :
   *************************************************************************/
   FUNCTION f_get_imprec(
      pcempres IN NUMBER,
      pcconcep IN NUMBER,
      pnconcep IN NUMBER,
      pcforpag IN NUMBER,
      psproduc IN NUMBER,
      pcramo IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vr_cur         sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000)
         := 'pcempres: ' || pcempres || ' pcconcep: ' || pcconcep || ' pnconcep: ' || pnconcep
            || ' pcforpag: ' || pcforpag || ' psproduc: ' || psproduc || ' pcramo: ' || pcramo
            || ' pcactivi: ' || pcactivi || ' pcgarant: ' || pcgarant || ' pfinivig: '
            || pfinivig || ' pffinvig: ' || pffinvig;
      v_object       VARCHAR2(200) := 'PAC_IAX_IMPUESTOS.F_Get_Imprec';
   BEGIN
      vr_cur := pac_md_impuestos.f_get_imprec(pcempres, pcconcep, pnconcep, pcforpag,
                                              psproduc, pcramo, pcactivi, pcgarant, pfinivig,
                                              pffinvig, mensajes);
      RETURN vr_cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vr_cur%ISOPEN THEN
            CLOSE vr_cur;
         END IF;

         RETURN vr_cur;
   END f_get_imprec;

   /*************************************************************************
      Inserta los impuestos en la tabla imprec
      param in pcempres  : empresa
      param in pcconcep  : impuesto
      param in pnconcep  : secuencia de concepto
      param in pcforpag  : codigo formad pago
      param in pcramo    : codigo ramo
      param in psproduc  : codigo de modalidad
      param in pcactivi  : codigo de actividad
      param in pcgarant  : codigo de garantia
      param in pfinivig  : fecha inicio vigencia
      param in pctipcon  : código tipo concepto
      param in pnvalcon  : valor del concepto
      param in pcfracci  : fraccionar
      param in pcbonifi  : aplicar a prima con bonificación
      param in pcrecfra  : aplicar a prima con recargo fraccionamiento
      param out mensajes : mesajes de error
      return             : numero de error

      Bug 14748 - 09/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_set_imprec(
      pcconcep IN NUMBER,
      pcempres IN NUMBER,
      pnconcep IN NUMBER,
      pcforpag IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pfinivig IN DATE,
      pctipcon IN NUMBER,
      pnvalcon IN NUMBER,
      pcfracci IN NUMBER,
      pcbonifi IN NUMBER,
      pcrecfra IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER(8);
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000)
         := 'pcempres: ' || pcempres || ' pcconcep: ' || pcconcep || ' pnconcep: ' || pnconcep
            || ' pcforpag: ' || pcforpag || ' pcramo: ' || pcramo || ' psproduc: ' || psproduc
            || ' pcactivi: ' || pcactivi || ' pcgarant: ' || pcgarant || ' pctipcon: '
            || pctipcon || ' pfinivig: ' || pfinivig;
      v_object       VARCHAR2(200) := 'PAC_IAX_IMPUESTOS.F_Set_Imprec';
   BEGIN
      IF pcconcep IS NULL
         OR pcempres IS NULL
         OR pfinivig IS NULL
         OR pctipcon IS NULL
         OR pnvalcon IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_md_impuestos.f_set_imprec(pcconcep, pcempres, pnconcep, pcforpag, pcramo,
                                               psproduc, pcactivi, pcgarant, pfinivig,
                                               pctipcon, pnvalcon, pcfracci, pcbonifi,
                                               pcrecfra, mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param,
                                           v_error);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_imprec;

   /*************************************************************************
      Recupera los conceptos de recibo que se consideran impuestos o recargos
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_cconcep(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vr_cur         sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000) := '';
      v_object       VARCHAR2(200) := 'PAC_IAX_IMPUESTOS.F_Get_Cconcep';
   BEGIN
      vr_cur := pac_md_impuestos.f_get_cconcep(mensajes);
      RETURN vr_cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vr_cur%ISOPEN THEN
            CLOSE vr_cur;
         END IF;

         RETURN vr_cur;
   END f_get_cconcep;

   /*************************************************************************
      Recupera los conceptos de recibo dados de alta para una empresa
      que se consideran impuestos o recargos
      param  in pcempres : empresa
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_cconcep_emp(pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vr_cur         sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000) := pcempres;
      v_object       VARCHAR2(200) := 'PAC_IAX_IMPUESTOS.F_Get_Cconcep_Emp';
   BEGIN
      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vr_cur := pac_md_impuestos.f_get_cconcep_emp(pcempres, mensajes);
      RETURN vr_cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);

         IF vr_cur%ISOPEN THEN
            CLOSE vr_cur;
         END IF;

         RETURN vr_cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vr_cur%ISOPEN THEN
            CLOSE vr_cur;
         END IF;

         RETURN vr_cur;
   END f_get_cconcep_emp;

   /*************************************************************************
      Recupera las formas de pago para un producto
      param  in psproduc : producto
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_cforpag(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vr_cur         sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000) := 'psproduc: ' || psproduc;
      v_object       VARCHAR2(200) := 'PAC_IAX_IMPUESTOS.F_Get_Cforpag';
   BEGIN
      vr_cur := pac_md_impuestos.f_get_cforpag(psproduc, mensajes);
      RETURN vr_cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vr_cur%ISOPEN THEN
            CLOSE vr_cur;
         END IF;

         RETURN vr_cur;
   END f_get_cforpag;

   /*************************************************************************
      Borra los impuestos en la tabla imprec
      param in pcempres  : empresa
      param in pcconcep  : impuesto
      param in pnconcep  : secuencia de concepto
      param in pcforpag  : codigo formad pago
      param in pfinivig  : fecha inicio vigencia
      param in mensajes  : mensajes de error
      return             : numero de error

      Bug 14748 - 10/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_del_imprec(
      pcconcep IN NUMBER,
      pcempres IN NUMBER,
      pnconcep IN NUMBER,
      pcforpag IN NUMBER,
      pfinivig IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER(8);
      vobjectname    VARCHAR2(100) := 'PAC_IAX_IMPUESTOS.f_del_imprec';
      vparam         VARCHAR2(1000)
         := ' pcconcep:' || pcconcep || ' pcempres:' || pcempres || ' pnconcep:' || pnconcep
            || ' pcforpag:' || pcforpag || ' pfinivig:' || pfinivig;
      vpasexec       NUMBER := 1;
   BEGIN
      IF pcconcep IS NULL
         OR pcempres IS NULL
         OR pfinivig IS NULL
         OR pnconcep IS NULL
         OR pcforpag IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_md_impuestos.f_del_imprec(pcconcep, pcempres, pnconcep, pcforpag,
                                               pfinivig, mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           v_error);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_del_imprec;

   /*************************************************************************
      Devuelve un reargo por fraccionamiento
      param in pcempres  : empresa
      param in pcconcep  : impuesto
      param in pnconcep  : secuencia de concepto
      param in pfinivig  : fecha inicio vigencia
      param out pctipcon : codigo tipo de concepto
      param out pnvalcon : valor del concepto
      param out pcbonifi : si aplica a prima con bonificacion
      param out pcfracci : fraccionar
      param out pcrecfra : si aplica a prima con recargo fraccionamiento
      param out mensajes  : mensajes de error

      return             : numero de error

      Bug 14748 - 13/09/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_recargo(
      pcconcep IN NUMBER,
      pcempres IN NUMBER,
      pnconcep IN NUMBER,
      pfinivig IN DATE,
      pctipcon OUT NUMBER,
      pnvalcon OUT NUMBER,
      pcbonifi OUT NUMBER,
      pcfracci OUT NUMBER,
      pcrecfra OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER(8);
      vobjectname    VARCHAR2(100) := 'PAC_IAX_IMPUESTOS.f_get_recargo';
      vparam         VARCHAR2(1000)
         := ' pcconcep:' || pcconcep || ' pcempres:' || pcempres || ' pnconcep:' || pnconcep
            || ' pfinivig:' || pfinivig;
      vpasexec       NUMBER := 1;
   BEGIN
      IF pcconcep IS NULL
         OR pcempres IS NULL
         OR pfinivig IS NULL
         OR pnconcep IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_md_impuestos.f_get_recargo(pcconcep, pcempres, pnconcep, pfinivig,
                                                pctipcon, pnvalcon, pcbonifi, pcfracci,
                                                pcrecfra, mensajes);

      IF v_error <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           v_error);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_recargo;
END pac_iax_impuestos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_IMPUESTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_IMPUESTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_IMPUESTOS" TO "PROGRAMADORESCSI";
