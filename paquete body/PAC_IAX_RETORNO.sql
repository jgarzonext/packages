--------------------------------------------------------
--  DDL for Package Body PAC_IAX_RETORNO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_RETORNO" AS
   /******************************************************************************
     NOMBRE:     PAC_IAX_RETORNO
     PROPÓSITO:  Package para gestionar los retornos de convenios beneficiarios

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        03/09/2012   JMF             0022701: LCOL: Implementación de Retorno
     2.0        28/11/2012   JMF             0024892 LCOL_C003-LCOL Q-trackers de Retornos
     3.0        22/01/2013   JMF             0025815: LCOL: Cambios para Retorno seg?n reuni?n con Comercial
   ******************************************************************************/

   -- Esta función nos devuelve un VARCHAR2 con la lista de los convenios en función de una série de valores que recibe por parámetros.
   -- BUG 0025691 - 15/01/2013 - JMF: afegir sucursal i adn
   FUNCTION f_get_lstconvenios(
      pccodconv IN VARCHAR2,
      ptdesconv IN VARCHAR2,
      pfinivig IN DATE,
      pffinvig IN DATE,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      ptnombnf IN VARCHAR2,
      psucursal IN NUMBER DEFAULT NULL,
      padnsuc IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      --
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_IAX_RETORNO.f_get_lstconvenios';
      vpar           VARCHAR2(500)
         := 'c=' || pccodconv || ' t=' || ptdesconv || ' i=' || pfinivig || ' f=' || pffinvig
            || ' r=' || pcramo || ' p=' || psproduc || ' a=' || pcagente || ' n=' || ptnombnf
            || ' s=' || psucursal || ' a=' || padnsuc;
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      cur := pac_md_retorno.f_get_lstconvenios(pccodconv, ptdesconv, pfinivig, pffinvig,
                                               pcramo, psproduc, pcagente, ptnombnf,
                                               psucursal, padnsuc, mensajes);

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

   -- Esta función nos devuelve un VARCHAR2 con los datos del convenio que se ha seleccionado en pantalla
   FUNCTION f_get_datconvenio(pidconvenio IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_IAX_RETORNO.f_get_datconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio;
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      cur := pac_md_retorno.f_get_datconvenio(pidconvenio, mensajes);

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
   END f_get_datconvenio;

   -- Esta función nos devuelve un VARCHAR2 con los datos del producto del convenio que se ha seleccionado en pantalla
   FUNCTION f_get_prodconvenio(
      pidconvenio IN NUMBER,
      pcramo OUT NUMBER,
      ptramo OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_IAX_RETORNO.f_get_prodconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio;
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      cur := pac_md_retorno.f_get_prodconvenio(pidconvenio, pcramo, ptramo, mensajes);

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

   -- Esta función nos devuelve un VARCHAR2 con los datos del agente del convenio que se ha seleccionado en pantalla
   FUNCTION f_get_ageconvenio(pidconvenio IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_IAX_RETORNO.f_get_ageconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio;
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      cur := pac_md_retorno.f_get_ageconvenio(pidconvenio, mensajes);

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
   END f_get_ageconvenio;

   -- Esta función nos devuelve un VARCHAR2 con los datos del beneficiario del convenio que se ha seleccionado en pantalla
   FUNCTION f_get_benefconvenio(pidconvenio IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_IAX_RETORNO.f_get_benefconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio;
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      cur := pac_md_retorno.f_get_benefconvenio(pidconvenio, mensajes);

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
   END f_get_benefconvenio;

   -- Esta función borra datos del agente del convenio
   FUNCTION f_del_ageconvenio(
      pidconvenio IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_IAX_RETORNO.f_del_ageconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio || ' a=' || pcagente;
      num_err        NUMBER;
   BEGIN
      vpas := 1;
      num_err := pac_md_retorno.f_del_ageconvenio(pidconvenio, pcagente, mensajes);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
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
   END f_del_ageconvenio;

   -- Esta función borra datos del beneficiario del convenio
   FUNCTION f_del_benefconvenio(
      pidconvenio IN NUMBER,
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_IAX_RETORNO.f_del_benefconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio || ' a=' || psperson;
      num_err        NUMBER;
   BEGIN
      vpas := 1;
      num_err := pac_md_retorno.f_del_benefconvenio(pidconvenio, psperson, mensajes);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
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
   END f_del_benefconvenio;

   -- Esta función actualiza datos convenio
   -- BUG 0025815 - 22/01/2013 - JMF: afegir sperson
   FUNCTION f_set_datconvenio(
      pidconvenio IN NUMBER,
      pccodconv IN VARCHAR2,
      ptdesconv IN VARCHAR2,
      pfinivig IN DATE,
      pffinvig IN DATE,
      psperson IN NUMBER,
      pidconvenio_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_IAX_RETORNO.F_SET_DATCONVENIO';
      vpar           VARCHAR2(500)
         := 'i=' || pidconvenio || ' c=' || pccodconv || ' t=' || ptdesconv || ' i='
            || pfinivig || ' f=' || pffinvig || ' p=' || psperson;
      num_err        NUMBER;
   BEGIN
      vpas := 1;
      num_err := pac_md_retorno.f_set_datconvenio(pidconvenio, pccodconv, ptdesconv, pfinivig,
                                                  pffinvig, psperson, pidconvenio_out,
                                                  mensajes);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
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
   END f_set_datconvenio;

   -- Borra la lista actual de productos asociados a un convenio,
   -- y añade los productos de la lista que le llegan de la pantalla.
   FUNCTION f_set_prodconvenio(
      pidconvenio IN NUMBER,
      plistaconve IN t_iax_info,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_IAX_RETORNO.f_set_prodconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio;
      num_err        NUMBER;
   BEGIN
      vpas := 1;
      num_err := pac_md_retorno.f_set_prodconvenio(pidconvenio, plistaconve, mensajes);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
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
   END f_set_prodconvenio;

   -- Esta función actualiza datos agente convenio
   FUNCTION f_set_ageconvenio(
      pidconvenio IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_IAX_RETORNO.f_set_ageconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio || ' a=' || pcagente;
      num_err        NUMBER;
   BEGIN
      vpas := 1;
      num_err := pac_md_retorno.f_set_ageconvenio(pidconvenio, pcagente, mensajes);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
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
   END f_set_ageconvenio;

   -- Esta función actualiza datos beneficiario convenio
   -- BUG 0025580 - 08/01/2013 - JMF
   FUNCTION f_set_benefconvenio(
      pidconvenio IN NUMBER,
      psperson IN NUMBER,
      ppretorno IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_IAX_RETORNO.f_set_benefconvenio';
      vpar           VARCHAR2(500)
                             := 'i=' || pidconvenio || ' a=' || psperson || ' p=' || ppretorno;
      num_err        NUMBER;
   BEGIN
      vpas := 1;
      num_err := pac_md_retorno.f_set_benefconvenio(pidconvenio, psperson, ppretorno,
                                                    mensajes);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
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
   END f_set_benefconvenio;

   -- Esta función nos devuelve cursor con los convenios
   FUNCTION f_get_rtnconvenios(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      --
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_IAX_RETORNO.f_get_rtnconvenios';
      vpar           VARCHAR2(500) := 's=' || psseguro || ' t=' || ptablas;
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      cur := pac_md_retorno.f_get_rtnconvenios(psseguro, ptablas, mensajes);

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
   END f_get_rtnconvenios;

   -- ini BUG 0024892 - 28/11/2012 - JMF
   -- Esta función realiza acciones sobre los campos obligatorios
   -- accion 0 = Validar si falta informacion obligatoria
   -- accion 1 = Borrar estructura del convenio.
   FUNCTION f_oblig_convenio(
      pidconvenio IN NUMBER,
      paccion IN NUMBER,
      presult OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_IAX_RETORNO.f_oblig_convenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio || ' a=' || paccion;
      num_err        NUMBER;
   BEGIN
      vpas := 1;
      num_err := pac_md_retorno.f_oblig_convenio(pidconvenio, paccion, presult, mensajes);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
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
   END f_oblig_convenio;

   -- Bug 29324/161283 - 12/12/2013 - AMC
   FUNCTION f_busca_convenioretorno(pidconvenio OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_IAX_RETORNO.f_busca_convenioretorno';
      vpar           VARCHAR2(500);
      num_err        NUMBER;
      poliza         ob_iax_detpoliza;
      vtomadores     t_iax_tomadores;
      vtomador       ob_iax_tomadores;
      vspersontom    NUMBER;
   BEGIN
      poliza := pac_iobj_prod.f_getpoliza(mensajes);
      vtomadores := poliza.tomadores;

      IF vtomadores IS NOT NULL THEN
         IF vtomadores.COUNT > 0 THEN
            vtomador := vtomadores(vtomadores.FIRST);
            vspersontom := vtomador.spereal;
         END IF;
      END IF;

      num_err := pac_md_retorno.f_busca_convenioretorno(poliza.sseguro, poliza.sproduc,
                                                        poliza.gestion.fefecto, poliza.cagente,
                                                        pidconvenio, vspersontom, mensajes);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
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
   END f_busca_convenioretorno;

   --Bug 29324/166247 - 18/02/2014 - AMC
   FUNCTION f_busca_convenioretorno_pol(
      pidconvenio OUT NUMBER,
      pdonde OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_IAX_RETORNO.f_busca_convenioretorno_pol';
      vpar           VARCHAR2(500);
      num_err        NUMBER;
      poliza         ob_iax_detpoliza;
      vtomadores     t_iax_tomadores;
      vtomador       ob_iax_tomadores;
      vspersontom    NUMBER;
   BEGIN
      poliza := pac_iobj_prod.f_getpoliza(mensajes);
      vtomadores := poliza.tomadores;

      IF vtomadores IS NOT NULL THEN
         IF vtomadores.COUNT > 0 THEN
            vtomador := vtomadores(vtomadores.FIRST);
            vspersontom := vtomador.spereal;
         END IF;
      END IF;

      num_err := pac_md_retorno.f_busca_convenioretorno_pol(poliza.sseguro, poliza.sproduc,
                                                            poliza.gestion.fefecto,
                                                            poliza.cagente, pidconvenio,
                                                            vspersontom, pdonde, mensajes);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
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
   END f_busca_convenioretorno_pol;
END pac_iax_retorno;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_RETORNO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_RETORNO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_RETORNO" TO "PROGRAMADORESCSI";
