--------------------------------------------------------
--  DDL for Package Body PAC_MD_COMCONVENIOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_COMCONVENIOS" AS
   /******************************************************************************
     NOMBRE:     pac_md_comconvenios
     PROPÓSITO:  Package para gestionar los convenios de sobrecomisión

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        11/02/2012   FAL             0025988: LCOL_C004: Realizar desarrollo Convenio Liberty web
     2.0        29/11/2013   JDS             0028964: Errores varios en comisiones Liberty Web (Oleoducto)
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_get_lstconvenios(
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      pcramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comconvenios.f_get_lstconvenios';
      vpar           VARCHAR2(500)
         := 'e=' || pcempres || ' s=' || psproduc || ' a=' || pcagente || ' f=' || pfinivig
            || ' ff=' || pffinvig;
      vsquery        VARCHAR2(2000);
      cur            sys_refcursor;
      v_ini          VARCHAR2(8);
      v_fin          VARCHAR2(8);
   BEGIN
      vpas := 1;
      vsquery :=
         'select c.scomconv,c.tconvenio,cf.finivig,cf.ffinvig,c.fanul,decode(cf.cestado,0,1,0) eseditable'
         || ' from comconvenios c, comconvenios_fec cf' || ' where c.scomconv = cf.scomconv';

      IF pcempres IS NOT NULL THEN
         vpas := 10;
         vsquery := vsquery || ' and c.cempres=' || pcempres;
      ELSE
         RAISE e_param_error;
      END IF;

      IF psproduc IS NOT NULL THEN
         vpas := 30;
         vsquery :=
            vsquery
            || ' and c.SCOMCONV IN (select SCOMCONV from COMCONVENIOS_PROD where cempres = c.cempres and sproduc ='
            || psproduc || ')';
      ELSE
         --Inici Bug 27857/150664 - 07/08/2013 - RCL: Afegim filtre per RAMO
         IF pcramo IS NOT NULL THEN
            vpas := 35;
            vsquery :=
               vsquery
               || ' and c.SCOMCONV IN (select SCOMCONV from COMCONVENIOS_PROD where cempres = c.cempres and sproduc IN (select sproduc from productos where cramo = '
               || pcramo || ') )';
         END IF;
      --Fi Bug 27857/150664 - 07/08/2013 - RCL: Afegim filtre per RAMO
      END IF;

      IF pcagente IS NOT NULL THEN
         vpas := 40;
         vsquery := vsquery || ' and c.cagente=' || pcagente;
      END IF;

      IF pfinivig IS NOT NULL THEN
         vpas := 50;
         v_ini := TO_CHAR(pfinivig, 'yyyymmdd');
         vsquery := vsquery || ' and to_char(finivig,''yyyymmdd'') >=' || v_ini;
      END IF;

      IF pffinvig IS NOT NULL THEN
         vpas := 60;
         v_fin := TO_CHAR(pffinvig, 'yyyymmdd');
         vsquery := vsquery || ' and to_char(ffinvig,''yyyymmdd'') <=' || v_fin;
      END IF;

      vsquery := vsquery || ' order by c.scomconv,cf.finivig desc';

      IF vsquery IS NULL THEN
         vpas := 70;
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_lstconvenios;

   FUNCTION f_get_convenio_vig(
      pcempres_in IN NUMBER,
      pscomconv_in IN NUMBER,
      pfinivig_in IN DATE,
      ptconvenio OUT VARCHAR2,
      pcagente OUT NUMBER,
      ptnomage OUT VARCHAR2,
      pffinvig OUT DATE,
      piimporte OUT NUMBER,
      pfanul OUT DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comconvenios.f_get_convenio_vig';
      vpar           VARCHAR2(500)
                        := 'e=' || pcempres_in || 's=' || pscomconv_in || ' f=' || pfinivig_in;
   BEGIN
      SELECT c.tconvenio, c.cagente, f_nombre(a.sperson, 3), f.ffinvig, f.importe, c.fanul
        INTO ptconvenio, pcagente, ptnomage, pffinvig, piimporte, pfanul
        FROM comconvenios c, comconvenios_fec f, agentes a
       WHERE c.cempres = pcempres_in
         AND c.scomconv = pscomconv_in
         AND TO_CHAR(f.finivig, 'yyyymmdd') = TO_CHAR(pfinivig_in, 'yyyymmdd')
         AND c.scomconv = f.scomconv
         AND c.cempres = f.cempres
         AND c.cagente = a.cagente;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_convenio_vig;

   FUNCTION f_get_prodconvenio(
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comconvenios.f_get_prodconvenio';
      vpar           VARCHAR2(500) := 'e=' || pcempres || 's=' || pscomconv;
      vsquery        VARCHAR2(2000);
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      vsquery :=
         'SELECT c.sproduc, F_DESPRODUCTO_T(p.cramo,p.cmodali,p.ctipseg,p.ccolect,1,pac_md_common.f_get_cxtidioma) tproduc'
         || ' FROM COMCONVENIOS_PROD c, PRODUCTOS p where 1=1 AND c.sproduc = p.sproduc';

      IF pcempres IS NOT NULL THEN
         vpas := 10;
         vsquery := vsquery || ' and c.cempres=' || pcempres;
      ELSE
         RAISE e_param_error;
      END IF;

      IF pscomconv IS NOT NULL THEN
         vpas := 20;
         vsquery := vsquery || ' and c.scomconv=' || pscomconv;
      END IF;

      IF vsquery IS NULL THEN
         vpas := 30;
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_prodconvenio;

   FUNCTION f_get_modcom_conv(
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      pfinivig IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comconvenios.f_get_modcom_conv';
      vpar           VARCHAR2(500)
                                  := 'e=' || pcempres || 's=' || pscomconv || 'f=' || pfinivig;
      vsquery        VARCHAR2(2000);
      cur            sys_refcursor;
   BEGIN
      vpas := 1;

      IF pscomconv IS NULL THEN
         vsquery :=
            'SELECT catribu cmodcom, tatribu tmodcom, null pcomisi FROM detvalores where cvalor = 67 and cidioma = pac_md_common.f_get_cxtidioma';
      ELSE
         vsquery :=
            'SELECT d.catribu cmodcom, d.tatribu tmodcom, c.pcomisi pcomisi FROM COMCONVENIOS_MOD c, DETVALORES d where c.scomconv(+) = '
            || pscomconv
            || ' AND c.cmodcom(+) = d.catribu AND d.cvalor = 67 AND d.cidioma = pac_md_common.f_get_cxtidioma';

         IF pcempres IS NOT NULL THEN
            vpas := 10;
            vsquery := vsquery || ' and c.cempres(+)=' || pcempres;
         ELSE
            RAISE e_param_error;
         END IF;

         IF pfinivig IS NOT NULL THEN
            vpas := 10;
            vsquery := vsquery || ' and to_char(c.finivig(+),''yyyymmdd'')='
                       || TO_CHAR(pfinivig, 'yyyymmdd');
         END IF;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_modcom_conv;

   FUNCTION f_val_convenio(
      pcmodo IN NUMBER,
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      ptconvenio IN VARCHAR2,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      piimporte IN NUMBER,
      pfanul IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comconvenios.f_val_convenio';
      vpar           VARCHAR2(500)
         := 'm=' || pcmodo || 'e=' || pcempres || 's=' || pscomconv || 't=' || ptconvenio
            || 'a=' || pcagente || 'f=' || pfinivig || 'ff=' || pffinvig || 'i=' || piimporte
            || 'fa=' || pfanul;
      numerr         NUMBER;
   BEGIN
      vpas := 1;

      IF pcmodo IS NULL
         OR pcempres IS NULL
         OR ptconvenio IS NULL
         OR pcagente IS NULL
         OR pfinivig IS NULL
         OR pffinvig IS NULL
         OR piimporte IS NULL THEN
         RAISE e_param_error;
      END IF;

      numerr := pac_comconvenios.f_val_convenio(pcmodo, pcempres, pscomconv, ptconvenio,
                                                pcagente, pfinivig, pffinvig, piimporte,
                                                pfanul);

      IF numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
      END IF;

      RETURN numerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_val_convenio;

   FUNCTION f_val_prod_convenio(
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      psproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comconvenios.f_val_prod_convenio';
      vpar           VARCHAR2(500)
         := 'e=' || pcempres || 's=' || pscomconv || 'a=' || pcagente || 'f=' || pfinivig
            || 'ff=' || pffinvig || 'p=' || psproduc;
      numerr         NUMBER;
   BEGIN
      vpas := 1;
      numerr := pac_comconvenios.f_val_prod_convenio(pcempres, pscomconv, pcagente, pfinivig,
                                                     pffinvig, psproduc);

      IF numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
      END IF;

      RETURN numerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_val_prod_convenio;

   FUNCTION f_val_modcom_convenio(
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      pcmodcom IN NUMBER,
      ppcomisi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comconvenios.f_val_modcom_convenio';
      vpar           VARCHAR2(500)
              := 'e=' || pcempres || 's=' || pscomconv || 'c=' || pcmodcom || 'm=' || ppcomisi;
      numerr         NUMBER;
   BEGIN
      vpas := 1;
      numerr := pac_comconvenios.f_val_modcom_convenio(pcempres, pscomconv, pcmodcom,
                                                       ppcomisi);

      IF numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
      END IF;

      RETURN numerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_val_modcom_convenio;

   FUNCTION f_alta_convenio(
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      ptconvenio IN VARCHAR2,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      piimporte IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comconvenios.f_alta_convenio';
      vpar           VARCHAR2(500)
         := 'e=' || pcempres || 's=' || pscomconv || 't=' || ptconvenio || 'a=' || pcagente
            || 'f=' || pfinivig || 'ff=' || pffinvig || 'i=' || piimporte;
      numerr         NUMBER;
   BEGIN
      vpas := 1;
      numerr := pac_comconvenios.f_alta_convenio(pcempres, pscomconv, ptconvenio, pcagente,
                                                 pfinivig, pffinvig, piimporte);

      IF numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
      END IF;

      RETURN numerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_alta_convenio;

   FUNCTION f_alta_prod_convenio(
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      psproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comconvenios.f_alta_prod_convenio';
      vpar           VARCHAR2(500)
                                  := 'e=' || pcempres || 's=' || pscomconv || 'p=' || psproduc;
      numerr         NUMBER;
   BEGIN
      vpas := 1;
      numerr := pac_comconvenios.f_alta_prod_convenio(pcempres, pscomconv, psproduc);

      IF numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
      END IF;

      RETURN numerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_alta_prod_convenio;

   FUNCTION f_alta_modcom_convenio(
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      pcmodcom IN NUMBER,
      pfinivig IN DATE,
      ppcomisi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comconvenios.f_alta_modcom_convenio';
      vpar           VARCHAR2(500)
         := 'e=' || pcempres || 's=' || pscomconv || 'c=' || pcmodcom || 'f=' || pfinivig
            || 'p=' || ppcomisi;
      numerr         NUMBER;
   BEGIN
      vpas := 1;
      numerr := pac_comconvenios.f_alta_modcom_convenio(pcempres, pscomconv, pcmodcom,
                                                        pfinivig, ppcomisi);

      IF numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
      END IF;

      RETURN numerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_alta_modcom_convenio;

   FUNCTION f_set_convenio_fec(
      pcempres IN NUMBER,
      pcmodo IN NUMBER,
      pscomconv IN NUMBER,
      ptconvenio IN VARCHAR2,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      piimporte IN NUMBER,
      pfanul IN DATE,
      pfinivig_out OUT DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comconvenios.f_set_convenio_fec';
      vpar           VARCHAR2(500)
         := 'e=' || pcempres || 'm=' || pcmodo || 's=' || pscomconv || 't=' || ptconvenio
            || 'a=' || pcagente || 'f=' || pfinivig || 'ff=' || pffinvig || 'i=' || piimporte
            || 'fa=' || pfanul;
      numerr         NUMBER;
   BEGIN
      vpas := 1;
      numerr := pac_comconvenios.f_set_convenio_fec(pcempres, pcmodo, pscomconv, ptconvenio,
                                                    pcagente, pfinivig, pffinvig, piimporte,
                                                    pfanul, pfinivig_out);

      IF numerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
      END IF;

      RETURN numerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_convenio_fec;

   FUNCTION f_get_next_conv(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_md_comconvenios.f_get_next_conv';
      vpar           VARCHAR2(500);
   BEGIN
      RETURN pac_comconvenios.f_get_next_conv();
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_next_conv;
END pac_md_comconvenios;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_COMCONVENIOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_COMCONVENIOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_COMCONVENIOS" TO "PROGRAMADORESCSI";
