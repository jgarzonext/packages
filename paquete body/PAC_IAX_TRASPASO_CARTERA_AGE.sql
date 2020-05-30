--------------------------------------------------------
--  DDL for Package Body PAC_IAX_TRASPASO_CARTERA_AGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_TRASPASO_CARTERA_AGE" AS
/******************************************************************************
   NAME:       PAC_IAX_TRASPASO_CARTERA_AGE
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        16/11/2009  DRA              1. Created this package.
   2.0        31/03/2011  DRA              2. 0018078: LCOL - Analisis Traspaso de Cartera
   3.0        06/02/2012  JMB              3. Ajuste de la conversión del parametro de fecha
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_traspasar_cartera(
      pcageini IN NUMBER,
      pcagefin IN NUMBER,
      pctiptra IN VARCHAR2,
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      psproces_in IN NUMBER,
      ptipotras IN NUMBER,
      pcomis IN VARCHAR2,
      pcmotraspaso IN traspacarage.cmotraspaso%TYPE,
      ptobserv IN traspacarage.tobserv%TYPE,
      psproces_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'pcageini: ' || pcageini || ' - pcagefin: ' || pcagefin || ' - pctiptra: '
            || pctiptra || ' - psseguro: ' || psseguro || ' - pnrecibo: ' || pnrecibo
            || ' - psproces_in: ' || psproces_in || ' - pcmotraspaso: ' || pcmotraspaso
            || ' - ptobserv: ' || ptobserv;
      vobject        VARCHAR2(200) := 'PAC_IAX_TRASPASO_CARTERA_AGE.f_traspasar_cartera';
      vpcomis        t_iax_gstcomision;
      num_err        NUMBER;

      FUNCTION f_crea_obcomis(comisiones IN VARCHAR2)
         RETURN t_iax_gstcomision IS
         vcomi          VARCHAR2(500);
         comi           t_iax_gstcomision := t_iax_gstcomision();
      BEGIN
         IF comisiones IS NULL
            OR comisiones = '' THEN
            RETURN t_iax_gstcomision();
         ELSE
            FOR i IN 1 ..(LENGTH(comisiones) - LENGTH(REPLACE(comisiones, '/', ''))) LOOP
               vcomi := REGEXP_SUBSTR(comisiones, '[^/]*', 1,(2 * i) - 1);
               comi.EXTEND;
               comi(comi.LAST) := ob_iax_gstcomision();
               comi(comi.LAST).cmodcom := TO_NUMBER(REGEXP_SUBSTR(vcomi, '[^#]*', 1, 1));
               comi(comi.LAST).pcomisi := TO_BINARY_FLOAT(REGEXP_SUBSTR(vcomi, '[^#]*', 1, 3));
               comi(comi.LAST).ninialt := TO_NUMBER(REGEXP_SUBSTR(vcomi, '[^#]*', 1, 5));
               comi(comi.LAST).nfinalt := TO_NUMBER(REGEXP_SUBSTR(vcomi, '[^#]*', 1, 7));
            END LOOP;
         END IF;

         RETURN comi;
      EXCEPTION
         WHEN OTHERS THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                              psqcode => SQLCODE, psqerrm => SQLERRM);
      END f_crea_obcomis;
   BEGIN
      vpasexec := 1;
      vpcomis := f_crea_obcomis(pcomis);
      num_err := pac_md_traspaso_cartera_age.f_traspasar_cartera(pcageini, pcagefin, pctiptra,
                                                                 psseguro, pnrecibo,
                                                                 psproces_in, ptipotras,
                                                                 vpcomis, pcmotraspaso,
                                                                 ptobserv, psproces_out,
                                                                 mensajes);

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_traspasar_cartera;

   FUNCTION f_get_listtraspasos(
      pcageini IN NUMBER,
      pcagefin IN NUMBER,
      pfefecto IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'pcageini: ' || pcageini || ' - pcagefin: ' || pcagefin || ' - pfefecto: '
            || pfefecto;
      vobject        VARCHAR2(200) := 'PAC_IAX_TRASPASO_CARTERA_AGE.f_get_listtraspasos';
      cur            sys_refcursor;
   BEGIN
      vpasexec := 1;
      cur := pac_md_traspaso_cartera_age.f_get_listtraspasos(pcageini, pcagefin, pfefecto,
                                                             mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_listtraspasos;

   FUNCTION f_get_listdettrasp(psproces IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psproces: ' || psproces;
      vobject        VARCHAR2(200) := 'PAC_IAX_TRASPASO_CARTERA_AGE.f_get_listdettrasp';
      cur            sys_refcursor;
   BEGIN
      vpasexec := 1;
      cur := pac_md_traspaso_cartera_age.f_get_listdettrasp(psproces, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_listdettrasp;
END pac_iax_traspaso_cartera_age;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_TRASPASO_CARTERA_AGE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_TRASPASO_CARTERA_AGE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_TRASPASO_CARTERA_AGE" TO "PROGRAMADORESCSI";
