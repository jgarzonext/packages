--------------------------------------------------------
--  DDL for Package Body PAC_IAX_CTACLIENTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_CTACLIENTE" AS
/*****************************************************************************
   NAME:       PAC_IAX_CTACLIENTE
   PURPOSE:    Funciones de obtención de datos de CTACLIENTE

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/02/2013   JRH             1. Creación del package.
   3.0        28/04/2015   YDA             3. Se crea la función f_crea_rec_gasto
   4.0        06/05/2015   YDA             4. Se crean las funciones f_get_nroreembolsos y f_actualiza_nroreembol
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   mensajes       t_iax_mensajes := NULL;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma;
   gempres        NUMBER := pac_md_common.f_get_cxtempresa;

   ------- Funciones internes
   /*************************************************************************
       Obtiene los registros de movimientos en CTACLIENTE
       param in psseguro  : póliza
       param in pnriesgo  : riesgo
       param in fechaIni     : fecha Inicio movimientos
       param in fechaFin    : fecha Final movimientos
       DatCtaseg out T_IAX_CTACLIENTE : Collection con datos CTACLIENTE
       param out mensajes : mensajes de error
       return             : 0 si todo ha ido bien o 1
    *************************************************************************/
   FUNCTION f_obtenermovimientos(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfechaini IN DATE,
      pfechafin IN DATE,
      pcmovimi IN NUMBER,
      pcmedmov IN NUMBER,
      pimporte IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := ' psseguro= ' || psseguro || ' psperson= ' || psperson || ' pfechaini= '
            || pfechaini || ' pfechaFin= ' || pfechafin || ' pcmovimi=' || pcmovimi
            || ' pcmedmov= ' || pcmedmov || ' pimporte= ' || pimporte;
      vobject        VARCHAR2(200) := 'PAC_IAX_CTACLIENTE.f_obtenerMovimientos';
      reg_seg        seguros%ROWTYPE;
      v_norden       NUMBER;
      datctaseg      sys_refcursor;
   BEGIN
      IF psperson IS NULL
         AND psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      numerr := pac_md_ctacliente.f_obtenermovimientos(gempres, psperson, psseguro, psproduc,
                                                       pfechaini, pfechafin, pcmovimi,
                                                       pcmedmov, pimporte, datctaseg, mensajes);

      IF numerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN datctaseg;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, numerr, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_obtenermovimientos;

   FUNCTION f_obtenerpolizas(sperson per_personas.sperson%TYPE, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'sperson= ' || sperson;
      vobject        VARCHAR2(200) := 'pac_iax_ctacliente.f_obtenerpolizas';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_ctacliente.f_obtenerpolizas(sperson, mensajes);
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

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_obtenerpolizas;

   FUNCTION f_obtenerpersonas(psseguro seguros.sseguro%TYPE, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psseguro= ' || psseguro;
      vobject        VARCHAR2(200) := 'pac_iax_ctacliente.f_obtenerpolizas';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_ctacliente.f_obtenerpersonas(psseguro, mensajes);
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

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_obtenerpersonas;

--BUG: 33886/199827
   FUNCTION f_transferible_spl(psseguro NUMBER, mensajes OUT t_iax_mensajes)
      --RDD 22/04/2015
   RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := '';
      vobject        VARCHAR2(200) := 'pac_iax_caja.f_transferible_spl';
   BEGIN
      vpasexec := 2;
      vnumerr := pac_md_ctacliente.f_transferible_spl(psseguro, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_transferible_spl;

   FUNCTION f_apunte_pago_spl(
      pcempres IN NUMBER,
      psseguro IN NUMBER,
      pimporte IN NUMBER,
      pncheque IN VARCHAR2 DEFAULT NULL,
      pcestchq IN NUMBER DEFAULT NULL,
      pcbanco IN NUMBER DEFAULT NULL,
      pccc IN VARCHAR2 DEFAULT NULL,
      pctiptar IN NUMBER DEFAULT NULL,
      pntarget IN NUMBER DEFAULT NULL,
      pfcadtar IN VARCHAR2 DEFAULT NULL,
      pcmedmov IN NUMBER DEFAULT NULL,
      pcmoneop IN NUMBER DEFAULT 1,
      pnrefdeposito IN NUMBER DEFAULT NULL,
      pcautoriza IN NUMBER DEFAULT NULL,
      pnultdigtar IN NUMBER DEFAULT NULL,
      pncuotas IN NUMBER DEFAULT NULL,
      pccomercio IN NUMBER DEFAULT NULL,
      pdsbanco IN VARCHAR2 DEFAULT NULL,
      pctipche IN NUMBER DEFAULT NULL,
      pctipched IN NUMBER DEFAULT NULL,
      pcrazon IN NUMBER DEFAULT NULL,
      pdsmop IN VARCHAR2 DEFAULT NULL,
      pfautori IN DATE DEFAULT NULL,
      pcestado IN NUMBER DEFAULT NULL,
      psseguro_d IN NUMBER DEFAULT NULL,
      pseqcaja_o IN NUMBER DEFAULT NULL,
      psperson IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := '';
      vobject        VARCHAR2(200) := 'pac_iax_caja.f_apunte_pago_spl';
   BEGIN
      vpasexec := 2;
      vnumerr := pac_md_ctacliente.f_apunte_pago_spl(pcempres, psseguro, pimporte, pncheque,
                                                     pcestchq, pcbanco, pccc, pctiptar,
                                                     pntarget, pfcadtar, pcmedmov, pcmoneop,
                                                     pnrefdeposito, pcautoriza, pnultdigtar,
                                                     pncuotas, pccomercio, pdsbanco, pctipche,
                                                     pctipched, pcrazon, pdsmop, pfautori,
                                                     pcestado, psseguro_d, pseqcaja_o,
                                                     psperson, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 2;
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_apunte_pago_spl;

   --Bug 33886/199825 ACL
   FUNCTION f_lee_ult_re(pnpoliza IN seguros.npoliza%TYPE, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' NPOLIZA =' || pnpoliza;
      vobject        VARCHAR2(200) := 'pac_iax_ctacliente.f_lee_ult_re';
      cur            sys_refcursor;
      v_sseguro      NUMBER;
   BEGIN
      cur := pac_md_ctacliente.f_lee_ult_re(pnpoliza, mensajes);
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

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_lee_ult_re;

   -- Funcion que genera un recibo de gasto cuando se supere el max No de devoluciones
   FUNCTION f_crea_rec_gasto(
      psseguro IN seguros.sseguro%TYPE,
      pimonto IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8);
      vparam         VARCHAR2(2000) := 'psseguro = ' || psseguro || ' pimonto = ' || pimonto;
      terror         VARCHAR2(2000);
      vobject        VARCHAR2(200) := 'PAC_IAX_CAJA.f_crea_rec_gasto';
      num_err        axis_literales.slitera%TYPE := 0;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL
         OR pimonto IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      num_err := pac_md_ctacliente.f_crea_rec_gasto(psseguro, pimonto, mensajes);

      IF num_err != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN num_err;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL,
                                           f_axis_literales(9901094, gidioma));
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
   END f_crea_rec_gasto;

   --Bug 33886/199825    ACL
   FUNCTION f_upd_nre(
      pcempres IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pnnumlin IN NUMBER,
      pnreembo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'CEMPRES = ' || pcempres || ' SPERSON = ' || psperson || ' SSEGURO =' || psseguro
            || ' nnumlin = ' || pnnumlin;
      vobject        VARCHAR2(200) := 'pac_iax_ctacliente.f_upd_nre';
   BEGIN
      vnumerr := pac_md_ctacliente.f_upd_nre(pcempres, psperson, psseguro, pnnumlin, pnreembo,
                                             mensajes);
      vpasexec := 2;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnumerr, vpasexec, vparam);
         RETURN vnumerr;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_upd_nre;

   -- Bug 33886/202377
   -- Función que recupera el numero de reembolsos de una poliza
   FUNCTION f_get_nroreembolsos(
      psseguro IN caja_datmedio.sseguro%TYPE,
      pnumreembo OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8);
      vparam         VARCHAR2(2000) := 'psseguro = ' || psseguro;
      terror         VARCHAR2(2000);
      vobject        VARCHAR2(200) := 'PAC_IAX_CTACLIENTE.f_get_nroreembolsos';
      num_err        axis_literales.slitera%TYPE := 0;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      num_err := pac_md_ctacliente.f_get_nroreembolsos(psseguro, pnumreembo, mensajes);

      IF num_err != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN num_err;
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
   END f_get_nroreembolsos;

   -- Bug 33886/202377
   -- Función que actualiza el numero de reembolsos de una poliza
   FUNCTION f_actualiza_nroreembol(
      psseguro IN caja_datmedio.sseguro%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8);
      vparam         VARCHAR2(2000) := 'psseguro = ' || psseguro;
      terror         VARCHAR2(2000);
      vobject        VARCHAR2(200) := 'PAC_IAX_CTACLIENTE.f_actualiza_nroreembol';
      num_err        axis_literales.slitera%TYPE := 0;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      num_err := pac_md_ctacliente.f_actualiza_nroreembol(psseguro, mensajes);

      IF num_err != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN num_err;
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
   END f_actualiza_nroreembol;

   FUNCTION f_obtener_movimientos_cmovimi6(pseqcaja IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := ' pseqcaja= ' || pseqcaja;
      vobject        VARCHAR2(200) := 'PAC_IAX_CTACLIENTE.f_obtener_movimientos_cmovimi6';
      reg_seg        seguros%ROWTYPE;
      v_norden       NUMBER;
      datctaseg      sys_refcursor;
   BEGIN
      IF pseqcaja IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      numerr := pac_md_ctacliente.f_obtener_movimientos_cmovimi6(pseqcaja, datctaseg, mensajes);

      IF numerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN datctaseg;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, numerr, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_obtener_movimientos_cmovimi6;
END pac_iax_ctacliente;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_CTACLIENTE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CTACLIENTE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CTACLIENTE" TO "PROGRAMADORESCSI";
