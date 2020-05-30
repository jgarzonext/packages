--------------------------------------------------------
--  DDL for Package Body PAC_IAX_WS_SUPL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_WS_SUPL" AS
   /******************************************************************************
    NOMBRE:      pac_iax_ws_supl
    PROPÓSITO:   Interficie para cada tipo de suplemento

    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------------  ------------------------------------
    1.0        28/07/2009   JRH                1. Creación del package. Bug 10776 reducción total
    2.0        15/09/2010   JRH                2. 0012278: Proceso de PB para el producto PEA.
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Realiza la reduccion total de una póliza
      param in psseguro   : Número de seguro
      param in pfefecto   : Fecha del suplemento (puede ser nula)
      param out           : mensajes de error
      return              : 0 todo correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_reduccion_total(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vestsseguro    NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500)
                 := 'psseguro=' || psseguro || ' pfefecto=' || TO_CHAR(pfefecto, 'DD/MM/YYYY');
      vobject        VARCHAR2(200) := 'pac_iax_ws_supl.f_reduccion_total';
      vfefecto       DATE;
      vmodfefe       NUMBER;
      vcmotmov       NUMBER;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      pac_iax_suplementos.limpiartemporales;
      vcmotmov := 266;
      vnumerr := pac_iax_suplementos.f_inicializar_suplemento(psseguro, vcmotmov, vfefecto,
                                                              vmodfefe, NULL, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 2;

      IF vmodfefe > 0 THEN
         vfefecto := pfefecto;
      END IF;

      vnumerr := pac_iax_suplementos.f_editarsuplemento(psseguro, TRUNC(vfefecto), vcmotmov,
                                                        vestsseguro,   --BUG9727-28042009-XVM
                                                        mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      vnumerr := pac_md_supl_dirigidos.f_reduccion_total(vestsseguro, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      vnumerr := pac_iax_produccion.f_tarificar(1, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      vnumerr := pac_iax_suplementos.f_emitirpropuesta(mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 6;
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
   END f_reduccion_total;

   -- BUG 12278 -  09/2010 - JRH  - 0012278: Proceso de PB para el producto PEA.

   /*************************************************************************
      f_suplemento_garant
      Realiza un suplemento asociado a garnatía (PB, Aport ext.,..)
      param in psseguro   : Número de seguro
      param in pnriesgo   : Riesgo
      param in pfecha   : Fecha del suplemento
      param in pimporte   : Importe
      param in pctipban   : Tipo banc.
      param in pcbancar   : Cuenta
      param in pcgarant   : Garantía asociada al suplemento
      param out           : pnmovimi
                            mensajes de error
      return              : 0 todo correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_suplemento_garant(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pimporte IN NUMBER,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR2,
      pcgarant IN NUMBER,
      pnmovimi OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vestsseguro    NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500)
         := 'psseguro=' || psseguro || ' pfecha=' || TO_CHAR(pfecha, 'DD/MM/YYYY')
            || 'pnriesgo=' || pnriesgo || ' pimporte=' || pimporte || 'pctipban=' || pctipban
            || ' pcbancar=' || pcbancar || 'pcgarant=' || pcgarant;
      vobject        VARCHAR2(200) := 'pac_iax_ws_supl.f_suplemento_garant';
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pac_iax_produccion.poliza IS NULL
         OR pac_iax_produccion.poliza.det_poliza IS NULL THEN
         pac_iax_produccion.poliza := ob_iax_poliza();   --JRH Para que no falle el preparar tarif del PAC_MD_PRODUCCION
         pac_iax_produccion.poliza.det_poliza := ob_iax_detpoliza();
      END IF;

      pac_iax_suplementos.limpiartemporales;
      vnumerr := pac_iax_sup_finan.f_aportacion_extraordinaria(psseguro, pnriesgo, pfecha,
                                                               pimporte, pctipban, pcbancar,
                                                               pcgarant, pnmovimi, mensajes);
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
   END f_suplemento_garant;
-- Fi BUG 12278 -  09/2010 - JRH  - 0012278: Proceso de PB para el producto PEA.
END pac_iax_ws_supl;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_WS_SUPL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_WS_SUPL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_WS_SUPL" TO "PROGRAMADORESCSI";
