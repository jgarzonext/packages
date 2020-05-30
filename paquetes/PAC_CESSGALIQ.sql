--------------------------------------------------------
--  DDL for Package PAC_CESSGALIQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CESSGALIQ" AS
   -- Variables de pantalla
   p_cempres      NUMBER;
   p_ccompani     NUMBER;
   p_datamov      DATE;
   p_sseguro      NUMBER := 0;
   p_cramo        NUMBER := 0;
   p_cmodali      NUMBER := 0;
   p_ctipseg      NUMBER := 0;
   p_ccolect      NUMBER := 0;
   p_efe          DATE := NULL;
   p_tip_reb      VARCHAR2(1) := NULL;
   num_certificado VARCHAR2(10) := NULL;
   tip_reb        VARCHAR2(1) := NULL;
   numpol         VARCHAR2(10) := NULL;
   num_certif     NUMBER := 0;
   nom_asse       VARCHAR2(30) := NULL;
   nif_asse       VARCHAR2(13) := NULL;
   data_cobr      DATE := NULL;
   p_num_registres NUMBER := 0;
   p_tot_pr_neta  NUMBER := 0;
   p_tot_ips      NUMBER := 0;
   p_tot_pr_bruta NUMBER := 0;
   p_tot_comissio NUMBER := 0;
   sortir         BOOLEAN;
   wfecha         DATE;
   situacion      NUMBER;
   anulada        VARCHAR2(2);

   CURSOR rebut_cv IS
      SELECT a.sseguro seguro, DECODE(a.ctiprec, 0, 'P', 3, 'C', 9, 'E', 1, 'S') tipo,
             a.nrecibo recibo, a.fefecto efecto, a.fvencim vencimiento, a.iprinet * 100 neta,
             SIGN(a.iprinet) * b.iips * 100 ips, a.itotalr * 100 bruta,
             a.icomis * 100 comision, 0 siniestro, 0 pago, a.fcierre,
             a.fmovini fecha_movimiento
        FROM cuadre_cc a, vdetrecibos b
       WHERE a.fcierre = LAST_DAY(p_datamov)
         AND a.cempres = p_cempres
         AND a.ccompani = p_ccompani
         AND a.nrecibo = b.nrecibo
      UNION ALL
      SELECT a.sseguro seguro, 'I' tipo, 0 recibo, a.fefepag efecto, a.fefepag vencimiento,
             0 neta, 0 ips, a.isinret * 100 bruta, 0 comision, a.nsinies siniestro,
             a.sidepag pago, a.fcierre, a.fefepag fecha_movimiento
        FROM siniestros_cc a
       WHERE a.fcierre = LAST_DAY(p_datamov)
         AND a.cempres = p_cempres
         AND a.ccompani = p_ccompani;

   TYPE regliqtyp IS RECORD(
      sseguro        cuadre_cc.sseguro%TYPE,   --NUMBER(6,0),
      tipo           VARCHAR2(1),
      nrecibo        cuadre_cc.nrecibo%TYPE,   --NUMBER(9),
      fefecto        cuadre_cc.fefecto%TYPE,   --DATE,
      fvencim        cuadre_cc.fvencim%TYPE,   --DATE,
      iprinet        cuadre_cc.iprinet%TYPE,   --NUMBER(15,2),
      iips           liquidalin.iprinet%TYPE,    --NUMBER(15,2),
      itotalr        cuadre_cc.itotalr%TYPE,   --NUMBER(15,2),
      icomcia        cuadre_cc.icomis%TYPE,   --NUMBER(15,2),
      nsinies        siniestros_cc.nsinies%TYPE,   --NUMBER(15,2),
      sidepag        siniestros_cc.sidepag%TYPE,   --NUMBER(15,2),
      fliquid        liquidacab.fliquid%TYPE,  --DATE,
      fecha_movimiento ctactescia.ffecmov%TYPE
   );   --DATE);

   regliq         regliqtyp;

   PROCEDURE inicialitzar(vempres IN NUMBER, vcia IN NUMBER, vsdatamov IN DATE);

   PROCEDURE fecha;

   PROCEDURE lee;

   FUNCTION fin
      RETURN BOOLEAN;
END pac_cessgaliq;

/

  GRANT EXECUTE ON "AXIS"."PAC_CESSGALIQ" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CESSGALIQ" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CESSGALIQ" TO "PROGRAMADORESCSI";
