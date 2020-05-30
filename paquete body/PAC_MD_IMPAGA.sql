--------------------------------------------------------
--  DDL for Package Body PAC_MD_IMPAGA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_IMPAGA" IS
   /******************************************************************************
    NOMBRE:      PAC_MD_IMPAGA
    PROPÓSITO:   Funciones para las interfases en segunda capa

    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------------  ------------------------------------
    1.0        ??/??/????   ???               1. Creación del package.
    2.0        13/06/2012   APD               2. 0022342: MDP_A001-Devoluciones
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   -- Bug 22342 - APD - 13/06/2012 - se añade el parametro pcagente
   FUNCTION f_get_prodreprec(
      psidprodp IN NUMBER,
      psproduc IN NUMBER,
      pctipoimp IN NUMBER,
      pcagente IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'psidprodp=' || psidprodp || 'psproduc=' || psproduc || ' pctipoimp=' || pctipoimp
            || ' pcagente=' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_MD_IMPAGA.F_get_prodreprec';
      psquery        VARCHAR2(1000);
      vnum_err       NUMBER;
      vcursor        sys_refcursor;
   BEGIN
      -- Bug 22342 - APD - 13/06/2012 - el producto o el agente deben estar informados
      IF (psproduc IS NULL
          AND pcagente IS NULL) THEN
         RAISE e_param_error;
      END IF;

         -- fin Bug 22342 - APD - 13/06/2012
      -- Bug 22342 - APD - 13/06/2012 - se añade el parametro pcagente
      vnum_err := pac_impaga.f_get_prodreprec(psidprodp, psproduc, NULL, pctipoimp,
                                              pac_md_common.f_get_cxtidioma(), NULL, pcagente,
                                              psquery);

      IF vnum_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnum_err);
         RAISE e_object_error;
      END IF;

      vcursor := pac_iax_listvalores.f_opencursor(psquery, mensajes);
      RETURN vcursor;
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
   END f_get_prodreprec;

   FUNCTION f_elimina_prodreprec(psidprodp IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_impaga.f_elimina_prodreprec';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'sidprodp : ' || psidprodp;
      error          NUMBER;
   BEGIN
      IF (psidprodp IS NULL) THEN
         RAISE e_param_error;
      END IF;

      error := pac_impaga.f_elimina_prodreprec(psidprodp);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, error);
         RAISE e_object_error;
      END IF;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_elimina_prodreprec;

   -- Bug 22342 - APD - 13/06/2012 - se añade el parametro pcagente
   FUNCTION f_set_prodreprec(
      psidprodp IN NUMBER,
      psproduc IN NUMBER,
      pfiniefe IN DATE,
      pctipoimp IN NUMBER,
      pctipnimp IN NUMBER,
      pcagente IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_impaga.f_set_prodreprec';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'psproduc : ' || psproduc || 'pfiniefe : ' || pfiniefe || 'pctipoimp : '
            || pctipoimp || 'pctipnimp : ' || pctipnimp || 'pcagente : ' || pcagente;
      error          NUMBER;
   BEGIN
      -- Bug 22342 - APD - 13/06/2012 - el producto o el agente deben estar informados
      IF ((psproduc IS NULL
           AND pcagente IS NULL)
          OR pfiniefe IS NULL
          OR pctipoimp IS NULL
          OR pctipnimp IS NULL) THEN
         RAISE e_param_error;
      END IF;

      -- fin Bug 22342 - APD - 13/06/2012

      -- Bug 22342 - APD - 13/06/2012 - se añade el parametro pcagente
      error := pac_impaga.f_set_prodreprec(psidprodp, psproduc, pfiniefe, pctipoimp, pctipnimp,
                                           pcagente);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, error);
         RAISE e_object_error;
      END IF;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_prodreprec;

   FUNCTION f_get_detprodreprec(
      psidprodp IN NUMBER,
      pcmotivo IN NUMBER,
      pnimpagad IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'psidprodp=' || psidprodp || ' pcmotivo=' || pcmotivo || ' pnimpagad= '
            || pnimpagad;
      vobject        VARCHAR2(200) := 'PAC_MD_IMPAGA.F_get_detprodreprec';
      psquery        VARCHAR2(1000);
      vnum_err       NUMBER;
      vcursor        sys_refcursor;
   BEGIN
      IF (psidprodp IS NULL) THEN
         RAISE e_param_error;
      END IF;

      vnum_err := pac_impaga.f_get_detprodreprec(psidprodp, pcmotivo, pnimpagad,
                                                 pac_md_common.f_get_cxtidioma(), psquery);

      IF vnum_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnum_err);
         RAISE e_object_error;
      END IF;

      vcursor := pac_iax_listvalores.f_opencursor(psquery, mensajes);
      RETURN vcursor;
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
   END f_get_detprodreprec;

   FUNCTION f_elimina_detprodreprec(
      psidprodp IN NUMBER,
      pcmotivo IN NUMBER,
      pnimpagad IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_impaga.f_elimina_detprodreprec';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'sidprodp : ' || psidprodp || 'pcmotivo : ' || pcmotivo || 'pnimpagad : '
            || pnimpagad;
      error          NUMBER;
   BEGIN
      IF (psidprodp IS NULL
          OR pcmotivo IS NULL) THEN
         RAISE e_param_error;
      END IF;

      error := pac_impaga.f_elimina_detprodreprec(psidprodp, pcmotivo, pnimpagad);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, error);
         RAISE e_object_error;
      END IF;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_elimina_detprodreprec;

   FUNCTION f_set_detprodreprec(
      psidprodp IN NUMBER,
      pcmotivo IN NUMBER,
      pcmodimm IN NUMBER,
      pcactimm IN NUMBER,
      pcdiaavis IN NUMBER,
      pcmodelo IN NUMBER,
      pcactimp IN NUMBER,
      pndiaavis IN NUMBER,
      pnimpagad IN NUMBER,
      pmodo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_md_impaga.f_set_detprodreprec';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'sidprodp : ' || psidprodp || 'pcmotivo : ' || pcmotivo || 'pnimpagad : '
            || pnimpagad;
      error          NUMBER;
   BEGIN
      IF (psidprodp IS NULL
          OR pcmotivo IS NULL
          OR pmodo IS NULL) THEN
         RAISE e_param_error;
      END IF;

      IF (pcactimp IS NULL
          AND pcactimm IS NULL) THEN
         RAISE e_param_error;
      END IF;

      error := pac_impaga.f_set_detprodreprec(psidprodp, pcmotivo, pcmodimm, pcactimm,
                                              pcdiaavis, pcmodelo, pcactimp, pndiaavis,
                                              pnimpagad, pmodo);

      IF error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, error);
         RAISE e_object_error;
      END IF;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_detprodreprec;

   -- Bug 22342 - APD - 13/06/2012 - se modifican los parametros de entrada
   FUNCTION f_get_impagados(
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pctiprec IN NUMBER,
      pfaccini IN DATE,
      pfaccfin IN DATE,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnrecibo IN NUMBER,
      pnimpagad IN NUMBER,
      pcoficina IN NUMBER,
      pcagente IN NUMBER,
      pcmotivo IN NUMBER,
      pccarta IN NUMBER,
      pcactimp IN NUMBER,
      pcidioma IN NUMBER,
      pcursor OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'psseguro=' || psseguro || ' pcramo=' || pcramo || ' psproduc=' || psproduc
            || ' pctiprec=' || pctiprec || ' pfaccini=' || TO_CHAR(pfaccini, 'dd/mm/yyyy')
            || ' pfaccfin=' || TO_CHAR(pfaccfin, 'dd/mm/yyyy') || ' pnpoliza=' || pnpoliza
            || ' pncertif=' || pncertif || ' pnrecibo=' || pnrecibo || ' pnimpagad='
            || pnimpagad || ' pcoficina=' || pcoficina || ' pcagente=' || pcagente
            || ' pcmotivo=' || pcmotivo || ' pccarta=' || pccarta || ' pcactimp=' || pcactimp
            || ' pcidioma=' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_MD_IMPAGA.F_get_impagados';
      vsquery        VARCHAR2(10000);
      vnum_err       NUMBER := 0;
      vcursor        sys_refcursor;
   BEGIN
      vnum_err := pac_impaga.f_get_impagados(psseguro, pcramo, psproduc, pctiprec, pfaccini,
                                             pfaccfin, pnpoliza, pncertif, pnrecibo,
                                             pnimpagad, pcoficina, pcagente, pcmotivo,
                                             pccarta, pcactimp,
                                             NVL(pcidioma, pac_md_common.f_get_cxtidioma()),
                                             vsquery);

      IF vnum_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnum_err);
         RAISE e_object_error;
      END IF;

      pcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         IF pcursor%ISOPEN THEN
            CLOSE pcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         IF pcursor%ISOPEN THEN
            CLOSE pcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         IF pcursor%ISOPEN THEN
            CLOSE pcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_impagados;

   FUNCTION f_get_detimpagado(
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pfaccion IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
           := 'psseguro=' || psseguro || ' pnrecibo= ' || pnrecibo || ' pfaccion=' || pfaccion;
      vobject        VARCHAR2(200) := 'PAC_MD_IMPAGA.F_get_detimpagado';
      psquery        VARCHAR2(1000);
      vnum_err       NUMBER;
      vcursor        sys_refcursor;
   BEGIN
      IF (psseguro IS NULL
          OR pnrecibo IS NULL
          OR pfaccion IS NULL) THEN
         RAISE e_param_error;
      END IF;

      vnum_err := pac_impaga.f_get_detimpagado(psseguro, pnrecibo, pfaccion, psquery);

      IF vnum_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnum_err);
         RAISE e_object_error;
      END IF;

      vcursor := pac_iax_listvalores.f_opencursor(psquery, mensajes);
      RETURN vcursor;
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
   END f_get_detimpagado;

   FUNCTION f_set_impagado(
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pfaccion IN DATE,
      pfalta IN DATE,
      pcmotdev IN NUMBER,
      pcaccion IN NUMBER,
      pcsituac IN NUMBER,
      pttexto IN VARCHAR2,
      pterror IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'psseguro=' || psseguro || ' pnrecibo= ' || pnrecibo || ' pfaccion=' || pfaccion
            || 'pfalta=' || pfalta || ' pcmotdev= ' || pcmotdev || ' pcaccion=' || pcaccion
            || 'pcsituac=' || pcsituac || ' pttexto= ' || pttexto || ' pterror=' || pterror;
      vobject        VARCHAR2(200) := 'PAC_MD_IMPAGA.f_set_impagado';
      vnum_err       NUMBER;
   BEGIN
      IF (psseguro IS NULL
          OR pnrecibo IS NULL
          OR pfaccion IS NULL) THEN
         RAISE e_param_error;
      END IF;

      vnum_err := pac_impaga.f_set_impagado(psseguro, pnrecibo, pfaccion, pfalta, pcmotdev,
                                            pcaccion, pcsituac, pttexto, pterror);

      IF vnum_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnum_err);
         RAISE e_object_error;
      END IF;

      RETURN vnum_err;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_impagado;

   FUNCTION f_elimina_impagado(
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pfaccion IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
           := 'psseguro=' || psseguro || ' pnrecibo= ' || pnrecibo || ' pfaccion=' || pfaccion;
      vobject        VARCHAR2(200) := 'PAC_MD_IMPAGA.f_elimina_impagado';
      vnum_err       NUMBER;
   BEGIN
      IF (psseguro IS NULL
          OR pnrecibo IS NULL
          OR pfaccion IS NULL) THEN
         RAISE e_param_error;
      END IF;

      vnum_err := pac_impaga.f_elimina_impagado(psseguro, pnrecibo, pfaccion);

      IF vnum_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnum_err);
         RAISE e_object_error;
      END IF;

      RETURN vnum_err;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_elimina_impagado;

   FUNCTION f_get_lstcartas(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := '';
      vobject        VARCHAR2(200) := 'PAC_MD_IMPAGA.f_get_lstcartas';
      psquery        VARCHAR2(1000);
      vnum_err       NUMBER;
      vcursor        sys_refcursor;
   BEGIN
      vnum_err := pac_impaga.f_get_lstcartas(pac_md_common.f_get_cxtidioma, psquery);

      IF vnum_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnum_err);
         RAISE e_object_error;
      END IF;

      vcursor := pac_iax_listvalores.f_opencursor(psquery, mensajes);
      RETURN vcursor;
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
   END f_get_lstcartas;

   -- Funcion para modificar la acción o la carta de un impagado
   -- Bug 22342 - APD - 13/06/2012 - se crea la funcion
   FUNCTION f_set_acccarta(
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pcactimp IN NUMBER,
      pffejecu IN DATE,
      pcactact IN NUMBER,
      pccarta IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'psseguro=' || psseguro || ' pnrecibo= ' || pnrecibo || ' pcactimp=' || pcactimp
            || 'pffejecu=' || TO_CHAR(pffejecu, 'DD/MM/YYYY') || ' pcactact= ' || pcactact
            || ' pccarta=' || pccarta;
      vobject        VARCHAR2(200) := 'PAC_MD_IMPAGA.f_set_acccarta';
      psquery        VARCHAR2(1000);
      vnum_err       NUMBER := 0;
   BEGIN
      IF psseguro IS NULL
         OR pnrecibo IS NULL
         OR pcactimp IS NULL
         OR pffejecu IS NULL
         OR pcactact IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnum_err := pac_impaga.f_set_acccarta(psseguro, pnrecibo, pcactimp, pffejecu, pcactact,
                                            pccarta);
      vpasexec := 3;

      IF vnum_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnum_err);
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      RETURN vnum_err;
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
   END f_set_acccarta;
END pac_md_impaga;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_IMPAGA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_IMPAGA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_IMPAGA" TO "PROGRAMADORESCSI";
