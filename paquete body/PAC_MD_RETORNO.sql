--------------------------------------------------------
--  DDL for Package Body PAC_MD_RETORNO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_RETORNO" AS
   /******************************************************************************
     NOMBRE:     PAC_MD_RETORNO
     PROPÓSITO:  Package para gestionar los retornos de convenios beneficiarios

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        03/09/2012   JMF             0022701: LCOL: Implementación de Retorno
     2.0        24/10/2012   JMF             0024132 LCOL_C003-LCOL Resoldre incidncies en el manteniment de Retorno
     3.0        28/11/2012   JMF             0024892 LCOL_C003-LCOL Q-trackers de Retornos
     4.0        08/01/2013   JMF             0025580: LCOL_C003-LCOL: Parametrizar tomador en el convenio de retorno
     5.0        29/01/2013   JMF             0025862: LCOL: Suplemento Retorno
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
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_MD_RETORNO.f_get_lstconvenios';
      vpar           VARCHAR2(500)
         := 'c=' || pccodconv || ' t=' || ptdesconv || ' i=' || pfinivig || ' f=' || pffinvig
            || ' r=' || pcramo || ' p=' || psproduc || ' a=' || pcagente || ' n=' || ptnombnf
            || ' s=' || psucursal || ' a=' || padnsuc;
      vsquery        VARCHAR2(2000);
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      vsquery := pac_retorno.f_get_lstconvenios(pccodconv, ptdesconv, pfinivig, pffinvig,
                                                pcramo, psproduc, pcagente, ptnombnf,
                                                psucursal, padnsuc);

      IF vsquery IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001846);
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

   -- Esta función nos devuelve un VARCHAR2 con los datos del convenio que se ha seleccionado en pantalla
   FUNCTION f_get_datconvenio(pidconvenio IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_MD_RETORNO.f_get_datconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio;
      vsquery        VARCHAR2(2000);
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      vsquery := pac_retorno.f_get_datconvenio(pidconvenio);

      IF vsquery IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001846);
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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
   END f_get_datconvenio;

   -- Esta función nos devuelve un VARCHAR2 con los datos del producto del convenio que se ha seleccionado en pantalla
   FUNCTION f_get_prodconvenio(
      pidconvenio IN NUMBER,
      pcramo OUT NUMBER,
      ptramo OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_MD_RETORNO.f_get_prodconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio;
      vsquery        VARCHAR2(2000);
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      vsquery := pac_retorno.f_get_prodconvenio(pidconvenio, pcramo, ptramo);

      IF vsquery IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001846);
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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

   -- Esta función nos devuelve un VARCHAR2 con los datos del agente del convenio que se ha seleccionado en pantalla
   FUNCTION f_get_ageconvenio(pidconvenio IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_MD_RETORNO.f_get_ageconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio;
      vsquery        VARCHAR2(2000);
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      vsquery := pac_retorno.f_get_ageconvenio(pidconvenio);

      IF vsquery IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001846);
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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
   END f_get_ageconvenio;

   -- Esta función nos devuelve un VARCHAR2 con los datos del beneficiario del convenio que se ha seleccionado en pantalla
   FUNCTION f_get_benefconvenio(pidconvenio IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_MD_RETORNO.f_get_benefconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio;
      vsquery        VARCHAR2(2000);
      cur            sys_refcursor;
   BEGIN
      vpas := 1;
      vsquery := pac_retorno.f_get_benefconvenio(pidconvenio);

      IF vsquery IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001846);
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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
   END f_get_benefconvenio;

   -- Esta función borra datos del agente del convenio
   FUNCTION f_del_ageconvenio(
      pidconvenio IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_MD_RETORNO.f_del_ageconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio || ' a=' || pcagente;
      num_err        NUMBER;
   BEGIN
      vpas := 100;
      num_err := pac_retorno.f_del_ageconvenio(pidconvenio, pcagente);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
      RETURN num_err;
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
   END f_del_ageconvenio;

   -- Esta función borra datos del beneficiario del convenio
   FUNCTION f_del_benefconvenio(
      pidconvenio IN NUMBER,
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_MD_RETORNO.f_del_benefconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio || ' a=' || psperson;
      num_err        NUMBER;
   BEGIN
      vpas := 100;
      num_err := pac_retorno.f_del_benefconvenio(pidconvenio, psperson);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
      RETURN num_err;
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
      pidconvenio_out IN OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_MD_RETORNO.F_SET_DATCONVENIO';
      vpar           VARCHAR2(500)
         := 'i=' || pidconvenio || ' c=' || pccodconv || ' t=' || ptdesconv || ' i='
            || pfinivig || ' f=' || pffinvig || ' p=' || psperson;
      num_err        NUMBER;
   BEGIN
      vpas := 100;
      num_err := pac_retorno.f_set_datconvenio(pidconvenio, pccodconv, ptdesconv, pfinivig,
                                               pffinvig, NULL, psperson, pidconvenio_out);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
      RETURN num_err;
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
   END f_set_datconvenio;

   -- Borra la lista actual de productos asociados a un convenio,
   -- y añade los productos de la lista que le llegan de la pantalla.
   FUNCTION f_set_prodconvenio(
      pidconvenio IN NUMBER,
      plistaconve IN t_iax_info,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_MD_RETORNO.f_set_prodconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio;
      num_err        NUMBER;
   BEGIN
      IF pidconvenio IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF plistaconve IS NULL THEN
         RETURN 0;
      END IF;

      IF plistaconve.COUNT = 0 THEN
         RETURN 0;
      END IF;

      num_err := 0;

      FOR j IN plistaconve.FIRST .. plistaconve.LAST LOOP
         IF plistaconve(j).seleccionado = 1 THEN
            IF plistaconve(j).nombre_columna = 'sproduc' THEN
               num_err := pac_retorno.f_set_prodconvenio(pidconvenio,
                                                         plistaconve(j).valor_columna);

               IF NVL(num_err, 0) <> 0 THEN
                  EXIT;
               END IF;
            END IF;
         ELSE
            -- BUG 0024132 - 24/10/2012 - JMF
            IF plistaconve(j).nombre_columna = 'sproduc' THEN
               DELETE FROM rtn_mntprodconvenio
                     WHERE idconvenio = pidconvenio
                       AND sproduc = plistaconve(j).valor_columna;
            END IF;
         END IF;
      END LOOP;

      IF NVL(num_err, 0) <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_prodconvenio;

   -- Esta función actualiza datos agente convenio
   FUNCTION f_set_ageconvenio(
      pidconvenio IN NUMBER,
      pcagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_MD_RETORNO.f_set_ageconvenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio || ' a=' || pcagente;
      num_err        NUMBER;
   BEGIN
      vpas := 100;
      num_err := pac_retorno.f_set_ageconvenio(pidconvenio, pcagente);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
      RETURN num_err;
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
      vobj           VARCHAR2(500) := 'PAC_MD_RETORNO.f_set_benefconvenio';
      vpar           VARCHAR2(500)
                             := 'i=' || pidconvenio || ' a=' || psperson || ' p=' || ppretorno;
      num_err        NUMBER;
   BEGIN
      vpas := 100;
      num_err := pac_retorno.f_set_benefconvenio(pidconvenio, psperson, ppretorno);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
      RETURN num_err;
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
   END f_set_benefconvenio;

   -- Inicializará la información del retorno
   FUNCTION f_inicializa_retorno(dtpoliza IN ob_iax_detpoliza, mensajes OUT t_iax_mensajes)
      RETURN t_iax_retorno IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_MD_RETORNO.f_inicializa_retorno';
      vpar           VARCHAR2(500);
      num_err        NUMBER;
      t_retrn        t_iax_retorno;
      vsquery        VARCHAR2(2000);
      i              NUMBER;
      cur            sys_refcursor;
      r_estcnv       estrtn_convenio%ROWTYPE;
      v_cretorno     NUMBER := 0;   -- BUG23911:DRA:18/10/2012
   BEGIN
      vpas := 10;

      IF dtpoliza IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000644);
         RAISE e_param_error;
      END IF;

      vpas := 15;

      -- BUG23911:DRA:18/10/2012:Inici
      IF pac_mdpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS', dtpoliza.sproduc) = 1
         AND NOT pac_iax_produccion.isaltacol THEN
         vpas := 16;
         num_err := pac_productos.f_get_herencia_col(dtpoliza.sproduc, 10, v_cretorno);
      END IF;

      vpas := 17;

      IF NVL(v_cretorno, 0) = 1
         AND num_err = 0 THEN
         t_retrn := dtpoliza.retorno;
      -- BUG23911:DRA:18/10/2012:Fi
      ELSE
         vpas := 18;
         num_err := pac_retorno.f_inicializa_retorno(dtpoliza.sseguro, dtpoliza.nmovimi,
                                                     dtpoliza.sproduc,
                                                     dtpoliza.gestion.fefecto,
                                                     dtpoliza.cagente, vsquery);
         vpar := SUBSTR(vsquery, 1, 500);

         IF num_err <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
            RAISE e_object_error;
         END IF;

         vpas := 20;
         cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
         i := 0;
         t_retrn := t_iax_retorno();

         LOOP
            FETCH cur
             INTO r_estcnv;

            EXIT WHEN cur%NOTFOUND;
            i := i + 1;
            t_retrn.EXTEND;
            t_retrn(i) := ob_iax_retorno();
            t_retrn(i).sseguro := r_estcnv.sseguro;
            t_retrn(i).sperson := r_estcnv.sperson;
            t_retrn(i).nmovimi := r_estcnv.nmovimi;
            t_retrn(i).pretorno := r_estcnv.pretorno;
            -- BUG 0023965 - 15/10/2012 - JMF
            t_retrn(i).idconvenio := r_estcnv.idconvenio;
         END LOOP;

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;
      END IF;

      vpas := 25;
      RETURN t_retrn;
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
   END f_inicializa_retorno;

   -- Inicializará la información del retorno del suplemento
   -- BUG 0025862 - 29/01/2013 - JMF
   FUNCTION f_suple_retorno(dtpoliza IN ob_iax_detpoliza, mensajes OUT t_iax_mensajes)
      RETURN t_iax_retorno IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_MD_RETORNO.f_suple_retorno';
      vpar           VARCHAR2(500);
      num_err        NUMBER;
      t_retrn        t_iax_retorno;
      vsquery        VARCHAR2(2000);
      i              NUMBER;
      cur            sys_refcursor;
      r_estcnv       estrtn_convenio%ROWTYPE;
      v_cretorno     NUMBER := 0;   -- BUG23911:DRA:18/10/2012
   BEGIN
      vpas := 10;

      IF dtpoliza IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000644);
         RAISE e_param_error;
      END IF;

      vpas := 17;
      vsquery :=
         'SELECT * FROM rtn_convenio a WHERE sseguro=' || dtpoliza.ssegpol
         || ' and a.nmovimi=(select max(b.nmovimi) from pregunpolseg b WHERE b.sseguro=a.sseguro)';
      vpar := SUBSTR(vsquery, 1, 500);
      vpas := 20;
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      i := 0;
      t_retrn := t_iax_retorno();

      LOOP
         FETCH cur
          INTO r_estcnv;

         EXIT WHEN cur%NOTFOUND;
         i := i + 1;
         t_retrn.EXTEND;
         t_retrn(i) := ob_iax_retorno();
         t_retrn(i).sseguro := dtpoliza.sseguro;
         t_retrn(i).sperson := r_estcnv.sperson;
         t_retrn(i).nmovimi := r_estcnv.nmovimi;
         t_retrn(i).pretorno := r_estcnv.pretorno;
         t_retrn(i).idconvenio := r_estcnv.idconvenio;
      END LOOP;

      IF cur%ISOPEN THEN
         CLOSE cur;
      END IF;

      vpas := 25;

      --Bug 29324/166247 - 20/02/2014 - AMC
      IF t_retrn IS NULL
         OR t_retrn.COUNT = 0 THEN
         t_retrn := pac_md_retorno.f_inicializa_retorno(dtpoliza, mensajes);
      END IF;

      --Fi Bug 29324/166247 - 20/02/2014 - AMC
      RETURN t_retrn;
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
   END f_suple_retorno;

   -- Esta función nos devuelve cursor con los convenios
   FUNCTION f_get_rtnconvenios(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_MD_RETORNO.f_get_rtnconvenios';
      vpar           VARCHAR2(500) := 's=' || psseguro || ' t=' || ptablas;
      vsquery        VARCHAR2(2000);
      cur            sys_refcursor;
      num_err        NUMBER;
   BEGIN
      vpas := 1;
      num_err := pac_retorno.f_get_rtnconvenios(psseguro, ptablas, vsquery);

      IF vsquery IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001846);
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
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
   END f_get_rtnconvenios;

   -- ini BUG 0024892 - 28/11/2012 - JMF
   -- Esta función realiza acciones sobre los campos obligatorios
   -- accion 0 = Validar si falta informacion obligatoria
   -- accion 1 = Borrar estructura del convenio.
   FUNCTION f_oblig_convenio(
      pidconvenio IN NUMBER,
      paccion IN NUMBER,
      presult IN OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_MD_RETORNO.f_oblig_convenio';
      vpar           VARCHAR2(500) := 'i=' || pidconvenio || ' a=' || paccion;
      num_err        NUMBER;
   BEGIN
      vpas := 100;
      num_err := pac_retorno.f_oblig_convenio(pidconvenio, paccion, presult);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

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
   END f_oblig_convenio;

   -- Bug 29324/161283 - 12/12/2013 - AMC
   FUNCTION f_busca_convenioretorno(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pcagente IN NUMBER,
      pidconvenio IN OUT NUMBER,
      ptomador IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_MD_RETORNO.f_busca_convenioretorno';
      vpar           VARCHAR2(500)
         := 'psseguro:' || psseguro || ' psproduc:' || psproduc || ' pfefecto:' || pfefecto
            || ' pcagente:' || pcagente || ' ptomador:' || ptomador;
      num_err        NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR psproduc IS NULL
         OR pfefecto IS NULL
         OR pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_retorno.f_busca_convenioretorno(psseguro, psproduc, pfefecto, pcagente,
                                                     pidconvenio, ptomador);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
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
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pcagente IN NUMBER,
      pidconvenio IN OUT NUMBER,
      ptomador IN NUMBER,
      pdonde OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER;
      vobj           VARCHAR2(500) := 'PAC_MD_RETORNO.f_busca_convenioretorno_pol';
      vpar           VARCHAR2(500)
         := 'psseguro:' || psseguro || ' psproduc:' || psproduc || ' pfefecto:' || pfefecto
            || ' pcagente:' || pcagente || ' ptomador:' || ptomador;
      num_err        NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR psproduc IS NULL
         OR pfefecto IS NULL
         OR pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_retorno.f_busca_convenioretorno_pol(psseguro, psproduc, pfefecto,
                                                         pcagente, pidconvenio, pdonde,
                                                         ptomador);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
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
END pac_md_retorno;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_RETORNO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_RETORNO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_RETORNO" TO "PROGRAMADORESCSI";
