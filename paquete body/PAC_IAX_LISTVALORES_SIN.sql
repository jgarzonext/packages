create or replace PACKAGE BODY        "PAC_IAX_LISTVALORES_SIN" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_LISTVALORES_SIN
   PROPÓSITO:  Funciones para recuperar valores

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        20/02/2009   XVM                 1. Creación del package body.
   2.0        01/10/2009   DCT                 1. Bug 10393 Crear parametrización de documentacion a solicitar por producto/causa
   3.0        21/10/2009   DCT                 1. Bug 10211 Procesos cambio estado siniestro/tramitación
   4.0        10/12/2009   AMC                 4. Bug 0012211: Mant. Eventos
   5.0        14/01/2010   AMC                 5. Bug 12605 - Destinatarios siniestros según parametrización
   6.0        05/03/2010   AMC                 6. Bug 13312 se añade la funcion f_get_lsctestmov
   7.0        30/10/2010   JRH                 7. BUG 15669 : Campos nuevos
   8.0        16/03/2011   JMF                 8. 0017970: ENSA101- Campos pantallas de siniestros y mejoras
   9.0        01/07/2011   APD                 9. 0018913: CRE998 - Afegir motiu de Rescats
  10.0        26/03/2012   JMF                 0021196: LCOL_S001-SIN - Cambio de tramitador
  11.0        29/03/2019   Swapnil             11.0 Cambio de IAXIS-2168
******************************************************************************/
-- BUG 9020 - 10/03/2009 - XVM - Nou model de dades del Sinistre, llistat pels sinistres
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
   FUNCTION f_get_lstcreclama
      Recupera codi reclamació
      param out mensajes : missatges d'error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcreclama(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstcreclama';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(318, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcreclama;

   /*************************************************************************
   FUNCTION f_get_lstcmeddec
      Recupera codi medi declaració
      param out mensajes : missatges d'error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcmeddec(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstcmeddec';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(319, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcmeddec;

   /*************************************************************************
   FUNCTION f_get_lstctipdec
      Recupera tipo declarant
      param out mensajes : missatges d'error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctipdec(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstctipdec';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(321, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstctipdec;

   /*************************************************************************
   FUNCTION f_get_lstctipreg
      Recupera tipus registre
      param out mensajes : missatges d'error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctipreg(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstctipreg';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(329, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstctipreg;

   /*************************************************************************
   FUNCTION f_get_lstcestage
      Recupera codi estat agencia
      param out mensajes : missatges d'error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcestage(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstcestage';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(29, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcestage;

   /*************************************************************************
   FUNCTION f_get_lstcmonda
      Recupera abreviatura moneda
      param out mensajes : missatges d'error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcmonda(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstcmonda';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(681, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcmonda;

   /*************************************************************************
   FUNCTION f_get_lstctcausin
      Recupera codi tipus dany
      param out mensajes : missatges d'error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctcausin(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstctcausin';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(815, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstctcausin;

   /*************************************************************************
   FUNCTION f_get_lstctipdes
      Recupera tipus destinatari
      param out mensajes : missatges d'error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctipdes(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstctipdes';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(10, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstctipdes;

   /*************************************************************************
   FUNCTION f_get_lstctippag
      Recupera tipus pagament
      param out mensajes : missatges d'error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctippag(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstctippag';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(2, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstctippag;

   /*************************************************************************
   FUNCTION f_get_lstcforpag
      Recupera tipus forma pagament
      param out mensajes : missatges d'error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcforpag(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstcforpag';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(813, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcforpag;

   /*************************************************************************
   FUNCTION f_get_lstctipban
      Recupera tipus de compte bancari
      param out mensajes : missatges d'error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctipban(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstctipban';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(274, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstctipban;

   /*************************************************************************
   FUNCTION f_get_lstcclares
      Recupera càlcul reserva (Manual/Automàtic)
      param out mensajes : missatges d'error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcclares(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstcclares';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(693, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcclares;

/*************************************************************************
   FUNCTION f_get_causasini
      Recupera les possibles causes de sinistres de pòlisses d'un determinat producte
      param in psproduc  : codi del producte
      param out mensajes : missatges d'error
      return             : refcursor
*************************************************************************/
   FUNCTION f_get_causasini(psproduc IN NUMBER, pcactivi IN NUMBER,
                           /*Cambios de IAXIS-2168 : Start*/
                           psseguro IN NUMBER,
                           /*Cambios de IAXIS-2168 : End*/
							mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                        := 'paràmetres - psproduc: ' || psproduc || ' - pcactivi:' || pcactivi
						/*Cambios de IAXIS-2168 : Start*/
						|| ' - psseguro:' || psseguro
						/*Cambios de IAXIS-2168 : End*/
						;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.F_Get_CausaSini';
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_listvalores_sin.f_get_causasini(psproduc, pcactivi,
			 /*Cambios de IAXIS-2168 : Start*/
             psseguro,
             /*Cambios de IAXIS-2168 : End*/
			 mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

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
   END f_get_causasini;

   /*************************************************************************
   FUNCTION F_Get_MotivosSini
      Recupera llista amb els motius de sinistres per producte
      param in psproduc  : codi del producte
      param in pccausa   : codi del sinistre
      param out mensajes : missatges d'error
      return             : refcursor
   *************************************************************************/
   FUNCTION f_get_motivossini(
      psproduc IN NUMBER,
      pccausa IN NUMBER,
      pcactivi IN NUMBER,
      psseguro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
-- Bug 0012822 - 09/02/2010 - JMF: Afegir paràmetre seguro.
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'paràmetres - psproduc: ' || psproduc || ' - pccausa:' || pccausa
            || ' - pcactivi:' || pcactivi || ' - sseguro:' || psseguro;
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.F_Get_MotivosSini';
      vcursor        sys_refcursor;
   BEGIN
      -- Comprovació pas de paràmetres
      IF psproduc IS NULL
         OR pccausa IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vcursor := pac_md_listvalores_sin.f_get_motivossini(psproduc, pccausa, pcactivi,
                                                          psseguro, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_motivossini;

   /*************************************************************************
   FUNCTION f_get_lstctramit
      Recupera codi tramitació
      param in out mensajes : missatges d'error
      return                : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctramit(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstctramit';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(800, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstctramit;

   /*************************************************************************
   FUNCTION f_get_lstcculpab
      Recupera la cupabilitat
      param in out mensajes : missatges d'error
      return                : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcculpab(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstcculpab';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(801, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcculpab;

   /*************************************************************************
   FUNCTION f_get_lstcsiglas
      Recupera les sigles de la via
      param out mensajes : missatges d'error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcsiglas(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstcsiglas';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(191, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcsiglas;

   /*************************************************************************
   FUNCTION f_get_lstcinform
      Recupera informes
      param  out mensajes : missatges d'error
      return              : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcinform(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstcinform';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(108, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcinform;

   /*************************************************************************
   FUNCTION f_get_lstcmanual
      Recupera registre manual
      param  out mensajes : missatges d'error
      return              : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcmanual(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstcmanual';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(693, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcmanual;

   /*************************************************************************
   FUNCTION f_get_lstctipres
      Recupera tipus reserva
      param  out mensajes : missatges d'error
      return              : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstctipres(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstctipres';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(322, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstctipres;

   /*************************************************************************
   FUNCTION f_get_lstcestval
      Recupera estat validació pagament
      param  out mensajes : missatges d'error
      return              : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcestval(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstcestval';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(324, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcestval;

   /*************************************************************************
   FUNCTION f_get_lstcconpag
      Recupera concepte pagament
      param  out mensajes : missatges d'error
      return              : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcconpag(
      psproduc IN NUMBER DEFAULT NULL,   --BUG 27909:NSS:04/09/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstcconpag';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_lstcconpag(psproduc, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcconpag;

   /*************************************************************************
   FUNCTION f_get_lstccauind
      Recupera causa indemnització
      param in out mensajes : missatges d'error
      return                : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstccauind(pctippag IN NUMBER,
                             mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstccauind';
   BEGIN
      cur := pac_md_listvalores.f_detvalores_dep(pac_md_common.f_get_cxtempresa, 2, pctippag, 325, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstccauind;

   /*************************************************************************
   FUNCTION f_get_lstccinform
      Recupera tramitació informativa
      param in out mensajes : missatges d'error
      return                : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstccinform(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstccinform';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(326, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstccinform;

/*************************************************************************
   FUNCTION f_get_tiptrami
   Recupera els tipus de tramitacions d'un determinat producte
   param in psseguro  : codi del seguro
   param in pcactivi  : codi de l'activitat
   param in pccausin  : codi de la causa del sinistre
   param in pmotsin   : codi de motiu del sinistre
   param in psproduc  : codi del producte
   param in pmodo     : mode 'ALTA' o 'MODIF' del siniestre
   param in pcestsin  : estado del siniestro.
   param out mensajes : missatges d'error
   return             : refcursor

   Bug 15153 - 28/06/2010 - AMC - Se añade el parametro pmodo
   CONF-513  - 20/12/2016 - OGQ - Se añade el parametro pcestsin
*************************************************************************/
   FUNCTION f_get_tiptrami(
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pccausin IN NUMBER,
      pmotsin IN NUMBER,
      psproduc IN NUMBER,
      pmodo IN VARCHAR2,
      pctramte IN NUMBER,
      pcestsin IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'paràmetres - psproduc: ' || psproduc || ' - pcactivi:' || pcactivi
            || ' psseguro:' || psseguro || ' pccausin:' || pccausin || ' pmotsin:' || pmotsin
            || ' pmodo:' || pmodo || ', pctramte:' || pctramte;
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.F_Get_tiptrami';
      vcursor        sys_refcursor;
   BEGIN
      -- Comprovació pas de paràmetres
      IF psseguro IS NULL
         OR pcactivi IS NULL
         OR psproduc IS NULL
         OR pmodo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vcursor := pac_md_listvalores_sin.f_get_tiptrami(psseguro, pcactivi, pccausin, pmotsin,
                                                       psproduc, pmodo, pctramte,pcestsin,mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_tiptrami;

   /*************************************************************************
   FUNCTION f_get_lstccestsin
      Recupera estat sinistre
      param in out mensajes : missatges d'error
      return                : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstccestsin(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstccestsin';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(6, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstccestsin;

   /*************************************************************************
   FUNCTION f_get_lstccsubtra
      Recupera subestat tramitació
      param in out mensajes : missatges d'error
      return                : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstccsubtra(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstccsubtra';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(665, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstccsubtra;

/*************************************************************************
   FUNCTION f_get_tcompania
   Recupera els tipus de tramitacions d'un determinat producte
   param out mensajes : missatges d'error
   return             : refcursor

*************************************************************************/
   FUNCTION f_get_tcompania(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'paràmetres - :';
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.F_Get_tcompania';
      vcursor        sys_refcursor;
   BEGIN
      vpasexec := 2;
      vcursor := pac_md_listvalores_sin.f_get_tcompania(mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_tcompania;

   /*************************************************************************
   FUNCTION f_get_lstcestper
      Recupera estat persona
      param in out mensajes : missatges d'error
      return                : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcestper(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstcestper';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(811, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcestper;

/*************************************************************************
       Recupera las actividades profesionales
       param out mensajes : mensajes de error
       return : ref cursor

          30/03/2009   XPL                 Sinistres.  Bug: 9020
*************************************************************************/
   FUNCTION f_get_lstcactprof(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(10) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES.f_get_lstcactprof';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_lstcactprof(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcactprof;

/*************************************************************************
   FUNCTION f_get_cunitra
   Recupera les unitats tramitadores amb les seves descripcions
   param in pcempres  : codi empresa
   param out mensajes : missatges d'error
   return             : refcursor
*************************************************************************/
   FUNCTION f_get_cunitra(pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'paràmetres - pcempres: ' || pcempres;
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.F_Get_cunitra';
      vcursor        sys_refcursor;
   BEGIN
      -- Comprovació pas de paràmetres
      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vcursor := pac_md_listvalores_sin.f_get_cunitra(pcempres, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_cunitra;

/*************************************************************************
   FUNCTION f_get_ctramitad
   Recupera els tramidors amb les seves descripcions
   param in pcempres     : codi empresa
   param in pctramitpad  : codi tramitador pare
   param out mensajes    : missatges d'error
   return                : refcursor
*************************************************************************/
   FUNCTION f_get_ctramitad(
      pcempres IN NUMBER,
      pctramitpad IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                  := 'paràmetres - pcempres: ' || pcempres || ' - pctramitpad:' || pctramitpad;
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.F_Get_ctramitad';
      vcursor        sys_refcursor;
   BEGIN
      -- Comprovació pas de paràmetres
      IF pcempres IS NULL
         AND pctramitpad IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vcursor := pac_md_listvalores_sin.f_get_ctramitad(pcempres, pctramitpad, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_ctramitad;

      /*************************************************************************
          Recupera las Causas Siniestro de sin_codmotcau
          param out mensajes : mensajes de error
          return : ref cursor

          20/05/2009   AMC                 Sinistres.  Bug: 8816
   *************************************************************************/
   FUNCTION f_get_lstcassin_codmotcau(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstcassin_codmotcau';
      terror         VARCHAR2(200) := 'Error recuperar LSTCASSIN_CODMOTCAU';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_lstcassin_codmotcau(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcassin_codmotcau;

   /*************************************************************************
       Recupera los Motivos Siniestro de sin_codmotcau
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstmotsin_codmotcau(pccausin IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstmotsin_codmotcau';
      terror         VARCHAR2(200) := 'Error recuperar lstmotsin_codmotcau';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_lstmotsin_codmotcau(pccausin, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstmotsin_codmotcau;

   /*************************************************************************
       Recupera los Motivos Movimientos
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstmotmovi(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstmotmovi';
      terror         VARCHAR2(200) := 'Error recuperar lstmotmovi';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_lstmotmovi(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstmotmovi;

   /*************************************************************************
       Recupera los Códigos Movimiento Cuenta Seguro
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstcodctaseguro(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstcodctaseguro';
      terror         VARCHAR2(200) := 'Error recuperar lstmotmovi';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_lstcodctaseguro(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcodctaseguro;

   /*************************************************************************
       Recupera los Tipo Destinatario
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lsttipdestinatario(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lsttipdestinatario';
      terror         VARCHAR2(200) := 'Error recuperar lsttipdestinatario';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_lsttipdestinatario(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttipdestinatario;

   /*************************************************************************
       Recupera los Modelos fiscales
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstmodfiscales(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstmodfiscales';
      terror         VARCHAR2(200) := 'Error recuperar lstmodfiscales';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_lstmodfiscales(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstmodfiscales;

   /*************************************************************************
       Recupera los elementos
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstelemento(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstelemento';
      terror         VARCHAR2(200) := 'Error recuperar lstelemento';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_lstelemento(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstelemento;

   /*************************************************************************
       Recupera las formulas
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstformula(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstformula';
      terror         VARCHAR2(200) := 'Error recuperar lstformula';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_lstformula(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstformula;

   /*************************************************************************
       Recupera las causas y motivos por producto
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstproductossin(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.lstproductossin';
      terror         VARCHAR2(200) := 'Error recuperar lstproductossin';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_lstproductossin(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstproductossin;

   /*************************************************************************
       Recupera a los profesionales
       param out mensajes : mensajes de error
       return : ref cursor

       29/05/2012   JLTS                 Sinistres.  Bug: 21838
    *************************************************************************/
   FUNCTION f_get_lstprofesionales(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstprofesionales';
      terror         VARCHAR2(200) := 'Error recuperar lstprofesionales';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_lstprofesionales(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstprofesionales;

   /*************************************************************************
       Recupera las actividades del producto escogido
       param in psproduc : código del producto
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstactiviprodsin(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstactiviprodsin';
      terror         VARCHAR2(200) := 'Error recuperar lstproductossin';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_lstactiviprodsin(psproduc, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstactiviprodsin;

     /*************************************************************************
      Recupera las garantias del producto y actividad escogidos
      param in psproduc : código del producto
      param in pcactivi : código de la actividad
      param out mensajes : mensajes de error
      return : ref cursor

      20/05/2009   AMC                 Sinistres.  Bug: 8816
   *************************************************************************/
   FUNCTION f_get_lstgaransin(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstgaransin';
      terror         VARCHAR2(200) := 'Error recuperar lstgaransin';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_lstgaransin(psproduc, pcactivi, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstgaransin;

   /*************************************************************************
       Recupera las garantias del producto y actividad escogidos
       param in psproduc : código del producto
       param in pcactivi : código de la actividad
       param in pcgarant : código de la garantia
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lsttramisin(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lsttramisin';
      terror         VARCHAR2(200) := 'Error recuperar lsttramisin';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_lsttramisin(psproduc, pcactivi, pcgarant, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttramisin;

   /*************************************************************************
      Recupera los estados de las causas de un siniestro
      param in pcestsin : código estado
      param out mensajes : mensajes de error
      return : ref cursor

      29/07/2009   XVM                 Sinistres.  Bug: 10211
   *************************************************************************/
   FUNCTION f_get_lstestado(pcestsin IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstestado';
      terror         VARCHAR2(200) := 'Error recuperar lstestado';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_lstestado(pcestsin, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstestado;

   /*************************************************************************
      Recupera los estados de las causas de una tramitación
      param in pcestsin : código estado
      param out mensajes : mensajes de error
      return : ref cursor

   -- BUG 0021196 - 26/03/2012 - JMF
   *************************************************************************/
   FUNCTION f_get_lstestadotra(pcestsin IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstestadotra';
      terror         VARCHAR2(200) := 'Error recuperar lstestado';
      v_estado       NUMBER;
   BEGIN
      IF pcestsin = 0 THEN
         -- 0 (abierto) --> 20 Tramitación Apertura
         v_estado := 20;
      ELSIF pcestsin = 1 THEN
         -- 1 (Terminado) --> 22 Tramitación Finalización
         v_estado := 22;
      ELSIF pcestsin = 2 THEN
         -- 2 (Anulado) --> 24 Tramitación Anulada
         v_estado := 24;
      ELSIF pcestsin = 3 THEN
         -- 3 (Rechazado) --> 23 Tramitación Rechazo
         v_estado := 23;
      ELSE
         -- No definido.
         v_estado := -1;
      END IF;

      cur := pac_md_listvalores_sin.f_get_lstestado(v_estado, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstestadotra;

   /*************************************************************************
      Recupera la lista de causas
      param out mensajes : mensajes de error
      return : ref cursor

      29/07/2009   XVM                 Sinistres.  Bug: 8820
   *************************************************************************/
   FUNCTION f_get_lstcausas(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstcausas';
      terror         VARCHAR2(200) := 'Error recuperar causas';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_lstcausas(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcausas;

   /*************************************************************************
   FUNCTION f_get_lstcdocume
       Recupera codi del document i el títol del document
      param out mensajes : missatges d'error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcdocume(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500);
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.F_Get_lstcdocume';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_listvalores_sin.f_get_lstcdocume(mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_lstcdocume;

   /*************************************************************************
    FUNCTION f_get_lstesttra
       Recupera llista estats tramitació
       param in  pcesttra : estado tramitación
       param out mensajes : mensajes de error
       return             : ref cursor
    *************************************************************************/
   FUNCTION f_get_lstesttra(pcesttra IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500);
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.F_Get_lstesttra';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_listvalores_sin.f_get_lstesttra(pcesttra, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_lstesttra;

   /*************************************************************************
    Función f_get_lsteventos
    Recupera el listado de eventos
    param out mensajes   : mensajes de error
    return              : sys_refcursor

    -- Bug 12211 - 10/12/2009 - AMC
   *************************************************************************/
   FUNCTION f_get_lsteventos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500);
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.f_get_lsteventos';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_listvalores_sin.f_get_lsteventos(mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_lsteventos;

   /*************************************************************************
    Función f_get_lsttipdes
    Recupera el listado de los tipos de destinatarios
    param in psproduc : código del producto
    param in pcactivi : codigo de la actividad
    param in pctramit : código del tipo de tramitación
    param in pccausin : código de la causa del siniestro
    param in pcmotsin : código del motivo del siniestro
    param in psseguro : código de seguro
    param out mensajes   : mensajes de error
    return              : sys_refcursor

    -- Bug 12605 - 14/01/2010- AMC
   *************************************************************************/
   FUNCTION f_get_listtipdes(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pctramit IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      psseguro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'psproduc=' || psproduc || ' pcactivi=' || pcactivi || ' pctramit=' || pctramit
            || ' pccausin=' || pccausin || ' pcmotsin=' || pcmotsin || ' psseguro='
            || psseguro;
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.f_get_listtipdes';
      vcursor        sys_refcursor;
   BEGIN
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pctramit IS NULL
         OR pccausin IS NULL
         OR pcmotsin IS NULL
         OR psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vcursor := pac_md_listvalores_sin.f_get_listtipdes(psproduc, pcactivi, pctramit,
                                                         pccausin, pcmotsin, psseguro,
                                                         mensajes);

      IF vcursor IS NULL THEN
         RAISE e_object_error;
      END IF;

      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_listtipdes;

      /*************************************************************************
       Función f_get_lsctestmov
       Recupera el listado del estado del pago dependiendo del estado anterior
       param in pestvalant : Estado de la validacion anterior
       param in pestpagant : Estado del pago anterior
       param in pestval: Estado de la validacion actual
       param out mensajes   : mensajes de error
       return              : sys_refcursor

       -- Bug 13312 - 05/03/2010 - AMC
      *************************************************************************/
      /*************************************************************************

   Función f_get_lsctestmov

   Recupera el listado del estado del pago dependiendo del estado anterior

   param in pestvalant : Estado de la validacion anterior

   param in pestpagant : Estado del pago anterior

   param in pestval: Estado de la validacion actual

   param out mensajes : mensajes de error

   return : sys_refcursor

   -- Bug 13312 - 05/03/2010 - AMC

   *************************************************************************/
   FUNCTION f_get_lsctestmov(
      pestvalant IN NUMBER,
      pestpagant IN NUMBER,
      pestval IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'pestvalant=' || pestvalant || ' pestpagant=' || pestpagant || ' pestval='
            || pestval;
      vobject        VARCHAR2(50) := 'PAC_MD_LISTVALORES_SIN.f_get_lsctestmov';
      vcursor        sys_refcursor;
   BEGIN
      IF pestvalant IS NULL
         OR pestpagant IS NULL
         OR pestval IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Bug.: 20335 - 20/12/2011 - ICV
      vcursor :=
         pac_md_listvalores.f_opencursor
            ('select distinct catribu, tatribu from SIN_TRANSICIONES st, detvalores d where '
             || ' cidioma = ' || pac_md_common.f_get_cxtidioma()
             || ' and cvalor = 3 and st.csubant = ' || pestvalant || ' and st.cestant = '
             || pestpagant || ' and csubsig = ' || pestval
             || ' and d.CATRIBU = st.cestsig and cempres = ' || pac_md_common.f_get_cxtempresa
             || ' and st.cvisible = 1 order by catribu asc',
             mensajes);

      IF vcursor IS NULL THEN
         p_tab_error(f_sysdate, f_user, 'pac_iax_listvalores_sin', 1, 'error:', SQLERRM);
         RAISE e_object_error;
      END IF;

      --Fi bug.: 20335
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_lsctestmov;

 -- Bug 0015669 - JRH - 30/09/2010 - Alta prestaciones
/*************************************************************************
    Función f_get_lstEstadoPrest
    Recupera el listado de estados de una prestación
    param out mensajes   : mensajes de error
    return              : sys_refcursor


   *************************************************************************/
   FUNCTION f_get_lstestadoprest(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500);
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstestadoprest';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_listvalores_sin.f_get_lstestadoprest(mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_lstestadoprest;

/*************************************************************************
    Función f_get_lstEstPagosPrest
    Recupera el listado de estado de pagos de una prestación
    param out mensajes   : mensajes de error
    return              : sys_refcursor


   *************************************************************************/
   FUNCTION f_get_lstestpagosprest(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500);
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstEstPagosPrest';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_listvalores_sin.f_get_lstestpagosprest(mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_lstestpagosprest;

/*************************************************************************
    Función f_get_lstDurPrest
    Recupera el listado de duraciones de prestación
    param out mensajes   : mensajes de error
    return              : sys_refcursor


   *************************************************************************/
   FUNCTION f_get_lstdurprest(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500);
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstDurPrest';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_listvalores_sin.f_get_lstdurprest(mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_lstdurprest;

   /*************************************************************************
      Función f_get_lstTipCap
      Recupera el listado de formas de pago de prestación
      param in  pnsinies   : siniestro -- Bug 0017970 - 16/03/2011 - JMF
      param out mensajes   : mensajes de error
      return              : sys_refcursor


     *************************************************************************/
   FUNCTION f_get_lsttipcap(pnsinies IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'pnsinies=' || pnsinies;
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.f_get_lsttipcap';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_listvalores_sin.f_get_lsttipcap(pnsinies, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_lsttipcap;

   /*************************************************************************
      Función f_get_lstTipRelAse
      Recupera el listado de formas de relación con el asegurados
      param out mensajes   : mensajes de error
      return              : sys_refcursor


     *************************************************************************/
   FUNCTION f_get_lsttiprelase(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500);
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.f_get_lsttiprelase';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_listvalores_sin.f_get_lsttiprelase(mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_lsttiprelase;

   /*************************************************************************
      Función f_get_lstNivelSini
      Recupera el listado de niveles de siniestro
      param out mensajes   : mensajes de error
      return              : sys_refcursor


     *************************************************************************/
   FUNCTION f_get_lstnivelsini(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500);
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstnivelsini';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_listvalores_sin.f_get_lstnivelsini(mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_lstnivelsini;

     /*************************************************************************
    Función f_get_lstPersonasCaus
    Recupera el listado de causantes del siniestro
    param in psseguro : Código seguro
    param in pccausin : Causa siniestro
    param in pcmotsin : Motivo siniestro
    param in pcnivel :  Nivel siniestro
    param out mensajes   : mensajes de error
    return              : sys_refcursor


   *************************************************************************/
   FUNCTION f_get_lstpersonascaus(
      psseguro IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin NUMBER,
      pcnivel IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
              := 'pccausin=' || pccausin || ' pcmotsin=' || pcmotsin || ' pcnivel=' || pcnivel;
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstPersonasCaus';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_listvalores_sin.f_get_lstpersonascaus(psseguro, pccausin, pcmotsin,
                                                              pcnivel, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_lstpersonascaus;

-- Fi Bug 0015669 - JRH - 30/09/2010

   /*************************************************************************
       Recupera los Motivos de Rescate de sin_desmotresccau
       param  in psseguro : identificador del seguro
       param  in pccausin : código de la causa del siniestro
       param out mensajes : mensajes de error
       return : ref cursor
    *************************************************************************/
   -- Bug 18913 - APD - 01/07/2011 - se crea la función
   FUNCTION f_get_lstmotresc(
      psseguro IN NUMBER,
      pccausin IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro - ' || psseguro || '; pccausin - ' || pccausin;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstmotresc';
      terror         VARCHAR2(200) := 'Error recuperar lstmotresc';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_lstmotresc(psseguro, pccausin, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstmotresc;

-- fin Bug 18913 - APD - 01/07/2011
   /*************************************************************************
   FUNCTION f_get_lstcconpag_dep
      Recupera concepte pagament (dependiendo del tipo de pago)
      param  in  ctippag  : tipo de pago
      param  out mensajes : missatges d'error
      return              : ref cursor
      bug 21720:ASN:20/03/2012 - creacion
   *************************************************************************/
   FUNCTION f_get_lstcconpag_dep(
      pctippag IN NUMBER,
      psproduc IN NUMBER DEFAULT NULL,   --BUG 27909:NSS:04/09/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'pctippag: ' || pctippag || ' psproduc: ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstcconpag_dep';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_lstcconpag_dep(pctippag, psproduc, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcconpag_dep;

   /*************************************************************************
      Recupera los estados de las causas de un tramite
      param in pcestado : código estado
      param out mensajes : mensajes de error
      return : ref cursor

   -- BUG 0022108 - 19/06/2012 - JMF
   *************************************************************************/
   FUNCTION f_get_lstestadotramite(pcestado IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstestadotramite';
      v_estado       NUMBER;
   BEGIN
      IF pcestado = 0 THEN
         -- 0 (abierto) --> 25 Tramite Apertura
         v_estado := 25;
      ELSIF pcestado = 1 THEN
         -- 1 (Terminado) --> 27 Tramite Finalización
         v_estado := 27;
      ELSIF pcestado = 2 THEN
         -- 2 (Anulado) --> 29 Tramite Anulado
         v_estado := 29;
      ELSIF pcestado = 3 THEN
         -- 3 (Rechazado) --> 28 Tramite Rechazo
         v_estado := 28;
      ELSE
         -- No definido.
         v_estado := -1;
      END IF;

      cur := pac_md_listvalores_sin.f_get_lstestado(v_estado, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstestadotramite;

   /*************************************************************************
       Recupera los subtipos de tipos de tramitación (valores dependientes)
       param  in pcempres : Código Empresa
       param  in pctramit : Código Tramitación
       param out mensajes : mensajes de error
       return : ref cursor
       -- BUG 0023536 - 04/10/2012 - JMF
    *************************************************************************/
   FUNCTION f_get_lstsubtiptra(
      pcempres IN NUMBER,
      pctramit IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstsubtiptra';
      vparam         VARCHAR2(100) := 'pcempres=' || pcempres || ' pctramit=' || pctramit;
      vpasexec       NUMBER(8) := 1;
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_listvalores_sin.f_get_lstsubtiptra(pcempres, pctramit, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstsubtiptra;

   /*************************************************************************
      f_get_lispignorados
       Recupera beneficiarios de las pignoraciones
         param  in psseguro : identificador del seguro
         param out mensajes : mensajes de error
         return             : ref cursor
    *************************************************************************/-- Bug 27766 - 10/12/2013 - se crea la funcion
   FUNCTION f_get_lispignorados(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro - ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lispignorados';
      terror         VARCHAR2(200) := 'Error recuperar lispignorados';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_lispignorados(psseguro, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lispignorados;

   /*************************************************************************
      f_get_beneficiarios_nominales
       Recupera beneficiarios nominales
         param  in psseguro : identificador del seguro
         param  in pfsinies : Fecha de siniestro
         param out mensajes : mensajes de error
         return             : ref cursor
    *************************************************************************/-- Bug 27766 - 10/12/2013 - se crea la funcion
   FUNCTION f_get_beneficiarios_nominales(
      psseguro IN NUMBER,
      pfsinies IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro - ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_beneficiarios_nominales';
      terror         VARCHAR2(200) := 'Error recuperar beneficiarios_nominales';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_beneficiarios_nominales(psseguro, pfsinies,
                                                                  mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_beneficiarios_nominales;

   /*************************************************************************
   FUNCTION f_get_aseginnominado
       Recupera los asegurados innominados
       param  in pnsinies : identificador del siniestro
       param  in pntramit : identificador del tramite
       param out mensajes : mensajes de error
       return : ref cursor
       BUG 35676:
    *************************************************************************/
   FUNCTION f_get_aseginnominado(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_aseginnominado';
      terror         VARCHAR2(200) := 'Error recuperar los asegurados innominados';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_aseginnominado(pnsinies, pntramit, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_aseginnominado;

   FUNCTION f_get_lstgarantias_cap(
      psseguro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstgarantias_cap';
      terror         VARCHAR2(200) := 'Error recuperar las garantias del seguro con su capital';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_lstgarantias_cap(psseguro, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstgarantias_cap;

   FUNCTION f_get_procesos_tramitador(
      pctramitad IN VARCHAR2,
      pctipo IN NUMBER,
      pctramit IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_procesos_tramitador';
      terror         VARCHAR2(200) := 'Error recuperar procesos del tramitador';
   BEGIN
      cur := pac_md_listvalores_sin.f_get_procesos_tramitador(pctramitad, pctipo, pctramit, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_procesos_tramitador;


 /*************************************************************************
      f_get_lstsoldoc
       Recupera beneficiarios de las pignoraciones
         pnsinies  in
         param out mensajes : mensajes de error
         return             : ref cursor
    *************************************************************************/-- Bug 27766 - 10/12/2013 - se crea la funcion
   FUNCTION f_get_lstsoldoc(pnsinies IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstsoldoc';
      terror         VARCHAR2(200) := '';
   BEGIN
      cur := PAC_MD_LISTVALORES_SIN.f_get_lstsoldoc(pnsinies, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstsoldoc;

   /*************************************************************************
      f_get_lsttramit
       Recupera beneficiarios de las pignoraciones
         pnsinies  in
         param out mensajes : mensajes de error
         return             : ref cursor
    *************************************************************************/-- Bug 27766 - 10/12/2013 - se crea la funcion
   FUNCTION f_get_lsttramit(pnsinies IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lsttramit';
      terror         VARCHAR2(200) := '';
   BEGIN
      cur := PAC_MD_LISTVALORES_SIN.f_get_lsttramit(pnsinies, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttramit;

  /*************************************************************************
      f_get_lstpagos
         pnsinies  in varchar2
         pntramit in number
         param out mensajes : mensajes de error
         return             : ref cursor
    *************************************************************************/-- Bug 27766 - 10/12/2013 - se crea la funcion
   FUNCTION f_get_lstpagos(pnsinies IN VARCHAR2, pntramit IN NUMBER,  mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor  IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstpagos';
      terror         VARCHAR2(200) := '';
   BEGIN
      cur := PAC_MD_LISTVALORES_SIN.f_get_lstpagos(pnsinies, pntramit, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstpagos;
   
   /*************************************************************************
         Funciones : f_get_lstcontingencia
         Autor: AB 09/05/2019
         param out mensajes   : mensajes de error
         Consulta de datos para la lista contingencia  de siniestros
         return              : sys_refcursor
         Bug 3603 
   *************************************************************************/
   FUNCTION f_get_lstcontingencia(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500);
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstcontingencia';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_listvalores_sin.f_get_lstcontingencia(mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
         RETURN vcursor;
   END f_get_lstcontingencia;
   
   /*************************************************************************
         Funciones : f_get_lstriesgos
         Autor: AB 09/05/2019
         param out mensajes   : mensajes de error
         Consulta de datos para la lista riesgos  de siniestros
         return              : sys_refcursor
         Bug 3603 
   *************************************************************************/
   
   FUNCTION f_get_lstriesgos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500);
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstcontingencia';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_listvalores_sin.f_get_lstriesgos(mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
         RETURN vcursor;
   END f_get_lstriesgos;
 /*************************************************************************
         Funciones : f_get_lstclaseproceso
         Autor: EA 21/02/2020
         param out mensajes   : mensajes de error
         Consulta de datos para la lista Clase de proceso de siniestros
         return              : sys_refcursor
         Bug o Tarea 3603 
   *************************************************************************/
   FUNCTION f_get_lstclaseproceso(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500);
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstclaseproceso';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_listvalores_sin.f_get_lstclaseproceso(mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
         RETURN vcursor;
   END f_get_lstclaseproceso;
 /*************************************************************************
         Funciones : f_get_lstinstanciaproceso
         Autor: EA 21/02/2020
         param out mensajes   : mensajes de error
         Consulta de datos para la lista Instancia del Proceso de siniestros
         return              : sys_refcursor
         Bug o Tarea 3603 
   *************************************************************************/
   FUNCTION f_get_lstinstanciaproceso(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500);
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstinstanciaproceso';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_listvalores_sin.f_get_lstinstanciaproceso(mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
         RETURN vcursor;
   END f_get_lstinstanciaproceso;
 /*************************************************************************
         Funciones : f_get_lstcontingenciafallo
         Autor: EA 21/02/2020
         param out mensajes   : mensajes de error
         Consulta de datos para la lista Fallo de siniestros
         return              : sys_refcursor
         Bug o Tarea 3603 
   *************************************************************************/
   FUNCTION f_get_lstcontingenciafallo(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500);
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstcontingenciafallo';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_listvalores_sin.f_get_lstcontingenciafallo(mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
         RETURN vcursor;
   END f_get_lstcontingenciafallo;
 /*************************************************************************
         Funciones : f_get_lstcalifmotivo
         Autor: EA 21/02/2020
         param out mensajes   : mensajes de error
         Consulta de datos para la lista Calificación Motivos de siniestros
         return              : sys_refcursor
         Bug o Tarea 3603 
   *************************************************************************/
   FUNCTION f_get_lstcalifmotivo(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500);
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstcalifmotivo';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_listvalores_sin.f_get_lstcalifmotivo(mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
         RETURN vcursor;
   END f_get_lstcalifmotivo;
 /*************************************************************************
         Funciones : f_get_lstoralproceso
         Autor: EA 21/02/2020
         param out mensajes   : mensajes de error
         Consulta de datos para la lista ¿El proceso se llevara a cabo de manera Oral? de siniestros
         return              : sys_refcursor
         Bug o Tarea 12959 
   *************************************************************************/
   FUNCTION f_get_lstoralproceso(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500);
      vobject        VARCHAR2(50) := 'PAC_IAX_LISTVALORES_SIN.f_get_lstoralproceso';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_listvalores_sin.f_get_lstoralproceso(mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode => SQLCODE, psqerrm => SQLERRM);
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;
         RETURN vcursor;
   END f_get_lstoralproceso;

END pac_iax_listvalores_sin;