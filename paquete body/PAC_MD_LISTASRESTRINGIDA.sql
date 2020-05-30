--------------------------------------------------------
--  DDL for Package Body PAC_MD_LISTASRESTRINGIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_LISTASRESTRINGIDA" IS
/******************************************************************************
    NOMBRE:      PAC_MD_LISTASRESTRINGIDA
    PROP真SITO:   Funciones para las listas restringidas

    REVISIONES:
    Ver        Fecha        Autor             Descripci真n
    ---------  ----------  ---------------  ------------------------------------
    1.0        31/10/2012  AMC               1. Creaci真n del package.
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
       FUNCTION f_get_listarestringida
       Funci真n que recupera las listas restringidas

       return lista de personas restringidas

       Bug 23824/124452 - 31/10/2012 - AMC
    *************************************************************************/
   FUNCTION f_get_listarestringida(
      pctipper IN NUMBER,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnomape IN VARCHAR2,
      pcclalis IN NUMBER,
      pctiplis IN NUMBER,
      pfinclusdesde IN DATE,
      pfinclushasta IN DATE,
      pfexclusdesde IN DATE,
      pfexclushasta IN DATE,
      psperlre IN NUMBER,
      pfnacimi IN DATE,
      ptdescrip IN VARCHAR2, --Se incluye campo tdescrip, AMA-232
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vparam         VARCHAR2(500)
         := 'pctipper: ' || pctipper || ' pctipide: ' || pctipide || ' pnnumide: ' || pnnumide
            || ' ptnomape: ' || ptnomape || ' pcclalis: ' || pcclalis || ' pctiplis: '
            || pctiplis || ' pfinclusdesde: ' || pfinclusdesde || ' pfinclushasta: '
            || pfinclushasta || ' pfexclusdesde: ' || pfexclusdesde || ' pfexclushasta: '
            || pfexclushasta || ' psperlre:' || psperlre || 'ptdescrip: '||ptdescrip;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTASRESTRINGIDA.f_get_listarestringida';
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      squery         VARCHAR2(4000);   -- Bug 31411/175020 - 16/05/2014 - AMC
   BEGIN
      squery := pac_listarestringida.f_get_listarestringida(pctipper, pctipide, pnnumide,
                                                            ptnomape, pcclalis, pctiplis,
                                                            pfinclusdesde, pfinclushasta,
                                                            pfexclusdesde, pfexclushasta,
                                                            psperlre,
                                                            pac_md_common.f_get_cxtidioma(),
                                                            pfnacimi,ptdescrip);

      IF squery IS NOT NULL THEN
         cur := pac_md_listvalores.f_opencursor(squery, mensajes);
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_listarestringida;

   /*************************************************************************
                   FUNCTION f_set_listarestringida
       Funci真n que inserta en la tabla lre_personas
       pspersonas in varchar2: Lista de personas
       pcclalis in number: Clase de lista
       pctiplis in number: Tipo de lista
       pcnotifi in number: Indicador de si hay que notificar o no la inserci真n en la lista.
       psperlre in number: Identificador de persona restringida
       pfexclus in date: Fecha de exclusi真n
       pfinclus in date: Fecha de inclusi真n
       pcinclus in number: C真digo motivo de inclusi真n
       mensajes in out : Mensajes de error
       return number: 0 -ok , otro valor ERROR
    *************************************************************************/
   FUNCTION f_set_listarestringida(
      psperson IN NUMBER,
      pcclalis IN NUMBER,
      pctiplis IN NUMBER,
      pcnotifi IN NUMBER,
      psperlre IN NUMBER,
      pfexclus IN DATE,
      pfinclus IN DATE,
      pcinclus IN NUMBER,
      pfnacimi IN DATE,
      ptdescrip IN VARCHAR2, --Se incluye campo tdescrip, AMA-232
      ptobserv IN VARCHAR2,
      ptmotexc IN VARCHAR2,
      psperlre_out OUT NUMBER,
      mensajes IN OUT t_iax_mensajes
      )
      RETURN NUMBER IS
      vtparam        tab_error.tdescrip%TYPE;
      vobject        tab_error.tobjeto%TYPE
                                          := 'pac_md_listasrestringida.f_set_listarestringida';
      vpasexec       NUMBER(1) := 0;
      vnumerr        NUMBER;
   BEGIN
      vtparam := 'psperson: ' || psperson || ' pcclalis: ' || pcclalis || ' pctiplis: '
                 || pctiplis || ' pcnotifi: ' || pcnotifi || ' psperlre:' || psperlre
                 || ' pfexclus:' || pfexclus || ' pfinclus:' || pfinclus || ' pcinclus:'
                 || pcinclus|| ' pfnacimi:' || pfnacimi|| ' ptdescrip:' || ptdescrip
                 || ' ptobserv:' || ptobserv|| ' ptmotexc:' || ptmotexc|| ' psperlre_out:' || psperlre_out;
      vpasexec := 1;

      IF psperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF psperlre IS NULL THEN
         vnumerr := pac_listarestringida.f_get_existepersona(psperson, pcclalis, pctiplis,
                                                             pcinclus);

         IF vnumerr > 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 2;
      vnumerr :=
         pac_listarestringida.f_set_listarestringida
                                                   (psperson, pcclalis, pctiplis, pcnotifi,
                                                    psperlre_out, psperlre, pfexclus, pfinclus,
                                                    pcinclus, NULL, NULL, NULL, NULL, NULL,
                                                    NULL, NULL,   -- Bug 31411/175020 - 16/05/2014 - AMC
                                                    pfnacimi,ptdescrip, ptobserv, ptmotexc
                                                    );

      IF vnumerr > 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vtparam);
         RETURN vnumerr;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vtparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vtparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN vnumerr;
   END f_set_listarestringida;

   /*************************************************************************
       FUNCTION f_get_listarestringida_aut
       Funci真n que recupera las listas restringidas de autos

       return lista de autos restringidos

       Bug 26923/152307 - 10/09/2013 - AMC
    *************************************************************************/
   FUNCTION f_get_listarestringida_aut(
      pcmatric IN VARCHAR2,
      pcodmotor IN VARCHAR2,
      pcchasis IN VARCHAR2,
      pnbastid IN VARCHAR2,
      pcclalis IN NUMBER,
      pctiplis IN NUMBER,
      pfinclusdesde IN DATE,
      pfinclushasta IN DATE,
      pfexclusdesde IN DATE,
      pfexclushasta IN DATE,
      psmatriclre IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vparam         VARCHAR2(1000)
         := 'pcmatric: ' || pcmatric || ' pcodmotor: ' || pcodmotor || ' pcchasis: '
            || pcchasis || ' pnbastid: ' || pnbastid || ' pcclalis: ' || pcclalis
            || ' pctiplis: ' || pctiplis || ' pfinclusdesde: ' || pfinclusdesde
            || ' pfinclushasta: ' || pfinclushasta || ' pfexclusdesde: ' || pfexclusdesde
            || ' pfexclushasta: ' || pfexclushasta;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTASRESTRINGIDA.f_get_listarestringida_aut';
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      squery         VARCHAR2(2000);
   BEGIN
      squery :=
         pac_listarestringida.f_get_listarestringida_aut(pcmatric, pcodmotor, pcchasis,
                                                         pnbastid, pcclalis, pctiplis,
                                                         pfinclusdesde, pfinclushasta,
                                                         pfexclusdesde, pfexclushasta,
                                                         pac_md_common.f_get_cxtidioma(),
                                                         psmatriclre);

      IF pac_md_log.f_log_consultas(squery,
                                    'pac_md_listasrestringida.f_get_listarestringida_aut', 1,
                                    2, mensajes) <> 0 THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      END IF;

      IF squery IS NOT NULL THEN
         cur := pac_md_listvalores.f_opencursor(squery, mensajes);
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_listarestringida_aut;

   /*************************************************************************
      FUNCTION f_set_listarestringida_aut
       Funcion que inserta en la tabla lre_autos
       psmatric in varchar2: Lista de Placas
       pcodmotor IN VARCHAR2: codigo de motor
       pcchasis IN VARCHAR2,: codigo de chasis
       pnbastid IN VARCHAR2: codigo VIN o Nbastidor
       pcclalis in number: Clase de lista
       pctiplis in number: Tipo de lista
       pcnotifi in number: Indicador de si hay que notificar o no la inserci真n en la lista.
       psmatrilre in number: Identificador de matricula restringida
       pfexclus in date: Fecha de exclusi真n
       pfinclus in date: Fecha de inclusi真n
       pcinclus in number: C真digo motivo de inclusi真n
       return number: 0 -ok , otro valor ERROR

       Bug 26923/152307 - 10/09/2013 - AMC
    *************************************************************************/
   FUNCTION f_set_listarestringida_aut(
      psmatric IN VARCHAR2,
      pcodmotor IN VARCHAR2,
      pcchasis IN VARCHAR2,
      pnbastid IN VARCHAR2,
      pcclalis IN NUMBER,
      pctiplis IN NUMBER,
      pcnotifi IN NUMBER,
      psmatriclre IN NUMBER,
      pfexclus IN DATE,
      pfinclus IN DATE,
      pcinclus IN NUMBER,
      psmatriclre_out OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vtparam        VARCHAR2(1000)
         := 'psmatric: ' || psmatric || ' pcclalis: ' || pcclalis || ' pctiplis: ' || pctiplis
            || ' pcnotifi: ' || pcnotifi || ' pfexclus:' || pfexclus || ' pfinclus:'
            || pfinclus || ' pcinclus:' || pcinclus;
      vobject        tab_error.tobjeto%TYPE
                                      := 'pac_md_listasrestringida.f_set_listarestringida_aut';
      vpasexec       NUMBER(1) := 0;
      vnumerr        NUMBER;
   BEGIN
      vpasexec := 1;

      IF psmatric IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF psmatriclre IS NULL THEN
         vnumerr := pac_listarestringida.f_get_existeauto(psmatric, pcclalis, pctiplis,
                                                          pcinclus);

         IF vnumerr > 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 2;
      vnumerr :=
         pac_listarestringida.f_set_listarestringida_aut
                                                    (psmatric, pcodmotor, pcchasis, pnbastid,
                                                     pcclalis, pctiplis, pcnotifi,
                                                     psmatriclre_out, psmatriclre, pfexclus,
                                                     pfinclus, pcinclus, NULL, NULL, NULL,
                                                     NULL, NULL, NULL,
                                                     NULL   -- Bug 31411/175020 - 16/05/2014 - AMC
                                                         );

      IF vnumerr > 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vtparam);
         RETURN vnumerr;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vtparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vtparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN vnumerr;
   END f_set_listarestringida_aut;

   /*************************************************************************
   FUNCTION f_get_historico_persona
      Funci真n que recupera los datos hist真ricos de una persona en lista restringida
      return cursor
      Bug CONF-239 JAVENDANO 01/09/2016
   *************************************************************************/
    FUNCTION f_get_historico_persona(
      pnnumide    IN       VARCHAR2,
      mensajes    OUT	   T_IAX_MENSAJES
    )
    RETURN SYS_REFCURSOR IS
        cur sys_refcursor;
        vobject varchar2(60) := 'pac_md_listasrestringida.f_get_historico_persona';
        vparam  varchar2(60) := 'pnnumide: ' || pnnumide;
        NUM_ERR NUMBER;
    BEGIN
        cur := pac_listarestringida.F_GET_HISTORICO_PERSONA(pnnumide);
        return cur;
    EXCEPTION WHEN OTHERS THEN
        pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, NULL, vparam);
        IF cur%ISOPEN THEN
            CLOSE cur;
        END IF;
        RETURN cur;
    END f_get_historico_persona;


END pac_md_listasrestringida;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTASRESTRINGIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTASRESTRINGIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTASRESTRINGIDA" TO "PROGRAMADORESCSI";
