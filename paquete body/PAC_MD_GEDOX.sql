create or replace PACKAGE BODY pac_md_gedox AS
/******************************************************************************
   NOMBRE:      PAC_MD_GEDOX
   PROPÃ¿SITO: Funciones para la gestiÃ³n de la comunicaciÃ³n con GEDOX

   REVISIONES:
   Ver        Fecha        Autor             DescripciÃ³n
   ---------  ----------  ---------------  ------------------------------------
   1.0        30/01/2008   JTS                1. CreaciÃ³n del package.
   2.0        12/03/2009   DCT                2. Modificar F_Get_DocumMov
   3.0        11/02/2010   XPL                3. 0012116: CEM - SINISTRES: Adjuntar documentaciÃ³ manualment i guardar-la al GEDOX
   4.0        06/02/2012   FPG                4. 0020975: LCOL999 - modificaciones de los perfiles
   5.0        30/05/2012   MDS                5. 0022267: LCOL_P001 - PER - DocumentaciÃ³n obligatoria subir a Gedox y si es persona o pÃ³liza
   6.0        30/10/2012   FPG                6. 0028129: LCOL899-Desarrollo interfases BPM-iAXIS
   7.0        04/11/2013   RCL                7. 0028263: LCOL899-Proceso EmisiÃ³n Vida Grupo - Desarrollo modificaciones de iAxis para BPM
   8.0        27/02/2014   AQ                 8. 0030302: CALI706-Perfils documentaciÃ³
   9.0        01/07/2014   ALF                6. modificacio f_set_documgedox per rebre parametre pidfichero
   9.1        06/10/2016   NMM                9.1.CONF-337. PARAM PDIR f_set_documpersgedox
   10.0       25/08/2016   JAVENDANO          10. CONF-236 ActualizaciÃ³n para fechas de archivado, eliminaciÃ³n y caducidad de los documentos
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /***********************************************************************
      Recupera los documentos asociados a un movimiento de un seguro
      param in psseguro  : cÃ³digo de seguro
      param in pnmovimi  : nÃºmero de movimiento del seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_docummov(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pusuari IN VARCHAR2,
      pcempres IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_GEDOX.F_Get_DocumMov';
      vparam         VARCHAR2(500)
         := 'parÃ¡metros - psseguro: ' || psseguro || ' - nmovimi: ' || pnmovimi
            || ' - pusuari: ' || pusuari || ' - pcempres:' || pcempres;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vccfgdoc       VARCHAR2(50);
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(2000);
      vcagente       NUMBER;
      vbloqueo       NUMBER;
   BEGIN
      --ComprovaciÃ³ dels parÃ¡metres d'entrada
      IF psseguro IS NULL
         OR pnmovimi IS NULL
         OR pusuari IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Miramos si la persona esta bloqueada por LOPD. Ya sea tomador, asegurado, riesgo, benficiario
      vbloqueo := pac_persona.f_esta_persona_bloqueada(psseguro, vcagente);
--------------
--Recuperamos el perfil de documentos para ese usuario y empresa
      vnumerr := pac_cfg.f_get_user_cfgdoc(pusuari, pcempres, vccfgdoc);

------------------------------------------------------------------------
--AQ                 8. 0030302: CALI706-Perfils documentaciÃ³
------------------------------------------------------------------------
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'NO_DOC'), 0) = 1 THEN
         IF vccfgdoc IS NULL THEN
            vccfgdoc := 'CFG_NO_DOC';
         END IF;
      END IF;

----------------------------------------------------------------------------
--FI AQ                 8. 0030302: CALI706-Perfils documentaciÃ³
----------------------------------------------------------------------------

      -- 06-02-2012 - FPG - 0020975: LCOL999 - modificaciones de los perfiles
-- Incluir condicion en la documentaciÃ³n requerida (iddocgedox no nulo)
      vsquery :=
         ' select d.iddocgedox iddoc, pac_axisgedox.f_get_descdoc(d.iddocgedox) tdescrip, '
         || ' decode(' || vbloqueo || ',1,1, (select c.tipo from cfg_doc c where c.cempres = '
         || pcempres || ' and c.ccfgdoc = ' || CHR(39) || vccfgdoc || CHR(39)
         || ' and c.idcat = pac_axisgedox.f_get_Catdoc(d.iddocgedox))) tipo, '
         || ' substr(pac_axisgedox.f_get_filedoc(d.iddocgedox),instr(pac_axisgedox.f_get_filedoc(d.iddocgedox),''\'',-1)+1,length(pac_axisgedox.f_get_filedoc(d.iddocgedox))) fichero, '
         || ' pac_axisgedox.f_get_farchiv(d.iddocgedox) farchiv, pac_axisgedox.f_get_fcaduci(d.iddocgedox) fcaduci,  pac_axisgedox.f_get_felimin(d.iddocgedox) felimin '
         || ' from docummovseg d where upper(pac_axisgedox.f_get_descdoc(d.iddocgedox)) not like ''EXC%'' and d.sseguro = ' || psseguro || ' and d.nmovimi = '
         || pnmovimi || ' and pac_axisgedox.f_get_Catdoc(d.iddocgedox) NOT IN (Select idcat '
         || ' from cfg_doc ' || ' where cempres = ' || pcempres || ' and ccfgdoc = ' || CHR(39)
         || vccfgdoc || CHR(39) || ' and tipo = 0 )'
         || ' and d.IDDOCGEDOX NOT IN (SELECT IDDOCGEDOX' || ' FROM docrequerida'
         || ' WHERE sseguro = d.sseguro'
         || ' AND nmovimi = d.nmovimi AND iddocgedox IS NOT NULL' || ' UNION'
         || ' SELECT IDDOCGEDOX' || ' FROM docrequerida_riesgo' || ' WHERE sseguro = d.sseguro'
         || ' AND nmovimi = d.nmovimi AND iddocgedox IS NOT NULL' || ' UNION'
         || ' SELECT IDDOCGEDOX' || ' FROM docrequerida_inqaval'
         || ' WHERE sseguro = d.sseguro'
         || ' AND nmovimi = d.nmovimi AND iddocgedox IS NOT NULL' || ' UNION'
         || ' SELECT IDDOCGEDOX' || ' FROM docrequerida_benespseg'
         || ' WHERE sseguro = d.sseguro'
         || ' AND nmovimi = d.nmovimi AND iddocgedox IS NOT NULL)';

      vpasexec := 3;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_docummov;

     /***********************************************************************
      Recupera los documentos de exclusion asociados a un movimiento de un seguro
      param in psseguro  : cÃ³digo de seguro
      param in pnmovimi  : nÃºmero de movimiento del seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_docummov_exc(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pusuari IN VARCHAR2,
      pcempres IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_GEDOX.F_Get_DocumMov';
      vparam         VARCHAR2(500)
         := 'parÃ¡metros - psseguro: ' || psseguro || ' - nmovimi: ' || pnmovimi
            || ' - pusuari: ' || pusuari || ' - pcempres:' || pcempres;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vccfgdoc       VARCHAR2(50);
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(2000);
      vcagente       NUMBER;
      vbloqueo       NUMBER;
   BEGIN
      --ComprovaciÃ³ dels parÃ¡metres d'entrada
      IF psseguro IS NULL
         OR pnmovimi IS NULL
         OR pusuari IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Miramos si la persona esta bloqueada por LOPD. Ya sea tomador, asegurado, riesgo, benficiario
      vbloqueo := pac_persona.f_esta_persona_bloqueada(psseguro, vcagente);
--------------
--Recuperamos el perfil de documentos para ese usuario y empresa
      vnumerr := pac_cfg.f_get_user_cfgdoc(pusuari, pcempres, vccfgdoc);

------------------------------------------------------------------------
--AQ                 8. 0030302: CALI706-Perfils documentaciÃ³
------------------------------------------------------------------------
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'NO_DOC'), 0) = 1 THEN
         IF vccfgdoc IS NULL THEN
            vccfgdoc := 'CFG_NO_DOC';
         END IF;
      END IF;

----------------------------------------------------------------------------
--FI AQ                 8. 0030302: CALI706-Perfils documentaciÃ³
----------------------------------------------------------------------------

      -- 06-02-2012 - FPG - 0020975: LCOL999 - modificaciones de los perfiles
-- Incluir condicion en la documentaciÃ³n requerida (iddocgedox no nulo)
      vsquery :=
         ' select d.iddocgedox iddoc, SUBSTR(pac_axisgedox.f_get_descdoc(d.iddocgedox),5) tdescrip, '
         || ' decode(' || vbloqueo || ',1,1, (select c.tipo from cfg_doc c where c.cempres = '
         || pcempres || ' and c.ccfgdoc = ' || CHR(39) || vccfgdoc || CHR(39)
         || ' and c.idcat = pac_axisgedox.f_get_Catdoc(d.iddocgedox))) tipo, '
         || ' substr(pac_axisgedox.f_get_filedoc(d.iddocgedox),instr(pac_axisgedox.f_get_filedoc(d.iddocgedox),''\'',-1)+1,length(pac_axisgedox.f_get_filedoc(d.iddocgedox))) fichero, '
         || ' pac_axisgedox.f_get_farchiv(d.iddocgedox) farchiv, pac_axisgedox.f_get_fcaduci(d.iddocgedox) fcaduci,  pac_axisgedox.f_get_felimin(d.iddocgedox) felimin '
         || ' from docummovseg d where '
		 || ' upper(pac_axisgedox.f_get_descdoc(d.iddocgedox)) like ''EXC%'' and '
		 || ' d.sseguro = ' || psseguro || ' and d.nmovimi = '
         || pnmovimi || ' and pac_axisgedox.f_get_Catdoc(d.iddocgedox) NOT IN (Select idcat '
         || ' from cfg_doc ' || ' where cempres = ' || pcempres || ' and ccfgdoc = ' || CHR(39)
         || vccfgdoc || CHR(39) || ' and tipo = 0 )'
         || ' and d.IDDOCGEDOX NOT IN (SELECT IDDOCGEDOX' || ' FROM docrequerida'
         || ' WHERE sseguro = d.sseguro'
         || ' AND nmovimi = d.nmovimi AND iddocgedox IS NOT NULL' || ' UNION'
         || ' SELECT IDDOCGEDOX' || ' FROM docrequerida_riesgo' || ' WHERE sseguro = d.sseguro'
         || ' AND nmovimi = d.nmovimi AND iddocgedox IS NOT NULL' || ' UNION'
         || ' SELECT IDDOCGEDOX' || ' FROM docrequerida_inqaval'
         || ' WHERE sseguro = d.sseguro'
         || ' AND nmovimi = d.nmovimi AND iddocgedox IS NOT NULL' || ' UNION'
         || ' SELECT IDDOCGEDOX' || ' FROM docrequerida_benespseg'
         || ' WHERE sseguro = d.sseguro'
         || ' AND nmovimi = d.nmovimi AND iddocgedox IS NOT NULL)';

      vpasexec := 3;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_docummov_exc;






   /***********************************************************************
      Recupera los documentos asociados a un movimiento de un seguro
      param out mensajes : missatge d'error
      return             : 0/1 -> Tot OK/Error
   ***********************************************************************/
   FUNCTION f_get_idfichero(pid OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_GEDOX.F_Get_IdFichero';
      vparam         VARCHAR2(500) := 'parÃ¡metros - sin';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(1) := 0;
   BEGIN
      vnumerr := pac_axisgedox.f_get_secuencia(pid);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_idfichero;

   /***********************************************************************
      Recupera un path de directori
      param in pparam : valor de path
      param out ppath    : pÃ¡rametre GEDOX
      param out mensajes : missatge d'error
      return             : 0/1 -> Tot OK/Error
   ***********************************************************************/
   FUNCTION f_get_directorio(
      pparam IN VARCHAR2,
      ppath OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_GEDOX.F_Get_Directorio';
      vparam         VARCHAR2(500) := 'parÃ¡metros - pparam: ' || pparam;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(1) := 0;
   BEGIN
      ppath := pac_axisgedox.buscaparametro_t(pparam);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_directorio;

   /*************************************************************************
      FunciÃ³n que grava a GEDOX un fitxer ja generat en el directory compartit de GEDOX.
      param in psseguro    : AsseguranÃ³a a la que cal vincular la
                             impressiÃ³.
      param in pnmovimi    : Moviment al que pertany la impressiÃ³.
      param in puser       : Usuari que realitza la gravaciÃ³ del document.
      param in ptfilename  : Nom del fitxer a pujar al GEDOX.
      param in pnfilename  : Id del fitxer a pujar al GEDOX (fisic).
      param in pidfichero  : DescripciÃ³ del fitxer a pujar al GEDOX.
      param in pidcat      : Categoria del fitxer a pujar al GEDOX.
      param out mensajes   : Missatges d'error.
      return               : 0/1 -> Tot OK/Error

   *************************************************************************/
   --11/02/2010#XPL#12116#Es canvia el nom de la funciÃ³, per a que sigui mÃ©s especific
   FUNCTION f_set_docummovseggedox(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      puser IN VARCHAR2,
      ptfilename IN VARCHAR2,
      pidfichero IN OUT VARCHAR2,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      porigen IN NUMBER DEFAULT 0,
      mensajes IN OUT t_iax_mensajes,
      pctipdest IN NUMBER DEFAULT 1   -- Bug 22267 - MDS - 30/05/2012
                                   )
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'psseguro: ' || psseguro || ' - pnmovimi:
' ||        pnmovimi || ' - puser: ' || puser || ' - ptfilename: ' || ptfilename
            || ' - ptdesc:
' ||        ptdesc || ' - pidcat: ' || pidcat;
      vobjectname    VARCHAR2(200) := 'PAC_MD_GEDOX.F_Set_DocumGedox';
      vterror        VARCHAR2(1000);
      viddoc         NUMBER(8) := 0;
      vidfichero     VARCHAR2(100);
      v_sperson      tomadores.sperson%TYPE;   -- Bug 22267 - MDS - 30/05/2012
      v_cagente      seguros.cagente%TYPE;   -- Bug 22267 - MDS - 30/05/2012
      vfarchiv       DATE;   --CONF 236 JAAB
      vfelimin       DATE;   --CONF 236 JAAB
      vfcaduci       DATE;   --CONF 236 JAAB
   BEGIN
      --INI JAAB CONF-236 22/08/2016
      vfarchiv := f_calcula_fecha_aec(1);
      vfcaduci := f_calcula_fecha_aec(2);
      vfelimin := f_calcula_fecha_aec(3);

      --FIN JAAB CONF 236 22/08/2016

    p_control_error('PRD_DOC_GEDOX',vobjectname,'vparam:' || vparam);
      --ComprovaciÃ³ de parÃ¡metres d'entrada
      IF psseguro IS NULL
         OR pnmovimi IS NULL
         OR puser IS NULL
         OR ptfilename IS NULL
         OR pidcat IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Gravem la capÃ³alera del document.
      --pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc); --JAAB CONF 236
      pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc,
                                  vfarchiv, vfelimin, vfcaduci);

      IF vterror IS NOT NULL
         OR NVL(viddoc, 0) = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      --Gravem a la BD el fiter en qÃ³estiÃ³ pidfichero .
      p_control_error('PRD_DOC_GEDOX',vobjectname,'pidfichero:' || pidfichero);
      pac_axisgedox.actualiza_gedoxdb(ptfilename/*pidfichero*/, viddoc, vterror);
      pidfichero := viddoc;
      p_control_error('PRD_DOC_GEDOX',vobjectname,'vterror:' || vterror);

      IF vterror IS NOT NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      INSERT INTO docummovseg
                  (sseguro, nmovimi, iddocgedox, corigen)
           VALUES (psseguro, pnmovimi, viddoc, porigen);

      -- Ini Bug 22267 - MDS - 30/05/2012
      vpasexec := 6;

      IF pctipdest = 2 THEN
         vpasexec := 7;

         SELECT sperson
           INTO v_sperson
           FROM tomadores
          WHERE sseguro = psseguro
            AND nordtom = (SELECT MIN(nordtom)
                             FROM tomadores
                            WHERE sseguro = psseguro);

         vpasexec := 8;

         SELECT cagente
           INTO v_cagente
           FROM seguros
          WHERE sseguro = psseguro;

         vpasexec := 9;

         INSERT INTO per_documentos
                     (sperson, cagente, iddocgedox)
              VALUES (v_sperson, ff_agente_cpervisio(v_cagente), viddoc);
      END IF;
     -- ML CORRECCION BUG PAC_LOG.F_LOG_ACTIVIDAD 180856
	  --vterror := pac_md_log.f_log_actividad('axisgedox', 1, viddoc, NULL, NULL, ptfilename, mensajes);
      -- Ini Bug 22267 - MDS - 30/05/2012
      COMMIT;      

      --ProcÃ³s finalitzat correctament.
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_docummovseggedox;

   /*************************************************************************
      FunciÃ³n que grava a GEDOX un fitxer ja generat en el directory compartit de GEDOX.
      I actualitzar la taula sin_tramita_documento amb iddoc del gedox
      param in pnsinies    : NÃºm Sinistre
      param in pntramit    : NÃºm. TramitaciÃ³
      param in pndocume    : id intern de la taula sin_tramita_documentos
      param in ptfilename  : Nom del fitxer a pujar al GEDOX.
      param in pnfilename  : Id del fitxer a pujar al GEDOX (fisic).
      param in pidfichero  : DescripciÃ³ del fitxer a pujar al GEDOX.
      param in pidcat      : Categoria del fitxer a pujar al GEDOX.
      param in porigen      : Origen (SINISTRES, CONS.POL...)
      param in out mensajes   : Missatges d'error.
      return               : 0/1 -> Tot OK/Error

   *************************************************************************/
   --11/02/2010#XPL#12116#0012116: CEM - SINISTRES: Adjuntar documentaciÃ³ manualment i guardar-la al GEDOX
   FUNCTION f_set_documsinistresgedox(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      pndocume IN NUMBER,
      puser IN VARCHAR2,
      ptfilename IN VARCHAR2,
      pidfichero IN NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      porigen IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'pnsinies: ' || pnsinies || ' - pntramit:' || pntramit || ' - pndocume: ' || pndocume
            || ' - puser: ' || puser || ' - ptfilename: ' || ptfilename || ' - pidfichero: ' || pidfichero

            || ' - ptdesc: ' || ptdesc || ' - pidcat: ' || pidcat || ' - porigen: ' || porigen;
      vobjectname    VARCHAR2(200) := 'PAC_MD_GEDOX.F_Set_documsinistresgedox';
      vterror        VARCHAR2(1000);
      viddoc         NUMBER(8) := 0;
      vfarchiv       DATE;   --CONF 236 JAAB
      vfelimin       DATE;   --CONF 236 JAAB
      vfcaduci       DATE;   --CONF 236 JAAB

   	 Wdir  VARCHAR2(200) DEFAULT NULL ;  -- DVA 17/08/2017 DATECSA
       vcaccion    NUMBER;  -- DVA 17/08/2017 DATECSA
       vnumerr        NUMBER(10) := 0;-- DVA 17/08/2017 DATECSA
   BEGIN
      --INI JAAB CONF-236 22/08/2016
      vfarchiv := f_calcula_fecha_aec(1);
      vfcaduci := f_calcula_fecha_aec(2);
      vfelimin := f_calcula_fecha_aec(3);

      --FIN JAAB CONF 236 22/08/2016

      --ComprovaciÃ³ de parÃ¡metres d'entrada
      IF pnsinies IS NULL
         OR pntramit IS NULL
         OR pndocume IS NULL
         OR puser IS NULL
         OR ptfilename IS NULL
         OR pidcat IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Gravem la capÃ³alera del document.
      --pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc); --JAAB CONF 236
      pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc,
                                  vfarchiv, vfelimin, vfcaduci);

      IF vterror IS NOT NULL
         OR NVL(viddoc, 0) = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      --Gravem a la BD el fiter en qÃ³estiÃ³ pidfichero .
 --     pac_axisgedox.actualiza_gedoxdb(pidfichero, viddoc, vterror);
      IF porigen='DATECSA'  THEN -- DVA 17/08/2017 DATECSA INICIO
        Wdir := porigen;
      END IF;
      pac_axisgedox.actualiza_gedoxdb(ptfilename, viddoc, vterror,Wdir);
      IF vterror IS NOT NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

	  if Wdir='DATECSA' THEN
       vnumerr := pac_siniestros.f_ins_documento(pnsinies, pntramit,pndocume, 1215,vfarchiv
                                         , vfarchiv,vfcaduci,0, ptdesc, vcaccion);
            IF vnumerr <> 0
            THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vnumerr);
              RAISE e_object_error;
            END IF;

     END IF; 			        -- DVA 17/08/2017 DATECSA FIN
      UPDATE sin_tramita_documento
         SET iddoc = viddoc
       WHERE nsinies = pnsinies
         AND ntramit = pntramit
         AND ndocume = pndocume;

      COMMIT;
      vterror := pac_md_log.f_log_actividad('axisgedox', 1, viddoc, NULL, NULL, ptfilename,
                                            mensajes);
      --ProcÃ³s finalitzat correctament.
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_documsinistresgedox;

   /***********************************************************************
      Recupera las categories
      param in pcidioma   : codi idioma
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_categor(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_GEDOX.F_Get_Categor';
      vparam         VARCHAR2(500) := 'parÃ¡metros';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcursor        sys_refcursor;
   BEGIN
      vcursor := pac_axisgedox.f_lista_categorias(pac_md_common.f_get_cxtidioma());
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_categor;

   /*************************************************************************
      VisualizaciÃ³n de un documento almacenado en GEDOX
      param in piddoc      : Id. del documento que se debe visualizar
      param out ptpath     : Ruta del fichero que se debe visualizar
      param out mensajes   : mensajes de error
      return               : 0/1 -> Ok/Error
   *************************************************************************/
   FUNCTION f_gedox_verdoc(piddoc IN NUMBER, optpath OUT VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_GEDOX.F_Gedox_VerDoc';
      vparam         VARCHAR2(500) := 'parÃ¡metros - piddoc: ' || piddoc;
      vpasexec       NUMBER(5) := 0;
      vnumerr        NUMBER(8) := 1;
      vtfichero      VARCHAR2(100);
      vtfichpath     VARCHAR2(250);
   BEGIN
      --ComprovaciÃ³ dels parÃ¡metres d'entrada
      IF piddoc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      pac_axisgedox.verdoc(piddoc, vtfichero, vnumerr);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      pac_axisgedox.actualizacabecera_click(piddoc);
      COMMIT;
      vtfichpath := pac_md_common.f_get_parinstalacion_t('INFORMES_SERV');
      optpath := vtfichpath || '\' || vtfichero;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_gedox_verdoc;

   /***********************************************************************
      Recupera los documentos asociados a un movimiento de un seguro
      param in psseguro  : cÃ³digo de seguro
      param in pnmovimi  : nÃºmero de movimiento del seguro
      param out mensajes : mensajes de error
      return             : ref cursor
   ***********************************************************************/
   FUNCTION f_get_docummov_requerida(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pusuari IN VARCHAR2,
      pcempres IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_GEDOX.f_get_docummov_requerida';
      vparam         VARCHAR2(500)
         := 'parÃ¡metros - psseguro: ' || psseguro || ' - nmovimi: ' || pnmovimi
            || ' - pusuari: ' || pusuari || ' - pcempres:' || pcempres;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vccfgdoc       VARCHAR2(50);
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(2000);
   BEGIN
      --ComprovaciÃ³ dels parÃ¡metres d'entrada
      IF psseguro IS NULL
         OR pnmovimi IS NULL
         OR pusuari IS NULL
         OR pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

--------------
--Recuperamos el perfil de documentos para ese usuario y empresa
      vnumerr := pac_cfg.f_get_user_cfgdoc(pusuari, pcempres, vccfgdoc);
--------------
-- 06-02-2012 - FPG - 0020975: LCOL999 - modificaciones de los perfiles
-- Incluir condicion en la documentaciÃ³n requerida (iddocgedox no nulo)
      vsquery :=
         ' select d.iddocgedox iddoc, pac_axisgedox.f_get_descdoc(d.iddocgedox) tdescrip, '
         || ' (select c.tipo from cfg_doc c where c.cempres = ' || pcempres
         || ' and c.ccfgdoc = ' || CHR(39) || vccfgdoc || CHR(39)
         || ' and c.idcat = pac_axisgedox.f_get_Catdoc(d.iddocgedox)) tipo, '
         || ' substr(pac_axisgedox.f_get_filedoc(d.iddocgedox),instr(pac_axisgedox.f_get_filedoc(d.iddocgedox),''\'',-1)+1,length(pac_axisgedox.f_get_filedoc(d.iddocgedox))) fichero, '
         || ' pac_axisgedox.f_get_farchiv(d.iddocgedox) farchiv, pac_axisgedox.f_get_fcaduci(d.iddocgedox) fcaduci,  pac_axisgedox.f_get_felimin(d.iddocgedox) felimin '
         || ' from docummovseg d where d.sseguro = ' || psseguro || ' and d.nmovimi = '
         || pnmovimi || ' and pac_axisgedox.f_get_Catdoc(d.iddocgedox) NOT IN (Select idcat '
         || ' from cfg_doc ' || ' where cempres = ' || pcempres || ' and ccfgdoc = ' || CHR(39)
         || vccfgdoc || CHR(39) || ' and tipo = 0 )'
         || ' and d.IDDOCGEDOX IN (SELECT IDDOCGEDOX' || ' FROM docrequerida'
         || ' WHERE sseguro = d.sseguro'
         || ' AND nmovimi = d.nmovimi AND iddocgedox IS NOT NULL' || ' UNION'
         || ' SELECT IDDOCGEDOX' || ' FROM docrequerida_riesgo' || ' WHERE sseguro = d.sseguro'
         || ' AND nmovimi = d.nmovimi AND iddocgedox IS NOT NULL' || ' UNION'
         || ' SELECT IDDOCGEDOX' || ' FROM docrequerida_inqaval'
         || ' WHERE sseguro = d.sseguro'
         || ' AND nmovimi = d.nmovimi AND iddocgedox IS NOT NULL' || ' UNION'
         || ' SELECT IDDOCGEDOX' || ' FROM docrequerida_benespseg'
         || ' WHERE sseguro = d.sseguro'
         || ' AND nmovimi = d.nmovimi AND iddocgedox IS NOT NULL)';
      vpasexec := 3;
      vcursor := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN vcursor;
      WHEN OTHERS THEN
         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN vcursor;
   END f_get_docummov_requerida;

   /*************************************************************************
      FunciÃ³n que inserta un documento en GEDOX  y hace el insert del registro
      de documentaciÃ³n en la tabla PER_DOCUMENTOS.
      param in psperson : Id. de la persona
      param in pcagente : codigo del agente
      param in puser : Usuario
      param in pfcaduca : Fecha de caducidad del documento
      param in ptobserva : Observaciones
      param in ptfilename : Nombre del fichero
      param in out piddocgedox : Identificador del documento GEDOX
      param in ptdesc : Descripcion
      param in pidcat : CategorÃ¿Â­a del documento
      param in ptdocumento : Tipo del documento
      param in pedocumento : Estado del documento
      param in pfedo : Fecha de estado del documento
      param out mensajes   : mensajes de error
      return               : 0/1 -> Ok/Error
   *************************************************************************/
   FUNCTION f_set_documpersgedox(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      puser IN VARCHAR2,
      pfcaduca IN DATE,
      ptobserva IN VARCHAR2,
      ptfilename IN VARCHAR2,
      piddocgedox IN OUT NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      ptdocumento IN NUMBER DEFAULT NULL,
      pedocumento IN NUMBER DEFAULT NULL,
      pfedo IN DATE DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes,
      pdir IN VARCHAR2 DEFAULT NULL   -- NMM.CONF-337
                                   )
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'psperson: ' || psperson || ' - pcagente:
' ||        pcagente || ' - puser: ' || puser || ' - pfcaduca: ' || pfcaduca
            || ' - ptobserva: ' || ptobserva || ' - ptfilename: ' || ptfilename
            || ' - piddocgedox: ' || piddocgedox || ' - ptdesc:
' ||        ptdesc || ' - pidcat: ' || pidcat || ' - ptdocumento: ' || ptdocumento
            || ' - pedocumento: ' || pedocumento || ' - pfedo: ' || pfedo;
      vobjectname    VARCHAR2(200) := 'PAC_MD_GEDOX.f_set_documpersgedox';
      vterror        VARCHAR2(1000);
      viddoc         NUMBER(8) := 0;
      vidfichero     VARCHAR2(100);
      vnumerr        NUMBER;
      vfarchiv       DATE;   --CONF 236 JAAB
      vfelimin       DATE;   --CONF 236 JAAB
      vfcaduci       DATE;   --CONF 236 JAAB
   BEGIN
      --INI JAAB CONF-236 22/08/2016
      vfarchiv := f_calcula_fecha_aec(1);
      vfcaduci := f_calcula_fecha_aec(2);
      vfelimin := f_calcula_fecha_aec(3);

      --FIN JAAB CONF 236 22/08/2016

      --ComprovaciÃ³ de parÃ¡metres d'entrada
      IF psperson IS NULL
         OR pcagente IS NULL
         OR puser IS NULL
         OR ptfilename IS NULL
         OR pidcat IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Gravem la capÃ³alera del document.
       --pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc); --JAAB CONF 236
      pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc,
                                  vfarchiv, vfelimin, vfcaduci);

      IF vterror IS NOT NULL
         OR NVL(viddoc, 0) = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      --Gravem a la BD el fitxer en qÃºestiÃ³ pidfichero .documobservagedox
      p_control_error('SGM','f_set_documpersgedox',ptfilename||'-'|| viddoc||'-'|| vterror||'-'|| pdir);
      pac_axisgedox.actualiza_gedoxdb(ptfilename, viddoc, vterror, pdir);
      piddocgedox := viddoc;

      IF vterror IS NOT NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      vnumerr := pac_persona.f_set_docpersona(psperson, pcagente, pfcaduca, ptobserva,
                                              piddocgedox, ptdocumento, pedocumento, pfedo);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      COMMIT;
      vterror := pac_md_log.f_log_actividad('axisgedox', 1, viddoc, NULL, NULL, ptfilename,
                                            mensajes);
      --ProcÃ©s finalitzat correctament.
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_documpersgedox;

   /*************************************************************************
      FunciÃ¿Æ¿Ã¿Â³n que inserta un documento en GEDOX  y hace el insert del registro
      de documentaciÃ¿Æ¿Ã¿Â³n en la tabla PER_DOCUMENTOS.
      param in pcagente : codigo del agente
      param in puser : Usuario
      param in pfcaduca : Fecha de caducidad del documento
      param in ptobserva : Observaciones
      param in ptamano : TamaÃ¿Â±o del fichero
      param in ptfilename : Nombre del fichero
      param in out piddocgedox : Identificador del documento GEDOX
      param in ptdesc : Descripcion
      param in pidcat : CategorÃ¿Æ¿Ã¿Â­a del documento
      param out mensajes   : mensajes de error
      return               : 0/1 -> Ok/Error
   *************************************************************************/
   FUNCTION f_set_documagegedox(
      pcagente IN NUMBER,
      puser IN VARCHAR2,
      pfcaduca IN DATE,
      ptobserva IN VARCHAR2,
      ptamano IN VARCHAR2,
      ptfilename IN VARCHAR2,
      piddocgedox IN OUT NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'pcagente:' || pcagente || ' - puser: ' || puser || ' - pfcaduca: ' || pfcaduca
            || ' - ptobserva: ' || ptobserva || ' - ptfilename: ' || ptfilename
            || ' - piddocgedox: ' || piddocgedox || ' - ptdesc:' || ptdesc || ' - pidcat: '
            || pidcat || ' - ptamano:' || ptamano;
      vobjectname    VARCHAR2(200) := 'PAC_MD_GEDOX.f_set_documagegedox';
      vterror        VARCHAR2(1000);
      viddoc         NUMBER(8) := 0;
      vidfichero     VARCHAR2(100);
      vnumerr        NUMBER;
      vfarchiv       DATE;   --CONF 236 JAAB
      vfelimin       DATE;   --CONF 236 JAAB
      vfcaduci       DATE;   --CONF 236 JAAB
   BEGIN
      --INI JAAB CONF-236 22/08/2016
      vfarchiv := f_calcula_fecha_aec(1);
      vfcaduci := f_calcula_fecha_aec(2);
      vfelimin := f_calcula_fecha_aec(3);

      --FIN JAAB CONF 236 22/08/2016

      --ComprovaciÃ³n de parÃ¡metres d'entrada
      IF pcagente IS NULL
         OR puser IS NULL
         OR ptfilename IS NULL
         OR pidcat IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Gravem la capÃ³Ã³alera del document.
      --pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc); --JAAB CONF 236
      pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc,
                                  vfarchiv, vfelimin, vfcaduci);

      IF vterror IS NOT NULL
         OR NVL(viddoc, 0) = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      --Gravem a la BD el fiter en qÃ³Ã³estiÃ³Ã³ pidfichero .
      pac_axisgedox.actualiza_gedoxdb(ptfilename, viddoc, vterror);
      piddocgedox := viddoc;

      IF vterror IS NOT NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      vnumerr := pac_agentes.f_set_docagente(pcagente, pfcaduca, ptobserva, piddocgedox,
                                             ptamano);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      COMMIT;
      vterror := pac_md_log.f_log_actividad('axisgedox', 1, viddoc, NULL, NULL, ptfilename,
                                            mensajes);
      --ProcÃ³Ã³s finalitzat correctament.
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_documagegedox;

   FUNCTION f_get_tamanofit(
      pidgedox IN NUMBER,
      ptamano OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_GEDOX.f_get_tamanofit';
      vparam         VARCHAR2(500) := 'parametros pidgedox:' || pidgedox;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vtamano        NUMBER;
   BEGIN
      IF pidgedox IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_axisgedox.f_get_tamanofit(pidgedox, ptamano);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_tamanofit;

   FUNCTION f_set_documinspeccion(
      pcgenerado IN NUMBER,
      puser IN VARCHAR2,
      ptfilename IN VARCHAR2,
      pidfichero IN OUT VARCHAR2,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      porigen IN NUMBER DEFAULT 0,
      mensajes IN OUT t_iax_mensajes,
      pctipdest IN NUMBER DEFAULT 1,
      piddoc_out OUT NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := ' - puser: ' || puser || ' - ptfilename: ' || ptfilename || ' - ptdesc:
' ||        ptdesc || ' - pidcat: ' || pidcat;
      vobjectname    VARCHAR2(200) := 'PAC_MD_GEDOX.F_Set_documinspeccion';
      vterror        VARCHAR2(1000);
      viddoc         NUMBER(8) := 0;
      vidfichero     VARCHAR2(100);
      vndocume       NUMBER;
      vfarchiv       DATE;   --CONF 236 JAAB
      vfelimin       DATE;   --CONF 236 JAAB
      vfcaduci       DATE;   --CONF 236 JAAB
   BEGIN
      --INI JAAB CONF-236 22/08/2016
      vfarchiv := f_calcula_fecha_aec(1);
      vfcaduci := f_calcula_fecha_aec(2);
      vfelimin := f_calcula_fecha_aec(3);

      --FIN JAAB CONF 236 22/08/2016

      --ComprovaciÃ³ parÃ³Ã³tres d'entrada
      IF puser IS NULL
         OR ptfilename IS NULL
         OR pidcat IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Gravem la capÃ³Ã³era del document.
      --pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc); --JAAB CONF 236
      pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc,
                                  vfarchiv, vfelimin, vfcaduci);

      IF vterror IS NOT NULL
         OR NVL(viddoc, 0) = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      --Gravem a la BD el fiter en qÃ³estiÃ³dfichero .
      pac_axisgedox.actualiza_gedoxdb(ptfilename, viddoc, vterror);
      pidfichero := viddoc;

      IF vterror IS NOT NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

         /*   BEGIN
               SELECT ndocume + 1
                 INTO vndocume
                 FROM ir_inspecciones_doc
                WHERE cempres = pcempres
                  AND sorden = psorden
                  AND ninspeccion = pninspeccion;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vndocume := 1;
            END;

            INSERT INTO ir_inspecciones_doc
                        (cempres, sorden, ninspeccion, ndocume, cdocume, cgenerado, cobliga,
                         cadjuntado, iddocgedox)
                 VALUES (pcempres, psorden, pninspeccion, vndocume, psorden, pcgenerado, 0,
                         1, viddoc);
      */
      vpasexec := 6;
      COMMIT;
      vterror := pac_md_log.f_log_actividad('axisgedox', 1, viddoc, NULL, NULL, ptfilename,
                                            mensajes);
      --ProcÃ³Ã³finalitzat correctament.
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_documinspeccion;

   -- BUG 21192 / NSS / 21-03-13 --
   /*************************************************************************
      FunciÃ³ue inserta un documento en GEDOX  y hace el insert del registro
      de documentaciÃ³n la tabla SIN_PROF_DOC.
      param in psprofes : Id. del profesional
      param in puser : Usuario
      param in pfcaduca : Fecha de caducidad del documento
      param in ptobserva : Observaciones
      param in ptfilename : Nombre del fichero
      param in out piddocgedox : Identificador del documento GEDOX
      param in ptdesc : Descripcion
      param in pidcat : CategorÃ¯Â¿Â½del documento
      param out mensajes   : mensajes de error
      return               : 0/1 -> Ok/Error
   *************************************************************************/
   FUNCTION f_set_documprofgedox(
      psprofes IN NUMBER,
      puser IN VARCHAR2,
      pfcaduca IN DATE,
      ptobserva IN VARCHAR2,
      ptfilename IN VARCHAR2,
      piddocgedox IN OUT NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'psprofes: ' || psprofes || ' - puser: ' || puser || ' - pfcaduca: ' || pfcaduca
            || ' - ptobserva: ' || ptobserva || ' - ptfilename: ' || ptfilename
            || ' - piddocgedox: ' || piddocgedox || ' - ptdesc:' || ptdesc || ' - pidcat: '
            || pidcat;
      vobjectname    VARCHAR2(200) := 'PAC_MD_GEDOX.f_set_documprofgedox';
      vterror        VARCHAR2(1000);
      viddoc         NUMBER(8) := 0;
      vidfichero     VARCHAR2(100);
      vnumerr        NUMBER;
      vfarchiv       DATE;   --CONF 236 JAAB
      vfelimin       DATE;   --CONF 236 JAAB
      vfcaduci       DATE;   --CONF 236 JAAB
   BEGIN
      --INI JAAB CONF-236 22/08/2016
      vfarchiv := f_calcula_fecha_aec(1);
      vfcaduci := f_calcula_fecha_aec(2);
      vfelimin := f_calcula_fecha_aec(3);

      --FIN JAAB CONF 236 22/08/2016

      --ComprovaciÃ³ de parÃ¡metres d'entrada
      IF psprofes IS NULL
         OR puser IS NULL
         OR ptfilename IS NULL
         OR pidcat IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Gravem la capÃ³alera del document.
      --pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc); --JAAB CONF 236
      pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc,
                                  vfarchiv, vfelimin, vfcaduci);

      IF vterror IS NOT NULL
         OR NVL(viddoc, 0) = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      --Gravem a la BD el fiter en qÃ³estiÃ³ pidfichero .
      pac_axisgedox.actualiza_gedoxdb(ptfilename, viddoc, vterror);
      piddocgedox := viddoc;

      IF vterror IS NOT NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      vnumerr := pac_prof.f_set_documentacion(psprofes, pfcaduca, ptobserva, piddocgedox,
                                              ptdesc);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      COMMIT;
      vterror := pac_md_log.f_log_actividad('axisgedox', 1, viddoc, NULL, NULL, ptfilename,
                                            mensajes);
      --ProcÃ³s finalitzat correctament.
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_documprofgedox;

-- FIN BUG 21192 / NSS / 21-03-13 --

   -- INI BUG 28129 - FPG - 30-10-2013 -
   /*************************************************************************
      FunciÃ³ue inserta un documento en GEDOX.
      param in puser : Usuario
      param in ptfilename : Nombre del fichero
      param in out piddocgedox : Identificador del documento GEDOX
      param in ptdesc : Descripcion del documento
      param in pidcat : CategorÃ¯Â¿Â½del documento
      param out mensajes   : mensajes de error
      return               : 0/1 -> Ok/Error
   *************************************************************************/
   FUNCTION f_set_documgedox(
      puser IN VARCHAR2,
      ptfilename IN VARCHAR2,
      piddocgedox IN OUT NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes,
      pidfichero IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'puser: ' || puser || ' - ptfilename: ' || ptfilename || ' - piddocgedox: '
            || piddocgedox || ' - ptdesc:' || ptdesc || ' - pidcat: ' || pidcat;
      vobjectname    VARCHAR2(200) := 'PAC_MD_GEDOX.f_set_documgedox';
      vterror        VARCHAR2(1000);
      viddoc         NUMBER(8) := 0;
      vnumerr        NUMBER;
      vfarchiv       DATE;   --CONF 236 JAAB
      vfelimin       DATE;   --CONF 236 JAAB
      vfcaduci       DATE;   --CONF 236 JAAB
   BEGIN
      --INI JAAB CONF-236 22/08/2016
      vfarchiv := f_calcula_fecha_aec(1);
      vfcaduci := f_calcula_fecha_aec(2);
      vfelimin := f_calcula_fecha_aec(3);

      --FIN JAAB CONF 236 22/08/2016

      --Comprrueba los parÃ³Ã³tros de entrada
      IF puser IS NULL
         OR ptfilename IS NULL
         OR pidcat IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Graba la cabecera del documento.
      --pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc); --JAAB CONF 236
      pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc,
                                  vfarchiv, vfelimin, vfcaduci);

      IF vterror IS NOT NULL
         OR NVL(viddoc, 0) = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      -- Graba en la BD el fichero
      pac_axisgedox.actualiza_gedoxdb(pidfichero, viddoc, vterror);
      piddocgedox := viddoc;

      IF vterror IS NOT NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      COMMIT;
      vterror := pac_md_log.f_log_actividad('axisgedox', 1, viddoc, NULL, NULL, ptfilename,
                                            mensajes);
      --Proceso final correcto
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_documgedox;

-- FIN BUG 28129 - FPG - 30-10-2013 -

   -- BUG 28263 - RCL - 4-11-2013 - inicio
   FUNCTION f_set_docummovseg(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      puser IN VARCHAR2,
      ptfilename IN VARCHAR2,
      pidfichero IN VARCHAR2,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      porigen IN NUMBER DEFAULT 0,
      mensajes IN OUT t_iax_mensajes,
      pctipdest IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'psseguro: ' || psseguro || ' - pnmovimi:
' ||        pnmovimi || ' - puser: ' || puser || ' - ptfilename: ' || ptfilename
            || ' - ptdesc:
' ||        ptdesc || ' - pidcat: ' || pidcat;
      vobjectname    VARCHAR2(200) := 'PAC_MD_GEDOX.f_set_docummovseg';
      vterror        VARCHAR2(1000);
      viddoc         NUMBER(8) := 0;
      vidfichero     VARCHAR2(100);
      v_sperson      tomadores.sperson%TYPE;   -- Bug 22267 - MDS - 30/05/2012
      v_cagente      seguros.cagente%TYPE;   -- Bug 22267 - MDS - 30/05/2012
      v_existe       NUMBER := 0;   -- Bug 28263 - FPG - 27/11/2013
   BEGIN
      --ComprovaciÃ³ de parÃ¡metres d'entrada
      IF psseguro IS NULL
         OR pnmovimi IS NULL
         OR puser IS NULL
         OR ptfilename IS NULL
         OR pidcat IS NULL THEN
         RAISE e_param_error;
      END IF;

-- BUG 28263 - FPG - 27-11-2013 - inicio
-- En el alta de la propuesta no existirÃ¡Â Â°ero si la propuesta queda retenida, al autorizarla si que existirÃ¡??
      SELECT COUNT(*)
        INTO v_existe
        FROM docummovseg
       WHERE sseguro = psseguro
         AND nmovimi = pnmovimi
         AND iddocgedox = TO_NUMBER(pidfichero);

      IF v_existe = 0 THEN
-- BUG 28263 - FPG - 27-11-2013 - final
         vpasexec := 2;
         --Actualizamos el tdescrip del documento gedox
         pac_axisgedox.actualizacabecera(TO_NUMBER(pidfichero), f_user, pidcat, ptdesc,
                                         ptfilename);
         vpasexec := 3;

         BEGIN
            INSERT INTO docummovseg
                        (sseguro, nmovimi, iddocgedox, corigen)
                 VALUES (psseguro, pnmovimi, TO_NUMBER(pidfichero), porigen);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec,
                                                 vparam);
         END;

         vpasexec := 4;

         IF pctipdest = 2 THEN
            vpasexec := 5;

            SELECT sperson
              INTO v_sperson
              FROM tomadores
             WHERE sseguro = psseguro
               AND nordtom = (SELECT MIN(nordtom)
                                FROM tomadores
                               WHERE sseguro = psseguro);

            vpasexec := 6;

            SELECT cagente
              INTO v_cagente
              FROM seguros
             WHERE sseguro = psseguro;

            vpasexec := 7;

            BEGIN
               INSERT INTO per_documentos
                           (sperson, cagente, iddocgedox)
                    VALUES (v_sperson, ff_agente_cpervisio(v_cagente), TO_NUMBER(pidfichero));
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec,
                                                    vparam);
            END;
         END IF;

         COMMIT;
      --vterror := pac_md_log.f_log_actividad('axisgedox', 1, to_number(pidfichero), NULL, NULL, ptfilename, mensajes);
      --ProcÃ©s finalitzat correctament
      -- BUG 28263 - FPG - 27-11-2013 - inicio.
      END IF;

      -- BUG 28263 - FPG - 27-11-2013 - final
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_docummovseg;

-- BUG 28263 - RCL - 4-11-2013 - final
   FUNCTION f_set_docummovcompanigedox(
      pccompani IN NUMBER,
      puser IN VARCHAR2,
      ptfilename IN VARCHAR2,
      pidfichero IN OUT VARCHAR2,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'pccompani: ' || pccompani || ' - puser: ' || puser || ' - ptfilename: '
            || ptfilename || ' - ptdesc: ' || ptdesc || ' - pidcat: ' || pidcat;
      vobjectname    VARCHAR2(200) := 'PAC_MD_GEDOX.f_set_docummovcompanigedox';
      vterror        VARCHAR2(1000);
      viddoc         NUMBER(8) := 0;
      vidfichero     VARCHAR2(100);
   BEGIN
      IF pccompani IS NULL
         OR puser IS NULL
         OR ptfilename IS NULL
         OR pidcat IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc);

      IF vterror IS NOT NULL
         OR NVL(viddoc, 0) = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      pac_axisgedox.actualiza_gedoxdb(pidfichero, viddoc, vterror);
      pidfichero := viddoc;

      IF vterror IS NOT NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      INSERT INTO cmpani_doc
                  (ccompani, iddocgdx, ctipo, fcaduci, falta, tobserv)
           VALUES (pccompani, viddoc, pidcat, NULL, NULL, ptdesc);

      vpasexec := 6;
      COMMIT;
      vterror := pac_md_log.f_log_actividad('axisgedox', 1, viddoc, NULL, NULL, ptfilename,
                                            mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_docummovcompanigedox;

   --CONF - 236 JAVENDANO 22/08/2016
   FUNCTION f_calcula_fecha_aec(pcmodo IN NUMBER)
      /*
      CONF-236 22/08/2016
      JAVENDANO
      Valida PCMODO 1 archivar, 2 caducar y 3 eliminar
      Si el parÃ³metro existe suma su valor en meses a la fecha actual y retorna la fecha resultante
      */
   RETURN DATE IS
      mensajes       t_iax_mensajes;
      vobjectname    VARCHAR2(30) := 'F_CALCULA_FECHA_AEC';
      vntraza        NUMBER;
      vparam         VARCHAR2(255) := 'PCMODO: ' || pcmodo;
      vmeses         NUMBER;
      vempresa       NUMBER;
      verror         NUMBER;
      vfecharet      DATE;
   BEGIN
      vntraza := 1;
      vempresa := f_parinstalacion_n('EMPRESADEF');
      verror := pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(vempresa,
                                                                            'USER_BBDD'));

      CASE pcmodo
         WHEN 1 THEN
            vmeses := pac_parametros.f_parempresa_n(vempresa, 'MESES_ARCHIV');
         WHEN 2 THEN
            vmeses := pac_parametros.f_parempresa_n(vempresa, 'MESES_CADUCI');
         WHEN 3 THEN
            vmeses := pac_parametros.f_parempresa_n(vempresa, 'MESES_ELIMIN');
      END CASE;

      vfecharet := ADD_MONTHS(TRUNC(f_sysdate), vmeses);
      RETURN vfecharet;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vntraza, vparam,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_calcula_fecha_aec;

   FUNCTION f_set_gca_docgsfavclis(
      pidobs IN NUMBER,
      puser IN VARCHAR2,
      ptfilename IN VARCHAR2,
      pidfichero IN OUT VARCHAR2,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'pidobs: ' || pidobs || ' - puser: ' || puser || ' - ptfilename: ' || ptfilename
            || ' - ptdesc: ' || ptdesc || ' - pidcat: ' || pidcat;
      vobjectname    VARCHAR2(200) := 'PAC_MD_GEDOX.f_set_gca_docgsfavclis';
      vterror        VARCHAR2(1000);
      viddoc         NUMBER(8) := 0;
      vidfichero     VARCHAR2(100);
   BEGIN
      IF pidobs IS NULL
         OR puser IS NULL
         OR ptfilename IS NULL
         OR pidcat IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc);

      IF vterror IS NOT NULL
         OR NVL(viddoc, 0) = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      pac_axisgedox.actualiza_gedoxdb(ptfilename, viddoc, vterror);
      pidfichero := viddoc;
      IF vterror IS NOT NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;
      
      INSERT INTO gca_docgsfavcli
                  (idobs, iddocgedox, ctipo, fcaduci, falta, tobserv)
           VALUES (pidobs, viddoc, pidcat, NULL, NULL, ptdesc);

      vpasexec := 6;
      COMMIT;
      vterror := pac_md_log.f_log_actividad('axisgedox', 1, viddoc, NULL, NULL, ptfilename,
                                            mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_gca_docgsfavclis;

   /*************************************************************************
      FunciÃ³n que inserta un documento en GEDOX  y hace el insert del registro
      de documentaciÃ³n en la tabla ctgar_doc.
      param in psperson : Id. de la persona
      param in pCONTRA : codigo de LA contraGARANTIA
      param in puser : Usuario
      param in pfcaduca : Fecha de caducidad del documento
      param in ptobserva : Observaciones
      param in ptfilename : Nombre del fichero
      param in out piddocgedox : Identificador del documento GEDOX
      param in ptdesc : Descripcion
      param in pidcat : CategorÃ­a del documento
      param in ptdocumento : Tipo del documento
      param in pedocumento : Estado del documento
      param in pfedo : Fecha de estado del documento
      param out mensajes   : mensajes de error
      return               : 0/1 -> Ok/Error
   *************************************************************************/
   FUNCTION f_set_documcontragedox(
      psperson IN NUMBER,
      pcontra IN NUMBER,
      PNMOVIMI IN NUMBER,
      puser IN VARCHAR2,
      pfcaduca IN DATE,
      ptobserva IN VARCHAR2,
      ptfilename IN VARCHAR2,
      piddocgedox IN OUT NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      ptdocumento IN NUMBER DEFAULT NULL,
      pedocumento IN NUMBER DEFAULT NULL,
      pfedo IN DATE DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes,
      pdir IN VARCHAR2 DEFAULT NULL   -- NMM.CONF-337
                                   )
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'psperson: ' || psperson || ' - pcontra:
' ||        pcontra || ' - puser: ' || puser || ' - pfcaduca: ' || pfcaduca
            || ' - ptobserva: ' || ptobserva || ' - ptfilename: ' || ptfilename
            || ' - piddocgedox: ' || piddocgedox || ' - ptdesc:
' ||        ptdesc || ' - pidcat: ' || pidcat || ' - ptdocumento: ' || ptdocumento
            || ' - pedocumento: ' || pedocumento || ' - pfedo: ' || pfedo;
      vobjectname    VARCHAR2(200) := 'PAC_MD_GEDOX.f_set_documpersgedox';
      vterror        VARCHAR2(1000);
      viddoc         NUMBER(8) := 0;
      vidfichero     VARCHAR2(100);
      vnumerr        NUMBER;
      vfarchiv       DATE;   --CONF 236 JAAB
      vfelimin       DATE;   --CONF 236 JAAB
      vfcaduci       DATE;   --CONF 236 JAAB
      e_object_error3  EXCEPTION;
      e_object_error2  EXCEPTION;
   BEGIN
      --INI JAAB CONF-236 22/08/2016
      vfarchiv := f_calcula_fecha_aec(1);
      vfcaduci := f_calcula_fecha_aec(2);
      vfelimin := f_calcula_fecha_aec(3);

      --FIN JAAB CONF 236 22/08/2016

      --ComprovaciÃ³ de parÃ¡metres d'entrada
      IF psperson IS NULL
         OR pcontra IS NULL
         OR puser IS NULL
         OR ptfilename IS NULL
         OR pidcat IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --Gravem la capÃ³alera del document.
       --pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc); --JAAB CONF 236
      pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc,
                                  vfarchiv, vfelimin, vfcaduci);

      IF vterror IS NOT NULL
         OR NVL(viddoc, 0) = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      --Gravem a la BD el fitxer en qÃºestiÃ³ pidfichero .
      pac_axisgedox.actualiza_gedoxdb(ptfilename, viddoc, vterror, pdir);
      piddocgedox := viddoc;

      IF vterror IS NOT NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error2;
      END IF;



     vnumerr := pac_contragarantias.f_ins_contragaran_doc(pscontgar => pcontra,
                                                            pnmovimi  => PNMOVIMI,
                                                            piddocgdx => viddoc,
                                                            pctipo    => pidcat,
                                                            ptobserv  => ptdesc,
                                                            pfcaduci  => vfcaduci,
                                                            pfalta    => vfarchiv,
                                                            mensajes  => mensajes);


      IF vnumerr <> 0 THEN

         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error3;
      END IF;

      COMMIT;
      vterror := pac_md_log.f_log_actividad('axisgedox', 1, viddoc, NULL, NULL, ptfilename,
                                            mensajes);
      --ProcÃ©s finalitzat correctament.
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error2 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 2;
      WHEN e_object_error3 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 3;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 11;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN 111;
   END f_set_documcontragedox;

   /*************************************************************************
      FunciÃ³n que inserta un documento en GEDOX  y hace el insert del registro
      de documentaciÃ³n en la tabla AGD_OBSERVACIONES.
      param in psperson : Id. de la persona
      param in pcagente : codigo del agente
      param in puser : Usuario
      param in pfcaduca : Fecha de caducidad del documento
      param in ptobserva : Observaciones
      param in ptfilename : Nombre del fichero
      param in out piddocgedox : Identificador del documento GEDOX
      param in ptdesc : Descripcion
      param in pidcat : CategorÃ¿Â­a del documento
      param in ptdocumento : Tipo del documento
      param in pedocumento : Estado del documento
      param in pfedo : Fecha de estado del documento
      param out mensajes   : mensajes de error
      return               : 0/1 -> Ok/Error
   *************************************************************************/
   FUNCTION f_set_documobservagedox(
      ptfilename IN VARCHAR2,
      piddocgedox IN OUT NUMBER,
      ptdesc IN VARCHAR2 DEFAULT NULL,
      pidcat IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := ' - ptfilename: ' || ptfilename
            || ' - piddocgedox: ' || piddocgedox || ' - ptdesc:' || ptdesc || ' - pidcat: ' || pidcat;
      vobjectname    VARCHAR2(200) := 'PAC_MD_GEDOX.f_set_documobservagedox';
      vterror        VARCHAR2(1000);
      viddoc         NUMBER(8) := 0;
      vidfichero     VARCHAR2(100);
      vnumerr        NUMBER;
      vfarchiv       DATE;   --CONF 236 JAAB
      vfelimin       DATE;   --CONF 236 JAAB
      vfcaduci       DATE;   --CONF 236 JAAB
   BEGIN
      --INI JAAB CONF-236 22/08/2016
      vfarchiv := f_calcula_fecha_aec(1);
      vfcaduci := f_calcula_fecha_aec(2);
      vfelimin := f_calcula_fecha_aec(3);

      --FIN JAAB CONF 236 22/08/2016

      --ComprovaciÃ³ de parÃ¡metres d'entrada
      IF ptfilename IS NULL
         OR pidcat IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      pac_axisgedox.grabacabecera(f_user, ptfilename, ptdesc, 1, 1, pidcat, vterror, viddoc,
                                  vfarchiv, vfelimin, vfcaduci);

      IF vterror IS NOT NULL
         OR NVL(viddoc, 0) = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;
      p_control_error('SGM','  LLAMANDO actualiza_gedoxdb','ptfilename'||ptfilename||'viddoc'||viddoc||'vterror'||vterror);
      pac_axisgedox.actualiza_gedoxdb(ptfilename, viddoc, vterror);
      piddocgedox := viddoc;

      IF vterror IS NOT NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
         RAISE e_object_error;
      END IF;

      COMMIT;
      vterror := pac_md_log.f_log_actividad('axisgedox', 1, viddoc, NULL, NULL, ptfilename,
                                            mensajes);
      --ProcÃ©s finalitzat correctament.
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_documobservagedox;


END pac_md_gedox;
