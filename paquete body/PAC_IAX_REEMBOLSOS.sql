--------------------------------------------------------
--  DDL for Package Body PAC_IAX_REEMBOLSOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_REEMBOLSOS" AS
   /******************************************************************************
      NOM:      PAC_IAX_REEMBOLSOS
      PROPÓSIT: Capa IAX

      REVISIONS:
      Ver        Data        Autor  Descripció
      ---------  ----------  -----  ------------------------------------
      1.0        14/08/2008  XVILA  Creación del package.
      2.0        05/05/2009  SBG    Nous params. a f_set_consultareemb i f_calcacto (Bug 8309)
      3.0        03/07/2009  DRA    3. 0010631: CRE - Modificaciónes modulo de reembolsos
      4.0        01/07/2009  NMM    4. 10682: CRE - Modificaciones para módulo de reembolsos ( ncertif)
      5.0        04/07/2009  DRA    5. 0010704: CRE - Traspaso de facturas para reembolso con mismo Nº Hoja CASS
      6.0        21/07/2009  DRA    6. 0010761: CRE - Reembolsos
      7.0        10/03/2010  DRA    7. 0012676: CRE201 - Consulta de reembolsos - Ocultar descripción de Acto y otras mejoras
      8.0        22/02/2011  DRA    8. 0017732: CRE998 - Modificacions mòdul reemborsaments
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /***********************************************************************
      Rutina que retorna les dades dels reembossaments que compleixin les
      condicions de cerca
      param in  pnreemb   : codi del reembossament
      param in  pcestado  : codi estat
      param in  pnpoliza  : Número pòlissa
      param in  pncass    : Número CASS
      param in  ptnombre  : Nom prenedor
      param in  pcoficina : Codi oficina
      param out mensajes  : T_IAX_MENSAJES
      return              : ref cursor
   ***********************************************************************/
   FUNCTION f_set_consultareemb(
      pestado IN NUMBER,
      pnreemb IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,   -- Mantis 10682.NMM.01/07/2009.
      pncass IN VARCHAR2,
      pnombre IN VARCHAR2,
      pagrsalud IN VARCHAR2,
      poficina IN NUMBER,
      pusuario IN VARCHAR2,
      -- BUG 8309 - 05/05/2009 - SBG - Nou paràmetre de cerca PNFACTCLI
      pnfactcli IN VARCHAR2,
      -- FINAL BUG 8309 - 05/05/2009 - SBG
      pfacto IN DATE,   -- BUG12676:DRA:10/03/2010
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS   -- BUG10761:DRA:21/07/2009
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'parámetros - pnreemb:' || pnreemb || ' - pestado:' || pestado || ' - pnpoliza:'
            || pnpoliza || ' - pncass:' || pncass || ' - pnombre:' || pnombre
            || ' - pagrsalud:' || pagrsalud || ' - poficina:' || poficina || ' - pusuario:'
            || pusuario || ' - pfacto: ' || pfacto;
      vobject        VARCHAR2(50) := 'PAC_IAX_REEMBOLSOS.F_Set_Consultareemb';
      cur            sys_refcursor;
   BEGIN
      -- BUG10761:DRA:21/07/2009:Inici
      -- BUG 8309 - 05/05/2009 - SBG - Nou paràmetre de cerca PNFACTCLI
      -- Mantis 10682.NMM.01/07/2009. S' afegeix ncertif.
      cur := pac_md_reembolsos.f_set_consultareemb(pestado, pnreemb, pnpoliza, pncertif,
                                                   pncass, pnombre, pagrsalud, poficina,
                                                   pusuario, pnfactcli, pfacto, mensajes);
      -- FINAL BUG 8309 - 05/05/2009 - SBG
      -- BUG10761:DRA:21/07/2009:Fi
      vpasexec := 2;
      RETURN cur;
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
   END f_set_consultareemb;

   /***********************************************************************
      Rutina que retorna les dades de les pòlisses amb reembossaments que compleixin les
      condicions de cerca
      param in  pnpoliza : Codi pòlissa
      param in  pncass   : Codi CASS
      param in  ptnombre : Nom prenedor
      param in  psnip    : Número snip
      param out mensajes : T_IAX_MENSAJES
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_set_consulta_activi(
      pnpoliza IN NUMBER,
      pncass IN VARCHAR2,
      ptnombre IN VARCHAR2,
      psnip IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'parámetros - pnpoliza:' || pnpoliza || ' - pncass:' || pncass || ' - ptnombre:'
            || ptnombre || ' - psnip:' || psnip;
      vobject        VARCHAR2(50) := 'PAC_IAX_REEMBOLSOS.F_Set_Consulta_Activi';
      vcursor        sys_refcursor;
   BEGIN
      -- Comprovació pas de paràmetres
      IF pnpoliza IS NULL
         OR pncass IS NULL
         OR ptnombre IS NULL
         OR psnip IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vcursor := pac_md_reembolsos.f_set_consulta_activi(pnpoliza, pncass, ptnombre, psnip,
                                                         mensajes);
      vpasexec := 3;
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
   END f_set_consulta_activi;

   /***********************************************************************
      Rutina que retorna les dades de les pòlisses amb reembossaments que compleixin les
      condicions de cerca
      param in  pnpoliza : Codi pòlissa
      param in  psperson : Codi persona
      param out mensajes : T_IAX_MENSAJES
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_set_consulta_poliza(
      pnpoliza IN NUMBER,
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                         := 'parámetros - pnpoliza:' || pnpoliza || ' - psperson:' || psperson;
      vobject        VARCHAR2(50) := 'PAC_IAX_REEMBOLSOS.F_Set_Consulta_Poliza';
      vcursor        sys_refcursor;
   BEGIN
      -- Comprovació pas de paràmetres
      IF pnpoliza IS NULL
         OR psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vcursor := pac_md_reembolsos.f_set_consulta_poliza(pnpoliza, psperson, mensajes);
      vpasexec := 3;
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
   END f_set_consulta_poliza;

   /***********************************************************************
      Rutina que retorna les dades dels riscs amb reembossaments que compleixin les
      condicions de cerca
      param in  psseguro : Codi segur
      param in  pnriesgo : Codi risc
      param out mensajes : T_IAX_MENSAJES
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_set_consulta_riesgo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psperson IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'parámetros - psseguro:' || psseguro || ' - pnriesgo:' || pnriesgo
            || ' - psperson:' || psperson;
      vobject        VARCHAR2(50) := 'PAC_IAX_REEMBOLSOS.F_Set_Consulta_Riesgo';
      vcursor        sys_refcursor;
   BEGIN
      -- Comprovació pas de paràmetres
      IF psseguro IS NULL
         OR pnriesgo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vcursor := pac_md_reembolsos.f_set_consulta_riesgo(psseguro, pnriesgo, psperson,
                                                         mensajes);
      vpasexec := 3;
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
   END f_set_consulta_riesgo;

   /***********************************************************************
      Rutina que retorna les dades dels riscs amb reembossaments que compleixin les
      condicions de cerca
      param in  psseguro : Codi segur
      param in  pnriesgo : Codi risc
      param out mensajes : T_IAX_MENSAJES
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_set_consulta_reembriesgo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                         := 'parámetros - psseguro:' || psseguro || ' - pnriesgo:' || pnriesgo;
      vobject        VARCHAR2(50) := 'PAC_IAX_REEMBOLSOS.F_Set_Consulta_Reembriesgo';
      vcursor        sys_refcursor;
   BEGIN
      -- Comprovació pas de paràmetres
      IF psseguro IS NULL
         OR pnriesgo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vcursor := pac_md_reembolsos.f_set_consulta_reembriesgo(psseguro, pnriesgo, mensajes);
      vpasexec := 3;
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
   END f_set_consulta_reembriesgo;

   /***********************************************************************
      Rutina que da d'alta un reembossament
      param in  psseguro    : codi segur
      param in  pnriesgo    : codi risc
      param in  pcgarant    : codi garantia
      param in  pcestado    : codi estat
      param in  ptobserv    : camp observació
      param in  pcbancar    : codi banc
      param in  pctipban    : codi tipus bancari
      param in  pcorigen    : codi origen
      param in out ponreemb : codi del reembossament
      param out mensajes    : T_IAX_MENSAJES
      return                : 0 tot correcte
                              1 ha hagut un error
   ***********************************************************************/
   FUNCTION f_set_reembolso(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pcestado IN NUMBER,
      ptobserv IN VARCHAR2,
      pcbancar IN VARCHAR2,
      pctipban IN NUMBER,
      pcorigen IN NUMBER,
      ponreemb IN OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_REEMBOLSOS.F_Set_Reembolso';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro:' || psseguro || ' - pnriesgo:' || pnriesgo
            || ' - pcgarant:' || pcgarant || ' - pcestado:' || pcestado || ' - ptobserv:'
            || ptobserv || ' - pcbancar:' || pcbancar || ' - pctipban:' || pctipban
            || ' - pcorigen:' || pcorigen || ' - ponreemb:' || ponreemb;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      -- Comprovació pas de paràmetres
      IF pcestado IS NULL
         OR pcgarant IS NULL
         OR pcbancar IS NULL
         OR pctipban IS NULL
         OR pcorigen IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_reembolsos.f_set_reembolso(psseguro, pnriesgo, pcgarant, pcestado,
                                                   ptobserv, pcbancar, pctipban, pcorigen,
                                                   ponreemb, mensajes);

      IF vnumerr <> 0 THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
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
   END f_set_reembolso;

   /***********************************************************************
      Rutina que graba los datos de las facturas
      param in pnreemb   : codi segur
      param in pnfactcli : Número factura cliente
      param in pncasase  : Número CASS titular
      param in pncass    : Número CASS asegurado
      param in pfacuse   : Fecha acuse
      param in pffactura : Fecha factura
      param in pimpfact  : Importe factura
      param in porigen   : Origen
      param in pfbaja    : Fecha baja
      param in pctipofac : Tipo factura
      param in pnfact    : Numero factura
      param in pnfactext  : Numero de factura externa
      param in pctractat : Tractada
      param out pnfactnew : Numero factura en alta
      param out mensajes : T_IAX_MENSAJES
      return             : 0 tot correcte
                           1 ha hagut un error
   ***********************************************************************/
   FUNCTION f_set_reembfact(
      pnreemb IN NUMBER,
      pnfactcli IN VARCHAR2,
      pncasase IN VARCHAR2,
      pncass IN VARCHAR2,
      pfacuse IN DATE,
      pffactura IN DATE,
      pimpfact IN NUMBER,
      pfbaja IN DATE,
      pctipofac IN NUMBER,   -- BUG10704:DRA:14/07/2009
      pnfact IN NUMBER,
      pnfactext IN VARCHAR2,   -- BUG10631:DRA:03/07/2009
      pctractat IN NUMBER,   -- BUG17732:DRA:22/02/2011
      pnfactnew OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_REEMBOLSOS.F_Set_ReembFact';
      vparam         VARCHAR2(500)
         := 'parámetros - pnreemb:' || pnreemb || ' - pnfactcli:' || pnfactcli
            || ' - pncasase:' || pncasase || ' - pncass:' || pncass || ' - pfacuse:'
            || pfacuse || ' - pffactura:' || pffactura || ' - pimpfact:' || pimpfact
            || ' - pfbaja:' || pfbaja || ' - pctipofac:' || pctipofac || ' - pnfact:'
            || pnfact || ' - pnfactnew:' || pnfactnew || ' - pnfactext:' || pnfactext
            || ' - pctractat:' || pctractat;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      -- Comprovació pas de paràmetres
      IF pnreemb IS NULL
         OR pfacuse IS NULL
         OR pffactura IS NULL
         OR pimpfact IS NULL
         OR pctipofac IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_reembolsos.f_set_reembfact(pnreemb, pnfactcli, pncasase, pncass,
                                                   pfacuse, pffactura, pimpfact, 1, pfbaja,
                                                   pctipofac,   -- BUG10704:DRA:14/07/2009
                                                   pnfact, pnfactext,   -- BUG10631:DRA:03/07/2009
                                                   pctractat,   -- BUG17732:DRA:22/02/2011
                                                   pnfactnew, mensajes);

      IF vnumerr <> 0 THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
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
   END f_set_reembfact;

    /***********************************************************************
      Rutina que valida y graba la información del acto
      param in  pnreemb     : codi segur
      param in pnfact         : Numero factura
      param in pcacto       : Código de acto
      param in pnacto      : Números de acto
      param in pfacto      : Fecha de acto
      param in ppreemb     : Porcentaje
      param in pitot       : Importe total
      param in piextra     : Importe extra
      param in pipago      : Importe pago
      param in piahorro    : Importe ahorro
      param in pfbaja      : Fecha baja
      param in pnlinea     : Número línea (modificación)
      param in pctipo      : codigo tipo
      param in pipagocomp  : importe de pago complementario
      param in pftrans     : Fecha de transferencia
      param out pnlineanew : Número linea (alta)
      param out ctipomsj   : Tipo mensaje error validación
      param out mensajes   : T_IAX_MENSAJES
      return               : 0 tot correcte
                              1 ha hagut un error
   ***********************************************************************/
   FUNCTION f_set_reembfactact(
      pnreemb IN NUMBER,
      pnfact IN NUMBER,
      pcacto IN VARCHAR2,
      pnacto IN NUMBER,
      pfacto IN DATE,
      pitarcass IN NUMBER,
      picass IN NUMBER,
      ppreemb IN NUMBER,
      pitot IN NUMBER,
      piextra IN NUMBER,
      pipago IN NUMBER,
      piahorro IN NUMBER,
      pfbaja IN DATE,
      pnlinea IN NUMBER,
      pctipo IN NUMBER,   -- BUG10704:DRA:14/07/2009
      pipagocomp IN NUMBER,   -- BUG10704:DRA:14/07/2009
      pftrans IN DATE,   -- BUG10761:DRA:27/07/2009
      pnlineanew OUT NUMBER,
      ctipomsj OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vobject        VARCHAR2(500) := 'PAC_IAX_REEMBOLSOS.F_Set_ReembFactAct';
      vparam         VARCHAR2(500)
         := 'parámetros - pnreemb:' || pnreemb || ' - pnfact:' || pnfact || ' - pcacto:'
            || pcacto || ' - pfacto:' || pfacto || ' - ppreemb:' || ppreemb || ' - pitot:'
            || pitot || ' - piextra:' || piextra || ' - pipago:' || pipago || ' - piahorro:'
            || piahorro || ' - pfbaja:' || pfbaja || ' - pnlinea:' || pnlinea || ' - pctipo:'
            || pctipo || ' - pipagocomp:' || pipagocomp || ' - pftrans:' || pftrans;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      -- Comprovació pas de paràmetres
      IF pnreemb IS NULL
         OR pnfact IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_reembolsos.f_set_reembfactact(pnreemb, pnfact, pcacto, pnacto, pfacto,
                                                      pitarcass, picass, ppreemb, pitot,
                                                      piextra, pipago, piahorro, pfbaja,
                                                      pnlinea, 1, pctipo, pipagocomp,   -- BUG10704:DRA:14/07/2009
                                                      pftrans,   -- BUG10761:DRA:27/07/2009
                                                      pnlineanew, ctipomsj, mensajes);

      IF vnumerr <> 0 THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
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
   END f_set_reembfactact;

   /***********************************************************************
      Rutina que neteja la taula TMP_CONTROLSAN
      param in out mensajes : T_IAX_MENSAJES
      return                : 0 tot correcte
                              1 ha hagut un error
   ***********************************************************************/
   FUNCTION f_neteja_errors(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_REEMBOLSOS.f_neteja_errors';
      vparam         VARCHAR2(500);
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_reembolsos.f_neteja_errors(mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_neteja_errors;

   /***********************************************************************
      Rutina que retorna les dades d'un reembossament
      param in  pnreeemb : Codi reembossament
      param out mensajes : T_IAX_MENSAJES
      return             : objecte reembossaments
   ***********************************************************************/
   FUNCTION f_get_datos_reemb(pnreeemb IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_reembolsos IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'parámetros - pnreeemb:' || pnreeemb;
      vobject        VARCHAR2(200) := 'PAC_IAX_REEMBOLSOS.F_Get_Datos_Reemb';
   BEGIN
      -- Comprovació pas de paràmetres
      IF pnreeemb IS NULL THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_md_reembolsos.f_get_datos_reemb(pnreeemb, mensajes);
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
   END f_get_datos_reemb;

   /***********************************************************************
      Rutina que retorna les factures associades a un reembossament
      param in  pnreeemb : Codi reembossament
      param in  pnfact   : Número factura
      param out mensajes : T_IAX_MENSAJES
      return             : objecte factura
   ***********************************************************************/
   FUNCTION f_get_datos_reembfact(
      pnreeemb IN NUMBER,
      pnfact IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_reembfact IS
      ree            ob_iax_reembfact;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                             := 'parámetros - pnreeemb:' || pnreeemb || ' - pnfact:' || pnfact;
      vobject        VARCHAR2(200) := 'PAC_IAX_REEMBOLSOS.F_Get_Datos_Reembfact';
   BEGIN
      -- Comprovació pas de paràmetres
      IF pnreeemb IS NULL
         OR pnfact IS NULL THEN
         RAISE e_param_error;
      END IF;

      ree := pac_md_reembolsos.f_get_datos_reembfact(pnreeemb, pnfact, mensajes);
      RETURN ree;
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
   END f_get_datos_reembfact;

   /***********************************************************************
      Rutina que retorna els actes associats a un reembossament
      param in  pnreeemb : Codi reembossament
      param in  pnfact   : Número factura
      param in  pnlinea  : Número línia
      param out mensajes : T_IAX_MENSAJES
      return             : objecte acte
   ***********************************************************************/
   FUNCTION f_get_datos_reembactfact(
      pnreemb IN NUMBER,
      pnfact IN NUMBER,
      pnlinea IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_reembactfact IS
      acte           ob_iax_reembactfact;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'parámetros - pnreemb:' || pnreemb || ' - pnfact:' || pnfact || ' - pnlinea:'
            || pnlinea;
      vobject        VARCHAR2(200) := 'PAC_IAX_REEMBOLSOS.F_Get_Datos_Rembactfact';
   BEGIN
      -- Comprovació pas de paràmetres
      IF pnfact IS NULL
         OR pnlinea IS NULL THEN
         RAISE e_param_error;
      END IF;

      acte := pac_md_reembolsos.f_get_datos_reembactfact(pnreemb, pnfact, pnlinea, mensajes);
      RETURN acte;
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
   END f_get_datos_reembactfact;

   /***********************************************************************
      Rutina que retorna les garanties possibles d'un reembossament
      param in  psseguro  : codi del segur
      param in  pnriesgo  : codi del risc
      param in  pfreembo  : data reembossament
      param out mensajes  : T_IAX_MENSAJES
      return              : ref cursor
   ***********************************************************************/
   FUNCTION f_get_garanreemb(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfreembo IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'parámetros - psseguro:' || psseguro || ' - pnriesgo:' || pnriesgo
            || ' - pfreembo' || pfreembo;
      vobject        VARCHAR2(50) := 'PAC_IAX_REEMBOLSOS.F_Get_Garanreemb';
      vcursor        sys_refcursor;
   BEGIN
      -- Comprovació pas de paràmetres
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pfreembo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vcursor := pac_md_reembolsos.f_get_garanreemb(psseguro, pnriesgo, pfreembo, mensajes);
      vpasexec := 2;
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
   END f_get_garanreemb;

   /***********************************************************************
      Rutina que retorna los tipos de centro de facturas
      param out mensajes : T_IAX_MENSAJES
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_lsttipofact(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(50) := 'PAC_IAX_REEMBOLSOS.F_Get_LstTipoFact';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_reembolsos.f_get_lsttipofact(mensajes);
      vpasexec := 2;
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
   END f_get_lsttipofact;

   /***********************************************************************
      Rutina que retorna exclusivamente les dades d'un reembossament
      param in  pnreeemb : Codi reembossament
      param out mensajes : T_IAX_MENSAJES
      return             : objecte reembossaments
   ***********************************************************************/
   FUNCTION f_get_datreemb(pnreeemb IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_reembolsos IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'parámetros - pnreeemb:' || pnreeemb;
      vobject        VARCHAR2(200) := 'PAC_IAX_REEMBOLSOS.F_Get_DatReemb';
   BEGIN
      -- Comprovació pas de paràmetres
      IF pnreeemb IS NULL THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_md_reembolsos.f_get_datreemb(pnreeemb, mensajes);
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
   END f_get_datreemb;

   /***********************************************************************
      Rutina que retorna la lista de actos
      param out mensajes : T_IAX_MENSAJES
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_lstactos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(50) := 'PAC_IAX_REEMBOLSOS.F_Get_LstActos';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_reembolsos.f_get_lstactos(mensajes);
      vpasexec := 2;
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
   END f_get_lstactos;

    /***********************************************************************
      Rutina que devuelve los valores por defecto del acto
      param in  pcacto       : Código acto
      param in  pfacto       : Fecha de acto
      param out oiextra      : Importe Extra
      param out oitotal      : Importe total
      param out mensajes     : T_IAX_MENSAJES
      return                 : 0 tot correcte
                               1 ha hagut un error
   ***********************************************************************/
   FUNCTION f_get_importacto(
      pnreemb IN NUMBER,
      pcacto IN VARCHAR2,
      pfacto IN DATE,
      oitarcass OUT NUMBER,
      oicass OUT NUMBER,
      opreemb OUT NUMBER,
      oiextra OUT NUMBER,
      onacto OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_REEMBOLSOS.F_Get_Importacto';
      vparam         VARCHAR2(500)
         := 'parámetros - pcacto:' || pcacto || ' - pnreemb:' || pnreemb || ' - pfacto:'
            || pfacto;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      -- Comprovació pas de paràmetres
      IF pcacto IS NULL
         OR pfacto IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_reembolsos.f_get_importacto(pnreemb, pcacto, pfacto, oitarcass, oicass,
                                                    opreemb, oiextra, onacto, mensajes);

      IF vnumerr <> 0 THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
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
   END f_get_importacto;

   /***********************************************************************
      Rutina que retorna las agrupaciones de producto AGR_SALUD
      param out mensajes : T_IAX_MENSAJES
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_lstagrsalud(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(50) := 'PAC_IAX_REEMBOLSOS.F_Get_LstAgrSalud';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_reembolsos.f_get_lstagrsalud(mensajes);
      vpasexec := 2;
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
   END f_get_lstagrsalud;

   -- BUG 8309 - 05/05/2009 - SBG - Incorporació paràms. PPORCENT i PITARCASS
   /***********************************************************************
      Rutina que calcula los importes del acto
      param in  pnrremb      : número reembossament
      param in  pcacto       : Código acto
      param in  pfacto       : Fecha de acto
      param in  pnactos      : Número de actos
      param in  pitarcass    : Importe tarifa CASS
      param in  picass       : Importe cass
      param in  pipago       : Importe pago
      param in  pporcent     : Porcentaje pago
      param out oicass       : Importe CASS
      param out oipago       : Importe pago
      param out oitot        : Importe total
      param out mensajes     : T_IAX_MENSAJES
      return                 : 0 tot correcte
                               1 ha hagut un error
   ***********************************************************************/
   FUNCTION f_calcacto(
      pnreemb IN NUMBER,
      pcacto IN VARCHAR2,
      pfacto IN DATE,
      pnactos IN NUMBER,
      pitarcass IN NUMBER,
      picass IN NUMBER,
      pipago IN NUMBER,
      pporcent IN NUMBER,
      oicass OUT NUMBER,   -- BUG10761:DRA:22/07/2009
      oipago OUT NUMBER,
      oitot OUT NUMBER,
      oitarcass OUT NUMBER,
      oiextra OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_IAX_REEMBOLSOS.F_CalcActo';
      vparam         VARCHAR2(500)
         := 'parámetros - pnreemb:' || pnreemb || ' - pcacto:' || pcacto || ' - pfacto:'
            || pfacto || ' - pnactos:' || pnactos || ' - pitarcass:' || pitarcass
            || ' - picass:' || picass || ' - pipago:' || pipago || ' - pporcent:' || pporcent;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      -- Comprovació pas de paràmetres
      IF pcacto IS NULL
         OR pfacto IS NULL
         OR pnreemb IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_reembolsos.f_calcacto(pnreemb, pcacto, pfacto, pnactos, pitarcass,
                                              picass, pipago, pporcent, oicass,   -- BUG10761:DRA:22/07/2009
                                              oipago, oitot, oitarcass, oiextra, mensajes);

      IF vnumerr <> 0 THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      -- FINAL BUG 8309 - 05/05/2009 - SBG
      RETURN vnumerr;
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
   END f_calcacto;

   /*************************************************************************
       Devuelve los asegurados de las pólizas que cumplan con el criterio de selección
       param in psproduc     : código de producto
       param in pnpoliza     : número de póliza
       param in pncert       : número de cerificado por defecto 0
       param in pnnumide     : número identidad persona
       param in psnip        : número identificador externo
       param in pbuscar      : nombre+apellidos a buscar de la persona
       param in ptipopersona : tipo de persona
                                1 tomador
                                2 asegurado
       param out mensajes    : mensajes de error
       return                : ref cursor
    *************************************************************************/
   FUNCTION f_consultapolizaasegurados(
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncert IN NUMBER DEFAULT -1,
      pnnumide IN VARCHAR2,
      psnip IN VARCHAR2,
      pbuscar IN VARCHAR2,
      ptipopersona IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'psproduc=' || psproduc || ' pnpoliza: ' || pnpoliza || ' pncert=' || pncert
            || ' pnnumide=' || pnnumide || ' psnip=' || psnip || ' pbuscar=' || pbuscar
            || ' ptipopersona=' || ptipopersona;
      vobject        VARCHAR2(200) := 'PAC_IAX_REEMBOLSOS.F_ConsultaPolizaAegurados';
   BEGIN
      cur := pac_md_reembolsos.f_consultapolizaasegurados(psproduc, pnpoliza, pncert,
                                                          pnnumide, psnip, pbuscar,
                                                          ptipopersona, mensajes);
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
   END f_consultapolizaasegurados;

   /***********************************************************************
      Rutina que retorna les dades d'un reembossament
      param in  pnreeemb : Codi reembossament
      param out mensajes : T_IAX_MENSAJES
      return             : objecte reembossaments
   ***********************************************************************/
   FUNCTION f_inicializa_reemb(
      psseguro IN reembolsos.sseguro%TYPE,
      pnriesgo IN reembolsos.nriesgo%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_reembolsos IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'parámetros - psseguro:' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_REEMBOLSOS.F_inicializa_Reemb';
   BEGIN
      -- Comprovació pas de paràmetres
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      RETURN pac_md_reembolsos.f_inicializa_reemb(psseguro, pnriesgo, mensajes);
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
   END f_inicializa_reemb;

   /***********************************************************************
      Rutina que Devuelve el tipo de perfil para el usuario conectado a la aplicación
      param out mensajes : T_IAX_MENSAJES
      return             : 1 gestión compañia
                           0 gestión oficina
   ***********************************************************************/
   FUNCTION f_isperfilcompany(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_REEMBOLSOS.F_IsperfilCompany';
   BEGIN
      RETURN pac_md_reembolsos.f_isperfilcompany(mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 0;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 0;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 0;
   END f_isperfilcompany;

   /***********************************************************************
      Valida los reembolsos de una compañia
      param in ptipo,
      param in psseguro,
      param in pnriesgo,
      param in pcgarant,
      param in psperson,
      param in pagr_salud,
      param in pcacto,
      param in pnacto,
      param in pfacto,
      param in piimporte,
      param in pnreemb,
      param in pnfact,
      param in pnlinea,
      param in psmancont,
      param in pftrans,
      param out mensajes : T_IAX_MENSAJES
      return             : 0 - correcto
                número error - incorrecto
   ***********************************************************************/
   FUNCTION f_valida_reemb(
      ptipo IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      psperson IN NUMBER,
      pagr_salud IN NUMBER,
      pcacto IN VARCHAR2,
      pnacto IN NUMBER,
      pfacto IN DATE,
      piimporte IN NUMBER,
      pnreemb IN NUMBER,
      pnfact IN NUMBER,
      pnlinea IN NUMBER,
      psmancont IN NUMBER,
      pftrans IN DATE,   -- BUG10761:DRA:27/07/2009
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - ptipo:' || ptipo || ' - psseguro:' || psseguro || ' - pnriesgo:'
            || pnriesgo || ' - pcgarant:' || pcgarant || ' - psperson:' || psperson
            || ' - pagr_salud:' || pagr_salud || ' - pcacto:' || pcacto || ' - pnacto:'
            || pnacto || ' - pfacto:' || pfacto || ' - piimporte:' || piimporte
            || ' - pnreemb:' || pnreemb || ' - pnfact:' || pnfact || ' - pnlinea:' || pnlinea
            || ' - psmancont:' || psmancont || ' - pftrans:' || pftrans;
      vobject        VARCHAR2(200) := 'PAC_IAX_REEMBOLSOS.F_Valida_reemb';
      resul          NUMBER;
   BEGIN
      resul := pac_md_reembolsos.f_valida_reemb(ptipo, psseguro, pnriesgo, pcgarant, psperson,
                                                pagr_salud, pcacto, pnacto, pfacto, piimporte,
                                                pnreemb, pnfact, pnlinea, psmancont, pftrans,
                                                mensajes);
      COMMIT;

      IF resul <> 0 THEN
         RETURN resul;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_reemb;

   -- BUG10704:DRA:15/07/2009:Inici
   /***********************************************************************
      Función que actualizará el estado de impresión de la factura
      param in  pnreemb   : codi del reembossament
      param in  pnfact    : Número de factura
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_act_factura(pnreemb IN NUMBER, pnfact IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                               := 'parámetros - pnreemb:' || pnreemb || ' - pnfact:' || pnfact;
      vobject        VARCHAR2(200) := 'PAC_IAX_REEMBOLSOS.f_act_factura';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_reembolsos.f_act_factura(pnreemb, pnfact, mensajes);

      IF vnumerr <> 0 THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_act_factura;

   /***********************************************************************
      Función que hará el traspaso de una factura a un reembolso ya existente
      param in  pnreemb   : codi del reembossament
      param in  pnfact    : Número de factura
      param in  pnfactcli : Número factura cliente
      param in  pnreembori: reembolso al cual tenemos que traspasar la factura
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_traspasar_factura(
      pnreemb IN NUMBER,
      pnfact IN NUMBER,
      pnfactcli IN VARCHAR2,
      pnreembori IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - pnreemb:' || pnreemb || ' - pnfact:' || pnfact || ' - pnfactcli:'
            || pnfactcli || ' - pnreembori:' || pnreembori;
      vobject        VARCHAR2(200) := 'PAC_IAX_REEMBOLSOS.f_traspasar_factura';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_reembolsos.f_traspasar_factura(pnreemb, pnfact, pnfactcli, pnreembori,
                                                       mensajes);

      IF vnumerr <> 0 THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_traspasar_factura;

   /***********************************************************************
      Función que nos dirá si se puede o no modificar la factura
      param in  pnreemb   : codi del reembossament
      param in  pnfact    : Número de factura
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_modif_factura(pnreemb IN NUMBER, pnfact IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                               := 'parámetros - pnreemb:' || pnreemb || ' - pnfact:' || pnfact;
      vobject        VARCHAR2(200) := 'PAC_IAX_REEMBOLSOS.f_modif_factura';
      vnumerr        NUMBER;
      v_permite      NUMBER(8);
      v_accion       NUMBER;
   BEGIN
      vnumerr := pac_md_reembolsos.f_modif_factura(pnreemb, pnfact, mensajes);
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_modif_factura;

   /***********************************************************************
      Función para detectar si el nº hoja CASS ya existe
      param in pnreemb    : codi del reembossament
      param in  pnfactcli : codi factura client
      param out pnreembdest  : codi del reembossament
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_existe_factcli(
      pnreemb IN NUMBER,
      pnfactcli IN VARCHAR2,
      pnreembdest OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                         := 'parámetros - pnreemb: ' || pnreemb || ' -pnfactcli:' || pnfactcli;
      vobject        VARCHAR2(200) := 'PAC_IAX_REEMBOLSOS.f_existe_factcli';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_reembolsos.f_existe_factcli(pnreemb, pnfactcli, pnreembdest, mensajes);

      IF vnumerr <> 0 THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
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
   END f_existe_factcli;

   /***********************************************************************
      Rutina que retorna los tipos de acto
      param out mensajes : T_IAX_MENSAJES
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_lsttipoactos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(50) := 'PAC_IAX_REEMBOLSOS.F_Get_lsttipoactos';
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_md_reembolsos.f_get_lsttipoactos(mensajes);
      vpasexec := 2;
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
   END f_get_lsttipoactos;

   -- BUG10704:DRA:15/07/2009:Fi

   /***********************************************************************
      Rutina que calcula el importe complementario
      param in  pitot        : Importe total
      param in  pipago       : Importe pago
      param in  picass       : Importe cass
      param out oipagocomp   : Importe pago complementario
      param out mensajes     : T_IAX_MENSAJES
      return                 : 0 tot correcte
                               1 ha hagut un error
   ***********************************************************************/
   -- BUG10761:DRA:22/07/2009:Inici
   FUNCTION f_calcomplementario(
      pitot IN NUMBER,
      pipago IN NUMBER,
      picass IN NUMBER,
      oipagocomp OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vobject        VARCHAR2(500) := 'PAC_IAX_REEMBOLSOS.F_calcomplementario';
      vparam         VARCHAR2(500)
         := 'parámetros - pitot:' || pitot || ' - pipago:' || pipago || ' - picass:' || picass;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_reembolsos.f_calcomplementario(pitot, pipago, picass, oipagocomp,
                                                       mensajes);
      RETURN vnumerr;
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
   END;

   /***********************************************************************
      Función para detectar si la factura es Ordinaria o Complementaria
      param in pnreemb    : codi del reembossament
      param in  pnfact    : codi factura
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_tipo_factura(pnreemb IN NUMBER, pnfact IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                               := 'parámetros - pnreemb: ' || pnreemb || ' -pnfact:' || pnfact;
      vobject        VARCHAR2(200) := 'PAC_IAX_REEMBOLSOS.f_tipo_factura';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_reembolsos.f_tipo_factura(pnreemb, pnfact, mensajes);

      IF vnumerr <> 0 THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
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
   END f_tipo_factura;

-- BUG10761:DRA:22/07/2009:Fi
-- BUG10949:JGM:19/08/2009:Fi
   /***********************************************************************
      Función para detectar si la factura tiene fecha de baja y cual
      param in pnreemb    : codi del reembossament
      param in  pnfact    : codi factura
      fbaja out  date    : data baixa
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_get_data_baixa(
      pnreemb IN NUMBER,
      pnfact IN NUMBER,
      pfbaja OUT DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                               := 'parámetros - pnreemb: ' || pnreemb || ' -pnfact:' || pnfact;
      vobject        VARCHAR2(200) := 'PAC_IAX_REEMBOLSOS.f_get_data_baixa';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_reembolsos.f_get_data_baixa(pnreemb, pnfact, pfbaja, mensajes);

      IF vnumerr <> 0 THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
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
   END f_get_data_baixa;

   -- BUG10949:JGM:19/08/2009:Fi

   -- BUG17732:DRA:22/02/2011:Inici
   /***********************************************************************
      Función para modificar la CCC del reembolso
      param in pnreemb    : codi del reembossament
      param in pcheck     : codi factura
      return              : 0 OK     1 ERROR
   ***********************************************************************/
   FUNCTION f_modificar_ccc(pnreemb IN NUMBER, pcheck IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                             := 'parámetros - pnreemb: ' || pnreemb || ' - pcheck: ' || pcheck;
      vobject        VARCHAR2(200) := 'PAC_IAX_REEMBOLSOS.f_modificar_ccc';
      vnumerr        NUMBER := 0;
   BEGIN
      -- Comprovació pas de paràmetres
      IF pnreemb IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_reembolsos.f_modificar_ccc(pnreemb, pcheck, mensajes);

      IF vnumerr <> 0 THEN
         vpasexec := 2;
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_modificar_ccc;
-- BUG17732:DRA:22/02/2011:Fi
END pac_iax_reembolsos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_REEMBOLSOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_REEMBOLSOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_REEMBOLSOS" TO "PROGRAMADORESCSI";
