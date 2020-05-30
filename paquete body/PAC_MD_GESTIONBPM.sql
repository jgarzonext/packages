--------------------------------------------------------
--  DDL for Package Body PAC_MD_GESTIONBPM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_GESTIONBPM" IS
/******************************************************************************
   NOMBRE:       PAC_MD_GESTIONBPM
   PROPÓSITO: Funciones para integracion de BPM con AXIS

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        27/09/2013   AMC              1. Creación del package.
   2.0        02/12/2013   FPG              2. 0028263: LCOL899-Proceso Emisi?n Vida Grupo - Desarrollo modificaciones de iAxis para BPM
                                             Aumentar la longitud de la variable vparam a 1000
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*******************************************************************************************
       FUNTION f_get_casos
       Función que retorna los casos de bpm
       param in pncaso_bpm. Número de caso BPM
       param in pnsolici_bpm. Número de solicitud BPM
       param in pcusuasignado. Usuario asignado
       param in pcestado. Estado del caso
       param in pctipmov_bpm. Tipo de movimiento
       param in pcramo. Ramo
       param in psproduc. Producto
       param in pnpoliza. Póliza
       param in pncertif. Certificado
       param in pnnumide. Número de identificación
       param in ptnomcom. Nombre del tomador

       Bug 28263/153355 - 27/09/2013 - AMC
   *******************************************************************************************/
   FUNCTION f_get_casos(
      pncaso_bpm IN NUMBER,
      pnsolici_bpm IN NUMBER,
      pcusuasignado IN VARCHAR2,
      pcestado IN NUMBER,
      pctipmov_bpm IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnomcom IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobject        VARCHAR2(500) := 'PAC_MD_BPM.f_get_casos';
      vparam         VARCHAR2(1000)
         := 'parámetros - pncaso_bpm:' || pncaso_bpm || ' pnsolici_bpm:' || pnsolici_bpm
            || ' pcusuasignado:' || pcusuasignado || ' pcestado:' || pcestado
            || ' pctipmov_bpm:' || pctipmov_bpm || ' pcramo:' || pcramo || ' psproduc:'
            || psproduc || ' pnpoliza:' || pnpoliza || ' pncertif:' || pncertif
            || ' pnnumide:' || pnnumide || ' ptnomcom:' || ptnomcom;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vselect        VARCHAR2(1000);
      cur            sys_refcursor;
   BEGIN
      vselect := 'select NNUMCASO,C.NCASO_BPM,C.NSOLICI_BPM,C.CESTADO,'
                 || ' ff_desvalorfijo(961,' || pac_md_common.f_get_cxtidioma
                 || ',C.CESTADO) TESTADO,' || ' C.NNUMIDE,C.TNOMCOM,C.SPRODUC,'
                 || ' F_DESPRODUCTO_T(P.CRAMO,P.CMODALI,P.CTIPSEG,P.CCOLECT,1,'
                 || pac_md_common.f_get_cxtidioma || ') TPRODUC,'
                 || ' C.CTIPMOV_BPM,ff_desvalorfijo(964,' || pac_md_common.f_get_cxtidioma
                 || ',C.CTIPMOV_BPM) TTIPMOV_BPM,' || ' C.NPOLIZA'
                 || ' from CASOS_BPM C, PRODUCTOS P where C.SPRODUC = P.SPRODUC'
                 || ' and C.fbaja is null and C.CAPROBADA_BPM = 1';

      IF pncaso_bpm IS NOT NULL THEN
         vselect := vselect || ' and c.ncaso_bpm = ' || pncaso_bpm;
      END IF;

      IF pnsolici_bpm IS NOT NULL THEN
         vselect := vselect || ' and c.nsolici_bpm = ' || pnsolici_bpm;
      END IF;

      IF pcusuasignado IS NOT NULL THEN
         vselect := vselect || ' and c.cusuasignado = ' || CHR(39) || pcusuasignado || CHR(39);
      END IF;

      IF pcestado IS NOT NULL THEN
         vselect := vselect || ' and c.cestado = ' || pcestado;
      END IF;

      IF pctipmov_bpm IS NOT NULL THEN
         vselect := vselect || ' and c.ctipmov_bpm = ' || pctipmov_bpm;
      END IF;

      IF pcramo IS NOT NULL THEN
         vselect := vselect
                    || ' and c.sproduc in (select sproduc from productos where cramo = '
                    || pcramo || ')';
      END IF;

      IF psproduc IS NOT NULL THEN
         vselect := vselect || ' and c.sproduc = ' || psproduc;
      END IF;

      IF pnpoliza IS NOT NULL THEN
         vselect := vselect || ' and c.npoliza = ' || pnpoliza;
      END IF;

      IF pncertif IS NOT NULL THEN
         vselect := vselect || ' and c.ncertif = ' || pncertif;
      END IF;

      IF pnnumide IS NOT NULL THEN
         --Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                              'NIF_MINUSCULAS'),
                0) = 1 THEN
            vselect := vselect || ' and UPPER(c.nnumide) = UPPER(''' || pnnumide || ''')';
         ELSE
            vselect := vselect || ' and c.nnumide = ' || CHR(39) || pnnumide || CHR(39);
         END IF;
      END IF;

      IF ptnomcom IS NOT NULL THEN
         vselect := vselect || ' and upper(c.tnomcom) like ' || CHR(39) || '%'
                    || UPPER(ptnomcom) || '%' || CHR(39);
      END IF;

      cur := pac_md_listvalores.f_opencursor(vselect, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_casos;

   /***************************************************************************************
    * Funcion f_get_tomcaso
    * Funcion que devuelve el nombre del tomador del cso BPM
    *
    * Parametros: pnnumcaso: Numero de caso
    *             pncaso_bpm: Numero de caso BPM
    *             pnsolici_bpm: Numero de solicitud BPM
    *             ptnomcom: Nombre completo del tomador
    *
    * Return: 0 OK, otro valor error.
    ****************************************************************************************/
   FUNCTION f_get_tomcaso(
      pnnumcaso IN NUMBER,
      pncaso_bpm IN NUMBER,
      pnsolici_bpm IN NUMBER,
      ptnomcom OUT VARCHAR2,
      pnnumcaso_out OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(100) := 'PAC_MD_GESTIONBPM.F_GET_TOMCASO';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'Parametros: pnnumcaso= ' || pnnumcaso || ' pncaso_bpm=' || pncaso_bpm
            || ' pnsolici_bpm:' || pnsolici_bpm;
      vnumerr        NUMBER;
   BEGIN
      IF pnnumcaso IS NULL
         AND pncaso_bpm IS NULL
         AND pnsolici_bpm IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_gestionbpm.f_get_tomcaso(pnnumcaso, pncaso_bpm, pnsolici_bpm,
                                              pac_md_common.f_get_cxtempresa, ptnomcom,
                                              pnnumcaso_out);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1000005;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1000006;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1000001;
   END f_get_tomcaso;

   /*************************************************************************
      Devuelve el caso bpm
       Parametros in: pnnumcaso: Numero de caso
                      pncaso_bpm: Numero de caso BPM
                      pnsolici_bpm: Numero de solicitud BPM
       param out mensajes : mesajes de error
      return             : caso bpm

      Bug 28263/153355 - 01/10/2013 - AMC
   *************************************************************************/
   FUNCTION f_lee_caso_bpm(
      pnnumcaso IN NUMBER,
      pncaso_bpm IN NUMBER,
      pnsolici_bpm IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_bpm IS
      num_err        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'Parametros: pnnumcaso= ' || pnnumcaso || ' pncaso_bpm=' || pncaso_bpm
            || ' pnsolici_bpm:' || pnsolici_bpm;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONBPM.f_lee_caso_bpm';
      casobpm        ob_iax_bpm;
   BEGIN
      casobpm := ob_iax_bpm();

      IF pnnumcaso IS NOT NULL THEN
         BEGIN
            SELECT nnumcaso, cusuasignado, ctipoproceso,
                   cestado, cestadoenvio, falta, fbaja,
                   cusualt, fmodifi, cusumod, sproduc,
                   cmotmov, ctipide, nnumide, tnomcom,
                   npoliza, ncertif, nmovimi, nnumcasop,
                   ncaso_bpm, nsolici_bpm, ctipmov_bpm,
                   caprobada_bpm
              INTO casobpm.nnumcaso, casobpm.cusuasignado, casobpm.ctipoproceso,
                   casobpm.cestado, casobpm.cestadoenvio, casobpm.falta, casobpm.fbaja,
                   casobpm.cusualt, casobpm.fmodifi, casobpm.cusumod, casobpm.sproduc,
                   casobpm.cmotmov, casobpm.ctipide, casobpm.nnumide, casobpm.tnomcom,
                   casobpm.npoliza, casobpm.ncertif, casobpm.nmovimi, casobpm.nnumcasop,
                   casobpm.ncaso_bpm, casobpm.nsolici_bpm, casobpm.ctipmov_bpm,
                   casobpm.caprobada_bpm
              FROM casos_bpm
             WHERE nnumcaso = pnnumcaso
               AND cempres = pac_md_common.f_get_cxtempresa;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9906039);
               RAISE e_object_error;
         END;
      ELSE
         BEGIN
            SELECT nnumcaso, cusuasignado, ctipoproceso,
                   cestado, cestadoenvio, falta, fbaja,
                   cusualt, fmodifi, cusumod, sproduc,
                   cmotmov, ctipide, nnumide, tnomcom,
                   npoliza, ncertif, nmovimi, nnumcasop,
                   ncaso_bpm, nsolici_bpm, ctipmov_bpm,
                   caprobada_bpm
              INTO casobpm.nnumcaso, casobpm.cusuasignado, casobpm.ctipoproceso,
                   casobpm.cestado, casobpm.cestadoenvio, casobpm.falta, casobpm.fbaja,
                   casobpm.cusualt, casobpm.fmodifi, casobpm.cusumod, casobpm.sproduc,
                   casobpm.cmotmov, casobpm.ctipide, casobpm.nnumide, casobpm.tnomcom,
                   casobpm.npoliza, casobpm.ncertif, casobpm.nmovimi, casobpm.nnumcasop,
                   casobpm.ncaso_bpm, casobpm.nsolici_bpm, casobpm.ctipmov_bpm,
                   casobpm.caprobada_bpm
              FROM casos_bpm
             WHERE ncaso_bpm = pncaso_bpm
               AND nsolici_bpm = NVL(pnsolici_bpm, 0)
               AND cempres = pac_md_common.f_get_cxtempresa;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9906039);
               RAISE e_object_error;
         END;
      END IF;

      RETURN casobpm;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_lee_caso_bpm;

   /*************************************************************************
      Valida los datos del caso bpm
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error

      Bug 28263/153355 - 02/10/2013 - AMC
   *************************************************************************/
   FUNCTION f_valida_datosbpm(
      poliza IN ob_iax_detpoliza,
      pmodo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      verrnum        NUMBER := 0;
      vparam         VARCHAR2(1000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONBPM.f_valida_datosbpm';
      vpasexec       NUMBER(8) := 1;
   BEGIN
      IF poliza.datos_bpm IS NOT NULL THEN
         IF poliza.datos_bpm.nnumcaso IS NOT NULL THEN
            -- El producto tenga el parámetro BPM_EMISION = 1
            IF NVL(pac_parametros.f_parproducto_n(poliza.sproduc, 'BPM_EMISION'), 0) = 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904610);
               RETURN 1;
            END IF;

            -- El nº de caso corresponda al producto seleccionado y que esté en estado "Caso recibido en iAXIS".
            IF poliza.sproduc <> poliza.datos_bpm.sproduc THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9906046);
               RETURN 1;
            ELSE
               IF poliza.datos_bpm.cestado <> 1 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9906047);
                  RETURN 1;
               END IF;
            END IF;

            -- usuario asociado al caso coincida con el usuario conectado
            IF poliza.datos_bpm.cusuasignado IS NOT NULL THEN
               IF poliza.datos_bpm.cusuasignado <> pac_md_common.f_get_cxtusuario THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9906048);
                  RETURN 1;
               END IF;
            END IF;

            IF poliza.datos_bpm.caprobada_bpm = 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9906100);
               RETURN 1;
            END IF;

            IF poliza.datos_bpm.fbaja IS NOT NULL THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9906140);
               RETURN 1;
            END IF;

            IF poliza.datos_bpm.cmotmov <> 100 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9906150);
               RETURN 1;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_datosbpm;

   /*************************************************************************
      Valida el tomador del caso bpm
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error

      Bug 28263/153355 - 02/10/2013 - AMC
   *************************************************************************/
   FUNCTION f_valida_tomadorbpm(poliza IN ob_iax_detpoliza, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      verrnum        NUMBER := 0;
      vparam         VARCHAR2(1000) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONBPM.f_valida_tomadorbpm';
      vpasexec       NUMBER(8) := 1;
      vctipide       NUMBER;
      vnnumide       VARCHAR2(50);
      vtrobat        NUMBER := 0;
   BEGIN
      IF poliza.datos_bpm IS NOT NULL THEN
         IF poliza.datos_bpm.nnumcaso IS NOT NULL THEN
            vctipide := poliza.datos_bpm.ctipide;
            vnnumide := poliza.datos_bpm.nnumide;

            IF vnnumide IS NULL THEN
               SELECT ctipide, nnumide
                 INTO vctipide, vnnumide
                 FROM casos_bpm
                WHERE ncaso_bpm = poliza.datos_bpm.ncaso_bpm
                  AND nsolici_bpm = 0
                  AND fbaja IS NULL
                  AND caprobada_bpm = 1;
            END IF;

            IF poliza.tomadores IS NOT NULL THEN
               IF poliza.tomadores.COUNT > 0 THEN
                  FOR tom IN poliza.tomadores.FIRST .. poliza.tomadores.LAST LOOP
                     IF poliza.tomadores(tom).ctipide = vctipide
                        AND poliza.tomadores(tom).nnumide = vnnumide THEN
                        vtrobat := 1;
                     END IF;
                  END LOOP;
               END IF;
            END IF;

            IF vtrobat = 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9906066);
               RETURN 1;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_tomadorbpm;

    /*************************************************************************
      Valida los datos del caso bpm para certificados
      param in pncaso_bpm: Numero de caso BPM
               pnsolici_bpm: Numero de solicitud BPM
               psproduc: Código del producto
               pnpoliza: Número de póliza
      return : 0 todo correcto
               <> 0 ha habido un error

      Bug 28263/153355 - 07/10/2013 - AMC
   *************************************************************************/
   FUNCTION f_valida_datosbpmcertif(
      pncaso_bpm IN NUMBER,
      pnsolici_bpm IN NUMBER,
      poliza IN ob_iax_detpoliza,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
                            := 'pncaso_bpm:' || pncaso_bpm || ' pnsolici_bpm:' || pnsolici_bpm;
      vobject        VARCHAR2(200) := 'PAC_MD_DATOSBPMCERTIF.f_valida_datosbpmcertif';
      v_nerror       NUMBER;
   BEGIN
      v_nerror := pac_gestionbpm.f_valida_datosbpmcertif(pac_md_common.f_get_cxtempresa,
                                                         pncaso_bpm, pnsolici_bpm,
                                                         poliza.sproduc, poliza.npoliza);

      IF v_nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_nerror);
         RETURN 1;
      END IF;

      IF poliza.datos_bpm IS NOT NULL THEN
         -- usuario asociado al caso coincida con el usuario conectado
         IF poliza.datos_bpm.cusuasignado IS NOT NULL THEN
            IF poliza.datos_bpm.cusuasignado <> pac_md_common.f_get_cxtusuario THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9906048);
               RETURN 1;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_datosbpmcertif;

/***********************************************************************
       Recupera : Retorna un objeto ob_iax_bpm y determina si se debe mostrar o no por pantalla
       param in  psseguro  : codigo de seguro
       param in  pnmovimi  : número de movimiento
       param out pmostrar : indica si se debe mostrar el caso BPM
       param out mensajes : mensajes de error
       return             : ob_iax_bpm
    ***********************************************************************/
   FUNCTION f2_get_caso_bpm(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pmostrar OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_bpm IS
      vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(1000) := 'psseguro: ' || psseguro || ', pnmovimi: ' || pnmovimi;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONBPM.f2_get_caso_bpm';
      squery         VARCHAR2(500);
      pcasobpm       ob_iax_bpm;
      vnnumcaso      NUMBER;
      vsproduc       NUMBER;
   BEGIN
      pmostrar := 0;

      IF psseguro IS NULL
         AND pnmovimi IS NULL THEN
         vpasexec := 10;
         RETURN NULL;
      ELSE
         vpasexec := 20;

         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE sseguro = psseguro;

         vpasexec := 30;

         IF NVL(pac_parametros.f_parproducto_n(vsproduc, 'BPM_EMISION'), 0) <> 0 THEN
            vpasexec := 31;
            pmostrar := 1;
            vpasexec := 40;

            BEGIN
               SELECT c2.nnumcaso
                 INTO vnnumcaso
                 FROM casos_bpmseg c1, casos_bpm c2
                WHERE c1.nnumcaso = c2.nnumcaso
                  AND c1.sseguro = psseguro
                  AND c1.nmovimi = pnmovimi
                  AND c1.cempres = c2.cempres
                  AND c1.cempres = pac_md_common.f_get_cxtempresa;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vnnumcaso := NULL;
            END;

            IF (vnnumcaso IS NOT NULL) THEN
               vpasexec := 41;
               pcasobpm := f_lee_caso_bpm(vnnumcaso, NULL, NULL, mensajes);
            END IF;
         END IF;
      END IF;

      vpasexec := 50;
      RETURN pcasobpm;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN pcasobpm;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN pcasobpm;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN pcasobpm;
   END f2_get_caso_bpm;

/*************************************************************************
      Valida los datos del caso bpm para certificados
      param in pnpoliza: Numero de póliza
               pncertif: Numero de certificado
               poperacion : Tipo de operacion.
      param out pcasobpm : Caso BPM
      return : 0 todo correcto
               <> 0 ha habido un error
   *************************************************************************/
   FUNCTION f_get_caso_bpm(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      poperacion IN VARCHAR2,
      pcasobpm OUT ob_iax_bpm,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'pnpoliza:' || pnpoliza || ' pncertif:' || pncertif || ' poperacion:'
            || poperacion;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONBPM.f_get_caso_bpm';
      v_nerror       NUMBER;
      vcount         NUMBER;
      vnnumcaso      NUMBER;
      vctipide       NUMBER;
      vnnumide       VARCHAR2(50);
      vncaso_bpm     NUMBER;
   BEGIN
      IF pcasobpm IS NULL THEN
         pcasobpm := ob_iax_bpm();
      END IF;

      IF NVL(pncertif, 0) = 0 THEN
         BEGIN
            SELECT nnumcaso
              INTO vnnumcaso
              FROM casos_bpm
             WHERE npoliza = pnpoliza
               AND ncertif = NVL(pncertif, 0)
               AND cestado = 1   --Caso recibido en iAXIS
               AND ctipmov_bpm = DECODE(poperacion,
                                        'SUPLEMENTO', 3,
                                        'ANULACION', 4,
                                        'REHABILITACION', 5)   --Suplemento certificado 0
               AND cusuasignado = pac_md_common.f_get_cxtusuario()
               AND fbaja IS NULL
               AND caprobada_bpm = 1
               AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 0;
         END;

         SELECT COUNT(nnumcaso)
           INTO vcount
           FROM casos_bpm
          WHERE npoliza = pnpoliza
            AND ncertif = NVL(pncertif, 0)
            AND(cestado = 1
                OR cestado = 10)
            AND nnumcaso != vnnumcaso
            AND fbaja IS NULL
            AND caprobada_bpm = 1;

         IF vcount = 0 THEN
            pcasobpm := f_lee_caso_bpm(vnnumcaso, NULL, NULL, mensajes);

            IF pcasobpm.tnomcom IS NULL THEN
               v_nerror := f_get_tomcaso(pcasobpm.nnumcaso, NULL, NULL, pcasobpm.tnomcom,
                                         vnnumcaso, mensajes);

               IF v_nerror <> 0 THEN
                  RAISE e_object_error;
               END IF;
            END IF;
         END IF;
      ELSE
         BEGIN
            SELECT nnumcaso, ncaso_bpm
              INTO vnnumcaso, vncaso_bpm
              FROM casos_bpm
             WHERE npoliza = pnpoliza
               AND ncertif = 0
               AND(cestado = 1
                   OR cestado = 10)
               AND ctipmov_bpm = 2   --Novedades de asegurados (Altas/Bajas/Modif)
               AND fbaja IS NULL
               AND caprobada_bpm = 1
               AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 0;
         END;

         SELECT COUNT(nnumcaso)
           INTO vcount
           FROM casos_bpm
          WHERE npoliza = pnpoliza
            AND ncertif = 0
            AND(cestado = 1
                OR cestado = 10)
            AND nnumcaso != vnnumcaso
            AND fbaja IS NULL
            AND caprobada_bpm = 1;

         IF vcount = 0 THEN
            SELECT p.ctipide, p.nnumide
              INTO vctipide, vnnumide
              FROM seguros s, tomadores t, per_personas p
             WHERE s.sseguro = t.sseguro
               AND s.npoliza = pnpoliza
               AND s.ncertif = pncertif
               AND t.sperson = p.sperson;

            BEGIN
               SELECT nnumcaso
                 INTO vnnumcaso
                 FROM casos_bpm
                WHERE ncaso_bpm = vncaso_bpm
                  AND cestado = 1
                  AND ctipide = vctipide
                  AND nnumide = vnnumide
                  AND ctipmov_bpm = DECODE(poperacion,
                                           'SUPLEMENTO', 11,
                                           'ANULACION', 12,
                                           'REHABILITACION', 13)
                  AND cusuasignado = pac_md_common.f_get_cxtusuario()
                  AND fbaja IS NULL
                  AND caprobada_bpm = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 0;
            END;

            pcasobpm := f_lee_caso_bpm(vnnumcaso, NULL, NULL, mensajes);

            IF pcasobpm.tnomcom IS NULL THEN
               v_nerror := f_get_tomcaso(pcasobpm.nnumcaso, NULL, NULL, pcasobpm.tnomcom,
                                         vnnumcaso, mensajes);

               IF v_nerror <> 0 THEN
                  RAISE e_object_error;
               END IF;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_caso_bpm;

   /***********************************************************************
       Recupera : validaciónes BPM  segun el tipo de operacion
       param in  pncaso_bpm  : numero de caso bpm
       param in  pnsolici_bpm: numero de solicitud bpm
       param in  psproduc    : codigo de producto
       param in  pnpoliza    : codigo de poliza
       param in  pncertif    : número de certificado
       param in  poperacion : Tipo de operacion
       param out mensajes    : mensajes de error
       return         NUMBER : 0--> OK , codigo error
    ***********************************************************************/
   FUNCTION f2_valida_datosbpm(
      pncaso_bpm IN NUMBER,
      pnsolici_bpm IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      poperacion IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(1000)
         := 'pncaso_bpm: ' || pncaso_bpm || ', pnsolici_bpm: ' || pnsolici_bpm
            || ', psproduc: ' || psproduc || ' ,pnpoliza: ' || pnpoliza || ', pncertif: '
            || pncertif || ', poperacion: ' || poperacion;
      vobject        VARCHAR2(200) := 'PAC_MD_BPM.f2_valida_datosbpm';
      v_nerror       NUMBER;
   BEGIN
      v_nerror := pac_gestionbpm.f_valida_datosbpm(pncaso_bpm, pnsolici_bpm, psproduc,
                                                   pnpoliza, pncertif,
                                                   pac_md_common.f_get_cxtempresa(),
                                                   poperacion);
      vpasexec := 10;

      IF (v_nerror <> 0) THEN
         vpasexec := 11;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_nerror);
      END IF;

      vpasexec := 20;
      RETURN v_nerror;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f2_valida_datosbpm;

   /*************************************************************************
      grabar registro en la tabla CASOS_BPMSEG
      param in pcempres_in
               psseguro:     identificador del seguro
               pnmovimi:     número de movimiento de seguro
               pncaso_bpm:   número del caso en el BPM
               pnsolici_bpm: número de la solicitud en el BPM
               pnnumcaso:    número del caso interno de iAxis
      return : 0 todo correcto
               <> 0 ha habido un error
   *************************************************************************/
   FUNCTION f_trata_movpoliza(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pncaso_bpm IN NUMBER,
      pnsolici_bpm IN NUMBER,
      pnnumcaso IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := ' psseguro:' || psseguro || ' pnmovimi:' || pnmovimi || ' pncaso_bpm:'
            || pncaso_bpm || ' pnsolici_bpm:' || pnsolici_bpm || ' pnnumcaso:' || pnnumcaso;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONBPM.f_trata_movpoliza';
      v_nerror       NUMBER;
      v_movimi       NUMBER;
      vsproduc       NUMBER;
      vncertif       NUMBER;
      v_nsolici_bpm  NUMBER;
   --vcont          NUMBER;
   BEGIN
      vpasexec := 10;

      BEGIN
         SELECT sproduc, ncertif
           INTO vsproduc, vncertif
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 9906020;   --Póliza informada no existe en iAxis
      END;

      IF NVL(pac_parametros.f_parproducto_n(vsproduc, 'BPM_EMISION'), 0) <> 0 THEN
         vpasexec := 20;
         v_nsolici_bpm := NVL(pnsolici_bpm, 0);

         -- Si no se informa caso, como no es obligatorio,  no hay nada más que hacer
         IF (NVL(pnnumcaso, 0) = 0
             AND NVL(pncaso_bpm, 0) = 0
             AND NVL(pnsolici_bpm, 0) = 0) THEN
            RETURN 0;
         ELSE
            IF NVL(pnnumcaso, 0) = 0 THEN
               IF NVL(pncaso_bpm, 0) = 0 THEN
                  RAISE e_param_error;
               ELSE
                  IF (vncertif = 0
                      AND v_nsolici_bpm <> 0)
                     OR(vncertif <> 0
                        AND v_nsolici_bpm = 0) THEN
                     RAISE e_param_error;
                  END IF;
               END IF;
            END IF;
         END IF;

         vpasexec := 30;

         --Si el parámetro pnmovimi es nulo, buscar el máximo nmovimi en MOVSEGURO
         IF (NVL(pnmovimi, 0) = 0) THEN
            SELECT MAX(nmovimi)
              INTO v_movimi
              FROM movseguro
             WHERE sseguro = psseguro;
         ELSE
            v_movimi := pnmovimi;
         END IF;

         vpasexec := 40;
         v_nerror := pac_gestionbpm.f_set_caso_bpmseg(pac_md_common.f_get_cxtempresa(),
                                                      psseguro, v_movimi, pncaso_bpm,
                                                      v_nsolici_bpm, pnnumcaso);
         vpasexec := 60;

         IF (v_nerror <> 0) THEN
            vpasexec := 61;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_nerror);
            RETURN 1;
         ELSE
            vpasexec := 62;
            v_nerror := pac_md_bpm.f_lanzar_proceso(psseguro, v_movimi, NULL, '*', 'EMITIDA',
                                                    mensajes);

            IF (v_nerror <> 0) THEN
               vpasexec := 63;
               RETURN 1;
            END IF;
         END IF;
      END IF;

      vpasexec := 70;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_trata_movpoliza;

/*************************************************************************
      Valida los datos del caso bpm para cargas
      param in pncaso_bpm: Numero de caso BPM
               pnnumcaso: Numero de caso
               pfichero: nombre del fichero

      return : 0 todo correcto
               <> 0 ha habido un error

      Bug 28263/155558 - 14/10/2013 - AMC
   *************************************************************************/
   FUNCTION f_valida_datosbpmcarga(
      pncaso_bpm IN NUMBER,
      pnnumcaso IN NUMBER,
      pfichero IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'pncaso_bpm:' || pncaso_bpm || ' pnnumcaso:' || pnnumcaso || ' pfichero:'
            || pfichero;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONBPM.f_valida_datosbpmcarga';
      v_nerror       NUMBER;
      vcestado       NUMBER;
      vnpoliza       NUMBER;
      vfichero       NUMBER;
      vnnumcaso      NUMBER;
      vcount         NUMBER;
      vusuario       VARCHAR2(100);
   BEGIN
      vpasexec := 10;
      vusuario := pac_md_common.f_get_cxtusuario;
      vpasexec := 11;
      v_nerror := pac_gestionbpm.f_valida_datosbpmcarga(pncaso_bpm, pnnumcaso, pfichero,
                                                        vusuario);
      vpasexec := 20;

      IF v_nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_nerror);
         RETURN 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_datosbpmcarga;
END pac_md_gestionbpm;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTIONBPM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTIONBPM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTIONBPM" TO "PROGRAMADORESCSI";
