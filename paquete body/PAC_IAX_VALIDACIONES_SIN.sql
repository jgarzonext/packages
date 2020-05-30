--------------------------------------------------------
--  DDL for Package Body PAC_IAX_VALIDACIONES_SIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_VALIDACIONES_SIN" AS
   /******************************************************************************
      NOMBRE:      PAC_IAX_VALIDACIONES_SIN
      PROP¿SITO: Funciones para la validaci¿n de siniestros

      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  ---------------  ------------------------------------
      1.0        17/02/2009   XPL i XVM          1. Creaci¿n del package.
      2.0        02/02/2010   AMC                2. Bug 12207. Se a¿ade la funci¿n f_calcimporteres
      3.0        27/05/2010   AMC                3. Bug 14608 .Se a¿aden nuevos parametros  a f_detpago
      4.0        07/06/2010   AMC                4. Bug 15260 .Se a¿aden los campos pccompani y pcpolcia a f_trasini
      5.0        10/08/2010   JRH                5. BUG 0015669 : Campos nuevos
      6.0        26/10/2010   ICV                6. 0016280: GRC - Gesti¿n de siniestro. Modificaci¿n de pago II
      7.0        04/08/2011   ICV                7. 0019172: SIN - Transiciones de estados de pagos permitidas
      8.0        29/09/2011   JMC                8. 0019601: LCOL_S001-SIN - Subestado del pago
      9.0        16/01/2012   JMP                9. 0018423: LCOL705 - Multimoneda
     10.0        24/01/2012   JMP               10. 0020014: LCOL_S001-SIN - Reservas y pagos en tramitaciones cerradas
     11.0        16/05/2012   JMF               0022243 LCOL_S001-SIN - Impedir siniestros duplicados en el alta de siniestros (ID=4561)
     12.0        19/06/2012   JMF               0022108 MDP_S001-SIN - Movimiento de tr¿mites
     13.0        24/10/2012   JMF               0023826 MDP_S001-SIN - Presiniestros, ref_ext, y estimaci¿n reserva (Id=22769)
     14.0        13/08/2013   ASN             0025537: RSA000 - Gesti¿n de incidencias (0150927/0150917)
     15.0        24/03/2014   NSS             0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros
     16.0        09/04/2014   NSS               16. 0030935: POSPG500-Control de alta de siniestros duplicados seg¿n garant¿a
     17.0        22/04/2014   NSS               17. 0029989/165377: LCOL_S001-SIN - Rechazo de tramitaci¿n ¿nica
     18.0    23/06/2016   AP                CONF-85 Fecha Real de Ocurrencia
   ******************************************************************************/
   -- BUG 9020 - 10/03/2009 - XPL I XVM - Nou model de dades del Sinistre
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      FUNCTION f_cabecerasini
         Valida la cap¿alera del sinistre
         param in pfsinies     : data sinistre
         param in pfnotifi     : data notificaci¿
         param in pccausin     : codi causa sinistre
         param in pcmotsin     : codi motiu sinistre
         param in psseguro     : secuencia seguro
         -- BUG 0015669 - 08/2010 - JRH  -  Alta prestacions en forma de renda (PL)
         param IN pcnivel  : Nivel
         param IN psperson2 : Persona relacionada
         -- Fi BUG 0015669 - 08/2010 - JRH
         param IN pnsinies : numero siniestro -- Bug 0022243 - 22/05/2012 - JMF
         param IN pmodo    : modo pantalla    -- 24434:ASN:05/11/2012
         param IN pierit   : importe estimado -- 24434:ASN:05/11/2012
         param out mensajes    : missatges d'error
         return                : 0 -> Tot correcte
                                 1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_cabecerasini(pfsinies    IN DATE,
                           pfnotifi    IN DATE,
                           pccausin    IN NUMBER,
                           pcmotsin    IN NUMBER,
                           psseguro    IN NUMBER,
                           pcnivel     IN NUMBER DEFAULT NULL,
                           psperson2   IN NUMBER DEFAULT NULL,
                           pnsinies    IN NUMBER DEFAULT NULL,
                           pmodo       IN VARCHAR2, -- 24434:ASN:05/11/2012
                           piperit     IN NUMBER, -- 24434:ASN:05/11/2012
                           ptemaildec  IN VARCHAR2, -- 24869:NSS:11/12/2012
                           picapital   IN NUMBER, -- 24869:NSS:11/12/2012
                           pctipdec    IN NUMBER, -- 0025537:ASN:13/08/2013
                           ptgarantias IN t_iax_garansini, -- BUG 30935 - 09/04/2014 - NSS
                           pfechapp    IN DATE DEFAULT NULL, -- CONF-85 AP
                           mensajes    OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vobject  VARCHAR2(200) := 'PAC_IAX_VALIDACIONES_SIN.f_cabecerasini';
      vparam   VARCHAR2(500) := 'par¿metros - pfsinies: ' || pfsinies ||
                                ' pfnotifi:' || pfnotifi || ' pccausin:' ||
                                pccausin || ' pcmotsin:' || pcmotsin ||
                                ' psseguro:' || psseguro;
      num_err  NUMBER(10);
   BEGIN
      vpasexec := 2;
      num_err  := pac_md_validaciones_sin.f_cabecerasini(pfsinies,
                                                         pfnotifi,
                                                         pccausin,
                                                         pcmotsin,
                                                         psseguro,
                                                         pcnivel,
                                                         psperson2,
                                                         pnsinies,
                                                         pmodo,
                                                         piperit, -- 24434:ASN:05/11/2012
                                                         ptemaildec, -- 24869:NSS:11/12/2012
                                                         picapital, -- BUG 0024869 - 14/12/2012 - NSS
                                                         pctipdec, -- 0025537:ASN:13/08/2013
                                                         ptgarantias, -- BUG 30935 - 09/04/2014 - NSS
                                                         pfechapp, -- CONF-85 AP
                                                         mensajes);
      vpasexec := 3;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            vpasexec := 4;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_cabecerasini;

   /*************************************************************************
      FUNCTION f_movsini
         Valida el moviment del sinistre
         param in pcestsin     : codi estat sinistre
         param in pfestsin     : data estat sinistre
         param in pcunitra     : codi unitat tramitadora
         param in pctramitad   : codi tramitador
         param out mensajes    : missatges d'error
         return                : 0 -> Tot correcte
                                 1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_movsini(pcestsin   IN NUMBER,
                      pfestsin   IN DATE,
                      pcunitra   IN VARCHAR2,
                      pctramitad IN VARCHAR2,
                      mensajes   OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vobject  VARCHAR2(200) := 'PAC_IAX_VALIDACIONES_SIN.f_movsini';
      vparam   VARCHAR2(500) := 'par¿metros - pcestsin: ' || pcestsin ||
                                ' pfestsin:' || pfestsin || ' pcunitra:' ||
                                pcunitra || ' pctramitad:' || pctramitad;
      num_err  NUMBER(10);
   BEGIN
      vpasexec := 2;
      num_err  := pac_md_validaciones_sin.f_movsini(pcestsin,
                                                    pfestsin,
                                                    pcunitra,
                                                    pctramitad,
                                                    mensajes);
      vpasexec := 3;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            vpasexec := 4;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_movsini;

   /*************************************************************************
      FUNCTION f_trasini
         Valida la tramitaci¿ del sinistre
         param in pctiptra  : Tipo tramitaci¿n
         param in pctcausin : Tipus dany
         param in pcinform  : Indicador tramitaci¿ informativa
         param in pttramita : Descripci¿n tramtiaci¿n
         param in pmarca    : Marca veh¿culo
         param in pmodel    : Modelo veh¿culo
         param in psperson  : Codi persona
         param in ptnomvia  : Nom via
         param in pcsiglas  : Siglas
         param in pcpoblac  : Codi poblaci¿
         param in pcprovin  : Codi provincia
         param in pcpais    : Codi pais
         param in ptdirec   : Descripci¿ direcci¿
         param in pccompani : C¿digo de la compa¿ia contraria
         param in pcpolcia  : Numero de p¿lizza contraria
         param out mensajes : missatges d'error
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error

         Bug 15260 - 07/06/2010 - AMC - Se a¿aden los campos pccompani y pcpolcia
   *************************************************************************/
   FUNCTION f_trasini(pctiptra  IN NUMBER,
                      pctcausin IN NUMBER,
                      pcinform  IN NUMBER,
                      pttramita IN VARCHAR2,
                      psperson  IN NUMBER,
                      pmarca    IN VARCHAR2,
                      pmodel    IN VARCHAR2,
                      ptnomvia  IN VARCHAR2,
                      pcsiglas  IN NUMBER,
                      pcpoblac  IN NUMBER,
                      pcprovin  IN NUMBER,
                      pcpais    IN NUMBER,
                      ptdirec   IN VARCHAR2,
                      pccompani IN NUMBER,
                      pcpolcia  IN VARCHAR2,
                      mensajes  OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vobject  VARCHAR2(200) := 'PAC_IAX_VALIDACIONES_SIN.f_trasini';
      vparam   VARCHAR2(2000) := 'par¿metros - pctiptra: ' || pctiptra ||
                                 ' pctcausin: ' || pctcausin ||
                                 ' pcinform:' || pcinform || ' pttramita: ' ||
                                 pttramita || ' psperson: ' || psperson ||
                                 ' pmarca: ' || pmarca || ' pmodel: ' ||
                                 pmodel || ' ptnomvia: ' || ptnomvia ||
                                 ' pcsiglas : ' || pcsiglas ||
                                 ' pcpoblac: ' || pcpoblac || ' pcprovin: ' ||
                                 pcprovin || ' pcpais: ' || pcpais ||
                                 ' ptdirec: ' || ptdirec || ' pccompani:' ||
                                 pccompani || ' pcpolcia:' || pcpolcia;
      num_err  NUMBER(10);
   BEGIN
      vpasexec := 2;
      num_err  := pac_md_validaciones_sin.f_trasini(pctiptra,
                                                    pctcausin,
                                                    pcinform,
                                                    pttramita,
                                                    psperson,
                                                    pmarca,
                                                    pmodel,
                                                    ptnomvia,
                                                    pcsiglas,
                                                    pcpoblac,
                                                    pcprovin,
                                                    pcpais,
                                                    ptdirec,
                                                    pccompani,
                                                    pcpolcia,
                                                    mensajes);
      vpasexec := 3;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            vpasexec := 4;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_trasini;

   /*************************************************************************
      FUNCTION f_movtrami
         Valida el moviment de tramitaci¿
         param in pnsinies  : n¿mero de sinistre
         param in pntramit  : n¿mero de tramitaci¿
         param in pcesttra  : estat tramitaci¿
         param in ppagos    : Tamany de l'objecte de pagaments (>0 hi han pagaments)
         param in pcsubtra  : Subestat tramitaci¿
         param out mensajes : missatges d'error
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_movtrami(pnsinies IN VARCHAR2,
                       pntramit IN NUMBER,
                       pcesttra IN NUMBER,
                       ppagos   IN NUMBER,
                       pcsubtra IN NUMBER DEFAULT NULL,
                       mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vobject  VARCHAR2(200) := 'PAC_IAX_VALIDACIONES_SIN.f_movtrami';
      vparam   VARCHAR2(500) := 'par¿metros - pnsinies: ' || pnsinies ||
                                ' pntramit:' || pntramit || ' pcesttra:' ||
                                pcesttra || ' pcsubtra : ' || pcsubtra;
      num_err  NUMBER(10);
   BEGIN
      vpasexec := 2;
      num_err  := pac_md_validaciones_sin.f_movtrami(pnsinies,
                                                     pntramit,
                                                     pcesttra,
                                                     ppagos,
                                                     pcsubtra,
                                                     mensajes);
      vpasexec := 3;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            vpasexec := 4;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_movtrami;

   /*************************************************************************
      FUNCTION f_loctrami
         Valida les dades de la direcci¿ del sinistre
         param in ptnomvia   : Nom via
         param in pcsiglas   : Siglas
         param in pcpoblac   : Codi poblaci¿
         param in pcprovin   : Codi provincia
         param in pcpais     : Codi pais
         param in ptdirec    : Descripci¿ direcci¿
         param out mensajes  : missatges d'error
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_loctrami(ptnomvia IN VARCHAR2,
                       pcsiglas IN NUMBER,
                       pcpoblac IN NUMBER,
                       pcprovin IN NUMBER,
                       pcpais   IN NUMBER,
                       ptdirec  IN VARCHAR2,
                       mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vobject  VARCHAR2(200) := 'PAC_IAX_VALIDACIONES_SIN.f_loctrami';
      vparam   VARCHAR2(500) := 'par¿metros - ptnomvia:' || ptnomvia ||
                                ' pcsiglas:' || pcsiglas || ' pcpoblac:' ||
                                pcpoblac || 'pcprovin:' || pcprovin ||
                                'pcpais:' || pcpais || 'ptdirecc:' ||
                                ptdirec;
      num_err  NUMBER(10);
   BEGIN
      vpasexec := 2;
      num_err  := pac_md_validaciones_sin.f_loctrami(ptnomvia,
                                                     pcsiglas,
                                                     pcpoblac,
                                                     pcprovin,
                                                     pcpais,
                                                     ptdirec,
                                                     mensajes);
      vpasexec := 3;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            vpasexec := 4;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_loctrami;

   /*************************************************************************
      FUNCTION f_dantrami
         Valida les dades dels danys d'un sinistre
         param in pnsinies  : n¿mero de sinistre
         param in pntramit  : n¿mero de tramitaci¿
         param in ptdano    : Descripci¿ dany
         param out mensajes : missatges d'error
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_dantrami(pnsinies IN VARCHAR2,
                       pntramit IN NUMBER,
                       ptdano   IN VARCHAR2,
                       mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vobject  VARCHAR2(200) := 'PAC_IAX_VALIDACIONES_SIN.f_dantrami';
      vparam   VARCHAR2(500) := 'par¿metros - pnsinies:' || pnsinies ||
                                ' pntramit:' || pntramit || ' ptdano:' ||
                                ptdano;
      num_err  NUMBER(10);
   BEGIN
      vpasexec := 2;
      num_err  := pac_md_validaciones_sin.f_dantrami(pnsinies,
                                                     pntramit,
                                                     ptdano,
                                                     mensajes);
      vpasexec := 3;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            vpasexec := 4;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_dantrami;

   /*************************************************************************
      FUNCTION f_dandettrami
         Valida les dades dels danys d'un sinistre
         param in pnsinies  : n¿mero de sinistre
         param in pntramit  : n¿mero de tramitaci¿
         param in pndano    : n¿mero de da¿o
         param in pndetdano : Tipus de dany (valor fixe: 0: Sin da¿os, 1: Secci¿n Delantera, etc)
         param out mensajes : missatges d'error
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_dandettrami(pnsinies  IN VARCHAR2,
                          pntramit  IN NUMBER,
                          pndano    IN NUMBER,
                          pndetdano IN NUMBER,
                          mensajes  OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vobject  VARCHAR2(200) := 'PAC_IAX_VALIDACIONES_SIN.f_dandettrami';
      vparam   VARCHAR2(500) := 'par¿metros - pnsinies:' || pnsinies ||
                                ' pntramit:' || pntramit || ' pndano:' ||
                                pndano || ' pndetdano:' || pndetdano;
      num_err  NUMBER(10);
   BEGIN
      vpasexec := 2;
      num_err  := pac_md_validaciones_sin.f_dandettrami(pnsinies,
                                                        pntramit,
                                                        pndano,
                                                        pndetdano,
                                                        mensajes);
      vpasexec := 3;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            vpasexec := 4;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_dandettrami;

   /*************************************************************************
      FUNCTION f_restrami
         Valida les dades de les reserves d'una tramitaci¿
         param in pnsinies  : N¿mero de sinistre
         param in pntramit  : N¿mero de tramitaci¿
         param in pccausa   : Codi causa
         param in pctipres  : Tipus de reserva
         param in pcgarant  : Codi garantia
         param in pccalres  : C¿lcul reserva
         param in pireserva : Import reserva
         param in picaprie  : Capital en risc
         param in pipenali  : Import penalitzaci¿
         param in pdinici   : Data inici
         param in pdfi      : Data fi
         param in pcmonres  : Moneda de la reserva
         param in ptorigen  : Pantalla que llama al alta de reservas
         param out mensajes : missatges d'error
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_restrami(pnsinies  IN VARCHAR2,
                       pntramit  IN NUMBER,
                       pccausa   IN NUMBER,
                       pctipres  IN NUMBER,
                       pcgarant  IN NUMBER,
                       pccalres  IN NUMBER,
                       pireserva IN NUMBER,
                       picaprie  IN NUMBER,
                       pipenali  IN NUMBER,
                       pdinici   IN DATE,
                       pdfi      IN DATE,
                       pcmonres  IN VARCHAR2, -- BUG 18423 - 16/01/2012 - JMP - Multimoneda
                       ptorigen  IN VARCHAR2, -- BUG 20014 - 24/01/2012 - JMP - LCOL_S001-SIN - Reservas y pagos en tramitaciones cerradas
                       pndias    IN NUMBER, -- 24708/162026 - 03/01/2014 - NSS - Validaciones garantia
                       mensajes  OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vobject  VARCHAR2(200) := 'PAC_IAX_VALIDACIONES_SIN.f_restrami';
      vparam   VARCHAR2(500) := 'par¿metros - pnsinies:' || pnsinies ||
                                ' pntramit:' || pntramit || ' pccausa:' ||
                                pccausa || ' pctipres:' || pctipres ||
                                ' pcgarant:' || pcgarant || ' pccalres:' ||
                                pccalres || ' pireserva:' || pireserva ||
                                ' picaprie:' || picaprie || ' pipenali:' ||
                                pipenali || ' pdinici:' || pdinici ||
                                ' pdfi:' || pdfi || ' pcmonres:' ||
                                pcmonres || ' ptorigen:' || ptorigen ||
                                ' pndias:' || pndias;
      num_err  NUMBER(10);
   BEGIN
      vpasexec := 2;
      num_err  := pac_md_validaciones_sin.f_restrami(pnsinies,
                                                     pntramit,
                                                     pccausa,
                                                     pctipres,
                                                     pcgarant,
                                                     pccalres,
                                                     pireserva,
                                                     picaprie,
                                                     pipenali,
                                                     pdinici,
                                                     pdfi,
                                                     pcmonres,
                                                     ptorigen,
                                                     pndias, -- 24708/162026 - 03/01/2014 - NSS - Validaciones garantia
                                                     mensajes);
      vpasexec := 3;

      -- se retorna el error en caso de que  num_err <>0 , no se mira el objeto mensajes para devolver el error(16683)
      IF num_err <> 0
      THEN
         vpasexec := 4;
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_restrami;

   /*************************************************************************
      FUNCTION f_dest
         Valida les dades del destinatari
         param in pnsinies  : N¿mero de sinistre
         param in pntramit  : N¿mero de tramitaci¿
         param in pccausa   : Codi causa
         param in pctipdes  : Tipus destinatari
         param in pcactpro  : Activitat professional
         param in psperson  : Codi persona
         param in ppasigna  : Percentatge assignaci¿
         param in pcpaisre  : Codi pa¿s resident
         param in pcbancar  : Codi Bancari
         -- BUG 0015669 - 08/2010 - JRH  -  Alta prestacions en forma de renda (PL)
         param IN  ctipcap : Tipo prestacion
         param IN  crelase : Relaci¿n con asegurado.
      -- Fi BUG 0015669 - 08/2010 - JRH
         param out mensajes : missatges d'error
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_dest(pnsinies IN VARCHAR2,
                   pntramit IN NUMBER,
                   pccausa  IN NUMBER,
                   pctipdes IN NUMBER,
                   pcactpro IN NUMBER,
                   psperson IN NUMBER,
                   ppasigna IN NUMBER,
                   pcpaisre IN NUMBER,
                   pcbancar IN VARCHAR2,
                   -- BUG 0015669 - 08/2010 - JRH  -  Alta prestacions en forma de renda (PL)
                   pctipcap IN NUMBER DEFAULT NULL,
                   pcrelase IN NUMBER DEFAULT NULL,
                   -- Fi BUG 0015669 - 08/2010 - JRH
                   mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vobject  VARCHAR2(200) := 'PAC_IAX_VALIDACIONES_SIN.f_dest';
      vparam   VARCHAR2(500) := 'par¿metros - pnsinies:' || pnsinies ||
                                ' pntramit:' || pntramit || ' pccausa:' ||
                                pccausa || ' pctipdes:' || pctipdes ||
                                ' pcactpro:' || pcactpro || ' psperson:' ||
                                psperson || ' ppasigna:' || ppasigna ||
                                ' pcpaisre:' || pcpaisre || ' pcbancar:' ||
                                pcbancar || ' ctipcap:' || pctipcap ||
                                ' crelase:' || pcrelase;
      num_err  NUMBER(10);
   BEGIN
      vpasexec := 2;
      num_err  := pac_md_validaciones_sin.f_dest(pnsinies,
                                                 pntramit,
                                                 pccausa,
                                                 pctipdes,
                                                 pcactpro,
                                                 psperson,
                                                 ppasigna,
                                                 pcpaisre,
                                                 pcbancar,
                                                 pctipcap,
                                                 pcrelase,
                                                 mensajes);
      vpasexec := 3;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            vpasexec := 4;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_dest;

   /*************************************************************************
      FUNCTION f_cabecerapago
         Valida les dades de la cap¿alera del pagament
         param in pnsinies  : N¿mero de sinistre
         param in pntramit  : N¿mero de tramitaci¿
         param in pctippag  : Codi tipus pagament
         param in pctipdes  : Tipus destinatari
         param in pcconpag  : Concepte pagament
         param in pccauind  : Causa indemnitzaci¿
         param in pcforpag  : Codi forma pagament
         param in pcbancar  : Codi Bancari
         param in pforden   : Data ordre
         param in psidepag  : Id. de pagament
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_cabecerapago(pnsinies IN VARCHAR2,
                           pntramit IN NUMBER,
                           pctippag IN NUMBER,
                           pctipdes IN NUMBER,
                           pcconpag IN NUMBER,
                           pccauind IN NUMBER,
                           pcforpag IN NUMBER,
                           pcbancar IN VARCHAR2,
                           pforden  IN DATE,
                           psidepag IN NUMBER DEFAULT NULL, --Bug.: 16280
                           mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vobject  VARCHAR2(200) := 'PAC_IAX_VALIDACIONES_SIN.f_cabecerapago';
      vparam   VARCHAR2(500) := 'par¿metros - pnsinies:' || pnsinies ||
                                ' pntramit:' || pntramit || ' pctippag:' ||
                                pctippag || ' pctipdes:' || pctipdes ||
                                ' pcconpag:' || pcconpag || ' pccauind:' ||
                                pccauind || ' pcforpag:' || pcforpag ||
                                ' pcbancar:' || pcbancar || ' pforden:' ||
                                pforden || ' psidepag : ' || psidepag;
      num_err  NUMBER(10);
   BEGIN
      vpasexec := 2;
      num_err  := pac_md_validaciones_sin.f_cabecerapago(pnsinies,
                                                         pntramit,
                                                         pctippag,
                                                         pctipdes,
                                                         pcconpag,
                                                         pccauind,
                                                         pcforpag,
                                                         pcbancar,
                                                         pforden,
                                                         psidepag,
                                                         mensajes);
      vpasexec := 3;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            vpasexec := 4;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_cabecerapago;

   /*************************************************************************
      FUNCTION f_movpago
         Valida els moviments d'un pagament
         param in psidepag  : Codi seq¿¿ncia pagament
         param in pcestpag  : Codi estat pagament
         param in pcestval  : Codi estat validaci¿
         param in pcsubpag  : C¿digo subestado pago
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_movpago(psidepag IN NUMBER,
                      pcestpag IN NUMBER,
                      pcestval IN NUMBER,
                      pcsubpag IN NUMBER, --bug:19601 - 29/09/2011 - JMC
                      mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vobject  VARCHAR2(200) := 'PAC_IAX_VALIDACIONES_SIN.f_movpago';
      vparam   VARCHAR2(500) := 'par¿metros - psidepag:' || psidepag ||
                                ' pcestpag:' || pcestpag || ' pcestval:' ||
                                pcestval || ' pcsubpag:' || pcsubpag;
      num_err  NUMBER(10);
   BEGIN
      vpasexec := 2;
      num_err  := pac_md_validaciones_sin.f_movpago(psidepag,
                                                    pcestpag,
                                                    pcestval,
                                                    pcsubpag,
                                                    mensajes);
      vpasexec := 3;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            vpasexec := 4;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_movpago;

   /*************************************************************************
      FUNCTION f_detpago
         Valida els detalls d'un pagament
         param in pnsinies  : N¿mero sinistre
         param in pireserva : Importe reserva
         param in pisinret  : Importe sin retenci¿n
         param in piiva     : Importe IVA
         param in piretenc  : Importe brut
         param in pfperini  : Fecha inicio
         param in pfperfin  : Fecha fin
         param in piresrcm  : Import Rendiment obligatori
         param in piresred  : Import Rendiment Redu¿t obligatori
         param in pctipres  : Tipo de reserva
         param in pcgarant  : Codigo de la garantia
         param in pctippag  : Tipo de pago
         param in pcmonres  : Moneda de la reserva contra la que va el pago
         param in psidepag  : Id. del pago
         param out mensajes : Mansajes de error
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error

      Bug 14608 - 27/05/2010 - AMC - Se a¿aden nuevos parametros
   *************************************************************************/
   FUNCTION f_detpago(pnsinies  IN VARCHAR2,
                      pireserva IN NUMBER,
                      pisinret  IN NUMBER,
                      piiva     IN NUMBER,
                      piretenc  IN NUMBER,
                      pfperini  IN DATE,
                      pfperfin  IN DATE,
                      piresrcm  IN NUMBER,
                      piresred  IN NUMBER,
                      pctipres  IN NUMBER,
                      pcgarant  IN NUMBER,
                      pctippag  IN NUMBER,
                      pcmonres  IN VARCHAR2, -- BUG 18423 - 16/01/2012 - JMP
                      psidepag  IN NUMBER, -- BUG 18423 - 16/01/2012 - JMP
                      pctipgas  IN NUMBER, --27909:NSS:03/09/2013
                      pcconpag  IN NUMBER, --27909:NSS:03/09/2013
                      pnmovres  IN NUMBER, --BUG 31294/174788:NSS:29/05/2014
                      pnorden   IN NUMBER, --BUG 31294/174788:NSS:29/05/2014
                      pireteiva IN NUMBER, --BUG 24637/147756:NSS:29/05/2014
                      pireteica IN NUMBER, --BUG 24637/147756:NSS:29/05/2014
                      mensajes  OUT t_iax_mensajes,
                      pitotimp  IN NUMBER DEFAULT NULL, --bug 24637/147756:NSS:14/03/2014
                      pitotret  IN NUMBER DEFAULT NULL, --bug 24637/147756:NSS:21/03/2014
                      piotrosgas IN NUMBER DEFAULT NULL,
                      pibaseipoc IN NUMBER DEFAULT NULL,
                      piipoconsumo IN NUMBER DEFAULT NULL
                      ) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vobject  VARCHAR2(200) := 'PAC_IAX_VALIDACIONES_SIN.f_detpago';
      vparam   VARCHAR2(500) := 'par¿metros - pnsinies:' || pnsinies ||
                                ' pireserva:' || pireserva || ' pisinret:' ||
                                pisinret || ' piiva:' || piiva ||
                                ' piretenc:' || piretenc || ' pfperini:' ||
                                pfperini || ' pfperfin:' || pfperfin ||
                                ' piresrcm:' || piresrcm || ' piresred:' ||
                                piresred || ' pctipres:' || pctipres ||
                                ' pcgarant:' || pcgarant || ' pctippag:' ||
                                pctippag || ' pctipgas:' || pctipgas ||
                                ' pcconpag:' || pcconpag || ' pitotimp:' ||
                                pitotimp || ' pitotret:' || pitotret ||
                                ' pnorden:' || pnorden || ' pnmovres:' ||
                                pnmovres || ' pireteiva: ' || pireteiva ||
                                ' pireteica: ' || pireteica;
      num_err  NUMBER(10);
   BEGIN
      vpasexec := 2;
      num_err  := pac_md_validaciones_sin.f_detpago(pnsinies,
                                                    pireserva,
                                                    pisinret,
                                                    piiva,
                                                    piretenc,
                                                    pfperini,
                                                    pfperfin,
                                                    piresrcm,
                                                    piresred,
                                                    pctipres,
                                                    pcgarant,
                                                    pctippag,
                                                    pcmonres,
                                                    psidepag,
                                                    pctipgas,
                                                    pcconpag, --27909:NSS:03/09/2013
                                                    pnmovres, --BUG 31294/174788:NSS:29/05/2014
                                                    pnorden, --BUG 31294/174788:NSS:29/05/2014
                                                    pireteiva, --BUG 24637/147756:NSS:29/05/2014
                                                    pireteica, --BUG 24637/147756:NSS:29/05/2014
                                                    mensajes,
                                                    pitotimp, --bug 24637/147756:NSS:14/03/2014
                                                    pitotret, --bug 24637/147756:NSS:21/03/2014
                                                    piotrosgas,
                                                    pibaseipoc,
                                                    piipoconsumo
                                                    );
      vpasexec := 3;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            vpasexec := 4;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_detpago;

   /*************************************************************************
      FUNCTION f_agenda
         Valida l'agenda
         param in pctipreg  : Codi tipo registro
         param in pcmanual  : Codi manual
         param in pcestage  : Codi estat agenda
         param in pffinage  : Data finalitzaci¿
         param in pcestage  : T¿tol
         param in ptlinage  : Descripci¿
         param in psidepag  : Seq¿¿ncia pagament
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_agenda(pctipreg IN NUMBER,
                     pcmanual IN NUMBER,
                     pcestage IN NUMBER,
                     pffinage IN DATE,
                     pttitage IN VARCHAR2,
                     ptlinage IN VARCHAR2,
                     psidepag IN NUMBER,
                     mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vobject  VARCHAR2(200) := 'PAC_IAX_VALIDACIONES_SIN.f_agenda';
      vparam   VARCHAR2(500) := 'par¿metros - pctipreg:' || pctipreg ||
                                ' pcmanual:' || pcmanual || ' pcestage:' ||
                                pcestage || ' pffinage:' || pffinage ||
                                ' pttitage:' || pttitage || ' ptlinage:' ||
                                ptlinage;
      num_err  NUMBER(10);
   BEGIN
      vpasexec := 2;
      num_err  := pac_md_validaciones_sin.f_agenda(pctipreg,
                                                   pcmanual,
                                                   pcestage,
                                                   pffinage,
                                                   pttitage,
                                                   ptlinage,
                                                   psidepag,
                                                   mensajes);
      vpasexec := 3;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            vpasexec := 4;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_agenda;

   /*************************************************************************
      FUNCTION f_calcimporteres
         Valida los parametros para poder calcular el importe de la reserva
         param in pctipres  : Codi tipo reserva
         param in pcgarang  : Codigo de la garantia
         param in pfresini  : Fecha de inicio reserva
         param in pfresfin  : Fecha fin de reserva
         param in psproduc  : C¿digo del producto
         mensajes           : Mensajes de error
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_calcimporteres(pctipres IN NUMBER,
                             pcgarant IN NUMBER,
                             pfresini IN DATE,
                             pfresfin IN DATE,
                             psproduc IN NUMBER,
                             mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vobject  VARCHAR2(200) := 'PAC_IAX_VALIDACIONES_SIN.f_calcimporteres';
      vparam   VARCHAR2(500) := 'par¿metros - pctipres:' || pctipres ||
                                ' pcgarant:' || pcgarant || ' pfresini:' ||
                                pfresini || ' pfresfin:' || pfresfin ||
                                ' psproduc:' || psproduc;
      num_err  NUMBER(10);
   BEGIN
      num_err := pac_md_validaciones_sin.f_calcimporteres(pctipres,
                                                          pcgarant,
                                                          pfresini,
                                                          pfresfin,
                                                          psproduc,
                                                          mensajes);

      IF num_err <> 0
      THEN
         RETURN 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_calcimporteres;

   -- BUG 0015669 - 08/2010 - JRH  -  Alta prestacions en forma de renda (PL)

   /*************************************************************************
          FUNCTION f_prest
         Valida les dades de la prestaci¿ en forma de renda
         param in pnsinies  : N¿mero de sinistre
         param in pntramit  : N¿mero de tramitaci¿
         param in psperson  : Codi persona
         param in pctipdes  : Tipus destinatari
         param in psseguro  : Sseguro
                  param in F1PAREN  : Fecha primera renta
        param in FUPAREN   : Fecha ultima renta
        param in CFORPAG : Forma pago renta
        param in IBRUREN   :Importe renta
        param in CREVALI   : Tipo revalorizaci¿n
        param in PREVALI   : % revalorizaci¿n
        param in IREVALI   : Importe revalorizaci¿n
        param in CTIPDUR   : Tipo duraci¿n
        param in NPARTOT : Participaciones inciales
        param in CTIPBAN   : Tipo Banc
        param in CBANCAR   :Cuenta
         param out mensajes : missatges d'error
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_prest(pnsinies IN VARCHAR2,
                    pntramit IN NUMBER,
                    psperson IN NUMBER,
                    pctipdes IN NUMBER,
                    psseguro IN NUMBER,
                    pf1paren IN DATE,
                    pfuparen IN DATE,
                    pcforpag IN NUMBER,
                    pibruren IN NUMBER,
                    pcrevali IN NUMBER,
                    pprevali IN NUMBER,
                    pirevali IN NUMBER,
                    pctipdur IN NUMBER,
                    pnpartot IN NUMBER,
                    pctipban IN NUMBER,
                    pcbancar IN VARCHAR2,
                    pcestado IN NUMBER,
                    pcmotivo IN NUMBER,
                    pcblopag IN NUMBER,
                    pnpresta IN NUMBER,
                    mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vobject  VARCHAR2(200) := 'PAC_IAX_VALIDACIONES_SIN.f_prest';
      vparam   VARCHAR2(2000) := 'par¿metros - pnsinies:' || pnsinies ||
                                 ' pntramit:' || pntramit || ' psseguro:' ||
                                 psseguro || ' pctipdes:' || pctipdes ||
                                 ' F1PAREN:' ||
                                 TO_CHAR(pf1paren, 'DD/MM/YYYY') ||
                                 ' psperson:' || psperson || ' FUPAREN:' ||
                                 TO_CHAR(pfuparen, 'DD/MM/YYYY') ||
                                 ' CFORPAG:' || pcforpag || ' IBRUREN:' ||
                                 pibruren || ' CREVALI:' || pcrevali ||
                                 ' PREVALI:' || pprevali || ' CTIPDUR:' ||
                                 pctipdur || ' NPARTOT:' || pnpartot ||
                                 ' CTIPBAN:' || pctipban || ' pcbancar:' ||
                                 pcbancar || ' PNPRESTA:' || pnpresta;
      num_err  NUMBER(10);
   BEGIN
      vpasexec := 2;
      num_err  := pac_md_validaciones_sin.f_prest(pnsinies,
                                                  pntramit,
                                                  psperson,
                                                  pctipdes,
                                                  psseguro,
                                                  pf1paren,
                                                  pfuparen,
                                                  pcforpag,
                                                  pibruren,
                                                  pcrevali,
                                                  pprevali,
                                                  pirevali,
                                                  pctipdur,
                                                  pnpartot,
                                                  pctipban,
                                                  pcbancar,
                                                  pcestado,
                                                  pcmotivo,
                                                  pcblopag,
                                                  pnpresta,
                                                  mensajes);
      vpasexec := 3;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            vpasexec := 4;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_prest;

   /*************************************************************************
      FUNCTION f_movtramte
         Valida el moviment de tramitaci¿
         param in pnsinies  : n¿mero de sinistre
         param in pNTRAMTE  : n¿mero de tramitaci¿
         param in pCESTTTE  : estat tramitaci¿
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
        -- Bug 0022108 - 19/06/2012 - JMF
   *************************************************************************/
   FUNCTION f_movtramte(pnsinies IN VARCHAR2,
                        pntramte IN NUMBER,
                        pcesttte IN NUMBER,
                        mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vobject  VARCHAR2(200) := 'PAC_IAX_VALIDACIONES_SIN.f_movtramte';
      vparam   VARCHAR2(500) := 'par¿metros - pnsinies: ' || pnsinies ||
                                ' pNTRAMTE:' || pntramte || ' pCESTTTE:' ||
                                pcesttte;
      num_err  NUMBER(10);
   BEGIN
      vpasexec := 2;
      num_err  := pac_md_validaciones_sin.f_movtramte(pnsinies,
                                                      pntramte,
                                                      pcesttte,
                                                      mensajes);
      vpasexec := 3;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            vpasexec := 4;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_movtramte;

   /*************************************************************************
      FUNCTION f_valpresiniestro
         Valida pre-siniestro
         param in vgobsiniestro: objecte siniestres
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
        -- Bug 0023826 - 08/10/2012 - JMF
   *************************************************************************/
   FUNCTION f_valpresiniestro(vgobsiniestro IN ob_iax_siniestros,
                              mensajes      OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vobject  VARCHAR2(200) := 'PAC_IAX_VALIDACIONES_SIN.f_valpresiniestro';
      vparam   VARCHAR2(500) := NULL;
      num_err  NUMBER(10);
   BEGIN
      vpasexec := 2;
      num_err  := pac_md_validaciones_sin.f_valpresiniestro(vgobsiniestro,
                                                            mensajes);

      IF NVL(num_err, 0) <> 0
      THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_valpresiniestro;

   /*************************************************************************
      FUNCTION f_valida_declarante
         Comprueba si el declarante del siniestro es el adecuado para el tipo de garant¿a
         param in psseguro  : clave seguros
         param in pctipdec : tipo de declarante
         param in pcgarant   : c¿digo garantia seleccionada
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
      -- Bug 0027487 - 25/11/2013 - NSS
   *************************************************************************/
   FUNCTION f_valida_declarante(psseguro IN NUMBER,
                                pctipdec IN NUMBER,
                                pcgarant IN NUMBER,
                                mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      vobject  VARCHAR2(200) := 'PAC_MD_VALIDACIONES_SIN.f_valida_declarante';
      vparam   VARCHAR2(500) := 'parametros - psseguro:' || psseguro ||
                                'pctipdec:' || pctipdec || ' pcgarant:' ||
                                pcgarant;
      num_err  NUMBER(10);
      vpasexec NUMBER(8) := 1;
   BEGIN
      num_err  := pac_md_validaciones_sin.f_valida_declarante(psseguro,
                                                              pctipdec,
                                                              pcgarant,
                                                              mensajes);
      vpasexec := 2;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            vpasexec := 4;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_valida_declarante;

   /*************************************************************************
      FUNCTION f_valida_garantia
         Comprueba validaciones propias de la garantia seleccionada
         param in psseguro  : clave seguros
         param in pcgarant   : c¿digo garantia seleccionada
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
      -- Bug 0024708/162026- 31/12/2013 - NSS
   *************************************************************************/
   FUNCTION f_valida_garantia(psseguro IN NUMBER,
                              pnriesgo IN NUMBER,
                              pcgarant IN NUMBER,
                              pndias   IN NUMBER,
                              pfsinies IN DATE,
                              pfresini IN DATE,
                              pfresfin IN DATE,
                              porigen  IN VARCHAR2,
                              mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      vobject  VARCHAR2(200) := 'PAC_MD_VALIDACIONES_SIN.f_valida_garantia';
      vparam   VARCHAR2(500) := 'parametros - psseguro:' || psseguro ||
                                ' pcgarant:' || pcgarant || ' pnriesgo:' ||
                                pnriesgo || ' pndias:' || pndias ||
                                ' pfsinies:' || pfsinies || ' pfresini:' ||
                                pfresini || ' pfresfin:' || pfresfin ||
                                ' porigen:' || porigen;
      num_err  NUMBER(10);
      vpasexec NUMBER(8) := 1;
   BEGIN
      num_err  := pac_md_validaciones_sin.f_valida_garantia(psseguro,
                                                            pnriesgo,
                                                            pcgarant,
                                                            pndias,
                                                            pfsinies,
                                                            pfresini,
                                                            pfresfin,
                                                            porigen,
                                                            mensajes);
      vpasexec := 2;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            vpasexec := 4;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_valida_garantia;

   /*************************************************************************
      FUNCTION f_valida_ult_tra
         Comprueba si es la ¿ltima tramitacion abierta del siniestro
         param in pnsinies  : c¿di sinistre
         param in pntramit   : N¿mero de tramitaci¿
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
      -- Bug 0029989/165377- 13/02/2014 - NSS
   *************************************************************************/
   FUNCTION f_valida_ult_tra(pnsinies IN VARCHAR2,
                             pntramit IN NUMBER,
                             ptlitera OUT axis_literales.tlitera%TYPE,
                             mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      vobjectname VARCHAR2(500) := 'pac_iax_validaciones_sin.f_valida_ult_tra';
      vparam      VARCHAR2(500) := 'par¿metros - pnsinies: ' || pnsinies ||
                                   ' pntramit: ' || pntramit ||
                                   ' ptlitera: ' || ptlitera;
      vpasexec    NUMBER(2) := 1;
      vnumerr     NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_validaciones_sin.f_valida_ult_tra(pnsinies,
                                                          pntramit,
                                                          ptlitera,
                                                          mensajes);

      IF vnumerr <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobjectname,
                                           1000006,
                                           vpasexec,
                                           vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobjectname,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           NULL,
                                           SQLCODE,
                                           SQLERRM);
         RETURN 1;
   END f_valida_ult_tra;

   /*************************************************************************
      FUNCTION f_val_aseg_innominado
         Comprueba validaciones propias del asegurado innominado
         param in psperson  : numero persona asegurado innominado
         param out pmensaje : mensaje de validacion
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
      -- Bug 0030882/171926- 04/04/2014 - NSS
   *************************************************************************/
   FUNCTION f_val_aseg_innominado(psperson IN NUMBER,
                                  pmensaje OUT VARCHAR2,
                                  mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      vobject  VARCHAR2(200) := 'PAC_MD_VALIDACIONES_SIN.f_val_aseg_innominado';
      vparam   VARCHAR2(500) := 'parametros - psperson:' || psperson;
      num_err  NUMBER(10);
      vpasexec NUMBER(8) := 1;
   BEGIN
      num_err  := pac_md_validaciones_sin.f_val_aseg_innominado(psperson,
                                                                pmensaje,
                                                                mensajes);
      vpasexec := 2;

      IF mensajes IS NOT NULL
      THEN
         IF mensajes.count > 0
         THEN
            vpasexec := 4;
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_val_aseg_innominado;
END pac_iax_validaciones_sin;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_VALIDACIONES_SIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_VALIDACIONES_SIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_VALIDACIONES_SIN" TO "PROGRAMADORESCSI";
