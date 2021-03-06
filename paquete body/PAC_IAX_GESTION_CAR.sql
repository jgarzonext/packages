--------------------------------------------------------
--  DDL for Package Body PAC_IAX_GESTION_CAR
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY PAC_IAX_GESTION_CAR AS
   FUNCTION f_get_gca_parampre_conc(
      pncodparcon IN NUMBER,
      pcodseccion IN NUMBER,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'pac_iax_gestion_car.f_set_gca_parampre_conc';
   BEGIN
      v_cursor := pac_md_gestion_car.f_get_gca_parampre_conc(pncodparcon, pcodseccion,
                                                             pcidioma, mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_gca_parampre_conc;

   FUNCTION f_set_gca_parampre_conc(
      pncodparcon IN NUMBER,
      pcodseccion IN NUMBER,
      pcidioma IN NUMBER,
      ppregunta IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'pac_iax_gestion_car.f_set_gca_parampre_conc';
      cont           NUMBER;
   BEGIN
      RETURN pac_md_gestion_car.f_set_gca_parampre_conc(pncodparcon, pcodseccion, pcidioma,
                                                        ppregunta, mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_gca_parampre_conc;

   FUNCTION f_del_gca_conciliacioncab(
      psidcon IN NUMBER,
      pacon IN NUMBER,
      pmcon IN NUMBER,
      pcsucursal IN NUMBER,
      pnnumideage IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_rea.f_set_gca_conciliacioncab';
   BEGIN
      RETURN pac_md_gestion_car.f_del_gca_conciliacioncab(psidcon, pacon, pmcon, pcsucursal,
                                                          pnnumideage, mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_gca_conciliacioncab;

   FUNCTION f_get_gca_conciliacioncab(
      psidcon IN NUMBER,
      pacon IN NUMBER,
      pmcon IN NUMBER,
      pcsucursal IN NUMBER,
      pnnumideage IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_rea.f_set_gca_conciliacioncab';
   BEGIN
      v_cursor := pac_md_gestion_car.f_get_gca_conciliacioncab(psidcon, pacon, pmcon,
                                                               pcsucursal, pnnumideage,
                                                               mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_gca_conciliacioncab;

   FUNCTION f_set_gca_conciliacioncab(
      psidcon IN NUMBER,
      pacon IN NUMBER,
      pmcon IN NUMBER,
      ptdesc IN VARCHAR2,
      pcsucursal IN NUMBER,
      pnnumideage IN VARCHAR2,
      pcfichero IN NUMBER,
      psproces IN NUMBER,
      pcestado IN NUMBER,
      pncodacta IN NUMBER,
      pcusualt IN VARCHAR2,
      pfalta IN DATE,
      pcusumod IN VARCHAR2,
      pfmodifi IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'pac_md_gestion_car.f_set_gca_conciliacioncab';
      cont           NUMBER;
   BEGIN
      RETURN pac_md_gestion_car.f_set_gca_conciliacioncab(psidcon, pacon, pmcon, ptdesc,
                                                          pcsucursal, pnnumideage, pcfichero,
                                                          psproces, pcestado, pncodacta,
                                                          pcusualt, pfalta, pcusumod,
                                                          pfmodifi, mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_gca_conciliacioncab;

   FUNCTION f_del_gca_conciliaciondet(
      psidcon IN NUMBER,
      pnlinea IN NUMBER,
      pcagente IN NUMBER,
      pnnumidecli IN VARCHAR2,
      ptnomcli IN VARCHAR2,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnrecibo IN NUMBER,
      pnmadurez IN NUMBER,
      pitotalr IN NUMBER,
      picomision IN NUMBER,
      pcmoneda IN VARCHAR2,
      pcoutsourcing IN NUMBER,
      ptnomcli_fic IN NUMBER,
      pnpoliza_fic IN NUMBER,
      pnrecibo_fic IN NUMBER,
      pnmadurez_fic IN NUMBER,
      pitotalr_fic IN NUMBER,
      picomision_fic IN NUMBER,
      pcmoneda_fic IN VARCHAR2,
      pcoutsourcing_fic IN NUMBER,
      pcrepetido IN NUMBER,
      pccruce IN NUMBER,
      pccrucedet IN NUMBER,
      pcestadoi IN NUMBER,
      pcestado IN NUMBER,
      ptobserva IN VARCHAR2,
      pcusualt IN VARCHAR2,
      pfalta IN DATE,
      pcusumod IN VARCHAR2,
      pfmodifi IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_gestion_car.f_set_gca_conciliaciondet';
   BEGIN
      RETURN pac_md_gestion_car.f_del_gca_conciliaciondet(psidcon, pnlinea, pcagente,
                                                          pnnumidecli, ptnomcli, pnpoliza,
                                                          pncertif, pnrecibo, pnmadurez,
                                                          pitotalr, picomision, pcmoneda,
                                                          pcoutsourcing, ptnomcli_fic,
                                                          pnpoliza_fic, pnrecibo_fic,
                                                          pnmadurez_fic, pitotalr_fic,
                                                          picomision_fic, pcmoneda_fic,
                                                          pcoutsourcing_fic, pcrepetido,
                                                          pccruce, pccrucedet, pcestadoi,
                                                          pcestado, ptobserva, pcusualt,
                                                          pfalta, pcusumod, pfmodifi,
                                                          mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_gca_conciliaciondet;

   FUNCTION f_get_gca_conciliaciondet(
      psidcon IN NUMBER,
      pnlinea IN NUMBER,
      pcagente IN NUMBER,
      pnnumidecli IN VARCHAR2,
      ptnomcli IN VARCHAR2,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnrecibo IN NUMBER,
      pnmadurez IN NUMBER,
      pitotalr IN NUMBER,
      picomision IN NUMBER,
      pcmoneda IN VARCHAR2,
      pcoutsourcing IN NUMBER,
      ptnomcli_fic IN NUMBER,
      pnpoliza_fic IN NUMBER,
      pnrecibo_fic IN NUMBER,
      pnmadurez_fic IN NUMBER,
      pitotalr_fic IN NUMBER,
      picomision_fic IN NUMBER,
      pcmoneda_fic IN VARCHAR2,
      pcoutsourcing_fic IN NUMBER,
      pcrepetido IN NUMBER,
      pccruce IN NUMBER,
      pccrucedet IN NUMBER,
      pcestadoi IN NUMBER,
      pcestado IN NUMBER,
      ptobserva IN VARCHAR2,
      pcusualt IN VARCHAR2,
      pfalta IN DATE,
      pcusumod IN VARCHAR2,
      pfmodifi IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_gestion_car.f_set_gca_conciliaciondet';
   BEGIN
      v_cursor := pac_md_gestion_car.f_get_gca_conciliaciondet(psidcon, pnlinea, pcagente,
                                                               pnnumidecli, ptnomcli,
                                                               pnpoliza, pncertif, pnrecibo,
                                                               pnmadurez, pitotalr,
                                                               picomision, pcmoneda,
                                                               pcoutsourcing, ptnomcli_fic,
                                                               pnpoliza_fic, pnrecibo_fic,
                                                               pnmadurez_fic, pitotalr_fic,
                                                               picomision_fic, pcmoneda_fic,
                                                               pcoutsourcing_fic, pcrepetido,
                                                               pccruce, pccrucedet, pcestadoi,
                                                               pcestado, ptobserva, pcusualt,
                                                               pfalta, pcusumod, pfmodifi,
                                                               mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_gca_conciliaciondet;

   FUNCTION f_set_gca_conciliaciondet(
      tipo IN NUMBER,
      psidcon IN NUMBER,
      pnlinea IN NUMBER,
      pcagente IN NUMBER,
      pnnumidecli IN VARCHAR2,
      ptnomcli IN VARCHAR2,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnrecibo IN NUMBER,
      pnmadurez IN NUMBER,
      pitotalr IN NUMBER,
      picomision IN NUMBER,
      pcmoneda IN VARCHAR2,
      pcoutsourcing IN NUMBER,
      ptnomcli_fic IN NUMBER,
      pnpoliza_fic IN NUMBER,
      pnrecibo_fic IN NUMBER,
      pnmadurez_fic IN NUMBER,
      pitotalr_fic IN NUMBER,
      picomision_fic IN NUMBER,
      pcmoneda_fic IN VARCHAR2,
      pcoutsourcing_fic IN NUMBER,
      pcrepetido IN NUMBER,
      pccruce IN NUMBER,
      pccrucedet IN NUMBER,
      pcestadoi IN NUMBER,
      pcestado IN NUMBER,
      ptobserva IN VARCHAR2,
      pcusualt IN VARCHAR2,
      pfalta IN DATE,
      pcusumod IN VARCHAR2,
      pfmodifi IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_gestion_car.f_set_gca_conciliaciondet';
      cont           NUMBER;
   BEGIN
      RETURN pac_md_gestion_car.f_set_gca_conciliaciondet(tipo, psidcon, pnlinea, pcagente,
                                                          pnnumidecli, ptnomcli, pnpoliza,
                                                          pncertif, pnrecibo, pnmadurez,
                                                          pitotalr, picomision, pcmoneda,
                                                          pcoutsourcing, ptnomcli_fic,
                                                          pnpoliza_fic, pnrecibo_fic,
                                                          pnmadurez_fic, pitotalr_fic,
                                                          picomision_fic, pcmoneda_fic,
                                                          pcoutsourcing_fic, pcrepetido,
                                                          pccruce, pccrucedet, pcestadoi,
                                                          pcestado, ptobserva, pcusualt,
                                                          pfalta, pcusumod, pfmodifi,
                                                          mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_gca_conciliaciondet;

   FUNCTION f_del_gca_conciliacion_acta(
      pnconciact IN NUMBER,
      psidcon IN NUMBER,
      pcconacta IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_pac_gestion_car.f_set_gca_conciliacion_acta';
   BEGIN
      RETURN pac_md_gestion_car.f_del_gca_conciliacion_acta(pnconciact, psidcon, pcconacta,
                                                            mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_gca_conciliacion_acta;

   FUNCTION f_get_gca_conciliacion_acta(
      pnconciact IN NUMBER,
      psidcon IN NUMBER,
      pcconacta IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_pac_gestion_car.f_set_gca_conciliacion_acta';
   BEGIN
      v_cursor := pac_md_gestion_car.f_get_gca_conciliacion_acta(pnconciact, psidcon,
                                                                 pcconacta, mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_gca_conciliacion_acta;

   FUNCTION f_set_gca_conciliacion_acta(
      pnconciact IN NUMBER,
      psidcon IN NUMBER,
      pcconacta IN NUMBER,
      pncantidad IN NUMBER,
      pnvalor IN NUMBER,
      pcrespage IN NUMBER,
      pcrespcia IN NUMBER,
      pfsolucion IN DATE,
      ptobs IN VARCHAR2,
      pcusualt IN VARCHAR2,
      pfalta IN DATE,
      pcusumod IN VARCHAR2,
      pfmodifi IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_pac_gestion_car.f_set_gca_conciliacion_acta';
      cont           NUMBER;
   BEGIN
      RETURN pac_md_gestion_car.f_set_gca_conciliacion_acta(pnconciact, psidcon, pcconacta,
                                                            pncantidad, pnvalor, pcrespage,
                                                            pcrespcia, pfsolucion, ptobs,
                                                            pcusualt, pfalta, pcusumod,
                                                            pfmodifi, mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_gca_conciliacion_acta;

   FUNCTION f_get_gestion_cartera_recobro(
      pnnumide IN VARCHAR2, --ML - EN CONSORCIOS EL NIT ES ALFANUMERICO
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN VARCHAR2,
      pnsinies IN NUMBER,
      pfinicio IN DATE,
      pffinal IN DATE,
      pcrecopen IN NUMBER,
      ptipo IN NUMBER,
      precurso IN NUMBER,
      popcion IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_pac_gestion_car.f_set_gestion_cartera_recobro';
   BEGIN
      v_cursor := pac_md_gestion_car.f_get_gestion_cartera_recobro(pnnumide, pcramo, psproduc,
                                                                   pnpoliza, pncertif,
                                                                   pnsinies, pfinicio,
                                                                   pffinal, pcrecopen, ptipo,
                                                                   precurso, popcion,
                                                                   mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_gestion_cartera_recobro;

   FUNCTION f_get_depu_saldofavcli(
      ppercorte IN DATE,
      pcpendientes IN NUMBER,
      pcsucursal IN NUMBER,
      pnnumideage IN NUMBER,
      pnnumidecli IN NUMBER,
      pfdocini IN DATE,
      pfdocfin IN DATE,
      pndocsap IN NUMBER,
      pfcontini IN DATE,
      pfcontfin IN DATE,
      pntipo IN NUMBER,
      pnopcion IN NUMBER,
      pnmodo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_pac_gestion_car.f_set_depu_saldofavcli';
   BEGIN
      v_cursor := pac_md_gestion_car.f_get_depu_saldofavcli(ppercorte, pcpendientes,
                                                            pcsucursal, pnnumideage, pnnumidecli, pfdocini,
                                                            pfdocfin, pndocsap, pfcontini,
                                                            pfcontfin, pntipo, pnopcion,
                                                            pnmodo, mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_depu_saldofavcli;

   FUNCTION f_del_sin_apuntes_rec(
      pidobs_gr IN NUMBER,
      pnsinies_r IN NUMBER,
      pntramit_r IN NUMBER,
      pnpoliza_r IN NUMBER,
      pttitobs IN VARCHAR2,
      pfalta_gr IN DATE,
      pcusualt_gr IN VARCHAR2,
      ptobs IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_pac_gestion_car.f_set_sin_apuntes_rec';
   BEGIN
      RETURN pac_md_gestion_car.f_del_sin_apuntes_rec(pidobs_gr, pnsinies_r, pntramit_r,
                                                      pnpoliza_r, pttitobs, pfalta_gr,
                                                      pcusualt_gr, ptobs, mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_sin_apuntes_rec;

   FUNCTION f_get_sin_apuntes_rec(
      pidobs_gr IN NUMBER,
      pnsinies_r IN NUMBER,
      pntramit_r IN NUMBER,
      pnpoliza_r IN NUMBER,
      pttitobs IN VARCHAR2,
      pfalta_gr IN DATE,
      pcusualt_gr IN VARCHAR2,
      ptobs IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_pac_gestion_car.f_set_sin_apuntes_rec';
   BEGIN
      v_cursor := pac_md_gestion_car.f_get_sin_apuntes_rec(pidobs_gr, pnsinies_r, pntramit_r,
                                                           pnpoliza_r, pttitobs, pfalta_gr,
                                                           pcusualt_gr, ptobs, mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_sin_apuntes_rec;

   FUNCTION f_set_sin_apuntes_rec(
      pidobs_gr IN NUMBER,
      pnsinies_r IN NUMBER,
      pntramit_r IN NUMBER,
      pnpoliza_r IN NUMBER,
      pttitobs IN VARCHAR2,
      pfalta_gr IN DATE,
      pcusualt_gr IN VARCHAR2,
      ptobs IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_pac_gestion_car.f_set_sin_apuntes_rec';
      cont           NUMBER;
   BEGIN
      p_control_error('SQL', 2, 'INGRESANDO');
      RETURN pac_md_gestion_car.f_set_sin_apuntes_rec(pidobs_gr, pnsinies_r, pntramit_r,
                                                      pnpoliza_r, pttitobs, pfalta_gr,
                                                      pcusualt_gr, ptobs, mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_sin_apuntes_rec;

   FUNCTION f_get_agd_observaciones(
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pcagente IN NUMBER,
      pnsinies IN NUMBER,
      pntramit IN VARCHAR2,
      ptipo IN DATE,
      pparama IN VARCHAR2,
      pparamb IN VARCHAR2,
      psgsfavcli IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_gestion_car.f_set_agd_observaciones';
   BEGIN
      v_cursor := pac_md_gestion_car.f_get_agd_observaciones(psseguro, pnrecibo, pcagente,
                                                             pnsinies, pntramit, ptipo,
                                                             pparama, pparamb, psgsfavcli,
                                                             mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_agd_observaciones;

   FUNCTION f_get_gca_cargaconc(
      pcempres IN NUMBER,
      pcfichero IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_rea.f_set_gca_cargaconc';
   BEGIN
      v_cursor := pac_md_gestion_car.f_get_gca_cargaconc(pcempres, pcfichero, mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_gca_cargaconc;

   FUNCTION f_set_gca_salfavcli(
      psgsfavcli IN NUMBER,
      pnnumidecli IN VARCHAR2,
      ptnomcli IN VARCHAR2,
      pndocsap IN NUMBER,
      pfdoc IN DATE,
      pfcontab IN DATE,
      pcsucursal IN NUMBER,
      pnnumideage IN VARCHAR2,
      ptnomage IN VARCHAR2,
      pnpoliza IN NUMBER,
      pncertif IN VARCHAR2,
      pnrecibo IN NUMBER,
      pimovimi_moncia IN NUMBER,
      psproces IN NUMBER,
      pcestado IN NUMBER,
      pcgestion IN NUMBER,
      ptinconsistencia IN VARCHAR2,
      pcusualt IN VARCHAR2,
      pfalta IN DATE,
      pcusumod IN VARCHAR2,
      pfmodifi IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_rea.f_set_gca_salfavcli';
      cont           NUMBER;
   BEGIN
      RETURN pac_md_gestion_car.f_set_gca_salfavcli(psgsfavcli, pnnumidecli, ptnomcli,
                                                    pndocsap, pfdoc, pfcontab, pcsucursal,
                                                    pnnumideage, ptnomage, pnpoliza, pncertif,
                                                    pnrecibo, pimovimi_moncia, psproces,
                                                    pcestado, pcgestion, ptinconsistencia,
                                                    pcusualt, pfalta, pcusumod, pfmodifi,
                                                    mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_gca_salfavcli;

   FUNCTION f_set_agd_observaciones(
      pcempres IN NUMBER,
      pidobs IN NUMBER,
      pcconobs IN NUMBER,
      pctipobs IN NUMBER,
      pttitobs IN VARCHAR2,
      ptobs IN VARCHAR2,
      pfobs IN DATE,
      pfrecordatorio IN DATE,
      pctipagd IN NUMBER,
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pcagente IN NUMBER,
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pcambito IN NUMBER,
      pcpriori IN NUMBER,
      pcprivobs IN NUMBER,
      ppublico IN NUMBER,
      pcusualt IN VARCHAR2,
      pfalta IN DATE,
      pcusumod IN VARCHAR2,
      pfmodifi IN DATE,
      psgsfavcli IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_gestion_car.f_set_agd_observaciones';
      cont           NUMBER;
   BEGIN
      RETURN pac_md_gestion_car.f_set_agd_observaciones(pcempres, pidobs, pcconobs, pctipobs,
                                                        pttitobs, ptobs, pfobs,
                                                        pfrecordatorio, pctipagd, psseguro,
                                                        pnrecibo, pcagente, pnsinies,
                                                        pntramit, pcambito, pcpriori,
                                                        pcprivobs, ppublico, pcusualt, pfalta,
                                                        pcusumod, pfmodifi, psgsfavcli,
                                                        mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_agd_observaciones;

   FUNCTION f_get_gca_docgsfavcli(pidobs IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      --
      v_cursor       sys_refcursor;
      --
      e_object_error EXCEPTION;
      e_param_error  EXCEPTION;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'pac_md_gestion_rec.f_get_gca_docgsfavcli';
      vparam         VARCHAR2(500) := 'pidobs: ' || pidobs;
   --
   BEGIN
      --
      v_cursor := pac_md_gestion_car.f_get_gca_docgsfavcli(pidobs => pidobs,
                                                        mensajes => mensajes);
      --
      RETURN v_cursor;
   --
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
   END f_get_gca_docgsfavcli;

   FUNCTION f_ins_gca_docgsfavcli(
      pidobs IN NUMBER,
      piddocgdx IN NUMBER,
      pctipo IN NUMBER,
      ptobserv IN VARCHAR2,
      ptfilename IN VARCHAR2,
      pfcaduci IN DATE,
      pfalta IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      e_object_error EXCEPTION;
      e_param_error  EXCEPTION;
      vpasexec       NUMBER := 1;
      vobject        VARCHAR2(200) := 'pac_md_gestion_rec.f_ins_gca_docgsfavcli';
      vparam         VARCHAR2(500)
         := 'pidobs: ' || pidobs || ' pfalta: ' || pfalta || ' piddocgdx: ' || piddocgdx
            || ' pctipo: ' || pctipo || ' ptobserv: ' || ptobserv || ' pfcaduci: ' || pfcaduci
            || ' pfalta: ' || pfalta;
      --
      vnum_err       NUMBER;
   --
   BEGIN
      --
      vnum_err := pac_md_gestion_car.f_ins_gca_docgsfavcli(pidobs => pidobs,
                                                        piddocgdx => piddocgdx,
                                                        pctipo => pctipo,
                                                        ptobserv => ptobserv,
                                                        ptfilename => ptfilename,
                                                        pfcaduci => pfcaduci,
                                                        pfalta => pfalta,
                                                        mensajes => mensajes);
      --
      RETURN vnum_err;
   --
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
   END f_ins_gca_docgsfavcli;

   FUNCTION f_get_gca_docgsfavclis(pidobs IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      --
      v_cursor       sys_refcursor;
      e_object_error EXCEPTION;
      e_param_error  EXCEPTION;
      --
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'pac_md_gestion_rec.f_get_gca_docgsfavclis';
      vparam         VARCHAR2(500) := 'pidobs: ' || pidobs;
   --
   BEGIN
      --
      v_cursor := pac_md_gestion_car.f_get_gca_docgsfavclis(pidobs => pidobs,
                                                         mensajes => mensajes);
      --
      RETURN v_cursor;
   --
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
   END f_get_gca_docgsfavclis;
   FUNCTION f_get_cantidad_acta_con(pncodparcon NUMBER, psidcon NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_cantidad     NUMBER;
      e_object_error EXCEPTION;
      e_param_error  EXCEPTION;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'pac_iax_gestion_car.f_get_cantidad_acta_con';
      vparam         VARCHAR2(500) := 'ncodparcon: ' || pncodparcon|| '- sidcon: ' || psidcon;
      v_total_c      NUMBER;
      v_total_a      NUMBER;
      v_valor_subtab NUMBER;
   BEGIN
          SELECT COUNT(1)
            INTO v_total_c
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND nrecibo IS NOT NULL;
--INI IAXIS 4060 SGM  12/06/2019  Se modifica calculo de valores en resumen conciliacion            
       /*   SELECT COUNT(1)
            INTO v_total_a
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND nrecibo IS null;*/
          SELECT COUNT(1)
            INTO v_total_a
            FROM GCA_CONCILIACIONDET
           WHERE 1=1 
             AND sidcon = psidcon
             AND CREPETIDO = 0
             AND (nrecibo_fic IS NOT NULL OR npoliza_fic IS NOT NULL);             
--FIN IAXIS 4060 SGM  12/06/2019  Se modifica calculo de valores en resumen conciliacion  
      IF pncodparcon = 1 THEN
        v_cantidad :=  v_total_c;
      ELSIF pncodparcon = 2 THEN
        v_cantidad :=  v_total_a;
      ELSIF pncodparcon = 3 THEN
        v_cantidad := v_total_a - v_total_c;
      ELSIF pncodparcon = 4 THEN
          SELECT COUNT(1)
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND cestado != 0;
      ELSIF pncodparcon = 5 THEN
          SELECT COUNT(1)
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND cestado = 0;
      ELSIF pncodparcon = 6 THEN
          SELECT COUNT(1)
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
              AND cestado = 9; --INI IAXIS 4060 SGM  12/06/2019  Se modifica calculo de valores en resumen conciliacion  
      ELSIF pncodparcon = 7 THEN
          SELECT COUNT(1)
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND cestado = 1;

      ELSIF pncodparcon = 8 THEN

         /* SELECT COUNT(1)
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET A, GCA_CONCILIACIONDET B
           WHERE A.sidcon = psidcon
             AND A.CREPETIDO = 0
             AND A.cestado = 1
             AND B.CREPETIDO = 0
             AND B.cestado = 1
             AND A.NRECIBO_FIC = B.NRECIBO_FIC
             AND A.NPOLIZA_FIC = B.NPOLIZA_FIC
             AND A.SIDCON != B.SIDCON;*/
        SELECT COUNT(*)  INTO v_cantidad FROM 
        (SELECT DISTINCT *
          FROM GCA_CONCILIACIONDET gd, GCA_CONCILIACIONCAB gc
         WHERE gd.sidcon = gc.sidcon
           AND gd.sidcon <> psidcon
           and gd.sidcon in (Select gc2.sidcon from GCA_CONCILIACIONCAB gc2 where gc2.cfichero = (select gc3.cfichero from GCA_CONCILIACIONCAB gc3 where sidcon = psidcon))
           AND gd.cestado <> 0
           AND ((instr(gd.tobserva,'CONCILIADO EN ',1,1) = 0) or (gd.tobserva is NULL)));

      ELSIF pncodparcon = 9 THEN
          SELECT COUNT(1)
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND cestado = 6;
      ELSIF pncodparcon = 10 THEN
          SELECT COUNT(1)
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND cestado = 7;
      ELSIF pncodparcon = 11 THEN
          SELECT COUNT(1)
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND cestado = 8;
      ELSIF pncodparcon = 12 THEN
          SELECT COUNT(1)
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND cestado = 3;
      ELSIF pncodparcon = 13 THEN
          SELECT COUNT(1)
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND cestado = 4;
      ELSIF pncodparcon = 14 THEN
          SELECT COUNT(1)
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND cestado = 2;
      ELSIF pncodparcon = 15 THEN
          SELECT COUNT(1)
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND cestado = 5;
      ELSIF pncodparcon = 16 THEN

        SELECT NVAL1
          INTO v_valor_subtab
          FROM SGT_SUBTABS_DET
         WHERE CSUBTABLA = 9000002
           AND CVERSUBT = (SELECT MAX(CVERSUBT) FROM SGT_SUBTABS_VER WHERE CSUBTABLA = 9000002)
           AND NVAL7 = 'ALTO IMPACTO';
          SELECT COUNT(1)
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND NVL(ITOTALR,0) > v_valor_subtab;

      ELSIF pncodparcon = 17 THEN
        SELECT NVAL1
          INTO v_valor_subtab
          FROM SGT_SUBTABS_DET
         WHERE CSUBTABLA = 9000002
           AND CVERSUBT = (SELECT MAX(CVERSUBT) FROM SGT_SUBTABS_VER WHERE CSUBTABLA = 9000002)
           AND NVAL7 = 'DIAS MORA';
          SELECT COUNT(1)
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND NVL(NMADUREZ,0) > v_valor_subtab;

      ELSIF pncodparcon = 18 THEN
        SELECT NVAL1
          INTO v_valor_subtab
          FROM SGT_SUBTABS_DET
         WHERE CSUBTABLA = 9000002
           AND CVERSUBT = (SELECT MAX(CVERSUBT) FROM SGT_SUBTABS_VER WHERE CSUBTABLA = 9000002)
           AND NVAL7 = 'DIAS PROVISION';
          SELECT COUNT(1)
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND NVL(NMADUREZ,0) > v_valor_subtab;
      ELSIF pncodparcon = 19 THEN
        SELECT NVAL1
          INTO v_valor_subtab
          FROM SGT_SUBTABS_DET
         WHERE CSUBTABLA = 9000002
           AND CVERSUBT = (SELECT MAX(CVERSUBT) FROM SGT_SUBTABS_VER WHERE CSUBTABLA = 9000002)
           AND NVAL7 = 'MADUREZ MINIMA PARA CANCELACION';
          SELECT COUNT(1)
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND NVL(NMADUREZ,0) > v_valor_subtab;
      END IF;


      RETURN v_cantidad;
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
   END f_get_cantidad_acta_con;
   FUNCTION f_get_valor_acta_con(pncodparcon NUMBER, psidcon NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_valor       NUMBER;
      e_object_error EXCEPTION;
      e_param_error  EXCEPTION;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'pac_iax_gestion_car.f_get_valor_acta_con';
      vparam         VARCHAR2(500) := 'ncodparcon: ' || pncodparcon|| '- sidcon: ' || psidcon;
      v_sum_a        NUMBER;
      v_sum_c        NUMBER;
      v_cantidad     NUMBER;
      v_valor_subtab NUMBER;
   BEGIN
          SELECT SUM(ITOTALR)
            INTO v_sum_c
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND nrecibo IS NOT null;
--INI IAXIS 4060 SGM  12/06/2019  se agregan ficheros a cruces cartera
       /*   SELECT SUM(TO_NUMBER(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ITOTALR_FIC, CHR(10) , ''), CHR(13) , ''), '.', ''), ',', '.'), '$',''))))
            INTO v_sum_a
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND nrecibo IS null;*/
          SELECT NVL(SUM(TO_NUMBER(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ITOTALR_FIC, CHR(10) , ''), CHR(13) , ''), '.', ''), ',', '.'), '$','')))),0)
            INTO v_sum_a
            FROM GCA_CONCILIACIONDET
           WHERE 1=1 
             AND sidcon = psidcon
             AND CREPETIDO = 0
             AND (nrecibo_fic IS NOT NULL OR npoliza_fic IS NOT NULL);             
--FIN IAXIS 4060 SGM  12/06/2019  se agregan ficheros a cruces cartera
      IF pncodparcon = 1 THEN
        v_cantidad :=  v_sum_c;
      ELSIF pncodparcon = 2 THEN
        v_cantidad :=  v_sum_a;
      ELSIF pncodparcon = 3 THEN
        v_cantidad := v_sum_a - v_sum_c;
      ELSIF pncodparcon = 4 THEN
          SELECT SUM(TO_NUMBER(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ITOTALR_FIC, CHR(10) , ''), CHR(13) , ''), '.', ''), ',', '.'), '$',''))))--05/09/2019 SGM IAXIS-4511 CONCILIACION DE CARTERA
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND cestado != 0;
      -- SGM IAXIS 4060 CONCILIACIONES DE CARTERA       
      ELSIF pncodparcon = 5 THEN
          SELECT SUM(TO_NUMBER(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ITOTALR_FIC, CHR(10) , ''), CHR(13) , ''), '.', ''), ',', '.'), '$',''))))
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND cestado = 0;
      ELSIF pncodparcon = 6 THEN
          SELECT SUM(TO_NUMBER(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ITOTALR_FIC, CHR(10) , ''), CHR(13) , ''), '.', ''), ',', '.'), '$',''))))
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND cestado = 9;--IAXIS 4060 SGM  12/06/2019  se agregan ficheros a cruces cartera
      ELSIF pncodparcon = 7 THEN
          SELECT SUM(TO_NUMBER(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ITOTALR_FIC, CHR(10) , ''), CHR(13) , ''), '.', ''), ',', '.'), '$',''))))
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND cestado = 1;
           
      ELSIF pncodparcon = 8 THEN

         /* SELECT SUM(TO_NUMBER(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(A.ITOTALR_FIC, CHR(10) , ''), CHR(13) , ''), '.', ''), ',', '.'), '$',''))))
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET A, GCA_CONCILIACIONDET B
           WHERE A.sidcon = psidcon
             AND A.CREPETIDO = 0
             AND A.cestado = 1
             AND B.CREPETIDO = 0
             AND B.cestado = 1
             AND A.NRECIBO_FIC = B.NRECIBO_FIC
             AND A.NPOLIZA_FIC = B.NPOLIZA_FIC
             AND A.SIDCON != B.SIDCON;*/
        SELECT SUM(TO_NUMBER(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ITOTALR_FIC, CHR(10) , ''), CHR(13) , ''), '.', ''), ',', '.'), '$','')))) 
          INTO v_cantidad FROM 
        (SELECT DISTINCT *
          FROM GCA_CONCILIACIONDET gd, GCA_CONCILIACIONCAB gc
         WHERE gd.sidcon = gc.sidcon
           AND gd.sidcon <> psidcon
           and gd.sidcon in (Select gc2.sidcon from GCA_CONCILIACIONCAB gc2 where gc2.cfichero = (select gc3.cfichero from GCA_CONCILIACIONCAB gc3 where sidcon = psidcon))
           AND gd.cestado <> 0
           AND ((instr(gd.tobserva,'CONCILIADO EN ',1,1) = 0) or (gd.tobserva is NULL)));             
      ELSIF pncodparcon = 9 THEN
          SELECT SUM(TO_NUMBER(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ITOTALR_FIC, CHR(10) , ''), CHR(13) , ''), '.', ''), ',', '.'), '$',''))))
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND cestado = 6;
      ELSIF pncodparcon = 10 THEN
          SELECT SUM(TO_NUMBER(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ITOTALR_FIC, CHR(10) , ''), CHR(13) , ''), '.', ''), ',', '.'), '$',''))))
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND cestado = 7;
      ELSIF pncodparcon = 11 THEN
          SELECT SUM(TO_NUMBER(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ITOTALR_FIC, CHR(10) , ''), CHR(13) , ''), '.', ''), ',', '.'), '$',''))))
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND cestado = 8;
      ELSIF pncodparcon = 12 THEN
          SELECT SUM(TO_NUMBER(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ITOTALR_FIC, CHR(10) , ''), CHR(13) , ''), '.', ''), ',', '.'), '$',''))))
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND cestado = 3;
      ELSIF pncodparcon = 13 THEN
          SELECT SUM(TO_NUMBER(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ITOTALR_FIC, CHR(10) , ''), CHR(13) , ''), '.', ''), ',', '.'), '$',''))))
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND cestado = 4;
      ELSIF pncodparcon = 14 THEN
          SELECT SUM(TO_NUMBER(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ITOTALR_FIC, CHR(10) , ''), CHR(13) , ''), '.', ''), ',', '.'), '$',''))))
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND cestado = 2;
      ELSIF pncodparcon = 15 THEN
          SELECT SUM(TO_NUMBER(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ITOTALR_FIC, CHR(10) , ''), CHR(13) , ''), '.', ''), ',', '.'), '$',''))))
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND cestado = 5;
      ELSIF pncodparcon = 16 THEN

        SELECT NVAL1
          INTO v_valor_subtab
          FROM SGT_SUBTABS_DET
         WHERE CSUBTABLA = 9000002
           AND CVERSUBT = (SELECT MAX(CVERSUBT) FROM SGT_SUBTABS_VER WHERE CSUBTABLA = 9000002)
           AND NVAL7 = 'ALTO IMPACTO';
          SELECT SUM(ITOTALR)
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND NVL(ITOTALR,0) > v_valor_subtab;

      ELSIF pncodparcon = 17 THEN
        SELECT NVAL1
          INTO v_valor_subtab
          FROM SGT_SUBTABS_DET
         WHERE CSUBTABLA = 9000002
           AND CVERSUBT = (SELECT MAX(CVERSUBT) FROM SGT_SUBTABS_VER WHERE CSUBTABLA = 9000002)
           AND NVAL7 = 'DIAS MORA';
          SELECT SUM(ITOTALR)
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND NVL(NMADUREZ,0) > v_valor_subtab;

      ELSIF pncodparcon = 18 THEN
        SELECT NVAL1
          INTO v_valor_subtab
          FROM SGT_SUBTABS_DET
         WHERE CSUBTABLA = 9000002
           AND CVERSUBT = (SELECT MAX(CVERSUBT) FROM SGT_SUBTABS_VER WHERE CSUBTABLA = 9000002)
           AND NVAL7 = 'DIAS PROVISION';
          SELECT SUM(ITOTALR)
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND NVL(NMADUREZ,0) > v_valor_subtab;
      ELSIF pncodparcon = 19 THEN
        SELECT NVAL1
          INTO v_valor_subtab
          FROM SGT_SUBTABS_DET
         WHERE CSUBTABLA = 9000002
           AND CVERSUBT = (SELECT MAX(CVERSUBT) FROM SGT_SUBTABS_VER WHERE CSUBTABLA = 9000002)
           AND NVAL7 = 'MADUREZ MINIMA PARA CANCELACION';
          SELECT SUM(ITOTALR)
            INTO v_cantidad
            FROM GCA_CONCILIACIONDET
           WHERE sidcon = psidcon
             AND CREPETIDO = 0
             AND NVL(NMADUREZ,0) > v_valor_subtab;
      END IF;

      RETURN v_cantidad;
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
   END f_get_valor_acta_con;
   FUNCTION f_get_gca_mapeo(
      pcfichero IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'pac_iax_gestion_car.f_get_gca_mapeo';
   BEGIN
      v_cursor := pac_md_gestion_car.f_get_gca_mapeo(pcfichero, mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_gca_mapeo;

   FUNCTION f_set_gca_mapeo(
      pcfichero IN NUMBER,
      ptcolir IN VARCHAR2,
      ptcoldest IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'pac_iax_gestion_car.f_set_gca_mapeo';
      cont           NUMBER;
   BEGIN
      RETURN pac_md_gestion_car.f_set_gca_mapeo(pcfichero, ptcolir, ptcoldest, mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_gca_mapeo;
END pac_iax_gestion_car;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_GESTION_CAR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GESTION_CAR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GESTION_CAR" TO "PROGRAMADORESCSI";
