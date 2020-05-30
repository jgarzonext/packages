--------------------------------------------------------
--  DDL for Package PAC_SIN_RESCATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SIN_RESCATES" AUTHID CURRENT_USER AS
   /******************************************************************************
      NOMBRE:       PAC_SIN_RESCATES
      PROPÓSITO:
      REVISIONES:

      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
       1.0       -            -               1. Creación de package
       10.0      20/05/2010   RSC             10.0013829: APRB78 - Parametrizacion y adapatacion de rescastes
       12.0      10/06/2010   ASN             12.0014834: CRE800 - Provisiones: Provisión matemática de las pólizas con rescates pendientes
       13.0      01/07/2011   APD             13.0018913: CRE998 - Afegir motiu de Rescats
       14.0      22/11/2011   RSC             14.0020241: LCOL_T004-Parametrización de Rescates (retiros)
       15.0      14/05/2013   ECP             15. 0026676: LCOL_T001- QT 7040: Error cierre de provisiones por c?digo de transacci?n en movimiento de anulaciones errado. Nota 144248
   ******************************************************************************/

   -- RSC 12/12/2007
   FUNCTION f_tratar_sinies_fallec(psseguro IN seguros.sseguro%TYPE, pfrescat IN DATE)
      RETURN NUMBER;

   FUNCTION f_gest_siniestro(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN riesgos.nriesgo%TYPE,
      pffecmov IN DATE,
      pctipmov IN NUMBER,
      pcidioma IN idiomas.cidioma%TYPE,
      pimporte IN sin_tramita_reserva.ireserva%TYPE,
      pipenali IN sin_tramita_reserva.ipenali%TYPE,
      picaprm IN sin_tramita_reserva.icaprie%TYPE,
      picapret IN NUMBER,
      picapred IN NUMBER,
      pnivel IN NUMBER,
      pnsinies OUT sin_siniestro.nsinies%TYPE,
      pimprcm IN NUMBER DEFAULT NULL,   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      ppctreten IN NUMBER DEFAULT NULL,   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      pcmotresc IN NUMBER DEFAULT NULL,   -- Bug 18913 - APD - 01/07/2011
      pcmotsin IN sin_siniestro.cmotsin%TYPE DEFAULT NULL,   -- BUG 20241 - RSC - 22/11/2011
      pctipdes IN sin_tramita_destinatario.ctipdes%TYPE DEFAULT NULL,
      -- Ini Bug 26676 -- ECP -- 14/05/2013
      pdiafinv NUMBER DEFAULT 0,
      pskipfanulac NUMBER DEFAULT 0
                                   -- Fin Bug 26676 -- ECP -- 14/05/2013
   )
      -- BUG 20241 - RSC - 22/11/2011
   RETURN NUMBER;

   FUNCTION f_vivo_o_muerto(
      psseguro IN seguros.sseguro%TYPE,
      pcestado IN NUMBER,
      pfecha IN DATE)
      RETURN NUMBER;

   FUNCTION f_simulacion_rescate(
      psseguro IN seguros.sseguro%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pccausin IN sin_codcausa.ccausin%TYPE,
      pimport IN NUMBER,
      pfecha IN DATE,
      pctipcal IN NUMBER,
      res OUT pac_sin_formula.t_val,
      pimppenali IN NUMBER DEFAULT NULL,
      pimprcm IN NUMBER DEFAULT NULL,   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      ppctreten IN NUMBER DEFAULT NULL)   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      RETURN NUMBER;

   FUNCTION f_sol_rescate(
      psseguro IN seguros.sseguro%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pcmoneda IN eco_codmonedas.cmoneda%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      pccausin IN sin_codcausa.ccausin%TYPE,
      pimport IN NUMBER,
      pfecha IN DATE,
      pipenali IN sin_tramita_reserva.ipenali%TYPE,
      pireduc IN NUMBER,
      pireten IN NUMBER,
      pirendi IN NUMBER,
      pnivel IN NUMBER,
      pimprcm IN NUMBER DEFAULT NULL,   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      ppctreten IN NUMBER DEFAULT NULL,   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      pcmotresc IN NUMBER DEFAULT NULL)   -- Bug 18913 - APD - 01/07/2011
      RETURN NUMBER;

   FUNCTION f_es_rescatable(
      psseguro IN seguros.sseguro%TYPE,
      pfmovimi IN DATE,
      pccausin IN sin_codcausa.ccausin%TYPE,
      pirescate IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_sit_rescate(
      psseguro IN seguros.sseguro%TYPE,
      pnmovimi IN movseguro.nmovimi%TYPE)
      RETURN NUMBER;

   FUNCTION f_rescate_total_abierto(psseguro IN seguros.sseguro%TYPE, pabierto IN OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_retencion_simulada(
      psesion IN NUMBER,
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN riesgos.nriesgo%TYPE,
      pcgarant IN codigaran.cgarant%TYPE,
      pfefecto IN seguros.fefecto%TYPE,
      pfrescat IN DATE,
      pctipres IN NUMBER,
      pirescate IN sin_tramita_reserva.icaprie%TYPE,
      pipenali IN sin_tramita_reserva.ipenali%TYPE,
      pmoneda IN eco_codmonedas.cmoneda%TYPE,
      pireten OUT NUMBER,
      pireduc OUT NUMBER,
      pirendi OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_finaliza_rescate(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN riesgos.nriesgo%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pmoneda IN eco_codmonedas.cmoneda%TYPE)
      RETURN NUMBER;

   FUNCTION f_distribuye_ctaseguro(
      psseguro IN seguros.sseguro%TYPE,
      xnnumlin IN OUT NUMBER,
      fcuenta IN DATE,
      pxcmovimi IN NUMBER,
      pivalora IN sin_tramita_reserva.ireserva%TYPE,
      seqgrupo IN NUMBER,
      pnsinies IN sin_siniestro.nsinies%TYPE)
      RETURN NUMBER;

   FUNCTION f_distribuye_ctaseguro_shw(
      psseguro IN seguros.sseguro%TYPE,
      xnnumlin IN OUT NUMBER,
      fcuenta IN DATE,
      pxcmovimi IN NUMBER,
      pivalora IN sin_tramita_reserva.ireserva%TYPE,
      seqgrupo IN NUMBER,
      pnsinies IN sin_siniestro.nsinies%TYPE)
      RETURN NUMBER;

   FUNCTION f_valida_permite_rescate(
      psseguro IN seguros.sseguro%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pfrescate IN DATE,
      pccausin IN sin_codcausa.ccausin%TYPE)
      RETURN NUMBER;

   FUNCTION f_avisos_rescates(
      psseguro IN seguros.sseguro%TYPE,
      pfrescate IN DATE,
      pirescate IN NUMBER,
      cavis OUT NUMBER,
      pdatos OUT NUMBER)
      RETURN NUMBER;

/******************************************************************************
   NOMBRE:       F_BUSCA_PRETEN
   DESCRIPCION:  Retorna un % de I.R.P.F.

   PARAMETROS:
   INPUT: PSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PPERSON(number) --> Clave del asegurado
        PCACTPRO(number) --> Actividad Profesional. 4 = Cliente
        PFECHA(number)  --> Fecha a aplicar la retención
   RETORNA VALUE:
          VALOR(NUMBER)-----> % DE RETENCIÓN
                            NULL --> No existe en la tabla PROFESIONALES
******************************************************************************/
   FUNCTION f_busca_preten(
      psesion IN NUMBER,
      pperson IN per_personas.sperson%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pfecha IN NUMBER,
      pnsinies IN sin_siniestro.nsinies%TYPE DEFAULT NULL,
      pntramit IN sin_tramitacion.ntramit%TYPE DEFAULT NULL)
      RETURN NUMBER;

/******************************************************************************
   NOMBRE:       F_INS_DESTINATARIO
   DESCRIPCION:  Inserta destinatarios de pago

   PARAMETROS:
   INPUT: pnsinies IN sin_tramita_destinatario.nsinies%TYPE,
          pntramit IN sin_tramita_destinatario.ntramit%TYPE,
          psseguro IN sin_siniestro.sseguro%TYPE,
          pnriesgo IN sin_siniestro.nriesgo%TYPE,
          ppagdes IN NUMBER,
          pctipdes IN sin_tramita_destinatario.ctipdes%TYPE,
          pcpagdes IN sin_tramita_destinatario.cpagdes%TYPE,
          ppasigna IN sin_tramita_destinatario.pasigna%TYPE,
          pcactpro IN sin_tramita_destinatario.cactpro%TYPE,
          pcbancar IN sin_tramita_destinatario.cbancar%TYPE,
          pcbancar2 IN sin_tramita_destinatario.cbancar%TYPE,
          pctipban IN sin_tramita_destinatario.ctipban%TYPE DEFAULT NULL,
          pctipban2 IN sin_tramita_destinatario.ctipban%TYPE DEFAULT NULL
   RETORNA VALUE:
          VALOR(NUMBER)-----> 0
                            1 --> Error
******************************************************************************/
   FUNCTION f_ins_destinatario(
      pnsinies IN sin_tramita_destinatario.nsinies%TYPE,
      pntramit IN sin_tramita_destinatario.ntramit%TYPE,
      psseguro IN sin_siniestro.sseguro%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      ppagdes IN NUMBER,
      pctipdes IN sin_tramita_destinatario.ctipdes%TYPE,
      pcpagdes IN sin_tramita_destinatario.cpagdes%TYPE,
      ppasigna IN sin_tramita_destinatario.pasigna%TYPE,
      pcactpro IN sin_tramita_destinatario.cactpro%TYPE,
      pcbancar IN sin_tramita_destinatario.cbancar%TYPE,
      pcbancar2 IN sin_tramita_destinatario.cbancar%TYPE,
      pctipban IN sin_tramita_destinatario.ctipban%TYPE DEFAULT NULL,
      pctipban2 IN sin_tramita_destinatario.ctipban%TYPE DEFAULT NULL)
      RETURN NUMBER;

-- Bug14834:10/06/2010:ASN:ini
/******************************************************************************
   NOMBRE:       F_PROVMAT
   DESCRIPCION:  Calcula la provision matematica teniendo en cuenta los rescates

   PARAMETROS:
   INPUT: psseguro IN sin_siniestro.sseguro%TYPE,
          pfecha   IN NUMBER
   RETORNA VALUE:
          VALOR(NUMBER)-----> Provision Matematica
******************************************************************************/
   FUNCTION f_provmat(psesion IN NUMBER, psseguro IN seguros.sseguro%TYPE, pfecha IN NUMBER)
      RETURN NUMBER;

-- Bug14834:10/06/2010:ASN:fin
   FUNCTION f_alta_siniestro_final(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pffecmov IN DATE,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      pimporte IN NUMBER,
      pipenali IN NUMBER,
      pctipdes IN NUMBER DEFAULT 1,
      pnivel IN NUMBER DEFAULT 1,
      pfinal IN NUMBER DEFAULT 1,
      pcidioma IN NUMBER DEFAULT pac_md_common.f_get_cxtidioma,
      -- Ini Bug 26676 -- ECP -- 14/05/2013
      pdiafinv NUMBER DEFAULT 0,
      pskipfanulac NUMBER DEFAULT 0
                                   -- Fin Bug 26676 -- ECP -- 14/05/2013
   )
      RETURN NUMBER;

   FUNCTION f_ajustar_unidades(
      psseguro IN NUMBER,
      pdetmovi IN NUMBER,
      pnnumlin IN NUMBER,
      pcesta IN NUMBER,
      pimport IN NUMBER,
      pvalliq IN NUMBER,
      pmultipl IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_ajustar_unidades_shw(
      psseguro IN NUMBER,
      pdetmovi IN NUMBER,
      pnnumlin IN NUMBER,
      pcesta IN NUMBER,
      pimport IN NUMBER,
      pvalliq IN NUMBER,
      pmultipl IN NUMBER)
      RETURN NUMBER;

   /************************************************************
     Guarda los datos utilizados para el calculo de la reserva
      param in  pnsinies
      param in  pntramit
      param in  pffecmov
      param in  pretenc
      param in  pipenal
      param in  pctipcal
      return number.
   ************************************************************/
   FUNCTION f_ins_prereserva(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pffecmov IN DATE,
      pretenc IN NUMBER,
      pipenal IN NUMBER,
      pctipcal IN NUMBER)
      RETURN NUMBER;

   /************************************************************
     Guarda los datos utilizados para el calculo de la preserva
      param in  pnsinies
      param in  pntramit
      param in  pffecmov
      param in  pretenc
      param in  pipenal
      param in  pctipcal
      return number.
   ************************************************************/
   FUNCTION f_ins_prereserva_fnd(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pffecmov IN DATE,
      pcesta IN NUMBER,
      pireserva IN NUMBER,
      pnunidad IN NUMBER,
      piunidad IN NUMBER,
      pretenc IN NUMBER,
      pipenal IN NUMBER,
      pcgarant IN NUMBER,
      pireservashw IN NUMBER,
      piunidadshw IN NUMBER,
      pnunidadshw IN NUMBER)
      RETURN NUMBER;

   /************************************************************
     Funcion que realiza la compensacion entre los pagos de ahorro y rescate de la poliza anulada
     y el recibo de la nueva poliza saldada / prorrogada.
      param in  psseguro
      param in  pfanulac
      return number.
   ************************************************************/
   FUNCTION f_compensa_poliza_saldada(psseguro IN seguros.sseguro%TYPE, pfanulac IN DATE)
      RETURN NUMBER;

   FUNCTION f_anula_pago_inicial(psidepag IN sin_tramita_pago.sidepag%TYPE, pfanulac IN DATE)
      RETURN NUMBER;

   FUNCTION f_crear_pago_compensatorio_cia(
      psidepag IN sin_tramita_pago.sidepag%TYPE,
      psseguro IN seguros.sseguro%TYPE,
      pfanulac IN DATE,
      psperson IN per_personas.sperson%TYPE,
      psidepag_nou OUT sin_tramita_pago.sidepag%TYPE,
      pnrecibo IN recibos.nrecibo%TYPE,
      pcestcomp IN sin_recibos_compensados.cestcomp%TYPE)
      RETURN NUMBER;

   FUNCTION f_crea_recibo_parcial(
      pmodali IN NUMBER,
      pnrecibo IN NUMBER,
      pnreciboclon OUT NUMBER,
      psmovagr IN OUT NUMBER,
      pirecibo IN NUMBER,
      pfefecto IN DATE DEFAULT NULL,
      porigen IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   PROCEDURE p_calc_rescatev;

   PROCEDURE p_pag_rescatev;
END pac_sin_rescates;

/

  GRANT EXECUTE ON "AXIS"."PAC_SIN_RESCATES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_RESCATES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_RESCATES" TO "PROGRAMADORESCSI";
