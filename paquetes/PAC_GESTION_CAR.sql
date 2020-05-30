--------------------------------------------------------
--  DDL for Package PAC_GESTION_CAR
--------------------------------------------------------

  CREATE OR REPLACE  PACKAGE PAC_GESTION_CAR IS
   FUNCTION f_get_gca_parampre_conc(
      pncodparcon IN NUMBER,
      pcodseccion IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_gca_parampre_conc(
      pncodparcon IN NUMBER,
      pcodseccion IN NUMBER,
      pcidioma IN NUMBER,
      ppregunta IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_gca_conciliacioncab(
      psidcon IN NUMBER,
      pacon IN NUMBER,
      pmcon IN NUMBER,
      pcsucursal IN NUMBER,
      pnnumideage IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_gca_conciliacioncab(
      psidcon IN NUMBER,
      pacon IN NUMBER,
      pmcon IN NUMBER,
      pcsucursal IN NUMBER,
      pnnumideage IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

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
      RETURN NUMBER;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

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
      RETURN NUMBER;

   FUNCTION f_del_gca_conciliacion_acta(
      pnconciact IN NUMBER,
      psidcon IN NUMBER,
      pcconacta IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_gca_conciliacion_acta(
      pnconciact IN NUMBER,
      psidcon IN NUMBER,
      pcconacta IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

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
      RETURN NUMBER;

   FUNCTION f_get_gestion_cartera_recobro(
      pnnumide IN VARCHAR2,
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
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_depu_saldofavcli(
      ppercorte IN DATE,
      pcpendientes IN NUMBER,
      pcsucursal IN NUMBER,
      pnnumideage IN NUMBER,
      pnnumidecli IN NUMBER,--  IAXIS-7653 - SGM
      pfdocini IN DATE,
      pfdocfin IN DATE,
      pndocsap IN NUMBER,
      pfcontini IN DATE,
      pfcontfin IN DATE,
      pntipo IN NUMBER,
      pnopcion IN NUMBER,
      pnmodo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_del_sin_apuntes_rec(
      pidobs_gr IN NUMBER,
      pnsinies_r IN NUMBER,
      pntramit_r IN NUMBER,
      pnpoliza_r IN NUMBER,
      pttitobs IN VARCHAR2,
      pfalta_gr IN DATE,
      pcusualt_gr IN VARCHAR2,
      ptobs IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_sin_apuntes_rec(
      pidobs_gr IN NUMBER,
      pnsinies_r IN NUMBER,
      pntramit_r IN NUMBER,
      pnpoliza_r IN NUMBER,
      pttitobs IN VARCHAR2,
      pfalta_gr IN DATE,
      pcusualt_gr IN VARCHAR2,
      ptobs IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

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
      RETURN NUMBER;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_gca_cargaconc(
      pcempres IN NUMBER,
      pcfichero IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

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
      RETURN NUMBER;

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
      RETURN NUMBER;

   FUNCTION f_get_gca_docgsfavcli(pidobs IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_ins_gca_docgsfavcli(
      pidobs IN NUMBER,
      piddocgdx IN NUMBER,
      pctipo IN NUMBER,
      ptobserv IN VARCHAR2,
      ptfilename IN VARCHAR2,
      pfcaduci IN DATE,
      pfalta IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_gca_docgsfavclis(pidobs IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;


   FUNCTION f_get_gca_mapeo(
      pcfichero IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_gca_mapeo(
      pcfichero IN NUMBER,
      ptcolir IN VARCHAR2,
      ptcoldest IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_gestion_car;

/

