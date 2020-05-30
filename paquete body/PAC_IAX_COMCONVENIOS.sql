--------------------------------------------------------
--  DDL for Package Body PAC_IAX_COMCONVENIOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_COMCONVENIOS" AS
   /******************************************************************************
     NOMBRE:     pac_iax_comconvenios
     PROPÓSITO:  Package para gestionar los convenios de sobrecomisión

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        11/02/2012   FAL             0025988: LCOL_C004: Realizar desarrollo Convenio Liberty web
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_get_lstconvenios(
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      pcramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_iax_comconvenios.f_get_lstconvenios';
      vpar           VARCHAR2(500)
         := ' s=' || psproduc || ' a=' || pcagente || ' f=' || pfinivig || ' ff=' || pffinvig
            || ' r=' || pcramo;
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      cur := pac_md_comconvenios.f_get_lstconvenios(pac_md_common.f_get_cxtempresa, psproduc,
                                                    pcagente, pfinivig, pffinvig, pcramo,
                                                    mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN cur;
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
   END f_get_lstconvenios;

   FUNCTION f_get_convenio_vig(
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
      vobj           VARCHAR2(500) := 'pac_iax_comconvenios.f_get_convenio_vig';
      vpar           VARCHAR2(500) := 's=' || pscomconv_in || ' f=' || pfinivig_in;
      numerr         NUMBER;
   BEGIN
      IF pscomconv_in IS NULL
         OR pfinivig_in IS NULL THEN
         RAISE e_param_error;
      END IF;

      numerr := pac_md_comconvenios.f_get_convenio_vig(pac_md_common.f_get_cxtempresa,
                                                       pscomconv_in, pfinivig_in, ptconvenio,
                                                       pcagente, ptnomage, pffinvig, piimporte,
                                                       pfanul, mensajes);
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
   END f_get_convenio_vig;

   FUNCTION f_get_prodconvenio(pscomconv IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_iax_comconvenios.f_get_prodconvenio';
      vpar           VARCHAR2(500) := 's=' || pscomconv;
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      cur := pac_md_comconvenios.f_get_prodconvenio(pac_md_common.f_get_cxtempresa, pscomconv,
                                                    mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN cur;
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
   END f_get_prodconvenio;

   FUNCTION f_get_modcom_conv(
      pscomconv IN NUMBER,
      pfinivig IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_iax_comconvenios.f_get_prodconvenio';
      vpar           VARCHAR2(500) := 's=' || pscomconv;
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      cur := pac_md_comconvenios.f_get_modcom_conv(pac_md_common.f_get_cxtempresa, pscomconv,
                                                   pfinivig, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN cur;
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
   END f_get_modcom_conv;

   FUNCTION f_val_convenio(
      pcmodo IN NUMBER,
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
      vobj           VARCHAR2(500) := 'pac_iax_comconvenios.f_get_prodconvenio';
      vpar           VARCHAR2(500)
         := 'm=' || pcmodo || 's=' || pscomconv || 't=' || ptconvenio || 'a=' || pcagente
            || 'f=' || pfinivig || 'ff=' || pffinvig || 'i=' || piimporte || 'fa=' || pfanul;
      numerr         NUMBER;
   BEGIN
      vpas := 1;

      IF pcmodo IS NULL
         OR ptconvenio IS NULL
         OR pcagente IS NULL
         OR pfinivig IS NULL
         OR pffinvig IS NULL
         OR piimporte IS NULL THEN
         RAISE e_param_error;
      END IF;

      numerr := pac_md_comconvenios.f_val_convenio(pcmodo, pac_md_common.f_get_cxtempresa,
                                                   pscomconv, ptconvenio, pcagente, pfinivig,
                                                   pffinvig, piimporte, pfanul, mensajes);
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
   END f_val_convenio;

   FUNCTION f_val_prod_convenio(
      pscomconv IN NUMBER,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      psproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_iax_comconvenios.f_val_prod_convenio';
      vpar           VARCHAR2(500)
         := 's=' || pscomconv || 'a=' || pcagente || 'f=' || pfinivig || 'ff=' || pffinvig
            || 'p=' || psproduc;
      numerr         NUMBER;
   BEGIN
      vpas := 1;
      numerr := pac_md_comconvenios.f_val_prod_convenio(pac_md_common.f_get_cxtempresa,
                                                        pscomconv, pcagente, pfinivig,
                                                        pffinvig, psproduc, mensajes);
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
      pscomconv IN NUMBER,
      pcmodcom IN NUMBER,
      ppcomisi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_iax_comconvenios.f_val_modcom_convenio';
      vpar           VARCHAR2(500)
                                  := 's=' || pscomconv || 'c=' || pcmodcom || 'm=' || ppcomisi;
      numerr         NUMBER;
   BEGIN
      vpas := 1;
      numerr := pac_md_comconvenios.f_val_modcom_convenio(pac_md_common.f_get_cxtempresa,
                                                          pscomconv, pcmodcom, ppcomisi,
                                                          mensajes);
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
   END f_val_modcom_convenio;

   FUNCTION f_alta_convenio(
      pscomconv IN NUMBER,
      ptconvenio IN VARCHAR2,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      piimporte IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_iax_comconvenios.f_alta_convenio';
      vpar           VARCHAR2(500)
         := 's=' || pscomconv || 't=' || ptconvenio || 'a=' || pcagente || 'f=' || pfinivig
            || 'ff=' || pffinvig || 'i=' || piimporte;
      numerr         NUMBER;
   BEGIN
      vpas := 1;
      numerr := pac_md_comconvenios.f_alta_convenio(pac_md_common.f_get_cxtempresa, pscomconv,
                                                    ptconvenio, pcagente, pfinivig, pffinvig,
                                                    piimporte, mensajes);
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
      pscomconv IN NUMBER,
      psproduc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_iax_comconvenios.f_alta_prod_convenio';
      vpar           VARCHAR2(500) := 's=' || pscomconv || 'p=' || psproduc;
      numerr         NUMBER;
   BEGIN
      vpas := 1;
      numerr := pac_md_comconvenios.f_alta_prod_convenio(pac_md_common.f_get_cxtempresa,
                                                         pscomconv, psproduc, mensajes);
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
      pscomconv IN NUMBER,
      pcmodcom IN NUMBER,
      pfinivig IN DATE,
      ppcomisi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_iax_comconvenios.f_alta_modcom_convenio';
      vpar           VARCHAR2(500)
              := 's=' || pscomconv || 'c=' || pcmodcom || 'f=' || pfinivig || 'p=' || ppcomisi;
      numerr         NUMBER;
   BEGIN
      vpas := 1;
      numerr := pac_md_comconvenios.f_alta_modcom_convenio(pac_md_common.f_get_cxtempresa,
                                                           pscomconv, pcmodcom, pfinivig,
                                                           ppcomisi, mensajes);
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
      vobj           VARCHAR2(500) := 'pac_iax_comconvenios.f_set_convenio_fec';
      vpar           VARCHAR2(500)
         := 'm=' || pcmodo || 's=' || pscomconv || 't=' || ptconvenio || 'a=' || pcagente
            || 'f=' || pfinivig || 'ff=' || pffinvig || 'i=' || piimporte || 'fa=' || pfanul;
      numerr         NUMBER;
   BEGIN
      vpas := 1;
      numerr := pac_md_comconvenios.f_set_convenio_fec(pac_md_common.f_get_cxtempresa, pcmodo,
                                                       pscomconv, ptconvenio, pcagente,
                                                       pfinivig, pffinvig, piimporte, pfanul,
                                                       pfinivig_out, mensajes);
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

   FUNCTION f_alta_convenio_web(
      pcmodo IN NUMBER,
      pscomconv IN NUMBER,
      ptconvenio IN VARCHAR2,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      pfanul IN DATE,
      piimporte IN NUMBER,
      plistaprods IN t_iax_info,
      plistacomis IN t_iax_info,
      pfinivig_out OUT DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_iax_comconvenios.f_alta_convenio_web';
      vpar           VARCHAR2(500)
         := 't=' || ptconvenio || 'a=' || pcagente || 'f=' || pfinivig || 'ff=' || pffinvig
            || 'i=' || piimporte;
      numerr         NUMBER;
      vfinivig       DATE;
      vvalor         NUMBER;
   BEGIN
      vpas := 1;
      numerr := pac_iax_comconvenios.f_val_convenio(pcmodo, pscomconv, ptconvenio, pcagente,
                                                    pfinivig, pffinvig, piimporte, pfanul,
                                                    mensajes);

      IF numerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpas := 2;

      IF pcmodo = 1 THEN
         IF plistaprods IS NULL
            OR plistaprods.COUNT = 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904591);
            RETURN 1;
         END IF;

         FOR j IN plistaprods.FIRST .. plistaprods.LAST LOOP
            IF plistaprods(j).seleccionado = 1 THEN
               IF plistaprods(j).nombre_columna = 'SPRODUC' THEN
                  numerr :=
                     pac_iax_comconvenios.f_val_prod_convenio(pscomconv, pcagente, pfinivig,
                                                              pffinvig,
                                                              plistaprods(j).valor_columna,
                                                              mensajes);

                  IF numerr <> 0 THEN
                     RAISE e_object_error;
                  END IF;
               END IF;
            END IF;
         END LOOP;
      END IF;

      vpas := 3;

      IF pcmodo <> 2
         OR(pcmodo = 2
            AND pfanul IS NULL) THEN
         FOR i IN plistacomis.FIRST .. plistacomis.LAST LOOP
            IF plistacomis(i).valor_columna IS NOT NULL THEN
               IF NVL(pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa(),
                                                    'SISTEMA_NUMERICO_BD'),
                      ',.') = '.,' THEN
                  vvalor := TO_NUMBER(REPLACE(plistacomis(i).valor_columna, ',', '.'));
               ELSE
                  vvalor := TO_NUMBER(plistacomis(i).valor_columna);
               END IF;

               numerr :=
                  pac_iax_comconvenios.f_val_modcom_convenio(pscomconv,
                                                             plistacomis(i).nombre_columna,
                                                             vvalor, mensajes);

               IF numerr <> 0 THEN
                  RAISE e_object_error;
               END IF;
            END IF;
         END LOOP;
      END IF;

      vpas := 4;

      IF pcmodo = 1 THEN
         numerr := pac_iax_comconvenios.f_alta_convenio(pscomconv, ptconvenio, pcagente,
                                                        pfinivig, pffinvig, piimporte,
                                                        mensajes);
      ELSE
         numerr := pac_iax_comconvenios.f_set_convenio_fec(pcmodo, pscomconv, ptconvenio,
                                                           pcagente, pfinivig, pffinvig,
                                                           piimporte, pfanul, pfinivig_out,
                                                           mensajes);
      END IF;

      IF numerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpas := 5;

      IF pcmodo = 1 THEN
         FOR j IN plistaprods.FIRST .. plistaprods.LAST LOOP
            IF plistaprods(j).seleccionado = 1 THEN
               IF plistaprods(j).nombre_columna = 'SPRODUC' THEN
                  numerr :=
                     pac_iax_comconvenios.f_alta_prod_convenio(pscomconv,
                                                               plistaprods(j).valor_columna,
                                                               mensajes);

                  IF numerr <> 0 THEN
                     RAISE e_object_error;
                  END IF;
               END IF;
            END IF;
         END LOOP;
      END IF;

      vpas := 6;

      IF pcmodo <> 2
         OR(pcmodo = 2
            AND pfanul IS NULL) THEN
         IF pcmodo = 1
            OR pcmodo = 3 THEN
            vfinivig := pfinivig;
         ELSE
            vfinivig := pfinivig_out;
         END IF;

         FOR i IN plistacomis.FIRST .. plistacomis.LAST LOOP
            IF plistacomis(i).valor_columna IS NOT NULL THEN
               IF NVL(pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa(),
                                                    'SISTEMA_NUMERICO_BD'),
                      ',.') = '.,' THEN
                  vvalor := TO_NUMBER(REPLACE(plistacomis(i).valor_columna, ',', '.'));
               ELSE
                  vvalor := TO_NUMBER(plistacomis(i).valor_columna);
               END IF;

               numerr :=
                  pac_iax_comconvenios.f_alta_modcom_convenio(pscomconv,
                                                              plistacomis(i).nombre_columna,
                                                              vfinivig, vvalor, mensajes);

               IF numerr <> 0 THEN
                  RAISE e_object_error;
               END IF;
            END IF;
         END LOOP;
      END IF;

      COMMIT;

      IF numerr = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9905541);
      END IF;

      RETURN numerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_alta_convenio_web;

   FUNCTION f_get_next_conv(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'pac_iax_comconvenios.f_get_next_conv';
      vpar           VARCHAR2(500);
   BEGIN
      RETURN pac_md_comconvenios.f_get_next_conv(mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_next_conv;
END pac_iax_comconvenios;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMCONVENIOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMCONVENIOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMCONVENIOS" TO "PROGRAMADORESCSI";
