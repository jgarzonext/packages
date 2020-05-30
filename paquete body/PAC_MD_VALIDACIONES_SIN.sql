--------------------------------------------------------
--  DDL for Package Body PAC_MD_VALIDACIONES_SIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_VALIDACIONES_SIN" AS
   /******************************************************************************
      NOMBRE:      PAC_MD_VALIDACIONES_SIN
      PROP¿SITO: Funciones para la validaci¿n de siniestros

      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  ---------------  ------------------------------------
      1.0        17/02/2009   XPL i XVM        1. Creaci¿n del package.
      2.0        02/02/2010   AMC              2. Bug 12207. Se a¿ade la funci¿n f_calcimporteres
      3.0        27/05/2010   AMC              3. Bug 14608 .Se a¿aden nuevos parametros  a f_detpago
      4.0        07/06/2010   AMC              4. Bug 15260 .Se a¿aden los campos pccompani y pcpolcia a f_trasini
      5.0        10/08/2010   JRH              5. BUG 0015669 : Campos nuevos
      6.0        26/10/2010   ICV              6. 0016280: GRC - Gesti¿n de siniestro. Modificaci¿n de pago II
      7.0        11/01/2011   SMF              7. Se modifica los parametros  de f_restrami hacerslo de entrada / salida (16683)
      8.0        11/06/2011   SRA              8. 0018554: LCOL701 - Desarrollo de Modificaci¿n de datos cabecera siniestro y ver hist¿rico (BBDD).
      9.0        04/08/2011   ICV              9. 0019172: SIN - Transiciones de estados de pagos permitidas
     10.0        29/09/2011   JMC             10. 0019601: LCOL_S001-SIN - Subestado del pago
     11.0        16/01/2012   JMP             11. 0018423: LCOL705 - Multimoneda
     12.0        24/01/2012   JMP             12. 0020014: LCOL_S001-SIN - Reservas y pagos en tramitaciones cerradas
     13.0        16/05/2012   JMF             0022243 LCOL_S001-SIN - Impedir siniestros duplicados en el alta de siniestros (ID=4561)
     14.0        19/06/2012   JMF             0022108 MDP_S001-SIN - Movimiento de tr¿mites
     15.0        24/10/2012   JMF             0023826 MDP_S001-SIN - Presiniestros, ref_ext, y estimaci¿n reserva (Id=22769)
     16.0        13/08/2013   ASN             0025537: RSA000 - Gesti¿n de incidencias (0150927/0150917)
     17.0        24/03/2014   NSS             0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros
     18.0        09/04/2014   NSS             18. 0030935: POSPG500-Control de alta de siniestros duplicados seg¿n garant¿a
     19.0        22/04/2014   NSS             19. 0029989/165377: LCOL_S001-SIN - Rechazo de tramitaci¿n ¿nica
     20.0        23/06/2016    AP             20. CONF-85 Fecha real de ocurrencia
     21.0        06/05/2019   AABC            21. IAXIS 3597 PROCESO JUDICIAL
   ******************************************************************************/
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
         param IN piperit  : importe estimado -- 24434:ASN:05/11/2012
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
                           ptemaildec  IN VARCHAR2, -- 24869:ASN:11/12/2012
                           picapital   IN NUMBER, -- BUG 0024869 - 14/12/2012 - NSS
                           pctipdec    IN NUMBER, -- 0025537:ASN:13/08/2013
                           ptgarantias IN t_iax_garansini, -- BUG 30935 - 09/04/2014 - NSS
                           pfechapp    IN DATE DEFAULT NULL, -- CONF-85 AP
                           mensajes    IN OUT t_iax_mensajes) RETURN NUMBER IS
      num_err  NUMBER(10);
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'par¿metros - pfsinies: ' || pfsinies ||
                                ' pfnotifi:' || pfnotifi || ' pccausin:' ||
                                pccausin || ' pcmotsin:' || pcmotsin ||
                                ' psseguro:' || psseguro;
      vobject  VARCHAR2(200) := 'PAC_MD_VALIDACIONES_SIN.f_cabecerasini';
      vterror  VARCHAR2(1000);
   BEGIN
      -- Bug 28224/153119 - 19/09/2013 - AMC
      num_err := pac_propio.f_permite_alta_siniestro(psseguro,
                                                     NULL,
                                                     pfsinies,
                                                     pfnotifi);

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;

      -- Bug 0022243 - 22/05/2012 - JMF : a¿adir pnsinies
      num_err  := pac_validaciones_sin.f_cabecerasini(pfsinies,
                                                      pfnotifi,
                                                      pccausin,
                                                      pcmotsin,
                                                      psseguro,
                                                      pcnivel,
                                                      psperson2,
                                                      pnsinies,
                                                      pmodo,
                                                      piperit, -- 24434:ASN:05/11/2012
                                                      ptemaildec, -- 24869:ASN:11/12/2012
                                                      picapital, -- BUG 0024869 - 14/12/2012 - NSS
                                                      pctipdec, -- 0025537:ASN:13/08/2013
                                                      ptgarantias, -- BUG 30935 - 09/04/2014 - NSS
                                                      pfechapp, -- CONF-85 AP
                                                      vterror -- BUG 30935 - 09/04/2014 - NSS
                                                      );
      vpasexec := 2;

      IF num_err <> 0
      THEN
         IF num_err = 9906710
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                                 5,
                                                 num_err,
                                                 vterror);
            p_tab_error(f_sysdate,
                        f_user,
                        vobject,
                        vpasexec,
                        vparam,
                        vterror);
         ELSE
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
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
                      mensajes   IN OUT t_iax_mensajes) RETURN NUMBER IS
      num_err  NUMBER(10);
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'par¿metros - pcestsin: ' || pcestsin ||
                                ' pfestsin:' || pfestsin || ' pcunitra:' ||
                                pcunitra || ' pctramitad:' || pctramitad;
      vobject  VARCHAR2(200) := 'PAC_MD_VALIDACIONES_SIN.f_movsini';
   BEGIN
      num_err  := pac_validaciones_sin.f_movsini(pcestsin,
                                                 pfestsin,
                                                 pcunitra,
                                                 pctramitad);
      vpasexec := 2;

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
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
                      mensajes  IN OUT t_iax_mensajes) RETURN NUMBER IS
      num_err  NUMBER(10);
      vpasexec NUMBER(8) := 1;
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
      vobject  VARCHAR2(200) := 'PAC_MD_VALIDACIONES_SIN.f_trasini';
   BEGIN
      -- Bug 15260 - 07/06/2010 - AMC
      num_err := pac_validaciones_sin.f_trasini(pctiptra,
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
                                                pcpolcia);
      -- Fi Bug 15260 - 07/06/2010 - AMC
      vpasexec := 2;

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
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
   END f_trasini;

   /*************************************************************************
      FUNCTION f_movtrami
         Valida el moviment de tramitaci¿
         param in pnsinies  : n¿mero de sinistre
         param in pntramit  : n¿mero de tramitaci¿
         param in pcesttra  : estat tramitaci¿
         param in ppagos    : Tamany de l'objecte de pagaments (>0 hi han pagaments)
         param out mensajes : missatges d'error
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_movtrami(pnsinies IN VARCHAR2,
                       pntramit IN NUMBER,
                       pcesttra IN NUMBER,
                       ppagos   IN NUMBER,
                       pcsubtra IN NUMBER DEFAULT NULL,
                       mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      num_err  NUMBER(10);
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'par¿metros - pnsinies: ' || pnsinies ||
                                ' pntramit:' || pntramit || ' pcesttra:' ||
                                pcesttra || ' pcsubtra : ' || pcsubtra;
      vobject  VARCHAR2(200) := 'PAC_MD_VALIDACIONES_SIN.f_movtrami';
      -- IAXIS 3597 AABC 06/05/2019 PROCESO JUDICIAL
      p_mensajes VARCHAR2(200);
   BEGIN
      num_err  := pac_validaciones_sin.f_movtrami(pnsinies,
                                                  pntramit,
                                                  pcesttra,
                                                  ppagos,
                                                  pcsubtra);
      vpasexec := 2;

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
      END IF;
      -- IAXIS 3597 AABC 06/05/2019 PROCESO JUDICIAL
      num_err  := pac_avisos_conf.f_finsin_tramita_val_codbarras(pnsinies ,pntramit ,pcesttra ,pac_md_common.f_get_cxtidioma, p_mensajes );
      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
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
                       mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      num_err  NUMBER(10);
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'par¿metros - ptnomvia:' || ptnomvia ||
                                ' pcsiglas:' || pcsiglas || ' pcpoblac:' ||
                                pcpoblac || 'pcprovin:' || pcprovin ||
                                'pcpais:' || pcpais || 'ptdirecc:' ||
                                ptdirec;
      vobject  VARCHAR2(200) := 'PAC_MD_VALIDACIONES_SIN.f_loctrami';
   BEGIN
      num_err  := pac_validaciones_sin.f_loctrami(ptnomvia,
                                                  pcsiglas,
                                                  pcpoblac,
                                                  pcprovin,
                                                  pcpais,
                                                  ptdirec);
      vpasexec := 2;

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
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
   END f_loctrami;

   /*************************************************************************
      FUNCTION f_dantrami
         Valida les dades dels danys d'un sinistre
         param in pnsinies   : n¿mero de sinistre
         param in pntramit   : n¿mero de tramitaci¿
         param in ptdano     : Descripci¿ dany
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_dantrami(pnsinies IN VARCHAR2,
                       pntramit IN NUMBER,
                       ptdano   IN VARCHAR2,
                       mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      num_err  NUMBER(10);
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'par¿metros - pnsinies:' || pnsinies ||
                                ' pntramit:' || pntramit || ' ptdano:' ||
                                ptdano;
      vobject  VARCHAR2(200) := 'PAC_MD_VALIDACIONES_SIN.f_dantrami';
   BEGIN
      num_err  := pac_validaciones_sin.f_dantrami(pnsinies,
                                                  pntramit,
                                                  ptdano);
      vpasexec := 2;

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
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
   END f_dantrami;

   /*************************************************************************
      FUNCTION f_dandettrami
         Valida les dades dels danys d'un sinistre
         param in pnsinies   : n¿mero de sinistre
         param in pntramit   : n¿mero de tramitaci¿
         param in pndano     : n¿mero de da¿o
         param in pndetdano  : Tipus de dany (valor fixe: 0: Sin da¿os, 1: Secci¿n Delantera, etc)
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_dandettrami(pnsinies  IN VARCHAR2,
                          pntramit  IN NUMBER,
                          pndano    IN NUMBER,
                          pndetdano IN NUMBER,
                          mensajes  IN OUT t_iax_mensajes) RETURN NUMBER IS
      num_err  NUMBER(10);
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'par¿metros - pnsinies:' || pnsinies ||
                                ' pntramit:' || pntramit || ' pndano:' ||
                                pndano || ' pndetdano:' || pndetdano;
      vobject  VARCHAR2(200) := 'PAC_MD_VALIDACIONES_SIN.f_dandettrami';
   BEGIN
      num_err  := pac_validaciones_sin.f_dandettrami(pnsinies,
                                                     pntramit,
                                                     pndano,
                                                     pndetdano);
      vpasexec := 2;

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
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
                       mensajes  IN OUT t_iax_mensajes) RETURN NUMBER IS
      num_err  NUMBER(10);
      vpasexec NUMBER(8) := 1;
      v_inform NUMBER := 0;
      vtmsg    VARCHAR2(500);
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
      vobject  VARCHAR2(200) := 'PAC_MD_VALIDACIONES_SIN.f_restrami';
   BEGIN
      num_err  := pac_validaciones_sin.f_restrami(pnsinies,
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
                                                  v_inform,
                                                  pndias); -- 24708/162026 - 03/01/2014 - NSS - Validaciones garantia
      vpasexec := 2;

      IF v_inform <> 0
      THEN
         vpasexec := 3;
         vtmsg    := pac_iobj_mensajes.f_get_descmensaje(v_inform,
                                                         pac_md_common.f_get_cxtidioma);
         vpasexec := 4;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                              2,
                                              0,
                                              vtmsg || pnsinies);
      END IF;

      IF num_err <> 0
      THEN
         vpasexec := 5;

         -- ini Bug 0023826 - 24/10/2012 - JMF
         /*  IF num_err = 9903735 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, num_err);
         ELSE
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
            RAISE e_object_error;
         END IF;*/
         -- fin Bug 0023826 - 24/10/2012 - JMF

         -- Bug 27514/147806 - 04/07/2013 - AMC
         IF num_err = 9903735 AND
            pac_md_param.f_parempresa_nn('TRAMITADORES', mensajes) = 1
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, num_err);
            RAISE e_object_error;
         ELSE
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
            RAISE e_object_error;
         END IF;
         -- Bug 27514/147806 - 04/07/2013 - AMC
      END IF;

      vpasexec := 6;
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
         param IN  pctipcap : Tipo prestacion
         param IN  pcrelase : Relaci¿n con asegurado.
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
                   mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      num_err  NUMBER(10);
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'par¿metros - pnsinies:' || pnsinies ||
                                ' pntramit:' || pntramit || ' pccausa:' ||
                                pccausa || ' pctipdes:' || pctipdes ||
                                ' pcactpro:' || pcactpro || ' psperson:' ||
                                psperson || ' ppasigna:' || ppasigna ||
                                ' pcpaisre:' || pcpaisre || ' ctipcap:' ||
                                pctipcap || ' crelase:' || pcrelase ||
                                ' pcbancar:' || pcbancar || pctipcap ||
                                ' crelase:' || pcrelase;
      vobject  VARCHAR2(200) := 'PAC_MD_VALIDACIONES_SIN.f_dest';
   BEGIN
      num_err  := pac_validaciones_sin.f_dest(pnsinies,
                                              pntramit,
                                              pccausa,
                                              pctipdes,
                                              pcactpro,
                                              psperson,
                                              ppasigna,
                                              pcpaisre,
                                              pcbancar,
                                              pctipcap,
                                              pcrelase);
      vpasexec := 2;

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
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
         param out mensajes : missatges d'error
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
                           mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      num_err          NUMBER(10);
      v_nombreoutfacta VARCHAR2(2000);
      v_literaerror    VARCHAR2(2000);
      vpasexec         NUMBER(8) := 1;
      vparam           VARCHAR2(500) := 'par¿metros - pnsinies:' ||
                                        pnsinies || ' pntramit:' ||
                                        pntramit || ' pctippag:' ||
                                        pctippag || ' pctipdes:' ||
                                        pctipdes || ' pcconpag:' ||
                                        pcconpag || ' pccauind:' ||
                                        pccauind || ' pcforpag:' ||
                                        pcforpag || ' pcbancar:' ||
                                        pcbancar || ' pforden:' || pforden ||
                                        ' psidepag : ' || psidepag;
      vobject          VARCHAR2(200) := 'PAC_MD_VALIDACIONES_SIN.f_cabecerapago';
   BEGIN
      num_err  := pac_validaciones_sin.f_cabecerapago(pnsinies,
                                                      pntramit,
                                                      pctippag,
                                                      pctipdes,
                                                      pcconpag,
                                                      pccauind,
                                                      pcforpag,
                                                      pcbancar,
                                                      pforden,
                                                      psidepag,
                                                      v_nombreoutfacta);
      vpasexec := 2;

      IF num_err <> 0
      THEN

         v_literaerror := f_axis_literales(num_err, f_usu_idioma);

         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                              1,
                                              num_err,
                                              v_literaerror || ' ' ||
                                              v_nombreoutfacta);
         RAISE e_object_error;
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
   END f_cabecerapago;

   /*************************************************************************
      FUNCTION f_movpago
         Valida els moviments d'un pagament
         param in psidepag  : Codi seq¿¿ncia pagament
         param in pcestpag  : Codi estat pagament
         param in pcestval  : Codi estat validaci¿
         param in pcsubpag  : C¿digo subestado pago
         param out mensajes : missatges d'error
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_movpago(psidepag IN NUMBER,
                      pcestpag IN NUMBER,
                      pcestval IN NUMBER,
                      pcsubpag IN NUMBER, --bug:19601 - 29/09/2011 - JMC
                      mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      num_err  NUMBER(10);
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'par¿metros - psidepag:' || psidepag ||
                                ' pcestpag:' || pcestpag || ' pcestval:' ||
                                pcestval || ' pcsubpag:' || pcsubpag;
      vobject  VARCHAR2(200) := 'PAC_MD_VALIDACIONES_SIN.f_movpago';
   BEGIN
      num_err  := pac_validaciones_sin.f_movpago(psidepag,
                                                 pcestpag,
                                                 pcestval,
                                                 pcsubpag);
      vpasexec := 2;

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
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
         param in out mensajes : Mansajes de error
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
                      mensajes  IN OUT t_iax_mensajes,
                      pitotimp  IN NUMBER DEFAULT NULL, --bug 24637/147756:NSS:14/03/2014
                      pitotret  IN NUMBER DEFAULT NULL, --bug 24637/147756:NSS:21/03/2014
                      piotrosgas IN NUMBER DEFAULT NULL,
                      pibaseipoc IN NUMBER DEFAULT NULL,
                      piipoconsumo IN NUMBER DEFAULT NULL
                      ) RETURN NUMBER IS
      num_err  NUMBER(10);
      vpasexec NUMBER(8) := 1;
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
      vobject  VARCHAR2(200) := 'PAC_MD_VALIDACIONES_SIN.f_detpago';
   BEGIN
      num_err  := pac_validaciones_sin.f_detpago(pnsinies,
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
                                                 pcconpag,
                                                 pnmovres, --BUG 31294/174788:NSS:29/05/2014
                                                 pnorden, --BUG 31294/174788:NSS:29/05/2014
                                                 pireteiva, --BUG 24637/147756:NSS:29/05/2014
                                                 pireteica, --BUG 24637/147756:NSS:29/05/2014
                                                 pitotimp, --bug 24637/147756:NSS:14/03/2014
                                                 pitotret, --bug 24637/147756:NSS:21/03/2014
                                                 piotrosgas,
                                                 pibaseipoc,
                                                 piipoconsumo
                                                 );
      vpasexec := 2;

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
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
                     mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      num_err  NUMBER(10);
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'par¿metros - pctipreg:' || pctipreg ||
                                ' pcmanual:' || pcmanual || ' pcestage:' ||
                                pcestage || ' pffinage:' || pffinage ||
                                ' pttitage:' || pttitage || ' ptlinage:' ||
                                ptlinage || ' psidepag:' || psidepag;
      vobject  VARCHAR2(200) := 'PAC_MD_VALIDACIONES_SIN.f_agenda';
   BEGIN
      num_err  := pac_validaciones_sin.f_agenda(pctipreg,
                                                pcmanual,
                                                pcestage,
                                                pffinage,
                                                pttitage,
                                                ptlinage,
                                                psidepag);
      vpasexec := 2;

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
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

     Bug 12207 - 02/02/2010 - AMC
   *************************************************************************/
   FUNCTION f_calcimporteres(pctipres IN NUMBER,
                             pcgarant IN NUMBER,
                             pfresini IN DATE,
                             pfresfin IN DATE,
                             psproduc IN NUMBER,
                             mensajes OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec NUMBER(8) := 1;
      vobject  VARCHAR2(200) := 'PAC_MD_VALIDACIONES_SIN.f_calcimporteres';
      vparam   VARCHAR2(500) := 'par¿metros - pctipres:' || pctipres ||
                                ' pcgarant:' || pcgarant || ' pfresini:' ||
                                pfresini || ' pfresfin:' || pfresfin ||
                                ' psproduc:' || psproduc;
      num_err  NUMBER(10);
   BEGIN
      num_err := pac_validaciones_sin.f_calcimporteres(pctipres,
                                                       pcgarant,
                                                       pfresini,
                                                       pfresfin,
                                                       psproduc);

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
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
                    mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      num_err  NUMBER(10);
      vpasexec NUMBER(8) := 1;
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
                                 pcbancar || ' pnpresta:' || pnpresta;
      vobject  VARCHAR2(200) := 'PAC_MD_VALIDACIONES_SIN.f_prest';
   BEGIN
      num_err  := pac_validaciones_sin.f_prest(pnsinies,
                                               pntramit,
                                               psperson,
                                               pctipdes,
                                               psseguro,
                                               pf1paren,
                                               pfuparen,
                                               pcforpag,
                                               pibruren,
                                               pcrevali,
                                               pcrevali,
                                               pirevali,
                                               pctipdur,
                                               pnpartot,
                                               pctipban,
                                               pcbancar,
                                               pcestado,
                                               pcmotivo,
                                               pcblopag,
                                               pnpresta);
      vpasexec := 2;

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
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
   END f_prest;

   -- Fi BUG 0015669 - 08/2010 - JRH

   -- Ini bug 18554 - 11/06/2011 - SRA
   FUNCTION f_cabecerasini2(pnsinies IN sin_siniestro.nsinies%TYPE,
                            pfsinact IN sin_siniestro.fsinies%TYPE,
                            mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      num_err  NUMBER(10);
      vobject  VARCHAR2(100) := 'PAC_MD_VALIDACIONES_SIN.F_CABECERASINI2';
      vpasexec NUMBER := 0;
      vparam   VARCHAR2(2000) := 'pnsinies: ' || pnsinies || ' - ' ||
                                 'pfsinact: ' || pfsinact;
      vterror  NUMBER := 0;
   BEGIN
      IF pnsinies IS NULL OR
         pfsinact IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      -- BUG 21546_108727 - 23/02/2012 - JLTS - Se quita la utilizacion del objeto mensajes
      -- num_err := pac_validaciones_sin.f_cabecerasini2(pnsinies, pfsinact, mensajes);
      num_err := pac_validaciones_sin.f_cabecerasini2(pnsinies,
                                                      pfsinact,
                                                      vterror);

      -- BUG 21546_108727- 23/02/2012 - JLTS - Se adiciona la revision de los errore 9902076, 9902068, 9902069, 9902070
      IF num_err <> 0
      THEN
         -- BUG 21546_108727- 23/02/2012 - JLTS - Se adiciona el control de los mensajes
         IF num_err = 9902076
         THEN
            vpasexec := 1;
            p_tab_error(f_sysdate,
                        f_user,
                        vobject,
                        vpasexec,
                        vparam,
                        vterror);
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                                 5,
                                                 9902076,
                                                 vterror);
         ELSIF num_err = 9902068
         THEN
            vpasexec := 2;
            p_tab_error(f_sysdate,
                        f_user,
                        vobject,
                        vpasexec,
                        vparam,
                        vterror);
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                                 5,
                                                 9902068,
                                                 vterror);
         ELSIF num_err = 9902069
         THEN
            vpasexec := 3;
            p_tab_error(f_sysdate,
                        f_user,
                        vobject,
                        vpasexec,
                        vparam,
                        vterror);
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                                 5,
                                                 9902069,
                                                 vterror);
         ELSIF num_err = 9902070
         THEN
            vpasexec := 4;
            p_tab_error(f_sysdate,
                        f_user,
                        vobject,
                        vpasexec,
                        vparam,
                        vterror);
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                                 5,
                                                 9902070,
                                                 vterror);
         ELSE
            vpasexec := 5;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
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
   END f_cabecerasini2;

   -- Fin bug 18554 - 11/06/2011 - SRA

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
                        mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      num_err  NUMBER(10);
      vpasexec NUMBER(8) := 1;
      vparam   VARCHAR2(500) := 'par¿metros - pnsinies: ' || pnsinies ||
                                ' pNTRAMTE:' || pntramte || ' pCESTTTE:' ||
                                pcesttte;
      vobject  VARCHAR2(200) := 'PAC_MD_VALIDACIONES_SIN.f_movtramte';
   BEGIN
      num_err  := pac_validaciones_sin.f_movtramte(pnsinies,
                                                   pntramte,
                                                   pcesttte);
      vpasexec := 2;

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
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
   END f_movtramte;

   /*************************************************************************
      FUNCTION f_valpresiniestro
         Valida pre siniestro
         param in vgobsiniestro: objecte siniestres
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
       -- Bug 0023826 - 24/10/2012 - JMF
   *************************************************************************/
   FUNCTION f_valpresiniestro(vgobsiniestro IN ob_iax_siniestros,
                              mensajes      IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject      VARCHAR2(200) := 'PAC_MD_VALIDACIONES_SIN.f_valpresiniestro';
      vparam       VARCHAR2(500) := NULL;
      num_err      NUMBER(10);
      vpasexec     NUMBER(8) := 1;
      treferencias t_iax_siniestro_referencias;
      v_sproduc    seguros.sproduc%TYPE;
   BEGIN
      vpasexec := 2;
      num_err  := 0;

      IF vgobsiniestro IS NOT NULL
      THEN
         vpasexec := 3;
         vparam   := vparam || ' s=' || vgobsiniestro.sseguro;

         SELECT MAX(sproduc)
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = vgobsiniestro.sseguro;

         -- Validar si debe existir almenos una referencia externa definida.
         vpasexec := 5;

         IF NVL(f_parproductos_v(v_sproduc, 'SIN_VALUNAREFERENCIA'), 0) = 1
         THEN
            vpasexec     := 7;
            treferencias := vgobsiniestro.referencias;
            num_err      := 9904415; -- Es necesario introducir una referencia externa
            vpasexec     := 9;

            IF treferencias IS NOT NULL
            THEN
               IF treferencias.count > 0
               THEN
                  vpasexec := 11;

                  FOR i IN treferencias.first .. treferencias.last
                  LOOP
                     vpasexec := 13;

                     IF treferencias(i).trefext IS NOT NULL
                     THEN
                        num_err := 0;
                     END IF;
                  END LOOP;
               END IF;
            END IF;
         END IF;
      END IF;

      vpasexec := 15;

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
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
                                mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
      vobject  VARCHAR2(200) := 'PAC_MD_VALIDACIONES_SIN.f_valida_declarante';
      vparam   VARCHAR2(500) := 'parametros - psseguro:' || psseguro ||
                                'pctipdec:' || pctipdec || ' pcgarant:' ||
                                pcgarant;
      num_err  NUMBER(10);
      vpasexec NUMBER(8) := 1;
   BEGIN
      num_err  := pac_validaciones_sin.f_valida_declarante(psseguro,
                                                           pctipdec,
                                                           pcgarant);
      vpasexec := 2;

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
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
         Comprobar si la persona que asistir¿ a la citaci¿n tiene otras citaciones o tiene otras audiencias
         Comprobar si la persona que asiste tiene otras citaciones o tiene otras audiencias
         param in pnsinies  : clave seguros
         param in pntramit  : c¿digo garantia seleccionada
         param in pncitacion : numero citacion
         param in pfcitacion : fecha citacion
         param in phcitacion : hora citacion
         param in pcpais : codigo pais
         param in pcprovin : codigo provincia
         param in pcpoblac : codigo poblacion
         param in ptlugar : lugar citacion
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_val_citacion(pnsinies IN VARCHAR2,
                           pntramit IN NUMBER,
                           pncitacion IN NUMBER,
                           psperson IN NUMBER,
                           pfcitacion IN DATE,
                           phcitacion IN VARCHAR2,
                           pcpais IN NUMBER,
                           pcprovin IN NUMBER,
                           pcpoblac IN NUMBER,
                           ptlugar IN VARCHAR2,
                           mensajes OUT t_iax_mensajes)

  RETURN NUMBER IS
      vterror  VARCHAR2(200);
      vobject  VARCHAR2(200) := 'PAC_MD_VALIDACIONES_SIN.f_val_citacion';
      vparam   VARCHAR2(500) := 'par¿metros - pnsinies: ' || pnsinies || ' - pntramit: ' || pntramit
                             || ' - pncitacion: ' || pncitacion || ' - psperson: ' || psperson;
      num_err  NUMBER(10);
      vpasexec NUMBER(8) := 1;
      vcount NUMBER;
      vfcitacion DATE;
      vhcitacion VARCHAR2(5);
      vdifhour NUMBER;
      v_sproduc    seguros.sproduc%TYPE;

      CURSOR c_cit_sin IS
        SELECT hcitacion
          FROM sin_tramita_citaciones
         WHERE sperson = psperson
           AND fcitacion = pfcitacion
           AND (pncitacion IS NULL
              OR ncitacion <> pncitacion
              OR ntramit <> pntramit
              OR nsinies <> pnsinies)
           AND cprovin = pcprovin
           AND cpoblac = pcpoblac;

   BEGIN

      SELECT COUNT(*)
        INTO vcount
        FROM sin_tramita_citaciones
       WHERE sperson = psperson
         AND fcitacion = pfcitacion
         AND (pncitacion IS NULL
              OR ncitacion <> pncitacion
              OR ntramit <> pntramit
              OR nsinies <> pnsinies)
         AND (cprovin <> pcprovin
              OR cpoblac <> pcpoblac);

      vpasexec := 2;

      SELECT MAX(sproduc)
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = (select sseguro from sin_siniestro where nsinies=pnsinies);

      IF vcount > 0
        THEN
            vterror := f_axis_literales(9909798, f_usu_idioma);
            vterror := REPLACE(vterror, '#1#', pfcitacion);
            vterror := REPLACE(vterror, '#2#', f_despoblac2(pcpoblac, pcprovin));
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err, vterror);
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, vterror);
            RAISE e_object_error;
      END IF;

      FOR i IN c_cit_sin
        LOOP

        SELECT 24 * (to_date(''|| pfcitacion ||','|| i.hcitacion ||'','dd/mm/yy,hh24:mi')
                   - to_date(''|| pfcitacion ||','|| phcitacion ||'','dd/mm/yy,hh24:mi'))
          INTO vdifhour
          FROM dual;

          IF vdifhour >= -f_parproductos_v(v_sproduc, 'HORAS_DIF_CITACION') AND vdifhour <= 0
          OR vdifhour <= f_parproductos_v(v_sproduc, 'HORAS_DIF_CITACION') AND vdifhour >= 0
          THEN
              vterror := f_axis_literales(9909798, f_usu_idioma);
              vterror := REPLACE(vterror, '#1#', pfcitacion);
              vterror := REPLACE(vterror, '#2#', phcitacion);
              pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err, vterror);
              p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, vterror);
              RAISE e_object_error;
          END IF;

        END LOOP;

      vpasexec := 3;

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
   END f_val_citacion;

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
      vterror  VARCHAR2(1000);
   BEGIN
      num_err  := pac_validaciones_sin.f_valida_garantia(psseguro,
                                                         pnriesgo,
                                                         pcgarant,
                                                         pndias,
                                                         pfsinies,
                                                         pfresini,
                                                         pfresfin,
                                                         porigen,
                                                         vterror);
      vpasexec := 2;

      IF num_err <> 0
      THEN
         IF num_err IN (9906391, 9906392)
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                                 5,
                                                 num_err,
                                                 vterror);
            p_tab_error(f_sysdate,
                        f_user,
                        vobject,
                        vpasexec,
                        vparam,
                        vterror);
         ELSE
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
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
      vobjectname VARCHAR2(500) := 'pac_md_validaciones_sin.f_valida_ult_tra';
      vparam      VARCHAR2(500) := ' par¿metros - ';
      vpasexec    NUMBER(5) := 1;
      vnumerr     NUMBER(8) := 0;
      vcidioma    NUMBER;
   BEGIN
      vcidioma := pac_md_common.f_get_cxtidioma();
      vnumerr  := pac_validaciones_sin.f_valida_ult_tra(pnsinies,
                                                        pntramit,
                                                        vcidioma,
                                                        ptlitera);

      IF vnumerr <> 0
      THEN
         RETURN vnumerr;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobjectname,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobjectname,
                                           1000006,
                                           vpasexec,
                                           vparam);
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
      vterror  VARCHAR2(1000);
   BEGIN
      num_err  := pac_validaciones_sin.f_val_aseg_innominado(psperson,
                                                             pmensaje);
      vpasexec := 2;

      IF num_err <> 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
         RAISE e_object_error;
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
END pac_md_validaciones_sin;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_VALIDACIONES_SIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_VALIDACIONES_SIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_VALIDACIONES_SIN" TO "PROGRAMADORESCSI";
