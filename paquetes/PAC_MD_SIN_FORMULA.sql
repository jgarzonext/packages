--------------------------------------------------------
--  DDL for Package PAC_MD_SIN_FORMULA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_SIN_FORMULA" AS
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

   /*************************************************************************
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
   *************************************************************************/
   FUNCTION f_cal_valora(
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
      pfperini IN sin_tramita_reserva.fresini%TYPE,
      pfperfin IN sin_tramita_reserva.fresfin%TYPE,
      pivalora OUT sin_tramita_reserva.ireserva%TYPE,
      pipenali OUT sin_tramita_reserva.ipenali%TYPE,
      picapris OUT sin_tramita_reserva.icaprie%TYPE,
      pifranq OUT sin_tramita_reserva.ifranq%TYPE,   --Bug 27059:NSS:05/06/2013
      pndias IN sin_tramita_reserva.ndias%TYPE DEFAULT NULL,   --Bug 27487/159742:NSS;28/11/2013
      piperit IN sin_siniestro.iperit%TYPE DEFAULT NULL,   --Bug 30525/170923:NSS;27/03/2014
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_sin_formula;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_FORMULA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_FORMULA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_FORMULA" TO "PROGRAMADORESCSI";
