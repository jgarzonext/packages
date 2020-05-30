--------------------------------------------------------
--  DDL for Package Body PAC_IAX_PRESTAMOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_PRESTAMOS" AS
   /******************************************************************************
      NOMBRE:      PAC_IAX_PRESTAMOS
      PROPÃƒâ€œSITO:   Contiene las funciones de gestiÃƒÂ³n de los prestamos

      REVISIONES:
      Ver        Fecha        Autor             DescripciÃƒÂ³n
      ---------  ----------  ---------------  ------------------------------------
      1.0        28/09/2011   DRA               1. 0019238: LCOL_T001- PrÃƒÂ¨stecs de pÃƒÂ²lisses de vida
      2.0        19/09/2012   MDS               2. 0023749: LCOL_T001-Autoritzaci? de prestecs
      3.0        01/10/2012   MDS               3. 0023772: LCOL_T001-Reversi? de prestecs
      4.0        25/10/2012   MDS               4. 0024192: LCOL898-Modificacions Notificaci? recaudo CxC
      5.0        30/11/2012   AEG               5. 0024898: LCOL_T001-QT5354: Los prestamos que son cancelados o reversados no deben mostrarse en SIR para eventuales pagos de cuotas.
      6.0        30/11/2012   JRV              15. 0024448: LCOL_T001-LCOL - qtracker 5181 - Calcul venciments quadre amortitzaci?
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_get_lstprestamos(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psseguro=' || psseguro || ', pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRESTAMOS.f_get_lstprestamos';
      vnumerr        NUMBER := 0;
      cur            sys_refcursor;
   BEGIN
      vpasexec := 1;
      cur := pac_md_prestamos.f_get_lstprestamos(psseguro, pnriesgo, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 2;
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
   END f_get_lstprestamos;

   FUNCTION f_get_detprestamo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pctapres IN VARCHAR2,
      mensajes OUT t_iax_mensajes,
      pcuotadesc IN NUMBER DEFAULT 0,
      phastahoy IN NUMBER DEFAULT 0)
      RETURN ob_iax_prestamo IS
      --
      vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(100)
          := 'psseguro=' || psseguro || ', pnriesgo=' || pnriesgo || ', pctapres=' || pctapres;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRESTAMOS.f_get_detprestamo';
      vnumerr        NUMBER := 0;
      vobprest       ob_iax_prestamo := ob_iax_prestamo();
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;
      vobprest := pac_md_prestamos.f_get_detprestamo(psseguro, pnriesgo, pctapres, mensajes,
                                                     pcuotadesc, phastahoy);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 2;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN vobprest;
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
   END f_get_detprestamo;

   FUNCTION f_consulta_presta(
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pctapres IN VARCHAR2,
      pnnumide IN VARCHAR2,
      psnip IN VARCHAR2,
      pbuscar IN VARCHAR2,
      ptipoper IN NUMBER,
      pcactivi IN NUMBER,
      pfiltro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'pcramo=' || pcramo || ', psproduc=' || psproduc || ', pnpoliza=' || pnpoliza
            || ', pncertif=' || pncertif || ', pctapres=' || pctapres || ', pnnumide='
            || pnnumide || ', psnip=' || psnip || ', pbuscar=' || pbuscar || ', ptipoper='
            || ptipoper || ', pcactivi=' || pcactivi || ', pfiltro=' || pfiltro;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRESTAMOS.f_consulta_presta';
      cur            sys_refcursor;
   BEGIN
      vpasexec := 1;
      cur := pac_md_prestamos.f_consulta_presta(pcramo, psproduc, pnpoliza, pncertif,
                                                pctapres, pnnumide, psnip, pbuscar, ptipoper,
                                                pcactivi, pfiltro, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 2;
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
   END f_consulta_presta;

   FUNCTION f_consulta_lstprst(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pctapres IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
          := 'psseguro=' || psseguro || ', pnriesgo=' || pnriesgo || ', pctapres=' || pctapres;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRESTAMOS.f_consulta_lstprst';
      vnumerr        NUMBER := 0;
      cur            sys_refcursor;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      cur := pac_md_prestamos.f_consulta_lstprst(psseguro, pnriesgo, pctapres, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 3;
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
   END f_consulta_lstprst;

   FUNCTION f_get_prestamo(mensajes OUT t_iax_mensajes)
      RETURN ob_iax_prestamo IS
      --
      vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRESTAMOS.f_get_prestamo';
      vnumerr        NUMBER := 0;
      cur            sys_refcursor;
   BEGIN
      vpasexec := 1;
      RETURN pac_iax_prestamos.vgobprestamos;
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
   END f_get_prestamo;

   FUNCTION f_get_prestamos(
      pctipdoc IN NUMBER,
      ptdoc IN VARCHAR2,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pctapres IN VARCHAR2,
      mensajes OUT t_iax_mensajes,
      -- 2012/11/30 aeg BUG:0024898 se agrega el sig. parametro.
      pcestado IN NUMBER DEFAULT NULL,
      pcuotadesc IN NUMBER DEFAULT 0,
      phastahoy IN NUMBER DEFAULT 0)
      RETURN t_iax_prestamo IS
      --
      vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(500)
         := 'pctipdoc: ' || pctipdoc || ', ptdoc: ' || ptdoc || ', pnpoliza: ' || pnpoliza
            || ', pncertif: ' || pncertif || ', pctapres: ' || pctapres;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRESTAMOS.f_get_prestamos';
      vnumerr        NUMBER := 0;
      cur            sys_refcursor;
   BEGIN
      vpasexec := 1;

      IF pctipdoc IS NULL
         AND ptdoc IS NULL
         AND pnpoliza IS NULL
         AND pctapres IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- 2012/11/30 aeg BUG:0024898 se agrega parametro = 1 al llamado de la funcion.
      RETURN pac_md_prestamos.f_get_prestamos(pctipdoc, ptdoc, pnpoliza, NVL(pncertif, 0),
                                              pctapres, mensajes, pcestado, pcuotadesc,
                                              phastahoy);
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
   END f_get_prestamos;

   FUNCTION f_inicializa_prestamo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pctapres IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_prestamo IS
      --
      vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(500)
          := 'psseguro=' || psseguro || ', pnriesgo=' || pnriesgo || ', pctapres=' || pctapres;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRESTAMOS.f_inicializa_prestamo';
      vnumerr        NUMBER := 0;
      obprest        ob_iax_prestamo;
   BEGIN
      vpasexec := 1;
      obprest := pac_md_prestamos.f_get_detprestamo(psseguro, pnriesgo, pctapres, mensajes);

      IF mensajes IS NOT NULL THEN
         IF mensajes.COUNT > 0 THEN
            vpasexec := 2;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN obprest;
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
   END f_inicializa_prestamo;

   FUNCTION f_obtener_porcentaje(
      pfiniprest IN DATE,
      psproduc IN NUMBER,
      pinteres OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(500)
         := 'pfiniprest=' || pfiniprest || ', psproduc=' || psproduc || ', pinteres='
            || pinteres;
      vobject        VARCHAR2(200) := 'PAC_MD_PRESTAMOS.f_obtener_porcentaje';
      vnumerr        NUMBER := 0;
   BEGIN
      vpasexec := 1;
      vnumerr := pac_md_prestamos.f_obtener_porcentaje(pfiniprest, psproduc, pinteres,
                                                       mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
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
   END f_obtener_porcentaje;

   FUNCTION f_insertar_prestamo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pctapres IN VARCHAR2,
      pfiniprest IN DATE,
      pffinprest IN DATE,
      pffecpag IN DATE,
      picapital IN NUMBER,
      pcmoneda IN VARCHAR2,
      pporcen IN NUMBER,
      pctipo IN NUMBER,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR2,
      pf1cuota IN DATE,
      cforpag IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(200)
         := 'psseguro=' || psseguro || ', pnriesgo=' || pnriesgo || ', pctapres=' || pctapres
            || ', pfiniprest=' || pfiniprest || ', pffinprest=' || pffinprest || ', pffecpag='
            || pffecpag || ', picapital=' || picapital || ', pcmoneda=' || pcmoneda
            || ', pporcen=' || pporcen || ', pctipo=' || pctipo || ', pctipban=' || pctipban;
      vobject        VARCHAR2(100) := 'PAC_MD_PRESTAMOS.f_insertar_prestamo';
      vnumerr        NUMBER := 0;
   BEGIN
      vpasexec := 1;
      vnumerr := pac_md_prestamos.f_insertar_prestamo(psseguro, pnriesgo, pnmovimi, pctapres,
                                                      pfiniprest, pffinprest,
                                                      TRUNC(f_sysdate), picapital, pcmoneda,
                                                      pporcen, pctipo, pctipban, pcbancar,
                                                      pf1cuota, pffecpag, cforpag, mensajes);

      IF vnumerr <> 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      END IF;

      COMMIT;
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
   END f_insertar_prestamo;

   FUNCTION f_anula_prestamo(pctapres IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(500) := 'pctapres=' || pctapres;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRESTAMOS.f_anula_prestamo';
      vnumerr        NUMBER := 0;
   BEGIN
      vpasexec := 1;
      vnumerr := pac_md_prestamos.f_anula_prestamo(pctapres, mensajes);

      IF vnumerr <> 0 THEN
         ROLLBACK;
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
   END f_anula_prestamo;

-- Bug 24448/135145 LCOL_T001-LCOL - qtracker 5181 - Calcul venciments quadre amortitzaci?
   FUNCTION f_calc_demora_cuota(
      pcmoneda IN NUMBER,
      picapital IN NUMBER,
      pfvencim IN DATE,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfecha IN DATE,
      pidemora OUT NUMBER,
      mensajes IN OUT t_iax_mensajes,
      pforigen IN DATE)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(200)
         := 'pcmoneda=' || pcmoneda || ',picapital=' || picapital || ',pfvencim=' || pfvencim
            || ',psseguro=' || psseguro || ',psproduc=' || psproduc || ',pfecha=' || pfecha;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRESTAMOS.f_calc_demora_cuota';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmoneda IS NULL
         OR picapital IS NULL
         OR pfvencim IS NULL
         OR pfecha IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF psproduc IS NULL
         AND psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;
      vnumerr := pac_md_prestamos.f_calc_demora_cuota(pcmoneda, picapital, pfvencim, psseguro,
                                                      psproduc, pfecha, pidemora, mensajes,
                                                      pforigen);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
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
   END f_calc_demora_cuota;

   /*************************************************************************
       f_mov_prestamocuota
       Funcion para insertar movimiento en las cuotas del prestamo
       param in pctapres      : Identificador del prÃƒÂ©stamo
       param in pfinicua     : VersiÃƒÂ³n del cuadro
       param in picappend    : capital pendiente
       param in pfvencim        : Fecha vencimiento de la cuota
       param in pidpago     : identificador del pago
       param in pnlinea      : identificador de la linea
       param out psmovcuo    : Secuencia movimiento cuota
       return              : 0 (todo Ok)
                             <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_mov_prestamocuota(
      pctapres IN VARCHAR2,
      pfinicua IN DATE,
      picappend IN NUMBER,
      pfvencim IN DATE,
      pidpago IN NUMBER,
      pnlinea IN NUMBER,
      pfmovini IN DATE,
      pcestcuo IN NUMBER,
      psmovcuo OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pctapres=' || pctapres || ',pfinicua=' || pfinicua || ',picappend=' || picappend
            || ',pfvencim=' || pfvencim || ',pidpago=' || pidpago || ',pnlinea=' || pnlinea
            || ',pfmovini=' || pfmovini || ',pcestcuo=' || pcestcuo;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRESTAMOS.f_mov_prestamocuota';
      num_err        NUMBER;
   BEGIN
      IF pctapres IS NULL
         OR pfinicua IS NULL
         OR picappend IS NULL
         OR pfvencim IS NULL
         OR pidpago IS NULL
         OR pnlinea IS NULL
         OR pfmovini IS NULL
         OR pcestcuo IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_md_prestamos.f_mov_prestamocuota(pctapres, pfinicua, picappend, pfvencim,
                                                      pidpago, pnlinea, pfmovini, pcestcuo,
                                                      psmovcuo, mensajes);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
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
   END f_mov_prestamocuota;

   /*************************************************************************
       f_mov_prestamopago
       Funcion para insertar movimiento en el pago del prestamo
       param in pctapres      : Identificador del prÃƒÂ©stamo
       param in pnpago     : VersiÃƒÂ³n del cuadro
       param in pcestpag    : capital pendiente
       param in pcsubpag        : Fecha vencimiento de la cuota
       param in pfefecto     : identificador del pago
       param out pnmovpag    : NÃƒÂºmero de movimiento del pago
       return              : 0 (todo Ok)
                             <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_mov_prestamopago(
      pctapres IN VARCHAR2,
      pnpago IN NUMBER,
      pcestpag IN NUMBER,
      pcsubpag IN NUMBER,
      pfefecto IN DATE,
      pnmovpag OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pctapres=' || pctapres || ',pnpago=' || pnpago || ',pcestpag=' || pcestpag
            || ',pcsubpag=' || pcsubpag || ',pfefecto=' || pfefecto;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRESTAMOS.f_mov_prestamopago';
      num_err        NUMBER;
   BEGIN
      IF pctapres IS NULL
         OR pnpago IS NULL
         OR pcestpag IS NULL
         OR pcsubpag IS NULL
         OR pfefecto IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_md_prestamos.f_mov_prestamopago(pctapres, pnpago, pcestpag, pcsubpag,
                                                     pfefecto, pnmovpag, mensajes);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
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
   END f_mov_prestamopago;

   -- Ini Bug : 23749 - MDS - 19/09/2012
   /*************************************************************************
       f_mov_prestamos
       Función para insertar un movimiento de préstamos
       param in  pctapres  : Identificador del préstamo
       param in  pfalta    : Fecha de alta del préstamo
       param in  pcestado  : Nuevo estado actual del préstamo
       param in  pfmovini  : Fecha inicio de vigencia del nuevo estado
       param out psmovpres : Secuencia del nuevo movimiento
       return              : 0 (todo OK)
                             <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_mov_prestamos(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pcestado IN NUMBER,
      pfmovini IN DATE,
      psmovpres OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pctapres=' || pctapres || ',pfalta=' || pfalta || ',pcestado=' || pcestado
            || ',pfmovini=' || pfmovini;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRESTAMOS.f_mov_prestamos';
      num_err        NUMBER;
   BEGIN
      -- control de parámetros, todos son obligatorios
      IF pctapres IS NULL
         OR pfalta IS NULL
         OR pcestado IS NULL
         OR pfmovini IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_md_prestamos.f_mov_prestamos(pctapres, pfalta, pcestado, pfmovini,
                                                  psmovpres, mensajes);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      RETURN 0;
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
   END f_mov_prestamos;

   /*************************************************************************
       f_autorizar
       Función para autorizar un préstamo
       param in  pctapres    : Identificador del préstamo
       param in  pfalta      : Fecha de alta del préstamo
       param in  pfautoriza  : Fecha de autorización del préstamo
       param in  pnmovimi    : Número de movimiento
       param in  pffecpag    : Fecha de efecto del préstamo
       param in  picapital   : Capital del préstamo
       return                : 0 (todo OK)
                               <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_autorizar(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pfautoriza IN DATE,
      pnmovimi IN NUMBER,
      pffecpag IN DATE,
      picapital IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pctapres=' || pctapres || ',pfalta=' || pfalta || ',pfautoriza=' || pfautoriza
            || ',pnmovimi=' || pnmovimi || ',pffecpag=' || pffecpag || ',picapital='
            || picapital;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRESTAMOS.f_autorizar';
      num_err        NUMBER;
   BEGIN
      -- control de parámetros, todos son obligatorios excepto pnmovimi
      IF pctapres IS NULL
         OR pfalta IS NULL
         OR pfautoriza IS NULL
         OR pffecpag IS NULL
         OR picapital IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_md_prestamos.f_autorizar(pctapres, pfalta, pfautoriza, pnmovimi, pffecpag,
                                              picapital, mensajes);

      IF num_err <> 0 THEN
         ROLLBACK;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_autorizar;

-- Fin Bug : 23749 - MDS - 19/09/2012

   -- Ini Bug 23772 - MDS - 01/10/2012

   /*************************************************************************
       f_reversar_prestamo
       Función para reversar un préstamo
       param in  pctapres    : Identificador del préstamo
       param in  pfalta      : Fecha de alta del préstamo
       param in  pfrechaza   : Fecha de reversión del préstamo
       param in  pnmovimi    : Número de movimiento
       return                : 0 (todo OK)
                               <> 0 (ha habido algun error)
    *************************************************************************/
   FUNCTION f_reversar_prestamo(
      pctapres IN VARCHAR2,
      pfalta IN DATE,
      pfrechaza IN DATE,
      pnmovimi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pctapres=' || pctapres || ',pfalta=' || pfalta || ',pfrechaza=' || pfrechaza
            || ',pnmovimi=' || pnmovimi;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRESTAMOS.f_reversar_prestamo';
      num_err        NUMBER;
   BEGIN
      -- control de parámetros, todos son obligatorios excepto pnmovimi
      IF pctapres IS NULL
         OR pfalta IS NULL
         OR pfrechaza IS NULL THEN
         RAISE e_param_error;
      END IF;

      num_err := pac_md_prestamos.f_reversar_prestamo(pctapres, pfalta, pfrechaza, pnmovimi,
                                                      mensajes);

      IF num_err <> 0 THEN
         ROLLBACK;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_reversar_prestamo;

-- Fin Bug 23772 - MDS - 01/10/2012
   FUNCTION f_permite_reversar(
      pctapres IN VARCHAR2,
      psepermite OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pctapres=' || pctapres;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRESTAMOS.f_permite_reversar';
      num_err        NUMBER;
   BEGIN
      /*
      IF pctapres IS NULL THEN
         RAISE e_param_error;
      END IF;
      */
      num_err := pac_md_prestamos.f_permite_reversar(pctapres, psepermite, mensajes);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
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
   END f_permite_reversar;

-- Ini Bug 24192 - MDS - 25/10/2012
   /*************************************************************************
        f_reversarpagar_prestamo
        Función para reversar un préstamo
        param in pctapres       : Identificador del préstamo
        param in pfvalida       : Fecha de Reversión / Pago del préstamo
        param in ptipooperacion : Reversar / Pagar
        param out pnmovpag      : Número de movimiento del pago
        return : 0 (todo OK)
                                <> 0 (ha habido algun error)
     *************************************************************************/
   FUNCTION f_reversarpagar_prestamo(
      pctapres IN VARCHAR2,
      pfvalida IN DATE,
      ptipooperacion IN VARCHAR2,
      pnmovpag OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pctapres=' || pctapres || ',pfvalida=' || pfvalida || ',ptipooperacion='
            || ptipooperacion;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRESTAMOS.f_pfvalida_prestamo';
      num_err        NUMBER;
      vfalta         DATE;
   BEGIN
      -- control de parámetros,
      IF pctapres IS NULL
         OR pfvalida IS NULL
         OR ptipooperacion IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- Reversar préstamo
      IF ptipooperacion = 'R' THEN
         -- obtener el parámetro vfalta
         num_err := pac_md_prestamos.f_fecha_ult_prest(pctapres, vfalta, mensajes);

         IF num_err <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
            RAISE e_object_error;
         END IF;

         num_err := pac_md_prestamos.f_reversar_prestamo(pctapres, vfalta, pfvalida, NULL,
                                                         mensajes);
      END IF;

      -- Pagar préstamo
      IF ptipooperacion = 'P' THEN
         num_err := pac_md_prestamos.f_mov_prestamopago(pctapres, 1, 2, 1, pfvalida, pnmovpag,
                                                        mensajes);
      END IF;

      IF num_err <> 0 THEN
         ROLLBACK;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
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
   END f_reversarpagar_prestamo;

-- Fin Bug 24192 - MDS - 25/10/2012

   -- BUG:2448 AMJ 22/02/2013  LCOL_T001-LCOL - qtracker 5181 - Calcul venciments quadre amortitzaci?  Ini
   FUNCTION f_calc_demora_cuota_prorr(
      pcmoneda IN NUMBER,
      picapital IN NUMBER,
      pforigen IN DATE,
      pfvencim IN DATE,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfecha IN DATE,
      pidemora OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 0;
      vparam         VARCHAR2(200)
         := 'pcmoneda=' || pcmoneda || ',picapital=' || picapital || ',pforigen=' || pforigen
            || ',pfvencim=' || pfvencim || ',psseguro=' || psseguro || ',psproduc='
            || psproduc || ',pfecha=' || pfecha;
      vobject        VARCHAR2(200) := 'PAC_IAX_PRESTAMOS.f_calc_demora_cuota_prorr';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmoneda IS NULL
         OR picapital IS NULL
         OR pfvencim IS NULL
         OR pfecha IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;
      vnumerr := pac_md_prestamos.f_calc_demora_cuota_prorr(pcmoneda, picapital, pforigen,
                                                            pfvencim, psseguro, psproduc,
                                                            pfecha, pidemora, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
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
   END f_calc_demora_cuota_prorr;
-- BUG: 24448  11/03/2013  AMJ   Se hace la nota 140238 Fin
END pac_iax_prestamos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_PRESTAMOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PRESTAMOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PRESTAMOS" TO "PROGRAMADORESCSI";
