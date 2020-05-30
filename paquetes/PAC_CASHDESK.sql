--------------------------------------------------------
--  DDL for Package PAC_CASHDESK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CASHDESK" AUTHID CURRENT_USER IS
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
   TYPE var_refcursor IS REF CURSOR;

   /******************************************************************************
      FUNCTION NAME: GET_SEQ_CAJA
      OBJECTIVE: GET A NUMBER FROM SEQUENCE TO BE THE TRANSACTION ID
      AUTHOR: JOHN BENITEZ ALEMAN - FACTORY COLOMBIA
      DATE: APRIL 2015
    ******************************************************************************/
   FUNCTION get_seq_caja(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

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
      RETURN var_refcursor;

   /******************************************************************************
      FUNCTION NAME: DEL_TEMPO
      OBJECTIVE: DELETE TEMPORALY DATA IN A TABLE, THAT WAS INSERTED WITH SAVE_TEMPO FUNCTION
      AUTHOR: JOHN BENITEZ ALEMAN - FACTORY COLOMBIA
      DATE: APRIL 2015
    ******************************************************************************/
   FUNCTION f_del_cashdesktmp(tstempo IN NUMBER, tid IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN var_refcursor;

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
      RETURN NUMBER;

   FUNCTION f_leepagos_sin_poliza(p_sperson IN NUMBER)
      RETURN NUMBER;

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
      RETURN NUMBER;

   FUNCTION f_get_datospago(
      pseqcaja IN caja_datmedio.seqcaja%TYPE,
      pnumlin IN caja_datmedio.nnumlin%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
END pac_cashdesk;

/

  GRANT EXECUTE ON "AXIS"."PAC_CASHDESK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CASHDESK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CASHDESK" TO "PROGRAMADORESCSI";
