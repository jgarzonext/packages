--------------------------------------------------------
--  DDL for Package Body PAC_CASHDESK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CASHDESK" IS
   e_param_error  EXCEPTION;

    /******************************************************************************
       PACKAGE NAME: PAC_CASHDESK_MSV
       OBJECTIVE:  Package created for temporaly data in window axisadm093*
       AUTHOR: JOHN BENITEZ ALEMAN - FACTORY COLOMBIA
       DATE: APRIL 2015

       LAST CHECKED:
       Ver        date          Author             Descriptión
       ---------  ----------  ---------------  ------------------------------------
       1.0        24/APRIL/2015   JBENITEZ             1.0 CASH DESK MODULE (MSV)

    ******************************************************************************/
   /******************************************************************************
      FUNCTION NAME: GET_SEQ_CAJA
      OBJECTIVE: GET A NUMBER FROM SEQUENCE TO BE THE TRANSACTION ID
      AUTHOR: JOHN BENITEZ ALEMAN - FACTORY COLOMBIA
      DATE: APRIL 2015
    ******************************************************************************/
   FUNCTION get_seq_caja(mensajes OUT t_iax_mensajes)
      --NUMBER RETURN
   RETURN NUMBER IS
      --VARIABLES
      vseqmovecash   NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_CASHDESK_MSV.GET_SEQ_CAJA';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'VSEQCAJA=' || vseqmovecash;
   BEGIN
      --GETTING VALUE FROM SEQUENCE FOR ID OPERATION
      SELECT seqmovecash.NEXTVAL
        INTO vseqmovecash
        FROM DUAL;

      --EXCEPTION CONTROLS
      RETURN vseqmovecash;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
--END FUNCTION GET_SEQ_CAJA
   END get_seq_caja;

   /******************************************************************************
      FUNCTION NAME: SAVE_TEMPO
      OBJECTIVE: SAVE TEMPORALY DATA IN A TABLE, THEN SEND IT TO A CORE FUNCTION
      AUTHOR: JOHN BENITEZ ALEMAN - FACTORY COLOMBIA
      DATE: APRIL 2015
    ******************************************************************************/
   FUNCTION f_ins_cashdesktmp(
      tstempo IN NUMBER,
      total IN NUMBER,
      tpolicy IN VARCHAR2,
      tpremium IN NUMBER,
      tid IN VARCHAR2,
      tsperson IN cashdesktmp.sperson%TYPE,
      mensajes OUT t_iax_mensajes)
      --CURSOR RETURN
   RETURN var_refcursor IS
      cur            var_refcursor;
      --VARIABLES
      credordebit    VARCHAR2(50) := '';
      vseq           NUMBER := 0;
      vtid           NUMBER := 0;
      tempo2         NUMBER := tstempo;
      varsperson     NUMBER := 0;
      varnom         VARCHAR(50) := '';
      varape         VARCHAR(50) := '';
      html           VARCHAR(70) := '';
      varsseguro     NUMBER := 0;
      vsuma          NUMBER := 0;
      vnull          NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_CASHDESK_MSV.f_ins_cashdesktmp';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'TSTEMPO=' || tstempo || ' TOTAL=' || total || ' TPOLICY=' || tpolicy
            || ' TPREMIUM=' || tpremium|| ' tid=' || tid|| ' tsperson=' || tsperson;
   BEGIN
      --CASTING TID TO NUMBER
      vtid := TO_NUMBER(tid);

      --VERIFING ROW WITH "STEMPO = 1" EXIST (ROW FOR HELP)
      SELECT MAX(seqtempo)
        INTO vnull
        FROM cashdesktmp;

      vpasexec := 2;

      IF vnull IS NULL THEN
         INSERT INTO cashdesktmp (SEQTEMPO, NPOLIZA, SSEGURO, TNOMBRE, SPERSON, ITOTPRI, CDEBHAB, SEQID)
              VALUES (1, '1', 1, '1', 1, '1', '1', NULL);
      END IF;

      vpasexec := 3;

      -- TESTTING IF AMOUNT TO PAY IS OVER THAN THE NEXT POSSIBLE TOTAL OF PREMIUMS
      SELECT SUM(itotpri)
        INTO vsuma
        FROM cashdesktmp
       WHERE seqid = vtid;

      vpasexec := 4;

      IF vsuma IS NULL THEN
         vsuma := 0;
      END IF;

      vpasexec := 5;
      vsuma :=(vsuma + tpremium);

      IF total >= vsuma THEN
         vpasexec := 6;

         --SELECTING NEXT VALUE FROM SEQUENCE SECTEMPO INTO VSEQ
         SELECT sectempo.NEXTVAL
           INTO vseq
           FROM DUAL;

         --IF TEMPO2 IS NULL CONTINUE WITH THE INSERT (WITH THE VSEQ VALUE)
         tempo2 := vseq;

         --CONDITION TO KNOW IF PUT DEBIT OR CREDIT
         IF tpremium < 0 THEN
            credordebit := 'DEBIT';
         ELSE
            credordebit := 'CREDIT';
         END IF;

         --FETCHING SSEGURO
         vpasexec := 7;

         IF tpolicy <> 0 THEN
            SELECT sseguro
              INTO varsseguro
              FROM seguros
             WHERE npoliza = tpolicy;
         END IF;

         IF tpolicy = 0 THEN
            varsseguro := 0;
         END IF;

         vpasexec := 8;

         --FECHING HOLDER NAME
         IF varsseguro <> 0 THEN
            IF tsperson IS NOT NULL THEN
               --
               BEGIN
                  --
                  SELECT t.sperson
                    INTO varsperson
                    FROM tomadores t
                   WHERE t.sseguro = varsseguro
                     AND t.sperson = tsperson;
               --
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     --
                     SELECT t.sperson
                       INTO varsperson
                       FROM tomadores t
                      WHERE t.sseguro = varsseguro
                        AND t.nordtom = (SELECT MIN(t1.nordtom)
                                           FROM tomadores t1
                                          WHERE t1.sseguro = t.sseguro);
               --
               END;
            --
            ELSE
               --
               SELECT t.sperson
                 INTO varsperson
                 FROM tomadores t
                WHERE t.sseguro = varsseguro
                  AND t.nordtom = (SELECT MIN(t1.nordtom)
                                     FROM tomadores t1
                                    WHERE t1.sseguro = t.sseguro);
            --
            END IF;
         END IF;

         IF varsseguro = 0 THEN
            varsperson := 0;
         END IF;

         vpasexec := 9;

         IF varsperson <> 0 THEN
            BEGIN
              SELECT SUBSTR (p.tnombre, 1, 50), SUBSTR (p.tapelli1, 1, 50)
                INTO varnom, varape
                FROM per_detper p
               WHERE p.sperson = varsperson
                 AND p.cagente = ff_agente_cpervisio((SELECT s.cagente FROM seguros s WHERE s.sseguro = varsseguro));
            EXCEPTION
              WHEN OTHERS THEN
                BEGIN
                  SELECT SUBSTR (p.tnombre, 1, 50), SUBSTR (p.tapelli1, 1, 50)
                    INTO varnom, varape
                    FROM personas p
                   WHERE p.sperson = varsperson;
                EXCEPTION
                  WHEN OTHERS THEN
                    varnom := '**';
                    varape := '**';
                END;
            END;
         END IF;

         varnom := SUBSTR (varnom || ' ' || varape, 1, 50);
         --PAINTING "DELETE BUTTON IN JSP" (´CAUSE USING AJAX)
         --html := '<img src="images/delete.gif" onclick="f_del(' || tempo2 || ')" />';

         --INSERTING VALUES INTO TABLE PAY_TEMPO
         vpasexec := 10;

         INSERT INTO cashdesktmp (SEQTEMPO, NPOLIZA, SSEGURO, TNOMBRE, SPERSON, ITOTPRI, CDEBHAB, SEQID)
              VALUES (tempo2, tpolicy, varsseguro, varnom, varsperson, tpremium, credordebit, vtid);

         vpasexec := 11;

         --COMMIT;

         -- OPENIGN CURSOR TO FETCH DATA TO JAVA
         OPEN cur FOR
            SELECT *
              FROM cashdesktmp
             WHERE seqtempo != 1
               AND seqid = vtid;

         vpasexec := 12;
         RETURN cur;

         CLOSE cur;
      --IF CONDITION DONT APPLY, RETURN NULL 1 VALUE (THAT IF NEGATIVE FOR USR)
      ELSE
         OPEN cur FOR
            SELECT *
              FROM cashdesktmp
             WHERE seqtempo = 1;

         vpasexec := 13;
         RETURN cur;
      --CLOSE cur;

      -- RETURN cur;
      END IF;
   --EXCEPTION CONTROLS
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_cashdesk.f_ins_cashdesktmp', vpasexec, vparam,
                     SQLERRM);
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   --END FUNCTION SAVE_TEMPO
   END f_ins_cashdesktmp;

   /******************************************************************************
      FUNCTION NAME: DEL_TEMPO
      OBJECTIVE: DELETE TEMPORALY DATA IN A TABLE, THAT WAS INSERTED WITH SAVE_TEMPO FUNCTION
      AUTHOR: JOHN BENITEZ ALEMAN - FACTORY COLOMBIA
      DATE: APRIL 2015
    ******************************************************************************/
   FUNCTION f_del_cashdesktmp(tstempo IN NUMBER, tid IN VARCHAR2, mensajes OUT t_iax_mensajes)
      --CURSOR RETURN
   RETURN var_refcursor IS
      cur            var_refcursor;
      --VARIABLES
      vnull          NUMBER := 0;
      vtid           NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_CASHDESK_MSV.DEL_TEMPO';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'TSTEMPO=' || tstempo;
   BEGIN
      --CASTING TID TO NUMBER
      vtid := TO_NUMBER(tid);

      --DELETING SELECTED DATA FROM PAY_TEMPO
      DELETE FROM cashdesktmp
            WHERE seqtempo = tstempo
              AND seqid = vtid;

      --COMMIT;

      --VERIFING IF THE TABLE "PAY_TEMPO_MSV" IS EMPTY (IF THAT IS THE CASE, A ERROR WILL APPEAR, SO THEN WE INSERT A VALUE=1 IN EVERY FIELD)
      SELECT MAX(seqtempo)
        INTO vnull
        FROM cashdesktmp;

      IF vnull IS NULL THEN
         INSERT INTO cashdesktmp (SEQTEMPO, NPOLIZA, SSEGURO, TNOMBRE, SPERSON, ITOTPRI, CDEBHAB, SEQID)
              VALUES (1, '1', 1, '1', 1, '1', '1', NULL);
      ELSIF vnull = 1 THEN
         RETURN NULL;
      ELSE
         --SENDING BACK DATA WITHOUT THE DELETED ROW
         OPEN cur FOR
            SELECT *
              FROM cashdesktmp
             WHERE seqtempo != 1
               AND seqid = vtid;

         RETURN cur;

         CLOSE cur;
      END IF;
   --EXCEPTION CONTROLS
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   --END FUNCTION DEL_TEMPO
   END f_del_cashdesktmp;

   /******************************************************************************
     FUNCTION NAME: DO_TRANSACTION
     OBJECTIVE: PREPARE AND SEND INSERTS (IN THIS CASE TRANSACTIONS) FOR EACH MOVEMENT´S POLICY
     AUTHOR: JOHN BENITEZ ALEMAN - FACTORY COLOMBIA
     DATE: APRIL 2015
   ******************************************************************************/
   FUNCTION f_apunte_pago_spl(
      payerid IN VARCHAR2,
      currency IN VARCHAR2,
      payreason IN VARCHAR2,
      amopay IN NUMBER,
      daterec IN VARCHAR2,
      paymet IN VARCHAR2,
      bname IN VARCHAR2,
      obank IN VARCHAR2,
      acconum IN VARCHAR2,
      chnum IN VARCHAR2,
      chtype IN VARCHAR2,
      climop IN VARCHAR2,
      paytext IN VARCHAR2,
      tid IN VARCHAR2,
      ptdescchk IN VARCHAR2 DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      --NUMBER RETURN
   RETURN NUMBER IS
      --VARIABLES pay_tempo
      vtid           NUMBER := 0;
      v_seqcaja      NUMBER;

      CURSOR shooter IS
         SELECT sseguro, itotpri, cdebhab
           FROM cashdesktmp
          WHERE seqtempo != 1
            AND seqid = vtid;

      vpayer         NUMBER := 0;
      vbank          VARCHAR(35) := '';
      vamopay        NUMBER := 0;
      vcurrency      NUMBER := 0;
      vpaymet        NUMBER := 0;
      vchtype        NUMBER := 0;
      vdatarec       DATE := f_sysdate;
      vselect        VARCHAR2(2000) := 0;
      vseguro        NUMBER := 0;
      vpremium       NUMBER := 0;
      vdestiny       VARCHAR2(2000) := 0;
      vcount         NUMBER := 0;
      vret           NUMBER := 0;
      vseqcaja       NUMBER := 0;
      e_error        EXCEPTION;
      vobject        VARCHAR2(200) := 'PAC_CASHDESK_MSV.F_APUNTE_PAGO_SPL';
      vpasexec       NUMBER(8) := 1;
      vchtyped       NUMBER;
      vparam         VARCHAR2(2000)
         := 'PAYERID=' || payerid || ' CURRENCY=' || vcurrency || ' PAYREASON=' || payreason
            || ' AMOPAY=' || vamopay || ' DATEREC=' || daterec || ' PAYMET=' || vpaymet
            || ' bnamecod=' || bname || ' OBANK=' || obank || ' ACCONUM=' || acconum
            || ' CHNUM=' || chnum || ' CHTYPE=' || chtype || ' CLIMOP=' || climop
            || ' PAYTEXT=' || paytext || ' tid=' || tid;
   BEGIN
      --CATCHING SPERSON FOR PAYER
      vpayer := payerid;
      --CASTING AMOPAY,CURRENCY,PAYMET,CHTYPE,TID TO NUMBER
      vtid := TO_NUMBER(tid);
      vamopay := amopay;
      vcurrency := TO_NUMBER(currency);
      vpaymet := TO_NUMBER(paymet);
      vchtype := TO_NUMBER(chtype);
      vpasexec := 2;

      --TESTING WHICH PARAMETER HAVE THE BANK NAME
      --IF bname IS NULL THEN
      vbank := obank;
      --END IF;

      --SELECTING HOW MANY REGISTERS THERE ARE IN TABLE PAY_TEMPO
      SELECT COUNT(*)
        INTO vcount
        FROM cashdesktmp
       WHERE seqid = vtid;

      vpasexec := 3;

      --OPENING CURSOR TO CALL DESTINY FUNCTION
      OPEN shooter;

      --OPEN FOR TO FETCH DATA FROM CURSOR
      FOR runner IN 1 .. vcount LOOP
         FETCH shooter
          INTO vseguro, vpremium, vdestiny;

         --CALLING FUNCTION AND SENDING DATA NAD STORING RESULT IN A VARIABLE (ZERO=POSITIVE, ONE=NEGATIVE)
         vret := pac_ctacliente.f_apunte_pago_spl(pac_md_common.f_get_cxtempresa, vseguro,
                                                  vpremium, chnum, 0, bname, NULL, NULL,
                                                  acconum, NULL, vpaymet, vcurrency, vtid,
                                                  NULL, NULL, NULL, NULL, vbank, vchtype,
                                                  climop, payreason, paytext,
                                                  TO_DATE(daterec, 'DD/MM/YYYY'), NULL, NULL,
                                                  NULL, vpayer, v_seqcaja, ptdescchk);

         --COMMIT;

         --CATCHING IF FUNCTION PAC_CTACLIENTE.F_APUNTE_PAGO_SPL RETURN ONE(1), SO A ERROR, AND SENDING IN RAISE
         IF vret <> 0 THEN
            RAISE e_error;
         END IF;

         --ENDING LOOP AND FOR
         EXIT WHEN shooter%NOTFOUND;
      END LOOP;

      vpasexec := 4;

      --CLOSING CURSOR
      CLOSE shooter;

      --DELETING DATA IN TABLE PAY_TEMPO_MSV(THIS IS JUST TEMPORAL HELP DATATABLE)
      DELETE FROM cashdesktmp
            WHERE seqtempo != 1
              AND seqid = vtid;

      vpasexec := 5;
      --COMMIT;
      --SENDING MESSAGE WHEN ALL IT´S OK
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL,
                                           f_axis_literales(9908113,
                                                            pac_md_common.f_get_cxtidioma())
                                           || vtid);
      RETURN vret;
   --EXCEPTION CONTROLS
   EXCEPTION
      --RAISE ERROR CONTINUE
      WHEN e_error THEN
         --SEND INFORMATION TO TAB_ERROR
         pac_iobj_mensajes.crea_nuevo_mensaje
                                          (mensajes, 1, NULL,
                                           f_axis_literales(9908112,
                                                            pac_md_common.f_get_cxtidioma())
                                           || vseguro);

         --DELETING DATA IN TABLE PAY_TEMPO_MSV(THIS IS JUST TEMPORAL HELP DATATABLE)
         DELETE FROM cashdesktmp
               WHERE seqtempo != 1;

         COMMIT;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF shooter%ISOPEN THEN
            CLOSE shooter;
         END IF;

         RETURN NULL;
   --END FUNCTION DO_TRANSACTION
   END f_apunte_pago_spl;

--END PACKAGE PAC_CASHDESK_MSV BODY
   FUNCTION f_leepagos_sin_poliza(p_sperson IN NUMBER)
      RETURN NUMBER IS
      v_imovimi      NUMBER;
      vpasexec       NUMBER;
   BEGIN
      SELECT NVL(SUM(d.imovimi), 0)
        INTO v_imovimi
        FROM caja_datmedio d
       WHERE d.sseguro = 0
         AND(d.cmedmov <> 8
             OR d.cmedmov IS NULL)
         AND d.seqcaja IN(SELECT c.seqcaja
                            FROM cajamov c
                           WHERE c.sperson = p_sperson);

      RETURN v_imovimi;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN -1;
   END f_leepagos_sin_poliza;

   FUNCTION f_ejecuta_sin_poliza(
      p_sperson IN NUMBER,
      p_currency IN VARCHAR2,
      p_payreason IN VARCHAR2,
      p_monto IN NUMBER,
      p_daterec IN VARCHAR2,
      p_paymet IN VARCHAR2,
      p_bname IN VARCHAR2,
      p_obank IN VARCHAR2,
      p_chdrtype IN VARCHAR2,
      p_chnum IN VARCHAR2,
      p_chtype IN VARCHAR2,
      p_climop IN VARCHAR2,
      p_paytext IN VARCHAR2,
      p_seq IN NUMBER,
      vsec OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_imovimi      NUMBER := 0;
      vpasexec       NUMBER := 1;
      vseguro        NUMBER;
      e_error        EXCEPTION;
      e_errores      EXCEPTION;
      v_seqcaja      NUMBER;
      vret           NUMBER;
      vseq           NUMBER;
   --mensajes  t_iax_mensajes;
   BEGIN
      vseq := p_seq;
--      BEGIN
--         SELECT MAX(sseguro)
--           INTO vseguro
--           FROM tomadores
--          WHERE sperson = p_sperson;
--      EXCEPTION
--         WHEN NO_DATA_FOUND THEN
--            RAISE e_error;
--      END;
      vpasexec := 2;

      IF (p_monto > 0
                     /*AND vseguro IS NOT NULL*/
         ) THEN
         vret := pac_cashdesk.f_apunte_pago_spl(p_sperson, p_currency, p_payreason, p_monto,
                                                p_daterec, p_paymet, p_bname, p_obank,
                                                p_chdrtype, p_chnum, p_chtype, p_climop,
                                                p_paytext, p_seq, NULL, mensajes);
         vpasexec := 3;

         IF vret <> 0 THEN
            RAISE e_errores;
         END IF;

         vret := pac_ctacliente.f_apunte_pago_spl(pac_md_common.f_get_cxtempresa, 0,
                                                  p_monto * -1, NULL, NULL, NULL, NULL, NULL,
                                                  NULL, NULL, NULL, NULL, vseq, NULL, NULL,
                                                  NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                                  NULL, NULL, NULL, NULL, p_sperson, v_seqcaja);
         vpasexec := 4;

         IF vret <> 0 THEN
            RAISE e_errores;
         END IF;

         vsec := vseq;
      END IF;

      RETURN v_imovimi;
   EXCEPTION
      WHEN e_errores THEN
         p_tab_error(f_sysdate, f_user, 'pac_cashdesk.f_ejecuta_sin_poliza', vpasexec,
                     'p_sperson =' || p_sperson || 'p_monto =' || p_monto, SQLERRM);
         RETURN SQLERRM;
      WHEN e_error THEN
         p_tab_error(f_sysdate, f_user, 'pac_cashdesk.f_ejecuta_sin_poliza', vpasexec,
                     'p_sperson =' || p_sperson, SQLERRM);
         RETURN 140897;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_cashdesk.f_ejecuta_sin_poliza', vpasexec,
                     'p_sperson =' || p_sperson, SQLERRM);
         RETURN -1;
   END f_ejecuta_sin_poliza;

   FUNCTION f_get_datospago(
      pseqcaja IN caja_datmedio.seqcaja%TYPE,
      pnumlin IN caja_datmedio.nnumlin%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      --
      vcursor        sys_refcursor;
      vobject        VARCHAR2(200) := 'PAC_IAX_CASHDESK.f_get_datospago';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pseqcaja= ' || pseqcaja || ' - pnumlin= ' || pnumlin;
   --
   BEGIN
      --
      OPEN vcursor FOR
         SELECT ff_desvalorfijo(481, pac_md_common.f_get_cxtidioma(), c.cmedmov) tmedmov,
                ff_desvalorfijo(1903, pac_md_common.f_get_cxtidioma(), c.crazon) trazon,
                c.fautori ffecharec, (SELECT b.tbanco
                                        FROM bancos b
                                       WHERE b.cbanco = c.cbanco) tbanco,
                ff_desvalorfijo(1902, pac_md_common.f_get_cxtidioma(), c.ctipche) ntypcheq,
                DECODE(c.ctipche, 3, ff_desvalorfijo(8000953, pac_md_common.f_get_cxtidioma(), c.ctipched),
                       ff_desvalorfijo(8000955, pac_md_common.f_get_cxtidioma(), c.ctipched)) ntypdcheq,
                c.ncheque ncheque, c.dsbanco totroban, c.ntarget naccnumber,
                c.tdescchk naccholder, c.dsmop tpaytext, c.imovimi namopay,
                c.cautoriza cautoriza, c.ccomercio ccomercio, ic.cproceso cproceso,
                ff_desvalorfijo(483, pac_md_common.f_get_cxtidioma(), c.cestchq) cestchq,
                NVL(ic.cusuario, m.cusuari) cuser,
                DECODE(c.sseguro, 0, 0, NULL, NULL, sg.npoliza) npolicy,
                DECODE(c.sseguro_d,
                       NULL, (SELECT sd.npoliza
                                FROM seguros sd
                               WHERE sd.sseguro =
                                        (SELECT co.sseguro
                                           FROM caja_datmedio co
                                          WHERE co.nrefdeposito = c.nrefdeposito
                                            AND co.seqcaja < c.seqcaja
                                            AND co.sseguro IS NOT NULL
                                            AND ROWNUM = 1)),
                       (SELECT so.npoliza
                          FROM seguros so
                         WHERE so.sseguro = c.sseguro)) npoliza_ori,
                DECODE(c.sseguro_d,
                       NULL, (SELECT sd.npoliza
                                FROM seguros sd
                               WHERE sd.sseguro =
                                        (SELECT co.sseguro_d
                                           FROM caja_datmedio co
                                          WHERE co.nrefdeposito = c.nrefdeposito
                                            AND co.seqcaja < c.seqcaja
                                            AND co.sseguro IS NOT NULL
                                            AND ROWNUM = 1)),
                       (SELECT so.npoliza
                          FROM seguros so
                         WHERE so.sseguro = c.sseguro_d)) npoliza_dtn
           FROM caja_datmedio c, cajamov m, int_carga_ctrl ic, seguros sg
          WHERE c.seqcaja = m.seqcaja
            AND ic.sproces(+) = c.cautoriza
            AND sg.sseguro(+) = c.sseguro
            AND c.seqcaja = pseqcaja
            AND c.nnumlin = pnumlin;

      --
      RETURN vcursor;
   --
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_datospago;
END pac_cashdesk;

/

  GRANT EXECUTE ON "AXIS"."PAC_CASHDESK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CASHDESK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CASHDESK" TO "PROGRAMADORESCSI";
