--------------------------------------------------------
--  DDL for Package Body PAC_IAX_SIN_FORMULA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_SIN_FORMULA" AS
/******************************************************************************
   NOMBRE:       PAC_MD_SIN_FORMULA
   PROPÓSITO:  Funciones para el cálculo de los siniestros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0        30/04/2009  XVM               1. Creación del package.
   2.0        28/05/2010  AMC               2. 0014752: AGA014 - Cambios en alta rápida de siniestros (axissin032). Se crea la función f_cal_fechas_sini.
   3.0        03/07/2012  ASN               3. 0022674: MDP_S001-SIN - Reserva global (calculo)
******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

   /***********************************************************************
      FUNCTION f_cal_valora
         Funció que carega les preguntes per poder executar la fórmula indicada
         param in pfsinies  : Data del sinistre
         param in psseguro  : Codi seguro
         param in pnriesgo  : Número risc
         param in pnsinies  : Número de sinistre
         param in pntramit  : Número tramitació
         param in pctramit  : Codi tramitació
         param in psproduc  : Codi Producte
         param in pcactivi  : Codi Activitat
         param in pcgarant  : Codi Garantía
         param in pccausin  : Codi Causa sinistre
         param in pcmotsin  : Codi Subcausa
         param in pfnotifi  : Data notificació
         param in pfecval   :
         param in pfperini  : Data inici pagament
         param in pfperfin  : Data fi pagament
         param out pivalora : Valorització
         param out pipenali : Penalització
         param out picapris : Capital de risc
         param out mensajes : Salida mensajes
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
     ***********************************************************************/
   FUNCTION f_cal_valora(
      pfsinies IN sin_siniestro.fsinies%TYPE,
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      pctramit IN sin_tramitacion.ctramit%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pcactivi IN activisegu.cactivi%TYPE,
      pcgarant IN codigaran.cgarant%TYPE,
      pccausin IN sin_siniestro.ccausin%TYPE,
      pcmotsin IN sin_siniestro.cmotsin%TYPE,
      pfnotifi IN sin_siniestro.fnotifi%TYPE,
      pfecval IN sin_tramita_reserva.fmovres%TYPE,
      pfperini IN sin_tramita_reserva.fresini%TYPE,
      pfperfin IN sin_tramita_reserva.fresfin%TYPE,
      pivalora OUT sin_tramita_reserva.ireserva%TYPE,
      pipenali OUT sin_tramita_reserva.ipenali%TYPE,
      picapris OUT sin_tramita_reserva.icaprie%TYPE,
      pifranq OUT sin_tramita_reserva.ifranq%TYPE,   --Bug 27059:NSS:05/06/2013
      pndias IN sin_tramita_reserva.ndias%TYPE DEFAULT NULL,   --Bug 27487/159742:NSS;28/11/2013
      piperit IN sin_siniestro.iperit%TYPE DEFAULT NULL,   --Bug 30525/170923:NSS;27/03/2014
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_SIN_FORMULA.f_cal_valora';
      vparam         VARCHAR2(2000)
         := 'parámetros - pfsinies: ' || pfsinies || 'psseguro: ' || psseguro || ' pnriesgo: '
            || pnriesgo || ' pnsinies: ' || pnsinies || ' pntramit: ' || pntramit
            || ' pctramit: ' || pctramit || ' psproduc: ' || psproduc || ' pcactivi: '
            || pcactivi || ' pcgarant: ' || pcgarant || ' pccausin: ' || pccausin
            || ' pcmotsin: ' || pcmotsin || ' pfnotifi: ' || pfnotifi || ' pfecval: '
            || pfecval || ' pfperini: ' || pfperini || ' pfperfin: ' || pfperfin;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vnsinies       NUMBER(8);
      vtmotsin       VARCHAR2(1000);
      vtcausin       VARCHAR2(1000);
      vtevento       VARCHAR2(1000);
      xactivi        NUMBER(4);
      xfecval        DATE;
   BEGIN
      IF pcactivi IS NULL THEN
         xactivi := 0;
      ELSE
         xactivi := pcactivi;
      END IF;

      IF pfecval IS NULL THEN
         xfecval := f_sysdate;
      ELSE
         xfecval := pfecval;
      END IF;

      vnumerr := pac_md_sin_formula.f_cal_valora(pfsinies, psseguro, pnriesgo, pnsinies,
                                                 pntramit, pctramit, psproduc, xactivi,
                                                 pcgarant, pccausin, pcmotsin, pfnotifi,
                                                 xfecval, pfperini, pfperfin, pivalora,
                                                 pipenali, picapris, pifranq,   --Bug 27059:NSS:05/06/201
                                                 pndias,   --Bug 27487/159742:NSS;28/11/2013
                                                 piperit,   --Bug 30525/170923:NSS;27/03/2014
                                                 mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_cal_valora;

   /*************************************************************************
      FUNCTION f_cal_fechas_sini
         Funció que carrega les dates de inici i fi del sinistre
         param in pfsinies  : Data del sinistre
         param in psseguro  : Codi seguro
         param in pnsinies  : Número de sinistre
         param in psproduc  : Codi Producte
         param in pcactivi  : Codi Activitat
         param in pcgarant  : Codi Garantía
         param in pccausin  : Codi Causa sinistre
         param in pcmotsin  : Codi Subcausa
         param in pfnotifi  : Data notificació
         param in pctramit  : Codi tramitació
         param in pntramit  : Número tramitació
         param in pnriesgo  : Número risc
         param in pfecval   :
         param out pfperini  : Data inici pagament
         param out pfperfin  : Data fi pagament
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error

         Bug 14752 - 28/05/2010 - AMC
   *************************************************************************/
   FUNCTION f_cal_fechas_sini(
      pfsinies IN sin_siniestro.fsinies%TYPE,
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      pctramit IN sin_tramitacion.ctramit%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pcactivi IN activisegu.cactivi%TYPE DEFAULT 0,
      pcgarant IN codigaran.cgarant%TYPE,
      pccausin IN sin_siniestro.ccausin%TYPE,
      pcmotsin IN sin_siniestro.cmotsin%TYPE,
      pfnotifi IN sin_siniestro.fnotifi%TYPE,
      pfecval IN sin_tramita_reserva.fmovres%TYPE DEFAULT f_sysdate,
      pfperini OUT sin_tramita_reserva.fresini%TYPE,
      pfperfin OUT sin_tramita_reserva.fresfin%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_SIN_FORMULA.f_cal_fechas_sini';
      vparam         VARCHAR2(500)
         := 'parámetros - pfsinies: ' || pfsinies || 'psseguro: ' || psseguro || ' pnriesgo: '
            || pnriesgo || ' pnsinies: ' || pnsinies || ' pntramit: ' || pntramit
            || ' pctramit: ' || pntramit || ' psproduc: ' || psproduc || ' pcactivi: '
            || pcactivi || ' pcgarant: ' || pcgarant || ' pccausin: ' || pccausin
            || ' pcmotsin: ' || pcmotsin || ' pfnotifi: ' || pfnotifi || ' pfecval: '
            || pfecval;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vnmovpag       NUMBER(8);
      vsquery        VARCHAR2(5000);
   BEGIN
      vnumerr := pac_md_sin_formula.f_cal_fechas_sini(pfsinies, psseguro, pnriesgo, pnsinies,
                                                      pntramit, pctramit, psproduc, pcactivi,
                                                      pcgarant, pccausin, pcmotsin, pfnotifi,
                                                      pfecval, pfperini, pfperfin, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_cal_fechas_sini;

   /*************************************************************************
      FUNCTION f_cal_penali
        Funció que devuelve el importe de penalización
        param in pcgarant
        param in pctramit
        param in pnsinies
        param in pireserva
        param in pfini
        param in pffin
        param out pivalora : Valorització
        param out pipenali : Penalització
        param out picapris : Capital de risc
        return             : 0 -> Tot correcte
                             1 -> S'ha produit un error

        Bug 20655/101537 - 22/12/2011 - AMC
   *************************************************************************/
   FUNCTION f_cal_penali(
      pcgarant IN codigaran.cgarant%TYPE,
      pctramit IN sin_tramitacion.ctramit%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pireserva IN sin_tramita_reserva.ireserva%TYPE,
      pfini IN sin_tramita_reserva.fresini%TYPE,
      pffin IN sin_tramita_reserva.fresfin%TYPE,
      pipenali OUT sin_tramita_reserva.ipenali%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(500) := 'PAC_MD_SIN_FORMULA.f_cal_penali';
      vparam         VARCHAR2(500)
         := 'parámetros - pcgarant: ' || pcgarant || 'pctramit: ' || pctramit || ' pnsinies: '
            || pnsinies || ' pireserva: ' || pireserva || ' pfini: ' || pfini || ' pffin: '
            || pffin;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      vnumerr := pac_md_sin_formula.f_cal_penali(pcgarant, pctramit, pnsinies, pireserva,
                                                 pfini, pffin, pipenali, mensajes);

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
   END f_cal_penali;

   /*************************************************************************
      FUNCTION f_cal_coste
        Funció que devuelve el importe del coste medio
        param in pfsinies
        param in pccausin
        param in pcmotsin
        param in psproduc
        param out pireserva
        return             : 0 -> Tot correcte
                             1 -> S'ha produit un error

        Bug 22674:ASN:03/07/2012
   *************************************************************************/
   FUNCTION f_cal_coste(
      pfsinies IN sin_siniestro.fsinies%TYPE,
      pccausin IN sin_siniestro.ccausin%TYPE,
      pcmotsin IN sin_siniestro.cmotsin%TYPE,
      psproduc IN productos.sproduc%TYPE,
      picoste OUT sin_tramita_reserva.ireserva%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vobjectname    VARCHAR2(500) := 'PAC_MD_SIN_FORMULA.f_cal_penali';
      vparam         VARCHAR2(500)
         := 'parámetros - pfsinies: ' || pfsinies || 'pccausin: ' || pccausin || ' pcmotsin: '
            || pcmotsin || ' psproduc: ' || psproduc;
      vpasexec       NUMBER(5) := 1;
   BEGIN
      vnumerr := pac_md_sin_formula.f_cal_coste(pfsinies, pccausin, pcmotsin, psproduc,
                                                picoste, mensajes);

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
   END f_cal_coste;
END pac_iax_sin_formula;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_FORMULA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_FORMULA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_FORMULA" TO "PROGRAMADORESCSI";
