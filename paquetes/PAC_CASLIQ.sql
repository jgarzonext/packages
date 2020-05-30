--------------------------------------------------------
--  DDL for Package PAC_CASLIQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CASLIQ" AUTHID CURRENT_USER AS
   -- Variables de pantalla
   cont           NUMBER := 0;
   p_cempres      NUMBER;
   p_ccompani     NUMBER;
   p_datamov      DATE;
   p_sseguro      NUMBER := 0;
   p_cramo        NUMBER := 0;
   p_cmodali      NUMBER := 0;
   p_ctipseg      NUMBER := 0;
   p_ccolect      NUMBER := 0;
   p_cproducto    VARCHAR2(8);
   p_efe          DATE := NULL;
   num_certificado VARCHAR2(10) := NULL;
   tip_reb        VARCHAR2(1) := NULL;
   data_cobr_rec  DATE := NULL;
   data_cobr_sinis DATE := NULL;
   itotal_rec     NUMBER := 0;
   itotal_sinis   NUMBER := 0;
   p_carrec_cia   VARCHAR2(1) := NULL;
   p_nsincoa      VARCHAR2(16) := NULL;
   tot_reb_liq    NUMBER := 0;
   tot_reb_cob_cent NUMBER := 0;
   comis_cesgrup  NUMBER := 0;
   pag_compte     NUMBER := 0;
   pag_cia        NUMBER := 0;
   indemnit       NUMBER := 0;
   balance        NUMBER := 0;
   t_balance      VARCHAR2(20) := NULL;
   sortir         BOOLEAN;
   situacion      NUMBER;
   anulada        VARCHAR2(2);
   refer          VARCHAR2(15);
   refint         VARCHAR2(50);
   forpag         VARCHAR2(30);
   codforpag      NUMBER;

   CURSOR rebut_cv IS
      SELECT 'R' tip_det, a.sseguro seguro,
             DECODE(a.ctiprec, 0, 'P', 3, 'C', 9, 'E', 1, 'S') tipo, a.nrecibo recibo,
             a.fefecto efecto, a.fvencim vencimiento, a.iprinet * 100 neta,
             SIGN(a.iprinet) * b.iips * 100 ips, a.itotalr bruta,   -- no multipliquem encara
                                                                 a.icomis * 100 comision,
             0 siniestro, 0 pago, a.fcierre liquidacion, a.cgescob cobro, 0 concepto,
             0 debe_haber, a.fmovini fecha_movimiento
        FROM cuadre_cc a, vdetrecibos b
       WHERE a.fcierre = LAST_DAY(p_datamov)
         AND a.cempres = p_cempres
         AND a.ccompani = p_ccompani
         AND a.nrecibo = b.nrecibo
      UNION ALL
      SELECT 'S' tip_det, a.sseguro seguro, ' ' tipo, 0 recibo, a.fefepag efecto,
             a.fefepag vencimiento, 0 neta, 0 ips, a.isinret bruta, 0 comision,
             a.nsinies siniestro, a.sidepag pago, a.fcierre liquidacion, 0 cobro, 0 concepto,
             0 debe_haber, a.fefepag fecha_movimiento
        FROM siniestros_cc a
       WHERE a.fcierre = LAST_DAY(p_datamov)
         AND a.cempres = p_cempres
         AND a.ccompani = p_ccompani
      UNION ALL
      SELECT ' ' tip_det, 0 seguro, ' ' tipo, 0 recibo, a.ffecmov efecto,
             a.ffecmov vencimiento, 0 neta, 0 ips,
             a.iimport * DECODE(a.cdebhab, 1, 1, 2, -1) bruta, 0 comision, 0 siniestro, 0 pago,
             LAST_DAY(p_datamov) liquidacion, 0 cobro, a.cconcta concepto,
             a.cdebhab debe_haber, a.ffecmov fecha_movimiento
        FROM ctactescia a
       WHERE ffecmov BETWEEN p_datamov AND LAST_DAY(p_datamov)
         AND a.cempres = p_cempres
         AND a.ccompani = p_ccompani
         AND a.cmanual = 1;

   TYPE regliqtyp IS RECORD(
      tip_det        VARCHAR2(1),
      sseguro        seguros.sseguro%TYPE,
      tip_reb        VARCHAR2(1),
      nrecibo        recibos.nrecibo%TYPE,
      fefecto        seguros.fefecto%TYPE,
      fvencim        seguros.fvencim%TYPE,
      iprinet        liquidalin.iprinet%TYPE,   --NUMBER(15,2), 25803
      iips           liquidalin.iprinet%TYPE,   --NUMBER(15,2),
      itotalr        liquidalin.itotalr%TYPE,   --NUMBER(15,2),
      icomcia        liquidalin.icomisi%TYPE,   --NUMBER(15,2),
      nsinies        liquidalin.itotalr%TYPE,   --NUMBER(15,2),
      sidepag        ctactescia.sidepag%TYPE,   --NUMBER(15,2),
      fliquid        liquidacab.fliquid%TYPE,   --DATE,
      cgescob        liquidalin.cagente%TYPE,   --NUMBER(1),
      cconcta        ctactescia.cconcta%TYPE,   --NUMBER(2),
      cdebhab        ctactescia.cdebhab%TYPE,   --NUMBER(1), 255803
      fecha_movimiento ctactescia.ffecmov%TYPE
   );   --DATE);

   regliq         regliqtyp;

   PROCEDURE inicialitzar(vempres IN NUMBER, vcia IN NUMBER, vsproces IN DATE);

   PROCEDURE lee;

   FUNCTION fin
      RETURN BOOLEAN;
END pac_casliq;

/

  GRANT EXECUTE ON "AXIS"."PAC_CASLIQ" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CASLIQ" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CASLIQ" TO "PROGRAMADORESCSI";
