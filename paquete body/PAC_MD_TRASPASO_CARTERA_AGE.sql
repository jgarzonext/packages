--------------------------------------------------------
--  DDL for Package Body PAC_MD_TRASPASO_CARTERA_AGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_TRASPASO_CARTERA_AGE" AS
/******************************************************************************
   NAME:       PAC_MD_TRASPASO_CARTERA_AGE
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        16/11/2009  DRA              1. Created this package.
   2.0        31/03/2011  DRA              2. 0018078: LCOL - Analisis Traspaso de Cartera
   3.0        06/02/2012  JMB              3. Ajuste de la conversión del parametro de fecha
   4.0        20/09/2013  MCA              4. 0027549: Traspaso de cartera
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
      pcomis IN t_iax_gstcomision,
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
      vobject        VARCHAR2(200) := 'PAC_MD_TRASPASO_CARTERA_AGE.f_traspasar_cartera';
      num_err        NUMBER;
      vsproces       NUMBER;

      CURSOR cur_polizas IS
         SELECT   sseguro
             FROM seguros
            WHERE ((npoliza = (SELECT npoliza
                                 FROM seguros
                                WHERE sseguro = psseguro
                                  AND ncertif = 0))
                   OR(sseguro = psseguro   -- BUG 0039417 - FAL - 18/01/2016
                      AND ncertif <> 0))
         ORDER BY sseguro;

      CURSOR cur_recibos IS
         SELECT nrecibo
           FROM adm_recunif
          WHERE nrecunif = pnrecibo
         UNION
         SELECT nrecibo
           FROM recibos
          WHERE nrecibo = pnrecibo;
   BEGIN
      vpasexec := 1;
      vsproces := psproces_in;

      IF pctiptra = 'POL' THEN
         FOR x IN cur_polizas LOOP
            num_err := pac_traspaso_cartera_age.f_traspasar_cartera(pcageini, pcagefin,
                                                                    pctiptra, x.sseguro,
                                                                    pnrecibo, vsproces,
                                                                    ptipotras, pcomis,
                                                                    pcmotraspaso, ptobserv,
                                                                    psproces_out);

            IF num_err <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
               RAISE e_object_error;
            ELSE
               vsproces := psproces_out;
            END IF;
         END LOOP;
      ELSIF pctiptra IN('RECGES', 'RECPEN') THEN
         FOR x IN cur_recibos LOOP
            num_err := pac_traspaso_cartera_age.f_traspasar_cartera(pcageini, pcagefin,
                                                                    pctiptra, psseguro,
                                                                    x.nrecibo, vsproces,
                                                                    ptipotras, pcomis,
                                                                    pcmotraspaso, ptobserv,
                                                                    psproces_out);

            IF num_err <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
               RAISE e_object_error;
            ELSE
               vsproces := psproces_out;
            END IF;
         END LOOP;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
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
      vsquery        VARCHAR2(2000);
      cur            sys_refcursor;
   BEGIN
      vpasexec := 1;
      vsquery := pac_traspaso_cartera_age.f_get_listtraspasos(pcageini, pcagefin, pfefecto);
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
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
      vsquery        VARCHAR2(2000);
      cur            sys_refcursor;
   BEGIN
      vpasexec := 1;
      vsquery := pac_traspaso_cartera_age.f_get_listdettrasp(psproces);
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
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
END pac_md_traspaso_cartera_age;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_TRASPASO_CARTERA_AGE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_TRASPASO_CARTERA_AGE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_TRASPASO_CARTERA_AGE" TO "PROGRAMADORESCSI";
