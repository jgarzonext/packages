--------------------------------------------------------
--  DDL for Package Body PAC_IAX_GEDOX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_GEDOX" AS
/******************************************************************************
   NOMBRE:      PAC_IAX_GEDOX
   PROP真SITO: Funciones para la gesti真n de la comunicaci真n con GEDOX

   REVISIONES:
   Ver        Fecha        Autor             Descripci真n
   ---------  ----------  ---------------  ------------------------------------
   1.0        17/01/2008   JTS                1. Creaci真n del package.
   2.0        12/03/2009   DCT                2. Modificaci真n funci真n F_GET_DOCUMMOV
   3.0        11/02/2010   XPL                3. 0012116: CEM - SINISTRES: Adjuntar documentaci真 manualment i guardar-la al GEDOX
   4.0        01/07/2014   ALF                4. modificacio f_set_documgedox per rebre parametre pidfichero
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /***********************************************************************
      Recupera los documentos asociados a un movimiento de un seguro
      param in psseguro  : c真digo de seguro
      param in pnmovimi  : n真mero de movimiento del seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_docummov(psseguro IN NUMBER, pnmovimi IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GEDOX.F_Get_DocumMov';
      vparam         VARCHAR2(500)
                     := 'par真metros - psseguro: ' || psseguro || ' - nmovimi: ' || pnmovimi;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vusuario       VARCHAR2(20);
      vcempres       NUMBER(2);
      vcursor        sys_refcursor;
      vsinterf       NUMBER;
   BEGIN
      --Comprovaci真 dels par真metres d'entrada
      IF psseguro IS NULL
         OR pnmovimi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Recuperamos el usuario
      vusuario := pac_md_common.f_get_cxtusuario();
      vcempres := pac_md_common.f_get_cxtempresa();

      IF NVL(pac_parametros.f_parempresa_t(vcempres, 'GESTORDOCUM'), 'X') = 'GEDOX' THEN
         vcursor := pac_md_gedox.f_get_docummov(psseguro, pnmovimi, vusuario, vcempres,
                                                mensajes);
      ELSIF NVL(pac_parametros.f_parempresa_t(vcempres, 'GESTORDOCUM'), 'X') = 'WS' THEN
         vcursor := pac_md_con.f_get_listado_doc(NULL, psseguro, pnmovimi, vsinterf, mensajes);
      END IF;

      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_docummov;


  FUNCTION f_get_docummov_exc(psseguro IN NUMBER, pnmovimi IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GEDOX.F_Get_DocumMov';
      vparam         VARCHAR2(500)
                     := 'par真metros - psseguro: ' || psseguro || ' - nmovimi: ' || pnmovimi;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vusuario       VARCHAR2(20);
      vcempres       NUMBER(2);
      vcursor        sys_refcursor;
      vsinterf       NUMBER;
   BEGIN
      --Comprovaci真 dels par真metres d'entrada
      IF psseguro IS NULL
         OR pnmovimi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Recuperamos el usuario
      vusuario := pac_md_common.f_get_cxtusuario();
      vcempres := pac_md_common.f_get_cxtempresa();

      IF NVL(pac_parametros.f_parempresa_t(vcempres, 'GESTORDOCUM'), 'X') = 'GEDOX' THEN
         vcursor := pac_md_gedox.f_get_docummov_exc(psseguro, pnmovimi, vusuario, vcempres,
                                                mensajes);
      ELSIF NVL(pac_parametros.f_parempresa_t(vcempres, 'GESTORDOCUM'), 'X') = 'WS' THEN
         vcursor := pac_md_con.f_get_listado_doc(NULL, psseguro, pnmovimi, vsinterf, mensajes);
      END IF;

      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_docummov_exc;




   /***********************************************************************
      Recupera un identificador pel fitxer
      param out mensajes : missatge d'error
      return             : 0/1 -> Tot OK/Error
   ***********************************************************************/
   FUNCTION f_get_idfichero(pid OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GEDOX.F_Get_IdFichero';
      vparam         VARCHAR2(500) := 'par真metros - sin';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(1) := 0;
   BEGIN
      vnumerr := pac_md_gedox.f_get_idfichero(pid, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_idfichero;

   /***********************************************************************
      Recupera un path de directori
      param in pparam : valor de path
      param out ppath    : p真rametre GEDOX
      param out mensajes : missatge d'error
      return             : 0/1 -> Tot OK/Error
   ***********************************************************************/
   FUNCTION f_get_directorio(ppath OUT VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GEDOX.F_Get_Directorio';
      vparam         VARCHAR2(500) := 'par真metros';
      vpasexec       NUMBER(5) := 1;
      pparam_aux     VARCHAR2(10) := 'INF_SERV';
      vnumerr        NUMBER(1) := 0;
   BEGIN
      vpasexec := 3;
      vnumerr := pac_md_gedox.f_get_directorio(pparam_aux, ppath, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_directorio;

   /*************************************************************************
      Funci真n que grava a GEDOX un fitxer ja generat en el directory compartit de GEDOX.
      param in psseguro    : Asseguran真a a la que cal vincular la
                             impressi真.
      param in pnmovimi    : Moviment al que pertany la impressi真.
      param in puser       : Usuari que realitza la gravaci真 del document.
      param in ptfilename  : Nom del fitxer a pujar al GEDOX.
      param in pnfilename  : Id del fitxer a pujar al GEDOX (fisic).
      param in pidfichero  : Descripci真 del fitxer a pujar al GEDOX.
      param in pidcat      : Categoria del fitxer a pujar al GEDOX.
      param out mensajes   : Missatges d'error.
      return               : 0/1 -> Tot OK/Error

   *************************************************************************/
   --11/02/2010#XPL#12116#Es canvia el nom de la funci真, per a que sigui m真s especific
   FUNCTION f_set_docummovseggedox(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      ptfilename IN VARCHAR2,
      pidfichero IN NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      porigen IN NUMBER DEFAULT 0,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'psseguro: ' || psseguro || ' - pnmovimi:
' ||        pnmovimi || ' - ptfilename: ' || ptfilename || ' - ptdesc:
' ||        ptdesc || ' - pidcat: ' || pidcat;
      vobjectname    VARCHAR2(200) := 'PAC_IAX_GEDOX.F_Set_DocumGedox';
      vterror        VARCHAR2(1000);
      viddoc         VARCHAR2(100);
      vusuario       VARCHAR2(20);
   BEGIN
      --Comprovaci真 de par真metres d'entrada
      IF psseguro IS NULL
         OR pnmovimi IS NULL
         OR ptfilename IS NULL
         OR pidcat IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Recuperamos el usuario
      vusuario := pac_md_common.f_get_cxtusuario();

      IF pidfichero IS NOT NULL THEN
         viddoc := pidfichero;
      ELSE
         viddoc := ptfilename;
      END IF;

      vterror := pac_md_gedox.f_set_docummovseggedox(psseguro, pnmovimi, vusuario, ptfilename,
                                                     viddoc, ptdesc, pidcat, porigen, mensajes);

      IF vterror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_docummovseggedox;

   /*************************************************************************
      Funci真n que grava a GEDOX un fitxer ja generat en el directory compartit de GEDOX.
      I actualitzar la taula sin_tramita_documento amb iddoc del gedox
      param in pnsinies    : N真m Sinistre
      param in pntramit    : N真m. Tramitaci真
      param in pndocume    : id intern de la taula sin_tramita_documentos
      param in ptfilename  : Nom del fitxer a pujar al GEDOX.
      param in pnfilename  : Id del fitxer a pujar al GEDOX (fisic).
      param in pidfichero  : Descripci真 del fitxer a pujar al GEDOX.
      param in pidcat      : Categoria del fitxer a pujar al GEDOX.
      param in porigen      : Origen (SINISTRES, CONS.POL...)
      param out mensajes   : Missatges d'error.
      return               : 0/1 -> Tot OK/Error

   *************************************************************************/
--11/02/2010#XPL#12116#0012116: CEM - SINISTRES: Adjuntar documentaci真 manualment i guardar-la al GEDOX
   FUNCTION f_set_documsinistresgedox(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pndocume IN NUMBER,
      ptfilename IN VARCHAR2,
      pidfichero IN NUMBER,
      ptdesc IN VARCHAR2,
      pidcat IN NUMBER,
      porigen IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'pnsinies: ' || pnsinies || ' - pntramit:
' ||        pntramit || 'pndocume: ' || pndocume || ' - ptfilename: ' || ptfilename
            || ' - ptdesc:
' ||        ptdesc || ' - pidcat: ' || pidcat;
      vobjectname    VARCHAR2(200) := 'PAC_IAX_GEDOX.F_Set_DocumGedox';
      vterror        VARCHAR2(1000);
      viddoc         NUMBER(8) := 0;
      vusuario       VARCHAR2(20);
   BEGIN
      --Comprovaci真 de par真metres d'entrada
      IF pnsinies IS NULL
         OR pntramit IS NULL
         OR pndocume IS NULL
         OR ptfilename IS NULL
         OR pidcat IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Recuperamos el usuario
      vusuario := pac_md_common.f_get_cxtusuario();
      vterror := pac_md_gedox.f_set_documsinistresgedox(pnsinies, pntramit, pndocume, vusuario,
                                                        ptfilename, pidfichero, ptdesc, pidcat,
                                                        porigen, mensajes);

      IF vterror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_documsinistresgedox;

   /***********************************************************************
      Recupera las categories
      param in pcidioma   : codi idioma
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_categor(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GEDOX.F_Get_Categor';
      vparam         VARCHAR2(500) := 'par真metros';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_gedox.f_get_categor(mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_categor;

   /*************************************************************************
      Visualizaci真n de un documento almacenado en GEDOX
      param in piddoc      : Id. del documento que se debe visualizar
      param out ptpath     : Ruta del fichero que se debe visualizar
      param out mensajes   : mensajes de error
      return               : 0/1 -> Ok/Error
   *************************************************************************/
   FUNCTION f_gedox_verdoc(piddoc IN NUMBER, optpath OUT VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GEDOX.F_Gedox_VerDoc';
      vparam         VARCHAR2(500) := 'par真metros - piddoc: ' || piddoc;
      vpasexec       NUMBER(5) := 0;
      vnumerr        NUMBER(8) := 1;
      vtfichero      VARCHAR2(100);
      vtfichpath     VARCHAR2(250);
   BEGIN
      --Comprovaci真 dels par真metres d'entrada
      IF piddoc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vnumerr := pac_md_gedox.f_gedox_verdoc(piddoc, optpath, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_gedox_verdoc;

    /***********************************************************************
      Recupera los documentos asociados a un movimiento de un seguro
      param in psseguro  : c真digo de seguro
      param in pnmovimi  : n真mero de movimiento del seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_docummov_requerida(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GEDOX.F_Get_DocumMov';
      vparam         VARCHAR2(500)
                     := 'par真metros - psseguro: ' || psseguro || ' - nmovimi: ' || pnmovimi;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vusuario       VARCHAR2(20);
      vcempres       NUMBER(2);
      vcursor        sys_refcursor;
      vsinterf       NUMBER;
   BEGIN
      --Comprovaci真 dels par真metres d'entrada
      IF psseguro IS NULL
         OR pnmovimi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Recuperamos el usuario
      vusuario := pac_md_common.f_get_cxtusuario();
      vcempres := pac_md_common.f_get_cxtempresa();
      vcursor := pac_md_gedox.f_get_docummov_requerida(psseguro, pnmovimi, vusuario, vcempres,
                                                       mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_docummov_requerida;

   FUNCTION f_get_tamanofit(
      pidgedox IN NUMBER,
      ptamano OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GEDOX.f_get_tamanofit';
      vparam         VARCHAR2(500) := 'par真metros pidgedox:' || pidgedox;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vtamano        NUMBER;
   BEGIN
      IF pidgedox IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_gedox.f_get_tamanofit(pidgedox, ptamano, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_tamanofit;

   FUNCTION f_set_documgedox(
      puser IN VARCHAR2,
      ptfilename IN VARCHAR2,
      pidfichero IN NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      piddocgedox OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GEDOX.f_set_documgedox';
      vparam         VARCHAR2(500)
         := 'puser: ' || puser || ' - ptfilename: ' || ptfilename || ' - piddocgedox: '
            || piddocgedox || ' - ptdesc:' || ptdesc || ' - pidcat: ' || pidcat;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vidfichero     VARCHAR2(100);
      vtamano        NUMBER;
   BEGIN
      IF puser IS NULL
         OR ptfilename IS NULL
         OR pidcat IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pidfichero IS NOT NULL THEN
         vidfichero := pidfichero;
      ELSE
         vidfichero := ptfilename;
      END IF;

      vnumerr := pac_md_gedox.f_set_documgedox(puser, ptfilename, piddocgedox, ptdesc, pidcat,
                                               mensajes, vidfichero);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_documgedox;
FUNCTION f_set_docummovcompanigedox(
      pccompani IN NUMBER,
      ptfilename IN VARCHAR2,
      pidfichero IN OUT VARCHAR2,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500):=
					' pccompani: ' || pccompani ||
					' - ptfilename: ' || ptfilename ||
					' - ptdesc: ' || ptdesc ||
					' - pidcat: ' || pidcat;
      vterror        VARCHAR2(1000);
      viddoc         VARCHAR2(100);
      vusuario       VARCHAR2(20);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GEDOX.f_set_docummovcompanigedox';
   BEGIN

      IF pccompani IS NULL
         OR ptfilename IS NULL
         OR pidcat IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Recuperamos el usuario
      vusuario := pac_md_common.f_get_cxtusuario();

      IF pidfichero IS NOT NULL THEN
         viddoc := pidfichero;
      ELSE
         viddoc := ptfilename;
      END IF;

      vterror := pac_md_gedox.f_set_docummovcompanigedox(pccompani, vusuario, ptfilename,
                                                     viddoc, ptdesc, pidcat,  mensajes);

      IF vterror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_docummovcompanigedox;


   FUNCTION f_set_gca_docgsfavclis(
      pidobs IN NUMBER,
      ptfilename IN VARCHAR2,
      pidfichero IN OUT VARCHAR2,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500):=
					' pidobs: ' || pidobs ||
					' - ptfilename: ' || ptfilename ||
					' - ptdesc: ' || ptdesc ||
					' - pidcat: ' || pidcat;
      vterror        VARCHAR2(1000);
      viddoc         VARCHAR2(100);
      vusuario       VARCHAR2(20);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_GEDOX.f_set_gca_docgsfavclis';
   BEGIN

      IF pidobs IS NULL
         OR ptfilename IS NULL
         OR pidcat IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Recuperamos el usuario
      vusuario := pac_md_common.f_get_cxtusuario();

      IF pidfichero IS NOT NULL THEN
         viddoc := pidfichero;
      ELSE
         viddoc := ptfilename;
      END IF;

      vterror := pac_md_gedox.f_set_gca_docgsfavclis(pidobs, vusuario, ptfilename,
                                                     viddoc, ptdesc, pidcat,  mensajes);

      IF vterror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_gca_docgsfavclis;
END pac_iax_gedox;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_GEDOX" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GEDOX" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GEDOX" TO "PROGRAMADORESCSI";
