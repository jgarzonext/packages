CREATE OR REPLACE PACKAGE BODY pac_iax_ws_siniestros AS
/******************************************************************************
   NOMBRE:       pac_iax_ws_siniestros
   PROPÓSITO:  Interficie para llamadas de Traspasos de creacion de Siniestros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        21/12/2009   JGM                1. Creación del package. Bug 10124
   2.0        29/09/2011   JMC                2. 0019601: LCOL_S001-SIN - Subestado del pago
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Función que sirve para aperturar un siniestro con su tramitación y reserva inicial pendiente.
        1.    PSPRODUC: Tipo numérico. Parámetro de entrada. Identificador del producto
        2.    PSSEGURO: Tipo numérico. Parámetro de entrada. Código de póliza.
        3.    PNRIESGO: Tipo numérico. Parámetro de entrada. Número de riesgo.
        4.    PCACTIVI: Tipo numérico. Parámetro de entrada. Identificador de activivad.
        5.    PFSINIES: Tipo Fecha. Parámetro de etnrada. Fecha de siniestro. Desde traspasos se llamará con la fecha de efecto del traspaso
        6.    PFNOTIFI: Tipo Fecha. Parámetro de entrada. Fecha de notificación del siniestro. Desde traspasos se llamará con la fecha de aceptación del traspaso.
        7.    PCCAUSIN:Tipo numérico. Parámetro de entrada. Código de causa del siniestro
        8.    PCMOTSIN:  Tipo numérico. Parámetro de entrada. Código de motivo del siniestro
        9.    PTSINIES: Tipo carácter. Parámetro de entrada.
        10.    PTZONAOCU: Tipo carácter. Parámetro de entrada.
        11.    PCGARANT: Tipo numérico. Parámetro de entrada. Garantía asignada al traspaso
        12.    PITRASPASO: Tipo numérico. Parámetro de entrada. Importe del traspaso.
        13.    MENSAJE: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.
   *************************************************************************/
   FUNCTION f_apertura_siniestro(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcactivi IN NUMBER,
      pfsinies IN DATE,
      pfnotifi IN DATE,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      ptsinies IN VARCHAR2,
      ptzonaocu IN VARCHAR2,
      pcgarant IN NUMBER,
      pitraspaso IN NUMBER,
      pnsinies OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vestsseguro    NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'pac_iax_ws_siniestros.f_apertura_siniestro';
      vfefecto       DATE;
      vmodfefe       NUMBER;
      vcmotmov       NUMBER;
      vnsinies       NUMBER;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr :=
         pac_iax_siniestros.f_set_objeto_cabecera_vida
                                (NULL,   --pnsinies IN VARCHAR2,
                                 psproduc, pcactivi, psseguro, pnriesgo, pfsinies, pfnotifi,
                                 pccausin, pcmotsin, NULL,   -- <--phsinies,
                                 NULL,   -- <--pcculpab,
                                 ptsinies, ptzonaocu, NULL,   -- <--pcmeddec,
                                 NULL,   -- <--pctipdec,
                                 NULL,   -- <--ptnomdec
                                 NULL,   -- <--ptnom1dec,
                                 NULL,   -- <--ptnom2dec,
                                 NULL,   -- <--ptape1dec,
                                 NULL,   -- <--ptape2dec,
                                 NULL,   -- <--ptteldec,
                                 NULL,   -- <--ptmovildec
                                 NULL,   --<--ptemaildec
                                 NULL,   -- <--pctipide,
                                 NULL,   -- <--pnnumide,
                                 NULL, NULL, NULL, NULL,   -- <-- pcagente IN NUMBER, -- Bug 21817 - MDS - 2/05/2012
                                 mensajes);
      vpasexec := 2;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      vnumerr :=
         pac_iax_siniestros.f_set_objeto_sintramireserva
            (pac_iax_siniestros.vgobsiniestro.nsinies,   -- JRH PRUEBA NULL, --pnsinies IN VARCHAR2,
             0,   -- <--pntramit,
             1,   -- <--pctipres,
             NULL,   -- <--pttipres,
             NULL,   -- <--pnmovres,
             pcgarant, 0,   -- <--pccalres,
             NULL,   -- <--pfmovres,
             NULL,   -- <--pcmonres,
             0,   -- <--pireserva,
             NULL,   -- <--pipago,
             NULL,   -- <--piingreso,
             NULL,   -- <--pirecobro,
             0,   -- <--picaprie,
             0,   -- <--pipenali,
             NULL,   -- <--pfresini,
             NULL,   -- <--pfresfin,
             NULL,   -- <--pfultpag,
             NULL,   -- <--psidepag,
             NULL,   -- <--psproces,
             NULL,   -- <--pfcontab,
             NULL,   -- piprerec
             NULL,   -- pctipgas
             NULL,   -- modo
             NULL,   -- ptorigen
             NULL,   -- pifranq Bug 27059:NSS:07/06/2013
             NULL,   -- ndias Bug 27487/159742:NSS:26/11/2013
             1,   -- cmovres Bug 0031294/0174788: NSS:26/05/2014
             NULL,   -- ptotimp Bug 26437/147756:NSS:17/01/2014
             mensajes);
      vpasexec := 4;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      vnumerr := pac_iax_siniestros.f_grabar_siniestro(pnsinies, mensajes);
      vpasexec := 6;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 7;
      RETURN vnumerr;
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
   END f_apertura_siniestro;

   FUNCTION f_pago_i_cierre_sin(
      pnsinies IN NUMBER,
      xproduc IN NUMBER,
      xcactivi IN NUMBER,
      psidepag IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vestsseguro    NUMBER;
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(500) := 'pnsinies=' || pnsinies || ' psidepag:' || psidepag;
      vobject        VARCHAR2(200) := 'pac_iax_ws_siniestros.f_pago_i_cierre_sin';
      v_cunitra      sin_movsiniestro.cunitra%TYPE;
      v_ctramitad    sin_movsiniestro.ctramitad%TYPE;
   BEGIN
      IF pnsinies IS NULL
         OR psidepag IS NULL
         OR xproduc IS NULL
         OR xcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_iax_siniestros.f_inicializasiniestro(xproduc, xcactivi, pnsinies,
                                                          mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vnumerr :=
         pac_iax_siniestros.f_set_obj_sintram_movpagrecob(0,   --ntramit
                                                          psidepag, NULL, 2,   --pagado
                                                          f_sysdate, 1,   --validado
                                                          NULL, 2, 0, 0, 0,   --Bug:19601 - 29/09/2011 - JMC
                                                          mensajes);   -- 'PAGO'

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      SELECT cunitra, ctramitad
        INTO v_cunitra, v_ctramitad
        FROM sin_movsiniestro
       WHERE nsinies = pnsinies
         AND nmovsin = (SELECT MAX(nmovsin)
                          FROM sin_movsiniestro
                         WHERE nsinies = pnsinies);

      vnumerr := pac_iax_siniestros.f_estado_siniestro(pnsinies, 1,   --Finalitzat,
                                                       1,   --Liquidació
                                                       v_cunitra, v_ctramitad, NULL, f_sysdate,NULL, --IAXIS 3663 AABC 12/04/2019 Adicion campo observacion
                                                       mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
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
   END f_pago_i_cierre_sin;
END pac_iax_ws_siniestros;
/