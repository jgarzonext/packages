--------------------------------------------------------
--  DDL for Package Body PAC_MD_CASHDESK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_CASHDESK" AS
   /******************************************************************************
        PACKAGE NAME: PAC_MD_CASHDESK_MSV
        OBJECTIVE:  Package created for temporaly data in window axisadm093*
        AUTHOR: JOHN BENITEZ ALEMAN - FACTORY COLOMBIA
        DATE: APRIL 2015

        LAST CHECKED:
        Ver        date          Author             Descriptión
        ---------  ----------  ---------------  ------------------------------------
        1.0        24/APRIL/2015   JBENITEZ             1.0 CASH DESK MODULE (MSV)

     ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   mensajes       t_iax_mensajes := NULL;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma;
   gempres        NUMBER := pac_md_common.f_get_cxtempresa;

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
      vnumerr        NUMBER;
      vseqcaja       NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_MD_CASHDESK_MSV.GET_SEQ_CAJA';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'VNUMERR=' || vnumerr;
   BEGIN
      vnumerr := pac_cashdesk.get_seq_caja(mensajes);
      --EXCEPTION CONTROLS
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
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
      RETURN var_refcursor IS
      cur            var_refcursor;
      vobject        VARCHAR2(200) := 'PAC_MD_CASHDESK_MSV.SAVE_TEMPO';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'TSTEMPO=' || tstempo || ' TOTAL=' || total || ' TPOLICY=' || tpolicy
            || ' TPREMIUM=' || tpremium;
   BEGIN
      cur := pac_cashdesk.f_ins_cashdesktmp(tstempo, total, tpolicy, tpremium, tid, tsperson,
                                            mensajes);
      RETURN cur;
   --EXCEPTION CONTROLS
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
         RETURN NULL;
   END f_ins_cashdesktmp;

/******************************************************************************
     FUNCTION NAME: DEL_TEMPO
     OBJECTIVE: DELETE TEMPORALY DATA IN A TABLE, THAT WAS INSERTED WITH SAVE_TEMPO FUNCTION
     AUTHOR: JOHN BENITEZ ALEMAN - FACTORY COLOMBIA
     DATE: APRIL 2015
   ******************************************************************************/
   FUNCTION f_del_cashdesktmp(tstempo IN NUMBER, tid IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN var_refcursor IS
      cur            var_refcursor;
      vobject        VARCHAR2(200) := 'PAC_IAX_CASHDESK_MSV.DEL_TEMPO';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'TSTEMPO=' || tstempo;
   BEGIN
      cur := pac_cashdesk.f_del_cashdesktmp(tstempo, tid, mensajes);
      RETURN cur;
   --EXCEPTION CONTROLS
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
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
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vobject        VARCHAR2(200) := 'PAC_IAX_CASHDESK_MSV.DO_TRANSACTION';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'PAYERID=' || payerid || ' CURRENCY=' || currency || ' PAYREASON=' || payreason
            || ' AMOPAY=' || amopay || ' DATEREC=' || daterec || ' PAYMET=' || paymet
            || ' BNAME=' || bname || ' OBANK=' || obank || ' ACCONUM=' || acconum || ' CHNUM='
            || chnum || ' CHTYPE=' || chtype || ' CLIMOP=' || climop || ' PAYTEXT=' || paytext;
   BEGIN
      vnumerr := pac_cashdesk.f_apunte_pago_spl(payerid, currency, payreason, amopay, daterec,
                                                paymet, bname, obank, acconum, chnum, chtype,
                                                climop, paytext, tid, ptdescchk, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_apunte_pago_spl;

   FUNCTION f_leepagos_sin_poliza(p_sperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      -- cur            var_refcursor;
      v_object       VARCHAR2(200) := 'PAC_IAX_CASHDESK.f_leepagos_sin_poliza';
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000) := 'sperson=' || p_sperson;
      v_monto        NUMBER;
      e_param_error  EXCEPTION;
   BEGIN
      v_monto := pac_cashdesk.f_leepagos_sin_poliza(p_sperson);
      --
      --p_tab_error(f_sysdate, f_user,'MD '||v_monto,v_pasexec,'p_sperson ='|| p_sperson, SQLERRM);
      RETURN v_monto;
   --EXCEPTION CONTROLS
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      -- cur            var_refcursor;
      v_object       VARCHAR2(200) := 'PAC_IAX_CASHDESK.f_ejecuta_sin_poliza';
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(2000) := 'sperson=' || p_sperson;
      v_monto        NUMBER;
      e_param_error  EXCEPTION;
      vtid           NUMBER;
   BEGIN
      v_monto := pac_cashdesk.f_ejecuta_sin_poliza(p_sperson, p_currency, p_payreason,
                                                   p_monto, p_daterec, p_paymet, p_bname,
                                                   p_obank, p_chdrtype, p_chnum, p_chtype,
                                                   p_climop, p_paytext, p_seq, vtid, mensajes);

      IF v_monto <> 0 THEN
         RAISE e_param_error;
      END IF;

      --p_tab_error(f_sysdate, f_user,'MD '||v_monto,v_pasexec,'p_sperson ='|| p_sperson, SQLERRM);
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL,
                                           f_axis_literales(9908113,
                                                            pac_md_common.f_get_cxtidioma())
                                           || vtid);
      RETURN vtid;
   --EXCEPTION CONTROLS
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, v_monto, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN -1;
   END f_ejecuta_sin_poliza;

   FUNCTION f_get_datospago(
      pseqcaja IN caja_datmedio.seqcaja%TYPE,
      pnumlin IN caja_datmedio.nnumlin%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      --
      vcursor        sys_refcursor;
      vobject        VARCHAR2(200) := 'PAC_MD_CASHDESK.f_get_datospago';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pseqcaja= ' || pseqcaja || ' - pnumlin= ' || pnumlin;
   --
   BEGIN
      --
      vcursor := pac_cashdesk.f_get_datospago(pseqcaja, pnumlin, mensajes);
      --
      RETURN vcursor;
   --
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_datospago;
END pac_md_cashdesk;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_CASHDESK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CASHDESK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CASHDESK" TO "PROGRAMADORESCSI";
