--------------------------------------------------------
--  DDL for Package PK_TR234_OUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_TR234_OUT" AS
   CURSOR c_generar(pcinout IN NUMBER, pfestado IN DATE) IS
      SELECT *
        FROM trasplainout t
       WHERE ((pcinout = 1
               AND t.cinout = 1
               AND t.cestado IN(1, 2))   --sin confirmar
              OR(pcinout = 2
                 AND t.cinout = 2
                 AND t.cestado IN(3, 4, 6, 8)))   --aceptado,rechazado o demorado
         AND t.cexterno = 1
         AND(t.festado IS NOT NULL
             AND t.festado <= NVL(pfestado, t.festado)
             OR(t.festado IS NULL))
         AND t.cenvio = 0
         AND((t.ccodpla IS NOT NULL
              AND t.ccodpla IN(SELECT ccodpla
                                 FROM planpensiones p
                                WHERE p.ccodpla = t.ccodpla
                                  AND p.clistblanc = 1))
             OR(t.ccompani IS NOT NULL
                AND t.ccompani IN(SELECT ccodaseg
                                    FROM aseguradoras p
                                   WHERE p.ccodaseg = t.ccompani
                                     AND p.clistblanc = 1)));

   --R_TMP234 C_TMP234%ROWTYPE;
   r_generar      c_generar%ROWTYPE;
   -- Ini BUG 22789 - MDS - 16/10/2012
   --vempresa       NUMBER(1) := 4;
   vempresa       NUMBER(2);
   -- Fin BUG 22789 - MDS - 16/10/2012
   -- Bug 28462 - 08/10/2013 - JMG - Modificacion campo sproces a NUMBER
   vsproces       NUMBER;
   vbanccedent    VARCHAR2(20);
   noperacions    NUMBER(6);
   nregistres     NUMBER(6);
   ncerror        NUMBER(8) := 0;
   stransfers     NUMBER(15, 2);
   data_fitxer    DATE;
   ordre_fitxer   NUMBER(2) := 1;
   ---
   --Bug 25736-XVM-29/07/13
   --nif_entitat_gestora VARCHAR2(10) := 'A17002874';
   --entitat_dipositaria VARCHAR2(4) := '2041';
   v_nppa1        NUMBER := 0;
   v_nppa2        NUMBER := 0;
   nif_entitat_gestora VARCHAR2(10);
   entitat_dipositaria VARCHAR2(4);
---
   sortir         BOOLEAN := TRUE;
   clau_origen    NUMBER(1);
   enitat_dipos   NUMBER(4);
   nif_gestora    NUMBER(9);
   nordre         NUMBER;
   num_operacio   NUMBER(5);
   num_registres  NUMBER(6);
   transf_total   NUMBER(10, 2);
   vnerror        NUMBER(6) := 0;
   i              NUMBER;
   ---
   xpolissa_ini   VARCHAR2(15);
   xnompla        VARCHAR2(60);
   ---
   xpla           NUMBER(8);
   xppa           NUMBER(8);
   xcbancar       VARCHAR2(20);
   xcestado       NUMBER;
   xiimporte      NUMBER;
   xiimptemp      NUMBER;
   xiimpanu       NUMBER;
   xfantigi       DATE;
   xnparpla       NUMBER;
   xnporcen       NUMBER(6, 3);
   xtiptras       NUMBER(2);
   xsprestaplan   NUMBER(8);
   xnsinies       NUMBER(8) := 0;
   xsidepag       NUMBER(8) := 0;
   ximovimi       NUMBER;
   xnparret_tr    NUMBER;
   xsperson_ass   NUMBER(8) := 0;
   xsperson       NUMBER(8) := 0;
   xctipjub       NUMBER;
   xnnivel        NUMBER;
------   xCESTADO NUMBER;
   xaportportsn   NUMBER;
   xporconpost    NUMBER;
   xporecopost    NUMBER;
   xporcenirpf    NUMBER;
   xnparti        NUMBER;
   xnparret       NUMBER;
   xnpartrasret   NUMBER;
   xvnparpla      NUMBER(25, 2);
   xrefc234       VARCHAR2(13);
   tdiv           NUMBER;
   xfvalmov       DATE;
   bapabe         BOOLEAN := TRUE;
   batransfer     BOOLEAN := FALSE;
   baiplapen      BOOLEAN := FALSE;
   baiprest       BOOLEAN := FALSE;
   bteembarg      BOOLEAN := FALSE;
   bminusv        BOOLEAN := FALSE;
   bidrec         BOOLEAN := FALSE;
   ---
   errorcontrolat EXCEPTION;
   nosenvia       EXCEPTION;
   noespotenviar  EXCEPTION;

   SUBTYPE registro IS tdc234_out_det%ROWTYPE;

   TYPE transferencia IS RECORD(
      clau_inici     NUMBER(1),
      data_emi       VARCHAR2(6),
      data_emi_dev   VARCHAR2(6),
      motiu_devo     NUMBER(2),
      entitat_ord    VARCHAR2(4),
      ofic_ord       VARCHAR2(4),
      dctrl_ord      VARCHAR2(2),
      compte_ord     VARCHAR2(10),
      import         NUMBER(10, 2),
      importeco      NUMBER(10, 2),
      ent_benef      VARCHAR2(4),
      ofic_benef     VARCHAR2(4)
   );

   transfer       transferencia;

   TYPE traspas_reg IS RECORD(
      clau_oper      NUMBER(2),
      motiu_refusa   NUMBER(2),
      sentit         NUMBER(2),   --1 entrada; 2 sortida
      tipus          NUMBER(2),   --1 total; 2 parcial
      tipus_imp      NUMBER(2),   --1 import; 2 %; 3 participacions
      partobene      NUMBER(1),   --1 partícep; 2 beneficiari
      import         NUMBER(10, 2),
      PERCENT        NUMBER(6, 3),
      partic         NUMBER(14, 6),
      referoper      VARCHAR2(13),
-- BUG 17245 - 12/01/2011 - JMP
      numidsol       VARCHAR2(14),
      tnomsol        VARCHAR2(100),
      nifgori        VARCHAR2(14),
      cdgsgori       VARCHAR2(10),
      cdgsppori      VARCHAR2(10),
      niffpori       VARCHAR2(14),
      cdgsfpori      VARCHAR2(10),
      nrbe           VARCHAR2(4)

-- FIN BUG 17245 - 12/01/2011 - JMP
   );

   traspas        traspas_reg;

   TYPE gestora_reg IS RECORD(
      sperson        NUMBER(8),
      nif            VARCHAR2(9),
      dgsfp          VARCHAR2(10)
   );

   TYPE fons_reg IS RECORD(
      sperson        NUMBER(8),
      nif            VARCHAR2(9),
      dgsfp          VARCHAR2(10),
      nrbe           VARCHAR2(4),
      ccc            VARCHAR2(20)
   );

   TYPE pla_reg IS RECORD(
      dgsfp          VARCHAR2(10),
      indprecap      NUMBER(1),
      indpreren      NUMBER(1),
      indpremix      NUMBER(1),
      polppa         NUMBER
   );

   TYPE gestfonspla IS RECORD(
      pla            pla_reg,
      gestora        gestora_reg,
      fons           fons_reg
   );

   origen         gestfonspla;
   desti          gestfonspla;

   TYPE partoben_reg IS RECORD(
      tipusdret      NUMBER(1),   ---1.Drets consolidats; 2.Drets econòmics; 3.Drets consol. i econ.
      formacobr      NUMBER(2),
      assnif         VARCHAR2(15),
      assnoms        VARCHAR2(36),
      aporpostsn     VARCHAR2(1),
      porconpost     NUMBER(5),
      porecopost     NUMBER(5)
   );

   partoben       partoben_reg;

   TYPE dades_embarg IS RECORD(
      nembarg        NUMBER(1),
      autoritat      VARCHAR2(35),
      data_com       DATE,
      id_demanda     VARCHAR2(27)
   );

   TYPE embarg_tau IS TABLE OF dades_embarg
      INDEX BY BINARY_INTEGER;

   embarg         embarg_tau;
   eembarg        dades_embarg;

   TYPE pla_transf_reg IS RECORD(
      ind_embarg     NUMBER(1),   --embarg
      n_aport_minus  NUMBER(2),
      data_pr_aport  VARCHAR2(6),
      ind_minus      NUMBER(1),   ---minus
      data_minus     DATE,
      ind_dc_ac      NUMBER(1),
      ind_part_scobr NUMBER(1),
      ind_apor_am    NUMBER(1),   ---minus
      dc_apor_am     NUMBER(10, 2),   ---minus
      ind_aport_any  NUMBER(1),
      ind_contr_pr_any NUMBER(1),
      ind_compl_tras NUMBER(1),
      aport_any      NUMBER(10, 2),
      contr_pr_any   NUMBER(10, 2),
      dc_altres_con  NUMBER(10, 2),
      dr_econ_traspassat NUMBER(10, 2),
      ncontin_prod   NUMBER(4),
      --alberto nuevo campo
      numaport      NUMBER,
      ccobroreduc   NUMBER,
      anyoreduc     NUMBER,
      ccobroactual  NUMBER,
      anyoactual    NUMBER,
      importeacumact NUMBER,
      anyoaport     NUMBER,
      fvalor       DATE


   );

   platransf      pla_transf_reg;

   TYPE aportant_pla_minusvalid IS RECORD(
      num_aportant   NUMBER(2),
      nif_aportant   VARCHAR2(9),
      dc_aporta_totals NUMBER(10, 2),
      ind_aporta_any NUMBER(1),
      aporta_any     NUMBER(10, 2),
      nomtot_aportant VARCHAR2(36)
   );

   TYPE aportant_pla_minusvalid_tau IS TABLE OF aportant_pla_minusvalid
      INDEX BY BINARY_INTEGER;

   aporamnv       aportant_pla_minusvalid_tau;
   eaporamnv      aportant_pla_minusvalid;

   TYPE prestacio_reg IS RECORD(
      num_forma_cobr NUMBER(1),
      ind_modprest_any NUMBER(1),
      ind_bencobrat_encap NUMBER(1),
      any_pag_mesantic VARCHAR2(4),
      ind_conting    NUMBER(2),
      data_conting   DATE
   );

   prest          prestacio_reg;

   TYPE prestacio_reg_nfc IS RECORD(
      nforma_cobr    NUMBER(2),
      ind_forma_cobr NUMBER(1),
      ind_tip_cobr   NUMBER(1),
      import_cap     NUMBER(10, 2),
      import_ren     NUMBER(10, 2),
      imp_cons_rfm   NUMBER(10, 2),
      ind_benef_te_benef_esp NUMBER(1),
      data_abon_cap  VARCHAR2(6),
      data_propera_renda VARCHAR2(6),
      data_ultima_renda VARCHAR2(6),
      periode_renda  NUMBER(2),
      tipus_reval    NUMBER(1),
      reval          NUMBER(7, 3),
      mes_reval      NUMBER(2),
      cobprestalg    NUMBER,
      fpripagalg     DATE,
      aporpostsn     NUMBER(1),
      portderecopost NUMBER(5, 2)
   );

   TYPE prestacio_reg_nfc_tau IS TABLE OF prestacio_reg_nfc
      INDEX BY BINARY_INTEGER;

   -- alberto, type y tabla trasplaaportaciones
   TYPE reg_TRASPLAAPORTACIONES IS RECORD(
      stras        NUMBER(8),
      naporta      NUMBER(8),
      faporta      DATE,
      cprocedencia NUMBER,
      ctipoderecho NUMBER,
      importe_post NUMBER(25,10),
      importe_ant  NUMBER(25,10)
   );

   TYPE tab_TRASPLAAPORTACIONES IS TABLE OF reg_TRASPLAAPORTACIONES
      INDEX BY BINARY_INTEGER;
   rtrasplaaportaciones   reg_TRASPLAAPORTACIONES;
   ttrasplaaportaciones   tab_TRASPLAAPORTACIONES;



   prestau        prestacio_reg_nfc_tau;
   eprestau       prestacio_reg_nfc;
   nport          NUMBER := 0;

   PROCEDURE obrir(pcinout IN NUMBER, pfhasta IN DATE);

   PROCEDURE inicialitzar;

   --  PROCEDURE TRANSMETRE (vsprocesnou IN NUMBER);
   PROCEDURE acabar(vsproces IN NUMBER);

   PROCEDURE llegir(vsproces IN NUMBER);

   PROCEDURE escr_apmin(nindex IN NUMBER);

   PROCEDURE escr_prest(nindex IN NUMBER);

   -- PROCEDURE ACTUALITZAR (vsproces IN NUMBER, NCERROR IN NUMBER);

   --
   FUNCTION insertar_registro(pregistro IN registro)
      RETURN NUMBER;

   FUNCTION generar_n234(psproces OUT NUMBER, pcinout IN NUMBER, pfhasta IN DATE)
      RETURN NUMBER;

   FUNCTION f_generar_fichero(
      pcinout IN NUMBER,
      pfhasta IN DATE,
      ptnomfich IN OUT VARCHAR2,
      pnfichero IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
END pk_tr234_out;

/

  GRANT EXECUTE ON "AXIS"."PK_TR234_OUT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_TR234_OUT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_TR234_OUT" TO "PROGRAMADORESCSI";
