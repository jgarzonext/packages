--------------------------------------------------------
--  DDL for Package Body PAC_MD_IMPUESTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_IMPUESTOS" AS
/******************************************************************************
   NOMBRE:     PAC_MD_IMPUESTOS
   PROPÓSITO:  Funciones del modelo de impuestos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/12/2008   JTS                1. Creación del package.
   2.0        10/06/2009   NMM                2. 9648: IAX - mto. de impuestos.
   3.0        09/06/2010   AMC                3. Se añaden nuevas funciones bug 14748
******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

   /*************************************************************************
      Recupera los impuestos de una empresa
      param in pempresa  : empresa a consultar
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_impempres(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vr_cur         sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000) := pcempres;
      v_object       VARCHAR2(200) := 'PAC_MD_IMPUESTOS.F_Get_ImpImpres';
   BEGIN
      vr_cur := pac_md_listvalores.f_opencursor('SELECT i.cempres, i.cconcep, v.tatribu '
                                                || 'FROM imp_empres i, detvalores v '
                                                || 'WHERE v.cvalor = 27 '
                                                || 'AND v.catribu = i.cconcep '
                                                || 'AND i.cempres = ' || pcempres
                                                || ' AND v.cidioma = '
                                                || pac_md_common.f_get_cxtidioma(),
                                                mensajes);
      RETURN vr_cur;
   EXCEPTION
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
   FUNCTION f_set_impempres(
      pcempres IN NUMBER,
      pcconcep IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER(8);
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000) := 'pcempres ' || pcempres || ' pcconcep ' || pcconcep;
      v_object       VARCHAR2(200) := 'PAC_MD_IMPUESTOS.F_Set_ImpImpres';
   BEGIN
      v_error := pac_impuestos.f_insert_impempres(pcconcep, pcempres);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, v_error, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN SQLCODE;
   END f_set_impempres;

   /*************************************************************************
      Borra impuestos para una empresa
      param in pcempres  : empresa
      param in pcconcep  : impuesto a borrar
      param out mensajes : mesajes de error
      return             : numero de error
   *************************************************************************/
   FUNCTION f_del_impempres(
      pcempres IN NUMBER,
      pcconcep IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER(8);
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000) := 'pcempres ' || pcempres || ' pcconcep ' || pcconcep;
      v_object       VARCHAR2(200) := 'PAC_MD_IMPUESTOS.F_Del_ImpImpres';
   BEGIN
      v_error := pac_impuestos.f_delete_impempres(pcconcep, pcempres);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, v_error, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
      END IF;

      RETURN v_error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN SQLCODE;
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
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vr_cur         sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000)
         := 'pcempres: ' || pcempres || ' pcconcep: ' || pcconcep || ' pnconcep: ' || pnconcep
            || ' pcforpag: ' || pcforpag || ' psproduc: ' || psproduc || ' pcramo: ' || pcramo
            || ' pcactivi: ' || pcactivi || ' pcgarant: ' || pcgarant || ' pfinivig: '
            || pfinivig || ' pffinvig: ' || pffinvig;
      v_object       VARCHAR2(200) := 'PAC_MD_IMPUESTOS.F_Get_Imprec';
      v_pfinivig     VARCHAR2(100);
      v_pffinvig     VARCHAR2(100);
      v_producto     VARCHAR2(200);
   BEGIN
      IF pfinivig IS NOT NULL THEN
         v_pfinivig := CHR(39) || TO_CHAR(pfinivig, 'ddmmyyyy') || CHR(39);
      ELSE
         v_pfinivig := 'to_char(i.finivig,''ddmmyyyy'')';
      END IF;

      IF pffinvig IS NOT NULL THEN
         v_pffinvig := CHR(39) || TO_CHAR(pffinvig, 'ddmmyyyy') || CHR(39);
      ELSE
         v_pffinvig := 'to_char(i.ffinvig,''ddmmyyyy'')';
      END IF;

      SELECT DECODE
                (psproduc,
                 NULL, 'null',
                 TO_CHAR(psproduc)
                 || ' and p.cramo = i.cramo AND p.cmodali = i.cmodali  AND p.ctipseg = i.ctipseg AND p.ccolect = i.ccolect ')
        INTO v_producto
        FROM DUAL;

      vr_cur :=
         pac_md_listvalores.f_opencursor
            ('SELECT i.cconcep, v1.tatribu descconcep, i.cramo, r.tramo descramo, i.cmodali,'
             || ' i.ctipseg, i.ccolect, i.cactivi, a.tactivi descactivi, i.cgarant,'
             || ' g.tgarant descgarant, i.finivig, i.ffinvig, i.cforpag,'
             || ' v2.tatribu descforpag, i.ctipcon, v3.tatribu desctipcon, i.nvalcon, i.cbonifi,'
             || ' i.crecfra, i.cfracci, i.cempres, i.nconcep,'
             -- Mantis 9648: IAX - mto. de impuestos.10/06/2009.NMM.i.
             || ' f_desproducto_t(i.cramo, i.cmodali, i.ctipseg, i.ccolect, 1, '
             || pac_md_common.f_get_cxtidioma || ') desc_prod,'   -- Mantis 9648.f.
             || ' (select pp.sproduc' || ' from productos pp' || ' where pp.cramo = i.cramo'
             || ' AND pp.cmodali = i.cmodali' || ' AND pp.ctipseg = i.ctipseg'
             || ' AND pp.ccolect = i.ccolect) sproduc' || ' FROM imprec i,'
             || ' detvalores v1,' || ' ramos r,' || ' garangen g,' || ' activisegu a,'
             || ' productos p,' || ' detvalores v2,' || ' detvalores v3'
             || ' WHERE v1.cvalor = 27' || ' AND v1.catribu = i.cconcep'
             || ' AND v1.cidioma = ' || pac_md_common.f_get_cxtidioma
             || ' AND r.cramo(+) = i.cramo' || ' AND r.cidioma(+) = '
             || pac_md_common.f_get_cxtidioma || ' AND g.cgarant(+) = i.cgarant'
             || ' AND g.cidioma(+) = ' || pac_md_common.f_get_cxtidioma
             || ' AND a.cactivi(+) = i.cactivi' || ' AND a.cramo(+) = i.cramo'
             || ' AND a.cidioma(+) = ' || pac_md_common.f_get_cxtidioma
             || ' AND v2.cvalor(+) = 17' || ' AND v2.catribu(+) = i.cforpag'
             || ' AND v2.cidioma(+) = ' || pac_md_common.f_get_cxtidioma
             || ' AND v3.cvalor = 313' || ' AND v3.catribu = i.ctipcon' || ' AND v3.cidioma = '
             || pac_md_common.f_get_cxtidioma || ' AND p.cramo(+) = i.cramo'
             || ' AND p.cmodali(+) = i.cmodali' || ' AND p.ctipseg(+) = i.ctipseg'
             || ' AND p.ccolect(+) = i.ccolect' || ' AND p.sproduc(+) = ' || v_producto
             || ' AND i.cempres = ' || NVL(TO_CHAR(pcempres), 'i.cempres')
             || ' AND i.cconcep = ' || NVL(TO_CHAR(pcconcep), 'i.cconcep')
             || ' AND i.nconcep = ' || NVL(TO_CHAR(pnconcep), 'i.nconcep')
             || ' AND nvl(i.cforpag,''1'') = '
             || NVL(TO_CHAR(pcforpag), 'nvl(i.cforpag,''1'')') || ' AND nvl(i.cramo,''1'') = '
             || NVL(TO_CHAR(pcramo), 'nvl(i.cramo,''1'')') || ' AND nvl(i.cactivi,''1'') = '
             || NVL(TO_CHAR(pcactivi), 'nvl(i.cactivi,''1'')')
             || ' AND nvl(i.cgarant,''1'') = '
             || NVL(TO_CHAR(pcgarant), 'nvl(i.cgarant,''1'')') || ' AND i.finivig >= to_date('
             || v_pfinivig || ',''ddmmyyyy'')' || ' AND (i.ffinvig is null'
             || ' OR i.ffinvig <= to_date(' || v_pffinvig || ',''ddmmyyyy''))',
             mensajes);
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER(8);
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000)
         := 'pcempres: ' || pcempres || ' pcconcep: ' || pcconcep || ' pnconcep: ' || pnconcep
            || ' pcforpag: ' || pcforpag || ' pcramo: ' || pcramo || ' psproduc: ' || psproduc
            || ' pcactivi: ' || pcactivi || ' pcgarant: ' || pcgarant || ' pctipcon: '
            || pctipcon || ' pfinivig: ' || pfinivig;
      v_object       VARCHAR2(200) := 'PAC_MD_IMPUESTOS.F_Set_Imprec';
   BEGIN
      IF pcconcep IS NULL
         OR pcempres IS NULL
         OR pfinivig IS NULL
         OR pctipcon IS NULL
         OR pnvalcon IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_impuestos.f_insert_imprec(pcconcep, pcempres, pnconcep, pcforpag, pcramo,
                                               psproduc, pcactivi, pcgarant, pfinivig,
                                               pctipcon, pnvalcon, pcfracci, pcbonifi,
                                               pcrecfra);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, v_error);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param,
                                           v_error);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_imprec;

   /*************************************************************************
      Recupera los conceptos de recibo que se consideran impuestos o recargos
      param out mensajes : mesajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_cconcep(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vr_cur         sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000) := '';
      v_object       VARCHAR2(200) := 'PAC_MD_IMPUESTOS.F_Get_Cconcep';
   BEGIN
      vr_cur :=
         pac_md_listvalores.f_opencursor
            ('SELECT catribu, tatribu
                   FROM detvalores
                  WHERE cvalor = 27
                    AND catribu in (2,4,5,6,7,8)
                    AND cidioma = '
             || pac_md_common.f_get_cxtidioma || ' ORDER by tatribu',
             mensajes);
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
   FUNCTION f_get_cconcep_emp(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vr_cur         sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000) := pcempres;
      v_object       VARCHAR2(200) := 'PAC_MD_IMPUESTOS.F_Get_Cconcep_Emp';
   BEGIN
      vr_cur :=
         pac_md_listvalores.f_opencursor
            ('SELECT v.catribu, v.tatribu
                   FROM detvalores v, imp_empres e
                  WHERE v.cvalor = 27
                    AND v.catribu in (2,4,5,6,7,8)
                    AND v.cidioma = '
             || pac_md_common.f_get_cxtidioma
             || ' AND v.catribu = e.cconcep
                    AND e.cempres = ' || pcempres || ' ORDER by v.tatribu',
             mensajes);
      RETURN vr_cur;
   EXCEPTION
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
   FUNCTION f_get_cforpag(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vr_cur         sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000) := 'psproduc: ' || psproduc;
      v_object       VARCHAR2(200) := 'PAC_MD_IMPUESTOS.F_Get_Cforpag';
   BEGIN
      IF psproduc IS NULL THEN
         vr_cur := pac_md_listvalores.f_detvalores(17, mensajes);
         RETURN vr_cur;
      END IF;

      vr_cur :=
         pac_md_listvalores.f_opencursor
            ('select distinct v.catribu, v.tatribu
                   from forpagpro f, productos p, detvalores v
                  where v.cvalor = 17
                    and v.cidioma = pac_md_common.f_get_cxtidioma
                    and v.catribu = f.cforpag
                    and p.sproduc = nvl('
             || psproduc
             || ',p.sproduc)
                    and p.cramo = f.cramo
                    and p.cmodali = f.cmodali
                    and p.ctipseg = f.ctipseg
                    and p.ccolect = f.ccolect
                  ORDER by v.tatribu',
             mensajes);
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER(8);
      vobjectname    VARCHAR2(100) := 'PAC_MD_IMPUESTOS.f_del_imprec';
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

      v_error := pac_impuestos.f_del_imprec(pcconcep, pcempres, pnconcep, pcforpag, pfinivig);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, v_error);
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
      param in out mensajes  : mensajes de error

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER(8);
      vobjectname    VARCHAR2(100) := 'PAC_MD_IMPUESTOS.f_get_recargo';
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

      v_error := pac_impuestos.f_get_recargo(pcconcep, pcempres, pnconcep, pfinivig, pctipcon,
                                             pnvalcon, pcbonifi, pcfracci, pcrecfra);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, v_error);
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
END pac_md_impuestos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_IMPUESTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_IMPUESTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_IMPUESTOS" TO "PROGRAMADORESCSI";
