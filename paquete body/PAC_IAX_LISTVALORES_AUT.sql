--------------------------------------------------------
--  DDL for Package Body PAC_IAX_LISTVALORES_AUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_LISTVALORES_AUT" AS
/******************************************************************************
 NOMBRE: PAC_IAX_LISTVALORES_AUT
 PROP脫SITO: Funciones para recuperar valores

 REVISIONES:
 Ver Fecha Autor Descripci贸n
 --------- ---------- --------------- ------------------------------------
 1.0                                  1. Creacion del Package
 1.1       26/02/2009 DCM             BUG 9198 - 3 Parte
 1.2       18/06/2009 XPL             BUG 10219
 1.3       19/03/2013 JDS             0025202: LCOL_T031 - Adaptar pantalla riesgo - autos. Id 428
 1.4       28/03/2013 JDS             0025840: LCOL_T031-LCOL - Fase 3 - (Id 111, 112, 115) - Parametrizaci髇 suplementos
 1.5       15/02/2013 ECP             Bug 25202/135707
 2.0       31/05/2013 ASN             0027045: LCOL_S010-SIN - Eliminar filtrado por producto en tramitaci髇 veh韈ulo contrario (Id=7846)
 3.0       24/02/2014 JDS             0030256: LCOL999-Modificar modelo autos a?adiendo : CPESO, CTRANSMISION, NPUERTAS
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

-- BUG 9198 - 26/02/2009 - DCM 驴 Se crean funciones para AUTOS.

   /*************************************************************************
   Recupera los accesorios que se pueden dar de alta como accesorios extras,
   es decir no entran de serie, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstaccesoriosnoserie(p_cversion IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := ' p_cversion = ' || p_cversion;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_AUT.F_Get_lstaccesoriosnoserie';
   BEGIN
      --Comprovaci贸 de par脿metres d'entrada
      IF p_cversion IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_listvalores_aut.f_get_lstaccesoriosnoserie(p_cversion, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstaccesoriosnoserie;

   /*************************************************************************
   Recupera los accesorios de serie segun la version,
   devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstaccesoriosserie(p_cversion IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := ' p_cversion = ' || p_cversion;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_AUT.F_Get_lstaccesoriosserie';
   BEGIN
      --Comprovaci贸 de par脿metres d'entrada
      IF p_cversion IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_listvalores_aut.f_get_lstaccesoriosserie(p_cversion, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstaccesoriosserie;

   /*************************************************************************
   Recupera los datos de una version, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_version(
      p_cversion IN VARCHAR2,
      phomologar IN NUMBER,
      pctramit IN NUMBER,   -- 27045:ASN:31/05/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := ' p_cversion = ' || p_cversion;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_AUT.F_Get_version';
      vobdetpoliza   ob_iax_detpoliza;
   BEGIN
      --Comprovaci贸 de par脿metres d'entrada
      IF p_cversion IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- Se obtiene el objeto detpoliza
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);
      cur := pac_md_listvalores_aut.f_get_version(p_cversion, vobdetpoliza.sproduc,
                                                  vobdetpoliza.gestion.cactivi, phomologar,
                                                  pctramit,   -- 27045:ASN:31/05/2013
                                                  mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_version;

   /*************************************************************************
   Recupera las marcas segun el producto, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstmarcas(
      pctramit IN NUMBER,   -- 27045:ASN:30/05/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_AUT.F_Get_lstmarcas';
      vobdetpoliza   ob_iax_detpoliza;
   BEGIN
      -- Se obtiene el objeto detpoliza
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);
      cur := pac_md_listvalores_aut.f_get_lstmarcas(vobdetpoliza.sproduc,
                                                    vobdetpoliza.gestion.cactivi, pctramit,   -- 27045:ASN:30/05/2013
                                                    mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstmarcas;

   /*************************************************************************
   Recupera las marcas segun el producto, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstmarcas(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pctramit IN NUMBER,   -- 27045:ASN:30/05/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_AUT.F_Get_lstmarcas';
   BEGIN
      cur := pac_md_listvalores_aut.f_get_lstmarcas(psproduc, pcactivi, pctramit, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstmarcas;

   /*************************************************************************
   Recupera las modelos segun la marca, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstmodelos(
      pctipveh IN VARCHAR2,
      pcclaveh IN VARCHAR2,
      p_cmarca IN VARCHAR2,
      pctramit IN NUMBER,   -- 27045:ASN:30/05/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := ' p_cmarca = ' || p_cmarca;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_AUT.F_Get_lstmodelos';
      vobdetpoliza   ob_iax_detpoliza;
   BEGIN
      --Comprovaci贸 de par脿metres d'entrada
      IF p_cmarca IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- Se obtiene el objeto detpoliza
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);
      cur := pac_md_listvalores_aut.f_get_lstmodelos(vobdetpoliza.sproduc,
                                                     vobdetpoliza.gestion.cactivi, pctipveh,
                                                     pcclaveh, p_cmarca, pctramit,   -- 27045:ASN:30/05/2013
                                                     mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstmodelos;

   /*************************************************************************
    Recupera el numero de puertas de un modelo, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_lstnumpuertas(
      p_cmarca IN VARCHAR2,
      p_cmodelo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
                                 := ' p_cmarca = ' || p_cmarca || ' p_cmodelo = ' || p_cmodelo;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_AUT.F_Get_lstnumpuertas';
   BEGIN
      --Comprovaci贸 de par脿metres d'entrada
      IF p_cmarca IS NULL
         OR p_cmodelo IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_listvalores_aut.f_get_lstnumpuertas(p_cmarca, p_cmodelo, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstnumpuertas;

   /*************************************************************************
    Recupera los usos de un vehiculo, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    -- Bug 25566 - APD - se a馻den los parametros p_sproduc y p_cactivi
    *************************************************************************/
   FUNCTION f_get_lstuso(
      p_cclaveh IN VARCHAR2,
      p_ctipveh IN VARCHAR2,
      p_sproduc IN NUMBER,
      p_cactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := ' p_cclaveh = ' || p_cclaveh || ' p_ctipveh = ' || p_ctipveh || ' p_sproduc = '
            || p_sproduc || ' p_cactivi = ' || p_cactivi;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_AUT.F_Get_lstuso';
      vobdetpoliza   ob_iax_detpoliza;
   BEGIN
      --Comprovaci贸 de par脿metres d'entrada
      IF p_ctipveh IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- Se obtiene el objeto detpoliza
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);
      cur := pac_md_listvalores_aut.f_get_lstuso(p_cclaveh, p_ctipveh,
                                                 NVL(p_sproduc, vobdetpoliza.sproduc),
                                                 NVL(p_cactivi, vobdetpoliza.gestion.cactivi),
                                                 mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstuso;

   /*************************************************************************
    Recupera los subusos de un vehiculo, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    -- Bug 25566 - APD - se a馻den los parametros p_sproduc y p_cactivi
    *************************************************************************/
   FUNCTION f_get_lstsubuso(
      p_cclaveh IN VARCHAR2,
      p_ctipveh IN VARCHAR2,
      p_uso IN VARCHAR2,
      p_sproduc IN NUMBER,
      p_cactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := ' p_cclaveh = ' || p_cclaveh || ' p_ctipveh = ' || p_ctipveh || ' p_uso = '
            || p_uso || ' p_sproduc = ' || p_sproduc || ' p_cactivi = ' || p_cactivi;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_AUT.F_Get_lstsubuso';
      vobdetpoliza   ob_iax_detpoliza;
   BEGIN
      --Comprovaci贸 de par脿metres d'entrada
      IF p_cclaveh IS NULL
         OR p_ctipveh IS NULL
         OR p_uso IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- Se obtiene el objeto detpoliza
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);
      cur := pac_md_listvalores_aut.f_get_lstsubuso(p_cclaveh, p_ctipveh, p_uso,
                                                    NVL(p_sproduc, vobdetpoliza.sproduc),
                                                    NVL(p_cactivi,
                                                        vobdetpoliza.gestion.cactivi),
                                                    mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstsubuso;

   /*************************************************************************
    Recupera las versiones que existen en funci贸n de la marca, modelo,
   n煤mero de puestas y motor de un veh铆culo, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_lstversiones(
      p_cmarca IN VARCHAR2,
      p_cmodelo IN VARCHAR2,
      p_numpuertas IN VARCHAR2,
      p_cmotor IN VARCHAR2,
      pctipveh IN VARCHAR2,
      pcclaveh IN VARCHAR2,
      pcversion IN VARCHAR2,
      pctramit IN NUMBER,   -- 27045:ASN:31/05/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobdetpoliza   ob_iax_detpoliza;
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := ' p_cmarca = ' || p_cmarca || ' p_cmodelo = ' || p_cmodelo || ' p_numpuertas = '
            || p_numpuertas || ' p_cmotor = ' || p_cmotor;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_AUT.F_Get_lstversiones';
   BEGIN
      --Comprovaci贸 de par脿metres d'entrada
      IF p_cmarca IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- Se obtiene el objeto detpoliza
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);
      cur := pac_md_listvalores_aut.f_get_lstversiones(vobdetpoliza.sproduc,
                                                       vobdetpoliza.gestion.cactivi, p_cmarca,
                                                       p_cmodelo, p_numpuertas, p_cmotor,
                                                       pctipveh, pcclaveh, pcversion, pctramit,   -- 27045:ASN:31/05/2013
                                                       mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstversiones;

   /*************************************************************************
    Recupera los diferentes tipos de vehiculo, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_lstctipveh(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_AUT.F_Get_lstctipveh';
   BEGIN
      cur := pac_md_listvalores_aut.f_get_lstctipveh(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstctipveh;

-- Bug 10219 - XPL - 18/06/2009 -- Modificacions Sinistres, s'afegeixen validacions a la funci贸 per tal q salti un error
   /*************************************************************************
    Recupera los diferentes clases de vehiculo, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_lstclaveh(p_ctipveh IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := ' p_ctipveh = ' || p_ctipveh;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_AUT.F_Get_lstclaveh';
   BEGIN
      -- Bug 10219 - XPL - 18/06/2009 -- s'afegeixen validacions a la funci贸 per tal q salti un error
      IF p_ctipveh IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_listvalores_aut.f_get_lstclaveh(p_ctipveh, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstclaveh;

-- FI BUG 9198 - 26/02/2009 - DCM 驴 Se crean funciones para AUTOS.

   -- Bug 9247 - APD - 17/03/2009 -- Se crea la funcion f_get_lstmodalidades
   /*************************************************************************
    Recupera las modalidades permitidas en un producto y actividad, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_lstmodalidades(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := NULL;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_AUT.f_get_lstmodalidades';
      v_csimula      BOOLEAN;
      vobdetpoliza   ob_iax_detpoliza;
   BEGIN
      -- Se obtiene el objeto detpoliza
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);

      IF mensajes IS NOT NULL THEN
         v_pasexec := 2;
         RAISE e_object_error;
      END IF;

      v_csimula := pac_iax_produccion.issimul;   -- BUG 10653 - 14/07/2009 - JJG Modificaciones para la simulaci贸n de autos y modalidades.
      cur := pac_md_listvalores_aut.f_get_lstmodalidades(vobdetpoliza.cramo,
                                                         vobdetpoliza.cmodali,
                                                         vobdetpoliza.ctipseg,
                                                         vobdetpoliza.ccolect,
                                                         vobdetpoliza.gestion.cactivi,
                                                         v_csimula, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstmodalidades;

-- Bug 9247 - APD - 17/03/2009 -- Se crea la funcion f_get_lstmodalidades
   FUNCTION f_get_lstctipveh_pormarca(
      pcmarca IN VARCHAR2,
      pctramit IN NUMBER,   -- 27045:ASN:31/05/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := NULL;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_AUT.f_get_lstctipveh_pormarca';
      vobdetpoliza   ob_iax_detpoliza;
   BEGIN
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);
      cur :=
         pac_md_listvalores_aut.f_get_lstctipveh_pormarca(vobdetpoliza.sproduc,
                                                          vobdetpoliza.gestion.cactivi,
                                                          pcmarca, pctramit,   -- 27045:ASN:31/05/2013
                                                          mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstctipveh_pormarca;

   FUNCTION f_get_lstclaveh_pormarca(
      pcmarca IN VARCHAR2,
      p_ctipveh IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := NULL;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_AUT.f_get_lstclaveh_pormarca';
   BEGIN
      cur := pac_md_listvalores_aut.f_get_lstclaveh_pormarca(pcmarca, p_ctipveh, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstclaveh_pormarca;

   FUNCTION f_get_anyos_version(
      p_cversion IN VARCHAR2,
      p_nriesgo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := NULL;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_AUT.f_get_anyos_version';
   BEGIN
      cur := pac_md_listvalores_aut.f_get_anyos_version(p_cversion, p_nriesgo, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_anyos_version;

   FUNCTION f_get_lstaccesorios(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES.f_get_lstaccesorios';
      terror         VARCHAR2(200) := 'Error recuperar lista de accesorios';
      v_query        VARCHAR2(1000);
   BEGIN
      cur := pac_md_listvalores_aut.f_get_lstaccesorios(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstaccesorios;

   FUNCTION f_get_lstdispositivos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_iax_LISTVALORES.f_get_lstdispositivos';
      terror         VARCHAR2(200) := 'Error recuperar lista de dispositivos';
      v_query        VARCHAR2(1000);
   BEGIN
      cur := pac_md_listvalores_aut.f_get_lstdispositivos(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstdispositivos;

   /*************************************************************************
   Recupera si un accesorio es asegurable, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor

   Bug 25578/135876 - 04/02/2013 - AMC
   *************************************************************************/
   FUNCTION f_get_lstasegurables(
      pcaccesorio IN VARCHAR2,
      pctipo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := ' pcaccesorio:' || pcaccesorio;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_AUT.f_get_lstasegurables';
      terror         VARCHAR2(200) := 'Error recuperar lista de accesorios';
      v_query        VARCHAR2(1000);
      vobdetpoliza   ob_iax_detpoliza;
   BEGIN
      -- Se obtiene el objeto detpoliza
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);
      cur := pac_md_listvalores_aut.f_get_lstasegurables(vobdetpoliza.sproduc,
                                                         vobdetpoliza.gestion.cactivi,
                                                         pcaccesorio, pctipo, mensajes);

      IF mensajes IS NOT NULL THEN
         vpasexec := 3;
         RAISE e_object_error;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstasegurables;

   /*************************************************************************
      Recupera la lista de pesos, devuelve un SYS_REFCURSOR
      param out : mensajes de error
      return : ref cursor

      Bug 25202/135707 - 15/02/2013 - ECP
      *************************************************************************/
   FUNCTION f_get_lstpesos(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := ' psproduc = ' || psproduc;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_AUT.F_Get_lstpesos';
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_listvalores_aut.f_get_lstpesos(psproduc, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstpesos;

   FUNCTION f_get_lstctipveh_pormarcamodel(
      pcmarca IN VARCHAR2,
      pcmodel IN VARCHAR2,
      pctramit IN NUMBER,   -- 27045:ASN:31/05/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := NULL;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_AUT.f_get_lstctipveh_pormarcamodel';
      vobdetpoliza   ob_iax_detpoliza;
   BEGIN
      vobdetpoliza := pac_iobj_prod.f_getpoliza(mensajes);
      cur :=
         pac_md_listvalores_aut.f_get_lstctipveh_pormarcamodel
                                                             (vobdetpoliza.sproduc,
                                                              vobdetpoliza.gestion.cactivi,
                                                              pcmarca, pcmodel, pctramit,   -- 27045:ASN:31/05/2013
                                                              mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstctipveh_pormarcamodel;
END pac_iax_listvalores_aut;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTVALORES_AUT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTVALORES_AUT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTVALORES_AUT" TO "PROGRAMADORESCSI";
